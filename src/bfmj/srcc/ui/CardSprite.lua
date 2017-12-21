--
-- Author: Chen
-- Date: 2017-11-21 11:47:33
-- Brief: 
--


local pp = pp

local CardType_Hand  = pp.CardType.HAND
local CardType_River = pp.CardType.RIVER
local CardType_Flat  = pp.CardType.FLAT

local PlayModel = pp.PlayModel

local spriteFrameCache = cc.SpriteFrameCache:getInstance()

local function tile_res(chairID, tile)
    if chairID == 0 then
        return "mj_" ..tile .."_b.png"
    elseif chairID == 1 then
        return "mj_" ..tile .."_s_r.png"
    elseif chairID == 2 then
        return "mj_" ..tile .."_s.png"
    else
        return "mj_" ..tile .."_s_l.png"
    end
end

--// 暗牌手牌资源
local function hand_card_an_res(chairID)
    if chairID == 0 then
        return "mj_back_b_lie.png"
    elseif chairID == 1 then
        return "mj_back_s_r_stand.png"
    elseif chairID == 2 then
        return "mj_back_s_stand.png"
    else
        return "mj_back_s_l_stand.png"
    end
end

--// 明牌手牌资源
local function hand_card_ming_res(chairID)
    if chairID == 0 then
        return "mj_back_b.png"
    elseif chairID == 1 then
        return "mj_back_s_r.png"
    elseif chairID == 2 then
        return "mj_back_s.png"
    else
        return "mj_back_s_l.png"
    end
end

--// 
local function flat_card_an_res(chairID)
    if chairID == 0 then
        return "mj_back_s_lie.png"
    elseif chairID == 1 then
        return "mj_back_s_r_lie.png"
    elseif chairID == 2 then
        return "mj_back_s_lie.png"
    else
        return "mj_back_s_l_lie.png"
    end
end

local CardSprite = class("CardSprite", function()
    return cc.Sprite:create()
end)

function CardSprite:ctor(cardType, chairID, tile)
    self._chairID = chairID
    self._cardType = cardType
    self.isGray   = false
    self.canTouch = true


    if cardType == CardType_Hand then
        self:createHand(chairID, tile)
    elseif cardType == CardType_River then
        self:createRiver(chairID, tile)
    elseif cardType == CardType_Flat then
        self:createFlat(chairID, tile)
    end

    self.tile   = tile
    self.fixed  = cc.p(0, 0) --// 所属位置
    self.idx    = 1 --// 在数组中的索引值
    self.isDraw = false --// 是否是刚摸到的牌
end

--// 牌值精灵的偏移值
local OFFSET_TILE = {
    [0] = cc.p(0, 0),
    [1] = cc.p(26, 31),
    [2] = cc.p(21.5, 36),
    [3] = cc.p(34, 30),
}

-- /**
--  * 目前只用于出牌后的展示
--  */
function CardSprite:setTile(tile)
    if self._cardType == CardType_Hand then
        local tileRes = tile_res(0, tile)
        local frame = spriteFrameCache:getSpriteFrame(tileRes)
        if not frame then
            cclog.fatal("invalid tile = " ..tile)
            return
        end
        self:setSpriteFrame(frame)
    end
end

-- /**
--  * 创建手牌
--  */
function CardSprite:createHand(chairID, tile)
    
    if chairID == 0 then
        local tileRes = tile_res(chairID, tile)
        local frame = spriteFrameCache:getSpriteFrame(tileRes)
        if not frame then
            cclog.fatal("invalid tile = " ..tile)
            return
        end
        self:setSpriteFrame(frame)
        --// bfmj
        if not PlayModel:getIsNothingFixType() then --// 定缺没打完
            if PlayModel:isFixType(tile) then
                self:setGray()
                self.canTouch = true
            else
                self.canTouch = false
            end
        else
            self.canTouch = true
        end
        --// bfmj
    else
        if tile == 0 then
            local cardRes = hand_card_an_res(chairID)
            local frame = spriteFrameCache:getSpriteFrame(cardRes)
            if not frame then
                cclog.fatal("invalid card res = " ..cardRes)
                return
            end
            self:setSpriteFrame(frame)
        elseif tile > 0 then
            local cardRes = hand_card_ming_res(chairID)
            local frame = spriteFrameCache:getSpriteFrame(cardRes)
            if not frame then
                cclog.fatal("invalid card res = " ..cardRes)
                return
            end
            self:setSpriteFrame(frame)

            --// tile
            local tileRes = tile_res(chairID, tile)
            local frame = spriteFrameCache:getSpriteFrame(tileRes)
            if not frame then
                cclog.fatal("invalid tile = " ..tile)
                return
            end

            local spTile = cc.Sprite:createWithSpriteFrame(frame)
                :pos(OFFSET_TILE[chairID])
                :addTo(self, 1)
        end
    end
end

-- /**
--  * 创建河牌
--  */
function CardSprite:createRiver(chairID, tile)
    if chairID == 0 then
        self:createHand(2, tile)
    else
        self:createHand(chairID, tile)
    end
end

-- /**
--  * 创建吃牌
--  */
function CardSprite:createFlat(chairID, tile)
    if tile == 0 then
        local cardRes = flat_card_an_res(chairID)
        local frame = spriteFrameCache:getSpriteFrame(cardRes)
        if not frame then
            cclog.fatal("invalid card res = " ..cardRes)
            return
        end
        self:setSpriteFrame(frame)
    elseif tile > 0 then
        if chairID == 0 then
            self:createHand(2, tile)
        else
            self:createHand(chairID, tile)
        end
    end
end

--// bfmj 置灰
function CardSprite:setGray()
    self.isGray   = true

    self:setColor(cc.c3b(0x9F, 0x9F, 0x9F))
end


return CardSprite