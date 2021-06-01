--
-- Author: gf
-- Date: 2016-05-07 11:48:17
--新坦克拉霸


local PrizeCycleView = class("PrizeCycleView", CycleView)

function PrizeCycleView:ctor(size, direction, grid)
	PrizeCycleView.super.ctor(self, size, direction)

	self.m_grid = grid
	-- self.m_cellSize = cc.size(size.width, 120)

	if grid ~= 4 then
		self.m_cellSize = cc.size(size.width, 120)
	else
		self.m_cellSize = cc.size(200, size.height)
	end

	self.m_prizes = {1,2,3,4}

	local raffleData = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_TANKRAFFLE_NEW).data
	--测试数据
	-- local raffleData = {
	-- 	free = 0,
	-- 	lockId = 0,
	-- 	tankIds = {25,26,29,30}
	-- }

	gdump(raffleData.tankIds,"raffleData.tankIds==")

	self.m_tank = raffleData.tankIds

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
	if self.m_grid == 4 then
		local prize = self.m_tank[index]
		-- local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png", self.m_cellSize.width / 2, self.m_cellSize.height / 2):addTo(cell)
		-- itemBg:setScale(0.8)

		local itemView = display.newSprite("image/tank/tank_" .. prize .. ".png", self.m_cellSize.width / 2, self.m_cellSize.height / 2):addTo(cell)
		itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		-- local lab = ui.newTTFLabel({text = prize, font = G_FONT, size = FONT_SIZE_BIG, 
		-- 	x = self.m_cellSize.width / 2, y = self.m_cellSize.height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		-- lab:setAnchorPoint(cc.p(0, 0.5))
	else
		local prize = self.m_prizes[index]
		local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png", self.m_cellSize.width / 2, self.m_cellSize.height / 2):addTo(cell)
		itemBg:setScale(0.6)

		local itemView = display.newSprite(IMAGE_COMMON .. "raffle_" .. prize .. ".png", x, y):addTo(cell)
		itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	end
	return cell
end


-----------------------------------------------------------
--
-----------------------------------------------------------

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local ActivityNewRaffleView = class("ActivityNewRaffleView", UiNode)

function ActivityNewRaffleView:ctor(activity)
	ActivityNewRaffleView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_activity = activity
	-- gdump(self.m_mail, "ActivityNewRaffleView:ctor")
end

function ActivityNewRaffleView:onEnter()
	ActivityNewRaffleView.super.onEnter(self)
	self:hasCoinButton(true)
	
	self:setTitle(self.m_activity.name)

	self.m_startMove = {}
	self.m_moveOffset = {}
	self.m_desOffset = {}


	local raffleData = ActivityCenterMO.getActivityContentById(self.m_activity.activityId).data
	self.m_raffleData = raffleData

	--测试数据
	-- self.m_raffleData = {
	-- 	free = 0,
	-- 	lockId = 29,
	-- 	tankIds = {25,26,29,30}
	-- }
	self:setUI()

	self.m_updateHandler = Notify.register(LOCAL_ACTIVITY_NEWRAFFLE_UPDATE_EVENT, handler(self, self.updateLotteryBtn))

end

function ActivityNewRaffleView:setUI()
	-- 活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self:getBg())
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self:getBg():getContentSize().height - 130)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(self:getBg())
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab

	

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityNewRaffle):push()
		end):addTo(self:getBg())
	detailBtn:setPosition(self:getBg():getContentSize().width - 60, self:getBg():getContentSize().height - 150)


	--背景图
	local btm = display.newSprite(IMAGE_COMMON .. 'info_bg_rebate.jpg'):addTo(self:getBg())
	btm:setPosition(self:getBg():getContentSize().width / 2, bg:getPositionY() - btm:getContentSize().height / 2 - 50)
	

	local bg1 = display.newSprite(IMAGE_COMMON .. "info_bg_74.jpg"):addTo(btm)
	bg1:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height / 2)


	local raffBg = display.newSprite(IMAGE_COMMON .. "info_bg_raffle.jpg"):addTo(self:getBg())
	raffBg:setPosition(self:getBg():getContentSize().width / 2, btm:getPositionY() - btm:getContentSize().height / 2 - raffBg:getContentSize().height / 2)

	local bgPos = {
		raffBg:getContentSize().width / 2 - 200,
		raffBg:getContentSize().width / 2,
		raffBg:getContentSize().width / 2 + 200
	}
	for index=1,3 do
		local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(raffBg)
		itemBg:setScale(0.8)
		itemBg:setPosition(bgPos[index],raffBg:getContentSize().height / 2 + 20)
	end
	

	local arrow1 = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png", x, y):addTo(raffBg)
	arrow1:setPosition(210,120)

	local arrow2 = display.newSprite(IMAGE_COMMON .. "btn_40_normal.png", x, y):addTo(raffBg)
	arrow2:setPosition(405,120)
	arrow2:setScale(-1)

	local rect = cc.rect(0, 0, 410, 320)
    local node = display.newClippingRegionNode(rect):addTo(bg1, 4)
    node:setPosition(44, 90)
    self.m_prizeFrame = node

	--拉霸UI
	self.m_cycleViews = {}

    local pos = {62, 190, 320, 190}

    for index = 1, 4 do

	    local view
	    if index < 4 then
	    	view = PrizeCycleView.new(cc.size(110, 320), SCROLL_DIRECTION_VERTICAL, index):addTo(bg1, 4)
	    	view:setPosition(pos[index], 70)
	    else
	    	view = PrizeCycleView.new(cc.size(600, 150), SCROLL_DIRECTION_HORIZONTAL, index):addTo(raffBg)
	    	view:setAnchorPoint(cc.p(0.5,0.5))
	    	view:setPosition(raffBg:getContentSize().width / 2, raffBg:getContentSize().height / 2 + 20)
	    end
	    
	    if view then
		    view:reloadData()
		    if index == 4 then
		    	local initOffset = -200 * ActivityCenterBO.getNewRaffleTankLockIndex(self.m_raffleData)
	    		view:setContentOffset(cc.p(initOffset, 0))
	    	else
	    		view:setContentOffset(cc.p(0, 0))
		    end
			self.m_cycleViews[index] = view
		end
    end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(btm, 3)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(btm:getContentSize().width / 2, 370)

	local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(btm, 3)
	shade:setScaleY(-1)
	shade:setPreferredSize(cc.size(410, shade:getContentSize().height))
	shade:setPosition(btm:getContentSize().width / 2, 132)

	local lockIconL = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(raffBg)
	lockIconL:setPosition(raffBg:getContentSize().width / 2 - 200, raffBg:getContentSize().height / 2 + 20)
	self.m_lockIconL = lockIconL

	local lockIconR = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(raffBg)
	lockIconR:setPosition(raffBg:getContentSize().width / 2 + 200, raffBg:getContentSize().height / 2 + 20)
	self.m_lockIconR = lockIconR

	local checkBox = CheckBox.new(nil, nil, handler(self, self.onConditionCheckedChanged)):addTo(self:getBg())
	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
	color = COLOR[12]}):addTo(self:getBg())
	info:setAnchorPoint(cc.p(0,0.5))
	self.tenInfo = info
	checkBox:setPosition(60,raffBg:getPositionY() - 130)
	info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10,checkBox:getPositionY())
	info:setString(CommonText[935][1])
	self.tenCheckBox = checkBox



	local checkBox = CheckBox.new(nil, nil, handler(self, self.onLockCheckedChanged)):addTo(self:getBg())
	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
	color = COLOR[12]}):addTo(self:getBg())
	info:setAnchorPoint(cc.p(0,0.5))
	self.locakInfo = info
	checkBox:setPosition(220,raffBg:getPositionY() - 130)
	info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 10,checkBox:getPositionY())
	info:setString(CommonText[935][2])
	self.lockCheckBox = checkBox


	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local lotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.lotteryHandler)):addTo(self:getBg())
	lotteryBtn:setPosition(self:getBg():getContentSize().width - 120, raffBg:getPositionY() - raffBg:getContentSize().height / 2 - 40)
	

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

