
EQUIP_CHECK_LEVEL = 80

EquipBO = {}

function socket_error_531_callback(code)
	Loading.getInstance():show()
	EquipBO.asynGetEquip(function() Loading.getInstance():unshow() end)
end

function EquipBO.update(data)
	-- gdump(data, "[EquipBO] update GetEquip")

	for index = 1, FIGHT_FORMATION_POS_NUM do
		EquipMO.equipData_[index] = {}
		for equipPos = 1, FIGHT_EQUIP_POS_NUM do
			EquipMO.equipData_[index][equipPos] = 0
		end
	end

	EquipMO.equip_ = {}

	if not data then return end

	local equips = PbProtocol.decodeArray(data["equip"])

	for index = 1, #equips do
		local equip = equips[index]
		if equip.keyId > 0 then
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			if equipDB then
				EquipMO.equip_[equip.keyId] = {equipId = equip.equipId, level = equip.lv, exp = equip.exp, keyId = equip.keyId, formatPos = equip.pos, starLv = equip.starLv}

				if equip.lv >= EQUIP_CHECK_LEVEL then
					EquipMO.reCheck = EquipMO.selectNextProEquip(equip.equipId, equip.lv, equip.exp)
				end

				if equip.pos == 0 then -- 还没有装备
				else
					local equipPos = EquipMO.getPosByEquipId(equip.equipId)
					EquipMO.equipData_[equip.pos][equipPos] = equip.keyId
				end
			end
		end
	end

	Notify.notify(LOCAL_EQUIP_EVENT)

	gdump(EquipMO.equip_, "[EquipBO] update GetEquip")
	-- gdump(EquipMO.equipData_, "[EquipBO] 装备了的装备")
end

-- -- 根据装备的id获得装备所在的位置
-- function EquipBO.getPosByEquipId(equipId)
-- 	local equipPos = math.floor(equipId / 100)
-- 	if equipPos > FIGHT_EQUIP_POS_NUM then return 0
-- 	else return equipPos end
-- end

-- -- keyId代表的装备是否装上了
-- function EquipBO.isEquipFreeByKeyId(keyId)
-- 	local equip = EquipMO.getEquipByKeyId(keyId)
-- 	if equip.formatPos == 0 then return true
-- 	else return false end
-- end

function EquipBO.getTotalEquipNum()
	local total = 0
	for formatIndex = 1, FIGHT_FORMATION_POS_NUM do
		for equipPos = 1, EQUIP_POS_CRIT_DEF do
			if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
				total = total + 1
			end
		end
	end
	return total
end

function EquipBO.getQualityEquipNumAtFormatIndex(formatIndex, equipQuality)
	local total = 0
	for equipPos = 1, EQUIP_POS_CRIT_DEF do
		if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
			local equip = EquipBO.getEquipAtPos(formatIndex, equipPos)
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			if equipDB.quality == equipQuality then
				total = total + 1
			end
		end
	end
	return total
end

function EquipBO.getSuitAttr(formatIndex)
	local nums = {}
	for equipPos = 1, EQUIP_POS_CRIT_DEF do
		if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
			local equip = EquipBO.getEquipAtPos(formatIndex, equipPos)
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			if not nums[equipDB.quality] then nums[equipDB.quality] = 0 end
			nums[equipDB.quality] = nums[equipDB.quality] + 1
			if equipDB.quality == 5 then
				if not nums[3] then nums[3] = 0 end
				if not nums[4] then nums[4] = 0 end
				nums[3] = nums[3] + 1
				nums[4] = nums[4] + 1
			end
		end
	end
	local attr = {}
	for i=3,5 do
		if nums[i] then
			for k,v in ipairs(EquipMO.getAttr()[i]) do
				if nums[i] >= v.number then
					table.insert(attr,v)
				end
			end
		end
	end
	return attr,nums
end

