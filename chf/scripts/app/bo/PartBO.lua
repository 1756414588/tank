
-- 配件BO

PartBO = {}

-- function PartBO.check()
--  local trigger = false
--  for type = 1, PART_TYPE_ROCKET do
--      for partPos = 1, PART_POS_ATTACK_HP do
--          local part = PartBO.getPartAtPos(type, partPos)
--          if part then
--              if PartMO.getOpenLv(PartMO.getPosByPartId(part.partId)) > UserMO.level_ then
--                  trigger = true
--                  PartBO.asynOnPart(nil, part.keyId)  -- 将不合法的配件卸下
--              end
--          end
--      end
--  end
--  if trigger then
--      scheduler.performWithDelayGlobal(function() UserBO.triggerFightCheck() end, 1.5)
--  end
-- end

-- 按照品质进行排序
function PartBO.sortPart(partA, partB)
	if partA.partId == partB.partId then
		return (partA.keyId > partB.keyId)
	else
		local partADb = PartMO.queryPartById(partA.partId)
		local partBDb = PartMO.queryPartById(partB.partId)
		if partADb and partBDb and partADb.quality > partBDb.quality then
			return true
		elseif partADb and partBDb and partADb.quality == partBDb.quality then
			return (partADb.partId < partBDb.partId)
		else
			return false
		end
	end
end

-- 按照品质进行排序
function PartBO.sortChip(chipA, chipB)
	local partADb = PartMO.queryPartById(chipA.chipId)
	local partBDb = PartMO.queryPartById(chipB.chipId)
	local ac = (partADb.chipCount > 0 and chipA.count >= partADb.chipCount and chipA.chipId ~= PART_ID_ALL_PIECE) and 1 or 0
	local bc = (partBDb.chipCount > 0 and chipB.count >= partBDb.chipCount and chipB.chipId ~= PART_ID_ALL_PIECE) and 1 or 0
	if ac ~= bc then
		return ac > bc
	elseif chipA.chipId == PART_ID_ALL_PIECE then
		return true
	elseif chipB.chipId == PART_ID_ALL_PIECE then
		return false
	elseif partADb.quality > partBDb.quality then
		return true
	elseif partADb.quality == partBDb.quality then
		return (partADb.partId < partBDb.partId)
	else
		return false
	end
end

function PartBO.update(data)
	PartMO.part_ = {}
	PartMO.partData_ = {}

	for index = 1, PART_TYPE_ROCKET do
		PartMO.partData_[index] = {}
		for partPos = 1, PART_POS_ATTACK_DEFEND_IMPALE do
			PartMO.partData_[index][partPos] = 0
		end
	end

	if not data then return end

	local parts = PbProtocol.decodeArray(data["part"])
	for index = 1, #parts do
		local part = parts[index]
		if part.partId > 100 then
			local attr = PbProtocol.decodeArray(part["attr"])
			PartMO.part_[part.keyId] = {partId = part.partId, upLevel = part.upLv, refitLevel = part.refitLv, 
				keyId = part.keyId, typePos = part.pos, locked = part.locked, smeltLv = part.smeltLv,smeltExp = part.smeltExp,
				saved = part.saved,attr = attr}

			if part.pos == 0 then
			else
				local d = PartMO.queryPartById(part.partId)
				local partPos = PartMO.getPosByPartId(part.partId)
				PartMO.partData_[d.type][partPos] = part.keyId
			end
		end
	end

	Notify.notify(LOCLA_PART_EVENT)

	gdump(PartMO.part_, "[PartBO] all part")
	gdump(PartMO.partData_, "[PartBO] 22222222222")
end

function PartBO.updateChip(data)
	-- gdump(data, "[PartBO] update GetChip 获得配件碎片数据")

	PartMO.chip_ = {}

	if not data then return end

	local chips = PbProtocol.decodeArray(data["chip"])
	for index = 1, #chips do
		local chip = chips[index]
		PartMO.chip_[chip.chipId] = {chipId = chip.chipId, count = chip.count}
	end
	gdump(PartMO.chip_, "[PartBO] all chip")
