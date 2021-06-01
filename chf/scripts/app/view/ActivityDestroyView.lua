--
-- Author: gf
-- Date: 2015-12-21 17:27:02
-- 疯狂歼灭


--------------------------------------------------------------------
-- 歼灭 tableview
--------------------------------------------------------------------

local ActivityDestroyTableView = class("ActivityDestroyTableView", TableView)

function ActivityDestroyTableView:ctor(size,activityId)
	ActivityDestroyTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 140)
	self.activityId_ = activityId
end

function ActivityDestroyTableView:onEnter()
	ActivityDestroyTableView.super.onEnter(self)
	self.m_list = ActivityCenterMO.getActivityContentById(self.activityId_).data.destoryTanks
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.onActivityUpdate))
end

function ActivityDestroyTableView:numberOfCells()
	return #self.m_list
end

function ActivityDestroyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityDestroyTableView:createCellAtIndex(cell, index)
	ActivityDestroyTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 40, self.m_cellSize.height))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	
	gdump(data.activityCond,"data.activityCond==")
	local tankIdx
	if data.activityCond.param == "0" then
		tankIdx = 5
	else
		tankIdx = tonumber(data.activityCond.param)
	end

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",70, 65):addTo(bg)

	local icon = display.newSprite(ACTIVITY_DESTORY_TANK_RES[tankIdx])
	icon:setScale(0.9)
	icon:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
	fame:addChild(icon)

	local name = ui.newTTFLabel({text = CommonText[832][tankIdx], font = G_FONT, 
		size = FONT_SIZE_SMALL, x = 160, y = bg:getContentSize().height - 25}):addTo(bg)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
	bar:setPosition(150 + bar:getContentSize().width / 2, self.m_cellSize.height - 85)
	bar:setLabel(data.state .. "/" .. data.activityCond.cond)
	bar:setPercent(data.state / data.activityCond.cond)
	
	if data.state < data.activityCond.cond then
		--歼灭按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_lock_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_lock_selected.png")
		local attackBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.attackHandler))
		cell:addButton(attackBtn, self.m_cellSize.width - 90, 50) 
	elseif data.activityCond.status == 0 then
		-- --领取奖励按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local awardBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.awardHandler))
		awardBtn:setLabel(CommonText[255])
		awardBtn.data = data.activityCond
		cell:addButton(awardBtn, self.m_cellSize.width - 100, 50) 
	end
	
	--奖励说明
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onRewardDetail))
	detailBtn.data = data.activityCond
	cell:addButton(detailBtn, self.m_cellSize.width - 210, 50)

	return cell
end

function ActivityDestroyTableView:onRewardDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityDestoryRewardDialog").new(sender.data):push()
end

function ActivityDestroyTableView:attackHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.clear()
	Notify.notify(LOCAL_LOCATION_EVENT)
end

function ActivityDestroyTableView:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynReceiveAward(function()
			Loading.getInstance():unshow()
		end, self.activityId_, sender.data)
end

function ActivityDestroyTableView:onActivityUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityDestroyTableView:onExit()
	ActivityDestroyTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

--------------------------------------------------------------------
-- 排行 tableview
--------------------------------------------------------------------

local ActivityDestroyRankTableView = class("ActivityDestroyRankTableView", TableView)

function ActivityDestroyRankTableView:ctor(size,activityId)
	ActivityDestroyRankTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 100)
	self.activityId_ = activityId
end

function ActivityDestroyRankTableView:onEnter()
	ActivityDestroyRankTableView.super.onEnter(self)

	self.m_list = ActivityCenterMO.getActivityContentById(self.activityId_).actFortuneRank.actPlayerRank
	-- gdump(self.actBeeRank_,"self.actBeeRank_==")
end

function ActivityDestroyRankTableView:numberOfCells()
	return #self.m_list
end

function ActivityDestroyRankTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityDestroyRankTableView:createCellAtIndex(cell, index)
	ActivityDestroyRankTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(550, 2))

	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2 - 35)
	
	local rankTitle = ArenaBO.createRank(index)
	rankTitle:setPosition(45, 40)
	bg:addChild(rankTitle)

	local name = ui.newTTFLabel({text = data.nick, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 192, y = 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	if index == 1 then
		name:setColor(COLOR[6])
	elseif index == 2 then
		name:setColor(COLOR[12])
	elseif index == 3 then
		name:setColor(COLOR[4])
	else
		name:setColor(COLOR[11])
	end

	local scoreValue = ui.newTTFLabel({text = data.rankValue, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 470, y = 40, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	return cell
end

function ActivityDestroyRankTableView:onRewardDetail(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityBeeRankDialog").new(sender.data):push()
end

function ActivityDestroyRankTableView:onExit()
	ActivityDestroyRankTableView.super.onExit(self)
end


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")


local ActivityDestroyView = class("ActivityDestroyView", UiNode)

function ActivityDestroyView:ctor(activity)
	ActivityDestroyView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityDestroyView:onEnter()
	ActivityDestroyView.super.onEnter(self)

	self:setTitle(CommonText[823])

	local function createDelegate(container, index)
		self.m_timeLab = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showDestroy(container)
				elseif index == 2 then 
					self:showDestroyRank(container)
				end
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[828][1],CommonText[828][2]}


	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x =GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)


	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end


function ActivityDestroyView:showDestroy(container)
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
			DetailTextDialog.new(DetailText.activityDestroy):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 50)

	local view = ActivityDestroyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 80),self.m_activity.activityId):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end


