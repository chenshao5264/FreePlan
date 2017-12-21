local game = {}


local GAME_NAME     = "bfmj"
local GAME_SRC_ROOT = GAME_NAME ..".srcc."


--// 封装游戏内部的require
function game:loadSource(packagePath)
    return require(GAME_SRC_ROOT ..packagePath)
end

-- /**
--  * 启动小游戏入口
--  */
function game:launch()
    cclog.debug("bfmj launch")

    cc.FileUtils:getInstance():addSearchPath("src/" ..GAME_NAME .."/res", true)
    --cc.FileUtils:getInstance():addSearchPath("src/" ..GAME_NAME .."/srcc", true)

    display.loadSpriteFrames("images/playing_atlas.plist", "images/playing_atlas.png")
    display.loadSpriteFrames("images/chow_atlas.plist", "images/chow_atlas.png")
    display.loadSpriteFrames("images/pong_atlas.plist", "images/pong_atlas.png")
    display.loadSpriteFrames("images/kong_atlas.plist", "images/kong_atlas.png")
    display.loadSpriteFrames("images/hu_atlas.plist", "images/hu_atlas.png")
    display.loadSpriteFrames("images/wind_rain_atlas.plist", "images/wind_rain_atlas.png")
    display.loadSpriteFrames("images/points_atlas.plist", "images/points_atlas.png")
    display.loadSpriteFrames("images/dice_atlas.plist", "images/dice_atlas.png")
    

    gg.Gobal = gg.Gobal or require("public.Global")

    pp = {}

    --// require 文件的顺序不能随便更换
    self:loadSource("Debug")
    self:loadSource("models.Defines")

    pp.GamePublic = self:loadSource("gamepublic.GamePublic")
    self:loadSource("gamepublic.GameProtocol")
    self:loadSource("gamepublic.ProtocolNum")

    pp.PlayModel  = self:loadSource("models.PlayModel").new()


    self:loadSource("net.MsgHandler")
    self:loadSource("net.RequestManager")

    self:loadSource("models.AudioHelper")
    gg.AudioHelper:setSex(gg.Player:getGender())

    local scene = self:loadSource("GameScene").new()
    display.runScene(scene, "fade", 0.6)
end

-- /**
--  * 退出小游戏
--  */
function game:exit()
    cclog.debug("bfmj exit")

    --//


    --cc.FileUtils:getInstance():removeSearchPath("src/" ..GAME_NAME .."/srcc")
    cc.FileUtils:getInstance():removeSearchPath("src/" ..GAME_NAME .."/res")
    cc.FileUtils:getInstance():purgeCachedEntries()

    -- gg.MsgHandler:clearGameMsg()
    -- gg.RequestManager:clearGameReq()
end

function game:createLayer(name)
    local layer = self:loadSource("layers." ..name).new()
    return layer
end

return game