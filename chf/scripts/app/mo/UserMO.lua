
local s_lord_lv = require("app.data.s_lord_lv")
local s_lord_command = require("app.data.s_lord_command")
local s_lord_pros = require("app.data.s_lord_pros")
local s_lord_rank = require("app.data.s_lord_rank")
local s_system = require("app.data.s_system")
local s_express = require("app.data.s_express")
local s_fame = require("app.data.s_fame")
local s_function_plan = require("app.data.s_function_plan")

UserMO = {}

-- 玩家等级信息，以等级作为索引
local db_lord_lv_ = nil
-- 统率等级信息，以等级作为索引
local db_command_lv_ = nil
-- 繁荣度等级信息，以等级作为索引
local db_pros_lv_ = nil

local db_rank_lv_ = nil

local db_system_ = nil
UserMO.express = {}

local db_fame_ = {}
local db_function_plan = {}

local online_award_ = {60, 120, 300, 600, 1800, 3600, 7200} -- 领取各个在线奖励的倒计时

local db_fun = {}

------------------------------------------
--		SYSTEM 帐号在其他地方登录		--
------------------------------------------
UserMO.systemLoginErrorState = nil
UserMO.systemLoginErrorStr = nil 
UserMO.systemLoginErrorListener = nil

ITEM_KIND_EXP               = 1     -- EXP
ITEM_KIND_PROSPEROUS        = 2     -- 繁荣度
ITEM_KIND_FAME              = 3     -- 声望
ITEM_KIND_HONOR             = 4     -- 荣誉
ITEM_KIND_PROP              = 5     -- 道具
ITEM_KIND_EQUIP             = 7     -- 装备
ITEM_KIND_PART              = 8     -- 配件
ITEM_KIND_CHIP              = 9     -- 配件碎片
ITEM_KIND_MATERIAL          = 10    -- 配件材料。id对应关系 1.零件 2.记忆金属 3.设计蓝图 4.金属矿物 5.改造工具 6.改造图纸
ITEM_KIND_SCORE             = 11    -- 竞技场积分
ITEM_KIND_CONTRIBUTION      = 12    -- 军团贡献度
ITEM_KIND_HUANGBAO          = 13    -- 荒宝碎片
ITEM_KIND_TANK              = 14    -- 坦克
ITEM_KIND_HERO              = 15    -- 将领
ITEM_KIND_COIN              = 16    -- 金币
ITEM_KIND_RESOURCE          = 17    -- 资源。1.铁
ITEM_KIND_PARTY_CONSTRUCT   = 18    -- 军团建设度
ITEM_KIND_POWER         	= 19    -- 体力、能量
ITEM_KIND_RED_PACKET        = 20    -- 红包奖励
ITEM_KIND_PORTRAIT      	= 22  	-- 玩家头像
ITEM_KIND_MILITARY      	= 23  	-- 军工科技材料
ITEM_KIND_ENERGY_SPAR      	= 24  	-- 能晶
ITEM_KIND_EXPLOIT     	    = 25  	-- 功勋
ITEM_KIND_FORMATION     	= 26  	-- 编制经验
ITEM_KIND_CROSSSCORE     	= 27  	-- 跨服积分
ITEM_KIND_MEDAL_ICON        = 28  	-- 勋章
ITEM_KIND_MEDAL_CHIP    	= 29  	-- 勋章碎片
ITEM_KIND_MEDAL_MATERIAL    = 30 	-- 勋章材料
ITEM_KIND_AWAKE_HERO        = 31    -- 觉醒将领

ITEM_KIND_WEAPONRY_ICON     = 32  	-- 军备
ITEM_KIND_WEAPONRY_PAPER  	= 33 	-- 军备图纸
ITEM_KIND_WEAPONRY_MATERIAL = 34 	-- 军备材料
ITEM_KIND_WEAPONRY_EMPLOY   = 35 	-- 技工
ITEM_KIND_MILITARY_EXPLOIT	= 36    -- 军功
ITEM_KIND_ATTACK_EFFECT		= 37 	-- 战斗特效
ITEM_KIND_LABORATORY_RES	= 38 	-- 作战实验室

ITEM_KIND_HUNTER_COIN		= 39 	-- 赏金代币
-- ITEM_KIND_NEW_HERO			= 41 	-- 破罩将领

ITEM_KIND_TACTIC			        = 42 	-- 战术
ITEM_KIND_TACTIC_PIECE			    = 43 	-- 战术碎片
ITEM_KIND_TACTIC_MATERIAL			= 44 	-- 战术材料

-- 500+ 以后 单独作用与客户端
ITEM_KIND_WEAPONRY_SKILL	= 500 	-- 军备技能
ITEM_KIND_SKIN				= 501	-- 皮肤

ITEM_KIND_WEAPONRY_RANDOM   = 999999  --随机材料
ITEM_KIND_LEVEL				= 999998  --人物等级


ITEM_KIND_CHAR     			= 100  	-- 字符

ITEM_KIND_SCIENCE       	= 1007  -- 科技 
ITEM_KIND_BUILD         	= 1009  -- 建筑

ITEM_KIND_RANK          	= 1012  -- 军衔
ITEM_KIND_COMMAND       	= 1013  -- 统率
ITEM_KIND_MEDAL         	= 1014  -- 授勋
ITEM_KIND_SKILL         	= 1015  -- 技能
ITEM_KIND_PARTY_BUILD		= 1016	-- 军团建筑
ITEM_KIND_PARTY_LIVELY_TASK	= 1017	-- 军团活跃任务
ITEM_KIND_TASK				= 1018	-- 任务

ITEM_KIND_ATTRIBUTE     = 2000  -- 仅用于显示属性图标用
ITEM_KIND_EFFECT        = 2001  -- 增益
ITEM_KIND_ACCEL         = 2002  -- 加速.id含义: 1:建筑加速, 2坦克，3改装，4制作，5科技
ITEM_KIND_VIP           = 2003
ITEM_KIND_FIGHT_VALUE   = 2004  -- 只用于战斗力UI
ITEM_KIND_SEX           = 2005
ITEM_KIND_WORLD_RES     = 2006  -- 世界资源。资源的id和ITEM_KIND_RESOURCE公用, 6表示玩家建筑
ITEM_KIND_ARMY_TASK     = 2007  -- id:1行军，2返回，3采集，4驻军
ITEM_KIND_TOPUP			= 2008  --玩家累计充值金币
ITEM_KIND_MILITARY_MINE = 2009

-- 资源id
RESOURCE_ID_IRON    = 1    -- 铁
RESOURCE_ID_OIL     = 2    -- 石油
RESOURCE_ID_COPPER  = 3    -- 铜
RESOURCE_ID_SILICON = 4    -- 硅
RESOURCE_ID_STONE   = 5    -- 宝石

-- 加速的类型id
ACCEL_ID_BUILD   = 1
ACCEL_ID_TANK    = 2
ACCEL_ID_REFIT   = 3
ACCEL_ID_PRODUCT = 4 -- 制作
ALLEL_ID_SCIENCE = 5 -- 科技

-- 战斗力每项的id标识
FIGHT_ID_COMMAND = 1
FIGHT_ID_SKILL   = 2
FIGHT_ID_EQUIP_QUALITY = 3
FIGHT_ID_EQUIP_LEVEL = 4
FIGHT_ID_PART_QUALITY = 5
FIGHT_ID_PART_UP = 6 -- 配件强化
FIGHT_ID_PART_REFIT = 7
FIGHT_ID_SCIENCE_LEVEL = 8
FIGHT_ID_PARTY = 9
FIGHT_ID_ARMY = 10 -- 主力部队
FIGHT_ID_FULL = 11 -- 满编
FIGHT_ID_PROPS = 12

WORLD_ID_BUILD = 6 -- 世界中的玩家建筑

EQUIP_QUALITY_TYPE_NUMBER = 5 -- 装备品质种类数 5种 白绿蓝紫橙

SEX_MALE = 1  -- 男
SEX_FEMALE = 2 -- 女

