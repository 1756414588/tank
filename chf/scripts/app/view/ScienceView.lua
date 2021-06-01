
-- 科技馆view

--------------------------------------------------------------------
-- 科技馆研究tableview
--------------------------------------------------------------------

local ScienceStudyTableView = class("ScienceStudyTableView", TableView)

function ScienceStudyTableView:ctor(size)
	ScienceStudyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
end

function ScienceStudyTableView:onEnter()
	ScienceStudyTableView.super.onEnter(self)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_UpgradeHandler = Notify.register(LOCAL_SCIENCE_DONE_EVENT, handler(self, self.onUpgradeUpdate))
	ScienceBO.sortScience()
end

function ScienceStudyTableView:numberOfCells()
	return #ScienceMO.sciences_
end

function ScienceStudyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ScienceStudyTableView:createCellAtIndex(cell, index)
	ScienceStudyTableView.super.createCellAtIndex(self, cell, index)

	local science = ScienceMO.sciences_[index]

	--是够可升级 0 未开放 1 已开放未达成条件 2 已开放已达成条件
	local canUpGrade = ScienceBO.canUpGrade(science.scienceId,science.scienceLv + 1)

	--是否正在升级 productData或者nil
	local productData = ScienceBO.isUpgrading(science.scienceId)


	if productData then -- 正在研究的
		-- gdump(productData,"productData====")
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 80, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	else
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	end

	local itemView = UiUtil.createItemView(ITEM_KIND_SCIENCE,science.scienceId):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = science.refineName, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local level = ui.newTTFLabel({text = "LV.0", font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width + 20, y = 114, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(cell)
	level:setAnchorPoint(cc.p(0, 0.5))


	local function openActivityRule()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.activity[10]):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_act_science.png")
	local activityBtn = CellScaleButton.new(normal, openActivityRule)
	activityBtn:setVisible(ActivityBO.scienceIsDis(science.scienceId))
	cell:addButton(activityBtn, self.m_cellSize.width - 170, 114)


	if canUpGrade == 0 then
		local alert = ui.newTTFLabel({text = string.format(CommonText[500],ScienceBO.getOpenLv(science.scienceId)), font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 54, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		alert:setAnchorPoint(cc.p(0, 0.5))
	else
		if productData then
			level:setString("LV." .. science.scienceLv .. "->LV." .. (science.scienceLv + 1))
			--升级进度
			local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
			bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
			bar.label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = bar:getContentSize().width/2, y = bar:getContentSize().height/2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
			cell.timeBar = bar

			local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
			clock:setAnchorPoint(cc.p(0, 0.5))
			clock:setVisible(productData[1].state == 1)
			local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
			time:setAnchorPoint(cc.p(0, 0.5))
			time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
			time:setVisible(productData[1].state == 1)
			cell.timeLabel = time

			-- 取消按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_cancel_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_cancel_selected.png")
			local cancelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onCancelProduct))
			cancelBtn.schedulerId = productData[2]
			cell:addButton(cancelBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

			-- 加速按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_accel_disabled.png")
			local accelBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onAccelProduct))
			accelBtn:setEnabled(productData[1].state == 1)
			accelBtn.scienceId = science.scienceId
			accelBtn.schedulerId = productData[2]

			cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

			cell.productData = productData
			cell.totalTime = productData[1].period
			cell.schedulerId = productData[2]

		else
			level:setString("LV." .. science.scienceLv)

			if canUpGrade ~= 3 then
				local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
				clock:setAnchorPoint(cc.p(0, 0.5))

				local timeValue = FormulaBO.scienceUpTime(science.scienceId, science.scienceLv + 1)
				-- if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
				-- 	local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
				-- 	local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
				-- 	local upIds = json.decode(refitInfo.techId)
				-- 	for index=1,#upIds do
				-- 		if upIds[index] == science.scienceId then
				-- 			timeValue = timeValue - timeValue * (refitInfo.time / 100)
				-- 		end
				-- 	end
				-- end
				local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(math.ceil(timeValue)), font = "fnt/num_2.fnt"}):addTo(cell)
				time:setAnchorPoint(cc.p(0, 0.5))
				time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
			else
				local desc = ui.newTTFLabel({text = CommonText[958][1], font = G_FONT, size = FONT_SIZE_MEDIUM, x = 170, y = self.m_cellSize.height - 90, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
				desc:setAnchorPoint(cc.p(0,0.5))
			end
			-- 详情按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
			local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetail))
			detailBtn.data = science
			cell:addButton(detailBtn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

			-- 升级按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_up_disabled.png")
			local upBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.doUpgrade))
			upBtn.data = science
			upBtn:setEnabled(canUpGrade == 2)
			-- upBtn:setVisible(canUpGrade == 2)
			-- gdump(canUpGrade,"可否升级")
			cell:addButton(upBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)

			if ActivityBO.isValid(ACTIVITY_ID_SCIENCE_SPEED) then --如果有科技加速活动
				local activity = ActivityMO.getActivityById(ACTIVITY_ID_SCIENCE_SPEED)
				local refitInfo =  ScienceMO.getTechSellInfo(activity.awardId)
				local upIds = json.decode(refitInfo.techId)
				for index=1,#upIds do
					if upIds[index] == science.scienceId then
						local text = {}
						table.insert(text, {{content= CommonText[1824]--[[string.format(,refitInfo.resource.."%",refitInfo.time.."%")--]]}})--标题
						--详情
						local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
						local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
						local tipBtn = CellMenuButton.new(normal, selected, nil, function ()
							local DetailTextDialog = require("app.dialog.DetailTextDialog")
							DetailTextDialog.new(text):push()
						end)
						cell:addButton(tipBtn, upBtn:x() - 160, self.m_cellSize.height / 2 - 22)
					end
				end
			end
		end
	end
	return cell
