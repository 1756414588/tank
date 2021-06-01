
-- 关卡BO

CombatBO = {}

function CombatBO.onTick(dt)
	if CombatMO.extremeWipeTime_ > 0 then
		CombatMO.extremeWipeTime_ = CombatMO.extremeWipeTime_ - dt

		if CombatMO.extremeWipeTime_ < 0 then CombatMO.extremeWipeTime_ = 0 end

		local delta = math.ceil(CombatMO.extremeWipeTime_ / EXPLORE_EXTREME_WIPE_TIME)
		local newId = CombatMO.exploreExtremeHighest_ - delta

		if newId ~= CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] then  -- 扫荡向前推进
			gprint("CombatBO Wipe move on newId:", newId)
			CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] = newId
			Notify.notify(LOCAL_EXTREME_EVENT)
		end
	end
end

function CombatBO.update(data)
	-- gdump(data, "[CombatBO] get combat")

	if not CombatMO.tickTimer_ then
		CombatMO.tickTimer_ = ManagerTimer.addTickListener(CombatBO.onTick)
	end

	CombatMO.currentCombatId_ = 0
	CombatMO.combats_ = {}
	CombatMO.sections_ = {}
	
	if not data then return end

	CombatMO.currentCombatId_ = data.combatId  -- 副本进度关卡id，也就是当前打过的最新关卡。此id的下一关就是新开启可以打的关卡

	local combats = PbProtocol.decodeArray(data["combat"])
	gdump(combats, "[CombatBO] getCombat combats")

	for index = 1, #combats do  -- 设置tank的数量
		local data = combats[index]
		CombatMO.combats_[data.combatId] = data  -- 包含id和星

		local combatDB = CombatMO.queryCombatById(data.combatId)

		if not CombatMO.sections_[combatDB.sectionId] then CombatMO.sections_[combatDB.sectionId] = {} end
		CombatMO.sections_[combatDB.sectionId][#CombatMO.sections_[combatDB.sectionId] + 1] = combatDB.combatId
	end
	gprint("[CombatBO] update progress combat id:", CombatMO.currentCombatId_)

	-- 各个探险副本的进度
	CombatMO.currentExplore_  = {}
	CombatMO.currentExplore_[EXPLORE_TYPE_EQUIP] = data.equipEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_PART] = data.partEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] = data.extrEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_LIMIT] = data.timePrlrId
	CombatMO.currentExplore_[EXPLORE_TYPE_WAR] = data.militaryEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_ENERGYSPAR] = data.energyStoneEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_MEDAL] = data.medalEplrId
	CombatMO.currentExplore_[EXPLORE_TYPE_TACTIC] = data.tacticsId

	if CombatMO.currentExplore_[EXPLORE_TYPE_EQUIP] < 101 then CombatMO.currentExplore_[EXPLORE_TYPE_EQUIP] = 0 end
	if CombatMO.currentExplore_[EXPLORE_TYPE_PART] < 201 then CombatMO.currentExplore_[EXPLORE_TYPE_PART] = 0 end
	if CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] < 301 then CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] = 0 end

	CombatMO.exploreExtremeHighest_ = data.extrMark
	gdump(CombatMO.currentExplore_, "[CombatBO] explore ids")

	CombatMO.explores_ = {}
	CombatMO.exploreSections_ = {}

	local explores = PbProtocol.decodeArray(data["explore"])
	gdump(explores, "[CombatBO] getCombat explores")
	for index = 1, #explores do
		local explore = explores[index]
		CombatMO.explores_[explore.combatId] = explore
		local exploreDB = CombatMO.queryExploreById(explore.combatId)
		local sectionId = CombatMO.getExploreSectionIdByType(exploreDB.type)

		if not CombatMO.exploreSections_[sectionId] then CombatMO.exploreSections_[sectionId] = {} end
		CombatMO.exploreSections_[sectionId][#CombatMO.exploreSections_[sectionId] + 1] = exploreDB.exploreId
	end
	-- gdump(CombatMO.currentExplore_, "[CombatBO] explore ids")

	CombatMO.sectionBoxs_ = {}

	local boxs = PbProtocol.decodeArray(data["section"])
	gdump(boxs, "[CombatBO] section box")
	for index = 1, #boxs do
		local sectionId = boxs[index].sectionId
		local box = boxs[index].box

		CombatMO.sectionBoxs_[sectionId] = {}
		CombatMO.sectionBoxs_[sectionId].box = {}

		-- 第一个宝箱是否领取
		if box % 2 == 1 then CombatMO.sectionBoxs_[sectionId].box[1] = true end
		-- 第二个宝箱是否领取
		if box == 2 or box == 3 or box == 6 or box == 7 then CombatMO.sectionBoxs_[sectionId].box[2] = true end
		-- 第三个宝箱是否领取
		if box == 4 or box == 5 or box == 6 or box == 7 then CombatMO.sectionBoxs_[sectionId].box[3] = true end
	end

	gdump(CombatMO.sectionBoxs_, "CombatBO sectionBox")

	CombatMO.extremeWipeTime_ = 0
	if table.isexist(data, "wipeTime") then  -- 扫荡有倒计时
		local index = CombatMO.getExtremeProgressIndex(CombatMO.exploreExtremeHighest_)
		local leftTime = index * EXPLORE_EXTREME_WIPE_TIME + data.wipeTime - ManagerTimer.getTime() + 0.99
		CombatMO.extremeWipeTime_ = leftTime
		-- gprint("wipe left time:", CombatMO.extremeWipeTime_, "index:", index)
	end
	-- CombatMO.extremeWipeTime_ = 40
end

-- -- 获得副本中，当前可以挑战的最新的章节
-- function CombatBO.getCanFightSectionId()
-- 	if CombatMO.currentCombatId_ == 0 then
-- 		return 1
-- 	end

-- 	local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
-- 	if not combatDB then
-- 		gprint("[CombatBO] getCanFightSectionId combat db is nil Error!!! cur combatId:", CombatMO.currentCombatId_)
-- 	end
-- 	if combatDB.nxtCombatId == 0 then -- 已经是最后一关了
-- 		return combatDB.sectionId
-- 	else
-- 		local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)
-- 		return nxtCombatDB.sectionId
-- 	end
-- end

function CombatBO.isSectionCanFight(sectionId)
	if CombatMO.currentCombatId_ == 0 then
		if sectionId == 101 then return true
		else return false end
	end

	local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
	if combatDB.sectionId >= sectionId then
		return true
	else
		if combatDB.nxtCombatId == 0 then -- 已经是最后一关
			return false
		else
			local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)
			if nxtCombatDB.sectionId == sectionId then  -- 章节刚好就是下一个可以打的关卡的章节
				return true
			else
				return false
			end
		end
	end
end

function CombatBO.isSectionPass(combatType, sectionId)
	if combatType == COMBAT_TYPE_COMBAT then
		if CombatMO.currentCombatId_ == 0 then return false end

		local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
		local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)

		if not nxtCombatDB then return true
		elseif sectionId < nxtCombatDB.sectionId then return true
		else return false end
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local curExploreId = CombatMO.getCurrentExploreIdBySectionId(sectionId)

		if curExploreId == 0 then return false end

		local exploreDB = CombatMO.queryExploreById(curExploreId)
		if exploreDB.nxtCombatId == 0 then return true  -- 就是最后一关了
		else return false end
	end
end

