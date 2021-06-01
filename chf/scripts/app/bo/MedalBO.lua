--
-- Author: xiaoxing
-- Date: 2016-12-21 19:14:33
--
MedalBO = {}
MedalBO.medals = {}
MedalBO.matrials = {}
MedalBO.chips = {}
MedalBO.shows = {}
local IDS = {
	detergent = 1,      --洗涤剂
	grindstone = 2,      --研磨石
	polishingMtr = 3,      --抛光材料
	maintainOil = 4,      --保养油
	grindTool = 5,      --打磨工具
	precisionInstrument = 6,  --精密仪器
	mysteryStone = 7,         --神秘石
	corundumMatrial = 8,      --刚玉磨料
	inertGas = 9,         --惰性气体
}

function MedalBO.queryById(id)
	return MedalBO.medals[id]
end

function MedalBO.updateMedal(data)
	local data = PbProtocol.decodeArray(data["medal"])
	for k,v in ipairs(data) do
		MedalBO.medals[v.keyId]	 = v
	end
end

function MedalBO.updateMedalChip(data)
	local data = PbProtocol.decodeArray(data["medalChip"])
	for k,v in ipairs(data) do
		MedalBO.chips[v.chipId] = v.count
	end
end

function MedalBO.updateMedalShow(data)
	local data = PbProtocol.decodeArray(data["medalBouns"])
	for k,v in ipairs(data) do
		MedalBO.shows[v.medalId] = v.state
	end
end

function MedalBO.addMedal(medal)
	MedalBO.medals[medal.keyId] = medal
	if not MedalBO.shows[medal.medalId] then
		MedalBO.shows[medal.medalId] = 0
	end
end

function MedalBO.updateMaterial(data)
	for k,v in pairs(data) do
		if IDS[k] then
			MedalBO.matrials[IDS[k]] = v
		elseif k == "medalUpCdTime" then
			MedalBO.cd = v
		end
	end
end

function MedalBO.getPartAttrData(keyId, medalId, data)
	local ret = {}
	local id = medalId
	local data = data
	if keyId then
		data = MedalBO.medals[keyId]
	end
	if data then
		id = data.medalId
	end
	local md = MedalMO.queryById(id)
	local value = FormulaBO.medalAttributeValue(md.attr1, md.a1, md.b1, data and data.upLv or 0, data and data.refitLv or 0)
	local att = AttributeBO.getAttributeData(md.attr1, value)
	ret[att.id] = att
	local total = FormulaBO.partStrengthValue(md.attr1, att.value)
	if md.attr2 > 0 then
		value = FormulaBO.medalAttributeValue(md.attr2, md.a2, md.b2, data and data.upLv or 0, data and data.refitLv or 0)
		att = AttributeBO.getAttributeData(md.attr2, value)
		ret[att.id] = att
		total = total + FormulaBO.partStrengthValue(md.attr2, att.value)
	end
	ret.strengthValue = math.floor(total)
	return ret
end

function MedalBO.getEquipAttr(showEquip)
	local medals = MedalMO.getPosMedal(1)
	local ret = {}
	for p,item in pairs(medals) do
		for k,v in pairs(item) do
			local attr = MedalBO.getPartAttrData(v.keyId)
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
	if not showEquip then
		local attrs = MedalBO.getShowAttr()
		for m,n in pairs(attrs) do
			if not ret[m] then 
				ret[m] = clone(n) 
			else
				if type(n) == "number" then
					ret[m] = ret[m] + n
				else
					ret[m].value = ret[m].value + n.value
				end
			end
		end
	end
	return ret
end