function ActivityNewRaffleView:updateLotteryBtn()
	
	if self.m_raffleData.free > 0 then
		self.tenCheckBox:setVisible(false)
		self.tenInfo:setVisible(false)
		self.lockCheckBox:setVisible(false)
		self.locakInfo:setVisible(false)
		self.lotteryBtn:setLabel(CommonText[792])
		self.lotteryBtn.icon:setVisible(false)
		self.lotteryBtn.need:setVisible(false)
		self.m_lockIconL:setVisible(false)
		self.m_lockIconR:setVisible(false)
	else
		self.tenCheckBox:setVisible(true)
		self.tenInfo:setVisible(true)
		self.lockCheckBox:setVisible(true)

		self.lockCheckBox:setChecked(self.m_raffleData.lockId > 0)
		self.m_lockIconL:setVisible(self.m_raffleData.lockId > 0)
		self.m_lockIconR:setVisible(self.m_raffleData.lockId > 0)

		self.locakInfo:setVisible(true)
		self.lotteryBtn.icon:setVisible(true)
		self.lotteryBtn.need:setVisible(true)
		self.lotteryBtn:setLabel(CommonText[791],{size = FONT_SIZE_SMALL - 2, y = self.lotteryBtn:getContentSize().height / 2 + 13})
		if self.tenCheckBox:isChecked() and self.lockCheckBox:isChecked() then
			self.lotteryBtn.need:setString(NEW_RAFFLE_LOCK_NEED_COIN_10)
		else
			if self.tenCheckBox:isChecked() then
				self.lotteryBtn.need:setString(NEW_RAFFLE_NEED_COIN_10)
			elseif self.lockCheckBox:isChecked() then
				self.lotteryBtn.need:setString(NEW_RAFFLE_LOCK_NEED_COIN)
			else
				self.lotteryBtn.need:setString(NEW_RAFFLE_NEED_COIN)
			end
		end
	end
