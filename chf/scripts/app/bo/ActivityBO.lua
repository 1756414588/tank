
-- 活动

ActivityBO = {}

function ActivityBO.update(data)
	ActivityMO.activityList_ = {}
	ActivityMO.activityContents_ = {}

	if not data then return end

	local activities = PbProtocol.decodeArray(data["activity"])
	-- gdump(activities, "ActivityBO.update")
	for index = 1, #activities do
		local activity = activities[index]
		gdump(activity, "ActivityBO.update " .. index)

		local displayTime = activity.endTime
		if table.isexist(activity, "displayTime") then displayTime = activity.displayTime end

		local tips = 0
		if table.isexist(activity, "tips") then tips = activity.tips end
		ActivityMO.activityList_[index] = {activityId = activity.activityId, name = activity.name, beginTime = activity.beginTime, endTime = activity.endTime, displayTime = displayTime, open = activity.open, tips=tips,awardId = activity.awardId}
		ActivityMO.checkEffectActivity(activity)
	end

	Notify.notify(LOCLA_ACTIVITY_EVENT)

	scheduler.performWithDelayGlobal(function()
			local list = ActivityBO.getShowList()
			for index = 1, #list do
				local activity = list[index]
				if activity.activityId == ACTIVITY_ID_RESOURCE
					or activity.activityId == ACTIVITY_ID_PARTY_LEVEL or activity.activityId == ACTIVITY_ID_PARTY_FIGHT
					or activity.activityId == ACTIVITY_ID_GIFT_ONLINE then
					if ActivityBO.isValid(activity.activityId) and LoginMO.isInLogin_ then
						ActivityBO.asynGetActivityContent(nil, activity.activityId)
					end
				end
			end
		end, 1)

	local function refresh(dt)
		if UiDirector.hasUiByName("ActivityView") then return end
		
		ActivityMO.activityList_ = {}
		ActivityMO.activityContents_ = {}

		local function parseGetActivity(name, data)
			ActivityBO.update(data)
		end

		SocketWrapper.wrapSend(parseGetActivity, NetRequest.new("GetActivityList"))
	end

	if not ActivityMO.refreshHandler_ then
		ActivityMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 180)
	end

	if not ActivityMO.tickHandler_ then
		ActivityMO.tickHandler_ = ManagerTimer.addTickListener(ActivityBO.onTick)
	end
end

function ActivityBO.onTick(dt)
	if ActivityBO.isValid(ACTIVITY_ID_GIFT_ONLINE) then
		local activityContent = ActivityMO.getActivityContentById(ACTIVITY_ID_GIFT_ONLINE)
		if not activityContent or not activityContent.conditions then return end
		activityContent.state = activityContent.state + dt
	end
end

function ActivityBO.readConfig()
	local name = "activity" .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
	local data = readfile(name)
	if not data then return end

	ActivityMO.localConfig_ = json.decode(data)
end

function ActivityBO.writeConfig()
	if not ActivityMO.localConfig_ then ActivityMO.localConfig_ = {} end

	local name = "activity" .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
	writefile(name, json.encode(ActivityMO.localConfig_))
end

