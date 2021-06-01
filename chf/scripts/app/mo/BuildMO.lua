
local s_building = require("app.data.s_building")
local s_building_lv = require("app.data.s_building_lv")
local s_buildsell = require("app.data.s_act_buildingsell")

BuildMO = {}

BUILD_ID_COMMAND           = 1   -- 司令部
BUILD_ID_WAREHOUSE_A       = 2   -- 仓库(一)
BUILD_ID_REFIT             = 3   -- 改装工厂
BUILD_ID_WORKSHOP          = 4   -- 制造车间
BUILD_ID_SCIENCE           = 5   -- 科技馆
BUILD_ID_CHARIOT_A         = 6   -- 战车工厂(一)
BUILD_ID_CHARIOT_B         = 7   -- 战车工厂(二)
BUILD_ID_STONE             = 8   -- 宝石工厂(水晶)
BUILD_ID_SILICON           = 9   -- 硅矿厂(钛)
BUILD_ID_IRON              = 10  -- 铁矿厂
BUILD_ID_COPPER            = 11  -- 铜矿厂
BUILD_ID_OIL               = 12  -- 石油厂
BUILD_ID_WAREHOUSE_B       = 13  -- 仓库(二)
BUILD_ID_SCHOOL            = 14  -- 军事学堂
BUILD_ID_PARTY             = 15  -- 军团
BUILD_ID_ARENA             = 16  -- 竞技场
BUILD_ID_COMPONENT         = 17  -- 配件工厂
BUILD_ID_EQUIP             = 18  -- 装备工厂
BUILD_ID_AFFAIRE           = 19  -- 外交部
BUILD_ID_NOTICE            = 20  -- 公告站
BUILD_ID_HARBOUR           = 21  -- 港口(在线奖励)
BUILD_ID_MILITARY          = 22  -- 军工科技
BUILD_ID_MATERIAL_WORKSHOP = 23  -- 材料工坊 
BUILD_ID_ARMAMENT          = 24  -- 军备工厂
BUILD_ID_LABORATORY		   = 25  -- 作战实验室
BUILD_ID_ADVANCEDTANK	   = 26  -- 高级金币车
BUILD_ID_TACTICCENTER	   = 27  -- 战术中心
BUILD_ID_ENERGYCORE 	   = 28  -- 能源核心

BUILD_ID_MAX = BUILD_ID_ENERGYCORE

BUILD_STATUS_FREE     = 0  -- 建筑空闲中
BUILD_STATUS_UPGRADE  = 1  -- 建筑建造或升级中
BUILD_STATUS_PRODUCE  = 2  -- 建筑生产中
BUILD_STATUS_REMOVE   = 3  -- 建筑拆除中

BUILD_ACCEL_TIME = 60 -- 每间隔多少秒加速需要消耗1个金币

BUILD_LEVEL_PRODUCT_SPEED = 5 -- 建筑每级增加生产速度(百分比)

BUILD_TYPE_MAIN = 1 -- 城内建筑
BUILD_TYPE_WILD = 2 -- 城外建筑

BUILD_AUTO_UPGRADE_TAKE = 238 -- 建筑自动升级购买需要金币

local db_build_ = nil
local db_build_level_ = nil
local db_build_sell_= nil

BuildMO.buildData_ = {}

-- 当前建筑的等级
BuildMO.buildLevel_ = {}

-- 城外的建筑的位置信息
BuildMO.millPos_ = {}

BuildMO.lastRequestTime_ = 0  -- 上次请求协议的时间

BuildMO.autoCdTime_ = 0 -- 自动升级建筑剩余时间
BuildMO.autoOpen_ = false  -- 自动升级建筑是否开启

BuildMO.autoQueueStretch_ = true -- 建筑建造UI的自动升级是否是展开的

BuildMO.tickHandler_ = nil

BuildMO.synBuildHandler_ = nil

BuildBuyTakeCoin = {68, 108, 198, 368, 688} -- 购买建造位花费的金币数量

function BuildMO.init()
	db_build_ = {}
	local records = DataBase.query(s_building)
	for index = 1, #records do
		local build = records[index]
		db_build_[build.buildingId] = build
	end

	db_build_level_ = {}
	local records = DataBase.query(s_building_lv)
	for index = 1, #records do
		local buildLevel = records[index]

		if not db_build_level_[buildLevel.buildingId] then db_build_level_[buildLevel.buildingId] = {} end

		if buildLevel.level == 0 then
			-- 等级0忽略
		else
			db_build_level_[buildLevel.buildingId][buildLevel.level] = buildLevel
		end
	end

	-- 初始所有建造的数据结构
	for index = 1, BUILD_ID_MAX do
		local data = {}
		data.upgradeId = 0  -- 升级的SchedulerSet的id

		BuildMO.buildData_[index] = data

		if index == BUILD_ID_CHARIOT_A or index == BUILD_ID_CHARIOT_B then
			BuildMO.buildData_[index].productQueue = {}  -- 战车工厂的生产队列
		elseif index == BUILD_ID_REFIT then
			BuildMO.buildData_[index].productQueue = {}  -- 改装工厂的改装队列
		elseif index == BUILD_ID_WORKSHOP then
			BuildMO.buildData_[index].productQueue = {}  -- 制作车间的生产队列
		elseif index == BUILD_ID_SCIENCE then
			BuildMO.buildData_[index].productQueue = {}  -- 科技馆的生产队列
		end
	end

	if not db_build_sell_ then
		db_build_sell_ = {}
		local records = DataBase.query(s_buildsell)
		for index = 1, #records do
			local data = records[index]
			db_build_sell_[data.id] = data
		end
	end
