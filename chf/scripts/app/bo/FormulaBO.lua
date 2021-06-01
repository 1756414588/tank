
FormulaBO = {}

-- 根据建筑的升级时间upTime，计算各种建筑加速加成，获得最终建筑升级时间
function FormulaBO.buildingUpTime(upTime,buildId)
	local factor = VipBO.getSpeedBuild()
	local addition = ScienceBO.buildUpAddition(buildId)  -- 建筑加速
	local job = FortressMO.buildSpeed()  -- 要塞职位加速
	-- print("---------------------------",factor,addition,job)
	local activity = EffectMO.buildTime()
	return math.ceil(upTime / (1 + (factor + addition + job + activity) / 100))
end

-- 生产坦克需要消耗的时间
function FormulaBO.tankBuildTime(buildingId, tankId)
	-- gprint("111111 buildingId:", buildingId, "tankId:", tankId)
	if buildingId ~= BUILD_ID_CHARIOT_A and buildingId ~= BUILD_ID_CHARIOT_B then return 0 end
	local tank = TankMO.queryTankById(tankId)
	if not tank then return 0 end

	local buildLevel = BuildMO.getBuildLevel(buildingId)
	-- local hero = HeroBO.getProductHero()
	local hero = HeroBO.getStaffHero(HERO_STAFF_PRODUCT)
	local value = tank.buildTime
	local reduce = OrdnanceBO.getProduceReduce(tankId)
	value = value - reduce
	if value < 0 then value = 0 end
	local job = FortressMO.productSpeed()
	local act = EffectMO.tankBuild()
	local lab = LaboratoryBO.getProductTypeAttr(tank.type)

	local _buildPDU = buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100
	local _vipPDU = VipBO.getSpeedTank() / 100
	local _jobPDU = job/100
	local _actPDU = act/100
	local _labPDU = lab/100
	local _heroPDU = hero and hero.skillValue / 100 or 0

	local _PDU = 1 + _buildPDU + _vipPDU + _jobPDU + _actPDU + _labPDU + _heroPDU

	value = value / _PDU
	-- if hero then
	-- 	value = value / (1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedTank() / 100 + job/100 + act/100 + hero.skillValue / 100)
	-- else
	-- 	value = value / (1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedTank() / 100 + job/100 + act/100)
	-- end
	return value
end

-- 改装坦克需要消耗的时间
function FormulaBO.tankRefitTime(buildingId, tankId)
	local chariotLevel = BuildBO.getChariotMaxLevel() -- 战车工厂的等级
	local buildLevel = BuildMO.getBuildLevel(buildingId) -- 改装工厂的等级

	local tank = TankMO.queryTankById(tankId)
	local refitTank = TankMO.queryTankById(tank.refitId) -- 改装到的坦克

	local deltaTime = refitTank.buildTime - tank.buildTime
	local reduce = OrdnanceBO.getProduceReduce(refitTank.tankId)
	deltaTime = deltaTime - reduce
	if deltaTime < 0 then deltaTime = 0 end

	-- local hero = HeroBO.getRefitHero()
	local hero = HeroBO.getStaffHero(HERO_STAFF_REFINE)
	local value = 0
	local job = FortressMO.productSpeed()
	local act = EffectMO.tankRefine()
	local lab = LaboratoryBO.getRefitTypeAttr(refitTank.type)

	local _buildPDU = buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100
	local _vipPDU = VipBO.getSpeedRefit() / 100
	local _jobPDU = job/100
	local _actPDU = act/100
	local _labPDU = lab/100
	local _heroPDU = hero and hero.skillValue / 100 or 0

	local _PDU = 1 + _buildPDU + _vipPDU + _jobPDU + _actPDU + _labPDU + _heroPDU
	value = deltaTime / _PDU
	-- if hero then
	-- 	value = deltaTime / (1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedRefit() / 100 + job/100 + act/100 + hero.skillValue / 100)
	-- else
	-- 	value = deltaTime / (1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedRefit() / 100 + job/100 + act/100)
	-- end
	return value
end

function FormulaBO.scienceUpTime(scienceId, scienceLv)
	local upTime = ScienceMO.queryScienceLevel(scienceId, scienceLv).upTime
	local buildLevel = BuildMO.getBuildLevel(BUILD_ID_SCIENCE)

	if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
		local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
		local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
		local upIds = json.decode(refitInfo.techId)
		for index=1,#upIds do
			if upIds[index] == scienceId then
				buildLevel = buildLevel + refitInfo.lv
			end
		end
	end

	local activityRate --研发速度享受活动倍数
	if ActivityBO.scienceIsDis(scienceId) then
		activityRate = ACTIVITY_ID_SCIENCE_DIS_SPEED
	else
		activityRate = 0
	end
	-- local hero = HeroBO.getScienceHero()
	local hero = HeroBO.getStaffHero(HERO_STAFF_SCIENCE)
	local job = FortressMO.scienceSpeed()
	if hero then
		return upTime / (activityRate + 1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedScience() / 100 + job/100 + hero.skillValue / 100)
	else
		return upTime / (activityRate + 1 + buildLevel * BUILD_LEVEL_PRODUCT_SPEED / 100 + VipBO.getSpeedScience() / 100 + job/100)
	end
end

function FormulaBO.buildProductSpeed(buildLevel)
	return buildLevel * BUILD_LEVEL_PRODUCT_SPEED
end

-- 获得某个装备equipId在等级equipLv下的属性值
-- function FormulaBO.equipAttributeValue(equipId, equipLv)
function FormulaBO.equipAttributeValue(equipId, equipLv, star)
	local equip = EquipMO.queryEquipById(equipId)
	if not equip then return 0 end
	local stars = star or 0
	local starValue = 0
	local starDB = EquipMO.queryEquipStarsById(stars)
	if starDB then
		starValue = starDB.starUpProperty
	end
	-- return (equip.a + equip.b * (equipLv - 1))
	return (equip.a + equip.b * (equipLv - 1) + equip.b * starValue)
end

function FormulaBO.partAttributeValue(attributeId, valueA, valueB, upLv, refitLv)
	if refitLv==10 then
		return valueA * (upLv + 1) + valueB * refitLv + valueA * (upLv + 1)*0.15
	else
		return valueA * (upLv + 1) + valueB * refitLv
	end
end

function FormulaBO.medalAttributeValue(attributeId, valueA, valueB, upLv, refitLv)
	if refitLv==10 then
		return valueA * (upLv + 1) + valueB * refitLv + valueA * (upLv + 1)*0.15
	else
		return valueA * (upLv + 1) + valueB * refitLv
	end
end

-- 配件强度值
function FormulaBO.partStrengthValue(attributeId, attrValue)
	if attributeId % 2 == 0 then return attrValue * 800
	else return attrValue * 20 end
end
