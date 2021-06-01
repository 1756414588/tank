--
-- Author: Your Name
-- Date: 2017-09-25 15:58:09
--

local AwardTableView = class("AwardTableView", TableView)

function AwardTableView:ctor(size, param, condTable, activityId)
	AwardTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)

	self.m_param = param
	self.m_condTable = condTable
	self.m_activityId = activityId
	self.m_cellSize = cc.size(192, size.height)
end

function AwardTableView:resetConfigData(param, condTable)
	self.m_param = param
	self.m_condTable = condTable
end

function AwardTableView:onEnter()
	AwardTableView.super.onEnter(self)
end

function AwardTableView:numberOfCells()
	return #self.m_param
end

function AwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function AwardTableView:createCellAtIndex(cell,index)
	AwardTableView.super.createCellAtIndex(self, cell, index)
	local activityContent = ActivityCenterMO.activityContents_[self.m_activityId]
	local daysOfContinuousPay = activityContent.daysOfContinuousPay

	local awData = self.m_param[index]
	local keyId = awData.keyId

	local cellWidth = self.m_cellSize.width
	local cellHeight = self.m_cellSize.height
	local midx = cellWidth / 2
	local itemWidth = 70

	-- 增加一个背景
	local bgFile = "secret_army_gift_bg.png"
	local bg = display.newSprite(IMAGE_COMMON .. bgFile):addTo(cell)
	bg:setPosition(cellWidth / 2, cellHeight / 2)

	-- 头部说明
	local day = awData.cond
	local payText = string.format(CommonText[2504], day)
	local textHeader = ui.newTTFLabel({text = payText, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, }):addTo(cell)
	textHeader:setPosition(cellWidth / 2 + 10, cellHeight - 20 - textHeader:height() / 2)

	local awardCount = #awData.award
	if awardCount % 2 == 0 then
		startX = midx - (awardCount / 2 - 0.5) * itemWidth
	else
		startX = midx - math.floor(awardCount / 2) * itemWidth
	end

	startX = startX + 10

	local itemY = 130

	for i = 1, awardCount do
		local aw = awData.award[i]
		local itemView = UiUtil.createItemView(aw.type, aw.id, {count=aw.count}):addTo(cell)
		itemView:setScale(0.7)
		itemView:setPosition(startX + (i - 1) * itemWidth, itemY)
		-- UiUtil.createItemDetailButton(itemView, nil, false)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")

	local function onBtnAcceptCallback(tag, sender)
		ActivityCenterBO.asynReceiveAward(
			function(statsAward, activityCond)
				sender:setLabel(CommonText[2506])
				sender:setEnabled(activityCond.status == 0)
			end, 
			sender.activityId, sender.awardData)
	end

	local btn = MenuButton.new(normal, selected, disabled, onBtnAcceptCallback):addTo(cell)
	if awData.status == 1 then
		btn:setLabel(CommonText[2506])
	else
		btn:setLabel(CommonText[2502])
	end
	btn:setPosition(midx + 10, itemY - itemWidth - 10)
	btn:setEnabled(awData.status == 0)

	btn.activityId = self.m_activityId
	btn.awardData = self.m_condTable[keyId]

	return cell
end

function AwardTableView:onExit()
	AwardTableView.super.onExit(self)
end

----------------------------------------------------------------------------------------------------------
HYPERSPACE_FRESH_NORMAL = 1
HYPERSPACE_FRESH_EXC    = 2
HYPERSPACE_FRESH_AWARD  = 3

local ActivitySecretArmyView = class("ActivitySecretArmyView", UiNode)

function ActivitySecretArmyView:ctor(activity)
	ActivitySecretArmyView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
	self.m_pageIndex = 1
	self.m_btnAccpetTodayGift = nil
	self.m_rechargeHandler = nil
	self.m_awardTableView = nil
	self.m_textHeader = nil
end

function ActivitySecretArmyView:onEnter()
	ActivitySecretArmyView.super.onEnter(self)
	-- self:hasCoinButton(true)
	if self.m_activity.awardId == 15504 then
		self:setTitle(CommonText[1165][1])
	else
		self:setTitle(self.m_activity.name)
	end

	self.m_rechargeHandler = Notify.register(LOCAL_RECHARGE_UPDATE, handler(self, self.onRechargeUpdate))

	self:showUI()
end