function EquipBO.hasEquipAtPos(formatIndex, equipPos)
	local keyId = EquipMO.getKeyIdAtPos(formatIndex, equipPos)
	if keyId == 0 then return false
	else return true end
end

-- 获得当前阵型位置formatIndex下的某个装备位置equipPos的的装备数据
function EquipBO.getEquipAtPos(formatIndex, equipPos)
	local keyId = EquipMO.getKeyIdAtPos(formatIndex, equipPos)
	return EquipMO.getEquipByKeyId(keyId)
end

function EquipBO.getEquipFormationAtPos(equipPos)
	local ret = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local keyId = EquipMO.getKeyIdAtPos(index, equipPos)
		ret[index] = keyId
	end
	return ret
end

function EquipBO.getEquipNameById(equipId)
	local equipDB = EquipMO.queryEquipById(equipId)
	if not equipDB then return "" end

	local pos = EquipMO.getPosByEquipId(equipId)
	if pos == 0 then return equipDB.equipName
	else return equipDB.equipName .. "[" .. CommonText.color[equipDB.quality][1] .. "]" end
end

-- function EquipBO.getEquipAttrData(equipId, equipLv)
function EquipBO.getEquipAttrData(equipId, equipLv, star)
	local stars = star or 0
	-- local value = FormulaBO.equipAttributeValue(equipId, equipLv)
	local value = FormulaBO.equipAttributeValue(equipId, equipLv, stars)
	local equipDB = EquipMO.queryEquipById(equipId)
	return AttributeBO.getAttributeData(equipDB.attributeId, value)
end

-- 获得阵型中某个位置formatIndex处的装备属性
function EquipBO.getFormationEquipAttrData(formatIndex)
	local attrValue = {[ATTRIBUTE_INDEX_HP] = {}, [ATTRIBUTE_INDEX_ATTACK] = {}, [ATTRIBUTE_INDEX_HIT] = {}, [ATTRIBUTE_INDEX_DODGE] = {}, [ATTRIBUTE_INDEX_CRIT] = {}, [ATTRIBUTE_INDEX_CRIT_DEF] = {}}
	local attrs = EquipBO.getSuitAttr(formatIndex)
	local attr = {}
	for k,v in ipairs(attrs) do
		local temp = json.decode(v.attribute)
		for m,n in ipairs(temp) do
			if not attr[n[1]] then
				attr[n[1]] = n[2]
			else
				attr[n[1]] = attr[n[1]] + n[2]
			end
		end
	end
	for index = 1, EQUIP_POS_CRIT_DEF do
		local equip = EquipBO.getEquipAtPos(formatIndex, index)
		local has = EquipBO.hasEquipAtPos(formatIndex,index)
		if equip and has then
			local attrData = nil
			-- local value = FormulaBO.equipAttributeValue(equip.equipId, equip.level)
			local value = FormulaBO.equipAttributeValue(equip.equipId, equip.level, equip.starLv)
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			if attr[equipDB.attributeId] then
				value = value + attr[equipDB.attributeId]
				attr[equipDB.attributeId] = nil
			end
			attrData = AttributeBO.getAttributeData(equipDB.attributeId, value)
			if attrValue[attrData.index] == nil then
				gprint("Error:", attrData.index)
				error("EquipBO getFormationEquipAttrData")
			end
			attrValue[attrData.index] = attrData
		else  -- 默认的显示
			local defalutId = index * 100 + 1
			local equipDB = EquipMO.queryEquipById(defalutId)
			local attrData =  AttributeBO.getAttributeData(equipDB.attributeId, 0)
			attrValue[attrData.index] = attrData
		end
	end
	for k,v in pairs(attr) do
		local attrData = AttributeBO.getAttributeData(k, v)
		attrValue[attrData.index] = attrData
	end
	return attrValue
end

