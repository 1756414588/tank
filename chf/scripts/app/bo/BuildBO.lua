
BuildBO = {}

function BuildBO.update(data)
	gdump(data, "[BuildBO] updateAllBuilding getBuilding")

	if not BuildMO.tickHandler_ then
		BuildMO.tickHandler_ = ManagerTimer.addTickListener(BuildBO.onTick)
	end

	-- BuildMO.lastRequestTime_ = socket.gettime()

	-- 清除所有已有的升级id
	for index = 1, #BuildMO.buildData_ do
		if BuildMO.buildData_[index].upgradeId > 0 then
			SchedulerSet.remove(BuildMO.buildData_[index].upgradeId)
			BuildMO.buildData_[index].upgradeId = 0
		end
	end

	for index = 1, #HomeBuildWildConfig do  -- 城外的建筑队列
		if BuildMO.millPos_[index] and BuildMO.millPos_[index].upgradeId > 0 then
			SchedulerSet.remove(BuildMO.millPos_[index].upgradeId)
			BuildMO.millPos_[index].upgradeId = 0
		end
	end

	BuildMO.buildLevel_ = {}
	BuildMO.millPos_ = {}

	if not data then return end

	BuildMO.autoCdTime_ = data.upBuildTime
	BuildMO.autoOpen_ = (data.onBuild ~= 0)

	BuildMO.buildLevel_[BUILD_ID_COMMAND] = data.command or 0
	BuildMO.buildLevel_[BUILD_ID_CHARIOT_A] = data.factory1 or 0
	BuildMO.buildLevel_[BUILD_ID_CHARIOT_B] = data.factory2 or 0
	BuildMO.buildLevel_[BUILD_ID_WAREHOUSE_A] = data.ware1 or 0
	BuildMO.buildLevel_[BUILD_ID_WAREHOUSE_B] = data.ware2 or 0
	BuildMO.buildLevel_[BUILD_ID_SCIENCE] = data.tech or 0
	BuildMO.buildLevel_[BUILD_ID_REFIT] = data.refit or 0
	BuildMO.buildLevel_[BUILD_ID_WORKSHOP] = data.workShop or 0
	BuildMO.buildLevel_[BUILD_ID_MATERIAL_WORKSHOP] = data.leqm or 0 --材料工坊

	local mills = PbProtocol.decodeArray(data["mill"])
	for index = 1, #mills do
		local mill = mills[index]
		if not BuildMO.millPos_[mill.pos] then BuildMO.millPos_[mill.pos] = {pos = index, buildingId = 0, level = 0, upgradeId = 0} end

		BuildMO.millPos_[mill.pos].pos = mill.pos
		BuildMO.millPos_[mill.pos].buildingId = mill.id
		BuildMO.millPos_[mill.pos].level = mill.lv
	end

	if data["queue"] then  -- 有升级队列
		local que = PbProtocol.decodeArray(data["queue"])
		for index = 1, #que do
			local unit = que[index]
			BuildBO.updateQueue(unit)
		end
	end
	Notify.notify(LOCAL_BUILD_EVENT)
end

function BuildBO.updateQueue(queue)
	if queue.buildingId <= 0 then  -- buildingId无效
		error("[BuildBO] updateQueue buildingId Error!!! id:", queue.buildingId)
	end

	gdump(queue, "[BuildBO] update queue")

	local endTime = queue.endTime + 0.99

	-- local leftTime = queue.endTime - ManagerTimer.getTime() + 0.99
	-- if leftTime > queue.period then leftTime = queue.period end
	-- if leftTime <= 0 then
	-- 	gprint("BuildBO.updateQueue ERROR!!! buildingId:", queue.buildingId)
	-- end

	if queue.pos > 0 then -- 野外
		if not BuildMO.millPos_[queue.pos] then
			BuildMO.millPos_[queue.pos] = {}
			BuildMO.millPos_[queue.pos].pos = queue.pos
			BuildMO.millPos_[queue.pos].buildingId = queue.buildingId
			BuildMO.millPos_[queue.pos].level = 0
		end

		if BuildMO.millPos_[queue.pos].upgradeId and BuildMO.millPos_[queue.pos].upgradeId > 0 then
			SchedulerSet.remove(BuildMO.millPos_[queue.pos].upgradeId)
			BuildMO.millPos_[queue.pos].upgradeId = 0
		end

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = BuildBO.onUpgradeDone, buildingId = queue.buildingId, keyId = queue.keyId, pos = queue.pos, period = queue.period})
		BuildMO.millPos_[queue.pos].upgradeId = schedulerId
	else
		if BuildMO.buildData_[queue.buildingId].upgradeId and BuildMO.buildData_[queue.buildingId].upgradeId > 0 then
			SchedulerSet.remove(BuildMO.buildData_[queue.buildingId].upgradeId)
			BuildMO.buildData_[queue.buildingId].upgradeId = 0
		end

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = BuildBO.onUpgradeDone, buildingId = queue.buildingId, keyId = queue.keyId, pos = queue.pos, period = queue.period})
		BuildMO.buildData_[queue.buildingId].upgradeId = schedulerId
	end
