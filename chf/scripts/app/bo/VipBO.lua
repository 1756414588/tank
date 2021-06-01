
VipBO = {}

function VipBO.getPowerBuyCount()
	return VipMO.queryVip(UserMO.vip_).buyPower
end

function VipBO.getPowerBuyCoin()
	-- local vipCount = VipBO.getPowerBuyCount()

	-- local maxVip = VipMO.queryMaxVip()
	-- if maxVip == UserMO.vip_ then -- 刚好是最大VIP
	-- 	if (UserMO.powerBuy_ + 1) >= vipCount then return 120  -- 将是最后一次购买
	-- 	else return (UserMO.powerBuy_ + 1) * 5 end
	-- else
	-- 	return (UserMO.powerBuy_ + 1) * 5
	-- end

	if (UserMO.powerBuy_ + 1) > 12 then
		return 120
	else
		return (UserMO.powerBuy_ + 1) * 5 
	end	
end

function VipBO.getAreanBuyCount()
	return VipMO.queryVip(UserMO.vip_).buyArena
end

-- 购买装备副本次数
function VipBO.getBuyEquipCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyEquip
end

function VipBO.getBuyPartCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyPart
end

function VipBO.getBuyMilitaryCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyMilitary
end

function VipBO.getBuyTreasureCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyTreasure
end

function VipBO.getBuyTacticsCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyTactic
end

function VipBO.getBuyEnergySparCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyEnergyStone
end

function VipBO.getBuyMedalSparCombatCount()
	return VipMO.queryVip(UserMO.vip_).buyMedal
end

-- 当前生产、改装、科研的队列最多数量
function VipBO.getWaitQueueNum()
	return VipMO.queryVip(UserMO.vip_).waitQue
end

-- 当前可以升级、建造建筑的最多数量
function VipBO.getBuildQueueNum()
	return VipMO.queryVip(UserMO.vip_).buildQue
end

-- 当前任务的数量
function VipBO.getArmyCount()
	return VipMO.queryVip(UserMO.vip_).armyCount + 1
end

function VipBO.canWipe()
	if VipMO.queryVip(UserMO.vip_).wipe > 0 then return true
	else return false end
end

-- 配件强化成功率百分比加成
function VipBO.getPartProb()
	return VipMO.queryVip(UserMO.vip_).partProb
end

function VipBO.getSpeedBuild()
	return VipMO.queryVip(UserMO.vip_).speedBuild
end

function VipBO.getSpeedArmy()
	return VipMO.queryVip(UserMO.vip_).speedArmy
end

function VipBO.getSpeedTank()
	return VipMO.queryVip(UserMO.vip_).speedTank
end

function VipBO.getSpeedRefit()
	return VipMO.queryVip(UserMO.vip_).speedRefit
end

function VipBO.getSpeedScience()
	return VipMO.queryVip(UserMO.vip_).speedScience
end

function VipBO.getBuyshopNum()
	return VipMO.queryVip(UserMO.vip_).buyShop
end
