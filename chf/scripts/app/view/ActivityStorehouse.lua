--
-- Author: xiaoxing
-- Date: 2016-12-03 10:25:10
--
local ActivityStorehouse = class("ActivityStorehouse", UiNode)
local PAGE = {"ActivityStorehousePage1","ActivityStorehousePage2","ActivityStorehousePage3"}
function ActivityStorehouse:ctor(activity,viewFor)
	self.m_viewFor = viewFor or 1
	self.activity = activity
	ActivityStorehouse.super.ctor(self, "image/common/bg_ui.jpg")
end

function ActivityStorehouse:onEnter()
	ActivityStorehouse.super.onEnter(self)
	self:hasCoinButton(true)
	-- 部队
	self:setTitle(self.activity.name)
	local function createDelegate(container, index)
		local view = require("app.view."..PAGE[index])
		self.view = view.new(container:width(), container:height(), self.activity):addTo(container)
		self.view:setPosition(0, 0)
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[20157][1],CommonText[20157][2],CommonText[774][2]}
	if self.activity.endTime - ManagerTimer.getTime() <= 0 then
		PAGE = {"ActivityStorehousePage3"}
		pages = {CommonText[774][2]}
	end
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	pageView:setPageIndex(self.m_viewFor)
end

return ActivityStorehouse