end

function BuildBO.parseSynBuild(name, data)
	local queue = PbProtocol.decodeRecord(data["queue"])
	local buildingId = queue.buildingId
	local build = BuildMO.queryBuildById(buildingId)
	local buildLv = 0

	if data.state == 1 then  -- 开始升级
		BuildBO.updateQueue(queue)
	elseif data.state == 2 then  -- 升级结束
		ManagerSound.playSound("build_upgrade_done")

		if queue.pos > 0 then -- 野外
			local level = BuildMO.getWildLevel(queue.pos)
			level = level + 1 -- 等级提升
			buildLv = level
			BuildMO.setBuildLevel(BUILD_TYPE_WILD, queue.pos, level)
			BuildMO.millPos_[queue.pos].upgradeId = 0  -- 队列关闭

			if level == 1 then
				Toast.show(build.name .. CommonText[373])  -- 建造成功
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD, type = buildingId})  --任务计数
			else
				Toast.show(build.name .. CommonText[585])  -- 升级成功
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD_UP, type = buildingId})  --任务计数
			end
		else
			local level = BuildMO.getBuildLevel(buildingId)
			level = level + 1
			buildLv = level
			BuildMO.setBuildLevel(BUILD_TYPE_MAIN, buildingId, level)
			BuildMO.buildData_[buildingId].upgradeId = 0

			if level == 1 then
				Toast.show(build.name .. CommonText[373]) -- 建造成功
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD, type = buildingId})  --任务计数
			else
				Toast.show(build.name .. CommonText[585])  -- 升级成功
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD_UP, type = buildingId})  --任务计数
			end
		end

		-- 最大繁荣度增加
		local posValue = build.pros
		if buildLv > 90 then
			posValue = build.pros2
		end
		UserMO.maxProsperous_ = UserMO.maxProsperous_ + posValue

		SecretaryBO.update()

		-- 繁荣度增加
		UserMO.addCycleResource(ITEM_KIND_PROSPEROUS, posValue)
	end
	Notify.notify(LOCAL_BUILD_EVENT)
end

function BuildBO.onTick(dt)
	if BuildMO.autoOpen_ then
		if BuildMO.autoCdTime_ > 0 then
			BuildMO.autoCdTime_ = BuildMO.autoCdTime_ - dt
		end
	end
end

