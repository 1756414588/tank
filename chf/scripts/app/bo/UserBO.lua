
UserBO = {}

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback())
    if UserBO.showDebug then
	    local t = UiUtil.label("LUA ERROR: " .. tostring(errorMessage) .. "\n",22,display.COLOR_RED,cc.size(display.width-20,0),ui.TEXT_ALIGN_LEFT)
	    	:addTo(display.getRunningScene(),1000):align(display.LEFT_TOP,10,display.height-50)
	    UiUtil.label(debug.traceback(),22,display.COLOR_RED,cc.size(display.width-20,0),ui.TEXT_ALIGN_LEFT):alignTo(t,-t:height()/2,1)
    end
    print("----------------------------------------")
end

local tickTimer_ = nil

local cycleTimers_ = {} -- 多个属性用于恢复的倒计时

UserBO.refreshCallbackHandler = nil

function UserBO.logout()
	gprint("UserBO.logout...")
	if ActivityMO.refreshHandler_ then
		scheduler.unscheduleGlobal(ActivityMO.refreshHandler_)
		ActivityMO.refreshHandler_ = nil
	end

	if ActivityCenterMO.refreshHandler_ then
		scheduler.unscheduleGlobal(ActivityCenterMO.refreshHandler_)
		ActivityCenterMO.refreshHandler_ = nil
	end

	if TankMO.delayGetTankHandler_ then
		scheduler.unscheduleGlobal(TankMO.delayGetTankHandler_)
		TankMO.delayGetTankHandler_ = nil		
	end

	ChatMO.chat_ = {}
	ChatMO.man_ = {}
	ChatMO.shield_ = {}
	ChatMO.showChat_ = true
	ChatMO.searchContent_ = ""
	ChatMO.curPrivacyLordId_ = 0

	RankMO.myRank_ = {}
	RankMO.ranks = {}
end

function UserBO.parseSynResource(name, data)
	local deltaResData = data
	local function parseResource(name, data)
		local delta = UserBO.updateGetResource(data)
		-- gdump(delta, "资源变化")

		local res = {}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_COPPER, count = deltaResData.copper}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_IRON, count = deltaResData.iron}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_OIL, count = deltaResData.oil}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_SILICON, count = deltaResData.silicon}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_STONE, count = deltaResData.stone}

		UiUtil.showAwards({awards = res})
	end

	SocketWrapper.wrapSend(parseResource, NetRequest.new("GetResource"))
end

-- 当有影响战斗力的事件发生时，需要处理是否玩家战斗力有变化
-- PROFILE_T = 0


function UserBO.triggerFightCheck(need_check_data)
	if not UserMO.startCheckFight_ then return end

	need_check_data = need_check_data or true
	if need_check_data then
		if ArmyMO.dirtyArmyData_ or TankMO.dirtyTankData_ or 
			HeroMO.dirtyHeroData_ or SkillMO.dirtySkillData_ or 
			ScienceMO.dirtyScienceData_ or PartyMO.dirtyPartyScienceData_ or EnergySparMO.dirtyEnergyData_ then 
			return 
		end
	end

	if UserMO.userFightCheckSchedule then
		-- print("triggerFightCheck exit because of UserMO.userFightCheckSchedule!!!!!!!")
		if UserMO.userFightCheckWait == false then
			UserMO.userFightCheckWait = true
		end
		return
	end

	UserBO.triggerStrengthCheck() --检测实力

	local fightHero = HeroBO.getMaxFightHero(true)
	local maxFormation = nil
	-- local temp = HeroBO.getHeroCompare(fightHero)
	local temp = HeroBO.getHeroCompareNew(fightHero)

	local tempTanks = TankBO.getMaxFightValueTanks()

	if table.nums(temp) > 0 then
		local list = {}
		local coroutineFunc = function()
			for k,v in pairs(temp) do
				local formation, total = TankBO.getMaxFightFormation(tempTanks, v)
				-- print("total!!!!!!", total)
				table.insert(list,{total = total,formation = formation, hero = v})
				coroutine.yield()
			end

			table.sort(list, function(a,b)
				return a.total > b.total
			end)
			maxFormation = TankBO.sortFormation(list[1].formation,list[1].hero)

			local data = TankBO.analyseFormation(maxFormation)
			data.total = math.floor(data.total)
			-- print("data.total now!!!!!", data.total)
			-- print("UserMO.fightValue_！！！", UserMO.fightValue_)
			if data.total ~= UserMO.fightValue_ then  -- 战斗力有变化
				if UserMO.fightShowScheduler_ then
					scheduler.unscheduleGlobal(UserMO.fightShowScheduler_)
					UserMO.fightShowScheduler_ = nil
				end

				local delayTime = math.random(4, 10) * 0.1
				-- 延迟发送，避免多个地方触发，而导致重复发送
				UserMO.fightShowScheduler_ = scheduler.performWithDelayGlobal(function()
						local function doneSetData()
							UserMO.fightShowScheduler_ = nil

							local old = math.floor(UserMO.fightValue_)
							UserMO.fightValue_ = data.total

							if UiDirector.hasUiByName("HomeView") then UiUtil.showFightChange(old, data.total, {formation = maxFormation, analyse = data}) end

							Notify.notify(LOCAL_FIGHT_EVENT)
						end
						UserBO.asynSetData(doneSetData, 1, data.total)
					end, delayTime)
			end

			if UserMO.userFightCheckSchedule ~= nil then
				-- print("unscheduleGlobal(UserMO.userFightCheckSchedule)!!!!!!!!!!!!!!!!!!!!!")
				scheduler.unscheduleGlobal(UserMO.userFightCheckSchedule)
				UserMO.userFightCheckSchedule = nil
			end

			if UserMO.userFightCheckWait == true then
				UserMO.userFightCheckWait = false
				UserBO.triggerFightCheck(false)
			end
		end

		local co2 = coroutine.create(coroutineFunc)
		coroutine.resume(co2)

		UserMO.userFightCheckSchedule = scheduler.scheduleGlobal(function ()
			-- body
			coroutine.resume(co2)
		end, 0.1)
	else
		maxFormation = TankBO.getMaxFightFormation(tempTanks, true)
		local data = TankBO.analyseFormation(maxFormation)
		data.total = math.floor(data.total)
		if data.total ~= UserMO.fightValue_ then  -- 战斗力有变化
			if UserMO.fightShowScheduler_ then
				scheduler.unscheduleGlobal(UserMO.fightShowScheduler_)
				UserMO.fightShowScheduler_ = nil
			end

			local delayTime = math.random(4, 10) * 0.1
			-- 延迟发送，避免多个地方触发，而导致重复发送
			UserMO.fightShowScheduler_ = scheduler.performWithDelayGlobal(function()
					local function doneSetData()
						UserMO.fightShowScheduler_ = nil

						local old = math.floor(UserMO.fightValue_)
						UserMO.fightValue_ = data.total

						if UiDirector.hasUiByName("HomeView") then UiUtil.showFightChange(old, data.total, {formation = maxFormation, analyse = data}) end

						Notify.notify(LOCAL_FIGHT_EVENT)
					end
					UserBO.asynSetData(doneSetData, 1, data.total)
				end, delayTime)
		end
	end
