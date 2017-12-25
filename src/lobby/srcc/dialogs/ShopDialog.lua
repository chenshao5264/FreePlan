--
-- Author: Chen
-- Date: 2017-12-15 19:04:53
-- Brief: 
--

local math_floor = math.floor

local gg = gg
local Global         = gg.Global
local ggDialog       = gg.Dialog
local ggUtility      = gg.Utility
local ggCurrencyType = gg.CurrencyType
local ggUIHelper     = gg.UIHelper

local M = class(ggDialog.ShopDialog, function()
    return cc.CSLoader:createNode(Global:getCsbFile("dialogs/ShopDialog"))
end)

--// step1
function M:ctor(defaultPage)

    self._isReady     = false
    self._buyType     = 0
    self._buyIndex    = 0
    self._buyQuantity = 0
    self._defaultPage = defaultPage or ggCurrencyType.DIAMOND

    local btnClose = self:getChildByName("Button_Close")
    btnClose:onClick_(function(obj)
        ggUIHelper:closeDialog(self.__cname)
    end)

    self.btnDiamond = self:getChildByName("Button_Diamond")
    self.btnBean    = self:getChildByName("Button_Bean")
    self.btnDiamond:ignoreContentAdaptWithSize(true)
    self.btnBean:ignoreContentAdaptWithSize(true)

    self.btnDiamond:onClickWithColor(function()
        if not self._isReady then
            return
        end
        self:turn2OnePage(ggCurrencyType.DIAMOND, true)
    end)

    self.btnBean:onClickWithColor(function()
        if not self._isReady then
            return
        end
        self:turn2OnePage(ggCurrencyType.BEAN, true)
    end)

    self:getChildByName("Image_Goods_Item"):hide()

    if self._defaultPage == ggCurrencyType.BEAN then
        self.btnDiamond:setEnabled(true)
        self.btnDiamond:setBright(true)
        self.btnBean:setEnabled(false)
        self.btnBean:setBright(false)
    else
        self.btnDiamond:setEnabled(false)
        self.btnDiamond:setBright(false)
        self.btnBean:setEnabled(true)
        self.btnBean:setBright(true)
    end

    cc.EventProxy.new(myApp, self)
        :on("evt_PL_PHONE_IOS_RECHARGEINFO_ACK_P", function(evt)
            self:onFillData()
        end)
        :on("evt_PL_PHONE_IOS_RECHARGE_ACK_P", function(evt)
            ggUIHelper:stopWaitting()
            local data = evt.data
            if data.nRet == 0 then

                local item = {}
                if self._buyType == ggCurrencyType.BEAN then
                    item.res = "shop_icon_bean_" .. self._buyIndex ..".png"
                    item.str = ggUtility.getShortBean(self._buyQuantity)
                else
                    item.res = "shop_icon_diamond_" .. self._buyIndex ..".png"
                    item.str = self._buyQuantity
                end
                
                ggUIHelper:showGains({item})
            end
        end)
end

--// 关闭弹窗回调，可在外部重写
function M:onClosedCompleted()

end

function M:onOpenCompleted()
    if _DEBUG_SHOP then    
        local infoString = cc.FileUtils:getInstance():getStringFromFile("IosRechargeInfo.json")
        local json = require("framework.json")
        local info = json.decode(infoString)
        gg.AppModel:setShopGoodsInfo(info)
        self:onFillData()
        return
    end
    if #gg.AppModel:getShopGoodsInfo() > 0 then
        self:onFillData()
    else
        ggUIHelper:showWaitting("地精正在进货")
        gg.RequestManager:reqRechargeInfo()
    end
end

