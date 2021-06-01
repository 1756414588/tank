
-- 军备BO

WeaponryBO = {}
WeaponryBO.Weaponryprop = {}			--图纸

-- 获取军备的全部属性
function WeaponryBO.getEquipAttr()
	local ret = {}
	if not UserMO.queryFuncOpen(UFP_WEAPONRY) then return ret end
	local medals = WeaponryMO.getShowMedals()
	for k , v in pairs(medals) do
		local attrs = WeaponryBO.getPartAttrData(v.keyId,nil,true)
		for ndex = 1 , #attrs do
			local attr = attrs[ndex]
			ret[#ret + 1] = attr
		end
	end
	return ret
end

-- 获取某一单一军备的全部战斗力
-- keyId 装备绝对ID
-- datas 装备数据 （和keyId效果一样）
-- useSkill是否使用技能效果
function WeaponryBO.getPartAttrData(keyId,datas,useSkill)
	useSkill = useSkill or false
	local data = datas
	if not data then
		data = WeaponryMO.WeaponryList[keyId]
	end
	-- 军备属性
	local md = WeaponryMO.queryById(data.equip_id)
	local temp = json.decode(md.atts)
	local attrs = {}
	for k,v in pairs(temp) do
		local attrid = v[1]
		local attrvalue = v[2]
		local att = AttributeBO.getAttributeData(attrid, attrvalue)
		attrs[#attrs + 1] = att
	end
	if useSkill and UserMO.queryFuncOpen(UFP_WEAP_CHANGE) then
		-- 军备技能属性
		local skills = PbProtocol.decodeArray(data.skillLv)
		if data.lordEquipSaveType and data.lordEquipSaveType == 1 then --根据当前使用的类型选择相应的属性
			skills = PbProtocol.decodeArray(data.skillLvSecond)
		end
		for index = 1 , #skills do
			local skilldata = WeaponryMO.queryChangeSkillById(skills[index].v1)
			if skilldata.attrs then
				local temp = json.decode(skilldata.attrs)
				for k,v in pairs(temp) do
					local attrid = v[1]
					local attrvalue = v[2]
					local att = AttributeBO.getAttributeData(attrid, attrvalue)
					attrs[#attrs + 1] = att
				end
			end
		end
	end
	return attrs
end

-- 全身军备带兵量
function WeaponryBO.WeapTakeAllTank()
	local tankCount = 0
	if not UserMO.queryFuncOpen(UFP_WEAPONRY) then return tankCount end
	local medals = WeaponryMO.getShowMedals()
	for k , v in pairs(medals) do
		local count = WeaponryBO.WeapTakeTank(v.keyId)
		tankCount = tankCount + count
	end
	return tankCount
end

-- 某个军备的带兵量 含军备技能
function WeaponryBO.WeapTakeTank(keyId, datas)
	local data = datas
	if not data then
		data = WeaponryMO.WeaponryList[keyId]
	end
	-- 带兵量
	local tankCount = 0
	-- 军备属性
	local md = WeaponryMO.queryById(data.equip_id)
	tankCount = tankCount + md.tankCount
	-- 军备技能
	-- 军备技能属性
	if UserMO.queryFuncOpen(UFP_WEAP_CHANGE) then
		local skills = PbProtocol.decodeArray(data.skillLv)
		if data.lordEquipSaveType and data.lordEquipSaveType == 1 then --根据当前使用的类型选择相应的属性
			skills = PbProtocol.decodeArray(data.skillLvSecond)
		end
		for index = 1 , #skills do
			local skilldata = WeaponryMO.queryChangeSkillById(skills[index].v1)
			tankCount = tankCount + skilldata.tankCount
		end
	end
	return tankCount
end

-- 获取某一单一军备的全部显示战力
function WeaponryBO.getPartAttrShow(keyId,datas)
	local attrs = WeaponryBO.getPartAttrData(keyId,datas,true)
	local show = 0
	for index = 1 , #attrs do
		local data = attrs[index]
		show =  show + FormulaBO.partStrengthValue(data.id, data.value)
	end
	--军备的带兵量
	local tankcount = WeaponryBO.WeapTakeTank(keyId,datas)
	show = show + tankcount * 20
	return show
end

-- function WeaponryBO.getShowAttr(showEquip)
-- 	local attrs = {}
-- 	local num = 0
-- 	for k,v in pairs(WeaponryBO.WeaponryShow) do
-- 		if v.pos ~= 0 then
-- 			num = num + 1
-- 			local md = WeaponryMO.queryById(v.equip_id)
-- 			local temp = json.decode(md.atts)
-- 			for m,n in ipairs(temp) do
-- 				if not attrs[n[1]] then
-- 					attrs[n[1]] = n[2]
-- 				else
-- 					attrs[n[1]] = attrs[n[1]] + n[2]
-- 				end
-- 			end
-- 		end
-- 	end
-- 	-- --判断套装
-- 	-- if not showEquip then
-- 	-- 	local list = MedalMO.queryBouns()
-- 	-- 	for k,v in ipairs(list) do
-- 	-- 		if num >= v.number then
-- 	-- 			local temp = json.decode(v.bonus)
-- 	-- 			for m,n in ipairs(temp) do
-- 	-- 				if not attrs[n[1]] then
-- 	-- 					attrs[n[1]] = n[2]
-- 	-- 				else
-- 	-- 					attrs[n[1]] = attrs[n[1]] + n[2]
-- 	-- 				end
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- 	local ret = {}
-- 	for k,v in pairs(attrs) do
-- 		local att = AttributeBO.getAttributeData(k, v)
-- 		ret[att.id] = att
-- 	end
-- 	return ret
-- end


--更新军备列表
function WeaponryBO.updateMedal(data)
	local data1 = PbProtocol.decodeArray(data["puton"])
	for k,v in pairs(data1) do
		-- WeaponryBO.WeaponryShow[v.keyId] = v
		WeaponryMO.WeaponryList[v.keyId] = v
	end
	local data1 = PbProtocol.decodeArray(data["store"])
	for k,v in pairs(data1) do
		WeaponryMO.WeaponryList[v.keyId] = v
	end
	local data1 = PbProtocol.decodeArray(data["prop"])
	for k,v in pairs(data1) do
		WeaponryBO.Weaponryprop[v.propId] = v
	end
	WeaponryBO.buildEquip = PbProtocol.decodeRecord(data["leqb"])

	WeaponryBO.MaxTechId = data.unlock_tech_max

	WeaponryBO.currEmployId = data.employ_tech_id

	WeaponryBO.employEndtime = data.employ_end_time

	WeaponryBO.isFirstEmploy = data.free

	--材料队列
	WeaponryBO.MaterialQueue = PbProtocol.decodeArray(data["mat_queue"])
	MaterialBO.updateInfo()


	MaterialMO.buyCount_ = data.buyCount

	-- repeated LordEquip puton = 1;//穿在指挥官身上的装备列表
	-- repeated LordEquip store = 2;//仓库中的装备列表
	-- repeated Prop prop = 3;//材料和图纸列表
	-- optional LordEquipBuilding leqb = 4;//生产中的军备
	-- optional int32 unlock_max_tech_id = 5;//已解锁的最高铁匠
	-- optional int32 employ_tech_id = 6;//雇佣中的铁匠
	-- optional int32 employ_end_ime = 7;//雇佣结束时间
end


--军备穿
function WeaponryBO.PutonLordEquip(keyId,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		local equips = PbProtocol.decodeArray(data["le"]) -- 回滚
		for index = 1, #equips do
			local equip = equips[index]
			WeaponryMO.WeaponryList[equip.keyId] = equip
		end
		-- local equip = PbProtocol.decodeRecord(data["le"])
		-- WeaponryMO.WeaponryList[equip.keyId] = equip
		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("PutonLordEquip",{keyId = keyId}))
end

--军备脱
function WeaponryBO.TakeOffEquip(pos,rhand)
	local function getResult(name,data)
		local equip = PbProtocol.decodeRecord(data["le"])
		Loading.getInstance():unshow()
		WeaponryMO.WeaponryList[equip.keyId] = equip
		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("TakeOffEquip",{pos = pos}))
end

-- 添加一个军备
function WeaponryBO.addMedal(medal)
	WeaponryMO.WeaponryList[medal.keyId] = medal
end

-- -- 删除某个军备
-- function WeaponryBO.reducePaper(keyId)
-- 	if WeaponryBO.Weaponryprop and WeaponryBO.Weaponryprop[keyId]  ~= nil then
-- 		WeaponryBO.Weaponryprop[keyId] = nil
-- 	end
-- end

function WeaponryBO.addPaper(medal)
	if WeaponryBO.Weaponryprop == nil then
		WeaponryBO.Weaponryprop = {}
	end
	if WeaponryBO.Weaponryprop[medal.propId] ~= nil then
		medal.count = medal.count + WeaponryBO.Weaponryprop[medal.propId].count
	end
	WeaponryBO.Weaponryprop[medal.propId] = medal
end

function WeaponryBO.addMaterial(medal)
	if WeaponryBO.Weaponryprop == nil then
		WeaponryBO.Weaponryprop = {}
	end
	if WeaponryBO.Weaponryprop[medal.propId] ~= nil then
		medal.count = medal.count + WeaponryBO.Weaponryprop[medal.propId].count
	end
	WeaponryBO.Weaponryprop[medal.propId] = medal
end


-- 按照品质进行排序
-- function WeaponryBO.sortMedal(medalA, medalB)
-- 	local medalADb = WeaponryMO.queryById(medalA.equip_id)
-- 	local medalBDb = WeaponryMO.queryById(medalB.equip_id)
	
-- 	if medalADb.pos == medalBDb.pos then
-- 		return (medalA.keyId > medalB.keyId)
-- 	else
-- 		local medalADb = WeaponryMO.queryById(medalA.equip_id)
-- 		local medalBDb = WeaponryMO.queryById(medalB.equip_id)
-- 		if medalADb and medalBDb and medalADb.quality > medalBDb.quality then
-- 			return true
-- 		elseif medalADb and medalBDb and medalADb.quality == medalBDb.quality then
-- 			return (medalADb.id < medalBDb.id)
-- 		else
-- 			return false
-- 		end
-- 	end
-- end

-- 分解装备
function WeaponryBO.explodeWeaponry(rhand,keyId,qualitys)
	local function parseResult(name, data)
		-- dump(data,"分解品质")
		Loading.getInstance():unshow()
		if keyId then -- 分解一个配件
			WeaponryMO.WeaponryList[keyId] = nil
		else
			for index = 1, #qualitys do
				local list = WeaponryMO.getPosWithQuality(qualitys[index])
				for dex = 1 , #list do
					local once = list[dex]
					WeaponryMO.WeaponryList[once.keyId] = nil
				end
			end
		end

		local awards = PbProtocol.decodeArray(data["award"])	
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		Notify.notify(LOCLA_PART_EVENT)
		rhand(ret)
	end
	local param = {}
	if keyId then
		param.keyId = keyId
	else
		param.quality = qualitys
	end

	SocketWrapper.wrapSend(parseResult, NetRequest.new("ResloveLordEquip",param))
end

-- 打造 申请装备ID
-- 刷新 打造数据 和 材料消耗
function WeaponryBO.ProductEquip(rhand,equipId)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		-- 更新打造数据
		WeaponryBO.buildEquip = nil
		WeaponryBO.buildEquip = PbProtocol.decodeRecord(data["leqb"])
		
		--刷新消耗
		local res = PbProtocol.decodeArray(data["cost"])   --/消耗的材料列表
		UserMO.updateResources(res)
		Notify.notify(LOCAL_BUILD_EVENT)
		Notify.notify(LOCAL_WEAPONRY_EMPLOY)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ProductEquip",{equip_id = equipId}))
end

--抽取装备 装备打造结束,收取装备
function WeaponryBO.CollectLordEquip(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		local temp = data["lord_equip"]
		local equip = PbProtocol.decodeRecord(temp)
		
		-- 添加装备 
		WeaponryMO.WeaponryList[equip.keyId] = equip
		WeaponryBO.buildEquip = nil

		-- 添加显示
		local award = {id = equip.equip_id,type = ITEM_KIND_WEAPONRY_ICON ,keyId =equip.keyId,kind = ITEM_KIND_WEAPONRY_ICON ,count = 1}
		local awards = {}
		awards.awards = {}
		table.insert(awards.awards,award)
		UiUtil.showAwards(awards)

		Notify.notify(LOCAL_WEAPONRY_EMPLOY)
		Notify.notify(LOCAL_BUILD_EVENT)
		rhand()
		--加入仓库	
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("CollectLordEquip"))
end

function WeaponryBO.UseTechnical(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		WeaponryBO.buildEquip.endTime = data.end_time
		WeaponryBO.buildEquip.tech_id = data.tech_id
		Notify.notify(LOCAL_BUILD_EVENT)
		Notify.notify(LOCAL_WEAPONRY_EMPLOY)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UseTechnical"))	
end

function WeaponryBO.EmployTechnical(rhand,id)
	local function parseResult(name, data)
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		WeaponryBO.employEndtime =  data.employ_end_time
		WeaponryBO.currEmployId = id
		if WeaponryBO.isFirstEmploy then
			WeaponryBO.isFirstEmploy  = false
		end
		Notify.notify(LOCAL_WEAPONRY_EMPLOY)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("EmployTechnical",{tech_id = id}))	
end

function WeaponryBO.LordEquipSpeedByGold(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		--剩余金币数
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		WeaponryBO.buildEquip.endTime = ManagerTimer.getTime()
		Notify.notify(LOCAL_BUILD_EVENT)
		Notify.notify(LOCAL_WEAPONRY_EMPLOY)
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("LordEquipSpeedByGold"))	
end

-- 按照品质进行排序
function WeaponryBO.sortPaper(chipA, chipB)
	local partADb = WeaponryMO.queryPaperById(chipA.propId) --MedalMO.queryById(chipA.chipId)
	local partBDb =  WeaponryMO.queryPaperById(chipB.propId)
	if partADb.quality > partBDb.quality then
		return true
	elseif partADb.quality == partBDb.quality then
		return (partADb.id < partBDb.id)
	else
		return false
	end
end


function WeaponryBO.parseUnlockTechnical(name, data)
	--if temp > WeaponryBO.MaxTechId then
		WeaponryBO.isFirstEmploy = data.free
	--end
	WeaponryBO.MaxTechId = data.unlock_tech_max
end

-- 获取洗练免费次数和倒计时
function WeaponryBO.loadEquipChageInfo(rhand)
	local function parseResult(name , data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("LordEquipChangeFreeTime"))
end

--军备洗练功能 
-- 装备keyid 洗练类型 装备状态 1穿戴0未穿戴
function WeaponryBO.loadEquipChage(rhand,keyId,btntype,state)
	local function parseResult(name , data)
		-- dump(data,"军备洗练")

		-- 更新装备
		local newequip = PbProtocol.decodeRecord(data["le"])
		WeaponryMO.WeaponryList[newequip.keyId] = newequip
		data.equip = newequip

		--更新金币
		local upcoin = {{kind = ITEM_KIND_COIN, id = 0, count = data.gold}}
		UserMO.updateResources(upcoin)

		-- 刷新战斗力
		if state == 1 then
			UserBO.triggerFightCheck()
		end
		
		rhand(data)
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("LordEquipChange",{keyId = keyId, type = btntype , puton = state}))	
end

-- 军备 比较穿戴和未出穿戴
function WeaponryBO.checkListUpWeaponryAtPos(equips,unequipslist)
	local state = false
	local unequipCount = unequipslist and #unequipslist or 0
	if unequipCount > 0 then
		if equips then
			local equipsdata = WeaponryMO.queryById(equips.equip_id)
			-- local equipsStrengthValue = WeaponryBO.getPartAttrShow(equips.keyId)
			for index = 1 , unequipCount do
				local unequips = unequipslist[index]
				local unequipsdata = WeaponryMO.queryById(unequips.equip_id)
				if unequipsdata.quality > equipsdata.quality then
					state = true
				-- elseif unequipsdata.quality == equipsdata.quality then
				-- 	local unequipsStrengthValue = WeaponryBO.getPartAttrShow(unequips.keyId)
				-- 	if unequipsStrengthValue > equipsStrengthValue then
				-- 		state = true
				-- 	end
				end
			end
		else
			state = true
		end
	end
	return state
end

function WeaponryBO.asynLockWeapon(doneCallback, weapon)
	local isPuton = nil
	if weapon.pos <= 0 then
		isPuton = 0
	else
		isPuton = 1
	end
	local function parseOnLock(name, data)
		local newequip = PbProtocol.decodeRecord(data["lordEquip"])
		WeaponryMO.WeaponryList[newequip.keyId] = newequip
		Notify.notify(LOCAL_WEAPONRY_LOCK)
		
		if doneCallback then doneCallback(data) end
	end

	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("LockLordEquip", {keyId = weapon.keyId, puton = isPuton}))
