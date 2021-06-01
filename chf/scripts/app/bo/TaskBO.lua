--
-- Author: gf
-- Date: 2015-09-22 10:00:56
--

TaskBO = {}

--errorCode 606处理
function socket_error_606_callback(code)
	TaskBO.asynGetMajorTask()
end

function TaskBO.init()
	if not TaskMO.updateResOutput_ then
		TaskMO.updateResOutput_ = Notify.register(LOCAL_RES_EVENT, function()
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_RES,type = RESOURCE_ID_IRON})
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_RES,type = RESOURCE_ID_OIL})
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_RES,type = RESOURCE_ID_COPPER})
			end)
	end
end

function TaskBO.updateMajorTask(data)
	TaskMO.majorTaskList_ = {}
	
	if not data then return end

	if table.isexist(data, "task") then
		TaskMO.majorTaskList_ = PbProtocol.decodeArray(data["task"])
		TaskBO.sortFun(TaskMO.majorTaskList_,TASK_TYPE_MAJOR)
		gdump(TaskMO.majorTaskList_,"TaskMO.majorTaskList_")
	end
end

function TaskBO.updateDaylyTask(data)
	
	TaskMO.daylyTaskList_ = {}
	if table.isexist(data, "task") then
		TaskMO.daylyTaskList_ = PbProtocol.decodeArray(data["task"])
		TaskBO.sortFun(TaskMO.daylyTaskList_,TASK_TYPE_DAYLY)
		gdump(TaskMO.daylyTaskList_,"TaskMO.daylyTaskList_")
	end
	if table.isexist(data, "taskDayiy") then
		TaskMO.taskDayiy = PbProtocol.decodeRecord(data["taskDayiy"])
		gdump(TaskMO.taskDayiy,"TaskMO.taskDayiy")
	end
end

function TaskBO.updateLiveTask(data)
	if table.isexist(data, "task") then
		TaskMO.liveTaskList_ = PbProtocol.decodeArray(data["task"])
		TaskBO.sortFun(TaskMO.liveTaskList_,TASK_TYPE_LIVE)
		-- gdump(TaskMO.liveTaskList_,"TaskMO.liveTaskList_")
	end
	if table.isexist(data, "taskLive") then
		TaskMO.taskLive = PbProtocol.decodeRecord(data["taskLive"])
		-- gdump(TaskMO.taskLive,"TaskMO.taskLive")
	end
	if table.isexist(data, "endTime") then
		TaskMO.taskActiveEndTime_ = data.endTime
	end
	if table.isexist(data, "states") then
		TaskMO.taskActiveStatus_ = data.states
		Notify.notify(LOCAL_ACTIVITY_TASK_LIVE)
	end
end

function TaskBO.sortFun(list,type)
	local sortFun = function(a,b)
		if a.status == b.status then
			return a.taskId < b.taskId
		else
			return a.status > b.status
		end
	end

	local sortFun1 = function(a,b)
		if a.accept == b.accept then
			return a.taskId < b.taskId
		else
			return a.accept > b.accept
		end
	end
	if type == TASK_TYPE_DAYLY then
		table.sort(list,sortFun1)
	else
		table.sort(list,sortFun)
	end
	
end


function TaskBO.asynGetMajorTask(doneCallback)
	local function parseResult(name, data)
		TaskBO.updateMajorTask(data)

		Notify.notify(LOCAL_TASK_UPDATE_EVENT)
		Notify.notify(LOCAL_TASK_FINISH_EVENT)
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetMajorTask"))
end

function TaskBO.asynGetDayiyTask(doneCallback,coin)

	local function parseResult(name, data)
		TaskBO.updateDaylyTask(data)
		--通知
		Notify.notify(LOCAL_TASK_UPDATE_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDayiyTask"))
end

function TaskBO.asynRefreshDayiyTask(doneCallback)
	local function parseResult(name, data)
		TaskBO.updateDaylyTask(data)
		--TK统计
		TKGameBO.onUseCoinTk(TASK_DAYLY_REFRESH_COIN,TKText[35],TKGAME_USERES_TYPE_CONSUME)
		--减少金币
		UserMO.reduceResource(ITEM_KIND_COIN, TASK_DAYLY_REFRESH_COIN)
		--通知
		Notify.notify(LOCAL_TASK_UPDATE_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("RefreshDayiyTask"))
end



function TaskBO.asynGetLiveTask(doneCallback)
	local function parseResult(name, data)
		TaskBO.updateLiveTask(data)
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetLiveTask"))
end

--新活跃度
function TaskBO.asynNewGetLiveTask(doneCallback)
	local function parseResult(name, data)
		TaskBO.updateLiveTask(data)
		
		if doneCallback then doneCallback(data) end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("NewGetLiveTask"))
