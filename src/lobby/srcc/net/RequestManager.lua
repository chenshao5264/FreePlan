--
-- Author: Chen
-- Date: 2017-11-16 11:03:45
-- Brief: 
--
local RequestManager = {}

local wnet         = wnet

local protocolNum  = gg.protocolNum
local ClientSocket = gg.ClientSocket
local AppModel     = gg.AppModel
local Player       = gg.Player


--// 注册帐号
function RequestManager:reqRegister(account, nickname, pwd)
    local data = {}
    data.strAccount  = account
    data.strNickName = nickname
    data.strPasswd   = MD5:create():ComplexMD5(pwd)
    data.strMac      = cc.Native:getOpenUDID()

    gg.Player:setAccount(account)
    gg.Player:setPassword(data.strPasswd)

    local req = wnet.CL_REG_REQ.new(protocolNum.CL_PHONE_NOPHONECODE_REG_REQ_P)
    local pack = req:bufferIn(data):getPack()
    ClientSocket:sendMsg2Login(pack)
end

--// 请求登录login server
function RequestManager:reqLoginAccount(account, pwd, isMD5)
    if not isMD5 then
        pwd = MD5:create():ComplexMD5(pwd)
    end
    gg.Player:setAccount(account)
    gg.Player:setPassword(pwd)

    local req  = wnet.CL_LOGIN_REQ.new(protocolNum.PL_PHONE_CL_LOGIN_REQ_P)
    local pack = req:bufferIn(account, pwd):getPack()
    ClientSocket:sendMsg2Login(pack)
end

--// 请求登录lobby server
function RequestManager:reqLoginLobby()
    local req = wnet.PL_PHONE_CS_USERLOGIN_REQ.new(protocolNum.PL_PHONE_CS_USERLOGIN_REQ_P, Player:getUserID())
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        platForm = 0
    elseif targetPlatform == cc.PLATFORM_OS_ANDROID then
        platForm = 1
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        platForm = 2
    end

    local pack = req:bufferIn(Player:getUserID(), AppModel:getLobbyPassCode(), "", "", platForm):getPack()
    ClientSocket:sendMsg2Lobby(pack)
end

--// 请求游戏列表
function RequestManager:reqGameList(gameID)
    local req = wnet.PL_PHONE_CS_GAMELIST_REQ.new(protocolNum.PL_PHONE_CS_GAMELIST_REQ_P, Player:getUserID())
    local pack = req:bufferIn(gameID):getPack()
    ClientSocket:sendMsg2Lobby(pack)
end

--// 请求登录game server
function RequestManager:reqLoginGame(roomID)
    local req = wnet.CG_LOGIN_REQ.new(protocolNum.PL_PHONE_CG_LOGIN_REQ_P, Player:getUserID())
    local pack = req:bufferIn(roomID, AppModel:getLobbyPassCode()):getPack()
    ClientSocket:sendMsg2Game(pack)
end

--// 请求加入桌子
function RequestManager:reqEnterTable(tableID, chairID)
    gg.Player:setSelectedTableID(tableID)
    gg.Player:setSelectedChairID(chairID)
    local req = wnet.CG_ENTERTABLE_REQ.new(protocolNum.CG_ENTERTABLE_REQ_P, Player:getUserID())
    local pack = req:bufferIn(tableID, chairID, ""):getPack()
    ClientSocket:sendMsg2Game(pack)
end

--// 请求举手准备
function RequestManager:reqHandUp()
    local req = wnet.CG_HANDUP.new(protocolNum.CG_HANDUP_P, Player:getUserID())
    local pack = req:bufferIn():getPack()
    ClientSocket:sendMsg2Game(pack)
end

--// 充值商品信息
function RequestManager:reqRechargeInfo()
    local req = wnet.PL_PHONE_IOS_RECHARGEINFO_REQ.new(protocolNum.PL_PHONE_IOS_RECHARGEINFO_REQ_P, Player:getUserID())
    local pack = req:bufferIn():getPack()
    ClientSocket:sendMsg2Lobby(pack)
end

--// 充值
function RequestManager:reqRecharge(productId)
    local req = wnet.PL_PHONE_IOS_RECHARGE.new(protocolNum.PL_PHONE_IOS_RECHARGE_REQ_P, Player:getUserID())
    local pack = req:bufferIn(Player:getUserID(), "", "", productId):getPack()
    ClientSocket:sendMsg2Lobby(pack)
end

return RequestManager