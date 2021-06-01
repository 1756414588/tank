
SHOP_KIND_ALL = 1
SHOP_KIND_RESOURCE = 2
SHOP_KIND_GAIN = 3
SHOP_KIND_OTHER = 4

PropBO = {}

function PropBO.update(data)
	PropMO.prop_ = {}
	
	if not data then return end

	local props = PbProtocol.decodeArray(data["prop"])
	-- gdump(props, "[PropBO] update props")
	for index = 1, #props do  -- 
		local prop = props[index]
		PropMO.prop_[prop.propId] = prop
	end

	Notify.notify(LOCAL_PROP_EVENT)

	FactoryBO.clearAllProduct(BUILD_ID_WORKSHOP)

	if data["queue"] then -- 制造车间的生产队列
		local que = PbProtocol.decodeArray(data["queue"])
		for index = 1, #que do
			PropBO.updateQueue(BUILD_ID_WORKSHOP, que[index])
		end
	end
end

function PropBO.updateQueue(buildingId, queue)
	gdump(queue, "[PropBO] updateQueue")

	if queue.state == QUEUE_STATE_PRODUCTING then  -- 队列正在生产
		-- 保证比服务器端时间延后
		local endTime = queue.endTime + 0.99

		local schedulerId = SchedulerSet.add(endTime, {doneCallback = PropBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, propId = queue.propId, count = queue.count, period = queue.period})
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	elseif queue.state == QUEUE_STATE_WAIT then  -- 等待队列
		local schedulerId = SchedulerSet.add(queue.period + ManagerTimer.getTime(), {doneCallback = PropBO.onProductDone, buildingId = buildingId, keyId = queue.keyId, propId = queue.propId, count = queue.count, period = queue.period}, SchedulerSet.STATE_WAIT)
		if schedulerId then
			FactoryBO.addSchedulerProduct(buildingId, schedulerId)
		end
	end
end

function PropBO.onProductDone(schedulerId, set)
	local buildingId = set.buildingId

	gprint("[PropBO] 物资生产结束了:", buildingId, schedulerId)

	local function updateProp()
		local propId = set.propId
		local count = set.count
		UiUtil.showAwards({awards = {{kind = ITEM_KIND_PROP, id = propId, count = count}}})

		Notify.notify(LOCAL_PROP_DONE_EVENT)
	end

	scheduler.performWithDelayGlobal(function() PropBO.asynGetProp(updateProp) end, 1.01)
end

function PropBO.orderProps(propA, propB)
	local propADB = PropMO.queryPropById(propA.propId)
	local propBDB = PropMO.queryPropById(propB.propId)
	if not propADB then return false end
	if not propBDB then return true end

	if propADB.canUse == 1 and propBDB.canUse == 1 then
		if propA.propId < propB.propId then
			return true
		else
			return false
		end
	elseif propADB.canUse == 1 then -- A可以用
		return true
	else  -- B可以使用
		return false
	end
end

-- 获得商城中可以购买的道具
function PropBO.getShopProp(kind)
	local s_prop = PropMO.getTableProp()
	if kind == SHOP_KIND_ALL then
		return DataBase.query(s_prop, {{"canBuy", "=", 1}})
	elseif kind == SHOP_KIND_RESOURCE then
		return DataBase.query(s_prop, {{"tag", "=", 1}, {"canBuy", "=", 1}})
	elseif kind == SHOP_KIND_GAIN then
		return DataBase.query(s_prop, {{"tag", "=", 2}, {"canBuy", "=", 1}})
	elseif kind == SHOP_KIND_OTHER then
		return DataBase.query(s_prop, {{"tag", ">=", 3}, {"tag", "<=", 4}, {"canBuy", "=", 1}})
	end
end

-- 获得积分商店的道具
-- status:1成长；2资源；3成长
function PropBO.getArenaProps(status)
	local s_prop = PropMO.getTableProp()
	if status == 1 then
		return DataBase.query(s_prop, {{"tag", ">=", 2}, {"tag", "<=", 3}, {"arenaScore", ">", 0}})
	elseif status == 2 then
		return DataBase.query(s_prop, {{"tag", "=", 1}, {"arenaScore", ">", 0}})
	elseif status == 3 then
		return DataBase.query(s_prop, {{"tag", "=", 4}, {"arenaScore", ">", 0}})
	end
