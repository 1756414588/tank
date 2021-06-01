--
-- Author: gf
-- Date: 2015-09-01 14:04:18
--

--------------------------------------------------------------------
-- 军事学堂view
--------------------------------------------------------------------

SCHOOL_VIEW_FOR_UI = 1
SCHOOL_VIEW_FOR_FORMAT = 2 -- 从设置阵型进入

local SchoolView = class("SchoolView", UiNode)

function SchoolView:ctor(buildingId, viewFor, kind)
	viewFor = viewFor or SCHOOL_VIEW_FOR_UI
	self.m_viewFor = viewFor
	self.kind = kind

	if self.m_viewFor == SCHOOL_VIEW_FOR_UI then
		SchoolView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	else
		SchoolView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	end

	self.m_build = BuildMO.queryBuildById(buildingId)
end

function SchoolView:onEnter()
	SchoolView.super.onEnter(self)
	
	self:setTitle(self.m_build.name)

	self:updatePage()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function SchoolView:updatePage(type)
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
		button:setLabel(pages[index])
		button:setPosition(posX, posY - 4)
		-- button:setLabel(pages[index] .. "(" .. #HeroMO.queryHeroByStar(index - 1) .. ")")
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
		local HeroTableView = require("app.scroll.HeroTableView")
		local view = nil

		view = HeroTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 130), index, self.m_viewFor, self.kind):addTo(container)

		if view then
			view:setPosition(0, 120)
			view:reloadData()
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		heroPicBtn = MenuButton.new(normal, selected, nil, handler(self,self.openHeroPicView)):addTo(container)
		heroPicBtn:setPosition(container:getContentSize().width / 2 - 230,70)
		heroPicBtn:setLabel(CommonText[505][1])

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		heroLotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.openLotteryHeroView)):addTo(container)
		heroLotteryBtn:setPosition(container:getContentSize().width / 2 - 75,70)
		heroLotteryBtn:setLabel(CommonText[505][2])

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		heroDecomposeBtn = MenuButton.new(normal, selected, nil, handler(self,self.openBatchDecompose)):addTo(container)
		heroDecomposeBtn:setPosition(container:getContentSize().width / 2 + 75,70)
		heroDecomposeBtn:setLabel(CommonText[505][3])

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		heroImproveBtn = MenuButton.new(normal, selected, nil, handler(self,self.openImproveView)):addTo(container)
		heroImproveBtn:setPosition(container:getContentSize().width / 2 + 230,70)
		heroImproveBtn:setLabel(CommonText[505][4])
	end

	local function clickDelegate(container, index)
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2,
		createDelegate = createDelegate, clickDelegate = clickDelegate, styleDelegates = {createYesBtnCallback = createYesBtnCallback, createNoBtnCallback = createNoBtnCallback}}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView


end

function SchoolView:openHeroPicView()
	ManagerSound.playNormalButtonSound()
	require("app.view.SchoolPicView").new():push()
end

function SchoolView:openLotteryHeroView()
	ManagerSound.playNormalButtonSound()
	require("app.view.LotteryHeroView").new():push()
end

function SchoolView:openBatchDecompose()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_HERO):push()
end

function SchoolView:openImproveView()
	ManagerSound.playNormalButtonSound()
	require("app.view.HeroImproveView").new():push()
end




function SchoolView:onExit()
	-- gprint("SchoolView onExit() ........................")

	-- if self.m_buildHandler then
	-- 	Notify.unregister(self.m_buildHandler)
	-- 	self.m_buildHandler = nil
	-- end
end





return SchoolView