-- 建造建造升级结束后的回调
function BuildBO.onUpgradeDone(schedulerId, set)
	-- if UiDirector.getTopUiName() == "BuildingQueueView" then
	-- end
	gprint("BuildBO.onUpgradeDone !!! pos:", set.pos, "buildingId:", set.buildingId)

	local buildingId = set.buildingId
	if set.pos > 0 then

	else
		if buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then
			UserBO.triggerStrengthCheck()
		end
	end
	-- local buildingId = set.buildingId
	-- local build = BuildMO.queryBuildById(buildingId)

	-- ManagerSound.playSound("build_upgrade_done")

	-- gdump(set, "BuildBO.onUpgradeDone, over")

	-- if set.pos > 0 then -- 城外
	-- 	local level = BuildMO.getWildLevel(set.pos)
	-- 	level = level + 1 -- 等级提升
	-- 	BuildMO.setBuildLevel(BUILD_TYPE_WILD, set.pos, level)
	-- 	-- 队列关闭
	-- 	BuildMO.millPos_[set.pos].upgradeId = 0

	-- 	if level == 1 then
	-- 		Toast.show(build.name .. CommonText[373])  -- 建造成功
	-- 		--任务计数
	-- 		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD,type = buildingId})
	-- 	else
	-- 		Toast.show(build.name .. CommonText[585])  -- 升级成功
	-- 		--任务计数
	-- 		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD_UP,type = buildingId})
	-- 	end
	-- else
	-- 	local level = BuildMO.getBuildLevel(buildingId)
	-- 	level = level + 1
	-- 	BuildMO.setBuildLevel(BUILD_TYPE_MAIN, buildingId, level)
	-- 	BuildMO.buildData_[buildingId].upgradeId = 0

	-- 	if level == 1 then
	-- 		Toast.show(build.name .. CommonText[373]) -- 建造成功
	-- 		--任务计数
	-- 		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD,type = buildingId})
	-- 	else
	-- 		Toast.show(build.name .. CommonText[585])  -- 升级成功
	-- 		--任务计数
	-- 		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_BUILD_UP,type = buildingId})
	-- 	end
	-- end

	-- -- local curTime = socket.gettime()
	-- -- if curTime - BuildMO.lastRequestTime_ > 1800 then  -- 上次拉取的时间距离当前的间隔多大，则重新拉取
	-- -- 	BuildMO.lastRequestTime_ = curTime

	-- -- 	Loading.getInstance():show()
	-- -- 	scheduler.performWithDelayGlobal(function()
	-- -- 			local function getBuilding(name, data)
	-- -- 				Loading.getInstance():unshow()
	-- -- 				BuildBO.update(data)
	-- -- 			end
	-- -- 			SocketWrapper.wrapSend(getBuilding, NetRequest.new("GetBuilding"))
	-- -- 		end, 1.01)
	-- -- end

	-- -- 最大繁荣度增加
	-- UserMO.maxProsperous_ = UserMO.maxProsperous_ + build.pros

	-- SecretaryBO.update()

	-- -- 繁荣度增加
	-- UserMO.addCycleResource(ITEM_KIND_PROSPEROUS, build.pros)

	-- Notify.notify(LOCAL_BUILD_EVENT)
end

function BuildBO.getChariotMaxLevel()
	return math.max(BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A), BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B))
end

-- 获得两个战车工厂的信息
function BuildBO.getChariotProductInfo()
	local productAs = FactoryBO.orderProduct(BUILD_ID_CHARIOT_A)
	local productBs = FactoryBO.orderProduct(BUILD_ID_CHARIOT_B)
	if #productAs <= 0  and #productBs <= 0 then  -- 都是空闲的
		return 0, 2, 0, BUILD_ID_CHARIOT_A
	else
		if #productAs > 0 and #productBs <= 0 then
			return 1, 1, productAs[1], BUILD_ID_CHARIOT_A
		elseif #productAs <= 0 and #productBs > 0 then  -- 只有一个开工
			return 1, 1, productBs[1], BUILD_ID_CHARIOT_B
		else
			local aLeftTime = FactoryBO.getProductTime(BUILD_ID_CHARIOT_A, productAs[1])
			local bLeftTime = FactoryBO.getProductTime(BUILD_ID_CHARIOT_B, productBs[1])
			local id = 0
			local buildingId = 0
			if aLeftTime < bLeftTime then
				id = productAs[1]
				buildingId = BUILD_ID_CHARIOT_A
			else
				id = productBs[1]
				buildingId = BUILD_ID_CHARIOT_B
			end

			return 2, 0, id, buildingId -- 两个都开工，有0个生产位，最先结束的队列id，队列的建筑id
		end
	end
end

function BuildBO.getOpenWildMaxNum()
	return 5
end

-- 城外的位置pos是否开启
function BuildBO.isWildOpen(pos)
	local config = HomeBuildWildConfig[pos]
	local buildLevel = BuildMO.getBuildLevel(BUILD_ID_COMMAND)
	if buildLevel < config.lv then  -- 等级不足，无法开启
		return false
	else
		return true
	end
end

-- -- 获得城外空闲的地块。如果没有则返回0
-- function BuildBO.getEmptyWildPos()
-- 	for index = 1, #HomeBuildWildConfig do
-- 		if BuildBO.isWildOpen(index) then
-- 			return index
-- 		end
-- 	end
-- 	return 0
-- end

