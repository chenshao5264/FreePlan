--
-- Author: Chen
-- Date: 2017-12-19 19:34:21
-- Brief: 
--
local cc = cc
local Global     = gg.Global
local TableModel = gg.TableModel
local ggGlobal   = gg.Global
local ggUIHelper = gg.UIHelper

local M = class("TableComponent", function()
    return cc.CSLoader:createNode(Global:getCsbFile("components/ProjTable"))
end)

--// 静态方法
function M:create(tableNo)
    local ptr = self.new(tableNo)
    return ptr
end

--// step1
function M:ctor(tableNo)
    self.imgTableNoBg = self:getChildByName("Image_TableNo_Bg")
    self.bfTableNo    = self:getChildByName("BitmapFontLabel_TableNo")
    self.imgVS        = self:getChildByName("Image_VSing"):hide()

    self.bfTableNo:setString(tableNo)

    self.imgSeats = {}
    for i = 0, 3 do
        self.imgSeats[i] = self:getChildByName("Image_Seat_" ..i)
        self.imgSeats[i].imgAvatar = self.imgSeats[i]:getChildByName("Image_Avatar"):hide()
        self.imgSeats[i].imgOK     = self.imgSeats[i]:getChildByName("Image_OK"):hide()

        self.imgSeats[i]:onClick_(function(obj)
            ggUIHelper:showOneMsgBox("开局消耗1个钻石")
        end)
    end
end

function M:fillData()
    local userInfos = TableModel:getUserDatas()
    for chairID, userInfo in pairs(userInfos) do
        local imgSeat = self.imgSeats[chairID]
        imgSeat.imgAvatar:loadTexture(ggGlobal:getAvatarImageByGender(userInfo.gender), 1)
        cclog.warn("userInfo.userStatus = " ..userStatus)
    end
end

return M