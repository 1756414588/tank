
StaffBO = {}

function StaffBO.getMineAt(pos)
	local minPos = pos.y * MILITARY_AREA_SIZE_WIDTH + pos.x

	return StaffMO.queryMineByPos(minPos)
end

function StaffBO.isMilitaryAreaOpen()
	local date = os.date("*t", ManagerTimer.getTime())
	local wday = date.wday

	local today = 0
	if wday == 1 then
		today = 7
	else
		today = wday - 1
	end

	-- 周六和周天全天开启
	if today == 6 or today == 7 then return true
	else return false end
end

-- 购买掠夺次数消耗的金币数量
function StaffBO.getBuyPlunderTake()
	return (StaffMO.plunderBuy_ + 1) * 5
end

function StaffBO.getStaffingAttrData()
	if UserMO.staffing_ == 0 then
		return {}
	end

	local staff = StaffMO.queryStaffById(UserMO.staffing_)

	local attrDatas = json.decode(staff.attr)
	if attrDatas then
		local ret = {}

		for index = 1, #attrDatas do
			local attrData = attrDatas[index]
			local attr = AttributeBO.getAttributeData(attrData[1], attrData[2])
			
			if not ret[attr.index] then ret[attr.index] = attr
			else ret[attr.index].value = ret[attr.index].value + attr.value end
		end
		return ret
	else
		return {}
	end
end

function StaffBO.updateGetStaffing(data)
	if not data then return end
	StaffMO.hasData_ = true
	StaffMO.ranking_ = data.ranking
	StaffMO.worldLv_ = data.worldLv
end

function StaffBO.updateGetSeniorMap(data)
	if not data then return end

	local mapData = PbProtocol.decodeArray(data["data"])
	gdump(mapData, "GetSeniorMap, mapData")

	StaffMO.mapData_ = {}
	for index = 1, #mapData do
		local freeTime = 0
		local tmpMap = mapData[index]
		if table.isexist(tmpMap, "freeTime") then freeTime = tmpMap["freeTime"] end

		StaffMO.mapData_[tmpMap.pos] = {pos = tmpMap.pos, name = tmpMap.name, party = tmpMap.party, freeTime = freeTime, my = tmpMap.my}
	end

	StaffMO.plunderCount_ = data.count -- 剩余掠夺次数
	StaffMO.plunderLimit_ = data.limit -- 掠夺次数限制(值等于5)
	StaffMO.plunderBuy_ = data.buy -- 已购买掠夺的次数

	-- Notify.notify(LOCAL_MILITARY_AREA_UPDATE_EVENT)
	Notify.notify(LOCAL_PLUNDER_UPDATE_EVENT)
end

function StaffBO.parseSynStaffing(name, data)
	gdump(data, "StaffBO.parseSynStaffing ===================")

	UserMO.staffing_ = data.staffing
	UserMO.staffingLv_ = data.staffingLv
	UserMO.staffingExp_ = data.staffingExp

	Notify.notify(LOCAL_STAFF_UPDATE_EVENT)
end

function StaffBO.asynGetStaffing(doneCallback)
	function parseGetStaffing(name, data)
		StaffBO.updateGetStaffing(data)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetStaffing, NetRequest.new("GetStaffing"))
end

function StaffBO.asynGetSeniorMap(doneCallback)
	function parseGetSeniorMap(name, data)
		-- gdump(data, "GetSeniorMap")
		StaffBO.updateGetSeniorMap(data)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetSeniorMap, NetRequest.new("GetSeniorMap"))
end

-- type: 1.掠夺 2.占领
function StaffBO.asynAtkSeniorMine(doneCallback, x, y, formation, type)
	function parseAtkSeniorMine(name, data)
		gdump(data, "[StaffBO] attack pos")
		
		UserMO.reduceCycleResource(ITEM_KIND_POWER, COMBAT_TAKE_POWER)

		local army = PbProtocol.decodeRecord(data["army"])
		if army then  -- 攻击胜利，有部队采集
			ArmyBO.updateArmy(army)

			Notify.notify(LOCAL_ARMY_EVENT, {force = true})  -- 强制显示第二页
		else
            UiDirector.pop()
		end

		if table.isexist(data, "count") then
			StaffMO.plunderCount_ = data["count"]
			Notify.notify(LOCAL_PLUNDER_UPDATE_EVENT)
		end

		Notify.notify(LOCAL_MILITARY_AREA_UPDATE_EVENT)  -- 重新获得军事矿区的地图数据

		TankBO.asynGetTank()
		UserBO.asynGetLord(function(awards) UiUtil.showAwards({awards = awards}) end)
		UserBO.asynGetResouce()

		if doneCallback then doneCallback() end
	end

	local pos = StaffMO.encodePosition(x, y)
	local format = CombatBO.encodeFormation(formation)

	SocketWrapper.wrapSend(parseAtkSeniorMine, NetRequest.new("AtkSeniorMine", {pos = pos, form = format, type = type}))
end

