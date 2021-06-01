
local HomeButtonTableView = class("HomeButtonTableView", TableView)

BUTTON_INDEX_COMBAT  = 1 -- 关卡
BUTTON_INDEX_ARMY    = 2 -- 部队
BUTTON_INDEX_TASK    = 3 -- 任务
BUTTON_INDEX_MAIL    = 4 -- 邮件
BUTTON_INDEX_BAG     = 5 -- 背包
BUTTON_INDEX_SOCIAL  = 6 -- 社交
-- BUTTON_INDEX_EFFECT  = 7 -- 增益
BUTTON_INDEX_EQUIP   = 7 -- 装备
BUTTON_INDEX_RANK    = 8 -- 排行
BUTTON_INDEX_SETTING = 9 -- 设置
BUTTON_INDEX_HELP    = 10 -- 帮助
function HomeButtonTableView:ctor(size)
	HomeButtonTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	self.m_cellSize = cc.size(94 * (LOGIN_PLATFORM_PARAM == "mz_appstoreXXX" and BUTTON_INDEX_HELP or BUTTON_INDEX_SETTING), self:getViewSize().height)
	self.m_bounceable = false
end

function HomeButtonTableView:onEnter()
	HomeButtonTableView.super.onEnter(self)
	
	self.m_repairHandler = Notify.register(LOCAL_TANK_REPAIR_EVENT, handler(self, self.onUpdateTip))
	self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onUpdateTip))
	self.m_equipHandler = Notify.register(LOCAL_EQUIP_EVENT, handler(self, self.onUpdateTip))
	self.m_propHandler = Notify.register(LOCAL_PROP_EVENT, handler(self, self.onUpdateTip))
	self.m_taskFinishHandler = Notify.register(LOCAL_TASK_FINISH_EVENT, handler(self, self.onUpdateTip))
	self.m_mailHandler = Notify.register(LOCAL_MAIL_UPDATE_EVENT, handler(self, self.onUpdateTip))
	self.m_blessHandler = Notify.register(LOCAL_BLESS_GET_EVENT, handler(self, self.onUpdateTip))
end

function HomeButtonTableView:onExit()
	HomeButtonTableView.super.onExit(self)
	
	if self.m_repairHandler then
		Notify.unregister(self.m_repairHandler)
		self.m_repairHandler = nil
	end

	if self.m_armyHandler then
		Notify.unregister(self.m_armyHandler)
		self.m_armyHandler = nil
	end

	if self.m_equipHandler then
		Notify.unregister(self.m_equipHandler)
		self.m_equipHandler = nil
	end

	if self.m_propHandler then
		Notify.unregister(self.m_propHandler)
		self.m_propHandler = nil
	end

	if self.m_taskFinishHandler then
		Notify.unregister(self.m_taskFinishHandler)
		self.m_taskFinishHandler = nil
	end

	if self.m_mailHandler then
		Notify.unregister(self.m_mailHandler)
		self.m_mailHandler = nil
	end

	if self.m_blessHandler then
		Notify.unregister(self.m_blessHandler)
		self.m_blessHandler = nil
	end
end

function HomeButtonTableView:numberOfCells()
	return 1
end

function HomeButtonTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HomeButtonTableView:createCellAtIndex(cell, index)
	HomeButtonTableView.super.createCellAtIndex(self, cell, index)

	self.m_buttons = {}

	for index = 1, (LOGIN_PLATFORM_PARAM == "mz_appstoreXXX" and BUTTON_INDEX_HELP or BUTTON_INDEX_SETTING) do
		local sprite = display.newSprite(IMAGE_COMMON .. "btn_position_3_normal.png")
		local btn = CellTouchButton.new(sprite, handler(self, self.onChoseBegan), nil, handler(self, self.onChoseEnded), handler(self, self.onChosenMenu))
		btn.menuIndex = index
		cell:addButton(btn, (index - 0.5) * 94, self.m_cellSize.height / 2)

		local icon = nil
		if index == BUTTON_INDEX_COMBAT then icon = display.newSprite(IMAGE_COMMON .. "btn_combat_icon.png")
		elseif index == BUTTON_INDEX_ARMY then icon = display.newSprite(IMAGE_COMMON .. "btn_army_icon.png")
		elseif index == BUTTON_INDEX_BAG then icon = display.newSprite(IMAGE_COMMON .. "btn_bag_icon.png")
		elseif index == BUTTON_INDEX_SOCIAL then icon = display.newSprite(IMAGE_COMMON .. "btn_social_icon.png")
		elseif index == BUTTON_INDEX_EQUIP then icon = display.newSprite(IMAGE_COMMON .. "btn_equip_icon.png")
		-- elseif index == BUTTON_INDEX_EFFECT then icon = display.newSprite(IMAGE_COMMON .. "btn_effect_icon.png")
		elseif index == BUTTON_INDEX_MAIL then icon = display.newSprite(IMAGE_COMMON .. "btn_mail_icon.png")
		elseif index == BUTTON_INDEX_TASK then icon = display.newSprite(IMAGE_COMMON .. "btn_task_icon.png")
		elseif index == BUTTON_INDEX_RANK then icon = display.newSprite(IMAGE_COMMON .. "btn_rank_icon.png")
		elseif index == BUTTON_INDEX_SETTING then icon = display.newSprite(IMAGE_COMMON .. "btn_setting_icon.png")
		elseif index == BUTTON_INDEX_HELP then icon = display.newSprite(IMAGE_COMMON .. "btn_help_icon.png")
		end
		if icon then
			icon:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
			icon:addTo(btn)
		end

		-- local light = display.newSprite(IMAGE_COMMON .. "info_bg_72.png"):addTo(btn, 2)
		-- light:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height - light:getContentSize().height / 2 - 10)

		self.m_buttons[index] = btn
	end

	self:onUpdateTip()

	return cell
