--
-- Author: gf
-- Date: 2015-09-07 15:14:43
--

local EnergyInsetTableView = class("EnergyInsetTableView", TableView)

function EnergyInsetTableView:ctor(size, energyspars)
	EnergyInsetTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_energyspars = energyspars
end

function EnergyInsetTableView:onEnter()
	EnergyInsetTableView.super.onEnter(self)
end

function EnergyInsetTableView:numberOfCells()
	return #self.m_energyspars
end

function EnergyInsetTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EnergyInsetTableView:createCellAtIndex(cell, index)
	EnergyInsetTableView.super.createCellAtIndex(self, cell, index)

	local spar = self.m_energyspars[index]
	local sparDB = EnergySparMO.queryEnergySparById(spar.stoneId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local bagView = UiUtil.createItemView(ITEM_KIND_ENERGY_SPAR, spar.stoneId, {count = spar.count}):addTo(cell)
	bagView:setPosition(60, self.m_cellSize.height / 2)
	-- UiUtil.createItemDetailButton(bagView, cell, true)

	-- 名称
	local name = ui.newTTFLabel({text = string.format("%sLv.%d", sparDB.stoneName, sparDB.level), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[sparDB.quite]}):addTo(cell)

	local attr = AttributeBO.getAttributeData(sparDB.attrId, sparDB.attrValue)
	-- attr.name ..CommonText[176]
	-- (attr.value > 0 and "+" or "-") .. attr.strValue

	local desc = string.format("%s%s%s%s", attr.name, CommonText[176], (attr.value > 0 and "+" or "-"), attr.strValue)
	local desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = spar.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	-- 使用按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback))
	btn:setLabel(CommonText[942])
	btn.stoneId = spar.stoneId
	-- btn.itemView = bagView
	btn.sparLabel = count
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	return cell
end

function EnergyInsetTableView:onBtnCallback( tag, sender )
	self:dispatchEvent({name="INSET_ENERGYSPAR", stoneId = sender.stoneId})
end

function EnergyInsetTableView:onExit()
	EnergyInsetTableView.super.onExit(self)
end

return EnergyInsetTableView