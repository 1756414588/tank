
-- 购买道具弹出框

local Dialog = require("app.dialog.Dialog")
local BagBuyDialog = class("BagBuyDialog", Dialog)

function BagBuyDialog:ctor(viewPos, propId, param)
	BagBuyDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})

	self.m_viewPos = viewPos
	self.m_propId = propId
	self.param = param
end

function BagBuyDialog:onEnter()
	BagBuyDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:showUI()
end

function BagBuyDialog:showUI()
	if self.m_numLabel then return end
	
	if self.param then
		self.m_propDB = UserMO.getResourceData(self.param.item[1], self.param.item[2])
	else
		self.m_propDB = PropMO.queryPropById(self.m_propId)
	end
	-- 名称
	local name = ui.newTTFLabel({text = self.param and self.m_propDB.name or PropMO.getPropName(self.m_propId), font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 60, color = COLOR[self.param and self.m_propDB.quality or self.m_propDB.color], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 100, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

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

    self.m_maxNum = math.floor(count / price)
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

	local fromPos = self:convertToNodeSpace(cc.p(self.m_viewPos.x, self.m_viewPos.y))
	local toPos = self:getBg():convertToWorldSpace(cc.p(84, self:getBg():getContentSize().height - 94))

	local kind,id,count = ITEM_KIND_PROP, self.m_propId
	if self.param then
		kind,id,count = self.param.item[1],self.param.item[2],self.param.item[3]
	end
	local itemView = UiUtil.createItemView(kind,id,{count = count}):addTo(self, 10)
	itemView:setPosition(fromPos.x, fromPos.y)

	itemView:runAction(transition.sequence({cc.DelayTime:create(0.1), cc.MoveTo:create(0.25, cc.p(toPos.x, toPos.y)),
		cc.CallFunc:create(function()
				local pos = self:getBg():convertToNodeSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))
				itemView:retain()
				itemView:setPosition(pos.x, pos.y)
				itemView:removeSelf()
				itemView:addTo(self:getBg())
				itemView:release()
			end)}))

	self:getBg():setCascadeOpacityEnabledRecursively(true)
	self:getBg():setOpacity(0)
	self:getBg():runAction(transition.sequence({cc.DelayTime:create(0.15), cc.FadeIn:create(0.1)}))
end

function BagBuyDialog:getPrice(num)
	if self.param then
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
			return self.param.price * num
		end
	elseif num and num > 0 then
		return self.m_propDB.price * self.m_settingNum
	else
		return self.m_propDB.price
	end
end

function BagBuyDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function BagBuyDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
end

function BagBuyDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.priceLabel:setString(UiUtil.strNumSimplify(self:getPrice(self.m_settingNum)))
	if self.param and self.param.nowtime then
		self.priceLabel:setString(self:getPrice(self.m_settingNum))
	end
end

function BagBuyDialog:onBuyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local count = UserMO.getResource(ITEM_KIND_COIN)
	local need = 0
	local name = self.param and self.m_propDB.name or PropMO.getPropName(self.m_propId)
	if self.param and self.param.nowtime then
		need = self:getPrice(self.m_settingNum)
	else
		need = (self.param and self.param.price or self.m_propDB.price) * self.m_settingNum
	end
	local function gotoBuy()
		if need > count or self.m_settingNum == 0 then -- 金币不足
			self:pop(function() require("app.dialog.CoinTipDialog").new():push() end)
			return
		end

		local function doneBuy()
			-- 成功购买
			Toast.show(CommonText[200])
			ManagerSound.playSound("shop_buy")
			self:pop()
		end
		if self.param then
			self.param.rhand(self.m_settingNum,doneBuy)
		else
			PropBO.asynBuyProp(doneBuy, self.m_propId, self.m_settingNum)
		end
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[1904], need, self.m_settingNum, name), function() gotoBuy() end, nil):push()
	else
		gotoBuy()
	end
end

return BagBuyDialog