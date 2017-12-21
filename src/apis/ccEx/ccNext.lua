--
-- Author: Chen
-- Date: 2017-11-29 18:00:36
-- Brief: 
--
local Next = class("Next")

-- /**
--  * 封装有时序关系的几个函数，使代码结构看起来不是杂乱
--  * @param  ... 函数列表
--  */
function Next:ctor(...)
    self._funcs  = {...}  --// 函数列表

    self._ptr = 1
end

--// 下一个
function Next:next()
    self._ptr = self._ptr + 1
    self:start()
end

--// 开始执行
function Next:start()
    if self._funcs[self._ptr] then
        self._funcs[self._ptr](self)
    end
end

--// 加入新的执行函数
function Next:push(func)
    self._funcs[#self._funcs + 1] = func
end

return Next