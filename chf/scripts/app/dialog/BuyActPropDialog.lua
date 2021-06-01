--
-- Author: Gss
-- Date: 2018-05-22 11:26:37
--
local Dialog = require("app.dialog.Dialog")
local BuyActPropDialog = class("BuyActPropDialog", Dialog)

function BuyActPropDialog:ctor(propId, rhand)
	BuyActPropDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})

	self.m_propId = propId
	self.rhand = rhand
end

function BuyActPropDialog:onEnter()
	BuyActPropDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:showUI()
end

function BuyActPropDialog:showUI()
	if self.m_numLabel then return end
	local data = UserMO.getResourceData(ITEM_KIND_CHAR, self.m_propId)
	self.m_data = data

	-- 名称
	local name = ui.newTTFLabel({text = data.name , font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 60, color = COLOR[data.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = data.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 80, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(350, 0)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 1))

	-- 售价
	local label = ui.newTTFLabel({text = CommonText[198] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 280, y = self:getBg():getContentSize().height - 175, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self:getBg())
	view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())

	local price = self:getPrice()
	local t = ui.newBMFontLabel({text = UiUtil.strNumSimplify(price), font = "fnt/num_2.fnt", x = view:getPositionX() + view:getContentSize().width / 2, y = view:getPositionY()}):addTo(self:getBg())
	t:setAnchorPoint(cc.p(0, 0.5))
	self.priceLabel = t

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_23.png"):addTo(self:getBg())
	line:setPreferredSize(cc.size(440, line:getContentSize().height))
	line:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 200)

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(64, 160 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width - 64, reduceBtn:getPositionY())

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = self:getBg():getContentSize().width / 2 - 50, y = 220, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local count = UserMO.getResource(ITEM_KIND_COIN)

    self.m_maxNum = PROP_BUY_MAX_NUM
    self.m_minNum = 1
	self.m_settingNum = self.m_maxNum

	local barHeight = 40
	local barWidth = 266
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 160)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

	-- 购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBuyCallback)):addTo(self:getBg())
	btn:setPosition(self:getBg():getContentSize().width / 2, 80)
	btn:setLabel(CommonText[119])

	local itemView = UiUtil.createItemView(ITEM_KIND_CHAR, self.m_propId):addTo(self:getBg(), 10)
	itemView:setAnchorPoint(cc.p(0,1))
	itemView:setPosition(30, self:getBg():getContentSize().height - 40)
end

function BuyActPropDialog:getPrice()
	if not self.m_settingNum then
		return self.m_data.price
	end
	return self.m_settingNum * self.m_data.price
end

function BuyActPropDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function BuyActPropDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function BuyActPropDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function BuyActPropDialog:onBuyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function gotoBuy()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		local need = self:getPrice()

		if need > count then -- 金币不足
			self:pop(function() require("app.dialog.CoinTipDialog").new():push() end)
			return
		end

		local function doneBuy()
			-- 成功购买
			Toast.show(CommonText[200])
			ManagerSound.playSound("shop_buy")
			self:pop()
		end
		ActivityCenterBO.buyActProp(self.m_propId,self.m_settingNum,function (data)
			if self.rhand then self.rhand(data) end
			doneBuy()
		end)
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1904], self:getPrice(self.m_settingNum), self.m_settingNum, self.m_data.name), function() gotoBuy() end, nil):push()
	else
		gotoBuy()
	end
end

return BuyActPropDialog