--
-- Author: Chen
-- Date: 2017-11-17 15:16:49
-- Brief: 
--
local BaseController = require('controllers.BaseController')
local M = class("LoginController", BaseController)



local string_len = string.len

local gg = gg
local ggDialog = gg.Dialog
local UIHelper = gg.UIHelper
local AppModel = gg.AppModel
local Player   = gg.Player

--// step1
function M:ctor()
    self.super.ctor(self)

end

--// step2
function M:onInit()
    self.super.onInit(self)
    --// todo
    --// ...
end

--// step3_1
--// 关联画布上的元素
function M:onRelateViewElements()
    self.editboxAccount = self.view.editboxAccount  
    self.editboxPwd     = self.view.editboxPwd

    self.editboxAccount:registerScriptEditBoxHandler(function(name, sender)
        if name == "began" then

        elseif name == "changed" then
            self.editboxPwd:setString("")
            Player:setAccount("")
            Player:setPassword("")
        elseif name == "return" then
            --// 焦点定到下一个editbox
            sender:closeKeyboard()
            self.editboxPwd:touchDownAction(nil, 2)
        end
    end)

    self.editboxPwd:registerScriptEditBoxHandler(function(name, sender)
        if name == "began" then
            self.editboxPwd:setString("")     
            Player:setAccount("")
            Player:setPassword("")
        elseif name == "return" then
            
        end
    end)

    self.btnLogin    = self.resNode:getChildByName("Button_Login")
    self.btnRegister = self.resNode:getChildByName("Button_Register")


    local account, password = AppModel:readAccount()
    if account ~= "" and password ~= "" then
        self.editboxAccount:setString(account)
        self.editboxPwd:setString("**********")

        gg.UIHelper:showWaitting("正在登录中")
        if _DEBUG_QUICK_LOGIN then
            gg.RequestManager:reqLoginAccount(account, password, true)
            return
        end
        self:performWithDelay(function()
            gg.RequestManager:reqLoginAccount(account, password, true)
        end, 1)
    end
end

--// step3_2
--// 注册视图上的交互事件
function M:onRegisterButtonClickEvent()
    self.btnLogin:onClick_(function(obj)

        local strAccount  = self.editboxAccount:getString()
        if string_len(strAccount) == 0 then
            UIHelper:showToast("账号不能为空！")
            return
        end
        local strPwd = self.editboxPwd:getString()
        if string_len(strPwd) == 0 then
            UIHelper:showToast("密码不能为空！")
            return
        end

        obj:shortDisable()
        gg.UIHelper:showWaitting()
        if string_len(Player:getAccount()) > 0 and string_len(Player:getPassword()) > 0 then
            gg.RequestManager:reqLoginAccount(Player:getAccount(), Player:getPassword(), true)
        else
            gg.RequestManager:reqLoginAccount(UTF82Mutiple(strAccount), strPwd, false)            
        end
    end)

    self.btnRegister:onClick_(function(obj)
        UIHelper:showDialog(ggDialog.RegisterDialog)
    end)
end

--// step4
--// 根据model数据填充ui
function M:onFillData2UI()

end

function M:onRegisterResult(ret)
    UIHelper:stopWaitting()

    if ret == 0 then
        UIHelper:closeDialog(ggDialog.RegisterDialog)
        UIHelper:showToast("注册成功！")

        self.editboxAccount:setString(Player:getAccount())
        self.editboxPwd:setString("**********")
    elseif ret == 2 then
        UIHelper:showToast("账号已被使用!")
    elseif ret == 3 then
        UIHelper:showToast("昵称已被使用!")
    elseif ret == 4 then
        UIHelper:showToast("时限未到!")
    else
        UIHelper:showOneMsgBox("未知错误！")
    end
end

function M:onLoginResult(ret)
    UIHelper:stopWaitting()

    --// ret == 0 表示登录成功，不展示UI
    if ret ~= 0 then
        UIHelper:showToast("账号或者密码错误！")
    end
end

--// 监听视图数据变化事件
function M:onRegisterEventProxy()
    cc.EventProxy.new(myApp, self)
        :on("evt_LC_PHONECODE_REG_ACK_P", function(evt)
            local data = evt.data
            self:onRegisterResult(data.ret)
        end)
        :on("evt_PL_PHONE_LC_LOGIN_ACK_P", function(evt)
            local data = evt.data
            self:onLoginResult(data.ret)
        end)
end

--[[
function M:onChangeNickname()

end
--]]

function M:onEnter()
    self.super.onEnter(self)
    --// todo
    --// ...


end

function M:onExit()
    --// todo
    --// ...
    self.super.onExit(self)
end

return M