
ActivityWeekBO = {}
ActivityWeekBO.firstOpen = true
ActivityWeekBO.halfPrice = {}
function ActivityWeekBO.updateRedPoint(data)
	--- 避免 0点 刷新 清理数据
	ActivityWeekMO.WeekList_ = {}
	-- if not UiDirector.hasUiByName("ActivityWeekView") then 
	-- 	ActivityWeekMO.WeekList_ = {}
	-- end

	if not data then return end
	--local activities = PbProtocol.decodeArray()
	-- gdump(activities, "ActivityBO.update")
end

function ActivityWeekBO.refTime()
	local function refresh()
		--if UiDirector.hasUiByName("RankView1") then return end

		local function show()
	        --ActivityWeekMO.WeekList_.RedPoint = 
	    end
		ActivityWeekBO.asynGetDay7ActTips(function(success) if success then show() end end)
	end

	-- if not ActivityWeekBO.refreshHandler_ then
	-- 	--ActivityWeekBO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 180)
	-- else
	 	refresh()
	-- end
end

--七日活动相关(tips红点提示)
function ActivityWeekBO.asynGetDay7ActTips(doneCallback)
	local function parseResult(name, data)	
		Loading.getInstance():unshow()
		if not ActivityWeekMO.WeekList_ then
			ActivityWeekMO.WeekList_ = {}
		end
		ActivityWeekMO.tips = data["tips"]
		ActivityWeekMO.lvUpIsUse = data["lvUpIsUse"]
		ActivityWeekMO.RedPoint = 0
		local half = {}
		for k,v in pairs(ActivityWeekBO.halfPrice) do
			half[math.floor(k/10)] = true
		end
		for k,v in pairs(ActivityWeekMO.tips) do
			if half[k] then
				v = v - 1
			end
			ActivityWeekMO.RedPoint  = ActivityWeekMO.RedPoint + v
		end
		--dump(ActivityWeekMO.RedPoint)
		if doneCallback then doneCallback(true) end
	end
	Loading.getInstance():show()
	local request = NetRequest.new("GetDay7ActTips")
	SocketWrapper.wrapSend(parseResult, request, 1)
end

--根据天数获取界面数据
function ActivityWeekBO.asynGetDay7Act(doneCallback,_day)
	local function parseResult(name, data)
		if not ActivityWeekMO.WeekList_ then
			ActivityWeekMO.WeekList_ = {}
		end
		if table.isexist(data, "day7Acts") then 
			ActivityWeekMO.WeekList_[_day] = PbProtocol.decodeArray(data["day7Acts"])
		end
		Loading.getInstance():unshow()
		if doneCallback then doneCallback(true) end
	end
	Loading.getInstance():show()
	local request = NetRequest.new("GetDay7Act",{day =  _day})
	SocketWrapper.wrapSend(parseResult, request)
end

--领奖（id）
function ActivityWeekBO.asynRecvDay7ActAward(doneCallback,_id,_day,isBuy)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		if isBuy then
			ActivityWeekBO.halfPrice[_day*10 + 4] = nil
		end
		ActivityWeekBO.refTime()
		local temp = UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		for k,v in pairs(temp) do
			if v.count > 0 then
				UiUtil.showAwards({awards = {v}})
				break
			end
		end

		local reqData = ActivityWeekMO.WeekList_[_day]
		local ret = {}
		for k,v in pairs(reqData) do
			if _id == v.keyId then
				ret = v
			end
		end
		if ret ~= nil then
			ret.recved = 3
		end
		--ActivityWeekBO.refTime()
		--ActivityWeekMO.tips
		--奖励
		local awards = {}
		if table.isexist(data, "awards") then
			awards = PbProtocol.decodeArray(data["awards"])
			 --加入背包
			local ret1 = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret1, true)
		end
		if doneCallback then doneCallback(true) end
	end
	Loading.getInstance():show()
	local request = NetRequest.new("RecvDay7ActAward",{keyId = _id})
	SocketWrapper.wrapSend(parseResult, request, 1)
end

--当前天数，获取当前tab的星数
function ActivityWeekBO.getWeekCurrDayPoint(_index,currDay)
	local needData = nil
	if _index == 1 then
		needData = ActivityWeekMO.getFirstTabData(currDay)
	elseif _index == 2 then
		needData = ActivityWeekMO.getTwoTabData(currDay)
	elseif _index == 3 then
		needData = ActivityWeekMO.getThreeTabData(currDay)
	else
		needData = ActivityWeekMO.getFourTabData(currDay)
	end

	local count = 0
	if ActivityWeekMO.WeekList_[currDay] == nil then
		return 0
	end
 	for i=1,#needData do
 		local weekData = needData[i]
		local reqData = ActivityWeekMO.WeekList_[currDay]
		local ret = {}
		for k,v in pairs(reqData) do
			if weekData.keyId == v.keyId then
				ret = v
			end
		end
		if ret.recved == 0 then
			if _index == 4 then
				if not ActivityWeekBO.halfPrice[currDay*10 + _index] then
					count = count + 1
				end
			else
 				count = count + 1
 			end
 		end
 	end
 	return count
end

function ActivityWeekBO.getWeekCurrDayTotalPoint(currDay,isFirst)
	local first = isFirst or false
	local count1 = 0
	local count = 0
	local total = 4
	for i=1,total do
		count1 = count1 + ActivityWeekBO.getWeekCurrDayPoint(i,currDay)
	end

	if ActivityWeekMO.WeekList_[currDay] == nil then
		return ActivityWeekMO.tips[currDay]
	end
	return count1
end

--立即升级
function ActivityWeekBO.asynDay7ActLvUp(doneCallback)
	local function parseResult(name, data)
		Loading.getInstance():unshow()	
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret,true)
		--dump(awards)
		--local level, exp, upgrade = UserBO.addUpgradeResouce(ITEM_KIND_EXP, awards["count"])

		ActivityWeekMO.lvUpIsUse  = true
		if doneCallback then doneCallback(true) end
	end
	Loading.getInstance():show()
	local request = NetRequest.new("Day7ActLvUp")
	SocketWrapper.wrapSend(parseResult, request, 1)
end
