require("app.text.DetailText")

local Dialog = require("app.dialog.Dialog")
local NewHeroCDConfirmDialog = class("NewHeroCDConfirmDialog", Dialog)

function NewHeroCDConfirmDialog:ctor(okCallback, cancelCallback, param, cooldownTimeS, goldPerM, cdClearRemains)
	NewHeroCDConfirmDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	self.m_okCallback = okCallback
	self.m_cancelCallback = cancelCallback
	self.param = param
	self.m_cooldownTimeS = cooldownTimeS
	self.m_goldPerM = goldPerM
	self.m_cdClearRemains = cdClearRemains
end

function NewHeroCDConfirmDialog:onEnter()
	NewHeroCDConfirmDialog.super.onEnter(self)

	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 230)

	local label = ui.newTTFLabel({text = CommonText[947][2], font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)
	label:setPositionY(self:getBg():getContentSize().height - 230 - label:getContentSize().height - 20 )

	local cd = self.m_cooldownTimeS
	local h = math.floor(cd / 3600)
	local m = math.floor((cd - h * 3600) / 60)
	local s = cd - h * 3600 - m * 60
	local mt = math.ceil(cd / 60)

	local timeStr = string.format("%02dh:%02dm:%02ds",h,m,s)
	local goldCost = math.ceil(mt*self.m_goldPerM)
	local descStr = DetailText.formatDetailText(DetailText.newHeroClearCD, timeStr, goldCost, self.m_cdClearRemains)
	self.m_descLabel = RichLabel.new(descStr[1], cc.size(0, 0)):addTo(self.m_contentNode)

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	self.m_descLabel:setAnchorPoint(cc.p(0,0.5))

	self.m_descLabel:setPositionX(-self.m_descLabel:getContentSize().width/2)

	self.m_descLabel:performWithDelay(handler(self, self.onTick), 1, 1)

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_isClickClose then
			self:pop()
			if self.m_cancelCallback then self.m_cancelCallback(self.param) end
		else
			if self.m_cancelCallback then self.m_cancelCallback(self.param) end
		end
	end

	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(CommonText[2])
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 70)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_isClickClose then
			self:pop()
			if self.m_okCallback then self.m_okCallback(self.param) end
		else
			if self.m_okCallback then self.m_okCallback(self.param) end
		end
	end

	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 70)
end

function NewHeroCDConfirmDialog:onTick()
	-- body

	self.m_cooldownTimeS = self.m_cooldownTimeS - 1
	if self.m_cooldownTimeS <= 0 then
		self.m_cooldownTimeS = 0
		self:pop()
		if self.m_cancelCallback then self.m_cancelCallback(self.param) end
		return
	end

	local cd = self.m_cooldownTimeS
	local h = math.floor(cd / 3600)
	local m = math.floor((cd - h * 3600) / 60)
	local s = cd - h * 3600 - m * 60
	local mt = math.ceil(cd / 60)

	local timeStr = string.format("%02dh:%02dm:%02ds",h,m,s)
	local goldCost = math.ceil(mt*self.m_goldPerM)
	local descStr = DetailText.formatDetailText(DetailText.newHeroClearCD, timeStr, goldCost, self.m_cdClearRemains)
	self.m_descLabel:setStringData(descStr[1])
end

function NewHeroCDConfirmDialog:registerRecreate(callback)
	if not callback then return end

	self.m_contentNode:removeAllChildren()
	callback(self.m_contentNode)
end

function NewHeroCDConfirmDialog:setCancelBtnText(text)
	if not text then return end

	self.m_cancelBtn:setLabel(text)
end

function NewHeroCDConfirmDialog:setOkBtnText(text)
	if not text then return end

	self.m_okBtn:setLabel(text)
end

function NewHeroCDConfirmDialog:setClickClose(close)
	self.m_isClickClose = close
end

return NewHeroCDConfirmDialog 
