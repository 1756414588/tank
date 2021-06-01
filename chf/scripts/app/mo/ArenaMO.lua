
local s_arena_award = require("app.data.s_arena_award")

ArenaMO = {}

ARENA_FIGHT_TOTAL_TIME = 5  -- 竞技场总共可以挑战次数

ARENA_COLD_TAKE_TIME = 600 -- 十分钟

ArenaMO.arenaLeftCount_ = 0  -- 剩余挑战次数
ArenaMO.currentRank_    = 0 -- 当前排名
ArenaMO.lastRank_       = 0 -- 上次排名
ArenaMO.winStreak_      = 0 -- 连胜次数
ArenaMO.rivals_         = {}  -- 对手
ArenaMO.cdTime_         = 0  -- 战败时的，cd时间
ArenaMO.receiveAwards_  = false -- 是否领取过当日排名奖励
ArenaMO.champion_       = ""  -- 冠军名称
ArenaMO.fightValue_     = 0 -- 竞技场的战斗力
ArenaMO.buyCount_       = 0 -- 购买次数

ArenaMO.arenaScore_ = 0 -- 积分

ArenaMO.cdTimeHandler_ = nil

ArenaMO.firstEnter_ = false -- 判断竞技场是否是首次进入

function ArenaMO.getCdTime()
	if ArenaMO.cdTime_ <= 0 then return 0 end
	return ArenaMO.cdTime_
end

-- 购买挑战次数花费金币数量
function ArenaMO.getBuyTakeCoin()
	return 10 + ArenaMO.buyCount_ * 2
end

function ArenaMO.queryAllAwards()
	return DataBase.query(s_arena_award)
end

function ArenaMO.canReceiveAward()
	if ArenaMO.lastRank_ > 0 and ArenaMO.lastRank_ <= 500 and not ArenaMO.receiveAwards_ then return true
	else return false end
end
