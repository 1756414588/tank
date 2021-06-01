--
-- Author: Gss
-- Date: 2018-12-12 16:33:37
--
-- 战术 TacticsMO

local s_tactics = require("app.data.s_tactics") --战术
local s_tactics_break = require("app.data.s_tactics_break") --突破
local s_tactics_matrial = require("app.data.s_tactics_matrial") --材料
local s_tactics_uplv = require("app.data.s_tactics_uplv") --升级
local s_tactics_tacticsRestrict = require("app.data.s_tactics_tacticsRestrict") --克制
local s_tactics_tankSuit = require("app.data.s_tactics_tankSuit") --套装

local db_tactics_ = nil
local db_tactics_materials_ = nil
local db_tactics_uplv_ = nil
local db_tactics_break_ = nil
local db_tactics_tankSuit_ = nil
local db_tactics_tacticsRestrict_ = nil

-- 战术适用兵种类型
TACTICS_TYPE_ALL       = 1 -- 全部
TACTICS_TYPE_TANK      = 2 -- 坦克
TACTICS_TYPE_CHARIOT   = 3 -- 战车
TACTICS_TYPE_ARTILLERY = 4 -- 火炮
TACTICS_TYPE_ROCKET    = 5 -- 火箭

-- 战术类型
TACTICS_TYPE_1         = 1 -- 攻击1
TACTICS_TYPE_2         = 2 -- 防御1
TACTICS_TYPE_3         = 3 -- 攻击2
TACTICS_TYPE_4         = 4 -- 防御2

TACTICS_ID_ALL_PIECE   = 901 -- 万能碎片

VIEW_FOR_SEE     = 1  -- 查看
VIEW_FOR_WEAR    = 2  -- 穿戴
VIEW_FOR_EXC     = 3  -- 替换卸下


TACTIC_FORMATION_MAX_NUM     = 8  -- 有8个战术阵型
TACTIC_CANUSE_MAX_NUM     = 6  -- 有6个个战术位置可用

TacticsMO = {}

TacticsMO.tactics_ = {}       --战术
TacticsMO.materials_ = {}     --战术碎片
TacticsMO.pieces_ = {}        --战术材料
TacticsMO.TacticForms_ = {}   --战术阵型

TacticsMO.tacticSynHandler_ = nil

function TacticsMO.init()
	db_tactics_ = {}
	local records = DataBase.query(s_tactics)
	for index = 1, #records do
		local data = records[index]
		db_tactics_[data.tacticsId] = data
	end

	db_tactics_materials_ = {}
	local records = DataBase.query(s_tactics_matrial)
	for index = 1, #records do
		local data = records[index]
		db_tactics_materials_[data.id] = data
	end

	db_tactics_uplv_ = {}
	local records = DataBase.query(s_tactics_uplv)
	for index = 1, #records do
		local data = records[index]
		db_tactics_uplv_[data.keyId] = data
	end

	db_tactics_break_ = {}
	local records = DataBase.query(s_tactics_break)
	for index = 1, #records do
		local data = records[index]
		db_tactics_break_[data.keyId] = data
	end


	db_tactics_tacticsRestrict_ = {}
	local records = DataBase.query(s_tactics_tacticsRestrict)
	for index = 1, #records do
		local data = records[index]
		db_tactics_tacticsRestrict_[data.Id] = data
	end

	db_tactics_tankSuit_  ={}
	local records = DataBase.query(s_tactics_tankSuit)
	for index = 1, #records do
		local data = records[index]
		db_tactics_tankSuit_[data.Id] = data
	end
end

--战术ID索取战术信息
function TacticsMO.queryTacticById(id)
	return db_tactics_[id]
end

--材料展示
function TacticsMO.queryTacticMaterialsById(id)
	if not id then return db_tactics_materials_ end
	return db_tactics_materials_[id]
end

function TacticsMO.updateMatrial(data)
	for k,v in ipairs(data) do
		TacticsMO.materials_[v.v1] = v.v2
	end
	--没有的初始化
	for k,v in pairs(db_tactics_materials_) do
		if not TacticsMO.materials_[v.id] then
			TacticsMO.materials_[v.id] = 0
		end
	end
