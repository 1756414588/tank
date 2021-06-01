
local s_combat = require("app.data.s_combat")
local s_section = require("app.data.s_section")
local s_explore = require("app.data.s_explore")
local s_treasure_shop = require("app.data.s_treasure_shop")

local combat_view_ = {
[101] = {offset = {463, 149}},
[102] = {offset = {142, 221}},
[103] = {offset = {317, 327}},
[104] = {offset = {431, 513}},
[105] = {offset = {211, 663}},
[106] = {offset = {434, 730}},
[107] = {offset = {395, 909}},
[108] = {offset = {166, 1072}},
[109] = {offset = {384, 1228}},
[110] = {offset = {222, 1385}},
[111] = {offset = {434, 1532}},

[201] = {offset = {430, 113}},
[202] = {offset = {152, 205}},
[203] = {offset = {404, 309}},
[204] = {offset = {392, 514}},
[205] = {offset = {151, 661}},
[206] = {offset = {439, 752}},

[207] = {offset = {343, 923}},
[208] = {offset = {169, 1063}},
[209] = {offset = {467, 1189}},
[210] = {offset = {240, 1280}},
[211] = {offset = {161, 1502}},
[212] = {offset = {435, 1561}},

[213] = {offset = {430, 113}},
[214] = {offset = {152, 205}},
[215] = {offset = {404, 309}},
[216] = {offset = {392, 514}},
[217] = {offset = {151, 661}},
[218] = {offset = {439, 752}},
[219] = {offset = {343, 923}},
[220] = {offset = {169, 1063}},
[221] = {offset = {467, 1189}},
[222] = {offset = {240, 1280}},
[223] = {offset = {161, 1502}},
[224] = {offset = {435, 1561}},

[225] = {offset = {430, 113}},
[226] = {offset = {152, 205}},
[227] = {offset = {404, 309}},
[228] = {offset = {392, 514}},
[229] = {offset = {151, 661}},
[230] = {offset = {439, 752}},
[231] = {offset = {343, 923}},
[232] = {offset = {169, 1063}},
[233] = {offset = {467, 1189}},
[234] = {offset = {240, 1280}},
[235] = {offset = {161, 1502}},
[236] = {offset = {435, 1561}},
}

local limit_combat_view_ = {  -- 限时副本
[401] = {offset = {443, 199}},
[402] = {offset = {172, 331}},
[403] = {offset = {387, 497}},
[404] = {offset = {301, 733}},
}

CombatMO = {}

COMBAT_TYPE_COMBAT  = 1 -- 普通副本
COMBAT_TYPE_EXPLORE = 2 -- 探险副本
COMBAT_TYPE_ARENA   = 3 -- 竞技场
COMBAT_TYPE_PARTY_COMBAT  = 4 -- 军团副本
COMBAT_TYPE_REPLAY        = 5 -- 只用于回放(没有结算界面)
COMBAT_TYPE_GUIDE         = 6 -- 只用于引导
-- COMBAT_TYPE_REPLAY_EXTREME = 7 -- 只用于探险记事的回放(没有结算界面)
COMBAT_TYPE_BOSS = 7 -- 用于世界BOSS
COMBAT_TYPE_BOUNTY_BOSS = 8 -- 用于赏金猎人玩法

-- 探险副本类型
EXPLORE_TYPE_EQUIP   = 1 -- 装备副本
EXPLORE_TYPE_PART    = 2 -- 配件副本
EXPLORE_TYPE_EXTREME = 3 -- 极限副本
EXPLORE_TYPE_LIMIT   = 4 -- 限时副本章节id
EXPLORE_TYPE_WAR     = 5 -- 军工科技副本
EXPLORE_TYPE_FORTRESS     = 7 -- 要塞战
EXPLORE_TYPE_ENERGYSPAR     = 8 -- 能晶副本
EXPLORE_TYPE_MEDAL     = 9 -- 勋章副本
EXPLORE_TYPE_TACTIC    = 10 -- 战术副本

