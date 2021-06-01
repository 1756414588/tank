
-- 战争武器
-- 阵前buff系统

local s_secret_weapon = require("app.data.s_secret_weapon")
local s_secret_weapon_skill = require("app.data.s_secret_weapon_skill")

-- 
local db_secret_weapon_ = nil
local db_secret_weapon_skill_ = nil
local db_secret_weapon_skill_pos_ = nil

WarWeaponMO = {}

function WarWeaponMO.Init()
	db_secret_weapon_ = {}
	local records = DataBase.query(s_secret_weapon)
	for index = 1, #records do
		local data = records[index]
		data.unLockCostParse = json.decode(data.unLockCost)
		data.studyLockCostParse = json.decode(data.studyLockCost)
		db_secret_weapon_[data.id] = data
	end

	db_secret_weapon_skill_ = {}
	db_secret_weapon_skill_pos_ = {}
	local records = DataBase.query(s_secret_weapon_skill)
	for index = 1, #records do
		local data = records[index]
		db_secret_weapon_skill_[data.sid] = data
		if not db_secret_weapon_skill_pos_[data.pos] then
			db_secret_weapon_skill_pos_[data.pos] = {}
		end
		db_secret_weapon_skill_pos_[data.pos][data.sid] = data
	end
end

-- 获取武器信息
function WarWeaponMO.queryWeaponById(id)
	return db_secret_weapon_[id]
end

-- 获取武器技能解锁消费
function  WarWeaponMO.getWeaponUnLockCoin(id, index)
	if not db_secret_weapon_[id] then return nil end
	return db_secret_weapon_[id].unLockCostParse[index]
end

-- 获取武器技能洗练锁定消费
function WarWeaponMO.getWeaponStudyLockCoin(id, index)
	if not db_secret_weapon_[id] then return nil end
	return db_secret_weapon_[id].studyLockCostParse[index]
end

function WarWeaponMO.queryWeaponSkillBySid(sid)
	return db_secret_weapon_skill_[sid]
end

function WarWeaponMO.queryWeaponSkillByPosID(pos, sid)
	if not db_secret_weapon_skill_pos_[pos] then return nil end
	return db_secret_weapon_skill_pos_[pos][sid]
end