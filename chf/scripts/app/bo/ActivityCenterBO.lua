--
-- Author: gf
-- Date: 2015-10-29 10:16:36
-- 活动中心

ActivityCenterBO = {}

--
ActivityCenterBO.isCouldUpdataActivity = false
ActivityCenterBO.RegisterActivityList = {
			"ActivityMechaView",
			"ActivityRebateView",
			"ActivityFortuneView",
			"ActivityBeeView",
			"ActivityProfotoView",
			"ActivityRaffleView",
			"ActivityDestroyView",
			"ActivityTechView",
			"ActivityGeneralView",
			"ActivityConsumeDialView",
			"ActivityVacationView",
			"ActivityPartResolveView",
			"ActivityEquipCashView",
			"ActivityPartCashView",
			"ActivityGambleView",
			"ActivityPayTurntableView",
			"ActivityCelebrateView",
			"ActivityNewRaffleView",
			"ActivityTankCarnival",
			"ActivityCollection",
			"ActivityM1A2View",
			"ActivityFlower",
			"ActivityRecharge",
			"ActivityStorehouse",
			"ActivityNewYearBoss",
			"ActivityFestival",
			"ActivityPayClear",
			"ActivityWorship",
			"ActivityBandits",
			"ActivitySchool",
			"ActivityRefineMasterView",
			"ActivityNewEnergyView",
			"ActivityOwnGiftView",
			"ActivityBrotherBuffView",
			"ActivityHyperSpaceView",
			"ActivityMedalView",
			"ActivityMonopolyView",
			"ActivityRedPacketView",
			"ActivityFragExcView",
			"ActivityQuestionView",
			"ActivitySecretArmyView",
			"ActivityKingView",
		}

-- 活动警告
function ActivityCenterBO.WarningCheckWithColseActivity()
	if not ActivityCenterBO.isCouldUpdataActivity then return end
	ActivityCenterBO.isCouldUpdataActivity = false
	for index = 1 , #ActivityCenterBO.RegisterActivityList do
		if UiDirector.hasUiByName(ActivityCenterBO.RegisterActivityList[index]) then
			require("app.dialog.WarningActivityDialog").new():push()
			break
		end
	end
end

function ActivityCenterBO.update(data)
	ActivityCenterMO.activityList_ = {}
	ActivityCenterMO.activityContents_ = {}

	-- 活动警告
	ActivityCenterBO.WarningCheckWithColseActivity()

	if not data then return end

	local activities = PbProtocol.decodeArray(data["activity"])
	gdump(activities, "ActivityCenterBO.update")
	for index = 1, #activities do
		local activity = activities[index]
		gdump(activity, "ActivityCenterBO.update " .. index)

		local displayTime = activity.endTime
		if table.isexist(activity, "displayTime") then displayTime = activity.displayTime end
		if not table.isexist(activity, "minLv") then activity.minLv = 0 end
		--每日充值不用显示
		-- if activity.activityId ~= 1001 then
			ActivityCenterMO.activityList_[index] = {activityId = activity.activityId, name = activity.name, beginTime = activity.beginTime, endTime = activity.endTime, displayTime = displayTime, open = activity.open,awardId = activity.awardId, minLv = activity.minLv}
		-- end
		--启动第一个活动倒计时计数器用来首页显示
		-- if index == 1 then
		-- 	if ActivityCenterMO.runTickList[index] then
		-- 		ManagerTimer.removeTickListener(ActivityCenterMO.runTickList[index])
		-- 	end
		-- 	local cd = activity.endTime - ManagerTimer.getTime()
		-- 	if activity.endTime > 0 then
		-- 		local runTick = ManagerTimer.addTickListener(function(dt)
		-- 			if activity.endTime > 0 then
		-- 				activity.endTime = activity.endTime - dt
		-- 			end
		-- 			if activity.endTime == 0 then
		-- 				ManagerTimer.removeTickListener(runTick)
		-- 			end
		-- 		end)
		-- 		ActivityCenterMO.runTickList[index] = runTick
		-- 	end
		-- end
	end

	Notify.notify(LOCLA_ACTIVITY_CENTER_EVENT)

	-- scheduler.performWithDelayGlobal(function()
	-- 		local list = ActivityCenterBO.getShowList()
	-- 		for index = 1, #list do
	-- 			local activity = list[index]
	-- 		end
	-- 	end, 1)

	local function refresh(dt)
		if UiDirector.hasUiByName("ActivityCenterView") then return end
		
		ActivityCenterMO.activityList_ = {}
		ActivityCenterMO.activityContents_ = {}

		local function parseGetActivity(name, data)
			ActivityCenterBO.update(data)
		end

		if LoginMO.isInLogin_ then
			SocketWrapper.wrapSend(parseGetActivity, NetRequest.new("GetActionCenter"))
		end
	end

	if not ActivityCenterMO.refreshHandler_ then
		ActivityCenterMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 180)
	end

	if not ActivityCenterMO.tickHandler_ then
		ActivityCenterMO.tickHandler_ = ManagerTimer.addTickListener(ActivityCenterBO.onTick)
	end

	-- 红包
	if ActivityCenterBO.isValid(ACTIVITY_ID_REDPACKET) then
		if not ActivityCenterMO.ActivityRedPacketListener then 
			ActivityCenterMO.ActivityRedPacketListener = SocketReceiver.register("SynSendActRedBag", ActivityCenterBO.SynSendActRedBag, true)
		end
		ActivityCenterBO.SelectActRedBagInfo()
	else
		if ActivityCenterMO.ActivityRedPacketListener then
			SocketReceiver.unregister("SynSendActRedBag")
			ActivityCenterMO.ActivityRedPacketListener = nil
		end
		if RedPacketView then
			RedPacketView.close()
		end
	end
end

ActivityCenterMO.lastBossStatus_ = nil

function ActivityCenterBO.onTick(dt)
	local status, cdTime = ActivityCenterBO.getBossStatus()

	if not ActivityCenterMO.lastBossStatus_ then
		ActivityCenterMO.lastBossStatus_ = status
	elseif status ~= ActivityCenterMO.lastBossStatus_ then
		if status == ACTIVITY_BOSS_STATE_READY and ActivityCenterMO.lastBossStatus_ == ACTIVITY_BOSS_STATE_CLOSE then  -- 进入准备状态
			if ActivityCenterMO.isBossOpen_ then
				ActivityCenterBO.asynGetBoss()

				local chat = {channel = CHAT_TYPE_WORLD, sysId = 137, style = 1}
				ChatMO.addChat(chat.channel, chat.name, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, 0, nil, false)
				UiUtil.showHorn(chat)
				Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = chat})
			end
		elseif status == ACTIVITY_BOSS_STATE_FIGHTING and ActivityCenterMO.lastBossStatus_ == ACTIVITY_BOSS_STATE_READY then
			if ActivityCenterMO.isBossOpen_ then
				local chat = {channel = CHAT_TYPE_WORLD, sysId = 138, style = 1}
				ChatMO.addChat(chat.channel, chat.name, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, 0, nil, false)
				UiUtil.showHorn(chat)
				Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = chat})
			end
		end
		ActivityCenterMO.lastBossStatus_ = status
	end


	if status == ACTIVITY_BOSS_STATE_READY then
		if ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_CLOSE or ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_OVER then
			-- gprint("ActivityCenterBO onTick 11111111111 state:", ActivityCenterMO.boss_.state)
			ActivityCenterMO.boss_.state = status
			ActivityCenterBO.asynGetBoss()
		end
	elseif status == ACTIVITY_BOSS_STATE_FIGHTING then
		if ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_CLOSE or ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_READY or ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_OVER then
			-- gprint("ActivityCenterBO onTick 222222 state:", ActivityCenterMO.boss_.state)
			ActivityCenterMO.boss_.state = status
			ActivityCenterBO.asynGetBoss()
		end
	elseif status == ACTIVITY_BOSS_STATE_CLOSE then
		if ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_FIGHTING then
			ActivityCenterMO.boss_.state = ACTIVITY_BOSS_STATE_OVER
			ActivityCenterBO.asynGetBoss()
		end
	end

	if ActivityCenterMO.boss_.cdTime and ActivityCenterMO.boss_.cdTime > 0 then
		ActivityCenterMO.boss_.cdTime = ActivityCenterMO.boss_.cdTime - dt

		if ActivityCenterMO.boss_.cdTime <= 0 then
			local hasLoading = false
			if UiDirector.hasUiByName("ActivityBossView") then hasLoading = true end

			if hasLoading then Loading.getInstance():show() end
			ActivityCenterBO.asynGetBoss(function() if hasLoading then Loading.getInstance():unshow() end end)
		end
	end
end

function ActivityCenterBO.updateBoss(data)
	-- gdump(data, "ActivityCenterBO.updateBoss ..")

	if not data then return end
	
	local deltaHurt = 0
	if not ActivityCenterMO.boss_ or not ActivityCenterMO.boss_.totalHurt or ActivityCenterMO.boss_.totalHurt == 0 then
		deltaHurt = 0
	else
		deltaHurt = data.totalHurt - ActivityCenterMO.boss_.totalHurt
	end

	ActivityCenterMO.boss_ = {}
	ActivityCenterMO.boss_.cdTime = data.cdTime - ManagerTimer.getTime() + 0.99
	ActivityCenterMO.boss_.killer = data.killer
	ActivityCenterMO.boss_.autoFight = data.autoFight
	ActivityCenterMO.boss_.bless1 = data.bless1
	ActivityCenterMO.boss_.bless2 = data.bless2
	ActivityCenterMO.boss_.bless3 = data.bless3
	ActivityCenterMO.boss_.hurt = data.hurt
	ActivityCenterMO.boss_.hurtRank = data.hurtRank
	ActivityCenterMO.boss_.which = data.which
	ActivityCenterMO.boss_.bossHp = data.bossHp
	ActivityCenterMO.boss_.state = data.state
	ActivityCenterMO.boss_.totalHurt = data.totalHurt  -- boss受到的总伤害

	-- ActivityCenterMO.bossActivityState_ = data.state

	-- gdump(ActivityCenterMO.boss_, "ActivityCenterBO.updateBoss BOSS data")

	Notify.notify(LOCAL_BOSS_UPDATE_EVENT, {deltaHurt = deltaHurt})
end

function socket_error_757_callback(code)
	Notify.notify(LOCAL_BOSS_UPDATE_EVENT)
end


