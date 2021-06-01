
-- 要塞

FortressBO = {}
FortressBO.DEFEND = 0 --防守
FortressBO.ATTACK = 1 --攻击
FortressBO.NOJOIN = -1 --无资格

function FortressBO.isInScope(tilePos)
	if tilePos.x >= (FortressMO.pos_.x - 1) and tilePos.x <= (FortressMO.pos_.x + 1)
		and tilePos.y >= (FortressMO.pos_.y - 1) and tilePos.y <= (FortressMO.pos_.y + 1) then
		return true
	else
		return false
	end
end

--获取获胜军团
function FortressBO.getWinParty(rhand)
	-- FortressBO.winParty_ = "测试军团"
	if not FortressBO.winParty_ then
		FortressBO.winParty_ = ""
		Loading.getInstance():show()
		local function getResult(name,data)
			Loading.getInstance():unshow()
			FortressBO.winParty_ = data.partyName
			if rhand then rhand(FortressBO.winParty_) end
		end
		SocketWrapper.wrapSend(getResult, NetRequest.new("GetFortressWinParty"))
	else
		rhand(FortressBO.winParty_)
	end
end

--获取参赛资格
function FortressBO.getJoinParty(rhand)
	if not FortressBO.statusParty_ then
		FortressBO.statusParty_ = {}
		Loading.getInstance():show()
		local function getResult(name,data)
			Loading.getInstance():unshow()
			-- if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			local party = PbProtocol.decodeArray(data.fortressBattleParty)
			for k,v in ipairs(party) do
				FortressBO.statusParty_[v.partyId] = v
			end
			if rhand then rhand(FortressBO.statusParty_) end
		end
		SocketWrapper.wrapSend(getResult, NetRequest.new("GetFortressBattleParty"))
	else
		if rhand then rhand(FortressBO.statusParty_) end
	end
end

--设置要塞战阵型
function FortressBO.setBattleForm(doneCallback, formation,fight)
	if FortressBO.hasOver_ == true then
		Loading.getInstance():unshow()
		Toast.show(CommonText[20051])
		return
	end
	if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
		Loading.getInstance():unshow()
		Toast.show(CommonText[366][2])
		return
	end

	local armyNum = ArmyMO.getFightArmies()
	if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
		Toast.show(CommonText[1629])
		return
	end
	
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local army = PbProtocol.decodeRecord(data.army)
		ArmyBO.updateArmy(army)
		Notify.notify(LOCAL_ARMY_EVENT)
		local newFormation, kind = CombatBO.parseServerFormation(army.form)
		TankMO.formation_[kind] = formation --newFormation  -- 更新阵型
		table.insert(FortressBO.defendList_,{nick=UserMO.nickName_,level=UserMO.level_,fight=fight})
		Notify.notify(LOCAL_DEFEND_LIST)
		Toast.show(CommonText[59])
	end
	local format = CombatBO.encodeFormation(formation)
	format.type = FORMATION_FORTRESS
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetFortressBattleForm",{form = format,fight = fight}))
end

--获取要塞防守信息
function FortressBO.GetDefend(doneCallback)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeRecord(data.fortressSelf)
		if not doneCallback then
			Notify.notify(LOCAL_FORTRESS_INFO, {info = info})
			return
		end
		local defendList = PbProtocol.decodeArray(data.fortressDefend)
		FortressBO.defendList_ = defendList or {}
		doneCallback(info,defendList,data.cdTime)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressBattleDefend",{form = format,fight = fight}))
end

--战况
function FortressBO.getBattleRecord(kind,page,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.record)
		if not FortressBO.recordList_ then
			FortressBO.recordList_ = {}
		end
		if not FortressBO.recordList_[kind] then
			FortressBO.recordList_[kind] = {}
		end
		for k,v in ipairs(info) do
			table.insert(FortressBO.recordList_[kind],v)
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("FortressBattleRecord",{type=kind,page=page}))
end

--推送战报
function FortressBO.parseFortressReport(name,data)
	--1战斗准备，2战斗中 3.取消 4战斗结束，5发放奖励结束
	FortressBO.warState_ = data.state
end

--推送信息
function FortressBO.parseFortressSelf(name,data)
	local info = PbProtocol.decodeRecord(data.fortressSelf)
	Notify.notify(LOCAL_FORTRESS_INFO, {info = info, attack = true})
end

--买cd
function FortressBO.buyBattleCd(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		UserMO.updateResource(ITEM_KIND_COIN,data.gold)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyFortressBattleCd"))
end

--解析战报
function FortressBO.parseReport(report,isReport)
	if not report then return end
	local record = report.record
	local result = report.result
	if result then  -- 胜利
		CombatMO.curBattleStar_ = 3
	else
		CombatMO.curBattleStar_ = 0
	end
	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curBattleCombatUpdate_ = 0
	CombatMO.curBattleAward_ = nil
	CombatMO.curBattleStatistics_ = {}

	if isReport then
		CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
	else
		CombatMO.curChoseBattleType_ = nil
	end
	CombatMO.curChoseBtttleId_ = 0

	-- 解析战斗的数据
	local combatData = CombatBO.parseCombatRecord(record)

	-- 设置先手
	CombatMO.curBattleOffensive_ = combatData.offsensive

	CombatMO.curBattleAtkFormat_ = combatData.atkFormat
	CombatMO.curBattleDefFormat_ = combatData.defFormat
	CombatMO.curBattleFightData_ = combatData

	BattleMO.reset()
	BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
	BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
	BattleMO.setFightData(CombatMO.curBattleFightData_)
	local atk = report.attacker
	if atk then atk = PbProtocol.decodeRecord(atk) end
	local def = report.defencer
	if def then def = PbProtocol.decodeRecord(def) end
	BattleMO.setBothInfo(atk,def)
	local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)
	require("app.view.BattleView").new():push()
