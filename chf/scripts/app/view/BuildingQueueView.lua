
BUILDING_FOR_ALL = 1
BUILDING_FOR_WILD_COMMON  = 2
BUILDING_FOR_WILD_STONE   = 3
BUILDING_FOR_WILD_SILICON = 4

------------------------------------------------------------------------------
-- 城外建造建筑tableview
------------------------------------------------------------------------------

local BuildingTableView = class("BuildingTableView", TableView)

function BuildingTableView:ctor(size, viewFor, wildPos)
	BuildingTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.m_viewFor = viewFor
	self.m_wildPos = wildPos
end

function BuildingTableView:onEnter()
	BuildingTableView.super.onEnter(self)
	
	if self.m_viewFor == BUILDING_FOR_ALL then
		local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
		self.m_allBuildData = buildData
		local function doneCallback()
			Loading.getInstance():unshow()
		end

		Loading.getInstance():show()
		BuildBO.asynGetBuilding(doneCallback)
	end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.buildHandler_ = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onUpdateBuild))
end

function BuildingTableView:onExit()
	BuildingTableView.super.onExit(self)

	if self.buildHandler_ then
		Notify.unregister(self.buildHandler_)
		self.buildHandler_ = nil
	end
end

function BuildingTableView:update(dt)
	if self.m_viewFor == BUILDING_FOR_ALL then
		local cellNum = self:numberOfCells()
		for index = 1, cellNum do
			local cell = self:cellAtIndex(index)
			if cell then
				local data = cell.data
				if data.status == BUILD_STATUS_UPGRADE then
					local leftTime = 0
					local totalTime = 0
					if data.pos == 0 then
						leftTime = BuildMO.getUpgradeLeftTime(data.buildingId)
						totalTime = BuildMO.getUpgradeTotalTime(data.buildingId)
					else
						leftTime = BuildMO.getWildUpgradeLeftTime(data.pos)
						totalTime = BuildMO.getWildUpgradeTotalTime(data.pos)
					end
					if totalTime == 0 then
						cell.timeBar:setPercent(1)
					else
						cell.timeBar:setPercent((totalTime - leftTime) / totalTime)
					end
					-- print("111 pos", data.pos, "id:", data.buildingId, "left:", leftTime, "total:", totalTime)
					cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
				end
			end
		end
	end
end

function BuildingTableView:numberOfCells()
	if self.m_viewFor == BUILDING_FOR_ALL then
		return #self.m_allBuildData
	elseif self.m_viewFor == BUILDING_FOR_WILD_COMMON then
		return 3
	elseif self.m_viewFor == BUILDING_FOR_WILD_STONE then
		return 1
	elseif self.m_viewFor == BUILDING_FOR_WILD_SILICON then
		return 1
	else
		gprint("view for:", self.m_viewFor)
		error("[BuildingTableView] numberOfCells ")
	end
end

function BuildingTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function BuildingTableView:createCellAtIndex(cell, index)
	BuildingTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local function showBuild(buildingId)
		local itemView = UiUtil.createItemSprite(ITEM_KIND_BUILD, buildingId):addTo(cell)
		itemView:setAnchorPoint(cc.p(0.5, 0))
		itemView:setPosition(93, 30)
		itemView:setScale(math.min(102 / itemView:getContentSize().width, 102 / itemView:getContentSize().height))

		local buildDB = BuildMO.queryBuildById(buildingId)		

		local nxtBuildLevel = BuildMO.queryBuildLevel(buildingId, 1)

		-- 名称
		local name = ui.newTTFLabel({text = buildDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
		clock:setAnchorPoint(cc.p(0, 0.5))
		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(FormulaBO.buildingUpTime(nxtBuildLevel.upTime, buildingId)), font = "fnt/num_2.fnt"}):addTo(cell)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())

		-- -- 详情
		-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
		-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
		-- local detailBtn = CellMenuButton.new(normal, selected, nil, nil)
		-- cell:addButton(detailBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

		-- 生产按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenBuild))
		accelBtn.build = buildDB
		cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	end

	if self.m_viewFor == BUILDING_FOR_ALL then
		self:showUpgrade(cell, index)
	elseif self.m_viewFor == BUILDING_FOR_WILD_COMMON then
		local ids = {BUILD_ID_IRON, BUILD_ID_COPPER, BUILD_ID_OIL}
		local id = ids[index]
		showBuild(id)
	elseif self.m_viewFor == BUILDING_FOR_WILD_STONE then -- 宝石
		showBuild(BUILD_ID_STONE)
	elseif self.m_viewFor == BUILDING_FOR_WILD_SILICON then -- 硅
		showBuild(BUILD_ID_SILICON)
	end

	return cell
