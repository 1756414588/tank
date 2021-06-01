
-- 计算多个属性对一辆作战单位的战斗力数值
local function calcAttrFightValue(tankDB, attrValues, tag)
	local factor = 0

	-- if tag then
	-- 	print("tag!!!!", tag)
	-- 	gdump(attrValues, "calcAttrFightValue attrValues==")
	-- end

	-- if tag then
	-- 	print("start----------------------------------------------")
	-- end
	for _, attr in pairs(attrValues) do
		if type(attr) == "table" then
			-- if tag then
			-- 	print("attr.attrName!!!!", attr.attrName)
			-- end

			if attr.attrName == "maxHp" then 
				-- local temp = attr.value * tankDB.hpFactor * 1000
				factor = factor + attr.value * tankDB.hpFactor * 1000
				-- if tag then
				-- 	print("fight contribute", temp)
				-- end
			elseif attr.attrName == "attack" then 
				-- local temp = attr.value * tankDB.attckFactor * 1000
				factor = factor + attr.value * tankDB.attckFactor * 1000
				-- if tag then
				-- 	print("fight contribute", temp)
				-- end
			elseif attr.attrName == "impale" or attr.attrName == "defend" or attr.attrName == "frighten" or attr.attrName == "fortitude" then
				-- local temp = attr.value * 10
				factor = factor + attr.value * 10
				-- if tag then
				-- 	print("fight contribute", temp)
				-- end
			else 
				-- local temp = attr.value * 100
				factor = factor + attr.value * 100
				-- if tag then
				-- 	print("fight contribute", temp)
				-- end
			end
		end
	end
	-- if tag then
	-- 	print("end----------------------------------------------")
	-- end

	return factor
end

TankBO = {}

function socket_error_526_callback(code)
	Loading.getInstance():show()
	TankBO.asynGetTank(function() Loading.getInstance():unshow() end)
end

function TankBO.updateForm(data)
	-- gdump(data, "GetForm 111")

	TankMO.formation_ = {}
	for index = 1, FORMATION_MAX_NUM do  -- 阵型
		TankMO.formation_[index] = TankMO.getEmptyFormation()
	end

	if not data then return end

	local forms = PbProtocol.decodeArray(data["form"])
	-- gdump(forms, "GetForm")
	
	for index = 1, FORMATION_MAX_NUM do  -- 阵型
		if forms[index] then
			local formation, type = CombatBO.parseServerFormation(forms[index])
			if formation.tactics then
				formation.tactics = nil
			end
			if type and type > 0 then
				if not TankMO.formation_[type] then TankMO.formation_[type] = {} end
				TankMO.formation_[type] = formation
			end
		end
	end

	--强制给客户端本地用的阵型赋值为设置防守的阵型
	TankMO.formation_[FORMATION_FOR_COMBAT_TEMP] = TankMO.formation_[FORMATION_FOR_FIGHT]
	gdump(TankMO.formation_, "GetForm formation")
end

-- 更新设置GetTank协议获得的数据
function TankBO.update(data)
	TankMO.tanks_ = {}
	
	-- 清除所有之前的生产计划
	FactoryBO.clearAllProduct(BUILD_ID_CHARIOT_A)
	FactoryBO.clearAllProduct(BUILD_ID_CHARIOT_B)

	-- 清除所有之前的改装计划
	FactoryBO.clearAllProduct(BUILD_ID_REFIT)

	if not data then return end

	local tanks = PbProtocol.decodeArray(data["tank"])
	-- gdump(tanks, "[TankBO] update tanks")
	for index = 1, #tanks do  -- 设置tank的数量
		local data = tanks[index]
		TankMO.tanks_[data.tankId] = data
	end

	for index = 1, 2 do  -- 两个战车工厂
		local name = ""
		buildingId = 0

		if index == 1 then
			name = "queue_1"
			buildingId = BUILD_ID_CHARIOT_A
		elseif index == 2 then
			name = "queue_2"
			buildingId = BUILD_ID_CHARIOT_B
		end

		if data[name] then
			local que = PbProtocol.decodeArray(data[name])
			for index = 1, #que do
				TankBO.updateQueue(buildingId, que[index])
			end
		end
	end

	-- 改装工厂队列
	local que = PbProtocol.decodeArray(data["refit"])
	for index = 1, #que do
		TankBO.updateRefitQueue(BUILD_ID_REFIT, que[index])
	end

	TankMO.dirtyTankData_ = false
	
	Notify.notify(LOCAL_TANK_EVENT)
	Notify.notify(LOCAL_TANK_REPAIR_EVENT)
end

function TankBO.updateQueue(buildingId, queue)
	gdump(queue, "[TankBO] update queue, buildingId:" .. buildingId)

	if queue.state == QUEUE_STATE_PRODUCTING then  -- 队列正在生产
		-- 保证比服务器端时间延后
		local endTime = queue.endTime + 0.99

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = TankBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, tankId = queue.tankId, count = queue.count, period = queue.period})
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	elseif queue.state == QUEUE_STATE_WAIT then  -- 等待队列
		local schedulerId = SchedulerSet.add(queue.period + ManagerTimer.getTime(), {doneCallback = TankBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, tankId = queue.tankId, count = queue.count, period = queue.period}, SchedulerSet.STATE_WAIT)
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	end
end

function TankBO.updateRefitQueue(buildingId, queue)
	gdump(queue, "[TankBO] update refit queue")

	if queue.state == QUEUE_STATE_PRODUCTING then  -- 队列正在生产
		-- 保证比服务器端时间延后
		local endTime = queue.endTime + 0.99

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = TankBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, tankId = queue.tankId, refitId = queue.refitId, count = queue.count, period = queue.period})
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	elseif queue.state == QUEUE_STATE_WAIT then  -- 等待队列
		local schedulerId = SchedulerSet.add(queue.period + ManagerTimer.getTime(), {doneCallback = TankBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, tankId = queue.tankId, refitId = queue.refitId, count = queue.count, period = queue.period}, SchedulerSet.STATE_WAIT)
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	end
end

function TankBO.onProductDone(schedulerId, set)
	-- dump(set, "XXXXXXXXXXX")
	local keyId = set.keyId
	local buildingId = set.buildingId

	gprint("[TankBO] onProductDone over:", buildingId, schedulerId)

	local function updateTank()
		local find = false
		local products = FactoryBO.orderProduct(buildingId)
		for index = 1, #products do
			local set = SchedulerSet.getSetById(products[index])
			if set and set.keyId == keyId then  -- 如果找到了，则说明坦克还没有生产结束
				find = true
			end
		end

		if not find then
			local buildingId = set.buildingId
			local tankId = set.tankId
			local count = set.count

			ManagerSound.playSound("tank_create_done")

			-- local tankDB = TankMO.queryTankById(tankId)
			if buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then
				-- 显示获得
				UiUtil.showAwards({awards = {{kind = ITEM_KIND_TANK, id = tankId, count = count}}})

			-- 	Toast.show("成功生产了" .. count .. "辆" .. tankDB.name)
				--任务计数
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_TANK,type = 1,tankId = tankId,count = count})
			elseif buildingId == BUILD_ID_REFIT then
			-- 	Toast.show("成功改装了" .. count .. "辆" .. tankDB.name)
			
				local tank = TankMO.queryTankById(tankId)
				UiUtil.showAwards({awards = {{kind = ITEM_KIND_TANK, id = tank.refitId, count = count}}})
				-- local refitTank = TankMO.queryTankById(tank.refitId) -- 改装到的坦克

			end

			Notify.notify(LOCAL_TANK_DONE_EVENT)
		end
	end

	scheduler.performWithDelayGlobal(function() TankBO.asynGetTank(updateTank) end, 1.01)
