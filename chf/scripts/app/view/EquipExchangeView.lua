
--------------------------------------------------------------------
-- 装备更换view中空闲的装备TableView
--------------------------------------------------------------------

local EquipTableView = class("EquipTableView", TableView)

-- 所有可装备的空闲装备
function EquipTableView:ctor(size, formatPosition, equipPos)
	EquipTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)

	self.m_formatPosition = formatPosition
	self.m_equipPos = EquipMO.getFreeEquipsAtPos(equipPos)
end

function EquipTableView:numberOfCells()
	return #self.m_equipPos
end

function EquipTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EquipTableView:createCellAtIndex(cell, index)
	EquipTableView.super.createCellAtIndex(self, cell, index)

	local equip = self.m_equipPos[index]
	local equipDB = EquipMO.queryEquipById(equip.equipId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView, cell, true)

	-- 名称
	local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[equipDB.quality]}):addTo(cell)

	-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)
	local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)
	local label = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)
	-- 每级增加部队
	local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	desc:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local equipBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onEquipCallback))
	equipBtn.equip = equip
	equipBtn:setLabel(CommonText[7])
	cell:addButton(equipBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)

	return cell
end

function EquipTableView:onEquipCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local equip = sender.equip
	self:dispatchEvent({name = "CHOSEN_EQUIP_EVENT", keyId = equip.keyId})
end

--------------------------------------------------------------------
-- 装备更换view
--------------------------------------------------------------------

local EquipExchangeView = class("EquipExchangeView", UiNode)

function EquipExchangeView:ctor(formatPosition, equipPos)
	EquipExchangeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	self.m_formatPosition = formatPosition
	self.m_equipPos = equipPos
end

function EquipExchangeView:onEnter()
	EquipExchangeView.super.onEnter(self)
	
	self:setTitle(CommonText[7] .. CommonText[133])  -- 装备更换
	
	self:showUI()
end

