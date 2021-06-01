local ActivityDailyTargetView = class("ActivityDailyTargetView", TableView)

function ActivityDailyTargetView:ctor(size, awardId, activityId)
	ActivityDailyTargetView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 220)
	self.m_awardId = awardId
	self.m_activityId = activityId
	local ultiAward, awards = ActivityMO.queryActivityAwardsByAwardId(self.m_awardId)
	self.m_ultiAward = ultiAward
	self.m_awards = awards
	-- self.m_rewardStatus
end

function ActivityDailyTargetView:onEnter()
	ActivityDailyTargetView.super.onEnter(self)
end

function ActivityDailyTargetView:numberOfCells()
	return #self.m_awards
end

function ActivityDailyTargetView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityDailyTargetView:createCellAtIndex(cell, index)
	ActivityDailyTargetView.super.createCellAtIndex(self, cell, index)
	self:updateCell(cell, index)
	return cell
end

function ActivityDailyTargetView:updateCell(cell, index)
	cell:removeAllChildren()
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 220))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local aw = self.m_awards[index]
	local awardId = aw.keyId
	local rewardStatus = nil
	local left = nil
	if self.m_activityId == ACTIVITY_ID_FORTUNE then
		rewardStatus = ActivityCenterMO.dailyTargetStates
		left = ActivityCenterMO.dayLotteryCount
	elseif self.m_activityId == ACTIVITY_ID_ENERGYSPAR then
		rewardStatus = ActivityCenterMO.dailyTargetEnergyStates
		left = ActivityCenterMO.dayEnergyCount
	elseif self.m_activityId == ACTIVITY_ID_EQUIPDIAL then
		rewardStatus = ActivityCenterMO.dailyTargetEquipStates
		left = ActivityCenterMO.dayEquipCount
	elseif self.m_activityId == ACTIVITY_ID_TACTICSPAR then
		rewardStatus = ActivityCenterMO.dailyTargetTacticStates
		left = ActivityCenterMO.dayTacticCount
	end
	local stat = rewardStatus[awardId]
	local total = aw.cond
	local labelGambleTip = UiUtil.label(aw.desc):addTo(cell)
	labelGambleTip:setAnchorPoint(cc.p(0.5, 0.5))
	labelGambleTip:setPosition(self.m_cellSize.width / 2 - 20, self.m_cellSize.height - labelGambleTip:getContentSize().height - 5)
	UiUtil.label(string.format("(%d/%d)", left, total), nil, COLOR[6]):addTo(cell):rightTo(labelGambleTip)

	local awardsData = json.decode(aw.awardList)
	for i, v in ipairs(awardsData) do
		local propType = v[1]
		local propId = v[2]
		local propCount = v[3]

		local propData = UserMO.getResourceData(propType, propId)

		local bagView = UiUtil.createItemView(propType, propId, {count = propCount}):addTo(cell)
		local bagSize = bagView:getContentSize()
		bagView:setPosition(100 + (i-1) * (bagSize.width + 10), self.m_cellSize.height - labelGambleTip:getContentSize().height - bagSize.height/2 - 40)
		UiUtil.createItemDetailButton(bagView, cell, true)

		-- 名称
		local name = ui.newTTFLabel({text = propData.name, font = G_FONT, size = FONT_SIZE_SMALL, }):addTo(cell)
		name:setPosition(100 + (i-1) * (bagSize.width + 10), self.m_cellSize.height - labelGambleTip:getContentSize().height - bagSize.height - 40 - name:getContentSize().height)
	end

	-- 兑换
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = CellMenuButton.new(normal, selected, disabled, handler(self, self.onBtnCallback))

	btn.cell = cell
	btn.index = index
	btn.awardId = awardId
	btn.activityId = self.m_activityId

	if stat == 0 then
		btn:setLabel("领取")
		btn:setEnabled(true)
	elseif stat == -1 then
		btn:setLabel("领取")
		btn:setEnabled(false)
	else
		btn:setLabel("已领取")
		btn:setEnabled(false)
	end

	cell:addButton(btn, self.m_cellSize.width - 120, self.m_cellSize.height / 2 - 22)
end

function ActivityDailyTargetView:onBtnCallback(tag, sender)
	local awardId = sender.awardId
	if sender.activityId == ACTIVITY_ID_FORTUNE then
		ActivityCenterBO.getFortuneDayAward(function ()
			-- body
			local aw = self.m_awards[sender.index]
			local awardId = aw.keyId
			-- 改为已领取
			ActivityCenterMO.dailyTargetStates[awardId] = 1
			self:updateCell(sender.cell, sender.index)
			self:reloadData()
		end, awardId)
	elseif sender.activityId == ACTIVITY_ID_ENERGYSPAR then
		ActivityCenterBO.getEnergyDialDayAward(function ()
			-- body
			local aw = self.m_awards[sender.index]
			local awardId = aw.keyId
			-- 改为已领取
			ActivityCenterMO.dailyTargetEnergyStates[awardId] = 1
			self:updateCell(sender.cell, sender.index)
			self:reloadData()
		end, awardId)
	elseif sender.activityId == ACTIVITY_ID_EQUIPDIAL then
		ActivityCenterBO.getEquipDialDayAward(function ()
			-- body
			local aw = self.m_awards[sender.index]
			local awardId = aw.keyId
			-- 改为已领取
			ActivityCenterMO.dailyTargetEquipStates[awardId] = 1
			self:updateCell(sender.cell, sender.index)
			self:reloadData()
		end, awardId)
	elseif sender.activityId == ACTIVITY_ID_TACTICSPAR then
		ActivityCenterBO.getTacyicsDialDayAward(function ()
			-- body
			local aw = self.m_awards[sender.index]
			local awardId = aw.keyId
			-- 改为已领取
			ActivityCenterMO.dailyTargetTacticStates[awardId] = 1
			self:updateCell(sender.cell, sender.index)
			self:reloadData()
		end, awardId)
	end
end

function ActivityDailyTargetView:onExit()
	ActivityDailyTargetView.super.onExit(self)
end

return ActivityDailyTargetView
