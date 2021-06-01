--
-- Author: Xiaohang
-- Date: 2016-08-10 14:52:11
--
ExerciseBO = {}

function ExerciseBO.getInfo(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		-- required int32 status = 1;				// 红蓝大战活动的状态，0 未开启，1 报名，2 备战，3 预热，4 第一部队战斗，5 第二部队战斗，6 第三部队战斗
		-- required int32 enrollNum = 2;			// 已报名玩家的数量
		-- required int32 camp = 3;				// 玩家所在的阵营，0 未分配，1 红方，2 蓝方
		-- required int32 myArmy = 4;				// 玩家当前的部队数0~2
		-- required int32 exploit = 5;				// 玩家当前的功勋值
		-- required bool isEnrolled = 6;			// 玩家是否已报名，已报名返回true
		-- repeated bool redWin = 7;				// 这里用一个bool类型的List表示已经结束的战斗的结果，true表示这一路的战斗红方胜利，否则蓝方胜
		Loading.getInstance():unshow()
		ExerciseBO.data = data
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetDrillData"))
end

function ExerciseBO.apply(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		ExerciseBO.data.isEnrolled = true
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("DrillEnroll"))
end

--演习坦克兑换
function ExerciseBO.exchange(id,count,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		if ExerciseBO.army[data.tankId] then
			ExerciseBO.army[data.tankId].count = data.count
		else
			ExerciseBO.army[data.tankId] = {tankId=data.tankId,count=data.count}			
		end
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("ExchangeDrillTank",{tankId=id,count=count}))
end

--战况
function ExerciseBO.report(type,which,page,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = nil
		if data.result then 
			info = PbProtocol.decodeRecord(data.result)
		end
		local list = nil
		if data.record then
			list = PbProtocol.decodeArray(data.record)
		end
		rhand(info,list)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetDrillRecord",{type=type,which=which,page=page}))
end

--获取战报
function ExerciseBO.fightReport(key)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local report = PbProtocol.decodeRecord(data.rptAtkFortress)
		FortressBO.parseReport(report,1)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDrillFightReport",{reportKey=key}))
end

--获取排行
function ExerciseBO.getRank(rankType,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		data.ranks = PbProtocol.decodeArray(data.ranks)
		if rankType == 4 then
			ExerciseBO.ranks = data
		end
		if table.isexist(data, "killTank") then
			ExerciseBO.record = PbProtocol.decodeArray(data.killTank)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDrillRank",{rankType=rankType}))
end

--获取奖励
function ExerciseBO.getReward(rankType,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		ExerciseBO.ranks.canGetRank = false
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrillReward",{rewardType=rankType}))
end

--获取商店数据
function ExerciseBO.getShopInfo(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		ExerciseBO.shopData = {}
		ExerciseBO.shopIds = {}
		if data["buy"] then
			local list = PbProtocol.decodeArray(data["buy"])
			for k,v in pairs(list) do
				ExerciseBO.shopData[v.shopId] = v
			end
		end
		if data["treasureShopId"] then
			for k,v in pairs(data["treasureShopId"]) do
				ExerciseBO.shopIds[v] = true
			end
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDrillShop"))
end

--兑换商店物品
function ExerciseBO.buyShop(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		ExerciseBO.data.exploit = data.exploit
		local count = nil
		if table.isexist(data, "count") then
			count = data.count
		end
		rhand(count)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ExchangeDrillShop",{shopId=id,count=1}))
end

--获取进修数据
function ExerciseBO.getBuff(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data["improve"])
		ExerciseBO.buffData = {}
		for k,v in pairs(list) do
			ExerciseBO.buffData[v.buffId] = v
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDrillImprove"))
end

--进修
function ExerciseBO.improveBuff(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeRecord(data["improve"])
		Toast.show(CommonText[20107])
		ExerciseBO.buffData[info.buffId] = info
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DrillImprove",{buffId = id}))
end

--获取演习军力
function ExerciseBO.getArmy(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data["drillTank"])
		ExerciseBO.army = {}
		for k,v in pairs(list) do
			ExerciseBO.army[v.tankId] = v
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDrillTank"))
end

--上阵坦克数据
function ExerciseBO.getFightTank(kind, key)
	local temp = clone(ExerciseBO.army)
	for k = ARMY_SETTING_FOR_EXERCISE1,ARMY_SETTING_FOR_EXERCISE3 do
		if k ~= kind then
			local formation = TankMO.getFormationByType(k - (ARMY_SETTING_FOR_EXERCISE1 - FORMATION_FOR_EXERCISE1))
			if formation then
				for index = 1, FIGHT_FORMATION_POS_NUM do
					local data = formation[index]
					if data.count > 0 and temp[data.tankId] then
						temp[data.tankId].count = temp[data.tankId].count - data.count
					end
				end
			end
		end
	end
	if key then return temp end
	return table.values(temp)
end