function ActivityBO.addNewConfig(activityId)
	if not ActivityMO.localConfig_ then ActivityMO.localConfig_ = {} end

	for index = 1, #ActivityMO.localConfig_ do
		if ActivityMO.localConfig_[index] == activityId then return end
	end
	ActivityMO.localConfig_[#ActivityMO.localConfig_ + 1] = activityId

	ActivityBO.writeConfig()
end

-- 根据最新的活动数据，和本地的活动数据对比，将多余的活动数据删除
function ActivityBO.adjustConfig()
	for index = #ActivityMO.localConfig_, 1, -1 do
		local activityId = ActivityMO.localConfig_[index]
		local activity = ActivityMO.getActivityById(activityId)
		if not activity then  -- 活动已经被取消了
			table.remove(ActivityMO.localConfig_, index)
		end
	end
	ActivityBO.writeConfig()
end

function ActivityBO.isNew(activityId)
	if activityId == ACTIVITY_ID_GIFT_CODE then return false end

	for index = 1, #ActivityMO.localConfig_ do
		if activityId == ActivityMO.localConfig_[index] then return false end
	end
	return true
end

-- 活动是否有效
function ActivityBO.isValid(activityId)
	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return false end

	if not activity.open then return false end

	if ManagerTimer.getTime() <= activity.endTime then return true
	else return false end
end

function ActivityBO.getShowList()
	local res = {}
	for index = 1, #ActivityMO.activityList_ do
		local activity = ActivityMO.activityList_[index]
		if activity.displayTime > ManagerTimer.getTime() then
			res[#res + 1] = activity
		end
	end
	return res
end

function ActivityBO.isActCashbackOpen()
	-- body
	for index = 1, #ActivityMO.activityList_ do
		local activity = ActivityMO.activityList_[index]
		if activity.activityId == ACTIVITY_ID_CASHBACK then
			if activity.endTime > ManagerTimer.getTime() then
				return true
			else
				return false
			end
		end
	end
	return false
end

function ActivityBO.isActCashbackNewOpen()
	-- body
	for index = 1, #ActivityMO.activityList_ do
		local activity = ActivityMO.activityList_[index]
		if activity.activityId == ACTIVITY_ID_CASHBACK_NEW then
			if activity.endTime > ManagerTimer.getTime() then
				return true
			else
				return false
			end
		end
	end
	return false
end

function ActivityBO.getGiftCode()
	local activity = {}
	activity.activityId = ACTIVITY_ID_GIFT_CODE
	activity.name = CommonText[456][1]  -- 兑换礼包
	activity.open = true
	activity.new = false
	return activity
end

function ActivityBO.getPayFirst()
	local activity = {}
	activity.activityId = ACTIVITY_ID_PAY_FIRST
	activity.name = CommonText[456][2]  -- 首充礼包
	activity.open = true
	activity.new = false
	return activity
end

-- 首充礼包活动是否开启
function ActivityBO.isPayFirstOpen()
	if UserMO.topup_ == 0 then return true
	else return false end
end

-- 获得活动activityId的可以领取而没有领取的奖励的数量
function ActivityBO.getUnReceiveNum(activityId)
	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return 0 end
	if not activity.open then return 0 end
	
	if table.isexist(activity, "tips") and activity.tips > 0 then return activity.tips end
	
	if activityId == ACTIVITY_ID_EQUIP or activityId == ACTIVITY_ID_PART or activityId == ACTIVITY_ID_RTURN_DONATE or activityId == ACTIVITY_ID_CARVINAL
		or activityId == ACTIVITY_ID_PAY_FIRST or activityId == ACTIVITY_ID_GIFT_CODE or activityId == ACTIVITY_ID_MILITARY
		or activityId == ACTIVITY_ID_ENERGY or activityId == ACTIVITY_ID_EXPLOR_MEDAL or activityId == ACTIVITY_ID_TACTICS_EXPLORE then
		return 0
	elseif activityId == ACTIVITY_ID_FIGHT_RANK or activityId == ACTIVITY_ID_HONOUR or activityId == ACTIVITY_ID_COMBAT or activityId == ACTIVITY_ID_PARTY_LEVEL then  -- 战力排名
		if ActivityBO.hasSingleReceive(activityId) then return 0
		elseif ActivityBO.canSingleReceive(activityId) then return 1
		else return 0 end
	elseif activityId == ACTIVITY_ID_RESOURCE or activityId == ACTIVITY_ID_PARTY_RECURIT or activityId == ACTIVITY_ID_PURPLE_EQP_UP
		or activityId == ACTIVITY_ID_CRAZY_UPGRADE or activityId == ACTIVITY_ID_FIRST_REBATE then
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return 0 end

		local num = 0
		for itemIndex = 1, #activityContent.items do
			local conditions = activityContent.items[itemIndex].conditions
			for condIndex = 1, #conditions do
				if conditions[condIndex].status == 0 and ActivityBO.canStateReceive(activityId, conditions[condIndex], activityContent.items[itemIndex].state) then
					num = num + 1
				end
			end
		end
		return num
	elseif activityId == ACTIVITY_ID_QUOTA or activityId == ACTIVITY_ID_DAY_BUY or activityId == ACTIVITY_ID_FLASH_META or activityId == ACTIVITY_ID_FLASH_SALE
		or activityId == ACTIVITY_ID_PART_EVOLVE or activityId == ACTIVITY_ID_MONTH_SCALE or activityId == ACTIVITY_ID_ENEMY_SALE or activityId == ACTIVITY_ID_EQUIP_UP_CRIT
		or activityId == ACTIVITY_ID_VIP_GIFT or activityId == ACTIVITY_ID_SPRING_SCALE or activityId == ACTIVITY_ID_PARTY_DONATE or activityId == ACTIVITY_ID_REFINE_CRIT
		or activityId == ACTIVITY_ID_CON_SPRING_SCALE or activityId == ACTIVITY_ID_SCIENCE_SPEED or activityId == ACTIVITY_ID_BUILD_SPEED then
		-- or activityId == ACTIVITY_ID_POWRE_SUPPLY then
		return 0
	elseif activityId == ACTIVITY_ID_POWRE_SUPPLY then
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return 0 end

		local t = ManagerTimer.getTime()
		-- local t = os.time()
		local week = tonumber(os.date("%w",t))
		local h = tonumber(os.date("%H", t))
		local m = tonumber(os.date("%M", t))
		local s = tonumber(os.date("%S", t))
		local conditions = activityContent.conditions
		local num = 0
		for index = 1,#conditions do
			local activityAward = ActivityMO.getActivityAwardsByTime(index)
			local temp1 = string.split(activityAward.startTime, ":")
			local temp2 = string.split(activityAward.endTime, ":")
			
			local state = conditions[index]
			if h >= tonumber(temp1[1]) and h < tonumber(temp2[1]) and state == 1 then
				num = num + 1
			end
		end
		return num
	-- elseif activityId == ACTIVITY_ID_PURPLE_EQP_COL then  -- 紫装收集
	-- 	local activityContent = ActivityMO.getActivityContentById(activityId)
	-- 	if not activityContent then return 0 end

	-- 	local total = 0  -- 总的紫装穿戴数量
	-- 	for formatPos = 1, FIGHT_FORMATION_POS_NUM do total = total + EquipBO.getQualityEquipNumAtFormatIndex(formatPos, 4) end

	-- 	for itemIndex
	-- 	return total
	elseif activityId == ACTIVITY_ID_CONTU_PAY_NEW then
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return 0 end
		local conditions = activityContent.conditions
		local state = activityContent.state
		local num = 0
		for index = 1, #conditions do
			if state[index] >= conditions[index].cond and conditions[index].status == 0 then  -- 可以领，但没有领
				num = num + 1
			end
		end
		return num
	elseif activityId == ACTIVITY_ID_PARTY_LIVES then --军团活跃活动
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return 0 end
		local activity = ActivityMO.getActivityById(activityId)
		local activityAwards = ActivityMO.getPatyWarById(activity.awardId)
		if not activityContent or (not activityAwards) then return 0 end
		local contents = activityContent.contents
		local states = activityContent.states
		local num = 0

		for index=1,#contents do
			if states[index].state == 0 and contents[index].progress >= activityAwards[index].eventCondition then
				num = num + 1
			end
		end

		return num
	else
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return 0 end

		local conditions = activityContent.conditions
		local num = 0
		for index = 1, #conditions do
			if ActivityBO.canReceive(activityId, conditions[index]) and conditions[index].status == 0 then  -- 可以领，但没有领
				num = num + 1
			end
		end
		return num
	end
end

function ActivityBO.canReceive(activityId, activityCondition)
	if not activityCondition then return false end

	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return false end

	if activityId == ACTIVITY_ID_LEVEL_RANK then  -- 等级排名
		if UserMO.level_ >= activityCondition.cond then return true
		else return false end
	elseif activityId == ACTIVITY_ID_INVEST or activityId == ACTIVITY_ID_INVEST_NEW then
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return false end
		if activityContent.state == 0 then return false end  -- 没有参与

		local buildLv = BuildMO.getBuildLevel(BUILD_ID_COMMAND)
		if buildLv >= activityCondition.cond then return true
		else return false end
	elseif activityId == ACTIVITY_ID_PURPLE_EQP_COL then  -- 紫装收集穿戴
		local total = 0
		for formatPos = 1, FIGHT_FORMATION_POS_NUM do total = total + EquipBO.getQualityEquipNumAtFormatIndex(formatPos, 4) end

		if total >= activityCondition.cond then return true
		else return false end
	elseif activityId == ACTIVITY_ID_VIP_GIFT then  -- VIP礼包
		if UserMO.vip_ >= activityCondition.cond then return true
		else return false end
	elseif activityId == ACTIVITY_ID_ATTACK or activityId == ACTIVITY_ID_ATTACK_NEW or activityId == ACTIVITY_ID_FIGHT_COMBAT or activityId == ACTIVITY_ID_PAY_RED_GIFT
		or activityId == ACTIVITY_ID_PAY_EVERYDAY or activityId == ACTIVITY_ID_CRAZY_ARENA or activityId == ACTIVITY_ID_CONTU_PAY or activityId == ACTIVITY_ID_CONTU_PAY_NEW
		or activityId == ACTIVITY_ID_DAY_PAY or activityId == ACTIVITY_ID_GIFT_ONLINE or activityId == ACTIVITY_ID_MONTH_LOGIN
		or activityId == ACTIVITY_ID_COST_GOLD or activityId == ACTIVITY_ID_PAY_FOUR or activityId == ACTIVITY_ID_RECHARGE_GIFT 
		or activityId == ACTIVITY_ID_CON_COST_GOLD or activityId == ACTIVITY_ID_CON_RECHARGE_GIFT or activityId == ACTIVITY_ID_SECRET_WEAPON then -- 攻打玩家、激情关卡
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return false end
		if activityId == ACTIVITY_ID_SECRET_WEAPON then
			if UserMO.level_ >= 60 and activityContent.cnt >= activityCondition.cond then return true
			else return false end
		else
			if activityContent.state >= activityCondition.cond then return true
			else return false end
		end
		-- if activityContent.state >= activityCondition.cond then return true
		-- else return false end
	end
end

function ActivityBO.canStateReceive(activityId, activityCondition, state)
	if activityId == ACTIVITY_ID_RESOURCE or activityId == ACTIVITY_ID_PARTY_RECURIT or activityId == ACTIVITY_ID_PURPLE_EQP_UP
		or activityId == ACTIVITY_ID_CRAZY_UPGRADE or activityId == ACTIVITY_ID_FIRST_REBATE then -- 资源采集、军团招募、紫装升级
		if state >= activityCondition.cond then return true
		else return false end
	end
end

-- activityId: 活动是否已经领取了
function ActivityBO.hasSingleReceive(activityId)
	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return false end

	local activityContent = ActivityMO.getActivityContentById(activityId)

	if activityId == ACTIVITY_ID_FIGHT_RANK or activityId == ACTIVITY_ID_HONOUR or activityId == ACTIVITY_ID_COMBAT
		or activityId == ACTIVITY_ID_PARTY_LEVEL or activityId == ACTIVITY_ID_PARTY_FIGHT then  -- 战力排名
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if not activityContent then return false end

		local conditions = activityContent.conditions
		for index = 1, #conditions do
			if conditions[index].status == 1 then  -- 只要有一个领取，所有的都领取了
				return true
			end
		end
	end
	return false
end

function ActivityBO.canSingleReceive(activityId)
	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return false end

	local activityContent = ActivityMO.getActivityContentById(activityId)
	if not activityContent then return false end

	if activityId == ACTIVITY_ID_FIGHT_RANK or activityId == ACTIVITY_ID_HONOUR or activityId == ACTIVITY_ID_COMBAT
		or activityId == ACTIVITY_ID_PARTY_LEVEL or activityId == ACTIVITY_ID_PARTY_FIGHT then  -- 战力排名
		if activityContent.state <= 0 then return false end

		local activityContent = ActivityMO.getActivityContentById(activityId)
		local conditions = activityContent.conditions
		for index = 2, #conditions do
			local condition = conditions[index - 1]
			if activityContent.state <= condition.cond then  -- 达到了条件
				receiveCondition = condition
				return true
			end

			local condition = conditions[index]
			if activityContent.state <= condition.cond then  -- 达到了条件
				receiveCondition = condition
				return true
			end
		end
		return false
	end
end

function ActivityBO.trigger(activityId, param)
	local activity = ActivityMO.getActivityById(activityId)
	if not activity then return end

	local activityContent = ActivityMO.getActivityContentById(activityId)
	if not activityContent then
		ActivityBO.asynGetActivityContent(nil, activityId)
		return
	end

	if activityId == ACTIVITY_ID_ATTACK or activityId == ACTIVITY_ID_ATTACK_NEW or activityId == ACTIVITY_ID_FIGHT_COMBAT or activityId == ACTIVITY_ID_CRAZY_ARENA
		or activityId == ACTIVITY_ID_PAY_RED_GIFT or activityId == ACTIVITY_ID_PAY_EVERYDAY or activityId == ACTIVITY_ID_DAY_PAY then
		activityContent.state = activityContent.state + param
	elseif activityId == ACTIVITY_ID_PARTY_RECURIT then -- 军团招募捐献
		gdump(param, "ActivityBO.trigger")
		if param.type == "hall" then -- 大厅的捐献
			if param.id == PARTY_CONTRIBUTE_TYPE_COIN then -- 金币捐献
				activityContent.items[2].state = activityContent.items[2].state + 1
			else  -- 资源捐献
				activityContent.items[1].state = activityContent.items[1].state + 1
			end
		elseif param.type == "science" then -- 科技厅的捐献
			if param.id == PARTY_CONTRIBUTE_TYPE_COIN then -- 金币捐献
				activityContent.items[4].state = activityContent.items[4].state + 1
			else  -- 资源捐献
				activityContent.items[3].state = activityContent.items[3].state + 1
			end
		end
	elseif activityId == ACTIVITY_ID_PURPLE_EQP_COL then -- 在下面的ActivityBO.getUnReceiveNum()方法中判断
	elseif activityId == ACTIVITY_ID_PURPLE_EQP_UP then  -- 紫装升级
		local keyId = param.keyId
		local oldLv = param.oldLv
		local newLv = param.newLv

		if oldLv >= newLv then return end

		gdump(param, "trigger ACTIVITY_ID_PURPLE_EQP_UP")

		for itemIdx = 1, #activityContent.items do
			local item = activityContent.items[itemIdx]
			if #item.conditions < 1 or #item.conditions > 1 then  -- 只能有一个
				gprint("ActivityBO.trigger Error!", itemIdx, "id:", activityId)
			end
			local condition = item.conditions[1]
			if condition.param > oldLv and condition.param <= newLv then  -- 装备升级到了指定的等级，则状态加1
				item.state = item.state + 1
			end
		end
	elseif activityId == ACTIVITY_ID_CRAZY_UPGRADE then
		local heroId = param
		local heroDB = HeroMO.queryHero(heroId)
		gdump(heroDB, "HeroBO.asynImprove hero db")

		for itemIdx = 1, #activityContent.items do
			local item = activityContent.items[itemIdx]
			if #item.conditions < 1 or #item.conditions > 1 then  -- 只能有一个
				gprint("ActivityBO.trigger Error!", itemIdx, "id:", activityId)
			end
			local condition = item.conditions[1]
			if condition.param == heroDB.star then  -- 武将升级到指定的等阶
				item.state = item.state + 1
			end
		end
	end

	gdump(activityContent, "ActivityBO.trigger !!!!!!!!!!!!!")

	-- if ActivityBO.getUnReceiveNum(activityId) > 0 then
	Notify.notify(LOCLA_ACTIVITY_EVENT)
	-- end
end

function ActivityBO.getRechargeConditionIndex(activityId)
	if activityId == ACTIVITY_ID_PAY_RED_GIFT or activityId == ACTIVITY_ID_PAY_EVERYDAY or activityId == ACTIVITY_ID_DAY_PAY
		or activityId == ACTIVITY_ID_RECHARGE_GIFT or activityId == ACTIVITY_ID_COST_GOLD or activityId == ACTIVITY_ID_CON_COST_GOLD
		or activityId == ACTIVITY_ID_CON_RECHARGE_GIFT or activityId == ACTIVITY_ID_SECRET_WEAPON then
		local activityContent = ActivityMO.getActivityContentById(activityId)
		for index = 1, #activityContent.conditions do
			if activityId == ACTIVITY_ID_SECRET_WEAPON then
				if activityContent.cnt < activityContent.conditions[index].cond then
					return index
				end
			else
				if activityContent.state < activityContent.conditions[index].cond then
					return index
				end
			end
			-- if activityContent.state < activityContent.conditions[index].cond then
			-- 	return index
			-- end
		end
		return #activityContent.conditions
	end
	return 0
end

function ActivityBO.asynGetActivityContent(doneCallback, activityId)
	local function parseActivityContent(name, data)
		local activity = ActivityMO.getActivityById(activityId)
		if activity then
			if table.isexist(activity, "tips") then activity.tips = 0 end -- tips交给客户端维护
		end

		ActivityMO.activityContents_[activityId] = {}

		if activityId == ACTIVITY_ID_PARTY_RECURIT or activityId == ACTIVITY_ID_RESOURCE then  -- 军团募集、资源采集
			local itemName = nil
			if activityId == ACTIVITY_ID_PARTY_RECURIT then
				itemName = {"hallResource", "hallGold", "scienceResource", "scienceGold"}
			elseif activityId == ACTIVITY_ID_RESOURCE then
				itemName = {"iron", "oil", "copper", "silicon", "stone"}
			end

			ActivityMO.activityContents_[activityId].items = {}

			for index = 1, #itemName do
				if table.isexist(data, itemName[index]) then
					local dataItem = PbProtocol.decodeRecord(data[itemName[index]])

					ActivityMO.activityContents_[activityId].items[index] = {state = dataItem.state, conditions = {}}

					local contents = PbProtocol.decodeArray(dataItem.activityCond)
					for condIndex = 1, #contents do
						local content = contents[condIndex]
						local awards = PbProtocol.decodeArray(content["award"])
						for awardIndex = 1, #awards do
							awards[awardIndex].kind = awards[awardIndex].type
						end
						ActivityMO.activityContents_[activityId].items[index].conditions[condIndex] = {keyId = content.keyId, cond = content.cond, status = content.status, award = awards}
					end
				end
			end
			gdump(ActivityMO.activityContents_[activityId], "ActivityBO.asynGetActivityContent ...")
		elseif activityId == ACTIVITY_ID_QUOTA or activityId == ACTIVITY_ID_PART_EVOLVE or activityId == ACTIVITY_ID_FLASH_SALE
			or activityId == ACTIVITY_ID_DAY_BUY or activityId == ACTIVITY_ID_FLASH_META or activityId == ACTIVITY_ID_MONTH_SCALE
			or activityId == ACTIVITY_ID_ENEMY_SALE or activityId == ACTIVITY_ID_EQUIP_UP_CRIT or activityId == ACTIVITY_ID_SPRING_SCALE
			or activityId == ACTIVITY_ID_REFINE_CRIT or activityId == ACTIVITY_ID_CON_SPRING_SCALE or activityId == ACTIVITY_ID_SCIENCE_SPEED
			or activityId == ACTIVITY_ID_BUILD_SPEED then  -- 开服限购、配件进化、限时抢购、淬炼暴击
			local quotas = PbProtocol.decodeArray(data["quota"])
			gdump(quotas, "ActivityBO.asynGetActivityContent quotas")

			ActivityMO.activityContents_[activityId].items = {}
			for index = 1, #quotas do
				local quota = quotas[index]
				ActivityMO.activityContents_[activityId].items[index] = quota
			end
		elseif activityId == ACTIVITY_ID_VIP_GIFT then
			ActivityMO.activityContents_[activityId].items = {}

			local vipQuotas = PbProtocol.decodeArray(data["quotaVip"])

			gdump(vipQuotas, "ActivityBO.asynGetActivityContent vip quotas ==> ACTIVITY_ID_VIP_GIFT")
			for index = 1, #vipQuotas do
				local vipQuota = vipQuotas[index]

				local quota = PbProtocol.decodeRecord(vipQuota.quota)

				ActivityMO.activityContents_[activityId].items[index] = quota
				ActivityMO.activityContents_[activityId].items[index].vip = vipQuota.vip
			end
		elseif activityId == ACTIVITY_ID_POWRE_SUPPLY then
			local powerState = data["state"]
			ActivityMO.activityContents_[activityId].conditions  = powerState
		elseif activityId == ACTIVITY_ID_PURPLE_EQP_UP or activityId == ACTIVITY_ID_CRAZY_UPGRADE or activityId == ACTIVITY_ID_FIRST_REBATE then  -- 紫装升级、疯狂进阶
			ActivityMO.activityContents_[activityId].items = {}

			local condStates = PbProtocol.decodeArray(data["condState"])
			-- gdump(condStates, "activityId 111" .. activityId)
			for index = 1, #condStates do
				local condState = condStates[index]
				ActivityMO.activityContents_[activityId].items[index] = {state = condState.state, conditions = {}}

				local activityConds = PbProtocol.decodeArray(condState["activityCond"])
				for condIndex = 1, #activityConds do
					local activityCond = activityConds[condIndex]
					local param = nil
					if table.isexist(activityCond, "param") then param = tonumber(activityCond["param"]) end

					local awards = PbProtocol.decodeArray(activityCond["award"])
					for awardIndex = 1, #awards do
						awards[awardIndex].kind = awards[awardIndex].type
					end
					ActivityMO.activityContents_[activityId].items[index].conditions[condIndex] = {keyId = activityCond.keyId, cond = activityCond.cond, status = activityCond.status, award = awards, param = param}
				end
			end
			gdump(ActivityMO.activityContents_[activityId], "ActivityBO.asynGetActivityContent")
		elseif activityId == ACTIVITY_ID_SERVERS_LOGIN then
			ActivityMO.activityContents_[activityId].conditions = {}
			local contents = PbProtocol.decodeArray(data["conds"])
			for index = 1, #contents do
				local content = contents[index]

				local param = nil
				if table.isexist(content, "param") then param = content["param"] end

				local awards = PbProtocol.decodeArray(content["award"])
				for index = 1, #awards do
					awards[index].kind = awards[index].type
				end

				ActivityMO.activityContents_[activityId].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
			end
		elseif activityId == ACTIVITY_ID_SECRET_WEAPON then --秘密武器活动
			ActivityMO.activityContents_[activityId].conditions = {}
			local contents = PbProtocol.decodeArray(data["cond"])
			local cnt = data.cnt
			ActivityMO.activityContents_[activityId].cnt = cnt

			for index = 1, #contents do
				local content = contents[index]

				local param = nil
				if table.isexist(content, "param") then param = content["param"] end

				local awards = PbProtocol.decodeArray(content["award"])
				for index = 1, #awards do
					awards[index].kind = awards[index].type
				end

				ActivityMO.activityContents_[activityId].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
			end
		elseif activityId == ACTIVITY_ID_BIGWIG_LEADER then --大咖带队
			--
			-- repeated TwoInt twoInt = 1;//key-vip等级,V-达成数量
			-- repeated ActivityCond cond = 2;
			--
			ActivityMO.activityContents_[activityId].conditions = {}
			-- 通用
			local contents = PbProtocol.decodeArray(data["cond"])

			for index = 1, #contents do
				local content = contents[index]

				local param = nil
				if table.isexist(content, "param") then param = content["param"] end

				local awards = PbProtocol.decodeArray(content["award"])
				for index = 1, #awards do
					awards[index].kind = awards[index].type
				end

				ActivityMO.activityContents_[activityId].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
			end

			ActivityMO.activityContents_[activityId].vipInfo = {}
			local vipCounts = PbProtocol.decodeArray(data["twoInt"])
			for index = 1, #vipCounts do
				local vc = vipCounts[index]
				local vipLv = vc["v1"]
				local vipCount = vc["v2"]
				ActivityMO.activityContents_[activityId].vipInfo[vipLv] = {lv = vipLv, count = vipCount}
			end
		elseif activityId == ACTIVITY_ID_LOTTERY_TREASURE then --探宝大师
			-- optional int32 score = 1;				//本次活动积分
			-- repeated ActivityCond cond = 2;

			ActivityMO.activityContents_[activityId].conditions = {}
			-- 通用
			local contents = PbProtocol.decodeArray(data["cond"])

			for index = 1, #contents do
				local content = contents[index]

				local param = nil
				if table.isexist(content, "param") then param = content["param"] end

				local awards = PbProtocol.decodeArray(content["award"])
				for index = 1, #awards do
					awards[index].kind = awards[index].type
				end

				ActivityMO.activityContents_[activityId].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
			end

			if table.isexist(data,"score") then
				ActivityMO.activityContents_[activityId].score = data.score
			else
				ActivityMO.activityContents_[activityId].score = 0
			end
		elseif activityId == ACTIVITY_ID_PARTY_LIVES then --军团活跃活动
			local activityAwards = ActivityMO.getPatyWarById(activity.awardId)
			local contents = {}
			local states = {}
			for index=1,#activityAwards do
				local rewars = activityAwards[index]
				contents[index] = {id = rewars.Id, progress = 0}
				states[index] = {id = rewars.Id, state = 0}

				if table.isexist(data, "info") then
					local info = PbProtocol.decodeArray(data["info"])
					for idx=1,#info do
						if info[idx].v1 == rewars.Id then
							contents[index] = {id = info[idx].v1, progress = info[idx].v2}
						end
					end
				end

				if table.isexist(data, "rewardState") then
					local rewardState = PbProtocol.decodeArray(data["rewardState"])
					for idx=1,#rewardState do
						if rewardState[idx].v1 == rewars.Id then
							states[index] = {id = rewardState[idx].v1, state = rewardState[idx].v2}
						end
					end
				end
			end

			ActivityMO.activityContents_[activityId].contents = contents
			ActivityMO.activityContents_[activityId].states = states
		else
			ActivityMO.activityContents_[activityId].conditions = {}
			
			local contents = PbProtocol.decodeArray(data["activityCond"])
			for index = 1, #contents do
				local content = contents[index]

				local param = nil
				if table.isexist(content, "param") then param = content["param"] end

				local awards = PbProtocol.decodeArray(content["award"])
				for index = 1, #awards do
					awards[index].kind = awards[index].type
				end

				ActivityMO.activityContents_[activityId].conditions[index] = {keyId = content.keyId, cond = content.cond, status = content.status, param = param, award = awards}
			end

			if table.isexist(data, "state") then
				if activityId == ACTIVITY_ID_MONTH_LOGIN then  -- 每月登录
					ActivityMO.activityContents_[activityId].state = data.state % 100
				else
					ActivityMO.activityContents_[activityId].state = data.state
				end
			else
				ActivityMO.activityContents_[activityId].state = 0
			end

			gdump(ActivityMO.activityContents_[activityId], "ActivityBO.asynGetActivityContent")
		end

		Notify.notify(LOCLA_ACTIVITY_EVENT)

		if doneCallback then doneCallback(statsAward) end

		-- 埋点
		Statistics.postPoint(STATIS_ACTIVITY + activityId)
	end

	gprint("ActivityBO:", activityId)

	if activityId == ACTIVITY_ID_LEVEL_RANK then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActLevel"))
	elseif activityId == ACTIVITY_ID_POWRE_SUPPLY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetPowerGiveData"))
	elseif activityId == ACTIVITY_ID_ATTACK or activityId == ACTIVITY_ID_ATTACK_NEW then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActAttack",{activityId = activityId}))
	elseif activityId == ACTIVITY_ID_FIGHT_RANK then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActFight"))
	elseif activityId == ACTIVITY_ID_COMBAT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCombat"))
	elseif activityId == ACTIVITY_ID_HONOUR then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActHonour"))
	elseif activityId == ACTIVITY_ID_PARTY_LEVEL then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPartyLv"))
	elseif activityId == ACTIVITY_ID_PARTY_RECURIT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPartyDonate"))
	elseif activityId == ACTIVITY_ID_RESOURCE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCollect"))
	elseif activityId == ACTIVITY_ID_FIGHT_COMBAT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCombatSkill"))
	elseif activityId == ACTIVITY_ID_PARTY_FIGHT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPartyFight"))
	elseif activityId == ACTIVITY_ID_INVEST or activityId == ACTIVITY_ID_INVEST_NEW then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActInvest",{activityId = activityId}))
	elseif activityId == ACTIVITY_ID_PAY_RED_GIFT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPayRedGift"))
	elseif activityId == ACTIVITY_ID_PAY_EVERYDAY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActEveryDayPay"))
	-- elseif activityId == ACTIVITY_ID_PAY_FIRST then
	-- 	SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPayFirst"))
	elseif activityId == ACTIVITY_ID_QUOTA then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActQuota"))
	elseif activityId == ACTIVITY_ID_PURPLE_EQP_COL then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPurpleEqpColl"))
	elseif activityId == ACTIVITY_ID_PURPLE_EQP_UP then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPurpleEqpUp"))
	elseif activityId == ACTIVITY_ID_CRAZY_ARENA then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCrazyArena"))
	elseif activityId == ACTIVITY_ID_CRAZY_UPGRADE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCrazyUpgrade"))
	elseif activityId == ACTIVITY_ID_PART_EVOLVE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPartEvolve"))
	elseif activityId == ACTIVITY_ID_FLASH_SALE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActFlashSale"))
	elseif activityId == ACTIVITY_ID_COST_GOLD then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCostGold"))
	elseif activityId == ACTIVITY_ID_CONTU_PAY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActContuPay"))
	elseif activityId == ACTIVITY_ID_CONTU_PAY_NEW then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActContuPayMore"))
	elseif activityId == ACTIVITY_ID_DAY_PAY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActDayPay"))
	elseif activityId == ACTIVITY_ID_DAY_BUY then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActDayBuy"))
	elseif activityId == ACTIVITY_ID_FLASH_META then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActFlashMeta"))
	elseif activityId == ACTIVITY_ID_MONTH_SCALE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActMonthSale"))
	elseif activityId == ACTIVITY_ID_GIFT_ONLINE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActGiftOL"))
	elseif activityId == ACTIVITY_ID_MONTH_LOGIN then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActMonthLogin"))
	elseif activityId == ACTIVITY_ID_ENEMY_SALE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActEnemySale"))
	elseif activityId == ACTIVITY_ID_EQUIP_UP_CRIT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActUpEquipCrit"))
	elseif activityId == ACTIVITY_ID_FIRST_REBATE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActReFristPay"))
	elseif activityId == ACTIVITY_ID_RECHARGE_GIFT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActGiftPay"))
	elseif activityId == ACTIVITY_ID_VIP_GIFT then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActVipGift"))
	elseif activityId == ACTIVITY_ID_PAY_FOUR then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActPayContu4"))
	elseif activityId == ACTIVITY_ID_SPRING_SCALE then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActFesSale"))
	elseif activityId == ACTIVITY_ID_SERVERS_LOGIN then
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActMergeGift"))
	elseif activityId == ACTIVITY_ID_REFINE_CRIT then  --淬炼暴击
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActSmeltPartCrit"))
	elseif activityId == ACTIVITY_ID_CON_COST_GOLD then --合服消费
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActCostGold",{activityId = activityId}))
	elseif activityId == ACTIVITY_ID_CON_RECHARGE_GIFT then --合服累冲
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActGiftPay",{activityId = activityId}))
	elseif activityId == ACTIVITY_ID_CON_SPRING_SCALE then --合服限购
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActFesSale",{activityId = activityId}))
	elseif activityId == ACTIVITY_ID_SECRET_WEAPON then --秘密武器
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActScrtWpnStdCnt"))
	elseif activityId == ACTIVITY_ID_BIGWIG_LEADER then --大咖带队
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActVipCountInfo"))
	elseif activityId == ACTIVITY_ID_LOTTERY_TREASURE then --探宝大师
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetActLotteryExplore"))
	elseif activityId == ACTIVITY_ID_SCIENCE_SPEED then --科技加速
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActTechInfo"))
	elseif activityId == ACTIVITY_ID_BUILD_SPEED then --建筑加速
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("ActBuildInfo"))
	elseif activityId == ACTIVITY_ID_PARTY_LIVES then --军团活跃活动
		SocketWrapper.wrapSend(parseActivityContent, NetRequest.new("GetWarActivityInfo"))
	end
end

function ActivityBO.asynReceiveAward(doneCallback, activityId, keyId)
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

		local activityCondition = ActivityMO.getActivityConditionById(activityId, keyId)
		if activityCondition then
			activityCondition.status = 1 -- 活动已领取
		end

		gdump(activityCondition, "ActivityBO.asynReceiveAward")

		UiUtil.showAwards(statsAward)

		Notify.notify(LOCLA_ACTIVITY_EVENT)

		if activityId == ACTIVITY_ID_LEVEL_RANK and not ActivityMO.isLevelActivityShow() then
			Notify.notify(LOCAL_ACTIVITY_LEVEL_EVENT)
		end

		if doneCallback then doneCallback(statsAward) end
	end

	SocketWrapper.wrapSend(parseActivityAward, NetRequest.new("GetActivityAward", {activityId = activityId, keyId = keyId}))
end

function ActivityBO.asynPowerAward(doneCallback, activityId, index)
	local function parsePowerAward(name, data)
		-- gdump(data, "[ActivityBO] asynReceiveAward")

		local awards = PbProtocol.decodeArray(data["reward"])

		-- --TK统计
		-- for index=1,#awards do
		-- 	local award = awards[index]
		-- 	if award.type == ITEM_KIND_COIN then
		-- 		TKGameBO.onReward(award.count, TKText[48])
		-- 	end
		-- end

		local statsAward = CombatBO.addAwards(awards)
		UiUtil.showAwards(statsAward)

		ActivityMO.activityContents_[activityId].conditions[index] = 2 --已领取

		if doneCallback then doneCallback() end
		Notify.notify(LOCLA_ACTIVITY_EVENT)
	end
	SocketWrapper.wrapSend(parsePowerAward, NetRequest.new("GetFreePower"))
end

function ActivityBO.asynDoInvest(doneCallback,activityId)
	local function parseDoInvest(name, data)

		if table.isexist(data, "gold") then 
			--TK统计
			TKGameBO.onReward(data.gold - UserMO.coin_, TKText[46])

			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end
		-- UserMO.reduceResource(ITEM_KIND_COIN, ACTIVITY_INVEST_TAKE_COIN)

		-- 已参与
		local activityContent = ActivityMO.getActivityContentById(activityId)
		if activityContent then
			activityContent.state = 1
		else
			print("@^^^^^^^^^^error no activityContent :", activityId)
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseDoInvest, NetRequest.new("DoInvest",{activityId = activityId}))
end