end

function TaskBO.asynTaskAward(doneCallback,type,taskId,awardType)
	local function parseResult(name, data)
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)

			--TK统计
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_RESOURCE then
					TKGameBO.onGetResTk(award.id,award.count,TKText[32],TKGAME_USERES_TYPE_CONSUME)
				elseif award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[32])
				end
			end
		end
		--任务数据更新
		local tasklist
		if type == TASK_TYPE_MAJOR then 
			tasklist = TaskMO.majorTaskList_
		else
			tasklist = TaskMO.daylyTaskList_
		end
		--删除已完成任务
		for index=1,#tasklist do
			local task = tasklist[index]
			if task.taskId == taskId then
				table.remove(tasklist,index)
				break
			end
		end
		--添加新任务
		if table.isexist(data, "task") then
			local tasks = PbProtocol.decodeArray(data["task"])
			for index=1,#tasks do
				table.insert(tasklist,tasks[index])
			end
		end
		--如果是日常任务
		if type == TASK_TYPE_DAYLY then
			--增加每日完成次数
			TaskMO.taskDayiy.dayiy = TaskMO.taskDayiy.dayiy + 1
			--如果是金币完成 减少金币
			if awardType == TASK_GET_AWARD_TYPE_GOLD then
				--TK统计 金币消耗
				TKGameBO.onUseCoinTk(TASK_DAYLY_QUICK_FINISH_COIN,TKText[33],TKGAME_USERES_TYPE_CONSUME)
				UserMO.reduceResource(ITEM_KIND_COIN, TASK_DAYLY_QUICK_FINISH_COIN)
			end
			--通知
			Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
		end

		--通知
		Notify.notify(LOCAL_TASK_UPDATE_EVENT)
		Notify.notify(LOCAL_TASK_FINISH_EVENT)
		Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
		Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
		
		if doneCallback then doneCallback() end
		--触发引导
		NewerBO.showNewerGuide()
		-- 埋点
		Statistics.postPoint(taskId)
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("TaskAward",{taskId = taskId, awardType = awardType}))
end

--接受每日任务
function TaskBO.asynAcceptTask(doneCallback,task)
	--测试
	--改变任务状态
	-- task.accept = 1
	-- --通知
	-- Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
	-- Notify.notify(LOCAL_TASK_UPDATE_EVENT)
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		--改变任务状态
		task.accept = 1
		--通知
		Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
		Notify.notify(LOCAL_TASK_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AcceptTask",{taskId = task.taskId}))
end

function TaskBO.asynAcceptNoTask(doneCallback)
	--测试
	--改变任务状态
	-- for index=1,#TaskMO.daylyTaskList_ do
	-- 	local task = TaskMO.daylyTaskList_[index]
	-- 	task.accept = 0
	-- end
	-- --通知
	-- Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
	-- Notify.notify(LOCAL_TASK_UPDATE_EVENT)
	-- if doneCallback then doneCallback() end
	-- do return end


	local function parseResult(name, data)
		--改变任务状态
		for index=1,#TaskMO.daylyTaskList_ do
			local task = TaskMO.daylyTaskList_[index]
			task.accept = 0
			task.schedule = 0
			task.status = 0
		end
		--通知
		Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
		Notify.notify(LOCAL_TASK_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AcceptNoTask"))
end

function TaskBO.asynTaskDaylyReset(doneCallback)
	--测试
	-- TaskMO.taskDayiy.dayiy = 0
	-- TaskMO.taskDayiy.dayiyCount = TaskMO.taskDayiy.dayiyCount + 1
	-- Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		TaskMO.taskDayiy.dayiy = 0
		TaskMO.taskDayiy.dayiyCount = TaskMO.taskDayiy.dayiyCount + 1
		--扣除金币
		--TK统计
		TKGameBO.onUseCoinTk(TASK_DAYLY_RESET_COIN,TKText[34],TKGAME_USERES_TYPE_CONSUME)
		UserMO.reduceResource(ITEM_KIND_COIN, TASK_DAYLY_RESET_COIN)
		Notify.notify(LOCAL_DAYLY_TASK_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("TaskDaylyReset"))
end

function TaskBO.asynTaskLiveAward(doneCallback,awardId)
	local function parseResult(name, data)
		-- TaskMO.taskActiveStatus_ = data.status
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)

			--TK统计 金币获得
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[2])
				end
			end
		end
		TaskMO.taskLive = PbProtocol.decodeRecord(data["taskLive"])
		Notify.notify(LOCAL_TASK_FINISH_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("TaskLiveAward",{awardId = awardId}))
