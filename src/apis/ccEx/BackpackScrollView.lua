--
-- Author: Your Name
-- Date: 2017-07-06 13:42:09
--

-- local backpackScrollView = cc.BackpackBoxScrollView:create(cc.size(backpackBox:getContentSize().width, 400))
-- backpackScrollView:addBackpackBox(backpackBox)
-- self:addChild(backpackScrollView)
-- backpackScrollView:setPosition(0, display.height)

local BackpackScrollView = class("BackpackScrollView", function()
    return ccui.ScrollView:create()
end)

function BackpackScrollView:ctor(size)
   -- self:setBackGroundColorType(1)
   -- self:setBackGroundColor(cc.c3b(255, 0, 0))

    self:setAnchorPoint(cc.p(0, 1))
    self:setContentSize(size)
end

function BackpackScrollView:addBackpackBox(backpackBox)
    self:adjust(backpackBox)
    self:addChild(backpackBox, 1)

    backpackBox.isInScrollView = true
    backpackBox.scrollView = self
end

function BackpackScrollView:adjust(backpackBox)
    local innerContainerSize = backpackBox:getContentSize()
    self:setInnerContainerSize(innerContainerSize)

    local boxY = innerContainerSize.height
    if boxY < self:getContentSize().height then
        boxY = self:getContentSize().height
    end
    backpackBox:setPosition(0, boxY)
end

return BackpackScrollView