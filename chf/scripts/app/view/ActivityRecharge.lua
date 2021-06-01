--
-- Author: xiaoxing
-- Date: 2016-11-30 16:28:19
--
local ActivityRecharge = class("ActivityRecharge", UiNode)

function ActivityRecharge:ctor(activity)
	ActivityRecharge.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityRecharge:onEnter()
	ActivityRecharge.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	ActivityCenterBO.getPayRebate(function(data)
			self.data = data
			self:showUI()
		end)

	self.hanlder = Notify.register("ACTIVITY_ID_RECHARGE_UPDATA_UI", handler(self, self.refreshUI))
end


function ActivityRecharge:showUI()
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_70.png"):addTo(self:getBg())
	infoBg:scaleTY(72)
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height - 82)
	-- 活动时间
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(20, infoBg:y()+14)
	self.m_timeLab = timeLab

	--活动说明
	local infoTit = ui.newTTFLabel({text = CommonText[882][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(self:getBg())
	infoTit:setAnchorPoint(cc.p(0, 0.5))
	infoTit:setPosition(20, infoBg:y()-14)

	local infoLab = ui.newTTFLabel({text = CommonText[20158], font = G_FONT, size = FONT_SIZE_SMALL, dimensions = cc.size(350, 60),
   	color = COLOR[1], align = ui.TEXT_ALIGN_LEFT}):addTo(self:getBg())
	infoLab:setAnchorPoint(cc.p(0, 0.5))
	infoLab:setPosition(infoTit:getPositionX() + infoTit:getContentSize().width, infoTit:y())


	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityRecharge):push()
		end):addTo(self:getBg())
	detailBtn:setPosition(infoBg:getContentSize().width - 50, infoBg:y())


	--内容背景
	local contentBg = display.newSprite(IMAGE_COMMON .. "info_bg_gamble.jpg"):addTo(self:getBg())
	contentBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 470)
	self.m_contentBg = contentBg
	
	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(contentBg)
		chanceBtn:setPosition(50, contentBg:height() - 30)
		chanceBtn:setVisible(chance.open == 1)
	end

	--剩余次数
	local countTit = ui.newTTFLabel({text = CommonText[883][2], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1]}):addTo(contentBg)
	countTit:setAnchorPoint(cc.p(0, 0.5))
	countTit:setPosition(470, 580)

	local countValue = ui.newTTFLabel({text = self.data.num, font = G_FONT, size = FONT_SIZE_SMALL,
   	color = COLOR[2], align = ui.TEXT_ALIGN_LEFT}):addTo(contentBg)
	countValue:setAnchorPoint(cc.p(0, 0.5))
	countValue:setPosition(countTit:getPositionX() + countTit:getContentSize().width, countTit:getPositionY())
	self.left = countValue

	self.tip = UiUtil.label(CommonText[20159][1]):addTo(self):align(display.LEFT_CENTER, 142, 160)
	--等级bar
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(350, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(350 + 4, 26)}):addTo(self:getBg())
		:pos(self:getBg():width()/2,120)
	self.bar = bar
	self.bar.num = UiUtil.label("0/0"):addTo(self.bar,10):center()

	--前往充值按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local rechargeBtn = MenuButton.new(normal, selected, disabled, handler(self,self.rechargeHandler)):addTo(self:getBg())
	rechargeBtn:setPosition(self:getBg():getContentSize().width / 2, 60)
	rechargeBtn:setLabel(CommonText[757][2])
	rechargeBtn:setEnabled(self.data.rate > 0)
	self.rechargeBtn = rechargeBtn
	--bar后面经验等级显示
	self:showLabel()

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
	
	self:updateUI(1)
end

function ActivityRecharge:showLabel(data)
	local data = data or self.data
	self.tip:removeAllChildren()
	local t = UiUtil.label(data.money == 0 and "?" or data.money,nil,COLOR[data.money == 0 and 6 or 2])
		:addTo(self.tip):align(display.LEFT_CENTER, self.tip:width(), self.tip:height()/2)
	t = UiUtil.label(CommonText[20159][2]):rightTo(t)
	t = UiUtil.label(data.rate == 0 and "?" or (data.rate .."%"),nil,COLOR[data.rate == 0 and 6 or 2]):rightTo(t)
	t = UiUtil.label(CommonText[20159][3]):rightTo(t)

	self.bar:setPercent(data.money == 0 and 0 or data.recharge/data.money)
	self.bar.num:setString(data.recharge .."/"..data.money)
	if data.money > 0 and not self.coin then
		self.coin = UiUtil.createItemView(ITEM_KIND_COIN, 0, {count=data.money*data.rate/100})
			:addTo(self:getBg()):pos(self:getBg():width()-70,140):scale(0.8)
	elseif data.money == 0 then
		if self.coin then self.coin:removeSelf() self.coin = nil end
	end
	self.rechargeBtn:setEnabled(self.data.rate > 0)
