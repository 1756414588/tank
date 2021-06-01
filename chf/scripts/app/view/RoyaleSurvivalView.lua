--
-- Author: heyunlong
-- Date: 2018-7-17 11:19:52
-- 荣耀生存

local RoyaleSurvivalView = class("RoyaleSurvivalView", UiNode)

function RoyaleSurvivalView:ctor(viewFor, pageIndex)
	RoyaleSurvivalView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor or 1
	self.m_pageIndex = pageIndex
end

function RoyaleSurvivalView:onEnter()
	RoyaleSurvivalView.super.onEnter(self)

	armature_add("animation/royale/poison_display.pvr.ccz", "animation/royale/poison_display.plist", "animation/royale/poison_display.xml")

	self:setTitle(CommonText[2100])

	local function createDelegate(container, index)
		if index == 1 then
			self:showManual(container)
		elseif index == 2 then
			self:showRank(container)
		elseif index == 3 then
			RoyaleSurviveBO.getHonourGoldInfo(function (data)
				self:showCoin(container, data)
			end)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = CommonText[2101]

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	if self.m_pageIndex then
		self.m_pageView:setPageIndex(self.m_pageIndex)
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function RoyaleSurvivalView:updateView()
end

function RoyaleSurvivalView:onExit()
	armature_remove("animation/royale/poison_display.pvr.ccz", "animation/royale/poison_display.plist", "animation/royale/poison_display.xml")
	RoyaleSurvivalView.super.onExit(self)
end

function RoyaleSurvivalView:showRank(container)
	-- body
	container:removeAllChildren()
	local RoyaleRankView = require("app.view.RoyaleRankView")
	self.view = RoyaleRankView.new(container:width(), container:height()):addTo(container)
	self.view:setPosition(0, 0)
end

function RoyaleSurvivalView:showCoin(container, data)
	container:removeAllChildren()
	local RoyaleCoinView = require("app.view.RoyaleCoinView")
	self.view = RoyaleCoinView.new(container:width(), container:height(), data):addTo(container)
	self.view:setPosition(0, 0)
end

function RoyaleSurvivalView:showManual(container)
	-- body
	container:removeAllChildren()

	local showPic = display.newScale9Sprite(IMAGE_COMMON .. "royale_survive/show_pic.jpg"):addTo(container)
	showPic:setPosition(self:getBg():width() / 2, self:getBg():height() - showPic:height() / 2 - 200)

	local effect = armature_create("poison_display", self:getBg():width() / 2 - 20, self:getBg():height() - showPic:height() / 2 - 150)
	effect:addTo(container)
	effect:getAnimation():playWithIndex(0)
	effect:setOpacity(120)

	local frame = display.newScale9Sprite(IMAGE_COMMON .. "royale_survive/frame.png"):addTo(container)
	frame:setPosition(self:getBg():width() / 2, self:getBg():height() - frame:height() / 2 - 180)

	local title = UiUtil.label(CommonText[2104][1]):addTo(container)
	title:setPosition(self:getBg():width() / 2, self:getBg():height() - frame:height() - 135)

	local title1 = UiUtil.label(CommonText[2104][2]):addTo(container)
	title1:setPosition(self:getBg():width() / 2, self:getBg():height() - 205)

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.royaleSurviveDetail):push()
	end
	local btnDetail = UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil, gotoDetail):addTo(container)
	btnDetail:setPosition(self:getBg():width() - btnDetail:width()/2 - 5, self:getBg():height() - 215)


	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local rechargeBtn = MenuButton.new(normal, selected, nil, function ()
		if RoyaleSurviveMO.isActOpen() then
			UiDirector.popMakeUiTop("HomeView")
			UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
			UiDirector.getTopUi():getCurContainer():onLocate(WorldMO.pos_.x, WorldMO.pos_.y)
		else
			Toast.show("未到活动开启时间")
		end
	end):addTo(container)
	rechargeBtn:setPosition(self:getBg():width() / 2, 100)
	rechargeBtn:setLabel(CommonText[2103])
end

return RoyaleSurvivalView
