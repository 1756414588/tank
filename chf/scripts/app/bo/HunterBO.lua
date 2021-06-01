--
-- Author: heyunlong
-- Date: 2018-04-19 14:22
--

HunterBO = {}
HunterBO.teamType = nil
HunterBO.teamId = nil
HunterBO.teamInfos = nil
HunterBO.teamOrders = nil
HunterBO.captainRoleId = nil
HunterBO.teamChats = {}
HunterBO.todayCoinGot = 0
HunterBO.stageChanlCount = {}
HunterBO.lastSectionId = nil
-- 是否可以发送世界邀请聊天
HunterBO.world_invite_enable = false
HunterBO.inviteScheduler = nil
HunterBO.unreadMsgCount = 0
HunterBO.wantedOpen = false
HunterBO.wantedRewardStatus = {}
HunterBO.duringStage = nil


function HunterBO.clear()
	-- body
	HunterBO.teamType = nil
	HunterBO.teamId = nil
	HunterBO.teamInfos = nil
	HunterBO.teamOrders = nil
	HunterBO.captainRoleId = nil
	HunterBO.teamChats = {}
	HunterBO.world_invite_enable = false
	HunterBO.unreadMsgCount = 0
end

function HunterBO.createTeam(teamType, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "createTeam recieve data==")
		HunterBO.teamType = teamType
		-- 存储队伍id
		HunterBO.teamId = data.teamId
		-- 建立队伍数组
		HunterBO.teamInfos = {}
		HunterBO.teamOrders = {}
		local info = PbProtocol.decodeRecord(data.roleInfo)
		HunterBO.captainRoleId = info.roleId
		-- 将队长的信息存进来
		HunterBO.teamInfos[info.roleId] = info
		table.insert(HunterBO.teamOrders, info.roleId)

		-- 刚刚创建队伍时可以重新点击邀请
		HunterBO.world_invite_enable = true
		if HunterBO.inviteScheduler ~= nil then
			scheduler.unscheduleGlobal(HunterBO.inviteScheduler)
			HunterBO.inviteScheduler = nil
		end

		gdump(HunterBO.teamInfos, "teamInfos==")
		gdump(HunterBO.teamOrders, "teamOrders==")

		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("CreateTeam", {teamType=teamType}))
end

function HunterBO.dismissTeam(rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		-- 清除掉队伍的数据
		HunterBO.clear()
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("DismissTeam"))
end

function HunterBO.joinTeam(teamId, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "joinTeam recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("JoinTeam", {teamId=teamId}))
end

function HunterBO.leaveTeam(rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "leaveTeam recieve data==")
		HunterBO.clear()
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("LeaveTeam"))
end


function HunterBO.kickOut(roleId, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "kickOut recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("KickOut", {roleId=roleId}))
end

function HunterBO.findTeam(teamType, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "findTeam recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	print("find team id=", teamType)
	SocketWrapper.wrapSend(getResult, NetRequest.new("FindTeam", {teamType=teamType}))
end

function HunterBO.changeMemberReadyState(rhand)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "ChangeMemberReadyState recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("ChangeMemberStatus"))
end

function HunterBO.exchangeOrder(role1, role2, rhand)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "ExchangeOrder recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("ExchangeOrder", {roleOne=role1, roleTwo=role2}))
end


function HunterBO.teamChat(message, rhand)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "TeamChat recieve data==")
		rhand(data.time)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("TeamChat", {message=message, }))
end

function HunterBO.lookMemberInfo(roleId, rhand)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "LookMemberInfo recieve data==")
		local fight = data.fight
		local form = PbProtocol.decodeRecord(data.form)
		local formation = {}
		for i = 1, 6 do
			local attrName = string.format("p%d", i)
			if table.isexist(form, attrName) then
				local pv = PbProtocol.decodeRecord(form[attrName])
				table.insert(formation, {count=pv.v2, tankId=pv.v1})
			else
				table.insert(formation, {count=0, tankId=0})
			end
		end
		local commander = form.commander
		-- gdump(formation, "LookMemberInfo recieve formation==")
		rhand(fight, formation, commander)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("LookMemberInfo", {roleId=roleId, }))
end

function HunterBO.inviteMember(stageId, rhand)
	-- body
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "InviteMember recieve data==")
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("InviteMember", {stageId=stageId, }))
end

function HunterBO.getBountyShopBuy(rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "GetBountyShopBuy recieve data==")
		local list = PbProtocol.decodeArray(data.shopInfo)
		UserMO.hunterCoin_ = data.itemCount
		rhand(data.openWeek, list)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetBountyShopBuy"))
