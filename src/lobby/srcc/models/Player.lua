--
-- Author: Chen
-- Date: 2017-11-16 14:28:36
-- Brief: 
--

local BaseModel = require('models.BaseModel')
local Model = class("Player", BaseModel)

Model.schema = clone(BaseModel.schema)

Model.schema["account"]         = {"string", ""}
Model.schema["password"]        = {"string", ""}

Model.schema["userID"]          = {"number", -1}
Model.schema["gender"]          = {"number", 1}
Model.schema["nickname"]        = {"string", ""}
Model.schema["beanCurrency"]    = {"number", 0}     --// 游戏豆
Model.schema["diamondCurrency"] = {"number", 0}     --// 钻石

Model.schema["selectedTableID"] = {"number", 0}
Model.schema["selectedChairID"] = {"number", 0}


function Model:ctor()
    self.super.ctor(self, Model.schema)

    --// 需要重写的set get函数
    local override = (function()
        
    end)()
end

--// 设置用户的一些基础信息
function Model:setPlayerBasicInfo(lobbyUser)
    self._gender          = lobbyUser.gender
    self._nickname        = lobbyUser.strNickNamebuf
    self._beanCurrency    = lobbyUser.gameCurrency.l
    self._diamondCurrency = lobbyUser.goldCurrency
end

return Model