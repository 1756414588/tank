
-- 主场景中可收缩的显示制造、科技、建筑等按钮

local HomeFuncButtonView = class("HomeFuncButtonView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

BUTTON_STATUS_DRAW_BACK = 1 -- 收缩
BUTTON_STATUS_STRETCH   = 2 -- 伸展

-- BUTTON_INDEX_WORKSHOP  = 1 -- 制作车间
BUTTON_INDEX_SCIENCE   = 1 -- 
BUTTON_INDEX_BUILD     = 2 -- 
BUTTON_INDEX_TANK      = 3 -- 
BUTTON_INDEX_POSITION  = 4 -- 建筑位

function HomeFuncButtonView:ctor()
end

function HomeFuncButtonView:onEnter()
	local normal = display.newSprite(IMAGE_COMMON .. "btn_21_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_21_selected.png")
	btn = MenuButton.new(normal, selected, nil, handler(self, self.onClickCallback)):addTo(self)
	btn:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	self.m_switchButton = btn

	self:setContentSize(btn:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self.m_buttons = {}

	-- -- 制作车间
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_27_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_27_selected.png")
	-- local btn = MenuButton.new(normal, selected, nil, handler(self, self.onWorkshopCallback)):addTo(self, -5)
	-- btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	-- btn:setVisible(false)
	-- btn.index = BUTTON_INDEX_WORKSHOP
	-- self.m_buttons[BUTTON_INDEX_WORKSHOP] = btn

	-- 科技馆
	local normal = display.newSprite(IMAGE_COMMON .. "btn_28_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_28_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onScienceCallback)):addTo(self, -4)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	btn:setVisible(false)
	btn.index = BUTTON_INDEX_SCIENCE
	self.m_buttons[BUTTON_INDEX_SCIENCE] = btn

	-- 建筑升级
	local normal = display.newSprite(IMAGE_COMMON .. "btn_29_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_29_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onBuildCallback)):addTo(self, -3)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	btn:setVisible(false)
	btn.index = BUTTON_INDEX_BUILD
	self.m_buttons[BUTTON_INDEX_BUILD] = btn

	-- 坦克生产
	local normal = display.newSprite(IMAGE_COMMON .. "btn_30_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_30_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onTankCallback)):addTo(self, -2)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	btn:setVisible(false)
	btn.index = BUTTON_INDEX_TANK
	self.m_buttons[BUTTON_INDEX_TANK] = btn

	-- 建筑位
	local normal = display.newSprite(IMAGE_COMMON .. "btn_31_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_31_selected.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onPositionCallback)):addTo(self, -1)
	btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	btn:setVisible(false)
	btn.index = BUTTON_INDEX_POSITION
	self.m_buttons[BUTTON_INDEX_POSITION] = btn

	self.m_isMove = false
	self.m_buttonStatus = BUTTON_STATUS_DRAW_BACK -- 收缩

	self:onUpdateShow()

	self.timerHandler_ = ManagerTimer.addTickListener(handler(self, self.update))

	self.propStartHandler_ = Notify.register(LOCLA_PROP_START_EVENT, handler(self, self.onUpdateShow))
	self.propDoneHandler_ = Notify.register(LOCAL_PROP_DONE_EVENT, handler(self, self.onUpdateShow))
	self.scienceDoneHandler_ = Notify.register(LOCAL_SCIENCE_DONE_EVENT, handler(self, self.onUpdateShow))
	self.buildHandler_ = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onUpdateShow))
	self.tankHandler_ = Notify.register(LOCAL_TANK_EVENT, handler(self, self.onUpdateShow))
	self.tankStartHandler_ = Notify.register(LOCAL_TANK_START_EVENT, handler(self, self.onUpdateShow))
	self.tankDoneHandler_ = Notify.register(LOCAL_TANK_DONE_EVENT, handler(self, self.onUpdateShow))
	self.buildBuyHandler_ = Notify.register(LOCAL_BUY_BUILD_EVENT, handler(self, self.onUpdateShow))
	self.effectHandler_ = Notify.register(LOCAL_EFFECT_EVENT, handler(self, self.onUpdateShow))
end

function HomeFuncButtonView:onExit()
	if self.timerHandler_ then
		ManagerTimer.removeTickListener(self.timerHandler_)
		self.timerHandler_ = nil
	end

	if self.propStartHandler_ then
		Notify.unregister(self.propStartHandler_)
		self.propStartHandler_ = nil
	end
	if self.propDoneHandler_ then
		Notify.unregister(self.propDoneHandler_)
		self.propDoneHandler_ = nil
	end
	if self.scienceDoneHandler_ then
		Notify.unregister(self.scienceDoneHandler_)
		self.scienceDoneHandler_ = nil
	end
	if self.buildHandler_ then
		Notify.unregister(self.buildHandler_)
		self.buildHandler_ = nil
	end
	if self.tankHandler_ then
		Notify.unregister(self.tankHandler_)
		self.tankHandler_ = nil
	end
	if self.tankStartHandler_ then
		Notify.unregister(self.tankStartHandler_)
		self.tankStartHandler_ = nil
	end
	if self.tankDoneHandler_ then
		Notify.unregister(self.tankDoneHandler_)
		self.tankDoneHandler_ = nil
	end
	if self.buildBuyHandler_ then
		Notify.unregister(self.buildBuyHandler_)
		self.buildBuyHandler_ = nil
	end
	if self.effectHandler_ then
		Notify.unregister(self.effectHandler_)
		self.effectHandler_ = nil
	end
end

function HomeFuncButtonView:onClickCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	HomeBO.NO_OPERATE_FREE_TIMER = 0

	if self.m_isMove then return false end

	if self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then
		self.m_buttonStatus = BUTTON_STATUS_STRETCH
	else
		self.m_buttonStatus = BUTTON_STATUS_DRAW_BACK
	end
	self:showButtons()
end

function HomeFuncButtonView:setStatus(buttonStatus)
	if self.m_isMove then return false end
	
	if self.m_buttonStatus ~= buttonStatus then
		self.m_buttonStatus = buttonStatus
		self:showButtons()
	end
end

function HomeFuncButtonView:showButtons()
	if self.m_isMove then return false end

	self.m_isMove = true

	if self.m_buttonStatus == BUTTON_STATUS_STRETCH then  -- 需要伸展开
		for index = 1, #self.m_buttons do
			local button = self.m_buttons[index]
			button:stopAllActions()
			button:setVisible(true)
			button:setEnabled(false)
			button:runAction(transition.sequence({cc.MoveTo:create(0.1 * index, cc.p(self:getContentSize().width / 2, 40 - 80 * index)), cc.CallFuncN:create(function(sender)
					sender:setEnabled(true)
					self:showStatus(sender, true)

					if index == #self.m_buttons then
						self.m_isMove = false
					end
				end)}))
		end
	elseif self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then -- 需要收缩
		for index = 1, #self.m_buttons do
			local button = self.m_buttons[index]
			button:stopAllActions()
			button:setVisible(true)
			button:setEnabled(false)
			button:runAction(transition.sequence({cc.MoveTo:create(0.08 * index, cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2)), cc.CallFuncN:create(function(sender)
					sender:setVisible(false)
					if index == #self.m_buttons then
						self.m_isMove = false
					end
				end)}))

			if button.bg then
				button.bg:runAction(transition.sequence({cc.FadeOut:create(0.03), cc.CallFuncN:create(function(bg)
						bg:getParent().bg = nil
						bg:removeSelf()
					end)}))
			end
		end
	end
end

function HomeFuncButtonView:update(dt)
	if self.m_buttonStatus == BUTTON_STATUS_DRAW_BACK then return end

	-- local products = FactoryBO.orderProduct(BUILD_ID_WORKSHOP)
	-- if #products > 0 then -- 正在生产
	-- 	local leftTime = FactoryBO.getProductTime(BUILD_ID_WORKSHOP, products[1])
	-- 	if self.m_buttons[BUTTON_INDEX_WORKSHOP].bg and self.m_buttons[BUTTON_INDEX_WORKSHOP].bg.timeLabel_ then
	-- 		self.m_buttons[BUTTON_INDEX_WORKSHOP].bg.timeLabel_:setString(UiUtil.strBuildTime(leftTime))
	-- 	end
	-- end

	local products = FactoryBO.orderProduct(BUILD_ID_SCIENCE)
	if #products > 0 then -- 正在生产
		local leftTime = FactoryBO.getProductTime(BUILD_ID_SCIENCE, products[1])
		if self.m_buttons[BUTTON_INDEX_SCIENCE].bg and self.m_buttons[BUTTON_INDEX_SCIENCE].bg.timeLabel_ then
			self.m_buttons[BUTTON_INDEX_SCIENCE].bg.timeLabel_:setString(UiUtil.strBuildTime(leftTime))
		end
	end

	-- local upgradeData = ScienceBO.isUpgrading(ScienceMO.sciences_[1].scienceId)
	-- if upgradeData and self.m_buttons[BUTTON_INDEX_SCIENCE].bg and self.m_buttons[BUTTON_INDEX_SCIENCE].bg.timeLabel_ then
	-- 	local leftTime = FactoryBO.getProductTime(BUILD_ID_SCIENCE, upgradeData[2])
	-- 	self.m_buttons[BUTTON_INDEX_SCIENCE].bg.timeLabel_:setString(UiUtil.strBuildTime(leftTime))
	-- end

	if self.m_buildData and self.m_buildData[1] then -- 建筑升级
		local data = self.m_buildData[1]
		-- dump(data)
		if data.status == BUILD_STATUS_UPGRADE and self.m_buttons[BUTTON_INDEX_BUILD].bg and self.m_buttons[BUTTON_INDEX_BUILD].bg.timeLabel_ then
			local leftTime = 0
			if data.pos == 0 then
				leftTime = BuildMO.getUpgradeLeftTime(data.buildingId)
			else
				leftTime = BuildMO.getWildUpgradeLeftTime(data.pos)
			end
			self.m_buttons[BUTTON_INDEX_BUILD].bg.timeLabel_:setString(UiUtil.strBuildTime(leftTime))
		end
	end

	local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()
	if schedulerId > 0 then
		local leftTime = FactoryBO.getProductTime(buildingId, schedulerId)
		if self.m_buttons[BUTTON_INDEX_TANK].bg and self.m_buttons[BUTTON_INDEX_TANK].bg.timeLabel_ then
			self.m_buttons[BUTTON_INDEX_TANK].bg.timeLabel_:setString(UiUtil.strBuildTime(leftTime))
		end
	end
end

function HomeFuncButtonView:showStatus(button, animate)
	local index = button.index
	if index == BUTTON_INDEX_POSITION then return end

	if button.bg then
		button.bg:removeSelf()
		button.bg = nil
	end

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_41.png"):addTo(button, -1)
	if animate then
		bg:setPosition(-30 - bg:getContentSize().width / 2, button:getContentSize().height / 2)
		bg:runAction(cc.MoveTo:create(0.1, cc.p(60 + bg:getContentSize().width / 2, button:getContentSize().height / 2)))
	else
		bg:setPosition(60 + bg:getContentSize().width / 2, button:getContentSize().height / 2)
	end
	button.bg = bg

	-- if index == BUTTON_INDEX_WORKSHOP then -- 制作车间
	-- 	local products = FactoryBO.orderProduct(BUILD_ID_WORKSHOP)
	-- 	if #products > 0 then -- 正在生产
	-- 		local productData = FactoryBO.getProductData(BUILD_ID_WORKSHOP, products[1])  -- 第一个
	-- 		if productData then
	-- 			local propId = productData.propId
	-- 			local propDB = PropMO.queryPropById(propId)

	-- 			-- 名称和数量
	-- 			local label = ui.newTTFLabel({text = PropMO.getPropName(propId) .. "*" .. productData.count, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	-- 			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 10)

	-- 			local leftTime = FactoryBO.getProductTime(BUILD_ID_WORKSHOP, products[1])
	-- 			local label = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	-- 			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 10)
	-- 			bg.timeLabel_ = label
	-- 		end
	-- 	else
	-- 		-- 空闲
	-- 		local label = ui.newTTFLabel({text = CommonText[352][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	-- 		label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	-- 	end
	-- else

	if index == BUTTON_INDEX_SCIENCE then
		local products = FactoryBO.orderProduct(BUILD_ID_SCIENCE)
		if #products > 0 then -- 正在生产
			local productData = FactoryBO.getProductData(BUILD_ID_SCIENCE, products[1])  -- 第一个
			if productData then
				local scienceId = productData.scienceId

				local scienceDB = ScienceMO.queryScience(scienceId)
				local label = ui.newTTFLabel({text = scienceDB.refineName, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 10)

				local leftTime = FactoryBO.getProductTime(BUILD_ID_SCIENCE, products[1])
				local label = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 10)
				bg.timeLabel_ = label
			end
		else
			-- 空闲
			local label = ui.newTTFLabel({text = CommonText[352][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		end

		-- local upgradeData = ScienceBO.isUpgrading(ScienceMO.sciences_[1].scienceId)
		-- if upgradeData then
		-- 	local scienceDB = ScienceMO.queryScience(ScienceMO.sciences_[1].scienceId)
		-- 	local label = ui.newTTFLabel({text = scienceDB.refineName, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		-- 	label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 10)

		-- 	local leftTime = FactoryBO.getProductTime(BUILD_ID_SCIENCE, upgradeData[2])
		-- 	local label = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		-- 	label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 10)
		-- 	bg.timeLabel_ = label
		-- else
		-- 	-- 空闲
		-- 	local label = ui.newTTFLabel({text = CommonText[352][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
		-- 	label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		-- end
	elseif index == BUTTON_INDEX_BUILD then
		-- local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
		if self.m_upgradeNum <= 0 then  -- 空闲
			local label = ui.newTTFLabel({text = (BuildBO.getUpgradeMaxNum() - 0) .. "/" .. BuildBO.getUpgradeMaxNum(), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		else
			local data = self.m_buildData[1]
			local buildingId = data.buildingId
			local buildDB = BuildMO.queryBuildById(buildingId)

			local label = ui.newTTFLabel({text = buildDB.name, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 10)

			local leftTime = 0
			if data.pos == 0 then
				leftTime = BuildMO.getUpgradeLeftTime(buildingId)
			else
				leftTime = BuildMO.getWildUpgradeLeftTime(data.pos)
			end
			local label = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 10)
			bg.timeLabel_ = label
		end
	elseif index == BUTTON_INDEX_TANK then
		local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()

		if schedulerId == 0 then  -- 两个工厂都是空闲的
			local label = ui.newTTFLabel({text = (position - work) .. "/" .. position, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
			label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
		else
			gprint("HomeFuncButtonView:showStatus:index:", index, "buildingId:", buildingId, "schedulerId:", schedulerId)
			local productData = FactoryBO.getProductData(buildingId, schedulerId)
			-- gdump(productData, "[ArmyProductingTableView] createCellAtIndex")
			if productData then
				local tankId = productData.tankId
				local tankDB = TankMO.queryTankById(tankId)

				-- 名称和数量
				local label = ui.newTTFLabel({text = tankDB.name .. "*" .. productData.count, font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 10)

				local leftTime = FactoryBO.getProductTime(buildingId, schedulerId)
				local label = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_TINY, align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
				label:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 10)
				bg.timeLabel_ = label
			else
				-- error("HomeFuncButtonView:showStatus")
			end
		end
	end
end

function HomeFuncButtonView:onWorkshopCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.WorkshopView").new(BUILD_ID_WORKSHOP):push()
end

function HomeFuncButtonView:onScienceCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local ScienceView = require("app.view.ScienceView")
	ScienceView.new(BUILD_ID_SCIENCE, SCIENCE_FOR_STUDY):push()
end

function HomeFuncButtonView:onBuildCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local BuildingQueueView = require("app.view.BuildingQueueView")
	BuildingQueueView.new(BUILDING_FOR_ALL):push()
end

function HomeFuncButtonView:onTankCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()
	local id = buildingId
	if position == 1 then  -- 有一个开工了，则需要进入另外一个
		if buildingId == BUILD_ID_CHARIOT_A then id = BUILD_ID_CHARIOT_B
		else id = BUILD_ID_CHARIOT_A end
	end
	require("app.view.ChariotInfoView").new(id, CHARIOT_FOR_PRODUCT):push()
end

function HomeFuncButtonView:onPositionCallback(tag, sener)
	ManagerSound.playNormalButtonSound()
	HomeBO.doBuildQueueCount(function() self:setStatus(BUTTON_STATUS_DRAW_BACK) end)
end

function HomeFuncButtonView:onUpdateShow()
	local buildData, upgradeNum = BuildBO.getCanUpgradeBuild(true)
	self.m_buildData = buildData
	self.m_upgradeNum = upgradeNum

	if self.m_buttonStatus ~= BUTTON_STATUS_DRAW_BACK then
		for index = 1, #self.m_buttons do
			self:showStatus(self.m_buttons[index], false)
		end
	end

	self:onUpdateTip()
end

function HomeFuncButtonView:onUpdateTip()
	local totalNum = 0

	-- 制作车间的制造
	-- local products = FactoryBO.orderProduct(BUILD_ID_WORKSHOP)
	-- if #products > 0 then -- 正在生产
	-- 	UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_WORKSHOP])
	-- else
	-- 	totalNum = totalNum + 1
	-- 	UiUtil.showTip(self.m_buttons[BUTTON_INDEX_WORKSHOP], 1, 60, 60)
	-- end

	local products = FactoryBO.orderProduct(BUILD_ID_SCIENCE)
	if #products > 0 then -- 正在生产
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_SCIENCE])
	else  -- 科技馆是空闲的
		totalNum = totalNum + 1
		UiUtil.showTip(self.m_buttons[BUTTON_INDEX_SCIENCE], 1, 60, 60)
	end

	-- local upgradeData = ScienceBO.isUpgrading(ScienceMO.sciences_[1].scienceId)
	-- if upgradeData then  -- 有科技在升级
	-- 	UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_SCIENCE])
	-- else  -- 科技馆是空闲的
	-- 	totalNum = totalNum + 1
	-- 	UiUtil.showTip(self.m_buttons[BUTTON_INDEX_SCIENCE], 1, 60, 60)
	-- end

	if BuildBO.isUpgradeFull() then -- 没有空闲的了
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_BUILD])
	else
		totalNum = totalNum + BuildBO.getUpgradeMaxNum() - self.m_upgradeNum
		UiUtil.showTip(self.m_buttons[BUTTON_INDEX_BUILD], BuildBO.getUpgradeMaxNum() - self.m_upgradeNum, 60, 60)
	end

	-- 坦克的生产
	local work, position, schedulerId, buildingId = BuildBO.getChariotProductInfo()
	if position > 0 then
		totalNum = totalNum + position
		UiUtil.showTip(self.m_buttons[BUTTON_INDEX_TANK], position, 60, 60)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_TANK])
	end

	local buildNum = VipBO.getBuildQueueNum() - UserMO.buildCount_ -- 可以购买建造位
	if buildNum > 0 then
		totalNum = totalNum + buildNum
		UiUtil.showTip(self.m_buttons[BUTTON_INDEX_POSITION], buildNum, 60, 60)
	else
		UiUtil.unshowTip(self.m_buttons[BUTTON_INDEX_POSITION])
	end

	if totalNum > 0 then
		UiUtil.showTip(self.m_switchButton, totalNum, 60, 60)
	else
		UiUtil.unshowTip(self.m_switchButton)
	end
end

return HomeFuncButtonView
