-- 缩放按钮，touchBegan事件下button会缩放

local ScaleButton = class("ScaleButton", Button)

function ScaleButton:ctor(touchSprite, tagCallback)
	ScaleButton.super.ctor(self)

	if touchSprite == nil then
		assert("ScaleButton:ctor touchSprite is nil!")
	end

	self:addChild(touchSprite)
	self:setContentSize(touchSprite:getContentSize())

	touchSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

	self.m_touchSprite = touchSprite
	--self.m_spriteOriginalScaleFactor = touchSprite:getScale()
	
	self:setTagCallback(tagCallback)
end

function ScaleButton:onTouchBegan(event, x, y)
	self.m_spriteOriginalScaleFactor = self:getScale()
	--gprint("ScaleButton:onTouchBegan")
	-- self:setScale(self.m_spriteOriginalScaleFactor * 0.95)
	self:runAction(CCScaleTo:create(0.08, self.m_spriteOriginalScaleFactor * 0.95))
	return true
end

function ScaleButton:onTouchMoved(event, x, y)
	-- gprint("MOVE....")
end

function ScaleButton:onTouchEnded(event, x, y)
	--gprint("END")
	self:stopAllActions()
	self:setScale(self.m_spriteOriginalScaleFactor)
	--self.m_touchSprite:setScale(self.m_spriteOriginalScaleFactor)

	ScaleButton.super.onTouchEnded(self, event, x, y)
end

function ScaleButton:onTouchCancelled(event, x, y)
	-- gprint("ScaleButton: CANCELLED")
	self:stopAllActions()
	self:setScale(self.m_spriteOriginalScaleFactor)
	--self.m_touchSprite:setScale(self.m_spriteOriginalScaleFactor)
end

function ScaleButton:setTouchSprite(touchSprite)
	self:removeChild(self.m_touchSprite)
	self:setContentSize(touchSprite:getContentSize())
	touchSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.m_touchSprite = touchSprite
	self:addChild(self.m_touchSprite)
end

return ScaleButton
