--
-- Author: gf
-- Date: 2015-09-01 11:37:44
--

HeroBO = {}


function HeroBO.update(data)
	-- HeroMO.heros_ = HeroMO.queryHeroToInfo(data)

	if not data then return end

	--将领数据
	local heros = PbProtocol.decodeArray(data["hero"])
	local awakeHeros = PbProtocol.decodeArray(data["awakenHero"])
	-- gdump(heros,"HeroBO.update .. heros000")

	local fightHeros = ArmyBO.getFightHeros()
	-- gdump(fightHeros,"fightHerosfightHeros")


	for index=1,#heros do
		local myHero = heros[index]
		local fightHero = fightHeros[myHero.heroId]
		if fightHero then
			myHero.count = myHero.count + fightHero.count
			fightHeros[myHero.heroId] = nil
		end
	end

	for heroId, data in pairs(fightHeros) do
		local hero = {}
		hero.keyId = data.heroId
		hero.heroId = data.heroId
		hero.count = data.count
		heros[#heros + 1] = hero
	end
	-- gdump(heros,"HeroBO.update .. heros111")
	HeroMO.heros_ = {}
	HeroMO.heros_ = HeroMO.queryHeroToInfo(heros)
	HeroMO.putAwakeHero(awakeHeros)

	local herolocklist = data["lockHero"]
	--gdump(herolocklist,"--------------------------------------- test start" .. #herolocklist)
	HeroMO.updateHeroLock(herolocklist)
	--gdump(HeroMO.heros_,"--------------------------------------- test end")

	--排序 
	local sortFun = function(a,b)
		return a.listOrder > b.listOrder
		-- return a.heroId < b.heroId
	end
	table.sort(HeroMO.heros_,sortFun)
	--]]
	HeroMO.coinCount = data["coinCount"]
	HeroMO.resCount = data["resCount"]

	HeroMO.dirtyHeroData_ = false
end

function HeroBO.asynLevelUp(doneCallback, keyId, needProp)

	local function parseUpgrade(name, data)
		--扣除资源
		for index=1,#needProp do
			UserMO.reduceResource(needProp[index][1], needProp[index][3], needProp[index][2])
		end

		Toast.show(CommonText[545])
		Notify.notify(LOCAL_HERO_LEVELUP_EVENT)
		Notify.notify(LOCAL_HERO_DETAIL_EVENT)

		--TK统计 将领
		--消耗
		TKGameBO.onEvnt(TKText.eventName[16], {heroId = keyId})
		if table.isexist(data, "hero") then
			--获得
			TKGameBO.onEvnt(TKText.eventName[15], {heroId = data.hero.keyId})
		end
		

		if doneCallback then doneCallback() end

		HeroBO.updateMyHeros()
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("HeroLevelUp", {keyId = keyId}))
end

function HeroBO.asynDecompose(doneCallback, type, id)

	gprint(type,"HeroBO.asynDecompose..type")
	gprint(id,"HeroBO.asynDecompose..id")

	local function parseUpgrade(name, data)
		Toast.show(CommonText[517])
		--添加道具
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			--TK统计 获得资源
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_RESOURCE then
					TKGameBO.onGetResTk(award.id,award.count,TKText[19],TKGAME_USERES_TYPE_CONSUME)
				end
			end
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end

		--TK统计 将领消耗
		if type == DECOMPOSE_TYPE_HERO then
			TKGameBO.onEvnt(TKText.eventName[16], {heroId = id})
		else
			local star = id
			local heros = HeroMO.queryHeroByStar(star)
			for index=1,#heros do
				local hero = heros[index]
				TKGameBO.onEvnt(TKText.eventName[16], {heroId = hero.keyId})
			end
		end

		--分解通知
		Notify.notify(LOCAL_HERO_DECOMPOSE_EVENT)
		Notify.notify(LOCAL_HERO_DETAIL_EVENT)

		if doneCallback then doneCallback() end

		HeroBO.updateMyHeros()
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("HeroDecompose", {type = type,id = id}))
end

