--
-- Author: Chen
-- Date: 2017-09-05 19:52:57
-- Brief: 
--
local BaseScene = require('scenes.BaseScene')
local M = class("SplashScene", BaseScene)

local ClientSocket = gg.ClientSocket

function M:ctor(...)
    self.super.ctor(self)
    --// todo
    --// ...
    self:setName("SplashScene")
    local resNode = myApp:createCsbNode("SplashLayer")
        :addTo(self, 1)

end

function M:onEnter()
    self.super.onEnter(self)
    --// todo
    --// ...
    
end

function M:onEnterTransitionFinish()
    self.super.onEnterTransitionFinish(self)

    --// todo
    --// ...
    cc.EventProxy.new(myApp, self)
        :on("LOGIN_SERVER_CONNECTED", function()
            myApp:enterScene(LOGIN_SCENE)
        end)

    ClientSocket:connectToLogin()
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