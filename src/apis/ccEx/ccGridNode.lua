--
-- Author: Your Name
-- Date: 2017-12-17 16:28:58
--

local cc = cc
cc.GridNode = {}
-- /**
--  * @brief  创建网格布局的节点
--  * @param  [items]           单元格
--  * @param  [rowCount]        行数
--  * @param  [rowMargin]       行间距
--  * @param  [colCount]        列单元格间距
--  * @param  [colMargin]       列间距
--  * @return
--  */
function cc.GridNode:create(items, rowCount, rowMargin, colCount, colMargin)
    local node = cc.Node:create()

    local item = items[1]

    local s = item:getContentSize()
    local itemWidth, itemHeight = s.width, s.height

    local itemX     = itemWidth + colMargin
    local itemY     = itemHeight + rowMargin
    local firstPosX = -itemX * (colCount - 1) / 2
    local firstPosY = itemY * (rowCount - 1) / 2

    local copyFirstPosX = firstPosX
    local curRow = 1
    local curCol = 1
    for i = 1, #items do
        local item = items[i]
            :addTo(node, 1)
        item:setPositionX(firstPosX + itemX * (curCol - 1))
        curCol = curCol + 1
        item:setPositionY(firstPosY - itemY * (curRow - 1))
        if i % colCount == 0 then
            curRow = curRow + 1
            curCol = 1
            firstPosX = copyFirstPosX
        end
    end

    return node
end