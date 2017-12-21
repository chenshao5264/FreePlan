--
-- Author: Chen
-- Date: 2017-11-16 10:37:25
-- Brief: 
--
local BaseScene = require('scenes.BaseScene')
local M = class("LoginScene", BaseScene)


local myApp = myApp

function M:ctor(...)
    self.super.ctor(self)
    --// todo
    --// ...

    local loginCtrl = myApp:createController("LoginController")
    self:addChild(loginCtrl, 1)
end

function M:onInit()
    self.super.onInit(self)
    --// todo
    --// ...
end

function M:onEnter()
    self.super.onEnter(self)
    --// todo
    --// ...
    cc.EventProxy.new(myApp, self)
    
end

function M:onEnterTransitionFinish()
    self.super.onEnterTransitionFinish(self)

    --// todo
    --// ...
end

function M:onExit()
    --// todo
    --// ...

    self.super.onExit(self)
end

function M:onCleanup()
    --// todo
    --// ...

    self.super.onCleanup(self)
end

return M