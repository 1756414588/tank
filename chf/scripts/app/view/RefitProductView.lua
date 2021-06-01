
--------------------------------------------------------------------
-- 坦克改装消耗资源TableView
--------------------------------------------------------------------

local itemKind = {RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER, RESOURCE_ID_SILICON} -- 铁、石油、铜、硅

local RefitResTableView = class("RefitResTableView", TableView)

-- tankId: 需要进行改装的tank
function RefitResTableView:ctor(size, tankId)
	RefitResTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)
	self.m_cellNum = 5
	self.m_tankDB = TankMO.queryTankById(tankId)

	-- 改装到的坦克
	self.m_refitTankDB = TankMO.queryTankById(self.m_tankDB.refitId)

	self.m_assistItem = {}
	self.m_assistItem[1] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_IRON}
	self.m_assistItem[2] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_OIL}
	self.m_assistItem[3] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_COPPER}
	self.m_assistItem[4] = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_SILICON}

	if self.m_refitTankDB.drawing > 0 then  -- 改装到的tank需要图纸
		self.m_assistItem[#self.m_assistItem + 1] = {kind = ITEM_KIND_PROP, id = self.m_refitTankDB.drawing}
	end

	if self.m_refitTankDB.book > 0 then  -- 需要技能书
		self.m_assistItem[#self.m_assistItem + 1] = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK}
	end

	self.m_assistItem[#self.m_assistItem + 1] = {kind = ITEM_KIND_TANK, id = self.m_tankDB.tankId}

	self.m_curProductNum = 0
end

function RefitResTableView:numberOfCells()
	return #self.m_assistItem
end

function RefitResTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function RefitResTableView:createCellAtIndex(cell, index)
	RefitResTableView.super.createCellAtIndex(self, cell, index)

	local item = self.m_assistItem[index]

	local view = UiUtil.createItemView(item.kind, item.id):addTo(cell)
	view:setPosition(74, self.m_cellSize.height / 2)
	view:setScale(0.65)

	-- 类别
	local resData = UserMO.getResourceData(item.kind, item.id)
	local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setColor(COLOR[11])
	cell.nameLabel = name

	-- 需求
	local labelN = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = 303, y = self.m_cellSize.height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	cell.needLabel = labelN

	-- 当前拥有
	local labelC = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = 430, y = self.m_cellSize.height / 2}):addTo(cell)
	labelC:setAnchorPoint(cc.p(0, 0.5))
	cell.haslabel = labelC

	local gou = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 410, self.m_cellSize.height / 2):addTo(cell)
	cell.gouView = gou

	local cha = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 410, self.m_cellSize.height / 2):addTo(cell)
	cell.chaView = cha

	if index ~= 1 then -- 两行之间的横线
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
		line:setPreferredSize(cc.size(554, line:getContentSize().height))
		line:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 + 40)
	end

	self:updateCell(cell, index)

	local function onUseCallback(tag, sender)  -- 物品使用弹出框
		ManagerSound.playNormalButtonSound()
		local index = sender.index
		if self.m_assistItem[index].kind == ITEM_KIND_RESOURCE then
			require("app.dialog.ItemUseDialog").new(ITEM_KIND_RESOURCE, self.m_assistItem[index].id):push()
		elseif self.m_assistItem[index].kind == ITEM_KIND_PROP then
			UiDirector.pop(function() require("app.view.BagView").new(BAG_VIEW_FOR_SHOP):push() end)
		elseif self.m_assistItem[index].kind == ITEM_KIND_TANK then
			UiDirector.pop(function() require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A, 2):push() end)
		end
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, onUseCallback)
	btn:setScale(0.9)
	btn.index = index
	cell:addButton(btn, 560, self.m_cellSize.height / 2)

	return cell
end

function RefitResTableView:updateCell(cell, cellIndex)
	local item = self.m_assistItem[cellIndex]

	local need = 0
	if cellIndex == 1 then need = self.m_refitTankDB.iron - self.m_tankDB.iron -- 铁
	elseif cellIndex == 2 then need = self.m_refitTankDB.oil - self.m_tankDB.oil
	elseif cellIndex == 3 then need = self.m_refitTankDB.copper - self.m_tankDB.copper
	elseif cellIndex == 4 then need = self.m_refitTankDB.silicon - self.m_tankDB.silicon
	elseif cellIndex == self:numberOfCells() then need = 1  -- tank
	else
		if item.kind == ITEM_KIND_PROP and item.id == self.m_refitTankDB.drawing then  -- 需要道具图纸
			need = 1
		elseif item.kind == ITEM_KIND_PROP and item.id == PROP_ID_SKILL_BOOK then
			need = self.m_refitTankDB.book
		end
	end

	need = need * self.m_curProductNum

	local count = UserMO.getResource(item.kind, item.id)

	cell.needLabel:setString(UiUtil.strNumSimplify(need))
	cell.haslabel:setString(UiUtil.strNumSimplify(count))

	if need <= count then -- 足够
		cell.gouView:setVisible(true)
		cell.chaView:setVisible(false)
		cell.nameLabel:setColor(COLOR[11])
		cell.needLabel:setColor(COLOR[11])
	else -- 不足够
		cell.gouView:setVisible(false)
		cell.chaView:setVisible(true)
		cell.nameLabel:setColor(COLOR[6])
		cell.needLabel:setColor(COLOR[6])
	end
