--
-- Author: gf
-- Date: 2015-12-15 16:04:14
-- 百团混战

PartyBattleBO = {}
PartyBattleBO.fortressJifen = 0
PartyBattleBO.fortressRank = 0
function PartyBattleBO.parseSynWarState(name, data)
	if not PartyBattleMO.isOpen then return end

	if not data then return end
	PartyBattleMO.warState = data.state
	
	if PartyBattleMO.warState == PARTY_BATTLE_STATE_AWARD_END or PartyBattleMO.warState == PARTY_BATTLE_STATE_CANCEL then
		-- PartyBattleMO.myArmy = nil
		scheduler.performWithDelayGlobal(function()
				ArmyBO.asynGetArmy(function()
						TankBO.asynGetTank()
					end)
			end, 0.99)
	end

	-- function showNotice(str,delayTime)
	-- 	if str then
	-- 		if PartyBattleMO.noticeShowScheduler_ then
	-- 			scheduler.unscheduleGlobal(PartyBattleMO.noticeShowScheduler_)
	-- 			PartyBattleMO.noticeShowScheduler_ = nil
	-- 		end

	-- 		-- 延迟发送，避免多个地方触发，而导致重复发送
	-- 		PartyBattleMO.noticeShowScheduler_ = scheduler.performWithDelayGlobal(function()
	-- 				local notice = {
	-- 					isGm = true,
	-- 					style = 1,
	-- 					msg = str
	-- 				}
	-- 				UiUtil.showHorn(notice)
	-- 				-- local chat = {
	-- 				-- 	channel = 1,
	-- 				-- 	isGm = true,
	-- 				-- 	msg = str,
	-- 				-- 	portrait = 1,
	-- 				-- 	time = 
	-- 				-- }

	-- 			end, delayTime)
	-- 	end
	-- end
	local str = nil
	local delayTime = 0
	if PartyBattleMO.warState == PARTY_BATTLE_STATE_AWARD_END then

	elseif PartyBattleMO.warState == PARTY_BATTLE_STATE_SIGN then
		--开始报名的时候清理掉战况数据
		PartyBattleMO.processList.all = {}
		PartyBattleMO.processList.party = {}
		PartyBattleMO.processList.personal = {}
		Notify.notify(LOCAL_PARTY_BATTLE_PROCESS_UPDATE_EVENT)
	elseif PartyBattleMO.warState == PARTY_BATTLE_STATE_CANCEL then
		str = CommonText[824][6]
		delayTime = 1
		PartyBattleBO.showNotice(145,delayTime)
	elseif PartyBattleMO.warState == PARTY_BATTLE_STATE_BEGIN then
		str = CommonText[824][4]
		delayTime = 1
		-- showNotice(143,delayTime)
	end
	
end 

function PartyBattleBO.showNotice(sysId,delayTime)
	if PartyBattleMO.noticeShowScheduler_ then
		scheduler.unscheduleGlobal(PartyBattleMO.noticeShowScheduler_)
		PartyBattleMO.noticeShowScheduler_ = nil
	end

	-- 延迟发送，避免多个地方触发，而导致重复发送
	PartyBattleMO.noticeShowScheduler_ = scheduler.performWithDelayGlobal(function()
			-- local notice = {
			-- 	isGm = true,
			-- 	style = 1,
			-- 	msg = str
			-- }
			-- UiUtil.showHorn(notice)
			local chat = {channel = CHAT_TYPE_WORLD, sysId = sysId, style = 1}
			ChatMO.addChat(chat.channel, chat.name, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, 0, nil, false)
			UiUtil.showHorn(chat)
			Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = chat})

		end, delayTime)
end

