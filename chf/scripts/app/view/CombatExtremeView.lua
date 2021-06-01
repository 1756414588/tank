
-- 具体小关卡view

require("app.text.DetailText")

local CombatExtremeView = class("CombatExtremeView", UiNode)

function CombatExtremeView:ctor(combatType, sectionId)
	CombatExtremeView.super.ctor(self, "image/common/bg_ui.jpg")

	gprint("[CombatExtremeView] combat type:", combatType, " sectionId:", sectionId)
end

function CombatExtremeView:onEnter()
	CombatExtremeView.super.onEnter(self)

	self.m_combatType = COMBAT_TYPE_EXPLORE
	self.m_exploreType = EXPLORE_TYPE_EXTREME
	self.m_sectionId = CombatMO.getExploreSectionIdByType(self.m_exploreType)

	local sectionDB = CombatMO.querySectionById(self.m_sectionId)

	self:setTitle(sectionDB.name)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_updateHandler = Notify.register(LOCAL_COMBAT_UPDATE_EVENT, handler(self, self.onCombatUpdate))
	self.m_extremeHandler = Notify.register(LOCAL_EXTREME_EVENT, handler(self, self.onCombatUpdate))
	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, handler(self, self.onChatUpdate))
	self.m_readChatHandler = Notify.register(LOCAL_READ_CHAT_EVENT, handler(self, self.onChatUpdate))

	self:setUI()
end

function CombatExtremeView:onExit()
	CombatExtremeView.super.onExit(self)

	armature_remove("animation/effect/ui_combat_chose_build.pvr.ccz", "animation/effect/ui_combat_chose_build.plist", "animation/effect/ui_combat_chose_build.xml")
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end

	if self.m_extremeHandler then
		Notify.unregister(self.m_extremeHandler)
		self.m_extremeHandler = nil
	end

	if self.m_chatHandler then
		Notify.unregister(self.m_chatHandler)
		self.m_chatHandler = nil
	end

	if self.m_readChatHandler then
		Notify.unregister(self.m_readChatHandler)
		self.m_readChatHandler = nil
	end
end

function CombatExtremeView:update(dt)
	if CombatMO.getExploreExtremeWipeTime() > 0 then
		if self.m_timerLabel then self.m_timerLabel:setString(CommonText[393] .. ":" .. UiUtil.strBuildTime(CombatMO.getExploreExtremeWipeTime())) end
		if self.m_resetBtn then self.m_resetBtn:setEnabled(false) end
	else
		if self.m_timerLabel then self.m_timerLabel:setString("") end
		if self.m_resetBtn then self.m_resetBtn:setEnabled(true) end
		if self.m_wipeBtn then self.m_wipeBtn:setLabel(CommonText[35]) end
	end
end

