--
--
--

local Dialog = require("app.dialog.Dialog")
local TipsAnyThingDialog = class("TipsAnyThingDialog", Dialog)

function TipsAnyThingDialog:ctor(desc, okcallback, okLabel, cancelCallback, cancelLabel)
	TipsAnyThingDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})
	self.desc = desc
	self.m_okCallback = okcallback
	self.okLabel = okLabel
	self.m_cancelCallback = cancelCallback
	self.cancelLabel = cancelLabel
end

function TipsAnyThingDialog:onEnter()
	TipsAnyThingDialog.super.onEnter(self)

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 250)

	self.m_descLabel = ui.newTTFLabel({text = self.desc, font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop(function ()
			if self.m_cancelCallback then self.m_cancelCallback() end
		end)
	end

	local cancelStr = self.cancelLabel or CommonText[2]
	-- 取消按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	self.m_cancelBtn = MenuButton.new(normal, selected, disabled, onCancelCallback):addTo(self:getBg())  -- 取消
	self.m_cancelBtn:setLabel(cancelStr)
	self.m_cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 130, 70)

	local function onOkCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		self:pop(function ()
			if self.m_okCallback then self.m_okCallback() end
		end)
	end

	local okStr = self.okLabel or CommonText[1]
	-- 确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal, selected, disabled, onOkCallback):addTo(self:getBg())  -- 确定
	self.m_okBtn:setLabel(okStr)
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2 + 130, 70)
end


return TipsAnyThingDialog