end

function PartBO.hasPartAtPos(type, partPos)
	local keyId = PartMO.getKeyIdAtPos(type, partPos)
	if keyId == 0 then return false
	else return true end
end

-- 获得当前配件类型type下的某个配件位置partPos的的配件
function PartBO.getPartAtPos(type, partPos)
	local keyId = PartMO.getKeyIdAtPos(type, partPos)
	return PartMO.getPartByKeyId(keyId)
end

-- 配件是否穿戴了
function PartBO.isPartWearByKeyId(keyId)
	local part = PartMO.getPartByKeyId(keyId)
	if part.typePos == 0 then return false
	else return true end
end

-- 某个配件位置在没有配件穿戴条件下，获得仓库中空闲可穿戴的配件
function PartBO.getCanWearPartsAtPos(type, partPos)
	local ret = {}
	for keyId, part in pairs(PartMO.part_) do
		if part.typePos == 0 then -- 配件是空闲的
			local partDB = PartMO.queryPartById(part.partId)
			local pos = PartMO.getPosByPartId(part.partId)

			if partDB and partDB.type == type and pos == partPos then
				ret[#ret + 1] = part
			end
		end
	end

	local function sortPart(partA, partB)
		if partA.partId == partB.partId then
			if partA.refitLevel > partB.refitLevel then
				return true
			elseif partA.refitLevel == partB.refitLevel then
				if partA.upLevel > partB.upLevel then
					return true
				elseif partA.upLevel == partB.upLevel then
					return partA.keyId < partB.keyId
				else
					return false
				end
			else
				return false
			end
		else
			local dbA = PartMO.queryPartById(partA.partId)
			local dbB = PartMO.queryPartById(partB.partId)
			if dbA.quality > dbB.quality then
				return true
			elseif dbA.quality == dbB.quality then
				return partA.partId < partB.partId
			else
				return false
			end
		end
	end
	table.sort(ret, sortPart)
	return ret
end

function PartBO.getFreePartsById(partId)
	local ret = {}
	for keyId, part in pairs(PartMO.part_) do
		if part.typePos == 0 and part.partId == partId then -- 配件是空闲的
			ret[#ret + 1] = part
		end
	end
	return ret
end

function PartBO.getPartAttrData(partId, upLv, refitLv, keyId, showBase)
	local ret = {}
	local part = PartMO.queryPartById(partId)
	local attrs = {}
	if keyId then
		local attrData = PartMO.getPartByKeyId(keyId)
		--配件淬炼
		if attrData.attr then
			for k,v in ipairs(attrData.attr) do
				if v.val > 0 then
					attrs[v.id] = v.val
				end
			end
		end
		--激活属性
		for k,v in pairs(PartMO.getActiveAttr(attrData,1)) do
			if attrs[k] then
				attrs[k] = attrs[k] + v
			else
				attrs[k] = v
			end
		end
	end
	local value = FormulaBO.partAttributeValue(part.attr1, part.a1, part.b1, upLv, refitLv)
	local oldVal = value
	if attrs[part.attr1] then
		value = value + attrs[part.attr1]
		attrs[part.attr1] = nil
	end
	local att = AttributeBO.getAttributeData(part.attr1, value)
	ret.attr1 = AttributeBO.getAttributeData(part.attr1, showBase and oldVal or value)
	ret.attr1.strengthValue = FormulaBO.partStrengthValue(part.attr1, att.value)  -- 配件强度
	if part.attr2 > 0 then
		local value = FormulaBO.partAttributeValue(part.attr2, part.a2, part.b2, upLv, refitLv)
		local oldVal = value
		if attrs[part.attr2] then
			value = value + attrs[part.attr2]
			attrs[part.attr2] = nil
		end
		local att = AttributeBO.getAttributeData(part.attr2, value)
		ret.attr2 = AttributeBO.getAttributeData(part.attr2, showBase and oldVal or value)
		ret.attr2.strengthValue = FormulaBO.partStrengthValue(part.attr2, att.value)
	end
	if part.attr3 > 0 then
		local value = FormulaBO.partAttributeValue(part.attr3, part.a3, part.b3, upLv, refitLv)
		local oldVal = value
		if attrs[part.attr3] then
			value = value + attrs[part.attr3]
			attrs[part.attr3] = nil
		end
		local att = AttributeBO.getAttributeData(part.attr3, value)
		ret.attr3 = AttributeBO.getAttributeData(part.attr3, showBase and oldVal or value)
		ret.attr3.strengthValue = FormulaBO.partStrengthValue(part.attr3, att.value)
	end
	ret.strengthValue = ret.attr1.strengthValue
	if ret.attr2 then
		ret.strengthValue = ret.strengthValue + ret.attr2.strengthValue
	end
	if ret.attr3 then
		ret.strengthValue = ret.strengthValue + ret.attr3.strengthValue
	end
	ret.attr = {}
	for k,v in pairs(attrs) do
		local attr = AttributeBO.getAttributeData(k, v)
		table.insert(ret.attr, attr)
		ret.strengthValue = ret.strengthValue + FormulaBO.partStrengthValue(k, attr.value)
	end
	ret.strengthValue = math.floor(ret.strengthValue)
	return ret
end

-- 获得某一类型的tanktankType的配件属性
function PartBO.getTankTypePartAttrData(tankType)
	local attrValue = {[ATTRIBUTE_INDEX_ATTACK] = {}, [ATTRIBUTE_INDEX_IMPALE] = {}, [ATTRIBUTE_INDEX_HP] = {}, [ATTRIBUTE_INDEX_DEFEND] = {}}

	local pos = {PART_POS_ATTACK, PART_POS_IMPALE, PART_POS_HP, PART_POS_DEFEND}

	local totalStrength = 0

	for index = 1, #pos do  -- 设置默认属性
		local partId = pos[index] * 100 + 1
		local partDB = PartMO.queryPartById(partId)
		local attrData = AttributeBO.getAttributeData(partDB.attr1, 0)
		attrValue[attrData.index] = attrData
	end

	for posIndex = 1, PART_POS_ATTACK_DEFEND_IMPALE do -- 统计每个位置
		if PartBO.hasPartAtPos(tankType, posIndex) then
			local part = PartBO.getPartAtPos(tankType, posIndex)
			local attrData = PartBO.getPartAttrData(part.partId, part.upLevel, part.refitLevel, part.keyId)
			totalStrength = totalStrength + attrData.strengthValue

			if attrValue[attrData.attr1.index] == nil then
				gprint("[PartBO] getTankTypePartAttrData Error!!! AA attrINdex:", attrData.attr1.index)
				error("[PartBO]")
			else
				attrValue[attrData.attr1.index].id = attrData.attr1.id
				attrValue[attrData.attr1.index].index = attrData.attr1.index
				attrValue[attrData.attr1.index].type = attrData.attr1.type
				attrValue[attrData.attr1.index].name = attrData.attr1.name
				attrValue[attrData.attr1.index].attrName = attrData.attr1.attrName
				if not attrValue[attrData.attr1.index].value then attrValue[attrData.attr1.index].value = 0 end
				attrValue[attrData.attr1.index].value = attrValue[attrData.attr1.index].value + attrData.attr1.value
				attrValue[attrData.attr1.index].strValue = AttributeBO.formatAttrValue(attrValue[attrData.attr1.index].id, attrValue[attrData.attr1.index].value)
			end

			if attrData.attr2 then
				if attrValue[attrData.attr2.index] == nil then
					gprint("[PartBO] getTankTypePartAttrData Error!!! BB attrINdex:", attrData.attr2.index)
					error("[PartBO]")
				else
					attrValue[attrData.attr2.index].id = attrData.attr2.id
					attrValue[attrData.attr2.index].index = attrData.attr2.index
					attrValue[attrData.attr2.index].type = attrData.attr2.type
					attrValue[attrData.attr2.index].name = attrData.attr2.name
					attrValue[attrData.attr2.index].attrName = attrData.attr2.attrName
					if not attrValue[attrData.attr2.index].value then attrValue[attrData.attr2.index].value = 0 end
					attrValue[attrData.attr2.index].value = attrValue[attrData.attr2.index].value + attrData.attr2.value
					attrValue[attrData.attr2.index].strValue = AttributeBO.formatAttrValue(attrValue[attrData.attr2.index].id, attrValue[attrData.attr2.index].value)
				end
			end

			if attrData.attr3 then
				if attrValue[attrData.attr3.index] == nil then
					gprint("[PartBO] getTankTypePartAttrData Error!!! BB attrINdex:", attrData.attr3.index)
					error("[PartBO]")
				else
					attrValue[attrData.attr3.index].id = attrData.attr3.id
					attrValue[attrData.attr3.index].index = attrData.attr3.index
					attrValue[attrData.attr3.index].type = attrData.attr3.type
					attrValue[attrData.attr3.index].name = attrData.attr3.name
					attrValue[attrData.attr3.index].attrName = attrData.attr3.attrName
					if not attrValue[attrData.attr3.index].value then attrValue[attrData.attr3.index].value = 0 end
					attrValue[attrData.attr3.index].value = attrValue[attrData.attr3.index].value + attrData.attr3.value
					attrValue[attrData.attr3.index].strValue = AttributeBO.formatAttrValue(attrValue[attrData.attr3.index].id, attrValue[attrData.attr3.index].value)
				end
			end

			for k,v in pairs(attrData.attr) do
				if not attrValue[v.index] then
					attrValue[v.index] = v
				else
					attrValue[v.index].value = attrValue[v.index].value + v.value
					attrValue[v.index].strValue = AttributeBO.formatAttrValue(attrValue[v.index].id, attrValue[v.index].value)
				end
			end
		end
	end

	attrValue.strengthValue = totalStrength
	return attrValue
end

function PartBO.checkPositionUnlock(oldLevel, newLevel)
	if oldLevel == newLevel then return end

	local position = 0

	for index = 1, PART_POS_ATTACK_DEFEND_IMPALE do
		local lockLevel = PartMO.getOpenLv(index)
		if oldLevel < lockLevel and newLevel >= lockLevel then
			position = index
		end
	end

	if position > 0 then  -- 避免将还没有显示的动画的值PartMO.unlockPosition_清除了
		PartMO.unlockPosition_ = position
		gprint("PartBO.checkPositionUnlock !!!!!!!!!!!!:", PartMO.unlockPosition_)
	end
end

-- 如果配件已经穿戴了，则卸下；如果没有穿戴，则穿戴
function PartBO.asynOnPart(doneCallback, keyId)
	local position = nil
	local part = PartMO.getPartByKeyId(keyId)
	local partDB = PartMO.queryPartById(part.partId)
	if PartBO.isPartWearByKeyId(keyId) then
		position = partDB.type
	end

	local function parseOnPart(name, data)
		gdump(data, "[PartBO] on part")

		local partPos = PartMO.getPosByPartId(part.partId)

		if PartBO.isPartWearByKeyId(keyId) then  -- 是卸下
			part.typePos = 0
			PartMO.partData_[partDB.type][partPos] = 0
		else -- 是穿戴
			if PartBO.hasPartAtPos(partDB.type, partPos) then -- 替换位置上的配件
				local oldPart = PartBO.getPartAtPos(partDB.type, partPos)
				oldPart.typePos = 0
				part.typePos = partDB.type
				PartMO.partData_[partDB.type][partPos] = part.keyId
			else -- 直接穿戴
				part.typePos = partDB.type
				PartMO.partData_[partDB.type][partPos] = part.keyId
			end
		end

		UserBO.triggerFightCheck()

		Notify.notify(LOCLA_PART_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseOnPart, NetRequest.new("OnPart", {keyId = keyId, pos = position}))
end

function PartBO.asynCombinePart(doneCallback, partId)
	local function parseCombinePart(name, data)
		gdump(data, "[PartBO] combine part")

		-- 新产生了一个配件
		local part = PbProtocol.decodeRecord(data["part"])
		local attr = PbProtocol.decodeArray(part["attr"])
		PartMO.part_[part.keyId] = {partId = part.partId, upLevel = part.upLv, refitLevel = part.refitLv, keyId = part.keyId, typePos = part.pos,
			smeltLv = part.smeltLv,smeltExp = part.smeltExp,saved = part.saved,attr = attr}
		local stastAwards = {awards = {{kind = ITEM_KIND_PART, id = part.partId, count = 1}}}

		--TK统计 配件获得
		TKGameBO.onEvnt(TKText.eventName[9], {partId = part.partId})


		-- 减少碎片
		local partDB = PartMO.queryPartById(partId)

		local count = UserMO.getResource(ITEM_KIND_CHIP, part.partId)
		if count < partDB.chipCount then -- 使用了万能碎片
			local res = {}
			res[#res + 1] = {kind = ITEM_KIND_CHIP, id = part.partId, count = count}
			res[#res + 1] = {kind = ITEM_KIND_CHIP, id = PART_ID_ALL_PIECE, count = (partDB.chipCount - count)}
			UserMO.reduceResources(res)
		else
			UserMO.reduceResource(ITEM_KIND_CHIP, partDB.chipCount, partDB.partId)
		end

		Notify.notify(LOCLA_PART_EVENT)

		if doneCallback then doneCallback(stastAwards) end
	end

	SocketWrapper.wrapSend(parseCombinePart, NetRequest.new("CombinePart", {partId = partId}))
end

-- keyId：只用来分解某一个配件
-- qualitys: 用于分解所有这些品质下的配件
function PartBO.asynExplodePart(doneCallback, keyId, qualitys)
	local function parseExplodePart(name, data)
		gdump(data, "[PartBO] explode part")

		if keyId then -- 分解一个配件
			--TK统计 配件消耗
			TKGameBO.onEvnt(TKText.eventName[10], {partId = PartMO.part_[keyId].partId})
			PartMO.part_[keyId] = nil
		else
			local function isInQuality(quality)
				for index = 1, #qualitys do
					if quality == qualitys[index] then return true end
				end
			end

			local parts = PartMO.getFreeParts()
			for index = 1, #parts do
				local part = parts[index]
				local partDB = PartMO.queryPartById(part.partId)
				if isInQuality(partDB.quality) and not part.locked then
					--TK统计 配件消耗
					TKGameBO.onEvnt(TKText.eventName[10], {partId = part.partId})
					PartMO.part_[part.keyId] = nil
				end
			end
		end

		local res = {}
		res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = data.fitting, id = MATERIAL_ID_FITTING}
		res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = data.plan, id = MATERIAL_ID_PLAN}
		res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = data.mineral, id = MATERIAL_ID_MINERAL}
		res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = data.tool, id = MATERIAL_ID_TOOL}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE}

		TKGameBO.onGetResTk(RESOURCE_ID_STONE,data.stone,TKText[15],TKGAME_USERES_TYPE_UPDATE)

		local delta = UserMO.updateResources(res)
		local award = PbProtocol.decodeArray(data.award)
		 --加入背包
		local ret = CombatBO.addAwards(award)
		for k,v in ipairs(ret.awards) do
			table.insert(delta, v)
		end

		Notify.notify(LOCLA_PART_EVENT)

		if doneCallback then doneCallback({awards = delta}) end
	end

	local param = {}
	if keyId then param.keyId = keyId
	else param.quality = qualitys end
	SocketWrapper.wrapSend(parseExplodePart, NetRequest.new("ExplodePart", param))