function CombatExtremeView:setUI()
	if not self.m_container then
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180 + 52))
		container:setPosition(self:getBg():getContentSize().width / 2, 34 + container:getContentSize().height / 2)
		self.m_container = container
	end

	local progressId = CombatMO.getCurrentExploreIdBySectionId(self.m_sectionId)
	local combatIds = CombatMO.getCombatIdsBySectionId(self.m_sectionId)

	local currentId = 0
	if progressId == 0 or progressId == 300 then -- 还没有挑战的
		currentId = combatIds[1]
	else
		gprint("CombatExtremeView progressId:", progressId)
		local combatDB = CombatMO.queryExploreById(progressId)
		currentId = combatDB.nxtCombatId
		if currentId == 0 then  -- 挑战的是最后一关，重头开始
			currentId = combatIds[1]
		end
	end
	self.m_currentId = currentId
	self.m_combatIds = combatIds

	self.m_container:removeAllChildren()
	local container = self.m_container

	local function gotoRank(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ExtremeRankDialog = require("app.dialog.ExtremeRankDialog")
		ExtremeRankDialog.new():push()
	end

	-- 排行
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local rankBtn = MenuButton.new(normal, selected, nil, gotoRank):addTo(container)
	rankBtn:setLabel(CommonText[268])
	rankBtn:setPosition(85, container:getContentSize().height - 45)

	local function gotoAward(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ExtremeAwardDialog = require("app.dialog.ExtremeAwardDialog")
		ExtremeAwardDialog.new():push()
	end

	-- 奖励预览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local awardBtn = MenuButton.new(normal, selected, nil, gotoAward):addTo(container)
	awardBtn:setLabel(CommonText[269])
	awardBtn:setPosition(240, rankBtn:getPositionY())

	local function doneGetExtreme(getExtreme)
		Loading.getInstance():unshow()
		-- 探险记事
		local ExtremeRecordDialog = require("app.dialog.ExtremeRecordDialog")
		ExtremeRecordDialog.new(self.m_currentId, getExtreme):push()
	end

	local function gotoPlay(tag, sender)
		ManagerSound.playNormalButtonSound()
		if self.m_currentId== 0 then
			Toast.show(CommonText[109]) -- 请挑战据点
			return
		end

		Loading.getInstance():show()
		-- CombatBO.asynGetExtreme(doneGetExtreme, CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME])
		CombatBO.asynGetExtreme(doneGetExtreme, self.m_currentId)
	end

	-- 探险记事
	local normal = display.newSprite(IMAGE_COMMON .. "btn_replay_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_replay_selected.png")
	local playBtn = MenuButton.new(normal, selected, nil, gotoPlay):addTo(container)
	playBtn:setPosition(container:getContentSize().width - 160, awardBtn:getPositionY())

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.extremeCombat):push()
	end

	-- 详情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = MenuButton.new(normal, selected, nil, gotoDetail):addTo(container)
	detailBtn:setPosition(container:getContentSize().width - 60, awardBtn:getPositionY())

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	infoBg:setPreferredSize(cc.size(container:getContentSize().width - 10, 610))
	infoBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 85 - infoBg:getContentSize().height / 2)

	local combatBg = display.newSprite(IMAGE_COMMON .. "combat/extreme_1.jpg"):addTo(infoBg)
	combatBg:setPosition(infoBg:getContentSize().width / 2, infoBg:getContentSize().height - 18 - combatBg:getContentSize().height / 2)

	self:showCombat(combatBg)

	-- 剩余挑战次数
	local label = ui.newTTFLabel({text = CommonText[272] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height / 2 - 46, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)

	local leftTime = CombatBO.getExploreChallengeLeftCount(EXPLORE_TYPE_EXTREME)
	local label = ui.newTTFLabel({text = leftTime, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width / 2, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))
	if leftTime <= 0 then
		label:setColor(COLOR[5])
	end

	-- 通关条件
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, 200)

	local title = ui.newTTFLabel({text = CommonText[273], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	local combatDB = CombatMO.queryExploreById(self.m_currentId)
	local desc = ""

	-- 全面歼敌
	local label = ui.newTTFLabel({text = CommonText[277] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 155, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	desc = combatDB.passDesc or ""

	local label = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	-- 通关奖励
	local bg = display.newSprite(IMAGE_COMMON .. 'info_bg_12.png'):addTo(infoBg)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(40, 95)

	local title = ui.newTTFLabel({text = CommonText[274], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = bg:getContentSize().height / 2}):addTo(bg)

	-- 可能获得
	local label = ui.newTTFLabel({text = CommonText[278] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 50, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	desc = combatDB.awardDesc or ""

	local label = ui.newTTFLabel({text = desc, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local function chatCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if ChatMO.showChat_ then
			require("app.view.ChatView").new():push()
		else
			require("app.view.ChatSearchView").new():push()
		end
	end

	-- 聊天按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	local btn = MenuButton.new(normal, selected, nil, chatCallback):addTo(container)
	btn:setPosition(60, 50)
	self.m_chatButton = btn

	-- 剩余次数
	local label = ui.newTTFLabel({text = CommonText[275] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width / 2 - 90, y = 112, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local left = EXPLORE_RESET_BUY_TIME - CombatMO.combatBuy_[self.m_exploreType].count
	if ActivityBO.isValid(ACTIVITY_ID_LIMIT_EXPLORE) then
		left = EXPLORE_RESET_BUY_TIME - CombatMO.combatBuy_[self.m_exploreType].count + 1
	end

	local label = ui.newTTFLabel({text = left, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	if left <= 0 then
		label:setColor(COLOR[5])
	end
	
	-- 重置
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local resetBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onResetCallback)):addTo(container)
	resetBtn:setPosition(container:getContentSize().width / 2, 50)
	resetBtn:setLabel(CommonText[118])
	self.m_resetBtn = resetBtn

	local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = container:getContentSize().width - 210, y = 110, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))
	self.m_timerLabel = label

	-- 扫荡
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local wipeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onWipeCallback)):addTo(container)
	wipeBtn:setPosition(container:getContentSize().width - 110, 50)
	if CombatMO.getExploreExtremeWipeTime() > 0 then
		wipeBtn:setLabel(CommonText[285])  -- 停止扫荡
	else
		wipeBtn:setLabel(CommonText[35])
	end
	self.m_wipeBtn = wipeBtn

	self:update()

	self:onChatUpdate()
end

function CombatExtremeView:showCombat(combatBg)
	local function createCombatBtn(assetData)
		local assetData = json.decode(assetData)
		local tankId = assetData[1][1]
		local buildId = assetData[1][2]
		local tankCount = assetData[1][3] or 0
		local isBuild = false

		if buildId and buildId > 0 then isBuild = true end

		local sprite = nil
		if isBuild then
			sprite = display.newSprite("image/build/build_" .. buildId .. ".png")
		else
			sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankId)
			sprite:setScale(1)
		end

		local combatBtn = ScaleButton.new(sprite, handler(self, self.onChoseCombatCallback))
		combatBtn:setAnchorPoint(cc.p(0.5, 0))
		combatBtn:setScale(0.9)

		if isBuild and tankId > 0 and tankCount > 0 then  -- 是建筑
			for index = 1, tankCount do -- 显示坦克
				local itemView = UiUtil.createItemSprite(ITEM_KIND_TANK, tankId):addTo(combatBtn, tankCount - index + 1)
				itemView:setScale(0.75)
				itemView:setPosition(combatBtn:getContentSize().width / 2 + 80 - (index - 1) * 40, combatBtn:getContentSize().height / 2 - 30 - (index - 1) * 10)
			end
		end
		return combatBtn, isBuild
	end

	local function createChose(combatBtn, isBuild)
		if isBuild then -- 是建筑
			armature_add("animation/effect/ui_combat_chose_build.pvr.ccz", "animation/effect/ui_combat_chose_build.plist", "animation/effect/ui_combat_chose_build.xml")
			local armature = armature_create("ui_combat_chose_build"):addTo(combatBtn, -1)
			armature:setPosition(combatBtn:getContentSize().width / 2, armature:getContentSize().height / 2)
			armature:setScale(1.1)
			armature:getAnimation():playWithIndex(0)
		else
			local chose = nil
			chose = display.newSprite(IMAGE_COMMON .. "chose_2.png"):addTo(combatBtn, -1)
			chose:setPosition(combatBtn:getContentSize().width / 2, combatBtn:getContentSize().height / 2)
			chose:setScale(0.6)
			chose:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(3, 0.8), cc.ScaleTo:create(3, 0.6)})))
		end
		local indicate = display.newSprite(IMAGE_COMMON .. "chose_4.png"):addTo(combatBtn, 2)
		indicate:setPosition(combatBtn:getContentSize().width / 2, combatBtn:getContentSize().height + 20)
		indicate:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(3, cc.p(0, 30)), cc.MoveBy:create(3, cc.p(0, -30))})))
	end

	gprint("[CombatExtremeView] currentId:", self.m_currentId)

	local combatDB = CombatMO.queryExploreById(self.m_currentId)

	local function getIndex(combatId)
		for index = 1, #self.m_combatIds do
			if self.m_combatIds[index] == combatId then return index end
		end
		return 0
	end

	-- 关卡名背景
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(combatBg)
	titleBg:setPosition(combatBg:getContentSize().width / 2, combatBg:getContentSize().height - 8)
	-- 第几关 名称
	local name = ui.newTTFLabel({text = CommonText[237][1] .. getIndex(self.m_currentId) .. CommonText[237][2] .. " - " .. combatDB.name, font = G_FONT, size = FONT_SIZE_SMALL, x = titleBg:getContentSize().width / 2, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)

	local combatBtn, isBuild = createCombatBtn(combatDB.assetData)
	combatBtn.combatId = self.m_currentId
	combatBtn:setPosition(combatBg:getContentSize().width / 2 - 80, 90)
	combatBtn:addTo(combatBg)

	createChose(combatBtn, isBuild)

	-- 之前的箭头
	local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_1.png"):addTo(combatBg)
	arrow:setPosition(80, combatBg:getContentSize().height / 2 + 40)
	arrow:setRotation(70)

	if combatDB.nxtCombatId ~= 0 then -- 有下一关，显示下一关
		local arrow = display.newSprite(IMAGE_COMMON .. "icon_arrow_1.png"):addTo(combatBg)
		arrow:setPosition(combatBg:getContentSize().width / 2 + 80, combatBg:getContentSize().height / 2)

		local nxtCombatDB = CombatMO.queryExploreById(combatDB.nxtCombatId)
		local nxtCombatBtn, isBuild = createCombatBtn(nxtCombatDB.assetData)
		nxtCombatBtn:addTo(combatBg)
		nxtCombatBtn:setEnabled(false)
		nxtCombatBtn:setScale(0.6)
		nxtCombatBtn:setPosition(combatBg:getContentSize().width - 100, combatBg:getContentSize().height / 2)
	end

	-- 特殊奖励
	local sprite = display.newSprite(IMAGE_COMMON .. "icon_specical_bag.png")
	local btn = ScaleButton.new(sprite, nil):addTo(combatBg)
	btn:setPosition(60, combatBg:getContentSize().height - 60)

	local label = ui.newTTFLabel({text = CommonText[270], font = G_FONT, size = FONT_SIZE_SMALL, x = btn:getContentSize().width / 2, y = btn:getContentSize().height, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(btn)

	-- 点击据点
	local label = ui.newTTFLabel({text = CommonText[271], font = G_FONT, size = FONT_SIZE_SMALL, x = combatBg:getContentSize().width / 2, y = 50, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(combatBg)
end

function CombatExtremeView:onChoseCombatCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if CombatMO.getExploreExtremeWipeTime() > 0 then  -- 还在扫荡中
		Toast.show(CommonText[394])
		return
	end

	local leftTime = CombatBO.getExploreChallengeLeftCount(EXPLORE_TYPE_EXTREME)
	if leftTime <= 0 then  -- 挑战次数已用完
		Toast.show(CommonText[283])
	else
		local CombatFightDialog = require("app.dialog.CombatFightDialog")
		local dialog = CombatFightDialog.new(self.m_combatType, sender.combatId):push()
	end
end

function CombatExtremeView:onReset()
	if ActivityBO.isValid(ACTIVITY_ID_LIMIT_EXPLORE) then
		if EXPLORE_RESET_BUY_TIME - CombatMO.combatBuy_[self.m_exploreType].count + 1 <= 0 then
			Toast.show("重置次数已用完")
			return
		end
	else
		if EXPLORE_RESET_BUY_TIME - CombatMO.combatBuy_[self.m_exploreType].count <= 0 then
			Toast.show("重置次数已用完")
			return
		end
	end

	local function doneCallback()
		Loading.getInstance():unshow()
		self:setUI()
	end

	local resData = UserMO.getResourceData(ITEM_KIND_POWER)
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[302], EXPLORE_EXTREME_RESET_TAKE_POWER, resData.name),function()
			local num = UserMO.getResource(ITEM_KIND_POWER)
			if num < EXPLORE_EXTREME_RESET_TAKE_POWER then
				require("app.dialog.BuyPawerDialog").new():push()
				Toast.show(resData.name .. CommonText[223])
				return
			end

			Loading.getInstance():show()
			CombatBO.asynResetExtrEpr(doneCallback)
		end):push()
end

function CombatExtremeView:onWipeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if CombatMO.getExploreExtremeWipeTime() > 0 then  -- 是要停止扫荡
		local function doneEndWipe(awards)
			Loading.getInstance():unshow()
			self:setUI()

			local ExtremeWipeAwardDialog = require("app.dialog.ExtremeWipeAwardDialog")
			ExtremeWipeAwardDialog.new(awards):push()
		end

		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[299][7], function()
				if CombatMO.getExploreExtremeWipeTime() > 0 then
					Loading.getInstance():show()
					CombatBO.asynEndExtremeWipe(doneEndWipe)
				end
			end):push()
		return
	end

	if CombatMO.exploreExtremeHighest_ == 0 then
		Toast.show(CommonText[109])
		return false
	end

	-- gprint("CombatMO.combatChallenge_[EXPLORE_TYPE_EXTREME] :", CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] , CombatMO.exploreExtremeHighest_)
	-- 需要重置才能扫荡
	if CombatMO.exploreExtremeHighest_ == CombatMO.currentExplore_[EXPLORE_TYPE_EXTREME] then
		self:onReset()
		return
	end

	local function doneCallback()
		Loading.getInstance():unshow()
		self:setUI()
	end

	local startIndex = 0
	if CombatMO.currentExplore_[self.m_exploreType] == 0 or CombatMO.currentExplore_[self.m_exploreType] == 300 then startIndex = 1
	else startIndex = CombatMO.getExtremeProgressIndex(CombatMO.currentExplore_[self.m_exploreType] + 1) end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[304], startIndex, CombatMO.getExtremeProgressIndex(CombatMO.exploreExtremeHighest_)), function()
			if not VipBO.canWipe() then  -- VIP不够
				Toast.show(CommonText[366][4])
				return
			end

			Loading.getInstance():show()
			CombatBO.asynBeginExtremeWipe(doneCallback)
		end):push()
