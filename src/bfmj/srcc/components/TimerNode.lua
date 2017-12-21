--
-- Author: Chen
-- Date: 2017-11-23 10:43:46
-- Brief: 
--
local Global = gg.Global

local M = class("TimerNode", function()
    return cc.CSLoader:createNode(Global:getCsbFile("games/TimerNode"))
end)

local string_format = string.format

--// step1
function M:ctor()
    self:enableNodeEvents()
    self:procUI()

end

--// ui关联
function M:procUI()
    self.spTimerBg    = self:getChildByName("time_bg_1")
    self.spTimerPause = self:getChildByName("time_bg_2"):hide()
    self.bfTime       = self:getChildByName("BitmapFontLabel_Time")
    self.bfTime:setString("00")
end

function M:onTimer(chairID, count)
    if chairID < 0 then
        self.spTimerBg:hide()
    else
        self.spTimerBg:show()
        local act = cc.RotateTo:create(GOLD_QTR_TIME, -90 * chairID)
        self.spTimerBg:stopAllActions()
        self.spTimerBg:runAction(act)  
    end


    self.bfTime:setString(string_format("%02d", count))
    cc.ScheduleManager:removeHandleByKey(self, "op_time")
    cc.ScheduleManager:addHandle(self, function()
        count = count - 1
        if count < 0 then
            count = 0
        end
        self.bfTime:setString(string_format("%02d", count))
    end, 1, "op_time")
end

--// 监听视图数据变化事件
function M:onRegisterEventProxy()
    cc.EventProxy.new(myApp, self)
        :on("evt_timer_update", function(evt)
            local data = evt.data
            self:onTimer(data.chairID, data.timeSec)
        end)
end

function M:onEnter()
    --// todo
    --// ...

    

    self:onRegisterEventProxy()
end

function M:onExit()
    --// todo
    --// ...

    cc.ScheduleManager:removeAllByTarget(self)
end

return M