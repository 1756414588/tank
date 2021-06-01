
local s_activity = require("app.data.s_activity")
local s_activity_award = require("app.data.s_activity_award")
local s_activity_time = require("app.data.s_activity_time")
local s_activity_effect = require("app.data.s_activity_effect")
local s_act_foison = require("app.data.s_act_foison")
local s_act_month_sign = require("app.data.s_act_month_sign")
local s_act_stroke = require("app.data.s_act_stroke")
local s_act_welfare = require("app.data.s_bonus")
local s_act_pay_new = require("app.data.s_act_pay_new")
local s_act_party_war = require("app.data.s_activity_partywar")

-- 以activityId作为索引
local db_activity_ = nil
local db_activity_award_ = nil
local db_activity_time_ = nil
local db_activity_effect_ = nil
local db_activity_month_sign_ = nil
local db_act_stroke_ = nil
local db_act_welfare = nil
local db_act_pay_new_ = nil
local db_act_party_war = nil
local act_pay_new_min_ = 0
local act_pay_new_max_ = 0

local ActivityConfig = {
{bar = 1},
{bar = 2},
{bar = 3},
{bar = 3},
{bar = 3},  -- 5
{bar = 3},
{bar = 7},
{bar = 8},
{bar = 9},
{bar = 10},  -- 10
{bar = 11},
{bar = 3},
{bar = 13},
{bar = 14},
{bar = 15},  -- 15
{bar = 16},
{bar = 17},
{bar = 18},
{bar = 19},
{bar = 20},  -- 20
{bar = 21},
{bar = 22},
{bar = 23},
{bar = 24},
{bar = 25},  -- 25
{bar = 26},
{bar = 27},
{bar = 28},
{bar = 29},
{bar = 30},  -- 30
{bar = 31},
{bar = 32},
{bar = 33},
{bar = 25},
{bar = 35},   -- 35
{bar = 36},
{bar = 37},
{bar = 38},
{bar = 39},
{bar = 40}, -- 40
{bar = 41},
{bar = 42},
{bar = 43},
{bar = 30},
{bar = 45}, -- 45
{bar = 46},
{bar = 47},
{bar = 48},
{bar = 49},
{bar = 50}, --- 50
{bar = 51},
{bar = 52},
{bar = 53},
{bar = 54},
{bar = 55}, --- 55
{bar = 40},
{bar = 2},
{bar = 31},
{bar = 59},
{bar = 37}, --  60
{bar = 61},
{bar = 28},
{bar = 42},
{bar = 45},
{bar = 65}, --  65
{bar = 66},
{bar = 67},
{bar = 68},
{bar = 69},
{bar = 70}, --  70
{bar = 71},
{bar = 71},
{bar = 73},
{bar = 74},
{bar = 75}, -- 75
{bar = 76},
{bar = 77},
{bar = 78},
{bar = 79},
}

ActivityMO = {}

