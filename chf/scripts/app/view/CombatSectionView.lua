
-- 选择关卡大类型章节

SECTION_VIEW_FOR_COMBAT  = 1 -- 征战
SECTION_VIEW_FOR_EXPLORE = 2 -- 探险
SECTION_VIEW_FOR_LIMIT   = 3 -- 限时
SECTION_VIEW_FOR_CHALLENGE = 4 --挑战

local CombatSectionView = class("CombatSectionView", UiNode)

function CombatSectionView:ctor(viewFor, uiEnter)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	CombatSectionView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)

	viewFor = viewFor or SECTION_VIEW_FOR_COMBAT
	self.m_viewFor = viewFor
	self.needCoin = nil
end

function CombatSectionView:onEnter()
	CombatSectionView.super.onEnter(self)

	armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

	-- 关卡
	self:setTitle(CommonText[4])

	self.m_updateHandler = Notify.register(LOCAL_COMBAT_UPDATE_EVENT, handler(self, self.onCombatUpdate))
	self.m_boxHandler = Notify.register(LOCAL_COMBAT_BOX_EVENT, handler(self, self.onBoxUpdate))
	self.m_exploreListener = Notify.register("WIPE_COMBAT_EXPLORE_HANDLER", handler(self,self.updatePowerListener))

	local function createDelegate(container, index)
		if index ~= SECTION_VIEW_FOR_EXPLORE then
			self.needCoin = nil
		end
		if index == SECTION_VIEW_FOR_COMBAT then  -- 征战
			self:showFight(container)
		elseif index == SECTION_VIEW_FOR_EXPLORE then -- 探险
			self:showExplor(container)
		elseif index == SECTION_VIEW_FOR_LIMIT then -- 限时
			self:showLimit(container)
		elseif index == SECTION_VIEW_FOR_CHALLENGE then --挑战
			if not UserMO.queryFuncOpen(UFP_BOUNTY_HUNTER) then
				Toast.show(CommonText[1722])
				self:showNotOpen(container)
			else
				HunterBO.getTeamFightBossInfo(function ()
					self:showChallenge(container)
				end)
			end
		end
	end

	local function clickDelegate(container, index)
		CombatMO.curBattleCombatUpdate_ = 0
		CombatMO.curChoseBattleType_ = nil
		CombatMO.curChoseBtttleId_ = nil
	end

	-- "征战", "探险", "限时"}
	local pages = {CommonText[43], CommonText[44], CommonText[45],CommonText[5039]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	--引导触发
	-- NewerBO.showNewerGuide()
end

function CombatSectionView:onEnterEnd()
	CombatSectionView.super.onEnterEnd(self)

	if CombatMO.combatNeedFresh_ or CombatMO.currentCombatId_ == 0 then
		local function doneCallback()
			Loading.getInstance():unshow()
			self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
		end

		Loading.getInstance():show()
		CombatBO.asynGetCombat(doneCallback)

		CombatMO.combatNeedFresh_ = false
	end
end

function CombatSectionView:onExit()
	CombatSectionView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end

	if self.m_boxHandler then
		Notify.unregister(self.m_boxHandler)
		self.m_boxHandler = nil
	end

	if self.m_exploreListener then
		Notify.unregister(self.m_exploreListener)
		self.m_exploreListener = nil
	end
	
	armature_remove("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_remove("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")
end

-- 显示征战
function CombatSectionView:showFight(container)
	local CombatSectionTableView = require("app.scroll.CombatSectionTableView")
	local view = CombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 20), SECTION_VIEW_FOR_COMBAT):addTo(container)
	view:setPosition(0, 20)
	view:reloadData(CombatMO.curBattleCombatUpdate_, CombatMO.curChoseBattleType_, CombatMO.curChoseBtttleId_)

	local resData = UserMO.getResourceData(ITEM_KIND_POWER)

	-- 当前能量
	local desc = ui.newTTFLabel({text = CommonText[73] .. resData.name .. "：", font = G_FONT, size = FONT_SIZE_TINY, x = 20, y = 6}):addTo(container)
	local cur = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_POWER), font = G_FONT, size = FONT_SIZE_TINY,
		x = desc:getPositionX() + desc:getContentSize().width / 2, y = desc:getPositionY(), color = COLOR[2]}):addTo(container)
	local total = ui.newTTFLabel({text = "/" .. POWER_MAX_VALUE, font = G_FONT, size = FONT_SIZE_TINY,
		x = cur:getPositionX() + cur:getContentSize().width / 2, y = cur:getPositionY()}):addTo(container)
	local content = ui.newTTFLabel({text = CommonText[47], font = G_FONT, size = FONT_SIZE_TINY,
		x = total:getPositionX() + total:getContentSize().width / 2, y = total:getPositionY(), color = COLOR[12]}):addTo(container)
