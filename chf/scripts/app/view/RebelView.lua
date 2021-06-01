--
-- Author: Xiaohang
-- Date: 2016-09-06 14:32:06
--
local RebelView = class("RebelView", UiNode)

function RebelView:ctor(uiEnter, viewFor, index)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or 1
	self.m_viewFor = viewFor
	self.index = index
	RebelView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function RebelView:onEnter()
	RebelView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[20114])
	local function createDelegate(container, index)
		if index == 1 then  
			self:showInfo(container)
		elseif index == 2 then 
			self:showRankWeek(container)
		elseif index == 3 then 
			self:showRankAll(container)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = CommonText[20131]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	RebelBO.getInfo(function()
			pageView:setPageIndex(self.m_viewFor)
		end)
end

function RebelView:showInfo(container)
	container:removeAllChildren()
	local RebelInfo = require("app.view.RebelInfo")
	self.view = RebelInfo.new(container:width(), container:height(), self.index):addTo(container)
	self.view:setPosition(0, 0)
end

function RebelView:showRankWeek(container)
	container:removeAllChildren()
	local RebelRankWeek = require("app.view.RebelRankWeek")
	self.view = RebelRankWeek.new(container:width(), container:height()):addTo(container)
	self.view:setPosition(0, 0)
end

function RebelView:showRankAll(container)
	container:removeAllChildren()
	local RebelRankAll = require("app.view.RebelRankAll")
	self.view = RebelRankAll.new(container:width(), container:height()):addTo(container)
	self.view:setPosition(0, 0)
end

function RebelView:refreshUI()
	if self.view and self.view.refreshUI then
		self.view:refreshUI()
	end
end

return RebelView