end

function ScienceStudyTableView:doUpgrade(tag,sender)
	ManagerSound.playNormalButtonSound()
	-- gdump(sender.data,"ScienceData")
	if FactoryBO.isProducting(BUILD_ID_SCIENCE) then
		local num = #FactoryBO.getWaitProducts(BUILD_ID_SCIENCE)
		if num >= VipBO.getWaitQueueNum() then  -- 队列满了
			Toast.show(CommonText[366][3])
			return
		end
	end
			
	Loading.getInstance():show()
	ScienceBO.asynUpgrade(function()
			Loading.getInstance():unshow()
		end, sender.data.scienceId)

end

function ScienceStudyTableView:openDetail(tag,sender)
	ManagerSound.playNormalButtonSound()
	gdump(sender.data,"ScienceData")
	require("app.dialog.ScienceInfoDialog").new(sender.data):push()
end

function ScienceStudyTableView:onAccelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_SCIENCE, sender.scienceId, {buildingId = BUILD_ID_SCIENCE, schedulerId = sender.schedulerId}):push()
end

function ScienceStudyTableView:onCancelProduct(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCancel()
		Loading.getInstance():unshow()
		-- self:reloadData()
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[502], function()
			Loading.getInstance():show()
			ScienceBO.asynCancelProduct(doneCancel,sender.schedulerId)
		end):push()
end

function ScienceStudyTableView:update(dt)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell and cell.productData then
			if cell.productData[1].state == 1 then
				local leftTime = FactoryBO.getProductTime(BUILD_ID_SCIENCE, cell.schedulerId)
				cell.timeBar:setPercent((cell.totalTime - leftTime) / cell.totalTime)
				cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
			else
				cell.timeBar:setPercent(0)
				cell.timeBar.label:setString(CommonText[503])
			end
			
		end
	end
end

function ScienceStudyTableView:onUpgradeUpdate()
	ScienceBO.sortScience()
	self:reloadData()
end

function ScienceStudyTableView:onExit()
	ScienceStudyTableView.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end

--------------------------------------------------------------------
-- 科技馆view
--------------------------------------------------------------------

local ScienceView = class("ScienceView", UiNode)

SCIENCE_FOR_BUILD = 1
SCIENCE_FOR_STUDY = 2

function ScienceView:ctor(buildingId, viewFor)
	ScienceView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	viewFor = viewFor or SCIENCE_FOR_BUILD
	self.m_viewFor = viewFor
	self.m_buildingId = buildingId
end

function ScienceView:onEnter()
	ScienceView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_buildLv = BuildMO.getBuildLevel(self.m_buildingId)

	self:showTitle()

	self.m_BuildUpgradeView = nil

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))

	local buildLv = self.m_buildLv
	if buildLv == 0 then -- 需要建造
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
		container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
		self:showUpgrade(container)
	else
		local function createDelegate(container, index)
			self.m_BuildUpgradeView = nil
			if index == 1 then  -- 建造
				self:showUpgrade(container)
			elseif index == 2 then -- 研究
				self:showStudy(container)
			end
		end

		local function clickDelegate(container, index)

		end

		--  "建造", "研究"
		local pages = {CommonText[70], CommonText[148]}
		local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
		local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
		pageView:setPageIndex(self.m_viewFor)
		self.m_pageView = pageView

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
		line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
		line:setScaleY(-1)
		line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	end
end

function ScienceView:onExit()
	ScienceView.super.onExit(self)
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function ScienceView:showTitle()
	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

function ScienceView:showUpgrade(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	self.m_BuildUpgradeView = view
end

function ScienceView:showStudy(container)
	local view = ScienceStudyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function ScienceView:onBuildUpdate(event)
	self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
	self:showTitle()
end

function ScienceView:doCommand(command, callback)
	if command == "science_study" then
		if not self.m_pageView then return end

		self.m_pageView:setPageIndex(2)
	elseif command == "build" then
		if self.m_BuildUpgradeView then
			self.m_BuildUpgradeView:onBuildUpgrade(2, self:getUiName())
		end
	end
end

return ScienceView