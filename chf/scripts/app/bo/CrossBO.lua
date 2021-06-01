--
-- Author: Xiaohang
-- Date: 2016-09-22 11:02:44
--

CrossBO = {}

function CrossBO.getServerList(rhand)
	if CrossBO.serverList_ then
		rhand()
		return
	end
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossBO.serverList_ = PbProtocol.decodeArray(data.gameServerInfo)
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossServerList"))
end

function CrossBO.parseCrossSelf(name,data)
 	CrossMO.isOpen_ = data.state == 1
end

--状态
function CrossBO.getState(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossBO.state_ = data.state
		gprint("state ===========",CrossBO.state_,data.beginTime)
		CrossBO.beginTime_ = data.beginTime
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossFightState"), 1)
end

--报名
function CrossBO.applyFight(kind,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		Toast.show(CommonText[30013][1])
		CrossBO.myGroup_ = kind
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("CrossFightReg",{groupId = kind}), 1)
end

--报名信息
function CrossBO.getEnterInfo(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossBO.jyGroupPlayerNum_ = data.jyGroupPlayerNum
		CrossBO.dfGroupPlayerNum_ = data.dfGroupPlayerNum
		CrossBO.myGroup_ = data.myGroup
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossRegInfo"),1)
end

--取消报名
function CrossBO.cancelApply(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		Toast.show(CommonText[30013][2])
		CrossBO.myGroup_ = 0
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("CancelCrossReg"),1)
end

--获取阵型
function CrossBO.getFormation(rhand)
	if CrossBO.newFormation_ then
		rhand()
		return
	end
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local forms = PbProtocol.decodeArray(data.form)
		CrossBO.newFormation_ = true
		for k,v in ipairs(forms) do
			local formation, kind = CombatBO.parseServerFormation(v)
			if kind and kind > 0 then
				TankMO.formation_[kind] = formation
			end
		end
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossForm"),1)
end

--设置阵型
function CrossBO.setFormation(form,fight,kind)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local form = PbProtocol.decodeRecord(data.form)
		local newFormation, kind = CombatBO.parseServerFormation(form)
		TankMO.formation_[kind] = newFormation  -- 更新阵型
		Toast.show(CommonText[59])
	end
	local format = CombatBO.encodeFormation(form)
	format.type = kind
	SocketWrapper.wrapSend(getResult, NetRequest.new("SetCrossForm",{form = format,fight = fight}))
end

--个人战况
function CrossBO.getCrossPerson(page,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.crossRecord)
		rhand(info)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossPersonSituation",{page = page}), 1)
end

--积分排行
function CrossBO.getCrossScore(page,groupId,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.crossJiFenRank)
		rhand(info,data.jifen,data.myRank)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossJiFenRank",{page = page}))
end

--获取战报
function CrossBO.fightReport(key,state)
	if state > 1 then
		Toast.show(CommonText[30027][state] or "未知错误")
		return
	end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local report = PbProtocol.decodeRecord(data.crossRptAtk)
		FortressBO.parseReport(report,1)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossReport",{reportKey=key}))
end

--淘汰赛信息
function CrossBO.getKnockInfo(groupId,groupType,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.knockoutCompetGroup)
		local list = {}
		for k,v in ipairs(info) do
			list[v.competGroupId] = v
		end
		rhand(list)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossKnockCompetInfo",{groupId = groupId,groupType = groupType}))
end

--决赛信息
function CrossBO.getFinalInfo(groupId,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.finalCompetGroup)
		local list = {}
		for k,v in ipairs(info) do
			list[v.competGroupId] = v
		end
		rhand(list)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossFinalCompetInfo",{groupId = groupId}))
end

--下注
function CrossBO.betBattle(rhand,kind,stage,groupType,groupId,pos)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeRecord(data.myBet)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		Toast.show(CommonText[30034])
		rhand(info)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BetBattle",{myGroup=kind,stage=stage,groupType=groupType,competGroupId=groupId,pos=pos}))
end

--下注信息
function CrossBO.battleInfo(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.myBet)
		table.sort(info,function(a,b)
				return a.betTime > b.betTime
			end)
		rhand(info)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetMyBet"))
end

--下注领取
function CrossBO.battleGet(myBet,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local bet = PbProtocol.decodeRecord(data.myBet)
		CrossBO.score_ = data.crossJifen
		rhand(bet)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ReceiveBet",{myGroup = myBet.myGroup,stage=myBet.stage,groupType=myBet.groupType,competGroupId=myBet.competGroupId}))
end

--获取跨服商店数据
function CrossBO.GetCrossShop(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossBO.shopLeft_ = {}
		CrossBO.score_ = data.crossJifen
		local buy = PbProtocol.decodeArray(data.buy)
		for k,v in pairs(buy) do
			CrossBO.shopLeft_[v.shopId] = {v.buyNum,v.restNum}
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossShop"))
end

--兑换跨服战商店的物品
function CrossBO.exchanCrossShop(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossBO.score_ = data.crossJifen
		if CrossBO.shopLeft_[data.shopId] then
			CrossBO.shopLeft_[data.shopId][1] = CrossBO.shopLeft_[data.shopId][1] + 1
			CrossBO.shopLeft_[data.shopId][2] = data.restNum
		else
			CrossBO.shopLeft_[data.shopId] = {1,data.restNum}
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ExchangeCrossShop",{shopId=id,count=1}))
end

--积分详情
function CrossBO.scoreInfo(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossBO.score_ = data.crossJifen
		local info = PbProtocol.decodeArray(data.crossTrend)
		rhand(info)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossTrend"))
end

--上阵坦克数据
function CrossBO.getFightTank(kind, key)
	local temp = clone(TankMO.tanks_)
	for k = ARMY_SETTING_FOR_CROSS,ARMY_SETTING_FOR_CROSS2 do
		if k ~= kind then
			local formation = TankMO.getFormationByType(k)
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

--获取总排行信息
function CrossBO.rankInfo(kind,rhand)
	if CrossBO.rankInfo_ and CrossBO.rankInfo_[kind] then
		rhand()
		return
	end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data.crossTopRank)
		if not CrossBO.rankInfo_ then
			CrossBO.rankInfo_ = {}
		end
		if #list > 0 then
			CrossBO.rankInfo_[kind] = {}
			CrossBO.rankInfo_[kind].list = list
			CrossBO.rankInfo_[kind].myRank = data.myRank
			CrossBO.rankInfo_[kind].state = data.state
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossFinalRank",{group=kind}))
end

--领取排行奖励
function CrossBO.getRank(kind,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret, true)
		CrossBO.rankInfo_[kind].state = 2
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ReceiveRankRward",{group=kind}))
end

--跨服名人堂
function CrossBO.GetCrossRank(rhand,kind)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local key,key2 = "crossFameInfo","crossFame"
		if kind == 2 then
			key,key2 = "cpFameInfo","cpFame"
		end
		CrossBO.backData_ = PbProtocol.decodeArray(data[key])
		for k,v in ipairs(CrossBO.backData_) do
			v.crossFame = PbProtocol.decodeArray(v[key2])
		end
		table.sort(CrossBO.backData_,function(a,b)
				return a.keyId > b.keyId
			end)
		rhand()
	end
	Loading.getInstance():show()
	kind = kind or 1
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossRank",{type=kind}), 1)
end
