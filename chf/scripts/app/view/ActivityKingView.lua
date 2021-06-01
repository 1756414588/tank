--
-- Author: Gss
-- Date: 2018-12-05 17:08:04
--
-- 最强王者活动  ActivityKingView

local ActivityKingAwardTableView = class("ActivityKingAwardTableView", TableView)

function ActivityKingAwardTableView:ctor(size,data,kind)
	ActivityKingAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 180)
	self.listData = ActivityCenterMO.getKingInfoByKind(kind)
	self.m_data = data
	self.m_status = PbProtocol.decodeArray(data.status) or {}
	self.m_point = data.points
end

function ActivityKingAwardTableView:onEnter()
	ActivityKingAwardTableView.super.onEnter(self)
end

function ActivityKingAwardTableView:numberOfCells()
	return #self.listData
end

function ActivityKingAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityKingAwardTableView:createCellAtIndex(cell, index)
	ActivityKingAwardTableView.super.createCellAtIndex(self, cell, index)
	local record = self.listData[index]

	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell, -1)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 20, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, line:getContentSize().height + 10)

	local descBg = display.newSprite(IMAGE_COMMON .. 'info_Bg_12.png'):addTo(cell, -1)
	descBg:setAnchorPoint(cc.p(0, 0.5))
	descBg:setPosition(20, self.m_cellSize.height - 30)

	local desc = UiUtil.label(string.format("本阶段达到%d积分",record.cond)):addTo(cell)
	desc:setAnchorPoint(cc.p(0, 0.5))
	desc:setPosition(60,descBg:y())

	local left = UiUtil.label("("):rightTo(desc,20)
	local myPoint = UiUtil.label(self.m_point,nil,COLOR[6]):rightTo(left)
	local limit = UiUtil.label("/"..record.cond..")"):rightTo(myPoint)

	local awards = json.decode(record.awardList)
	for index = 1 , #awards do
		local award = awards[index]
		local kind = award[1]
		local id = award[2]
		local count = award[3]
		local item = UiUtil.createItemView(kind, id, {count = count}):addTo(cell)
		item:setScale(0.7)
		item:setPosition(62.5 + (index - 1) * 108, 90)
		UiUtil.createItemDetailButton(item)

		local resData = UserMO.getResourceData(kind, id)
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = item:getPositionX(), y = item:y() - 50, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	end

	-- 领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(cell):pos(self.m_cellSize.width - 80,70)
	btn:setLabel(CommonText[870][2])
	btn:setEnabled(self.m_point >= record.cond)
	btn.id = record.id

	for i,v in ipairs(self.m_status) do
		if v.v1 == record.id and v.v2 == 1 then
			btn:setLabel(CommonText[870][3])
			btn:setEnabled(false)
		end
	end

	if self.m_point >= record.cond then
		myPoint:setString(record.cond)
		myPoint:setColor(COLOR[2])
		limit:setPosition(myPoint:x() + myPoint:width(), myPoint:y())
	end
	return cell
end

function ActivityKingAwardTableView:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.getActivityKingAwards(function (data)
		local statusList = PbProtocol.decodeArray(data)
		self.m_status = statusList

		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end,sender.id)
end

function ActivityKingAwardTableView:onExit()
	ActivityKingAwardTableView.super.onExit(self)
end


-----------------------------------------------------------------------------------


local ActivityKingRankTableView = class("ActivityKingRankTableView", TableView)

function ActivityKingRankTableView:ctor(size,data,activity)
	ActivityKingRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 120)
	self.m_rankData = data
	self.m_activity = activity

	self._rankIndex_data = PbProtocol.decodeArray(self.m_rankData["firstRankInfo"])
end

function ActivityKingRankTableView:onEnter()
	ActivityKingRankTableView.super.onEnter(self)
end

function ActivityKingRankTableView:numberOfCells()
	return #self.m_rankData.firstRankInfo
end

function ActivityKingRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityKingRankTableView:createCellAtIndex(cell, index)
	ActivityKingRankTableView.super.createCellAtIndex(self, cell, index)
	local record = self._rankIndex_data[index]
	local line = display.newScale9Sprite(IMAGE_COMMON .. "awake_line.png"):addTo(cell, -1)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 20, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, line:getContentSize().height + 10)

	local icon = display.newSprite(IMAGE_COMMON .. "rank_1.png"):addTo(cell)
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(40,self.m_cellSize.height / 2)

	local name = UiUtil.label(""..index):addTo(cell)
	name:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	if record.value ~= "" then
		name:setString(record.value)
	else
		name:setString(CommonText[778])
	end

	-- 领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(cell):pos(self.m_cellSize.width - 80,self.m_cellSize.height / 2)
	btn:setLabel(CommonText[3001][index])
	btn.kind = record.key
	return cell
end

