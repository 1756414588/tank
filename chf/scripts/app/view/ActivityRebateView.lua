--
-- Author: gf
-- Date: 2015-11-26 10:05:52
-- 活动返利


local ActivityRebateView = class("ActivityRebateView", UiNode)

function ActivityRebateView:ctor(activity)
	ActivityRebateView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityRebateView:onEnter()
	ActivityRebateView.super.onEnter(self)

	self:setTitle(self.m_activity.name)

	armature_add("animation/effect/ui_activity_center_christ.pvr.ccz", "animation/effect/ui_activity_center_christ.plist", "animation/effect/ui_activity_center_christ.xml")

	local function createDelegate(container, index)
		self.m_timeLab = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showActivityCelebrate(container)
				elseif index == 2 then 
					self:showActivityRebate(container)
				end
				
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {}
	if self.m_activity.activityId == ACTIVITY_ID_AMY_REBATE then
		pages = {CommonText[754][2],CommonText[754][1]}
	elseif self.m_activity.activityId == ACTIVITY_ID_OPENSERVER then
		pages = {CommonText[754][3],CommonText[754][4]}
	end
	
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_rechargeHandler = Notify.register(LOCAL_RECHARGE_UPDATE_EVENT, handler(self, self.updateTip))
	self.m_rebateHandler = Notify.register(LOCAL_ACTIVITY_REBATE_EVENT, handler(self, self.updateTip))
	self:updateTip()


	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end


function ActivityRebateView:showActivityRebate(container)
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab


	-- 活动说明
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, timeLab:getPositionY() - timeLab:getContentSize().height - 40)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(510, 60)}):addTo(container)
	desc1:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 5)
	desc1:setAnchorPoint(cc.p(0, 1))
	if self.m_activity.activityId == ACTIVITY_ID_AMY_REBATE then
		desc1:setString(CommonText[755][1])
	elseif self.m_activity.activityId == ACTIVITY_ID_OPENSERVER then
		desc1:setString(CommonText[755][4])
	end

	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate.jpg'):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, desc1:getPositionY() - bg:getContentSize().height / 2 - 50)
	self.m_rebateBg = bg
	self:showRebateAward()

	--按钮
	--充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(container)
	rechargeBtn:setPosition(container:getContentSize().width / 2, 30)
	rechargeBtn:setLabel(CommonText[757][2])
	
end

function ActivityRebateView:showRebateAward()
	if self.node_rebateAward then self.m_rebateBg:removeChild(self.node_rebateAward, true) end
	local node = display.newNode():addTo(self.m_rebateBg)
	self.node_rebateAward = node
	local awardList

	--安卓和IOS读取不同档位的配置
	if device.platform == "android" then
		awardList = ActivityCenterMO.getRebateListById(self.m_activity.activityId)
	elseif device.platform == "ios" or device.platform == "mac" then
		if self.m_activity.activityId == ACTIVITY_ID_AMY_REBATE then
			awardList = ActivityCenterMO.getRebateListById(ACTIVITY_AMY_REBATE_AWARDID_IOS)
		else
			awardList = ActivityCenterMO.getRebateListById(ACTIVITY_AMY_REBATE_AWARDID_IOS_NEW)
		end
	else
		awardList = ActivityCenterMO.getRebateListById(self.m_activity.activityId)
	end

	local posList = {
		{x = 120, y = 350},
		{x = 310, y = 350},
		{x = 500, y = 350},
		{x = 120, y = 140},
		{x = 310, y = 140},
		{x = 500, y = 140}
	}
	--充值列表
	for index=1,#awardList do
		local award = awardList[index]
		local sprite = display.newSprite(IMAGE_COMMON .. award.asset .. ".png")
		-- local selected = display.newSprite(IMAGE_COMMON .. award.asset .. ".png")
		-- selected:setScale(0.95)
		-- local disabled = display.newSprite(IMAGE_COMMON .. award.asset .. ".png")
		-- local awardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.getRebateHandler)):addTo(node)
		local awardBtn = ScaleButton.new(sprite, handler(self, self.getRebateHandler)):addTo(node)


		awardBtn:setPosition(posList[index].x,posList[index].y)
		awardBtn.rebateId = award.rebateId

		--由于安卓和IOS共用一个30元档位，所以这里特殊处理
		if (device.platform == "windows" or device.platform == "android") and award.rebateId == 2 then
			awardBtn.rebateId = 8
		end
		if (device.platform == "windows" or device.platform == "android") and award.rebateId == 14 then
			awardBtn.rebateId = 20
		end

		local title = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL}):addTo(awardBtn)
		title:setString(string.format(CommonText[756],award.money,award.desc))
		title:setPosition(awardBtn:getContentSize().width / 2, 25)

		local tipPic = display.newSprite(IMAGE_COMMON .. "icon_red_point.png"):addTo(awardBtn)
		tipPic:setPosition(awardBtn:getContentSize().width - 40, awardBtn:getContentSize().height - 40)
		local count = ActivityCenterBO.getRebateCount(self.m_activity.activityId,award.rebateId)
		local tipValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL}):addTo(tipPic)

		local effect = CCArmature:create("ui_activity_center_christ")
        effect:getAnimation():playWithIndex(0)
        effect:connectMovementEventSignal(function(movementType, movementID) end)
        effect:setPosition(awardBtn:getContentSize().width / 2, 110)
        effect:setScale(1.5)
        awardBtn:addChild(effect)

		if count and count > 0 then
			tipValue:setString(count)
			tipValue:setPosition(tipPic:getContentSize().width / 2, tipPic:getContentSize().height / 2)
		end
		
		tipPic:setVisible(count and count > 0)
		awardBtn:setEnabled(count and count > 0)
		effect:setVisible(count and count > 0)
	end

	