end

-- 根据上阵的阵型formation中的数量，以及当前拥有的坦克数据，确定阵型的坦克是否足够
-- 同时也需要根据当前带兵量来确定阵型的tank是否多了。
-- 如果可以满足阵型的数量，则返回true，并返回当前formation的拷贝
-- 如果不能满足，则返回false，并返回最多可以达到的坦克条件的阵型
function TankBO.checkFormation(formation,kind)
	local retFormation = TankMO.getEmptyFormation()
	local ownTanks = {}

	local ok = true

	for index = 1, FIGHT_FORMATION_POS_NUM do
		local data = formation[index]
		if data.count > 0 then -- 位置上有坦克要出阵
			if not ownTanks[data.tankId] then
				if kind and kind >= ARMY_SETTING_FOR_EXERCISE1 then
					local t = ExerciseBO.getFightTank(kind,1)[data.tankId]
					ownTanks[data.tankId] = t and t.count or 0
				elseif kind and kind >= ARMY_SETTING_FOR_CROSS then
					local t = CrossBO.getFightTank(kind,1)[data.tankId]
					ownTanks[data.tankId] = t and t.count or 0
				else
					ownTanks[data.tankId] = UserMO.getResource(ITEM_KIND_TANK, data.tankId)
				end
			end
			if ownTanks[data.tankId] > 0 then
				if data.count > ownTanks[data.tankId] then -- 坦克的数量不足
					ok = false -- 修改 单个位置没有满足 依然保留阵形
					retFormation[index] = {tankId = data.tankId, count = ownTanks[data.tankId]}

					ownTanks[data.tankId] = 0
				else
					retFormation[index] = {tankId = data.tankId, count = data.count}

					ownTanks[data.tankId] = ownTanks[data.tankId] - data.count
				end
			else
				ok = false
			end
		end
	end
	if formation.awakenHero and formation.awakenHero.keyId > 0 and formation.commander > 0 then
		local hero = HeroBO.getAwakeHeroByKeyId(formation.awakenHero.keyId)
		if hero and UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then  -- 这个觉醒将可出战
			retFormation.awakenHero = formation.awakenHero
			retFormation.commander = formation.awakenHero.heroId
		end
	else
		local hero = HeroMO.getHeroById(formation.commander)
		if hero and UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_SCHOOL) and HeroBO.canHeroFight(formation.commander) == true then  -- 有这个英雄，并且军师学堂开启
			retFormation.commander = formation.commander
		end
	end

	-- local takeCount
	-- if retFormation.awakenHero and retFormation.awakenHero.keyId > 0 then
	-- 	takeCount = UserBO.getTakeTank(retFormation.awakenHero.heroId) --觉醒将
	-- else
	local awakeHeroKeyId = nil
	if table.isexist(retFormation,"awakenHero") then awakeHeroKeyId = retFormation.awakenHero.keyId end
	takeCount = UserBO.getTakeTank(retFormation.commander, awakeHeroKeyId) -- 普通将带兵量
	-- end
	-- UserBO.getTakeTank(retFormation.commander) -- 带兵量
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local data = retFormation[index]
		if data.tankId > 0 and data.count > 0 then
			if data.count > takeCount then  -- 当前的兵力，比最大带兵量还多，则减少坦克数量
				data.count = takeCount
			end
		end
	end

	--战术
	if formation.tacticsKeyId then
		retFormation.tacticsKeyId = formation.tacticsKeyId
	end

	return ok, retFormation
end

