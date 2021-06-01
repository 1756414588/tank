--
-- Author: Xiaohang
-- Date: 2016-09-07 17:00:36
--

RebelBO = {}

--获取数据
function RebelBO.getInfo(rhand)
	-- if true then
	-- 	RebelBO.data = {}
	-- 	RebelBO.data.state = 0;   			
	-- 	RebelBO.data.changeTime = ManagerTimer.getTime() + 10	
	-- 	RebelBO.data.killNum = 3;			
	-- 	RebelBO.data.restUnit = 1;			
	-- 	RebelBO.data.restGuard = 2;			
	-- 	RebelBO.data.restLeader = 3
	-- 	-- required int32 rebelId = 1;			// 叛军id
	-- 	-- required int32 rebelLv = 2;			// 叛军的等级
	-- 	-- required int32 state = 3;			// 叛军状态，0 已击杀，1 未击杀，2 已逃跑
	-- 	-- required int32 type = 4;			// 叛军类型，1 分队，2 卫队，3 领袖
	-- 	-- optional int32 pos = 5;				// 坐标
	-- 	RebelBO.data.unitRebels = {{rebelId=1,heroPick=101,rebelLv=40,state=1,type=1,pos=5260}}		
	-- 	RebelBO.data.guardRebels = {{rebelId=37,heroPick=201,rebelLv=50,state=0,type=0,pos=512}}		
	-- 	RebelBO.data.leaderRebels = {{rebelId=55,heroPick=202,rebelLv=60,state=2,type=1,pos=878}}		
	-- 	rhand()
	-- 	return
	-- end
	Loading.getInstance():show()
	local function getResult(name,data)
 --    required int32 state = 1;   			// 活动状态，0 未开启或已结束，1 已刷新
 --    required int32 changeTime = 2;  		// 下次状态改变剩余时间，单位：s
	-- required int32 killNum = 3;				// 今日击杀叛军数量
	-- required int32 restUnit = 4;			// 剩余分队数量
	-- required int32 restGuard = 5;			// 剩余卫队数量
	-- required int32 restLeader = 6;			// 剩余领袖数量
	-- repeated Rebel unitRebels = 7;			// 分队叛军的数据
	-- repeated Rebel guardRebels = 8;			// 卫队叛军的数据
	-- repeated Rebel leaderRebels = 9;		// 领袖叛军的数据
		Loading.getInstance():unshow()
		RebelBO.data = data
		RebelBO.data.unitRebels = PbProtocol.decodeArray(data.unitRebels)
		RebelBO.data.guardRebels = PbProtocol.decodeArray(data.guardRebels)
		RebelBO.data.leaderRebels = PbProtocol.decodeArray(data.leaderRebels)
		RebelBO.data.bossRebels = PbProtocol.decodeArray(data.bossRebels)
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetRebelData"))
end

--排行榜数据
function RebelBO.getRank(kind,page,rhand)
	-- if true then
	-- 	RebelBO.rankData = {}
	--     RebelBO.rankData.killUnit = 1;   			-- 玩家击杀分队数量
	--     RebelBO.rankData.killGuard = 2;  			-- 玩家击杀卫队数量
	-- 	RebelBO.rankData.killLeader = 3;			-- 玩家击杀领袖数量
	-- 	RebelBO.rankData.score = 4;				-- 玩家的积分
	-- 	RebelBO.rankData.rank = 5;				-- 玩家积分排行，0为未上榜
	-- 	RebelBO.rankData.getReward = false		-- 是否已领取奖励，只有玩家上榜，并在可领取奖励的排名内才有值
	-- 	RebelBO.rankData.lastRank = 7;			-- 上周排行
	-- 	RebelBO.rankData.rebelRanks = {{rank=1,name="开飞机",killUnit=3,killGuard=5,killLeader=2,score=10}}		-- 排行榜数据
	-- 	rhand()
	-- 	return
	-- end
	-- required int32 rankType = 1;            // 排行榜类型，1：个人周榜，2：个人总榜 ，3：军团周榜
 --    required int32 page = 2;                // 分页，每一页显示20个，第一页page=0，第二页page=1
	Loading.getInstance():show()
	local function getResult(name,data)
 --    required int32 killUnit = 1;   			// 玩家击杀分队数量
 --    required int32 killGuard = 2;  			// 玩家击杀卫队数量
	-- required int32 killLeader = 3;			// 玩家击杀领袖数量
	-- required int32 score = 4;				// 玩家的积分
	-- required int32 rank = 5;				// 玩家积分排行，0为未上榜
	-- optional bool getReward = 6;			// 是否已领取奖励，只有玩家上榜，并在可领取奖励的排名内才有值
	-- optional int32 lastRank = 7;			// 上周排行
	-- repeated RebelRank rebelRanks = 8;		// 排行榜数据
		Loading.getInstance():unshow()
		if kind <= 2 then
			RebelBO.rankData = data
			RebelBO.rankData.rebelRanks = PbProtocol.decodeArray(data.rebelRanks)
		else
			RebelBO.rankPartyBata = data
			RebelBO.rankPartyBata.rebelRanks = PbProtocol.decodeArray(data.rebelRanks)
		end
		
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetRebelRank",{rankType=kind,page=page}))
end