end

-- qualitys: 用于分解所有这些品质下的碎片
function PartBO.asynExplodeChip(doneCallback, chipId, count, qualitys)
	local function parseExplodeChip(name, data)
		gdump(data, "[PartBO] explode chip")
		local res = {}
		if chipId then -- 分解一个碎片
			res[#res + 1] = {kind = ITEM_KIND_CHIP, id = chipId, count = count}
		else
			local function isInQuality(quality)
				for index = 1, #qualitys do
					if quality == qualitys[index] then return true end
				end
			end

			local chips = PartMO.getAllChips()
			for index = 1, #chips do
				local chip = chips[index]
				local partDB = PartMO.queryPartById(chip.chipId)
				if isInQuality(partDB.quality) then
					res[#res + 1] = {kind = ITEM_KIND_CHIP, id = chip.chipId, count = chip.count}
				end
			end
		end
		UserMO.reduceResources(res)

		local delta = UserMO.updateResource(ITEM_KIND_MATERIAL, data.fitting, MATERIAL_ID_FITTING)
		gdump(delta, "PartBO.asynExplodeChip")

		Notify.notify(LOCLA_PART_EVENT)

		if doneCallback then doneCallback({awards = delta}) end
	end
	local param = {}
	if chipId then
		param.chipId = chipId
		param.count = count
	else
		param.quality = qualitys
	end
	SocketWrapper.wrapSend(parseExplodeChip, NetRequest.new("ExplodeChip", param))
end

-- metalNum: 使用记忆金属的数量
function PartBO.asynUpPart(doneCallback, keyId, metalNum)
	local function parseUpPart(name, data)
		gdump(data, "[PartBO] up part")

		local part = PartMO.getPartByKeyId(keyId)
		if data.success then -- 成功
			part.upLevel = part.upLevel + 1
		end

		local res = {}
		res[#res + 1] = {kind = ITEM_KIND_RESOURCE, count = data.stone, id = RESOURCE_ID_STONE}
		res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = data.metal, id = MATERIAL_ID_METAL}

		TKGameBO.onUseResTk(RESOURCE_ID_STONE,data.stone,TKText[16],TKGAME_USERES_TYPE_UPDATE)

		UserMO.updateResources(res)

		if part.typePos ~= 0 then
			UserBO.triggerFightCheck()
		end

		Notify.notify(LOCLA_PART_EVENT)
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_PART_UP,type = 1})

		if doneCallback then doneCallback(data.success) end
	end

	local position = PartMO.getPartByKeyId(keyId).typePos
	SocketWrapper.wrapSend(parseUpPart, NetRequest.new("UpPart", {keyId = keyId, pos = position, metal = metalNum}))
