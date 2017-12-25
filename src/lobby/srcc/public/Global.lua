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

-- /**
--  * 根据性别获取头像资源
--  * @param  [isUserCenter] 是否是用户中心界面
--  * @return [string]
--  */
function Global:getAvatarImageByGender(gender, isUserCenter)
    if gender == 1 then
        if isUserCenter then
            return "UserCenter_head1.png"
        else
            return "img_avatar1.png"
        end
    else
        if isUserCenter then
            return "UserCenter_head0.png"
        else
            return "img_avatar0.png"
        end
    end
end

return Global