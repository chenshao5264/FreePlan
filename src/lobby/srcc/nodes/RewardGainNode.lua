--
-- Author: Chen
-- Date: 2017-12-18 19:07:40
-- Brief: 
--
local Global = gg.Global

local M = class("RewardGainNode", function()
    return cc.CSLoader:createNode(Global:getCsbFile("nodes/RewardGainNode"))
end)

--// step1
function M:ctor(infos)
    local imgIcon = self:getChildByName("Image_Icon")
    local imgBg1  = self:getChildByName("Image_Bg_1")
    local imgBg2  = self:getChildByName("Image_Bg_2")
    local bfValue = self:getChildByName("BitmapFontLabel_Value")
    imgIcon:ignoreContentAdaptWithSize(true)

    local widget = ccui.Widget:create()
        :addTo(self, 1)

    imgIcon:changeParent(widget, 3)
    imgBg1:changeParent(widget, 2)
    imgBg2:changeParent(widget, 1)
    bfValue:changeParent(widget, 1)
    
    local items = {}

    for i = 1, #infos do
        local info = infos[i]
        local w = widget:clone()
        w:getChildByName("Image_Icon"):loadTexture(info.res, 1)
        w:getChildByName("BitmapFontLabel_Value"):setString(info.str)
        local img1 = w:getChildByName("Image_Bg_1")


        local act1 = cc.ScaleTo:create(GOLD_TIME, 1.2)
        local act2 = cc.ScaleTo:create(GOLD_TIME, 1)
        img1:runAction(cc.RepeatForever:create(cc.Sequence:create(act1, act2)))

        items[#items + 1] = w
    end

    local params = {
        totalCount = #infos,
        colCount = #infos,
        rowMargin = 10,
        colMargin = 180,
    }

    local grid = cc.GridNode:create(items, params)
        :addTo(self, 1)

    widget:hide()
end

return M