function HeroBO.asynDoLottery(doneCallback, type)
	

	local function parseUpgrade(name, data)
		local heros = PbProtocol.decodeArray(data["hero"])
		gdump(heros,"HeroBO.asynDoLottery .. heros:")

		--TK统计 
		--金币消耗
  		TKGameBO.onUseCoinTk(data.gold,TKText[10][7],TKGAME_USERES_TYPE_UPDATE)
  		--资源消耗
  		TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[10][7],TKGAME_USERES_TYPE_UPDATE)
  		--获得将领
  		for index=1,#heros do
  			local hero = heros[index]
  			TKGameBO.onEvnt(TKText.eventName[15], {heroId = hero.keyId})
  		end

		--扣除资源
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		UserMO.updateResource(ITEM_KIND_RESOURCE, data.stone, RESOURCE_ID_STONE)

		--增加次数
		if type == HeroMO.HERO_LOTTERY_TYPE_RES_1 then
			HeroMO.resCount = HeroMO.resCount + 1
		elseif type == HeroMO.HERO_LOTTERY_TYPE_RES_5 then
			HeroMO.resCount = HeroMO.resCount + 5
		elseif type == HeroMO.HERO_LOTTERY_TYPE_GOLD_1 then
			HeroMO.coinCount = HeroMO.coinCount + 1
		elseif type == HeroMO.HERO_LOTTERY_TYPE_GOLD_5 then
			HeroMO.coinCount = HeroMO.coinCount + 5
		end
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_HERO_LOTTERY,type = 1})

		Notify.notify(LOCAL_UPDATE_HERO_LOTTERY_EVENT)
		if table.isexist(data,"stoneAdd") then
			UserMO.addResource(ITEM_KIND_RESOURCE,data.stoneAdd,RESOURCE_ID_STONE)
			UiUtil.showAwards({awards = {{kind = ITEM_KIND_RESOURCE,count = data.stoneAdd,id = RESOURCE_ID_STONE}}})
		end

		if doneCallback then doneCallback(type,heros) end

		HeroBO.updateMyHeros()
		-- 埋点
		Statistics.postPoint(STATIS_POINT_HERO)
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("LotteryHero", {type = type}))
end

function HeroBO.asynImprove(doneCallback, heros,need)
	local function parseUpgrade(name, data)
		--减少进阶石
		UserMO.reduceResource(ITEM_KIND_PROP, need, HeroMO.improve_need_propId)

		local hero = PbProtocol.decodeRecord(data["hero"])

		if ActivityBO.isValid(ACTIVITY_ID_CRAZY_UPGRADE) then
			ActivityBO.trigger(ACTIVITY_ID_CRAZY_UPGRADE, hero.heroId)
		end

		if doneCallback then doneCallback(hero) end
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_HERO_IMPROVE,type = 1})

		--TK统计 将领
		--消耗
		for index=1,#heros do
			TKGameBO.onEvnt(TKText.eventName[16], {heroId = heros[index].keyId})
		end
		--获得
		TKGameBO.onEvnt(TKText.eventName[15], {heroId = hero.keyId})


		HeroBO.updateMyHeros()
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("HeroImprove", {hero = heros}))
end

function HeroBO.getLotteryNeed(type)
	local cost = 0
	--招兵买将活动是否开启
	local isActivityTime = ActivityBO.isValid(ACTIVITY_ID_HERO_RECRUIT)
	if type == HeroMO.HERO_LOTTERY_TYPE_RES_1 then
		cost = HeroMO.queryCost(2, HeroMO.resCount + 1).price
		if isActivityTime then
			cost = math.floor(cost * ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_RES1)
		end
	elseif type == HeroMO.HERO_LOTTERY_TYPE_GOLD_1 then
		cost = HeroMO.queryCost(1, HeroMO.coinCount + 1).price
		if isActivityTime then
			cost = math.floor(cost * ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_COIN1)
		end
	elseif type == HeroMO.HERO_LOTTERY_TYPE_RES_5 then
		for i=1,5 do
			cost = cost + HeroMO.queryCost(2, HeroMO.resCount + i).price
		end
		if isActivityTime then
			cost = math.floor(cost * ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_RES5)
		end
	elseif type == HeroMO.HERO_LOTTERY_TYPE_GOLD_5 then
		for i=1,5 do
			cost = cost + HeroMO.queryCost(1, HeroMO.coinCount + i).price
		end
		if isActivityTime then
			cost = math.floor(cost * ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_COIN5)
		end
	end
	return cost
end