end

--新活跃度领奖
function TaskBO.asynNewTaskLiveAward(doneCallback,awardId)
	local function parseResult(name, data)
		TaskMO.taskActiveStatus_ = data.states
		Notify.notify(LOCAL_ACTIVITY_TASK_LIVE)
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)

			--TK统计 金币获得
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[2])
				end
			end
		end
		-- TaskMO.taskLive = PbProtocol.decodeRecord(data["taskLive"])
		-- Notify.notify(LOCAL_TASK_FINISH_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("NewTaskLiveAward",{awardId = awardId}))
end

function TaskBO.addSchedule(task,taskInfo,count)
	task.schedule = task.schedule + count
	if task.schedule >= taskInfo.schedule then
		task.schedule = taskInfo.schedule
		task.status = 1
	end
	Notify.notify(LOCAL_TASK_FINISH_EVENT)
	Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
end

function TaskBO.setSchedule(task,taskInfo,count)
	task.schedule = count
	if task.schedule >= taskInfo.schedule then
		task.schedule = taskInfo.schedule
		task.status = 1
	end
	Notify.notify(LOCAL_TASK_FINISH_EVENT)
	Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
end

function TaskBO.canAddSchedule(task,taskInfo,param)
	--根据条件判断是否增加进度
	if param.kind == TASK_SCHEDULE_KIND_TANK then
		--造坦克
		local tankId
		if taskInfo.param then
			tankId = json.decode(taskInfo.param)[1]
		end
		--配置为0或者没有填表示随意坦克
		if not tankId or tankId == 0 then
			TaskBO.addSchedule(task,taskInfo,param.count)
		elseif tankId == param.tankId then
			TaskBO.addSchedule(task,taskInfo,param.count)
		end
	elseif param.kind == TASK_SCHEDULE_KIND_COMBAT or param.kind == TASK_SCHEDULE_KIND_COMBAT_NO then
		--战胜关卡
		local combatId
		if taskInfo.param then
			combatId = json.decode(taskInfo.param)[1]
		end
		--配置为0或者没有填表示随意关卡
		if not combatId or combatId == 0 then
			TaskBO.addSchedule(task,taskInfo,1)
		elseif combatId == param.combatId then
			TaskBO.addSchedule(task,taskInfo,1)
		end
	elseif param.kind == TASK_SCHEDULE_KIND_ATTACK_MINE then
		--攻打资源点
		local level
		if taskInfo.param then
			level = json.decode(taskInfo.param)[1]
		end
		--配置为0或者没有填表示随意资源点
		if not level or level == 0 then
			TaskBO.addSchedule(task,taskInfo,1)
		end

	elseif param.kind == TASK_SCHEDULE_KIND_RES then
		--资源产量
		task.schedule = BuildBO.getResourceOutput()[param.type]
		if task.schedule >= taskInfo.schedule then
			task.schedule = taskInfo.schedule
			task.status = 1
			Notify.notify(LOCAL_TASK_FINISH_EVENT)
			Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
		end
	elseif param.kind == TASK_SCHEDULE_KIND_BUILD_UP then
		local buildId = param.type
		local buildLv
		--获得当前建筑的最大等级
		if buildId >= BUILD_ID_STONE and buildId <= BUILD_ID_OIL then --升级 野外资源点
			buildLv = BuildBO.getMaxLvWildBuild(buildId).level
		elseif buildId == BUILD_ID_COMMAND or buildId == BUILD_ID_REFIT or 
			buildId == BUILD_ID_SCIENCE or buildId == BUILD_ID_WORKSHOP then
			buildLv = BuildMO.getBuildLevel(buildId)
		elseif buildId == BUILD_ID_CHARIOT_A or buildId == BUILD_ID_CHARIOT_B then
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
			if buildLvA > buildLvB then
				buildLv = buildLvA
			else
				buildLv = buildLvB
			end
		elseif buildId == BUILD_ID_WAREHOUSE_A or buildId == BUILD_ID_WAREHOUSE_B then
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_B)
			if buildLvA > buildLvB then
				buildLv = buildLvA
			else
				buildLv = buildLvB
			end
		end
		TaskBO.setSchedule(task,taskInfo,buildLv)
	elseif param.kind == TASK_SCHEDULE_KIND_FAME then
		TaskBO.setSchedule(task,taskInfo,UserMO.fameLevel_)
	else
		TaskBO.addSchedule(task,taskInfo,1)
	end
