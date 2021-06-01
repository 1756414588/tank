
-- 基地TableView

local LOCAL_HOME_LIMIT_ITEM_WARWEAPON = 1 -- 战争武器 限制等级显示

local function createBuildNameView(buildName, width)
	local titleBg = display.newNode()
	titleBg:setCascadeOpacityEnabledRecursively(true)

	local normal = nil
	local selected = nil
	-- if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		normal = display.newScale9Sprite("image/screen/a_bg_5.png"):addTo(titleBg)
		selected = display.newScale9Sprite("image/screen/a_bg_6.png"):addTo(titleBg)
	-- else
	-- 	normal = display.newScale9Sprite("image/screen/b_bg_5.png"):addTo(titleBg)
	-- 	selected = display.newScale9Sprite("image/screen/b_bg_6.png"):addTo(titleBg)
	-- end
	titleBg.normal_ = normal
	selected:setVisible(false)
	titleBg.selected_ = selected

	local name = ui.newTTFLabel({text = buildName, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	titleBg.name_ = name

	local length = 0
	if width then length = width
	else length = math.max(name:getContentSize().width + 20, 54) end

	normal:setPreferredSize(cc.size(length, normal:getContentSize().height))
	selected:setPreferredSize(cc.size(length, selected:getContentSize().height))

	return titleBg
end

local function updateBuildNameView(view, buildName, width)
	view.name_:setString(buildName)

	local length = 0
	if width then length = width
	else length = math.max(view.name_:getContentSize().width + 20, 54) end

	view.normal_:setPreferredSize(cc.size(length, view.normal_:getContentSize().height))
	view.selected_:setPreferredSize(cc.size(length, view.selected_:getContentSize().height))
end

local function createBuildLvView(buildLv)
	local lvBg = display.newSprite(IMAGE_COMMON .. "info_bg_55.png")

	-- 显示等级
	local lv = ui.newTTFLabel({text = buildLv, font = G_FONT, size = FONT_SIZE_LIMIT, x = lvBg:getContentSize().width / 2, y = lvBg:getContentSize().height / 2, color = cc.c3b(246, 217, 40), align = ui.TEXT_ALIGN_CENTER}):addTo(lvBg)
	lvBg.level_ = lv
	return lvBg
end

local HomeBaseTableView = class("HomeBaseTableView", TableView)

function HomeBaseTableView:ctor(size)
	-- HomeBaseTableView.super.ctor(self, size, SCROLL_DIRECTION_HORIZONTAL)
	HomeBaseTableView.super.ctor(self, size, SCROLL_DIRECTION_BOTH)

	self.m_size = size

	local left = display.newSprite("image/bg/bg_main_1_1.jpg")
	local right = display.newSprite("image/bg/bg_main_1_2.jpg")

	self.m_cellSize = cc.size(left:getContentSize().width + right:getContentSize().width, size.height)
	-- self.m_cellSize = cc.size(left:getContentSize().width, size.height)
	self.m_cell = nil

	self.m_bounceable = false
	self:setMultiTouchEnabled(true)
end

function HomeBaseTableView:onEnter()
	HomeBaseTableView.super.onEnter(self)
	-- armature_add(IMAGE_ANIMATION .. "effect/guangyun.pvr.ccz", IMAGE_ANIMATION .. "effect/guangyun.plist", IMAGE_ANIMATION .. "effect/guangyun.xml")
	-- require_ex("app.bo.HomeBO")
	-- HomeBO.init()

	self.limitItemList = {}

	function gmCallBack()
		require_ex("app.view.GMToolView").new():push()
	end
	--GM按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_38_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_38_selected.png")
	local gmBtn = MenuButton.new(normal, selected, nil, gmCallBack):addTo(self)
	gmBtn:setPosition(190, self.m_size.height - 165 * GAME_X_SCALE_FACTOR)
	gmBtn:setVisible(GMMO.showToolBtn and UserMO.gm_ ~= 0)


	-- if SecretaryBO.isOpen() then  -- 秘书
	-- 	local SecretaryView = require("app.view.SecretaryView")
	-- 	local view = SecretaryView.new():addTo(self)
	-- 	view:setPosition(50, 440)
	-- end

	-- 功能下拉按钮
	local HomeFuncButtonView = require("app.view.HomeFuncButtonView")
	local view = HomeFuncButtonView.new():addTo(self)
	view:setPosition(40, self.m_size.height - 165 * GAME_X_SCALE_FACTOR - 90)
	self.m_funcButtonView = view

	if RoyaleSurviveMO.isActOpen() and RoyaleSurviveMO.curPhase > 0 then
		function rsCallback()
			-- body
			-- require_ex("app.view.RoyaleSurvivalView").new():push()
			require("app.view.RoyaleBuffShowDialog").new():push()
		end

		local normal = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected.png")
		local hsBtn = MenuButton.new(normal, selected, nil, rsCallback):addTo(self)
		hsBtn:setPosition(120, self.m_size.height - 165 * GAME_X_SCALE_FACTOR - 90)

		local normal1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal_debuff.png")
		local selected1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected_debuff.png")
		local hsBtn1 = MenuButton.new(normal1, selected1, nil, rsCallback):addTo(self)
		hsBtn1:setPosition(120, self.m_size.height - 165 * GAME_X_SCALE_FACTOR - 90)

		local myPos = WorldMO.pos_
		local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
		hsBtn:setVisible(temp)
		hsBtn1:setVisible(not temp)

		self.m_hsBtnBuff = hsBtn
		self.m_hsBtnDebuff = hsBtn1
	end

	self.m_hndSafeAreaUpdate = Notify.register(LOCAL_UPDATE_SAFE_AREA, handler(self, self.onSafeAreaUpdate))

	local HomeAwardButtonView = require("app.view.HomeAwardButtonView")
	local view = HomeAwardButtonView.new():addTo(self)
	view:setPosition(self.m_size.width - 40, 200 * GAME_X_SCALE_FACTOR)
	view:setStatus(BUTTON_STATUS_STRETCH, false)
	self.m_awardButtonView = view

	--活动按钮
	local HomeActivityButtonView = require("app.view.HomeActivityButtonView")
	local view = HomeActivityButtonView.new():addTo(self)
	view:setPosition(self.m_size.width - 35, self.m_size.height - 145 * GAME_X_SCALE_FACTOR)
	self.m_activityButtonView = view

	-- local function gotoShop(tag, sender)
	-- 	require("app.view.BagView").new(BAG_VIEW_FOR_SHOP):push()
	-- end

	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_shop_normal.png")
	-- local shopBtn = ScaleButton.new(normal, gotoShop):addTo(self)
	-- shopBtn:setPosition(self.m_size.width - 130, self.m_awardButtonView:getPositionY())


	-- -- 神秘武器
	-- local function gotoWarWeapon()
	-- 	require("app.view.WarWeaponView").new():push()
	-- end
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_65_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_65_selected.png")
	-- local warWeaponBtn = MenuButton.new(normal, selected, nil, gotoWarWeapon):addTo(self)
	-- warWeaponBtn:setPosition(self.m_size.width - 130, self.m_awardButtonView:getPositionY() + 80)
	-- warWeaponBtn:setVisible(UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) and (TriggerGuideBO.guideIsDone(70) or WarWeaponBO.isHaveSkill()) )
	-- self.limitItemList[LOCAL_HOME_LIMIT_ITEM_WARWEAPON] = warWeaponBtn

	--显示观看拇指广告登录奖励按钮
	if ServiceBO.muzhiAdPlat() and MuzhiADMO.LoginADStatus == 0 then
		self.mzAdLoginBtn = UiUtil.button("mzAdLogin_normal.png","mzAdLogin_selected.png",nil,function()
			--打开界面
			require("app.dialog.PlayAdDialog").new():push()
			end):addTo(self)
		self.mzAdLoginBtn:pos(self.m_size.width - 130, self.m_awardButtonView:getPositionY() + 80)
		--倒计时
		self.mzAdLoginCDLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = self.mzAdLoginBtn:getContentSize().width / 2, y = 10, align = ui.TEXT_ALIGN_CENTER}):addTo(self.mzAdLoginBtn)
		self.mzAdLoginCDLab:setColor(COLOR[12])
		self.mzAdLoginCDLab:setAnchorPoint(cc.p(0.5, 0.5))

		
	-- else
	-- 	if self.mzAdLoginCDLab then
	-- 		self.mzAdLoginCDLab:removeSelf()
	-- 		self.mzAdLoginCDLab = nil
	-- 	end

	-- 	if self.mzAdLoginBtn then
	-- 		self.mzAdLoginBtn:removeSelf()
	-- 		self.mzAdLoginBtn = nil
	-- 	end
	end

	
	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

	self.m_levelHandler = Notify.register(LOCAL_LEVEL_EVENT, handler(self, self.onBuildUpdate))
	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self.m_tankStartHandler = Notify.register(LOCAL_TANK_START_EVENT, handler(self, self.onBuildUpdate))
	self.m_tankDoneHandler = Notify.register(LOCAL_TANK_DONE_EVENT, handler(self, self.onBuildUpdate))
	self.scienceDoneHandler_ = Notify.register(LOCAL_SCIENCE_DONE_EVENT, handler(self, self.onBuildUpdate))
	self.propStartHandler_ = Notify.register(LOCLA_PROP_START_EVENT, handler(self, self.onBuildUpdate))
	self.propDoneHandler_ = Notify.register(LOCAL_PROP_DONE_EVENT, handler(self, self.onBuildUpdate))
	self.m_tankHandler = Notify.register(LOCAL_TANK_EVENT, handler(self, self.onTankUpdate))
	self.m_firstTaskHandler = Notify.register(LOCAL_FIRST_TASK_UPDATE_EVENT, handler(self, self.updateTaskBarView))
	self.m_partyBuildHandler = Notify.register(LOCAL_MYPARTY_UPDATE_EVENT, handler(self, self.onBuildUpdate))
	self.m_arenaHandler = Notify.register(LOCLA_GET_ARENA_EVENT, handler(self, self.onArenaUpdate))

	self.m_goldSpeedHandler =  Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self.lembHandler_ = Notify.register(LOCAL_MATERIAL_LEMB, handler(self, self.onBuildUpdate)) --材料工坊
	self.m_limitHandler = Notify.register(LOCAL_HOME_LIMIT_ITEM, handler(self, self.checkAndShowLimitItem)) --主界面限制性功能图标
	self.m_activeBoxHandler = Notify.register(LOCAL_ACTIVE_BOX, handler(self, self.onBoxUpdate)) --活跃宝箱
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.onActivityUpdate)) --活动刷新

	--更新任务
	self:updateTaskBarView()

	self.homeEnterSchedulerHandler_ = scheduler.performWithDelayGlobal(function()
			self.homeEnterSchedulerHandler_ = nil
			if UiDirector.getTopUiName() == "HomeView" then
				ManagerSound.playSound("base_1")
				Toast.show(CommonText[359][1])

				self:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function() ManagerSound.playSound("base_2") end)}))
			end
		end, 0.1)

	-- 这里主动拉取一下活动是否结束的状态
	-- RoyaleSurviveBO.getHonourStatus()
