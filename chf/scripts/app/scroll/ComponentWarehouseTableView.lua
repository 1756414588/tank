
-- 配件仓库中的配件和碎片TableView

local COL_NUM = 5

local ComponentWarehouseTableView = class("ComponentWarehouseTableView", TableView)

VIEW_FOR_PART = 1  -- 配件
VIEW_FOR_CHIP = 2  -- 碎片

function ComponentWarehouseTableView:ctor(size, viewFor, key)
	ComponentWarehouseTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 120)
	self.key = key
	self.m_viewFor = viewFor
	if self.m_viewFor == VIEW_FOR_PART then
		if key == "medal" then
			self.m_parts = MedalMO.getFreeMedals()
			table.sort(self.m_parts, MedalBO.sortMedal)
		elseif key == "weaponry" then
			self.m_parts = WeaponryMO.getFreeMedals()
			local function sortfunction(medalA,medalB)		
				local medalADb = WeaponryMO.queryById(medalA.equip_id)
				local medalBDb = WeaponryMO.queryById(medalB.equip_id)
				if medalADb and medalBDb and medalADb.quality > medalBDb.quality then
					return true
				elseif medalADb and medalBDb and medalADb.quality == medalBDb.quality then
					return (medalADb.id < medalBDb.id)
				else
					return false
				end
			end
			table.sort( self.m_parts, sortfunction )
			--table.sort(self.m_parts, WeaponryBO.sortMedal)
		else
			self.m_parts = PartMO.getFreeParts()
			table.sort(self.m_parts, PartBO.sortPart)
		end
	elseif self.m_viewFor == VIEW_FOR_CHIP then				-- 碎片
		if key == "medal" then								-- 勋章
			self.m_chips = MedalMO.getAllChips()
			table.sort(self.m_chips, MedalBO.sortChip)
		elseif key == "weaponry" then						-- 军备
			self.m_chips = WeaponryMO.getAllChipsByType(2)
			table.sort(self.m_chips, WeaponryBO.sortPaper)		
		else 												-- 配件
			self.m_chips = PartMO.getAllChips()
			table.sort(self.m_chips, PartBO.sortChip)
		end
	end
end

function ComponentWarehouseTableView:onEnter()
	ComponentWarehouseTableView.super.onEnter(self)
	armature_add("animation/effect/kehecheng.pvr.ccz", "animation/effect/kehecheng.plist", "animation/effect/kehecheng.xml")
end

function ComponentWarehouseTableView:onExit()
	ComponentWarehouseTableView.super.onExit(self)
	armature_remove("animation/effect/kehecheng.pvr.ccz", "animation/effect/kehecheng.plist", "animation/effect/kehecheng.xml")
end
-- function ComponentWarehouseTableView:cellTouched(cell, index)
-- 	print("OH MY GOLD index:", index)
-- end

local SHOW_GRID_LIMIT = 60

