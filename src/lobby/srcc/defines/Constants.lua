--
-- Author: Your Name
-- Date: 2017-12-17 20:46:03
--


local gg = gg or {}

--// 支付方式
gg.PayType = {
    DIAMOND = 1,    --// 钻石
    RMB     = 2,    --// rmb    
}

--// 桌子状态
gg.TableStatus = {
    IDLE   = 0,   --// 没有人
    WAIT   = 1,   --// 有人且未坐满
    READY  = 2,   --// 坐满但未开始
    GAMING = 3,   --// 已开始
}

--// 玩家状态
gg.UserStatus = {
    WAIT   = 3,     --// 坐着未准备
    READY  = 4,     --// 坐着已准备
    GAMING = 5,     --// 游戏中
    BOKEN  = 7,     --// 断线
}

--// 玩家行为
gg.UserAction = {
    ENTER_TABLE = 10,    --// 进入桌子
    LEAVE_TABLE = 20,    --// 离开桌子
}