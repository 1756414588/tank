
-- 主场景中可收缩的显示活动、抽装备等按钮

local HomeAwardButtonView = class("HomeAwardButtonView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

BUTTON_STATUS_DRAW_BACK = 1 -- 收缩
BUTTON_STATUS_STRETCH   = 2 -- 伸展

AWARD_BUTTON_INDEX_EXPLORE  = 1 -- 探宝
AWARD_BUTTON_INDEX_EQUIP    = 2 -- 抽装备
AWARD_BUTTON_INDEX_MEDAL    = 3 -- 勋章
AWARD_BUTTON_INDEX_WARWEAPON  = 4 -- 神秘武器
AWARD_BUTTON_INDEX_SHOP     = 5  --商城
-- AWARD_BUTTON_INDEX_ACTIVITY_HOT    = 4 -- 热门活动

function HomeAwardButtonView:ctor()
end

function HomeAwardButtonView:onEnter()
	local normal = display.newSprite(IMAGE_COMMON .. "btn_22_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_22_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onClickCallback)):addTo(self)
	btn:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	self.m_switchButton = btn

	self:setContentSize(btn:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_buttons = {}

	-- -- 活动中心
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_24_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_24_selected.png")
	-- local btn = MenuButton.new(normal, selected, nil, handler(self, self.onActivityHotCallback)):addTo(self, -2)
	-- btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	-- self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY_HOT] = btn

	-- -- 每日活动
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_23_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_23_selected.png")
	-- local btn = MenuButton.new(normal, selected, nil, handler(self, self.onActivityCallback)):addTo(self, -1)
	-- btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	-- self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY] = btn
	-- 勋章
	local normal = display.newSprite(IMAGE_COMMON .. "btn_58_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_58_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onMedalCallback)):addTo(self, -2)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	self.m_buttons[AWARD_BUTTON_INDEX_MEDAL] = btn
	if MedalMO.open_ then
		self:updateMedal()
	end

	-- 抽装备
	local normal = display.newSprite(IMAGE_COMMON .. "btn_25_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_25_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onEquipCallback)):addTo(self, -3)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	self.m_buttons[AWARD_BUTTON_INDEX_EQUIP] = btn

	-- 探宝
	local normal = display.newSprite(IMAGE_COMMON .. "btn_26_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_26_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onExploreCallback)):addTo(self, -4)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	self.m_buttons[AWARD_BUTTON_INDEX_EXPLORE] = btn

	--神秘武器
	local function gotoWarWeapon()
		ManagerSound.playNormalButtonSound()
		require("app.view.WarWeaponView").new():push()
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_65_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_65_selected.png")
	local warWeaponBtn = MenuButton.new(normal, selected, nil, gotoWarWeapon):addTo(self, -5)
	warWeaponBtn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	warWeaponBtn:setVisible(UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) and (TriggerGuideBO.guideIsDone(70) or WarWeaponBO.isHaveSkill()))
	self.m_buttons[AWARD_BUTTON_INDEX_WARWEAPON] = warWeaponBtn

	--商城
	local function gotoShop(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.BagView").new(BAG_VIEW_FOR_SHOP):push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_shop_normal.png")
	local shopBtn = ScaleButton.new(normal, gotoShop):addTo(self, -6)
	shopBtn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.m_buttons[AWARD_BUTTON_INDEX_SHOP] = shopBtn

	self.m_isMove = false
	self.m_buttonStatus = BUTTON_STATUS_DRAW_BACK -- 收缩

	self.m_equipHandler = Notify.register(LOCAL_UPDATE_EQUIP_LOTTERY_EVENT, handler(self, self.updateTip))
	-- self.m_signHandler = Notify.register(LOCAL_SIGN_UPDATE_EVENT, handler(self, self.updateTip))
	self.m_treasureHandler = Notify.register(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT, handler(self, self.updateTip))
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.updateTip))
	self.m_activityHotHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.updateTip))
	self.m_medalOpenHandler = Notify.register("MEDAL_OPEN", handler(self, self.updateMedal))
	self.m_medalHandler = Notify.register(LOCLA_MEDAL_EVENT, handler(self, self.updateTip))
	self.m_limitHandler = Notify.register(LOCAL_HOME_LIMIT_ITEM, handler(self, self.checkAndShowLimitItem)) --主界面限制性功能图标

	self:updateTip()
end

function HomeAwardButtonView:onClickCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	HomeBO.NO_OPERATE_FREE_TIMER = 0
	
	if self.m_isMove then return false end

	if self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then
		self.m_buttonStatus = BUTTON_STATUS_STRETCH
	else
		self.m_buttonStatus = BUTTON_STATUS_DRAW_BACK
	end
	self:showButtons(true)
end

function HomeAwardButtonView:setStatus(buttonStatus, animated)
	if self.m_isMove then return false end

	if self.m_buttonStatus ~= buttonStatus then
		self.m_buttonStatus = buttonStatus
		self:showButtons(animated)
	end