end

-- needDraw: 是否使用改装图纸
function PartBO.asynRefitPart(doneCallback, keyId, needDraw)
	local function parseRefitPart(name, data)
		gdump(data, "[PartBO] refit part")

		local refitItemId = {MATERIAL_ID_PLAN, MATERIAL_ID_MINERAL, MATERIAL_ID_TOOL, MATERIAL_ID_FITTING}
		local part = PartMO.getPartByKeyId(keyId)
		local partDB = PartMO.queryPartById(part.partId)
		local partRefit = PartMO.queryPartRefit(partDB.quality, part.refitLevel + 1, part.partId)

		local res = {}
		for index = 1, #refitItemId do
			local needCount = 0
			if refitItemId[index] == MATERIAL_ID_PLAN then needCount = partRefit.plan
			elseif refitItemId[index] == MATERIAL_ID_MINERAL then needCount = partRefit.mineral
			elseif refitItemId[index] == MATERIAL_ID_TOOL then needCount = partRefit.tool
			elseif refitItemId[index] == MATERIAL_ID_FITTING then needCount = partRefit.fitting
			end
			res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = needCount, id = refitItemId[index]}
		end

		if needDraw then  -- 使用图纸
			res[#res + 1] = {kind = ITEM_KIND_MATERIAL, count = PART_REFIT_DRAW_NUM, id = MATERIAL_ID_DRAW}
		end

		UserMO.reduceResources(res)
		if partRefit.cost and partRefit.cost ~= "" then
			for k,v in ipairs(json.decode(partRefit.cost)) do
				UserMO.reduceResource(v[1],v[3],v[2])
			end
		end

		part.refitLevel = part.refitLevel + 1
		part.upLevel = data.upLv

		if part.typePos ~= 0 then
			UserBO.triggerFightCheck()
		end

		Notify.notify(LOCLA_PART_EVENT)
		if doneCallback then doneCallback() end
	end

	local position = PartMO.getPartByKeyId(keyId).typePos
	SocketWrapper.wrapSend(parseRefitPart, NetRequest.new("RefitPart", {keyId = keyId, pos = position, draw = needDraw}))
end

function PartBO.asynLockPart(doneCallback, part)
	local locked
	if part.locked then
		locked = false
	else
		locked = true
	end
	local function parseOnLock(name, data)
		if data.result then
			if part.locked == true then
				part.locked = false
			else
				part.locked = true
			end
		end
		Notify.notify(LOCLA_PART_EVENT)
		
		if doneCallback then doneCallback(part.locked) end
	end

	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("LockPart", {keyId = part.keyId, pos = part.typePos, locked = locked}))