function ActivityKingRankTableView:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local kind = sender.kind
	local activity = self.m_activity
	ActivityCenterBO.getIndexRankinfo(function (data)
		require("app.dialog.ActivityKingRankDialog").new(data,kind,activity):push()
	end,kind)
end

function ActivityKingRankTableView:onExit()
	ActivityKingRankTableView.super.onExit(self)
end




------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local ActivityKingView = class("ActivityKingView", UiNode)

function ActivityKingView:ctor(activity)
	ActivityKingView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityKingView:onEnter()
	ActivityKingView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	local function createDelegate(container, index)
		if self.time_lab then
			self.time_lab:removeSelf()
			self.time_lab = nil
		end

		if self.activity_time then
			self.activity_time:removeSelf()
			self.activity_time = nil
		end

		if index >= 1 and index <= 3 then
			ActivityCenterBO.getActivityInfoByKind(function (data)
				self:showActivityInfo(container,data,index)
			end,index)
		elseif index == 4 then
			ActivityCenterBO.GetAactivityAllRanks(function (data)
				self:showRank(container,data)
			end)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = CommonText[3000]

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local stage = ActivityCenterMO.getActivityStage(self.m_activity)
	pageView:setPageIndex(stage)
end

function ActivityKingView:showActivityInfo(container, data, index)
	local kill = UiUtil.label(CommonText[3002][index]):addTo(container)
	kill:setAnchorPoint(cc.p(0, 0.5))
	kill:setPosition(30,container:height() - 30)
	local killNum = UiUtil.label(data.totalNumber,nil,COLOR[2]):rightTo(kill)

	local point = UiUtil.label(CommonText[3003]):alignTo(kill, -40, 1)
	local pointNum = UiUtil.label(data.points,nil,COLOR[2]):rightTo(point)
	local time = UiUtil.label(CommonText[3004]):alignTo(point, -40, 1)
	local leftTimeLab = UiUtil.label("00",nil,COLOR[2]):rightTo(time)

	local function tick()
		local leftTime = data.endTime / 1000 - ManagerTimer.getTime()
		if leftTime > 0 and ManagerTimer.getTime() - data.startTime / 1000 >= 0 then
			leftTimeLab:setString(UiUtil.strActivityTime(leftTime))
		else
			if ManagerTimer.getTime() - data.startTime / 1000 <= 0 then
				leftTimeLab:setString(CommonText[3005])
			else
				leftTimeLab:setString(CommonText[852])
			end
		end
	end
	tick()
	leftTimeLab:performWithDelay(tick, 1, 1)

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.king):push()
		end):addTo(container)
	detailBtn:setPosition(container:width() - 55, container:height() - 50)

	--奖励展示
	local awardBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	awardBg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 180))
	awardBg:setCapInsets(cc.rect(80, 60, 1, 1))
	awardBg:setPosition(container:width() / 2,container:height() - awardBg:height() / 2 - 140)

	local view = ActivityKingAwardTableView.new(cc.size(awardBg:width() - 10, awardBg:height() - 70), data, index):addTo(awardBg)
	view:setPosition(0, 20)
	view:reloadData()

end

function ActivityKingView:showRank(container,data)
	local kill = UiUtil.label(CommonText[3006][1]):addTo(container)
	kill:setAnchorPoint(cc.p(0, 0.5))
	kill:setPosition(30,container:height() - 30)
	local killNum = UiUtil.label(data.points,nil,COLOR[2]):rightTo(kill)

	local point = UiUtil.label(CommonText[3006][2]):alignTo(kill, -40, 1)
	local pointNum = UiUtil.label(data.partyPoint,nil,COLOR[2]):rightTo(point)
	local time = UiUtil.label(CommonText[3004]):alignTo(point, -40, 1)
	local leftTimeLab = UiUtil.label("00",nil,COLOR[2]):rightTo(time)

	local function tick()
		local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
		if leftTime > 0 then
			leftTimeLab:setString(UiUtil.strActivityTime(leftTime))
		else
			leftTimeLab:setString(CommonText[852])
		end
	end
	tick()
	leftTimeLab:performWithDelay(tick, 1, 1)

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.king):push()
		end):addTo(container)
	detailBtn:setPosition(container:width() - 55, container:height() - 50)

	--排行
	local awardBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	awardBg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 180))
	awardBg:setCapInsets(cc.rect(80, 60, 1, 1))
	awardBg:setPosition(container:width() / 2,container:height() - awardBg:height() / 2 - 140)

	local rankView = ActivityKingRankTableView.new(cc.size(awardBg:width() - 10, awardBg:height() - 70), data, self.m_activity):addTo(awardBg)
	rankView:setPosition(0, 20)
	rankView:reloadData()
end

function ActivityKingView:onExit()
	ActivityKingView.super.onExit(self)

end

return ActivityKingView