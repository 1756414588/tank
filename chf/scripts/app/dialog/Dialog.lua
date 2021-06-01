
Dialog = class("Dialog", UiNode)

function Dialog:ctor(bgName, enterStyle, param)
	param = param or {}
	param.alpha = param.alpha or 180
	self.param__ = param
	-- param.receiveTouch = true

	self.m_bgName = bgName

	Dialog.super.ctor(self, bgName, enterStyle, param)

	self._full_screen_ = false
end

function Dialog:onEnter()
	Dialog.super.onEnter(self)

	if self.m_enterStyle == UI_ENTER_LEFT_TO_RIGHT then
		self.m_bg:setPositionX(-self:getBg():getContentSize().width / 2)
		self.m_bg:runAction(transition.sequence({cc.EaseBackOut:create(cc.MoveBy:create(0.3, cc.p(self:getBg():getContentSize().width / 2 + display.cx, 0))),
			cc.CallFunc:create(function() self:onEnterEnd() end)}))
	else
	end

	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, self.param__.alpha)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)

	nodeTouchEventProtocol(self.touchLayer, function(event) return self:onTouch(event) end, nil, nil, true)

	self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)
	self:getBg():setCascadeColorEnabled(true)
    self:getBg():setCascadeOpacityEnabled(true)

end

function Dialog:hasCloseButton(has)
	if has then
		if not self.m_returnButton then
			if self.m_bgName == "image/common/bg_dlg_1.png" then
				local normal = display.newSprite(IMAGE_COMMON .. "btn_close_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_close_selected.png")
				local disabled = display.newSprite(IMAGE_COMMON .. "btn_close_disabled.png")
				local returnButton = MenuButton.new(normal, selected, disabled, handler(self, self.onReturnCallback)):addTo(self.m_bg, 5)
				returnButton:setPosition(self.m_bg:getContentSize().width - 62, self.m_bg:getContentSize().height - 36)
				self.m_returnButton = returnButton
			end
		end
	else
		if self.m_returnButton then
			self.m_returnButton:removSelf()
			self.m_returnButton = nil
		end
	end
end

-- function Dialog:setTitle(titleName)
-- 	if self.m_bgName == IMAGE_COMMON .. "bg_dlg_1.png" then
-- 		local title = ui.newTTFLabel({text = titleName, font = G_FONT, size = FONT_SIZE_MEDIUM,
-- 			x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
-- 	-- elseif self.m_bgName == IMAGE_COMMON .. "dlg_bg_11.png" then
-- 		-- local bg = display.newSprite(IMAGE_COMMON.. "ui_title_bg_2.png", 440, 470):addTo(self.m_bg)
-- 		-- local title = display.newSprite(url, 440, 457):addTo(bg)
-- 		-- local title = display.newSprite(url, 440, 457):addTo(self.m_bg)
-- 		-- title:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height - title:getContentSize().height / 2 - 20)
-- 	end
-- end

function Dialog:setPosition(x, y)
	error("Dialog cannot set position! Please set position of bg")
end

-- touch事件在背景的范围外发生时，是否可以关闭弹出框
function Dialog:setOutOfBgClose(enable, closeCallback)
	self.m_outOfBgClose = enable
	self.m_outOfBgCloseCallback = closeCallback
end

-- touch事件在背景的范围内发生时，是否可以关闭弹出框
function Dialog:setInOfBgClose(enable, closeCallback)
	self.m_inOfBgClose = enable
	self.m_inOfBgCloseCallback = closeCallback
end

-- 判断是否在点击到了弹出框背景外部的是否，是使用getCascadeBoundingBox还是使用getCascadeBoundingBox，默认是false
-- true:使用getCascadeBoundingBox
function Dialog:setCloseRectCascade(cascade)
	self.m_closeRectCascade = cascade
end

function Dialog:onTouch(event)
	-- print("touch", event.name)

	local function ptInNode(node)
		local point = node:getParent():convertToNodeSpace(cc.p(event.x, event.y))

		-- local rect = 
		local rect = nil
		if self.m_closeRectCascade then
			rect = node:getCascadeBoundingBox()
		else
			rect = node:getBoundingBox()
		end

		if cc.rectContainsPoint(rect, point) then
			return true
		else
			return false
		end
	end

	if event.name == "ended" and self.m_bg then
		if self.m_outOfBgClose and not ptInNode(self:getBg()) then
			self:pop(self.m_outOfBgCloseCallback)
		elseif self.m_inOfBgClose and ptInNode(self:getBg()) then
			self:pop(self.m_inOfBgCloseCallback)
		end
	end

	return true
end

function Dialog:pop(popCallback)
	-- 提升层级，遮挡弹出框上按钮
	local node = self:getTouchReceiveNode()
	node:setZOrder(1000000)

	if self.m_enterStyle == UI_ENTER_LEFT_TO_RIGHT then
		self.m_bg:runAction(transition.sequence({cc.EaseBackIn:create(cc.MoveTo:create(0.3, cc.p(-self:getBg():getContentSize().width / 2, self:getBg():getPositionY()))),
			cc.CallFunc:create(function() Dialog.super.pop(self, popCallback) end)}))
	else
		Dialog.super.pop(self, popCallback)
	end
end

return Dialog