--处理推送 百团混战 战况
function PartyBattleBO.parseSynReport(name, data)
	if not PartyBattleMO.isOpen then return end

	if not data then return end
	local record = PbProtocol.decodeRecord(data["record"])
	gdump(record, "PartyBattleBO.parseSynReport")

	-- local record = {partyName1 = "11111", name1 = "王大锤", hp1 = 70, partyName2 = "bbbb", name2 = "aaaa", hp2 = 80,result = 2, time = ManagerTimer.getTime(),rank = #PartyBattleMO.cacheBattleProcess}


	PartyBattleMO.cacheBattleProcess[#PartyBattleMO.cacheBattleProcess + 1] = record


	--战斗开始 每1.5秒执行一次 处理推送战况，刷新界面
	if not PartyBattleMO.refreshTimeScheduler_ then
		PartyBattleMO.refreshTimeScheduler_ = scheduler.scheduleGlobal(function()
			gprint("#PartyBattleMO.cacheBattleProcess.." .. #PartyBattleMO.cacheBattleProcess)
			if #PartyBattleMO.cacheBattleProcess > 0 then
				PartyBattleBO.updateBattleProcessView()
			elseif PartyBattleMO.warState == PARTY_BATTLE_STATE_AWARD_END then
				if PartyBattleMO.refreshTimeScheduler_ then
					scheduler.unscheduleGlobal(PartyBattleMO.refreshTimeScheduler_)
					PartyBattleMO.refreshTimeScheduler_ = nil
				end
				str = CommonText[824][5]
				delayTime = 2
				-- showNotice(144,delayTime)
			end
		end, 1.5)  -- 每1.5秒钟执行一次
	end

end

--刷新战况界面
function PartyBattleBO.updateBattleProcessView()
	if not PartyBattleMO.processList.all then
		PartyBattleMO.processList.all = {}
	end
	if not PartyBattleMO.processList.party then
		PartyBattleMO.processList.party = {}
	end
	if not PartyBattleMO.processList.personal then
		PartyBattleMO.processList.personal = {}
	end
	for index=1,#PartyBattleMO.cacheBattleProcess do
		local record = PartyBattleMO.cacheBattleProcess[index]

		--加入全服战报
		--判断战报数量是否超过MAX
		if #PartyBattleMO.processList.all == PARTY_BATTLE_PROCESS_MAX then
			table.remove(PartyBattleMO.processList.all,1)
		end
		table.insert(PartyBattleMO.processList.all,record)

		--如果是自己军团的战报
		
		if PartyMO.partyData_ and PartyMO.partyData_.partyName and 
			(PartyMO.partyData_.partyName == record.partyName1 or PartyMO.partyData_.partyName == record.partyName2) then
			if #PartyBattleMO.processList.party == PARTY_BATTLE_PROCESS_MAX then
				table.remove(PartyBattleMO.processList.party,1)
			end
			table.insert(PartyBattleMO.processList.party,record)
		end

		--如果是个人战报
		if record.name1 and record.name1 ~= "" and record.name2 and record.name2 ~= "" and (UserMO.nickName_ == record.name1 or UserMO.nickName_ == record.name2) then
			-- or (PartyMO.partyData_ and PartyMO.partyData_.partyName and 
			-- (PartyMO.partyData_.partyName == record.partyName1 or PartyMO.partyData_.partyName == record.partyName2)
			-- and record.rank and record.rank > 0) then
			table.insert(PartyBattleMO.processList.personal,record)
		end
	end

	PartyBattleMO.cacheBattleProcess = {}
	Notify.notify(LOCAL_PARTY_BATTLE_PROCESS_UPDATE_EVENT)

end

--百团混战军团成员报名列表
function PartyBattleBO.asynWarMembers(doneCallback)
	local function sortFun(a,b)
		if a.fight == b.fight then
			return a.time < b.time
		else
			return a.fight > b.fight
		end
	end

	------------------测试数据
	-- PartyBattleMO.joinMember = {
	-- 	{time = 10000, name = "王大锤", lv = 1, fight = 20000},
	-- 	{time = 11000, name = "张三", lv = 2, fight = 30000},
	-- 	{time = 12000, name = "李四", lv = 3, fight = 50000},
	-- 	{time = 13000, name = "王五", lv = 4, fight = 70000},
	-- 	{time = 14000, name = "aaaa", lv = 5, fight = 3200}
	-- }
	-- table.sort(PartyBattleMO.joinMember,sortFun)
	-- if doneCallback then doneCallback() end
	-- do return end
	------------------测试数据

	local function parseResult(name, data)
		if table.isexist(data, "memberReg") then
			PartyBattleMO.joinMember = PbProtocol.decodeArray(data["memberReg"])
		else
			PartyBattleMO.joinMember = {}
		end		
		if #PartyBattleMO.joinMember > 0 then
			table.sort(PartyBattleMO.joinMember,sortFun)
		end
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarMembers"))

end

--百团混战参与军团列表
function PartyBattleBO.asynWarParties(doneCallback,page)
	if page == 0 then
		PartyBattleMO.joinParty = {}
	end

	local function sortFun(a,b)
		if a.fight == b.fight then
			return a.lv > b.lv
		else
			return a.fight > b.fight
		end
	end

	------------------测试数据
	-- local list = {
	-- 	{lv = 5, name = "军团1", count = 10, fight = 20000},
	-- 	{lv = 4, name = "军团2", count = 12, fight = 30000},
	-- 	{lv = 3, name = "军团3", count = 13, fight = 50000},
	-- 	{lv = 2, name = "军团4", count = 14, fight = 70000},
	-- 	{lv = 1, name = "军团5", count = 15, fight = 70000},
	-- 	{lv = 5, name = "军团1", count = 10, fight = 20000},
	-- 	{lv = 4, name = "军团2", count = 12, fight = 30000},
	-- 	{lv = 3, name = "军团3", count = 13, fight = 50000},
	-- 	{lv = 2, name = "军团4", count = 14, fight = 70000},
	-- 	{lv = 1, name = "军团5", count = 15, fight = 70000},
	-- 	{lv = 5, name = "军团1", count = 10, fight = 20000},
	-- 	{lv = 4, name = "军团2", count = 12, fight = 30000},
	-- 	{lv = 3, name = "军团3", count = 13, fight = 50000},
	-- 	{lv = 2, name = "军团4", count = 14, fight = 70000},
	-- 	{lv = 1, name = "军团5", count = 15, fight = 70000},
	-- 	{lv = 5, name = "军团1", count = 10, fight = 20000},
	-- 	{lv = 4, name = "军团2", count = 12, fight = 30000},
	-- 	{lv = 3, name = "军团3", count = 13, fight = 50000},
	-- 	{lv = 2, name = "军团4", count = 14, fight = 70000},
	-- 	{lv = 1, name = "军团5", count = 15, fight = 70000}
	-- }
	-- for index = 1,#list do
	-- 	table.insert(PartyBattleMO.joinParty,list[index])
	-- end
	-- table.sort(PartyBattleMO.joinParty,sortFun)
	-- PartyBattleMO.joinPartyTotal = 40
	-- Notify.notify(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT,{page = page,count = #list})
	-- if doneCallback then doneCallback() end
	-- do return end
	------------------测试数据

	local function parseResult(name, data)
		local list
		if table.isexist(data, "partyReg") then
			list = PbProtocol.decodeArray(data["partyReg"])
			for index = 1,#list do
				table.insert(PartyBattleMO.joinParty,list[index])
			end
		else
			list = {}
		end
		if table.isexist(data, "total") then
			PartyBattleMO.joinPartyTotal = data["total"]
		end

		if #PartyBattleMO.joinParty > 0 then
			table.sort(PartyBattleMO.joinParty,sortFun)
		end
		Notify.notify(LOCAL_PARTY_BATTLE_JOIN_UPDATE_EVENT,{page = page,count = #list})
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarParties",{page = page}))

end

--百团混战战况
function PartyBattleBO.asynWarReport(doneCallback,type)
	------------------测试数据
	-- local list = {
	-- 		{partyName1 = "XXX", name1 = "ggf", hp1 = 90, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 0, time = 10000},
	-- 		{partyName1 = "XXX", name1 = "王大锤", hp1 = 80, partyName2 = "天朝", name2 = "叫兽", hp2 = 40,result = 1, time = 11000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "ggf", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "叫兽", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "ggf", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "叫兽", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "ggf", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "叫兽", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "ggf", hp2 = 80,result = 2, time = 50000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "叫兽", hp2 = 80,result = 2, time = 50000,rank = 2},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 2, time = 50000, rank = 1}
	-- 	}
	-- if type == 1 then
		
	-- 	PartyBattleMO.processList.all = list
	-- 	gdump(PartyBattleMO.processList.all,"PartyBattleMO.processList.all===")
	-- elseif type == 2 then
	-- 	list = {
	-- 		{partyName1 = "XXX", name1 = "ggf", hp1 = 90, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 0, time = 10000},
	-- 		{partyName1 = "XXX", name1 = "王大锤", hp1 = 80, partyName2 = "天朝", name2 = "叫兽", hp2 = 40,result = 1, time = 11000},
	-- 	}
	-- 	PartyBattleMO.processList.party = list
	-- elseif type == 3 then
	-- 	list = {
	-- 		{partyName1 = "XXX", name1 = "ggf", hp1 = 90, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 0, time = 10000},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "XXX", name2 = "叫兽", hp2 = 80,result = 2, time = 50000,rank = 2},
	-- 		{partyName1 = "天团", name1 = "王大锤", hp1 = 70, partyName2 = "天朝", name2 = "叫兽", hp2 = 80,result = 2, time = 50000, rank = 1}
	-- 	}
	-- 	PartyBattleMO.processList.personal = list
	-- end
	

	-- if doneCallback then doneCallback() end
	-- do return end
	------------------测试数据

	local function parseResult(name, data)
		local list
		if table.isexist(data, "record") then
			list = PbProtocol.decodeArray(data["record"])
			-- local function sortFun(a,b)
			-- 	return a.time < b.time
			-- end
			-- table.sort(list,sortFun)
		else
			list = {}
		end		
		gdump(list,"PartyBattleMO.processList.party==")
		if type == PARTY_BATTLE_PROCESS_TYPE_ALL then
			PartyBattleMO.processList.all = list
		elseif type == PARTY_BATTLE_PROCESS_TYPE_PARTY then
			PartyBattleMO.processList.party = list

		elseif type == PARTY_BATTLE_PROCESS_TYPE_PERSONAL then
			PartyBattleMO.processList.personal = list
		end

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarReport",{type = type}))

end


--百团混战 报名
function PartyBattleBO.asynWarReg(doneCallback, formation,fight)
	------------------测试数据
	-- local data = {time = ManagerTimer.getTime(),name = UserMO.nickName_,lv = UserMO.level_,fight = fight}
	-- table.insert(PartyBattleMO.joinMember,data)
	-- Notify.notify(LOCAL_PARTY_BATTLE_SIGN_UPDATE_EVENT)
	-- if doneCallback then doneCallback()  return end
	------------------测试数据

	local function parseResult(name, data)
		local data1 = {time = ManagerTimer.getTime(),name = UserMO.nickName_,lv = UserMO.level_,fight = data.fight}
		table.insert(PartyBattleMO.joinMember,data1)

		-- if table.isexist(data, "army") then
		-- 	PartyBattleMO.myArmy = PbProtocol.decodeRecord(data["army"])
		-- 	ArmyBO.updateArmy(PartyBattleMO.myArmy)
		-- else
		-- 	PartyBattleMO.myArmy = nil
		-- end

		-- -- 减少坦克
		-- local stastFormat = TankBO.stasticsFormation(formation)
		-- local res = {}
		-- for tankId, count in pairs(stastFormat.tank) do
		-- 	res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
		-- end
		-- UserMO.reduceResources(res)

		scheduler.performWithDelayGlobal(function()
				ArmyBO.asynGetArmy(function()
						TankBO.asynGetTank()
						Notify.notify(LOCAL_PARTY_BATTLE_SIGN_UPDATE_EVENT)
						if doneCallback then doneCallback() end
					end)
			end, 0.99)
	end

	local format = CombatBO.encodeFormation(formation)

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarReg",{form = format,fight = fight}))

end

--百团混战 取消报名
function PartyBattleBO.asynWarCancel(doneCallback)
	------------------测试数据
	-- local findIndex
	-- for index=1,#PartyBattleMO.joinMember do
	-- 	local member = PartyBattleMO.joinMember[index]
	-- 	if member.name == UserMO.nickName_ then
	-- 		findIndex = index
	-- 		break
	-- 	end
	-- end
	-- if findIndex then
	-- 	table.remove(PartyBattleMO.joinMember,findIndex)
	-- end
	-- PartyBattleMO.myArmy = nil
	-- Notify.notify(LOCAL_PARTY_BATTLE_SIGN_UPDATE_EVENT)
	-- if doneCallback then doneCallback() end
	-- do return end
	------------------测试数据

	local function parseResult(name, data)
		local findIndex
		for index=1,#PartyBattleMO.joinMember do
			local member = PartyBattleMO.joinMember[index]
			if member.name == UserMO.nickName_ then
				findIndex = index
				break
			end
		end
		if findIndex then
			table.remove(PartyBattleMO.joinMember,findIndex)
		end
		scheduler.performWithDelayGlobal(function()
				ArmyBO.asynGetArmy(function()
						TankBO.asynGetTank()
						Notify.notify(LOCAL_PARTY_BATTLE_SIGN_UPDATE_EVENT)
						if doneCallback then doneCallback() end
					end)
			end, 0.99)
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarCancel"))
end

--百团混战连胜排名列表
function PartyBattleBO.asynWarWinRank(doneCallback)
	------------------测试数据
	-- PartyBattleMO.rankWin = {
	-- 	{rank = 1,name = "aaa", winCount = 10, fight = 10000},
	-- 	{rank = 2,name = "aaa", winCount = 9, fight = 9000},
	-- 	{rank = 3,name = "aaa", winCount = 8, fight = 8000},
	-- 	{rank = 4,name = "aaa", winCount = 7, fight = 5555},
	-- 	{rank = 4,name = "aaa", winCount = 7, fight = 5555},
	-- 	{rank = 4,name = "aaa", winCount = 7, fight = 5555},
	-- 	{rank = 4,name = "aaa", winCount = 7, fight = 5555},
	-- 	{rank = 4,name = "aaa", winCount = 7, fight = 5555}
	-- }
	-- PartyBattleMO.myRankWin = {rank = -1,name = "aaa", winCount = 10, fight = 10000}

	-- if doneCallback then doneCallback() return end
	------------------测试数据

	local function parseResult(name, data)

		PartyBattleMO.myRankWin = nil
		if table.isexist(data, "winRank") then
			PartyBattleMO.rankWin = PbProtocol.decodeArray(data["winRank"])
			for index=1,#PartyBattleMO.rankWin do
				local rankData = PartyBattleMO.rankWin[index]
				if rankData.name == UserMO.nickName_ then
					PartyBattleMO.myRankWin = rankData
					break
				end
			end
		else
			PartyBattleMO.rankWin = {}
		end		

		gdump(data,"PartyBattleBO.asynWarWinRank .. data=======")
		if not PartyBattleMO.myRankWin and table.isexist(data, "winCount") and table.isexist(data, "fight") then
			if data.fight > 0 then
				PartyBattleMO.myRankWin = {rank = -1,name = UserMO.nickName_, winCount = data.winCount, fight = data.fight}
			end
		end	

		if table.isexist(data, "canGet") then
			PartyBattleMO.rankWinGet = data["canGet"]
		else
			PartyBattleMO.rankWinGet = false
		end


		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarWinRank"))

end

--百团混战领取个人连胜排行奖励
function PartyBattleBO.asynWarWinAward(doneCallback)
	local function parseResult(name, data)
		local awards
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
		end		
		if awards then
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end
		PartyBattleMO.rankWinGet = false
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarWinAward"))
end

--百团混战军团排名列表
function PartyBattleBO.asynWarRank(doneCallback,page)
	if page == 0 then
		PartyBattleMO.rankParty = {}
	end

	------------------测试数据
	-- local list = {}
	-- for index = 1,20 do
	-- 	list[#list + 1] = {rank = index + page * 20,partyName = "aaa", count = 10, fight = 10000}
	-- end
	

	-- for index = 1,#list do
	-- 	table.insert(PartyBattleMO.rankParty,list[index])
	-- end
	-- PartyBattleMO.myRankParty = {rank = 1,partyName = "aaadd", count = 10, fight = 9999}
	-- Notify.notify(LOCAL_PARTY_BATTLE_RANK_UPDATE_EVENT,{page = page,count = #list})

	-- if doneCallback then doneCallback() return end
	------------------测试数据

	local function parseResult(name, data)
		local list
		if table.isexist(data, "warRank") then
			list = PbProtocol.decodeArray(data["warRank"])
			gdump(list,"PartyBattleBO.asynWarRank..warRank")
			for index = 1,#list do
				table.insert(PartyBattleMO.rankParty,list[index])
			end
		else
			list = {}
		end

		--排序
		local function sortFun(a,b)
			return a.rank < b.rank
		end
		table.sort(PartyBattleMO.rankParty,sortFun)

		if table.isexist(data, "selfParty") then
			PartyBattleMO.myRankParty = PbProtocol.decodeRecord(data["selfParty"])
		else
			PartyBattleMO.myRankParty = nil
		end	

		Notify.notify(LOCAL_PARTY_BATTLE_RANK_UPDATE_EVENT,{page = page,count = #list})
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("WarRank",{page = page}))

end

function PartyBattleBO.asynGetWarFight(doneCallback,index)
	local function parseResult(name, data)
		local rptAtkWar
		if table.isexist(data, "rpt") then
			rptAtkWar = PbProtocol.decodeRecord(data["rpt"])
			local record = rptAtkWar.record
			local result = rptAtkWar.result
			if result then  -- 胜利
				CombatMO.curBattleStar_ = 3
			else
				CombatMO.curBattleStar_ = 0
			end

			gdump(record, "ReportArenaView replayHandler")

			CombatMO.curBattleNeedShowBalance_ = false
			CombatMO.curBattleCombatUpdate_ = 0
			CombatMO.curBattleAward_ = nil
			CombatMO.curBattleStatistics_ = {}

			CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
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

			local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)
		end

		if doneCallback then doneCallback(rptAtkWar) end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetWarFight",{index = index}))
end


function PartyBattleBO.asynGetPartyAmyProps(doneCallback)
	------------------测试数据
	-- PartyBattleMO.battleAwards = {
	-- 	{propId = 1,count = 100},
	-- 	{propId = 2,count = 10},
	-- 	{propId = 3,count = 1},
	-- 	{propId = 4,count = 1}
	-- }
	-- if doneCallback then doneCallback() return end
	------------------测试数据

	local function parseResult(name, data)
		PartyBattleMO.battleAwards = {}
		if table.isexist(data, "prop") then
			PartyBattleMO.battleAwards = PbProtocol.decodeArray(data["prop"])
		end
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPartyAmyProps"))
end

function PartyBattleBO.asynSendPartyAmyProp(doneCallback,sendId,sendCount,sendProp)

	local function parseResult(name, data)
		if table.isexist(data, "prop") then
			local newProp = PbProtocol.decodeRecord(data["prop"])
			local delIndex
			for index = 1,#PartyBattleMO.battleAwards do
				local prop = PartyBattleMO.battleAwards[index]
				if prop.propId == newProp.propId then
					if newProp.count > 0 then
						prop.count = newProp.count
					else
						delIndex = index
					end
					break
				end
			end
			if delIndex then
				table.remove(PartyBattleMO.battleAwards,delIndex)
			end
		end
		Notify.notify(LOCAL_PARTY_BATTLE_AWARD_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end

	local prop = {
		propId = sendProp.propId,
		count = sendCount
	}

	SocketWrapper.wrapSend(parseResult, NetRequest.new("SendPartyAmyProp",{sendId = sendId,prop = prop}))
end


function PartyBattleBO.asynUseAmyProp(doneCallback,propId,settingNum)
	local function parseResult(name, data)
		local res = {}
		gdump(data, "data====================")
		--宝箱
		res[#res + 1] = {kind = ITEM_KIND_PROP, count = settingNum, id = propId}

		if #res > 0 then
			gdump(res,"res==")
			UserMO.reduceResources(res)
		end
		
		--获得奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end

	local prop = {
		propId = propId,
		count = settingNum
	}
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UseAmyProp",{prop = prop}))
end





function PartyBattleBO.getProcessDataBytype(type)
	local list
	if type == PARTY_BATTLE_PROCESS_TYPE_ALL then
		list = PartyBattleMO.processList.all
	elseif type == PARTY_BATTLE_PROCESS_TYPE_PARTY then
		list = PartyBattleMO.processList.party
	elseif type == PARTY_BATTLE_PROCESS_TYPE_PERSONAL then
		list = PartyBattleMO.processList.personal
	end
	return list
end

--军团战报名状态   0 未开始 1 报名 2开打
function PartyBattleBO.getBattleStatus()

	--当前系统时间
	local date = os.date("*t", ManagerTimer.getTime() - 5)
	local wday = date.wday
	local hour = date.hour
	local min = date.min
	local sec = date.sec

	local today
	if wday == 1 then
		today = 7
	else
		today = wday - 1
	end
	local openDays = PARTY_BATTLE_TIME_DAY
	for i=1,#openDays do
		if openDays[i] == today then 
			if hour == PARTY_BATTLE_TIME_HOUR then
				if min >= PARTY_BATTLE_TIME_MIN[1] and min < PARTY_BATTLE_TIME_MIN[2] then
					local t1 = os.time(date)
					local tab = {year=date.year, month=date.month, day=date.day, hour=PARTY_BATTLE_TIME_HOUR, min=PARTY_BATTLE_TIME_MIN[2],sec=0}
					local t2 = os.time(tab)
					local cd = os.difftime(t2,t1);
					return {stage = 1,cd = cd}
				elseif min >= PARTY_BATTLE_TIME_MIN[2] and min < PARTY_BATTLE_TIME_MIN[2] + 5 then
					local t1 = os.time(date)
					local tab = {year=date.year, month=date.month, day=date.day, hour=PARTY_BATTLE_TIME_HOUR, min=PARTY_BATTLE_TIME_MIN[2] + 4,sec=55}
					local t2 = os.time(tab)
					local cd = os.difftime(t2,t1);
					return {stage = 2,cd = cd}
				end
			elseif hour == PARTY_BATTLE_TIME_HOUR + 1 and min >= 0 and min < 30 then
				return {stage = 3}
			end
		end
	end
	return {stage = 0}
end

--获取军团战进程1

function PartyBattleBO.getBattleStage()
	--当前系统时间
	local date = os.date("*t", ManagerTimer.getTime() - 5)
	local wday = date.wday
	local hour = date.hour
	local min = date.min
	local sec = date.sec

	local today
	if wday == 1 then
		today = 7
	else
		today = wday - 1
	end
	local openDays = PARTY_BATTLE_TIME_DAY
	for i=1,#openDays do
		if openDays[i] == today then 
			if hour == PARTY_BATTLE_TIME_HOUR then
				if min == PARTY_BATTLE_TIME_MIN[1] and sec == 0 then
					return 1
				elseif min == 50 and sec == 0 then
					return 2
				elseif min == PARTY_BATTLE_TIME_MIN[2] and sec == 0 then
					return 3
				end
			end

			-- if hour == 16 then
			-- 	if min == 39 and sec == 0 then
			-- 		return 1
			-- 	elseif min == 40 and sec == 0 then
			-- 		return 2
			-- 	elseif min == 41 and sec == 0  then
			-- 		return 3
			-- 	end
			-- end
		end
	end
	return 0
end

--是否已报名
function PartyBattleBO.haveSign()
	for index=1,#PartyBattleMO.joinMember do
		local member = PartyBattleMO.joinMember[index]
		if member.name == UserMO.nickName_ then
			return true
		end
	end
	return false
end

function PartyBattleBO.getPersonalReport()
	local list = {}
	if PartyBattleMO.processList.personal then
		for index=1,#PartyBattleMO.processList.personal do
			local process = PartyBattleMO.processList.personal[index]
			if UserMO.nickName_ == process.name1 or UserMO.nickName_ == process.name2 then
				list[#list + 1] = process
			end
		end
	end
	-- local function sortFun(a,b)
	-- 	return a.time < b.time
	-- end
	-- table.sort(list,sortFun)
	return list
end

function PartyBattleBO.getFortressRank(rhand)
	local function parseResult(name, data)
		PartyBattleBO.fortressJifen = data.jifen or 0
		PartyBattleBO.fortressRank = data.rank or 0
		rhand()
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetThisWeekMyWarJiFenRank"))
end