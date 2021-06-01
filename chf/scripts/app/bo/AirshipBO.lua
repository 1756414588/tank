--
-- Author: xiaoxing
-- Date: 2017-04-15 15:09:40
--

AirshipBO = {}

-- 获取所有飞艇
function AirshipBO.getAirship(rhand, airshipId)
	if not UserMO.queryFuncOpen(UFP_AIRSHIP) then return end 
	if AirshipBO.ships_ and not AirshipBO.needUpdate_  and not rhand then
		return
	end

	airshipId = airshipId or 0 ---0表示拉去所有飞艇信息

	if airshipId == 0  or not AirshipBO.ships_ then
		AirshipBO.ships_ = {}
	end

	AirshipBO.needUpdate_ = nil
	local function getResult(name,data)
		local info = PbProtocol.decodeArray(data.airship)
		for k,v in ipairs(info) do
			local airship = {}
			airship.base = PbProtocol.decodeRecord(v["base"])
			if table.isexist(v, "occupy") then
				airship.occupy = PbProtocol.decodeRecord(v["occupy"])
			end
			if table.isexist(v, "detail") then
				airship.detail = PbProtocol.decodeRecord(v["detail"])
			end

			-- dump(airship, "@^^^^^^^getAirship  ", 9)	
			AirshipBO.ships_[airship.base.id] = airship
		end

		Notify.notify(LOCAL_AIRSHIP_UPDATE_EVENT)

		if rhand then
			rhand()
		end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetAirship", {airshipId = airshipId}))
end

--创建攻打飞艇队伍(战事)
function AirshipBO.createAirshipTeam(id,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()

		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))

		local info = PbProtocol.decodeRecord(data.airshipTeam)
		AirshipBO.team_ = info
		AirshipBO.myArmy_ = nil
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("CreateAirshipTeam",{id = id}))
end

-- 撤销飞艇队伍(战事)
function AirshipBO.cancelTeam(rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		AirshipBO.team_ = nil
		AirshipBO.myArmy_ = nil
		Toast.show(CommonText[997][2])
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("CancelTeam"))
end

--获取成员战事队伍列表
--注:一个玩家同一时间只能对一个飞艇发起一个战事集结
function AirshipBO.getAirshipTeamList(rhand, isSelf)
	if isSelf == nil then
		isSelf = false
	end

	local function getResult(name,data)
		Loading.getInstance():unshow()

		AirshipBO.team_ = nil
		AirshipBO.myArmy_ = nil
		AirshipBO.memberTeams_ = nil
		
		local teams = PbProtocol.decodeArray(data.teams)
		if isSelf then
			AirshipBO.team_ = teams[1]

			if AirshipBO.team_ then
				AirshipBO.getAirshipTeamDetail(function (armys)
					AirshipBO.myArmy_ = armys

					if rhand then
						rhand()
					end
				end, AirshipBO.team_.airshipId)
			else
				if rhand then
					rhand()
				end				
			end
		else
			if rhand then
				AirshipBO.memberTeams_ = teams
				rhand()
			end
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetAirshipTeamList",{self = isSelf}))
end

--获取组队详情
----飞艇ID(一个工会同一时间对一个飞艇只能有一个队伍集结)
function AirshipBO.getAirshipTeamDetail(rhand, airshipId)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local armys = PbProtocol.decodeArray(data.armys)
		if rhand then
			rhand(armys, airshipId)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetAirshipTeamDetail", {airshipId = airshipId}))
end

-- 设置 飞艇 部队进攻阵形 设置攻打飞艇部队
-- function AirshipBO.setAirshipForm(form,fight)
function AirshipBO.JoinAirshipTeam(form,teamLeader,airshipId)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		-- 减少坦克
		local stastFormat = TankBO.stasticsFormation(form)
		local res = {}
		for tankId, count in pairs(stastFormat.tank) do
			res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
		end
		UserMO.reduceResources(res)
		local army = PbProtocol.decodeRecord(data.army)
		ArmyBO.updateArmy(army)
		ArmyMO.dirtyArmyData_ = false
		Toast.show(CommonText[382][1])
		Notify.notify(LOCAL_ARMY_EVENT, {force = true})  -- 强制显示第二页
	end
	Loading.getInstance():show()
	local format = CombatBO.encodeFormation(form)
	SocketWrapper.wrapSend(getResult, NetRequest.new("JoinAirshipTeam",{teamLeader = teamLeader, airshipId = airshipId, form = format}))