end

function BuildingTableView:showUpgrade(cell, index)
	local data = self.m_allBuildData[index]
	local buildingId = data.buildingId
	local level = data.level
	local buildDB = BuildMO.queryBuildById(buildingId)

	cell.data = data

	local itemView = UiUtil.createItemSprite(ITEM_KIND_BUILD, buildingId):addTo(cell)
	itemView:setAnchorPoint(cc.p(0.5, 0))
	itemView:setPosition(93, 30)
	itemView:setScale(math.min(102 / itemView:getContentSize().width, 102 / itemView:getContentSize().height))

	local conditionEnough = BuildBO.canUpgrade(data.buildingId, data.pos)

	-- 名称
	local name = ui.newTTFLabel({text = buildDB.name .. " LV." .. level, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
	if data.status ~= BUILD_STATUS_UPGRADE and not conditionEnough then
		name:setColor(COLOR[5])
	end

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	if data.status ~= BUILD_STATUS_UPGRADE and not conditionEnough then
		time:setColor(COLOR[5])
	end
	cell.timeLabel = time

	if data.status == BUILD_STATUS_UPGRADE then -- 正在升级中
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
		bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
		bar:setPercent(0)
		cell.timeBar = bar

		-- 取消按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_cancel_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_cancel_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onCancelProduct))
		accelBtn.buildData = data
		cell:addButton(accelBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

		-- 加速按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onAccelProduct))
		accelBtn.buildData = data
		cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	else
		-- 详情
		local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
		local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
		detailBtn.buildData = data
		cell:addButton(detailBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

		if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
			local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
			local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
			local upIds = json.decode(refitInfo.buildingId)
			for index=1,#upIds do
				if upIds[index] == buildingId then
					local text = {}
					table.insert(text, {{content= CommonText[1833]}})
					--详情
					local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
					local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
					local tipBtn = CellMenuButton.new(normal, selected, nil, function ()
						local DetailTextDialog = require("app.dialog.DetailTextDialog")
						DetailTextDialog.new(text):push()
					end)
					cell:addButton(tipBtn, detailBtn:x() - 80, self.m_cellSize.height / 2 - 22)
				end
			end
		end

		local nxtBuildLevel = BuildMO.queryBuildLevel(buildingId, level + 1)
		if nxtBuildLevel then
			cell.timeLabel:setString(UiUtil.strBuildTime(FormulaBO.buildingUpTime(nxtBuildLevel.upTime, buildingId)))
		end
		-- 生产按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenBuild))
		accelBtn.buildData = data
		accelBtn.conditionEnough = conditionEnough
		cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	end
end

function BuildingTableView:onChosenBuild(tag, sender)
	ManagerSound.playNormalButtonSound()

	if BuildBO.isUpgradeFull() then  -- 队列已满
		HomeBO.doBuildQueueCount()
		return
	end

	if self.m_isUp then return end   -- 避免连点

	if self.m_viewFor == BUILDING_FOR_ALL then
		local data = sender.buildData
		local buildingId = data.buildingId

		local conditionEnough = sender.conditionEnough
		if not conditionEnough then  -- 条件不足
			if buildingId == BUILD_ID_COMMAND then
				require("app.view.CommandInfoView").new():push()
			elseif buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then 
				require("app.view.ChariotInfoView").new(buildingId):push()
			elseif buildingId == BUILD_ID_WAREHOUSE_A or buildingId == BUILD_ID_WAREHOUSE_B then
				require("app.view.WarehouseView").new(buildingId):push()
			elseif buildingId == BUILD_ID_SCIENCE then
				require("app.view.ScienceView").new(buildingId):push()
			elseif buildingId == BUILD_ID_WORKSHOP then
				require("app.view.WorkshopView").new(buildingId):push()
			elseif buildingId == BUILD_ID_REFIT then
				require("app.view.RefitView").new(buildingId):push()
			elseif buildingId == BUILD_ID_MATERIAL_WORKSHOP then
				require("app.view.MaterialWorkshopView").new(buildingId,1):push()
			elseif data.pos > 0 then
				local mill = BuildMO.getMillAtPos(data.pos)
				-- ggprint("id:" .. mill.buildingId)
				local BuildingInfoView = require("app.view.BuildingInfoView")
				BuildingInfoView.new(nil, mill.buildingId, data.pos):push()
			end
			return
		end

		local function doneUpgrade()
			local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
			self.m_allBuildData = buildData

			ManagerSound.playSound("build_create")

			Loading.getInstance():unshow()
			self:reloadData()
			self.m_isUp = false
		end

		self.m_isUp = true
		if data.pos > 0 then -- 城外
			Loading.getInstance():show()
			BuildBO.asynBuildUpgrade(doneUpgrade, data.buildingId, data.level, 2, data.pos)
		else
			Loading.getInstance():show()
			BuildBO.asynBuildUpgrade(doneUpgrade, data.buildingId, data.level, 2)
		end
	else
		local build = sender.build
		local buildingId = build.buildingId
		local function doneBuildUpgrade() -- 城外的建造建筑
			Loading.getInstance():unshow()
			
			ManagerSound.playSound("build_create")
			UiDirector.pop()
		end
		self.m_isUp = true
		Loading.getInstance():show()
		BuildBO.asynBuildUpgrade(doneBuildUpgrade, build.buildingId, 0, 2, self.m_wildPos)
	end
