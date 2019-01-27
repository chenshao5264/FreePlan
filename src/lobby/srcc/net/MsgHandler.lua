--
-- Author: Chen
-- Date: 2017-11-16 10:46:49
-- Brief: 
--
local MsgHandler = {}

local gg = gg
local AppModel       = gg.AppModel
local protocolNum    = gg.protocolNum
local Player         = gg.Player

function S2CChair(chairID)
    if chairID < 0 then
        return chairID
    end
    local myChairID = Player:getSelectedChairID()
    if not myChairID then
        return chairID
    end
    return (chairID - myChairID + 4) % 4
end

--// 连接login server成功
MsgHandler["LOGIN_SERVER_CONNECTED"] = function()
    cclog.info("login server connected!")
    AppModel:setIsLoginConnected(true)

    if _DEBUG_QUICK_ENTER_GAME then
        gg.RequestManager:reqLoginAccount(_DEBUG_LOGIN_ACCOUNT, _DEBUG_LOGIN_PWD, false)
        return
    end

    myApp:emit("LOGIN_SERVER_CONNECTED")

end

--// 连接lobby server成功
MsgHandler["LOBBY_SERVER_CONNECTED"] = function()
    cclog.info("lobby server connected!")
    gg.RequestManager:reqLoginLobby()
end

--// 连接game server成功
MsgHandler["GAME_SERVER_CONNECTED"] = function()
    cclog.info("game server connected!")
    gg.RequestManager:reqLoginGame(1)
end

--// 注册回复
MsgHandler[protocolNum.LC_PHONECODE_REG_ACK_P] = function(buf)
    local resp = wnet.LC_REG_ACK.new()
    resp:bufferOut(buf)
    --cclog.warn(resp, "LC_PHONECODE_REG_ACK_P")

    myApp:emit("evt_LC_PHONECODE_REG_ACK_P", {ret = resp.ret})
end

--// 登录login回复
MsgHandler[protocolNum.PL_PHONE_LC_LOGIN_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_LC_LOGIN_ACK.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "PL_PHONE_LC_LOGIN_ACK_P")


    if resp.loginRet == 0 then
        AppModel:saveAccount()
        Player:setUserID(resp.userID)
        AppModel:setLobbyPassCode(resp.passCode)
        gg.ClientSocket:connectToLobby(resp.ip, resp.port)
    else
        myApp:emit("evt_PL_PHONE_LC_LOGIN_ACK_P", {ret = resp.loginRet})
    end
end

--// 登录lobby回复
MsgHandler[protocolNum.PL_PHONE_SC_USERLOGIN_ACK_P] = function(buf)
    local resp = wnet.SC_USERLOGIN_ACK.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "PL_PHONE_SC_USERLOGIN_ACK_P")

    if _DEBUG_QUICK_ENTER_GAME then
        if resp.lobbyResult == 0 then
            gg.ClientSocket:disconnectFromLogin()
            Player:setPlayerBasicInfo(resp.lobbyUser)
            gg.RequestManager:reqGameList(GAME_ID)
            --gg.RequestManager:reqRechargeInfo()
        end
        return
    end

    if resp.lobbyResult == 0 then
        gg.ClientSocket:disconnectFromLogin()
        Player:setPlayerBasicInfo(resp.lobbyUser)
        myApp:enterScene(LOBBY_SCENE)
    else

    end
end

--// 判断是否是断线重连
MsgHandler[protocolNum.DC_USER_LOAD_BROKEN_GAME_P] = function(buf)
    local resp = wnet.BROKEN_GAME_LIST.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "DC_USER_LOAD_BROKEN_GAME_P")
    if #resp.vList > 0 then
        AppModel:setIsBrokenConnect(true)
    end
end

--// 房间列表回复
MsgHandler[protocolNum.PL_PHONE_SC_GAMELIST_ACK_P] = function(buf)
    local resp = wnet.SC_GAMELIST_ACK.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "PL_PHONE_SC_GAMELIST_ACK_P")

    local vecGameInfo = resp.vecGameInfo[1]
    if vecGameInfo then
        local svrInfo = vecGameInfo.svrInfo
        gg.ClientSocket:connectToGame(svrInfo.srvIP, svrInfo.srvPort)
    end
end

--// 登录game server
MsgHandler[protocolNum.PL_PHONE_GC_LOGIN_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_GC_LOGIN_ACK.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "PL_PHONE_GC_LOGIN_ACK_P")

    Player:setSelectedTableID(_DEBUG_SELECTED_TABLEID)
    Player:setSelectedChairID(_DEBUG_SELECTED_CHAIRID)
    gg.RequestManager:reqEnterTable(_DEBUG_SELECTED_TABLEID, _DEBUG_SELECTED_CHAIRID)
end

--// 进入桌子回复
MsgHandler[protocolNum.GC_ENTERTABLE_ACK_P] = function(buf)
    local resp = wnet.GC_ENTERTABLE_ACK.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "GC_ENTERTABLE_ACK")
    if resp.result == gg.EnterTableResult.OK then
        cclog.debug("进入桌子成功")

        myApp:launchGame(LAUNCH_GAME)
    end
end

--// 桌子玩家列表用户
MsgHandler[protocolNum.GC_TABLE_USERLIST_P] = function(buf)
    local resp = wnet.GC_TABLE_USERLIST.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "GC_TABLE_USERLIST_P")

    local TableModel = gg.TableModel
    for i = 1, #resp.userList do
        local user = resp.userList[i]
        local gameData = user.gameData
        local userData = user.userData
        TableModel:addUserByChairID(S2CChair(gameData.chairID), {
            userStatus  = gameData.userStatus,
            gender      = userData.gender,
            strNickName = userData.strNickName,
            userID      = userData.userID,
        })
    end

    myApp:emit("evt_GC_TABLE_USERLIST_P")