-- 检测当前位置equipPos是否有装备可以更新的
function EquipBO.checkAllEquip(formatIndex)

	local freeEquips = clone(EquipMO.getFreeEquipsAtPos())
	if #freeEquips <= 0 then return false end

	table.sort(freeEquips, EquipBO.orderEquip)

	local on = {} -- 当前需要替换上的装备
	local off = {}

	local sortData = clone(freeEquips)
	--按星级排序
	local sortFun = function(a,b)
		return a.starLv > b.starLv
	end
	table.sort(sortData,sortFun)

	for index = 1, #sortData do
		local equip = sortData[index]
		local equipPos = EquipMO.getPosByEquipId(equip.equipId)
		if equipPos == 0 then -- 不能装备，是经验
		else
			if on[equipPos] and on[equipPos] > 0 then  -- 当前装备位置上已经有要替换上的装备了
			else
				local keyId = EquipMO.getKeyIdAtPos(formatIndex, equipPos)
				if keyId == 0 then -- 没有装备
					on[equipPos] = equip.keyId
				else
					local equipDB = EquipMO.queryEquipById(equip.equipId)

					local originalEquip = EquipMO.getEquipByKeyId(keyId)
					local originalEquipDB = EquipMO.queryEquipById(originalEquip.equipId)

					if (originalEquip.starLv < equip.starLv) or (originalEquipDB.quality < equipDB.quality) or
						(originalEquip.starLv == equip.starLv and originalEquipDB.quality == equipDB.quality and originalEquip.level < equip.level) then --需要更换
						on[equipPos] = equip.keyId
						off[equipPos] = originalEquip.keyId
					end
				end
			end
		end
	end

	if table.nums(on) <= 0 then return false
	else return true, on, off end
end

-- 获得仓库扩容需要消耗的金币数量
function EquipBO.buyCapacityTakCoin()
	local time = (UserMO.equipWarhouse_ - 100 + EQUIP_CAPACITY_DELTA_NUM) / EQUIP_CAPACITY_DELTA_NUM
	return math.ceil(time / 2) * 10
end

-- 获得仓库已经扩容的次数
function EquipBO.hasBuyCapacityNum()
	return (UserMO.equipWarhouse_ - 100) / EQUIP_CAPACITY_DELTA_NUM
end

function EquipBO.orderEquip(equipA, equipB)
	local posA = EquipMO.getPosByEquipId(equipA.equipId)
	local posB = EquipMO.getPosByEquipId(equipB.equipId)
	if posA == 0 and posB == 0 then  -- 都是经验
		local equipDbA = EquipMO.queryEquipById(equipA.equipId)
		if not equipDbA then return false end
		local equipDbB = EquipMO.queryEquipById(equipB.equipId)
		if not equipDbB then return false end
		if equipDbA.a > equipDbB.a then  -- a比b的经验值高
			return true
		elseif equipDbA.a == equipDbB.a then
			if equipA.keyId < equipB.keyId then return true
			else return false end
		else
			return false
		end
	elseif posA == 0 and posB ~= 0 then
		return false
	elseif posA ~= 0 and posB == 0 then
		return true
	else -- a和b都不是经验，都是装备
		local equipDbA = EquipMO.queryEquipById(equipA.equipId)
		if not equipDbA then return false end
		local equipDbB = EquipMO.queryEquipById(equipB.equipId)
		if not equipDbB then return false end
		if equipDbA.quality > equipDbB.quality then
			return true
		elseif equipDbA.quality == equipDbB.quality then
			if equipA.level > equipB.level then
				return true
			elseif equipA.level == equipB.level then
				if posA < posB then
					return true
				elseif posA == posB then
					if equipA.exp > equipB.exp then
						return true
					elseif equipA.exp == equipB.exp then
						if equipA.keyId < equipB.keyId then return true
						else return false end
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	end
end

