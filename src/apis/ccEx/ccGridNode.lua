--
-- Author: Your Name
-- Date: 2017-12-17 16:28:58
--



local cc = cc
cc.GridNode = {}

local math_ceil = math.ceil

-- /**
--  * @brief  创建网格布局的节点
--  * @return
--  */
function cc.GridNode:create(items, params)
    local node = cc.Node:create()

    if not items then
        return node
    end
    if #items == 0 then
        return node
    end

    local totalCount = params.totalCount        --// 总数量
    local colCount   = params.colCount          --// 列数
    local rowMargin  = params.rowMargin or 0
    local colMargin  = params.colMargin or 0
    local alignment  = params.alignment or "left"    --// 排列方式 left center

    local rowCount   = math_ceil(totalCount / colCount) --// 行数
    local lastRowCount = totalCount - colCount * (rowCount - 1)

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
        item:setPositionY(firstPosY - itemY * (curRow - 1))
        curCol = curCol + 1
        if i % colCount == 0 then
            curRow = curRow + 1
            curCol = 1
            if curRow == rowCount then --// 最后一行
                if alignment == "center" then
                    firstPosX = -itemX * (lastRowCount - 1) / 2
                else
                    firstPosX = copyFirstPosX
                end
            end
            
        end
    end

    return node
end