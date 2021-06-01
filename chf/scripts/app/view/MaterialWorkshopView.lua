--
-- Author: Your Name
-- Date: 2017-04-19 15:17:48
--
--材料生产tableview
local MaterialProductTableView = class("MaterialProductTableView", TableView)

function MaterialProductTableView:ctor(size, viewFor)
	MaterialProductTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.m_viewFor = viewFor

	self.buildInfo = BuildMO.queryBuildById(BUILD_ID_MATERIAL_WORKSHOP)
	self.cellNum = self.buildInfo.proDefault + #json.decode(self.buildInfo.proBuyPrice)
end

function MaterialProductTableView:onEnter()
	MaterialProductTableView.super.onEnter(self)

	self.lembHandler_ = Notify.register(LOCAL_MATERIAL_LEMB, handler(self, self.updateCells))
end

function MaterialProductTableView:numberOfCells()
	return self.cellNum
end

function MaterialProductTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MaterialProductTableView:createCellAtIndex(cell, index)
	MaterialProductTableView.super.createCellAtIndex(self, cell, index)
	local materialQueue = WeaponryBO.MaterialQueue
	local completeInfo = {}
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	--材料框
	local famebg = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(cell)
	famebg:setPosition(famebg:width() + 10,self.m_cellSize.height / 2)
	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
	if index <= self.buildInfo.proDefault + MaterialMO.buyCount_ then
		if materialQueue and #materialQueue > 0 and index <= #materialQueue then
			local resData = UserMO.getResourceData(ITEM_KIND_WEAPONRY_PAPER, materialQueue[index].pid)
			local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER, materialQueue[index].pid, {count = materialQueue[index].count}):addTo(famebg):center()
			UiUtil.createItemDetailButton(itemView)
			--生产的材料名
			local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[3]}):addTo(cell)
			--当前繁荣度
			local now = ui.newTTFLabel({text = CommonText[1701][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 84, color = COLOR[11]}):addTo(cell)
			local nowNum = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_PROSPEROUS), font = G_FONT, size = FONT_SIZE_SMALL, x = now:x() + now:width() / 2, y = 84, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			--繁荣度上线
			local max = ui.newTTFLabel({text = CommonText[1701][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 54, color = COLOR[11]}):addTo(cell)
			local maxNum = ui.newTTFLabel({text = UserMO.maxProsperous_, font = G_FONT, size = FONT_SIZE_SMALL, x = max:x() + max:width() / 2, y = 54, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			--预计生产时间
			local time = ui.newTTFLabel({text = CommonText[1701][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 24, color = COLOR[11]}):addTo(cell)
			local timeNum = ui.newTTFLabel({text = UiUtil.strBuildTime(materialQueue[index].endTime - ManagerTimer.getTime()), font = G_FONT, size = FONT_SIZE_SMALL, x = time:x() + time:width() / 2, y = 24, align = ui.TEXT_ALIGN_LEFT, color = COLOR[1]}):addTo(cell)
			cell.timeLabel = timeNum
			--进度条
			local bar = ProgressBar.new(IMAGE_COMMON .. "bar_11.png", BAR_DIRECTION_HORIZONTAL, nil, {bgName = IMAGE_COMMON .. "bar_bg_11.png"}):addTo(bg)
			bar:setPosition(bg:width() - 100,bg:height() / 2 - 20)
			bar:setPercent(materialQueue[index].complete / materialQueue[index].period)
			cell.timeBar = bar
			cell.data = materialQueue[index]
			if materialQueue[index].complete >= materialQueue[index].period then
				table.insert(completeInfo,materialQueue[index])
			end
			local complete = ui.newTTFLabel({text = CommonText[1702]..string.format("%.2f", (materialQueue[index].complete / materialQueue[index].period) * 100).."%", font = G_FONT, size = FONT_SIZE_SMALL, x = bar:x(), y = bar:y() + 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(bg)
			cell.complete = complete
			local function tick()
				if cell.data.complete >= cell.data.period then
					cell.timeBar:removeSelf()
					cell.timeLabel:setString("00m:00s")
					cell.complete:removeSelf()
					--领取按钮
					local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
					local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
					local extBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.collectMaterial))
					extBtn:setLabel(CommonText[1719])
					extBtn.tag = index
					cell:addButton(extBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
				else
					local leftTime = cell.data.endTime - ManagerTimer.getTime()
					cell.timeBar:setPercent(cell.data.complete / cell.data.period)
					if leftTime > 0 then
						cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
					else
						cell.timeLabel:setString("00m:00s")
						cell.timeBar:stopAllActions()
						MaterialBO.updateLemb(function ()
							local offset = self:getContentOffset()
							self:reloadData()
							self:setContentOffset(offset)
						end)
					end
					cell.complete:setString(CommonText[1702]..string.format("%.2f", (cell.data.complete / cell.data.period) * 100).."%")
				end
			end
			cell.timeBar:performWithDelay(tick, 1, 1)
			tick()

		else
			local add = display.newSprite(IMAGE_COMMON.."icon_plus.png"):addTo(fame):center()
			local addBtn = TouchButton.new(fame, nil, nil, handler(self, self.onProductCallback)):addTo(cell):pos(famebg:x(),famebg:y())
			local pruduct = ui.newTTFLabel({text = CommonText[1703][1], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width / 2 - 50, y = self.m_cellSize.height / 2, color = COLOR[2]}):addTo(cell)
			--生产按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local productBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onProductCallback))
			productBtn:setLabel(CommonText[1703][2])
			cell:addButton(productBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
		end
	else
		local lock = display.newSprite(IMAGE_COMMON.."icon_lock_1.png"):addTo(fame):center()
		local lockBtn = TouchButton.new(fame, nil, nil, handler(self, self.onExtenCallback)):addTo(cell):pos(famebg:x(),famebg:y())

		local extension = ui.newTTFLabel({text = CommonText[1703][3], font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width / 2 - 50, y = self.m_cellSize.height / 2, color = COLOR[6]}):addTo(cell)
		--扩建按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local extBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onExtenCallback))
		extBtn:setLabel(CommonText[1703][4])
		cell:addButton(extBtn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	end

	return cell
end
--点击生产
function MaterialProductTableView:onProductCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.MaterialProductDialog").new(nil,function(data)
		UserMO.updateResources(PbProtocol.decodeArray(data.cost))
		self:reloadData()
	end):push()
end
--点击扩建
function MaterialProductTableView:onExtenCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local cost = json.decode(self.buildInfo.proBuyPrice)[MaterialMO.buyCount_ + 1]
	if cost > UserMO.getResource(ITEM_KIND_COIN) then
		require("app.dialog.CoinTipDialog").new():push()
		return
	end
	if  UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1700], cost), function()
			MaterialBO.buyMateriaPos(function()
				self:reloadData()
			end)
		end):push()
	else
		MaterialBO.buyMateriaPos(function()
			self:reloadData()
		end)
	end
