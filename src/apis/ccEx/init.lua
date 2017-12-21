--
-- Author: Your Name
-- Date: 2017-06-14 11:02:59
--
require "ccEx.ccWidget"

require "ccEx.ccButton"

require "ccEx.ccDrawNode"

require "ccEx.ccGroup"

require "ccEx.ccNode"

require "ccEx.ccText"

require "ccEx.ccGridNode"

cc.RichTextEx  = require("ccEx.ccRichText")

cc.HVNode      = require("ccEx.ccHVNode")

cc.BackpackBox = require("ccEx.ccBackpackBox")

cc.BackpackBoxScrollView = require("ccEx.BackpackScrollView")

-- cc.DebugLayer = require("ccEx.ccDebugLayer")

-- EventProxy 使用
-- 在MyApp.lua中
-- cc(self):addComponent("ccEx.cc.components.behavior.EventProtocol"):exportMethods()

-- 监听
-- cc.EventProxy.new(myApp, node)
--    :on("Evt_XXX", function(evt)
--    end)

--    :once("Evt_XXX", function(evt) -- 只监听一次
--    end)

-- 发送
-- myApp:emit("Evt_XXX", {name = "11111", age = 10})

require "ccEx.cc.init"


require "ccEx.functions"

cc.ScheduleManager = require("ccEx.ScheduleManager")

cc.CallFuncSequence = require("ccEx.CallFuncSequence")

cc.Next = require("ccEx.ccNext")