COMBAT_TAKE_POWER  = 1 -- 副本挑战消耗的能量数量

COMBAT_FIRST_ID = 101  -- 普通副本的第一关的关卡id

EXPLORE_FIGHT_TIME = 5 -- 探险副本可挑战次数
EXPLORE_RESET_BUY_TIME = 1 -- 探险副本重置最多可购买次数
EXPLORE_RESET_TAKE_COIN = {98, 148, 198, 248, 298, 298}    -- 充值花费金币
EXPLORE_ALTAR_RESET_TAKE_COIN = {80, 150, 290, 550}    -- 充值花费金币
EXPLORE_LIMIT_COIN = {10, 20, 50}    -- 限制副本购买

EXPLORE_EXTREME_FIGHT_TIME = 3 -- 极限副本可挑战次数
EXPLORE_EXTREME_RESET_TAKE_POWER = 5 -- 极限副本重置消耗能量

EXPLORE_EXTREME_WIPE_TIME = 30  -- 极限副本扫荡时一关消耗的时间

local db_treasure_shop = nil
local db_combat_ = nil
local db_section_ = nil
local db_combat_section_ = nil -- 关卡章节信息，只保存章节id和关卡的id信息

local db_explore_ = nil -- 探险的副本
local db_explore_section_ = nil -- 探险章节信息，只保存章节id和探险副本的id信息

local db_combat_section_max_ = 0 -- 副本关卡最大的章节数

CombatMO.currentCombatId_ = 0 -- 副本进度id
CombatMO.combats_ = {} -- 保存所有通关的关卡信息，以id为索引，保存星级等
CombatMO.sections_ = {}  -- 以sectionId为key，保存某个章节下所有的关卡

CombatMO.sectionBoxs_ = {}  -- 章节的宝箱领取状态

CombatMO.currentExplore_ = {} -- 当前探险副本的进度
CombatMO.explores_ = {}
CombatMO.exploreSections_ = {}
CombatMO.exploreExtremeHighest_ = 0 -- 极限副本历史最高层数

CombatMO.combatChallenge_ = {}  -- 记录副本已挑战次数, 用于探险副本
CombatMO.combatBuy_ = {}  -- 记录副本购买次数, 用于探险副本

CombatMO.extremeWipeTime_ = 0 -- 极限副本扫荡倒计时

CombatMO.curChoseBattleType_ = nil
CombatMO.curChoseBtttleId_ = nil
CombatMO.curSkipBattle_ = false -- 是否省流量不看战斗

----------------------------------------------------------
-- CombatMO保存的战斗信息，主要用于ui，并用于传递给战斗用，而不能参与到战斗中使用
----------------------------------------------------------
CombatMO.curBattleNeedShowBalance_ = nil -- 当前发生的战斗返回关卡页面是是否需要显示解析奖励的
CombatMO.curBattleCombatUpdate_ = nil -- 关卡数据有更新，1表示只是星级增加了，2表示开启了同一章节的下一关，3表示开启了新的章节的第一关，4表示开启了普通副本的第二章，0表示无
CombatMO.curBattleStar_ = 0 -- 当前发生的战斗的星级
-- CombatMO.curBattleExp_ = 0 -- 当前发生的战斗获得的EXP
-- CombatMO.curBattleLevelUp_ = false -- 当前战斗是否增加了玩家等级
CombatMO.curBattleAward_ = nil -- 战斗的奖励等信息统计
CombatMO.curBattleStatistics_ = {}  -- 当前战斗的统计。双方数量、损兵、暴击等等

CombatMO.curBattleOffensive_ = nil -- 当前发生的战斗的先手
CombatMO.curBattleAtkFormat_ = nil -- 进攻方的阵型
CombatMO.curBattleDefFormat_ = nil
CombatMO.curBattleFightData_ = nil
-- -- CombatMO.curBattleDefSeveralForOne_ = false -- true用于世界BOSS，表示对方阵型中多个Tank单元的数据代表一个Tank行为
----------------------------------------------------------

