
ArmyMO = {}

ArmyMO.army_ = {}

ArmyMO.invasion_ = {}  -- 有人进攻

ArmyMO.aid_ = {}  -- 驻军、待命、驻军行军中

ARMY_TYPE_ARMY = 1
ARMY_TYPE_INVASION = 2  -- 敌人攻打自己的路上、或者军团成员往自己家驻军的路上
ARMY_TYPE_AID = 3  -- 正在驻军

-- 部队的状态
ARMY_STATE_MARCH    = 1 -- 行军
ARMY_STATE_RETURN   = 2 -- 返回
ARMY_STATE_COLLECT  = 3 -- 采集
ARMY_STATE_GARRISON = 4 -- 驻军
ARMY_STATE_WAITTING = 5 -- 等待
ARMY_STATE_AID_MARCH =  6 -- 援助行军
ARMY_STATE_PARTYB = 7 -- 百团混战
ARMY_STATE_FORTRESS = 8 -- 要塞战驻军
ARMY_AIRSHIP_BEGAIN = 15 -- 飞艇部队 准备中
ARMY_AIRSHIP_MARCH = 16 --飞艇部队 行军中
ARMY_AIRSHIP_GUARD_MARCH = 17 --飞艇部队 驻防行军中
ARMY_AIRSHIP_GUARD = 18 --飞艇部队 驻防中

-- 接受SynInvasion的数据
ArmyMO.synInvasionHandler_ = nil

-- 接受SynArmy的数据
ArmyMO.synArmyHandler_ = nil

ArmyMO.tickHandler_ = nil

ArmyMO.dirtyArmyData_ = false  -- 判断GetArmy数据是否正常，如果不正常，需要重新拉取
-- ArmyMO.refreshHandler_ = nil

ARMY_SETTING_FOR_SETTING = 1 -- 用于设置
ARMY_SETTING_FOR_COMBAT  = 2 -- 用于副本
ARMY_SETTING_FOR_WIPE    = 3 -- 用于扫荡
ARMY_SETTING_FOR_ARENA   = 4 -- 用于竞技场
ARMY_SETTING_FOR_WORLD   = 5 -- 用于世界
ARMY_SETTING_FOR_GUARD   = 6 -- 用于驻军
ARMY_SETTING_FOR_PARTYB   = 7 -- 用于百团混战
ARMY_SETTING_FOR_BOSS    = 8 -- 用于世界BOSS
ARMY_SETTING_FOR_MILITARY_AREA  = 9 -- 用于军事矿区
ARMY_SETTING_FORTRESS  = 10 -- 用于要塞战防守
ARMY_SETTING_FORTRESS_ATTACK  = 11 -- 用于要塞战攻击
ARMY_SETTING_FOR_ALTAR_BOSS    = 12 -- 用于军团BOSS
ARMY_SETTING_FOR_CROSS    = 13 -- 用于跨服战
ARMY_SETTING_FOR_CROSS1    = 14 -- 用于跨服战2
ARMY_SETTING_FOR_CROSS2    = 15 -- 用于跨服战3
ARMY_SETTING_FOR_CROSSPARTY    = 16 -- 用军团跨服战
ARMY_SETTING_AIRSHIP_ATTACK = 17 --用于飞艇攻击
ARMY_SETTING_AIRSHIP_DEFEND = 18 --用于飞艇驻防
ARMY_SETTING_HUNTER = 19 --用于赏金
ARMY_SETTING_FOR_CROSS_MILITARY_AREA  = 20 -- 用于跨服军事矿区

ARMY_SETTING_FOR_EXERCISE1    = 101 -- 演习布阵1
ARMY_SETTING_FOR_EXERCISE2    = 102 -- 演习布阵2
ARMY_SETTING_FOR_EXERCISE3    = 103 -- 演习布阵3

-- 目标部队类型
ARMY_TARGET_TYPE_NONE	 	= 0 	-- 未定义
ARMY_TARGET_TYPE_ACT_REBEL	= 1 	-- 活动叛军(剿匪)
ARMY_TARGET_TYPE_REBEL 		= 2 	-- 叛军
ARMY_TARGET_TYPE_PLAYER		= 3 	-- 其他玩家
ARMY_TARGET_TYPE_MINT 		= 4 	-- 打矿
ARMY_TARGET_TYPE_AIRSHIP	= 5 	-- 飞艇


