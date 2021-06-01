--
-- Author: gf
-- Date: 2015-09-08 11:09:07
--

LotteryBO = {}

function LotteryBO.updateLotteryEquip(data)
	LotteryMO.LotteryEquipData_ = {}

	if not data then return end

	--抽装备数据
	local lotteryEquip = PbProtocol.decodeArray(data["lotteryEquip"])
	LotteryMO.LotteryEquipData_ = lotteryEquip
	gdump(LotteryMO.LotteryEquipData_,"LotteryBO.updateLotteryEquip..LotteryEquipData_")

	for index=1,#LotteryMO.LotteryEquipData_ do
		local lotteryData = LotteryMO.LotteryEquipData_[index]
		if LotteryMO.runTickList[lotteryData.lotteryId] then
			ManagerTimer.removeTickListener(LotteryMO.runTickList[lotteryData.lotteryId])
		end
		if lotteryData.cd > 0 then
			local runTick = ManagerTimer.addTickListener(function(dt)
				if lotteryData.cd > 0 then
					lotteryData.cd = lotteryData.cd - dt
				end
				if lotteryData.cd <= 0 then
					if lotteryData.lotteryId == 1 then
						if lotteryData.freetimes < 5 then
							lotteryData.freetimes = lotteryData.freetimes + 1
							lotteryData.cd = 14400
						else
							lotteryData.cd = 0
							ManagerTimer.removeTickListener(LotteryMO.runTickList[lotteryData.lotteryId])
						end
					else
						lotteryData.cd = 0
						lotteryData.freetimes = lotteryData.freetimes + 1
						ManagerTimer.removeTickListener(LotteryMO.runTickList[lotteryData.lotteryId])
					end
					Notify.notify(LOCAL_UPDATE_EQUIP_LOTTERY_EVENT)
				end
			end)
			LotteryMO.runTickList[lotteryData.lotteryId] = runTick
		end
	end
end


function LotteryBO.getLotteryEquip(doneCallback)
	local function parseUpgrade(name, data)
		LotteryBO.updateLotteryEquip(data)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetLotteryEquip"))
end

function LotteryBO.doLotteryEquip(doneCallback,type,level)
	local function parseUpgrade(name, data)
		local doLotteryResult = data
		doLotteryResult.award = PbProtocol.decodeArray(data["award"])
		if data["displayAward"] then
			doLotteryResult.displayAward = PbProtocol.decodeArray(data["displayAward"])
		end
		-- gdump(doLotteryResult,"LotteryBO.doLotteryEquip..doLotteryResult")
		--更新数据
		local lotteryData = LotteryMO.getLotteryDataByType(level)

		if type ~= LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 and lotteryData.freetimes > 0 then 
			lotteryData.freetimes = lotteryData.freetimes - 1
		end

		if type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE or type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 then
			if type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE then
				lotteryData.purple = lotteryData.purple - 1
			end
			if type == LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 then
				lotteryData.purple = lotteryData.purple - 9
			end
			if lotteryData.purple <= 0 then lotteryData.purple = 10 + lotteryData.purple end
			lotteryData.isFirst = 1
		end

		if data.cd > 0 then
			lotteryData.cd = data.cd
			if lotteryData.cd > 0 then
				if LotteryMO.runTickList[level] then
					ManagerTimer.removeTickListener(LotteryMO.runTickList[level])
				end
				local runTick = ManagerTimer.addTickListener(function(dt)
					if lotteryData.cd > 0 then
						lotteryData.cd = lotteryData.cd - dt
					end
					if lotteryData.cd == 0 then
						ManagerTimer.removeTickListener(runTick)
						if lotteryData.freetimes < 5 then
							lotteryData.freetimes = lotteryData.freetimes + 1
							Notify.notify(LOCAL_UPDATE_EQUIP_LOTTERY_EVENT)
						end
					end
				end)
				LotteryMO.runTickList[level] = runTick
			end
		end
		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[25],TKGAME_USERES_TYPE_UPDATE)
		--更新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		--更新装备
		local ret =CombatBO.addAwards(doLotteryResult.award)
		if table.isexist(data,"stoneAdd") then
			UserMO.addResource(ITEM_KIND_RESOURCE,data.stoneAdd,RESOURCE_ID_STONE)
			table.insert(ret.awards,1,{kind = ITEM_KIND_RESOURCE,count = data.stoneAdd,id = RESOURCE_ID_STONE})
		end
		UiUtil.showAwards(ret)

		Notify.notify(LOCAL_UPDATE_EQUIP_LOTTERY_EVENT)

		if doneCallback then doneCallback(doLotteryResult) end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[27],{type = type})
		-- 埋点
		Statistics.postPoint(STATIS_LOTTERY + type)
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DoLottery",{type = type}))
end

