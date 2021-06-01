
-- 战车工厂信息view

local ChariotInfoView = class("ChariotInfoView", UiNode)

CHARIOT_FOR_BUILD = 1
CHARIOT_FOR_PRODUCT = 2
CHARIOT_FOR_PRODUCTING = 3

function ChariotInfoView:ctor(buildingId, viewFor)
	ChariotInfoView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)

	viewFor = viewFor or CHARIOT_FOR_BUILD

	self.m_viewFor = viewFor
	self.m_build = BuildMO.queryBuildById(buildingId)
	self.m_buildLv = BuildMO.getBuildLevel(buildingId)
end

function ChariotInfoView:onEnter()
	ChariotInfoView.super.onEnter(self)

	self:showTitle()
	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))

	local buildLv = self.m_buildLv
	if buildLv == 0 then -- 需要建造
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
		container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
		self:showUpgrade(container)
	else
		local function createDelegate(container, index)
			if index == 1 then  -- 建造
				self:showUpgrade(container)
			elseif index == 2 then -- 生产
				container.showStatus = 1 -- 显示可生产的坦克列表
				self:showProduct(container)
			elseif index == 3 then -- 生产中
				self:showProducting(container)
			end
		end

		local function clickDelegate(container, index)
		end

		--  "建造", "生产", "生产中"
		local pages = {CommonText[70], CommonText[71], CommonText[72]}
		local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
		local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
		pageView:setPageIndex(self.m_viewFor)
		self.m_pageView = pageView

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
		line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
		line:setScaleY(-1)
		line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	end
end

function ChariotInfoView:onExit()
	ChariotInfoView.super.onExit(self)
	-- gprint("ChariotInfoView onExit() ........................")

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function ChariotInfoView:showTitle()
	-- 标题
	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

function ChariotInfoView:showUpgrade(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function ChariotInfoView:showProduct(container)
	local function productTank(event)
		container.showStatus = 2 -- 显示具体的某个用于生产的tank
		container.productTankId = event.tankId
		self:showProduct(container)
	end

	local function showTanks()
		container.showStatus = 1 -- 显示所有tank
		self:showProduct(container)
	end

	local function gotoProducting(event)
		if FactoryBO.isProducting(self.m_build.buildingId) then
			local num = #FactoryBO.getWaitProducts(self.m_build.buildingId)
			if num >= VipBO.getWaitQueueNum() then  -- 队列满了
				Toast.show(CommonText[366][3])
				return
			end
		end

		Loading.getInstance():show()

		TankBO.asynProduct(function() 
				Loading.getInstance():unshow()
				ManagerSound.playSound("tank_create")
				if self.m_pageView then
					self.m_pageView:setPageIndex(3)
				end
			end,
			self.m_build.buildingId, event.tankId, event.tankNum)
	end

	container:removeAllChildren()

	if container.showStatus == 1 then
		local ArmyProductTableView = require("app.scroll.ArmyProductTableView")
		local view = ArmyProductTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), self.m_build.buildingId):addTo(container)
		view:addEventListener("PRODUCT_TANK_EVENT", productTank)
		view:reloadData()
	else
		local ArmyProductView = require("app.view.ArmyProductView")
		local view = ArmyProductView.new(self.m_build.buildingId, container.productTankId):addTo(container)
		view:addEventListener("ARMY_PRODUCT_RETURN_EVENT", showTanks)
		view:addEventListener("ARMY_PRODUCTING_EVENT", gotoProducting)
		view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	end
end

function ChariotInfoView:showProducting(container)
	local ArmyProductingTableView = require("app.scroll.ArmyProductingTableView")
	local view = ArmyProductingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), self.m_build.buildingId):addTo(container)
	view:reloadData()
end

function ChariotInfoView:onBuildUpdate(event)
	if self.m_build then
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
		self:showTitle()
	end

	-- if self.m_pageView:getPageIndex() == 2 then -- 处于生产标签页
	-- end
end

function ChariotInfoView:doCommand(command, callback)
	if not self.m_pageView then if callback then callback() end return end

	if command == "chariotView_product" then
		self.m_pageView:setPageIndex(CHARIOT_FOR_PRODUCT)
		if callback then callback() end
	elseif command == "chariotView_chose" then
		self.m_pageView:setPageIndex(CHARIOT_FOR_PRODUCT)
		local container = self.m_pageView:getContainerByIndex(CHARIOT_FOR_PRODUCT)
		container.showStatus = 2 -- 显示具体的某个用于生产的tank
		container.productTankId = 1
		self:showProduct(container)
		if callback then callback() end
	end
end

return ChariotInfoView