ACTIVITY_ID_LEVEL_RANK = 1 -- 等级排名
ACTIVITY_ID_ATTACK = 2 -- 雷霆计划
ACTIVITY_ID_FIGHT_RANK = 3 -- 战力排名
ACTIVITY_ID_COMBAT = 4 -- 关卡排名
ACTIVITY_ID_HONOUR = 5 -- 荣誉排名
ACTIVITY_ID_PARTY_LEVEL = 6 -- 军团等级
ACTIVITY_ID_PARTY_RECURIT = 7 -- 军团招募
ACTIVITY_ID_EQUIP = 8  -- 装备探险
ACTIVITY_ID_PART = 9
ACTIVITY_ID_RESOURCE = 10  -- 资源采集
ACTIVITY_ID_FIGHT_COMBAT = 11 -- 激情关卡
ACTIVITY_ID_PARTY_FIGHT = 12 -- 军团战力
ACTIVITY_ID_RTURN_DONATE = 13 -- 捐献返还
ACTIVITY_ID_CARVINAL = 14  -- 全民狂欢
ACTIVITY_ID_INVEST = 15  -- 投资计划
ACTIVITY_ID_PAY_RED_GIFT = 16 -- 充值红包
ACTIVITY_ID_PAY_EVERYDAY = 17 -- 开服充值
ACTIVITY_ID_PAY_FIRST = 18 -- 首充礼包
ACTIVITY_ID_QUOTA = 19 -- 开服限购
ACTIVITY_ID_PURPLE_EQP_COL = 20  -- 紫装收集
ACTIVITY_ID_PURPLE_EQP_UP = 21  -- 紫装升级
ACTIVITY_ID_CRAZY_ARENA = 22 -- 疯狂竞技
ACTIVITY_ID_CRAZY_UPGRADE = 23  -- 疯狂升级
ACTIVITY_ID_PART_EVOLVE = 24  -- 配件进化
ACTIVITY_ID_FLASH_SALE = 25  -- 限时抢购
ACTIVITY_ID_HERO_RECRUIT = 26 -- 招兵买将
ACTIVITY_ID_LOTTERY_EQUIP = 27 -- 抽装折扣
ACTIVITY_ID_COST_GOLD = 28  -- 消费有奖
ACTIVITY_ID_EQUIP_SUPPLY = 29 -- 装备补给
ACTIVITY_ID_CONTU_PAY = 30  -- 连续充值
ACTIVITY_ID_RES_HARV = 31 -- 资源丰收
ACTIVITY_ID_DAY_PAY = 32 -- 天天充值
ACTIVITY_ID_DAY_BUY = 33 -- 天天限购
ACTIVITY_ID_FLASH_META = 34 -- 限购材料
ACTIVITY_ID_MONTH_SCALE = 35 -- 月末限购
ACTIVITY_ID_GIFT_ONLINE = 36 -- 在线送礼
ACTIVITY_ID_MONTH_LOGIN = 37 -- 每月登录
ACTIVITY_ID_ENEMY_SALE = 38  -- 敌军兜售
ACTIVITY_ID_EQUIP_UP_CRIT = 39  -- 升装暴击
ACTIVITY_ID_COMBAT_INTERCEPT = 40 -- 关卡拦截
ACTIVITY_ID_FIRST_REBATE = 41 -- 首充返利
ACTIVITY_ID_RECHARGE_GIFT = 42 -- 充值赠送
ACTIVITY_ID_VIP_GIFT = 43 -- VIP礼包
ACTIVITY_ID_PAY_FOUR = 44 -- 连续4天充值
ACTIVITY_ID_SPRING_SCALE = 45 -- 春节限购
ACTIVITY_ID_PART_SUPPLY = 46 -- 配件补给
ACTIVITY_ID_SCIENCE_DIS = 47 -- 科技优惠
ACTIVITY_ID_PARTY_DONATE = 48 -- 火力全开

ACTIVITY_ID_MILITARY = 49 			-- 军工探险
ACTIVITY_ID_MILITARY_SUPPLY = 50 	-- 军工补给
ACTIVITY_ID_ENERGY = 51 			-- 能晶探险
ACTIVITY_ID_ENERGY_SUPPLY = 52		-- 能晶补给
ACTIVITY_ID_POWRE_SUPPLY = 53 		-- 能量赠送
ACTIVITY_ID_ANNIVERSARY	 = 54		-- 周年庆

ACTIVITY_ID_CONTU_PAY_NEW = 55		-- 连续充值新
ACTIVITY_ID_COMBAT_INTERCEPT_NEW = 56		-- 关卡拦截新
ACTIVITY_ID_ATTACK_NEW = 57         --雷霆计划新
ACTIVITY_ID_INVEST_NEW = 59         -- 新投资计划
ACTIVITY_ID_SERVERS_LOGIN = 60      --合服登录
ACTIVITY_ID_REFINE_CRIT = 61      --淬炼暴击
ACTIVITY_ID_CON_COST_GOLD = 62 		--合服消费
ACTIVITY_ID_CON_RECHARGE_GIFT = 63 	--合服累冲
ACTIVITY_ID_CON_SPRING_SCALE = 64 	--合服限购
ACTIVITY_ID_SECRET_WEAPON = 65      --秘密武器
ACTIVITY_ID_BIGWIG_LEADER = 66 		--大咖带队
ACTIVITY_ID_LOTTERY_TREASURE = 67	--探宝大师
ACTIVITY_ID_EXPLOR_MEDAL = 68       --勋章探险
ACTIVITY_ID_MEDAL_SUPPLY = 69       --勋章补给
ACTIVITY_ID_CASHBACK = 70			-- 充值返现
ACTIVITY_ID_SCIENCE_SPEED = 71		--科技加速
ACTIVITY_ID_BUILD_SPEED = 72		--建筑加速
ACTIVITY_ID_CASHBACK_NEW = 73		-- 新充值返现
ACTIVITY_ID_LOGIN_AWARDS = 74		-- 登录福利
ACTIVITY_ID_PARTY_LIVES = 75		-- 军团战活跃
ACTIVITY_ID_LIMIT_EXPLORE = 76		-- 极限探险
ACTIVITY_ID_TACTICS_SSUPPLY = 77		-- 战术补给
ACTIVITY_ID_TACTICS_EXPLORE = 78		-- 战术探险
ACTIVITY_ID_GREAT_ACHIEVEMENT = 79		-- 战功显赫

