--
-- Author: Chen
-- Date: 2017-11-21 11:19:25
-- Brief: 
--
local BaseModel = require('models.BaseModel')
local Model = class("PlayModel", BaseModel)

local table_remove = table.remove

local GamePublic = pp.GamePublic
local MahjOp     = GamePublic.MahjOp
local band       = GamePublic.band

local KongLogic  = game:loadSource("models.KongLogic")

Model.schema = clone(BaseModel.schema)

--// 最大的座位号
Model.schema["maxChairID"] = {"number", 3}
Model.schema["bankerChairID"] = {"number", 0}

--// 是否是新的一轮
Model.schema["isNewRound"] = {"bool", true}

--// 手牌牌值
Model.schema["handTiles"]  = {"table", {[0] = {}, {}, {}, {}}}
--// 河牌牌值
Model.schema["riverTiles"] = {"table", {[0] = {}, {}, {}, {}}}
--// 吃牌牌值
Model.schema["flatTiles"]  = {"table", {[0] = {}, {}, {}, {}}}

--// 服务器传来的未经修改的值，只保存自己，用户杠牌检测
Model.schema["rawFlatTiles"] = {"table", {}}

--// 摸到的牌
Model.schema["drawTile"] = {"number", 0}

--// 用来标志是否是主动出牌，区分超时系统自动出牌
--// 若该值与服务器传来的出牌通知一样，则为玩家主动出牌
--// 否则为超时出牌
Model.schema["preDiscardTile"] = {"number", 0}

--// 吃牌区堆数
Model.schema["flatHeapCount"] = {"table", {}}

--// 可以操作的行为
Model.schema["canOpActions"] = {"table", false}

--// 服务器相关数据
Model.schema["op"]        = {"number", 0}
Model.schema["opTile"]    = {"number", 0}
Model.schema["opReqTime"] = {"number", 0}

--// 当前的操作行为
Model.schema["curOpAction"]  = {"number", 0}
Model.schema["curOpChairID"] = {"number", 0}
Model.schema["curOpTile"]    = {"number", 0}

--// 可以吃牌的数量
Model.schema["canChowAmount"] = {"number", 0}
--// 胡牌番型
Model.schema["mahjPoints"]    = {"table", {}}
--//
Model.schema["winChairID"] = {"number", 0}
--// 
Model.schema["results"] = {"table", {}}
function Model:ctor()
    self.super.ctor(self, Model.schema)

    --// 需要重写的set get函数
    local override = (function()
        
    end)()
end

-- /**
--  * 设置当前通知的操作行为
--  */
function Model:setNotifyOpAction(op, tile)
    self._curOpTile = tile
    if band(MahjOp.DISCARD, op) ~= 0 then
        self._curOpAction = MahjOp.DISCARD
    elseif band(MahjOp.GIVEUP, op) ~= 0 then
        self._curOpAction = MahjOp.GIVEUP
    elseif band(MahjOp.CHOW, op) ~= 0 then
        self._curOpAction = MahjOp.CHOW
    elseif band(MahjOp.PONG, op) ~= 0 then
        self._curOpAction = MahjOp.PONG
    elseif band(MahjOp.KONG, op) ~= 0 then
        self._curOpAction = MahjOp.KONG
    elseif band(MahjOp.WIN, op) ~= 0 then
        self._curOpAction = MahjOp.WIN
    end 
end

-- /**
--  * 是否可以出牌
--  */
function Model:canPlay()
    return self._canOpActions[MahjOp.DISCARD]
end

-- /**
--  * 清空可操作action
--  */
function Model:clearCanActions()
    self._canOpActions = {}
end

