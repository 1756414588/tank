--
-- Author: xiaoxing
-- Date: 2017-02-05 10:06:50
--
local ActivityFestival = class("ActivityFestival", UiNode)
local PAGE = {"ActivityFestivalPage1","ActivityFestivalPage2"}
function ActivityFestival:ctor(activity,viewFor)
	self.m_viewFor = viewFor or 1
	self.activity = activity
	ActivityFestival.super.ctor(self, "image/common/bg_ui.jpg")
end

function ActivityFestival:onEnter()
	ActivityFestival.super.onEnter(self)

	self.m_dayPayHandler = Notify.register("FESTIVAL_PAY", handler(self, self.refresh))
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
	local pages = CommonText[1066]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	pageView:setPageIndex(self.m_viewFor)
end

function ActivityFestival:refresh()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function ActivityFestival:refreshUI()
	if self.m_pageView:getPageIndex() == 2 then
		self.view:updateInfo()
	end
end

function ActivityFestival:onExit()
	if self.m_dayPayHandler then
		Notify.unregister(self.m_dayPayHandler)
		self.m_dayPayHandler = nil
	end
end

return ActivityFestival