-- 能量恢复时间
POWER_CYCLE_TIME = 30 * 60

POWER_MAX_VALUE  = 20 -- 能量的最大值

POWER_MAX_HAVE  = 100 -- 拥有最大能量值

PROSPEROUS_CYCLE_TIME = 1 * 60  -- 繁荣度恢复一点时间

COMMAND_UP_TAKE_COIN = 28 -- 使用金币提升统帅

POWER_BUY_NUM       = 5  -- 花费金币购买的点数

-- USER_FUNCTION_PLAN 用户功能代码
UFP_AIRSHIP		= 2 --飞艇
UFP_WEAPONRY	= 301 --军备
UFP_MILITARY	= 601 --军衔
UFP_WEAP_CHANGE = 302 --军备洗练
UFP_NEW_ACTIVE  = 801 --新活跃度
UFP_NEW_PLAYERBACK = 701 --老玩家回归
UFP_STAFF_CONFIG  = 602 --参谋配置
UFP_MAIL_SYNC   = 901 --邮箱优化
UFP_NEW_PLAYER_POWER   = 1001 --玩家总实力
UFP_SKIN_MGR	= 1101	-- 皮肤管理
UFP_HERO_FXZ	= 1201	-- 风行者
UFP_FRIGHTEN	= 1301 -- 战斗震慑
UFP_MEDAL_REFINE = 1401 --勋章精炼
UFP_WARWEAPON	= 1501 -- 战争武器
UFP_FIGHTER		= 1601 -- 战斗特效
UFP_LABORATORY	= 1701 -- 作战实验室 
UFP_LABORATORY_2= 1702 -- 作战实验室 - 兵种调配室
UFP_LABORATORY_3= 1703 -- 作战实验室 - 谍报机构
UFP_BOUNTY_HUNTER = 1801 -- 组队副本
UFP_CHANCE_EQUIP = 80 -- 抽装备概率公示开关
UFP_CHANCE_HERO = 81 -- 抽将领概率公示开关

SYSTEM_SOCKET_ACTIVITY_NO_FLUSHDATA = 1159 -- 活动数据未刷新（服务端来定字段）

-- 授勋相关信息(获得声望值，使用宝石还是金币，花费数量)
FAME_MEDAL_TAKE = {{10, 1, 1000}, {100, 2, 10}, {400, 2, 40}, {1200, 2, 100}}

UserMO.lordId_   = 0
UserMO.oldLordId_= 0
UserMO.nickName_ = ""  -- 昵称
UserMO.portrait_ = 1  -- 头像
UserMO.pendant_  = 0  -- 挂件
UserMO.level_    = 0  -- 玩家等级
UserMO.exp_      = 0  -- exp
UserMO.vip_      = 0
UserMO.topup_    = 0  -- 已充值金额

-- 位置坐标
-- UserMO.position_ = cc.p(0, 0)

UserMO.fightValue_ = 0  -- 战斗力
UserMO.coin_    = 0
UserMO.rank_    = 0    -- 军衔
UserMO.command_ = 0    -- 统帅等级
UserMO.fame_    = 0    -- 声望
UserMO.fameLevel_  = 0  -- 声望等级
UserMO.honor_      = 0  -- 荣誉

UserMO.prosperous_      = 0  -- 繁荣度
UserMO.maxProsperous_   = 0  -- 最大繁荣度，和繁荣等级相关
UserMO.prosperousLevel_ = 0  -- 繁荣度等级

UserMO.power_ = 0  -- 能量
UserMO.powerBuy_ = 0 -- 能量购买次数

UserMO.scout_ = 0   ---侦查水晶次数
UserMO.VerificationFailure=0 --侦察失败次数
UserMO.scoutCount=0          --侦察次数
UserMO.scoutValidate=false     --侦察是否验证

UserMO.canClickFame_ = false -- 能否领取声望
UserMO.canBuyFame_ = false -- 能否授勋

UserMO.sex_ = 1

UserMO.newerGift_ = 0 --是否领取过新手礼包

UserMO.equipWarhouse_ = 0   -- 装备仓库的容量

UserMO.resource_ = {}

UserMO.huangbao_ = 0  -- 荒宝碎片数量

UserMO.hunterCoin_ = 0  -- 赏金代币

UserMO.buildCount_ = 0 -- 购买的建造位

UserMO.newState = 0 --新手礼包领取状态 0未领取 1已领取

UserMO.onlineAccumTime_ = 0 -- 当日累计在线时间

UserMO.onlineCdTime_ = 0  -- 在线奖励倒计时
UserMO.onlineAwardIndex_ = 0 -- 在线奖励的奖励索引

UserMO.gm_ = 0 -- GM权限
UserMO.guider_ = 0 -- 新手指导员

UserMO.partyTipAward_ = 0 --军团加入奖励

UserMO.staffing_ = 0 -- 编制
UserMO.staffingLv_ = 0 -- 编制等级
UserMO.staffingExp_ = 0 -- 编制经验

UserMO.createRoleTime_ = 0 --玩家注册时间
UserMO.openServerDay = 0 --开服时间

UserMO.ruins = {isRuins=false,lordId=0,attackerName=""} --废墟信息

--IOS push评论推送
IOS_PUSH_VERSION = 999  --PUSH评论推送版本
IOS_PUSH_STATE_NO = 0  -- 未推送
IOS_PUSH_STATE_YES = 1 -- 已推送

UserMO.pushState = nil   --推送状态
UserMO.shouldPushTime = nil  --push时间点

UserMO.militaryRank_ = nil -- 军衔等级
UserMO.militaryExploit_ = 0 -- 军功


UserMO.worldMineExpConribDay = 0

UserMO.Crossscout_ = 0   ---跨服军事矿区侦查次数

---------------------------------------------
GAME_SETTING_FILE = "config_0753951"

UserMO.autoDefend = true -- 自动补充防御部队
UserMO.consumeConfirm = true -- 消费二次确认
UserMO.showBuildName = true -- 显示建筑名称
UserMO.showArmyLine = true -- 显示行军路线
UserMO.showPintUI = false -- 显示网络延迟
---------------------------------------------

UserMO.startCheckFight_ = false -- 是否开启检测战斗力

UserMO.tickTimer_ = nil
UserMO.refreshTimer_ = nil

UserMO.synResourceHandler_ = nil

UserMO.bubble_ = nil --玩家聊天气泡

------------------------------------------- 功能引导
local local_function_recode = "lfr"
UserMO._functionState = nil
LOCAL_FUNC_WARWEAPON_1 = 101
LOCAL_FUNC_WARWEAPON_2 = 102

------------------------------------------ 安全检测
UserMO.SynPlugInScoutMineView = nil
UserMO.SynPlugInScoutMineListener = nil

UserMO.userFightCheckSchedule = nil
UserMO.userFightCheckWait = false

UserMO.userStrengthCheckSchedule = nil

function UserMO.init()

	db_lord_lv_ = {}
	local records = DataBase.query(s_lord_lv)
	for index = 1, #records do
		local data = records[index]
		db_lord_lv_[data.lordLv] = data
	end

	db_command_lv_ = {}
	local records = DataBase.query(s_lord_command)
	for index = 1, #records do
		local data = records[index]
		db_command_lv_[data.commandLv] = data
	end

	db_pros_lv_ = {}
	local records = DataBase.query(s_lord_pros)
	for index = 1, #records do
		local data = records[index]
		db_pros_lv_[data.prosLv] = data
	end

	db_rank_lv_ = {}
	local records = DataBase.query(s_lord_rank)
	for index = 1, #records do
		local data = records[index]
		db_rank_lv_[data.rankId] = data
	end

	db_system_ = {}
	local records = DataBase.query(s_system)
	for index = 1, #records do
		local data = records[index]
		db_system_[data.id] = data
	end

	local records = DataBase.query(s_express)
	for index = 1, #records do
		local data = records[index]
		UserMO.express[data.id] = data
	end

	local records = DataBase.query(s_fame)
	for index = 1, #records do
		local data = records[index]
		db_fame_[data.fameLv] = data
	end

	db_function_plan = {}
	local records = DataBase.query(s_function_plan)
	for index = 1, #records do
		local data = records[index]
		db_function_plan[data.funId] = data
	end

	db_fun = {}

	if UserMO.systemLoginErrorListener then
		SocketReceiver.unregister("SynLoginElseWhere")
		UserMO.systemLoginErrorListener = nil
	end
	UserMO.updateSystemLoginError()

	-- 刷新数据
	if not UserBO.refreshCallbackHandler then
		UserBO.refreshCallbackHandler = Notify.register(LOCAL_USER_REFRESH_CLOCK, UserBO.refreshCallback)
	end
