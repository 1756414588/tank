
-- 活动TableView

local ActivityTableView = class("ActivityTableView", TableView)

--
function ActivityTableView:ctor(size, activityId)
	ActivityTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_activityId = activityId
	self.m_activityContent = ActivityMO.getActivityContentById(self.m_activityId)

	gprint("ActivityTableView ctor activity id:", activityId)
	gdump(self.m_activityContent, "ActivityTableView ctor")

	self.m_cellSize = cc.size(size.width, 190)
end

function ActivityTableView:onEnter()
	ActivityTableView.super.onEnter(self)
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.onActivityUpdate))
	self.curIndex = 0
end

function ActivityTableView:onExit()
	ActivityTableView.super.onExit(self)
	
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
end

function ActivityTableView:onActivityUpdate(event)
	gprint("ActivityTableView:onActivityUpdate")
	if self.m_activityId == ACTIVITY_ID_PAY_RED_GIFT or self.m_activityId == ACTIVITY_ID_PAY_EVERYDAY or self.m_activityId == ACTIVITY_ID_DAY_PAY then
		local view = UiDirector.getUiByName("ActivityView")
		if view then
			self:dispatchEvent({name = "RECEIVE_ACTIVITY_EVENT"})
		end
	end
	
	local offset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(offset)
end

function ActivityTableView:reloadData()
	--排序
	if self.m_activityId == ACTIVITY_ID_BIGWIG_LEADER then
		local function sortFun(a, b)
			local actA = ActivityMO.queryActivityAwardsById(a.keyId)
			local actB = ActivityMO.queryActivityAwardsById(b.keyId)
			local dataA = self.m_activityContent.vipInfo[actA.sortId]
			local dataB = self.m_activityContent.vipInfo[actB.sortId]
			local limitA = actA.cond
			local limitB = actB.cond
			local curA = dataA and dataA.count or 0
			local curB = dataB and dataB.count or 0
			local stateA = curA >= limitA and 1 or 0
			local stateB = curB >= limitB and 1 or 0
			if a.status == b.status then
				if stateA == stateB then
					return actA.keyId < actB.keyId
				else
					return stateA > stateB
				end
			else
				return a.status < b.status
			end
		end
		table.sort(self.m_activityContent.conditions,sortFun)
	else
		-- if type(self.m_activityContent.conditions[index]) == "table" then
			function sortFun(a,b)
				if type(a) ~= "table" then return false end
				if a.status == b.status then
					return a.keyId < b.keyId
				else
					return a.status < b.status
				end
			end
			table.sort(self.m_activityContent.conditions,sortFun)
		-- end
	end

	ActivityTableView.super.reloadData(self)
end

function ActivityTableView:numberOfCells()
	if self.m_activityContent then return #self.m_activityContent.conditions else return 0 end
end

function ActivityTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityTableView:createCellAtIndex(cell, index)
	ActivityTableView.super.createCellAtIndex(self, cell, index)

	local moveNode = display.newNode():addTo(cell)
	moveNode:setContentSize(cc.size(self.m_cellSize.width, self.m_cellSize.height))

	-- --排序
	-- if type(self.m_activityContent.conditions[index]) == "table" then
	-- 	function sortFun(a,b)
	-- 		if a.status == b.status then
	-- 			return a.keyId < b.keyId
	-- 		else
	-- 			return a.status < b.status
	-- 		end
	-- 	end
	-- 	table.sort(self.m_activityContent.conditions,sortFun)
	-- end

	
	local activity = ActivityMO.getActivityById(self.m_activityId)
	local lastCondition = nil
	if index > 1 then lastCondition = self.m_activityContent.conditions[index - 1] end

	local condition = self.m_activityContent.conditions[index]

	if self.m_activityId == ACTIVITY_ID_FIGHT_RANK or self.m_activityId == ACTIVITY_ID_HONOUR or self.m_activityId == ACTIVITY_ID_COMBAT
		or self.m_activityId == ACTIVITY_ID_PARTY_LEVEL then -- 战力排行、荣誉排行
		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local str = ""
		if lastCondition then
			if condition.cond - lastCondition.cond > 1 then str = CommonText[237][1] .. (lastCondition.cond + 1) .. "-" .. condition.cond .. CommonText[237][7]
			else str = CommonText[237][1] .. condition.cond .. CommonText[237][7] end
		else
			str = CommonText[237][1] .. condition.cond .. CommonText[237][7]
		end

		local title = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local awards = condition.award
		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 90)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end
	elseif self.m_activityId == ACTIVITY_ID_POWRE_SUPPLY then  -- 能量赠送
		-- dump(condition,"cell的数量是：")
		local activityAward = ActivityMO.getActivityAwardsByTime(index)
		local noteBg = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(cell)
		noteBg:setPosition(noteBg:getContentSize().width/2 + 10,self.m_cellSize.height - noteBg:getContentSize().height / 2)
		local note = ui.newTTFLabel({text = CommonText[964],font = G_FONT,size = FONT_SIZE_SMALL,x = 40,y = noteBg:getContentSize().height / 2,align = ui.TEXT_ALIGN_CENTER}):addTo(noteBg)
		note:setAnchorPoint(cc.p(0,0.5))

		--活动描述
		local desc = activityAward.startTime.."~"..activityAward.endTime..activityAward.desc
		desc = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))

		--领取按钮
		local normal = display.newSprite(IMAGE_COMMON.."btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON.."btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON.."btn_9_disabled.png")
		local btn = MenuButton.new(normal,selected,disabled,handler(self, self.onPowerCallback))
		btn.index = index
		-- cell:addButton(btn,self.m_cellSize.width - 70,70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)

		--领取的prop
		local awards = json.decode(activityAward.award)   
		if awards then
			for awardIndex=1,#awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award[1],award[2],{count = award[3]}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 70)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award[1],award[2])
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 10, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end
		if condition == 2 then --已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])
		else
			local t = ManagerTimer.getTime()
			-- local t = os.time()
			local h = tonumber(os.date("%H", t))
			local m = tonumber(os.date("%M", t))
			local s = tonumber(os.date("%S", t))

			local temp1 = string.split(activityAward.startTime, ":")
			local temp2 = string.split(activityAward.endTime, ":")
			if h >= tonumber(temp1[1]) and h < tonumber(temp2[1]) then
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])  -- 领取
			else
				btn:setEnabled(false)
				btn:setLabel(CommonText[672][1])  -- 灰色领取
			end
		end
	elseif self.m_activityId == ACTIVITY_ID_GIFT_ONLINE then  -- 在线时长
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, ACTIVITY_ID_GIFT_ONLINE... Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		-- 当前进度
		local desc = ui.newTTFLabel({text = CommonText[236] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))

		-- 已在线时长
		local stateCount = ui.newTTFLabel({text = math.floor(self.m_activityContent.state / 60), font = G_FONT, size = FONT_SIZE_TINY, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		stateCount:setAnchorPoint(cc.p(0, 0.5))

		local condCount = ui.newTTFLabel({text = "/" .. math.floor(condition.cond / 60) .. CommonText[159][5], font = G_FONT, size = FONT_SIZE_TINY, x = stateCount:getPositionX() + stateCount:getContentSize().width, y = stateCount:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		condCount:setAnchorPoint(cc.p(0, 0.5))

		local awards = condition.award
		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 70)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 10, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end

		-- 领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback))
		btn.index = index
		btn.condition = condition
		-- cell:addButton(btn, self.m_cellSize.width - 70, 70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)

		if not activity.open then -- 活动还没有开启领奖
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][3])  -- 不可领取
		elseif condition.status == 1 then -- 已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])

			stateCount:setColor(COLOR[2])
		else
			if ActivityBO.canReceive(self.m_activityId, condition) then
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])  -- 领取

				stateCount:setColor(COLOR[2])
			else
				btn:setEnabled(false)
				btn:setLabel(CommonText[672][1])  -- 领取

				stateCount:setColor(COLOR[6])
			end
		end
	elseif self.m_activityId == ACTIVITY_ID_MONTH_LOGIN then -- 每月登录
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, ACTIVITY_ID_GIFT_ONLINE... Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		-- 当前登录天数
		local desc = ui.newTTFLabel({text = CommonText[962], font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 130, align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))

		local stateCount = ui.newTTFLabel({text = self.m_activityContent.state, font = G_FONT, size = FONT_SIZE_TINY, x = desc:getPositionX() + desc:getContentSize().width, y = desc:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		stateCount:setAnchorPoint(cc.p(0, 0.5))

		local awards = condition.award
		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 70)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 10, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end

		-- 领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback))
		btn.index = index
		btn.condition = condition
		-- cell:addButton(btn, self.m_cellSize.width - 70, 70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)

		if not activity.open then -- 活动还没有开启领奖
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][3])  -- 不可领取
		elseif condition.status == 1 then -- 已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])

			stateCount:setColor(COLOR[2])
		else
			if ActivityBO.canReceive(self.m_activityId, condition) then
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])  -- 领取

				stateCount:setColor(COLOR[2])
			else
				btn:setEnabled(false)
				btn:setLabel(CommonText[672][1])  -- 领取

				stateCount:setColor(COLOR[6])
			end
		end
	elseif self.m_activityId == ACTIVITY_ID_SERVERS_LOGIN then --合服登录
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, ACTIVITY_ID_GIFT_ONLINE... Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end
		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)
		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))
		local awards = condition.award

		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 70)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 10, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end
		--领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback))
		btn.condition = condition
		btn.index = index
		-- cell:addButton(btn, self.m_cellSize.width - 70, 70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)
		local nowDay = ActivityMO.getDay(activity.beginTime)-- 活动的第几天
		if activity.open and condition.status == 0 and nowDay == condition.cond then
			btn:setEnabled(true)
			btn:setLabel(CommonText[672][1])  -- 领取
		else
			if condition.cond < nowDay and condition.status == 0 then
				btn:setEnabled(false)
				btn:setLabel(CommonText[20063])  -- 已过期
			elseif nowDay >= condition.cond and condition.status == 1 then
				btn:setEnabled(false)
				btn:setLabel(CommonText[747])  -- 已领取
			else
				btn:setEnabled(false)
				btn:setLabel(CommonText[672][3])  -- 不可领取
			end
		end

	elseif self.m_activityId == ACTIVITY_ID_PARTY_FIGHT then -- 军团战力
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(cell)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local awards = condition.award
		if awards then
			for awardIndex = 1, #awards do
				local award = awards[awardIndex]
				local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(cell)
				itemView:setScale(0.9)
				itemView:setPosition(10 + (awardIndex - 0.5) * 105, 90)
				UiUtil.createItemDetailButton(itemView, cell, true)

				local resData = UserMO.getResourceData(award.kind, award.id)
				local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			end
		end
	elseif self.m_activityId == ACTIVITY_ID_ANNIVERSARY then  --周年庆
		local eb = EffectMO.queryEffectById(condition)
		local noteBg = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(cell)
		noteBg:setPosition(noteBg:getContentSize().width/2 + 10,self.m_cellSize.height - noteBg:getContentSize().height / 2)
		local note = ui.newTTFLabel({text = eb.desc,font = G_FONT,size = FONT_SIZE_SMALL,x = 40,y = noteBg:getContentSize().height / 2,align = ui.TEXT_ALIGN_CENTER}):addTo(noteBg)
		note:setAnchorPoint(cc.p(0,0.5))
		--按钮
		local normal = display.newSprite(IMAGE_COMMON.."btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON.."btn_11_selected.png")
		local btn = MenuButton.new(normal,selected,nil,handler(self, self.onYearCallback))
		btn.id = condition
		-- cell:addButton(btn,self.m_cellSize.width - 70,70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)
		btn:setLabel(CommonText[20139])

		local itemView = UiUtil.createItemView(ITEM_KIND_EFFECT, condition):addTo(cell)
		itemView:setPosition(80,90)
		UiUtil.createItemDetailButton(itemView, cell, true)
	elseif self.m_activityId == ACTIVITY_ID_BIGWIG_LEADER then -- 大咖带队
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(moveNode)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local _data = self.m_activityContent.vipInfo[activityAward.sortId]
		local _curNumber = _data and _data.count or 0
		local _limitNumber = activityAward.cond
		local _color = cc.c3b(255, 0, 0)
		local isCouldTakeAward = false
		if _curNumber >= _limitNumber then 
			_color = cc.c3b(0, 255, 0) 
			isCouldTakeAward = true
		end

		local strs = { {content = "(",color = cc.c3b(255, 255, 255) , size = FONT_SIZE_SMALL},
						{content = tostring(_curNumber),color = _color , size = FONT_SIZE_SMALL}, 
						{content = "/" .. _limitNumber .. ")",color = cc.c3b(255, 255, 255),  size = FONT_SIZE_SMALL} } 
		local titleEx = RichLabel.new(strs):addTo(titleBg)
		titleEx:setAnchorPoint(cc.p(0,0.5))
		titleEx:setPosition(title:x() + title:width() + 20 , titleBg:height() - 13)

		local awards =  json.decode(activityAward.awardList)
		for index = 1 , #awards do
			local award = awards[index]
			local kind = award[1]
			local id = award[2]
			local count = award[3]
			local item = UiUtil.createItemView(kind, id, {count = count}):addTo(moveNode)
			item:setScale(0.9)
			item:setPosition(62.5 + (index - 1) * 108, 90)
			UiUtil.createItemDetailButton(item)

			local resData = UserMO.getResourceData(kind, id)
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = item:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)
		end

		-- 领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(moveNode):pos(self.m_cellSize.width - 70,70)
		btn.condition = condition
		btn.index = index

		if isCouldTakeAward then
			-- CommonText[672][1] 领取
			-- CommonText[672][2] 已领取
			if condition.status == 1 then
				btn:setEnabled(false)
				btn:setLabel(CommonText[672][2])
			else
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])
			end
		else
			btn:setEnabled(true)
			btn:setLabel(CommonText[1786])
		end
	elseif self.m_activityId == ACTIVITY_ID_LOTTERY_TREASURE then -- 探宝大师
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(moveNode)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		local awards =  json.decode(activityAward.awardList)
		for index = 1 , #awards do
			local award = awards[index]
			local kind = award[1]
			local id = award[2]
			local count = award[3]
			local item = UiUtil.createItemView(kind, id, {count = count}):addTo(moveNode)
			item:setScale(0.9)
			item:setPosition(62.5 + (index - 1) * 108, 90)
			UiUtil.createItemDetailButton(item)

			local resData = UserMO.getResourceData(kind, id)
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = item:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)
		end

		-- 领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(moveNode):pos(self.m_cellSize.width - 70,70)
		btn.condition = condition
		btn.index = index

		local score = ActivityMO.activityContents_[self.m_activityId].score

		if condition.status == 1 then -- 已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])
		else
			btn:setLabel(CommonText[672][1])
			if score >= activityAward.cond then
				btn:setEnabled(true)
			else
				btn:setEnabled(false)
			end
		end
	else
		local activityAward = ActivityMO.queryActivityAwardsById(condition.keyId)
		if not activityAward then
			gprint("ActivityTableView:createCellAtIndex, Error!!! keyId:", condition.keyId, "cellIndex:", index)
			activityAward = {desc = "NULL"}
		end

		-- local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(moveNode)
		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(moveNode)
		titleBg:setPosition(titleBg:getContentSize().width / 2 + 10, self.m_cellSize.height - titleBg:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = activityAward.desc, font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setAnchorPoint(cc.p(0, 0.5))

		if self.m_activityId == ACTIVITY_ID_INVEST or self.m_activityId == ACTIVITY_ID_INVEST_NEW then  -- 投资计划
			local build = BuildMO.queryBuildById(BUILD_ID_COMMAND)
			local label = ui.newTTFLabel({text = string.format(CommonText[97], build.name, condition.cond) .. CommonText[398][3], x = self.m_cellSize.width - 20, y = titleBg:getPositionY(), font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)--:addTo(moveNode)
			label:setAnchorPoint(cc.p(1, 0.5))
		end
		if self.m_activityId == ACTIVITY_ID_INVEST_NEW then
			local awards =  json.decode(activityAward.awardList)
			local list = {awards[1],awards[2]}
			local need = {2,3}
			if UserMO.vip_ >= 1 + #awards then
				list = {awards[#awards]}
				need = {UserMO.vip_}
			elseif UserMO.vip_ >= 2 then
				list = {awards[UserMO.vip_-1],awards[UserMO.vip_]}
				need = {UserMO.vip_,UserMO.vip_+1}
			end
			for awardIndex = 1, #list do
				local award = list[awardIndex]
				local itemView = UiUtil.createItemView(award[1], award[2], {count = award[3]}):addTo(moveNode)
				itemView:setScale(0.9)
				if #list > 1 then
					display.newSprite(IMAGE_COMMON.."arrow.png"):addTo(moveNode):pos(160,90)
				end
				itemView:setPosition(62.5 + (awardIndex - 1) * 185, 90)
				UiUtil.createItemDetailButton(itemView, cell, true)
				local resData = UserMO.getResourceData(award[1], award[2])
				local name = ui.newTTFLabel({text = string.format(CommonText[20217], need[awardIndex]), font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)
			end
		else
			local awards = condition.award
			if awards then
				for awardIndex = 1, #awards do
					local award = awards[awardIndex]
					local itemView = UiUtil.createItemView(award.kind, award.id, {count = award.count}):addTo(moveNode)
					if award.kind == ITEM_KIND_HERO then
						itemView:setScale(0.45)
					else
						itemView:setScale(0.9)
					end
					itemView:setPosition(10 + (awardIndex - 0.5) * 105, 90)
					if award.kind == ITEM_KIND_HERO then
					else
						UiUtil.createItemDetailButton(itemView, cell, true)
					end

					local resData = UserMO.getResourceData(award.kind, award.id)
					local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_LIMIT, x = itemView:getPositionX(), y = 30, color = COLOR[resData.quality], align = ui.TEXT_ALIGN_CENTER}):addTo(moveNode)
				end
			end
		end

		-- 领取按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback))
		btn.condition = condition
		btn.index = index
		-- cell:addButton(btn, self.m_cellSize.width - 70, 70)
		btn:addTo(moveNode):pos(self.m_cellSize.width - 70,70)

		if not activity.open then -- 活动还没有开启领奖
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][3])  -- 不可领取
		elseif condition.status == 1 then -- 已领取
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])
		else
			if ActivityBO.canReceive(self.m_activityId, condition) then
				btn:setEnabled(true)
				btn:setLabel(CommonText[672][1])  -- 领取
			else
				if self.m_activityId == ACTIVITY_ID_PAY_RED_GIFT or self.m_activityId == ACTIVITY_ID_PAY_EVERYDAY or self.m_activityId == ACTIVITY_ID_DAY_PAY then
					btn:setEnabled(true)
					btn:setLabel(CommonText[484]) -- 前往充值
					btn:setTagCallback(handler(self, self.onRechargeCallback))
				elseif self.m_activityId == ACTIVITY_ID_SECRET_WEAPON then
					if UserMO.level_ < 60 then
						btn:setEnabled(true)
						btn:setLabel(CommonText[572][1])
						btn:setTagCallback(function ()
							Toast.show(CommonText[1133][1])
						end)
					else
						btn:setEnabled(true)
						btn:setLabel(CommonText[1133][2])
						btn:setTagCallback(function ()
							require("app.view.WarWeaponView").new():push()
						end)					
					end
				else
					btn:setEnabled(false)
					btn:setLabel(CommonText[672][1])  -- 领取
				end
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

