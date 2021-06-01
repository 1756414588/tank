--
-- Author: gf
-- Date: 2015-09-22 10:52:02
--
local s_task = require("app.data.s_task")
local s_task_new = require("app.data.s_task_activity")
local s_task_live = require("app.data.s_task_live")
local s_task_live_new = require("app.data.s_task_live_activity")
local s_daily = require("app.data.s_daily")
local db_task_
local db_task_live_
local db_task_cond_
local db_task_live_new_
local db_task_new_
local db_daily_

TaskMO = {}

TaskMO.updateResOutput_ = nil

TaskMO.majorTaskList_ = {}
TaskMO.daylyTaskList_ = {}
TaskMO.taskDayiy = {}
TaskMO.liveTaskList_ = {}
TaskMO.taskLive = {}
TaskMO.taskLiveInfo_ = nil
TaskMO.taskActiveInfo_ = nil
TaskMO.taskActiveEndTime_ = nil
TaskMO.taskActiveStatus_ = nil


--任务常量

--任务类型
TASK_TYPE_MAJOR = 1  --主线
TASK_TYPE_DAYLY = 2  --日常
TASK_TYPE_LIVE = 3   --活跃

--主线任务类型
TASK_MAJOR_TYPE_BASE = 1  --基地
TASK_MAJOR_TYPE_MAN  = 2  --角色
TASK_MAJOR_TYPE_RES  = 3  --资源

TASK_DAYLY_COUNT = 5 --日常任务每天可完成次数
TASK_DAYLY_QUICK_FINISH_COIN = 5 --日常任务快速完成需要花费的金币
TASK_DAYLY_REFRESH_COIN = 5 --日常任务刷新需要花费的金币
TASK_DAYLY_RESET_COIN = 25 --日常任务重置需要花费的金币

TASK_GET_AWARD_TYPE_NOMAL = 1
TASK_GET_AWARD_TYPE_GOLD = 2

TASK_SCHEDULE_KIND_BUILD = 1 --建造建筑
TASK_SCHEDULE_KIND_BUILD_UP = 2 --升级建筑(某个)
TASK_SCHEDULE_KIND_TANK = 3  --建造坦克
TASK_SCHEDULE_KIND_COMBAT = 4 --战胜关卡
TASK_SCHEDULE_KIND_FAME = 5 --声望等级提升
TASK_SCHEDULE_KIND_RANK = 6 --军衔提升
TASK_SCHEDULE_KIND_ATTACK_MAN = 7 --攻打玩家
TASK_SCHEDULE_KIND_ATTACK_MINE = 8 --攻打资源点
TASK_SCHEDULE_KIND_RES = 9 --资源产量
TASK_SCHEDULE_KIND_BUILD_UP_ALL = 10 --升级建筑(都包括)
TASK_SCHEDULE_KIND_EQUIP_UP = 11 --升级装备
TASK_SCHEDULE_KIND_COIN_COST = 12 --金币消费
TASK_SCHEDULE_KIND_SCIENCE_UP = 13 --研发科技
TASK_SCHEDULE_KIND_JJC = 14 --挑战JJC
TASK_SCHEDULE_KIND_EXPLORE = 15 --完成探险副本
TASK_SCHEDULE_KIND_PARTY_COMBAT = 16 --完成军团试练
TASK_SCHEDULE_KIND_PARTY_SHOP = 17 --兑换军团道具
TASK_SCHEDULE_KIND_PARTY_DONOR = 18 --军团贡献
TASK_SCHEDULE_KIND_HERO_IMPROVE = 19 --进阶将领
TASK_SCHEDULE_KIND_HERO_LOTTERY = 20 --招募将领
TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD = 21 --领取军团试炼箱
TASK_SCHEDULE_KIND_STATION = 22 --驻军
-- TASK_SCHEDULE_KIND_EQUIP_UP = 23 --升级装备
TASK_SCHEDULE_KIND_PART_UP = 24 --强化配件
TASK_SCHEDULE_KIND_ATTACK_MINE_LEVEL = 25 --战胜目标等级的资源点
TASK_SCHEDULE_KIND_COMBAT_NO = 26 --关卡征战
TASK_SCHEDULE_KIND_STAR_COLLECT = 27 --任务集星
-- TASK_SCHEDULE_KIND_REFINE_PART = 28 --强化配件
TASK_SCHEDULE_KIND_LIMIT_ACTIVE = 29 --限时活动
TASK_SCHEDULE_KIND_RECHARGE_ACTIVE = 30 --充值活跃
TASK_SCHEDULE_KIND_COMBAT_ACTIVE = 31  --关卡活跃

--------------------------------------------------------------
--任务跳转自定义
TASK_LIMIT_YAOSAI = 1 --要塞
TASK_LIMIT_LEGION = 2 --军团
TASK_LIMIT_YANXI = 3  --演习
TASK_LIMIT_BOSS = 4   --BOSS