end

function UserMO.FuncList()
	return db_function_plan
end

-- 是否开服可用
-- true : 开服可用
-- false: 开服不可用
-- UFP_AIRSHIP		= 2 --飞艇
-- UFP_WEAPONRY		= 3 --军备
-- UFP_MILITARY		= 601 --军衔
-- UFP_WEAP_CHANGE = 301 --军备洗练
-- UFP_NEW_PLAYERBACK = 701 --老玩家回归
-- UFP_FRIGHTEN	= 1301 -- 战斗震慑
-- UFP_WARWEAPON	= 1501 -- 战争武器
-- UFP_FIGHTER		= 1601 -- 战斗特效
-- UFP_LABORATORY	= 1701 -- 作战实验室 
-- UFP_LABORATORY_2 = 1702 -- 作战实验室 - 兵种调配室
-- UFP_LABORATORY_3 = 1703 -- 作战实验室 - 谍报机构
function UserMO.queryFuncOpen(funcId)
	if db_fun[funcId] then
		return (db_fun[funcId] == 1)
	end
	local fb = db_function_plan[funcId]
	if not fb then return false end
	if type(fb.rules) == 'string' or type(fb.rules) == 'number'then
		local str = tostring(fb.rules)
		-- 1 全开 0 全关
		if string.len(str) == 1 then
			if str and str == "1" then
				db_fun[funcId] = 1
				return true
			end
		else
			local liststr = string.split(str,",")
			for index=1 , #liststr do
				local strs = string.split(liststr[index],"-")
				local str1 , str2 = tonumber(strs[1]) , tonumber(strs[2])
				if GameConfig.areaId >= str1 and GameConfig.areaId <= str2 then
					db_fun[funcId] = 1
					return true
				end
			end
		end
	end
	db_fun[funcId] = 0
	return false
end

function UserMO.querySystemId(id)
	return db_system_[id].value
end

function UserMO.queryLordByLevel(lordLv)
	return db_lord_lv_[lordLv]
end

function UserMO.queryMaxLordLevel()
	return #db_lord_lv_
end

function UserMO.queryCommandByLevel(commandLv)
	return db_command_lv_[commandLv]
end

function UserMO.queryMaxCommand()
	return #db_command_lv_
end

function UserMO.queryProsperousByLevel(propLv)
	return db_pros_lv_[propLv]
end

function UserMO.queryMaxProsperousLevel()
	return #db_pros_lv_
end

function UserMO.queryRankById(rankId)
	return db_rank_lv_[rankId]
end

function UserMO.queryMaxRank()
	return #db_rank_lv_
end

function UserMO.queryRankByLevel(level)
	for index=1,#db_rank_lv_ do
		local rankData = db_rank_lv_[index]
		if rankData.lordLv == level then
			return rankData
		end
	end
	return nil
end

function UserMO.getUpFameByLevel(fameLv)
	if not db_fame_[fameLv + 1] then
		return
	end
	return db_fame_[fameLv + 1].fame
end

function UserMO.getResource(kind, id)
	if kind == ITEM_KIND_COIN then return UserMO.coin_
	elseif kind == ITEM_KIND_RESOURCE then return UserMO.resource_[id]
	elseif kind == ITEM_KIND_POWER then return UserMO.power_
	elseif kind == ITEM_KIND_PROSPEROUS then return UserMO.prosperous_
	elseif kind == ITEM_KIND_FAME then return UserMO.fame_
	elseif kind == ITEM_KIND_EXP then return UserMO.exp_
	elseif kind == ITEM_KIND_HONOR then return UserMO.honor_
	elseif kind == ITEM_KIND_RANK then return UserMO.rank_
	elseif kind == ITEM_KIND_COMMAND then return UserMO.command_
	elseif kind == ITEM_KIND_SCORE then return ArenaMO.arenaScore_
	elseif kind == ITEM_KIND_HUANGBAO then return UserMO.huangbao_
	elseif kind == ITEM_KIND_HUNTER_COIN then return UserMO.hunterCoin_
	elseif kind == ITEM_KIND_MATERIAL then
		return PartMO.material_[id].count
	elseif kind == ITEM_KIND_TANK then
		local tank = TankMO.tanks_[id]
		if not tank then return 0
		else return tank.count end
	elseif kind == ITEM_KIND_PROP then
		local prop = PropMO.prop_[id]
		if prop then return prop.count
		else return 0 end
	elseif kind == ITEM_KIND_CHIP then
		local chip = PartMO.chip_[id]
		if chip then return chip.count
		else return 0 end
	elseif kind == ITEM_KIND_MEDAL_MATERIAL then
		local chip = MedalBO.matrials[id]
		return chip or 0
	elseif kind == ITEM_KIND_MEDAL_CHIP then
		local chip = MedalBO.chips[id]
		if chip then return chip
		else return 0 end
	elseif kind == ITEM_KIND_MILITARY then
		local po = OrdnanceBO.queryPropById(id)
		if po then return po.count
		else return 0 end
	elseif kind == ITEM_KIND_ENERGY_SPAR then
		local spar = EnergySparMO.energySpar_[id]
		if spar then return spar.count
		else return 0 end
	elseif kind == ITEM_KIND_WEAPONRY_PAPER then
		local spar = WeaponryBO.Weaponryprop[id]
		if spar then return spar.count
		else return 0 end
	elseif kind == ITEM_KIND_WEAPONRY_MATERIAL then
		local spar = WeaponryBO.Weaponryprop[id]
		if spar then return spar.count
		else return 0 end
	elseif kind == ITEM_KIND_LABORATORY_RES then
		local idl = LaboratoryMO.dataList[id]
		if idl then return idl.count
		else return 0 end
	elseif kind == ITEM_KIND_MILITARY_EXPLOIT then return UserMO.militaryExploit_
	elseif kind == ITEM_KIND_LEVEL then return UserMO.level_
	elseif kind == ITEM_KIND_CHAR then --kind 为 100
		if not ActivityCenterBO.prop_[id] then ActivityCenterBO.prop_[id] = {id = id, count = 0, kind = ITEM_KIND_CHAR} end
		return ActivityCenterBO.prop_[id].count
	elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
		if not TacticsMO.materials_[id] then return 0 end
		return TacticsMO.materials_[id]
	elseif kind == ITEM_KIND_TACTIC_PIECE then --战术碎片
		if not TacticsMO.pieces_[id] then return 0 end
		return TacticsMO.pieces_[id]
	end
end

