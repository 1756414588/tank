--
-- Author: Xiaohang
-- Date: 2016-08-09 15:51:34
--
local StrongholdView = class("StrongholdView", UiNode)

ORDNANCE_VIEW_ARMY   = 1  --驻军
ORDNANCE_VIEW_REPORT = 2  --报告
ORDNANCE_VIEW_RANK   = 3  --百行

function StrongholdView:ctor(uiEnter, kind, viewFor)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or ORDNANCE_VIEW_ARMY
	self.kind = kind
	self.m_viewFor = viewFor
	StrongholdView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function StrongholdView:onEnter()
	StrongholdView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[20067][self.kind]..CommonText[20081])
	local function createDelegate(container, index)
		if index == 1 then  
			self:showArmy(container)
		elseif index == 2 then 
			self:showReport(container)
		elseif index == 3 then 
			self:showRank(container)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[12], CommonText[20024], CommonText[268]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function StrongholdView:showReport(container)
	container:removeAllChildren()
	local StrongholdReport = require("app.view.StrongholdReport")
	self.view = StrongholdReport.new(container:width(), container:height(), self.kind):addTo(container)
	self.view:setPosition(0, 0)
end

function StrongholdView:showArmy(container)
	container:removeAllChildren()
	ExerciseBO.getArmy(function()
		local ArmySettingView = require("app.view.ArmySettingView")
		local armySettingFor = self.kind + 100
		local view = ArmySettingView.new(container:getContentSize(), armySettingFor):addTo(container)
		view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
		end)
end

function StrongholdView:showRank(container)
	container:removeAllChildren()
	local StrongholdRank = require("app.view.StrongholdRank")
	self.view = StrongholdRank.new(container:width(), container:height(), self.kind):addTo(container)
	self.view:setPosition(0, 0)
end

function StrongholdView:refreshUI()
	if self.view and self.view.refreshUI then
		self.view:refreshUI()
	end
end

return StrongholdView