TaskMO.schedule_type = {
	[TASK_SCHEDULE_KIND_BUILD] = {
			[BUILD_ID_IRON] = 24,
			[BUILD_ID_OIL] = 25,
			[BUILD_ID_COPPER] = 26,
			[BUILD_ID_SILICON] = 27,
			[BUILD_ID_STONE] = 28,
			[BUILD_ID_CHARIOT_B] = 29,
			[BUILD_ID_WAREHOUSE_A] = 30,
			[BUILD_ID_WAREHOUSE_B] = 30,
			[BUILD_ID_REFIT] = 50,
			[BUILD_ID_SCIENCE] = 51,
			[BUILD_ID_WORKSHOP] = 52
		},
	[TASK_SCHEDULE_KIND_BUILD_UP] = {
			[BUILD_ID_IRON] = 1,
			[BUILD_ID_OIL] = 2,
			[BUILD_ID_COPPER] = 3,
			[BUILD_ID_SILICON] = 4,
			[BUILD_ID_STONE] = 5,
			[BUILD_ID_COMMAND] = 6,
			[BUILD_ID_CHARIOT_A] = 7,
			[BUILD_ID_CHARIOT_B] = 7,
			[BUILD_ID_REFIT] = 8,
			[BUILD_ID_SCIENCE] = 9,
			[BUILD_ID_WAREHOUSE_A] = 10,
			[BUILD_ID_WAREHOUSE_B] = 10,
			[BUILD_ID_WORKSHOP] = 11
		},
	[TASK_SCHEDULE_KIND_TANK] = {12},
	[TASK_SCHEDULE_KIND_COMBAT] = {16},
	[TASK_SCHEDULE_KIND_COMBAT_NO] = {14},
	[TASK_SCHEDULE_KIND_FAME] = {17},
	[TASK_SCHEDULE_KIND_RANK] = {18},
	[TASK_SCHEDULE_KIND_ATTACK_MAN] = {19,64},
	[TASK_SCHEDULE_KIND_ATTACK_MINE] = {20},
	[TASK_SCHEDULE_KIND_ATTACK_MINE_LEVEL] = {13},
	[TASK_SCHEDULE_KIND_RES] = {
			[RESOURCE_ID_IRON] = 21,
			[RESOURCE_ID_OIL] = 22,
			[RESOURCE_ID_COPPER] = 23
		},
	[TASK_SCHEDULE_KIND_BUILD_UP_ALL] = {31},
	[TASK_SCHEDULE_KIND_EQUIP_UP] = {32},
	[TASK_SCHEDULE_KIND_COIN_COST] = {33,54},
	[TASK_SCHEDULE_KIND_SCIENCE_UP] = {34},
	[TASK_SCHEDULE_KIND_JJC] = {35},
	[TASK_SCHEDULE_KIND_EXPLORE] = {
			[EXPLORE_TYPE_EQUIP] = 39,
			[EXPLORE_TYPE_PART] = 37,
			[EXPLORE_TYPE_EXTREME] = 38,
			[EXPLORE_TYPE_LIMIT] = 41
		},
	[TASK_SCHEDULE_KIND_PARTY_COMBAT] = {40},
	[TASK_SCHEDULE_KIND_PARTY_SHOP] = {42},
	[TASK_SCHEDULE_KIND_PARTY_DONOR] = {43},
	[TASK_SCHEDULE_KIND_HERO_IMPROVE] = {44},
	[TASK_SCHEDULE_KIND_HERO_LOTTERY] = {45,53},
	[TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD] = {46},
	[TASK_SCHEDULE_KIND_STATION] = {47},
	[TASK_SCHEDULE_KIND_PART_UP] = {49,57},
	[TASK_SCHEDULE_KIND_STAR_COLLECT] = {55},
	-- [TASK_SCHEDULE_KIND_REFINE_PART] = {57},
	[TASK_SCHEDULE_KIND_LIMIT_ACTIVE] = {
			[TASK_LIMIT_YAOSAI] = 56,
			[TASK_LIMIT_LEGION] = 59,
			[TASK_LIMIT_YANXI] = 61,
			[TASK_LIMIT_BOSS] = 62
	},
	[TASK_SCHEDULE_KIND_RECHARGE_ACTIVE] = {58},
	[TASK_SCHEDULE_KIND_COMBAT_ACTIVE] = {63},
}