end

-- 探险
function CombatSectionView:showExplor(container)
	if UserMO.level_ < 70 then
		local CombatSectionTableView = require("app.scroll.CombatSectionTableView")
		local view = CombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), SECTION_VIEW_FOR_EXPLORE):addTo(container)
		view:setPosition(0, 0)
		view:reloadData()
	else
		local CombatSectionTableView = require("app.scroll.CombatSectionTableView")
		local view = CombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4-130), SECTION_VIEW_FOR_EXPLORE):addTo(container)
		view:setPosition(0, 130)
		view:reloadData()

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
		line:setPreferredSize(cc.size(container:getContentSize().width - 10, line:getContentSize().height))
		line:setPosition(container:getContentSize().width / 2, 130)

		local function gotoSweepSet(tag, sender)
			if not VipBO.canWipe() then  -- VIP不够
				Toast.show(CommonText[366][4])
				return
			end
			local SweepSectionView = require("app.view.SweepSectionView").new()
			SweepSectionView:push()
			SweepSectionView:setCallBack(handler(self,self.upCoinNum))

			--require("app.view.SweepSectionView").new(handler(self,self.upCoinNum)):push()
		end
		-- 扫荡设置
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = MenuButton.new(normal, selected, nil, gotoSweepSet):addTo(container)
		btn:setPosition(150, 35)
		btn:setLabel(CommonText[1167][1])

		-- 金币
		local coinTag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(container)
		coinTag:setPosition(container:getContentSize().width-180, 80)

		self.needCoin = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt", x = coinTag:getPositionX() + coinTag:getContentSize().width / 2, y = coinTag:getPositionY()}):addTo(container)
		self.needCoin:setAnchorPoint(cc.p(0, 0.5))
		container.coinLabel_ = self.needCoin
		container.coinLabel_:setString(UiUtil.strNumSimplify(coinTotal))

		self.m_needCoin = 0
		local function setCoin()
			self:upCoinNum(CombatMO.getUseCoin())
		end
		CombatBO.asynGetWipeInfo(setCoin)

		local function gotoSweep(tag, sender)
			if not VipBO.canWipe() then  -- VIP不够
				Toast.show(CommonText[366][4])
				return
			end

			if self.m_needCoin > UserMO.getResource(ITEM_KIND_COIN) then
				require("app.dialog.CoinTipDialog").new():push()
				return
			end

			local function oneKey()
				local OnkeyWipeCombatDialog = require("app.dialog.OnkeyWipeCombatDialog")
				OnkeyWipeCombatDialog.new():push()
			end
			CombatBO.asynOnekeyDoWipe(oneKey)
		end

		local function onWipeCallback()
			local coinResData = UserMO.getResourceData(ITEM_KIND_COIN)
			local hasFree, canWipe, isnewOpen = CombatMO.hasAllFree()

			if table.nums(CombatMO.myWipeInfo_) > 0 then
				if isnewOpen then
					Toast.show(CommonText[1174])
					return
				end
				if not hasFree then
					if self.m_needCoin > 0 then
						if canWipe then
							if UserMO.consumeConfirm then
								local ConfirmDialog = require("app.dialog.ConfirmDialog")
								ConfirmDialog.new(string.format(CommonText[1172], self.m_needCoin, coinResData.name), function() gotoSweep() end):push()
							else
								gotoSweep()
							end
						else
							Toast.show(CommonText[1173])
							return
						end
					else
						Toast.show(CommonText[1171])
						return
					end
				else
					--有免费的，而且有设置的次数小于可购买的次数
					if canWipe then
						--转点后又有免费次数当前方案（消耗金币）又可以扫荡 弹出二次确认
						if self.m_needCoin > 0 then
							if UserMO.consumeConfirm then
								local ConfirmDialog = require("app.dialog.ConfirmDialog")
								ConfirmDialog.new(string.format(CommonText[1172], self.m_needCoin, coinResData.name), function() gotoSweep() end):push()
							else
								gotoSweep()
							end
						else
							gotoSweep()
						end
					else
						Toast.show(CommonText[1173])
						return
					end
				end
			else
				Toast.show(CommonText[1168][6])
				return						
			end
		end

		-- 一键扫荡
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local btn = MenuButton.new(normal, selected, nil, onWipeCallback):addTo(container)
		btn:setPosition(container:getContentSize().width-150, 35)
		btn:setLabel(CommonText[1167][2])
	end