end

function CombatExtremeView:onResetCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if CombatMO.currentExplore_[self.m_exploreType] == 0 or CombatMO.currentExplore_[self.m_exploreType] == 300 then
		Toast.show(CommonText[109])
		return false
	end

	self:onReset()
end

function CombatExtremeView:onCombatUpdate()
	self:setUI()
-- 	gprint("CombatExtremeView: 关卡有数据更新了")

-- 	self.m_tableView:reloadData()
-- 	self:updateCenter()

-- 	self:showStarInfo()

-- 	if CombatMO.curBattleNeedShowBalance_ then
-- 		-- CombatMO.curBattleNeedShowBalance_ = false

-- 		gprint("CombatExtremeView exp:", CombatMO.curBattleExp_)
		
-- 		if CombatMO.curBattleCombatUpdate_ == 1 then
			
-- 		elseif CombatMO.curBattleCombatUpdate_ == 2 then
-- 			gprint("[CombatExtremeView] onCombatUpdate 开启新的关卡")
-- 		end
-- 	end
end

function CombatExtremeView:onChatUpdate(event)
	local num = ChatBO.getUnreadChatNum()
	if num > 0 then
		UiUtil.showTip(self.m_chatButton, num, 42, 42)
	else
		UiUtil.unshowTip(self.m_chatButton)
	end
end

return CombatExtremeView
