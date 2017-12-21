--
-- Author: Chen
-- Date: 2017-11-20 18:43:09
-- Brief: 
--


local pp = pp
local Point_Configs = pp.Point_Configs

local GamePublic  = pp.GamePublic
local eMahjPoints = GamePublic.eMahjPoints
local band        = GamePublic.band

local PlayModel = pp.PlayModel


local Global = gg.Global


local ScreenBlur = require(LOBBY_SRC_ROOT .."public.ScreenBlur")

local Layer = class("ResultLayer", function()
    return cc.Node:create()
end)


-- /**
--  * 添加番型
--  * @param  
--  * @return [number] 返回总番数
--  */
function Layer:fillPoints(chairID, lvPoints, stResult, bfFanPointsNum)
    local totalFan = 0

    local points = stResult.points

    local function addPointTypeToListView(points, mahjPoints)
        if band(points,  eMahjPoints[mahjPoints]) ~= 0 then

            local pointConfig = Point_Configs[mahjPoints]
            if not pointConfig then
                return
            end

            local img = ccui.ImageView:create(pointConfig[1], 1)
            lvPoints:pushBackCustomItem(img)
            img:hide()

            bfFanPointsNum:performWithDelay(function(obj)
                totalFan = totalFan + pointConfig[2]
                bfFanPointsNum:setString(totalFan)
            end, lvPoints:getChildrenCount() * 0.08)
        end
    end

    local isLongQiDui = false
    if band(points, eMahjPoints.MJPT_LONGQIDUI) ~= 0 or
       band(points, eMahjPoints.MJPT_DLONGQIDUI) ~= 0 or
       band(points, eMahjPoints.MJPT_TLONGQIDUI) ~= 0 or
       band(points, eMahjPoints.MJPT_QLONGQIDUI) ~= 0 or
       band(points, eMahjPoints.MJPT_QDLONGQIDUI) ~= 0 or
       band(points, eMahjPoints.MJPT_QTLONGQIDUI) ~= 0 then

        isLongQiDui = true

        addPointTypeToListView(points, "MJPT_LONGQIDUI")
        addPointTypeToListView(points, "MJPT_DLONGQIDUI")
        addPointTypeToListView(points, "MJPT_TLONGQIDUI")
        addPointTypeToListView(points, "MJPT_QLONGQIDUI")
        addPointTypeToListView(points, "MJPT_QDLONGQIDUI")
        addPointTypeToListView(points, "MJPT_QTLONGQIDUI")

        if band(points, eMahjPoints.MJPT_DLONGQIDUI) and
            band(points, eMahjPoints.MJPT_QDLONGQIDUI) then

            addPointTypeToListView(eMahjPoints.MJPT_GEN2, "MJPT_GEN2")
        end

        if band(points, eMahjPoints.MJPT_TLONGQIDUI) and
            band(points, eMahjPoints.MJPT_QTLONGQIDUI) then

            addPointTypeToListView(eMahjPoints.MJPT_GEN3, "MJPT_GEN3")
        end
    end

    addPointTypeToListView(points, "MJPT_SELFDRAWN")
    addPointTypeToListView(points, "MJPT_SUFAN")
    addPointTypeToListView(points, "MJPT_DADUIZI")
    addPointTypeToListView(points, "MJPT_ONECOLOR")
    addPointTypeToListView(points, "MJPT_ANQIDUI")
    addPointTypeToListView(points, "MJPT_DAIYAO")
    addPointTypeToListView(points, "MJPT_JIANGDUI")
    addPointTypeToListView(points, "MJPT_QINGDUI")
    addPointTypeToListView(points, "MJPT_QINGQIDUI")
    addPointTypeToListView(points, "MJPT_QINGDAIYAO")
    addPointTypeToListView(points, "MJPT_YJQIDUI")
    addPointTypeToListView(points, "MJPT_DIANPAO")
    addPointTypeToListView(points, "MJPT_KONGHUA")
    addPointTypeToListView(points, "MJPT_KONGPAO")
    addPointTypeToListView(points, "MJPT_QIANGGANG")
    addPointTypeToListView(points, "MJPT_TIANHU")
    addPointTypeToListView(points, "MJPT_DIHU")
    addPointTypeToListView(points, "MJPT_HUAZHU")
    addPointTypeToListView(points, "MJPT_WUJIAO")
    addPointTypeToListView(points, "MJPT_BIGDAN")

    if isLongQiDui == false then
        local genNum = stResult.get or 0
        if genNum == 1 then
            addPointTypeToListView(eMahjPoints.MJPT_GEN1, "MJPT_GEN1")
        elseif genNum == 2 then
            addPointTypeToListView(eMahjPoints.MJPT_GEN2, "MJPT_GEN2")
        elseif genNum == 3 then
            addPointTypeToListView(eMahjPoints.MJPT_GEN3, "MJPT_GEN3")
        elseif genNum == 4 then
            addPointTypeToListView(eMahjPoints.MJPT_GEN4, "MJPT_GEN4")
        end 
    end