-- 根据当前的建筑，获得资源的容量
function BuildBO.getResourceCapacity(onlyWarehouse)
	local res = {[RESOURCE_ID_IRON] = 0, [RESOURCE_ID_OIL] = 0, [RESOURCE_ID_COPPER] = 0, [RESOURCE_ID_SILICON] = 0, [RESOURCE_ID_STONE] = 0}

	if onlyWarehouse then -- 只用处理两个仓库
		local ids = {BUILD_ID_WAREHOUSE_A, BUILD_ID_WAREHOUSE_B}
		for index = 1, #ids do
			local id = ids[index]
			local level = BuildMO.getBuildLevel(id)
			if level and level > 0 then
				local buildLevel = BuildMO.queryBuildLevel(id, level)
				-- print("id:", id)
				-- dump(buildLevel)
				res[RESOURCE_ID_IRON] = res[RESOURCE_ID_IRON] + buildLevel.ironMax
				res[RESOURCE_ID_OIL] = res[RESOURCE_ID_OIL] + buildLevel.oilMax
				res[RESOURCE_ID_COPPER] = res[RESOURCE_ID_COPPER] + buildLevel.copperMax
				res[RESOURCE_ID_SILICON] = res[RESOURCE_ID_SILICON] + buildLevel.siliconMax
				res[RESOURCE_ID_STONE] = res[RESOURCE_ID_STONE] + buildLevel.stoneMax
			end
		end
	else
		-- 城内所有的建筑的容量
		for index = 1, BUILD_ID_MAX do
			local level = BuildMO.getBuildLevel(index)
			if level and level > 0 then
				local buildLevel = BuildMO.queryBuildLevel(index, level)
				if buildLevel then
					-- gdump(buildLevel, "???")
					res[RESOURCE_ID_IRON] = res[RESOURCE_ID_IRON] + buildLevel.ironMax
					res[RESOURCE_ID_OIL] = res[RESOURCE_ID_OIL] + buildLevel.oilMax
					res[RESOURCE_ID_COPPER] = res[RESOURCE_ID_COPPER] + buildLevel.copperMax
					res[RESOURCE_ID_SILICON] = res[RESOURCE_ID_SILICON] + buildLevel.siliconMax
					res[RESOURCE_ID_STONE] = res[RESOURCE_ID_STONE] + buildLevel.stoneMax
				end
			end
		end

		-- 城外建造的容量
		for index = 1, #HomeBuildWildConfig do
			if BuildMO.hasMillAtPos(index) then
				local mill = BuildMO.getMillAtPos(index)
				local buildLevel = BuildMO.queryBuildLevel(mill.buildingId, mill.level)
				if buildLevel then
					res[RESOURCE_ID_IRON] = res[RESOURCE_ID_IRON] + buildLevel.ironMax
					res[RESOURCE_ID_OIL] = res[RESOURCE_ID_OIL] + buildLevel.oilMax
					res[RESOURCE_ID_COPPER] = res[RESOURCE_ID_COPPER] + buildLevel.copperMax
					res[RESOURCE_ID_SILICON] = res[RESOURCE_ID_SILICON] + buildLevel.siliconMax
					res[RESOURCE_ID_STONE] = res[RESOURCE_ID_STONE] + buildLevel.stoneMax
				end
			end
		end
	end
	local addition = ScienceBO.capacityAddition()  -- 资源加成
	-- gprint("addition:", addition)
	for resId, _ in pairs(res) do
		res[resId] = res[resId] * (1 + addition / 100)
	end
	return res
end

