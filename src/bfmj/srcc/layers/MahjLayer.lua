--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--
local Layer = class("MahjLayer", function()
    return cc.Layer:create()
end)

local table_remove = table.remove
 
local gg = gg
local pp = pp

local PlayModel   = pp.PlayModel
local MahjOp      = pp.GamePublic.MahjOp

local AudioHelper = pp.AudioHelper

local Player = gg.Player

local game = game
local CardSprite   = game:loadSource("ui.CardSprite")
local FlatHeapNode = game:loadSource("ui.FlatHeapNode")


local PADDING_LEFT_HAND     = pp.PADDING_LEFT_HAND
local PADDING_BOTTOM_HAND   = pp.PADDING_BOTTOM_HAND
local GRAP_HAND_CARD        = pp.GRAP_HAND_CARD
local PADDING_LEFT_RIVER    = pp.PADDING_LEFT_RIVER
local PADDING_BOTTOM_RIVER  = pp.PADDING_BOTTOM_RIVER
local GRAP_RIVER_CARD       = pp.GRAP_RIVER_CARD
local GRAP_RIVER_LINE       = pp.GRAP_RIVER_LINE
local PADDING_LEFT_FLAT     = pp.PADDING_LEFT_FLAT
local GRAP_FLAT_HEAP        = pp.GRAP_FLAT_HEAP
local RIVER_EACH_LINE_COUNT = pp.RIVER_EACH_LINE_COUNT
local CardType_River        = pp.CardType.RIVER
local CardType_Hand         = pp.CardType.HAND

function Layer:ctor()
    self:enableNodeEvents()

    self._spHandCards  = {[0] = {}, {}, {}, {}}
    self._spRiverCards = {[0] = {}, {}, {}, {}}
    self._spFlatHeaps  = {[0] = {}, {}, {}, {}}
    self._spDrawCard   = nil --// 摸到的牌,用于所有人

    self._spPlayCard = nil --// 当前的出牌精灵

    self._cardIndexMapPosition = {} --// 牌索引值映射到坐标，只用于自己手牌

    self._isActionPlaying = false --// 是否正在播放动作，播放动作时，屏蔽触摸
end

-- /**
--  * 根据chairID删除已存在的牌精灵
--  */
function Layer:removeHandCards(chairID)
    local spCards = self._spHandCards[chairID]
    if not spCards then
        return
    end

    for i = 1, #spCards do
        local card = spCards[i]
        card:removeSelf()
    end

    self._spHandCards[chairID] = {}
end

-- /**
--  * 删除河牌
--  */
function Layer:removeRiverCards(chairID)
    local spCards = self._spRiverCards[chairID]
    if not spCards then
        return
    end

    for i = 1, #spCards do
        local card = spCards[i]
        card:removeSelf()
    end

    self._spRiverCards[chairID] = {}
end

-- /**
--  * 删除PlayCardSprite
--  */
function Layer:removePlayCard()
    if not self._spPlayCard then
        return
    end
    self._spPlayCard:removeSelf()
    self._spPlayCard = nil
end

-- /**
--  * 出牌动画
--  */
function Layer:playDiscard(chairID, playCard)
    local index = #self._spRiverCards[chairID] + 1

    local k, fixed = self:getRiverCardPositionByIndex(chairID, index)

    local curPos = cc.p(playCard:getPosition())

    --// 删除手牌创建河牌
     local spCard = CardSprite.new(CardType_River, chairID, playCard.tile)
        :pos(curPos)
        :addTo(self)
    self._spPlayCard = spCard
    playCard:removeSelf()
    
    local tmpZOrder
    local finalZOrder
    local ctrlPoint 
    if chairID == 0 then
        tmpZOrder   = 100
        finalZOrder = 20 - k
        ctrlPoint   = cc.p(curPos.x, fixed.y)
    elseif chairID == 1 then
        tmpZOrder   = 1
        finalZOrder = 50 - k
        ctrlPoint   = cc.p(fixed.x, curPos.y)
    elseif chairID == 2 then
        tmpZOrder   = 1
        finalZOrder = 50 - index
        ctrlPoint   = cc.p(curPos.x, fixed.y)
    else
        tmpZOrder   = 100
        finalZOrder = index
        ctrlPoint   = cc.p(fixed.x, curPos.y)
    end

    local bezierTo = cc.BezierTo:create(GOLD_TIME, {
        curPos,
        ctrlPoint,
        fixed
    })
    --// 动画过程中，调节卡牌层级，优化显示
    cc.CallFuncSequence.new(spCard, 
        function()
            spCard:setLocalZOrder(tmpZOrder)
            if self._playCardNext then
                self._playCardNext:next()
            end
        end, 
        cc.EaseSineOut:create(bezierTo),
        function()
            spCard:setLocalZOrder(finalZOrder)

            --// 光标
            local csorPos = fixed
            if chairID == 0 then
                csorPos.y = csorPos.y + 20
            elseif chairID == 1 then
                csorPos.y = csorPos.y + 20
            elseif chairID == 2 then
                csorPos.y = csorPos.y + 20
            elseif chairID == 3 then
                csorPos.y = csorPos.y + 20
            end
            self:showPlayCursor(csorPos)
        end
    ):start()   


