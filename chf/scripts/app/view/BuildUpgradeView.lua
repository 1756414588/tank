------------------------------------------------------------------------------
-- 建筑的建筑或者升级
------------------------------------------------------------------------------

local BuildUpgradeView = class("BuildUpgradeView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

local itemKind = {RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER} -- 铁、石油、铜

-- 如果是城外的，需要位置wildPos
function BuildUpgradeView:ctor(buildingId, wildPos)
	-- 大小和多标签页一样
	self:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	-- gprint("[BuildUpgradeView] build id:", buildingId)
	buildingId = buildingId or 0
	wildPos = wildPos or 0
	self.m_wildPos = wildPos
	self.m_buildingId = buildingId
end

function BuildUpgradeView:onEnter()
	self.m_build = BuildMO.queryBuildById(self.m_buildingId)

	if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
		self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
	else
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
	end

	if not self.m_build then return end

	self:showUI()

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self.m_resHandler = Notify.register(LOCAL_RES_EVENT, handler(self, self.onResUpdate))
end

function BuildUpgradeView:showUI()
	self:removeAllChildren()

	if self.m_buildLv > 0 then
		self.m_isBuildUpgrade = true -- 建筑是升级，而不是建造
	end

	local container = self

	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_8.png"):addTo(container)
	titleBg:setAnchorPoint(cc.p(0, 0.5))
	titleBg:setPosition(20, container:getContentSize().height - 26)

	local title = ui.newTTFLabel({text = self.m_build.name, font = G_FONT, size = FONT_SIZE_TINY, x = 100, y = titleBg:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(titleBg)

	local maxLevel = BuildMO.queryBuildMaxLevel(self.m_buildingId)
	if self.m_buildLv < maxLevel then
		local nxtBuildLevel = BuildMO.queryBuildLevel(self.m_buildingId, self.m_buildLv + 1, self.m_wildPos and self.m_wildPos > 0)
		self.m_nxtBuildLevel = nxtBuildLevel

		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 452, titleBg:getPositionY()):addTo(container)
		local time = ui.newBMFontLabel({text = UiUtil.strBuildTime(FormulaBO.buildingUpTime(nxtBuildLevel.upTime, self.m_buildingId)), font = "fnt/num_2.fnt"}):addTo(container)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width / 2 + 5, clock:getPositionY())

	end

	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(container)
	if self.m_build.buildingId == BUILD_ID_COMMAND or self.m_build.buildingId == BUILD_ID_COPPER or self.m_build.buildingId == BUILD_ID_OIL
		or self.m_build.buildingId == BUILD_ID_IRON or self.m_build.buildingId == BUILD_ID_STONE or self.m_build.buildingId == BUILD_ID_SILICON then  -- 司令部
		attrBg:setPreferredSize(cc.size(390, 190))
	else
		attrBg:setPreferredSize(cc.size(390, 130))
	end
	attrBg:setPosition(420, container:getContentSize().height - 46 - attrBg:getContentSize().height / 2)

	-- 建筑样式
	local build = UiUtil.createItemSprite(ITEM_KIND_BUILD, self.m_build.buildingId):addTo(container)
	build:setAnchorPoint(cc.p(0.5, 0))
	build:setPosition(120, attrBg:getPositionY() - attrBg:getContentSize().height / 2)
	if self.m_build.buildingId == BUILD_ID_COMMAND then
		build:setScale(math.min(1, math.min(220 / build:getContentSize().width, 190 / build:getContentSize().height)))
	else
		build:setScale(math.min(1, math.min(220 / build:getContentSize().width, 120 / build:getContentSize().height)))
	end

	self:showBuildAttr(attrBg)

	if self.m_buildLv >= maxLevel then return end

	local conditionEnough = true

	local buildStatus = 0
	if self.m_wildPos > 0 then buildStatus = BuildMO.getWildBuildStatus(self.m_wildPos) -- 城外的
	else buildStatus = BuildMO.getBuildStatus(self.m_buildingId) end

	-- 小提示
	local tip = ui.newTTFLabel({text = CommonText[53] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 84, y = attrBg:getPositionY() - attrBg:getContentSize().height / 2 - 30, color = COLOR[2]}):addTo(container)

	-- 成为VIP。。。。
	if self.m_buildingId == BUILD_ID_MATERIAL_WORKSHOP then
		local desc = ui.newTTFLabel({text = CommonText[1716], font = G_FONT, size = FONT_SIZE_SMALL,
			x = tip:getPositionX() + tip:getContentSize().width / 2, y = tip:getPositionY(), color = COLOR[11]}):addTo(tip:getParent())
	else
		local desc = ui.newTTFLabel({text = CommonText[69], font = G_FONT, size = FONT_SIZE_SMALL,
				x = tip:getPositionX() + tip:getContentSize().width / 2, y = tip:getPositionY(), color = COLOR[11]}):addTo(tip:getParent())
	end

	local resBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	resBg:setCapInsets(cc.rect(80, 60, 1, 1))
	if self.m_buildingId == BUILD_ID_COMMAND then -- 司令部
		resBg:setPreferredSize(cc.size(604, 312))
	else
		resBg:setPreferredSize(cc.size(604, 372))
	end
	resBg:setPosition(container:getContentSize().width / 2, tip:getPositionY() - 20 - resBg:getContentSize().height / 2)

	-- 类别
	local title = ui.newTTFLabel({text = CommonText[61], font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = resBg:getContentSize().height - 26, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 需求
	local title = ui.newTTFLabel({text = CommonText[62], font = G_FONT, size = FONT_SIZE_SMALL, x = 303, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
	-- 当前拥有
	local title = ui.newTTFLabel({text = CommonText[63], font = G_FONT, size = FONT_SIZE_SMALL, x = 470, y = title:getPositionY(), color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

	local start = 0

	if self.m_buildingId == BUILD_ID_COMMAND then start = 1 end

	for index = start, 3 do
		local posY = 12 + (3 - index + 0.5) * 80

		local view = nil
		if index == 0 then view = UiUtil.createItemView(ITEM_KIND_BUILD, BUILD_ID_COMMAND):addTo(resBg) -- 建造升级需要司令部
		else view = UiUtil.createItemView(ITEM_KIND_RESOURCE, itemKind[index]):addTo(resBg) end

		view:setScale(0.65)
		view:setPosition(74, posY)

		if index == 0 then -- 建造升级需要司令部
			-- 类别名称
			local commandBuild = BuildMO.queryBuildById(BUILD_ID_COMMAND)
			local name = ui.newTTFLabel({text = commandBuild.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 需求等级
			local level = ui.newTTFLabel({text = "LV." .. self.m_nxtBuildLevel.commandLv, font = G_FONT, size = FONT_SIZE_SMALL, x = 303, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 当前等级
			local curLv = ui.newTTFLabel({text = "LV." .. BuildMO.getBuildLevel(BUILD_ID_COMMAND), font = G_FONT, size = FONT_SIZE_SMALL, x = 430, y = posY, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
			curLv:setAnchorPoint(cc.p(0, 0.5))

			if self.m_nxtBuildLevel.commandLv <= BuildMO.getBuildLevel(BUILD_ID_COMMAND) then -- 等级足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 410, posY):addTo(resBg)
			else
				conditionEnough = false -- 条件不够

				local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 410, posY):addTo(resBg)

				local function onUpCallback(tag, sender)
					ManagerSound.playNormalButtonSound()
					require("app.view.CommandInfoView").new(UI_ENTER_NONE):push()
				end
				-- 升级司令部按钮
				local normal = display.newSprite(IMAGE_COMMON .. "btn_up_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_up_selected.png")
				local upBtn = MenuButton.new(normal, selected, nil, onUpCallback):addTo(resBg)
				upBtn:setScale(0.9)
				upBtn:setPosition(560, posY)
			end
		else
			-- 类别
			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, itemKind[index])
			local name = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = 174, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)
			
			local need = 0
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, itemKind[index])

			if index == 1 then need = self.m_nxtBuildLevel.ironCost -- 铁
			elseif index == 2 then need = self.m_nxtBuildLevel.oilCost
			elseif index == 3 then need = self.m_nxtBuildLevel.copperCost
			end

			if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
				local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
				local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
				local upIds = json.decode(refitInfo.buildingId)
				for index=1,#upIds do
					if upIds[index] == self.m_buildingId then
						need = math.floor(need - need * (refitInfo.resource / 100))
					end
				end
			end

			-- 需求
			local labelN = ui.newTTFLabel({text = UiUtil.strNumSimplify(need), font = G_FONT, size = FONT_SIZE_SMALL, x = 303, y = posY, align = ui.TEXT_ALIGN_CENTER}):addTo(resBg)

			-- 当前拥有
			local labelC = ui.newBMFontLabel({text = UiUtil.strNumSimplify(count), font = "fnt/num_1.fnt", x = 430, y = posY}):addTo(resBg)
			labelC:setAnchorPoint(cc.p(0, 0.5))
			labelC:setScale(0.9)

			if need <= count then -- 足够
				local tag = display.newSprite(IMAGE_COMMON .. "icon_gou.png", 410, posY):addTo(resBg)

				name:setColor(COLOR[11])
				labelN:setColor(COLOR[11])
			else -- 不足够
				conditionEnough = false -- 条件不够

				local tag = display.newSprite(IMAGE_COMMON .. "icon_cha.png", 410, posY):addTo(resBg)

				name:setColor(COLOR[6])
				labelN:setColor(COLOR[6])

				local function onUseCallback(tag, sender)  -- 物品使用弹出框
					ManagerSound.playNormalButtonSound()
					require("app.dialog.ItemUseDialog").new(ITEM_KIND_RESOURCE, itemKind[index]):push()
				end

				local normal = display.newSprite(IMAGE_COMMON .. "btn_add_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_add_selected.png")
				local addBtn = MenuButton.new(normal, selected, nil, onUseCallback):addTo(resBg)
				addBtn:setScale(0.9)
				addBtn:setPosition(560, posY)
			end
		end

		if index ~= start then -- 两行之间的横线
			local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(resBg)
			line:setPreferredSize(cc.size(554, line:getContentSize().height))
			line:setPosition(resBg:getContentSize().width / 2, posY + 40)
		end
	end

	if buildStatus == BUILD_STATUS_FREE then -- 建筑处于空闲中
		if self.m_buildLv == 0 then
			if conditionEnough then  -- 条件足
				-- 建造
				local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
				local buildBtn = MenuButton.new(normal, selected, nil, handler(self, self.onUpgradeCallback)):addTo(container)
				buildBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
				buildBtn:setLabel(CommonText[70])
			else
				local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
				local buildBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCoinUpgradeCallback)):addTo(container)
				if self.m_wildPos and self.m_wildPos > 0 then
					buildBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 780)
				else
					buildBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
				end
				buildBtn:setLabel(CommonText[93], {y = buildBtn:getContentSize().height / 2 + 14})

				local tag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(buildBtn)
				tag:setPosition(buildBtn:getContentSize().width / 2 - 34, buildBtn:getContentSize().height / 2 - 14)

				local cost = ui.newBMFontLabel({text = self.m_nxtBuildLevel.goldCost, font = "fnt/num_1.fnt"}):addTo(buildBtn)
				cost:setAnchorPoint(cc.p(0, 0.5))
				cost:setPosition(tag:getPositionX() + tag:getContentSize().width / 2 + 5, tag:getPositionY())
			end
		else
			local function showCoinUpgradeBtn(x, y)
				-- 金币升级
				local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
				local coinUpgradeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCoinUpgradeCallback)):addTo(container)
				coinUpgradeBtn:setPosition(x, y)
				coinUpgradeBtn:setLabel(CommonText[80], {y = coinUpgradeBtn:getContentSize().height / 2 + 14})
				coinUpgradeBtn:setVisible(false)

				local tag = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(coinUpgradeBtn)
				tag:setPosition(coinUpgradeBtn:getContentSize().width / 2 - 34, coinUpgradeBtn:getContentSize().height / 2 - 14)

				local cost = ui.newBMFontLabel({text = self.m_nxtBuildLevel.goldCost, font = "fnt/num_1.fnt"}):addTo(coinUpgradeBtn)
				cost:setAnchorPoint(cc.p(0, 0.5))
				cost:setPosition(tag:getPositionX() + tag:getContentSize().width / 2 + 5, tag:getPositionY())
			end

			if self.m_wildPos and self.m_wildPos > 0 then
				-- 拆除
				local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
				local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
				local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
				local destroyBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onDestroyCallback)):addTo(container)
				destroyBtn:setPosition(140, container:getContentSize().height - 780)
				destroyBtn:setLabel(CommonText[243])

				if self.m_buildingId == BUILD_ID_STONE or self.m_buildingId == BUILD_ID_SILICON then
					destroyBtn:setEnabled(false)
				end
			end

			local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
			local upgradeBtn = MenuButton.new(normal, selected, disabled, handler(self, self.onUpgradeCallback)):addTo(container)
			if self.m_wildPos and self.m_wildPos > 0 then
				upgradeBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 780)
			else
				upgradeBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
			end
			upgradeBtn:setLabel(CommonText[79])

			if not conditionEnough then -- 条件不足，只显示金币升级
				-- if self.m_wildPos and self.m_wildPos > 0 then
				-- 	showCoinUpgradeBtn(container:getContentSize().width - 140, container:getContentSize().height - 780)
				-- else
				-- 	showCoinUpgradeBtn(container:getContentSize().width - 140, container:getContentSize().height - 730)
				-- end
				upgradeBtn:setEnabled(false)
			else
				if self.m_wildPos and self.m_wildPos > 0 then  -- 如果是城外，而条件足够，则不显示金币升级
				else
					--showCoinUpgradeBtn(140, container:getContentSize().height - 730)
				end
				-- 升级
				-- local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
				-- local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
				-- local upgradeBtn = MenuButton.new(normal, selected, nil, handler(self, self.onUpgradeCallback)):addTo(container)
				-- if self.m_wildPos and self.m_wildPos > 0 then
				-- 	upgradeBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 780)
				-- else
				-- 	upgradeBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
				-- end
				-- upgradeBtn:setLabel(CommonText[79])
			end
		end
	elseif buildStatus == BUILD_STATUS_UPGRADE then  -- 建筑升级
		local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(container)
		time:setPosition(container:getContentSize().width / 2, resBg:getPositionY() - resBg:getContentSize().height / 2 - 20)
		self.m_upgradeTimeLabel = time

		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(526, 40),
			{bgName = IMAGE_COMMON .. "bar_bg_3.png", bgScale9Size = cc.size(container:getContentSize().width - 8, 64), bgY = 17}):addTo(container)
		bar:setPosition(container:getContentSize().width / 2, resBg:getPositionY() - resBg:getContentSize().height / 2 - 58)
		bar:setPercent(0)
		self.m_upgradeBar = bar

		-- 取消
		local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
		local cancelBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCancelCallback)):addTo(container)
		if self.m_wildPos and self.m_wildPos > 0 then
			cancelBtn:setPosition(140, container:getContentSize().height - 780)
		else
			cancelBtn:setPosition(140, container:getContentSize().height - 730)
		end
		cancelBtn:setLabel(CommonText[2])

		-- 加速
		local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
		local accelBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAccelCallback)):addTo(container)
		if self.m_wildPos and self.m_wildPos > 0 then
			accelBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 780)
		else
			accelBtn:setPosition(container:getContentSize().width - 140, container:getContentSize().height - 730)
		end
		accelBtn:setLabel(CommonText[82])
	end
