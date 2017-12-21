
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
if DEBUG == 0 then
CC_SHOW_FPS = false
else
CC_SHOW_FPS = true
end

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

CONFIG_SCREEN_WIDTH = 1136
CONFIG_SCREEN_HEIGHT = 640

-- for module display
CC_DESIGN_RESOLUTION = {
    width = CONFIG_SCREEN_WIDTH,
    height = CONFIG_SCREEN_HEIGHT,
    autoscale = "FIXED_WIDTH",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "SHOW_ALL"}
        end
    end
}