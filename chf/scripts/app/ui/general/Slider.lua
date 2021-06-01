
local Slider = class("Slider", cc.ui.UISlider)

function Slider:ctor(direction, images, options)
	Slider.super.ctor(self, direction, images, options)
	self.limitMax_ = options.limitmax or self.max_
	self.limitMin_ = options.limitmin or self.min_

	self:setSliderValue((self.min_ + self.max_) / 2)

	self:onShowSlider()

	self:addSliderValueChangedEventListener(handler(self, self.onShowSlider))
	self:addSliderPressedEventListener(handler(self, self.onShowSlider))
	self:addSliderReleaseEventListener(handler(self, self.onShowSlider))
	self:addSliderValueChangedEventListener(handler(self, self.onShowSlider))
end

function Slider:updateButtonPosition_()
	if not self.barSprite_ or not self.buttonSprite_ then return end

	if self.max_ == self.min_ then
		local x, y = 0, 0
		local barSize = self.barSprite_:getContentSize()
		local buttonSize = self.buttonSprite_:getContentSize()
		local ap = self:getAnchorPoint()

		if self.isHorizontal_ then
			x = x - barSize.width * ap.x
			y = y + barSize.height * (0.5 - ap.y)

			if self.direction_ == display.LEFT_TO_RIGHT then
				if self.min_ == 0 then
					x = buttonSize.width / 2
					self.barSprite_:setVisible(false)
				else
					x = x + buttonSize.width / 2 + barSize.width - buttonSize.width
				end
			else
			end
		else
		end
		-- print("x:", self.buttonSprite_:getPositionX(), "y:", self.buttonSprite_:getPosition())
		self.buttonSprite_:setPosition(x, y)
	else
		return Slider.super.updateButtonPosition_(self)
	end
end

function Slider:setSliderValue(value)
    assert(value >= self.min_ and value <= self.max_, "UISlider:setSliderValue() - invalid value")
    -- if self.value_ ~= value then
    	if value >= self.limitMax_ then value = self.limitMax_ end
    	if value <= self.limitMin_ then value = self.limitMin_ end
        self.value_ = value
        self:updateButtonPosition_()
        self:dispatchEvent({name = cc.ui.UISlider.VALUE_CHANGED_EVENT, value = self.value_})
    -- end
    return self
end

function Slider:onShowSlider()
	if self.max_ == self.min_ then
		if self.isHorizontal_ then
			self.barSprite_:setScaleX(1)
		else
			self.barSprite_:setScaleY(1)
		end
	else
		local value = self:getSliderValue()
		local percent = (value - self.min_) / (self.max_ - self.min_)
		if self.isHorizontal_ then
			self.barSprite_:setScaleX(percent)
		else
			self.barSprite_:setScaleY(percent)
		end
	end
end

function Slider:setBg(bgName, scale9Size, param)
	param = param or {}
	param.x = param.x or self.barSprite_:getContentSize().width / 2
	param.y = param.y or self.barSprite_:getContentSize().height / 2

	if bgName then
		if scale9Size then
			self.m_bg = display.newScale9Sprite(bgName):addTo(self, -1)
			self.m_bg:setPreferredSize(scale9Size)
		else
			self.m_bg = display.newSprite(bgName):addTo(self, -1)
		end

		self.m_bg:setPosition(param.x, param.y)
	end
end

function Slider:onTouch_(event, x, y)
	if self.max_ == self.min_ then
		return true
	else
		return Slider.super.onTouch_(self, event, x, y)
	end 
end

-- 设置 动态限制 不改变上/下限
function Slider:setSliderLimit(limitMax, limitMin)
	local limitMax_ = limitMax or self.max_
	local limitMin_ = limitMin or self.min_

	self.limitMax_ = math.max(math.min(limitMax_, self.max_), self.min_) 
	self.limitMin_ = math.max(math.min(limitMin_, self.max_), self.min_) 

	if self.value_ > self.limitMax_ then
		self:setSliderValue(self.limitMax_)
	elseif self.value_ < self.limitMin_ then
		self:setSliderValue(self.limitMin_)
	end
end

return Slider
