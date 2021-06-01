
-- 基地城外工厂TableView

local HomeMillTableView = class("HomeMillTableView", TableView)

function HomeMillTableView:ctor(size)
	HomeMillTableView.super.ctor(self, size, SCROLL_DIRECTION_BOTH)

	local left = display.newSprite("image/bg/bg_wild_1_1.jpg")
	local right = display.newSprite("image/bg/bg_wild_1_2.jpg")

	-- self.m_cellSize = cc.size(left:getContentSize().width + right:getContentSize().width, left:getContentSize().height)
	self.m_cellSize = cc.size(left:getContentSize().width + right:getContentSize().width, size.height)

	self.m_bounceable = false
	self:setMultiTouchEnabled(true)
end

function HomeMillTableView:onEnter()
	HomeMillTableView.super.onEnter(self)
	-- armature_add(IMAGE_ANIMATION .. "effect/guangyun.pvr.ccz", IMAGE_ANIMATION .. "effect/guangyun.plist", IMAGE_ANIMATION .. "effect/guangyun.xml")
	self.m_buidlBtn = {}
	self.m_emptyBtn = {}
	self.m_shade = {}
	-- self.m_curChosenIndex = 1

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self.m_firstTaskHandler = Notify.register(LOCAL_FIRST_TASK_UPDATE_EVENT, handler(self, self.updateTaskBarView))

	self.homeEnterSchedulerHandler_ = scheduler.performWithDelayGlobal(function()
			self.homeEnterSchedulerHandler_ = nil
			if UiDirector.getTopUiName() == "HomeView" then
				ManagerSound.playSound("build_create")
				Toast.show(CommonText[359][2])
			end
		end, 0.1)

	self:updateTaskBarView()
end

function HomeMillTableView:updateTaskBarView()
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

function HomeMillTableView:onExit()
	HomeMillTableView.super.onExit(self)
	-- armature_remove(IMAGE_ANIMATION .. "effect/guangyun.pvr.ccz", IMAGE_ANIMATION .. "effect/guangyun.plist", IMAGE_ANIMATION .. "effect/guangyun.xml")
	
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	if self.m_firstTaskHandler then
		Notify.unregister(self.m_firstTaskHandler)
		self.m_firstTaskHandler = nil
	end

	if self.homeEnterSchedulerHandler_ then
		scheduler.unscheduleGlobal(self.homeEnterSchedulerHandler_)
		self.homeEnterSchedulerHandler_ = nil
	end
end

function HomeMillTableView:update(dt)
	for wildPos, buildBtn in pairs(self.m_buidlBtn) do
		local buildStatus = BuildMO.getWildBuildStatus(wildPos)
		if buildStatus == BUILD_STATUS_UPGRADE then
			local totalTime = BuildMO.getWildUpgradeTotalTime(wildPos)
			local percent = 1
			if totalTime > 0 then
				local leftTime = BuildMO.getWildUpgradeLeftTime(wildPos)
				-- gprint("建筑升级的剩余时间", leftTime, "pos:", wildPos)
				percent = (totalTime - leftTime) / totalTime
			end
			if buildBtn.upgradeBar then buildBtn.upgradeBar:setPercent(percent) end
		end
	end
end

function HomeMillTableView:onBuildUpdate(event)
	local cell = self:cellAtIndex(1)

	self:createBuildButton(cell)
end

function HomeMillTableView:numberOfCells()
	return 1
end

function HomeMillTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function HomeMillTableView:createCellAtIndex(cell, index)
	HomeMillTableView.super.createCellAtIndex(self, cell, index)

	local bgLeft = display.newSprite("image/bg/bg_wild_1_1.jpg"):addTo(cell)
	local bgRight = display.newSprite("image/bg/bg_wild_1_2.jpg"):addTo(cell)
	-- local armature = armature_create("guangyun", 60, bgLeft:height()-120):addTo(bgLeft)
	-- armature:getAnimation():playWithIndex(0)
	local offsetY = (self.m_cellSize.height - bgLeft:getContentSize().height) / 2
	self.m_offsetY = offsetY
	
	bgLeft:setPosition(bgLeft:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)
	bgRight:setPosition(bgLeft:getContentSize().width + bgRight:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)

	self:createBuildButton(cell)

	return cell
end

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

local function createBuildLvView(buildLv)
	local lvBg = display.newSprite(IMAGE_COMMON .. "info_bg_55.png")

	-- 显示等级
	local lv = ui.newTTFLabel({text = buildLv, font = G_FONT, size = FONT_SIZE_LIMIT, x = lvBg:getContentSize().width / 2, y = lvBg:getContentSize().height / 2, color = cc.c3b(246, 217, 40), align = ui.TEXT_ALIGN_CENTER}):addTo(lvBg)
	lvBg.level_ = lv
	return lvBg