function UserMO.addResources(resources)
	if not resources then return end

	local function add(kind, count, id)
		if count <= 0 then return 0 end
		local num = UserMO.getResource(kind, id)

		if kind == ITEM_KIND_COIN then
			UserMO.coin_ = UserMO.coin_ + count
			return 1
		elseif kind == ITEM_KIND_RESOURCE then
			UserMO.resource_[id] = UserMO.resource_[id] + count
			return 1
		elseif kind == ITEM_KIND_HONOR then
			UserMO.honor_ = UserMO.honor_ + count
			return 6
		elseif kind == ITEM_KIND_MATERIAL then
			if PartMO.material_[id] then 
				PartMO.material_[id].count = PartMO.material_[id].count + count 
				--TK统计 获得配件材料
				TKGameBO.onEvnt(TKText.eventName[13], {partId = id, count = count})
			end
			return 5
		elseif kind == ITEM_KIND_MEDAL_MATERIAL then
			if not MedalBO.matrials[id] then
				MedalBO.matrials[id] = count
			else
				MedalBO.matrials[id] = MedalBO.matrials[id] + count
			end
		elseif kind == ITEM_KIND_MEDAL_CHIP then
			if not MedalBO.chips[id] then
				MedalBO.chips[id] = count
			else
				MedalBO.chips[id] = MedalBO.chips[id] + count
			end
		elseif kind == ITEM_KIND_PROP then  -- 道具
			if PropMO.prop_[id] then 
				PropMO.prop_[id].count = PropMO.prop_[id].count + count
			else 
				PropMO.prop_[id] = {propId = id, count = count} 
			end
			--TK统计 获得道具
			TKGameBO.onEvnt(TKText.eventName[5], {propId = id, count = count})
			return 2
		elseif kind == ITEM_KIND_TANK then  -- 坦克
			if TankMO.tanks_[id] then TankMO.tanks_[id].count = TankMO.tanks_[id].count + count
			else TankMO.tanks_[id] = {tankId = id, count = count, rest = 0} end
			return 3
		elseif kind == ITEM_KIND_CHIP then -- 部件碎片
			if PartMO.chip_[id] then 
				PartMO.chip_[id].count = PartMO.chip_[id].count + count
			else 
				PartMO.chip_[id] = {chipId = id, count = count} 
			end
			--TK统计 获得配件碎片
			TKGameBO.onEvnt(TKText.eventName[11], {partId = id, count = count})
			return 4
		elseif kind == ITEM_KIND_SCORE then -- 竞技场积分
			ArenaMO.arenaScore_ = ArenaMO.arenaScore_ + count
			return 7
		elseif kind == ITEM_KIND_HUANGBAO then
			UserMO.huangbao_ = UserMO.huangbao_ + count
			return 8
		elseif kind == ITEM_KIND_HUNTER_COIN then
			UserMO.hunterCoin_ = UserMO.hunterCoin_ + count
			return 9
		elseif kind == ITEM_KIND_CONTRIBUTION then
			PartyMO.myDonate_ = PartyMO.myDonate_ + count
		elseif kind == ITEM_KIND_MILITARY then
			local po = OrdnanceBO.queryPropById(id)
			if po then
				po.count = po.count + count
			else
				OrdnanceBO.addProp({id=id,count=count})
			end
		elseif kind == ITEM_KIND_ENERGY_SPAR then
			if EnergySparMO.energySpar_[id] then 
				EnergySparMO.energySpar_[id].count = EnergySparMO.energySpar_[id].count + count
			else 
				EnergySparMO.energySpar_[id] = {stoneId = id, count = count} 
			end
			--TK统计 获得能晶数
			TKGameBO.onEvnt(TKText.eventName[32], {stoneId = id, count = count})
			return 4			
		elseif kind == ITEM_KIND_WEAPONRY_MATERIAL or  kind == ITEM_KIND_WEAPONRY_PAPER then    -- 军备材料 -- 军备图纸
  			if WeaponryBO.Weaponryprop == nil then
				WeaponryBO.Weaponryprop = {}
			end
			local cur = WeaponryBO.Weaponryprop[id] or 0 
			if cur > 0 then
				WeaponryBO.Weaponryprop[id] = cur + count
			end
		elseif kind == ITEM_KIND_MILITARY_EXPLOIT then		-- 军功
			local cur = UserMO.militaryExploit_
			if cur > 0 then
				UserMO.militaryExploit_ = cur + count
			end
		elseif kind == ITEM_KIND_LABORATORY_RES then
			local idl = LaboratoryMO.dataList[id]
			if idl then 
				idl.count = idl.count + count
			end
		elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
			if not TacticsMO.materials_[id] then
				TacticsMO.materials_[id] = count
			else
				TacticsMO.materials_[id] = TacticsMO.materials_[id] + count
			end
		elseif kind == ITEM_KIND_TACTIC_PIECE then --战术碎片
			if not TacticsMO.pieces_[id] then
				TacticsMO.pieces_[id] = count
			else
				TacticsMO.pieces_[id] = TacticsMO.pieces_[id] + count
			end
		end
		return 0
	end

	local change = {}
	for key, resource in pairs(resources) do
		local value = add(resource.kind, resource.count, resource.id)
		change[value] = true
	end

	-- 资源发生了变化
	if change[1] then Notify.notify(LOCAL_RES_EVENT, {tag = 1}) end  -- tag = 1,资源是增加
	-- 道具发生了变化
	if change[2] then Notify.notify(LOCAL_PROP_EVENT) end
	-- 坦克发生了变化
	if change[3] then Notify.notify(LOCAL_TANK_EVENT) end
	-- 积分
	if change[7] then Notify.notify(LOCAL_SCORE_EVENT) end
	-- 9 用于装备
end

function UserMO.addResource(kind, count, id)
	if count <= 0 then return -1 end
	UserMO.addResources({{kind = kind, count = count, id = id}})
end

-- 批量减少资源
function UserMO.reduceResources(resources)
	if not resources then return end

	local function reduce(kind, count, id)
		if count <= 0 then return 0 end

		local num = UserMO.getResource(kind, id)
		if num < count then return 0 end

		if kind == ITEM_KIND_COIN then
			UserMO.coin_ = UserMO.coin_ - count
			--任务计数
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COIN_COST,type = 1})

			if ActivityBO.isValid(ACTIVITY_ID_COST_GOLD) then ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_COST_GOLD) end
			if ActivityBO.isValid(ACTIVITY_ID_CON_COST_GOLD) then ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_CON_COST_GOLD) end
			return 1
		elseif kind == ITEM_KIND_RESOURCE then
			UserMO.resource_[id] = UserMO.resource_[id] - count
			return 1
		elseif kind == ITEM_KIND_MATERIAL then
			PartMO.material_[id].count = PartMO.material_[id].count - count
			--TK统计 消耗配件材料
			TKGameBO.onEvnt(TKText.eventName[14], {partId = id, count = count})
			return 5
		elseif kind == ITEM_KIND_PROP then  -- 道具
			if PropMO.prop_[id] then
				PropMO.prop_[id].count = PropMO.prop_[id].count - count
				--TK统计 消耗道具
				TKGameBO.onEvnt(TKText.eventName[6], {propId = id, count = count})
				TKGameBO.onUse(PropMO.getPropName(id), count)
				return 2
			end
		elseif kind == ITEM_KIND_TANK then  -- 坦克
			if TankMO.tanks_[id] then
				TankMO.tanks_[id].count = TankMO.tanks_[id].count - count
				return 3
			end
		elseif kind == ITEM_KIND_CHIP then -- 部件碎片
			if PartMO.chip_[id] then
				PartMO.chip_[id].count = PartMO.chip_[id].count - count
				--TK统计 消耗配件碎片
				TKGameBO.onEvnt(TKText.eventName[12], {partId = id, count = count})
				return 4
			end
		elseif kind == ITEM_KIND_MEDAL_CHIP then
			if MedalBO.chips[id] then
				MedalBO.chips[id] = MedalBO.chips[id] - count
			end
		elseif kind == ITEM_KIND_HUANGBAO then
			UserMO.huangbao_ = UserMO.huangbao_ - count
			return 8
		elseif kind == ITEM_KIND_HUNTER_COIN then
			UserMO.hunterCoin_ = UserMO.hunterCoin_ - count
			return 9
		elseif kind == ITEM_KIND_ENERGY_SPAR then
			if EnergySparMO.energySpar_[id] then
				EnergySparMO.energySpar_[id].count = EnergySparMO.energySpar_[id].count - count
				--TK统计 消耗配件碎片
				TKGameBO.onEvnt(TKText.eventName[33], {stoneId = id, count = count})
				return 4
			end	
		elseif kind == ITEM_KIND_WEAPONRY_ICON then    	-- 军备
			
  		elseif kind == ITEM_KIND_WEAPONRY_MATERIAL or  kind == ITEM_KIND_WEAPONRY_PAPER then    -- 军备材料 -- 军备图纸
  			if WeaponryBO.Weaponryprop == nil then
				WeaponryBO.Weaponryprop = {}
			end
			if WeaponryBO.Weaponryprop[id] then
				local cur = WeaponryBO.Weaponryprop[id].count
				WeaponryBO.Weaponryprop[id].count = cur - count
			end
		elseif kind == ITEM_KIND_MILITARY_EXPLOIT then		-- 军功
			local cur = UserMO.militaryExploit_
			if cur > 0 then
				UserMO.militaryExploit_ = cur - count
			end
		elseif kind == ITEM_KIND_LABORATORY_RES then
			local idl = LaboratoryMO.dataList[id]
			if idl then 
				local cur = idl.count - count
				if cur < 0 then cur = 0 end
				idl.count = cur
			end
		elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
			if not TacticsMO.materials_[id] then
				gprint(":错误的id--------------------",id)
			else
				TacticsMO.materials_[id] = TacticsMO.materials_[id] - count
			end
		elseif kind == ITEM_KIND_TACTIC_PIECE then --战术碎片
			if not TacticsMO.pieces_ then
				gprint(":错误的id--------------------",id)
			else
				TacticsMO.pieces_[id] = TacticsMO.pieces_[id] - count
			end
		end
		return 0
	end

	local change = {}
	for key, resource in pairs(resources) do
		local value = reduce(resource.kind, resource.count, resource.id)
		change[value] = true
	end

	-- 资源发生了变化
	if change[1] then Notify.notify(LOCAL_RES_EVENT, {tag = 2}) end  -- tag = 2,资源是减少
	-- 道具发生了变化
	if change[2] then Notify.notify(LOCAL_PROP_EVENT) end
	-- 坦克发生了变化
	if change[3] then Notify.notify(LOCAL_TANK_EVENT) end
	-- 9 用于装备