end

function BuildingTableView:onCancelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = sender.buildData
	gdump(data, "Cancel")

	local function doneCancel()
		Loading.getInstance():unshow()
		if self.m_viewFor == BUILDING_FOR_ALL then
			local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
			self.m_allBuildData = buildData
		end
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[196], function()
			Loading.getInstance():show()
			BuildBO.asynCancelUpgrade(doneCancel, data.buildingId, data.pos)
		end):push()
end

function BuildingTableView:onAccelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = sender.buildData
	require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_BUILD, data.buildingId, {wildPos = data.pos, buildingId = data.buildingId}):push()
end

function BuildingTableView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = sender.buildData
	require("app.dialog.DetailBuildDialog").new(data.buildingId, data.pos):push()
end

function BuildingTableView:onUpdateBuild(event)
	if self.m_viewFor == BUILDING_FOR_ALL then
		local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
		self.m_allBuildData = buildData
	end
	self:reloadData()
end

------------------------------------------------------------------------------
-- 建造建筑view
------------------------------------------------------------------------------
local BuildingQueueView = class("BuildingQueueView", UiNode)

-- 如果是野外，则需要传递位置
function BuildingQueueView:ctor(viewFor, wildPos)
	BuildingQueueView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)

	self.m_viewFor = viewFor
	self.m_wildPos = wildPos
end

function BuildingQueueView:onEnter()
	BuildingQueueView.super.onEnter(self)

	-- 建造
	self:setTitle(CommonText[70])

	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 124))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
	self.m_container = container
	self:showUI(container)

	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))
end

function BuildingQueueView:onExit()
	BuildingQueueView.super.onExit(self)

	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end
end