end

function ActivityRebateView:showActivityCelebrate(container)
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab

	-- 活动说明
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, timeLab:getPositionY() - timeLab:getContentSize().height - 40)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(510, 60)}):addTo(container)
	desc1:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 5)
	desc1:setAnchorPoint(cc.p(0, 1))
	if self.m_activity.activityId == ACTIVITY_ID_AMY_REBATE then
		desc1:setString(CommonText[755][2])
	elseif self.m_activity.activityId == ACTIVITY_ID_OPENSERVER then
		desc1:setString(CommonText[755][3])
	end

	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate.jpg'):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, desc1:getPositionY() - bg:getContentSize().height / 2 - 50)
	self.m_celebrateBg = bg
	self:showCelebrateUI()

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)

	--当前欢庆
	local festValueLab = ui.newTTFLabel({text = CommonText[760] .. activityContent.state, font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(bg)
	festValueLab:setAnchorPoint(cc.p(0.5, 0.5))
	festValueLab:setPosition(bg:getContentSize().width / 2, -10)

	--按钮
	--采集按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local gatherBtn = MenuButton.new(normal, selected, nil, handler(self,self.gatherHandler)):addTo(container)
	gatherBtn:setPosition(container:getContentSize().width / 2 - 150, 30)
	gatherBtn:setLabel(CommonText[757][1])

	--充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(container)
	rechargeBtn:setPosition(container:getContentSize().width / 2 + 150, 30)
	rechargeBtn:setLabel(CommonText[757][2])
end


function ActivityRebateView:showCelebrateUI()
	if self.node_celebrate then self.m_celebrateBg:removeChild(self.node_celebrate, true) end
	local node = display.newNode():addTo(self.m_celebrateBg)
	self.node_celebrate = node

	local bg = self.m_celebrateBg
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)

	local activityConds = activityContent.activityCond
	local maxCond = ActivityCenterBO.getMaxActivityCond(activityConds)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(395, 40),
			{bgName = IMAGE_COMMON .. "bar_bg_3.png", bgScale9Size = cc.size(480, 64), bgY = 17}):addTo(node)
	bar:setPosition(50, bg:getContentSize().height / 2)
	bar:setPercent(activityContent.state / maxCond)
	bar:setRotation(-90)

	local offsetY = {0,20,20,-20}
	for index=1,#activityConds do
		local activityCond = activityConds[index]
		gdump(activityCond,"activityCond===")
		local line = display.newRect(CCRect(80,46 + 395 * activityCond.cond / maxCond, 50, 4))
		line:setLineColor(cc.c4f(43/255, 245/255, 61/255,1))
		line:setFill(true)
		node:addChild(line)
		
		local awards = PbProtocol.decodeArray(activityCond["award"])
		-- gdump(awards,"activityCond.awards")
		--奖励
		for j = 1,#awards do
			local award = awards[j]
			local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count}):addTo(node)
			itemView:setScale(0.7)
			itemView:setPosition(140 + (j - 1) * 90, line:getPositionY() + offsetY[index])
			UiUtil.createItemDetailButton(itemView)

			local itemNameBg = display.newSprite(IMAGE_COMMON .. 'info_bg_32.png'):addTo(node)
			itemNameBg:setPosition(itemView:getPositionX(), itemView:getPositionY() - 50)

			local itemName = ui.newTTFLabel({text = " ", font = G_FONT, 
				size = FONT_SIZE_TINY - 2}):addTo(itemNameBg)
			local propData = UserMO.getResourceData(award.type, award.id)
			itemName:setString(propData.name2 .. "*" .. award.count)
			itemName:setAnchorPoint(cc.p(0.5,0.5))
			itemName:setPosition(itemNameBg:getContentSize().width / 2, itemNameBg:getContentSize().height / 2)
			if propData.quality then
				itemName:setColor(COLOR[propData.quality])
			end
			
		end
		--状态
		if activityContent.state >= activityCond.cond then
			--可领取
			if activityCond.status == 0 then
				--未领
				local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
				local awardBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardHandler)):addTo(node)
				awardBtn:setPosition(180 + #awards * 90, line:getPositionY() + offsetY[index])
				awardBtn:setLabel(CommonText[672][1])
				awardBtn.activityCond = activityCond
			else
				--已领
				local cueLab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, 
			   	color = cc.c3b(43, 245, 61)}):addTo(node)
				cueLab:setAnchorPoint(cc.p(0, 0.5))
				cueLab:setPosition(120 + #awards * 90, line:getPositionY() + offsetY[index])
				cueLab:setString(CommonText[672][2])
			end
		else
			local cueLab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, 
		   	color = cc.c3b(43, 245, 61)}):addTo(node)
			cueLab:setAnchorPoint(cc.p(0, 0.5))
			cueLab:setPosition(120 + #awards * 90, line:getPositionY() + offsetY[index])
			cueLab:setString(string.format(CommonText[761],activityCond.cond))
		end
	end

end

function ActivityRebateView:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynDoActAmyfestivity(function()
		Loading.getInstance():unshow()
		self:showCelebrateUI()
		end,sender.activityCond,self.m_activity.activityId,sender.rebateId)

end

function ActivityRebateView:gatherHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	UiDirector.popMakeUiTop("HomeView")
	UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
end

function ActivityRebateView:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function ActivityRebateView:getRebateHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynDoActAmyRebate(function()
		Loading.getInstance():unshow()
		self:showRebateAward()
		end,self.m_activity.activityId,sender.rebateId)
end

function ActivityRebateView:updateTip()

	local countAll = ActivityCenterBO.getRebateCountAll()
	--标签tip
	if countAll > 0 then
		UiUtil.showTip(self.m_pageView.m_noButtons[2], countAll, 150, 35)
		UiUtil.showTip(self.m_pageView.m_yesButtons[2], countAll, 157, 48)
	else
		UiUtil.unshowTip(self.m_pageView.m_noButtons[2])
		UiUtil.unshowTip(self.m_pageView.m_yesButtons[2])
	end
end

function ActivityRebateView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityRebateView:onExit()
	ActivityRebateView.super.onExit(self)
	if self.m_rechargeHandler then
		Notify.unregister(self.m_rechargeHandler)
		self.m_rechargeHandler = nil
	end
	if self.m_rebateHandler then
		Notify.unregister(self.m_rebateHandler)
		self.m_rebateHandler = nil
	end
	armature_remove("animation/effect/ui_activity_center_christ.pvr.ccz", "animation/effect/ui_activity_center_christ.plist", "animation/effect/ui_activity_center_christ.xml")
end





return ActivityRebateView
