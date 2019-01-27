require "framework.utils.ByteArray"
require "framework.utils.BigNumber"
require "framework.utils.bit"

local packBody = require "net.protocol.packBody"

local iconv = require "iconv"
local encoding = iconv.new("utf-8", "GB18030") --多字节 -->utf8  接受服务器带中文字字段
local decoding = iconv.new("GB18030", "utf-8") --utf8 -->多字节 发送到服务器 带中文字字段

---[[
local function UTF82Mutiple(str)
    if str == "" then return str end
    return decoding:iconv(str)
end

local function Mutiple2UTF8(str)
    if str == "" then return str end
    return encoding:iconv(str)
end
--]]
local MAX_IP_LENGTH = 16 --ip地址长度

wnet = {}
wnet.packBody = packBody
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.heartBeatCheck = class("heartBeatCheck", packBody)
function wnet.heartBeatCheck:ctor(code, uid, pnum, mapid, syncid)
    wnet.heartBeatCheck.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.heartBeatCheck:bufferIn()
    local buf = wnet.CL_LOGIN_REQ.super.bufferIn(self)
    return buf
end

--// **************************************************************
--// **************************************************************
wnet.EUserStatus                            = {}
wnet.EUserStatus.EGAME_STATUS_NULL          = 0
wnet.EUserStatus.EGAME_STATUS_LOADING       = 1
wnet.EUserStatus.EGAME_STATUS_ROOM          = 2
wnet.EUserStatus.EGAME_STATUS_TABLE         = 3
wnet.EUserStatus.EGAME_STATUS_READY         = 4
wnet.EUserStatus.EGAME_STATUS_GAMEING       = 5
wnet.EUserStatus.EGAME_STATUS_WATCH         = 6
wnet.EUserStatus.EGAME_STATUS_BOKEN         = 7
wnet.EUserStatus.EGAME_STATUS_BOKENTIMEOUT  = 8
wnet.EUserStatus.EGAME_STATUS_WAITING       = 9
wnet.EUserStatus.EGAME_STATUS_RUNBYNOBROKEN = 10
wnet.EUserStatus.EGAME_STATUS_MATCH         = 11

local stGameData = class("stGameData")
function stGameData:ctor()
end

function stGameData:bufferOut(buf)
    self.userStatus = buf:readInt()
    self.tableID    = buf:readChar()
    self.chairID    = buf:readChar()
    self.nScore     = buf:readInt()
    self.nWin       = buf:readInt()
    self.nLose      = buf:readInt()
    self.nDraw      = buf:readInt()
    self.nDisc      = buf:readInt()
end

local stUserData = class("stUserData")
function stUserData:ctor()
end

function stUserData:bufferOut(buf)
    self.userID       = buf:readInt()
    self.ident        = buf:readInt()
    self.gmPur        = buf:readInt()
    self.icon         = buf:readShort()
    self.gender       = buf:readChar()
    self.vipExp       = buf:readInt()
    self.vipBegin     = buf:readInt()
    self.vipEnd       = buf:readInt()
    self.vipLevel     = buf:readChar()
    self.honor        = buf:readInt()
    self.honorLevel   = buf:readChar()
    local gch         = buf:readUInt()
    local gcl         = buf:readUInt()
    self.gameCurrency = i64(gch, gcl)
    self.strNickName  = Mutiple2UTF8(buf:readStringUShort())
end

local stGameUser = class("stGameUser")
function stGameUser:ctor()
    self.userData = stUserData.new()
    self.gameData = stGameData.new()
end

function stGameUser:bufferOut(buf)
    self.userData:bufferOut(buf)
    self.gameData:bufferOut(buf)
end


--// **************************************************************
--// **************************************************************
wnet.CL_LOGIN_REQ = class("CL_LOGIN_REQ", packBody)
function wnet.CL_LOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.CL_LOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CL_LOGIN_REQ:bufferIn(name, pwd, ip, vcode, mac, gate)
    local buf = wnet.CL_LOGIN_REQ.super.bufferIn(self)
    buf:writeStringUShort(decoding:iconv(name))
        :writeStringUShort(pwd):writeStringUShort(ip or "")
        :writeStringUShort(vcode or "")
        :writeStringUShort(mac or "")
        :writeStringUShort(gate or 0)
    return buf
end

