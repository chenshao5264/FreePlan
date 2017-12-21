--
-- Author: ChenShao
-- Date: 2015-08-12 15:02:27
--
local KongLogic = {}

local GamePublic = pp.GamePublic

local MahjOp          = GamePublic.MahjOp
local bor             = GamePublic.bor
local band            = GamePublic.band
local findTile        = GamePublic.findTile
local eWindKong_state = GamePublic.eWindKong_state
local eWindKong_Par   = GamePublic.eWindKong_Par
local isValidTile     = GamePublic.isValidTile
local countTile       = GamePublic.countTile

KongLogic.windKongState = 0
KongLogic.isBaoTing     = false

local _bFeng  = false
local _bNine  = false
local _bOne   = false
local _bZFB   = false
local _tmpPut = {}

local _canKongTiles = {}

--// 初始化特殊杠的字段
local function initType()
    _bFeng  = false
    _bNine  = false
    _bOne   = false
    _bZFB   = false
    _tmpPut = {}
end

local function isFeng(tiles)
    local index = 0
    for i = 31, 34 do
        if countTile(i, tiles) > 0 then
            index = index + 1
        end
    end

    if index == 4 then
        return true
    end
    return false
end

local function isZFB(tiles)
    local index = 0
    for i = 35, 37 do
        if countTile(i, tiles) > 0 then
            index = index + 1
        end
    end

    if index == 3 then
        return true
    end
    return false
end

local function isNine(tiles)
    if countTile(9, tiles) > 0 and countTile(19, tiles) > 0 and countTile(29, tiles) > 0 then
        return true
    end
    return false
end

local function isOne(tiles)
    if countTile(1, tiles) > 0 and countTile(11, tiles) > 0 and countTile(21, tiles) > 0 then
        return true
    end
    return false
end

