--
-- Author: Chen
-- Date: 2017-11-30 13:34:37
-- Brief: 
--
local Global = gg.Global

--// 超时时间
local TIME_OUT = 5

local M = class("WaittingNode", function()
    local node = cc.CSLoader:createNode(Global:getCsbFile("nodes/WaittingNode"))

    local csdAni = cc.CSLoader:createTimeline(Global:getCsbFile("nodes/WaittingNode"))
    node:runAction(csdAni)
    csdAni:gotoFrameAndPlay(0, true)

    return node
end)

--// step1
function M:ctor(content, callback)
    self:enableNodeEvents()

    local textTips = self:getChildByName("Text_Tips"):str(content)

    local time = 0
    local count = 0
    cc.ScheduleManager:addHandle(self, function()
        count = count + 1
        if count == 0 then
            textTips:str(content)
        elseif count == 1 then
            textTips:str(content ..".")
        elseif count == 2 then
            textTips:str(content .."..")
        elseif count == 3 then
            textTips:str(content .."...")
            count = -1
        end

        time = time + 0.5
        if time >= TIME_OUT then
            cclog.warn("time out")
            if callback then
                callback()
            end
        end
    end, 0.5, "waitting_schedule")
end


function M:onEnter()
    --// todo
    --// ...

end

function M:onExit()
    --// todo
    --// ...

    cc.ScheduleManager:removeAllByTarget(self)
end

return M