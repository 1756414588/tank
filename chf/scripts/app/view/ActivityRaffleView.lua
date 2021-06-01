--
-- Author: gf
-- Date: 2015-12-12 16:03:38
-- 坦克拉霸

local PrizeCycleView = class("PrizeCycleView", CycleView)

function PrizeCycleView:ctor(size, grid)
	PrizeCycleView.super.ctor(self, size)

	self.m_grid = grid
	self.m_cellSize = cc.size(size.width, 120)
	self.m_prizes = {1,2,3,4}

	-- gprint("Grid:", self.m_grid)
	-- gdump(self.m_prizes, "PrizeCycleView")
end

-- function PrizeCycleView:onEnter()
-- end

function PrizeCycleView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PrizeCycleView:numberOfCells()
	return #self.m_prizes
end

function PrizeCycleView:createCellAtIndex(cell, index)
	local prize = self.m_prizes[index]

	local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png", self.m_cellSize.width / 2, self.m_cellSize.height / 2):addTo(cell)
	itemBg:setScale(0.6)
	local itemView = display.newSprite(IMAGE_COMMON .. "raffle_" .. prize .. ".png", x, y):addTo(cell)
	itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	return cell
end


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local ActivityRaffleView = class("ActivityRaffleView", UiNode)

function ActivityRaffleView:ctor(activity)
	ActivityRaffleView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_activity = activity
	-- gdump(self.m_mail, "ActivityRaffleView:ctor")
end

function ActivityRaffleView:onEnter()
	ActivityRaffleView.super.onEnter(self)
	self:hasCoinButton(true)
	
	self:setTitle(self.m_activity.name)

	armature_add(IMAGE_ANIMATION .. "effect/ui_item_light_orange.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_item_light_orange.plist", IMAGE_ANIMATION .. "effect/ui_item_light_orange.xml")

	self.m_startMove = {}
	self.m_moveOffset = {}
	self.m_desOffset = {}

	self:setUI()

end

function ActivityRaffleView:setUI()
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self:getBg():getContentSize().height - 130)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	--概率公示
	local chance = ActivityCenterMO.getProbabilityTextById(self.m_activity.activityId, self.m_activity.awardId)
	if chance then
		local sp = display.newSprite(IMAGE_COMMON .. "chance_btn.png")
		local chanceBtn = ScaleButton.new(sp, function ()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(chance.content):push()
		end):addTo(self:getBg())
		chanceBtn:setPosition(self:getBg():width() / 2 + 130, self:getBg():height() - 130)
		chanceBtn:setVisible(chance.open == 1)
	end

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab

	-- 活动说明
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, timeLab:getPositionY() - timeLab:getContentSize().height - 40)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local desc1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(510, 60)}):addTo(self:getBg())
	desc1:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 5)
	desc1:setAnchorPoint(cc.p(0, 1))
	desc1:setString(CommonText[788][1])

	local desc2 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL - 2,color = COLOR[11],
	 align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(510, 60)}):addTo(self:getBg())
	desc2:setPosition(40, desc1:getPositionY() - desc1:getContentSize().height / 2 - 5)
	desc2:setAnchorPoint(cc.p(0, 1))
	desc2:setString(CommonText[788][2])


	local normal = display.newSprite(IMAGE_COMMON .. "icon_specical_bag.png")
	local awardBtn = ScaleButton.new(normal, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.RaffleAwardDialog").new(self.m_activity.activityId):push()			
		end):addTo(self:getBg())
	awardBtn:setPosition(self:getBg():getContentSize().width - 70, self:getBg():getContentSize().height - 170)
	--奖励一览
	local btnLab = ui.newTTFLabel({text = CommonText[771], font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[2],align = ui.TEXT_ALIGN_CENTER, 
		x = awardBtn:getContentSize().width / 2, y = awardBtn:getContentSize().height}):addTo(awardBtn)
	btnLab:setAnchorPoint(cc.p(0.5,0.5))


	local checkBox = CheckBox.new(nil, nil, handler(self, self.onConditionCheckedChanged)):addTo(self:getBg())
	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
	color = COLOR[12]}):addTo(self:getBg())
	info:setAnchorPoint(cc.p(0,0.5))
	checkBox:setPosition(60,desc2:getPositionY() - 50)
	info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10,checkBox:getPositionY())
	info:setString(CommonText[790])
	self.checkBox = checkBox


	--背景图
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate.jpg'):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, desc2:getPositionY() - bg:getContentSize().height / 2 - 80)
	

	local bg1 = display.newSprite(IMAGE_COMMON .. "info_bg_74.jpg"):addTo(bg)
	bg1:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

	local rect = cc.rect(0, 0, 410, 320)
    local node = display.newClippingRegionNode(rect):addTo(bg1, 4)
    node:setPosition(44, 90)
    self.m_prizeFrame = node

	--拉霸UI
	self.m_cycleViews = {}

    local pos = {62, 190, 320}

    for index = 1, 3 do

	    local view = PrizeCycleView.new(cc.size(110, 320), index):addTo(bg1, 4)
	    view:setPosition(pos[index], 70)
	    view:reloadData()
	    view:setContentOffset(cc.p(0, 0))
	    local light = armature_create("ui_item_light_orange", pos[index] + 55, 160 + 90 - 20,nil):addTo(bg1 ,6)
	    light:setScale(0.8)
	    light:getAnimation():playWithIndex(0)
	    light:setVisible(false)
	    view.light = light
		self.m_cycleViews[index] = view
    end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(bg, 3)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(bg:getContentSize().width / 2, 370)

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(bg, 3)
	shade:setScaleY(-1)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(bg:getContentSize().width / 2, 132)


	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(self:getBg())
	lotteryBtn:setPosition(self:getBg():getContentSize().width / 2, bg:getPositionY() - bg:getContentSize().height / 2 - 40)
	

	local icon = display.newSprite(IMAGE_COMMON .. "icon_coin.png", lotteryBtn:getContentSize().width / 2 - 30,lotteryBtn:getContentSize().height / 2 - 13):addTo(lotteryBtn)
	local need = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(lotteryBtn)
	need:setAnchorPoint(cc.p(0, 0.5))
	need:setPosition(icon:getPositionX() + icon:getContentSize().width / 2 + 5,icon:getPositionY() + 2)
	lotteryBtn.icon = icon
	lotteryBtn.need = need
	self.lotteryBtn = lotteryBtn

	--按钮
	self:updateLotteryBtn()
