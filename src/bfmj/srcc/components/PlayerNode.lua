--
-- Author: Chen
-- Date: 2017-11-28 13:05:30
-- Brief: 
--
local Global = gg.Global

local M = class("PlayerNode", function(chairID)
    
    return cc.CSLoader:createNode(Global:getCsbFile("games/PlayerNode" ..chairID))
end)

--// step1
function M:ctor(chairID)
    self:enableNodeEvents()

    self:procUI()
end

--// ui关联
function M:procUI()
    self.spReady     = self:getChildByName("sp_ready"):hide()
    local nodePlayer  = self:getChildByName("FileNode_Player")
    self.textNickname = nodePlayer:getChildByName("Text_Nickname"):str("1111111")
    self.spAvatar     = nodePlayer:getChildByName("sp_avatar")
end

function M:onGameStart()
    self.spReady:hide()
end

--// 
function M:onHandUp()
    self.spReady:show()
end

--// 填充数据
function M:onFillData(user)
    self:show()
    self.textNickname:setString(user.strNickName)
    if user.gender == 0 then
        self.spAvatar:setSpriteFrame("img_avatar0.png")
    else
        self.spAvatar:setSpriteFrame("img_avatar1.png")
    end
    if user.userStatus == wnet.EUserStatus.EGAME_STATUS_READY then
        self.spReady:show()
    else
        self.spReady:hide()
    end
end

--// 监听视图数据变化事件
function M:onRegisterEventProxy()

end

function M:onEnter()
    --// todo
    --// ...

    

    self:onRegisterEventProxy()
end

function M:onExit()
    --// todo
    --// ...
end

return M