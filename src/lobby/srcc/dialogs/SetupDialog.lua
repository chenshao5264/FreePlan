--
-- Author: Chen
-- Date: 2017-12-13 17:25:52
-- Brief: 
--

local gg = gg
local Global      = gg.Global
local AudioHelper = gg.AudioHelper

local UserDefault = cc.UserDefault:getInstance()

local M = class("SetupDialog", function()
    return cc.CSLoader:createNode(Global:getCsbFile("dialogs/SetupDialog"))
end)

--// step1
function M:ctor()
    local SliderEventType_percentChanged = ccui.SliderEventType.percentChanged

    self.sliders = {}
    --// name Music Effect
    local function initSlider(name)
        local spOnTag = self:getChildByName("Sprite_On_Tag_" ..name)

        local slider = self:getChildByName("Slider_" ..name)
        slider:addEventListener(function(sender, eventType)
            if eventType == SliderEventType_percentChanged then

                local percent = sender:getPercent()

                if percent == 0 then
                    spOnTag:setSpriteFrame("setting_min_sound_sign.png")
                else
                    spOnTag:setSpriteFrame("setting_max_sound_sign.png")
                end

                if name == "Effect" then
                    AudioHelper:setEffectVolume(percent / 100)
                else
                    AudioHelper:setMusicVolume(percent / 100)
                end
            end
        end)
        self.sliders[name] = slider
    
        local sliderPercent = UserDefault:getIntegerForKey("Volume_" ..name, 100)
        slider:setPercent(sliderPercent)

        if sliderPercent == 0 then
            spOnTag:setSpriteFrame("setting_min_sound_sign.png")
        else
            spOnTag:setSpriteFrame("setting_max_sound_sign.png")
        end
    end
    
    initSlider("Music")
    initSlider("Effect")

    self:getChildByName("Button_Close")
        :onClick_(function(obj)
            gg.UIHelper:closeDialog("SetupDialog")
            UserDefault:setIntegerForKey("Volume_Music", self.sliders["Music"]:getPercent())
            UserDefault:setIntegerForKey("Volume_Effect", self.sliders["Effect"]:getPercent())
        end)

    self:onNodeEvent("exit", function()
        UserDefault:setIntegerForKey("Volume_Music", self.sliders["Music"]:getPercent())
        UserDefault:setIntegerForKey("Volume_Effect", self.sliders["Effect"]:getPercent())
    end)
end

return M