function ActivityCenterBO.asynGetActivityContent(doneCallback, activityId, type)
	local function parseActivityContent(name, data)
		if not ActivityCenterMO.activityContents_[activityId] then
			ActivityCenterMO.activityContents_[activityId] = {}
		end
		
		if activityId == ACTIVITY_ID_MECHA then
			ActivityCenterMO.activityContents_[activityId].mechaSingle = PbProtocol.decodeRecord(data["mechaSingle"])
			ActivityCenterMO.activityContents_[activityId].mechaTen = PbProtocol.decodeRecord(data["mechaTen"])
		elseif activityId == ACTIVITY_ID_AMY_REBATE or activityId == ACTIVITY_ID_OPENSERVER then
			if type == 1 then
				ActivityCenterMO.activityContents_[activityId].activityCond = PbProtocol.decodeArray(data["activityCond"])
				ActivityCenterMO.activityContents_[activityId].state = data.state
			elseif type == 2 then
				ActivityCenterMO.activityContents_[activityId].amyRebate = PbProtocol.decodeArray(data["amyRebate"])
			end
		elseif activityId == ACTIVITY_ID_FORTUNE or activityId == ACTIVITY_ID_PARTDIAL or activityId == ACTIVITY_ID_ENERGYSPAR or 
				activityId == ACTIVITY_ID_EQUIPDIAL or activityId == ACTIVITY_ID_TACTICSPAR then
			if type == 1 then
				local ret = {}
				ret.score = data.score
				ret.fortune = PbProtocol.decodeArray(data["fortune"])
				if table.isexist(data, "free") then
					ret.free = data.free
				else
					ret.free = 0
				end
				if table.isexist(data, "displayList") then
					ret.displayList = data.displayList
				else
					ret.displayList = {}
				end
				gdump(ret,"ActivityCenterMO.activityContents_[activityId].actFortune")
				ActivityCenterMO.activityContents_[activityId].actFortune = ret
			elseif type == 2 then
				local ret = {}
				--自己积分
				ret.score = data.score
				--排行数据
				ret.actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])
				--排序
				function sortFun(a,b)
					if a.rankValue == b.rankValue then
						return a.rankTime < b.rankTime  ---修改了协议，根据上榜时间来排序
					else
						return a.rankValue > b.rankValue
					end
				end

				table.sort(ret.actPlayerRank,sortFun)
				--是否可领
				ret.open = data.open
				--奖励详情
				ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
				gdump(ret.rankAward,"ret.rankAward===")
				--领取状态
				ret.status = data.status
				
				ActivityCenterMO.activityContents_[activityId].actFortuneRank = ret
			elseif type == 3 then
				if activityId == ACTIVITY_ID_FORTUNE then
					ActivityCenterMO.dayLotteryCount = data.count
					local rewardStatus = PbProtocol.decodeArray(data.rewardStatus)
					ActivityCenterMO.dailyTargetStates = {}
					for i, v in ipairs(rewardStatus) do
						ActivityCenterMO.dailyTargetStates[v.v1] = v.v2
					end
				elseif activityId == ACTIVITY_ID_ENERGYSPAR then
					ActivityCenterMO.dayEnergyCount = data.count
					local rewardStatus = PbProtocol.decodeArray(data.rewardStatus)
					ActivityCenterMO.dailyTargetEnergyStates = {}
					for i, v in ipairs(rewardStatus) do
						ActivityCenterMO.dailyTargetEnergyStates[v.v1] = v.v2
					end
				elseif activityId == ACTIVITY_ID_EQUIPDIAL then
					ActivityCenterMO.dayEquipCount = data.count
					local rewardStatus = PbProtocol.decodeArray(data.rewardStatus)
					ActivityCenterMO.dailyTargetEquipStates = {}
					for i, v in ipairs(rewardStatus) do
						ActivityCenterMO.dailyTargetEquipStates[v.v1] = v.v2
					end
				elseif activityId == ACTIVITY_ID_TACTICSPAR then
					ActivityCenterMO.dayTacticCount = data.count
					local rewardStatus = PbProtocol.decodeArray(data.rewardStatus)
					ActivityCenterMO.dailyTargetTacticStates = {}
					for i, v in ipairs(rewardStatus) do
						ActivityCenterMO.dailyTargetTacticStates[v.v1] = v.v2
					end
				end
			end
		elseif activityId == ACTIVITY_ID_BEE or activityId == ACTIVITY_ID_BEE_NEW then
			if type == 1 then
				local ret = {}

				local stone = PbProtocol.decodeRecord(data["stone"])
				stone.activityCond = PbProtocol.decodeArray(stone["activityCond"])
				stone.resId = RESOURCE_ID_STONE 
				ret[#ret + 1] = stone
				local silicon = PbProtocol.decodeRecord(data["silicon"])
				silicon.activityCond = PbProtocol.decodeArray(silicon["activityCond"])
				silicon.resId = RESOURCE_ID_SILICON 
				ret[#ret + 1] = silicon
				local oil = PbProtocol.decodeRecord(data["oil"])
				oil.activityCond = PbProtocol.decodeArray(oil["activityCond"])
				oil.resId = RESOURCE_ID_OIL 
				ret[#ret + 1] = oil
				local copper = PbProtocol.decodeRecord(data["copper"])
				copper.activityCond = PbProtocol.decodeArray(copper["activityCond"])
				copper.resId = RESOURCE_ID_COPPER 
				ret[#ret + 1] = copper
				local iron = PbProtocol.decodeRecord(data["iron"])
				iron.activityCond = PbProtocol.decodeArray(iron["activityCond"])
				iron.resId = RESOURCE_ID_IRON 
				ret[#ret + 1] = iron

				ActivityCenterMO.activityContents_[activityId].actBee = ret
			elseif type == 2 then
				local ret = {}
				ret.open = data.open
				ret.beeRank = PbProtocol.decodeArray(data["beeRank"])
				for index=1,#ret.beeRank do
					local beeRank = ret.beeRank[index]
					if table.isexist(beeRank, "actPlayerRank") then
						beeRank.actPlayerRank =  PbProtocol.decodeArray(beeRank["actPlayerRank"])
						function sortFun(a,b)
							if a.rankValue == b.rankValue then
								-- return a.lordId < b.lordId
								return a.rankTime < b.rankTime  ---修改了协议，根据上榜时间来排序
							else
								return a.rankValue > b.rankValue
							end
						end
						table.sort(beeRank.actPlayerRank,sortFun)
					else
						beeRank.actPlayerRank = {}
					end
				end
				ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
				ActivityCenterMO.activityContents_[activityId].actBeeRank = ret
			end
		elseif activityId == ACTIVITY_ID_PROFOTO then
			local ret = {}
			ret.profoto = PbProtocol.decodeRecord(data["profoto"])
			ret.trust = PbProtocol.decodeRecord(data["trust"])
			ret.parts = PbProtocol.decodeArray(data["parts"])
			gdump(ret,"ret==")
			ActivityCenterMO.activityContents_[activityId].data = ret
		elseif activityId == ACTIVITY_ID_TANKRAFFLE then
			local ret = {}
			if table.isexist(data, "free") then
				ret.free = data.free
			else
				ret.free = 0
			end
			ActivityCenterMO.activityContents_[activityId].data = ret
		elseif activityId == ACTIVITY_ID_TANKDESTROY then
			if type == 1 then
				local ret = {}
				if table.isexist(data, "destoryTank") then
					ret.destoryTanks = PbProtocol.decodeArray(data["destoryTank"])
					for index=1,#ret.destoryTanks do
						local destoryTank = ret.destoryTanks[index]
						destoryTank.activityCond = PbProtocol.decodeArray(destoryTank["activityCond"])[1]
					end
				end
				ActivityCenterMO.activityContents_[activityId].data = ret
			elseif type == 2 then
				local ret = {}
				ret.score = data["score"]
				ret.open = data["open"]
				ret.status = data["status"]
				if table.isexist(data, "actPlayerRank") then
					ret.actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])
				else
					ret.actPlayerRank = {}
				end
				--排序
				function sortFun(a,b)
					if a.rankValue == b.rankValue then
						-- return a.lordId < b.lordId
						return a.rankTime < b.rankTime  ---修改了协议，根据上榜时间来排序
					else
						return a.rankValue > b.rankValue
					end
				end
				table.sort(ret.actPlayerRank,sortFun)
				
				if table.isexist(data, "rankAward") then
					ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
				else
					ret.rankAward = {}
				end
				ActivityCenterMO.activityContents_[activityId].actFortuneRank = ret
			end
		elseif activityId == ACTIVITY_ID_TECH then
			local ret = {}
			if table.isexist(data, "tech") then
				ret.techList = PbProtocol.decodeArray(data["tech"])
			else
				ret.techList = {}
			end
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_GENERAL or activityId == ACTIVITY_ID_GENERAL1 then
			if type == 1 then
				local ret = {}
				if table.isexist(data,"general") then
					ret.general = PbProtocol.decodeArray(data["general"])
				else
					ret.general = {}
				end
				ret.luck = data.luck
				ret.count = data.count % data.luck
				
				ActivityCenterMO.activityContents_[activityId].data = ret
			elseif type == 2 then
				local ret = {}
				ret.score = data["score"]
				ret.open = data["open"]
				ret.status = data["status"]
				if table.isexist(data, "actPlayerRank") then
					ret.actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])
				else
					ret.actPlayerRank = {}
				end
				--排序
				function sortFun(a,b)
					if a.rankValue == b.rankValue then
						-- return a.lordId < b.lordId
						return a.rankTime < b.rankTime  ---修改了协议，根据上榜时间来排序
					else
						return a.rankValue > b.rankValue
					end
				end
				table.sort(ret.actPlayerRank,sortFun)
				
				if table.isexist(data, "rankAward") then
					ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
				else
					ret.rankAward = {}
				end
				ActivityCenterMO.activityContents_[activityId].actFortuneRank = ret
			end
		elseif activityId == ACTIVITY_ID_CONSUMEDIAL then
			if type == 1 then
				local ret = {}
				ret.score = data.score
				ret.fortune = PbProtocol.decodeArray(data["fortune"])
				if table.isexist(data, "free") then
					ret.free = data.free
				else
					ret.free = 0
				end
				if table.isexist(data, "count") then
					ret.count = data.count
				else
					ret.count = 0
				end
				if table.isexist(data, "displayList") then
					ret.displayList = data.displayList
				else
					ret.displayList = {}
				end

				gdump(ret,"ActivityCenterMO.activityContents_[activityId].actFortune")
				ActivityCenterMO.activityContents_[activityId].actFortune = ret
			elseif type == 2 then
				local ret = {}
				--自己积分
				ret.score = data.score
				--排行数据
				ret.actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])
				--排序
				function sortFun(a,b)
					if a.rankValue == b.rankValue then
						-- return a.lordId < b.lordId
						return a.rankTime < b.rankTime  ---修改了协议，根据上榜时间来排序
					else
						return a.rankValue > b.rankValue
					end
				end
				table.sort(ret.actPlayerRank,sortFun)
				--是否可领
				ret.open = data.open
				--奖励详情
				ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
				gdump(ret.rankAward,"ret.rankAward===")
				--领取状态
				ret.status = data.status
				
				ActivityCenterMO.activityContents_[activityId].actFortuneRank = ret
			end
		elseif activityId == ACTIVITY_ID_VACATION then
			local ret = {}
			--累充额度
			ret.topup = data.topup
			--0未购买 1-n购买的度假村ID
			ret.villageId = data.villageId
			--度假村
			ret.village = PbProtocol.decodeArray(data["village"])
			--度假村奖励
			ret.villageAward = PbProtocol.decodeArray(data["villageAward"])

			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_EXCHANGE_EQUIP or activityId == ACTIVITY_ID_EXCHANGE_PART
		or activityId == ACTIVITY_ID_EXCHANGE_PAPER then -- 113,114,151限时兑换活动
			local ret = {}
			if table.isexist(data, "cash") then
				ret.cash = PbProtocol.decodeArray(data["cash"])
				for index=1,#ret.cash do
					local data = ret.cash[index]
					data.atom = PbProtocol.decodeArray(data["atom"])
					data.award = PbProtocol.decodeRecord(data["award"])
				end
			else
				ret.cash = {}
			end

			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_PART_RESOLVE then
			local ret = {}
			ret.state = data.state
			ret.partResolve = PbProtocol.decodeArray(data["partResolve"])
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_SECRETARMY then
			local ret = {}
			ret.daysOfContinuousPay = data.days
			ret.activity = PbProtocol.decodeRecord(data['activity'])
			ret.awardStatus = PbProtocol.decodeArray(data['activityCond'])
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_MEDAL_RESOLVE then
			local ret = {}
			ret.state = data.state
			ret.partResolve = PbProtocol.decodeArray(data["partResolve"])
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_GAMBLE then
			local ret = {}
			ret.topup = data.topup
			ret.count = data.count
			ret.price = data.price
			ret.topupGambles = PbProtocol.decodeArray(data["topupGamble"])
			for index=1,#ret.topupGambles do
				local topupGamble = ret.topupGambles[index]
				topupGamble.awards = PbProtocol.decodeArray(topupGamble["award"])
			end
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_PAYTURNTABLE then
			local ret = {}
			ret.topup = data.topup
			ret.count = data.count
			ret.paycount = data.paycount
			ret.topupGamble = PbProtocol.decodeRecord(data["topupGamble"])
			ret.topupGamble.awards = PbProtocol.decodeArray(ret.topupGamble["award"])
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_CELEBRATE then
			if type == 1 then
				local ret = {}
				if table.isexist(data, "portrait") then --头像挂件
					ret.portrait = PbProtocol.decodeRecord(data["portrait"])
					ret.portrait.activityCond = PbProtocol.decodeArray(ret.portrait["activityCond"])[1]
				else
					ret.portrait = {}
				end
				if table.isexist(data, "payFrist") then --首充
					ret.payFrist = PbProtocol.decodeRecord(data["payFrist"])
					ret.payFrist.activityCond = PbProtocol.decodeArray(ret.payFrist["activityCond"])[1]
				else
					ret.payFrist = {}
				end
				if table.isexist(data, "payTopup") then --累充
					ret.payTopup = PbProtocol.decodeRecord(data["payTopup"])
					ret.payTopup.activityCond = PbProtocol.decodeArray(ret.payTopup["activityCond"])[1]
				else
					ret.payTopup = {}
				end
				ActivityCenterMO.activityContents_[activityId].celeData = ret
			elseif type == 2 then
				local ret = {}
				if table.isexist(data, "pray") then
					ret = PbProtocol.decodeArray(data["pray"])

					for index=1,#ret do
						local pray = ret[index]

						if ActivityCenterMO.runPrayTickList[pray.prayId] then
							ManagerTimer.removeTickListener(ActivityCenterMO.runPrayTickList[pray.prayId])
						end
						if pray.prayTime > 0 then
							pray.prayTime = pray.prayTime + 1
							local runTick = ManagerTimer.addTickListener(function(dt)
								if pray.prayTime > 0 then
									pray.prayTime = pray.prayTime - dt
								end
								if pray.prayTime <= 0 then
									pray.prayTime = 0
									ManagerTimer.removeTickListener(ActivityCenterMO.runPrayTickList[pray.prayId])
								end
							end)
							ActivityCenterMO.runPrayTickList[pray.prayId] = runTick
						end
					end
				end
				ActivityCenterMO.activityContents_[activityId].prayData = ret
			end
		elseif activityId == ACTIVITY_ID_TANKRAFFLE_NEW then
			local ret = {}
			if table.isexist(data, "free") then
				ret.free = data.free
			else
				ret.free = 0
			end
			if table.isexist(data, "lockId") then
				ret.lockId = data.lockId
			else
				ret.lockId = 0
			end
			if table.isexist(data, "tankId") then
				ret.tankIds = data["tankId"]
			else
				ret.tankIds = {}
			end
			ActivityCenterMO.activityContents_[activityId].data = ret
		elseif activityId == ACTIVITY_ID_TANK_CARNIVAL then
			local ret = {}
			if table.isexist(data, "freeNum") then
				ret.free = data.freeNum
			else
				ret.free = 0
			end
			ActivityCenterMO.activityContents_[activityId].data = ret
		elseif activityId == ACTIVITY_ID_M1A2 then  --m1a2活动
			local ret = {}
			-- if table.isexist(data, "hasFree") then
			-- 	ret.hasFree = data.hasFree
			-- else
			ret.hasFree = data.hasFree
			-- end
			ActivityCenterMO.activityContents_[activityId].data = ret
		elseif activityId == ACTIVITY_ID_QUESTION_ANSWER then  --有奖问答
			local ret = {}
			ret.queStatus = data.queStatus
			ActivityCenterMO.activityContents_[activityId] = ret
		elseif activityId == ACTIVITY_ID_PARTY_PAY then --军团充值
			local ret = {}
			ret.totalGold = data.totalGold
			ret.activityCond = PbProtocol.decodeArray(data["activityCond"])
			ActivityCenterMO.activityContents_[activityId] = ret
		end
			
		gdump(ActivityCenterMO.activityContents_,"ActivityCenterMO.activityContents_")
		if doneCallback then doneCallback() end
	end

	if activityId == ACTIVITY_ID_MECHA then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActMecha"))
	elseif activityId == ACTIVITY_ID_AMY_REBATE or activityId == ACTIVITY_ID_OPENSERVER then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActAmyfestivity",{activityId = activityId}))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActAmyRebate",{activityId = activityId}))
		end
	elseif activityId == ACTIVITY_ID_FORTUNE then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActFortune"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActFortuneRank"))
		elseif type == 3 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActFortuneDayInfo"))
		end
	elseif activityId == ACTIVITY_ID_EQUIPDIAL then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActEquipDial"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActEquipDialRank"))
		elseif type == 3 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetEquipDialDayInfo"))
		end
	elseif activityId == ACTIVITY_ID_BEE or activityId == ACTIVITY_ID_BEE_NEW then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActBee",{activityId = activityId}))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActBeeRank",{activityId = activityId}))
		end
	elseif activityId == ACTIVITY_ID_PROFOTO then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActProfoto"))
	elseif activityId == ACTIVITY_ID_PARTDIAL then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPartDial"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPartDialRank"))
		end
	elseif activityId == ACTIVITY_ID_ENERGYSPAR then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActEnergyStoneDial"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActEnergyStoneDialRank"))
		elseif type == 3 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetEnergyDialDayInfo"))
		end
	elseif activityId == ACTIVITY_ID_TACTICSPAR then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActTicDial"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActTicDialRank"))
		elseif type == 3 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetTicDialDayInfo"))
		end
	elseif activityId == ACTIVITY_ID_TANKRAFFLE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActTankRaffle"))
	elseif activityId == ACTIVITY_ID_TANKDESTROY then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActDestroy"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActDestroyRank"))
		end
	elseif activityId == ACTIVITY_ID_TECH then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActTech"))
	elseif activityId == ACTIVITY_ID_GENERAL or activityId == ACTIVITY_ID_GENERAL1 then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActGeneral",{actId=activityId}))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActGeneralRank",{actId=activityId}))
		end
	elseif activityId == ACTIVITY_ID_CONSUMEDIAL then
		if type == 1 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActConsumeDial"))
		elseif type == 2 then
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActConsumeDialRank"))
		end
	elseif activityId == ACTIVITY_ID_VACATION then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActVacationland"))
	elseif activityId == ACTIVITY_ID_EXCHANGE_EQUIP then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActEquipCash"))
	elseif activityId == ACTIVITY_ID_EXCHANGE_PART then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPartCash"))
	elseif activityId == ACTIVITY_ID_PART_RESOLVE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPartResolve"))
	elseif activityId == ACTIVITY_ID_MEDAL_RESOLVE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActMedalResolve"))
	elseif activityId == ACTIVITY_ID_GAMBLE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActGamble"))
	elseif activityId == ACTIVITY_ID_PAYTURNTABLE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPayTurntable"))
	elseif activityId == ACTIVITY_ID_CELEBRATE then
		if type == 1 then --狂欢
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActCarnival"))
		elseif type == 2 then --祈福
			SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActPray"))
		end
	elseif activityId == ACTIVITY_ID_TANKRAFFLE_NEW then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActNewRaffle"))
	elseif activityId == ACTIVITY_ID_TANK_CARNIVAL then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetTankCarnival"))
	elseif activityId == ACTIVITY_ID_M1A2 then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActM1a2"))
	elseif activityId == ACTIVITY_ID_EXCHANGE_PAPER then --图纸兑换
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetDrawingCash"))
	elseif activityId == ACTIVITY_ID_QUESTION_ANSWER then --有奖问答
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetQueAwardStatus"))
	elseif activityId == ACTIVITY_ID_SECRETARMY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetNewPayEveryday"))
	elseif activityId == ACTIVITY_ID_PARTY_PAY then  --军团充值活动
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetPartyRecharge"))
	end
