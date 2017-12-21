--
-- Author: ChenShao
-- Date: 2015-08-28 10:59:07
--

gg = {}

require("public.iconv")
require("AppConfig")

require("defines.Dialogs")
require("defines.Constants")

--// 单例
gg.AppModel  = require("models.AppModel").new()
--// 玩家数据 单例
gg.Player    = require("models.Player").new()
--// 房间数据 单例
gg.RoomModel = require("models.RoomModel").new()
--// 协议号 单例
gg.protocolNum    = require("net.protocol.protocolNum")

--// 消息处理
gg.MsgHandler     = require("net.MsgHandler")
--// socket 单例
gg.ClientSocket   = require("net.ClientSocket").new()
--// 消息请求
gg.RequestManager = require("net.RequestManager")
--// 返回消息错误码
gg.ErrorMsg       = require("defines.ErrorMsg")


--// 存储与桌子相关联的数据 单例
gg.TableModel = require("models.TableModel").new()

--// 全局工具类
gg.Global  = require("public.Global")
gg.Utility = require("public.utility")

--// 弹窗管理类
gg.UIHelper = require("helpers.UIHelper")

gg.AudioHelper = require("helpers.AudioHelper")
--// 动作效果
gg.ActionHelper = require("helpers.ActionHelper")