-- 获得资源的产出
function BuildBO.getResourceOutput()
	local res = {[RESOURCE_ID_IRON] = 0, [RESOURCE_ID_OIL] = 0, [RESOURCE_ID_COPPER] = 0, [RESOURCE_ID_SILICON] = 0, [RESOURCE_ID_STONE] = 0}

	-- 城内所有的建筑的产量
	for index = 1, BUILD_ID_NOTICE do
		local level = BuildMO.getBuildLevel(index)
		if level and level > 0 then
			local buildLevel = BuildMO.queryBuildLevel(index, level)
			if buildLevel then
				-- gdump(buildLevel, "???")
				res[RESOURCE_ID_IRON] = res[RESOURCE_ID_IRON] + buildLevel.ironOut
				res[RESOURCE_ID_OIL] = res[RESOURCE_ID_OIL] + buildLevel.oilOut
				res[RESOURCE_ID_COPPER] = res[RESOURCE_ID_COPPER] + buildLevel.copperOut
				res[RESOURCE_ID_SILICON] = res[RESOURCE_ID_SILICON] + buildLevel.siliconOut
				res[RESOURCE_ID_STONE] = res[RESOURCE_ID_STONE] + buildLevel.stoneOut
			end
		end
	end
	local o1 = res[RESOURCE_ID_STONE]
	-- print("========1111",o1)
	-- 城外建造的产量
	for index = 1, #HomeBuildWildConfig do
		if BuildMO.hasMillAtPos(index) then
			local mill = BuildMO.getMillAtPos(index)
			local buildLevel = BuildMO.queryBuildLevel(mill.buildingId, mill.level)
			if buildLevel then
				res[RESOURCE_ID_IRON] = res[RESOURCE_ID_IRON] + buildLevel.ironOut
				res[RESOURCE_ID_OIL] = res[RESOURCE_ID_OIL] + buildLevel.oilOut
				res[RESOURCE_ID_COPPER] = res[RESOURCE_ID_COPPER] + buildLevel.copperOut
				res[RESOURCE_ID_SILICON] = res[RESOURCE_ID_SILICON] + buildLevel.siliconOut
				res[RESOURCE_ID_STONE] = res[RESOURCE_ID_STONE] + buildLevel.stoneOut
			end
		end
	end
	local o2 = res[RESOURCE_ID_STONE]
	-- print("========222",o2 - o1, o2)
	local scienceAdd = ScienceBO.resourceAddition()  -- 科技加成
	-- gdump(scienceAdd, "BuildBO.getResourceOutput()")

	for index = 1, #res do
		local effectAdd = 0

		local valid, _ = EffectBO.getResEffectValid(ITEM_KIND_RESOURCE, index)
		if valid then  -- 资源增益
			effectAdd = EFFECT_RESOURCE_ADDITION
		end

		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_RESOURCE_ALL)
		if valid then  -- 全面开采
			effectAdd = effectAdd + EFFECT_RESOURCE_ADDITION
		end

		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_PB_RESOURCE)
		if valid then  -- 军团战增益
			effectAdd = effectAdd + EFFECT_PB_RES_ADDITION
		end

		local valid, leftTime, value = FortressMO.getEffectValid()
		if valid then  -- 要塞战官职
			local t = value*0.01
			if valid == "-" then
				t = t*-1
			end
			effectAdd = effectAdd + t
		end

		--活动增益
		local valid,left = EffectMO.resourceAdd()
		if valid > 0 then
			effectAdd = effectAdd + valid/100
		end

		--老玩家回归
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_PLAYER_BACK)
		if valid then
			effectAdd = effectAdd + EFFECT_RESOURCE_ADDITION
		end

		-- 资源丰收基地
		local resAdd = 0
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_BASE_RESOURCE)
		if valid then
			resAdd = EFFECT_BASE_RES_ADDITION
		end

		-- 至尊基地特效
		local skinAdd = 0
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_SKIN_EXTREME)
		if valid then
			skinAdd = EFFECT_SKIN_EXTREME_ADDITION
		end

		-- 机械迷城基地特效
		local mechaniAdd = 0
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_SKIN_MECHANICS)
		if valid then
			skinAdd = EFFECT_SKIN_MECHAIN_ADDITION
		end

		if WorldMO.isRuin(UserMO.prosperous_, UserMO.maxProsperous_) then  -- 废墟产出减半
			res[index] = res[index] * (scienceAdd[index] + effectAdd + resAdd + skinAdd + mechaniAdd)
		else
			res[index] = res[index] * (1 + scienceAdd[index] + effectAdd + resAdd + skinAdd + mechaniAdd)
		end
	end


	return res
end

-- 建筑buildingId是否可以升级
-- 如果是城外的需要wildPos
function BuildBO.canUpgrade(buildingId, wildPos)
	local maxLevel = BuildMO.queryBuildMaxLevel(buildingId)
	local buildLv = 0
	if wildPos and wildPos > 0 then -- 城外的
		buildLv = BuildMO.getWildLevel(wildPos)
	else
		buildLv = BuildMO.getBuildLevel(buildingId)
	end

	if buildLv >= maxLevel then return false end

	local nxtBuildLevel = BuildMO.queryBuildLevel(buildingId, buildLv + 1, wildPos and wildPos > 0)

	if nxtBuildLevel.commandLv > BuildMO.getBuildLevel(BUILD_ID_COMMAND) then return false end -- 司令部等级不足

	local conditionEnough = true
	local itemKind = {RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER} -- 铁、石油、铜
	for index = 1, 3 do
		local need = 0
		local count = UserMO.getResource(ITEM_KIND_RESOURCE, itemKind[index])

		if index == 1 then need = nxtBuildLevel.ironCost -- 铁
		elseif index == 2 then need = nxtBuildLevel.oilCost
		elseif index == 3 then need = nxtBuildLevel.copperCost
		end

		if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
			local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
			local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
			local upIds = json.decode(refitInfo.buildingId)
			for index=1,#upIds do
				if upIds[index] == buildingId then
					need = math.floor(need - need * (refitInfo.resource / 100))
				end
			end
		end

		if need > count then -- 不足
			conditionEnough = false
		end
	end

	if not conditionEnough then return false end

	return true
