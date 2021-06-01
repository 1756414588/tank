--
-- Author: Your Name
-- Date: 2017-07-24 11:28:45
--

local Dialog = require("app.dialog.Dialog")
local MailDelDialog = class("MailDelDialog", Dialog)

function MailDelDialog:ctor(desc, okCallback, cancelCallback)
	MailDelDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 360)})

	desc = desc or ""
	self.m_desc = desc
	self.m_okCallback = okCallback
	self.m_cancelCallback = cancelCallback
end

function MailDelDialog:onEnter()
	MailDelDialog.super.onEnter(self)

	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 250)

	self.m_descLabel = ui.newTTFLabel({text = self.m_desc, font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	local function onCancelCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_isClickClose then
			self:pop(self.m_cancelCallback)
		else
			if self.m_cancelCallback then self.m_cancelCallback() end
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
			self:pop(self.m_okCallback)
		else
			if self.m_okCallback then self.m_okCallback() end
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

return MailDelDialog

