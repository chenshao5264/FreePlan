--
-- Author: Chen
-- Date: 2017-11-23 14:21:57
-- Brief: 
--

local Global = gg.Global

local M = class("MahjWallNode", function()
    return cc.CSLoader:createNode(Global:getCsbFile("MahjWallNode"))
end)


--// step1
function M:ctor()
    self:procUI()
end

--// ui关联
function M:procUI()
    self.textMahjRemain = self:getChildByName("Text_Remain")
    self.spSmallDice1   = self:getChildByName("diceSmall_yxn_pic_1")
    self.spSmallDice2   = self:getChildByName("diceSmall_yxn_pic_2")
end

--// 色子
function M:loadSmallDicesTexture(points)
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frame1 = spriteFrameCache:getSpriteFrame("mj_diceSmall_yxn_pic_" ..points[1] ..".png")
    if frame1 then
        self.spSmallDice1:setSpriteFrame(frame1)
    end
    local frame2 = spriteFrameCache:getSpriteFrame("mj_diceSmall_yxn_pic_" ..points[2] ..".png")
    if frame2 then
        self.spSmallDice2:setSpriteFrame(frame2)
    end
end

--//
function M:updateMahjRemain(remain)
    self.textMahjRemain:setString(remain)
end


return M