-- 根据上阵的阵型formation中的数量影响，获得当前可上阵的坦克数量
function TankBO.getFormationCanFightTank(formation,kind)
	-- 所有阵型中所有已经上阵的坦克总数量
	local function getFightedTank()
		local ret = {}
		for index = 1, FIGHT_FORMATION_POS_NUM do
			local data = formation[index]
			if data.count > 0 then
				if not ret[data.tankId] then ret[data.tankId] = {tankId = data.tankId, count = data.count}
				else ret[data.tankId].count = ret[data.tankId].count + data.count end
			end
		end
		return ret
	end

	local fighted = getFightedTank()

	local ret = {}
	local tanks = TankMO.tanks_
	--判断是否是演习上阵
	if kind and kind >= ARMY_SETTING_FOR_EXERCISE1 then
		tanks = ExerciseBO.getFightTank(kind)
	elseif kind and kind>= ARMY_SETTING_FOR_CROSS then
		tanks = CrossBO.getFightTank(kind)
	end
	for tankId, tank in pairs(tanks) do
		if fighted[tank.tankId] then
			local leftCount = tank.count - fighted[tank.tankId].count
			if leftCount > 0 then  -- 有还可以上阵的坦克
				ret[#ret + 1] = {tankId = tank.tankId, count = leftCount}
			end
		elseif tank.count > 0 then -- 可上阵的
			ret[#ret + 1] = {tankId = tank.tankId, count = tank.count}
		end
	end
	return ret
end

-- 阵型formation是否有出阵的坦克
function TankBO.hasFightFormation(formation)
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local data = formation[index]
		if data and data.tankId > 0 and data.count > 0 then
			return true
		end
	end
	return false
end

function TankBO.getFormationLockOpenLevel(position)
	return FORMATION_LOCK_DATA[position]
end

-- 阵型的位置position是否被锁住
function TankBO.isFormationLockAtPosition(position)
	if UserMO.level_ >= FORMATION_LOCK_DATA[position] then return false
	else return true end
end

function TankBO.getMyFormationLockData()
	local ret = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		ret[index] = TankBO.isFormationLockAtPosition(index)
	end
	return ret
end

-- -- 计算指挥官的属性加成
-- local function calcHeroAttrData(heroId)
-- 	if not heroId or heroId <= 0 then return {} end

-- 	local attrValue = {}
-- 	local hero = HeroMO.queryHero(heroId)
-- 	local heroAttr = json.decode(hero.attr)
-- 	for index = 1,#heroAttr do
-- 		local attrData = AttributeBO.getAttributeData(heroAttr[index][1], heroAttr[index][2])
-- 		if not attrValue[attrData["attrName"]] then attrValue[attrData["attrName"]] = attrData
-- 		else attrValue[attrData["attrName"]].value = attrValue[attrData["attrName"]].value + attrData.value end
-- 	end
-- 	return attrValue
-- end

-- 获得计算玩家最大战斗力的tank，包括基地的、以及各个地方执行任务的tank
function TankBO.getMaxFightValueTanks()
	local tanks = clone(TankMO.tanks_)
	-- dump(tanks, "11111111")

	for _, army in pairs(ArmyMO.army_) do
		-- dump(army)
		if army.formation then -- 任务中的阵型中的tank
			local stast = TankBO.stasticsFormation(army.formation)
			-- gdump(stast)
			for tankId, count in pairs(stast.tank) do
				if not tanks[tankId] then tanks[tankId] = {tankId = tankId, count = count}
				else tanks[tankId].count = tanks[tankId].count + count end
			end
		end
	end

	if PartyBattleMO.myArmy then  -- 军团战
		local army = PartyBattleMO.myArmy
		-- gdump(PartyBattleMO.myArmy, "TankBO 1111111111111111111111111")
		-- gdump(army.formation, "TankBO 2222222222222222222222")

		if army.formation then -- 任务中的阵型中的tank
			local stast = TankBO.stasticsFormation(army.formation)
			-- gdump(stast)
			for tankId, count in pairs(stast.tank) do
				if not tanks[tankId] then tanks[tankId] = {tankId = tankId, count = count}
				else tanks[tankId].count = tanks[tankId].count + count end
			end
		end
	end

	-- dump(tanks, "2222222")
	return table.values(tanks)
end

----获取 玩家 最大战力的tank,包括基地的、以及各个地方执行任务的，和可生产的tank
function TankBO.getMaxFightValueTanksEx(heroId)
	heroId = heroId or 0
	local tanks = clone(TankMO.tanks_)
	for _, army in pairs(ArmyMO.army_) do
		if army.formation then -- 任务中的阵型中的tank
			local stast = TankBO.stasticsFormation(army.formation)
			for tankId, count in pairs(stast.tank) do
				if not tanks[tankId] then 
					tanks[tankId] = {tankId = tankId, count = count}
				else 
					tanks[tankId].count = tanks[tankId].count + count 
				end
			end
		end
	end

	if PartyBattleMO.myArmy then  -- 军团战
		local army = PartyBattleMO.myArmy
		if army.formation then -- 任务中的阵型中的tank
			local stast = TankBO.stasticsFormation(army.formation)
			for tankId, count in pairs(stast.tank) do
				if not tanks[tankId] then 
					tanks[tankId] = {tankId = tankId, count = count}
				else 
					tanks[tankId].count = tanks[tankId].count + count 
				end
			end
		end
	end

	----可生产tank，也需要计算在内
	local canBuildTankId = BuildBO.getMaxFightTankId()

	if canBuildTankId > 0 then
		local takeCount = UserBO.getTakeTank(heroId)  -- 带兵量

		if not tanks[canBuildTankId] then
			tanks[canBuildTankId] = {tankId = canBuildTankId, count = takeCount * FIGHT_FORMATION_POS_NUM}
		else
			tanks[canBuildTankId].count = math.max(takeCount * FIGHT_FORMATION_POS_NUM, tanks[canBuildTankId].count)
		end
	end

	return table.values(tanks)
end

-- 获得最大战斗力阵型
-- tanks: 不为空，则表示根据tanks的tank来计算最大战斗力；否则以当前基地中有的tank来计算
-- allHero: true表示在所有已上阵和未上阵中武将中进行计算；false表示只在未上阵武将中计算
function TankBO.getMaxFightFormation(tanks, allHero, kind, forceFightHeroNil)
	local fightHero
	if forceFightHeroNil == true then
		fightHero = nil
	else
		if type(allHero) == "table" then
			fightHero = allHero
		else
			fightHero = HeroBO.getMaxFightHero(allHero,kind)
		end
	end

	if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then fightHero = nil allHero = nil end  -- 军师学堂没有开启是，不能上阵

	local fightData = {}
	local heroAttr = {}
	if fightHero then heroAttr = HeroBO.getHeroAttrData(fightHero.heroId) end
	-- gdump(heroAttr, "TankBO.getMaxFightFormation hero attr")

	tanks = tanks or table.values(TankMO.tanks_)
	tanks = clone(tanks)

	local heroId = 0
	if fightHero then heroId = fightHero.heroId end

	local awakeHeroKeyId = nil
	if table.isexist(fightHero,"awakenHero") then awakeHeroKeyId = fightHero.awakenHero.keyId end
	local takeCount = UserBO.getTakeTank(heroId, awakeHeroKeyId)  -- 带兵量

	local partAttr = {} -- 每种类型tank的配件属性
	local skillAttr = {}
	local scienceAttr = {}
	local militaryAttr = {}
	local staffAttr = StaffBO.getStaffingAttrData()
	local medalAttr = MedalBO.getEquipAttr()

	local WeaponryAttr = {}
	local WeaponryAttr = WeaponryBO.getEquipAttr()

	local MilitaryStaffAttr = {}
	MilitaryStaffAttr = MilitaryRankBO.getEquipAttr()

	local laboratoryAttr = {}
	local tacticsAttr = TacticsMO.getMaxFightTactics() --战术加成

	local tankIndex = 1
	local tankCount = 1

	while tankIndex <= #tanks do
		local tank = tanks[tankIndex]
		if tank.tankId > 0 and tank.count > 0 and tankCount <= FIGHT_FORMATION_POS_NUM then  -- 每种坦克最多只需要六组参与计算就可以了，更多的已经没有必要计算
			local tankDB = TankMO.queryTankById(tank.tankId)

			-- 部件加成
			if not partAttr[tankDB.type] then
				partAttr[tankDB.type] = PartBO.getTankTypePartAttrData(tankDB.type)
				partAttr[tankDB.type].strengthValue = nil
			end

			-- 坦克技能加成
			if not skillAttr[tankDB.type] then
				skillAttr[tankDB.type] = SkillBO.getTankTypeSkillAttrData(tankDB.type)
			end
			if not scienceAttr[tankDB.type] then
				scienceAttr[tankDB.type] = ScienceBO.getTankTypeScienceAttrData(tankDB.type)
			end

			-- 战争兵器加成
			local WarWeaponAttr = WarWeaponBO.getEquipAttr(tankCount)
			local energyCoreAttr = EnergyCoreMO.getFightAttr(tankCount) --能源核心加成
			-- 实验室加成
			if not laboratoryAttr[tankDB.type] then
				laboratoryAttr[tankDB.type] = LaboratoryBO.getLaboratoryCommonAttr(tankDB.type, true)
			end

			-- 军工科技加成
			local militaryAttr = OrdnanceBO.getAttrOnTank(tank.tankId,true)
			local count = math.min(tank.count, takeCount) -- 最多上阵数量
			-- 保存id和载重
			local data = {}
			data.tankId = tank.tankId
			data.fight = 0
			data.count = count

			-- 计算每种坦克的最大战力
			-- data.fight = (tankDB.fight + calcAttrFightValue(tankDB, partAttr[tankDB.type]) + calcAttrFightValue(tankDB, skillAttr[tankDB.type])
			-- 			+ calcAttrFightValue(tankDB, scienceAttr[tankDB.type]) + calcAttrFightValue(tankDB, heroAttr) + calcAttrFightValue(tankDB, effectAttr)) * count
			local base = tankDB.fight
			local part = calcAttrFightValue(tankDB, partAttr[tankDB.type])
			local skill = calcAttrFightValue(tankDB, skillAttr[tankDB.type])
			local science = calcAttrFightValue(tankDB, scienceAttr[tankDB.type])
			local hero = calcAttrFightValue(tankDB, heroAttr)
			local military = calcAttrFightValue(tankDB, militaryAttr)
			local staff = calcAttrFightValue(tankDB, staffAttr)
			local medal = calcAttrFightValue(tankDB, medalAttr)
			local Weaponry = calcAttrFightValue(tankDB, WeaponryAttr)
			local MilitaryStaff = calcAttrFightValue(tankDB, MilitaryStaffAttr)
			local WarWeapon = calcAttrFightValue(tankDB, WarWeaponAttr)
			local laboratory = calcAttrFightValue(tankDB, laboratoryAttr[tankDB.type])
			local tactic = calcAttrFightValue(tankDB, tacticsAttr)
			local energyCore = calcAttrFightValue(tankDB, energyCoreAttr)

			data.fight = (base + part + skill + science + hero + military + staff + medal + Weaponry + MilitaryStaff + WarWeapon + laboratory + tactic + energyCore) * count

			fightData[#fightData + 1] = data

			-- 从当前坦克重新开始计算
			tank.count = tank.count - count

			tankCount = tankCount + 1 -- 当前坦克参与计算的次数加一
		else
			tankCount = 1
			tankIndex = tankIndex + 1
		end
	end
	-- gdump(partAttr, "TankBO.getMaxFightFormation part attr")

	-- 从高到低排序
	local function sortFight(fightA, fightB)
		-- if not fightB then return end
		if fightA.fight > fightB.fight then return true
		elseif fightA.fight == fightB.fight then
			if fightA.tankId > fightB.tankId then return true
			else return false end
		else return false end
	end

	-- 进行排序
	table.sort(fightData, sortFight)

	-- gdump(fightData, "[TankBO] getMaxFightFormation 222 aaaaaaaaaaaaaaaaaaa")
	local formatData = {}

	local total = 0
	local choseIndex = 1
	for index = 1, FIGHT_FORMATION_POS_NUM do -- 只取前面几个有效的最大的战斗力，并排序
		if TankBO.isFormationLockAtPosition(index) then
		else
			formatData[choseIndex] = fightData[choseIndex]
			if fightData[choseIndex] then
				total = total + fightData[choseIndex].fight
			end
			choseIndex = choseIndex + 1
		end
	end

	-- 计算最大无需额外计算装备加成，因为装备加成是在已经确定了阵型后再加到阵型上的
	if type(allHero) == "table" then
		return formatData,total
	else
		return TankBO.sortFormation(formatData,fightHero)
	end
	-- gdump(formation, "TankBO.getMaxFightFormation result")
end

--阵型排序
function TankBO.sortFormation(formatData,fightHero)
	local function sortFormat(fightA, fightB)
		if fightA.tankId == fightB.tankId then  -- id相同，判断数量
			if fightA.count > fightB.count then return true else return false end
		end
		local tankA = TankMO.queryTankById(fightA.tankId)
		local tankB = TankMO.queryTankById(fightB.tankId)

		if tankA.type == tankB.type then  -- 类型相同，判断id
			if tankA.tankId > tankB.tankId then return true else return false end
		end

		-- if tankA.type == TANK_TYPE_TANK then return true  -- tank优先
		-- elseif tankB.type == TANK_TYPE_TANK then return false
		-- elseif tankA.type == TANK_TYPE_ARTILLERY then return true -- 火炮
		-- elseif tankB.type == TANK_TYPE_ARTILLERY then return false
		-- elseif tankA.type == TANK_TYPE_CHARIOT then return true -- 战车
		-- elseif tankB.type == TANK_TYPE_CHARIOT then return false
		-- elseif tankA.type == TANK_TYPE_ROCKET then return true -- 火箭
		-- elseif tankB.type == TANK_TYPE_ROCKET then return false
		-- end


		if tankA.type == TANK_TYPE_ROCKET then return true -- 火箭优先
		elseif tankB.type == TANK_TYPE_ROCKET then return false
		elseif tankA.type == TANK_TYPE_CHARIOT then return true -- 战车
		elseif tankB.type == TANK_TYPE_CHARIOT then return false
		elseif tankA.type == TANK_TYPE_TANK then return true  -- tank
		elseif tankB.type == TANK_TYPE_TANK then return false
		elseif tankA.type == TANK_TYPE_ARTILLERY then return true -- 火炮
		elseif tankB.type == TANK_TYPE_ARTILLERY then return false
		end
	end

	table.sort(formatData, sortFormat) -- 将上阵的按照类型排序

	local formation = {}

	if fightHero then 
		formation.commander = fightHero.heroId
		if table.isexist(fightHero, "awakenHero") then
			formation.awakenHero = fightHero.awakenHero
		end
	end -- 最大战力中有武将上阵

	local choseIndex = 1
	for index = 1, FIGHT_FORMATION_POS_NUM do -- 只取前面几个有效的
		if TankBO.isFormationLockAtPosition(index) then
			formation[index] = {tankId = 0, count = 0}
		else
			local data = formatData[choseIndex]
			if data then
				formation[index] = {tankId = data.tankId, count = data.count}
				choseIndex = choseIndex + 1
			else
				formation[index] = {tankId = 0, count = 0}
			end
		end
	end
	return formation
end

-- 获得最大载重阵型
-- allHero:true表示在所有已上阵和未上阵中武将中进行计算；false表示只在未上阵武将中计算
function TankBO.getMaxPayloadFormation(allHero,tanks,kind,commanderLocked)
	local payloadData = {}

	local tanks = tanks or clone(table.values(TankMO.tanks_))

	local fightHero = nil
	if commanderLocked and type(allHero) == "table" then
		fightHero = allHero
	else
		fightHero = HeroBO.getMaxFightHeroNew(allHero,kind)
	end

	if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then fightHero = nil end  -- 军师学堂没有开启是，不能上阵

	local heroId = 0
	if fightHero then heroId = fightHero.heroId end

	local awakeHeroKeyId = nil
	if table.isexist(fightHero,"awakenHero") then awakeHeroKeyId = fightHero.awakenHero.keyId end
	local takeCount = UserBO.getTakeTank(heroId, awakeHeroKeyId)  -- 带兵量

	local _payloadratio = PartyMO.getSciencePayloadAdd()
	local heroratio = 0
	if awakeHeroKeyId ~= nil then
		heroratio = HeroMO.HeroForTankPayloadAdd(awakeHeroKeyId)
	end

	local tankIndex = 1
	while tankIndex <= #tanks do
		local tank = tanks[tankIndex]
		if tank.tankId > 0 and tank.count > 0 then
			local tankDB = TankMO.queryTankById(tank.tankId)
			local labvalue = LaboratoryBO.getPayloadTypeAttr(tankDB.type) --作战实验室影响载重
			
			local count = math.min(tank.count, takeCount)
			local _payload = tankDB.payload * (1 + labvalue * 0.01 + _payloadratio + heroratio)		-- 计算每种坦克的最大载重
			local payload = count * _payload  
			-- 保存id和载重
			local data = {}
			data.tankId = tank.tankId
			data.payload = payload
			data.count = count

			payloadData[#payloadData + 1] = data

			-- data.weight = #payloadData  -- 权重

			-- 从当前坦克重新开始计算
			tank.count = tank.count - count
		else
			tankIndex = tankIndex + 1
		end
	end

	-- 从高到低排序
	local function sortPayload(payA, payB)
		-- if not payB then return end
		if payA.payload > payB.payload then
			return true
		elseif payA.payload == payB.payload then
			if payA.tankId > payB.tankId then return true
			else return false end
		else
			return false
		end
	end

	-- 进行排序
	table.sort(payloadData, sortPayload)

	local formatData = {}

	local choseIndex = 1
	for index = 1, FIGHT_FORMATION_POS_NUM do -- 只取前面几个有效的最大的载重，并排序
		if TankBO.isFormationLockAtPosition(index) then
		else
			formatData[choseIndex] = payloadData[choseIndex]
			choseIndex = choseIndex + 1
		end
	end

	local function sortFormat(fightA, fightB)
		if fightA.tankId == fightB.tankId then  -- id相同，判断数量
			if fightA.count > fightB.count then return true else return false end
		end
		local tankA = TankMO.queryTankById(fightA.tankId)
		local tankB = TankMO.queryTankById(fightB.tankId)

		if tankA.type == tankB.type then  -- 类型相同，判断id
			if tankA.tankId > tankB.tankId then return true else return false end
		end

		if tankA.type == TANK_TYPE_TANK then return true  -- tank优先
		elseif tankB.type == TANK_TYPE_TANK then return false
		elseif tankA.type == TANK_TYPE_ARTILLERY then return true -- 火炮
		elseif tankB.type == TANK_TYPE_ARTILLERY then return false
		elseif tankA.type == TANK_TYPE_CHARIOT then return true -- 战车
		elseif tankB.type == TANK_TYPE_CHARIOT then return false
		elseif tankA.type == TANK_TYPE_ROCKET then return true -- 火箭
		elseif tankB.type == TANK_TYPE_ROCKET then return false
		end
	end

	table.sort(formatData, sortFormat) -- 将上阵的按照类型排序

	local formation = {}

	if fightHero then 
		formation.commander = fightHero.heroId
		if table.isexist(fightHero, "awakenHero") then
			formation.awakenHero = fightHero.awakenHero
		end
	end -- 最大载重中有武将上阵

	local choseIndex = 1
	for index = 1, FIGHT_FORMATION_POS_NUM do -- 只取前面几个有效的
		if TankBO.isFormationLockAtPosition(index) then
			formation[index] = {tankId = 0, count = 0}
		else
			local data = formatData[choseIndex]
			if data then
				formation[index] = {tankId = data.tankId, count = data.count}
				choseIndex = choseIndex + 1
			else
				formation[index] = {tankId = 0, count = 0}
			end
		end
	end

	return formation
end

-- 统计阵型中的坦克数量等信息
function TankBO.stasticsFormation(formation)
	local amount = 0
	local amountTheory = 0  -- 玩家自己在当前状态下理论可以达到了阵型最多出阵数量

	local awakeHeroKeyId = nil
	if table.isexist(formation,"awakenHero") then awakeHeroKeyId = formation.awakenHero.keyId end
	local tankCount = UserBO.getTakeTank(formation.commander, awakeHeroKeyId)

	local tank = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local format = formation[index]
		if format.tankId > 0 and format.count > 0 then
			amount = amount + format.count

			if not tank[format.tankId] then tank[format.tankId] = 0 end
			tank[format.tankId] = tank[format.tankId] + format.count
		end

		local isLock = TankBO.isFormationLockAtPosition(index)
		if not isLock then
			amountTheory = amountTheory + tankCount
		end
	end
	return {tank = tank, amount = amount, amountTheory = amountTheory}
end

-- 分析阵型，获得相关战力数据
function TankBO.analyseFormation(formation)
	local partAttr = {}
	local medalAttr = {}
	local skillAttr = {}
	local scienceAttr = {}
	local WeaponryAttr = {}
	local MilitaryStaffAttr = {}
	local tacticAttr = {}

	local heroAttr = HeroBO.getHeroAttrData(formation.commander)
	local staffAttr = StaffBO.getStaffingAttrData()

	-- local effectAttr = EffectBO.getBattleBaseAttrData() -- 战争基地属性

	local baseValue = 0  -- 基础战斗力
	local partValue = 0  -- 配件战力
	local medalValue = 0  -- 勋章战力
	local skillValue = 0 -- 技能战力
	local scienceValue = 0 -- 科技战力
	local heroValue    = 0 -- 武将战力
	local staffValue = 0 -- 编制战力
	local equipValue = 0 -- 装备战力
	local military = 0 -- 军工科技力
	local enerygyValue = 0 ---能晶战力
	local tacticValue = 0 --战术战力
	local energyCoreValue = 0 --能源核心战力

	local WeaponryValue = 0 --军备战斗力
	local MilitaryStaffValue = 0 --军衔战斗力

	local warweaponValue = 0 --神秘武器战斗力

	local laboratoryValue = 0 -- 作战实验室战斗力

	local payloadValue = 0 -- 载重
	local payloadratio = 0 -- 载重 系数
	payloadratio = PartyMO.getSciencePayloadAdd()
	local partyPayload = 0 --特殊4阶兵载重加成
	partyPayload = PartyMO.getSciencePayloadAddNew4()

	local partyPayloadNew = 0 --特殊大于等于5阶兵载重加成
	partyPayloadNew = PartyMO.getSciencePayloadAddNew5()

	local awakeHeroKeyId = nil
	if table.isexist(formation,"awakenHero") then awakeHeroKeyId = formation.awakenHero.keyId end
	local heroratio = 0
	if awakeHeroKeyId ~= nil then
		heroratio = HeroMO.HeroForTankPayloadAdd(awakeHeroKeyId)
	end

	medalAttr = MedalBO.getEquipAttr()
	WeaponryAttr = WeaponryBO.getEquipAttr()
	MilitaryStaffAttr = MilitaryRankBO.getEquipAttr()
	if table.isexist(formation,"tacticsKeyId") then
		tacticAttr = TacticsMO.getTacticAttr(formation)
	else
		tacticAttr = TacticsMO.getMaxFightTactics()
	end
	-- print("TankBO.analyseFormation+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local format = formation[index]
		if format.tankId > 0 and format.count > 0 then
			local tankDB = TankMO.queryTankById(format.tankId)

			if not partAttr[tankDB.type] then  -- 当前坦克类型的配件属性
				partAttr[tankDB.type] = PartBO.getTankTypePartAttrData(tankDB.type)
				partAttr[tankDB.type].strengthValue = nil
			end

			if not skillAttr[tankDB.type] then
				skillAttr[tankDB.type] = SkillBO.getTankTypeSkillAttrData(tankDB.type)
			end

			if not scienceAttr[tankDB.type] then
				scienceAttr[tankDB.type] = ScienceBO.getTankTypeScienceAttrData(tankDB.type)
			end

			-- baseValue = baseValue + tankDB.fight * format.count + calcAttrFightValue(tankDB, effectAttr) * format.count
			baseValue = baseValue + tankDB.fight * format.count
			-- local temp = tankDB.fight * format.count
			-- print("baseValue pos", index, temp)
			partValue = partValue + calcAttrFightValue(tankDB, partAttr[tankDB.type], 'part') * format.count
			-- local temp = calcAttrFightValue(tankDB, partAttr[tankDB.type]) * format.count
			-- print("partValue pos", index, temp)
			medalValue = medalValue + calcAttrFightValue(tankDB, medalAttr)* format.count
			-- local temp = calcAttrFightValue(tankDB, medalAttr)* format.count
			-- print("medalValue pos", index, temp)
			skillValue = skillValue + calcAttrFightValue(tankDB, skillAttr[tankDB.type], 'skill') * format.count
			-- local temp = calcAttrFightValue(tankDB, skillAttr[tankDB.type]) * format.count
			-- print("skillValue pos", index, temp)
			scienceValue = scienceValue + calcAttrFightValue(tankDB, scienceAttr[tankDB.type], 'scienceValue') * format.count
			-- local temp = calcAttrFightValue(tankDB, scienceAttr[tankDB.type]) * format.count
			-- print("scienceValue pos", index, temp)
			heroValue = heroValue + calcAttrFightValue(tankDB, heroAttr, 'hero') * format.count
			-- local temp = calcAttrFightValue(tankDB, heroAttr) * format.count
			-- print("heroValue pos", index, temp)
			staffValue = staffValue + calcAttrFightValue(tankDB, staffAttr, 'staff') * format.count
			-- local temp = calcAttrFightValue(tankDB, staffAttr) * format.count
			-- print("staffValue pos", index, temp)

			WeaponryValue = WeaponryValue+ calcAttrFightValue(tankDB, WeaponryAttr, 'weaponry')* format.count
			-- local temp = calcAttrFightValue(tankDB, WeaponryAttr)* format.count
			-- print("WeaponryValue pos", index, temp)
			MilitaryStaffValue = MilitaryStaffValue + calcAttrFightValue(tankDB, MilitaryStaffAttr, 'MilitaryStaff') * format.count
			-- local temp = calcAttrFightValue(tankDB, MilitaryStaffAttr) * format.count
			-- print("MilitaryStaffValue pos", index, temp)
			tacticValue = tacticValue+ calcAttrFightValue(tankDB, tacticAttr, 'tactic')* format.count

			local equipAttr = EquipBO.getFormationEquipAttrData(index)
			equipValue = equipValue + calcAttrFightValue(tankDB, equipAttr, 'equip') * format.count

			local energyAttr = EnergySparBO.getFormationEnergyAttrData(index)
			enerygyValue = enerygyValue + calcAttrFightValue(tankDB, energyAttr, 'energy') * format.count

			local militaryAttr = OrdnanceBO.getAttrOnTank(format.tankId,true)
			military = military + calcAttrFightValue(tankDB, militaryAttr, 'military') * format.count

			local WarWeaponAttr = WarWeaponBO.getEquipAttr(index)
			warweaponValue = warweaponValue + calcAttrFightValue(tankDB, WarWeaponAttr, 'warweapon') * format.count

			local energyCoreAttr = EnergyCoreMO.getFightAttr(index)
			energyCoreValue = energyCoreValue + calcAttrFightValue(tankDB, energyCoreAttr, 'energyCore')* format.count

			local laboratoryAttr = LaboratoryBO.getLaboratoryCommonAttr(tankDB.type, true)
			laboratoryValue = laboratoryValue + calcAttrFightValue(tankDB, laboratoryAttr, 'laboratory') * format.count

			local labAttrValue = LaboratoryBO.getPayloadTypeAttr(tankDB.type)
			-- payloadValue = payloadValue + math.floor(tankDB.payload * (1 + labAttrValue * 0.01 + payloadratio + heroratio) * format.count)  -- 载重
			if tankDB.grade == 4 then
				payloadValue = payloadValue + math.floor(tankDB.payload * (1 + labAttrValue * 0.01 + payloadratio + heroratio + partyPayload) * format.count)  -- 载重
			elseif tankDB.grade >= 5 then
				payloadValue = payloadValue + math.floor(tankDB.payload * (1 + labAttrValue * 0.01 + payloadratio + heroratio + partyPayloadNew) * format.count)  -- 载重
			else
				payloadValue = payloadValue + math.floor(tankDB.payload * (1 + labAttrValue * 0.01 + payloadratio + heroratio) * format.count)  -- 载重
			end

			-- payloadValue = payloadValue + tankDB.payload * format.count -- 载重
		end
	end
	-- print("TankBO.analyseFormation-------------------------------------------------------------")

	baseValue = math.floor(baseValue)
	partValue = math.floor(partValue)
	medalValue = math.floor(medalValue)
	equipValue = math.floor(equipValue)
	heroValue = math.floor(heroValue)
	staffValue = math.floor(staffValue)
	military = math.floor(military)
	enerygyValue = math.floor(enerygyValue)

	WeaponryValue = math.floor(WeaponryValue)
	MilitaryStaffValue = math.floor(MilitaryStaffValue)

	scienceValue = math.floor(scienceValue)
	skillValue = math.floor(skillValue)

	warweaponValue = math.floor(warweaponValue)

	laboratoryValue = math.floor(laboratoryValue)
	tacticValue = math.floor(tacticValue)
	energyCoreValue = math.floor(energyCoreValue)
	-- print("baseValue!!", baseValue)
	-- print("partValue!!", partValue)
	-- print("medalValue!!", medalValue)
	-- print("equipValue!!", equipValue)
	-- print("heroValue!!", heroValue)
	-- print("staffValue!!", staffValue)
	-- print("military!!", military)
	-- print("enerygyValue!!", enerygyValue)
	-- print("WeaponryValue!!", WeaponryValue)
	-- print("MilitaryStaffValue!!", MilitaryStaffValue)
	-- print("scienceValue!!", scienceValue)
	-- print("skillValue!!", skillValue)
	-- print("warweaponValue!!", warweaponValue)
	-- print("laboratoryValue!!", laboratoryValue)

	-- 最终总战力
	local totalValue = baseValue + partValue + skillValue + heroValue + staffValue + equipValue + military + enerygyValue + medalValue + WeaponryValue + MilitaryStaffValue + scienceValue + warweaponValue + laboratoryValue + tacticValue + energyCoreValue

	return {total = totalValue, base = baseValue, part = partValue, skill = skillValue, hero = heroValue, staff = staffValue, equip = equipValue, science = scienceValue,
	 military = military, medal = medalValue,weaponry = WeaponryValue , militarystaff = MilitaryStaffValue, payload = payloadValue, energyspar = enerygyValue, warweaponValue = warweaponValue, laboratoryValue = laboratoryValue, tactic = tacticValue, energyCore =  energyCoreValue}
end

-- 修复了id为tankId的坦克
function TankBO.repairTank(tankId)
	local repairCount = TankMO.getTankRepairCountById(tankId)

	if repairCount > 0 then
		UserMO.addResource(ITEM_KIND_TANK, repairCount, tankId)
		TankMO.setTankRepairCountById(tankId, 0)
	else
		gprint("[TankBO] repair tank's rest is not larger than ZERO! Error!!! id:", tankId)
	end
end

-- 获得当前tank的最大生产数量
function TankBO.getMaxProductNum(tankId)
	local tank = TankMO.queryTankById(tankId)
	if not tank then return 0 end

	local ironNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_IRON) / tank.iron)
	local oilNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_OIL) / tank.oil)
	local copperNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_COPPER) / tank.copper)
	local silicon = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_SILICON) / tank.silicon)

	local addNum = StaffMO.queryWorldByLv(StaffMO.worldLv_).limit
	local drawNum = TANK_PRODUCT_MAX_NUM + addNum
	if tank.drawing > 0 then -- 需要道具图纸
		drawNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, tank.drawing) / 1)
	end

	local bookNum = TANK_PRODUCT_MAX_NUM + addNum
	if tank.book > 0 then
		bookNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) / tank.book)
	end

	return math.min(math.min(math.min(math.min(ironNum,  math.min(oilNum, math.min(copperNum, silicon))), drawNum), bookNum), TANK_PRODUCT_MAX_NUM + addNum)
