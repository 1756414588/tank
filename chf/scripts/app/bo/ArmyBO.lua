
ArmyBO = {}

function socket_error_594_callback(code)
	Loading.getInstance():show()
	ArmyBO.asynGetArmy(function() Loading.getInstance():unshow() end)
end

function socket_error_600_callback(code)
	Loading.getInstance():show()
	ArmyBO.asynGetArmy(function() Loading.getInstance():unshow() end)
end

function socket_error_601_callback(code)
	Loading.getInstance():show()
	ArmyBO.asynGetArmy(function() TankBO.asynGetTank(); Loading.getInstance():unshow() end)
end

function socket_error_603_callback(code)
	Loading.getInstance():show()
	ArmyBO.asynGetArmy(function() TankBO.asynGetTank(); Loading.getInstance():unshow() end)
end

function ArmyBO.update(data)
	-- gdump(data, "ArmyBO update")
	for keyId, army in pairs(ArmyMO.army_) do
		if army.schedulerId then
			SchedulerSet.remove(army.schedulerId)
		end
	end

	ArmyMO.army_ = {}

	if not data then return end

	local armies = PbProtocol.decodeArray(data["army"])
	gdump(armies, "[ArmyBO] getArmy")
	for index = 1, #armies do
		ArmyBO.updateArmy(armies[index])
	end

	ArmyMO.dirtyArmyData_ = false

	if not ArmyMO.tickHandler_ then
		ArmyMO.tickHandler_ = ManagerTimer.addTickListener(ArmyBO.onTick)
	end

	Notify.notify(LOCAL_ARMY_EVENT)
end

function ArmyBO.updateArmy(army)
	if army.keyId <= 0 then
		error("ArmyBO updateArmy")
	end

	gdump(army, "[ArmyBO] updateArmy")
	-- gdump(army.grab, "[ArmyBO] updateArmy grab")

	local form = PbProtocol.decodeRecord(army["form"])
	local formation = CombatBO.parseServerFormation(form)
	-- gdump(formation, "ArmyBO.updateArmy")

	local collect = nil
	if table.isexist(army, "collect") then
		local clt = PbProtocol.decodeRecord(army["collect"])
		gdump(clt, "ArmyBO.updateArmy collect")
		collect = {load = clt.load, speed = clt.speed}
	end

	local staffingTime = 0
	if table.isexist(army, "staffingTime") then staffingTime = army["staffingTime"] + 0.99 end

	local isMilitary = false  -- 是否是军事矿区
	if table.isexist(army, "senior") then isMilitary = army["senior"] end

	local isRuins = false --是否是废墟
	if table.isexist(army, "isRuins") then isRuins = army["isRuins"] end

	local isZhujun = 0
	if table.isexist(army, "isZhuJun") then isZhujun = army.isZhuJun end --是否是驻军

	local crossMine = false
	if table.isexist(army, "crossMine") then crossMine = army["crossMine"] end --跨服军事矿区

	if army.state == ARMY_STATE_PARTYB then
		PartyBattleMO.myArmy = {keyId = army.keyId, target = army.target, state = army.state, period = army.period, formation = formation, grab = army.grab, collect = collect, isMilitary = isMilitary, staffingTime = staffingTime, isRuins = isRuins, isZhujun = isZhujun, crossMine = crossMine}
		return
	end

	local endTime = army["endTime"] + 0.99

	ArmyMO.army_[army.keyId] = {keyId = army.keyId, tar_qua = table.isexist(army, "tar_qua") and army.tar_qua, target = army.target, state = army.state, period = army.period, formation = formation, grab = army.grab, collect = collect, isMilitary = isMilitary, staffingTime = staffingTime, isRuins = isRuins, crossMine = crossMine, type = table.isexist(army, "type") and army.type or 0, isZhujun = isZhujun}

	if army.state == ARMY_STATE_COLLECT then -- 正在采集
		local schedulerId = SchedulerSet.add(endTime, {doneCallback = ArmyBO.onArmyDone, keyId = army.keyId, period = army.period, armyType = ARMY_TYPE_ARMY})
		if schedulerId then
			ArmyMO.army_[army.keyId].schedulerId = schedulerId
		end
		-- --如果采集的矿有品质，更改状态
		-- local tilePos = WorldMO.decodePosition(army.target)
		-- local mine = WorldMO.getMineAt(tilePos.x, tilePos.y)
		-- print("采集==========")
		-- if mine then  -- 是矿
		-- 	WorldBO.asynGetMp({tilePos}, true)
		-- end
	elseif army.state == ARMY_STATE_RETURN then -- 返回
		local schedulerId = SchedulerSet.add(endTime, {doneCallback = ArmyBO.onArmyDone, keyId = army.keyId, period = army.period, armyType = ARMY_TYPE_ARMY})
		if schedulerId then
			ArmyMO.army_[army.keyId].schedulerId = schedulerId
		end
	elseif army.state == ARMY_STATE_MARCH or army.state == ARMY_STATE_AID_MARCH then -- 行军中
		local schedulerId = SchedulerSet.add(endTime, {doneCallback = ArmyBO.onArmyDone, keyId = army.keyId, period = army.period, armyType = ARMY_TYPE_ARMY})
		if schedulerId then
			ArmyMO.army_[army.keyId].schedulerId = schedulerId
		end
	elseif army.state == ARMY_AIRSHIP_BEGAIN or army.state == ARMY_AIRSHIP_MARCH or army.state == ARMY_AIRSHIP_GUARD_MARCH then -- 行军中
		local schedulerId = SchedulerSet.add(endTime, {doneCallback = ArmyBO.onArmyDone, keyId = army.keyId, period = army.period, armyType = ARMY_TYPE_ARMY})
		if schedulerId then
			ArmyMO.army_[army.keyId].schedulerId = schedulerId
		end
	end
