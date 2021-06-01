
-- 

local IndicatorView = class("IndicatorView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function IndicatorView:ctor(indicatorConfig)
	self.touchLayer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(self, -1)
	self.touchLayer:setContentSize(cc.size(display.width, display.height))
	self.touchLayer:setPosition(0, 0)

	self.m_contaier = display.newNode():addTo(self)

	nodeTouchEventProtocol(self.touchLayer, function(event) return self:onTouch(event) end, nil, nil, true)

	self.m_indicatorConfig = indicatorConfig

	self.m_clickRemove = false
end

function IndicatorView:onEnter()
	self.m_stepIndex = 0
	self.m_scienceBuild = true
	self:step()
end

function IndicatorView:step()
	self.m_stepIndex = self.m_stepIndex + 1
	if self.m_scienceBuild == false then
		self.m_stepIndex = self.m_stepIndex + 1
	end
	local config = self.m_indicatorConfig.step[self.m_stepIndex]
	if config then
		if config.kind == 1 then -- 指定位置
			self:showArrow()
		elseif config.kind == 2 then --显示弹出框
			self:showDialog()
		elseif config.kind == 0 then -- 结束
			if config.command and config.command == "up_rank" then  -- 提升军衔
				if UiDirector.getTopUiName() == "PlayerView" then
					local ui = UiDirector.getTopUi()
					local container = ui.m_pageView:getContainerByIndex(1)
					if container and container.tableView_ then
						container.tableView_:onRankCallback()
					end
				end
			else
				Toast.show(CommonText[492])
			end
			self:removeSelf()
		elseif config.kind == 101 then
			self:removeSelf()

			UiDirector.popMakeUiTop("HomeView")
			require("app.view.CombatSectionView").new(1, UI_ENTER_NONE):push()
		end
	end
end

function IndicatorView:showArrow()

	self.m_contaier:removeAllChildren()

	local function createArrow(pos, size, callback)
		armature_add(IMAGE_ANIMATION .. "effect/ryxz_dianji.pvr.ccz", IMAGE_ANIMATION .. "effect/ryxz_dianji.plist", IMAGE_ANIMATION .. "effect/ryxz_dianji.xml")

		local armature = armature_create("ryxz_dianji", pos.x, pos.y + size.height / 2):addTo(self.m_contaier)
		armature:getAnimation():playWithIndex(0)
		armature:setOpacity(0)
		armature:runAction(cc.FadeIn:create(0.3))

		local normal = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png")
		normal:setPreferredSize(size)
		normal:setOpacity(0)
		local selected = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png")
		selected:setPreferredSize(size)
		selected:setOpacity(0)
		local btn = MenuButton.new(normal, selected, nil, callback):addTo(self.m_contaier)
		btn:setPosition(pos.x, pos.y + size.height / 2)
	end

	local step = self.m_indicatorConfig.step[self.m_stepIndex]

	if self.m_indicatorConfig.type == INDICATOR_TYPE_BUILD_BASE then
		if step.buildingId and step.buildingId > 0 then
			local homeView = UiDirector.getUiByName("HomeView")
			homeView:doIndicator(self.m_indicatorConfig, self.m_stepIndex, true)

			self:runAction(transition.sequence({cc.DelayTime:create(0.22), cc.CallFunc:create(function()
					local offset = homeView:getTableOffSet()

					local config = HomeBO.getBuildConfig(step.buildingId)

					local bgLeft = display.newSprite("image/bg/bg_main_1_1.jpg")
					local offsetY = (display.height - bgLeft:getContentSize().height) / 2

					local pos = cc.p(config.x + offset.x, config.y + offsetY)

					createArrow(pos, step.size, handler(self, self.doArrowReact))
				end)}))
		elseif step.wildPos and step.wildPos > 0 then
			local homeView = UiDirector.getUiByName("HomeView")
			homeView:showChosenIndex(MAIN_SHOW_WILD)

			local container = homeView:getCurContainer()
			container:centerPosition(step.wildPos)

			self:runAction(transition.sequence({cc.DelayTime:create(0.22), cc.CallFunc:create(function()
					local offset = homeView:getTableOffSet()

					local config = HomeBuildWildConfig[step.wildPos]
					local pos = HomeWildPos[config.pos]

					local bgLeft = display.newSprite("image/bg/bg_main_1_1.jpg")
					local offsetY = (display.height - bgLeft:getContentSize().height) / 2

					local pos = cc.p(pos.x + offset.x, pos.y + offsetY)

					createArrow(pos, step.size, handler(self, self.doArrowReact))
				end)}))
		else
			if step.command == "lottery_treasure" or step.command == "lottery_equip" then
				local view = UiDirector.getUiByName("HomeView")
				local tableView = view:getCurContainer()
				if tableView.m_awardButtonView:getStatus() == BUTTON_STATUS_DRAW_BACK then
					tableView.m_awardButtonView:setStatus(BUTTON_STATUS_STRETCH, true)
				end
			elseif step.command == "combat" then
				local view = UiDirector.getUiByName("HomeView")
				view:homeBottomButton(true)
			elseif step.command == "up_rank" then
				require("app.view.PlayerView").new(UI_ENTER_NONE):push()
			end

			local pos = cc.p(step.pos.x, step.pos.y)
			if step.offset then
				if step.offset == 2 then pos.y = display.cy + pos.y
				elseif step.offset == 3 then pos.y = display.height + pos.y end
			end

			createArrow(pos, step.size, handler(self, self.doArrowReact))
		end
	elseif self.m_indicatorConfig.type == INDICATOR_TYPE_WILD then
		if step.wildPos and step.wildPos > 0 then -- 是要定位要某个建筑
			local homeView = UiDirector.getUiByName("HomeView")
			homeView:doIndicator(self.m_indicatorConfig, self.m_stepIndex, true)
			self:runAction(transition.sequence({cc.DelayTime:create(0.22), cc.CallFunc:create(function()
					local offset = homeView:getTableOffSet()

					local config = HomeBuildWildConfig[step.wildPos]

					local bgLeft = display.newSprite("image/bg/bg_wild_1_1.jpg")
					local offsetY = (display.height - bgLeft:getContentSize().height) / 2

					local pos = cc.p(HomeWildPos[config.pos].x + offset.x, HomeWildPos[config.pos].y + offsetY)

					createArrow(pos, step.size, handler(self, self.doArrowReact))
				end)}))
		else
			createArrow(step.pos, step.size, handler(self, self.doArrowReact))
		end
	elseif self.m_indicatorConfig.type == INDICATOR_TYPE_ACTIVITY_LEVEL then
		local pos = cc.p(step.pos.x, step.pos.y)
		if step.offset then
			if step.offset == 2 then pos.y = display.cy + pos.y
			elseif step.offset == 3 then pos.y = display.height + pos.y end
		end

		createArrow(pos, step.size, handler(self, self.doArrowReact))
	end

	if not step.noSkip then
		self:showSkipIndicator()
	end
end

function IndicatorView:doArrowReact()
	local step = self.m_indicatorConfig.step[self.m_stepIndex]

	if self.m_indicatorConfig.type == INDICATOR_TYPE_BUILD_BASE then
		if step.buildingId and step.buildingId > 0 then
			if step.buildingId == BUILD_ID_COMMAND then  -- 要去升级司令部
				require("app.view.CommandInfoView").new():push()
			elseif step.buildingId == BUILD_ID_CHARIOT_A then
				require("app.view.ChariotInfoView").new(BUILD_ID_CHARIOT_A):push()
			elseif step.buildingId == BUILD_ID_SCIENCE then
				local buildLv = BuildMO.getBuildLevel(step.buildingId)
				if buildLv >= 1 then
				else
					self.m_scienceBuild = false
				end
				require("app.view.ScienceView").new(BUILD_ID_SCIENCE):push()
			elseif step.buildingId == BUILD_ID_EQUIP then
				require("app.view.EquipView").new(UI_ENTER_FADE_IN_GATE):push()
			elseif step.buildingId == BUILD_ID_PARTY then
				if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
					Loading.getInstance():show()
					PartyBO.asynGetParty(function()
							--进入军团场景
							Loading.getInstance():unshow()
							UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_PARTY)
						end, 0)
				else
					--打开军团列表
					PartyBO.asynGetPartyRank(function()
						require("app.view.AllPartyView").new():push()
						end, 0, PartyMO.allPartyList_type_)
				end
			end
		elseif step.command then
			if step.command == "equipOneKey" or step.command == "equipUpgrade" then
				local equipView = UiDirector.getUiByName("EquipView")
				equipView:doCommand(step.command)
			elseif step.command == "equipDialog_upgrade" then
				local equipDialog = UiDirector.getUiByName("EquipDialog")
				if equipDialog then equipDialog:doCommand(step.command) end
			elseif step.command == "chariotView_product" or step.command == "chariotView_chose" then
				local chariotView = UiDirector.getUiByName("ChariotInfoView")
				if chariotView then chariotView:doCommand(step.command) end
			elseif step.command == "player_upCommand" or step.command == "player_skill" or step.command == "player_portrait" then
				local view = UiDirector.getUiByName("PlayerView")
				if view then view:doCommand(step.command) end
			elseif step.command == "science_study" then
				local view = UiDirector.getUiByName("ScienceView")
				if view then view:doCommand(step.command) end
			elseif step.command == "home_wild" or step.command == "home_world" or step.command == "world_nearby" then
				local view = UiDirector.getUiByName("HomeView")
				if view then view:doCommand(step.command) end
			elseif step.command == "task_daily" then
				local view = UiDirector.getUiByName("TaskView")
				if view then view:doCommand(step.command) end
			elseif step.command == "indicate_wild_create" then
				if BuildMO.hasMillAtPos(step.wildPos) then
					local mill = BuildMO.getMillAtPos(step.wildPos)
					local BuildingInfoView = require("app.view.BuildingInfoView")
					BuildingInfoView.new(nil, mill.buildingId, step.wildPos):push()
				else
					local BuildingQueueView = require("app.view.BuildingQueueView")
					local config = HomeBuildWildConfig[step.wildPos]
					local viewFor = 0
					if config.tag == 0 then
						viewFor = BUILDING_FOR_WILD_COMMON
					elseif config.tag == 1 then
						viewFor = BUILDING_FOR_WILD_STONE
					elseif config.tag == 2 then
						viewFor = BUILDING_FOR_WILD_SILICON
					end
					BuildingQueueView.new(viewFor, step.wildPos):push()
				end
			elseif step.command == "login_prize" then
				if SignMO.dailyLogin_.display then
					-- local DailyLoginDialog = require("app.dialog.DailyLoginDialog")
					-- DailyLoginDialog.new():push()
					require("app.dialog.ActivityDaySign").new():push()
				else
					UiDirector.push(require("app.view.SignView").new())
				end
			elseif step.command == "lottery_treasure" or step.command == "lottery_equip" or step.command == "combat" then
				if step.name and step.name ~= "" then
					local NameView = require("app.view." .. step.name)
					NameView.new():push()
				end
			end
		elseif step.name and step.name ~= "" then
			local NameView = require("app.view." .. step.name)
			NameView.new():push()
		end
	elseif self.m_indicatorConfig.type == INDICATOR_TYPE_WILD then
		if self.m_stepIndex == 1 then
			local homeView = UiDirector.getUiByName("HomeView")
			homeView:doIndicator(self.m_indicatorConfig, self.m_stepIndex, true)
		elseif self.m_stepIndex == 3 then
			local wildPos = step.wildPos

			if BuildMO.hasMillAtPos(wildPos) then
				local mill = BuildMO.getMillAtPos(wildPos)
				-- gprint("id:" .. mill.buildingId)
				local BuildingInfoView = require("app.view.BuildingInfoView")
				BuildingInfoView.new(nil, mill.buildingId, wildPos):push()
			else
				local BuildingQueueView = require("app.view.BuildingQueueView")
				local config = HomeBuildWildConfig[wildPos]
				local viewFor = 0
				if config.tag == 0 then
					viewFor = BUILDING_FOR_WILD_COMMON
				elseif config.tag == 1 then
					viewFor = BUILDING_FOR_WILD_STONE
				elseif config.tag == 2 then
					viewFor = BUILDING_FOR_WILD_SILICON
				end
				BuildingQueueView.new(viewFor, wildPos):push()
			end
		end
	elseif self.m_indicatorConfig.type == INDICATOR_TYPE_ACTIVITY_LEVEL then
		local NameView = require("app.view." .. step.name)
		NameView.new():push()
	end
	scheduler.performWithDelayGlobal(function() self:step() end, 0.45)
