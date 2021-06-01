--
-- Author: gf
-- Date: 2016-02-20 10:34:17
-- 分解配件兑换改造

local ActivityPartResolveTableView = class("ActivityPartResolveTableView", TableView)

function ActivityPartResolveTableView:ctor(size, activity)
	ActivityPartResolveTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 150)
	self.m_activity = activity
	self.list = ActivityCenterMO.getActivityContentById(activity.activityId).partResolve
end

function ActivityPartResolveTableView:onEnter()
	ActivityPartResolveTableView.super.onEnter(self)
	-- self.m_updateListHandler = Notify.register(LOCAL_ACTIVITY_VACATION_UPDATE_EVENT, handler(self, self.updateListHandler))
end

function ActivityPartResolveTableView:numberOfCells()
	return #self.list
end

function ActivityPartResolveTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPartResolveTableView:createCellAtIndex(cell, index)
	ActivityPartResolveTableView.super.createCellAtIndex(self, cell, index)

	local data = self.list[index]
	-- gdump(data,"ActivityPartResolveTableView .. data")
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	

	local itemData = PbProtocol.decodeRecord(data["award"])

	gdump(itemData,"ActivityPartResolveTableView .. itemData")

	local itemView = UiUtil.createItemView(itemData.type, itemData.id, {count = itemData.count})
	itemView:setPosition(90, 65)
	UiUtil.createItemDetailButton(itemView, cell, true)
	bg:addChild(itemView)

	local resDB = UserMO.getResourceData(itemData.type, itemData.id)

	-- 名称
	local name = ui.newTTFLabel({text = resDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 117, color = COLOR[resDB.quality]}):addTo(cell)

	local desc = resDB.desc or ""
	local desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height / 2 - 15, color = COLOR[11], align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(260, 88)}):addTo(cell)
	desc:setAnchorPoint(cc.p(0.5, 0.5))

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)

	--需要芯片
	local needLab = ui.newTTFLabel({text = CommonText[873], font = G_FONT, size = FONT_SIZE_SMALL, x = 400, y = 117}):addTo(cell)
	needLab:setAnchorPoint(cc.p(0,0.5))
	local needValue = ui.newTTFLabel({text = data.count, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = needLab:getPositionX() + needLab:getContentSize().width, y = 117}):addTo(cell)
	if activityContent.state >= data.count then
		needValue:setColor(COLOR[2])
	else
		needValue:setColor(COLOR[6])
	end

	--兑换按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png") 
	local awardBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.getAwardHandler))
	awardBtn:setLabel(CommonText[589])
	awardBtn.partResolve = data
	cell:addButton(awardBtn, self.m_cellSize.width - 120, bg:getContentSize().height / 2 - 10)
	awardBtn:setEnabled(activityContent.state >= data.count)
	awardBtn.view = itemView

	
	return cell
end

function ActivityPartResolveTableView:getAwardHandler(tag, sender)
	local itemView = sender.view
	local worldPoint = itemView:getParent():convertToWorldSpace(cc.p(itemView:getPositionX(), itemView:getPositionY()))

	local activityId = self.m_activity.activityId
	local data = sender.partResolve
	data.isMedal = false

	local function gotoExc()
		self:updateListHandler()
	end

	local ActPropExcDialog = require("app.dialog.ActPropExcDialog")--批量购买
	ActPropExcDialog.new(data, function ()
		gotoExc()
	end, worldPoint, activityId):push()


	-- if self.m_activity.activityId == ACTIVITY_ID_PART_RESOLVE then
	-- 	Loading.getInstance():show()
	-- 		ActivityCenterBO.asynDoActPartResolve(function()
	-- 			Loading.getInstance():unshow()
	-- 			self:updateListHandler()
	-- 			end, sender.partResolve)
	-- else
	-- 	Loading.getInstance():show()
	-- 	ActivityCenterBO.asynDoActMedalResolve(function()
	-- 		Loading.getInstance():unshow()
	-- 		self:updateListHandler()
	-- 		end, sender.partResolve)
	-- end
end

function ActivityPartResolveTableView:updateListHandler(event)
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityPartResolveTableView:onExit()
	ActivityPartResolveTableView.super.onExit(self)
end

local ConfirmDialog = require("app.dialog.ConfirmDialog")


local ActivityPartResolveView = class("ActivityPartResolveView", UiNode)

function ActivityPartResolveView:ctor(activity)
	ActivityPartResolveView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivityPartResolveView:onEnter()
	ActivityPartResolveView.super.onEnter(self)

	self:setTitle(self.m_activity.name)

	Loading.getInstance():show()
		ActivityCenterBO.asynGetActivityContent(function()
				Loading.getInstance():unshow()
				self:showUI()
				self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
				self:scheduleUpdate()
		end, self.m_activity.activityId,1)

end


function ActivityPartResolveView:showUI()
	--背景
	local infoBg = display.newSprite(IMAGE_COMMON .. "info_bg_partResolve.jpg"):addTo(self:getBg())
	infoBg:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height - infoBg:getContentSize().height)
	-- 活动时间

	local timeLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
	color = cc.c3b(35,255,0)}):addTo(infoBg)
	timeLab:setAnchorPoint(cc.p(0, 0.5))
	timeLab:setPosition(160, 50)
	self.m_timeLab = timeLab

	local activityContent = ActivityCenterMO.getActivityContentById(self.m_activity.activityId)
	self.m_activityContent = activityContent

	local labelStr = nil
	if self.m_activity.activityId == ACTIVITY_ID_PART_RESOLVE then
		labelStr = CommonText[872]
	elseif self.m_activity.activityId == ACTIVITY_ID_MEDAL_RESOLVE then
		labelStr = CommonText[2000]
	end
	local partCountLab = ui.newTTFLabel({text = labelStr, font = G_FONT, size = FONT_SIZE_SMALL, x = 100, y = 20}):addTo(infoBg)
	partCountLab:setAnchorPoint(cc.p(0, 0.5))
	local partCountValue = ui.newTTFLabel({text = activityContent.state, font = G_FONT, size = FONT_SIZE_SMALL, 
	color = cc.c3b(35,255,0)}):addTo(infoBg)
	partCountValue:setAnchorPoint(cc.p(0, 0.5))
	partCountValue:setPosition(partCountLab:getPositionX() + partCountLab:getContentSize().width, 20)
	self.m_partCountValue = partCountValue

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			local detailText = nil
			if self.m_activity.activityId == ACTIVITY_ID_PART_RESOLVE then
				detailText = DetailText.activityPartResolve
			else
				detailText = DetailText.activityMedalResolve
			end
			DetailTextDialog.new(detailText):push()
		end):addTo(infoBg)
	detailBtn:setPosition(infoBg:getContentSize().width - 70, 30)

	

	local view = ActivityPartResolveTableView.new(cc.size(self:getBg():getContentSize().width, self:getBg():getContentSize().height - 340), self.m_activity):addTo(self:getBg())
	view:setPosition(0, 30)
	view:reloadData()
	self.ActivityPartResolveTableView = view

end


function ActivityPartResolveView:update(dt)

	if not self.m_timeLab then return end
	local leftTime = self.m_activity.endTime - ManagerTimer.getTime()
	if leftTime > 0 then
		self.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
	else
		self.m_timeLab:setString(CommonText[871])
	end
	self.m_partCountValue:setString(self.m_activityContent.state)
end


function ActivityPartResolveView:onExit()
	ActivityPartResolveView.super.onExit(self)

end





return ActivityPartResolveView