end

-- 获得当前tank的最大改装数量
function TankBO.getMaxRefitNum(tankId)
	local tank = TankMO.queryTankById(tankId)
	if not tank then return 0 end

	local refitTank = TankMO.queryTankById(tank.refitId) -- 改装到的tank数据
	if not refitTank then return 0 end

	local count = UserMO.getResource(ITEM_KIND_TANK, tankId)  -- 可以改装的数量

	local ironNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_IRON) / (refitTank.iron - tank.iron))
	local oilNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_OIL) / (refitTank.oil - tank.oil))
	local copperNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_COPPER) / (refitTank.copper - tank.copper))
	local silicon = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_SILICON) / (refitTank.silicon - tank.silicon))

	local addNum = StaffMO.queryWorldByLv(StaffMO.worldLv_).limit
	local drawNum = TANK_PRODUCT_MAX_NUM + addNum
	if refitTank.drawing > 0 then -- 被改装的tank需要道具图纸
		if tank.drawing > 0 then
			gprint("TankBO.getMaxRefitNum error!!!! drawing:", tankId)
		end
		drawNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, refitTank.drawing) / 1)
	end

	local bookNum = TANK_PRODUCT_MAX_NUM + addNum
	if refitTank.book > 0 then
		if tank.book > 0 then
			gprint("TankBO.getMaxRefitNum error!!!! book:", tankId)
		end
		bookNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) / refitTank.book)
	end

	return math.min(math.min(math.min(math.min(math.min(ironNum,  math.min(oilNum, math.min(copperNum, silicon))), drawNum), bookNum), count), TANK_PRODUCT_MAX_NUM + addNum)
