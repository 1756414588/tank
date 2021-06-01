
------------------------------------------------------------------------------
-- 驻防TableView
------------------------------------------------------------------------------

local GuardTableView = class("GuardTableView", TableView)

-- 当前的阵型
function GuardTableView:ctor(size)
	GuardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
end

function GuardTableView:onEnter()
	GuardTableView.super.onEnter(self)

	self.m_aids = ArmyMO.getAllAids()
	self.m_invasions = ArmyMO.getInvasionsByState(ARMY_STATE_AID_MARCH)

	self.m_timerHandler = ManagerTimer.addTickListener(handler(self, self.onTick))
	self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onGuardUpdate))
end

function GuardTableView:onExit()
	GuardTableView.super.onExit(self)
	if self.m_timerHandler then
		ManagerTimer.removeTickListener(self.m_timerHandler)
		self.m_timerHandler = nil
	end
	if self.m_armyHandler then
		Notify.unregister(self.m_armyHandler)
		self.m_armyHandler = nil
	end
end

function GuardTableView:numberOfCells()
	return #self.m_aids + #self.m_invasions
end

function GuardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function GuardTableView:createCellAtIndex(cell, index)
	GuardTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	if index <= #self.m_aids then
		local aid = self.m_aids[index]

		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, aid.portrait):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)
		itemView:setScale(0.55)
		itemView.aid = aid

		local name = ui.newTTFLabel({text = aid.name .. " LV." .. aid.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		if aid.state == ARMY_STATE_WAITTING then -- 待命中
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onHeadCallback))

			local label = ui.newTTFLabel({text = CommonText[320][6] .. "...", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))

			-- 设置防守
			local normal = display.newSprite(IMAGE_COMMON .. "btn_wait_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_wait_selected.png")
			local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onGuardCallback))
			btn.aid = aid
			cell:addButton(btn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

			-- 返回
			local normal = display.newSprite(IMAGE_COMMON .. "btn_back_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_back_selected.png")
			local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRetreatCallback))
			btn.aid = aid
			cell:addButton(btn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 22)
		elseif aid.state == ARMY_STATE_GARRISON then
			UiUtil.createItemDetailButton(itemView, cell, true, handler(self, self.onHeadCallback))

			local label = ui.newTTFLabel({text = CommonText[320][4] .. "...", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))

			-- 防守
			local normal = display.newSprite(IMAGE_COMMON .. "btn_guard_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_guard_selected.png")
			local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onGuardCallback))
			btn.aid = aid
			cell:addButton(btn, self.m_cellSize.width - 170, self.m_cellSize.height / 2 - 22)

			-- 返回
			local normal = display.newSprite(IMAGE_COMMON .. "btn_back_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_back_selected.png")
			local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRetreatCallback))
			btn.aid = aid
			cell:addButton(btn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 22)
		end

		cell.aid = aid
	else  -- 还在行军中
		local invasion = self.m_invasions[index - #self.m_aids]

		local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, invasion.portrait):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)
		itemView:setScale(0.55)
		-- itemView.aid = aid

		local name = ui.newTTFLabel({text = invasion.name .. " LV." .. invasion.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

		local label = ui.newTTFLabel({text = CommonText[320][1], font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))

		local leftTime = SchedulerSet.getTimeById(invasion.schedulerId)

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, label:getPositionY() - 30):addTo(cell)
		clock:setAnchorPoint(cc.p(0, 0.5))
		local time = ui.newBMFontLabel({text =  UiUtil.strBuildTime(leftTime), font = "fnt/num_2.fnt"}):addTo(cell)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
		cell.timeLabel = time
		cell.schedulerId = invasion.schedulerId
	end
	return cell
end

function GuardTableView:onTick()
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell and cell.timeLabel and cell.schedulerId then
			local leftTime = SchedulerSet.getTimeById(cell.schedulerId)
			cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
		end
	end
end

function GuardTableView:onGuardUpdate()
	self.m_aids = ArmyMO.getAllAids()
	self.m_invasions = ArmyMO.getInvasionsByState(ARMY_STATE_AID_MARCH)
	self:reloadData()
end

function GuardTableView:onGuardCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[367][1])
	end

	Loading.getInstance():show()
	WorldBO.asynSetGuard(doneCallback, sender.aid)
end

function GuardTableView:onRetreatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[367][2])
	end

	Loading.getInstance():show()
	WorldBO.asynRetreatAid(doneCallback, sender.aid)
end

function GuardTableView:onHeadCallback(sender)
	ManagerSound.playNormalButtonSound()
	-- dump(sender.aid)
	local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
	ReportArmyDetailView.new(sender.aid):push()
end

------------------------------------------------------------------------------
-- 驻防Dialog
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local GuardDialog = class("GuardDialog", Dialog)

function GuardDialog:ctor()
	GuardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function GuardDialog:onEnter()
	GuardDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[365]) -- 驻军

	local function doneCallback()
		Loading.getInstance():unshow()
		self:showUI()
	end
	
	Loading.getInstance():show()
	ArmyBO.asynGetAid(doneCallback)
end

function GuardDialog:showUI()
	local view = GuardTableView.new(cc.size(526, 748)):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

return GuardDialog
