
local CoinButton = class("CoinButton", MenuButton)

function CoinButton:ctor(callback)
	-- 获得金币
	local normal = display.newSprite(IMAGE_COMMON .. "btn_18_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_18_selected.png")
	CoinButton.super.ctor(self, normal, selected, nil, handler(self, self.onCoinCallback))
	self.callback = callback
end

function CoinButton:onEnter()
	local item = display.newSprite(IMAGE_COMMON .. "icon_coin_2.png"):addTo(self) -- UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(self)
	item:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + 10)

	armature_add(IMAGE_ANIMATION .. "effect/ui_home_coin.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_home_coin.plist", IMAGE_ANIMATION .. "effect/ui_home_coin.xml")
	local armature = armature_create("ui_home_coin", item:getContentSize().width / 2 - 5, item:getContentSize().height / 2):addTo(item)
	armature:getAnimation():playWithIndex(0)

	local getCoinLabel = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = self:getContentSize().width- 6, y = 25, align = ui.TEXT_ALIGN_CENTER}):addTo(self)
	getCoinLabel:setAnchorPoint(cc.p(1, 0.5))
	getCoinLabel:setScale(0.85)
	self.coinLabel_ = getCoinLabel

	self.m_resHandler = Notify.register(LOCAL_RES_EVENT, handler(self, self._updateShowCoin))

	self:_updateShowCoin()
end

function CoinButton:onCoinCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- require("app.view.RechargeView").new():push()
	RechargeBO.openRechargeView()
	if self.callback then self.callback() end
end

function CoinButton:_updateShowCoin()
	self.coinLabel_:setString(UserMO.getResource(ITEM_KIND_COIN))
	-- self.coinLabel_:setString(UiUtil.strNumSimplify(UserMO.getResource(ITEM_KIND_COIN)))
end

function CoinButton:onExit()
	if self.m_resHandler then
		Notify.unregister(self.m_resHandler)
		self.m_resHandler = nil
	end
end

-------------------------------------------------------------------

-- 所有UiNode类型的ui的入场方式
UI_ENTER_NONE = 1 -- ui入场无样式
UI_ENTER_BOTTOM_TO_UP = 2 -- ui从底向上入场
UI_ENTER_FADE_IN_GATE = 3 -- ui淡入，并有开门动画
UI_ENTER_LEFT_TO_RIGHT = 4

