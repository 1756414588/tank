
--------------------------------------------------------------------
-- 伤害排名 tableview
--------------------------------------------------------------------

local HurtTableView = class("HurtTableView", TableView)

function HurtTableView:ctor(size, rankData)
	HurtTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 80)

	self.m_rankData = rankData
	-- self.m_rankData = {{rank = 1, name = "a", hurt = 1000}, {rank = 2, name = "b", hurt = 999}}
end

function HurtTableView:onEnter()
	HurtTableView.super.onEnter(self)
end

function HurtTableView:numberOfCells()
	return #self.m_rankData
end

function HurtTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HurtTableView:createCellAtIndex(cell, index)
	HurtTableView.super.createCellAtIndex(self, cell, index)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(450, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2 + 5, 5)

	local rankData = self.m_rankData[index]

	-- 排行
	local rankView = ArenaBO.createRank(rankData.rank):addTo(cell)
	rankView:setPosition(85, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = rankData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 280 - 40, y = 52, color = ArenaBO.getRankColor(rankData.rank), align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	name:setAnchorPoint(cc.p(0, 0.5))
	-- cell.name = rankData.name

	local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(rankData.hurt), font = G_FONT, size = FONT_SIZE_SMALL, x = 475, y = name:getPositionY(), color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)

	return cell
end

--------------------------------------------------------------------
-- 世界BOSS
--------------------------------------------------------------------

local ActivityBossView = class("ActivityBossView", UiNode)

function ActivityBossView:ctor(activity)
	ActivityBossView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity

	self.m_pageIndex = 1
end

function ActivityBossView:onEnter()
	ActivityBossView.super.onEnter(self)

	self:setTitle(CommonText[10008])

	Loading.getInstance():show()
	ActivityCenterBO.asynGetBoss(function()
			Loading.getInstance():unshow()
			self:showUI()
		end)

	self.m_bossHandler = Notify.register(LOCAL_BOSS_UPDATE_EVENT, handler(self, self.onBossUpdate))
end

