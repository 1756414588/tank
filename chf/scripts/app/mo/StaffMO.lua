
-- 军事矿区

local s_mine_senior = require("app.data.s_mine_senior")
local s_staffing = require("app.data.s_staffing")
local s_staffing_lv = require("app.data.s_staffing_lv")
local s_staffing_world = require("app.data.s_staffing_world")
local s_staffHero = require("app.data.s_hero_put")
local s_mine_cross = require("app.data.s_mine_cross")

StaffMO = {}

local db_mine_senior_ = nil -- 军事矿区信息表
local db_staffing_ = nil
local db_staffing_lv_ = nil
local db_staffing_world = nil
local db_staffHero_ = nil

MILITARY_AREA_SIZE_WIDTH = 20
MILITARY_AREA_SIZE_HEIGHT = 20

CROSS_SERVER_MILITARY_AREA_SIZE_WIDTH = 40
CROSS_SERVER_MILITARY_AREA_SIZE_HEIGHT = 40

MILITARY_AREA_PLUNDER = 1 -- 掠夺
MILITARY_AREA_ATTACK  = 2 -- 攻击

STAFFING_PLATOON_LEADER = 2 -- 排长

STAFFING_CYCLE_TIME = 1800  -- 编制结算的时间，30分钟

StaffMO.ranking_ = 0
StaffMO.worldLv_ = 0  -- 世界等级

StaffMO.mapData_ = {}

StaffMO.plunderCount_ = 0 -- 剩余掠夺次数
StaffMO.plunderLimit_ = 0 -- 掠夺次数限制(值等于5)
StaffMO.plunderBuy_ = 0 -- 已购买掠夺的次数

-- 个人排名数据
StaffMO.rankPerson_ = 0
StaffMO.rankPersonReceive_ = 0
StaffMO.rankPersonScore_ = 0

-- 军团排名数据
StaffMO.rankParty_ = 0
StaffMO.rankPartyReceive_ = 0
StaffMO.rankPartyScore_ = 0

StaffMO.curAttackPos_ = cc.p(0, 0)  -- 军事矿区攻击位置坐标
StaffMO.curAttackType_ = 0 -- 表示是掠夺还是攻击

StaffMO.isStaffOpen_ = true -- 是否开启编制

StaffMO.refreshHandler_ = nil

StaffMO.synStaffingHandler_ = nil

StaffMO.staffHerosData_ = nil --buff将领信息


local db_mine_cross_ = nil -- 跨服军事矿区信息表

StaffMO.CrossServerMineOpen = 1 --跨服军事矿区开启状态
StaffMO.CrossmapData_ = {} --跨服军事矿区地图信息

-- StaffMO.CrossplunderCount_ = 0 -- 跨服军事矿区剩余掠夺次数
-- StaffMO.CrossplunderLimit_ = 0 -- 跨服军事矿区掠夺次数限制(值等于5)
-- StaffMO.CrossplunderBuy_ = 0 -- 跨服军事矿区已购买掠夺的次数

StaffMO.curCrossAttackPos_ = cc.p(0, 0)  -- 跨服军事矿区攻击位置坐标
StaffMO.curCrossAttackType_ = 0 -- 表示是掠夺还是攻击

--  跨服军事矿区个人排名数据
StaffMO.CrossServerrankPerson_ = 0
StaffMO.CrossServerrankPersonReceive_ = 0
StaffMO.CrossServerrankPersonScore_ = 0

--  跨服军事矿区军团排名数据
StaffMO.CrossServerrankServer_ = 0
StaffMO.CrossServerrankServerReceive_ = 0
StaffMO.CrossServerrankServerScore_ = 0

-- 跨服军矿跨服排行领奖积分限制
StaffMO.CrossServerMineServerScore_ = 800

--跨服服务器列表
StaffMO.ServerListData_ = {}

