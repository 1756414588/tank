--
-- Author: Xiaohang
-- Date: 2016-09-14 14:15:50
--

local PrizeCycleView = class("PrizeCycleView", CycleView)

function PrizeCycleView:ctor(size, grid)
	PrizeCycleView.super.ctor(self, size)

	self.m_cellSize = cc.size(size.width, 120)
	self.m_prizes = {}
	local list = ActivityCenterMO.getAllEqudate()
	for k,v in ipairs(list) do
		if v.type == grid then
			table.insert(self.m_prizes, v.equateId)
		end
	end
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

	local item = json.decode(ActivityCenterMO.getEquateById(prize).showList)
	local itemBg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png", self.m_cellSize.width / 2, self.m_cellSize.height / 2):addTo(cell)
	itemBg:setScale(0.6)
	local itemView = UiUtil.createItemView(item[1], item[2]):addTo(cell):scale(0.8)
	itemView:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	if itemView.bg_ then itemView.bg_:hide() end
	if itemView.armature_ then itemView.armature_:hide() end
	return cell
end


local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
local ActivityTankCarnival = class("ActivityTankCarnival", UiNode)

function ActivityTankCarnival:ctor(activity)
	ActivityTankCarnival.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_activity = activity
end

function ActivityTankCarnival:onEnter()
	ActivityTankCarnival.super.onEnter(self)
	self:hasCoinButton(true)
	
	self:setTitle(self.m_activity.name)

	self.m_startMove = {}
	self.m_moveOffset = {}
	self.m_desOffset = {}

	self:setUI()

end

function ActivityTankCarnival:setUI()
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
		chanceBtn:setPosition(self:getBg():width() - 200, self:getBg():height() - 130)
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
			require("app.dialog.TankCarnivalReward").new():push()			
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
	info:setString(CommonText[20129])
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
	    local view = PrizeCycleView.new(cc.size(110, 360), index):addTo(bg1, 4)
	    view:setPosition(pos[index], 70)
	    view:reloadData()
	    view:setContentOffset(cc.p(0, 0))
		self.m_cycleViews[index] = view
    end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	--亮点
	local x,y,ex = 118,bg1:height()-40,130
	local tags = {5,4,6}
	local dots = {}
	for i=0,2 do
		local t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,tags[i+1]):pos(x+i*ex,y)
		UiUtil.label(tags[i+1],28):addTo(t):center()
		table.insert(dots,t)
		t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,tags[i+1]):pos(x+i*ex,55)
		UiUtil.label(tags[i+1],28):addTo(t):center()
		table.insert(dots,t)
	end

	local temp = {{7,8},{8,7}}
	for k,v in ipairs(temp) do
		local t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,v[1]):pos(10,k == 1 and bg1:height()-40 or 55)
		UiUtil.label(v[1],28):addTo(t):center()
		table.insert(dots,t)
		t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,v[2]):pos(bg1:width() - t:x(),t:y())
		UiUtil.label(v[2],28):addTo(t):center()
		table.insert(dots,t)
	end

	x,y,ex = 10,120,122
	tags = {2,1,3}
	for i=0,2 do
		local t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,tags[i+1]):pos(x,y+ex*i)
		UiUtil.label(tags[i+1],28):addTo(t):center()
		table.insert(dots,t)
		t = display.newSprite(IMAGE_COMMON.."dot_gray.png")
			:addTo(bg1,5,tags[i+1]):pos(bg1:width() - x,y+ex*i)
		UiUtil.label(tags[i+1],28):addTo(t):center()
		table.insert(dots,t)
	end

	self.dots = dots
	-- local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(bg, 3)
	-- shade:setPreferredSize(cc.size(410, shade:getContentSize().height/2))
	-- shade:setPosition(bg:getContentSize().width / 2, 370 + shade:height()/2)
	-- shade:setScaleY(0.5)

	-- local shade = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_75.png"):addTo(bg, 3)
	-- shade:setScaleY(-1)
	-- shade:setPreferredSize(cc.size(410, shade:getContentSize().height/2))
	-- shade:setPosition(bg:getContentSize().width / 2, 132 - shade:height()/2)
	-- shade:setScaleY(0.5)

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

	self:checkState()
	--按钮
	self:updateLotteryBtn()
