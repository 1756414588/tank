
require("app.text.DetailText")

------------------------------------------------------------------------------
-- 活动TableView
------------------------------------------------------------------------------
local MenuTableView = class("MenuTableView", TableView)

function MenuTableView:ctor(size, viewFor)
	MenuTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

	self.m_cellSize = cc.size(size.width, 80)

	self.m_chosenIndex = 1

	self.m_activityList = ActivityBO.getShowList()

	-- if ActivityBO.isPayFirstOpen() then -- 首充礼包
	-- 	table.insert(self.m_activityList, 1, ActivityBO.getPayFirst())
	-- end

	if GameConfig.enableCode then
		local activity = ActivityBO.getGiftCode()
		self.m_activityList[#self.m_activityList + 1] = activity		
	end

	if viewFor then
		for k, v in pairs(self.m_activityList) do
			if v.activityId == viewFor then
				self.m_chosenIndex = k
				break
			end
		end
	end
end

function MenuTableView:onEnter()
	MenuTableView.super.onEnter(self)

	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.onUpdateTip))
	self.m_levelActivityHandler = Notify.register(LOCAL_ACTIVITY_LEVEL_EVENT, handler(self, self.onLevelActivityUpdate))
end

function MenuTableView:onExit()
	MenuTableView.super.onExit(self)

	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end

	if self.m_levelActivityHandler then
		Notify.unregister(self.m_levelActivityHandler)
		self.m_levelActivityHandler = nil
	end
end

function MenuTableView:numberOfCells()
	return #self.m_activityList
end

function MenuTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MenuTableView:createCellAtIndex(cell, index)
	MenuTableView.super.createCellAtIndex(self, cell, index)

	local activity = self.m_activityList[index]
	cell.activity = activity

	local normal = display.newSprite(IMAGE_COMMON .. "btn_20_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_20_selected.png")
	local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenCallback))
	btn:setLabel(activity.name, {size = FONT_SIZE_SMALL})
	btn.index = index
	cell:addButton(btn, self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	cell.btn = btn

	if self.m_chosenIndex == index then
		btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))

		ActivityBO.addNewConfig(activity.activityId)
	end

	self:showNewTag(btn, activity.activityId) -- 显示活动是否是新开的

	local num = ActivityBO.getUnReceiveNum(activity.activityId)
	if num > 0 then UiUtil.showTip(btn, num)
	else UiUtil.unshowTip(btn) end

	return cell
end

function MenuTableView:showNewTag(btn, activityId)
	local new = ActivityBO.isNew(activityId)
	if new then
		if not btn.newTag then
			btn.newTag = display.newSprite(IMAGE_COMMON .. "label_new.png"):addTo(btn, 4)
			btn.newTag:setPosition(28, 45)
		end
	else
		if btn.newTag then
			btn.newTag:removeSelf()
			btn.newTag = nil
		end
	end
end

function MenuTableView:onChosenCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if sender.index == self.m_chosenIndex then
	else
		local activity = self.m_activityList[sender.index]

		ActivityBO.addNewConfig(activity.activityId)
		self:showNewTag(sender, activity.activityId)

		self:dispatchEvent({name = "CHOSEN_MENU_EVENT", index = sender.index})
	end
end

function MenuTableView:chosenIndex(menuIndex)
	self.m_chosenIndex = menuIndex

	for index = 1, self:numberOfCells() do
		local cell = self:cellAtIndex(index)
		if cell then
			if index == self.m_chosenIndex then
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_selected.png"))
			else
				cell.btn:setNormalSprite(display.newSprite(IMAGE_COMMON .. "btn_20_normal.png"))
			end
		end
	end
end

function MenuTableView:getChosenIndex()
	return self.m_chosenIndex
end

function MenuTableView:getChosenActivity()
	if self.m_chosenIndex <= #self.m_activityList then
		return self.m_activityList[self.m_chosenIndex]
	else
		return nil
	end
end

function MenuTableView:onUpdateTip(event)
	local num = self:numberOfCells()

	for index = 1, num do
		local cell = self:cellAtIndex(index)
		if cell and cell.activity and cell.btn then
			local activity = cell.activity
			local btn = cell.btn

			local num = ActivityBO.getUnReceiveNum(activity.activityId)
			if num > 0 then
				UiUtil.showTip(btn, num)
			else
				UiUtil.unshowTip(btn)
			end
		end
	end

end