function EquipBO.orderEquipNew(equipA, equipB)
	local posA = EquipMO.getPosByEquipId(equipA.equipId)
	local posB = EquipMO.getPosByEquipId(equipB.equipId)
	if posA == 0 and posB == 0 then  -- 都是经验
		local equipDbA = EquipMO.queryEquipById(equipA.equipId)
		if not equipDbA then return false end
		local equipDbB = EquipMO.queryEquipById(equipB.equipId)
		if not equipDbB then return false end
		if equipDbA.a < equipDbB.a then  -- a比b的经验值高
			return true
		elseif equipDbA.a == equipDbB.a then
			if equipA.keyId < equipB.keyId then return true
			else return false end
		else
			return false
		end
	elseif posA == 0 and posB ~= 0 then
		return true
	elseif posA ~= 0 and posB == 0 then
		return false
	else -- a和b都不是经验，都是装备
		local equipDbA = EquipMO.queryEquipById(equipA.equipId)
		if not equipDbA then return false end
		local equipDbB = EquipMO.queryEquipById(equipB.equipId)
		if not equipDbB then return false end
		if equipDbA.quality < equipDbB.quality then
			return true
		elseif equipDbA.quality == equipDbB.quality then
			if equipA.level < equipB.level then
				return true
			elseif equipA.level == equipB.level then
				if posA < posB then
					return true
				elseif posA == posB then
					if equipA.exp < equipB.exp then
						return true
					elseif equipA.exp == equipB.exp then
						if equipA.keyId < equipB.keyId then return true
						else return false end
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	end
end

function EquipBO.asynGetEquip(doneCallback)
	local function updateGetEquip(name, data)
		EquipBO.update(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(updateGetEquip, NetRequest.new("GetEquip"))
end

-- fromFormat: 从阵型的哪个位置，0表示从仓库
-- toFormat: 到阵型的哪个位置, 0表示卸下
function EquipBO.asynEquip(doneCallback, keyId, fromFormat, toFormat)
	if keyId and fromFormat == 0 and toFormat == 0 then
		return
	end
	local param = {}
	param.from = keyId
	param.fromPos = fromFormat
	param.toPos = toFormat

	local equip = EquipMO.getEquipByKeyId(keyId)
	local equipPos = 0
	if keyId ~= 0 then equipPos = EquipMO.getPosByEquipId(equip.equipId) end

	if keyId ~= 0 then
		if toFormat ~= 0 then
			local toKeyId = EquipMO.getKeyIdAtPos(toFormat, equipPos)
			if toKeyId ~= 0 then -- 被替换的位置上有装备，两者交换
				param.to = toKeyId
			end
		end
	else -- 两个阵型部队交换所有装备
		param.to = 0
	end

	local function parseEquip(name, data)
		if keyId == 0 then -- 两个阵型部队交换所有装备
			local tmp = EquipMO.equipData_[fromFormat]
			EquipMO.equipData_[fromFormat] = EquipMO.equipData_[toFormat]
			EquipMO.equipData_[toFormat] = tmp
			for index = 1, EQUIP_POS_CRIT_DEF do
				local equip = EquipBO.getEquipAtPos(fromFormat, index)
				if equip then
					equip.formatPos = fromFormat
				end

				local equip = EquipBO.getEquipAtPos(toFormat, index)
				if equip then
					equip.formatPos = toFormat
				end
			end

			EnergySparMO.swapInlayData(fromFormat, toFormat)
		else
			if fromFormat == 0 then -- 装上装备
				equip.formatPos = toFormat -- 安装到的部队
				EquipMO.equipData_[toFormat][equipPos] = keyId
			elseif toFormat == 0 then  -- 卸下装备
				equip.formatPos = 0
				EquipMO.equipData_[fromFormat][equipPos] = 0
			else -- 两个装备是交换位置
				local tmpToKeyId = EquipMO.getKeyIdAtPos(toFormat, equipPos)

				equip.formatPos = toFormat
				EquipMO.equipData_[toFormat][equipPos] = keyId

				if tmpToKeyId == 0 then -- 替换到的位置之前无装备
					EquipMO.equipData_[fromFormat][equipPos] = 0
				else
					local toEquip = EquipMO.getEquipByKeyId(tmpToKeyId)
					toEquip.formatPos = fromFormat
					EquipMO.equipData_[fromFormat][equipPos] = tmpToKeyId
				end
			end
		end

		UserBO.triggerFightCheck()
		-- UserBO.triggerEquip(equipPos)
		UserBO.triggerEquip(equip)

		if ActivityBO.isValid(ACTIVITY_ID_PURPLE_EQP_COL) then -- 紫装收集穿戴
			ActivityBO.trigger(ACTIVITY_ID_PURPLE_EQP_COL)
		end

		Notify.notify(LOCAL_EQUIP_EVENT)

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseEquip, NetRequest.new("OnEquip", param))
end

