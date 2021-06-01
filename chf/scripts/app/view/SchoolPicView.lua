--
-- Author: gf
-- Date: 2015-09-01 16:36:05
--

--------------------------------------------------------------------
-- 将领图鉴view
--------------------------------------------------------------------

local SchoolPicView = class("SchoolPicView", UiNode)

function SchoolPicView:ctor(buildingId)
	SchoolPicView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)

end

function SchoolPicView:onEnter()
	SchoolPicView.super.onEnter(self)

	self:setTitle(CommonText[506])

	self:updatePage()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function SchoolPicView:updatePage(type)
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)

	local pages = {CommonText[504],"","","","",""}
	

	local function createYesBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 105
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newSprite(IMAGE_COMMON .. "btn_14_selected.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_14_selected.png")
		button = MenuButton.new(normal, selected, nil, nil)
		button:setPosition(posX, posY - 4)
		button:setLabel(pages[index])
		-- button:setLabel(pages[index] .. "(" .. #HeroMO.queryHeroPicByStar(index - 1) .. ")")
		-- button.m_label:setFontSize(FONT_SIZE_SMALL)
		-- if index == 1 then
		-- 	button.m_label:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)
		-- else
		-- 	button.m_label:setPosition(button:getContentSize().width / 2 + 20,button:getContentSize().height / 2)
		-- end
		
		local starPic
		if index > 1 then
			-- starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. (index - 1) .. ".png", button:getContentSize().width / 2 - 20,button:getContentSize().height / 2):addTo(button)
			starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. (index - 1) .. ".png", button:getContentSize().width / 2,button:getContentSize().height / 2):addTo(button)
		end
		return button
	end

	local function createNoBtnCallback(index)
		local button = nil

		local startPosX = 0
		local posXDelta = 0
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		startPosX = sprite:getContentSize().width / 2
		posXDelta = 105
		local posY = size.height + 22
		local posX = startPosX + (index - 1) * posXDelta

		local normal = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_14_normal.png")
		button = MenuButton.new(normal, selected, nil, nil)
		button:setPosition(posX, posY)
		button:setLabel(pages[index], {color = COLOR[11]})
		local starPic
		if index > 1 then
			starPic = display.newSprite(IMAGE_COMMON .. "hero_star_" .. (index - 1) .. ".png",button:getContentSize().width / 2,button:getContentSize().height / 2):addTo(button)
		end

		return button
	end

	local function createDelegate(container, index)
		local HeroPicTableView = require("app.scroll.HeroPicTableView")
		local view = nil

		view = HeroPicTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), index):addTo(container)

		if view then
			view:setPosition(0, 0)
			view:reloadData()
		end
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView


end


function SchoolPicView:onExit()

end




return SchoolPicView