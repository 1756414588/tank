

local s_prop = require("app.data.s_prop")
local s_act_prop = require("app.data.s_activity_prop")
local s_vip_shop = require("app.data.s_vip_shop")
local s_world_shop = require("app.data.s_world_shop")
local s_skin = require("app.data.s_skin")
local s_friend = require("app.data.s_friend")

-- 缓存道具数据，以propId为索引
local db_prop_ = nil
local db_act_prop_ = nil
local db_vip_shop_ = nil
local db_world_shop_ = nil
local db_skin_ = nil
local db_friend_ = nil

PropMO = {}

PROP_TAG_RESOURCE = 1 -- 道具资源分类
PROP_TAG_GAIN     = 2 -- 增益
PROP_TAG_GROW     = 3 -- 成长
PROP_TAG_SPECIAL  = 4 -- 特殊

PROP_ID_FREE_WAR_72         = 38 --免战72小时
PROP_ID_FREE_WAR_24         = 42 --免战24小时
PROP_ID_FREE_WAR_8          = 46 --免战8小时
PROP_ID_SKILL_BOOK_BAG      = 47 -- 技能书礼包

PROP_ID_JIANGSHENHUN		= 50 -- 将神魂
PROP_ID_HERO_CHIP			= 172 -- 将神魂碎片
PROP_ID_COMMAND_BOOK		= 56 -- 统率书
PROP_ID_SKILL_BOOK			= 57 -- 技能书
PROP_ID_LUCKY_COIN			= 58 -- 幸运币

PROP_ID_MOVE_HOME_SPECIFY   = 51 -- 迁城令(定点)
PROP_ID_MOVE_HOME_RANDOM    = 55 -- 迁城令(随机)

PROP_ID_SURFACE_BATTLE      = 52 -- 战争基地
PROP_ID_SURFACE_RESOURCE    = 53 -- 资源丰收基地
PROP_ID_SURFACE_CASTLE_FAIR = 54 -- 童话城堡
PROP_ID_SURFACE_CASTLE_DARD = 64 -- 暗黑城堡
PROP_ID_SURFACE_CASTLE_DESDERT = 65 -- 荒漠城堡
PROP_ID_SURFACE_HOUSE       = 66 -- 茅草屋
PROP_ID_SURFACE_STONE       = 67 -- 水晶伪装
PROP_ID_SURFACE_ELITE       = 344 -- 精英伪装
PROP_ID_SURFACE_EXTREME     = 345 -- 至尊伪装
PROP_ID_SURFACE_AIRHOME		= 415 -- 飞行堡垒
PROP_ID_SURFACE_GOST		= 507 -- 鬼森鬼气
PROP_ID_SURFACE_SNOW		= 561 -- 圣诞老人
PROP_ID_SURFACE_CITY		= 587 -- 未来之城
PROP_ID_MECHANIC_CITY		= 3315 -- 机械迷城

PROP_ID_HORN_NORMAL         = 60 -- 普通喇叭
PROP_ID_HORN_LOVE           = 61 -- 求爱喇叭
PROP_ID_HORN_BLESS          = 62 -- 祝福喇叭
PROP_ID_HORN_BIRTH          = 63 -- 生日喇叭

PROP_ID_EQUIP_BOX_WHITE = 87  -- 装备箱子
PROP_ID_EQUIP_BOX_GREEN = 88
PROP_ID_EQUIP_BOX_BLUE = 89
PROP_ID_EQUIP_BOX_PURPLE = 90
PROP_ID_NEED_BOX_FIGHT = 92  -- 胜利的指引

PROP_ID_FITTING       = 97    -- 零件
PROP_ID_METAL         = 98    -- 记忆金属
PROP_ID_PLAN          = 99    -- 设计蓝图
PROP_ID_MINERAL       = 100   -- 金属矿物
PROP_ID_TOOL          = 101   -- 改造工具
PROP_ID_DRAW          = 102    -- 改造图纸
PROP_ID_TANK          = 250    -- 改造图纸
PROP_ID_CHARIOT       = 251    -- 改造图纸
PROP_ID_ARTILLERY     = 252    -- 改造图纸
PROP_ID_ROCKETDRIVE   = 253    -- 改造图纸

PROP_ID_RED_PACKET_MICRO    = 105 -- 红包(微)
PROP_ID_RED_PACKET_SMALL    = 106
PROP_ID_RED_PACKET_MEDIUM   = 107
PROP_ID_RED_PACKET_BIG      = 108

PROP_ID_INDICATOR_RESOURCE  = 116 -- 矿点侦查
PROP_ID_INDICATOR_PLAYER    = 117 -- 定位仪

PROP_ID_PARTY_CONTRIBUTION  = 119 -- 军团贡献宝箱
PROP_ID_PARTY_CONTRIBUTION1 = 234 -- 军团贡献宝箱(蓝)

PROP_ID_NICK_CHANGE         = 121 -- 身份铭牌

PROP_ID_HUANGBAO_SMALL      = 139  -- 荒宝宝箱
PROP_ID_HUANGBAO_MEDIUM     = 140
PROP_ID_HUANGBAO_BIG        = 141

PROP_ID_TRUST				= 129 --哈洛克信物
PROP_ID_PROFOTO				= 124 --哈洛克宝图

PROP_ID_TANKBOX				= 149 --坦克箱子

PROP_ID_PARTY_RENAME		= 195 --军团铭牌

