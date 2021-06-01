--
-- Author: gf
-- Date: 2016-03-24 15:39:16
-- 充值转盘

--N次后开启一键抽奖
DO_ALL_TIME = 3


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")


local ActivityPayTurntableView = class("ActivityPayTurntableView", UiNode)

function ActivityPayTurntableView:ctor(activity)
	ActivityPayTurntableView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityPayTurntableView:onEnter()
	ActivityPayTurntableView.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)
	self.m_Turntimes = 0 --默认转了0次。
	self.need_DoAll = true --默认需要开启全部

	Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				self:showUI()
				self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
				self:scheduleUpdate()
		end, self.m_activity.activityId,1)

end


function ActivityPayTurntableView:showUI()
	local info = ActivityCenterMO.getGambleById(self.m_activity.awardId)
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
	local infoTit = ui.newTTFLabel({text = CommonText[886][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(infoBg)
	infoTit:setAnchorPoint(cc.p(0, 0.5))
	infoTit:setPosition(20, 45)

	local infoLab = ui.newTTFLabel({text = string.format(CommonText[886][2], info.topup) , font = G_FONT, size = FONT_SIZE_SMALL, dimensions = cc.size(270, 60),
   	color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(infoBg)
	infoLab:setAnchorPoint(cc.p(0, 1))
	infoLab:setPosition(infoTit:getPositionX() + infoTit:getContentSize().width, 65)


	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local text = clone(DetailText.activityPayTurntable)
			text[2][1].content = string.format(text[2][1].content, info.topup)
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
	self.m_r = 190
	self.m_coe = 0
	self.m_scaleCoe = 0.65		


	--抽奖花费
	-- local coinIcon = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(goBtn)
	-- coinIcon:setPosition(50,35)
	-- local needPrice = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
 --   	color = COLOR[1]}):addTo(goBtn)
	-- needPrice:setAnchorPoint(cc.p(0, 0.5))
	-- needPrice:setPosition(coinIcon:getPositionX() + 20, coinIcon:getPositionY())
	-- self.m_needPrice = needPrice

	self:updateUI()
end

function ActivityPayTurntableView:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function ActivityPayTurntableView:updateUI()
	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
	self.m_activityContent = activityContent
	self.m_rechargeValue:setString(activityContent.topup)
	self.m_countValue:setString(activityContent.count)

	local currentTopupGamble = activityContent.topupGamble
	self.m_currentTopupGamble = currentTopupGamble

	local awards = currentTopupGamble.awards
	gdump(awards,"ActivityPayTurntableView .. awards===")
	if self.m_awardUI then self.m_contentBg:removeChild(self.m_awardUI, true) end
	self.m_awardUI = nil
	local awardUI = display.newNode():addTo(self.m_contentBg,999)
	self.m_awardUI = awardUI

	self.m_itemList = {}
	
	local r = 190
	local _r = r - 50
	for index= #awards , 1 , -1 do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award.type, award.id)
		self.m_itemList[index] = clone(itemView)
		UiUtil.createItemDetailButton(itemView)
		
		local strLabel = ui.newBMFontLabel({text = "x" .. award.count, font = "fnt/num_8.fnt", align = ui.TEXT_ALIGN_CENTER})--:addTo(self)
		strLabel:setAnchorPoint(cc.p(0.5, 0.5))

		local rads = 36 * (index - 1) + 36

		local rad = (index - 1) * (-36) + 18 + 36
		local x =	math.cos(math.rad(rad)) * r + self.m_contentBg:width() * 0.5
		local y =	math.sin(math.rad(rad)) * r +  self.m_contentBg:height() * 0.5

		itemView:addChild(strLabel)
		strLabel:setPosition(itemView:width() * 0.5 , -28)

		itemView:setRotation(rads)
		itemView:setScale(0.65)
		itemView:setPosition(x,y)
		self.m_awardUI:addChild(itemView)
	end
end

function ActivityPayTurntableView:lotteryhandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doAnima()
		for index=1,#self.m_itemList do
			local rads = 36 * (index - 1 + self.m_coe) + 36
			local rad = (index - 1 + self.m_coe) * (-36) + 18 + 36
			local x =	math.cos(math.rad(rad)) * self.m_r + self.m_contentBg:width() * 0.5
			local y =	math.sin(math.rad(rad)) * self.m_r +  self.m_contentBg:height() * 0.5

			self.m_itemList[index]:setRotation(rads)
			self.m_itemList[index]:setScale(self.m_scaleCoe)
			self.m_itemList[index]:setPosition(x,y)
		end
		self.m_coe = self.m_coe + 0.1
		self.m_r = self.m_r - 7
		self.m_scaleCoe = self.m_scaleCoe - 0.008

		if self.m_r > 0 then
			self:performWithDelay(function ()
				doAnima()
			end, 0.005)
		else
			require("app.dialog.ActivityPayTurnAwardDialog").new(self.m_awards):push()
			local r = 190
			local _r = r - 50
			for index=1,#self.m_itemList do
				local rads = 36 * (index - 1) + 36
				local rad = (index - 1) * (-36) + 18 + 36
				local x =	math.cos(math.rad(rad)) * r + self.m_contentBg:width() * 0.5
				local y =	math.sin(math.rad(rad)) * r +  self.m_contentBg:height() * 0.5

				self.m_itemList[index]:setRotation(rads)
				self.m_itemList[index]:setScale(0.65)
				self.m_itemList[index]:setPosition(x,y)
			end
			self.m_r = 190
			self.m_coe = 0
			self.m_scaleCoe = 0.65
			return
		end
	end

	--判断次数
	if self.m_activityContent.count <= 0 then
		Toast.show(CommonText[884])
		return
	end

	local function doAll()
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActPayTurntable(function(awards)
			Loading.getInstance():unshow()
			self.m_awards = awards
			local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
			self.m_activityContent = activityContent
			self.m_countValue:setString(activityContent.count)
				doAnima()
			end, self.m_activityContent.count)
	end

	if self.m_Turntimes >= DO_ALL_TIME and self.need_DoAll and self.m_activityContent.count > 0 then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1638],function ()
			doAll()
		end, nil, function ()
			self.need_DoAll = false
		end):push()
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
		ActivityCenterBO.asynDoActPayTurntable(function(awards)
			Loading.getInstance():unshow()
			local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
			self.m_countValue:setString(activityContent.count)
			self:showResultEffect(awards)
			self.m_Turntimes = self.m_Turntimes + 1
			end,1) --单抽
	end 

	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[885],cost), function()
			doLottery()
			end):push()
	else
		doLottery()
	end

end

function ActivityPayTurntableView:showResultEffect(awards)

	--根据获得的金币判断抽中哪一档
	local resultIdx = ActivityCenterBO.getAwardPayTurntableIdx(self.m_currentTopupGamble,awards[1])
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
				if awards then
					statsAward = CombatBO.addAwards(awards)
					UiUtil.showAwards(statsAward)
				end
			end)}))
	else
		gprint("resultIdx:",resultIdx)
	end
end

function ActivityPayTurntableView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
end

function ActivityPayTurntableView:refreshUI(name)
	if name == "RechargeView" then
		Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
			Loading.getInstance():unshow()
			local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
			self.m_activityContent = activityContent
			self.m_countValue:setString(activityContent.count)
		end, self.m_activity.activityId,1)
	end
end

function ActivityPayTurntableView:onExit()
	ActivityPayTurntableView.super.onExit(self)
end

return ActivityPayTurntableView