end

function HomeAwardButtonView:getStatus()
	return self.m_buttonStatus
end

function HomeAwardButtonView:showMedalState()
	self.m_buttons[AWARD_BUTTON_INDEX_MEDAL]:setVisible(UserMO.level_ >= MedalMO.level_)
end

function HomeAwardButtonView:showButtons(animated)
	if self.m_isMove then return false end

	if animated then
		self.m_isMove = true

		if self.m_buttonStatus == BUTTON_STATUS_STRETCH then  -- 需要伸展开
			for index = 1, #self.m_buttons do
				local button = self.m_buttons[index]
				button:stopAllActions()
				-- button:setVisible(true)
				-- button:setEnabled(false)
				button:setVisible(true)
				button:setOpacity(0)
				self:showMedalState()
				local spwArray = cc.Array:create()
				local px = self:getContentSize().width / 2
				local py = 40 + 80 * index
				if index == AWARD_BUTTON_INDEX_WARWEAPON then
					button:setVisible(UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) and (TriggerGuideBO.guideIsDone(70) or WarWeaponBO.isHaveSkill()))
					px = self:getContentSize().width / 2 - 90
					py = 120
				elseif index == AWARD_BUTTON_INDEX_SHOP then
					px = self:getContentSize().width / 2 - 90
					py = 40
				end
				spwArray:addObject(cc.MoveTo:create(0.1 * index, cc.p(px, py)))
				spwArray:addObject(cc.FadeIn:create(0.1 * index))
				button:runAction(transition.sequence({
					cc.Spawn:create(spwArray),
					cc.CallFuncN:create(function(sender)
						-- sender:setEnabled(true)
						if index == #self.m_buttons then
							self.m_isMove = false
						end
					end)}))
			end
		elseif self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then -- 需要收缩
			for index = 1, #self.m_buttons do
				local button = self.m_buttons[index]
				button:stopAllActions()
				button:setOpacity(255)
				local ey = index == #self.m_buttons and 80 or 0
				if index == AWARD_BUTTON_INDEX_SHOP then
					ey = 0
				end
				local spwArray = cc.Array:create()
				spwArray:addObject(cc.MoveTo:create(0.08 * index, cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + ey)))
				spwArray:addObject(cc.FadeOut:create(0.1 * index))
				
				button:runAction(transition.sequence({
					cc.Spawn:create(spwArray),
					cc.CallFuncN:create(function(sender)
						sender:setVisible(false)
						if index == #self.m_buttons then
							self.m_isMove = false
						end
					end)}))
			end
		end
	else
		if self.m_buttonStatus == BUTTON_STATUS_STRETCH then  -- 需要伸展开
			for index = 1, #self.m_buttons do
				local button = self.m_buttons[index]
				button:stopAllActions()
				button:setVisible(true)
				button:setPosition(self:getContentSize().width / 2, 40 + 80 * index)
				if index == AWARD_BUTTON_INDEX_WARWEAPON then
					button:setVisible(UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) and (TriggerGuideBO.guideIsDone(70) or WarWeaponBO.isHaveSkill()))
					button:setPosition(self:getContentSize().width / 2 - 90, 40 + 80)
				elseif index == AWARD_BUTTON_INDEX_SHOP then
					button:setPosition(self:getContentSize().width / 2 - 90, 40)
				end
			end
		elseif self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then -- 需要收缩
			for index = 1, #self.m_buttons do
				local button = self.m_buttons[index]
				button:stopAllActions()
				button:setVisible(false)
				local ey = index == #self.m_buttons and 80 or 0
				button:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + ey)
			end
		end
	end
end

function HomeAwardButtonView:onActivityCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	-- -- 需要判断是否有活动
	-- if #ActivityMO.activityList_ <= 0 then
	-- 	Toast.show("目前还没有活动，敬请期待")
	-- else
		-- 至少有一个兑换码
		local ActivityView = require("app.view.ActivityView")
		ActivityView.new():push()
	-- end

	-- CombatMO.curBattleNeedShowBalance_ = false
	-- CombatMO.curBattleCombatUpdate_ = 0
	-- CombatMO.curBattleAward_ = nil
	-- CombatMO.curBattleStatistics_ = {}

	-- CombatMO.curChoseBattleType_ = COMBAT_TYPE_GUIDE
	-- CombatMO.curChoseBtttleId_ = 0

	-- -- 获得战斗的数据
	-- local combatData = CombatBO.codeGuideRecord()

	-- -- 设置先手
	-- CombatMO.curBattleOffensive_ = combatData.offsensive

	-- CombatMO.curBattleAtkFormat_ = combatData.atkFormat
	-- CombatMO.curBattleDefFormat_ = combatData.defFormat
	-- CombatMO.curBattleFightData_ = combatData

	-- BattleMO.reset()
	-- BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
	-- BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
	-- BattleMO.setFightData(CombatMO.curBattleFightData_)

	-- local atkLost = CombatBO.parseBattleStastics(combatData.atkFormat, combatData.defFormat, combatData)

	-- require("app.view.BattleView").new():push()