end


function ActivityCenterBO.getFortuneDayAward(doneCallback, awardId)
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "ActivityCenterBO.getFortuneDayAward recieve data==")

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetFortuneDayAward", {awardId=awardId}))
end


function ActivityCenterBO.getEnergyDialDayAward(doneCallback, awardId)
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "ActivityCenterBO.getEnergyDialDayAward recieve data==")

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetEnergyDialDayAward", {awardId=awardId}))
end


function ActivityCenterBO.getEquipDialDayAward(doneCallback, awardId)
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "ActivityCenterBO.getEquipDialDayAward recieve data==")

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetEquipDialDayAward", {awardId=awardId}))
end

function ActivityCenterBO.getTacyicsDialDayAward(doneCallback, awardId)
	local function getResult(name, data)
		Loading.getInstance():unshow()

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetTicDialDayAward", {awardId=awardId}))
end


function ActivityCenterBO.asynDoActMecha(doneCallback, mecha)
	local function parseLottery(name, data)
		local function recheck()
			local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_MECHA)
			if activityContent then
				activityContent.mechaSingle.crit = data.crit
				activityContent.mechaTen.crit = data.crit
				--更新碎片
				if table.isexist(data, "twoInt") then
					local twoInt = PbProtocol.decodeRecord(data["twoInt"])
					activityContent.mechaSingle.part = twoInt.v1
					activityContent.mechaTen.part = twoInt.v2
				end
				--减少金币
				if mecha.free and mecha.free > 0 then
					mecha.free = 0
				else
					UserMO.reduceResource(ITEM_KIND_COIN, mecha.cost)
					--TK统计 
					--金币消耗
			  		TKGameBO.onUseCoinTk(mecha.cost,TKText[38],TKGAME_USERES_TYPE_CONSUME)
				end
				gdump(ActivityCenterMO.activityContents_,"ActivityCenterMO.activityContents_")
				if doneCallback then doneCallback() end
			else
				ActivityCenterBO.asynGetActivityContent(recheck, ACTIVITY_ID_MECHA,1)
			end
		end
		recheck()
	end
	SocketWrapper.wrapSend(parseLottery, NetRequest.new("DoActMecha",{mechaId = mecha.mechaId}))
end

function ActivityCenterBO.asynAssembleMecha(doneCallback, mecha)
	local function parseLottery(name, data)
		--获得坦克
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
			--TK统计 获得坦克
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_TANK then
					TKGameBO.onEvnt(TKText.eventName[1], {tankId = award.id, count = award.count})
					--更新碎片
					mecha.part = mecha.part - award.count * ACTIVITY_MECHA_MERGE_COUNT
				end
			end
		end
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseLottery, NetRequest.new("AssembleMecha",{mechaId = mecha.mechaId}))

end