end


function HunterBO.teamInstanceExchange(goodId, rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "TeamInstanceExchange recieve data==")
		local coinCount = data.itemCount
		local awards = PbProtocol.decodeArray(data.award)
		local buyInfo = PbProtocol.decodeRecord(data.buyInfo)
		rhand(coinCount, awards, buyInfo)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("TeamInstanceExchange", {goodid=goodId, }))
end


function HunterBO.getTaskRewardStatus(rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "GetTaskRewardStatus recieve data==")
		local taskStatus = PbProtocol.decodeArray(data.taskInfo)
		HunterBO.wantedRewardStatus = {}
		for i, v in ipairs(taskStatus) do
			HunterBO.wantedRewardStatus[v.taskId] = v
		end
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetTaskRewardStatus"))
end


function HunterBO.getTaskReward(taskId, rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "GetTaskReward recieve data==")
		local reward = PbProtocol.decodeArray(data.award)
		rhand(reward)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetTaskReward", {taskId=taskId, }))
end


function HunterBO.teamFightBoss(rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "TeamFightBoss recieve data==")
		-- 赏金出击成功
		-- CombatMO.curBattleCombatUpdate_ = 5
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("TeamFightBoss"))
end


function HunterBO.getTeamFightBossInfo(rhand)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "GetTeamFightBossInfo recieve data==")
		HunterBO.todayCoinGot = data.dayItemCount
		local countInfo = PbProtocol.decodeArray(data.count)
		HunterBO.stageChanlCount = {}
		for i, v in ipairs(countInfo) do
			HunterBO.stageChanlCount[v.v1] = v.v2
		end
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetTeamFightBossInfo"))
end


function HunterBO.getStageChanllCount(stageId)
	-- body
	if HunterBO.stageChanlCount[stageId] then
		return HunterBO.stageChanlCount[stageId]
	else
		return 0
	end
end


function HunterBO.SynTeamInfo(name, data)
	local teamId = data.teamId
	local captainId = data.captainId
	local teamType = data.teamType
	gdump(data, "SynTeamInfo data==")
	local order = data.order
	local teamOrders = {}
	for k, v in ipairs(order) do
		if v ~= 0 then
			teamOrders[k] = v
		else
			teamOrders[k] = v
		end
	end
	local teamInfo = PbProtocol.decodeArray(data.teamInfo)
	gdump(teamInfo, "SynTeamInfo, teamInfo==")
	local teamInfos = {}
	for k, v in ipairs(teamInfo) do
		local roleId = v['roleId']
		teamInfos[roleId] = v
	end
	local actionType = data.actionType

	local isJoin = false
	if HunterBO.teamId == nil then
		isJoin = true
	end

	HunterBO.teamId = teamId
	HunterBO.captainRoleId = captainId
	HunterBO.teamType = teamType
	HunterBO.teamOrders = teamOrders
	HunterBO.teamInfos = teamInfos

	if actionType == 2 then
		-- 如果是加入操作
		if isJoin == true then
			-- 加入操作
			Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=1})
		else
			-- 加入之后刷新队伍信息的操作
			Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=2})
		end
	elseif actionType == 3 then
		-- 离开操作引擎的更新
		Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=4})
	elseif actionType == 4 then
		-- 踢出操作引起的更新
		Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=3})
	elseif actionType == 5 then
		if isJoin == true then
			local view = require("app.view.CombatHunterView").new(HunterBO.teamType, UI_ENTER_FADE_IN_GATE)
			view:push()
			view:joinTeamUI()
		else
			Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=2})
		end
	elseif actionType == 7 then
		Notify.notify(LOCAL_TEAM_INFO_EVENT, {type=7})
	elseif actionType == 8 then
		Notify.notify(LOCAL_TEAM_ORDER_EVENT, {type=actionType})
	end
end

function HunterBO.SynNotifyDismissTeam(name, data)
	HunterBO.clear()
	Notify.notify(LOCAL_TEAM_DISMISS_EVENT)
end


function HunterBO.SynNotifyKickOut(name, data)
	-- 告知这边已被踢出，并且退出
	HunterBO.clear()
	Notify.notify(LOCAL_TEAM_KICK_OUT_EVENT)
end


