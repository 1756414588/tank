
-- 所有可用于改装的tank

local RefitProductTableView = class("RefitProductTableView", TableView)

function RefitProductTableView:ctor(size, buildingId)
	RefitProductTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_buildingId = buildingId
end

function RefitProductTableView:onEnter()
	RefitProductTableView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_buildLevel = BuildMO.getBuildLevel(self.m_buildingId)
	-- 战车工厂的最大等级
	self.m_chariotLevel = BuildBO.getChariotMaxLevel()
	self.m_chariotBuild = BuildMO.queryBuildById(BUILD_ID_CHARIOT_A)

	self.m_tanks = TankMO.queryCanRefitTanks()
end

function RefitProductTableView:onExit()
	RefitProductTableView.super.onExit(self)
	
	-- if self.m_tankHandler then
	-- 	Notify.unregister(self.m_tankHandler)
	-- 	self.m_tankHandler = nil
	-- end
end

function RefitProductTableView:numberOfCells()
	return #self.m_tanks
end

function RefitProductTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RefitProductTableView:createCellAtIndex(cell, index)
	RefitProductTableView.super.createCellAtIndex(self, cell, index)

	local tankDB = self.m_tanks[index]
	local refitTankDB = TankMO.queryTankById(tankDB.refitId)  -- 改装到的坦克

	-- 被改装后名称
	local name = ui.newTTFLabel({text = refitTankDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[refitTankDB.grade]}):addTo(cell)

	-- 被改装后样式
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, refitTankDB.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)

	-- 可改装数量
	local label = ui.newTTFLabel({text = CommonText[207] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_TANK, tankDB.tankId), font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	-- local _fightLabSkill = LaboratoryMO.militaryData[refitTankDB.type] and LaboratoryMO.militaryData[refitTankDB.type][refitTankDB.fightLabSkill]
	local _fightLabSkill = LaboratoryMO.militarySkillData[refitTankDB.fightLabSkill]
	local _fightLabSkillLv = _fightLabSkill and _fightLabSkill.lv or 0

	if self.m_chariotLevel >= refitTankDB.factoryLv and UserMO.level_ >= refitTankDB.lordLv and (refitTankDB.fightLabSkill == 0 or _fightLabSkillLv > 0) then -- 可以改装
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 80, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, label:getPositionY() - 30):addTo(cell)
		clock:setAnchorPoint(cc.p(0, 0.5))
		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(math.ceil(FormulaBO.tankRefitTime(BUILD_ID_REFIT, tankDB.tankId))), font = "fnt/num_2.fnt"}):addTo(cell)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

		-- 生产按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenTank))
		accelBtn.tank = tankDB
		cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	else  -- 还不能改装
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		if refitTankDB.factoryLv > 0 and refitTankDB.lordLv > 0 and refitTankDB.fightLabSkill > 0 then -- 需要战车工厂达到x级，并角色到达x级 科技激活
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_chariotBuild.name, refitTankDB.factoryLv) .. "." .. string.format(CommonText[97], CommonText[98], refitTankDB.lordLv),
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 22, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
			local skill = LaboratoryMO.queryLaboratoryForMilitarye(refitTankDB.type, refitTankDB.fightLabSkill)
			local desc2 = ui.newTTFLabel({text = CommonText[96] .. CommonText[1775] .. "[" .. skill[1].name .. "]",
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = desc:getPositionY() - 22, color = COLOR[4], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc2:setAnchorPoint(cc.p(0, 0.5))
		elseif refitTankDB.factoryLv > 0 and refitTankDB.lordLv > 0 then -- 需要战车工厂达到x级，并角色到达x级
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_chariotBuild.name, refitTankDB.factoryLv) .. "." .. string.format(CommonText[97], CommonText[98], refitTankDB.lordLv),
				font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif refitTankDB.factoryLv > 0 then -- 只需要战车工厂达到x级
			local desc = ui.newTTFLabel({text = CommonText[96] .. string.format(CommonText[97], self.m_chariotBuild.name, refitTankDB.factoryLv) .. ".", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = label:getPositionY() - 30, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	return cell
end

function RefitProductTableView:reloadData()
	local allHeight = self.m_cellSize.height * self:numberOfCells()
	local unableNum = 0
	local offsetHeight = allHeight
	local checkState = false
	for index = 1 , self:numberOfCells() do
		local tankDB = self.m_tanks[index]
		local refitTankDB = TankMO.queryTankById(tankDB.refitId)
		if checkState then
			unableNum = unableNum + 1
		end
		-- local _fightLabSkill = LaboratoryMO.militaryData[refitTankDB.type] and LaboratoryMO.militaryData[refitTankDB.type][refitTankDB.fightLabSkill]
		local _fightLabSkill = LaboratoryMO.militarySkillData[refitTankDB.fightLabSkill]
		local _fightLabSkillLv = _fightLabSkill and _fightLabSkill.lv or 0
		if not (self.m_chariotLevel >= refitTankDB.factoryLv and UserMO.level_ >= refitTankDB.lordLv and (refitTankDB.fightLabSkill == 0 or _fightLabSkillLv > 0) ) then
			checkState = true
		end
	end
	if allHeight - (unableNum * self.m_cellSize.height) < self:getViewSize().height then
		offsetHeight = allHeight - self:getViewSize().height
	else
		offsetHeight = unableNum * self.m_cellSize.height
	end
	RefitProductTableView.super.reloadData(self)
	self:setContentOffset(cc.p(0,-offsetHeight))
end

function RefitProductTableView:onChosenTank(tag, sender)
	local tank = sender.tank
	self:dispatchEvent({name = "CHOSEN_TANK_EVENT", tankId = tank.tankId})
end

return RefitProductTableView
