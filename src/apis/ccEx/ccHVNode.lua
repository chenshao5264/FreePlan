--
-- Author: Your Name
-- Date: 2017-07-03 10:15:25
--


-- local hvNode = cc.HVNode:create({img1, img2, img3, img4}, 0, 10)
-- hvNode:setPosition(display.cx, display.cy)
-- self:addChild(hvNode, 1)

-- hvNode:pushBackCustomItem(img1:clone())

local HVNode = class("HVNode", function()
    return cc.Node:create()
end)

--// direction 垂直, 水平
--// itemsMargin 单元格边缘
--// type 类型 0 居中, 1 居左或者居上, 2居右或者居下
function HVNode:ctor(direction, type, itemsMargin)

    self._items       = {}
    self._direction   = direction or 0
    self._itemsMargin = itemsMargin or 10
    self._type        = type or 0
end

function HVNode:setDirection(direction)
    self._direction = direction or 0
end

function HVNode:setItemsMargin(margin)
    self._itemsMargin = margin or 10
end

function HVNode:pushBackCustomItem(item)
    self._items[#self._items + 1] = item
    self:addChild(item)
    item:setPosition(0, 0)

    self:adjust()
end

function HVNode:adjust()
    local items       = self._items
    local itemCount   = #self._items    

    if itemCount <= 0 then
        return
    end

    local itemSize = items[1]:getContentSize()
    if self._direction == 0 then --// 水平
        local itemX = itemSize.width + self._itemsMargin
        local firstPos
        if self._type == 0 then
            firstPos  = -itemX * (itemCount - 1) / 2
        elseif self._type == 1 then
            firstPos  = itemX / 2 
        else
            firstPos  = (0.5 - itemCount) * itemX
        end

        for i = 1, itemCount do
            local item = items[i]
            item:setPositionX(firstPos + itemX * (i - 1))
            item:setTag(i)
        end
    else
        local itemX = itemSize.height + self._itemsMargin
        local firstPos
        if self._type == 0 then 
            firstPos  = itemX * (itemCount - 1) / 2
        elseif self._type == 1 then 
            firstPos  = -itemX / 2 
        else
            firstPos  = -(0.5 - itemCount) * itemX
        end
        
        for i  = 1, itemCount do
            local item = items[i]
            item:setPositionY(firstPos - itemX * (i - 1))
            item:setTag(i)
        end
    end
end

function HVNode:getItemByIndex(idx)
    return self:getChildByTag(idx)
end

function HVNode:removeItemByIndex(idx)
    if self:getChildByTag(idx) then
        table.remove(self._items, idx)
        self:removeChildByTag(idx)
    else
        print("no item: " ..idx)
    end

    self:adjust()
end

return HVNode