function HunterBO.SynChangeStatus(name, data)
	gdump(data, "SynChangeStatus, data==")
	local roleId = data.roleId
	local status = data.status
	if HunterBO.teamInfos and HunterBO.teamInfos[roleId] then
		HunterBO.teamInfos[roleId].status = status
		Notify.notify(LOCAL_TEAM_CHANGE_STATUS_EVENT)
	end
end


function HunterBO.SynTeamOrder(name, data)
	gdump(data, "SynTeamOrder, data==")
	local order = data.order
	local teamOrders = {}
	for k, v in ipairs(order) do
		if v ~= 0 then
			teamOrders[k] = v
		else
			teamOrders[k] = v
		end
	end
	HunterBO.teamOrders = teamOrders
	Notify.notify(LOCAL_TEAM_ORDER_EVENT)
end


function HunterBO.SynTeamChat(name, data)
	if HunterBO.teamInfos and HunterBO.teamInfos[data.roleId] then
		table.insert(HunterBO.teamChats, {roleId=data.roleId, content=data.message, time=data.time, name=data.name, serName = data.serverName})
		table.sort(HunterBO.teamChats, function(a,b) return a.time < b.time end)
		Notify.notify(LOCAL_TEAM_CHAT_EVENT)
	end
end


function HunterBO.SynStageCloseToTeamRq(name, data)
	-- body
	HunterBO.clear()
	Notify.notify(LOCAL_TEAM_STAGE_CLOSE_EVENT)
end