function ActivityCenterBO.asynDoActAmyRebate(doneCallback,activityId,rebateId)
	local function parseAward(name, data)
		--获得金币
		--TK统计 金币获得
		TKGameBO.onReward(data.gold - UserMO.coin_, TKText[45])

		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end


		ActivityCenterBO.updateRebateCount(activityId,rebateId)

		Notify.notify(LOCAL_ACTIVITY_REBATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActAmyRebate",{rebateId = rebateId,activityId = activityId}))
end

function ActivityCenterBO.asynDoActAmyfestivity(doneCallback,activityCond,activityId)
	local function parseAward(name, data)
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end
		activityCond.status = 1
		if doneCallback then doneCallback(awards) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActAmyfestivity",{keyId = activityCond.keyId,activityId = activityId}))
end

function ActivityCenterBO.asynDoActFortune(doneCallback,activityId,fortune,type)
	local function parseAward(name, data)
		
		local actFortune_ = ActivityCenterMO.getActivityContentById(activityId).actFortune

		if type == 1 and actFortune_.free > 0 then
			actFortune_.free = actFortune_.free - 1
		else
			--扣除金币
			local cost = fortune.cost
			UserMO.reduceResource(ITEM_KIND_COIN, cost)
			--TK统计 
			--金币消耗
			if activityId == ACTIVITY_ID_FORTUNE then
				TKGameBO.onUseCoinTk(cost,TKText[49],TKGAME_USERES_TYPE_CONSUME)
			elseif activityId == ACTIVITY_ID_PARTDIAL then
				TKGameBO.onUseCoinTk(cost,TKText[51],TKGAME_USERES_TYPE_CONSUME)
			elseif activityId == ACTIVITY_ID_ENERGYSPAR then
				TKGameBO.onUseCoinTk(cost,TKText[66],TKGAME_USERES_TYPE_CONSUME)
			elseif activityId == ACTIVITY_ID_EQUIPDIAL then
				TKGameBO.onUseCoinTk(cost, TKText[68], TKGAME_USERES_TYPE_CONSUME)
			end
		end
  		--更新积分
		actFortune_.score = data.score
		--奖励
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
		end
		if doneCallback then doneCallback(actFortune_.score,awards,type) end
	end
	if activityId == ACTIVITY_ID_FORTUNE then
		SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActFortune",{fortuneId = fortune.fortuneId}))
	elseif activityId == ACTIVITY_ID_PARTDIAL then
		SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActPartDial",{fortuneId = fortune.fortuneId}))
	elseif activityId == ACTIVITY_ID_ENERGYSPAR then
		SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActEnergyStoneDial",{fortuneId = fortune.fortuneId}))
	elseif activityId == ACTIVITY_ID_EQUIPDIAL then
		SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActEquipDial",{fortuneId = fortune.fortuneId}))
	elseif activityId == ACTIVITY_ID_TACTICSPAR then
		SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActTicDial",{fortuneId = fortune.fortuneId}))
	end
end


function ActivityCenterBO.asynGetRankAward(doneCallback,activityId,rankType,rankData)
	local function parseAward(name, data)

		if rankData then
			rankData.status = 1
		end
		
		--奖励
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end
		if doneCallback then doneCallback() end
	end
	
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetRankAward",{activityId = activityId,rankType = rankType}))
end

function ActivityCenterBO.asynReceiveAward(doneCallback, activityId, activityCond)
	local function parseActivityAward(name, data)
		-- gdump(data, "[ActivityBO] asynReceiveAward")

		local awards = PbProtocol.decodeArray(data["award"])

		--TK统计
		for index=1,#awards do
			local award = awards[index]
			if award.type == ITEM_KIND_COIN then
				TKGameBO.onReward(award.count, TKText[48])
			end
		end

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		activityCond.status = 1

		UiUtil.showAwards(statsAward)

		Notify.notify(LOCLA_ACTIVITY_CENTER_EVENT)

		if doneCallback then doneCallback(statsAward, activityCond) end
	end

	SocketWrapper.wrapSend(parseActivityAward, NetRequest.new("GetActivityAward", {activityId = activityId, keyId = activityCond.keyId}))
end

function ActivityCenterBO.asynDoActProfoto(doneCallback,activityId)
	local function parseActivityAward(name, data)
		--碎片更新
		local parts = PbProtocol.decodeArray(data["parts"])
		gdump(parts,"ActivityCenterBO.asynDoActProfoto==")
		local activityContent = ActivityCenterMO.getActivityContentById(activityId).data
		local res = {}
		for index=1,#parts do
			local data = parts[index]
			res[#res + 1] = {kind = ITEM_KIND_PROP, count = data.count, id = data.propId}
		end
		if #res > 0 then
			UserMO.updateResources(res)
		end
		
		activityContent.parts = parts

		--获得宝图
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		UiUtil.showAwards(statsAward)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseActivityAward, NetRequest.new("DoActProfoto"))
end
--集字活动
-- function ActivityCenterBO.asynDoActWords(doneCallback,activityId)
-- 	local function parseActivityAward(name,data)
-- 		local parts = PbProtocol.decodeArray(data["协议字段"])
-- 		local activityContent = ActivityCenterMO.getActivityContentById(activityId).data
-- 		local res = {}
-- 		for index = 1,#parts do
-- 			local data =parts[index]
-- 			res[#res + 1] = {kind = ITEM_KIND_PROP,count = data.count,id = data.propId}
-- 		end
-- 		if #res > 0 then
-- 			UserMO.updateResources(res)
-- 		end
-- 		activityContent.parts = parts
-- 		--获得字样
-- 		local awards = PbProtocol.decodeArray(data["协议字段"])
-- 		local statsAward = nil
-- 		if awards then
-- 			statsAward = CombatBO.addAwards(awards)
-- 		end
-- 		UiUtil.showAwards(statsAward)
-- 		if doneCallback then doneCallback() end
-- 	end
-- 	SocketWrapper.wrapSend(parseActivityAward, NetRequest.new("协议字段"))
-- end

function ActivityCenterBO.asynUnfoldProfoto(doneCallback,useGold)
	local function parseActivityAward(name, data)
		if useGold then
			--金币减少
			UserMO.reduceResource(ITEM_KIND_COIN, PROFOTO_UNFOLD_COIN)
			--TK统计 
			--金币消耗
	  		TKGameBO.onUseCoinTk(PROFOTO_UNFOLD_COIN,TKText[50],TKGAME_USERES_TYPE_CONSUME)
		end
		local res = {}
		--宝图更新
		local profoto = PbProtocol.decodeRecord(data["profoto"])
		gdump(profoto,"profoto==")
		res[#res + 1] = {kind = ITEM_KIND_PROP, count = profoto.count, id = profoto.propId}
		
		--信物更新
		local trust = PbProtocol.decodeRecord(data["trust"])
		gdump(trust,"trust==")
		res[#res + 1] = {kind = ITEM_KIND_PROP, count = trust.count, id = trust.propId}

		if #res > 0 then
			gdump(res,"res==")
			UserMO.updateResources(res)
		end
		
		--获得奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseActivityAward, NetRequest.new("UnfoldProfoto"))
end

function ActivityCenterBO.asynDoActTankRaffle(doneCallback,activityId,type)
	local function parseAward(name, data)
		
		local contentData = ActivityCenterMO.getActivityContentById(activityId).data

		if type == 1 and contentData.free > 0 then
			contentData.free = contentData.free - 1
		else
			--扣除金币
			local cost
			if type == 1 then
				cost = RAFFLE_NEED_COIN
			elseif type == 2 then
				cost = RAFFLE_NEED_COIN_10
			end
			UserMO.reduceResource(ITEM_KIND_COIN, cost)
			--TK统计 
			--金币消耗
			TKGameBO.onUseCoinTk(cost,TKText[52],TKGAME_USERES_TYPE_CONSUME)
		end

		ActivityCenterMO.raffleColors = {}
		local outColor = {}
		for index = 1, #data.color do
			local out = {}
			out.key = index
			out.value = data.color[index]
			out.def = false
			outColor[#outColor + 1] = out
		end
		local hasOnce = false
		for index = 1, #outColor - 1 do
			local idata = outColor[index]
			for ndex = index + 1 , #outColor do
				local ndata = outColor[ndex]
				if idata.value == ndata.value then
					idata.def = true
					ndata.def = true
					hasOnce = true
				end
			end
		end
		for index = 1, #outColor do
			local data = outColor[index]
			if not hasOnce and data.key == 1 then
				data.def = true
			end
			ActivityCenterMO.raffleColors[data.key] = data
		end

		-- ActivityCenterMO.raffleColors = data.color
		-- gdump(ActivityCenterMO.raffleColors,"color===")
		--奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActTankRaffle",{type = type}))
end

function ActivityCenterBO.asynDoActTankCarnival(activityId,allLine,doneCallback)
	local function parseAward(name, data)
		local contentData = ActivityCenterMO.getActivityContentById(activityId).data
		if contentData.free > 0 then
			contentData.free = contentData.free - 1
		else
			--扣除金币
			local cost = CARNIVAL_NEED_COIN
			if allLine == 1 then
				cost = CARNIVAL_NEED_COIN_ALL
			end
			UserMO.reduceResource(ITEM_KIND_COIN, cost)
			--TK统计 
			--金币消耗
			TKGameBO.onUseCoinTk(cost,TKText[64],TKGAME_USERES_TYPE_CONSUME)
		end
		-- gdump(ActivityCenterMO.raffleColors,"color===")
		--奖励
		local awards = PbProtocol.decodeArray(data["rewards"])
		if doneCallback then doneCallback(data.equateId,awards) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("TankCarnivalReward",{allLine=allLine}))
end

function ActivityCenterBO.asynDoActTech(doneCallback,useData)
	local function parseAward(name, data)
		
		--奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		--更新消耗
		UserMO.reduceResource(ITEM_KIND_PROP, useData.usePropcount, useData.usePropId)

		Notify.notify(LOCLA_ACTIVITY_CENTER_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActTech",{techId = useData.techId}))

end

function ActivityCenterBO.updateActEDayPay(data)
	if not data then return end
	ActivityCenterMO.dayPayData.state = data.state
	ActivityCenterMO.dayPayData.goldBoxId = data.goldBoxId
	ActivityCenterMO.dayPayData.propBoxId = data.propBoxId
end

function ActivityCenterBO.asynGetActEDayPay(doneCallback)
	local function parseAward(name, data)
		ActivityCenterBO.updateActEDayPay(data)

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetActEDayPay"))

end

function ActivityCenterBO.asynDoActEDayPay(doneCallback)
	local function parseAward(name, data)
		--奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end
		ActivityCenterMO.dayPayData.state = 2
		Notify.notify(LOCAL_DAYPAY_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActEDayPay"))

end

function ActivityCenterBO.asynDoActGeneral(doneCallback,general,actId)
	local function parseAward(name, data)

		local cost = general.price
		UserMO.reduceResource(ITEM_KIND_COIN, cost)
		--TK统计 
		--金币消耗
		TKGameBO.onUseCoinTk(cost,TKText[53],TKGAME_USERES_TYPE_CONSUME)

		--奖励
		local awards = PbProtocol.decodeArray(data["award"])
		-- gdump(awards,"ActivityCenterBO.asynDoActGeneral .. awards==")
		local heros = {}
		for index=1,#awards do
			local award = awards[index]
			local hero = {}
			hero.heroId = award.id
			heros[#heros + 1] = hero
			--TK统计
			TKGameBO.onEvnt(TKText.eventName[15], {heroId = hero.heroId})
		end
		-- gdump(heros,"ActivityCenterBO.asynDoActGeneral .. heros==")

		local activityContent = ActivityCenterMO.getActivityContentById(actId).data
		activityContent.count = data.count % activityContent.luck

		Notify.notify(LOCAL_ACT_GENERAL_UPDATE_EVENT)
		if doneCallback then doneCallback(heros) end

		HeroBO.updateMyHeros()
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActGeneral",{generalId = general.generanlId,actId = actId}))
end





--宝图是否可合成
function ActivityCenterBO.profotoCanCompose(activityId)
	local activityContent = ActivityCenterMO.getActivityContentById(activityId).data
	for index=1,#activityContent.parts do
		local part = activityContent.parts[index]
		if part.count == 0 then return false end
	end
	return true
end


--字是否能合成字牌 --集字活动
-- function ActivityCenterMO.wordsCanCompose(activityId)
-- 	local activityContent = ActivityCenterMO.getActivityContentById(activityId).data
-- 	for index=1,#activityContent.parts do
-- 		local part = activityContent.parts[index]
-- 		if part.count == 0 then return false end
-- 	end
-- 	return true
-- end


function ActivityCenterBO.formatTime(cd)
	local str
	local time = ManagerTimer.time(cd)
	if time.day > 0 then
		str = string.format("%dd%02d:%02d:%02d", time.day, time.hour, time.minute, time.second)
	else
		str = string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
	end
	return str
end

function ActivityCenterBO.updateRebateCount(activityId,rebateId)
	local amyRebateData_ = ActivityCenterMO.getActivityContentById(activityId).amyRebate
	gdump(amyRebateData_,rebateId)
	for index=1,#amyRebateData_ do
		local data = amyRebateData_[index]
		if data.rebateId == rebateId then
			data.status = data.status - 1
		end
	end
end

function ActivityCenterBO.getRebateCount(activityId,rebateId)
	local amyRebateData_ = ActivityCenterMO.getActivityContentById(activityId).amyRebate
	for index=1,#amyRebateData_ do
		local data = amyRebateData_[index]
		--由于安卓和IOS共用一个30元档位，所以这里特殊处理
		if (device.platform == "windows" or device.platform == "android") and rebateId == 2 then 
			rebateId = 8
		end
		if (device.platform == "windows" or device.platform == "android") and rebateId == 14 then 
			rebateId = 20
		end
		if data.rebateId == rebateId then
			return data.status
		end
	end
	return 0
end

function ActivityCenterBO.getRebateCountAll()
	if not ActivityCenterMO.getActivityContentById(ACTIVITY_ID_AMY_REBATE) then return 0 end
	local amyRebateData_ = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_AMY_REBATE).amyRebate
	local count = 0
	if amyRebateData_ and #amyRebateData_ > 0 then
		for j=1,#amyRebateData_ do
			local data = amyRebateData_[j]
			if data.status and data.status > 0 then
				count = count + data.status
			end
		end
	end
	return count
end

function ActivityCenterBO.getMaxActivityCond(activityConds)
	local cond = 0
	for index=1,#activityConds do
		local activityCond = activityConds[index]
		if cond < activityCond.cond then
			cond = activityCond.cond
		end
	end
	return cond
end



function ActivityCenterBO.getActivityById(activityId)
	for index=1,#ActivityCenterMO.activityList_ do
		local activity = ActivityCenterMO.activityList_[index]
		if activity.activityId == activityId then
			return activity
		end
	end
	return nil
end


function ActivityCenterBO.getMyFortuneRank(activityId)
	local myRank = CommonText[768]
	local rankList = ActivityCenterMO.activityContents_[activityId].actFortuneRank.actPlayerRank
	if rankList and #rankList > 0 then
		for index=1,#rankList do
			local player = rankList[index]
			if player.lordId == UserMO.lordId_ then
				return index
			end
		end
	end
	return myRank
end

function ActivityCenterBO.getMyFortuneRankData(activityId)
	local rankList = ActivityCenterMO.activityContents_[activityId].actFortuneRank.actPlayerRank
	if rankList and #rankList > 0 then
		for index=1,#rankList do
			local player = rankList[index]
			if player.lordId == UserMO.lordId_ then
				return player
			end
		end
	end
	return nil
end


function ActivityCenterBO.getActivityBeeSchedule(data)
	local schedule = 0
	for index=1,#data.activityCond do
		local activityCond = data.activityCond[index]
		if data.state >= activityCond.cond then
			schedule = index
		end
	end

	return schedule
end

function ActivityCenterBO.getBeeRankFirst(beeRank)
	local name = ""
	for index=1,#beeRank.actPlayerRank do
		if index == 1 then
			name = beeRank.actPlayerRank[index].nick
		end
	end
	return name
end

function ActivityCenterBO.getMyBeeRank(rankList)
	if rankList and #rankList > 0 then
		for index=1,#rankList do
			local player = rankList[index]
			player.rank = index
			if player.lordId == UserMO.lordId_ then
				return player
			end
		end
	end
	return nil
end

function ActivityCenterBO.getCanAwardBee(actBee)
	local count = 0
	for index=1,#actBee.activityCond do
		local activityCond = actBee.activityCond[index]
		if actBee.state >= activityCond.cond and activityCond.status == 0 then
			count = count + 1
		end
	end
	return count
end


function ActivityCenterBO.getTechDataByType(type)
	local list = {}
	local techList = ActivityCenterMO.activityContents_[ACTIVITY_ID_TECH].techList
	for index=1,#techList do
		local tech = techList[index]
		if tech.type == type then
			list[#list + 1] = tech
		end
	end
	function sortFun(a,b)
		return a.techId < b.techId
	end
	table.sort(list,sortFun)
	return list
end

function ActivityCenterBO.isValid(activityId)
	local activity = ActivityCenterBO.getActivityById(activityId)
	if not activity then return false end

	if not activity.open then return false end

	if ManagerTimer.getTime() <= activity.endTime then return true
	else return false end
end


function ActivityCenterBO.asynGetBoss(doneCallback)
	local function parseGetBoss(name, data)
		ActivityCenterBO.updateBoss(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetBoss, NetRequest.new("GetBoss"))
end

function ActivityCenterBO.getBossStatus()
	--当前系统时间
	local date = os.date("*t", ManagerTimer.getTime())
	local wday = date.wday
	-- local hour = date.hour
	-- local min = date.min
	-- local sec = date.sec

	local today = 0
	if wday == 1 then
		today = 7
	else
		today = wday - 1
	end

	local curTime = os.time(date)

	for index = 1, #ACTIVITY_BOSS_OPEN_DAY do
		if ACTIVITY_BOSS_OPEN_DAY[index] == today then
			local readyStartTime = os.time({year = date.year, month = date.month, day = date.day, hour = ACTIVITY_BOSS_READY_HOUR_S, min = ACTIVITY_BOSS_READY_MIN_S, sec = 0})
			local readyEndTime = os.time({year = date.year, month = date.month, day = date.day, hour = ACTIVITY_BOSS_READY_HOUR_E, min = ACTIVITY_BOSS_READY_MIN_E, sec = 0})
			local fightEndTime = os.time({year = date.year, month = date.month, day = date.day, hour = ACTIVITY_BOSS_FIGHTING_HOUR_E, min = ACTIVITY_BOSS_FIGHTING_MIN_E, sec = 0})

			local leftTime = 0

			if curTime >= readyStartTime and curTime < readyEndTime then
				leftTime = os.difftime(readyEndTime, curTime)
				return ACTIVITY_BOSS_STATE_READY, leftTime
			elseif curTime >= readyEndTime and curTime < fightEndTime then
				leftTime = os.difftime(fightEndTime, curTime)
				return ACTIVITY_BOSS_STATE_FIGHTING, leftTime
			-- elseif curTime >= fightEndTime then
				-- return ACTIVITY_BOSS_STATE_CLOSE, 0
			end
		end
	end
	return ACTIVITY_BOSS_STATE_CLOSE, 0
end

-- 根据当前的祝福等级blessLv，获得祝福到下一级需要花费的金币数量
function ActivityCenterBO.getBlessPrice(blessLv)
	local config = {20, 40, 80, 120, 160, 240, 320, 400, 600, 1000}
	return config[blessLv + 1]
end

function ActivityCenterBO.asynGetBossHurtRank(doneCallback)
	local function parseGetBossHurtRank(name, data)
		ActivityCenterMO.boss_.hurt = data.hurt
		ActivityCenterMO.boss_.hurtRank = data.rank
		ActivityCenterMO.boss_.canReceive = data.canGet -- true可以领取; false不可领取

		local rankData = PbProtocol.decodeArray(data.hurtRank)
		if doneCallback then doneCallback(rankData) end
	end
	SocketWrapper.wrapSend(parseGetBossHurtRank, NetRequest.new("GetBossHurtRank"))
end

function ActivityCenterBO.asynSetBossAutoFight(doneCallback, isAutoFight)
	local function parseSetBossAutoFight(name, data)
		if isAutoFight then
			ActivityCenterMO.boss_.autoFight = 1
		else
			ActivityCenterMO.boss_.autoFight = 0
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseSetBossAutoFight, NetRequest.new("SetBossAutoFight", {autoFight = isAutoFight}))
end

function ActivityCenterBO.asynBlessBossFight(doneCallback, index)
	local function parseBlessBossFight(name, data)
		if index == 1 then ActivityCenterMO.boss_.bless1 = data.lv
		elseif index == 2 then ActivityCenterMO.boss_.bless2 = data.lv
		elseif index == 3 then ActivityCenterMO.boss_.bless3 = data.lv
		end
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseBlessBossFight, NetRequest.new("BlessBossFight", {index = index}))
end

function ActivityCenterBO.asynFightBoss(doneCallback)
	local function parseFightBoss(name, data)
		if data.result == 2 then
			ActivityCenterMO.boss_.cdTime = data.coldTime - ManagerTimer.getTime() + 0.99
			-- Toast.show("WARNING: CD TIME")
			if doneCallback then doneCallback(false) end
			return
		end

		if data.result > 0 then  -- BOSS
			ActivityCenterMO.boss_.killer = UserMO.nickName_
			ActivityCenterMO.boss_.state = ACTIVITY_BOSS_STATE_DIE

			CombatMO.curBattleStar_ = 3
		else
			CombatMO.curBattleStar_ = 0
		end

		ActivityCenterMO.bossBalance_.hurtDelta = data.hurt - ActivityCenterMO.boss_.hurt  -- 此次伤害总值

		ActivityCenterMO.beforeBattleWhich_ = ActivityCenterMO.boss_.which -- 保存战斗之前的血条状态信息，用于显示战斗前的BOSS

		ActivityCenterMO.boss_.hurt = data.hurt
		ActivityCenterMO.boss_.hurtRank = data.rank
		ActivityCenterMO.boss_.which = data.which
		ActivityCenterMO.boss_.bossHp = data.bossHp

		ActivityCenterMO.boss_.cdTime = data.coldTime + ACTIVITY_BOSS_COLD_CD - ManagerTimer.getTime() + 0.99

		local awards = PbProtocol.decodeArray(data.award)
		CombatMO.curBattleAward_ = CombatBO.addAwards(awards)

		local formation = TankMO.getFormationByType(FORMATION_FOR_BOSS)
		local defFormat = TankMO.getEmptyFormation(TANK_BOSS_CONFIG_ID)
		-- defFormat[TANK_BOSS_POSITION_INDEX].tankId = TANK_BOSS_CONFIG_ID
		defFormat[TANK_BOSS_POSITION_INDEX].count = 1

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"], formation, defFormat)

		CombatMO.curChoseBattleType_ = COMBAT_TYPE_BOSS
		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive
		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData

		BattleMO.reset()
		BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		BattleMO.setFightData(CombatMO.curBattleFightData_)

		if doneCallback then doneCallback(true) end
	end
	SocketWrapper.wrapSend(parseFightBoss, NetRequest.new("FightBoss"))
end

function ActivityCenterBO.asynBuyBossCd(doneCallback, leftSecond)
	local function parseBuyBossCd(name, data)
		ActivityCenterMO.boss_.cdTime = 0  -- 清除CD时间
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		if leftSecond > ACTIVITY_BOSS_COLD_CD then leftSecond = ACTIVITY_BOSS_COLD_CD end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseBuyBossCd, NetRequest.new("BuyBossCd", {s = leftSecond}))
end

function ActivityCenterBO.asynBossHurtAward(doneCallback)
	local function parseBuyBossCd(name, data)

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)

		ActivityCenterMO.boss_.canReceive = false

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseBuyBossCd, NetRequest.new("BossHurtAward"))
end


function ActivityCenterBO.asynDoActConsumeDial(doneCallback,activityId,fortune,type)
	local function parseAward(name, data)
		
		local actFortune_ = ActivityCenterMO.getActivityContentById(activityId).actFortune

		if type == 1 and actFortune_.free > 0 then
			actFortune_.free = actFortune_.free - 1
		else
			--扣除次数
			actFortune_.count = actFortune_.count - type
		end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[29] .. type)

  		--更新积分
		actFortune_.score = data.score
		--奖励
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
		end
		if doneCallback then doneCallback(actFortune_.score,awards,type) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActConsumeDial",{fortuneId = fortune.fortuneId}))
end

function ActivityCenterBO.asynBuyActVacationland(doneCallback,villageId,cost)
	local function parseAward(name, data)
		--扣除金币
		UserMO.reduceResource(ITEM_KIND_COIN, cost)
		--TK统计 
		--金币消耗
		TKGameBO.onUseCoinTk(cost,TKText[56],TKGAME_USERES_TYPE_CONSUME)

		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_VACATION)
		activityContent.villageId = villageId

		--第一天奖励状态变为可领
		local villageAward = ActivityCenterBO.getVillageAwardById(villageId)
		villageAward[1].state = 1

		Notify.notify(LOCAL_ACTIVITY_VACATION_UPDATE_EVENT)

		--清除世界缓存，更新建筑外观
		WorldMO.clearMapData_ = true
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("BuyActVacationland",{villageId = villageId}))
end