end

----实力变化
function UserBO.triggerStrengthCheck()
	if not UserMO.queryFuncOpen(UFP_NEW_PLAYER_POWER) then
		return
	end

	if UserMO.userStrengthCheckSchedule then
		-- print("triggerStrengthCheck exit because of UserMO.userStrengthCheckSchedule!!!!!!!")
		return
	end

	if UserMO.strengthScheduler_ then
		scheduler.unscheduleGlobal(UserMO.strengthScheduler_)
		UserMO.strengthScheduler_ = nil
	end

	local delayTime = math.random(5, 10) * 0.1
	-- 延迟发送，避免多个地方触发，而导致重复发送
	UserMO.strengthScheduler_ = scheduler.performWithDelayGlobal(function()
			local fightHero = HeroBO.getMaxFightHero(true)
			local maxFormation = nil
			-- local temp = HeroBO.getHeroCompare(fightHero)
			local temp = HeroBO.getHeroCompareNew(fightHero)
			if table.nums(temp) > 0 then
				local tempTanks = {}
				for k,v in pairs(temp) do
					tempTanks[k] = TankBO.getMaxFightValueTanksEx(v.heroId)
				end
				local list = {}
				local coroutineFunc = function()
					for k,v in pairs(temp) do
						local formation, total = TankBO.getMaxFightFormation(tempTanks[k], v)
						-- print("triggerStrengthCheck total!!!!!!", total)
						table.insert(list,{total = total,formation = formation, hero = v})
						coroutine.yield()
					end

					table.sort(list, function(a,b)
						return a.total > b.total
					end)

					maxFormation = TankBO.sortFormation(list[1].formation,list[1].hero)
					local data = TankBO.analyseFormation(maxFormation)
					data.total = math.floor(data.total)
					local format = CombatBO.encodeFormation(maxFormation)
					UserMO.strengthScheduler_ = nil
					UserBO.asynSetData(nil, 10, data.total, format)

					if UserMO.userStrengthCheckSchedule ~= nil then
						-- print("unscheduleGlobal(UserMO.userStrengthCheckSchedule)!!!!!!!!!!!!!!!!!!!!!")
						scheduler.unscheduleGlobal(UserMO.userStrengthCheckSchedule)
						UserMO.userStrengthCheckSchedule = nil
					end
				end

				local co2 = coroutine.create(coroutineFunc)
				coroutine.resume(co2)

				UserMO.userStrengthCheckSchedule = scheduler.scheduleGlobal(function ()
					coroutine.resume(co2)
				end, 0.12)
			else
				maxFormation = TankBO.getMaxFightFormation(TankBO.getMaxFightValueTanksEx(), true)
				local data = TankBO.analyseFormation(maxFormation)
				data.total = math.floor(data.total)
				local format = CombatBO.encodeFormation(maxFormation)
				UserMO.strengthScheduler_ = nil
				UserBO.asynSetData(nil, 10, data.total, format)
			end
		end, delayTime)
end

-- 统计征战关卡的总星数，并上传
function UserBO.triggerCombatStar()
	local star = 0
	for combatId, combat in pairs(CombatMO.combats_) do
		star = star + combat.star
	end

	local function doneSetData()
	end
	UserBO.asynSetData(doneSetData, 2, star)
end

-- 目前只统计攻击、暴击、和闪避
-- function UserBO.triggerEquip(equipPos)
function UserBO.triggerEquip(equip)
	local keyId = 0
	if not equip then return end

	local equipPos = EquipMO.getPosByEquipId(equip.equipId)
	if equipPos ~= EQUIP_POS_ATK and equipPos ~= EQUIP_POS_DODGE and equipPos ~= EQUIP_POS_CRIT then return end

	keyId = equip.keyId
	-- local level = 0

	-- for formatIndex = 1, FIGHT_FORMATION_POS_NUM do
	-- 	if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
	-- 		local equip = EquipBO.getEquipAtPos(formatIndex, equipPos)
	-- 		if equip.level > level then
	-- 			level = equip.level
	-- 			keyId = equip.keyId
	-- 		end
	-- 	end
	-- end

	if keyId <= 0 then return end

	local dataType = 0
	if equipPos == EQUIP_POS_ATK then dataType = 4
	elseif equipPos == EQUIP_POS_CRIT then dataType = 5
	elseif equipPos == EQUIP_POS_DODGE then dataType = 6
	end

	local function doneSetData()
	end
	UserBO.asynSetData(doneSetData, dataType, keyId)