function ComponentWarehouseTableView:numberOfCells()
	if self.m_viewFor == VIEW_FOR_PART then
		if #self.m_parts > SHOW_GRID_LIMIT then
			return math.ceil(#self.m_parts / COL_NUM)
		else
			return math.ceil(60 / COL_NUM)
		end
	elseif self.m_viewFor == VIEW_FOR_CHIP then
		if #self.m_chips > SHOW_GRID_LIMIT then
			return math.ceil(#self.m_chips / COL_NUM)
		else
			return math.ceil(60 / COL_NUM)
		end
	end
end

function ComponentWarehouseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ComponentWarehouseTableView:createCellAtIndex(cell, index)
	ComponentWarehouseTableView.super.createCellAtIndex(self, cell, index)

	for numIndex = 1, COL_NUM do
		local posIndex = (index - 1) * COL_NUM + numIndex

		local normal = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
		local selected = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onComponentCallback))
		cell:addButton(btn, 14 + (numIndex - 0.5) * 120, self.m_cellSize.height / 2)

		if self.m_viewFor == VIEW_FOR_PART then
			local part = self.m_parts[posIndex]
			if part then
				btn.part = part
				local itemView = nil
				if self.key == "medal" then
					itemView = UiUtil.createItemView(ITEM_KIND_MEDAL_ICON, part.medalId, {data = part}):addTo(btn)
				elseif self.key == "weaponry" then
					itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON,part.equip_id,{data = part}):addTo(btn)
					--锁定状态icon
					local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
					lockIcon:setScale(0.5)
					lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
					lockIcon:setVisible(part.isLock)
				else
					itemView = UiUtil.createItemView(ITEM_KIND_PART, part.partId, {upLv = part.upLevel, refitLv = part.refitLevel, keyId = part.keyId}):addTo(btn)
				end
				itemView:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

				if self.key ~= "weaponry" then
					--锁定状态icon
					local lockIcon = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
					lockIcon:setScale(0.5)
					lockIcon:setPosition(itemView:getContentSize().width - lockIcon:getContentSize().width / 2 * 0.5, itemView:getContentSize().height - lockIcon:getContentSize().height / 2 * 0.5)
					lockIcon:setVisible(part.locked)
				end
				if self.key == "weaponry" and UserMO.queryFuncOpen(UFP_WEAP_CHANGE) then
					-- 星星背景
					local bg = display.newSprite(IMAGE_COMMON .. "info_bg_32.png"):addTo(itemView)
					bg:setScaleX(0.8)
					bg:setAnchorPoint(cc.p(0,0))
					bg:setPosition(0,5)
					local weapData = WeaponryMO.queryById(part.equip_id)
					local skills = PbProtocol.decodeArray(part.skillLv)
					local starNumber = math.max(weapData.normalBox,table.getn(skills))
					local posX = 10
					for index = 1 , starNumber do
						local starStr = "estar_bg.png"
						if skills[index] and skills[index].v2 >= weapData.maxSkillLevel then
							starStr = "estar.png"
						end
						--星星
						local star = display.newSprite(IMAGE_COMMON .. starStr):addTo(itemView)
						star:setAnchorPoint(cc.p(0,0.5))
						star:setPosition(posX,bg:getContentSize().height * 0.5 + 6)
						posX = star:getPositionX() + star:getContentSize().width
					end
				end
			end
		elseif self.m_viewFor == VIEW_FOR_CHIP then
			local chip = self.m_chips[posIndex]
			if chip then
				btn.chip = chip
				local itemView = nil
				if self.key == "medal" then
					itemView = UiUtil.createItemView(ITEM_KIND_MEDAL_CHIP, chip.chipId, {count = chip.count}):addTo(btn)
					local md = MedalMO.queryById(chip.chipId)
					if chip.chipId ~= MEDAL_ID_ALL_PIECE and md.chipCount > 0 and chip.count and chip.count >= md.chipCount then
						local composebg = display.newSprite(IMAGE_COMMON .. "compose.png"):addTo(itemView, 7)
						composebg:setAnchorPoint(cc.p(1,1))
						composebg:setPosition(itemView:getContentSize().width + 1, itemView:getContentSize().height + 1)
						local kehecheng = display.newSprite(IMAGE_COMMON .. "kehecheng.png"):addTo(composebg)
						kehecheng:setAnchorPoint(cc.p(0.5,0.5))
						kehecheng:setPosition(composebg:getContentSize().width *0.5 + 7, composebg:getContentSize().height *0.5 + 7)
						local compose = armature_create("kehecheng"):addTo(itemView,8)
						compose:setAnchorPoint(cc.p(0.5,0.5))
						compose:setPosition(itemView:getContentSize().width * 0.5 , itemView:getContentSize().width * 0.5 - 2)
						compose:getAnimation():playWithIndex(0)
					end
				elseif self.key == "weaponry" then
					itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER, chip.propId, {count = chip.count}):addTo(btn)
				else
					itemView = UiUtil.createItemView(ITEM_KIND_CHIP, chip.chipId, {count = chip.count}):addTo(btn)
					local pt = PartMO.queryPartById(chip.chipId)
					if chip.chipId ~= PART_ID_ALL_PIECE and pt.chipCount > 0 and chip.count and chip.count >= pt.chipCount then
						local composebg = display.newSprite(IMAGE_COMMON .. "compose.png"):addTo(itemView, 7)
						composebg:setAnchorPoint(cc.p(1,1))
						composebg:setPosition(itemView:getContentSize().width + 1, itemView:getContentSize().height + 1)
						local kehecheng = display.newSprite(IMAGE_COMMON .. "kehecheng.png"):addTo(composebg)
						kehecheng:setAnchorPoint(cc.p(0.5,0.5))
						kehecheng:setPosition(composebg:getContentSize().width *0.5 + 7, composebg:getContentSize().height *0.5 + 7)
						local compose = armature_create("kehecheng"):addTo(itemView,8)
						compose:setAnchorPoint(cc.p(0.5,0.5))
						compose:setPosition(itemView:getContentSize().width * 0.5 , itemView:getContentSize().width * 0.5 - 2)
						compose:getAnimation():playWithIndex(0)
					end
				end
				itemView:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
			end
		end
	end

	return cell
end

function ComponentWarehouseTableView:onComponentCallback(tag, sender)
	if self.m_viewFor == VIEW_FOR_PART then
		local part = sender.part
		if part then
			if self.key == "medal" then
				require("app.dialog.MedalDialog").new(part.keyId):push()
			elseif self.key == "weaponry" then
				require("app.dialog.WeaponryDialog").new(part):push()
			else
				require("app.dialog.ComponentDialog").new(part.keyId):push()
			end
		end
	elseif self.m_viewFor == VIEW_FOR_CHIP then
		local chip = sender.chip
		if chip then
			if self.key == "medal" then
				require("app.dialog.MedalChipDialog").new(chip.chipId):push()
			elseif self.key == "weaponry" then
				require("app.dialog.WeaponryPaperDialog").new(chip.propId):push()
			else
				print("=======")
				require("app.dialog.ChipDialog").new(chip.chipId):push()
			end
		end
	end
end

return ComponentWarehouseTableView
