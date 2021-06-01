
-- 部队设置中显示的战斗力等属性TableView

ARMY_ATTR_FOR_LOCAL = 1 -- 驻守本城
ARMY_ATTR_FOR_COMBAT = 2 -- 挑战副本
ARMY_ATTR_FOR_ARENA = 3 -- 竞技场
ARMY_ATTR_FOR_WORLD = 4 -- 世界
ARMY_ATTR_FOR_GUARD = 5 -- 驻军
ARMY_ATTR_FOR_PARTYB = 6 --百团混战
ARMY_ATTR_FOR_BOSS  = 7 -- 世界BOSS
ARMY_ATTR_FOR_MILITARY_AREA = 8 -- 军事矿区
ARMY_ATTR_FOR_ALTAR_BOSS  = 9 -- 军团BOSS
ARMY_ATTR_FOR_HUNTER = 11
ARMY_ATTR_FOR_CROSS_MILITARY_AREA = 12 -- 跨服军事矿区

local ArmyFightAttrTableView = class("ArmyFightAttrTableView", TableView)

-- 需要显示属性的部队阵型formation
function ArmyFightAttrTableView:ctor(size, viewFor, alarmIcon)
	ArmyFightAttrTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_viewFor = viewFor
	self.alarmIcon = alarmIcon
	if self.alarmIcon then
		self.alarmIcon:setVisible(false)
	end
	

	gprint("ArmyFightAttrTableView view for:", viewFor)

	self:showSlider(true)

	self.m_cellSize = cc.size(size.width, 290)
	self.m_curChoseIndex = 0
end

function ArmyFightAttrTableView:onEnter()
	ArmyFightAttrTableView.super.onEnter(self)
	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onUpdateShow))
	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onUpdateShow))
end

function ArmyFightAttrTableView:onExit()
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
end

function ArmyFightAttrTableView:numberOfCells()
	return 1
end

function ArmyFightAttrTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArmyFightAttrTableView:createCellAtIndex(cell, index)
	-- 战斗力
	local fight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(cell)
	fight:setAnchorPoint(cc.p(0, 0.5))
	fight:setPosition(10, self.m_cellSize.height - 25)

	local value = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
	value:setPosition(fight:getPositionX() + fight:getContentSize().width + 5, fight:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_fightLabel = value

	--VS
	local vsLab = ui.newTTFLabel({text = "VS", font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = self.m_cellSize.width / 2, y = value:getPositionY(), color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	vsLab:setAnchorPoint(cc.p(0.5, 0.5))
	vsLab:setVisible(false)
	self.m_vsLab = vsLab

	local enemyFight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(cell)
	enemyFight:setAnchorPoint(cc.p(0, 0.5))
	enemyFight:setPosition(vsLab:getPositionX() + vsLab:getContentSize().width / 2 + 10, vsLab:getPositionY())
	enemyFight:setVisible(false)
	self.m_enemyFight = enemyFight

	local enemyValue = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
	enemyValue:setPosition(enemyFight:getPositionX() + enemyFight:getContentSize().width + 5, enemyFight:getPositionY())
	enemyValue:setAnchorPoint(cc.p(0, 0.5))
	enemyValue:setVisible(false)
	self.m_enemyValue = enemyValue




	-- 载重
	local load = display.newSprite(IMAGE_COMMON .. "label_payload.png"):addTo(cell)
	load:setAnchorPoint(cc.p(0, 0.5))
	load:setPosition(10, fight:getPositionY() - 30)

	local value = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
	value:setPosition(load:getPositionX() + load:getContentSize().width + 5, load:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_payloadLabel = value

	local labelColor = COLOR[11]

	local height = self.m_cellSize.height - 60
	local deltaY = 26

	self.m_attrLabels = {}

	-- 行军目标
	local label = ui.newTTFLabel({text = CommonText[20] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 1, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[1] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[1]:setAnchorPoint(cc.p(0, 0.5))
	if self.m_viewFor == ARMY_ATTR_FOR_PARTYB then
		label:setString(CommonText[815])
	end

	-- 行军时间
	local label = ui.newTTFLabel({text = CommonText[21] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 2, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[2] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[2]:setAnchorPoint(cc.p(0, 0.5))
	if self.m_viewFor == ARMY_ATTR_FOR_PARTYB then
		label:setVisible(false)
	end

	-- 装备战力
	local label = ui.newTTFLabel({text = CommonText[25] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 3, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[3] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[3]:setAnchorPoint(cc.p(0, 0.5))

	-- 基础战力
	local label = ui.newTTFLabel({text = CommonText[24] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 4, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[4] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[4]:setAnchorPoint(cc.p(0, 0.5))

	-- 将领战力
	local label = ui.newTTFLabel({text = CommonText[26] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 5, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[5] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[5]:setAnchorPoint(cc.p(0, 0.5))

	-- 技能科技
	local label = ui.newTTFLabel({text = CommonText[27] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 6, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[6] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[6]:setAnchorPoint(cc.p(0, 0.5))

	-- 配件战力
	local label = ui.newTTFLabel({text = CommonText[28] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 7, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[7] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[7]:setAnchorPoint(cc.p(0, 0.5))

	-- 带兵数量
	local label = ui.newTTFLabel({text = CommonText[22] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = height - deltaY * 8, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_attrLabels[8] = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	self.m_attrLabels[8]:setAnchorPoint(cc.p(0, 0.5))

	self:showAttr()

	return cell
end

function ArmyFightAttrTableView:showAttr()
	local formation = self.m_formation
	local fightValueData = TankBO.analyseFormation(formation)

	-- local fightValue = 0
	-- local payloadValue = 0

	-- for index = 1, FIGHT_FORMATION_POS_NUM do
	-- 	local formatData = formation[index]
	-- 	if formatData.tankId > 0 then
	-- 		local tankDB = TankMO.queryTankById(formatData.tankId)

	-- 		fightValue = fightValue + tankDB.fight * formatData.count
	-- 		payloadValue = payloadValue + tankDB.payload * formatData.count
	-- 	end
	-- end

	self.m_fightLabel:setString(UiUtil.strNumSimplify(fightValueData.total)) -- 战斗力

	local load = 0
	if self.m_viewFor == ARMY_ATTR_FOR_CROSS_MILITARY_AREA then
		for index = 1, FIGHT_FORMATION_POS_NUM do
			local format = formation[index]
			if format.tankId > 0 and format.count > 0 then
				local tankDB = TankMO.queryTankById(format.tankId)
				load = load + tankDB.payload * format.count
			end
		end
	else
		load = fightValueData.payload
	end
	if UserMO.ruins and UserMO.ruins.isRuins then
		load =  load *(1 - UserMO.querySystemId(24)/10000)
	end
	self.m_payloadLabel:setString(UiUtil.strNumSimplify(load))  -- 载重


	-- 行军目标
	if self.m_viewFor == ARMY_ATTR_FOR_LOCAL then
		self.m_attrLabels[1]:setString(CommonText[261] .. "(0,0)")
	elseif self.m_viewFor == ARMY_ATTR_FOR_COMBAT then
		if CombatMO.curChoseBattleType_ == COMBAT_TYPE_COMBAT then
			local combatDB = CombatMO.queryCombatById(CombatMO.curChoseBtttleId_)
			local sectionDB = CombatMO.querySectionById(combatDB.sectionId)
			self.m_attrLabels[1]:setString(sectionDB.name .. "(" .. combatDB.name .. ")")
			self.m_vsLab:setVisible(true)
			self.m_enemyFight:setVisible(true)
			self.m_enemyValue:setVisible(true)
			self.m_enemyValue:setString(UiUtil.strNumSimplify(combatDB.fight))
			self.alarmIcon:setVisible(fightValueData.total < combatDB.fight)
		elseif CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
			local combatDB = CombatMO.queryExploreById(CombatMO.curChoseBtttleId_)
			local sectionId = CombatMO.getExploreSectionIdByType(combatDB.type)
			local sectionDB = CombatMO.querySectionById(sectionId)
			self.m_attrLabels[1]:setString(sectionDB.name .. "(" .. combatDB.name .. ")")
			if combatDB.type == EXPLORE_TYPE_PART or combatDB.type == EXPLORE_TYPE_EQUIP or combatDB.type == EXPLORE_TYPE_WAR or combatDB.type == EXPLORE_TYPE_ENERGYSPAR or combatDB.type == EXPLORE_TYPE_MEDAL
			   or combatDB.type == EXPLORE_TYPE_TACTIC then
				self.m_vsLab:setVisible(true)
				self.m_enemyFight:setVisible(true)
				self.m_enemyValue:setVisible(true)
				self.m_enemyValue:setString(UiUtil.strNumSimplify(combatDB.fight))
				self.alarmIcon:setVisible(fightValueData.total < combatDB.fight)
			end
		end
	elseif self.m_viewFor == ARMY_ATTR_FOR_ARENA then -- 竞技场
		local build = BuildMO.queryBuildById(BUILD_ID_ARENA)
		self.m_attrLabels[1]:setString(build.name)
	elseif self.m_viewFor == ARMY_ATTR_FOR_WORLD then  -- 世界
		local mine = WorldBO.getMineAt(cc.p(WorldMO.curAttackPos_.x, WorldMO.curAttackPos_.y))

		if mine then
			local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type)
			self.m_attrLabels[1]:setString(mine.lv .. CommonText[237][4] .. resData.name2 .. "(" .. WorldMO.curAttackPos_.x .. "," .. WorldMO.curAttackPos_.y .. ")")
		else
			local mapData = WorldMO.getMapDataAt(WorldMO.curAttackPos_.x, WorldMO.curAttackPos_.y)
			-- dump(mapData)
			if mapData then
				self.m_attrLabels[1]:setString(mapData.lv .. CommonText[237][4] .. mapData.name .. "(" .. WorldMO.curAttackPos_.x .. "," .. WorldMO.curAttackPos_.y .. ")")
			end
		end
	elseif self.m_viewFor == ARMY_ATTR_FOR_GUARD then
		local mapData = WorldMO.getMapDataAt(WorldMO.curGuardPos_.x, WorldMO.curGuardPos_.y)
		if mapData then
			self.m_attrLabels[1]:setString(mapData.lv .. CommonText[237][4] .. mapData.name .. "(" .. WorldMO.curGuardPos_.x .. "," .. WorldMO.curGuardPos_.y .. ")")
		end
	elseif self.m_viewFor == ARMY_ATTR_FOR_PARTYB then
	elseif self.m_viewFor == ARMY_ATTR_FOR_BOSS then
		self.m_attrLabels[1]:setString(CommonText[10018])
	elseif self.m_viewFor == ARMY_ATTR_FOR_HUNTER then
		-- self.m_attrLabels[1]:setString(CommonText[10018])
	elseif self.m_viewFor == ARMY_ATTR_FOR_MILITARY_AREA then
		local mine = StaffBO.getMineAt(StaffMO.curAttackPos_)
		local resData = UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, mine.type)
		self.m_attrLabels[1]:setString(mine.lv .. CommonText[237][4] .. resData.name2 .. "(" .. StaffMO.curAttackPos_.x .. "," .. StaffMO.curAttackPos_.y .. ")")
	elseif self.m_viewFor == ARMY_SETTING_FORTRESS then
		self.m_attrLabels[1]:setString(CommonText[20042])
	elseif self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK then
		self.m_attrLabels[1]:setString(CommonText[20041])
	elseif self.m_viewFor == ARMY_ATTR_FOR_ALTAR_BOSS then
		local lv = PartyBO.getAltarBossLevel()
		local altarboss = PartyMO.queryPartyAltarBoss(lv)
		if altarboss then
			self.m_attrLabels[1]:setString(altarboss.bossName)
		end		
	end

	-- 行军时间
	if self.m_viewFor == ARMY_ATTR_FOR_LOCAL or self.m_viewFor == ARMY_ATTR_FOR_COMBAT or self.m_viewFor == ARMY_ATTR_FOR_ARENA or self.m_viewFor == ARMY_ATTR_FOR_BOSS or self.m_viewFor == ARMY_ATTR_FOR_ALTAR_BOSS then
		self.m_attrLabels[2]:setString(0)
	elseif self.m_viewFor == ARMY_ATTR_FOR_WORLD then -- 世界
		self.m_attrLabels[2]:setString(UiUtil.strBuildTime(WorldBO.getMarchTime(WorldMO.pos_, WorldMO.curAttackPos_)))
	elseif self.m_viewFor == ARMY_ATTR_FOR_GUARD then  -- 驻军
		self.m_attrLabels[2]:setString(UiUtil.strBuildTime(WorldBO.getMarchTime(WorldMO.pos_, WorldMO.curGuardPos_)))
	elseif self.m_viewFor == ARMY_ATTR_FOR_MILITARY_AREA then -- 军事矿区
		self.m_attrLabels[2]:setString(0)
	end

	self.m_attrLabels[3]:setString(UiUtil.strNumSimplify(fightValueData.equip))

	-- 基础战力
	self.m_attrLabels[4]:setString(UiUtil.strNumSimplify(fightValueData.base))

	self.m_attrLabels[5]:setString(UiUtil.strNumSimplify(fightValueData.hero))

	self.m_attrLabels[6]:setString(UiUtil.strNumSimplify(fightValueData.skill))

	-- 配件战力
	self.m_attrLabels[7]:setString(UiUtil.strNumSimplify(fightValueData.part))
	
	local awakeHeroKeyId = nil
	if table.isexist(formation,"awakenHero") then awakeHeroKeyId = formation.awakenHero.keyId end
	local takeTank = UserBO.getTakeTank(formation.commander, awakeHeroKeyId)  -- 计算没有武将加成下的带兵量

	-- 带兵数量
	local stasFormat = TankBO.stasticsFormation(self.m_formation)
	self.m_attrLabels[8]:setString(stasFormat.amount .. "/" .. (takeTank * FIGHT_FORMATION_POS_NUM))
end

function ArmyFightAttrTableView:setFormation(formation)
	local tacticsKeyId = TacticsMO.isTacticCanUse(formation)
	-- self.m_formation = formation
	local format = clone(formation)
	format.tacticsKeyId = tacticsKeyId
	self.m_formation = format
	if table.isexist(formation, "awakenHero") then
		self.m_formation.commander = formation.awakenHero.heroId
	end
end

function ArmyFightAttrTableView:onUpdateShow(event)
	self:showAttr()
end

return ArmyFightAttrTableView
