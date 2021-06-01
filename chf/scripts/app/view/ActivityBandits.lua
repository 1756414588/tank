--
-- Author: xiaoxing
-- Date: 2017-03-15 10:54:01
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.rhand = rhand
	self.m_cellSize = cc.size(size.width, 76)
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	if index == #self.m_activityList + 1 then -- 最后一个按钮
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_normal.png")
		normal:setPreferredSize(cc.size(500, 76))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_16_selected.png")
		selected:setPreferredSize(cc.size(500, 76))
		local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onNextCallback))
		btn:setLabel(CommonText[577])
		cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		return cell
	end
	local data = self.m_activityList[index]
	local t = nil
	if index <= 3 then
		t = display.newSprite(IMAGE_COMMON.."rank_"..index ..".png")
			:addTo(cell):pos(54,self.m_cellSize.height/2)
	else
		t = UiUtil.label(index):addTo(cell):pos(54,self.m_cellSize.height/2)
	end
	local c = ArenaBO.getRankColor(index)
	if index > 10 then c = cc.c3b(255, 255, 255) end
	t = UiUtil.label(data.name, nil, c)
		:addTo(cell):alignTo(t,138)
	t = UiUtil.label(data.killNum)
		:addTo(cell):alignTo(t,170)
	t = UiUtil.label(data.score)
		:addTo(cell):alignTo(t,122)
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width-10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:numberOfCells()
	if #self.m_activityList < RANK_PAGE_NUM or #self.m_activityList >= 1000 then
		return #self.m_activityList
	else
		return #self.m_activityList + 1
	end
end

function ContentTableView:onNextCallback(tag, sender)
	local function showData(data)
		Loading.getInstance():unshow()
		local oldHeight = self:getContainer():getContentSize().height
		for k,v in ipairs(PbProtocol.decodeArray(data.rebelRanks)) do
			table.insert(self.m_activityList,v)
		end
		self:reloadData()
		local delta = self:getContainer():getContentSize().height - oldHeight
		self:setContentOffset(cc.p(0, -delta))
	end

	local page = math.ceil(#self.m_activityList / RANK_PAGE_NUM)
	RebelBO.getActRebelRank(page,showData)
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data or {}
	self:reloadData()
end
----------------------------------------------
local ActivityBandits = class("ActivityBandits", UiNode)

function ActivityBandits:ctor(activity)
	ActivityBandits.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityBandits:onEnter()
	ActivityBandits.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
	self.content = display.newNode():addTo(self:getBg()):size(self:getBg():width(),self:getBg():height())
	RebelBO.getActRebelRank(0,function(data)
			self:showUI(data)
		end)
end

function ActivityBandits:showUI(data)
	self.data = data
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "bar_bandit.jpg"):addTo(self.content)
	infoBg:setPosition(self.content:getContentSize().width / 2,self.content:getContentSize().height - infoBg:getContentSize().height)
	-- 活动时间
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(20, 32)
	self.m_timeLab = timeLab

	--活动说明
	-- local infoTit = ui.newTTFLabel({text = CommonText[886][1], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(infoBg)
	-- infoTit:setAnchorPoint(cc.p(0, 0.5))
	-- infoTit:setPosition(20, 20)

	-- local infoLab = ui.newTTFLabel({text =CommonText[5026], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_LEFT}):addTo(infoBg)
	-- infoLab:rightTo(infoTit)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.actRebel):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 30)

	local t = UiUtil.label(CommonText[20123]):addTo(self.content):align(display.LEFT_CENTER, 35, infoBg:y() - infoBg:height()/2 - 20)
	UiUtil.label(data.killNum,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[764][1]):alignTo(t, -25, 1)
	UiUtil.label(data.score,nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(CommonText[20028].."："):alignTo(t, -25, 1)
	local rank = UiUtil.label(data.rank == 0 and CommonText[392] or data.rank,nil,COLOR[2]):rightTo(t)

	local bg = UiUtil.sprite9("info_bg_9.png", 80, 60, 1, 1, self.content:getContentSize().width-20, t:y() - 150)
	bg:addTo(self.content):pos(self.content:width()/2,bg:height()/2+130)
	t = UiUtil.label(CommonText[396][1],nil,cc.c3b(150,150,150)):addTo(bg):pos(85,bg:height()-24)
	t = UiUtil.label(CommonText[396][2],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 138)
	t = UiUtil.label(CommonText[20124],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 170)
	t = UiUtil.label(CommonText[770][3],nil,cc.c3b(150,150,150)):addTo(bg):alignTo(t, 122)
	local view = ContentTableView.new(cc.size(560, bg:height()-55))
		:addTo(bg):pos(30,10)
	view:updateUI(PbProtocol.decodeArray(data.rebelRanks))

	UiUtil.label(string.format(CommonText[20125],RebelMO.queryActId(1).point)):addTo(self.content):align(display.LEFT_CENTER,40,110)
	UiUtil.button("btn_9_normal.png","btn_9_selected.png",nil,handler(self, self.lookAward),CommonText[769][1])
		:addTo(self.content):pos(110,70)
	self.getBtn = UiUtil.button("btn_11_normal.png","btn_11_selected.png","btn_9_disabled.png",handler(self, self.getAward),CommonText[769][3])
		:addTo(self.content):pos(self.content:width() - 110,70)

	if table.isexist(data,"getReward") then
		if data.getReward then
			self.getBtn:setLabel(CommonText[777][3])
			self.getBtn:setEnabled(false)
		end
	else
		self.getBtn:setEnabled(false)
	end
end

function ActivityBandits:lookAward()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(ACTIVITY_ID_BANDITS):push()
end

function ActivityBandits:getAward()
	ManagerSound.playNormalButtonSound()
	RebelBO.actRebelRankReward(function()
			self.getBtn:setLabel(CommonText[777][3])
			self.getBtn:setEnabled(false)
		end)
end

function ActivityBandits:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
end

return ActivityBandits