end

function BuildUpgradeView:update(dt)
	local buildStatus = 0
	if self.m_wildPos > 0 then
		buildStatus = BuildMO.getWildBuildStatus(self.m_wildPos)
	else
		buildStatus = BuildMO.getBuildStatus(self.m_buildingId)
	end
	if buildStatus == BUILD_STATUS_UPGRADE then
		local percent = 1
		local leftTime = 0
		local totalTime = 0
		if self.m_wildPos > 0 then -- 城外
			leftTime = BuildMO.getWildUpgradeLeftTime(self.m_wildPos)
			totalTime = BuildMO.getWildUpgradeTotalTime(self.m_wildPos)
		else
			leftTime = BuildMO.getUpgradeLeftTime(self.m_buildingId)
			totalTime = BuildMO.getUpgradeTotalTime(self.m_buildingId)
		end
		if totalTime > 0 then percent = (totalTime - leftTime) / totalTime end
		-- gprint("[BuildUpgradeView] buildId:", self.m_buildingId, "time:", leftTime)

		if self.m_upgradeTimeLabel then self.m_upgradeTimeLabel:setString(UiUtil.strBuildTime(leftTime)) end
		if self.m_upgradeBar then self.m_upgradeBar:setPercent(percent) end
	end
end

function BuildUpgradeView:onBuildUpdate(event)
	-- print("BuildUpgradeView 建筑是:", event.obj.buildId, "self:", self.m_buildingId)

	local buildingId = nil
	if event.obj then buildingId = event.obj.buildingId end
	
	if not buildingId or (buildingId == BUILD_ID_COMMAND or buildingId == self.m_buildingId) then
		if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
			self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
		else
			self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
		end
		-- self.m_buildLv = BuildMO.getBuildLevel(self.m_buildingId)
		-- print("等级是", self.m_buildLv)
		self:showUI()
	end