end

-- 阵型formation上了一个武将，武将id为formation.commander，更新当前的阵型中的坦克数量，以达到最大带兵量的数量
function TankBO.formationOnHero(formation,kind)
	if formation.awakenHero and formation.awakenHero.keyId > 0 then
		-- if formation.commander > 0 then
			local heroId = HeroBO.getAwakeHeroByKeyId(formation.awakenHero.keyId).heroId
			local heroDB = HeroMO.queryHero(heroId)
			if heroDB.tankCount > 0 then  -- 新的武将是增加带兵量的
				local oldCount = UserBO.getTakeTank()  -- 没有指挥官的阵型带兵量
				local awakeHeroKeyId = nil
				if table.isexist(formation,"awakenHero") then awakeHeroKeyId = formation.awakenHero.keyId end
				local newCount = UserBO.getTakeTank(heroId, awakeHeroKeyId)

				for index = 1, FIGHT_FORMATION_POS_NUM do
					if formation[index].count >= oldCount then
						formation[index].count = newCount -- 将数量补齐到最大数量
					end
				end
			end
		-- end
	else
		if formation.commander > 0 then
			local heroDB = HeroMO.queryHero(formation.commander)
			if heroDB.tankCount > 0 then  -- 新的武将是增加带兵量的
				local oldCount = UserBO.getTakeTank()  -- 没有指挥官的阵型带兵量
				local newCount = UserBO.getTakeTank(formation.commander)

				for index = 1, FIGHT_FORMATION_POS_NUM do
					if formation[index].count >= oldCount then
						formation[index].count = newCount -- 将数量补齐到最大数量
					end
				end
			end
		end
	end

	local formatOk, checkFormat = TankBO.checkFormation(formation,kind)
	return checkFormat
