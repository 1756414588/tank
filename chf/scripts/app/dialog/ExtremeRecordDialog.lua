
------------------------------------------------------------------------------
-- 探险记事tableview
------------------------------------------------------------------------------

local ExtremeRecordTableView = class("ExtremeRecordTableView", TableView)

local ExtremeRecordTableView = class("ExtremeRecordTableView", TableView)

function ExtremeRecordTableView:ctor(size, extremeId, getExtreme)
	ExtremeRecordTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 150)
	self.m_extremeId = extremeId
	self.m_getExtreme = getExtreme
end

function ExtremeRecordTableView:numberOfCells()
	return 4
end

function ExtremeRecordTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ExtremeRecordTableView:createCellAtIndex(cell, index)
	ExtremeRecordTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(cell)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	if index == 1 or index == 2 then -- 首次通关, 最近通关
		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
		titleBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 8)

		local name = ui.newTTFLabel({text = CommonText[376][index], font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	end

	local extremeData = nil
	if index == 1 then
		extremeData = self.m_getExtreme.first
		if not table.isexist(extremeData, "name") then extremeData = nil end
		-- dump(extremeData, "111111111")
	else
		if not self.m_getExtreme.last then self.m_getExtreme.last = {} end

		extremeData = self.m_getExtreme.last[index - 1]
	end

	local enabled = true
	if not extremeData then
		enabled = false
		extremeData = {}
		extremeData.name = CommonText[108] -- 无
		extremeData.lv = 0
		extremeData.strTime = ""
	else
		extremeData.strTime = os.date("%c", extremeData.time)
	end


	local name = ui.newTTFLabel({text = extremeData.name .. "  LV." .. extremeData.lv, font = G_FONT, size = FONT_SIZE_SMALL, x = 32, y = 86, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))

	local time = ui.newTTFLabel({text = extremeData.strTime, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	time:setAnchorPoint(cc.p(0, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_replay_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_replay_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_replay_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onPlayCallback))
	btn:setEnabled(enabled)
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width - 50, self.m_cellSize.height / 2)

	return cell
end

function ExtremeRecordTableView:onPlayCallback(tag, sender)
	local function doneCallback()
		Loading.getInstance():unshow()
		
		require("app.view.BattleView").new():push()
	end

	Loading.getInstance():show()
	CombatBO.asynExtremeRecord(doneCallback, self.m_extremeId, sender.index - 1)
end

------------------------------------------------------------------------------
-- 探险记事弹出框
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExtremeRecordDialog = class("ExtremeRecordDialog", Dialog)

function ExtremeRecordDialog:ctor(extremeId, getExtreme)
	ExtremeRecordDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	self.m_extremeId = extremeId
	self.m_getExtreme = getExtreme
end

function ExtremeRecordDialog:onEnter()
	ExtremeRecordDialog.super.onEnter(self)
	
	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[291])

	self:showUI()
end

function ExtremeRecordDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local view = ExtremeRecordTableView.new(cc.size(526, 748), self.m_extremeId, self.m_getExtreme):addTo(container)
	view:setPosition((container:getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

return ExtremeRecordDialog