-- /**
--  * 设置可以操作的行为 过 吃 碰 杠 听 胡，用来显示按钮
--  */
function Model:setCanOpActions(op, tile)
    self._op     = op
    self._opTile = tile

    self._canOpActions = {}
    if band(MahjOp.DISCARD, op) ~= 0 then
        self._canOpActions[MahjOp.DISCARD] = true
    end
    if band(MahjOp.GIVEUP, op) ~= 0 then
        self._canOpActions[MahjOp.GIVEUP] = true
    end
    if band(MahjOp.CHOW, op) ~= 0 then
        self._canOpActions[MahjOp.CHOW] = true
        self._canChowAmount = 0
        if band(MahjOp.LEFTCHOW, op) ~= 0 then
            self._canOpActions[MahjOp.LEFTCHOW] = true
            self._canChowAmount = self._canChowAmount + 1
        end
        if band(MahjOp.MIDCHOW, op) ~= 0 then
            self._canOpActions[MahjOp.MIDCHOW] = true
            self._canChowAmount = self._canChowAmount + 1
        end
        if band(MahjOp.RIGHTCHOW, op) ~= 0 then
            self._canOpActions[MahjOp.RIGHTCHOW] = true
            self._canChowAmount = self._canChowAmount + 1
        end
    end
    if band(MahjOp.PONG, op) ~= 0 then
        self._canOpActions[MahjOp.PONG] = true
    end
    if band(MahjOp.KONG, op) ~= 0 then
        self._canOpActions[MahjOp.KONG] = true
    end 
    if band(MahjOp.WIN, op) ~= 0 then
        self._canOpActions[MahjOp.WIN] = true
    end 
end

-- /**
--  * 获取吃的具体op
--  * @param tag 哪种吃标记 0 单, 1 左, 2 中, 3 右
--  */
function Model:checkChowOp(tag)
    if self._canChowAmount > 1 then
        if tag == 1 then
            return band(MahjOp.LEFTCHOW, self._op)
        elseif tag == 2 then
            return band(MahjOp.MIDCHOW, self._op)
        else
            return band(MahjOp.RIGHTCHOW, self._op)
        end
    else
        return band(MahjOp.CHOW, self._op)
    end
end

-- /**
--  * 设置吃牌区牌堆数
--  */
function Model:setFlatHeapCountByChairID(chairID, count)
    self._flatHeapCount[chairID] = count
end

-- /**
--  * 获取吃牌区牌堆数
--  */
function Model:getFlatHeapCountByChairID(chairID)
    return self._flatHeapCount[chairID] or 0
end

-- /**
--  * 设置，获取玩家手牌
--  * @param  座位号
--  */
function Model:setHandTilesByChairID(chairID, tiles)
    self._handTiles[chairID] = tiles
end

function Model:getHandTilesByChairID(chairID)
    return self._handTiles[chairID]
end

-- /**
--  * 设置，获取玩家河牌
--  * @param  座位号
--  */
function Model:setRiverTilesByChairID(chairID, tiles)
    self._riverTiles[chairID] = tiles
end

function Model:getRiverTilesByChairID(chairID)
    return self._riverTiles[chairID]
end

-- /**
--  * 设置，获取玩家吃牌
--  * @param  座位号
--  */
function Model:setFlatTilesByChairID(chairID, tiles)
    self._flatTiles[chairID] = tiles
end

function Model:getFlatTilesByChairID(chairID)
    return self._flatTiles[chairID]
end

-- /**
--  * 保存服务器的原始数据
--  */
function Model:setRawFlatTiles(tiles)
    self._rawFlatTiles = tiles
end

function Model:getRawFlatTiles(tiles)
    return self._rawFlatTiles
end

-- /**
--  * 从手牌中删除打出的牌,self
--  */
function Model:removeTileFromHand(idx)
    table_remove(self._handTiles[0], idx)
end

-- /**
--  * 设置玩家结果
--  */
function Model:setResults(chairID, result)
    self._results[chairID] = result
end

--// 带参数
function Model:sortAfterPlayWithTiles(drawTile, handTiles)
    local idx = 1
    local flag = false
    for i = 1, #handTiles do
        local tile = handTiles[i]
        if tile > drawTile then
            flag = true
            idx = i
            break
        end
    end

    if not flag then
        idx = #handTiles + 1
    end

    
    cclog.warn(handTiles, "<==== handTiles")
    cclog.warn("<==== idx = " ..idx)
    cclog.warn("<==== drawTile = " ..drawTile)
    return idx, not flag
end