function EquipExchangeView:showUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 +  container:getContentSize().height / 2)
		container:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_container = container
	end

	self.m_container:removeAllChildren()
	local container = self.m_container

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container, 2)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(container:getContentSize().width / 2, container:getContentSize().height - (156 + line:getContentSize().height / 2))

	local title = ui.newTTFLabel({text = string.format(CommonText[127], self.m_formatPosition), font = G_FONT, size = FONT_SIZE_TINY,
		x = container:getContentSize().width / 2, y = container:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER}):addTo(container)

	if EquipBO.hasEquipAtPos(self.m_formatPosition, self.m_equipPos) then -- 有装备
		local equip = EquipBO.getEquipAtPos(self.m_formatPosition, self.m_equipPos)
		local equipDB = EquipMO.queryEquipById(equip.equipId)

		itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(container)
		itemView:setPosition(95, container:getContentSize().height - 90)
		UiUtil.createItemDetailButton(itemView)

		local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_MEDIUM, x = 160, y = container:getContentSize().height - 60, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		name:setAnchorPoint(cc.p(0, 0.5))

		-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)
		local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)

		local label = ui.newTTFLabel({text = attrData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		value:setAnchorPoint(cc.p(0, 0.5))

		local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)
		-- 每级增加部队
		local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		desc:setAnchorPoint(cc.p(0, 0.5))

		self:showExchange()
	else -- 无装备
		local desc = ui.newTTFLabel({text = CommonText[129], font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = container:getContentSize().height - 85, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		self:showBags()
	end
end

-- 显示装备用于交换
function EquipExchangeView:showExchange()
	-- self.m_exchangePositoin = 0 -- 当前交换到的阵型位置索引
	self.m_exchangeFormation = EquipBO.getEquipFormationAtPos(self.m_equipPos)

	local function showChosen()  -- 显示当前选中的位置的装备
		if self.m_exchangeEquipNode.itemView then
			self.m_exchangeEquipNode.itemView:removeSelf()
			self.m_exchangeEquipNode.itemView = nil
		end

		local position = self.m_exchangeFormatView:getChosenPosition()
		local keyId = self.m_exchangeFormation[position]

		if keyId > 0 then -- 有装备
			local equip = EquipMO.getEquipByKeyId(keyId)
			local equipDB = EquipMO.queryEquipById(equip.equipId)

			local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(self.m_exchangeEquipNode)
			itemView:setPosition(self.m_exchangeEquipNode:getContentSize().width / 2, self.m_exchangeEquipNode:getContentSize().height / 2 + 2)
			itemView:setScale(1.24)
			self.m_exchangeEquipNode.itemView = itemView

			local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getContentSize().width / 2, y = -20, color = COLOR[equipDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
		end

		-- if self.m_formatPosition ~= position then  -- 两个位置需要交换
			-- print("要交换了")
			local format = clone(self.m_exchangeFormation)
			local tmpKeyId = format[self.m_formatPosition]
			format[self.m_formatPosition] = format[position]
			format[position] = tmpKeyId
			self.m_exchangeFormatView:updateUI(format)
		-- end
	end

	local function chosenFormation(event)
		local position = event.pos
		gprint("[EquipExchangeView] chosenFormation position:", position)
		-- self.m_exchangePositoin = position
		showChosen()
	end

	local node = display.newNode():addTo(self.m_container)
	node:setContentSize(cc.size(self.m_container:getContentSize().width, self.m_container:getContentSize().height - 170))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self.m_container:getContentSize().width / 2, node:getContentSize().height / 2)

	-- 当前装备背景框
	local normal = display.newSprite(IMAGE_COMMON .. "btn_position_normal.png"):addTo(node)
	normal:setPosition(node:getContentSize().width / 2, node:getContentSize().height - 80)
	normal:setScale(0.78)
	self.m_exchangeEquipNode = normal

	local selected = display.newSprite(IMAGE_COMMON .. "chose_1.png"):addTo(normal)
	selected:setPosition(selected:getContentSize().width / 2 + 4, selected:getContentSize().height / 2 + 8)

	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(node)
	formatBg:setPreferredSize(cc.size(node:getContentSize().width - 12 - 50, 370))
	formatBg:setPosition(node:getContentSize().width / 2, node:getContentSize().height - 180 - formatBg:getContentSize().height / 2)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 24, 280):addTo(formatBg)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 24, 105):addTo(formatBg)

	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_EQUIP_ITEM, self.m_exchangeFormation, TankBO.getMyFormationLockData()):addTo(formatBg, 10)
	view:addEventListener("FORMATION_CHOSEN_EVENT", chosenFormation)
	view:setDragEnabled(false)
	view:setScale(0.78)
	view:updateOffset(cc.p(54, 60))
	view:setPosition(formatBg:getContentSize().width / 2, 40)
	view:onBeganPosition(self.m_formatPosition)
	self.m_exchangeFormatView = view

	showChosen()

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, handler(self, self.onExchangeEquip)):addTo(node)
	okBtn:setPosition(node:getContentSize().width / 2, 50)
	okBtn:setLabel(CommonText[1])
end

function EquipExchangeView:showBags()
	local node = display.newNode():addTo(self.m_container)
	node:setContentSize(cc.size(self.m_container:getContentSize().width, self.m_container:getContentSize().height - 170))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self.m_container:getContentSize().width / 2, node:getContentSize().height / 2)

	local view = EquipTableView.new(cc.size(node:getContentSize().width, node:getContentSize().height), self.m_formatPosition, self.m_equipPos):addTo(node)
	view:addEventListener("CHOSEN_EQUIP_EVENT", handler(self, self.onChosenEquip))
	view:setPosition(0, 0)
	view:reloadData()
end

function EquipExchangeView:onChosenEquip(event)

	local keyId = event.keyId

	local function doneEquip()
		Loading.getInstance():unshow()
		Toast.show(CommonText[447]) -- 装备成功
		self:pop()
		-- self:showUI()
	end
	Loading.getInstance():show()
	EquipBO.asynEquip(doneEquip, keyId, 0, self.m_formatPosition)
end

function EquipExchangeView:onExchangeEquip(tag, sender)
	gprint("EquipExchangeView:onExchangeEquip")
	local position = self.m_exchangeFormatView:getChosenPosition()
	if self.m_formatPosition == position then  -- 不需要交换
		Toast.show(CommonText[470]) -- 请选择要交换到的新位置
		return
	end

	local function doneEquip()
		Toast.show(CommonText[448])  -- 交换成功

		self:showUI()
		Loading.getInstance():unshow()
	end
	Loading.getInstance():show()
	local keyId = EquipMO.getKeyIdAtPos(self.m_formatPosition, self.m_equipPos)
	EquipBO.asynEquip(doneEquip, keyId, self.m_formatPosition, position)
end

return EquipExchangeView