end

function HomeBaseTableView:onExit()
	HomeBaseTableView.super.onExit(self)
	-- armature_remove(IMAGE_ANIMATION .. "effect/guangyun.pvr.ccz", IMAGE_ANIMATION .. "effect/guangyun.plist", IMAGE_ANIMATION .. "effect/guangyun.xml")
	ManagerTimer.removeTickListener(self.m_tickHandler)

	if self.m_helicopterHandler then
		scheduler.unscheduleGlobal(self.m_helicopterHandler)
		self.m_helicopterHandler = nil
	end

	if self.m_activeBoxHandler then
		scheduler.unscheduleGlobal(self.m_activeBoxHandler)
		self.m_activeBoxHandler = nil
	end

	if self.m_activityHandler then
		scheduler.unscheduleGlobal(self.m_activityHandler)
		self.m_activityHandler = nil
	end
	
	if self.m_noticeScheduler then
		scheduler.unscheduleGlobal(self.m_noticeScheduler)
		self.m_noticeScheduler = nil
	end

	if self.homeEnterSchedulerHandler_ then
		scheduler.unscheduleGlobal(self.homeEnterSchedulerHandler_)
		self.homeEnterSchedulerHandler_ = nil
	end

	if self.m_levelHandler then
		Notify.unregister(self.m_levelHandler)
		self.m_levelHandler = nil
	end
	
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	if self.m_tankStartHandler then
		Notify.unregister(self.m_tankStartHandler)
		self.m_tankStartHandler = nil
	end

	if self.m_tankDoneHandler then
		Notify.unregister(self.m_tankDoneHandler)
		self.m_tankDoneHandler = nil
	end
	if self.m_tankHandler then
		Notify.unregister(self.m_tankHandler)
		self.m_tankHandler = nil
	end
	if self.scienceDoneHandler_ then
		Notify.unregister(self.scienceDoneHandler_)
		self.scienceDoneHandler_ = nil
	end
	if self.propStartHandler_ then
		Notify.unregister(self.propStartHandler_)
		self.propStartHandler_ = nil
	end
	if self.propDoneHandler_ then
		Notify.unregister(self.propDoneHandler_)
		self.propDoneHandler_ = nil
	end
	if self.m_firstTaskHandler then
		Notify.unregister(self.m_firstTaskHandler)
		self.m_firstTaskHandler = nil
	end
	if self.m_partyBuildHandler then
		Notify.unregister(self.m_partyBuildHandler)
		self.m_partyBuildHandler = nil
	end
	if self.m_arenaHandler then
		Notify.unregister(self.m_arenaHandler)
		self.m_arenaHandler = nil
	end
	if self.m_goldSpeedHandler then
		Notify.unregister(self.m_goldSpeedHandler)
		self.m_goldSpeedHandler = nil
	end
	if self.lembHandler_ then
		Notify.unregister(self.lembHandler_)
		self.lembHandler_ = nil
	end
	if self.m_limitHandler then
		Notify.unregister(self.m_limitHandler)
		self.m_limitHandler = nil
	end

	if self.m_helicopterliwuHandler then
		scheduler.unscheduleGlobal(self.m_helicopterliwuHandler)
		self.m_helicopterliwuHandler = nil
	end

	if self.liwu then
		for index = 1, #self.liwu do
			if not tolua.isnull(self.liwu[index]) then
				self.liwu[index]:removeSelf()
			end
		end
	end

	if self.m_hndSafeAreaUpdate then
		Notify.unregister(self.m_hndSafeAreaUpdate)
		self.m_hndSafeAreaUpdate = nil
	end
end

function HomeBaseTableView:onTick(dt)
	for buildingId, buildBtn in pairs(self.m_buidlBtn) do
		local buildStatus = BuildMO.getBuildStatus(buildingId)
		if buildStatus == BUILD_STATUS_UPGRADE then
			local buildLv = BuildMO.getBuildLevel(buildingId)

			local totalTime = BuildMO.getUpgradeTotalTime(buildingId)
			local percent = 1
			if totalTime > 0 then
				local leftTime = BuildMO.getUpgradeLeftTime(buildingId)
				-- gprint("建筑升级的剩余时间", leftTime)
				percent = (totalTime - leftTime) / totalTime
			end
			if buildBtn.upgradeBar then buildBtn.upgradeBar:setPercent(percent) end
		end

		-- 如果在生产，则更新生产剩余时间
		if buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then  -- 战车工厂
			local products = FactoryBO.orderProduct(buildingId)
			if #products > 0 then
				local productTip = buildBtn.productTip
				if productTip and productTip.itemView then
					local productData = FactoryBO.getProductData(buildingId, products[1])
					if productData then  -- 显示生产倒计时
						local leftTime = FactoryBO.getProductTime(buildingId, products[1])
						self:showProducting(productTip.itemView, leftTime, productData.period)
					end
				end
			end
		elseif buildingId == BUILD_ID_SCIENCE then
			local products = FactoryBO.orderProduct(buildingId)
			if #products > 0 then
				local productTip = buildBtn.productTip
				if productTip and productTip.itemView then
					local productData = FactoryBO.getProductData(buildingId, products[1])
					if productData then  -- 显示生产倒计时
						local leftTime = FactoryBO.getProductTime(buildingId, products[1])
						self:showProducting(productTip.itemView, leftTime, productData.period)
					end
				end
			end

			-- local upgradeData = ScienceBO.isUpgrading(ScienceMO.sciences_[1].scienceId)
			-- if upgradeData then  -- 有科技在升级
			-- 	local productTip = buildBtn.productTip
			-- 	if productTip and productTip.itemView then
			-- 		local productData = FactoryBO.getProductData(buildingId, upgradeData[2])
			-- 		if productData then  -- 显示生产倒计时
			-- 			local leftTime = FactoryBO.getProductTime(buildingId, upgradeData[2])
			-- 			self:showProducting(productTip.itemView, leftTime, productData.period)
			-- 		end
			-- 	end
			-- end
		elseif buildingId == BUILD_ID_WORKSHOP then -- 制作车间
			local products = FactoryBO.orderProduct(BUILD_ID_WORKSHOP)
			if #products > 0 then -- 正在生产
				local productTip = buildBtn.productTip
				if productTip and productTip.itemView then
					local productData = FactoryBO.getProductData(buildingId, products[1])
					if productData then  -- 显示生产倒计时
						local leftTime = FactoryBO.getProductTime(buildingId, products[1])
						self:showProducting(productTip.itemView, leftTime, productData.period)
					end
				end
			end
		elseif buildingId == BUILD_ID_REFIT then -- 改装工厂
			local products = FactoryBO.orderProduct(BUILD_ID_REFIT)
			if #products > 0 then
				local productTip = buildBtn.productTip
				if productTip and productTip.itemView then
					local productData = FactoryBO.getProductData(buildingId, products[1])
					if productData then  -- 显示生产倒计时
						local leftTime = FactoryBO.getProductTime(buildingId, products[1])
						self:showProducting(productTip.itemView, leftTime, productData.period)
					end
				end
			end
		elseif  buildingId == BUILD_ID_ARMAMENT then --军备工坊
			if WeaponryBO.buildEquip then
			  	if WeaponryBO.buildEquip.endTime > ManagerTimer.getTime() then
				    --打造中
					local productTip = buildBtn.productTip
					if productTip and productTip.itemView then
						local leftTime = WeaponryBO.buildEquip.endTime - ManagerTimer.getTime()
						self:showProducting(productTip.itemView, leftTime, WeaponryBO.buildEquip.period)
					end

					if productTip and productTip.WeaponryHead then
						productTip.WeaponryHead:removeSelf()
						productTip.WeaponryHead = nil
					end
				else
					-- --可以领取
					-- local productTip = buildBtn.productTip
					-- if productTip and productTip.itemView then
					-- 	local leftTime = 0
					-- 	self:showProducting(productTip.itemView, leftTime, WeaponryBO.buildEquip.period)
					-- end
					local productTip = buildBtn.productTip
					if productTip  and not productTip.WeaponryHead  then 
						local data = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id)			
						local heroHead = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON, data.id):addTo(self.m_cell, productTip:getZOrder())
						heroHead:setScale(0.6)
						heroHead:setAnchorPoint(cc.p(0.5,0))
						heroHead:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
						heroHead:run{
							"rep",
							{
								"seq",
								{"delay",math.random(1,3)},
								{"rotateTo",0,-10},
								{"rotateTo",0.1,10},
								{"rotateTo",0.1,-10},
								{"rotateTo",0.5,0,"ElasticOut"}
							}
						}
						productTip.WeaponryHead = heroHead
					end
				end	
			else
				local productTip = buildBtn.productTip
				if productTip and productTip.itemView then	
					productTip.itemView:setVisible(false)
				end
			end
		end

		if buildingId == BUILD_ID_HARBOUR then  -- 港口(在线奖励)
			self:onOnlineAward()
		end
	end

	if self.mzAdLoginBtn then
		self.mzAdLoginBtn:setVisible(ServiceBO.muzhiAdPlat() and MuzhiADMO.LoginADStatus == 0)
		if self.mzAdLoginCDLab then
			self.mzAdLoginCDLab:setString(MuzhiADMO.get24HourCD())
		end
	end
end

function HomeBaseTableView:onOnlineAward()
	local buildBtn = self.m_buidlBtn[BUILD_ID_HARBOUR]
	if not buildBtn then return end

	if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then
		buildBtn.buildNameView:setVisible(false)
		buildBtn.armature:setVisible(false)

		if buildBtn.armatureBtn then
			buildBtn.armatureBtn:removeSelf()
			buildBtn.armatureBtn = nil
		end
	else
		self:showOnlineAwardBoat()

		if UserMO.getOnlineAwardLeftTime() <= 0 then
			buildBtn.buildNameView:setVisible(false)
			buildBtn.armature:setVisible(true)

			if not buildBtn.armatureBtn then
				local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_2_normal.png")
				normal:setOpacity(0)
				normal:setScale(0.85)
				local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_2_normal.png")
				selected:setOpacity(0)
				selected:setScale(0.85)
				local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenBuild))
				btn.buildingId = BUILD_ID_HARBOUR
				btn:setEnabled(false)  -- 目前的动画位置，导致此按钮可以不使用了
				-- local cell = self:cellAtIndex(1)
				local cell = self.m_cell
				cell:addButton(btn, buildBtn:getPositionX(), buildBtn:getPositionY() + buildBtn:getContentSize().height + btn:getContentSize().height / 2)
				buildBtn.armatureBtn = btn
			end
		else
			buildBtn.armature:setVisible(false)
			buildBtn.buildNameView:setVisible(true)
			buildBtn.buildNameView.name_:setString(UiUtil.strBuildTime(UserMO.getOnlineAwardLeftTime()))

			if buildBtn.armatureBtn then
				buildBtn.armatureBtn:removeSelf()
				buildBtn.armatureBtn = nil
			end
		end
	end
