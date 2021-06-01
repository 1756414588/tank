
RANK_PAGE_NUM = 20 -- 每页显示的排行榜的数量

RankMO = {}

RankMO.myRank_ = {}

RankMO.ranks = {}

RankMO.myRankFight_ = {}

RankMO.refreshHandler_ = nil

function RankMO.getRanksByType(rankType)
	return RankMO.ranks[rankType]
end

function RankMO.getMyRankByType(rankType)
	return RankMO.myRank_[rankType]
end

function RankMO.getMyRankFightByType(rankType)
	return RankMO.myRankFight_[rankType]
end