function ActivityTableView:onRechargeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- UiDirector.pop(function() require("app.view.RechargeView").new():push() end)
	UiDirector.pop(function()
		-- body
		RechargeBO.openRechargeView()
	end)
end

function ActivityTableView:onPowerCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- if self.m_isReceive then return end
	local function doneCallback()
		Loading.getInstance():unshow()
		sender:setEnabled(false)
		sender:setLabel(CommonText[672][2])
	end

	self.m_isReceive = true

	Loading.getInstance():show()
	ActivityBO.asynPowerAward(doneCallback, self.m_activityId, sender.index)
end

function ActivityTableView:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.curIndex = sender.index
	if self.m_isReceive then return end

	local function onReceiveCallback1()
		local function doneCallback(success, awards)
			Loading.getInstance():unshow()
			self.m_isReceive = false
		end

		self.m_isReceive = true

		local condition = sender.condition
		Loading.getInstance():show()
		ActivityBO.asynReceiveAward(doneCallback, self.m_activityId, condition.keyId)
	end
	if self.m_activityId == ACTIVITY_ID_INVEST_NEW then  -- 投资计划
		local activityAward = ActivityMO.queryActivityAwardsById(sender.condition.keyId)
		local awards =  json.decode(activityAward.awardList)
		local getAward = {}
		if UserMO.vip_ >= 2 and UserMO.vip_ < 1 + #awards then
			getAward = awards[UserMO.vip_ - 1]
			local old,new = 0,0
			for k,v in ipairs(self.m_activityContent.conditions) do
				if v.status == 0 then
					old = old + v.award[UserMO.vip_ - 1].count
					new = new + v.award[UserMO.vip_].count
				end
			end

			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			local confirm = ConfirmDialog.new(string.format(CommonText[20219],UserMO.vip_,sender.condition.cond,getAward[3],UserMO.vip_+1,new - old), function()
					onReceiveCallback1()
				end,function()
					-- require("app.view.RechargeView").new():push() 
					RechargeBO.openRechargeView()
				end):push()
			confirm:setCancelBtnText(CommonText[20220])
			confirm:setOkBtnText(CommonText[255])
			confirm:setOutOfBgClose(true)
		elseif UserMO.vip_ >= 1 + #awards  then
			--getAward = awards[4]
			--不需要二次弹框
			onReceiveCallback1()
		else
			return
		end
	elseif self.m_activityId == ACTIVITY_ID_BIGWIG_LEADER then
		local activityAward = ActivityMO.queryActivityAwardsById(sender.condition.keyId)
		local _data = self.m_activityContent.vipInfo[activityAward.sortId]
		local _curNumber = _data and _data.count or 0
		local _limitNumber = activityAward.cond
		if _curNumber >= _limitNumber then
			onReceiveCallback1()
		else
			-- UiDirector.pop(function() require("app.view.RechargeView").new():push() end)
			UiDirector.pop(function() RechargeBO.openRechargeView() end)
		end
	else	
		onReceiveCallback1()
	end
