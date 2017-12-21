--
-- Author: Chen
-- Date: 2017-12-05 10:42:20
-- Brief: 
--

local AppDelegate = {}

function AppDelegate:runApp()
    --local scene = require("scenes.UpdateScene").new()
    --display.runScene(scene)
    
    
    --// DBUEG
    myApp = require("MyApp").new()
    myApp:run()

    --myApp:launchGame(LAUNCH_GAME)
end

return AppDelegate
