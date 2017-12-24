local MyApp = class("MyApp")

local string_format = string.format

local cc = cc
local display = display

function MyApp:ctor()
    require "ccEx.init"
    require "lobby.srcc.init"

    cc(self):addComponent("ccEx.cc.components.behavior.EventProtocol"):exportMethods()


    display.loadSpriteFrames("images/share/share_atlas.plist", "images/share/share_atlas.png")
    display.loadSpriteFrames("images/game/game_atlas.plist", "images/game/game_atlas.png")
    display.loadSpriteFrames("images/shop/shop_atlas.plist", "images/shop/shop_atlas.png")
    display.loadSpriteFrames("images/signin/signin_atlas.plist", "images/signin/signin_atlas.png")
    
    --// 小游戏实例
    game = nil
end

-- /**
--  * 是否是android平台
--  */
function MyApp:isAndroid()
    local platform = cc.Application:getInstance():getTargetPlatform()
    return platform == cc.PLATFORM_OS_ANDROID
end

-- /**
--  * 是否是ios平台
--  */
function MyApp:isIos()
    local platform = cc.Application:getInstance():getTargetPlatform()
    return (platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD)
end

function MyApp:setRunningScene(scene)
    self._runningScene = scene
end

function MyApp:getRunningScene()
    return self._runningScene
end

function MyApp:run()
    local scene = require("scenes." ..LAUNCH_SCENE).new()
    display.runScene(scene)
end

--// 启动小游戏
function MyApp:launchGame(name)
    gg.ClientSocket:setIsQueuePause(true)
    game = require(string_format("%s.srcc.main", name))
    game:launch()
end

--// 退出小游戏
function MyApp:exitGame()
    if game then
        game:exit()
    end
    game = nil
    self:enterScene(LOBBY_SCENE)
end

function MyApp:enterScene(name, isNotWrap)
    --// 切换场景时，不错做消息处理
    gg.ClientSocket:setIsQueuePause(true)
    local sceneName = string_format("scenes.%s", name)
    local scene = require(sceneName).new()
    if not isNotWrap then
        display.runScene(scene, "fade", GOLD_TIME)
    else
        display.runScene(scene)
    end
end

--// 创建控制器
function MyApp:createController(name)
    local ctrlName = string_format("controllers.%s", name)
    local ctrl = require(ctrlName).new()
    return ctrl
end

--// 创建csb
function MyApp:createCsbNode(name)
    return cc.CSLoader:createNode(string_format("csb/%s.csb", name))
end

return MyApp