end

function HomeAwardButtonView:onActivityHotCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	UiDirector.push(require("app.view.ActivityCenterView").new())

	-- if #ActivityCenterMO.activityList_ > 0 then
	-- 	UiDirector.push(require("app.view.ActivityCenterView").new())
	-- else
	-- 	UiDirector.push(require("app.view.LotteryTreasureView").new())
	-- end
end

function HomeAwardButtonView:onEquipCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.push(require("app.view.LotteryEquipView").new())
end

function HomeAwardButtonView:onMedalCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	MedalMO.open_ = nil
	if sender.openFlag then
		sender.openFlag:removeSelf()
		sender.openFlag = nil
	end
	UiDirector.push(require("app.view.MedalBaseView").new())
end

function HomeAwardButtonView:onExploreCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.push(require("app.view.LotteryTreasureView").new())
end

function HomeAwardButtonView:checkAndShowLimitItem()
	for k , v in pairs(self.m_buttons) do
		if k == AWARD_BUTTON_INDEX_WARWEAPON then
			if UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) then
				v:setVisible(true)
			end
		end
	end
end

function HomeAwardButtonView:onExit()
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
	-- if self.m_signHandler then
	-- 	Notify.unregister(self.m_signHandler)
	-- 	self.m_signHandler = nil
	-- end
	if self.m_treasureHandler then
		Notify.unregister(self.m_treasureHandler)
		self.m_treasureHandler = nil
	end
	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end
	if self.m_activityHotHandler then
		Notify.unregister(self.m_activityHotHandler)
		self.m_activityHotHandler = nil
	end
	if self.m_medalOpenHandler then
		Notify.unregister(self.m_medalOpenHandler)
		self.m_medalOpenHandler = nil
	end
	if self.m_medalHandler then
		Notify.unregister(self.m_medalHandler)
		self.m_medalHandler = nil
	end

	if self.m_limitHandler then
		Notify.unregister(self.m_limitHandler)
		self.m_limitHandler = nil
	end
end

function HomeAwardButtonView:updateMedal()
	MedalMO.open_ = true
	local btn = self.m_buttons[AWARD_BUTTON_INDEX_MEDAL]
	if btn.openFlag then
		return
	end
	armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")
	local arrowPic = CCArmature:create("ryxz_dianji")
    arrowPic:getAnimation():playWithIndex(0)
    arrowPic:connectMovementEventSignal(function(movementType, movementID) end)
    arrowPic:addTo(btn):center()
    btn.openFlag = arrowPic
end

function HomeAwardButtonView:updateTip()
	--抽装备
	local freeTimes = LotteryBO.getFreeTimes()
	if freeTimes > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_EQUIP], freeTimes, 65, 65)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_EQUIP])
	end

	--勋章
	local wears = MedalMO.getAllShowMedals()
	if wears > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_MEDAL], wears, 65, 65)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_MEDAL])
	end

	-- local activityNum = 0
	-- local activityList = ActivityBO.getShowList()
	-- if ActivityMO.clickView_ then
	-- 	for index = 1, #activityList do
	-- 		local activity = activityList[index]
	-- 		activityNum = activityNum + ActivityBO.getUnReceiveNum(activity.activityId)
	-- 	end
	-- else
	-- 	activityNum = #activityList

	-- 	if ActivityBO.isPayFirstOpen() then  -- 如果首充开启，还得额外增加一个活动
	-- 		activityNum = activityNum + 1
	-- 	end
	-- end

	-- if activityNum > 0 then
	-- 	UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY], activityNum, 60, 60)
	-- else
	-- 	UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY])
	-- end

	--探宝
	local luckCoinCount = LotteryMO.LotteryTreasureFree_ + UserMO.getResource(ITEM_KIND_PROP, PROP_ID_LUCKY_COIN)
	if luckCoinCount > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_EXPLORE], math.min(luckCoinCount, 99), 70, 65)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_EXPLORE])
	end

	-- --限时活动
	-- local activiteCount = #ActivityCenterMO.activityList_ + #ActivityCenterMO.activityLimitList_
	-- if not ActivityCenterMO.showTip and activiteCount > 0 then
	-- 	UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY_HOT], activiteCount, 60, 60)
	-- else
	-- 	UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY_HOT])
	-- end
	

	local allTipCount = freeTimes + luckCoinCount + wears
	-- if not ActivityCenterMO.showTip then
	-- 	allTipCount = allTipCount + activiteCount
	-- end
	if allTipCount > 0 then
		UiUtil.showTip(self.m_switchButton, math.min(allTipCount, 99), 65, 65)
	else
		UiUtil.unshowTip(self.m_switchButton)
	end


	
end

return HomeAwardButtonView
