
-- 设置部队的view节点

-- ARMY_SETTING_FOR_SETTING = 1 -- 用于设置
-- ARMY_SETTING_FOR_COMBAT  = 2 -- 用于副本
-- ARMY_SETTING_FOR_WIPE    = 3 -- 用于扫荡
-- ARMY_SETTING_FOR_ARENA   = 4 -- 用于竞技场
-- ARMY_SETTING_FOR_WORLD   = 5 -- 用于世界
-- ARMY_SETTING_FOR_GUARD   = 6 -- 用于驻军
-- ARMY_SETTING_FOR_PARTYB   = 7 -- 用于百团混战
-- ARMY_SETTING_FOR_BOSS    = 8 -- 用于世界BOSS
-- ARMY_SETTING_FOR_MILITARY_AREA  = 9 -- 用于军事矿区
-- ARMY_SETTING_FORTRESS  = 10 -- 用于要塞战防守
-- ARMY_SETTING_FORTRESS_ATTACK  = 11 -- 用于要塞战攻击
-- ARMY_SETTING_FOR_ALTAR_BOSS    = 12 -- 用于军团BOSS
-- ARMY_SETTING_FOR_CROSS    = 13 -- 用于跨服战
-- ARMY_SETTING_FOR_CROSS1    = 14 -- 用于跨服战2
-- ARMY_SETTING_FOR_CROSS2    = 15 -- 用于跨服战3
-- ARMY_SETTING_FOR_CROSSPARTY    = 16 -- 用军团跨服战
-- ARMY_SETTING_AIRSHIP_ATTACK = 17 --用于飞艇攻击
-- ARMY_SETTING_AIRSHIP_DEFEND = 18 --用于飞艇驻防
-- ARMY_SETTING_HUNTER = 19 --用于赏金
-- ARMY_SETTING_FOR_CROSS_MILITARY_AREA  = 20 -- 用于跨服军事矿区

-- ARMY_SETTING_FOR_EXERCISE1    = 101 -- 演习布阵1
-- ARMY_SETTING_FOR_EXERCISE2    = 102 -- 演习布阵2
-- ARMY_SETTING_FOR_EXERCISE3    = 103 -- 演习布阵3

local ArmySettingView = class("ArmySettingView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function ArmySettingView:ctor(size, viewFor, defaultFormation, commanderLocked, lockedHero)
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_viewFor = viewFor
	self.m_defaultFormation = defaultFormation  -- 初始显示默认的阵型
	self.m_commanderLocked = commanderLocked or false
	self.m_lockedHero = lockedHero
	self.m_choseFormIndex = 0 --选择战术阵型。默认没选
end

function ArmySettingView:onEnter()
	self:showUI(self)
	self.m_choseHeroHandler = Notify.register(LOCAL_CHOSE_HERO_EVENT, handler(self, self.onChoseHero))
	self.m_choseTacticHandler = Notify.register(LOCAL_TACTICS_FORARMY, handler(self, self.onChoseTactic))
	self.m_choseForamtionHandler = Notify.register(LOCAL_TACTICS_UPDATA_ITEM, handler(self, self.updateItem))
	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onEquipUpdate))
	self.m_partHandler = Notify.register(LOCLA_PART_EVENT, handler(self, self.onPartUpdate))
	self.m_tankHandler = Notify.register(LOCAL_TANK_EVENT, handler(self, self.onTankUpdate))
end

function ArmySettingView:onExit()
	if self.m_choseHeroHandler then
		Notify.unregister(self.m_choseHeroHandler)
		self.m_choseHeroHandler = nil
	end
	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end
	if self.m_partHandler then
		Notify.unregister(self.m_partHandler)
		self.m_partHandler = nil
	end
	if self.m_tankHandler then
		Notify.unregister(self.m_tankHandler)
		self.m_tankHandler = nil
	end
	if self.m_choseTacticHandler then
		Notify.unregister(self.m_choseTacticHandler)
		self.m_choseTacticHandler = nil
	end

	if self.m_choseForamtionHandler then
		Notify.unregister(self.m_choseForamtionHandler)
		self.m_choseForamtionHandler = nil
	end
end