function StaffBO.asynSctSeniorMine(doneCallback, x, y)
	function parseSctSeniorMine(name, data)
		local mail = PbProtocol.decodeRecord(data["mail"])
		local mail = MailBO.parseMail(mail)
		-- gdump(mail, "[StaffBO] scout pos")

		-- 扣除宝石
		local mine = StaffBO.getMineAt(cc.p(x, y))
		local scout = WorldMO.queryScout(mine.lv)
		UserMO.reduceResource(ITEM_KIND_RESOURCE, scout.scoutCost, RESOURCE_ID_STONE)
		UserMO.scout_ = UserMO.scout_ + 1
		if doneCallback then doneCallback(mail) end
	end

	local pos = StaffMO.encodePosition(x, y)

	SocketWrapper.wrapSend(parseSctSeniorMine, NetRequest.new("SctSeniorMine", {pos = pos}))
end

function StaffBO.asynBuySenior(doneCallback)
	local function parseBuySenior(name, data)
		StaffMO.plunderCount_ = data.count -- 剩余掠夺次数
		StaffMO.plunderBuy_ = data.buy -- 已购买掠夺的次数

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		Notify.notify(LOCAL_PLUNDER_UPDATE_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuySenior, NetRequest.new("BuySenior"))
end

function StaffBO.asynScoreRank(doneCallback)
	local function parseScoreRank(name, data)
		local rankDatas = PbProtocol.decodeArray(data["scoreRank"])

		StaffMO.rankPerson_ = data.rank
		StaffMO.rankPersonReceive_ = data.canGet
		StaffMO.rankPersonScore_ = data.score

		if doneCallback then doneCallback(rankDatas) end
	end

	SocketWrapper.wrapSend(parseScoreRank, NetRequest.new("ScoreRank"))
end

function StaffBO.asynScorePartyRank(doneCallback)
	local function parseScorePartyRank(name, data)
		local rankDatas = PbProtocol.decodeArray(data["scoreRank"])

		StaffMO.rankParty_ = data.rank
		StaffMO.rankPartyReceive_ = data.canGet
		StaffMO.rankPartyScore_ = data.score

		if doneCallback then doneCallback(rankDatas) end
	end

	SocketWrapper.wrapSend(parseScorePartyRank, NetRequest.new("ScorePartyRank"))
end

function StaffBO.asynScoreAward(doneCallback)
	local function parseScoreAward(name, data)
		StaffMO.rankPersonReceive_ = 2

		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end

	SocketWrapper.wrapSend(parseScoreAward, NetRequest.new("ScoreAward"))
end

function StaffBO.asynPartyScoreAward(doneCallback)
	local function parsePartyScoreAward(name, data)
		StaffMO.rankPartyReceive_ = 2

		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end
		
		if doneCallback then doneCallback(statsAward) end
	end

	SocketWrapper.wrapSend(parsePartyScoreAward, NetRequest.new("PartyScoreAward"))
end

--文官入驻信息
function StaffBO.updateStaffHeros(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local staffHero = PbProtocol.decodeArray(data["heroPut"])
		StaffMO.staffHerosData_ = staffHero
		if rhand then
			rhand()
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetHeroPutInfo"))
end

--请求跨服军事矿区地图
function StaffBO.asynGetCrossSeniorMap(doneCallback)
	function parseGetCrossSeniorMap(name, data)
		-- gdump(data, "GetCrossSeniorMap")
		StaffBO.updateGetCrossSeniorMap(data)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetCrossSeniorMap, NetRequest.new("GetCrossSeniorMap"))
end

--接续获取到的跨服军事矿区地图
function StaffBO.updateGetCrossSeniorMap(data)
	if not data then return end

	local mapData = PbProtocol.decodeArray(data["data"])
	-- gdump(mapData, "GetCrossSeniorMap, mapData")

	StaffMO.CrossmapData_ = {}
	for index = 1, #mapData do
		local freeTime = 0
		local tmpMap = mapData[index]
		gdump(tmpMap, "tmpMap")
		if table.isexist(tmpMap, "freeTime") then freeTime = tmpMap["freeTime"] end

		StaffMO.CrossmapData_[tmpMap.pos] = {pos = tmpMap.pos, name = tmpMap.name, party = tmpMap.party, freeTime = freeTime, my = tmpMap.my}
	end

	StaffMO.plunderCount_ = data.count -- 剩余掠夺次数
	StaffMO.plunderLimit_ = data.limit -- 掠夺次数限制(值等于5)
	StaffMO.plunderBuy_ = data.buy -- 已购买掠夺的次数

	-- Notify.notify(LOCAL_MILITARY_AREA_UPDATE_EVENT)
	Notify.notify(LOCAL_CROSS_PLUNDER_UPDATE_EVENT)
end

function StaffBO.getCrossMineAt(pos)
	local minPos = pos.y * CROSS_SERVER_MILITARY_AREA_SIZE_WIDTH + pos.x

	return StaffMO.queryCrossMineByPos(minPos)
end

