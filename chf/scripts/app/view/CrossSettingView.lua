--
-- Author: Xiaohang
-- Date: 2016-09-22 16:24:32
--
local CrossSettingView = class("CrossSettingView", UiNode)

function CrossSettingView:ctor(kind)
	self.kind = kind or 1
	self.m_pageIndex = pageIndex or 1
	CrossSettingView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function CrossSettingView:onEnter()
	CrossSettingView.super.onEnter(self)
	self:setTitle(CommonText[12])
	if self.kind == 1 then
		CrossBO.getFormation(handler(self, self.show))
	elseif self.kind == 2 then
		CrossPartyBO.getFormation(handler(self, self.show))
	end
end

function CrossSettingView:show()

	local function createDelegate(container, index)
		container:removeAllChildren()
		self:showSettingArmy(container,index)
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[15].."1",CommonText[15].."2",CommonText[15].."3"}
	if self.kind == 2 then
		pages = {CommonText[15]}
	end
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function CrossSettingView:showSettingArmy(container,index)
	local ArmySettingView = require("app.view.ArmySettingView")
	local armySettingFor = ARMY_SETTING_FOR_CROSS-1 + index
	if self.kind == 2 then
		armySettingFor = ARMY_SETTING_FOR_CROSSPARTY
	end
	local view = ArmySettingView.new(container:getContentSize(), armySettingFor):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

return CrossSettingView
