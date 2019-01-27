--
-- Author: Chen
-- Date: 2017-08-24 11:55:45
-- Brief: 所有scene的基类
--

local ClientSocket = gg.ClientSocket

local BaseScene = class("BaseScene", function()
    return cc.Scene:create()
end)

function BaseScene:ctor()
    self:enableNodeEvents()


    myApp:setRunningScene(self)

    -- local testView = require("app.TestView").new()
    -- self:addChild(testView, 1)
end

-- /**
--  * 进入场景
--  */
function BaseScene:onEnter()
    cclog.trace(self.__cname, "onEnter")
    ClientSocket:setIsQueuePause(false)

    if not myApp:isIos() then
        --// 注册android按钮事件
        local function onKeyReleased(keyCode)
            if keyCode == cc.KeyCode.KEY_ESCAPE then
                print("<===== KEY_ESCAPE")
                
                if gg.UIHelper:closeTopDialog() then
                    return
                end

                gg.UIHelper:showOneMsgBox("退出游戏？", function(ret)
                    if ret == "ok" then
                        cclog.warn("退出游戏!")
                    end
                end)
            end
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    end

    
end

-- /**
--  * 场景执行完过度动画
--  */
function BaseScene:onEnterTransitionFinish()
    cclog.trace(self.__cname, "onEnterTransitionFinish")
end

-- /**
--  * 退出场景
--  */
function BaseScene:onExit()
    cclog.trace(self.__cname, "onExit")
end

-- /**
--  * 完全退出场景
--  */
function BaseScene:onCleanup()
    cclog.trace(self.__cname, "onCleanup")
end

return BaseScene
