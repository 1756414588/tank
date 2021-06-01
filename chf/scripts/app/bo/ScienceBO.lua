--
-- Author: gf
-- Date: 2015-08-26 10:27:21
--

ScienceBO = {}

function ScienceBO.update(data)
	if not data then return end
	--科技数据
	if table.isexist(data, "science") then
		local sciences = PbProtocol.decodeArray(data["science"])
		for i=1,#sciences do
			local scienceDB = sciences[i]
			for j=1,#ScienceMO.sciences_ do
				local localscience = ScienceMO.sciences_[j]
				if scienceDB.scienceId == localscience.scienceId then
					localscience.scienceLv = scienceDB.scienceLv
				end
				if localscience.scienceId == SCIENCE_REFINE_ID_REST then
					if localscience.scienceLv >= 1 then BATTLE_REPAIR_RATE = 1 end
				end
			end
		end
	end
	
	--科技队列
	local scienceQue = PbProtocol.decodeArray(data["queue"])

	FactoryBO.clearAllProduct(BUILD_ID_SCIENCE)
	if scienceQue and #scienceQue > 0 then
		for index = 1, #scienceQue do
			ScienceBO.updateQueue(BUILD_ID_SCIENCE, scienceQue[index])
		end
	end
	gdump(sciences,"ScienceBO.update(data) .. sciences")
	gdump(scienceQue,"ScienceBO.update(data) .. scienceQue")

	ScienceMO.dirtyScienceData_ = false
end

function ScienceBO.updateQueue(buildingId, queue)
	if queue.state == QUEUE_STATE_PRODUCTING then  -- 队列正在生产
		-- 保证比服务器端时间延后
		local endTime = queue.endTime + 0.99

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = ScienceBO.onUpgradeDone, buildingId = buildingId, keyId = queue.keyId, scienceId = queue.scienceId, period = queue.period,state = queue.state})
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	elseif queue.state == QUEUE_STATE_WAIT then  -- 等待队列
		local schedulerId = SchedulerSet.add(queue.period + ManagerTimer.getTime(), {doneCallback = ScienceBO.onUpgradeDone, buildingId = buildingId, keyId = queue.keyId, scienceId = queue.scienceId, period = queue.period}, SchedulerSet.STATE_WAIT)
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	end
end

function ScienceBO.onUpgradeDone(schedulerId, set)
	local buildingId = set.buildingId

	-- gprint("[ScienceBO] 坦克生产结束了:", buildingId, schedulerId)

	local function updateScience(name, data)
		ScienceBO.update(data)
		
		local scienceId = set.scienceId
		local scienceDB = ScienceMO.queryScienceById(scienceId)
		if scienceDB then
			ManagerSound.playSound("science_skill_create")
			Toast.show(string.format(CommonText[501],ScienceMO.queryScience(scienceDB.scienceId).refineName,scienceDB.scienceLv))
			--任务计数
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_SCIENCE_UP,type = 1})

			if scienceDB.scienceId == SCIENCE_REFINE_ID_REST then
				if scienceDB.scienceLv >= 1 then BATTLE_REPAIR_RATE = 1 end
			end
		end

		UserBO.triggerFightCheck()

		Notify.notify(LOCAL_SCIENCE_DONE_EVENT)
	end

	ScienceMO.dirtyScienceData_ = true
	scheduler.performWithDelayGlobal(function() SocketWrapper.wrapSend(updateScience, NetRequest.new("GetScience")) end, 1.01)
end

function ScienceBO.getScienceAttrData(scienceId, scienceLv)
	local scienceDB = ScienceMO.queryScience(scienceId)
	-- local science = ScienceMO.queryScienceById(scienceId)

	local value = scienceDB.addtion * scienceLv

	return AttributeBO.getAttributeData(scienceDB.attributeId, value)
end

