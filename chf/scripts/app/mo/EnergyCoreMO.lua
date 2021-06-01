--
-- Author: Gss
-- Date: 2019-04-09 11:33:13
--
-- 能源核心

local s_core_exp = require("app.data.s_core_exp")
local s_core_award = require("app.data.s_core_award")
local s_core_material = require("app.data.s_core_material")


local db_core_exp_ = nil
local db_core_award_ = nil
local db_core_material_ = nil

ENERGY_OPEN_ID_ROLELV        = 1 --角色等级
ENERGY_OPEN_ID_ENERGYLV      = 2 --能晶等级总
ENERGY_OPEN_ID_EQUIPLV       = 3 --装备等级总和
ENERGY_OPEN_ID_PARTQUENCHLV  = 4 --配件淬炼等级总和
ENERGY_OPEN_ID_EQUIPSTARLV   = 5 --装备星级等级总和
ENERGY_OPEN_ID_MEDALLV       = 6 --勋章等级总和
ENERGY_OPEN_ID_MEDALPOLISHLV = 7 --勋章打磨等级总和

EnergyCoreMO = {}

EnergyCoreMO.energyCoreData_ = {}

function EnergyCoreMO.init()

	db_core_exp_ = {}
	local records = DataBase.query(s_core_exp)
	for index = 1, #records do
		local data = records[index]
		db_core_exp_[data.id] = data
	end

	db_core_award_ = {}
	local records = DataBase.query(s_core_award)
	for index = 1, #records do
		local data = records[index]
		db_core_award_[data.id] = data
	end

	db_core_material_ = {}
	local records = DataBase.query(s_core_material)
	for index = 1, #records do
		local data = records[index]
		db_core_material_[data.id] = data
	end

end

--等级和阶段取经验值
function EnergyCoreMO.queryExpByLvAndSection(lv, section)
	local data = db_core_exp_
	for index=1,#db_core_exp_ do
		local record = db_core_exp_[index]
		if record.level == lv and record.section == section then
			return record
		end
	end

	return nil
end

--根据等级获得等级配置信息
function EnergyCoreMO.queryLvInfoByLv(lv)
	local data = db_core_award_
	for index=1,#db_core_award_ do
		local record = db_core_award_[index]
		if record.level == lv then
			return record
		end
	end

	if not lv then
		return data
	end

	return nil
end