end

function IndicatorView:showDialog()
	self.m_contaier:removeAllChildren()

	local infoBg = display.newSprite(IMAGE_COMMON .. "guide/info_bg_1.png"):addTo(self.m_contaier)
	infoBg:setPosition(display.cx, display.cy + 60)
	infoBg:setCascadeOpacityEnabled(true)
	infoBg:setOpacity(0)
	infoBg:runAction(cc.FadeIn:create(0.4))

	local npc = display.newSprite(IMAGE_COMMON .. "guide/role_1.png"):addTo(infoBg)
	npc:setPosition(npc:getContentSize().width / 2 + 20, 145)

	local step = self.m_indicatorConfig.step[self.m_stepIndex]

	local desc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = infoBg:getContentSize().width / 2 + 80, y = infoBg:getContentSize().height / 2, color = COLOR[1],  align = ui.TEXT_ALIGN_CENTER}):addTo(infoBg)
	if text then
		desc:setString(text)
	else
		if self.m_scienceBuild == false then
			desc:setString(CommonText[1760])
			self.m_scienceBuild = true
		else
			desc:setString(step.text)
		end
	end
	if not step.noSkip then
		self:showSkipIndicator()
	end

	if step.command then
		if step.command == "chat" then
			require("app.view.ChatView").new(nil, UI_ENTER_BOTTOM_TO_UP):push()
		elseif step.command == "rank" then
			require("app.view.RankView").new():push()
		end
	end
end

function IndicatorView:doDialogReact()
	self:step()
end

function IndicatorView:onTouch(event)
	if event.name == "ended" then
		local step = self.m_indicatorConfig.step[self.m_stepIndex]
		if step and (step.kind == 2 or step.kind == 101) then
			self:doDialogReact()
		end
	end
	return true
end

function IndicatorView:showSkipIndicator()
	local function skillCallback(tag, sender)
		self:removeSelf()
		Toast.show("退出引导")
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_42_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_42_selected.png")
	local btn = MenuButton.new(normal, selected, nil, skillCallback):addTo(self.m_contaier)
	btn:setPosition(display.width - btn:getContentSize().width / 2, btn:getContentSize().height / 2)
end

return IndicatorView