end

function BuildBO.isUpgradeFull()
	local _, upgradeNum = BuildBO.getCanUpgradeBuild(false)
	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_BUILD_UPGRADE)
	if valid then
		if upgradeNum >= UserMO.buildCount_ + 3 then return true
		else return false end
	else
		-- 默认有两个建造位
		if upgradeNum >= UserMO.buildCount_ + 2 then return true
		else return false end
	end
end

-- 获得同一时间段内可以升级的最多建筑位
function BuildBO.getUpgradeMaxNum()
	local valid, leftTime = EffectBO.getEffectValid(EFFECT_ID_BUILD_UPGRADE)
	if valid then return UserMO.buildCount_ + 3
	else return UserMO.buildCount_ + 2 end
end

-- 获得所有可以升级的建筑
-- order:是否将结果排序
function BuildBO.getCanUpgradeBuild(order)
	local data = {}
	local upgrade = 0 -- 正在升级的数量

	-- 城内所有的建筑
	for index = 1, BUILD_ID_MAX do
		local level = BuildMO.getBuildLevel(index)
		if index ~= BUILD_ID_WORKSHOP and level and level > 0 then
			local build = BuildMO.queryBuildById(index)
			local isfull = 0
			local maxLv = BuildMO.queryBuildMaxLevel(index)
			if level >= maxLv then
				isfull = 1
			end
			if build.canUp > 0 then
				local status = BuildMO.getBuildStatus(index)
				local leftTime = 0
				if status == BUILD_STATUS_UPGRADE then
					upgrade = upgrade + 1
					leftTime = BuildMO.getUpgradeLeftTime(index)
				end

				data[#data + 1] = {pos = 0, buildingId = index, level = level, status = status, leftTime = leftTime, isFull = isfull}
			end
		end
	end

	-- 城外建造的容量
	for index = 1, #HomeBuildWildConfig do
		if BuildMO.hasMillAtPos(index) then
			local isfull = 0
			local mill = BuildMO.getMillAtPos(index)
			local maxLv = BuildMO.queryBuildMaxLevel(mill.buildingId)
			if mill.level >= maxLv then
				isfull = 1
			end
			local status = BuildMO.getWildBuildStatus(index)
			local leftTime = 0
			if status == BUILD_STATUS_UPGRADE then
				upgrade = upgrade + 1
				leftTime = BuildMO.getWildUpgradeLeftTime(index)
			end

			data[#data + 1] = {pos = index, buildingId = mill.buildingId, level = mill.level, status = status, leftTime = leftTime, isFull = isfull}
		end
	end

	if order then
		local function sortData(dataA, dataB)
			if dataA.status == BUILD_STATUS_UPGRADE and dataB.status == BUILD_STATUS_UPGRADE then
				if dataA.leftTime < dataB.leftTime then
					return true
				elseif dataA.leftTime == dataB.leftTime then
					if dataA.level < dataB.level then
						return true
					elseif dataA.level == dataB.level then
						if dataA.buildingId < dataB.buildingId then
							return true
						else
							return false
						end
					else
						return false
					end
				else
					return false
				end
			elseif dataA.status == BUILD_STATUS_UPGRADE then return true
			elseif dataB.status == BUILD_STATUS_UPGRADE then return false
			else
				if dataA.level < dataB.level then
					return true
				elseif dataA.level == dataB.level then
					if dataA.buildingId < dataB.buildingId then
						return true
					else
						return false
					end
				else
					return false
				end
			end
		end

		table.sort(data, sortData)

		table.bubble(data, function(a,b)  --冒泡排序
			return a.isFull < b.isFull
		end)
	end
	return data, upgrade
end

function BuildBO.asynGetBuilding(doneCallback)
	local function parseGetBuilding(name, data)

		BuildBO.update(data)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetBuilding, NetRequest.new("GetBuilding"))
end

-- 如果是城外的建筑，则要传递wildPos
function BuildBO.asynBuildUpgrade(doneCallback, buildingId, curBuildLv, upgradeType, wildPos)
	local nxtBuildLevel = BuildMO.queryBuildLevel(buildingId, curBuildLv + 1)

	local function parseBuild(name, data)
		-- gdump(data, "[BuildBO] asynBuildUpgrade 升级了某建筑")

		local queue = PbProtocol.decodeRecord(data["queue"])
		gdump(queue, "BuildBO.asynBuildUpgrade queue")

		BuildBO.updateQueue(queue)

		if upgradeType == 1 then -- 金币升级
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[4],TKGAME_USERES_TYPE_UPDATE)

			UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		elseif upgradeType == 2 then -- 资源升级
			local res = {}
			if table.isexist(data, "iron") then 
				TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[4],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
			end
			if table.isexist(data, "oil") then 
				TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[4],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
			end
			if table.isexist(data, "copper") then
				TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[4],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
			end
			if table.isexist(data, "silicon") then 
				TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[4],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
			end

			UserMO.updateResources(res)
		end

		Notify.notify(LOCAL_BUILD_EVENT, {buildingId = buildingId})

		if doneCallback then doneCallback() end

		NewerBO.showNewerGuide()
		-- 埋点
		Statistics.postPoint( (STATIS_BUILDING + upgradeType * 100000 + buildingId * 1000 + curBuildLv + 1) )
	end

	SocketWrapper.wrapSend(parseBuild, NetRequest.new("UpBuilding", {type = upgradeType, buildingId = buildingId, pos = wildPos}))