function ActivityCenterBO.asynDoActVacationland(doneCallback,villageAward)
	local function parseAward(name, data)
		villageAward.status = 1
		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end
		
		Notify.notify(LOCAL_ACTIVITY_VACATION_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActVacationland",{landId = villageAward.landId}))
end

function ActivityCenterBO.asynDoActPartResolve(doneCallback,partResolve)
	local function parseAward(name, data)
		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_PART_RESOLVE)
		activityContent.state = activityContent.state - partResolve.count

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActPartResolve",{resolveId = partResolve.resolveId}))
end

function ActivityCenterBO.asynDoActMedalResolve(doneCallback, medalResolve)
	local function parseAward(name, data)
		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_MEDAL_RESOLVE)
		activityContent.state = activityContent.state - medalResolve.count

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActMedalResolve",{resolveId = medalResolve.resolveId}))
end

function ActivityCenterBO.asynRefshEquipCash(doneCallback,oldCash)
	local function parseAward(name, data)
		--是否免费
		if oldCash.free == 0 then
			--扣除金币
			UserMO.reduceResource(ITEM_KIND_COIN, oldCash.price)
			--TK统计 
			--金币消耗
			TKGameBO.onUseCoinTk(oldCash.price,TKText[57],TKGAME_USERES_TYPE_CONSUME)
		end
		gdump(oldCash,"oldCash")
		local newCash = PbProtocol.decodeRecord(data["cash"])
		newCash.atom = PbProtocol.decodeArray(newCash["atom"])
		newCash.award = PbProtocol.decodeRecord(newCash["award"])
		gdump(newCash,"newCash")

		oldCash.cashId = newCash.cashId
		oldCash.formulaId = newCash.formulaId
		oldCash.state = newCash.state
		oldCash.free = newCash.free
		oldCash.price = newCash.price
		oldCash.atom = newCash.atom
		oldCash.award = newCash.award
		

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("RefshEquipCash",{cashId = oldCash.cashId}))
end

function ActivityCenterBO.asynDoEquipCash(doneCallback,cash)
	local function parseAward(name, data)
		--获得合成道具
		local award = PbProtocol.decodeRecord(data["award"])
		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[30], {name = UserMO.getResourceData(award.type,award.id).name})
		
		--减少次数
		cash.state = cash.state - 1
		local costList = PbProtocol.decodeArray(data["costList"])
		--减少材料
		for index=1,#costList do
			local prop = costList[index]
			if prop.type == ITEM_KIND_EQUIP then
				EquipMO.removeEquipByKeyId(prop.keyId)
			elseif prop.type == ITEM_KIND_PART then
				PartMO.part_[prop.keyId] = nil
			else
				UserMO.reduceResource(prop.type,prop.count,prop.id)
			end
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoEquipCash",{cashId = cash.cashId}))
end


function ActivityCenterBO.asynRefshPartCash(doneCallback,oldCash)
	local function parseAward(name, data)
		--是否免费
		if oldCash.free == 0 then
			--扣除金币
			UserMO.reduceResource(ITEM_KIND_COIN, oldCash.price)
			--TK统计 
			--金币消耗
			TKGameBO.onUseCoinTk(oldCash.price,TKText[58],TKGAME_USERES_TYPE_CONSUME)
		end
		gdump(oldCash,"oldCash")
		local newCash = PbProtocol.decodeRecord(data["cash"])
		newCash.atom = PbProtocol.decodeArray(newCash["atom"])
		newCash.award = PbProtocol.decodeRecord(newCash["award"])
		gdump(newCash,"newCash")

		oldCash.cashId = newCash.cashId
		oldCash.formulaId = newCash.formulaId
		oldCash.state = newCash.state
		oldCash.free = newCash.free
		oldCash.price = newCash.price
		oldCash.atom = newCash.atom
		oldCash.award = newCash.award
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("RefshPartCash",{cashId = oldCash.cashId}))
end

function ActivityCenterBO.asynDoPartCash(doneCallback,cash)
	local function parseAward(name, data)
		--获得合成道具
		local award = PbProtocol.decodeRecord(data["award"])
		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[31], {name = UserMO.getResourceData(award.type,award.id).name})

		--减少次数
		cash.state = cash.state - 1
		local costList = PbProtocol.decodeArray(data["costList"])
		--减少材料
		for index=1,#costList do
			local prop = costList[index]
			if prop.type == ITEM_KIND_EQUIP then
				EquipMO.removeEquipByKeyId(prop.keyId)
			elseif prop.type == ITEM_KIND_PART then
				PartMO.part_[prop.keyId] = nil
			else
				UserMO.reduceResource(prop.type,prop.count,prop.id)
			end
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoPartCash",{cashId = cash.cashId}))
end

function ActivityCenterBO.asynDoActGamble(doneCallback,price)
	local function parseAward(name, data)

		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_GAMBLE)

		--减少次数
		activityContent.count = activityContent.count - 1
		--更新已下注档位
		activityContent.price = price
		--扣除金币
		UserMO.reduceResource(ITEM_KIND_COIN, price)
		--TK统计 
		--金币消耗
		TKGameBO.onUseCoinTk(price,TKText[59],TKGAME_USERES_TYPE_CONSUME)
		
		if doneCallback then doneCallback(data.gold) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActGamble"))
end

function ActivityCenterBO.asynDoActPayTurntable(doneCallback, times)
	local function parseAward(name, data)

		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_PAYTURNTABLE)

		--减少次数
		activityContent.count = activityContent.count - times
		
		local awards = PbProtocol.decodeArray(data["award"])

		if doneCallback then doneCallback(awards) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActPayTurntable",{count = times}))
end

function ActivityCenterBO.getVillageAwardById(villageId)
	local villageAward = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_VACATION).villageAward

	
	local list = {}
	for j=1,#villageAward do
		local award = villageAward[j]
		if villageId == award.villageId then
			list[#list + 1] = award
		end
	end

	local function sortFun(a,b)
		return a.onday < b.onday
	end
	table.sort(list,sortFun)

	-- gdump(list,villageId)
	return list
end

--获得当前奖池数据（下注赢金币）
function ActivityCenterBO.getCurrentGamble()
	local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_GAMBLE)
	local lastPrice = activityContent.price
	if lastPrice > 0 then
		local idx
		for index=1,#activityContent.topupGambles do
			local topupGamble = activityContent.topupGambles[index]
			if lastPrice == topupGamble.price then
				idx = index
				break 
			end
		end
		if idx == #activityContent.topupGambles then
			return activityContent.topupGambles[idx]
		else
			return activityContent.topupGambles[idx + 1]
		end
	else
		return activityContent.topupGambles[1]
	end
end

--获得转盘结果IDX(下注赢金币)
function ActivityCenterBO.getAwardGambleIdx(currentTopupGamble,gold)
	for index=1,#currentTopupGamble.awards do
		local award = currentTopupGamble.awards[index]
		if gold == award.count then
			return index
		end
	end
end

--获得转盘结果IDX(充值转盘)
function ActivityCenterBO.getAwardPayTurntableIdx(currentTopupGamble,getAward)
	for index=1,#currentTopupGamble.awards do
		local award = currentTopupGamble.awards[index]
		if getAward.type == award.type and getAward.id == award.id and getAward.count == award.count then
			return index
		end
	end
end


function ActivityCenterBO.formatPrayTime(cd)
	local str
	local time = ManagerTimer.time(cd)
	if time.hour > 0 then
		str = string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
	else
		str = string.format("%02d:%02d", time.minute, time.second)
	end
	return str
end

function ActivityCenterBO.asynDoActPray(doneCallback,prayCardId,prayId)
	local function parseAward(name, data)
		--减少道具
		UserMO.reduceResource(ITEM_KIND_PROP, 1, prayCardId)
		local newPray = PbProtocol.decodeRecord(data["pray"])
		local prayData = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_CELEBRATE).prayData
		
		for index = 1,#prayData do
			local pray = prayData[index]
			if pray.prayId == newPray.prayId then
				pray.card = newPray.card
				pray.prayTime = newPray.prayTime + 1
				if ActivityCenterMO.runPrayTickList[pray.prayId] then
					ManagerTimer.removeTickListener(ActivityCenterMO.runPrayTickList[pray.prayId])
				end
				if pray.prayTime > 0 then
					local runTick = ManagerTimer.addTickListener(function(dt)
						if pray.prayTime > 0 then
							pray.prayTime = pray.prayTime - dt
						end
						if pray.prayTime <= 0 then
							pray.prayTime = 0
							ManagerTimer.removeTickListener(ActivityCenterMO.runPrayTickList[pray.prayId])
						end
					end)
					ActivityCenterMO.runPrayTickList[pray.prayId] = runTick
				end
			end
		end
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActPray",{prayCardId = prayCardId, prayId = prayId}))
end

function ActivityCenterBO.asynActPrayAward(doneCallback,type,pray)
	local function parseAward(name, data)
		
		if table.isexist(data, "gold") then 
			local res = {}
			--TK统计
			TKGameBO.onUseCoinTk(data.gold,TKText[60],TKGAME_USERES_TYPE_UPDATE)
			res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 
			UserMO.updateResources(res)
		end
		
		--改变状态
		pray.card = 0
		pray.prayTime = 0
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("ActPrayAward",{type = type, prayId = pray.prayId}))
end



function ActivityCenterBO.asynDoActNewRaffle(doneCallback,activityId,type)
	--测试数据
	-- ActivityCenterMO.newRaffleColors = {1,1,1}
	-- ActivityCenterMO.newRaffleResultTankId = 25

	-- local raffleData = {
	-- 	free = 0,
	-- 	lockId = 29,
	-- 	tankIds = {25,26,29,30}
	-- }
	-- local resultIdx
	-- for index=1,#raffleData.tankIds do
	-- 	local tankId = raffleData.tankIds[index]
	-- 	if ActivityCenterMO.newRaffleResultTankId == tankId then
	-- 		resultIdx = index
	-- 		break
	-- 	end
	-- end
	-- --插入坦克颜色
	-- table.insert(ActivityCenterMO.newRaffleColors,resultIdx)
	-- gdump(ActivityCenterMO.newRaffleColors,"color===")

	-- if doneCallback then doneCallback() end

	-- do return end

	--测试数据

	local function parseAward(name, data)
		
		local raffleData = ActivityCenterMO.getActivityContentById(activityId).data

		if type == 1 and raffleData.free > 0 then
			raffleData.free = raffleData.free - 1
		else
			if table.isexist(data, "gold") then 
				local res = {}
				--TK统计
				TKGameBO.onUseCoinTk(data.gold,TKText[61],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 

				UserMO.updateResources(res)
			end
		end

		ActivityCenterMO.newRaffleColors = data.color
		
		--奖励
		local awards = PbProtocol.decodeArray(data["award"])

		local statsAward = nil
		if awards then
			gdump(awards,"awards===")
			ActivityCenterMO.newRaffleResultTankId = awards[1].id

			local resultIdx
			for index=1,#raffleData.tankIds do
				local tankId = raffleData.tankIds[index]
				if ActivityCenterMO.newRaffleResultTankId == tankId then
					resultIdx = index
					break
				end
			end
			--插入坦克颜色
			table.insert(ActivityCenterMO.newRaffleColors,resultIdx)
			gprint(ActivityCenterMO.newRaffleResultTankId,"ActivityCenterMO.newRaffleResultTankId")
			gdump(ActivityCenterMO.newRaffleColors,"color===")
			statsAward = CombatBO.addAwards(awards)
		end

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActNewRaffle",{type = type}))
end



function ActivityCenterBO.asynLockNewRaffle(doneCallback,tankId)
	--测试数据
	-- if doneCallback then doneCallback(true) end
	-- do return end

	--测试数据

	local function parseAward(name, data)
		local raffData = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_TANKRAFFLE_NEW).data
		raffData.lockId = tankId
		if doneCallback then doneCallback(data.result) end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("LockNewRaffle",{tankId = tankId}))
end


function ActivityCenterBO.getNewRaffleTankLockIndex(raffleData)
	if raffleData.lockId > 0 then
		for index=1,#raffleData.tankIds do
			local tankId = raffleData.tankIds[index]
			if tankId == raffleData.lockId then
				return index - 2
			end
		end
	else
		local resultTankId = ActivityCenterBO.getNewRaffleTankResultId(raffleData)
		for index=1,#raffleData.tankIds do
			local tankId = raffleData.tankIds[index]
			if tankId == resultTankId then
				return index - 2
			end
		end
	end
	return -1
end

function ActivityCenterBO.getNewRaffleTankResultId(raffleData)
	local tankId
	if ActivityCenterMO.newRaffleResultTankId then
		tankId = ActivityCenterMO.newRaffleResultTankId
	else
		--默认第一次是第一个坦克
		tankId = raffleData.tankIds[1]
	end
	return tankId
end

--零点更新新坦克拉霸数据(免费次数+1，锁定清除)
function ActivityCenterBO.resetNewRaffle()
	if ActivityCenterBO.isValid(ACTIVITY_ID_TANKRAFFLE_NEW) then
		local content = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_TANKRAFFLE_NEW)
		if content then
			local raffleData = content.data
			raffleData.free = 1
			raffleData.lockId = 0
			ActivityCenterMO.newRaffleResultTankId = nil
			Notify.notify(LOCAL_ACTIVITY_NEWRAFFLE_UPDATE_EVENT)
		end
	end
end

function ActivityCenterBO.resetDailyTarget()
	-- body
	local InfoDialog = require("app.dialog.InfoDialog")
	InfoDialog.new("每日目标已刷新", function() 
			UiDirector.popMakeUiTop("ActivityCenterView")
		end):push()
end

-- --探索M1A2
-- function ActivityCenterBO.asynDoActTankExtract(doneCallback,price)
-- 	local function parseAward(name, data)
-- 		local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_TANK_CARNIVAL).data
-- 		--减少免费次数
-- 		if price == 1 and activityContent.free > 0 then
-- 			activityContent.free = activityContent.free - 1
-- 		else
-- 			if table.isexist(data, "gold") then 
-- 				local res = {}
-- 				--TK统计
-- 				TKGameBO.onUseCoinTk(data.gold,TKText[62],TKGAME_USERES_TYPE_UPDATE)
-- 				res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold} 

-- 				UserMO.updateResources(res)
-- 			end
-- 		end
		
-- 		--奖励
-- 		local awards = PbProtocol.decodeArray(data["award"])

-- 		local statsAward = nil
-- 		if awards then
-- 			gdump(awards,"awards===")
-- 			statsAward = CombatBO.addAwards(awards)
-- 			UiUtil.showAwards(statsAward)
-- 		end
		
-- 		if doneCallback then doneCallback() end
-- 	end
-- 	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoActTankExtract",{price = price}))
-- end

