
WorldBO = {}

function socket_error_593_callback(code)
	Toast.show(ErrorText.text593 .. "(" .. code .. ")")
	WorldMO.clearMapData_ = true  -- 当进入到地图时，需要清除地图数据
end

function socket_error_620_callback(code)
	Toast.show(ErrorText.text620 .. "(" .. code .. ")")
	WorldMO.mapData_ = {}
	WorldMO.partyMine_ = {}
	WorldMO.mine_ = {}
	WorldMO.areaIndex_ = {}
	WorldMO.warFree_ = {}

	WorldMO.clearMapData_ = false
	
	Notify.notify(LOCAL_CLEAR_MAP_EVENT)
end

function WorldBO.init()
	WorldMO.mapData_ = {}
	WorldMO.partyMine_ = {}
	WorldMO.mine_ = {}
	WorldMO.areaIndex_ = {}
	WorldMO.warFree_ = {}

	local function onTick()
		local viewName = UiDirector.getTopUiName()
		if viewName == "HomeView" then  -- 避免在玩家处理世界相关逻辑时，就把地图删除导致逻辑出错
			WorldMO.mapData_ = {}
			WorldMO.partyMine_ = {}
			WorldMO.mine_ = {}
			WorldMO.areaIndex_ = {}
			WorldMO.warFree_ = {}

			WorldMO.clearMapData_ = false

			Notify.notify(LOCAL_CLEAR_MAP_EVENT)
		else
			WorldMO.clearMapData_ = true  -- 当进入到地图时，需要清除地图数据
		end
	end

	if not WorldMO.reshScheduler_ then
		WorldMO.reshScheduler_ = scheduler.scheduleGlobal(onTick, 300)  -- 每隔一段时间删除客户端所有数据
	end
end

-- 行军到位置pos需要的时间
function WorldBO.getMarchTime(fromPos, toPos)
	local k =1
	if fromPos.x ~= toPos.x then
		if ((fromPos.y - toPos.y) / (fromPos.x - toPos.x)) < 0 then k = -1 end
	end

	-- local time = 180 + math.abs(fromPos.x - toPos.x) + math.abs(fromPos.y - toPos.y)
	local time = 180 + (math.abs(fromPos.x - toPos.x) + math.abs(fromPos.y - k * fromPos.x + k * toPos.x - toPos.y)) * 7.5
	-- print("from:x", fromPos.x, "y", fromPos.y, "to:x", toPos.x, "y", toPos.y, "time:", time, "k:", k)

	local validSenior, _ = EffectBO.getEffectValid(EFFECT_ID_RAPID_MARCH_SENIOR)  -- 飞行军道具的effect
	local valid, _ = EffectBO.getEffectValid(EFFECT_ID_RAPID_MARCH)  -- 急行军道具的effect

	local addition = ScienceBO.speedAddition()  -- 行军加速
	addition = addition + FortressMO.armySpeed()  -- 要塞职位
	addition = addition + LaboratoryBO.getCommonTypeAttrSpeed() -- 作战实验室
	if validSenior then
		return time / (1 + (VipBO.getSpeedArmy() + addition) / 100 + 1.5)
	elseif valid then
		return time / (1 + (VipBO.getSpeedArmy() + addition) / 100 + 1)
	else
		return time / (1 + (VipBO.getSpeedArmy() + addition) / 100)
	end
end

