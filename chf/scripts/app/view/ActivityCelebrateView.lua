--
-- Author: gf
-- Date: 2016-04-06 17:24:13
-- 节日欢庆

local ActivityCelebrateView = class("ActivityCelebrateView", UiNode)

function ActivityCelebrateView:ctor(activity)
	ActivityCelebrateView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityCelebrateView:onEnter()
	ActivityCelebrateView.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	local function createDelegate(container, index)
		self.m_timeLab = nil
		self.prayButtons = nil
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				if index == 1 then  
					self:showActivityCelebrate(container)
				elseif index == 2 then 
					self:showActivityPray(container)
				end
				
		end, self.m_activity.activityId,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[909][1],CommonText[909][2]}


	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_rechargeHandler = Notify.register(LOCAL_RECHARGE_UPDATE_EVENT, function() pageView:setPageIndex(1) end)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end



function ActivityCelebrateView:showActivityCelebrate(container)
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "bar_gamble.jpg"):addTo(container)
	infoBg:setPosition(container:getContentSize().width / 2,container:getContentSize().height - infoBg:getContentSize().height / 2 - 4)
	-- 活动时间
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(20, 45)
	self.m_timeLab = timeLab

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityCelebrate):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 45)

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).celeData

	-- local activityContent = {
	-- 	portrait = {
	-- 		state = 0,
	-- 		activityCond = {
	-- 			keyId = 1,
	-- 			cond = 4,
	-- 			status = 0
	-- 		}
	-- 	},
	-- 	payFrist = {
	-- 		state = 0,
	-- 		activityCond = {
	-- 			keyId = 1,
	-- 			cond = 4,
	-- 			status = 0,
	-- 			award = {
	-- 				{type = 5,id = 1,count = 1},
	-- 				{type = 5,id = 1,count = 1},
	-- 				{type = 5,id = 1,count = 1},
	-- 				{type = 5,id = 1,count = 1}
	-- 			}

	-- 		}
	-- 	},
	-- 	payTopup = {
	-- 		state = 1000,
	-- 		activityCond = {
	-- 			keyId = 1,
	-- 			cond = 2000,
	-- 			status = 0,
	-- 			award = {
	-- 				{type = 5,id = 5,count = 1},
	-- 				{type = 5,id = 6,count = 1},
	-- 				{type = 5,id = 7,count = 1},
	-- 				{type = 5,id = 8,count = 1}
	-- 			}

	-- 		}
	-- 	}
	-- }
	

	--专属挂件
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 30, infoBg:getPositionY() - infoBg:getContentSize().height / 2 - titleBg:getContentSize().height / 2)

	local title = ui.newTTFLabel({text = CommonText[906][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))


	local awards = PbProtocol.decodeArray(activityContent.portrait.activityCond["award"])
	gdump(awards,"awards===")
	--头像
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0, {pendant = 2}):addTo(container)
	itemView.id = 2
	itemView:setScale(0.55)
	itemView:setPosition(100, titleBg:getPositionY() - 80)

	--活动描述
	local desc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(265, 70)}):addTo(container)
	desc:setPosition(itemView:getPositionX() + 60, itemView:getPositionY() + 35)
	desc:setAnchorPoint(cc.p(0, 1))
	desc:setString(CommonText[907][1])

	--已达成
	local condLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(container)
	condLab:setPosition(desc:getPositionX(), itemView:getPositionY() - 10)
	condLab:setAnchorPoint(cc.p(0, 1))
	condLab:setString(CommonText[907][2])

	local condValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(container)
	condValue:setPosition(condLab:getPositionX() + condLab:getContentSize().width, condLab:getPositionY())
	condValue:setAnchorPoint(cc.p(0, 1))
	self.portraitCondValue = condValue


	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardPortraitHandler)):addTo(container)
	awardBtn:setPosition(container:getContentSize().width - 80,itemView:getPositionY())
	self.awardPortraitBtn = awardBtn



	--每天充值
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 30, awardBtn:getPositionY() - 85)

	local title = ui.newTTFLabel({text = CommonText[906][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	gdump(activityContent.payFrist.activityCond,"activityContent.payFrist.activityCond")
	--奖励
	local awards = PbProtocol.decodeArray(activityContent.payFrist.activityCond["award"])
	-- local awards = activityContent.payFrist.activityCond.award
	for index=1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setScale(0.9)
		itemView:setPosition(80 + (index - 1) * 110,titleBg:getPositionY() - 70)
		container:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardDayHandler)):addTo(container)
	awardBtn:setPosition(container:getContentSize().width - 80,titleBg:getPositionY() - 120)
	self.awardDayBtn = awardBtn

	



	--累计充值
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 30, awardBtn:getPositionY() - 60)

	local title = ui.newTTFLabel({text = CommonText[906][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	--奖励
	local awards = PbProtocol.decodeArray(activityContent.payTopup.activityCond["award"])
	-- local awards = activityContent.payTopup.activityCond.award
	for index=1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setScale(0.9)
		itemView:setPosition(80 + (index - 1) * 110,titleBg:getPositionY() - 70)
		container:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name2 .. " * " .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.awardTopupHandler)):addTo(container)
	awardBtn:setPosition(container:getContentSize().width - 80,titleBg:getPositionY() - 150)
	self.awardTopupBtn = awardBtn


	--可领次数
	local getLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(container)
	getLab:setPosition(awardBtn:getPositionX() - 55, awardBtn:getPositionY() + 60)
	getLab:setAnchorPoint(cc.p(0, 1))
	getLab:setString(CommonText[908][2])

	local getValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP}):addTo(container)
	getValue:setPosition(getLab:getPositionX() + getLab:getContentSize().width, getLab:getPositionY())
	getValue:setAnchorPoint(cc.p(0, 1))
	self.getValue = getValue

	--说明
	local infoLab = ui.newTTFLabel({text = CommonText[908][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 25, y = awardBtn:getPositionY() - 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0, 0.5))
	
	--进度条
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(450, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(450 + 4, 26)}):addTo(container)
	bar:setPosition(30 + bar:getContentSize().width / 2, infoLab:getPositionY() - 30)
	self.m_topupBar = bar


	self:updateCelebrateView()