function ActivityBO.asynDoQuota(doneCallback, item, activityId)
	local function parseDoQuota(name, data)
		
		item.buy = item.buy + 1  -- 购买次数加1

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)

		if table.isexist(data, "gold") then 
			if awards and #awards > 0 then
				local newAwards = TKGameBO.arrangeAwards(awards)
				--TK统计
				local awardsName = ""
				local awardsCount = 0
				for index=1,#newAwards do
					local award = newAwards[index]
					awardsName = awardsName .. UserMO.getResourceData(award.type,award.id).name .. "*" .. award.count
				end
				TKGameBO.onUseCoinTk(data.gold,awardsName,TKGAME_USERES_TYPE_UPDATE)
			end
			--更新金币
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseDoQuota, NetRequest.new("DoQuota", {quotaId = item.quotaId, activityId = activityId}))
end

function ActivityBO.asynDoVipGift(doneCallback, item)
	local function parseDoVipGift(name, data)
		item.buy = item.buy + 1  -- 购买次数加1

		local awards = PbProtocol.decodeArray(data["award"])
		local statsAward = CombatBO.addAwards(awards)

		if table.isexist(data, "gold") then 
			if awards and #awards > 0 then
				local newAwards = TKGameBO.arrangeAwards(awards)
				--TK统计
				local awardsName = ""
				local awardsCount = 0
				for index=1,#newAwards do
					local award = newAwards[index]
					awardsName = awardsName .. UserMO.getResourceData(award.type,award.id).name .. "*" .. award.count
				end
				TKGameBO.onUseCoinTk(data.gold,awardsName,TKGAME_USERES_TYPE_UPDATE)
			end
			--更新金币
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end

		if doneCallback then doneCallback(statsAward) end
	end
	SocketWrapper.wrapSend(parseDoVipGift, NetRequest.new("DoActVipGift", {vip = item.vip}))
