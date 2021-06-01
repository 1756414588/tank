--
-- Author: xiaoxing
-- Date: 2016-11-23 17:18:37
--
-- 跨服战view
local CrossPartyView = class("CrossPartyView", UiNode)

local PAGE = {"CrossPartyTeam","CrossPartyMy","CrossPartyFinal","CrossPartyRank"}

function CrossPartyView:ctor(uiEnter, viewFor)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	CrossPartyView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	self:setNodeEventEnabled(true)
end

function CrossPartyView:onEnter()
	CrossPartyView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[30060])
	local function createDelegate(container, index)
		local view = require_ex("app.view."..PAGE[index])
		self.view = view.new(container:width(), container:height()):addTo(container)
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[30061][1],CommonText[30061][2],CommonText[30061][3],CommonText[268]}
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function CrossPartyView:showTeam(container)
	container:removeAllChildren()
	local CrossPartyTeam = require_ex("app.view.CrossPartyTeam")
	local view = CrossPartyTeam.new(container:width(), container:height()):addTo(container)
	self.view = view
end

return CrossPartyView