--根据等级获取熔炼消耗品
function EnergyCoreMO.queryMeltingCostByLv(lv)
	local data = db_core_material_
	local cost = {}
	for index=1,#db_core_material_ do
		local record = db_core_material_[index]
		if record.level == lv then
			cost[#cost + 1] = record
		end
	end

	return cost
end

--一键填充
function EnergyCoreMO.queryOneFillByLv(lv)
	local lv = lv
	local totalCost = {}
	local costList = {}
	local data = EnergyCoreMO.queryMeltingCostByLv(lv)
	if not data then return end

	for index=1,#data do
		local record = data[index]
		local indexCost =  json.decode(record.material)
		totalCost[index] = indexCost
	end
	
	for idx=1,#totalCost do
		local param = totalCost[idx]
		for num=1,#param do
			local info = param[num]
			local own = UserMO.getResource(info[1],info[2])
			if own >= info[3] then --从前往后遍历
				costList[idx] = {v1 = info[1],v2 = info[2],v3 = info[3]}
				break
			end
		end
	end

	return costList
end

--等级显示处理
function EnergyCoreMO.formatEnergyCoreLv()
	local s = tostring(EnergyCoreMO.energyCoreData_.lv)
	local k = string.len(s)
	local list={}
	for i=1,k do
	    list[i]= string.sub(s,i,i)
	end

	local lvlab1 = ""
	local lvlab2 = ""
	if #list > 1 then
		lvlab1 = list[1]
		lvlab2 = list[2]
	else
		lvlab1 = 0
		lvlab2 = list[1]
	end

	return lvlab1, lvlab2
end

--根据条件类型获取能源核心开放信息条件(写死7种)
function EnergyCoreMO.queryOpenInfoBykind(kind)
	local num = 0

	if kind == ENERGY_OPEN_ID_ROLELV then
		num = UserMO.level_
	elseif kind == ENERGY_OPEN_ID_ENERGYLV then
		num = EnergySparMO.getAllEquipEnergySparsLv()
	elseif kind == ENERGY_OPEN_ID_EQUIPLV then
		num = EquipMO.getAllPosedEquipLv()
	elseif kind == ENERGY_OPEN_ID_PARTQUENCHLV then
		num = PartMO.getAllPosedPartQuenchLv()
	elseif kind == ENERGY_OPEN_ID_EQUIPSTARLV then
		num = EquipMO.getAllPosedEquipStarLv()
	elseif kind == ENERGY_OPEN_ID_MEDALLV then
		num = MedalMO.getAllPosedMedalLv()
	elseif kind == ENERGY_OPEN_ID_MEDALPOLISHLV then
		num = MedalMO.getAllPosedMedalFRefitLv()
	end

	return num
end

--当前等级的所有阶段经验和以及当前拥有的总经验
function EnergyCoreMO.getExpByLvAnd()
	local lv = EnergyCoreMO.energyCoreData_.lv
	local expAll = 0
	local needAll = 0

	--填满所需要的经验
	for index=1,4 do
		local lvinfo = EnergyCoreMO.queryExpByLvAndSection(lv, index)
		expAll = expAll + lvinfo.exp
	end

	--当前的总经验
	local ownAll = EnergyCoreMO.energyCoreData_.exp
	for index=1,EnergyCoreMO.energyCoreData_.section do
		local lvinfo = EnergyCoreMO.queryExpByLvAndSection(lv, index)
		if index < EnergyCoreMO.energyCoreData_.section then
			ownAll = ownAll + lvinfo.exp
		end
	end

	return expAll ,ownAll
end

--计算完成奖励属性加成 逐级累加
function EnergyCoreMO.getEnergyCoreAttr()
	-- local data = db_core_award_

	-- local nowLight = json.decode(data[EnergyCoreMO.energyCoreData_.lv].lightAward)  --当前等级的点亮属性加上小于这个等级的点亮属性
	-- local totalLight = {} 
	-- local totalFinish = {}

	-- if EnergyCoreMO.energyCoreData_.lv <= 1 and EnergyCoreMO.energyCoreData_.section < 2 then
	-- 	return totalFinish
	-- end

	-- for num=1,#nowLight do
	-- 	totalLight[num] = {nowLight[num][1],nowLight[num][2]*(EnergyCoreMO.energyCoreData_.section - 1)}
	-- end

	-- local lv = EnergyCoreMO.energyCoreData_.lv
	-- local maxState = EnergyCoreMO.energyCoreData_.state
	-- local needLv = lv
	-- if maxState ~= 1 then --如果是满级了
	-- 	needLv = needLv - 1
	-- end

	-- for index=1,needLv do
	-- 	local record = EnergyCoreMO.queryLvInfoByLv(index)
		-- local lightAttr = json.decode(record.lightAward)
		-- local finishAttr = json.decode(record.finishAward)

		-- for k,v in pairs(lightAttr) do
		-- 	local isSame = false
		-- 	for a,b in pairs(totalLight) do
		-- 		if b[1] == v[1] then
		-- 			b[2] = b[2] + v[2] * 4
		-- 			isSame = true
		-- 			break
		-- 		end
		-- 	end

		-- 	local data = {v[1],v[2] * 4}
		-- 	if not isSame then
		-- 		table.insert(totalLight, data)
		-- 	end
		-- end

	-- 	for k,v in pairs(finishAttr) do
	-- 		if #totalFinish <= 0 then
	-- 			totalFinish = finishAttr
	-- 			break
	-- 		end

	-- 		local isSame = false
	-- 		for a,b in pairs(totalFinish) do
	-- 			if b[1] == v[1] then
	-- 				b[2] = b[2] + v[2]
	-- 				isSame = true
	-- 				break
	-- 			end
	-- 		end

	-- 		if not isSame then
	-- 			table.insert(totalFinish, v)
	-- 		end
	-- 	end
	-- end

	-- for k,v in pairs(totalLight) do
	-- 	local isSame = false
	-- 	for a,b in pairs(totalFinish) do
	-- 		if b[1] == v[1] then
	-- 			b[2] = b[2] + v[2] * 4
	-- 			isSame = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if not isSame then
	-- 		table.insert(totalFinish, v)
	-- 	end
	-- end

-------------------------上面那套算法不要删除，备用，免得策划又反悔修改-------------------------
-- 下面是算总的完成奖励的属性
	local totalFinish = {}

	local lv = EnergyCoreMO.energyCoreData_.lv
	local maxState = EnergyCoreMO.energyCoreData_.state
	local needLv = lv
	if maxState ~= 1 then --如果是满级了
		needLv = needLv - 1
	end

	for index=1,needLv do
		local record = EnergyCoreMO.queryLvInfoByLv(index)
		local finishAttr = json.decode(record.finishAward)

		for k,v in pairs(finishAttr) do
			if #totalFinish <= 0 then
				totalFinish = finishAttr
				break
			end

			local isSame = false
			for a,b in pairs(totalFinish) do
				if b[1] == v[1] then
					b[2] = b[2] + v[2]
					isSame = true
					break
				end
			end

			if not isSame then
				table.insert(totalFinish, v)
			end
		end
	end

	return totalFinish
end

--获得每个位置的属性加成（这里逻辑有点冗杂，我不知道怎么写备注了。主要是因为策划的需求让我蛋疼）
function EnergyCoreMO.getEnergyCoreAttrByPos(posIndex)
	local lv = EnergyCoreMO.energyCoreData_.lv
	local section = EnergyCoreMO.energyCoreData_.section
	local finishAttr = EnergyCoreMO.getEnergyCoreAttr() --熔炼完成奖励
	local totalAttr = {} --初始化6个位置
	
	if lv <= 1 and section < 2 then return totalAttr end

	local function getbyPos(pos)
		local attrindex = {}
		for num = 1,lv do
			local record = EnergyCoreMO.queryLvInfoByLv(num)
			if record.index == pos then
				local variable = 4 --初始4,默认是满阶段
				if num == lv then --如果是当前等级，判断是第几阶段。系数就定为几
					variable = section - 1
				end

				if variable == 0 then
					break
				end
				
				local att = json.decode(record.lightAward) --当前级数的点亮奖励
				local sectionAtt = {}
				for a=1,#att do
					local v = att[a]
					sectionAtt[a] = {v[1], v[2] * variable} --实际加的属性为:表配置里的*系数
				end

				attrindex[#attrindex + 1] = sectionAtt --包装进去用于后面的计算
			end
		end

		return attrindex
	end

	for pos = 1 , 6 do --初始6个位置
		local myattr = getbyPos(pos)
		local indexAttrr = {} --每一个位置的属性
		local attrData = {} --每一个位置的属性格式化

		for index = 1 , #myattr do
			local att = myattr[index]
			for k,v in pairs(att) do
				local isSame = false
				for a,b in pairs(indexAttrr) do
					if b[1] == v[1] then
						b[2] = b[2] + v[2]
						isSame = true
						break
					end
				end
				if not isSame then
					table.insert(indexAttrr, v)
				end
			end
		end

		--完成奖励的属性加成，数据合并
		for k,v in pairs(finishAttr) do
			local isSame = false
			for a,b in pairs(indexAttrr) do
				if b[1] == v[1] then
					b[2] = b[2] + v[2]
					isSame = true
					break
				end
			end
			if not isSame then
				table.insert(indexAttrr, v)
			end
		end

		for windex = 1 , #indexAttrr do
			local attr = indexAttrr[windex]
			local attrid = attr[1]
			local attrvalue = attr[2]
			local att = AttributeBO.getAttributeData(attrid, attrvalue)
			attrData[#attrData + 1] = att
		end

		totalAttr[pos] = attrData
	end

	if not posIndex then return totalAttr end
	return totalAttr[posIndex]
end

--获取当前等级,当前格子，熔炼需要消耗的所有物品
function EnergyCoreMO.getMeltingInfoByLoc(loc)
	local consume = {}
	local lv = EnergyCoreMO.energyCoreData_.lv
	local data = EnergyCoreMO.queryMeltingCostByLv(lv)
	if not data then return consume end

	for index=1,#data do
		local record = data[index]
		if record.loc == loc then
			consume = record
			return consume
		end
	end

	return consume
end

--能源核心战力属性格式转化
function EnergyCoreMO.getEnergyCoreCombatAttr()
	local ret1 = {}
	local ret = {}
	local attr = EnergyCoreMO.getEnergyCoreAttr()


	for index=1,#attr do
		local att = AttributeBO.getAttributeData(attr[index][1], attr[index][2])
		ret1[att.id] = att
	end

	for m,n in pairs(ret1) do
		if not ret[m] then 
			ret[m] = clone(n) 
		else
			if type(n) == "number" then
				ret[m] = ret[m] + n
			else
				ret[m].value = ret[m].value + n.value
				ret[m].strValue = AttributeBO.formatAttrValue(ret[m].id, ret[m].value)
			end
		end
	end

	return ret
end

--用于计算战力
function EnergyCoreMO.getFightAttr(index)
	local attrs = EnergyCoreBO.energyCorePosAttrs[index] or {}
	return attrs 
end