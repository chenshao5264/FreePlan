cc.FileUtils:getInstance():setPopupNotify(false)


cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("src/apis")
cc.FileUtils:getInstance():addSearchPath("src/lobby/srcc")
cc.FileUtils:getInstance():addSearchPath("src/lobby/res")

local writeablePath = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(writeablePath .."update", true)


require "config" 
require "cocos.init"
require "ccEx.cclog.init"
require "AppDelegate"

--for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog.error("----------------------------------------")
    cclog.error("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog.error(debug.traceback())
    cclog.error("----------------------------------------")
end

local function main()
    runApp()
end

xpcall(main, __G__TRACKBACK__)