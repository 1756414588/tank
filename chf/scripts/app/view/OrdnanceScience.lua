--
-- Author: Xiaohang
-- Date: 2016-05-04 10:56:56
--

-- 军工科技树
local OrdnanceScience = class("OrdnanceScience", UiNode)

ORDNANCE_VIEW_TREE   = 1  --科技树
ORDNANCE_VIEW_ADAPT  = 2  --装配
local PAGE = {"OrdnanceTree","OrdnanceSet"}

function OrdnanceScience:ctor(uiEnter, viewFor, tankId)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	viewFor = viewFor or ORDNANCE_VIEW_TREE
	self.tankId = tankId
	self.m_viewFor = viewFor
	OrdnanceScience.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function OrdnanceScience:onEnter()
	OrdnanceScience.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[917])
	local function createDelegate(container, index)
		container:removeAllChildren()
		local page = require("app.view."..PAGE[index])
		local view = page.new(container:width(), container:height(),self.tankId):addTo(container)
		view:setPosition(0, 0)
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[925][1], CommonText[925][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

return OrdnanceScience