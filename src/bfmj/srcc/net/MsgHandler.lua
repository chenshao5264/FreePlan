--
-- Author: Chen
-- Date: 2017-11-17 17:28:13
-- Brief: 
--

local MsgHandler = gg.MsgHandler
if not MsgHandler then
    return
end

local pp = pp
local protocolNum = gg.protocolNum
local MahjOp      = pp.GamePublic.MahjOp
local PlayModel   = pp.PlayModel

local gnet = game:loadSource("gamepublic.GameProtocol")


--// 退出小游戏时，清除这块跟小游戏有关的内存
function MsgHandler:clearGameMsg()
    MsgHandler[protocolNum.GC_HANDUP_P]       = nil
    MsgHandler[protocolNum.GC_GAME_START_P]   = nil
    MsgHandler[protocolNum.SC_MAHJ_DICE_P]    = nil
    MsgHandler[protocolNum.SC_BET_P]          = nil
    MsgHandler[protocolNum.SC_MAHJ_TITE_UP_P] = nil
    MsgHandler[protocolNum.SC_MAHJ_OP_REQ_P]  = nil
    MsgHandler[protocolNum.SC_MAHJ_OP_P]      = nil
end

--// 玩家准备通知
MsgHandler[protocolNum.GC_HANDUP_P] = function(buf)
    local resp = wnet.GC_HANDUP.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "GC_HANDUP")

    local chairID = S2CChair(resp.chairID)
    cclog.debug("玩家准备 chairID = " ..chairID)

    myApp:emit("evt_GC_HANDUP_P", {chairID = chairID})
end


--// 启动客户端定时器
MsgHandler[protocolNum.GC_STARTTIMER_P] = function(buf)
    local resp = wnet.GC_STARTTIMER.new()
    resp:bufferOut(buf)

    --cclog.debug(resp, "GC_STARTTIMER")

    local chairID = S2CChair(resp.chairID)

    myApp:emit("evt_timer_update", {chairID = chairID, timeSec = resp.timeSec, timeEvent = resp.timeEvent})
end
--// 游戏开始
MsgHandler[protocolNum.GC_GAME_START_P] = function(buf)
    cclog.debug("游戏开始")

    PlayModel:setIsNewRound(true)
    myApp:emit("evt_GC_GAME_START_P")
end



--// 色子
MsgHandler[protocolNum.SC_MAHJ_DICE_P] = function(buf)
    local resp = gnet.SC_MAHJ_DICE.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_DICE")

    local banker = S2CChair(resp.banker)
    PlayModel:setBankerChairID(banker)

    myApp:emit("evt_SC_MAHJ_DICE", {points = {resp.dices[3], resp.dices[4]}, banker = banker})
end

--// 底注通知
MsgHandler[protocolNum.SC_BET_P] = function(buf)
    local resp = gnet.SC_BET.new()
    resp:bufferOut(buf)
end

--// 转换成客户端绘制所需要的结构
local function convertFlatTiles(tiles)
    local flats = {}
    local tmp = {}
    for i = 1, #tiles do
        local tile = tiles[i]
        if tile == -1 then
            flats[#flats + 1] = tmp
            tmp = {}
        else
            tmp[#tmp + 1] = tile
        end
    end
    return flats
end

--// 更新牌,发牌通知和后续的更新牌是同一个协议
MsgHandler[protocolNum.SC_MAHJ_TITE_UP_P] = function(buf)
    local resp = gnet.SC_MAHJ_TITE_UP.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "SC_MAHJ_TITE_UP")

    local chairID = S2CChair(resp.chairID)

    local handTiles  = resp.handTiles
    local riverTiles = resp.riverTiles
    local flatTiles  = resp.flatTiles

    PlayModel:setRawFlatTiles(flatTiles)

    local flatTiles = convertFlatTiles(flatTiles)
    PlayModel:setFlatHeapCountByChairID(chairID, #flatTiles)

    PlayModel:setHandTilesByChairID(chairID, handTiles)
    PlayModel:setRiverTilesByChairID(chairID, riverTiles)
    PlayModel:setFlatTilesByChairID(chairID, flatTiles)


    --// bfmj
    PlayModel:checkNothingFixType()
    --// bfmj

    --// 不是新的回合，重现绘制这些牌在播放了动画之后
    --if PlayModel:getIsNewRound() then
        --// 第一轮牌更新，定义为发牌，总共会收到4次,每个玩家收到一次，后续考虑服务器，独立出发牌协议
        --// 现在在第一次要求客户端操作后，调用 PlayModel:setIsNewRound(false)
        myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = chairID})
    --end
end

--// 摸牌
MsgHandler[protocolNum.SC_MAHJ_DRAWN_P] = function(buf)
    local resp = gnet.SC_MAHJ_DRAWN.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_DRAWN")
    
    --// 发牌协议独立出来后，不需要这端代码
    if PlayModel:getIsNewRound() then
        PlayModel:setIsNewRound(false)
    end
    --//

    local chairID = S2CChair(resp.chairID)
    if chairID == 0 then
        PlayModel:setDrawTile(resp.tile)
    end
    myApp:emit("evt_SC_MAHJ_DRAWN_P", {chairID = chairID, tile = resp.tile, wallNum = resp.wallNum})
end

--// 操作请求
MsgHandler[protocolNum.SC_MAHJ_OP_REQ_P] = function(buf)
    local resp = gnet.SC_MAHJ_OP_REQ.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_OP_REQ")
    

    PlayModel:setCanOpActions(resp.op, resp.tile)
    PlayModel:setOpReqTime(resp.reqTime)

    myApp:emit("evt_SC_MAHJ_OP_REQ")
