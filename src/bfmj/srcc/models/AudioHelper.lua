--
-- Author: Chen
-- Date: 2017-12-13 14:17:13
-- Brief: 
--

local AudioHelper = gg.AudioHelper or {}

local string_format = string.format
local MahjOp        = pp.GamePublic.MahjOp

local SOUND_TILE       = "sound/%d-%d.mp3"
local SOUND_CHOW       = "sound/chow-%d.mp3"
local SOUND_PONG       = "sound/pong-%d.mp3"
local SOUND_KONG       = "sound/kong-%d.mp3"
local SOUND_HU         = "sound/win-%d.mp3"
local SOUND_DRAW       = "sound/mopai.mp3"
local SOUND_CLICK_CARD = "sound/ClickCardSound.mp3"
local SOUND_GAME_START = "sound/GameStartSound.mp3"

AudioHelper._sex   = 1

--// 设置男女音
function AudioHelper:setSex(sex)
    self._sex = sex
end

-- /**
--  * 播放牌值音效
--  */
function AudioHelper:playTile(tile)
    if self._isOff then 
        return
    end
    audio.playSound(string_format(SOUND_TILE, tile, self._sex), false)
end

-- /**
--  * 播放吃碰杠胡
--  */
function AudioHelper:playCKPH(op)
    if self._isOff then 
        return
    end
    if op == MahjOp.CHOW then
        audio.playSound(string_format(SOUND_CHOW, self._sex), false)
    elseif op == MahjOp.PONG then
        audio.playSound(string_format(SOUND_PONG, self._sex), false)
    elseif op == MahjOp.KONG then
        audio.playSound(string_format(SOUND_KONG, self._sex), false)
    -- elseif op == MahjOp.WIN then
    --     audio.playSound(string_format(SOUND_HU, self._sex), false)
    end
end

-- /**
--  * 摸牌音效
--  */
function AudioHelper:playDraw()
    if self._isOff then 
        return
    end
    audio.playSound(SOUND_HU, sex, false)
end

-- /**
--  * 点击牌音效
--  */
function AudioHelper:playClickCard()
    if self._isOff then 
        return
    end
    audio.playSound(SOUND_CLICK_CARD, false)
end

-- /**
--  * 游戏开始音效
--  */
function AudioHelper:playGameStart()
    if self._isOff then 
        return
    end
    audio.playSound(SOUND_GAME_START, false)
end

return AudioHelper