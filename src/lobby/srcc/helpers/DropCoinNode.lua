local M = class("DropCoinNode", function()
    return cc.Node:create()
end)

local math = math
local math_random   = math.random
local math_sqrt     = math.sqrt
local string_format = string.format

local spriteFrameCache = cc.SpriteFrameCache:getInstance()

function M:ctor(x, y, speed, bounceHeight, finalHeight, time)
    self.constValue   = speed             --决定下落速度的一个常量
    self.bounceHeight = bounceHeight    --每次下落弹起的高度，值为0~1之间
    self.finalHeight  = finalHeight      --低于该高度将不再弹起
    self.delayTime    = time               --开始下落前延时范围
    self.baseX        = x
    self.baseY        = y

    self:setPosition(x, y)
    self:initCoinRotateAnim()
    self:initCoinDropAnim()
end

function M:initCoinRotateAnim()
    local frames = {}
    local offset = math_random(1, 7)
    for i = 1, 7 do
        local source = string_format("sign_icon_coin_%02d.png", (i + offset) % 7 + 1)
        frames[i] = spriteFrameCache:getSpriteFrame(source)
    end

    local animation, target = display.newAnimation(frames, 0.05)
    target:addTo(self)
    target:playAnimationForever(animation)
end

function M:initCoinDropAnim()
    local height = self.baseY
    local anims = {}

    local delayTime = math_random() * self.delayTime
    anims[#anims + 1] = cc.DelayTime:create(delayTime)

    while height > self.finalHeight do
        local dropDown = cc.MoveTo:create(math_sqrt(height) / self.constValue, cc.p(self.baseX, 0))
        local speedUp = cc.EaseIn:create(dropDown, 2)

        height = height * self.bounceHeight * math_random()

        local bounce = cc.MoveTo:create(math_sqrt(height) / self.constValue, cc.p(self.baseX, height))
        local speedDown = cc.EaseOut:create(bounce, 2)

        anims[#anims + 1] = cc.Sequence:create(speedUp, speedDown)
    end

    local dropDown = cc.MoveTo:create(math_sqrt(height) / self.constValue, cc.p(self.baseX, 0))
    local speedUp = cc.EaseIn:create(dropDown, 2)

    anims[#anims + 1] = speedUp
    anims[#anims + 1] = cc.CallFunc:create(function ()
        self:removeFromParent()
    end)

    local sequence = cc.Sequence:create(anims)
    self:runAction(sequence)
end

return M

