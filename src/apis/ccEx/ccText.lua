--
-- Author: Chen
-- Date: 2017-11-28 15:32:29
-- Brief: 
--
local Text = ccui.Text or {}


function Text:str(text)
    self:setString(text)
    return self
end