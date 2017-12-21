--
-- Author: Chen
-- Date: 2017-11-17 10:21:03
-- Brief: 
--
local BaseScene = require('scenes.BaseScene')
local M = class("LobbyScene", BaseScene)

function M:ctor(...)
    self.super.ctor(self)
    --// todo
    --// ...

    local lobbyView = myApp:createView("LobbyView")
    self:addChild(lobbyView, 1)

    local lobbyCtrl = myApp:createController("LobbyController")
    self:addChild(lobbyCtrl, 1)

    lobbyCtrl:bindView(lobbyView)
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

    --
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