end

function ActivityNewRaffleView:onConditionCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	self:updateLotteryBtn()
end

function ActivityNewRaffleView:onLockCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	local tankId
	if isChecked then
		tankId = ActivityCenterBO.getNewRaffleTankResultId(self.m_raffleData)
	else
		tankId = 0
	end
	gprint(tankId,"tankId====")
	Loading.getInstance():show()
	ActivityCenterBO.asynLockNewRaffle(function(result)
			Loading.getInstance():unshow()
			if result then
				self:updateLotteryBtn()
			end
		end,tankId)
end


local offsetX = 0

function ActivityNewRaffleView:lotteryHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local type --抽取方式 1 单抽 2十连
	local cost --抽取花费


	if self.tenCheckBox:isChecked() then
		type = 2
		if self.lockCheckBox:isChecked() then
			cost = NEW_RAFFLE_LOCK_NEED_COIN_10
		else
			cost = NEW_RAFFLE_NEED_COIN_10
		end
	else
		type = 1
		if self.lockCheckBox:isChecked() then
			cost = NEW_RAFFLE_LOCK_NEED_COIN
		else
			cost = NEW_RAFFLE_NEED_COIN
		end
	end
	--判断免费次数
	if type == 1 and self.m_raffleData.free > 0 then
		cost = 0
	end

	function doLottery()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActNewRaffle(function(statsAward)
			Loading.getInstance():unshow()
			self:updateLotteryBtn()

			for index = 1, #self.m_cycleViews do
				local view = self.m_cycleViews[index]
				if view then
					view:setTouchEnabled(false)

					local maxOffset = view:getMaxContentOffset()

					if index == 4 and self.m_raffleData.lockId == 0 then
						self.m_moveOffset[index] = cc.p(0, maxOffset.y)

						local loginIndex = ActivityCenterMO.newRaffleColors[index]
						local offsetX = 600 / 2 -  (loginIndex - 0.5) * 200
						if offsetX > 0 then offsetX = offsetX - maxOffset.x end

						self.m_desOffset[index] = cc.p(-maxOffset.x + offsetX,maxOffset.y)
						self.m_startMove[index] = true
					else
						self.m_moveOffset[index] = cc.p(maxOffset.x, 0)

						local loginIndex = ActivityCenterMO.newRaffleColors[index]
						local offsetY = 320 / 2 - (maxOffset.y - (loginIndex - 0.5) * 120)
						-- gprint("offsetY:", offsetY, "index:", index)
						if offsetY > 0 then offsetY = offsetY - maxOffset.y end

						self.m_desOffset[index] = cc.p(maxOffset.x, -maxOffset.y + offsetY)
						self.m_startMove[index] = true
					end
					
				end
			end

			sender:setEnabled(false)
			self.tenCheckBox:setEnabled(false)
			self.lockCheckBox:setEnabled(false)
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

local deltaOffset = {-3, -4.5, -8, -5}

function ActivityNewRaffleView:update(dt)

	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			if index == 4 and self.m_raffleData.lockId == 0 then
				self.m_moveOffset[index].x = self.m_moveOffset[index].x + deltaOffset[index]

				if self.m_moveOffset[index].x < self.m_desOffset[index].x then  -- 运动完了
					self.m_startMove[index] = false
				else
					local view = self.m_cycleViews[index]
					view:setContentOffset(self.m_moveOffset[index])
				end
			else
				self.m_moveOffset[index].y = self.m_moveOffset[index].y + deltaOffset[index]

				if self.m_moveOffset[index].y < self.m_desOffset[index].y then  -- 运动完了
					self.m_startMove[index] = false
				else
					local view = self.m_cycleViews[index]
					view:setContentOffset(self.m_moveOffset[index])
				end
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
			view:setTouchEnabled(true)
		end
		self.lotteryBtn:setEnabled(true)
		self.tenCheckBox:setEnabled(true)
		self.lockCheckBox:setEnabled(true)
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

function ActivityNewRaffleView:onExit()
	ActivityNewRaffleView.super.onExit(self)

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end




return ActivityNewRaffleView

