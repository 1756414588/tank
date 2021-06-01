
-- 军团TableView


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

local HomePartyTableView = class("HomePartyTableView", TableView)

function HomePartyTableView:ctor(size)
	HomePartyTableView.super.ctor(self, size, SCROLL_DIRECTION_BOTH)
	local left = display.newSprite("image/bg/bg_party_1_1.jpg")
	self.m_cellSize = cc.size(left:getContentSize().width, size.height)
	self.size = size

	self.m_bounceable = false
	self:setMultiTouchEnabled(true)
end

function HomePartyTableView:onEnter()
	HomePartyTableView.super.onEnter(self)
	local size = self.size
	
	PartyBO.asynGetPartyAltarBossData()
	
	local openPartyInfo = function()
		ManagerSound.playNormalButtonSound()
		require("app.view.PartyManageView").new():push()
		
	end
	--军团信息按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_38_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_38_selected.png")
	local partyInfoBtn = MenuButton.new(normal, selected, nil, openPartyInfo)
	partyInfoBtn:setPosition(size.width - 50, 200 * GAME_X_SCALE_FACTOR)
	self.partyInfoBtn = partyInfoBtn
	self:addChild(partyInfoBtn)

	self.m_buildHandler = Notify.register(LOCAL_PARTY_BUILD_EVENT, handler(self, self.onBuildUpdate))
	self.m_buildScienceHandler = Notify.register(LOCAL_PARTY_BUILD_SCIENCE_EVENT, handler(self, self.onBuildUpdate))
	self.m_applyHandler = Notify.register(LOCAL_PARTY_APPLY_UPDATE_EVENT, handler(self, self.updateTip))

	self:updateTip()

	

	scheduler.performWithDelayGlobal(function()
			Toast.show(CommonText[698])
		end, 0.05)
end

function HomePartyTableView:onExit()
	HomePartyTableView.super.onExit(self)
	
	if self.m_buildHandler then
		Notify.unregister(self.m_buildHandler)
		self.m_buildHandler = nil
	end
	if self.m_applyHandler then
		Notify.unregister(self.m_applyHandler)
		self.m_applyHandler = nil
	end
	if self.m_buildScienceHandler then
		Notify.unregister(self.m_buildScienceHandler)
		self.m_buildScienceHandler = nil
	end
end

function HomePartyTableView:updateTip()
	if PartyMO.myJob >= PARTY_JOB_OFFICAIL then
		local applyNum = PartyMO.partyApplyList_num
		if applyNum > 0 then
			UiUtil.showTip(self.partyInfoBtn, applyNum, 70, 70)
		else
			UiUtil.unshowTip(self.partyInfoBtn)
		end
	end
end


function HomePartyTableView:onBuildUpdate(event)
	for buildingId, buildBtn in pairs(self.m_buidlBtn) do
		if buildBtn.buildLvView then
			if buildingId == PARTY_BUILD_ID_HALL then
				buildBtn.buildLvView.level_:setString(PartyMO.partyData_.partyLv)
			elseif buildingId == PARTY_BUILD_ID_SCIENCE then
				buildBtn.buildLvView.level_:setString(PartyMO.partyData_.scienceLv)
			elseif buildingId == PARTY_BUILD_ID_WEAL then
				buildBtn.buildLvView.level_:setString(PartyMO.partyData_.wealLv)
			elseif buildingId == PARTY_BUILD_ID_ALTAR then
				buildBtn.buildLvView.level_:setString(PartyMO.partyData_.altarLv)
			end
		end
	end
end


function HomePartyTableView:numberOfCells()
	return 1
end

function HomePartyTableView:cellSizeForIndex(index)
	return self.m_cellSize
end