end

function ArmyBO.onTick(dt)
	-- for keyId, army in pairs(ArmyMO.army_) do
	-- 	if army.state == ARMY_STATE_COLLECT then -- 正在采集
			-- local curTime = ManagerTimer.getTime()
			-- -- print("delta:", (army.staffingTime - ManagerTimer.getTime()))
			-- if curTime >= army.staffingTime and curTime < SchedulerSet.getEndTime(army.schedulerId) then  -- 编制结算的时间到了，并且采集还没有结束
			-- 	-- print("?????:", army.staffingTime, "dt:", dt)
			-- -- army.staffingTime = army.staffingTime - dt
			-- -- if army.staffingTime <= 0 then  -- 编制结算的时间到了
			-- 	army.staffingTime = army.staffingTime + STAFFING_CYCLE_TIME

			-- 	local mineLv = 0
			-- 	if army.isMilitary then  -- 是军事矿区
			-- 		local pos = StaffMO.decodePosition(army.target)
			-- 		local mine = StaffBO.getMineAt(pos)
			-- 		mineLv = mine.lv
			-- 	else
			-- 		local pos = WorldMO.decodePosition(army.target)
			-- 		local mine = WorldBO.getMineAt(pos)
			-- 		mineLv = mine.lv
			-- 	end

			-- 	local mineLvDB = WorldMO.queryMineLvByLv(mineLv)
			-- 	local pros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_)

			-- 	local exp = mineLvDB.staffingExp * (1 + pros.staffingAdd / 100)  -- 当前结算的周期内获得的编制经验
			-- 	army.staffingExp = army.staffingExp + exp
			-- 	gprint("ArmyBO.onTick totalExp:" .. army.staffingExp, "addExp:" .. exp, "mineLv:" .. mineLv, "prosAdd:" .. pros.staffingAdd)
			-- end
	-- 	end
	-- end
end

