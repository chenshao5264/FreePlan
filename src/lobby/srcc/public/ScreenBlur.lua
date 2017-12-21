--
-- Author: Chen
-- Date: 2017-12-11 16:05:04
-- Brief: 
--
local ScreenBlur = {}


local vertDefaultSource = "\n".."\n" ..
                  "attribute vec4 a_position;\n" ..
                  "attribute vec2 a_texCoord;\n" ..
                  "attribute vec4 a_color;\n\n" ..
                  "\n#ifdef GL_ES\n" .. 
                  "varying lowp vec4 v_fragmentColor;\n" ..
                  "varying mediump vec2 v_texCoord;\n" ..
                  "\n#else\n" ..
                  "varying vec4 v_fragmentColor;" ..
                  "varying vec2 v_texCoord;" ..
                  "\n#endif\n" ..
                  "void main()\n" ..
                  "{\n" .. 
                  "   gl_Position = CC_MVPMatrix * a_position;\n"..
                  "   v_fragmentColor = a_color;\n"..
                  "   v_texCoord = a_texCoord;\n" ..
                  "} \n"

-- /**
--  * 屏幕模糊
--  * @return 模糊后的精灵
--  */
function ScreenBlur:start()

    local scene = display.getRunningScene()
    if not scene then
        return
    end

    local textureScreen = cc.RenderTexture:create(display.width, display.height)
    textureScreen:beginWithClear(0, 0, 0, 0)       
    cc.Director:getInstance():getRunningScene():visit()
    textureScreen:endToLua()

    local sp = cc.Sprite:createWithSpriteFrame(textureScreen:getSprite():getSpriteFrame())

    local vertSource = vertDefaultSource
    local fragSource = cc.FileUtils:getInstance():getStringFromFile("shaders/example_Blur.fsh")

    local pProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    pProgram:link()
    pProgram:updateUniforms()

    local pProgramState = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    pProgramState:setUniformVec2("resolution", cc.p(100, 100))
    pProgramState:setUniformFloat("blurRadius", 0.8)
    pProgramState:setUniformFloat("sampleNum", 5)
    sp:setFlippedY(true)
    sp:setGLProgram(pProgram)

    -- --// 有待研究
    -- local textureScreen = cc.RenderTexture:create(display.width, display.height)
    -- textureScreen:beginWithClear(0, 0, 0, 0)       
    -- sp:visit()
    -- textureScreen:endToLua()

    -- sp = cc.Sprite:createWithSpriteFrame(textureScreen:getSprite():getSpriteFrame())

    return sp
end

return ScreenBlur