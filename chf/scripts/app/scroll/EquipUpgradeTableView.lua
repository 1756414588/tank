
-- 装备升级tableview，用于可以被吸收的装备

local EquipUpgradeTableView = class("EquipUpgradeTableView", TableView)

-- keyId: 需要升级的装备keyId
function EquipUpgradeTableView:ctor(size, keyId)
	EquipUpgradeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	local function orderEquip(equipA, equipB)
		local posA = EquipMO.getPosByEquipId(equipA.equipId)
		local posB = EquipMO.getPosByEquipId(equipB.equipId)
		if posA == 0 and posB == 0 then  -- 都是经验
			local equipDbA = EquipMO.queryEquipById(equipA.equipId)
			if not equipDbA then return false end
			local equipDbB = EquipMO.queryEquipById(equipB.equipId)
			if not equipDbB then return false end
			if equipDbA.a < equipDbB.a then  -- a比b的经验值高
				return true
			elseif equipDbA.a == equipDbB.a then
				if equipA.keyId < equipB.keyId then return true
				else return false end
			else
				return false
			end
		elseif posA == 0 and posB ~= 0 then
			return true
		elseif posA ~= 0 and posB == 0 then
			return false
		else -- a和b都不是经验，都是装备
			local equipDbA = EquipMO.queryEquipById(equipA.equipId)
			if not equipDbA then return false end
			local equipDbB = EquipMO.queryEquipById(equipB.equipId)
			if not equipDbB then return false end
			if equipDbA.quality < equipDbB.quality then
				return true
			elseif equipDbA.quality == equipDbB.quality then
				if equipA.level < equipB.level then
					return true
				elseif equipA.level == equipB.level then
					if posA < posB then
						return true
					elseif posA == posB then
						if equipA.exp < equipB.exp then
							return true
						elseif equipA.exp == equipB.exp then
							if equipA.keyId < equipB.keyId then return true
							else return false end
						else
							return false
						end
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		end
	end

	self.m_equips = EquipMO.getCanUseUpgradeEqups(keyId)
	table.sort(self.m_equips, orderEquip)

	-- 表示每个cell中的checkbox是否被选中
	self.m_chosenData = {}
end

function EquipUpgradeTableView:numberOfCells()
	return #self.m_equips
end

function EquipUpgradeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function EquipUpgradeTableView:createCellAtIndex(cell, index)
	EquipUpgradeTableView.super.createCellAtIndex(self, cell, index)

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
	else
		-- 装备升级材料：提供xx经验值
		local label = ui.newTTFLabel({text = string.format(CommonText[208], equipDB.a), font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	local checkBox = CellCheckBox.new(nil, nil, handler(self, self.onCheckedChanged))
	checkBox.cellIndex = index
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	cell:addButton(checkBox, self.m_cellSize.width - 90, self.m_cellSize.height / 2 - 22)

	if self.m_chosenData[index] then
		checkBox:setChecked(true)
	end

	cell.checkBox = checkBox

	-- EXP
	local label = ui.newTTFLabel({text = "EXP", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 160, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local expValue = 0
	if equipPos == 0 then
		expValue = equipDB.a
	else
		local equipLevel = EquipMO.queryEquipLevel(equipDB.quality, equip.level)
		if equipLevel then
			expValue = equipLevel.giveExp + equip.exp
		else
			expValue = equip.exp
		end
	end

	if equipPos == 0 and ActivityBO.isValid(ACTIVITY_ID_EQUIP_UP_CRIT) then
		expValue = math.floor(expValue * (1 + ACTIVITY_EQUIP_CRIT_RATE))
	else
		expValue = expValue
	end

	local value = ui.newTTFLabel({text = "+" .. expValue, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	value:setAnchorPoint(cc.p(0, 0.5))

	return cell
end

function EquipUpgradeTableView:cellTouched(cell, index)
	self.m_chosenData[index] = not self.m_chosenData[index]
	cell.checkBox:setChecked(self.m_chosenData[index])

	self:dispatchEvent({name = "CHECK_EQUIP_EVENT", index = index})
end

function EquipUpgradeTableView:onCheckedChanged(sender, isChecked)
	local index = sender.cellIndex

	self.m_chosenData[index] = isChecked
	self:dispatchEvent({name = "CHECK_EQUIP_EVENT", index = index})
end

-- quality:某种品质的装备全部被选中，为nil表示全部装备
function EquipUpgradeTableView:checkAll(quality, isChecked)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local equip = self.m_equips[index]
		local equipDB = EquipMO.queryEquipById(equip.equipId)
		local pos = EquipMO.getPosByEquipId(equip.equipId)

		if equipDB then
			if ((quality == nil or equipDB.quality == quality) and pos == 0) or (equipDB.quality < 3 and (quality == nil or equipDB.quality == quality)) then
				self.m_chosenData[index] = isChecked

				local cell = self:cellAtIndex(index)
				if cell and cell.checkBox then
					cell.checkBox:setChecked(isChecked)
				end
			end
		end
	end
end

-- 获得勾选上的数量和价格信息
function EquipUpgradeTableView:getCheckedExp()
	local exp = 0

	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		if self.m_chosenData[index] then -- 选中了
			local equip = self.m_equips[index]
			local equipDB = EquipMO.queryEquipById(equip.equipId)
			local equipPos = EquipMO.getPosByEquipId(equip.equipId)

			if equipPos == 0 then
				if ActivityBO.isValid(ACTIVITY_ID_EQUIP_UP_CRIT) then
					exp = exp + math.floor(equipDB.a * (1 + ACTIVITY_EQUIP_CRIT_RATE))
				else
					exp =  exp + equipDB.a
				end
			else
				exp = exp + EquipMO.queryEquipLevel(equipDB.quality, equip.level).giveExp + equip.exp
			end
		end
	end

	return exp
end

function EquipUpgradeTableView:getCheckedEquips()
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

return EquipUpgradeTableView
