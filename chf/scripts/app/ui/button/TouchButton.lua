-- 触碰按钮，可以获得touch各个事件回调的button

local TouchButton = class("TouchButton", Button)

function TouchButton:ctor(touchSprite, beganCallback, movedCallback, endedCallback, tagCallback)

	TouchButton.super.ctor(self)

	if touchSprite == nil then
		assert("TouchButton:ctor touchSprite is nil!")
	end

	self:addChild(touchSprite)
	self:setContentSize(touchSprite:getContentSize())

	touchSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.m_touchSprite = touchSprite
	self.m_beganCallback = beganCallback
	self.m_movedCallback = movedCallback
	self.m_endedCallback = endedCallback

	self:setTagCallback(tagCallback)
end

function TouchButton:onTouchBegan(event)
	--gprint("TouchButton:onTouchBegan")
	if self.m_beganCallback ~= nil then
		self.m_beganCallback(self:getTag(), self, event.x, event.y)
	end
	return true
end

function TouchButton:onTouchMoved(event)
	-- gprint("MOVE....")
	if self.m_movedCallback ~= nil then
		self.m_movedCallback(self:getTag(), self, event.x, event.y)
	end
end

function TouchButton:onTouchEnded(event)
	--gprint("END")
	if self.m_endedCallback ~= nil then
		self.m_endedCallback(self:getTag(), self, event.x, event.y)
	end

	TouchButton.super.onTouchEnded(self, event)
end

function TouchButton:onTouchCancelled(event)
	-- gprint("TouchButton CANCELLED")
	if self.m_endedCallback ~= nil then
		self.m_endedCallback(self:getTag(), self, event.x, event.y)
	end
end

function TouchButton:setTouchSprite(touchSprite)
	if touchSprite == nil then
		assert("TouchButton:ctor touchSprite is nil!")
	end

	if self.m_touchSprite then
		self.m_touchSprite:removeSelf()
		self.m_touchSprite = nil
	end
	self:addChild(touchSprite)
	self:setContentSize(touchSprite:getContentSize())
	touchSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.m_touchSprite = touchSprite
end

return TouchButton