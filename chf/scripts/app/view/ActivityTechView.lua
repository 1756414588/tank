--
-- Author: gf
-- Date: 2015-12-25 11:21:34
-- 技术革新

--------------------------------------------------------------------
-- 兑换列表 tableview
--------------------------------------------------------------------

local ActivityTechTableView = class("ActivityTechTableView", TableView)

function ActivityTechTableView:ctor(size,activityId,type)
	ActivityTechTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 140)
	self.activityId_ = activityId
	self.m_list = ActivityCenterBO.getTechDataByType(type)
end

function ActivityTechTableView:onEnter()
	ActivityTechTableView.super.onEnter(self)
	
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.onActivityUpdate))
end

function ActivityTechTableView:numberOfCells()
	return #self.m_list
end

function ActivityTechTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityTechTableView:createCellAtIndex(cell, index)
	ActivityTechTableView.super.createCellAtIndex(self, cell, index)

	local data = self.m_list[index]
	gdump(data,"====")

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPreferredSize(cc.size(self.m_cellSize.width - 40, self.m_cellSize.height))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
	
	if data.propId == 0 then
		--随机道具
		local itemBg = display.newSprite(IMAGE_COMMON .. "item_bg_4.png", 110, self.m_cellSize.height / 2)
		cell:addChild(itemBg)
		local itemBg1 = display.newSprite(IMAGE_COMMON .. "item_fame_4.png", 110, self.m_cellSize.height / 2)
		cell:addChild(itemBg1)
		local itemView = display.newSprite(IMAGE_COMMON .. "randomTech.png", itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2):addTo(itemBg)
		--名称
		local name = ui.newTTFLabel({text = CommonText[831][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 175, y = self.m_cellSize.height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))
	else
		local itemView = UiUtil.createItemView(ITEM_KIND_PROP, data.propId)
		itemView:setPosition(110, self.m_cellSize.height / 2)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView,cell,true)

		local resData = UserMO.getResourceData(ITEM_KIND_PROP, data.propId)

		--名称
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 175, y = self.m_cellSize.height - 25, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		name:setAnchorPoint(cc.p(0, 0.5))

		
	end

	local needResData = UserMO.getResourceData(ITEM_KIND_PROP, data.usePropId)
	--配方
	local needLab = ui.newTTFLabel({text = CommonText[831][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 175, y = self.m_cellSize.height - 70, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	needLab:setAnchorPoint(cc.p(0, 0.5))

	local needValue = ui.newTTFLabel({text = needResData.name .. "*" .. data.usePropcount, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 175 + needLab:getContentSize().width, y = self.m_cellSize.height - 70, color = COLOR[needResData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	needValue:setAnchorPoint(cc.p(0, 0.5))

	--现有数量
	local countLab = ui.newTTFLabel({text = CommonText[831][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 175, y = self.m_cellSize.height - 100, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	countLab:setAnchorPoint(cc.p(0, 0.5))

	local countValue = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 175 + countLab:getContentSize().width, y = self.m_cellSize.height - 100, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	countValue:setAnchorPoint(cc.p(0, 0.5)) 

	local haveCount = UserMO.getResource(ITEM_KIND_PROP, data.usePropId)
	countValue:setString(haveCount)
	if haveCount >= data.usePropcount then
		countValue:setColor(COLOR[2])
	else
		countValue:setColor(COLOR[6])
	end
	
	--兑换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local buyBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onExchangeHandler))
	buyBtn:setLabel(CommonText[833])
	buyBtn.data = data
	buyBtn:setEnabled(haveCount >= data.usePropcount)
	cell:addButton(buyBtn, self.m_cellSize.width - 100, 50)


	return cell
end

function ActivityTechTableView:onExchangeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynDoActTech(function()
		Loading.getInstance():unshow()
		end, sender.data)
end



function ActivityTechTableView:onActivityUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityTechTableView:onExit()
	ActivityTechTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end


local ActivityTechView = class("ActivityTechView", UiNode)

function ActivityTechView:ctor(activity)
	ActivityTechView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityTechView:onEnter()
	ActivityTechView.super.onEnter(self)

	self:setTitle(CommonText[830])

	local function createDelegate(container, index)
		self.m_timeLab = nil
		self:setUI(container,index)
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[829][1],CommonText[829][2]}


	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end


function ActivityTechView:setUI(container,index)
	-- 活动时间
	local title = ui.newTTFLabel({text = CommonText[727][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = container:getContentSize().height - 30}):addTo(container)

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   	color = COLOR[2]}):addTo(container)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(40, container:getContentSize().height - 60)
	self.m_timeLab = timeLab

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.activityTech):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 70, container:getContentSize().height - 50)

	local view = ActivityTechTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 80),self.m_activity.activityId,index):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function ActivityTechView:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

function ActivityTechView:onExit()
	ActivityTechView.super.onExit(self)

end





return ActivityTechView
