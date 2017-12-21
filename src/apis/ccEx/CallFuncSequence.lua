--
-- Author: Chen
-- Date: 2017-11-24 09:42:22
-- Brief: 
--
local CallFuncSequence = class("CallFuncSequence")


function CallFuncSequence:ctor(target, ...)
    self._target = target
    local funcs  = {...}

    self._actList = {}
    
    for i = 1, #funcs do
        local callFunc = funcs[i]
        if type(callFunc) == "userdata" then
            --// cc的anction
            self._actList[#self._actList + 1] = callFunc
        elseif type(callFunc) == "function" then
            self._actList[#self._actList + 1] = cc.CallFunc:create(callFunc)
        end
    end
end

-- /**
--  * 开始执行
--  */
function CallFuncSequence:start()
    
    if not self._target then
        cclog.fatal("not set target!")
        return
    end
    if #self._actList == 0 then
        cclog.warn("action list is empty!")
        return
    end

    self._target:stopAllActions()
    self._target:runAction(cc.Sequence:create(self._actList))
end

return CallFuncSequence