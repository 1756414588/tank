
local Dialog = require("app.dialog.Dialog")
local ConfirmDialog = class("ConfirmDialog", Dialog)

function ConfirmDialog:ctor(desc, okCallback, cancelCallback, param)
	ConfirmDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	desc = desc or ""
	self.m_desc = desc
	self.m_okCallback = okCallback
	self.m_cancelCallback = cancelCallback
	self.param = param
end

function ConfirmDialog:onEnter()
	ConfirmDialog.super.onEnter(self)

	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 230)

	local label = ui.newTTFLabel({text = CommonText[947][2], font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)
	label:setPositionY(self:getBg():getContentSize().height - 230 - label:getContentSize().height - 20 )

	local descType = type(self.m_desc)
	if descType == 'string' then
		self.m_descLabel = ui.newTTFLabel({text = self.m_desc, font = G_FONT, size = FONT_SIZE_MEDIUM,
			dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)
	else
		self.m_descLabel = RichLabel.new(self.m_desc, cc.size(0, 0)):addTo(self.m_contentNode)
	end

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	self.m_descLabel:setAnchorPoint(cc.p(0,0.5))

	self.m_descLabel:setPositionX(-self.m_descLabel:getContentSize().width/2)

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

function ConfirmDialog:registerRecreate(callback)
	if not callback then return end

	self.m_contentNode:removeAllChildren()
	callback(self.m_contentNode)
end

function ConfirmDialog:setDesc(desc)
	if not desc then return end

	if self.m_descLabel then
		if type(desc) == 'string' then
			self.m_descLabel:setString(desc)
		else
			self.m_descLabel:setStringData(desc)
		end
	end
end

function ConfirmDialog:setCancelBtnText(text)
	if not text then return end

	self.m_cancelBtn:setLabel(text)
end

function ConfirmDialog:setOkBtnText(text)
	if not text then return end

	self.m_okBtn:setLabel(text)
end

function ConfirmDialog:setClickClose(close)
	self.m_isClickClose = close
end

return ConfirmDialog

