--
-- Author: gf
-- Date: 2015-10-29 11:41:55
-- 活动中心


local ActivityCenterTableView = class("ActivityCenterTableView", TableView)

function ActivityCenterTableView:ctor(size,type)
	ActivityCenterTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	if type == ACTIVITY_CENTER_TYPE_NOMAL then
		self.activityList = ActivityCenterMO.activityList_
	elseif type == ACTIVITY_CENTER_TYPE_LIMIT then
		self.activityList = clone(ActivityCenterMO.activityLimitList_)

		if StaffMO.isStaffOpen_ then  -- 如果开启了编制，则添加活动军事矿区
			self.activityList[#self.activityList + 1] = {activityId = ACTIVITY_ID_MILITARY_AREA, name = CommonText[10059][1]}
		end
	elseif type == ACTIVITY_CENTER_TYPE_CROSS then
		self.activityList = ActivityCenterMO.activityCrossList_
	end

	self.type = type
end


function ActivityCenterTableView:onEnter()
	ActivityCenterTableView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_ACTIVITY_REBATE_EVENT, handler(self, self.updateTip))

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()
end

function ActivityCenterTableView:numberOfCells()
	return #self.activityList
end

function ActivityCenterTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ActivityCenterTableView:createCellAtIndex(cell, index)
	ActivityCenterTableView.super.createCellAtIndex(self, cell, index)

	local activity = self.activityList[index]
	cell.activity = activity

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local fame = display.newSprite(IMAGE_COMMON .. "item_fame_1.png",70, 65):addTo(bg)

	local icon = nil
	if self.type == ACTIVITY_CENTER_TYPE_CROSS then
		icon = display.newSprite("image/item/kua_" .. activity.activityId .. ".jpg"):addTo(fame)
	else
		icon = display.newSprite("image/item/activity_" .. activity.activityId .. ".jpg"):addTo(fame)
	end
	icon:setScale(0.9)
	icon:setPosition(fame:getContentSize().width / 2, fame:getContentSize().height / 2)
	

	local title = ui.newTTFLabel({text = activity.name, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	title:setAnchorPoint(cc.p(0, 0.5))

	if activity.activityId == ACTIVITY_ID_BOSS then
		local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		status:setAnchorPoint(cc.p(0, 0.5))

		if not ActivityCenterMO.isBossOpen_ then
			status:setString("(" .. CommonText[10026] .. ")")  -- 活动暂未开放
			status:setColor(COLOR[11])
		end

		-- 每周五(20:...)
		local desc = ui.newTTFLabel({text = CommonText[10027], font = G_FONT, size = FONT_SIZE_SMALL, x = 130, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId == ACTIVITY_ID_MILITARY_AREA then   -- 军事矿区
		local status = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = title:getPositionX() + title:getContentSize().width, y = title:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		status:setAnchorPoint(cc.p(0, 0.5))

		if not StaffBO.isMilitaryAreaOpen() then  -- 活动开启的时间还没有到
			status:setString("(" .. CommonText[411] .. ")")  -- 未开启
			status:setColor(COLOR[6])
		end

		-- 每周六-每周日全天开放
		local desc = ui.newTTFLabel({text = CommonText[10057], font = G_FONT, size = FONT_SIZE_SMALL, x = 130, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId == ACTIVITY_ARMY_WAR then   -- 要塞战
		local time = ui.newTTFLabel({text = CommonText[20049], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 380, y = 54, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		time:setAnchorPoint(cc.p(1, 0.5))
	elseif activity.activityId == ACTIVITY_WAR_EXERCISE then   -- 军事演习
		local desc = ui.newTTFLabel({text = CommonText[20064], font = G_FONT, size = FONT_SIZE_SMALL, x = 130, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId == ACTIVITY_REBEL_COME then   -- 叛军入侵
		local desc = ui.newTTFLabel({text = CommonText[20115], font = G_FONT, size = FONT_SIZE_SMALL, x = 130, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId == ACTIVITY_ROYALE_SURVIVE then
		local desc = ui.newTTFLabel({text = CommonText[20228], font = G_FONT, size = FONT_SIZE_SMALL, x = 130, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId <= #ActivityCenterMO.activityCrossList_ then
		local desc = ui.newTTFLabel({text = CommonText[10026], font = G_FONT, size = FONT_SIZE_SMALL, x = 155, y = 54, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		desc:setAnchorPoint(cc.p(0, 0.5))
		if activity.time then
			UiUtil.label(CommonText[326][1],nil,COLOR[2]):rightTo(title)
			desc:setString(activity.time)
			desc:setColor(COLOR[2])
		end
	else
		local time = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. "-" .. os.date("%Y/%m/%d %X", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 500, y = 54, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		time:setAnchorPoint(cc.p(1, 0.5))

		cell.m_timeLab = time
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetailhandler))
	detailBtn.activity = activity
	self.m_detailBtns[index] = detailBtn
	cell:addButton(detailBtn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 20)

	return cell
end

function ActivityCenterTableView:openDetailhandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:openDetail(sender.activity)
end

function ActivityCenterTableView:cellTouched(cell, index)
	ManagerSound.playNormalButtonSound()
	local activity = self.activityList[index]
	self:openDetail(activity)
end

function ActivityCenterTableView:openDetail(activity)
	if self.type == ACTIVITY_CENTER_TYPE_NOMAL then
		local function show()
			Loading.getInstance():unshow()
			if activity.activityId == ACTIVITY_ID_MECHA then
				UiDirector.push(require("app.view.ActivityMechaView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_AMY_REBATE or activity.activityId == ACTIVITY_ID_OPENSERVER then
				UiDirector.push(require("app.view.ActivityRebateView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_FORTUNE or activity.activityId == ACTIVITY_ID_PARTDIAL or activity.activityId == ACTIVITY_ID_ENERGYSPAR or 
					activity.activityId == ACTIVITY_ID_EQUIPDIAL or activity.activityId == ACTIVITY_ID_TACTICSPAR then
				UiDirector.push(require("app.view.ActivityFortuneView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_BEE or activity.activityId == ACTIVITY_ID_BEE_NEW then
				UiDirector.push(require("app.view.ActivityBeeView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_PROFOTO then
				UiDirector.push(require("app.view.ActivityProfotoView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TANKRAFFLE then
				UiDirector.push(require("app.view.ActivityRaffleView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TANKDESTROY then
				UiDirector.push(require("app.view.ActivityDestroyView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TECH then
				UiDirector.push(require("app.view.ActivityTechView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_GENERAL or activity.activityId == ACTIVITY_ID_GENERAL1 then
				UiDirector.push(require("app.view.ActivityGeneralView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_CONSUMEDIAL then
				UiDirector.push(require("app.view.ActivityConsumeDialView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_VACATION then
				UiDirector.push(require("app.view.ActivityVacationView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_PART_RESOLVE or activity.activityId == ACTIVITY_ID_MEDAL_RESOLVE then
				UiDirector.push(require("app.view.ActivityPartResolveView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_EXCHANGE_EQUIP or activity.activityId == ACTIVITY_ID_EXCHANGE_PAPER then
				UiDirector.push(require("app.view.ActivityEquipCashView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_EXCHANGE_PART then
				UiDirector.push(require("app.view.ActivityPartCashView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_GAMBLE then
				UiDirector.push(require("app.view.ActivityGambleView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_PAYTURNTABLE then
				UiDirector.push(require("app.view.ActivityPayTurntableView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_CELEBRATE then
				UiDirector.push(require_ex("app.view.ActivityCelebrateView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TANKRAFFLE_NEW then
				UiDirector.push(require("app.view.ActivityNewRaffleView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TANK_CARNIVAL then
				UiDirector.push(require("app.view.ActivityTankCarnival").new(activity))
			elseif activity.activityId == ACTIVITY_ID_COLLECRION then
				UiDirector.push(require("app.view.ActivityCollection").new(activity))
			elseif activity.activityId == ACTIVITY_ID_M1A2 then
				UiDirector.push(require("app.view.ActivityM1A2View").new(activity))
			elseif activity.activityId == ACTIVITY_ID_FLOWER then
				UiDirector.push(require("app.view.ActivityFlower").new(activity))
			elseif activity.activityId == ACTIVITY_ID_RECHARGE then
				UiDirector.push(require("app.view.ActivityRecharge").new(activity))
			elseif activity.activityId == ACTIVITY_ID_STOREHOUSE then
				UiDirector.push(require("app.view.ActivityStorehouse").new(activity))
			elseif activity.activityId == ACTIVITY_ID_NEWYEAR then
				UiDirector.push(require("app.view.ActivityNewYearBoss").new(activity))
			elseif activity.activityId == ACTIVITY_ID_FESTIVAL then
				UiDirector.push(require("app.view.ActivityFestival").new(activity))
			elseif activity.activityId == ACTIVITY_ID_CLEAR then
				UiDirector.push(require("app.view.ActivityPayClear").new(activity))
			elseif activity.activityId == ACTIVITY_ID_WORSHIP then
				UiDirector.push(require("app.view.ActivityWorship").new(activity))
			elseif activity.activityId == ACTIVITY_ID_BANDITS then
				UiDirector.push(require("app.view.ActivityBandits").new(activity))
			elseif activity.activityId == ACTIVITY_ID_SCHOOL then
				UiDirector.push(require("app.view.ActivitySchool").new(activity))
			elseif activity.activityId == ACTIVITY_ID_REFINE_MASTER then --淬炼大师活动
				UiDirector.push(require("app.view.ActivityRefineMasterView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_NEWENERGY then --能量灌注
				UiDirector.push(require("app.view.ActivityNewEnergyView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_OWNGIFT then
				UiDirector.push(require("app.view.ActivityOwnGiftView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_BROTHER then
				UiDirector.push(require("app.view.ActivityBrotherBuffView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_HYPERSPACE then
				UiDirector.push(require("app.view.ActivityHyperSpaceView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_SECRETARMY then
				UiDirector.push(require("app.view.ActivitySecretArmyView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_MEDAL then
				UiDirector.push(require("app.view.ActivityMedalView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_MONOPOLY then
				UiDirector.push(require("app.view.ActivityMonopolyView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_REDPACKET then
				UiDirector.push(require("app.view.ActivityRedPacketView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_RED_SCHEME then
				UiDirector.push(require("app.view.ActivityCommunismView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_FRAG_EXCHANGE then --碎片兑换活动
				UiDirector.push(require("app.view.ActivityFragExcView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_LUCKYROUND then -- 幸运奖池
				UiDirector.push(require("app.view.ActivityLuckyRoundView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_TANKEXCHANGE then -- 坦克转换
				ActivityCenterBO.getTankExc(function (data)
					UiDirector.push(require("app.view.ActivityTankExcView").new(activity, data))
				end)
			elseif activity.activityId == ACTIVITY_ID_QUESTION_ANSWER then -- 有奖问答
				if UserMO.level_ < activity.minLv then
					Toast.show(string.format(CommonText[1125],activity.minLv))
					return
				end
				local activityContent = ActivityCenterMO.activityContents_[activity.activityId]
				if activityContent.queStatus == 1 then
					Toast.show(CommonText[1156])
					return
				end
				UiDirector.push(require("app.view.ActivityQuestionView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_PARTY_PAY then -- 军团充值
				UiDirector.push(require("app.view.ActivityPartyPayView").new(activity))
			elseif activity.activityId == ACTIVITY_ID_ACTIVITY_KING then -- 最强王者
				UiDirector.push(require("app.view.ActivityKingView").new(activity))
			end
			-- WARNING: 所有限时活动须在 ActivityCenterBO.RegisterActivityList 表中注册 
		end

		if activity.activityId ~= ACTIVITY_ID_SECRETARMY and activity.activityId ~= ACTIVITY_ID_PARTY_PAY and activity.activityId ~= ACTIVITY_ID_ACTIVITY_KING then
			local activityContent = ActivityCenterMO.getActivityContentById(activity.activityId)
			-- gdump(activityContent,"activityContentactivityContent")
			if activityContent 
				or activity.activityId == ACTIVITY_ID_AMY_REBATE or activity.activityId == ACTIVITY_ID_ENERGYSPAR
				or activity.activityId == ACTIVITY_ID_OPENSERVER --开服狂欢
				or activity.activityId == ACTIVITY_ID_EQUIPDIAL
				or activity.activityId == ACTIVITY_ID_FORTUNE 
				or activity.activityId == ACTIVITY_ID_PARTDIAL 
				or activity.activityId == ACTIVITY_ID_BEE or activity.activityId == ACTIVITY_ID_BEE_NEW
				or activity.activityId == ACTIVITY_ID_PROFOTO 
				or activity.activityId == ACTIVITY_ID_TANKDESTROY 
				or activity.activityId == ACTIVITY_ID_GENERAL or activity.activityId == ACTIVITY_ID_GENERAL1
				or activity.activityId == ACTIVITY_ID_CONSUMEDIAL 
				or activity.activityId == ACTIVITY_ID_VACATION
				or activity.activityId == ACTIVITY_ID_PART_RESOLVE 
				or activity.activityId == ACTIVITY_ID_MEDAL_RESOLVE
				or activity.activityId == ACTIVITY_ID_EXCHANGE_EQUIP 
				or activity.activityId == ACTIVITY_ID_EXCHANGE_PART 
				or activity.activityId == ACTIVITY_ID_GAMBLE 
				or activity.activityId == ACTIVITY_ID_PAYTURNTABLE 
				or activity.activityId == ACTIVITY_ID_CELEBRATE 
				or activity.activityId == ACTIVITY_ID_COLLECRION
				or activity.activityId == ACTIVITY_ID_FLOWER
				or activity.activityId ==  ACTIVITY_ID_RECHARGE
				or activity.activityId ==  ACTIVITY_ID_STOREHOUSE
				or activity.activityId ==  ACTIVITY_ID_NEWYEAR
				or activity.activityId ==  ACTIVITY_ID_FESTIVAL 
				or activity.activityId == ACTIVITY_ID_CLEAR
				or activity.activityId == ACTIVITY_ID_WORSHIP
				or activity.activityId == ACTIVITY_ID_BANDITS
				or activity.activityId == ACTIVITY_ID_SCHOOL
				or activity.activityId == ACTIVITY_ID_REFINE_MASTER
				or activity.activityId == ACTIVITY_ID_NEWENERGY
				or activity.activityId == ACTIVITY_ID_OWNGIFT 
				or activity.activityId == ACTIVITY_ID_BROTHER
				or activity.activityId == ACTIVITY_ID_HYPERSPACE 
				or activity.activityId == ACTIVITY_ID_MEDAL 
				or activity.activityId == ACTIVITY_ID_MONOPOLY
				or activity.activityId == ACTIVITY_ID_REDPACKET
				or activity.activityId == ACTIVITY_ID_RED_SCHEME --红色方案
				or activity.activityId == ACTIVITY_ID_FRAG_EXCHANGE --碎片兑换
				or activity.activityId == ACTIVITY_ID_LUCKYROUND -- 幸运奖池
				or activity.activityId == ACTIVITY_ID_TANKEXCHANGE -- 坦克转换
				or activity.activityId == ACTIVITY_ID_EXCHANGE_PAPER -- 图纸兑换
				-- or activity.activityId == ACTIVITY_ID_ACTIVITY_KING --  最强王者
				or activity.activityId == ACTIVITY_ID_TACTICSPAR
				 then
				if activity.minLv and activity.minLv > 0 and UserMO.level_ < activity.minLv then
					Toast.show(string.format(CommonText[1125],activity.minLv))
				else
					show()
					-- 埋点
					Statistics.postPoint(STATIS_ACTIVITY + activity.activityId)
				end
			else
				Loading.getInstance():show()
				ActivityCenterBO.asynGetActivityContent(show, activity.activityId,1)
			end
		else
			if activity.activityId == ACTIVITY_ID_ACTIVITY_KING then  --不拉协议直接进界面
				show()
			else
				Loading.getInstance():show()
				ActivityCenterBO.asynGetActivityContent(show, activity.activityId,1)
			end
		end
	elseif self.type == ACTIVITY_CENTER_TYPE_LIMIT then
		if activity.activityId == ACTIVITY_ID_BOSS then  -- 世界BOSS
			if not ActivityCenterMO.isBossOpen_ then
				Toast.show(CommonText[10026])
				return
			end

			if UserMO.level_ < ACTIVITY_BOSS_OPEN_LEVEL then
				Toast.show(string.format(CommonText[290], ACTIVITY_BOSS_OPEN_LEVEL, activity.name))
				return
			end

			local ActivityBossView = require("app.view.ActivityBossView")
			ActivityBossView.new():push()
		elseif activity.activityId == ACTIVITY_ID_MILITARY_AREA then  -- 军事矿区
			if not StaffMO.isStaffOpen_ then
				Toast.show(CommonText[10058][2])  -- 开服31天后开启军事矿区
				return
			end

			if UserMO.level_ < ACTIVITY_MILITARY_AREA_OPNE_LV then
				Toast.show(string.format(CommonText[290], ACTIVITY_MILITARY_AREA_OPNE_LV, activity.name))
				return
			end

			local HomeView = require("app.view.HomeView")
			local view = HomeView.new(MAIN_SHOW_MINE_AREA):push()

			-- local MineMap = require("app.mine.MineMap")
			-- local view = MineMap.new(cc.size(display.width, display.height - 100 - 30), mapInfo):addTo(self)
			-- view:setPosition((self:getContentSize().width - view:getContentSize().width) / 2, 102)
		elseif activity.activityId == ACTIVITY_ARMY_WAR then  -- 要塞战
			-- if GameConfig.areaId > 5 then
			-- 	Toast.show(CommonText[64])
			-- 	return
			-- end
			local HomeView = require("app.view.HomeView")
			local view = HomeView.new(MAIN_SHOW_FORTRESS):push()
		elseif activity.activityId == ACTIVITY_WAR_EXERCISE then  -- 军事演习
			if StaffMO.worldLv_ < 1 then  -- 世界等级达到1级后
				Toast.show(CommonText[10054][2])
				return
			end
			require("app.view.ExerciseView").new():push()
		elseif activity.activityId == ACTIVITY_REBEL_COME then  -- 叛军入侵
			if RebelMO.checkDay(1) then
				require("app.view.RebelView").new():push()
			end
		elseif activity.activityId == ACTIVITY_ROYALE_SURVIVE then
			require("app.view.RoyaleSurvivalView").new():push()
		end
	else
		if activity.time then
			if activity.activityId == ACTIVITY_CROSS_WORLD then
				if UserMO.level_ < UserMO.querySystemId(45) then
					Toast.show(string.format(CommonText[1083], UserMO.querySystemId(45)))
					return
				end
				require("app.view.CrossEnter").new():push()
			elseif activity.activityId == ACTIVITY_CROSS_PARTY then
				require("app.view.CrossPartyEnter").new():push()
			end
		end
	end
end

function ActivityCenterTableView:updateTip()
	if self.type ~= ACTIVITY_CENTER_TYPE_NOMAL then return end
	for index=1,#ActivityCenterMO.activityList_ do
		local activity = ActivityCenterMO.activityList_[index]
		if activity.activityId == ACTIVITY_ID_AMY_REBATE or activity.activityId == ACTIVITY_ID_OPENSERVER then
			local count = ActivityCenterBO.getRebateCountAll()
			if count > 0 then
				gdump(self.m_cellButtons,index)
				if self.m_detailBtns[index] then
					UiUtil.showTip(self.m_detailBtns[index], count, 70, 70)
				else
					UiUtil.unshowTip(self.m_detailBtns[index])
				end
			end
		end
	end
end

function ActivityCenterTableView:reloadData()
	self.m_detailBtns = {}
	ActivityCenterTableView.super.reloadData(self)
	self:updateTip()
end

function ActivityCenterTableView:update(dt)
	if self.type == ACTIVITY_CENTER_TYPE_NOMAL then
		local cellNum = self:numberOfCells()
		for index = 1, cellNum do
			local cell = self:cellAtIndex(index)
			if cell and cell.activity then
				local leftTime = cell.activity.endTime - ManagerTimer.getTime()
				if leftTime > 0 then
					cell.m_timeLab:setString(CommonText[853] .. UiUtil.strActivityTime(leftTime))
				else
					cell.m_timeLab:setString(CommonText[852])
				end
			end
		end
	end
end

function ActivityCenterTableView:onExit()
	ActivityCenterTableView.super.onExit(self)
end



return ActivityCenterTableView