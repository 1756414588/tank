--
-- Author: Gss
-- Date: 2018-10-09 11:54:14
--
--红色方案商店批量兑换

local Dialog = require("app.dialog.Dialog")
local RedPlanExchangeDialog = class("RedPlanExchangeDialog", Dialog)

function RedPlanExchangeDialog:ctor(data, useCallback,viewPos,activityId)
	RedPlanExchangeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 450)})

	self.m_viewPos = viewPos
	self.m_data = data
	self.m_useCallback = useCallback
	self.m_propDB = nil
end

function RedPlanExchangeDialog:onEnter()
	RedPlanExchangeDialog.super.onEnter(self)
	self:setTitle(CommonText[5048][2])
	self:setOutOfBgClose(true)
	self.cost = 0
	self:showOtherUI()
end

function RedPlanExchangeDialog:showOtherUI()
	if self.m_numLabel then return end
	local activityContent = ActivityCenterMO.getActivityContentById(self.activityId)

	local item  		--兑换物拼
	local costNum 		--消耗数量
	local own 			--拥有的可消耗道具数量
	item = json.decode(self.m_data.award)
	item.type = item[1]
	item.id = item[2]
	item.count = item [3]
	self.m_propDB = UserMO.getResourceData(item[1], item[2], item[3])
	costNum = self.m_data.price
	own = UserMO.getResource(ITEM_KIND_PROP,640)--物资

	if item[1] == ITEM_KIND_MEDAL_CHIP then --如果是勋章碎片。特殊判断
		local partDB = MedalMO.queryById(self.m_propDB.id)
		self.m_propDB.desc = string.format(CommonText[20172], partDB.chipCount, partDB.medalName)
	end
	self.cost = costNum

	local name = ui.newTTFLabel({text = self.m_propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 40, color = COLOR[self.m_propDB.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 1))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = self:getBg():getContentSize().height - 60, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(370, 80)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 1))

	-- 售价
	local name = ""
	local data = UserMO.getResourceData(ITEM_KIND_PROP,640)
	name = data.name

	local label = ui.newTTFLabel({text = string.format(CommonText[1811],name), font = G_FONT, size = FONT_SIZE_SMALL, x = 280, y = self:getBg():getContentSize().height - 175, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	local t = ui.newBMFontLabel({text = UiUtil.strNumSimplify(costNum), font = "fnt/num_2.fnt"}):rightTo(label)
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
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2 - 50, y = 220, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local max --最大可兑换量
	if table.isexist(self.m_data,"max") then --如果有购买限制
		max = math.min(math.floor(own / costNum), self.m_data.max)
	else
		max = math.floor(own / costNum)
	end

	self.m_maxNum = max
	if false and self.m_data.personNumber > 0 then
		local now = self.m_data.personNumber - self.m_data.times --当前剩余可兑换的次数
		local times = math.min(now, max)
		self.m_maxNum = times
	else
		self.m_maxNum = math.min(max,PROP_BUY_MAX_NUM)
	end

    self.m_minNum = 1
    if self.m_maxNum == 0 then self.m_minNum = 0 end
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum


	local total = ui.newTTFLabel({text = "/" .. self.m_maxNum, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	total:setAnchorPoint(cc.p(0, 0.5))
	self.m_totalLabel = total

	local barHeight = 40
	local barWidth = 266
	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 160)
    self.m_numSlider:setSliderSize(barWidth, barHeight)
    self.m_numSlider:onSliderValueChanged(handler(self, self.onSlideCallback))
    self.m_numSlider:setSliderValue(self.m_settingNum)
    self.m_numSlider:setBg(IMAGE_COMMON .. "bar_bg_3.png", cc.size(266 + 78, 64), {x = barWidth / 2, y = barHeight / 2 - 4})

    -- 使用按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    self.m_okBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onOkCallback)):addTo(self:getBg())  -- 确定
    self.m_okBtn:setLabel(CommonText[1])
    self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 80)

    local fromPos = self:convertToNodeSpace(cc.p(self.m_viewPos.x, self.m_viewPos.y))
    local toPos = self:getBg():convertToWorldSpace(cc.p(84, self:getBg():getContentSize().height - 94))

    local kind,id,count = item.type, item.id, item.count
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

function RedPlanExchangeDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(self.m_settingNum * self.cost)
end

function RedPlanExchangeDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
	self.priceLabel:setString(self.m_settingNum * self.cost)
end

function RedPlanExchangeDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
	self.priceLabel:setString(self.m_settingNum * self.cost)
end

function RedPlanExchangeDialog:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local goodId = self.m_data.resolveId
	if self.m_settingNum <= 0 then return end
	local count = self.m_settingNum
	local activityId = self.activityId
	local price = self.cost * self.m_settingNum --总消耗

	local function gotoBuy()
		local function doneExcProp(data)
			if self.m_useCallback then self.m_useCallback(data) end
			self:pop()
		end
		ActivityCenterBO.exchangeRedPlan(doneExcProp, goodId, count)
	end

	gotoBuy()
end

return RedPlanExchangeDialog