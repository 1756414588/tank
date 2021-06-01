

------------------------------------------------------------------------------
-- 极限副本扫荡奖励
------------------------------------------------------------------------------

local ExtremeWipeAwardTableView = class("ExtremeWipeAwardTableView", TableView)

function ExtremeWipeAwardTableView:ctor(size, awards)
	ExtremeWipeAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 145)

	self.m_awards = awards

	gdump(self.m_awards, "ExtremeWipeAwardTableView 奖励")
end

function ExtremeWipeAwardTableView:numberOfCells()
	return #self.m_awards.awards
end

function ExtremeWipeAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ExtremeWipeAwardTableView:createCellAtIndex(cell, index)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local award = self.m_awards.awards[index]

	local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
	itemView:setPosition(80, self.m_cellSize.height / 2)

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self.m_cellSize.width - 120 - 25, y = 114, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	label:setAnchorPoint(cc.p(0, 0.5))

	local countLabel = ui.newTTFLabel({text = award.count, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	countLabel:setAnchorPoint(cc.p(0, 0.5))

	return cell
end

------------------------------------------------------------------------------
-- 极限副本扫荡获得奖励
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ExtremeWipeAwardDialog = class("ExtremeWipeAwardDialog", Dialog)

function ExtremeWipeAwardDialog:ctor(awards)
	ExtremeWipeAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	
	self.m_awards = awards
end

function ExtremeWipeAwardDialog:onEnter()
	ExtremeWipeAwardDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	self:setTitle(CommonText[395])  -- 扫荡奖励

	self:showUI()
end

function ExtremeWipeAwardDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local view = ExtremeWipeAwardTableView.new(cc.size(526, 740), self.m_awards):addTo(container)
	view:setPosition((container:getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

return ExtremeWipeAwardDialog