function TaskMO.init()
	TaskMO.taskLiveInfo_ = nil
	TaskMO.majorTaskList_ = {}
	TaskMO.daylyTaskList_ = {}
	TaskMO.taskDayiy = {}
	TaskMO.liveTaskList_ = {}
	TaskMO.taskLive = {}

	db_task_ = nil
	db_task_live_ = nil
	db_task_cond_ = nil
	db_task_live_new_ = nil
	db_task_new_ = nil
	db_daily_ = nil

	if not db_task_ then
		db_task_ = {}
		db_task_cond_ = {}
		local records = DataBase.query(s_task)
		for index = 1, #records do
			local task = records[index]
			local cond = task.cond
			if not db_task_cond_[cond] then
				db_task_cond_[cond] = {}
			end
			db_task_cond_[cond][task.taskId] = task
			db_task_[task.taskId] = task
		end
	end
	if not db_daily_ then
		db_daily_ = {}
		local records = DataBase.query(s_daily)
		for index = 1, #records do
			local task = records[index]
			db_daily_[task.id] = task
		end
	end
	if not db_task_live_ then
		db_task_live_ = {}
		local records = DataBase.query(s_task_live)
		for index = 1, #records do
			local taskLive = records[index]
			db_task_live_[taskLive.id] = taskLive
		end
	end

	if not db_task_new_ then
		db_task_new_ = {}
		local records = DataBase.query(s_task_new)
		for index = 1, #records do
			local task = records[index]
			db_task_new_[task.taskId] = task
		end
	end

	if not db_task_live_new_ then
		db_task_live_new_ = {}
		local records = DataBase.query(s_task_live_new)
		for index = 1, #records do
			local taskLive = records[index]
			db_task_live_new_[taskLive.id] = taskLive
		end
	end
end

function TaskMO.queryTask(taskId)
	if not db_task_[taskId] then return nil end
	return db_task_[taskId]
end

function TaskMO.getTaskLiveList()
	return db_task_live_
end

--新活跃度任务信息
function TaskMO.queryNewTask(taskId)
	if not db_task_new_[taskId] then return nil end
	return db_task_new_[taskId]
end

--新活跃度奖励
function TaskMO.getNewTaskLiveList()
	return db_task_live_new_
end

function TaskMO.queryTaskLive(id)
	if not db_task_live_[id] then return nil end
	return db_task_live_[id]
end

function TaskMO.queryNextTaskLive(live)
	if live == 0 then return db_task_live_[1] end
	for index=1,#db_task_live_ do
		if db_task_live_[index].live == live  then
			if db_task_live_[index + 1] then
				return db_task_live_[index + 1]
			end			
		end
	end
	return nil
end

function TaskMO.queryTaskByCond(cond)
	if not db_task_cond_[cond] then return nil end
	return db_task_cond_[cond]
end

--获取活跃任务信息
function TaskMO.getLiveTaskInfo()
	if not TaskMO.taskLiveInfo_ then
		TaskMO.taskLiveInfo_ = {}
		for k,v in ipairs(TaskMO.liveTaskList_) do
			local data = TaskMO.queryNewTask(TaskMO.liveTaskList_[k].taskId)
			local point = json.decode(data.param)
			data.kind = point[1]
			data.id = point[2]
			if not TaskMO.taskLiveInfo_[data.kind] then
				TaskMO.taskLiveInfo_[data.kind] = {}
			end
			if not TaskMO.taskLiveInfo_[data.kind][data.id] then
				TaskMO.taskLiveInfo_[data.kind][data.id] = {}
			end
			TaskMO.taskLiveInfo_[data.kind][data.id][#TaskMO.taskLiveInfo_[data.kind][data.id] + 1] = data
		end
	end
	return TaskMO.taskLiveInfo_
end

--通过活跃任务的ID进行分类
function TaskMO.getTypeByID(id)
	if not TaskMO.taskLiveInfo_ then return end
	local kindInfo = TaskMO.taskLiveInfo_[id]
	return kindInfo
end

--根据任务ID获取对应的活跃度
function TaskMO.getActiveById(taskId)
	if not TaskMO.liveTaskList_ then return end
	if not TaskMO.taskActiveInfo_ then
		TaskMO.taskActiveInfo_ = {}
	end
	for k,v in ipairs(TaskMO.liveTaskList_) do
		TaskMO.taskActiveInfo_[v.taskId] = v.schedule
	end
	return TaskMO.taskActiveInfo_[taskId]
end

function TaskMO.getActivityCanrecive()
	local num = 0
	for index=1,#TaskMO.taskActiveStatus_ do
		local data = TaskMO.taskActiveStatus_[index]
		if data == 1 then
			num = num + 1
		end
	end
	return num
end

function TaskMO.getDailyTaskExpByUserLevel(userLevel, taskLevel)
	-- body
	if userLevel < 30 then
		return 0
	end

	for k, v in pairs(db_daily_) do
		if userLevel >= v.beginLv and userLevel <= v.endLv then
			local a = v.a
			local b = v.b
			local c = v.c

			local exp = (userLevel * userLevel * a + b - 50000) / math.pow((c / 100), 5 - taskLevel)
			return math.floor(exp)
		end
	end
	return 0
end