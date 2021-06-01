require("app.text.DetailText")

--------------------------------------------------------------------
-- 战斗力TableView
--------------------------------------------------------------------

local FightValueTableView = class("FightValueTableView", TableView)

-- -- 所有可装备的空闲装备
function FightValueTableView:ctor(size, formatPosition, equipPos)
	FightValueTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
end

function FightValueTableView:numberOfCells()
	return FIGHT_ID_PROPS
end

function FightValueTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function FightValueTableView:createCellAtIndex(cell, index)
	FightValueTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_FIGHT_VALUE, index):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)
	itemView.index = index
	UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onDetailCallback))

	local resData = UserMO.getResourceData(ITEM_KIND_FIGHT_VALUE, index)

	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[resData.quality]}):addTo(cell)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
	bar:setPosition(170 + bar:getContentSize().width / 2, 40)
	bar:setPercent(0)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback))
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width - 80, 50)

	if index == 1 then  -- 统率
		local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK)
		local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_COMMAND_BOOK)

		-- 拥有
		local label = ui.newTTFLabel({text = CommonText[562][1] .. resData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		if count <= 0 then value:setColor(COLOR[5])
		else value:setColor(COLOR[2]) end

		local percent = UserMO.command_ / UserMO.level_
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == 2 then -- 技能
		local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK)
		local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_SKILL_BOOK)

		-- 拥有
		local label = ui.newTTFLabel({text = CommonText[562][1] .. resData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		if count <= 0 then value:setColor(COLOR[5])
		else value:setColor(COLOR[2]) end

		-- 所有的技能等级
		local value = 0
		local num = SkillMO.queryMaxSkill()
		for index = 1, num do
			local skillLv = SkillMO.getSkillLevelById(index)
			value = value + skillLv
		end

		local percent = value / (UserMO.level_ * num)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == 3 then  -- 装备品质
		local count = 0
		-- 可以穿，而没有穿放在仓库中的装备
		for keyId, equip in pairs(EquipMO.equip_) do
			if equip.formatPos == 0 then
				local pos = EquipMO.getPosByEquipId(equip.equipId)
				if pos > 0 then count = count + 1 end
			end
		end

		-- 仓库中的装备
		local label = ui.newTTFLabel({text = CommonText[210] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		if count <= 0 then value:setColor(COLOR[5])
		else value:setColor(COLOR[2]) end

		local value = 0
		for formatIndex = 1, FIGHT_FORMATION_POS_NUM do
			for equipPos = 1, EQUIP_POS_CRIT_DEF do
				if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
					local equip = EquipBO.getEquipAtPos(formatIndex, equipPos)
					local equipDB = EquipMO.queryEquipById(equip.equipId)
					value = value + equipDB.quality
				end
			end
		end

		local percent = value / (FIGHT_FORMATION_POS_NUM * EQUIP_POS_CRIT_DEF * EQUIP_QUALITY_TYPE_NUMBER)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == 4 then -- 装备升级
		local count = 0
		-- 有没有装备卡
		for keyId, equip in pairs(EquipMO.equip_) do
			if equip.formatPos == 0 then
				local pos = EquipMO.getPosByEquipId(equip.equipId)
				if pos == 0 then count = count + 1 end
			end
		end

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
		if count > 0 then
			label:setString(CommonText[419][1])  -- 装备可升级
			label:setColor(COLOR[2])
		else
			label:setString(CommonText[419][2])  -- 装备不可升级
			label:setColor(COLOR[5])
		end

		local value = 0
		for formatIndex = 1, FIGHT_FORMATION_POS_NUM do
			for equipPos = 1, EQUIP_POS_CRIT_DEF do
				if EquipBO.hasEquipAtPos(formatIndex, equipPos) then
					local equip = EquipBO.getEquipAtPos(formatIndex, equipPos)
					value = value + equip.level
				end
			end
		end

		local percent = value / (FIGHT_FORMATION_POS_NUM * EQUIP_POS_CRIT_DEF * UserMO.level_)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == 5 then -- 配件品质
		local count = #PartMO.getFreeParts()

		-- 仓库中的装备
		local label = ui.newTTFLabel({text = CommonText[420] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))
		if count <= 0 then value:setColor(COLOR[5])
		else value:setColor(COLOR[2]) end

		local value = 0
		for index = 1, PART_TYPE_ROCKET do
			for partPos = 1, PART_POS_ATTACK_HP do
				if PartBO.hasPartAtPos(index, partPos) then
					local part = PartBO.getPartAtPos(index, partPos)
					local partDB = PartMO.queryPartById(part.partId)
					if partDB.quality == 1 then value = value + 1
					elseif partDB.quality == 2 then value = value + 1.5
					elseif partDB.quality == 3 then value = value + 2
					elseif partDB.quality == 4 then value = value + 3
					end
				end
			end
		end

		local percent = value / (PART_TYPE_ROCKET * PART_POS_ATTACK_HP * 3)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_PART_UP then -- 配件强化
		local count = 0
		local value = 0
		for index = 1, PART_TYPE_ROCKET do
			for partPos = 1, PART_POS_ATTACK_HP do
				if PartBO.hasPartAtPos(index, partPos) then
					local part = PartBO.getPartAtPos(index, partPos)
					value = value + part.upLevel
					count = count + 1
				end
			end
		end

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
		if count > 0 then
			label:setString(CommonText[419][3])  -- 配件可强化
			label:setColor(COLOR[2])
		else
			label:setString(CommonText[419][4])  -- 配件不可强化
			label:setColor(COLOR[5])
		end

		local percent = value / (PART_TYPE_ROCKET * PART_POS_ATTACK_HP * UserMO.level_)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_PART_REFIT then
		local count = 0
		local value = 0
		for index = 1, PART_TYPE_ROCKET do
			for partPos = 1, PART_POS_ATTACK_HP do
				if PartBO.hasPartAtPos(index, partPos) then
					local part = PartBO.getPartAtPos(index, partPos)
					value = value + part.refitLevel

					count = count + 1
				end
			end
		end

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
		if count > 0 then
			label:setString(CommonText[419][5])  -- 配件可改造
			label:setColor(COLOR[2])
		else
			label:setString(CommonText[419][6])  -- 配件不可改造
			label:setColor(COLOR[5])
		end
		local max = UserMO.querySystemId(16)
		local percent = value / (PART_TYPE_ROCKET * PART_POS_ATTACK_HP * max)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_SCIENCE_LEVEL then
		local canUp = false
		local value = 0
		local ids = {106, 107, 108, 109, 110, 111, 112,113}
		for index = 1, #ids do  -- 科技id
			local id = ids[index]
			local science = ScienceMO.queryScienceById(id)
			value = value + science.scienceLv

			local maxLevel = ScienceMO.queryScienceMaxLevel(id)
			if science.scienceLv >= maxLevel then -- 已经是最高等级了
			else
				local result = ScienceBO.canUpGrade(id, science.scienceLv + 1)
				if result == 2 then canUp = true end  -- 科技可以升级
			end
		end

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
		if canUp then
			label:setString(CommonText[422][1])
			label:setColor(COLOR[2])
		else
			label:setString(CommonText[422][2])
			label:setColor(COLOR[5])
		end

		local percent = value / (UserMO.level_ * #ids)
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_PARTY then  -- 军团科技
		local percent = 0

		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			local value = 0
			local ids = {202, 203, 204, 205}
			for index = 1, #ids do  -- 科技id
				local id = ids[index]
				local science = PartyBO.getScienceById(id)
				if science then
					value = value + science.scienceLv
				end
			end

			local maxLevel = ScienceMO.queryScienceMaxLevel(ids[1])
			local percent = value / (maxLevel * #ids)

			local label = ui.newTTFLabel({text = CommonText[421][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))
			label:setColor(COLOR[2])
		else
			-- 还没有军团
			local label = ui.newTTFLabel({text = CommonText[421][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))
			label:setColor(COLOR[5])
		end
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_ARMY then  -- 主力部队
		local level = math.max(BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A), BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)) -- 找到等级更高的战车工厂

		-- 在所有可以生产的坦克中找到当前可以生产的最好tank
		local bestTankId = 0
		local tanks = TankMO.queryCanBuildTanks()
		for index = 1, #tanks do
			local tank = tanks[index]
			if tank.factoryLv <= level and tank.lordLv <= UserMO.level_ then
				bestTankId = tank.tankId
			end
		end
		if bestTankId > 0 then
			local tankDB = TankMO.queryTankById(bestTankId)
			-- 最强制作坦克
			local label = ui.newTTFLabel({text = CommonText[424] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))

			local name = ui.newTTFLabel({text = tankDB.name, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[tankDB.grade]}):addTo(cell)
			name:setAnchorPoint(cc.p(0, 0.5))

			local percent = 0

			local takeTank = UserBO.getTakeTank() * FIGHT_FORMATION_POS_NUM -- 带兵量
			local count = UserMO.getResource(ITEM_KIND_TANK, bestTankId)
			local delta = takeTank - count
			if delta > 0 then -- 还差
				percent = count / takeTank

				-- 还差
				local label = ui.newTTFLabel({text = "." .. CommonText[425], font = G_FONT, size = FONT_SIZE_TINY, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(cell)
				label:setAnchorPoint(cc.p(0, 0.5))

				local label = ui.newTTFLabel({text = delta, font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[5]}):addTo(cell)
				label:setAnchorPoint(cc.p(0, 0.5))
				-- 辆
				local label = ui.newTTFLabel({text = CommonText[237][6], font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(cell)
				label:setAnchorPoint(cc.p(0, 0.5))
			else
				percent = 1
			end

			bar:setPercent(percent)
			bar:setLabel(math.ceil(percent * 100) .. "%")
		end
	elseif index == FIGHT_ID_FULL then -- 部队满编
		local formation = TankBO.getMaxFightFormation(nil, false)
		local stasFormat = TankBO.stasticsFormation(formation)

		local label = ui.newTTFLabel({text = CommonText[426], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local percent = stasFormat.amount / stasFormat.amountTheory
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	elseif index == FIGHT_ID_PROPS then
		local maxLevel = UserMO.queryMaxProsperousLevel()
		local prosDB = UserMO.queryProsperousByLevel(maxLevel)

		-- 可提升...
		local label = ui.newTTFLabel({text = CommonText[423], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 75, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local percent = UserMO.getResource(ITEM_KIND_PROSPEROUS) / prosDB.prosExp
		bar:setPercent(percent)
		bar:setLabel(math.ceil(percent * 100) .. "%")
	end

	return cell
end

function FightValueTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local index = sender.index
	if index == FIGHT_ID_COMMAND then
		local PlayerView = require("app.view.PlayerView")
		PlayerView.new(UI_ENTER_NONE):push()
	elseif index == FIGHT_ID_SKILL then
		local PlayerView = require("app.view.PlayerView")
		PlayerView.new(UI_ENTER_NONE, PLAYER_VIEW_SKILL):push()
	elseif index == FIGHT_ID_EQUIP_QUALITY then -- 抽装备
		require("app.view.LotteryEquipView").new(UI_ENTER_NONE):push()
	elseif index == FIGHT_ID_EQUIP_LEVEL then -- 装备
		require("app.view.EquipView").new():push()
	elseif index == FIGHT_ID_PART_QUALITY then -- 配件品质
		if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_PART) then  -- 等级不足
			local exploreSection = CombatMO.querySectionById(CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART))
			Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_PART), exploreSection.name))
			return
		end

		local CombatLevelView = require("app.view.CombatLevelView")
		CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART)):push()
	elseif index == FIGHT_ID_PART_UP or index == FIGHT_ID_PART_REFIT then -- 配件强化、配件改造
		local buildingId = BUILD_ID_COMPONENT
		if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
			local build = BuildMO.queryBuildById(buildingId)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
			return
		end

		require("app.view.ComponentView").new(buildingId):push()
	elseif index == FIGHT_ID_SCIENCE_LEVEL then -- 科技等级
		local ScienceView = require("app.view.ScienceView")
		ScienceView.new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
	elseif index == FIGHT_ID_PARTY then -- 军团科技
		local buildingId = BUILD_ID_PARTY
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
			local build = BuildMO.queryBuildById(buildingId)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
			return
		end

		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			Loading.getInstance():show()
			PartyBO.asynGetPartyScience(function()
					--进入军团科技
					Loading.getInstance():unshow()
					require("app.view.PartyScienceView").new():push()
				end, 0)
		else
			Loading.getInstance():show()
			--打开军团列表
			PartyBO.asynGetPartyRank(function()
					Loading.getInstance():unshow()
					require("app.view.AllPartyView").new():push()
				end, 0, PartyMO.allPartyList_type_)
		end
	elseif index == FIGHT_ID_ARMY or index == FIGHT_ID_FULL then -- 主力部队、部队满编
		local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()
		local id = buildingId
		if position == 1 then  -- 有一个开工了，则需要进入另外一个
			if buildingId == BUILD_ID_CHARIOT_A then id = BUILD_ID_CHARIOT_B
			else id = BUILD_ID_CHARIOT_A end
		end
		require("app.view.ChariotInfoView").new(id, CHARIOT_FOR_PRODUCT):push()
	elseif index == FIGHT_ID_PROPS then
		local BuildingQueueView = require("app.view.BuildingQueueView")
		BuildingQueueView.new(BUILDING_FOR_ALL):push()
	end
end

function FightValueTableView:onDetailCallback(sender)
	local index = sender.index
	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	local tabStr = DetailText.fightValue[index]
	local max = UserMO.querySystemId(16)
	local change = {max}
	DetailTextDialog.new(tabStr,change):push()
end

--------------------------------------------------------------------
-- 装备更换view
--------------------------------------------------------------------

local FightValueView = class("FightValueView", UiNode)

function FightValueView:ctor()
	FightValueView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)

end

function FightValueView:onEnter()
	FightValueView.super.onEnter(self)

	-- 战斗力
	self:setTitle(CommonText[281])
	
	local ranks = RankMO.getRanksByType(1)
	if ranks then
		self:showUI()
	else
		Loading.getInstance():show()
		RankBO.asynGetRank(function()
				Loading.getInstance():unshow()
				self:showUI()
			end, 1, 1) -- 在获得的第一页中确定自己的排名
	end

	self.m_respHandler = Notify.register(LOCAL_RES_EVENT, handler(self, self.onUpdate))
	self.m_propHandler = Notify.register(LOCAL_PROP_EVENT, handler(self, self.onUpdate))
	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onUpdate))
	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onUpdate))
	self.m_partyHandler = Notify.register(LOCAL_MYPARTY_UPDATE_EVENT, handler(self, self.onUpdate))
	self.m_scienceHandler = Notify.register(LOCAL_SCIENCE_DONE_EVENT, handler(self, self.onUpdate))
end

function FightValueView:onExit()
	FightValueView.super.onExit(self)
	if self.m_respHandler then
		Notify.unregister(self.m_respHandler)
		self.m_respHandler = nil
	end
	if self.m_propHandler then
		Notify.unregister(self.m_propHandler)
		self.m_propHandler = nil
	end
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
	if self.m_partyHandler then
		Notify.unregister(self.m_partyHandler)
		self.m_partyHandler = nil
	end
	if self.m_scienceHandler then
		Notify.unregister(self.m_scienceHandler)
		self.m_scienceHandler = nil
	end
end

function FightValueView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_container = container
	end

	self.m_container:removeAllChildren()
	local container = self.m_container

	-- 当前战斗力
	local label = ui.newTTFLabel({text = CommonText[307] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = container:getContentSize().height - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = UserMO.fightValue_ .. " (" .. UiUtil.strNumSimplify(UserMO.fightValue_) .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 战斗力排名
	local label = ui.newTTFLabel({text = CommonText[416] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = container:getContentSize().height - 70, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local myRank = RankMO.getMyRankByType(1)
	if myRank == nil or myRank == 0 then  -- 未上榜
		local value = ui.newTTFLabel({text = CommonText[392], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = CommonText[417], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		desc:setAnchorPoint(cc.p(0, 0.5))
	else
		local value = ui.newTTFLabel({text = myRank, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = CommonText[417], font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		desc:setAnchorPoint(cc.p(0, 0.5))
	end

	local function gotoRank(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.RankView").new(1):push()
	end

	-- 战力榜
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoRank):addTo(container)
	btn:setPosition(container:getContentSize().width - 120, container:getContentSize().height - 60)
	btn:setLabel(CommonText[329][1])

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 120))
	bg:setPosition(container:getContentSize().width / 2, bg:getContentSize().height / 2)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 5)

	local label = ui.newTTFLabel({text = CommonText[418], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2 + 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local view = FightValueTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 156 - 4)):addTo(container)
	view:setPosition(0, 10)
	view:reloadData()
end

function FightValueView:onUpdate()
	self:showUI()
end

return FightValueView
