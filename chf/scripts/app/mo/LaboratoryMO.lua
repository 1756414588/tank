--
--
--

local s_laboratory_item = require("app.data.s_laboratory_item")
local s_laboratory_tech = require("app.data.s_laboratory_tech")
local s_laboratory_research = require("app.data.s_laboratory_research")
local s_laboratory_military = require("app.data.s_laboratory_military")
local s_laboratory_progress = require("app.data.s_laboratory_progress")
local s_laboratory_area = require("app.data.s_laboratory_area")
local s_laboratory_task = require("app.data.s_laboratory_task")
local s_laboratory_spy = require("app.data.s_laboratory_spy")

local db_laboratory_item_ = nil
local db_laboratory_tech_ = nil
local db_laboratory_research_ = nil
local db_laboratory_research_type_ = nil
local db_laboratory_military_ = nil
local db_laboratory_progress_ = nil
local db_laboratory_area_ = nil
local db_laboratory_task_ = nil
local db_laboratory_spy_ = nil

local db_laboratory_military_attr_ = nil

LaboratoryMO = {}
LaboratoryMO.dataList = {}  -- 道具碎片资源
LaboratoryMO.resProduct = {}
LaboratoryMO.academeData = {}	-- 研究院数据

-- LaboratoryMO.militaryData = {}	-- 科技数据
LaboratoryMO.militarySkillData = {}
LaboratoryMO.progressID = 1

LaboratoryMO.AttrType = {}
LaboratoryMO.AttrTypePayload = {} 		-- 载重
LaboratoryMO.AttrTypeProduct = {} 		-- 生产
LaboratoryMO.AttrTypeRefit = {} 		-- 改装
-- LaboratoryMO.AttrTypeCommonSpeed = {}	-- 行军速度
-- LaboratoryMO.AttrTypeCommonSoldier = {}	-- 带兵量


-- 道具
LABORATORY_ITEM1_ID = 201
LABORATORY_ITEM2_ID = 202
LABORATORY_ITEM3_ID = 203
LABORATORY_ITEM4_ID = 204
-- 碎片
LABORATORY_RES1_ID = 101
LABORATORY_RES2_ID = 102
LABORATORY_RES3_ID = 103
LABORATORY_RES4_ID = 104
-- 科技
LABORATORY_TECH1_ID = 1 	-- 碎片1 科技 
LABORATORY_TECH2_ID = 2 	-- 碎片2 科技 
LABORATORY_TECH3_ID = 3 	-- 碎片3 科技 
LABORATORY_TECH4_ID = 4 	-- 增加总人数 科技 
LABORATORY_TECH5_ID = 5 	-- 增加项目人数 科技 
-- 建筑
LABORATORY_RESEARCH1_ID = 101
LABORATORY_RESEARCH2_ID = 102
LABORATORY_RESEARCH3_ID = 103
LABORATORY_RESEARCH4_ID = 104

LABORATORY_RESEARCH1_LIB_ID = 201
LABORATORY_RESEARCH2_LIB_ID = 202
LABORATORY_RESEARCH3_LIB_ID = 203
LABORATORY_RESEARCH4_LIB_ID = 204
LABORATORY_RESEARCH_MAX_LIB_ID = 301

local TankAttr 		= {[1021] = true, [1031] = true, [1041] = true}
local ChariotAttr 	= {[1022] = true, [1032] = true, [1042] = true}
local ArtilleryAttr	= {[1023] = true, [1033] = true, [1043] = true}
local RocketAttr	= {[1024] = true, [1034] = true, [1044] = true}



