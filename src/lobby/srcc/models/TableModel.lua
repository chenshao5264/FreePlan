--
-- Author: Chen
-- Date: 2017-11-17 10:40:38
-- Brief: 
--
local BaseModel = require('models.BaseModel')
local Model = class("TableModel", BaseModel)

Model.schema = clone(BaseModel.schema)

Model.schema["tableID"] = {"number", -1}

--// 用户信息数据
Model.schema["userData"]   = {"ctable", {
    chairID     = -1,
    userStatus  = -1,
    gender      = 1,
    strNickName = "",
    userID      = -1,
}}

--// 用户信息数据集合,索引号为chairID
Model.schema["userDatas"] = {"table", {}}

--// userID 对应 chairID
Model.schema["userIDMapChairID"] = {"table", {}}

function Model:ctor()
    self.super.ctor(self, Model.schema)

    --// 需要重写的set get函数
    local override = (function()
        
    end)()
end

--// 获取ChairID
function Model:getChairIDByUserID(userID)
    return self._userIDMapChairID[userID]
end

--// 更改用户状态
function Model:changeUserStatusByUserID(userID, userStatus)
    local chairID = self._userIDMapChairID[userID]
    if not chairID then
        return
    end
    
    if not self._userDatas[chairID] then
        return
    end

    self._userDatas[chairID].userStatus  = userStatus
end

--// 新增用户
function Model:addUserByChairID(chairID, userData)
    if self._userDatas[chairID] then
        return
    end
    self._userDatas[chairID] = {}
    self._userDatas[chairID].userStatus  = userData.userStatus
    self._userDatas[chairID].gender      = userData.gender
    self._userDatas[chairID].strNickName = userData.strNickName
    self._userDatas[chairID].userID      = userData.userID

    self._userIDMapChairID[userData.userID] = chairID
end

--// 移除用户
function Model:removeUserByCharID(chairID)
    self._userDatas[chairID] = nil
end

--// 移除用户
function Model:removeUserByUserID(userID)
    local chairID = self._userIDMapChairID[userID]
    if not chairID then
        return
    end

    self:removeUserByCharID(chairID)
end

return Model