
-- 竞技场view

local ArenaView = class("ArenaView", UiNode)

function ArenaView:ctor()
	ArenaView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function ArenaView:onEnter()
	ArenaView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(BUILD_ID_ARENA)

	self:setTitle(self.m_build.name)

	ArenaBO.asynGetArena()

	self.m_isGetArenaData = false

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_getHandler = Notify.register(LOCLA_GET_ARENA_EVENT, handler(self, self.onGetArena))
	self.m_updateHandler = Notify.register(LOCAL_COMBAT_UPDATE_EVENT, handler(self, self.onCombatUpdate))
	self.m_scoreHandler = Notify.register(LOCAL_SCORE_EVENT, handler(self, self.onScoreUpdate))
	self.m_reportHandler = Notify.register(LOCAL_JJC_REPORT_UPDATE_EVENT, handler(self, self.updateTip))

	local function createDelegate(container, index)
		if index == 1 then  -- 挑战
			self:showChallenge(container)
		elseif index == 2 then -- 设置阵型
			self:showFormat(container)
		end
	end

	local function clickDelegate(container, index)
		if ArenaMO.firstEnter_  and index == 1 then
			-- 首次进入需要设置阵型
			self.m_pageView:setPageIndex(2)
			Toast.show(CommonText[280])
		end
	end

	--  "挑战", "设置阵型"
	local pages = {CommonText[34], CommonText[15]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function ArenaView:onExit()
	ArenaView.super.onExit(self)

-- 	-- gprint("ArenaView onExit() ........................")

	if self.m_getHandler then
		Notify.unregister(self.m_getHandler)
		self.m_getHandler = nil
	end

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end

	if self.m_scoreHandler then
		Notify.unregister(self.m_scoreHandler)
		self.m_scoreHandler = nil
	end

	if self.m_reportHandler then
		Notify.unregister(self.m_reportHandler)
		self.m_reportHandler = nil
	end

	
end

function ArenaView:onGetArena()
	self.m_isGetArenaData = true

	if ArenaMO.firstEnter_ then
		-- 首次进入需要设置阵型
		self.m_pageView:setPageIndex(2)
		Toast.show(CommonText[280])
	else
		if self.m_pageView:getPageIndex() == 1 then
			local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
			self:showChallenge(container)
		end
	end
end

function ArenaView:update(dt)
	if self.m_pageView:getPageIndex() == 1 then
		local container = self.m_pageView:getContainerByIndex(self.m_pageView:getPageIndex())
		if container and container.cdLabel_ then
			if ArenaMO.getCdTime() > 0 then
				container.cdLabel_:setString("(" .. UiUtil.strBuildTime(ArenaMO.getCdTime()) .. ")")
			else
				container.cdLabel_:setString("")
			end
		end
	end
end

function ArenaView:showChallenge(container)
	if not self.m_isGetArenaData then return end

	-- 排名
	local rank = ArenaBO.createRank(ArenaMO.currentRank_):addTo(container)
	rank:setPosition(60, container:getContentSize().height - 55)

	-- 头像
	local portrait = UiUtil.createItemView(ITEM_KIND_PORTRAIT, UserMO.portrait_):addTo(container)
	portrait:setScale(0.4)
	portrait:setPosition(145, container:getContentSize().height - 55)

	-- 玩家自己
	local label = ui.newTTFLabel({text = CommonText[247], font = G_FONT, size = FONT_SIZE_SMALL, x = 200, y = container:getContentSize().height - 30, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 等级
	local label = ui.newTTFLabel({text = CommonText[113] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local lvlabel = ui.newTTFLabel({text = UserMO.level_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	lvlabel:setAnchorPoint(cc.p(0, 0.5))

	-- 阵型战力
	local label = ui.newTTFLabel({text = CommonText[248] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = label:getPositionY() - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local numLabel = ui.newBMFontLabel({text = UiUtil.strNumSimplify(ArenaMO.fightValue_), font = "fnt/num_2.fnt", x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY()}):addTo(container)
	numLabel:setAnchorPoint(cc.p(0, 0.5))

	-- 挑战次数
	local label = ui.newTTFLabel({text = CommonText[249] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width - 228, y = container:getContentSize().height - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.arenaLeftCount_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	if ArenaMO.arenaLeftCount_ <= 0 then
		label:setColor(COLOR[5])
	end

	local label = ui.newTTFLabel({text = "/" .. ARENA_FIGHT_TOTAL_TIME, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local cdLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width + 5, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	cdLabel:setAnchorPoint(cc.p(0, 0.5))
	container.cdLabel_ = cdLabel

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.arena):push()
	end

	-- 详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 188, container:getContentSize().height - 82)

	-- 添加
	local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
	local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onBuyCallback)):addTo(container)
	addBtn:setPosition(container:getContentSize().width - 75, container:getContentSize().height - 82)

	local ArenaPlayerTableView = require("app.scroll.ArenaPlayerTableView")
	local view = ArenaPlayerTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 140 - 120 - 4), ArenaMO.rivals_):addTo(container)
	view:setPosition(0, 140)
	view:reloadData()

	-- 连胜次数
	local label = ui.newTTFLabel({text = CommonText[250] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 110 - 90, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.winStreak_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local function onRecordCallback(tag, sender)
		ManagerSound.playNormalButtonSound()

		if #MailMO.myJJCPersonReprot_ > 0 then
			self:openBattleReportView()
		else
			MailBO.getMails(function()
				self:openBattleReportView()
				end,MAIL_TYPE_PERSON_JJC)
		end
	end

	-- 挑战记录
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local recordBtn = MenuButton.new(normal, selected, nil, onRecordCallback):addTo(container)
	recordBtn:setLabel(CommonText[253])
	recordBtn:setPosition(110, 50)
	self.recordBtn = recordBtn

	-- 当前积分
	local label = ui.newTTFLabel({text = CommonText[251] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2 - 90, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_SCORE), font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local function onScoreCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ScoreShopView = require("app.view.ScoreShopView")
		ScoreShopView.new():push()
	end

	-- 积分兑换
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_10_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_10_selected.png')
	local scoreBtn = MenuButton.new(normal, selected, nil, onScoreCallback):addTo(container)
	scoreBtn:setLabel(CommonText[254])
	scoreBtn:setPosition(container:getContentSize().width / 2, 50)

	-- 上期排名
	local label = ui.newTTFLabel({text = CommonText[252] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width - 110 - 90, y = 110, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = ArenaMO.lastRank_, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local function onReceiveCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ArenaAwardView = require("app.view.ArenaAwardView")
		ArenaAwardView.new():push()
	end

	-- 领取奖励
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_10_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_10_selected.png')
	local receiveBtn = MenuButton.new(normal, selected, nil, onReceiveCallback):addTo(container)
	receiveBtn:setLabel(CommonText[255])
	receiveBtn:setPosition(container:getContentSize().width - 110, 50)

	self:updateTip()
end

function ArenaView:showFormat(container)
	local ArmySettingView = require("app.view.ArmySettingView")

	local armySettingFor = ARMY_SETTING_FOR_ARENA
	local view = ArmySettingView.new(container:getContentSize(), armySettingFor):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	self.armySettingView = view
end

function ArenaView:onBuyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if ArenaMO.buyCount_ >= VipBO.getAreanBuyCount() then  -- VIP不足
		Toast.show(CommonText[366][1])
		return
	end
	
	local function doneBuy()
		Loading.getInstance():unshow()
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end
	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[260], ArenaMO.getBuyTakeCoin(), resData.name), function()
			Loading.getInstance():show()
			ArenaBO.asynBuyArena(doneBuy)
		end):push()
end

function ArenaView:onCombatUpdate()
	gprint("[ArenaView] onCombatUpdate")
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())

	-- 显示奖励
	UiUtil.showAwards(CombatMO.curBattleAward_)
	CombatMO.curBattleAward_ = nil
end

function ArenaView:onScoreUpdate()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function ArenaView:openBattleReportView()
	local BattleReportView = require("app.view.BattleReportView")
	BattleReportView.new():push()
end

function ArenaView:updateTip()
	if tolua.isnull(self.recordBtn) then
		return
	end
	local newReportCount = MailBO.getNewReportCount(MAIL_TYPE_PERSON_JJC)
	if newReportCount > 0 then
		UiUtil.showTip(self.recordBtn, newReportCount, 170, 60)
	else
		UiUtil.unshowTip(self.recordBtn)
	end
end

return ArenaView
