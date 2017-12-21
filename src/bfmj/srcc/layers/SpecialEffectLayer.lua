--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--
local Layer = class("SpecialEffectLayer", function()
    return cc.Layer:create()
end)

local pp = pp
local MahjOp      = pp.GamePublic.MahjOp
local PlayModel   = pp.PlayModel
local AudioHelper = pp.AudioHelper

local function createAnimation(name, num)
    local frames = display.newFrames(name.. "_%d.png", 0, num, false)
    local animation, target = display.newAnimation(frames, GOLD_TIME / num)
    display.setAnimationCache(name .."_animation", animation)
    return target
end

function Layer:ctor()
    self:enableNodeEvents()

    --// 用于播放动画的容器
    self._aniTargets = {}
end

local OP_NAME = {
    [MahjOp.CHOW] = "mj_ani_chow",
    [MahjOp.PONG] = "mj_ani_pong",
    [MahjOp.KONG] = "mj_ani_kong",
    [MahjOp.WIN]  = "mj_ani_hu",
}

local ANI_POSITION = {
    [0] = cc.p(display.cx, 200),
    [1] = cc.p(display.cx + 300, display.cy),
    [2] = cc.p(display.cx, display.top - 100),
    [3] = cc.p(display.cx - 300, display.cy + 50),
}

function Layer:playOpAnimation(op, chairID)
    local opName  = OP_NAME[op]
    local aniName = opName .."_animation"

    if not display.getAnimationCache(aniName) then
        self._aniTargets[opName] = createAnimation(opName, 14)
            :pos(ANI_POSITION[chairID])
            :addTo(self, 2)
    end
    --// 二次检测
    if not self._aniTargetChow then
        self._aniTargets[opName] = createAnimation(opName, 14)
            :pos(ANI_POSITION[chairID])
            :addTo(self, 2)
    end
    self._aniTargets[opName]:playAnimationOnce(display.getAnimationCache(aniName), {afterDelay = GOLD_HALF_TIME, hide = true})
end

--// 刮风下雨动画，尝试用cocos studio做出来的动画
function Layer:onPlayWindRain(chairID)
    if not self.nodeWindRain then
        self.nodeWindRain = cc.CSLoader:createNode("csb/animations/AniWindRainNode.csb")
        self.aniWindRain  = cc.CSLoader:createTimeline("csb/animations/AniWindRainNode.csb")
        self.nodeWindRain:retain()
        self.aniWindRain:retain()
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end

            local frameName = frame:getEvent()
            if frameName == "end_frame" then
                cc.CallFuncSequence.new(self.nodeWindRain, 
                    cc.FadeOut:create(GOLD_QTR_TIME),
                    function(obj)
                        obj:removeSelf()
                    end):start()
            end
        end
        self.aniWindRain:setFrameEventCallFunc(onFrameEvent)
    end

    if not self.nodeWindRain:getParent() then
        self.nodeWindRain:pos(ANI_POSITION[chairID])
            :addTo(self, 3)

        self.nodeWindRain:setOpacity(255)
        self.nodeWindRain:runAction(self.aniWindRain)
        self.aniWindRain:gotoFrameAndPlay(0, false)
    end
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")

    cc.EventProxy.new(myApp, self)
        :on("evt_SC_MAHJ_OP_P_CPKTH", function(evt)
            local data = evt.data
            local op = PlayModel:getCurOpAction()
            --// 取消杠动画表现，表现在刮风下雨
            if op == MahjOp.CHOW or op == MahjOp.PONG --[[or op == MahjOp.KONG]] then
                self:playOpAnimation(op, data.chairID)
            end

            AudioHelper:playCKPH(op)
        end)
        :on("evt_SC_MAHJ_CALC_RESULT_P_Wind_Rain", function(evt)
            local data = evt.data
            self:onPlayWindRain(data.chairID)
        end)
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")

    if self.nodeWindRain then
        self.nodeWindRain:release()
        self.nodeWindRain = nil
    end

    if self.aniWindRain then
        self.aniWindRain:release()
        self.aniWindRain = nil
    end
end

return Layer