--
-- Author: Chen
-- Date: 2017-08-24 18:06:58
-- Brief: 
--

local BaseController = class("BaseController", function()
    return cc.Node:create()
end)

function BaseController:ctor()
    self:enableNodeEvents()
    self:onInit()
end

function BaseController:showShade(showTime)
    if not self.layShade then
        self.layShade = ccui.Layout:create()
        self.layShade:setPosition(0, 0)
        self.layShade:setContentSize(cc.size(display.width, display.height))
        self.layShade:setTouchEnabled(true)
        --self.layShade:setBackGroundColorType(1)
        --self.layShade:setBackGroundColor(cc.c3b(255, 0, 0))
        self._view:addChild(self.layShade, 0xffffff)
    end
    if showTime then
        self.layShade:performWithDelay(function(obj)
            obj:hide()
        end, showTime)
    end

    self.layShade:show()
end

function BaseController:hideShade()
    self.layShade:hide()
end

-- /**
--  * 绑定控制器对应的视图
--  */
function BaseController:bindView(view)
    self.view    = view
    self.resNode = view.resNode

    self:onRelateViewElements()
end

function BaseController:onInit()
    self._models = {}
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