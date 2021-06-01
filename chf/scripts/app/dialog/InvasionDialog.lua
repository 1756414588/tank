
------------------------------------------------------------------------------
-- 敌军来袭TableView
------------------------------------------------------------------------------
local InvasionTableView = class("InvasionTableView", TableView)

-- 当前的阵型
function InvasionTableView:ctor(size)
	InvasionTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)
end

function InvasionTableView:onEnter()
	InvasionTableView.super.onEnter(self)

	self.m_invasions = ArmyMO.getInvasionsByState(ARMY_STATE_MARCH)

	self.m_timerHandler = ManagerTimer.addTickListener(handler(self, self.onTick))
	self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onInvasionUpdate))
end

function InvasionTableView:onExit()
	InvasionTableView.super.onExit(self)
	if self.m_timerHandler then
		ManagerTimer.removeTickListener(self.m_timerHandler)
		self.m_timerHandler = nil
	end
	if self.m_armyHandler then
		Notify.unregister(self.m_armyHandler)
		self.m_armyHandler = nil
	end
end

function InvasionTableView:numberOfCells()
	return #self.m_invasions
end

function InvasionTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function InvasionTableView:createCellAtIndex(cell, index)
	InvasionTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
	bg:setCapInsets(cc.rect(220, 80, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local invasion = self.m_invasions[index]

	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, invasion.portrait):addTo(cell)
	itemView:setPosition(100, self.m_cellSize.height / 2)
	itemView:setScale(0.55)

	-- 即将来袭
	local name = ui.newTTFLabel({text = invasion.name .. " LV." .. invasion.lv .. " " .. CommonText[362], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)

	local label = ui.newTTFLabel({text = CommonText[363][1] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local pos = WorldMO.decodePosition(invasion.target)

	if pos.x == WorldMO.pos_.x and pos.y == WorldMO.pos_.y then  -- 我方基地
		local label = ui.newTTFLabel({text = CommonText[363][2] .. "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	else
		local label = ui.newTTFLabel({text = "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_TINY, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))
	end

	local leftTime = SchedulerSet.getTimeById(invasion.schedulerId)

	local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, label:getPositionY() - 30):addTo(cell)
	clock:setAnchorPoint(cc.p(0, 0.5))
	local time = ui.newBMFontLabel({text =  UiUtil.strBuildTime(leftTime), font = "fnt/num_2.fnt"}):addTo(cell)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
	cell.timeLabel = time

	cell.invasion = invasion
	return cell
end

function InvasionTableView:onTick()
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			local invasion = cell.invasion
			local leftTime = SchedulerSet.getTimeById(invasion.schedulerId)
			cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
		end
	end
end

function InvasionTableView:onInvasionUpdate()
	self.m_invasions = ArmyMO.getInvasionsByState(ARMY_STATE_MARCH)
	self:reloadData()
end

------------------------------------------------------------------------------
-- 敌军来袭弹出框
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local InvasionDialog = class("InvasionDialog", Dialog)

function InvasionDialog:ctor()
	InvasionDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
end

function InvasionDialog:onEnter()
	InvasionDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[361][1]) -- 敌军来袭

	self:showUI()
end

function InvasionDialog:showUI()
	local view = InvasionTableView.new(cc.size(526, 748)):addTo(self:getBg())
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2, 44)
	-- view:addEventListener("READER_FORMATION_EVENT", function(event) if choseFormationCallback then choseFormationCallback(event.formation) end  end)
	view:reloadData()

	local aids = ArmyMO.getAllAids()

	if #aids > 0 then -- 有驻军，则设置驻军
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onGuardCallback)):addTo(self:getBg())
		btn:setPosition(self:getBg():getContentSize().width / 2 - 120, 26)
		btn:setLabel(CommonText[495])
	else
		-- 查看部队
		local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onArmyCallback)):addTo(self:getBg())
		btn:setPosition(self:getBg():getContentSize().width / 2 - 120, 26)
		btn:setLabel(CommonText[364])
	end

	-- 设置防守
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSettingCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2 + 120, 26)
	btn:setLabel(CommonText[19])
end

function InvasionDialog:onGuardCallback(tag, sender)
	self:pop(function() require("app.dialog.GuardDialog").new():push() end)
end

function InvasionDialog:onArmyCallback(tag, sender)
	self:pop(function()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_UI, 2):push()
		end)
end

function InvasionDialog:onSettingCallback(tag, sender)
	self:pop(function()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_UI):push()
		end)
end

return InvasionDialog