end

--消息战况推送
function AirshipBO.updateTeamArmy(name, data)
	ArmyBO.asynGetArmy(function() 
		-- TankBO.asynGetTank()
		TankBO.asynDelayGetTank(3)
	end)
	Notify.notify(LOCAL_GET_MAP_EVENT)
end


-- 设置攻击顺序-我的战事入口
function AirshipBO.setPlayerAttackSeq(lordId, keyId, step, isGuard, id, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("SetPlayerAttackSeq",{lordId=lordId, armyKeyId=keyId, step=step, isGuard = isGuard, guardAishipId = id}))	
end

-- 对飞艇发起战事 立即行军
function AirshipBO.startAirshipTeamMarch(rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("StartAirshipTeamMarch"))	
end

-- 设置 驻防飞艇
function AirshipBO.guardAirship(airshipId, form, fight)
	fight = fight or 0

	local function getResult(name,data)
		Loading.getInstance():unshow()
		AirshipBO.defendId = nil
		-- 减少坦克
		local stastFormat = TankBO.stasticsFormation(form)
		local res = {}
		for tankId, count in pairs(stastFormat.tank) do
			res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
		end
		UserMO.reduceResources(res)
		local army = PbProtocol.decodeRecord(data.army)
		ArmyBO.updateArmy(army)
		ArmyMO.dirtyArmyData_ = false
		UiDirector.pop()
		require("app.view.ArmyView").new(nil ,2):push()

		Notify.notify(LOCAL_AIRSHIP_TEAM_GUARD_EVENT)
	end
	Loading.getInstance():show()
	local format = CombatBO.encodeFormation(form)
	SocketWrapper.wrapSend(getResult, NetRequest.new("GuardAirship",{id = airshipId, form = format, fight = fight}))
end

-- 查看驻防部队信息
function AirshipBO.getAirshipGuard(id,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		dump(data, "@^^^^^^^^getAirshipGuard^^^^^^^")
		local team = PbProtocol.decodeArray(data.armys)
		rhand(team)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetAirshipGuard",{id= id}))	
end

-- 侦查飞艇
function AirshipBO.scoutAirship(rhand, id)
	local function getResult(name,data)
		Loading.getInstance():unshow()

		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))

		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("ScoutAirship",{id = id}))	
end

-- 领取飞艇自产奖励
-- id:飞艇ID
-- pid: 强征道具
function AirshipBO.asynLevyAirshipProduce(rhand,id,useProp)
	-- pid = pid or 0
	if useProp == nil then
		useProp = false
	end
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local info = AirshipBO.ships_[id]
		if info.detail then
			info.detail.produceNum = data.produceNum
			info.detail.produceTime = data.produceTime
		end

		if table.isexist(data, "atom2") then
			UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		end

		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		Notify.notify(LOCAL_GET_MAP_EVENT)

		if rhand then
			rhand()
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("RecvAirshipProduceAward",{id = id, useProp = useProp}))	
end

--获取军团中所有飞艇指挥官信息
function AirshipBO.GetPartyAirshipCommander(rhand)
	local function getResult(name,data)
		-- Loading.getInstance():unshow()
		local outdata = PbProtocol.decodeArray(data["kv"])
		rhand(outdata)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetPartyAirshipCommander"))
end

--任命飞艇指挥官
function AirshipBO.AppointAirshipCommander(airshipid,lordId,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("AppointAirshipCommander",{airship_id = airshipid, lordId = lordId}))
end

---同步飞艇变化
function AirshipBO.parseSynAirShipChanged( name, data )
	-- local airshipId = data.airshipId
	AirshipBO.needUpdate_ = true
	AirshipBO.getAirship(function ()
		Notify.notify(LOCAL_GET_MAP_EVENT)
	end)
end