end

function UserBO.triggerHonor()
	-- local function doneSetData()
	-- end
	-- UserBO.asynSetData(doneSetData, 3, UserMO.honor_)
end

function UserBO.parsePortrait(portrait)
	local v1 = portrait % 100  -- 头像
	local v2 = math.floor(portrait / 100)  -- 挂件
	return v1, v2
end

function UserBO.updateGetLord(data)
	gdump(data, "UserBO GetLord")

	local res = {}

	UserMO.lordId_ = data.lordId
	UserMO.nickName_ = data.nick
	local p, q = UserBO.parsePortrait(data.portrait)
	UserMO.portrait_ = p
	UserMO.pendant_ = q
	UserMO.level_ = data.level
	local old = UserMO.exp_
	UserMO.exp_ = data.exp
	local count = UserMO.exp_ - old
	res[#res + 1] = {kind = ITEM_KIND_EXP, count = count}
	UserMO.vip_ = data.vip
	UserMO.topup_ = data.topup
	UserMO.coin_ = data.gold
	UserMO.rank_ = data.ranks
	UserMO.command_ = data.command
	UserMO.fame_ = data.fame
	UserMO.fameLevel_ = data.fameLv

	local oldHonor = UserMO.honor_
	UserMO.honor_ = data.honour

	UserMO.prosperous_ = data.pros
	UserMO.maxProsperous_ = data.prosMax
	UserMO.prosperousLevel_ = UserBO.getProsperousLevel(data.pros)
	UserMO.power_ = data.power
	UserMO.powerTime_ = data.powerTime
	UserMO.fightValue_ = data.fight
	UserMO.newerGift_= data.newerGift
	UserMO.equipWarhouse_ = data.equip
	UserMO.huangbao_ = data.huangbao
	UserMO.hunterCoin_ = data.bounty
	UserMO.canClickFame_ = data.clickFame
	UserMO.canBuyFame_ = data.buyFame
	UserMO.sex_ = data.sex
	UserMO.powerBuy_ = data.buyPower
	UserMO.newState = data.newState
	UserMO.scout_ = data.scout   ---侦查次数
	UserMO.oldLordId_ = 0
	ActivityMO.activeBoxInfo = data.activeBox --活跃宝箱

	if table.isexist(data,"oldLordId") then UserMO.oldLordId_ = data.oldLordId end

	if UserMO.sex_ == 0 then
		UserMO.sex_ = SEX_MALE
	end
	UserMO.buildCount_ = data.buildCount

	UserMO.onlineAccumTime_ = data.olTime

	UserMO.onlineCdTime_ = data.ctTime
	UserMO.onlineAwardIndex_ = data.olAward  -- 已经领取了的索引

	if table.isexist(data, "ruins") then
		local ruins = PbProtocol.decodeRecord(data.ruins)
		UserMO.ruins = ruins
	end
	UserMO.gem_ = 0
	if table.isexist(data, "gm") then UserMO.gm_ = data.gm end

	if table.isexist(data, "createRoleTime") then UserMO.createRoleTime_ = data.createRoleTime end

	if table.isexist(data, "partyTipAward") then UserMO.partyTipAward_ = data.partyTipAward end
	if table.isexist(data, "openServerDay") then UserMO.openServerDay = data.openServerDay end
	UserMO.guider_ = 0
	if table.isexist(data, "guider") then UserMO.guider_ = data.guider end

	if table.isexist(data, "staffing") then UserMO.staffing_ = data.staffing end

	if table.isexist(data, "staffingLv") then UserMO.staffingLv_ = data.staffingLv end

	if table.isexist(data, "staffingExp") then UserMO.staffingExp_ = data.staffingExp end

	if table.isexist(data, "bubbleId") then UserMO.bubble_ = data.bubbleId end

	if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then -- 当天的所有的都领完了
		UserMO.onlineCdTime_ = 0
	else -- 还有在线奖励可以领取
		local time = UserMO.getOnlineAwardByIndex(UserMO.onlineAwardIndex_ + 1)
		-- gprint("xxxx time:", time, ManagerTimer.getTime(), (ManagerTimer.getTime() - UserMO.onlineCdTime_))
		UserMO.onlineCdTime_ = time - (ManagerTimer.getTime() - UserMO.onlineCdTime_) + 0.99
	end
	-- gprint("UserBO.updateGetLord", UserMO.onlineCdTime_)

	WorldMO.updatePos(data.pos)

	CombatMO.combatChallenge_ = {}
	CombatMO.combatBuy_ = {}
	for index = 1, EXPLORE_TYPE_TACTIC do
		CombatMO.combatChallenge_[index] = {}
		CombatMO.combatBuy_[index] = {}

		if index == EXPLORE_TYPE_EQUIP then
			CombatMO.combatChallenge_[index].count = data.equipEplr
			CombatMO.combatBuy_[index].count = data.equipBuy
		elseif index == EXPLORE_TYPE_PART then
			CombatMO.combatChallenge_[index].count = data.partEplr
			CombatMO.combatBuy_[index].count = data.partBuy
		elseif index == EXPLORE_TYPE_EXTREME then
			CombatMO.combatChallenge_[index].count = data.extrEplr
			CombatMO.combatBuy_[index].count = data.extrReset  -- 极限副本已重置次数
		elseif index == EXPLORE_TYPE_LIMIT then
			CombatMO.combatChallenge_[index].count = data.timeEplr
			CombatMO.combatBuy_[index].count = data.timeBuy
		elseif index == EXPLORE_TYPE_WAR then
			CombatMO.combatChallenge_[index].count = data.militaryEplr
			CombatMO.combatBuy_[index].count = data.militaryBuy
		elseif index == EXPLORE_TYPE_ENERGYSPAR then
			CombatMO.combatChallenge_[index].count = data.energyStoneEplrId
			CombatMO.combatBuy_[index].count = data.energyStoneBuy	
		elseif index == EXPLORE_TYPE_MEDAL then
			CombatMO.combatChallenge_[index].count = data.medalEplr
			CombatMO.combatBuy_[index].count = data.medalBuy
		elseif index == EXPLORE_TYPE_TACTIC then  --战术副本
			CombatMO.combatChallenge_[index].count = data.tacticsReset
			CombatMO.combatBuy_[index].count = data.tacticsBuy	
		end
	end

	-- 配件材料信息
	PartMO.material_ = {}
	PartMO.material_[MATERIAL_ID_FITTING] = {id = MATERIAL_ID_FITTING, count = data.fitting}
	PartMO.material_[MATERIAL_ID_METAL] = {id = MATERIAL_ID_METAL, count = data.metal}
	PartMO.material_[MATERIAL_ID_PLAN] = {id = MATERIAL_ID_PLAN, count = data.plan}
	PartMO.material_[MATERIAL_ID_MINERAL] = {id = MATERIAL_ID_MINERAL, count = data.mineral}
	PartMO.material_[MATERIAL_ID_TOOL] = {id = MATERIAL_ID_TOOL, count = data.tool}
	PartMO.material_[MATERIAL_ID_DRAW] = {id = MATERIAL_ID_DRAW, count = data.draw}
	PartMO.material_[MATERIAL_ID_TANK] = {id = MATERIAL_ID_TANK, count = data.tankDrive}
	PartMO.material_[MATERIAL_ID_CHARIOT] = {id = MATERIAL_ID_CHARIOT, count = data.chariotDrive}
	PartMO.material_[MATERIAL_ID_ARTILLERY] = {id = MATERIAL_ID_ARTILLERY, count = data.artilleryDrive}
	PartMO.material_[MATERIAL_ID_ROCKETDRIVE] = {id = MATERIAL_ID_ROCKETDRIVE, count = data.rocketDrive}
	--配件10以后的材料
	PartMO.updateMatrial(data.partMatrial)
	--勋章材料
	MedalBO.updateMaterial(data)
	-- gprint("等级是:", UserMO.prosperousLevel_)

	local timer = cycleTimers_[ITEM_KIND_POWER]   -- 体力定时器
	if not timer then
		cycleTimers_[ITEM_KIND_POWER] = require("app.util.CycleTimer").new(data.powerTime, POWER_CYCLE_TIME)
	else
		cycleTimers_[ITEM_KIND_POWER]:setDeltaTime(data.powerTime)
	end
	cycleTimers_[ITEM_KIND_POWER]:start()
	UserBO.updateCycleTime(ITEM_KIND_POWER)

	local timer = cycleTimers_[ITEM_KIND_PROSPEROUS]  -- 繁荣度定时器
	if not timer then
		cycleTimers_[ITEM_KIND_PROSPEROUS] = require("app.util.CycleTimer").new(data.prosTime, PROSPEROUS_CYCLE_TIME)
	else
		cycleTimers_[ITEM_KIND_PROSPEROUS]:setDeltaTime(data.prosTime)
	end
	cycleTimers_[ITEM_KIND_PROSPEROUS]:start()
	UserBO.updateCycleTime(ITEM_KIND_PROSPEROUS)

	if not UserMO.tickTimer_ then
		UserMO.tickTimer_ = ManagerTimer.addTickListener(UserBO.onTick)
	end

	if not UserMO.refreshTimer_ then  -- 每日的刷新时间
		UserMO.refreshTimer_ = ManagerTimer.addClockListener(0, UserBO.refreshCallback)
	end

	if oldHonor ~= UserMO.honor_ then
		UserBO.triggerHonor()
	end

	if UserMO.queryFuncOpen(UFP_NEW_PLAYERBACK) and UserMO.level_ >= 30 then ---30级 老玩家拉去 回归活动
		PlayerBackBO.GetPlayerBackInfo()
	end

	if UserMO.queryFuncOpen(UFP_STAFF_CONFIG) then --文官入驻
		StaffBO.updateStaffHeros()
	end

	-- 战争武器
	if UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) then
		WarWeaponBO.GetSecretWeaponInfo()
	end

	Notify.notify(LOCAL_RES_EVENT, {tag = 3})
	Notify.notify(LOCAL_EXP_EVENT)
	Notify.notify(LOCAL_LEVEL_EVENT)
	Notify.notify(LOCAL_FAME_EVENT)
	Notify.notify(LOCAL_POWER_EVENT)
	Notify.notify(LOCAL_PROSPEROUS_EVENT)

	return res