end

function Layer:drawWinTiles()
    if not self._mahjLayer then
        return
    end

    local winChairID = PlayModel:getWinChairID() or 0
    local handTiles  = PlayModel:getHandTilesByChairID(winChairID)
    local flatTiles  = PlayModel:getFlatTilesByChairID(winChairID)

    local node = self._mahjLayer:drawWinTiles(handTiles, flatTiles)
        :pos(display.cx - 200, display.cy + 120)
        :addTo(self.layResult, 2) 
end

function Layer:setMahjLayer(lay)
    self._mahjLayer = lay
end

function Layer:ctor()
    self:enableNodeEvents()


    self.layResult = nil
end

function Layer:procUI()
    if self.layResult then
        return
    end

    self.layResult = cc.CSLoader:createNode(Global:getCsbFile("ResultLayer"))
        :addTo(self, 2)

    local btnZLYJ = self.layResult:getChildByName("Button_ZLYJ")
    btnZLYJ:onClick_(function(obj)
        self:removeBlurBg()
        self.layResult:removeSelf()
        self.layResult = nil
    end)
    local btnFHFJ = self.layResult:getChildByName("Button_FHFJ")
    btnFHFJ:onClick_(function(obj)
        self:removeBlurBg()
        self.layResult:removeSelf()
        self.layResult = nil
    end)    

    self._layUserPoints = {}

    self._layUserPoints[0] = self.layResult:getChildByName("Panel_User0")
    local oriPosX, oriPosY = self._layUserPoints[0]:getPosition()
    local sizeWidth = self._layUserPoints[0]:getContentSize().width
    for i = 1, PlayModel:getMaxChairID() do
        self._layUserPoints[i] = self._layUserPoints[0]:clone()
            :pos(oriPosX + sizeWidth * i, oriPosY)
            :addTo(self.layResult, 2)
    end
end

function Layer:fillData()
    local users   = gg.TableModel:getUserDatas()
    local results = PlayModel:getResults()
 
    for i = 0, PlayModel:getMaxChairID() do
        local layUserPoints = self._layUserPoints[i]
        local textNickname = layUserPoints:getChildByName("Text_Nickname")
        textNickname:str(users[i].strNickName)
        layUserPoints:getChildByName("Image_Icon_Hu"):hide()

        local bfFanPointsNum = layUserPoints:getChildByName("BitmapFontLabel_Points_Value")
        bfFanPointsNum:setString(0)
        local lvPoints = layUserPoints:getChildByName("ListView_Points")
        layUserPoints.lvPoints = lvPoints

        self:fillPoints(i, lvPoints, results[i], bfFanPointsNum)
    end

    --// 番型弹出动画
    for i = 0, PlayModel:getMaxChairID() do
        local lvPoints = self._layUserPoints[i].lvPoints
        local onceTime = GOLD_HALF_TIME
        local waitTime = 0.08
        for i = 1, lvPoints:getChildrenCount()  do
            local cellBg = lvPoints:getItem(i - 1):hide()
            cellBg:performWithDelay(function(obj)
                obj:show()
                obj:setScale(0.01)
                local scaleTo = cc.EaseBackOut:create(cc.ScaleTo:create(onceTime, 1))
                obj:runAction(scaleTo)
            end, (i - 1) * waitTime)
        end
    end

    self:drawWinTiles()
end

--// 添加模糊背景
function Layer:addBulrBg()
    if self:getChildByTag(1234) then
        return
    end

    local sp = ScreenBlur:start()
        :pos(display.cx, display.cy)
        :addTo(self, 1)
    sp:setTag(1234)
end

--// 删除模糊背景
function Layer:removeBlurBg()
    self:removeChildByTag(1234)
end

function Layer:onEnter()
    cclog.trace(self.__cname .." onEnter")

    cc.EventProxy.new(myApp, self)
        :on("evt_SC_MAHJ_RESULT", function(evt)
            local data = evt.data
            self:addBulrBg()
            self:procUI()
            self:fillData()
        end)
end

function Layer:onExit()
    cclog.trace(self.__cname .." onExit")


end

return Layer