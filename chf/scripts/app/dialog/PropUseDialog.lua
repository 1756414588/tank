
-- 道具批量使用弹出框

local Dialog = require("app.dialog.Dialog")
local PropUseDialog = class("PropUseDialog", Dialog)

function PropUseDialog:ctor(propId, useCallback)
	PropUseDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 382)})

	self.m_propId = propId
	self.m_useCallback = useCallback
end

function PropUseDialog:onEnter()
	PropUseDialog.super.onEnter(self)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)

	self:setTitle(CommonText[429]) -- 批量使用

	local resData = UserMO.getResourceData(ITEM_KIND_PROP, self.m_propId)
	local propCount = UserMO.getResource(ITEM_KIND_PROP, self.m_propId)

	self.m_propDB = PropMO.queryPropById(self.m_propId)
	if self.m_propDB.effectType == 8 then --选择使用
		self:pop(function()
			require("app.dialog.PropUseAssign").new(self.m_propId,self.m_useCallback):push()
		end)
		return
	end

	local itemView = UiUtil.createItemView(ITEM_KIND_PROP, self.m_propId):addTo(self:getBg())
	itemView:setPosition(100, self:getBg():getContentSize().height - 130)

	-- 名称
	local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self:getBg():getContentSize().height - 90, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	name:setAnchorPoint(cc.p(0, 0.5))

	local desc = ui.newTTFLabel({text = self.m_propDB.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self:getBg():getContentSize().height - 150, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(350, 120)}):addTo(self:getBg())
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	-- 数量
	local label = ui.newTTFLabel({text = CommonText[40] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = 160, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	label:setAnchorPoint(cc.p(1, 0.5))

	-- 
	local count = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	count:setAnchorPoint(cc.p(0, 0.5))
	self.m_numLabel = count

	local total = ui.newTTFLabel({text = "/" .. propCount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	total:setAnchorPoint(cc.p(0, 0.5))
	self.m_totalLabel = total

 	local barHeight = 40
	local barWidth = 266

    -- 减少按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_reduce_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_reduce_selected.png")
    local reduceBtn = MenuButton.new(normal, selected, nil, handler(self, self.onReduceCallback)):addTo(self:getBg())
    reduceBtn:setPosition(self:getBg():getContentSize().width / 2 - barWidth / 2 - 78, 100 + 16)

    -- 增加按钮
    local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
    local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(self:getBg())
    addBtn:setPosition(self:getBg():getContentSize().width / 2 + barWidth / 2 + 78, reduceBtn:getPositionY())

    self.m_maxNum = propCount
    self.m_minNum = 1
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
	self.m_settingNum = self.m_minNum

	self.m_numSlider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."bar_4.png", button = IMAGE_COMMON.."btn_slider_head.png"}, {scale9 = true,min=self.m_minNum,max = self.m_maxNum}):addTo(self:getBg())
	self.m_numSlider:align(display.LEFT_BOTTOM, self:getBg():getContentSize().width / 2 - barWidth / 2, 100)
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
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 25)
	--只有一个道具，直接使用
	if propCount == 1 then
		self:hide()
		self:onOkCallback(nil,nil)	
	end
end

function PropUseDialog:onReduceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum - 1
	self.m_settingNum = math.max(self.m_settingNum, self.m_minNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropUseDialog:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_settingNum = self.m_settingNum + 1
	self.m_settingNum = math.min(self.m_settingNum, self.m_maxNum)
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

function PropUseDialog:onSlideCallback(event)
	local value = event.value - event.value % 1
	self.m_settingNum = value
	self.m_numLabel:setString(self.m_settingNum)
	self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
end

function PropUseDialog:onOkCallback(tag, sender)
	if not sender then
		ManagerSound.playNormalButtonSound()
	end

	if self.m_isUseProp then return false end

	if self.m_settingNum <= 0 then return end

    local function doneUseProp(awards)
    	self.m_isUseProp = false
    		
	    Loading.getInstance():unshow()
    	if self.m_useCallback then self.m_useCallback(awards) end
    	self.m_lastSettingNum = self.m_settingNum
    	local propCount = UserMO.getResource(ITEM_KIND_PROP, self.m_propId)
    	if propCount > 0 then
    		self:reSetUI(propCount)
    	else
    		self:pop()
    	end
    end

    self.m_isUseProp = true

    Loading.getInstance():show()
    if self.m_propId == PROP_ID_TANKBOX then --军团战箱子
    	PartyBattleBO.asynUseAmyProp(function(awards)
				Loading.getInstance():unshow()
				doneUseProp(awards)
			end,self.m_propId, self.m_settingNum)
    else
    	PropBO.asynUseProp(doneUseProp, self.m_propId, self.m_settingNum)
    end
end

function PropUseDialog:reSetUI(propCount)
	self.m_totalLabel:setString("/" .. propCount)
	self.m_totalLabel:setPosition(self.m_numLabel:getPositionX() + self.m_numLabel:getContentSize().width, self.m_numLabel:getPositionY())
    self.m_maxNum = propCount
    self.m_minNum = 1
    if self.m_maxNum > PROP_BUY_MAX_NUM then self.m_maxNum = PROP_BUY_MAX_NUM end
    if self.m_minNum >= propCount then self.m_minNum = propCount end
	self.m_settingNum = self.m_lastSettingNum
	if self.m_lastSettingNum > self.m_maxNum then
		self.m_settingNum = self.m_maxNum
	end
	self.m_numSlider.max_ = self.m_maxNum
	self.m_numSlider:setSliderValue(self.m_settingNum)
end

return PropUseDialog
