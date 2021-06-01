
local s_tank = require("app.data.s_tank")
local c_attack = require("app.data.c_attack")
local c_tank = require('app.data.c_tank')

TankMO = {}

TANK_BOSS_CONFIG_ID = 1001  -- 世界BOSS的UI配置ID

TANK_ALTAR_BOSS_CONFIG_ID = 1002  -- 军团BOSS的UI配置ID

TANK_BOSS_POSITION_INDEX = 5

FORMATION_LOCK_DATA = {5, 1, 6, 10, 3, 15}  -- 每个位置分别是多少级开启

FORAMTION_VIP_OPEN = {0, 2, 5, 8}  -- 每个模板阵型开启的VIP等级

-- 多少辆坦克消耗一个金币
TANK_REPAIR_COIN_RATE = 10

-- 坦克一次性生产的最大数量
TANK_PRODUCT_MAX_NUM = 100
-- 坦克一次军工改装最大数量
TANK_REFIT_MAX_NUM = 1000

-- 上阵坦克的位置数量
FIGHT_FORMATION_POS_NUM = 6

FORMATION_FOR_TEMPLATE = 1 -- 模板阵型 VIP0
FORMATION_FOR_FIGHT = 2  -- 防守阵型
FORMATION_FOR_ARENA = 3  -- 竞技场阵型
FORMATION_FOR_TEMPLATE_2 = 4 -- 模板阵型 VIP2
FORMATION_FOR_TEMPLATE_3 = 5 -- 模板阵型 VIP5
FORMATION_FOR_TEMPLATE_4 = 6 -- 模板阵型 VIP8
FORMATION_FOR_BOSS = 7 -- 世界BOSS
FORMATION_FORTRESS = 8 -- 要塞战阵型 防守
FORMATION_FOR_ALTAR_BOSS = 9 -- 军团BOSS阵型
FORMATION_FOR_EXERCISE1 = 10 -- 演习阵型1
FORMATION_FOR_EXERCISE2 = 11 -- 演习阵型2
FORMATION_FOR_EXERCISE3 = 12 -- 演习阵型3
FORMATION_FOR_CROSS = 13 -- 跨服积分赛阵型
FORMATION_FOR_CROSS1 = 14 -- 跨服积分赛阵型2
FORMATION_FOR_CROSS2 = 15 -- 跨服积分赛阵型3
FORMATION_FOR_HUNTER = 16 -- 赏金猎人阵型
FORMATION_FORTRESS_ATTACK = 17 -- 要塞战阵型 进攻
FORMATION_FOR_COMBAT_TEMP = 18 -- 副本 临时阵容 进保存在客户端 不参与初始化

FORMATION_MAX_NUM = FORMATION_FOR_COMBAT_TEMP  -- 阵型type的最大数量



TANK_TYPE_TANK       = 1 -- 坦克
TANK_TYPE_CHARIOT    = 2 -- 战车
TANK_TYPE_ARTILLERY  = 3 -- 火炮
TANK_TYPE_ROCKET     = 4 -- 火箭

ATTACK_MODE_HORIZONTAL  = 1 -- 横排
ATTACK_MODE_VERTICAL    = 2 -- 竖排
ATTACK_MODE_ALL         = 3 -- 全体
ATTACK_MODE_SINGLE      = 4 -- 单体

BATTLE_REPAIR_RATE = 0.8  -- 坦克中折损后可修复的比率

-- 我方所有的坦克
TankMO.tanks_ = {}

-- 玩家部队模板的阵型
TankMO.formation_ = {}

TankMO.dirtyTankData_ = false

TankMO.unlockPosition_ = 0 -- 如果有阵型位置解锁，记录位置，用于界面显示

-- 缓存数据表中所有以tankId为key的数据
local db_tanks_ = nil

local db_attacks_ = nil
local db_tank_attacks = nil

function TankMO.init()
	db_tanks_ = {}
	local records = DataBase.query(s_tank)
	for index = 1, #records do
		local data = records[index]
		db_tanks_[data.tankId] = data
	end

	db_attacks_ = {}
	local records = DataBase.query(c_attack)
	for index = 1, #records do
		local data = records[index]
		db_attacks_[data.type] = data
	end

	db_tank_attacks = {}
	local records = DataBase.query(c_tank)
	for index = 1, #records do
		local data = records[index]
		db_tank_attacks[data.tankId] = data
	end
end

function TankMO.queryTankById(tankId)
	if not tankId or tankId <= 0 or not db_tanks_[tankId] then
		gprint("[TankMO] queryTankById id is Error:", tankId)
	end

	return db_tanks_[tankId]
