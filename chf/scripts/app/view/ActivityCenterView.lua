--
-- Author: gf
-- Date: 2015-10-29 11:19:52
-- 活动中心

local ActivityCenterView = class("ActivityCenterView", UiNode)

function ActivityCenterView:ctor(viewFor)
	ActivityCenterView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewFor = viewFor or 1
end

function ActivityCenterView:onEnter()
	ActivityCenterView.super.onEnter(self)

	self:setTitle(CommonText[725])

	ActivityCenterMO.showTip = true
	Notify.notify(LOCLA_ACTIVITY_CENTER_EVENT)

	local function createDelegate(container, index)
		if #ActivityCenterMO.activityList_ > 0 then
			if index == 1 then  
				self:showActivityList(container)
			elseif index == 2 then 
				self:showActivityListLimit(container)
			elseif index == 3 then
				self:showActivityCross(container)
			elseif index == 4 then
				self:showPlayerBack(container)
			end
		else
			if index == 1 then  
				self:showActivityListLimit(container)
			elseif index == 2 then
				self:showActivityCross(container)
			elseif index == 3 then
				self:showPlayerBack(container)
			end
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {}
	--判断是否有活动
	-- if #ActivityCenterMO.activityList_ > 0 then
	-- 	pages = CommonText[724]
	-- else
	-- 	pages = {CommonText[724][2],CommonText[724][3]}
	-- end

	if #ActivityCenterMO.activityList_ > 0 and PlayerBackMO.isBack_ and UserMO.level_ >= 30 then
		pages = CommonText[100015]
	elseif #ActivityCenterMO.activityList_ > 0 then
		pages = CommonText[724]
	elseif PlayerBackMO.isBack_ and UserMO.level_ >= 30 then
		pages = {CommonText[100015][2],CommonText[100015][3],CommonText[100015][4]}
	else
		pages = {CommonText[724][2],CommonText[724][3]}
	end

	--临时
	-- pages = {CommonText[724][1]}

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end


function ActivityCenterView:showActivityList(container)
	local ActivityCenterTableView = require("app.scroll.ActivityCenterTableView")
	local view = nil

	view = ActivityCenterTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), ACTIVITY_CENTER_TYPE_NOMAL):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()

end

function ActivityCenterView:showActivityListLimit(container)
	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(container, -1)
	-- bg:setPreferredSize(cc.size(607, 140))
	-- bg:setCapInsets(cc.rect(220, 60, 1, 1))
	-- bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 80)

	-- local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",70, 65):addTo(bg)

	-- local icon = display.newSprite("image/item/activity_boss.jpg"):addTo(fame)
	-- icon:setScale(0.9)
	-- icon:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
	

	-- local title = ui.newTTFLabel({text = "世界BOSS", font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 	x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	-- title:setAnchorPoint(cc.p(0, 0.5))


	-- local time = ui.newTTFLabel({text = CommonText[758], font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 	x = 170, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	-- time:setAnchorPoint(cc.p(0, 0.5))

	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = MenuButton.new(normal, selected, nil, function()
	-- 	Toast.show(CommonText[758])
	-- 	end):addTo(bg)
	-- detailBtn:setPosition(bg:getContentSize().width - 70, bg:getContentSize().height / 2 - 20)


	local ActivityCenterTableView = require("app.scroll.ActivityCenterTableView")
	local view = nil

	view = ActivityCenterTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), ACTIVITY_CENTER_TYPE_LIMIT):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()

end

function ActivityCenterView:showActivityCross(container)
	local state = false
	if not CrossMO.isOpen_ then
		ActivityCenterMO.activityCrossList_[1].time = nil
	elseif CrossMO.isOpen_  and not ActivityCenterMO.activityCrossList_[1].time then 
		state = true
		CrossBO.getState(function()
			ActivityCenterMO.activityCrossList_[1].time = CrossMO.getTime()
			self:showCross(container)
			return
		end)
	elseif ActivityCenterMO.activityCrossList_[1].time then
	end
	if not CrossPartyMO.isOpen_ then
		ActivityCenterMO.activityCrossList_[2].time = nil
	elseif CrossPartyMO.isOpen_  and not ActivityCenterMO.activityCrossList_[2].time then 
		state = true
		CrossPartyBO.getState(function()
			ActivityCenterMO.activityCrossList_[2].time = CrossPartyMO.getTime()
			self:showCross(container)
		end)
	elseif ActivityCenterMO.activityCrossList_[2].time then
	end
	if not state then
		self:showCross(container)
	end
end

function ActivityCenterView:showCross(container)
	local ActivityCenterTableView = require("app.scroll.ActivityCenterTableView")
	local view = nil
	view = ActivityCenterTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 104), ACTIVITY_CENTER_TYPE_CROSS):addTo(container)
	view:setPosition(0, 100)
	view:reloadData()

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 100)

	UiUtil.button("btn_10_normal.png","btn_10_selected.png",nil,handler(self,self.crossRank),CommonText[30051])
		:addTo(container):pos(container:width() - 120,40)
end

function ActivityCenterView:showPlayerBack(container)
	local PlayerBackTableView = require("app.scroll.PlayerBackTableView")
	local view = PlayerBackTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height)):addTo(container)
	view:setPosition(0,0)
	view:reloadData()
end

function ActivityCenterView:crossRank()
	ManagerSound.playNormalButtonSound()
	-- CrossBO.GetCrossRank(function()
		require("app.view.CrossRankView").new():push()
	-- end)
end

function ActivityCenterView:updateView()
	
end

function ActivityCenterView:onExit()
	ActivityCenterView.super.onExit(self)

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end

return ActivityCenterView
