--
-- Author: Chen
-- Date: 2017-11-17 15:44:17
-- Brief: 
--
local BaseController = require('controllers.BaseController')
local M = class("LobbyController", BaseController)

local gg = gg
local Player    = gg.Player
local UIHelper  = gg.UIHelper
local ggDialog  = gg.Dialog
local ggUtility = gg.Utility
local ggGlobal  = gg.Global

local TableComponent = require("components.TableComponent")

--// step1
function M:ctor()
    self.super.ctor(self)

end

--// step2
function M:onInit()
    self.super.onInit(self)
    --// todo
    --// ...
end

--// step3_1
--// 关联画布上的元素
function M:onRelateViewElements()
    self.btnHZMJ = self.resNode:getChildByName("Button_hzmj")
    self.btnSK   = self.resNode:getChildByName("Button_sk")
    self.btnSKY  = self.resNode:getChildByName("Button_sky")
    self.btnHZMJ.oriPos = cc.p(self.btnHZMJ:getPosition())
    self.btnSK.oriPos   = cc.p(self.btnSK:getPosition())
    self.btnSKY.oriPos  = cc.p(self.btnSKY:getPosition())
    self.btnHZMJ:posX(display.right + self.btnHZMJ:getContentSize().width / 2)
    self.btnSK:posX(display.right + self.btnSK:getContentSize().width / 2)
    self.btnSKY:posX(display.right + self.btnSKY:getContentSize().width / 2)
    
    self.nodeHead    = self.resNode:getChildByName("Node_Head")
    self.nodeBean    = self.resNode:getChildByName("Node_Bean")
    self.nodeDiamond = self.resNode:getChildByName("Node_Diamond")
    self.btnSetup    = self.resNode:getChildByName("Button_Setup")
    self.nodeHead.oriPos    = cc.p(self.nodeHead:getPosition())
    self.nodeBean.oriPos    = cc.p(self.nodeBean:getPosition())
    self.nodeDiamond.oriPos = cc.p(self.nodeDiamond:getPosition())
    self.btnSetup.oriPos    = cc.p(self.btnSetup:getPosition())

    self.nodeHead:posX(-200)
    self.nodeBean:posY(display.top + 100)
    self.nodeDiamond:posY(display.top + 100)
    self.btnSetup:posY(display.top + 100)


    self.spRenWu = self.resNode:getChildByName("img_renwu")
    self.spRenWu.oriPos = cc.p(self.spRenWu:getPosition())
    self.spRenWu.goalPos = cc.p(0, self.spRenWu.oriPos.y)
    self.spRenWu:setOpacity(0)

    self.btnCJBX = self.resNode:getChildByName("Button_cjbx"):hide()
    self.btnJRBX = self.resNode:getChildByName("Button_jrbx"):hide()
    self.btnKSKS = self.resNode:getChildByName("Button_ksk"):hide()

    self.btnCJBX.oriPos = cc.p(self.btnCJBX:getPosition())
    self.btnJRBX.oriPos = cc.p(self.btnJRBX:getPosition())
    self.btnKSKS.oriPos = cc.p(self.btnKSKS:getPosition())

    self.btnCJBX.goalPos = cc.p(display.right + self.btnCJBX:getContentSize().width / 2, self.btnCJBX.oriPos.y)
    self.btnJRBX.goalPos = cc.p(display.right + self.btnJRBX:getContentSize().width / 2, self.btnJRBX.oriPos.y)
    self.btnKSKS.goalPos = cc.p(display.right + self.btnKSKS:getContentSize().width / 2, self.btnKSKS.oriPos.y)

    self.bg2 = self.resNode:getChildByName("Image_bg_2")
    self.bg2:hide()
    self.bg2:setTouchEnabled(true)
    self.bg2:setOpacity(0)
    self.btnBack = self.nodeHead:getChildByName("Button_Back")

    self.btnShop     = self.resNode:getChildByName("Button_Shop")
    self.btnActivity = self.resNode:getChildByName("Button_Activity")
    self.btnTask     = self.resNode:getChildByName("Button_Task")
    self.btnMail     = self.resNode:getChildByName("Button_Mail")

    self.btnShop.oriPos     = cc.p(self.btnShop:getPosition())
    self.btnActivity.oriPos = cc.p(self.btnActivity:getPosition())
    self.btnTask.oriPos     = cc.p(self.btnTask:getPosition())
    self.btnMail.oriPos     = cc.p(self.btnMail:getPosition())

    self.btnShop.goalPos     = cc.p(self.btnShop.oriPos.x, -self.btnShop:getContentSize().height / 2)
    self.btnActivity.goalPos = cc.p(self.btnActivity.oriPos.x, -self.btnActivity:getContentSize().height / 2)
    self.btnTask.goalPos     = cc.p(self.btnTask.oriPos.x, -self.btnTask:getContentSize().height / 2)
    self.btnMail.goalPos     = cc.p(self.btnMail.oriPos.x, -self.btnMail:getContentSize().height / 2)

    self.btnShop:setPositionY(self.btnShop.goalPos.y)
    self.btnActivity:setPositionY(self.btnActivity.goalPos.y)
    self.btnTask:setPositionY(self.btnTask.goalPos.y)
    self.btnMail:setPositionY(self.btnMail.goalPos.y)

    self.spBoard = self.resNode:getChildByName("sp_board")
    self.spBoard.oriPos  = cc.p(self.spBoard:getPosition())
    self.spBoard.goalPos = cc.p(self.spBoard.oriPos.x, -self.spBoard:getContentSize().height / 2)
    self.spBoard:setPositionY(self.spBoard.goalPos.y)

    self.btnSign = self.resNode:getChildByName("Button_Sign")
    self.btnSign.oriPos  = cc.p(self.btnSign:getPosition())
    self.btnSign.goalPos = cc.p(self.btnSign.oriPos.x, display.top + self.btnSign:getContentSize().height / 2)
    self.btnSign:setPositionY(self.btnSign.goalPos.y)

    --// filldata
    self.nodeHead:getChildByName("Text_Nickname"):str(gg.Utility.getShortStr(Player:getNickname(), 6))
    self.nodeHead:getChildByName("Image_Avatar"):loadTexture(ggGlobal:getAvatarImageByGender(Player:getGender()), 1)


    self.bfBeanValue = self.nodeBean:getChildByName("BitmapFontLabel_Value")
    self.bfBeanValue:setString(ggUtility.getShortBean(Player:getBeanCurrency()))
    self.bfDiamondValue = self.nodeDiamond:getChildByName("BitmapFontLabel_Value")
    self.bfDiamondValue:setString(Player:getDiamondCurrency())