function ArmySettingView:showUI(container)
	local formation = nil
	if not self.m_defaultFormation then
		formation = TankMO.getEmptyFormation()
		if self.m_viewFor == ARMY_SETTING_FOR_SETTING or self.m_viewFor == ARMY_SETTING_FOR_MILITARY_AREA or self.m_viewFor == ARMY_SETTING_FOR_CROSS_MILITARY_AREA  then
			formation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
			_, formation = TankBO.checkFormation(formation) -- 检测当前阵型的部队
		elseif self.m_viewFor == ARMY_SETTING_FOR_COMBAT or self.m_viewFor == ARMY_SETTING_FOR_WIPE then
			formation = TankMO.getFormationByType(FORMATION_FOR_COMBAT_TEMP)
			_, formation = TankBO.checkFormation(formation) -- 检测当前阵型的部队
		elseif self.m_viewFor == ARMY_SETTING_HUNTER then
			formation = TankMO.getFormationByType(FORMATION_FOR_FIGHT)
		elseif self.m_viewFor == ARMY_SETTING_FOR_ARENA then
			formation = TankMO.getFormationByType(FORMATION_FOR_ARENA)
		elseif self.m_viewFor == ARMY_SETTING_FOR_BOSS then
			formation = TankMO.getFormationByType(FORMATION_FOR_BOSS)
			--gdump(formation, "ArmySettingView:showUI BOSSSSSSSSSSSSSSSSS")
		elseif self.m_viewFor == ARMY_SETTING_FORTRESS then -- 要塞战防守
			formation = TankMO.getFormationByType(FORMATION_FORTRESS)
			if not formation then
				formation = TankMO.getEmptyFormation()
			end
		elseif self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK then -- 要塞战攻击
			formation = TankMO.getFormationByType(FORMATION_FORTRESS_ATTACK)
			if not formation then
				formation = TankMO.getEmptyFormation()
			end
		elseif self.m_viewFor == ARMY_SETTING_FOR_ALTAR_BOSS then
			formation = TankMO.getFormationByType(FORMATION_FOR_ALTAR_BOSS)
			-- formation = TankMO.getFormationByType(FORMATION_FOR_BOSS)
		elseif self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
			formation = TankMO.getFormationByType(self.m_viewFor - (ARMY_SETTING_FOR_EXERCISE1 - FORMATION_FOR_EXERCISE1))
			if not formation then
				formation = TankMO.getEmptyFormation()
			end
		elseif self.m_viewFor == ARMY_SETTING_FOR_CROSSPARTY then
			formation = CrossPartyBO.newFormation_ or TankMO.getEmptyFormation()
		elseif self.m_viewFor >= ARMY_SETTING_FOR_CROSS then
			formation = TankMO.getFormationByType(self.m_viewFor)
			if not formation then
				formation = TankMO.getEmptyFormation()
			end
		end
	else
		formation = self.m_defaultFormation
	end
	-- gdump(formation, "阵型校对后")

	-- 指挥官
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 26)

	local title = ui.newTTFLabel({text = CommonText[51], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	-- 属性背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	attrBg:setPreferredSize(cc.size(316, 156))
	attrBg:setPosition(450, container:getContentSize().height - 130)


	local attrFor = 0
	if self.m_viewFor == ARMY_SETTING_FOR_SETTING then
		attrFor = ARMY_ATTR_FOR_LOCAL
	elseif self.m_viewFor == ARMY_SETTING_FOR_COMBAT or self.m_viewFor == ARMY_SETTING_FOR_WIPE then
		attrFor = ARMY_ATTR_FOR_COMBAT
	elseif self.m_viewFor == ARMY_SETTING_FOR_ARENA then
		attrFor = ARMY_ATTR_FOR_ARENA
	elseif self.m_viewFor == ARMY_SETTING_FOR_WORLD then
		attrFor = ARMY_ATTR_FOR_WORLD
	elseif self.m_viewFor == ARMY_SETTING_FOR_GUARD then
		attrFor = ARMY_ATTR_FOR_GUARD
	elseif self.m_viewFor == ARMY_SETTING_FOR_PARTYB then
		attrFor = ARMY_ATTR_FOR_PARTYB
	elseif self.m_viewFor == ARMY_SETTING_FOR_BOSS then
		attrFor = ARMY_ATTR_FOR_BOSS
	elseif self.m_viewFor == ARMY_SETTING_FOR_MILITARY_AREA then
		attrFor = ARMY_ATTR_FOR_MILITARY_AREA
	elseif self.m_viewFor == ARMY_SETTING_FORTRESS then
		attrFor = ARMY_SETTING_FORTRESS
	elseif self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK then
		attrFor = ARMY_SETTING_FORTRESS_ATTACK
	elseif self.m_viewFor == ARMY_SETTING_FOR_ALTAR_BOSS then
		attrFor = ARMY_ATTR_FOR_ALTAR_BOSS
	elseif self.m_viewFor == ARMY_SETTING_CROSS then
		attrFor = ARMY_SETTING_CROSS
	elseif self.m_viewFor == ARMY_SETTING_HUNTER then
		attrFor = ARMY_ATTR_FOR_HUNTER
	elseif self.m_viewFor == ARMY_SETTING_FOR_CROSS_MILITARY_AREA then
		attrFor = ARMY_ATTR_FOR_CROSS_MILITARY_AREA
	end

	--警示图标（当副本界面并且战力小于敌方战力的时候显示）
	local alarmIcon
	if CombatMO.curChoseBattleType_ == COMBAT_TYPE_COMBAT or CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
		alarmIcon = display.newSprite(IMAGE_COMMON .. "danger.png", attrBg:getContentSize().width - 30, attrBg:getContentSize().height + 10):addTo(attrBg)
	end
	
	local ArmyFightAttrTableView = require("app.scroll.ArmyFightAttrTableView")
	local view = ArmyFightAttrTableView.new(cc.size(304, 148), attrFor, alarmIcon):addTo(attrBg)
	view:setPosition((attrBg:getContentSize().width - view:getContentSize().width) / 2, (attrBg:getContentSize().height - view:getContentSize().height) / 2)
	container.attrView = view
	self:showHero(formation.commander,formation)
	-- 阵型
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 238)

	local title = ui.newTTFLabel({text = CommonText[52], font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)


	--战术
	local tacticForm = clone(formation)
	self.m_tacticForm = tacticForm
	local box = display.newSprite("image/tactics/icon_tactics.png")
	local awardBtn = ScaleButton.new(box, function ()
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_TACTICCENTER) then 
			Toast.show(string.format(CommonText[4026], BuildMO.getOpenLevel(BUILD_ID_TACTICCENTER)))
			return
		end
		UiDirector.push(require("app.view.TacticalCenterView").new(self.m_tacticForm,nil,self.m_viewFor, self.m_choseFormIndex))
	end):addTo(container)
	awardBtn:setPosition(container:width() / 2 - 70, attrBg:y())
	self.m_awardBtn = awardBtn
	--战术套装图标
	--战术坦克类型套图标
	if self.m_tacticForm.tacticsKeyId and #self.m_tacticForm.tacticsKeyId > 0 then
		local isTacticSuit = TacticsMO.isTacticSuit(self.m_tacticForm, true) -- 战术类型
		local quality, tankType = TacticsMO.isArmsSuit(self.m_tacticForm, true)  --兵种类型

		if isTacticSuit then
			local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png")
			self.m_awardBtn:setTouchSprite(display.newSprite("image/tactics/tactics_"..isTacticSuit..".png"))

			if tankType then
				local tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png"):alignTo(self.m_awardBtn, -50, 1)
				self.m_awardBtn.tankItem = tankItem
			end
		end
	end

	-- 阵型背景框
	local formatBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	formatBg:setPreferredSize(cc.size(570, 356))
	formatBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 440)

	-- 前排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_17.png", 24, 262):addTo(formatBg)

	-- 后排
	local tag = display.newSprite(IMAGE_COMMON .. "info_bg_18.png", 24, 94):addTo(formatBg)

	local function onUpdateFormation(event)
		if container and container.attrView then
			container.attrView:setFormation(container.formationView:getFormation())
			container.attrView:reloadData()

			self:showBuff(container.formationView:getFormation())
		end

		self:dispatchEvent({name = "ARMY_FORMATION_EVENT", formation = container.formationView:getFormation()})
	end

	local ArmyFormationView = require("app.view.ArmyFormationView")
	local fview = ArmyFormationView.new(FORMATION_FOR_TANK, formation, TankBO.getMyFormationLockData(), nil, nil, self.m_viewFor):addTo(container, 10)
	fview:setPosition(container:getContentSize().width / 2 + 20, container:getContentSize().height - 606)
	fview:addEventListener("UPDATE_FORMATION_EVENT", onUpdateFormation)
	container.formationView = fview

	if self.m_viewFor ~= ARMY_SETTING_FOR_ARENA and self.m_viewFor < ARMY_SETTING_FOR_EXERCISE1 
			and not (self.m_viewFor >= ARMY_SETTING_FOR_CROSS and self.m_viewFor <= ARMY_SETTING_FOR_CROSSPARTY) and self.m_viewFor ~= ARMY_SETTING_HUNTER then
		_, formation = TankBO.checkFormation(formation,self.m_viewFor)
		container.formationView:updateUI(formation)
	end
	view:setFormation(formation)
	view:reloadData()

	self:showBuff(container.formationView:getFormation())

	self:showUnlock(container.formationView)

	local function onEffect(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.EffectView").new():push()
	end

	local function onBack(tag, sender)
		ManagerSound.playNormalButtonSound()
		if TankMO.isEmptyFormation(TankMO.getFormationByType(self.m_viewFor - (ARMY_SETTING_FOR_EXERCISE1 - FORMATION_FOR_EXERCISE1))) then
			Toast.show(CommonText[20101])
			return
		end
		if not ExerciseMO.inPrepareTime() then
			Toast.show(CommonText[20105])
			return
		end
		-- 是否确定取消
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[20098], function()
				Loading.getInstance():show()
				local kind = self.m_viewFor - (ARMY_SETTING_FOR_EXERCISE1 - FORMATION_FOR_EXERCISE1)
				local function doneSetFormat()
					Loading.getInstance():unshow()
					Toast.show(CommonText[20099])
					container.formationView:updateUI(TankMO.getFormationByType(kind))
					self:showHero(0)
					TankMO.formation_[kind] = nil
				end
				local formation = TankMO.getEmptyFormation()
				local clean = true
				TankBO.asynSetForm(doneSetFormat, kind, formation, clean)
			end):push()
	end

	if self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
		-- 撤回
		local normal = display.newSprite(IMAGE_COMMON .. "btn_back_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_back_selected.png")
		local zengBtn = MenuButton.new(normal, selected, nil, onBack):addTo(container)
		zengBtn:setPosition(110, container:getContentSize().height - 652)
	end	

	-- 增益
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local zengBtn = MenuButton.new(normal, selected, nil, onEffect):addTo(container)
	zengBtn:setPosition(252, container:getContentSize().height - 652)
	zengBtn:setLabel(CommonText[135])

	local function gotoEquip(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.EquipView").new():push()
	end

	-- 装备
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local equipBtn = MenuButton.new(normal, selected, nil, gotoEquip):addTo(container)
	equipBtn:setPosition(394, container:getContentSize().height - 652)
	equipBtn:setLabel(CommonText[7])
	self.m_equipButton = equipBtn

	local function gotoComponent(tag, sender)
		ManagerSound.playNormalButtonSound()

		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_COMPONENT) then
			local build = BuildMO.queryBuildById(BUILD_ID_COMPONENT)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_COMPONENT), build.name))
			return
		end

		require("app.view.ComponentView").new(BUILD_ID_COMPONENT):push()
	end

	-- 配件
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local partBtn = MenuButton.new(normal, selected, nil, gotoComponent):addTo(container)
	partBtn:setPosition(536, equipBtn:getPositionY())
	partBtn:setLabel(CommonText[11])
	self.m_partButton = partBtn

	self:showButtons(container)

	self:onEquipUpdate()
	self:onPartUpdate()


