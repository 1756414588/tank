
-- 只用于建筑的升级view

local BuildingInfoView = class("BuildingInfoView", UiNode)

-- 如果是城外的建筑，需要传递位置wildPos
function BuildingInfoView:ctor(uiEnter, buildingId, wildPos)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP

	-- gprint("[BuildingInfoView] enter:", uiEnter)

	BuildingInfoView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
	self.m_buildingId = buildingId
	self.m_wildPos = wildPos
end

function BuildingInfoView:onEnter()
	BuildingInfoView.super.onEnter(self)

	self.m_build = BuildMO.queryBuildById(self.m_buildingId)

	if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
		self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
	else
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
	end
	self:showTitle()

	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))

	self:setUI()
end

function BuildingInfoView:onExit()
	BuildingInfoView.super.onExit(self)
	
	-- gprint("BuildingInfoView onExit() ........................")
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function BuildingInfoView:setUI()
	local container = display.newNode():addTo(self:getBg())
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setContentSize(cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180))
	container:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 94 - container:getContentSize().height / 2)

	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId, self.m_wildPos):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function BuildingInfoView:showTitle()
	if self.m_titleLabel then
		self.m_titleLabel:removeSelf()
		self.m_titleLabel = nil
	end

	-- 标题
	if self.m_buildLv == 0 then -- 建造
		self.m_titleLabel = ui.newTTFLabel({text = CommonText[70], font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER,
			x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 54}):addTo(self:getBg(), 4)
	else
		self.m_titleLabel = ui.newTTFLabel({text = self.m_build.name .. "(LV." .. self.m_buildLv .. ")", font = G_FONT, size = FONT_SIZE_BIG, align = ui.TEXT_ALIGN_CENTER,
			x = self:getBg():getContentSize().width / 2, y = self:getBg():getContentSize().height - 54}):addTo(self:getBg(), 4)
	end
end

function BuildingInfoView:onBuildUpdate(event)
	if self.m_wildPos and self.m_wildPos > 0 then -- 城外的
		self.m_buildLv = BuildMO.getWildLevel(self.m_wildPos)
	else
		self.m_buildLv = BuildMO.getBuildLevel(self.m_build.buildingId)
	end
	self:showTitle()
end

return BuildingInfoView