wnet.ELoginResult                           = {}
wnet.ELoginResult.ELOGIN_RESULT_OK          = 0                          --登陆成功
wnet.ELoginResult.ELOGIN_RESULT_WRONGVALID  = 1                  --验证码错误
wnet.ELoginResult.ELOGIN_RESULT_NONAME      = 2                      --用户不存在
wnet.ELoginResult.ELOGIN_RESULT_WRONGPASSWD = 3                 --密码错误
wnet.ELoginResult.ELOGIN_RESULT_BINDING     = 4                     --帐号绑定在其它机器登陆
wnet.ELoginResult.ELOGIN_RESULT_FORBID      = 5                      --帐号被禁用
wnet.ELoginResult.ELOGIN_RESULT_ICE         = 6                         --帐号被封冻
wnet.ELoginResult.ELOGIN_RESULT_LOST        = 7                        --帐号失效
wnet.ELoginResult.ELOGIN_RESULT_RELOGIN     = 8                     --帐号已经登陆
wnet.ELoginResult.ELOGIN_RESULT_BUSY        = 9                        --系统繁忙
wnet.ELoginResult.ELOGIN_RESULT_WRONGDYNPWD = 10                --动态密码错误

wnet.PL_PHONE_LC_LOGIN_ACK = class("PL_PHONE_LC_LOGIN_ACK", packBody)
function wnet.PL_PHONE_LC_LOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_LC_LOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
    self.name = "PL_PHONE_LC_LOGIN_ACK"
end

function wnet.PL_PHONE_LC_LOGIN_ACK:bufferOut(buf)
    self.loginRet  = buf:readUInt()
    self.userID    = buf:readInt()
    self.passCode  = buf:readStringUShort()
    self.serverID  = buf:readInt()
    self.ip        = buf:readStringUShort()
    self.port      = buf:readUShort()
    self.lastIP    = buf:readStringUShort()
    self.lastTime  = buf:readInt()
    self.curIP     = buf:readStringUShort()
    self.curTime   = buf:readInt()
    self.startTime = buf:readChar()
end

--// **************************************************************
--// **************************************************************
wnet.CL_REG_REQ = class("CL_REG_REQ", packBody)
function wnet.CL_REG_REQ:ctor(code, uid, pnum, mapid, syncid)  
    wnet.CL_REG_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CL_REG_REQ:bufferIn(data)
    local buf = wnet.CL_REG_REQ.super.bufferIn(self)
    buf:writeStringUShort(data.strAccount or "")
        :writeStringUShort(data.strNickName or "")
        :writeStringUShort(data.strPasswd or "")
        :writeStringUShort(data.strRealName or "")
        :writeStringUShort(data.strIDCard or "")
        :writeStringUShort(data.strPhone or "")
        :writeStringUShort(data.strEmail or "")
        :writeStringUShort(data.strValid or "")
        :writeChar(gender or 0)
        :writeShort(icon or 1)
        :writeStringUShort(data.strIP or "")
        :writeStringUShort(data.strMac or "")
        :writeChar(phoneReg or 1)
    return buf
end

wnet.LC_REG_ACK = class("LC_REG_ACK", packBody)
function wnet.LC_REG_ACK:ctor(code, uid, pnum, mapid, syncid)  
    wnet.LC_REG_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.LC_REG_ACK:bufferOut(buf)
    self.ret      = buf:readUInt()
    self.uerID    = buf:readUInt()
    self.leftTime = buf:readChar()
end

--// **************************************************************
--// **************************************************************
local lobbyUser = class("lobbyUser")
function lobbyUser:ctor(code, uid, pnum, mapid, syncid)
end
function lobbyUser:bufferOut(buf)
    self.userID          = buf:readUInt() --用户ID
    self.ident           = buf:readUInt() --用户身份
    self.gmPur           = buf:readUInt() --如果是GM,GM权限
    self.icon            = buf:readUShort() --ICON
    self.gender          = buf:readChar() --性别
    self.vipExp          = buf:readUInt() --vip经验，以天为单位
    self.vipBegin        = buf:readUInt() --vip最后一次续费时间
    self.vipEnd          = buf:readUInt() --vip还有多久到期
    self.vipLevel        = buf:readChar() --vip等级, 0为非会员
    self.vipUp           = buf:readUInt() --vip还有多少天升级
    self.cofferEnd       = buf:readUInt() --保险箱结束时间
    self.cofferstate     = buf:readChar() --保险箱状态, 0是为开通，1是已开通但过期， 2是开通没过期
    self.honor           = buf:readUInt() --声望
    self.honorLevel      = buf:readChar() --声望等级
    local gch            = buf:readUInt()
    local gcl            = buf:readUInt()
    self.gameCurrency    = i64(gch, gcl) --游戏豆
    local cch            = buf:readUInt()
    local ccl            = buf:readUInt()
    self.cofferCurrency  = i64(cch, ccl) --保险箱里的游戏豆
    self.goldCurrency    = tonumber(buf:readFloat()) --风雷币
    self.isHaveAdvPasswd = buf:readChar() --是否应有二级密码
    self.strNickNamebuf  = encoding:iconv(buf:readStringUShort()) --昵称