local UiNode = class("UiNode", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function UiNode:ctor(bgName, enterStyle, param)
	bgName = bgName or ""
	enterStyle = enterStyle or UI_ENTER_NONE
	param = param or {}
	param.x = param.x or display.cx
	param.y = param.y or display.cy

	if param.receiveTouch == nil then param.receiveTouch = true end

	if param.closeBtn == nil then param.closeBtn = true end  -- 是否有关闭返回按钮

	self.m_bgName = bgName
	self._enterStyle_ = enterStyle
	self._param_ = param
	self._full_screen_ = true -- 是否是全屏，覆盖整个屏幕
end

function UiNode:onEnter()
	if self._param_.receiveTouch then
		self:addTouchReceiveNode()
	end

	local bg = nil
	if self.m_bgName == "" then
		bg = display.newNode()
		bg:setContentSize(cc.size(display.width, display.height))
		bg:setAnchorPoint(cc.p(0.5, 0.5))
	elseif self.m_bgName == "image/common/bg_ui.jpg" then
		bg = display.newNode()
		bg:setContentSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
		bg:setAnchorPoint(cc.p(0.5, 0.5))

		local b = display.newSprite(self.m_bgName):addTo(bg)
		b:setScaleY(bg:getContentSize().height / b:getContentSize().height)
		b:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

		local head = display.newSprite("image/common/bg_ui_head.png"):addTo(bg, 3)
		head:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - head:getContentSize().height / 2)

		local btm = display.newSprite("image/common/bg_ui_btm.png"):addTo(bg)
		btm:setPosition(bg:getContentSize().width / 2, btm:getContentSize().height / 2)
	else
		if self._param_.scale9Size then
			bg = display.newScale9Sprite(self.m_bgName)
			bg:setPreferredSize(self._param_.scale9Size)

			if self._param_.scale9Inset then
				bg:setCapInsets(scale9Inset)
			end
		else
			bg = display.newSprite(self.m_bgName)
		end
	end

	bg:addTo(self)
	bg:setPosition(self._param_.x, self._param_.y)

	if self._enterStyle_ == UI_ENTER_FADE_IN_GATE then
		local node = display.newNode():addTo(bg)
		node:setAnchorPoint(cc.p(0.5, 0.5))
		node:setContentSize(bg:getContentSize())
		node:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

		self.m_bg = node
	else
		self.m_bg = bg
	end

	self:hasCloseButton(self._param_.closeBtn)

	if self._enterStyle_ == UI_ENTER_NONE then
		self:onEnterEnd()
	elseif self._enterStyle_ == UI_ENTER_BOTTOM_TO_UP then
		self.m_bg:setPosition(display.cx, -self.m_bg:getContentSize().height / 2)
		self.m_bg:runAction(transition.sequence({cc.MoveTo:create(0.25, cc.p(display.cx, display.cy)), cc.CallFunc:create(function() self:onEnterEnd() end)}))
	elseif self._enterStyle_ == UI_ENTER_FADE_IN_GATE then
		self.m_bg:setCascadeOpacityEnabledRecursively(true)

		local topGate = display.newSprite(IMAGE_COMMON .. "bg_gate_top.png"):addTo(self.m_bg:getParent())
		topGate:setPosition(self.m_bg:getContentSize().width / 2, self.m_bg:getContentSize().height - 100 - 50)
		topGate:runAction(transition.sequence({cc.MoveBy:create(0.2, cc.p(0, 300)),
			cc.MoveBy:create(0.2, cc.p(0, 40)),
			cc.CallFunc:create(function() topGate:removeSelf() end) }))

		local btmGate = display.newSprite(IMAGE_COMMON .. "bg_gate_top.png"):addTo(self.m_bg:getParent())
		btmGate:setScaleY(-1)
		btmGate:setPosition(self.m_bg:getContentSize().width / 2, 100- 50)
		btmGate:runAction(transition.sequence({cc.MoveBy:create(0.2, cc.p(0, -300)),
			cc.MoveBy:create(0.2, cc.p(0, -40)),
			cc.CallFunc:create(function() btmGate:removeSelf() end) }))

		self.m_bg:runAction(transition.sequence({cc.FadeIn:create(0.45), cc.CallFunc:create(function() self:onEnterEnd() end)}))
	end
end

-- 入场结束
function UiNode:onEnterEnd()
	UiDirector.unvisualBottomUi()
end

function UiNode:onExit()
end

-- -- 当前UI从UiDirector中删除
-- function UiNode:removeFromDirector()
-- 	local topName = UiDirector.getTopUiName()
-- 	if topName == "HomeView" then
-- 		gprint("[UiNode] removeFromDirector is HomeView!!! Error!!!")
-- 	end

-- 	if self:getUiName() == topName then
-- 		if not UiDirector.pop() then
-- 			gprint("[UiNode] removeFromDirector remove wrong!!! Error!!! name is:", topName)
-- 		end
-- 	end
-- end

function UiNode:getUiName()
	return self.__cname
end

