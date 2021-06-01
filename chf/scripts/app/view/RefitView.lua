
-- 改装工厂view

local RefitView = class("RefitView", UiNode)

function RefitView:ctor(buildingId)
	RefitView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.buildingId = buildingId
end

function RefitView:onEnter()
	RefitView.super.onEnter(self)

	local buildingId = self.buildingId
	

	self.m_build = BuildMO.queryBuildById(buildingId)
	self.m_buildLv = BuildMO.getBuildLevel(buildingId)

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self:showTitle()
	
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
			elseif index == 2 then -- 改装
				container.showStatus = 1 -- 显示可改装的坦克列表
				self:showProduct(container)
			elseif index == 3 then -- 生产中
				self:showProducting(container)
			end
		end

		local function clickDelegate(container, index)
		end

		--  "建造", "改装", "生产中"
		local pages = {CommonText[70], CommonText[206], CommonText[72]}
		local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
		local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
		pageView:setPageIndex(1)
		self.m_pageView = pageView

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
		line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
		line:setScaleY(-1)
		line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	end
end

function RefitView:onExit()
	RefitView.super.onExit(self)
	-- gprint("RefitView onExit() ........................")

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	-- if self.m_productHandler then
	-- 	Notify.unregister(self.m_productHandler)
	-- 	self.m_productHandler = nil
	-- end
end

function RefitView:showTitle()
	-- 标题
	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

function RefitView:showUpgrade(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function RefitView:showProduct(container)
	local function chosenTank(event)
		container.showStatus = 2 -- 显示具体的某个用于生产的tank
		container.chosenTankId = event.tankId
		self:showProduct(container)
	end

	local function showTanks()
		container.showStatus = 1 -- 显示所有tank
		self:showProduct(container)
	end

	local function gotoRefit(event)
		if FactoryBO.isProducting(self.m_build.buildingId) then
			local num = #FactoryBO.getWaitProducts(self.m_build.buildingId)
			if num >= VipBO.getWaitQueueNum() then  -- 队列满了
				Toast.show(CommonText[366][3])
				return
			end
		end

		Loading.getInstance():show()

		local tankId = event.tankId
		local count = event.count

		TankBO.asynRefit(function()
				Loading.getInstance():unshow()
				-- Toast.show("改装成功")
				self.m_pageView:setPageIndex(3)
			end, tankId, count)
	end

	container:removeAllChildren()

	if container.showStatus == 1 then
		local RefitProductTableView = require("app.scroll.RefitProductTableView")
		local view = RefitProductTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
		view:addEventListener("CHOSEN_TANK_EVENT", chosenTank)
		view:reloadData()
	else
		local RefitProductView = require("app.view.RefitProductView")
		local view = RefitProductView.new(self.m_build.buildingId, container.chosenTankId):addTo(container)
		view:addEventListener("REFIT_RETURN_EVENT", showTanks)
		view:addEventListener("ARMY_REFIT_EVENT", gotoRefit)
		view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
	end
end

function RefitView:showProducting(container)
	local RefitProductingTableView = require("app.scroll.RefitProductingTableView")
	local view = RefitProductingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), self.m_build.buildingId):addTo(container)
	view:reloadData()
end

function RefitView:onBuildUpdate(event)
	if self.m_build then
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
		self:showTitle()
	end
end

return RefitView

