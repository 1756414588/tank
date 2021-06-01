--
-- Author: Xiaohang
-- Date: 2016-05-17 17:08:50
--
-- 跨服战view
local CrossView = class("CrossView", UiNode)

CROSS_VIEW_SCORE = 1  --积分赛
CROSS_VIEW_OUT   = 2  --淘汰赛 
CROSS_VIEW_FINAL = 3  --总决赛
CROSS_VIEW_RANK  = 4  --排行
function CrossView:ctor(uiEnter, viewFor, type)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or CROSS_VIEW_SCORE
	self.m_viewFor = viewFor
	self.type = type or 1
	if self.type == 0 then
		self.type = 1
	end
	CrossView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function CrossView:onEnter()
	CrossView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[30011] .."-" ..CommonText[30012][self.type])
	local function createDelegate(container, index)
		if index == 1 then  
			self:showScore(container)
		elseif index == 2 then 
			self:showOut(container)
		elseif index == 3 then 
			self:showFinal(container)
		elseif index == 4 then
			self:showRank(container)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[30022][1],CommonText[30022][2],CommonText[30022][3],CommonText[268]}
	local size = cc.size(display.width - 12, display.height - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = display.cx, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function CrossView:showScore(container)
	container:removeAllChildren()
	local CrossScore = require("app.view.CrossScore")
	local view = CrossScore.new(container:width(), container:height(),self.type):addTo(container)
end

function CrossView:showOut(container)
	container:removeAllChildren()
	local CrossOut = require("app.view.CrossOut")
	local view = CrossOut.new(container:width(), container:height(),self.type):addTo(container)
end

function CrossView:showFinal(container)
	container:removeAllChildren()
	local CrossFinal = require("app.view.CrossFinal")
	local view = CrossFinal.new(container:width(), container:height(),self.type):addTo(container)
end

function CrossView:showRank(container)
	container:removeAllChildren()
	local CrossRank = require("app.view.CrossRank")
	local view = CrossRank.new(container:width(), container:height(),self.type):addTo(container)
end

return CrossView