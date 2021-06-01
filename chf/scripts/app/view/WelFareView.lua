--
-- Author: Gss
-- Date: 2018-07-25 11:15:21
-- 每日/周福利
-- 

local WelFareTableView = class("WelFareTableView", TableView)

function WelFareTableView:ctor(size,data,kind)
	WelFareTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_data = data
	self.m_info = ActivityMO.getWelFareDataByType(kind)
	self.m_kind = kind
	self.m_cellSize = cc.size(size.width, 232)
end

function WelFareTableView:numberOfCells()
	return #self.m_data
end

function WelFareTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function WelFareTableView:createCellAtIndex(cell, index)
	WelFareTableView.super.createCellAtIndex(self, cell, index)
	local item = self.m_data[index]
	local info = self.m_info[index]

	local bg = display.newSprite(IMAGE_COMMON.."cell_bg_1.png"):addTo(cell)
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg)
	titleBg:setPosition(bg:width() / 2, bg:height() - titleBg:height() / 2)
	local title = UiUtil.label(item.name):addTo(titleBg):center()

	local awards = json.decode(item.content)
	for idx = 1 , #awards do
		local award = awards[idx]
		local kind = award[1]
		local id = award[2]
		local count = award[3]
		local item = UiUtil.createItemView(kind, id, {count = count}):addTo(bg)
		item:setScale(0.9)
		item:setPosition(item:width()+ (idx - 1) * (bg:width() / 3), titleBg:y() - 70)
		UiUtil.createItemDetailButton(item)

		local resData = UserMO.getResourceData(kind, id)
		local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = item:getPositionX(), y = item:y() - 60, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	end

	--每日限购X次
	local limitBg = display.newSprite(IMAGE_COMMON.."bg_title1.png"):addTo(bg)
	limitBg:setPosition(limitBg:width() / 2, limitBg:height() / 2 + 10)
	local limit = UiUtil.label(string.format(CommonText[1826], item.count)):addTo(limitBg)
	if self.m_kind == 2 then
		limit:setString(string.format(CommonText[1835], item.count))
	end
	limit:setAnchorPoint(cc.p(0,0.5))
	limit:setPosition(10,limitBg:height() / 2)

	local left = UiUtil.label("("):rightTo(limit)
	local now = UiUtil.label(info.v2,nil,COLOR[2]):rightTo(left)
	local total = UiUtil.label("/" .. item.count):rightTo(now)
	local right = UiUtil.label(")"):rightTo(total)

	local price = UiUtil.label(string.format(CommonText[1827],item.orginPrice)):rightTo(limitBg,40)
	local tag = display.newSprite(IMAGE_COMMON .. "red_line.png"):addTo(price):center()

	local disCount = UiUtil.label(string.format(CommonText[1828],item.discount),nil,COLOR[2]):rightTo(price,30)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_61_selected.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_61_normal.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBtnCallback)):addTo(bg)
	btn:setPosition(bg:width() - btn:width() / 2, disCount:y())
	btn.id = item.id
	btn.price = item.price
	btn.total = item.count
	btn.now = info.v2

	local icon = display.newSprite(IMAGE_COMMON.."icon_coin.png"):addTo(btn)
	icon:setPosition(icon:width(), btn:height() / 2)

	local buyPrice = UiUtil.label(item.price,nil,COLOR[12]):rightTo(icon,10)

	return cell
end

function WelFareTableView:onBtnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local goodId = sender.id
	local take = sender.price
	local now = sender.now
	local total = sender.total
	if now >= total then Toast.show(CommonText[1829]) return end

	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < take then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		ActivityBO.buyWelFare(function (data)
			self.m_info = ActivityMO.getWelFareDataByType(self.m_kind)
			self:reloadData()
		end,goodId)
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1757], take), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

-------------------------------------------------------------------
-------------------------------------------------------------------

local WelFareView = class("WelFareView", UiNode)

function WelFareView:ctor()
	WelFareView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	
end

function WelFareView:onEnter()
	WelFareView.super.onEnter(self)
	self:setTitle(CommonText[1830])
	local function createDelegate(container, index)
		self.m_timeLab = nil
		if index == 1 then
			Loading.getInstance():show()
			ActivityCenterBO.asynGetActEDayPay(function()
				Loading.getInstance():unshow()
					self:showDayPay(container)
				end)
		elseif index == 2 then
			ActivityBO.getWelFare(function ()
				self:showDayWelFare(container)
			end)
		elseif index == 3 then
			ActivityBO.getWelFare(function ()
				self:showWeekWelFare(container)
			end)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = CommonText[1831]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView
end

function WelFareView:showDayPay(container)
	local tips = UiUtil.label(CommonText[839],nil,COLOR[2]):addTo(container)
	tips:setPosition(container:width() / 2, container:height() - 100)
	
	local awards = {
		{ITEM_KIND_PROP,ActivityCenterMO.dayPayData.goldBoxId,1},
		{ITEM_KIND_PROP,ActivityCenterMO.dayPayData.propBoxId,1}
	}

	for index = 1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award[1], award[2]):addTo(container)
		itemView:setPosition(210 + (index - 1) % 2 * 220 ,container:height() - 200 - 120 * math.floor((index - 1) / 2))
		
		UiUtil.createItemDetailButton(itemView)
		local name = ui.newTTFLabel({text = UserMO.getResourceData(award[1], award[2]).name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, 
			y = -20, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1]}):addTo(itemView)
			name:setAnchorPoint(cc.p(0.5, 0.5))
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, handler(self,self.rechargeHandler)):addTo(container)
	rechargeBtn:setPosition(container:width() / 2,tips:y() - 300)
	self.reBtn = rechargeBtn

	local got = UiUtil.label(CommonText[842]):addTo(container):alignTo(rechargeBtn, 50, 1)
	self.gotLab = got

	if ActivityCenterMO.dayPayData.state == 0 then
		rechargeBtn:setLabel(CommonText[10004])
		self.gotLab:setVisible(false)
	elseif ActivityCenterMO.dayPayData.state == 1 then
		rechargeBtn:setLabel(CommonText[694][2])
		self.gotLab:setVisible(false)
	elseif ActivityCenterMO.dayPayData.state == 2 then
		rechargeBtn:setVisible(false)
		self.gotLab:setVisible(true)
	end
end

function WelFareView:rechargeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	if ActivityCenterMO.dayPayData.state == 0 then
		self:pop(function() RechargeBO.openRechargeView() end)
	elseif ActivityCenterMO.dayPayData.state == 1 then
		Loading.getInstance():show()
		ActivityCenterBO.asynDoActEDayPay(function()
			Loading.getInstance():unshow()
				self.reBtn:setVisible(false)
				self.gotLab:setVisible(true)
			end)
	end
end

function WelFareView:showDayWelFare(container,param)
	local kind = 1
	local data = ActivityMO.getWelFareByType(kind)
	if not data then return end
	local view = WelFareTableView.new(cc.size(container:width(), container:height()),data,kind):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function WelFareView:showWeekWelFare(container,param)
	local kind = 2
	local data = ActivityMO.getWelFareByType(kind)
	if not data then return end
	local view = WelFareTableView.new(cc.size(container:width(), container:height()),data,kind):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function WelFareView:onExit()
	WelFareView.super.onExit(self)

end

return WelFareView