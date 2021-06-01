--
-- Author: gf
-- Date: 2015-09-11 11:17:58
--

local s_party = require("app.data.s_party")
local s_party_build_level = require("app.data.s_party_build_level")
local s_party_contribute = require("app.data.s_party_contribute")
local s_party_prop = require("app.data.s_party_prop")
local s_party_science = require("app.data.s_party_science")
local s_party_weal = require("app.data.s_party_weal")
local s_party_lively = require("app.data.s_party_lively")
local s_live_task = require("app.data.s_live_task")
local s_party_trend = require("app.data.s_party_trend")
local s_altar_boss = require("app.data.s_altar_boss")
--军团BOSS星级
local s_altar_boss_award = require("app.data.s_altar_boss_award")
local s_altar_boss_contribute = require("app.data.s_altar_boss_contribute")
local s_altar_boss_star = require("app.data.s_altar_boss_star")

PartyMO = {}



--职位相关
--自定义职位开启等级
PARTY_CUSTOM_JOB_LV = {1,3,6,9}

--军团职位
PARTY_JOB_MEMBER = 10 --帮众
PARTY_JOB_CUSTOM_1 = 20
PARTY_JOB_CUSTOM_2 = 25
PARTY_JOB_CUSTOM_3 = 30
PARTY_JOB_CUSTOM_4 = 35
PARTY_JOB_OFFICAIL = 90 --副团长
PARTY_JOB_MASTER = 99 --团长

--领取日常活跃需求
PartyMO.getDayWealNeed = 5

--军团福利类别
PARTY_WEAL_GET_TYPE_DAY = 1    --日常福利
PARTY_WEAL_GET_TYPE_LIVE = 2   --活跃福利

--军团情报类型
PARTY_TREND_TYPE_1 = 1 --军情
PARTY_TREND_TYPE_2 = 2 --民情

--创建军团需要资源
CREAT_PARTY_NEED_COIN = 50
CREAT_PARTY_NEED_STONE = 300000
CREAT_PARTY_NEED_IRON = 300000
CREAT_PARTY_NEED_OIL = 300000
CREAT_PARTY_NEED_COPPER = 300000
CREAT_PARTY_NEED_SILICON = 300000

--创建军团需求等级
CREAT_PARTY_LV = 12

PARTY_BUILD_ID_HALL         	 = 1   -- 军团大厅
PARTY_BUILD_ID_SCIENCE      	 = 2   -- 科技大厅
PARTY_BUILD_ID_WEAL         	 = 3   -- 福利院
PARTY_BUILD_ID_INTELLIGENCE 	 = 4   -- 情报站
PARTY_BUILD_ID_SHOP         	 = 5   -- 军团商店
PARTY_BUILD_ID_TAOC         	 = 6   -- 作战中心
PARTY_BUILD_ID_ALTAR         	 = 7   -- 军团祭坛

-- 贡献类别 1铁 2石油 3铜 4硅石 5宝石 6金币
PARTY_CONTRIBUTE_TYPE_IRON = 1
PARTY_CONTRIBUTE_TYPE_OIL = 2
PARTY_CONTRIBUTE_TYPE_COPPER = 3
PARTY_CONTRIBUTE_TYPE_SILICON = 4
PARTY_CONTRIBUTE_TYPE_STONE = 5
PARTY_CONTRIBUTE_TYPE_COIN = 6

--商店物品类别
PARTY_SHOP_TYPE_NORMAL = 1 --普通
PARTY_SHOP_TYPE_TREASURE = 2 --珍品

--军团加入方式
PARTY_JOIN_TYPE_1 = 1 --申请即可加入
PARTY_JOIN_TYPE_2 = 2 --需要审批

--军团申请人数上限
PARTY_MEMBER_MAX_COUNT = 20



----祭坛Boss状态
PARTY_ALTAR_BOSS_STATE_CLOSE = 0
PARTY_ALTAR_BOSS_STATE_READY = 1
PARTY_ALTAR_BOSS_STATE_FIGHTING = 2
PARTY_ALTAR_BOSS_STATE_DIE = 3
PARTY_ALTAR_BOSS_STATE_OVER = 4
----------------------------------------------------
-----祭坛BOSS
PartyMO.altarBoss_ = {}
PartyMO.altarBossDirty_ = true
---------------------------------------------------