function WorldBO.parseGetMap(name, data)
	-- gdump(data, "[WorldBO] get map 111")
	local maps = PbProtocol.decodeArray(data["data"])

	-- gdump(maps, "[WorldBO] get map 222")

	for index = 1, #maps do
		local map = maps[index]
		local pos = WorldMO.decodePosition(map.pos)

		local index = WorldMO.encodePosition(pos.x, pos.y)
		if not table.isexist(map, "surface") then map["surface"] = 0 end
		if not table.isexist(map, "free") then map["free"] = false end
		if not table.isexist(map, "nameplate") then map["nameplate"] = 0 end
		-- gprint("WorldBO.parseGetMap pos:", map.pos, "x:", pos.x, "y:", pos.y, "index:", index)
		if table.isexist(map, "ruins") then
			local ruins = PbProtocol.decodeRecord(map["ruins"])
			map.ruins = ruins
		end
		WorldMO.setMapDataAt(pos.x, pos.y, map)
	end

	if table.isexist(data, "partyMine") then
		local partyMines = PbProtocol.decodeArray(data["partyMine"]) -- 同一个军团的资源数据
		for index = 1, #partyMines do
			local partyMine = partyMines[index]
			if partyMine.name ~= UserMO.nickName_ then  -- 自己的不算
				local pos = WorldMO.decodePosition(partyMine.pos)
				WorldMO.setPartyMineAt(pos.x, pos.y, partyMine)
			end
		end
	end

	if table.isexist(data, "mineInfo") then
		local info = PbProtocol.decodeRecord(data["mineInfo"]) -- 矿点信息
		local mine = PbProtocol.decodeArray(info.mine)
		for k,v in ipairs(mine) do
			local pos = WorldMO.decodePosition(v.pos)
			WorldMO.setMineAt(pos.x, pos.y, v)
		end
	end

	local area = nil
	if table.isexist(data, "area") then
		area = data.area
	end

	local freeTimeInfo = PbProtocol.decodeArray(data["freeTimeInfo"])
	-- gdump(freeTimeInfo, "parseGetMap freeTimeInfo==")
	if area then
		WorldMO.warFree_[area] = {}
		for i = 1, #freeTimeInfo do
			local f = freeTimeInfo[i]
			local pos = WorldMO.decodePosition(f.pos)
			WorldMO.setWarFreeInfo(pos.x, pos.y, f)
		end
	end

	Loading.getInstance():unshow()

	Notify.notify(LOCAL_GET_MAP_EVENT)
	Notify.notify(LOCAL_MAP_DATE_UPDATE_EVENT)
end

function WorldBO.getMineAt(pos)
	-- local pos = WorldMO.encodePosition(tilePos.x, tilePos.y)
	local x = pos.x % MINE_SIZE_WIDTH
	local y = pos.y % MINE_SIZE_HEIGHT
	local offset = math.floor(pos.x / MINE_SIZE_WIDTH) + math.floor(pos.y / MINE_SIZE_HEIGHT) * 15 -- 15 = WORLD_SIZE_WIDTH / MINE_SIZE_WIDTH
	local minPos = (x + y * MINE_SIZE_WIDTH + MINE_OFFSET_SEED * offset) % 1600  -- 1600 = MINE_SIZE_WIDTH * MINE_SIZE_HEIGHT

	return WorldMO.queryMineByPos(minPos)
end

function WorldBO.getEnvironmentAt(pos)
	local x = pos.x % MINE_SIZE_WIDTH
	local y = pos.y % MINE_SIZE_HEIGHT
	local offset = math.floor(pos.x / MINE_SIZE_WIDTH) + math.floor(pos.y / MINE_SIZE_HEIGHT) * 15 -- 15 = WORLD_SIZE_WIDTH / MINE_SIZE_WIDTH
	local minPos = (x + y * MINE_SIZE_WIDTH + MINE_OFFSET_SEED * offset) % 1600  -- 1600 = MINE_SIZE_WIDTH * MINE_SIZE_HEIGHT

	return WorldMO.queryEnvironmentByPos(minPos)
end

function WorldBO.getPositionStatus(pos)
	local ret = {}
	ret[ARMY_STATE_MARCH] = false
	ret[ARMY_STATE_COLLECT] = false

	local armies = ArmyMO.getAllArmies()
	for index = 1, #armies do
		local army = armies[index]
		if not army.isMilitary and not army.crossMine then
			local armyPos = WorldMO.decodePosition(army.target)
			if armyPos.x == pos.x and armyPos.y == pos.y then
				if army.state == ARMY_STATE_MARCH or army.state == ARMY_STATE_COLLECT then
					ret[army.state] = true
				end
			end
		end
	end
	return ret
end

