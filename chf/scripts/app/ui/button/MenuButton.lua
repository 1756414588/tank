-- 菜单按钮，touchBegan事件下button会切换按下效果

local MenuButton = class("MenuButton", Button)

-- MenuButton.BUTTON_BIG_LABEL_COLOR = cc.c3b(60, 42, 80)
-- MenuButton.BUTTON_SMALL_LABEL_COLOR = cc.c3b(251, 250, 246)
MenuButton.BUTTON_BIG_LABEL_COLOR = cc.c3b(255, 255, 255)
MenuButton.BUTTON_SMALL_LABEL_COLOR = cc.c3b(255, 255, 255)

function MenuButton:ctor(normalSprite, selectedSprite, disabledSprite, tagCallback)
	MenuButton.super.ctor(self)

	if normalSprite == nil then
		assert("MenuButton:ctor normalSprite is nil!")
	end

	if selectedSprite == nil then
		assert("MenuButton:ctor selectedSprite is nil!")
	end

	self:setCascadeOpacityEnabled(true)

	-- self.m_normalSprite = normalSprite
	-- self.m_selectedSprite = selectedSprite
	-- self.m_disabledSprite = disabledSprite
	self:setContentSize(cc.size(math.abs(normalSprite:getContentSize().width * normalSprite:getScaleX()), math.abs(normalSprite:getContentSize().height * normalSprite:getScaleY())))

	self:setNormalSprite(normalSprite)
	self:setSelectedSprite(selectedSprite)
	self:setDisabledSprite(disabledSprite)

	-- if self.m_normalSprite then
	-- 	self.m_normalSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- 	self:addChild(self.m_normalSprite)
	-- end
	-- if self.m_selectedSprite then
	-- 	self.m_selectedSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- 	self:addChild(self.m_selectedSprite)
	-- end
	-- if self.m_disabledSprite then
	-- 	self.m_disabledSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- 	self:addChild(self.m_disabledSprite)
	-- end

	self:setTagCallback(tagCallback)

    self:updateImagesVisibility()
end

function MenuButton:setNormalSprite(normalSprite)
	if self.m_normalSprite then
		self.m_normalSprite:removeSelf()
		self.m_normalSprite = nil
	end
	if normalSprite then
		self.m_normalSprite = normalSprite
		self.m_normalSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(self.m_normalSprite)
	end
	self:updateImagesVisibility()
end

function MenuButton:setSelectedSprite(selectedSprite)
	if self.m_selectedSprite then
		self.m_selectedSprite:removeSelf()
		self.m_selectedSprite = nil
	end
	if selectedSprite then
		self.m_selectedSprite = selectedSprite
		self.m_selectedSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(self.m_selectedSprite)
	end
	self:updateImagesVisibility()
end

function MenuButton:setDisabledSprite(disabledSprite)
	if self.m_disabledSprite then
		self.m_disabledSprite:removeSelf()
		self.m_disabledSprite = nil
	end
	if disabledSprite then
		self.m_disabledSprite = disabledSprite
		self.m_disabledSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(self.m_disabledSprite)
	end
	self:updateImagesVisibility()
end

--只在没选中状态才能点击
function MenuButton:selectDisabled()
	if self.m_selectedSprite:isVisible() then
		return true
	end
end

function MenuButton:onTouchBegan(event)
	if self:selectDisabled() then
		return false
	end
	self:selected()
	return true
end

function MenuButton:onTouchMoved(event)
	--gprint("MOVE....")
	if not self:containPosition(event.x, event.y) then
		self:unselected()
	else
		self:selected()
	end
end

function MenuButton:onTouchEnded(event)
	--gprint("END")
	self:unselected()
	MenuButton.super.onTouchEnded(self, event)
end

function MenuButton:onTouchCancelled(event)
	--gprint("MenuButton: CANCELLED")
	self:unselected()
end

function MenuButton:setEnabled(enabled)
	MenuButton.super.setEnabled(self, enabled)

	self:updateImagesVisibility()
end

function MenuButton:selected()
	if self.m_normalSprite then
		if self.m_disabledSprite then self.m_disabledSprite:setVisible(false) end

		if self.m_selectedSprite then
			self.m_normalSprite:setVisible(false)
			self.m_selectedSprite:setVisible(true)
		else
			self.m_normalSprite:setVisible(true)
		end
	end
end

function MenuButton:unselected()
	if self.m_normalSprite then
		self.m_normalSprite:setVisible(true)

		if self.m_selectedSprite then self.m_selectedSprite:setVisible(false) end
		if self.m_disabledSprite then self.m_disabledSprite:setVisible(false) end
	end
end

function MenuButton:updateImagesVisibility()
	if self:isEnabled() then
		if self.m_normalSprite then self.m_normalSprite:setVisible(true) end
		if self.m_selectedSprite then self.m_selectedSprite:setVisible(false) end
		if self.m_disabledSprite then self.m_disabledSprite:setVisible(false) end
	else
		if self.m_disabledSprite then
			if self.m_normalSprite then self.m_normalSprite:setVisible(false) end
			if self.m_selectedSprite then self.m_selectedSprite:setVisible(false) end
			if self.m_disabledSprite then self.m_disabledSprite:setVisible(true) end
		else
			if self.m_normalSprite then self.m_normalSprite:setVisible(true) end
			if self.m_selectedSprite then self.m_selectedSprite:setVisible(false) end
			if self.m_disabledSprite then self.m_disabledSprite:setVisible(false) end
		end
	end
end

function MenuButton:setLabel(strText, param)
	param = param or {}
	param.color = param.color or nil
	param.size = param.size or (FONT_SIZE_SMALL + 2)
	param.x = param.x or self:getContentSize().width / 2
	param.y = param.y or self:getContentSize().height / 2

	if self.m_label then
		self.m_label:setString(strText)

		self.m_label:setPosition(param.x, param.y)
		self.m_label:setFontSize(param.size)

		if param.color then self.m_label:setColor(param.color) end
	else
		local labelColor = nil
		local size = 0
		local delta = 0
		if self:getContentSize().width > 180 then  -- 大的按钮
			size = FONT_SIZE_SMALL + 2
			delta = 0
			if not labelColor then labelColor = MenuButton.BUTTON_BIG_LABEL_COLOR  end
		else
			size = FONT_SIZE_SMALL + 2
			delta = 0
			if not labelColor then labelColor = MenuButton.BUTTON_SMALL_LABEL_COLOR end
		end

		if param.color then labelColor = param.color end

		self.m_label = ui.newTTFLabel({text = strText, font = G_FONT, size = param.size, x = param.x, y = param.y, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self, 4)
	end
end

function MenuButton:getLabel()
	return self.m_label
end

return MenuButton
