
-- 执行任务

local ArmyTaskTableView = class("ArmyTaskTableView", TableView)

function ArmyTaskTableView:ctor(size)
	ArmyTaskTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self:showSlider(true)
	-- self:showShade(true)

	self.m_cellSize = cc.size(size.width, 145)

	self.m_tipMoreArmyVip =  ArmyBO.higherVipCanOpenArmy()

	self.m_army = ArmyMO.getAllArmies()
	table.sort(self.m_army, ArmyMO.orderArmy)
end

function ArmyTaskTableView:onEnter()
	ArmyTaskTableView.super.onEnter(self)

	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.update))
end

function ArmyTaskTableView:onExit()
	ArmyTaskTableView.super.onExit(self)
	ArmyBO.isAsk = false
	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end
end

function ArmyTaskTableView:numberOfCells()
	if self.m_tipMoreArmyVip then return VipBO.getArmyCount() + 1 else return VipBO.getArmyCount() end
end

function ArmyTaskTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ArmyTaskTableView:reloadData()
	ArmyTaskTableView.super.reloadData(self)
	if ArmyBO.isAsk then
		ArmyBO.isAsk = nil
	end
	self:update()
end

function ArmyTaskTableView:createCellAtIndex(cell, index)
	ArmyTaskTableView.super.createCellAtIndex(self, cell, index)

	if index <= #self.m_army then  -- 有任务执行
		local army = self.m_army[index]
		local bgName = "info_bg_26.png"
		if army.state >= ARMY_AIRSHIP_BEGAIN then
			bgName = "info_bg_26_1.png"
		end
		local bg = display.newScale9Sprite(IMAGE_COMMON .. bgName):addTo(cell)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(222, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		cell.army = army

		local itemView = UiUtil.createItemView(ITEM_KIND_ARMY_TASK, army.state):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		-- dump(army,"army===================army")
		if army.isMilitary then -- 是军事矿区
			local pos = StaffMO.decodePosition(army.target)
			local mine = StaffBO.getMineAt(pos)

			cell.resId = mine.type

			local resData = UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, mine.type)
			local title = ui.newTTFLabel({text = mine.lv .. resData.name2 .. "LV." .. mine.lv .. "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		elseif army.state == ARMY_STATE_FORTRESS then --要塞驻军
			ui.newTTFLabel({text = CommonText[20042], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		elseif army.state >= ARMY_AIRSHIP_BEGAIN then --飞艇
			local pos = WorldMO.decodePosition(army.target)
			ui.newTTFLabel({text = CommonText[998][army.state] .."(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		elseif army.crossMine then	--跨服军事矿区
			local pos = StaffMO.decodeCrossPosition(army.target)
			local mine = StaffBO.getCrossMineAt(pos)

			cell.resId = mine.type

			local resData = UserMO.getResourceData(ITEM_KIND_MILITARY_MINE, mine.type)
			local title = ui.newTTFLabel({text = mine.lv .. resData.name2 .. "LV." .. mine.lv .. "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
		else
			local pos = WorldMO.decodePosition(army.target)
			local mine = WorldBO.getMineAt(pos)

			if mine then -- 是资源
				cell.resId = mine.type
				local quality = army.tar_qua or 1
				local resData = UserMO.getResourceData(ITEM_KIND_WORLD_RES, mine.type)
				local title = ui.newTTFLabel({text = mine.lv .. resData.name2 .. "LV." .. mine.lv .. "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[quality]}):addTo(cell)
			else
				local title = ui.newTTFLabel({text = "(" .. pos.x .. "," .. pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)
			end
		end

		if army.state == ARMY_STATE_WAITTING then  -- 待命中，界面上也显示驻军中
			local label = ui.newTTFLabel({text = CommonText[320][4] .. "...", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))
			-- local label = ui.newTTFLabel({text = CommonText[320][6] .. "...", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			-- label:setAnchorPoint(cc.p(0, 0.5))
		elseif  army.state == ARMY_STATE_GARRISON then  -- 驻军中
			local label = ui.newTTFLabel({text = CommonText[320][4] .. "...", font = G_FONT, size = FONT_SIZE_TINY, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif army.state == ARMY_STATE_FORTRESS or army.state == ARMY_AIRSHIP_GUARD then  -- 驻军中
		else
			local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(cell)
			bar:setPosition(170 + bar:getContentSize().width / 2, self.m_cellSize.height - 74)
			bar:setPercent(0)
			cell.timeBar = bar

			local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, self.m_cellSize.height - 74 - 30):addTo(cell)
			clock:setAnchorPoint(cc.p(0, 0.5))
			local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(cell)
			time:setAnchorPoint(cc.p(0, 0.5))
			time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
			cell.timeLabel = time
		end

		-- 详情按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
		local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDetailCallback))
		detailBtn.army = army
		cell:addButton(detailBtn, self.m_cellSize.width - 172, self.m_cellSize.height / 2 - 22)

		if army.state == ARMY_STATE_MARCH or army.state == ARMY_STATE_RETURN or army.state == ARMY_STATE_AID_MARCH then -- 行军、返回中
			-- 加速按钮
			local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
			local accelBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onAccelCallback))
			accelBtn.army = army
			cell:addButton(accelBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
		elseif army.state == ARMY_STATE_COLLECT or army.state == ARMY_STATE_WAITTING or army.state == ARMY_STATE_GARRISON 
			or (army.state >= ARMY_AIRSHIP_BEGAIN and army.state <= ARMY_AIRSHIP_GUARD) then -- 采集、等待、驻军中
			local normal = display.newSprite(IMAGE_COMMON .. "btn_back_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_back_selected.png")
			local backBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onBackCallback))
			backBtn.army = army
			cell:addButton(backBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
		end
	elseif index <= VipBO.getArmyCount() then
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(222, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local itemView = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local bg = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(itemView, -1)
		bg:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)

		local tag = display.newSprite(IMAGE_COMMON .. "icon_time.png")
		local desc = ui.newTTFLabel({text = CommonText[481][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = self.m_cellSize.height - 74, color = COLOR[11]}):addTo(cell)
		desc:setAnchorPoint(cc.p(0, 0.5))

		local zhujun = ArmyMO.getZhujunFightArmies()
		if zhujun <= 0 and index == VipBO.getArmyCount() then
			tag = display.newSprite(IMAGE_COMMON .. "icon_zhujun.jpg")
			tag:setScale(0.9)
			desc:setString(CommonText[1630])
		end
		tag:addTo(itemView)
		tag:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)
		-- 待命中
		local title = ui.newTTFLabel({text = CommonText[320][6] .. "...", font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[1]}):addTo(cell)


		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onGoCallback))
		cell:addButton(goBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	else
		local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(222, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

		local itemView = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(cell)
		itemView:setPosition(100, self.m_cellSize.height / 2)

		local bg = display.newSprite(IMAGE_COMMON .. "item_bg_1.png"):addTo(itemView, -1)
		bg:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)

		local tag = display.newSprite(IMAGE_COMMON .. "icon_lock_1.png"):addTo(itemView)
		tag:setPosition(itemView:getContentSize().width / 2, itemView:getContentSize().height / 2)

		local title = ui.newTTFLabel({text = "VIP" .. self.m_tipMoreArmyVip .. CommonText[50], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = 114, color = COLOR[6]}):addTo(cell)

		local desc = ui.newTTFLabel({text = CommonText[481][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = self.m_cellSize.height - 74, color = COLOR[11]}):addTo(cell)

		local normal = display.newSprite(IMAGE_COMMON .. "btn_nxt_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_nxt_selected.png")
		local goBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onVipCallback))
		cell:addButton(goBtn, self.m_cellSize.width - 82, self.m_cellSize.height / 2 - 22)
	end

	-- scheduler.performWithDelayGlobal(function() self:update() end, 0.01)

	return cell
end

function ArmyTaskTableView:update(dt)
	local cellNum = self:numberOfCells()
	for index = 1, cellNum do
		local cell = self:cellAtIndex(index)
		if cell then
			if cell.timeBar and cell.timeLabel then
				local army = cell.army
				-- dump(grab, "!!!!!!!")
				-- gdump(army, "army")

				local leftTime = SchedulerSet.getTimeById(army.schedulerId)
				local percent = 0
				if army.period == 0 then
					percent = 1
				else
					percent = (army.period - leftTime) / army.period
				end
				-- gprint("percent:", percent, "leftTime:", leftTime)
				if army.state == ARMY_STATE_COLLECT then
					local grabCount = 0

					local grab = MailBO.parseGrab(army["grab"])
					if cell.resId then
						for index = 1, #grab do
							if grab[index].id == cell.resId then
								grabCount = grabCount + grab[index].count
							end
						end
					end

					local load = 0
					local totalLoad = 0
					if army.collect then
						load = math.floor((army.collect.load - grabCount) * percent) + grabCount
						totalLoad = army.collect.load
					else
						local analyseData = TankBO.analyseFormation(army.formation)
						load = math.floor((analyseData.payload - grabCount) * percent) + grabCount
						totalLoad = analyseData.payload
					end
					if load < 0 then load = 0 end

					cell.timeBar:setLabel(UiUtil.strNumSimplify(load) .. "/" .. UiUtil.strNumSimplify(totalLoad))
					percent = load / totalLoad
					cell.timeBar:setPercent(percent)
				else
					local army = cell.army
					local leftTime = SchedulerSet.getTimeById(army.schedulerId)
					local percent = 0
					if army.period == 0 then
						percent = 1
					else
						percent = (army.period - leftTime) / army.period
					end

					cell.timeBar:setPercent(percent)
				end
				cell.timeLabel:setString(UiUtil.strBuildTime(leftTime))
				-- cell.timeBar:setPercent(percent)
			end
		end
	end
end

function ArmyTaskTableView:onDetailCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local army = sender.army
	if RoyaleSurviveMO.isActOpen() then
		RoyaleSurviveBO.getCollectInfo(function (score, gold)
			local honourGold = gold
			local honourScore = score
			HeroBO.getNewHeroInfo(function (heroGold, stafExp)
				local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
				ReportArmyDetailView.new(army, score, gold, heroGold, stafExp):push()
			end, army.keyId)
		end, army.keyId)
	else
		HeroBO.getNewHeroInfo(function (heroGold, stafExp)
			local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
			ReportArmyDetailView.new(army, nil, nil, heroGold, stafExp):push()
		end, army.keyId)
	end
end

function ArmyTaskTableView:onAccelCallback(tag, sender)
	if ArmyBO.isAsk then return end
	ManagerSound.playNormalButtonSound()
	local army = sender.army
	local leftTime = SchedulerSet.getTimeById(army.schedulerId)
	if leftTime <= 0 then  -- 已经没有剩余时间了
		return
	end
	local needCoin = math.ceil(leftTime / BUILD_ACCEL_TIME)
	local function doneCallback()
		Loading.getInstance():unshow()
	end

	local resData = UserMO.getResourceData(ITEM_KIND_COIN)
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[317], needCoin, resData.name), function()
			local count = UserMO.getResource(ITEM_KIND_COIN)
			if count < needCoin then
				Toast.show(resData.name .. CommonText[223])
				return
			end
			leftTime = SchedulerSet.getTimeById(army.schedulerId)
			if leftTime <= 0 then  -- 已经没有剩余时间了
				return
			end
			Loading.getInstance():show()
			ArmyBO.isAsk = true
			ArmyBO.asynSpeedArmy(doneCallback, army.keyId)
		end):push()
end

function ArmyTaskTableView:onBackCallback(tag, sender)
	if ArmyBO.isAsk then return end
	ManagerSound.playNormalButtonSound()
	local function doneCallback()
		Loading.getInstance():unshow()
	end

	local army = sender.army
	if army.state == ARMY_STATE_COLLECT then  -- 采集
		local leftTime = SchedulerSet.getTimeById(army.schedulerId)
		if leftTime > 0 then
			-- 采集未满，确定返回
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(CommonText[321], function()
					Loading.getInstance():show()
					ArmyBO.isAsk = true
					WorldBO.asynRetreat(doneCallback, army.keyId)
				end):push()
		else
			Loading.getInstance():show()
			ArmyBO.isAsk = true
			WorldBO.asynRetreat(doneCallback, army.keyId)
		end
	elseif army.state == ARMY_STATE_GARRISON or army.state == ARMY_STATE_WAITTING 
		or army.state >= ARMY_AIRSHIP_BEGAIN then
			if army.state == ARMY_AIRSHIP_MARCH then -- 飞艇行军(撤回需要扣除道具)
				local count = UserMO.getResource(ITEM_KIND_PROP, PROP_ID_MARCH_RECALL)
				local resData = UserMO.getResourceData(ITEM_KIND_PROP, PROP_ID_MARCH_RECALL)
				local ConfirmDialog = require("app.dialog.ConfirmDialog")
				ConfirmDialog.new(string.format(CommonText[1004], resData.name .. "*1"), function()
					if count <= 0  then
						Toast.show(resData.name .. CommonText[1039])
						return
					end
					Loading.getInstance():show()
					ArmyBO.isAsk = true
					WorldBO.asynRetreat(doneCallback, army.keyId)
				end):push()
			else
				Loading.getInstance():show()
				ArmyBO.isAsk = true
				WorldBO.asynRetreat(doneCallback, army.keyId)
			end
	end
end

function ArmyTaskTableView:onGoCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	UiDirector.popMakeUiTop("HomeView")
	local homeView = UiDirector.getUiByName("HomeView")
	homeView:showChosenIndex(MAIN_SHOW_WORLD)
end

function ArmyTaskTableView:onVipCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.VipView").new():push()
end

return ArmyTaskTableView