function WorldBO.findNeerBy(findPos)
	local delta = 20

	local startX = findPos.x - delta
	if startX < 0 then startX = 0 end
	if startX > (WORLD_SIZE_WIDTH - delta) then startX = WORLD_SIZE_WIDTH - delta end

	local endX = startX + delta + delta
	if endX >= WORLD_SIZE_WIDTH then endX = WORLD_SIZE_WIDTH - 1 end

	local startY = findPos.y - delta
	if startY < 0 then startY = 0 end
	if startY > (WORLD_SIZE_HEIGHT - delta) then startY = WORLD_SIZE_HEIGHT - delta end

	local endY = startY + delta + delta
	if endY >= WORLD_SIZE_HEIGHT then endY = WORLD_SIZE_HEIGHT -1 end

	-- gprint('findPos:', findPos.x, findPos.y, "start:", startX, startY, "end:", endX, endY)
	
	local res = {}
	local players = {}
	for indexX = startX, endX do
		for indexY = startY, endY do
			if indexX ~= WorldMO.pos_.x and indexY ~= WorldMO.pos_.y then  -- 剔除玩家自己
				local tilePos = cc.p(indexX, indexY)
				local mine = WorldBO.getMineAt(tilePos)
				if mine then  -- 是矿
					local mine = clone(mine)
					mine.pos = WorldMO.encodePosition(indexX, indexY)
					if not res[mine.type] then res[mine.type] = {} end
					if not res[mine.type][mine.lv] then res[mine.type][mine.lv] = {} end
					res[mine.type][mine.lv][#res[mine.type][mine.lv] + 1] = mine  -- 资源按类型和等级分类
					-- res[mine.type][#res[mine.type] + 1] = mine -- 框
				else
					local mapData = WorldMO.getMapDataAt(tilePos.x, tilePos.y)
					if mapData and not mapData.free then  -- 是玩家
						if not players[mapData.lv] then players[mapData.lv] = {} end
						players[mapData.lv][#players[mapData.lv] + 1] = mapData
						-- players[#players + 1] = mapData
					end
				end
			end
		end
	end
	return res, players
end

function WorldBO.getMoveHomeStatus()
	if ArmyMO.getArmyNum() > 0 then  -- 有部队执行任务
		return 1
	end
	return 0
end

-- force: 强制获得positions里的GetMap数据
function WorldBO.asynGetMp(positions, force, doAtk)
	if not WorldMO.getMapHandler_ then
		-- gprint("WorldBO getMap 注册")
		WorldMO.getMapHandler_ = SocketReceiver.register("GetMap", WorldBO.parseGetMap, true)
	end

	local areas = {}

	for index = 1, #positions do
		local pos = positions[index]
		local area = WorldMO.getAreaInex(pos)

		if force then
			areas[area] = area
		else
			if not WorldMO.areaIndex_[area] or not WorldMO.areaIndex_[area].capture then  -- 从来就没有获得过此area区块的数据
				areas[area] = area
			end
		end
	end

	-- dump(areas, "WorldBO need map areas")

	local needInfo = false --检查区域是否包含要塞信息
	local asks = {}
	if #table.values(areas) > 0 then
		for area, _ in pairs(areas) do
			if area == WorldMO.getAreaInex(FortressMO.pos_) then
				needInfo = true
			end
			table.insert(asks,area)
		end
	end
	-- SocketWrapper.wrapSend(nil, NetRequest.new("GetMap", {area = area}))
	local function getMaps()
		if #asks > 0 then
			Loading.getInstance():show(nil, 3, 1)
			for _, area in ipairs(asks) do
				if not WorldMO.areaIndex_[area] then
					WorldMO.areaIndex_[area] = {}
				end
				WorldMO.areaIndex_[area].capture = true -- 请求了数据

				SocketWrapper.wrapSend(nil, NetRequest.new("GetMap", {area = area}))
			end
		elseif doAtk then --从邮件里面发起攻击
			Loading.getInstance():unshow()
			Toast.show(ErrorText.text593)
		end
	end
	if needInfo then
		FortressBO.getWinParty(getMaps)
	else
		getMaps()
	end
	AirshipBO.getAirship()
	-- local mapData = WorldMO.getMapDataAt(x, y)
	-- if mapData then
	-- 	return mapData
	-- end

	-- local areaX = x % 15
	-- local areaY = y % 15
	-- local area = areaX + areaY * 40

	-- -- local area = WorldMO.encodePosition(x, y)
	-- SocketWrapper.wrapSend(nil, NetRequest.new("GetMap", {area = area}))
end

-- function WorldBO.asynGetMp(x, y)
-- 	if not WorldMO.getMapHandler_ then
-- 		gprint("WorldBO getMap 注册")
-- 		WorldMO.getMapHandler_ = SocketReceiver.register("GetMap", WorldBO.parseGetMap, true)
-- 	end

-- 	local mapData = WorldMO.getMapDataAt(x, y)
-- 	if mapData then
-- 		return mapData
-- 	end

-- 	local areaX = x % 15
-- 	local areaY = y % 15
-- 	local area = areaX + areaY * 40

-- 	-- local area = WorldMO.encodePosition(x, y)
-- 	SocketWrapper.wrapSend(nil, NetRequest.new("GetMap", {area = area}))
-- end

-- 侦查坐标点数据
function WorldBO.asynScoutPos(doneCallback, x, y)
	local function parseScoutPos(name, data)
		local mail = PbProtocol.decodeRecord(data["mail"])
		local mail = MailBO.parseMail(mail)
		gdump(mail, "[WorldBO] scout pos")

		-- 扣除宝石
		local mine = WorldBO.getMineAt(cc.p(x, y))
		if mine then
			local scout = WorldMO.queryScout(mine.lv)
			UserMO.reduceResource(ITEM_KIND_RESOURCE, scout.scoutCost, RESOURCE_ID_STONE)
			UserMO.scout_ = UserMO.scout_ + 1
			WorldBO.asynGetMp({cc.p(x, y)}, true)
			-- 埋点
			Statistics.postPoint(STATIS_SCOUT + mine.type * 100 + mine.lv)
		else
			local mapData = WorldMO.getMapDataAt(x, y) -- 是玩家
			if mapData then
				local scout = WorldMO.queryScout(mapData.lv)
				UserMO.reduceResource(ITEM_KIND_RESOURCE, scout.scoutCost, RESOURCE_ID_STONE)
				UserMO.scout_ = UserMO.scout_ + 1
				-- 埋点
				Statistics.postPoint(STATIS_SCOUT + mapData.lv)
			else
				gprint("WorldBO.asynScoutPos ERROR!!!! x:", x, "y:", y)
			end
		end
		
		if doneCallback then doneCallback(mail) end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[26])
	end

	local pos = WorldMO.encodePosition(x, y)

	-- print("WorldBO.asynScoutPos x:", x, "y:", y, "pos:", pos)
	SocketWrapper.wrapSend(parseScoutPos, NetRequest.new("ScoutPos", {pos = pos}), 1)
end

function WorldBO.asynAttackPos(doneCallback, x, y, formation)
	local mine = WorldBO.getMineAt(cc.p(x, y))
	local mapData = WorldMO.getMapDataAt(x, y)

	local function parseAttackPos(name, data)
		gdump(data, "[WorldBO] attack pos")
		local army = PbProtocol.decodeRecord(data["army"])
		ArmyBO.updateArmy(army)
		ArmyMO.dirtyArmyData_ = false
		
		-- 减少坦克
		local stastFormat = TankBO.stasticsFormation(formation)
		local res = {}
		for tankId, count in pairs(stastFormat.tank) do
			res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
		end
		UserMO.reduceResources(res)

		UserMO.reduceCycleResource(ITEM_KIND_POWER, 1) -- 减少一点体力

		Notify.notify(LOCAL_ARMY_EVENT, {force = true})  -- 强制显示第二页
		
		if mine then
			--任务计数
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_ATTACK_MINE,type = 1})
			--TK统计
			TKGameBO.onEvnt(TKText.eventName[18])
			-- 埋点
			Statistics.postPoint(STATIS_ATTACK + mine.type * 100 + mine.lv)
		elseif mapData then   -- 是玩家
			local myMapData = WorldMO.getMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y)
			if myMapData and not table.isexist(mapData, "heroPick") then  -- 只要是攻打玩家，自身的免战效果则会消失
				myMapData.free = false
			end

			local valid, _ = EffectBO.getEffectValid(EFFECT_ID_FREE_WAR) -- 如果是免战
			if valid and not table.isexist(mapData, "heroPick") then
				EffectBO.setEffectInvalid(EFFECT_ID_FREE_WAR)

				Notify.notify(LOCAL_MAP_FORCE_EVENT)
			end
			if not table.isexist(mapData, "heroPick") then
				ActivityBO.trigger(ACTIVITY_ID_ATTACK, 1)
				--TK统计
				TKGameBO.onEvnt(TKText.eventName[17])
				--任务计数
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_ATTACK_MAN,type = 1})
			end
			-- 埋点
			Statistics.postPoint(STATIS_ATTACK + mapData.lv)
		end

		-- 在攻打完之后更新一下英雄数据
		HeroBO.getHeroCd()

		if doneCallback then doneCallback() end
	end

	ArmyMO.dirtyArmyData_ = true

	local pos = WorldMO.encodePosition(x, y)
	local format = CombatBO.encodeFormation(formation)

	SocketWrapper.wrapSend(parseAttackPos, NetRequest.new("AttackPos", {pos = pos, form = format}))
