--
-- Author: Chen
-- Date: 2017-08-31 17:20:32
-- Brief: 
--

-- /**
--  * 标准数组table转为枚举table
--  * @param {[type]} t     需要转换的数组
--  * @param {[type]} index 枚举值开始下标值,默认0
--  * @param {[type]} srct  可为空, 若不为空, srct与t合并
--  *
--  * local Day = Enum({
--  *    "Monday",
--  *    "Tuesday",
--  *    "Wednesday",
--  * })
--  *
--  * Day = Enum({
--  *   "Thursday",
--  *   "Friday",
--  *   "Saturday",
--  * }, 4, Day)
--  */

function Enum(t, index, srct)
    local eTable = srct or {}
    if index then
        index = index - 1
    else
        index = -1
    end
    local eIndex = index or 0

    for i = 1, #t do
        eTable[t[i]] = eIndex + i
    end

    return eTable
end