function ActivityCenterBO.getMaxRefitM1A1Num(tankFormula)

	local tank = TankMO.queryTankById(tankFormula.from)
	if not tank then return 0 end

	local refitTank = TankMO.queryTankById(tankFormula.to) -- 改装到的tank数据
	if not refitTank then return 0 end

	local count = UserMO.getResource(ITEM_KIND_TANK, tankFormula.from)  -- 可以改装的数量

	local ironNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_IRON) / (refitTank.iron - tank.iron))
	local oilNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_OIL) / (refitTank.iron - tank.iron))
	local copperNum = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_COPPER) / (refitTank.iron - tank.iron))
	local silicon = math.floor(UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_SILICON) / (refitTank.iron - tank.iron))

	local propNum = math.floor(UserMO.getResource(ITEM_KIND_PROP, PROP_ID_M1A2_CORE) / 1)

	return math.min(math.min(math.min(math.min(ironNum,  math.min(oilNum, math.min(copperNum, silicon))), propNum), count), TANK_PRODUCT_MAX_NUM)
end


function ActivityCenterBO.asynFormulaTankExtract(doneCallback,tankFormula,num)
	local function parseAward(name, data)
		local res = {}
		--更新资源
		if table.isexist(data, "grab") then
			local grab = PbProtocol.decodeRecord(data["grab"])
			if grab.oil then 
				TKGameBO.onUseResTk(RESOURCE_ID_OIL,grab.oil,TKText[63],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = grab.oil, id = RESOURCE_ID_OIL} 
			end
			if grab.iron then 
				TKGameBO.onUseResTk(RESOURCE_ID_IRON,grab.iron,TKText[63],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = grab.iron, id = RESOURCE_ID_IRON} 
			end
			if grab.copper then 
				TKGameBO.onUseResTk(RESOURCE_ID_COPPER,grab.copper,TKText[63],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = grab.copper, id = RESOURCE_ID_COPPER} 
			end
			if grab.silicon then 
				TKGameBO.onUseResTk(RESOURCE_ID_SILICON,grab.silicon,TKText[63],TKGAME_USERES_TYPE_UPDATE)
				res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = grab.silicon, id = RESOURCE_ID_SILICON} 
			end
		end
		
		-- --更新坦克数量
		-- local tankCount = UserMO.getResource(ITEM_KIND_TANK, tankFormula.tank.tankId)
		-- res[#res + 1] = {kind = ITEM_KIND_TANK, count = tankCount - num * tankFormula.tank.count, id = tankFormula.tank.tankId}
		
		UserMO.updateResources(res)

		--减少道具
		local res = {}
		if tankFormula.prop and #tankFormula.prop > 0 then
			for index=1, #tankFormula.prop do
				local prop = tankFormula.prop[index]
				res[#res + 1] = {kind = ITEM_KIND_PROP, id = prop.propId, count = prop.count}
			end
		end
		UserMO.reduceResources(res)

		--更新坦克数据
		local tanks = PbProtocol.decodeArray(data["tank"])
		for index = 1, #tanks do  -- 设置tank的数量
			local data = tanks[index]
			TankMO.tanks_[data.tankId] = data
		end
		
		UserBO.triggerFightCheck()

		--TK统计
		--消耗材料坦克
		TKGameBO.onEvnt(TKText.eventName[2], {tankId = tankFormula.tank.tankId, count = num * tankFormula.tank.count ,type = "del"})
		--获得改装后坦克
		TKGameBO.onEvnt(TKText.eventName[1], {tankId = tankFormula.tankId, count = num})

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("FormulaTankExtract",{tankFormulaId = tankFormula.tankFormulaId, count = num}))
end

function ActivityCenterBO.GetCollectInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.actProp)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		local left = PbProtocol.decodeArray(data.changeNum)
		ActivityCenterBO.propLeft_ = {}
		for k,v in ipairs(left) do
			ActivityCenterBO.propLeft_[v.v1] = v.v2
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCollectCharacter"))
end

--拉取淬炼大师活动信息
function ActivityCenterBO.GetRefineMasterInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.props)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		local prize = PbProtocol.decodeArray(data.broadcast)
		if prize then
			ActivityCenterMO.refineMasterChat_ = prize
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActSmeltPartMaster"))
end

--淬炼大师抽奖
function ActivityCenterBO.RefineMasterLottery(doneCallback,times)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.props)
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		local awards = PbProtocol.decodeArray(data["award"])
		local awars = clone(awards)
		local newData = {}
		newData.awards = awards
		local ret = CombatBO.addAwards(awars)
		newData.ret = ret

		Notify.notify("ACTIVITY_NOTIFY_ACTIVITY_REFINEMASTER")
		if doneCallback then doneCallback(newData) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("LotteryInSmeltPartMaster",{times=times}))
end

--淬炼大师活动排行
function ActivityCenterBO.GetActSmeltPartMasterRank(doneCallback)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local newData = {}
		newData.score = data.score
		newData.open = data.open
		newData.status = data.status
		newData.actPlayerRank = PbProtocol.decodeArray(data["actPlayerRank"])

		if doneCallback then doneCallback(newData) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActSmeltPartMasterRank",{times=times}))
end

--获取淬炼大师个人排名
function ActivityCenterBO.getMyRefineMasterRank(data)
	local myRank = CommonText[768]
	local rankList = data
	if rankList and #rankList > 0 then
		for index=1,#rankList do
			local player = rankList[index]
			if player.lordId == UserMO.lordId_ then
				return index
			end
		end
	end
	return myRank
end

function ActivityCenterBO.CollectCombine(id,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.actProp)
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CollectCharacterCombine",{id=id}))
end

function ActivityCenterBO.CollectExchange(id,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.actProp)
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		local left = PbProtocol.decodeArray(data.changeNum)
		for k,v in ipairs(left) do
			ActivityCenterBO.propLeft_[v.v1] = v.v2
		end
		local awards = PbProtocol.decodeArray(data["award"])
		--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CollectCharacterChange",{id=id}))
end

function ActivityCenterBO.doM1a2(id,single,rhand,needUpdate)
	local function parseResult(name,data)
		local function reback(redata)
			local old = UserMO.coin_
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
			--金币消耗
	  		TKGameBO.onUseCoinTk(old-UserMO.coin_,TKText[62],TKGAME_USERES_TYPE_CONSUME)
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
			rhand(redata)
		end

		local function recheck()
			local content = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_M1A2)
			if content and not needUpdate then
				content.data.hasFree = data.hasFree
				reback(content.data)
			else
				ActivityCenterBO.asynGetActivityContent(recheck, ACTIVITY_ID_M1A2,1)
				needUpdate = false
			end
		end
		
		recheck()
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoActM1a2",{id=id,single=single}))
end

function ActivityCenterBO.doM1a2Refit(id,count,rhand)
	local function parseResult(name,data)
		local temp = UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		for k,v in pairs(temp) do
			if v.count > 0 then
				UiUtil.showAwards({awards = {v}})
				break
			end
		end
		rhand()
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("M1a2RefitTank",{tankId=id,count=count}))
end

function ActivityCenterBO.GetFlower(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		if table.isexist(data,"actProp") then
			local item = PbProtocol.decodeRecord(data.actProp)
			if item then
				ActivityCenterBO.prop_[item.id] = item
			end
		end
		ActivityCenterBO.flowerLeft_ = {}
		if table.isexist(data,"changeNum") then
			local left = PbProtocol.decodeArray(data.changeNum)
			for k,v in ipairs(left) do
				ActivityCenterBO.flowerLeft_[v.v1] = v.v2
			end
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFlower"))
end

function ActivityCenterBO.WishFlower(id,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.actProp)
		ActivityCenterBO.prop_[item.id] = item
		local left = PbProtocol.decodeArray(data.changeNum)
		for k,v in ipairs(left) do
			ActivityCenterBO.flowerLeft_[v.v1] = v.v2
		end
		local awards = PbProtocol.decodeArray(data["award"])
		--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("WishFlower",{id=id}))
end

function ActivityCenterBO.getPayRebate(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.payRebate)
		rhand(item)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPayRebate"))
end

function ActivityCenterBO.doPayRebate(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.payRebate)
		rhand(item)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoPayRebate"))
end

function ActivityCenterBO.getPirateInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.data)
		rhand(item,data.awardId)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPirateLottery"))
end

function ActivityCenterBO.doPirate(kind,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.data)
		local awards = PbProtocol.decodeArray(data["awards"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		rhand(item)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoPirateLottery",{type = kind}))
end

function ActivityCenterBO.resetPirate(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.data)
		rhand(item)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ResetPirateLottery"))
end

function ActivityCenterBO.getPirateChange(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.actProp)

		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		if item then
			ActivityCenterBO.prop_[item.id] = item
		end

		local info = {}
		for k,v in ipairs(PbProtocol.decodeArray(data.changeNum)) do
			info[v.v1] = v.v2
		end
		rhand(item,info,data.awardId)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPirateChange"))
end

function ActivityCenterBO.doPirateChange(id,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.actProp)
		local info = {}
		for k,v in ipairs(PbProtocol.decodeArray(data.changeNum)) do
			info[v.v1] = v.v2
		end
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand(item,info)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoPirateChange",{id = id}))
end

function ActivityCenterBO.getActPirateRank(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data.actPlayerRank)
		local info = PbProtocol.decodeArray(data.rankAward)
		rhand(data.score,data.status,list,info,data.open)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActPirateRank"))
end

function ActivityCenterBO.getActBoss(kind,rhand)
	local function parseResult(name,data)
		if rhand then
			Loading.getInstance():unshow()
		end
		ActivityCenterBO.yearBoss_ = data
		ActivityCenterBO.yearBoss_.props = {}
		if table.isexist(data, "actProp") then
			for k,v in ipairs(PbProtocol.decodeArray(data["actProp"])) do
				ActivityCenterBO.yearBoss_.props[v.id] = v.count
			end
		end
		if rhand then
			rhand()
		end
	end
	if rhand then
		Loading.getInstance():show()
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActBoss",{type = kind}))
end

function ActivityCenterBO.callActBoss(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		UserMO.updateResources({PbProtocol.decodeRecord(data.atom)})
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CallActBoss"))
end

function ActivityCenterBO.attackActBoss(index,useGold,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		ActivityCenterBO.yearBoss_.attackCd = data.attackCd
		local atom = PbProtocol.decodeArray(data.atom)
		UserMO.updateResources(atom)
		for k,v in ipairs(atom) do
			if v.kind == ITEM_KIND_CHAR then
				if not ActivityCenterBO.yearBoss_.props then
					ActivityCenterBO.yearBoss_.props = {}
				end
				ActivityCenterBO.yearBoss_.props[v.id] = v.count
			end
		end
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		ActivityCenterBO.yearBoss_.bossState = data.bossState
		ActivityCenterBO.yearBoss_.bossBagNum = data.bossBagNum
		ActivityCenterBO.yearBoss_.bagNum = data.bagNum
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AttackActBoss",{useId = index,useGold = useGold}))
end

function ActivityCenterBO.buyActBossCd(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		ActivityCenterBO.yearBoss_.callTimes = data.cdTime
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyActBossCd"))
end

function ActivityCenterBO.getActBossRank(kind,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		data.actPlayerRank = PbProtocol.decodeArray(data.actPlayerRank)
		data.rankAward = PbProtocol.decodeArray(data.rankAward)
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActBossRank",{rankType = kind}))
end

-- 请求狂欢祈福充值领奖界面信息
function ActivityCenterBO.getActHilarityPray(rhand)
	if ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] and ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].payData then
		rhand()
		return
	end
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] = {}
		ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].payData = data
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActHilarityPray"))
end

-- 领取狂欢祈福充值奖励
function ActivityCenterBO.receiveActHilarityPray(id, rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["awards"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ReceiveActHilarityPray",{keyId = id}))
end

-- 请求狂欢祈福祈福界面信息
function ActivityCenterBO.getActHilarityPrayAction(rhand)
	-- if ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] and table.isexist(ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL],"info") then
	-- 	rhand()
	-- 	return
	-- end
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.actProp)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		if not ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] then
			ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] = {}
		end
		ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].info = data
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActHilarityPrayAction"))
end

-- 使用卡片道具祈福
function ActivityCenterBO.doActHilarityPrayAction(index,propId,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeArray(data.actProp)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end
		local temp = ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].info
		if not table.isexist(temp,"index") then 
			temp.index = {}
		end
		table.insert(temp.index,data.index)
		if not table.isexist(temp,"time") then
			temp.time = {}
		end
		table.insert(temp.time,data.time)
		if not table.isexist(temp,"propId") then
			temp.propId = {}
		end
		table.insert(temp.propId,data.propId)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoActHilarityPrayAction",{index = index,prop = propId}))
end

