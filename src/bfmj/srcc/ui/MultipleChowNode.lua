--
-- Author: Chen
-- Date: 2017-12-06 16:19:56
-- Brief: 
--

local gg = gg
local pp = pp
local Global    = gg.Global
local PlayModel = pp.PlayModel

local GamePublic = pp.GamePublic
local MahjOp     = GamePublic.MahjOp

local Res_mj_mutiply_chow = gg.Res_mj_mutiply_chow

local CardSprite = game:loadSource("ui.CardSprite")

local M = class("MultipleChowNode", function()
    return cc.Node:create()
end)

--// step1
function M:ctor(tile)
    local actions = PlayModel:getCanOpActions()
    local count   = PlayModel:getCanChowAmount()

    count = 3
    actions[MahjOp.LEFTCHOW] = true

    local cx = 125
    local cy = 63

    local cardType = gg.CardType.HAND
    local grap     = gg.GRAP_HAND_CARD[0]

    local function onClick(obj)
        gg.RequestManager:reqChow(obj.op)
        self:removeSelf()
    end

    local imgBg1
    if actions[MahjOp.LEFTCHOW] then
        imgBg1 = ccui.ImageView:create(Res_mj_mutiply_chow[1], Res_mj_mutiply_chow[2])
        imgBg1:setScale9Enabled(true)
        imgBg1:setContentSize(cc.size(250, 120))
        self:addChild(imgBg1, 1)
        imgBg1:onClick_(onClick)

        imgBg1.op = MahjOp.LEFTCHOW
        local spCard1 = CardSprite.new(cardType, 0, tile)
            :pos(cx - grap, cy)
            :addTo(imgBg1, 1)
        local spCard2 = CardSprite.new(cardType, 0, tile + 1)
            :pos(cx, cy)
            :addTo(imgBg1, 1)
        local spCard3 = CardSprite.new(cardType, 0, tile + 2)
            :pos(cx + grap, cy)
            :addTo(imgBg1, 1)
    end

    local imgBg2
    if actions[MahjOp.MIDCHOW] then
        imgBg2 = ccui.ImageView:create(Res_mj_mutiply_chow[1], Res_mj_mutiply_chow[2])
        imgBg2:setScale9Enabled(true)
        imgBg2:setContentSize(cc.size(250, 120))
        self:addChild(imgBg2, 1)
        imgBg2:onClick_(onClick)

        imgBg2.op = MahjOp.MIDCHOW

        local spCard1 = CardSprite.new(cardType, 0, tile - 1)
            :pos(cx - grap, cy)
            :addTo(imgBg2, 1)
        local spCard2 = CardSprite.new(cardType, 0, tile)
            :pos(cx, cy)
            :addTo(imgBg2, 1)
        local spCard3 = CardSprite.new(cardType, 0, tile + 1)
            :pos(cx + grap, cy)
            :addTo(imgBg2, 1)
    end

    local imgBg3
    if actions[MahjOp.RIGHTCHOW] then
        imgBg3 = ccui.ImageView:create(Res_mj_mutiply_chow[1], Res_mj_mutiply_chow[2])
        imgBg3:setScale9Enabled(true)
        imgBg3:setContentSize(cc.size(250, 120))
        self:addChild(imgBg3, 1)
        imgBg3:onClick_(onClick)

        imgBg3.op = MahjOp.RIGHTCHOW

        local spCard1 = CardSprite.new(cardType, 0, tile - 2)
            :pos(cx - grap, cy)
            :addTo(imgBg3, 1)
        local spCard2 = CardSprite.new(cardType, 0, tile - 1)
            :pos(cx, cy)
            :addTo(imgBg3, 1)
        local spCard3 = CardSprite.new(cardType, 0, tile)
            :pos(cx + grap, cy)
            :addTo(imgBg3, 1)
    end

    local left
    local grap = 0
    if count == 2 then
        left = -130
    else
        left = -260
    end

    if imgBg1 then
        imgBg1:posX(left + grap)
        grap = grap + 260
    end
    if imgBg2 then
        imgBg2:posX(left + grap)
        grap = grap + 260
    end
    if imgBg3 then
        imgBg3:posX(left + grap)
    end
end


return M