end


function ActivityBO.asynGetActPartyDonateRank(doneCallback)
	local function parseDoInvest(name, data)
		local ret = {}
		if table.isexist(data, "party") then 
			ret.party = PbProtocol.decodeRecord(data["party"])
		end
		if table.isexist(data, "open") then 
			ret.open = data.open
		end
		if table.isexist(data, "status") then 
			ret.status = data.status
		end
		if table.isexist(data, "actPartyRank") then 
			ret.actPartyRank = PbProtocol.decodeArray(data["actPartyRank"])
			--排序
			-- local sortFun = function(a,b)
			-- 	if a.rankValue == b.rankValue then
			-- 		return a.fight > b.fight
			-- 	else
			-- 		return a.rankValue > b.rankValue
			-- 	end
			-- end
			-- table.sort(ret.actPartyRank,sortFun)
		else
			ret.actPartyRank = {}
		end
		if table.isexist(data, "rankAward") then 
			ret.rankAward = PbProtocol.decodeArray(data["rankAward"])
		end

		ActivityMO.activityContents_[ACTIVITY_ID_PARTY_DONATE] = ret		

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseDoInvest, NetRequest.new("GetActPartyDonateRank"))
end


function ActivityBO.asynGetPartyRankAward(doneCallback,activityId)
	local function parseDoInvest(name, data)
		local rankData = ActivityMO.activityContents_[ACTIVITY_ID_PARTY_DONATE]
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
	SocketWrapper.wrapSend(parseDoInvest, NetRequest.new("GetPartyRankAward",{activityId = activityId}))
