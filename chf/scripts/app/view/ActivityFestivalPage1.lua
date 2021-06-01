--
-- Author: xiaoxing
-- Date: 2017-02-05 10:19:15
--
local ContentTableView = class("ContentTableView",TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 240)
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
end

function ContentTableView:numberOfCells()
	return #self.data
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell)
	tableBg:setPreferredSize(cc.size(self.m_cellSize.width - 10, self.m_cellSize.height))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local t = UiUtil.label(index == 1 and CommonText[906][2] or CommonText[908][1]):addTo(tableBg):pos(self.m_cellSize.width / 2,tableBg:height() - 25)
	local ab = ActivityCenterMO.getActHilarity(index + 1)
	local item = json.decode(ab.awards)
	local x,y,ex = 90,tableBg:height()/2 + 20, 105
	for k,v in ipairs(item) do
		local tx,ty = x + (k-1)*ex,y
		local t = UiUtil.createItemView(v[1], v[2], {count = v[3]}):addTo(cell):pos(tx,ty):scale(0.9)
		UiUtil.createItemDetailButton(t,cell,true)
	end
	local btn = UiUtil.button("btn_11_normal.png","btn_11_selected.png","btn_9_disabled.png",handler(self, self.getAward),CommonText[672][1],1)
	cell:addButton(btn,self.m_cellSize.width / 2 + 190,42)
	local data = self.data[index]
	btn.keyId = data.keyId
	btn.state = data.state
	btn.index = index
	if index == 1 then
		if data.state == -1 then
			btn:setLabel(CommonText[672][2])
			btn:setEnabled(false)
		elseif data.state == 0 then
			btn:setLabel(CommonText[484])
		end
	elseif index == 2 then
		local num = data.value
		local count = math.floor(num/2000)
		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(350, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(350 + 4, 26)}):addTo(cell)
		bar:setPosition(220, 42)
		bar:setLabel(num .. "/" .. 2000)
		bar:setPercent(num / 2000)
		t = UiUtil.label(CommonText[908][2]):addTo(cell):align(display.LEFT_CENTER, 420, 83)
		UiUtil.label(count,nil,COLOR[count < 1 and 6 or 2]):rightTo(t)
		if count <= 0 then
			btn:setEnabled(false)
		end
	end
	return cell
end

function ContentTableView:getAward(tag,sender)
	ManagerSound.playNormalButtonSound()
	if sender.state == 0 then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end
	ActivityCenterBO.receiveActHilarityPray(sender.keyId,function(data)
			local data = ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].payData
			if sender.index == 1 then
				self.data[sender.index].state = -1
				data.status[sender.index + 1] = -1
			elseif sender.index == 2 then
				self.data[sender.index].value = self.data[sender.index].value - 2000
				data.value[sender.index + 1] = data.value[sender.index + 1] - 2000
			end
			self:reloadData()
		end)
end

function ContentTableView:updateUI(data)
	self.data = data
	self:reloadData()
end
--------------------------------------------
local ActivityFestivalPage1 = class("ActivityFestivalPage1",function ()
	return display.newNode()
end)

function ActivityFestivalPage1:ctor(width,height,activity)
	self.activity = activity
	self:size(width,height)

	--活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(self)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(20, height - 30)
	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(self)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab

	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityCelebrate2):push()
		end):addTo(self)
	detailBtn:setPosition(width - 50,height - 50)

	bg = display.newSprite(IMAGE_COMMON..'info_bg_12.png'):alignTo(bg, -80, 1)
	local title = ui.newTTFLabel({text = CommonText[906][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local ab = ActivityCenterMO.getActHilarity(1)
	local prop = json.decode(ab.awards)[1]
	prop = PropMO.queryPropById(prop[2])
	prop = json.decode(prop.effectValue)[1][1]
	UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0, {pendant = prop}):addTo(self):pos(80,bg:y() - 80):scale(0.6)
	local t = UiUtil.label(CommonText[907][1]):addTo(self):align(display.LEFT_CENTER, 150, bg:y() - 40)
	t = UiUtil.label(CommonText[907][2]):addTo(self):alignTo(t, -75, 1)
	self.hasLabel = UiUtil.label("0/4"):rightTo(t)

	self.getBtn = UiUtil.button("btn_19_normal.png","btn_19_selected.png","btn_9_disabled.png",handler(self, self.getAward),CommonText[870][2])
		:addTo(self):pos(500,t:y() + 20)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self)
	bg:setPreferredSize(cc.size(width - 30, height - 280))
	bg:setPosition(width / 2, bg:height() / 2 + 25)
	ActivityCenterBO.getActHilarityPray(function()
		self.data = ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL].payData
		self.getBtn.keyId = self.data.keyId[1]
		self:checkBtn()
		local view = ContentTableView.new(cc.size(bg:width() - 20, bg:height() - 10)):addTo(bg):pos(10,5)
		view:updateUI({{state = self.data.status[2], keyId = self.data.keyId[2]},{state = self.data.status[3], value = self.data.value[3], keyId = self.data.keyId[3]}})
		self.view = view
	end)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityFestivalPage1:checkBtn()
	local state = self.data.status[1]
	self.getBtn:setEnabled(true)
	self.getBtn.state = state
	self.getBtn.keyId = self.data.keyId[1]
	if state == 1 then
		self.getBtn:setLabel(CommonText[672][1])
	elseif state == -1 then
		self.getBtn:setEnabled(false)
		self.getBtn:setLabel(CommonText[672][2])
	else
		self.getBtn:setLabel(CommonText[484])
	end
	self.hasLabel:setString(self.data.value[1] .."/4")
end

function ActivityFestivalPage1:getAward(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.state == 0 then
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
		return
	end
	ActivityCenterBO.receiveActHilarityPray(sender.keyId,function()
			self.data.status[1] = -1
			self:checkBtn()
		end)
end

function ActivityFestivalPage1:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

return ActivityFestivalPage1