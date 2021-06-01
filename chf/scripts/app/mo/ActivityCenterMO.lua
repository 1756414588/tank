--
-- Author: gf
-- Date: 2015-10-29 10:15:55
-- 活动中心

ActivityCenterMO = {}

ACTIVITY_CENTER_TYPE_NOMAL = 1  --普通
ACTIVITY_CENTER_TYPE_LIMIT = 2 	--限时
ACTIVITY_CENTER_TYPE_CROSS = 3 	--跨服

--活动ID
ACTIVITY_ID_MECHA			= 101 --机甲洪流
ACTIVITY_ID_BEE				= 102 --勤劳致富
ACTIVITY_ID_AMY_REBATE 		= 103 --建军返利
ACTIVITY_ID_FORTUNE 		= 104 --极限单兵
ACTIVITY_ID_PROFOTO 		= 105 --哈洛克宝藏
ACTIVITY_ID_PARTDIAL 		= 106 --配件转盘
ACTIVITY_ID_TANKRAFFLE		= 107 --坦克拉霸
ACTIVITY_ID_TANKDESTROY		= 108 --疯狂歼灭
ACTIVITY_ID_GENERAL			= 109 --名将招募
ACTIVITY_ID_TECH 			= 110 --技术革新
ACTIVITY_ID_CONSUMEDIAL		= 111 --消费转盘
ACTIVITY_ID_VACATION 		= 112 --度假胜地
ACTIVITY_ID_EXCHANGE_EQUIP	= 113 --限时兑换（装备）
ACTIVITY_ID_EXCHANGE_PART	= 114 --限时兑换（配件）
ACTIVITY_ID_PART_RESOLVE	= 115 --分解兑换
ACTIVITY_ID_GAMBLE			= 116 --下注赢金币
ACTIVITY_ID_PAYTURNTABLE	= 117 --充值转盘
ACTIVITY_ID_CELEBRATE		= 118 --节日欢庆
ACTIVITY_ID_TANKRAFFLE_NEW	= 119 --新坦克拉霸
ACTIVITY_ID_TANK_CARNIVAL	= 120 --坦克嘉年华
ACTIVITY_ID_COLLECRION      = 121 --集字活动
ACTIVITY_ID_M1A2            = 122 --M1A2
ACTIVITY_ID_FLOWER          = 123 --鲜花活动
ACTIVITY_ID_RECHARGE        = 124 --充值返利
ACTIVITY_ID_STOREHOUSE      = 125 --海贼宝藏
ACTIVITY_ID_GENERAL1        = 126 --神将降临
ACTIVITY_ID_BEE_NEW			= 128 --勤劳致富新
ACTIVITY_ID_ENERGYSPAR		= 129 --能晶转盘
ACTIVITY_ID_NEWYEAR  		= 130 --新年boss召唤
ACTIVITY_ID_FESTIVAL  		= 131 --节日狂欢
ACTIVITY_ID_CLEAR  		    = 132 --清盘计划
ACTIVITY_ID_WORSHIP			= 133 --拜神许愿
ACTIVITY_ID_OPENSERVER      = 134 --开服狂欢
ACTIVITY_ID_BANDITS			= 136 --剿匪行动
ACTIVITY_ID_SCHOOL			= 137 --西点军校
ACTIVITY_ID_REFINE_MASTER   = 139 --淬炼大师活动
ACTIVITY_ID_NEWENERGY		= 140 --能量灌注
ACTIVITY_ID_OWNGIFT			= 141 --自选豪礼
ACTIVITY_ID_BROTHER			= 142 --兄弟同心
ACTIVITY_ID_HYPERSPACE      = 143 --超时空财团
ACTIVITY_ID_MEDAL 			= 144 -- 荣誉勋章
ACTIVITY_ID_MONOPOLY		= 145 -- 大富翁
ACTIVITY_ID_REDPACKET		= 146 -- 红包活动
ACTIVITY_ID_RED_SCHEME      = 147 --红色方案
ACTIVITY_ID_FRAG_EXCHANGE   = 148 --碎片兑换
ACTIVITY_ID_LUCKYROUND		= 149 --幸运奖池
ACTIVITY_ID_TANKEXCHANGE	= 150 --坦克转换
ACTIVITY_ID_EXCHANGE_PAPER  = 151 --图纸兑换
ACTIVITY_ID_EQUIPDIAL		= 152 -- 装备转盘
ACTIVITY_ID_MEDAL_RESOLVE	= 153 -- 勋章分解
ACTIVITY_ID_QUESTION_ANSWER	= 154 -- 有奖问答
ACTIVITY_ID_SECRETARMY		= 155 -- 神秘部队
ACTIVITY_ID_PARTY_PAY		= 156 -- 军团充值
ACTIVITY_ID_ACTIVITY_KING   = 157 -- 最强王者
ACTIVITY_ID_TACTICSPAR      = 158 -- 战术转盘

ACTIVITY_ID_BOSS		    = 1000 --世界BOSS
ACTIVITY_ID_MILITARY_AREA   = 1001  -- 军事矿区
ACTIVITY_ARMY_WAR    		= 1002  -- 军团要塞
ACTIVITY_WAR_EXERCISE    	= 1003  -- 军事演习
ACTIVITY_REBEL_COME     	= 1004  -- 叛军入侵
ACTIVITY_ROYALE_SURVIVE 	= 1005  -- 荣耀生存

--跨服战
ACTIVITY_CROSS_WORLD        = 1     --世界争霸
ACTIVITY_CROSS_PARTY        = 2     --军团争霸
ACTIVITY_CROSS_EXERCISE     = 3     --演习争霸
ACTIVITY_CROSS_FORTRESS     = 4     --要塞争霸

-----------------------------------------------------------
ACTIVITY_BOSS_OPEN_LEVEL = 30 -- 世界BOSS开启等级

ACTIVITY_BOSS_TOTAL_LIFE = 6

ACTIVITY_BOSS_BLESS_MAX_LV = 10

-- 世界BOSS活动状态
ACTIVITY_BOSS_STATE_CLOSE = 0
ACTIVITY_BOSS_STATE_READY = 1
ACTIVITY_BOSS_STATE_FIGHTING = 2
ACTIVITY_BOSS_STATE_DIE = 3
ACTIVITY_BOSS_STATE_OVER = 4

ACTIVITY_BOSS_AUTO_FIGHT_VIP = 6 -- VIP自动战斗开启VIP等级