end

function HomeBaseTableView:showOnlineAwardBoat()
	if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then
		if self.m_boatArmature then
			self.m_boatArmature:removeSelf()
			self.m_boatArmature = nil
		end
		return
	end

	local leftTime = UserMO.getOnlineAwardLeftTime()
	if leftTime > 5 then  -- 船还没有出现
		if self.m_boatArmature then
			self.m_boatArmature:removeSelf()
			self.m_boatArmature = nil
		end
		return
	end

	if self.m_boatArmature then return end -- 船已经创建了

	-- local cell = self:cellAtIndex(1)
	local cell = self.m_cell

	armature_add(IMAGE_ANIMATION .. "effect/ui_online_award_boat.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_online_award_boat.plist", IMAGE_ANIMATION .. "effect/ui_online_award_boat.xml")
	local armature = armature_create("ui_online_award_boat", 0, 0):addTo(cell, 10)
	armature:getAnimation():playWithIndex(0)

	if leftTime <= 3 then  -- 直接停在港口
		if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
			armature:setPosition(80, 740 + self.m_offsetY)
		else
			armature:setPosition(110, 880 + self.m_offsetY)
		end
	else
		if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
			armature:setPosition(-30, 690 + self.m_offsetY)
			armature:runAction(transition.sequence({cc.MoveTo:create(leftTime - 0.3, cc.p(70 + 4, 740 + self.m_offsetY + 4)), cc.MoveTo:create(0.3, cc.p(70, 740 + self.m_offsetY))}))
		else
			armature:setPosition(-30, 810 + self.m_offsetY)
			armature:runAction(transition.sequence({cc.MoveTo:create(leftTime - 0.6, cc.p(110 + 4, 880 + self.m_offsetY + 4)), cc.MoveTo:create(0.6, cc.p(110, 880 + self.m_offsetY))}))
		end
	end
	self.m_boatArmature = armature
end

--添加新的参数。进度,优先展示进度的
function HomeBaseTableView:showProducting(parent, leftTime, totalTime,progress)
	local str = ""
	local time = ManagerTimer.time(leftTime)
	totalTime = totalTime or leftTime

	if time.day > 0 then str = ">1d"
	else str = UiUtil.strBuildTime(leftTime, "") end

	-- 显示生产倒计时
	if not parent.timeLabel_ then
		local timeLabel = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_MEDIUM, align = ui.TEXT_ALIGN_CENTER}):addTo(parent, 10)
		timeLabel:setPosition(parent:getContentSize().width / 2, timeLabel:getContentSize().height / 2)
		parent.timeLabel_ = timeLabel
	else
		parent.timeLabel_:setString(str)
	end
	if progress then
		parent.timeLabel_:setVisible(false)
	end
	if not parent.shadeTimer_ then
		local sprite = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
		sprite:setOpacity(160)
		parent.shadeTimer_ = cc.ProgressTimer:create(sprite):addTo(parent, 11)
		parent.shadeTimer_:setType(kCCProgressTimerTypeRadial)
		parent.shadeTimer_:setPosition(parent:getContentSize().width / 2, parent:getContentSize().height / 2)
		parent.shadeTimer_:setReverseProgress(true)
		if progress then
			parent.shadeTimer_:setPercentage(100 - tonumber(progress) * 100)
		else
			parent.shadeTimer_:setPercentage(leftTime / totalTime * 100)
		end
	else
		if progress then
			parent.shadeTimer_:setPercentage(100 - tonumber(progress) * 100)
		else
			parent.shadeTimer_:setPercentage(leftTime / totalTime * 100)
		end
	end
end

function HomeBaseTableView:onResetBuildButton(cell, buildingId)
	if not cell then return self.m_buidlBtn[buildingId] end

	local lv = BuildMO.getBuildLevel(buildingId)

	local buildBtn = self.m_buidlBtn[buildingId]
	if buildBtn then
		if buildBtn.buildLv ~= lv then
			buildBtn:removeSelf()
			self.m_buidlBtn[buildingId] = nil
		else
			return buildBtn
		end
	end

	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_command.xml")

	local config = HomeBO.getBuildConfig(buildingId)

	local x = config.x or 0
	local y = config.y or 0
	local order = config.order or 1

	local build = BuildMO.queryBuildById(config.id)
	if not build then
		gprint("[HomeBaseTableView] build is nil. Error!!! id:", config.id)
	end

	local sprite = UiUtil.createItemSprite(ITEM_KIND_BUILD, config.id)
	local buildBtn = CellTouchButton.new(sprite, handler(self, self.onBuildBegan), nil, handler(self, self.onBuildEnded), handler(self, self.onChosenBuild))
	buildBtn:setAnchorPoint(cc.p(0.5, 0))
	buildBtn.buildingId = config.id
	cell:addButton(buildBtn, x, y + self.m_offsetY, {order = order})

	buildBtn.buildLv = lv

	if buildingId == BUILD_ID_COMMAND then
		local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
		buildBtn.buildNameView = nameView

		local x = config.tx or buildBtn:getContentSize().width / 2
		local y = config.ty or buildBtn:getContentSize().height + 15
		nameView:setPosition(x, y)

		local buildLv = BuildMO.getBuildLevel(config.id)
		if buildLv then  -- 建筑是有等级的
			local lvView = createBuildLvView(buildLv):addTo(buildBtn, 3)
			lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
			buildBtn.buildLvView = lvView
		end

		-- 显示建筑名
		if UserMO.showBuildName then nameView:setOpacity(255) else nameView:setOpacity(0) end

		local x = buildBtn.buildNameView:getPositionX()
		local y = buildBtn.buildNameView:getPositionY() - 18

		-- 每个建筑的升级进度条
		local upgradeBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(buildBtn, 4)
		upgradeBar:setPosition(x, y)
		upgradeBar:setPercent(0)
		upgradeBar:setVisible(false)  -- 初始不可见
		upgradeBar:setScale(0.3)
		buildBtn.upgradeBar = upgradeBar
	end

	local armature = nil
	if buildingId == BUILD_ID_COMMAND then -- 基地
		armature = armature_create("ui_base_command"):addTo(buildBtn)
		if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
			armature:setPosition(66, 75)
		else
			armature:setScaleX(0.8)
			armature:setScaleY(0.92)
			armature:setPosition(55, 72)
		end
	end

	if armature then
		armature:getAnimation():playWithIndex(0)
	end
	buildBtn.armature = armature

	self.m_buidlBtn[buildingId] = buildBtn
	return buildBtn
end