end

function RefitResTableView:setCurProductNum(num)
	self.m_curProductNum = num

	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			self:updateCell(cell, index)
		end
	end
end

------------------------------------------------------------------------------
-- 坦克改装view
------------------------------------------------------------------------------

local RefitProductView = class("RefitProductView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

-- tankId: 需要改装的tank
function RefitProductView:ctor(buildingId, tankId)
	-- 大小和多标签页一样
	self:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	gprint("[RefitProductView] build id:", buildingId, tankId)
	self.m_buildingId = buildingId
	self.m_tankId = tankId
end

function RefitProductView:onEnter()
	self:showUI()

	self.m_resHandler = Notify.register(LOCAL_RES_EVENT, handler(self, self.onResUpdate))
end

function RefitProductView:onExit()
	if self.m_resHandler then
		Notify.unregister(self.m_resHandler)
		self.m_resHandler = nil
	end
end

function RefitProductView:showUI()
	local container = self

	local tankDB = TankMO.queryTankById(self.m_tankId)
	self.m_tank = tankDB
	local refitTank = TankMO.queryTankById(tankDB.refitId)
	self.m_refitTank = refitTank

	-- 改装坦克需要消耗的时间
	self.m_tankBuildTime = FormulaBO.tankRefitTime(self.m_buildingId, tankDB.tankId)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 26)

	local title = ui.newTTFLabel({text = refitTank.name, font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	-- 建筑样式
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, refitTank.tankId):addTo(container)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(110, container:getContentSize().height - 114)

	-- 当前数量
	local label = ui.newTTFLabel({text = CommonText[95] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 195, y = container:getContentSize().height - 65, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_TANK, refitTank.tankId), font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	count:setAnchorPoint(cc.p(0, 0.5))

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 195, label:getPositionY() - 30):addTo(container)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(math.ceil(self.m_tankBuildTime)), font = "fnt/num_2.fnt"}):addTo(container)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

	-- 详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); require("app.dialog.DetailTankDialog").new(self.m_refitTank.tankId):push() end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 60, container:getContentSize().height - 84)

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(container:getContentSize().width - 30, 130))
	attrBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 125 - attrBg:getContentSize().height / 2)

	local valueColor = COLOR[3]
	local labelX = 100
	local labelX2 = 380

	-- 攻击
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "attack"}):addTo(attrBg)
	itemView:setPosition(labelX - 30, attrBg:getContentSize().height - 36)

	local label = ui.newTTFLabel({text = CommonText.attr[1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = refitTank.attack, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 生命
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "maxHp"}):addTo(attrBg)
	itemView:setPosition(labelX - 30, attrBg:getContentSize().height - 96)

	local label = ui.newTTFLabel({text = CommonText.attr[2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = refitTank.hp, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 攻击方式
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, tankDB.attackMode, {name = "atkMode"}):addTo(attrBg)
	itemView:setPosition(labelX2 - 30, attrBg:getContentSize().height - 36)

	local label = ui.newTTFLabel({text = CommonText.atkMode[refitTank.attackMode], font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = attrBg:getContentSize().height - 36, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 载重
	local itemView = UiUtil.createItemView(ITEM_KIND_ATTRIBUTE, nil, {name = "payload"}):addTo(attrBg)
	itemView:setPosition(labelX2 - 30, attrBg:getContentSize().height - 96)

	local label = ui.newTTFLabel({text = CommonText.attr[3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = labelX2, y = itemView:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = refitTank.payload, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = valueColor, align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	resBg:setPreferredSize(cc.size(604, 336))
	resBg:setCapInsets(cc.rect(80, 60, 1, 1))
	resBg:setPosition(container:getContentSize().width / 2, attrBg:getPositionY() - attrBg:getContentSize().height / 2 - 2 - resBg:getContentSize().height / 2)
	self.m_resBg = resBg

	local view = RefitResTableView.new(cc.size(resBg:getContentSize().width, 278), self.m_tankId):addTo(resBg)
	view:setPosition(0, 12)
	view:reloadData()
	self.m_resTablView = view

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 303, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = 470, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	local greenLabelColor = COLOR[2]

	-- 数量
	local desc = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 192, y = resBg:getPositionY() - resBg:getContentSize().height / 2 - 16, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	local num = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = desc:getPositionX() +  desc:getContentSize().width / 2, y = desc:getPositionY(), color = greenLabelColor}):addTo(container)
	num:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = num

	-- 生产需要时间
	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 345, num:getPositionY()):addTo(container)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(container)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	self.m_timeLabel = time

	self.m_minNum = 1
	self.m_maxNum = TankBO.getMaxRefitNum(self.m_tankId)
	if self.m_maxNum <= 0 then self.m_maxNum = 1 end -- 最少有一个

	self.m_settingNum = self.m_maxNum

	self:showSlider()

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(container)
    reduceBtn:setPosition(50, self.m_numSlider:getPositionY() + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(container)
    addBtn:setPosition(container:getContentSize().width - 50, reduceBtn:getPositionY())

	-- 返回
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local returnBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); self:dispatchEvent({name = "REFIT_RETURN_EVENT"}) end):addTo(container)
	returnBtn:setPosition(140, container:getContentSize().height - 730)
	returnBtn:setLabel(CommonText[99])

	-- 确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local returnBtn = MenuButton.new(normal, selected, nil, handler(self, self.onProductCallback)):addTo(container)
	returnBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
	returnBtn:setLabel(CommonText[1])
end

function RefitProductView:showSlider()
	if self.m_numSlider then
		self.m_numSlider:removeSelf()
		self.m_numSlider = nil
	end

	local barHeight = 40
	local barWidth = 372

	gprint("self.m_settingNum:", self.m_settingNum)
	
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self, 2)
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getContentSize().width / 2 - barWidth / 2, self.m_resBg:getPositionY() - self.m_resBg:getContentSize().height / 2 - 70)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(barWidth + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})
end

function RefitProductView:onResUpdate()
	local maxNum = TankBO.getMaxRefitNum(self.m_tankId)
	if maxNum == 0 then maxNum = 1 end -- 最少有一个
	-- if maxNum == self.m_maxNum then return end

	self.m_maxNum = maxNum
	if self.m_settingNum > self.m_maxNum then self.m_settingNum = self.m_maxNum end

	gprint("self.m_maxNum:", self.m_maxNum, "self.m_settingNum:", self.m_settingNum)
	self:showSlider()
end

function RefitProductView:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function RefitProductView:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function RefitProductView:onSlideCallback(event)
	local value = event.value - event.value % 1
	-- -- gprint("RefitProductView value:", value)
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_timeLabel:setString(UiUtil.strBuildTime(math.ceil(self.m_tankBuildTime * self.m_settingNum)))
	self.m_resTablView:setCurProductNum(self.m_settingNum)
end

function RefitProductView:onProductCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	for index = 1, 7 do
		local item = {}
		local need = 0

		if index == 1 then item = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_IRON}; need = self.m_refitTank.iron - self.m_tank.iron -- 铁
		elseif index == 2 then item = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_OIL}; need = self.m_refitTank.oil - self.m_tank.oil
		elseif index == 3 then item = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_COPPER}; need = self.m_refitTank.copper - self.m_tank.copper
		elseif index == 4 then item = {kind = ITEM_KIND_RESOURCE, id = RESOURCE_ID_SILICON}; need = self.m_refitTank.silicon - self.m_tank.silicon
		elseif index == 5 then item = {kind = ITEM_KIND_PROP, id = self.m_refitTank.drawing}; if self.m_refitTank.drawing > 0 then need = 1 end
		elseif index == 6 then item = {kind = ITEM_KIND_PROP, id = PROP_ID_SKILL_BOOK}; need = self.m_refitTank.book
		elseif index == 7 then item = {kind = ITEM_KIND_TANK, id = self.m_tank.tankId}; need = 1
		end

		need = need * self.m_settingNum

		local count = UserMO.getResource(item.kind, item.id)
		if count < need then
			-- gprint("RefitProductView ???:", index)
			Toast.show(CommonText[368])
			return
		end
	end

	self:dispatchEvent({name = "ARMY_REFIT_EVENT", tankId = self.m_tankId, count = self.m_settingNum})
end

return RefitProductView