end

-- 展示底部的按钮
function ArmySettingView:showButtons(container)
	local function useFormat(tag, sender)
		ManagerSound.playNormalButtonSound()
		local ChoseFormationDialog = require("app.dialog.ChoseFormationDialog")
		ChoseFormationDialog.new(container.formationView:getFormation(), function (formation)
				gdump(formation, "ArmySettingView chose formation")
				container.formationView:updateUI(formation)
				self:showHero(formation.commander) -- 更新显示武将
				self:updateTactic(formation)
			end, self.m_viewFor, self.m_commanderLocked, self.m_lockedHero):push()
	end

	-- 阵型
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local useBtn = MenuButton.new(normal, selected, nil, useFormat):addTo(container)
	useBtn:setLabel(CommonText[52])
	useBtn:setPosition(110, 50)
	useBtn:setVisible(not (self.m_viewFor >= ARMY_SETTING_FOR_CROSS and self.m_viewFor <= ARMY_SETTING_FOR_CROSS2))

	local function maxCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		local tanks = nil
		if self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
			tanks = ExerciseBO.getFightTank(self.m_viewFor)
		elseif self.m_viewFor >= ARMY_SETTING_FOR_CROSS then
			tanks = CrossBO.getFightTank(self.m_viewFor)
		end
		if sender.status == 1 then  -- 当前按钮是最大战力，则需要显示最大战力
			local fightHero = false
			local temp = {}
			if self.m_commanderLocked == false then
				fightHero = HeroBO.getMaxFightHeroNew(false,self.m_viewFor)
				temp = HeroBO.getHeroCompareNew(fightHero, self.m_viewFor)
			else
				fightHero = self.m_lockedHero
			end

			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then temp = {} end
			local formation = nil
			if table.nums(temp) > 0 then
				local list = {}
				for k,v in pairs(temp) do
					local formation,total = TankBO.getMaxFightFormation(tanks, v)
					table.insert(list,{total = total,formation = formation, hero = v})
				end
				table.sort(list, function(a,b)
					return a.total > b.total
				end)
				formation = TankBO.sortFormation(list[1].formation,list[1].hero)
			else
				local forceFightHeroNil = false
				if fightHero == nil then
					forceFightHeroNil = true
				end
				formation = TankBO.getMaxFightFormation(tanks, fightHero, self.m_viewFor, forceFightHeroNil)
				if fightHero then
					formation.commander = fightHero.heroId
				end
			end
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
				formation.commander = 0
			end
			self:showHero(formation.commander) -- 更新显示武将
			container.formationView:updateUI(formation)
			self:updateTactic(formation)
			
			sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_5_normal.png"))
			sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_5_selected.png"))
			sender:setLabel(CommonText[60])  -- 最大载重
			sender.status = 2
		else
			local fightHero = false
			local temp = {}
			if self.m_commanderLocked == true then
				fightHero = self.m_lockedHero
			end
			local formation = TankBO.getMaxPayloadFormation(fightHero, tanks, self.m_viewFor, self.m_commanderLocked)
			-- gdump(formation, "最大载重")
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
				formation.commander = 0
			end
			self:showHero(formation.commander) -- 更新显示武将
			container.formationView:updateUI(formation)
			self:updateTactic(formation)
			-- Toast.show(CommonText[59])
			sender:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_1_normal.png"))
			sender:setSelectedSprite(display.newSprite(IMAGE_COMMON .. "btn_1_selected.png"))
			sender:setLabel(CommonText[17])  -- 最大战力
			sender.status = 1
		end
	end

	-- 最大战力
	local normal = display.newSprite(IMAGE_COMMON .. 'btn_1_normal.png')
	local selected = display.newSprite(IMAGE_COMMON .. 'btn_1_selected.png')
	local maxBtn = MenuButton.new(normal, selected, nil, maxCallback):addTo(container)
	maxBtn.status = 1 -- 表示当前显示最大战力
	maxBtn:setLabel(CommonText[17])
	maxBtn:setPosition(container:getContentSize().width / 2, 50)
	self.maxBtn = maxBtn

	if self.m_viewFor == ARMY_SETTING_FOR_SETTING or self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
		local kind = FORMATION_FOR_FIGHT
		local canSet = true
		if self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
			kind = self.m_viewFor - (ARMY_SETTING_FOR_EXERCISE1 - FORMATION_FOR_EXERCISE1)
			local num = 0
			for i = FORMATION_FOR_EXERCISE1,FORMATION_FOR_EXERCISE3 do
				if kind ~= i and not TankMO.isEmptyFormation(TankMO.getFormationByType(i)) then
					num = num + 1
				end
			end
			if num >= 2 then canSet = false end
		end
		local function doneSetFormat()
			Loading.getInstance():unshow()
			-- 设置阵型成功
			Toast.show(CommonText[59])
			container.formationView:updateUI(TankMO.getFormationByType(kind))
		end

		local function setFormat(tag, sender)
			ManagerSound.playNormalButtonSound()
			if self.m_viewFor >= ARMY_SETTING_FOR_EXERCISE1 then
				if not ExerciseBO.data.isEnrolled then
					Toast.show(CommonText[20104])
					return
				elseif not ExerciseMO.inPrepareTime() then
					Toast.show(CommonText[20105])
					return
				end	
			end
			if not canSet then
				Toast.show(CommonText[20100])
				return
			end
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			local clean = false
			if not TankBO.hasFightFormation(formation) then  -- 设置防守阵型可以设置为空的
				clean = true
			end
			Loading.getInstance():show()
			formation.commander = self.m_heroId  -- 更新指挥官
			TankBO.asynSetForm(doneSetFormat, kind, formation, clean)
		end

		-- 设置防守
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_5_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_5_selected.png')
		local maxBtn = MenuButton.new(normal, selected, nil, setFormat):addTo(container)
		maxBtn:setLabel(CommonText[19])
		maxBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_COMBAT then  -- 用于挑战副本
		local function doneDoCombat(result, atkFormat, defFormat, combatData)
			UiDirector.pop(function()
				Loading.getInstance():unshow()
				
				if CombatMO.curSkipBattle_ then -- 省流量不看战斗
					local BattleBalanceView = require("app.view.BattleBalanceView")
					BattleBalanceView.new():push()
				else
					BattleMO.reset()
					BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
					BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
					BattleMO.setFightData(CombatMO.curBattleFightData_)

					if CombatMO.curChoseBattleType_ == COMBAT_TYPE_PARTY_COMBAT then
						require("app.view.BattleView").new("image/bg/bg_battle.jpg"):push()
					else
						require("app.view.BattleView").new():push()
					end
				end
			end)
		end

		local function onFightCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
				local combatDB = CombatMO.queryExploreById(CombatMO.curChoseBtttleId_)
				if combatDB.type == EXPLORE_TYPE_EQUIP then
					local equips = EquipMO.getFreeEquipsAtPos()
					local remainCount = UserMO.equipWarhouse_ - #equips
					if remainCount <= 0 then
						Toast.show(CommonText[711])  -- 仓库已满
						return
					end
				end
			end

			Loading.getInstance():show()
			if CombatMO.curChoseBattleType_ == COMBAT_TYPE_PARTY_COMBAT then
				gdump(formation,"formationformation")
				PartyCombatBO.asynDoPartyCombat(doneDoCombat,CombatMO.curChoseBtttleId_,formation)
			else
				CombatBO.asynDoCombat(doneDoCombat, CombatMO.curChoseBattleType_, CombatMO.curChoseBtttleId_, formation)
			end
		end

		-- 出战
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local maxBtn = MenuButton.new(normal, selected, nil, onFightCallback):addTo(container)
		maxBtn:setLabel(CommonText[18])
		maxBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_WIPE then -- 用于扫荡
		local function onWipeCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if CombatMO.curChoseBattleType_ == COMBAT_TYPE_COMBAT then
				local resData = UserMO.getResourceData(ITEM_KIND_POWER)
				local power = UserMO.getResource(ITEM_KIND_POWER)
				
				if power < COMBAT_TAKE_POWER then -- 能量不足
					require("app.dialog.BuyPawerDialog").new():push()
					Toast.show(resData.name .. CommonText[223])  -- 能量不足
					return
				end
			end

			local function doneWipe()
				gprint("ArmySettingView: wipe stop!!!!")
				local formation = container.formationView:getFormation()
				_, formation = TankBO.checkFormation(formation,self.m_viewFor)

				container.formationView:updateUI(formation)
				container.attrView:setFormation(container.formationView:getFormation())
				container.attrView:reloadData()
			end

			if CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
				local exploreDB = CombatMO.queryExploreById(CombatMO.curChoseBtttleId_)
				local count = CombatBO.getExploreChallengeLeftCount(exploreDB.type)
				if count <= 0 then
					local view = UiDirector.getUiByName("CombatLevelView")
					if view then
						view:onBuyCombat()
					end
					return
				end
			end
			local WipeCombatDialog = require("app.dialog.WipeCombatDialog")
			WipeCombatDialog.new(CombatMO.curChoseBattleType_, CombatMO.curChoseBtttleId_, formation, doneWipe):push()
		end

		-- 出战
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local wipeBtn = MenuButton.new(normal, selected, nil, onWipeCallback):addTo(container)
		wipeBtn:setLabel(CommonText[1841])
		wipeBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_ARENA then -- 竞技场
		local function onSaveCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			local function doneFormat()
				-- 设置阵型成功
				Loading.getInstance():unshow()
				Toast.show(CommonText[59])
				container.formationView:updateUI(TankMO.getFormationByType(FORMATION_FOR_ARENA))

				--触发引导
        		TriggerGuideBO.showNewerGuide()
			end

			Loading.getInstance():show()

			if ArenaMO.firstEnter_ then  -- 首次进入竞技场
				ArenaBO.asynInitArena(doneFormat, formation)
			else
				TankBO.asynSetForm(doneFormat, FORMATION_FOR_ARENA, formation)
			end
		end

		-- 保存阵型
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local saveBtn = MenuButton.new(normal, selected, nil, onSaveCallback):addTo(container)
		saveBtn:setLabel(CommonText[31])
		saveBtn:setPosition(container:getContentSize().width - 110, 50)
		self.saveBtn = saveBtn
	elseif self.m_viewFor == ARMY_SETTING_FOR_WORLD then -- 世界
		local num = UserMO.getResource(ITEM_KIND_POWER)
		if num < 1 then  -- 能量不足
			require("app.dialog.BuyPawerDialog").new():push()
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			Toast.show(resData.name .. CommonText[223])
			return
		end

		local function onFightCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
				Toast.show(CommonText[366][2])
				return
			end

			local armyNum = ArmyMO.getFightArmies()
			if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
				Toast.show(CommonText[1629])
				return
			end

			local function doneAttack()
				Loading.getInstance():unshow()
			end

			Loading.getInstance():show()
			WorldBO.asynAttackPos(doneAttack, WorldMO.curAttackPos_.x, WorldMO.curAttackPos_.y, formation)
		end

		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local fightBtn = MenuButton.new(normal, selected, nil, onFightCallback):addTo(container)
		fightBtn:setLabel(CommonText[18])
		fightBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_GUARD then -- 驻军
		local function onGuardCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
				Toast.show(CommonText[366][2])
				return
			end

			local function doneGuardPos()
				Loading.getInstance():unshow()
			end

			Loading.getInstance():show()
			WorldBO.asynGuardPos(doneGuardPos, WorldMO.curGuardPos_.x, WorldMO.curGuardPos_.y, formation)
		end

		local normal = display.newSprite(IMAGE_COMMON .. 'btn_10_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_10_selected.png')
		local guardBtn = MenuButton.new(normal, selected, nil, onGuardCallback):addTo(container)
		guardBtn:setLabel(CommonText[365])
		guardBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_AIRSHIP_ATTACK or self.m_viewFor == ARMY_SETTING_AIRSHIP_DEFEND then
		local function onSaveCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end
			if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
				Toast.show(CommonText[366][2])
				return
			end

			local armyNum = ArmyMO.getFightArmies()
			if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
				Toast.show(CommonText[1629])
				return
			end

			local fightValueData = TankBO.analyseFormation(formation)
			if self.m_viewFor == ARMY_SETTING_AIRSHIP_ATTACK then
				local teamLeader = AirshipBO.teamLord
				local airshipId = AirshipBO.airshipId

				local canJoin = ArmyMO.checkAirshpState(airshipId)

				if canJoin then
					AirshipBO.JoinAirshipTeam(formation,teamLeader,airshipId)
				else
					Toast.show(CommonText[1107])
				end
			else
				if not AirshipBO.defendId then
					Toast.show(CommonText[1106])
					return
				end
				local defendId = AirshipBO.defendId

				local canJoin = ArmyMO.checkAirshpState(defendId)

				if canJoin then
					AirshipBO.guardAirship(defendId, formation, fightValueData.total)
				else
					Toast.show(CommonText[1108])
				end							
			end
		end
		-- 保存阵型
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local saveBtn = MenuButton.new(normal, selected, nil, onSaveCallback):addTo(container)
		saveBtn:setLabel(CommonText[327])
		saveBtn:setPosition(container:getContentSize().width - 110, 50)	
	elseif self.m_viewFor == ARMY_SETTING_HUNTER then
		local function onSaveCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			print("保存阵型")

			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的

			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			Loading.getInstance():show()

			local function doneFormat()
				Loading.getInstance():unshow()
				Toast.show(CommonText[59])  -- 设置阵型成功
				container.formationView:updateUI(TankMO.getFormationByType(FORMATION_FOR_HUNTER))
			end

			TankBO.asynSetForm(doneFormat, FORMATION_FOR_HUNTER, formation)
		end

		-- 保存阵型
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local saveBtn = MenuButton.new(normal, selected, nil, onSaveCallback):addTo(container)
		saveBtn:setLabel(CommonText[31])
		saveBtn:setPosition(container:getContentSize().width - 110, 50)
		self.saveBtn = saveBtn
	elseif self.m_viewFor == ARMY_SETTING_FOR_CROSS_MILITARY_AREA then -- 跨服军事矿区
		local function onCrossFightCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
				Toast.show(CommonText[366][2])
				return
			end

			local armyNum = ArmyMO.getFightArmies()
			if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
				Toast.show(CommonText[1629])
				return
			end

			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			local power = UserMO.getResource(ITEM_KIND_POWER)
			
			if power < COMBAT_TAKE_POWER then -- 能量不足
				require("app.dialog.BuyPawerDialog").new():push()
				Toast.show(resData.name .. CommonText[223])  -- 能量不足
				return
			end

			local function doneAttack()
				Loading.getInstance():unshow()
			end

			Loading.getInstance():show()
			StaffBO.asynAtkCrossSeniorMine(doneAttack, StaffMO.curCrossAttackPos_.x, StaffMO.curCrossAttackPos_.y, formation, StaffMO.curCrossAttackType_)
		end

		-- 出战
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local fightBtn = MenuButton.new(normal, selected, nil, onCrossFightCallback):addTo(container)
		fightBtn:setLabel(CommonText[18])
		fightBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_PARTYB or self.m_viewFor == ARMY_SETTING_FORTRESS or
		self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK or self.m_viewFor >= ARMY_SETTING_FOR_CROSS then -- 百团混战
		local function onSignCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			local fightValueData = TankBO.analyseFormation(formation)

			Loading.getInstance():show()
			if self.m_viewFor == ARMY_SETTING_FOR_PARTYB then
				PartyBattleBO.asynWarReg(function()
					Loading.getInstance():unshow()
					UiDirector.pop()
					end, formation,fightValueData.total)
			elseif self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK then
				local function callback()
					TankMO.formation_[FORMATION_FORTRESS_ATTACK] = formation
				end
				FortressBO.attackFortress(formation, callback)
			elseif self.m_viewFor == ARMY_SETTING_FORTRESS then
				FortressBO.setBattleForm(nil,formation,fightValueData.total)
			elseif self.m_viewFor == ARMY_SETTING_FOR_CROSSPARTY then
				CrossPartyBO.setFormation(formation,fightValueData.total)
			elseif self.m_viewFor >= ARMY_SETTING_FOR_CROSS then
				CrossBO.setFormation(formation,fightValueData.total,self.m_viewFor)
			else
				Cross.setFormation(formation,fightValueData.total)
			end
		end

		local normal = display.newSprite(IMAGE_COMMON .. 'btn_10_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_10_selected.png')
		local signBtn = MenuButton.new(normal, selected, nil, onSignCallback):addTo(container)
		local label = CommonText[814]
		if self.m_viewFor == ARMY_SETTING_FORTRESS or self.m_viewFor == ARMY_SETTING_CROSS then label = CommonText[19] end
		if self.m_viewFor == ARMY_SETTING_FORTRESS_ATTACK then label = CommonText[313][6] end
		if self.m_viewFor >= ARMY_SETTING_FOR_CROSS then label = CommonText[1] end
		signBtn:setLabel(label)
		signBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_BOSS then -- 世界BOSS
		local function onSaveCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			Loading.getInstance():show()

			local function doneFormat()
				Loading.getInstance():unshow()
				Toast.show(CommonText[59])  -- 设置阵型成功
				container.formationView:updateUI(TankMO.getFormationByType(FORMATION_FOR_BOSS))
			end

			TankBO.asynSetForm(doneFormat, FORMATION_FOR_BOSS, formation)
		end

		-- 保存阵型
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local saveBtn = MenuButton.new(normal, selected, nil, onSaveCallback):addTo(container)
		saveBtn:setLabel(CommonText[31])
		saveBtn:setPosition(container:getContentSize().width - 110, 50)
	elseif self.m_viewFor == ARMY_SETTING_FOR_MILITARY_AREA then -- 军事矿区

		-- local function doneDoCombat(result, atkFormat, defFormat, combatData)
		-- 	UiDirector.pop(function()
		-- 		Loading.getInstance():unshow()
				
		-- 		if CombatMO.curSkipBattle_ then -- 省流量不看战斗
		-- 			local BattleBalanceView = require("app.view.BattleBalanceView")
		-- 			BattleBalanceView.new():push()
		-- 		else
		-- 			BattleMO.reset()
		-- 			BattleMO.setOffensive(CombatMO.curBattleOffensive_)  -- 设置先手
		-- 			BattleMO.setFormat(CombatMO.curBattleAtkFormat_, CombatMO.curBattleDefFormat_)
		-- 			BattleMO.setFightData(CombatMO.curBattleFightData_)

		-- 			if CombatMO.curChoseBattleType_ == COMBAT_TYPE_PARTY_COMBAT then
		-- 				require("app.view.BattleView").new("image/bg/bg_battle.jpg"):push()
		-- 			else
		-- 				require("app.view.BattleView").new():push()
		-- 			end
		-- 		end
		-- 	end)
		-- end

		local function onFightCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			if ArmyMO.getArmyNum() >= VipBO.getArmyCount() then -- 提升VIP，才能执行任务
				Toast.show(CommonText[366][2])
				return
			end

			local armyNum = ArmyMO.getFightArmies()
			if armyNum >= VipMO.queryVip(UserMO.vip_).armyCount then
				Toast.show(CommonText[1629])
				return
			end

			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			local power = UserMO.getResource(ITEM_KIND_POWER)
			
			if power < COMBAT_TAKE_POWER then -- 能量不足
				require("app.dialog.BuyPawerDialog").new():push()
				Toast.show(resData.name .. CommonText[223])  -- 能量不足
				return
			end

			local function doneAttack()
				Loading.getInstance():unshow()
			end

			Loading.getInstance():show()
			StaffBO.asynAtkSeniorMine(doneAttack, StaffMO.curAttackPos_.x, StaffMO.curAttackPos_.y, formation, StaffMO.curAttackType_)

			-- if CombatMO.curChoseBattleType_ == COMBAT_TYPE_EXPLORE then
			-- 	local combatDB = CombatMO.queryExploreById(CombatMO.curChoseBtttleId_)
			-- 	if combatDB.type == EXPLORE_TYPE_EQUIP then
			-- 		local equips = EquipMO.getFreeEquipsAtPos()
			-- 		local remainCount = UserMO.equipWarhouse_ - #equips
			-- 		if remainCount <= 0 then
			-- 			Toast.show(CommonText[711])  -- 仓库已满
			-- 			return
			-- 		end
			-- 	end
			-- end

			-- Loading.getInstance():show()
			-- if CombatMO.curChoseBattleType_ == COMBAT_TYPE_PARTY_COMBAT then
			-- 	gdump(formation,"formationformation")
			-- 	PartyCombatBO.asynDoPartyCombat(doneDoCombat,CombatMO.curChoseBtttleId_,formation)
			-- else
			-- 	CombatBO.asynDoCombat(doneDoCombat, CombatMO.curChoseBattleType_, CombatMO.curChoseBtttleId_, formation)
			-- end
		end

		-- 出战
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local fightBtn = MenuButton.new(normal, selected, nil, onFightCallback):addTo(container)
		fightBtn:setLabel(CommonText[18])
		fightBtn:setPosition(container:getContentSize().width - 110, 50)
	
	elseif self.m_viewFor == ARMY_SETTING_FOR_ALTAR_BOSS then
		local function onSaveCallback(tag, sender)
			ManagerSound.playNormalButtonSound()
			local formation = container.formationView:getFormation()
			formation.commander = self.m_heroId -- 使用最新的
			if not TankBO.hasFightFormation(formation) then
				-- 阵型为空，请设置阵型
				Toast.show(CommonText[193])
				return
			end

			Loading.getInstance():show()

			local function doneFormat()
				Loading.getInstance():unshow()
				Toast.show(CommonText[59])  -- 设置阵型成功
				container.formationView:updateUI(TankMO.getFormationByType(FORMATION_FOR_ALTAR_BOSS))
			end

			TankBO.asynSetForm(doneFormat, FORMATION_FOR_ALTAR_BOSS, formation)
		end

		-- 保存阵型
		local normal = display.newSprite(IMAGE_COMMON .. 'btn_2_normal.png')
		local selected = display.newSprite(IMAGE_COMMON .. 'btn_2_selected.png')
		local saveBtn = MenuButton.new(normal, selected, nil, onSaveCallback):addTo(container)
		saveBtn:setLabel(CommonText[31])
		saveBtn:setPosition(container:getContentSize().width - 110, 50)		
	end
