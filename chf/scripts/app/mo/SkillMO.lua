
local s_skill = require("app.data.s_skill")

local db_skill_ = nil

SKILL_RESET_TAKE_COIN = 58 -- 技能重置花费金币

SkillMO = {}

SkillMO.skill_ = {}

SkillMO.dirtySkillData_ = false

function SkillMO.init()
	db_skill_ = {}
	local records = DataBase.query(s_skill)
	for index = 1, #records do
		local data = records[index]
		db_skill_[data.skillId] = data
	end
end

function SkillMO.querySkillById(id)
	return db_skill_[id]
end

function SkillMO.queryMaxSkill()
	return #db_skill_
end

function SkillMO.getSkillLevelById(skillId)
	if not SkillMO.skill_[skillId] then return 0 end
	return SkillMO.skill_[skillId].level
end
