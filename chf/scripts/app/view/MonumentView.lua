--
-- Author: Xiaohang
-- Date: 2016-05-07 15:18:51
--
-- 丰碑
local MonumentView = class("MonumentView", UiNode)
local PAGE = {"RankArmy","RankScore","RankRecord"} 
function MonumentView:ctor(uiEnter, viewFor)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	MonumentView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function MonumentView:onEnter()
	MonumentView.super.onEnter(self)
	self:setTitle(CommonText[20027])
	local function createDelegate(container, index)
		container:removeAllChildren()
		local page = require("app.view."..PAGE[index])
		local view = page.new(container:width(), container:height()):addTo(container)
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[802][2],CommonText[20028],CommonText[20029]}
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

return MonumentView