end

function ArmySettingView:updateTactic(formation)
	self.m_tacticForm = formation
	Notify.notify(LOCAL_TACTICS_FORARMY, {formation = formation})
	Notify.notify(LOCAL_TACTICS_UPDATA_ITEM, {formation = formation})
end

function ArmySettingView:showHero(heroId)
	if self.m_heroView then
		self.m_heroView:removeSelf()
		self.m_heroView = nil
	end

	heroId = heroId or 0

	if heroId ~= 0 then
		local hero = HeroMO.getHeroById(heroId)
		if not hero then  -- 已经没有这个英雄了
			heroId = 0
		end
	end

	local itemView = UiUtil.createItemView(ITEM_KIND_HERO, heroId):addTo(self)
	itemView:setScale(0.75)
	itemView:setPosition(122, self:getContentSize().height - 130)
	UiUtil.createItemDetailButton(itemView, nil, nil, function()
			ManagerSound.playNormalButtonSound()

			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
				local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
				return
			end

			if self.m_commanderLocked then
				Toast.show("不可更换将领")
				return
			end

			if self.m_heroId and self.m_heroId > 0 then
				self:showHero(0)  -- 去掉武将
				local container = self

				local formation = container.formationView:getFormation()
				formation.commander = 0 -- 武将被去掉了
				_, formation = TankBO.checkFormation(formation,self.m_viewFor)

				container.formationView:updateUI(formation)

				container.attrView:setFormation(container.formationView:getFormation())
				container.attrView:reloadData()

				self:showBuff(container.formationView:getFormation())
			else
				-- 记录当前的ui名称，以保证选择武将上阵后当前UI是最上层的
				self.m_curUiName = UiDirector.getTopUiName()

				require("app.view.NewSchoolView").new(BUILD_ID_SCHOOL, SCHOOL_VIEW_FOR_FORMAT,self.m_viewFor):push()
			end
		end)
	self.m_heroView = itemView
	if kind == 1 then self.m_heroId = 0 else self.m_heroId = heroId --如果有kind == 1为觉醒将，则heroId置0
	end
