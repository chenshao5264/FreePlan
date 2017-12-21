--
-- Author: Chen
-- Date: 2017-09-08 11:53:49
-- Brief: 
--


local BaseModel = require('models.BaseModel')
local Model = class("AppModel", BaseModel)


local crypto = require("framework.crypto")

Model.schema = clone(BaseModel.schema)

Model.schema["isLoginConnected"] = {"bool", false}
Model.schema["lobbyPassCode"]    = {"string", ""}
Model.schema["isBrokenConnect"]  = {"bool", false} --// 断线重连标志
Model.schema["shopGooldsInfo"]   = {"table", {}}  --// 商店物品信息

function Model:ctor()
    self.super.ctor(self, Model.schema)

    --// 需要重写的set get函数
    local override = (function()
        
    end)()
end

--// 保存账号密码信息
function Model:saveAccount()
    cc.UserDefault:getInstance():setStringForKey("account", gg.Player:getAccount())
    cc.UserDefault:getInstance():setStringForKey("password", gg.Player:getPassword())
end

--// 读取账号密码信息
function Model:readAccount()
    local account =  cc.UserDefault:getInstance():getStringForKey("account", "")
    local password = cc.UserDefault:getInstance():getStringForKey("password", "")

    gg.Player:setAccount(account)
    gg.Player:setPassword(password)
    return account, password
end

--// 设置商店的商品信息
function Model:setShopGoodsInfo(infos)

    self._shopGooldsInfo = {}
    self._shopGooldsInfo[1] = {}
    self._shopGooldsInfo[2] = {}
    for i = 1, #infos do
        local info = infos[i]
        local tmp = {}
        tmp.productId    = info.productId
        tmp.productPrice = info.productPrice
        tmp.productNum   = info.productNum
        tmp.productExtra = info.productExtra

        self._shopGooldsInfo[info.productType][#self._shopGooldsInfo[info.productType] + 1] = tmp
    end
end

function Model:getShopGoodsInfo()
    return self._shopGooldsInfo
end

return Model