end

function ActivityCelebrateView:updateCelebrateView()
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).celeData

	self.portraitCondValue:setString(activityContent.portrait.state .. "/" .. activityContent.portrait.activityCond.cond)
	if activityContent.portrait and activityContent.portrait.state >= activityContent.portrait.activityCond.cond then
		if activityContent.portrait.activityCond.status == 0 then
			self.awardPortraitBtn:setEnabled(true)
			self.awardPortraitBtn:setLabel(CommonText[870][2])
			self.awardPortraitBtn.type = 1
			self.awardPortraitBtn.data = activityContent.portrait.activityCond
		else
			self.awardPortraitBtn:setEnabled(false)
			self.awardPortraitBtn:setLabel(CommonText[870][3])
		end
	else
		self.awardPortraitBtn:setEnabled(true)
		self.awardPortraitBtn:setLabel(CommonText[369])
		self.awardPortraitBtn.type = 2
	end



	if activityContent.payFrist and activityContent.payFrist.state >= activityContent.payFrist.activityCond.cond then
		if activityContent.payFrist.activityCond.status == 0 then
			self.awardDayBtn:setEnabled(true)
			self.awardDayBtn:setLabel(CommonText[870][2])
			self.awardDayBtn.type = 1
			self.awardDayBtn.data = activityContent.payFrist.activityCond
		else
			self.awardDayBtn:setEnabled(false)
			self.awardDayBtn:setLabel(CommonText[870][3])
		end
	else
		self.awardDayBtn:setEnabled(true)
		self.awardDayBtn:setLabel(CommonText[369])
		self.awardDayBtn.type = 2
	end


	self.getValue:setString(math.floor(activityContent.payTopup.state / activityContent.payTopup.activityCond.cond))
	if activityContent.payTopup and activityContent.payTopup.state >= activityContent.payTopup.activityCond.cond then
		if activityContent.payTopup.activityCond.status == 0 then
			self.awardTopupBtn:setEnabled(true)
			self.awardTopupBtn:setLabel(CommonText[870][2])
			self.awardTopupBtn.type = 1
			self.awardTopupBtn.data = activityContent.payTopup.activityCond
		else
			self.awardTopupBtn:setEnabled(false)
			self.awardTopupBtn:setLabel(CommonText[870][3])
		end
	else
		self.awardTopupBtn:setEnabled(true)
		self.awardTopupBtn:setLabel(CommonText[369])
		self.awardTopupBtn.type = 2
	end
	self.m_topupBar:setLabel(activityContent.payTopup.state .. "/" .. activityContent.payTopup.activityCond.cond)
	self.m_topupBar:setPercent(activityContent.payTopup.state / activityContent.payTopup.activityCond.cond)

