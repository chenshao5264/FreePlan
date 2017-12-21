--
-- Author: Chen
-- Date: 2017-08-24 14:03:03
-- Brief: 
--

local BaseView = class("BaseView", function()
    return cc.Node:create()
end)

function BaseView:ctor(csb)
    self:enableNodeEvents()
    self:onInit()

    if csb then
        self.resNode = cc.CSLoader:createNode(csb)
        self:addChild(self.resNode, 1)
    end
end

function BaseView:onInit()
    self.resNode = nil --// csb根节点
end


function BaseView:onEnter()
end

function BaseView:onExit()
end

return BaseView