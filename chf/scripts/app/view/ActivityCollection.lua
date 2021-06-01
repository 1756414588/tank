--
-- Author: Your Name
-- Date: 2016-10-22 17:26:44
--
--------------------------------------------------------
	--集字活动
--------------------------------------------------------
local ActivityCollection = class("ActivityCollection", UiNode)

function ActivityCollection:ctor(activity)
	ActivityCollection.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityCollection:onEnter()
	ActivityCollection.super.onEnter(self)
	self:setTitle(self.m_activity.name)
		local function createDelegate(container, index)
		self.m_timeLab = nil
		self.index = index
		if index == 1 then  
			self:showCollect(container)
		elseif index == 2 then 
			self:showExchange(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[20140],CommonText[589]}

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	ActivityCenterBO.GetCollectInfo(function()
		pageView:setPageIndex(1)
	end)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityCollection:showCollect(container)
	--活动时间
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, container:getContentSize().height - 30)

	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)
	
	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg:getPositionY() - bg:getContentSize().height / 2 - 10)
	self.m_timeLab = timeLab
	--活动说明btn
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local content = DetailText.collection
			DetailTextDialog.new(content):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 50,container:getContentSize().height - 50)

	--活动说明
	local bg1 = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(container)
	bg1:setAnchorPoint(cc.p(0, 0.5))
	bg1:setPosition(40, container:getContentSize().height - 145)

	local title = ui.newTTFLabel({text = CommonText[727][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg1:getContentSize().height / 2}):addTo(bg1)
	local timeLab = ui.newTTFLabel({text = CommonText[20141], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,dimensions = cc.size(530, 70)}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, bg1:getPositionY() - bg1:getContentSize().height / 2 - 30)

	--背景图
	local pic = display.newScale9Sprite(IMAGE_COMMON.."info_bg_Fortune.jpg"):addTo(container,-1)
	pic:setPosition(container:getContentSize().width / 2,container:getContentSize().height / 2 - 30)

	self.m_bg = pic

	local x,y,ex,ey = 115,420,378,232
	local list = PropMO.queryActProp(self.m_activity.activityId)
	self.list = list
	for k = 1, 4 do
		local tx,ty = x + (k-1)%2*ex,y - math.floor((k-1)/2)*ey
		local count = ActivityCenterBO.prop_[list[k].id] and ActivityCenterBO.prop_[list[k].id].count or 0
		local item = UiUtil.createItemView(ITEM_KIND_CHAR, list[k].id, {count = count})
			:addTo(pic):pos(tx,ty)
		UiUtil.createItemDetailButton(item)
		local t = display.newSprite(IMAGE_COMMON.."profoto.png"):addTo(pic)
			:align(display.LEFT_CENTER, tx+(item:width()/2)*(k%2 == 1 and 1 or -1),ty)
		if k == 2 then t:setScaleX(-1)
		elseif k == 3 then t:setScaleY(-1)
		elseif k == 4 then t:scale(-1) end
	end
	--中间的合成物
	local itemView = UiUtil.createItemView(ITEM_KIND_CHAR, list[#list].id,{count = ActivityCenterBO.prop_[list[#list].id] and ActivityCenterBO.prop_[list[#list].id].count or 0}):addTo(pic)
	itemView:setPosition(pic:getContentSize().width / 2,pic:getContentSize().height / 2)
	UiUtil.createItemDetailButton(itemView)

	--注
	local notice = ui.newTTFLabel({text = CommonText[20142], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[6]}):addTo(container)
	notice:setPosition(container:getContentSize().width / 2,pic:getPositionY() - pic:getContentSize().height / 2 - 20)

	--按钮:去搜集，拼合
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local gatherBtn = MenuButton.new(normal, selected, nil, handler(self,self.goCollect)):addTo(pic)
	gatherBtn:setPosition(pic:getContentSize().width / 2 - 150, 40)
	gatherBtn:setLabel(CommonText[784][1])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local composeBtn = MenuButton.new(normal, selected, nil, handler(self,self.goCompose)):addTo(pic)
	composeBtn:setPosition(pic:getContentSize().width / 2 + 150, 40)
	composeBtn:setLabel(CommonText[20143])
	composeBtn.id = list[#list].id
end

function ActivityCollection:showOwn()
	if self.node then self.node:removeAllChildren() end
	local x,y,ex = 105,self.node:height()/2,110
	for k,v in ipairs(self.list) do
		local tx = x+((k-1)*ex)
		local count = ActivityCenterBO.prop_[v.id] and ActivityCenterBO.prop_[v.id].count or 0
		local t = display.newSprite("image/item/chat_small"..v.id..".png"):addTo(self.node):pos(tx,y)
		UiUtil.label("x"..count,nil,COLOR[2]):rightTo(t)
	end
end

function ActivityCollection:showExchange(container)
	local hasLab = ui.newTTFLabel({text = CommonText[507][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[12]}):addTo(container)
   	hasLab:setPosition(20,container:getContentSize().height - 30)
   	hasLab:setAnchorPoint(cc.p(0,0.5))
   	self.node = display.newNode():size(container:width(),70):addTo(container):pos(0,hasLab:y()-55)
   	self:showOwn()

	--背景框
	local bg = display.newScale9Sprite(IMAGE_COMMON.."info_bg_15.png"):addTo(container)
	bg:setPreferredSize(cc.size(607, 700))
	bg:setPosition(container:getContentSize().width / 2,container:getContentSize().height / 2 -50)
	--兑换TableView
	local ActivityCollectionTableView = require("app.scroll.ActivityCollectionTableView")
	local view = ActivityCollectionTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height),121,handler(self,self.showOwn)):addTo(bg)
	view:setPosition(0,0)
	view:reloadData()
end

function ActivityCollection:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityCollection:goCollect(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.CombatSectionView").new():push()
end

function ActivityCollection:goCompose(tag,sender)
	ManagerSound.playNormalButtonSound()
	ActivityCenterBO.CollectCombine(sender.id,function()
		self.m_pageView:setPageIndex(1)
		Toast.show(CommonText[467][1])
	end)
end

function ActivityCollection:refreshUI()
	if self.index == 1 then
		self.m_pageView:setPageIndex(1)
	end
end

return ActivityCollection