end

-- 获得当前某个道具可以生产的最大数量
function PropBO.canProductMaxNum(propId)
	local prop = PropMO.queryPropById(propId)
	if not prop then return 0 end

	local stoneNum = GAME_INVALID_VALUE
	if prop.stoneCost > 0 then
		stoneNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) / prop.stoneCost)
	end

	local skillNum = GAME_INVALID_VALUE
	if prop.skillBook > 0 then
		skillNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK) / prop.skillBook)
	end

	local chipNum = GAME_INVALID_VALUE
	if prop.heroChip > 0 then
		chipNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, PROP_ID_HERO_CHIP) / prop.heroChip)
	end

	local max = math.min(stoneNum, math.min(skillNum, chipNum))

	if prop.buildCost then
		local _buildCosts =  json.decode(prop.buildCost)
		local exNum = nil
		for index = 1, #_buildCosts do
			local cost = _buildCosts[index]
			local kind = cost[1]
			local id = cost[2]
			local need = cost[3]
			local num = math.floor(UserMO.getResource(kind, id) / need)
			exNum = exNum and math.min(exNum, num) or num
		end
		if exNum and exNum > 0 then
			max = math.min(max, exNum)
		end
	end

	if max == GAME_INVALID_VALUE then return 0 end

	return max
end

-- 获得由kind和id确定的某种东西可使用的道具
function PropBO.getCanUsePopIds(kind, id)
	if kind == ITEM_KIND_RESOURCE then
		if id == RESOURCE_ID_IRON then return {21, 6, 31, 26, 16, 11}
		elseif id == RESOURCE_ID_OIL then return {22, 7, 32, 27, 17, 12}
		elseif id == RESOURCE_ID_STONE then return {20, 5, 30, 25, 15, 10}
		elseif id == RESOURCE_ID_COPPER then return {23, 8, 33, 28, 18, 13}
		elseif id == RESOURCE_ID_SILICON then return {24, 9, 34, 29, 19, 14}
		else
			return {}
		end
	elseif kind == ITEM_KIND_EFFECT then
		if id == 2 then return {1, 5, 20}  -- 增加宝石50%的基础产量
		elseif id == 3 then return {1, 6, 21}  -- 增加铁50%的基础产量
		elseif id == 4 then return {1, 7, 22}  -- 增加石油50%的基础产量
		elseif id == 5 then return {1, 8, 23}
		elseif id == 6 then return {1, 9, 24}
		elseif id == 7 then return {35, 39, 43} -- 增加己方部队20%伤害
		elseif id == 8 then return {36, 40, 44}  -- 降低地方部队20%伤害
		elseif id == 9 then return {37, 41, 45}  -- 部队在世界地图行军速度提升100%.
		elseif id == 10 then return {38, 42, 46}  -- 保护基地免受攻击/侦查.攻击他人后状态取消
		elseif id == 12 then return {1}
		elseif id == 18 then return {1}
		elseif id == 19 then return {151,154}
		elseif id == 20 then return {152,155}
		elseif id == 21 then return {153,156}	
		else return {}
		end
	elseif kind == ITEM_KIND_ACCEL then
		if id == ACCEL_ID_BUILD then return {72, 75, 78, 210} -- 建筑加速
		elseif id == ACCEL_ID_TANK then return {73, 76, 79, 211}
		elseif id == ACCEL_ID_REFIT then return {}
		elseif id == ACCEL_ID_PRODUCT then return {}
		elseif id == ALLEL_ID_SCIENCE then return {74, 77, 80, 212}
		else return {} end
	else
		return {}
	end
end

-- 将部分配置的道具转换为材料
function PropBO.convertMaterial(award)
	if not award.kind then award.kind = award.type end

	if award.kind == ITEM_KIND_PROP then
		if award.id == PROP_ID_FITTING then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_FITTING, count = award.count}
		elseif award.id == PROP_ID_METAL then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_METAL, count = award.count}
		elseif award.id == PROP_ID_PLAN then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_PLAN, count = award.count}
		elseif award.id == PROP_ID_MINERAL then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_MINERAL, count = award.count}
		elseif award.id == PROP_ID_TOOL then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_TOOL, count = award.count}
		elseif award.id == PROP_ID_DRAW then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_DRAW, count = award.count}
		elseif award.id == PROP_ID_TANK then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_TANK, count = award.count}
		elseif award.id == PROP_ID_CHARIOT then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_CHARIOT, count = award.count}
		elseif award.id == PROP_ID_ARTILLERY then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_ARTILLERY, count = award.count}
		elseif award.id == PROP_ID_ROCKETDRIVE then
			return {kind = ITEM_KIND_MATERIAL, id = MATERIAL_ID_ROCKETDRIVE, count = award.count}
		else
			return award
		end
	else
		return award
	end