--我的军团信息
PartyMO.partyData_ = {}

--我的军团职位
PartyMO.myJob = 10

--军团职位人数
PartyMO.partyJobCount = {}

--所有军团列表
PartyMO.allPartyList_ = {}

--军团建筑基本信息
PartyMO.buildData_ = {}

--大厅信息
PartyMO.hallData_ = {}

--商店数据
PartyMO.shopData_nomal_ = {}      	--普通
PartyMO.shopData_treasure_ = {}		--珍品

--科技大厅信息
PartyMO.scienceData_ = {}

--福利院信息
PartyMO.wealData_ = {}

--日常福利一览数据
PartyMO.dayWealList = {}

--我对军团的贡献值
PartyMO.myDonate_ = 0

PartyMO.enterTime_ = 0  ---入团时间

PartyMO.allPartyList_type_ = 1  --1 全部 2可加入

--个人申请帮派列表
PartyMO.applyList = {}

--军团申请玩家列表
PartyMO.partyApplyList = {}
PartyMO.partyApplyList_num = 0

PartyMO.liveTaskList = {}


--军团情报列表
PartyMO.trends_1 = {}	--军情
PartyMO.trends_2 = {}	--民情

--军团排名
PartyMO.partyRankList_ = {}
PartyMO.myPartyRank = nil

PartyMO.dirtyPartyScienceData_ = false

local db_party_ --军团信息
local db_party_build_level_ --军团建筑
local db_party_contribute_ --军团贡献
local db_party_prop_ --军团道具(商店购买)
local db_party_science_ --军团科技
local db_party_weal_ --军团福利
local db_party_lively_ --军团活跃
local db_party_lively_task_  --军团活跃任务
local db_party_trend_		--军团情报
local db_party_altar_		--军团祭坛

local db_party_altar_boss_award         --奖励
local db_party_altar_boss_contribute    --捐献
local db_party_altar_boss_star          --星级

local db_party_altar_maxLevel_ = 1  ---军团BOSS最大等级

CREAT_PARTY_NAME_LEN = {}