end

function WorldBO.asynMoveHome(doneCallback, x, y, type)
	local function parseMoveHome(name, data)
		gdump(data, "WorldBO.asynMoveHome")
		local oldPos = WorldMO.pos_
		local mapData = WorldMO.getMapDataAt(oldPos.x, oldPos.y)
		
		WorldMO.setMapDataAt(oldPos.x, oldPos.y, nil)  -- 清除旧的位置数据

		WorldMO.pos_ = WorldMO.decodePosition(data.pos)
		WorldMO.setCurrentPosition(WorldMO.pos_.x, WorldMO.pos_.y)
		
		WorldMO.setMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y, mapData)

		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[31],TKGAME_USERES_TYPE_UPDATE)

			UserMO.updateResource(ITEM_KIND_COIN, data.gold) 
		end

		if type == 2 then  -- 随机迁城
			UserMO.reduceResource(ITEM_KIND_PROP, 1, PROP_ID_MOVE_HOME_RANDOM)
		elseif type == 3 then -- 定点搬家
			UserMO.reduceResource(ITEM_KIND_PROP, 1, PROP_ID_MOVE_HOME_SPECIFY)
		end

		local invasions = ArmyMO.getAllInvasions()
		if #invasions > 0 then -- 清除所有的别人行军
			for index = 1, #invasions do
				local invasion = invasions[index]
				SchedulerSet.remove(invasion.schedulerId)
			end
			ArmyMO.invasion_ = {}
			Notify.notify(LOCAL_ARMY_EVENT)
		end

		local aids = ArmyMO.aid_
		if #aids > 0 then  -- 清除军团成员往自己家驻军的部队
			local find = false
			for index = #aids, 1, -1 do
				local aid = aids[index]
				if aid.state == ARMY_STATE_AID_MARCH then
					SchedulerSet.remove(aid.schedulerId)
					table.remove(ArmyMO.aid_, index)
					find = true
				end
			end
			if find then
				Notify.notify(LOCAL_ARMY_EVENT)
			end
		end

		Notify.notify(LOCAL_LOCATION_EVENT)

		if doneCallback then doneCallback() end
		--TK统计
		TKGameBO.onEvnt(TKText.eventName[25])
	end

	local pos = nil
	if type ~= 2 then
		pos = WorldMO.encodePosition(x, y)
	end
	SocketWrapper.wrapSend(parseMoveHome, NetRequest.new("MoveHome", {pos = pos, type = type}))
