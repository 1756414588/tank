
local Fighter = require("app.fight.entity.Fighter")
-- local Tank = require("app.fight.entity.Tank")
-- local Chariot = require("app.fight.entity.Chariot")
-- local Artillery = require("app.fight.entity.Artillery")
-- local Rocket = require("app.fight.entity.Rocket")

-- ENTITY_KIND_TANK = 1

EntityFactory = {}

-- 所有Entity被add的父节点
local parentNode_ = nil

function EntityFactory.init(parentNode)
	parentNode_ = parentNode
end

function EntityFactory.createTank(tankFor, pos, tankId, tankCount, hp)
	if not parentNode_ then
		error("[EntityFactory] create tank Error!!! No PARENT.")
	end

	local entity = nil

	if tankId == 401 then
	-- if tankId == 401 or (pos == 5 and tankFor == BATTLE_FOR_DEFEND) then
		local bountyBossId = HunterMO.curBountyBossId
		local RailGun = require("app.fight.entity.RailGun")
		entity = RailGun.new(tankFor, pos, 401, tankCount, hp, bountyBossId):addTo(parentNode_, Fighter.LAYER_BODY1)
		return entity
	end

	if tankId == 402 then
	-- if tankId == 403 or (pos == 5 and tankFor == BATTLE_FOR_DEFEND) then
		local bountyBossId = HunterMO.curBountyBossId
		local DestructTruck = require("app.fight.entity.DestructTruck")
		entity = DestructTruck.new(tankFor, pos, 402, tankCount, hp, bountyBossId):addTo(parentNode_, Fighter.LAYER_BODY1)
		return entity
	end

	if tankId == 403 then
	-- if tankId == 403 or (pos == 5 and tankFor == BATTLE_FOR_DEFEND) then
		local bountyBossId = HunterMO.curBountyBossId
		local V3Rocket = require("app.fight.entity.V3Rocket")
		entity = V3Rocket.new(tankFor, pos, 403, tankCount, hp, bountyBossId):addTo(parentNode_, Fighter.LAYER_BODY1)
		return entity
	end

	if tankId == 404 then
		local V3SubRocket = require("app.fight.entity.V3SubRocket")
		entity = V3SubRocket.new(tankFor, pos, 404, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY1)
		return entity
	end

	if tankId == TANK_BOSS_CONFIG_ID or tankId == TANK_ALTAR_BOSS_CONFIG_ID then  -- 世界BOSS
		local Boss = require("app.fight.entity.Boss")
		entity = Boss.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_)
	elseif EntityFactory.isAirsship(tankId) then
		local Airsship = require("app.fight.entity.Airsship")
		local airshipId = BattleMO.airshipId_

		entity = Airsship.new(tankFor, pos, tankId, tankCount, hp, airshipId):addTo(parentNode_, Fighter.LAYER_BODY1)
	-- elseif EntityFactory.isBountyBoss(tankId) then
	-- 	local bountyBossId = HunterMO.curBountyBossId
	-- 	local RailGun = require("app.fight.entity.RailGun")

	-- 	entity = RailGun.new(tankFor, pos, tankId, tankCount, hp, bountyBossId):addTo(parentNode_, Fighter.LAYER_BODY1)
	elseif EntityFactory.isMoneyTank(tankId) then
		local tankDB = TankMO.queryTankById(tankId)
		if tankDB.type == TANK_TYPE_TANK then
			local Tank = require("app.fight.entity.MoneyTank")
			entity = Tank.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_CHARIOT then
			local Chariot = require("app.fight.entity.MoneyChariot")
			entity = Chariot.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_ARTILLERY then
			local Artillery = require("app.fight.entity.MoneyArtillery")
			entity = Artillery.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_ROCKET then
			local Rocket = require("app.fight.entity.MoneyRocket")
			entity = Rocket.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		end
	else
		local tankDB = TankMO.queryTankById(tankId)
		if tankDB.type == TANK_TYPE_TANK then
			local Tank = tankDB.special == 1 and require("app.fight.entity.TankEx") or require("app.fight.entity.Tank")
			entity = Tank.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_CHARIOT then
			local Chariot= tankDB.special == 1 and require("app.fight.entity.ChariotEx") or require("app.fight.entity.Chariot")
			entity = Chariot.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_ARTILLERY then
			local Artillery = tankDB.special == 1 and require("app.fight.entity.ArtilleryEx") or require("app.fight.entity.Artillery")
			entity = Artillery.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		elseif tankDB.type == TANK_TYPE_ROCKET then
			local Rocket = tankDB.special == 1 and require("app.fight.entity.RocketEx") or require("app.fight.entity.Rocket")
			entity = Rocket.new(tankFor, pos, tankId, tankCount, hp):addTo(parentNode_, Fighter.LAYER_BODY)
		end
	end

	if not entity then
		gprint("tankId", tankId)
		error("[EntityFactory] create tank ERROR!!!")
	end

	return entity
end

function EntityFactory.isAirsship(tankId)
	if tankId >= 300 and tankId <= 307 then
		return true
	end
	return false
end

function EntityFactory.isMoneyTank(tankId)
	local tank = TankMO.queryTankById(tankId)
	if tank.special == 2 then  --特殊金币车
		return true
	end
	return false
end

function EntityFactory.isBountyBoss(tankId)
	-- body
	if tankId >= 401 and tankId <= 403 then
		return true
	end
	return false
end
