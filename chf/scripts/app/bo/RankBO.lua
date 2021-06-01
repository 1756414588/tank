
RankBO = {}

function RankBO.init()
	local function refresh()
		if UiDirector.hasUiByName("RankView") then return end

		RankMO.myRank_ = {}
		RankMO.ranks = {}
		RankMO.myRankFight_ = {}
	end

	if not RankMO.refreshHandler_ then
		RankMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 300)
	end
end

function RankBO.asynGetRank(doneCallback, rankType, page)
	local function parseGetRank(name, data)
		gdump(data, "RankBO.asynGetRank 111")
		local ranks = PbProtocol.decodeArray(data["rankData"])
		for index = 1, #ranks do
			if not RankMO.ranks[rankType] then RankMO.ranks[rankType] = {} end

			if index == 1 and page == 1 then RankMO.ranks[rankType] = {} end
			
			RankMO.ranks[rankType][#RankMO.ranks[rankType] + 1] = ranks[index]
		end
		-- gdump(RankMO.ranks[rankType], "RankBO.asynGetRank 222")

		if table.isexist(data, "rank") then  -- 玩家自己的排名
			gprint("RankBO.asynGetRank my rank:", data["rank"])
			RankMO.myRank_[rankType] = data["rank"]
		end

		if table.isexist(data, "maxFight") then  -- 玩家自己的排名数值
			gprint("RankBO.asynGetRank my maxFight:", data["maxFight"])
			RankMO.myRankFight_[rankType] = data["maxFight"]
		end

		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetRank, NetRequest.new("GetRank", {type = rankType, page = page}))
end