end

function TankBO.checkFormationUnlock(oldLevel, newLevel)
	if oldLevel == newLevel then return end

	local position = 0
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local lockLevel = FORMATION_LOCK_DATA[index]
		if oldLevel < lockLevel and newLevel >= lockLevel then
			position = index
		end
	end

	if position > 0 then  -- 避免将还没有显示的动画的值TankMO.unlockPosition_清除了
		TankMO.unlockPosition_ = position
		gprint("TankBO.checkFormationUnlock !!!!!!!!!!!!:", TankMO.unlockPosition_)
	end
end

function TankBO.asynGetTank(doneCallback)

	if TankMO.delayGetTankHandler_ then
		scheduler.unscheduleGlobal(TankMO.delayGetTankHandler_)
		TankMO.delayGetTankHandler_ = nil		
	end

	local function parseTank(name, data)
		TankBO.update(data)

		UserBO.triggerFightCheck()
		if doneCallback then doneCallback() end
	end

	TankMO.dirtyTankData_ = true
	SocketWrapper.wrapSend(parseTank, NetRequest.new("GetTank"))
end

function TankBO.asynDelayGetTank(delay)

	if TankMO.delayGetTankHandler_ then
		scheduler.unscheduleGlobal(TankMO.delayGetTankHandler_)
		TankMO.delayGetTankHandler_ = nil		
	end

	TankMO.delayGetTankHandler_  = scheduler.performWithDelayGlobal(function ()
		TankMO.delayGetTankHandler_ = nil		

		local function parseTank(name, data)
			TankBO.update(data)
			UserBO.triggerFightCheck()
		end

		TankMO.dirtyTankData_ = true
		SocketWrapper.wrapSend(parseTank, NetRequest.new("GetTank"))		
	end, delay)