end

function PropBO.asynGetProp(doneCallback)
	local function parseGetProp(name, data)
		PropBO.update(data)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetProp, NetRequest.new("GetProp"))
end

function PropBO.asynBuyProp(doneCallback, propId, count)
	local function parseBuyProp(name, data)
		gdump(data, "[PropBO] buy prop")

		--TK统计 获得道具
		local buyCount = data.count - UserMO.getResource(ITEM_KIND_PROP, propId)
		if buyCount > 0 then
			local propName = UserMO.getResourceData(ITEM_KIND_PROP, propId).name
			TKGameBO.onUseCoinTk(data.gold,TKText[8]..propName,TKGAME_USERES_TYPE_UPDATE,buyCount)
		end
		
		local res = {}
		res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold}
		res[#res + 1] = {kind = ITEM_KIND_PROP, count = data.count, id = propId}
		UserMO.updateResources(res)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyProp, NetRequest.new("BuyProp", {propId = propId, count = count}))
end

function PropBO.asynUseProp(doneCallback, propId, count, param)
	local function parseUseProp(name, data)
		-- gdump(data, "[PropBO] use prop")
		
		UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)

		local effects = PbProtocol.decodeArray(data["effect"])
		gdump(effects, "PropBO asynUseProp effects")

		if propId == PROP_ID_FREE_WAR_72 or propId == PROP_ID_FREE_WAR_24 or propId == PROP_ID_FREE_WAR_8 then  -- 是免战
			local mapData = WorldMO.getMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y)
			if mapData then
				mapData.free = true
			end
			EffectBO.updateEffects(effects)
			Notify.notify(LOCAL_MAP_FORCE_EVENT)
		elseif propId == PROP_ID_SURFACE_BATTLE or propId == PROP_ID_SURFACE_RESOURCE or propId == PROP_ID_SURFACE_CASTLE_FAIR
			or propId == PROP_ID_SURFACE_CASTLE_DARD or propId == PROP_ID_SURFACE_CASTLE_DESDERT or propId == PROP_ID_SURFACE_HOUSE
			or propId == PROP_ID_SURFACE_STONE or propId == PROP_ID_SURFACE_ELITE or propId == PROP_ID_SURFACE_EXTREME 
			or propId == PROP_ID_SURFACE_AIRHOME or propId == PROP_ID_SURFACE_GOST or propId == PROP_ID_SURFACE_SNOW
			or propId == PROP_ID_SURFACE_CITY then  -- 基地伪装
			local mapData = WorldMO.getMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y)
			if mapData then
				if propId == PROP_ID_SURFACE_BATTLE then mapData.surface = 1
				elseif propId == PROP_ID_SURFACE_RESOURCE then mapData.surface = 2
				elseif propId == PROP_ID_SURFACE_CASTLE_FAIR then mapData.surface = 3
				elseif propId == PROP_ID_SURFACE_CASTLE_DARD then mapData.surface = 4
				elseif propId == PROP_ID_SURFACE_CASTLE_DESDERT then mapData.surface = 5
				elseif propId == PROP_ID_SURFACE_HOUSE then mapData.surface = 6
				elseif propId == PROP_ID_SURFACE_STONE then mapData.surface = 7
				elseif propId == PROP_ID_SURFACE_ELITE then mapData.surface = 991
				elseif propId == PROP_ID_SURFACE_EXTREME then mapData.surface = 992
				elseif propId == PROP_ID_SURFACE_AIRHOME then mapData.surface = 993
				elseif propId == PROP_ID_SURFACE_GOST then mapData.surface = 2001
				elseif propId == PROP_ID_SURFACE_SNOW then mapData.surface = 2002
				elseif propId == PROP_ID_SURFACE_CITY then mapData.surface = 2003
				end
			end
			
			EffectBO.updateEffects(effects)
			Notify.notify(LOCAL_MAP_FORCE_EVENT)
		elseif propId == PROP_ID_NICK_CHANGE then  -- 身份铭牌
			UserMO.nickName_ = param
			Notify.notify(LOCAL_NICK_EVENT)
		elseif propId == PROP_ID_PARTY_RENAME then --军团铭牌
			PartyMO.partyData_.partyName = param
			Notify.notify(LOCAL_MYPARTY_UPDATE_EVENT)
		else
			EffectBO.updateEffects(effects)
		end

		-- if effect and effect.id >= EFFECT_ID_BATTLE_BASE and effect.id <= EFFECT_ID_STONE_STYLE then
		-- 	UserBO.triggerFightCheck()  -- 确定战争基地effect对战斗力的影响
		-- end

		local stastAwards = nil
		local awards = PbProtocol.decodeArray(data["award"])
		if awards and #awards > 0 then
			local pb = PropMO.queryPropById(propId)
			if pb.effectType == 9 or pb.effectType == 10 then
				local item = awards[1]
				if pb.effectType == 9 then
					PendantBO.pendants_[item.id] = {pendantId = item.id,endTime = item.keyId, foreverHold = item.count == 1}
					UserMO.pendant_ = item.id
				else
					PendantBO.portraits_[item.id] = {id = item.id,endTime = item.keyId, foreverHold = item.count == 1}
					UserMO.portrait_ = item.id
				end
				Notify.notify(LOCAL_PORTRAIT_EVENT)
			else
				stastAwards = CombatBO.addAwards(awards)

				--TK统计 获得资源
				for index=1,#awards do
					local award = awards[index]
					if award.type == ITEM_KIND_RESOURCE then
						TKGameBO.onGetResTk(award.id,award.count,TKText[9],TKGAME_USERES_TYPE_CONSUME)
					end
				end
			end
		end

		if doneCallback then doneCallback(stastAwards) end
	end

	SocketWrapper.wrapSend(parseUseProp, NetRequest.new("UseProp", {propId = propId, count = count, param = param}))