function MenuTableView:onLevelActivityUpdate(event)
	self.m_activityList = ActivityMO.getNewActivityList()
	if GameConfig.enableCode then
		local activity = ActivityBO.getGiftCode()
		self.m_activityList[#self.m_activityList + 1] = activity		
	end
	self:reloadData()
	self:dispatchEvent({name = "CHOSEN_MENU_EVENT", index = self.m_chosenIndex})
end

function MenuTableView:updateList()
	local isShow = ActivityMO.isLevelActivityShow()
	if not isShow then
		self.m_activityList = ActivityMO.getNewActivityList()
		if GameConfig.enableCode then
			local activity = ActivityBO.getGiftCode()
			self.m_activityList[#self.m_activityList + 1] = activity		
		end
	end

	self:reloadData()
end

------------------------------------------------------------------------------
-- 活动TableView
------------------------------------------------------------------------------

local ActivityView = class("ActivityView", UiNode)

function ActivityView:ctor(viewChoiceActivityid)
	ActivityView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_viewChoiceActivityid = viewChoiceActivityid
end

function ActivityView:onEnter()
	ActivityView.super.onEnter(self)

	if not ActivityMO.clickView_ then
		ActivityMO.clickView_ = true
		Notify.notify(LOCLA_ACTIVITY_EVENT)
	end

	self:setTitle(CommonText[438])

	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
	self:showUI(container)

	self.m_tickTimer = ManagerTimer.addTickListener(handler(self, self.onTick))
end

function ActivityView:onExit()
	ActivityView.super.onExit(self)

	if self.m_tickTimer then
		ManagerTimer.removeTickListener(self.m_tickTimer)
		self.m_tickTimer = nil
	end	
	-- if self.m_activityHandler then
	-- 	Notify.unregister(self.m_activityHandler)
	-- 	self.m_activityHandler = nil
	-- end

	Notify.notify(LOCAL_UPDATE_TREASURE_LOTTERY_EVENT)
end

-- function ActivityView:onActivityUpdate(event)
-- 	self:showActivity()
-- end

function ActivityView:showUI(container)
	-- 菜单
	local view = MenuTableView.new(cc.size(130, container:getContentSize().height - 180), self.m_viewChoiceActivityid):addTo(container)
	view:addEventListener("CHOSEN_MENU_EVENT", handler(self, self.onChosenMenu))
	view:setPosition(10, -40)
	view:reloadData()
	self.m_menuTablView = view

	--先判断是否有等级礼包的数据
	if not ActivityMO.activityContents_[ACTIVITY_ID_LEVEL_RANK] then
		ActivityBO.asynGetActivityContent(function ()
			self.m_menuTablView:updateList()
		end, ACTIVITY_ID_LEVEL_RANK)
	else
		self.m_menuTablView:updateList()
	end

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	bg:setCapInsets(cc.rect(130, 40, 1, 1))
	bg:setPreferredSize(cc.size(474, container:getContentSize().height - 145))
	bg:setPosition(container:getContentSize().width - bg:getContentSize().width / 2 - 10, bg:getContentSize().height / 2 - 65)

	local node = display.newNode():addTo(bg)
	node:setContentSize(bg:getContentSize())
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	self.m_activityNode = node
	self:performWithDelay(function ()
		self:showActivity()
	end, 0.4)
	
end

function ActivityView:onChosenMenu(event)
	local index = event.index
	self.m_menuTablView:chosenIndex(index)

	self:showActivity()
end

function ActivityView:showActivity()
	-- local index = self.m_menuTablView:getChosenIndex()

	local function show()
		Loading.getInstance():unshow()
		self.m_activityNode:removeAllChildren()
		self.m_activityNode.timerLabel_ = nil

		local activity = self.m_menuTablView:getChosenActivity()
		if not activity then return end

		self:showBarContent(activity)

		self:showActivityContent(activity)
	end

	-- 显示兑换码
	local function showGiftCode()
		Loading.getInstance():unshow()
		self.m_activityNode:removeAllChildren()
		self.m_activityNode.timerLabel_ = nil

		local titleBar = display.newSprite(IMAGE_COMMON .. "activity/bar_gift.jpg"):addTo(self.m_activityNode)
		titleBar:setPosition(self.m_activityNode:getContentSize().width - titleBar:getContentSize().width / 2, self.m_activityNode:getContentSize().height + titleBar:getContentSize().height / 2)

		local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(self.m_activityNode)
		titleBg:setPosition(self.m_activityNode:getContentSize().width / 2, self.m_activityNode:getContentSize().height - 8)

		local title = ui.newTTFLabel({text = CommonText[435][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
		title:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 + 2)

	    local function onEdit(event, editbox)
	        -- if editbox:getText() == CommonText[435][1] then
	        --     editbox:setText("")
	        -- end
	    end

	    local width = 350
	    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

		local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_activityNode)
		inputBg:setPreferredSize(cc.size(width + 20, height + 10))
		inputBg:setPosition(self.m_activityNode:getContentSize().width / 2, self.m_activityNode:getContentSize().height - 130)

	    local inputMsg = ui.newEditBox({x = inputBg:getPositionX(), y = inputBg:getPositionY(), size = cc.size(width, height), listener = onEdit}):addTo(self.m_activityNode)
	    inputMsg:setFontColor(COLOR[11])
	    -- inputMsg:setText(CommonText[435][1]) -- 请输入兑换码
	    inputMsg:setPlaceholderFontColor(COLOR[11])
	    inputMsg:setPlaceHolder(CommonText[435][1])

        local function doneGift(state, awards)
	    	Loading.getInstance():unshow()
	    	UiUtil.showAwards(awards)

	    	if state > 0 then
	    		Toast.show(CommonText[436][state])
	    	else
	    		Toast.show(CommonText[437])  -- 兑换码使用成功
	    	end
	    end

	    local function onGiftCallback(tag, sender)
	    	local code = string.gsub(inputMsg:getText()," ","")
	    	-- if code == CommonText[435][1] then
	    	-- 	inputMsg:setText("")
	    	-- 	return
	    	-- end

	    	if code == "" then
	    		Toast.show(CommonText[355][1])
	    		return
	    	end

	    	local length = string.len(code)
	    	if length ~= 12 then
	    		Toast.show(CommonText[436][4]) -- 兑换码无效
	    		return
	    	end
	    	
	    	Loading.getInstance():show()
	    	UserBO.asynGiftCode(doneGift, code)
		end

	    local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	    local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	    local btn = MenuButton.new(normal, selected, nil, onGiftCallback):addTo(self.m_activityNode)
	    btn:setPosition(self.m_activityNode:getContentSize().width / 2, 100)
	    btn:setLabel(CommonText[589])
	end

	local activity = self.m_menuTablView:getChosenActivity()
	-- gdump(activity, "ActivityView:showActivity")
	if activity.activityId == ACTIVITY_ID_GIFT_CODE then  -- 显示兑换码
		showGiftCode()
	elseif activity.activityId == ACTIVITY_ID_EQUIP or activity.activityId == ACTIVITY_ID_PART or activity.activityId == ACTIVITY_ID_RTURN_DONATE or activity.activityId == ACTIVITY_ID_CARVINAL
		or activity.activityId == ACTIVITY_ID_PAY_FIRST or activity.activityId == ACTIVITY_ID_RES_HARV or activity.activityId == ACTIVITY_ID_HERO_RECRUIT
		or activity.activityId == ACTIVITY_ID_LOTTERY_EQUIP or activity.activityId == ACTIVITY_ID_COMBAT_INTERCEPT or activity.activityId == ACTIVITY_ID_EQUIP_SUPPLY 
		or activity.activityId == ACTIVITY_ID_PART_SUPPLY or activity.activityId == ACTIVITY_ID_SCIENCE_DIS or activity.activityId == ACTIVITY_ID_PARTY_DONATE 
		or activity.activityId == ACTIVITY_ID_MILITARY or activity.activityId == ACTIVITY_ID_ENERGY or activity.activityId == ACTIVITY_ID_COMBAT_INTERCEPT_NEW
		or activity.activityId == ACTIVITY_ID_MILITARY_SUPPLY or activity.activityId == ACTIVITY_ID_ENERGY_SUPPLY or activity.activityId == ACTIVITY_ID_EXPLOR_MEDAL
		or activity.activityId == ACTIVITY_ID_MEDAL_SUPPLY or activity.activityId == ACTIVITY_ID_CASHBACK or activity.activityId == ACTIVITY_ID_CASHBACK_NEW
		or activity.activityId == ACTIVITY_ID_LOGIN_AWARDS or activity.activityId == ACTIVITY_ID_LIMIT_EXPLORE or activity.activityId == ACTIVITY_ID_TACTICS_SSUPPLY
		or activity.activityId == ACTIVITY_ID_TACTICS_EXPLORE or activity.activityId == ACTIVITY_ID_GREAT_ACHIEVEMENT then
		show()
	elseif activity.activityId == ACTIVITY_ID_SECRET_WEAPON or activity.activityId == ACTIVITY_ID_BIGWIG_LEADER 
		or activity.activityId == ACTIVITY_ID_LOTTERY_TREASURE then -- 每次进入都重新拉去协议 (秘密行动活动 or 大咖带队 )
		Loading.getInstance():show()
		ActivityBO.asynGetActivityContent(show, activity.activityId)
	else
		local activityContent = ActivityMO.getActivityContentById(activity.activityId)
		if activityContent and activity.activityId ~= ACTIVITY_ID_ATTACK_NEW then
			show()
		else
			Loading.getInstance():show()
			ActivityBO.asynGetActivityContent(show, activity.activityId)
		end
	end
end

function ActivityView:showActivityContent(activity)
	local activityContent = ActivityMO.getActivityContentById(activity.activityId)

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(self.m_activityNode, 4)
	titleBg:setPosition(self.m_activityNode:getContentSize().width / 2, self.m_activityNode:getContentSize().height - 8)

	local title = ui.newTTFLabel({text = activity.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	title:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 + 2)

	if activity.activityId == ACTIVITY_ID_PARTY_LEVEL or activity.activityId == ACTIVITY_ID_PARTY_FIGHT or activity.activityId == ACTIVITY_ID_FIGHT_RANK
		or activity.activityId == ACTIVITY_ID_HONOUR or activity.activityId == ACTIVITY_ID_COMBAT then  -- 军团等级、军团战力
		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self.m_activityNode)
		line:setPreferredSize(cc.size(self.m_activityNode:getContentSize().width - 10, line:getContentSize().height))
		line:setPosition(self.m_activityNode:getContentSize().width / 2, 120)

		local ActivityTableView = require("app.scroll.ActivityTableView")
		local view = ActivityTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 150), activity.activityId):addTo(self.m_activityNode)
		view:addEventListener("RECEIVE_ACTIVITY_EVENT", handler(self, self.onReceiveActivity))
		view:setPosition(0, 120)
		view:reloadData()

		local label = ui.newTTFLabel({text = CommonText[443] .. ":", font = G_FONT, size = FONT_SIZE_TINY, x = 90, y = 92, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_activityNode)
		if activityContent.state == 0 then
			local value = ui.newTTFLabel({text = CommonText[392], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width / 2, y = label:getPositionY(), color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_activityNode)
			value:setAnchorPoint(cc.p(0, 0.5))
		else
			local value = ui.newTTFLabel({text = activityContent.state, font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width / 2, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_activityNode)
			value:setAnchorPoint(cc.p(0, 0.5))
		end

		local function gotoRank(tag, sender)
			ManagerSound.playNormalButtonSound()
			if activity.activityId == ACTIVITY_ID_HONOUR then
				require("app.view.RankView").new(3):push()
			elseif activity.activityId == ACTIVITY_ID_COMBAT then
				require("app.view.RankView").new(2):push()
			elseif activity.activityId == ACTIVITY_ID_PARTY_FIGHT then 
				local function doneCallback()
					Loading.getInstance():unshow()
					-- 有军团
					if PartyBO.getMyParty() then require("app.view.PartyManageView").new(4):push()
					else require("app.view.AllPartyView").new():push() end
				end
				Loading.getInstance():show()
				PartyBO.asynGetPartyRank(doneCallback, 0, 1)
			elseif activity.activityId == ACTIVITY_ID_PARTY_LEVEL then
				local function doneCallback()
					Loading.getInstance():unshow()
					require("app.view.PartyRankView").new():push()
				end
				Loading.getInstance():show()
				PartyBO.asynGetPartyLvRank(doneCallback, 0)
			else
				require("app.view.RankView").new():push()
			end
		end

		-- 查看排行
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoRank):addTo(self.m_activityNode)
		btn:setPosition(100, 50)
		btn:setLabel(CommonText[440])

		-- 领取
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onReceiveCallback)):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width - 100, 50)
		btn:setLabel(CommonText[255])
		btn.activityId = activity.activityId
		if not activity.open then
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][3])  -- 不可领取
		elseif ActivityBO.hasSingleReceive(activity.activityId) then
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][2])  -- 已经领取了
		elseif not ActivityBO.canSingleReceive(activity.activityId) then
			btn:setEnabled(false)
			btn:setLabel(CommonText[672][3])  -- 不可领取
		end
	elseif activity.activityId == ACTIVITY_ID_EQUIP then -- 装备探险
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[1] do
			local strings = DetailText.activity[1][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoEquip(tag, sender)
			ManagerSound.playNormalButtonSound()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_EQUIP)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoEquip):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_LIMIT_EXPLORE then --极限探险
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[18] do
			local strings = DetailText.activity[18][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoEquip(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ >= 35 then
				local CombatLevelView = require("app.view.CombatExtremeView")
				CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(SECTION_VIEW_FOR_CHALLENGE)):push()
			else
				Toast.show(CommonText[245])
			end
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoEquip):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_CASHBACK then -- 充值返现
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[15] do
			local strings = DetailText.activity[15][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCharge(tag, sender)
			ManagerSound.playNormalButtonSound()
			-- 跳转到充值界面
			-- local RechargeView = require("app.view.RechargeView")
			-- RechargeView.new():push()
			RechargeBO.openRechargeView()
		end

		-- 去充值
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCharge):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[10004])
	elseif activity.activityId == ACTIVITY_ID_CASHBACK_NEW then
		local startY = self.m_activityNode:getContentSize().height - 40
		-- 对activity[16]进行预处理
		local r_first = ActivityMO.getActNewPay2Ratio1(1)
		local r_min, r_max = ActivityMO.getActNewPay2RatioMinMax()
		local formatStrings = DetailText.formatDetailText(DetailText.activity[16], r_first, r_min, r_max)
		for index = 1, #formatStrings do
			local strings = formatStrings[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCharge(tag, sender)
			ManagerSound.playNormalButtonSound()
			RechargeBO.openRechargeView()
		end

		-- 去充值
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCharge):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[10004])
	elseif activity.activityId == ACTIVITY_ID_MILITARY then -- 军工探险
		local startY = self.m_activityNode:getContentSize().height - 40
		local activityTxt = DetailText.militaryAct
		for index = 1, #activityTxt do
			local strings = activityTxt[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoEquip(tag, sender)
			ManagerSound.playNormalButtonSound()

			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_WAR) then
				-- require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
				local exploreType = EXPLORE_TYPE_WAR
				local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
				local section = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), section.name))				
				return 
			end

			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_WAR)):push()
		end


		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoEquip):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])			
	elseif activity.activityId == ACTIVITY_ID_ENERGY then -- 能晶探险
		local startY = self.m_activityNode:getContentSize().height - 40
		local activityTxt = DetailText.energyAct
		for index = 1, #activityTxt do
			local strings = activityTxt[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoEquip(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_ENERGYSPAR) then
				-- require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
				local exploreType = EXPLORE_TYPE_ENERGYSPAR
				local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
				local section = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), section.name))				
				return 
			end			
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_ENERGYSPAR)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoEquip):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])		
	elseif activity.activityId == ACTIVITY_ID_LOTTERY_EQUIP then
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[7] do
			local strings = DetailText.activity[7][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoEquip(tag, sender)
			ManagerSound.playNormalButtonSound()
			self:pop(function() UiDirector.push(require("app.view.LotteryEquipView").new(UI_ENTER_FADE_IN_GATE,LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE)) end)
		end

		-- 抽装备
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoEquip):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[555][1])
	elseif activity.activityId == ACTIVITY_ID_PART then -- 配件探险
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[2] do
			local strings = DetailText.activity[2][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoPart(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_PART) then  -- 等级不足
				local exploreSection = CombatMO.querySectionById(CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART))
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_PART), exploreSection.name))
				return
			end

			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoPart):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_LOGIN_AWARDS then --登录福利
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[17] do
			local strings = DetailText.activity[17][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end
	elseif activity.activityId == ACTIVITY_ID_RTURN_DONATE then
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[3] do
			local strings = DetailText.activity[3][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoParty(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then  -- 判断玩家等级是否开启军团
				local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
				return
			end

			if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then  -- 如果有军团
				Loading.getInstance():show()
				PartyBO.asynGetPartyHall(function()
						Loading.getInstance():unshow()
						require("app.view.PartyHallView").new():push()
					end)
			else
				--打开军团列表
				PartyBO.asynGetPartyRank(function()
						require("app.view.AllPartyView").new():push()
					end, 0, PartyMO.allPartyList_type_)
			end
		end

		-- 军团列表
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoParty):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		-- btn:setLabel(CommonText[442])
		btn:setLabel(CommonText[676][2])  -- 前往
	elseif activity.activityId == ACTIVITY_ID_CARVINAL then -- 全名狂欢
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[4] do
			local strings = DetailText.activity[4][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end
	elseif activity.activityId == ACTIVITY_ID_RESOURCE then
		local ActivityCollectTableView = require("app.scroll.ActivityCollectTableView")
		local view = ActivityCollectTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_PARTY_RECURIT then
		local ActivityPartyRecuritTableView = require("app.scroll.ActivityPartyRecuritTableView")
		local view = ActivityPartyRecuritTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_QUOTA or activity.activityId == ACTIVITY_ID_DAY_BUY or activity.activityId == ACTIVITY_ID_FLASH_META
		or activity.activityId == ACTIVITY_ID_FLASH_SALE or activity.activityId == ACTIVITY_ID_MONTH_SCALE or activity.activityId == ACTIVITY_ID_ENEMY_SALE
		or activity.activityId == ACTIVITY_ID_SPRING_SCALE or activity.activityId == ACTIVITY_ID_CON_SPRING_SCALE then
		local ActivityQuotaTableView = require("app.scroll.ActivityQuotaTableView")
		local view = ActivityQuotaTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_SCIENCE_SPEED or activity.activityId == ACTIVITY_ID_BUILD_SPEED then --科技加速
		local item = display.newSprite("image/item/hero_303.png"):addTo(self.m_activityNode)
		item:setPosition(item:width() / 2 - 10, self.m_activityNode:height() - item:height() / 2 - 10)
		item:setScale(0.6)
		local name = UiUtil.label(CommonText[1825]):alignTo(item, -60, 1)
		local desc = UiUtil.label(CommonText[1823],18,nil,cc.size(180,0),ui.TEXT_ALIGN_LEFT):addTo(self.m_activityNode)
		if activity.activityId == ACTIVITY_ID_BUILD_SPEED then
			desc:setString(CommonText[1832])
		end
		desc:setAnchorPoint(cc.p(0,0.5))
		desc:setPosition(item:x() + item:width() / 2 - 10, self.m_activityNode:height() - 90)
		--前往
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local goBtn = MenuButton.new(normal ,selected, nil, function ()
			if activity.activityId == ACTIVITY_ID_SCIENCE_SPEED then
				require("app.view.ScienceView").new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
			elseif activity.activityId == ACTIVITY_ID_BUILD_SPEED then
				require("app.view.BuildingQueueView").new(BUILDING_FOR_ALL):push()
			end
		end):addTo(self.m_activityNode)
		goBtn:setPosition(self.m_activityNode:width() - 80, self.m_activityNode:height() - 90)
		goBtn:setLabel(CommonText[1822])

		local ActivityQuotaTableView = require("app.scroll.ActivityQuotaTableView")
		local view = ActivityQuotaTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 190), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_PAY_FIRST then  -- 首充礼包
		local ActivityPayFirstView = require("app.view.ActivityPayFirstView")
		local view = ActivityPayFirstView.new(cc.size(467, self.m_activityNode:getContentSize().height)):addTo(self.m_activityNode)
		view:setPosition(view:getContentSize().width / 2, view:getContentSize().height / 2)
	elseif activity.activityId == ACTIVITY_ID_RES_HARV then
		local startY = self.m_activityNode:getContentSize().height - 40
		local awardId =activity.awardId
		local awardData = ActivityMO.queryRechargeHaveById(awardId)
		for index = 1, #DetailText.activity[5] do
			local text = clone(DetailText.activity[5])
			text[2][2].content = string.format(text[2][2].content, awardData.money)
			text[4][2].content = string.format(text[4][2].content, awardData.stone)
			local strings = text[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoRecharge(tag, sender)
			ManagerSound.playNormalButtonSound()
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoRecharge):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[475])  -- 丰收喜悦
	elseif activity.activityId == ACTIVITY_ID_PURPLE_EQP_UP then
		local ActivityPurpEqpUpTableView = require("app.scroll.ActivityPurpEqpUpTableView")
		local view = ActivityPurpEqpUpTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_CRAZY_ARENA then -- 疯狂竞技场
		local ActivityTableView = require("app.scroll.ActivityTableView")
		local view = ActivityTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 130), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 100)
		view:reloadData()

		local function gotoArena(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_ARENA) then
				local build = BuildMO.queryBuildById(BUILD_ID_ARENA)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_ARENA), build.name))
				return
			end
			require("app.view.ArenaView").new():push()
		end

		-- 前往竞技
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoArena):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[471][1])
	elseif activity.activityId == ACTIVITY_ID_CRAZY_UPGRADE then -- 疯狂进化
		local ActivityCondTableView = require("app.scroll.ActivityCondTableView")
		local view = ActivityCondTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 130), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 100)
		view:reloadData()

		local function gotoHero(tag, sender)
			ManagerSound.playNormalButtonSound()
			local buildingId = BUILD_ID_SCHOOL
			if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
				local build = BuildMO.queryBuildById(buildingId)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
				return
			end
			require("app.view.NewSchoolView").new(buildingId):push()
		end

		-- 前往将领
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoHero):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[471][2])
	elseif activity.activityId == ACTIVITY_ID_HERO_RECRUIT then -- 招兵买将
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[6] do
			local strings = DetailText.activity[6][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoHero(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_SCHOOL) then
				local build = BuildMO.queryBuildById(BUILD_ID_SCHOOL)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_SCHOOL), build.name))
				return
			end
			require("app.view.LotteryHeroView").new():push()
		end

		-- 招募武将
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoHero):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[477])
	elseif activity.activityId == ACTIVITY_ID_PART_EVOLVE then  -- 配件
		local ActivityPartEvolveTableView = require("app.scroll.ActivityPartEvolveTableView")
		local view = ActivityPartEvolveTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_CONTU_PAY or activity.activityId == ACTIVITY_ID_PAY_FOUR or activity.activityId == ACTIVITY_ID_CONTU_PAY_NEW then -- 连续充值
		local ActivityContuPayTableView = require("app.scroll.ActivityContuPayTableView")
		local view = ActivityContuPayTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_EQUIP_UP_CRIT then
		local ActivityEquipUpCritTableView = require("app.scroll.ActivityEquipUpCritTableView")
		local view = ActivityEquipUpCritTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_COMBAT_INTERCEPT or activity.activityId == ACTIVITY_ID_COMBAT_INTERCEPT_NEW then
		local startY = self.m_activityNode:getContentSize().height - 40
		local id = activity.activityId == ACTIVITY_ID_COMBAT_INTERCEPT and 8 or 12
		for index = 1, #DetailText.activity[id] do
			local strings = DetailText.activity[id][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			require("app.view.CombatSectionView").new(nil, UI_ENTER_NONE):push()
		end

		-- 去关卡
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[10003])
	elseif activity.activityId == ACTIVITY_ID_EQUIP_SUPPLY then
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[9] do
			local strings = DetailText.activity[9][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_EQUIP)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_MILITARY_SUPPLY then
		local startY = self.m_activityNode:getContentSize().height - 40
		local activityTxt = DetailText.militaryActSupply
		for index = 1, #activityTxt do
			local strings = activityTxt[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_WAR) then
				-- require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
				local exploreType = EXPLORE_TYPE_WAR
				local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
				local section = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), section.name))				
				return 
			end				
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_WAR)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_ENERGY_SUPPLY then
		local startY = self.m_activityNode:getContentSize().height - 40
		local activityTxt = DetailText.energyActSupply
		for index = 1, #activityTxt do
			local strings = activityTxt[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_ENERGYSPAR) then
				-- require("app.view.CombatSectionView").new(SECTION_VIEW_FOR_EXPLORE):push()
				local exploreType = EXPLORE_TYPE_ENERGYSPAR
				local sectionId = CombatMO.getExploreSectionIdByType(exploreType)
				local section = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(exploreType), section.name))
				return 
			end		

			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_ENERGYSPAR)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])				
	elseif activity.activityId == ACTIVITY_ID_FIRST_REBATE then
		local ActivityCondTableView = require("app.scroll.ActivityCondTableView")
		local view = ActivityCondTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 130), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 100)
		view:reloadData()

		-- local ActivityTableView = require("app.scroll.ActivityTableView")
		-- local view = ActivityTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 130), activity.activityId):addTo(self.m_activityNode)
		-- view:setPosition(0, 100)
		-- view:reloadData()

		local function gotoRecharge(tag, sender)
			ManagerSound.playNormalButtonSound()
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		end

		-- 赢取返利
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoRecharge):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[10007])
	elseif activity.activityId == ACTIVITY_ID_VIP_GIFT then
		local ActivityVipQuatoTableView = require("app.scroll.ActivityVipQuatoTableView")
		local view = ActivityVipQuatoTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_PART_SUPPLY then
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[11] do
			local strings = DetailText.activity[11][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()
			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_PART)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_GREAT_ACHIEVEMENT then --战功显赫
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[21] do
			local strings = DetailText.activity[21][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end
	elseif activity.activityId == ACTIVITY_ID_SCIENCE_DIS then
		local startY = self.m_activityNode:getContentSize().height - 40
		for index = 1, #DetailText.activity[10] do
			local strings = DetailText.activity[10][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end
	elseif activity.activityId == ACTIVITY_ID_PARTY_DONATE then
		--判断是否加入军团
		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self.m_activityNode)
			titBg:setAnchorPoint(cc.p(0,0.5))
			titBg:setPosition(20, self.m_activityNode:getContentSize().height - 60)
			local title = ui.newTTFLabel({text = CommonText[889][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = titBg:getContentSize().height / 2}):addTo(titBg)
			local info = ui.newTTFLabel({text = CommonText[890][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = titBg:getPositionY() - titBg:getContentSize().height}):addTo(self.m_activityNode)


			local iconBg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self.m_activityNode)
			iconBg:setPosition(80, info:getPositionY() - 70)
			local icon = display.newSprite("image/item/t_con.jpg"):addTo(iconBg)
			icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
			local nameLab = ui.newTTFLabel({text = CommonText[891][1], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(self.m_activityNode)
			nameLab:setAnchorPoint(cc.p(0.5,0.5))
			nameLab:setPosition(iconBg:getPositionX(),iconBg:getPositionY() - 70)

			local iconBg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self.m_activityNode)
			iconBg:setPosition(220, info:getPositionY() - 70)
			local icon = display.newSprite("image/item/t_food.jpg"):addTo(iconBg)
			icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
			local nameLab = ui.newTTFLabel({text = CommonText[891][2], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(self.m_activityNode)
			nameLab:setAnchorPoint(cc.p(0.5,0.5))
			nameLab:setPosition(iconBg:getPositionX(),iconBg:getPositionY() - 70)


			local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(self.m_activityNode)
			titBg:setAnchorPoint(cc.p(0,0.5))
			titBg:setPosition(20, self.m_activityNode:getContentSize().height - 300)
			local title = ui.newTTFLabel({text = CommonText[889][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 42, y = titBg:getContentSize().height / 2}):addTo(titBg)
			local info = ui.newTTFLabel({text = CommonText[890][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 30, y = titBg:getPositionY() - titBg:getContentSize().height}):addTo(self.m_activityNode)


			local iconBg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self.m_activityNode)
			iconBg:setPosition(80, info:getPositionY() - 70)
			local icon = display.newSprite("image/item/r_fight_exp.jpg"):addTo(iconBg)
			icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
			local nameLab = ui.newTTFLabel({text = CommonText[891][3], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(self.m_activityNode)
			nameLab:setAnchorPoint(cc.p(0.5,0.5))
			nameLab:setPosition(iconBg:getPositionX(),iconBg:getPositionY() - 70)

			local iconBg = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(self.m_activityNode)
			iconBg:setPosition(220, info:getPositionY() - 70)
			local icon = display.newSprite("image/item/t_food.jpg"):addTo(iconBg)
			icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
			local nameLab = ui.newTTFLabel({text = CommonText[891][2], font = G_FONT, size = FONT_SIZE_SMALL}):addTo(self.m_activityNode)
			nameLab:setAnchorPoint(cc.p(0.5,0.5))
			nameLab:setPosition(iconBg:getPositionX(),iconBg:getPositionY() - 70)


			local function gotoRank()
				Loading.getInstance():show()
				ActivityBO.asynGetActPartyDonateRank(function()
					Loading.getInstance():unshow()
					UiDirector.push(require("app.view.ActivityPartyDonateView").new(activity))
					end)
			end
			--查看排行
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local btn = MenuButton.new(normal, selected, disabled, gotoRank):addTo(self.m_activityNode)
			btn:setPosition(self.m_activityNode:getContentSize().width / 2 - 100, 60)
			btn:setLabel(CommonText[443])

			local function gotoDonate()
				self:pop()
				Loading.getInstance():show()
				PartyBO.asynGetParty(function()
						--进入军团场景
						Loading.getInstance():unshow()
						UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_PARTY)
					end, 0)
			end
			--去捐献
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local btn = MenuButton.new(normal, selected, disabled, gotoDonate):addTo(self.m_activityNode)
			btn:setPosition(self.m_activityNode:getContentSize().width / 2 + 100, 60)
			btn:setLabel(CommonText[892])

		else
			local label = ui.newTTFLabel({text = CommonText[421][2], font = G_FONT, size = FONT_SIZE_SMALL, 
				x = 170, y = 125, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_activityNode)
			label:setAnchorPoint(cc.p(0.5, 0.5))
			label:setPosition(self.m_activityNode:getContentSize().width / 2, self.m_activityNode:getContentSize().height / 2)

			local function gotoJoinParty()
				--打开军团列表
				Loading.getInstance():show()
				PartyBO.asynGetPartyRank(function()
					Loading.getInstance():unshow()
					require("app.view.AllPartyView").new():push()
					end, 0, PartyMO.allPartyList_type_)
			end
			--加入军团
			local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local btn = MenuButton.new(normal, selected, disabled, gotoJoinParty):addTo(self.m_activityNode)
			btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
			btn:setLabel(CommonText[836][2])
		end
	elseif activity.activityId == ACTIVITY_ID_REFINE_CRIT then --淬炼暴击活动
		local ActivityEquipUpCritTableView = require("app.scroll.ActivityRefineCritTableView")
		local view = ActivityEquipUpCritTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	elseif activity.activityId == ACTIVITY_ID_EXPLOR_MEDAL or activity.activityId == ACTIVITY_ID_MEDAL_SUPPLY then --勋章探险,勋章补给
		local startY = self.m_activityNode:getContentSize().height - 40

		local detailLab
		if activity.activityId == ACTIVITY_ID_EXPLOR_MEDAL then -- 勋章探险
			detailLab = DetailText.activity[14]
		elseif activity.activityId == ACTIVITY_ID_MEDAL_SUPPLY then -- 勋章补给
			detailLab = DetailText.activity[13]
		end

		for index = 1, #detailLab do
			local strings = detailLab[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()

			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_MEDAL) then  -- 等级不足
				local sectionId = CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_MEDAL)
				local exploreSection = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_MEDAL), exploreSection.name))
				return
			end

			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_MEDAL)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_TACTICS_SSUPPLY or activity.activityId == ACTIVITY_ID_TACTICS_EXPLORE then --战术补给, 战术探险
		local startY = self.m_activityNode:getContentSize().height - 40

		local detailLab
		if activity.activityId == ACTIVITY_ID_TACTICS_SSUPPLY then
			detailLab = DetailText.activity[19]
		elseif activity.activityId == ACTIVITY_ID_TACTICS_EXPLORE then
			detailLab = DetailText.activity[20]
		end
		

		for index = 1, #detailLab do
			local strings = detailLab[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(self.m_activityNode)
			label:setPosition(20, startY)
			startY = startY - label:getHeight()
		end

		local function gotoCombat(tag, sender)
			ManagerSound.playNormalButtonSound()

			if UserMO.level_ < CombatMO.getExploreOpenLv(EXPLORE_TYPE_TACTIC) then  -- 等级不足
				local sectionId = CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_TACTIC)
				local exploreSection = CombatMO.querySectionById(sectionId)
				Toast.show(string.format(CommonText[290], CombatMO.getExploreOpenLv(EXPLORE_TYPE_TACTIC), exploreSection.name))
				return
			end

			local CombatLevelView = require("app.view.CombatLevelView")
			CombatLevelView.new(COMBAT_TYPE_EXPLORE, CombatMO.getExploreSectionIdByType(EXPLORE_TYPE_TACTIC)):push()
		end

		-- 去探险
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local btn = MenuButton.new(normal, selected, disabled, gotoCombat):addTo(self.m_activityNode)
		btn:setPosition(self.m_activityNode:getContentSize().width / 2, 50)
		btn:setLabel(CommonText[441])
	elseif activity.activityId == ACTIVITY_ID_PARTY_LIVES then --军团活跃活动
		local ActivityPartyWarTableView = require("app.scroll.ActivityPartyWarTableView")
		local view = ActivityPartyWarTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:setPosition(0, 30)
		view:reloadData()
	else
		local ActivityTableView = require("app.scroll.ActivityTableView")
		local view = ActivityTableView.new(cc.size(467, self.m_activityNode:getContentSize().height - 60), activity.activityId):addTo(self.m_activityNode)
		view:addEventListener("RECEIVE_ACTIVITY_EVENT", handler(self, self.onReceiveActivity))
		view:setPosition(0, 30)
		view:reloadData()
	end
end

-- 显示活动view顶部的内容
function ActivityView:showBarContent(activity)
	local config = ActivityMO.getConfigById(activity.activityId)
	local title = display.newSprite(IMAGE_COMMON .. "activity/bar_" .. config.bar .. ".jpg"):addTo(self.m_activityNode)
	title:setPosition(self.m_activityNode:getContentSize().width - title:getContentSize().width / 2 + 16, self.m_activityNode:getContentSize().height + title:getContentSize().height / 2)
	local bar = title

	self.m_activityNode.timerLabel_ = nil

	if activity.activityId == ACTIVITY_ID_LEVEL_RANK or activity.activityId == ACTIVITY_ID_PAY_FIRST or activity.activityId == ACTIVITY_ID_VIP_GIFT then
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)
	elseif activity.activityId == ACTIVITY_ID_BIGWIG_LEADER then
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 30, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)

		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 100, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))
		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label
	elseif activity.activityId == ACTIVITY_ID_INVEST or activity.activityId == ACTIVITY_ID_INVEST_NEW then -- 投资计划
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)

		local function gotoRecharge()
			ManagerSound.playNormalButtonSound()
			-- require("app.view.RechargeView").new():push()
			RechargeBO.openRechargeView()
		end

		-- 充值
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_13_selected.png")
		normal:setPreferredSize(cc.size(210, normal:getContentSize().height))
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_13_normal.png")
		selected:setPreferredSize(cc.size(210, selected:getContentSize().height))
		local btn = MenuButton.new(normal, selected, nil, gotoRecharge):addTo(bar)
		btn:setPosition(160, 52)
		btn:setLabel(CommonText[369])

		local function onBuyCallback(tag, sender)
			local function doneBuy()
				Toast.show(CommonText[200])  -- 成功购买
				self:showActivity()
				Notify.notify(LOCLA_ACTIVITY_EVENT)
			end

			local resData = UserMO.getResourceData(ITEM_KIND_COIN)
			local function gotoBuy()
				if UserMO.vip_ < 2 then
					Toast.show("VIP" .. CommonText[113] .. CommonText[199])  -- VIP等级不足
					return
				end

				local count = UserMO.getResource(ITEM_KIND_COIN)
				if count < ACTIVITY_INVEST_TAKE_COIN then
					require("app.dialog.CoinTipDialog").new():push()
					return
				end
				ActivityBO.asynDoInvest(doneBuy, activity.activityId)
			end
		
			if UserMO.consumeConfirm then
				local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
				CoinConfirmDialog.new(string.format(CommonText[457], ACTIVITY_INVEST_TAKE_COIN, resData.name, activity.name), function() gotoBuy() end):push()
			else
				gotoBuy()
			end
		end

		-- 购买
		local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_13_selected.png")
		normal:setPreferredSize(cc.size(210, normal:getContentSize().height))
		normal:setScaleX(-1)
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_13_normal.png")
		selected:setPreferredSize(cc.size(210, selected:getContentSize().height))
		selected:setScaleX(-1)
		local disabled = display.newScale9Sprite(IMAGE_COMMON .. "btn_13_normal.png")
		disabled:setPreferredSize(cc.size(210, disabled:getContentSize().height))
		disabled:setScaleX(-1)
		local btn = MenuButton.new(normal, selected, disabled, onBuyCallback):addTo(bar)
		btn:setPosition(bar:getContentSize().width - 160, 52)
		btn:setLabel(CommonText[119])
		if activity.open then
			local activityContent = ActivityMO.getActivityContentById(activity.activityId)
			if activityContent.state ~= 0 then -- 已参与
				btn:setEnabled(false)
			end
		else
			btn:setEnabled(false)
		end
	elseif activity.activityId == ACTIVITY_ID_PAY_RED_GIFT or activity.activityId == ACTIVITY_ID_PAY_EVERYDAY or activity.activityId == ACTIVITY_ID_DAY_PAY
		or activity.activityId == ACTIVITY_ID_RECHARGE_GIFT or activity.activityId == ACTIVITY_ID_COST_GOLD or activity.activityId == ACTIVITY_ID_CON_COST_GOLD
		or activity.activityId == ACTIVITY_ID_CON_RECHARGE_GIFT or activity.activityId == ACTIVITY_ID_SECRET_WEAPON then -- 充值送红包
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(540, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)

		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		-- local label = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. " - " .. os.date("%Y/%m/%d(%H:%M)", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label

		local activityContent = ActivityMO.getActivityContentById(activity.activityId)

		local pbar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(516, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(516 + 4, 26)}):addTo(bar)
		pbar:setPosition(bar:getContentSize().width / 2, 45)
		local condIndex = ActivityBO.getRechargeConditionIndex(activity.activityId)
		local need = activityContent.conditions[condIndex].cond
		if activity.activityId == ACTIVITY_ID_SECRET_WEAPON then --如果活动ID是秘密行动
			pbar:setLabel(activityContent.cnt .. "/" .. need)
			pbar:setPercent(activityContent.cnt / need)
		else
			pbar:setLabel(activityContent.state .. "/" .. need)
			pbar:setPercent(activityContent.state / need)
		end
		-- pbar:setLabel(activityContent.state .. "/" .. need)
		-- pbar:setPercent(activityContent.state / need)
	elseif activity.activityId == ACTIVITY_ID_POWRE_SUPPLY then 
		local desc = ui.newTTFLabel({text = CommonText[965][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)
		local tab = ui.newTTFLabel({text = CommonText[965][2], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80 , dimensions = cc.size(550, 110), color = COLOR[12],align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_BORDER}):addTo(bar)
	elseif activity.activityId == ACTIVITY_ID_ANNIVERSARY then
		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 55, y = 80, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))
		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label
	elseif activity.activityId == ACTIVITY_ID_LOTTERY_TREASURE then
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80,color = cc.c3b(255, 255, 255), dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)

		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label

		-- 积分
		local sourelb = ui.newTTFLabel({text = CommonText[251] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = bar:width() - 110, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		sourelb:setAnchorPoint(cc.p(1, 0.5))

		local sourenumlb = ui.newTTFLabel({text = ActivityMO.activityContents_[activity.activityId].score, font = G_FONT, size = FONT_SIZE_SMALL, x = sourelb:x(), y = 70, color = COLOR[2],align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		sourenumlb:setAnchorPoint(cc.p(0, 0.5))
	elseif activity.activityId == ACTIVITY_ID_CASHBACK then
		-- 描述
		local startY = 140
		for index = 1, #DetailText.activity[15] do
			local strings = DetailText.activity[15][index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(bar)
			label:setPosition(50, startY)
			startY = startY - label:getHeight()
		end
		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		-- local label = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. " - " .. os.date("%Y/%m/%d(%H:%M)", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label
	elseif activity.activityId == ACTIVITY_ID_CASHBACK_NEW then
		local startY = 140
		local r_first = ActivityMO.getActNewPay2Ratio1(1)
		local r_min, r_max = ActivityMO.getActNewPay2RatioMinMax()
		local formatStrings = DetailText.formatDetailText(DetailText.activity[16], r_first, r_min, r_max)
		for index = 1, #formatStrings do
			local strings = formatStrings[index]
			local label = RichLabel.new(strings, cc.size(430, 0)):addTo(bar)
			label:setPosition(50, startY)
			startY = startY - label:getHeight()
		end
		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		-- local label = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. " - " .. os.date("%Y/%m/%d(%H:%M)", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label
	else
		local desc = ui.newTTFLabel({text = CommonText[439][activity.activityId], font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 80, dimensions = cc.size(550, 110), align = ui.TEXT_ALIGN_LEFT, valign = ui.TEXT_VALIGN_TOP}):addTo(bar)

		-- 时间
		local time = ui.newTTFLabel({text = CommonText[393] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 50, y = 70, align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		time:setAnchorPoint(cc.p(0, 0.5))

		local label = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		-- local label = ui.newTTFLabel({text = os.date("%Y/%m/%d", activity.beginTime) .. " - " .. os.date("%Y/%m/%d(%H:%M)", activity.endTime), font = G_FONT, size = FONT_SIZE_SMALL, x = time:getPositionX() + time:getContentSize().width, y = time:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bar)
		label:setAnchorPoint(cc.p(0, 0.5))
		label.activity = activity
		self.m_activityNode.timerLabel_ = label
	end

	self:onTick(0)
end

function ActivityView:onTick(dt)
	if self.m_activityNode.timerLabel_ and self.m_activityNode.timerLabel_.activity then
		local activity = self.m_activityNode.timerLabel_.activity
		local leftTime = activity.endTime - ManagerTimer.getTime()
		if leftTime <= 0 then leftTime = 0 end

		self.m_activityNode.timerLabel_:setString(UiUtil.strActivityTime(leftTime))
	end
end

function ActivityView:onReceiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local activityId = sender.activityId
	if not activityId or activityId <= 0 then return end

	local activityContent = ActivityMO.getActivityContentById(activityId)

	local receiveCondition = nil
	if activityId == ACTIVITY_ID_PARTY_LEVEL or activityId == ACTIVITY_ID_PARTY_FIGHT or activityId == ACTIVITY_ID_FIGHT_RANK
		or activityId == ACTIVITY_ID_HONOUR or activityId == ACTIVITY_ID_COMBAT then  -- 军团等级、军团战力
		local conditions = activityContent.conditions
		for index = 2, #conditions do
			local condition = conditions[index - 1]
			if activityContent.state <= condition.cond then  -- 达到了条件
				receiveCondition = condition
				break
			end

			local condition = conditions[index]
			if activityContent.state <= condition.cond then  -- 达到了条件
				receiveCondition = condition
				break
			end
		end

		local function doneCallback(awards)
			Loading.getInstance():unshow()
			self:showActivity()
		end

		if receiveCondition then
			gdump(receiveCondition, "ActivityView:onReceiveCallback")
			Loading.getInstance():show()
			ActivityBO.asynReceiveAward(doneCallback, activityId, receiveCondition.keyId)
		else
			Toast.show("未达到领取条件")
		end
	else
	end
end

function ActivityView:onReceiveActivity(event)
	local activity = self.m_menuTablView:getChosenActivity()
	if not activity then return end

	self:showBarContent(activity)
end

function ActivityView:refreshUI(name)
	if name == "WarWeaponView" then
		self:showActivity()
	end
end

return ActivityView