--领取奖励
function RebelBO.getRankAward(rhand, awardType)
	-- required int32 awardType = 1;	//奖励类型 1-周个人榜，3-周军团榜
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		if awardType == 1 then
			RebelBO.rankData.getReward = true
		else -- awardType == 2 then
			RebelBO.rankPartyBata.getReward = true
		end
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("RebelRankReward",{awardType = awardType}))
end

--检查将领死亡
function RebelBO.checkDead(pos,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand(data.isDead)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("RebelIsDead",{pos=pos}))
end

--检查剿匪
function RebelBO.checkActDead(pos,rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand(data.isDead)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("ActRebelIsDead",{pos=pos}))
end

-- 剿匪界面信息
function RebelBO.getActRebelRank(page,rhand)
	function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetActRebelRank",{page = page}),1)
end

-- 剿匪领奖
function RebelBO.actRebelRankReward(rhand)
	function parseResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ActRebelRankReward"),1)
end

-- 叛军领取礼盒奖励
function RebelBO.GetRebelBoxAward(rhand, pos)
	-- required int32 pos = 1;  //礼盒坐标
	function parseResult(name,data)
		Loading.getInstance():unshow()
		-- required int32 leftCount = 1; // 本次领取之前红包剩余个数  -2单个礼盒每人限领一次/-1超出每日领取次数/0已被领完/>0正常领
		-- optional Award award = 2;
		if data.leftCount > 0 then
			if table.isexist(data, "award") then
				local award = PbProtocol.decodeRecord(data["award"])
				local awards = {}
				awards[#awards + 1] = award
				local ret = CombatBO.addAwards(awards)
				UiUtil.showAwards(ret)
			end
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetRebelBoxAward",{pos = pos}),1)
end

-- 叛军抢红包
function RebelBO.GrabRebelRedBag(rhand, uid)
	-- required int32 uid = 1;  //红包唯一ID
	function parseResult(name,data)
		Loading.getInstance():unshow()
		-- optional int32 grabMoney = 1;      // >0抢红包金额, 小于等于零: 抢红包失败
  --   	optional ActRedBag redBag = 2;    //如果未抢到红包则显示红包详细信息

  		local state = false
		local out = {}
		if table.isexist(data, "grabMoney") then
			local grabMoney = data.grabMoney
			if grabMoney >= 0 then
				out.grabMoney = grabMoney
				local awards = {{type = ITEM_KIND_COIN, id = 0, count = grabMoney}}
				local statsAward = nil
				if awards then
					statsAward = CombatBO.addAwards(awards)
				end
				out.statsAward = statsAward
				state = true
			elseif grabMoney == -1 then
				Toast.show(CommonText[1860])
			elseif grabMoney == -3 then
				Toast.show(CommonText[1781])
			end
		end

		if table.isexist(data, "redBag") then
			out.redBag = PbProtocol.decodeRecord(data["redBag"])
		end

		rhand(out, state)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GrabRebelRedBag",{uid = uid}),1)
end

function RebelBO.parseSynRebelBoss(name, data)
	if not data then return end
	-- local state = data
	Notify.notify(LOCAL_REBEL_BOSS_UPDATA,{param = data.boosState})
end

function RebelBO.parseSynOnRebelBossDie(name, data)
	if not data then return end
	dump(value, desciption, nesting)
	local effects = PbProtocol.decodeRecord(data["effect"])
	EffectBO.updateEffect(effects)

	Notify.notify(LOCAL_EFFECT_EVENT)
end