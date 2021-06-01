
require("app.text.DetailText")

local ScrollText = class("ScrollText", TableView)

function ScrollText:ctor(size, contont)
	ScrollText.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_contont = contont

	self.m_cellSize = cc.size(size.width-10, size.height)

	local height = 0
	for i = 1, #self.m_contont do
		local d = self.m_contont[i]
		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0))
		height = height + label:getHeight()
	end

	height = height + 10

	self.m_cellSize.height = math.max(size.height, height)
end

-- 获得view中总共有多少个cell
function ScrollText:numberOfCells()
	return 1
end

-- 索引为index的cell的大小，index从1开启
function ScrollText:cellSizeForIndex(index)
	return self.m_cellSize
end

-- cell:默认会创建一个空的node，node包含有_CELL_INDEX_的值。方法的返回的cellNode才是最终的cell
function ScrollText:createCellAtIndex(cell, index)
	local posY = self.m_cellSize.height
	for i = 1, #self.m_contont do
		local d = self.m_contont[i]
		local label = RichLabel.new(d, cc.size(self.m_cellSize.width, 0)):addTo(cell)
		label:setTouchEnabled(false)
		label:setPosition(5, posY)
		posY = posY - label:getHeight()
	end

	return cell
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

local VipPageView = class("VipPageView", function (size)
	local node = display.newNode()
	node:setContentSize(size)
	return node
end)

function VipPageView:ctor(size)
	self.m_cellSize = size
end

function VipPageView:reloadData()
	-- body
end

function VipPageView:setCurrentIndex( index )
	if index > VipMO.queryMaxVip() or index < 1 then return end
	self.m_currentIndex = index

	if self.m_last then
		local old = self.m_last
		self.m_last = nil
		old:stopAllActions()
		local sequence = transition.sequence({
		    CCFadeOut:create(0.3),
		    CCCallFunc:create(function()
		    	old:removeSelf()
		    end)
		})

		old:runAction(sequence)
	end

	local cell = display.newNode():addTo(self)
	cell:setCascadeOpacityEnabled(true)
	cell:setOpacity(0)
	cell:setVisible(false)
	self.m_last = cell
	cell:setContentSize(self.m_cellSize)
	self:createCellAtIndex(cell, self.m_currentIndex)

	local sequence = transition.sequence({
	    CCDelayTime:create(0.3),
	    CCCallFunc:create(function ()
	    	cell:setVisible(true)
	    end),

	    CCFadeIn:create(0.3)
	})

	cell:runAction(sequence)	
end

function VipPageView:getCurrentIndex()
	return self.m_currentIndex
end