CombatMO.curWipeFormation_ = nil -- 保存进入扫荡前的原始阵型
-- CombatMO.deforeWipeTankNum_ = nil -- 保存在扫荡前相关tank的数量，以tankId，count为key value形式

CombatMO.tickTimer_ = nil

CombatMO.combatNeedFresh_ = true

CombatMO.myWipeInfo_ = {}   --获取的扫荡设置信息
CombatMO.selectCombatId = {}--选中要扫荡的关卡
CombatMO.wipeSetInfo = {}   --扫荡设置信息
CombatMO.wipeReward = {}    --一键奖励信息

function CombatMO.init()
	db_combat_ = {}
	db_combat_section_ = {}

	local records = DataBase.query(s_combat)
	for index = 1, #records do
		local data = records[index]
		db_combat_[data.combatId] = data

		-- 获得前一关卡的id
		if index == 1 then data.prevCombatId = 0
		else data.prevCombatId = records[index - 1].combatId end

		-- 获得后一关卡的id
		if index == #records then data.nxtCombatId = 0
		else data.nxtCombatId = records[index + 1].combatId end

		if not db_combat_section_[data.sectionId] then db_combat_section_[data.sectionId] = {} end
		db_combat_section_[data.sectionId][#db_combat_section_[data.sectionId] + 1] = data.combatId
	end

	db_combat_section_max_ = 0
	db_section_ = {}

	local records = DataBase.query(s_section)
	for index = 1, #records do
		local data = records[index]
		db_section_[data.sectionId] = data

		if data.type == COMBAT_TYPE_COMBAT then
			db_combat_section_max_ = db_combat_section_max_ + 1
		end
	end

	-- gprint("db_combat_section_max_db_combat_section_max_:", db_combat_section_max_)

	db_explore_ = {}
	db_explore_section_ = {}
	local records = DataBase.query(s_explore)
	for index = 1, #records do
		local data = records[index]
		db_explore_[data.exploreId] = data

		-- 获得前一关卡的id
		if index == 1 then
			data.prevCombatId = 0
		else
			if records[index - 1].type ~= data.type then data.prevCombatId = 0
			else data.prevCombatId = records[index - 1].exploreId end
		end

		if index == #records then
			data.nxtCombatId = 0
		else
			if records[index + 1].type ~= data.type then data.nxtCombatId = 0
			else data.nxtCombatId = records[index + 1].exploreId end
		end

		local sectionId = CombatMO.getExploreSectionIdByType(data.type)
		if not db_explore_section_[sectionId] then db_explore_section_[sectionId] = {} end
		db_explore_section_[sectionId][#db_explore_section_[sectionId] + 1] = data.exploreId
	end

	db_treasure_shop = {}
	local records = DataBase.query(s_treasure_shop)
	for index = 1, #records do
		local data = records[index]
		if not db_treasure_shop[data.openWeek%4] then
			db_treasure_shop[data.openWeek%4] = {}
		end
		table.insert(db_treasure_shop[data.openWeek%4],data)
	end
end

function CombatMO.getCombatById(combatType)
	return CombatMO.myWipeInfo_[combatType]
end

function CombatMO.queryCombatById(combatId)
	return db_combat_[combatId]
end

function CombatMO.queryShopByWeek(week)
	return db_treasure_shop[week%4]
end

-- function CombatMO.queryMaxSection()
-- 	return #db_section_
-- end

function CombatMO.querySectionById(sectionId)
	return db_section_[sectionId]
end

function CombatMO.queryCombatSectionMax()
	return db_combat_section_max_
end

function CombatMO.queryExploreById(exploreId)
	return db_explore_[exploreId]
end

function CombatMO.getCombatById(combatId)
	return CombatMO.combats_[combatId]
end

function CombatMO.getCombatViewById(combatType, combatId)
	if combatType == COMBAT_TYPE_COMBAT then
		local combatDB = CombatMO.queryCombatById(combatId)
		if combatDB.sectionId % 100 == 1 then
			return combat_view_[combatId]
		else
			local id = combatId - math.floor(combatId / 100) * 100 + 200
			return combat_view_[id]
		end
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local exploreDB = CombatMO.queryExploreById(combatId)
		if exploreDB.type == EXPLORE_TYPE_EXTREME then
			return nil -- 还没有处理
		elseif exploreDB.type == EXPLORE_TYPE_LIMIT then
			return limit_combat_view_[combatId]
		else
			local id = combatId - math.floor(combatId / 100) * 100 + 200
			return combat_view_[id]
		end
	end
end

function CombatMO.getCombatIdsBySectionId(sectionId)
	if sectionId < 200 then -- 普通副本
		return db_combat_section_[sectionId]  -- 获得某章sectionId拥有的所有关卡的id
	else
		return db_explore_section_[sectionId]  -- 获得探险某章sectionId拥有的所有关卡的id
	end
end

-- 获得章节的评星
function CombatMO.getSectionStar(starNum, totalNum)
	if starNum == 0 then return 0
	elseif starNum < 24 then return 1
	elseif starNum < totalNum then return 2
	else return 3 end
end

-- key: 编号1-12
function CombatMO.getBattlePosition(offensive, key)
	local pos = math.floor((key + 1) / 2)

	if offensive == BATTLE_OFFENSIVE_ATTACK then  -- 进攻方是先手
		if key % 2 == 1 then -- 进攻方
			return BATTLE_FOR_ATTACK, pos
		else
			return BATTLE_FOR_DEFEND, pos
		end
	else
		if key % 2 == 1 then -- 防守方
			return BATTLE_FOR_DEFEND, pos
		else
			return BATTLE_FOR_ATTACK, pos
		end
	end
end

function CombatMO.getExploreById(combatId)
	return CombatMO.explores_[combatId]
end

function CombatMO.getExploreSectionIdByType(type)
	if type == EXPLORE_TYPE_EQUIP then return 201
	elseif type == EXPLORE_TYPE_PART then return 301
	elseif type == EXPLORE_TYPE_EXTREME then return 401
	elseif type == EXPLORE_TYPE_LIMIT then return 501
	elseif type == EXPLORE_TYPE_WAR then return 601
	elseif type == EXPLORE_TYPE_FORTRESS then return 701
	elseif type == EXPLORE_TYPE_ENERGYSPAR then return 801
	elseif type == EXPLORE_TYPE_MEDAL then return 901
	elseif type == EXPLORE_TYPE_TACTIC then return 1001
	end
end

function CombatMO.getExploreTypeBySectionId(sectionId)
	if sectionId == 201 then return EXPLORE_TYPE_EQUIP
	elseif sectionId == 301 then return EXPLORE_TYPE_PART
	elseif sectionId == 401 then return EXPLORE_TYPE_EXTREME
	elseif sectionId == 501 then return EXPLORE_TYPE_LIMIT
	elseif sectionId == 601 then return EXPLORE_TYPE_WAR
	elseif sectionId == 801 then return EXPLORE_TYPE_ENERGYSPAR
	elseif sectionId == 901 then return EXPLORE_TYPE_MEDAL
	elseif sectionId == 1001 then return EXPLORE_TYPE_TACTIC
	end
end

function CombatMO.getCurrentExploreIdBySectionId(sectionId)
	local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)
	return CombatMO.currentExplore_[exploreType]
end

-- 获得极限探险副本的进度索引
function CombatMO.getExtremeProgressIndex(combatId)
	if CombatMO.exploreExtremeHighest_ == 0 then return 0 end

	local combatIds = CombatMO.getCombatIdsBySectionId(CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_EXTREME))
	for index = 1, #combatIds do
		if combatIds[index] == combatId then
			return index
		end
	end
	gprint("CombatMO.exploreExtremeHighest_:", CombatMO.exploreExtremeHighest_)
	return -1
