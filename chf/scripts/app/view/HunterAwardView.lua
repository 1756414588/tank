--
-- Author: Gss
-- Date: 2018-04-12 17:58:16
--
local HunterAwardPageView = class("HunterAwardPageView", function(size)
    if not size then size = cc.size(0, 0) end
    local rect = cc.rect(0, 0, size.width, size.height)

    local node = display.newClippingRegionNode(rect)
    node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
    return node
end)

function HunterAwardPageView:ctor(size, wantedList)
	self.m_viewSize = size
	self.m_viewNode = {}
	self.m_curPageIndex = 0
	self.m_wantedList = wantedList
	-- self.selected_ = {}
end

function HunterAwardPageView:onEnter()
	local container = display.newNode():addTo(self)
	container:setContentSize(self.m_viewSize)
	nodeTouchEventProtocol(container, function(event)
        	return self:onTouch(event)
        end)
	self.m_container = container
end

function HunterAwardPageView:numberOfCells()
	return #self.m_wantedList
end

function HunterAwardPageView:cellSizeForIndex(index)
	return self:getViewSize()
end

function HunterAwardPageView:setCurrentIndex(pageIndex, animated)
	if self.m_moveAnimation then return end
	if self.m_curPageIndex == pageIndex then return end
	if pageIndex > self:numberOfCells() then pageIndex = pageIndex % self:numberOfCells() end
	if pageIndex == 0 then pageIndex = self:numberOfCells() end

	if not self.m_viewNode[pageIndex] then
		local node = display.newNode():addTo(self.m_container)
		local cell = self:createCellAtIndex(node, pageIndex)
		self.m_viewNode[pageIndex] = cell
	end

	local function setPage()
		for index = 1, self:numberOfCells() do
			if index ~= pageIndex then
				if self.m_viewNode[index] then  -- 删除掉没有使用的page
					self.m_viewNode[index]:removeSelf()
					self.m_viewNode[index] = nil
				end
			end
	    end

		self.m_curPageIndex = pageIndex
	end

	if animated then
		self.m_moveAnimation = true
		local moveX = 0
		if (pageIndex < self.m_curPageIndex and not (self.m_curPageIndex == self:numberOfCells() and pageIndex == 1)) or (self.m_curPageIndex == 1 and pageIndex == self:numberOfCells()) then
			self.m_viewNode[pageIndex]:setPosition(-self:getViewSize().width, 0)
			moveX = self:getViewSize().width
		else
			self.m_viewNode[pageIndex]:setPosition(self:getViewSize().width, 0)
			moveX = -self:getViewSize().width
		end

		self.m_container:runAction(transition.sequence({cc.MoveTo:create(0.6, cc.p(moveX, 0)), cc.CallFunc:create(function()
				self.m_container:setPosition(0, 0)
				self.m_viewNode[pageIndex]:setPosition(0, 0)

				self.m_moveAnimation = false
				setPage()
			end)}))
	else
		setPage()
	end
end

function HunterAwardPageView:getCurrentIndex()
	return self.m_curPageIndex
end

function HunterAwardPageView:getNodeAtIndex(index)
	return self.m_viewNode[index]
end

function HunterAwardPageView:createCellAtIndex(cell, index)
	self:updateCell(cell, index)
	return cell
end

