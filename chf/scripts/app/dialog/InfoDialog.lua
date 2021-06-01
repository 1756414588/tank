
local Dialog = require("app.dialog.Dialog")
local InfoDialog = class("InfoDialog", Dialog)

function InfoDialog:ctor(desc, okCallback, size, offset)
	size = size or cc.size(550, 360)
	InfoDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = size})

	desc = desc or ""
	self.m_desc = desc
	self.m_okCallback = okCallback
	self.m_offset = offset
end

function InfoDialog:onEnter()
	InfoDialog.super.onEnter(self)

	-- 点击了确定或者取消按钮后就立即关闭弹出框
	self.m_isClickClose = true

	self.m_contentNode = display.newNode():addTo(self:getBg())
	self.m_contentNode:setPosition(self:getBg():getContentSize().width / 2, 230)

	self.m_descLabel = ui.newTTFLabel({text = self.m_desc, font = G_FONT, size = FONT_SIZE_MEDIUM,
		dimensions = cc.size(0, 0), align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(self.m_contentNode)

	if self.m_descLabel:getContentSize().width > 450 then
		self.m_descLabel:setDimensions(cc.size(450, 200))
	end

	if self.m_offset then
		self.m_descLabel:setPosition(self.m_offset)
	end

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
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2, 70)
end

function InfoDialog:registerRecreate(callback)
	if not callback then return end

	self.m_contentNode:removeAllChildren()
	callback(self.m_contentNode)
end

function InfoDialog:setDesc(desc)
	if not desc then return end

	if self.m_descLabel then
		self.m_descLabel:setString(desc)
	end
end

function InfoDialog:setOkBtnText(text)
	if not text then return end

	self.m_okBtn:setLabel(text)
end

function InfoDialog:setClickClose(close)
	self.m_isClickClose = close
end

return InfoDialog