function MedalBO.getShowAttr(showEquip)
	local attrs = {}
	local num = 0
	for k,v in pairs(MedalBO.shows) do
		if v == 1 then
			num = num + 1
			local md = MedalMO.queryById(k)
			local temp = json.decode(md.attrShowed)
			for m,n in ipairs(temp) do
				if not attrs[n[1]] then
					attrs[n[1]] = n[2]
				else
					attrs[n[1]] = attrs[n[1]] + n[2]
				end
			end
		end
	end
	--判断套装
	if not showEquip then
		local list = MedalMO.queryBouns()
		for k,v in ipairs(list) do
			if num >= v.number then
				local temp = json.decode(v.bonus)
				for m,n in ipairs(temp) do
					if not attrs[n[1]] then
						attrs[n[1]] = n[2]
					else
						attrs[n[1]] = attrs[n[1]] + n[2]
					end
				end
			end
		end
	end
	local ret = {}
	for k,v in pairs(attrs) do
		local att = AttributeBO.getAttributeData(k, v)
		ret[att.id] = att
	end
	return ret
end

-- 按照品质进行排序
function MedalBO.sortMedal(medalA, medalB)
	if medalA.medalId == medalB.medalId then
		return (medalA.keyId > medalB.keyId)
	else
		local medalADb = MedalMO.queryById(medalA.medalId)
		local medalBDb = MedalMO.queryById(medalB.medalId)
		if medalADb and medalBDb and medalADb.quality > medalBDb.quality then
			return true
		elseif medalADb and medalBDb and medalADb.quality == medalBDb.quality then
			return (medalADb.medalId < medalBDb.medalId)
		else
			return false
		end
	end
end


-- 按照品质进行排序
function MedalBO.sortChip(chipA, chipB)
	local partADb = MedalMO.queryById(chipA.chipId)
	local partBDb = MedalMO.queryById(chipB.chipId)
	local ac = (partADb.chipCount > 0 and chipA.count >= partADb.chipCount and chipA.chipId ~= MEDAL_ID_ALL_PIECE) and 1 or 0
	local bc = (partBDb.chipCount > 0 and chipB.count >= partBDb.chipCount and chipB.chipId ~= MEDAL_ID_ALL_PIECE) and 1 or 0
	if ac ~= bc then
		return ac > bc
	elseif chipA.chipId == MEDAL_ID_ALL_PIECE and chipB.chipId ~= MEDAL_ID_ALL_PIECE then
		return true
	elseif chipA.chipId ~= MEDAL_ID_ALL_PIECE and chipB.chipId == MEDAL_ID_ALL_PIECE then
		return (partADb.medalId > partBDb.medalId)
	elseif partADb.quality > partBDb.quality then
		return true
	elseif partADb.quality == partBDb.quality then
		return (partADb.medalId < partBDb.medalId)
	else
		return false
	end
end

function MedalBO.OnMedal(keyId,pos,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local medals = PbProtocol.decodeArray(data["medals"]) -- 回滚 
		for index = 1, #medals do
			local medal = medals[index]
			MedalBO.medals[medal.keyId] = medal
		end
		-- pos = (pos + 1)%2
		-- MedalBO.medals[keyId].pos = pos
		Toast.show(CommonText[649])
		Notify.notify(LOCLA_MEDAL_EVENT)
		UserBO.triggerFightCheck()
		rhand()
		MedalBO.checkAttr(MedalBO.medals[keyId])
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("OnMedal",{keyId = keyId,pos = pos}))
end

function MedalBO.checkAttr(medal)
	if medal.pos == 0 then return end
	--检查属性排行榜
	local md = MedalMO.queryById(medal.medalId)
	local id,index = nil,nil
	if md.attr1 == ATTRIBUTE_INDEX_FORTITUDE or md.attr2 == ATTRIBUTE_INDEX_FORTITUDE then
		id = ATTRIBUTE_INDEX_FORTITUDE
		index = 8
	elseif md.attr1 == ATTRIBUTE_INDEX_FRIGHTEN or md.attr2 == ATTRIBUTE_INDEX_FRIGHTEN then
		id = ATTRIBUTE_INDEX_FRIGHTEN
		index = 7
	end
	if id then
		local attrs = MedalBO.getEquipAttr(1)
		for k,v in pairs(attrs) do
			if k == id then
				UserBO.asynSetData(nil, index, v.value*1000)
				return
			end
		end
	end