function ScienceBO.getTankTypeScienceAttrData(tankType)
	local ret = {}
	for index = 1, #ScienceMO.sciences_ do
		local scienceDB = ScienceMO.queryScience(ScienceMO.sciences_[index].scienceId)
		if scienceDB and ((scienceDB.type == 5) or (tankType == scienceDB.type)) then
			local attr = ScienceBO.getScienceAttrData(ScienceMO.sciences_[index].scienceId, ScienceMO.sciences_[index].scienceLv)
			if not ret[attr.index] then ret[attr.index] = attr
			else ret[attr.index].value = ret[attr.index].value + attr.value end
		end
	end

	-- 额外计算军团科技
	if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		for i = 1,#PartyMO.scienceData_.scienceData do
			local science = PartyMO.scienceData_.scienceData[i]
			local scienceDB = ScienceMO.queryScience(science.scienceId)
			if scienceDB and ((scienceDB.type == 5) or (tankType == scienceDB.type)) then
				local attr = ScienceBO.getScienceAttrData(science.scienceId, science.scienceLv)
				if not ret[attr.index] then ret[attr.index] = attr
				else ret[attr.index].value = ret[attr.index].value + attr.value end
			end
		end
	end
	return ret
end

function ScienceBO.asynUpgrade(doneCallback, scienceId)
	local function parseUpgrade(name, data)
		-- gdump(data, "[ScienceBO] asynUpgrade")

		local res = {}
		if table.isexist(data, "oil") then 
			TKGameBO.onUseResTk(RESOURCE_ID_OIL,data.oil,TKText[17],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			TKGameBO.onUseResTk(RESOURCE_ID_IRON,data.iron,TKText[17],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then 
			TKGameBO.onUseResTk(RESOURCE_ID_COPPER,data.copper,TKText[17],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			TKGameBO.onUseResTk(RESOURCE_ID_SILICON,data.silicon,TKText[17],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[17],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end

		UserMO.updateResources(res)

		local queue = PbProtocol.decodeRecord(data["queue"])
		-- gdump(queue,"[ScienceBO] parseUpgrade queue")
		ScienceBO.updateQueue(BUILD_ID_SCIENCE, queue)
		ScienceBO.sortScience()
		Notify.notify(LOCAL_SCIENCE_DONE_EVENT)
		if doneCallback then doneCallback() end
		-- 埋点
		Statistics.postPoint(STATIS_SCIENCE + scienceId)
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("UpgradeScience", {scienceId = scienceId}))
end

function ScienceBO.asynCancelProduct(doneCallback, schedulerId)
	local function parseCancel(name, data)
		FactoryBO.removeSchdulerProduct(BUILD_ID_SCIENCE, schedulerId)

		local res = {}
		if table.isexist(data, "oil") then 
			TKGameBO.onGetResTk(RESOURCE_ID_OIL,data.oil,TKText[5][5],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "iron") then 
			TKGameBO.onGetResTk(RESOURCE_ID_IRON,data.iron,TKText[5][5],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "copper") then
			TKGameBO.onGetResTk(RESOURCE_ID_COPPER,data.copper,TKText[5][5],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			TKGameBO.onGetResTk(RESOURCE_ID_SILICON,data.silicon,TKText[5][5],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end
		if table.isexist(data, "stone") then 
			TKGameBO.onGetResTk(RESOURCE_ID_STONE,data.stone,TKText[5][5],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end

		local exAtom = PbProtocol.decodeArray(data["award"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.type, count = item.count + UserMO.getResource(item.type, item.id), id = item.id}
		end

		UserMO.updateResources(res)


		ScienceMO.dirtyScienceData_ = true
		scheduler.performWithDelayGlobal(function()
				local function updateScience(name, data)
					ScienceBO.update(data)
					Notify.notify(LOCAL_SCIENCE_DONE_EVENT)
	            	if doneCallback then doneCallback() end
				end
				SocketWrapper.wrapSend(updateScience, NetRequest.new("GetScience"))
            end, 1.01)
	end


	local set = SchedulerSet.getSetById(schedulerId)
	-- gdump(set,"ScienceBO.asynCancelProduct")
	if set then
		SocketWrapper.wrapSend(parseCancel, NetRequest.new("CancelQue", {type = 5, keyId = set.keyId}))
	end
end

-- costType: 1消耗金币，2消耗道具
function ScienceBO.asynSpeedProduct(doneCallback, buildingId, schedulerId, costType, propId, propCount)
	local function parseSpeed(name, data)
		-- gdump(data, "[ScienceBO] asynSpeedProduct speed upgrade")

		local endTime = 0

		if costType == 1 then -- 金币加速
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[10][5],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
			endTime = ManagerTimer.getTime() + 0.99
		elseif costType == 2 then  -- 道具加速
			UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)
			endTime = data.endTime + 0.99
		end

		SchedulerSet.setTimeById(schedulerId, endTime)
		if doneCallback then doneCallback() end
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseSpeed, NetRequest.new("SpeedQue", {type = 5, keyId = set.keyId, cost = costType, propId = propId, propCount = propCount}))
	end
end

function ScienceBO.isUpgrading(scienceId)
	local m_products = FactoryBO.orderProduct(BUILD_ID_SCIENCE)
	local productData
	for index=1,#m_products do
		productData = FactoryBO.getProductData(BUILD_ID_SCIENCE, m_products[index])
		if productData and productData.scienceId == scienceId then 
			return {productData,m_products[index]} 
		end
	end
	return nil
end

function ScienceBO.getOpenLv(scienceId)
	local scienceLevel = ScienceMO.queryScienceLevel(scienceId,1)
	if scienceLevel then
		return scienceLevel.scienceLv
	else
		gdump(scienceId,"不存在的科技")
	end
	return nil
end

-- 0 未开放 1 已开放未达成条件 2 已开放已达成条件 3 等级已达上限
function ScienceBO.canUpGrade(scienceId,lv)
	local maxLv = ScienceMO.queryScienceMaxLevel(scienceId)
	if maxLv == lv - 1 then
		return 3
	end
	local data = ScienceMO.queryScienceLevel(scienceId,lv)
	local buildLevel = BuildMO.getBuildLevel(BUILD_ID_SCIENCE)
	local fameLv = UserMO.fameLevel_
	--判断是否开放
	if ScienceBO.getOpenLv(scienceId) > buildLevel then
		return 0
	end

	--判断是否打折
	local disCount = 1
	if ActivityBO.scienceIsDis(scienceId) then
		disCount = ACTIVITY_ID_SCIENCE_DIS_RES_RATE
	end

	--活动打折
	if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
		local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
		local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
		local upIds = json.decode(refitInfo.techId)
		for index=1,#upIds do
			if upIds[index] == scienceId then
				if ActivityBO.scienceIsDis(scienceId) then
					disCount = disCount + (refitInfo.resource / 100)
				else
					disCount = 1 - (refitInfo.resource / 100)
				end
			end
		end
	end

	--判断是否达成升级条件
	if (data.scienceLv and buildLevel < data.scienceLv) or (data.fameLv and fameLv < data.fameLv)
		or (data.copperCost and UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_COPPER) < data.copperCost * disCount)
		or (data.ironCost and UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_IRON) < data.ironCost * disCount)
		or (data.oilCost and UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_OIL) < data.oilCost * disCount)
		or (data.silionCost and UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_SILICON) < data.silionCost * disCount)
		or (data.goldCost and UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) < data.goldCost * disCount) then
		return 1
	end
	return 2