end

-- /**
--  * 吃碰杠后，重新排序动画
--  */
function Layer:playSortAfterCPK()
    local flatCount   = PlayModel:getFlatHeapCountByChairID(0)
    flatCount         = flatCount + 1 --// 用来动画预处理
    local leftPadding = PADDING_LEFT_HAND[0]
    --//local leftPadding = leftPadding + flatCount * GRAP_FLAT_HEAP[chairID]
    --// 吃牌区有牌时微调坐标，以防有4组吃牌，手牌超出屏幕
    if flatCount > 0 then
        leftPadding = leftPadding + flatCount * GRAP_FLAT_HEAP[0]
    end

    local bottomPadding = PADDING_BOTTOM_HAND[0]
    local grap          = GRAP_HAND_CARD[0]


    local handCards = self._spHandCards[0]

    for i = 1, #handCards do
        local fixed = cc.p(leftPadding + grap * (i - 1), bottomPadding)
        local card = handCards[i]
        card:stopAllActions()
        card:runAction(cc.MoveTo:create(GOLD_QTR_TIME, fixed))
    end

    -- --// 执行吃碰杠后，手牌重排动画
    cc.ScheduleManager:performWithDelay(self, function()
        self._opCPKNext:next()
    end, GOLD_QTR_TIME)
end

-- /**
--  * 摸牌出牌之后，重新排序动画
--  * @param playCard 打出的牌
--  */
function Layer:playSortAfterPlayWithDraw(playCard)
    if playCard == self._spDrawCard then
        --// 等待动画执行完毕，再重绘UI
        cc.ScheduleManager:performWithDelay(self, function()
            if self._playCardNext then
                self._playCardNext:next()
            end
        end, 0.9)
        return
    end

    local idx, isend = PlayModel:sortAfterPlay() --// idx 摸到的牌插入的位置
    cclog.debug("idx = " ..idx)
    

    local handCards = self._spHandCards[0]
    --// 手牌位置调整
    local cidx = 1
    for i = 1, #handCards do
        local card = handCards[i]
        if i == idx then
            cidx = cidx + 1
        end
        if not card.isDraw then
            local act = cc.MoveTo:create(0.3, self._cardIndexMapPosition[cidx])
            card:stopAllActions()
            card:runAction(act)
        end
        cidx = cidx + 1
    end

    local drawCard = self._spDrawCard
    if not drawCard then
        cclog.fatal("drawCard is nil!")
        return
    end

    --// 摸到的牌排在最右边
    if isend then
        local act = cc.MoveTo:create(0.3, cc.p(self._cardIndexMapPosition[idx].x, drawCard.fixed.y))
        
        cc.CallFuncSequence.new(drawCard, 
            act,
            cc.DelayTime:create(0.9), --// 保持一样的时间
            function()
                if self._playCardNext then
                    self._playCardNext:next()
                end
            end
        ):start()
    else
        local cardHeight = drawCard:getContentSize().height
        local act1 = cc.MoveTo:create(0.3, cc.p(drawCard.fixed.x, drawCard.fixed.y + cardHeight))
        local act2 = cc.MoveTo:create(0.6, cc.p(self._cardIndexMapPosition[idx].x, drawCard.fixed.y + cardHeight))
        local act3 = cc.MoveTo:create(0.3, cc.p(self._cardIndexMapPosition[idx].x, drawCard.fixed.y))

        cc.CallFuncSequence.new(drawCard, 
            act1,
            cc.EaseSineOut:create(act2), 
            act3,
            function()
                if self._playCardNext then
                    self._playCardNext:next()
                end
            end
        ):start()
    end
