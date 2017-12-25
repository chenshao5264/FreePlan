--
-- Author: Chen
-- Date: 2017-12-25 11:20:38
-- Brief: 
--
local cc = cc
local gg = gg
local ggGlobal   = gg.Global
local ggUIHelper = gg.UIHelper
local ggUtility  = gg.Utility
local ggDialog   = gg.Dialog

local M = class("UserCenterDialog", function()
    return cc.CSLoader:createNode(ggGlobal:getCsbFile("dialogs/UserCenterDialog"))
end)

--// step1
function M:ctor()
    local btnClose = self:getChildByName("Button_Close")
    btnClose:onClick_(function(obj)
        ggUIHelper:closeDialog(self.__cname)
    end)

    local Player = gg.Player

    self.textID            = self:getChildByName("Text_ID")
    self.textNickname      = self:getChildByName("Text_Nickname")
    self.textSex           = self:getChildByName("Text_Sex")
    self.textDiamondAmount = self:getChildByName("Image_Diamond"):getChildByName("Text_Amount")
    self.textBeanAmount    = self:getChildByName("Image_Bean"):getChildByName("Text_Amount")
    self.imgAvatar         = self:getChildByName("Image_Avatar")

    self.textID:setString(string.format("ID:%06d", Player:getUserID()))
    self.textNickname:setString(Player:getNickname())
    self.textSex:setString(Player:getGender() == 0 and "男" or "女")
    self.textBeanAmount:setString(ggUtility.getShortBean(Player:getBeanCurrency()))
    self.textDiamondAmount:setString(Player:getDiamondCurrency())
    self.imgAvatar:loadTexture(ggGlobal:getAvatarImageByGender(Player:getGender(), true), 1)

    local btnChangeAccount = self:getChildByName("Button_Change_Account")
        :onClick_(function(obj)
            ggUIHelper:showTwoMsgBox("是否切换帐号?", function(ret)
                if ret == "ok" then
                    gg.ClientSocket:disconnectFromLobby()
                    gg.AppModel:setIsAutoLogin(false)
                    myApp:enterScene(SPLASH_SCENE, true)
                end
            end)
        end)

    local btnBuyDiamond = self:getChildByName("Image_Diamond"):getChildByName("Button_Plus")
    local btnBuyBean = self:getChildByName("Image_Bean"):getChildByName("Button_Plus")
    btnBuyDiamond.currencyType = gg.CurrencyType.DIAMOND
    btnBuyBean.currencyType    = gg.CurrencyType.BEAN

    local function onClickBuy(obj)
        ggUIHelper:closeDialog(self.__cname)
        ggUIHelper:showDialog(ggDialog.ShopDialog, obj.currencyType)
        -- local dialogNode = ggUIHelper:showDialog(ggDialog.ShopDialog, obj.currencyType)
        -- dialogNode.onClosedCompleted = function(self)
        --     ggUIHelper:showDialog(ggDialog.UserCenterDialog)
        -- end
    end

    btnBuyDiamond:onClick_(onClickBuy)
    btnBuyBean:onClick_(onClickBuy)
end

--// ui关联
function M:procUI()
    
end



return M