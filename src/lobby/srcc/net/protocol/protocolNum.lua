local M = {}

local WM_USER = 1024
M.PROTOCOL_GAMESERVER      = (WM_USER + 20000)      --GM协议
M.PROTOCOL_GAMECLIENT      = (WM_USER + 30000)      --GM协议

M.CS_HEARTBEAT_CHECK_P = 11026
M.SC_HEARTBEAT_CHECK_P = 11027      --// 心跳


M.PL_PHONE_CL_LOGIN_REQ_P        = 51024    --// 登录loginserver请求
M.PL_PHONE_LC_LOGIN_ACK_P        = 51025    --// 登陆loginserver请求回复

M.CL_PHONE_NOPHONECODE_REG_REQ_P = 51052    --// 注册请求
M.LC_PHONECODE_REG_ACK_P         = 12044 
M.PL_PHONE_CS_USERLOGIN_REQ_P    = 51031    --// 登录lobbyserver请求
M.PL_PHONE_CS_GAMELIST_REQ_P     = 51035    --// 请求游戏列表
M.PL_PHONE_CG_LOGIN_REQ_P        = 51037    --// 登录gameserver请求
M.CG_HANDUP_P                    = 13038    --// 举手请求
M.GC_HANDUP_P                    = 13039    --// 举手请求广播
M.GC_STARTTIMER_P                = 13045    --// 启动客户段定时器
M.GC_GAME_START_P                = 13040    --// 本桌游戏开始通知
M.CG_ENTERTABLE_REQ_P            = 13032    --// 玩家请求坐桌子
M.PL_PHONE_SC_USERLOGIN_ACK_P    = 51034    --// 登录lobbyserver请求回复

M.DC_USER_LOAD_BROKEN_GAME_P     = 11575    --// 获取断线游戏列表
M.PL_PHONE_SC_GAMELIST_ACK_P     = 51036    --// 请求游戏列表回复
M.PL_PHONE_GC_LOGIN_ACK_P        = 51038    --// 游戏服务器登陆结果
M.GC_ENTERTABLE_ACK_P            = 13033    --// 坐桌子回应
M.GC_TABLE_USERLIST_P            = 13031    --// 发送桌子用户列表给客户端
M.GC_ENTERTABLE_P                = 13035    --// 加入桌子广播
M.GC_LEAVETABLE_P                = 13037    --// 离开桌子广播
M.GC_GAMEUSER_UP_P               = 13028    --// 更新用户数据

M.PL_PHONE_IOS_RECHARGEINFO_REQ_P = 51056   --// 充值商品信息请求
M.PL_PHONE_IOS_RECHARGEINFO_ACK_P = 51057   --// 
M.PL_PHONE_IOS_RECHARGE_REQ_P     = 51053   --// 充值商品信息回复 
M.PL_PHONE_IOS_RECHARGE_ACK_P     = 51055   --// 充值结果


-- M.PL_PHONE_LC_SHOWFIRSTINFO_ACK_P = 51060    --// 发送给客户端是否显示首冲按钮
M.PL_PHONE_LC_INISIGNININFO_ACK_P = 51079   --// 初始化签到信息给客户端
M.PL_PHONE_CL_SIGNIN_REQ_P        = 51080   --// 签到请求
M.PL_PHONE_LC_SIGNIN_ACK_P        = 51081   --// 签到回复

--// 服务器暂时屏蔽发送
-- M.SC_LOGIN_TOKEN_P                = 11573    --// 登陆成功服务器发送玩家代币信息
return M