end

-- 有武将选中了要上阵
function ArmySettingView:onChoseHero(event)
	if self.m_curUiName and self.m_curUiName ~= "" then
		UiDirector.popMakeUiTop(self.m_curUiName)
		if event.obj.kind == 1 then --如果是觉醒将
			self:showHero(event.obj.hero.heroId)
			local container = self
			local formation = container.formationView:getFormation()
			formation.awakenHero = event.obj.hero --觉醒将的唯一ID
			formation.commander = formation.awakenHero.heroId

			formation = TankBO.formationOnHero(formation,self.m_viewFor)

			container.formationView:updateUI(formation)

			container.attrView:setFormation(container.formationView:getFormation())
			container.attrView:reloadData()

			self:showBuff(container.formationView:getFormation())
		else --如果是普通将领
			self:showHero(event.obj.heroId)

			local container = self
			local formation = container.formationView:getFormation()
			formation.commander = event.obj.heroId -- 有武将选中了
			formation.awakenHero = nil
			formation = TankBO.formationOnHero(formation,self.m_viewFor)

			container.formationView:updateUI(formation)

			container.attrView:setFormation(container.formationView:getFormation())
			container.attrView:reloadData()

			self:showBuff(container.formationView:getFormation())
		end
	end
end

function ArmySettingView:onChoseTactic(event)
	local container = self
	local format = container.formationView:getFormation()
	if event.obj.formation.tacticsKeyId then
		format.tacticsKeyId = event.obj.formation.tacticsKeyId
	end
	container.formationView:updateUI(format)
	container.attrView:setFormation(container.formationView:getFormation())
	container.attrView:reloadData()
	self.m_choseFormIndex = event.obj.formationIndex