function StaffMO.init()
	db_mine_senior_ = {}
	local records = DataBase.query(s_mine_senior)
	for index = 1, #records do
		local data = records[index]
		db_mine_senior_[data.pos] = data
	end

	db_staffing_ = {}
	local records = DataBase.query(s_staffing)
	for index = 1, #records do
		local data = records[index]
		db_staffing_[data.staffingId] = data
	end

	db_staffing_lv_ = {}
	local records = DataBase.query(s_staffing_lv)
	for index = 1, #records do
		local data = records[index]
		db_staffing_lv_[data.staffingLv] = data
	end	

	db_staffing_world = {}
	local records = DataBase.query(s_staffing_world)
	for index = 1, #records do
		local data = records[index]
		db_staffing_world[data.worldLv] = data
	end	

	db_staffHero_ = {}
	local records = DataBase.query(s_staffHero)
	for index = 1, #records do
		local data = records[index]
		db_staffHero_[data.partId] = data
	end	

	db_mine_cross_ = {}
	local records = DataBase.query(s_mine_cross)
	for index = 1, #records do
		local data = records[index]
		db_mine_cross_ [data.pos] = data
	end
end

function StaffMO.queryMineByPos(pos)
	local mineData = clone(db_mine_senior_[pos])
	if mineData then
		mineData.lv = mineData.lv + WorldMO.worldMineLevel * 2
		if mineData.lv > 100 then
			mineData.lv = 100
		end
		return mineData
	end
end

-- 军衔最大的等级
function StaffMO.queryStaffMax()
	return #db_staffing_
end

function StaffMO.queryStaffById(staffingId)
	return db_staffing_[staffingId]
end

function StaffMO.queryStaffLvMaxLv()
	return #db_staffing_lv_
end

function StaffMO.queryStaffLvByLv(lv)
	return db_staffing_lv_[lv]
end

function StaffMO.queryWorldByLv(lv)
	return db_staffing_world[lv]
end

function StaffMO.queryWorldMaxLv()
	return #db_staffing_world
end

-- local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
function StaffMO.getMapDataAt(x, y)
	local pos = StaffMO.encodePosition(x, y)
	return StaffMO.mapData_[pos]
end

-- function StaffMO.setMapDataAt(x, y, mapData)
-- end

function StaffMO.encodePosition(x, y)
	return x + MILITARY_AREA_SIZE_WIDTH * y
end

function StaffMO.decodePosition(pos)
	pos = pos or 0
	local x = pos % MILITARY_AREA_SIZE_WIDTH
	local y = math.floor(pos / MILITARY_AREA_SIZE_HEIGHT)
	return cc.p(x, y)
end

function StaffMO.queryStaffHeroInfo()
	return db_staffHero_
end

function StaffMO.queryStaffHeroById(partId)
	return db_staffHero_[partId]
end

--根据partId索取当前part加成大的文官
function StaffMO.queryStrongStaffHeroById(data)
	local max = 0
	local maxHeroId = 0
	local skillValue_ = {}
	for idx =1,#data do
		skillValue_[#skillValue_ + 1] = HeroMO.getHeroById(data[idx])
		if skillValue_[idx] == nil then
			skillValue_[idx] = {}
			skillValue_[idx].skillValue = 0
			skillValue_[idx].heroId = 0
		end
		if skillValue_[idx].skillValue > max then
			max = skillValue_[idx].skillValue
			maxHeroId = skillValue_[idx].heroId
		end
	end
	return max,maxHeroId
end

function StaffMO.queryCrossMineByPos(pos)
	local mineData = clone(db_mine_cross_[pos])
	if mineData then
		-- mineData.lv = mineData.lv + WorldMO.worldMineLevel * 2
		-- if mineData.lv > 100 then
		-- 	mineData.lv = 100
		-- end
		return mineData
	end
end

function StaffMO.getCrossMapDataAt(x, y)
	local pos = StaffMO.encodeCrossPosition(x, y)
	return StaffMO.CrossmapData_[pos]
end

function StaffMO.encodeCrossPosition(x, y)
	return x + CROSS_SERVER_MILITARY_AREA_SIZE_WIDTH * y
end

function StaffMO.decodeCrossPosition(pos)
	pos = pos or 0
	local x = pos % CROSS_SERVER_MILITARY_AREA_SIZE_WIDTH
	local y = math.floor(pos /  CROSS_SERVER_MILITARY_AREA_SIZE_HEIGHT)
	return cc.p(x, y)
end