end

--科技排序
function ScienceBO.sortScience()
	local function isUpgrade(scienceId)
		local m_products = FactoryBO.orderProduct(BUILD_ID_SCIENCE)
		local productData
		for index=1,#m_products do
			productData = FactoryBO.getProductData(BUILD_ID_SCIENCE, m_products[index])
			if productData and productData.scienceId == scienceId then 
				return {1,productData.state}
			end
		end
		return {0,scienceId}
	end
	
	local function sortFun(a,b)
		local isUpgradeA = isUpgrade(a.scienceId)
		local isUpgradeB = isUpgrade(b.scienceId)
		if isUpgradeA[1] == isUpgradeB[1] then
			if isUpgradeA[1] == 1 then --正在升级
				return isUpgradeA[2] < isUpgradeB[2]
			else
				local cupa = ScienceBO.canUpGrade(a.scienceId,a.scienceLv + 1)
				local cupb = ScienceBO.canUpGrade(b.scienceId,b.scienceLv + 1)
				if cupa == cupb then
					if cupa == 0 then
						return ScienceBO.getOpenLv(a.scienceId) < ScienceBO.getOpenLv(b.scienceId)
					else
						return a.scienceId < b.scienceId
					end
					
				else
					return cupa > cupb
				end
			end
		else
			return isUpgradeA[1] > isUpgradeB[1]
		end
	end

	table.sort(ScienceMO.sciences_,sortFun)
