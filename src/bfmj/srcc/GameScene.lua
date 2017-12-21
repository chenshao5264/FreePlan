--
-- Author: Chen
-- Date: 2017-11-17 10:31:35
-- Brief: 
--
local BaseScene = require('scenes.BaseScene')
local M = class("GameScene", BaseScene)



function M:ctor(...)
    self.super.ctor(self)
    --// todo
    --// ...
    
    local layTest = game:loadSource("TestView").new()
        :addTo(self)

    local zorder = 1
    --// 桌子元素相关
    self.layTable = game:createLayer("TableLayer")
        :addTo(self, zorder)
    zorder = zorder + 1

    --// 麻将牌显示层
    self.layMahj = game:createLayer("MahjLayer")
        :addTo(self, zorder)
    zorder = zorder + 1

    --// 触摸层
    self.layTouch = game:createLayer("TouchLayer")
        :addTo(self, zorder)
    self.layTouch:setMahjLayer(self.layMahj)
    zorder = zorder + 1

    --// 操作按钮层 吃碰...
    self.layOp = game:createLayer("OpLayer")
        :addTo(self, zorder)
    zorder = zorder + 1

    --// 特效显示层
    self.laySpecial = game:createLayer("SpecialEffectLayer")
        :addTo(self, zorder)
    zorder = zorder + 1

    --// 功能按钮层 如设置，聊天
    self.layFunction = game:createLayer("FunctionLayer")
        :addTo(self, zorder)
    zorder = zorder + 1

    --// 结算层
    self.layResult = game:createLayer("ResultLayer")
        :addTo(self, zorder)
    zorder = zorder + 1
    self.layResult:setMahjLayer(self.layMahj)
end

function M:onInit()
    self.super.onInit(self)
    --// todo
    --// ...
end

function M:onEnter()
    self.super.onEnter(self)
    --// todo
    --// ...
    cc.EventProxy.new(myApp, self)
    
end

function M:onEnterTransitionFinish()
    self.super.onEnterTransitionFinish(self)

    --// todo
    --// ...

    gg.RequestManager:reqHandUp()

end

function M:onExit()
    --// todo
    --// ...

    self.super.onExit(self)
end

function M:onCleanup()
    --// todo
    --// ...
    
    

    self.super.onCleanup(self)
end

return M