function HomePartyTableView:createCellAtIndex(cell, index)
	HomePartyTableView.super.createCellAtIndex(self, cell, index)

	armature_add(IMAGE_ANIMATION .. "effect/ui_base.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_base.plist", IMAGE_ANIMATION .. "effect/ui_base_party.xml")

	local bgLeft = display.newSprite("image/bg/bg_party_1_1.jpg"):addTo(cell)
	-- local bgRight = display.newSprite("image/bg/bg_main_1_2.jpg"):addTo(cell)

	local offsetY = (self.m_cellSize.height - bgLeft:getContentSize().height) / 2
	self.m_offsetY = offsetY
	
	bgLeft:setPosition(bgLeft:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)
	-- bgRight:setPosition(bgLeft:getContentSize().width + bgRight:getContentSize().width / 2, bgLeft:getContentSize().height / 2 + offsetY)

	self.m_buidlBtn = {}

	-- 显示军团的所有建筑
	for buildIndex = 1, #HomePartyMapConfig do
		local config = HomePartyMapConfig[buildIndex]
		if config then
			local x = config.x or 0
			local y = config.y or 0
			local order = config.order or 1

			local sprite = UiUtil.createItemSprite(ITEM_KIND_PARTY_BUILD, config.id)
			local buildBtn = CellTouchButton.new(sprite, handler(self, self.onBuildBegan), nil, handler(self, self.onBuildEnded), handler(self, self.onChosenBuild))
			buildBtn:setAnchorPoint(cc.p(0.5, 0))
			buildBtn.buildingId = config.id
			cell:addButton(buildBtn, x, y + offsetY, {order = order})

			local nameView = createBuildNameView(CommonText[581][config.id]):addTo(buildBtn, 2)
			buildBtn.buildNameView = nameView

			-- if config.id < PARTY_BUILD_ID_INTELLIGENCE then -- 有等级
			if PartyBO.isPartyBuildShowLevel( config.id ) then -- 有等级
				nameView:setPosition(buildBtn:getContentSize().width / 2 + 30, buildBtn:getContentSize().height + 15)

				local lvView = createBuildLvView(""):addTo(buildBtn, 3)
				lvView:setPosition(nameView:getPositionX() - lvView:getContentSize().width / 2 - nameView.normal_:getContentSize().width / 2 + 8, nameView:getPositionY())
				buildBtn.buildLvView = lvView
			else
				nameView:setPosition(buildBtn:getContentSize().width / 2, buildBtn:getContentSize().height + 15)
			end

			-- 显示建筑名
			if UserMO.showBuildName then nameView:setOpacity(255) else nameView:setOpacity(0) end

			self.m_buidlBtn[config.id] = buildBtn

			-- 建筑的阴影
			local shade = display.newSprite("image/build/build_shade.png"):addTo(cell, 1)
			shade:setAnchorPoint(cc.p(0, 0))
			shade:setPosition(buildBtn:getPositionX() + config.sx, buildBtn:getPositionY() + config.sy)
			if config.ss then
				shade:setScale(config.ss)
			end

			local armature = nil
			if config.id == PARTY_BUILD_ID_HALL then
				armature = armature_create("ui_base_party"):addTo(buildBtn)
				if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
					armature:setPosition(49, 60)
				else
					armature:setScale(0.9)
					armature:setPosition(34, 55)
				end
			end
			if armature then
				armature:getAnimation():playWithIndex(0)
			end
		end
	end

	self:onBuildUpdate()

	return cell
end

function HomePartyTableView:cellWillRecycle(cell, index)
	-- print("删除cell:", index)
end

function HomePartyTableView:onBuildBegan(tag, sender)
	local buildNameView = sender.buildNameView

	if buildNameView and buildNameView.normal_ then
		buildNameView.normal_:setVisible(false)
	end
	if buildNameView and buildNameView.selected_ then
		buildNameView.selected_:setVisible(true)
	end
end

function HomePartyTableView:onBuildEnded(tag, sender)
	local buildNameView = sender.buildNameView

	if buildNameView and buildNameView.normal_ then
		buildNameView.normal_:setVisible(true)
	end
	if buildNameView and buildNameView.selected_ then
		buildNameView.selected_:setVisible(false)
	end
end

-- 选中了某个建筑
function HomePartyTableView:onChosenBuild(tag, sender)
	ManagerSound.playNormalButtonSound()
	local buildingId = sender.buildingId
	gprint("[HomePartyTableView] onChosenBuild buildingId:", buildingId)
	if buildingId == PARTY_BUILD_ID_HALL then  -- 司令部
		Loading.getInstance():show()
		PartyBO.asynGetPartyHall(function()
			Loading.getInstance():unshow()
			require("app.view.PartyHallView").new():push()
			end)
	elseif buildingId == PARTY_BUILD_ID_SCIENCE then 
		Loading.getInstance():show()
		PartyBO.asynGetPartyScience(function()
			Loading.getInstance():unshow()
			require("app.view.PartyScienceView").new():push()
			end)
	elseif buildingId == PARTY_BUILD_ID_WEAL then
		Loading.getInstance():show()
		PartyBO.asynGetPartyWeal(function()
			Loading.getInstance():unshow()
			require("app.view.PartyWealView").new():push()
			end)
	elseif buildingId == PARTY_BUILD_ID_INTELLIGENCE then
		require("app.view.PartyTrendView").new():push()
		
	elseif buildingId == PARTY_BUILD_ID_SHOP then
		Loading.getInstance():show()
		PartyBO.asynGetPartyShop(function()
			Loading.getInstance():unshow()
			require("app.view.PartyShopView").new():push()
			end)
	elseif buildingId == PARTY_BUILD_ID_TAOC then
		Loading.getInstance():show()
		PartyCombatBO.asynGetPartyCombat(function()
			Loading.getInstance():unshow()
			require("app.view.PartyCombatView").new():push()
			end)
	elseif buildingId == PARTY_BUILD_ID_ALTAR then

		if PartyBO.isPartyBuildOpen( buildingId ) then
			require("app.view.PartyAltarView").new():push()
		else
			Toast.show(CommonText[952][2])
		end
	end
end


function HomePartyTableView:onTouchBegan(event)
	local result = HomePartyTableView.super.onTouchBegan(self, event)

	-- print("HomePartyTableView:onTouchBegan")

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

function HomePartyTableView:onTouchEnded(event)
	HomePartyTableView.super.onTouchEnded(self, event)

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
function HomePartyTableView:startZoomEnter()
	self:setTouchEnabled(false)

	self:setZoomScale(1.5)
	self:setZoomScale(1, true)
	self:runAction(transition.sequence({cc.DelayTime:create(1.01), cc.CallFunc:create(function() self:setTouchEnabled(true) end)}))
end

return HomePartyTableView
