--
-- Author: Your Name
-- Date: 2017-12-02 16:41:36
--
local AudioHelper = {}

local SOUND_COMMOM_CLICK = "sound/button_click.mp3"

AudioHelper._isOff = false

audio.setSoundsVolume(1)
audio.setMusicVolume(1)

--// 设置是否静音
function AudioHelper:setOff(isOff)
    self._isOff = isOff
end

--// 设置音效音量
function AudioHelper:setEffectVolume(volume)
    audio.setSoundsVolume(volume)
end

--// 设置背景音量
function AudioHelper:setMusicVolume(volume)
    audio.setMusicVolume(volume)
end

function AudioHelper:playClickSound()
    if self._isOff then 
        return
    end
    audio.playSound(SOUND_COMMOM_CLICK, false)
end


return AudioHelper