end

function TaskBO.updateTaskSchedule(param)
	-- gdump(param,"TaskBO.updateTaskSchedule(param)")
	local cond = TaskMO.schedule_type[param.kind][param.type]
	if not cond then gprint("不存在任务完成类别") return end

	--主线任务
	for index=1,#TaskMO.majorTaskList_ do
		local task = TaskMO.majorTaskList_[index]
		local taskInfo = TaskMO.queryTask(task.taskId)
		if param.kind == TASK_SCHEDULE_KIND_BUILD_UP then
			if taskInfo.cond == cond or taskInfo.cond == 31 then
				TaskBO.canAddSchedule(task,taskInfo,param)
				Notify.notify(LOCAL_TASK_FINISH_EVENT)
				Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)				
			end
		else
			if taskInfo.cond == cond then
				TaskBO.canAddSchedule(task,taskInfo,param)
				Notify.notify(LOCAL_TASK_FINISH_EVENT)
				Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)				
			end
		end
	end

	--日常任务
	for index=1,#TaskMO.daylyTaskList_ do
		local task = TaskMO.daylyTaskList_[index]
		local taskInfo = TaskMO.queryTask(task.taskId)
		--只有已接受的任务
		if task.accept == 1 then
			if param.kind == TASK_SCHEDULE_KIND_BUILD_UP then
				if taskInfo.cond == cond or taskInfo.cond == 31 then
					TaskBO.canAddSchedule(task,taskInfo,param)
				end
			else
				if taskInfo.cond == cond then
					TaskBO.canAddSchedule(task,taskInfo,param)
				end
			end
		end
	end

	--活跃任务
	for index=1,#TaskMO.liveTaskList_ do
		local task = TaskMO.liveTaskList_[index]
		local taskInfo 
		if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then
			taskInfo = TaskMO.queryNewTask(task.taskId)
		else
			taskInfo = TaskMO.queryTask(task.taskId)
		end
		if param.kind == TASK_SCHEDULE_KIND_BUILD_UP then
			if taskInfo.cond == cond or taskInfo.cond == 31 then
				if task.schedule < taskInfo.schedule then
					TaskBO.canAddSchedule(task,taskInfo,param)
					if task.schedule == taskInfo.schedule then
						--增加活跃
						TaskMO.taskLive.live = TaskMO.taskLive.live + taskInfo.live
						Notify.notify(LOCAL_TASK_FINISH_EVENT)
						Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
					end
				end
			end
		else
			if taskInfo.cond == cond then
				if task.schedule < taskInfo.schedule then
					TaskBO.canAddSchedule(task,taskInfo,param)
					if task.schedule == taskInfo.schedule then
						--增加活跃
						TaskMO.taskLive.live = TaskMO.taskLive.live + taskInfo.live
						Notify.notify(LOCAL_TASK_FINISH_EVENT)
						Notify.notify(LOCAL_FIRST_TASK_UPDATE_EVENT)
					end
				end
			end
		end
	end
end


function TaskBO.getAllFinishTask(type)
	local count
	if type == TASK_TYPE_MAJOR then
		count = 0
		--主线任务
		for index=1,#TaskMO.majorTaskList_ do
			local task = TaskMO.majorTaskList_[index]
			if task.status == 1 then
				count = count + 1
			end
		end
	elseif type == TASK_TYPE_DAYLY then
		count = 0
		--日常任务
		for index=1,#TaskMO.daylyTaskList_ do
			local task = TaskMO.daylyTaskList_[index]
			if task.status == 1 then
				count = count + 1
			end
		end
	else
		if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then return 0 end
		count = 0
		--日常活跃
		if TaskMO.taskLive then
			local nextLive = TaskMO.queryNextTaskLive(TaskMO.taskLive.liveAward)
			if nextLive and TaskMO.taskLive.live >= nextLive.live then
				count = count + 1
			end
		end
	end
	return count
