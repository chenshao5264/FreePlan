--
-- Author: Chen
-- Date: 2017-11-23 19:46:41
-- Brief: 
--

local gg = gg
local pp = pp

local RequestManager = gg.RequestManager or {}
local ClientSocket   = gg.ClientSocket
local protocolNum    = gg.protocolNum
local Player         = gg.Player


local GamePublic = pp.GamePublic
local MahjOp     = GamePublic.MahjOp
local PlayModel  = pp.PlayModel

local gnet = game:loadSource("gamepublic.GameProtocol")

--// 退出小游戏时，清除这块跟小游戏有关的内存
function RequestManager:clearGameReq()
    RequestManager.reqDiscard = nil
    RequestManager.reqOpAck   = nil
    RequestManager.reqPass    = nil
    RequestManager.reqChow    = nil
    RequestManager.reqPong    = nil
    RequestManager.reqKong    = nil
end

-- /**
--  * 请求出牌
--  */
function RequestManager:reqDiscard(tile)
    if not PlayModel:canPlay() then
        return
    end
    self:reqOpAck(MahjOp.DISCARD, tile)
end

-- /**
--  * 请求杠牌
--  * @param tile 可能不是服务器发过来的值，因为可能有旋风杠(ccmj)
--  * @param op 可能不是服务器发过来的值，因为可能有多杠选择(ccmj 东东东东 东南西北 等)
--  */
function RequestManager:reqKong(tile, op)
    self:reqOpAck(op, tile)
end

-- /**
--  * 请求碰牌
--  */
function RequestManager:reqPong()
    self:reqOpAck(MahjOp.PONG, PlayModel:getOpTile())
end

-- /**
--  * 请求吃牌
--  * @param op 可能不是服务器发过来的值，因为可能有多吃选择
--  */
function RequestManager:reqChow(op)
    self:reqOpAck(op, PlayModel:getOpTile())
end

-- /**
--  * 请求过牌
--  */
function RequestManager:reqPass()
    self:reqOpAck(MahjOp.GIVEUP, PlayModel:getOpTile())
end

-- /**
--  * 请求胡
--  */
function RequestManager:reqHu()
    self:reqOpAck(GamePublic.band(MahjOp.WIN, PlayModel:getOp()), PlayModel:getOpTile())
end


-- /**
--  * 发送操作回复给服务器
--  */
function RequestManager:reqOpAck(op, tile)
    --// ui
    myApp:emit("evt_Hide_Op_Buttons")

    PlayModel:clearCanActions()

    local reqTime = PlayModel:getOpReqTime()
    local req = gnet.CS_MAHJ_OP_ACK.new(protocolNum.CS_MAHJ_OP_ACK_P, Player:getUserID())
    ClientSocket:sendMsg2Game(req:bufferIn(tile, op, reqTime):getPack())
end


--------------------------// bfmj

--// 定张请求
function RequestManager:reqFix(fixType)
    local req = gnet.CS_FIXTYPE_DATA.new(protocolNum.CS_MAHJ_FIX_REQ_P, Player:getUserID())
    ClientSocket:sendMsg2Game(req:bufferIn(0, fixType):getPack())
end
    