end

--根据类型获取战术
--坦克类型
--属性类型
function TacticsMO.getTacticsByKind(tankTyke, tacticType, formation)
	local data = {}
	for k,v in pairs(TacticsMO.tactics_) do
		local tactic = TacticsMO.queryTacticById(v.tacticsId)
		-- if tactic.tanktype == tankTyke and tactic.tacticstype == tacticType and v.use == 0 then
		if tactic.tanktype == tankTyke and tactic.tacticstype == tacticType then
			v.quality = tactic.quality
			data[#data + 1] = v
		end
	end

	--排除掉已经在部队装备上的
	if formation and formation.tacticsKeyId then
		for index=1,#formation.tacticsKeyId do
			for k,v in pairs(data) do
				if formation.tacticsKeyId[index] == v.keyId then
					table.remove(data,k)
					break
				end
			end
		end
	end
	return data
end

--获取根据类型获取战术碎片
function TacticsMO.getTacticsPiecesByKind(tankTyke, tacticType)
	local data = {}
	for k,v in pairs(TacticsMO.pieces_) do
		local tactic = TacticsMO.queryTacticById(k)
		if tactic.tanktype == tankTyke and tactic.tacticstype == tacticType then
			tactic.count = v
			data[#data + 1] = tactic
		end
	end
	return data
end

function TacticsMO.getTacticByKeyId(keyId)
	if not keyId then return nil end
	for k,v in pairs(TacticsMO.tactics_) do
		if v.keyId == keyId then
			return v
		end
	end
end

--根据keyId, 计算出某个战术的属性加成
function TacticsMO.getTacticAttrByKeyId(keyId,lv)
	lv = lv or false
	local tactic = TacticsMO.getTacticByKeyId(keyId)
	if not tactic then return end
	local tacticDB = TacticsMO.queryTacticById(tactic.tacticsId)

	local baseAttr = json.decode(tacticDB.attrBase)
	local lvAttr = json.decode(tacticDB.attrLv)
	local tacticLv = tactic.lv
	if lv then
		tacticLv = tactic.lv + 1
	end

	for index=1,#baseAttr do
		local attr1 = baseAttr[index]
		for a=1,#lvAttr do
			if attr1[1] == lvAttr[a][1] then
				baseAttr[index] = {attr1[1], attr1[2] + lvAttr[a][2] * tacticLv}
				break
			end
		end
	end

	return baseAttr
end

--获取所有的可用于升级消耗的战术,
function TacticsMO.getConsumeTactics(keyId, formation)
	local data = {}
	for k,v in pairs(TacticsMO.tactics_) do
		local tactic = TacticsMO.queryTacticById(v.tacticsId)
		-- if v.use == 0 and v.keyId ~= keyId then --没佩戴，不是同一keyId
		if v.keyId ~= keyId and v.bind == 0 then --没佩戴，不是同一keyId , 没锁定
			v.quality = tactic.quality
			v.count = 1
			data[#data + 1] = v
		end
	end

	--排除掉已经在部队装备上的
	if formation and formation.tacticsKeyId then
		for index=1,#formation.tacticsKeyId do
			for k,v in pairs(data) do
				if formation.tacticsKeyId[index] == v.keyId then
					table.remove(data,k)
					break
				end
			end
		end
	end

	--排除掉已经在阵型内的
	-- for k,v in pairs(TacticsMO.TacticForms_) do
	-- 	local tacticsKeyId = v.keyId
	-- 	for index=1,#tacticsKeyId do
	-- 		for a,b in pairs(data) do
	-- 			if tacticsKeyId[index] == b.keyId then
	-- 				table.remove(data,a)
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end

	return data
end

--获取所有的可用于升级消耗的战术碎片
function TacticsMO.getConsumeTacticPieces()
	local data = {}
	for k,v in pairs(TacticsMO.pieces_) do
		local tactic = TacticsMO.queryTacticById(k)
		tactic.count = v
		data[#data + 1] = tactic
	end
	return data
end

--是否有当前品质的战术碎片或战术
function TacticsMO.getTacticQualityState(taticType,quality,keyId, formation)
	local state = false
	local tempTactics = {}
	if taticType == 1 then
		for k,v in pairs(TacticsMO.pieces_) do
			local tactic = TacticsMO.queryTacticById(k)
			if tactic.quality == quality then
				state = true
				break
			end
		end
	else
		for k,v in pairs(TacticsMO.getConsumeTactics(keyId,formation)) do
			local tactic = TacticsMO.queryTacticById(v.tacticsId)
			if tactic.quality == quality then
				state = true
				break
			end
		end
	end
	return state
end
--是否有当前兵种的战术碎片或战术
function TacticsMO.getTacticTankTypeState(taticType,quality,tankType,keyId, formation)
	local state = false
	if taticType == 1 then
		for k,v in pairs(TacticsMO.pieces_) do
			local tactic = TacticsMO.queryTacticById(k)
			if tactic.tanktype == tankType and tactic.quality == quality then
				state = true
				break
			end
		end
	else
		for k,v in pairs(TacticsMO.getConsumeTactics(keyId,formation)) do
			local tactic = TacticsMO.queryTacticById(v.tacticsId)
			if tactic.tanktype == tankType and tactic.quality == quality then
				state = true
				break
			end
		end
	end
	return state
end


--获取等级信息
function TacticsMO.getLvInfoByLv(quality, level)
	local data = db_tactics_uplv_
	for k,v in pairs(data) do
		if v.lv == level and v.quality == quality then
			return v
		end
	end

	return nil
end

--得出当前品质升级限制
function TacticsMO.getMaxLvByQuality(quality)
	local data = db_tactics_uplv_
	local info = {}
	for k,v in pairs(data) do
		if v.quality == quality then
			info[#info + 1] = v
		end
	end

	local function sortFun(a,b)
		return a.lv < b.lv
	end

	table.sort(info,sortFun)
	return info
end

--计算出某个keyId战术的所加经验
function TacticsMO.getOfferExpByKeyId(keyId)
	local db = TacticsMO.getTacticByKeyId(keyId)
	local lvExp = TacticsMO.getLvInfoByLv(db.quality, db.lv).expOffer
	local totalExp = db.exp + lvExp
	return totalExp
end

--计算出下一突破等级上限
function TacticsMO.getNextBreakByLv(quality, lv)
	local data = db_tactics_uplv_
	local info = {}
	for k,v in pairs(data) do
		if v.quality == quality and v.breakOn == 1 then
			info[#info + 1] = v
		end
	end

	local function sortFun(a,b)
		return a.lv < b.lv
	end

	table.sort(info,sortFun)

	for index=1,#info do
		if info[index].lv == lv then
			if info[index + 1] then
				return info[index + 1].lv
			end
		end
	end

	if lv == info[#info].lv then --最大突破上限
		local maxLvInfo = TacticsMO.getMaxLvByQuality(quality)
		local maxLv = maxLvInfo[#maxLvInfo].lv
		return maxLv
	end


	return 0
end

-- 品质，战术类型和等级获得突破消耗
function TacticsMO.getBreakCostByLv(quality,tacticsType,lv)
	local data = db_tactics_break_

	for k,v in pairs(data) do
		if v.quality == quality and v.tacticsType == tacticsType and v.lv == lv then
			return v
		end
	end

	return nil
end

--计算兵种套装加成属性,战术、品质和兵种(1-5)
function TacticsMO.getAttrByQuality(tacticType, quality, tankType)
	local configInfo = db_tactics_tankSuit_
	local attr = {}
	for k,v in pairs(configInfo) do
		if v.quality == quality and v.tankType == tankType and v.tacticsType == tacticType then
			attr = json.decode(v.attrUp)
		end
	end

	return attr
end

--判断当前阵型中是否有战术套装
function TacticsMO.isTacticSuit(formation,hasAttr)
	local has = hasAttr or false
	local tactics = formation.tacticsKeyId
	local isSuit = true
	if #tactics < 6 then  -- 如果是少于6个的
		return false
	end
	for index =1, #tactics do
		local tac = TacticsMO.getTacticByKeyId(tactics[index])
		if not tac then
			isSuit = false
			break
		end
		local tacDB = TacticsMO.queryTacticById(tac.tacticsId)
		for idx =index + 1, #tactics do
			local tac2 = TacticsMO.getTacticByKeyId(tactics[idx])
			if tac2 then
				local tacDB2 = TacticsMO.queryTacticById(tac2.tacticsId)
				if tacDB.tacticstype ~= tacDB2.tacticstype then
					isSuit = false
					break
				end
			end
		end
	end

	--如果是套装，算出战术套装的战术类型
	if isSuit then
		local tacticstype
		local tac = TacticsMO.getTacticByKeyId(tactics[1])
		local tacDB = TacticsMO.queryTacticById(tac.tacticsId)
		tacticstype = tacDB.tacticstype

		if has then
			return tacticstype
		end
	end

	return isSuit
end

--判断当前阵型中是否有兵种套装
function TacticsMO.isArmsSuit(formation, hasAttr)
	local has = hasAttr or false
	local tactics = formation.tacticsKeyId
	local isSuit = true

	if #tactics < 6 then  -- 如果是少于6个的
		return false
	end
	for index =1, #tactics do
		local tac = TacticsMO.getTacticByKeyId(tactics[index])
		if not tac then
			isSuit = false
			break
		end
		local tacDB = TacticsMO.queryTacticById(tac.tacticsId)
		for idx =index + 1, #tactics do
			local tac2 = TacticsMO.getTacticByKeyId(tactics[idx])
			if tac2 then
				local tacDB2 = TacticsMO.queryTacticById(tac2.tacticsId)
				if tacDB.tanktype ~= tacDB2.tanktype then
					isSuit = false
					break
				end
			end
		end
	end

	if isSuit then
		local info = {}
		for num=1,#tactics do
			local tac = TacticsMO.getTacticByKeyId(tactics[num])
			local tacDB = TacticsMO.queryTacticById(tac.tacticsId)
			info[#info + 1] = tacDB
		end

		local function sortFun(a,b)
			return a.quality < b.quality
		end

		table.sort(info,sortFun)

		if has then
			return info[1].quality, info[1].tanktype  --返回坦克套装类型和最小的品质(用于根据品质和坦克兵种类型计算加成的属性)
		end
	end

	return isSuit
end

--计算属性加成
function TacticsMO.getTacticAttr(formation)
	local ret = {}
	if not formation or not formation.tacticsKeyId or #formation.tacticsKeyId <= 0 then return ret end
	local tactics = formation.tacticsKeyId

	local quality, tankType = TacticsMO.isArmsSuit(formation, true)  --兵种类型
	local isTacticSuit = TacticsMO.isTacticSuit(formation, true) --战术类型
	
	local otherAttr = {}
	if isTacticSuit then
		-- otherAttr = TacticsMO.getAttrByQuality(quality, tankType)
		local record = TacticsMO.getTacticsRestricts(isTacticSuit)
		otherAttr = json.decode(record.attrSuit)
	end

	local suitAttr = {}
	local length = 0
	if #otherAttr > 0 then
		for atNum=1,#otherAttr do
			local att = AttributeBO.getAttributeData(otherAttr[atNum][1], otherAttr[atNum][2])
			suitAttr[att.id] = att
			length = length + 1
		end
	end

	for index=1,#tactics do
		if tactics[index] > 0 then
			local attr = TacticsMO.getTacticAttrData(tactics[index])
			for m,n in pairs(attr) do
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
		end
	end

	-- if length > 0 then --套装属性(备用。不删除)
	-- 	for k,v in pairs(ret) do
	-- 		local has = false
	-- 		for a,b in pairs(suitAttr) do
	-- 			if a == k then
	-- 				v.value = v.value + b.value
	-- 				v.strValue = AttributeBO.formatAttrValue(v.id, v.value)
	-- 				has = true
	-- 				break
	-- 			end

	-- 			if not has then
	-- 				ret[a] = b
	-- 			end
	-- 		end
	-- 	end
	-- end

	return ret
end

--算得keyId的属性加成
function TacticsMO.getTacticAttrData(keyId)
	local ret = {}
	local attr = TacticsMO.getTacticAttrByKeyId(keyId) or {}
	for index=1,#attr do
		local att = AttributeBO.getAttributeData(attr[index][1], attr[index][2])
		ret[att.id] = att
	end

	return ret
end

--计算最大战力
function TacticsMO.getMaxFightTactics()
	local ret = {}
	local data = clone(TacticsMO.tactics_)
	for k,v in pairs(data) do
		if v.lv > 0 then -- 不是0级才计算战力
			local attr = TacticsMO.getTacticAttrData(v.keyId)
			for a,b in pairs(attr) do
				local value = UserBO.calcAttrFightValue(b)
				b.fightValue = value or 0
				ret[#ret + 1] = b
			end
		end
	end
		
	table.sort(ret,function (a, b)
		return a.fightValue > b.fightValue
	end)

	local attrs = {}
	for index=1,FIGHT_FORMATION_POS_NUM do
		if ret[index] then
			attrs[#attrs + 1] = ret[index]
		end
	end

	return attrs
end

--判断是否能穿戴，同属性的战术，最多穿戴三个
function TacticsMO.canTacticWear(formation, attrType)
	local canWear = true
	local wearNum = 0

	if formation.tacticsKeyId then
		for index=1,#formation.tacticsKeyId do
			local keyId = formation.tacticsKeyId[index]
			local tac = TacticsMO.getTacticByKeyId(keyId)
			if tac then
				local tacDB = TacticsMO.queryTacticById(tac.tacticsId)
				if tacDB.attrtype == attrType then
					wearNum = wearNum + 1
				end
			end
		end
	end

	if wearNum >= 3 then
		canWear = false
	end

	return canWear
end

--获得战术克制效果
function TacticsMO.getTacticsRestricts(tacticType)
	local data = db_tactics_tacticsRestrict_
	if not tacticType then return data end
	return data[tacticType]
end

--viewFor特殊处理些镜像部队。为true，是镜像部队。特殊判断
function TacticsMO.isTacticCanUse(formation,viewFor)
	local list = clone(formation.tacticsKeyId)
	if not list then return {} end
	-- local viewFor = viewFor or false
	-- if viewFor then
		for index=1,#list do
			if not TacticsMO.tactics_[list[index]] then
				list[index] = 0
			end
		end
	-- else
	-- 	for index=1,#list do
	-- 		-- if (list[index] ~= 0 and (not TacticsMO.tactics_[list[index]])) or (TacticsMO.tactics_[list[index]] and TacticsMO.tactics_[list[index]].use == 1) then
	-- 		if not TacticsMO.tactics_[list[index]] or TacticsMO.tactics_[list[index]].use == 1 then
	-- 			list[index] = 0
	-- 		end
	-- 	end
	-- end

	return list
end

--判断当前阵型中是否有战术套装
function TacticsMO.isFormationTacticSuit(tactic,hasAttr)
	local has = hasAttr or false
	local tactics = tactic
	local isSuit = true
	if #tactics < 6 then  -- 如果是少于6个的
		return false
	end
	for index =1, #tactics do
		local tacDB = TacticsMO.queryTacticById(tactics[index].v1)
		if not tacDB then
			isSuit = false
			break
		end
		for idx =index + 1, #tactics do
			local tac2 = tactics[idx]
			local tacDB2 = TacticsMO.queryTacticById(tac2.v1)
			if tacDB.tacticstype ~= tacDB2.tacticstype then
				isSuit = false
				break
			end
		end
	end

	--如果是套装，算出战术套装的战术类型
	if isSuit then
		local tacticstype
		local tacDB = TacticsMO.queryTacticById(tactics[1].v1)
		tacticstype = tacDB.tacticstype

		if has then
			return tacticstype
		end
	end

	return isSuit
end

--判断当前阵型中是否有兵种套装
function TacticsMO.isFormationArmsSuit(tactic, hasAttr)
	local has = hasAttr or false
	local tactics = tactic
	local isSuit = true
	if #tactics < 6 then  -- 如果是少于6个的
		return false
	end
	for index =1, #tactics do
		local tacDB = TacticsMO.queryTacticById(tactics[index].v1)
		if not tacDB then
			isSuit = false
			break
		end
		for idx =index + 1, #tactics do
			local tac2 = tactics[idx]
			if tac2 then
				local tacDB2 = TacticsMO.queryTacticById(tac2.v1)
				if tacDB.tanktype ~= tacDB2.tanktype then
					isSuit = false
					break
				end
			end
		end
	end

	if isSuit then
		local info = {}
		for num=1,#tactics do
			local tacDB = TacticsMO.queryTacticById(tactics[num].v1)
			info[#info + 1] = tacDB
		end

		local function sortFun(a,b)
			return a.quality < b.quality
		end

		table.sort(info,sortFun)

		if has then
			return info[1].quality, info[1].tanktype  --返回坦克套装类型和最小的品质(用于根据品质和坦克兵种类型计算加成的属性)
		end
	end

	return isSuit
end

--计算当前阵型。战术的属性加成
function TacticsMO.getFormationTacticAttr(tactic)
	local ret = {}
	local tactics = tactic
	for index=1,#tactics do
		local attr = TacticsMO.getTacticAttrByLv(tactics[index].v1, tactics[index].v2)
		for idx=1,#attr do
			ret[#ret + 1] = attr[idx]
		end
	end

	local temp = {}

	for i, v in ipairs(ret) do 
		if not temp[v[1]] then
			temp[v[1]] = v
		else
			temp[v[1]][2] = temp[v[1]][2] + v[2]
		end
	end

	temp = table.values(temp)

	return temp
end

--特殊的
function TacticsMO.getCrossTacticsByKind(tankTyke, tacticType, formation, kind)
	local data = {}
	for k,v in pairs(TacticsMO.tactics_) do
		local tactic = TacticsMO.queryTacticById(v.tacticsId)
		if tactic.tanktype == tankTyke and tactic.tacticstype == tacticType and v.use == 0 then
			v.quality = tactic.quality
			data[#data + 1] = v
		end
	end

	--排除掉已经在部队装备上的
	if formation and formation.tacticsKeyId then
		for index=1,#formation.tacticsKeyId do
			for k,v in pairs(data) do
				if formation.tacticsKeyId[index] == v.keyId then
					table.remove(data,k)
					break
				end
			end
		end
	end

	--检查跨服战
	if kind == ARMY_SETTING_FOR_CROSS or kind == ARMY_SETTING_FOR_CROSS1 or kind == ARMY_SETTING_FOR_CROSS2 then
		for index = FORMATION_FOR_CROSS,FORMATION_FOR_CROSS2 do
			if kind ~= index then
				local formation = TankMO.getFormationByType(index)
				if formation.tacticsKeyId then
					for index=1,#formation.tacticsKeyId do
						for k,v in pairs(data) do
							if formation.tacticsKeyId[index] == v.keyId then
								table.remove(data,k)
								break
							end
						end
					end
				end
			end
		end
	end

	return data
end

--根据战术的ID和等级计算加成属性
function TacticsMO.getTacticAttrByLv(tacticsId, lv)
	local tacticDB = TacticsMO.queryTacticById(tacticsId)
	local baseAttr = json.decode(tacticDB.attrBase)
	local lvAttr = json.decode(tacticDB.attrLv)
	local tacticLv = lv

	for index=1,#baseAttr do
		local attr1 = baseAttr[index]
		for a=1,#lvAttr do
			if attr1[1] == lvAttr[a][1] then
				baseAttr[index] = {attr1[1], attr1[2] + lvAttr[a][2] * tacticLv}
				break
			end
		end
	end

	return baseAttr
end