
local s_effect = require("app.data.s_effect")

local db_effect_ = nil
local db_effects_ = nil

EffectMO = {}

EFFECT_SHOW_TYPE_DEFEND = 1
EFFECT_SHOW_TYPE_ATTACK = 2
EFFECT_SHOW_TYPE_RESOURCE = 3

EFFECT_ID_RESOURCE_ALL = 1  -- 全面开采
EFFECT_ID_STONE = 2
EFFECT_ID_IRON = 3
EFFECT_ID_OIL = 4
EFFECT_ID_COPPER = 5
EFFECT_ID_SILICON = 6
EFFECT_ID_HURT_ADD = 7
EFFECT_ID_HURT_DECAY = 8
EFFECT_ID_RAPID_MARCH = 9 -- 急行
EFFECT_ID_FREE_WAR = 10 -- 免战
EFFECT_ID_BATTLE_BASE   = 11 -- 战争基地
EFFECT_ID_BASE_RESOURCE = 12  -- 资源丰收
EFFECT_ID_BUILD_UPGRADE = 13  -- 建造位
EFFECT_ID_BLACK_STYLE   = 14
EFFECT_ID_DESERT_STYLE  = 15
EFFECT_ID_HOUSE_STYLE   = 16 -- 茅草屋
EFFECT_ID_STONE_STYLE   = 17 -- 水晶伪装
EFFECT_ID_PB_RESOURCE   = 18 -- 军团战，增产
EFFECT_ID_PLAYER_BACK   = 47 -- 老玩家回归

EFFECT_ID_HURT_ADD_SENIOR = 19  -- 比7高级，会覆盖7的效果
EFFECT_ID_HURT_DECAY_SENIOR = 20  -- 比8高级，同上
EFFECT_ID_RAPID_MARCH_SENIOR = 21  -- 比9高级，同上

EFFECT_ID_SKIN_ELITE = 1001 -- 精英基地
EFFECT_ID_SKIN_EXTREME = 1002 -- 至尊基地特效
EFFECT_ID_SKIN_AIR_FORTRESS = 1003 -- 空中要塞
EFFECT_ID_SKIN_GOST = 2011 -- 鬼影森森
EFFECT_ID_SKIN_MECHANICS = 2015 -- 机械迷城

EFFECT_RESOURCE_ADDITION = 0.5  -- 资源增益
EFFECT_BASE_RES_ADDITION = 0.25 -- 资源丰收基地加成

EFFECT_PB_RES_ADDITION = 0.5 -- 军团战，资源增益系数

EFFECT_BATTLE_HIT_ADDITION = 0.15
EFFECT_BATTLE_DODGE_ADDITION = 0.05

EFFECT_SKIN_ADDITION_VALUE2 = 0.2
EFFECT_SKIN_ADDITION_VALUE1 = 0.1

EFFECT_SKIN_EXTREME_ADDITION = 0.6 -- 至尊基地特效 5种资源基础产量+60%
EFFECT_SKIN_MECHAIN_ADDITION = 1 -- 机械迷城特效 5种资源基础产量+60%

EffectMO.effects_ = {}  -- 当前的所有效果

EffectMO.timeHandler_ = nil

function EffectMO.init()
	db_effect_ = {}
	local records = DataBase.query(s_effect)
	db_effects_ = records
	for index = 1, #records do
		local data = records[index]
		db_effect_[data.effectId] = data
	end
end

function EffectMO.queryEffectById(id)
	return db_effect_[id]
end

function EffectMO.getAllEffect()
	return db_effects_
end

function EffectMO.getEffectById(effectId)
	return EffectMO.effects_[effectId]
end

function EffectMO.getEffectShowType(effectId)
	local eb = EffectMO.queryEffectById(effectId)
	return eb.kind or 0
end

--建造时间
function EffectMO.buildTime()
	if EffectBO.getEffectValid(201) then
		return 100
	end
	return 0
end

--建造消耗
function EffectMO.buildCost()
	if EffectBO.getEffectValid(200) then
		return 100
	end
	return 0
end

--坦克建造时间
function EffectMO.tankBuild()
	if EffectBO.getEffectValid(202) then
		return 100
	end
	return 0
end

--坦克改造时间
function EffectMO.tankRefine()
	if EffectBO.getEffectValid(203) then
		return 100
	end
	return 0
end

--资源产量
function EffectMO.resourceAdd()
	local valid,left = EffectBO.getEffectValid(204)
	if valid then
		return 100,left
	end
	return 0
end
