
-- 部队view

-- 部队view的使用方式
ARMY_VIEW_FOR_UI    = 1 -- 从主页进入的显示
ARMY_VIEW_FOR_FIGHT = 2 -- 用于挑战副本
ARMY_VIEW_FOR_WIPE  = 3 -- 用于挂机扫荡
ARMY_VIEW_FOR_WORLD = 4 -- 用于攻击地图
ARMY_VIEW_FOR_GUARD = 5 -- 用于军团驻军
ARMY_VIEW_FOR_PARTYB = 6 --用于百团混战
ARMY_VIEW_MILITARY_AREA = 7 -- 用于军事矿区
ARMY_VIEW_FORTRESS = 8 -- 用于要塞战
ARMY_VIEW_AIRSHIP = 9 -- 用于飞艇集结
ARMY_VIEW_HUNTER = 10 -- 用于赏金任务
ARMY_VIEW_CORSS_MILITARY_AREA = 11 -- 用于跨服军事矿区

local ArmyView = class("ArmyView", UiNode)

function ArmyView:ctor(viewFor, pageIndex, fixHero)
	viewFor = viewFor or ARMY_VIEW_FOR_UI
	self.m_viewFor = viewFor
	self.m_pageIndex = pageIndex or 1

	if self.m_viewFor == ARMY_VIEW_FOR_UI then
		ArmyView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	else
		ArmyView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	end
	self.m_fixHero = fixHero
end

