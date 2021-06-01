--
-- Author: Gss
-- Date: 2018-11-07 16:05:38
-- 军团活跃活动

local ActivityPartyWarTableView = class("ActivityPartyWarTableView", TableView)

function ActivityPartyWarTableView:ctor(size, activityId)
	ActivityPartyWarTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_activityId = activityId
	local activity = ActivityMO.getActivityById(activityId)
	self.m_activity = activity
	self.m_awards = ActivityMO.getPatyWarById(activity.awardId)

	gprint("ActivityPartyWarTableView ctor activity id:", activityId)
	gdump(self.m_awards, "ActivityPartyWarTableView ctor:")

	self.m_cellSize = cc.size(size.width, 190)
end

function ActivityPartyWarTableView:onEnter()
	ActivityPartyWarTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.onUpdateTip))
	self.curIndex = 0
end

function ActivityPartyWarTableView:numberOfCells()
	return #self.m_awards
end

function ActivityPartyWarTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPartyWarTableView:createCellAtIndex(cell, index)
	ActivityPartyWarTableView.super.createCellAtIndex(self, cell, index)

	local moveNode = display.newNode():addTo(cell)
	moveNode:setContentSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))
	--排序
	function sortFun(a,b)
		if a.received == b.received then
			return a.Id < b.Id
		else
			return a.received < b.received
		end
	end
	table.sort(self.m_awards,sortFun)

	local item = self.m_awards[index]
	local info = item.info
	local rewardState = item.states

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(moveNode)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

	local desc = UiUtil.label(item.desc):addTo(titleBg)
	desc:setAnchorPoint(cc.p(0,0.5))
	desc:setPosition(40,titleBg:height() / 2)

	--进度
	local process = UiUtil.label(CommonText[10015]):addTo(moveNode)
	process:setPosition(titleBg:x() + titleBg:width() / 2 + 90, titleBg:y())
	local has = UiUtil.label(info.progress,16,COLOR[6]):rightTo(process)
	local conditions = UiUtil.label("/"..item.eventCondition,16):rightTo(has)

	--奖励展示
	local awards = json.decode(item.award)
	if awards then
		for awardIndex = 1, #awards do
			local award = awards[awardIndex]
			local itemView = UiUtil.createItemView(award[1], award[2], {count = award[3]}):addTo(moveNode)
			itemView:setScale(0.9)
			itemView:setPosition(10 + (awardIndex - 0.5) * 100, 90)
			UiUtil.createItemDetailButton(itemView, cell, true)

			local resData = UserMO.getResourceData(award[1], award[2])
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)
		end
	end

	-- 立即购买
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onRewardCallback))
	btn:setLabel(CommonText[672][1])
	btn.id = item.Id
	btn.index = index
	btn:addTo(moveNode):pos(self.m_cellSize.width - 70, 70)

	local activity = ActivityMO.getActivityById(self.m_activityId)
	if not activity.open then
		btn:setEnabled(false)
	else
		if rewardState.state == 1 then --已领取
			btn:setLabel(CommonText[747])
			btn:setEnabled(false)
		else
			if info.progress < item.eventCondition then
				btn:setEnabled(false)
			end
		end
	end

	--cell移动
	if self.curIndex and self.curIndex ~= 0 and index >= self.curIndex then
		if moveNode then
			moveNode:setPosition(moveNode:x() , moveNode:y() - self.m_cellSize.height)
			moveNode:runAction(transition.sequence({cc.MoveBy:create(0.3,cc.p(0, self.m_cellSize.height) ) , cc.CallFunc:create(function ()
				self.curIndex = 0
			end)}))
		end
	end
	return cell
end

function ActivityPartyWarTableView:onUpdateTip()
	if self.m_activityContent then
		self.m_activityContent = ActivityMO.getActivityContentById(self.m_activityId)
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end
end

function ActivityPartyWarTableView:onRewardCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	ActivityBO.getPartyWarAwards(function ()
		self.curIndex = sender.index
		self.m_awards = ActivityMO.getPatyWarById(self.m_activity.awardId)
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end,sender.id)
end

function ActivityPartyWarTableView:onExit()
	ActivityPartyWarTableView.super.onExit(self)
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

return ActivityPartyWarTableView