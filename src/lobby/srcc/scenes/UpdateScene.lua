--
-- Author: Your Name
-- Date: 2017-12-03 21:14:00
--
local UpdateScene = class("UpdateScene", function()
    return cc.Scene:create()
end)


function UpdateScene:ctor()
    self:enableNodeEvents()

end

function UpdateScene:updateOver()
    myApp = require("MyApp").new()
    myApp:run()
end

function UpdateScene:startCheckUpdate()

    local gameHotUpdateHelper
    local function onUpdate(err, ret)
        if err == 0 then
            self:updateOver()
        elseif err == 1 then

        else

        end
        gameHotUpdateHelper:clear()
    end

    gameHotUpdateHelper = require("helpers.GameHotUpdateHelper")
    gameHotUpdateHelper:startUpdate("lobby", onUpdate)
end

function UpdateScene:onEnter()

    self:startCheckUpdate()
end

return UpdateScene