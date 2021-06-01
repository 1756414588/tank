
-- 积分兑换

local ScoreShopView = class("ScoreShopView", UiNode)

function ScoreShopView:ctor(uiEnter)
	ScoreShopView.super.ctor(self, "image/common/bg_ui.jpg")
end

function ScoreShopView:onEnter()
	ScoreShopView.super.onEnter(self)

	self:setTitle(CommonText[254])

	self.m_updateHandler = Notify.register(LOCAL_SCORE_EVENT, handler(self, self.onScoreUpdate))

	local function createDelegate(container, index)
		if index == 1 then  -- 
			self:showFight(container)
		elseif index == 2 then -- 执行任务
			self:showRes(container)
		elseif index == 3 then -- 坦克修复
			self:showGrow(container)
		end
	end

	local function clickDelegate(container, index)
	end

	--  "战斗", "资源", "成长"
	local pages = {CommonText[265], CommonText[153], CommonText[266]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function ScoreShopView:onExit()
	ScoreShopView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end

function ScoreShopView:showFight(container)
	-- 我的积分
	local label = ui.newTTFLabel({text = CommonText[293] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 60, y = container:getContentSize().height - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.arenaScore_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local ScoreTableView = require("app.scroll.ScoreTableView")
	local view = ScoreTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70), VIEW_FOR_FIGHT):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function ScoreShopView:showRes(container)
	-- 我的积分
	local label = ui.newTTFLabel({text = CommonText[293] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 60, y = container:getContentSize().height - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.arenaScore_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local ScoreTableView = require("app.scroll.ScoreTableView")
	local view = ScoreTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70), VIEW_FOR_RESOURCE):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function ScoreShopView:showGrow(container)
	-- 我的积分
	local label = ui.newTTFLabel({text = CommonText[293] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 60, y = container:getContentSize().height - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.arenaScore_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local ScoreTableView = require("app.scroll.ScoreTableView")
	local view = ScoreTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 70), VIEW_FOR_GROWN):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function ScoreShopView:onScoreUpdate(event)
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

return ScoreShopView