end

--
function CombatSectionView:upCoinNum(coinNum)
	self.m_needCoin = coinNum
	if self.needCoin then
		self.needCoin:setString(self.m_needCoin)
	end
end

function CombatSectionView:updatePowerListener()
	self:upCoinNum(CombatMO.getUseCoin())
end

function CombatSectionView:showLimit(container)
	local CombatSectionTableView = require("app.scroll.CombatSectionTableView")
	local view = CombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 130), SECTION_VIEW_FOR_LIMIT):addTo(container)
	view:setPosition(0, 130)
	view:reloadData()

	-- local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	-- line:setPreferredSize(cc.size(container:getContentSize().width - 10, line:getContentSize().height))
	-- line:setPosition(container:getContentSize().width / 2, 130)

	-- local label = ui.newTTFLabel({text = CommonText[415][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- local function gotoDetail(tag, sender)
	-- 	local DetailTextDialog = require("app.dialog.DetailTextDialog")
	-- 	DetailTextDialog.new(DetailText.limitCombat):push()
	-- end

	-- -- 详情
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local btn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(container)
	-- btn:setPosition(80, 35)

	local function gotoShop(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ShopHuangbaoView = require("app.view.ShopHuangbaoView")
		ShopHuangbaoView.new():push()
	end

	-- 神秘商店
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoShop):addTo(container)
	btn:setPosition(container:getContentSize().width - 130, 35)
	btn:setLabel(CommonText[415][1])
end

function CombatSectionView:onCombatUpdate()
	gprint("[CombatSectionView] onCombatUpdate", CombatMO.curBattleNeedShowBalance_, CombatMO.curBattleCombatUpdate_, self.m_pageView:getPageIndex())

	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())

	if CombatMO.curBattleNeedShowBalance_ then
		-- if CombatMO.curBattleCombatUpdate_ == 1 then
		-- elseif CombatMO.curBattleCombatUpdate_ == 2 then
		-- end

		-- 显示奖励
		UiUtil.showAwards(CombatMO.curBattleAward_)
		CombatMO.curBattleAward_ = nil
	end
end

function CombatSectionView:onBoxUpdate()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

--挑战
function CombatSectionView:showChallenge(container)
	--关卡tablevi
	local CombatSectionTableView = require("app.scroll.CombatSectionTableView")
	local view = CombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4 - 130), SECTION_VIEW_FOR_CHALLENGE):addTo(container)
	view:setPosition(0, 130)
	view:reloadData()

	--分隔线
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(container)
	line:setPreferredSize(cc.size(container:getContentSize().width - 10, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, 130)

	--描述
	-- local label = ui.newTTFLabel({text = CommonText[415][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	-- label:setAnchorPoint(cc.p(0, 0.5))

	-- 神秘商店
	local function gotoShop(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ShopHunterView = require("app.view.ShopHunterView")
		ShopHunterView.new():push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btn = MenuButton.new(normal, selected, nil, gotoShop):addTo(container)
	btn:setPosition(container:getContentSize().width - 110, 35)
	btn:setLabel(CommonText[415][1])

	--通缉令
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local btnBounty = MenuButton.new(normal, selected, nil, function ()
		ManagerSound.playNormalButtonSound()
		if UserMO.level_ < 70 then
			Toast.show("指挥官到达70级开启通缉令")
			return
		end
		if HunterBO.wantedOpen then
			HunterBO.getTaskRewardStatus(function ()
				require("app.view.HunterAwardView").new(UI_ENTER_FADE_IN_GATE):push()
			end)
		else
			Toast.show("通缉令还未到开放时间")
		end
	end):addTo(container)
	-- local btn = MenuButton.new(normal, selected, nil, function ()
	-- 	Toast.show("该功能暂未开放")
	-- 	end):addTo(container)
	btnBounty:setPosition(110, 35)
	btnBounty:setLabel(CommonText[5040])

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.bountyDetail):push()
	end
	local btnDetail = UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil,gotoDetail):addTo(container):rightTo(btnBounty)
	btnDetail:setScale(0.6)

	--查看跨服
	local function showCrossList()
		ManagerSound.playNormalButtonSound()
		if HunterMO.teamFightCrossData_.state == 1 then
			Toast.show(CommonText[8023])
			return
		end

		if #HunterMO.teamFightCrossData_.serverData <= 0 then
			HunterBO.getCrossServerList(function ()
				require("app.dialog.ServerList").new(HunterMO.teamFightCrossData_.serverData, VIEW_FOR_TEAM_FIGHT):push()
			end)
		else
			require("app.dialog.ServerList").new(HunterMO.teamFightCrossData_.serverData, VIEW_FOR_TEAM_FIGHT):push()
		end
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local btn = MenuButton.new(normal, selected, nil, showCrossList):addTo(container)
	btn:setPosition(container:width() / 2 + 30, 35)
	btn:setLabel("跨服列表")

	-- 增加倒计时
	local openStages = HunterMO.getBountyWantedOpenTimeStages()
	local t = UiUtil.label("剩余倒计时:"):addTo(container)
	t:setPosition(80, btn:getContentSize().height + 20)
	self.left = UiUtil.label("00d:00h:00m:00s"):rightTo(t)

	local function tick()
		local now_t = ManagerTimer.getTime()
		local h = tonumber(os.date("%H", now_t))
		local m = tonumber(os.date("%M", now_t))
		local s = tonumber(os.date("%S", now_t))

		-- 判断一下当前时间在不在开放的时间内
		local duringIndex = -1
		local duringStage = nil
		local nextIndex = -1
		local nextStage = nil
		for i, v in ipairs(openStages) do
			local startH = v['start'][1]
			local startM = v['start'][2]

			local endH = v['end'][1]
			local endM = v['end'][2]

			if h > startH and h < endH then
				duringIndex = i
				duringStage = v
				break
			elseif h == startH then
				if m >= startM then
					duringIndex = i
					duringStage = v
					break
				else
					if nextIndex < 0 then
						nextIndex = i
						nextStage = v
					end
				end
			elseif h < startH then
				if nextIndex < 0 then
					nextIndex = i
					nextStage = v
				end
			elseif h == endH then
				if m < endM then
					duringIndex = i
					duringStage = v
					break
				else
					if i == #openStages then
						nextIndex = i + 1
						nextStage = nil
					end
				end
			elseif h > endH then
				if i == #openStages then
					nextIndex = i + 1
					nextStage = nil
				end
			end
		end

		if duringIndex > 0 then -- 在某个开放的时间段内
			HunterBO.wantedOpen = true
			-- 记录当前正在放的时段
			HunterBO.duringStage = duringStage
			t:setString("剩余倒计时:")
			local leftS = 60 - s
			local leftM = duringStage['end'][2] - 1 - m
			local flag = false
			if leftM < 0 then
				leftM = leftM + 60
				flag = true
			end
			local leftH = nil
			if flag then
				leftH = duringStage['end'][1] - 1 - h
			else
				leftH = duringStage['end'][1] - h
			end
			self.left:setString(string.format("%02dh:%02dm:%02ds",leftH,leftM,leftS))
		else
			HunterBO.wantedOpen = false
			t:setString("开放倒计时:")
			local startH = nil
			local startM = nil
			if nextIndex >= (#openStages + 1) then
				-- 相当于要从第二天开始
				nextIndex = 1
				nextStage = openStages[nextIndex]
				startH = nextStage['start'][1] + 24
			else
				startH = nextStage['start'][1]
			end

			startM = nextStage['start'][2]

			local leftS = 60 - s
			local leftM = startM - 1 - m
			local flag = false
			if leftM < 0 then
				leftM = leftM + 60
				flag = true
			end
			local leftH = nil
			if flag then
				leftH = startH - 1 - h
			else
				leftH = startH - h
			end
			self.left:setString(string.format("%02dh:%02dm:%02ds",leftH,leftM,leftS))
		end
	end
	self.left:performWithDelay(tick, 1, 1)
	tick()
end

function CombatSectionView:showNotOpen(container)
	--描述
	local label = ui.newTTFLabel({text = CommonText[1903], font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

return CombatSectionView