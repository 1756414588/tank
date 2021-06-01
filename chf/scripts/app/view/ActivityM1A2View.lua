--
-- Author: gf
-- Date: 2016-05-12 11:26:55
-- 热门活动 M1A2

local ActivityM1A2View = class("ActivityM1A2View", UiNode)

function ActivityM1A2View:ctor(activity)
	ActivityM1A2View.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityM1A2View:onEnter()
	ActivityM1A2View.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	self:hasCoinButton(true)

	local function createDelegate(container, index)
		self.m_timeLab = nil
		if index == 1 then  
			self:showLotteryView(container)
		elseif index == 2 then 
			container.showStatus = 1
			self:showFormulaView(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[936][1],CommonText[936][2]}


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

function ActivityM1A2View:showLotteryView(container)
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(30, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(container,999)
		chanceBtn:setPosition(container:width() - 230, container:height() - 30)
		chanceBtn:setVisible(chance.open == 1)
	end

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 20)
	self.m_timeLab = timeLab


	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityM1A2):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 60)

	--背景图
	local btm = display.newSprite(IMAGE_COMMON .. 'info_bg_30.jpg'):addTo(container)
	btm:setPosition(container:getContentSize().width / 2, container:getContentSize().height - btm:getContentSize().height / 2 - 100)



	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	self.m_activityContent = activityContent

	local act1 = ActivityCenterMO.getA1m2ById(1)
	local act2 = ActivityCenterMO.getA1m2ById(2)
	--坦克图片
	local tank = UiUtil.createItemSprite(ITEM_KIND_TANK, act2.tankId)
		:addTo(btm):pos(100, btm:getContentSize().height - 60)

	--目前最厉害
	local infoLab = ui.newTTFLabel({text = CommonText[937], font = G_FONT, size = FONT_SIZE_MEDIUM, 
		x = tank:getPositionX() + tank:getContentSize().width / 2 + 10, y = tank:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	infoLab:setAnchorPoint(cc.p(0, 0.5))

	--左边BUTTON
	local normal = display.newSprite(IMAGE_COMMON .. "btn_m1a2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_m1a2_selected.png")
	local leftButton = MenuButton.new(normal, selected, nil, handler(self,self.lotteryTypeHandler))
	leftButton:setPosition(btm:getContentSize().width / 2 - 150, btm:getContentSize().height - 270)
	btm:addChild(leftButton)
	leftButton:selected()
	leftButton:setTag(M1A2_LOTTERY_TYPE_NORMAL)
	self.m_leftButton = leftButton

	self.lotteryType = M1A2_LOTTERY_TYPE_NORMAL

	--左边标题
	local leftTitle = ui.newTTFLabel({text = CommonText[938][1], font = G_FONT, size = FONT_SIZE_SMALL + 2, 
		x = leftButton:getContentSize().width / 2, y = 235, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(leftButton)
	leftTitle:setAnchorPoint(cc.p(0.5, 0.5))

	--左边坦克图片
	local normal = UiUtil.createItemSprite(ITEM_KIND_TANK, act1.tankId)
	local selected = UiUtil.createItemSprite(ITEM_KIND_TANK, act1.tankId)
	local leftTankPic = MenuButton.new(normal, selected, nil, function()
		require("app.dialog.DetailTankDialog").new(act1.tankId):push()
	end)
	leftTankPic:setPosition(leftButton:getContentSize().width / 2, 120)
	leftTankPic:setScale(1.4)
	leftTankPic:setTag(M1A2_LOTTERY_TYPE_NORMAL)
	leftButton:addChild(leftTankPic)

	--右边BUTTON
	local normal = display.newSprite(IMAGE_COMMON .. "btn_m1a2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_m1a2_selected.png")
	local rightButton = MenuButton.new(normal, selected, nil, handler(self,self.lotteryTypeHandler))
	rightButton:setPosition(btm:getContentSize().width / 2 + 150, btm:getContentSize().height - 270)
	btm:addChild(rightButton)
	rightButton:setTag(M1A2_LOTTERY_TYPE_SENIOR)
	self.m_rightButton = rightButton

	--右边标题
	local rightTitle = ui.newTTFLabel({text = CommonText[938][2], font = G_FONT, size = FONT_SIZE_SMALL + 2, 
		x = leftButton:getContentSize().width / 2, y = 235, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(rightButton)
	rightTitle:setAnchorPoint(cc.p(0.5, 0.5))

	--右边坦克图片
	local normal = UiUtil.createItemSprite(ITEM_KIND_TANK, act2.tankId)
	local selected = UiUtil.createItemSprite(ITEM_KIND_TANK, act2.tankId)
	local rightTankPic = MenuButton.new(normal, selected, nil, function()
		require("app.dialog.DetailTankDialog").new(act2.tankId):push()
	end)
	rightTankPic:setPosition(leftButton:getContentSize().width / 2, 120)
	rightTankPic:setScale(1.4)
	rightTankPic:setTag(M1A2_LOTTERY_TYPE_SENIOR)
	rightButton:addChild(rightTankPic)


	--说明文字
	local lab = ui.newTTFLabel({text = CommonText[939][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = 150, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab:setAnchorPoint(cc.p(0, 0.5))

	local lab = ui.newTTFLabel({text = CommonText[939][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = 120, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	lab:setAnchorPoint(cc.p(0, 0.5))

	self.awardBtn = UiUtil.button("btn_19_normal.png","btn_19_selected.png",nil,handler(self,self.awardInfo),CommonText[20146])
		:addTo(btm):pos(505,135)

	--普通探索按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local lotteryNormalBtn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(btm)
	lotteryNormalBtn:setPosition(btm:getContentSize().width / 2 - 150, 50)

	local icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lotteryNormalBtn:getContentSize().width / 2 - 30,lotteryNormalBtn:getContentSize().height / 2 - 13):addTo(lotteryNormalBtn)
	local need = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(lotteryNormalBtn)
	need:setAnchorPoint(cc.p(0, 0.5))
	need:setPosition(icon:getPositionX() + icon:getContentSize().width / 2 + 5,icon:getPositionY() + 2)
	lotteryNormalBtn.icon = icon
	lotteryNormalBtn.need = need
	lotteryNormalBtn.cost1 = act1.priceOne
	lotteryNormalBtn.cost2 = act2.priceOne
	lotteryNormalBtn:setTag(1)
	self.lotteryNormalBtn = lotteryNormalBtn



	--高级探索按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lotterySeniorBtn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(btm)
	lotterySeniorBtn:setPosition(btm:getContentSize().width / 2 + 150, 50)

	local icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lotterySeniorBtn:getContentSize().width / 2 - 30,lotterySeniorBtn:getContentSize().height / 2 - 13):addTo(lotterySeniorBtn)
	local need = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(lotterySeniorBtn)
	need:setAnchorPoint(cc.p(0, 0.5))
	need:setPosition(icon:getPositionX() + icon:getContentSize().width / 2 + 5,icon:getPositionY() + 2)
	lotterySeniorBtn.icon = icon
	lotterySeniorBtn.need = need
	lotterySeniorBtn.cost1 = act1.priceTen
	lotterySeniorBtn.cost2 = act2.priceTen
	lotterySeniorBtn:setTag(2)
	self.lotterySeniorBtn = lotterySeniorBtn

	--按钮
	self:updateLotteryBtn()

end

function ActivityM1A2View:lotteryTypeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_activityContent.hasFree and tag == M1A2_LOTTERY_TYPE_SENIOR then
		Toast.show(CommonText[20147])
		return
	end
	self.lotteryType = tag
	if tag == M1A2_LOTTERY_TYPE_NORMAL then
		self.m_leftButton:selected()
		self.m_rightButton:unselected()
	elseif tag == M1A2_LOTTERY_TYPE_SENIOR then
		self.m_leftButton:unselected()
		self.m_rightButton:selected()
	end
	self:updateLotteryBtn()
end

function ActivityM1A2View:updateLotteryBtn()
	if self.lotteryType == M1A2_LOTTERY_TYPE_NORMAL then
		if self.m_activityContent.hasFree then
			self.lotteryNormalBtn.icon:setVisible(false)
			self.lotteryNormalBtn.need:setVisible(false)
			self.lotteryNormalBtn:setLabel(CommonText[781])
			self.lotterySeniorBtn:hide()
		else
			self.lotterySeniorBtn:show()
			self.lotteryNormalBtn.icon:setVisible(true)
			self.lotteryNormalBtn.need:setVisible(true)
			self.lotteryNormalBtn.need:setString(self.lotteryNormalBtn.cost1)
			self.lotteryNormalBtn:setLabel(string.format(CommonText[766],1),{size = FONT_SIZE_SMALL - 2, y = self.lotteryNormalBtn:getContentSize().height / 2 + 13})
		end

		self.lotterySeniorBtn.need:setString(self.lotterySeniorBtn.cost1)
		self.lotterySeniorBtn:setLabel(string.format(CommonText[766],10),{size = FONT_SIZE_SMALL - 2, y = self.lotteryNormalBtn:getContentSize().height / 2 + 13})


	elseif self.lotteryType == M1A2_LOTTERY_TYPE_SENIOR then
		self.lotteryNormalBtn.icon:setVisible(true)
		self.lotteryNormalBtn.need:setVisible(true)

		self.lotteryNormalBtn.need:setString(self.lotteryNormalBtn.cost2)
		self.lotteryNormalBtn:setLabel(string.format(CommonText[766],1),{size = FONT_SIZE_SMALL - 2, y = self.lotteryNormalBtn:getContentSize().height / 2 + 13})

		self.lotterySeniorBtn.need:setString(self.lotterySeniorBtn.cost2)
		self.lotterySeniorBtn:setLabel(string.format(CommonText[766],10),{size = FONT_SIZE_SMALL - 2, y = self.lotteryNormalBtn:getContentSize().height / 2 + 13})

	end
end

function ActivityM1A2View:awardInfo(tag, sender)
	ManagerSound.playNormalButtonSound()
	require_ex("app.dialog.ActivityM1A2AwardDialog").new(self.lotteryType):push()
end


function ActivityM1A2View:showFormulaView(container)
	local function chosenTank(event)
		container.showStatus = 2 -- 显示具体的某个用于生产的tank
		container.tankFormula = event.tankFormula
		self:showFormulaView(container)
	end

	local function showTanks()
		container.showStatus = 1 -- 显示所有tank
		self:showFormulaView(container)
	end

	local function gotoRefit(event)
		
		Loading.getInstance():show()

		local tankFormula = event.tankFormula
		local count = event.count

		ActivityCenterBO.doM1a2Refit(tankFormula.from,count,function()
				Loading.getInstance():unshow()
				self:showFormulaView(container)
			end)
	end

	container:removeAllChildren()

	if container.showStatus == 1 then
		local RefitM1A1TableView = require("app.scroll.RefitM1A1TableView")
		local view = RefitM1A1TableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4),self.m_activity.activityId):addTo(container)
		view:addEventListener("CHOSEN_M1A1_EVENT", chosenTank)
		view:reloadData()
	else
		local RefitM1A1View = require_ex("app.view.RefitM1A1View")
		local view = RefitM1A1View.new(container.tankFormula):addTo(container)
		view:addEventListener("REFIT_M1A1_RETURN_EVENT", showTanks)
		view:addEventListener("ARMY_M1A1_REFIT_EVENT", gotoRefit)
		view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	end

end

function ActivityM1A2View:lotteryHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	local cost
	if self.lotteryType == M1A2_LOTTERY_TYPE_NORMAL then
		--单抽
		if tag == 1 then
			if self.m_activityContent.hasFree then
				cost = 0
			else
				cost = sender.cost1
			end 
		else
		--十连
			cost = sender.cost1
		end
	elseif self.lotteryType == M1A2_LOTTERY_TYPE_SENIOR then
		--单抽
		cost = sender.cost2
	end

	--判断金币
	if cost > UserMO.getResource(ITEM_KIND_COIN) then
		require("app.dialog.CoinTipDialog").new():push()
		return 
	end

	function doLottery()
		Loading.getInstance():show()
		ActivityCenterBO.doM1a2(self.lotteryType,tag == 1,function(redata)
			Loading.getInstance():unshow()
			-- self.m_activityContent = redata
			local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
			self.m_activityContent = activityContent			

			self:updateLotteryBtn()
			end, cost == 0)
	end
	--二次消耗判断
	if cost > 0 then
		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[767],cost), function()
				doLottery()
				end):push()
		else
			doLottery()
		end
	else
		doLottery()
	end
end

function ActivityM1A2View:update(dt)
	if self.m_timeLab then
		local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
		if leftTime > 0 then
			self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
		else
			self.m_timeLab:setString(CommonText[852])
		end
	end
end

function ActivityM1A2View:onExit()
	ActivityM1A2View.super.onExit(self)

end

return ActivityM1A2View

