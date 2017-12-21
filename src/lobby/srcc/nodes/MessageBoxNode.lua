--
-- Author: Chen
-- Date: 2017-11-30 11:16:29
-- Brief: 
--
local Global = gg.Global

local M = class("MessageBoxNode", function()
    return cc.CSLoader:createNode(Global:getCsbFile("nodes/MessageBoxNode"))
end)

--// step1
function M:ctor(content, type, callback)
    self:setCascadeOpacityEnabled(true)

    self:getChildByName("Text_Content"):str(content)

    local btnOK     = self:getChildByName("Button_OK")
    local btnCancel = self:getChildByName("Button_Cancel")


    local function onClick(obj)
        if obj == btnOK then
            if callback then
                callback("ok")
            end
        else
            if callback then
                callback("cancel")
            end
        end
    end
    
    btnOK:onClick_(onClick)
    if type == 1 then
        btnOK:posX(0)
        btnCancel:hide()
    else
        btnCancel:onClick_(onClick)
    end
end

return M