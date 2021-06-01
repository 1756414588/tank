
local CheckBox = class("CheckBox", Button)

-- MenuButton.BUTTON_LABEL_COLOR = cc.c3b(255, 255, 253)

function CheckBox:ctor(uncheckedSprite, checkedSprite, onCheckedChanged)
	CheckBox.super.ctor(self)

	uncheckedSprite = uncheckedSprite or display.newSprite(IMAGE_COMMON .. "btn_7_unchecked.png")
	checkedSprite = checkedSprite or display.newSprite(IMAGE_COMMON .. "btn_7_checked.png")

	self:setCascadeOpacityEnabled(true)

	self:setContentSize(cc.size(uncheckedSprite:getContentSize().width * uncheckedSprite:getScaleX(), uncheckedSprite:getContentSize().height * uncheckedSprite:getScaleY()))

	self.m_onCheckedChanged = onCheckedChanged

	self:setTagCallback(handler(self, self.onCheckedClick))
	self:setUnCheckedSprite(uncheckedSprite)
	self:setCheckedSprite(checkedSprite)

	self:setChecked(false)
end

function CheckBox:setChecked(checked)
	self.m_isChecked = checked
	self:updateImagesVisibility()
end

function CheckBox:isChecked()
	return self.m_isChecked
end

function CheckBox:setCheckedSprite(checkedSprite)
	if self.m_checkedSprite then
		self.m_checkedSprite:removeSelf()
		self.m_checkedSprite = nil
	end

	if checkedSprite then
		self.m_checkedSprite = checkedSprite
		self.m_checkedSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(self.m_checkedSprite)
	end
	self:updateImagesVisibility()
end

function CheckBox:setUnCheckedSprite(uncheckedSprite)
	if self.m_uncheckedSprite then
		self.m_uncheckedSprite:removeSelf()
		self.m_uncheckedSprite = nil
	end

	if uncheckedSprite then
		self.m_uncheckedSprite = uncheckedSprite
		self.m_uncheckedSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(self.m_uncheckedSprite)
	end
	self:updateImagesVisibility()
end

function CheckBox:updateImagesVisibility()
	if self:isChecked() then
		if self.m_checkedSprite then self.m_checkedSprite:setVisible(true) end
		if self.m_uncheckedSprite then self.m_uncheckedSprite:setVisible(true) end
	else
		if self.m_checkedSprite then self.m_checkedSprite:setVisible(false) end
		if self.m_uncheckedSprite then self.m_uncheckedSprite:setVisible(true) end
	end
end

function CheckBox:onCheckedClick(tag, sender)
	if self:isChecked() then
		self:setChecked(false)
	else
		self:setChecked(true)
	end

	if self.m_onCheckedChanged then
		self.m_onCheckedChanged(self, self:isChecked())
	end
end

return CheckBox