end

function WorldBO.asynRetreat(doneCallback, keyId)
	local function parseRetreat(name, data)
		local army = ArmyMO.getArmyByKeyId(keyId)
		ArmyMO.dirtyArmyData_ = false
		if army.isMilitary or army.crossMine then  -- 跨服军事矿区和军事矿区要拉取坦克数据
			ArmyBO.asynGetArmy(function() TankBO.asynGetTank() end)
			UserBO.asynGetResouce()
		elseif army.state >= ARMY_AIRSHIP_MARCH then
			ArmyBO.asynGetArmy(function() TankBO.asynGetTank() end)
		else
			ArmyBO.asynGetArmy(function()
					local tilePos = WorldMO.decodePosition(army.target)
					if WorldBO.getMineAt(tilePos) then  -- 是矿
						WorldBO.asynGetMp({tilePos}, true)
					end
				end)
		end

		if table.isexist(data, "atom2") then
			UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		end

		local gold = 0
		if table.isexist(data, "honourGold") and data.honourGold > 0 then
			UserMO.addResource(ITEM_KIND_COIN, data.honourGold)
			gold = gold + data.honourGold
		end

		if table.isexist(data, "heroGold") and data.heroGold > 0 then
			UserMO.addResource(ITEM_KIND_COIN, data.heroGold)
			gold = gold + data.heroGold
		end

		if gold > 0 then
			v = {kind=ITEM_KIND_COIN, count=gold}
			UiUtil.showAwards({awards = {v}})
		end

		if doneCallback then doneCallback() end
	end

	ArmyMO.dirtyArmyData_ = true

	SocketWrapper.wrapSend(parseRetreat, NetRequest.new("Retreat", {keyId = keyId}))