-----队伍ID也就是飞艇ID
function AirshipBO.parseSynAirShipTeamChanged( name, data )
	dump(data, "AirshipBO.parseSynAirShipTeamChanged", 9)
	local airshipId = data.airshipId
	local status = data.status  -----//队伍状态(1-创建,2-变化,3-删除)
	AirshipBO.team_ = nil
	Notify.notify(LOCAL_AIRSHIP_TEAM_UPDATE_EVENT, {airshipId=airshipId,status=status})
end

-----重建飞艇
function AirshipBO.asynRebuildAirship( rhand, airshipId )
	local function parse( name,data )
		Loading.getInstance():unshow()
		-- dump(data, "@#########AirshipBO.asynRebuildAirship######")
		local id = data.airshipId
		local info = AirshipBO.ships_[id]
		if info and info.detail then
			info.detail.durability = data.durability
		end

		UserMO.updateResources(PbProtocol.decodeArray(data.atom))

		if rhand then
			rhand()
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("RebuildAirship",{airshipId = airshipId}))
end

----//根据飞艇ID获取飞艇信息
function AirshipBO.asynGetAirshipPlayer( rhand, airshipId )
	local function parse( name, data )
		Loading.getInstance():unshow()
		gdump(data, "@^^^^asynGetAirshipPlayer^^^")
		if rhand then
			rhand(data)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetAirshipPlayer",{airshipId = airshipId}))
end

function AirshipBO.parseArmy(army)
	local armyData = {}

	local form = PbProtocol.decodeRecord(army["form"])
	local formation = CombatBO.parseServerFormation(form)

	local collect = nil
	if table.isexist(army, "collect") then
		local clt = PbProtocol.decodeRecord(army["collect"])
		gdump(clt, "ArmyBO.updateArmy collect")
		collect = {load = clt.load, speed = clt.speed}
	end

	local staffingTime = 0
	if table.isexist(army, "staffingTime") then staffingTime = army["staffingTime"] + 0.99 end

	local isMilitary = false  -- 是否是军事矿区
	if table.isexist(army, "senior") then isMilitary = army["senior"] end

	local isRuins = false --是否是废墟
	if table.isexist(army, "isRuins") then isRuins = army["isRuins"] end

	if army.state == ARMY_STATE_PARTYB then
		armyData = {keyId = army.keyId, target = army.target, state = army.state, period = army.period, formation = formation, grab = army.grab, collect = collect, isMilitary = isMilitary, staffingTime = staffingTime, isRuins = isRuins}
	else
		armyData = {keyId = army.keyId, tar_qua = table.isexist(army, "tar_qua") and army.tar_qua, target = army.target, state = army.state, period = army.period, formation = formation, grab = army.grab, collect = collect, isMilitary = isMilitary, staffingTime = staffingTime, isRuins = isRuins}
	end

	return armyData
end

----//查看飞艇进攻部队信息
function AirshipBO.asynGetAirshpTeamArmy( rhand, airshipId, lordId, armyKeyId )
	local function parse( name, data )
		Loading.getInstance():unshow()
		gdump(data, "@^^^^asynGetAirshpTeamArmy^^^")
		local armyData = PbProtocol.decodeRecord(data.army)
		local army = AirshipBO.parseArmy(armyData)
		if rhand then
			rhand(army)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetAirshpTeamArmy",{airshipId = airshipId,lordId=lordId,armyKeyId=armyKeyId}))
end

----//查看飞艇驻军部队信息
function AirshipBO.asynGetAirshipGuardArmy( rhand, airshipId, lordId, armyKeyId )
	local function parse( name, data )
		Loading.getInstance():unshow()
		gdump(data, "@^^^^asynGetAirshipGuardArmy^^^")
		local armyData = PbProtocol.decodeRecord(data.army)
		local army = AirshipBO.parseArmy(armyData)
		if rhand then
			rhand(army)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetAirshipGuardArmy",{airshipId = airshipId,lordId=lordId,keyId=armyKeyId}))
end

--//获取飞艇征收详情
function AirshipBO.GetRecvAirshipProduceAwardRecord(rhand , airshipId)
	local function parse( name, data )
		Loading.getInstance():unshow()
		local pProduce = PbProtocol.decodeArray(data["records"])
		rhand(pProduce)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("GetRecvAirshipProduceAwardRecord",{airshipId = airshipId}))
end