end

-- 异步取消建筑的升级
-- 如果是城外，则需要wildPos
function BuildBO.asynCancelUpgrade(doneCallback, buildingId, wildPos)
	if wildPos and wildPos > 0 then -- 城外建筑
		if BuildMO.getWildBuildStatus(wildPos) ~= BUILD_STATUS_UPGRADE then
			gprint("[BuildBO] asynCancelUpgrade Error 11 城外建筑")
			return
		end
	else
		if BuildMO.getBuildStatus(buildingId) ~= BUILD_STATUS_UPGRADE then
			gprint("[BuildBO] asynCancelUpgrade Error 22 建筑升级结束了")
			return
		end
	end

	gprint("BuildBO.asynCancelUpgrade:", buildingId, wildPos)

	local function parseCancelUpgrade(name, data)
		gdump(data, "[BuildBO] asynCancelUpgrade 获得数据")

		local schedulerId = 0
		if wildPos and wildPos > 0 then -- 城外建筑
			schedulerId = BuildMO.millPos_[wildPos].upgradeId
			BuildMO.millPos_[wildPos].upgradeId = 0
		else
			schedulerId = BuildMO.buildData_[buildingId].upgradeId
			BuildMO.buildData_[buildingId].upgradeId = 0
		end
		SchedulerSet.remove(schedulerId)

		local res = {}
		if table.isexist(data, "iron") then 
			TKGameBO.onGetResTk(RESOURCE_ID_IRON,data.iron,TKText[5][1],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "oil") then 
			TKGameBO.onGetResTk(RESOURCE_ID_OIL,data.oil,TKText[5][1],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "copper") then
			TKGameBO.onGetResTk(RESOURCE_ID_COPPER,data.copper,TKText[5][1],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			TKGameBO.onGetResTk(RESOURCE_ID_SILICON,data.silicon,TKText[5][1],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		local exAtom = PbProtocol.decodeArray(data["award"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.type, count = item.count + UserMO.getResource(item.type, item.id), id = item.id}
		end

		local delta = UserMO.updateResources(res)
		UiUtil.showAwards({awards = delta})  -- 显示返还的

		Notify.notify(LOCAL_BUILD_EVENT, {buildingId = buildingId})

		if doneCallback then doneCallback() end
	end

	local schedulerId = 0
	if wildPos and wildPos > 0 then -- 城外建筑
		schedulerId = BuildMO.millPos_[wildPos].upgradeId
	else
		schedulerId = BuildMO.buildData_[buildingId].upgradeId
	end
	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseCancelUpgrade, NetRequest.new("CancelQue", {type = 1, keyId = set.keyId}))
	end
end

-- costType: 1消耗金币，2消耗道具
-- wildPos: 如果是城外建筑，需要传递
function BuildBO.asynSpeedUpgrade(doneCallback, buildingId, costType, propId, wildPos, propCount)
	local propCount = propCount
	if wildPos and wildPos > 0 then
		if BuildMO.getWildBuildStatus(wildPos) ~= BUILD_STATUS_UPGRADE then
			gprint("[BuildBO] asynCancelUpgrade Error !!! 11 upgrade done")
			return
		end
	else
		if BuildMO.getBuildStatus(buildingId) ~= BUILD_STATUS_UPGRADE then
			gprint("[BuildBO] asynSpeedUpgrade Error !!! 22 upgrade done")
			return
		end
	end

	local function parseSpeedUpgrade(name, data)
		gdump(data, "[BuildBO] asynSpeedUpgrade speed upgrade")

		local endTime = 0

		if costType == 1 then -- 金币加速
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[10][1],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
			endTime = ManagerTimer.getTime() + 0.99
		elseif costType == 2 then  -- 道具加速
			UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)
			endTime = data.endTime + 0.99
		end

		local schedulerId = 0
		if wildPos and wildPos > 0 then
			schedulerId = BuildMO.millPos_[wildPos].upgradeId
		else
			schedulerId = BuildMO.buildData_[buildingId].upgradeId
		end
		SchedulerSet.setTimeById(schedulerId, endTime)

		if doneCallback then doneCallback() end
		
	end

	local schedulerId = 0
	if wildPos and wildPos > 0 then
		schedulerId = BuildMO.millPos_[wildPos].upgradeId
	else
		schedulerId = BuildMO.buildData_[buildingId].upgradeId
	end
	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseSpeedUpgrade, NetRequest.new("SpeedQue", {type = 1, keyId = set.keyId, cost = costType, propId = propId, propCount = propCount}))
	end