end

local function delayPlayMoveActionWithTargetNoEase(target, delay, duration, pos)
    cc.CallFuncSequence.new(target,
        cc.DelayTime:create(delay),
        cc.MoveTo:create(duration, pos)
    ):start()
end

local function delayPlayMoveActionWithTarget(target, delay, duration, pos)
    cc.CallFuncSequence.new(target,
        cc.DelayTime:create(delay),
        cc.EaseBackOut:create(cc.MoveTo:create(duration, pos))
    ):start()
end

--// 进入桌子页面
function M:playEnterTablePage()
    cc.CallFuncSequence.new(self.nodeHead,
         cc.DelayTime:create(0.1),
         cc.MoveTo:create(GOLD_HALF_TIME / 2, cc.p(self.nodeHead.oriPos.x + self.btnBack:getContentSize().width, self.nodeHead.oriPos.y))
    ):start()

    self.bg2:show()
    self.bg2:setOpacity(0)
    self.bg2:stopAllActions()
    self.bg2:runAction(cc.FadeIn:create(GOLD_TIME))

    self.nodeTables = {}
    for i = 1, 6 do
        self.nodeTables[i] = TableComponent:create(i)
    end

    local gridTables = cc.GridNode:create(self.nodeTables, 3, 125, 2, 520)
        :pos(display.cx, display.cy - 40)
        :addTo(self, 2)

    for i = 1, 6 do
        local nodeTable = self.nodeTables[i]
        nodeTable.oriPos = cc.p(nodeTable:getPosition())
        if i % 2 == 0 then --// 右边
            nodeTable.goalPos = cc.p(display.cx + 260, nodeTable.oriPos.y)
        else
            nodeTable.goalPos = cc.p(-display.cx - 260, nodeTable.oriPos.y)
        end

        nodeTable:setPosition(nodeTable.goalPos)
        delayPlayMoveActionWithTargetNoEase(nodeTable, 0.1 * math.floor(i / 2), GOLD_HALF_TIME, nodeTable.oriPos)
    end
end