function ArmyView:onEnter()
	ArmyView.super.onEnter(self)

	if self.m_viewFor == ARMY_VIEW_FOR_WIPE then  -- 扫荡
		self:setTitle(CommonText[35])
	else
		-- 部队
		self:setTitle(CommonText[5])
	end

	self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onArmyUpdate))
	self.m_repairHandler = Notify.register(LOCAL_TANK_REPAIR_EVENT, handler(self, self.onRepairUpdate))

	local realCrDelegate = nil
	local function createDelegate(container, index)
		if index == 1 then  -- 设置部队
			self:showSettingArmy(container)
		elseif index == 2 then -- 执行任务
			self:showTask(container)
		elseif index == 3 then -- 坦克修复
			self:showRepairTank(container)
		elseif index == 4 then --军团集结
			self:showPartyMass(container)
		end
	end

	local function createDelegateHunter(container, index)
		-- body
		if index == 1 then  -- 设置部队
			self:showSettingArmy(container)
		end
	end

	if self.m_viewFor == ARMY_VIEW_HUNTER then
		realCrDelegate = createDelegateHunter
	else
		realCrDelegate = createDelegate
	end

	local function clickDelegate(container, index)
	end

	--  "设置部队", "执行任务", "修理坦克", "设置阵型"
	local pages = nil 
	if self.m_viewFor == ARMY_VIEW_HUNTER then 
		pages = {CommonText[12], }
	else
		pages = {CommonText[12], CommonText[13], CommonText[14]}
	end
	----未开启 飞艇 或者没有 军团，不能显示 军团集结
	if self.m_viewFor ~= ARMY_VIEW_HUNTER and UserMO.queryFuncOpen(UFP_AIRSHIP) and PartyBO.getMyParty() then
		table.insert(pages, CommonText[1003][2])
	end
	-- local pages = {CommonText[12], CommonText[13], CommonText[14], CommonText[15]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = realCrDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self:onUpdateTip()

	if UserMO.level_ <= 10 and UserMO.level_ >= 2 then 
		TriggerGuideMO.currentStateId = 15
		Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
	end
end

function ArmyView:onExit()
	ArmyView.super.onExit(self)
	
	if self.m_armyHandler then
		Notify.unregister(self.m_armyHandler)
		self.m_armyHandler = nil
	end

	if self.m_repairHandler then
		Notify.unregister(self.m_repairHandler)
		self.m_repairHandler = nil
	end
end

-- 设置部队
function ArmyView:showSettingArmy(container)
	local ArmySettingView = require("app.view.ArmySettingView")

	local armySettingFor = 0
	if self.m_viewFor == ARMY_VIEW_FOR_UI then
		armySettingFor = ARMY_SETTING_FOR_SETTING
	elseif self.m_viewFor == ARMY_VIEW_FOR_FIGHT then
		armySettingFor = ARMY_SETTING_FOR_COMBAT
	elseif self.m_viewFor == ARMY_VIEW_FOR_WIPE then
		armySettingFor = ARMY_SETTING_FOR_WIPE
	elseif self.m_viewFor == ARMY_VIEW_FOR_WORLD then
		armySettingFor = ARMY_SETTING_FOR_WORLD
	elseif self.m_viewFor == ARMY_VIEW_FOR_GUARD then
		armySettingFor = ARMY_SETTING_FOR_GUARD
	elseif self.m_viewFor == ARMY_VIEW_FOR_PARTYB then
		armySettingFor = ARMY_SETTING_FOR_PARTYB
	elseif self.m_viewFor == ARMY_VIEW_MILITARY_AREA then -- 军事矿区
		armySettingFor = ARMY_SETTING_FOR_MILITARY_AREA
	elseif self.m_viewFor == ARMY_VIEW_FORTRESS then
		armySettingFor = ARMY_SETTING_FORTRESS_ATTACK
	elseif self.m_viewFor == ARMY_VIEW_AIRSHIP then
		armySettingFor = ARMY_SETTING_AIRSHIP_ATTACK
	elseif self.m_viewFor == ARMY_VIEW_HUNTER then
		armySettingFor = ARMY_SETTING_HUNTER
	elseif self.m_viewFor == ARMY_VIEW_CORSS_MILITARY_AREA then -- 跨服军事矿区
		armySettingFor = ARMY_SETTING_FOR_CROSS_MILITARY_AREA
	end

	local commanderLocked = false
	if not self.m_armyFormation then
		if self.m_viewFor == ARMY_VIEW_HUNTER then
			self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_HUNTER)
			if self.m_armyFormation == nil then
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
			end
		elseif self.m_viewFor == ARMY_VIEW_FOR_FIGHT or self.m_viewFor == ARMY_VIEW_FOR_WIPE then
			if TankMO.formation_[FORMATION_FOR_COMBAT_TEMP] then
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_COMBAT_TEMP)
			else
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
			end
		elseif self.m_viewFor == ARMY_VIEW_FORTRESS then
			if TankMO.formation_[FORMATION_FORTRESS_ATTACK] then
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FORTRESS_ATTACK)
			else
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
			end
		else
			if self.m_fixHero == nil then
				self.m_armyFormation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
			else
				self.m_armyFormation = TankBO.getMaxFightFormation(nil, self.m_fixHero)
				self.m_armyFormation.commander = self.m_fixHero.heroId
				commanderLocked = true
			end
		end
	end

	if self.m_viewFor ~= ARMY_VIEW_HUNTER then
		_, self.m_armyFormation = TankBO.checkFormation(self.m_armyFormation) -- 检测当前阵型的部队
	end
	if not HeroBO.canFormationFight(self.m_armyFormation) and self.m_viewFor ~= ARMY_VIEW_HUNTER then
		self.m_armyFormation.commander = 0
	end

	local function onArmyFormation(event)
		-- dump(event)
		local formation = event.formation
		self.m_armyFormation = formation
	end

	--先判断是否有战术
	local format = clone(self.m_armyFormation)
	if self.m_armyFormation.tacticsKeyId and #self.m_armyFormation.tacticsKeyId > 0 then
		format.tacticsKeyId = TacticsMO.isTacticCanUse(self.m_armyFormation)
	end

	local view = ArmySettingView.new(container:getContentSize(), armySettingFor, format, commanderLocked, self.m_fixHero):addTo(container)
	view:addEventListener("ARMY_FORMATION_EVENT", onArmyFormation)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	self.armySettingView = view

	--触发引导
	if CombatMO.curChoseBtttleId_ == 201 and NewerBO.combatNewerIsDone(201) == false then
		Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = 500,type = 1})
		NewerBO.saveCombatState(nil,201)
	end
	