end

--攻击要塞
function FortressBO.attackFortress(format, donecallback)
	if FortressBO.hasOver_ == true then 
		Toast.show(CommonText[20051])
		return
	end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local record = PbProtocol.decodeRecord(data.record)
		local report = PbProtocol.decodeRecord(data.rptAtkFortress)

		--更新坦克数据
		local tanks = PbProtocol.decodeArray(data["tank"])
		for index = 1, #tanks do  -- 设置tank的数量
			local data = tanks[index]
			TankMO.tanks_[data.tankId] = data
		end
		UserBO.triggerFightCheck()

		if donecallback then donecallback() end
		
		UiDirector.pop()
		FortressBO.parseReport(report)
	end
	-- local form = TankMO.getFormationByType(FORMATION_FORTRESS)
	format = CombatBO.encodeFormation(format)
	-- format.type = FORMATION_FORTRESS
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AttackFortress",{lordId=FortressMO.attackLordId_,form=format}))
end

--军团排名
function FortressBO.partyRank(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		FortressBO.partyRankData_ = {}
		if data.fortressPartyRank then
			FortressBO.partyRankData_.list = PbProtocol.decodeArray(data.fortressPartyRank)
		end
		if data.myFortressPartyRank then
			FortressBO.partyRankData_.myRank = PbProtocol.decodeRecord(data.myFortressPartyRank)
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressPartyRank"))
end

--积分排名
function FortressBO.scoreRank(page,kind,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		FortressBO.scoreRankData_ = {}
		if data.fortressJiFenRank then
			FortressBO.scoreRankData_.list = PbProtocol.decodeArray(data.fortressJiFenRank)
		end
		if data.myFortressJiFenRank then
			FortressBO.scoreRankData_.myRank = PbProtocol.decodeRecord(data.myFortressJiFenRank)
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressJiFenRank",{page=page,type=kind}))
end

--战绩统计
function FortressBO.combatStatics(kind,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		FortressBO.combatRankData_ = {}
		if data.twoInt then
			FortressBO.combatRankData_.list = PbProtocol.decodeArray(data.twoInt)
		end
		FortressBO.combatRankData_.fightNum = data.fightNum
		FortressBO.combatRankData_.winNum = data.winNum
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressCombatStatics",{type=kind}))
end

--获取战报
function FortressBO.fightReport(key)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local report = PbProtocol.decodeRecord(data.rptAtkFortress)
		FortressBO.parseReport(report,1)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressFightReport",{reportKey=key}))
end

--获取进修数据
function FortressBO.fortressAttr(rhand)
	if FortressBO.attrs_ then
		rhand()
		return 
	end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		FortressBO.attrs_ = {}
		local data = PbProtocol.decodeArray(data.myFortressAttr)
		for k,v in ipairs(data) do
			FortressBO.attrs_[v.id] = v.level
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressAttr"))
end

--进修
function FortressBO.upAttr(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		FortressBO.attrs_[data.id] = data.level
		UserMO.updateResource(ITEM_KIND_COIN,data.gold)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpFortressAttr",{id=id}))
end

--职位获取
function FortressBO.getJob(rhand)
	-- if FortressBO.jobList_ then
	-- 	rhand()
	-- 	return 
	-- end
	local function parseResult(name, data)
		FortressBO.jobList_ = {}
		Loading.getInstance():unshow()
		if data.fortressJob then
			local temp = PbProtocol.decodeArray(data.fortressJob)
			for k,v in ipairs(temp) do
				if not FortressBO.jobList_[v.jobId] then
					FortressBO.jobList_[v.jobId] = {}
				end
				table.insert(FortressBO.jobList_[v.jobId],v)
			end
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFortressJob"))
end

--职位任命
function FortressBO.appoint(jobId,nick,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local map = FortressBO.jobList_[jobId]
		if not map then
			map = {}
			FortressBO.jobList_[jobId] = map
		end
		local temp = {}
		local jb = FortressMO.queryJobById(jobId)
		temp.endTime = ManagerTimer.getTime() + jb.durationTime
		temp.index = #temp+1
		temp.nick = nick
		temp.jobId = jobId
		table.insert(map,temp)
		Toast.show(CommonText[20059])
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("FortressAppoint",{jobId=jobId,nick=nick}))	
end

--获取要塞职位
function FortressBO.fortressJob(data)
	if data.fortressJob then
		FortressBO.job_ = PbProtocol.decodeRecord(data.fortressJob)
	end
end