end 


-- /**
--  * 出牌后，从手牌中删除一张牌后，重新设置卡牌的idx，fixed
--  */
function Layer:resetCardsIndex()
    for i = 1, #self._spHandCards[0] do
        self._spHandCards[0][i].idx = i
    end
end

-- /**
--  * 出牌之后，从手牌中删除一张牌,针对self
--  * @param card 打出的牌
--  */
function Layer:removeCardFromHandAfterPlay(card)
    local idx = card.idx
    table_remove(self._spHandCards[0], idx)
    PlayModel:removeTileFromHand(idx)
end

-- /**
--  * 删除吃牌节点
--  */
function Layer:removeFlatHeaps(chairID)
    local flatHeaps = self._spFlatHeaps[chairID]
    if not flatHeaps then
        return
    end

    for i = 1, #flatHeaps do
        local heap = flatHeaps[i]
        heap:removeSelf()
    end

    self._spFlatHeaps[chairID] = {}
end

-- /**
--  * 绘制吃牌区
--  */
function Layer:onRenderFlat(chairID, flats)
    local leftPadding   = PADDING_LEFT_FLAT[chairID]
    local bottomPadding = PADDING_BOTTOM_HAND[chairID]
    local grap          = GRAP_FLAT_HEAP[chairID]

    self:removeFlatHeaps(chairID)
    if chairID == 0 then
        for i = 1, #flats do
            local flat = flats[i]
            local nodeFlatHeap = FlatHeapNode.new(chairID, flat)
                :pos(cc.p(leftPadding + grap * (i - 1), bottomPadding))
                :addTo(self, 1)
            self._spFlatHeaps[chairID][i] = nodeFlatHeap
        end
    elseif chairID == 1 then
        for i = 1, #flats do
            local flat = flats[i]
            local nodeFlatHeap = FlatHeapNode.new(chairID, flat)
                :pos(cc.p(display.right - bottomPadding, leftPadding + grap * (i - 1)))
                :addTo(self, 5 - i)
            self._spFlatHeaps[chairID][i] = nodeFlatHeap
        end
    elseif chairID == 2 then
        for i = 1, #flats do
            local flat = flats[i]
            local nodeFlatHeap = FlatHeapNode.new(chairID, flat)
                :pos(cc.p(display.right -  leftPadding - grap * (i - 1), display.top - bottomPadding))
                :addTo(self, 1)
            self._spFlatHeaps[chairID][i] = nodeFlatHeap
        end
    else
        for i = 1, #flats do
            local flat = flats[i]
            local nodeFlatHeap = FlatHeapNode.new(chairID, flat)
                :pos(cc.p(bottomPadding, display.top - leftPadding - grap * (i - 1)))
                :addTo(self, 5 - i)
            self._spFlatHeaps[chairID][i] = nodeFlatHeap
        end
    end
end