end

-- -- 
-- function CombatMO.getExploreChallengeTime(exploreType)
-- end

-- -- 探险副本剩余挑战次数
-- function CombatMO.getExploreChallengeLeftTime(exploreType)
-- 	if exploreType == EXPLORE_TYPE_EXTREME then
-- 		return EXPLORE_EXTREME_FIGHT_TIME - CombatMO.combatChallenge_[exploreType].count
-- 	else
-- 		return (CombatMO.combatBuy_[exploreType].count + 1) * EXPLORE_FIGHT_TIME - CombatMO.combatChallenge_[exploreType].count
-- 	end
-- end

function CombatMO.getExploreExtremeWipeTime()
	return CombatMO.extremeWipeTime_
end

function CombatMO.getExploreOpenLv(exploreType)
	if exploreType == EXPLORE_TYPE_EQUIP then
		return 0
	elseif exploreType == EXPLORE_TYPE_PART then
		return 18
	elseif exploreType == EXPLORE_TYPE_EXTREME then
		return 35
	elseif exploreType == EXPLORE_TYPE_LIMIT then
		return 20
	elseif exploreType == EXPLORE_TYPE_WAR then
		return 30
	elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
		return ENERGYSPAR_OPEN_LEVEL
	elseif exploreType == EXPLORE_TYPE_MEDAL then
		return 70
	elseif exploreType == EXPLORE_TYPE_TACTIC then
		return 45
	end
