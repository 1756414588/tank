--
--
--
--

FighterEffectMO = {}

local s_attack_effect = require("app.data.s_attack_effect")
local db_attack_effect_ = nil
local db_attack_effect_type_ = nil

function FighterEffectMO.init()
 	db_attack_effect_ = {}
 	db_attack_effect_type_ = {}
	local records = DataBase.query(s_attack_effect)
	for index = 1, #records do
		local data = records[index]
		db_attack_effect_[data.id] = data
		if not db_attack_effect_type_[data.type] then
			db_attack_effect_type_[data.type] = {}
		end
		db_attack_effect_type_[data.type][data.eid] = data
	end
 end 

 function FighterEffectMO.queryEffectById(id)
	return db_attack_effect_[id]
end

function FighterEffectMO.queryTypeForEid(type, eid)
	if not db_attack_effect_type_[type] then return nil end
	return db_attack_effect_type_[type][eid]
end