end

function UserBO.refreshCallback()
	if UserMO.refreshTimer_ then
		ManagerTimer.removeClockListener(UserMO.refreshTimer_)
	end
	gprint("UserBO.refreshCallback next day refresh !!!")
	UserBO.asynScout()
	UserBO.asynGetLord()
	SocketWrapper.wrapSend(function(name, data) SignBO.update(data) end, NetRequest.new("GetSign"))
	SocketWrapper.wrapSend(function(name, data) SignBO.updateEveryLogin(data) end, NetRequest.new("EveLogin"))
	SocketWrapper.wrapSend(function(name, data) ActivityBO.update(data) end, NetRequest.new("GetActivityList"))
	SocketWrapper.wrapSend(function(name, data) LotteryBO.updateTreasureFreeTimes(data) end, NetRequest.new("GetLotteryExplore"))
	SocketWrapper.wrapSend(function(name, data) ActivityCenterBO.update(data) end, NetRequest.new("GetActionCenter"))
	SocketWrapper.wrapSend(function(name, data) ActivityBO.updateMonthSign(data) end, NetRequest.new("GetMonthSign"))
	ActivityCenterBO.isCouldUpdataActivity = true
	--刷新日常任务
	TaskBO.asynGetDayiyTask()
	--新坦克拉霸零点刷新
	ActivityCenterBO.resetNewRaffle()
	--每日目标零点刷新
	-- ActivityCenterBO.resetDailyTarget()

	-- if not UserMO.refreshTimer_ then
	UserMO.refreshTimer_ = ManagerTimer.addClockListener(0, UserBO.refreshCallback)
	-- end
	PropBO.shopInfo_ = nil
	UserBO.asynUpdateAct()

	--拇指广告活动刷新
	if ServiceBO.muzhiAdPlat() then
		MuzhiADBO.GetLoginADStatus()
		if UserMO.vip_ == 0 then
			MuzhiADBO.GetFirstGiftADStatus()
		end
		MuzhiADBO.GetExpAddStatus()
		MuzhiADBO.GetStaffingAddStatus()
		MuzhiADBO.GetAddPowerAD()
		MuzhiADBO.GetAddCommandAD()
	end
