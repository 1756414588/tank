
-- 

local LabelButton = class("LabelButton", Button)

function LabelButton:ctor(param, tagCallback)
	LabelButton.super.ctor(self)

	self:setString(param)

	self:setTagCallback(tagCallback)
end

function LabelButton:setString(param)
	if param == nil or param.text == nil then
		assert("ScaleButton:ctor param or text is nil!")
	end

	if self.m_label then
		self.m_label:removeSelf()
		self.m_label = nil
	end

	param.font = G_FONT
	param.size = FONT_SIZE_SMALL
	param.align = ui.TEXT_ALIGN_CENTER

	local label = ui.newTTFLabel(param):addTo(self)
	label:setAnchorPoint(cc.p(0.5, 0.5))

	self:setContentSize(label:getContentSize())

	label:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

	self.m_label = label
end

-- function LabelButton:onTouchBegan(event, x, y)
-- 	self.m_spriteOriginalScaleFactor = self:getScale()
-- 	--gprint("LabelButton:onTouchBegan")
-- 	-- self:setScale(self.m_spriteOriginalScaleFactor * 0.95)
-- 	self:runAction(CCScaleTo:create(0.08, self.m_spriteOriginalScaleFactor * 0.95))
-- 	return true
-- end

-- function LabelButton:onTouchMoved(event, x, y)
-- 	-- gprint("MOVE....")
-- end

-- function LabelButton:onTouchEnded(event, x, y)
-- 	--gprint("END")
-- 	self:stopAllActions()
-- 	self:setScale(self.m_spriteOriginalScaleFactor)
-- 	--self.m_touchSprite:setScale(self.m_spriteOriginalScaleFactor)

-- 	LabelButton.super.onTouchEnded(self, event, x, y)
-- end

-- function LabelButton:onTouchCancelled(event, x, y)
-- 	-- gprint("LabelButton: CANCELLED")
-- 	self:stopAllActions()
-- 	self:setScale(self.m_spriteOriginalScaleFactor)
-- 	--self.m_touchSprite:setScale(self.m_spriteOriginalScaleFactor)
-- end

return LabelButton