-- /**
--  * 出牌后把摸到的牌，放到合适的位置，如何摸到的牌被打掉，则不会调用此函数
--  * @return number 插入位置的索引值, 
--  * @return bool 是否是最后
--  */
function Model:sortAfterPlay()

    --// bfmj
    if not self._isNothingFixType then --// 有定缺的牌
        return self:sortAfterPlayBFMJ()
    end
    --// bfmj

    return self:sortAfterPlayWithTiles(self._drawTile, self._handTiles[0])

    -- 为了bfmj代码重复，把下面的类容提炼为一个函数 sortAfterPlayWithTiles

    -- local drawTile  = self._drawTile
    -- local handTiles = self._handTiles[0]

    -- local idx = 1
    -- local flag = false
    -- for i = 1, #handTiles do
    --     local tile = handTiles[i]
    --     if tile > drawTile then
    --         flag = true
    --         idx = i
    --         break
    --     end
    -- end

    -- if not flag then
    --     idx = #handTiles + 1
    -- end

    -- return idx, not flag 
end

-- /**
--  * 获取杠牌的具体操作
--  * @return number tile  number op
--  */
function Model:checkKongTileAndOp()
    local tile = KongLogic:checkKongTile({
        op        = self._op, 
        opTile    = self._opTile,
        handTiles = self._handTiles[0],
        flatTiles = self._rawFlatTiles,
        drawTile  = self._drawTile}
    )
    cclog.debug("kong tile = " ..tile)

    if GamePublic.isValidTile(tile) then
        local op = KongLogic:checkKongOp({
            tile      = tile, 
            handTiles = self._handTiles[0],
            drawTile  = self._drawTile}
        )
        cclog.debug("kong op = " ..op)

        if op > 0 then
            return tile, band(MahjOp.KONG, op)
        end
    end

    return -1, -1
end

-- /**
--  * 检测胡牌番型
--  */
function Model:checkHuMahjPoints()
    
end

----------// bfmj start
--// 定缺
Model.schema["isNothingFixType"] = {"bool", true}
Model.schema["myFixType"]        = {"number", -1}
Model.schema["fixTypes"]         = {"table", {}}

--// 是否打光定缺的牌
function Model:checkNothingFixType()
    local handTiles = self._handTiles[0]
    local flag = true
    for i = 1, #handTiles do
        if self:isFixType(handTiles[i]) then
            flag = false
            break
        end
    end
    self._isNothingFixType = flag
end

--// 设置对应座位号的定缺类型
function Model:setFixType(chairID, fixType)
    self._fixTypes[chairID] = fixType
end

--// 获取tile的类型，万 筒 条
function Model:getTileType(tile)
    if tile < 10 then
        return 0
    elseif tile < 20 then
        return 1
    else
        return 2
    end
end

--// tile 是否是定缺的类型
function Model:isFixType(tile)
    return self._myFixType == self:getTileType(tile)
end

-- /**
--  * 出牌后把摸到的牌，放到合适的位置，能调用到这个函数的前提，定缺类型的牌没有打完，
--  * @return number 插入位置的索引值, 
--  * @return bool 是否是最后
--  */
function Model:sortAfterPlayBFMJ()
    cclog.warn("<===== sortAfterPlayBFMJ")
    local drawTile  = self._drawTile
    local handTiles = self._handTiles[0]

    local unFixTiles       = {}
    local fixTiles         = {} --// 保存定缺类型的牌值
    for i = 1, #handTiles do
        local tile = handTiles[i]
        if self:isFixType(tile) then
            fixTiles[#fixTiles + 1] = tile
        else
            unFixTiles[#unFixTiles + 1] = tile
        end
    end

    local idx, isend
    if self:isFixType(drawTile) then 
        idx, isend = self:sortAfterPlayWithTiles(drawTile, fixTiles) 
        idx = #unFixTiles + idx
    else
        idx, isend = self:sortAfterPlayWithTiles(drawTile, unFixTiles)
        --// 定缺的牌未打完，则isend = false
        if #fixTiles ~= 0 then
            isend = false
        end
    end

    return idx, isend
end

----------// bfmj end

return Model