end

--// 加入桌子广播
MsgHandler[protocolNum.GC_ENTERTABLE_P] = function(buf)
    local resp = wnet.GC_ENTERTABLE.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "GC_ENTERTABLE")

    if resp.tableID ~= Player:getSelectedTableID() then
        return
    end

    local TableModel = gg.TableModel

    TableModel:setTableID(resp.tableID)

    local user = resp.gameUser
    local gameData = user.gameData
    local userData = user.userData

    local chairID = S2CChair(resp.chairID)
    TableModel:addUserByChairID(chairID, {
        userStatus  = gameData.userStatus,
        gender      = userData.gender,
        strNickName = userData.strNickName,
        userID      = userData.userID,
    })

    myApp:emit("evt_GC_ENTERTABLE", {chairID = chairID})
end

--// 离开房间广播
MsgHandler[protocolNum.GC_LEAVETABLE_P] = function(buf)
    local resp = wnet.GC_LEAVETABLE.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "GC_LEAVETABLE")
    local TableModel = gg.TableModel
    TableModel:removeUserByUserID(resp.userID)


    local chairID = TableModel:getChairIDByUserID(resp.userID)
    cclog.warn(chairID)
    if chairID then
        myApp:emit("evt_GC_LEAVETABLE_P", {chairID = chairID})
    end
end

--// 玩家游戏状态更新
MsgHandler[protocolNum.GC_GAMEUSER_UP_P] = function(buf)
    local resp = wnet.GC_GAMEUSER_UP.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "GC_GAMEUSER_UP")

    if not resp.attrList then
        return
    end
    local TableModel = gg.TableModel
    local userID = resp.userID
    table.foreach(resp.attrList, function(_, v)
        local attrEntry = v.attrEntry
        local attrValue = v.attrValue

        if attrEntry == wnet.Attr_Entry.eAttrEntry_Status then   --游戏状态更新
            TableModel:changeUserStatusByUserID(userID, attrValue)
        end
    end)
end

--// 充值商品信息回复 
MsgHandler[protocolNum.PL_PHONE_IOS_RECHARGEINFO_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_IOS_RECHARGEINFO.new()
    resp:bufferOut(buf)
    --cclog.debug(resp, "PL_PHONE_IOS_RECHARGEINFO")

    AppModel:setShopGoodsInfo(resp.iosRechargeInfo)

    myApp:emit("evt_PL_PHONE_IOS_RECHARGEINFO_ACK_P")

    --cclog.warn(AppModel:getShopGooldsInfo(), "AppModel:getShopGooldsInfo()")

    --gg.RequestManager:reqRecharge(AppModel:getShopGooldsInfo()[2][1].productId)
end

--// 充值结果
MsgHandler[protocolNum.PL_PHONE_IOS_RECHARGE_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_IOS_RECHARGE_ACK.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "PL_PHONE_IOS_RECHARGE_ACK")

    if resp.nRet == 0 then
        if resp.payType == gg.CurrencyType.BEAN then
            Player:setBeanCurrency(resp.totalGameCurrency.l)
            myApp:emit("evt_bean_update")

        elseif resp.payType == gg.CurrencyType.DIAMOND then
            Player:setDiamondCurrency(resp.totalGoldCurrency)
            myApp:emit("evt_diamond_update")
        end
    end
    myApp:emit("evt_PL_PHONE_IOS_RECHARGE_ACK_P", {nRet = resp.nRet})
end

--// 玩家签到信息 
MsgHandler[protocolNum.PL_PHONE_LC_INISIGNININFO_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_LC_INISIGNININFO.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "PL_PHONE_LC_INISIGNININFO")

    AppModel:setSignInInfo(resp.bSignIn, resp.signInDay, resp.signInAwardInfo.awardInfo)

    myApp:emit("evt_sign_red_tag_visible", {bSignIn = resp.bSignIn ~= 0})
end

--// 签到回复
MsgHandler[protocolNum.PL_PHONE_LC_SIGNIN_ACK_P] = function(buf)
    local resp = wnet.PL_PHONE_LC_SIGNIN.new()
    resp:bufferOut(buf)
    cclog.debug(resp, "PL_PHONE_LC_SIGNIN")

    if resp.signResult == 0 then
        AppModel:doSignIn()
        myApp:emit("evt_PL_PHONE_LC_SIGNIN_ACK_P")
        myApp:emit("evt_sign_red_tag_visible", {bSignIn = true})
        if resp.totalGameCurrency.l > 0 then
            Player:setBeanCurrency(resp.totalGameCurrency.l)
            myApp:emit("evt_bean_update")
        end
        if resp.totalGoldCurrency > 0 then
            Player:setDiamondCurrency(resp.totalGoldCurrency)
            myApp:emit("evt_diamond_update")
        end
    else

    end
end

--// 是否显示首冲按钮
-- MsgHandler[protocolNum.PL_PHONE_LC_SHOWFIRSTINFO_ACK_P] = function(buf)
-- end

--// 玩家代币信息
-- MsgHandler[protocolNum.SC_LOGIN_TOKEN_P] = function(buf)
--     local resp = wnet.SC_LOGIN_TOKEN.new()
--     resp:bufferOut(buf)
-- end



return MsgHandler
