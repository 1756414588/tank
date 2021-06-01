--
-- 征收记录 DIALOG
-- DATA:20170721
--
local LevyRecordTableView = class("LevyRecordTableView", TableView)

function LevyRecordTableView:ctor(size)
	LevyRecordTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)
	self.dataList = {}
end

function LevyRecordTableView:onEnter()
	LevyRecordTableView.super.onEnter(self)
end

function LevyRecordTableView:numberOfCells()
	return #self.dataList
end

function LevyRecordTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function LevyRecordTableView:createCellAtIndex(cell, index)
	LevyRecordTableView.super.createCellAtIndex(self, cell, index)
	local _data = self.dataList[index]

	-- 时间
	local timLabel = ui.newTTFLabel({text = _data.recvTime, font = G_FONT, size = FONT_SIZE_LIMIT,
			color = cc.c3b(180,180,180), algin = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_CENTER}):addTo(cell)
	timLabel:setPosition(self.m_cellSize.width * 0.15, self.m_cellSize.height * 0.5)
	
    --事件
	local action = RichLabel.new(_data.recvAction, cc.size(self.m_cellSize.width * 0.60, 0)):addTo(cell)
	action:setPosition(self.m_cellSize.width * 0.35, self.m_cellSize.height * 0.5 + action:getHeight() * 0.5)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width * 0.95,2))
	line:setAnchorPoint(cc.p(0.5,0))
	line:setPosition(self.m_cellSize.width * 0.5 , 0)

	return cell
end

function LevyRecordTableView:loadData(data)
	-- 接收数据
	self.dataList = {}
	for index = 1 ,#data do
		local _db = data[index]
		local time = os.date("%Y.%m.%d\n%H:%M:%S", _db.recvTime) -- 时间
		local strs = UserMO.getResourceData(_db.type , _db.awardId)
		local actions = {{content = _db.nick, color = cc.c3b(49,206,49), size=FONT_SIZE_TINY}, 
			{content = CommonText[1065][2],color = cc.c3b(180,180,180), size=FONT_SIZE_TINY},
			{content = strs.name .. "*" .. _db.count, color = cc.c3b(49,206,49), size=FONT_SIZE_TINY},
			{content = " "..CommonText[1065][3],color = cc.c3b(180,180,180), size=FONT_SIZE_TINY},
			{content = _db.mplt .. CommonText[1017][1], color = cc.c3b(49,206,49), size=FONT_SIZE_TINY}}

		local out = {}
		out.recvTime = time
		out.recvAction = actions
		self.dataList[#self.dataList + 1] = out
	end

	self:reloadData()
end

function LevyRecordTableView:onExit()
	LevyRecordTableView.super.onExit(self)
end

-----------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local LevyRecordDialog = class("LevyRecordDialog", Dialog)

function LevyRecordDialog:ctor(airshipid)
	LevyRecordDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 840)})
	self.airshipid = airshipid
end

function LevyRecordDialog:onEnter()
	LevyRecordDialog.super.onEnter(self)
	self:setTitle(CommonText[1065][1])  -- 编制

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(520, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	-- 背景模版
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(520 - 40, 810 - 80))
	bg:setCapInsets(cc.rect(50 , 50 ,34 , 13))
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 12)

	-- 列表
	local view = LevyRecordTableView.new(cc.size(520 - 40 - 60,810 - 80 - 70)):addTo(bg)
	view:setAnchorPoint(cc.p(0.5,0.5))
	view:setPosition(bg:getContentSize().width * 0.5, bg:getContentSize().height * 0.5 - 10)
	self.view = view
	
	-- 时间
	ui.newTTFLabel({text = CommonText[619][1], font = G_FONT, size = FONT_SIZE_LIMIT, algin = ui.TEXT_VALIGN_CENTER, valign = ui.TEXT_VALIGN_CENTER
		, color = cc.c3b(180,180,180), x = bg:getContentSize().width * 0.15 , y = bg:getContentSize().height - 25}):addTo(bg)

	-- 事件
	ui.newTTFLabel({text = CommonText[619][2], font = G_FONT, size = FONT_SIZE_LIMIT, algin = ui.TEXT_VALIGN_CENTER, valign = ui.TEXT_VALIGN_CENTER
		, color = cc.c3b(180,180,180), x = bg:getContentSize().width * 0.6 , y = bg:getContentSize().height - 25}):addTo(bg)

	AirshipBO.GetRecvAirshipProduceAwardRecord(handler(self,self.LoadInfo),self.airshipid)
end

function LevyRecordDialog:LoadInfo(data)
	if self.view then
		self.view:loadData(data)
	end
end

function LevyRecordDialog:onExit()
	LevyRecordDialog.super.onExit(self)
end

return LevyRecordDialog