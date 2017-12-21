--
-- Author: Your Name
-- Date: 2017-07-06 10:35:11
--
local BackpackBox = class("BackpackBox", function()
    return cc.Node:create()
end)


-- /**
--  * [ctor description]
--  * @param  {[type]} rowItemCount [每行item的数量]
--  * @param  {[type]} direction    [0:多行;1:单行]
--  * @param  {[type]} itemsMargin  [单元格边距]
--  * @param  {[type]} rowsMargin   [行距]
--  * @return {[type]}              [node]
--  */
function BackpackBox:ctor(rowItemCount, direction, itemsMargin, rowsMargin)
    if rowItemCount <= 0 then
        return
    end

    self._items        = {}
    self._rowItemCount = rowItemCount or 4
    self._direction    = direction or 0
    self._itemsMargin  = itemsMargin or 0
    self._rowsMargin   = rowsMargin or 0

    self._selectedListener = nil
    self._isAnimation      = false
    self._defaultItem      = nil

    self._margins = {left = 0, top = 0}
end

function BackpackBox:setMargin(margin)
    self._margins = margin
end

function BackpackBox:setDirection(direction)
    self._direction = direction or 0
end

function BackpackBox:setRowsMargin(rowsMargin)
    self._rowsMargin = rowsMargin or 10
end

function BackpackBox:pushBackCustomItem(item)
    self._items[#self._items + 1] = item
    self:addChild(item)
    if item.x and item.y then
        item:setPosition(item.x, item.y)
    else
        item:setPosition(0, 0)
    end

    self:adjust()
end

function BackpackBox:getItemByIndex(idx)
    return self._items[idx]
end

function BackpackBox:getItemsCount()
    return #self._items
end

function BackpackBox:getItems()
    return self._items
end

function BackpackBox:setActionCompletedCallBack(callback)
    self._actionCompleted = callback
end

function BackpackBox:adjust()
    local items       = self._items
    local itemCount   = #self._items    

    if itemCount <= 0 then
        return
    end

    local itemSize = items[1]:getContentSize()

    local itemWidth  = itemSize.width + self._itemsMargin
    local itemHeight = itemSize.height + self._rowsMargin
    local firstPos   = cc.p(itemSize.width / 2 + self._margins.left, -(itemSize.height / 2) - self._margins.top)

    local itemX = firstPos.x - itemWidth
    local itemY = firstPos.y + itemHeight
    for i = 1, itemCount do
        local item = items[i]
        item:setTag(i)

        if self._rowItemCount == 1 or i % self._rowItemCount == 1 then
            itemX = firstPos.x
            itemY = itemY - itemHeight
        else
            itemX = itemX + itemWidth
            itemY = itemY
        end

        if self._isAnimation then
            if item:getPositionX() ~= itemX or item:getPositionY() ~= itemY then
                local moveTo = cc.MoveTo:create(0.3, cc.p(itemX, itemY))
                item:stopAllActions()
                item:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(function()
                    if self._actionCompleted then
                        self._actionCompleted()
                        self._actionCompleted = nil
                    end
                end)))
           end
        else
            item:setPositionX(itemX)
            item:setPositionY(itemY)
        end    
    end

    if self.scrollView then
        self.scrollView:adjust(self)
    end
end

--// index 遵循lua规则, 从1开始计数
function BackpackBox:removeItemByIndex(idx, isAnimation)
    if self:getChildByTag(idx) then
        table.remove(self._items, idx)
        self:removeChildByTag(idx)

        self._isAnimation = isAnimation
        self:adjust()
    else
        print("no item: " ..idx)
    end
end

function BackpackBox:insertItemByIndex(item, idx, isAnimation)
    idx = idx or #self._items
    if idx <= 0 then
        idx = 1
    end

    self._isAnimation = isAnimation

    if idx > #self._items then
        self:pushBackCustomItem(item)
    else
        table.insert(self._items, idx, item)
        if item.x and item.y then
            item:setPosition(item.x, item.y)
        else
            item:setPosition(0, 0)
        end
        self:addChild(item)
        self:adjust()
    end
end

function BackpackBox:getContentSize()
    local rowCount = math.ceil(#self._items / self._rowItemCount)

    if self._items[1] then
        local itemSize   = self._items[1]:getContentSize()
        local itemWidth  = itemSize.width + self._itemsMargin
        local itemHeight = itemSize.height + self._rowsMargin

        if self._direction == 0 then
            return {
                width  = itemWidth * self._rowItemCount,
                height = itemHeight * rowCount
            }
        else
            return {
                width  = itemWidth * #self._items,
                height = itemHeight * rowCount
            }
        end
    end

    return {
        width  = 0,
        height = 0
    }
end

return BackpackBox