--跨服军事矿区侦察指定位置
function StaffBO.asynSctCrossSeniorMine(doneCallback, x, y)
	function parseSctCrossSeniorMine(name, data)
		local mail = PbProtocol.decodeRecord(data["mail"])
		local mail = MailBO.parseMail(mail)
		gdump(mail, "[StaffBO] scout pos")

		-- 扣除宝石
		local mine = StaffBO.getCrossMineAt(cc.p(x, y))
		local scout = WorldMO.queryScout(mine.lv)
		UserMO.reduceResource(ITEM_KIND_RESOURCE, scout.scoutCost, RESOURCE_ID_STONE)
		UserMO.scout_ = UserMO.scout_ + 1
		if doneCallback then doneCallback(mail) end
	end

	local pos = StaffMO.encodeCrossPosition(x, y)
	-- gdump("[StaffBO] scout pos==========="..pos)
	SocketWrapper.wrapSend(parseSctCrossSeniorMine, NetRequest.new("SctCrossSeniorMine", {pos = pos}))
end

--跨服军事矿区
-- type: 1.掠夺 2.占领
function StaffBO.asynAtkCrossSeniorMine(doneCallback, x, y, formation, type)
	function parseAtkCrossSeniorMine(name, data)
		gdump(data, "[StaffBO] attack pos")
		
		UserMO.reduceCycleResource(ITEM_KIND_POWER, COMBAT_TAKE_POWER)

		local army = PbProtocol.decodeRecord(data["army"])
		if army then  -- 攻击胜利，有部队采集
			ArmyBO.updateArmy(army)

			Notify.notify(LOCAL_ARMY_EVENT, {force = true})  -- 强制显示第二页
		else
            UiDirector.pop()
		end

		if table.isexist(data, "count") then
			StaffMO.plunderCount_ = data["count"]
			Notify.notify(LOCAL_CROSS_PLUNDER_UPDATE_EVENT)
		end

		Notify.notify(LOCAL_CROSS_MILITARY_AREA_UPDATE_EVENT)  -- 重新获得军事矿区的地图数据

		TankBO.asynGetTank()
		UserBO.asynGetLord(function(awards) UiUtil.showAwards({awards = awards}) end)
		UserBO.asynGetResouce()

		if doneCallback then doneCallback() end
	end

	local pos = StaffMO.encodeCrossPosition(x, y)
	local format = CombatBO.encodeFormation(formation)

	SocketWrapper.wrapSend(parseAtkCrossSeniorMine, NetRequest.new("AtkCrossSeniorMine", {pos = pos, form = format, type = type}))
end


function StaffBO.asynCrossScoreRank(doneCallback)
	local function parseCrossScoreRank(name, data)
		local rankDatas = PbProtocol.decodeArray(data["scoreRank"])
		if table.isexist(data, "rank") then 
			StaffMO.CrossServerrankPerson_ = data.rank
		end
		if table.isexist(data, "canGet") then 
			StaffMO.CrossServerrankPersonReceive_ = data.canGet
		end
		if table.isexist(data, "score") then 
			StaffMO.CrossServerrankPersonScore_ = data.score
		end
		if doneCallback then doneCallback(rankDatas) end
	end

	SocketWrapper.wrapSend(parseCrossScoreRank, NetRequest.new("CrossScoreRank"))
end

function StaffBO.asynCrossScoreServerRank(doneCallback)
	local function parseCrossScoreServerRank(name, data)
		local rankDatas = PbProtocol.decodeArray(data["scoreRank"])

		if table.isexist(data, "canGet") then 
			StaffMO.CrossServerrankServerReceive_ = data.canGet
		end

		if table.isexist(data, "score") then 
			StaffMO.CrossServerrankServerScore_ = data.score
		end

		if table.isexist(data, "rank") then 
			StaffMO.CrossServerrankServer_ = data.rank
		end

		-- for index = 1, #rankDatas do
		-- 	local rankdata = rankDatas[index]
		-- 	if rankdata.fight == GameConfig.areaId then
		-- 		StaffMO.CrossServerrankServer_ = index
		-- 		break
		-- 	end
		-- end
		-- StaffMO.CrossServerrankServer_ = data.rank
		-- StaffMO.CrossServerrankServerScore_ = data.score

		if doneCallback then doneCallback(rankDatas) end
	end

	SocketWrapper.wrapSend(parseCrossScoreServerRank, NetRequest.new("CrossServerScoreRank"))
end

function StaffBO.asynCrossScoreAward(doneCallback)
	local function parseScoreAward(name, data)
		StaffMO.CrossServerrankPersonReceive_ = 2

		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end

	SocketWrapper.wrapSend(parseScoreAward, NetRequest.new("CrossScoreAward"))
end

function StaffBO.asynCrossServerScoreAward(doneCallback)
	local function parsePartyScoreAward(name, data)
		StaffMO.CrossServerrankServerReceive_ = 2

		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end
		
		if doneCallback then doneCallback(statsAward) end
	end

	SocketWrapper.wrapSend(parsePartyScoreAward, NetRequest.new("CrossServerScoreAward"))
end

function StaffBO.asynCrossServerList(doneCallback)
	local function getResult(name, data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data.info)
		StaffMO.ServerListData_ = list
		
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossServerInfo"))
end

function StaffBO.IsCrossServerMineAreaOpen()
	if HunterMO.teamFightCrossData_.state == 2 then
		return true
	else
		return false
	end
end