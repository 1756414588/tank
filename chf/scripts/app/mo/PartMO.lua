
-- 配件MO

local s_part = require("app.data.s_part")
local s_part_up = require("app.data.s_part_up")
local s_part_refit = require("app.data.s_part_refit")
local s_part_quality = require("app.data.s_part_quality_up")
local s_part_smelting = require("app.data.s_part_smelting")
local s_part_matrial = require("app.data.s_part_matrial")

local db_part_ = nil
local db_part_up_ = nil
local db_part_refit_ = nil
local db_part_quality_ = nil
local db_part_smelt_ = nil
local db_part_matrial_ = nil

-- 配件的四大类
PART_TYPE_TANK      = 1
PART_TYPE_CHARIOT   = 2 -- 战车
PART_TYPE_ARTILLERY = 3 -- 火炮
PART_TYPE_ROCKET    = 4 -- 火箭

PART_POS_HP            			= 1  -- 生命
PART_POS_ATTACK        			= 2 -- 攻击
PART_POS_DEFEND        			= 3 -- 防护
PART_POS_IMPALE        			= 4 -- 穿刺
PART_POS_HP_DEFEND     			= 5 -- 生命、防护
PART_POS_ATTACK_IMPALE 			= 6 -- 攻击、穿刺
PART_POS_ATTACK_HP     			= 7 -- 攻击、生命
PART_POS_IMPALE_DEFEND 			= 8 -- 穿刺、防护
PART_POS_HP_DEFEND_IMPALE   	= 9 -- 生命、防护、穿刺
PART_POS_ATTACK_DEFEND_IMPALE 	= 10 -- 攻击、防护、穿刺

PART_ID_ALL_PIECE      = 901 -- 万能碎片(这是碎片，kind=ITEM_KIND_CHIP)

-- 配件材料id
MATERIAL_ID_FITTING       = 1    -- 零件
MATERIAL_ID_METAL         = 2    -- 记忆金属
MATERIAL_ID_PLAN          = 3    -- 设计蓝图
MATERIAL_ID_MINERAL       = 4    -- 金属矿物
MATERIAL_ID_TOOL          = 5    -- 改造工具
MATERIAL_ID_DRAW          = 6    -- 改造图纸
MATERIAL_ID_TANK          = 7    -- 坦克驱动
MATERIAL_ID_CHARIOT       = 8    -- 战车驱动
MATERIAL_ID_ARTILLERY     = 9    -- 火炮驱动
MATERIAL_ID_ROCKETDRIVE   = 10   -- 火箭驱动

-----改造等级限制
PART_REFIT_LEVEL_LIMIT  = 4
PART_REFINE_LEVEL = 75

PartMO = {}

-- -- 各个品质下的配件可分解获得零件的数量，品质从白开始，白为1
-- PartQualityExplodeFitting = {0, 50, 300, 1000, 2000}

-- 各个品质下的碎片可分解获得零件的数量，品质从白开始，白为1
ChipQualityExplodeFitting = {0, 0, 100, 200, 1000}

PART_REFIT_DRAW_NUM = 5 -- 改造使用图纸保证不降低等级的图纸数量
PART_REFIT_REDUCE_UP_LEVEL = 3 --  改装不使用图纸降低强化等级数

-- 所有的部件
PartMO.part_ = nil

-- 四种类型的战车配件安装状态信息
PartMO.partData_ = nil

PartMO.chip_ = nil
-- 保存材料数量信息
PartMO.material_ = nil

PartMO.unlockPosition_ = 0  -- 有配件位置解锁，记录位置，用于界面显示

function PartMO.init()
	PART_REFIT_LEVEL_LIMIT  = UserMO.querySystemId(16)
	db_part_ = {}
	local records = DataBase.query(s_part)
	for index = 1, #records do
		local data = records[index]
		db_part_[data.partId] = data
	end

	db_part_up_ = {}
	local records = DataBase.query(s_part_up)
	for index = 1, #records do
		local data = records[index]

		if not db_part_up_[data.partId] then db_part_up_[data.partId] = {} end

		db_part_up_[data.partId][data.lv] = data
	end

	db_part_refit_ = {}
	local records = DataBase.query(s_part_refit)
	for index = 1, #records do
		local data = records[index]

		if not db_part_refit_[data.quality] then db_part_refit_[data.quality] = {} end
		if not db_part_refit_[data.quality][data.lv] then db_part_refit_[data.quality][data.lv] = {} end

		if data.nineOrTen then
			db_part_refit_[data.quality][data.lv][1] = data
		else
			db_part_refit_[data.quality][data.lv][0] = data
		end
	end

	db_part_quality_ = {}
	local records = DataBase.query(s_part_quality)
	for index = 1, #records do
		local data = records[index]
		db_part_quality_[data.partId] = data
	end

	db_part_smelt_ = {}
	local records = DataBase.query(s_part_smelting)
	for index = 1, #records do
		local data = records[index]
		db_part_smelt_[data.kind] = data
	end

	db_part_matrial_ = {}
	local records = DataBase.query(s_part_matrial)
	for index = 1, #records do
		local data = records[index]
		db_part_matrial_[data.id] = data
	end