end

-- 只用减少一个资源
function UserMO.reduceResource(kind, count, id)
	if count <= 0 then return -1 end
	UserMO.reduceResources({{kind = kind, count = count, id = id}})
end

-- 设置资源的数量，资源的数量被重置
function UserMO.updateResources(resources)
	if not resources then return end

	local function update(kind, count, id)
		local delta = {}
		delta.kind = kind
		delta.id = id

		if kind == ITEM_KIND_COIN then
			if UserMO.coin_ ~= count then
				delta.count = count - UserMO.coin_
				UserMO.coin_ = count
				if delta.count < 0 then
					--任务计数
					TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COIN_COST,type = 1})
				end

				if ActivityBO.isValid(ACTIVITY_ID_COST_GOLD) then ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_COST_GOLD) end
				if ActivityBO.isValid(ACTIVITY_ID_CON_COST_GOLD) then ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_CON_COST_GOLD) end
				return 1, delta
			end
		elseif kind == ITEM_KIND_RESOURCE then
			if UserMO.resource_[id] ~= count then
				delta.count = count - UserMO.resource_[id]
				UserMO.resource_[id] = count
				return 1, delta
			end
		elseif kind == ITEM_KIND_MATERIAL then
			if PartMO.material_[id].count ~= count then
				delta.count = count - PartMO.material_[id].count
				if delta.count > 0 then
					--TK统计 获得配件碎片
					TKGameBO.onEvnt(TKText.eventName[13], {partId = id, count = delta.count})
				elseif delta.count < 0 then
					--TK统计 消耗配件碎片
					TKGameBO.onEvnt(TKText.eventName[14], {partId = id, count = -delta.count})
				end
				PartMO.material_[id].count = count
				return 5, delta
			end
		elseif kind == ITEM_KIND_PROP then  -- 道具
			if not PropMO.prop_[id] then PropMO.prop_[id] = {propId = id, count = 0} end

			if PropMO.prop_[id].count ~= count then
				delta.count = count - PropMO.prop_[id].count
				if delta.count > 0 then
					--TK统计 获得道具
					TKGameBO.onEvnt(TKText.eventName[5], {propId = id, count = delta.count})
				elseif delta.count < 0 then
					--TK统计 消耗道具
					TKGameBO.onEvnt(TKText.eventName[6], {propId = id, count = -delta.count})
					TKGameBO.onUse(PropMO.getPropName(id), -delta.count)
				end
				PropMO.prop_[id].count = count
				return 2, delta
			end
		elseif kind == ITEM_KIND_TANK then -- 坦克
			if not TankMO.tanks_[id] then TankMO.tanks_[id] = {tankId = id, count = 0, rest = 0} end

			if TankMO.tanks_[id].count ~= count then
				delta.count = count - TankMO.tanks_[id].count
				TankMO.tanks_[id].count = count
				return 3, delta
			end
		elseif kind == ITEM_KIND_CHIP then -- 配件碎片
			if not PartMO.chip_[id] then PartMO.chip_[id] = {chipId = id, count = 0} end

			if PartMO.chip_[id].count ~= count then
				delta.count = count - PartMO.chip_[id].count
				if delta.count > 0 then
					--TK统计 获得配件碎片
					TKGameBO.onEvnt(TKText.eventName[11], {partId = id, count = delta.count})
				elseif delta.count < 0 then
					--TK统计 消耗配件碎片
					TKGameBO.onEvnt(TKText.eventName[12], {partId = id, count = -delta.count})
				end
				PartMO.chip_[id].count = count
				return 4, delta
			end
		elseif kind == ITEM_KIND_MEDAL_CHIP then
			if MedalBO.chips[id] then
				MedalBO.chips[id] = count
			end
		elseif kind == ITEM_KIND_SCORE then
			delta.count = count - ArenaMO.arenaScore_
			ArenaMO.arenaScore_ = count
			return 7, delta
		elseif kind == ITEM_KIND_MILITARY then
			local po = OrdnanceBO.queryPropById(id)
			if po and po.count ~= count then
				delta.count = count - po.count
				po.count = count
			else
				OrdnanceBO.addProp({id=id,count=count})
			end
		elseif kind == ITEM_KIND_MEDAL_MATERIAL then
			MedalBO.matrials[id] = count
		elseif kind == ITEM_KIND_CHAR then
			if not ActivityCenterBO.prop_[id] then ActivityCenterBO.prop_[id] = {id = id, count = 0, kind = ITEM_KIND_CHAR} end
			if ActivityCenterBO.prop_[id].count ~= count then
				delta.count = count - ActivityCenterBO.prop_[id].count
				ActivityCenterBO.prop_[id].count = count
				return ITEM_KIND_CHAR, delta
			end
		elseif kind == ITEM_KIND_WEAPONRY_ICON then    	-- 军备
			-- local data = resources
			-- for k,v in pairs(data) do
			-- 	WeaponryMO.WeaponryList[v.keyId] = v
			-- end
  		elseif kind == ITEM_KIND_WEAPONRY_MATERIAL or  kind == ITEM_KIND_WEAPONRY_PAPER then    -- 军备材料 -- 军备图纸
			if WeaponryBO.Weaponryprop == nil then
				WeaponryBO.Weaponryprop = {}
			end
			local data = resources
			for k,v in pairs(data) do
				WeaponryBO.Weaponryprop[v.id] = v
			end
		elseif kind == ITEM_KIND_MILITARY_EXPLOIT then		-- 军功
			if count then
				UserMO.militaryExploit_ = count
			end
		elseif kind == ITEM_KIND_LABORATORY_RES then 		-- 研究院
			local cur = LaboratoryMO.dataList[id]
			local out = {}
			out.id = id
			out.count = count
			if cur and out.count >= cur.count then
				delta.count = out.count - cur.count
			else
				delta.count = out.count
			end
			LaboratoryMO.dataList[id] = out
			return 0 , delta
		elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
			if not TacticsMO.materials_[id] then
				gprint(":错误的id--------------------",id)
			else
				TacticsMO.materials_[id] = count
			end
		elseif kind == ITEM_KIND_TACTIC_PIECE then --战术碎片
			if not TacticsMO.pieces_ then
				gprint(":错误的id--------------------",id)
			else
				TacticsMO.pieces_[id] = count
			end
		elseif kind == ITEM_KIND_ENERGY_SPAR then  --能晶
			if EnergySparMO.energySpar_[id] then
				EnergySparMO.energySpar_[id].count = count
			end
		end
		return 0
	end
	local change = {}
	local dt = {}
	for key, resource in pairs(resources) do
		local value, delta = update(resource.kind, resource.count, resource.id)
		change[value] = true
		dt[#dt + 1] = delta
	end

	-- 资源发生了变化
	if change[1] then Notify.notify(LOCAL_RES_EVENT, {tag = 3}) end  -- tag = 3,资源是更新
	-- 道具发生了变化
	if change[2] then Notify.notify(LOCAL_PROP_EVENT) end
	-- 坦克发生了变化
	if change[3] then Notify.notify(LOCAL_TANK_EVENT) end
	-- 配件碎片发生了变化
	if change[4] then end
	-- 零件、蓝图、矿物、工具等等发生了变化
	if change[5] then end
	-- 积分
	if change[7] then Notify.notify(LOCAL_SCORE_EVENT) end
	-- 9 用于装备

	return dt
end

function UserMO.updateResource(kind, count, id)
	local delta = UserMO.updateResources({{kind = kind, count = count, id = id}})
	return delta
end

-- 用于添加exp等可提升等级的属性值
-- 返回最新的等级、经验、以及是否有升级
function UserMO.addUpgradeResouce(kind, count, id)
	if count <= 0 then
		error("[UserMO] add upgrade resource. count is ERROR.", count, "kind:", kind, "id:", id)
	end

	if kind == ITEM_KIND_EXP then  -- 添加经验
		local maxLevel = UserMO.queryMaxLordLevel()

		--拇指广告经验加成
		if ServiceBO.muzhiAdPlat() and MuzhiADMO.ExpAddADTime > 0 then
			count = math.floor(count * (1 + MuzhiADMO.ExpAddADTime * MZAD_EXPADD_FACTOR / 100))
			print(count,"exp add ++++++++++++++++++++++++++")
		end
		
		local newExp = UserMO.exp_ + count
		local copyLevel = UserMO.level_
		local curLevel = UserMO.level_

		if curLevel >= maxLevel then
			UserMO.exp_ = newExp
			return UserMO.level_, UserMO.exp_, false 
		end

		local needExp = UserMO.queryLordByLevel(UserMO.level_ + 1).needExp
		if newExp < needExp then -- 没有升级
			UserMO.exp_ = newExp
			Notify.notify(LOCAL_EXP_EVENT)
			return UserMO.level_, UserMO.exp_, false
		end
		
		while newExp >= needExp do  -- 升级了
			curLevel = curLevel + 1
			newExp = newExp - needExp

			UserMO.level_ = curLevel
			--TK统计 设定等级
			TKGameBO.setLevel(UserMO.level_)
			UserMO.exp_ = newExp

			-- 达到装备的上限
			if curLevel >= maxLevel then
				UserMO.exp_ = 0
				break
			end
			needExp = UserMO.queryLordByLevel(UserMO.level_ + 1).needExp

			--如果升到2级同时没有坐标则完成引导，获取坐标
			if UserMO.level_ == 2 and (WorldMO.pos_.x < 0 or WorldMO.pos_.y < 0) then
				NewerBO.asynDoneGuide()
			end
			--拇指玩和草花的升级统计
			if GameConfig.environment == "zty_client" or GameConfig.environment == "chpub_client" or GameConfig.environment == "chYh_client"
				or GameConfig.environment == "weiuu_client" or GameConfig.environment == "37wan_client" or GameConfig.environment == "muzhiJh_client" 
				or GameConfig.environment == "chpub_hj4_client" or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "mz_appstore" 
				or GameConfig.environment == "muzhi_49" or GameConfig.environment == "mztkwz_client" or GameConfig.environment == "muzhiJhly_client" 
				or GameConfig.environment == "mztkjjylfc_appstore" or GameConfig.environment == "ztyLy_client" or GameConfig.environment == "mztkjjhwcn_appstore" 
				or GameConfig.environment == "n_uc_client" or GameConfig.environment == "chpubNew_client" or GameConfig.environment == "mztkjjylfcba_appstore" 
				or GameConfig.environment == "mzTkjjQysk_appstore" or GameConfig.environment == "muzhiU8ly_client" or GameConfig.environment == "muzhiJhYyb_client"
				or GameConfig.environment == "aile_client" or GameConfig.environment == "muzhiTkjj_client" or GameConfig.environment == "youlong_client" 
				or GameConfig.environment == "mzGhgzh_appstore" or GameConfig.environment == "chhjfc_gp_client" or GameConfig.environment == "chhjfc_uc_client"
				or GameConfig.environment == "chhjfc_360_client" or GameConfig.environment == "muzhiJhYyb1_client" or GameConfig.environment == "chCjzjtkzz_appstore" 
				or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" then
				ServiceBO.userLevelUp()
			end
			
		end
		UserBO.triggerFightCheck()  -- 等级提升可能会开放战斗阵型位置，从而影响战斗力

		TankBO.checkFormationUnlock(copyLevel, UserMO.level_) -- 判断阵型是否有位置解锁

		PartBO.checkPositionUnlock(copyLevel, UserMO.level_)

		ActivityBO.trigger(ACTIVITY_ID_LEVEL_RANK)

		Notify.notify(LOCAL_EXP_EVENT)
		Notify.notify(LOCAL_LEVEL_EVENT)
		return UserMO.level_, UserMO.exp_, true
	elseif kind == ITEM_KIND_FAME then -- 声望
		local newFame = UserMO.fame_ + count
		local curLevel = UserMO.fameLevel_

		local needFame = UserMO.getUpFameByLevel(curLevel)
		if not needFame then
			return
		end
		if newFame < needFame then  -- 没有升级
			UserMO.fame_ = newFame
			Notify.notify(LOCAL_FAME_EVENT)
			return UserMO.fameLevel_, UserMO.fame_, false
		end

		while newFame >= needFame do
			curLevel = curLevel + 1
			newFame = newFame - needFame

			UserMO.fameLevel_ = curLevel
			UserMO.fame_ = newFame

			needFame = UserMO.getUpFameByLevel(UserMO.fameLevel_)
			if not needFame then break end
			--任务计数
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_FAME,type = 1})
		end
		Notify.notify(LOCAL_FAME_EVENT)
		return UserMO.fameLevel_, UserMO.fame_, true
	elseif kind == ITEM_KIND_TOPUP then --累计充值金额
		UserMO.topup_ = UserMO.topup_ + count
		local newVip = VipMO.getVipByTopup(UserMO.topup_)
		-- if newVip > UserMO.vip_ then
		-- 	--达到vip专属客服等级
		-- 	if newVip >= PERSONAL_SERVICE_VIP and not RechargeBO.getVipServState() then
		-- 		require("app.dialog.VipServiceDialog").new():push()
		-- 		RechargeBO.saveVipServState()
		-- 	end
		-- end --vip升级

		UserMO.vip_ = newVip
	end