ACTIVITY_ID_GIFT_CODE = 10000  -- 兑换码

ACTIVITY_PARTY_DONATE_COIN_RATE = 0.4 -- 军团军衔

ACTIVITY_INVEST_TAKE_COIN = 500

ACTIVITY_EQUIP_CRIT_RATE = 0.5  -- 升装暴击系数

ACTIVITY_EQUIP_SUPPLY_COIN_RATE = 0.5  -- 装备供给金币返还

ACTIVITY_PART_SUPPLY_COIN_RATE = 0.5  -- 配件补给金币返还

ACTIVITY_MILITARY_SUPPLY_COIN_RATE = 0.5  -- 军工补给金币返还

ACTIVITY_ENERYG_SUPPLY_COIN_RATE = 0.5  -- 能晶补给金币返还

ACTIVITY_MEDAL_SUPPLY_COIN_RATE = 0.5  -- 勋章补给金币返还

ACTIVITY_TACTIC_SUPPLY_COIN_RATE = 0.5  -- 战术补给金币返还

ACTIVITY_WEL_FARE = 25  --开服25天开启福利特惠

-- 活动总的列表信息
ActivityMO.activityList_ = {}

-- 每个活动的内容
ActivityMO.activityContents_ = {}

ActivityMO.refreshHandler_ = nil

ActivityMO.activeBoxHandler_ = nil --活跃宝箱
ActivityMO.activeBoxInfo = {} --活跃宝箱箱子信息

ActivityMO.clickView_ = false -- 标记是否点击过活动按钮

ActivityMO.localConfig_ = {} -- 保存当前开放的所有的活动

ActivityMO.actStroke = {} -- 闪击行动
ActivityMO.welFare_ = nil -- 福利特惠
ActivityMO.partyWarHandler_ = nil -- 军团活跃活动

ActivityMO.actStrokeMax = 0

--招兵买将活动折扣
ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_COIN1 = 0.8
ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_COIN5 = 0.7
ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_RES1 = 0.6
ACTIVITY_ID_HERO_RECRUIT_DISCOUNT_RES5 = 0.5

--科技优惠相关参数
ACTIVITY_ID_SCIENCE_DIS_SID = {101,102,103,104,105} --享受科技优惠的科技ID
ACTIVITY_ID_SCIENCE_DIS_SPEED = 1  --研发速度倍数
ACTIVITY_ID_SCIENCE_DIS_RES_RATE = 0.5 --资源消耗百分比

--火力全开加成
ACTIVITY_ID_PARTY_DONATE_RATE = 1.5