end

function BuildMO.queryBuildById(buildingId)
	return db_build_[buildingId]
end

function BuildMO.queryBuildLevel(buildingId, buildLevel, wild)
	if not db_build_level_[buildingId] then return nil end
	local temp = clone(db_build_level_[buildingId][buildLevel])
	if not temp then return nil end
	local valid = EffectMO.buildCost()
	if valid > 0 and not wild then
		temp.ironCost = math.floor(temp.ironCost/(1+valid/100))
		temp.oilCost = math.floor(temp.oilCost/(1+valid/100))
		temp.copperCost = math.floor(temp.copperCost/(1+valid/100))
		temp.siliconCost = math.floor(temp.siliconCost/(1+valid/100))
	end
	return temp
end

function BuildMO.queryBuildMaxLevel(buildingId)
	if not db_build_level_[buildingId] then return 0 end
	return #db_build_level_[buildingId]
end

function BuildMO.getBuildLevel(buildingId)
	return BuildMO.buildLevel_[buildingId]
end

-- 获得城外某个位置上的建筑等级
function BuildMO.getWildLevel(pos)
	if not BuildMO.millPos_[pos] then return 0 end
	return BuildMO.millPos_[pos].level
end

-- buildType是城内建筑时，buildParam表示建筑id
-- buildType是城外建筑时，buildParam表示建筑pos
function BuildMO.setBuildLevel(buildType, buildParam, buildLv)
	if buildType == BUILD_TYPE_MAIN then -- 城内建筑
		if BuildMO.buildLevel_ then BuildMO.buildLevel_[buildParam] = buildLv end
	elseif buildType == BUILD_TYPE_WILD then -- 城外建筑
		if BuildMO.millPos_ then BuildMO.millPos_[buildParam].level = buildLv end
	end
end

-- 获得建筑buildingId的状态
function BuildMO.getBuildStatus(buildingId)
	local buildData = BuildMO.buildData_[buildingId]
	if buildData.upgradeId > 0 then
		return BUILD_STATUS_UPGRADE
	else
		return BUILD_STATUS_FREE
	end
end

function BuildMO.getWildBuildStatus(pos)
	if BuildMO.millPos_[pos] then
		if BuildMO.millPos_[pos].upgradeId > 0 then
			return BUILD_STATUS_UPGRADE
		else
			return BUILD_STATUS_FREE
		end
	end
end

-- 获得建筑buildingId的建造、升级的剩余时间
function BuildMO.getUpgradeLeftTime(buildingId)
	local buildData = BuildMO.buildData_[buildingId]
	if buildData.upgradeId > 0 then
		return SchedulerSet.getTimeById(buildData.upgradeId)
	else
		return 0
	end
end

function BuildMO.getWildUpgradeLeftTime(pos)
	if not BuildMO.millPos_[pos] then return 0 end
	if BuildMO.millPos_[pos].upgradeId > 0 then
		return SchedulerSet.getTimeById(BuildMO.millPos_[pos].upgradeId)
	else
		return 0
	end
end

-- 获得建筑升级的总时间
function BuildMO.getUpgradeTotalTime(buildingId)
	local buildData = BuildMO.buildData_[buildingId]
	if buildData.upgradeId > 0 then
		local set = SchedulerSet.getSetById(buildData.upgradeId)
		if set then
			return set.period
		else
			return 0
		end
	else
		return 0
	end
end

function BuildMO.getWildUpgradeTotalTime(pos)
	if not BuildMO.millPos_[pos] then return 0 end
	if BuildMO.millPos_[pos].upgradeId > 0 then
		local set = SchedulerSet.getSetById(BuildMO.millPos_[pos].upgradeId)
		if set then
			return set.period
		else
			return 0
		end
	else
		return 0
	end
end

function BuildMO.hasMillAtPos(pos)
	-- print("pos:", pos)
	-- dump(BuildMO.millPos_, "xxxxxxxxx")
	if BuildMO.millPos_[pos] and BuildMO.millPos_[pos].buildingId > 0 then return true
	else return false end
end

function BuildMO.getMillAtPos(pos)
	return BuildMO.millPos_[pos]
end

function BuildMO.getOpenLevel(buildingId)
	if buildingId == BUILD_ID_ARENA then return 15
	elseif buildingId == BUILD_ID_PARTY then return 10
	elseif buildingId == BUILD_ID_SCHOOL then return 24
	elseif buildingId == BUILD_ID_WAREHOUSE_A then return 6
	elseif buildingId == BUILD_ID_WAREHOUSE_B then return 13
	elseif buildingId == BUILD_ID_COMPONENT then return 18
	elseif buildingId == BUILD_ID_MILITARY then return 30
	elseif buildingId == BUILD_ID_MATERIAL_WORKSHOP then return 20
	elseif buildingId == BUILD_ID_LABORATORY then return 65
	elseif buildingId == BUILD_ID_ARMAMENT then return WeaponryMO.level_
	elseif buildingId == BUILD_ID_TACTICCENTER then return 45
	elseif buildingId == BUILD_ID_ENERGYCORE then return UserMO.querySystemId(80) --能源核心
	else return 0 end
end

--获得建筑加速活动配置信息
function BuildMO.getBuildSellInfo(awardId)
	local data = db_build_sell_
	for index=1,#data do
		if data[index].awardId == awardId then
			return data[index]
		end
	end
end