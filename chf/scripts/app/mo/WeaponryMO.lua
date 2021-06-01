--
-- Author: wz
-- Date: 2016-12-21 19:15:02
--
WeaponryMO = {}

WeaponryMO.level_ = 20 --开启等级
WeaponryMO.WeaponryList = {}

WEAPONRY_STORE	= 0 --仓库
WEAPONRY_SHOW	= 1 --身上

WEAPONRY_SECOND_SETTYPE_INDEX = 1 -- 单个军备的洗练套装属性设置
WEAPONRY_SECOND_SETTYPE_ALL = 2   -- 全部在穿军备的洗练套装属性设置

FIGHT_WEPONRYSCHEME_POS_NUM = 8

local s_weaponry = require("app.data.s_lord_equip")
local s_weaponry_matrial = require("app.data.s_lord_equip_material")
local s_weaponry_technical = require("app.data.s_lord_equip_technical")
local s_weaponry_formula = require("app.data.s_formula")
local s_weaponry_equip_change = require("app.data.s_lord_equip_change")
local s_weaponry_equip_skill = require("app.data.s_lord_equip_skill")

WeaponryMO.schemesAll = nil


local d_weaponry = nil
local d_weaponry_matrial = nil
local d_weaponry_Paper = nil
local d_weaponry_technical = nil
local d_weaponry_formula = nil
local d_weaponry_change = nil
local d_weaponry_skill = nil

function WeaponryMO.init()
	d_weaponry = {}
	local records = DataBase.query(s_weaponry)
	for index = 1, #records do
		local data = records[index]
		d_weaponry[data.id] = data
	end

	d_weaponry_matrial = {}
	d_weaponry_Paper = {}
	local records = DataBase.query(s_weaponry_matrial)
	for index = 1, #records do
		local data = records[index]
		if data.tag == 1 then --材料
			d_weaponry_matrial[data.id%1000] = data
		end
		-- elseif  data.tag == 2 then
		d_weaponry_Paper[data.id] = data
		-- end
	end

	d_weaponry_technical = {}
	local records = DataBase.query(s_weaponry_technical)
	for index = 1, #records do
		local data = records[index]
		d_weaponry_technical[data.id] = data
	end

	d_weaponry_formula = {}
	local records = DataBase.query(s_weaponry_formula)
	for index = 1, #records do
		local data = records[index]
		d_weaponry_formula[data.id] = data
	end

	d_weaponry_change = {}
	local records = DataBase.query(s_weaponry_equip_change)
	for index = 1, #records do
		local data = records[index]
		d_weaponry_change[data.id] = data
	end

	d_weaponry_skill = {}
	local records = DataBase.query(s_weaponry_equip_skill)
	for index = 1, #records do
		local data = records[index]
		d_weaponry_skill[data.id] = data
	end
end

--洗练数据
function WeaponryMO.queryChangeById(id)
	return d_weaponry_change[id]
end

--洗练技能(军备技能)
--洗练技能
function WeaponryMO.queryChangeSkillById(id)
	return d_weaponry_skill[id]
end

-- 军备合成分解公式
function WeaponryMO.queryUp(id)
	return d_weaponry_formula[id]
end

-- 根据装备ID 获取装备表
function WeaponryMO.queryById(equipId)
	return d_weaponry[equipId]
end