end

-- 用于添加exp等可提升等级的属性值
-- 由于这些属性是由等级值和等级下的具体值两个部分组成，所有需要传递level和value两个值
function UserMO.updateUpgradeResource(kind, level, value, id)
	if kind == ITEM_KIND_EXP then
	elseif kind == ITEM_KIND_FAME then
		gprint("[UserMO] updateUpgradeResource:level:", level, "value:", value)
		local oldFame = UserMO.fame_
		local oldLevel = UserMO.fameLevel_

		UserMO.fame_ = value
		UserMO.fameLevel_ = level

		local totalFame = 0

		local deltaLv = UserMO.fameLevel_ - oldLevel
		for index = oldLevel, (UserMO.fameLevel_ - 1) do
			if UserMO.getUpFameByLevel(index) then
				totalFame = totalFame + UserMO.getUpFameByLevel(index)
			end
		end

		totalFame = totalFame - oldFame + UserMO.fame_

		local up = false
		if UserMO.fameLevel_ ~= oldLevel then 
			up = true 
			local upLv = UserMO.fameLevel_ - oldLevel
			if upLv > 0 then
				for index = 1,upLv do
					--任务计数
					TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_FAME,type = 1})
				end
			end
		end

		Notify.notify(LOCAL_FAME_EVENT)
		return UserMO.fameLevel_, UserMO.fame_, up, totalFame
	end