end

-- 执行任务
function ArmyView:showTask(container)
	local ArmyTaskTableView = require("app.scroll.ArmyTaskTableView")
	local view = ArmyTaskTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
	-- view:cellAppearRecursively()

	if ArmyMO.dirtyArmyData_ then  -- 需要重新拉取数据
		Loading.getInstance():show()
		ArmyBO.asynGetArmy(function() TankBO.asynGetTank(); Loading.getInstance():unshow() end)
	end
end

-- 修复坦克
function ArmyView:showRepairTank(container)
	container:removeAllChildren()

	-- 全部修复
	local desc = ui.newTTFLabel({text = CommonText[29] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 20, y = container:getContentSize().height - 85, color = COLOR[11]}):addTo(container)

	local repairTanks, cost = TankMO.getNeedRepairTanks()
	local cost = TankMO.calcRepairCost(repairTanks)

	local coinTotal = cost.coinTotal
	local gemTotal = cost.gemTotal

	local function doneRepair()
		ManagerSound.playSound("tank_repair_done")

		Loading.getInstance():unshow()
		
		self:onUpdateTip()
		
		Toast.show(CommonText[372]) -- 修复成功
		-- self:showRepairTank(container)
	end

	local function gotoRepair(tankId, repairType, cost)
		if repairType == 2 then  -- 金币修复
			local resData = UserMO.getResourceData(ITEM_KIND_COIN)
			
			local function gotoAction()
				if cost.coin > UserMO.getResource(ITEM_KIND_COIN) then
					require("app.dialog.CoinTipDialog").new(resData.name .. CommonText[66]):push()
					return
				end

				Loading.getInstance():show()
				TankBO.asynRepair(doneRepair, tankId, repairType)
			end
			
			if UserMO.consumeConfirm then
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[445], cost.coin, resData.name), function() gotoAction() end):push()
			else
				gotoAction()
			end
		else  -- 宝石修复
			if cost.gem > UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE) then
				local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
				Toast.show(resData.name .. CommonText[66])  -- 不足，无法修复
				return
			end

			Loading.getInstance():show()
			TankBO.asynRepair(doneRepair, tankId, repairType, cost.gem)
		end
	end

	local function repairCallback(tag, sender) -- 全部修复的按钮回调
		ManagerSound.playNormalButtonSound()
		if #repairTanks <= 0 then
			Toast.show(CommonText[192])  -- 没有需要修复的坦克
			return
		end
		gotoRepair(0, sender.status, {coin = coinTotal, gem = gemTotal})
	end

	-- 金币
	local coinTag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(container)
	coinTag:setPosition(container:getContentSize().width / 2 - 20, container:getContentSize().height - 35)

	local coin = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt", x = coinTag:getPositionX() + coinTag:getContentSize().width / 2, y = coinTag:getPositionY()}):addTo(container)
	coin:setAnchorPoint(cc.p(0, 0.5))
	container.coinLabel_ = coin
	container.coinLabel_:setString(UiUtil.strNumSimplify(coinTotal))

	-- 金币修复
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local coinBtn = MenuButton.new(normal, selected, nil, repairCallback):addTo(container)
	coinBtn.status = 2
	coinBtn:setPosition(container:getContentSize().width / 2 - 20, desc:getPositionY())
	coinBtn:setLabel(CommonText[30])

	-- 宝石
	local gemTag = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE):addTo(container)
	gemTag:setPosition(container:getContentSize().width / 2 + 175, coinTag:getPositionY())

	local gem = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt", x = gemTag:getPositionX() + gemTag:getBoundingBox().size.width / 2, y = gemTag:getPositionY()}):addTo(container)
	gem:setAnchorPoint(cc.p(0, 0.5))
	container.stoneLabel_ = gem
	container.stoneLabel_:setString(UiUtil.strNumSimplify(gemTotal))

	-- 宝石修复
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local stoneBtn = MenuButton.new(normal, selected, nil, repairCallback):addTo(container)
	stoneBtn.status = 1
	stoneBtn:setPosition(container:getContentSize().width / 2 + 175, desc:getPositionY())
	stoneBtn:setLabel(CommonText[30])

	local ArmyRepairTableView = require("app.scroll.ArmyRepairTableView")
	local view = ArmyRepairTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 120), repairTanks, cost):addTo(container)
	view:addEventListener("REPAIR_TANK_EVENT", function(event) gotoRepair(event.tankId, event.status, event.cost) end)
	view:setPosition(0, 0)
	container.repairView = view
	container.repairView:reloadData()
