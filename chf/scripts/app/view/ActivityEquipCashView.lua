--
-- Author: gf
-- Date: 2016-03-15 11:48:26
-- 限时兑换（装备）(军备图纸)

local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")

local ActivityEquipCashTableView = class("ActivityEquipCashTableView", TableView)

function ActivityEquipCashTableView:ctor(size,activityId)
	ActivityEquipCashTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 420)
	self.list = ActivityCenterMO.getActivityContentById(activityId).cash
	self.m_activityId = activityId
end

function ActivityEquipCashTableView:onEnter()
	ActivityEquipCashTableView.super.onEnter(self)
end

function ActivityEquipCashTableView:numberOfCells()
	return #self.list
end

function ActivityEquipCashTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityEquipCashTableView:createCellAtIndex(cell, index)
	ActivityEquipCashTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]
	-- gdump(data,"ActivityEquipCashTableView .. data")
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

	local title = ui.newTTFLabel({text = string.format(CommonText[874], index), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	--今日可兑换次数
	local count = ui.newTTFLabel({text = string.format(CommonText[875], data.state), font = G_FONT, size = FONT_SIZE_SMALL,
	 x = self.m_cellSize.width - 30, y = self.m_cellSize.height - 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(87,220,5)}):addTo(cell)
	count:setAnchorPoint(cc.p(1, 0.5))

	--配方列表
	-- gdump(data.atom,"ActivityEquipCashTableView .. data.atom")
	local canCash = true

	if #data.atom == 5 then
		for index=1,#data.atom do
			local prop = data.atom[index]
			local itemPic = UiUtil.createItemView(prop.type, prop.id,{count = prop.count}):addTo(cell)
			itemPic:setPosition(100 + (index - 1) * 110,320)
			UiUtil.createItemDetailButton(itemPic,cell,true)

			local myCount
			if prop.type == ITEM_KIND_EQUIP then
				myCount = #EquipMO.getFreeEquipsById(prop.id)
			elseif prop.type == ITEM_KIND_PART then
				myCount = #PartBO.getFreePartsById(prop.id)
			else
				myCount = UserMO.getResource(prop.type, prop.id)
			end

			local countLab = ui.newTTFLabel({text = myCount .. "/" .. prop.count, font = G_FONT, size = FONT_SIZE_SMALL,
			 align = ui.TEXT_ALIGN_CENTER, color = COLOR[3]}):addTo(cell)
			countLab:setAnchorPoint(cc.p(1, 0.5))
			countLab:setPosition(145 + (index - 1) * 110,355)
			if myCount < prop.count then
				countLab:setColor(COLOR[6])
				canCash = false
			end
		end
		local arrowPic = display.newSprite(IMAGE_COMMON .. "arrow_activityCash.png", x, y):addTo(cell)
		arrowPic:setPosition(320,237)
	elseif #data.atom == 3 then
		for index=1,#data.atom do
			local prop = data.atom[index]
			local itemPic = UiUtil.createItemView(prop.type, prop.id,{count = prop.count}):addTo(cell)
			itemPic:setPosition(100 + (index - 1) * 220,320)
			UiUtil.createItemDetailButton(itemPic,cell,true)
			local myCount
			if prop.type == ITEM_KIND_EQUIP then
				myCount = #EquipMO.getFreeEquipsById(prop.id)
			elseif prop.type == ITEM_KIND_PART then
				myCount = #PartBO.getFreePartsById(prop.id)
			else
				myCount = UserMO.getResource(prop.type, prop.id)
			end
			local countLab = ui.newTTFLabel({text = myCount .. "/" .. prop.count, font = G_FONT, size = FONT_SIZE_SMALL,
			 align = ui.TEXT_ALIGN_CENTER, color = COLOR[3]}):addTo(cell)
			countLab:setAnchorPoint(cc.p(1, 0.5))
			countLab:setPosition(145 + (index - 1) * 220,355)
			if myCount < prop.count then
				countLab:setColor(COLOR[6])
				canCash = false
			end
		end
		local arrowPic = display.newSprite(IMAGE_COMMON .. "arrow_activityCash1.png", x, y):addTo(cell)
		arrowPic:setPosition(320,237)
	end
	
	--合成目标
	local itemView = UiUtil.createItemView(data.award.type, data.award.id,{count = data.award.count}):addTo(cell)
	itemView:setPosition(320,150)
	UiUtil.createItemDetailButton(itemView,cell,true)

	--刷新按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local refreshBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.refreshHandler))
	cell:addButton(refreshBtn, self.m_cellSize.width / 2 - 150, 50)
	refreshBtn.cash = data
	if data.free > 0 then
		refreshBtn:setLabel(CommonText[876][1])
	else
		refreshBtn:setLabel(CommonText[876][2],{size = FONT_SIZE_SMALL - 2, y = refreshBtn:getContentSize().height / 2 + 13})
	end
	local icon1 = display.newSprite(IMAGE_COMMON .. "icon_coin.png", refreshBtn:getContentSize().width / 2 - 30,refreshBtn:getContentSize().height / 2 - 13):addTo(refreshBtn)
	local need1 = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt"}):addTo(refreshBtn)
	need1:setAnchorPoint(cc.p(0, 0.5))
	need1:setPosition(icon1:getPositionX() + icon1:getContentSize().width / 2 + 5,icon1:getPositionY() + 2)
	need1:setString(data.price)
	icon1:setVisible(data.free == 0)
	need1:setVisible(data.free == 0)
	refreshBtn.icon1 = icon1
	refreshBtn.need1 = need1
	self.refreshBtn = refreshBtn

	--兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local cashBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.cashHandler))
	cashBtn:setLabel(CommonText[877])
	cashBtn:setEnabled(canCash and data.state > 0)
	cashBtn.cash = data
	cell:addButton(cashBtn, self.m_cellSize.width / 2 + 150, 50)
	
	return cell