end

-- 专门用于添加体力、繁荣度等有定时器恢复的属性值
-- force：是否强制添加。如果为false，需要判断属性是否达到了上限，如果达到了上限，则为上限值。
function UserMO.addCycleResource(kind, count, force)
	if count < 0 then return false end

	local delta = {}
	delta.kind = kind
	delta.id = 0

	if kind == ITEM_KIND_POWER then
		delta.count = UserMO.power_
		UserMO.power_ = UserMO.power_ + count

		if not force then
			if UserMO.power_ > POWER_MAX_VALUE then UserMO.power_ = POWER_MAX_VALUE end
		end

		if UserMO.power_ > POWER_MAX_HAVE then UserMO.power_ = POWER_MAX_HAVE end

		delta.count = UserMO.power_ - delta.count

		Notify.notify(LOCAL_POWER_EVENT)
	elseif kind == ITEM_KIND_PROSPEROUS then
		delta.count = UserMO.prosperous_
		UserMO.prosperous_ = UserMO.prosperous_ + count

		if UserMO.prosperous_ > UserMO.maxProsperous_ then UserMO.prosperous_ = UserMO.maxProsperous_ end

		delta.count = UserMO.prosperous_ - delta.count

		local old = UserMO.prosperousLevel_
		UserMO.prosperousLevel_ = UserBO.getProsperousLevel(UserMO.prosperous_)  -- 更新繁荣度等级
		if old ~= UserMO.prosperousLevel_ then  -- 繁荣度等级发生了变化
			UserBO.triggerFightCheck()
		end

		Notify.notify(LOCAL_PROSPEROUS_EVENT)
	end

	UserBO.updateCycleTime(kind)
	return true, delta
end

function UserMO.reduceCycleResource(kind, count)
	if count < 0 then return false end

	if kind == ITEM_KIND_POWER then
		if count > UserMO.power_  then return false end

		UserMO.power_ = UserMO.power_ - count

		Notify.notify(LOCAL_POWER_EVENT)
	elseif kind == ITEM_KIND_PROSPEROUS then
		if count > UserMO.prosperous_ then return false end

		UserMO.prosperous_ = UserMO.prosperous_ - count

		local old = UserMO.prosperousLevel_
		UserMO.prosperousLevel_ = UserBO.getProsperousLevel(UserMO.prosperous_)  -- 更新繁荣度等级
		if old ~= UserMO.prosperousLevel_ then  -- 繁荣度等级发生了变化
			UserBO.triggerFightCheck()
		end

		Notify.notify(LOCAL_PROSPEROUS_EVENT)
	end

	local delta = {}
	delta.kind = kind
	delta.count = -count

	UserBO.updateCycleTime(kind)
	return true, delta
end

function UserMO.updateCycleResource(kind, count)
	local delta = {}

	if kind == ITEM_KIND_POWER then
		if count == UserMO.power_ then return false end
		delta.kind = kind
		delta.count = count - UserMO.power_

		UserMO.power_ = count
		Notify.notify(LOCAL_POWER_EVENT)
	elseif kind == ITEM_KIND_PROSPEROUS then
		if count == UserMO.prosperous_ then return false end
		delta.kind = kind
		delta.count = count - UserMO.prosperous_

		UserMO.prosperous_ = count

		local old = UserMO.prosperousLevel_
		UserMO.prosperousLevel_ = UserBO.getProsperousLevel(UserMO.prosperous_)  -- 更新繁荣度等级
		if old ~= UserMO.prosperousLevel_ then  -- 繁荣度等级发生了变化
			UserBO.triggerFightCheck()
		end

		Notify.notify(LOCAL_PROSPEROUS_EVENT)
	end

	UserBO.updateCycleTime(kind)
	return true, delta
end

