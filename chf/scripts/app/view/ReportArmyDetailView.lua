
-- 报告，部队详情

local ReportArmyDetailView = class("ReportArmyDetailView", UiNode)

-- 部队状态
function ReportArmyDetailView:ctor(army, royaleScore, royaleGold, newHeroGold, stafExp)
	ReportArmyDetailView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_army = army
	self.m_royaleScore = royaleScore
	self.m_royaleGold = royaleGold
	self.m_newHeroGold = newHeroGold
	self.m_stafExp = stafExp

	gdump(army, "ReportArmyDetailView:ctor")

	local res = MailBO.parseGrab(army["grab"])
	gdump(res, "ReportArmyDetailView:ctor grab RES")
end

function ReportArmyDetailView:onEnter()
	ReportArmyDetailView.super.onEnter(self)
	
	self:setTitle(CommonText[316])

	self:setUI()
end

function ReportArmyDetailView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	-- 指挥官
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 26)

	local title = ui.newTTFLabel({text = CommonText[51], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, self.m_army.formation.commander):addTo(container)
	itemView:setScale(0.85)
	itemView:setPosition(122, container:getContentSize().height - 140)

	-- 属性背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(366 + 40, 156 + 40))
	attrBg:setPosition(420, container:getContentSize().height - 130)
	attrBg:setOpacity(0)

	local analyseData = TankBO.analyseFormation(self.m_army.formation)

	-- 战斗力
	local fight = display.newSprite(IMAGE_COMMON .. "label_fight.png"):addTo(attrBg)
	fight:setAnchorPoint(cc.p(0, 0.5))
	fight:setPosition(10, attrBg:getContentSize().height - 25)

	local fightNum = self.m_army.fight and self.m_army.fight > 0 and self.m_army.fight or analyseData.total
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(fightNum), font = "fnt/num_2.fnt"}):addTo(attrBg)
	value:setPosition(fight:getPositionX() + fight:getContentSize().width + 5, fight:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_fightLabel = value

	-- 载重
	local load = display.newSprite(IMAGE_COMMON .. "label_payload.png"):addTo(attrBg)
	load:setAnchorPoint(cc.p(0, 0.5))
	load:setPosition(attrBg:getContentSize().width / 2 + 10, fight:getPositionY())

	local floadNum = 0
	if self.m_army.crossMine then 			--跨服军矿的载重要单独计算
		for index = 1, FIGHT_FORMATION_POS_NUM do
			local format = self.m_army.formation[index]
			if format.tankId > 0 and format.count > 0 then
				local tankDB = TankMO.queryTankById(format.tankId)
				floadNum = floadNum + tankDB.payload * format.count
			end
		end
	else
		local fload = analyseData.payload
		-- [载重] 军团科技加成
		-- if PartyMO.scienceData_ and PartyMO.scienceData_.scienceData then
		-- 	for index =1 , #PartyMO.scienceData_.scienceData do
		-- 		local scienceData = PartyMO.scienceData_.scienceData[index]
		-- 		if scienceData.scienceId == 201 then
		-- 			fload = fload * (1 + scienceData.addtion * scienceData.scienceLv * 0.01)
		-- 		end
		-- 	end
		-- end
		-- [载重] 废墟影响
		if self.m_army.isRuins then
			fload =  fload *(1 - UserMO.querySystemId(24)/10000)
		end
		floadNum = self.m_army.load and self.m_army.load > 0 and self.m_army.load or fload
	end
	local value = ui.newBMFontLabel({text = UiUtil.strNumSimplify(floadNum), font = "fnt/num_2.fnt"}):addTo(attrBg)
	value:setPosition(load:getPositionX() + load:getContentSize().width + 5, load:getPositionY())
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_payloadLabel = value

	local stasFormat = TankBO.stasticsFormation(self.m_army.formation)
	-- self.m_attrLabels[8]:setString(stasFormat.amount .. "/" .. stasFormat.amountTheory)

	-- 带兵
	local label = ui.newTTFLabel({text = CommonText[508], font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = fight:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = stasFormat.amount, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 10, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	-- 部队状态
	local label = ui.newTTFLabel({text = CommonText[318] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local strState = ""

	if self.m_army.state == ARMY_STATE_COLLECT then -- 采集中
		local leftTime = SchedulerSet.getTimeById(self.m_army.schedulerId)
		if leftTime > 0 then -- 还在采集
			strState = CommonText[320][self.m_army.state]
			-- local value = ui.newTTFLabel({text = CommonText[320][self.m_army.state], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			-- value:setAnchorPoint(cc.p(0, 0.5))
		else -- 采集结束
			strState = CommonText[320][5]
			-- local value = ui.newTTFLabel({text = CommonText[320][5], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			-- value:setAnchorPoint(cc.p(0, 0.5))
		end
	else
		if self.m_army.state == ARMY_STATE_MARCH or self.m_army.state == ARMY_STATE_RETURN or self.m_army.state == ARMY_STATE_COLLECT or self.m_army.state == ARMY_STATE_GARRISON then
			strState = CommonText[320][self.m_army.state]
			-- local value = ui.newTTFLabel({text = CommonText[320][self.m_army.state], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			-- value:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_army.state == ARMY_STATE_WAITTING then
			strState = CommonText[320][6]
		elseif self.m_army.state == ARMY_STATE_AID_MARCH then
			strState = CommonText[320][1]
		elseif self.m_army.state == ARMY_STATE_FORTRESS then --要塞驻军
			strState = CommonText[20042]
		elseif self.m_army.state >= ARMY_AIRSHIP_BEGAIN then
			strState = CommonText[998][self.m_army.state]
		end
	end
	
	if self.m_army.state == ARMY_STATE_PARTYB then -- 百团混战
		strState = CommonText[794]
	end

	local value = ui.newTTFLabel({text = strState, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
	value:setAnchorPoint(cc.p(0, 0.5))

	local staffY = label:getPositionY() - 30

	if self.m_army.state == ARMY_STATE_MARCH then -- 行军中
		-- 行军剩余时间
		local label = ui.newTTFLabel({text = CommonText[319] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local leftTime = SchedulerSet.getTimeById(self.m_army.schedulerId)

		local value = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		staffY = label:getPositionY() - 30
	end

	if self.m_army.state == ARMY_STATE_COLLECT then -- 采集中
		-- 已获得编制经验
		local label = ui.newTTFLabel({text = CommonText[10053] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = staffY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		label:setAnchorPoint(cc.p(0, 0.5))

		local staffingExpValue = 0
		if StaffMO.isStaffOpen_ then -- 编制开放
			-- local staffingTime = 0
			-- local curTime = ManagerTimer.getTime()
			-- local endTime = SchedulerSet.getEndTime(self.m_army.schedulerId)
			-- if curTime < endTime then  -- 采集还没有结束
			-- 	staffingTime = curTime - (endTime - self.m_army.period)
			-- else
			-- 	staffingTime = self.m_army.period
			-- end

			-- local mineLv = 0
			-- local mineType = 1
			-- if self.m_army.isMilitary then  -- 是军事矿区
			-- 	local pos = StaffMO.decodePosition(self.m_army.target)
			-- 	local mine = StaffBO.getMineAt(pos)
			-- 	mineLv = mine.lv
			-- 	mineType = 2
			-- elseif self.m_army.crossMine then  -- 是跨服军事矿区
			-- 	local pos = StaffMO.decodeCrossPosition(self.m_army.target)
			-- 	local mine = StaffBO.getCrossMineAt(pos)
			-- 	mineLv = mine.lv
			-- 	mineType = 3
			-- else
			-- 	local pos = WorldMO.decodePosition(self.m_army.target)
			-- 	local mine = WorldBO.getMineAt(pos)
			-- 	mineLv = mine.lv
			-- end
			-- local mineLvDB = WorldMO.queryMineLvByLv(mineLv, mineType)
			-- local pros = UserMO.queryProsperousByLevel(UserMO.prosperousLevel_)
			-- local exp = mineLvDB.staffingExp 
			-- if not self.m_army.isRuins then
			-- 	exp = exp * (1 + pros.staffingAdd / 100)  -- 结算的周期内获得的编制经验
			-- end

			-- -- local count = math.floor(staffingTime / STAFFING_CYCLE_TIME)

			-- -- gprint("ReportArmyDetailView: staffing army period:", self.m_army.period, "exp:", exp, "count:", count)
			-- -- staffingExpValue = exp * count


			-- staffingExpValue = math.floor(exp * staffingTime / STAFFING_CYCLE_TIME)
			staffingExpValue = self.m_stafExp
			-- gprint("self.m_army.period=================", self.m_army.period)
			-- gprint("staffingExpValue=================", staffingExpValue)
		end

		local value = ui.newTTFLabel({text = math.floor(staffingExpValue), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
		value:setAnchorPoint(cc.p(0, 0.5))

		if staffingExpValue > 0 then
			local add = 0
			if EffectBO.getEffectValid(32) then
				add = add + 0.1
			end
			if EffectBO.getEffectValid(34) then
				add = add + 0.1
			end
			if add > 0 then
				UiUtil.label("(+"..math.floor(staffingExpValue*add) ..")",FONT_SIZE_SMALL,COLOR[2]):rightTo(value, 5)
			end
		end

		if self.m_royaleScore and self.m_royaleScore >= 0 then
			local label = ui.newTTFLabel({text = CommonText[2112][1] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = staffY - 30, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = math.floor(self.m_royaleScore), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		if self.m_royaleGold and self.m_royaleGold >= 0 then
			local label = ui.newTTFLabel({text = CommonText[2112][2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = staffY - 60, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = math.floor(self.m_royaleGold), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		if self.m_newHeroGold and self.m_newHeroGold > 0 then
			local x = label:getPositionX()
			if self.m_royaleGold and self.m_royaleGold >= 0 then
				x = x + 180
			end
			local label = ui.newTTFLabel({text = CommonText[2200] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = x, y = staffY - 60, color = COLOR[25], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = math.floor(self.m_newHeroGold), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))
		end
	end

	-- 阵型
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 238)

	local title = ui.newTTFLabel({text = CommonText[52], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	formatBg:setPreferredSize(cc.size(570, 356))
	formatBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 440)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 24, 262):addTo(formatBg)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 24, 94):addTo(formatBg)

	local ArmyFormationView = require("app.view.ArmyFormationView")
	local view = ArmyFormationView.new(FORMATION_FOR_TANK, self.m_army.formation, nil, {showAdd = false}):addTo(container, 10)
	view:setPosition(container:getContentSize().width / 2 + 20, container:getContentSize().height - 606)
	view:setTouchEnabled(false)
end

return ReportArmyDetailView