--// 离开桌子页面
function M:playLeaveTablePage()
    cc.CallFuncSequence.new(self.nodeHead,
         cc.DelayTime:create(0.1),
         cc.MoveTo:create(GOLD_HALF_TIME / 2, self.nodeHead.oriPos)
    ):start()

    self.bg2:stopAllActions()
    self.bg2:runAction(cc.Sequence:create(
        cc.FadeOut:create(GOLD_TIME), 
        cc.CallFunc:create(function()
            self.bg2:hide()
        end)
    ))

    self:playBoardAppearAction()

    for i = 1, 6 do
        local nodeTable = self.nodeTables[i]
        nodeTable.oriPos = cc.p(nodeTable:getPosition())
        if i % 2 == 0 then --// 右边
            nodeTable.goalPos = cc.p(display.cx + 260, nodeTable.oriPos.y)
        else
            nodeTable.goalPos = cc.p(-display.cx - 260, nodeTable.oriPos.y)
        end

        delayPlayMoveActionWithTargetNoEase(nodeTable, 0.1 * math.floor(i / 2), GOLD_HALF_TIME, nodeTable.goalPos)
    end
end

--// 进入厢房界面
function M:playEnterWingRoom()

    cc.CallFuncSequence.new(self.nodeHead,
         cc.DelayTime:create(0.1),
         cc.MoveTo:create(GOLD_HALF_TIME / 2, cc.p(self.nodeHead.oriPos.x + self.btnBack:getContentSize().width, self.nodeHead.oriPos.y))
    ):start()

    self.bg2:show()
    self.bg2:setOpacity(0)
    self.bg2:stopAllActions()
    self.bg2:runAction(cc.FadeIn:create(GOLD_TIME))

    self.btnCJBX:posX(self.btnCJBX.goalPos.x):show()
    self.btnJRBX:posX(self.btnJRBX.goalPos.x):show()
    self.btnKSKS:posX(self.btnKSKS.goalPos.x):show()

    delayPlayMoveActionWithTarget(self.spRenWu, 0.1, GOLD_TIME, self.spRenWu.goalPos)
    delayPlayMoveActionWithTarget(self.btnCJBX, 0.1, GOLD_TIME, self.btnCJBX.oriPos)
    delayPlayMoveActionWithTarget(self.btnJRBX, 0.2, GOLD_TIME, self.btnJRBX.oriPos)
    delayPlayMoveActionWithTarget(self.btnKSKS, 0.3, GOLD_TIME, self.btnKSKS.oriPos)

    self:playBoardDisappearAction()
end

--// 离开厢房界面
function M:playLeaveWingRoom()
    cc.CallFuncSequence.new(self.nodeHead,
         cc.DelayTime:create(0.1),
         cc.MoveTo:create(GOLD_HALF_TIME / 2, self.nodeHead.oriPos)
    ):start()

    self.bg2:stopAllActions()
    self.bg2:runAction(cc.Sequence:create(
        cc.FadeOut:create(GOLD_TIME), 
        cc.CallFunc:create(function()
            self.bg2:hide()
        end)
    ))

    delayPlayMoveActionWithTarget(self.btnCJBX, 0.3, GOLD_TIME, self.btnCJBX.goalPos)
    delayPlayMoveActionWithTarget(self.btnJRBX, 0.2, GOLD_TIME, self.btnJRBX.goalPos)
    delayPlayMoveActionWithTarget(self.btnKSKS, 0.1, GOLD_TIME, self.btnKSKS.goalPos)
    delayPlayMoveActionWithTarget(self.spRenWu, 0.1, GOLD_TIME, self.spRenWu.oriPos)

    self:playBoardAppearAction()
end

--// step3_2
--// 注册视图上的交互事件
function M:onRegisterButtonClickEvent()
    local function onClickEvent(obj)
        if obj == self.btnHZMJ then
            --self:playEnterWingRoom()
            self:playEnterTablePage()
        else
            gg.UIHelper:showToast("敬请期待！")
        end
    end
    self.btnHZMJ:onClick_(onClickEvent)
    self.btnSK:onClick_(onClickEvent)
    self.btnSKY:onClick_(onClickEvent)

    self.btnBack:onClick_(function(obj)
        --self:playLeaveWingRoom()
        self:playLeaveTablePage()
    end)

    --// 设置
    self.btnSetup:onClick_(function(obj)
        UIHelper:showDialog(ggDialog.SetupDialog)
    end)

    --// 创建包房
    self.btnCJBX:onClick_(function(obj)

    end)
    --// 加入包房
    self.btnJRBX:onClick_(function(obj)

    end)
    --// 快速开始
    self.btnKSKS:onClick_(function(obj)

    end)
    --// 商店
    self.btnShop:onClick_(function(obj)
        gg.UIHelper:showDialog(ggDialog.ShopDialog)
    end)
    --// 活动
    self.btnActivity:onClick_(function(obj)
        
    end)
    --// 任务
    self.btnTask:onClick_(function(obj)
        
    end) 
    --// 邮件
    self.btnMail:onClick_(function(obj)
        
    end)
    --// 签到
    self.btnSign:onClick_(function(obj)
        
    end)