end

function PartMO.queryPartById(partId)
	return db_part_[partId]
end

function PartMO.updateMatrial(data)
	local temp = PbProtocol.decodeArray(data)
	for k,v in ipairs(temp) do
		PartMO.material_[v.v1] = {id = v.v1,count = v.v2}
	end
	--没有的初始化
	for k,v in pairs(db_part_matrial_) do
		if not PartMO.material_[v.id] then
			PartMO.material_[v.id] = {id = v.id,count = 0}
		end
	end
end

function PartMO.queryMatrials()
	return table.keys(db_part_matrial_)
end

function PartMO.queryMatrialById(partId)
	return db_part_matrial_[partId]
end

function PartMO.querySmeltById(kind)
	return db_part_smelt_[kind]
end

function PartMO.queryQualityById(partId)
	return db_part_quality_[partId]
end

function PartMO.queryPartUp(partId, partLv)
	if not db_part_up_[partId] then return nil end
	return db_part_up_[partId][partLv]
end

function PartMO.queryPartUpMaxLevel(partId)
	if not db_part_up_[partId] then return 0 end
	return #db_part_up_[partId]
end

function PartMO.queryPartRefit(quality, partLv, partId)
	if not db_part_refit_[quality] then return nil end
	local partPos = PartMO.getPosByPartId(partId)
	if partPos > 8 then 
		return db_part_refit_[quality][partLv][1]
	end
	return db_part_refit_[quality][partLv][0]
end

function PartMO.queryPartRefitMaxLevel(quality)
	if not db_part_refit_[quality] then return 0 end

	return PART_REFIT_LEVEL_LIMIT
	-- return #db_part_refit_[quality]
end

function PartMO.getPartByKeyId(keyId)
	return PartMO.part_[keyId]
end

-- 根据配件的id获得配件所在的位置
function PartMO.getPosByPartId(partId)
	local partPos = math.floor(partId / 100)
	if partPos > 9 then  -- 9-10号配件特殊处理
		partPos = partPos - 1
	end
	return partPos
end

function PartMO.getKeyIdAtPos(type, partPos)
	if not PartMO.partData_ or not PartMO.partData_[type] then return 0 end
	return PartMO.partData_[type][partPos]
end