function ActivityMO.init()
	-- db_activity_award_ = {}
	-- local records = DataBase.query(s_activity_award)
	-- for index = 1, #records do
	-- 	local data = records[index]
	-- 	if not db_activity_award_[data.activityId] then
	-- 		db_activity_award_[data.activityId] = {}
	-- 	end
	-- 	db_activity_award_[data.activityId][#db_activity_award_[data.activityId] + 1] = data
	-- end

	db_activity_ = {}
	db_activity_award_ = {}
	db_activity_time_ = {}
	db_activity_effect_ = {}
	db_activity_rechargeHava_ = {}
	db_activity_month_sign_ = {}
	db_act_welfare = {}
	db_act_party_war = {}

	local records = DataBase.query(s_activity)
	for index = 1, #records do
		local data = records[index]
		db_activity_[data.activityId] = data
	end

	local records = DataBase.query(s_activity_award)
	for index = 1, #records do
		local data = records[index]
		db_activity_award_[data.keyId] = data
	end

	local new_records = DataBase.query(s_activity_time)
	for index_ = 1, #new_records do
		local data_ = new_records[index_]
		db_activity_time_[data_.time] = data_
	end

	local records = DataBase.query(s_activity_effect)
	for index = 1, #records do
		local data = records[index]
		if not db_activity_effect_[data.activityId] then
			db_activity_effect_[data.activityId] = {}
		end
		db_activity_effect_[data.activityId][data.day] = data
	end
	--充值丰收
	local records = DataBase.query(s_act_foison)
	for index = 1, #records do
		local data = records[index]
		if not db_activity_rechargeHava_[data.awardId] then
			db_activity_rechargeHava_[data.awardId] = {}
		end
		db_activity_rechargeHava_[data.awardId] = data
	end
	--每日签到
	local records = DataBase.query(s_act_month_sign)
	for index = 1, #records do
		local data = records[index]
		if not db_activity_month_sign_[data.month] then
			db_activity_month_sign_[data.month] = {}
		end
		table.insert(db_activity_month_sign_[data.month], data)
	end

	db_act_stroke_ = {}
	local records = DataBase.query(s_act_stroke)
	for index = 1, #records do
		local data = records[index]
		if not db_act_stroke_[data.activityId] then
			db_act_stroke_[data.activityId] = {}
		end
		db_act_stroke_[data.activityId][data.id] = data
		ActivityMO.actStrokeMax = ActivityMO.actStrokeMax + 1
	end

	local records = DataBase.query(s_act_welfare)
	for index = 1, #records do
		local data = records[index]
		if not db_act_welfare[data.id] then
			db_act_welfare[data.id] = {}
		end
		db_act_welfare[data.id] = data
	end

	local ratio2Str = nil
	db_act_pay_new_ = {}
	local records = DataBase.query(s_act_pay_new)
	for index = 1, #records do
		local data = records[index]
		db_act_pay_new_[data.payId] = data
		if ratio2Str == nil then
			ratio2Str = data.ratio2
		end
	end

	local records = DataBase.query(s_act_party_war)
	for index = 1, #records do
		local data = records[index]
		db_act_party_war[data.Id] = data
	end

	local ratio2Data = json.decode(ratio2Str)
	act_pay_new_min_ = ratio2Data[1][1]
	act_pay_new_max_ = ratio2Data[#ratio2Data][1]
end

function ActivityMO.getMonthSign(month)
	return db_activity_month_sign_[month]
end

-- function ActivityMO.queryActivityAwardsById(activityId)
-- 	return db_activity_award_[activityId]
-- end
--充值丰收
function ActivityMO.queryRechargeHaveById(awardId)
	return db_activity_rechargeHava_[awardId]
end

function ActivityMO.queryActivityAwardsById(keyId)
	return db_activity_award_[keyId]
end

function ActivityMO.queryActivityInfoById(activityId)
	return db_activity_[activityId]
end

function ActivityMO.queryActivityAwardsByAwardId(awardId)
	-- body
	local awards = {}
	local ultiAward = nil
	for k, v in pairs(db_activity_award_) do
		if v.activityId == awardId then
			if v.param == 1 then
				ultiAward = v
			else
				table.insert(awards, v)
			end
		end
	end
	table.sort(awards, function(a,b) return a.keyId < b.keyId end)
	return ultiAward, awards
end

function ActivityMO.getActivityAwardsByTime(time)
	return db_activity_time_[time]
end

function ActivityMO.getActivityEffectByDay(actId,day)
	if not db_activity_effect_[actId] then
		return
	end
	return db_activity_effect_[actId][day or 1]
end

function ActivityMO.getConfigById(id)
	return ActivityConfig[id]
end

function ActivityMO.getActivityById(activityId)
	for index = 1, #ActivityMO.activityList_ do
		if ActivityMO.activityList_[index].activityId == activityId then
			return ActivityMO.activityList_[index]
		end
	end
end

function ActivityMO.getActStroke(activityid, id)
	if not db_act_stroke_[activityid] then return nil end
	return db_act_stroke_[activityid][id]
end

-- function ActivityMO.getActivityContent(activityId, keyId)
-- 	local contents = ActivityMO.activityContents_[activityId]
-- 	if not contents then return end

-- 	for index = 1, #contents do
-- 		if contents[index].keyId == keyId then
-- 			return contents[index]
-- 		end
-- 	end
-- end

function ActivityMO.getActivityContentById(activityId)
	return ActivityMO.activityContents_[activityId]
end

function ActivityMO.getActivityConditionById(activityId, keyId)
	local activityContent = ActivityMO.activityContents_[activityId]
	if not activityContent then return nil end

	if activityId == ACTIVITY_ID_RESOURCE or activityId == ACTIVITY_ID_PARTY_RECURIT or activityId == ACTIVITY_ID_PURPLE_EQP_UP
		or activityId == ACTIVITY_ID_CRAZY_UPGRADE or activityId == ACTIVITY_ID_FIRST_REBATE then -- 资源采集、军团招募
		for itemIndex = 1, #activityContent.items do
			local conditions = activityContent.items[itemIndex].conditions
			for condIndex = 1, #conditions do
				if conditions[condIndex].keyId == keyId then
					return conditions[condIndex]
				end
			end
		end
	else
		for index = 1, #activityContent.conditions do
			local condition = activityContent.conditions[index]
			if condition.keyId == keyId then
				return condition
			end
		end
	end
end

function ActivityMO.getPowerConditionById(activityId, condition)
	local activityContent = ActivityMO.activityContents_[activityId]
	if not activityContent then return nil end

	if activityId == ACTIVITY_ID_POWRE_SUPPLY then -- 能量
		for itemIndex = 1, #activityContent.conditions do
			local conditions = activityContent.conditions
			for condIndex = 1, #conditions do
				if conditions[condIndex] == condition then
					return conditions[condIndex]
				end
			end
		end
	else
		for index = 1, #activityContent.conditions do
			local condition = activityContent.conditions[index]
			if condition == condition then
				return condition
			end
		end
	end
end

--获取效果活动第几天
function ActivityMO.getDay(beganTime)
	local a1,a2 = os.date("*t",beganTime),os.date("*t",ManagerTimer.getTime())
	a1 = {year=a1.year,month=a1.month,day=a1.day}
	a2 = {year=a2.year,month=a2.month,day=a2.day}
	local day = (os.time(a2) - os.time(a1))/(3600*24)
	return day + 1
end

--检查效果活动是否有效
function ActivityMO.checkEffectActivity(act)
	if not db_activity_effect_[act.activityId] then
		return
	end
	local day = ActivityMO.getDay(act.beginTime)
	if not db_activity_effect_[act.activityId][day] then return end
	local item = db_activity_effect_[act.activityId][day]
	ActivityMO.activityContents_[act.activityId] = {}
	local ids = json.decode(item.effectId)
	ActivityMO.activityContents_[act.activityId].conditions = ids
	for k,v in ipairs(ids) do
		if not EffectBO.getEffectValid(v) then
			local time = os.date("*t",act.beginTime + day*24*3600)
			time.hour = 0
			time.min = 0
			time.sec = 0
			EffectBO.updateEffect({id=v,endTime=os.time(time)})
		end
	end
end

function ActivityMO.getWelFareByType(kind)
	if not kind then return db_act_welfare end
	local welData = {}
	for index=1,#db_act_welfare do
		local data = db_act_welfare[index]
		if data.type == kind then
			welData[#welData + 1] = data
		end
	end
	return welData
end

function ActivityMO.getWelFareDataByType(kind)
	local data = {}
	local param = ActivityMO.getWelFareByType()
	for index=1,#param do
		if param[index].type == kind then
			local tab = {v1 = index, v2 = 0}
			data[#data + 1] = tab
		end
	end

	if ActivityMO.welFare_ then
		for a,b in pairs(data) do
			for k,v in pairs(ActivityMO.welFare_) do
				if b.v1 == v.v1 then
					b.v2 = v.v2
				end
			end
		end
	end

	return data
end

function ActivityMO.isLevelActivityShow()
	local isShow = false
		
	if not ActivityMO.getActivityContentById(ACTIVITY_ID_LEVEL_RANK) then return isShow end
	local conditions = ActivityMO.getActivityContentById(ACTIVITY_ID_LEVEL_RANK).conditions
	if conditions then
		for index=1,#conditions do
			if conditions[index].status == 0 then
				isShow = true
				break
			end
		end
	end
	return isShow
end

function ActivityMO.getNewActivityList()
	local list = ActivityBO.getShowList()
	for k,v in ipairs(list) do
		if v.activityId == ACTIVITY_ID_LEVEL_RANK then
			table.remove(list, k)
		end
	end

	return list
end

function ActivityMO.getActNewPay2RatioMinMax()
	return act_pay_new_min_, act_pay_new_max_
end

function ActivityMO.getActNewPay2Ratio1(payId)
	return db_act_pay_new_[payId].ratio1
end

--军团活跃活动
function ActivityMO.getPatyWarById(awardId)
	if not awardId then return nil end
	local states = ActivityMO.getActivityContentById(ACTIVITY_ID_PARTY_LIVES).states
	local info = ActivityMO.getActivityContentById(ACTIVITY_ID_PARTY_LIVES).contents
	local data = db_act_party_war
	local records = {}
	for index=1,#data do
		if data[index].awardId == awardId then
			if states and states[index] then
				data[index].states = states[index]
				if data[index].Id == states[index].id then
					data[index].received = states[index].state
				end
			end

			if info and info[index] then
				data[index].info = info[index]
			end
			records[#records + 1] = data[index]
		end
	end
	return records
end