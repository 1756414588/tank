--[[
	能晶数据配置表
--]]

local s_energy_stone = require("app.data.s_energy_stone")
local s_energy_hidden_attribute = require("app.data.s_energy_hidden_attribute")

local db_energystar = nil
local db_energy_hidden_attribute = nil
local db_energy_hidden_attribute_list = nil

ENERGYSPAR_OPEN_LEVEL = 55

ENERGYSPAR_HOLE_NUM = 6 ---能晶孔 个数

EnergySparMO = {}
EnergySparMO.energySpar_ = nil
EnergySparMO.inlayData_ = nil

EnergySparMO.dirtyEnergyData_ = true

function EnergySparMO.init()
	db_energystar = {}
	db_energy_hidden_attribute = {}

	local records = DataBase.query(s_energy_stone)
	for index = 1, #records do
		local data = records[index]
		db_energystar[data.stoneId] = data
	end	

	local records = DataBase.query(s_energy_hidden_attribute)
	for index = 1, #records do
		local data = records[index]
		db_energy_hidden_attribute[data.attributeID] = data
	end		

	db_energy_hidden_attribute_list = {}

	for k,v in pairs(db_energy_hidden_attribute) do
		db_energy_hidden_attribute_list[#db_energy_hidden_attribute_list+1] = v
	end

	table.sort(db_energy_hidden_attribute_list,function ( a,b )
		return a.attributeID < b.attributeID
	end)


	EnergySparMO.inlayData_ = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		EnergySparMO.inlayData_[index] = {}
	end	

	EnergySparMO.dirtyEnergyData_ = true
end

function EnergySparMO.swapInlayData( fromFormat, toFormat )
	local temp = EnergySparMO.inlayData_[fromFormat]
	EnergySparMO.inlayData_[fromFormat] = EnergySparMO.inlayData_[toFormat]
	EnergySparMO.inlayData_[toFormat] = temp
end

function EnergySparMO.queryEnergySparById( stoneId )
	return db_energystar[stoneId]
end

function EnergySparMO.getEnergySparByPos( pos, hole )
	return EnergySparMO.inlayData_[pos][hole]
end

function EnergySparMO.getAllEnergySpars(holeType,subType)
	local ret = {}

	for stoneId, spar in pairs(EnergySparMO.energySpar_) do
		if spar.count > 0 then
			if not holeType then
				ret[#ret + 1] = spar
			else
				local sparDB = EnergySparMO.queryEnergySparById(spar.stoneId)
				if sparDB and sparDB.holeType == holeType then
					if subType then
						if sparDB.type ~= subType then
							ret[#ret + 1] = spar
						end
					else
						ret[#ret + 1] = spar
					end
				end
			end
		end
	end

	local function sort(spar1, spar2)
		local spar1DB = EnergySparMO.queryEnergySparById(spar1.stoneId)
		local spar2DB = EnergySparMO.queryEnergySparById(spar2.stoneId)
		if spar1DB.holeType ~= spar2DB.holeType then
			return spar1DB.holeType < spar2DB.holeType
		end
		
		return spar1DB.level > spar2DB.level
	end

	table.sort(ret, sort)	

	return ret
end

function EnergySparMO.getAttributeDataByPos( holePos )
	local spars = EnergySparMO.inlayData_[holePos]
	local ret = {}
	local maps = {}
	local levelCounts = {}
	for i,v in ipairs(spars) do
		if v > 0 then
			local sparDB = EnergySparMO.queryEnergySparById(v)
			if not maps[sparDB.attrId] then
				maps[sparDB.attrId] = 0
			end
			if not levelCounts[sparDB.level] then
				levelCounts[sparDB.level] = 0
			end

			levelCounts[sparDB.level] = levelCounts[sparDB.level] + 1

			maps[sparDB.attrId] = maps[sparDB.attrId] + sparDB.attrValue
		end
	end

	for k,v in pairs(maps) do
		local attrValue = AttributeBO.getAttributeData(k, v)
		ret[attrValue.index] = attrValue
	end

	return ret, levelCounts
end


function EnergySparMO.getHideAttributes()
	-- "attributeID","rule","effect","describe"
	return db_energy_hidden_attribute_list
end

function EnergySparMO.getOpenLv( lv )
	return lv >= ENERGYSPAR_OPEN_LEVEL
end

--获取所有装备上的能晶的等级总和
function EnergySparMO.getAllEquipEnergySparsLv()
	local data = EnergySparMO.inlayData_
	local lv = 0
	for index=1,#data do
		local record = data[index]
		for num=1,#record do
			local energyId = record[num]
			if energyId > 0 then
				local energy = EnergySparMO.queryEnergySparById(energyId)
				lv = lv + energy.level
			end
		end
	end

	return lv
end