end

function TankBO.asynSetForm(doneCallback, fightFor, formation, clean, formname)
	local function parseSetForm(name, data)
		-- gdump(data, "[TankBO] set form")

		local form = PbProtocol.decodeRecord(data["form"])
		if form.tactics then  --把服务端用的东西。这里做特殊删除
			form.tactics = nil
		end
		local newFormation, type = CombatBO.parseServerFormation(form)
		TankMO.formation_[type] = newFormation  -- 更新阵型

		gprint("[TankBO] asynSetForm :", fightFor)
		-- gdump(TankMO.formation_, "[TankBO] asynSetForm")

		local fightValue = -1
		if table.isexist(data, "fight") then fightValue = data["fight"] end

		if fightFor == FORMATION_FOR_ARENA and fightValue > 0 then  -- 竞技场有战斗力更新
			ArenaMO.fightValue_ = fightValue
		end

		if doneCallback then doneCallback() end
	end

	-- gdump(formation, "[TankBO] asynSetForm")

	local format = CombatBO.encodeFormation(formation)
	format.type = fightFor
	if formname then
		format.formName = formname
	end

	if clean then
		format.p1 = nil
		format.p2 = nil
		format.p3 = nil
		format.p4 = nil
		format.p5 = nil
		format.p6 = nil
	end

	SocketWrapper.wrapSend(parseSetForm, NetRequest.new("SetForm", {form = format, clean = clean}))
end

-- tankId: 为0修所有
function TankBO.asynRepair(doneCallback, tankId, repairType)
	gprint("[TankBO] asynRepair: tankId:", tankId, "repairType:", repairType)
	local function parseRepair(name, data)
		gdump(data, "[TankBO] Repair")

		if repairType == 1 then -- 宝石修复
			--TK统计 资源消耗
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.cur,TKText[6],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_RESOURCE, data.cur, RESOURCE_ID_STONE)
			-- 埋点
			Statistics.postPoint(STATIS_POINT_REPAIR1)
		else  -- 金币修复
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.cur,TKText[6],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.cur)
			-- 埋点
			Statistics.postPoint(STATIS_POINT_REPAIR2)
		end

		if tankId == 0 then
			local tanks = TankMO.getNeedRepairTanks()

			for index = 1, #tanks do
				TankBO.repairTank(tanks[index].tankId)
			end
		else
			TankBO.repairTank(tankId)
		end

		UserBO.triggerFightCheck()

		Notify.notify(LOCAL_TANK_REPAIR_EVENT)

		if doneCallback then doneCallback () end
	end
	SocketWrapper.wrapSend(parseRepair, NetRequest.new("Repair", {tankId = tankId, repairType = repairType}))
end

function TankBO.asynProduct(doneCallback, buildingId, tankId, tankNum)
	local function parseProduct(name, data)
		gdump(data, "[TankBO] asynProduct")

		local res = {}
		if data.oil then 
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[7],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if data.iron then 
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[7],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if data.copper then 
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[7],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if data.silicon then 
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[7],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		UserMO.updateResources(res)

		local res = {}
		local tankDB = TankMO.queryTankById(tankId)
		if tankDB.drawing > 0 then -- 需要图纸
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = tankDB.drawing, count = tankNum}
		end
		if tankDB.book > 0 then  -- 需要技能书
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK, count = tankNum * tankDB.book}
		end
		UserMO.reduceResources(res)

		local queue = PbProtocol.decodeRecord(data["queue"])
		TankBO.updateQueue(buildingId, queue)

		Notify.notify(LOCAL_TANK_START_EVENT)

		--TK统计 坦克生产
		TKGameBO.onEvnt(TKText.eventName[1], {tankId = tankId, count = tankNum})

		if doneCallback then doneCallback() end

		NewerBO.showNewerGuide()
	end

	-- if BuildMO.getProductNum(buildingId) >= 1 then
	-- 	gprint("[TankBO] asynProduct 队列中已经在生产了!", buildingId)
	-- 	return
	-- end

	local which = 0
	if buildingId == BUILD_ID_CHARIOT_A then which = 1
	elseif buildingId == BUILD_ID_CHARIOT_B then which = 2
	end

	SocketWrapper.wrapSend(parseProduct, NetRequest.new("BuildTank", {tankId = tankId, count = tankNum, which = which}))
end

