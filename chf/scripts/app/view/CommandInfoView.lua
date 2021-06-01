
-- 司令部升级view

local CommandInfoView = class("CommandInfoView", UiNode)

function CommandInfoView:ctor(uiEnter)
	uiEnter = uiEnter or UI_ENTER_BOTTOM_TO_UP
	CommandInfoView.super.ctor(self, "image/common/bg_ui.jpg", uiEnter)
end

function CommandInfoView:onEnter()
	CommandInfoView.super.onEnter(self)

	self:onBuildUpdate()
	self.m_buildHandler = Notify.register(LOCAL_BUILD_EVENT, handler(self, self.onBuildUpdate))

	local pages = {CommonText[70],CommonText[1059][1],CommonText[1078][2],CommonText[1118]} -- ,CommonText[1078][1]

	local function createDelegate(container, index)
		if index == 1 then
			self:showCommand(container)
		elseif index == 2 then
			self:showSkinMgr(container,1)	-- 皮肤
		-- elseif index == 3 then
		-- 	self:showSkinMgr(container,2)	-- 身份铭牌
		elseif index == 3 then
			self:showSkinMgr(container,3)	-- 聊天气泡
		elseif index == 4 then
			self:showFightEffectMgr(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate( index )
		if index == 2 and (not UserMO.queryFuncOpen(UFP_SKIN_MGR)) then
			Toast.show(CommonText[1722])
			return false
		end
		if index == 4 and (not UserMO.queryFuncOpen(UFP_FIGHTER)) then
			Toast.show(CommonText[1722])
			return false
		end 
		return true
	end

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 1)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end

function CommandInfoView:showCommand(container)
	container:removeAllChildren()
	local BuildUpgradeView = require("app.view.BuildUpgradeView")
	local view = BuildUpgradeView.new(self.m_build.buildingId):addTo(container)
	view:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2)
end

function CommandInfoView:showSkinMgr(container,index)
	container:removeAllChildren()
	local SkinView = require("app.view.SkinView")
	local view = SkinView.new(cc.size(container:getContentSize().width,container:getContentSize().height),index):addTo(container)
	view:setPosition(0, 0)
end

function CommandInfoView:showFightEffectMgr(container)
	container:removeAllChildren()
	local FightEffectMangaerView = require("app.view.FightEffectMangaerView")
	local view = FightEffectMangaerView.new(cc.size(container:getContentSize().width,container:getContentSize().height)):addTo(container)
	view:setPosition(0, 0)
end

function CommandInfoView:onExit()
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
end

function CommandInfoView:onBuildUpdate(event)
	self.m_build = BuildMO.queryBuildById(BUILD_ID_COMMAND)
	self.m_buildLv = BuildMO.getBuildLevel(BUILD_ID_COMMAND)

	if self.m_buildLv == 0 then -- 建造
		self:setTitle(CommonText[70])
	else
		self:setTitle(self.m_build.name .. "(LV." .. self.m_buildLv .. ")")
	end
end

return CommandInfoView
