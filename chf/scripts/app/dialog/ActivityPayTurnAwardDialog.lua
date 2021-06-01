--
-- Author: Gss
-- Date: 2018-11-06 16:37:02
--
--  充值转盘全抽奖励预览

local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size, param)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	local height = size.height
	self.m_param = param
	if self.m_param and #self.m_param > 0 then
		height = math.ceil(#self.m_param / 3) * 126
	end
	self.m_cellSize = cc.size(size.width, height)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	for index=1,#self.m_param do
		local award = self.m_param[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count}):addTo(cell)
		itemView:setScale(0.7)
		itemView:setPosition(5 + ((index - 1) % 3 + 1 - 0.5) * ((self.m_cellSize.width - 10) / 3) ,
							 self.m_cellSize.height - math.floor((index - 1) / 3) * 126 - 40)
		UiUtil.createItemDetailButton(itemView, cell, true)
		local propDB = UserMO.getResourceData(award.type, award.id)
		UiUtil.label(propDB.name, nil,COLOR[propDB.quality or 1]):addTo(cell):pos(itemView:x(),itemView:y()-60)
	end
	return cell
end

function ContentTableView:numberOfCells()
	return 1
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end
------------------------------------------------------------------------------
-- 充值转盘全抽奖励预览 dialog
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ActivityPayTurnAwardDialog = class("ActivityPayTurnAwardDialog", Dialog)

function ActivityPayTurnAwardDialog:ctor(data)
	ActivityPayTurnAwardDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834 - 130)})
	self:size(582,834 - 130)
	self.m_data = data
end

function ActivityPayTurnAwardDialog:onEnter()
	ActivityPayTurnAwardDialog.super.onEnter(self)
	self:setTitle(CommonText[771])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804 - 130))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	UiUtil.sprite9("info_bg_15.png", 30, 30, 1, 1, 500, self:getBg():height()-210)
		:addTo(self:getBg()):pos(self:getBg():width()/2,(self:getBg():height()-290)/2+170)
	local view = ContentTableView.new(cc.size(500, self:getBg():height()-240), self.m_data)
		:addTo(self:getBg()):pos(42,143)
	view:reloadData()

	--确定
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, function ()
		local statsAward = CombatBO.addAwards(self.m_data)
		UiUtil.showAwards(statsAward)
		self:pop()
	end):addTo(self:getBg())
	btn:setLabel(CommonText[1])
	btn:setPosition(self:getBg():width() / 2, btn:height() / 2 + 35)
end

function ActivityPayTurnAwardDialog:onExit()
	ActivityPayTurnAwardDialog.super.onExit(self)
end

function ActivityPayTurnAwardDialog:CloseAndCallback()
	local statsAward = CombatBO.addAwards(self.m_data)
	UiUtil.showAwards(statsAward)
end

return ActivityPayTurnAwardDialog