end

function BuildUpgradeView:onResUpdate(event)
	self:showUI()
end

-- upgradeType: 升级的方式.1金币升级，2资源升级
function BuildUpgradeView:onBuildUpgrade(upgradeType, isReceivePopName)
	if BuildBO.isUpgradeFull() then  -- 队列已满
		HomeBO.doBuildQueueCount()
		return
	end

	if self.m_isUp then return end   -- 避免连点

	local nxtBuildLevel = BuildMO.queryBuildLevel(self.m_buildingId, self.m_buildLv + 1)

	if self.m_buildingId ~= BUILD_ID_COMMAND then -- 如果不是司令部，则需要判断司令部的等级是否足够
		if nxtBuildLevel.commandLv > BuildMO.getBuildLevel(BUILD_ID_COMMAND) then -- 司令部等级不足
			local commandBuild = BuildMO.queryBuildById(BUILD_ID_COMMAND)

			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(string.format(CommonText[92], commandBuild.name, commandBuild.name), function()
					require("app.view.CommandInfoView").new(UI_ENTER_NONE):push()
				end):push()
			return
		end
	end

	if upgradeType == 1 then -- 金币直接升级
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < nxtBuildLevel.goldCost then -- 金币不足
			local resData = UserMO.getResourceData(ITEM_KIND_COIN)
			require("app.dialog.CoinTipDialog").new(resData.name .. CommonText[65]):push()  -- xx不足，无法升级
			return
		end
	elseif upgradeType == 2 then -- 资源升级
		for index = 1,  #itemKind do
			local need = 0
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, itemKind[index])

			if index == 1 then need = nxtBuildLevel.ironCost -- 铁
			elseif index == 2 then need = nxtBuildLevel.oilCost
			elseif index == 3 then need = nxtBuildLevel.copperCost
			end

			if ActivityBO.isValid(ACTIVITY_ID_BUILD_SPEED) then --如果有建筑加速活动
				local activity = ActivityMO.getActivityById(ACTIVITY_ID_BUILD_SPEED)
				local refitInfo =  BuildMO.getBuildSellInfo(activity.awardId)
				local upIds = json.decode(refitInfo.buildingId)
				for index=1,#upIds do
					if upIds[index] == self.m_buildingId then
						need = math.floor(need - need * (refitInfo.resource / 100))
					end
				end
			end

			if count < need  then
				-- xx不足，无法升级
				local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, itemKind[index])
				Toast.show(resData.name .. CommonText[65])
				return
			end
		end
	end

	local function doneBuild()
		Loading.getInstance():unshow()

		ManagerSound.playSound("build_create")

		if isReceivePopName then 
			UiDirector.popName(nil, isReceivePopName)
			return
		end
		
		if not self.m_isBuildUpgrade then
			Toast.show(CommonText[373])  -- 建造成功
			UiDirector.pop()
		end

		if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
			self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
		else
			self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
		end

		self:showUI()
		self.m_isUp = false
	end

	self.m_isUp = true
	Loading.getInstance():show()
	BuildBO.asynBuildUpgrade(doneBuild, self.m_buildingId, self.m_buildLv, upgradeType, self.m_wildPos)