function M:onFillData()
    ggUIHelper:stopWaitting()

    self._isReady = true

    local goods = gg.AppModel:getShopGoodsInfo()
    
    local imgGoodsItem = self:getChildByName("Image_Goods_Item")
    self.nodeGoods = {}
    for i = 1, #goods do
        local goodsCount = 0
        local items = {}
        local infos = goods[i]
        for j = 1, #infos do
            goodsCount = goodsCount + 1
            local info = infos[j]
            local imgItem = imgGoodsItem:clone():show()
            imgItem:setCascadeOpacityEnabled(true)
            imgItem.productId = info.productId

            imgItem.idx      = j
            imgItem.quantity = info.productNum + info.productExtra
            imgItem.type     = i

            imgItem:onClick_(handler(self, self.onBuyClick))
            items[#items + 1] = imgItem
            
            local imgIcon = imgItem:getChildByName("Image_Icon")
            imgIcon:ignoreContentAdaptWithSize(true)  
            imgItem:getChildByName("BitmapFontLabel_Price"):setString(info.productPrice)
            
            local imgCurrencyType = imgItem:getChildByName("Image_Currency_Type")
            imgCurrencyType:ignoreContentAdaptWithSize(true)
            if i == ggCurrencyType.BEAN then
                imgItem:getChildByName("BitmapFontLabel_Quantity"):setString(ggUtility.getShortBean(info.productNum) .."d")
                imgIcon:loadTexture("shop_icon_bean_" .. j ..".png", 1)
                imgCurrencyType:loadTexture("shop_icon_currency_type_diamond.png", 1)
                if info.productExtra == 0 then
                    imgItem:getChildByName("Image_Extra_Bg"):hide()
                    imgItem:getChildByName("BitmapFontLabel_Extra"):hide()
                else
                    imgItem:getChildByName("BitmapFontLabel_Extra"):setString(ggUtility.getShortBean(info.productExtra) .."d")
                end
            else
                imgItem:getChildByName("BitmapFontLabel_Quantity"):setString(ggUtility.getShortBean(info.productNum) .."z")
                imgIcon:loadTexture("shop_icon_diamond_" .. j ..".png", 1)
                imgCurrencyType:loadTexture("shop_icon_currency_type_rmb.png", 1)
                if info.productExtra == 0 then
                    imgItem:getChildByName("Image_Extra_Bg"):hide()
                    imgItem:getChildByName("BitmapFontLabel_Extra"):hide()
                else
                    imgItem:getChildByName("BitmapFontLabel_Extra"):setString(ggUtility.getShortBean(info.productExtra) .."z")
                end
            end
        end

        if #items > 0 then
            self.nodeGoods[i] = cc.GridNode:create(items, {totalCount = goodsCount, 
                                                            colCount = 4,
                                                            rowMargin = 20,
                                                            colMargin = 20
                                                            })
                :posY(-65)
                :addTo(self, 1)
            self.nodeGoods[i]:setCascadeOpacityEnabled(true)
        end
    end
    self:setDefaultPage(self._defaultPage)
end

--// 购买按钮事件回调
function M:onBuyClick(obj)
    cclog.debug("will buy " ..obj.productId)
    self._buyType     = obj.type
    self._buyIndex    = obj.idx
    self._buyQuantity = obj.quantity

    ggUIHelper:showWaitting("地精正在出货")
    gg.RequestManager:reqRecharge(obj.productId)
end

--// 设置开启后的默认页面
function M:setDefaultPage(page)
    self:turn2OnePage(page, true)
end

-- /**
--  * @brief  切换到某一页
--  * @param  [page]    对应PlayType
--  * @param  [isAni]   是否有动画
--  * @return
--  */
function M:turn2OnePage(page, isAni)

    local isBean = ggCurrencyType.BEAN == page

    self.btnDiamond:setEnabled(isBean)
    self.btnDiamond:setBright(isBean)
    self.btnBean:setEnabled(not isBean)
    self.btnBean:setBright(not isBean)

    self.nodeGoods[ggCurrencyType.BEAN]:setVisible(isBean)
    self.nodeGoods[ggCurrencyType.DIAMOND]:setVisible(not isBean)

    if isAni then
        local items = self.nodeGoods[page]:getChildren()
        for i = 1, #items do
            local imgItem = items[i]
            imgItem:setScale(GOLD_TIME)
            local act1 = cc.ScaleTo:create(GOLD_HALF_TIME, 1)
            imgItem:stopAllActions()
            imgItem:runAction(cc.EaseBackOut:create(act1))
        end
    end
end

return M