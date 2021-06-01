
-- 当前制作车间正在生产的道具

local WorkshopProductingTableView = class("WorkshopProductingTableView", TableView)

function WorkshopProductingTableView:ctor(size, buildingId)
	-- gprint("[WorkshopProductingTableView] ctor: ", buildingId)

	WorkshopProductingTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_buildingId = buildingId
end

function WorkshopProductingTableView:onEnter()
	WorkshopProductingTableView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_products = FactoryBO.orderProduct(self.m_buildingId)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_productHandler = Notify.register(LOCAL_PROP_DONE_EVENT, handler(self, self.onProductUpdate))
end

function WorkshopProductingTableView:numberOfCells()
	return #self.m_products
end

function WorkshopProductingTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WorkshopProductingTableView:createCellAtIndex(cell, index)
	WorkshopProductingTableView.super.createCellAtIndex(self, cell, index)

	local productData = FactoryBO.getProductData(self.m_build.buildingId, self.m_products[index])
	gdump(productData, "[WorkshopProductingTableView] createCellAtIndex")

	local propId = productData.propId
	local propDB = PropMO.queryPropById(propId)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	-- 名称
	local name = ui.newTTFLabel({text = PropMO.getPropName(propId) .. "*" .. productData.count, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[propDB.color]}):addTo(cell)

	--
	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propDB.propId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

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
	accelBtn.propId = propDB.propId
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

function WorkshopProductingTableView:onCancelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCancel()
		Loading.getInstance():unshow()
		
		self.m_products = FactoryBO.orderProduct(self.m_build.buildingId)
		self:reloadData()
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[100], function()
			Loading.getInstance():show()
			PropBO.asynCancelProp(doneCancel, sender.schedulerId)
		end):push()
end

function WorkshopProductingTableView:onAccelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneSpeed()
		Loading.getInstance():unshow()
		-- Toast.show("花费金币加速成功")
	end
	
	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local needCoin = math.ceil(FactoryBO.getProductTime(self.m_build.buildingId, sender.schedulerId) / BUILD_ACCEL_TIME)

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[298], needCoin, resData.name), function()
			local count = UserMO.getResource(ITEM_KIND_COIN)
			if count < needCoin then
				Toast.show(resData.name .. CommonText[223])
				return
			end

			local leftTime = FactoryBO.getProductTime(self.m_build.buildingId, sender.schedulerId)
			if leftTime <= 0 then return end

			Loading.getInstance():show()
			PropBO.asynSpeedProp(doneSpeed, sender.schedulerId, 1)

		end):push()
	-- require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_PROP, sender.propId, {buildingId = self.m_build.buildingId, schedulerId = sender.schedulerId}):push()
end

function WorkshopProductingTableView:onProductUpdate(event)
	-- gprint("[WorkshopProductingTableView] 有道具生产完了")
	self.m_products = FactoryBO.orderProduct(self.m_build.buildingId)

	self:reloadData()
end

function WorkshopProductingTableView:update(dt)
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

function WorkshopProductingTableView:onExit()
	WorkshopProductingTableView.super.onExit(self)
	if self.m_productHandler then
		Notify.unregister(self.m_productHandler)
		self.m_productHandler = nil
	end
end

return WorkshopProductingTableView
