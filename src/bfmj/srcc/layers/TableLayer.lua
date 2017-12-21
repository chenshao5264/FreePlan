--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--
local Layer = class("TableLayer", function()
    return cc.Layer:create()
end)

local game       = game
local TableModel = gg.TableModel
local Global     = gg.Global

function Layer:ctor()
    self:enableNodeEvents()

    local spBg = cc.Sprite:create("game_bg.jpg")
        :pos(display.cx, display.cy)
        :addTo(self, 1)

    local btnExit = ccui.Button:create("btn_exit_game.png", "btn_exit_game.png", "", 1)
        :pos(display.left + 40, display.top - 40)
        :addTo(self, 2)
        :onClick_(function()

        end)

    local btnSetup = ccui.Button:create("btn_set.png", "btn_set.png", "", 1)
        :pos(display.right - 40, display.top - 40)
        :addTo(self, 2)
        :onClick_(function()
            gg.UIHelper:showDialog("SetupDialog")
        end)

    --// 计时器
    self._nodeTimer = game:loadSource("components.TimerNode").new()
        :pos(display.cx, display.cy + 50)
        :addTo(self, 2)
        :hide()

    --// 剩余提示
    self._nodeWahjWall = game:loadSource("components.MahjWallNode").new()
        :pos(display.cx - 200, display.cy - 80)
        :addTo(self, 2)
        :hide()

    --// 玩家头像
    local NODE_PLAYERS_POSITION = pp.NODE_PLAYERS_POSITION

    local NodePlayer = game:loadSource("components.PlayerNode")
    self._nodePlayers = {}
    for i = 0, 3 do
        self._nodePlayers[i] = NodePlayer.new(i)
            :pos(NODE_PLAYERS_POSITION[i])
            :addTo(self, 2)
            :hide()
    end
end

function Layer:onPlayDiceAni(points)
    local node = cc.CSLoader:createNode("csb/animations/AniDiceNode.csb")
        :pos(display.cx + 100, display.cy - 50)
        :addTo(self, 3)
    local nodeAni = cc.CSLoader:createTimeline("csb/animations/AniDiceNode.csb")
    node:runAction(nodeAni)
    nodeAni:gotoFrameAndPlay(0, false)
    node:setName("dice_ani")

    local act = cc.MoveTo:create(GOLD_HALF_TIME, cc.p(display.cx - 100, display.cy + 50))
    node:runAction(act)

    local spAniTarget = node:getChildByName("Sprite_Target")
    local spDice0 = node:getChildByName("sp_dice_0"):hide()
    local spDice1 = node:getChildByName("sp_dice_1"):hide()

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end

        local frameName = frame:getEvent()
        if frameName == "end_frame" then
            spAniTarget:hide()
            spDice0:show()
            spDice1:show()
            spDice0:setSpriteFrame(string.format("mj_image_dice_dice%d_0.png", points[1]))
            spDice1:setSpriteFrame(string.format("mj_image_dice_dice%d_1.png", points[2]))

            node:performWithDelay(function()
                node:removeSelf()

                if self._nextDice then
                    self._nextDice:next()
                end
            end, 1)
        end
    end
    nodeAni:setFrameEventCallFunc(onFrameEvent)
end

--// 断线重连直接显示庄家标志
function Layer:onShowBankerIcon(chairID)
    local spBanker = cc.Sprite:createWithSpriteFrameName("mj_icon_banker.png")
        :pos(pp.NODE_BANKER_ICONS_POSITION[chairID])
        :addTo(self, 3)
end

--// 庄家标志动画
function Layer:onPlayBankerAni(chairID)

    local node = cc.CSLoader:createNode("csb/animations/AniBankerNode.csb")
        :pos(display.cx, display.cy)
        :addTo(self, 3)
    local nodeAni = cc.CSLoader:createTimeline("csb/animations/AniBankerNode.csb")
    node:runAction(nodeAni)
    nodeAni:gotoFrameAndPlay(0, false)
    node:setName("banker_icon")

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end

        local frameName = frame:getEvent()
        if frameName == "end_frame" then
            local act = cc.MoveTo:create(GOLD_TIME, pp.NODE_BANKER_ICONS_POSITION[chairID])
            node:stopAllActions()
            node:runAction(cc.Sequence:create(
                cc.DelayTime:create(GOLD_QTR_TIME), 
                cc.EaseBackIn:create(act),
                cc.DelayTime:create(GOLD_QTR_TIME),
                cc.CallFunc:create(function()
                    if self._nextDice then
                        self._nextDice:next()
                    end
                end)
            ))
        end
    end
    nodeAni:setFrameEventCallFunc(onFrameEvent)
end

--// 进入桌子后，玩家头像
function Layer:onFillTablePlayer()
    local users = TableModel:getUserDatas()
    cclog.debug(users, "<==== users")

    for cid, user in pairs(users) do
        self._nodePlayers[cid]:onFillData(user)
    end
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")

    cc.EventProxy.new(myApp, self)
        :on("evt_GC_TABLE_USERLIST_P", function(evt)
            self:onFillTablePlayer()
        end)
        :on("evt_GC_ENTERTABLE", function(evt)
            local data  = evt.data
            local users = TableModel:getUserDatas()
            local user  = users[data.chairID]
            self._nodePlayers[data.chairID]:onFillData(user)
        end)
        :on("evt_GC_LEAVETABLE_P", function(evt)
            local data  = evt.data
            self._nodePlayers[data.chairID]:hide()
        end)
        :on("evt_GC_HANDUP_P", function(evt)
            local data = evt.data
            self._nodePlayers[data.chairID]:onHandUp()
        end)
        :on("evt_GC_GAME_START_P", function(evt)
            for i = 0, 3 do
                self._nodePlayers[i]:onGameStart()
            end
        end)
        :on("evt_SC_MAHJ_INITDATA", function(evt)
            local data = evt.data

            self._nodeTimer:show()
            self:onShowBankerIcon(data.banker)

            self._nodeWahjWall:show()
            self._nodeWahjWall:updateMahjRemain(data.wallNum)

            self._nodeWahjWall:loadSmallDicesTexture(data.points)
        end)
        :on("evt_SC_MAHJ_DICE", function(evt)
            local data = evt.data
            self._nodeWahjWall:loadSmallDicesTexture(data.points)

            self._nextDice = cc.Next.new(
                function()
                    self:onPlayBankerAni(data.banker)
                end,
                function()
                    self:onPlayDiceAni(data.points)
                end,
                function()
                    self._nodeTimer:performWithDelay(function()
                        self._nodeTimer:show()
                    end, GOLD_QTR_TIME)
                end
            )
            self._nextDice:start()
        end)
        :on("evt_SC_MAHJ_DRAWN_P", function(evt)
            local data = evt.data
            self._nodeWahjWall:show()
            self._nodeWahjWall:updateMahjRemain(data.wallNum)
        end)
        :on("evt_Clear_UI", function(evt)
            self:removeChildByName("banker_icon")
        end)
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")
end

return Layer