function PartyMO.init()
	PartyMO.clearMyParty()

	db_party_  = nil --军团信息
	db_party_build_level_  = nil  --军团建筑
	db_party_contribute_   = nil --军团贡献
	db_party_prop_   = nil --军团道具(商店购买)
	db_party_science_   = nil --军团科技
	db_party_weal_  = nil  --军团福利
	db_party_lively_  = nil  --军团活跃
	db_party_lively_task_  = nil   --军团活跃任务
	db_party_trend_	  = nil 	--军团情报
	db_party_altar_ = nil 			----军团祭坛
	db_party_altar_boss_award = nil
	db_party_altar_boss_contribute = nil
	db_party_altar_boss_star = nil
	PartyMO.applyList = {}
	PartyMO.partyApplyList = {}
	PartyMO.partyApplyList_num = 0

	if not db_party_ then
		db_party_ = {}

		local records = DataBase.query(s_party)
		for index = 1, #records do
			local party = records[index]
			db_party_[party.partyLv] = party
		end
	end

	if not db_party_build_level_ then
		db_party_build_level_ = {}
		local records = DataBase.query(s_party_build_level)
		for index = 1, #records do
			local buildLevel = records[index]
			if not db_party_build_level_[buildLevel.type] then db_party_build_level_[buildLevel.type] = {} end
			db_party_build_level_[buildLevel.type][buildLevel.buildLv] = buildLevel
		end
	end
	-- gdump(db_party_build_level_,"PartyMO.init()..db_party_build_level_")

	if not db_party_contribute_ then
		db_party_contribute_ = {}
		local records = DataBase.query(s_party_contribute)
		for index = 1, #records do
			local record = records[index]
			if not db_party_contribute_[record.type] then db_party_contribute_[record.type] = {} end
			db_party_contribute_[record.type][record.count] = record
		end
	end

	if not db_party_prop_ then
		db_party_prop_ = {}
		local records = DataBase.query(s_party_prop)
		for index = 1, #records do
			local prop = records[index]
			db_party_prop_[prop.keyId] = prop
		end
	end

	if not db_party_science_ then
		db_party_science_ = {}
		local records = DataBase.query(s_party_science)
		for index = 1, #records do
			local scienceLevel = records[index]

			if not db_party_science_[scienceLevel.scienceId] then db_party_science_[scienceLevel.scienceId] = {} end

			--因为有等级为0的情况，所以需要+1
			db_party_science_[scienceLevel.scienceId][scienceLevel.scienceLv + 1] = scienceLevel
		end
	end

	if not db_party_altar_ then
		db_party_altar_ = {}
		db_party_altar_maxLevel_ = 1
		local records = DataBase.query(s_altar_boss)
		for i=1,#records do
			local altarLevel = records[i]
			db_party_altar_[altarLevel.lv] = altarLevel		
			if db_party_altar_maxLevel_ < altarLevel.lv then
				db_party_altar_maxLevel_ = altarLevel.lv
			end
		end	
	end	

	if not db_party_weal_ then
		db_party_weal_ = {}

		local records = DataBase.query(s_party_weal)
		for index = 1, #records do
			local weal = records[index]
			db_party_weal_[weal.wealLv] = weal
		end
	end

	if not db_party_lively_ then
		db_party_lively_ = {}

		local records = DataBase.query(s_party_lively)
		for index = 1, #records do
			local lively = records[index]
			db_party_lively_[lively.livelyLv] = lively
		end
	end

	if not db_party_lively_task_ then
		db_party_lively_task_ = {}
		local records = DataBase.query(s_live_task)
		for index = 1, #records do
			local lively_task = records[index]
			db_party_lively_task_[lively_task.taskId] = lively_task
			lively_task.schedue = 0
			table.insert(PartyMO.liveTaskList,lively_task)
		end
	end

	gdump(PartyMO.liveTaskList,"PartyMO.liveTaskListPartyMO.liveTaskList")
	PartyMO.queryPartyWealShow()

	if not db_party_trend_ then
		db_party_trend_ = {}

		local records = DataBase.query(s_party_trend)
		for index = 1, #records do
			local party_trend = records[index]
			db_party_trend_[party_trend.trendId] = party_trend
		end
	end

	--BOSS星级奖励
	if not db_party_altar_boss_award then
		db_party_altar_boss_award = {}
		local records = DataBase.query(s_altar_boss_award)
		for index = 1, #records do
			local record = records[index]
			if not db_party_altar_boss_award[record.lv] then db_party_altar_boss_award[record.lv] = {} end
			db_party_altar_boss_award[record.lv][record.star] = record
		end
	end

	--BOSS星级捐献
	if not db_party_altar_boss_contribute then
		db_party_altar_boss_contribute = {}
		local records = DataBase.query(s_altar_boss_contribute)
		for index = 1, #records do
			local record = records[index]
			if not db_party_altar_boss_contribute[record.type] then db_party_altar_boss_contribute[record.type] = {} end
			db_party_altar_boss_contribute[record.type][record.count] = record
		end
	end

	--BOSS星级
	if not db_party_altar_boss_star then
		db_party_altar_boss_star = {}
		local records = DataBase.query(s_altar_boss_star)
		for index = 1, #records do
			local party = records[index]
			db_party_altar_boss_star[party.id] = party
		end
	end

	-- gdump(db_party_contribute_,"PartyMO.init()..db_party_contribute_")
end



function PartyMO.queryParty(partyLv)
	if not db_party_[partyLv] then return nil end
	return db_party_[partyLv]
end

function PartyMO.queryPartyBuildLv(type,lv)
	if not db_party_build_level_[type] then return nil end
	return db_party_build_level_[type][lv + 1]
end

function PartyMO.queryPartyBuildMaxLevel(type)
	if not db_party_build_level_[type] then return 0 end
	return #db_party_build_level_[type]
end

