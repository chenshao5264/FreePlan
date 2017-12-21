--
-- Author: Chen
-- Date: 2017-11-23 14:48:45
-- Brief: 
--
pp = pp or {}

local setmetatable = setmetatable

--// 牌河每行最多放10张
pp.RIVER_EACH_LINE_COUNT = 9

--// 第一张牌离屏幕的距离
pp.PADDING_LEFT_HAND = { 
    [0] = 120,
    [1] = 180,
    [2] = 250,
    [3] = 110,
}
setmetatable(pp.PADDING_LEFT_HAND, {__index = function(table, key)
    return 0
end})

--// 离对应自己底部的距离
pp.PADDING_BOTTOM_HAND = { 
    [0] = 50,
    [1] = 150,
    [2] = 50,
    [3] = 150,
}
setmetatable(pp.PADDING_BOTTOM_HAND, {__index = function(table, key)
    return 0
end})

--// 相邻两张牌的间隔
pp.GRAP_HAND_CARD = { 
    [0] = 71,
    [1] = 23,
    [2] = 33,
    [3] = 23,
}
setmetatable(pp.GRAP_HAND_CARD, {__index = function(table, key)
    return 0
end})

pp.PADDING_LEFT_RIVER = {
    [0] = 450,
    [1] = 200,
    [2] = 450,
    [3] = 150,
}
setmetatable(pp.PADDING_LEFT_RIVER, {__index = function(table, key)
    return 0
end})

local PADDING_BOTTOM_HAND = pp.PADDING_BOTTOM_HAND

pp.PADDING_BOTTOM_RIVER = {
    [0] = PADDING_BOTTOM_HAND[0] + 150,
    [1] = PADDING_BOTTOM_HAND[1] + 150,
    [2] = PADDING_BOTTOM_HAND[2] + 120,
    [3] = PADDING_BOTTOM_HAND[3] + 150,
}
setmetatable(pp.PADDING_BOTTOM_RIVER, {__index = function(table, key)
    return 0
end})

--// 牌河中每张牌的间隔
pp.GRAP_RIVER_CARD = {
    [0] = 33,
    [1] = 30,
    [2] = 33,
    [3] = 30,
}
setmetatable(pp.GRAP_RIVER_CARD, {__index = function(table, key)
    return 0
end})

--// 牌河中每行间隔
pp.GRAP_RIVER_LINE = {
    [0] = 41.5,
    [1] = 48,
    [2] = 41.5,
    [3] = 48,
}
setmetatable(pp.GRAP_RIVER_LINE, {__index = function(table, key)
    return 0
end})

--// 
pp.PADDING_LEFT_FLAT = { 
    [0] = 110,
    [1] = 180,
    [2] = 300,
    [3] = 100,
}
setmetatable(pp.PADDING_LEFT_FLAT, {__index = function(table, key)
    return 0
end})

--// 每堆之间的间隔
pp.GRAP_FLAT_HEAP = {
    [0] = 110,
    [1] = 100,
    [2] = 110,
    [3] = 100,
}
setmetatable(pp.GRAP_FLAT_HEAP, {__index = function(table, key)
    return 0
end})


pp.CardType = Enum({
    "HAND",     --// 手
    "RIVER",    --// 河
    "FLAT",     --// 吃
})


--// 玩家头像
pp.NODE_PLAYERS_POSITION = {
    [0] = cc.p(60, 180),
    [1] = cc.p(display.right - 60, display.cy + 150),
    [2] = cc.p(300, display.top - 60),
    [3] = cc.p(60, display.cy + 150),
}

--// 定缺标志位置
pp.NODE_FIX_ICONS_POSITION = {
    [0] = cc.pAdd(pp.NODE_PLAYERS_POSITION[0], cc.p(60, -20)),
    [1] = cc.pAdd(pp.NODE_PLAYERS_POSITION[1], cc.p(-60, -20)),
    [2] = cc.pAdd(pp.NODE_PLAYERS_POSITION[2], cc.p(60, -20)),
    [3] = cc.pAdd(pp.NODE_PLAYERS_POSITION[3], cc.p(60, -20)),
}

