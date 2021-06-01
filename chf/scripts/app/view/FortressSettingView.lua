--
-- Author: Xiaohang
-- Date: 2016-06-27 12:01:19
--
local FortressSettingView = class("FortressSettingView", UiNode)

function FortressSettingView:ctor(viewFor)
	self.m_pageIndex = 1
	self.viewFor = viewFor or ARMY_SETTING_FORTRESS
	FortressSettingView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function FortressSettingView:onEnter()
	FortressSettingView.super.onEnter(self)
	self:setTitle(self.viewFor == ARMY_SETTING_FORTRESS and CommonText[20005] or CommonText[1000][2])

	local function createDelegate(container, index)
		if index == 1 then  -- 设置部队
			self:showSettingArmy(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[12]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function FortressSettingView:showSettingArmy(container)
	local ArmySettingView = require("app.view.ArmySettingView")
	
	local armySettingFor = self.viewFor
	local view = ArmySettingView.new(container:getContentSize(), armySettingFor):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

return FortressSettingView