end

function ActivityEquipCashTableView:cashHandler(tag, sender)
	if self.m_activityId == ACTIVITY_ID_EXCHANGE_EQUIP then --装备兑换
		Loading.getInstance():show()
			ActivityCenterBO.asynDoEquipCash(function()
				Loading.getInstance():unshow()
				self:updateListHandler()
				end,sender.cash)
	elseif self.m_activityId == ACTIVITY_ID_EXCHANGE_PAPER then --图纸兑换
		Loading.getInstance():show()
			ActivityCenterBO.asynDoPaperCash(function()
				Loading.getInstance():unshow()
				self:updateListHandler()
				end,sender.cash)
	end
end

function ActivityEquipCashTableView:refreshHandler(tag, sender)
	local free = sender.cash.free
	local cost

	function doRefresh()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		--根据活动ID处理
		if self.m_activityId == ACTIVITY_ID_EXCHANGE_EQUIP then --装备兑换
			Loading.getInstance():show()
				ActivityCenterBO.asynRefshEquipCash(function()
					Loading.getInstance():unshow()
					self:updateListHandler()
					Toast.show(CommonText[879])
					end,sender.cash)
		elseif self.m_activityId == ACTIVITY_ID_EXCHANGE_PAPER then --图纸兑换
			Loading.getInstance():show()
				ActivityCenterBO.asynRefshPaperCash(function()
					Loading.getInstance():unshow()
					self:updateListHandler()
					Toast.show(CommonText[879])
					end,sender.cash)
		end
	end 

	if free > 0 then
		cost = 0
	else
		cost = sender.cash.price
	end
	
	if UserMO.consumeConfirm and cost > 0 then
		CoinConfirmDialog.new(string.format(CommonText[878],cost), function()
			doRefresh()
			end):push()
	else
		doRefresh()
	end
end

function ActivityEquipCashTableView:updateListHandler(event)
	local offset = self:getContentOffset()
	self.list = ActivityCenterMO.getActivityContentById(self.m_activityId).cash
   	self:reloadData()
   	self:setContentOffset(offset)
end

function ActivityEquipCashTableView:onExit()
	ActivityEquipCashTableView.super.onExit(self)
end




local ActivityEquipCashView = class("ActivityEquipCashView", UiNode)

function ActivityEquipCashView:ctor(activity)
	ActivityEquipCashView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityEquipCashView:onEnter()
	ActivityEquipCashView.super.onEnter(self)

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


function ActivityEquipCashView:showUI()
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_partResolve.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height)
	-- 活动时间

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(160, 50)
	self.m_timeLab = timeLab

	local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_PART_RESOLVE)
	self.m_activityContent = activityContent

	

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			if self.m_activity.activityId == ACTIVITY_ID_EXCHANGE_PAPER then
				DetailTextDialog.new(DetailText.activityMedalCash):push()
				return
			end
			DetailTextDialog.new(DetailText.activityEquipCash):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 30)

	

	local view = ActivityEquipCashTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 340),self.m_activity.activityId):addTo(self:getBg())
	view:setPosition(0, 30)
	view:reloadData()

end


function ActivityEquipCashView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
end


function ActivityEquipCashView:onExit()
	ActivityEquipCashView.super.onExit(self)

end





return ActivityEquipCashView

