--
-- Author: Gss
-- Date: 2018-04-16 14:48:20
--
--碎片兑换活动 

--碎片兑换商店
local ActivityFragExcTableView = class("ActivityFragExcTableView", TableView)

function ActivityFragExcTableView:ctor(size,rhand,data)
	ActivityFragExcTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.rhand = rhand
	self.m_data = ActivityCenterMO.festivelInfo_

	local iconInfo, excInfo = ActivityCenterMO:getFestivalData(data)
	self.m_iconInfo = iconInfo
	self.m_goods = excInfo
end

function ActivityFragExcTableView:onEnter()
	ActivityFragExcTableView.super.onEnter(self)
	self:reloadData()
end

function ActivityFragExcTableView:numberOfCells()
	return #self.m_goods
end

function ActivityFragExcTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityFragExcTableView:createCellAtIndex(cell, index)
	ActivityFragExcTableView.super.createCellAtIndex(self, cell, index)
	local good = self.m_goods[index]
	local data = clone(self.m_data)
	table.remove(data.limitCount,1)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local item = json.decode(good.reward)[1]

	local view = UiUtil.createItemView(item[1], item[2], {count = item[3]}):addTo(cell):pos(100, self.m_cellSize.height / 2)
	UiUtil.createItemDetailButton(view, cell, true)
	local pb = UserMO.getResourceData(item[1], item[2])
	-- 名称
	local name = ui.newTTFLabel({text = pb.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[pb.quality]}):addTo(cell)
	local descStr = pb.desc or ""
	local desc = ui.newTTFLabel({text = descStr, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	--兑换限制
	if good.personNumber > 0 then
		local count = ui.newTTFLabel({text = "(" .. data.limitCount[index] .. "/" .. good.personNumber .. ")", font = G_FONT, size = FONT_SIZE_SMALL,
		 color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell):rightTo(name)
		count:setAnchorPoint(cc.p(0, 0.5))
		if data.limitCount[index] < good.personNumber then
			count:setColor(COLOR[1])
		else
			count:setColor(COLOR[6])
		end
	end

	--价格
	local dollar = display.newSprite(IMAGE_COMMON..self.m_iconInfo.icon..".png"):addTo(bg)
	dollar:setScale(0.7)
	dollar:setPosition(bg:width() - 130, bg:height() - dollar:height() / 2 - 5)

	local costNum = json.decode(good.cost)[3]
	local cost = UiUtil.label(costNum):addTo(bg):rightTo(dollar)
	local own = UserMO.getResource(json.decode(good.cost)[1],json.decode(good.cost)[2])
	-- 兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))
	btn:setLabel(CommonText[589])
	btn.goodsId = good.id
	btn.good = good
	btn.times = data.limitCount[index]
	btn.view = view
	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
	if good.personNumber > 0 then
		btn:setEnabled(data.limitCount[index] < good.personNumber and own >= costNum)
	else
		btn:setEnabled(own >= costNum)
	end

  	return cell
end

function ActivityFragExcTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local itemView = sender.view
	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))

	local function onExcBack(data)
		local item = PbProtocol.decodeArray(data.actProp)
		for k,v in ipairs(item) do
			ActivityCenterBO.prop_[v.id] = v
		end

		self.m_data.limitCount = data.limitCount
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
		if self.rhand then self.rhand() end
	end

	local data = sender.good
	data.times = sender.times

	local limit = data.personNumber - data.times --可兑换次数

	if limit == 1 then
		ActivityCenterBO.DoFragExchange(onExcBack,sender.goodsId,1)
	else
		local PropExcDialog = require("app.dialog.PropExcDialog")--批量兑换
		PropExcDialog.new(data, onExcBack, worldPoint, self.m_iconInfo.icon):push()
	end
end

function ActivityFragExcTableView:onExit()
	ActivityFragExcTableView.super.onExit(self)
end


