
-- 具体小关卡view

local CombatLevelView = class("CombatLevelView", UiNode)

function CombatLevelView:ctor(combatType, sectionId)
	CombatLevelView.super.ctor(self)

	gprint("[CombatLevelView] combat type:", combatType, " sectionId:", sectionId)
	self.m_combatType = combatType
	self.m_sectionId = sectionId
end

function CombatLevelView:onEnter()
	CombatLevelView.super.onEnter(self)

	self.m_updateHandler = Notify.register(LOCAL_COMBAT_UPDATE_EVENT, handler(self, self.onCombatUpdate))
	self.m_powerListener = Notify.register("WIPE_COMBAT_POWER_HANDLER", handler(self,self.updatePowerListener))

	local CombatLevelTableView = require("app.scroll.CombatLevelTableView")
	local view = CombatLevelTableView.new(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT), self.m_combatType, self.m_sectionId):addTo(self:getBg())
	view:addEventListener("BUY_COMBAT_EVENT", handler(self, self.onBuyCombat))
	view:setPosition((self:getBg():getContentSize().width - view:getContentSize().width) / 2,
		(self:getBg():getContentSize().height - view:getContentSize().height) / 2)
	view:reloadData()
	self.m_tableView = view
	self:updateCenter()

	local top = display.newSprite(IMAGE_COMMON .. "info_bg_7.png"):addTo(self:getBg())
	top:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - top:getContentSize().height / 2)

	if self.m_combatType == COMBAT_TYPE_COMBAT then  -- 征战
		local sectionDB = CombatMO.querySectionById(self.m_sectionId)
		local name = ui.newTTFLabel({text = sectionDB.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 190, y = top:getContentSize().height - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(top)
	else
		local sectionDB = CombatMO.querySectionById(self.m_sectionId)
		local name = ui.newTTFLabel({text = sectionDB.name, font = G_FONT, size = FONT_SIZE_MEDIUM, x = 190, y = top:getContentSize().height - 40, align = ui.TEXT_ALIGN_CENTER}):addTo(top)
	end

	self:showStarInfo()
end

function CombatLevelView:onExit()
	CombatLevelView.super.onExit(self)

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end

	armature_remove("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_remove("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end

function CombatLevelView:showStarInfo()
	if self.m_starNode then
		self.m_starNode:removeSelf()
	end

	local node = display.newNode():addTo(self:getBg())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getBg():getContentSize().width / 2, 0)
	self.m_starNode = node

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_6.png"):addTo(node)
	bg:setPreferredSize(cc.size(self:getBg():getContentSize().width, bg:getContentSize().height))
	bg:setPosition(0, bg:getContentSize().height / 2)

	local sectionBoxData = CombatBO.getSectionBoxData(self.m_combatType, self.m_sectionId)

	if self.m_combatType == COMBAT_TYPE_COMBAT then  -- 征战
		local starBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(440, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(440 + 4, 26)}):addTo(node)
		starBar:setPosition(-65, 32)
		starBar:setPercent(sectionBoxData.starOwnNum / sectionBoxData.starTotal)

		local power = display.newSprite(IMAGE_COMMON .. "icon_power.png"):addTo(node, 4)
		power:setPosition(150, self:getBg():height() - 52)

		local count = ui.newTTFLabel({text = UserMO.getResource(ITEM_KIND_POWER), font = G_FONT, size = FONT_SIZE_MEDIUM, x = power:getPositionX() + 20, y = self:getBg():height() - 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
		count:setAnchorPoint(cc.p(0, 0.5))
		self.m_starNode.count = count

		local label = ui.newTTFLabel({text = "/" .. POWER_MAX_VALUE, font = G_FONT, size = FONT_SIZE_MEDIUM, x = count:getPositionX() + count:getContentSize().width, y = count:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
		label:setAnchorPoint(cc.p(0, 0.5))

		local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(node)
		starBg:setScale(0.6)
		starBg:setPosition(215, 40)

		local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
		star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)

		-- 拥有的星的数量
		local value = ui.newTTFLabel({text = sectionBoxData.starOwnNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = starBg:getPositionX() + 15, y = starBg:getPositionY() - 4, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
		value:setAnchorPoint(cc.p(0, 0.5))

		local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
		local addBtn = MenuButton.new(normal, selected, nil, function ()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.BuyPawerDialog").new():push()
		end):addTo(node, 4)
		addBtn:setScale(0.8)
		addBtn:setPosition(270, self:getBg():height() - 52)
	elseif self.m_combatType == COMBAT_TYPE_EXPLORE then
		local exploreType = CombatMO.getExploreTypeBySectionId(self.m_sectionId)

		if exploreType == EXPLORE_TYPE_EQUIP or exploreType == EXPLORE_TYPE_PART or exploreType == EXPLORE_TYPE_WAR or exploreType == EXPLORE_TYPE_ENERGYSPAR or exploreType == EXPLORE_TYPE_MEDAL
		or exploreType == EXPLORE_TYPE_TACTIC then  -- 装备和配件副本可以看到星进度条
			local starBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(440, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(440 + 4, 26)}):addTo(node)
			starBar:setPosition(-65, 32)
			starBar:setPercent(sectionBoxData.starOwnNum / sectionBoxData.starTotal)
		end

		-- 副本可挑战次数
		local leftTime = CombatBO.getExploreChallengeLeftCount(exploreType)

		-- 次数
		local leftLabel = ui.newTTFLabel({text = CommonText[282] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 110, y = self:getBg():height() - 52, align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
		leftLabel:setAnchorPoint(cc.p(0, 0.5))

		local count = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_MEDIUM, x = leftLabel:getPositionX() + leftLabel:getContentSize().width, y = leftLabel:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
		count:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "/" .. EXPLORE_FIGHT_TIME, font = G_FONT, size = FONT_SIZE_MEDIUM, x = count:getPositionX() + count:getContentSize().width, y = count:getPositionY(), align = ui.TEXT_ALIGN_CENTER}):addTo(node, 4)
		label:setAnchorPoint(cc.p(0, 0.5))

		if leftTime <= 0 then  -- 没有可挑战的次数了
			count:setColor(COLOR[5])
		end

		-- 拥有的星的数量
		local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(node)
		starBg:setScale(0.6)
		starBg:setPosition(215, 40)

		local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
		star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)

		if sectionBoxData then
			local value = ui.newTTFLabel({text = sectionBoxData.starOwnNum, font = G_FONT, size = FONT_SIZE_MEDIUM, x = starBg:getPositionX() + 15, y = starBg:getPositionY() - 4, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		if exploreType == EXPLORE_TYPE_EQUIP or exploreType == EXPLORE_TYPE_PART or exploreType == EXPLORE_TYPE_WAR or exploreType == EXPLORE_TYPE_ENERGYSPAR 
			or exploreType == EXPLORE_TYPE_LIMIT or exploreType == EXPLORE_TYPE_MEDAL or exploreType == EXPLORE_TYPE_TACTIC then
			-- 添加次数
			local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
			local addBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAddCallback)):addTo(node, 4)
			addBtn:setScale(0.8)
			addBtn:setPosition(270, self:getBg():height() - 52)
		end
	end

	if sectionBoxData then  -- 显示宝箱
		for index = 1, #sectionBoxData.boxNeedStar do
			local sprite = nil
			if CombatBO.hasSectionBoxOpen(self.m_sectionId, index) then  -- 宝箱已经领取了
				sprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_open.png")
			else
				sprite = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
			end

			local boxBtn = ScaleButton.new(sprite, handler(self, self.onOpenBoxCallback)):addTo(node)
			boxBtn.index = index
			boxBtn:setScale(0.75)
			boxBtn:setAnchorPoint(cc.p(0, 0.5))
			boxBtn:setPosition(-380 + 80 + (index - 0.5) * 146, 68)
			if #sectionBoxData.boxNeedStar == 1 then
				boxBtn:setPosition(-380 + 80 + (3 - 0.5) * 146, 68)
			end

			local value = ui.newTTFLabel({text = sectionBoxData.boxNeedStar[index], font = G_FONT, size = FONT_SIZE_MEDIUM, x = boxBtn:getPositionX() + 40, y = 36, align = ui.TEXT_ALIGN_CENTER}):addTo(node)
			value:setScale(1)

			local starBg = display.newSprite(IMAGE_COMMON .. "star_bg_1.png"):addTo(node)
			starBg:setScale(0.6)
			starBg:setAnchorPoint(cc.p(0, 0.5))
			starBg:setPosition(boxBtn:getPositionX() + 60, 40)

			local star = display.newSprite(IMAGE_COMMON .. "star_1.png"):addTo(starBg)
			star:setPosition(starBg:getContentSize().width / 2, starBg:getContentSize().height / 2)

			if not CombatBO.hasSectionBoxOpen(self.m_sectionId, index) and sectionBoxData.starOwnNum >= sectionBoxData.boxNeedStar[index] then -- 可以领取宝箱，而 没有领
				armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
				armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

				local lightEffect = armature_create("ui_box_light", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
		        lightEffect:getAnimation():playWithIndex(0)
		        boxBtn:addChild(lightEffect, -1)

				local starEffect = armature_create("ui_box_star", boxBtn:getContentSize().width / 2, boxBtn:getContentSize().height / 2)
		        starEffect:getAnimation():playWithIndex(0)
		        boxBtn:addChild(starEffect)
			end
		end
	end

	local btm = display.newSprite(IMAGE_COMMON .. "bg_ui_btm.png"):addTo(node)
	btm:setPosition(0, btm:getContentSize().height / 2)
end

function CombatLevelView:updateCenter()
	if self.m_combatType == COMBAT_TYPE_COMBAT then
		if CombatBO.isSectionPass(self.m_combatType, self.m_sectionId) then
		elseif CombatMO.currentCombatId_ == 0 then
			self.m_tableView:setContentOffset(self.m_tableView:maxContainerOffset())
		else
			local combatDB = CombatMO.queryCombatById(CombatMO.currentCombatId_)
			if combatDB.sectionId ~= self.m_sectionId then
				if combatDB.sectionId > self.m_sectionId then
				else
					self.m_tableView:setContentOffset(self.m_tableView:maxContainerOffset())
				end
			else -- 就是当前打了的最新关卡的章节
				local nxtCombatDB = CombatMO.queryCombatById(combatDB.nxtCombatId)
				if not nxtCombatDB or nxtCombatDB.sectionId ~= combatDB.sectionId then  -- 是当前章节最后一关
					local combatView = CombatMO.getCombatViewById(self.m_combatType, CombatMO.currentCombatId_)
					if combatView then
						self.m_tableView:setContentOffset(cc.p(0, display.cy - combatView.offset[2]))
					end
				else
					local combatView = CombatMO.getCombatViewById(self.m_combatType, nxtCombatDB.combatId)
					if combatView then
						self.m_tableView:setContentOffset(cc.p(0, display.cy - combatView.offset[2]))
					end
				end
			end
		end
	elseif self.m_combatType == COMBAT_TYPE_EXPLORE then  -- 探险副本
		if CombatBO.isSectionPass(self.m_combatType, self.m_sectionId) then
		else
			local curExploreId = CombatMO.getCurrentExploreIdBySectionId(self.m_sectionId)
			if curExploreId == 0 then
				self.m_tableView:setContentOffset(self.m_tableView:maxContainerOffset())
			else
				local exploreDB = CombatMO.queryExploreById(curExploreId)
				local combatView = CombatMO.getCombatViewById(self.m_combatType, curExploreId + 1)
				self.m_tableView:setContentOffset(cc.p(0, display.cy - combatView.offset[2]))
			end
		end
	end
end

function CombatLevelView:onCombatUpdate()
	gprint("CombatLevelView: onCombatUpdate balance:", CombatMO.curBattleNeedShowBalance_, "update:", CombatMO.curBattleCombatUpdate_)

	self.m_tableView:reloadData(CombatMO.curBattleCombatUpdate_, self.m_combatType, CombatMO.curChoseBtttleId_)
	
	self:updateCenter()

	self:showStarInfo()

	if CombatMO.curBattleNeedShowBalance_ then
		-- gprint("CombatLevelView exp:", CombatMO.curBattleExp_)
		
		if CombatMO.curBattleCombatUpdate_ == 1 then
			
		elseif CombatMO.curBattleCombatUpdate_ == 2 then
			gprint("[CombatLevelView] onCombatUpdate 开启新的关卡")
		elseif CombatMO.curBattleCombatUpdate_ == 4 then  -- 第一章打完了
			local IndicatorView = require("app.view.IndicatorView")
			local view = IndicatorView.new(HomePassSectionConfig)
			display.getRunningScene():addChild(view, 999999999)
		end

		-- 显示奖励
		UiUtil.showAwards(CombatMO.curBattleAward_)
		CombatMO.curBattleAward_ = nil
	end
end

function CombatLevelView:onOpenBoxCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function receiveCallback()
		self:showStarInfo()
	end

	local SectionAwardDialog = require("app.dialog.SectionAwardDialog")
	SectionAwardDialog.new(self.m_combatType, self.m_sectionId, sender.index, receiveCallback):push()
end

function CombatLevelView:onAddCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local exploreType = CombatMO.getExploreTypeBySectionId(self.m_sectionId)

	if exploreType == EXPLORE_TYPE_EQUIP then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEquipCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_PART then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyPartCombatCount() then
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_WAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMilitaryCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyEnergySparCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_MEDAL then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyMedalSparCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_LIMIT then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyTreasureCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	elseif exploreType == EXPLORE_TYPE_TACTIC then
		if CombatMO.combatBuy_[exploreType].count >= VipBO.getBuyTacticsCombatCount() then  -- 次数用完
			Toast.show(CommonText[366][1])
			return
		end
	end

	local function doneBuy()
		Loading.getInstance():unshow()
		Toast.show(CommonText[200])  -- 成功购买
		self:showStarInfo()
	end

	local coinNum = EXPLORE_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count + 1] or EXPLORE_RESET_TAKE_COIN[#EXPLORE_RESET_TAKE_COIN]
	if exploreType == EXPLORE_TYPE_EQUIP and ActivityBO.isValid(ACTIVITY_ID_EQUIP_SUPPLY) then --装备探险 1
		coinNum = math.ceil(coinNum * ACTIVITY_EQUIP_SUPPLY_COIN_RATE)
	elseif exploreType == EXPLORE_TYPE_PART and ActivityBO.isValid(ACTIVITY_ID_PART_SUPPLY) then -- 配件探险 2
		coinNum = math.ceil(coinNum * ACTIVITY_PART_SUPPLY_COIN_RATE)	--配件补给金币返还
	elseif exploreType == EXPLORE_TYPE_ENERGYSPAR then	--能晶探险
		coinNum = EXPLORE_ALTAR_RESET_TAKE_COIN[CombatMO.combatBuy_[exploreType].count+1] or EXPLORE_ALTAR_RESET_TAKE_COIN[#EXPLORE_ALTAR_RESET_TAKE_COIN]--8
		if ActivityBO.isValid(ACTIVITY_ID_ENERGY_SUPPLY) then	-- 能晶补给
			coinNum = math.ceil(coinNum * ACTIVITY_ENERYG_SUPPLY_COIN_RATE)
		end
	elseif exploreType == EXPLORE_TYPE_WAR and ActivityBO.isValid(ACTIVITY_ID_MILITARY_SUPPLY) then	-- 军工探险 5
		coinNum = math.ceil(coinNum * ACTIVITY_MILITARY_SUPPLY_COIN_RATE)
	elseif exploreType == EXPLORE_TYPE_LIMIT then	--限时 4
		coinNum = EXPLORE_LIMIT_COIN[CombatMO.combatBuy_[exploreType].count + 1] or EXPLORE_LIMIT_COIN[#EXPLORE_LIMIT_COIN]
	elseif exploreType == EXPLORE_TYPE_MEDAL and ActivityBO.isValid(ACTIVITY_ID_MEDAL_SUPPLY) then
		coinNum = math.ceil(coinNum * ACTIVITY_MEDAL_SUPPLY_COIN_RATE)
	elseif exploreType == EXPLORE_TYPE_TACTIC and ActivityBO.isValid(ACTIVITY_ID_TACTICS_SSUPPLY) then
		coinNum = math.ceil(coinNum * ACTIVITY_TACTIC_SUPPLY_COIN_RATE)
	end

	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local function gotoBuy()
		if UserMO.getResource(ITEM_KIND_COIN) < coinNum then  -- 金币不足
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		Loading.getInstance():show()
		CombatBO.asynBuyExplore(doneBuy, self.m_sectionId)
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[241], coinNum, resData.name, EXPLORE_FIGHT_TIME), function() gotoBuy() end):push()
	else
		gotoBuy()
	end
end

function CombatLevelView:onBuyCombat(event)
	self:onAddCallback()
end

function CombatLevelView:getTableOffSet()
	return self.m_tableView:getContentOffset()
end

function CombatLevelView:updatePowerListener()
	if self.m_starNode and self.m_starNode.count then
		self.m_starNode.count:setString(UserMO.getResource(ITEM_KIND_POWER))
	end
end

return CombatLevelView