PROP_ID_PRAY_CARD_1 		= 196 --祝福卡(绿)
PROP_ID_PRAY_CARD_2 		= 197 --祝福卡(蓝)
PROP_ID_PRAY_CARD_3 		= 198 --祝福卡(紫)
PROP_ID_PRAY_CARD_4 		= 199 --祝福卡(橙)

PROP_ID_M1A2_CORE			= 200 --M1A2核心

PROP_ID_MARCH_RECALL		= 3300 --行军召回令
PROP_ID_LEVY_AIRSHIP		= 3301 --征收双倍令
PROP_ID_MASS_AIRSHIP		= 3302 --集结令

PROP_BUY_MAX_NUM = 100 -- 道具一次性购买最大数量

-- 荒宝兑换的道具和消耗碎片数量
PropMO.huangbaoExchnage = {
{id = PROP_ID_HUANGBAO_SMALL, price = 10},
{id = PROP_ID_HUANGBAO_MEDIUM, price = 20},
{id = PROP_ID_HUANGBAO_BIG, price = 40},
}

-- 当前拥有的道具，以propId为索引
PropMO.prop_ = {}

function PropMO.init()
	db_prop_ = {}
	local records = DataBase.query(s_prop)
	for index = 1, #records do
		local data = records[index]
		db_prop_[data.propId] = data
	end

	db_act_prop_ = {}
	local records = DataBase.query(s_act_prop)
	for index = 1, #records do
		local data = records[index]
		db_act_prop_[data.id] = data
	end

	db_vip_shop_ = {}
	local records = DataBase.query(s_vip_shop)
	for index = 1, #records do
		local data = records[index]
		db_vip_shop_[data.gid] = data
	end

	db_world_shop_ = {}
	local records = DataBase.query(s_world_shop)
	for index = 1, #records do
		local data = records[index]
		db_world_shop_[data.gid] = data
	end

	db_skin_ = {}
	local records = DataBase.query(s_skin)
	for index = 1, #records do
		local data = records[index]
		db_skin_[data.id] = data
	end

	db_friend_ = {}
	local records = DataBase.query(s_friend)
	for index = 1, #records do
		local data = records[index]
		db_friend_[data.id] = data
	end
end

function PropMO.getVipShop()
	return db_vip_shop_
end

function PropMO.getWorldShop()
	return db_world_shop_
end

function PropMO.getTableProp()
	return s_prop
end

function PropMO.queryPropById(propId)
	return db_prop_[propId]
end

function PropMO.queryActPropById(id)
	return db_act_prop_[id]
end

function PropMO.queryActProp(id)
	local list = {}
	for k,v in ipairs(db_act_prop_) do
		if v.activityId == id then
			table.insert(list,v)
		end
	end
	return list
end

-- 获得制作车间可以
function PropMO.queryCanBuildProps()
	local ret = {}
	for propId, prop in pairs(db_prop_) do
		if prop.canBuild == 1 then
			ret[#ret + 1] = prop
		end
	end
	return ret
end

function PropMO.getPropName(propId)
	local prop = PropMO.queryPropById(propId)
	local name = prop.propName
	if prop.nameSuffix and prop.nameSuffix ~= "" then
		name = name .. "[" .. prop.nameSuffix .. "]"
	end
	return name
end

function PropMO.getPropNameById(propId)
	local prop = PropMO.queryPropById(propId)
	return prop.name
end
-- function PropMO.getPropById(propId)
-- 	return PropMO.prop_[propId]
-- end

-- canUse为空表示所有，为true表示只获得可以使用的，为false表示表示只获得不可使用的
function PropMO.getAllProps(canUse)
	local isAll = false
	if canUse == nil then isAll = true end

	local ret = {}
	for propId, prop in pairs(PropMO.prop_) do
		if prop.count > 0 and prop.propId > 0 then
			if isAll then
				local propDB = PropMO.queryPropById(propId)
				if propDB then
					ret[#ret + 1] = prop
				end
			else
				local propDB = PropMO.queryPropById(propId)
				if propDB then
					if canUse then
						if propDB.canUse == 1 then
							ret[#ret + 1] = prop
						end
					else
						if propDB.canUse == 0 then
							ret[#ret + 1] = prop
						end
					end
				end
			end
		end
	end
	return ret
end

function PropMO.getPropsByKind(kind)
	local ret = {}
	for propId, prop in pairs(PropMO.prop_) do
		if prop.count > 0 and prop.propId > 0 then
			local propDB = PropMO.queryPropById(propId)
			if propDB then
				if kind == SHOP_KIND_RESOURCE and propDB.tag == 1 then
					ret[#ret + 1] = prop
				elseif kind == SHOP_KIND_GAIN and propDB.tag == 2 then
					ret[#ret + 1] = prop
				elseif kind == SHOP_KIND_OTHER and (propDB.tag == 3 or propDB.tag == 4) then
					ret[#ret + 1] = prop
				end
			end
		end
	end
	return ret
end

--
function PropMO.checkPropForSkin(skinid)
	local _data = db_skin_[skinid]
	if _data then return _data end
	return nil
end

function PropMO.getAddValueByRedId(propId)
	local data = db_friend_
	if propId == PROP_ID_RED_PACKET_MICRO then
		return data[2].friendAdd
	elseif propId == PROP_ID_RED_PACKET_SMALL then
		return data[3].friendAdd
	elseif propId == PROP_ID_RED_PACKET_MEDIUM then
		return data[4].friendAdd
	elseif propId == PROP_ID_RED_PACKET_BIG then
		return data[5].friendAdd
	elseif propId == 1 then --如果是祝福
		return data[1].friendAdd
	end
	return 0
end