function WeaponryMO.queryWeaponry()
	local d_prop = {}
	local d_temp = {}
	for key , data in pairs(d_weaponry) do
		local upt = WeaponryMO.queryUp(data.formula)
		if  UserMO.level_ >= upt.level then
			d_prop[#d_prop + 1] = data
		else
			d_temp[#d_temp + 1] = data
		end
	end

	function sortfunction(a,b)
		if a.quality  == b.quality then  
			return a.id < b.id
		else
			return a.quality < b.quality
		end
	end 
	table.sort(d_prop, sortfunction )

	function sortfunction1(a,b)
		if a.level  == b.level then  
			return a.id < b.id
		else
			return a.level < b.level
		end
	end 
	table.sort(d_temp, sortfunction1 )

	if d_temp[1] then table.insert(d_prop,d_temp[1]) end

	return d_prop
end

function WeaponryMO.needMaterials(id)
	local upt = WeaponryMO.queryUp(id)
	return upt.materials
end

-- 材料
function WeaponryMO.queryMatrial()
	return d_weaponry_matrial
end

function WeaponryMO.queryMatrialById(id)
	return d_weaponry_matrial[id]
end

function WeaponryMO.queryPaper()
	return d_weaponry_Paper
end

function WeaponryMO.queryPaperById(id)
	return d_weaponry_Paper[id]
end

function WeaponryMO.getEmploy()
	return d_weaponry_technical
end

function WeaponryMO.getEmployById(id)
	return d_weaponry_technical[id]
end


-- 根据品质获取背包中的军备
function WeaponryMO.getPosWithQuality(quality)
	local idles = WeaponryMO.getFreeMedals()
	dump(idles)
	local outlist = {}
	for index=1, #idles do
		local data = idles[index]
		local equ = WeaponryMO.queryById(data.equip_id)
		if equ.quality == quality then
			outlist[#outlist + 1] = data
		end
	end
	return outlist
end


-- 判断是否可以穿戴该装备
function WeaponryMO.canUseByLv(keyId)
	if UserMO.level_ <  WeaponryMO.queryById(keyId).level then
		return false
	end
	return true
end

--获取仓库里装备
function WeaponryMO.getFreeMedals()
	local medals = {}
	for k, v in pairs(WeaponryMO.WeaponryList) do
		if v.pos == 0 then
			medals[#medals + 1] = v
		end
	end 
	return medals
end

--获取身上的装备
function WeaponryMO.getShowMedals(pos)
	pos = pos or -1
	local medals = {}
	for k, v in pairs(WeaponryMO.WeaponryList) do
		if v.pos == pos or v.pos > 0 then
			medals[v.pos] = v
		end
	end 
	return medals
end

-- --区分图纸和材料(判断)
-- function WeaponryMO.getChipById()
-- 	return 
-- end

--图纸(2)，材料（1）
function WeaponryMO.getAllChipsByType(_type)
	local chips = {}
	for k,v in pairs(WeaponryMO.queryPaper()) do
		local type1 =  WeaponryMO.queryPaperById(v.id).tag
		if type1  == _type then
			local count1 = 0
			if WeaponryBO.Weaponryprop[v.id] then
				count1 = WeaponryBO.Weaponryprop[v.id].count	
			end
			if count1 ~= 0 then
				table.insert(chips, {propId = v.id,count = count1})
			end
		end
	end
	return chips
end


-- 获取要分解军备
-- 返回列表和品质
function WeaponryMO.getResolve(keyId)
	local medal = WeaponryMO.WeaponryList[keyId]
	local md = WeaponryMO.queryById(medal.equip_id)
	local upt = WeaponryMO.queryUp(md.formula)
	local ret = {}
	for k,v in ipairs(json.decode(upt.rslFix)) do
		ret[#ret + 1] = {type = v[1],id = v[2],count = v[3]}
	end
	return ret , md.quality
end

-- 根据装备ID 
-- 查看指定装备的数量
function WeaponryMO.getWeaponryCount(_equipId)
	local count = 0 
	for k , v in pairs(WeaponryMO.WeaponryList) do
		if v.equip_id == _equipId then
			count = count + 1
		end
	end
	return count
end


-- function WeaponryMO.updateMaxTechBypros()	
-- 	local ret = nil
-- 	for k,v in pairs(WeaponryMO.getEmploy()) do
-- 		if v.prosLevel <= UserBO.getProsperousLevel(UserMO.maxProsperous_)  then
-- 			if ret ~= nil then
-- 				ret = math.max(ret,v.id) 
-- 			else
-- 				ret = v.id
-- 			end
-- 		end
-- 		if UserBO.getProsperousLevel(UserMO.maxProsperous_) == 0 then
-- 			ret = 1001
-- 		end
-- 	end
-- 	if ret == nil then
-- 		ret = 1010
-- 	end
-- 	return ret
-- end

function WeaponryMO.getEmptyWeaponryScheme()
	local format = {}
	local leq = {}
	for index = 1, FIGHT_WEPONRYSCHEME_POS_NUM do
		leq[index] = {pos = index, keyId = 0}
	end

	format.leq = leq
	return format
end

-- 将套装解析为服务器格式
function WeaponryMO.encodeWeaponryScheme(scheme)
	local format = {}
	local out = {}

	for k,v in pairs(scheme.leq) do
		if v.pos > 0 and v.keyId > 0 then
			out[#out + 1] = {v1 = v.pos, v2 = v.keyId}
		else
			out[#out + 1] = {v1 = v.pos, v2 = 0}
		end
	end

	if scheme.name then
		format.name = scheme.name
	end

	format.leq = out
	format.type = scheme.type

	return format
end

--获取可进行二次洗练属性解锁的军备
function WeaponryMO.getCanSecondWeaponrys()
	local secondWeaponrys = {}
	for k,v in pairs(WeaponryMO.WeaponryList) do
		local data = WeaponryMO.queryById(v.equip_id)

		local out = {}
		out.equip_id = v.equip_id				              --装备ID
		out.keyId = v.keyId 					              --绝对ID
		out.pos = v.pos 						              --位置
		out.skillLv = v.skillLv 			 	              --技能列表
		out.name = data.name 					              --装备名称
		out.quality = data.quality 				              --装备品质
		out.atts = data.atts 					              --装备属性
		out.tankCount = data.tankCount 			              --带兵量
		out.level = data.level 					              --装备可穿戴等级
		out.normalBox = data.normalBox 			              --普通格子技能格子
		out.superBox = data.superBox			              --是否可以神秘洗练 1可以2不能
		out.maxSkillLevel = data.maxSkillLevel	              --洗练技能等级上限
		out.isLock = v.isLock                                 --是否锁定
		out.lordEquipSaveType = v.lordEquipSaveType or 0      --当前设置的是第几套属性
		out.skillLvSecond = v.skillLvSecond or {}             --第二套技能列表

		local isMax = true
		local skills = PbProtocol.decodeArray(v.skillLv)
		if #skills == 4 then
			for idx=1,#skills do
				if skills[idx].v2 ~= data.maxSkillLevel or data.quality ~= 5 then  --全满级。且橙色品质
					isMax = false
					break
				end
			end
		else
			isMax = false
		end

		if isMax then
			secondWeaponrys[#secondWeaponrys + 1] = out
		end
	end

	return secondWeaponrys
end

--根据军备ID获取用于解锁二套属性可消耗的军备
function WeaponryMO.getCostWeaponrysById(eq_lordId)
	if not eq_lordId then return end
	local costWeaponrys = {}
	for k,v in pairs(WeaponryMO.WeaponryList) do
		local data = WeaponryMO.queryById(v.equip_id)
		local isMax = true
		local skills = PbProtocol.decodeArray(v.skillLv)
		if #skills == 4 then
			for idx=1,#skills do
				if skills[idx].v2 ~= data.maxSkillLevel or v.equip_id ~= eq_lordId or v.pos ~= 0 then  --全满级。且ID相同，且未穿戴
					isMax = false
					break
				end
			end
		else
			isMax = false
		end

		if isMax then
			costWeaponrys[#costWeaponrys + 1] = v
		end
	end

	local function sortFun(a, b)
		return a.keyId < b.keyId
	end
	table.sort(costWeaponrys, sortFun)

	return costWeaponrys[1]
end

--判断穿在身上的军备是否有解锁二套洗练了的
function WeaponryMO.isHasSecondWeaponrys()
	local list = WeaponryMO.getShowMedals()
	local has = false
	for k,v in pairs(list) do
		if table.isexist(v, "skillLvSecond") then
			has = true
			break
		end
	end
	return has
end