end

function CombatMO.getCombatState(explorePass,index)
	local exploreType = explorePass[index]
	local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
	local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
	for k,v in pairs(combatIds) do
		local combat = CombatMO.getExploreById(v)
		if combat and combat.star == 3 then
			return true
		end
	end
	return false
end


function CombatMO.getLastFullStarCombatId(combatIds)
	local combatId = 0
	local tempCombatIds = clone(combatIds)
	table.sort(tempCombatIds,function(a,b)
			return a<b
	end)
	for k,v in pairs(tempCombatIds) do
		local combat = CombatMO.getExploreById(v)
		if combat and combat.star == 3 then
			combatId = v
		end
	end
	return combatId
end


function CombatMO.getNeedNum(exploreType)
	local needNum = 0
	if exploreType == EXPLORE_TYPE_EQUIP then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEquipCombatCount() then  -- 次数用完
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyEquipCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	elseif exploreType == EXPLORE_TYPE_PART then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyPartCombatCount() then
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyPartCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	elseif exploreType == EXPLORE_TYPE_WAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMilitaryCombatCount() then  -- 次数用完
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyMilitaryCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEnergySparCombatCount() then  -- 次数用完
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyEnergySparCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	elseif exploreType == EXPLORE_TYPE_MEDAL then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMedalSparCombatCount() then  -- 次数用完
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyMedalSparCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	elseif exploreType == EXPLORE_TYPE_TACTIC then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyTacticsCombatCount() then  -- 次数用完
			needNum = 0
			return needNum
		else
			needNum = VipBO.getBuyTacticsCombatCount() - CombatMO.combatBuy_[exploreType].count
		end
	end

	return needNum
end

