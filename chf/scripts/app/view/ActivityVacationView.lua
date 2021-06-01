--
-- Author: gf
-- Date: 2016-02-18 15:13:57
-- 度假胜地

local ActivityVacationAwardTableView = class("ActivityVacationAwardTableView", TableView)

function ActivityVacationAwardTableView:ctor(size,villageId)
	ActivityVacationAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
	self.list = ActivityCenterBO.getVillageAwardById(villageId)
	self.villageId_ = villageId
end

function ActivityVacationAwardTableView:onEnter()
	ActivityVacationAwardTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_ACTIVITY_VACATION_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function ActivityVacationAwardTableView:numberOfCells()
	return #self.list
end

function ActivityVacationAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityVacationAwardTableView:createCellAtIndex(cell, index)
	ActivityVacationAwardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]
	-- gdump(data,"ActivityVacationAwardTableView .. data")
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self.m_cellSize.height - 30)

	local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	if data.onday == 1 then
		info:setString(CommonText[869][1])
	else
		info:setString(string.format(CommonText[869][2],data.onday))
	end

	local awardList = PbProtocol.decodeArray(data["award"])

	-- gdump(awardList,data.onday)
	for index=1,#awardList do
		local award = awardList[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 140,bg:getPositionY() - 80)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		

		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	--领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	local awardBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.getAwardHandler))
	awardBtn.villageAward = data
	cell:addButton(awardBtn, self.m_cellSize.width - 80, bg:getPositionY() - 80)

	local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_VACATION)
	
 	if activityContent.villageId == self.villageId_ and data.state == 1 then
 		if data.status == 0 then
 			awardBtn:setEnabled(true)
 			awardBtn:setLabel(CommonText[870][2])
 		else
 			awardBtn:setEnabled(false)
 			awardBtn:setLabel(CommonText[870][3])
 		end
 	else
 		awardBtn:setEnabled(false)
		awardBtn:setLabel(CommonText[870][1])
 	end
	
	return cell
end

function ActivityVacationAwardTableView:getAwardHandler(tag, sender)
	Loading.getInstance():show()
		ActivityCenterBO.asynDoActVacationland(function()
			Loading.getInstance():unshow()
			end, sender.villageAward)
end

function ActivityVacationAwardTableView:updateListHandler(event)
	self.list = ActivityCenterBO.getVillageAwardById(self.villageId_)
	local offset = self:getContentOffset()
   	self:reloadData()
   	self:setContentOffset(offset)
end

function ActivityVacationAwardTableView:onExit()
	ActivityVacationAwardTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end
end



local ConfirmDialog = require("app.dialog.ConfirmDialog")


local ActivityVacationView = class("ActivityVacationView", UiNode)

function ActivityVacationView:ctor(activity)
	ActivityVacationView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityVacationView:onEnter()
	ActivityVacationView.super.onEnter(self)

	self:setTitle(self.m_activity.name)
	-- cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

	Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
		
				local function createDelegate(container, index)
					self.m_timeLab = nil
					self.m_timeLab1 = nil
					self.buyBtn_ = nil
					self:showVacation(container,index)
				end

				local function clickDelegate(container, index)
					
				end

				local pages = {CommonText[864][1],CommonText[864][2],CommonText[864][3]}


				local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
				local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
				pageView:setPageIndex(3)
				self.m_pageView = pageView

				local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
				line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
				line:setScaleY(-1)
				line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

				self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
				self:scheduleUpdate()		
		end, self.m_activity.activityId,1)

end


function ActivityVacationView:showVacation(container,index)
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_vacation.jpg"):addTo(container)
	infoBg:setPosition(container:getContentSize().width / 2,container:getContentSize().height - infoBg:getContentSize().height / 2 - 5)
	-- 活动时间
	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = container:getContentSize().height - 50}):addTo(container)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = cc.c3b(35,255,0)}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(200, container:getContentSize().height - 80)
	self.m_timeLab = timeLab


	-- 资格时间
	local title = ui.newTTFLabel({text = CommonText[865], font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = container:getContentSize().height - 110}):addTo(container)

	local timeLab1 = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[12]}):addTo(container)
	timeLab1:setAnchorPoint(cc.p(0, 0.5))
	timeLab1:setPosition(200, container:getContentSize().height - 140)
	self.m_timeLab1 = timeLab1

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityVacation):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 50)

	local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_VACATION)

	--建筑图片
	local buildPic
	if index == 1 then
		buildPic = display.newSprite("image/skin/base/w_s_6.png"):addTo(infoBg)
	elseif index == 2 then
		buildPic = display.newSprite("image/skin/base/w_s_5.png"):addTo(infoBg)
	elseif index == 3 then
		buildPic = display.newSprite("image/skin/base/w_s_2.png"):addTo(infoBg)
	end
	buildPic:setPosition(90,120)

	--说明
	local infoLab = ui.newTTFLabel({text = string.format(CommonText[866],activityContent.village[index].topup), font = G_FONT, size = FONT_SIZE_SMALL}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0,0.5))
	infoLab:setPosition(50, container:getContentSize().height - 190)
	
	--金币花费
	local coinPic = display.newSprite(IMAGE_COMMON .. "icon_coin.png"):addTo(infoBg)
	coinPic:setPosition(510,80)

	local priceLab = ui.newTTFLabel({text = activityContent.village[index].price, font = G_FONT, size = FONT_SIZE_SMALL}):addTo(infoBg)
	priceLab:setAnchorPoint(cc.p(0,0.5))
	priceLab:setPosition(coinPic:getPositionX() + 20,coinPic:getPositionY())

	--度假按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	buyBtn = MenuButton.new(normal, selected, disabled, handler(self,self.buyVacation)):addTo(infoBg)
	buyBtn:setPosition(540,35)
	buyBtn:setLabel(CommonText[867])
	buyBtn.village = activityContent.village[index]
	buyBtn.index = index

	buyBtn:setEnabled(activityContent.villageId == 0 and activityContent.topup >= activityContent.village[index].topup)
	self.buyBtn_ = buyBtn


	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	tableBg:setPreferredSize(cc.size(container:getContentSize().width - 20, container:getContentSize().height - 220))
	tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 220 - tableBg:getContentSize().height / 2)

	local view = ActivityVacationAwardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),activityContent.village[index].villageId):addTo(tableBg)
	view:setPosition(0, 10)
	view:reloadData()
	self.activityVacationAwardTableView = view

end

function ActivityVacationView:buyVacation(tag,sender)
	gdump(sender.village,"buyVacation .. village")
	local cost = sender.village.price
	--判断金币
	function dobuy()
		if cost > UserMO.getResource(ITEM_KIND_COIN) then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end
		Loading.getInstance():show()
		ActivityCenterBO.asynBuyActVacationland(function()
			Loading.getInstance():unshow()
			local activityContent = ActivityCenterMO.getActivityContentById(ACTIVITY_ID_VACATION)
			self.buyBtn_:setEnabled(activityContent.villageId == 0) 
			end, sender.village.villageId,cost)
	end
	ConfirmDialog.new(string.format(CommonText[868][sender.index],cost), function()
		dobuy()
		end):push()
end


function ActivityVacationView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.displayTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end

	local leftTime1 = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime1 > 0 then
		self.m_timeLab1:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime1))
	else
		self.m_timeLab1:setString(CommonText[871])
		self.buyBtn_:setEnabled(false)
	end
end


function ActivityVacationView:onExit()
	ActivityVacationView.super.onExit(self)

end





return ActivityVacationView
