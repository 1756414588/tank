
-- 修理坦克

local ArmyRepairTableView = class("ArmyRepairTableView", TableView)

function ArmyRepairTableView:ctor(size, repairTanks, cost)
	ArmyRepairTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 144)

	self.m_tanks = repairTanks
	self.m_cost = cost
	-- gdump(self.m_tanks, "ArmyRepairTableView ctor tank")
	-- gdump(self.m_cost, "ArmyRepairTableView ctro cost")
end

function ArmyRepairTableView:numberOfCells()
	return #self.m_tanks
end

function ArmyRepairTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArmyRepairTableView:createCellAtIndex(cell, index)
	ArmyRepairTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local tank = self.m_tanks[index]
	local tankDB = TankMO.queryTankById(tank.tankId)

	local cost = self.m_cost[index]

	-- 名称
	local name = ui.newTTFLabel({text = tankDB.name .. "*" .. tank.rest, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[tankDB.grade]}):addTo(cell)

	--
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)

	local coinTag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(bg)
	coinTag:setPosition(self.m_cellSize.width - 280, 112)

	local coin = ui.newBMFontLabel({text = UiUtil.strNumSimplify(cost.coin), font = "fnt/num_2.fnt", x = coinTag:getPositionX() + coinTag:getContentSize().width / 2, y = coinTag:getPositionY()}):addTo(bg)
	coin:setAnchorPoint(cc.p(0, 0.5))

	-- 金币修复按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local coinBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRepairCallback))
	coinBtn.status = 2
	coinBtn.tank = tank
	coinBtn.cost = cost
	coinBtn:setLabel(CommonText[30])
	cell:addButton(coinBtn, self.m_cellSize.width - 280, self.m_cellSize.height / 2 - 22)

	--
	local gemTag = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(bg)
	gemTag:setPosition(self.m_cellSize.width - 120, coinTag:getPositionY())

	local gem = ui.newBMFontLabel({text = UiUtil.strNumSimplify(cost.gem), font = "fnt/num_2.fnt", x = gemTag:getPositionX() + gemTag:getBoundingBox().size.width / 2, y = gemTag:getPositionY()}):addTo(gemTag:getParent())
	gem:setAnchorPoint(cc.p(0, 0.5))

	-- 宝石按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local repairBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRepairCallback))
	repairBtn.status = 1
	repairBtn.tank = tank
	repairBtn.cost = cost
	repairBtn:setLabel(CommonText[30])
	cell:addButton(repairBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	return cell
end

function ArmyRepairTableView:onRepairCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local status = sender.status
	local tank = sender.tank
	local cost = sender.cost

	self:dispatchEvent({name = "REPAIR_TANK_EVENT", tankId = tank.tankId, status = status, cost = cost})
end

return ArmyRepairTableView
