--
-- Author: Chen
-- Date: 2017-11-17 15:43:16
-- Brief: 
--
local BaseView = require('views.BaseView')
local M = class("LobbyView", BaseView)


function M:ctor()
    self.super.ctor(self, "csb/LobbyLayer.csb")
end

function M:onInit()
    self.super.onInit(self)
end

function M:onEnter()
    self.super.onEnter(self)
end

function M:onExit()
    self.super.onExit(self)
end

return M