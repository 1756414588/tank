
-- 竞技场BO

ArenaBO = {}

function ArenaBO.update(data)
	ArenaMO.arenaLeftCount_ = 0
	ArenaMO.currentRank_ = 0
	ArenaMO.lastRank_ = 0
	ArenaMO.winStreak_ = 0
	ArenaMO.cdTime_ = 0
	ArenaMO.receiveAwards_ = false
	ArenaMO.champion_ = ""
	ArenaMO.fightValue_ = 0
	ArenaMO.buyCount_ = 0
	ArenaMO.arenaScore_ = 0
	ArenaMO.firstEnter_ = false
	ArenaMO.rivals_ = {}
	
	gdump(data, "ArenaBO.update")
	
	if data then
		if table.isexist(data, "count") then ArenaMO.arenaLeftCount_ = data.count end
		if table.isexist(data, "score") then ArenaMO.arenaScore_ = data.score end
		if table.isexist(data, "rank") then ArenaMO.currentRank_ = data.rank end
		if table.isexist(data, "lastRank") then ArenaMO.lastRank_ = data.lastRank end
		if table.isexist(data, "winCount") then ArenaMO.winStreak_ = data.winCount end
		if table.isexist(data, "coldTime") then ArenaMO.cdTime_ = data.coldTime + ARENA_COLD_TAKE_TIME - ManagerTimer.getTime() + 0.99 end
		if table.isexist(data, "award") then ArenaMO.receiveAwards_ = data.award end
		if table.isexist(data, "champion") then ArenaMO.champion_ = data.champion end
		if table.isexist(data, "fight") then ArenaMO.fightValue_ = data.fight end
		if table.isexist(data, "buyCount") then ArenaMO.buyCount_ = data.buyCount end

		local ary = PbProtocol.decodeArray(data["rankPlayer"])
		ArenaMO.rivals_ = ary

		if ArenaMO.currentRank_ == 0 then  -- 首次进入
			ArenaMO.firstEnter_ = true
		else
			ArenaMO.firstEnter_ = false
		end
	end

	local function onTick(dt)
		if ArenaMO.cdTime_ > 0 then
			ArenaMO.cdTime_ = ArenaMO.cdTime_ - dt
			if ArenaMO.cdTime_ <= 0 then  -- cd时间结束
			end
		end
	end

	if not ArenaMO.cdTimeHandler_ then
		ArenaMO.cdTimeHandler_ = ManagerTimer.addTickListener(onTick)
	end
end

function ArenaBO.orderRival(rivalA, rivalB)
	if rivalA.rank < rivalB.rank then return true
	else return false end
end

-- refresh:false表示不是用于刷新数据，而是进入竞技场界面时拉取数据的
function ArenaBO.asynGetArena(doneCallback, refresh)
	local function parseGetArena(name, data)
		gdump(data, "[ArenaBO] get arena")

		ArenaBO.update(data)
		
		if not refresh then
			Notify.notify(LOCLA_GET_ARENA_EVENT)
		end
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetArena, NetRequest.new("GetArena", {type = typeValue, combatId = combatId, form = format}))
end

function ArenaBO.asynInitArena(doneCallback, formation)
	local function parseInitArena(name, data)
		gdump(data, "[ArenaBO] init arena")
		TankMO.formation_[FORMATION_FOR_ARENA] = formation  -- 保存阵型

		ArenaMO.firstEnter_ = false
		ArenaMO.arenaLeftCount_ = data.count
		ArenaMO.arenaScore_ = 0
		ArenaMO.currentRank_ = data.rank
		ArenaMO.lastRank_ = 0
		ArenaMO.winStreak_ = 0
		ArenaMO.cdTime_ = 0
		ArenaMO.receiveAwards_ = false
		if table.isexist(data, "fight") then ArenaMO.fightValue_ = data.fight end

		local ary = PbProtocol.decodeArray(data["rankPlayer"])
		ArenaMO.rivals_ = ary

		if doneCallback then doneCallback() end
	end

	local format = CombatBO.encodeFormation(formation)
	format.type = FORMATION_FOR_ARENA

	SocketWrapper.wrapSend(parseInitArena, NetRequest.new("InitArena", {form = format}))
end