function ActivityBossView:showUI()
	local function createDelegate(container, index)
		if index == 1 then  -- 挑战
			self:showChallenge(container)
		elseif index == 2 then -- 设置阵型
			self:showSettingArmy(container)
		elseif index == 3 then -- 伤害排名
			self:showHurtRank(container)
		end
	end

	local function clickDelegate(container, index)
		-- if index == 1 then
		-- 	self:onTick(0)
		-- end
	end

	--  "挑战", "设置阵型", "伤害排名"
	local pages = {CommonText[34], CommonText[15], CommonText[10009]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_tickCount = 0
	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

	self:onTick(0)
end

function ActivityBossView:onExit()
	ActivityBossView.super.onExit(self)

	if self.m_tickHandler then
		ManagerTimer.removeTickListener(self.m_tickHandler)
		self.m_tickHandler = nil
	end

	if self.m_bossHandler then
		Notify.unregister(self.m_bossHandler)
		self.m_bossHandler = nil
	end
end

function ActivityBossView:onTick(dt)
	self:updataActivityState()
end

function ActivityBossView:showChallenge(container)
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_76.jpg"):addTo(container)
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 8)

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.boss):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(bg)
	btn:setPosition(bg:getContentSize().width - 70, bg:getContentSize().height - 60)

	for index = 1, 5 do
		local label = ui.newTTFLabel({text = CommonText[10011][index] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		label:setAnchorPoint(cc.p(0, 0.5))
		label:setPosition(40, bg:getContentSize().height - 50 - (index - 0.5) * 28)

		if index == 1 then  -- 活动状态
			local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			self.m_stateLabel = value
		elseif index == 2 then  -- 我的伤害
			local value = ui.newTTFLabel({text = ActivityCenterMO.boss_.hurt, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		elseif index == 3 then  -- 伤害排名
			local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			if ActivityCenterMO.boss_.hurtRank == 0 then value:setString(CommonText[392])  -- 未上榜
			else value:setString(ActivityCenterMO.boss_.hurtRank) end

		elseif index == 4 then  -- BOSS名称
			local value = ui.newTTFLabel({text = CommonText[10018], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
		elseif index == 5 then  -- BOSS终结者
			local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			value:setAnchorPoint(cc.p(0, 0.5))
			if ActivityCenterMO.boss_.killer and ActivityCenterMO.boss_.killer ~= "" then
				value:setString(ActivityCenterMO.boss_.killer)
			else
				value:setString(CommonText[108])  -- 无
			end
		end
	end

	local boss = display.newSprite(IMAGE_COMMON .. "icon_tank_boss.png"):addTo(bg)
	boss:setPosition(bg:getContentSize().width / 2, 200)
	self.m_bossSprite = boss

	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(510, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(510 + 4, 26)}):addTo(bg)
	bar:setPosition(bg:getContentSize().width / 2, 26)
	bar:setPercent(0)
	self.m_hpBar = bar

	-- 生命X
	local label = ui.newTTFLabel({text = CommonText.attr[2] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(1, 0.5))
	label:setPosition(bg:getContentSize().width / 2, 60)

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_hpLabel = value

	-- 挑战
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onChallengeCallback)):addTo(container)
	btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 530)
	btn:setLabel(CommonText[34])
	self.m_challengeButton = btn

	-- 冷却倒计时
	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2, y = container:getContentSize().height - 590, color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	self.m_cdLabel = value

	local function onCheckedChanged(sender, isChecked)
		ManagerSound.playNormalButtonSound()

		if UserMO.vip_ < ACTIVITY_BOSS_AUTO_FIGHT_VIP then  -- VIP不足
			Toast.show("VIP" .. ACTIVITY_BOSS_AUTO_FIGHT_VIP .. CommonText[50])
			sender:setChecked(false)
			return
		end

		local formation = TankMO.getFormationByType(FORMATION_FOR_BOSS)
		if not TankBO.hasFightFormation(formation) then
			Toast.show(CommonText[193])  -- 阵型是空的
			sender:setChecked(false)
			return
		end

		local function gotoSet(ischeck)
			-- sender:setChecked(isChecked)
			local function doneSetBossAutoFight()
				Loading.getInstance():unshow()
				if ischeck then
					Toast.show(CommonText[10023][1])  -- 设置自动战斗成功
				else
					Toast.show(CommonText[10023][2])  -- 取消自动战斗成功
				end
				self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
			end

			Loading.getInstance():show()
			ActivityCenterBO.asynSetBossAutoFight(doneSetBossAutoFight, ischeck)
		end

		if not isChecked then
			sender:setChecked(true)

			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(CommonText[10024], function(check) gotoSet(check) end, nil, false):push()
		else
			gotoSet(true)
		end
	end

	-- VIP自动战斗
	local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(container)
	checkBox:setPosition(50, 40)
	self.m_autoFightCheckBox = checkBox

	if ActivityCenterMO.boss_.autoFight ~= 0 then  -- 设置了自动战斗
		checkBox:setChecked(true)
	end

	local label = ui.newTTFLabel({text = CommonText[10010], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	label:setPosition(checkBox:getPositionX() + 40, 40)

	local function gotoBless(sener, tag)
		ManagerSound.playNormalButtonSound()
		local BossBlessDialog = require("app.dialog.BossBlessDialog")
		BossBlessDialog.new():push()
	end

	-- 祝福
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, gotoBless):addTo(container)
	btn:setPosition(container:getContentSize().width - 120, 40)
	btn:setLabel(CommonText[538][1])
	self.m_blessButton = btn

	self:onTick(0)
end

function ActivityBossView:onBossUpdate(event)
	if self.m_pageView and self.m_pageView:getPageIndex() == 1 then -- 挑战
		local deltaHurt = 0
		if event and event.obj and event.obj.deltaHurt then
			deltaHurt = event.obj.deltaHurt
		end

		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())

		if deltaHurt > 0 and self.m_bossSprite then
			local label = ui.newBMFontLabel({text = "-" .. deltaHurt, font = "fnt/num_5.fnt", x = self.m_bossSprite:getContentSize().width / 2, y = 25}):addTo(self.m_bossSprite)
			label:setAnchorPoint(cc.p(0.5, 0))
			label:runAction(transition.sequence({cc.MoveBy:create(1.2, cc.p(0, 30)), cc.FadeOut:create(0.3), cc.CallFuncN:create(function(sender) sender:removeSelf() end)}))
		end
	end
end

function ActivityBossView:onChallengeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local formation = TankMO.getFormationByType(FORMATION_FOR_BOSS)
	if not TankBO.hasFightFormation(formation) then
		Toast.show(CommonText[193])  -- 阵型是空的
		return
	end

	local function doneCallback()
		Loading.getInstance():unshow()
		Toast.show(CommonText[10025]) -- 清除冷却时间成功
	end

	local function gotoBuy()
		if ActivityCenterMO.boss_.cdTime <= 0 then return end

		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < math.ceil(ActivityCenterMO.boss_.cdTime) then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		ActivityCenterBO.asynBuyBossCd(doneCallback, math.ceil(ActivityCenterMO.boss_.cdTime))
	end

	if ActivityCenterMO.boss_.autoFight ~= 0 then  -- 设置了自动战斗
		-- 确定取消自动战斗吗
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[10024], function()
				local function doneSet()
					Loading.getInstance():unshow()

					if self.m_autoFightCheckBox then self.m_autoFightCheckBox:setChecked(false) end

					if ActivityCenterMO.boss_.cdTime > 0 then -- 有CD时间，需要提示清除CD时间
						if UserMO.consumeConfirm then
							local resData = UserMO.getResourceData(ITEM_KIND_COIN)

							local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
							CoinConfirmDialog.new(string.format(CommonText[10022], math.ceil(ActivityCenterMO.boss_.cdTime), resData.name), function() gotoBuy() end):push()
						else
							Toast.show(CommonText[10023][2])  -- 取消自动战斗成功
						end
					else
						Toast.show(CommonText[10023][2])  -- 取消自动战斗成功
					end
				end

				Loading.getInstance():show()
				ActivityCenterBO.asynSetBossAutoFight(doneSet, false)  -- 取消自动战斗
			end):push()
		return
	end

	if ActivityCenterMO.boss_.cdTime > 0 then -- 
		if UserMO.consumeConfirm then
			local resData = UserMO.getResourceData(ITEM_KIND_COIN)

			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[10022], math.ceil(ActivityCenterMO.boss_.cdTime), resData.name), function() gotoBuy() end):push()
		else
			gotoBuy()
		end
		return
	end

	if self.m_isFight then return end

	local function doneFightBoss(success)
		self.m_isFight = false

		Loading.getInstance():unshow()

		if success then
			require("app.view.BattleView").new():push()
		end

		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end

	Loading.getInstance():show()
	ActivityCenterBO.asynFightBoss(doneFightBoss)

	self.m_isFight = true
