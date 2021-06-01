local Dialog = require("app.dialog.Dialog")
local BuyAnythingDialog = class("BuyAnythingDialog", Dialog)

--自定义批量购买框架
-- param = {}
-- param.kind 				商品类型
-- param.id 				商品ID
-- param.name 				商品名称
-- param.quality 			商品名称品质(颜色) [默认 1]
-- param.desc 				商品描述
-- param.coinIcon 			货币ICON地址（绝对地址）[可选]
-- param.max 				商品购买最大数量 (默认 100)
-- param.myCoinNumber		当前拥有的货币数量
-- param.price 				货币购买方式 （string - 购买规则）（int - 单价）
-- param.nowtime 			货币启买次数 （必须 param.price为string - 购买规则 生效）
-- param.okCallback 		购买成功回调
-- param.unEnoughCallback	商品购买货币不足回调
function BuyAnythingDialog:ctor(param)
	BuyAnythingDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})
	self.param = param
end

function BuyAnythingDialog:onEnter()
	BuyAnythingDialog.super.onEnter(self)

	if not self.param.quality then self.param.quality = 1 end
	if not self.param.max then self.param.max = 100 end

	self:setOutOfBgClose(true)

	-- 名称
	local name = ui.newTTFLabel({text = self.param.name , font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 60, color = COLOR[self.param.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.param.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 100, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 售价
	local label = ui.newTTFLabel({text = CommonText[1096] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 280, y = self:getBg():getContentSize().height - 175, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 自定义货币
	local view = nil
	if self.param.coinIcon then
		view = display.newSprite(self.param.coinIcon):addTo(self:getBg())
		view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())
	else
		view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self:getBg())
		view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())
	end

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

    self.m_maxNum = math.floor(self.param.myCoinNumber / price)
    if self.param and self.param.max then
    	self.m_maxNum = math.min(self.m_maxNum, self.param.max)
    end
    self.m_minNum = 1
    if self.m_maxNum == 0 then self.m_minNum = 0 end
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum

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


	local kind,id = self.param.kind, self.param.id

	local itemView = UiUtil.createItemView(kind,id):addTo(self:getBg(), 10)
	itemView:setPosition(84, self:getBg():getContentSize().height - 94)


	self:getBg():setCascadeOpacityEnabledRecursively(true)
	self:getBg():setOpacity(0)
	self:getBg():runAction(transition.sequence({cc.DelayTime:create(0.15), cc.FadeIn:create(0.1)}))
end

function BuyAnythingDialog:getPrice(num)
	num = num or 1
	if type(self.param.price) == "string" then
		local total = 0
		local sec = json.decode(self.param.price)
		for i=self.param.nowtime + 1,self.param.nowtime + num do
			local t = sec[1][2]
			for k,v in ipairs(sec) do
				if i > v[1] and i <= sec[k+1][1] then
					t = sec[k+1][2]
					break
				end
			end
			total = total + t
		end
		return total
	else
		if num and num == 0 then num = 1 end
		return self.param.price * num
	end
end

function BuyAnythingDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function BuyAnythingDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function BuyAnythingDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	-- if self.param and self.param.nowtime then
		self.priceLabel:setString(self:getPrice(self.m_settingNum))
	-- end
end

function BuyAnythingDialog:onBuyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local count = self.param.myCoinNumber
	local need = 0
	if self.param and self.param.nowtime then
		need = self:getPrice(self.m_settingNum)
	else
		need = self.param.price * self.m_settingNum
	end
	if need > count or self.m_settingNum == 0 then -- 金币不足
		self:pop(function() 
			if param.unEnoughCallback then
				param.unEnoughCallback()
			else
				Toast.show("货币不足")
			end 
		end)
		return
	end

	local function doneBuy()
		-- 成功购买
		Toast.show(CommonText[200])
		ManagerSound.playSound("shop_buy")
		self:pop()
	end

	if self.param then
		self.param.okCallback(self.m_settingNum, doneBuy)
	end
end

function BuyAnythingDialog:onExit()
	BuyAnythingDialog.super.onExit(self)
end

return BuyAnythingDialog