--[[
-- /**
--  * 绘制一张河牌,每次打出牌，玩牌河中加一张，而不是删除所有，重新绘制
--  */
function Layer:onRenderOneRiver(chairID, tile)
    local cardType      = CardType_River
    local leftPadding   = PADDING_LEFT_RIVER[chairID]
    local bottomPadding = PADDING_BOTTOM_RIVER[chairID]
    local grap          = GRAP_RIVER_CARD[chairID]

    local spRiverCards = self._spRiverCards[chairID]
    local riverCount = #spRiverCards

    local fixed = cc.p(leftPadding + grap * riverCount, bottomPadding)
    local spCard = CardSprite.new(cardType, chairID, tile)
        :pos(fixed)
        :addTo(self, 1, i)

    spRiverCards[#spRiverCards + 1] = spCard
end
--]]

-- /**
--  * 获取第index张牌在牌河的位置
--  */
function Layer:getRiverCardPositionByIndex(chairID, index)
    local leftPadding   = PADDING_LEFT_RIVER[chairID]
    local bottomPadding = PADDING_BOTTOM_RIVER[chairID]
    local grap          = GRAP_RIVER_CARD[chairID]

    local k = index - 1
    if k >= RIVER_EACH_LINE_COUNT then --// 换一行，每行放9个
        bottomPadding = bottomPadding - GRAP_RIVER_LINE[chairID]
        k = k - RIVER_EACH_LINE_COUNT
    end

    if chairID == 0 then
        return k, cc.p(leftPadding + grap * k, bottomPadding)
    elseif chairID == 1 then
        return k, cc.p(display.right - bottomPadding, leftPadding + grap * k)
    elseif chairID == 2 then
        return k, cc.p(display.right - leftPadding - grap * k, display.top - bottomPadding)
    else
        return k, cc.p(bottomPadding, display.top - leftPadding - grap * k)
    end
end

-- /**
--  * 绘制河牌
--  */
function Layer:onRenderRiver(chairID, tiles)
    local cardType      = CardType_River
    local leftPadding   = PADDING_LEFT_RIVER[chairID]
    local bottomPadding = PADDING_BOTTOM_RIVER[chairID]
    local grap          = GRAP_RIVER_CARD[chairID]

    self:removePlayCard()
    self:removeRiverCards(chairID)
    if chairID == 0 then
        for i = 1, #tiles do
            local k, fixed = self:getRiverCardPositionByIndex(chairID, i)
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(fixed)
                :addTo(self, 20 - k)
            spCard.idx = i
            self._spRiverCards[chairID][i] = spCard
        end
    elseif chairID == 1 then
        local k = 0
        for i = 1, #tiles do
            local k, fixed = self:getRiverCardPositionByIndex(chairID, i)
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(fixed)
                :addTo(self, 50 - k)
            spCard.idx = i
            self._spRiverCards[chairID][i] = spCard
        end
    elseif chairID == 2 then
        local k = 0
        for i = 1, #tiles do
            local k, fixed = self:getRiverCardPositionByIndex(chairID, i)
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(fixed)
                :addTo(self, 50 - i)
            spCard.idx = i
            self._spRiverCards[chairID][i] = spCard
        end
    else
        local k = 0
        for i = 1, #tiles do
            local k, fixed = self:getRiverCardPositionByIndex(chairID, i)
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(fixed)
                :addTo(self, i)
            spCard.idx = i
            self._spRiverCards[chairID][i] = spCard
        end
    end
end

-- /**
--  * 绘制摸到的牌
--  */
function Layer:onRenderDraw(chairID, tile)
        
    local leftPadding   = PADDING_LEFT_HAND[chairID] + PlayModel:getFlatHeapCountByChairID(chairID) * GRAP_FLAT_HEAP[chairID]
    local bottomPadding = PADDING_BOTTOM_HAND[chairID]
    local grap          = GRAP_HAND_CARD[chairID]

    local handCount = #self._spHandCards[chairID]
    if chairID == 0 then
        local fixed = cc.p(leftPadding + grap * handCount + 30, bottomPadding)
        local spCard = CardSprite.new(CardType_Hand, chairID, tile)
                :pos(fixed.x, fixed.y + 40)
                :addTo(self, 50)
        spCard.fixed  = fixed
        spCard.idx    = handCount + 1
        spCard.isDraw = true
        self._spHandCards[chairID][handCount + 1] = spCard
        self._spDrawCard = spCard

        --// 摸到的牌动画
        spCard:runAction(cc.MoveTo:create(GOLD_QTR_TIME, fixed))

    elseif chairID == 1 then
        local fixed = cc.p(display.right - bottomPadding, leftPadding + grap * handCount + 10)
        local spCard = CardSprite.new(CardType_Hand, chairID, tile)
                :pos(fixed)
                :addTo(self, 1)
        --self._spHandCards[chairID][handCount + 1] = spCard
        self._spDrawCard = spCard
    elseif chairID == 2 then
        local fixed = cc.p(display.right - leftPadding - grap * handCount - 15, display.top - bottomPadding)
        local spCard = CardSprite.new(CardType_Hand, chairID, tile)
                :pos(fixed)
                :addTo(self, 1)
        --self._spHandCards[chairID][handCount + 1] = spCard
        self._spDrawCard = spCard
    else
        local fixed = cc.p(bottomPadding, display.top - leftPadding - grap * handCount - 10)
        local spCard = CardSprite.new(CardType_Hand, chairID, tile)
                :pos(fixed)
                :addTo(self, handCount + 1)
        --self._spHandCards[chairID][handCount + 1] = spCard
        self._spDrawCard = spCard
    end
end

-- /**
--  * 绘制手牌
--  */
function Layer:onRenderHand(chairID, tiles)
    local cardType      = CardType_Hand

    local flatCount   = PlayModel:getFlatHeapCountByChairID(chairID)
    local leftPadding = PADDING_LEFT_HAND[chairID]
    --//local leftPadding = leftPadding + flatCount * GRAP_FLAT_HEAP[chairID]
    --// 吃牌区有牌时微调坐标，以防有4组吃牌，手牌超出屏幕
    if flatCount > 0 then
        if chairID == 0 then
            leftPadding = leftPadding + flatCount * GRAP_FLAT_HEAP[chairID]
        elseif chairID == 1 then
            leftPadding = leftPadding - 10 + flatCount * GRAP_FLAT_HEAP[chairID]
        else
            leftPadding = leftPadding - 30 + flatCount * GRAP_FLAT_HEAP[chairID]
        end
    end

    local bottomPadding = PADDING_BOTTOM_HAND[chairID]
    local grap          = GRAP_HAND_CARD[chairID]

    self:removeHandCards(chairID)
    if chairID == 0 then
        for i = 1, #tiles do
            local fixed = cc.p(leftPadding + grap * (i - 1), bottomPadding)
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(fixed)
                :addTo(self, 1, 50)
            spCard.fixed  = fixed
            spCard.idx    = i
            spCard.isDraw = false
            self._spHandCards[chairID][i] = spCard
            self._cardIndexMapPosition[i] = fixed
        end

        --// 吃碰杠后，最右边的牌当作摸到的牌
        if #tiles % 3 == 2 then
            local drawCard = self._spHandCards[chairID][#self._spHandCards[chairID]]
            drawCard.fixed.x = drawCard.fixed.x + 30
            drawCard:setPositionX(drawCard.fixed.x)
            drawCard.isDraw = true
            self._cardIndexMapPosition[#self._cardIndexMapPosition] = drawCard.fixed
            self._spDrawCard = drawCard
        end
    elseif chairID == 1 then
        for i = 1, #tiles do
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(display.right - bottomPadding, leftPadding + grap * (i - 1))
                :addTo(self, 20 - i)
            self._spHandCards[chairID][i] = spCard
        end

        --// 吃碰杠后，最右边的牌当作摸到的牌
        if #tiles % 3 == 2 then
            local drawCard = self._spHandCards[chairID][#self._spHandCards[chairID]]
            drawCard:setPositionY(drawCard:getPositionY() + 10)
            self._spDrawCard = drawCard
            --// 摸得牌不加到手牌队列中
            table_remove(self._spHandCards[chairID])
        end
    elseif chairID == 2 then
        for i = 1, #tiles do
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(display.right - leftPadding - grap * (i - 1), display.top - bottomPadding)
                :addTo(self, i)
            self._spHandCards[chairID][i] = spCard
        end

        --// 吃碰杠后，最右边的牌当作摸到的牌
        if #tiles % 3 == 2 then
            local drawCard = self._spHandCards[chairID][#self._spHandCards[chairID]]
            drawCard:setPositionX(drawCard:getPositionX() - 10)
            self._spDrawCard = drawCard
            --// 摸得牌不加到手牌队列中
            table_remove(self._spHandCards[chairID])
        end
    else
        for i = 1, #tiles do
            local spCard = CardSprite.new(cardType, chairID, tiles[i])
                :pos(display.left + bottomPadding, display.top - leftPadding - grap * (i - 1))
                :addTo(self, i)
            self._spHandCards[chairID][i] = spCard
        end

        --// 吃碰杠后，最右边的牌当作摸到的牌
        if #tiles % 3 == 2 then
            local drawCard = self._spHandCards[chairID][#self._spHandCards[chairID]]
            drawCard:setPositionY(drawCard:getPositionX() - 15)
            self._spDrawCard = drawCard
            --// 摸得牌不加到手牌队列中
            table_remove(self._spHandCards[chairID])
        end
    end
end

-- /**
--  * 其他人出牌
--  */
function Layer:playCardOther(chairID, tile)
    local spDrawCard = self._spDrawCard
    if not spDrawCard then
        cclog.fatal("spDrawCard is nil!")
        return
    end

    spDrawCard.tile = tile
    --// 其他人出的牌，动画上显示都是摸到的牌
    self:playDiscard(chairID, spDrawCard)
end

-- /**
--  * 出牌, self
--  */
function Layer:playCard(card)
    if not card then
        return
    end

    self:removeCardFromHandAfterPlay(card)

    self._playCardNext = cc.Next.new( 
        --// 执行出牌动画
        function(ptr)
            self._isActionPlaying = true
            self:playDiscard(0, card)
             AudioHelper:playTile(card.tile)
        end, 
        --// 执行手牌排序动画
        function(ptr)
            self:playSortAfterPlayWithDraw(card)
        end,
        --// 系列动画执行完
        function(ptr)
            cclog.info("系列动画执行完毕")
            ptr:next()
            self._isActionPlaying = false
            self._playCardNext = nil
        end
    )
    self._playCardNext:start()
end

-- /**
--  * 出牌通知处理
--  */
function Layer:onPlayCard(chairID, tile)
    cclog.debug("<==== onPlayCard chairID = " ..chairID .. " tile = " ..tile)
    if chairID == 0 then
        if tile == PlayModel:getPreDiscardTile() then
            cclog.debug("已预出牌，此处不做处理")
        else
            if PlayModel:getPreDiscardTile() == 0 then
                --// 系统超时出牌,出的牌默认为最右边的一张，即为摸到的牌
                --// 若是吃碰杠后，把最右边的牌设置为摸到的牌
                cclog.debug("系统超时出牌")
                self:playCard(self._spDrawCard)
                AudioHelper:playTile(tile)
            else
                --// 后续强制刷新UI，同步服务器数据，不做纠正的UI处理
                cclog.warn("预出牌无效") 
            end
        end
    else
        self:playCardOther(chairID, tile)
         AudioHelper:playTile(tile)

        self:showPlayTips(chairID, tile)
    end
end

--// 绘制手牌，河牌，吃牌
function Layer:renderAllTilesByChairID(chairID)
    local handTiles  = PlayModel:getHandTilesByChairID(chairID)
    local riverTiles = PlayModel:getRiverTilesByChairID(chairID)
    local flatTiles  = PlayModel:getFlatTilesByChairID(chairID)

    self:onRenderHand(chairID, handTiles)
    self:onRenderRiver(chairID, riverTiles)
    self:onRenderFlat(chairID, flatTiles)
end

--// 隐藏光标
function Layer:hidePlayCursor()
    local spCursor = self:getChildByName("play_cursor")
    if spCursor then
        spCursor:hide()
    end
end

--// 显示光标
function Layer:showPlayCursor(pos)
    local spCursor = self:getChildByName("play_cursor")
    if not spCursor then
        spCursor = cc.Sprite:createWithSpriteFrameName("mj_play_cursor.png")
            :addTo(self, 200)
        spCursor:setName("play_cursor")
    end
    spCursor:show()
    spCursor:setPosition(pos)
    
    local act1 = cc.MoveTo:create(0.5, cc.p(pos.x, pos.y + 5))
    local act2 = cc.MoveTo:create(0.5, cc.p(pos.x, pos.y))
    spCursor:stopAllActions()
    spCursor:runAction(cc.RepeatForever:create(cc.Sequence:create(act1, act2)))
end

local CARDS_TIPS_POSITION = {
    [0] = cc.p(display.cx, 200),
    [1] = cc.p(display.cx + 330, display.cy + 50),
    [2] = cc.p(display.cx, display.top - 100),
    [3] = cc.p(display.cx - 330, display.cy + 50),
}

--// 隐藏出牌提示
function Layer:hidePlayTips()
    local nodeTips = self:getChildByName("play_card_tips")
    if nodeTips then
        nodeTips:hide()
    end
end

--// 绘制出牌显示
function Layer:showPlayTips(chairID, tile)
    local nodeTips = self:getChildByName("play_card_tips")
    if nodeTips then
        nodeTips:setPosition(CARDS_TIPS_POSITION[chairID])
        nodeTips:getChildByTag(100):setTile(tile)
        nodeTips:show()
        return
    end

    nodeTips = cc.Node:create()
        :pos(CARDS_TIPS_POSITION[chairID])
        :addTo(self, 200)
    nodeTips:setName("play_card_tips")
    local spPlayTips = cc.Sprite:createWithSpriteFrameName("mj_play_tips_bg.png")
        :addTo(nodeTips, 1)
    local spCard = CardSprite.new(CardType_Hand, 0, tile)
        :posY(5)
        :addTo(nodeTips, 2)
    spCard:setTag(100)
end

-- /**
--  * 绘制结算界面的wintiles
--  * @return node
--  */
function Layer:drawWinTiles(handTiles, flatTiles)

    local node = cc.Node:create()

    local function drawFlats()
        local grap          = GRAP_FLAT_HEAP[0]
        for i = 1, #flatTiles do
            local flat = flatTiles[i]
            local nodeFlatHeap = FlatHeapNode.new(0, flat)
                :pos(cc.p(grap * (i - 1), 0))
                :addTo(node, 2)
        end
    end

    drawFlats()

    local function drawHand()
        local leftPadding = #flatTiles * GRAP_FLAT_HEAP[0] - 30
        local grap          = GRAP_RIVER_CARD[0]
        local huGrap = 0
        for i = 1, #handTiles do
            local spCard = CardSprite.new(CardType_River, 0, handTiles[i])
                :pos(cc.p(leftPadding + grap * (i - 1) + huGrap, 0))
                :addTo(node, 2)

            if handTiles[i] == PlayModel:getOpTile() then
                huGrap = 5
                spCard:posX(spCard:getPositionX() + huGrap)
                local spLight = cc.Sprite:createWithSpriteFrameName("mj_light.png")
                    :pos(cc.p(spCard:getPosition()))
                    :addTo(node, 1)
                huGrap = huGrap * 2

                local act1 = cc.ScaleTo:create(GOLD_TIME, 1.2)
                local act2 = cc.ScaleTo:create(GOLD_TIME, 1)
                local act11 = cc.FadeTo:create(GOLD_TIME, 200)
                local act21 = cc.FadeTo:create(GOLD_TIME, 255)
                spLight:runAction(cc.RepeatForever:create(cc.Sequence:create(act1, act2)))
                spLight:runAction(cc.RepeatForever:create(cc.Sequence:create(act11, act21)))
            end
        end
    end

    drawHand()

    return node
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")
    cc.EventProxy.new(myApp, self)
        :on("evt_SC_MAHJ_DRAWN_P", function(evt)
            local data = evt.data
            self:onRenderDraw(data.chairID, data.tile)
            AudioHelper:playDraw()
        end)
        :on("evt_SC_MAHJ_TITE_UP_P", function(evt)
            local data = evt.data
            if PlayModel:getIsNewRound() then
                self:renderAllTilesByChairID(data.chairID)
            else
                --// 等出牌动画执行完毕后再执行
                if self._playCardNext then
                    self._playCardNext:push(function()
                        self:renderAllTilesByChairID(data.chairID)
                    end)
                else
                    --// 因为杠排之后，有可能需要摸牌，所以不延迟绘制，
                    --// 后续加上CPK的动画后，再考虑
                    if PlayModel:getCurOpAction() == MahjOp.KONG then
                        self:renderAllTilesByChairID(data.chairID)
                    else
                        --// 等动画执行完毕，重新绘制牌
                        cc.ScheduleManager:performWithDelay(self, function()
                            self:renderAllTilesByChairID(data.chairID)
                        end, GOLD_TIME)
                    end
                end
            end
        end)
        :on("evt_Hide_Play_Card_Tips", function(evt)
            self:hidePlayTips()
        end)
        :on("evt_Hide_Play_Card_Cursor", function(evt)
            self:hidePlayCursor()
        end)
        :on("evt_SC_MAHJ_OP_P_DISCARD", function(evt)
            local data = evt.data

            cclog.info("出牌广播 tile = " ..data.tile)
            self:onPlayCard(data.chairID, data.tile)
        end)
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")
end

return Layer