end

function UserBO.updateGetResource(data)
	-- gdump(data, "GetResource")
	if not UserMO.resource_[RESOURCE_ID_COPPER] then UserMO.resource_[RESOURCE_ID_COPPER] = 0 end
	if not UserMO.resource_[RESOURCE_ID_IRON] then UserMO.resource_[RESOURCE_ID_IRON] = 0 end
	if not UserMO.resource_[RESOURCE_ID_OIL] then UserMO.resource_[RESOURCE_ID_OIL] = 0 end
	if not UserMO.resource_[RESOURCE_ID_SILICON] then UserMO.resource_[RESOURCE_ID_SILICON] = 0 end
	if not UserMO.resource_[RESOURCE_ID_STONE] then UserMO.resource_[RESOURCE_ID_STONE] = 0 end

	local res = {}
	res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_COPPER, count = data.copper}
	res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_IRON, count = data.iron}
	res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_OIL, count = data.oil}
	res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_SILICON, count = data.silicon}
	res[#res + 1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_STONE, count = data.stone}

	local delta = UserMO.updateResources(res)
	return delta
end

-- 玩家的等级level是否是满级了
function UserBO.isLordFullLevel()
	local level = UserMO.level_
	if level >= UserMO.queryMaxLordLevel() then return true
	else return false end
end

-- 根据繁荣值，确定繁荣度等级
function UserBO.getProsperousLevel(prosperous)
	local lv = 0
	local maxLv = UserMO.queryMaxProsperousLevel()
	-- print("最大繁荣度等级 pros lv:", maxLv)
	for index = 1, maxLv do
		local prosData = UserMO.queryProsperousByLevel(index)
		if prosData.prosExp > prosperous then
			return lv
		else
			lv = index
		end
	end
	return maxLv
end

function UserBO.getCycleTime(kind)
	if not cycleTimers_[kind] then return 0 end
	
	return cycleTimers_[kind]:getLeftTime()
end

function UserBO.updateCycleTime(kind)
	local timer = cycleTimers_[kind]
	if not timer then return end

	local needTime = 0

	if kind == ITEM_KIND_POWER then
		if UserMO.power_ >= POWER_MAX_VALUE then
			timer:stop()
			return
		end
		needTime = POWER_CYCLE_TIME
	elseif kind == ITEM_KIND_PROSPEROUS then
		if UserMO.prosperous_ >= UserMO.maxProsperous_ then
			timer:stop()
			return
		end
		--废墟状态下回复速度减半
		if UserMO.ruins and UserMO.ruins.isRuins then
			timer:setCycle(PROSPEROUS_CYCLE_TIME*2)
		else
			timer:setCycle(PROSPEROUS_CYCLE_TIME)
		end
		needTime = PROSPEROUS_CYCLE_TIME
	end

	if not timer:isStart() then  -- 如果之前属性是达到了上限，而定时器没有运行，则现在需要运行了
		timer:start()
		timer:setDeltaTime(needTime)
	end
end

-- 可带兵数量详情
-- commander:指挥官
function UserBO.getTakeTank(commander,awakeHeroKeyID)
	local takeTank = 0
	local lord = UserMO.queryLordByLevel(UserMO.level_)  -- 玩家等级
	takeTank = takeTank + lord.tankCount

	local pros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_)  -- 繁荣度
	takeTank = takeTank + pros.tankCount

	local command = UserMO.queryCommandByLevel(UserMO.command_)  -- 统率
	if not command then
		command = {}
		command.tankCount = 0
	end
	takeTank = takeTank + command.tankCount

	if commander and commander > 0 then  -- 指挥官
		local tankCount = HeroMO.HeroForTankCount(commander,awakeHeroKeyID)
		-- local heroDB = HeroMO.queryHero(commander)
		-- if heroDB.tankCount > 0 then
		-- 	takeTank = takeTank + heroDB.tankCount
		-- end
		takeTank = takeTank + tankCount
	end
	takeTank = takeTank + FortressMO.takeNum() --要塞官职

	local weaptankCount = WeaponryBO.WeapTakeAllTank() --军备带兵量
	takeTank = takeTank + weaptankCount

	local laboratoryCount = LaboratoryBO.getCommonTypeAttrSoldier() -- 作战实验室 兵数量
	takeTank = takeTank + laboratoryCount

	-- 总带兵数量，等级带兵数量，繁荣度可带兵数量
	return takeTank, lord.tankCount, pros.tankCount, command.tankCount , weaptankCount , laboratoryCount