function LaboratoryMO.init()
	db_laboratory_item_ = {}
	local records = DataBase.query(s_laboratory_item)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_item_[data.id] = data
	end

	db_laboratory_tech_ = {}
	local records = DataBase.query(s_laboratory_tech)
	for index = 1, #records do
		local data = records[index]
		if not db_laboratory_tech_[data.techId] then
			db_laboratory_tech_[data.techId] = {}
		end
		db_laboratory_tech_[data.techId][data.techLv] = data
	end

	db_laboratory_research_ = {}
	db_laboratory_research_type_ = {}
	local records = DataBase.query(s_laboratory_research)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_research_[data.id] = data
		if not db_laboratory_research_type_[data.type] then
			db_laboratory_research_type_[data.type] = {}
		end
		db_laboratory_research_type_[data.type][#db_laboratory_research_type_[data.type] + 1] = data
	end

	db_laboratory_military_ = {}
	db_laboratory_military_attr_ = {}
	local records = DataBase.query(s_laboratory_military)
	for index = 1, #records do
		local data = records[index]
		if not db_laboratory_military_[data.type] then
			db_laboratory_military_[data.type] = {}
		end
		if not db_laboratory_military_[data.type][data.skillId] then
			db_laboratory_military_[data.type][data.skillId] = {}
		end
		db_laboratory_military_[data.type][data.skillId][data.lv] = data
		LaboratoryMO._parseLaboratoryForAttr(data)
	end

	db_laboratory_progress_ = {}
	local records = DataBase.query(s_laboratory_progress)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_progress_[data.id] = data
	end

	db_laboratory_area_ = {}
	local records = DataBase.query(s_laboratory_area)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_area_[data.areaId] = data
	end

	db_laboratory_task_ = {}
	local records = DataBase.query(s_laboratory_task)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_task_[data.taskId] = data
	end

	db_laboratory_spy_ = {}
	local records = DataBase.query(s_laboratory_spy)
	for index = 1, #records do
		local data = records[index]
		db_laboratory_spy_[#db_laboratory_spy_ + 1] = data
	end
end

-- 查询研究道具和碎片
function LaboratoryMO.queryLaboratoryForItemById(id)
	return db_laboratory_item_[id]
end

-- 查询 科技条目
function LaboratoryMO.queryLaboratoryForTechnologyByIdLv(techID, techLV)
	if not db_laboratory_tech_[techID] then return nil end
	return db_laboratory_tech_[techID][techLV]
end

-- 查询 研究项目
function LaboratoryMO.queryLaboratoryForResearchById(id)
	return db_laboratory_research_[id]
end

-- 查询 研究项目 
function LaboratoryMO.queryLaboratoryForResearchAllType()
	return db_laboratory_research_type_
end

-- 
function LaboratoryMO.queryLaboratoryForMilitarye(type, skillId)
	if not skillId then return db_laboratory_military_[type] end
	return db_laboratory_military_[type][skillId]
end

function LaboratoryMO.queryLaboratoryForProgress(id)
	return db_laboratory_progress_[id]
end



function LaboratoryMO._parseLaboratoryForAttr(data)
	if not data or not data.effect then return end
	local attrs = json.decode(data.effect)
	for index = 1, #attrs do
		local attr = attrs[index]
		local attrid = attr[1]
		local attrvalue = attr[2]

		local out = {}
		out.attrType = 0 							-- 公共属性
		out.attrid = attrid
		out.value = attrvalue
		out.kid = data.kid
		out.type = data.type
		out.skillId = data.skillId
		out.lv = data.lv

		if TankAttr[attrid] then				-- 坦克专有属性
			out.attrType = data.type
		elseif ChariotAttr[attrid] then			-- 战车专有属性
			out.attrType = data.type
		elseif ArtilleryAttr[attrid] then		-- 火炮专有属性
			out.attrType = data.type
		elseif RocketAttr[attrid] then			-- 火箭专有属性
			out.attrType = data.type
		end

		if not db_laboratory_military_attr_[out.attrType] then
			db_laboratory_military_attr_[out.attrType] = {}
		end
		if not db_laboratory_military_attr_[out.attrType][out.skillId] then
			db_laboratory_military_attr_[out.attrType][out.skillId] = {}
		end
		db_laboratory_military_attr_[out.attrType][out.skillId][out.lv] = out
	end
end

function LaboratoryMO.getLaboratoryForAttr(tankType)
	return db_laboratory_military_attr_[tankType]
end

function LaboratoryMO.getLaboratoryLurkArea(areaid)
	if not areaid then return db_laboratory_area_ end
	return db_laboratory_area_[areaid]
end

function LaboratoryMO.getLaboratoryLurkTask(taskId)
	return db_laboratory_task_[taskId]
end

function LaboratoryMO.getLaboratoryLurkSpy()
	return db_laboratory_spy_
end