function HomeBaseTableView:onNoticeButton(cell)
	-- local function updateShowAnimation()
	-- 	armature_add(IMAGE_ANIMATION .. "effect/ui_home_notice.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_home_notice.plist", IMAGE_ANIMATION .. "effect/ui_home_notice.xml")

	-- 	local buildBtn = self.m_buidlBtn[BUILD_ID_NOTICE]

	-- 	if buildBtn.buildNameArmature then
	-- 		buildBtn.buildNameArmature:removeSelf()
	-- 		buildBtn.buildNameArmature = nil
	-- 	end

	-- 	local function showLabel(armature)
	-- 		local data = {}

	-- 		for index = 1, #CommonText[473] do
	-- 			local label = ui.newTTFLabel({text = CommonText[473][index], font = G_FONT, size = FONT_SIZE_LIMIT}):addTo(armature)
	-- 			label:setPosition((index - #CommonText[473] / 2 - 0.5) * 16, 0)
	-- 			label:setVisible(false)
	-- 			label.index_ = index
	-- 			armature.labels[index] = label

	-- 			label:runAction(transition.sequence({cc.DelayTime:create(0.2 * index), cc.CallFuncN:create(function(sender) sender:setVisible(true) end)}))
	-- 		end
	-- 		armature:runAction(transition.sequence({cc.DelayTime:create(3), cc.CallFuncN:create(function(sender)
	-- 				for index = 1, #sender.labels do
	-- 					armature.labels[index]:removeSelf()
	-- 				end
	-- 				sender.labels = {}
	-- 				sender:getAnimation():play("end")
	-- 			end)}))
	-- 	end

	-- 	local armature = armature_create("ui_home_notice", buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 20, function (movementType, movementID, armature)
	-- 			-- gprint('movementID:', movementID, "movementType:", movementType)
	-- 			if movementType == MovementEventType.COMPLETE and movementID == "start" then
	-- 				showLabel(armature)
	-- 			elseif movementType == MovementEventType.COMPLETE and movementID == "end" then
	-- 				armature:setVisible(false)
	-- 			end
	-- 		 end):addTo(buildBtn)
	-- 	armature:getAnimation():play("start")
	-- 	armature.labels = {}
	-- 	buildBtn.buildNameArmature = armature
	-- end

	-- if not self.m_noticeScheduler then  -- 定时刷新限时公告标题
	-- 	self.m_noticeScheduler = scheduler.scheduleGlobal(function() updateShowAnimation() end, 20)
	-- end

	local buildBtn = self:onResetBuildButton(cell, BUILD_ID_NOTICE)
	-- updateShowAnimation()
	buildBtn:setVisible(false)
	return buildBtn
end

function HomeBaseTableView:checkAndShowLimitItem()
	for k , v in pairs(self.limitItemList) do
		if k == LOCAL_HOME_LIMIT_ITEM_WARWEAPON then
			if UserMO.queryFuncOpen(UFP_WARWEAPON) and UserMO.level_ >= UserMO.querySystemId(48) then
				v:setVisible(true)
			end
		end
	end
end

function HomeBaseTableView:onBuildUpdate(event)
	local cell = self.m_cell

	for buildingId, buildBtn in pairs(self.m_buidlBtn) do
		if buildingId == BUILD_ID_COMMAND then
			buildBtn = self:onResetBuildButton(self:cellAtIndex(1), buildingId)
		end

		if buildingId == BUILD_ID_PARTY then
			local party = PartyBO.getMyParty()
			if party then -- 有工会，显示名称和等级
				updateBuildNameView(buildBtn.buildNameView, party.partyName)

				buildBtn.buildLvView.level_:setString(party.partyLv)
				buildBtn.buildLvView:setPosition(buildBtn.buildNameView:getPositionX() - buildBtn.buildLvView:getContentSize().width / 2 - buildBtn.buildNameView.normal_:getContentSize().width / 2 + 8, buildBtn.buildNameView:getPositionY())

				buildBtn.partyTag:setVisible(true)
			else
				local build = BuildMO.queryBuildById(buildingId)
				updateBuildNameView(buildBtn.buildNameView, build.name)

				buildBtn.buildLvView.level_:setString(1)
				buildBtn.buildLvView:setPosition(buildBtn.buildNameView:getPositionX() - buildBtn.buildLvView:getContentSize().width / 2 - buildBtn.buildNameView.normal_:getContentSize().width / 2 + 8, buildBtn.buildNameView:getPositionY())

				buildBtn.partyTag:setVisible(false)
			end
		elseif buildingId == BUILD_ID_HARBOUR then  -- 在线奖励
			if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then
				buildBtn.buildNameView:setVisible(false)
				buildBtn.armature:setVisible(false)
			else
				if UserMO.getOnlineAwardLeftTime() <= 0 then
					buildBtn.buildNameView:setVisible(false)
					buildBtn.armature:setVisible(true)
				else
					buildBtn.buildNameView:setVisible(true)
					buildBtn.armature:setVisible(false)
				end
			end
		else
			-- 更新建筑升级进度条
			local buildStatus = BuildMO.getBuildStatus(buildingId)

			if buildBtn.buildLvView then
				local buildLv = BuildMO.getBuildLevel(buildingId)
				buildBtn.buildLvView.level_:setString(buildLv)

				local nxtBuildLevel = BuildMO.queryBuildLevel(buildingId, buildLv + 1)

				if buildLv == 0 and UserMO.level_ >= BuildMO.getOpenLevel(buildingId) and buildStatus == BUILD_STATUS_FREE
					and nxtBuildLevel and nxtBuildLevel.commandLv <= BuildMO.getBuildLevel(BUILD_ID_COMMAND) then  -- 建筑还没有建造，并可以建造
					if not buildBtn.createArmature then
						armature_add(IMAGE_ANIMATION .. "effect/ui_create_building.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_create_building.plist", IMAGE_ANIMATION .. "effect/ui_create_building.xml")
						local armature = armature_create("ui_create_building", buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height):addTo(buildBtn)
						armature:setScale(0.6)
						armature:getAnimation():playWithIndex(0)
						buildBtn.createArmature = armature

						local normal = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_2_normal.png")
						normal:setOpacity(0)
						normal:setScale(0.6)
						local selected = display.newScale9Sprite(IMAGE_COMMON .. "btn_position_2_normal.png")
						selected:setOpacity(0)
						selected:setScale(0.6)
						local btn = CellMenuButton.new(normal, selected, nil, handler(self, self.onChosenBuild))
						btn.buildingId = buildingId
						local cell = self.m_cell
						cell:addButton(btn, buildBtn:getPositionX(), buildBtn:getPositionY() + buildBtn:getContentSize().height + 20)
						buildBtn.createArmatureBtn = btn
					end

					buildBtn.buildNameView:setVisible(false)
					buildBtn.buildLvView:setVisible(false)
				else
					if buildBtn.createArmatureBtn then
						buildBtn.createArmatureBtn:removeSelf()
						buildBtn.createArmatureBtn = nil
					end

					if buildBtn.createArmature then
						buildBtn.createArmature:removeSelf()
						buildBtn.createArmature = nil
					end

					buildBtn.buildNameView:setVisible(true)
					buildBtn.buildLvView:setVisible(true)
				end
			end

			if buildStatus == BUILD_STATUS_FREE then
				if buildBtn.upgradeBar then
					buildBtn.upgradeBar:setVisible(false)
					buildBtn.upgradeBar:setPercent(0)
				end
			elseif buildStatus == BUILD_STATUS_UPGRADE then
				if buildBtn.upgradeBar then
					buildBtn.upgradeBar:setVisible(true)
					buildBtn.upgradeBar:setPercent(0)
				end
			end
		end

		if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then -- 没有开启
			buildBtn:setCascadeOpacityEnabled(true)
			buildBtn:setOpacity(160)
		elseif buildingId == BUILD_ID_AFFAIRE then
			if not StaffMO.isStaffOpen_ and not UserMO.queryFuncOpen(UFP_MILITARY) then
				buildBtn:setCascadeOpacityEnabled(true)
				buildBtn:setOpacity(160)
			else
				buildBtn:setOpacity(255)
			end
		else
			buildBtn:setOpacity(255)
		end
		
		-- 更新建筑生产的图标
		if buildBtn.productTip and buildBtn.productTip.itemView then
			buildBtn.productTip.itemView:removeSelf()
			buildBtn.productTip.itemView = nil
		end
		local productTip = buildBtn.productTip

		if buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then  -- 战车工厂
			local products = FactoryBO.orderProduct(buildingId)
			if #products > 0 then
				productTip:setVisible(true)

				local productData = FactoryBO.getProductData(buildingId, products[1])
				if productData then
					local tankId = productData.tankId
					local itemView = UiUtil.createItemView(ITEM_KIND_TANK, tankId):addTo(cell, productTip:getZOrder())
					itemView:setAnchorPoint(cc.p(0.5, 0))
					itemView:setScale(0.5)
					itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
					productTip.itemView = itemView

					-- 显示生产倒计时
					local leftTime = FactoryBO.getProductTime(buildingId, products[1])
					self:showProducting(itemView, leftTime, productData.period)
				end

				if buildBtn.armature then
					buildBtn.armature:setVisible(true)
				end
			else
				productTip:setVisible(false)
				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
			end
		elseif buildingId == BUILD_ID_SCIENCE then
			local products = FactoryBO.orderProduct(buildingId)
			if #products > 0 then
				productTip:setVisible(true)

				local productData = FactoryBO.getProductData(buildingId, products[1])
				if productData then
					local scienceId = productData.scienceId
					local itemView = UiUtil.createItemView(ITEM_KIND_SCIENCE, scienceId):addTo(cell, productTip:getZOrder())
					itemView:setAnchorPoint(cc.p(0.5, 0))
					itemView:setScale(0.5)
					itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
					productTip.itemView = itemView

					-- 显示生产倒计时
					local leftTime = FactoryBO.getProductTime(buildingId, products[1])
					self:showProducting(itemView, leftTime, productData.period)
				end

				if buildBtn.armature then
					buildBtn.armature:setVisible(true)
				end
			else
				productTip:setVisible(false)

				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
			end
		elseif buildingId == BUILD_ID_WORKSHOP then -- 制作车间
			local products = FactoryBO.orderProduct(BUILD_ID_WORKSHOP)
			if #products > 0 then -- 正在生产
				productTip:setVisible(true)

				local productData = FactoryBO.getProductData(BUILD_ID_WORKSHOP, products[1])  -- 第一个
				if productData then
					local propId = productData.propId

					local itemView = UiUtil.createItemView(ITEM_KIND_PROP, propId):addTo(cell, productTip:getZOrder())
					itemView:setAnchorPoint(cc.p(0.5, 0))
					itemView:setScale(0.5)
					itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
					productTip.itemView = itemView

					-- 显示生产倒计时
					local leftTime = FactoryBO.getProductTime(buildingId, products[1])
					self:showProducting(itemView, leftTime, productData.period)
				end

				if buildBtn.armature then
					buildBtn.armature:setVisible(true)
				end
			else
				productTip:setVisible(false)
				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
			end
		elseif buildingId == BUILD_ID_REFIT then -- 改装工厂
			local products = FactoryBO.orderProduct(BUILD_ID_REFIT)
			if #products > 0 then
				productTip:setVisible(true)

				local productData = FactoryBO.getProductData(BUILD_ID_REFIT, products[1])  -- 第一个
				if productData then
					local tankId = productData.refitId

					local itemView = UiUtil.createItemView(ITEM_KIND_TANK, tankId):addTo(cell, productTip:getZOrder())
					itemView:setAnchorPoint(cc.p(0.5, 0))
					itemView:setScale(0.5)
					itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
					productTip.itemView = itemView

					-- 显示生产倒计时
					local leftTime = FactoryBO.getProductTime(buildingId, products[1])
					self:showProducting(itemView, leftTime, productData.period)
				end

				if buildBtn.armature then
					buildBtn.armature:setVisible(true)
				end
			else
				productTip:setVisible(false)
				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
			end
		elseif buildingId == BUILD_ID_ARMAMENT then --军备工坊
			if WeaponryBO.buildEquip then
				productTip:setVisible(true)

				if WeaponryBO.buildEquip.endTime  > ManagerTimer.getTime()  then
					if not productTip.itemView then
						local data = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id)
						local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON, data.id):addTo(cell, productTip:getZOrder())
						itemView:setAnchorPoint(cc.p(0.5, 0))
						itemView:setScale(0.5)
						itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
						productTip.itemView = itemView
					end
					-- 显示生产倒计时
					local leftTime = WeaponryBO.buildEquip.endTime - ManagerTimer.getTime()
					self:showProducting(productTip.itemView, leftTime, WeaponryBO.buildEquip.period)
					if buildBtn.armature then
						buildBtn.armature:setVisible(true)
					end

					if productTip and productTip.WeaponryHead then
						productTip.WeaponryHead:removeSelf()
						productTip.WeaponryHead = nil
					end
				else
					--领奖
					-- if productTip and (not productTip.itemView) then
					-- 	local data = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id)
					-- 	local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON, data.id):addTo(cell, productTip:getZOrder())
					-- 	itemView:setAnchorPoint(cc.p(0.5, 0))
					-- 	itemView:setScale(0.5)
					-- 	itemView:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
					-- 	productTip.itemView = itemView
					-- end
					-- local leftTime = 0
					-- self:showProducting(productTip.itemView, leftTime, WeaponryBO.buildEquip.period)
					-- if buildBtn.armature then
					-- 	buildBtn.armature:setVisible(true)
					-- end
					if buildBtn.armature then
						buildBtn.armature:setVisible(true)
					end
					--if WeaponryBO.buildEquip.endTime  > ManagerTimer.getTime()  then
					if productTip and not productTip.WeaponryHead  then
						local data = WeaponryMO.queryById(WeaponryBO.buildEquip.equip_id)			
						local heroHead = UiUtil.createItemView(ITEM_KIND_WEAPONRY_ICON, data.id):addTo(cell, productTip:getZOrder())
						heroHead:setScale(0.6)
						heroHead:setAnchorPoint(cc.p(0.5,0))
						heroHead:setPosition(productTip:getPositionX(), productTip:getPositionY() + productTip:getContentSize().height - 4)
						heroHead:run{
							"rep",
							{
								"seq",
								{"delay",math.random(1,3)},
								{"rotateTo",0,-10},
								{"rotateTo",0.1,10},
								{"rotateTo",0.1,-10},
								{"rotateTo",0.5,0,"ElasticOut"}
							}
						}
						productTip.WeaponryHead = heroHead
					end
				end
			else
				productTip:setVisible(false)
				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
				if productTip.WeaponryHead then
					productTip.WeaponryHead:removeSelf()
					productTip.WeaponryHead = nil
				end
			end
		elseif buildingId == BUILD_ID_MATERIAL_WORKSHOP then --材料工坊
			local lemb = WeaponryBO.MaterialQueue
			if lemb and #lemb > 0 then
				productTip:setVisible(true)
				if lemb[1].complete < lemb[1].period then
					if not productTip.itemView then
						local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER, lemb[1].pid):addTo(cell, productTip:getZOrder())
						itemView:setAnchorPoint(cc.p(0.5, 0))
						itemView:setScale(0.5)
						itemView:setPosition(productTip:getPositionX() - 10, productTip:getPositionY() + productTip:getContentSize().height - 4)
						productTip.itemView = itemView
					end
					-- 显示生产倒计时
					local leftTime = lemb[1].endTime - ManagerTimer.getTime()
					local progress = string.format("%.2f", lemb[1].complete / lemb[1].period)
					self:showProducting(productTip.itemView, leftTime, lemb[1].endTime,progress)
					if buildBtn.armature then
						buildBtn.armature:setVisible(true)
					end
				else
					--显示可领取
					if productTip and (not productTip.itemView) then
						local itemView = UiUtil.createItemView(ITEM_KIND_WEAPONRY_PAPER, lemb[1].pid):addTo(cell, productTip:getZOrder())
						itemView:setAnchorPoint(cc.p(0.5, 0))
						itemView:setScale(0.5)
						itemView:setPosition(productTip:getPositionX() - 10, productTip:getPositionY() + productTip:getContentSize().height - 4)
						productTip.itemView = itemView
						UiUtil.createItemDetailButton(itemView,nil,nil,handler(self,self.awardMaterial))
						itemView:run{
							"rep",
							{
								"seq",
								{"delay",math.random(1,3)},
								{"rotateTo",0,-10},
								{"rotateTo",0.1,10},
								{"rotateTo",0.1,-10},
								{"rotateTo",0.5,0,"ElasticOut"}
							}
						}
					end
				end
			else
				productTip:setVisible(false)
				if buildBtn.armature then
					buildBtn.armature:setVisible(false)
				end
			end
		end
	end
	self.m_awardButtonView:showMedalState()
	self:onTick(0)
	-- scheduler.performWithDelayGlobal(function() self:onTick(0) end, 0.01)
