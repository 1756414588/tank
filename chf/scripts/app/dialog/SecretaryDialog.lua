

local Dialog = require("app.dialog.Dialog")
local SecretaryDialog = class("SecretaryDialog", Dialog)

function SecretaryDialog:ctor()
	SecretaryDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_2.png", UI_ENTER_NONE, {scale9Size = cc.size(550, 230), alpha = 0})
end

function SecretaryDialog:onEnter()
	SecretaryDialog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:showUI()
end

function SecretaryDialog:showUI()
	self:getBg():setPositionY(display.cy + 50)

	local node = display.newNode():addTo(self:getBg())
	node:setContentSize(self:getBg():getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	self.m_container = node

	local npc = display.newSprite(IMAGE_COMMON .. "guide/role_1.png"):addTo(self:getBg())
	npc:setPosition(npc:getContentSize().width / 2 + 15, self:getBg():getContentSize().height + npc:getContentSize().height / 2 - 10)

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_5.png"):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 10)

	local name = ui.newTTFLabel({text = CommonText[487][1], font = G_FONT, size = FONT_SIZE_SMALL, x = bg:getContentSize().width / 2, y = bg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	self.m_titleLabel = name

	local desc = ui.newTTFLabel({text = CommonText[487][2], font = G_FONT, size = FONT_SIZE_SMALL, x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 45, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(237, 169, 6)}):addTo(self:getBg())

	-- 我想发展
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
	btn:setPosition(self.m_container:getContentSize().width / 2 - 120, 140)
	btn:setLabel(CommonText[488][1])
	btn.index = 1

	-- 我要变强
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
	btn:setPosition(self.m_container:getContentSize().width / 2 + 120, 140)
	btn:setLabel(CommonText[488][2])
	btn.index = 2

	-- 我很无聊
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
	btn:setPosition(self.m_container:getContentSize().width / 2 - 120, 60)
	btn:setLabel(CommonText[488][3])
	btn.index = 3

	-- 我想爽爽
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.showSecondaryUi)):addTo(self.m_container)
	btn:setPosition(self.m_container:getContentSize().width / 2 + 120, 60)
	btn:setLabel(CommonText[488][4])
	btn.index = 4
end

function SecretaryDialog:showSecondaryUi(tag, sender)
	local index = sender.index

	self.m_titleLabel:setString(CommonText[488][index])

	self.m_container:removeAllChildren()

	for idx = 1, 6 do
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local btn = MenuButton.new(normal, selected, nil, handler(self, self.onGuideCallback)):addTo(self.m_container)
		btn:setLabel(CommonText[489][index][idx])
		btn.index = index
		btn.secondaryIndex = idx

		local x, y
		if idx == 1 or idx == 4 then x = self.m_container:getContentSize().width / 2 - 160
		elseif idx == 2 or idx == 5 then x = self.m_container:getContentSize().width / 2
		else x = self.m_container:getContentSize().width / 2 + 160
		end

		if idx == 1 or idx == 2 or idx == 3 then y = 140 else y = 60 end

		btn:setPosition(x, y)
	end
end

function SecretaryDialog:onGuideCallback(tag, sender)
	local index = sender.index
	local secondaryIndex = sender.secondaryIndex

	gprint("SecretaryDialog==> index:", index, "secondaryIndex:", secondaryIndex)

	self:pop()

	if index == 1 then  -- 我想发展
		local IndicatorView = require("app.view.IndicatorView")
		local view = IndicatorView.new(HomeIndicatorConifg[secondaryIndex])
		display.getRunningScene():addChild(view, 999999999,999)
	elseif index == 2 then  -- 我要变强
		local IndicatorView = require("app.view.IndicatorView")
		local view = IndicatorView.new(HomeIndicatorConifg[secondaryIndex + 6])
		display.getRunningScene():addChild(view, 999999999,999)
	elseif index == 3 then  -- 我很无聊
		local IndicatorView = require("app.view.IndicatorView")
		local view = IndicatorView.new(HomeIndicatorConifg[secondaryIndex + 12])
		display.getRunningScene():addChild(view, 999999999,999)
	elseif index == 4 then  -- 我想爽爽
		local IndicatorView = require("app.view.IndicatorView")
		local view = IndicatorView.new(HomeIndicatorConifg[secondaryIndex + 18])
		display.getRunningScene():addChild(view, 999999999,999)
	end

end

return SecretaryDialog