function PartMO.getFreeParts(type, partPos)
	local ret = {}
	if not PartMO.part_ then return ret end

	for keyId, part in pairs(PartMO.part_) do
		if part.typePos == 0 then
			if not type and not partPos then
				ret[#ret + 1] = part
			end
		end
	end

	return ret
end

-- 获得所有碎片, 如果有万能碎片则放在第一个
function PartMO.getAllChips()
	local ret = {}
	local allChip = nil
	for keyId, chip in pairs(PartMO.chip_) do
		if chip.chipId == PART_ID_ALL_PIECE then
			allChip = chip
		else
			if chip.count > 0 then
				ret[#ret + 1] = chip
			end
		end
	end
	if allChip and allChip.count > 0 then
		table.insert(ret, 1, allChip)
	end
	return ret
end

-- 获得配件位置pos开放等级
function PartMO.getOpenLv(pos)
	if pos == PART_POS_HP then return 18
	elseif pos == PART_POS_ATTACK then return 18
	elseif pos == PART_POS_DEFEND then return 20
	elseif pos == PART_POS_IMPALE then return 25
	elseif pos == PART_POS_HP_DEFEND then return 30
	elseif pos == PART_POS_ATTACK_IMPALE then return 40
	elseif pos == PART_POS_IMPALE_DEFEND then return 60
	elseif pos == PART_POS_ATTACK_HP then return 55
	elseif pos == PART_POS_HP_DEFEND_IMPALE then return 65
	elseif pos == PART_POS_ATTACK_DEFEND_IMPALE then return 68
	end
end

--获取进阶返还材料
function PartMO.getAdvReturn(part)
	local list = {}
	local lv = part.upLevel
	local refitLv = part.refitLevel
	--石头
	local max = 0
	for i=1,lv do
		local partUp = PartMO.queryPartUp(part.partId, i)
		max = max + partUp.stone
	end
	local qualityDB = PartMO.queryQualityById(part.partId)
	if max > 0 then
		table.insert(list,{ITEM_KIND_RESOURCE, RESOURCE_ID_STONE, math.floor(max*qualityDB.discont/100)})
	end
	--改造消耗
	local temp = {[MATERIAL_ID_PLAN]=0,[MATERIAL_ID_MINERAL]=0, [MATERIAL_ID_TOOL]=0, [MATERIAL_ID_FITTING]=0}
	for i=1,refitLv do
		local partDB = PartMO.queryPartById(part.partId)
		local partRefit = PartMO.queryPartRefit(partDB.quality, i, part.partId)
		temp[MATERIAL_ID_PLAN] = temp[MATERIAL_ID_PLAN] + partRefit.plan
		temp[MATERIAL_ID_MINERAL] = temp[MATERIAL_ID_MINERAL] + partRefit.mineral
		temp[MATERIAL_ID_TOOL] = temp[MATERIAL_ID_TOOL] + partRefit.tool
		temp[MATERIAL_ID_FITTING] = temp[MATERIAL_ID_FITTING] + partRefit.fitting
		if partRefit.cost and partRefit.cost ~= "" then
			for k,v in ipairs(json.decode(partRefit.cost)) do
				if temp[v[2]] then
					temp[v[2]] = temp[v[2]] + v[3]	
				else
					temp[v[2]] = v[3]	
				end
			end
		end
	end
	for k,v in pairs(temp) do
		if v > 0 then
			table.insert(list,{ITEM_KIND_MATERIAL, k, v})	
		end
	end
	return list
end

--获取淬炼最大值
function PartMO.getRefineMax(part,isData)
	local list = {}
	local partDB = PartMO.queryPartById(part.partId)
	local con = json.decode(partDB.s_attr)
	for k,v in ipairs(con) do
		local attId = v[1][1]
		if attId%2 == 0 then attId = attId - 1 end
		local name = AttributeMO.queryAttributeById(attId).desc
		if v[2][part.smeltLv+1] then
			if isData then
				list[v[1][1]] = v[2][part.smeltLv+1]
			else
				local ao = AttributeBO.getAttributeData(v[1][1],v[2][part.smeltLv+1],2)
				table.insert(list,{{content=string.format(CommonText[5023], name)..ao.strValue}})
			end
		end
	end
	return list
end

--获取淬炼属性
function PartMO.getRefineAttr(part,hasActive)
	local list = {}
	local partDB = PartMO.queryPartById(part.partId)
	local con = json.decode(partDB.s_attrCondition)
	local atts = {}
	local act = nil
	--包括激活属性
	if hasActive then
		act = PartMO.getActiveAttr(part,1)
	end
	if part.attr then
		for k,v in ipairs(part.attr) do
			local ex = nil
			if not part.saved then
				ex = v.newVal - v.val
			end
			atts[v.id] = {v.val,ex}
			if act and act[v.id] then
				atts[v.id][1] = atts[v.id][1] + act[v.id]
			end
		end
	end
	local maxAttr = PartMO.getRefineMax(part,1)
	for k,v in ipairs(con) do
		local attId = v[1][1]
		if attId%2 == 0 then attId = attId - 1 end
		local name = AttributeMO.queryAttributeById(attId).desc .. CommonText[176] ..":"
		local value = atts[v[1][1]] or {0}
		local flag = value[2] or 0
		local max = nil
		if maxAttr[v[1][1]] and maxAttr[v[1][1]] <= value[1] then
			max = true
		end
		for m,n in ipairs(value) do
			local ao = AttributeBO.getAttributeData(v[1][1],n,2)
			value[m] = ao.strValue
		end
		local limit = nil
		if (part.upLevel < v[2][1] or part.refitLevel < v[2][2]) and atts[v[1][1]] == nil then
			limit = string.format(CommonText[5011], v[2][1],v[2][2])
		end
		table.insert(list,{name=name,value=value,limit=limit,flag=flag,max=max})
	end
	return list
end

--获取激活属性
function PartMO.getActiveAttr(part,ifData)
	local partDB = PartMO.queryPartById(part.partId)
	-- print("PartMO.getActiveAttr part.keyId", part.keyId)
	-- print("PartMO.getActiveAttr part.partId", part.partId)
	local list = {}
	local data = {}
	local add = json.decode(partDB.unlockAttr)
	local con = json.decode(partDB.unlockAttrCondition)
	local atts = {}
	if part.attr then
		for k,v in ipairs(part.attr) do
			atts[v.id] = v.val
		end
	end
	for k,v in ipairs(add) do
		local id,value = v[1],v[2]
		if id%2 == 0 then id = id - 1 end
		local name = AttributeMO.queryAttributeById(id).desc
		local ao = AttributeBO.getAttributeData(v[1],v[2],2)
		local temp = {name = name .. CommonText[176] ..":",value = ao.strValue}
		local limit = con[k]
		if atts[limit[1]] and atts[limit[1]] >= limit[2] then
			data[v[1]] = v[2]
		else
			local tid,tval = limit[1],limit[2]
			if tid%2 == 0 then tid = tid - 1 end
			local ao = AttributeBO.getAttributeData(limit[1],limit[2],2)
			temp.limit = string.format(CommonText[5012], AttributeMO.queryAttributeById(tid).desc, ao.strValue)
		end
		table.insert(list,temp)
	end
	if ifData then
		return data
	end
	return list
end

--获取所有已装备的配件淬炼等级的总和
function PartMO.getAllPosedPartQuenchLv()
	local data = PartMO.partData_
	local lv = 0
	for index=1,#data do
		local record = data[index]
		for num=1,#record do
			local keyId = record[num]
			if keyId > 0 then
				local part = PartMO.getPartByKeyId(keyId)
				lv = lv + part.smeltLv
			end
		end
	end

	return lv
end