--
-- Author: Chen
-- Date: 2017-11-20 19:35:52
-- Brief: 
--

local packBody = require "net.protocol.packBody"

local gnet = {}

----------------------- 麻将 常规 Start -----------------------
--//
gnet.SC_BET = class("SC_BET", packBody)
function gnet.SC_BET:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_BET:bufferOut(buf)
    self.bet = buf:readInt()
end

--//
gnet.SC_MAHJ_DICE = class("SC_MAHJ_DICE", packBody)
function gnet.SC_MAHJ_DICE:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_DICE:bufferOut(buf)
    self.banker = buf:readChar()
    self.bet    = buf:readInt()
    self.dices  = {}
    for i = 1, 4 do
        self.dices[#self.dices + 1] = buf:readChar()
    end
end

--//
gnet.SC_MAHJ_OP_REQ = class("SC_MAHJ_OP_REQ", packBody)
function gnet.SC_MAHJ_OP_REQ:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_OP_REQ:bufferOut(buf)
    self.tile    = buf:readChar()
    self.op      = buf:readInt()
    self.reqTime = buf:readInt()
end

--//
gnet.SC_MAHJ_OP = class("SC_MAHJ_OP", packBody)
function gnet.SC_MAHJ_OP:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_OP:bufferOut(buf)
    self.chairID = buf:readChar()
    self.tile    = buf:readChar()
    self.bShow   = buf:readBool()
    self.op      = buf:readInt()
end

--//
gnet.SC_MAHJ_DRAWN = class("SC_MAHJ_DRAWN", packBody)
function gnet.SC_MAHJ_DRAWN:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_DRAWN:bufferOut(buf)
    self.chairID = buf:readChar()
    self.tile    = buf:readChar()
    self.isBack  = buf:readChar()
    self.wallNum = buf:readInt()
end

--//
gnet.SC_MAHJ_TITE_UP = class("SC_MAHJ_TITE_UP", packBody)
function gnet.SC_MAHJ_TITE_UP:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_TITE_UP:bufferOut(buf)
    self.chairID = buf:readChar()
    self.handTiles = {}
    for i = 1, buf:readShort(), 1 do 
        self.handTiles[#self.handTiles + 1] = buf:readChar()
    end
    self.flatTiles = {}
    local len = buf:readShort()
    for i = 1, len, 1 do 
        self.flatTiles[#self.flatTiles + 1] = buf:readChar()
    end
    self.riverTiles = {}
    for i = 1, buf:readShort(), 1 do 
        self.riverTiles[#self.riverTiles + 1] = buf:readChar()
    end
    self.FixType = buf:readInt()
end



--//
local stResult = class("stResult", packBody)
function stResult:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function stResult:bufferOut(buf)
    self.chair   = buf:readChar() --// 座位号
    self.score   = buf:readInt()
    self.points  = buf:readInt() --// 番型
    self.get     = buf:readInt()
    self.selfNum = buf:readInt()
    self.huNum   = buf:readInt()
end

local stCurRecord = class("stCurRecord", packBody)
function stCurRecord:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function stCurRecord:bufferOut(buf)
    self.chair   = buf:readChar()
    self.vRecord = {}
    for i = 1, buf:readShort() do
        self.vRecord[#self.vRecord + 1] = buf:readInt()
    end
end

gnet.SC_MAHJ_RESULT = class("SC_MAHJ_RESULT", packBody)
function gnet.SC_MAHJ_DICE:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_RESULT:bufferOut(buf)
    self.endType = buf:readChar()
    self.vecResults = {}
    for i = 1, buf:readShort() do
        local tmp = stResult.new()
        tmp:bufferOut(buf)
        self.vecResults[#self.vecResults + 1] = tmp
    end
    --// bfmj专用，记录游戏对局
    self.vecCurRecord = {}
    for i = 1, buf:readShort() do
        local tmp = stCurRecord.new()
        tmp:bufferOut(buf)
        self.vecCurRecord[#self.vecCurRecord + 1] = tmp
    end
end

--//
gnet.SC_MAHJ_BAO = class("SC_MAHJ_BAO", packBody)
function gnet.SC_MAHJ_BAO:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_BAO:bufferOut(buf)
    self.bao     = buf:readChar()
    self.pos     = buf:readInt()
    self.baoNum  = buf:readInt()
    self.wallNum = buf:readInt()
end

--//
gnet.SC_MAHJ_INITDATA = class("SC_MAHJ_INITDATA", packBody)
function gnet.SC_MAHJ_INITDATA:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_INITDATA:bufferOut(buf)
    self.bet    = buf:readInt()
    self.banker = buf:readChar()
    self.dices  = {}
    for i = 1, buf:readShort() do
        self.dices[#self.dices + 1] = buf:readChar()
    end

    self.wallChair = buf:readChar()
    self.wallPos   = buf:readInt()
    self.pos       = buf:readInt()
    self.wallNum   = buf:readInt()
    self.huType    = buf:readBool()

    self.tilesData = {}
    for i = 1, buf:readShort() do
        local tmp = gnet.SC_MAHJ_TITE_UP.new()
        tmp:bufferOut(buf)
        self.tilesData[#self.tilesData + 1] = tmp
    end
    --[[
    self.vecWinTile = {}
    for i = 1, buf:readShort() do
        local tmp = self.SC_HU_TILE.new()
        tmp:bufferOut(buf)
        self.vecWinTile[#self.vecWinTile + 1] = tmp
    end
    self.mapWinTile = {}
    for i = 1, buf:readShort() do
        local tmp = {}
        tmp.key = buf:readChar()
        
        tmp.value = {}
        for i = 1, buf:readShort() do
            local tmp0 = self.WINTILE_SHOW_INFO.new()
            tmp0:bufferOut(buf)
            tmp.value[#tmp.value + 1] = tmp0
        end
        self.mapWinTile[tmp.key] = tmp.value
    end
    self.vecNum = {}
    for i = 1, buf:readShort() do
        local tmp = self.SC_MAHJ_HU_RESULT.new()
        tmp:bufferOut(buf)
        self.vecNum[#self.vecNum + 1] = self.vecNum
    end
    --]]
end

--//
gnet.CS_MAHJ_OP_ACK = class("CS_MAHJ_OP_ACK", packBody)
function gnet.CS_MAHJ_OP_ACK:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.CS_MAHJ_OP_ACK:bufferIn(tile, op, reqTime)
    local buf = self.super.bufferIn(self)
    buf:writeChar(tile)
       :writeInt(op)
       :writeInt(reqTime)
    return buf
end

----------------------- 麻将 常规 End -----------------------


--// bfmj
gnet.SC_MAHJ_FIX = class("SC_MAHJ_FIX", packBody)
function gnet.SC_MAHJ_FIX:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_FIX:bufferOut(tile, op, reqTime)
end

gnet.SC_MAHJ_FIX_END = class("SC_MAHJ_FIX_END", packBody)
function gnet.SC_MAHJ_FIX_END:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_FIX_END:bufferOut(tile, op, reqTime)
end

--// 发送定张和收到定张
gnet.CS_FIXTYPE_DATA = class("CS_FIXTYPE_DATA", packBody)
function gnet.CS_FIXTYPE_DATA:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.CS_FIXTYPE_DATA:bufferOut(buf)
    self.chairID = buf:readChar()
    self.type    = buf:readInt()
end
function gnet.CS_FIXTYPE_DATA:bufferIn(chairID, type)
    local buf = self.super.bufferIn(self)
    buf:writeChar(chairID)
       :writeInt(type)
    return buf
end

gnet.SC_MAHJ_FIX_MOVE = class("SC_MAHJ_FIX_MOVE", packBody)
function gnet.SC_MAHJ_FIX_MOVE:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_FIX_MOVE:bufferOut(buf)
    self.chairID = buf:readChar()
    self.handTiles = {}
    for i = 1, buf:readShort(), 1 do 
        self.handTiles[#self.handTiles + 1] = buf:readChar()
    end
    self.flatTiles = {}
    for i = 1, buf:readShort(), 1 do 
        self.flatTiles[#self.flatTiles + 1] = buf:readChar()
    end
    self.riverTiles = {}
    for i = 1, buf:readShort(), 1 do 
        self.riverTiles[#self.riverTiles + 1] = buf:readChar()
    end
    self.FixType = buf:readInt()
end

gnet.SC_MAHJ_CALC_RESULT = class("SC_MAHJ_CALC_RESULT", packBody)
function gnet.SC_MAHJ_CALC_RESULT:ctor(code, uid, pnum, mapid, syncid)
    self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function gnet.SC_MAHJ_CALC_RESULT:bufferOut(buf)
    self.chairID     = buf:readChar()   --// 赢家座位号
    self.bKong       = buf:readUByte()  --// 0:胡牌;1:刮风;2:下雨
    self.scores      = buf:readInt()    --// 玩家输赢分数(客户端需要根据输家个数计算赢家最终分数)
    self.chairIdList = {}               --// 输家列表
    for i = 1, buf:readShort() do
        self.chairIdList[#self.chairIdList + 1] = buf:readChar()
    end
end


return gnet