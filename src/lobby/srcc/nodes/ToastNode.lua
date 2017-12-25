--
-- Author: Chen
-- Date: 2017-11-30 15:21:18
-- Brief: 
--
local cc = cc
local Global = gg.Global

local M = class("ToastNode", function()
    return cc.CSLoader:createNode(Global:getCsbFile("nodes/ToastNode"))
end)

-- /**
--  * 
--  * @param  content 目前有长度限制，适合简短的提示
--  * @return
--  */
function M:ctor(content)
    
    local imgBg    = self:getChildByName("Image_Bg")
    local textTips = self:getChildByName("Text_Tips"):str(content)

    self.height = imgBg:getContentSize().height

    cc.CallFuncSequence.new(self, 
        cc.DelayTime:create(1.5),
        function()
            local act = cc.FadeOut:create(GOLD_HALF_TIME)
            self:runAction(act)
        end
    ):start()
end

function M:rise(goalPos)
    self:runAction(cc.MoveTo:create(GOLD_QTR_TIME, goalPos))
end

return M