end

function HomeButtonTableView:cellWillRecycle(cell, index)
	-- print("删除cell:", index)
end

function HomeButtonTableView:onChoseBegan(tag, sender)
	HomeBO.NO_OPERATE_FREE_TIMER = 0
	
	if not self.m_choseSprite then
		local chose = display.newSprite(IMAGE_COMMON .. "btn_3_selected.png"):addTo(sender)
		chose:setPosition(sender:getContentSize().width / 2, sender:getContentSize().height / 2)
		self.m_choseSprite = chose
	end

	self.m_choseSprite:retain()
	self.m_choseSprite:removeSelf()
	self.m_choseSprite:addTo(sender)
	self.m_choseSprite:release()
	self.m_choseSprite:setVisible(true)
end

function HomeButtonTableView:onChoseEnded(tag, sender)
	if self.m_choseSprite then
		self.m_choseSprite:setVisible(false)
	end
end

-- 选中了某个雇员
function HomeButtonTableView:onChosenMenu(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- gprint("index:", sender.menuIndex)
	local index = sender.menuIndex
	if index == BUTTON_INDEX_COMBAT then
		CombatMO.curBattleCombatUpdate_ = 0
		CombatMO.curChoseBattleType_ = nil
		CombatMO.curChoseBtttleId_ = nil
		
		if CombatBO.isSectionPass(COMBAT_TYPE_COMBAT, 101) then
			-- 在这里就去拉赏金的关卡信息
			require("app.view.CombatSectionView").new():push()
		else
			require("app.view.CombatLevelView").new(COMBAT_TYPE_COMBAT, 101):push()
		end
	elseif index == BUTTON_INDEX_ARMY then
		require("app.view.ArmyView").new():push()
	elseif index == BUTTON_INDEX_BAG then
		require("app.view.BagView").new():push()
	elseif index == BUTTON_INDEX_EQUIP then
		require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push()
	-- elseif index == BUTTON_INDEX_EFFECT then
	-- 	require("app.view.EffectView").new():push()
	elseif index == BUTTON_INDEX_SOCIAL then
		require("app.view.SocialityView").new():push()
	elseif index == BUTTON_INDEX_MAIL then
		-- MailBO.getMails(function()
		-- 	require("app.view.MailView").new():push()
		-- 	end)
		require("app.view.MailView").new():push()
	elseif index == BUTTON_INDEX_RANK then
		require("app.view.RankView").new():push()
	elseif index == BUTTON_INDEX_SETTING then
		require("app.view.SettingView").new():push()
	elseif index == BUTTON_INDEX_HELP then
		require("app.view.HelpView").new():push()
	elseif index == BUTTON_INDEX_TASK then
		if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then
			require("app.view.TaskView").new():push()
		else
			Loading.getInstance():show()
				TaskBO.asynGetLiveTask(function()
					Loading.getInstance():unshow()
					require("app.view.TaskView").new():push()
					end)
		end
	else
		gprint("fuck:", index)
	end
end

function HomeButtonTableView:onUpdateTip(event)
	local repairTanks = TankMO.getNeedRepairTanks()
	local armies = ArmyMO.getAllArmies()
	local num = 0

	num = #armies + #repairTanks

	if num > 0 then  -- 部队有数字显示
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_ARMY], num, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_ARMY])
	end

	-- 显示红点提示
	local equips = EquipMO.getFreeEquipsAtPos()
	if #equips > 0 then
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_EQUIP], #equips, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_EQUIP])
	end

	local props = PropMO.getAllProps(true)
	if #props > 0 then
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_BAG], #props, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_BAG])
	end

	local finishTasks = TaskBO.getAllFinishTask(TASK_TYPE_MAJOR) + TaskBO.getAllFinishTask(TASK_TYPE_DAYLY) + TaskBO.getAllFinishTask(TASK_TYPE_LIVE)
	if finishTasks > 0 then
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_TASK], finishTasks, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_TASK])
	end

	local newMails = MailBO.getNewMailCount()
	if newMails > 0 then
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_MAIL], newMails, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_MAIL])
	end

	local blessCount = SocialityBO.getBlessCount()
	if blessCount > 0 then
		local tip = UiUtil.showTip(self.m_buttons[BUTTON_INDEX_SOCIAL], blessCount, 70, 70)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_SOCIAL])
	end
end

return HomeButtonTableView