end

--配件进阶
function PartBO.qualityUp(doneCallback, part)
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()
		local reward = PbProtocol.decodeArray(data.atom2)
		local ret = UserMO.updateResources(reward)
		local list = {}
		for k,v in ipairs(ret) do
			if v.count > 0 then
				table.insert(list, v)
			end
		end
		local award = PbProtocol.decodeArray(data.award)
		local ret = CombatBO.addAwards(award)
		for k,v in ipairs(ret.awards) do
			table.insert(list, v)
		end
		--加入背包
		UiUtil.showAwards({awards = list})
		part.partId = data.partId
		part.upLevel = data.upLv
		part.refitLevel = data.refitLv
		part.smeltLv = data.smeltLv
		part.smeltExp = data.smeltExp
		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		if doneCallback then doneCallback(part) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("PartQualityUp", {keyId = part.keyId, pos = part.typePos}))
end

--淬炼
function PartBO.refineUp(doneCallback, part, kind)
	local function parse(name, data)
		Loading.getInstance():unshow()
		local reward = PbProtocol.decodeArray(data.atom2)
		UserMO.updateResources(reward)

		part.smeltLv = data.smeltLv
		part.smeltExp = data.smeltExp
		part.attr = PbProtocol.decodeArray(data.attr)
		part.saved = data.saved
		part.crit = data.expMult
		--淬炼获取氪金奖励
		local award = PbProtocol.decodeRecord(data["krypton"])
		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
			UiUtil.showAwards(statsAward)
		end
		if doneCallback then doneCallback(part) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("SmeltPart", {keyId = part.keyId, pos = part.typePos, option = kind}))