end

function BuildUpgradeView:onCoinUpgradeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if UserMO.consumeConfirm then
		local nxtBuildLevel = BuildMO.queryBuildLevel(self.m_buildingId, self.m_buildLv + 1)
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[486], nxtBuildLevel.goldCost, resData.name), function() self:onBuildUpgrade(1) end):push()
	else
		self:onBuildUpgrade(1)
	end
end

function BuildUpgradeView:onUpgradeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:onBuildUpgrade(2)
end

function BuildUpgradeView:onDestroyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneDestroy()
		Loading.getInstance():unshow()
		UiDirector.pop()
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(CommonText[244], function()
			Loading.getInstance():show()
			BuildBO.asynDestroyBuild(doneDestroy, self.m_wildPos)
		end):push()
end

function BuildUpgradeView:onCancelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doneCancel()
		Loading.getInstance():unshow()
		self:showUI()
	end

	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	-- 是否确定取消
	ConfirmDialog.new(CommonText[196], function()
			Loading.getInstance():show()
			BuildBO.asynCancelUpgrade(doneCancel, self.m_buildingId, self.m_wildPos)
		end):push()
end

function BuildUpgradeView:onAccelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.UpgradeAccelDialog").new(ITEM_KIND_BUILD, self.m_buildingId, {wildPos = self.m_wildPos, buildingId = self.m_buildingId}):push()
end

