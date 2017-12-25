--
-- Author: Chen
-- Date: 2017-11-30 11:21:49
-- Brief: 
--
local UIHelper = {}

local MsgBox   = require("nodes.MessageBoxNode")
local Waitting = require("nodes.WaittingNode")
local Toast    = require("nodes.ToastNode")
local Gain     = require("nodes.RewardGainNode")

local table_remove = table.remove


local E_ZORDER = Enum({
    "SHADE",
    "COMMOM_DIALOG",
    "NULL",
    "REWARD_GAIN",
    "POP_WINDOWS",
    "WAITTING",
}, 10)

--// 已打开的对话框列表
local openendDialogs = {}

--// 已呈现的toast
local nodeToasts = {}

--// UI弹窗的跟节点
function UIHelper:getRoot()
    return display.getRunningScene()
end

-- /**
--  * 显示透明遮罩,x秒后自动删除，防止用户点击
--  */
function UIHelper:showLucencyShade(isAutoRemove, duration)
    self:showShade({opacity = 0})
    if isAutoRemove then
        layShade:performWithDelay(function()
            layShade:removeSelf()
        end, duration or 5)
    end
end

-- /**
--  * 显示遮罩，放置用户点击
--  * params.name 定制name，为了防止已经有了弹窗，再弹出waitting时，删除waitting时，把dialog的shader删除
--  */
function UIHelper:showShade(params)

    params = params or {}
    local layShade = ccui.Layout:create()
    layShade:setContentSize(cc.size(display.width, display.height))
    layShade:setTouchEnabled(true)
    layShade:setBackGroundColorType(1)
    layShade:setBackGroundColor(cc.c3b(0, 0, 0))
    layShade:setOpacity(params.opacity or 150)
    layShade:setName(params.name or "layer_shade")
    layShade:addTo(self:getRoot(), params.zOrder or E_ZORDER.SHADE)

    return layShade
end

-- /**
--  * 移除遮罩
--  */
function UIHelper:removeShade(name)
    if self:getRoot() then
       self:getRoot():removeChildByName(name or "layer_shade")
    end
end