function BuildingQueueView:showUI(container)
	container:removeAllChildren()
	container.cdLabel_ = nil
	container.coinOwnLabel_ = nil

	if self.m_viewFor == BUILDING_FOR_ALL then
		if BuildMO.autoQueueStretch_ then
			local view = BuildingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 214 - 13), self.m_viewFor, self.m_wildPos):addTo(container)
			view:setPosition(0, 214 + 13)
			view:reloadData()

			local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_81.png"):addTo(container)
			bg:setPreferredSize(cc.size(GAME_SIZE_WIDTH, bg:getContentSize().height))
			bg:setCapInsets(cc.rect(66, 60, 1, 1))
			bg:setPosition(container:getContentSize().width / 2, bg:getContentSize().height / 2 - 20)

			local normal = display.newSprite(IMAGE_COMMON .. "btn_47_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_47_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onAutoCallback)):addTo(container)
			btn:setPosition(container:getContentSize().width - 122, bg:getContentSize().height + btn:getContentSize().height / 2 - 20)

			local view = display.newSprite("image/item/p_build_accel.jpg"):addTo(bg)
			view:setPosition(75, 135)

			local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(view, 6)
			fame:setPosition(view:getContentSize().width / 2, view:getContentSize().height / 2)

			-- 自动升级建筑
			local title = ui.newTTFLabel({text = CommonText[10033][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 134, y = 170, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			title:setAnchorPoint(cc.p(0, 0.5))

			local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))
			container.cdLabel_ = label

			local label = ui.newTTFLabel({text = CommonText[10033][2], font = G_FONT, size = FONT_SIZE_TINY, x = title:getPositionX(), y = title:getPositionY() - 32, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local item = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(bg)
			item:setPosition(148, 105)

			local price = ui.newTTFLabel({text = BUILD_AUTO_UPGRADE_TAKE, font = G_FONT, size = FONT_SIZE_SMALL, x = item:getPositionX() + item:getContentSize().width / 2 + 5, y = item:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			price:setAnchorPoint(cc.p(0, 0.5))

			local count = UserMO.getResource(ITEM_KIND_COIN)

			-- 当前拥有
			local label = ui.newTTFLabel({text = "(" .. CommonText[63] .. ":" .. count .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = price:getPositionX() + price:getContentSize().width + 10, y = price:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setAnchorPoint(cc.p(0, 0.5))
			container.coinOwnLabel_ = label

			-- 自动升级
			local label = ui.newTTFLabel({text = CommonText[10034], font = G_FONT, size = FONT_SIZE_SMALL, x = view:getPositionX(), y = 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

			-- 开关按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_49_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_49_normal.png")
			local switchBtn = self:createSwitchButton()
			switchBtn:setPosition(200, 50)
			switchBtn:addTo(bg)

			-- 购买使用
			local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
			local buyBtn = MenuButton.new(normal, selected, nil, handler(self, self.onBuyCallback)):addTo(bg)
			buyBtn:setPosition(container:getContentSize().width - 110, 60)
			buyBtn:setLabel(CommonText[87])

		else
			local view = BuildingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 33), self.m_viewFor, self.m_wildPos):addTo(container)
			view:setPosition(0, 33)
			view:reloadData()

			local normal = display.newSprite(IMAGE_COMMON .. "btn_48_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_48_selected.png")
			local btn = MenuButton.new(normal, selected, nil, handler(self, self.onAutoCallback)):addTo(container)
			btn:setPosition(container:getContentSize().width - 122, btn:getContentSize().height / 2)
		end
	else
		local view = BuildingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), self.m_viewFor, self.m_wildPos):addTo(container)
		view:reloadData()
	end

	self:onTick(0)
end

function BuildingQueueView:onTick(dt)
	if self.m_container.cdLabel_ then
		if BuildMO.autoCdTime_ > 0 then
			self.m_container.cdLabel_:setString("(" .. CommonText[10036] .. UiUtil.strBuildTime(BuildMO.autoCdTime_) .. ")")  -- 剩余
		else
			self.m_container.cdLabel_:setString("")
		end
	end
end

function BuildingQueueView:createSwitchButton()
	local function showTag(sender)
		local tag = sender.tag
		local label = sender.statusLabel

		if sender.isOn then
			-- 显示ON
			tag:setPosition(sender:getContentSize().width - tag:getContentSize().width / 2, sender:getContentSize().height / 2)
			label:setString(CommonText[326][1])  -- 已开启
		else
			-- 显示OFF
			tag:setPosition(tag:getContentSize().width / 2, sender:getContentSize().height / 2)
			label:setString(CommonText[326][2])  -- 已关闭
		end
	end

	local function onSwitchCallback(tag, sender)
		local gotoOn = not sender.isOn
		
		if gotoOn and BuildMO.autoCdTime_ <= 0 then  -- 需要开启
			Toast.show(CommonText[10035])  -- 请先购买自动升级时间，再开启自动功能
			return
		end

		local function doneSetAutoBuild()
			Loading.getInstance():unshow()

			sender.isOn = BuildMO.autoOpen_
			showTag(sender)
		end

		Loading.getInstance():show()
		BuildBO.asynSetAutoBuild(doneSetAutoBuild, gotoOn)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_49_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_49_normal.png")
	local btn = MenuButton.new(normal, selected, nil, onSwitchCallback)

	local on = ui.newTTFLabel({text = "ON", font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)

	local off = ui.newTTFLabel({text = "OFF", font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width - 30, y = btn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)

	local tag = display.newSprite(IMAGE_COMMON .. "btn_slider_head.png"):addTo(btn)
	btn.tag = tag
	btn.isOn = BuildMO.autoOpen_

	local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width + 10, y = btn:getContentSize().height / 2, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
	status:setAnchorPoint(cc.p(0, 0.5))
	btn.statusLabel = status

	showTag(btn)

	return btn
end

function BuildingQueueView:onBuyCallback(tag, sender)
	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[10038])  -- 自动升级建筑成功

		if self.m_container.coinOwnLabel_ then
			self.m_container.coinOwnLabel_:setString("(" .. CommonText[63] .. ":" .. UserMO.getResource(ITEM_KIND_COIN) .. ")")
		end
	end

	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < BUILD_AUTO_UPGRADE_TAKE then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		BuildBO.asynBuyAutoBuild(doneCallback)
	end

	if UserMO.consumeConfirm then
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)

		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[10037], BUILD_AUTO_UPGRADE_TAKE, resData.name), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

function BuildingQueueView:onAutoCallback(tag, sender)
	BuildMO.autoQueueStretch_ = not BuildMO.autoQueueStretch_
	self:showUI(self.m_container)
end

return BuildingQueueView