end

--买cd
function MedalBO.buyCd(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		UserMO.updateResource(ITEM_KIND_COIN,data.gold)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyMedalCdTime"))
end
--升级
function MedalBO.upMedal(keyId,pos,rhand)
	local oldLv = MedalBO.medals[keyId].upLv
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		UserMO.updateResources(PbProtocol.decodeArray(data.atom))
		MedalBO.cd = data.cdTime
		MedalBO.medals[keyId].upLv = data.upLv
		MedalBO.medals[keyId].upExp = data.upExp
		if data.upLv > oldLv then
			UserBO.triggerFightCheck()
			MedalBO.checkAttr(MedalBO.medals[keyId])
			Notify.notify(LOCLA_MEDAL_EVENT)
		end
		rhand(data.hitState)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpMedal",{keyId = keyId,pos = pos}))
end
--一键升级
function MedalBO.aKeyUpMedal(keyId,pos,rhand)
	local oldLv = MedalBO.medals[keyId].upLv
	local function parseResult(name,data)
		gdump(data,"aKeyUpMedal data ==")
		Loading.getInstance():unshow()
		UserMO.updateResources(PbProtocol.decodeArray(data.atom))
		MedalBO.cd = data.cdTime
		MedalBO.luckyHitCount = data.luckyHit
		MedalBO.medals[keyId].upLv = data.upLv
		MedalBO.medals[keyId].upExp = data.upExp
		if data.upLv > oldLv then
			UserBO.triggerFightCheck()
			MedalBO.checkAttr(MedalBO.medals[keyId])
			Notify.notify(LOCLA_MEDAL_EVENT)
		end
		rhand(data.state)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("QuickUpMedal",{keyId = keyId,pos = pos}))
end

function MedalBO.refitMedal(keyId,pos,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		MedalBO.medals[keyId].refitLv = data.refitLv
		UserMO.updateResources(PbProtocol.decodeArray(data.atom))
		Notify.notify(LOCLA_MEDAL_EVENT)
		UserBO.triggerFightCheck()
		MedalBO.checkAttr(MedalBO.medals[keyId])
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("RefitMedal",{keyId = keyId,pos = pos}))
end

