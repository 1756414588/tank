--
-- Author: Xiaohang
-- Date: 2016-04-29 09:48:09

-- 军工科技view
local OrdnanceView = class("OrdnanceView", UiNode)

ORDNANCE_VIEW_STUDY = 1  --研发
ORDNANCE_VIEW_PROP  = 2  --材料
ORDNANCE_VIEW_ADAPT = 3  --改装

function OrdnanceView:ctor(uiEnter, viewFor)
	uiEnter = uiEnter or UI_ENTER_FADE_IN_GATE
	viewFor = viewFor or ORDNANCE_VIEW_STUDY
	self.m_viewFor = viewFor
	OrdnanceView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function OrdnanceView:onEnter()
	OrdnanceView.super.onEnter(self)
	-- 部队
	self:setTitle(CommonText[917])
	local function createDelegate(container, index)
		if index == 1 then  -- 详情
			if not OrdnanceBO.getProp() then
				Loading.getInstance():show()
				OrdnanceBO.updateProp(function()
						Loading.getInstance():unshow()
						self:showStudy(container)
					end)
			else
				self:showStudy(container)
			end
		elseif index == 2 then -- 技能
			self:showProp(container)
		elseif index == 3 then -- 头像
			self:showAdapt(container)
		end
	end

	local function clickDelegate(container, index)
	end
	local pages = {CommonText[918], CommonText[165], CommonText[919]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete=true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end

function OrdnanceView:onExit()
	-- body
	if self.view.onExit then
		self.view:onExit()
	end
end

function OrdnanceView:showStudy(container)
	container:removeAllChildren()
	local OrdnanceStudy = require("app.view.OrdnanceStudy")
	self.view = OrdnanceStudy.new(container:width(), container:height()):addTo(container)
	self.view:setPosition(0, 0)
	if self.view.onEnter then
		self.view:onEnter()
	end
end

function OrdnanceView:showProp(container)
	container:removeAllChildren()
	local OrdanceProp = require("app.view.OrdnanceProp")
	self.view = OrdanceProp.new(container:width(), container:height()):addTo(container)
end

function OrdnanceView:showAdapt(container)
	container:removeAllChildren()
	local OrdnanceAdapt = require("app.view.OrdnanceAdapt")
	self.view = OrdnanceAdapt.new(cc.size(container:width(), container:height()-10)):addTo(container)
	self.view:setPosition(0, 0)
end

function OrdnanceView:refreshUI()
	if self.view and self.view.refreshUI then
		self.view:refreshUI()
	end
end

return OrdnanceView