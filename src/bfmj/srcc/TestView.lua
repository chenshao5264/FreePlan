--
-- Author: Chen
-- Date: 2017-11-21 19:48:07
-- Brief: 
--


local TestView = class("TestView", function()
    return cc.Layer:create()
end)

local PlayModel = pp.PlayModel

local GamePublic  = pp.GamePublic
local MahjOp      = GamePublic.MahjOp
local eMahjPoints = GamePublic.eMahjPoints
local bor         = GamePublic.bor


local ScreenBlur = require("lobby.srcc.public.ScreenBlur")

function TestView:ctor()
    local handTiles = _dHandTiles[0]

    local drawTile
    local disTile

    local remain = 100
    local chair = 0
    local function onKeyReleased(keyCode, event)
        if keyCode == 47 then
           
           gg.UIHelper:showDialog("ShopDialog")
           do return end

            -- chair = chair + 1
            -- if chair == 4 then
            --     chair = 0
            -- end
            -- myApp:emit("evt_timer_update", {chairID = chair, count = 12})

            -- PlayModel:setHandTilesByChairID(0, handTiles)

            local function convertFlatTiles(tiles)
                local flats = {}
                local tmp = {}
                for i = 1, #tiles do
                    local tile = tiles[i]
                    if tile == -1 then
                        flats[#flats + 1] = tmp
                        tmp = {}
                    else
                        tmp[#tmp + 1] = tile
                    end
                end
                return flats
            end



            local flatTiles0 = convertFlatTiles(_dFlatTiles[0])
            PlayModel:setFlatHeapCountByChairID(0, #flatTiles0)
            local flatTiles1 = convertFlatTiles(_dFlatTiles[1])
            PlayModel:setFlatHeapCountByChairID(1, #flatTiles1)
            local flatTiles2 = convertFlatTiles(_dFlatTiles[2])
            PlayModel:setFlatHeapCountByChairID(2, #flatTiles2)
            local flatTiles3 = convertFlatTiles(_dFlatTiles[3])
            PlayModel:setFlatHeapCountByChairID(3, #flatTiles3)

            PlayModel:setHandTilesByChairID(0, _dHandTiles[0])
            PlayModel:setRiverTilesByChairID(0, _dRiverTiles[0])
            PlayModel:setFlatTilesByChairID(0, flatTiles0)
            PlayModel:setHandTilesByChairID(1, _dHandTiles[1])
            PlayModel:setRiverTilesByChairID(1, _dRiverTiles[1])
            PlayModel:setFlatTilesByChairID(1, flatTiles1)
            PlayModel:setHandTilesByChairID(2, _dHandTiles[2])
            PlayModel:setRiverTilesByChairID(2, _dRiverTiles[2])
            PlayModel:setFlatTilesByChairID(2, flatTiles2)
            PlayModel:setHandTilesByChairID(3, _dHandTiles[3])
            PlayModel:setRiverTilesByChairID(3, _dRiverTiles[3])
            PlayModel:setFlatTilesByChairID(3, flatTiles3)


            myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = 0})
            myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = 1})
            myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = 2})
            myApp:emit("evt_SC_MAHJ_TITE_UP_P", {chairID = 3})



            myApp:emit("evt_mahjWall_node_visible", {visible = true, points = {1, 2}})
        elseif keyCode == 48 then
            -- while true do
            --     drawTile = math.random(1, 37)
            --     if drawTile % 10 == 0 then
            --         drawTile = nil
            --     end
            --     if drawTile then
            --         break
            --     end
            -- end
            -- myApp:emit("evt_render_river", {chairID = 0, tile = drawTile})



            while true do
                drawTile = math.random(1, 37)
                if drawTile % 10 == 0 then
                    drawTile = nil
                end
                if drawTile then
                    break
                end
            end
            drawTile = 1
            PlayModel:setDrawTile(drawTile)
            PlayModel:setCanOpActions(MahjOp.DISCARD, 1)
            myApp:emit("evt_SC_MAHJ_DRAWN_P", {chairID = 3, tile = drawTile})
        elseif keyCode == 49 then
            -- local node = cc.CSLoader:createNode(gg.Global:getCsbFile("BankerAniNode"))
            --     :pos(display.cx, display.cy)
            --     :addTo(myApp:getRunningScene(), 100)
            -- local nodeAni = cc.CSLoader:createTimeline(gg.Global:getCsbFile("BankerAniNode"))
            -- node:runAction(nodeAni)
            -- nodeAni:gotoFrameAndPlay(0, false)

            -- _chairID = _chairID or 1
            -- _tile = _tile or 1
            -- myApp:emit("evt_SC_MAHJ_OP_P_DISCARD", {chairID = _chairID, tile = _tile})
            -- _chairID = _chairID + 1
            -- _tile = _tile + 1
            -- if _chairID == 4 then
            --     _chairID = 1
            -- end
            -- do return end

            myApp:emit("evt_timer_update", {chairID = 3, timeSec = 15})
            do return end

            myApp:emit("evt_SC_MAHJ_OP_P_DISCARD", {chairID = 3, tile = 1})
            do return end

            myApp:emit("evt_SC_MAHJ_DICE", {banker = 3, points = {4, 6}})
            do return end


            myApp:emit("evt_SC_MAHJ_FIX_ACK_P")
            myApp:emit("evt_SC_MAHJ_FIX_END")
            do return end

            PlayModel:setCanOpActions(0, 2)

            gg.TableModel:addUserByChairID(0, {strNickName = "00000", userID = 0})
            gg.TableModel:addUserByChairID(1, {strNickName = "11111", userID = 1})
            gg.TableModel:addUserByChairID(2, {strNickName = "22222", userID = 2})
            gg.TableModel:addUserByChairID(3, {strNickName = "33333", userID = 3})

            pp.PlayModel:setResults(0, {points = bor({0,
                eMahjPoints.MJPT_SELFDRAWN,
                eMahjPoints.MJPT_SUFAN,
                eMahjPoints.MJPT_DADUIZI,
                eMahjPoints.MJPT_ONECOLOR,
                eMahjPoints.MJPT_ANQIDUI,
            })})
            pp.PlayModel:setResults(1, {points = bor({0,
                eMahjPoints.MJPT_SELFDRAWN,
                eMahjPoints.MJPT_SUFAN,
                eMahjPoints.MJPT_DADUIZI,
                eMahjPoints.MJPT_ONECOLOR,
                eMahjPoints.MJPT_ANQIDUI,
            })})
            pp.PlayModel:setResults(2, {points = bor({0,
                eMahjPoints.MJPT_SELFDRAWN,
                eMahjPoints.MJPT_SUFAN,
                eMahjPoints.MJPT_DADUIZI,
                eMahjPoints.MJPT_ONECOLOR,
                eMahjPoints.MJPT_ANQIDUI,
            })})
            pp.PlayModel:setResults(3, {points = bor({0,
                eMahjPoints.MJPT_SELFDRAWN,
                eMahjPoints.MJPT_SUFAN,
                eMahjPoints.MJPT_DADUIZI,
                eMahjPoints.MJPT_ONECOLOR,
                eMahjPoints.MJPT_ANQIDUI,
            })})

            myApp:emit("evt_SC_MAHJ_RESULT")
        end
    end


    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


return TestView