--
-- Author: gf
-- Date: 2015-09-18 15:34:56
--

local s_party_combat = require("app.data.s_party_combat")

PartyCombatMO = {}

PARTY_COMBAT_VIEW_ = {
		{420, 178},
		{302, 385},
		{408, 566},
		{156, 749},
		{381, 930}
}

--团本数据
PartyCombatMO.CombatSection = {}

--今日剩余次数
PartyCombatMO.combatCount_ = 0

--副本总数据
PartyCombatMO.partyCombat_ = {}

--副本单章数据
PartyCombatMO.combatList_ = {}

--领取过奖励的关卡ID
PartyCombatMO.getAwardId_ = {}



--团本每天最大次数
PARTY_COMBAT_COUNT_MAX = 5

local db_party_section_combat_ = nil
local db_party_combat_ = nil

function PartyCombatMO.init()
	--团本数据
	PartyCombatMO.CombatSection = {}

	--今日剩余次数
	PartyCombatMO.combatCount_ = 0

	--副本总数据
	PartyCombatMO.partyCombat_ = {}

	--副本单章数据
	PartyCombatMO.combatList_ = {}

	--领取过奖励的关卡ID
	PartyCombatMO.getAwardId_ = {}

	db_party_combat_ = {}
	db_party_section_combat_ = {}

	local records = DataBase.query(s_party_combat)
	local j
	for index = 1, #records do
		local data = records[index]
		local sectionId = math.floor(data.sectionId / 100)

		if not db_party_section_combat_[sectionId] then 
			db_party_section_combat_[sectionId] = {}
			j = 1
			local section = {}
			section.combatName = data.combatName
			section.sectionId = data.sectionId
			table.insert(PartyCombatMO.CombatSection,section)
		else
			j = j + 1
		end
		db_party_section_combat_[sectionId][j] = data
		db_party_combat_[data.combatId] = data		
	end
	-- gdump(db_party_section_combat_,"PartyCombatMO.init()..db_party_section_combat_")
	-- gdump(PartyCombatMO.CombatSection,"PartyCombatMO.init()..PartyCombatMO.CombatSection")
end

function PartyCombatMO.queryCombat(combatId)
	return db_party_combat_[combatId]
end



function PartyCombatMO.queryCombatBySection(sectionId)
	return db_party_section_combat_[sectionId]
end

function PartyCombatMO.queryCombatBySectionNum(sectionId)
	if not db_party_section_combat_[sectionId] then return 0 end
	return #db_party_section_combat_[sectionId]
end

function PartyCombatMO.queryCombatSectionMax()
	return #db_party_section_combat_
end

function PartyCombatMO.getCombatSectionById(combatId)
	local sectionId = PartyCombatMO.queryCombat(combatId).sectionId
	for index=1,#PartyCombatMO.CombatSection do
		local section = PartyCombatMO.CombatSection[index]
		if section.sectionId == sectionId then
			return section
		end
	end
	return nil
end



	