--
-- Author: Your Name
-- Date: 2017-06-26 09:19:27
--
local Button = ccui.Button or {}

function Button:setSelected(selected)
    if self.selectedImage then
        self.selectedImage:setVisible(selected)
        if selected then
            self:setScale(1.1)
        else
            self:setScale(1)
        end
    end
end