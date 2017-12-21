--
-- Author: Chen
-- Date: 2017-12-01 14:16:45
-- Brief: 
--
local gg = gg
local Global   = gg.Global
local ggDialog = gg.Dialog

local M = class(ggDialog.RegisterDialog, function()
    return cc.CSLoader:createNode(Global:getCsbFile("dialogs/RegisterDialog"))
end)

local string_len = string.len

--// step1
function M:ctor()
    local btnClose = self:getChildByName("Button_Close")
    btnClose:onClick_(function(obj)
        gg.UIHelper:closeDialog(self.__cname)
    end)

    --// 帐号
    local imgInput1 = self:getChildByName("Image_Input_1")
    local editboxAccount = ccui.EditBox:create(cc.size(250, 40), " ")
    editboxAccount:addTo(imgInput1:getParent(), 1)
    editboxAccount:setPosition(imgInput1:getPosition())
    editboxAccount:setPlaceHolder("请输入帐号")
    editboxAccount:setPlaceholderFontColor(cc.c4b(100, 65, 61, 100))
    editboxAccount:setFontColor(cc.c4b(100, 65, 61, 255))
    editboxAccount:setCascadeOpacityEnabled(true)
    editboxAccount:setInputMode(4)
    self.editboxAccount = editboxAccount

    --// 昵称
    local imgInput2 = self:getChildByName("Image_Input_2")
    local editboxNickname = ccui.EditBox:create(cc.size(250, 40), " ")
    editboxNickname:addTo(imgInput2:getParent(), 1)
    editboxNickname:setPosition(imgInput2:getPosition())
    editboxNickname:setPlaceHolder("请输入昵称")
    editboxNickname:setPlaceholderFontColor(cc.c4b(100, 65, 61, 100))
    editboxNickname:setFontColor(cc.c4b(100, 65, 61, 255))
    editboxNickname:setCascadeOpacityEnabled(true)
    editboxNickname:setInputMode(4)
    self.editboxNickname = editboxNickname

    --// 密码
    local imgInput3 = self:getChildByName("Image_Input_3")
    local editboxPwd= ccui.EditBox:create(cc.size(250, 40), " ")
    editboxPwd:addTo(imgInput3:getParent(), 1)
    editboxPwd:setPosition(imgInput3:getPosition())
    editboxPwd:setPlaceHolder("请输入密码")
    editboxPwd:setPlaceholderFontColor(cc.c4b(100, 65, 61, 100))
    editboxPwd:setFontColor(cc.c4b(100, 65, 61, 255))
    editboxPwd:setCascadeOpacityEnabled(true)
    editboxPwd:setInputMode(4)
    self.editboxPwd = editboxPwd

    self.editboxAccount:registerScriptEditBoxHandler(function(name, sender)
        if name == "return" then
            --// 焦点定到下一个editbox
            sender:closeKeyboard()
            self.editboxNickname:touchDownAction(nil, 2)
        end
    end)
    self.editboxNickname:registerScriptEditBoxHandler(function(name, sender)
        if name == "return" then
            --// 焦点定到下一个editbox
            sender:closeKeyboard()
            self.editboxPwd:touchDownAction(nil, 2)
        end
    end)

    local btnOK = self:getChildByName("Button_OK")
        :onClick_(function(obj)

        if _DEBUG_Register then
            local strAccount  = _DEBUG_Register_Account
            local strNickname = _DEBUG_Register_Nickname
            local strPwd      = _DEBUG_Register_Pwd
            local mutiplyAccount  = UTF82Mutiple(strAccount)
            local mutiplyNickname = UTF82Mutiple(strNickname)
            obj:shortDisable()
            gg.UIHelper:showWaitting()
            gg.RequestManager:reqRegister(mutiplyAccount, mutiplyNickname, strPwd)
            return
        end

        local strAccount  = editboxAccount:getString()
        local mutiplyAccount  = UTF82Mutiple(strAccount)
        if string_len(mutiplyAccount) < 6 or string_len(mutiplyAccount) > 16 then
            gg.UIHelper:showToast("帐号长度不符合！")
            return
        end

        local strNickname = editboxNickname:getString()
        local mutiplyNickname = UTF82Mutiple(strNickname)
        if string_len(mutiplyNickname) < 6 or string_len(mutiplyNickname) > 16 then
            gg.UIHelper:showToast("昵称长度不符合！")
            return
        end

        local strPwd  = editboxPwd:getString()
        local utility = gg.Utility
        if utility.isNumberOnly(strPwd) or utility.isLetterOnly(strPwd) then
            gg.UIHelper:showToast("密码格式不符合！")
            return
        end

        obj:shortDisable()
        gg.UIHelper:showWaitting()
        gg.RequestManager:reqRegister(mutiplyAccount, mutiplyNickname, strPwd)
    end)  
end

return M