function ActivitySecretArmyView:showUI()
	local activityContent = ActivityCenterMO.activityContents_[self.m_activity.activityId]

	-- 生成状态表
	local statusTbl = {}
	local activityCondTbl = {}
	local todayGiftData = nil
	local todayActivityCond = nil
	for i = 1, #activityContent.awardStatus do
		local aw = activityContent.awardStatus[i]
		local t = {}
		t.status = aw.status
		t.keyId = aw.keyId
		t.cond = aw.cond
		t.award = PbProtocol.decodeArray(aw.award)
		if t.cond ~= 1 then
			table.insert(statusTbl, t)
			activityCondTbl[aw.keyId] = aw
		else
			todayGiftData = t
			todayActivityCond = aw
		end
	end

	local bgFile = "secret_army_bg.jpg"
	local bg = display.newSprite(IMAGE_COMMON .. bgFile):addTo(self:getBg())
	local bgWidth = self:getBg():getContentSize().width
	bg:setPosition(bgWidth / 2, self:getBg():height() - bg:height() / 2 - 100)

	local textDetail = ui.newTTFLabel({text = CommonText[2507], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT, }):addTo(bg)
	textDetail:setPosition(0, textDetail:height() * 3 - 5)
	textDetail:setAnchorPoint(0, 0)

	local textDetail1 = ui.newTTFLabel({text = CommonText[2508], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], align = ui.TEXT_ALIGN_LEFT, }):addTo(bg)
	textDetail1:setPosition(0, textDetail:height() * 2 - 5)
	textDetail1:setAnchorPoint(0, 0)

	local timeCDLabel = UiUtil.label("剩余倒计时:"):addTo(bg)
	timeCDLabel:setPosition(0, timeCDLabel:height() - 5)
	timeCDLabel:setAnchorPoint(0, 0)
	local timeLabel = UiUtil.label("00d:00h:00m:00s", nil, COLOR[2]):rightTo(timeCDLabel)
	timeLabel:setAnchorPoint(0, 0)

	local function tick()
		local endTime = activityContent.activity.endTime
		local now_t = ManagerTimer.getTime()
		local remain_t = endTime - now_t
		if remain_t > 0 then
			-- 判断一下当前时间在不在开放的时间内
			local d = math.floor(remain_t / 86400)
			local h = math.floor((remain_t - d * 86400) / 3600)
			local m = math.floor((remain_t - d * 86400 - h * 3600) / 60)
			local s = remain_t - d * 86400 - h * 3600 - m * 60

			timeLabel:setString(string.format("%02dd:%02dh:%02dm:%02ds",d,h,m,s))
		else
			timeLabel:setString("00d:00h:00m:00s")
		end
	end
	timeLabel:performWithDelay(tick, 1, 1)
	tick()

	local bgFileDaily = "secret_army_daily_bg.png"
	local bgDaily = display.newSprite(IMAGE_COMMON .. bgFileDaily):addTo(self:getBg())
	bgDaily:setPosition(bgWidth / 2, self:getBg():height() - bg:height() - bgDaily:height()/2 - 100)

	local bgDailyWidth = bg:getContentSize().width
	local decoLine = display.newSprite("image/common/line3.png"):addTo(bgDaily)
	decoLine:setPosition(bgDailyWidth / 2, bgDaily:height() + 10)

	local bgTextFile = "secret_army_daily_gift.png"
	local bgText = display.newSprite(IMAGE_COMMON .. bgTextFile):addTo(bgDaily)
	bgText:setPosition(bgDailyWidth / 2, bgDaily:height() + 10 - bgText:height())

	-- 今日礼包奖励
	local textDailyGift = ui.newTTFLabel({text = CommonText[2501], font = G_FONT, size = FONT_SIZE_TINY, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, }):addTo(bgDaily)
	textDailyGift:setPosition(bgDailyWidth / 2, bgDaily:height() - bgText:height() - textDailyGift:height() - 10)


	-- 拿到今日充值礼包的keyId
	-- 今日礼包奖励
	local midx = bgDailyWidth / 2
	local awardCount = #todayGiftData.award
	local itemWidth = 80
	local startX = 0
	if awardCount % 2 == 0 then
		startX = midx - (awardCount / 2 - 0.5) * itemWidth
	else
		startX = midx - math.floor(awardCount / 2) * itemWidth
	end
	local itemY = textDailyGift:getPositionY() - itemWidth / 2 - 30
	for i = 1, awardCount do
		local awData = todayGiftData.award[i]
		local itemView = UiUtil.createItemView(awData.type, awData.id, {count=awData.count}):addTo(bgDaily)
		itemView:setPosition(startX + (i - 1) * itemWidth, itemY)
		itemView:setScale(0.8)
		UiUtil.createItemDetailButton(itemView, nil, false)
	end

	-- 领取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onBtnAcceptCallback)):addTo(bgDaily)
	if todayGiftData.status == 1 then
		btn:setLabel(CommonText[2506])
	else
		btn:setLabel(CommonText[2502])
	end
	btn:setPosition(midx, itemY - itemWidth)
	-- 查询领取状态
	-- 当天是否已经充值
	btn:setEnabled(todayGiftData.status == 0)
	btn.awardData = todayActivityCond
	btn.activityId = self.m_activity.activityId

	self.m_btnAccpetTodayGift = btn

	-- 前往充值
	-- 前往充值底部背景
	local bottomBg = display.newScale9Sprite(IMAGE_COMMON .. "bar_bg_6.png"):addTo(self:getBg())
	bottomBg:setPreferredSize(cc.size(bgWidth - 20, 280))
	bottomBg:setAnchorPoint(cc.p(0.5,0))
	bottomBg:setPosition(bgWidth * 0.5, self:getBg():height() - bg:height() - bgDaily:height() - 100 - 280)

	-- 头部文字底和文字
	local headerTextBg = display.newScale9Sprite(IMAGE_COMMON .. "secret_army_gift_head_bg.png"):addTo(self:getBg())
	headerTextBg:setPosition(bgWidth * 0.5, self:getBg():height() - bg:height() - bgDaily:height() - headerTextBg:height()/2 - 100)

	local day = activityContent.daysOfContinuousPay
	local payText = string.format(CommonText[2505], day)
	local textHeader = ui.newTTFLabel({text = payText, font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, }):addTo(self:getBg())
	textHeader:setPosition(bgWidth * 0.5, self:getBg():height() - bg:height() - bgDaily:height() - headerTextBg:height()/2 - 100)

	self.m_textHeader = textHeader

	local view = AwardTableView.new(cc.size(bgWidth - 30, 240), statusTbl, activityCondTbl, self.m_activity.activityId):addTo(self:getBg())
	view:setPosition(10, self:getBg():height() - bg:height() - bgDaily:height() - headerTextBg:height() - 340)
	view:reloadData()

	-- 查找第一个没有领但是可以领的奖励
	local index = -1
	for i = 1, #statusTbl do
		local awData = statusTbl[i]
		if awData.status == 0 then
			index = i
			break
		end
	end
	local itemW = 192
	local maxItemInScreen = math.floor((bgWidth - 30) / itemW)
	local maxIndex = #statusTbl - maxItemInScreen + 1
	if index > 0 then
		if index > maxIndex then
			index = maxIndex
		end
		local xOffset = (index - 1) * itemW
		view:setContentOffset(cc.p(-xOffset, 0))
	end

	self.m_awardTableView = view

	-- 前往充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn1 = MenuButton.new(normal, selected, disabled, handler(self, self.onBtnPayCallback)):addTo(self:getBg())
	btn1:setLabel(CommonText[2503])
	btn1:setPosition(midx, btn1:height() / 2 + 20)