function ArmyMO.getArmyByKeyId(keyId)
	return ArmyMO.army_[keyId]
end

function ArmyMO.getArmiesByState(state)
	local ret = {}
	for _, army in pairs(ArmyMO.army_) do
		if army.state == state then
			ret[#ret + 1] = army
		end
	end
	return ret
end

function ArmyMO.getAllArmies()
	return table.values(ArmyMO.army_)
end

function ArmyMO.getArmyNum()
	return #ArmyMO.getAllArmies()
end

function ArmyMO.getInvasion(keyId, lordId)
	for index = 1, #ArmyMO.invasion_ do
		local invasion = ArmyMO.invasion_[index]
		if invasion.keyId == keyId and invasion.lordId == lordId then
			return invasion
		end
	end
end

function ArmyMO.removeInvasion(keyId, lordId)
	local findIndex = 0
	for index = 1, #ArmyMO.invasion_ do
		local invasion = ArmyMO.invasion_[index]
		if invasion.keyId == keyId and invasion.lordId == lordId then
			findIndex = index
			break
		end
	end
	if findIndex > 0 then
		table.remove(ArmyMO.invasion_, findIndex)
	end
end

function ArmyMO.getAllInvasions()
	return ArmyMO.invasion_
end

function ArmyMO.getInvasionsByState(state)
	local ret = {}
	for index = 1, #ArmyMO.invasion_ do
		local invasion = ArmyMO.invasion_[index]
		if invasion.state == state then
			ret[#ret + 1] = invasion
		end
	end
	return ret
end

function ArmyMO.getAllAids()
	return ArmyMO.aid_
end

function ArmyMO.getAid(keyId, lordId)
	local findIndex = 0
	for index = 1, #ArmyMO.aid_ do
		local aid = ArmyMO.aid_[index]
		if aid.keyId == keyId and aid.lordId == lordId then
			if findIndex > 0 then
				error("[ArmyMO] getAidByKeyId")
			else
				findIndex = index
			end
		end
	end
	if findIndex > 0 then return ArmyMO.aid_[findIndex] end
end

function ArmyMO.removeAid(keyId, lordId)
	local findIndex = 0
	for index = 1, #ArmyMO.aid_ do
		local aid = ArmyMO.aid_[index]
		if aid.keyId == keyId and aid.lordId == lordId then
			findIndex = index
			break
		end
	end
	if findIndex > 0 then
		table.remove(ArmyMO.aid_, findIndex)
	end
end

function ArmyMO.orderArmy(armyA, armyB)
	-- if armyA.state == armyB.state then
		local leftTimeA = SchedulerSet.getTimeById(armyA.schedulerId)
		local leftTimeB = SchedulerSet.getTimeById(armyB.schedulerId)
		if leftTimeA < leftTimeB then
			return true
		else
			return false
		end
	-- elseif armyA.state == ARMY_STATE_MARCH then
	-- 	return true
	-- elseif armyB.state == ARMY_STATE_MARCH then
	-- 	return true
	-- else
	-- 	if armyA.state < armyB.state then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end
end

----判断飞艇是否可以派兵
function ArmyMO.checkAirshpState( airshipId )
	local ab = AirshipMO.queryShipById(airshipId)
	local canJoin = true

	for k,v in pairs(ArmyMO.army_) do
		if (v.state >= ARMY_AIRSHIP_BEGAIN and v.state <= ARMY_AIRSHIP_GUARD) and ab.pos == v.target then
			canJoin = false
		end
	end		

	return canJoin
end

--获取除驻军外出战部队的数量
function ArmyMO.getFightArmies()
	local armys = 0

	for k,v in pairs(ArmyMO.army_) do
		if v.isZhujun ~= 1 then
			armys = armys + 1
		end
	end

	return armys
end

--获取除驻军部队的数量
function ArmyMO.getZhujunFightArmies()
	local armys = 0

	for k,v in pairs(ArmyMO.army_) do
		if v.isZhujun == 1 then
			armys = armys + 1
		end
	end

	return armys
end