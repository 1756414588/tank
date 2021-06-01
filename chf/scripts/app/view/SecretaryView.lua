
-- 秘书view

local SecretaryView = class("SecretaryView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function SecretaryView:ctor()
	local function onSecretaryCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local SecretaryDialog = require("app.dialog.SecretaryDialog")
		SecretaryDialog.new():push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "icon_secretary.png")
	local selected = display.newSprite(IMAGE_COMMON .. "icon_secretary.png")
	local btn = MenuButton.new(normal, selected, nil, onSecretaryCallback):addTo(self)
	btn:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	self:setContentSize(cc.size(btn:getContentSize().width, btn:getContentSize().height))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	btn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(1.8, 1.3), cc.ScaleTo:create(2.2, 1)})))
end

function SecretaryView:onEnter()
	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onUpdateTip))

	-- 野外有空地可建造
	local tip = SecretaryBO.getWildTip()
	gdump(tip, "SecretaryView:onEnter")
	if tip then
		self:showWildTip(tip)
	end
end

function SecretaryView:onExit()
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function SecretaryView:showWildTip(tip)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_58.png"):addTo(self)
	bg:setCapInsets(cc.rect(24, 12, 1, 1))
	bg:setPreferredSize(cc.size(174, 60))
	bg:setPosition(80 + bg:getContentSize().width / 2, bg:getContentSize().height + 10)
	self.m_wildNode = bg

	-- 野外有空地
	local desc = ui.newTTFLabel({text = CommonText[490][1], font = G_FONT, size = FONT_SIZE_TINY, x = bg:getContentSize().width / 2, y = bg:getContentSize().height - 15, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	local btn = LabelButton.new({text = CommonText[490][2], color = COLOR[2], size = FONT_SIZE_TINY}, handler(self, self.onSkipCallback)):addTo(bg)
	btn:setPosition(40, 20)
	btn.tip = tip
	self.m_wildIngoreBtn = btn

	local btn = LabelButton.new({text = CommonText[490][3], color = COLOR[2], size = FONT_SIZE_TINY}, handler(self, self.onBuildCallback)):addTo(bg)
	btn:setPosition(bg:getContentSize().width - 40, 20)
	btn.tip = tip
	self.m_wildBuildBtn = btn
end

function SecretaryView:onSkipCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	SecretaryBO.ingoreAllWildTip()
	
	if self.m_wildNode then
		self.m_wildNode:removeSelf()
		self.m_wildNode = nil
	end
end

function SecretaryView:onBuildCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local tip = sender.tip
	tip.ingore = true

	local config = clone(HomeIndicatorWildConifg)
	config.step[1].wildPos = tip.pos

	local IndicatorView = require("app.view.IndicatorView")
	local view = IndicatorView.new(config)
	display.getRunningScene():addChild(view, 999999999)
end


-- function SecretaryView:onSecretaryCallback(tag, sender)
-- 	local SecretaryDialog = require("app.dialog.SecretaryDialog")
-- 	SecretaryDialog.new():push()
-- end

function SecretaryView:onUpdateTip()
	-- 野外有空地可建造
	local tip = SecretaryBO.getWildTip()
	gdump(tip, "SecretaryView:onUpdateTip")
	if tip then
		if not self.m_wildNode then
			self:showWildTip(tip)
		end
		-- self.m_wildIngoreBtn.tip = tip
		-- self.m_wildBuildBtn.tip = tip
	end
end

return SecretaryView