end

--领取材料
function MaterialProductTableView:collectMaterial(tag,sender)
	ManagerSound.playNormalButtonSound()
	MaterialBO.awardMaterial(function (data)
		local awards = PbProtocol.decodeRecord(data["award"])
		local record = {}
		record[#record + 1] = awards
		if record then
			local statsAward = CombatBO.addAwards(record)
			UiUtil.showAwards(statsAward)
		end
		self:reloadData()
	end,sender.tag)
end

function MaterialProductTableView:updateCells(event)
	self:reloadData()
end

function MaterialProductTableView:onExit()
	MaterialProductTableView.super.onExit(self)
		Notify.unregister(self.lembHandler_)
		self.lembHandler_ = nil
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--材料工坊view
local MaterialWorkshopView = class("MaterialWorkshopView", UiNode)

function MaterialWorkshopView:ctor(buildingId, viewFor)
	MaterialWorkshopView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	viewFor = viewFor or SCIENCE_FOR_BUILD
	self.m_viewFor = viewFor
	self.m_buildingId = buildingId
end

function MaterialWorkshopView:onEnter()
	MaterialWorkshopView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_buildLv = BuildMO.getBuildLevel(self.m_buildingId)
	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self:showTitle()

	local buildLv = self.m_buildLv
	if buildLv == 0 then -- 需要建造
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
		container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
		self:showUpgrade(container)
	else
		local function createDelegate(container, index)
			if index == 1 then  -- 建造
				self:showUpgrade(container)
			elseif index == 2 then -- 生产
				self:showProduct(container)
			end
		end

		local function clickDelegate(container, index)

		end

		--  "建造", "生产"
		local pages = {CommonText[70], CommonText[1703][2]}
		local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
		local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
		pageView:setPageIndex(1)
		self.m_pageView = pageView

		if self.m_buildLv >= 1 then
			pageView:setPageIndex(self.m_viewFor)  --如果开启了材料工坊打开为第二页项
		end

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
		line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
		line:setScaleY(-1)
		line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	end
end

function MaterialWorkshopView:showTitle()
	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

function MaterialWorkshopView:showUpgrade(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(BUILD_ID_MATERIAL_WORKSHOP):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function MaterialWorkshopView:showProduct(container)
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.MaterialInfo):push()
		end):addTo(container)
	detailBtn:setPosition(container:width() - detailBtn:width(),container:height() - detailBtn:height() / 2 - 10)
	self.prosHandler_ = Notify.register(LOCAL_PROSPEROUS_EVENT, handler(self, self.onUpdateInfo))
	--当前繁荣度
	local prosperous = ui.newTTFLabel({text = CommonText[1701][1], font = G_FONT, size = FONT_SIZE_SMALL,
	 x = 20, y = container:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	prosperous:setAnchorPoint(cc.p(0, 0.5))
	--line
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container,-1)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2,prosperous:y() - 40)
	--繁荣度
	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = prosperous:getPositionX() + prosperous:getContentSize().width, y = prosperous:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_prosLabel = value

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_prosMaxLabel = value

	--工厂状况
	local factory = ui.newTTFLabel({text = CommonText[993] .. ":", font = G_FONT, size = FONT_SIZE_SMALL,
	 x = 20, y = prosperous:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	factory:setAnchorPoint(cc.p(0, 0.5))
	self.m_state = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL,
	 x = factory:getPositionX() + factory:getContentSize().width + 10, y = factory:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	self.m_state:setAnchorPoint(cc.p(0, 0.5))
	--材料生产tableview
	local MaterialProductTableView = MaterialProductTableView.new(cc.size(container:getContentSize().width,line:y() - line:height()/2)):addTo(container)
	MaterialProductTableView:setPosition(0,0)
	MaterialProductTableView:reloadData()

	self:onUpdateInfo()
end

function MaterialWorkshopView:onUpdateInfo(event)
	if self.m_pageView and self.m_pageView:getPageIndex() == 2 then
		self.m_prosLabel:setString(UserMO.getResource(ITEM_KIND_PROSPEROUS))
		self.m_prosMaxLabel:setString("/" .. UserMO.maxProsperous_)
		self.m_prosMaxLabel:setPosition(self.m_prosLabel:getPositionX() + self.m_prosLabel:getContentSize().width, self.m_prosLabel:getPositionY())

		if (UserMO.getResource(ITEM_KIND_PROSPEROUS) / UserMO.maxProsperous_) * 100 >= 75 then
			self.m_prosLabel:setColor(COLOR[2])
			self.m_state:setString(CommonText[1704][1])
			self.m_state:setColor(COLOR[2])
		elseif (UserMO.getResource(ITEM_KIND_PROSPEROUS) / UserMO.maxProsperous_) * 100 >= 50 and (UserMO.getResource(ITEM_KIND_PROSPEROUS) / UserMO.maxProsperous_) * 100 <= 75 then
			self.m_prosLabel:setColor(COLOR[1])
			self.m_state:setString(CommonText[1704][2])
			self.m_state:setColor(COLOR[1])
		elseif (UserMO.getResource(ITEM_KIND_PROSPEROUS) / UserMO.maxProsperous_) * 100 <= 50 then
			self.m_prosLabel:setColor(COLOR[6])
			self.m_state:setString(CommonText[1704][3])
			self.m_state:setColor(COLOR[6])
		end
	end
end

function MaterialWorkshopView:onBuildUpdate(event)
	if self.m_build then
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
		self:showTitle()
	end
end

function MaterialWorkshopView:onExit()
	MaterialWorkshopView.super.onExit(self)
	if self.prosHandler_ then
		Notify.unregister(self.prosHandler_)
		self.prosHandler_ = nil
	end

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end


return MaterialWorkshopView