end

function ActivityRaffleView:updateLotteryBtn()
	local data = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data

	if data.free > 0 and not self.checkBox:isChecked() then
		self.lotteryBtn:setLabel(CommonText[792])
		self.lotteryBtn.icon:setVisible(false)
		self.lotteryBtn.need:setVisible(false)
	else
		self.lotteryBtn:setLabel(CommonText[791],{size = FONT_SIZE_SMALL - 2, y = self.lotteryBtn:getContentSize().height / 2 + 13})
		self.lotteryBtn.icon:setVisible(true)
		self.lotteryBtn.need:setVisible(true)
		if self.checkBox:isChecked() then
			self.lotteryBtn.need:setString(RAFFLE_NEED_COIN_10)
		else
			self.lotteryBtn.need:setString(RAFFLE_NEED_COIN)
		end
	end
end

function ActivityRaffleView:onConditionCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	self:updateLotteryBtn()
end

function ActivityRaffleView:lotteryHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local type --抽取方式 1 单抽 2十连
	local cost --抽取花费
	if self.checkBox:isChecked() then
		type = 2
		cost = RAFFLE_NEED_COIN_10
	else
		type = 1
		cost = RAFFLE_NEED_COIN
	end
	--判断免费次数
	local data = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	if type == 1 and data.free > 0 then
		cost = 0
	end

	function doLottery()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActTankRaffle(function(statsAward)
			Loading.getInstance():unshow()
			self:updateLotteryBtn()

			-- for index = 1, #self.m_cycleViews do
			for index = #self.m_cycleViews, 1 , -1  do
				local view = self.m_cycleViews[index]
				view:setTouchEnabled(false)
				view.light:setVisible(false)

				local maxOffset = view:getMaxContentOffset()

				self.m_moveOffset[index] = cc.p(maxOffset.x, 0)

				local loginIndex = ActivityCenterMO.raffleColors[index]
				local offsetY = 320 / 2 - (maxOffset.y - (loginIndex.value - 0.5) * 120)
				-- gprint("offsetY:", offsetY, "index:", index)
				if offsetY > 0 then offsetY = offsetY - maxOffset.y end

				self.m_desOffset[index] = cc.p(maxOffset.x, -maxOffset.y + offsetY)

				self.m_startMove[index] = true
			end

			sender:setEnabled(false)
			self.checkBox:setEnabled(false)
			self.m_statsAward = statsAward
			
			end, self.m_activity.activityId,type)
	end

	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[793],cost), function()
			doLottery()
			end):push()
	else
		doLottery()
	end
end

local deltaOffset = {-3, -4.5, -8}

function ActivityRaffleView:update(dt)
	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			self.m_moveOffset[index].y = self.m_moveOffset[index].y + deltaOffset[index]

			if self.m_moveOffset[index].y < self.m_desOffset[index].y then  -- 运动完了
				self.m_startMove[index] = false
			else
				local view = self.m_cycleViews[index]
				view:setContentOffset(self.m_moveOffset[index])
			end
		end
	end

	local open = true
	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			open = false
			break
		end
	end
	if open and not self.lotteryBtn:isEnabled() then
		for index = 1, #self.m_cycleViews do
			local view = self.m_cycleViews[index]
			local loginIndex = ActivityCenterMO.raffleColors[index]
			if loginIndex.def then
				view.light:setVisible(true)
			end
			view:setTouchEnabled(true)
		end
		self.lotteryBtn:setEnabled(true)
		self.checkBox:setEnabled(true)
		gprint("======显示奖励======")
		if self.m_statsAward then
			UiUtil.showAwards(self.m_statsAward)
		end
	end

	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityRaffleView:onExit()
	ActivityRaffleView.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "effect/ui_item_light_orange.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_item_light_orange.plist", IMAGE_ANIMATION .. "effect/ui_item_light_orange.xml")
end




return ActivityRaffleView