end

function ArmySettingView:updateItem(event)
	local format = event.obj.formation
	--战术套装图标
	--战术坦克类型套图标
	if format.tacticsKeyId and #format.tacticsKeyId > 0 then
		local isTacticSuit = TacticsMO.isTacticSuit(format, true) -- 战术类型
		local quality, tankType = TacticsMO.isArmsSuit(format, true)  --兵种类型

		if isTacticSuit then
			local effItem = display.newSprite("image/tactics/tactics_"..isTacticSuit..".png")
			self.m_awardBtn:setTouchSprite(display.newSprite("image/tactics/tactics_"..isTacticSuit..".png"))

			if tankType then
				if self.m_awardBtn.tankItem then 
					self.m_awardBtn.tankItem:removeSelf()
					self.m_awardBtn.tankItem = nil
				end
				self.m_awardBtn.tankItem = display.newSprite("image/tactics/tank_type_"..tankType..".png"):alignTo(self.m_awardBtn, -50, 1)
			else
				if self.m_awardBtn.tankItem then
					self.m_awardBtn.tankItem:setVisible(false)
				end
			end
		else
			self.m_awardBtn:setTouchSprite(display.newSprite("image/tactics/icon_tactics.png"))
			if self.m_awardBtn.tankItem then
				self.m_awardBtn.tankItem:setVisible(false)
			end
		end
	else
		self.m_awardBtn:setTouchSprite(display.newSprite("image/tactics/icon_tactics.png"))
		if self.m_awardBtn.tankItem then
			self.m_awardBtn.tankItem:setVisible(false)
		end
	end
