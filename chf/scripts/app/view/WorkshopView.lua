
-- 制作车间view

local WorkshopView = class("WorkshopView", UiNode)

function WorkshopView:ctor(buildingId)
	WorkshopView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)

	self.m_buildingId = buildingId
end

function WorkshopView:onEnter()
	WorkshopView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)
	self.m_buildLv = BuildMO.getBuildLevel(self.m_buildingId)

	local buildLv = self.m_buildLv

	self:showTitle()

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))

	if buildLv == 0 then -- 需要建造
		local container = display.newNode():addTo(self:getBg())
		container:setAnchorPoint(cc.p(0.5, 0.5))
		container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
		container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)
		self:showUpgrade(container)
	else
		local function createDelegate(container, index)
			if index == 1 then  -- 建造
				self:showInfo(container)
			elseif index == 2 then -- 生产
				self:showProduct(container)
			elseif index == 3 then -- 生产中
				self:showProducting(container)
			end
		end

		local function clickDelegate(container, index)
		end

		--  "建造", "生产", "生产中"
		local pages = {CommonText[70], CommonText[202], CommonText[203]}
		local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
		local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
		pageView:setPageIndex(2)
		self.m_pageView = pageView

		local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
		line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
		line:setScaleY(-1)
		line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
	end
end

function WorkshopView:onExit()
	WorkshopView.super.onExit(self)
	-- gprint("WorkshopView onExit() ........................")

	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end

	-- if self.m_productHandler then
	-- 	Notify.unregister(self.m_productHandler)
	-- 	self.m_productHandler = nil
	-- end
end

function WorkshopView:showTitle()
	-- 标题
	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

function WorkshopView:showUpgrade(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function WorkshopView:showInfo(container)
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function WorkshopView:showProduct(container)
	local function gotoProduct(event)
		if FactoryBO.isProducting(self.m_build.buildingId) then
			local num = #FactoryBO.getWaitProducts(self.m_build.buildingId)
			if num >= VipBO.getWaitQueueNum() then  -- 队列满了
				Toast.show(CommonText[366][3])
				return
			end
		end

		Loading.getInstance():show()

		local propId = event.propId
		local count = event.count

		PropBO.asynBuildProp(function()
				Loading.getInstance():unshow()
				-- 显示正在生产中
				self.m_pageView:setPageIndex(3)
			end, propId, count)
	end

	local WorkshopProductTableView = require("app.scroll.WorkshopProductTableView")
	local view = WorkshopProductTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:addEventListener("PRODUCT_PROP_EVENT", gotoProduct)
	view:reloadData()
end

function WorkshopView:showProducting(container)
	local WorkshopProductingTableView = require("app.scroll.WorkshopProductingTableView")
	local view = WorkshopProductingTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4), self.m_build.buildingId):addTo(container)
	view:reloadData()
end

function WorkshopView:onBuildUpdate(event)
	self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
	self:showTitle()
end

return WorkshopView