function HeroBO.getDecomposeAwards(type,param)

	local awards = {}
	-- 单个分解
	if type == DECOMPOSE_TYPE_HERO then

		awards = json.decode(HeroMO.queryAwards(HeroMO.queryHero(param).resolveId).awardList)
	else
	-- 批量分解
		local star = param
		local heros = HeroBO.getCanDecomposeHeros(star)
		-- gdump(heros,"HeroBO.getDecomposeAwards..heros")
		for index = 1,#heros do
			local meta = json.decode(HeroMO.queryAwards(heros[index].resolveId).awardList)
			for j = 1,#meta do
				meta[j][3] = meta[j][3] * heros[index].count
			end
			-- gdump(meta,"HeroBO.getDecomposeAwards..meta")
			for n = 1,#meta do
				local has = false
				for m = 1,#awards do
					if awards[m][1] == meta[n][1] and awards[m][2] == meta[n][2] then
						awards[m][3] = awards[m][3] + meta[n][3]
						has = true
					end
				end
				if has == false then
					awards[#awards + 1] = meta[n]
				end
			end
		end
	end
	gdump(awards,"HeroBO.getDecomposeAwards..awards")
	
	return awards
end

function HeroBO.getImproveHeros(star)
	local myHeros = clone(HeroMO.queryHeroByStar(star))
	gdump(myHeros,"HeroBO.getImproveHeros..myHeros")
	-- gdump(HeroMO.improve_heros_s,"HeroBO.getImproveHeros..HeroMO.improve_heros_s")
	for j=1,#HeroMO.improve_heros_s do
		local improveHero = HeroMO.improve_heros_s[j]
		if improveHero and improveHero ~= 0 then
			-- gdump(improveHero,"HeroBO.getImproveHeros..improveHero")
			for i=1,#myHeros do
				local hero = myHeros[i]
				if hero.heroId == improveHero.heroId then
					hero.count = hero.count - 1
					if hero.count == 0 then
						table.remove(myHeros,i)
					end
					break
				end
			end
		end
	end
	
	return myHeros
end

function HeroBO.canImproveHeros()
	local can = true
	for j=1,#HeroMO.improve_heros_s do
		if HeroMO.improve_heros_s[j] == 0 then
			can = false
			break
		end
	end
	return can
end

function HeroBO.getAutoSelectHeros(star)
	local selectHeros = {}
	local myHeros = clone(HeroMO.queryHeroByStar(star))
	for i=1,#myHeros do
		local myhero = myHeros[i]
		if myhero and not myhero.locked then
			local count = myhero.count
			local fightNum = ArmyBO.getHeroFightNum(myhero.heroId)
			for j=1,myhero.count - fightNum do
				local hero = {}
				hero.keyId = myhero.keyId
				hero.heroId = myhero.heroId
				hero.count = 1
				selectHeros[#selectHeros + 1] = hero
				if #selectHeros == 6 then
					return selectHeros
				end
			end
		end
	end
	return selectHeros
end

function HeroBO.getMultiHeros(star)
	local allCount = 0
	local tempHeros = {}
	local myHeros = clone(HeroMO.queryHeroByStar(star))
	for i=1,#myHeros do
		local myhero = myHeros[i]
		if myhero and not myhero.locked then
			local count = myhero.count
			local fightNum = ArmyBO.getHeroFightNum(myhero.heroId)
			local hero = {}
			hero.keyId = myhero.keyId
			hero.heroId = myhero.heroId
			hero.count = myhero.count - fightNum
			if hero.count > 0 then
				allCount = allCount + hero.count
				tempHeros[#tempHeros + 1] = hero
			end
		end
	end

	gprint(allCount,"allCount===")

	local selectHeros = {}
	local needCount = (math.floor(allCount / 6)) * 6

	
	local currentCount = 0
	for index=1,#tempHeros do
		local tempHero = tempHeros[index]
		currentCount = currentCount + tempHero.count
		gprint(currentCount,needCount)
		if currentCount < needCount then
			selectHeros[#selectHeros + 1] = tempHero
		else
			if currentCount == needCount then
				selectHeros[#selectHeros + 1] = tempHero
			elseif currentCount > needCount then
				tempHero.count = tempHero.count - (currentCount - needCount)
				selectHeros[#selectHeros + 1] = tempHero
			end
			break
		end
	end
	local set = {}
	set.heros = selectHeros
	set.count = needCount
	return set
end

function HeroBO.getMultiHerosImproveNeed(star,selectHeros)
	local needOne = HeroMO.improve_need_propCount[star]
	local allCount = 0
	for index=1,#selectHeros do
		allCount = allCount + selectHeros[index].count
	end
	return math.floor(allCount / 6) * HeroMO.improve_need_propCount[star]
end

function HeroBO.updateMyHeros(doneCallback)
	local function updateHero(name, data)
		HeroBO.update(data)

		-- 武将更新后，重新计算战斗力
		UserBO.triggerFightCheck()

		--列表更新通知
		Notify.notify(LOCAL_HERO_UPDATE_EVENT)
		Notify.notify(LOCAL_HERO_AWAKEHERO_EVENT)
		if doneCallback then doneCallback() end
	end

	HeroMO.dirtyHeroData_ = true

	SocketWrapper.wrapSend(updateHero, NetRequest.new("GetMyHeros"))
end


function HeroBO.getHerosCount(star)
	local count = 0
end

-- 获得指挥官的属性加成
function HeroBO.getHeroAttrData(heroId)
	if not heroId or heroId <= 0 then return {} end

	local attrValue = {}
	local hero = HeroMO.queryHero(heroId)
	local heroAttr = json.decode(hero.attr)
	for index = 1,#heroAttr do
		local attrData = AttributeBO.getAttributeData(heroAttr[index][1], heroAttr[index][2])

		if not attrValue[attrData["attrName"]] then attrValue[attrData["attrName"]] = attrData
		else attrValue[attrData["attrName"]].value = attrValue[attrData["attrName"]].value + attrData.value end
	end
	return attrValue
end

function HeroBO.hasHeroInSchool(heroId)
	for i=1,#HeroMO.heros_ do
		local hero = HeroMO.heros_[i]
		if hero.heroId == heroId then
			return true
		end
	end
	gprint(heroId,"heroId======")
	return false
end

-- 是否还有武将是否可以出战
function HeroBO.canHeroFight(heroId,kind)
	local hero = HeroMO.getHeroById(heroId)
	if not hero then return false end
	if not table.isexist(hero, "count") then --觉醒被消耗了
		return false
	end
	local fightNum = ArmyBO.getHeroFightNum(heroId,kind)  -- 已经上阵的数量
	if fightNum >= hero.count then return false  -- 武将已经上阵完了，没有剩余的武将上阵
	else return true end  -- 还有武将可以上阵
end

--阵型中武将是否可以出战
function HeroBO.canFormationFight(formation,kind)
	if table.isexist(formation, "awakenHero") then
		return HeroBO.canAwakeHeroFight(formation,kind) <= 0
	else
		return HeroBO.canHeroFight(formation.commander,kind)
	end
end

-- 判断阵型中觉醒武将是否在出战
--formation --阵型 或者 keyId
function HeroBO.canAwakeHeroFight(formation,kind)
	if type(formation) == "table" then
		if formation.awakenHero then
			local num = ArmyBO.getHeroFightNum(formation.awakenHero.keyId,kind)
			return num
		end
	else
		return ArmyBO.getHeroFightNum(formation,kind)
	end
	return 0
end

--当前武将是否需要对比
function HeroBO.getHeroCompare(hero,kind)
	local show = {}
	if hero and hero.star >= 4 then
		local heros = clone(HeroMO.heros_)
		for k,v in pairs(HeroMO.awakeHeros_) do
			local temp = clone(HeroMO.queryHero(v.heroId))
			temp.awakenHero = {keyId = v.keyId,heroId = v.heroId,skillLv = v.skillLv}
			table.insert(heros, temp)
		end
		for index = 1, #heros do
			local temp = heros[index]
			if temp.type == HERO_TYPE_MILITARY and temp.order > 0 and temp.star >= 4 then  -- 是武将，并可以上阵
				if not kind or ((table.isexist(temp, "awakenHero") and ArmyBO.getHeroFightNum(temp.awakenHero.keyId,kind) <=0)
					or (not table.isexist(temp, "awakenHero") and HeroBO.canHeroFight(temp.heroId,kind))) then
					if not show[temp.show] then
						show[temp.show] = temp
					elseif temp.order < show[temp.show].order then
						show[temp.show] = temp
					end
				end
			end
		end
	end
	return show
end

function HeroBO.getHeroCompareNew(hero,kind)
	local show = {}
	if hero and hero.star >= 4 then
		local heros_temp = {}
		if kind == ARMY_SETTING_FOR_WORLD then
			heros_temp = clone(HeroMO.heros_)
		else
			for i, v in ipairs(HeroMO.heros_) do
				if v.heroId < 401 or v.heroId > 410 then
					table.insert(heros_temp, v)
				end
			end
		end

		local heros = {}
		for i, v in ipairs(heros_temp) do
			if v.endTime then
				local curTime = ManagerTimer.getTime()
				if v.endTime > 0 and curTime < v.endTime then
					table.insert(heros, v)
				elseif v.endTime <= 0 then
					table.insert(heros, v)
				end
			end
		end

		for k,v in pairs(HeroMO.awakeHeros_) do
			local temp = clone(HeroMO.queryHero(v.heroId))
			temp.awakenHero = {keyId = v.keyId,heroId = v.heroId,skillLv = v.skillLv}
			table.insert(heros, temp)
		end
		for index = 1, #heros do
			local temp = heros[index]
			if temp.type == HERO_TYPE_MILITARY and temp.order > 0 and temp.star >= 4 then  -- 是武将，并可以上阵
				if not kind or ((table.isexist(temp, "awakenHero") and ArmyBO.getHeroFightNum(temp.awakenHero.keyId,kind) <=0)
					or (not table.isexist(temp, "awakenHero") and HeroBO.canHeroFight(temp.heroId,kind))) then
					if not show[temp.show] then
						show[temp.show] = temp
					elseif temp.order < show[temp.show].order then
						show[temp.show] = temp
					elseif temp.order == show[temp.show].order then
						if table.isexist(temp, 'awakenHero') and (not table.isexist(show[temp.show], "awakenHero")) then
							show[temp.show] = temp
						elseif table.isexist(temp, 'awakenHero') and table.isexist(show[temp.show], "awakenHero") then
							if temp.heroId == show[temp.show].heroId then
								-- 如果id相同，那么对比觉醒技能状态
								local awakeHero = HeroBO.getAwakeHeroByKeyId(temp.awakenHero.keyId)
								local minAwakeHero = HeroBO.getAwakeHeroByKeyId(show[temp.show].awakenHero.keyId)

								local skillLv = PbProtocol.decodeArray(awakeHero.skillLv)
								local minSkillLv = PbProtocol.decodeArray(minAwakeHero.skillLv)

								local score = HeroBO.calcAwakeHeroAwakeSkillScore(skillLv)
								local minScore = HeroBO.calcAwakeHeroAwakeSkillScore(minSkillLv)

								if score > minScore then
									show[temp.show] = temp
								end
							end
						end
					end
				end
			end
		end
	end
	return show
end

-- 获得计算最大战斗力时所用的武将
-- allHero: 是否考虑已经上阵了的武将。如果为false，表示在所有玩家拥有的武将中选择
function HeroBO.getMaxFightHero(allHero,kind)
	local minOrder = GAME_INVALID_VALUE
	local minHero = nil
	local heros = clone(HeroMO.heros_)
	for k,v in pairs(HeroMO.awakeHeros_) do
		local temp = clone(HeroMO.queryHero(v.heroId))
		temp.awakenHero = {keyId = v.keyId,heroId = v.heroId}
		table.insert(heros, temp)
	end
	for index = 1, #heros do
		local hero = heros[index]
		if hero.type == HERO_TYPE_MILITARY and hero.order > 0 then  -- 是武将，并可以上阵
			if allHero then
				if hero.order < minOrder then
					minOrder = hero.order
					minHero = hero
				end
			else
				if (table.isexist(hero, "awakenHero") and ArmyBO.getHeroFightNum(hero.awakenHero.keyId,kind) <=0)
					or (not table.isexist(hero, "awakenHero") and HeroBO.canHeroFight(hero.heroId,kind)) then
						if hero.order < minOrder then
							minOrder = hero.order
							minHero = hero
						end
				end
			end
		end
	end
	return minHero
end

function HeroBO.calcAwakeHeroAwakeSkillScore(skillLvs)
	-- body
	local score = 0
	if #skillLvs > 0 and skillLvs[1].v2 >= 4 then
		score = score + 10
	end
	if #skillLvs > 1 then
		for i = 2, #skillLvs do
			if skillLvs[i].v1 == 15 then
				local scoreM = skillLvs[i].v2
				if scoreM > 0 then
					scoreM = scoreM * 16
				end
				score = score + scoreM
			else
				score = score + skillLvs[i].v2
			end
		end
	end
	return score
end


function HeroBO.getMaxFightHeroNew(allHero, kind)
	local minOrder = GAME_INVALID_VALUE
	local minHero = nil
	local heros_temp = {}
	if kind == ARMY_SETTING_FOR_WORLD then
		heros_temp = clone(HeroMO.heros_)
	else
		for i, v in ipairs(HeroMO.heros_) do
			if v.heroId < 401 or v.heroId > 410 then
				table.insert(heros_temp, v)
			end
		end
	end

	local heros = {}
	for i, v in ipairs(heros_temp) do
		if v.endTime then
			local curTime = ManagerTimer.getTime()
			if v.endTime > 0 and curTime < v.endTime then
				table.insert(heros, v)
			elseif v.endTime <= 0 then
				table.insert(heros, v)
			end
		end
	end

	for k,v in pairs(HeroMO.awakeHeros_) do
		local temp = clone(HeroMO.queryHero(v.heroId))
		temp.awakenHero = {keyId = v.keyId,heroId = v.heroId}
		table.insert(heros, temp)
	end

	for index = 1, #heros do
		local hero = heros[index]
		if hero.type == HERO_TYPE_MILITARY and hero.order > 0 then  -- 是武将，并可以上阵
			if allHero then
				if hero.order < minOrder then
					minOrder = hero.order
					minHero = hero
				elseif hero.order == minOrder then
					if table.isexist(hero, 'awakenHero') and (not table.isexist(minHero, "awakenHero")) then
						minHero = hero -- 取有觉醒的英雄
					elseif table.isexist(hero, 'awakenHero') and table.isexist(minHero, "awakenHero") then
						-- 都有觉醒的情况下，判断heroId
						if hero.awakenHero.heroId == minHero.awakenHero.heroId then
							-- 如果id相同，那么对比觉醒技能状态
							local awakeHero = HeroBO.getAwakeHeroByKeyId(hero.awakenHero.keyId)
							local minAwakeHero = HeroBO.getAwakeHeroByKeyId(minHero.awakenHero.keyId)

							local skillLv = PbProtocol.decodeArray(awakeHero.skillLv)
							local minSkillLv = PbProtocol.decodeArray(minAwakeHero.skillLv)

							local score = HeroBO.calcAwakeHeroAwakeSkillScore(skillLv)
							local minScore = HeroBO.calcAwakeHeroAwakeSkillScore(minSkillLv)

							-- print("score!!!!", score)
							-- print("minScore!!!!", minScore)

							if score > minScore then
								minHero = hero
							end
						end
					end
				end
			else
				if (table.isexist(hero, "awakenHero") and ArmyBO.getHeroFightNum(hero.awakenHero.keyId,kind) <=0)
					or (not table.isexist(hero, "awakenHero") and HeroBO.canHeroFight(hero.heroId,kind)) then
					if hero.order < minOrder then
						minOrder = hero.order
						minHero = hero
					elseif hero.order == minOrder then
						if table.isexist(hero, 'awakenHero') and (not table.isexist(minHero, "awakenHero")) then
							minHero = hero -- 取有觉醒的英雄
						elseif table.isexist(hero, 'awakenHero') and table.isexist(minHero, "awakenHero") then
							-- 都有觉醒的情况下，判断heroId
							if hero.awakenHero.heroId == minHero.awakenHero.heroId then
								-- 如果id相同，那么对比觉醒技能状态
								local awakeHero = HeroBO.getAwakeHeroByKeyId(hero.awakenHero.keyId)
								local minAwakeHero = HeroBO.getAwakeHeroByKeyId(minHero.awakenHero.keyId)

								local skillLv = PbProtocol.decodeArray(awakeHero.skillLv)
								local minSkillLv = PbProtocol.decodeArray(minAwakeHero.skillLv)

								local score = HeroBO.calcAwakeHeroAwakeSkillScore(skillLv)
								local minScore = HeroBO.calcAwakeHeroAwakeSkillScore(minSkillLv)

								-- print("score****", score)
								-- print("minScore****", minScore)

								if score > minScore then
									minHero = hero
								end
							end
						end
					end
				end
			end
		end
	end
	return minHero
end


function HeroBO.getCanDecomposeHeros(star)
	local heros = {}
	local ret = {}
	for index=1,#HeroMO.heros_ do
		local hero = HeroMO.heros_[index]
		if hero.star == star then
			if not hero.locked and hero.count > ArmyBO.getHeroFightNum(hero.heroId) then
				ret = clone(hero)
				ret.count = ret.count - ArmyBO.getHeroFightNum(ret.heroId)
				heros[#heros + 1] = ret
			end
		end
	end
	return heros
end

-- 获得提升坦克生产速度的武将
function HeroBO.getProductHero()
	local sir = HeroMO.getHeroById(HERO_ID_PRODUCT_SIR)
	local soldier = HeroMO.getHeroById(HERO_ID_PRODUCT_SOLDIER)
	if not sir and not soldier then return nil
	elseif sir and not soldier then return sir
	elseif not sir and soldier then return soldier
	else
		if sir.skillValue >= soldier.skillValue then return sir
		else return soldier end
	end
end

-- 获得提升坦克改造速度的武将
function HeroBO.getRefitHero()
	local sir = HeroMO.getHeroById(HERO_ID_REFIT_SIR)
	local soldier = HeroMO.getHeroById(HERO_ID_REFIT_SOLDIER)
	if not sir and not soldier then return nil
	elseif sir and not soldier then return sir
	elseif not sir and soldier then return soldier
	else
		if sir.skillValue >= soldier.skillValue then return sir
		else return soldier end
	end
end

-- 获得提升科技速度的武将
function HeroBO.getScienceHero()
	local sir = HeroMO.getHeroById(HERO_ID_SCIENCE_SIR)
	local soldier = HeroMO.getHeroById(HERO_ID_SCIENCE_SOLDIER)
	if not sir and not soldier then return nil
	elseif sir and not soldier then return sir
	elseif not sir and soldier then return soldier
	else
		if sir.skillValue >= soldier.skillValue then return sir
		else return soldier end
	end
end

-- --如果文官入驻开启
function HeroBO.getStaffHero(kind)
	local sir = nil
	if not UserMO.queryFuncOpen(UFP_STAFF_CONFIG) then
		if kind == HERO_STAFF_REFINE then
			sir = HeroBO.getRefitHero()
		elseif kind == HERO_STAFF_PRODUCT then
			sir = HeroBO.getProductHero()
		elseif kind == HERO_STAFF_SCIENCE then
			sir = HeroBO.getScienceHero()
		else
			--todo
		end
	else
		sir = HeroMO.getStaffHeroById(kind)
	end
	return sir
end



function HeroBO.asynMultiHeroImprove(doneCallback, heros,need)
	local function parseUpgrade(name, data)
		--减少进阶石
		UserMO.reduceResource(ITEM_KIND_PROP, need, HeroMO.improve_need_propId)

		local newHeros = PbProtocol.decodeArray(data["hero"])

		if ActivityBO.isValid(ACTIVITY_ID_CRAZY_UPGRADE) then
			for index=1,#newHeros do
				local hero = newHeros[index]
				ActivityBO.trigger(ACTIVITY_ID_CRAZY_UPGRADE, hero.heroId)
			end
		end

		if doneCallback then doneCallback(newHeros) end
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_HERO_IMPROVE,type = 1})

		--TK统计 将领
		--消耗
		for index=1,#heros do
			TKGameBO.onEvnt(TKText.eventName[16], {heroId = heros[index].keyId})
		end
		--获得
		for index=1,#newHeros do
			local hero = newHeros[index]
			TKGameBO.onEvnt(TKText.eventName[15], {heroId = hero.keyId})
		end
		HeroBO.updateMyHeros()
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("MultiHeroImprove", {hero = heros}))
end


function HeroBO.lockHero( doneCallback, heroid, islocked)
	local function parseUpgrade(name, data)
		local locked = HeroMO.IsLockById(heroid)

		-- 修改数据
		locked = not locked
		HeroMO.setHeroLockById(heroid, locked)

		-- 列表更新通知
		Notify.notify(LOCAL_HERO_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("LockHero", {heroId = heroid, locked = islocked}))
end
--获取觉醒将领ID对应的技能ID和等级数据
function HeroBO.getAwakeSkillInfo()
	local info = {}
	for k,v in pairs(HeroMO.awakeHeros_) do
		local awakeHeros = v --HeroMO.awakeHeros_[idx]
		local awakeSkill = PbProtocol.decodeArray(awakeHeros.skillLv)
		local skillInfo = {}
		for k,v in pairs (awakeSkill) do
			skillInfo[v.v1] = v.v2
		end
		if not info[awakeHeros.heroId] then
			info[awakeHeros.heroId] = skillInfo
		else
			local awakeInfo = info[awakeHeros.heroId]
			for id,lv in pairs (skillInfo) do
				if awakeInfo[id] and lv > awakeInfo[id] then
					awakeInfo[id] = lv
				elseif not awakeInfo[id] then
					awakeInfo[id] = lv
				end
			end
		end
	end
	return info
end


--获取觉醒将领数据
function HeroBO.getAwakeHeroInfo(doneCallback, hero)
	local function parse(name, data)
		Loading.getInstance():unshow()
		local awakeHeros = PbProtocol.decodeRecord(data["awakenHero"])
		-- UserMO.updateResources(reward)
		if doneCallback then doneCallback(awakeHeros) end
		HeroBO.updateMyHeros()
		Notify.notify(LOCAL_HERO_AWAKE_EVENT)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("HeroAwaken", {heroId = hero.heroId}))
end

function HeroBO.goAwake(doneCallback,kind,hero)
	local keyId = hero.keyId
	local function parse(name, data)
		Loading.getInstance():unshow()

		if doneCallback then doneCallback(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("HeroAwakenSkillLv", {id = kind,keyId = keyId}), 1)
end

function HeroBO.getAwakeHeroByKeyId(keyId)
	-- local awakeHeros = HeroMO.awakeHeros_ 
	-- local awakeHerosInfo = nil
	-- if not awakeHerosInfo then
	-- 	awakeHerosInfo = {}
	-- 	for index = 1, #awakeHeros do
	-- 		local awards = awakeHeros[index]
	-- 		awakeHerosInfo[awards.keyId] = awards
	-- 	end
	-- end
	return HeroMO.awakeHeros_[keyId]--awakeHerosInfo[keyId]
end
--根据HeroId判断当前将领觉醒的状态返回1说明当前将领是已觉醒的
function HeroBO.getHeroStateById(heroId)
	local heroInfo = HeroMO.queryHero(heroId)
	if heroInfo.awakenSkillArr then
		return 1 
	end
	return nil
end

--参谋部设置文官入驻
function HeroBO.setStaffHeros(doneCallback,param)
	local function parse(name, data)
		Loading.getInstance():unshow()
		local staffHero = PbProtocol.decodeArray(data["heroPut"])
		StaffMO.staffHerosData_ = staffHero
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("SetHeroPut", {partId = param.partId,id = param.id,heroId = param.heroId}))
end

-- 是否还有文官能部署
function HeroBO.canHeroStaff(heroId)
	local hero = HeroMO.getHeroById(heroId)
	if not hero then return false end
	if not table.isexist(hero, "count") then --觉醒被消耗了
		return false
	end
	local fightNum = HeroMO.getHeroStaffNum(heroId) -- 已经上阵的数量  HeroMO.isStaffHeroPutById(heroId)
	if fightNum >= hero.count then return false  -- 武将已经上阵完了，没有剩余的武将上阵
	else return true end  -- 还有武将可以上阵
end

function HeroBO.getNewHeroInfo(doneCallback, armyId)
	-- body
	local function parse(name, data)
		Loading.getInstance():unshow()
		-- gdump(data, "data=======================")
		local gold = data.gold
		local stafExp = 0
		-- 部队获得的编制经验
		if table.isexist(data, "stafExp") then 
			stafExp = data.stafExp
		end		
		if doneCallback then doneCallback(gold, stafExp) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetNewHeroInfo", {keyId = armyId}))
end

function HeroBO.clearHeroCd(doneCallback, heroId)
	-- body
	local function parse(name, data)
		Loading.getInstance():unshow()
		-- 更新金币数量
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		-- 清除英雄cd
		local hero = HeroMO.getHeroById(heroId)
		hero.cd = 0
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("ClearHeroCd", {heroId = heroId}))
end

function HeroBO.getHeroCd(doneCallback)
	-- body
	local function parse(name, data)
		Loading.getInstance():unshow()
		local heroCd = PbProtocol.decodeArray(data.heroCd)
		for i, v in ipairs(heroCd) do
			local hero = HeroMO.getHeroById(v.v1)
			if hero then
				hero.cd = v.v2 / 1000
			end
		end
		local heroClearCount = PbProtocol.decodeArray(data.heroClearCount)
		gdump(heroClearCount, "HeroBO.getHeroCd heroClearCount==")
		for i, v in ipairs(HeroMO.heros_) do
			if v.cdClearCount then
				v.cdClearCount = 0
			end
		end
		for i, v in ipairs(heroClearCount) do
			local hero = HeroMO.getHeroById(v.v1)
			if hero then
				hero.cdClearCount = v.v2
			end
		end
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetHeroCd"))
end

function HeroBO.getHeroEndTime(doneCallback)
	-- body
	local function parse(name, data)
		Loading.getInstance():unshow()
		local heroEndTime = PbProtocol.decodeArray(data.heroEndTime)
		for i, v in ipairs(heroEndTime) do
			local hero = HeroMO.getHeroById(v.v1)
			if hero then
				hero.endTime = v.v2 / 1000
			end
		end
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetHeroEndTime"))
end