-- formation: 我方上阵阵型
function ArenaBO.asynDoArena(doneCallback, rivalRank, formation)
	local function parseDoArena(name, data)
		gdump(data, "[ArenaBO] do arena")
		ArenaMO.cdTime_ = 0

		if table.isexist(data, "coldTime") then ArenaMO.cdTime_ = data.coldTime + ARENA_COLD_TAKE_TIME - ManagerTimer.getTime() + 0.99 end
		-- print("ArenaMO.cdTime_:", ArenaMO.cdTime_)
		
		if data.result > 0 then 
			CombatMO.curBattleStar_ = 3
		else
			CombatMO.curBattleStar_ = 0
		end
		CombatMO.curBattleNeedShowBalance_ = false
		-- CombatMO.curBattleExp_ = 0
		-- CombatMO.curBattleLevelUp_ = false
		CombatMO.curBattleCombatUpdate_ = 0

		ArenaMO.arenaLeftCount_ = ArenaMO.arenaLeftCount_ - 1 -- 次数减少

		local form = PbProtocol.decodeRecord(data["form"])
		local defFormation, type = CombatBO.parseServerFormation(form)

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"], formation, defFormation)

		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive

		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData

		-- 攻先手值
		if table.isexist(data,"firstValue1") then
			CombatMO.curBattleFightData_.firstValue1 = data.firstValue1
		end
		-- 防先手值
		if table.isexist(data,"firstValue2") then
			CombatMO.curBattleFightData_.firstValue2 = data.firstValue2
		end

		-- 统计战斗数据
		local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])
		gdump(awards, "[ArenaBO] arena drop award")
		local statisticsAward = CombatBO.addAwards(awards)
		CombatMO.curBattleAward_ = statisticsAward

		if data.score > 0 then
			local old = UserMO.getResource(ITEM_KIND_SCORE)

			UserMO.updateResource(ITEM_KIND_SCORE, data.score)

			local delta = data.score - old
			statisticsAward.awards[#statisticsAward.awards + 1] = {kind = ITEM_KIND_SCORE, count = delta}
		end

		if CombatMO.curBattleStar_ > 0 and ActivityBO.isValid(ACTIVITY_ID_CRAZY_ARENA) then  -- 疯狂竞技活动
			ActivityBO.trigger(ACTIVITY_ID_CRAZY_ARENA, 1)
		end

		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_JJC,type = 1})
		--TK统计
		TKGameBO.onEvnt(TKText.eventName[24])

		if doneCallback then doneCallback() end

		-- 埋点
		Statistics.postPoint(STATIS_POINT_PK)
	end

	SocketWrapper.wrapSend(parseDoArena, NetRequest.new("DoArena", {rank = rivalRank}))
end

function ArenaBO.asynBuyArenaCd(doneCallback, second)
	local function parseBuyArena(name, data)
		-- 清除CD时间
		ArenaMO.cdTime_ = 0

		TKGameBO.onUseCoinTk(data.gold,TKText[54],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseBuyArena, NetRequest.new("BuyArenaCd", {s = math.ceil(second)}))
end

function ArenaBO.asynBuyArena(doneCallback)
	local function parseBuyArena(name, data)
		gdump(data, "[ArenaBO] buy arena")
		ArenaMO.arenaLeftCount_ = data.count -- 剩余挑战次数
		ArenaMO.buyCount_ = ArenaMO.buyCount_ + 1

		TKGameBO.onUseCoinTk(data.gold,TKText[27],TKGAME_USERES_TYPE_UPDATE)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseBuyArena, NetRequest.new("BuyArena"))
end

function ArenaBO.asynUseScore(doneCallback, propId)
	local function doneUseScore(name, data)
		gdump(data, "[ArenaBO] use score")
		local award = PropBO.convertMaterial({kind = ITEM_KIND_PROP, id = propId, count = 1})
		UserMO.addResources({award})

		-- 更新积分
		UserMO.updateResource(ITEM_KIND_SCORE, data.score)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(doneUseScore, NetRequest.new("UseScore", {propId = propId}))
end

function ArenaBO.asynArenaAward(doneCallback)
	local function doneArenaAward(name, data)
		gdump(data, "[ArenaBO] arena award")

		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])
		gdump(awards, "[ArenaBO] arena award")
		local statisticsAward = CombatBO.addAwards(awards)

		ArenaMO.receiveAwards_ = true

		if doneCallback then doneCallback(statisticsAward) end
	end
	SocketWrapper.wrapSend(doneArenaAward, NetRequest.new("ArenaAward"))
end

function ArenaBO.createRank(rank)
	if rank == 1 then return display.newSprite(IMAGE_COMMON .. "rank_1.png")
	elseif rank == 2 then return display.newSprite(IMAGE_COMMON .. "rank_2.png")
	elseif rank == 3 then return display.newSprite(IMAGE_COMMON .. "rank_3.png")
	else
		return ui.newTTFLabel({text = rank, font = G_FONT, size = FONT_SIZE_HUGE, align = ui.TEXT_ALIGN_CENTER})
	end
end

function ArenaBO.getRankColor(rank)
	if rank == 1 then return COLOR[5]
	elseif rank == 2 then return COLOR[12]
	elseif rank == 3 then return COLOR[4]
	elseif rank <= 13 then return cc.c3b(249, 242, 164)
	else return cc.c3b(255, 255, 255)
	end
end