function CombatMO.getNeedCoin(exploreType,num)
	local needCoin = 0
	if exploreType == EXPLORE_TYPE_EQUIP then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEquipCombatCount() then  -- 次数用完
			needCoin = 0
			return needCoin
		end
	elseif exploreType == EXPLORE_TYPE_PART then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyPartCombatCount() then
			needCoin = 0
			return needCoin
		end
	elseif exploreType == EXPLORE_TYPE_WAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMilitaryCombatCount() then  -- 次数用完
			needCoin = 0
			return needCoin
		end
	elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEnergySparCombatCount() then  -- 次数用完
			needCoin = 0
			return needCoin
		end
	elseif exploreType == EXPLORE_TYPE_MEDAL then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMedalSparCombatCount() then  -- 次数用完
			needCoin = 0
			return needCoin
		end
	elseif exploreType == EXPLORE_TYPE_TACTIC then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyTacticsCombatCount() then  -- 次数用完
			needCoin = 0
			return needCoin
		end
	end

	if num <=0 then
		needCoin = 0
	else
		for i=1,num do
			local coinNum = EXPLORE_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count + i] or EXPLORE_RESET_TAKE_COIN[#EXPLORE_RESET_TAKE_COIN]
			if exploreType == EXPLORE_TYPE_EQUIP and ActivityBO.isValid(ACTIVITY_ID_EQUIP_SUPPLY) then --装备探险 1
				coinNum = math.ceil(coinNum * ACTIVITY_EQUIP_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_PART and ActivityBO.isValid(ACTIVITY_ID_PART_SUPPLY) then -- 配件探险 2
				coinNum = math.ceil(coinNum * ACTIVITY_PART_SUPPLY_COIN_RATE)	--配件补给金币返还
			elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then	--能晶探险
				coinNum = EXPLORE_ALTAR_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count+i] or EXPLORE_ALTAR_RESET_TAKE_COIN[#EXPLORE_ALTAR_RESET_TAKE_COIN]--8
				if ActivityBO.isValid(ACTIVITY_ID_ENERGY_SUPPLY) then	-- 能晶补给
					coinNum = math.ceil(coinNum * ACTIVITY_ENERYG_SUPPLY_COIN_RATE)
				end
			elseif exploreType == EXPLORE_TYPE_WAR and ActivityBO.isValid(ACTIVITY_ID_MILITARY_SUPPLY) then	-- 军工探险 5
				coinNum = math.ceil(coinNum * ACTIVITY_MILITARY_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_MEDAL and ActivityBO.isValid(ACTIVITY_ID_MEDAL_SUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_MEDAL_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_TACTIC and ActivityBO.isValid(ACTIVITY_ID_TACTICS_SSUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_TACTIC_SUPPLY_COIN_RATE)
			end
			needCoin = needCoin + coinNum
		end
	end
	
	return needCoin
end

--获得所有探险副本是否还有可免费扫荡的次数
function CombatMO.hasAllFree()
	local hasFree = false
	local canWipe = true
	local isnewOpen = false --是否有新开的关卡
	local openExplore = {}

	local explores = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
	local info = clone(explores)

	for num=1,#explores do
		local state = CombatMO.getCombatState(info, num)
		if state then
			openExplore[#openExplore + 1] = num
			if CombatBO.getExploreChallengeLeftCount(explores[num]) > 0 then
				hasFree = true
			end
		end
	end

	local aa = clone(CombatMO.myWipeInfo_)
	for index=1,#aa do
		local data = aa[index]
		for idx=1,#explores do
			local time = CombatMO.getNeedNum(explores[idx])
			if explores[idx] == data.exploreType and time < data.buyCount then
				canWipe = false
				break
			end
		end
	end
	
	if table.nums(CombatMO.myWipeInfo_) < #openExplore then
		isnewOpen = true
	end

	return hasFree, canWipe , isnewOpen
end


---
function CombatMO.getUseCoin()
	local coinNum = 0
	for k,v in pairs(CombatMO.myWipeInfo_) do
		if v.buyCount >= CombatMO.getNeedNum(v.exploreType) then
			coinNum = coinNum+CombatMO.getNeedCoin(v.exploreType,CombatMO.getNeedNum(v.exploreType))
		else
			coinNum = coinNum+CombatMO.getNeedCoin(v.exploreType,v.buyCount)
		end
	end
	return coinNum
end