ACTIVITY_BOSS_OPEN_DAY = {5}  -- 活动开启日期
ACTIVITY_BOSS_READY_HOUR_S = 20  -- 准备开始小时
ACTIVITY_BOSS_READY_MIN_S = 50 -- 准备开始分钟
ACTIVITY_BOSS_READY_HOUR_E = 21
ACTIVITY_BOSS_READY_MIN_E = 0  -- 准备结束分钟(不含)

ACTIVITY_BOSS_FIGHTING_HOUR_E = 21  -- 战斗结束小时
ACTIVITY_BOSS_FIGHTING_MIN_E = 30 -- 战斗结束分钟

ACTIVITY_BOSS_COLD_CD = 60 -- 冷却时间秒数

-----------------------------------------------------------
ACTIVITY_MILITARY_AREA_OPNE_LV = 60  -- 军师矿区开启等级

-----------------------------------------------------------
-- 活动总的列表信息
ActivityCenterMO.activityList_ = {}


ActivityCenterMO.activityLimitList_ = {
	{activityId = ACTIVITY_ID_BOSS,name = CommonText[10008]},
	{activityId = ACTIVITY_ARMY_WAR,name = CommonText[20005]},
	{activityId = ACTIVITY_WAR_EXERCISE,name = CommonText[10059][2]},
	{activityId = ACTIVITY_REBEL_COME,name = CommonText[20114]},
	{activityId = ACTIVITY_ROYALE_SURVIVE, name = CommonText[2100]},
}

ActivityCenterMO.activityCrossList_ = {
	{activityId = ACTIVITY_CROSS_WORLD,name = CommonText[30054] .."-"..CommonText[20148][1]},
	{activityId = ACTIVITY_CROSS_PARTY,name = CommonText[30054] .."-"..CommonText[20148][2]},
	{activityId = ACTIVITY_CROSS_EXERCISE,name = CommonText[30054] .."-"..CommonText[20148][3]},
	{activityId = ACTIVITY_CROSS_FORTRESS,name = CommonText[30054] .."-"..CommonText[20148][4]},
}

-- 每个活动的内容
ActivityCenterMO.activityContents_ = {}

ActivityCenterMO.showTip = nil
ActivityCenterMO.refineMasterChat_ = nil  --淬炼大师获奖推送信息


ActivityCenterMO.dayPayData = {}

ActivityCenterMO.tickHandler_ = nil

ActivityCenterMO.isBossOpen_ = false -- 世界BOSS功能是否开启
-- ActivityCenterMO.bossActivityState_ = 0 -- 客户端自己用于比较的活动状态
ActivityCenterMO.boss_ = {}  -- 世界BOSS
ActivityCenterMO.bossBalance_ = {} -- 世界BOSS结算显示的额外数据
ActivityCenterMO.beforeBattleWhich_ = 0

ActivityCenterMO.worshipRecord = {}

ActivityCenterMO.actLocalRecord = nil 	-- 用于活动的本地存储
ActivityCenterMO.actLocalRecord2 = nil

--能量灌注==============================================
ActivityCenterMO.ActivityEnergyOfdata = {day = 0, updateui = false}
--兄弟同心==============================================
ActivityCenterMO.ActivityBrotherListener = nil
ActivityCenterMO.ActivityBrotherList = {}
ActivityCenterMO.ActivityBroFightLitener = nil
--勋章活跃性活动（荣誉勋章）==============================================
ActivityCenterMO.ActivityMedalInfo = {three = false, ten = false, pass = false, price = 0}
--红包活动==============================================
ActivityCenterMO.ActivityRedPacketInfo = {} 	-- 收到的红包信息
ActivityCenterMO.ActivityRedPacketList = {}		-- 身上的红包
ActivityCenterMO.ActivityRedPacketWorldChat = {}	-- 
ActivityCenterMO.ActivityRedPacketPartyChat = {}	--
ActivityCenterMO.ActivityRedPacketListener = nil

ActivityCenterMO.dayLotteryCount = 0
ActivityCenterMO.dailyTargetStates = {}
ActivityCenterMO.dayEnergyCount = 0
ActivityCenterMO.dailyTargetEnergyStates = {}
ActivityCenterMO.dayEquipCount = 0
ActivityCenterMO.dailyTargetEquipStates = {}
ActivityCenterMO.dayTacticCount = 0
ActivityCenterMO.dailyTargetTacticStates = {}
--机甲猛兽================BEGIN=========================
--合成机甲需要碎片数量
ACTIVITY_MECHA_MERGE_COUNT = 20
--机甲猛兽================END===========================

--哈洛克宝藏================BEGIN=========================
--无信物时开宝藏需要金币
PROFOTO_UNFOLD_COIN = 50
--信物
PROFOTO_PROP_TRUST_ID = 129
--宝图
PROFOTO_PROP_PROFOTO_ID = 124
--庆字
COLLECTION_PROP_COLLECTION_ID = 125

--哈洛克宝藏================END===========================

--坦克拉霸================BEGIN=========================
--拉取需要金币
RAFFLE_NEED_COIN = 35
RAFFLE_NEED_COIN_10 = 315
ActivityCenterMO.raffleColors = nil
--坦克拉霸================END===========================
CARNIVAL_NEED_COIN = 40
CARNIVAL_NEED_COIN_ALL = 288
--疯狂歼灭================BEGIN=========================

ACTIVITY_DESTORY_TANK_RES = {
	"image/item/r_tank_fire.jpg",
	"image/item/r_char_fire.jpg",
	"image/item/r_arti_fire.jpg",
	"image/item/r_rocket_fire.jpg",
	"image/item/fame.jpg"
}
--疯狂歼灭================END===========================

--节日欢庆===============START======================
--祈福时间倒计时
ActivityCenterMO.runPrayTickList = {}
ACTIVITY_PRAY_AWARD_NORMAL = 1
ACTIVITY_PRAY_AWARD_GOLD = 2

--节日欢庆===============END======================


--新坦克拉霸================BEGIN=========================
--拉取需要金币
NEW_RAFFLE_NEED_COIN = 80
NEW_RAFFLE_NEED_COIN_10 = 720

NEW_RAFFLE_LOCK_NEED_COIN = 106
NEW_RAFFLE_LOCK_NEED_COIN_10 = 950

ActivityCenterMO.newRaffleColors = nil
-- 上次抽取到的tankId
ActivityCenterMO.newRaffleResultTankId = nil