end

--活跃宝箱
function HomeBaseTableView:onBoxUpdate(event)
	if self.m_boxBtn then
		self.m_boxBtn:setVisible(true)
	end
end

function HomeBaseTableView:onActivityUpdate(event)
	if not ActivityBO.isValid(ACTIVITY_ID_LOGIN_AWARDS) then
		if self.m_airshipBtn then
			self.m_airshipBtn:setVisible(true)
			self.m_airshipBtn:removeSelf()
			self.m_airshipBtn = nil
		end
	else
		if not tolua.isnull(self) then
			self:showLoginActivity(self.m_cell)
		end
	end
end

function HomeBaseTableView:onArenaUpdate(event)
	local buildBtn = self.m_buidlBtn[BUILD_ID_ARENA]
	if buildBtn then
		updateBuildNameView(buildBtn.buildNameView, ArenaMO.champion_, 115)
	end
end

function HomeBaseTableView:onTankUpdate(event)
	self:putAllTanks(self:cellAtIndex(1))
end

function HomeBaseTableView:numberOfCells()
	return 1
end

function HomeBaseTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

--领取材料工坊材料
function HomeBaseTableView:awardMaterial()
	MaterialBO.awardMaterial(function (data)
		local awards = PbProtocol.decodeRecord(data["award"])
		local record = {}
		record[#record + 1] = awards
		if record then
			local statsAward = CombatBO.addAwards(record)
			UiUtil.showAwards(statsAward)
		end
	end,1)
end

function HomeBaseTableView:createCellAtIndex(cell, index)
	HomeBaseTableView.super.createCellAtIndex(self, cell, index)

	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_arena.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_chariot.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_equip.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_party.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_refit.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_school.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_science.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_part.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_online_award.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_online_award.plist", IMAGE_ANIMATION .. "effect/ui_online_award.xml")
	armature_add(IMAGE_ANIMATION .. "effect/zzsys_zc.pvr.ccz", IMAGE_ANIMATION .. "effect/zzsys_zc.plist", IMAGE_ANIMATION .. "effect/zzsys_zc.xml")
	--三周年庆动画
	-- armature_add(IMAGE_ANIMATION .. "effect/lihua.pvr.ccz", IMAGE_ANIMATION .. "effect/lihua.plist", IMAGE_ANIMATION .. "effect/lihua.xml")
	-- armature_add(IMAGE_ANIMATION .. "effect/qiqiu_3.pvr.ccz", IMAGE_ANIMATION .. "effect/qiqiu_3.plist", IMAGE_ANIMATION .. "effect/qiqiu_3.xml")
	-- armature_add(IMAGE_ANIMATION .. "effect/szn_paomadeng.pvr.ccz", IMAGE_ANIMATION .. "effect/szn_paomadeng.plist", IMAGE_ANIMATION .. "effect/szn_paomadeng.xml")

	self.m_cell = cell

	local bgLeft = display.newSprite("image/bg/bg_main_1_1.jpg"):addTo(cell)
	-- local armature = armature_create("guangyun", 60, bgLeft:height()-120):addTo(bgLeft)
	-- armature:getAnimation():playWithIndex(0)
	local bgRight = display.newSprite("image/bg/bg_main_1_2.jpg"):addTo(cell)

	local offsetY = (self.m_cellSize.height - bgLeft:getContentSize().height) / 2
	self.m_offsetY = offsetY
	
	bgLeft:setPosition(bgLeft:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)
	bgRight:setPosition(bgLeft:getContentSize().width + bgRight:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)


	--位置全部手动校对
	-- local roll = armature_create("szn_paomadeng"):addTo(cell,990)
	-- roll:setPosition(551, self.m_offsetY + 712)
	-- roll:getAnimation():playWithIndex(0)


	--小气球顺序为，从三周年跑马的左上开始。第一个为1.逆时针顺序
	-- for smallNum=1,#HomeBallonsAnimationConfig do
	-- 	local qiqiu3_smallNum = armature_create("qiqiu_3"):addTo(cell,990)
	-- 	qiqiu3_smallNum:setPosition(HomeBallonsAnimationConfig[smallNum].x, self.m_offsetY + HomeBallonsAnimationConfig[smallNum].y)
	-- 	qiqiu3_smallNum:getAnimation():playWithIndex(0)
	-- end

	--礼花
	-- for lihuaNum=1,#HomeFireworksConfig do
	-- 	local lihua = armature_create("lihua", nil,nil, function (movementType, movementID, armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			armature:getAnimation():play("start")
	-- 		end
	-- 	end):addTo(cell,990)
	-- 	lihua:setPosition(HomeFireworksConfig[lihuaNum].x, self.m_offsetY + HomeFireworksConfig[lihuaNum].y)
	-- 	lihua:runAction(cc.RepeatForever:create(transition.sequence({cc.DelayTime:create(5), cc.CallFuncN:create(function(sender) sender:getAnimation():play("fei") end)})))
	-- end

	--静态气球
	-- for ballons1Index=1,#HomeBallons1Config do
	-- 	local ballon = display.newSprite(IMAGE_COMMON .. "ballon_1.png"):addTo(cell,10)
	-- 	ballon:setPosition(HomeBallons1Config[ballons1Index].x, self.m_offsetY + HomeBallons1Config[ballons1Index].y)
	-- end

	-- for ballons2Index=1,#HomeBallons2Config do
	-- 	local ballon = display.newSprite(IMAGE_COMMON .. "ballon_2.png"):addTo(cell,10)
	-- 	ballon:setPosition(HomeBallons2Config[ballons2Index].x, self.m_offsetY + HomeBallons2Config[ballons2Index].y)
	-- end

	self.m_buidlBtn = {}

	-- 显示基地的所有建筑
	for buildIndex = 1, #HomeBaseMapConfig do
		local config = HomeBaseMapConfig[buildIndex]
		if config then
			local x = config.x or 0
			local y = config.y or 0
			local order = config.order or 1

			local build = BuildMO.queryBuildById(config.id)
			if not build then
				gprint("[HomeBaseTableView] build is nil. Error!!! id:", config.id)
			end

			local buildBtn = nil

			if config.id == BUILD_ID_COMMAND then
				buildBtn = self:onResetBuildButton(cell, config.id)
			elseif config.id == BUILD_ID_NOTICE then -- 系统公告
				buildBtn = self:onNoticeButton(cell)
			else
				local sprite = UiUtil.createItemSprite(ITEM_KIND_BUILD, config.id)
				buildBtn = CellTouchButton.new(sprite, handler(self, self.onBuildBegan), nil, handler(self, self.onBuildEnded), handler(self, self.onChosenBuild))
				buildBtn:setAnchorPoint(cc.p(0.5, 0))
				buildBtn.buildingId = config.id
				buildBtn.buildingName = build.name
				cell:addButton(buildBtn, x, y + offsetY, {order = order})

				if config.id == BUILD_ID_ARENA then -- 竞技场
					local nameView = createBuildNameView(ArenaMO.champion_, 115):addTo(buildBtn, 2)
					nameView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + nameView.normal_:getContentSize().height / 2 - 30)
					nameView:setSkewY(-26)
					buildBtn.buildNameView = nameView

					local title = display.newSprite(IMAGE_COMMON .. "info_bg_67.png"):addTo(nameView)
					title:setPosition(0, nameView.selected_:getContentSize().height / 2 + title:getContentSize().height / 2)
				elseif config.id == BUILD_ID_PARTY then  -- 军团
					local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height - 35
					nameView:setPosition(x, y)

					local lvView = createBuildLvView(1):addTo(buildBtn, 3)
					lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
					buildBtn.buildLvView = lvView

					local tag = display.newSprite(IMAGE_COMMON .. "icon_party.png"):addTo(lvView)
					tag:setPosition(-tag:getContentSize().width / 2, lvView:getContentSize().height / 2)
					buildBtn.partyTag = tag

					-- 显示建筑名
					if UserMO.showBuildName then nameView:setOpacity(255) else nameView:setOpacity(0) end
				elseif config.id == BUILD_ID_HARBOUR then  -- 港口(在线奖励)
					local nameView = createBuildNameView(UiUtil.strBuildTime(UserMO.getOnlineAwardLeftTime())):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height + 12
					nameView:setPosition(x, y)
				elseif config.id == BUILD_ID_SCHOOL then
					local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height + 15
					nameView:setPosition(x, y)
					if true then
						local awakeHeadInfo = HeroMO.queryCanAwakeHero(HeroMO.heros_)
						if awakeHeadInfo and #awakeHeadInfo > 0 then
							local awakeLv = HeroMO.queryHero(awakeHeadInfo[1]).commanderLv
							if #awakeHeadInfo > 0 and UserMO.level_ >= awakeLv then
									if awakeHeadInfo[index] == 336 then   --如果有heroId == 336的将，此处写死为heroId == 336
										local heroHead = UiUtil.createItemView(ITEM_KIND_HERO,336):addTo(buildBtn)
										heroHead:setScale(0.3)
										heroHead:setAnchorPoint(cc.p(0.5,0))
										heroHead:setPosition(nameView:getPositionX(),nameView:getPositionY() + 20)
									end
									local function sortFun(a,b)
										return a > b
									end
									table.sort(awakeHeadInfo,sortFun) --可觉醒将领ID排序,ID最大的排第一个，做优先展示
									local heroHead = UiUtil.createItemView(ITEM_KIND_HERO,awakeHeadInfo[1]):addTo(buildBtn)
									heroHead:setScale(0.3)
									heroHead:setAnchorPoint(cc.p(0.5,0))
									heroHead:setPosition(nameView:getPositionX(),nameView:getPositionY() + 20)
									heroHead:run{
										"rep",
										{
											"seq",
											{"delay",math.random(1,3)},
											{"rotateTo",0,-10},
											{"rotateTo",0.1,10},
											{"rotateTo",0.1,-10},
											{"rotateTo",0.5,0,"ElasticOut"}
										}
									}
							end
						end
					end
				elseif config.id == BUILD_ID_LABORATORY then
					local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height - 25
					nameView:setPosition(x, y)

				elseif config.id == BUILD_ID_ADVANCEDTANK then  --高级金币车
					local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height - 25
					nameView:setPosition(x, y)
				else
					local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
					buildBtn.buildNameView = nameView

					local x = config.tx or buildBtn:getContentSize().width / 2
					local y = config.ty or buildBtn:getContentSize().height + 15
					nameView:setPosition(x, y)

					local buildLv = BuildMO.getBuildLevel(config.id)
					if buildLv then  -- 建筑是有等级的
						local lvView = createBuildLvView(buildLv):addTo(buildBtn, 3)
						lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
						buildBtn.buildLvView = lvView
					end

					-- 显示建筑名
					if UserMO.showBuildName then nameView:setOpacity(255) else nameView:setOpacity(0) end

					-- 有生产提示的小箭头
					local productTip = display.newNode():addTo(cell, buildBtn:getZOrder())
					productTip:setVisible(false) -- 默认是不可见的
					buildBtn.productTip = productTip

					local x = buildBtn:getPositionX() + nameView:getPositionX() - buildBtn:getContentSize().width / 2
					local y = buildBtn:getPositionY() + nameView:getPositionY() + 20
					productTip:setPosition(x, y)
				end

				local x = buildBtn.buildNameView:getPositionX()
				local y = buildBtn.buildNameView:getPositionY() - 18

				-- 每个建筑的升级进度条
				local upgradeBar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(222, 40), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(222 + 4, 26)}):addTo(buildBtn, 4)
				upgradeBar:setPosition(x, y)
				upgradeBar:setPercent(0)
				upgradeBar:setVisible(false)  -- 初始不可见
				upgradeBar:setScale(0.3)
				buildBtn.upgradeBar = upgradeBar

				self.m_buidlBtn[config.id] = buildBtn
			end

			if UserMO.level_ < BuildMO.getOpenLevel(config.id) then -- 没有开启
				buildBtn:setCascadeOpacityEnabled(true)
				buildBtn:setOpacity(160)
			elseif config.id == BUILD_ID_AFFAIRE then
				if not StaffMO.isStaffOpen_ and not UserMO.queryFuncOpen(UFP_MILITARY) then
					buildBtn:setCascadeOpacityEnabled(true)
					buildBtn:setOpacity(160)
				else
					buildBtn:setOpacity(255)
				end
			end

			-- 建筑的阴影
			local shade = display.newSprite("image/build/build_shade.png"):addTo(cell, 1)
			shade:setAnchorPoint(cc.p(0, 0))
			shade:setPosition(buildBtn:getPositionX() + config.sx, buildBtn:getPositionY() + config.sy)
			if config.ss then
				shade:setScale(config.ss)
			end
			
			if config.id == BUILD_ID_NOTICE then
				shade:setVisible(false)
			end

			local armature = nil
			if config.id == BUILD_ID_COMMAND then -- 基地
			else
				if config.id == BUILD_ID_REFIT then
					armature = armature_create("ui_base_refit"):addTo(buildBtn)
					armature:setVisible(false)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(88, 46)
					else
						armature:setPosition(80, 34)
					end
				elseif config.id == BUILD_ID_SCIENCE then
					armature = armature_create("ui_base_science"):addTo(buildBtn)
					armature:setVisible(false)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(40, 54)
					else
						armature:setPosition(54, 48)
					end
				elseif config.id == BUILD_ID_CHARIOT_A or config.id == BUILD_ID_CHARIOT_B then
					armature = armature_create("ui_base_chariot"):addTo(buildBtn)
					armature:setVisible(false)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(26, 30)
					else
						armature:setScale(0.88)
						armature:setPosition(38, 30)
					end
				elseif config.id == BUILD_ID_COMPONENT then
					armature = armature_create("ui_base_part", 80, 106):addTo(buildBtn)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
					else
						armature:setVisible(false)
					end
					--淬炼大师活动动画
					local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_REFINE_MASTER)
					if activity and UserMO.level_ >= BuildMO.getOpenLevel(BUILD_ID_COMPONENT) then
					armature_add(IMAGE_ANIMATION .. "effect/cuilian_gongchengshi.pvr.ccz", IMAGE_ANIMATION .. "effect/cuilian_gongchengshi.plist", IMAGE_ANIMATION .. "effect/cuilian_gongchengshi.xml")
						local armature = armature_create("cuilian_gongchengshi"):addTo(buildBtn,999):center()
						armature:setScale(0.5)
						armature:getAnimation():playWithIndex(0)
						armature:runAction(cc.RepeatForever:create(transition.sequence({cc.DelayTime:create(21),
							cc.CallFuncN:create(function(sender) sender:getAnimation():playWithIndex(0) end)})))
					end
				elseif config.id == BUILD_ID_SCHOOL then
					armature = armature_create("ui_base_school", 67, 87):addTo(buildBtn)
				elseif config.id == BUILD_ID_PARTY then
					armature = armature_create("ui_base_party"):addTo(buildBtn)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(49, 60)
					else
						armature:setScale(0.9)
						armature:setPosition(34, 55)
					end
				elseif config.id == BUILD_ID_ARENA then
					armature = armature_create("ui_base_arena"):addTo(buildBtn)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(50, 67)
					else
						armature:setPosition(54, 56)
					end
				elseif config.id == BUILD_ID_EQUIP then
					armature = armature_create("ui_base_equip", 116, 56):addTo(buildBtn)
				elseif config.id == BUILD_ID_HARBOUR then
					armature = armature_create("ui_online_award", 50, 90):addTo(buildBtn)
					armature:setScale(0.85)
					armature:setVisible(false)
				-- elseif config.id == BUILD_ID_MATERIAL_WORKSHOP then --材料工坊
				-- 	armature = armature_create("ui_base_science"):addTo(buildBtn)
				-- 	armature:setVisible(false)
				-- 	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
				-- 		armature:setPosition(40, 54)
				-- 	else
				-- 		armature:setPosition(54, 48)
				-- 	end
				elseif config.id == BUILD_ID_LABORATORY then
					armature = armature_create("zzsys_zc", 67, 181):addTo(buildBtn)
				end
				if armature then
					armature:getAnimation():playWithIndex(0)
				end
				buildBtn.armature = armature
			end
		end
	end

	self:showLoginActivity(cell)

	self:putAllTanks(cell)

	self:onBuildUpdate()

	self.liwu = {}

	self:showPatrol(cell)

	self:showBox(cell)


	return cell