end

-- 拆除城外的建筑
function BuildBO.asynDestroyBuild(doneCallback, wildPos)
	local wild = BuildMO.getMillAtPos(wildPos)
	if not wild then
		error("[BuildBO] wild is nil ERROR")
	end

	if wild.upgradeId > 0 then
		error("[BuildBO] wild is nil! upgradeId ! ERROR !")
	end

	local function parseDestroyBuild(name, data)
		gdump(data, "[BuildBO] destroy build")

		BuildMO.millPos_[wildPos] = nil
		
		UserMO.maxProsperous_ = data.prosMax
		if UserMO.getResource(ITEM_KIND_PROSPEROUS) > UserMO.maxProsperous_ then
			UserMO.updateCycleResource(ITEM_KIND_PROSPEROUS, UserMO.maxProsperous_)
		end

		Notify.notify(LOCAL_PROSPEROUS_EVENT)
		Notify.notify(LOCAL_BUILD_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseDestroyBuild, NetRequest.new("DestroyMill", {pos = wildPos}))
end

function BuildBO.asynBuyAutoBuild(doneCallback)
	local function parseBuyAutoBuild(name, data)
		gdump(data, "BuildBO.asynBuyAutoBuild")

		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[55],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		BuildMO.autoCdTime_ = data.upBuildTime

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyAutoBuild, NetRequest.new("BuyAutoBuild"))
end

function BuildBO.asynSetAutoBuild(doneCallback, isOn)
	local function parseSetAutoBuild(name, data)
		gdump(data, "BuildBO.asynSetAutoBuild")

		-- UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		BuildMO.autoCdTime_ = data.upBuildTime
		BuildMO.autoOpen_ = (data.onBuild ~= 0)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseSetAutoBuild, NetRequest.new("SetAutoBuild", {state = isOn}))
end

function BuildBO.getMaxLvWildBuild(buildId)
	local param = {level = -1}
	for index = 1, #HomeBuildWildConfig do
		if BuildMO.hasMillAtPos(index) then
			local mill = BuildMO.getMillAtPos(index)
			if mill.buildingId == buildId then
				if mill.level > param.level then
					param = mill
				end
			end
		end
	end
	if param.level == -1 then return nil end
	return param
end

function BuildBO.getMaxFightTankId()
	local buildLevel = BuildBO.getChariotMaxLevel()

	local canProducts = TankMO.queryCanBuildTanks()
	local maxTankId = 0
	for i,tankDB in ipairs(canProducts) do
		if buildLevel >= tankDB.factoryLv and UserMO.level_ >= tankDB.lordLv then  -- 可以生产
			maxTankId = math.max(maxTankId, tankDB.tankId)
		end
	end

	return maxTankId
end