function UserMO.getResourceData(kind, id)
	local data = {}
	kind = kind or ""
	id = id or 0
	data.kind = kind
	data.id = id

	if kind == ITEM_KIND_COIN then
		data.name = CommonText.item[1][1]
		data.name2 = CommonText.item[1][2]
	elseif kind == ITEM_KIND_EXPLOIT then
		data.name = CommonText.item[16][1]
	elseif kind == ITEM_KIND_FORMATION then
		data.name = CommonText.item[17][1]
	elseif kind == ITEM_KIND_CROSSSCORE then
		data.name = CommonText.item[18][1]
	elseif kind == ITEM_KIND_EFFECT then
		data.name = CommonText[135]
		local eb = EffectMO.queryEffectById(id)
		if eb then
			data.name = eb.name
		end
	elseif kind == ITEM_KIND_EXP then
		data.name = "EXP"
	elseif kind == ITEM_KIND_RESOURCE then
		if id == RESOURCE_ID_IRON then
			data.name = CommonText.item[2][1]
			data.name2 = CommonText.item[2][2]
		elseif id == RESOURCE_ID_OIL then
			data.name = CommonText.item[3][1]
			data.name2 = CommonText.item[3][2]
		elseif id == RESOURCE_ID_COPPER then
			data.name = CommonText.item[4][1]
			data.name2 = CommonText.item[4][2]
		elseif id == RESOURCE_ID_SILICON then
			data.name = CommonText.item[5][1]
			data.name2 = CommonText.item[5][2]
		elseif id == RESOURCE_ID_STONE then
			data.name = CommonText.item[6][1]
			data.name2 = CommonText.item[6][2]
			data.desc = CommonText.item[6][3]
		end
	elseif kind == ITEM_KIND_MATERIAL then
		local prop = PartMO.queryMatrialById(id)
		data.name = prop.name
		data.quality = prop.quality
		data.desc = prop.dec
	elseif kind == ITEM_KIND_POWER then -- 体力、能量
		data.name = CommonText[107]
	elseif kind == ITEM_KIND_PROSPEROUS then
		data.name = CommonText[78][1]
		data.name2 = CommonText[78][2]  -- 繁荣度
	elseif kind == ITEM_KIND_FAME then -- 声望
		data.name = CommonText[110][1]
		data.name2 = CommonText[110][2]  -- 声望值
	elseif kind == ITEM_KIND_PROP or kind == ITEM_KIND_RED_PACKET then  -- 道具
		local propDB = PropMO.queryPropById(id)
		data.name = PropMO.getPropName(id)
		data.name2 = PropMO.queryPropById(id).propName
		data.quality = propDB.color
		data.desc = propDB.desc
	elseif kind == ITEM_KIND_EQUIP then  -- 装备
		local equip = EquipMO.queryEquipById(id)
		if equip then
			data.name = equip.equipName
			data.name2 = EquipBO.getEquipNameById(equip.equipId)
			data.quality = equip.quality
		end
	elseif kind == ITEM_KIND_PART or kind == ITEM_KIND_CHIP then
		local part = PartMO.queryPartById(id)
		if part then
			data.name = part.partName
			data.quality = part.quality + 1
		end
	elseif kind == ITEM_KIND_SCORE then -- 竞技场积分
		data.name = CommonText.item[13][1]
		data.quality = 1
	elseif kind == ITEM_KIND_FIGHT_VALUE then -- 战斗力
		data.name = CommonText.item[14][id]
		data.quality = 1
	elseif kind == ITEM_KIND_WORLD_RES or kind == ITEM_KIND_MILITARY_MINE then
		if id == RESOURCE_ID_IRON then
			data.name = CommonText.item[2][1]
			data.name2 = CommonText.item[2][2]
		elseif id == RESOURCE_ID_OIL then
			data.name = CommonText.item[3][1]
			data.name2 = CommonText.item[3][2]
		elseif id == RESOURCE_ID_COPPER then
			data.name = CommonText.item[4][1]
			data.name2 = CommonText.item[4][2]
		elseif id == RESOURCE_ID_SILICON then
			data.name = CommonText.item[5][1]
			data.name2 = CommonText.item[5][2]
		elseif id == RESOURCE_ID_STONE then
			data.name = CommonText.item[6][1]
			data.name2 = CommonText.item[6][2]
			data.desc = CommonText.item[6][3]
		end
	elseif kind == ITEM_KIND_HUANGBAO then
		data.name = CommonText.item[15][1]
		data.quality = 1
	elseif kind == ITEM_KIND_HUNTER_COIN then
		data.name = CommonText.item[19][1]
		data.quality = 1
	elseif kind == ITEM_KIND_TANK then
		local tankDB = TankMO.queryTankById(id)
		data.name = tankDB.name
		data.quality = tankDB.grade
	elseif kind == ITEM_KIND_HERO or kind == ITEM_KIND_AWAKE_HERO then
		local heroDB = HeroMO.queryHero(id)
		data.name = heroDB.heroName
		data.quality = heroDB.star
	elseif kind == ITEM_KIND_PARTY_CONSTRUCT then
		data.name = CommonText[668]
	elseif kind == ITEM_KIND_MILITARY then
		local po = OrdnanceMO.queryMaterialById(id)
		data.name = po.name
		data.desc = po.desc
		data.quality = po.quality
	elseif kind == ITEM_KIND_CHAR then
		local po = PropMO.queryActPropById(id)
		data.name = po.name
		data.desc = po.desc
		data.quality = po.quality
		data.price = po.price
		
	elseif kind == ITEM_KIND_ENERGY_SPAR then
		local db = EnergySparMO.queryEnergySparById(id)
		local attribute = AttributeBO.getAttributeData(db.attrId, db.attrValue)
		data.name = db.stoneName .. "Lv." .. db.level
		data.desc = string.format(CommonText[954], attribute.strValue, attribute.name)
		data.quality = db.quite		
	elseif kind == ITEM_KIND_MEDAL_ICON or kind == ITEM_KIND_MEDAL_CHIP then
		local part = MedalMO.queryById(id)
		if part then
			data.name = part.medalName
			data.quality = part.quality
		end
	elseif kind == ITEM_KIND_MEDAL_MATERIAL then
		local prop = MedalMO.queryPropById(id)
		if prop then
			data.name = prop.name
			data.quality = prop.quality
			data.desc = prop.dec
		end
	elseif kind == ITEM_KIND_WEAPONRY_ICON then    	-- 军备
		local part = WeaponryMO.queryById(id)
		if part then
			data.name = part.name
			data.pos = part.pos
			data.quality = part.quality
		end
	elseif kind == ITEM_KIND_WEAPONRY_PAPER then    	-- 军备图纸
		local part = WeaponryMO.queryPaperById(id)
		if part then
			data.name = part.name
			data.desc = part.desc
			data.quality = part.quality
		end
	elseif kind == ITEM_KIND_WEAPONRY_MATERIAL then    -- 军备材料
		local part = WeaponryMO.queryPaperById(id)
		if part then
			data.name = part.name
			data.desc = part.desc
			data.quality = part.quality or 1
		end
	elseif kind == ITEM_KIND_MILITARY_EXPLOIT then		-- 军功
		data.name = CommonText[1017][1]
		data.desc = CommonText[1017][4]
	elseif kind == ITEM_KIND_LEVEL then
		data.name = CommonText[113]
		data.desc = CommonText[113]
	-- elseif kind == ITEM_KIND_SKIN then
	-- 	local skindata = PropMO.queryPropById(id)
	-- 	data.name = skindata.propName
	-- 	data.desc = skindata.desc
	-- 	data.color = skindata.color
	elseif kind == ITEM_KIND_WEAPONRY_RANDOM then		--军备随机材料
		data.name = "随机材料"
		data.quality = 1
	elseif kind == ITEM_KIND_PORTRAIT then
		local _portrait = PendantMO.queryPortrait(id)
		data.name = CommonText[104]
		data.desc = _portrait.desc
	elseif kind == ITEM_KIND_LABORATORY_RES then 		-- 研究院
		local idl = LaboratoryMO.queryLaboratoryForItemById(id)
		data.name = idl.name
		data.desc = idl.description
	elseif kind == ITEM_KIND_TACTIC or kind == ITEM_KIND_TACTIC_PIECE then --战术或者战术碎片
		local tactics = TacticsMO.queryTacticById(id)
		data.name = tactics.tacticsName
		data.quality = tactics.quality
		data.attrtype = tactics.attrtype
		data.tacticstype = tactics.tacticstype
		data.tanktype = tactics.tanktype
		data.desc = tactics.desc
	elseif kind == ITEM_KIND_TACTIC_MATERIAL then --战术材料
		local tactiscMaterial = TacticsMO.queryTacticMaterialsById(id)
		data.name = tactiscMaterial.name
		data.desc = tactiscMaterial.dec
		data.quality = tactiscMaterial.quality + 1
		data.icon = tactiscMaterial.icon
	end
	if not data.name then data.name = "unkown " .. kind end
	if not data.name2 then data.name2 = data.name end
	if not data.desc then data.desc = "" end
	return data
end

function UserMO.getOnlineAwardByIndex(index)
	return online_award_[index]
end

function UserMO.getOnlineAwardTotalNum()
	return #online_award_
end

function UserMO.getOnlineAwardLeftTime()
	return UserMO.onlineCdTime_
end

------------------------------------------------------
--					功能引导						--
------------------------------------------------------

function UserMO.getFunctionNeverName()
	return local_function_recode .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
end

function UserMO.getFunctionState()
	if UserMO._functionState then return UserMO._functionState end
	--读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. UserMO.getFunctionNeverName()
    local data = nil
    if io.exists(path) then
        data = json.decode(io.readfile(path))
    end
	UserMO._functionState = data
    return data
end

function UserMO.setFunctionState(stateId)
	local data = UserMO.getFunctionState()
	if not data then data = {} end
	data[#data + 1] = stateId
	UserMO._functionState = data
	dump(UserMO._functionState)
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. UserMO.getFunctionNeverName()
    io.writefile(path, json.encode(data), "w+b")
end

function UserMO.checkFunctionState(stateId)
	if not UserMO._functionState then
		UserMO._functionState = UserMO.getFunctionState()
	end
	local data = UserMO._functionState
	if data and #data > 0 then
		for index=1,#data do
			if stateId == data[index] then
				return true
			end
		end
	end
	return false
end

function UserMO.getIgnoreAvoidWarCDClearCost()
	return db_system_[68].value / 100
end

function UserMO.getIgnoreAvoidWarCDClearCount()
	-- body
	return db_system_[67].value
end

------------------------------------------------------
--				SYSTEM 帐号在其他地方登录			--
------------------------------------------------------
function UserMO.SystemLoginError()
	UserMO.systemLoginErrorStr = CommonText[999999]
	UserMO.systemLoginErrorState = true
end

function UserMO.updateSystemLoginError()
	UserMO.systemLoginErrorState = false
	UserMO.systemLoginErrorStr = ErrorText.text6
end

--获得所有的红包
function UserMO.getAllRedPes()
	local data = PropMO.getAllProps()
	local reds = {}
	for index=1,#data do
		if data[index].propId == 105 or data[index].propId == 106 or data[index].propId == 107
		or data[index].propId == 108 then --红包4种
			reds[#reds + 1] = data[index]
		end
	end

	function sortFun(a,b)
		return a.propId > b.propId
	end

	table.sort(reds,sortFun)
	return reds
end