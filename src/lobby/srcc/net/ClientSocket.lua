require "net.protocol.protocolPublic"

local packBody  = require "net.protocol.packBody"

local socketTCP = require "framework.net.SocketTCP"
local scheduler = require "framework.scheduler"
local ByteArray = require "framework.utils.ByteArray"

local clientConfig = clientConfig
local protocolNumber = gg.protocolNum

local ClientSocket = class("ClientSocket")


local MsgHandler = gg.MsgHandler

function ClientSocket:ctor()
    self.playingScene = nil

    self._socketLogin = nil
    self._socketLobby = nil
    self._socketGame  = nil

    self._socketLobbyConnecting = false
    
    self._isQueuePause = false
    self._dataQueue = {}

    self._heartBeatElapsedTime = 0

    self.heartBeatCheckBuffer = wnet.heartBeatCheck.new(protocolNumber.CS_HEARTBEAT_CHECK_P):bufferIn()
end

function ClientSocket:setIsQueuePause(flag)
    self._isQueuePause = flag
end

function ClientSocket:connect(stage)
    local _socket = nil
    if stage == "login" then
        _socket = self._socketLogin
    elseif stage == "lobby" then
        _socket = self._socketLobby
    elseif stage == "game" then
        _socket = self._socketGame
    end

    assert(_socket, "invalid socket instence")
    local function onStatus(__event)
        -- print(string.format("socket status: %s", __event.name))
    end

    local function onConnected(__event)

        if stage == "lobby" then
            self._socketLobbyConnecting = true
        end

        local method = string.upper(stage) .."_SERVER_CONNECTED"
        if MsgHandler[method] then
            MsgHandler[method]()
        end
    end

    local function onClose(__event)
        print("connect close.")
        print(string.format("socket status: %s", __event.name))

    end

    local function onClosed(__event)
        print("connect closed.")
        print(string.format("socket status: %s", __event.name))


        if __event.socket == self._socketGame then
            
        elseif __event.socket == self._socketLobby then
            self._socketLobbyConnecting = false
        end
    end

    local function onConnectFailed(__event)
        print("connect failed.")
        print(string.format("socket status: %s", __event.name))
    end


    local function onData(__event)
       
        --[[
		---------------------------- mini game proc start------------------------------
        function self.procs.proc_GC_GAME_START_P(socket, buf) --游戏开始
            cc.dataMgr.isBroken = false
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_GAME_START_P"})
            if app.gameLayer ~= nil then
                app.gameLayer.eventProtocol:dispatchEvent({ name = "GC_GAME_START_P"})
            end
        end

		function self.procs.proc_mini_game_msg(socket, buf, opCode)
            if app.miniGameClientSocket ~= nil then
                app.miniGameClientSocket:procMsgs(socket, buf, opCode)
            else
                print("miniGameClientSocket is nil")
            end
		end
		---------------------------- mini game proc end------------------------------
       
    --]]
       
       
        --local str = string.format("socket data status: %s, data:%s", __event.name, ByteArray.toString(__event.data))
        table.insert(self._dataQueue, __event.data)
    end

    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CONNECTED, onConnected)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CLOSE, onClose)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CLOSED, onClosed)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CONNECT_FAILURE, onConnectFailed)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_DATA, onData)

    local function _doMsgProc()

        

        -- if #self._dataQueue > 0 then
        --     print("dataQueue " .. #self._dataQueue)
        -- end

        if stage == "lobby" and self._socketLobbyConnecting then
            self._heartBeatElapsedTime = self._heartBeatElapsedTime + 0.1
            if self._heartBeatElapsedTime > 30 then
                --cclog.error("心跳停止，需要断开连接")
                --self._socketLobbyConnecting = false
                --self:disconnectFromLobby()
            end
        end

        if self._isQueuePause then
            return
        end

        local msg = self._dataQueue[1]
        if not msg then
            return
        end
        table.remove(self._dataQueue, 1)

        local buffer = ByteArray.new():writeString(msg):setPos(1)
        local pack = packBody.new(buffer:readUInt(), buffer:readUInt(), buffer:readUShort(), buffer:readUInt(), buffer:readUInt())
        
        if MsgHandler[pack.opCode] then   
            cclog.debug("[recv msg from server] " ..pack.opCode)
            MsgHandler[pack.opCode](buffer)
        else
            if pack.opCode == protocolNumber.SC_HEARTBEAT_CHECK_P then
                --cclog.debug("lobby 心跳消息 : " ..self._heartBeatElapsedTime)
                --// 心跳
                self:sendHeartBeat2Lobby()
                self:sendHeartBeat2Game()
            else
                cclog.warn("un register msg code = " ..pack.opCode)
            end
        end
        
    end

    scheduler.scheduleGlobal(_doMsgProc, 0.1)
   
    _socket:connect()
end

function ClientSocket:sendHeartBeat2Game()
    if not self._socketGame then
        return
    end
    self._heartBeatElapsedTime = 0
    self._socketGame:send(self.heartBeatCheckBuffer:getPack())
end

function ClientSocket:sendHeartBeat2Lobby()
    if not self._socketLobby then
        return
    end
    self._heartBeatElapsedTime = 0
    self._socketLobby:send(self.heartBeatCheckBuffer:getPack())
end

function ClientSocket:connectToLogin()
    if self._socketLogin then
        return
    end
    self._socketLogin = socketTCP.new(clientConfig.serverHost, clientConfig.serverPort, false)
    self:connect("login")
end

function ClientSocket:connectToLobby(ip, port)
    if self._socketLobby then
        return
    end
    ip = clientConfig.serverHost
    self._socketLobby = socketTCP.new(ip, port, false)
    self:connect("lobby")
end

function ClientSocket:connectToGame(ip, port)
    if self._socketGame then
        return
    end
    self._socketGame = socketTCP.new(ip, port, false)
    self:connect("game")
end

function ClientSocket:disconnectFromLogin()
    if self._socketLogin then
        self._socketLogin:disconnect()
        self._socketLogin:close()
        self._socketLogin = nil
    end
end

function ClientSocket:disconnectFromLobby()
    if self._socketLobby then
        self._socketLobby:disconnect()
        self._socketLobby:close()
        self._socketLobby = nil
    end
end

function ClientSocket:disconnectFromGame()
    if self._socketGame then
        self._socketGame:disconnect()
        self._socketGame:close()
        self._socketGame = nil
    end
end

--// 发送消息到loginserver
function ClientSocket:sendMsg2Login(pack)
    if not self._socketLogin then
        cclog.warn("self._socketLogin has disconnect!")
        return
    end
    if DEBUG == 2 then
        local buffer = ByteArray.new():writeString(pack):setPos(1)
        local pack = packBody.new(buffer:readUInt(), buffer:readUInt(), buffer:readUShort(), buffer:readUInt(), buffer:readUInt())
        cclog.debug("[send msg to login server] " ..pack.opCode)
    end
    self._socketLogin:send(pack)
end

--// 发送消息到lobbyserver
function ClientSocket:sendMsg2Lobby(pack)
    if not self._socketLobby then
        cclog.warn("self._socketLobby has disconnect!")
        return
    end
    if DEBUG == 2 then
        local buffer = ByteArray.new():writeString(pack):setPos(1)
        local pack = packBody.new(buffer:readUInt(), buffer:readUInt(), buffer:readUShort(), buffer:readUInt(), buffer:readUInt())
        cclog.debug("[send msg to lobby server] " ..pack.opCode)
    end
    self._socketLobby:send(pack)
end

--// 发送消息到gameserver
function ClientSocket:sendMsg2Game(pack)
    if not self._socketGame then
        cclog.warn("self._socketGame has disconnect!")
        return
    end
    if DEBUG == 2 then
        local buffer = ByteArray.new():writeString(pack):setPos(1)
        local pack = packBody.new(buffer:readUInt(), buffer:readUInt(), buffer:readUShort(), buffer:readUInt(), buffer:readUInt())
        cclog.debug("[send msg to game server] " ..pack.opCode)
    end
    self._socketGame:send(pack)
end

return ClientSocket