function BuildUpgradeView:onExit()
	-- gprint("BuildUpgradeView onExit() ........................", self.m_buildHandler)

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	if self.m_resHandler then
		Notify.unregister(self.m_resHandler)
		self.m_resHandler = nil
	end
end

function BuildUpgradeView:showBuildAttr(attrBg)
	if self.m_buildLv == 0 then  -- 是建造
		if self.m_build.buildingId == BUILD_ID_SCIENCE then  -- 科技馆
			-- 每级提高科技研发速度
			local label = ui.newTTFLabel({text = CommonText[333][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))

			local desc = ui.newTTFLabel({text = CommonText[333][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_WAREHOUSE_A or self.m_build.buildingId == BUILD_ID_WAREHOUSE_B then
			-- 提高所有资源容量，并保护这部分不被掠夺
			local label = ui.newTTFLabel({text = CommonText[335][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_WORKSHOP then -- 制作车间
			-- 可制作部队在商城有出售的道具
			local label = ui.newTTFLabel({text = CommonText[334][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_CHARIOT_A or self.m_build.buildingId == BUILD_ID_CHARIOT_B then  -- 战车工厂
			-- 每级作战单位生产速度
			local label = ui.newTTFLabel({text = CommonText[336][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))

			local desc = ui.newTTFLabel({text = CommonText[336][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_REFIT then -- 改装工厂
			-- 每级提升改装速度
			local label = ui.newTTFLabel({text = CommonText[337][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local value = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			value:setAnchorPoint(cc.p(0, 0.5))

			local desc = ui.newTTFLabel({text = CommonText[337][2], font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			desc:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_STONE or self.m_build.buildingId == BUILD_ID_SILICON then
			local data = {}
			if self.m_build.buildingId == BUILD_ID_STONE then
				data.id = RESOURCE_ID_STONE
			elseif self.m_build.buildingId == BUILD_ID_SILICON then
				data.id = RESOURCE_ID_SILICON
			end

			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, data.id)
			-- 可生产
			local resLabel = ui.newTTFLabel({text = CommonText[338][4] .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			resLabel:setAnchorPoint(cc.p(0, 0.5))

			-- 提供每种资源容量
			local capLabel = ui.newTTFLabel({text = CommonText[338][2] .. resData.name2 .. CommonText[338][3], font = G_FONT, size = FONT_SIZE_SMALL, x = resLabel:getPositionX(), y = attrBg:getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			capLabel:setAnchorPoint(cc.p(0, 0.5))
		elseif self.m_build.buildingId == BUILD_ID_MATERIAL_WORKSHOP then --材料工坊
			--材料工坊对应的描述
			local label = ui.newTTFLabel({text = CommonText[1714], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))
		end
	elseif self.m_build.buildingId == BUILD_ID_WORKSHOP then -- 制作车间
		-- 可制作部队在商城有出售的道具
		local label = ui.newTTFLabel({text = CommonText[334][1], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
		label:setAnchorPoint(cc.p(0, 0.5))
	else
		local maxLevel = BuildMO.queryBuildMaxLevel(self.m_build.buildingId)

		-- 当前
		local cur = ui.newTTFLabel({text = CommonText[73], font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = attrBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
		cur:setAnchorPoint(cc.p(0, 0.5))

		-- 当前等级
		local curLevel = ui.newTTFLabel({text = "LV." .. self.m_buildLv, font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX() + cur:getContentSize().width + 10, y = cur:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[3]}):addTo(attrBg)
		curLevel:setAnchorPoint(cc.p(0, 0.5))

		local nxtLevel = nil
		if self.m_buildLv < maxLevel then
			local nxt = ui.newTTFLabel({text = CommonText[74], font = G_FONT, size = FONT_SIZE_SMALL, x = 150, y = cur:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			nxt:setAnchorPoint(cc.p(0, 0.5))

			-- 下一级
			nxtLevel = ui.newTTFLabel({text = "LV." .. self.m_buildLv + 1, font = G_FONT, size = FONT_SIZE_SMALL, x = nxt:getPositionX() + nxt:getContentSize().width + 10, y = nxt:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(attrBg)
			nxtLevel:setAnchorPoint(cc.p(0, 0.5))
		end

		if self.m_build.buildingId == BUILD_ID_COMMAND then -- 司令部
			-- 每小时可生产资源
			local resLabel = ui.newTTFLabel({text = CommonText[331], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			resLabel:setAnchorPoint(cc.p(0, 0.5))

			local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv)
			local cl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneOut), font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = resLabel:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

			-- 提供每种资源容量
			local capLabel = ui.newTTFLabel({text = CommonText[332], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			capLabel:setAnchorPoint(cc.p(0, 0.5))

			local cl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneMax), font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = capLabel:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

			if self.m_buildLv < maxLevel then
				local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv + 1)
				-- 下一级的生产资源
				local nl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneOut), font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = resLabel:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
				-- 下一级的容量
				local nl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneMax), font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = capLabel:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_SCIENCE then  -- 科技馆
			-- 提高科技研发速度
			local label = ui.newTTFLabel({text = CommonText[333][3], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local curLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			if self.m_buildLv < maxLevel then
				local nxtLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv + 1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_WAREHOUSE_A or self.m_build.buildingId == BUILD_ID_WAREHOUSE_B then
			-- 提高所有资源容量，并保护这部分不被掠夺
			local label = ui.newTTFLabel({text = CommonText[335][1], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv)
			local cl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneMax), font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			
			if self.m_buildLv < maxLevel then
				local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv + 1)
				-- 下一级的容量
				local nl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel.stoneMax), font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_CHARIOT_A or self.m_build.buildingId == BUILD_ID_CHARIOT_B then
			-- 作战单位生产速度
			local speed = ui.newTTFLabel({text = CommonText[336][3], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			speed:setAnchorPoint(cc.p(0, 0.5))

			local curLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = speed:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

			if self.m_buildLv < maxLevel then
				local nxtLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv + 1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = speed:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_REFIT then -- 改装工厂
			-- 改装速度
			local label = ui.newTTFLabel({text = CommonText[337][3], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			label:setAnchorPoint(cc.p(0, 0.5))

			local curLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			if self.m_buildLv < maxLevel then
				local nxtLabel = ui.newTTFLabel({text = FormulaBO.buildProductSpeed(self.m_buildLv + 1) .. "%", font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = label:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_MATERIAL_WORKSHOP then -- 材料工坊
			local descTab = {CommonText[1718][1],CommonText[1718][2],CommonText[1718][3],CommonText[1718][4]}

			local curLabel = ui.newTTFLabel({text = descTab[self.m_buildLv], font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = curLevel:getPositionY() - 45, color = COLOR[self.m_buildLv + 1], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			if self.m_buildLv < maxLevel then
				local nxtLabel = ui.newTTFLabel({text = descTab[self.m_buildLv + 1], font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = curLevel:getPositionY() - 45, color = COLOR[self.m_buildLv + 2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		elseif self.m_build.buildingId == BUILD_ID_COPPER or self.m_build.buildingId == BUILD_ID_IRON or self.m_build.buildingId == BUILD_ID_OIL
			or self.m_build.buildingId == BUILD_ID_STONE or self.m_build.buildingId == BUILD_ID_SILICON then -- 铜厂
			local data = {}
			if self.m_build.buildingId == BUILD_ID_COPPER then
				data.id = RESOURCE_ID_COPPER
				data.param1 = "copperMax"
				data.param2 = "copperOut"
			elseif self.m_build.buildingId == BUILD_ID_IRON then
				data.id = RESOURCE_ID_IRON
				data.param1 = "ironMax"
				data.param2 = "ironOut"
			elseif self.m_build.buildingId == BUILD_ID_OIL then
				data.id = RESOURCE_ID_OIL
				data.param1 = "oilMax"
				data.param2 = "oilOut"
			elseif self.m_build.buildingId == BUILD_ID_STONE then
				data.id = RESOURCE_ID_STONE
				data.param1 = "stoneMax"
				data.param2 = "stoneOut"
			elseif self.m_build.buildingId == BUILD_ID_SILICON then
				data.id = RESOURCE_ID_SILICON
				data.param1 = "siliconMax"
				data.param2 = "siliconOut"
			end

			local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, data.id)
			-- 每小时可生产
			local resLabel = ui.newTTFLabel({text = CommonText[338][1] .. resData.name, font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			resLabel:setAnchorPoint(cc.p(0, 0.5))

			local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv)
			local cl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel[data.param2]), font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = resLabel:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

			-- 提供每种资源容量
			local capLabel = ui.newTTFLabel({text = CommonText[338][2] .. resData.name2 .. CommonText[338][3], font = G_FONT, size = FONT_SIZE_SMALL, x = cur:getPositionX(), y = attrBg:getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
			capLabel:setAnchorPoint(cc.p(0, 0.5))

			local cl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel[data.param1]), font = G_FONT, size = FONT_SIZE_SMALL, x = curLevel:getPositionX() + curLevel:getContentSize().width / 2, y = capLabel:getPositionY() - 25, color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)

			if self.m_buildLv < maxLevel then
				local buildLevel = BuildMO.queryBuildLevel(self.m_build.buildingId, self.m_buildLv + 1)
				-- 下一级的生产资源
				local nl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel[data.param2]), font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = resLabel:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
				-- 下一级的容量
				local nl = ui.newTTFLabel({text = UiUtil.strNumSimplify(buildLevel[data.param1]), font = G_FONT, size = FONT_SIZE_SMALL, x = nxtLevel:getPositionX() + nxtLevel:getContentSize().width / 2, y = capLabel:getPositionY() - 25, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(attrBg)
			end
		end
	end

	if self.m_build.pros > 0 then
		local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)

		-- 每级xxx可增加
		local level = ui.newTTFLabel({text = string.format(CommonText[77], self.m_build.name), font = G_FONT, size = FONT_SIZE_SMALL, x = 14, y = 25, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
		level:setAnchorPoint(cc.p(0, 0.5))

		-- xx点
		local posValue = self.m_build.pros
		if self.m_buildLv >= 90 then
			posValue = self.m_build.pros2
		end
		local dot = ui.newTTFLabel({text = posValue .. CommonText[83], font = G_FONT, size = FONT_SIZE_SMALL, x = level:getPositionX() + level:getContentSize().width, y = level:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[3]}):addTo(attrBg)
		dot:setAnchorPoint(cc.p(0, 0.5))

		-- 繁荣度
		local pros = ui.newTTFLabel({text = resData.name2, font = G_FONT, size = FONT_SIZE_SMALL, x = dot:getPositionX() + dot:getContentSize().width, y = level:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(attrBg)
		pros:setAnchorPoint(cc.p(0, 0.5))

		local text = {}
		table.insert(text, {{content= string.format(CommonText[1816],self.m_build.pros,self.m_build.pros2)}})--标题
		--详情

		if self.m_buildingId ~= BUILD_ID_MATERIAL_WORKSHOP then
			local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal2.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected2.png")
			local tipBtn = MenuButton.new(normal, selected, nil, function ()
				local DetailTextDialog = require("app.dialog.DetailTextDialog")
				DetailTextDialog.new(text):push()
			end):addTo(attrBg)
			tipBtn:setPosition(attrBg:width() - 30,30)
			tipBtn:setScale(0.7)
		end
	else

	end
end



return BuildUpgradeView