end

function UserBO.onTick(dt)
	if UserMO.onlineCdTime_ > 0 then
		UserMO.onlineCdTime_ = UserMO.onlineCdTime_ - dt
	end

	for kind, timer in pairs(cycleTimers_) do
		local t, c = timer:calculate()
		if c > 0 then
			gprint("[UserBO] on Tick 添加cycle值:" , c, "kind:", kind)
			local _, award = UserMO.addCycleResource(kind, c, false)

			if kind == ITEM_KIND_POWER then
				UiUtil.showAwards({awards = {award}})
			end
		end
	end

	TKGameBO.update()

	-- print("体力剩余时间:" .. cycleTimers_[ITEM_KIND_POWER]:getLeftTime(), UserMO.power_)
	-- print("繁荣度剩余时间:" .. cycleTimers_[ITEM_KIND_PROSPEROUS]:getLeftTime(), UserMO.prosperous_)
end

function UserBO.asynLordData(doneCallback)
	local load = require("app.util.LoadInfo")
	function parseLordData(name, data)
		LoginMO.isInLogin_ = true -- 成功登录进入了游戏

		WorldMO.currentPos_ = nil

		UserBO.updateGetLord(data)
		--更新数据
		for k,v in ipairs(load.repairs) do
			local n = v.item
			local temp = v.data
			if (n[3] == true and temp) or n[3] == nil then
				if type(n[2]) == "function" then
					n[2](temp)
				else
					n[2] = temp
				end
			end
		end

		CombatMO.combatNeedFresh_ = true
		TaskBO.init()
		ActivityBO.readConfig()
		ActivityMO.clickView_ = false
		ActivityBO.adjustConfig()
		WorldBO.init()

		RankMO.myRank_ = {}
		RankMO.ranks = {}
		RankBO.init()

		--初始化新手引导
		NewerBO.init()

		SecretaryBO.updateWild() -- 根据Mill数据更新秘书

		-- PartBO.check()

		--根据等级获取军团数据
		if UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_PARTY) then
			scheduler.performWithDelayGlobal(function()
		            PartyBO.asynGetParty(function(partyData)
			            	gdump(partyData,"partyData===")
			            	if partyData then
			            		if PartyMO.myJob >= PARTY_JOB_OFFICAIL then
			            			PartyBO.asynPartyApplyList()
			            		end
			            		PartyBO.asynGetPartyMember(nil,1)
			            	end
			            	if doneCallback then doneCallback() end
		            	end, 0)
		            PartyBO.asynApplyList()
	            end, 0.05)
		else
			if doneCallback then doneCallback() end
		end

		ActivityCenterMO.boss_ = {}
		
		if ActivityCenterMO.isBossOpen_ and UserMO.level_ >= ACTIVITY_BOSS_OPEN_LEVEL then  -- 世界BOSS开放
			ActivityCenterBO.asynGetBoss(nil)
		end
	end

	SocketReceiver.clear()

	UserMO.startCheckFight_ = false

	ArmyMO.dirtyArmyData_ = true
	TankMO.dirtyTankData_ = true
	HeroMO.dirtyHeroData_ = true
	SkillMO.dirtySkillData_ = true
	ScienceMO.dirtyScienceData_ = true
	PartyMO.dirtyPartyScienceData_ = true

	load.getInfo(function()
			SocketWrapper.wrapSend(parseLordData, NetRequest.new("GetLord"))
		end)

	--拇指观看广告活动
	if ServiceBO.muzhiAdPlat() then
		MuzhiADBO.GetLoginADStatus()
		if UserMO.vip_ == 0 then
			MuzhiADBO.GetFirstGiftADStatus()
		end
		MuzhiADBO.GetExpAddStatus()
		MuzhiADBO.GetStaffingAddStatus()
		MuzhiADBO.GetAddPowerAD()
		MuzhiADBO.GetAddCommandAD()
	end
end

function UserBO.asynGetLord(doneCallback)
	local function parseGetLord(name, data)
		local awards = UserBO.updateGetLord(data)
		if doneCallback then doneCallback(awards) end
	end

	SocketWrapper.wrapSend(parseGetLord, NetRequest.new("GetLord"))
end

function UserBO.asynGetResouce(doneCallback, showAward)
	local function parseResource(name, data)
		local delta = UserBO.updateGetResource(data)
		if showAward then
			UiUtil.showAwards({awards = delta})
		end
	end

	SocketWrapper.wrapSend(parseResource, NetRequest.new("GetResource"))
end

