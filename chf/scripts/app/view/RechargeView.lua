--
-- Author: gf
-- Date: 2015-11-04 11:31:21
--
local ItemView = class("ItemView", TableView)

function ItemView:ctor(size)
	ItemView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(150, 108)
end

function ItemView:createCellAtIndex(cell, index)
	ItemView.super.createCellAtIndex(self, cell, index)
	local prop = self.props[index]
	local itemView = UiUtil.createItemView(prop[1], prop[2], {count = prop[3]})
		:addTo(cell):pos(self.m_cellSize.width/2,self.m_cellSize.height/2+20)
	UiUtil.createItemDetailButton(itemView, cell, true)
	local propDB = UserMO.getResourceData(prop[1], prop[2])
	local name = ui.newTTFLabel({text = prop[1] == ITEM_KIND_COIN and prop[2] or propDB.name, font = G_FONT, size = FONT_SIZE_SMALL - 2, 
		x = itemView:getPositionX(), y = itemView:getPositionY() - 60, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	return cell
end

function ItemView:numberOfCells()
	return #self.props
end

function ItemView:cellSizeForIndex(index)
	return self.m_cellSize
end
--------------------------------------------

local RechargeView = class("RechargeView", UiNode)

function RechargeView:ctor(viewFor)
	RechargeView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor
end

function RechargeView:onEnter()
	RechargeView.super.onEnter(self)

	--拇指裸包不能打开充值界面
	if GameConfig.environment == "zty_nake_client" then
		self:pop()
		return
	end
	
	self:hasCoinButton(true)
	self:setTitle(CommonText[731])

	self:setUI()

	self.m_updateHandler = Notify.register(LOCAL_RECHARGE_UPDATE_EVENT, handler(self, self.onRechargeUpdate))
end

function RechargeView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
	self.container = container

	local titleBar = display.newSprite(IMAGE_COMMON .. "bar_recharge.jpg"):addTo(container)
		titleBar:setPosition(container:getContentSize().width / 2, container:getContentSize().height - titleBar:getContentSize().height / 2)

	--文字
	local lab1 = ui.newTTFLabel({text = CommonText[736][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 50, y = 125, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBar)
	lab1:setAnchorPoint(cc.p(0, 0.5))

	local lab2 = ui.newTTFLabel({text = CommonText[736][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = lab1:getPositionX() + lab1:getContentSize().width, y = 125, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBar)
	lab2:setAnchorPoint(cc.p(0, 0.5))

	local lab3 = ui.newTTFLabel({text = CommonText[736][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 50, y = 95, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBar)
	lab3:setAnchorPoint(cc.p(0, 0.5))

	local lab4 = ui.newTTFLabel({text = CommonText[736][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = lab3:getPositionX() + lab3:getContentSize().width, y = 95, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBar)
	lab4:setAnchorPoint(cc.p(0, 0.5))

	local vip = UiUtil.createItemSprite(ITEM_KIND_VIP, UserMO.vip_):addTo(container)
	vip:setPosition(70, container:getContentSize().height - 160)
	self.vipIcon = vip

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(300, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(300 + 4, 26)}):addTo(container)
	bar:setPosition(container:getContentSize().width / 2 - 40, vip:getPositionY() - 5)
	self.topupBar = bar

	local curVip = VipMO.queryVip(UserMO.vip_)

	if UserMO.vip_ >= VipMO.queryMaxVip() then -- 已经是最高VIP了
		bar:setPercent(1)
		bar:setLabel(UserMO.topup_ .. "/" .. curVip.topup)
	else
		local nxtVip = VipMO.queryVip(UserMO.vip_ + 1)
		bar:setPercent((UserMO.topup_ - curVip.topup) / (nxtVip.topup - curVip.topup))
		bar:setLabel(UserMO.topup_ .. "/" .. nxtVip.topup)
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
    normal:setFlipX(true)
    local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
    selected:setFlipX(true)
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onVipCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width - 100, container:getContentSize().height - 165)
	btn:setLabel(CommonText[264])

	self:showFirstUI()
	self:showRechargeUI()
end

--首充礼包
function RechargeView:showFirstUI()
	if self.firstBg then self:getBg():removeChild(self.firstBg, true) end
	--判断是否已经首充，已首充则不显示
	if UserMO.topup_ > 0 then return end

	local firstBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	firstBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, 180))
	firstBg:setCapInsets(cc.rect(130, 40, 1, 1))
	firstBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 420)
	self.firstBg = firstBg

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		firstBg:getContentSize().width / 2, firstBg:getContentSize().height):addTo(firstBg)

	local firstLab = ui.newTTFLabel({text = CommonText[737][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	-- --奖励内容
	local awardDB = json.decode(ActivityMO.queryActivityAwardsById(FIRST_RECHARGE_ACTIVITY_ID).awardList)
	table.insert(awardDB,{ITEM_KIND_COIN,CommonText[462]})

	local view = ItemView.new(cc.size(586, 150))
		:addTo(firstBg):pos(6,26)
	view.props = awardDB
	view:reloadData()
end

--充值项目
function RechargeView:showRechargeUI()
	if self.rechargeBg then self:getBg():removeChild(self.rechargeBg, true) end
	local rechargeBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self:getBg())
	rechargeBg:setCapInsets(cc.rect(130, 40, 1, 1))
	self.rechargeBg = rechargeBg
	-- UserMO.topup_ = 50
	--判断是否有首充礼包
	local height = 0
	if UserMO.topup_ > 0 then
		height = self:getBg():getContentSize().height - 350
		rechargeBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 330 - height / 2)
	else
		height = self:getBg():getContentSize().height - 550
		rechargeBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 520 - height / 2)
	end
	rechargeBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, height))
	
	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		rechargeBg:getContentSize().width / 2, rechargeBg:getContentSize().height):addTo(rechargeBg,5)

	local firstLab = ui.newTTFLabel({text = CommonText[737][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)

	--列表
	local RechargeTableView = require("app.scroll.RechargeTableView")
	local view = RechargeTableView.new(cc.size(rechargeBg:getContentSize().width, rechargeBg:getContentSize().height - 30), self.m_viewFor):addTo(rechargeBg,4)
	view:setPosition(0, 23)
	view:reloadData()
end

function RechargeView:onVipCallback()
	ManagerSound.playNormalButtonSound()

	UiDirector.popToUI(nil,require("app.view.VipView").new())
	-- self:pop()
	-- require("app.view.VipView").new():push()
end

function RechargeView:onRechargeUpdate()
	if self.vipIcon then 
		self.container:removeChild(self.vipIcon)
	end
	local vip = UiUtil.createItemSprite(ITEM_KIND_VIP, UserMO.vip_):addTo(self.container)
	vip:setPosition(70, self.container:getContentSize().height - 160)
	self.vipIcon = vip

	local curVip = VipMO.queryVip(UserMO.vip_)
	if UserMO.vip_ >= VipMO.queryMaxVip() then -- 已经是最高VIP了
		self.topupBar:setPercent(1)
		self.topupBar:setLabel(UserMO.topup_ .. "/" .. curVip.topup)
	else
		local nxtVip = VipMO.queryVip(UserMO.vip_ + 1)
		self.topupBar:setPercent((UserMO.topup_ - curVip.topup) / (nxtVip.topup - curVip.topup))
		self.topupBar:setLabel(UserMO.topup_ .. "/" .. nxtVip.topup)
	end
	self:showFirstUI()
	self:showRechargeUI()
end

function RechargeView:onExit()
	RechargeView.super.onExit(self)
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end


return RechargeView