-- ActivityCenterMO.lockTankId = 0
-- NEW_RAFFLE_TANK_ID = {25,26,29,30}

--新坦克拉霸================END===========================

--M1A2================START===========================
M1A2_LOTTERY_TYPE_NORMAL = 1
M1A2_LOTTERY_TYPE_SENIOR = 2
--M1A2================END===========================
--=======集字活动===================================
-- ActivityCenterMO.exchangeData_ = {} --活动兑换物品
--=======集字活动end================================

--活动ID 103 节日返利 奖励ID
ACTIVITY_AMY_REBATE_AWARDID_ANDROID	= 103 --节日返利奖励ID 安卓
ACTIVITY_AMY_REBATE_AWARDID_IOS	= 10302 --节日返利奖励ID IOS
ACTIVITY_AMY_REBATE_AWARDID_IOS_NEW	= 13402 --节日返利2奖励ID IOS

--超时空财团刷新提示
ActivityCenterMO.HysperTip_ = true        --刷新购买物品
ActivityCenterMO.HysperExcTip_ = true     --刷新兑换物品
ActivityCenterMO.HysperExchange_ = true   --物品兑换

--红色方案
ActivityCenterMO.redPlanMapInfo_ = {}   --红色方案地图信息
ActivityCenterMO.redPlanFuelInfo = {}	--红色方案燃料信息

--节日碎片(148)
ActivityCenterMO.festivelInfo_ = {}

-- 幸运奖池
ActivityCenterMO.luckyroundInfo = {}

local s_act_rebate = require("app.data.s_act_rebate")
local s_act_fortune = require("app.data.s_act_fortune")
local s_act_rank = require("app.data.s_act_rank")
local s_act_raffle = require("app.data.s_act_raffle")
local s_act_equate = require("app.data.s_act_equate")
local s_anniversary_prop = require("app.data.s_anniversary_rule") --集字活动兑换表
local s_activity_m1a2 = require("app.data.s_activity_m1a2")
local s_activity_flower = require("app.data.s_activity_flower")
local s_act_rebate_ = require("app.data.s_act_rebate_turntable")
local s_act_change_ = require("app.data.s_activity_change")
local s_act_pirate_ = require("app.data.s_act_pirate")
local s_act_boss_ = require("app.data.s_act_boss")
local s_act_hilarity_pray_ = require("app.data.s_act_hilarity_pray")
local s_act_gamble_ = require("app.data.s_act_gamble")
local s_act_worship_ = require("app.data.s_act_worship_god")
local s_act_worship_task_ = require("app.data.s_act_worship_task")
local s_act_worship_god_data_ = require("app.data.s_act_worship_god_data")
local s_act_college_education = require("app.data.s_act_college_education")
local s_act_college_showgirlchat = require("app.data.s_act_college_showgirlchat")
local s_act_college_subject = require("app.data.s_act_college_subject")
local s_act_refinemaster = require("app.data.s_act_part_master_lottery")
local s_act_cumulativepay = require("app.data.s_act_cumulativepay")
local s_act_choosegift = require("app.data.s_act_choosegift")
local s_act_brother_buff = require("app.data.s_act_brother_buff")
local s_act_brother_task = require("app.data.s_act_brother_task")
local s_act_brother_radio = require("app.data.s_act_brother_radio")
local s_act_brother = require("app.data.s_act_brother")
local s_act_hyperspace = require("app.data.s_act_quinn")
local s_act_medalofhonor = require("app.data.s_act_medalofhonor")
local s_act_medalofhonor_explore = require("app.data.s_act_medalofhonor_explore")
local s_act_medalofhonor_rule = require("app.data.s_act_medalofhonor_rule")
local s_act_monopoly = require("app.data.s_act_monopoly")
local s_act_monopoly_evt = require("app.data.s_act_monopoly_evt")
local s_act_monopoly_evt_buy = require("app.data.s_act_monopoly_evt_buy")
local s_act_monopoly_evt_dlg = require("app.data.s_act_monopoly_evt_dlg")
local s_act_red_bag = require("app.data.s_act_red_bag")
local s_act_red_scheme = require("app.data.s_redplan_area")
local s_act_red_talk = require("app.data.s_redplan_dialogue")
local s_act_redPlan_shop = require("app.data.s_redplan_shop")
local s_act_redPlan_point = require("app.data.s_redplan_point")
local s_act_redPlan_fuellimit = require("app.data.s_redplan_fuellimit")
local s_act_redplan_fuel = require("app.data.s_redplan_fuel")
local s_act_festival_piece = require("app.data.s_act_festival_piece")
local s_act_luky_draw = require("app.data.s_act_luky_draw")
local s_act_config = require("app.data.s_act_config")
local s_act_tanConvert = require("app.data.s_act_convert_tank")
local s_act_part_resolve = require("app.data.s_act_part_resolve")
local s_act_question_anwser = require("app.data.s_act_questionnaire")
local s_act_probability_show = require("app.data.s_activity_chance")


local s_act_king_rank = require("app.data.s_act_king_rank")
local s_act_king_award = require("app.data.s_act_king_award")
local s_act_king_ratio = require("app.data.s_act_king_ratio")

local db_ = {}
db_.act_king_rank_ = nil
db_.act_king_award_ = nil
db_.act_king_ratio_ = nil
db_.act_rebate_ = nil
db_.act_fortune_ = nil
db_.act_rank_ = nil
db_.act_raffle_ = nil
db_.act_equate_ = nil
db_.act_anniversary_ = nil
db_.act_m1a2_ = nil
db_.act_flower_ = nil
db_.act_rebate_turn_ = nil
db_.act_change_ = nil
db_.act_pirate_ = nil
db_.act_boss_ = nil
db_.act_hilarity_pray_ = nil
db_.act_gamble_ = nil
db_.act_worship_ = nil
db_.act_worship_task_ = nil
db_.act_worship_god_data_ = nil
db_.act_act_college_education_ = nil
db_.act_college_showgirlchat_ = nil
db_.act_college_subject_ = nil
db_.act_refinemaster_ = nil
db_.act_cumulativepay_ = nil
db_.act_choosegift_ = nil
db_.act_brother_buff_ = nil
db_.act_brother_task_ = nil
db_.act_brother_radio_ = nil
db_.act_brother_ = nil
db_.act_hyperspace_ = nil
db_.act_medalofhonor_ = nil
db_.act_medalofhonor_explore_ = nil
db_.act_medalofhonor_rule_ = nil
db_.act_monopoly_ = nil
db_.act_monopoly_evt_ = nil
db_.act_monopoly_evt_buy_ = nil
db_.act_monopoly_evt_dlg_ = nil
db_.act_red_bag_ = nil
db_.act_red_scheme_ = nil
db_.act_red_talk_ = nil
db_.act_redPlan_shop_ = nil
db_.act_redPlan_point_ = nil
db_.act_redPlan_fuellimit_ = nil
db_.act_redplan_fuel_ = nil
db_.act_festival_piece_ = nil
db_.act_luky_draw_ = nil
db_.act_luky_draw_by_ID_ = nil
db_.act_config_ = nil
db_.act_tank_convert_ = nil
db_.act_part_resolve_ = nil
db_.medal_resolve_count_ = nil
db_.act_question_anwser_ = nil
db_.act_probability_show_ = nil


