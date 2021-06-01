

-- 当前战车工厂中正在生产的tank

local ArmyProductingTableView = class("ArmyProductingTableView", TableView)

-- buildingId: 通过buildingId确定是哪个战车工厂，已确定战车工厂正在生产哪些tank
function ArmyProductingTableView:ctor(size, buildingId)
	gprint("[ArmyProductingTableView] ctor: ", buildingId)
	ArmyProductingTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_buildingId = buildingId
end

function ArmyProductingTableView:onEnter()
	ArmyProductingTableView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_products = FactoryBO.orderProduct(self.m_buildingId)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_productHandler = Notify.register(LOCAL_TANK_DONE_EVENT, handler(self, self.onProductUpdate))
end

function ArmyProductingTableView:numberOfCells()
	return #self.m_products
end

function ArmyProductingTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArmyProductingTableView:createCellAtIndex(cell, index)
	ArmyProductingTableView.super.createCellAtIndex(self, cell, index)

	local productData = FactoryBO.getProductData(self.m_build.buildingId, self.m_products[index])
	gdump(productData, "[ArmyProductingTableView] createCellAtIndex")

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	if not productData then return cell end

	local tankId = productData.tankId
	local tankDB = TankMO.queryTankById(tankId)

	-- 名称
	local name = ui.newTTFLabel({text = tankDB.name .. "*" .. productData.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[tankDB.grade]}):addTo(cell)

	--
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(cell)
	sprite:setAnchorPoint(cc.p(0.5, 0))
	sprite:setPosition(93, 30)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
	bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
	cell.timeBar = bar

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	cell.timeLabel = time

	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_cancel_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_cancel_selected.png")
	local cancelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onCancelProduct))
	cancelBtn.schedulerId = self.m_products[index]
	cell:addButton(cancelBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

	-- 加速按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_accel_disabled.png")
	local accelBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onAccelProduct))
	accelBtn.tankId = tankId
	accelBtn.schedulerId = self.m_products[index]
	cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

	if productData.state == SchedulerSet.STATE_WAIT then
		bar:setPercent(0)
		bar:setLabel(CommonText[503])  -- 等待中
		time:setString(UiUtil.strBuildTime(productData.period))
		accelBtn:setEnabled(false)
	end

	cell.state = productData.state
	cell.totalTime = productData.period
	cell.schedulerId = self.m_products[index]
	return cell
end

function ArmyProductingTableView:onCancelProduct(tag, sender)
	local function doneCancel()
		Loading.getInstance():unshow()
		
		self.m_products = FactoryBO.orderProduct(self.m_build.buildingId)
		self:reloadData()
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[100], function()
			Loading.getInstance():show()
			TankBO.asynCancelProduct(doneCancel, self.m_build.buildingId, sender.schedulerId)
		end):push()
end

function ArmyProductingTableView:onAccelProduct(tag, sender)
	require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_TANK, sender.tankId, {buildingId = self.m_build.buildingId, schedulerId = sender.schedulerId}):push()
	--触发引导
	-- NewerBO.showNewerGuide()
end

function ArmyProductingTableView:onProductUpdate(event)
	gprint("[ArmyProductingTableView] tank product done!!!")
	self.m_products = FactoryBO.orderProduct(self.m_build.buildingId)

	self:reloadData()
end

function ArmyProductingTableView:update(dt)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			if cell.state == SchedulerSet.STATE_WAIT then -- 等待中
			elseif cell.state == SchedulerSet.STATE_RUN then -- 运行中
				local leftTime = FactoryBO.getProductTime(self.m_build.buildingId, cell.schedulerId)
				cell.timeBar:setPercent((cell.totalTime - leftTime) / cell.totalTime)
				cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
			end
		end
	end
end

function ArmyProductingTableView:onExit()
	ArmyProductingTableView.super.onExit(self)
	if self.m_productHandler then
		Notify.unregister(self.m_productHandler)
		self.m_productHandler = nil
	end
end

-- function ArmyProductingTableView:setCurProductNum(num)
-- 	self.m_curProductNum = num

-- 	for index = 1, self.m_cellNum do
-- 		local cell = self:cellAtIndex(index)
-- 		if cell then
-- 			self:updateCell(cell, index)
-- 		end
-- 	end
-- end


-- 

return ArmyProductingTableView