function ActivityDestroyView:showDestroyRank(container)
	local rankData_ = ActivityCenterMO.activityContents_[self.m_activity.activityId].actFortuneRank

	--我的积分
	local scoreLab = ui.newTTFLabel({text = CommonText[764][1], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 30}):addTo(container)
	scoreLab:setAnchorPoint(cc.p(0, 0.5))

	local scoreValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[2],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = scoreLab:getPositionX() + scoreLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(container)
	scoreValue:setAnchorPoint(cc.p(0, 0.5))
	scoreValue:setString(rankData_.score)
	self.scoreValue_ = scoreValue

	--当前排名
	local rankLab = ui.newTTFLabel({text = CommonText[764][2], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 350, y = container:getContentSize().height - 30}):addTo(container)
	rankLab:setAnchorPoint(cc.p(0, 0.5))

	local rankValue = ui.newTTFLabel({text = " ", font = G_FONT, color = COLOR[6],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = rankLab:getPositionX() + rankLab:getContentSize().width, y = scoreLab:getPositionY()}):addTo(container)
	rankValue:setAnchorPoint(cc.p(0, 0.5))
	local myRank = ActivityCenterBO.getMyFortuneRank(self.m_activity.activityId)
	rankValue:setString(myRank)
	if myRank == CommonText[768] then
		rankValue:setColor(COLOR[6])
	else
		rankValue:setColor(COLOR[2])
	end

	--活动结束时结算排名
	local infoLab = ui.newTTFLabel({text = CommonText[764][3], font = G_FONT, color = COLOR[11],
		align = ui.TEXT_ALIGN_CENTER,size = FONT_SIZE_SMALL, x = 40, y = container:getContentSize().height - 60}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0, 0.5))

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBg:setPreferredSize(cc.size(container:getContentSize().width, container:getContentSize().height - 160))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - (container:getContentSize().height - 160) / 2 - 80)

	local posX = {65,200,490}
	for index=1,#CommonText[770] do
		local title = ui.newTTFLabel({text = CommonText[770][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		title:setAnchorPoint(cc.p(0, 0.5))
	end


	local view = ActivityDestroyRankTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70),self.m_activity.activityId):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()

	--按钮
	--查看奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardInfoBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardInfoHandler)):addTo(container)
	awardInfoBtn:setPosition(container:getContentSize().width / 2 - 150, 30)
	awardInfoBtn:setLabel(CommonText[769][1])

	--领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local awardGetBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardGetHandler)):addTo(container)
	awardGetBtn:setPosition(container:getContentSize().width / 2 + 150, 30)
	self.awardGetBtn = awardGetBtn

	--我的排名数据
	local myRankData = ActivityCenterBO.getMyFortuneRankData(self.m_activity.activityId)
	
	if rankData_.open == true and myRankData then
		if rankData_.status == 0 then
			awardGetBtn:setLabel(CommonText[777][1])
			awardGetBtn:setEnabled(true)
			awardGetBtn.rankType = myRankData.rankType
			awardGetBtn.actFortuneRank = rankData_
		else
			awardGetBtn:setLabel(CommonText[777][3])
			awardGetBtn:setEnabled(false)
		end
	else
		awardGetBtn:setLabel(CommonText[777][2])
		awardGetBtn:setEnabled(false)
	end
end

function ActivityDestroyView:awardInfoHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityFortuneAwardDialog").new(self.m_activity.activityId):push()
end

function ActivityDestroyView:awardGetHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynGetRankAward(function()
			Loading.getInstance():unshow()
			self.awardGetBtn:setLabel(CommonText[777][3])
			self.awardGetBtn:setEnabled(false)
		end,self.m_activity.activityId,sender.rankType,sender.actFortuneRank)
end

function ActivityDestroyView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end


function ActivityDestroyView:onExit()
	ActivityDestroyView.super.onExit(self)

end





return ActivityDestroyView
