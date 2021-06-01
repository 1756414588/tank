
-- 加速生产弹出框

-- local AccelItemTableView = class("AccelItemTableView", TableView)

-- function AccelItemTableView:ctor(size, kind)
-- 	AccelItemTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)

-- 	self.m_cellSize = cc.size(size.width, 145)
-- 	self.m_curChoseIndex = 0
-- 	-- self.m_curTankFightNum = 0 -- 当前选中的坦克上阵的数量

-- 	self.m_propIds = PropBO.getCanUsePopIds(ITEM_KIND_ACCEL, id)
-- end

-- function AccelItemTableView:numberOfCells()
-- 	return #self.m_propIds
-- end

-- function AccelItemTableView:cellSizeForIndex(index)
-- 	return self.m_cellSize
-- end

-- function AccelItemTableView:createCellAtIndex(cell, index)
-- 	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell)
-- 	bg:setPreferredSize(cc.size(self.m_cellSize.width, self.m_cellSize.height - 4))
-- 	bg:setCapInsets(cc.rect(220, 60, 1, 1))
-- 	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

-- 	return cell
-- end

------------------------------------------------------------------------------
-- 加速生产弹出框
------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local UpgradeAccelDialog = class("UpgradeAccelDialog", Dialog)

-- param: kind表示ITEM_KIND_BUILD，如果有参数wildPos则表示是城外建筑
function UpgradeAccelDialog:ctor(kind, id, param)
	UpgradeAccelDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 860)})
	param = param or {}

	gprint("[UpgradeAccelDialog] kind:", kind, "id:", id)

	self.m_kind = kind
	self.m_id = id
	self.m_param = param
end

function UpgradeAccelDialog:onEnter()
	UpgradeAccelDialog.super.onEnter(self)

	self:setTitle(CommonText[89])  -- 加速生产

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	if self.m_kind == ITEM_KIND_BUILD then -- 建筑加速
		local buildLv = 0
		if self.m_param.wildPos and self.m_param.wildPos > 0 then  -- 城外
			buildLv = BuildMO.getWildLevel(self.m_param.wildPos)
		else
			buildLv = BuildMO.getBuildLevel(self.m_id)
		end

		local nxtBuildLevel = BuildMO.queryBuildLevel(self.m_id, buildLv + 1)
		self.m_totalTime = nxtBuildLevel.upTime
	elseif self.m_kind == ITEM_KIND_TANK then
		local tank = TankMO.queryTankById(self.m_id)
		local productData = FactoryBO.getProductData(self.m_param.buildingId, self.m_param.schedulerId)
		if productData then
			self.m_totalTime = productData.period
		else
			self.m_totalTime = 0
		end
	elseif self.m_kind == ITEM_KIND_PROP then -- 道具加速
		local prop = PropMO.queryPropById(self.m_id)
		self.m_totalTime = prop.buildTime
	elseif self.m_kind == ITEM_KIND_SCIENCE then
		local productData = FactoryBO.getProductData(self.m_param.buildingId, self.m_param.schedulerId)
		if productData then
			self.m_totalTime = productData.period
		else
			self.m_totalTime = 0
		end
	end

	self:showUI()

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	if self.m_kind == ITEM_KIND_BUILD then
		self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	elseif self.m_kind == ITEM_KIND_TANK then
		self.m_tankHandler = Notify.register(LOCAL_TANK_DONE_EVENT, handler(self, self.onTankUpdate))
	elseif self.m_kind == ITEM_KIND_SCIENCE then
		self.m_scienceHandler = Notify.register(LOCAL_SCIENCE_DONE_EVENT, handler(self, self.onScienceUpdate))
	end
end

