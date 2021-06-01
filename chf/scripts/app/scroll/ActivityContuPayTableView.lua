
-- 连续充值活动

local ActivityContuPayTableView = class("ActivityContuPayTableView", TableView)

--
function ActivityContuPayTableView:ctor(size, activityId)
	ActivityContuPayTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_activityId = activityId
	self.m_activityContent = ActivityMO.getActivityContentById(self.m_activityId)

	gprint("ActivityContuPayTableView ctor activity id:", activityId)
	gdump(self.m_activityContent, "ActivityContuPayTableView:ctor contents")

	self.m_cellSize = cc.size(size.width, 190)
end

function ActivityContuPayTableView:onEnter()
	ActivityContuPayTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.onActivityUpdate))
end

function ActivityContuPayTableView:onExit()
	ActivityContuPayTableView.super.onExit(self)
	
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

function ActivityContuPayTableView:onActivityUpdate(event)
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityContuPayTableView:numberOfCells()
	return self.m_activityId == ACTIVITY_ID_CONTU_PAY_NEW and #self.m_activityContent.conditions+1 or 2
end

function ActivityContuPayTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityContuPayTableView:createCellAtIndex(cell, index)
	ActivityContuPayTableView.super.createCellAtIndex(self, cell, index)

	local activity = ActivityMO.getActivityById(self.m_activityId)
	local condition = self.m_activityContent.conditions[1]
	gdump(condition, "ActivityContuPayTableView createCellAtIndex")

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
	titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

	if index == 1 then
		local title = ui.newTTFLabel({text = string.format(CommonText[474][1], condition.param), font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local desc = ui.newTTFLabel({text = CommonText[474][2], font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))
		if self.m_activityId == ACTIVITY_ID_CONTU_PAY_NEW then
			title:setString(CommonText[10068])
			desc:setString(CommonText[10069])
		end

		-- 金币
		local itemView = UiUtil.createItemView(ITEM_KIND_COIN):addTo(cell)
		itemView:setScale(0.9)
		itemView:setPosition(10 + (1 - 0.5) * 100, 70)
		UiUtil.createItemDetailButton(itemView, cell, true)

		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		local name = ui.newTTFLabel({text = resData.name, font = G_FONT, size = FONT_SIZE_TINY, x = itemView:getPositionX(), y = 10, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	else
		local state = self.m_activityContent.state
		if self.m_activityId == ACTIVITY_ID_CONTU_PAY_NEW then
			condition = self.m_activityContent.conditions[index -1]
			state = self.m_activityContent.state[index -1]
		end
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		local desc = nil
		if self.m_activityId == ACTIVITY_ID_CONTU_PAY then
			-- 每天充值满1K金币可领取
			desc = ui.newTTFLabel({text = string.format(CommonText[474][3],activityAward.param), font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_activityId == ACTIVITY_ID_PAY_FOUR or self.m_activityId == ACTIVITY_ID_CONTU_PAY_NEW then
			-- 每天充值满500金币可领取
			desc = ui.newTTFLabel({text = string.format(CommonText[474][self.m_activityId == ACTIVITY_ID_PAY_FOUR and 5 or 4],activityAward.param), font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			desc:setAnchorPoint(cc.p(0, 0.5))
		end

		-- 
		local count = ui.newTTFLabel({text = UiUtil.strNumSimplify(state), font = G_FONT, size = FONT_SIZE_TINY, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		count:setAnchorPoint(cc.p(0, 0.5))

		if state < condition.cond then
			count:setColor(COLOR[6])
		else
			count:setColor(COLOR[2])
		end

		-- 
		local label = ui.newTTFLabel({text = ")", font = G_FONT, size = FONT_SIZE_TINY, x = count:getPositionX() + count:getContentSize().width, y = count:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		label:setAnchorPoint(cc.p(0, 0.5))


		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local awards = condition.award
		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 120, 70)
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
			if (self.m_activityId == ACTIVITY_ID_CONTU_PAY_NEW and state >= condition.cond) or 
				(self.m_activityId ~= ACTIVITY_ID_CONTU_PAY_NEW and ActivityBO.canReceive(self.m_activityId, condition)) then
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])  -- 领取
			else
				-- btn:setEnabled(false)
				-- btn:setLabel(CommonText[672][1])  -- 领取
				btn:setEnabled(true)
				btn:setLabel(CommonText[484]) -- 前往充值
				btn:setTagCallback(handler(self, self.onRechargeCallback))
			end
		end

	end

	return cell
end

function ActivityContuPayTableView:onRechargeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.pop(function()
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		end)
end

function ActivityContuPayTableView:onReceiveCallback(tag, sender)
	local function doneCallback(awards)
		Loading.getInstance():unshow()
		UiUtil.showAwards(awards)
		local offset = self:getContentOffset()
		self:reloadData()
		self:setContentOffset(offset)
	end

	local condition = sender.condition
	Loading.getInstance():show()
	ActivityBO.asynReceiveAward(doneCallback, self.m_activityId, condition.keyId)
end

return ActivityContuPayTableView
