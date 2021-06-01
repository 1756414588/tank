--
-- Author: gf
-- Date: 2015-08-26 10:26:14
--

local s_refine = require("app.data.s_refine")
local s_refine_lv = require("app.data.s_refine_lv")
local s_techsell = require("app.data.s_act_techsell")

SCIENCE_ID_MARCH_SPPED = 116  -- 引擎强化
SCIENCE_ID_BUILD_UP_SPEED = 117  -- 建筑设计

ScienceMO = {}

--我方所有科技
ScienceMO.sciences_ = {}

ScienceMO.party_sciences_ = {}

ScienceMO.dirtyScienceData_ = false

local db_science_ = nil
local db_science_lv_ = nil
local db_tech_sell_= nil

SCIENCE_REFINE_ID_REST = 100 -- 修复科技ID

function ScienceMO.init()
	db_science_ = nil
	db_science_lv_ = nil
	db_tech_sell_ = nil
	ScienceMO.sciences_ = {}
	ScienceMO.party_sciences_ = {}

	if not db_science_ then
		db_science_ = {}
		local records = DataBase.query(s_refine)
		for index = 1, #records do
			local science = records[index]
			db_science_[science.refineId] = science
			if science.refineType == 1 then
				local scienceDB = {}
				scienceDB = science
				scienceDB.scienceId = science.refineId
				scienceDB.scienceLv = 0
				ScienceMO.sciences_[#ScienceMO.sciences_ + 1] = scienceDB
			elseif science.refineType == 2 then
				local scienceDB = {}
				scienceDB = science
				scienceDB.scienceId = science.refineId
				scienceDB.scienceLv = 0
				scienceDB.schedule = 0
				ScienceMO.party_sciences_[#ScienceMO.party_sciences_ + 1] = scienceDB
			end
		end
	end
	-- gdump(ScienceMO.sciences_,"ScienceMO.sciences_ScienceMO.sciences_")

	if not db_science_lv_ then
		db_science_lv_ = {}
		local records = DataBase.query(s_refine_lv)
		for index = 1, #records do
			local scienceLevel = records[index]

			if not db_science_lv_[scienceLevel.refineId] then db_science_lv_[scienceLevel.refineId] = {} end

			--因为有等级为0的情况，所以需要+1
			db_science_lv_[scienceLevel.refineId][scienceLevel.level + 1] = scienceLevel
		end
	end

	if not db_tech_sell_ then
		db_tech_sell_ = {}
		local records = DataBase.query(s_techsell)
		for index = 1, #records do
			local data = records[index]
			db_tech_sell_[data.id] = data
		end
	end
end

function ScienceMO.queryScience(refineId)
	if not db_science_[refineId] then return nil end
	return db_science_[refineId]
end

function ScienceMO.queryScienceLevel(refineId, level)
	if not db_science_lv_[refineId] then return nil end
	return db_science_lv_[refineId][level + 1]
end

function ScienceMO.queryScienceMaxLevel(refineId)
	if not db_science_lv_[refineId] then return 0 end
	return #db_science_lv_[refineId] - 1
end





function ScienceMO.queryScienceById(scienceId)
	local data
	for index=1,#ScienceMO.sciences_ do
		data = ScienceMO.sciences_[index]
		if data.scienceId == scienceId then
			return data
		end
	end
	return nil
end

--获得科技加速活动时科技配置信息
function ScienceMO.getTechSellInfo(awardId)
	local data = db_tech_sell_
	for index=1,#data do
		if data[index].awardId == awardId then
			return data[index]
		end
	end
end