end

function ActivityTableView:onYearCallback(tag,sender)
	local index = sender.id
	-- if index == 1 or index == 2 then
	-- 	Loading.getInstance():show()
	-- 		TaskBO.asynGetLiveTask(function()
	-- 			Loading.getInstance():unshow()
	-- 			require("app.view.TaskView").new():push()
	-- 			end)
	if index == 200 or index == 201 then
		require("app.view.BuildingQueueView").new(BUILDING_FOR_ALL):push()
	elseif index == 202 then
		-- require("app.view.RefitView").new(BUILD_ID_REFIT):push()
		local a = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_A)
		local b = BuildMO.getBuildLevel(BUILD_ID_CHARIOT_B)
		local a_num = #FactoryBO.getWaitProducts(BUILD_ID_CHARIOT_A)
		local b_num = #FactoryBO.getWaitProducts(BUILD_ID_CHARIOT_B)
		if a > b then
			if a_num >= VipBO.getWaitQueueNum() then
				if a_num == b_num then
					require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A,2):push()
				else
					require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_B,2):push()
				end
			else
				require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A,2):push()
			end
		else
			if b_num >= VipBO.getWaitQueueNum() then
				if b_num == a_num then
					require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_B,2):push()
				else
					require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A,2):push()
				end
			else
				require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_B,2):push()
			end
		end
	elseif index == 203 then
		require("app.view.RefitView").new(BUILD_ID_REFIT):push()
	elseif index == 204 then
		require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
	end
end

return ActivityTableView