-- 获得章节sectionId可以打的最大的关卡
function CombatBO.getSectionCanFightMaxCombatId(combatType, sectionId)
	if combatType == COMBAT_TYPE_COMBAT then
		if CombatMO.currentCombatId_ == 0 then
			local firsetCombatDB = CombatMO.queryCombatById(COMBAT_FIRST_ID)
			if firsetCombatDB.sectionId == sectionId then return firsetCombatDB.combatId
			else return 0 end
		end

		local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
		if combatDB.sectionId == sectionId then
			local nxtCombatId = combatDB.nxtCombatId
			if nxtCombatId == 0 then -- 最后一关了
				gprint("[CombatBO] getSectionCanFightMaxCombatId AA")
				return CombatMO.currentCombatId_
			else
				local nxtCombatDB = CombatMO.queryCombatById(nxtCombatId)
				if nxtCombatDB.sectionId ~= sectionId then  -- 下一关是下一章了，表示这一章已经打完了
					gprint("[CombatBO] getSectionCanFightMaxCombatId BB")
					return CombatMO.currentCombatId_
				else
					gprint("[CombatBO] getSectionCanFightMaxCombatId CC")
					return nxtCombatDB.combatId
				end
			end
		elseif combatDB.sectionId > sectionId then  -- 章节都打完了，返回章节的最后一关
			local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
			return combatIds[#combatIds]
		elseif combatDB.sectionId + 1 == sectionId then  -- 刚好是下一章
			local nxtCombatId = combatDB.nxtCombatId
			if nxtCombatId == 0 then -- 最后一关了，下一章没有关卡
				return 0
			else
				local nxtCombatDB = CombatMO.queryCombatById(nxtCombatId)
				if nxtCombatDB.sectionId == sectionId then -- 章节刚好打完，在打下一章了
					return nxtCombatDB.combatId
				else  -- 下一章还不能打
					return 0
				end
			end
		else
			return 0
		end
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local type = CombatMO.getExploreTypeBySectionId(sectionId)
		if CombatMO.currentExplore_[type] == 0 then
			local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
			local exploreDB = CombatMO.queryExploreById(combatIds[1])
			return exploreDB.exploreId
		end

		local exploreDB = CombatMO.queryExploreById(CombatMO.currentExplore_[type])
		if exploreDB.nxtCombatId == 0 then -- 当前章节的最后一关
			return CombatMO.currentExplore_[type]
		else
			return exploreDB.nxtCombatId
		end
	end
end

-- 获得某章节下所有的星数量
function CombatBO.getSectionCombatStar(combatType, sectionId)
	if combatType == COMBAT_TYPE_COMBAT then
		local combats = CombatMO.sections_[sectionId]
		if not combats then return 0 end

		local count = 0
		for index = 1, #combats do
			local combat = CombatMO.getCombatById(combats[index])
			count = count + combat.star
		end

		return count
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local combats = CombatMO.exploreSections_[sectionId]
		if not combats then return 0 end

		local count = 0
		for index = 1, #combats do
			local combat = CombatMO.getExploreById(combats[index])
			count = count + combat.star
		end
		return count
	end
end

function CombatBO.addSectionCombat(sectionId, combatId)
	if not CombatMO.sections_[sectionId] then CombatMO.sections_[sectionId] = {} end

	for index = 1, #CombatMO.sections_[sectionId] do
		if combatId == CombatMO.sections_[sectionId][index] then
			return false
		end
	end

	CombatMO.sections_[sectionId][#CombatMO.sections_[sectionId] + 1] = combatId
end

function CombatBO.addExploreSectionCombat(sectionId, combatId)
	if not CombatMO.exploreSections_[sectionId] then CombatMO.exploreSections_[sectionId] = {} end

	for index = 1, #CombatMO.exploreSections_[sectionId] do
		if combatId == CombatMO.exploreSections_[sectionId][index] then
			return false
		end
	end

	CombatMO.exploreSections_[sectionId][#CombatMO.exploreSections_[sectionId] + 1] = combatId
end

function CombatBO.getSectionBoxData(combatType, sectionId)
	local boxNeedStar = nil -- 开启每个宝箱需要的星星的数量，table的长度表示有宝箱的个数
	local starTotal = 0
	local starOwnNum = CombatBO.getSectionCombatStar(combatType, sectionId)  -- 当前获得多少个小星星

	if combatType == COMBAT_TYPE_COMBAT then
		local combats = CombatMO.getCombatIdsBySectionId(sectionId)  -- 有多少个关卡

		if sectionId == 101 then  -- 普通副本的第一章只有一个宝箱
			boxNeedStar = {#combats * 3}
		else
			boxNeedStar = {12, 24, #combats * 3}
		end

		starTotal = #combats * 3
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)
		if exploreType == EXPLORE_TYPE_EXTREME or exploreType == EXPLORE_TYPE_LIMIT then  -- 没有宝箱
			return nil
		end

		local combats = CombatMO.getCombatIdsBySectionId(sectionId)

		boxNeedStar = {12, 24, #combats * 3}

		starTotal = #combats * 3
	end
	return {boxNeedStar = boxNeedStar, starOwnNum = starOwnNum, starTotal = starTotal}
end

function CombatBO.hasSectionBoxOpen(sectionId, boxIndex)
	local sectionBox = CombatMO.sectionBoxs_[sectionId]
	if not sectionBox then return false end

	if sectionBox.box[boxIndex] then return true
	else return false end
end

function CombatBO.canOpenSectionBox(combatType, sectionId, boxIndex)
	if CombatBO.hasSectionBoxOpen(sectionId, boxIndex) then return false end

	local combatIds = CombatMO.getCombatIdsBySectionId(sectionId)
	local star = CombatBO.getSectionCombatStar(combatType, sectionId)

	if sectionId == 101 then  -- 第一章只有一个宝箱
		if star == (#combatIds * 3) and boxIndex == 1 then
			return true
		else
			return false
		end
	else
		if boxIndex == 1 then
			if star >= 12 then return true
			else return false end
		elseif boxIndex == 2 then
			if star >= 24 then return true
			else return false end
		elseif boxIndex == 3 then
			if star >= (#combatIds * 3) then return true
			else return false end
		end
	end
end

-- combatId的关卡是否可以挑战
function CombatBO.canFightCombat(combatId)
	if CombatMO.currentCombatId_ == 0 then
		if combatId == COMBAT_FIRST_ID then return true
		else return false end
	end

	if combatId <= CombatMO.currentCombatId_ then
		return true
	else
		local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
		if combatId == combatDB.nxtCombatId then
			return true
		else
			return false
		end
	end
end

function CombatBO.parseSectionBox(sectionId, boxIndex)
	local sectionDB = CombatMO.querySectionById(sectionId)
	if not sectionDB then return end
	local box = sectionDB["box" .. boxIndex]
	if not box or box == "" then return end

	local boxs = json.decode(box)
	local ret = {}
	for index = 1, #boxs do
		ret[index] = {kind = boxs[index][1], id = boxs[index][2], count = boxs[index][3]}
	end
	return ret
end

-- 解析数据库中关卡的阵型
function CombatBO.parseCombatFormation(combatDB)
	local formation = {}

	local f = json.decode(combatDB.form)
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local data = f[index]
		if data[1] and data[1] > 0 and data[2] and data[2] > 0 then
			formation[index] = {tankId = data[1], count = data[2]}
		else
			formation[index] = {tankId = 0, count = 0}
		end
	end

	formation.commander = 0
	-- formation.commander = combatDB.hero
	return formation
end

function CombatBO.parseServerFormation(form)
	local formation = TankMO.getEmptyFormation()
	
	for key, value in pairs(form) do
		if key == "p1" then
			local pos = PbProtocol.decodeRecord(value)
			formation[1] = {tankId = pos.v1, count = pos.v2}
		elseif key == "p2" then
			local pos = PbProtocol.decodeRecord(value)
			formation[2] = {tankId = pos.v1, count = pos.v2}
		elseif key == "p3" then
			local pos = PbProtocol.decodeRecord(value)
			formation[3] = {tankId = pos.v1, count = pos.v2}
		elseif key == "p4" then
			local pos = PbProtocol.decodeRecord(value)
			formation[4] = {tankId = pos.v1, count = pos.v2}
		elseif key == "p5" then
			local pos = PbProtocol.decodeRecord(value)
			formation[5] = {tankId = pos.v1, count = pos.v2}
		elseif key == "p6" then
			local pos = PbProtocol.decodeRecord(value)
			formation[6] = {tankId = pos.v1, count = pos.v2}
		end
	end

	if table.isexist(form, "commander") then
		formation.commander = form["commander"]
	end
	if table.isexist(form, "awakenHero") then
		local awakenHero = PbProtocol.decodeRecord(form["awakenHero"])
		awakenHero.skillLv = PbProtocol.decodeArray(form["awakenHero"]["skillLv"])
		formation.awakenHero = awakenHero

		-- formation.commander = formation.awakenHero.heroId
	end
	if table.isexist(form, "formName") then
		formation.formName = form["formName"]
	end

	if table.isexist(form, "tacticsKeyId") then
		formation.tacticsKeyId = form.tacticsKeyId
	end

	if table.isexist(form, "tactics") then
		formation.tactics = form.tactics
	end

	return formation, form["type"]
end

-- 战报解析秘密武器
function CombatBO.parseWarWeaponFormation(weapon)
	local ret = 0
	if not weapon then return ret end
	local weaponIds = weapon["weaponId"] -- PbProtocol.decodeArray(weapon["weaponId"])
	for index = 1, #weaponIds do
		if weaponIds[index] > ret then
			ret = weaponIds[index]
		end
	end
	return ret
end

-- 战报解析战斗特效
function CombatBO.parseWarFighterEffect(effect)
	if not effect then return nil end
	local ret = effect["eid"]
	return ret 
end

-- 将阵型解析为服务器格式
function CombatBO.encodeFormation(formation)
	local format = {}
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local value = formation[index]
		if value.tankId > 0 and value.count > 0 then
			format["p" .. index] = {v1 = value.tankId, v2 = value.count}
		else
			format["p" .. index] = {v1 = 0, v2 = 0}
		end
	end
	
	if formation.commander and formation.commander > 0 then
		format.commander = formation.commander
		if formation.awakenHero and formation.awakenHero.keyId > 0 then --如果是觉醒将，awakenHero对象里只传keyId
			local awakeHero = {}
			awakeHero.keyId = formation.awakenHero.keyId
			if table.isexist(formation.awakenHero,"skillLv") then
				awakeHero.skillLv = PbProtocol.decodeArray(formation.awakenHero.skillLv) -- 
			end
			format.awakenHero = awakeHero
		end
	end

	if formation.tacticsKeyId and #formation.tacticsKeyId > 0 then  --战术
		format.tacticsKeyId = formation.tacticsKeyId
	end

	return format
end

function CombatBO.codeGuideRecord()
	local record = {}
	record.keyId = 0
	record.offsensive = BATTLE_OFFENSIVE_ATTACK
	record.atkFormat = TankMO.getEmptyFormation()
	record.atkFormat[1] = {tankId = 25, count = 99}
	record.atkFormat[2] = {tankId = 22, count = 99}
	record.atkFormat[3] = {tankId = 23, count = 99}
	record.atkFormat[4] = {tankId = 16, count = 99}
	record.atkFormat[5] = {tankId = 20, count = 99}
	record.atkFormat[6] = {tankId = 24, count = 99}
	record.atkFormat.commander = 293

	record.defFormat = TankMO.getEmptyFormation()
	record.defFormat[1] = {tankId = 15, count = 99}
	record.defFormat[2] = {tankId = 14, count = 99}
	record.defFormat[3] = {tankId = 13, count = 99}
	record.defFormat[4] = {tankId = 20, count = 99}
	record.defFormat[5] = {tankId = 21, count = 99}
	record.defFormat[6] = {tankId = 20, count = 99}
	record.defFormat.commander = 284

	record.hp = {623700, 247500, 544500, 170775, 737550, 297000, 256410, 395010, 395010, 1188000, 693000, 395010}

	--crit 暴击 impale 穿刺 dodge 闪避
	record.round = {
		{
			key = 1, 
			action = {
				{target=2, count=79, hurt={50000}, crit=false, impale=false, dodge=false},
				{target=4, count=79, hurt={34500}, crit=false, impale=false, dodge=false},
				{target=6, count=79, hurt={60000}, crit=false, impale=false, dodge=false},
			}

		},
		{
			key = 2, 
			action = {
				{target=1, count=69, hurt={189000}, crit=true, impale=false, dodge=false},
				{target=7, count=69, hurt={77700}, crit=true, impale=false, dodge=false}
			}

		},
		{
			key = 3, 
			action = {
				{target=4, count=49, hurt={10350,10350,10350,10350,10350}, crit=false, impale=false, dodge=false}
			}

		},
		{
			key = 4, 
			action = {
				{target=3, count=84, hurt={16500,16500,16500,16500,16500}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 5, 
			action = {
				{target=6, count=69, hurt={30000}, crit=false, impale=false, dodge=false},
				{target=12, count=89, hurt={39900}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 6, 
			action = {
				{target=1, count=59, hurt={63000}, crit=false, impale=false, dodge=false},
				{target=3, count=74, hurt={55000}, crit=false, impale=false, dodge=false},
				{target=5, count=89, hurt={74500}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 7, 
			action = {
				{target=2, count=69, hurt={25000}, crit=false, impale=false, dodge=false},
				{target=4, count=39, hurt={17250}, crit=false, impale=false, dodge=false},
				{target=6, count=59, hurt={30000}, crit=false, impale=false, dodge=false},
				{target=8, count=89, hurt={39900}, crit=false, impale=false, dodge=false},
				{target=10, count=89, hurt={120000}, crit=false, impale=false, dodge=false},
				{target=12, count=79, hurt={39900}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 8, 
			action = {
				{target=1, count=49, hurt={63000}, crit=false, impale=false, dodge=false},
				{target=3, count=64, hurt={55000}, crit=false, impale=false, dodge=false},
				{target=5, count=79, hurt={74500}, crit=false, impale=false, dodge=false},
				{target=7, count=59, hurt={25900}, crit=false, impale=false, dodge=false},
				{target=9, count=89, hurt={39900}, crit=false, impale=false, dodge=false},
				{target=11, count=89, hurt={70000}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 9, 
			action = {
				{target=2, count=69, hurt={}, crit=false, impale=false, dodge=true},
				{target=4, count=39, hurt={}, crit=false, impale=false, dodge=true},
				{target=6, count=59, hurt={}, crit=false, impale=false, dodge=true},
				{target=8, count=89, hurt={}, crit=false, impale=false, dodge=true},
				{target=10, count=89, hurt={}, crit=false, impale=false, dodge=true},
				{target=12, count=79, hurt={}, crit=false, impale=false, dodge=true}
			}
		},
		{
			key = 10, 
			action = {
				{target=1, count=39, hurt={63000}, crit=false, impale=false, dodge=false},
				{target=3, count=54, hurt={55000}, crit=false, impale=false, dodge=false},
				{target=5, count=69, hurt={74500}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 11, 
			action = {
				{target=2, count=49, hurt={50000}, crit=false, impale=false, dodge=false},
				{target=4, count=19, hurt={34500}, crit=false, impale=false, dodge=false},
				{target=6, count=39, hurt={60000}, crit=false, impale=false, dodge=false},
				{target=8, count=69, hurt={79800}, crit=false, impale=false, dodge=false},
				{target=10, count=69, hurt={240000}, crit=false, impale=false, dodge=false},
				{target=12, count=59, hurt={79800}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 12, 
			action = {
				{target=1, count=39, hurt={}, crit=false, impale=false, dodge=true},
				{target=3, count=54, hurt={}, crit=false, impale=false, dodge=true},
				{target=5, count=69, hurt={}, crit=false, impale=false, dodge=true},
				{target=7, count=59, hurt={}, crit=false, impale=false, dodge=true},
				{target=9, count=89, hurt={}, crit=false, impale=false, dodge=true},
				{target=11, count=89, hurt={}, crit=false, impale=false, dodge=true}
			}
		},
		{
			key = 1, 
			action = {
				{target=2, count=30, hurt={47500}, crit=false, impale=false, dodge=false},
				{target=4, count=0, hurt={32775}, crit=false, impale=false, dodge=false},
				{target=6, count=20, hurt={57000}, crit=false, impale=false, dodge=false}
			}

		},
		{
			key = 2, 
			action = {
				{target=1, count=20, hurt={119700}, crit=false, impale=false, dodge=false},
				{target=7, count=40, hurt={49210}, crit=false, impale=false, dodge=false}
			}

		},
		{
			key = 3, 
			action = {
				{target=10, count=0, hurt={165600,165600,165600,165600,165600}, crit=true, impale=false, dodge=false}
			}

		},
		{
			key = 6, 
			action = {
				{target=1, count=10, hurt={126000}, crit=false, impale=false, dodge=false},
				{target=3, count=44, hurt={110000}, crit=false, impale=false, dodge=false},
				{target=5, count=59, hurt={149000}, crit=false, impale=false, dodge=false}
			}
		},

		{
			key = 5, 
			action = {
				{target=6, count=0, hurt={60000}, crit=true, impale=false, dodge=false},
				{target=12, count=0, hurt={235410}, crit=true, impale=false, dodge=false}
			}
		},

		{
			key = 8, 
			action = {
				{target=3, count=24, hurt={110000}, crit=false, impale=false, dodge=false},
				{target=5, count=39, hurt={149000}, crit=false, impale=false, dodge=false},
				{target=7, count=20, hurt={51800}, crit=false, impale=false, dodge=false},
				{target=9, count=69, hurt={79800}, crit=false, impale=false, dodge=false},
				{target=11, count=69, hurt={140000}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 7, 
			action = {
				{target=2, count=25, hurt={5}, crit=false, impale=false, dodge=false},
				{target=8, count=64, hurt={5}, crit=false, impale=false, dodge=false}
			}
		},
		{
			key = 9, 
			action = {
				{target=2, count=0, hurt={12500}, crit=false, impale=true, dodge=false},
				{target=8, count=39, hurt={19950}, crit=false, impale=true, dodge=false}
			}
		},
		{
			key = 11, 
			action = {
				{target=8, count=0, hurt={155610}, crit=false, impale=true, dodge=false}
			}
		}
	}

		-- 	if rounds then
		-- 	for roundIndex = 1, #rounds do
		-- 		local round = rounds[roundIndex]

		-- 		ret.round[roundIndex] = {}
		-- 		ret.round[roundIndex].key = round.key
		-- 		ret.round[roundIndex].action = {}

		-- 		local actions = PbProtocol.decodeArray(round["action"])
		-- 		-- gdump(actions, "action")
		-- 		if actions then
		-- 			for actionIndex = 1, #actions do
		-- 				local action = actions[actionIndex]

		-- 				ret.round[roundIndex].action[actionIndex] = {}
		-- 				ret.round[roundIndex].action[actionIndex].target = action.target
		-- 				ret.round[roundIndex].action[actionIndex].count = action.count
		-- 				ret.round[roundIndex].action[actionIndex].hurt = action.hurt
		-- 				ret.round[roundIndex].action[actionIndex].crit = action.crit
		-- 				ret.round[roundIndex].action[actionIndex].impale = action.impale
		-- 				ret.round[roundIndex].action[actionIndex].dodge = action.dodge
		-- 			end
		-- 		end
		-- 	end
		-- end
	return record
end

-- atkFormat:备份的进攻方阵型。如果record中没有formA字段，则使用atkFormat作为进攻方阵型; 如果有，则优先formA字段阵型
-- defFormat:同atkFormat
function CombatBO.parseCombatRecord(record, atkFormat, defFormat)
	if not record then return {} end
	BattleMO.record_ = nil
	local function parse(record, atkFormat, defFormat)
		local ret = {}
		if not record then return ret end

		gdump(record, "CombatBO.parseCombatRecord parse origin record")
		local record = PbProtocol.decodeRecord(record)
		gdump(record, "CombatBO.parseCombatRecord parse record")

		if not record then return ret end

		-- ret.hp = record.hp
		ret.keyId = record.keyId

		if record.first then 
			ret.offsensive = BATTLE_OFFENSIVE_ATTACK
		else 
			ret.offsensive = BATTLE_OFFENSIVE_DEFEND 
		end

		if table.isexist(record, "formA") then
			local form = PbProtocol.decodeRecord(record["formA"])
			ret.atkFormat = CombatBO.parseServerFormation(form)
		else
			ret.atkFormat = clone(atkFormat)
		end

		if table.isexist(record, "formB") then
			local form = PbProtocol.decodeRecord(record["formB"])
			ret.defFormat = CombatBO.parseServerFormation(form)
		else
			ret.defFormat = clone(defFormat)
		end
		local hpIndex = 1
		ret.hp = {}

		-- -- 根据key值，建立key和双方阵型的位置的对应关系
		-- if ret.offsensive == BATTLE_OFFENSIVE_ATTACK then -- 进攻方先手
		-- 	local keyAtkIndex = 1
		-- 	local keyDefIndex = 2
		gdump(record.hp, "@^^^^^^^^^^^^^^^^^", 9)
		local hp = {}
		for i,v in ipairs(record.hp) do
			if v > 0 then
				table.insert(hp,v)
			end
		end
		for index = 1, FIGHT_FORMATION_POS_NUM * 2 do
			local battleFor, pos = CombatMO.getBattlePosition(ret.offsensive, index)
			if battleFor == BATTLE_FOR_ATTACK then
				local format = ret.atkFormat[pos]
				if format and format.tankId > 0 and format.count > 0 then
					ret.hp[index] = hp[hpIndex] or 0
					hpIndex = hpIndex + 1
				else
					ret.hp[index] = 0
				end
			elseif battleFor == BATTLE_FOR_DEFEND then
				local format = ret.defFormat[pos]
				if format and format.tankId > 0 and format.count > 0 then
					ret.hp[index] = hp[hpIndex] or 0
					hpIndex = hpIndex + 1
				else
					ret.hp[index] = 0
				end
			end
		end
		ret.round = {}
		if record["round"] then
			local rounds = PbProtocol.decodeArray(record["round"])
			-- gdump(rounds, "round")
			if rounds then
				for roundIndex = 1, #rounds do
					local round = rounds[roundIndex]

					ret.round[roundIndex] = {}
					ret.round[roundIndex].key = round.key
					ret.round[roundIndex].action = {}

					local actions = PbProtocol.decodeArray(round["action"])
					-- gdump(actions, "action")
					if actions then
						for actionIndex = 1, #actions do
							local action = actions[actionIndex]

							ret.round[roundIndex].action[actionIndex] = {}
							ret.round[roundIndex].action[actionIndex].target = action.target
							ret.round[roundIndex].action[actionIndex].count = action.count
							ret.round[roundIndex].action[actionIndex].hurt = action.hurt
							ret.round[roundIndex].action[actionIndex].crit = action.crit
							ret.round[roundIndex].action[actionIndex].impale = action.impale
							ret.round[roundIndex].action[actionIndex].dodge = action.dodge
							ret.round[roundIndex].action[actionIndex].frighten = action.frighten
							ret.round[roundIndex].action[actionIndex].forceCount = action.forceCount
							ret.round[roundIndex].action[actionIndex].force = action.force
						end
					end
				end
			end
		end
		--复活信息
		ret.reborn = {}
		if table.isexist(record,"reborn") then
			local info = PbProtocol.decodeArray(record["reborn"])
			for k,v in ipairs(info) do
				-- local reborn = {}
				-- reborn.pos = PbProtocol.decodeArray(v.pos)
				-- reborn.tankId = PbProtocol.decodeArray(v.tankId)
				-- reborn.count = PbProtocol.decodeArray(v.count)
				-- reborn.hp = PbProtocol.decodeArray(v.hp)
				ret.reborn[v.round] = v
			end
		end
		--技能效果信息
		ret.addSkillEffect = {}
		if table.isexist(record, "addSkillEffect") then
			for k,v in ipairs(PbProtocol.decodeArray(record["addSkillEffect"])) do
				if not ret.addSkillEffect[v.round] then
					ret.addSkillEffect[v.round] = {}
				end
				table.insert(ret.addSkillEffect[v.round],v)
			end
		end

		-- 被动技能效果信息
		ret.passiveSkillEffect = {}
		if table.isexist(record, "passiveSkillEffect") then
			for k, v in ipairs(PbProtocol.decodeArray(record["passiveSkillEffect"])) do
				if not ret.passiveSkillEffect[v.round] then
					ret.passiveSkillEffect[v.round] = {}
				end
				table.insert(ret.passiveSkillEffect[v.round], v)
			end
		end

		gdump(ret, "[CombatBO] parseCombatRecord record!!!!")

		-- 秘密武器
		ret.weapon = {}
		ret.fighterEffect = {}
		if table.isexist(record, "formExtA") then
			local wfA = PbProtocol.decodeRecord(record["formExtA"])
			ret.weapon.atkWeaponId = CombatBO.parseWarWeaponFormation(wfA)
			ret.fighterEffect.atkFighterEffect = CombatBO.parseWarFighterEffect(wfA)
		end
		if table.isexist(record, "formExtB") then
			local wfB = PbProtocol.decodeRecord(record["formExtB"])
			ret.weapon.defWeaponId = CombatBO.parseWarWeaponFormation(wfB)
			ret.fighterEffect.defFighterEffect = CombatBO.parseWarFighterEffect(wfB)
		end
				
		return ret
	end

	if type(record[1]) == "table" then --飞艇车轮战 or 赏金猎人战斗
		local data = nil
		BattleMO.record_ = {} --保存后续数据
		for k,v in ipairs(record) do
			gdump(v, "CombatBO.parseCombatRecord v==")
			local temp = parse(v, atkFormat, defFormat)
			if k == 1 then
				data = temp
			else
				table.insert(BattleMO.record_, temp)
			end

			-- if device.platform == "windows" then
			if GAME_PRINT_ENABLE and device.platform == "windows" then
				local writeStr = serialize(temp)
				writefile("record_" .. k .. ".lua", writeStr)
			end
		end
		gdump(data, "CombatBO.parseCombatRecord data==")
		return data
	else
		return parse(record, atkFormat, defFormat)
	end
end

-- 根据combat的数据，解析关卡可掉落物品
function CombatBO.parseShowDrop(combatDB)
	local drops = json.decode(combatDB.drop)
	-- gdump(drops, "[CombatBO] parse drop")
	local ret = {}
	for index = 1, #drops do
		ret[index] = {kind = drops[index][1], id = drops[index][2]}
	end
	return ret
end

-- 解析游戏中需要的统计数据
-- haust:战损，如果为空，则根据record数据计算
-- 返回战损
function CombatBO.parseBattleStastics(atkFormat, defFormat, battleRecord, haust)
	CombatMO.curBattleStatistics_ = {[BATTLE_FOR_ATTACK] = {}, [BATTLE_FOR_DEFEND] = {}}
	CombatMO.curBattleStatistics_[BATTLE_FOR_ATTACK] = {tankCount = 0, roundCount = 0, actionCount = 0, impaleCount = 0, dodgeCount = 0, critCount = 0}
	CombatMO.curBattleStatistics_[BATTLE_FOR_DEFEND] = {tankCount = 0, roundCount = 0, actionCount = 0, impaleCount = 0, dodgeCount = 0, critCount = 0}
		
	-- 获得阵型中的坦克总数
	local tankStat = TankBO.stasticsFormation(atkFormat)
	CombatMO.curBattleStatistics_[BATTLE_FOR_ATTACK].tankCount = tankStat.amount
	local tankStat = TankBO.stasticsFormation(defFormat)
	CombatMO.curBattleStatistics_[BATTLE_FOR_DEFEND].tankCount = tankStat.amount

	-- 保存战斗结束后的双方阵型数据
	local leftFormats = {[BATTLE_FOR_ATTACK] = clone(atkFormat), [BATTLE_FOR_DEFEND] = clone(defFormat)}

	for roundIndex = 1, #battleRecord.round do
		local round = battleRecord.round[roundIndex]
		local battleFor, pos = CombatMO.getBattlePosition(CombatMO.curBattleOffensive_, round.key)
		CombatMO.curBattleStatistics_[battleFor].roundCount = CombatMO.curBattleStatistics_[battleFor].roundCount + 1
		CombatMO.curBattleStatistics_[battleFor].actionCount = CombatMO.curBattleStatistics_[battleFor].actionCount + #round.action

		for actionIndex = 1, #round.action do
			local action = round.action[actionIndex]
			-- gdump(action, "CombatBO.parseBattleStastics")
			
			if action.impale then CombatMO.curBattleStatistics_[battleFor].impaleCount = CombatMO.curBattleStatistics_[battleFor].impaleCount + 1 end -- 穿刺
			if action.dodge then CombatMO.curBattleStatistics_[battleFor].dodgeCount = CombatMO.curBattleStatistics_[battleFor].dodgeCount + 1 end -- 闪避
			if action.crit then CombatMO.curBattleStatistics_[battleFor].critCount = CombatMO.curBattleStatistics_[battleFor].critCount + 1 end -- 暴击

			if not action.dodge then  -- 如果发生了闪避，则不会有伤害
				-- 剩余tank的数量
				local rivalBattleFor, rivalPos = CombatMO.getBattlePosition(CombatMO.curBattleOffensive_, action.target)
				leftFormats[rivalBattleFor][rivalPos].count = action.count
			end
		end
	end

	local tankStat = TankBO.stasticsFormation(leftFormats[BATTLE_FOR_ATTACK])
	CombatMO.curBattleStatistics_[BATTLE_FOR_ATTACK].leftTankCount = tankStat.amount
	local tankStat = TankBO.stasticsFormation(leftFormats[BATTLE_FOR_DEFEND])
	CombatMO.curBattleStatistics_[BATTLE_FOR_DEFEND].leftTankCount = tankStat.amount
	gdump(CombatMO.curBattleStatistics_, "[CombatBO] parseBattleStastics 111")

	if haust then return haust end

	local atkLost = {}  -- 攻击累计损失的tank数量
	for index = 1, FIGHT_FORMATION_POS_NUM do
		local atkF = atkFormat[index]
		local leftAtkF = leftFormats[BATTLE_FOR_ATTACK][index]
		if atkF.tankId > 0 then
			if not atkLost[atkF.tankId] then atkLost[atkF.tankId] = 0 end
			atkLost[atkF.tankId] = atkLost[atkF.tankId] + atkF.count - leftAtkF.count
		end
	end

	local haust = {}
	for tankId, count in pairs(atkLost) do
		haust[#haust + 1] = {tankId = tankId, count = count}
	end
	return haust
end
--
function CombatBO.parseWipeInfo(data)
	if data ~=nil then
		local info = PbProtocol.decodeArray(data)
		CombatMO.myWipeInfo_ = info
		gdump(info, "CombatBO.WipeInfo !!!!")
	end
end

function CombatBO.parseWipeReward(data)
	if data ~=nil then
		local reward = {}
		local stateawards = {}
		local expreward = {}
		expreward.awards = {}
		local rewardInfo = PbProtocol.decodeArray(data["rewardInfo"])
		for k,v in pairs(rewardInfo) do
			local tempReward = {}
			tempReward.exploreType = v.exploreType
			tempReward.exp = v.exp
			local mreward = PbProtocol.decodeArray(v["award"])
			for index=1,#mreward do
				stateawards[#stateawards + 1] = mreward[index]
			end

			tempReward.award = CombatBO.arrangeAwards(mreward)
			if v.exp >0 then
				local mexp = {kind = ITEM_KIND_EXP, count = v.exp,type = ITEM_KIND_EXP,id = ITEM_KIND_EXP}
				table.insert(tempReward.award,clone(mexp))
				table.insert(expreward.awards,clone(mexp))
				stateawards[#stateawards + 1] = clone(mexp)
			end
			table.insert(reward,tempReward)
		end
		local awards = CombatBO.addAwards(stateawards)
		-- local mexpreward =  CombatBO.arrangeAwards(clone(expreward.awards))
		-- if mexpreward and table.nums(mexpreward) > 0 then
		-- 	local level, exp, upgrade = UserMO.addUpgradeResouce(ITEM_KIND_EXP, mexpreward[1].count)
		-- 	if upgrade then awards.levelUp = true end
		-- end

		UiUtil.showAwards(awards)
		-- UiUtil.showAwards(expreward)

		UserMO.updateResource(ITEM_KIND_COIN, data.gold) -- 更新金币数量
		CombatMO.wipeReward.rewardInfo = reward	

		local exploreType = {EXPLORE_TYPE_PART,EXPLORE_TYPE_EQUIP,EXPLORE_TYPE_MEDAL,EXPLORE_TYPE_WAR,EXPLORE_TYPE_ENERGYSPAR,EXPLORE_TYPE_TACTIC}
		local combatChallenge = {data.partEplr,data.equipEplr,data.medalEplr,data.militaryEplr,data.energyStoneEplrId,data.tacticsReset}
		local combatBuy = {data.partBuy,data.equipBuy,data.medalBuy,data.militaryBuy,data.energyStoneBuy,data.tacticsBuy}

		for i=1,#exploreType do
			if CombatMO.combatChallenge_[exploreType[i]]~= nil then
				CombatMO.combatChallenge_[exploreType[i]].count = combatChallenge[i]
			end
			if CombatMO.combatBuy_[exploreType[i]] ~= nil then
				CombatMO.combatBuy_[exploreType[i]].count = combatBuy[i]
			end
		end
		
		Notify.notify(LOCAL_TANK_EVENT)
		Notify.notify(LOCAL_TANK_REPAIR_EVENT)
		Notify.notify(LOCAL_COMBAT_UPDATE_EVENT)
	end
end


function CombatBO.addAwards(awards, trigFightCheck, fightChangeCb)
	if trigFightCheck == nil then
		trigFightCheck = true
	end
	if not awards then return end
	local ret = {}
	ret.levelUp = false -- 是否提升等级
	ret.fameUp = false -- 声望是否等级提升
	ret.awards = {}

	awards = CombatBO.arrangeAwards(awards)

	-- if awards and #awards > 0 then
	-- 	for index = 1, #awards do
	-- 		awards[index].kind = awards[index].type
	-- 	end
	-- end
	local change = {}
	local haveHero = false
	local havePendant = false
	for index = 1, #awards do
		local award = awards[index]
		if award.type == ITEM_KIND_EXP then  -- 奖励exp
			local _, _, up = UserMO.addUpgradeResouce(award.type, award.count)
			ret.levelUp = up
			ret.awards[#ret.awards + 1] = award
		elseif award.type == ITEM_KIND_PROSPEROUS then
			local ok, res = UserMO.addCycleResource(award.type, award.count)
			if ok then ret.awards[#ret.awards + 1] = res end
		elseif award.type == ITEM_KIND_FAME then
			local _, _, up = UserMO.addUpgradeResouce(ITEM_KIND_FAME, award.count)
			ret.fameUp = up
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_FAME, count = award.count}
		elseif award.type == ITEM_KIND_EQUIP then
			local param = nil
			if table.isexist(award,"param") then
				param = award.param
			end
			local lv = 1
			local starLv = 0
			if param and param[1] then
				lv = param[1]
				starLv = param[2]
			end
			EquipMO.equip_[award.keyId] = {equipId = award.id, level = lv, exp = 0, keyId = award.keyId, formatPos = 0, starLv = starLv}
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_EQUIP, id = award.id, count = 1, keyId = award.keyId}
			change[9] = true
			--TK统计 装备获得
			TKGameBO.onEvnt(TKText.eventName[7], {equipId = award.id})
		elseif award.type == ITEM_KIND_PART then
			local param = nil
			if table.isexist(award,"param") then
				param = award.param
			end
			local lv1,lv2 = 0,0
			if param then
				lv1 = param[1]
				lv2 = param[2]
			end
			PartMO.part_[award.keyId] = {partId = award.id, upLevel = lv1 or 0, refitLevel = lv2 or 0, keyId = award.keyId, typePos = 0,
					smeltLv = 0,smeltExp = 0,saved = true,attr = {}}
			-- ret.awards[#ret.awards + 1] = PartMO.part_[award.keyId]
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_PART, id = award.id, count = 1, keyId = award.keyId}
			Notify.notify(LOCLA_PART_EVENT)
			--TK统计 配件获得
			TKGameBO.onEvnt(TKText.eventName[9], {partId = award.id})
		elseif award.type == ITEM_KIND_POWER then
			UserMO.addCycleResource(award.type, award.count, true)
			ret.awards[#ret.awards + 1] = award
		elseif award.type == ITEM_KIND_RED_PACKET then  -- 红包
			local propDB = PropMO.queryPropById(award.id)
			local effectValue = json.decode(propDB.effectValue)
			local coinCount = 0
			if effectValue and effectValue[1] and effectValue[1][1] then coinCount = effectValue[1][1] * award.count end

			local awd = {kind = ITEM_KIND_COIN, count = coinCount}
			UserMO.addResource(awd.kind, awd.count)
			ret.awards[#ret.awards + 1] = awd
		elseif award.type == ITEM_KIND_HERO or award.type == ITEM_KIND_AWAKE_HERO then
			haveHero = true
			ret.awards[#ret.awards + 1] = award
		elseif award.type == ITEM_KIND_MILITARY then
			local po = OrdnanceBO.queryPropById(award.id)
			if po then
				po.count = po.count + award.count
			else
				OrdnanceBO.addProp({id=award.id,count=award.count})
			end
			ret.awards[#ret.awards + 1] = award
		elseif award.type == ITEM_KIND_MEDAL_ICON then
			local param = nil
			if table.isexist(award,"param") then
				param = award.param
			end
			local lv1,lv2 = 0,0
			if param then
				lv1 = param[1]
				lv2 = param[2]
			end
			local medal = {
			    keyId = award.keyId,
			    medalId = award.id,
			    upLv = lv1,
				upExp = 0,
			    refitLv = lv2,
				pos = 0,
				locked = false
			}
			MedalBO.addMedal(medal)
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_MEDAL_ICON, id = award.id, count = 1}
		elseif award.type == ITEM_KIND_WEAPONRY_ICON then
			local param = nil
			if table.isexist(award,"param") then
				param = award.param
			end
			local skillLv = {}
			if param then
				local outdata = {}
				for index = 1 , #param do
					local out = {}
					local skillId = param[index]
					local data = WeaponryMO.queryChangeSkillById(skillId)
					out.key = skillId
					out.value = data.level
					outdata[#outdata + 1] = out
				end
				skillLv = PbProtocol.analogyTwoIntList(outdata)
			end

			local Weaponry = {
			    equip_id = award.id,
			    keyId = award.keyId,
				pos = 0,
				skillLv = skillLv
			}
			WeaponryBO.addMedal(Weaponry)
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_WEAPONRY_ICON, id = award.id, count = 1}
		elseif award.type == ITEM_KIND_WEAPONRY_PAPER then
			local Weaponry = {
			    propId = award.id,
			    count = award.count
			}
			WeaponryBO.addPaper(Weaponry)
			ret.awards[#ret.awards + 1] = {kind = award.type, id = award.id, count = award.count}
		elseif award.type == ITEM_KIND_CHAR then
			if not ActivityCenterBO.prop_ then
				ActivityCenterBO.prop_ = {}
			end
			if not ActivityCenterBO.prop_[award.id] then
				ActivityCenterBO.prop_[award.id] = {id=award.id,kind=award.type,count=award.count}
			else
				ActivityCenterBO.prop_[award.id].count = ActivityCenterBO.prop_[award.id].count + award.count
			end
			ret.awards[#ret.awards + 1] = award
		elseif award.type == ITEM_KIND_PORTRAIT then
			havePendant = true
		elseif award.type == ITEM_KIND_TACTIC then -- 战术
			local param = nil
			if table.isexist(award,"param") then
				param = award.param
			end
			local lv = 0
			local exp = 0
			if param and param[1] then
				lv = param[1]
				exp = param[2]
			end
			TacticsMO.tactics_[award.keyId] = {tacticsId = award.id, lv = lv, exp = 0, keyId = award.keyId, exp = exp, use = 0, state = 0}
			ret.awards[#ret.awards + 1] = {kind = ITEM_KIND_TACTIC, id = award.id, count = 1, keyId = award.keyId}
			--TK统计 装备获得
			TKGameBO.onEvnt(TKText.eventName[7], {tacticsId = award.id})
		else
			if award.type == ITEM_KIND_TANK then
				change[3] = true
			end
			UserMO.addResource(award.type, award.count, award.id)
			ret.awards[#ret.awards + 1] = award
		end
	end
	if haveHero then
		HeroBO.updateMyHeros()
	end
	if havePendant then
		PendantBO.asynGetPendant()
	end

	if trigFightCheck and change[3] then UserBO.triggerFightCheck() end

	if fightChangeCb then
		fightChangeCb(change[3])
	end

	-- 装备
	if change[9] then Notify.notify(LOCAL_EQUIP_EVENT) end
	return ret
end

-- 将奖励awards中的
function CombatBO.arrangeAwards(awards)
	local ret = {}
	local function add(award)
		if award.id and award.id == 0 then award.id = nil end

		if award.kind == ITEM_KIND_EQUIP or award.kind == ITEM_KIND_PART or award.kind == ITEM_KIND_MEDAL_ICON or  award.kind == ITEM_KIND_WEAPONRY_ICON
		or award.kind == ITEM_KIND_TACTIC then  -- 不累计个数
			ret[#ret + 1] = award
		else
			for index = 1, #ret do
				local r = ret[index]
				if r.kind == award.kind then
					if r.id and award.id then
						if r.id == award.id then  -- 找到了
							r.count = r.count + award.count
							return
						end
					elseif not r.id and not award.id then  -- 找到了
						r.count = award.count
						return
					end
				end
			end
			ret[#ret + 1] = award
		end
	end

	for index = 1, #awards do
		local award = awards[index]
		if not table.isexist(award, "kind") then award.kind = award.type end

		add(award)
	end
	return ret
end

-- 以star的星通过了关卡combatId
function CombatBO.passCombat(combatType, combatId, star)
	if star <= 0 then return false, 0 end

	if combatType == COMBAT_TYPE_COMBAT then
		if combatId <= CombatMO.currentCombatId_ then -- 关卡已经打过了再打
			local combat = CombatMO.getCombatById(combatId)
			if not combat then
				error("[CombatBO] pass combat Error no combat data!!!")
			else
				if combat.star < star then  -- 更新星级
					combat.star = star
					return true, 1
				else
					return false, 0
				end
			end
		else
			local combatDB = CombatMO.queryCombatById(combatId)
			if combatDB.prevCombatId == CombatMO.currentCombatId_ then -- 刚好是下一关被打了
				CombatMO.combats_[combatId] = {combatId = combatId, star = star}
				CombatBO.addSectionCombat(combatDB.sectionId, combatId)

				CombatMO.currentCombatId_ = combatId  -- 更新当前关卡的进度
				
				local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)
				if not nxtCombatDB then
					return false,0
				end
				if nxtCombatDB.sectionId ~= combatDB.sectionId then -- 开启新的章节的新一关
					if combatDB.sectionId == 101 then
						return true, 4
					else
						return true, 3
					end
				else
					return true, 2 -- 开启本章新的关卡
				end
			else
				error("[CombatBO] pass combat Error wrong id")
			end
		end
	elseif combatType == COMBAT_TYPE_EXPLORE then
		local combatDB = CombatMO.queryExploreById(combatId)
		local currentId = CombatMO.currentExplore_[combatDB.type]

		if combatId <= currentId then -- 关卡已经打过了再打
			local combat = CombatMO.getExploreById(combatId)
			if not combat then
				error("[CombatBO] pass explore Error !!!")
			else
				if combat.star < star then -- 更新星级
					combat.star = star
					return true, 1
				else
					return false, 0
				end
			end
		else
			if combatDB.prevCombatId == currentId then -- 刚好是下一关被打了
				CombatMO.explores_[combatId] = {combatId = combatId, star = star}
				local sectionId = CombatMO.getExploreSectionIdByType(combatDB.type)

				CombatBO.addExploreSectionCombat(sectionId, combatId)

				CombatMO.currentExplore_[combatDB.type] = combatId

				----任务计数
				--TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_EXPLORE,type = combatDB.type})

				return true, 2 -- 探险副本没有下一章
			else
				gprint("combatId:", combatId)
				error("[CombatBO] pass explore ERROR!!! Wrong ID")
			end
		end
	end
end

-- 探险副本剩余挑战次数
function CombatBO.getExploreChallengeLeftCount(exploreType)
	if exploreType == EXPLORE_TYPE_EXTREME then
		return EXPLORE_EXTREME_FIGHT_TIME - CombatMO.combatChallenge_[exploreType].count
	else
		local left = (CombatMO.combatBuy_[exploreType].count + 1) * EXPLORE_FIGHT_TIME - CombatMO.combatChallenge_[exploreType].count

		if exploreType == EXPLORE_TYPE_EQUIP then
			if ActivityBO.isValid(ACTIVITY_ID_EQUIP) then  -- 额外增加5次
				left = left + 5
			end
		elseif exploreType == EXPLORE_TYPE_PART then
			if ActivityBO.isValid(ACTIVITY_ID_PART) then  -- 额外增加5次
				left = left + 5
			end
		elseif exploreType == EXPLORE_TYPE_WAR then
			if ActivityBO.isValid(ACTIVITY_ID_MILITARY) then
				left = left + 5
			end
		elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
			if ActivityBO.isValid(ACTIVITY_ID_ENERGY) then
				left = left + 5
			end
		elseif exploreType == EXPLORE_TYPE_MEDAL then
			if ActivityBO.isValid(ACTIVITY_ID_EXPLOR_MEDAL) then
				left = left + 5
			end
		elseif exploreType == EXPLORE_TYPE_TACTIC then
			if ActivityBO.isValid(ACTIVITY_ID_TACTICS_EXPLORE) then
				left = left + 5
			end
		end

		return left
	end
end

function CombatBO.isLimitExploreTimeOpen()
	local date = ManagerTimer.getDate()
	if date.wday == 3 or date.wday == 5 or date.wday == 7 then -- 周二、四、六
		-- if date.hour >= 18 and date.hour <= 24 then
			return true
		-- end
	end
	return false
end

function CombatBO.asynGetCombat(doneCallback)
	local function parseGetCombat(name, data)
		gdump(data, "CombatBO.asynGetCombat !!!!")
		CombatBO.update(data)
		
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseGetCombat, NetRequest.new("GetCombat"))
end

-- formation: 我方阵型
function CombatBO.asynDoCombat(doneCallback, combatType, combatId, formation)
	local typeValue = 0
	if combatType == COMBAT_TYPE_COMBAT then
		typeValue = 1
	elseif combatType == COMBAT_TYPE_EXPLORE then
		typeValue = math.floor(combatId / 100) + 1
	end

	local function parseDoCombat(name, data)
		gdump(data, "[CombatBO] doCombat")
		
		CombatMO.curBattleStar_ = data.result
		CombatMO.curBattleCombatUpdate_ = 0

		local combatDB = nil
		if combatType == COMBAT_TYPE_COMBAT then combatDB = CombatMO.queryCombatById(combatId)
		elseif combatType == COMBAT_TYPE_EXPLORE then combatDB = CombatMO.queryExploreById(combatId) end


		--TK统计 关卡开始
		if combatType == COMBAT_TYPE_COMBAT then
			TKGameBO.onBegin(TKText[40] .. combatId)
			if CombatMO.curBattleStar_ > 0 then -- 战斗胜利通关
				TKGameBO.onCompleted(TKText[40] .. combatId)
			else
				TKGameBO.onFailed(TKText[40] .. combatId,TKText[44])
			end
		elseif combatType == COMBAT_TYPE_EXPLORE then
			TKGameBO.onBegin(TKText[41][combatDB.type] .. combatId)
			if CombatMO.curBattleStar_ > 0 then -- 战斗胜利通关
				TKGameBO.onCompleted(TKText[41][combatDB.type] .. combatId)
			else
				TKGameBO.onFailed(TKText[41][combatDB.type] .. combatId,TKText[44])
			end
		end


		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])

		--TK统计 
		if combatType == COMBAT_TYPE_COMBAT then
			TKGameBO.onEvnt(TKText.eventName[21], {combatId = combatId})
		elseif combatType == COMBAT_TYPE_EXPLORE then
			TKGameBO.onEvnt(TKText.eventName[23], {combatId = combatId, combatType = combatDB.type})
		end
		
		--获得资源
		for index=1,#awards do
			local award = awards[index]
			if award.type == ITEM_KIND_RESOURCE then
				TKGameBO.onGetResTk(award.id,award.count,TKText[18],TKGAME_USERES_TYPE_CONSUME)
			end
		end

		-- gdump(awards, "[CombatBO] drop award")
		local stastAwards = CombatBO.addAwards(awards)
		CombatMO.curBattleAward_ = stastAwards

		if table.isexist(data, "exp") then
			-- 添加经验
			local level, exp, upgrade = UserMO.addUpgradeResouce(ITEM_KIND_EXP, data.exp)
			-- 记录当前战斗获得的经验
			stastAwards.awards[#stastAwards.awards + 1] = {kind = ITEM_KIND_EXP, count = data.exp}
			if upgrade then stastAwards.levelUp = true end
		end

		if combatType == COMBAT_TYPE_COMBAT then  -- 普通副本会减少能量
			UserMO.reduceCycleResource(ITEM_KIND_POWER, COMBAT_TAKE_POWER)
		end

		gprint("[CombatBO] star:" .. CombatMO.curBattleStar_, "status:" .. CombatMO.curBattleCombatUpdate_)
		gdump(CombatMO.curBattleAward_, "CombatBO award award")

		if CombatMO.curBattleStar_ > 0 then -- 战斗胜利通关
			CombatMO.curBattleNeedShowBalance_ = true

			local update, status = CombatBO.passCombat(combatType, combatId, CombatMO.curBattleStar_)
			if update then  -- 关卡数据有更新
				CombatMO.curBattleCombatUpdate_ = status
			end

			if combatType == COMBAT_TYPE_COMBAT then
				ActivityBO.trigger(ACTIVITY_ID_FIGHT_COMBAT, 1)
				--任务计数
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COMBAT,type = 1,combatId = combatId})
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COMBAT_NO,type = 1,combatId = combatId})
			elseif combatType == COMBAT_TYPE_EXPLORE then
				if combatDB.type == EXPLORE_TYPE_EQUIP or combatDB.type == EXPLORE_TYPE_PART or combatDB.type == EXPLORE_TYPE_LIMIT or
					combatDB.type == EXPLORE_TYPE_WAR or combatDB.type == EXPLORE_TYPE_ENERGYSPAR or combatDB.type == EXPLORE_TYPE_MEDAL
					or combatDB.type == EXPLORE_TYPE_TACTIC then  -- 装备和配件副本胜利会增加已挑战次数
					CombatMO.combatChallenge_[combatDB.type].count = CombatMO.combatChallenge_[combatDB.type].count + 1
				elseif combatDB.type == EXPLORE_TYPE_EXTREME then  -- 极限副本需要判断是否达到了历史最高排名
					if CombatMO.exploreExtremeHighest_ < combatId then
						CombatMO.exploreExtremeHighest_ = combatId
					end
				end
				--任务计数
				TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_EXPLORE,type = combatDB.type})
				gdump(CombatMO.combatChallenge_[combatDB.type], "CombatBO.asynDoCombat")
			end
			
		else  -- 战斗失败
			CombatMO.curBattleNeedShowBalance_ = false
			CombatMO.curBattleStar_ = 0 -- 星级
			
			if combatType == COMBAT_TYPE_EXPLORE then
				if combatDB.type == EXPLORE_TYPE_EXTREME then  -- 探险副本失败会增加已挑战次数
					CombatMO.combatChallenge_[combatDB.type].count = CombatMO.combatChallenge_[combatDB.type].count + 1
				end
				gdump(CombatMO.combatChallenge_[combatDB.type], "CombatBO.asynDoCombat")
			end
		end

		-- 解析防守的阵型
		local defFormat = CombatBO.parseCombatFormation(combatDB)

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"], formation, defFormat)
		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive
		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData

		local isExtreme = false
		if combatType == COMBAT_TYPE_EXPLORE and combatDB.type == EXPLORE_TYPE_EXTREME then
			isExtreme = true
		end

		local haust = nil
		if table.isexist(data, "haust") then haust = PbProtocol.decodeArray(data["haust"]) end
		-- dump(haust, "server calc")
		local haust = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData, haust)
		-- dump(tmpHaust, "client calc")

		if not isExtreme then -- 极限副本不消耗tank
			local res = {}
			for index = 1, #haust do
				local repair = math.ceil(haust[index].count * BATTLE_REPAIR_RATE)  -- 需要修的
				TankMO.addTankRepairCountById(haust[index].tankId, repair)

				-- 损失的tank数量
				res[#res + 1] = {kind = ITEM_KIND_TANK, count = haust[index].count, id = haust[index].tankId}
				--TK统计
				if haust[index].count > 0 then
					TKGameBO.onEvnt(TKText.eventName[2], {tankId = haust[index].tankId, count = haust[index].count})
				end
			end

		-- for index = 1, #haust do
		-- 	local repair = math.ceil(haust[index].count * BATTLE_REPAIR_RATE)  -- 需要修的
		-- 	TankMO.addTankRepairCountById(haust[index].tankId, repair)

		-- 	-- 损失的tank数量
		-- 	UserMO.reduceResource(ITEM_KIND_TANK, , )
		-- end

			-- for tankId, count in pairs(atkLost) do
			-- 	local repair = TankMO.calcRepairNum(count) -- 战斗死亡中的tank要转换为修理的数量
			-- 	TankMO.addTankRepairCountById(tankId, repair)
				
			-- 	res[#res + 1] = {kind = ITEM_KIND_TANK, count = count, id = tankId}
			-- end
			UserMO.reduceResources(res)
			Notify.notify(LOCAL_TANK_REPAIR_EVENT)
		end

		if NewerMO.needSaveState > 0 then
            NewerBO.saveGuideState(nil,NewerMO.needSaveState)
            NewerMO.needSaveState = 0
        end

		if doneCallback then doneCallback(data.result, formation, defFormat, combatData) end

		-- 埋点
		Statistics.postPoint(typeValue * STATIS_COMBAT + combatId)
	end

	local format = CombatBO.encodeFormation(formation)
	-- -- dump(formation, "传进来的数据")
	-- local format = {}
	-- for index = 1, FIGHT_FORMATION_POS_NUM do
	-- 	local value = formation[index]
	-- 	if value.tankId > 0 and value.count > 0 then
	-- 		format["p" .. index] = {v1 = value.tankId, v2 = value.count}
	-- 	end
	-- end

	-- if formation.commander and formation.commander > 0 then
	-- 	format.commander = formation.commander
	-- end

	SocketWrapper.wrapSend(parseDoCombat, NetRequest.new("DoCombat", {type = typeValue, combatId = combatId, form = format}))
end

-- formation: 当前用于挑战的阵型
-- originalFormation: 用于比较的原始阵型
-- 返回1:能量不足，2:宝石不足, 3:阵型损失过大
function CombatBO.canWipe(formation, originalFormation)
	local statFormation = TankBO.stasticsFormation(formation)
	-- local formatTanks = statFormation.tank -- 统计的阵型tank数据
	-- local repairTanks = TankMO.getNeedRepairTanks()  -- 当前已有的修复tank数据

	-- local restTanks = {}

	-- for tankId, count in pairs(formatTanks) do
	-- 	if not restTanks[tankId] then restTanks[tankId] = {tankId = tankId, count = 0, rest = 0} end
	-- 	restTanks[tankId].rest = TankMO.calcRepairNum(count)
	-- end

	-- for index = 1, #repairTanks do
	-- 	local tankId = repairTanks[index].tankId

	-- 	if not restTanks[tankId] then restTanks[tankId] = {tankId = tankId, count = 0, rest = 0} end
	-- 	restTanks[tankId].rest = restTanks[tankId].rest + repairTanks[index].rest
	-- end

	-- local cost = TankMO.calcRepairCost(restTanks)  -- 计算修理所有tank的总成本
	-- local stoneCount = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
	-- if stoneCount < cost.gemTotal then  -- 宝石不够修的
	-- 	return 2
	-- end

	local statOrigin = TankBO.stasticsFormation(originalFormation)
	if statFormation.amount < (statOrigin.amount * BATTLE_REPAIR_RATE) then  -- 数量太少了
		return 3
	end

	return 0
end

function CombatBO.asynDoWipe(doneCallback, combatType, combatId, formation)
	local function doneDoWipe(name, data)
		-- gdump(data, "[CombatBO] asyn wipe")
		CombatMO.curBattleStar_ = data.result

		local haust = PbProtocol.decodeArray(data["haust"])
		gdump(haust, "[CombatBO] asynDoWipe haust")

		local del = {}

		for index = 1, #haust do
			local repair = math.ceil(haust[index].count * BATTLE_REPAIR_RATE)  -- 需要修的
			TankMO.addTankRepairCountById(haust[index].tankId, repair)

			if haust[index].count > 0 then
				TKGameBO.onEvnt(TKText.eventName[2], {tankId = haust[index].tankId, count = haust[index].count})
			end
			-- 损失的tank数量
			UserMO.reduceResource(ITEM_KIND_TANK, haust[index].count, haust[index].tankId)

			local delNum = haust[index].count - repair
			if delNum > 0 then -- 最终被彻底删除的坦克
				del[#del + 1] = {tankId = haust[index].tankId, count = delNum}
			end
		end

		if combatType == COMBAT_TYPE_COMBAT then
			ActivityBO.trigger(ACTIVITY_ID_FIGHT_COMBAT, 1)
			
			-- 减少能量
			UserMO.reduceCycleResource(ITEM_KIND_POWER, COMBAT_TAKE_POWER)

			--任务计数
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COMBAT,type = 1,combatId = combatId})
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_COMBAT_NO,type = 1,combatId = combatId})
		elseif combatType == COMBAT_TYPE_EXPLORE then
			local combatDB = CombatMO.queryExploreById(combatId)
			if combatDB.type == EXPLORE_TYPE_EXTREME then
			else  -- 减少挑战次数
				CombatMO.combatChallenge_[combatDB.type].count = CombatMO.combatChallenge_[combatDB.type].count + 1
			end
			TaskBO.updateTaskSchedule({kind = TASK_SCHEDULE_KIND_EXPLORE,type = combatDB.type})
		end

		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])
		gdump(awards, "[CombatBO] wipe drop award")

		local stastAward = CombatBO.addAwards(awards)
		CombatMO.curBattleAward_ = stastAward

		if table.isexist(data, "exp") then
			-- 添加经验
			local level, exp, upgrade = UserMO.addUpgradeResouce(ITEM_KIND_EXP, data.exp)
			-- 记录当前战斗获得的经验
			stastAward.awards[#stastAward.awards + 1] = {kind = ITEM_KIND_EXP, count = data.exp}
			if upgrade then stastAward.levelUp = true end
		end

		Notify.notify(LOCAL_TANK_EVENT)
		Notify.notify(LOCAL_TANK_REPAIR_EVENT)

		if doneCallback then doneCallback(stastAward.awards, del) end
	end

	local format = CombatBO.encodeFormation(formation)

	local typeValue = 0
	if combatType == COMBAT_TYPE_COMBAT then
		typeValue = 1
	elseif combatType == COMBAT_TYPE_EXPLORE then
		typeValue = math.floor(combatId / 100) + 1
	end
	-- print("============ DoCombat  扫荡  type:" .. typeValue .. " combatId:" .. combatId )
	SocketWrapper.wrapSend(doneDoWipe, NetRequest.new("DoCombat", {type = typeValue, combatId = combatId, form = format, wipe = true}))
end

--获得扫荡设置
function CombatBO.asynGetWipeInfo(doneCallback)
	local function parseGetWipeInfo(name, data)
		Loading.getInstance():unshow()

		CombatBO.parseWipeInfo(data["info"])
		if doneCallback then doneCallback() end
	end
	
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseGetWipeInfo, NetRequest.new("GetWipeInfo"))
end


--扫荡设置
function CombatBO.asynSetWipeInfo(doneCallback,wipeInfo)
	local function setWipe(name, data)
		Loading.getInstance():unshow()

		CombatBO.parseWipeInfo(data["info"])
		if doneCallback then doneCallback() end
	end
	local temp ={}
	for k,v in pairs(wipeInfo) do
		table.insert(temp,v)
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(setWipe, NetRequest.new("SetWipeInfo", {info = temp}))
end

--一键扫荡
function CombatBO.asynOnekeyDoWipe(doneCallback)
	local function doneDoWipe(name, data)
		Loading.getInstance():unshow()

		CombatBO.parseWipeReward(data)
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(doneDoWipe, NetRequest.new("GetWipeRewar"))
end



function CombatBO.asynBeginExtremeWipe(doneCallback)
	local function parseBeginWipe(name, data)
		gdump(data, "CombatBO.asynBeginExtremeWipe")
		local curIndex = CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME]
		if curIndex == 0 then curIndex = 300 end

		local delta = CombatMO.exploreExtremeHighest_ - curIndex
		-- local index = CombatMO.getExtremeProgressIndex(CombatMO.exploreExtremeHighest_)
		-- local startIndex = CombatMO.getExtremeProgressIndex(CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME])

		local leftTime = delta * EXPLORE_EXTREME_WIPE_TIME + 0.99
		CombatMO.extremeWipeTime_ = leftTime
		-- print("leftTime:", CombatMO.extremeWipeTime_)
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBeginWipe, NetRequest.new("BeginWipe"))
end

function CombatBO.asynEndExtremeWipe(doneCallback)
	local function parseEndWipe(name, data)
		gdump(data, "CombatBO.asynEndExtremeWipe")

		CombatMO.extremeWipeTime_ = 0
		CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] = data.combatId

		local awards = PbProtocol.decodeArray(data["award"])

		local stastAwards = CombatBO.addAwards(awards)

		--TK统计
		for index=1,#awards do
			local award = awards[index]
			if award.type == ITEM_KIND_RESOURCE then
				TKGameBO.onGetResTk(award.id,award.count,TKText[18],TKGAME_USERES_TYPE_CONSUME)
			elseif award.type == ITEM_KIND_COIN then
				TKGameBO.onReward(award.count, TKText[18])
			end
		end

		if doneCallback then doneCallback(stastAwards) end
	end

	SocketWrapper.wrapSend(parseEndWipe, NetRequest.new("EndWipe"))
end

function CombatBO.asynCombatBox(doneCallback, combatType, sectionId, boxIndex)
	local function parseCombatBox(name, data)
		gdump(data, "[CombatBO] combat box")

		if not CombatMO.sectionBoxs_[sectionId] then
			CombatMO.sectionBoxs_[sectionId] = {}
			CombatMO.sectionBoxs_[sectionId].box = {}
		end

		-- 宝箱已领取
		CombatMO.sectionBoxs_[sectionId].box[boxIndex] = true

		-- 解析掉落奖励
		local awards = PbProtocol.decodeArray(data["award"])
		local stastAwards = CombatBO.addAwards(awards)

		-- 是荒宝兑换，需要扣除荒宝
		if combatType == COMBAT_TYPE_EXPLORE and CombatMO.getExploreTypeBySectionId(sectionId) == EXPLORE_TYPE_LIMIT then
			local price = PropMO.huangbaoExchnage[boxIndex].price
			UserMO.reduceResource(ITEM_KIND_HUANGBAO, price)
		end

		--TK统计
		for index=1,#awards do
			local award = awards[index]
			if award.type == ITEM_KIND_COIN then
				TKGameBO.onReward(award.count, TKText[20])
			end
		end

		Notify.notify(LOCAL_COMBAT_BOX_EVENT)  -- 领取了宝箱

		if doneCallback then doneCallback(stastAwards) end
	end

	local typeValue = 0
	if combatType == COMBAT_TYPE_COMBAT then
		typeValue = 1
	elseif combatType == COMBAT_TYPE_EXPLORE then
		if sectionId == 201 then typeValue = 2
		elseif sectionId == 301 then typeValue = 3
		elseif sectionId == 501 then typeValue = 4
		elseif sectionId == 601 then typeValue = 6
		elseif sectionId == 801 then typeValue = 8
		elseif sectionId == 901 then typeValue = 9
		elseif sectionId == 1001 then typeValue = 10
		end
	end

	SocketWrapper.wrapSend(parseCombatBox, NetRequest.new("CombatBox", {type = typeValue, id = sectionId, which = boxIndex}))
end

-- 用于探险副本中的装备和配件
function CombatBO.asynBuyExplore(doneCallback, sectionId)
	local exploreType = CombatMO.getExploreTypeBySectionId(sectionId)

	local function parseBuyExplore(name, data)
		gdump(data, "[CombatBO] buy explore")

		-- CombatMO.combatBuy_[exploreType].count = CombatMO.combatBuy_[exploreType].count + 1  -- 增加购买次数
		CombatMO.combatBuy_[exploreType].count = data.count  -- 增加购买次数

		local coinNum = 0
		if table.isexist(data, "gold") then
			coinNum = UserMO.getResource(ITEM_KIND_COIN) - data.gold  -- 减少的金币数量
			UserMO.updateResource(ITEM_KIND_COIN, data.gold) -- 更新金币数量
		else
			coinNum = EXPLORE_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count] or EXPLORE_RESET_TAKE_COIN[#EXPLORE_RESET_TAKE_COIN]
			if exploreType == EXPLORE_TYPE_EQUIP and ActivityBO.isValid(ACTIVITY_ID_EQUIP_SUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_EQUIP_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_PART and ActivityBO.isValid(ACTIVITY_ID_PART_SUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_PART_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
				coinNum = EXPLORE_ALTAR_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count] or EXPLORE_ALTAR_RESET_TAKE_COIN[#EXPLORE_ALTAR_RESET_TAKE_COIN]
				if ActivityBO.isValid(ACTIVITY_ID_ENERGY_SUPPLY) then
					coinNum = math.ceil(coinNum * ACTIVITY_ENERYG_SUPPLY_COIN_RATE)
				end
			elseif exploreType == EXPLORE_TYPE_WAR and ActivityBO.isValid(ACTIVITY_ID_MILITARY_SUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_MILITARY_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_MEDAL and ActivityBO.isValid(ACTIVITY_ID_MEDAL_SUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_MEDAL_SUPPLY_COIN_RATE)
			elseif exploreType == EXPLORE_TYPE_TACTIC and ActivityBO.isValid(ACTIVITY_ID_TACTICS_SSUPPLY) then
				coinNum = math.ceil(coinNum * ACTIVITY_TACTIC_SUPPLY_COIN_RATE)
			end

			UserMO.reduceResource(ITEM_KIND_COIN, coinNum) -- 减少金币
		end

		--TK统计  金币消耗
  		TKGameBO.onUseCoinTk(coinNum, TKText[10][8], TKGAME_USERES_TYPE_CONSUME)
  		Notify.notify("WIPE_COMBAT_EXPLORE_HANDLER")
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuyExplore, NetRequest.new("BuyExplore", {type = exploreType}))
end

-- 重置极限探险，只用于极限副本
function CombatBO.asynResetExtrEpr(doneCallback)
	local function parseResetExtrEpr(name, data)
		gdump(data, "[CombatBO] reset explore")

		UserMO.reduceCycleResource(ITEM_KIND_POWER, EXPLORE_EXTREME_RESET_TAKE_POWER)  -- 减少能量

		CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] = 0 -- 清除当前进度
		CombatMO.combatBuy_[EXPLORE_TYPE_EXTREME].count = CombatMO.combatBuy_[EXPLORE_TYPE_EXTREME].count + 1 -- 重置次数增加

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseResetExtrEpr, NetRequest.new("ResetExtrEpr", {type = 1}))
end

function CombatBO.asynGetExtreme(doneCallback, extremeId)
	local function parseGteExtreme(name, data)
		gdump(data, "CombatBO.asynGetExtreme")
		local ret = {}
		local first = nil
		if table.isexist(data, "first") then
			first = PbProtocol.decodeRecord(data["first"])
		end
		local last = PbProtocol.decodeArray(data["last3"])
		ret.first = first or {}
		ret.last = last
		gdump(ret, "CombatBO.asynGetExtreme 111")
		if doneCallback then doneCallback(ret) end
	end

	SocketWrapper.wrapSend(parseGteExtreme, NetRequest.new("GetExtreme", {extremeId = extremeId}))
end

function CombatBO.asynExtremeRecord(doneCallback, extremeId, which)
	local function parseExtremeRecord(name, data)
		-- local record = PbProtocol.decodeRecord(data["record"])
		-- gdump(record, "CombatBO.asynExtremeRecord")

		CombatMO.curBattleStar_ = 3  -- 通关默认是胜利

		CombatMO.curBattleNeedShowBalance_ = false
		CombatMO.curBattleCombatUpdate_ = 0
		CombatMO.curBattleAward_ = nil
		CombatMO.curBattleStatistics_ = {}

		CombatMO.curChoseBattleType_ = COMBAT_TYPE_REPLAY
		CombatMO.curChoseBtttleId_ = 0

		-- 解析战斗的数据
		local combatData = CombatBO.parseCombatRecord(data["record"])

		-- 设置先手
		CombatMO.curBattleOffensive_ = combatData.offsensive

		CombatMO.curBattleAtkFormat_ = combatData.atkFormat
		CombatMO.curBattleDefFormat_ = combatData.defFormat
		CombatMO.curBattleFightData_ = combatData

		BattleMO.reset()
		BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		BattleMO.setFightData(CombatMO.curBattleFightData_)

		local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

		if doneCallback then doneCallback(ret) end
	end

	SocketWrapper.wrapSend(parseExtremeRecord, NetRequest.new("ExtremeRecord", {extremeId = extremeId, which = which}))
end

function CombatBO.GetTreasureShop(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local week = data.openWeek
		local list = PbProtocol.decodeArray(data.shopBuy)
		rhand(week,list)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetTreasureShopBuy"))
end

function CombatBO.BuyTreasureShop(id,rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		rhand()
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BuyTreasureShop",{treasureId=id,count=1}))
end
