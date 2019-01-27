--
-- Author: Your Name
-- Date: 2017-09-05 22:22:10
--

local utility = {}

local math_floor = math.floor

function utility.isNumberOnly(str)
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if ch < 48 or ch > 57 then
            return false
        end
    end
    return true
end

function utility.isLetterOnly(str)
    local count = 0
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122) then
            count = count + 1
        end
    end
    if count == string.len(str) then
        return true
    end

    return false
end

--// 智能游戏豆写法
function utility.getShortBean(quantity)
    if quantity < 10000 then
        return quantity
    -- elseif quantity < 100000 then
    --     return math_floor(quantity / 1000) / 10 .."w"
    else
        return quantity
        --return math_floor(quantity / 10000) .."w"
    end
end

--省略文本 str为文本内容 n为最大内容 其中中文为2个单位
function utility.getShortStr(str, maxCount, substitute)  
    if str == nil or maxCount == nil then
        return ""
    end

    substitute = substitute or "..."
    local sStr = str
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    local nShowCount = maxCount
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount - 1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName,char)
            table.insert(tCode,1)
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName,char)
            table.insert(tCode,2)
        end
    end
    if nWidth > maxCount then
        local _sN = ""
        local _len = 0
        for i=1,#tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        str = _sN ..substitute
    end
    return str
end

return utility