--// 弹窗打开动画
local function playOpenAction(node)
    openendDialogs[#openendDialogs + 1] = node

    node:show()
    node:setScale(GOLD_TIME)
    local act1 = cc.ScaleTo:create(GOLD_HALF_TIME, 1)
    node:stopAllActions()
    node:runAction(cc.Sequence:create(
        cc.EaseBackOut:create(act1), 
        cc.CallFunc:create(function() --// 打开动画完成
            if node.onOpenCompleted then
                node:onOpenCompleted()
            end
        end)
    ))
end

--// 弹窗关闭动画
local function playCloseAction(node, cbOver)
    table_remove(openendDialogs)
    
    node:stopAllActions()
    node:runAction(cc.ScaleTo:create(GOLD_QTR_TIME, 1.15))
    node:runAction(cc.Sequence:create(
        cc.FadeOut:create(GOLD_QTR_TIME), 
        cc.CallFunc:create(function()
            if node.onClosedCompleted then
                node:onClosedCompleted()
            end
            if cbOver then
                cbOver(node)
            end 
        end)
    ))
end


local function showMsgBox(content, type, callback)
    UIHelper:showShade({zOrder = E_ZORDER.POP_WINDOWS - 1, name = "box_shader"})

    UIHelper:getRoot():removeChildByName("msg_box")

    local msgBox
    msgBox = MsgBox.new(content, type, 
            function(ret)
                if callback then
                    callback(ret)
                end
                UIHelper:removeShade("box_shader")
                playCloseAction(msgBox)
            end)
        :pos(display.cx, display.cy)
        :addTo(UIHelper:getRoot(), E_ZORDER.POP_WINDOWS)
    msgBox:setName("msg_box")
    playOpenAction(msgBox)
    msgBox.dialogType = "msg_box"
end

-- /**
--  * 显示1个按钮的msgbox
--- * @param callback 按钮回调 参数：string "ok" "cancel"
--  */
function UIHelper:showOneMsgBox(content, callback)
    showMsgBox(content, 1, callback)
end

-- /**
--  * 显示2个按钮的msgbox
--- * @param callback 按钮回调 参数：string "ok" "cancel"
--  */
function UIHelper:showTwoMsgBox(content, callback)
    showMsgBox(content, 2, callback)
end

-- /**
--  * 网络等待
--- * @param callback 超时回调
--- * @param isNotDelay 是否直接显示
--  */
function UIHelper:showWaitting(content, callback, isNotDelay)
    self:getRoot():removeChildByName("waitting_dialog")

    local delay
    if not isNotDelay then
       delay = TIME_WIDGET_DISABLE
    else 
        delay = 0
    end

    cc.ScheduleManager:performWithDelay(self:getRoot(), function()
        content = content or "正在通讯中"
        UIHelper:showShade({zOrder = E_ZORDER.WAITTING - 1, name = "waitting_shader"})
        Waitting.new(content, 
                function()
                    if callback then
                        callback()
                    end
                    self:stopWaitting()
                    self:showOneMsgBox("请求超时,请重试！")
                end)
            :pos(display.cx, display.cy)
            :addTo(self:getRoot(), E_ZORDER.WAITTING)
            :name("waitting_dialog")
    end, delay, "scheule_waitting")
end

function UIHelper:stopWaitting()
    cc.ScheduleManager:removeHandleByKey(UIHelper:getRoot(), "scheule_waitting")

    self:removeShade("waitting_shader")
    self:getRoot():removeChildByName("waitting_dialog")
end

function UIHelper:showGains(items)
    self:showShade({zOrder = E_ZORDER.REWARD_GAIN - 1, name = "gains_shader"})
        :addClickEventListener(function()
            self:removeShade("gains_shader")
            self:getRoot():removeChildByName("gains_dialog")
        end)
    Gain.new(items)
        :pos(display.cx, display.cy)
        :addTo(self:getRoot(), E_ZORDER.REWARD_GAIN)
        :name("gains_dialog")
end

-- /**
--  * 显示toast
--  * @param content 目前有长度限制，适合简短的提示
--  */
function UIHelper:showToast(content)
    --self:getRoot():removeChildByName("toast_dialog")

    local toast = Toast.new(content)
        :pos(display.cx, display.cy)
        :addTo(self:getRoot(), E_ZORDER.WAITTING)
        --:name("toast_dialog")

    nodeToasts[#nodeToasts + 1] = toast


    

    -- if #nodeToasts <= 3 then
    --     for i = #nodeToasts, 1, -1 do
    --         local nodeToast = nodeToasts[i]
    --         nodeToast:rise(cc.p(display.cx, display.cy + nodeToast.height * (3 - i)))
    --     end
    -- end


end

-- /**
--  * 打开某个弹窗
--  */
function UIHelper:showDialog(name, ...)
    UIHelper:showShade({zOrder = E_ZORDER.COMMOM_DIALOG - 1})

    local dialogNode = require("dialogs." ..name).new(...)
        :pos(display.cx, display.cy)
        :addTo(self:getRoot(), E_ZORDER.COMMOM_DIALOG)
        :name(name)
        :hide()

    --// 优化打开动画
    dialogNode:performWithDelay(function()
        playOpenAction(dialogNode)
    end, 0)
    
    return dialogNode
end

-- /**
--  * 关闭弹窗
--  * @param name为空，关闭最上层弹窗
--  */
function UIHelper:closeDialog(source)

    local node
    if type(source) == "string" then
        node = self:getRoot():getChildByName(source)
    elseif type(source) == "userdata" then
        node = source
    end

    if node then
        if node.dialogType == "msg_box" then
            self:removeShade("box_shader")
        else
            self:removeShade()
        end
        playCloseAction(node, function(obj)
            obj:removeSelf()
        end)
    end
end

-- /**
--  * 关闭最上层弹窗
--  * @return bool true 当前操作有弹窗，false 当前操作无弹窗
--  */
function UIHelper:closeTopDialog()
    local node = openendDialogs[#openendDialogs]
    if node then
        self:closeDialog(node)
        return true
    else
        return false
    end
end

return UIHelper