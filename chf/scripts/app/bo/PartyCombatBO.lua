--
-- Author: gf
-- Date: 2015-09-18 15:33:58
-- 军团副本

PartyCombatBO = {}

function PartyCombatBO.update(data)



end


function PartyCombatBO.asynGetPartyCombat(doneCallback)

	local function parseResult(name, data)
		gdump(data, "[PartyCombatBO] GetPartyCombat")

		if table.isexist(data, "partyCombat") then
			local partyCombat = PbProtocol.decodeArray(data["partyCombat"])		
			PartyCombatMO.partyCombat_ = partyCombat
		else
			PartyCombatMO.partyCombat_ = {}
		end
		if table.isexist(data, "count") then
			PartyCombatMO.combatCount_ = data.count
		else
			PartyCombatMO.combatCount_ = 0
		end

		if table.isexist(data, "getAward") then
			PartyCombatMO.getAwardId_ = data.getAward
		else
			PartyCombatMO.getAwardId_ = {}
		end
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyCombat"))
end

function PartyCombatBO.asynPtcForm(doneCallback,combatDB)
	local function parseResult(name, data)
		if table.isexist(data, "state") then
			if data.state == 1 then --关卡已结束,重新请求
				local cb = function()
					Notify.notify(LOCAL_PARTY_COMBAT_UPDATE_EVENT)
				end
				PartyCombatBO.asynGetPartyCombat(cb)
				return
			else
				if table.isexist(data, "form") then
					combatDB.form = CombatBO.parseServerFormation(PbProtocol.decodeRecord(data["form"]))
				end
			end
		end
		
		if doneCallback then doneCallback(combatDB) end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PtcForm",{combatId = combatDB.combatId}))
end




function PartyCombatBO.asynDoPartyCombat(doneCallback,combatId,formation)
	local function parseDoCombat(name, data)
		gdump(data, "[PartyCombatBO] doCombat")

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[22], {combatId = combatId})

		

		PartyCombatMO.combatCount_ = PartyCombatMO.combatCount_ - 1

		CombatMO.curBattleStar_ = data.result

		local combatDB = PartyCombatBO.getCombatDbById(combatId)
		
		--TK统计 关卡开始
		TKGameBO.onBegin(TKText[42] .. combatId)
		if CombatMO.curBattleStar_ > 0 then -- 战斗胜利通关
			TKGameBO.onCompleted(TKText[42] .. combatId)
		else
			TKGameBO.onFailed(TKText[42] .. combatId,TKText[44])
		end

		CombatMO.curBattleCombatUpdate_ = 0

		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])
		gdump(awards, "[PartyCombatBO] drop award")

		local stastAwards = CombatBO.addAwards(awards)
		CombatMO.curBattleAward_ = stastAwards

		if CombatMO.curBattleStar_ > 0 then -- 战斗胜利通关
			CombatMO.curBattleNeedShowBalance_ = true

		else  -- 战斗失败
			CombatMO.curBattleNeedShowBalance_ = false
			CombatMO.curBattleStar_ = 0 -- 星级
		end

		if table.isexist(data, "exp") then
			-- 添加经验
			local level, exp, upgrade = UserMO.addUpgradeResouce(ITEM_KIND_EXP, data.exp)
			-- 记录当前战斗获得的经验
			stastAwards.awards[#stastAwards.awards + 1] = {kind = ITEM_KIND_EXP, count = data.exp}
			if upgrade then stastAwards.levelUp = true end
		end

		gprint("[PartyCombatBO] star:" .. CombatMO.curBattleStar_, "status:" .. CombatMO.curBattleCombatUpdate_)
		gdump(CombatMO.curBattleAward_, "PartyCombatBO award award")

		--军团建设度
		if table.isexist(data, "build") then
			--建设度增加
			PartyMO.partyData_.build = PartyMO.partyData_.build + data.build
		end

		--更新副本信息
		if table.isexist(data, "partyCombat") then
			local partyCombat = PbProtocol.decodeRecord(data["partyCombat"])
			gdump(partyCombat,"dump..partyCombat")
			PartyCombatBO.updatePartyCombat(partyCombat)
		end

		-- 解析防守的阵型
		local defFormat = combatDB.form

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"], formation, defFormat)

		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive

		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData

		local atkLost = CombatBO.parseBattleStastics(formation, defFormat, combatData)

		Notify.notify(LOCAL_PARTY_SECTION_UPDATE_EVENT)

		if doneCallback then doneCallback(data.result, formation, defFormat, combatData) end


		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_COMBAT,type = 1})
	end

	local format = CombatBO.encodeFormation(formation)

	SocketWrapper.wrapSend(parseDoCombat, NetRequest.new("DoPartyCombat",{combatId = combatId, form = format}))