--// 庄家标志位置
pp.NODE_BANKER_ICONS_POSITION = {
    [0] = cc.pAdd(pp.NODE_PLAYERS_POSITION[0], cc.p(35, 35)),
    [1] = cc.pAdd(pp.NODE_PLAYERS_POSITION[1], cc.p(-35, 35)),
    [2] = cc.pAdd(pp.NODE_PLAYERS_POSITION[2], cc.p(35, 35)),
    [3] = cc.pAdd(pp.NODE_PLAYERS_POSITION[3], cc.p(35, 35)),
}

--// 
pp.Res_mj_mutiply_chow = {"mj_mutiply_chow.png", 1}
pp.Res_mj_dq_icons     = {[0] = "mj_icon_dq_wan.png", "mj_icon_dq_tong.png", "mj_icon_dq_tiao.png"}
setmetatable(pp.Res_mj_dq_icons , {__index = function(table, key)
    return pp.Res_mj_dq_icons[0]
end})

--// 番型相关 1: 资源 2: 番数
pp.Point_Configs = {
    MJPT_SHOOT          = {"mj_points_hu.png",                  0},
    MJPT_SELFDRAWN      = {"mj_points_ziMo.png",                0},
    MJPT_SUFAN          = {"mj_points_suFan.png",               1},
    MJPT_DADUIZI        = {"mj_points_daDuiZi.png",             1},
    MJPT_ONECOLOR       = {"mj_points_qingYiSe.png",            2},
    MJPT_ANQIDUI        = {"mj_points_anQiDui.png",             2},
    MJPT_DAIYAO         = {"mj_points_daiYao.png",              2},
    MJPT_JIANGDUI       = {"mj_points_jiangDui.png",            3},
    MJPT_QINGDUI        = {"mj_points_qingDui.png",             3},
    MJPT_LONGQIDUI      = {"mj_points_longQiDui.png",           3},
    MJPT_DLONGQIDUI     = {"mj_points_shuangLongQiDui.png",     4},
    MJPT_QINGQIDUI      = {"mj_points_qingQiDui.png",           4},
    MJPT_QINGDAIYAO     = {"mj_points_qingDaiYao.png",          5},
    MJPT_TLONGQIDUI     = {"mj_points_sanLongQiDui.png",        5},
    MJPT_QLONGQIDUI     = {"mj_points_qingLongQiDui.png",       5},
    MJPT_QDLONGQIDUI    = {"mj_points_qingShuangLongQiDui.png", 6},
    MJPT_QTLONGQIDUI    = {"mj_points_qingSanLongQiDui.png",    7},
    MJPT_YJQIDUI        = {"mj_points_yaoJiuQiDui.png",         7},
    MJPT_DIANPAO        = {"mj_points_dianPao.png",             0},
    MJPT_KONGHUA        = {"mj_points_gangShangHua.png",        1},
    MJPT_KONGPAO        = {"mj_points_gangShangPao.png",        1},
    MJPT_QIANGGANG      = {"mj_points_qiangGangHu.png",         1},
    MJPT_TIANHU         = {"mj_points_tianHe.png",              3},
    MJPT_DIHU           = {"mj_points_diHe.png",                3},
    MJPT_HUAZHU         = {"mj_points_huaZhu.png",              0},
    MJPT_WUJIAO         = {"mj_points_wuJiao.png",              0},
    MJPT_GEN1           = {"mj_points_gen_1.png",               1},
    MJPT_GEN2           = {"mj_points_gen_2.png",               2},
    MJPT_GEN3           = {"mj_points_gen_3.png",               3},
    MJPT_GEN4           = {"mj_points_gen_4.png",               4},
    MJPT_BIGDAN         = {"mj_points_daDanDiao.png",           2},
}