end

--获取套装
function WeaponryBO.getAallWeaponryScheme(doneCallback)
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()
		
		local awars = PbProtocol.decodeArray(data["leqScheme"])
		if awars then
			WeaponryMO.schemesAll = awars
		end
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("GetAllLeqScheme"))
end

--设置套装
function WeaponryBO.setWeaponryScheme(doneCallback, scheme)
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()

		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("SetLeqScheme", {leqScheme = scheme}))
end

--读取穿戴套装
function WeaponryBO.wealWeaponryScheme(doneCallback, kind)
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()
		local equips = PbProtocol.decodeArray(data["leq"])

		for i=1,#equips do
			local equip = equips[i]
			WeaponryMO.WeaponryList[equip.keyId] = equip
		end

		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("PutonLeqScheme", {type = kind}))
end

--解锁军备二套洗练属性
-- keyId   军备keyId
-- puton  是否穿戴
-- consumekeyId  解锁消耗军备的ID
function WeaponryBO.unLockSecondAttrbite(doneCallback, param)
	local param = param
	local costId = param.consumeKeyId
	local function parseOnLock(name, data)
		Loading.getInstance():unshow()
		UserMO.updateResource(ITEM_KIND_COIN, data.gold) --刷新金币数
		WeaponryMO.WeaponryList[costId] = nil --删除消耗的军备

		local newequip = PbProtocol.decodeRecord(data["le"])  --刷新解锁的军备
		WeaponryMO.WeaponryList[newequip.keyId] = newequip  

		if doneCallback then doneCallback(data) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseOnLock, NetRequest.new("LordEquipInherit", {keyId = param.keyId, puton = param.puton, consumekeyId = param.consumeKeyId}))
end

--设置是用第几套军备属性
-- type // 0第一套  1第二套
-- keyId //keyId
-- puton  // 0 未穿戴 1 已穿戴
-- operationType  //操作类型 1单个  2批量
function WeaponryBO.setWeaponryAttribute(doneCallback, myParam)
	local param = myParam
	local function parsSetCallback(name, data)
		Loading.getInstance():unshow()

		local equips = PbProtocol.decodeArray(data["le"])
		for index = 1, #equips do
			local equip = equips[index]
			WeaponryMO.WeaponryList[equip.keyId] = equip
		end

		Notify.notify(LOCLA_PART_EVENT)
		UserBO.triggerFightCheck()
		if doneCallback then doneCallback(equips) end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parsSetCallback, NetRequest.new("SetLordEquipUseType", {type = param.type,keyId = param.keyId, puton = param.puton, operationType = param.operationType}))
end