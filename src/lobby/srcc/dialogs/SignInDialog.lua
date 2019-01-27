--
-- Author: Chen
-- Date: 2017-12-22 11:21:22
-- Brief: 
--

local cc = cc
local gg = gg

local Global     = gg.Global
local ggUIHelper = gg.UIHelper
local ggUtility  = gg.Utility

local M = class("SignInDialog", function()
    return cc.CSLoader:createNode(Global:getCsbFile("dialogs/SignInDialog"))
end)

--// step1
function M:ctor()
    self:enableNodeEvents()

    local btnClose = self:getChildByName("Button_Close")
    btnClose:onClick_(function(obj)
        ggUIHelper:closeDialog(self.__cname)
    end)

    local btnSignIn = self:getChildByName("Button_SignIn")
    btnSignIn:onClick_(function(obj)
        -- gg.AppModel:getSignInfo().signInDay = gg.AppModel:getSignInfo().signInDay + 1
        -- myApp:emit("evt_PL_PHONE_LC_SIGNIN_ACK_P")

        gg.RequestManager:reqSignIn()
    end)
    self.btnSignIn = btnSignIn

    if gg.AppModel:isSignIn() then
        btnSignIn:setBright(false)
        btnSignIn:setEnabled(false)
    end

    self.imgItemDays = {}
    for i = 1, 5 do
        local imgItemDay = self:getChildByName("Image_Item_Day_" ..i):hide()
        imgItemDay.imgIcon  = imgItemDay:getChildByName("Image_Icon")
        imgItemDay.textDay  = imgItemDay:getChildByName("Text_Day")
        imgItemDay.bfAmount = imgItemDay:getChildByName("BitmapFontLabel_Amount")
        imgItemDay.imgShade = imgItemDay:getChildByName("Image_Shade")
        imgItemDay.imgMark  = imgItemDay:getChildByName("Image_Mark")
        imgItemDay.imgFrame = imgItemDay:getChildByName("Image_Frame")
        imgItemDay.imgIcon:ignoreContentAdaptWithSize(true)
        self.imgItemDays[i] = imgItemDay
    end    

    self:fillData()
end


function M:onOpenCompleted()
    
end

function M:fillData()
    local Days = {"第一天", "第二天", "第三天", "第四天", "第五天+"}
    local CurrencyType_DIAMOND = gg.CurrencyType.DIAMOND
    local infos = gg.AppModel:getSignInfo()
  
    for i = 1, #infos do
        local info = infos[i]
        local imgItemDay = self.imgItemDays[i]:show()
        if info.currencyType == CurrencyType_DIAMOND then
            imgItemDay.imgIcon:loadTexture("icon_item_2.png", 1)

            imgItemDay.bfAmount:setString(ggUtility.getShortBean(info.currencyAmount) .."z")
        else
            imgItemDay.imgIcon:loadTexture("icon_item_1.png", 1)
            imgItemDay.bfAmount:setString(ggUtility.getShortBean(info.currencyAmount) .."d")
        end
        self.imgItemDays[i].textDay:setString(Days[i])
        if i > infos.signInDay then
            imgItemDay.imgShade:hide()
            imgItemDay.imgMark:hide()
            imgItemDay.imgFrame:hide()
        end
        if not infos.bSignIn then
            if i == #infos then
                imgItemDay.imgShade:hide()
                imgItemDay.imgMark:hide()
                imgItemDay.imgFrame:hide()
            end
        end
    end
end

--// 签到结果
function M:onSignResult()
    self.btnSignIn:setBright(false)
    self.btnSignIn:setEnabled(false)

    self:startCoinsDropAnim()

    local signInfo = gg.AppModel:getSignInfo()
    local idx = signInfo.signInDay
    if idx > 5 then
        idx = 5
    end

    self:playSignIngAction(idx)
    self:showGains(signInfo[idx])
end

function M:showGains(info)
    local item = {}
    if info.currencyType == gg.CurrencyType.BEAN then
        item.res = "icon_item_1.png"
        item.str = ggUtility.getShortBean(info.currencyAmount) .."d"
    else
        item.res = "icon_item_2.png"
        item.str = info.currencyAmount .."z"
    end         
    ggUIHelper:showGains({item})
end

function M:startCoinsDropAnim()
    math.randomseed(os.time())
    local math_random = math.random
    local CoinAnim = require("helpers.DropCoinNode")
    for i = 1, 120 do
        local x = math_random(1, 1136)
        local coin = CoinAnim.new(x, 960, 40, 0.2, 300, 0.7)
        ggUIHelper:getRoot():addChild(coin, 50)
    end
end

function M:playSignIngAction(idx)
    
    local imgItemDay = self.imgItemDays[idx]
    imgItemDay.imgShade:show()
    imgItemDay.imgMark:show()
    imgItemDay.imgFrame:show()

end

--// 监听视图数据变化事件
function M:onRegisterEventProxy()
    cc.EventProxy.new(myApp, self)
        :on("evt_PL_PHONE_LC_SIGNIN_ACK_P", function(evt)
            self:onSignResult()
        end)
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