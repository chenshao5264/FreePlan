--
-- Author: Your Name
-- Date: 2017-08-17 09:47:39
--
local ActionHelper = {}


-- /**
--  * 文字滚动动画
--  * @param obj 执行动作主体
--  * @param time 执行动作时间
--  * @param c1 起始数字
--  * @param c2 结束数字
--  */
function ActionHelper:digitRoll(obj, time, c1, c2)
    time = time or 0.3
    local factor = c1 > c2 and -1 or 1
    local frameChangeCount = math.ceil(math.abs(c1 - c2) / time / 60)

    local delay = cc.DelayTime:create(1 / 60)
    local fc = cc.CallFunc:create(function()
        c1 = c1 + frameChangeCount * factor
        if factor == -1 then
            if c1 <= c2 then
                obj:stopAllActions()
                c1 = c2
            end
        else
            if c1 >= c2 then
                obj:stopAllActions()
                c1 = c2
            end
        end
        obj:setString(c1)
    end)
    obj:runAction(cc.RepeatForever:create(cc.Sequence:create(delay, fc)))
end

return ActionHelper