function ArmyBO.updateInvasion(invasion)
	local endTime = invasion["endTime"] + 0.99

	local target = WorldMO.encodePosition(WorldMO.pos_.x, WorldMO.pos_.y)

	local record = {keyId = invasion.keyId, lordId = invasion.lordId, portrait = invasion.portrait, name = invasion.name, lv = invasion.lv, target = target, state = invasion.state}

	ArmyMO.invasion_[#ArmyMO.invasion_ + 1] = record

	local schedulerId = SchedulerSet.add(endTime, {doneCallback = ArmyBO.onArmyDone, keyId = record.keyId, lordId = record.lordId, armyType = ARMY_TYPE_INVASION})
	if schedulerId then
		record.schedulerId = schedulerId
	end
end

function ArmyBO.updateInvasions(data)
	for index, invasion in pairs(ArmyMO.invasion_) do
		if invasion.schedulerId then
			SchedulerSet.remove(invasion.schedulerId)
		end
	end

	ArmyMO.invasion_ = {}

	if not data then return end

	local invasions = PbProtocol.decodeArray(data["invasion"])
	gdump(invasions, "ArmyBO.updateInvasions")
	for index = 1, #invasions do
		local invasion = invasions[index]
		ArmyBO.updateInvasion(invasion)
	end
end

function ArmyBO.updateAids(data)
	ArmyMO.aid_ = {}

	if not data then return end

	local aids = PbProtocol.decodeArray(data["aid"])
	gdump(aids, "ArmyBO.updateAid aaa")
	for index = 1, #aids do
		local aid = aids[index]

		local form = PbProtocol.decodeRecord(aid["form"])
		local formation = CombatBO.parseServerFormation(form)

		local record = {keyId = aid.keyId, lordId = aid.lordId, portrait = aid.portrait, name = aid.name, lv = aid.lv, state = aid.state, formation = formation, fight = aid.fight, load = aid.load}
		ArmyMO.aid_[#ArmyMO.aid_ + 1] = record
	end

	Notify.notify(LOCAL_ARMY_EVENT)
end

function ArmyBO.parseSynInvasion(name, data)
	-- gdump("ArmyBO.parseSynInvasion SERVER!!!")
	local invasion = PbProtocol.decodeRecord(data["invasion"])
	gdump(invasion, " ArmyBO.parseSynInvasion SERVER!!! parseSynInvasion")
	ArmyBO.updateInvasion(invasion)
	
	if UiDirector.hasUiByName("HomeView") then
		Notify.notify(LOCAL_ARMY_EVENT)
	end
end

function ArmyBO.parseSynArmy(name, data)
	gdump(data, "ArmyBO.parseSynArmy SERVER !!!")
	local armyStatu = PbProtocol.decodeRecord(data["armyStatu"])
	gdump(armyStatu, "ArmyBO.parseSynArmy")

	if armyStatu.lordId == UserMO.lordId_ then  -- 我自己派驻的部队
		-- local army = ArmyMO.getArmyByKeyId(armyStatu.keyId)
		if armyStatu.state == 1 then
		elseif armyStatu.state == 2 then -- 被对方把我派驻的部队遣返了
			ArmyBO.asynGetArmy(function() TankBO.asynGetTank() end)
		else
			gprint("ArmyBO army self:", armyStatu.state)

			ArmyBO.asynGetArmy(function() TankBO.asynGetTank() end)
			UserBO.asynGetLord()
		end
	else -- 别人往我家的部队(可能是行军中，也可能是驻军中)
		local invasion = ArmyMO.getInvasion(armyStatu.keyId, armyStatu.lordId)
		gdump(invasion, "ArmyBO.parseSynArmy invasion")
		local aid = ArmyMO.getAid(armyStatu.keyId, armyStatu.lordId)
		gdump(aid, "ArmyBO.parseSynArmy aid")
		if invasion then
			if invasion.state == ARMY_STATE_MARCH then -- 别人攻打我
				if armyStatu.state == 1 then -- 别人到了
					TankBO.asynGetTank()

					SocketWrapper.wrapSend(function(name, data) UserBO.updateGetResource(data) end, NetRequest.new("GetResource"))

					UserBO.asynGetLord(function(awards) UiUtil.showAwards({awards = awards}) end)

					SchedulerSet.remove(invasion.schedulerId)
					ArmyMO.removeInvasion(armyStatu.keyId, armyStatu.lordId) -- 删除进军数据

					Notify.notify(LOCAL_ARMY_EVENT)
				elseif armyStatu.state == 4 then  -- 别人的部队发生了变化
					Loading.getInstance():show()
					ArmyBO.asynGetInvasion(function() Notify.notify(LOCAL_ARMY_EVENT) end)
					UserBO.asynGetLord(function(awards) Loading.getInstance():unshow(); UiUtil.showAwards({awards = awards}) end)
				else
					gprint("ArmyBO.parseSynArmy invasion march. Error!!! status:", armyStatu.state)
					-- error("ArmyBO.parseSynArmy invasion 111")
				end
			elseif invasion.state == ARMY_STATE_AID_MARCH then  -- 别人驻军
				SchedulerSet.remove(invasion.schedulerId)
				ArmyMO.removeInvasion(armyStatu.keyId, armyStatu.lordId) -- 删除进军数据

				if armyStatu.state == 1 then  -- 驻军到了
					ArmyBO.asynGetAid()  -- 便于获得阵型数据
				elseif armyStatu.state == 4 then -- 驻军的部队发生了变化
					ArmyBO.asynGetInvasion(function() Notify.notify(LOCAL_ARMY_EVENT) end)
					ArmyBO.asynGetAid()  -- 便于获得阵型数据(部队可能直接就到了)
				else
					gprint("ArmyBO.parseSynArmy invasion aid march. Error!!! status:", armyStatu.state)
					-- error("ArmyBO.parseSynArmy invasion 222")
				end
			else
				gprint("ArmyBO.parseSynArmy ERROR!!!! invasion state:", invasion.state)
			end
		elseif aid then
			if armyStatu.state == 1 then
				gprint("ArmyBO.parseSynArmy aid Error!!! aaaa")
			elseif armyStatu.state == 2 then -- 离开了
				ArmyMO.removeAid(armyStatu.keyId, armyStatu.lordId)
				Notify.notify(LOCAL_ARMY_EVENT)
			else
				ArmyBO.asynGetAid()  -- 重新获得驻军信息
			end
		else
			gprint("ArmyBO.parseSynArmy ERROR!!!! dddddd")
		end
	end
end

function ArmyBO.onArmyDone(schedulerId, set)
	local armyType = set.armyType
	local keyId = set.keyId
	gprint("[ArmyBO] onArmyDone army is over!!!", keyId, "armyType:", armyType)

	if armyType == ARMY_TYPE_ARMY then
		local army = ArmyMO.getArmyByKeyId(keyId)
		if not army then return end

		gdump(army, "ArmyBO.onArmyDone")

		if army.state == ARMY_STATE_MARCH or army.state == ARMY_STATE_COLLECT or army.state == ARMY_STATE_AID_MARCH then  -- 行军,采集结束
			local armyPos = WorldMO.decodePosition(army.target)
			local mapData = WorldMO.getMapDataAt(armyPos.x, armyPos.y)

			if mapData then  -- 是玩家或者矿
				WorldBO.asynGetMp({armyPos}, true)
			elseif army.state == ARMY_STATE_MARCH and WorldBO.getMineAt(cc.p(armyPos.x, armyPos.y)) then
				--保存假数据
				local mine = WorldMO.getMineAt(armyPos.x, armyPos.y)
				if not mine then
					local data = {
						mineId = 0,
						mineLv = 2,
						pos = WorldMO.encodePosition(armyPos.x, armyPos.y),
						qua = 1,
						quaExp = 0,
						scoutTime = ManagerTimer.getTime(),
					}
					WorldMO.setMineAt(armyPos.x, armyPos.y, data)
				else
					mine.scoutTime = ManagerTimer.getTime()
				end
				WorldBO.asynGetMp({armyPos}, true)
			end

			if army.state == ARMY_STATE_MARCH then -- 行军结束
				ArmyBO.asynGetArmy(function() TankBO.asynGetTank(function()
						--新版雷霆计划攻打玩家胜利后刷新提示
						if mapData and ActivityBO.isValid(ACTIVITY_ID_ATTACK_NEW) then
							ActivityBO.asynGetActivityContent(function()
									Notify.notify(LOCLA_ACTIVITY_EVENT)
								end, ACTIVITY_ID_ATTACK_NEW)
						end
					end); Loading.getInstance():unshow() end)

				if UiDirector.getTopUiName() == "ArmyView" then Loading.getInstance():show() end
			elseif army.state == ARMY_STATE_AID_MARCH then
				ArmyBO.asynGetArmy(function() Loading.getInstance():unshow() end)

				if UiDirector.getTopUiName() == "ArmyView" then Loading.getInstance():show() end
			elseif army.state == ARMY_STATE_COLLECT then -- 采集结束
				Notify.notify(LOCAL_ARMY_EVENT)
			end

			if army.state == ARMY_STATE_MARCH then -- 行军结束
				UserBO.asynGetLord(function(awards) UiUtil.showAwards({awards = awards}) end)  -- 可能有经验获得

				local function parseResource(name, data)
					local delta = UserBO.updateGetResource(data)
					-- gdump(delta, "资源变化")
					UiUtil.showAwards({awards = delta})
				end
				SocketWrapper.wrapSend(parseResource, NetRequest.new("GetResource"))

				scheduler.performWithDelayGlobal(function() PropBO.asynGetProp() end, 1)  -- 可能有道具掉落
			end
		elseif army.state == ARMY_STATE_RETURN then  -- 返回的时间到了
			-- gdump(army, "army ")
			-- gdump(army.grab, "army grab ")
			gprint("ArmyBO.onArmyDone state is ARMY_STATE_RETURN !!!!")

			ArmyBO.asynGetArmy(function() TankBO.asynGetTank(); Loading.getInstance():unshow() end)

			if UiDirector.getTopUiName() == "ArmyView" then
				Loading.getInstance():show()
			end

			-- 掠到的资源
			if army.grab then
				local function doneCallback(awards)
					local res = MailBO.parseGrab(army["grab"])
					gdump(res, "ArmyBO.onArmyDone resource ADD")

					UiUtil.showAwards({awards = res})
				end

				UserBO.asynGetResouce(doneCallback)

				if ActivityBO.isValid(ACTIVITY_ID_RESOURCE) then  -- 资源采集活动
					ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_RESOURCE)
				end
			end

			-- ArmyMO.army_[keyId] = nil -- 删除任务

			-- Notify.notify(LOCAL_ARMY_EVENT)
		end
	elseif armyType == ARMY_TYPE_INVASION then
		gprint("ArmyBO arrival invasion Error!!!!!!")
		ArmyBO.asynGetInvasion()
		ArmyBO.asynGetAid()
	elseif armyType == ARMY_TYPE_AID then  -- 驻军
		gprint("ArmyBO.onArmyDone aid Error!!!!!")
	end
end

-- 判断为heroId的武将被派出出战的数量。为0，表示没有被派出过
-- 判断为keyId的觉醒将是否被排除，> 0表示派出了。
function ArmyBO.getHeroFightNum(heroId,kind)
	local num = 0
	local armies = ArmyMO.getAllArmies()
	for index = 1, #armies do
		local army = armies[index]
		local formation = army.formation
		if formation.awakenHero and formation.awakenHero.keyId > 0 then
			if formation.awakenHero.keyId == heroId then
				num = num + 1
			end
		else
			if formation.commander == heroId then
				num = num + 1
			end
		end
	end
	--检查演习将领
	for index = FORMATION_FOR_EXERCISE1,FORMATION_FOR_EXERCISE3 do
		local formation = TankMO.getFormationByType(index)

		if formation and formation.awakenHero and formation.awakenHero.keyId > 0 then
			if formation.awakenHero.keyId == heroId then
				num = num + 1
			end
		else
			if formation and formation.commander == heroId then
				num = num + 1
			end
		end
	end
	--检查跨服战将领
	if kind == ARMY_SETTING_FOR_CROSS or kind == ARMY_SETTING_FOR_CROSS1 or kind == ARMY_SETTING_FOR_CROSS2 then
		for index = FORMATION_FOR_CROSS,FORMATION_FOR_CROSS2 do
			if kind ~= index then
				local formation = TankMO.getFormationByType(index)
				if formation and formation.awakenHero and formation.awakenHero.keyId > 0 then
					if formation.awakenHero.keyId == heroId then
						num = num + 1
					end
				else
					if formation and formation.commander == heroId then
						num = num + 1
					end
				end
			end
		end
	end

	if PartyBattleMO.myArmy and PartyBattleMO.myArmy.formation and PartyBattleMO.myArmy.formation.awakenHero then
		if PartyBattleMO.myArmy.formation.awakenHero.keyId == heroId then
			num = num + 1
		end
	else
		if PartyBattleMO.myArmy and PartyBattleMO.myArmy.formation and PartyBattleMO.myArmy.formation.commander == heroId then  -- 军团战
			num = num + 1
		end
	end
	return num
end

-- 获得所有已出战的武将列表
function ArmyBO.getFightHeros()
	local res = {}
	local armies = ArmyMO.getAllArmies()
	for index = 1, #armies do
		local army = armies[index]
		local formation = army.formation
		if formation.commander and formation.commander > 0 and not formation.awakenHero then --部队中如果有觉醒将，不参加计算
			local heroId = formation.commander
			if not res[heroId] then res[heroId] = {heroId = heroId, count = 1}
			else res[heroId].count = res[heroId].count + 1 end
		end
	end

	if PartyBattleMO.myArmy and PartyBattleMO.myArmy.formation and PartyBattleMO.myArmy.formation.commander > 0 and not PartyBattleMO.myArmy.formation.awakenHero then  -- 军团战
		local heroId = PartyBattleMO.myArmy.formation.commander
		if not res[heroId] then res[heroId] = {heroId = heroId, count = 1}
		else res[heroId].count = res[heroId].count + 1 end
	end
	return res
end

-- 比当前VIP等级更高的VIP是否可以开启更多的队列
function ArmyBO.higherVipCanOpenArmy()
	local maxVip = VipMO.queryMaxVip()

	if UserMO.vip_ >= maxVip then return nil end

	local curCount = VipBO.getArmyCount()

	for index = UserMO.vip_ + 1, maxVip do
		local count = VipMO.queryVip(index).armyCount + 1
		if curCount < count then
			return index
		end
	end
end

function ArmyBO.asynGetArmy(doneCallback)
	local function updateGetArmy(name, data)

		PartyBattleMO.myArmy = nil

		ArmyBO.update(data)
		if doneCallback then doneCallback() end
	end
	ArmyMO.dirtyArmyData_ = true
	SocketWrapper.wrapSend(updateGetArmy, NetRequest.new("GetArmy"))
end

function ArmyBO.asynSpeedArmy(doneCallback, keyId)
	local army = ArmyMO.getArmyByKeyId(keyId)

	local function parseSpeed(name, data)
		gdump(data, "[TankBO] asynSpeedProduct speed upgrade")
		--TK统计 金币消耗
		TKGameBO.onUseCoinTk(data.gold,TKText[10][6],TKGAME_USERES_TYPE_UPDATE)
		
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		local endTime = ManagerTimer.getTime() + 0.99
		SchedulerSet.setTimeById(army.schedulerId, endTime)

		if doneCallback then doneCallback() end
	end

	local set = SchedulerSet.getSetById(army.schedulerId)
	if set then
		SocketWrapper.wrapSend(parseSpeed, NetRequest.new("SpeedQue", {type = 6, keyId = keyId, cost = 1}))
	end
end

function ArmyBO.asynGetAid(doneCallback)
	local function parseGetAid(name, data)
		ArmyBO.updateAids(data)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetAid, NetRequest.new("GetAid"))	
end

function ArmyBO.asynGetInvasion(doneCallback)
	local function parseGetInvasion(name, data)
		ArmyBO.updateInvasions(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetInvasion, NetRequest.new("GetInvasion"))
end
