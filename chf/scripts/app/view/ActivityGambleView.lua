--
-- Author: gf
-- Date: 2016-03-22 15:40:08
-- 下注赢金币


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")


local ActivityGambleView = class("ActivityGambleView", UiNode)

function ActivityGambleView:ctor(activity)
	ActivityGambleView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityGambleView:onEnter()
	ActivityGambleView.super.onEnter(self)
	self.m_rechargeHandler = Notify.register(LOCAL_RECHARGE_UPDATE_EVENT, handler(self, self.refreshUI))
	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				self:showUI()
				self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
				self:scheduleUpdate()
		end, self.m_activity.activityId,1)

end


function ActivityGambleView:showUI()
	local currentTopupGamble = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_GAMBLE)
	local gamBles = currentTopupGamble.topupGambles
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "bar_gamble.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height)
	-- 活动时间
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(20, 75)
	self.m_timeLab = timeLab

	--活动说明
	local infoTit = ui.newTTFLabel({text = CommonText[882][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(infoBg)
	infoTit:setAnchorPoint(cc.p(0, 0.5))
	infoTit:setPosition(20, 45)

	local infoLab = ui.newTTFLabel({text = CommonText[882][2], font = G_FONT, size = FONT_SIZE_SMALL, dimensions = cc.size(270, 60),
   	color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(infoBg)
	infoLab:setAnchorPoint(cc.p(0, 1))
	infoLab:setPosition(infoTit:getPositionX() + infoTit:getContentSize().width, 65)

	local text = {}
	table.insert(text, {{content = CommonText[976]}})
	for index = 1,#gamBles do
		local gbId = gamBles[index].gambleId
		local gbInfo = ActivityCenterMO.getGambleById(gbId)
		local actDesc = gbInfo.desc
		table.insert(text, {{content = "    "..actDesc}})
	end
	table.insert(text, {{content = CommonText[977]}})
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(text):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 30)


	--内容背景
	local contentBg = display.newSprite(IMAGE_COMMON .. "info_bg_gamble.jpg"):addTo(self:getBg())
	contentBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 620)
	self.m_contentBg = contentBg
	--我的充值
	local rechargeTit = ui.newTTFLabel({text = CommonText[883][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(contentBg)
	rechargeTit:setAnchorPoint(cc.p(0, 0.5))
	rechargeTit:setPosition(20, 580)

	local rechargeValue = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL,
   	color = COLOR[2], align = ui.TEXT_ALIGN_LEFT}):addTo(contentBg)
	rechargeValue:setAnchorPoint(cc.p(0, 0.5))
	rechargeValue:setPosition(rechargeTit:getPositionX() + rechargeTit:getContentSize().width, rechargeTit:getPositionY())
	self.m_rechargeValue = rechargeValue
	
	--剩余次数
	local countTit = ui.newTTFLabel({text = CommonText[883][2], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(contentBg)
	countTit:setAnchorPoint(cc.p(0, 0.5))
	countTit:setPosition(220, 580)

	local countValue = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL,
   	color = COLOR[2], align = ui.TEXT_ALIGN_LEFT}):addTo(contentBg)
	countValue:setAnchorPoint(cc.p(0, 0.5))
	countValue:setPosition(countTit:getPositionX() + countTit:getContentSize().width, countTit:getPositionY())
	self.m_countValue = countValue


	--前往充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(self:getBg())
	rechargeBtn:setPosition(self:getBg():getContentSize().width / 2, 40)
	rechargeBtn:setLabel(CommonText[757][2])


	--结果效果
	local resultPic = display.newSprite(IMAGE_COMMON .. "gamble_go_result.png"):addTo(contentBg,100)
	resultPic:setPosition(306,305)
	resultPic:setAnchorPoint(cc.p(0.5,0))
	resultPic:setVisible(false)
	self.m_resultPic = resultPic

	--箭头
	local arrowPic = display.newSprite(IMAGE_COMMON .. "arrow_gamble_go.png"):addTo(contentBg,101)
	arrowPic:setPosition(self.m_contentBg:getContentSize().width / 2, self.m_contentBg:getContentSize().height / 2)
	arrowPic:setAnchorPoint(cc.p(0.5,0.5))
	self.m_arrowPic = arrowPic


	--抽奖按钮
	local sprite = display.newSprite(IMAGE_COMMON .. "btn_gamble_go.png")
	local goBtn = ScaleButton.new(sprite, handler(self, self.lotteryhandler)):addTo(contentBg,102)
	goBtn:setPosition(self.m_contentBg:getContentSize().width / 2, self.m_contentBg:getContentSize().height / 2)
	goBtn:setAnchorPoint(cc.p(0.5,0.5))
	
	--抽奖花费
	local coinIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(goBtn)
	coinIcon:setPosition(50,35)
	local needPrice = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(goBtn)
	needPrice:setAnchorPoint(cc.p(0, 0.5))
	needPrice:setPosition(coinIcon:getPositionX() + 20, coinIcon:getPositionY())
	self.m_needPrice = needPrice

	self:updateUI()
end

function ActivityGambleView:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function ActivityGambleView:updateUI()
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
	self.m_activityContent = activityContent
	self.m_rechargeValue:setString(activityContent.topup)
	self.m_countValue:setString(activityContent.count)

	local currentTopupGamble = ActivityCenterBO.getCurrentGamble()
	self.m_currentTopupGamble = currentTopupGamble

	local awardPos = {
		{x = 410, y = 455},
		{x = 480, y = 355},
		{x = 480, y = 255},
		{x = 410, y = 160},
		{x = 308, y = 120},
		{x = 200, y = 160},
		{x = 135, y = 255},
		{x = 135, y = 355},
		{x = 200, y = 455},
		{x = 308, y = 490}
	}
	local awards = currentTopupGamble.awards
	gdump(awards,"ActivityGambleView .. awards===")
	if self.m_awardUI then self.m_contentBg:removeChild(self.m_awardUI, true) end
	self.m_awardUI = nil
	local awardUI = display.newNode():addTo(self.m_contentBg)
	self.m_awardUI = awardUI
	for index=1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id)
		local strLabel = ui.newTTFLabel({text = award.count, font = G_FONT, size = FONT_SIZE_LIMIT, color = COLOR[1], algin = ui.TEXT_ALIGN_RIGHT})

		local suffix = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(itemView)
		suffix:setPreferredSize(cc.size(strLabel:getContentSize().width + 10, strLabel:getContentSize().height))
		suffix:setPosition(itemView:getContentSize().width - suffix:getContentSize().width / 2 - 16, 14)

		strLabel:addTo(suffix)
		strLabel:setPosition(suffix:getContentSize().width / 2, suffix:getContentSize().height / 2)
		suffix:setScale(1.5)

		itemView:setScale(0.75)
		itemView:setPosition(awardPos[index].x,awardPos[index].y)
		self.m_awardUI:addChild(itemView)
	end

	self.m_needPrice:setString(currentTopupGamble.price)

end

function ActivityGambleView:refreshUI(name)
	if name == "RechargeView" then
		ActivityCenterBO.asynGetActivityContent(function(data)
				self:updateUI()
			end,ACTIVITY_ID_GAMBLE)
	end
end

function ActivityGambleView:lotteryhandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- self:showResultEffect(10)
	-- do return end

	--判断次数
	if self.m_activityContent.count > 0 then
		self:updateUI()
	else
		Toast.show(CommonText[884])
		return
	end
	--判断金币
	local cost = self.m_currentTopupGamble.price

	function doLottery()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActGamble(function(gold)
			Loading.getInstance():unshow()
			local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
			self.m_countValue:setString(activityContent.count)
			local currentTopupGamble = ActivityCenterBO.getCurrentGamble()
			self.m_needPrice:setString(currentTopupGamble.price)

			self:showResultEffect(gold)
			end,cost)		
	end 

	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[885],cost), function()
			doLottery()
			end):push()
	else
		doLottery()
	end

end

function ActivityGambleView:showResultEffect(gold)

	--根据获得的金币判断抽中哪一档
	local resultIdx = ActivityCenterBO.getAwardGambleIdx(self.m_currentTopupGamble,gold)
	-- resultIdx = 7
	if resultIdx and resultIdx > 0 and resultIdx <= #self.m_currentTopupGamble.awards then

		--黑色遮罩
		local rect = CCRectMake(0, 0, GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)
		local bgMask = CCSprite:create("image/common/bg_ui.jpg", rect)
		bgMask:setCascadeBoundingBox(rect)
		bgMask:setColor(ccc3(0, 0, 0))
		bgMask:setOpacity(0)
		bgMask:setPosition(GAME_SIZE_WIDTH / 2, GAME_SIZE_HEIGHT / 2)
		self:addChild(bgMask,199)
		self.bgMask = bgMask

		nodeTouchEventProtocol(bgMask, function(event)  
                end, nil, true, true)
		self.m_resultPic:setVisible(false)
		self.m_arrowPic:setRotation(0);
		self.m_arrowPic:runAction(transition.sequence({
			cc.RotateBy:create(1,360 * 4),
			cc.RotateBy:create(0.1,120),
			cc.RotateBy:create(0.2,120),
			cc.RotateBy:create(0.3,120),
			cc.RotateBy:create(0.2 * resultIdx,360 * resultIdx / #self.m_currentTopupGamble.awards),
			cc.CallFunc:create(function()	
				if self.bgMask then self:removeChild(self.bgMask, true) end
				self.m_resultPic:setRotation(360 * resultIdx / #self.m_currentTopupGamble.awards)
				self.m_resultPic:setVisible(true)

				--获得奖励
				local award = {type = ITEM_KIND_COIN,id = 0,count = gold,detailed = true}
				local awards = {}
				awards[#awards + 1] = award
				local statsAward = nil
				if awards then
					statsAward = CombatBO.addAwards(awards)
					UiUtil.showAwards(statsAward)
				end
			end)}))
	else
		gprint("resultIdx:",resultIdx)
	end
end

function ActivityGambleView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
end


function ActivityGambleView:onExit()
	ActivityGambleView.super.onExit(self)
end





return ActivityGambleView


