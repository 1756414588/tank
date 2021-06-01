
-- if package.loaded["app.controller.SchedulerSet"] then
-- 	print("app.init SchedulerSet destroy !!!")
-- 	SchedulerSet.destroy()
-- end

require("app.controller.ManagerTimer")  -- 使用scheduler，不能使用require_ex加载
require("app.controller.SchedulerSet")  -- 使用scheduler，不能使用require_ex加载

ManagerSound = require_ex("app.controller.ManagerSound")

require_ex("app.controller.UiDirector")
UiNode = require_ex("app.controller.UiNode")