function EquipBO.asynEquipUpgrade(doneCallback, keyId, needEquips)
	if #needEquips <= 0 then return end

	local function parseEquipUpgrade(name, data)
		gdump(data, "[EquipBO] equip upgrade")

		-- 更新装备等级和经验
		local equip = EquipMO.getEquipByKeyId(keyId)
		local oldLv = equip.level
		equip.level = data.lv
		equip.exp = data.exp

		for index = 1, #needEquips do -- 删除被吞掉的装备
			EquipMO.removeEquipByKeyId(needEquips[index].keyId)
		end

		if equip.formatPos > 0 then  -- 装备是装上了的，会影响战斗力
			UserBO.triggerFightCheck()
			local equipPos = EquipMO.getPosByEquipId(equip.equipId)
			-- UserBO.triggerEquip(equipPos)
			UserBO.triggerEquip(equip)
		end

		if ActivityBO.isValid(ACTIVITY_ID_PURPLE_EQP_UP) then
			ActivityBO.trigger(ACTIVITY_ID_PURPLE_EQP_UP, {keyId = keyId, oldLv = oldLv, newLv = equip.level})
		end

		Notify.notify(LOCAL_EQUIP_EVENT)
		--任务计数
		TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_EQUIP_UP,type = 1})
		if doneCallback then doneCallback() end
	end

	local equip = EquipMO.getEquipByKeyId(keyId)

	local from = {}
	for index = 1, #needEquips do
		table.insert(from, needEquips[index].keyId)
	end

	SocketWrapper.wrapSend(parseEquipUpgrade, NetRequest.new("UpEquip", {keyId = keyId, pos = equip.formatPos, from = from}))
end

function EquipBO.asynSellEquip(doneCallback, equips)
	if #equips <= 0 then return end

	local function parseSellEquip(name, data)
		gdump(data, "[EquipBO] sell equip")

		--TK统计 获得资源
		TKGameBO.onGetResTk(RESOURCE_ID_STONE,data.stone,TKText[13],TKGAME_USERES_TYPE_UPDATE)
		local delta = UserMO.updateResource(ITEM_KIND_RESOURCE, data.stone, RESOURCE_ID_STONE)

		for index = 1, #equips do
			EquipMO.removeEquipByKeyId(equips[index].keyId)
		end

		Notify.notify(LOCAL_EQUIP_EVENT)

		if doneCallback then doneCallback({awards = delta}) end
	end

	local param = {keyId = {}}
	for index = 1, #equips do
		table.insert(param.keyId, equips[index].keyId)
	end

	SocketWrapper.wrapSend(parseSellEquip, NetRequest.new("SellEquip", param))
end

