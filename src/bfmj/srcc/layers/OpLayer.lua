--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--
local Layer = class("OpLayer", function()
    return cc.Layer:create()
end)

local pp = pp

local PlayModel = pp.PlayModel

local GamePublic = pp.GamePublic
local MahjOp     = GamePublic.MahjOp

local RequestManager = gg.RequestManager

local MultipleChowNode = game:loadSource("ui.MultipleChowNode")

function Layer:ctor()
    self:enableNodeEvents()

    self.btnPass = ccui.Button:create("mj_btn_pass.png", "mj_btn_pass.png", "", 1)
        :posY(200)
        :addTo(self, 1)
        :hide()
    self.btnChow = ccui.Button:create("mj_btn_chow.png", "mj_btn_chow.png", "", 1)
        :posY(200)
        :addTo(self, 1)
        :hide()
    self.btnPong = ccui.Button:create("mj_btn_pong.png", "mj_btn_pong.png", "", 1)
        :posY(200)
        :addTo(self, 1)
        :hide()
    self.btnKong = ccui.Button:create("mj_btn_kong.png", "mj_btn_kong.png", "", 1)
        :posY(200)
        :addTo(self, 1)
        :hide()
    self.btnHu   = ccui.Button:create("mj_btn_hu.png", "mj_btn_hu.png", "", 1)
        :posY(200)
        :addTo(self, 1)
        :hide()


    self.spFixIcons = {}
end

--// 定缺结束
function Layer:onFixEnd()
    local fixTypes = PlayModel:getFixTypes()

    local pos_icons = {
        cc.p(display.cx + 350, display.cy + 50),
        cc.p(display.cx, display.cy + 220),
        cc.p(display.cx - 350, display.cy + 50),
    }

    for i = 1, PlayModel:getMaxChairID() do
        local fixType = fixTypes[i] or 1
        if fixType then
            self.spFixIcons[i] = cc.Sprite:createWithSpriteFrameName(pp.Res_mj_dq_icons[fixType])
                :pos(pos_icons[i])
                :addTo(self, 1)
        end
    end

    local NODE_FIX_ICONS_POSITION = pp.NODE_FIX_ICONS_POSITION

    for i = 0, PlayModel:getMaxChairID() do
        local spFixIcon = self.spFixIcons[i]

        if spFixIcon then
            local act = cc.MoveTo:create(GOLD_TIME, NODE_FIX_ICONS_POSITION[i])
            spFixIcon:stopAllActions()
            spFixIcon:runAction(cc.Sequence:create(cc.DelayTime:create(GOLD_QTR_TIME), act))
        end
    end
end

--// 定缺回复
function Layer:onDingQueAck()
    if self.btnDQWan and self.btnDQTong and self.btnDQTiao then
        self.btnDQWan:hide()
        self.btnDQTong:hide()
        self.btnDQTiao:hide()
    end

    local fixType = PlayModel:getFixTypes()[0]
    self.spFixIcons[0] = cc.Sprite:createWithSpriteFrameName(pp.Res_mj_dq_icons[fixType])
        :pos(display.cx, 150)
        :addTo(self, 1)
end

--// 显示选择定缺按钮
function Layer:showDingQueButtons()
    if self.btnDQWan and self.btnDQTong and self.btnDQTiao then
        self.btnDQWan:show()
        self.btnDQTong:show()
        self.btnDQTiao:show()
        return
    end

    self.btnDQWan = ccui.Button:create("mj_btn_dq_wan.png", "mj_btn_dq_wan.png", "", 1)
        :pos(display.cx - 150, 200)
        :addTo(self, 1)
    self.btnDQTong = ccui.Button:create("mj_btn_dq_tong.png", "mj_btn_dq_tong.png", "", 1)
        :pos(display.cx, 200)
        :addTo(self, 1)
    self.btnDQTiao = ccui.Button:create("mj_btn_dq_tiao.png", "mj_btn_dq_tiao.png", "", 1)
        :pos(display.cx + 150, 200)
        :addTo(self, 1)

    self.btnDQWan.fixType  = 0
    self.btnDQTong.fixType = 1
    self.btnDQTiao.fixType = 2

    local function onClick(obj)
        self.btnDQWan:hide()
        self.btnDQTong:hide()
        self.btnDQTiao:hide()

        RequestManager:reqFix(obj.fixType)
    end

    self.btnDQWan:onClick_(onClick)
    self.btnDQTong:onClick_(onClick)
    self.btnDQTiao:onClick_(onClick)
end

function Layer:registerClickEvents()
    local function onClick(obj)
        self:hideAllButtons()
        
        if obj == self.btnPass then
            cclog.info("click btnPass")
            RequestManager:reqPass()
        elseif obj == self.btnChow then
            if PlayModel:getCanChowAmount() == 1 then
                RequestManager:reqChow(PlayModel:checkChowOp())
            else
                MultipleChowNode.new(PlayModel:getOpTile())
                    :pos(display.cx, display.cy - 120)
                    :addTo(self, 2)
            end
        elseif obj == self.btnPong then
            RequestManager:reqPong()
        elseif obj == self.btnKong then
            local tile, op = PlayModel:checkKongTileAndOp()
            RequestManager:reqKong(tile, op)
        elseif obj == self.btnHu then
            RequestManager:reqHu()
        end
    end
    self.btnPass:onClick_(onClick)
    self.btnChow:onClick_(onClick)
    self.btnPong:onClick_(onClick)
    self.btnKong:onClick_(onClick)
    self.btnHu:onClick_(onClick)
end

function Layer:hideAllButtons()
    self.btnPass:hide()
    self.btnChow:hide()
    self.btnPong:hide()
    self.btnKong:hide()
    self.btnHu:hide()
end

function Layer:onShowButtons()
    self:hideAllButtons()

    local i = 1
    local canOpActions = PlayModel:getCanOpActions()
    cclog.warn(canOpActions)
    if canOpActions[MahjOp.GIVEUP] then
        self.btnPass:show()
            :posX(display.right - 150 * i)
        i = i + 1
    end
    if canOpActions[MahjOp.CHOW] then
        self.btnChow:show()
            :posX(display.right - 150 * i)
        i = i + 1
    end
    if canOpActions[MahjOp.PONG] then
        self.btnPong:show()
            :posX(display.right - 150 * i)
        i = i + 1
    end
    if canOpActions[MahjOp.KONG] then
        self.btnKong:show()
            :posX(display.right - 150 * i)
        i = i + 1
    end
    if canOpActions[MahjOp.WIN] then
        self.btnHu:show()
            :posX(display.right - 150 * i)
        i = i + 1
    end
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")

    cc.EventProxy.new(myApp, self)
        :on("evt_SC_MAHJ_OP_REQ", function(evt)
            self:onShowButtons()
        end)
        :on("evt_SC_MAHJ_FIX_P", function(evt)
            self:showDingQueButtons()
        end)
        :on("evt_SC_MAHJ_FIX_ACK_P", function(evt)
            self:onDingQueAck()
        end)
        :on("evt_SC_MAHJ_FIX_END", function(evt)
            self:onFixEnd()
        end)
        :on("evt_Hide_Op_Buttons", function(evt)
            self:hideAllButtons()
        end)
        :on("evt_Clear_UI", function()
            --// 清除定缺标志
            for i = 0, PlayModel:getMaxChairID() do
                local spFixIcon = self.spFixIcons[i]
                if spFixIcon then
                    spFixIcon:removeSelf()
                end
            end
        end)    

    self:registerClickEvents()
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")
end

return Layer