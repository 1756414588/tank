
-- 所有可用于生产的tank

local ArmyProductTableView = class("ArmyProductTableView", TableView)

-- buildingId: 通过buildingId确定是哪个战车工厂，已确定哪些tank可以生产
function ArmyProductTableView:ctor(size, buildingId)
	ArmyProductTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_buildingId = buildingId
end

function ArmyProductTableView:onEnter()
	ArmyProductTableView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_buildLevel = BuildMO.getBuildLevel(self.m_buildingId)
	self.m_tanks = TankMO.queryCanBuildTanks()

	-- print("buildingId:", self.m_buildingId)
	-- dump(self.m_build)
	self.m_tankHandler = Notify.register(LOCAL_TANK_EVENT, handler(self, self.onTankUpdate))
end

function ArmyProductTableView:onExit()
	ArmyProductTableView.super.onExit(self)
	
	if self.m_tankHandler then
		Notify.unregister(self.m_tankHandler)
		self.m_tankHandler = nil
	end
end

function ArmyProductTableView:numberOfCells()
	return #self.m_tanks
end

function ArmyProductTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArmyProductTableView:createCellAtIndex(cell, index)
	ArmyProductTableView.super.createCellAtIndex(self, cell, index)

	local tankDB = self.m_tanks[index]

	-- 名称
	local name = ui.newTTFLabel({text = tankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[tankDB.grade]}):addTo(cell)

	--
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)

	-- 当前数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_TANK, tankDB.tankId), font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	-- local _fightLabSkill = LaboratoryMO.militaryData[tankDB.type] and LaboratoryMO.militaryData[tankDB.type][tankDB.fightLabSkill]
	local _fightLabSkill = LaboratoryMO.militarySkillData[tankDB.fightLabSkill]
	local _fightLabSkillLv = _fightLabSkill and _fightLabSkill.lv or 0

	if self.m_buildLevel >= tankDB.factoryLv and UserMO.level_ >= tankDB.lordLv and (tankDB.fightLabSkill == 0 or _fightLabSkillLv > 0) then  -- 可以生产
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 80, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, label:getPositionY() - 30):addTo(cell)
		clock:setAnchorPoint(cc.p(0, 0.5))
		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(math.ceil(FormulaBO.tankBuildTime(self.m_build.buildingId, tankDB.tankId))), font = "fnt/num_2.fnt"}):addTo(cell)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

		-- 生产按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenTank))
		accelBtn.tank = tankDB
		cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	else  -- 还不能生产
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		if tankDB.factoryLv > 0 and tankDB.lordLv > 0 and tankDB.fightLabSkill > 0 then -- 需要战车工厂达到x级，并角色到达x级 科技激活
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_build.name, tankDB.factoryLv) .. "." .. string.format(CommonText[97], CommonText[98], tankDB.lordLv),
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 22, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
			local skill = LaboratoryMO.queryLaboratoryForMilitarye(tankDB.type, tankDB.fightLabSkill)
			local desc2 = ui.newTTFLabel({text = CommonText[96] .. CommonText[1775] .. "[" .. skill[1].name .. "]",
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = desc:getPositionY() - 22, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc2:setAnchorPoint(cc.p(0, 0.5))
		elseif tankDB.factoryLv > 0 and tankDB.lordLv > 0 then -- 需要战车工厂达到x级，并角色到达x级
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_build.name, tankDB.factoryLv) .. "." .. string.format(CommonText[97], CommonText[98], tankDB.lordLv),
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif tankDB.factoryLv > 0 then -- 只需要战车工厂达到x级
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_build.name, tankDB.factoryLv) .. ".", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	return cell
end

function ArmyProductTableView:reloadData()
	local allHeight = self.m_cellSize.height * self:numberOfCells()
	local unableNum = 0
	local offsetHeight = allHeight
	local checkState = false
	for index = 1 , self:numberOfCells() do
		local tankDB = self.m_tanks[index]
		if checkState then
			unableNum = unableNum + 1
		end
		-- local _fightLabSkill = LaboratoryMO.militaryData[tankDB.type] and LaboratoryMO.militaryData[tankDB.type][tankDB.fightLabSkill]
		local _fightLabSkill = LaboratoryMO.militarySkillData[tankDB.fightLabSkill]
		local _fightLabSkillLv = _fightLabSkill and _fightLabSkill.lv or 0
		if not (self.m_buildLevel >= tankDB.factoryLv and UserMO.level_ >= tankDB.lordLv and (tankDB.fightLabSkill == 0 or _fightLabSkillLv > 0) ) then
			checkState = true
		end
	end
	if allHeight - (unableNum * self.m_cellSize.height) < self:getViewSize().height then
		offsetHeight = allHeight - self:getViewSize().height
	else
		offsetHeight = unableNum * self.m_cellSize.height
	end
	ArmyProductTableView.super.reloadData(self)
	self:setContentOffset(cc.p(0,-offsetHeight))
end

function ArmyProductTableView:onChosenTank(tag, sender)
	ManagerSound.playNormalButtonSound()
	local tank = sender.tank
	self:dispatchEvent({name = "PRODUCT_TANK_EVENT", tankId = tank.tankId})
end

function ArmyProductTableView:onTankUpdate(event)
	self:reloadData()
end

return ArmyProductTableView