end

function TaskBO.getTaskByChildType(type)
	local list = {}
	for index=1,#TaskMO.majorTaskList_ do
		local task = TaskMO.majorTaskList_[index]
		local taskInfo = TaskMO.queryTask(task.taskId)
		if taskInfo.typeChild == type then
			list[#list + 1] = task
		end
	end
	return list
end

function TaskBO.getFirstMajorTask()
	if TaskMO.majorTaskList_ and #TaskMO.majorTaskList_ > 0 then
		TaskBO.sortFun(TaskMO.majorTaskList_,TASK_TYPE_MAJOR)
		return TaskMO.majorTaskList_[1]
	else
		return nil
	end
end



--能否接受日常任务
function TaskBO.canGetDaylyTask()
	local can = true
	for index=1,#TaskMO.daylyTaskList_ do
		local task = TaskMO.daylyTaskList_[index]
		if task.accept == 1 then
			can = false
			break
		end
	end
	return can
end

function TaskBO.goToTaskDo(taskInfo)
	if taskInfo.type == TASK_TYPE_LIVE then
		UiDirector.popMakeUiTop("HomeView")
	end
	
	--日常任务没有前往
	if taskInfo.type == TASK_TYPE_DAYLY then return end
	local cond = taskInfo.cond
	-- gdump(cond,"任务类别:")
	local kind,type = TaskBO.getKindTypeByCond(cond)
	if not kind then return end

	if kind == TASK_SCHEDULE_KIND_BUILD then
		if cond >= 24 and cond <= 28 then --建造 铁 油 铜 硅 宝石矿
			UiDirector.clear()
			Notify.notify(LOCAL_SHOW_WILD_EVENT)
		else
			local buildingId = type

			if buildingId == BUILD_ID_WAREHOUSE_A or buildingId == BUILD_ID_WAREHOUSE_B then 
				if BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_A) == 0 then
					buildingId = BUILD_ID_WAREHOUSE_A
					type = BUILD_ID_WAREHOUSE_A
				else
					buildingId = BUILD_ID_WAREHOUSE_B
					type = BUILD_ID_WAREHOUSE_B					
				end
			end

			if BuildMO.getBuildStatus(buildingId) == BUILD_STATUS_UPGRADE then  -- 如果正在建造中，则不可点击进入
				if BuildMO.getBuildLevel(buildingId) == 0 then
					return
				end
			end
			if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
				local build = BuildMO.queryBuildById(buildingId)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
				return
			end
			if buildingId == BUILD_ID_CHARIOT_B then 
				require("app.view.ChariotInfoView").new(buildingId):push()
			elseif buildingId == BUILD_ID_WAREHOUSE_A or buildingId == BUILD_ID_WAREHOUSE_B then
				-- require("app.view.WarehouseView").new(buildingId):push()
				local buildLvA = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_A)
				local buildLvB = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_B)
				local buildId
				if buildLvA > buildLvB then
					buildId = BUILD_ID_WAREHOUSE_B
				else
					buildId = BUILD_ID_WAREHOUSE_A
				end
				require("app.view.WarehouseView").new(buildId):push()

			elseif buildingId == BUILD_ID_SCIENCE then
				require("app.view.ScienceView").new(buildingId):push()
			elseif buildingId == BUILD_ID_WORKSHOP then
				require("app.view.WorkshopView").new(buildingId):push()
			elseif buildingId == BUILD_ID_REFIT then
				require("app.view.RefitView").new(buildingId):push()
			end
		end
	elseif kind == TASK_SCHEDULE_KIND_BUILD_UP then --建筑升级
		if type >= BUILD_ID_STONE and type <= BUILD_ID_OIL then --升级 野外资源点
			local param = BuildBO.getMaxLvWildBuild(type)
			if param then
				local BuildingInfoView = require("app.view.BuildingInfoView")
				BuildingInfoView.new(nil, param.buildingId, param.pos):push()
				Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = kind,type = type})
			else
				UiDirector.clear()
				Notify.notify(LOCAL_SHOW_WILD_EVENT)
				Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = TASK_SCHEDULE_KIND_BUILD,type = type})
			end
			return
		elseif type == BUILD_ID_COMMAND then
			require("app.view.CommandInfoView").new():push()
		elseif type == BUILD_ID_CHARIOT_A or type == BUILD_ID_CHARIOT_B then
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
			local buildId
			if buildLvA > buildLvB then
				buildId = BUILD_ID_CHARIOT_A
			else
				buildId = BUILD_ID_CHARIOT_B
			end
			require("app.view.ChariotInfoView").new(buildId):push()
		elseif type == BUILD_ID_REFIT then
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_REFIT) then
				local build = BuildMO.queryBuildById(BUILD_ID_REFIT)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_REFIT), build.name))
				return
			end
			require("app.view.RefitView").new(BUILD_ID_REFIT):push()
		elseif type == BUILD_ID_SCIENCE then
			require("app.view.ScienceView").new(BUILD_ID_SCIENCE):push()
		elseif type == BUILD_ID_WORKSHOP then
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_WORKSHOP) then
				local build = BuildMO.queryBuildById(BUILD_ID_WORKSHOP)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_WORKSHOP), build.name))
				return
			end
			require("app.view.WorkshopView").new(BUILD_ID_WORKSHOP):push()
		elseif type == BUILD_ID_WAREHOUSE_A or type == BUILD_ID_WAREHOUSE_B then
			local buildLvA = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_A)
			local buildLvB = BuildMO.getBuildLevel(BUILD_ID_WAREHOUSE_B)
			local buildId
			if buildLvA > buildLvB then
				buildId = BUILD_ID_WAREHOUSE_A
			else
				buildId = BUILD_ID_WAREHOUSE_B
			end
			require("app.view.WarehouseView").new(buildId):push()
		end
	elseif kind == TASK_SCHEDULE_KIND_TANK then --建造坦克
		local buildLvA = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
		local buildLvB = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
		local buildId
		if buildLvA > buildLvB then
			buildId = BUILD_ID_CHARIOT_A
		else
			buildId = BUILD_ID_CHARIOT_B
		end
		require("app.view.ChariotInfoView").new(buildId,CHARIOT_FOR_PRODUCT):push()
	elseif kind == TASK_SCHEDULE_KIND_COMBAT or kind == TASK_SCHEDULE_KIND_COMBAT_NO or kind == TASK_SCHEDULE_KIND_COMBAT_ACTIVE then
		local combatId = json.decode(taskInfo.param)[1]
		require("app.view.CombatSectionView").new():push()
		if not combatId or combatId == 0 then 
			return
		end
		local sectionId = CombatMO.queryCombatById(combatId).sectionId
		if not sectionId then
			return
		else
			local sectionDB = CombatMO.querySectionById(sectionId)
			local sectionOpen = CombatBO.isSectionCanFight(sectionId)  -- 章节是否开启
			if not sectionOpen then return end
			if sectionDB.rank > 0 and UserMO.rank_ < sectionDB.rank then -- 军衔要求
				return
			end
		end
		local CombatLevelView = require("app.view.CombatLevelView")
		CombatLevelView.new(COMBAT_TYPE_COMBAT, sectionId):push()
	elseif kind == TASK_SCHEDULE_KIND_FAME then
		require("app.view.PlayerView").new():push()
	elseif kind == TASK_SCHEDULE_KIND_RANK then
		require("app.view.PlayerView").new():push()
	elseif kind == TASK_SCHEDULE_KIND_ATTACK_MAN or kind == TASK_SCHEDULE_KIND_ATTACK_MINE 
		or kind == TASK_SCHEDULE_KIND_ATTACK_MINE_LEVEL then
		UiDirector.clear()
		Notify.notify(LOCAL_LOCATION_EVENT)
	elseif kind == TASK_SCHEDULE_KIND_RES then
		UiDirector.clear()
		Notify.notify(LOCAL_SHOW_WILD_EVENT)
	elseif kind == TASK_SCHEDULE_KIND_SCIENCE_UP then
		require("app.view.ScienceView").new(BUILD_ID_SCIENCE,SCIENCE_FOR_STUDY):push()
	elseif kind == TASK_SCHEDULE_KIND_JJC then
		--判断等级
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_ARENA) then
			local build = BuildMO.queryBuildById(BUILD_ID_ARENA)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_ARENA), build.name))
			return
		end
		require("app.view.ArenaView").new():push()
	elseif kind == TASK_SCHEDULE_KIND_EXPLORE then
		if type == EXPLORE_TYPE_LIMIT then
			require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_LIMIT):push()
		else
			require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
		end
	elseif kind == TASK_SCHEDULE_KIND_PARTY_COMBAT or kind == TASK_SCHEDULE_KIND_PARTY_SHOP 
		or kind == TASK_SCHEDULE_KIND_PARTY_DONOR or kind == TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD 
		or kind == TASK_SCHEDULE_KIND_STATION then
		--判断等级
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
			local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
			return
		end
		UiDirector.popMakeUiTop("HomeView")
		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			if kind == TASK_SCHEDULE_KIND_STATION then
				UiDirector.clear()
				Notify.notify(LOCAL_LOCATION_EVENT)	
			else
				Loading.getInstance():show()
				PartyBO.asynGetParty(function(data)
						Loading.getInstance():unshow()
						UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_PARTY)
						Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = kind,type = type})
					end, 0)
			end
		else
			--打开军团列表
			PartyBO.asynGetPartyRank(function()
				require("app.view.AllPartyView").new():push()
				end, 0, PartyMO.allPartyList_type_)
			
		end
		return
	elseif kind == TASK_SCHEDULE_KIND_HERO_IMPROVE then
		--判断等级
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
			local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
			return
		end
		require("app.view.HeroImproveView").new():push()
	elseif kind == TASK_SCHEDULE_KIND_HERO_LOTTERY then
		--判断等级
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
			local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
			return
		end
		require("app.view.LotteryHeroView").new():push()
	elseif kind == TASK_SCHEDULE_KIND_PART_UP then
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_COMPONENT) then
			local build = BuildMO.queryBuildById(BUILD_ID_COMPONENT)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_COMPONENT), build.name))
			return
		end
		require("app.view.ComponentView").new(BUILD_ID_COMPONENT, UI_ENTER_FADE_IN_GATE):push()
	elseif kind == TASK_SCHEDULE_KIND_BUILD_UP_ALL then
		local BuildingQueueView = require("app.view.BuildingQueueView")
		BuildingQueueView.new(BUILDING_FOR_ALL):push()
	elseif kind == TASK_SCHEDULE_KIND_COIN_COST then
		local BagView = require("app.view.BagView")
		BagView.new(BAG_VIEW_FOR_SHOP):push()
	elseif kind == TASK_SCHEDULE_KIND_EQUIP_UP then
		require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push()
	elseif kind == TASK_SCHEDULE_KIND_STAR_COLLECT then
		require("app.view.TaskView").new(2):push()
	-- elseif kind == TASK_SCHEDULE_KIND_REFINE_PART then
	-- 	if UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_COMPONENT) then
	-- 		require("app.view.ComponentView").new(nil, UI_ENTER_FADE_IN_GATE):push()
	-- 	else
	-- 		Toast.show(CommonText[245])
	-- 	end
	elseif kind == TASK_SCHEDULE_KIND_RECHARGE_ACTIVE then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
	elseif kind == TASK_SCHEDULE_KIND_LIMIT_ACTIVE then
		if type == TASK_LIMIT_YAOSAI or type == TASK_LIMIT_YANXI or type == TASK_LIMIT_BOSS then
			local index = nil
			if  #ActivityCenterMO.activityList_ > 0 then
				index = 2
			else
				index = 1
			end
			UiDirector.push(require("app.view.ActivityCenterView").new(index))
		else
			if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
				require("app.view.PartyBattleView").new():push()
			else
				if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
					local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
					Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
					return
				else
					Toast.show(CommonText[421][2])
				end
			end
		end
	end

	Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = kind,type = type})
end

function TaskBO.getKindTypeByCond(cond)
	for kind, type in pairs(TaskMO.schedule_type) do
		for type1, cond1 in pairs(type) do
			if cond1 == cond then
				return kind,type1
			end
		end
	end
end




-- --根据参数取得任务的完成类型
-- function TaskBO.getFinishType(param)
-- 	local cond
-- 	local kind = param.kind
-- 	local type = param.type

-- 	cond = TaskMO.schedule_type[kind][type]
-- 	-- for index = 1,#TaskMO.schedule_type[kind] do
-- 	-- 	if kind == TASK_SCHEDULE_KIND_BUILD then
-- 	-- 		return 
-- 	-- 	end
-- 	-- end


-- 	return cond
-- end