end


function ActivityCelebrateView:showActivityPray(container)
	self.m_pray_container = container
	-- 活动说明
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(480, 60)}):addTo(container)
	desc1:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 5)
	desc1:setAnchorPoint(cc.p(0, 1))
	desc1:setString(CommonText[910])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityCelebrate1):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 60, container:getContentSize().height - 60)


	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 140)

	local title = ui.newTTFLabel({text = CommonText[911], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local props = {
		PROP_ID_PRAY_CARD_1,
		PROP_ID_PRAY_CARD_2,
		PROP_ID_PRAY_CARD_3,
		PROP_ID_PRAY_CARD_4
	}
	--祝福卡
	for index = 1, #props do
		local itemView = UiUtil.createItemView(ITEM_KIND_PROP, props[index])
		itemView:setPosition(100 + (index - 1) * 130,bg:getPositionY() - 80)
		container:addChild(itemView)
		UiUtil.createItemDetailButton(itemView)
		local propDB = UserMO.getResourceData(ITEM_KIND_PROP, props[index])
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end


	--背景图
	local btm = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate.jpg'):addTo(container)
	btm:setPosition(container:getContentSize().width / 2, bg:getPositionY() - btm:getContentSize().height / 2 - 170)


	self:updatePrayView()
	

end

function ActivityCelebrateView:updatePrayView()

	local prayNode = display.newNode():addTo(self.m_pray_container)
	

	local prayData = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).prayData
	local posInfo = {
		{x = 120,y = 330},
		{x = 320,y = 330},
		{x = 520,y = 330},
		{x = 120,y = 115},
		{x = 320,y = 115},
		{x = 520,y = 115},
	}

	local prayButtons = {}
	
	gdump(prayData,"prayData===")
	for index = 1,#prayData do
		prayButtons[index] = {}
		local pray = prayData[index]

		local normal = display.newSprite(IMAGE_COMMON .. "pray_icon_nomal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "pray_icon_ing.png")
		local awardPic = display.newSprite(IMAGE_COMMON .. "icon_rebate_1.png")

		local normalBtn = ScaleButton.new(normal, handler(self, self.prayHandler)):addTo(prayNode)
		normalBtn:setPosition(posInfo[index].x,posInfo[index].y)
		normalBtn.prayId = pray.prayId
		prayButtons[index].normalBtn = normalBtn
		local infoLab = ui.newTTFLabel({text = CommonText[912][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = normalBtn:getContentSize().width / 2, y = 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(normalBtn)
		infoLab:setAnchorPoint(cc.p(0.5, 0.5))


		local selectedBtn = ScaleButton.new(selected, handler(self, self.speedHandler)):addTo(prayNode)
		selectedBtn:setPosition(posInfo[index].x,posInfo[index].y + 34)
		selectedBtn.pray = pray
		local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 1, 
			x = selectedBtn:getContentSize().width / 2, y = 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(selectedBtn)
		timeLab:setAnchorPoint(cc.p(0.5, 0.5))
		selectedBtn.m_timeLab = timeLab
		prayButtons[index].selectedBtn = selectedBtn

		local awardBtn = ScaleButton.new(awardPic, handler(self, self.awardHandler)):addTo(prayNode)
		awardBtn:setPosition(posInfo[index].x - 5,posInfo[index].y + 11)
		awardBtn.pray = pray
		prayButtons[index].awardBtn = awardBtn
		local infoLab = ui.newTTFLabel({text = CommonText[912][3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = awardBtn:getContentSize().width / 2, y = 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(awardBtn)
		infoLab:setAnchorPoint(cc.p(0.5, 0.5))
	end
	self.m_prayNode = prayNode
	self.prayButtons = prayButtons
end

function ActivityCelebrateView:prayHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityPrayCardDialog").new(sender.prayId):push()
end

function ActivityCelebrateView:speedHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function gotoSpeed()
		local prayTime = sender.pray.prayTime
		if prayTime == 0 then
			return 
		end

		Loading.getInstance():show()
		ActivityCenterBO.asynActPrayAward(function()
			Loading.getInstance():unshow()
			end,ACTIVITY_PRAY_AWARD_GOLD,sender.pray)
	end

	--金币判断
	local prayTime = sender.pray.prayTime
	local needCoin = math.ceil(prayTime / BUILD_ACCEL_TIME)

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[916], needCoin), function() gotoSpeed() end):push()
	else
		gotoSpeed()
	end

	
end

function ActivityCelebrateView:awardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynActPrayAward(function()
		Loading.getInstance():unshow()
		end,ACTIVITY_PRAY_AWARD_NORMAL,sender.pray)
end



function ActivityCelebrateView:awardPortraitHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	if sender.type == 2 then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end

	Loading.getInstance():show()
	ActivityCenterBO.asynReceiveAward(function()
		Loading.getInstance():unshow()
		self:updateCelebrateView()
		end, self.m_activity.activityId, sender.data)

end

function ActivityCelebrateView:awardDayHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	if sender.type == 2 then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end

	Loading.getInstance():show()
	ActivityCenterBO.asynReceiveAward(function()
		Loading.getInstance():unshow()
		self:updateCelebrateView()
		end, self.m_activity.activityId, sender.data)
end

function ActivityCelebrateView:awardTopupHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	if sender.type == 2 then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end

	Loading.getInstance():show()
	ActivityCenterBO.asynReceiveAward(function()
		Loading.getInstance():unshow()
		local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).celeData
		activityContent.payTopup.state = activityContent.payTopup.state - activityContent.payTopup.activityCond.cond

		local activityCond = sender.data
		if activityContent.payTopup.state >= activityContent.payTopup.activityCond.cond then
			activityCond.status = 0
		end

		self:updateCelebrateView()
		end, self.m_activity.activityId, sender.data)

end


function ActivityCelebrateView:update(dt)

	if self.m_timeLab then
		local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
		if leftTime > 0 then
			self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
		else
			self.m_timeLab:setString(CommonText[852])
		end
	end
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
	if activityContent and self.prayButtons then
		local prayData = activityContent.prayData
		for index = 1,#prayData do
			local pray = prayData[index]

			if pray.card > 0 then
				self.prayButtons[index].normalBtn:setVisible(false)
				if pray.prayTime > 0 then
					self.prayButtons[index].awardBtn:setVisible(false)
					self.prayButtons[index].selectedBtn:setVisible(true)
					self.prayButtons[index].selectedBtn.m_timeLab:setString(string.format(CommonText[912][2],ActivityCenterBO.formatPrayTime(pray.prayTime)))
				else
					self.prayButtons[index].awardBtn:setVisible(true)
					self.prayButtons[index].selectedBtn:setVisible(false)
				end
			else
				self.prayButtons[index].normalBtn:setVisible(true)
				self.prayButtons[index].selectedBtn:setVisible(false)
				self.prayButtons[index].awardBtn:setVisible(false)
			end
		end

	end 

end

function ActivityCelebrateView:onExit()
	ActivityCelebrateView.super.onExit(self)

	if self.m_rechargeHandler then
		Notify.unregister(self.m_rechargeHandler)
		self.m_rechargeHandler = nil
	end
end





return ActivityCelebrateView