end

-- 显示巡逻
function HomeBaseTableView:showPatrol(cell)
	armature_add(IMAGE_ANIMATION .. "effect/ui_patrol_helicopter.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_patrol_helicopter.plist", IMAGE_ANIMATION .. "effect/ui_patrol_helicopter.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_patrol_soldier.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_patrol_soldier.plist", IMAGE_ANIMATION .. "effect/ui_patrol_soldier.xml")

	-- 战车巡逻
	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		armature_add(IMAGE_ANIMATION .. "effect/ui_patrol_car.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_patrol_car.plist", IMAGE_ANIMATION .. "effect/ui_patrol_car.xml")

		local armature = armature_create("ui_patrol_car", self.m_cellSize.width / 2-40, self.m_cellSize.height / 2 + 20):addTo(cell)
		armature:getAnimation():playWithIndex(0)
	else
		armature_add(IMAGE_ANIMATION .. "effect/ui_patrol_car.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_patrol_car.plist", IMAGE_ANIMATION .. "effect/ui_patrol_car_1.xml")
		
		local armature = armature_create("ui_patrol_car_1", self.m_cellSize.width / 2-180 - 140, self.m_cellSize.height / 2 +35):addTo(cell)
		armature:getAnimation():playWithIndex(0)
	end

	--直升机
	-- local armature = armature_create("ui_patrol_helicopter", 0, 0):addTo(cell, 100000)
	-- -- armature:setScale(0.6)
	-- armature:setVisible(false)
	-- armature:getAnimation():playWithIndex(0)
	-- self.m_helicopterArmature = armature

	-- local function setGiftTouchEvent(node)
	-- 	local touchNode = display.newNode():addTo(node)
	-- 	touchNode:setContentSize(50,50)
	-- 	touchNode:setPosition(-182,-112)
	-- 	touchNode:setTouchEnabled(true)
	-- 	-- touchNode:drawBoundingBox()
	-- 	touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event) 
	-- 		if event.name == "began" then
	-- 			return true
	-- 		elseif event.name == "ended" then
	-- 			if node then
	-- 				node:removeSelf()
	-- 				node = nil
	-- 			end
				
	-- 			UserBO.GetGiftRewardBOX()
	-- 		end
	-- 	end)
	-- end

	-- -- 创建礼物
	-- local function makeLiwu(wdex, heidex,callback)
	-- 	wdex = wdex or 0
	-- 	heidex = heidex or 0
	-- 	if self.m_helicopterArmature and not self.m_helicopterArmature:isVisible() then return end
	-- 	local armatureliwu = armature_create("ui_patrol_helicopter_liwu",0,0,function(movementType, movementID, _armature)
	-- 		if movementType == MovementEventType.COMPLETE then
	-- 			-- if callback then callback() end
	-- 			setGiftTouchEvent(_armature)
	-- 		end
	-- 	end):addTo(cell, 100000)
	-- 	-- armatureliwu:setPosition(self.m_helicopterArmature:x() - 170 + wdex, self.m_helicopterArmature:y() + 190 + heidex)
	-- 	armatureliwu:setPosition(self.m_helicopterArmature:x() - 0 + wdex, self.m_helicopterArmature:y() + 66 + heidex)
	-- 	armatureliwu:getAnimation():playWithIndex(0)
	-- 	armatureliwu:runAction(transition.sequence({cc.DelayTime:create(0.85),cc.CallFunc:create(function ()
	-- 		if callback then callback() end
	-- 	end)}))
	-- 	self.liwu[#self.liwu + 1] = armatureliwu
	-- end

	-- -- 显示礼物
	-- local function showLiwu()
	-- 	if not self.m_helicopterliwuHandler then
	-- 		self.m_helicopterliwuHandler = scheduler.scheduleGlobal(function ()
	-- 			if self.m_helicopterArmature and not self.m_helicopterArmature:isVisible() then return end
	-- 			armature_add(IMAGE_ANIMATION .. "effect/ui_patrol_helicopter_liwu.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_patrol_helicopter_liwu.plist", IMAGE_ANIMATION .. "effect/ui_patrol_helicopter_liwu.xml")

	-- 			makeLiwu(0,0,function ()
					
	-- 				makeLiwu()
	-- 			end)

	-- 		end,2.395)
	-- 	end
	-- end

	-- -- 隐藏礼物
	-- local function hidLiwu()
	-- 	scheduler.performWithDelayGlobal(function ()
	-- 		if self.liwu then
	-- 			for index = 1, #self.liwu do
	-- 				if not tolua.isnull(self.liwu[index]) then
	-- 					self.liwu[index]:removeSelf()
	-- 				end
	-- 			end
	-- 		end
	-- 		self.liwu = {}

	-- 		if self.m_helicopterliwuHandler then
	-- 			scheduler.unscheduleGlobal(self.m_helicopterliwuHandler)
	-- 			self.m_helicopterliwuHandler = nil
	-- 		end
	-- 	end, 2)
	-- end

	-- if not self.m_helicopterHandler then
	-- 	self.m_helicopterHandler = scheduler.scheduleGlobal(function()
	-- 			if not self.m_helicopterArmature then return end
	-- 			local spwArray = cc.Array:create()
	-- 			spwArray:addObject( cc.MoveTo:create(10, cc.p(self.m_cellSize.width + 220, self.m_cellSize.height / 2 - 200 + 80)) )
	-- 			spwArray:addObject( transition.sequence({cc.DelayTime:create(1.215),cc.CallFunc:create(function()
	-- 				showLiwu()
	-- 			end)}) )
	-- 			local move = cc.Spawn:create(spwArray)

	-- 			self.m_helicopterArmature:setVisible(true)
	-- 			self.m_helicopterArmature:setPosition(-80, self.m_cellSize.height / 2 + 250 + 50)
	-- 			self.m_helicopterArmature:runAction(transition.sequence({cc.CallFunc:create(function()
	-- 					if UiDirector.getTopUiName() == "HomeView" then
	-- 						-- ManagerSound.playSound("helicopter") 
	-- 					end
	-- 			 	end),
	-- 				-- cc.MoveTo:create(18, cc.p(self.m_cellSize.width + 220, self.m_cellSize.height / 2 - 200 + 80)),
	-- 				move,
	-- 				cc.CallFunc:create(function() 
	-- 					self.m_helicopterArmature:setVisible(false) 
	-- 					hidLiwu() 
	-- 				end)}))
	-- 		end, 20)
	-- end

	local armature = armature_create("ui_patrol_soldier", 640 + 140, self.m_offsetY + 370 + 70):addTo(cell)
	-- armature:setAnchorPoint(cc.p(0.5, 0))
	armature:getAnimation():play("fan")
	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		armature:runAction(cc.RepeatForever:create(transition.sequence({
			cc.CallFuncN:create(function(sender) sender:getAnimation():play("fan") end),
			cc.MoveBy:create(8, cc.p(-140, -70)),
			cc.CallFuncN:create(function(sender) sender:getAnimation():play("zheng") end),
			cc.MoveTo:create(8, cc.p(640 + 140, self.m_offsetY + 370 + 70)) })))
	else
		armature:setPosition(560 + 140, self.m_offsetY + 370 + 70)
		armature:runAction(cc.RepeatForever:create(transition.sequence({
			cc.CallFuncN:create(function(sender) sender:getAnimation():play("fan") end),
			cc.MoveBy:create(8, cc.p(-140, -70)),
			cc.CallFuncN:create(function(sender) sender:getAnimation():play("zheng") end),
			cc.MoveTo:create(8, cc.p(560 + 140, self.m_offsetY + 370 + 70)) })))
	end

end

function HomeBaseTableView:showLoginActivity(cell)
	if ActivityBO.isValid(ACTIVITY_ID_LOGIN_AWARDS) then
		if not self.m_airshipBtn then
			--登录福利活动
			local normal = display.newSprite(IMAGE_COMMON .. "activity_airship.png")
			local selected = display.newSprite(IMAGE_COMMON .. "activity_airship.png")
			local boxBtn = MenuButton.new(normal, selected, nil, function ()
				ActivityBO.getLoginAwardsInfo(function (data)
					require("app.dialog.ActivityLoginAwardDialog").new(data):push()
				end)
			end):addTo(cell,999)
			boxBtn:setPosition(-80, self.m_cellSize.height / 2 + 300)
			local label = display.newSprite(IMAGE_COMMON .. "loginaward_label.png"):addTo(boxBtn)
			label:setScale(0.9)
			label:setPosition(boxBtn:width() / 2, boxBtn:height() - 20)

			self.m_airshipBtn = boxBtn
			local move = transition.sequence({cc.MoveTo:create(15, cc.p(560, 300 + self.m_offsetY)), 
				cc.CallFunc:create(function()
					boxBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(0, 15)), cc.MoveBy:create(2, cc.p(0, -15))})))
				end)})
			boxBtn:runAction(move)
		else
			self.m_airshipBtn:stopAllActions()
			self.m_airshipBtn:setPosition(560, 300 + self.m_offsetY)
			self.m_airshipBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.MoveBy:create(2, cc.p(0, 15)), cc.MoveBy:create(2, cc.p(0, -15))})))
		end
	end