end

-- 更新显示活动状态标签内容
function ActivityBossView:updataActivityState()
	if not self.m_pageView then return end

	local status, cdTime = ActivityCenterBO.getBossStatus()
	if self.m_pageView:getPageIndex() == 1 then -- 挑战
		-- gprint("status:", status, "cdTime:", cdTime)

		self.m_cdLabel:setString("")

		if status == ACTIVITY_BOSS_STATE_CLOSE then
			if ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_OVER then
				self.m_stateLabel:setString(CommonText[10017][4])  -- 活动已结束
				self.m_stateLabel:setColor(COLOR[12])
				
				self.m_hpLabel:setString("X" .. (ACTIVITY_BOSS_TOTAL_LIFE - ActivityCenterMO.boss_.which))
				local percent = ActivityCenterMO.boss_.bossHp / 10000
				self.m_hpBar:setPercent(percent)
				self.m_hpBar:setLabel((string.format("%.2f", percent * 100)) .. "%")
			else  -- 活动未开启
				self.m_stateLabel:setString(CommonText[411])
				self.m_stateLabel:setColor(COLOR[12])

				self.m_hpLabel:setString("X0")
				self.m_hpBar:setPercent(0)
				self.m_hpBar:setLabel((string.format("%.2f", 0)) .. "%")
			end

			self.m_challengeButton:setEnabled(false)
			self.m_blessButton:setEnabled(false)

		elseif status == ACTIVITY_BOSS_STATE_READY then
			self.m_stateLabel:setString(UiUtil.strBuildTime(cdTime, "ms") .. "(" .. CommonText[10017][1] .. ")")  -- 等待中
			self.m_stateLabel:setColor(COLOR[12])

			self.m_hpLabel:setString("X" .. ACTIVITY_BOSS_TOTAL_LIFE)
			self.m_hpBar:setPercent(1)
			self.m_hpBar:setLabel((string.format("%.2f", 1 * 100)) .. "%")

			self.m_challengeButton:setEnabled(false)
			self.m_blessButton:setEnabled(true)
		elseif status == ACTIVITY_BOSS_STATE_FIGHTING then  -- 在战斗时间内
			if ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_FIGHTING then -- 还可战斗
				self.m_stateLabel:setString(UiUtil.strBuildTime(cdTime, "ms") .. "(" .. CommonText[10017][2] .. ")")  -- 活动结束倒计时
				self.m_stateLabel:setColor(COLOR[2])

				self.m_hpLabel:setString("X" .. (ACTIVITY_BOSS_TOTAL_LIFE - ActivityCenterMO.boss_.which))
				local percent = ActivityCenterMO.boss_.bossHp / 10000
				self.m_hpBar:setPercent(percent)
				self.m_hpBar:setLabel((string.format("%.2f", percent * 100)) .. "%")

				if ActivityCenterMO.boss_.cdTime > 0 then -- 冷却时间
					self.m_cdLabel:setString(CommonText[10021] .. ":" .. UiUtil.strBuildTime(ActivityCenterMO.boss_.cdTime, "ms"))
				end
				self.m_challengeButton:setEnabled(true)
				self.m_blessButton:setEnabled(true)
			elseif ActivityCenterMO.boss_.state == ACTIVITY_BOSS_STATE_DIE then -- BOSS被击杀了
				self.m_stateLabel:setString(CommonText[10017][4])
				self.m_stateLabel:setColor(COLOR[12])

				self.m_hpLabel:setString("X0")
				self.m_hpBar:setPercent(0)
				self.m_hpBar:setLabel((string.format("%.2f", 0)) .. "%")

				self.m_challengeButton:setEnabled(false)
				self.m_blessButton:setEnabled(false)
			end
		end
	end

	self.m_tickCount = self.m_tickCount + 1
	if self.m_tickCount % 8 == 0 then  -- 间隔5秒一次
		if status == ACTIVITY_BOSS_STATE_FIGHTING then
			ActivityCenterBO.asynGetBoss()
		end
	end