end

function HomeMillTableView:createBuildButton(cell)
	armature_add(IMAGE_ANIMATION .. "effect/ui_wild.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_wild.plist", IMAGE_ANIMATION .. "effect/ui_wild_copper.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_wild.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_wild.plist", IMAGE_ANIMATION .. "effect/ui_wild_iron.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_wild.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_wild.plist", IMAGE_ANIMATION .. "effect/ui_wild_oil.xml")
	armature_add(IMAGE_ANIMATION .. "effect/ui_wild.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_wild.plist", IMAGE_ANIMATION .. "effect/ui_wild_silicon.xml")

	-- 显示基地的所有建筑
	for index = 1, #HomeBuildWildConfig do
		if self.m_buidlBtn[index] then
			self.m_buidlBtn[index]:removeSelf()
			self.m_buidlBtn[index] = nil
		end

		if self.m_emptyBtn[index] then
			self.m_emptyBtn[index]:removeSelf()
			self.m_emptyBtn[index] = nil
		end

		if self.m_shade[index] then
			self.m_shade[index]:removeSelf()
			self.m_shade[index] = nil
		end

		local config = HomeBuildWildConfig[index]
		local pos = HomeWildPos[config.pos]
		if BuildBO.isWildOpen(index) then
			local x = pos.x or 0
			local y = pos.y or 0
			local order = pos.order or 1

			local itemView = nil
			if BuildMO.hasMillAtPos(index) then
				local mill = BuildMO.getMillAtPos(index)
				itemView = UiUtil.createItemSprite(ITEM_KIND_BUILD, mill.buildingId)
			else
				itemView = UiUtil.createItemSprite(ITEM_KIND_BUILD)
			end
			local buildBtn = CellTouchButton.new(itemView, handler(self, self.onBuildBegan), nil, handler(self, self.onBuildEnded), handler(self, self.onChosenBuild))
			buildBtn:setAnchorPoint(cc.p(0.5, 0))
			buildBtn.index = index
			cell:addButton(buildBtn, x, y + self.m_offsetY, {order = order})

			if BuildMO.hasMillAtPos(index) then  -- 位置上有建筑
				local mill = BuildMO.getMillAtPos(index)
				local build = BuildMO.queryBuildById(mill.buildingId)
				local buildLv = BuildMO.getWildLevel(index)

				local nameView = createBuildNameView(build.name):addTo(buildBtn, 2)
				buildBtn.buildNameView = nameView

				nameView:setPosition(buildBtn:getContentSize().width / 2 + 30, buildBtn:getContentSize().height + 15)

				local lvView = createBuildLvView(buildLv):addTo(buildBtn, 3)
				lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
				buildBtn.buildLvView = lvView
				if GMMO.showToolBtn and UserMO.gm_ ~= 0 then
					UiUtil.label(index,26,COLOR[6]):leftTo(lvView)
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

				-- 显示建筑名
				if UserMO.showBuildName then nameView:setOpacity(255) else nameView:setOpacity(0) end

				-- 建筑的阴影
				local shade = display.newSprite("image/build/build_shade.png"):addTo(cell, 1)
				shade:setAnchorPoint(cc.p(0, 0))
				shade:setPosition(buildBtn:getPositionX() - 10, buildBtn:getPositionY() + 15)
				shade:setScale(0.65)
				self.m_shade[index] = shade

				self.m_buidlBtn[index] = buildBtn

				local armature = nil
				if mill.buildingId == BUILD_ID_COPPER then -- 铜矿
					armature = armature_create("ui_wild_copper", 72, 96):addTo(buildBtn)
				elseif mill.buildingId == BUILD_ID_IRON then -- 
					armature = armature_create("ui_wild_iron", 30, 72):addTo(buildBtn)
				elseif mill.buildingId == BUILD_ID_OIL then
					armature = armature_create("ui_wild_oil"):addTo(buildBtn)
					if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
						armature:setPosition(44, 50)
					else
						armature:setPosition(48, 50)
					end
				elseif mill.buildingId == BUILD_ID_SILICON then
					armature = armature_create("ui_wild_silicon", 62, 96):addTo(buildBtn)
				end

				if armature then
					armature:getAnimation():playWithIndex(0)
				end
				buildBtn.armature = armature
			else
				self.m_emptyBtn[index] = buildBtn
			end

			----------------------------------------------------------
			-- local label = ui.newTTFLabel({text = index .. "|" .. config.lv, font = G_FONT, size = FONT_SIZE_MEDIUM, x = buildBtn:getContentSize().width / 2, y = buildBtn:getContentSize().height / 2, color = COLOR[5], align = ui.TEXT_ALIGN_CENTER}):addTo(buildBtn, 100)
			----------------------------------------------------------
		end
	end

	for wildPos, buildBtn in pairs(self.m_buidlBtn) do
		local buildLv = BuildMO.getWildLevel(wildPos)
		if buildLv then
			buildBtn.buildLvView.level_:setString(buildLv)
		end

		local buildStatus = BuildMO.getWildBuildStatus(wildPos)
		if buildStatus == BUILD_STATUS_FREE then
			buildBtn.upgradeBar:setVisible(false)
			buildBtn.upgradeBar:setPercent(0)
		elseif buildStatus == BUILD_STATUS_UPGRADE then
			buildBtn.upgradeBar:setVisible(true)
			buildBtn.upgradeBar:setPercent(0)
		end
	end
