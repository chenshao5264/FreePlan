--
-- Author: Chen
-- Date: 2017-11-17 14:30:36
-- Brief: 
--

local BaseView = require('views.BaseView')
local M = class("LoginView", BaseView)


function M:ctor()
    self.super.ctor(self, "csb/LoginLayer.csb")

    local imgInput1 = self.resNode:getChildByName("Image_Input_Bg_1")
    local editboxAccount = ccui.EditBox:create(cc.size(300, 40), " ")
    editboxAccount:addTo(imgInput1:getParent(), 1)
    editboxAccount:setPosition(imgInput1:getPosition())
    editboxAccount:setPlaceHolder("请输入帐号")
    editboxAccount:setPlaceholderFontColor(cc.c4b(100, 65, 61, 100))
    editboxAccount:setFontColor(cc.c4b(100, 65, 61, 255))
    editboxAccount:setInputMode(4)
    self.editboxAccount = editboxAccount

    local imgInput2 = self.resNode:getChildByName("Image_Input_Bg_2")
    local editboxPwd = ccui.EditBox:create(cc.size(300, 40), " ")
    editboxPwd:addTo(imgInput2:getParent(), 1)
    editboxPwd:setPosition(imgInput2:getPosition())
    editboxPwd:setPlaceHolder("请输入密码")
    editboxPwd:setPlaceholderFontColor(cc.c4b(100, 65, 61, 100))
    editboxPwd:setFontColor(cc.c4b(100, 65, 61, 255))
    editboxPwd:setInputFlag(0)
    editboxPwd:setInputMode(4)
    self.editboxPwd = editboxPwd
end

function M:onInit()
    self.super.onInit(self)
end

function M:onEnter()
    self.super.onEnter(self)
end

function M:onExit()
    self.super.onExit(self)
end

return M