end

--显示活跃宝箱
function HomeBaseTableView:showBox(cell)
	armature_add(IMAGE_ANIMATION .. "effect/hongbaofu.pvr.ccz", IMAGE_ANIMATION .. "effect/hongbaofu.plist", IMAGE_ANIMATION .. "effect/hongbaofu.xml")

	local box = display.newSprite(IMAGE_COMMON .. "lottery_treasure_senior_close.png")
	box:setScale(0.6)
	local boxBtn = CellTouchButton.new(box, nil, nil, nil, handler(self, self.onBoxCallback))
	cell:addButton(boxBtn, 105, 634 - 75 + self.m_offsetY,{order = 100})
	boxBtn:setVisible(#ActivityMO.activeBoxInfo > 0)
	local armature = armature_create("hongbaofu"):addTo(boxBtn)
	armature:setPosition(boxBtn:width() / 2, boxBtn:height() / 2 + 20)
	armature:setVisible(false)
	boxBtn.armature = armature
	self.m_boxBtn = boxBtn
	self.m_boxTouch = true

	armature_add("animation/effect/ui_box_star.pvr.ccz", "animation/effect/ui_box_star.plist", "animation/effect/ui_box_star.xml")
	armature_add("animation/effect/ui_box_light.pvr.ccz", "animation/effect/ui_box_light.plist", "animation/effect/ui_box_light.xml")

	local lightEffect = armature_create("ui_box_light"):addTo(boxBtn, -1):center()
    lightEffect:getAnimation():playWithIndex(0)
    lightEffect:setScale(0.6)

	local starEffect = armature_create("ui_box_star"):addTo(boxBtn, -1):center()
    starEffect:getAnimation():playWithIndex(0)
    starEffect:setScale(0.6)

end

function HomeBaseTableView:onBoxCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if not self.m_boxTouch then
		return
	end
	local function doBoxAni(awards,ret)
		require("app.dialog.ActiveBoxAwardsDialog").new(awards,ret, function ()
			if self.m_boxBtn then
				self.m_boxBtn:setVisible(false)
				self.m_boxBtn.armature:setVisible(false)
				self.m_boxTouch = true
			end
		end):push()
	end
	self.m_boxTouch = false
	HomeBO.getActiveBox(function (awards,ret)
		local awards = awards
		local ret = ret
		sender.armature:setVisible(true)
		sender.armature:getAnimation():playWithIndex(0)
		self:performWithDelay(function ()
			doBoxAni(awards,ret)
		end, 0.6)
	end)
end

function HomeBaseTableView:putAllTanks(cell)
	if self.m_tankButtons then
		for index = 1, #self.m_tankButtons do
			self.m_tankButtons[index]:removeSelf()
		end
	end
	self.m_tankButtons = {}

	local function putTank(cell, tank)
		local tankConfig = HomeBO.getTankConfig(tank.tankId)
		if tankConfig then  -- 主场景上可以放置此坦克
			-- gdump(tankConfig, "[HomeBaseTableView] putTank")
			local disX = - 77 --更换新主场地，坐标微调
			local disY = - 15
			local touch = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png")
			touch:setPreferredSize(cc.size(80, 40))
			touch:setOpacity(0)
			local btn = CellTouchButton.new(touch, handler(self, self.onTankBegan), nil, handler(self, self.onTankEnded), handler(self, self.onChosenTank))
			btn.tankId = tank.tankId
			btn:setScale(0.78)
			cell:addButton(btn, tankConfig.x + disX, tankConfig.y + self.m_offsetY + disY, {order = tankConfig.order})

			-- -- 显示底板
			-- local ban = display.newSprite(IMAGE_COMMON .. "info_bg_46.png"):addTo(btn)
			-- ban:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

			-- 显示坦克样式
			local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tank.tankId):addTo(btn)
			sprite:setScale(0.5)
			sprite:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 + 5)

			-- 显示数量
			local count = UserMO.getResource(ITEM_KIND_TANK, tank.tankId)
			local label = ui.newTTFLabel({text = count, font = G_FONT, size = FONT_SIZE_LIMIT, align = ui.TEXT_ALIGN_CENTER})

			local numBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_36.png"):addTo(btn)
			numBg:setPreferredSize(cc.size(label:getContentSize().width + 10, numBg:getContentSize().height))
			numBg:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height + 6)
			numBg:setScale(0.9)

			label:setPosition(numBg:getContentSize().width / 2 + 2, numBg:getContentSize().height / 2 + 2)
			label:addTo(numBg)

			self.m_tankButtons[#self.m_tankButtons + 1] = btn
		end
	end

	local tanks = TankMO.getFightTanks()
	-- 显示所有的坦克
	for tankIndex = 1, #tanks do
		putTank(cell, tanks[tankIndex])
	end
end

function HomeBaseTableView:cellWillRecycle(cell, index)
	-- print("删除cell:", index)
end

function HomeBaseTableView:onBuildBegan(tag, sender)
	local buildNameView = sender.buildNameView

	if buildNameView and buildNameView.normal_ then
		buildNameView.normal_:setVisible(false)
	end
	if buildNameView and buildNameView.selected_ then
		buildNameView.selected_:setVisible(true)
	end
end

function HomeBaseTableView:onBuildEnded(tag, sender)
	local buildNameView = sender.buildNameView

	if buildNameView and buildNameView.normal_ then
		buildNameView.normal_:setVisible(true)
	end
	if buildNameView and buildNameView.selected_ then
		buildNameView.selected_:setVisible(false)
	end

	-- if self.m_choseSprite then
	-- 	self.m_choseSprite:setVisible(false)
	-- end
end

-- 选中了某个建筑
function HomeBaseTableView:onChosenBuild(tag, sender)
	ManagerSound.playNormalButtonSound()

	local buildingId = sender.buildingId
	if BuildMO.getBuildStatus(buildingId) == BUILD_STATUS_UPGRADE then  -- 如果正在建造中，则不可点击进入
		if BuildMO.getBuildLevel(buildingId) == 0 then
			return
		end
	end

	if buildingId == BUILD_ID_MATERIAL_WORKSHOP then
		if not UserMO.queryFuncOpen(UFP_WEAPONRY) then
			Toast.show(CommonText[1721] .. CommonText[1722])
			return
		end
	end	

	if buildingId == BUILD_ID_ARMAMENT then
		if not UserMO.queryFuncOpen(UFP_WEAPONRY) then
			Toast.show( CommonText[1600][2] .. CommonText[1722])
			return
		end
	end	

	if buildingId == BUILD_ID_LABORATORY then
		if not UserMO.queryFuncOpen(UFP_LABORATORY) then
			Toast.show(sender.buildingName .. CommonText[1722])
			return
		end
	end

	if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
		local build = BuildMO.queryBuildById(buildingId)
		Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
		return
	end

	if buildingId == BUILD_ID_COMMAND then  -- 司令部
		require("app.view.CommandInfoView").new():push()
	elseif buildingId == BUILD_ID_CHARIOT_A or buildingId == BUILD_ID_CHARIOT_B then 
		require("app.view.ChariotInfoView").new(buildingId):push()
	elseif buildingId == BUILD_ID_EQUIP then
		require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push()
	elseif buildingId == BUILD_ID_WAREHOUSE_A or buildingId == BUILD_ID_WAREHOUSE_B then
		require("app.view.WarehouseView").new(buildingId):push()
	elseif buildingId == BUILD_ID_SCIENCE then
		require("app.view.ScienceView").new(buildingId):push()
	elseif buildingId == BUILD_ID_COMPONENT then
		require("app.view.ComponentView").new(buildingId, UI_ENTER_FADE_IN_GATE):push()
	elseif buildingId == BUILD_ID_WORKSHOP then
		require("app.view.WorkshopView").new(buildingId):push()
	elseif buildingId == BUILD_ID_REFIT then
		require("app.view.RefitView").new(buildingId):push()
	elseif buildingId == BUILD_ID_SCHOOL then
		require("app.view.NewSchoolView").new(buildingId):push()
	elseif buildingId == BUILD_ID_ARENA then
		require("app.view.ArenaView").new():push()
	elseif buildingId == BUILD_ID_MATERIAL_WORKSHOP then     --材料工坊
		local lemb = WeaponryBO.MaterialQueue
		if lemb and #lemb > 0 then
			if lemb[1].complete >= lemb[1].period then
				self:awardMaterial()
			else
				require("app.view.MaterialWorkshopView").new(buildingId,2):push()
			end
		else
			require("app.view.MaterialWorkshopView").new(buildingId,2):push()
		end
	elseif buildingId == BUILD_ID_ARMAMENT then --军备工厂
		if WeaponryBO.buildEquip and WeaponryBO.buildEquip.endTime <= ManagerTimer.getTime() then
			local function doneReset()
				self:onBuildUpdate()
			end
			WeaponryBO.CollectLordEquip(doneReset)
		else
			require("app.view.WeaponryView").new(1):push()
		end
	elseif buildingId == BUILD_ID_PARTY then
		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			Loading.getInstance():show()
			PartyBO.asynGetParty(function()
					--进入军团场景
					Loading.getInstance():unshow()
					UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_PARTY)
				end, 0)
		else
			--打开军团列表
			Loading.getInstance():show()
			PartyBO.asynGetPartyRank(function()
				Loading.getInstance():unshow()
				require("app.view.AllPartyView").new():push()
				end, 0, PartyMO.allPartyList_type_)
		end
	elseif buildingId == BUILD_ID_HARBOUR then
		if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then
			gprint("[HomeBaseTableView] harbour 1111")
		else
			if UserMO.getOnlineAwardLeftTime() <= 0 then
				local function receiveCallback()
					self:onOnlineAward()
				end

				local OnlineAwardDialog = require("app.dialog.OnlineAwardDialog")
				OnlineAwardDialog.new(receiveCallback):push()
			else
				Toast.show(CommonText[459]) -- 奖励物资正在配送中
			end
		end
	elseif buildingId == BUILD_ID_NOTICE then
		ServiceBO.showNotice(GameConfig.downRootURL .. "notice.html?t=" .. os.time())
	elseif buildingId == BUILD_ID_AFFAIRE then
		if not StaffMO.isStaffOpen_ and not UserMO.queryFuncOpen(UFP_MILITARY) then
			Toast.show(CommonText[10058][1])  -- 开服31天后开启
			return
		end
		require("app.view.StaffView").new():push()
	elseif buildingId == BUILD_ID_MILITARY then
		-- if GameConfig.areaId > 5 then
		-- 	Toast.show(CommonText[758])
		-- 	return
		-- end
		require("app.view.OrdnanceView").new():push()
	elseif buildingId == BUILD_ID_LABORATORY then
		require("app.view.LaboratoryView").new(buildingId):push()
	elseif buildingId == BUILD_ID_ADVANCEDTANK then
		UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_MONEYTANK)
	elseif buildingId == BUILD_ID_TACTICCENTER then --战术中心
		require("app.view.TacticView").new(buildingId):push()
	elseif buildingId == BUILD_ID_ENERGYCORE then --能源核心
		require("app.view.EnergyCoreView").new(buildingId):push()
	else
		gprint("[HomeBaseTableView] onChosenBuild buildingId:", buildingId)
	end