end

function HomeMillTableView:onBuildBegan(tag, sender)
	local buildNameView = sender.buildNameView
	if not buildNameView then return end

	if buildNameView.normal_ then
		buildNameView.normal_:setVisible(false)
	end
	if buildNameView.selected_ then
		buildNameView.selected_:setVisible(true)
	end
end

function HomeMillTableView:onBuildEnded(tag, sender)
	local buildNameView = sender.buildNameView
	if not buildNameView then return end

	if buildNameView.normal_ then
		buildNameView.normal_:setVisible(true)
	end
	if buildNameView.selected_ then
		buildNameView.selected_:setVisible(false)
	end
end

-- 选中了某个建筑
function HomeMillTableView:onChosenBuild(tag, sender)
	ManagerSound.playNormalButtonSound()

	local index = sender.index

	if BuildMO.hasMillAtPos(index) then
		local mill = BuildMO.getMillAtPos(index)
		-- gprint("id:" .. mill.buildingId)
		local BuildingInfoView = require("app.view.BuildingInfoView")
		BuildingInfoView.new(nil, mill.buildingId, index):push()
	else
		local BuildingQueueView = require("app.view.BuildingQueueView")
		local config = HomeBuildWildConfig[index]
		local viewFor = 0
		if config.tag == 0 then
			viewFor = BUILDING_FOR_WILD_COMMON
		elseif config.tag == 1 then
			viewFor = BUILDING_FOR_WILD_STONE
		elseif config.tag == 2 then
			viewFor = BUILDING_FOR_WILD_SILICON
		end
		BuildingQueueView.new(viewFor, index):push()
	end
end

function HomeMillTableView:onTouchBegan(event)
	local result = HomeMillTableView.super.onTouchBegan(self, event)

	-- print("HomeMillTableView:onTouchBegan")

	if not UserMO.showBuildName then  -- 不显示建筑
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildBtn.buildNameView then
				buildBtn.buildNameView:stopAllActions()
				buildBtn.buildNameView:runAction(cc.FadeIn:create(0.1))
			end
		end
	else
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildBtn.buildNameView then
				buildBtn.buildNameView:setOpacity(255)
			end
		end
	end


	return result
end

function HomeMillTableView:onTouchEnded(event)
	HomeMillTableView.super.onTouchEnded(self, event)

	if not UserMO.showBuildName then  -- 不显示建筑
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildBtn.buildNameView then
				buildBtn.buildNameView:stopAllActions()
				buildBtn.buildNameView:runAction(cc.FadeOut:create(0.08))
			end
		end
	else
		for buildingId, buildBtn in pairs(self.m_buidlBtn) do
			if buildBtn.buildNameView then
				buildBtn.buildNameView:setOpacity(255)
			end
		end
	end
end

-- 开始进入游戏时的缩小效果
function HomeMillTableView:startZoomEnter()
	-- self:setTouchEnabled(false)

	-- self:setZoomScale(1.5)
	-- self:setZoomScale(1, true)
	-- self:runAction(transition.sequence({cc.DelayTime:create(1.01), cc.CallFunc:create(function() self:setTouchEnabled(true) end)}))
end

function HomeMillTableView:centerPosition(posIndex, animation)
	local config = HomeBuildWildConfig[posIndex]
	local pos = HomeWildPos[config.pos]

	local offset = self:getContentOffset()
	offset.x = -pos.x + display.cx

    local minOffset = self:minContainerOffset()
    local maxOffset = self:maxContainerOffset()

    offset.x = math.max(minOffset.x, math.min(maxOffset.x, offset.x))
    offset.y = math.max(minOffset.y, math.min(maxOffset.y, offset.y))

	self:setContentOffset(offset, animation)
end

return HomeMillTableView