function ActivityCenterMO.init()
	db_.act_rebate_ = {}
	local records = DataBase.query(s_act_rebate)
	for index = 1, #records do
		local data = records[index]
		db_.act_rebate_[data.rebateId] = data
	end

	db_.act_probability_show_ = {}
	local records = DataBase.query(s_act_probability_show)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_probability_show_[data.activityId] then  db_.act_probability_show_[data.activityId] = {} end
		db_.act_probability_show_[data.activityId][data.awardId] = data
	end

	db_.act_question_anwser_ = {}
	local records = DataBase.query(s_act_question_anwser)
	for index = 1, #records do
		local data = records[index]
		db_.act_question_anwser_[data.keyId] = data
	end

	db_.act_fortune_ = {}
	local records = DataBase.query(s_act_fortune)
	for index = 1, #records do
		local data = records[index]
		db_.act_fortune_[data.fortuneId] = data
	end

	db_.act_rank_ = DataBase.query(s_act_rank)

	db_.act_raffle_ = {}
	local records = DataBase.query(s_act_raffle)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_raffle_[data.activityId] then db_.act_raffle_[data.activityId] = {} end
		table.insert(db_.act_raffle_[data.activityId],data)
	end

	db_.act_equate_ = {}
	local records = DataBase.query(s_act_equate)
	for index = 1, #records do
		local data = records[index]
		db_.act_equate_[data.equateId] = data
	end

	db_.act_anniversary_ = {}
	local records = DataBase.query(s_anniversary_prop)
	for index = 1,#records do
		local data = records[index]
		db_.act_anniversary_[data.id] = data
	end

	db_.act_m1a2_ = {}
	local records = DataBase.query(s_activity_m1a2)
	for index = 1,#records do
		local data = records[index]
		db_.act_m1a2_[data.id] = data
	end

	db_.act_flower_ = {}
	local records = DataBase.query(s_activity_flower)
	for index = 1,#records do
		local data = records[index]
		db_.act_flower_[data.id] = data
	end

	db_.act_rebate_turn_ = {}
	local records = DataBase.query(s_act_rebate_)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_rebate_turn_[data.type] then
			db_.act_rebate_turn_[data.type] = {}
		end
		table.insert(db_.act_rebate_turn_[data.type],data)
	end

	db_.act_change_ = {}
	local records = DataBase.query(s_act_change_)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_change_[data.activityId] then
			db_.act_change_[data.activityId] = {}
		end
		table.insert(db_.act_change_[data.activityId], data)
	end

	db_.act_pirate_ = {}
	local records = DataBase.query(s_act_pirate_)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_pirate_[data.awardId] then
			db_.act_pirate_[data.awardId] = {}
		end
		db_.act_pirate_[data.awardId][data.id] = data
	end

	db_.act_boss_ = {}
	local records = DataBase.query(s_act_boss_)
	for index = 1,#records do
		local data = records[index]
		db_.act_boss_[data.keyId] = data
	end

	db_.act_hilarity_pray_ = {}
	local records = DataBase.query(s_act_hilarity_pray_)
	for index = 1,#records do
		local data = records[index]
		db_.act_hilarity_pray_[data.id] = data
	end

	db_.act_gamble_ = {}
	local records = DataBase.query(s_act_gamble_)
	for index = 1,#records do
		local data = records[index]
		db_.act_gamble_[data.gambleId] = data
	end

	db_.act_worship_ = {}
	local records = DataBase.query(s_act_worship_)
	for index = 1,#records do
		local data = records[index]
		db_.act_worship_[data.keyId] = data
	end

	db_.act_worship_task_ = {}
	local records = DataBase.query(s_act_worship_task_)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_worship_task_[data.awardId] then
			db_.act_worship_task_[data.awardId] = {}
		end
		db_.act_worship_task_[data.awardId][data.day] = data
	end

	db_.act_worship_god_data_ = {}
	local records = DataBase.query(s_act_worship_god_data_)
	for index = 1,#records do
		local data = records[index]
		db_.act_worship_god_data_[data.count] = data
	end

	db_.act_act_college_education_ = {}
	local records = DataBase.query(s_act_college_education)
	for index = 1,#records do
		local data = records[index]
		db_.act_act_college_education_[data.id] = data
	end

	db_.act_college_showgirlchat_ = {}
	local records = DataBase.query(s_act_college_showgirlchat)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_college_showgirlchat_[data.showgirlnumber] then
			db_.act_college_showgirlchat_[data.showgirlnumber] = {}
		end
		table.insert(db_.act_college_showgirlchat_[data.showgirlnumber], data)
	end

	db_.act_college_subject_ = {}
	local records = DataBase.query(s_act_college_subject)
	for index = 1,#records do
		local data = records[index]
		db_.act_college_subject_[data.id] = data
	end

	--淬炼大师
	db_.act_refinemaster_ = {}
	local records = DataBase.query(s_act_refinemaster)
	for index = 1,#records do
		local data = records[index]
		db_.act_refinemaster_[data.id] = data
	end

	--能量灌注
	db_.act_cumulativepay_ = {}
	local records = DataBase.query(s_act_cumulativepay)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_cumulativepay_[data.activityid] then
			db_.act_cumulativepay_[data.activityid] = {}
		end
		db_.act_cumulativepay_[data.activityid][data.dayid] = data
	end

	-- 自选豪礼
	db_.act_choosegift_ = {}
	local records = DataBase.query(s_act_choosegift)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_choosegift_[data.awardid] then
			db_.act_choosegift_[data.awardid] = {}
		end
		db_.act_choosegift_[data.awardid][data.id] = data
	end

	-- 兄弟同心 BUFF
	db_.act_brother_buff_ = {}
	local records = DataBase.query(s_act_brother_buff)
	for index = 1,#records do
		local data = records[index]
		db_.act_brother_buff_[data.id] = data
	end

	-- 兄弟同心 task
	db_.act_brother_task_ = {}
	local records = DataBase.query(s_act_brother_task)
	for index = 1,#records do
		local data = records[index]
		db_.act_brother_task_[data.id] = data
	end

	-- 兄弟同心 db_.act_brother_radio_
	db_.act_brother_radio_ = {}
	local records = DataBase.query(s_act_brother_radio)
	for index = 1,#records do
		local data = records[index]
		db_.act_brother_radio_[#db_.act_brother_radio_ + 1] = data
	end

	db_.act_brother_ = {}
	local records = DataBase.query(s_act_brother)
	for index = 1,#records do
		local data = records[index]
		db_.act_brother_[#db_.act_brother_ + 1] = data
	end

	--超时空财团
	db_.act_hyperspace_ = {}
	local records = DataBase.query(s_act_hyperspace)
	for index = 1,#records do
		local data = records[index]
		db_.act_hyperspace_[data.id] = data
	end

	-- 勋章活跃性
	db_.act_medalofhonor_ = {} 
	local records = DataBase.query(s_act_medalofhonor)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_medalofhonor_[data.acitivityid] then
			db_.act_medalofhonor_[data.acitivityid] = {}
		end
		db_.act_medalofhonor_[data.acitivityid][data.id] = data
	end

	db_.act_medalofhonor_explore_ = {}
	local records = DataBase.query(s_act_medalofhonor_explore)
	for index = 1,#records do
		local data = records[index]
		db_.act_medalofhonor_explore_[data.id] = data
	end

	db_.act_medalofhonor_rule_ = {}
	local records = DataBase.query(s_act_medalofhonor_rule)
	for index = 1,#records do
		local data = records[index]
		db_.act_medalofhonor_rule_[data.id] = data
	end

	-- 大富翁
	db_.act_monopoly_ = {}
	local records = DataBase.query(s_act_monopoly)
	for index = 1,#records do
		local data = records[index]
		db_.act_monopoly_[data.activityId] = data
	end

	db_.act_monopoly_evt_ = {}
	local records = DataBase.query(s_act_monopoly_evt)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_monopoly_evt_[data.activityId] then
			db_.act_monopoly_evt_[data.activityId] = {}
		end
		db_.act_monopoly_evt_[data.activityId][data.id] = data
	end

	db_.act_monopoly_evt_buy_ = {}
	local records = DataBase.query(s_act_monopoly_evt_buy)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_monopoly_evt_buy_[data.eId] then
			db_.act_monopoly_evt_buy_[data.eId] = {}
		end
		db_.act_monopoly_evt_buy_[data.eId][data.id] = data
	end

	db_.act_monopoly_evt_dlg_ = {}
	local records = DataBase.query(s_act_monopoly_evt_dlg)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_monopoly_evt_dlg_[data.eid] then
			db_.act_monopoly_evt_dlg_[data.eid] = {}
		end
		db_.act_monopoly_evt_dlg_[data.eid][data.id] = data
	end

	-- 红包活动
	db_.act_red_bag_ = {}
	local records = DataBase.query(s_act_red_bag)
	for index = 1,#records do
		local data = records[index]
		if not db_.act_red_bag_[data.activityId] then
			db_.act_red_bag_[data.activityId] = {}
		end
		db_.act_red_bag_[data.activityId][#db_.act_red_bag_[data.activityId] + 1] = data
	end

	--红色方案
	db_.act_red_scheme_ = {}
	local records = DataBase.query(s_act_red_scheme)
	for index = 1, #records do
		local data = records[index]
		db_.act_red_scheme_[data.areaId] = data
	end

	db_.act_red_talk_ = {}
	local records = DataBase.query(s_act_red_talk)
	for index = 1, #records do
		local data = records[index]
		db_.act_red_talk_[data.id] = data
	end

	db_.act_redPlan_shop_ = {}
	local records = DataBase.query(s_act_redPlan_shop)
	for index = 1, #records do
		local data = records[index]
		db_.act_redPlan_shop_[#db_.act_redPlan_shop_ + 1] = data
	end

	db_.act_redPlan_point_ = {}
	local records = DataBase.query(s_act_redPlan_point)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_redPlan_point_[data.awardId] then
			db_.act_redPlan_point_[data.awardId] = {}
		end
		if not db_.act_redPlan_point_[data.awardId][data.areaInclude] then
			db_.act_redPlan_point_[data.awardId][data.areaInclude] = {}
		end
		db_.act_redPlan_point_[data.awardId][data.areaInclude][#db_.act_redPlan_point_[data.awardId][data.areaInclude] + 1] = data
	end

	db_.act_redPlan_fuellimit_ = {}
	local records = DataBase.query(s_act_redPlan_fuellimit)
	for index = 1, #records do
		local data = records[index]
		db_.act_redPlan_fuellimit_[data.id] = data
	end

	db_.act_redplan_fuel_ = {}
	local records = DataBase.query(s_act_redplan_fuel)
	for index = 1, #records do
		local data = records[index]
		db_.act_redplan_fuel_[data.amount] = data
	end

	db_.act_festival_piece_ = {}
	local records = DataBase.query(s_act_festival_piece)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_festival_piece_[data.awardId] then
			db_.act_festival_piece_[data.awardId] = {}
		end
		db_.act_festival_piece_[data.awardId][data.id] = data
	end

	db_.act_luky_draw_ = {}
	db_.act_luky_draw_by_ID_ = {}
	local records = DataBase.query(s_act_luky_draw)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_luky_draw_[data.awardId] then
			db_.act_luky_draw_[data.awardId] = {}
		end
		db_.act_luky_draw_[data.awardId][#db_.act_luky_draw_[data.awardId] + 1] = data
		db_.act_luky_draw_by_ID_[data.lucyId] = data
	end

	db_.act_config_ = {}
	local records = DataBase.query(s_act_config)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_config_[data.activityId] then
			db_.act_config_[data.activityId] = {}
		end
		db_.act_config_[data.activityId][data.awardId] = data
	end

	--坦克置换
	db_.act_tank_convert_ = {}
	local records = DataBase.query(s_act_tanConvert)
	for index = 1, #records do
		local data = records[index]
		db_.act_tank_convert_[data.id] = data
	end

	db_.act_part_resolve_ = {}
	db_.medal_resolve_count_ = {}
	local medalResolve = false
	local records = DataBase.query(s_act_part_resolve)
	for index = 1, #records do
		local data = records[index]
		if not db_.act_part_resolve_[data.activityId] then
			db_.act_part_resolve_[data.activityId] = {}
		end
		if data.activityId == ACTIVITY_ID_MEDAL_RESOLVE and medalResolve == false then
			medalResolve = true
			local resolveList = json.decode(data.resolveList)
			for i, v in ipairs(resolveList) do
				local tp = v[1]
				local quality = v[2]
				local count = v[3]

				if db_.medal_resolve_count_[tp] == nil then
					db_.medal_resolve_count_[tp] = {}
				end

				if db_.medal_resolve_count_[tp][quality] == nil then
					db_.medal_resolve_count_[tp][quality] = {}
				end

				if v[1] == 28 or v[1] == 29 then
					if v[1] == 28 and quality == 4 then
						local spFactor = json.decode(data.partNum)
						for i1, v1 in ipairs(spFactor) do
							local partPos = v1[1]
							local posFac = v1[2] * 0.01
							if db_.medal_resolve_count_[tp][quality][partPos] == nil then
								db_.medal_resolve_count_[tp][quality][partPos] = {}
							end

							db_.medal_resolve_count_[tp][quality][partPos]['count'] = count
							db_.medal_resolve_count_[tp][quality][partPos]['fac'] = posFac
						end
					else
						db_.medal_resolve_count_[tp][quality]['count'] = count
						db_.medal_resolve_count_[tp][quality]['fac'] = 1.0
					end
				end
			end
		end
		db_.act_part_resolve_[data.activityId][data.resolveId] = data
	end

	--最强王者活动
	db_.act_king_rank_ = {}
	local records = DataBase.query(s_act_king_rank)
	for index = 1, #records do
		local data = records[index]
		db_.act_king_rank_[data.id] = data
	end


	db_.act_king_award_ = {}
	local records = DataBase.query(s_act_king_award)
	for index = 1, #records do
		local data = records[index]
		db_.act_king_award_[data.id] = data
	end

	db_.act_king_ratio_ = {}
	local records = DataBase.query(s_act_king_ratio)
	for index = 1, #records do
		local data = records[index]
		db_.act_king_ratio_[data.id] = data
	end
end


function ActivityCenterMO.getMedalResolveChipCount(tp, quality, partPos)
	if tp ~= 28 and tp ~= 29 then
		return 0
	end

	local data = nil
	if tp == 28 and quality == 4 then
		data = db_.medal_resolve_count_[tp][quality][partPos]
	else
		data = db_.medal_resolve_count_[tp][quality]
	end
	return data.count * data.fac
end


function ActivityCenterMO.getCollegeEducation(id)
	if not id then
		return db_.act_act_college_education_
	else
		return db_.act_act_college_education_[id]
	end
end

function ActivityCenterMO.getCollegeShowgirlchat(id,index)
	if not index then
		return db_.act_college_showgirlchat_[id]
	else
		return db_.act_college_showgirlchat_[id][index]
	end
end

--通过ID索取超时空财团表信息
function ActivityCenterMO.gethyperSpaceById(id)
	return db_.act_hyperspace_[id]
end

function ActivityCenterMO.getCollegeSubject(id)
	return db_.act_college_subject_[id]
end

function ActivityCenterMO.getRechargeTurn(kind)
	return db_.act_rebate_turn_[kind]
end

function ActivityCenterMO.getAllEqudate()
	return db_.act_equate_
end

function ActivityCenterMO.getEquateById(id)
	return db_.act_equate_[id]
end

function ActivityCenterMO.getActivityContentById(activityId)
	return ActivityCenterMO.activityContents_[activityId]
end

function ActivityCenterMO.getA1m2ById(id)
	return db_.act_m1a2_[id]
end

function ActivityCenterMO.getFlowerAward()
	return db_.act_flower_
end

function ActivityCenterMO.getStorehouseShop(awardId)
	return db_.act_change_[awardId]
end

function ActivityCenterMO.getStorehouseList(awardId,id)
	return db_.act_pirate_[awardId][id]
end

function ActivityCenterMO.getActBossInfo()
	return db_.act_boss_[1]
end

function ActivityCenterMO.getActHilarity(id)
	return db_.act_hilarity_pray_[id]
end

function ActivityCenterMO.getGambleById(id)
	return db_.act_gamble_[id]
end

function ActivityCenterMO.getWorshipGodById(id)
	return db_.act_worship_[id]
end

function ActivityCenterMO.getWorshipTaskById(activityId,day)
	return db_.act_worship_task_[activityId][day]
end

function ActivityCenterMO.getWorshipGodDataTimes(count)
	if not db_.act_worship_god_data_[count] then return nil end
	return db_.act_worship_god_data_[count]
end

function ActivityCenterMO.getRedPacketData(activityId, id)
	if not activityId then return nil end
	if not id then return db_.act_red_bag_[activityId] end
	return db_.act_red_bag_[activityId][id]
end

function ActivityCenterMO.getProbabilityTextById(activityId, awardId)
	local data = db_.act_probability_show_
	local contentInfo =  db_.act_probability_show_[activityId][awardId]
	if contentInfo then
		local text = json.decode(contentInfo.chance_des)
		local content = {}
		for index=1,#text do
			table.insert(content,{{content = text[index]}})
		end
		contentInfo.content = content
		return contentInfo
	end
end

--建军返利
function ActivityCenterMO.getRebateListById(activityId)
	local list = {}
	for index=1,#db_.act_rebate_ do
		local data = db_.act_rebate_[index]
		if data.activityId == activityId then
			list[#list + 1] = data
		end
	end
	return list
end

function ActivityCenterMO.getFortuneById(activityId)
	-- local fortuneId
	-- if activityId == ACTIVITY_ID_FORTUNE then
	-- 	fortuneId = 1
	-- elseif activityId == ACTIVITY_ID_PARTDIAL then
	-- 	fortuneId = 3
	-- elseif activityId == ACTIVITY_ID_CONSUMEDIAL then
	-- 	fortuneId = 5
	-- end
	-- if not db_.act_fortune_[fortuneId] then return nil end
	-- return db_.act_fortune_[fortuneId]

	return ActivityCenterMO.activityContents_[activityId].actFortune
end

function ActivityCenterMO.getFortuneByFortunId(fortunId)
	if not fortunId then return {} end
	local data = db_.act_fortune_
	return data[fortunId]
end

function ActivityCenterMO.getRankDataById(activityId)
	local list = {}
	for k,v in pairs(db_.act_rank_) do
		if v.activityId == activityId then
			v.rank = v.rankBegin
			v.rankEd = v.rankEnd
			list[#list + 1] = v
		end
	end
	table.sort(list,function(a,b)
			return a.keyId < b.keyId
		end)
	return list 
end

function ActivityCenterMO.getRaffleById(activityId)
	if not db_.act_raffle_[activityId] then return nil end
	return db_.act_raffle_[activityId]
end

--type 1配件 2芯片
function ActivityCenterMO.getActPartResolveChip(type,quality)
	local count = 0
	gprint(quality,"quality")
	if type == 1 then
		if quality == 2 then
			count = 5
		elseif quality == 3 then
			count = 120
		elseif quality == 4 then
			count = 2000
		elseif quality == 5 then
			count = 5000
		end
	elseif type == 2 then
		if quality == 3 then
			count = 50
		elseif quality == 4 then
			count = 800
		elseif quality == 5 then
			count = 2000
		end
	end
	gprint(count,"count")
	return count
end

--周年庆活动兑换
function ActivityCenterMO.getExchangeById(keyId)
	if not db_.act_anniversary_[keyId] then return nil end
	return db_.act_anniversary_[keyId]
end

function ActivityCenterMO.activityIng(id)
	for k,v in pairs(ActivityCenterMO.activityList_) do
		if v.activityId == id then
			return v
		end
	end
	return nil
end

--获取淬炼大师开奖消耗
function ActivityCenterMO.getConsumeById(id)
	return db_.act_refinemaster_[id]
end

-- 能量灌注
function ActivityCenterMO.getCumulativepay(awardId,day)
	return db_.act_cumulativepay_[awardId][day]
end

-- isCheckType default 0
-- 0 检查是否在活动期间
-- 1 检查是否在当前页面
function ActivityCenterMO.isCheckActivityNewenergy(isCheckType)
	isCheckType = isCheckType or 0
	if isCheckType == 1 then
		if UiDirector.getTopUiName() == "ActivityNewEnergyView" then
			return true
		end
	else
		if ActivityCenterBO.isValid(ACTIVITY_ID_NEWENERGY) then
			return true
		end 
	end
	return false
end

-- 自选豪礼
function ActivityCenterMO.getChooseGift(awardId)
	return db_.act_choosegift_[awardId]
end


-- 用于活动的本地记录
-- true
-- false
function ActivityCenterMO.UseActivityLoaclRecordInfo(key,_value)
	local _keys = key .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId

	-- 获取本地数据
	if not ActivityCenterMO.actLocalRecord then
		local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal_" .. _keys
		local stores = nil
		if io.exists(path) then
	        stores = json.decode(io.readfile(path))
	    end
	    if stores then
	    	ActivityCenterMO.actLocalRecord = stores
	    else
	    	ActivityCenterMO.actLocalRecord = {}
	    end
	end
	
	-- 读取记录
	local isValue = ActivityCenterMO.actLocalRecord[_keys]
	if isValue ~= nil then
		if _value and isValue ~= _value then
			-- 修改 并保存记录
			isValue = _value
			ActivityCenterMO.actLocalRecord[_keys] = isValue
			local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal_" .. _keys
			io.writefile(path, json.encode(ActivityCenterMO.actLocalRecord), "w+b")
		end
	else
		-- 添加新记录
		if _value then
			isValue = _value
		else
			isValue = false
		end
		ActivityCenterMO.actLocalRecord[_keys] = isValue
		local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal_" .. _keys
		io.writefile(path, json.encode(ActivityCenterMO.actLocalRecord), "w+b")
	end
	return isValue
end

-- 用于活动的本地记录2 for 
function ActivityCenterMO.UseActLocalRecord(actID,_inParam)
	local _keys = actID .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId

	if not ActivityCenterMO.actLocalRecord2 then
		local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal2_" .. _keys
		local stores = nil
		if io.exists(path) then
	        stores = json.decode(io.readfile(path))
	    end
	    if stores then
	    	ActivityCenterMO.actLocalRecord2 = stores
	    else
	    	ActivityCenterMO.actLocalRecord2 = {}
	    end
	end

	-- 读取记录
	local iValue = ActivityCenterMO.actLocalRecord2[_keys]
	if iValue then
		if _inParam then	
			-- 写入
			iValue = _inParam
			ActivityCenterMO.actLocalRecord2[_keys] = iValue
			local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal2_" .. _keys
			io.writefile(path, json.encode(ActivityCenterMO.actLocalRecord2), "w+b")
			
		end
	else
		iValue = {}
		if _inParam then	
			-- 写入
			iValue = _inParam
			ActivityCenterMO.actLocalRecord2[_keys] = iValue
			local path = CCFileUtils:sharedFileUtils():getCachePath() .. "actlocal2_" .. _keys
			io.writefile(path, json.encode(ActivityCenterMO.actLocalRecord2), "w+b")
			
		end
	end
	return iValue
end

-- db_.act_brother_buff_
function ActivityCenterMO.getActBrotherBuff(id)
	return db_.act_brother_buff_[id]
end

-- db_.act_brother_task_
function ActivityCenterMO.getActBrotherTask(id)
	return db_.act_brother_task_[id]
end

-- db_.act_brother_radio_
function ActivityCenterMO.getActBrotherRadio()
	return db_.act_brother_radio_
end

-- db_.act_brother_
function ActivityCenterMO.getActBrother()
	return db_.act_brother_
end

--
function ActivityCenterMO.getActivityMedal(acitivityid,id)
	if not id then return nil end
	return db_.act_medalofhonor_[acitivityid][id]
end

function ActivityCenterMO.getActivityMedalExplore(id)
	return db_.act_medalofhonor_explore_[id]
end

function ActivityCenterMO.getActivityMedalRule()
	return db_.act_medalofhonor_rule_
end

-- 获取 大富翁 活动配置信息
function ActivityCenterMO.getMonopolyActInfo(activityID)
	return db_.act_monopoly_[activityID]
end

-- 获取 大富翁 事件
function ActivityCenterMO.getMonopolyActEvents(activityID, eid)
	if not db_.act_monopoly_evt_[activityID] then return nil end
	return db_.act_monopoly_evt_[activityID][eid]
end

-- 获取 大富翁 打折商品
function ActivityCenterMO.getMonopolyActBuy(eid, id)
	if not db_.act_monopoly_evt_buy_[eid] then return nil end
	return db_.act_monopoly_evt_buy_[eid][id]
end

-- 获取 大富翁 对话
function ActivityCenterMO.getMonopolyActDlg(eid)
	return db_.act_monopoly_evt_dlg_[eid]
end

--红色方案获取区域
function ActivityCenterMO.getRedPlanArea(areaid)
	if not areaid then return db_.act_red_scheme_ end
	return db_.act_red_scheme_[areaid]
end

--获取当前id的谈话信息
function ActivityCenterMO.getCurrentTalkInfo(id)
	return db_.act_red_talk_[id]
end

--红色方案，根据章节判断当前的章节所包含的对话
function ActivityCenterMO.getTalkByChapter(chapter)
	if not chapter then return end
	local tanlkInfo = db_.act_red_talk_
	local chapterInfo = {}
	for index=1,#tanlkInfo do
		if db_.act_red_talk_[index].chapter == chapter then
			table.insert(chapterInfo, db_.act_red_talk_[index])
		end
	end

	return chapterInfo
end

--红色方案，获取所有的商品；
function ActivityCenterMO.getAllRedPlanGoods()
	return db_.act_redPlan_shop_
end

--
function ActivityCenterMO.getRedPlanPoints(activityid, area)
	if not db_.act_redPlan_point_[activityid] then return nil end
	return db_.act_redPlan_point_[activityid][area]
end

function ActivityCenterMO.getRedPlanFuelLimit()
	return db_.act_redPlan_fuellimit_[1]
end

function ActivityCenterMO.getRedPlanFuelRole(amount)
	local _amount = amount + 1
	local _db =  db_.act_redplan_fuel_[_amount]
	if not _db then
		_db = db_.act_redplan_fuel_[#db_.act_redplan_fuel_]
	end
	return _db.cost
end

--根据区域ID判断箭头指向点
function ActivityCenterMO:getArrowPoint(id)
	if id > 6 then return end
	--a:起始点
	--b:终点
	--isforward：是否是正方向
	local configPoint = {
		[1] = {a = cc.p(500, 360), b = cc.p(470, 550), isforward = true},
		[2] = {a = cc.p(533, 650), b = cc.p(140, 680), isforward = false},
		[3] = {a = cc.p(250, 670), b = cc.p(100, 760), isforward = false},
		[4] = {a = cc.p(100, 700), b = cc.p(290, 710), isforward = false},
		[5] = {a = cc.p(310, 820), b = cc.p(460, 670), isforward = true},
		[6] = {a = cc.p(440, 640), b = cc.p(520, 680), isforward = false}
	}
	
	local begainPoint = configPoint[id].a
	local endPoint = configPoint[id].b
	local isforward = configPoint[id].isforward

	return begainPoint, endPoint, isforward
end

--节日碎片，根据活动的awardId获取配置信息
function ActivityCenterMO:getFestivalInfo(awardId)
	if not awardId then return end
	return db_.act_festival_piece_[awardId]
end

--节日碎片，数据处理
function ActivityCenterMO:getFestivalData(data)
	if not data then return end
	local iconInfo = {}
	local excInfo = {}
	local myData = data
	for k,v in pairs(myData) do
		if v.identfy == 1 then
			iconInfo = v
		elseif v.identfy == 2 then
		elseif v.identfy == 3 then
			table.insert(excInfo, v)
		end
	end

	function sortFun(a,b)
		return a.id < b.id
	end
	table.sort(excInfo,sortFun)

	return iconInfo, excInfo
end

function ActivityCenterMO.getLuckAwardDraw(activityAwardId)
	return db_.act_luky_draw_[activityAwardId]
end

function ActivityCenterMO.getLuckAwardDrawByID(lucyId)
	return db_.act_luky_draw_by_ID_[lucyId]
end

function ActivityCenterMO.getActivitySupportConfig(activityId, awardId)
	return db_.act_config_[activityId][awardId]
end

function ActivityCenterMO.getTankExcInfo(id)
	if not id then
		return db_.act_tank_convert_
	end
	return db_.act_tank_convert_[id]
end

function ActivityCenterMO.getTankExcByAwardId(awardId)
	local excInfo = {}
	local data = ActivityCenterMO.getTankExcInfo()
	for index=1,#data do
		if data[index].awardId == awardId then
			excInfo[#excInfo + 1] = data[index]
		end
	end

	return excInfo
end

function ActivityCenterMO.getQuestionById(id)
	if not id then return db_.act_question_anwser_ end
	if db_.act_question_anwser_[id] then return db_.act_question_anwser_[id] end
	return nil
end

--最强王者
--通过类型索取到活动类型数据
function ActivityCenterMO.getKingInfoByKind(kind)
	if not kind then return db_.act_king_award_ end
	local info = {}
	for index=1,#db_.act_king_award_ do
		local data = db_.act_king_award_[index]
		if data.type == kind then
			info[#info + 1] = data
		end
	end

	return info
end

--通过类型索取类型活动的排行奖励
function ActivityCenterMO.getKingRankByKind(kind)
	if not kind then return db_.act_king_rank_ end
	local info = {}
	for index=1,#db_.act_king_rank_ do
		local data = db_.act_king_rank_[index]
		if data.type == kind then
			info[#info + 1] = data
		end
	end

	return info
end

--获取当前活动是第几阶段
function ActivityCenterMO.getActivityStage(activity)
	local data = db_.act_king_ratio_
	local beginTime = activity.beginTime
	local endTime = activity.endTime
	local displayTime = activity.displayTime
	local nowTime = ManagerTimer.getTime()

	if nowTime > endTime and nowTime <= displayTime then
		return 4
	end

	for index=1,#data do
		local indexTime = beginTime + data[index].date * 86400
		local lastTime = beginTime
		if data[index -1] and data[index -1].date then
			lastTime = beginTime + data[index -1].date * 86400
		end

		if nowTime >= beginTime and nowTime <= indexTime then
			return index
		end
	end

	return 0
end

--根据排行榜类型获取最大可领取的名次
function ActivityCenterMO.getMaxNumByKind(kind)
	local data = ActivityCenterMO.getKingRankByKind(kind)
	return data[#data].rankEnd
end