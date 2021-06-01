--
-- Author: gf
-- Date: 2016-05-13 14:42:07
--

local RefitM1A1TableView = class("RefitM1A1TableView", TableView)

function RefitM1A1TableView:ctor(size,activityId)
	RefitM1A1TableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_activityId = activityId
end

function RefitM1A1TableView:onEnter()
	RefitM1A1TableView.super.onEnter(self)
	local act1 = ActivityCenterMO.getA1m2ById(1)
	local act2 = ActivityCenterMO.getA1m2ById(2)
	self.m_tankFormula = {{
		from = act1.tankId,
		to = act2.tankId
	}}
end

function RefitM1A1TableView:onExit()
	RefitM1A1TableView.super.onExit(self)
end

function RefitM1A1TableView:numberOfCells()
	return #self.m_tankFormula
end

function RefitM1A1TableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RefitM1A1TableView:createCellAtIndex(cell, index)
	RefitM1A1TableView.super.createCellAtIndex(self, cell, index)

	local tankFormula = self.m_tankFormula[index]

	local tankDB = TankMO.queryTankById(tankFormula.from)  -- 材料坦克
	local refitTankDB = TankMO.queryTankById(tankFormula.to)  -- 改装到的坦克

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

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 生产按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
	local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenTank))
	accelBtn.tankFormula = tankFormula
	cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	return cell
end

function RefitM1A1TableView:onChosenTank(tag, sender)
	self:dispatchEvent({name = "CHOSEN_M1A1_EVENT", tankFormula = sender.tankFormula})
end

return RefitM1A1TableView
