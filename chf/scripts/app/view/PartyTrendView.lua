--
-- Author: gf
-- Date: 2015-09-16 18:03:02
-- 军团军情界面

local PartyTrendView = class("PartyTrendView", UiNode)

function PartyTrendView:ctor(buildingId)
	PartyTrendView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyTrendView:onEnter()
	PartyTrendView.super.onEnter(self)

	self:setTitle(CommonText[617])

	local function createDelegate(container, index)
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
		bg:setPreferredSize(cc.size(container:getContentSize().width, container:getContentSize().height - 20))
		bg:setCapInsets(cc.rect(80, 60, 1, 1))
		bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)

		local posX = {44,260,540}
		for index=1,#CommonText[619] do
			local name = ui.newTTFLabel({text = CommonText[619][index], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = posX[index], y = bg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			name:setAnchorPoint(cc.p(0, 0.5))
		end

		Loading.getInstance():show()
		PartyBO.asynGetPartyTrend(function()
			Loading.getInstance():unshow()
			local PartyTrendTableView = require("app.scroll.PartyTrendTableView")
			local view = PartyTrendTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height - 70),index):addTo(bg)
			view:setPosition(0, 25)
			view:reloadData()
			local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(container)
			line:setPreferredSize(cc.size(view:getContentSize().width, line:getContentSize().height))
			line:setPosition(container:getContentSize().width / 2, view:getPositionY())
			end, 0,index)
	end

	local function clickDelegate(container, index)

	end

	local pages = {CommonText[618][1],CommonText[618][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end


return PartyTrendView