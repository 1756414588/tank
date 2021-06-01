--
-- Author: gf
-- Date: 2015-12-08 11:14:59
--

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local ActivityBeeRewardTableView = class("ActivityBeeRewardTableView", TableView)

function ActivityBeeRewardTableView:ctor(size,data)
	ActivityBeeRewardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 200)
	self.data_ = data
end

function ActivityBeeRewardTableView:onEnter()
	ActivityBeeRewardTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.onActivityUpdate))
end

function ActivityBeeRewardTableView:numberOfCells()
	return #self.data_.activityCond
end

function ActivityBeeRewardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityBeeRewardTableView:createCellAtIndex(cell, index)
	ActivityBeeRewardTableView.super.createCellAtIndex(self, cell, index)

	local data = self.data_.activityCond[index]

	gdump(data,"ActivityBeeRewardTableView:createCellAtIndex==")
	
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(cell, -1)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, self.m_cellSize.height - 30)

	local info = ui.newTTFLabel({text = string.format(CommonText[775],UserMO.getResourceData(ITEM_KIND_RESOURCE,self.data_.resId).name2) .. "："  .. UiUtil.strNumSimplify(data.cond), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = bg:getContentSize().height - 25, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	info:setAnchorPoint(cc.p(0,0.5))

	local awardList = PbProtocol.decodeArray(data["award"])
	-- gdump(dayWeal,"当前等级每日福利")
	for index=1,#awardList do
		local award = awardList[index]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setPosition(50 + itemView:getContentSize().width / 2 + (index - 1) * 140,bg:getPositionY() - 80)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView, cell, true)		

		local propDB = UserMO.getResourceData(award.type, award.id)
		local name = ui.newTTFLabel({text = propDB.name .. " * " .. award.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getContentSize().width / 2, y = -20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(itemView)
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local awardBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onRewardHandler))
	awardBtn.data = data

	if self.data_.state >= data.cond then
		--可领取未领
		if data.status == 0 then
			awardBtn:setEnabled(true)
			awardBtn:setLabel(CommonText[777][1])
		else
			awardBtn:setEnabled(false)
			awardBtn:setLabel(CommonText[777][3])
		end
	else
		--不可领取
		awardBtn:setEnabled(false)
		awardBtn:setLabel(CommonText[777][2])
	end
	
	cell:addButton(awardBtn, self.m_cellSize.width - 110, self.m_cellSize.height / 2)

	return cell
end

function ActivityBeeRewardTableView:onRewardHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynReceiveAward(function()
		Loading.getInstance():unshow()
		end, self.data_.activityId, sender.data)
end

function ActivityBeeRewardTableView:onActivityUpdate()
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityBeeRewardTableView:onExit()
	ActivityBeeRewardTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

--------------------------------------------------------------------
-- 排行tableview
--------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local ActivityBeeDialog = class("ActivityBeeDialog", Dialog)

function ActivityBeeDialog:ctor(data)
	ActivityBeeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})
	self.rewardData_ = data
end

function ActivityBeeDialog:onEnter()
	ActivityBeeDialog.super.onEnter(self)
	
	self:setTitle(UserMO.getResourceData(ITEM_KIND_RESOURCE,self.rewardData_.resId).name)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)
	
	local title = ui.newTTFLabel({text = string.format(CommonText[775],UserMO.getResourceData(ITEM_KIND_RESOURCE,self.rewardData_.resId).name), font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 50}):addTo(btm)

	local schedule = ui.newTTFLabel({text = "(" .. ActivityCenterBO.getActivityBeeSchedule(self.rewardData_) .. "/" .. #self.rewardData_.activityCond .. ")", font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = title:getPositionX() + title:getContentSize().width / 2, y = btm:getContentSize().height - 50}):addTo(btm)

	local stateLab = ui.newTTFLabel({text = CommonText[776], font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[11], x = 40, y = btm:getContentSize().height - 80}):addTo(btm)

	local stateValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.rewardData_.state), font = G_FONT, 
		size = FONT_SIZE_SMALL,color = COLOR[2], x = stateLab:getPositionX() + stateLab:getContentSize().width / 2, y = btm:getContentSize().height - 80}):addTo(btm)

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(btm)
	tableBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, btm:getContentSize().height - 100))
	tableBg:setPosition(btm:getContentSize().width / 2, btm:getContentSize().height - 95 - tableBg:getContentSize().height / 2)
	

	local view = ActivityBeeRewardTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 20),self.rewardData_):addTo(btm)
	view:setPosition(0, 20)
	view:reloadData()
end

return ActivityBeeDialog