end

--// 操作广播
MsgHandler[protocolNum.SC_MAHJ_OP_P] = function(buf)
    local resp = gnet.SC_MAHJ_OP.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_OP")

    --// 清除出牌后的一些提示ui
    myApp:emit("evt_Hide_Play_Card_Tips")

    local chairID = S2CChair(resp.chairID)
    PlayModel:setNotifyOpAction(resp.op, resp.tile)

    local op = PlayModel:getCurOpAction()
    if op == MahjOp.DISCARD then
        --// 出牌事件派发
        myApp:emit("evt_SC_MAHJ_OP_P_DISCARD", {chairID = chairID, tile = resp.tile})

        --// 操作后，清空一些记录值
        if chairID == 0 then
            PlayModel:setPreDiscardTile(0)
            PlayModel:setDrawTile(0)
        end
    elseif op == MahjOp.CHOW or op == MahjOp.PONG or op == MahjOp.KONG then
        --// 吃碰杠听胡事件派发
        myApp:emit("evt_SC_MAHJ_OP_P_CPKTH", {chairID = chairID})
        myApp:emit("evt_Hide_Play_Card_Cursor")
    end

    --// 重置UI状态
    if chairID == 0 then
        myApp:emit("evt_Hide_Op_Buttons")
    end

    
end

--// 游戏结束
MsgHandler[protocolNum.SC_MAHJ_RESULT_P] = function(buf)
    local resp = gnet.SC_MAHJ_RESULT.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_RESULT")



    --// 座位号转化成本地客户端座位号
    for i = 1, #resp.vecResults do
        local chairID = S2CChair(resp.vecResults[i].chair)
        resp.vecResults[i].chair = chairID
        PlayModel:setResults(chairID, resp.vecResults[i])
    end

    myApp:emit("evt_timer_update", {chairID = -1, timeSec = 0})
    myApp:emit("evt_SC_MAHJ_RESULT")
end

--// 断线重连初始化数据
MsgHandler[protocolNum.SC_MAHJ_INITDATA_P] = function(buf)
    local resp = gnet.SC_MAHJ_INITDATA.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_INITDATA")

    PlayModel:setIsNewRound(false)

    local banker = S2CChair(resp.banker)
    PlayModel:setBankerChairID(banker)

    for i = 1, #resp.tilesData do
        local tilesData = resp.tilesData[i]

        local chairID = S2CChair(tilesData.chairID)
        local handTiles  = tilesData.handTiles
        local riverTiles = tilesData.riverTiles
        local flatTiles  = tilesData.flatTiles

        PlayModel:setRawFlatTiles(flatTiles)

        local flatTiles = convertFlatTiles(flatTiles)
        PlayModel:setFlatHeapCountByChairID(chairID, #flatTiles)

        PlayModel:setHandTilesByChairID(chairID, handTiles)
        PlayModel:setRiverTilesByChairID(chairID, riverTiles)
        PlayModel:setFlatTilesByChairID(chairID, flatTiles)

        --// bfmj
        PlayModel:checkNothingFixType()
        --// bfmj

        myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = chairID})
    end

    myApp:emit("evt_SC_MAHJ_INITDATA", {points = {resp.dices[3], resp.dices[4]}, wallNum = resp.wallNum, banker = banker})
end

----------------------------- bfmj
--// 开始定张
MsgHandler[protocolNum.SC_MAHJ_FIX_P] = function(buf)
    --local resp = gnet.SC_MAHJ_FIX.new()
    --resp:bufferOut(buf)
    myApp:emit("evt_SC_MAHJ_FIX_P")
end

--// 定张通知
MsgHandler[protocolNum.SC_MAHJ_FIX_ACK_P] = function(buf)
    local resp = gnet.CS_FIXTYPE_DATA.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "CS_FIXTYPE_DATA")

    local chairID = S2CChair(resp.chairID)
    PlayModel:setFixType(chairID, resp.type)

    if chairID == 0 then
        myApp:emit("evt_SC_MAHJ_FIX_ACK_P")
    end
end

--// 定张结束
MsgHandler[protocolNum.SC_MAHJ_FIX_END_P] = function(buf)
    --local resp = gnet.SC_MAHJ_FIX_END.new()
    --resp:bufferOut(buf)
    myApp:emit("evt_SC_MAHJ_FIX_END")
end

--// 定张结束后，整理牌面
MsgHandler[protocolNum.SC_MAHJ_FIX_MOVE_P] = function(buf)
    local resp = gnet.SC_MAHJ_FIX_MOVE.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_FIX_MOVE")


    PlayModel:setMyFixType(resp.FixType)
    PlayModel:setHandTilesByChairID(0, resp.handTiles)

    PlayModel:checkNothingFixType()
    myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = 0})
end

--// 分数变化
MsgHandler[protocolNum.SC_MAHJ_CALC_RESULT_P] = function(buf)
    local resp = gnet.SC_MAHJ_CALC_RESULT.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "SC_MAHJ_CALC_RESULT")

    --// 刮风下雨
    if resp.bKong == 1 or resp.bKong == 2 then
        local chairID = S2CChair(resp.chairID)
        myApp:emit("evt_SC_MAHJ_CALC_RESULT_P_Wind_Rain", {chairID = chairID})
    end
end