end

function ActivityRecharge:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
end

function ActivityRecharge:updateUI(state)
	local item = ActivityCenterMO.getRechargeTurn(state)

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
	if self.m_awardUI then self.m_contentBg:removeChild(self.m_awardUI, true) end
	self.m_awardUI = nil
	local awardUI = display.newNode():addTo(self.m_contentBg)
	self.m_awardUI = awardUI
	for index=1,#item do
		local award = item[index]

		local itemView = nil
		if state == 1 then
			itemView = UiUtil.label(award.value .. (state == 1 and "%" or ""), 30)
		else
			itemView = UiUtil.createItemView(ITEM_KIND_COIN, 0, {count = award.value}):scale(0.8)
		end
		itemView:setPosition(awardPos[index].x,awardPos[index].y)
		self.m_awardUI:addChild(itemView)
	end
end

function ActivityRecharge:lotteryhandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if tonumber(self.left:getString()) <= 0 then
		Toast.show(CommonText[20161])
		return
	end
	if self.data.money > 0 and self.data.recharge < self.data.money then
		self.noRefresh = true
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[20160][3], function()
				self.noRefresh = nil
				ActivityCenterBO.doPayRebate(function(data)
						self.data = data
						self:updateUI(1)
						self:showLabel({money=0,rate = 0,recharge=0})
						self:showResultEffect(1,self.data.rate)
						self.left:setString(self.data.num)
					end)
			end,function() self.noRefresh = nil end):push()
	else
		ActivityCenterBO.doPayRebate(function(data)
				self.data = data
				self:updateUI(1)
				self:showLabel({money=0,rate = 0,recharge=0})
				self:showResultEffect(1,self.data.rate)
				self.left:setString(self.data.num)
			end)
	end
end

function ActivityRecharge:showResultEffect(kind,value)
	--根据获得的金币判断抽中哪一档
	local resultIdx = 0
	local item = ActivityCenterMO.getRechargeTurn(kind)
	for k,v in ipairs(item) do
		if v.value == value then
			resultIdx = k
			break
		end
	end
	if resultIdx > 0 then
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
			cc.RotateBy:create(1,360 * 5),
			cc.RotateBy:create(0.1,120),
			cc.RotateBy:create(0.2,120),
			cc.RotateBy:create(0.3,120),
			cc.RotateBy:create(0.2 * resultIdx,360 * resultIdx / #item),
			cc.CallFunc:create(function()	
				self.m_resultPic:setRotation(360 * resultIdx / #item)
				self.m_resultPic:setVisible(true)
				if kind == 1 then
					Toast.show(string.format(CommonText[20160][kind], value .."%"))
				else
					Toast.show(string.format(CommonText[20160][2], value, self.data.rate .."%"))
				end
				--获得奖励
				if kind == 1 then
					self:showLabel({money=0,rate = self.data.rate,recharge=0})
					self:performWithDelay(function()
						if self.bgMask then self:removeChild(self.bgMask, true) end
						self:updateUI(2)
						self:showResultEffect(2,self.data.money)
					end, 2.2)
				else
					self:showLabel({money=self.data.money,rate = self.data.rate,recharge=0})
					if self.bgMask then self:removeChild(self.bgMask, true) end
				end
			end)}))
	else
		gprint("resultIdx:",resultIdx)
	end
end

function ActivityRecharge:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
	local t = ManagerTimer.getTime()
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	if h == 0 and m == 0 and s == 0 then
		ActivityCenterBO.getPayRebate(function(data)
			--重置界面
			if self.bgMask then self:removeChild(self.bgMask, true) self.bgMask = nil end
			self.data = data
			self:updateUI(1)
			self.m_arrowPic:stopAllActions()
			self.m_arrowPic:setRotation(0)
			self.m_resultPic:hide()
			self.left:setString(self.data.num)
			self:showLabel()
		end)
	end
end

function ActivityRecharge:refreshUI()
	if not self.noRefresh then 
		ActivityCenterBO.getPayRebate(function(data)
			self.data = data
			self:showLabel()
		end)
	end
end

function ActivityRecharge:onExit()
	ActivityRecharge.super.onExit(self)
	if self.hanlder then
		Notify.unregister(self.hanlder)
		self.hanlder = nil
	end
	
end

return ActivityRecharge