end

--保存
function PartBO.refineSave(doneCallback, part)
	local function parse(name, data)
		Loading.getInstance():unshow()
		part.attr = PbProtocol.decodeArray(data.attr)
		part.saved = data.saved
		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		if doneCallback then doneCallback(part) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("SaveSmeltPart", {keyId = part.keyId, pos = part.typePos}))
end

--淬炼10次
function PartBO.refineTenUp(doneCallback, part, kind, attr, tag, tagNum)
	local function parse(name, data)
		Loading.getInstance():unshow()
		local reward = PbProtocol.decodeArray(data.atom2)
		UserMO.updateResources(reward)

		part.smeltLv = data.smeltLv
		part.smeltExp = data.smeltExp
		part.attr = PbProtocol.decodeArray(data.attr)
		part.saved = data.saved
		--淬炼获取氪金奖励
		local award = PbProtocol.decodeRecord(data["krypton"])
		local awards = {}
		awards[#awards + 1] = award
		local statsAward = nil
		if awards then
			statsAward = CombatBO.addAwards(awards)
		end
		part.statsAward  =statsAward
		local result = PbProtocol.decodeRecord(data.result)
		if table.isexist(result, "crit") then
			result.crit = PbProtocol.decodeRecord(result.crit)
		end     

		local records = PbProtocol.decodeArray(data.records) or {}

		for i,v in ipairs(records) do
			if table.isexist(v, "crit") then
				v.crit = PbProtocol.decodeRecord(v.crit)
			end
		end
		if doneCallback then doneCallback(part,kind,attr,records,result,tag,tagNum) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parse, NetRequest.new("TenSmeltPart", {keyId = part.keyId, pos = part.typePos, option = kind, saveAttrId = attr, times = tag}), 1)
