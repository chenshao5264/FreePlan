--
-- Author: Chen
-- Date: 2017-12-05 10:42:20
-- Brief: 
--

local AppDelegate = {}

function AppDelegate:runApp()
    --local scene = require("scenes.UpdateScene").new()
    --display.runScene(scene)
    
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
    
    --// DBUEG
    myApp = require("MyApp").new()
    myApp:run()

    --myApp:launchGame(LAUNCH_GAME)
end

return AppDelegate