end

function HomeBaseTableView:onTankBegan(tag, sender)
end

function HomeBaseTableView:onTankEnded(tag, sender)
end

function HomeBaseTableView:onChosenTank(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local tankId = sender.tankId
	gprint("[HomeBaseTableView] onChosenTank tankId:", tankId)

	require("app.dialog.DetailTankDialog").new(tankId, true):push()
end

function HomeBaseTableView:onTouchBegan(event)
	local result = HomeBaseTableView.super.onTouchBegan(self, event)

	HomeBO.NO_OPERATE_FREE_TIMER = 0

	self.m_funcButtonView:setStatus(BUTTON_STATUS_DRAW_BACK)
	-- self.m_awardButtonView:setStatus(BUTTON_STATUS_DRAW_BACK)

	-- print("HomeBaseTableView:onTouchBegan")
	if not UserMO.showBuildName then  -- 不显示建筑
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildingId ~= BUILD_ID_ARENA and buildingId ~= BUILD_ID_HARBOUR then
				if buildBtn.buildNameView then
					buildBtn.buildNameView:stopAllActions()
					buildBtn.buildNameView:runAction(cc.FadeIn:create(0.1))
				end
			end
		end
	else
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildingId ~= BUILD_ID_ARENA and buildingId ~= BUILD_ID_HARBOUR then
				if buildBtn.buildNameView then
					buildBtn.buildNameView:setOpacity(255)
				end
			end
		end
	end

	return result
end

function HomeBaseTableView:onTouchMoved(event)
	HomeBO.NO_OPERATE_FREE_TIMER = 0

	return HomeBaseTableView.super.onTouchMoved(self, event)
end

function HomeBaseTableView:onTouchEnded(event)
	HomeBaseTableView.super.onTouchEnded(self, event)

	if not UserMO.showBuildName then  -- 不显示建筑
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildingId ~= BUILD_ID_ARENA and buildingId ~= BUILD_ID_HARBOUR then
				if buildBtn.buildNameView then
					buildBtn.buildNameView:stopAllActions()
					buildBtn.buildNameView:runAction(cc.FadeOut:create(0.08))
				end
			end
		end
	else
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildingId ~= BUILD_ID_ARENA and buildingId ~= BUILD_ID_HARBOUR then
				if buildBtn.buildNameView then
					buildBtn.buildNameView:setOpacity(255)
				end
			end
		end
	end
end

-- 开始进入游戏时的缩小效果
function HomeBaseTableView:startZoomEnter()
	self:setTouchEnabled(false)

	self:setZoomScale(1.5)
	self:setZoomScale(1.1, true)
	self:runAction(transition.sequence({cc.DelayTime:create(1.01), cc.CallFunc:create(function() self:setTouchEnabled(true) Pinging.GetInstance():show() end)})) -- 
end

function HomeBaseTableView:updateTaskBarView()
	local m_status
	if self.m_taskBarView then
		m_status = self.m_taskBarView:getBarStatus()
		self.m_taskBarView:removeSelf()
		self.m_taskBarView = nil
	end
	local task = TaskBO.getFirstMajorTask()
	-- gdump(task,"============")
	if task then
		local bg = display.newSprite(IMAGE_COMMON .. "info_bg_65.png")
		local TaskBarView = require("app.view.TaskBarView")
		local view = TaskBarView.new(task,m_status):addTo(self)
		view:setPosition(bg:getContentSize().width / 2, 184 * GAME_X_SCALE_FACTOR)
		self.m_taskBarView = view
	end
end

-- 将某个建造在屏幕中"居中"
function HomeBaseTableView:centerBuilding(buildingId, animation)
	local buildBtn = self.m_buidlBtn[buildingId]
	if not buildBtn then return end

	-- local config = findBuildConfig(buildingId)

	self:setZoomScale(1.1)

	local offset = self:getContentOffset()
	offset.x = -buildBtn:getPositionX() + display.cx

    local minOffset = self:minContainerOffset()
    local maxOffset = self:maxContainerOffset()

    offset.x = math.max(minOffset.x, math.min(maxOffset.x, offset.x))
    offset.y = math.max(minOffset.y, math.min(maxOffset.y, offset.y))

	self:setContentOffset(offset, animation)
end

function HomeBaseTableView:onSafeAreaUpdate(event)
	-- body
	if self.m_hsBtnDebuff and self.m_hsBtnBuff then
		if RoyaleSurviveMO.isActOpen() then
			local myPos = WorldMO.pos_
			local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
			self.m_hsBtnBuff:setVisible(temp)
			self.m_hsBtnDebuff:setVisible(not temp)
		else
			self.m_hsBtnBuff:setVisible(false)
			self.m_hsBtnDebuff:setVisible(false)
		end
	else
		if RoyaleSurviveMO.isActOpen() and RoyaleSurviveMO.curPhase > 0 then
			function rsCallback()
				require("app.view.RoyaleBuffShowDialog").new():push()
			end

			local normal = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected.png")
			local hsBtn = MenuButton.new(normal, selected, nil, rsCallback):addTo(self)
			hsBtn:setPosition(120, self.m_size.height - 165 * GAME_X_SCALE_FACTOR - 90)

			local normal1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_normal_debuff.png")
			local selected1 = display.newSprite(IMAGE_COMMON .. "btn_royale_survive_selected_debuff.png")
			local hsBtn1 = MenuButton.new(normal1, selected1, nil, rsCallback):addTo(self)
			hsBtn1:setPosition(120, self.m_size.height - 165 * GAME_X_SCALE_FACTOR - 90)

			local myPos = WorldMO.pos_
			local temp = RoyaleSurviveMO.IsInSafeArea(myPos)
			hsBtn:setVisible(temp)
			hsBtn1:setVisible(not temp)

			self.m_hsBtnBuff = hsBtn
			self.m_hsBtnDebuff = hsBtn1
		end
	end
end

return HomeBaseTableView