function MedalBO.combineMedal(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		-- 新产生了一个勋章
		local medal = PbProtocol.decodeRecord(data["medal"])
		MedalBO.addMedal(medal)
		local stastAwards = {awards = {{kind = ITEM_KIND_MEDAL_ICON, id = medal.medalId, count = 1}}}
		-- 减少碎片
		local md = MedalMO.queryById(medal.medalId)
		local count = UserMO.getResource(ITEM_KIND_MEDAL_CHIP, medal.medalId)
		if count < md.chipCount then -- 使用了万能碎片
			local res = {}
			res[#res + 1] = {kind = ITEM_KIND_MEDAL_CHIP, id = medal.medalId, count = count}
			res[#res + 1] = {kind = ITEM_KIND_MEDAL_CHIP, id = MEDAL_ID_ALL_PIECE, count = (md.chipCount - count)}
			UserMO.reduceResources(res)
		else
			UserMO.reduceResource(ITEM_KIND_MEDAL_CHIP, md.chipCount, medal.medalId)
		end
		Notify.notify(LOCLA_MEDAL_EVENT)
		rhand(stastAwards)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CombineMedal",{medalChipId = id}))
end

function MedalBO.explodeMedal(rhand,keyId,qualitys)
	local function parseResult(name, data)
		if keyId then -- 分解一个配件
			MedalBO.medals[keyId] = nil
		else
			local function isInQuality(quality)
				for index = 1, #qualitys do
					if quality == qualitys[index] then return true end
				end
			end

			local parts = MedalMO.getFreeMedals()
			for index = 1, #parts do
				local part = parts[index]
				local partDB = MedalMO.queryById(part.medalId)
				if isInQuality(partDB.quality) and not part.locked then
					MedalBO.medals[part.keyId] = nil
				end
			end
		end

		local awards = PbProtocol.decodeArray(data["awards"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		Notify.notify(LOCLA_MEDAL_EVENT)
		rhand(ret)
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ExplodeMedal",{keyId = keyId,quality = qualitys}))
end

-- qualitys: 用于分解所有这些品质下的碎片
function MedalBO.explodeChip(doneCallback, chipId, count, qualitys)
	local function parseExplodeChip(name, data)
		local res = {}
		if chipId then -- 分解一个碎片
			res[#res + 1] = {kind = ITEM_KIND_MEDAL_CHIP, id = chipId, count = count}
		else
			local function isInQuality(quality)
				for index = 1, #qualitys do
					if quality == qualitys[index] then return true end
				end
			end

			local chips = MedalMO.getAllChips()
			for index = 1, #chips do
				local chip = chips[index]
				local partDB = MedalMO.queryById(chip.chipId)
				if isInQuality(partDB.quality) then
					res[#res + 1] = {kind = ITEM_KIND_MEDAL_CHIP, id = chip.chipId, count = chip.count}
				end
			end
		end
		UserMO.reduceResources(res)
		Notify.notify(LOCLA_MEDAL_EVENT)

		local awards = PbProtocol.decodeArray(data["awards"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		if doneCallback then doneCallback(ret) end
	end
	local param = {}
	if chipId then
		param.chipId = chipId
		param.count = count
	else
		param.quality = qualitys
	end
	SocketWrapper.wrapSend(parseExplodeChip, NetRequest.new("ExplodeMedalChip", param))
end

function MedalBO.lockMedal(doneCallback, part)
	local locked
	if part.locked then
		locked = false
	else
		locked = true
	end
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()
		part.locked = data.locked
		Notify.notify(LOCLA_MEDAL_EVENT)
		if doneCallback then doneCallback(part.locked) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("LockMedal", {keyId = part.keyId, pos = part.pos, locked = locked}))
end

function MedalBO.showMedal(medalId,keyId,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		MedalBO.medals[keyId] = nil
		MedalBO.shows[medalId] = 1
		Notify.notify(LOCLA_MEDAL_EVENT)
		UserBO.triggerFightCheck()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("DoMedalBouns",{costMedalKeyId = keyId}))
end

--勋章精炼
function MedalBO.advanceMedal(rhand, keyId,pos)
	local keyId = keyId
	local pos = pos
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local medal = PbProtocol.decodeRecord(data["medal"])
		MedalBO.medals[keyId].refitLv = medal.refitLv
		MedalBO.medals[keyId].medalId = medal.medalId

		MedalBO.addMedal(medal)
		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))
		Notify.notify(LOCLA_MEDAL_EVENT)
		UserBO.triggerFightCheck()
		MedalBO.checkAttr(MedalBO.medals[keyId])
		if rhand then rhand(medal) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("TransMedal",{keyId = keyId,pos = pos}))
end

-- 判断 同一位置 是否有比当前更强的勋章
-- equipsList 装备列表
-- unequipsList 未装备列表
function MedalBO.checkListUpMedalsAtPos(equipsList, unequipsList)
	local state = false
	local equipsCount = equipsList and #equipsList or 0
	local unequipsCount = unequipsList and #unequipsList or 0
 	if unequipsCount > 0 then
 		if equipsCount > 0 then
 			local equips = equipsList[1]
 			local attr = MedalBO.getPartAttrData(equips.keyId)
 			for index = 1 , unequipsCount do
 				local unequips = unequipsList[index]
				local attrs = MedalBO.getPartAttrData(unequips.keyId)
				if attrs.strengthValue > attr.strengthValue then
					state = true
					break
				end
 			end
 		else
 			state = true
 		end
 	end
 	return state
 end 

 function MedalBO.queryMatrial()
 	local data = clone(IDS)
 	local aa = table.values(data)
 	--排序
 	function sortFun(a,b)
 		return a < b
 	end

 	table.sort(aa,sortFun)
 	return  table.values(aa)
 end