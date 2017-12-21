--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--
local Layer = class("FunctionLayer", function()
    return cc.Layer:create()
end)

function Layer:ctor()
    self:enableNodeEvents()
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")
end

return Layer