end

-- 配件转换
function PartBO.partConvert(pos, pos2, keyIds, rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()

		local newPartId = PbProtocol.decodeArray(data.newPartId)
		local key2PartIds = {}
		for i, v in ipairs(newPartId) do
			key2PartIds[v.v1] = v.v2
		end

		-- 对部件的淬炼等属性进行交换
		for i = 1, #keyIds do
			local exch_key = keyIds[i]
			local key1 = exch_key.v1
			local key2 = exch_key.v2

			local part1 = PartMO.getPartByKeyId(key1)
			local part2 = PartMO.getPartByKeyId(key2)

			local function deepcopy(object)
				local lookup_table = {}
				local function _copy(object)
					if type(object) ~= "table" then
						return object
					elseif lookup_table[object] then
						return lookup_table[object]
					end
					local new_table = {}
					lookup_table[object] = new_table
					for index, value in pairs(object) do
						new_table[_copy(index)] = _copy(value)
					end
					return setmetatable(new_table, getmetatable(object))
				end
				return _copy(object)
			end
			local attr1 = deepcopy(part1.attr)
			if table.isexist(part2, "attr") then
				part1.attr = {}
				for j, v in ipairs(part2.attr) do
					table.insert(part1.attr, v)
				end
			else
				part1.attr = {}
			end

			if attr1 ~= nil then
				part2.attr = {}
				for j, v in ipairs(attr1) do
					table.insert(part2.attr, v)
				end
			else
				part2.attr = {}
			end

			local tmpRefitLevel = part1.refitLevel
			part1.refitLevel = part2.refitLevel
			part2.refitLevel = tmpRefitLevel

			local tmpSmeltExp = part1.smeltExp
			part1.smeltExp = part2.smeltExp
			part2.smeltExp = tmpSmeltExp

			local tmpSmeltLv = part1.smeltLv
			part1.smeltLv = part2.smeltLv
			part2.smeltLv = tmpSmeltLv

			local tmpUpLv = part1.upLevel
			part1.upLevel = part2.upLevel
			part2.upLevel = tmpUpLv

			-- 交换partId
			part1.partId = key2PartIds[key1]
			part2.partId = key2PartIds[key2]
		end

		-- 剩余金币刷新
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		Notify.notify(LOCLA_PART_EVENT, {leftPageIndex=pos, rightPageIndex=pos2})
		UserBO.triggerFightCheck()

		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("PartConvert", {pos=pos, pos2=pos2, keyIds=keyIds}))