-------------------------------------------------------------------------------------------------------------------
--碎片兑换活动
-------------------------------------------------------------------------------------------------------------------
local ActivityFragExcView = class("ActivityFragExcView", UiNode)

function ActivityFragExcView:ctor(activity)
	ActivityFragExcView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityFragExcView:onEnter()
	ActivityFragExcView.super.onEnter(self)
	self:setTitle(self.m_activity.name)

	local activityInfo = ActivityCenterMO:getFestivalInfo(self.m_activity.awardId)
	
	local titleInfo = {}
	local saleInfo = {}
	for k,v in pairs(activityInfo) do
		if v.identfy == 1 then
			titleInfo = v
		elseif v.identfy == 2 then
			saleInfo = v
		end
	end
	self.m_titleInfo = titleInfo
	self.m_saleInfo = saleInfo
	self.m_activityInfo = activityInfo

	local title = json.decode(titleInfo.desc)

	local function createDelegate(container, index)
		if index == 1 then
			if not self.m_data then self:pop() return end
			self:showFragment(container)
		elseif index == 2 then 
			if not self.m_data then self:pop() return end
			self:showExchange(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = title

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	ActivityCenterBO.GetFragExcInfo(function(data)
		self.m_data = data
		pageView:setPageIndex(1)
	end)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end

function ActivityFragExcView:showFragment(container)
	local activityInfo = self.m_titleInfo
	local descArr = json.decode(activityInfo.desc2)
	--活动说明
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(10, container:getContentSize().height - 30)
	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local height = 100
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	btm:setPreferredSize(cc.size(container:width() - 20, height))
	btm:setPosition(container:width() / 2, container:height() - bg:height() - 10)
	btm:setAnchorPoint(cc.p(0.5,1))

	local posY = container:getContentSize().height - 70
	local tHeight = 0
	for index=1,#descArr do
		local desc = UiUtil.label(descArr[index],nil,COLOR[11],cc.size(btm:width() - 20,0), ui.TEXT_ALIGN_LEFT):addTo(container)
		desc:setAnchorPoint(cc.p(0,1))
		desc:setPosition(20,posY)
		posY = posY - desc:height()
		tHeight = tHeight + desc:height()
		if tHeight > height then
			btm:setPreferredSize(cc.size(container:width() - 20, tHeight + 30))
		end
	end

	--下面的BG
	local dwonBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	dwonBg:setPreferredSize(cc.size(container:width() - 20, container:height() - btm:height() - bg:height() - 70))
	dwonBg:setPosition(container:width() / 2, btm:y() - btm:height() - 20)
	dwonBg:setAnchorPoint(cc.p(0.5,1))

	--登录有礼
	local giftBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(dwonBg)
	giftBg:setAnchorPoint(cc.p(0, 0.5))
	giftBg:setPosition(10, dwonBg:getContentSize().height - 30)
	local giftLab = ui.newTTFLabel({text = CommonText[5045][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = giftBg:getContentSize().height / 2}):addTo(giftBg)
	local giftTip = UiUtil.label(CommonText[5044][1],FONT_SIZE_SMALL):addTo(dwonBg)
	giftTip:setPosition(20,giftBg:y() - giftBg:height() + 10)
	giftTip:setAnchorPoint(cc.p(0,0.5))

	local awardList = json.decode(activityInfo.reward)
	for idx=1,#awardList do
		local itemView = UiUtil.createItemView(awardList[idx][1], awardList[idx][2], {count = awardList[idx][3]}):addTo(dwonBg)
		itemView:setPosition(10 + itemView:getContentSize().width / 2 + (idx - 1) * 100,giftTip:y() - itemView:height() / 2)
		itemView:setScale(0.7)
		UiUtil.createItemDetailButton(itemView)

		local propDB = UserMO.getResourceData(awardList[idx][1], awardList[idx][2])
		local name = ui.newTTFLabel({text = propDB.name2, font = G_FONT, size = 18, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(dwonBg)
		name:setPosition(itemView:x(), itemView:y() - itemView:height() / 2)
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local awardBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onRewardHandler)):addTo(dwonBg)
	awardBtn:setPosition(dwonBg:width() - awardBtn:width() / 2 - 10, giftTip:y() - 50)
	if self.m_data.loginRewardState == 0 then
		awardBtn:setLabel(CommonText[5046][1])
	else
		awardBtn:setLabel(CommonText[672][2])
	end
	awardBtn:setEnabled(self.m_data.loginRewardState == 0)
	self.awardBtn = awardBtn

	local buyList = json.decode(self.m_saleInfo.reward)
	--攻打关卡
	local propInfo = UserMO.getResourceData(buyList[1][1], buyList[1][2]) --节日碎片
	local attBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(dwonBg)
	attBg:setAnchorPoint(cc.p(0, 0.5))
	attBg:setPosition(10, giftTip:y() - 150)
	local attLab = ui.newTTFLabel({text = CommonText[5045][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = attBg:getContentSize().height / 2}):addTo(attBg)
	local attTip = UiUtil.label(string.format(CommonText[5044][2],propInfo.name),FONT_SIZE_SMALL):addTo(dwonBg)
	attTip:setPosition(20,attBg:y() - attBg:height() + 10)
	attTip:setAnchorPoint(cc.p(0,0.5))

	local item = UiUtil.createItemView(ITEM_KIND_CHAR,23):addTo(dwonBg)
	item:setPosition(10 + item:getContentSize().width / 2,attTip:y() - item:height() / 2)
	item:setScale(0.7)
	UiUtil.createItemDetailButton(item)
	local itemName = ui.newTTFLabel({text = propInfo.name2, font = G_FONT, size = 18, color = COLOR[propInfo.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(dwonBg)
	itemName:setPosition(item:x(), item:y() - item:height() / 2)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local goBtn = MenuButton.new(normal, selected, disabled, handler(self, self.goCollect)):addTo(dwonBg)
	goBtn:setPosition(dwonBg:width() - goBtn:width() / 2 - 10, giftTip:y() - 50 - 190)
	goBtn:setLabel(CommonText[5046][2])

	--碎片售卖
	local saleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(dwonBg)
	saleBg:setAnchorPoint(cc.p(0, 0.5))
	saleBg:setAnchorPoint(cc.p(0, 0.5))
	saleBg:setPosition(10, attTip:y() - 150)
	local saleLab = ui.newTTFLabel({text = CommonText[5045][3], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = saleBg:getContentSize().height / 2}):addTo(saleBg)
	local saleTip = UiUtil.label(string.format(CommonText[5044][3],propInfo.name),FONT_SIZE_SMALL):addTo(dwonBg)
	saleTip:setPosition(20,saleBg:y() - saleBg:height() + 10)
	saleTip:setAnchorPoint(cc.p(0,0.5))

	--购买次数限制
	if self.m_saleInfo.personNumber > 0 then
		local buy = UiUtil.label("(次数"):addTo(dwonBg):rightTo(saleTip)
		local now = UiUtil.label(self.m_data.limitCount[1],nil,COLOR[2]):addTo(dwonBg):rightTo(buy)
		self.m_now = now
		local limit = UiUtil.label("/"..self.m_saleInfo.personNumber..")"):addTo(dwonBg):rightTo(now)
		self.m_limit = limit
	end

	-- for idx=1,#awardList do
	local itemBuy = UiUtil.createItemView(buyList[1][1], buyList[1][2], {count = buyList[1][3]}):addTo(dwonBg)
	itemBuy:setPosition(10 + itemBuy:getContentSize().width / 2 + (1 - 1) * 100,saleTip:y() - itemBuy:height() / 2)
	itemBuy:setScale(0.7)
	UiUtil.createItemDetailButton(itemBuy)

	local propDB = UserMO.getResourceData(buyList[1][1], buyList[1][2])
	local name = ui.newTTFLabel({text = propDB.name2, font = G_FONT, size = 18, color = COLOR[propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(dwonBg)
	name:setPosition(itemBuy:x(), itemBuy:y() - itemBuy:height() / 2)
	-- end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local buyBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onBuyCallback)):addTo(dwonBg)
	buyBtn:setPosition(dwonBg:width() - buyBtn:width() / 2 - 10, giftTip:y() - 50 - 2 * 190)
	buyBtn:setLabel(CommonText[5046][3])
	buyBtn.id = self.m_saleInfo.id
	buyBtn.view = itemBuy
	if self.m_saleInfo.personNumber > 0 then
		buyBtn:setEnabled(self.m_data.limitCount[1] < self.m_saleInfo.personNumber)
	end
	self.buyBtn = buyBtn

	local cost = json.decode(self.m_saleInfo.cost)
	local coin = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(dwonBg)
	coin:setPosition(buyBtn:x() - 30, buyBtn:y() + 50)
	local price = UiUtil.label(cost[3]):rightTo(coin,10)

	local warning = UiUtil.label(CommonText[5049],nil,COLOR[6]):addTo(container)
	warning:setPosition(40,10)
	warning:setAnchorPoint(cc.p(0,0.5))
end

function ActivityFragExcView:onRewardHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.GetLoginRewards(function (data)
		-- self.m_data.itemCount = data.itemCount
		self.m_data.loginRewardState = data.loginRewardState
		self.awardBtn:setEnabled(data.loginRewardState == 0)
		self.awardBtn:setLabel(data.loginRewardState == 0 or CommonText[5046][1] and CommonText[672][2])
	end)
end

function ActivityFragExcView:goCollect(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.CombatSectionView").new():push()
end

function ActivityFragExcView:onBuyCallback(tag,sender)
	ManagerSound.playNormalButtonSound()
	local itemView = sender.view
	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))

	local cost = json.decode(self.m_saleInfo.cost)
	local function doneCallback(data)
		if self.m_saleInfo.personNumber > 0 then
			if data.limitCount[1] >= self.m_saleInfo.personNumber then
				data.limitCount[1] = self.m_saleInfo.personNumber
				self.buyBtn:setEnabled(false)
			end
			self.m_now:setString(data.limitCount[1])
			self.m_limit:setPosition(self.m_now:x() + self.m_now:width(), self.m_now:y())
		end
		self.m_data.limitCount = data.limitCount
	end

	local coinResData = UserMO.getResourceData(cost[1],cost[2])

	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < cost[3] then
			Toast.show(coinResData.name .. CommonText[223])
			return
		end

		self.m_saleInfo.times = self.m_data.limitCount[1]

		local PropExcDialog = require("app.dialog.PropExcDialog")--批量购买
		PropExcDialog.new(self.m_saleInfo, doneCallback, worldPoint):push()
	end

	gotoBuy()
end

function ActivityFragExcView:showExchange(container)
	local prop = json.decode(self.m_saleInfo.reward)
	local propInfo = UserMO.getResourceData(prop[1][1], prop[1][2]) --节日碎片prop
	local count = UserMO.getResource(prop[1][1],prop[1][2]) --碎片数量
	--我的碎片
	local myToken = ui.newTTFLabel({text = string.format(CommonText[5047],propInfo.name2), font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	myToken:setPosition(10, container:height() - 30)
	myToken:setAnchorPoint(cc.p(0,0.5))

	local festival = display.newSprite(IMAGE_COMMON..self.m_titleInfo.icon..".png"):addTo(container):rightTo(myToken)

	local itemNum = UiUtil.label(count,nil,COLOR[2]):addTo(container):rightTo(festival)
	self.itemNum = itemNum
	--兑换列表
	local view = ActivityFragExcTableView.new(cc.size(container:width(), container:height() - 80),function ()
		local countNum = UserMO.getResource(prop[1][1],prop[1][2]) --碎片数量
		self.itemNum:setString(countNum)
	end,self.m_activityInfo):addTo(container)
	view:setPosition(0,20)
end

return ActivityFragExcView