end

-- 获得所有可以生产的坦克
function TankMO.queryCanBuildTanks()
	local ret = {}
	for tankId, tank in pairs(db_tanks_) do
		if tank.canBuild == 0 then
			ret[#ret + 1] = tank
		end
	end
	return ret
end

-- 获得所有可以改装的坦克
function TankMO.queryCanRefitTanks()
	local ret = {}
	for tankId, tank in pairs(db_tanks_) do
		if tank.canRefit == 1 then
			ret[#ret + 1] = tank
		end
	end
	return ret
end

function TankMO.queryAttackByType(type)
	return db_attacks_[type]
end

function TankMO.queryTankAttackById(tankId)
	return db_tank_attacks[tankId]
end

-- 需要维修的tank数量
function TankMO.getTankRepairCountById(tankId)
	local tank = TankMO.tanks_[tankId]
	if not tank then return 0
	else return tank.rest end
end

function TankMO.setTankRepairCountById(tankId, count)
	local tank = TankMO.tanks_[tankId]
	if not tank then TankMO.tanks_[tankId] = {count = 0, rest = count}
	else TankMO.tanks_[tankId].rest = count end
end

-- 增加tank需要维修的数量
function TankMO.addTankRepairCountById(tankId, count)
	local tank = TankMO.tanks_[tankId]
	if not tank then TankMO.tanks_[tankId] = {count = 0, rest = count}
	else TankMO.tanks_[tankId].rest = TankMO.tanks_[tankId].rest + count end
end

-- 获得所有需要修复的tank
function TankMO.getNeedRepairTanks()
	local ret = {}
	for tankId, tank in pairs(TankMO.tanks_) do
		if tank.rest > 0 then  -- 需要修复的数量
			ret[#ret + 1] = tank
		end
	end
	return ret
end

-- 获得所有可以上阵的tank
function TankMO.getFightTanks()
	local ret = {}
	for tankId, tank in pairs(TankMO.tanks_) do
	-- for index = 1, #TankMO.tanks_ do
	-- 	local tank = TankMO.tanks_[index]
		if tank.count > 0 then -- 可以出战
			ret[#ret + 1] = tank
		end
	end
	return ret
end
-- 获得指定位置position的出阵信息
function TankMO.getFormationByType(formatType)
	-- gprint("formatType:", formatType)
	-- gdump(TankMO.formation_, "后台数据")
	if not formatType then formatType = FORMATION_FOR_TEMPLATE end
	
	return TankMO.formation_[formatType]
end

function TankMO.isEmptyFormation(formation)
	if not formation then return true end
	if formation.commander and formation.commander > 0 then return false end
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local data = formation[index]
		if data and data.count > 0 and data.tankId > 0 then
			return false
		end
	end
	return true
end

function TankMO.getEmptyFormation(tankId)
	tankId = tankId or 0
	return {{tankId = tankId, count = 0}, {tankId = tankId, count = 0}, {tankId = tankId, count = 0}, {tankId = tankId, count = 0}, {tankId = tankId, count = 0}, {tankId = tankId, count = 0}, commander = 0}
end

function TankMO.calcRepairNum(count)
	return math.ceil(count * BATTLE_REPAIR_RATE)
end

-- 获得所有需要修复的tanks，以及修复的成本
function TankMO.calcRepairCost(tanks)
	local cost = {}
	cost.coinTotal = 0
	cost.gemTotal = 0
	for _, tank in pairs(tanks) do
		if tank.rest and tank.rest > 0 then  -- 需要修复的数量
			local tankDB = TankMO.queryTankById(tank.tankId)

			-- 修复分别需要消耗金币和宝石数
			cost[#cost + 1] = {coin = math.ceil(tank.rest / TANK_REPAIR_COIN_RATE), gem = tankDB.repair * tank.rest}

			cost.coinTotal = cost.coinTotal + cost[#cost].coin
			cost.gemTotal = cost.gemTotal + cost[#cost].gem
		end
	end
	return cost
end

function TankMO.getHPByTankId(tankId)
	-- body
	local tankDB = db_tanks_[tankId]
	return tankDB.hp
end

--获得所有的可出战的金币车
function TankMO.getAllMoneyTanks()
	local ret = {}
	for tankId, tank in pairs(TankMO.tanks_) do
		local data = TankMO.queryTankById(tank.tankId)
		if tank.count > 0 and data.canBuild == 1 then --金币车
			ret[#ret + 1] = tank
		end
	end
	return ret
end