end

-- 检查 某个类型某个功能的配件位置 是否有比当前已装备 配件强度更高的配件
-- list 该位置上闲置的配件列表
-- state 是否有更高配件强度的配件 true 有 false 没有
function PartBO.checkListUpPartsAtPos(part)
	local attrData = PartBO.getPartAttrData(part.partId, part.upLevel, part.refitLevel, part.keyId, 1)
	local pos = PartMO.getPosByPartId(part.partId)
	local list = PartBO.getCanWearPartsAtPos(part.typePos,pos)
	local state = false
	for index = 1 , #list do
		local _partdata = list[index]
		local _attrData = PartBO.getPartAttrData(_partdata.partId, _partdata.upLevel, _partdata.refitLevel, _partdata.keyId, 1)
		if _attrData.strengthValue > attrData.strengthValue then
			state = true
			break
		end
	end 
	return list, state
end

-- 配件强度排序
function PartBO.sortStrength(as, bs)
	local aStrengthData = PartBO.getPartAttrData(as.partId, as.upLevel, as.refitLevel, as.keyId, 1)
	local bStrengthData = PartBO.getPartAttrData(bs.partId, bs.upLevel, bs.refitLevel, bs.keyId, 1)
	return aStrengthData.strengthValue > bStrengthData.strengthValue
end