end

-- 设置阵型
function ArmyView:showSettingFormat(container)
	-- local formation = TankMO.getFormationByType(FORMATION_FOR_TEMPLATE)
	-- local height = container:getContentSize().height - 35
	-- local deltaY = 35

	-- local labelColor = cc.c3b(231, 190, 112)
	-- -- 行军目标
	-- local label1 = ui.newTTFLabel({text = CommonText[20] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = height, color = labelColor}):addTo(container)

	-- -- 行军目标
	-- local label2 = ui.newTTFLabel({text = CommonText[21] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = height - deltaY, color = labelColor}):addTo(container)

	-- -- 带兵数量
	-- local label3 = ui.newTTFLabel({text = CommonText[22] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = height - deltaY * 2, color = labelColor}):addTo(container)

	-- -- 部队载重
	-- local label4 = ui.newTTFLabel({text = CommonText[23] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 25, y = height - deltaY * 3, color = labelColor}):addTo(container)

	-- local ArmyFormationView = require("app.view.ArmyFormationView")
	-- local view = ArmyFormationView.new(formation):addTo(container)
	-- view:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 610)

	-- -- 最大战力
	-- local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	-- local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	-- local maxBtn = MenuButton.new(normal, selected, nil, nil):addTo(container)
	-- maxBtn:setLabel(CommonText[17])
	-- maxBtn:setPosition(container:getContentSize().width / 2, 10)

	-- -- 保存阵型
	-- local normal = display.newSprite(IMAGE_COMMON .. 'btn_5_normal.png')
	-- local selected = display.newSprite(IMAGE_COMMON .. 'btn_5_selected.png')
	-- local saveBtn = MenuButton.new(normal, selected, nil, nil):addTo(container)
	-- saveBtn:setLabel(CommonText[31])
	-- saveBtn:setPosition(container:getContentSize().width - 110, 10)
end

function ArmyView:onUpdateTip()
	if self.m_viewFor ~= ARMY_VIEW_HUNTER then
		local armies = ArmyMO.getAllArmies()
		if #armies > 0 then
			UiUtil.showTip(self.m_pageView, #armies, 300, self.m_pageView:getContentSize().height + 35, 40, "tip2__")
		else
			UiUtil.unshowTip(self.m_pageView, "tip2__")
		end

		local repairTanks = TankMO.getNeedRepairTanks()
		if #repairTanks > 0 then  -- 有坦克要维修
			UiUtil.showTip(self.m_pageView, #repairTanks, 460, self.m_pageView:getContentSize().height + 35, 40, "tip3__")
		else
			UiUtil.unshowTip(self.m_pageView, "tip3__")
		end
	end
end

function ArmyView:onArmyUpdate(event)
	local force = false
	if event.obj then  -- 强制显示第二页
		force = event.obj.force
	end
	if self.m_pageView:getPageIndex() ~= 2 and force then
		self.m_pageView:setPageIndex(2)
	elseif self.m_pageView:getPageIndex() == 2 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end

	self:onUpdateTip()
end

function ArmyView:onRepairUpdate(event)
	if self.m_pageView:getPageIndex() == 3 then
		self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	end

	self:onUpdateTip()
end

-- 军团集结
function ArmyView:showPartyMass(container)
	local view = require("app.view.PartyMassView")
	self.view = view.new(container:width(), container:height()):addTo(container)
	self.view:setPosition(0, 0)
end

return ArmyView
