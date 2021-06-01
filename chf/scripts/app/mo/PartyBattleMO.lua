--
-- Author: gf
-- Date: 2015-12-15 16:04:58
-- 百团混战



PartyBattleMO = {}

--军团战是否开启
PartyBattleMO.isOpen = false 
--百团混战状态 
PartyBattleMO.warState = 0

--百团大战报名时间
PARTY_BATTLE_TIME_DAY = {1,3,6}
PARTY_BATTLE_TIME_HOUR = 19
PARTY_BATTLE_TIME_MIN = {30,55}

-- PARTY_BATTLE_TIME_DAY = {5}
-- PARTY_BATTLE_TIME_HOUR = 18
-- PARTY_BATTLE_TIME_MIN = {30,40}

--军团战参加成员
PartyBattleMO.joinMember ={}
--军团战参加军团列表
PartyBattleMO.joinParty = {}
--军团战参加军团总数量
PartyBattleMO.joinPartyTotal = 0

--连胜排行
PartyBattleMO.rankWin = {}
PartyBattleMO.myRankWin = nil
PartyBattleMO.rankWinGet = false
--军团排行
PartyBattleMO.rankParty = {}
PartyBattleMO.myRankParty = nil

--军团战战况 全服 all 军团 party 个人 personal
PartyBattleMO.processList = {}

--当前报名百团混战的队伍
PartyBattleMO.myArmy = nil

--百团混战 战事福利
PartyBattleMO.battleAwards = {}

--百团混战推送战报缓存
PartyBattleMO.cacheBattleProcess = {}

PARTY_BATTLE_PROCESS_TYPE_ALL = 1
PARTY_BATTLE_PROCESS_TYPE_PARTY = 2
PARTY_BATTLE_PROCESS_TYPE_PERSONAL = 3


PARTY_BATTLE_STATE_SIGN = 1
PARTY_BATTLE_STATE_PRE = 2
PARTY_BATTLE_STATE_BEGIN = 3 --战斗开始
PARTY_BATTLE_STATE_END = 4 --战斗结束
PARTY_BATTLE_STATE_AWARD_END = 5 --团战结束
PARTY_BATTLE_STATE_CANCEL = 6 --战斗取消
--战况显示最多数量
PARTY_BATTLE_PROCESS_MAX = 20


local s_war_award = require("app.data.s_war_award")
local db_war_award_

function PartyBattleMO.init()
	PartyBattleMO.clearData()

	db_war_award_ = {}
	local records = DataBase.query(s_war_award)
	for index = 1, #records do
		local data = records[index]
		db_war_award_[data.rank] = data
	end
end

function PartyBattleMO.getAll(key)
	local list = {}
	for k,v in ipairs(db_war_award_) do
		if v[key] ~= nil then
			table.insert(list,json.decode(v[key]))
		end
	end
	return list
end

--军事演习阵营奖励
function PartyBattleMO.getCampReward()
	local list = {}
	local temp = json.decode(db_war_award_[1].drillPartWinAward)
	table.insert(temp,json.decode(db_war_award_[2].drillPartWinAward)[1])
	table.insert(list,temp)
	table.insert(list,json.decode(db_war_award_[1].drillPartFailAward))
	return list
end