end

function ActivityTankCarnival:checkState()
	for k,v in ipairs(self.dots) do
		local yes = 1
		if self.checkBox:isChecked() then yes = nil end
		if yes then
			if v:getTag() == yes then 
				v:setTexture(CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON .."dot_yellow.png"))
			else
				v:setTexture(CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON .."dot_gray.png"))
			end
		else
			v:setTexture(CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON .."dot_yellow.png"))
		end
	end
end

function ActivityTankCarnival:updateLotteryBtn()
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
			self.lotteryBtn.need:setString(CARNIVAL_NEED_COIN_ALL)
		else
			self.lotteryBtn.need:setString(CARNIVAL_NEED_COIN)
		end
	end
	self.checkBox:setEnabled(data.free <= 0)
end

function ActivityTankCarnival:onConditionCheckedChanged(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	self:updateLotteryBtn()
	self:checkState()
end

function ActivityTankCarnival:lotteryHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local type --抽取方式 1 单抽 2十连
	local cost --抽取花费
	local all = 0
	if self.checkBox:isChecked() then
		type = 2
		cost = CARNIVAL_NEED_COIN_ALL
		all = 1
	else
		type = 1
		cost = CARNIVAL_NEED_COIN
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
		ActivityCenterBO.asynDoActTankCarnival(self.m_activity.activityId,all,function(ids,statsAward)
			Loading.getInstance():unshow()
			self:updateLotteryBtn()
			for index = 1, #self.m_cycleViews do
				local view = self.m_cycleViews[index]
				view:setTouchEnabled(false)
				local maxOffset = view:getMaxContentOffset()

				self.m_moveOffset[index] = cc.p(maxOffset.x, 0)

				local loginIndex = 1
				for k,v in ipairs(view.m_prizes) do
					if v == ids[index] and k < #view.m_prizes then
						loginIndex = k + 1
					end
				end
				-- local loginIndex = ActivityCenterMO.raffleColors[index]
				local offsetY = 320 / 2 - (maxOffset.y - (loginIndex - 0.5) * 120)
				-- gprint("offsetY:", offsetY, "index:", index)
				if offsetY > 0 then offsetY = offsetY - maxOffset.y end

				self.m_desOffset[index] = cc.p(maxOffset.x, -maxOffset.y + offsetY)

				self.m_startMove[index] = true
			end

			sender:setEnabled(false)
			self.checkBox:setEnabled(false)
			local t = display.newNode():size(display.width, display.height)
			self.lock = TouchButton.new(t, nil, nil, nil, function()
					for index = 1, #self.m_cycleViews do
						if self.m_startMove[index] then
							local view = self.m_cycleViews[index]
							view:setContentOffset(self.m_desOffset[index])
							self.m_startMove[index] = false
						end
					end
				end):addTo(display.getRunningScene(),1000000):pos(display.width/2,display.height/2)
			self.m_statsAward = statsAward
		end)
	end

	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[793],cost), function()
			doLottery()
			end):push()
	else
		doLottery()
	end
end

local deltaOffset = {-9.5, -13.5, -18}

function ActivityTankCarnival:update(dt)
	for index = 1, #self.m_cycleViews do
		if self.m_startMove[index] then
			self.m_moveOffset[index].y = self.m_moveOffset[index].y + deltaOffset[index]

			if self.m_moveOffset[index].y < self.m_desOffset[index].y then  -- 运动完了
				local view = self.m_cycleViews[index]
				view:setContentOffset(self.m_desOffset[index])
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
			view:setTouchEnabled(true)
		end
		self.lotteryBtn:setEnabled(true)
		self.checkBox:setEnabled(true)
		self.lock:removeSelf()
		self.lock = nil
		gprint("======显示奖励======")
		if self.m_statsAward then
			require("app.dialog.TankCarnivalAward").new(self.m_statsAward):push()
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

function ActivityTankCarnival:onExit()
	ActivityTankCarnival.super.onExit(self)
end

return ActivityTankCarnival

