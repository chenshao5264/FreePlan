--
-- Author: Chen
-- Date: 2017-12-19 19:57:44
-- Brief: 
--

local gg = gg

local BaseModel = require('models.BaseModel')
local Model = class("RoomModel", BaseModel)

Model.schema = clone(BaseModel.schema)

-- user = {
--     chairID     = -1,
--     userStatus  = -1,
--     gender      = 1,
--     strNickName = "",
--     userID      = -1,
-- }

--// {tableno: {chairID: user}}
Model.schema["users"] = {"table", {}}
--// 房间ID
Model.schema["roomID"] = {"number", 0}
--// 房间的桌子数
Model.schema["tableAmount"] = {"number", 0}

function Model:ctor()
    self.super.ctor(self, Model.schema)

end

--// 拷贝玩家一些有用的数据
local function copyUserData(user)
    local tuser = {}
    tuser.userStatus  = user.userStatus
    tuser.gender      = user.gender
    tuser.strNickName = user.strNickName
    tuser.userID      = user.userID
    return tuser
end

-- /**
--  * @brief  设置桌子上的玩家，在初始化的时候调用
--  * @param  [tableNo] 桌子号
--  * @param  [tableStatus] 桌子状态 
--  * @param  [chairID] 椅子号
--  */
function Model:initTables(tableNo, tableStatus, chairID, user)
    self._users[tableNo]          = {}
    self._users[tableNo].status   = tableStatus
    self._users[tableNo][chairID] = copyUserData(user)
end

-- /**
--  * @brief  更新桌子上的玩家
--  * @param  [tableNo] 桌子号
--  * @param  [action] 玩家行为 gg.UserAction
--  * @param  [chairID] 椅子号
--  */
function Model:updateTableUser(tableNo, action, chairID, user)
    if action == gg.UserAction.ENTER_TABLE then
        if not self._users[tableNo] then
            self._users[tableNo] = {}
        end
        self._users[tableNo][chairID] = copyUserData(user)
    else
        self._users[tableNo][chairID] = {}
    end
end

return Model