--
-- Author: Chen
-- Date: 2017-11-23 17:06:48
-- Brief: 
--

local pp = pp
local CardType_Flat   = pp.CardType.FLAT
local GRAP_RIVER_CARD = pp.GRAP_RIVER_CARD

local CardSprite = game:loadSource("ui.CardSprite")

local FlatHeapNode = class("FlatHeapNode", function()
    return cc.Node:create()
end)

function FlatHeapNode:ctor(chairID, tiles)
    local cardType = CardType_Flat
    local grap     = GRAP_RIVER_CARD[chairID]

    local spCards = {}
    if chairID == 0 then
        for i = 1, #tiles do
            local tile = tiles[i]
            local spCard = CardSprite.new(cardType, chairID, tile)
            if i < 4 then
                spCard:pos(cc.p(grap * (i - 2), 0))
            elseif i == 4 then
                spCard:pos(cc.p(0, 14))
            end
            spCard:addTo(self, 1)
            spCards[#spCards + 1] = spCard
        end
    elseif chairID == 1 then
        for i = 1, #tiles do
            local tile = tiles[i]
            local spCard = CardSprite.new(cardType, chairID, tile)
            if i < 4 then
                spCard:pos(cc.p(0, grap * (i - 2)))
                spCard:setLocalZOrder(3 - i)
            elseif i == 4 then
                spCard:pos(cc.p(0, 10))
                spCard:setLocalZOrder(4)
            end
            spCard:addTo(self)
            spCards[#spCards + 1] = spCard
        end
    elseif chairID == 2 then
        for i = 1, #tiles do
            local tile = tiles[i]
            local spCard = CardSprite.new(cardType, chairID, tile)
            if i < 4 then
                spCard:pos(cc.p(grap * (i - 2), 0))
            elseif i == 4 then
                spCard:pos(cc.p(0, 14))
            end
            spCard:addTo(self, 1)
            spCards[#spCards + 1] = spCard
        end
    else
        for i = 1, #tiles do
            local tile = tiles[i]
            local spCard = CardSprite.new(cardType, chairID, tile)
            if i < 4 then
                spCard:pos(cc.p(0, grap * (2 - i)))
            elseif i == 4 then
                spCard:pos(cc.p(0, 10))
            end
            spCard:addTo(self, i)
            spCards[#spCards + 1] = spCard
        end
    end

    self._spCards = spCards
end

return FlatHeapNode