function TankBO.asynCancelProduct(doneCallback, buildingId, schedulerId)
	local function parseCancel(name, data)
		gdump(data, "TankBO.asynCancelProduct CancelProduct")

		--TK统计 取消坦克队列
		local productData = FactoryBO.getProductData(buildingId, schedulerId)
		TKGameBO.onEvnt(TKText.eventName[2], {tankId = productData.tankId, count = productData.count ,type = "del"})

		FactoryBO.removeSchdulerProduct(buildingId, schedulerId)

		local res = {}
		if data.iron then 
			TKGameBO.onGetResTk(RESOURCE_ID_IRON,data.iron,TKText[5][2],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if data.oil then 
			TKGameBO.onGetResTk(RESOURCE_ID_OIL,data.oil,TKText[5][2],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if data.copper then 
			TKGameBO.onGetResTk(RESOURCE_ID_COPPER,data.copper,TKText[5][2],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if data.silicon then 
			TKGameBO.onGetResTk(RESOURCE_ID_SILICON,data.silicon,TKText[5][2],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		local tank = TankMO.queryTankById(productData.tankId)
		if tank.drawing > 0 then -- 生产需要图纸
			local left = math.floor((1 * productData.count) / 2)
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = tank.drawing, count = UserMO.getResource(ITEM_KIND_PROP, tank.drawing) + left}
		end

		if tank.book > 0 then
			local left = math.floor((tank.book * productData.count) / 2)
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK, count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) + left}
		end

		local exAtom = PbProtocol.decodeArray(data["award"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.type, count = item.count + UserMO.getResource(item.type, item.id), id = item.id}
		end

		local delta = UserMO.updateResources(res)
		UiUtil.showAwards({awards = delta})

		scheduler.performWithDelayGlobal(function() TankBO.asynGetTank(doneCallback) end, 1.01)
	end

	local which = 0
	if buildingId == BUILD_ID_CHARIOT_A then which = 1
	elseif buildingId == BUILD_ID_CHARIOT_B then which = 2
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseCancel, NetRequest.new("CancelQue", {type = 2, keyId = set.keyId, which = which}))
	end
end

-- costType: 1消耗金币，2消耗道具
function TankBO.asynSpeedProduct(doneCallback, buildingId, schedulerId, costType, propId, propCount)
	local function parseSpeed(name, data)
		gdump(data, "[TankBO] asynSpeedProduct speed upgrade")

		local endTime = 0

		if costType == 1 then -- 金币加速
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[10][2],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
			endTime = ManagerTimer.getTime() + 0.99
		elseif costType == 2 then  -- 道具加速
			UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)
			endTime = data.endTime + 0.99
		end

		SchedulerSet.setTimeById(schedulerId, endTime)

		if doneCallback then doneCallback() end

		NewerBO.showNewerGuide()
	end

	local which = 0
	if buildingId == BUILD_ID_CHARIOT_A then which = 1
	elseif buildingId == BUILD_ID_CHARIOT_B then which = 2
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseSpeed, NetRequest.new("SpeedQue", {type = 2, keyId = set.keyId, cost = costType, which = which, propId = propId, propCount = propCount}))
	end
end

-- 改装坦克
function TankBO.asynRefit(doneCallback, tankId, count)
	local function parseRefit(name, data)
		gdump(data, "[TankBO] asynRefit refit tank")

		local res = {}
		if data.oil then 
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[12],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if data.iron then 
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[12],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if data.copper then 
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[12],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if data.silicon then 
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[12],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		local tankCount = UserMO.getResource(ITEM_KIND_TANK, tankId)
		res[#res + 1] = {kind = ITEM_KIND_TANK, count = tankCount - count, id = tankId}

		UserMO.updateResources(res)

		local res = {}
		local tankDB = TankMO.queryTankById(tankId)
		local refitTankDB = TankMO.queryTankById(tankDB.refitId)
		if refitTankDB.drawing > 0 then -- 需要图纸
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = refitTankDB.drawing, count = count}
		end
		if refitTankDB.book > 0 then  -- 需要技能书
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK, count = count * refitTankDB.book}
		end
		UserMO.reduceResources(res)

		local queue = PbProtocol.decodeRecord(data["queue"])
		TankBO.updateRefitQueue(BUILD_ID_REFIT, queue)

		Notify.notify(LOCAL_TANK_START_EVENT) -- 和tank生产公用一个事件

		--TK统计
		--消耗材料坦克
		TKGameBO.onEvnt(TKText.eventName[2], {tankId = tankId, count = count ,type = "del"})
		--获得改装后坦克
		TKGameBO.onEvnt(TKText.eventName[1], {tankId = tankDB.refitId, count = count})

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseRefit, NetRequest.new("RefitTank", {tankId = tankId, count = count}))
end

-- 取消改装
function TankBO.asynCancelRefit(doneCallback, schedulerId)
	local buildingId = BUILD_ID_REFIT

	local function parseCancel(name, data)
		local set = SchedulerSet.getSetById(schedulerId)
		if set then
			-- 返还相应的坦克
			UserMO.addResource(ITEM_KIND_TANK, set.count, set.tankId)
		end

		--TK统计 取消坦克队列
		local productData = FactoryBO.getProductData(buildingId, schedulerId)
		--还原建造坦克
		TKGameBO.onEvnt(TKText.eventName[1], {tankId = productData.tankId, count = productData.count})
		local tankDB = TankMO.queryTankById(productData.tankId)
		--还原改造坦克
		TKGameBO.onEvnt(TKText.eventName[2], {tankId = tankDB.refitId, count = productData.count,type = "del"})

		FactoryBO.removeSchdulerProduct(buildingId, schedulerId)

		local res = {}
		if data.iron then 
			TKGameBO.onGetResTk(RESOURCE_ID_IRON,data.iron,TKText[5][3],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if data.oil then 
			TKGameBO.onGetResTk(RESOURCE_ID_OIL,data.oil,TKText[5][3],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if data.copper then 
			TKGameBO.onGetResTk(RESOURCE_ID_COPPER,data.copper,TKText[5][3],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if data.silicon then 
			TKGameBO.onGetResTk(RESOURCE_ID_SILICON,data.silicon,TKText[5][3],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		local refitTank = TankMO.queryTankById(tankDB.refitId)

		if refitTank.drawing > 0 then -- 生产需要图纸
			local left = math.floor((1 * productData.count) / 2)
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = refitTank.drawing, count = UserMO.getResource(ITEM_KIND_PROP, refitTank.drawing) + left}
		end

		if refitTank.book > 0 then
			local left = math.floor((refitTank.book * productData.count) / 2)
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK, count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) + left}
		end

		local exAtom = PbProtocol.decodeArray(data["award"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.type, count = item.count + UserMO.getResource(item.type, item.id), id = item.id}
		end

		local delta = UserMO.updateResources(res)
		UiUtil.showAwards({awards = delta})

		scheduler.performWithDelayGlobal(function() TankBO.asynGetTank(doneCallback) end, 1.01)
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseCancel, NetRequest.new("CancelQue", {type = 3, keyId = set.keyId}))
	end
end

function TankBO.asynSpeedRefit(doneCallback, schedulerId, costType, propId,propCount)
	local function parseSpeed(name, data)
		gdump(data, "[TankBO] asynSpeedRefit speed refit")

		local curTime = ManagerTimer.getTime()
		local endTime = 0

		if costType == 1 then -- 金币加速
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[10][3],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
			endTime = curTime + 0.99
		elseif costType == 2 then  -- 道具加速
			UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)
			endTime = data.endTime + 0.99
		end

		SchedulerSet.setTimeById(schedulerId, endTime)

		if doneCallback then doneCallback() end
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseSpeed, NetRequest.new("SpeedQue", {type = 3, keyId = set.keyId, cost = costType, propId = propId, propCount = propCount}))
	end
end
