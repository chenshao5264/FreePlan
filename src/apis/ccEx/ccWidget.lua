--
-- Author: Your Name
-- Date: 2017-06-13 10:00:45
--
local Widget = ccui.Widget or {}

function grayNode ( node )

    local pProgram = cc.GLProgram:createWithFilenames(
        "shader/defalut.vert", "shader/flowing.frag")

    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR , cc.VERTEX_ATTRIB_COLOR )
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD , cc.VERTEX_ATTRIB_FLAG_TEX_COORDS )
    pProgram:link()
    pProgram:updateUniforms()
    
    local pProgramState = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    pProgramState:setUniformTexture("u_texture", cc.Director:getInstance():getTextureCache():addImage("images/kidnap.png"))
    pProgramState:setUniformFloat("factor", 1.5)
    pProgramState:setUniformFloat("width", 0.8)
    pProgramState:setUniformVec3("color", cc.vec3(1, 0, 0))

    node:setGLProgram(pProgram)

    -- local scheduler = require("utils.scheduler")
    -- scheduler.scheduleGlobal(function() 

    -- end)
end

local function removeGray()

end

local function press(obj)
    local act = cc.ScaleTo:create(0.15, 0.95)
    obj:stopAllActions()
    obj:runAction(act)
end

local function release(obj)
    local act = cc.ScaleTo:create(0.15, 1)
    obj:stopAllActions()
    obj:runAction(act)
end

function Widget:onClickWithColor(cb)
    self:addTouchEventListener(function(obj, eventType)
        if eventType == 0 then
            obj:setColor(cc.c4b(0x6e, 0x6e, 0x6e, 0x6e))
        elseif eventType == 1 then

        elseif eventType == 2 then
            if cb then
                cb(obj)
            end
            obj:setColor(cc.c4b(0xff, 0xff, 0xff, 0xff))
            gg.AudioHelper:playClickSound()
        else
            obj:setColor(cc.c4b(0xff, 0xff, 0xff, 0xff))
        end
    end)
    return self
end

function Widget:onClick_(cb)
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(obj, eventType)
        if eventType == 0 then
            press(self)

        elseif eventType == 1 then

        elseif eventType == 2 then
            if cb then
                cb(obj)
            end
            release(self)
            gg.AudioHelper:playClickSound()
        else
            release(self)
        end
    end)
    return self
end

--// 短时间内禁止点击
function Widget:shortDisable()
    self:setEnabled(false)
    cc.ScheduleManager:performWithDelay(self, function()
        self:setEnabled(true)
    end, TIME_WIDGET_DISABLE, "widget_short_disable")
end
