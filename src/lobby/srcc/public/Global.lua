--
-- Author: Chen
-- Date: 2017-11-23 09:42:23
-- Brief: 
--
local Global = {}


function Global:getCsbFile(name)
    return string.format("csb/%s.csb", name)
end

function Global:getGameImage(name)
    return string.format("images/%s.png", name)
end

function Global:getAvatarImageByGender(gender)
    if gender == 1 then
        return "img_avatar1.png"
    else
        return "img_avatar0.png"
    end
end

return Global