-- 领取狂欢祈福充值奖励
function ActivityCenterBO.receiveActHilarityPrayAction(index,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["awards"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ReceiveActHilarityPrayAction",{index = index}))
end

-- 祈福加速
function ActivityCenterBO.speedActHilarityPrayAction(index,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		TKGameBO.onUseCoinTk(data.gold,TKText[60],TKGAME_USERES_TYPE_UPDATE)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SpeedActHilarityPrayAction",{index = index}))
end

-- 清盘计划信息
function ActivityCenterBO.getOverRebateAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetOverRebateAct"))
end

-- 转动清盘计划
function ActivityCenterBO.doOverRebateAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["awards"])
		rhand(data.Index,awards)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoOverRebateAct"))
end

-- 请求拜女神
function ActivityCenterBO.getWorshipGodAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetWorshipGodAct"))
end

-- 拜神反金币
function ActivityCenterBO.doWorshipGodAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoWorshipGodAct"))
end

-- 请求许愿界面
function ActivityCenterBO.getWorshipTaskAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetWorshipTaskAct"),1)
end

-- 许愿
function ActivityCenterBO.doWorshipTaskAct(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoWorshipTaskAct"),1)
end

function ActivityCenterBO.getActCollege(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.actProp)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		ActivityCenterBO.prop_[item.id] = item
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActCollege"),1)
end

function ActivityCenterBO.buyActProp(id,count,rhand,noshow)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local temp = UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		if not noshow then
			for k,v in pairs(temp) do
				if v.count > 0 then
					UiUtil.showAwards({awards = {v}})
					break
				end
			end
		end
		local time = nil
		if table.isexist(data, "freeTime") then
			time = data.freeTime
		end
		rhand(data.buyPropNum,time)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyActProp",{id = id, count = count}),1)
end

function ActivityCenterBO.doActCollege(time,useGold,rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local item = PbProtocol.decodeRecord(data.actProp)
		if not ActivityCenterBO.prop_ then
			ActivityCenterBO.prop_ = {}
		end
		ActivityCenterBO.prop_[item.id] = item
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoActCollege",{times = time, useGold = useGold}),1)
end

-- 拉去 能量灌注活动 信息
function ActivityCenterBO.GetActCumulativePayInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActCumulativePayInfo"),1)
end

--领取第几天奖励 1,2,3第几天奖励 0 大奖
function ActivityCenterBO.GetActCumulativePayAward(rhand,dayid)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		if dayid > 0 then
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActCumulativePayAward",{day = dayid}),1)
end

-- 补充第几天 1,2
function ActivityCenterBO.ActCumulativeRePay(rhand,dayid)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ActCumulativeRePay",{day = dayid}),1)
end

-- 自选豪礼
function ActivityCenterBO.GetActChooseGift(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	-- 	required int32 limit = 1;                    //领取最大次数
	-- required int32 left = 2;                     //剩余次数
	-- required int32 states = 3;                   //1 可领取  0 不可领取
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActChooseGift"),1)
end

-- 自选豪礼 领取奖励
function ActivityCenterBO.DoActChooseGift(rhand, giftIndex)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoActChooseGift",{id = giftIndex}),1)
end

-- 兄弟同心 拉取数据
function ActivityCenterBO.GetActBrotherTask(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActBrotherTask"),1)
end

-- 兄弟同心 升级BUFF
function ActivityCenterBO.UpBrotherBuff(rhand, buffType)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpBrotherBuff",{buffType = buffType}),1)
end

-- 兄弟同心 领取奖励
function ActivityCenterBO.GetBrotherAward(rhand, id)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetBrotherAward",{id = id}),1)
end

-- 兄弟同心 消息推送
function ActivityCenterBO.AcceptBrotherList(name,data)
	local idbuff = data.id
	local nickbuff = data.nick
	if #ActivityCenterMO.ActivityBrotherList > 20 then
		table.remove(ActivityCenterMO.ActivityBrotherList,1)
	end
	local out = {id = idbuff, nick = nickbuff}
	ActivityCenterMO.ActivityBrotherList[#ActivityCenterMO.ActivityBrotherList + 1] = out
	Notify.notify("ACTIVITY_NOTIFY_BROTHER_NOTES")
end

-- 打完飞艇或占领飞艇时广播消息
function ActivityCenterBO.AcceptBrotherFight()
	Notify.notify("ACTIVITY_NOTIFY_BROTHER_FIGHT_NOTES")
end

--超时空财团刷新
function ActivityCenterBO.FreshHyperSpace(rhand,type,isRefresh)
	local showType = type
	local isRefresh = isRefresh
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		UserMO.updateResource(ITEM_KIND_COIN, data.hasMoney)
		UserMO.updateResource(ITEM_KIND_PROP, data.hasRefreshes,493)
		if rhand then rhand(data) end
		
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ShowQuinn",{showType = showType,isRefresh = isRefresh}))
end

--超时空财团购买
function ActivityCenterBO.HyperSpaceBuy(rhand,type)
	local buyType = type
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end
		if buyType ~= 100 then
			UserMO.updateResource(ITEM_KIND_COIN, data.hasMoney)
		elseif buyType == 100 then
			UserMO.updateResource(ITEM_KIND_PROP, data.hasMoney, 492) -- 刷新道具 原力
		end
		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyQuinn",{type = buyType}))
end

--超时空财团领奖
function ActivityCenterBO.HyperSpaceGetAward(rhand)
	local buyType = type
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret, true)
		end
		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetQuinnAward"))
end

--获取荣誉勋章活动信息
function ActivityCenterBO.GetActMedalofhonorInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActMedalofhonorInfo"))
end

-- 打开活动宝箱(大吉大利,晚上吃鸡)
function ActivityCenterBO.OpenActMedalofhonor(rhand,index)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
        rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("OpenActMedalofhonor",{pos = index}))
end

-- force 1: 不指定搜索结果, 2: 指定搜索结果(必定3橙)
-- search 1: 单次搜索, 2: 使用一键十倍
function ActivityCenterBO.SearchActMedalofhonorTargets(rhand, force, search)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- dump(data,"SearchActMedalofhonorTargets")
		if table.isexist(data,"gold") then
			-- 刷新金币
	    	local res = {}
	    	res[#res + 1] = {kind = ITEM_KIND_COIN, count = data.gold}
	    	UserMO.updateResources(res)
		end	
    	rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SearchActMedalofhonorTargets",{forceResult = force, searchType = search}))
end

-- 购买荣誉勋章活动道
function ActivityCenterBO.BuyActMedalofhonorItem(rhand, id, buyCount)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		ActivityCenterMO.ActivityMedalInfo.price = data.medalHonor
		local awards = PbProtocol.decodeRecord(data["award"])
		if awards then
			local allAwards = {}
			allAwards[#allAwards + 1] = awards
			local statsAward = CombatBO.addAwards(allAwards)
			UiUtil.showAwards(statsAward)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyActMedalofhonorItem",{id = id, buyCount = buyCount}))
end

-- 领取荣誉勋章活动排名奖励
function ActivityCenterBO.GetActMedalofhonorRankAward(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
    	-- get 
    	-- repeated Award award = 1;			//排名奖励
    	local awards = PbProtocol.decodeArray(data["award"])
    	-- dump(awards,"GetActMedalofhonorRankAward")
    	if awards then
    		local statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
    	end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActMedalofhonorRankAward"))
end

-- 查看排行榜
function ActivityCenterBO.GetActMedalofhonorRankInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
    	-- get 
    	-- optional int32 score = 1;                   //我的积分
	 --    repeated ActPlayerRank actPlayerRank = 2;   //排行榜
		-- optional bool open = 3;                     //true可领奖励 1 不可领奖
	 --    repeated RankAward rankAward = 4;           //排名奖励信息
	 --    optional int32 status = 5;                  //0未领 1已领
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActMedalofhonorRankInfo"))
end


-- 获取大富翁活动信息
function ActivityCenterBO.GetMonopolyInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
 --    	repeated int32 event = 1;					//格子里面事件列表,下标为格子ID[0,22)
	-- optional int32 pos = 2;						//当前所在格子位置
	-- optional int32 energy = 3;					//剩余精力
	-- optional int32 finishRound = 4;				//已经完成的轮数
	-- repeated int32 drawRound = 5;				//已经领取的宝箱列表
	-- optional int32 drawFreeEnergySec = 6;       //最后领取免费精力事件:单位：秒
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetMonopolyInfo"))
end

-- 投骰子
function ActivityCenterBO.ThrowDice(rhand,point)
	-- required int32 point = 1;					//0-普通骰子, 1-6 使用意念骰子
	local function parseResult(name,data)
		Loading.getInstance():unshow()
 --    	optional int32 pos	= 1;					//骰子新位置>=22表示已经完成本轮游戏
	-- optional int32 energy = 2;					//剩余精力
	-- optional int32 finishRound = 3;				//已完成次数
	-- repeated Award award = 4;					//获得奖励
	-- optional int32 buyId = 5;					//如果新位置是购买商品的事件，则buyId 表示可购买商
	-- optional Atom2 atom2 = 6;					//剩余意念骰子信息
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ThrowDice",{point = point}))
end

-- 购买精力
function ActivityCenterBO.BuyEnergy(rhand,isBuy)
	-- required bool isBuy	= 1;					//true-购买精力, false 使用精力道具
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		print("ActivityCenterBO.BuyEnergy ========= 购买精力 " .. tostring(isBuy) .. "    true-购买精力 false 使用精力道具")
 -- optional int32 energy = 1;					//剩余精力
	-- optional int32 gold = 2;					//剩余金币
	-- optional Atom2 atom2 = 3;					//剩余精力信息
		if table.isexist(data,"atom2") then
			local propData = PbProtocol.decodeRecord(data["atom2"])
			UserMO.updateResource(propData.kind,propData.count,propData.id)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyOrUseEnergy",{isBuy = isBuy}))
end

-- 购买打折商品
function ActivityCenterBO.BuyDiscountGoods(rhand,buyId)
	-- required int32 buyId = 1;					//购买ID
	local function parseResult(name,data)
		Loading.getInstance():unshow()
 -- optional int32 gold = 1;					//剩余金币
	-- repeated Award award = 2;					//获得奖励
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyDiscountGoods",{buyId = buyId}))
end

-- 选择对话事件，对话选项
function ActivityCenterBO.SelectDialog(rhand,dlgId)
	-- required int32 dlgId = 1;					//对话ID
	local function parseResult(name,data)
		Loading.getInstance():unshow()
 -- optional int32 energy = 1;					//剩余精力
	-- repeated Award award = 2;					//获得奖励
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SelectDialog",{dlgId = dlgId}))
end

-- 领取已完成的游戏次数奖励
function ActivityCenterBO.DrawFinishCountAward(rhand,cnt)
	-- optional int32 cnt  = 1;                    //完成的次数
	local function parseResult(name,data)
		Loading.getInstance():unshow()
 -- repeated Award award = 1;                   //奖励内容
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrawFinishCountAward",{cnt = cnt}))
end

-- 领取免费精力
function ActivityCenterBO.DrawFreeEnergy(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
-- optional int32 drawFreeEnergySec = 1;       //最后领取免费精力事件:单位：秒
    -- optional int32 energy = 2;                  //当前剩余精力
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrawFreeEnergy"))
end

------------------------------红包--------------------------------- start
-- 红包活动信息
function ActivityCenterBO.GetActRedBagInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		ActivityCenterBO.GetRedPacketAct(name, data)
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActRedBagInfo"))
end

-- 登录时 拉去一次
function ActivityCenterBO.SelectActRedBagInfo()
	RedPacketView = require("app.view.RedPacketView")
	local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_REDPACKET)
	if activity and UserMO.level_ >= activity.minLv then
		SocketWrapper.wrapSend(ActivityCenterBO.GetRedPacketAct, NetRequest.new("GetActRedBagInfo"))
	end
end

function ActivityCenterBO.GetRedPacketAct(name,data)
	-- optional int32 activityId = 1;						//活动ID
	-- optional int32 actStage = 2;						//当前全服充值达到的阶段
	-- repeated int32 stage = 3;							//已经领取过的奖励
	-- repeated Atom2 prop = 4;                            //玩家身上红包道具信息
	-- repeated RedBagChat chat = 5;						//聊天频道中的红包信息

	-- 玩家身上红包道具信息
	ActivityCenterMO.ActivityRedPacketList = {}
	local props = PbProtocol.decodeArray(data["prop"]) 
	for index = 1 , #props do
		local prop = props[index]
		ActivityCenterMO.ActivityRedPacketList[prop.id] = {id = prop.id, count = prop.count}
	end

	-- 聊天频道中的红包信息 按时间排序
	ActivityCenterMO.ActivityRedPacketWorldChat = {}	-- 
	ActivityCenterMO.ActivityRedPacketPartyChat = {}	--
	ActivityCenterMO.ActivityRedPacketWorldChat = PbProtocol.decodeArray(data["worldChat"]) 
	ActivityCenterMO.ActivityRedPacketPartyChat = PbProtocol.decodeArray(data["partyChat"]) 
	local function timeSort(a, b)
		return a.time < b.time
	end
	table.sort(ActivityCenterMO.ActivityRedPacketWorldChat, timeSort)
	table.sort(ActivityCenterMO.ActivityRedPacketPartyChat, timeSort)
end

-- 领取红包活动阶段奖励
function ActivityCenterBO.DrawActRedBagStageAward(rhand, stage)
	-- required int32 stage = 1;							//领取的红包充值阶段
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated Award award = 1;							//领取到的阶段奖励
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrawActRedBagStageAward",{stage = stage}))
end

-- 获取红包列表
function ActivityCenterBO.GetActRedBagList(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated RedBagSummary redBag = 1;                  //红包列表
		local list = PbProtocol.decodeArray(data["redBag"])
		ActivityCenterMO.ActivityRedPacketInfo = {}
		for index = 1 , #list do
			local info = list[index]
			ActivityCenterMO.ActivityRedPacketInfo[info.uid] = info
		end
		
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActRedBagList"))
end

-- 抢红包
function ActivityCenterBO.GrabRedBag(rhand, uid)
	-- required int32 uid = 1;                              //红包唯一ID

	-- 等级限制
	local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_REDPACKET)
	if UserMO.level_ < activity.minLv then
		Toast.show(string.format(CommonText[1125],activity.minLv))
		rhand(nil, false)
		return
	end

	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional int32 grabMoney = 1;						// >0抢红包金额, 小于等于零: 抢红包失败
		-- optional ActRedBag redBag = 2;						//如果未抢到红包则显示红包详细信息
		local out = {}
		if table.isexist(data, "grabMoney") then
			out.grabMoney = data.grabMoney
			local awards = {{type = ITEM_KIND_COIN, id = 0, count = out.grabMoney}}
			local statsAward = nil
			if awards then
				statsAward = CombatBO.addAwards(awards)
			end
			out.statsAward = statsAward
		else
			out.grabMoney = 0
		end

		if table.isexist(data, "redBag") then
			out.redBag = PbProtocol.decodeRecord(data["redBag"])
		end

		rhand(out, true)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GrabRedBag",{uid = uid}))
end


-- 发红包
function ActivityCenterBO.SendActRedBag(rhand, propId, grabCnt, isPartyRedBag)
	-- required int32 propId = 1;							//红包道具ID
	-- required int32 grabCnt = 2;							//最多允许抢多少次
	-- required bool isPartyRedBag = 3;					//true-发放的红包只有本军团才能抢
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional Atom2 atom2 = 1;							//剩余红包道具信息
		-- optional RedBagSummary summary = 2;                 //红包摘要信息
		local prop = PbProtocol.decodeRecord(data["atom2"])
		ActivityCenterMO.ActivityRedPacketList[prop.id] = {id = prop.id, count = prop.count}

		local info = PbProtocol.decodeRecord(data["summary"])
		ActivityCenterMO.ActivityRedPacketInfo[info.uid] = info
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SendActRedBag",{propId = propId, grabCnt = grabCnt, isPartyRedBag = isPartyRedBag}))
end

-- 聊天主推
function ActivityCenterBO.SynSendActRedBag( name, data )
	local chat = PbProtocol.decodeRecord(data["chat"])
	if chat.type == 1 then
		ActivityCenterMO.ActivityRedPacketWorldChat[#ActivityCenterMO.ActivityRedPacketWorldChat + 1] = chat
	else
		ActivityCenterMO.ActivityRedPacketPartyChat[#ActivityCenterMO.ActivityRedPacketPartyChat + 1] = chat
	end

	local msg = chat.name .. CommonText[1795]
	local pushOut = {}
	pushOut.uid = chat.uid
	pushOut.style = 1
	pushOut.sysId = 1001
	pushOut.name = chat.name
	pushOut.msg = msg
	pushOut.param = {chat.name,chat.type}

	-- 发送公告
	UiUtil.showHorn(pushOut)

	-- 发送 抢
	-- local RedPacketView = require("app.view.RedPacketView")
	RedPacketView.show(pushOut)	
end

------------------------------红包--------------------------------- end

--红色方案获取信息
function ActivityCenterBO.getRedPlanInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 fuel = 1;//燃料数量
		-- required int32 itemCount =2;//代币数
		-- repeated int32 areaInfo =3;//地图地图id 对应地图状态 1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
		-- repeated int32 shopInfo =4;//兑换物品信息 goodsid- count已经对接次数
		-- required int32 fuelBuyCount =5;//购买燃料次数
		-- required int32 isfirst = 6;//是否第一次打开这个活动 1是 0否
		-- required int32 nowAreaId =7;//当前打的那一块地图
		-- required int32 fuelTime = 8;//下次回复燃料剩余时间

		ActivityCenterMO.redPlanFuelInfo.fuel = data.fuel
		ActivityCenterMO.redPlanFuelInfo.fuelTime = data.fuelTime
		ActivityCenterMO.redPlanFuelInfo.fuelBuyCount = data.fuelBuyCount
		-- ActivityCenterMO.redPlanFuelInfo.Max = ActivityCenterMO.getRedPlanFuelLimit().recoverLimit
		if ActivityCenterMO.redPlanFuelInfo.fuelTime <= 0 then
			ActivityCenterMO.redPlanFuelInfo.fuelTime = ActivityCenterMO.getRedPlanFuelLimit().recoverSpan
		end

		-- 代币数 道具[5,629,X]
		UserMO.updateResource(ITEM_KIND_PROP, data.itemCount, 640)

		ActivityCenterMO.redPlanMapInfo_ = data
		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetRedPlanInfo"))
end

--红色方案，商店界面兑换物品
function ActivityCenterBO.exchangeRedPlan(rhand, goodsId,num)
	local count = num
	local id = goodsId
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 itemCount =1;//代币数
		-- repeated Award award = 2;//获得的奖励
		-- repeated int32 shopInfo =3;//兑换物品信息 goodsid- count已经对接次数

		local awards = PbProtocol.decodeArray(data["award"])
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end
		UserMO.updateResource(ITEM_KIND_PROP, data.itemCount, 640) --刷新代币数
		ActivityCenterMO.redPlanMapInfo_.itemCount = data.itemCount
		ActivityCenterMO.redPlanMapInfo_.shopInfo = data.shopInfo
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("RedPlanReward",{goodsid = id, count = count}))
end

-- 红色方案获取某个区域块内信息
function ActivityCenterBO.GetRedPlanAreaInfo(rhand, areaId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated int32 pointIds =1;//通过线路
		-- repeated int32 areaInfo =2;//地图地图id 对应地图状态 1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
		-- required int32 rewardInfo =3;//对应奖励的状态 0不可以 1可以领取  2已经领取
		-- required int32 nowAreaId =4;//当前打的那一块地图
		-- required int32 isfirst = 5;//是否第一次打开这个区域 1是 0否

		-- dump(data,"GetRedPlanAreaInfo")
		ActivityCenterMO.redPlanMapInfo_.nowAreaId = data.nowAreaId
		ActivityCenterMO.redPlanMapInfo_.areaInfo = data.areaInfo
		ActivityCenterMO.redPlanMapInfo_.isfirst = data.isfirst
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetRedPlanAreaInfo",{areaId = areaId}))
end

-- 红色方案移动格子
function ActivityCenterBO.MoveRedPlan(rhand, areaId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 nextPointId = 1;//下一个格子id
		-- repeated Award award = 2;//获得的奖励
		-- required int32 awardType = 3;//奖励类型
		-- required int32 itemCount =4;//代币数
		-- required int32 fuel = 5;//燃料数量
		-- required int32 rewardInfo =6;//对应奖励的状态 0不可以 1可以领取  2已经领取
		-- repeated int32 historyPoint =8;//已经走过的点
		-- required int32 perfect = 9;//是否完美通关 1是 0否

		local out = {}
		out.nextPointId = data.nextPointId
		out.awardType = data.awardType
		out.rewardInfo = data.rewardInfo
		out.isfirst = data.isfirst
		out.perfect = data.perfect
		out.historyPoint = data.historyPoint

		-- 获得的奖励
		local awards = PbProtocol.decodeArray(data["award"])
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			-- UiUtil.showAwards(statsAward)
			out.awards = awards
			out.statsAward = statsAward
		end

		-- 代币数 道具[5,629,X]
		UserMO.updateResource(ITEM_KIND_PROP, data.itemCount, 640)

		-- 燃料数量
		ActivityCenterMO.redPlanFuelInfo.fuel = data.fuel
		-- ActivityCenterMO.redPlanMapInfo_.fuel = data.fuel

		rhand(out)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("MoveRedPlan",{areaId = areaId}))
end

-- 红色方案购买燃料
function ActivityCenterBO.RedPlanBuyFuel(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 fuelBuyCount = 1;//购买燃料次数
		-- required int32 gold = 2;//金币数
		-- required int32 fuel = 3;//燃料数量

		-- 购买燃料次数
		ActivityCenterMO.redPlanFuelInfo.fuelBuyCount = data.fuelBuyCount
		ActivityCenterMO.redPlanFuelInfo.fuel = data.fuel

		-- 刷新金币
		UserMO.updateResource(ITEM_KIND_COIN, data.gold, 0)

		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("RedPlanBuyFuel"))
end

-- 红色方案领取通关宝箱
function ActivityCenterBO.GetRedPlanBox(rhand, areaId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated Award award = 1;//获得的奖励
		-- required int32 rewardInfo =2;//对应奖励的状态 0不可以 1可以领取  2已经领取

		-- 获得的奖励
		local awards = PbProtocol.decodeArray(data["award"])
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetRedPlanBox",{areaId = areaId}))
end

-- 红色方案扫荡
function ActivityCenterBO.RefRedPlanArea(rhand, areaId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated Award award = 1;//获得的奖励
		-- required int32 awardType = 2;//奖励类型
		-- required int32 itemCount =3;//代币数
		-- required int32 fuel = 4;//燃料数量

		local out = {}
		out.awardType = data.awardType

		-- 获得的奖励
		local awards = PbProtocol.decodeArray(data["award"])
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			-- UiUtil.showAwards(statsAward)
			out.awards = awards
			out.statsAward = statsAward
		end

		ActivityCenterMO.redPlanFuelInfo.fuel = data.fuel

		-- 代币数 道具[5,629,X]
		UserMO.updateResource(ITEM_KIND_PROP, data.itemCount, 640)

		rhand(out)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("RefRedPlanArea",{areaId = areaId}))
end

------------------------------节日碎片活动---------------------------------------------
--获取活动信息
function ActivityCenterBO.GetFragExcInfo(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()

		local item = PbProtocol.decodeArray(data.actProp)
		if not ActivityCenterBO.prop_ then  --道具碎片信息
			ActivityCenterBO.prop_ = {}
		end
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end

		ActivityCenterMO.festivelInfo_ = data
		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFestivalInfo"))
end

--兑换物品
function ActivityCenterBO.DoFragExchange(rhand,id,count)
	local function parseResult(name,data)
		Loading.getInstance():unshow()

    	--更新金币
    	UserMO.updateResource(ITEM_KIND_COIN, data.gold)

    	local awards = PbProtocol.decodeArray(data["award"])
    	local statsAward = CombatBO.addAwards(awards)
    	UiUtil.showAwards(statsAward)

		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFestivalReward",{id = id, count = count}))
end

--领取登录奖励
function ActivityCenterBO.GetLoginRewards(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()

    	local awards = PbProtocol.decodeArray(data["award"])
    	local statsAward = CombatBO.addAwards(awards)
    	UiUtil.showAwards(statsAward)

		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFestivalLoginReward"))
end

------------------------------幸运奖池---------------------------------------------
-- 幸运奖池获取信息
function ActivityCenterBO.GetActLuckyInfo( rhand )
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 luckyCount = 1;//可以抽取的次数
		-- required int32 poolgold = 2;//奖池金额
		-- required int32 rechargegold = 3;//活动期间充值金额
		-- dump(data,"GetActLuckyInfo")
		
		ActivityCenterMO.luckyroundInfo.luckyCount = data.luckyCount
		ActivityCenterMO.luckyroundInfo.poolgold = data.poolgold

		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActLuckyInfo"))
end

function ActivityCenterBO.GetActLuckyReward(rhand, tocount)
	-- required int32 count = 1;//抽取次数
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 luckyCount = 1;//可以抽取的次数
		-- repeated Award award = 2;//获得的奖励
		-- repeated int32 luckyId = 3;//中奖的配置id
		-- required int32 poolgold = 4;//奖池金额

		ActivityCenterMO.luckyroundInfo.luckyCount = data.luckyCount
		ActivityCenterMO.luckyroundInfo.poolgold = data.poolgold


    	local out = {}
    	-- 获得的奖励
		local awards = PbProtocol.decodeArray(data["award"])
		out.awards = clone(awards)
		if awards then
			local statsAward = CombatBO.addAwards(awards)
			-- UiUtil.showAwards(statsAward)
			out.statsAward = statsAward
		end

		out.luckyId = data.luckyId

		if rhand then rhand(out) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActLuckyReward",{count = tocount}))
end

function ActivityCenterBO.AysActLuckyPoolGoldChange(name , data)
	-- required int32 poolgold = 1;//奖池金额
	ActivityCenterMO.luckyroundInfo.poolgold = data.poolgold
	Notify.notify("ACTIVITY_LUCKY_ROUND_ALL_GOLD")
end

--幸运奖池 获取中奖纪录
function ActivityCenterBO.GetActLuckyPoolLog(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		-- repeated ActLuckyPoolLog luckLog = 1; 
		
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActLuckyPoolLog"))
end

--获取坦克转换
function ActivityCenterBO.getTankExc(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetTankConvertInfo"))
end

--坦克转换
function ActivityCenterBO.goTankExc(rhand, count, srcTankId, dstTankId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		
		UserMO.reduceResource(ITEM_KIND_TANK,count,srcTankId)
		-- UserMO.addResource(ITEM_KIND_TANK,count,dstTankId)

		local awards = {}
		local data = {}
		data.count = count
		data.id = dstTankId
		data.type = ITEM_KIND_TANK
		awards[#awards + 1] = data

		local statsAward = CombatBO.addAwards(awards)

		UiUtil.showAwards(statsAward)

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("TankConvert",{count = count, srcTankId = srcTankId, dstTankId = dstTankId}))
end

--军备兑换刷新
function ActivityCenterBO.asynRefshPaperCash(doneCallback,oldCash)
	local function parseAward(name, data)
		--是否免费
		if oldCash.free == 0 then
			--扣除金币
			UserMO.reduceResource(ITEM_KIND_COIN, oldCash.price)
			--TK统计 
			--金币消耗
			TKGameBO.onUseCoinTk(oldCash.price,TKText[58],TKGAME_USERES_TYPE_CONSUME)
		end
		gdump(oldCash,"oldCash")
		local newCash = PbProtocol.decodeRecord(data["cash"])
		newCash.atom = PbProtocol.decodeArray(newCash["atom"])
		newCash.award = PbProtocol.decodeRecord(newCash["award"])
		gdump(newCash,"newCash")

		oldCash.cashId = newCash.cashId
		oldCash.formulaId = newCash.formulaId
		oldCash.state = newCash.state
		oldCash.free = newCash.free
		oldCash.price = newCash.price
		oldCash.atom = newCash.atom
		oldCash.award = newCash.award
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("RefshDrawingCash",{cashId = oldCash.cashId}))
end

--军备图纸兑换
function ActivityCenterBO.asynDoPaperCash(doneCallback,cash)
	local function parseAward(name, data)
		--获得合成道具
		local award = PbProtocol.decodeRecord(data["award"])
		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[30], {name = UserMO.getResourceData(award.type,award.id).name})
		
		--减少次数
		cash.state = cash.state - 1
		local costList = PbProtocol.decodeArray(data["costList"])
		--减少材料
		for index=1,#costList do
			local prop = costList[index]
			-- if prop.type == ITEM_KIND_EQUIP then
			-- 	EquipMO.removeEquipByKeyId(prop.keyId)
			-- elseif prop.type == ITEM_KIND_PART then
			-- 	PartMO.part_[prop.keyId] = nil
			-- else
				UserMO.reduceResource(prop.type,prop.count,prop.id)
			-- end
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseAward, NetRequest.new("DoDrawingCash",{cashId = cash.cashId}))
end

--活动道具批量购买/兑换
function ActivityCenterBO.doActPropExc(doneCallback,activityId, goodId, count, price)
	price = price or 0
	local function parseAward(name, data)
		Loading.getInstance():unshow()

		local activityContent = ActivityCenterMO.getActivityContentById(activityId)
		if activityContent and activityContent.state then
			activityContent.state = activityContent.state - price
		end

		--获得合成道具
		local award = PbProtocol.decodeArray(data.award)
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)

		--刷新消耗
		if table.isexist(data,"actProp") then
			local propData = PbProtocol.decodeRecord(data["actProp"])
			UserMO.updateResource(propData.kind,propData.count,propData.id)
		end

		--TK统计
		TKGameBO.onEvnt(TKText.eventName[30], {name = UserMO.getResourceData(award.type,award.id).name})
		
		if doneCallback then doneCallback(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("BuyInBuck",{activityId = activityId, goodId = goodId, count = count}))
end

function ActivityCenterBO.upLoadAnswer(doneCallback, answerList)
	local function parseAward(name, data)
		Loading.getInstance():unshow()
		local award = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)
		ActivityCenterMO.activityContents_[ACTIVITY_ID_QUESTION_ANSWER].queStatus = data.queStatus
		if doneCallback then doneCallback(true) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("QueSendAnswer",{answer = answerList}))
end

--最强王者获取信息
function ActivityCenterBO.getActivityInfoByKind(doneCallback,kind)
	local function parseAward(name, data)
		Loading.getInstance():unshow()

		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetPsnKillRank",{type = kind}))
end

--获取排行总榜信息
function ActivityCenterBO.GetAactivityAllRanks(doneCallback)
	local function parseAward(name, data)
		Loading.getInstance():unshow()

		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetAllRanks"))
end

--获取分榜信息
function ActivityCenterBO.getIndexRankinfo(doneCallback,kind)
	local function parseAward(name, data)
		Loading.getInstance():unshow()

		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetRanksInfo",{type = kind}))
end

--领奖
function ActivityCenterBO.getActivityKingRankAwards(doneCallback,kind)
	local function parseAward(name, data)
		Loading.getInstance():unshow()
		local award = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)
		if doneCallback then doneCallback(true) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetKingRankAward",{type = kind}))
end

--领奖个人
function ActivityCenterBO.getActivityKingAwards(doneCallback,id)
	local function parseAward(name, data)
		Loading.getInstance():unshow()
		local award = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(award)
		UiUtil.showAwards(ret)
		if doneCallback then doneCallback(data.status) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseAward, NetRequest.new("GetKingAward",{id = id}))
end