function UiNode:setTitle(titleName)
	if self.m_titleLabel then
		self.m_titleLabel:removeSelf()
		self.m_titleLabel = nil
	end

	if self.m_bg then
		local title = nil
		if self.m_bgName == "image/common/bg_ui.jpg" then
			if self._enterStyle_ == UI_ENTER_FADE_IN_GATE then
				title = ui.newTTFLabel({text = titleName, font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER,
					x = self.m_bg:getParent():getContentSize().width / 2, y = self.m_bg:getParent():getContentSize().height - 54}):addTo(self.m_bg:getParent(), 5)
			else
				title = ui.newTTFLabel({text = titleName, font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER,
					x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 54}):addTo(self:getBg(), 5)
			end
		elseif self.m_bgName == IMAGE_COMMON .. "bg_dlg_1.png" then
			title = ui.newTTFLabel({text = titleName, font = G_FONT, size = FONT_SIZE_MEDIUM,
				x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
		end
		self.m_titleLabel = title
	end
end

function UiNode:hasCloseButton(has)
	if has then
		if not self.m_returnButton then
			if self.m_bgName == "image/common/bg_ui.jpg" then
				if self._enterStyle_ == UI_ENTER_FADE_IN_GATE then
					local normal = display.newSprite(IMAGE_COMMON .. "btn_return_normal.png")
					local selected = display.newSprite(IMAGE_COMMON .. "btn_return_selected.png")
					local returnButton = MenuButton.new(normal, selected, nil, handler(self, self.onReturnCallback)):addTo(self.m_bg:getParent(), 10)
					returnButton:setPosition(self.m_bg:getParent():getContentSize().width / 2 - 270, self.m_bg:getParent():getContentSize().height - 56)
					self.m_returnButton = returnButton
				else
					local normal = display.newSprite(IMAGE_COMMON .. "btn_return_normal.png")
					local selected = display.newSprite(IMAGE_COMMON .. "btn_return_selected.png")
					local returnButton = MenuButton.new(normal, selected, nil, handler(self, self.onReturnCallback)):addTo(self.m_bg, 5)
					returnButton:setPosition(self.m_bg:getContentSize().width / 2 - 270, self.m_bg:getContentSize().height - 56)
					self.m_returnButton = returnButton
				end
			else
				local normal = display.newSprite(IMAGE_COMMON .. "btn_return_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_return_selected.png")
				local returnButton = MenuButton.new(normal, selected, nil, handler(self, self.onReturnCallback)):addTo(self.m_bg, 5)
				returnButton:setPosition(self.m_bg:getContentSize().width / 2 - 270, self.m_bg:getContentSize().height - 56)
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

function UiNode:getCloseButton()
	return self.m_returnButton
end

function UiNode:hasCoinButton(has,callback)
	if has then
		if not self.m_coinButton then
			local button = CoinButton.new(callback)
			-- if self.m_bgName == "image/common/bg_ui.jpg" then
				button:addTo(self:getBg():getParent(), 1000)
			-- else
				-- button:addTo(self:getBg(), 100)
			-- end
			button:setPosition(display.cx +  self.m_bg:getContentSize().width / 2 - button:getContentSize().width / 2, self.m_bg:getContentSize().height - button:getContentSize().height / 2)
			self.m_coinButton = button
		end
	else
		if self.m_coinButton then
			self.m_coinButton:removeSelf()
			self.m_coinButton = nil
		end
	end
end

function UiNode:getCoinButton()
	return self.m_coinButton
end

-- function UiNode:_updateShowCoin()
-- 	if self.m_coinLabel then
-- 		self.m_coinLabel:setString(str)
-- 	end
-- end

-- 在每个ui的最下层添加一个node来接受所有的touch事件，避免点击了下层ui
function UiNode:addTouchReceiveNode()
	local touchNode = display.newNode():addTo(self, -1000)
	touchNode:setContentSize(cc.size(display.width, display.height))
	nodeTouchEventProtocol(touchNode, function() end, nil, nil, true)
	self.m_touchNode = touchNode
end

function UiNode:deleteTouchReceiveNode()
	if self.m_touchNode then
		self.m_touchNode:removeSelf()
		self.m_touchNode = nil
	end
end

function UiNode:getTouchReceiveNode()
	return self.m_touchNode
end

function UiNode:onReturnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- error("UiNode:onReturnCallback() - inherited class must override this method")
	self:CloseAndCallback()
	self:pop()
end

function UiNode:push()
	UiDirector.push(self, self:getUiName())
	return self
end

function UiNode:pop(popCallback)
	local name = UiDirector.getTopUiName()
	if name == self:getUiName() then
		return UiDirector.pop(popCallback)
	else
		gprint("[UiNode] pop Error! name:", name)
	end
end

-- 关闭并回调 --重载
function UiNode:CloseAndCallback()
	-- body
end

-- function UiNode:getName()
-- 	return self.__cname
-- end

function UiNode:getBg()
	return self.m_bg
end

function UiNode:ShowBlackShade()
	local blackShade = display.newColorLayer(ccc4(0, 0, 0, 255)):addTo(self, -99)
	blackShade:setContentSize(cc.size(display.width, display.height))
	blackShade:setPosition(0, 0)
	return self
end

return UiNode