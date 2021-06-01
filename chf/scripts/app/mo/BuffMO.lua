
local s_buff = require("app.data.s_buff")

local db_buff_ = nil

BuffMO = {}

-- buff的groupId对应的素材
BuffMO.buffMap = {"attr_crit", "p_hurt_strength", "attr_atkMode_1", "p_hurt_dep", "attr_hit", "attr_dodge", "attr_defend", "attr_atkMode_2",
	 "buff_dodge_dec", "buff_hit_add","buff_reduce","buff_dodge_dec","buff_critdes","buff_biteadd","attr_frighten","attr_fortitude"}

function BuffMO.init()
	db_buff_ = {}
	local records = DataBase.query(s_buff)
	for index = 1, #records do
		local data = records[index]
		db_buff_[data.buffId] = data
	end
end

function BuffMO.queryBuffById(id)
	return db_buff_[id]
end
