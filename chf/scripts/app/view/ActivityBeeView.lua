--
-- Author: gf
-- Date: 2015-12-07 11:37:50
--

--------------------------------------------------------------------
-- 采集 tableview
--------------------------------------------------------------------

local ActivityBeeTableView = class("ActivityBeeTableView", TableView)

function ActivityBeeTableView:ctor(size,activityId)
	ActivityBeeTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 140)
	self.activityId_ = activityId
end

function ActivityBeeTableView:onEnter()
	ActivityBeeTableView.super.onEnter(self)
	self.actBee_ = ActivityCenterMO.getActivityContentById(self.activityId_).actBee
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.onActivityUpdate))
end

function ActivityBeeTableView:numberOfCells()
	return #self.actBee_
end

function ActivityBeeTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityBeeTableView:createCellAtIndex(cell, index)
	ActivityBeeTableView.super.createCellAtIndex(self, cell, index)

	local data = self.actBee_[index]
	-- gdump(data,"ActivityBeeTableView:createCellAtIndex==")
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 40, self.m_cellSize.height))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	
	local icon = UiUtil.createItemView(ITEM_KIND_RESOURCE, data.resId)
	icon:setPosition(90,70)
	bg:addChild(icon)

	local name = ui.newTTFLabel({text = string.format(CommonText[775],UserMO.getResourceData(ITEM_KIND_RESOURCE,data.resId).name2), font = G_FONT, 
		size = FONT_SIZE_SMALL, x = 160, y = bg:getContentSize().height - 25}):addTo(bg)

	local schedule = ui.newTTFLabel({text = "(" .. ActivityCenterBO.getActivityBeeSchedule(data) .. "/" .. #data.activityCond .. ")", font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = 160, y = bg:getContentSize().height - 80}):addTo(bg)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRewardDetail))
	detailBtn.data = data
	detailBtn.data.activityId = self.activityId_
	cell:addButton(detailBtn, self.m_cellSize.width - 110, 50)
	self:updateTip(index,detailBtn)

	return cell
end

function ActivityBeeTableView:onRewardDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityBeeDialog").new(sender.data):push()
end

function ActivityBeeTableView:updateTip(index,btn)
	local actBee = self.actBee_[index]
	local count = ActivityCenterBO.getCanAwardBee(actBee)
	if count > 0 then
		UiUtil.showTip(btn, count, 60, 60)
	else
		UiUtil.unshowTip(btn)
	end
end

function ActivityBeeTableView:onActivityUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityBeeTableView:onExit()
	ActivityBeeTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

--------------------------------------------------------------------
-- 采集tableview
--------------------------------------------------------------------


--------------------------------------------------------------------
-- 排行 tableview
--------------------------------------------------------------------

local ActivityBeeRankTableView = class("ActivityBeeRankTableView", TableView)

function ActivityBeeRankTableView:ctor(size,activityId)
	ActivityBeeRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 100)
	self.activityId_ = activityId
end

function ActivityBeeRankTableView:onEnter()
	ActivityBeeRankTableView.super.onEnter(self)

	self.actBeeRank_ = ActivityCenterMO.getActivityContentById(self.activityId_).actBeeRank.beeRank
	-- gdump(self.actBeeRank_,"self.actBeeRank_==")
end

function ActivityBeeRankTableView:numberOfCells()
	return #self.actBeeRank_
end

function ActivityBeeRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityBeeRankTableView:createCellAtIndex(cell, index)
	ActivityBeeRankTableView.super.createCellAtIndex(self, cell, index)

	local data = self.actBeeRank_[index]
	-- gdump(data,"ActivityBeeRankTableView:createCellAtIndex==")
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(cell, -1)

	bg:setPreferredSize(cc.size(self.m_cellSize.width - 60, bg:getContentSize().height))
	bg:setPosition(self.m_cellSize.width / 2, 0)
	
	local icon = display.newSprite(IMAGE_COMMON .. "rank_1.png")
	icon:setPosition(50,self.m_cellSize.height / 2)
	bg:addChild(icon)

	local name = ui.newTTFLabel({text = "", font = G_FONT, 
		size = FONT_SIZE_SMALL, x = 150, y = self.m_cellSize.height / 2}):addTo(bg)
	name:setAnchorPoint(cc.p(0,0.5))
	local firstName = ActivityCenterBO.getBeeRankFirst(data)
	if firstName == "" then
		firstName = CommonText[778]
		name:setColor(COLOR[11])
	else
		name:setColor(COLOR[1])
	end
	name:setString(firstName)
	

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRewardDetail))
	detailBtn:setLabel(UserMO.getResourceData(ITEM_KIND_RESOURCE, data.resourceId).name2 .. CommonText[779])
	detailBtn.data = data
	detailBtn.data.activityId = self.activityId_
	cell:addButton(detailBtn, self.m_cellSize.width - 110, self.m_cellSize.height / 2)

	return cell
end

function ActivityBeeRankTableView:onRewardDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityBeeRankDialog").new(sender.data):push()
end

function ActivityBeeRankTableView:onExit()
	ActivityBeeRankTableView.super.onExit(self)
end

--------------------------------------------------------------------
-- 排行 tableview
--------------------------------------------------------------------

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")


local ActivityBeeView = class("ActivityBeeView", UiNode)

function ActivityBeeView:ctor(activity)
	ActivityBeeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityBeeView:onEnter()
	ActivityBeeView.super.onEnter(self)

	self:setTitle(CommonText[773])

	local function createDelegate(container, index)
		self.m_timeLab = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showBee(container)
				elseif index == 2 then 
					self:showBeeRank(container)
				end
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[774][1],CommonText[774][2]}


	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end


function ActivityBeeView:showBee(container)
	-- 活动时间
	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = container:getContentSize().height - 30}):addTo(container)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, container:getContentSize().height - 60)
	self.m_timeLab = timeLab

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(self.m_activity.activityId == ACTIVITY_ID_BEE and DetailText.activityBee or DetailText.activityBeeNew):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 50)

	local view = ActivityBeeTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 80),self.m_activity.activityId):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end


function ActivityBeeView:showBeeRank(container)
	-- 活动时间
	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = container:getContentSize().height - 30}):addTo(container)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, container:getContentSize().height - 60)
	self.m_timeLab = timeLab

	local view = ActivityBeeRankTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 80),self.m_activity.activityId):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()

	--查看奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardInfoBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardInfoHandler)):addTo(container)
	awardInfoBtn:setPosition(container:getContentSize().width / 2, 30)
	awardInfoBtn:setLabel(CommonText[769][1])
end

function ActivityBeeView:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function ActivityBeeView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end


function ActivityBeeView:onExit()
	ActivityBeeView.super.onExit(self)

end





return ActivityBeeView