function HunterBO.SyncTeamFightBoss(name, data)
	-- body
	gdump(data, "SyncTeamFightBoss data==")
	-- CombatMO.curBattleCombatUpdate_ = 5
	HunterMO.curTeamFightBossData_ = data
	-- 更新挑战次数信息
	local countInfo = PbProtocol.decodeArray(data.count)
	for i, v in ipairs(countInfo) do
		HunterBO.stageChanlCount[v.v1] = v.v2
	end

	local bgFile = nil
	if HunterBO.teamType == 101 then
		bgFile = "image/bg/bg_bounty_railgun.png"
	else
		bgFile = "image/bg/bg_bounty_boss.png"
	end

	-- 清除组队信息
	-- HunterBO.clear()
	Notify.notify(LOCAL_TEAM_FIGHT_BOSS_EVENT)
	-- 退出当前界面
	UiDirector.popName(nil, "CombatHunterView")
	-- 进入到战斗界面
	local record = data.record
	local recordLord = PbProtocol.decodeArray(data.recordLord)
	-- 挑战的结果
	local success = data.isSuccess
	if success == 1 then
		CombatMO.curBattleStar_ = 3
	else
		CombatMO.curBattleStar_ = 0
	end

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curBattleCombatUpdate_ = 5

	local awards = PbProtocol.decodeArray(data.award)
	CombatMO.curBattleAward_ = CombatBO.addAwards(awards)
	CombatMO.curBattleStatistics_ = {}

	CombatMO.curChoseBattleType_ = COMBAT_TYPE_BOUNTY_BOSS
	CombatMO.curChoseBtttleId_ = 0

	-- 解析战斗的数据
	gdump(record, "SyncTeamFightBoss record ==")
	local combatData = CombatBO.parseCombatRecord(record, nil, nil)
	gdump(combatData, "SyncTeamFightBoss combatData ==")

	BattleMO.bountyBossId_ = true
	BattleMO.attackers_ = {}
	BattleMO.defencers_ = {}

	local atkQue = {}
	local defQue = {}
	for i,v in ipairs(recordLord) do
		if v.v1 >= 0 then
			if #atkQue <= 0 or atkQue[#atkQue].lordId ~= v.v1 then
				atkQue[#atkQue+1] = {lordId = v.v1, idx = i}
			end
		end

		if v.v2 >= 0 then
			if #defQue <= 0 or defQue[#defQue].lordId ~= v.v2 then
				defQue[#defQue+1] = {lordId = v.v2, idx = i}
			end
		end
	end

	for i,v in ipairs(atkQue) do
		BattleMO.attackers_[i] = {}
		BattleMO.attackers_[i].lordId = v.lordId
		-- for _,person in ipairs(self.m_mail.report_db_.attackers or {}) do
		-- 	if v.lordId == person.lordId then
		-- 		BattleMO.attackers_[i].name = person.name
		-- 		if table.isexist(person,"firstValue") then
		-- 			BattleMO.attackers_[i].firstValue = person.firstValue
		-- 		end
		-- 		break
		-- 	end
		-- end
		if i == 1 then
			BattleMO.attackers_[i].commander = combatData.atkFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.attackers_[i].commander = BattleMO.record_[v.idx-1].atkFormat.commander
		end
	end

	for i,v in ipairs(defQue) do
		BattleMO.defencers_[i] = {}
		BattleMO.defencers_[i].lordId = v.lordId
		-- for _,person in ipairs(self.m_mail.report_db_.defencers or {}) do
		-- 	if v.lordId == person.lordId then
		-- 		BattleMO.defencers_[i].name = person.name
		-- 		if table.isexist(person,"firstValue") then
		-- 			BattleMO.defencers_[i].firstValue = person.firstValue
		-- 		end
		-- 		break
		-- 	end
		-- end
		if i == 1 then
			BattleMO.defencers_[i].commander = combatData.defFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.defencers_[i].commander = BattleMO.record_[v.idx-1].defFormat.commander
		end
	end

	CombatMO.curBattleOffensive_ = combatData.offsensive

	CombatMO.curBattleAtkFormat_ = combatData.atkFormat
	CombatMO.curBattleDefFormat_ = combatData.defFormat
	CombatMO.curBattleFightData_ = combatData

	BattleMO.reset()
	BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
	BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
	BattleMO.setFightData(CombatMO.curBattleFightData_)
	-- BattleMO.setBothInfo(self.m_mail.report_db_.attacker,self.m_mail.report_db_.defencer)

	-- HunterBO.parseTotalBattleStastics()
	local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

	HunterBO.getTeamFightBossInfo(function ()
	end)
	require("app.view.BattleView").new(bgFile):push()
end


function HunterBO.PlayTeamFightBoss(stageId, data)
	-- body
	local bgFile = nil
	if stageId == 101 then
		bgFile = "image/bg/bg_bounty_railgun.png"
	else
		bgFile = "image/bg/bg_bounty_boss.png"
	end

	-- 进入到战斗界面
	local record = data.record
	local recordLord = PbProtocol.decodeArray(data.recordLord)
	-- 挑战的结果
	local success = data.isSuccess
	if success == 1 then
		CombatMO.curBattleStar_ = 3
	else
		CombatMO.curBattleStar_ = 0
	end

	CombatMO.curBattleNeedShowBalance_ = false
	CombatMO.curBattleCombatUpdate_ = 5
	local awards = PbProtocol.decodeArray(data.award)
	-- CombatMO.curBattleAward_ = CombatBO.addAwards(awards)
	CombatMO.curBattleStatistics_ = {}

	CombatMO.curChoseBattleType_ = COMBAT_TYPE_BOUNTY_BOSS
	CombatMO.curChoseBtttleId_ = 0

	-- 解析战斗的数据
	local combatData = CombatBO.parseCombatRecord(record, nil, nil)

	BattleMO.bountyBossId_ = true
	BattleMO.attackers_ = {}
	BattleMO.defencers_ = {}

	local atkQue = {}
	local defQue = {}
	for i,v in ipairs(recordLord) do
		if v.v1 > 0 then
			if #atkQue <= 0 or atkQue[#atkQue].lordId ~= v.v1 then
				atkQue[#atkQue+1] = {lordId = v.v1, idx = i}
			end
		end

		if v.v2 > 0 then
			if #defQue <= 0 or defQue[#defQue].lordId ~= v.v2 then
				defQue[#defQue+1] = {lordId = v.v2, idx = i}
			end
		end
	end

	for i,v in ipairs(atkQue) do
		BattleMO.attackers_[i] = {}
		BattleMO.attackers_[i].lordId = v.lordId
		if i == 1 then
			BattleMO.attackers_[i].commander = combatData.atkFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.attackers_[i].commander = BattleMO.record_[v.idx-1].atkFormat.commander
		end
	end

	for i,v in ipairs(defQue) do
		BattleMO.defencers_[i] = {}
		BattleMO.defencers_[i].lordId = v.lordId
		if i == 1 then
			BattleMO.defencers_[i].commander = combatData.defFormat.commander
		elseif BattleMO.record_ and BattleMO.record_[v.idx-1] then
			BattleMO.defencers_[i].commander = BattleMO.record_[v.idx-1].defFormat.commander
		end
	end

	CombatMO.curBattleOffensive_ = combatData.offsensive

	CombatMO.curBattleAtkFormat_ = combatData.atkFormat
	CombatMO.curBattleDefFormat_ = combatData.defFormat
	CombatMO.curBattleFightData_ = combatData

	BattleMO.reset()
	BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
	BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
	BattleMO.setFightData(CombatMO.curBattleFightData_)

	local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

	require("app.view.BattleView").new(bgFile):push()
end


function HunterBO.parseTotalBattleStastics()
	-- body
	HunterMO.allBattleStatistics_ = {}
	local records = BattleMO.record_
	for i = 1, #records do
		local record = records[i]

		local curBattleStatistics = {[BATTLE_FOR_ATTACK] = {}, [BATTLE_FOR_DEFEND] = {}}
		curBattleStatistics[BATTLE_FOR_ATTACK] = {tankCount = 0, roundCount = 0, actionCount = 0, impaleCount = 0, dodgeCount = 0, critCount = 0}
		curBattleStatistics[BATTLE_FOR_DEFEND] = {tankCount = 0, roundCount = 0, actionCount = 0, impaleCount = 0, dodgeCount = 0, critCount = 0}

		local atkFormat = record.atkFormat
		local defFormat = record.defFormat
		-- 获得阵型中的坦克总数
		local tankStat = TankBO.stasticsFormation(atkFormat)
		curBattleStatistics[BATTLE_FOR_ATTACK].tankCount = tankStat.amount
		local tankStat = TankBO.stasticsFormation(defFormat)
		curBattleStatistics[BATTLE_FOR_DEFEND].tankCount = tankStat.amount

		-- 保存战斗结束后的双方阵型数据
		local leftFormats = {[BATTLE_FOR_ATTACK] = clone(atkFormat), [BATTLE_FOR_DEFEND] = clone(defFormat)}

		for roundIndex = 1, #record.round do
			local round = record.round[roundIndex]
			local battleFor, pos = CombatMO.getBattlePosition(record.offensive, round.key)
			curBattleStatistics[battleFor].roundCount = curBattleStatistics[battleFor].roundCount + 1
			curBattleStatistics[battleFor].actionCount = curBattleStatistics[battleFor].actionCount + #round.action

			for actionIndex = 1, #round.action do
				local action = round.action[actionIndex]
				-- gdump(action, "CombatBO.parseBattleStastics")
				
				if action.impale then curBattleStatistics[battleFor].impaleCount = curBattleStatistics[battleFor].impaleCount + 1 end -- 穿刺
				if action.dodge then curBattleStatistics[battleFor].dodgeCount = curBattleStatistics[battleFor].dodgeCount + 1 end -- 闪避
				if action.crit then curBattleStatistics[battleFor].critCount = curBattleStatistics[battleFor].critCount + 1 end -- 暴击

				if not action.dodge then  -- 如果发生了闪避，则不会有伤害
					-- 剩余tank的数量
					local rivalBattleFor, rivalPos = CombatMO.getBattlePosition(record.offensive, action.target)
					leftFormats[rivalBattleFor][rivalPos].count = action.count
				end
			end
		end

		local tankStat = TankBO.stasticsFormation(leftFormats[BATTLE_FOR_ATTACK])
		curBattleStatistics[BATTLE_FOR_ATTACK].leftTankCount = tankStat.amount
		local tankStat = TankBO.stasticsFormation(leftFormats[BATTLE_FOR_DEFEND])
		curBattleStatistics[BATTLE_FOR_DEFEND].leftTankCount = tankStat.amount

		table.insert(HunterMO.allBattleStatistics_, curBattleStatistics)
	end
end

function HunterBO.isBountyOpen(openTimeStr)
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	if week == 0 then week = 7 end
	local temp1 = json.decode(openTimeStr)
	for i = 1, #temp1 do
		local d = tonumber(temp1[i])
		if week == d then
			return true
		end
	end

	return false
end


--跨服组队相关
function HunterBO.updateCrossInfo(data)
	HunterMO.teamFightCrossData_.state = data.state
	--跨服军事矿区开启状态
	StaffMO.CrossServerMineOpen = data.crossMineState

	local list = PbProtocol.decodeArray(data.info)
	HunterMO.teamFightCrossData_.serverData = list
end

function HunterBO.getCrossServerList(rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		HunterMO.teamFightCrossData_.state = data.state
		local list = PbProtocol.decodeArray(data.info)
		HunterMO.teamFightCrossData_.serverData = list
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossServerInfo"))
end

--跨服推送
function HunterBO.SyncTeamFightCrossInfo(name, data)
	HunterMO.teamFightCrossData_.state = data.state
	--跨服军事矿区开启状态
	StaffMO.CrossServerMineOpen = data.crossMineState
end