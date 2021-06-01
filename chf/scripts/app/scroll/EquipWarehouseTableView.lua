
-- 装备仓库tableview，用于显示装备列表、装备出售列表

local EquipWarehouseTableView = class("EquipWarehouseTableView", TableView)

-- status: 1表示显示列表，2表示显示出售
function EquipWarehouseTableView:ctor(size, status)
	EquipWarehouseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_equips = EquipMO.getFreeEquipsAtPos()
	table.sort(self.m_equips, EquipBO.orderEquip)

	self.m_status = status
	-- 表示每个cell中的checkbox是否被选中
	self.m_chosenData = {}

	gdump(self.m_equips, "[EquipWarehouseTableView]")
end

function EquipWarehouseTableView:numberOfCells()
	return #self.m_equips
end

function EquipWarehouseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EquipWarehouseTableView:createCellAtIndex(cell, index)
	EquipWarehouseTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local equip = self.m_equips[index]
	local equipDB = EquipMO.queryEquipById(equip.equipId)
	if not equipDB then return cell end
	
	local equipPos = EquipMO.getPosByEquipId(equip.equipId)

	local itemView = UiUtil.createItemView(ITEM_KIND_EQUIP, equip.equipId, {equipLv = equip.level, star = equip.starLv}):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(itemView, cell, true)

	-- 名称
	local name = ui.newTTFLabel({text = EquipBO.getEquipNameById(equip.equipId), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[equipDB.quality]}):addTo(cell)
		
	if equipPos ~= 0 then
		-- local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level)
		local attrData = EquipBO.getEquipAttrData(equip.equipId, equip.level, equip.starLv)

		local label = ui.newTTFLabel({text = attrData.name .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "+" .. attrData.strValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		value:setAnchorPoint(cc.p(0, 0.5))

		-- 每级增加部队
		local attrB = AttributeBO.getAttributeData(attrData.id, equipDB.b)
		local desc = ui.newTTFLabel({text = string.format(CommonText[128], attrB.strValue, attrData.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))
	else
		-- 装备升级材料：提供xx经验值
		local label = ui.newTTFLabel({text = string.format(CommonText[208], equipDB.a), font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	if self.m_status == 1 then
		local function onUpgradeCallback(tag, sender)
			require("app.view.EquipUpgradeView").new(sender.equip.keyId):push()
		end
		
		if equipPos ~= 0 then  -- 是装备可以装备升级的
			local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
			local upgradeBtn = CellMenuButton.new(normal, selected, nil, onUpgradeCallback)
			upgradeBtn:setLabel(CommonText[79])
			upgradeBtn.equip = equip
			cell:addButton(upgradeBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
		end
	elseif self.m_status == 2 then  -- 用于出售
		-- 全选
		local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
		checkBox.cellIndex = index
		checkBox:setAnchorPoint(cc.p(0, 0.5))
		cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 22)

		if self.m_chosenData[index] then
			checkBox:setChecked(true)
		end

		cell.checkBox = checkBox

		-- 宝石价格
		local gemTag = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(cell)
		gemTag:setPosition(self.m_cellSize.width - 120, 114)

		local gem = ui.newBMFontLabel({text = UiUtil.strNumSimplify(equipDB.price), font = "fnt/num_2.fnt", x = gemTag:getPositionX() + gemTag:getBoundingBox().size.width / 2, y = gemTag:getPositionY()}):addTo(gemTag:getParent())
		gem:setAnchorPoint(cc.p(0, 0.5))
	end

	return cell
end

function EquipWarehouseTableView:onCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	local index = sender.cellIndex

	self.m_chosenData[index] = isChecked
	self:dispatchEvent({name = "CHECK_EQUIP_EVENT", index = index})
end

function EquipWarehouseTableView:checkAll(isChecked)
	if self.m_status ~= 2 then return end

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		self.m_chosenData[index] = isChecked

		local cell = self:cellAtIndex(index)
		if cell and cell.checkBox then
			cell.checkBox:setChecked(isChecked)
		end
	end
end

-- 获得勾选上的数量和价格信息
function EquipWarehouseTableView:getCheckedNumPrice()
	local ret = {}
	ret.num = 0
	ret.total = 0

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			local equip = self.m_equips[index]
			local equipDB = EquipMO.queryEquipById(equip.equipId)

			ret.num = ret.num + 1
			ret.total = ret.total + equipDB.price
		end
	end
	return ret
end

function EquipWarehouseTableView:getCheckedEquips()
	local ret = {}
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			local equip = self.m_equips[index]
			ret[#ret + 1] = equip
		end
	end
	return ret
end

return EquipWarehouseTableView