end

--军团是否在火力全开活动的排名中
function ActivityBO.getMyPartyDonateRank()
	local activityContent = ActivityMO.getActivityContentById(ACTIVITY_ID_PARTY_DONATE)
	local myParty = activityContent.party
	for index = 1,#activityContent.actPartyRank do
		local party = activityContent.actPartyRank[index]
		if party.partyId == myParty.partyId then
			return index
		end
	end
	return 0
end


-- 是否享受科技优惠活动
function ActivityBO.scienceIsDis(scienceId)
	if not ActivityBO.isValid(ACTIVITY_ID_SCIENCE_DIS) then return false end
	for index=1,#ACTIVITY_ID_SCIENCE_DIS_SID do
		local sid = ACTIVITY_ID_SCIENCE_DIS_SID[index]
		if scienceId == sid then
			return true
		end
	end
	return false
end

function ActivityBO.updateMonthSign(data)
	gdump(data,"updateMonthSign========")
	ActivityBO.sign_ = data
end

function ActivityBO.hasSign()
	local data = ActivityBO.sign_
	if not data then return false end
	if data.today_sign == 0 then
		return true
	end
	local month = tonumber(os.date("%m", ManagerTimer.getTime()))
	local days = ActivityMO.getMonthSign(month)
	if data.today_sign == 1 then
		if days[data.days].multiple > 1 then
			return true
		end
	end
	local last = nil
	if table.isexist(data, "day_ext") then
		table.sort(data.day_ext, function(a,b) return a < b end)
		last = data.day_ext[#data.day_ext]
	end
	for i=1,data.days do
		if days[i].extreward and days[i].extreward ~= "" then
			if not last or last < i then
				return true
			end
		end
	end
	return false
end

function ActivityBO.monthSign(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		ActivityBO.sign_.today_sign = data.today_sign
		ActivityBO.sign_.days = data.days
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("MonthSign"))
end

function ActivityBO.drawMonthSignExt(day,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		ActivityBO.sign_.day_ext = data.day_ext
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrawMonthSignExt",{days = day}))
end

---------------------------------------------------- 闪击行动 start

function ActivityBO.UpdateActStroke(data)
	-- required int32 activityId = 1;			//活动唯一ID, 0-或者null表示当前并无此活动
	-- optional int32 beginTime = 2;           //活动开启时间
 --    optional int32 endTime = 3;             //活动结束时间
	-- optional int32 serverTime = 4;			//服务器当前时间
	-- repeated int32 id = 5;					//已经领取过的奖励

	-- dump(data , "================================ UpdateActStroke")

	ActivityMO.actStroke = {}
	if not table.isexist(data,"activityId") then return end
	if data.activityId == 0 then return end
	
	ActivityMO.actStroke.actId = data.activityId

	if table.isexist(data,"beginTime") then 
		ActivityMO.actStroke.beginTime = data.beginTime
	end

	if table.isexist(data,"endTime") then 
		ActivityMO.actStroke.endTime = data.endTime
	end

	if table.isexist(data,"serverTime") then 
		ActivityMO.actStroke.serverTime = data.serverTime
	end

	ActivityMO.actStroke.id = 0
	if table.isexist(data,"id") then 
		ActivityMO.actStroke.ids = data.id
		ActivityMO.actStroke.id = #data.id
	end

	ActivityBO.ServerFixedCheck()
end

function ActivityBO.DrawActStrokeAward(rhand, id)
	-- required int32 id = 1;//时间点
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		-- optional int32 id = 1;					//领取的奖励ID
		-- repeated Award award = 1;//
		-- dump(data,"==== DrawActStrokeAward")

		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end

		-- 更新奖励ID
		if not ActivityMO.actStroke.ids then ActivityMO.actStroke.ids = {} end
		table.insert(ActivityMO.actStroke.ids , id)
		ActivityMO.actStroke.id = #ActivityMO.actStroke.ids

		ActivityBO.ServerFixedCheck()

		-- 更新时间
		ActivityMO.actStroke.serverTime = ManagerTimer.getTime()

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrawActStrokeAward",{id = id}))
end

-- 
-- ret 0 关闭或未开启 1 
function ActivityBO.ServerFixedCheck()
	local ret = 0
	local sub = 0
	if not ActivityMO.actStroke.actId or ActivityMO.actStroke.actId == 0 then return ret, sub end -- 关闭

	if ActivityMO.actStroke.endTime < ActivityMO.actStroke.serverTime then return ret, sub end -- 关闭

	if ActivityMO.actStroke.beginTime > ActivityMO.actStroke.serverTime then return ret, sub end -- 未开启

	local info = ActivityMO.getActStroke(ActivityMO.actStroke.actId , ActivityMO.actStroke.id + 1)

	ActivityMO.actStroke.period = nil

	if not info then return ret, sub end -- 结束

	local time = ActivityMO.actStroke.serverTime - ActivityMO.actStroke.beginTime

	ActivityMO.actStroke.period = info.period

	if time >= ActivityMO.actStroke.period then
		-- 可领取
		ret = 1
	else
		if ActivityMO.actStroke.id >= ActivityMO.actStrokeMax then
			-- 领取完毕
			ret = 3
		else
			-- 倒计时
			ret = 2
			sub = ActivityMO.actStroke.period - time
		end
	end
	return ret, sub
end

function ActivityBO.ServerFixedUpdate()
	if not ActivityMO.actStroke.actId or ActivityMO.actStroke.actId == 0 then return end -- 关闭

	if ActivityMO.actStroke.endTime < ActivityMO.actStroke.serverTime then return end -- 关闭

	if ActivityMO.actStroke.beginTime > ActivityMO.actStroke.serverTime then return end -- 未开启

	ActivityMO.actStroke.serverTime = ManagerTimer.getTime()

	local outTime = -1 -- -1 无效 -2 可领取 -3 领取完毕  >=0 正常
	local time = ActivityMO.actStroke.serverTime - ActivityMO.actStroke.beginTime
	
	if ActivityMO.actStroke.period then
		if time <= ActivityMO.actStroke.period then
			outTime = ActivityMO.actStroke.period - time
		else
			if ActivityMO.actStroke.id >= ActivityMO.actStrokeMax then
				outTime = -3
			else
				outTime = -2
			end
		end
	else
		if ActivityMO.actStroke.id >= ActivityMO.actStrokeMax then
			outTime = -3
		end
	end

	return outTime
end

---------------------------------------------------- 闪击行动 end

--福利特惠
function ActivityBO.getWelFare(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		if table.isexist(data, "info") then
			local status = PbProtocol.decodeArray(data.info)
			ActivityMO.welFare_ = status
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetBoxInfo"))
end

function ActivityBO.buyWelFare(rhand,id)
	local goodId = id
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local status = PbProtocol.decodeArray(data.info)
		ActivityMO.welFare_ = status

		local awards = PbProtocol.decodeArray(data["award"])
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)

		if table.isexist(data, "gold") then
			--TK统计
			TKGameBO.onReward(data.gold - UserMO.coin_, TKText[46])

			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyBox",{id = goodId}))
end

--六天登录福利
function ActivityBO.getLoginAwardsInfo(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetLoginWelfareInfo"))
end

function ActivityBO.getLoginAwards(rhand,id)
	local id = tonumber(id)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		local awards = PbProtocol.decodeArray(data["awards"])
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)

		if rhand then rhand(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetLoginWelfareAward",{awardId = id}))
end

--军团活跃活动领奖
function ActivityBO.getPartyWarAwards(rhand,id)
	local id = tonumber(id)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local states = PbProtocol.decodeArray(data["rewardState"])
		for idx=1,#ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].states do
			local record = ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].states[idx]
			for index=1,#states do
				if states[index].v1 == record.id then
					ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].states[idx].state = states[index].v2
				end
			end
		end

		local awards = PbProtocol.decodeArray(data["award"])
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)

		Notify.notify(LOCLA_ACTIVITY_EVENT)
		if rhand then rhand() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetWarActivityReward",{id = id}))
end

function ActivityBO.SynPartyWarInfo(name, data)
	local info = PbProtocol.decodeArray(data["info"])
	if ActivityBO.isValid(ACTIVITY_ID_PARTY_LIVES) then
		local activityContent = ActivityMO.getActivityContentById(ACTIVITY_ID_PARTY_LIVES)
		if not activityContent then
			ActivityBO.asynGetActivityContent(function ()
				for idx=1,#ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents do
					local record = ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents[idx]
					for index=1,#info do
						if info[index].v1 == record.id then
							ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents[idx].progress = info[index].v2
						end
					end
				end
				Notify.notify(LOCLA_ACTIVITY_EVENT)
			end, ACTIVITY_ID_PARTY_LIVES)
		else
			for idx=1,#ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents do
				local record = ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents[idx]
				for index=1,#info do
					if info[index].v1 == record.id then
						ActivityMO.activityContents_[ACTIVITY_ID_PARTY_LIVES].contents[idx].progress = info[index].v2
					end
				end
			end
			Notify.notify(LOCLA_ACTIVITY_EVENT)
		end
	end
end