function PartyBattleMO.getRankAward(type)
	local awards = {}
	if type == 1 then
		for index=1,#db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 3 then
				ret.rank = award.rank
				ret.awards = json.decode(award.winAwards) 
				awards[#awards + 1] = ret
			elseif award.rank == 5 then
				ret.rank = "4-5"
				ret.awards = json.decode(award.winAwards)
				awards[#awards + 1] = ret 
			elseif award.rank == 10 then
				ret.rank = "6-10"
				ret.awards = json.decode(award.winAwards) 
				awards[#awards + 1] = ret
			end
		end
	elseif type == 2 then
		for index=1,#db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 5 then
				ret.rank = award.rank
				ret.awards = json.decode(award.rankAwards) 
				awards[#awards + 1] = ret
			elseif award.rank == 10 then
				ret.rank = "6-10"
				ret.awards = json.decode(award.rankAwards) 
				awards[#awards + 1] = ret
			end
		end
	elseif type == 3 then  -- 伤害(世界BOSS)奖励
		for index = 1, #db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 5 then
				ret.rank = award.rank
				ret.awards = json.decode(award.hurtAwards) 
				awards[#awards + 1] = ret
			elseif award.rank == 10 then
				ret.rank = "6-10"
				ret.awards = json.decode(award.hurtAwards) 
				awards[#awards + 1] = ret
			end
		end
	elseif type == 4 then -- 军事矿区积分个人奖励
		for index = 1, #db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 3 then
				ret.rank = award.rank
				ret.awards = json.decode(award.scoreAwardsDesc) 
				awards[#awards + 1] = ret
			elseif award.rank == 5 then
				ret.rank = "4-5"
				ret.awards = json.decode(award.scoreAwardsDesc)
				awards[#awards + 1] = ret
			elseif award.rank == 10 then
				ret.rank = "6-10"
				ret.awards = json.decode(award.scoreAwardsDesc) 
				awards[#awards + 1] = ret
			end
		end
	elseif type == 5 then -- 军事矿区积分军团奖励
		for index = 1, #db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 3 then
				ret.rank = award.rank
				ret.awards = json.decode(award.scorePartyAwardsDesc) 
				awards[#awards + 1] = ret
			elseif award.rank == 5 then
				ret.rank = "4-5"
				ret.awards = json.decode(award.scorePartyAwardsDesc)
				awards[#awards + 1] = ret
			end
		end
	elseif type == 6 then -- 跨服军事矿区积分个人奖励
		for index = 1, #db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 3 then
				ret.rank = award.rank
				ret.awards = json.decode(award.serverMineRankAward) 
				awards[#awards + 1] = ret
			elseif award.rank == 5 then
				ret.rank = "4-5"
				ret.awards = json.decode(award.serverMineRankAward)
				awards[#awards + 1] = ret
			elseif award.rank == 10 then
				ret.rank = "6-10"
				ret.awards = json.decode(award.serverMineRankAward) 
				awards[#awards + 1] = ret
			elseif award.rank == 15 then
				ret.rank = "11-15"
				ret.awards = json.decode(award.serverMineRankAward) 
				awards[#awards + 1] = ret
			elseif award.rank == 20 then
				ret.rank = "16-20"
				ret.awards = json.decode(award.serverMineRankAward) 
				awards[#awards + 1] = ret
			end
		end
	elseif type == 7 then -- 跨服军事矿区积分服务器奖励
		for index = 1, #db_war_award_ do
			local award = db_war_award_[index]
			local ret = {}
			if award.rank >= 1 and award.rank <= 4 then
				ret.rank = award.rank
				ret.awards = json.decode(award.serverMinePartyRankAward) 
				awards[#awards + 1] = ret
			end
		end
	end

	return awards
end

function PartyBattleMO.clearData()
	--军团战参加成员
	PartyBattleMO.joinMember ={}
	--军团战参加军团列表
	PartyBattleMO.joinParty = {}
	--军团战参加军团总数量
	PartyBattleMO.joinPartyTotal = 0

	--连胜排行
	PartyBattleMO.rankWin = {}
	PartyBattleMO.myRankWin = nil
	PartyBattleMO.rankWinGet = false
	--军团排行
	PartyBattleMO.rankParty = {}
	PartyBattleMO.myRankParty = nil
	--军团战战况
	PartyBattleMO.processList = {}

	--当前报名百团混战的队伍
	PartyBattleMO.myArmy = nil

	--百团混战 战事福利
	PartyBattleMO.battleAwards = {}

	PartyBattleMO.cacheBattleProcess = {}

end