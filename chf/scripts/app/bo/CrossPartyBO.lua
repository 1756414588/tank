--
-- Author: Xiaohang
-- Date: 2016-09-22 11:02:44
--

CrossPartyBO = {}

function CrossPartyBO.getServerList(rhand)
	if CrossPartyBO.serverList_ then
		rhand()
		return
	end
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossPartyBO.serverList_ = PbProtocol.decodeArray(data.gameServerInfo)
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossPartyServerList"))
end

function CrossPartyBO.parseCrossSelf(name,data)
	if data.state == 1 then
		local chat = {channel = CHAT_TYPE_WORLD, sysId = 220, style = 1}
		ChatMO.addChat(chat.channel, nil, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, nil, false)
	end
 	CrossPartyMO.isOpen_ = data.state == 1
end

--同步小组赛战况
function CrossPartyBO.parseCrossTeam(name,data)
 	local group = data.gruop
 	Notify.notify(LOCAL_CROSSPARTY_SITUATION, {group = group, info = PbProtocol.decodeRecord(data.cpRecord)})
end

--状态
function CrossPartyBO.getState(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossPartyBO.state_ = data.state
		CrossPartyBO.beginTime_ = data.beginTime
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossPartyState"), 1)
end

--报名
function CrossPartyBO.applyFight(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		Toast.show(CommonText[30013][1])
		CrossPartyBO.myGroup_ = true
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("CrossPartyReg",{groupId = kind}), 1)
end

--积分详情
function CrossPartyBO.scoreInfo(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossBO.score_ = data.jifen
		local info = PbProtocol.decodeArray(data.crossTrend)
		rhand(info)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCPTrend"))
end

--获取参加跨服军团
function CrossPartyBO.getPartyInfo(kind,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.cpPartyInfo)
		rhand(info,data.totalRegPartyNum or 0)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossParty",{group = kind}),1)
end

--获取报名跨服军团成员列表
function CrossPartyBO.getMyPartyInfo(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local member = PbProtocol.decodeArray(data.cpMemberReg)
		rhand(member,data.group or 0)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossPartyMember",{group = kind}),1)
end

--获取报名显示
function CrossPartyBO.getRegInfo(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossPartyBO.myGroup_ = data.isReg
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCPMyRegInfo"),1)
end

--获取阵型
function CrossPartyBO.getFormation(rhand)
	if CrossPartyBO.newFormation_ then
		rhand()
		return
	end
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		CrossPartyBO.newFormation_ = TankMO.getEmptyFormation()
		if table.isexist(data,"form") then
			local form = PbProtocol.decodeRecord(data.form)
			local formation, kind = CombatBO.parseServerFormation(form)
			CrossPartyBO.newFormation_ = formation
		end
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCPForm"),1)
end

--设置阵型
function CrossPartyBO.setFormation(form,fight)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local form = PbProtocol.decodeRecord(data.form)
		local newFormation, kind = CombatBO.parseServerFormation(form)
		CrossPartyBO.newFormation_ = newFormation  -- 更新阵型
		Toast.show(CommonText[59])
	end
	local format = CombatBO.encodeFormation(form)
	SocketWrapper.wrapSend(getResult, NetRequest.new("SetCPForm",{form = format,fight = fight}))
end

--获取跨服军团状况
function CrossPartyBO.getCrossInfo(kind,page,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.cpRecord)
		rhand(info)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCPSituation",{group = kind,page = page}), 1)
end

--获取跨服军团本服战况
function CrossPartyBO.getMyCrossInfo(kind,page,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.cpRecord)
		rhand(info)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCPOurServerSituation",{type = kind,page = page}), 1)
end

--积分排行
function CrossPartyBO.getCrossScore(page,groupId,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = PbProtocol.decodeArray(data.crossJiFenRank)
		rhand(info,data.jifen,data.myRank)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetCrossJiFenRank",{page = page}))
end

--获取战报
function CrossPartyBO.fightReport(key)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local report = PbProtocol.decodeRecord(data.cpRptAtk)
		FortressBO.parseReport(report,1)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCPReport",{reportKey=key}), 1)
end

--获取跨服商店数据
function CrossPartyBO.GetCrossShop(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossPartyBO.shopLeft_ = {}
		CrossPartyBO.score_ = data.jifen
		local buy = PbProtocol.decodeArray(data.buy)
		for k,v in pairs(buy) do
			CrossPartyBO.shopLeft_[v.shopId] = {v.buyNum,v.restNum}
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCPShop"))
end

--兑换跨服战商店的物品
function CrossPartyBO.exchanCrossShop(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossPartyBO.score_ = data.jifen
		if CrossPartyBO.shopLeft_[data.shopId] then
			CrossPartyBO.shopLeft_[data.shopId][1] = CrossPartyBO.shopLeft_[data.shopId][1] + 1
			CrossPartyBO.shopLeft_[data.shopId][2] = data.restNum
		else
			CrossPartyBO.shopLeft_[data.shopId] = {1,data.restNum}
		end
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ExchangeCPShop",{shopId=id,count=1}))
end

--上阵坦克数据
function CrossPartyBO.getFightTank(kind, key)
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
function CrossPartyBO.rankInfo(kind,page,rhand)
	-- if CrossPartyBO.rankInfo_ and CrossPartyBO.rankInfo_[kind] then
	-- 	rhand()
	-- 	return
	-- end
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local list = PbProtocol.decodeArray(data.cpRank)
		if not CrossPartyBO.rankInfo_ then
			CrossPartyBO.rankInfo_ = {}
		end
		CrossPartyBO.rankInfo_[kind] = {}
		CrossPartyBO.rankInfo_[kind].list = list
		CrossPartyBO.rankInfo_[kind].myRank = PbProtocol.decodeRecord(data.mySelf)
		rhand(data.myJiFen)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCPRank",{type=kind,page=page}), 1)
end

--领取排行奖励
function CrossPartyBO.getRank(kind,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		local add = 0
		for k,v in pairs(awards) do
			if v.type == ITEM_KIND_CROSSSCORE then
				add = v.count
			end
		end
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret, true)
		CrossPartyBO.rankInfo_[kind].myRank.rewardState = 3
		rhand(add)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ReceiveCPReward",{type=kind}), 1)
end

--跨服名人堂
function CrossPartyBO.GetCrossRank(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		CrossPartyBO.backData_ = PbProtocol.decodeArray(data["crossFameInfo"])
		for k,v in ipairs(CrossPartyBO.backData_) do
			v.crossFame = PbProtocol.decodeArray(v.crossFame)
		end
		table.sort(CrossPartyBO.backData_,function(a,b)
				return a.keyId > b.keyId
			end)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetCrossRank"), 1)
end