end

-- 设置部队
function ActivityBossView:showSettingArmy(container)
	local ArmySettingView = require("app.view.ArmySettingView")

	local function onArmyFormation(event)
	end

	local view = ArmySettingView.new(container:getContentSize(), ARMY_SETTING_FOR_BOSS):addTo(container)
	view:addEventListener("ARMY_FORMATION_EVENT", onArmyFormation)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	self.armySettingView = view
end

function ActivityBossView:showHurtRank(container)
	-- 我的伤害
	local label = ui.newTTFLabel({text = CommonText[10012] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = 40, y = container:getContentSize().height - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local hurtLabel = ui.newTTFLabel({text = ActivityCenterMO.boss_.hurt, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	hurtLabel:setAnchorPoint(cc.p(0, 0.5))

	-- 伤害排名
	local label = ui.newTTFLabel({text = CommonText[10011][3] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], x = label:getPositionX(), y = label:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local rankLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[2], x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	rankLabel:setAnchorPoint(cc.p(0, 0.5))
	if ActivityCenterMO.boss_.hurtRank == 0 then rankLabel:setString(CommonText[392]) -- 未上榜
	else rankLabel:setString(ActivityCenterMO.boss_.hurtRank) end

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 20 * 2, container:getContentSize().height - 80 - 90))
	bg:setCapInsets(cc.rect(80, 60, 1, 1))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 80 - bg:getContentSize().height / 2)

	-- 排名
	local label = ui.newTTFLabel({text = CommonText[396][1], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 85, y = bg:getContentSize().height - 25}):addTo(bg)
	-- 角色名
	local label = ui.newTTFLabel({text = CommonText[396][2], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 280, y = label:getPositionY()}):addTo(bg)
	-- 伤害
	local label = ui.newTTFLabel({text = CommonText[401][4], font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER, x = 475, y = label:getPositionY()}):addTo(bg)

	local function gotoAward(sender, tag)
		ManagerSound.playNormalButtonSound()
		local BossAwardDialog = require("app.dialog.BossAwardDialog")
		BossAwardDialog.new():push()
	end

	-- 奖励一览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoAward):addTo(container)
	btn:setPosition(120, 35)
	btn:setLabel(CommonText[771])

	local function gotoReceiveAward(tag, sender)
		local function doneCallback(statsAward)
			UiUtil.showAwards(statsAward)
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		end

		Loading.getInstance():show()
		ActivityCenterBO.asynBossHurtAward(doneCallback)
	end

	local function show(rankData)
		Loading.getInstance():unshow()

		hurtLabel:setString(ActivityCenterMO.boss_.hurt)

		if ActivityCenterMO.boss_.hurtRank == 0 then rankLabel:setString(CommonText[392]) -- 未上榜
		else rankLabel:setString(ActivityCenterMO.boss_.hurtRank) end

		local view = HurtTableView.new(cc.size(bg:getContentSize().width, bg:getContentSize().height - 16 - 50), rankData):addTo(bg)
		view:setPosition(0, 16)
		view:reloadData()
		
		-- 领取奖励
		local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoReceiveAward):addTo(container)
		btn:setPosition(container:getContentSize().width - 120, 35)
		btn:setLabel(CommonText[255])
		awardButton = btn

		if not ActivityCenterMO.boss_.canReceive then
			awardButton:setEnabled(false)
		end
	end

	Loading.getInstance():show()
	ActivityCenterBO.asynGetBossHurtRank(show)
end

return ActivityBossView
