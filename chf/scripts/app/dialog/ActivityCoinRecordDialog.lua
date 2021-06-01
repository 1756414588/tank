--
-- yansong
-- Date: 2017-03-07 
--
-- 金币记录

local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 100)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)

	local data = self.alldatalist[index]

	-- 时间
	local timeview = ui.newTTFLabel({text = data.time, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(cell)
	timeview:setAnchorPoint(0,0.5)
	timeview:setPosition(self.m_cellSize.width * 0.05,self.m_cellSize.height / 2)

	-- 记录信息
	local recordview = ui.newTTFLabel({text = data.value, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1],
	 algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER, dimensions = cc.size(330, 70)}):addTo(cell)
	recordview:setAnchorPoint(0,0.5)
	recordview:setPosition(timeview:getPositionX() + timeview:getContentSize().width * 1.1,self.m_cellSize.height / 2)

	-- 分割线
	if index ~= #ActivityCenterMO.worshipRecord then
		local lines = display.newSprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(cell)
		lines:setAnchorPoint(0.5,0)
		lines:setPosition(self.m_cellSize.width / 2 , 0)
		lines:setScaleX(2)
	end

	return cell
end

function ContentTableView:numberOfCells()
	return #self.alldatalist
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI()

	self.alldatalist = {}

	local datalist = ActivityCenterMO.worshipRecord

	-- 根据时间排序
	table.sort(datalist ,function(a,b) return a.time < b.time end)

	for index=1,#datalist do
		local alldata = {}
		local data = datalist[index]
		local time = os.date("%m-%d %H:%M",data.time)

		local act_data = ActivityCenterMO.getWorshipGodDataTimes(index)
		local price = act_data.price

		local str = string.format(CommonText[20204], price, data.value, price * data.value * 0.01)
		alldata.time = time
		alldata.value = str

		self.alldatalist[#self.alldatalist + 1] = alldata
	end


	self:reloadData()
end

------------------------------------------------------------------------------
-- 金币记录view
------------------------------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ActivityCoinRecordDialog = class("ActivityCoinRecordDialog", Dialog)

-- tankId: 需要改装的tank
function ActivityCoinRecordDialog:ctor(begintime)
	ActivityCoinRecordDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
end

function ActivityCoinRecordDialog:onEnter()
	ActivityCoinRecordDialog.super.onEnter(self)
	self:setTitle(CommonText[20203])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	frame:setPreferredSize(cc.size(500, self:getBg():height()-110))
	frame:setCapInsets(cc.rect(130, 40, 1, 1))
	frame:align(display.CENTER_TOP,self:getBg():width()/2,self:getBg():height()-70)

	local view = ContentTableView.new(cc.size(490, self:getBg():height()-142))
		:addTo(self:getBg()):pos(45,66)
	view:updateUI()
end

function ActivityCoinRecordDialog:onExit()
	ActivityCoinRecordDialog.super.onExit(self)
end

return ActivityCoinRecordDialog