end

-- 合成将神魂
function PropBO.asynComposeSant(doneCallback)
	local function parseComposeSant(name, data)
		local heroDB = PropMO.queryPropById(PROP_ID_JIANGSHENHUN) -- 获得将魂的数据信息
		UserMO.reduceResources({{kind = ITEM_KIND_PROP, id = PROP_ID_HERO_CHIP, count = heroDB.heroChip}})

		local stastAwards = nil
		local awards = PbProtocol.decodeArray(data["award"])
		if awards and #awards > 0 then
			stastAwards = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(stastAwards) end
	end

	SocketWrapper.wrapSend(parseComposeSant, NetRequest.new("ComposeSant"))
end

function PropBO.asynBuildProp(doneCallback, propId, count)
	local function parseBuildProp(name, data)
		gdump(data, "[PropBO] build prop")

		--TK统计 资源消耗
		TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[11],TKGAME_USERES_TYPE_UPDATE)
		
		local res = {}
		if table.isexist(data, "stone") then
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE}
		end

		if table.isexist(data, "skillBook") then
			res[#res + 1] = {kind = ITEM_KIND_PROP, count = data.skillBook, id = PROP_ID_SKILL_BOOK}
		end

		if table.isexist(data, "heroChip") then
			res[#res + 1] = {kind = ITEM_KIND_PROP, count = data.heroChip, id = PROP_ID_HERO_CHIP}
		end

		local exAtom = PbProtocol.decodeArray(data["atom2"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.kind, count = item.count, id = item.id}
		end

		UserMO.updateResources(res)

		local queue = PbProtocol.decodeRecord(data["queue"])
		PropBO.updateQueue(BUILD_ID_WORKSHOP, queue)

		Notify.notify(LOCLA_PROP_START_EVENT)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuildProp, NetRequest.new("BuildProp", {propId = propId, count = count}))
end

-- 取消道具生产
function PropBO.asynCancelProp(doneCallback, schedulerId)
	local buildingId = BUILD_ID_WORKSHOP

	local function parseCancel(name, data)
		FactoryBO.removeSchdulerProduct(buildingId, schedulerId)

		local res = {}
		if table.isexist(data, "stone") then 
			TKGameBO.onGetResTk(RESOURCE_ID_STONE,data.stone,TKText[5][4],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE} 
		end
		if table.isexist(data, "iron") then 
			TKGameBO.onGetResTk(RESOURCE_ID_IRON,data.iron,TKText[5][4],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.iron, id = RESOURCE_ID_IRON} 
		end
		if table.isexist(data, "oil") then 
			TKGameBO.onGetResTk(RESOURCE_ID_OIL,data.oil,TKText[5][4],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.oil, id = RESOURCE_ID_OIL} 
		end
		if table.isexist(data, "copper") then 
			TKGameBO.onGetResTk(RESOURCE_ID_COPPER,data.copper,TKText[5][4],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.copper, id = RESOURCE_ID_COPPER} 
		end
		if table.isexist(data, "silicon") then 
			TKGameBO.onGetResTk(RESOURCE_ID_SILICON,data.silicon,TKText[5][4],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.silicon, id = RESOURCE_ID_SILICON} 
		end

		local exAtom = PbProtocol.decodeArray(data["award"])
		for index = 1 ,#exAtom do
			local item = exAtom[index]
			res[#res + 1] = {kind = item.type, count = item.count + UserMO.getResource(item.type, item.id), id = item.id}
		end

		local delta = UserMO.updateResources(res)
		UiUtil.showAwards({awards = delta})

		Notify.notify(LOCAL_PROP_DONE_EVENT)

		scheduler.performWithDelayGlobal(function() PropBO.asynGetProp(doneCallback) end, 1.01)
	end

	local set = SchedulerSet.getSetById(schedulerId)
	if set then
		SocketWrapper.wrapSend(parseCancel, NetRequest.new("CancelQue", {type = 4, keyId = set.keyId}))
	end
end

-- costType: 1消耗金币，2消耗道具
function PropBO.asynSpeedProp(doneCallback, schedulerId, costType, propId)
	local function parseSpeed(name, data)
		gdump(data, "[PropBO] asynSpeedProp speed prop")

		local endTime = 0

		if costType == 1 then -- 金币加速
			--TK统计 金币消耗
			TKGameBO.onUseCoinTk(data.gold,TKText[10][4],TKGAME_USERES_TYPE_UPDATE)
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
		SocketWrapper.wrapSend(parseSpeed, NetRequest.new("SpeedQue", {type = 4, keyId = set.keyId, cost = costType, which = which}))
	end
end

-- 选择使用道具
function PropBO.usePropChoose(id,count,cid,ckind,rhand)
	function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		UserMO.updateResource(ITEM_KIND_PROP,data.count,id)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UsePropChoose",{propId = id,count = count,chooseId = cid,chooseType = ckind}))
end

--道具修改信息
function PropBO.parseModProps(name,data)
	local props = PbProtocol.decodeArray(data.props)
	for k,v in ipairs(props) do
		v.type = v.kind
	end
	if data.type == 1 then
		 --加入背包
		local ret = CombatBO.addAwards(props)
		UiUtil.showAwards(ret)
	else
		UserMO.reduceResources(props)
	end
end

function PropBO.getShopInfo(rhand)
	if PropBO.shopInfo_ then
		rhand()
		return
	end
	function parseResult(name,data)
		Loading.getInstance():unshow()
		if not PropBO.shopInfo_ then
			PropBO.shopInfo_ = {}
		end
		local info = PbProtocol.decodeArray(data["shop"])
		for k,v in ipairs(info) do
			if table.isexist(v, "sty") then
				PropBO.shopInfo_[v.sty] = {}
				for m,n in ipairs(PbProtocol.decodeArray(v["buy"])) do
					PropBO.shopInfo_[v.sty][n.gid] = n.buyCount
				end
			end
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetShopInfo"), 1)
end

function PropBO.buyShopGoods(sty,gid,count,rhand)
	function parseResult(name,data)
		Loading.getInstance():unshow()
		if table.isexist(data, "gold") then 
			--更新金币
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end
		if not PropBO.shopInfo_ then
			PropBO.shopInfo_ = {}
		end
		if not PropBO.shopInfo_[sty] then
			PropBO.shopInfo_[sty] = {[gid] = count}
		else
			if not PropBO.shopInfo_[sty][gid] then
				PropBO.shopInfo_[sty][gid] = count
			else
				PropBO.shopInfo_[sty][gid] = PropBO.shopInfo_[sty][gid] + count
			end
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyShopGoods",{sty = sty,gid = gid,count = count}), 1)
end

-- 获取皮肤信息
function PropBO.GetSkins(rhand,skintype)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetSkins",{type = skintype}), 1)
end

-- 购买或使用皮肤
-- skinId 		购买/使用的皮肤id
-- count 		购买/使用数量
function PropBO.BuySkin(rhand, skinId, count, propId, skintype)
	local function parseResult(name,data)
		Loading.getInstance():unshow()

		local res = {}
		res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold}

		if skintype == 1 then
			res[#res + 1] = {kind = ITEM_KIND_PROP, id = propId, count = count}
		end

		UserMO.updateResources(res)
		
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuySkin",{skinId = skinId,count = count}), 1)
end

-- 购买或使用皮肤
-- skinId 		购买/使用的皮肤id
-- count 		购买/使用数量
function PropBO.UseSkin(rhand,skinId, count, propId, skintype)
	local function parseResult(name,data)
		Loading.getInstance():unshow()

		if skintype == 1 then -- 基地皮肤

			UserMO.updateResource(ITEM_KIND_PROP, data.count, propId)

			-- effect
			local effects = PbProtocol.decodeRecord(data["effect"])
			if effects.id == 0 then
				for index = EFFECT_ID_BATTLE_BASE, EFFECT_ID_STONE_STYLE do
					EffectMO.effects_[index] = nil
				end
				for index = EFFECT_ID_SKIN_ELITE, EFFECT_ID_SKIN_AIR_FORTRESS do
					EffectMO.effects_[index] = nil
				end
				if index == EFFECT_ID_SKIN_GOST then
					EffectMO.effects_[EFFECT_ID_SKIN_GOST] = nil
				end

				if EFFECT_ID_SKIN_MECHANICS ~= effects.id then
					EffectMO.effects_[EFFECT_ID_SKIN_MECHANICS] = nil
				end
				Notify.notify(LOCAL_EFFECT_EVENT)
			else
				local outeffect = {{id = effects.id , endTime = effects.endTime}}
				EffectBO.updateEffects(outeffect)
			end

			local mapData = WorldMO.getMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y)
			if mapData then
				if propId == PROP_ID_SURFACE_BATTLE then mapData.surface = 1
				elseif propId == PROP_ID_SURFACE_RESOURCE then mapData.surface = 2
				elseif propId == PROP_ID_SURFACE_CASTLE_FAIR then mapData.surface = 3
				elseif propId == PROP_ID_SURFACE_CASTLE_DARD then mapData.surface = 4
				elseif propId == PROP_ID_SURFACE_CASTLE_DESDERT then mapData.surface = 5
				elseif propId == PROP_ID_SURFACE_HOUSE then mapData.surface = 6
				elseif propId == PROP_ID_SURFACE_STONE then mapData.surface = 7
				elseif propId == PROP_ID_SURFACE_ELITE then mapData.surface = 991
				elseif propId == PROP_ID_SURFACE_EXTREME then mapData.surface = 992
				elseif propId == PROP_ID_SURFACE_AIRHOME then mapData.surface = 993
				elseif propId == PROP_ID_SURFACE_GOST then mapData.surface = 2001
				elseif propId == PROP_ID_SURFACE_SNOW then mapData.surface = 2002
				elseif propId == PROP_ID_SURFACE_CITY then mapData.surface = 2003
				elseif propId == PROP_ID_MECHANIC_CITY then mapData.surface = 2005
				else mapData.surface = 0
				end
			end
		
			Notify.notify(LOCAL_MAP_FORCE_EVENT)
		elseif skintype == 2 then -- 身份名牌
			local mapData = WorldMO.getMapDataAt(WorldMO.pos_.x, WorldMO.pos_.y)
			if mapData then
				mapData.nameplate = skinId
			end
		elseif skintype == 3 then -- 聊天气泡
			UserMO.bubble_ = skinId
		end

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UseSkin",{skinId = skinId,count = count}), 1)
end