function VipPageView:createCellAtIndex(cell, index)
	local labelColor = cc.c3b(0, 0, 0)

	local title = ui.newTTFLabel({text = "VIP" .. index .. CommonText[408], font = G_FONT, size = FONT_SIZE_HUGE, 
		x = self.m_cellSize.width / 2, y = self.m_cellSize.height - 40, 
		color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	local posY = self.m_cellSize.height - 60

	local data = DetailText.vip[index]

	if data then
		local label = ScrollText.new(cc.size(self.m_cellSize.width, self.m_cellSize.height - 60), data):addTo(cell)
		label:reloadData()
		-- label:setPosition(10,0)
	end

	return cell
end

-----------------------------------------------------------------
-----------------------------------------------------------------

local VipView = class("VipView", UiNode)

function VipView:ctor()
	VipView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function VipView:onEnter()
	VipView.super.onEnter(self)
	
	self:hasCoinButton(true)
	self:setTitle(CommonText[264])

	self:setUI()
end

function VipView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	local vip = UiUtil.createItemSprite(ITEM_KIND_VIP, UserMO.vip_):addTo(container)
	vip:setPosition(70, container:getContentSize().height - 220)

	local titleBar = display.newSprite(IMAGE_COMMON .. "bar_vip.jpg"):addTo(container)
	titleBar:setPosition(container:getContentSize().width / 2, container:getContentSize().height - titleBar:getContentSize().height / 2)

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(300, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(300 + 4, 26)}):addTo(container)
	bar:setPosition(container:getContentSize().width / 2 - 40, vip:getPositionY() - 20)

	local curVip = VipMO.queryVip(UserMO.vip_)
	
	if UserMO.vip_ >= VipMO.queryMaxVip() then -- 已经是最高VIP了
		bar:setPercent(1)
		bar:setLabel(UserMO.topup_ .. "/" .. curVip.topup)
	else
		local nxtVip = VipMO.queryVip(UserMO.vip_ + 1)

		bar:setPercent((UserMO.topup_ - curVip.topup) / (nxtVip.topup - curVip.topup))
		bar:setLabel(UserMO.topup_ .. "/" .. nxtVip.topup)

		-- 再充值
		local label = ui.newTTFLabel({text = CommonText[370][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = bar:getPositionY() + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		local label = ui.newTTFLabel({text = (nxtVip.topup - UserMO.topup_) .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		-- 可成为
		local label = ui.newTTFLabel({text = CommonText[370][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "VIP" .. (UserMO.vip_ + 1), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))
	end
	
	-- 充值
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onChargeCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 100, vip:getPositionY() - 8)
	btn:setLabel(CommonText[369], {x = 90})

	local sprite = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(btn)
	sprite:setPosition(50, btn:getContentSize().height / 2)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_53.jpg"):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 260 - bg:getContentSize().height / 2)

	local view = VipPageView.new(cc.size(360, 470)):addTo(container)
	view:setPosition(134, container:getContentSize().height - 780)
	view:reloadData()
	self.m_pageView = view

	local pageIndex = UserMO.vip_ + 1
	if pageIndex > VipMO.queryMaxVip() then pageIndex = VipMO.queryMaxVip() end
	view:setCurrentIndex(pageIndex)

	local normal = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png")
	normal:setScale(-1)
	local selected = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png")
	selected:setScale(-1)
	local lastBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLastCallback)):addTo(container)
	lastBtn:setPosition(50, container:getContentSize().height - 530)
	self.m_lastBtn = lastBtn
	local normal = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png")
	local selected = display.newSprite(IMAGE_COMMON .. "icon_arrow_right.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onNextCallback)):addTo(container)
	nxtBtn:setPosition(container:getContentSize().width - 50, container:getContentSize().height - 530)
	self.m_nxtBtn = nxtBtn
	--尊享VIP按钮
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	-- local vip6Btn = MenuButton.new(normal, selected, nil, handler(self, self.onVip6ServCallback)):addTo(self:getBg())
	-- vip6Btn:setLabel(CommonText[846],{color = COLOR[12]})
	-- vip6Btn:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 920)
	-- vip6Btn:setVisible(UserMO.vip_ >= PERSONAL_SERVICE_VIP)

	self:updateBtnState()
end

function VipView:onChargeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	-- UiDirector.popToUI(nil,require("app.view.RechargeView").new())
	UiDirector.popToUI(function() RechargeBO.openRechargeView() end)
	-- self:pop()
	-- require("app.view.RechargeView").new():push()
end

function VipView:onLastCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage - 1, true)

	self:updateBtnState()
end

function VipView:onNextCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local curPage = self.m_pageView:getCurrentIndex()
	self.m_pageView:setCurrentIndex(curPage + 1, true)

	self:updateBtnState()
end

function VipView:onVip6ServCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.VipServiceDialog").new():push()
end

function VipView:updateBtnState()
	local index = self.m_pageView:getCurrentIndex()
	if index == VipMO.queryMaxVip() then 
		self.m_nxtBtn:setVisible(false)
		self.m_lastBtn:setVisible(true)	
	elseif index == 1 then
		self.m_lastBtn:setVisible(false)
		self.m_nxtBtn:setVisible(true)
	else
		self.m_nxtBtn:setVisible(true)
		self.m_lastBtn:setVisible(true)		
	end
end

return VipView