function HunterAwardPageView:updateCell(cell, index)
	-- body
	local wantedData = self.m_wantedList[index]
	local wantedStatus = HunterBO.wantedRewardStatus[wantedData.id].status
	local schedule = HunterBO.wantedRewardStatus[wantedData.id].schedule

	cell:removeAllChildren()
	local componentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(cell)
	componentBg:setPreferredSize(cc.size(self:getViewSize().width - 20, self:getViewSize().height - 40))
	componentBg:setPosition(self:getViewSize().width / 2, self:getViewSize().height - 15 - componentBg:getContentSize().height / 2)

	local openStages = HunterMO.getBountyWantedOpenTimeStagesByTaskId(wantedData.id)
	local t = UiUtil.label("剩余倒计时:"):addTo(cell)
	t:setPosition(50, componentBg:height() - t:height() - 340)
	local left = UiUtil.label("00d:00h:00m:00s", nil, COLOR[2]):rightTo(t)

	local function tick()
		local now_t = ManagerTimer.getTime()
		local h = tonumber(os.date("%H", now_t))
		local m = tonumber(os.date("%M", now_t))
		local s = tonumber(os.date("%S", now_t))

		-- 判断一下当前时间在不在开放的时间内
		t:setString("倒计时:")
		local duringStage = HunterBO.duringStage
		local leftS = 60 - s
		local leftM = duringStage['end'][2] - 1 - m
		local flag = false
		if leftM < 0 then
			leftM = leftM + 60
			flag = true
		end
		local leftH = nil
		if flag then
			leftH = duringStage['end'][1] - 1 - h
		else
			leftH = duringStage['end'][1] - h
		end
		left:setString(string.format("%02dh:%02dm:%02ds",leftH,leftM,leftS))
		if leftH == 0 and leftM == 0 and leftS <= 1 then
			-- 认为活动应结束，弹出对话框，退出该界面
			local InfoDialog = require("app.dialog.InfoDialog")
			InfoDialog.new("活动已结束", function() UiDirector.popMakeUiTop("CombatSectionView") end):push()
		end
	end
	left:performWithDelay(tick, 1, 1)
	tick()

	local pic = display.newScale9Sprite(IMAGE_COMMON .. "wanted_bg.jpg"):addTo(componentBg)
	pic:setPosition(componentBg:width() / 2, componentBg:height() - pic:height() / 2)

	local head = display.newScale9Sprite(string.format("%s%s.png", IMAGE_COMMON, wantedData.head)):addTo(componentBg)
	head:setPosition(componentBg:width() / 2, componentBg:height() - head:height() + 90)

	local deco = display.newScale9Sprite(string.format("%s%s.png", IMAGE_COMMON, wantedData.deco)):addTo(componentBg)
	deco:setPosition(componentBg:width() / 2, componentBg:height() - deco:height() - 265)
	-- 背景
	local bottomBG = display.newScale9Sprite(IMAGE_COMMON .. "bounty_bottom_bg.png"):addTo(componentBg)
	bottomBG:setPreferredSize(cc.size(self:getViewSize().width - 20, componentBg:height() - pic:height() - 70))
	bottomBG:setPosition(componentBg:width() / 2, bottomBG:getContentSize().height/2 + 70)

	local bottomDeco = display.newScale9Sprite(IMAGE_COMMON .. "bounty_deco.png"):addTo(bottomBG)
	bottomDeco:setPosition(bottomBG:getContentSize().width/2, bottomBG:getContentSize().height - bottomDeco:getContentSize().height/2+5)
	--目标
	local achieve = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(componentBg)
	achieve:setPosition(10,pic:y() - pic:height() / 2 - achieve:height() / 2 - 20)
	achieve:setAnchorPoint(cc.p(0,0.5))

	local targetStr = nil
	if wantedData.target == 1 then
		targetStr = "个人目标"
	else
		targetStr = "全服目标"
	end
	local target = UiUtil.label(targetStr):addTo(achieve)
	target:setPosition(80,achieve:height() / 2)

	local desc = UiUtil.label(wantedData.desc,nil,nil,nil,ui.TEXT_ALIGN_LEFT):addTo(componentBg)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(50, achieve:y() - 40)

	local progressStr = nil
	if wantedData.cond <= 100000 then
		progressStr = string.format("(%d/%.0f)", schedule, wantedData.cond)
	else
		local scheduleStr = nil
		if schedule <= 100000 then
			scheduleStr = string.format("%s", schedule)
		else
			scheduleStr = UiUtil.strNumSimplify(schedule)
		end
		progressStr = string.format("(%s/%s)", scheduleStr, UiUtil.strNumSimplify(wantedData.cond))
	end

	local progress = UiUtil.label(progressStr):addTo(componentBg)
	progress:setPosition(50 + desc:getContentSize().width + progress:getContentSize().width / 2, achieve:y() - 40)

	--奖励
	local awardBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(componentBg)
	awardBg:setPosition(10,desc:y() - awardBg:height() / 2 - desc:height() / 2 - 10)
	awardBg:setAnchorPoint(cc.p(0,0.5))

	local award = UiUtil.label("奖励"):addTo(awardBg)
	award:setPosition(60,awardBg:height() / 2)

	local coinCount = wantedData.awardList
	-- if #awardJson > 0 then
	-- 	for idx = 1, #awardJson do

	local propCount = coinCount

	local itemView = UiUtil.createItemView(ITEM_KIND_HUNTER_COIN, 0, {count = propCount}):addTo(componentBg)
	itemView:setPosition(20 + itemView:getContentSize().width / 2,awardBg:y() - itemView:height() / 2 - 20)
	itemView:setScale(0.7)
	UiUtil.createItemDetailButton(itemView)
	-- local propDB = UserMO.getResourceData(award.type, award.id)
	local propDB = UserMO.getResourceData(ITEM_KIND_HUNTER_COIN, 0)
	local name = ui.newTTFLabel({text = propDB.name2, font = G_FONT, size = 18, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(componentBg)
	name:setPosition(itemView:x(), itemView:y() - itemView:height() / 2)
	-- 	end
	-- end

	--领取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local awardButton = MenuButton.new(normal, selected, disabled, handler(self, self.onAwardsCallback)):addTo(componentBg)
	awardButton:setPosition(componentBg:width() / 2, awardButton:height() / 2 - 10)
	awardButton:setLabel(CommonText[538][2])
	awardButton.taskId = wantedData.id
	awardButton.cell = cell
	awardButton.index = index

	-- self.m_awardButton = awardButton

	if wantedStatus == 1 then
		awardButton:setEnabled(false)
		awardButton:setLabel("已领取")
	else
		awardButton:setEnabled(schedule >= wantedData.cond)
		awardButton:setLabel("领取")
		-- UiUtil.showTip(self.m_awardButton, nil, 142, 60)
	end

	return cell
end

function HunterAwardPageView:getViewSize()
	return self.m_viewSize
end

function HunterAwardPageView:onTouch(event)
    if event.name == "began" then
        return self:onTouchBegan(event)
    elseif event.name == "moved" then
    elseif event.name == "ended" then
        self:onTouchEnded(event)
    else
        self:onTouchCancelled(event)
    end
end

function HunterAwardPageView:onTouchBegan(event)
    if not self:isVisible() then return false end

    self.m_touchPoint = cc.p(event.x, event.y)
    return true
end

function HunterAwardPageView:onTouchEnded(event)
    if not self:isVisible() then return end

	if not self.m_touchPoint then return end

	local deltaX = event.x - self.m_touchPoint.x

	if math.abs(deltaX) <= 18 then return end

	if deltaX < 0 then
		self:setCurrentIndex(self:getCurrentIndex() + 1, true)
	else
		self:setCurrentIndex(self:getCurrentIndex() - 1, true)
	end

end

function HunterAwardPageView:onTouchCancelled(event)
	self.m_touchPoint = nil
end

function HunterAwardPageView:onAwardsCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local taskId = sender.taskId
	local cell = sender.cell
	local index = sender.index
	HunterBO.getTaskReward(taskId, function (awards)
		-- body
		local awardsShow = {awards={}}
		for i, v in ipairs(awards) do
			local award = {kind=v.type,id=v.id,count=v.count}
			table.insert(awardsShow.awards, award)
		end
		UiUtil.showAwards(awardsShow)

		HunterBO.wantedRewardStatus[taskId].status = 1
		self:updateCell(cell, index)
	end)
end








-----------------------------------------------------------------------------------------
--赏金猎人功能奖励预览和领取View
-----------------------------------------------------------------------------------------

local HunterAwardView = class("HunterAwardView", UiNode)

function HunterAwardView:ctor(enterStyle)
	enterStyle = enterStyle or UI_ENTER_NONE
	HunterAwardView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
	-- self.m_taskStatus = taskStatus
end

function HunterAwardView:onEnter()
	HunterAwardView.super.onEnter(self)
	self:setTitle("通缉令") 
	self:showUI()
end

function HunterAwardView:onExit()
	HunterAwardView.super.onExit(self)
end

function HunterAwardView:showUI()
	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLastCallback)):addTo(self:getBg(),10)
	lastBtn:setPosition(50, self:getBg():getContentSize().height - 298)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_page_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onNextCallback)):addTo(self:getBg(),10)
	nxtBtn:setPosition(self:getBg():getContentSize().width - 50, self:getBg():getContentSize().height - 298)

	local wantedList = HunterMO.getBountyWantedArrayOpen(HunterBO.duringStage)
	local view = HunterAwardPageView.new(cc.size(self:getBg():getContentSize().width - 10, self:getBg():height() - 80), wantedList):addTo(self:getBg())
	view:setPosition(0,0)
	view:setCurrentIndex(2)
	self.m_pageView = view
end

function HunterAwardView:onLastCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage - 1, true)
end

function HunterAwardView:onNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage + 1, true)
end


return HunterAwardView