function UserBO.asynBuyPower(doneCallback)
	local function parseBuyPower(name, data)
		gdump(data, "[UserBO] buy power")
		UserMO.powerBuy_ = UserMO.powerBuy_ + 1  -- 购买次数加1

		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[10][9],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		local _, award = UserMO.updateCycleResource(ITEM_KIND_POWER, data.power)

		UiUtil.showAwards({awards = {award}})

		Notify.notify("WIPE_COMBAT_POWER_HANDLER")

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyPower, NetRequest.new("BuyPower"))
end

function UserBO.asynUpRank(doneCallback)
	local function parseUpRank(name, data)
		gdump(data, "[UserBO] up rank")
		UserMO.rank_ = UserMO.rank_ + 1
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_RANK,type = 1,rankId = UserMO.rank_})
		--TK统计
		TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[21],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_RESOURCE, data.stone, RESOURCE_ID_STONE)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseUpRank, NetRequest.new("UpRank"))
end

function UserBO.asynUpCommand(doneCallback, useCoin)
	local function parseUpCommand(name, data)
		gdump(data, "[UserBO] up command")

		if data.success then
			UserMO.command_ = UserMO.command_ + 1
		else
		end

		local res = {}
		if useCoin then
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[22],TKGAME_USERES_TYPE_UPDATE)

			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold}
		else
			res[#res + 1] = {kind = ITEM_KIND_PROP, count = data.book, id = PROP_ID_COMMAND_BOOK}
		end
		UserMO.updateResources(res)

		if data.success then
			UserBO.triggerFightCheck()
		end

		if doneCallback then doneCallback(data.success) end

		--引导触发
		NewerBO.showNewerGuide()
		-- 埋点
		Statistics.postPoint(STATIS_POINT_COMM)
	end

	SocketWrapper.wrapSend(parseUpCommand, NetRequest.new("UpCommand", {useGold = useCoin}))
end

function UserBO.asynBuyPros(doneCallback,replyAll)
	local function parseBuyPros(name, data)
		gdump(data, "[UserBO] buy pros")
		--TK统计
		TKGameBO.onUseCoinTk(data.gold,TKText[10][10],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		UserMO.updateCycleResource(ITEM_KIND_PROSPEROUS, replyAll or UserMO.maxProsperous_)
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyPros, NetRequest.new("BuyPros"))
end

function UserBO.asynBuyFame(doneCallback, fameType)
	local function parseBuyFame(name, data)
		gdump(data, "[UserBO] buy fame")

		UserMO.canBuyFame_ = false

		local res = {}
		if FAME_MEDAL_TAKE[fameType][2] == 1 then  -- 宝石授勋
			--TK统计
			TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[23],TKGAME_USERES_TYPE_UPDATE)

			res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE}
		else
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[23],TKGAME_USERES_TYPE_UPDATE)
			
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold}
		end
		UserMO.updateResources(res)

		local level, value, up, delta = UserMO.updateUpgradeResource(ITEM_KIND_FAME, data.fameLv, data.fame)
		if doneCallback then doneCallback(up, delta) end
	end

	SocketWrapper.wrapSend(parseBuyFame, NetRequest.new("BuyFame", {type = fameType}))
end

function UserBO.asynClickFame(doneCallback)
	local function parseClickFame(name, data)
		gdump(data, "[UserBO] click fame")
		UserMO.canClickFame_ = false

		local level, value, up, delta = UserMO.updateUpgradeResource(ITEM_KIND_FAME, data.fameLv, data.fame)
		if doneCallback then doneCallback(up, delta) end
	end

	SocketWrapper.wrapSend(parseClickFame, NetRequest.new("ClickFame"))
end

function UserBO.asynSetData(doneCallback, type, value, form)
	if not form then
		form = {}
		for index=1,FIGHT_FORMATION_POS_NUM do
			form["p" .. index] = {v1 = 0, v2 = 0}
		end
	end

	local function parseSetData(name, data)
		-- gdump(data, "UserBO.asynSetData")
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseSetData, NetRequest.new("SetData", {type = type, value = value, form = form}))
end

function UserBO.asynSetPortrait(doneCallback, portrait, pendant)
	gprint("UserBO.asynSetPortrait portrait:", portrait, "pendant:", pendant)
	local function parseSetPortrait(name, data)
		UserMO.portrait_ = portrait
		UserMO.pendant_ = pendant

		if doneCallback then doneCallback() end
	end

	local value = pendant * 100 + portrait
	SocketWrapper.wrapSend(parseSetPortrait, NetRequest.new("SetPortrait", {portrait = value}))
end

function UserBO.asynBuyBuild(doneCallback)
	local function parseBuyBuild(name, data)
		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[37],TKGAME_USERES_TYPE_UPDATE)

			UserMO.updateResource(ITEM_KIND_COIN, data.gold) 
		end

		UserMO.buildCount_ = UserMO.buildCount_ + 1

		Notify.notify(LOCAL_BUY_BUILD_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyBuild, NetRequest.new("BuyBuild"))
end

function UserBO.asynGiftCode(doneCallback, content)
	local function parseGiftCode(name, data)
		local awards = nil
		if table.isexist(data, "award") then awards = PbProtocol.decodeArray(data["award"]) end

		local statisticsAward = nil
		if awards then
			statisticsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(data.state, statisticsAward) end
	end

	SocketWrapper.wrapSend(parseGiftCode, NetRequest.new("GiftCode", {code = content}))
end