end

function ScienceBO.getScienceUpNeedRes(scienceData)
	local needRes = {}
	local scinenceInfo = ScienceMO.queryScienceLevel(scienceData.scienceId, scienceData.scienceLv + 1)
	-- gdump(scinenceInfo,"scinenceInfo===")

	if scinenceInfo.scienceLv > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_BUILD,type = BUILD_ID_SCIENCE,value = scinenceInfo.scienceLv}
	end
	if scinenceInfo.fameLv > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_FAME,value = scinenceInfo.fameLv}
	end
	if scinenceInfo.goldCost > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_RESOURCE,value = scinenceInfo.goldCost, id = RESOURCE_ID_STONE}
	end
	if scinenceInfo.ironCost > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_RESOURCE, value = scinenceInfo.ironCost, id = RESOURCE_ID_IRON}
	end
	if scinenceInfo.oilCost > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_RESOURCE, value = scinenceInfo.oilCost, id = RESOURCE_ID_OIL}
	end
	if scinenceInfo.copperCost > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_RESOURCE, value = scinenceInfo.copperCost, id = RESOURCE_ID_COPPER}
	end
	if scinenceInfo.silionCost > 0 then
		needRes[#needRes + 1] = {kind = ITEM_KIND_RESOURCE, value = scinenceInfo.silionCost, id = RESOURCE_ID_SILICON}
	end

	return needRes
end

-- 获得科技对所有资源的加成
function ScienceBO.resourceAddition()
	local add = {0, 0, 0, 0, 0}

	for index = 1, #ScienceMO.sciences_ do
		local science = ScienceMO.sciences_[index]

		if science.scienceLv > 0 then
			local scienceDB =  ScienceMO.queryScience(science.scienceId)

			if scienceDB.buildId == BUILD_ID_STONE or scienceDB.buildId == BUILD_ID_SILICON or scienceDB.buildId == BUILD_ID_IRON
				or scienceDB.buildId == BUILD_ID_COPPER or scienceDB.buildId == BUILD_ID_OIL then

				local value = scienceDB.addtion * science.scienceLv / 100

				if scienceDB.buildId == BUILD_ID_STONE then add[RESOURCE_ID_STONE] = add[RESOURCE_ID_STONE] + value end
				if scienceDB.buildId == BUILD_ID_SILICON then add[RESOURCE_ID_SILICON] = add[RESOURCE_ID_SILICON] + value end
				if scienceDB.buildId == BUILD_ID_IRON then add[RESOURCE_ID_IRON] = add[RESOURCE_ID_IRON] + value end
				if scienceDB.buildId == BUILD_ID_COPPER then add[RESOURCE_ID_COPPER] = add[RESOURCE_ID_COPPER] + value end
				if scienceDB.buildId == BUILD_ID_OIL then add[RESOURCE_ID_OIL] = add[RESOURCE_ID_OIL] + value end
			end
		end
	end
	return add
end

-- 建筑升级加速的加成
function ScienceBO.buildUpAddition(buildId)
	local science = ScienceMO.queryScienceById(SCIENCE_ID_BUILD_UP_SPEED)
	if not science then return 0 end

	local scienceLv = science.scienceLv
	if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
		local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
		local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
		local upIds = json.decode(refitInfo.buildingId)
		for index=1,#upIds do
			if upIds[index] == buildId then
				scienceLv = scienceLv + refitInfo.lv
			end
		end
	end
	
	return scienceLv * science.addtion
end

-- 仓库容量加成
function ScienceBO.capacityAddition()
	local addition = 0

	for index = 1, #ScienceMO.sciences_ do
		local science = ScienceMO.sciences_[index]
		if science.capacity > 0 then
			addition = addition + science.scienceLv * science.addtion
		end
	end

	-- 额外计算军团科技
	if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		for index = 1,#PartyMO.scienceData_.scienceData do
			local science = PartyMO.scienceData_.scienceData[index]
			if science.capacity > 0 then
				addition = addition + science.scienceLv * science.addtion
			end
		end
	end
	return addition
end

function ScienceBO.speedAddition()
	local science = ScienceMO.queryScienceById(SCIENCE_ID_MARCH_SPPED)
	if not science then return 0 end
	return science.scienceLv * science.addtion
end
