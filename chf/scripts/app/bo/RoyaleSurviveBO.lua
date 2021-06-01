--
-- Author: heyunlong
-- Date: 2018-07-18 14:22
--

RoyaleSurviveBO = {}
RoyaleSurviveBO.individualData = nil
RoyaleSurviveBO.partyData = nil


function RoyaleSurviveBO.SynHonourSurviveOpen(name, data)
	-- 同步开始消息
	gdump(data, "SynHonourSurviveOpen recieve data==")
	if data.type == 1 then
		if UiDirector.hasUiByName("HomeView") then
			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new(CommonText[2105], function() end, cc.size(500, 300), cc.p(0, -40)):push()
		else
			RoyaleSurviveMO.tipOpenFlag = true
		end
		RoyaleSurviveMO.shrinkAllOver = false
		-- 记录总的阶段数
		Notify.notify(LOCAL_ROYALE_SURVIVE_OPEN)
	elseif data.type == 2 then
		RoyaleSurviveMO.safeAreaRightUpCorner = nil
		RoyaleSurviveMO.safeAreaLeftBottomCorner = nil
		RoyaleSurviveMO.nextSafeAreaRightUpCorner = nil
		RoyaleSurviveMO.nextSafeAreaLeftBottomCorner = nil

		local InfoDialog = require("app.dialog.InfoDialog")
		InfoDialog.new(CommonText[2109], function() end, cc.size(500, 300), cc.p(0, -40)):push()

		Notify.notify(LOCAL_ROYALE_SURVIVE_CLOSE)
		Notify.notify(LOCAL_UPDATE_SAFE_AREA)
	end
end

function RoyaleSurviveBO.SynUpdateSafeArea(name, data)
	-- 同步安全区范围
	gdump(data, "RoyaleSurviveBO.SynUpdateSafeArea==")
	local xbegin = data.xbegin
	local ybegin = data.ybegin
	local xend = data.xend
	local yend = data.yend

	local curPhase = data.phase
	-- if curPhase > RoyaleSurviveMO.totalPhase then
	-- 	curPhase = RoyaleSurviveMO.totalPhase
	-- end
	RoyaleSurviveMO.curPhase = curPhase
	RoyaleSurviveMO.safeAreaRightUpCorner = {x=xend, y=yend}
	RoyaleSurviveMO.safeAreaLeftBottomCorner = {x=xbegin, y=ybegin}

	Notify.notify(LOCAL_UPDATE_SAFE_AREA)
end

function RoyaleSurviveBO.SynNextSafeArea(name, data)
	-- 同步下个安全区范围
	gdump(data, "RoyaleSurviveBO.SynNextSafeArea==")
	local pos = data.pos
	local halfLen = data.length

	local y = math.floor(pos / WORLD_SIZE_WIDTH)
	local x = pos % WORLD_SIZE_WIDTH

	-- print("center x y", x, y)

	local xbegin = x - halfLen
	local xend = x + halfLen

	local ybegin = y - halfLen
	local yend = y + halfLen

	RoyaleSurviveMO.nextSafeAreaRightUpCorner = {x=xend, y=yend}
	RoyaleSurviveMO.nextSafeAreaLeftBottomCorner = {x=xbegin, y=ybegin}
	-- 下次缩圈时间

	local curPhase = data.phase
	RoyaleSurviveMO.shrinkAllOver = (curPhase == 1)
	Notify.notify(LOCAL_SAFE_AREA_SHRINK_OVER)
	RoyaleSurviveMO.shrinkStartTime = data.startTime
	RoyaleSurviveMO.shrinkEndTime = data.endTime

	Notify.notify(LOCAL_NEXT_SAFE_AREA)
end

--排行榜数据
function RoyaleSurviveBO.getRank(kind, rhand)
	Loading.getInstance():show()

	local function getResult(name,data)
		Loading.getInstance():unshow()
		if kind == 1 then
			RoyaleSurviveBO.individualData = {}
			RoyaleSurviveBO.individualData.rank = data.rank
			RoyaleSurviveBO.individualData.score = data.score
			RoyaleSurviveBO.individualData.rankList = PbProtocol.decodeArray(data.rankList)
			RoyaleSurviveBO.individualData.awardStatus = data.awardStatus
		elseif kind == 2 then
			RoyaleSurviveBO.partyData = {}
			RoyaleSurviveBO.partyData.rank = data.rank
			RoyaleSurviveBO.partyData.score = data.score
			if table.isexist(data, "partyName") then
				RoyaleSurviveBO.partyData.partyName = data.partyName
			end
			RoyaleSurviveBO.partyData.rankList = PbProtocol.decodeArray(data.rankList)
			RoyaleSurviveBO.partyData.awardStatus = data.awardStatus
		end

		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetHonourRank",{type=kind, }))
end

--领取奖励
function RoyaleSurviveBO.getRankAward(rhand, awardType)
	-- required int32 awardType = 1;	//奖励类型 1-个人榜，2-军团榜
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local awards = PbProtocol.decodeArray(data["award"])
		--加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		if awardType == 1 then
			RoyaleSurviveBO.individualData.awardStatus = 3
		elseif awardType == 2 then
			RoyaleSurviveBO.partyData.awardStatus = 3
		end
		rhand()
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetHonourRankAward",{awardType = awardType}))
end


function RoyaleSurviveBO.getCollectInfo(rhand, armyId)
	-- body
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		rhand(data.honourScore, data.honourGold)
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("HonourCollectInfo",{keyId = armyId}))
end


function RoyaleSurviveBO.getHonourStatus(rhand)
	-- body
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data, "RoyaleSurviveBO.getHonourStatus==")
		RoyaleSurviveMO.isActOver = (data.status == 1)
		if RoyaleSurviveMO.isActOver then -- 如果活动结束清掉数据
			RoyaleSurviveMO.safeAreaRightUpCorner = nil
			RoyaleSurviveMO.safeAreaLeftBottomCorner = nil
			RoyaleSurviveMO.nextSafeAreaRightUpCorner = nil
			RoyaleSurviveMO.nextSafeAreaLeftBottomCorner = nil
			Notify.notify(LOCAL_UPDATE_SAFE_AREA)
		end
		if rhand then rhand() end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetHonourStatus"))
end

--获取金币排行
function RoyaleSurviveBO.getHonourGoldInfo(rhand)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()

		if rhand then rhand(data) end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("HonourScoreGoldInfo"))
end

--金币排行领奖
function RoyaleSurviveBO.getHonourGoldAwards(rhand, awardId)
	Loading.getInstance():show()
	local function getResult(name,data)
		Loading.getInstance():unshow()

		local award = PbProtocol.decodeRecord(data["award"])
		--TK统计
		for index=1,#award do
			local data = award[index]
			if data.type == ITEM_KIND_COIN then
				TKGameBO.onReward(data.count, TKText[48])
			end
		end

		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end

		if rhand then rhand(true) end
	end
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetHonourScoreGold", {awardId = awardId}))
end