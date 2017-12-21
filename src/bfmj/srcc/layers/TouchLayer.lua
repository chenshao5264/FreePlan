--
-- Author: Chen
-- Date: 2017-11-21 16:18:46
-- Brief: 
--
local Layer = class("FunctionLayer", function()
    return cc.Layer:create()
end)

local pp = pp
local PlayModel = pp.PlayModel
local AudioHelper = pp.AudioHelper


local CARD_WIDTH          = 71
local CARD_SELECTED_SCALE = 1.2
local ADJUEST_X           = (CARD_WIDTH * CARD_SELECTED_SCALE - CARD_WIDTH) / 2
local OFFSET_HEIGHT       = 40

function Layer:ctor()
    self:enableNodeEvents()

    local cardRect = cc.rect()

    local rectContainsPoint = cc.rectContainsPoint

    local canDrag = false
    local curCard  = nil
    local lastCard = nil
    local needPlay = false

    --// 重置上一张触摸牌的状态
    local function reset_lastcard(card)
        if card then
            card.isDraging = false
            card.needPlay = false
            card:setScale(1.0)
            card:setPosition(card.fixed)
            card:setLocalZOrder(50)
        end
    end

    --// 设置当前触摸牌的状态
    local function selected_card(card)
        cclog.debug("tile = " ..card.tile)
        card:setPositionY(card.fixed.y + OFFSET_HEIGHT)
        card:setScale(CARD_SELECTED_SCALE)
        card:setLocalZOrder(100)
        curCard = card

        AudioHelper:playClickCard()
    end

    --// 触摸牌后调整坐标
    local function adjust_cards()
        local touchCards = self:getTouchCards()

        local factor = -1
        for i = 1, #touchCards do
            local card = touchCards[i]
            if card then
                card:setPositionX(card.fixed.x)
                if card == curCard then
                    factor = 1
                else
                    card:setPositionX(card.fixed.x + factor * ADJUEST_X)
                end
            end
        end
    end

    --// 还原所有牌的坐标
    local function reset_cards(touchCards)
        for i = 1, #touchCards do
            local card = touchCards[i]
            if card then
                card:setPosition(card.fixed)
                card:setScale(1.0)
            end
        end
    end

    --// 出牌
    local function play_card(card)


        local tile = card.tile
        --// 出牌预处理
        self._layMahj:playCard(card)
        PlayModel:setPreDiscardTile(tile)
        gg.RequestManager:reqDiscard(tile)
    end
    
    local function onTouchBegan(touch, event)

        if not self:canTouch() then
            return false
        end

        reset_lastcard(lastCard)

        --// 手牌
        local touchCards = self:getTouchCards()
        for i = 1, #touchCards do
            local card = touchCards[i]
            if card and card.canTouch and rectContainsPoint(card:getBoundingBox(), cc.p(touch:getLocation())) then
                
                if not card.isDraw then
                    selected_card(card)
                    adjust_cards()
                else
                    reset_cards(touchCards, card)
                    selected_card(card)
                end
                
                return true
            end
        end

        reset_cards(touchCards)

        return true
    end
    
    local function onTouchMoved(touch, event)

        local touchLocation = touch:getLocation()
        if PlayModel:canPlay() then
            --// 处理拖动
            if curCard then
                if not curCard.isDraging then
                    if touchLocation.y > curCard:getPositionY() then
                        curCard.isDraging = true
                        curCard.needPlay = true
                    end
                end
                if curCard.isDraging then
                    if touchLocation.y > curCard.fixed.y + OFFSET_HEIGHT then
                        curCard:setPosition(cc.p(touchLocation))
                    else
                        --// y小于某个值，还原
                        curCard.needPlay = false
                        curCard.isDraging = false
                        curCard:setPositionX(curCard.fixed.x)
                    end
                end
            end
        end

        local flag = false
        local touchCards = self:getTouchCards()
        for i = 1, #touchCards do
            local card = touchCards[i]
            if card and card.canTouch and rectContainsPoint(card:getBoundingBox(), cc.p(touch:getLocation())) then
                if card ~= curCard then
                    reset_lastcard(curCard)
                    
                    if not card.isDraw then
                        selected_card(card)
                        adjust_cards()
                    else
                        reset_cards(touchCards)
                        selected_card(card)
                    end
                    lastCard = nil
                end
                flag = true
            end
        end
        if not flag then
            reset_lastcard(curCard)
            reset_cards(touchCards)
            curCard = nil
        end
    end
    
    local function onTouchEnded(touch, event)
        if PlayModel:canPlay() then
            if curCard and lastCard == curCard then
                play_card(curCard)
                curCard = nil
            end

            if curCard and curCard.needPlay then
                play_card(curCard)
                curCard = nil
            end
        end

        if curCard then
            curCard:setLocalZOrder(50)
        end
        lastCard = curCard
        curCard = nil
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Layer:getTouchCards()
    return self._layMahj._spHandCards[0]
end

function Layer:canTouch()
    return not self._layMahj._isActionPlaying
end

function Layer:setMahjLayer(lay)
    self._layMahj = lay
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")
end

return Layer