end

function M:onRegisterEventProxy()
    cc.EventProxy.new(myApp, self)
        :on("evt_bean_update", function(evt)
            self.bfBeanValue:setString(Player:getBeanCurrency())
        end)
        :on("evt_diamond_update", function(evt)
            self.bfDiamondValue:setString(Player:getDiamondCurrency())
        end)
end

-- /**
--  * 进场动画
--  */
function M:onEnterAnimation()
    delayPlayMoveActionWithTarget(self.nodeHead, 0.1, GOLD_TIME, self.nodeHead.oriPos)
    delayPlayMoveActionWithTarget(self.btnSign, 0.2, GOLD_TIME, self.btnSign.oriPos)
    delayPlayMoveActionWithTarget(self.btnSetup, 0.1, GOLD_TIME, self.btnSetup.oriPos)
    delayPlayMoveActionWithTarget(self.nodeBean, 0.2, GOLD_TIME, self.nodeBean.oriPos)
    delayPlayMoveActionWithTarget(self.nodeDiamond, 0.3, GOLD_TIME, self.nodeDiamond.oriPos)

    delayPlayMoveActionWithTarget(self.btnHZMJ, 0.1, GOLD_TIME, self.btnHZMJ.oriPos)
    delayPlayMoveActionWithTarget(self.btnSK, 0.2, GOLD_TIME, self.btnSK.oriPos)
    delayPlayMoveActionWithTarget(self.btnSKY, 0.3, GOLD_TIME, self.btnSKY.oriPos)

    self:playBoardAppearAction()
end

--// 底部按钮消失动画
function M:playBoardDisappearAction()
    self.spBoard:runAction(cc.MoveTo:create(GOLD_TIME, self.spBoard.goalPos))
    self.btnShop:runAction(cc.MoveTo:create(GOLD_TIME, self.btnShop.goalPos))
    self.btnActivity:runAction(cc.MoveTo:create(GOLD_TIME, self.btnActivity.goalPos))
    self.btnTask:runAction(cc.MoveTo:create(GOLD_TIME, self.btnTask.goalPos))
    self.btnMail:runAction(cc.MoveTo:create(GOLD_TIME, self.btnMail.goalPos))
end

--// 底部按钮出现动画
function M:playBoardAppearAction()
    self.spBoard:setPositionY(self.spBoard.goalPos.y)
    self.spBoard:stopAllActions()
    self.spBoard:runAction(cc.MoveTo:create(GOLD_TIME, self.spBoard.oriPos))

    self.btnShop:setPositionY(self.btnShop.goalPos.y)
    self.btnActivity:setPositionY(self.btnActivity.goalPos.y)
    self.btnTask:setPositionY(self.btnTask.goalPos.y)
    self.btnMail:setPositionY(self.btnMail.goalPos.y)
    
    delayPlayMoveActionWithTarget(self.btnShop, 0.1, GOLD_TIME, self.btnShop.oriPos)
    delayPlayMoveActionWithTarget(self.btnActivity, 0.2, GOLD_TIME, self.btnActivity.oriPos)
    delayPlayMoveActionWithTarget(self.btnTask, 0.3, GOLD_TIME, self.btnTask.oriPos)
    delayPlayMoveActionWithTarget(self.btnMail, 0.4, GOLD_TIME, self.btnMail.oriPos)

    self.spRenWu:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(GOLD_TIME))
        )
end

function M:onEnter()
    self.super.onEnter(self)
    --// todo
    --// ...
end

function M:onEnterTransitionFinish()
    self.super.onEnterTransitionFinish(self)
    
end

function M:onExit()
    --// todo
    --// ...
    self.super.onExit(self)
end

return M