end

function ArmySettingView:showBuff(formation)
	if not self.m_buffNode then
		self.m_buffNode = display.newNode():addTo(self)
	end
	self.m_buffNode:removeAllChildren()

	local groups = {}
	-- local function addGroup(groupId, buffId)
	local function addGroup(buff)
		for index = 1, #groups do
			if groups[index].groupId == buff.groupId then
				if groups[index].value < buff.effectValue then  -- 保存buff值高的
					groups[index].buffId = buff.buffId
					groups[index].value = buff.effectValue
				end
				return
			end
		end
		groups[#groups + 1] = {groupId = buff.groupId, buffId = buff.buffId, value = buff.effectValue}
	end

	for index = 1, FIGHT_FORMATION_POS_NUM do
		local format = formation[index]
		if format.tankId > 0 and format.count > 0 then
			local tankDB = TankMO.queryTankById(format.tankId)
			local aura = {}
			if tankDB.aura then aura = json.decode(tankDB.aura) end

			for index = 1, #aura do
				local buff = BuffMO.queryBuffById(aura[index])
				if buff then
					addGroup(buff)
				end
			end
		end
	end

	local function onBuffCallback(tag, sender)
		local groups = sender.groups
		local DetailBuffDialog = require("app.dialog.DetailBuffDialog")
		DetailBuffDialog.new(groups):push()
	end

	local num = 1
	for index = #groups, 1, -1 do
		local groupId = groups[index].groupId

		if BuffMO.buffMap[groupId] then
			local normal = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
			local selected = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
			local btn = MenuButton.new(normal, selected, nil, onBuffCallback):addTo(self.m_buffNode)
			btn:setScale(0.4)
			btn.groups = groups
			btn:setPosition(self:getContentSize().width - 30 - (num - 1) * 5 - btn:getBoundingBox().size.width * (num - 0.5), self:getContentSize().height - 235)

			local sprite = display.newSprite("image/item/" .. BuffMO.buffMap[groupId] ..".jpg" ):addTo(btn, -1)
			sprite:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

			num = num + 1
		end
	end
end

function ArmySettingView:showUnlock(formationView)
	if not formationView then return end
	gprint("ArmySettingView:showUnlock TankMO.unlockPosition_:", TankMO.unlockPosition_)
	if TankMO.unlockPosition_ > 0 then
		local node = formationView:getFormationNode(TankMO.unlockPosition_)

		TankMO.unlockPosition_ = 0

		armature_add(IMAGE_ANIMATION .. "effect/ui_unlock_1.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_unlock_1.plist", IMAGE_ANIMATION .. "effect/ui_unlock_1.xml")
		local armature = armature_create("ui_unlock_1", node:getContentSize().width / 2, node:getContentSize().height / 2 + 8, function (movementType, movementID, armature)
				if movementType == MovementEventType.COMPLETE then
					armature:removeSelf()
				end
			 end)
		armature:setScale(1.22)
		armature:getAnimation():playWithIndex(0)
		armature:addTo(node, 10)
	end
end

function ArmySettingView:onEquipUpdate(event)
	-- 显示红点提示
	local equips = EquipMO.getFreeEquipsAtPos()
	if #equips > 0 then
		UiUtil.showTip(self.m_equipButton, #equips)
	else
		UiUtil.unshowTip(self.m_equipButton)
	end
end

function ArmySettingView:onPartUpdate(event)
	local parts = PartMO.getFreeParts()
	if #parts > 0 then
		UiUtil.showTip(self.m_partButton, #parts)
	else
		UiUtil.unshowTip(self.m_partButton)
	end
end

function ArmySettingView:onTankUpdate(event)
	local container = self
	local formation = container.formationView:getFormation()
	local ok, _ = TankBO.checkFormation(formation,self.m_viewFor)
	if ok then
	else
		local formation = TankMO.getEmptyFormation()

		container.formationView:updateUI(formation)
		if container and container.attrView then
			container.attrView:setFormation(container.formationView:getFormation())
			container.attrView:reloadData()

			self:showBuff(container.formationView:getFormation())
		end
	end
end

return ArmySettingView