function UpgradeAccelDialog:showUI()
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	self.m_upgradeTimeLabel = nil
	self.m_upgradeBar = nil

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container

	local itemView = nil
	if self.m_kind == ITEM_KIND_BUILD then  -- 建筑加速
		-- 建筑样式
		itemView = UiUtil.createItemSprite(ITEM_KIND_BUILD, self.m_id)
	elseif self.m_kind == ITEM_KIND_TANK then
		if self.m_param.isRefit then -- 用于改装
			local tank = TankMO.queryTankById(self.m_id)
			itemView = UiUtil.createItemSprite(self.m_kind, tank.refitId)
		else
			itemView = UiUtil.createItemSprite(self.m_kind, self.m_id)
		end
	elseif self.m_kind == ITEM_KIND_PROP then
		itemView = UiUtil.createItemView(self.m_kind, self.m_id)
	elseif self.m_kind == ITEM_KIND_SCIENCE then
		itemView = UiUtil.createItemView(self.m_kind, self.m_id)
	end
	if itemView then
		itemView:setScale(math.min(1, math.min(130 / itemView:getContentSize().width, 130 / itemView:getContentSize().height)))
		itemView:setAnchorPoint(cc.p(0.5, 0))
		itemView:setPosition(100, container:getContentSize().height - 190)
		itemView:addTo(container)
	end

	local strName = ""
	if self.m_kind == ITEM_KIND_BUILD then  -- 建筑加速
		local build = BuildMO.queryBuildById(self.m_id)
		strName = build.name
	elseif self.m_kind == ITEM_KIND_TANK then
		local tank = TankMO.queryTankById(self.m_id)
		if self.m_param.isRefit then
			local refitTank = TankMO.queryTankById(tank.refitId)
			strName = refitTank.name
		else
			strName = tank.name
		end
	elseif self.m_kind == ITEM_KIND_PROP then -- 道具加速
		strName = PropMO.getPropName(self.m_id)
	elseif self.m_kind == ITEM_KIND_SCIENCE then -- 科技加速
		local science = ScienceMO.queryScience(self.m_id)
		strName = science.refineName
	end

	local name = ui.newTTFLabel({text = strName, font = G_FONT, size = FONT_SIZE_SMALL, x = 170, y = container:getContentSize().height - 100, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
	name:setAnchorPoint(cc.p(0, 0.5))

	if self.m_kind == ITEM_KIND_BUILD then  -- 建筑加速
		local buildLv = 0
		if self.m_param.wildPos and self.m_param.wildPos > 0 then  -- 城外
			buildLv = BuildMO.getWildLevel(self.m_param.wildPos)
		else
			buildLv = BuildMO.getBuildLevel(self.m_id)
		end
		local level = ui.newTTFLabel({text = "LV." .. buildLv, font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX() + name:getContentSize().width, y = name:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(container)
		level:setAnchorPoint(cc.p(0, 0.5))
	end

	local isProgressing = false -- 是否正在进行生产中

	if self.m_kind == ITEM_KIND_BUILD then  -- 建筑加速
		local buildStatus = 0
		if self.m_param.wildPos and self.m_param.wildPos > 0 then
			buildStatus = BuildMO.getWildBuildStatus(self.m_param.wildPos)
		else
			buildStatus = BuildMO.getBuildStatus(self.m_id)
		end
		if buildStatus == BUILD_STATUS_UPGRADE then
			isProgressing = true
		end
	else
		local productData = FactoryBO.getProductData(self.m_param.buildingId, self.m_param.schedulerId)

		if productData then
			isProgressing = true
		end
	end

	if isProgressing then
		local clock = display.newSprite(IMAGE_COMMON .. "icon_clock.png", 170, container:getContentSize().height - 130):addTo(container)
		clock:setAnchorPoint(cc.p(0, 0.5))

		-- 升级倒计时
		local time = ui.newBMFontLabel({text = "", font = "fnt/num_2.fnt"}):addTo(container)
		time:setAnchorPoint(cc.p(0, 0.5))
		time:setPosition(clock:getPositionX() + clock:getContentSize().width + 5, clock:getPositionY())
		self.m_upgradeTimeLabel = time

		-- 一键
		local label = ui.newTTFLabel({text = CommonText[91], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))
		label:setPosition(338, time:getPositionY())

		-- 金币
		local view = UiUtil.createItemSprite(ITEM_KIND_COIN):addTo(container)
		view:setPosition(label:getPositionX() + label:getContentSize().width + view:getContentSize().width / 2, label:getPositionY())

		-- 加速
		local label = ui.newTTFLabel({text = CommonText[82], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER}):addTo(container)
		label:setAnchorPoint(cc.p(0, 0.5))
		label:setPosition(view:getPositionX() + view:getContentSize().width / 2, view:getPositionY())

		local bar = ProgressBar.new(IMAGE_COMMON .. "bar_4.png", BAR_DIRECTION_HORIZONTAL, cc.size(290, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(290 + 4, 26)}):addTo(container)
		bar:setPosition(170 + bar:getContentSize().width / 2, container:getContentSize().height - 160)
		bar:setPercent(0)
		self.m_upgradeBar = bar

		-- 金币加速按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_accel_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_accel_selected.png")
		local accelBtn = MenuButton.new(normal, selected, nil, handler(self, self.onAccelCallback)):addTo(container)
		accelBtn:setPosition(510, container:getContentSize().height - 150)
	end

	local id = 0
	if self.m_kind == ITEM_KIND_BUILD then id = ACCEL_ID_BUILD  -- 建筑加速
	elseif self.m_kind == ITEM_KIND_TANK then id = ACCEL_ID_TANK
	elseif self.m_kind == ITEM_KIND_PROP then id = ACCEL_ID_PRODUCT
	elseif self.m_kind == ITEM_KIND_SCIENCE then id = ALLEL_ID_SCIENCE
	end

	local ItemUseTableView = require("app.scroll.ItemUseTableView")
	-- isRefit:对于tank，需要区别是否是改装
	local view = ItemUseTableView.new(cc.size(526, 607), ITEM_KIND_ACCEL, id, {buildingId = self.m_param.buildingId, wildPos = self.m_param.wildPos, schedulerId = self.m_param.schedulerId, disabled = (not isProgressing), isRefit = self.m_param.isRefit}):addTo(container)
	view:setPosition((container:getContentSize().width - view:getContentSize().width) / 2, 44)
	view:reloadData()
end

function UpgradeAccelDialog:update(dt)
	if self.m_kind == ITEM_KIND_BUILD then
		local buildStatus = 0
		if self.m_param.wildPos and self.m_param.wildPos > 0 then
			buildStatus = BuildMO.getWildBuildStatus(self.m_param.wildPos)
		else
			buildStatus = BuildMO.getBuildStatus(self.m_id)
		end

		if buildStatus == BUILD_STATUS_UPGRADE then
			local percent = 1
			local leftTime = 0
			local totalTime = 0
			if self.m_param.wildPos and self.m_param.wildPos > 0 then
				totalTime = BuildMO.getWildUpgradeTotalTime(self.m_param.wildPos)
				leftTime = BuildMO.getWildUpgradeLeftTime(self.m_param.wildPos)
			else
				totalTime = BuildMO.getUpgradeTotalTime(self.m_id)
				leftTime = BuildMO.getUpgradeLeftTime(self.m_id)
			end

			if totalTime > 0 then percent = (totalTime - leftTime) / totalTime end

			if self.m_upgradeTimeLabel then self.m_upgradeTimeLabel:setString(UiUtil.strBuildTime(leftTime)) end
			if self.m_upgradeBar then self.m_upgradeBar:setPercent(percent) end
		end
	elseif self.m_kind == ITEM_KIND_TANK or self.m_kind == ITEM_KIND_PROP or self.m_kind == ITEM_KIND_SCIENCE then
		local leftTime = FactoryBO.getProductTime(self.m_param.buildingId, self.m_param.schedulerId)
		if self.m_upgradeTimeLabel then self.m_upgradeTimeLabel:setString(UiUtil.strBuildTime(leftTime)) end

		local percent = (self.m_totalTime - leftTime) / self.m_totalTime
		if self.m_upgradeBar then self.m_upgradeBar:setPercent(percent) end
	end
end

function UpgradeAccelDialog:getLeftTime()
	if self.m_kind == ITEM_KIND_BUILD then
		local buildStatus = 0
		if self.m_param.wildPos and self.m_param.wildPos > 0 then -- 城外
			buildStatus = BuildMO.getWildBuildStatus(self.m_param.wildPos)
		else
			buildStatus = BuildMO.getBuildStatus(self.m_id)
		end
		if buildStatus == BUILD_STATUS_UPGRADE then
			if self.m_param.wildPos and self.m_param.wildPos > 0 then -- 城外
				return BuildMO.getWildUpgradeLeftTime(self.m_param.wildPos)
			else
				return BuildMO.getUpgradeLeftTime(self.m_id)
			end
		else
			return 0
		end
	elseif self.m_kind == ITEM_KIND_TANK or self.m_kind == ITEM_KIND_PROP or self.m_kind == ITEM_KIND_SCIENCE then
		return FactoryBO.getProductTime(self.m_param.buildingId, self.m_param.schedulerId)
	end
end

function UpgradeAccelDialog:onAccelCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local resData = UserMO.getResourceData(ITEM_KIND_COIN)

	local leftTime = self:getLeftTime()
	if leftTime <= 0 then return end

	local function doneSpeed()
		Loading.getInstance():unshow()
		Toast.show(CommonText[375])  -- 花费金币加速成功
		self:pop()
	end

	local needCoin = math.ceil(leftTime / BUILD_ACCEL_TIME)

	local function gotoSpeed()
		local count = UserMO.getResource(ITEM_KIND_COIN)
		if count < needCoin then
			require("app.dialog.CoinTipDialog").new():push()
			return
		end

		local leftTime = self:getLeftTime()
		if leftTime <= 0 then return end

		Loading.getInstance():show()
		if self.m_kind == ITEM_KIND_BUILD then
			if self.m_param.wildPos and self.m_param.wildPos > 0 then
				BuildBO.asynSpeedUpgrade(doneSpeed, self.m_id, 1, nil, self.m_param.wildPos)
			else
				BuildBO.asynSpeedUpgrade(doneSpeed, self.m_id, 1)  -- 金币加速
			end
		elseif self.m_kind == ITEM_KIND_TANK then
			if self.m_param.isRefit then  -- 改装的加速
				TankBO.asynSpeedRefit(doneSpeed, self.m_param.schedulerId, 1)
			else
				TankBO.asynSpeedProduct(doneSpeed, self.m_param.buildingId, self.m_param.schedulerId, 1)  -- 金币加速
			end
		elseif self.m_kind == ITEM_KIND_SCIENCE then -- 科技的加速
			ScienceBO.asynSpeedProduct(doneSpeed, self.m_param.buildingId, self.m_param.schedulerId, 1)  -- 金币加速
		end
	end

	if UserMO.consumeConfirm then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[201], needCoin, resData.name), function() gotoSpeed() end):push()
	else
		gotoSpeed()
	end
end

function UpgradeAccelDialog:onBuildUpdate(event)
	self:showUI()
end

function UpgradeAccelDialog:onTankUpdate(event)
	self:showUI()
end

function UpgradeAccelDialog:onScienceUpdate(event)
	self:showUI()
end

function UpgradeAccelDialog:onExit()
	UpgradeAccelDialog.super.onExit(self)

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	if self.m_tankHandler then
		Notify.unregister(self.m_tankHandler)
		self.m_tankHandler = nil
	end

	if self.m_scienceHandler then
		Notify.unregister(self.m_scienceHandler)
		self.m_scienceHandler = nil
	end
end


return UpgradeAccelDialog