function LotteryBO.doLotteryTreasure(doneCallback,type,need, lotteryCount)
	local function parseUpgrade(name, data)

		local doLotteryResult = data
		doLotteryResult.award = PbProtocol.decodeArray(data["award"])
		if data["displayAward"] then
			doLotteryResult.displayAward = PbProtocol.decodeArray(data["displayAward"])
		end
		-- gdump(doLotteryResult,"LotteryBO.doLotteryEquip..doLotteryResult")
		--更新数据

		local function fightChangeCb(doChangeFight)
			-- body
			LotteryMO.doLotteryTreasureChangeFightPoint = doChangeFight
		end

		local ret = CombatBO.addAwards(doLotteryResult.award, false, fightChangeCb)
		if table.isexist(data,"stoneAdd") then
			UserMO.addResource(ITEM_KIND_RESOURCE,data.stoneAdd,RESOURCE_ID_STONE)
			table.insert(ret.awards,1,{kind = ITEM_KIND_RESOURCE,count = data.stoneAdd,id = RESOURCE_ID_STONE})
		end

		-- UiUtil.showAwards(ret)

		--TK统计 获得坦克
		for index=1,#doLotteryResult.award do
			local award = doLotteryResult.award[index]
			if award.type == ITEM_KIND_TANK then
				TKGameBO.onEvnt(TKText.eventName[1], {tankId = award.id, count = award.count})
			end
		end

		-- UserBO.triggerFightCheck()
		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[26],TKGAME_USERES_TYPE_UPDATE)

		--更新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		--减少幸运币
		if need > 0 then
			UserMO.reduceResource(ITEM_KIND_PROP,need,PROP_ID_LUCKY_COIN)
		end

		if type == LotteryMO.LOTTERY_TYPE_TANBAO_1 and LotteryMO.LotteryTreasureFree_ > 0 then 
			LotteryMO.LotteryTreasureFree_ = 0 
			Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
		end
		
		if doneCallback then doneCallback(doLotteryResult, ret) end

		TKGameBO.onEvnt(TKText.eventName[28],{type = type})
		-- 埋点
		Statistics.postPoint(STATIS_LOTTERY + type)
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DoLottery",{type = type, count = lotteryCount}))
end

function LotteryBO.updateTreasureFreeTimes(data)
	if data and table.isexist(data, "singleFree") then
		LotteryMO.LotteryTreasureFree_ = data.singleFree
	end
end

function LotteryBO.getFreeTimes()
	local times = 0
	for index=1,#LotteryMO.LotteryEquipData_ do
		local data = LotteryMO.LotteryEquipData_[index]
		if data.freetimes > 0 then
			times = times + data.freetimes
		end
	end
	return times
end

function LotteryBO.GetGuideReward(rhand, index)
	local function parseUpgrade(name, data)

		--更新数据
		local awards = PbProtocol.decodeArray(data["award"])
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)

		--减少幸运币
		UserMO.updateResource(ITEM_KIND_PROP,data.count,PROP_ID_LUCKY_COIN)

		rhand(data)
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("GetGuideReward",{index = index}))
end