function EquipBO.asynAllEquip(doneCallback, formatIndex, on, off)
	local onData = {}
	local offData = {}
	for pos, keyId in pairs(on) do
		onData[#onData + 1] = keyId
	end

	for pos, keyId in pairs(off) do
		offData[#offData + 1] = keyId
	end

	local function parseAllEquip(name, data)
		gdump(data, "[EquipBO] all equip")

		for index = 1, #offData do
			local keyId = offData[index]
			local equip = EquipMO.getEquipByKeyId(keyId)
			equip.formatPos = 0

			local equipPos = EquipMO.getPosByEquipId(equip.equipId)
			EquipMO.equipData_[formatIndex][equipPos] = 0
		end

		for index = 1, #onData do  -- 要穿戴的装备
			local keyId = onData[index]
			local equip = EquipMO.getEquipByKeyId(keyId)
			equip.formatPos = formatIndex

			local equipPos = EquipMO.getPosByEquipId(equip.equipId)
			EquipMO.equipData_[formatIndex][equipPos] = keyId

			if equipPos == EQUIP_POS_ATK or equipPos == EQUIP_POS_DODGE or equipPos == EQUIP_POS_CRIT then
				-- UserBO.triggerEquip(equipPos)
				UserBO.triggerEquip(equip)
			end
		end

		UserBO.triggerFightCheck()

		if ActivityBO.isValid(ACTIVITY_ID_PURPLE_EQP_COL) then -- 紫装收集穿戴
			ActivityBO.trigger(ACTIVITY_ID_PURPLE_EQP_COL)
		end

		Notify.notify(LOCAL_EQUIP_EVENT)

		if doneCallback then doneCallback() end

		--触发引导
		NewerBO.showNewerGuide()
	end
	SocketWrapper.wrapSend(parseAllEquip, NetRequest.new("AllEquip", {pos = formatIndex, on = onData, off = offData}))
end

-- 是否确定夸大装备容量
function EquipBO.asynUpCapacity(doneCallback)
	local function parseCapacity(name, data)
		gdump(data, "[EquipBO] UpCapacity")

		TKGameBO.onUseCoinTk(data.gold,TKText[14],TKGAME_USERES_TYPE_UPDATE)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)

		UserMO.equipWarhouse_ = UserMO.equipWarhouse_ + EQUIP_CAPACITY_DELTA_NUM

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseCapacity, NetRequest.new("UpCapacity"))
end

-- 装备进阶
function EquipBO.equipUp(equip,doneCallback)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		equip.equipId = data.equipId
		equip.level = data.lv
		equip.exp = data.exp
		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		Notify.notify(LOCAL_EQUIP_EVENT)
		if equip.formatPos > 0 then  -- 装备是装上了的，会影响战斗力
			UserBO.triggerFightCheck()
			local equipPos = EquipMO.getPosByEquipId(equip.equipId)
			-- UserBO.triggerEquip(equipPos)
			UserBO.triggerEquip(equip)
		end
		Toast.show(CommonText[20154])
		if doneCallback then doneCallback(equip) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("EquipQualityUp",{pos = equip.formatPos, keyId = equip.keyId}))
end

-- 装备升星
function EquipBO.equipUpStar(equip,doneCallback)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		local newEquip = PbProtocol.decodeRecord(data["equip"])
		if table.isexist(data, "equip") then
			EquipMO.equip_[newEquip.keyId] = {equipId = newEquip.equipId, level = newEquip.lv, exp = newEquip.exp, keyId = newEquip.keyId, formatPos = newEquip.pos, starLv = newEquip.starLv}
		end

		--刷新资源
		local awards = PbProtocol.decodeArray(data["award"])
		local resources = {}
		for index=1,#awards do
			resources[#resources + 1] = {kind = awards[index].type, count = awards[index].count, id = awards[index].id}
		end
		UserMO.reduceResources(resources)

		Notify.notify(LOCAL_EQUIP_EVENT)

		for index = 1, #data.needKeyId do -- 删除被吞掉的装备
			EquipMO.removeEquipByKeyId(data.needKeyId[index])
		end

		if equip.formatPos > 0 then  -- 装备是装上了的，会影响战斗力
			UserBO.triggerFightCheck()
			local equipPos = EquipMO.getPosByEquipId(equip.equipId)
			-- UserBO.triggerEquip(equipPos)
			UserBO.triggerEquip(equip)
		end
		Toast.show(CommonText[5058])
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpEquipStarLv",{keyId = equip.keyId, pos = equip.formatPos}))
end