function PartyMO.queryPartyContribute(type,count)
	if not db_party_contribute_[type] then return nil end
	return db_party_contribute_[type][count + 1]
end

function PartyMO.queryPartyContributeMaxCount(type)
	if not db_party_contribute_[type] then return 0 end
	return #db_party_contribute_[type]
end


function PartyMO.queryPartyProp(keyId)
	if not db_party_prop_[keyId] then return nil end
	return db_party_prop_[keyId]
end

function PartyMO.queryScienceLevel(scienceId, scienceLv)
	if not db_party_science_[scienceId] then return nil end
	return db_party_science_[scienceId][scienceLv + 1]
end

function PartyMO.queryScienceMaxLevel(scienceId)
	if not db_party_science_[scienceId] then return 0 end
	return #db_party_science_[scienceId] - 1
end


function PartyMO.queryPartyWeal(wealLv)
	if not db_party_weal_[wealLv] then return nil end
	return db_party_weal_[wealLv]
end

function PartyMO.queryPartyLively(livelyLv)
	if not db_party_lively_[livelyLv] then return nil end
	return db_party_lively_[livelyLv]
end

function PartyMO.queryPartyMaxLively()
	return #db_party_lively_
end

function PartyMO.queryPartyLivelyTask(taskId)
	if not db_party_lively_task_[taskId] then return nil end
	return db_party_lively_task_[taskId]
end

function PartyMO.getLivelyDataByExp(exp)
	for index=1,#db_party_lively_ do
		if exp < db_party_lively_[index].livelyExp then
			return db_party_lively_[index]
		end
	end
end

function PartyMO.queryPartyTrend(trendId)
	if not db_party_trend_[trendId] then return nil end
	return db_party_trend_[trendId]
end

--军团BOSS捐献
function PartyMO.queryPartyBossContribute(type,count)
	if not db_party_altar_boss_contribute[type] then return nil end
	local maxCount = PartyMO.queryPartyBossContributeMaxCount(type)
	local mextCount = count + 1
	if mextCount > maxCount then
		mextCount = maxCount
	end
	return db_party_altar_boss_contribute[type][mextCount]
end

function PartyMO.queryPartyBossContributeMaxCount(type)
	if not db_party_altar_boss_contribute[type] then return 0 end
	return #db_party_altar_boss_contribute[type]
end

function PartyMO.queryPartyBossStar(lv)
	if not lv then return nil end
	return db_party_altar_boss_star[lv]
end

function PartyMO.queryPartyBossAwards(lv,star)
	if not db_party_altar_boss_award[lv] then return nil end
	return db_party_altar_boss_award[lv][star]
end