end


function ActivitySecretArmyView:onRechargeUpdate(event)
	-- body
	Loading.getInstance():show()
	local function updateView()
		Loading.getInstance():unshow()
		if self.m_btnAccpetTodayGift then
			local btn = self.m_btnAccpetTodayGift
			local activityContent = ActivityCenterMO.activityContents_[self.m_activity.activityId]

			local statusTbl = {}
			local activityCondTbl = {}
			local todayGiftData = nil
			local todayActivityCond = nil
			for i = 1, #activityContent.awardStatus do
				local aw = activityContent.awardStatus[i]
				local t = {}
				t.status = aw.status
				t.keyId = aw.keyId
				t.cond = aw.cond
				t.award = PbProtocol.decodeArray(aw.award)
				if t.cond ~= 1 then
					table.insert(statusTbl, t)
					activityCondTbl[aw.keyId] = aw
				else
					todayGiftData = t
					todayActivityCond = aw
				end
			end

			if todayGiftData.status == 1 then
				btn:setLabel(CommonText[2506])
			else
				btn:setLabel(CommonText[2502])
			end
			btn:setEnabled(todayGiftData.status == 0)

			if self.m_textHeader then
				local day = activityContent.daysOfContinuousPay
				local payText = string.format(CommonText[2505], day)
				self.m_textHeader:setString(payText)
			end

			if self.m_awardTableView then
				self.m_awardTableView:resetConfigData(statusTbl, activityCondTbl)
				self.m_awardTableView:reloadData()
			end
		end
	end

	ActivityCenterBO.asynGetActivityContent(updateView, self.m_activity.activityId, 1)
end

function ActivitySecretArmyView:onBtnAcceptCallback(tag, sender)
	-- body
	ActivityCenterBO.asynReceiveAward(
		function(statsAward, activityCond)
			self:refreshBtnAccept(activityCond)
		end, 
		sender.activityId, sender.awardData)
end

function ActivitySecretArmyView:refreshBtnAccept(activityCond)
	if self.m_btnAccpetTodayGift then
		self.m_btnAccpetTodayGift:setEnabled(activityCond.status == 0)
		self.m_btnAccpetTodayGift:setLabel(CommonText[2506])
	end
end

function ActivitySecretArmyView:onBtnPayCallback(tag, sender)
	-- body
	RechargeBO.openRechargeView()
end

function ActivitySecretArmyView:onExit()
	if self.m_rechargeHandler then
		Notify.unregister(self.m_rechargeHandler)
		self.m_rechargeHandler = nil
	end
	ActivitySecretArmyView.super.onExit(self)
end

return ActivitySecretArmyView 
