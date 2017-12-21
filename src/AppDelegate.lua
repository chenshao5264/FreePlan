--
-- Author: Chen
-- Date: 2017-12-05 10:42:20
-- Brief: 
--

--// 启动app
function runApp()
    --local scene = require("scenes.UpdateScene").new()
    --display.runScene(scene)
    
    
    --// DBUEG
    myApp = require("MyApp").new()
    myApp:run()

    --myApp:launchGame(LAUNCH_GAME)
end