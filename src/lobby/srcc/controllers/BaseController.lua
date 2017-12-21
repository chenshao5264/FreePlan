--
-- Author: Chen
-- Date: 2017-08-24 18:06:58
-- Brief: 
--

local BaseController = class("BaseController", function()
    return cc.Node:create()
end)

function BaseController:ctor(csb)
    self:enableNodeEvents()
    
    if csb then
        self.resNode = cc.CSLoader:createNode(csb)
        self:addChild(self.resNode, 1)
    end

    self:onRelateViewElements()
end

function BaseController:onEnterTransitionFinish()
    if self.onEnterAnimation then
        self:onEnterAnimation()
    end
end

function BaseController:onEnter()
    self:onRegisterEventProxy()
    self:onRegisterButtonClickEvent()
end

function BaseController:onExit()

end

return BaseController