function PartyMO.queryPartyWealShow()
	if PartyMO.dayWealList and #PartyMO.dayWealList > 0 then
		return
	end
	PartyMO.dayWealList = {}
	for index=1,#db_party_weal_ do
		if index == 1 or index == 4 or index == 7 or
			index == 10 or index == 13 or index == 16 or 
			index == 19 or index == 22 or index == 25 or 
			index == 28 or index == 31 or index == 34 or 
			index == 37 or index == 40 then
			PartyMO.dayWealList[#PartyMO.dayWealList + 1] = db_party_weal_[index]
		end
	end

	return PartyMO.dayWealList
end

function PartyMO.queryPartyAltarBoss( lv )
	return db_party_altar_[lv]
end

function PartyMO.queryPartyAltarBossMaxLevel()
	return db_party_altar_maxLevel_
end

function PartyMO.getRankAward(lv)
	local awards = {}
	local maxRank = 3
	local altarboss = PartyMO.queryPartyAltarBoss(lv)
	for index=1, maxRank do
		local award = altarboss["rankAward" .. index]
		if award then
			local ret = {}
			ret.rank = index
			ret.awards = json.decode(award) 
			awards[#awards + 1] = ret			
		end
	end

	return awards	
end

--公会是否已申请
function PartyMO.isInApply(partyId)
	if PartyMO.applyList and #PartyMO.applyList > 0 then
		for index=1,#PartyMO.applyList do
			local id = PartyMO.applyList[index]
			if partyId == id then
				return true
			end
		end
	end
	return false
end

function PartyMO.clearMyParty()
	--我的军团信息
	PartyMO.partyData_ = {}

	--我的军团职位
	PartyMO.myJob = PARTY_JOB_MEMBER

	--军团职位人数
	PartyMO.partyJobCount = {}

	--所有军团列表
	PartyMO.allPartyList_ = {}

	--军团建筑基本信息
	PartyMO.buildData_ = {}

	--大厅信息
	PartyMO.hallData_ = {}

	--军团BOSS捐献信息
	PartyMO.partyBossData_ = {}

	--商店数据
	PartyMO.shopData_nomal_ = {}      	--普通
	PartyMO.shopData_treasure_ = {}		--珍品

	--科技大厅信息
	PartyMO.scienceData_ = {}

	--福利院信息
	PartyMO.wealData_ = {}

	--日常福利一览数据
	PartyMO.dayWealList = {}

	--我对军团的贡献值
	PartyMO.myDonate_ = 0

	---入团时间
	PartyMO.enterTime_ = 0
	---祭坛boss
	PartyMO.altarBoss_ = {}

	PartyMO.altarBossDirty_ = true

	PartyMO.allPartyList_type_ = 1  --1 全部 2可加入

	--个人申请帮派列表
	PartyMO.applyList = {}

	--军团申请玩家列表
	PartyMO.partyApplyList = {}
	PartyMO.partyApplyList_num = 0

	PartyMO.liveTaskList = {}


	--军团情报列表
	PartyMO.trends_1 = {}	--军情
	PartyMO.trends_2 = {}	--民情

	PartyMO.partyRankList_ = {}
	PartyMO.myPartyRank = nil

	--今日剩余次数
	PartyCombatMO.combatCount_ = 0

	--副本总数据
	PartyCombatMO.partyCombat_ = {}

	--副本单章数据
	PartyCombatMO.combatList_ = {}

	--领取过奖励的关卡ID
	PartyCombatMO.getAwardId_ = {}

	PartyBattleMO.clearData()
end

function PartyMO.getSciencePayloadAdd()
	local _payloadratio = 0
	if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		for index =1 , #PartyMO.scienceData_.scienceData do
			local scienceData = PartyMO.scienceData_.scienceData[index]
			if scienceData.scienceId == 201 then
				_payloadratio = scienceData.addtion * scienceData.scienceLv * 0.01
			end
		end
	end
	return _payloadratio
end

--只有4阶兵才加
function PartyMO.getSciencePayloadAddNew4()
	local _payloadratio = 0
	if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		for index =1 , #PartyMO.scienceData_.scienceData do
			local scienceData = PartyMO.scienceData_.scienceData[index]
			if scienceData.scienceId == 215 then
				_payloadratio = scienceData.addtion * scienceData.scienceLv * 0.005
			end
		end
	end
	return _payloadratio
end

--只有大于等于5阶兵才加
function PartyMO.getSciencePayloadAddNew5()
	local _payloadratio = 0
	if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		for index =1 , #PartyMO.scienceData_.scienceData do
			local scienceData = PartyMO.scienceData_.scienceData[index]
			if scienceData.scienceId == 215 then
				_payloadratio = scienceData.addtion * scienceData.scienceLv * 0.01
			end
		end
	end
	return _payloadratio
end

function PartyMO.getBossStarByExp(exp)
	local data = db_party_altar_boss_star
	if exp >= data[#data].exp then
		return data[#data].star
	else
		for index=1,#data do
			if exp >= data[index].exp and exp < data[index + 1].exp then
				return data[index].star
			end
		end
	end
end

function PartyMO.getStarInfoByStar(star)
	if not star then return db_party_altar_boss_star end
	for index=1,#db_party_altar_boss_star do
		if db_party_altar_boss_star[index].star == star then
			return db_party_altar_boss_star[index]
		end
	end

	return nil
end

function PartyMO.getPartyBossMaxStarInfo()
	return db_party_altar_boss_star[#db_party_altar_boss_star]
end