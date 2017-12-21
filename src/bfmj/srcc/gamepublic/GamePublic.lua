local GamePublic = {}
require "framework.utils.bit"

local math_pow = math.pow

function GamePublic.bor(tbl)
	local p = 0
	for _, v in pairs(tbl) do
		p = bit.bor(v, p)
	end
	return p
end

function GamePublic.band(a, b)
	return bit.band(a, b)
end
---------------------------------------------------------------
GamePublic.MahjOp = {
	DISCARD 		= math_pow(2, 0),
	GIVEUP 			= math_pow(2, 1),
	LEFTCHOW 		= math_pow(2, 2),
	MIDCHOW 		= math_pow(2, 3),
	RIGHTCHOW 		= math_pow(2, 4),
	--CHOW 			= 28,
	PONG 			= math_pow(2, 5),
	EXPOSEDKONG 	= math_pow(2, 6),
	CONCEALEDKONG 	= math_pow(2, 7),
	REPLENISHKONG 	= math_pow(2, 8),
	WINDKONG 		= math_pow(2, 9),
	REWINDKONG 		= math_pow(2, 10),
	--KONG 			= 1984,
	SELFDRAWN 		= math_pow(2, 11),
	SHOOT 			= math_pow(2, 12),
	--WIN 			= 14336,
}

GamePublic.MahjOp.CHOW = GamePublic.bor({
	GamePublic.MahjOp.LEFTCHOW, 
	GamePublic.MahjOp.MIDCHOW, 
	GamePublic.MahjOp.RIGHTCHOW })

GamePublic.MahjOp.KONG = GamePublic.bor({
	GamePublic.MahjOp.EXPOSEDKONG,
	GamePublic.MahjOp.CONCEALEDKONG,
	GamePublic.MahjOp.REPLENISHKONG,
	GamePublic.MahjOp.WINDKONG,
	GamePublic.MahjOp.REWINDKONG })

GamePublic.MahjOp.WIN = GamePublic.bor({
	GamePublic.MahjOp.SELFDRAWN,
	GamePublic.MahjOp.SHOOT,
	GamePublic.MahjOp.TIANHU })
---------------------------------------------------------------
GamePublic.eWindKong_state = {
	eKongState_Feng = math_pow(2, 0),
	eKongState_ZFB  = math_pow(2, 1),
	eKongState_One  = math_pow(2, 2),
	eKongState_Nine = math_pow(2, 3),
	--eKongState_All = eKongState_Feng | eKongState_ZFB | eKongState_One | eKongState_Nine,
}
GamePublic.eWindKong_state.eKongState_All = GamePublic.bor({
	GamePublic.eWindKong_state.eKongState_Feng,
	GamePublic.eWindKong_state.eKongState_ZFB,
	GamePublic.eWindKong_state.eKongState_One,
	GamePublic.eWindKong_state.eKongState_Nine
})

GamePublic.eWindKong_Par = {
	eKongPar_Feng   = 41,
	eKongPar_ZFB    = 42,
	eKongPar_One    = 43,
	eKongPar_Nine   = 44,
	eKongPar_BuFeng = 45,
	eKongPar_BuZFB  = 46,
	eKongPar_BuOne  = 47,
	eKongPar_BuNine = 48
} 

GamePublic.eWindKong_Num = {
	eKongNum_Null  = 53,
	eKongNum_One   = 54,
	eKongNum_Two   = 55,
	eKongNum_Three = 56,
	eKongNum_Four  = 57
}

GamePublic.eMahjPoints = {
	MJPT_SHOOT 			= math_pow(2, 0),
	MJPT_SELFDRAWN 		= math_pow(2, 1),		--自摸
	MJPT_SUFAN 			= math_pow(2, 2),		--素番
	MJPT_DADUIZI 		= math_pow(2, 3),		--大对子
	MJPT_ONECOLOR 		= math_pow(2, 4),		--清一色
	MJPT_ANQIDUI 		= math_pow(2, 5),		--暗七对
	MJPT_DAIYAO 		= math_pow(2, 6),		--带幺
	MJPT_JIANGDUI 		= math_pow(2, 7),		--将对
	MJPT_QINGDUI 		= math_pow(2, 8),		--清对
	MJPT_LONGQIDUI 		= math_pow(2, 9),		--龙七对
	MJPT_DLONGQIDUI 	= math_pow(2, 10),	 	--双龙七对
	MJPT_QINGQIDUI 		= math_pow(2, 11),		--清七对
	MJPT_QINGDAIYAO 	= math_pow(2, 12),		--清带幺
	MJPT_TLONGQIDUI 	= math_pow(2, 13),		--三龙七对
	MJPT_QLONGQIDUI 	= math_pow(2, 14),		--清龙七对
	MJPT_QDLONGQIDUI 	= math_pow(2, 15),		--清双龙七对
	MJPT_QTLONGQIDUI 	= math_pow(2, 16),		--清三龙七对
	MJPT_YJQIDUI 		= math_pow(2, 17),		--幺九七对
	MJPT_DIANPAO 		= math_pow(2, 18),		--点炮
	MJPT_KONGHUA 		= math_pow(2, 19),		--杠上花
	MJPT_KONGPAO 		= math_pow(2, 20),		--杠上炮
	MJPT_QIANGGANG 		= math_pow(2, 21),		--抢杠
	MJPT_TIANHU 		= math_pow(2, 22),		--天胡
	MJPT_DIHU 			= math_pow(2, 23),		--地胡
	MJPT_HUAZHU 		= math_pow(2, 24),		--花猪
	MJPT_WUJIAO 		= math_pow(2, 25),		--无叫
	MJPT_GEN1 			= math_pow(2, 26),		--根1
	MJPT_GEN2 			= math_pow(2, 27),		--根2
	MJPT_GEN3 			= math_pow(2, 28),		--根3
	MJPT_GEN4 			= math_pow(2, 29),		--根4
	MJPT_BIGDAN 		= math_pow(2, 30),        --大单吊
}

GamePublic.kongState   = GamePublic.eWindKong_state.eKongState_All -- ps：针对不同麻将的杠规程 可能不同
GamePublic.isThreeFeng = false
GamePublic.maxTile     = 37
GamePublic.minTile     = 1
GamePublic.mahjCount   = 108

GamePublic.isCanWINDKONG = false --// 是否可以旋风杠(ccmj)
GamePublic.isCanZFB      = false --// 是否有中发白杠(ccmj)
GamePublic.isCanOne      = false --// 是否有妖杠(ccmj)
GamePublic.isCanNine     = false --// 是否有九杠(ccmj)

---------------------------------------------------------------
function GamePublic.isSingleChow(op) --是否是单吃
	local count = 0
	if GamePublic.band(op, GamePublic.MahjOp.LEFTCHOW) ~= 0 then
		count = count + 1
	end
	if GamePublic.band(op, GamePublic.MahjOp.MIDCHOW) ~= 0 then
		count = count + 1
	end
	if GamePublic.band(op, GamePublic.MahjOp.RIGHTCHOW) ~= 0 then
		count = count + 1
	end
	return count == 1
end

function GamePublic.countTile(opTile, tiles)
	local num = 0
	for _, tile in pairs(tiles) do
		if tile == opTile then
			num = num + 1
		end
	end
	return num
end

function GamePublic.isValidTile(tile)
	if tile >= GamePublic.minTile and tile <= GamePublic.maxTile then
		return true
	end
	return false
end

function GamePublic.findTile(tile, tiles)
	for _, t in pairs(tiles) do
		if t == tile then
			return true
		end
	end
	return false
end

return GamePublic