-- 领取在线奖励
function UserBO.asynOnlineAward(doneCallback)
	local function parseGiftCode(name, data)
		gdump(data, "UserBO.asynOnlineAward")

		UserMO.onlineAwardIndex_ = data.id

		if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then -- 都已经领完了
			UserMO.onlineCdTime_ = 0
		else
			UserMO.onlineCdTime_ = UserMO.getOnlineAwardByIndex(UserMO.onlineAwardIndex_ + 1)
		end

		local awards = nil
		if table.isexist(data, "award") then awards = PbProtocol.decodeArray(data["award"]) end

		local statisticsAward = nil
		if awards then
			gdump(awards, "UserBO.asynOnlineAward")
			statisticsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(data.id, statisticsAward) end
	end

	SocketWrapper.wrapSend(parseGiftCode, NetRequest.new("OlAward", {code = content}))
end


function UserBO.asynScout( doneCallback )
	local function parseScout(name, data)
		UserMO.scout_ = data.scout
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseScout, NetRequest.new("GetScout"))
end


function UserBO.IsNewOpen()
	return not (GameConfig.areaId > 5)
end




--IOS 推送评论更新
function UserBO.updatePushState(data)
	if UserBO.isEnablePush() then
		UserMO.pushState = data.state
		if UserMO.pushState == IOS_PUSH_STATE_NO and table.isexist(data, "shouldPushTime") then
			UserMO.shouldPushTime = data.shouldPushTime
			-- UserMO.shouldPushTime = ManagerTimer.getTime() + 1
		else
			UserMO.shouldPushTime = nil
		end
	end
end

--提交评论状态
function UserBO.asynPushComment(doneCallback,type)
	local function parsePushComment(name, data)
		UserMO.pushState = data.state
		if UserMO.pushState == IOS_PUSH_STATE_NO and table.isexist(data, "shouldPushTime") then
			UserMO.shouldPushTime = data.shouldPushTime
		else
			UserMO.shouldPushTime = nil
		end
		if type == 3 or type == 2 then
			ServiceBO.gotoAppStorePageRaisal(CommonText[1501][4])
		end 
		
		if doneCallback then doneCallback() end
	end

	local commentState
	if type == 1 or type == 2 then --拒绝 建议
		commentState = 2
	elseif type == 3 then --好评
		commentState = 1
	end

	SocketWrapper.wrapSend(parsePushComment, NetRequest.new("PushComment", {commentState = commentState}))
end

function UserBO.isEnablePush()
	local localVersion = LoginBO.getLocalApkVersion()
	if localVersion >= IOS_PUSH_VERSION and GameConfig.environment == "mz_appstore" or GameConfig.environment == "mztkjjylfc_appstore" or device.platform == "windows" then
		return true
	end
	return false
end

--获取注册之后下一天
function UserBO.getCreateNextDay()
	local t = math.floor(UserMO.createRoleTime_/1000)
	local h = os.date("%H", t)
	local m = os.date("%M", t)
	local s = os.date("%S", t)
	return t + (23-h)*3600 + (59-m)*60 + 60 - s
end

--七日活动的当前活动天数
function UserBO.getWeekCurrDay()
	local time = UserBO.getCreateNextDay() - 24*3600
	local t = math.floor(ManagerTimer.getTime() - time)
	if t <= 0 then
		return 7
	end
	local h = math.ceil(t/(24*3600))
	if  h >= 7 then
		h = 7
	end
	return h
end

--获取七天的领奖时间，和活动时间
function UserBO.getWeekActEndTime()
	return UserBO.getCreateRoleNextNDay(7)
end

function UserBO.getWeekAwardEndTime()
	return UserBO.getCreateRoleNextNDay(10)
end

--获取注册之后N天
function UserBO.getCreateRoleNextNDay(nDay)
	nDay = nDay or 1
	nDay = math.floor(nDay)
	assert(nDay > 0, "nDay must is a interger number!")

	local t = math.floor(UserMO.createRoleTime_/1000)
	local h = os.date("%H", t)
	local m = os.date("%M", t)
	local s = os.date("%S", t)
	return t + ((nDay - 1)* 24 + 23-h)*3600 + (59-m)*60 + 60 - s
end

--零点刷新七日活动
function UserBO.asynUpdateAct()
	if UserBO.getWeekAwardEndTime() - ManagerTimer.getTime() > 0 then
		ActivityWeekBO.refTime()
	end
end

-- 矿点扫描外挂验证码回答
function UserBO.PlugInScoutMineValidCode(rhand, validCode)
	-- required string validCode = 1;//用|分割
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlugInScoutMineValidCode",{validCode = validCode}))
end

function UserBO.SynPlugInScoutMine(name, data)
	Loading.getInstance():unshow()
	require("app.dialog.VerificationDialog").new(data.validCode):push()
end

-- 点击宝箱获得奖励
function UserBO.GetGiftRewardBOX()
	local function parseResult(name, data)
		-- repeated Award award = 1;
		local awards = PbProtocol.decodeArray(data["award"])
		if table.getn(awards) > 0 then
			local AwardsDialog = require("app.dialog.AwardsDialog")
			AwardsDialog.new(awards,nil,{hadd = 76}):push()
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		else
			Toast.show(CommonText[1785])
		end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetGiftReward"), 1)
end


-- 计算某个属性的战力值
function UserBO.calcAttrFightValue(attr)
	local factor = 0
	if attr.attrName == "maxHp" then 
		factor = factor + attr.value * 1000
	elseif attr.attrName == "attack" then 
		factor = factor + attr.value * 1000
	elseif attr.attrName == "impale" or attr.attrName == "defend" or attr.attrName == "frighten" or attr.attrName == "fortitude" then
		factor = factor + attr.value * 10
	else 
		factor = factor + attr.value * 100
	end

	return factor
end