end

wnet.SC_USERLOGIN_ACK = class("SC_USERLOGIN_ACK", lobbyUser)
function wnet.SC_USERLOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
    wnet.SC_USERLOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.SC_USERLOGIN_ACK:bufferOut(buf)
    self.userID      = buf:readUInt()
    self.lobbyResult = buf:readUInt()
    self.lobbyUser   = lobbyUser.new()
    self.lobbyUser:bufferOut(buf)
end
--// **************************************************************
--// **************************************************************
wnet.BROKEN_GAME_LIST = class("BROKEN_GAME_LIST", packBody)
function wnet.BROKEN_GAME_LIST:ctor(code, uid, pnum, mapid, syncid)
    wnet.BROKEN_GAME_LIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.BROKEN_GAME_LIST:bufferOut(buf)
    self.vList = {}
    local vListSize = buf:readShort()
    for i = 1, vListSize do
        local tmp = {}
        tmp.gameId = buf:readShort()
        tmp.srvId  = buf:readInt()
        tmp.roomId = buf:readChar()
        self.vList[#self.vList + 1] = tmp
    end
end
--// **************************************************************
--// **************************************************************
local serverInfo = class("ServerInfo")
function serverInfo:ctor()
end

function serverInfo:bufferOut(buf)
    self.srvIP    = buf:readBuf(MAX_IP_LENGTH)
    self.srvPort  = buf:readUShort()
    self.srvID    = buf:readInt()
    self.gateType = buf:readInt()
end

local gameInfo = class("GameInfo")
function gameInfo:ctor()
end

function gameInfo:bufferOut(buf)
    self.gameID      = buf:readShort()
    self.gameType    = buf:readInt()
    self.typeName    = encoding:iconv(buf:readStringUShort())
    self.gameName    = encoding:iconv(buf:readStringUShort())
    self.chanelName  = encoding:iconv(buf:readStringUShort())
    self.appName     = encoding:iconv(buf:readStringUShort())
    self.roomMaxNum  = buf:readShort()
    self.tableNum    = buf:readShort()
    self.tablePlyNum = buf:readShort()
    self.reConn      = buf:readChar()
    local gch        = buf:readUInt()
    local gcl        = buf:readUInt()
    self.moneyLimit  = i64(gch, gcl)
    self.startType   = buf:readInt()
    self.hancUpNum   = buf:readChar()
    self.sortID      = buf:readShort()
    self.tax         = buf:readInt()
    self.onlineGive  = buf:readInt()
    self.version     = buf:readInt()
    self.downUrl     = encoding:iconv(buf:readStringUShort())
    self.rightUrl    = encoding:iconv(buf:readStringUShort())
    self.gameChanel  = buf:readInt()
    self.nGameBet    = buf:readInt()
end

local roomInfo = class("RoomInfo")
function roomInfo:ctor()
end

function roomInfo:bufferOut(buf)
    self.roomID = buf:readChar()
    self.szRoomName = encoding:iconv(buf:readStringUShort())
    self.userNum = buf:readInt()
    self.roomIcon = encoding:iconv(buf:readStringUShort())
end

local gameTotalInfo = class("GameTotalInfo")
function gameTotalInfo:ctor()
end

function gameTotalInfo:bufferOut(buf)
    self.svrInfo = serverInfo.new()
    self.svrInfo:bufferOut(buf)

    self.gameInfo = gameInfo.new()
    self.gameInfo:bufferOut(buf)

    self.rmInfo = {}
    local len = buf:readShort()
    for i = 1, len do
        local rmi = roomInfo.new()
        rmi:bufferOut(buf)
        self.rmInfo[#self.rmInfo + 1] = rmi
    end
end

wnet.SC_GAMELIST_ACK = class("SC_GAMELIST_ACK", packBody)
function wnet.SC_GAMELIST_ACK:ctor(code, uid, pnum, mapid, syncid)
    self.name = "SC_GAMELIST_ACK"
    wnet.SC_GAMELIST_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.SC_GAMELIST_ACK:bufferOut(buf)
    self.vecGameInfo = {}
    local len = buf:readShort()
    for i = 1, len do
        local gi = gameTotalInfo.new()
        gi:bufferOut(buf)
        self.vecGameInfo[#self.vecGameInfo + 1] = gi
    end
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_GC_LOGIN_ACK = class("PL_PHONE_GC_LOGIN_ACK", packBody)
function wnet.PL_PHONE_GC_LOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_GC_LOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_GC_LOGIN_ACK:bufferOut(buf)
    self.bRet     = buf:readInt()
    self.userID   = buf:readInt()
    self.gameData = stGameData.new()
    self.gameData:bufferOut(buf)
    self.svrID    = buf:readInt()
    self.roomID   = buf:readChar()
end
--// **************************************************************
--// **************************************************************
wnet.GC_ENTERTABLE_ACK = class("GC_ENTERTABLE_ACK", packBody)
function wnet.GC_ENTERTABLE_ACK:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_ENTERTABLE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.GC_ENTERTABLE_ACK:bufferOut(buf)
    self.result          = buf:readInt()
    self.forbidID        = buf:readInt()
    self.lineUpTime      = buf:readInt()
    self.minGameCurrency = buf:readInt()
end
--// **************************************************************
--// **************************************************************
wnet.GC_TABLE_USERLIST = class("GC_TABLE_USERLIST", packBody)
function wnet.GC_TABLE_USERLIST:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_TABLE_USERLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_TABLE_USERLIST:bufferOut(buf)
    self.userList = {}
    local len = buf:readShort()
    
    for i = 1, len, 1 do
        local ti = stGameUser.new()
        ti:bufferOut(buf)
        self.userList[#self.userList + 1] = ti
    end
end
--// **************************************************************
--// **************************************************************
wnet.GC_ENTERTABLE = class("GC_ENTERTABLE", packBody)
function wnet.GC_ENTERTABLE:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_ENTERTABLE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_ENTERTABLE:bufferOut(buf)
    self.gameUser = stGameUser.new()
    self.gameUser:bufferOut(buf)
    self.tableID  = buf:readChar()
    self.chairID  = buf:readChar()
    self.isOB     = buf:readChar()
    self.setBet   = buf:readInt()
end
--// **************************************************************
--// **************************************************************
wnet.GC_LEAVETABLE = class("GC_LEAVETABLE", packBody)
function wnet.GC_LEAVETABLE:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_LEAVETABLE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_LEAVETABLE:bufferOut(buf)
    self.userID = buf:readInt()
    self.isOB   = buf:readChar()
end
--// **************************************************************
--// **************************************************************
wnet.Attr_Entry = {}
wnet.Attr_Entry.eAttrEntry_Null      = 0
wnet.Attr_Entry.eAttrEntry_Money     = 1                         --更新游戏豆
wnet.Attr_Entry.eAttrEntry_Score     = 2                         --更新积分
wnet.Attr_Entry.eAttrEntry_Status    = 3                        --更新状态
wnet.Attr_Entry.eAttrEntry_Win       = 4                           --更新赢局
wnet.Attr_Entry.eAttrEntry_Lose      = 5                          --更新输局
wnet.Attr_Entry.eAttrEntry_Draw      = 6                          --更新平局
wnet.Attr_Entry.eAttrEntry_Disc      = 7                          --更新断线
wnet.Attr_Entry.eAttrEntry_Train     = 8                         --更新练习币
wnet.Attr_Entry.eAtrrEntry_GameMoney = 9                     --类似于德州扑克更新小游戏内携带的游戏豆
wnet.Attr_Entry.eAttrEntry_Num       = 10

local stAttr = class("stAttr")
function stAttr:ctor()

end

function stAttr:bufferOut(buf)
    self.attrEntry = buf:readChar()
    self.attrValue = buf:readInt()
end

wnet.GC_GAMEUSER_UP = class("GC_GAMEUSER_UP", packBody)
function wnet.GC_GAMEUSER_UP:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_GAMEUSER_UP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_GAMEUSER_UP:bufferOut(buf)
    self.userID = buf:readInt()
    local len   = buf:readShort()
    self.attrList = {}
    for i = 1, len, 1 do
        local ti = stAttr.new()
        ti:bufferOut(buf)
        self.attrList[#self.attrList + 1] = ti
    end
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_CS_USERLOGIN_REQ = class("PL_PHONE_CS_USERLOGIN_REQ", packBody)
function wnet.PL_PHONE_CS_USERLOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_CS_USERLOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_CS_USERLOGIN_REQ:bufferIn(userid, passcode, mac, validate, loginMachineType)
    local buf = wnet.PL_PHONE_CS_USERLOGIN_REQ.super.bufferIn(self)
        buf:writeInt(userid)
            :writeStringUShort(passcode)
            :writeStringUShort(mac or "")
            :writeStringUShort(validate or "")
            :writeByte(loginMachineType or 0)
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_CS_GAMELIST_REQ = class("PL_PHONE_CS_GAMELIST_REQ", packBody)
function wnet.PL_PHONE_CS_GAMELIST_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_CS_GAMELIST_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_CS_GAMELIST_REQ:bufferIn(gameid)
    local buf = wnet.PL_PHONE_CS_GAMELIST_REQ.super.bufferIn(self)
    buf:writeShort(gameid)
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.CG_LOGIN_REQ = class("CG_LOGIN_REQ", packBody)
function wnet.CG_LOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.CG_LOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CG_LOGIN_REQ:bufferIn(roomid, passcode, mac)
    local buf = wnet.CG_LOGIN_REQ.super.bufferIn(self)
        buf:writeChar(roomid)
            :writeStringUShort(passcode)
            :writeStringUShort(mac or "")
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.CG_ENTERTABLE_REQ = class("CG_ENTERTABLE_REQ", packBody)
function wnet.CG_ENTERTABLE_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.CG_ENTERTABLE_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CG_ENTERTABLE_REQ:bufferIn(tableid, chairid, password)
    local buf = wnet.CG_ENTERTABLE_REQ.super.bufferIn(self)
    buf:writeChar(tableid)
        :writeChar(chairid)
        :writeStringUShort(password or "")
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.CG_HANDUP = class("CG_HANDUP", packBody)
function wnet.CG_HANDUP:ctor(code, uid, pnum, mapid, syncid)
    wnet.CG_HANDUP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CG_HANDUP:bufferIn()
    local buf = wnet.CG_HANDUP.super.bufferIn(self)
    return buf
end

wnet.GC_HANDUP = class("GC_HANDUP", packBody)
function wnet.GC_HANDUP:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_HANDUP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_HANDUP:bufferOut(buf)
    self.chairID = buf:readChar()
end
--// **************************************************************
--// **************************************************************
wnet.GC_STARTTIMER = class("GC_STARTTIMER", packBody)
function wnet.GC_STARTTIMER:ctor(code, uid, pnum, mapid, syncid)
    wnet.GC_STARTTIMER.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_STARTTIMER:bufferOut(buf)
    self.timeEvent = buf:readInt()
    self.timeSec   = buf:readInt()
    self.chairID   = buf:readChar()
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO = class("PL_PHONE_IOS_SINGLE_RECHARGEINFO", packBody)
function wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO:bufferOut(buf)
    self.productId    = buf:readStringUShort()
    self.productType  = buf:readInt() --// 1 金币 --// 2 钻石
    self.productPrice = buf:readFloat()
    self.productNum   = buf:readInt()
    --self.productIcon  = buf:readStringUShort()
    self.productExtra = buf:readInt()
end

wnet.PL_PHONE_IOS_RECHARGEINFO = class("PL_PHONE_IOS_RECHARGEINFO", packBody)
function wnet.PL_PHONE_IOS_RECHARGEINFO:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_IOS_RECHARGEINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_IOS_RECHARGEINFO:bufferOut(buf)
    self.iosRechargeInfo = {}
    local len = buf:readUShort()
    for i = 1, len do
        local info = wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO.new()
        info:bufferOut(buf)
        self.iosRechargeInfo[#self.iosRechargeInfo + 1] = info
    end
end

wnet.PL_PHONE_IOS_RECHARGEINFO_REQ = class("PL_PHONE_IOS_RECHARGEINFO_REQ", packBody)
function wnet.PL_PHONE_IOS_RECHARGEINFO_REQ:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_IOS_RECHARGEINFO_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_IOS_RECHARGEINFO_REQ:bufferIn(tableid, chairid, password)
    local buf = wnet.PL_PHONE_IOS_RECHARGEINFO_REQ.super.bufferIn(self)
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_IOS_RECHARGE = class("PL_PHONE_IOS_RECHARGE", packBody)
function wnet.PL_PHONE_IOS_RECHARGE:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_IOS_RECHARGE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_IOS_RECHARGE:bufferIn(userId, transActionId, recevieData, productId)
    local buf = wnet.PL_PHONE_IOS_RECHARGE.super.bufferIn(self)
    buf:writeInt(userId)
        :writeStringUShort(transActionId)
        :writeStringUShort(recevieData)
        :writeStringUShort(productId)
    return buf
end
--// **************************************************************
--// **************************************************************
wnet.PL_PHONE_IOS_RECHARGE_ACK = class("PL_PHONE_IOS_RECHARGE_ACK", packBody)
function wnet.PL_PHONE_IOS_RECHARGE_ACK:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_IOS_RECHARGE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_IOS_RECHARGE_ACK:bufferOut(buf)
    self.nRet              = buf:readInt()
    self.transactionId     = buf:readStringUShort()
    self.payType           = buf:readInt()
    self.rechargeNum       = buf:readInt()
    local gch              = buf:readInt()
    local gcl              = buf:readInt()
    self.totalGameCurrency = i64(gch, gcl)
    self.totalGoldCurrency = buf:readFloat()
end
--// **************************************************************
--// **************************************************************
wnet.stVipData = class("stVipData")
function wnet.stVipData:ctor()
end
function wnet.stVipData:bufferOut(buf)
    self.vipExp   = buf:readInt()
    self.vipBegin = buf:readInt()
    self.vipEnd   = buf:readInt()
    self.vipLevel = buf:readChar()
    self.vipUp    = buf:readInt()
end
--// **************************************************************
--// **************************************************************
wnet.SIGNIN_DAYAWARDINFO = class("SIGNIN_DAYAWARDINFO", packBody)
function wnet.SIGNIN_DAYAWARDINFO:ctor(code, uid, pnum, mapid, syncid)
    wnet.SIGNIN_DAYAWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.SIGNIN_DAYAWARDINFO:bufferOut(buf)
    self.day               = buf:readInt()
    self.odds              = buf:readInt()
    self.awardGameCurrency = buf:readInt()
    self.awardGoldCurrency = buf:readInt()
    self.awardIngore       = buf:readInt()
    self.awardVipDays      = buf:readInt()
end
wnet.SIGNIN_AWARDINFO = class("SIGNIN_AWARDINFO", packBody)
function wnet.SIGNIN_AWARDINFO:ctor(code, uid, pnum, mapid, syncid)
    wnet.SIGNIN_AWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.SIGNIN_AWARDINFO:bufferOut(buf)
    self.vipRate = buf:readInt()
    local size = buf:readShort()
    self.awardInfo = {}
    for i = 1, size do
        local tmp = wnet.SIGNIN_DAYAWARDINFO.new()
        tmp:bufferOut(buf)
        self.awardInfo[i] = tmp
    end
end
wnet.PL_PHONE_LC_INISIGNININFO = class("PL_PHONE_LC_INISIGNININFO", packBody)
function wnet.PL_PHONE_LC_INISIGNININFO:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_LC_INISIGNININFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
    self.signInAwardInfo = wnet.SIGNIN_AWARDINFO.new()
end
function wnet.PL_PHONE_LC_INISIGNININFO:bufferOut(buf)
    self.signInDay = buf:readInt()
    self.bSignIn = buf:readChar()
    self.signInAwardInfo:bufferOut(buf)
end
wnet.PL_PHONE_LC_SIGNIN = class("PL_PHONE_LC_SIGNIN", packBody)
function wnet.PL_PHONE_LC_SIGNIN:ctor(code, uid, pnum, mapid, syncid)
    wnet.PL_PHONE_LC_SIGNIN.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
    --self.vipData = wnet.stVipData.new()
end
function wnet.PL_PHONE_LC_SIGNIN:bufferOut(buf)
    self.signResult        = buf:readInt()
    self.awardDouble       = buf:readChar()
    local gch              = buf:readInt()
    local gcl              = buf:readInt()
    self.totalGameCurrency = i64(gch, gcl)
    self.totalGoldCurrency = buf:readFloat()
    --self.vipData:bufferOut(buf)
end