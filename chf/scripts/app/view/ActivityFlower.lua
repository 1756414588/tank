--
-- Author: xiaoxing
-- Date: 2016-11-16 14:49:16
--
local ContentTableView = class("ContentTableView",TableView)

function ContentTableView:ctor(size,rhand)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	self.props = ActivityCenterMO.getFlowerAward()
	self.rhand = rhand
end

function ContentTableView:onEnter()
	ContentTableView.super.onEnter(self)
end

function ContentTableView:numberOfCells()
	return #self.props
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ContentTableView:updateCell(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell,index)
	local data = self.props[index]
	--背景框
	local viewBg = display.newScale9Sprite(IMAGE_COMMON.."info_bg_25.png"):addTo(cell)
	viewBg:setPreferredSize(cc.size(607, 140))
	viewBg:setCapInsets(cc.rect(220, 60, 1, 1))
	viewBg:setPosition(self.m_cellSize.width / 2,self.m_cellSize.height / 2)
	--prop
	local itemView = display.newSprite("image/item/"..data.icon..".jpg"):addTo(cell)
	itemView:setPosition(80,viewBg:getContentSize().height / 2)
	display.newSprite(IMAGE_COMMON.."item_fame_5.png"):addTo(itemView):center()

	--propName and num
	local name = ui.newTTFLabel({text = data.name,font = G_FONT,size = FONT_SIZE_SMALL,x = 160,y = 115,
		color = COLOR[5],align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0,0.5))
	local left = ActivityCenterBO.flowerLeft_[data.id] or data.itemNum
	if data.itemNum ~= -1 then
		UiUtil.label("("..left .."/"..data.itemNum ..")",nil,COLOR[2]):rightTo(name)
	end
	--道具描述
	local desc = ui.newTTFLabel({text = data.itemDec,font = G_FONT,size = FONT_SIZE_SMALL,x = 160,y = self.m_cellSize.height / 2 - 15,
		color = COLOR[1],align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(260,80)}):addTo(cell)

	local need = json.decode(data.more)[1]
	--兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local changeBtn = CellMenuButton.new(normal, selected, disabled, handler(self,self.onChangeCallback))
	changeBtn:setLabel(CommonText[589])
	changeBtn.id = data.id
	changeBtn.cell = cell
	changeBtn.index = index
	cell:addButton(changeBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2 - 30)
	--字牌item
	local t = display.newSprite(IMAGE_COMMON .."flower.png"):addTo(cell):pos(self.m_cellSize.width - 120,self.m_cellSize.height / 2+10):scale(0.7)
	local own = ActivityCenterBO.prop_[need[2]] and ActivityCenterBO.prop_[need[2]].count or 0
	UiUtil.label(need[3],nil,COLOR[own >= need[3] and 2 or 6]):rightTo(t,5)
	if data.itemNum == -1 then
		changeBtn:setEnabled(own >= need[3])
	else
		changeBtn:setEnabled(own >= need[3] and left > 0)
	end
end

function ContentTableView:onChangeCallback(tag,sender)
	ActivityCenterBO.WishFlower(sender.id,function()
		self:reloadData()
		self.rhand()
	end)
end
----------------------------------------------------------------
local ActivityFlower = class("ActivityFlower", UiNode)

function ActivityFlower:ctor(activity)
	ActivityFlower.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityFlower:onEnter()
	ActivityFlower.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	local function createDelegate(container, index)
		self.m_timeLab = nil
		self.index = index
		if index == 1 then  
			self:showCollect(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local pages = {CommonText[538][1]}

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	ActivityCenterBO.GetFlower(function()
		dump(ActivityCenterBO.prop_,"ActivityCenterBO.prop_=====")
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

function ActivityFlower:showCollect(container)
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
			DetailTextDialog.new(DetailText.flower):push()
		end):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 50,container:getContentSize().height - 50)

	local t = display.newSprite(IMAGE_COMMON.."flower_bg.jpg"):addTo(container):pos(container:width()/2,container:height()-190)
	t = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(t)
		:align(display.LEFT_CENTER, 460, 18)
	t = UiUtil.label(CommonText[20149]):addTo(t):align(display.LEFT_CENTER, 5, t:height()/2)
	local own = ActivityCenterBO.prop_[6] and ActivityCenterBO.prop_[6].count or 0
	self.own = UiUtil.label(own,nil,COLOR[2]):rightTo(t)

	local view = ContentTableView.new(cc.size(607, container:height()-296),function()
			local own = ActivityCenterBO.prop_[6] and ActivityCenterBO.prop_[6].count or 0
			self.own:setString(own)
		end):addTo(container):pos(0,0)
	view:reloadData()
end

function ActivityFlower:update(dt)
	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[852])
	end
end

return ActivityFlower