end

function WorldBO.asynGuardPos(doneCallback, x, y, formation)
	local function parseGuardPos(name, data)
		gdump(data, "[WorldBO] GuiardPos")
		local army = PbProtocol.decodeRecord(data["army"])
		ArmyBO.updateArmy(army)

		-- 减少坦克
		local stastFormat = TankBO.stasticsFormation(formation)
		local res = {}
		for tankId, count in pairs(stastFormat.tank) do
			res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
		end
		UserMO.reduceResources(res)

		Notify.notify(LOCAL_ARMY_EVENT, {force = true})  -- 强制显示第二页
		if doneCallback then doneCallback() end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[20])
	end

	local pos = WorldMO.encodePosition(x, y)
	local format = CombatBO.encodeFormation(formation)
	SocketWrapper.wrapSend(parseGuardPos, NetRequest.new("GuardPos", {pos = pos, form = format}))
end

function WorldBO.asynSetGuard(doneCallback, army)
	local function parseSetGuard(name, data)
		gdump(data, "[WorldBO] setGuard")

		if army.state == ARMY_STATE_WAITTING then -- 当前是正在等待的，转为驻防，还要将其他的驻防转为等待
			for index = 1, #ArmyMO.aid_ do
				local aid = ArmyMO.aid_[index]
				if aid.state == ARMY_STATE_GARRISON then
					aid.state = ARMY_STATE_WAITTING
				end
			end
			army.state = ARMY_STATE_GARRISON
		elseif army.state == ARMY_STATE_GARRISON then -- 当前是正在驻防的，转为等待
			army.state = ARMY_STATE_WAITTING
		else
			gdump(army)
			error("WorldBO.asynSetGuard")
		end

		Notify.notify(LOCAL_ARMY_EVENT)
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseSetGuard, NetRequest.new("SetGuard", {lordId = army.lordId, keyId = army.keyId}))
end

function WorldBO.asynRetreatAid(doneCallback, aid)
	local function parseRetreatAid(name, data)
		gdump(data, "[WorldBO] RetreatAid")

		ArmyMO.removeAid(aid.keyId, aid.lordId)

		Notify.notify(LOCAL_ARMY_EVENT)
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseRetreatAid, NetRequest.new("RetreatAid", {lordId = aid.lordId, keyId = aid.keyId}))
end


function WorldBO.getWorldStaffing(doneCallback)
	local function parseResult(name, data)
		gdump(data, "[WorldBO] getWorldStaffing")
		WorldMO.worldMineExp = data.worldExp
		UserMO.worldMineExpConribDay = data.dayExp

		-- 重新计算世界矿等级
		local level = WorldMO.queryWorldMineLevelByExp(WorldMO.worldMineExp)
		WorldMO.worldMineLevel = level

		if doneCallback then doneCallback(data) end
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetWorldStaffing"))
end


function WorldBO.SynWorldStaffing(name, data)
	-- 同步下个安全区范围
	gdump(data, "WorldBO.SynWorldStaffing==")

	WorldMO.worldMineExp = data.worldExp
	UserMO.worldMineExpConribDay = data.dayExp

	-- 重新计算世界矿等级
	local level = WorldMO.queryWorldMineLevelByExp(WorldMO.worldMineExp)
	WorldMO.worldMineLevel = level

	Notify.notify(LOCAL_WORLD_STAFFING)
end