end


function PartyCombatBO.asynPartyctAward(doneCallback,combatDB,need)
	local function parseResult(name, data)
		combatDB.status = 2
		table.insert(PartyCombatMO.getAwardId_,combatDB.combatId)
		PartyMO.myDonate_ = PartyMO.myDonate_ - need
		local award = PbProtocol.decodeArray(data["award"])
		
		gdump(award,"award====")
		 --加入背包
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)
		Notify.notify(LOCAL_PARTY_COMBAT_UPDATE_EVENT)
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD,type = 1})

		Notify.notify(LOCAL_PARTY_SECTION_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("PartyctAward",{combatId = combatDB.combatId}))
end


function PartyCombatBO.getSectionDB(sectionId)
	local sectionDB = PartyCombatMO.queryCombatBySection(sectionId)
	-- gdump(sectionDB,"sectionDBsectionDB"..sectionId)
	local killedCount = 0
	local awardCount = 0
	for i = 1,#sectionDB do
		local combat = sectionDB[i]
		for j = 1,#PartyCombatMO.partyCombat_ do
			local combatDb = PartyCombatMO.partyCombat_[j]
			if combat.combatId == combatDb.combatId and combatDb.schedule == 100 then
				killedCount = killedCount + 1
				if PartyCombatBO.awardIsGot(combat.combatId) == false then
					awardCount = awardCount + 1
				end
			end
		end
	end

	return {killedCount,awardCount}
end

--当前关卡奖励是否已领取
function PartyCombatBO.awardIsGot(combatId)
	for index=1,#PartyCombatMO.getAwardId_ do
		local gotCombatId = PartyCombatMO.getAwardId_[index]
		if gotCombatId == combatId then
			return true
		end
	end
	return false
end

function PartyCombatBO.getCombatList(sectionId)
	local sectionIndex = math.floor(sectionId / 100)
	local sectionDB = PartyCombatMO.queryCombatBySection(sectionIndex)
	-- gdump(sectionDB,"sectionDBsectionDB")

	PartyCombatMO.combatList_ = {}

	-- gdump(PartyCombatMO.partyCombat_,"PartyCombatMO.partyCombat_")

	for i = 1,#sectionDB do
		local combat = sectionDB[i]
		combat.schedule = 0
		combat.status = 1
		for j = 1,#PartyCombatMO.partyCombat_ do
			local combatDb = PartyCombatMO.partyCombat_[j]
			if combat.combatId == combatDb.combatId then
				combat.schedule = combatDb.schedule
				if combatDb.schedule == 100 and PartyCombatBO.awardIsGot(combat.combatId) then
					combat.status = 2
				end
			end
		end
		PartyCombatMO.combatList_[#PartyCombatMO.combatList_ + 1] = combat
	end
	return PartyCombatMO.combatList_
end


function PartyCombatBO.getCombatDbById(combatId)
	for index = 1,#PartyCombatMO.combatList_ do
		local combat = PartyCombatMO.combatList_[index]
		if combat.combatId == combatId then
			return combat
		end
	end
	return nil
end

function PartyCombatBO.updatePartyCombat(partyCombat)
	local has = false
	for index=1,#PartyCombatMO.partyCombat_ do
		local combat = PartyCombatMO.partyCombat_[index]
		if combat.combatId == partyCombat.combatId  then
			has = true
			if table.isexist(partyCombat,"form") then
				combat.form = partyCombat["form"]
			end
			combat.schedule = partyCombat.schedule
		end
	end
	if has == false then
		table.insert(PartyCombatMO.partyCombat_,partyCombat)
	end
end

--军团副本一键领奖
function PartyCombatBO.getAllPartyAwards(doneCallback, need)
	local function parseCallBack(name, data)
		Loading.getInstance():unshow()

		if table.isexist(data, "combatId") then
			PartyCombatMO.getAwardId_ = data.combatId
		else
			PartyCombatMO.getAwardId_ = {}
		end

		local award = PbProtocol.decodeArray(data["award"])
		
		 --加入背包
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)
		Notify.notify(LOCAL_PARTY_COMBAT_UPDATE_EVENT)
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PARTY_COMBAT_AWARD,type = 1})
		Notify.notify(LOCAL_PARTY_SECTION_UPDATE_EVENT)

		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseCallBack, NetRequest.new("GetAllPcbtAward"))
end