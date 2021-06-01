
-- 军团招募

local ActivityPartyRecuritTableView = class("ActivityPartyRecuritTableView", TableView)

--
function ActivityPartyRecuritTableView:ctor(size, activityId)
	ActivityPartyRecuritTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_activityId = ACTIVITY_ID_PARTY_RECURIT
	self.m_activityContent = ActivityMO.getActivityContentById(self.m_activityId)

	gprint("ActivityPartyRecuritTableView ctor activity id:", activityId)
	gdump(self.m_activityContent)

	self.m_cellSize = cc.size(size.width, 190)
end

function ActivityPartyRecuritTableView:numberOfCells()
	local num = 0
	for index = 1, #self.m_activityContent.items do
		num = num + #self.m_activityContent.items[index].conditions
	end
	return num
end

function ActivityPartyRecuritTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityPartyRecuritTableView:createCellAtIndex(cell, index)
	ActivityPartyRecuritTableView.super.createCellAtIndex(self, cell, index)

	local itemId = 0
	local condIndex = 0

	local accu = 0
	for itemIndex = 1, #self.m_activityContent.items do
		if index <= (accu + #self.m_activityContent.items[itemIndex].conditions) then
			itemId = itemIndex
			condIndex = index - accu
			break
		else
			accu = accu + #self.m_activityContent.items[itemIndex].conditions
		end
	end

	local activity = ActivityMO.getActivityById(self.m_activityId)
	local item = self.m_activityContent.items[itemId]
	local condition = item.conditions[condIndex]

	gdump(item, "ActivityPartyRecuritTableView createCellAtIndex")
	-- gdump(condition, "ActivityPartyRecuritTableView createCellAtIndex")

	local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

	local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setAnchorPoint(cc.p(0, 0.5))

	-- 当前进度
	local desc = ui.newTTFLabel({text = CommonText[236] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	desc:setAnchorPoint(cc.p(0, 0.5))

	-- 
	local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(item.state), font = G_FONT, size = FONT_SIZE_TINY, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	count:setAnchorPoint(cc.p(0, 0.5))

	local awards = condition.award
	if awards then
		for awardIndex = 1, #awards do
			local award = awards[awardIndex]
			local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
			itemView:setScale(0.9)
			itemView:setPosition(10 + (awardIndex - 0.5) * 100, 70)
			UiUtil.createItemDetailButton(itemView, cell, true)

			local resData = UserMO.getResourceData(award.kind, award.id)
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getPositionX(), y = 10, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		end
	end

	-- 领取按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback))
	btn.condition = condition
	cell:addButton(btn, self.m_cellSize.width - 70, 70)

	if not activity.open then -- 活动还没有开启领奖
		btn:setEnabled(false)
		btn:setLabel(CommonText[672][3])  -- 不可领取
	elseif condition.status == 1 then -- 已领取
		btn:setEnabled(false)
		btn:setLabel(CommonText[672][2])
	else
		if ActivityBO.canStateReceive(self.m_activityId, condition, item.state) then
			btn:setEnabled(true)
			btn:setLabel(CommonText[672][1])  -- 领取
		else
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][1])  -- 领取
		end
	end
	return cell
end

function ActivityPartyRecuritTableView:onReceiveCallback(tag, sender)
	local function doneCallback(awards)
		Loading.getInstance():unshow()
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end

	local condition = sender.condition
	Loading.getInstance():show()
	ActivityBO.asynReceiveAward(doneCallback, self.m_activityId, condition.keyId)
end

return ActivityPartyRecuritTableView