--// 检测是否有特殊杠牌，风杠、中发白杠、九杠、妖杠 (ccmj)
local function check(flatTiles)
    _tmpPut = {}

    for i = 1, #flatTiles do
        if flatTiles[i] == -1 or flatTiles[i] == 255 then
            if isFeng(_tmpPut) then
                _bFeng = true
            elseif isZFB(_tmpPut) then
                _bZFB = true
            elseif isNine(_tmpPut) then
                _bNine = true
            elseif isOne(_tmpPut) then
                _bOne = true
            end
            _tmpPut = {}
        else
            _tmpPut[#_tmpPut + 1] = flatTiles[i]
        end
    end
end

function KongLogic:clearData()
    KongLogic.windKongState = 0
    KongLogic.isBaoTing     = false
end

--// 用于旋风杠，妖九杠 (ccmj)
function KongLogic:addKongState(state)
    KongLogic.windKongState = bor({KongLogic.windKongState, state})
end

function KongLogic:checkKongTile(data)

    _canKongTiles = {}
    local op        = data.op
    local opTile    = data.opTile
    local handTiles = clone(data.handTiles) --// 下面对handTiles进行了修改，所以clone
    local flatTiles = data.flatTiles
    local drawTile  = data.drawTile 
    
    local isThreeFeng = GamePublic.isThreeFeng
    local kongState   = GamePublic.kongState
    
    
    initType()
    
    check(flatTiles)

    
    local tileCheck = -1
    if opTile > 0  then 
        handTiles[#handTiles + 1] = opTile
        tileCheck = opTile
    elseif drawTile ~= 0 then 
        tileCheck = drawTile
    end

    --// 一般mj的三种杠
    --明杠
    if band(op, MahjOp.EXPOSEDKONG) ~= 0 then
        _canKongTiles[#_canKongTiles + 1] = opTile
    end

    --暗杠
    if band(op, MahjOp.CONCEALEDKONG) ~= 0 then
        cclog.warn("暗杠")
        for i = 1, #handTiles do
            if countTile(handTiles[i], handTiles) == 4 then 
                if countTile(handTiles[i], _canKongTiles) == 0 then
                    _canKongTiles[#_canKongTiles + 1] = handTiles[i]
                end
            end
        end
    end

    --补杠
    if band(op, MahjOp.REPLENISHKONG) ~= 0 then
        for i = 1, #handTiles do
            local tmp = handTiles[i] 
            for j = 1, #flatTiles - 2 do
                if flatTiles[j] == tmp and flatTiles[j + 1] == tmp and flatTiles[j + 2] == tmp then
                    if countTile(handTiles[i], _canKongTiles) == 0 then
                        _canKongTiles[#_canKongTiles + 1] = handTiles[i]
                    end
                    break
                end
            end
        end
    end

    --旋风杠
    if band(op, MahjOp.WINDKONG) ~= 0 then
        local fengNum = 0
        for i = 31, 34 do
            if countTile(i, handTiles) > 0 then
                fengNum = fengNum + 1
            end
        end

        if isThreeFeng == false then
            if not _bFeng and
             band(kongState, eWindKong_state.eKongState_Feng) ~= 0  and
            countTile(31, handTiles) > 0 and countTile(32, handTiles) > 0 and
            countTile(33, handTiles) > 0 and countTile(34, handTiles) > 0 then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_Feng
            end
        else
            if not _bFeng and fengNum >= 3 then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_Feng
            end
        end 

        --中发白杠
        if not _bZFB and
         band(kongState, eWindKong_state.eKongState_ZFB) ~= 0 and
        countTile(35, handTiles) > 0 and countTile(36, handTiles) > 0 and
        countTile(37, handTiles) > 0 then
            _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_ZFB
        end

        --幺杠
        if not _bOne and
        band(kongState, eWindKong_state.eKongState_One) ~= 0 and
        countTile(1, handTiles) > 0 and countTile(11, handTiles) > 0 and
        countTile(21, handTiles) > 0 then
            _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_One
        end

        --九杠
        if not _bNine and
         band(kongState, eWindKong_state.eKongState_Nine) ~= 0 and
        countTile(9, handTiles) > 0 and countTile(19, handTiles) > 0 and
        countTile(29, handTiles) > 0 then
            _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_Nine
        end

    elseif  band(op, MahjOp.REWINDKONG) ~= 0 then
        --补旋风杠
        if _bFeng and
         band(KongLogic.windKongState, eWindKong_state.eKongState_Feng) ~= 0 then
            if KongLogic.isBaoTing and (tileCheck >= 31 and tileCheck <= 34) then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuFeng
            elseif not KongLogic.isBaoTing then
                for i = 31, 34 do 
                    if countTile(i, handTiles) > 0 then
                        _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuFeng
                    end
                end
            end
        end

        --补中发白
        if _bZFB and
         band(KongLogic.windKongState, eWindKong_state.eKongState_ZFB) ~= 0 then
            if KongLogic.isBaoTing and (tileCheck >= 35 and tileCheck <= 37) then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuZFB
            elseif not KongLogic.isBaoTing then
                for i = 35, 37 do 
                    if countTile(i, handTiles) > 0 then
                        _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuZFB
                    end
                end
            end
        end

        --补幺鸡
        if _bOne and
         band(KongLogic.windKongState, eWindKong_state.eKongState_One) ~= 0 then
            if KongLogic.isBaoTing and (tileCheck % 10 == 1 and tileCheck < 30) then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuOne
            elseif not KongLogic.isBaoTing then
                for i = 0, 2 do 
                    if countTile(i * 10 + 1, handTiles) > 0 then
                        _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuOne
                    end
                end
            end
        end

        --补九杠
        if _bNine and
         band(KongLogic.windKongState, eWindKong_state.eKongState_Nine) ~= 0 then
            if KongLogic.isBaoTing and (tileCheck % 10 == 9 and tileCheck < 30) then
                _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuNine
            elseif not KongLogic.isBaoTing then
                for i = 0, 2 do 
                    if countTile(i * 10 + 9, handTiles) > 0 then
                        _canKongTiles[#_canKongTiles + 1] = eWindKong_Par.eKongPar_BuNine
                    end
                end
            end
        end
    end

    if #_canKongTiles == 1 then
        if _canKongTiles[1] >= eWindKong_Par.eKongPar_BuFeng and _canKongTiles[1] <= eWindKong_Par.eKongPar_BuNine then
            if _canKongTiles[1] ==  eWindKong_Par.eKongPar_BuFeng then
                if KongLogic.isBaoTing and (tileCheck >= 31 and tileCheck <= 34) then
                    return tileCheck
                elseif not KongLogic.isBaoTing then
                    for i = 31, 34 do --补旋风杠
                        if countTile(i, handTiles) > 0 then 
                            return i 
                        end
                    end
                end
            elseif _canKongTiles[1] ==  eWindKong_Par.eKongPar_BuZFB then
                if KongLogic.isBaoTing and (tileCheck >= 35 and tileCheck <= 37) then
                    return tileCheck
                elseif not KongLogic.isBaoTing then
                    for i = 35, 37 do --补中发白
                        if countTile(i, handTiles) > 0 then 
                            return i 
                        end
                    end
                end
            elseif _canKongTiles[1] ==  eWindKong_Par.eKongPar_BuOne then
                if KongLogic.isBaoTing and (tileCheck % 10 == 1 and tileCheck < 30) then
                    return tileCheck
                elseif not KongLogic.isBaoTing then
                    for i = 0, 2 do --补幺杠
                        if countTile(i * 10 + 1, handTiles) > 0 then 
                            return i * 10 + 1 
                        end
                    end
                end
            elseif _canKongTiles[1] ==  eWindKong_Par.eKongPar_BuNine then
                if KongLogic.isBaoTing and (tileCheck % 10 == 9 and tileCheck < 30) then
                    return tileCheck
                elseif not KongLogic.isBaoTing then
                    for i = 0, 2 do --补九杠
                        if countTile(i * 10 + 9, handTiles) > 0 then 
                            return i * 10 + 9 
                        end
                    end 
                end
            end
        else
            return _canKongTiles[1]
        end

    return _canKongTiles[1]
    
    else
        return -1
    end
end

function KongLogic:isInKong(tile)
     local bFind = findTile(tile, _canKongTiles)

     if bFind == false then
        if tile >= 31 and tile <= 34 then
            return findTile(eWindKong_Par.eKongPar_Feng, _canKongTiles) or
                findTile(eWindKong_Par.eKongPar_BuFeng, _canKongTiles)
        end

        if tile >= 35 and tile <= 37 then
            return findTile(eWindKong_Par.eKongPar_ZFB, _canKongTiles) or
                findTile(eWindKong_Par.eKongPar_BuZFB, _canKongTiles)
        end

        if tile % 10 == 1 then
            return findTile(eWindKong_Par.eKongPar_One, _canKongTiles) or
                findTile(eWindKong_Par.eKongPar_BuOne, _canKongTiles)
        end

        if tile % 10 == 9 then
            return findTile(eWindKong_Par.eKongPar_Nine, _canKongTiles) or
                findTile(eWindKong_Par.eKongPar_BuNine, _canKongTiles)
        end
     else
        return true
     end
end

--// 获取kong的具体值
function KongLogic:checkKongOp(data)
    local tile = data.tile

    if KongLogic:isInKong(tile) == false then
        return 0
    end

    local handTiles = data.handTiles
    local drawTile  = data.drawTile

    if findTile(tile, _canKongTiles) and isValidTile(tile) then
        if countTile(tile, handTiles) == 3 and drawTile ~= tile then
            return MahjOp.EXPOSEDKONG
        elseif countTile(tile, handTiles) == 4 or (countTile(tile, handTiles) == 3 and drawTile == tile) then
            return MahjOp.CONCEALEDKONG
        else
            return MahjOp.REPLENISHKONG
        end
    else
        if KongLogic.isBaoTing then
            if findTile(eWindKong_Par.eKongPar_Feng, _canKongTiles) then
                return MahjOp.WINDKONG
            elseif findTile(eWindKong_Par.eKongPar_BuFeng, _canKongTiles) then
                return MahjOp.REWINDKONG
            end

            if findTile(eWindKong_Par.eKongPar_ZFB, _canKongTiles) then
                return MahjOp.WINDKONG
            elseif findTile(eWindKong_Par.eKongPar_BuZFB, _canKongTiles) then
                return MahjOp.REWINDKONG
            end

            if findTile(eWindKong_Par.eKongPar_One, _canKongTiles) then
                return MahjOp.WINDKONG
            elseif findTile(eWindKong_Par.eKongPar_BuOne, _canKongTiles) then
                return MahjOp.REWINDKONG
            end

            if findTile(eWindKong_Par.eKongPar_Nine, _canKongTiles) then
                return MahjOp.WINDKONG
            elseif findTile(eWindKong_Par.eKongPar_BuNine, _canKongTiles) then
                return MahjOp.REWINDKONG
            end
        else

            if tile >= 31 and tile <= 34 or tile == eWindKong_Par.eKongPar_Feng or eWindKong_Par.eKongPar_BuFeng then
                if findTile(eWindKong_Par.eKongPar_Feng, _canKongTiles) then
                    return MahjOp.WINDKONG
                elseif findTile(eWindKong_Par.eKongPar_BuFeng, _canKongTiles) then
                    return MahjOp.REWINDKONG
                end
            end

            if tile >= 35 and tile <= 37 or tile == eWindKong_Par.eKongPar_ZFB or eWindKong_Par.eKongPar_BuZFB then
                if findTile(eWindKong_Par.eKongPar_ZFB, _canKongTiles) then
                    return MahjOp.WINDKONG
                elseif findTile(eWindKong_Par.eKongPar_BuZFB, _canKongTiles) then
                    return MahjOp.REWINDKONG
                end
            end

            if tile % 10 == 1 or tile == eWindKong_Par.eKongPar_One or eWindKong_Par.eKongPar_BuOne then
                if findTile(eWindKong_Par.eKongPar_One, _canKongTiles) then
                    return MahjOp.WINDKONG
                elseif findTile(eWindKong_Par.eKongPar_BuOne, _canKongTiles) then
                    return MahjOp.REWINDKONG
                end
            end

            if tile % 10 == 9 or tile == eWindKong_Par.eKongPar_Nine or eWindKong_Par.eKongPar_BuNine then
                if findTile(eWindKong_Par.eKongPar_Nine, _canKongTiles) then
                    return MahjOp.WINDKONG
                elseif findTile(eWindKong_Par.eKongPar_BuNine, _canKongTiles) then
                    return MahjOp.REWINDKONG
                end
            end

        end
    end 
    return 0
end

return KongLogic