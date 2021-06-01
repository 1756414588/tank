--
-- Author: gf
-- Date: 2015-09-18 16:00:42
--
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local PartyCombatView = class("PartyCombatView", UiNode)

function PartyCombatView:ctor(buildingId)
	PartyCombatView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
end

function PartyCombatView:onEnter()
	PartyCombatView.super.onEnter(self)

	self:setTitle(CommonText[581][6])

	self.m_sectionUpdateHandler = Notify.register(LOCAL_PARTY_SECTION_UPDATE_EVENT, handler(self, self.onSectionUpdate))
	
	local function createDelegate(container, index)
		if index == 1 then
			self:showCombatView(container)
		elseif index == 2 then
			self:showPartyBattleView(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[654][1],CommonText[654][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_tickHandler = ManagerTimer.addTickListener(handler(self, self.onTick))
	self:onTick(0)	
end

function PartyCombatView:showCombatView(container)
	local PartyCombatSectionTableView = require("app.scroll.PartyCombatSectionTableView")
	local view = PartyCombatSectionTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 60),index):addTo(container)
	view:setPosition(0, 55)
	view:reloadData()

	local lab = ui.newTTFLabel({text = CommonText[656][1] .. PartyCombatMO.combatCount_ .. "/" .. PARTY_COMBAT_COUNT_MAX, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = 35, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	lab:setAnchorPoint(cc.p(0, 0.5))

	local lab1 = ui.newTTFLabel({text = "("..CommonText[656][2]..")", font = G_FONT, size = 16, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):alignTo(lab, -25, 1)
	-- lab1:setAnchorPoint(cc.p(1, 0.5))

	--一键领取
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local btn = MenuButton.new(normal, selected, disabled, handler(self, self.onAwardCallback)):addTo(container)
	btn:setPosition(container:width() - btn:width() / 2 - 20,20)
	btn:setLabel(CommonText[100026])
	
end
	
function PartyCombatView:onAwardCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local contribute = 0
	for idx=1,#PartyCombatMO.CombatSection do
		local sectionInfo = PartyCombatMO.CombatSection[idx]
		local combatList_ = PartyCombatBO.getCombatList(sectionInfo.sectionId)
		for num=1,#combatList_ do
			local combatDB = combatList_[num]
			if combatDB.schedule == 100 and combatDB.status == 1 then
				contribute = contribute + combatDB.contribute
			end
		end
	end

	local canAward = false
	for index=1,#PartyCombatMO.CombatSection do
		local sectionDB = PartyCombatBO.getSectionDB(index)
		local awardNum = sectionDB[2]
		if awardNum > 0 then
			canAward = true
			break
		end
	end

	if canAward then
		local function awards()
			PartyCombatBO.getAllPartyAwards(function (data)
				if PartyMO.myDonate_ >= contribute then
					PartyMO.myDonate_ = PartyMO.myDonate_ - contribute
				end
				if data.donate < 0 then
					Toast.show(CommonText[1150])
				else
					Toast.show(string.format(CommonText[1151],data.donate))
				end
			end)
		end

		if contribute > 0 then
			ConfirmDialog.new(string.format(CommonText[1164], contribute), function()
				awards()
			end):push()
		else
			awards()
		end
	else
		Toast.show(CommonText[1149])
	end
end

function PartyCombatView:showPartyBattleView(container)
	local battles = {
		{id=1,img = "bar_partyBattle.jpg",name=CommonText[716],text1=CommonText[816][1],text2=CommonText[816][2]},
		{id=2,img = "party_war.jpg",name=CommonText[20005],text1=CommonText[20049],text2=""},
		{id=3,img = "party_boss.jpg",name=CommonText[953][1],text1=CommonText[953][2],text2=""},
	}

	self.m_altarboss_item = nil
	for k,v in ipairs(battles) do
		local pic = display.newSprite(IMAGE_COMMON .. v.img):addTo(container)
		pic:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 110 - pic:height()*(k-1)-10)
		local lab = ui.newTTFLabel({text = v.name, font = G_FONT, size = FONT_SIZE_MEDIUM, 
			x = 100, y = 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(pic)
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(250, 30)
		local lab = ui.newTTFLabel({text = v.text1, font = G_FONT, size = FONT_SIZE_SMALL, 
			color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(pic)
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(370, 40 - (k==2 and 4 or 0))
		local lab = ui.newTTFLabel({text = v.text2, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 220, y = 0, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(pic)
		lab:setAnchorPoint(cc.p(0, 0.5))
		lab:setPosition(370, 20)
		pic.data = v

		if v.id == 3 then
			local tips = ui.newTTFLabel({text = CommonText[953][5], font = G_FONT, size = FONT_SIZE_SMALL, 
			color = COLOR[6], align = ui.TEXT_ALIGN_CENTER}):addTo(pic)
			pic.tips = tips
			tips:setAnchorPoint(cc.p(0, 0.5))
			tips:setPosition(lab:getPosition())
			self.m_altarboss_item = pic
		end

		nodeTouchEventProtocol(pic, function(event)
			if event.name == "ended" then
				if v.id == 1 then
					if not PartyBattleMO.isOpen then
						Toast.show(CommonText[717]) 
						return
					end
		            require("app.view.PartyBattleView").new():push()
		        elseif v.id == 3 then
					if PartyBO.isPartyBuildOpen( buildingId ) then
			        	require("app.view.PartyAltarBossView").new():push()
					else
						Toast.show(CommonText[952][2])
					end		        	
		   --      	if PartyBO.canFight() then
					-- 	require("app.view.PartyAltarBossView").new():push()
					-- else
					-- 	-- Toast.show("未召唤")
					-- 	local DetailTextDialog = require("app.dialog.DetailTextDialog")
					-- 	DetailTextDialog.new(DetailText.altarboss):push()						
					-- end
		        else
		        	-- if GameConfig.areaId > 5 then
		        	-- 	Toast.show(CommonText[64])
		        	-- 	return
		        	-- end
		        	require("app.view.HomeView").new(MAIN_SHOW_FORTRESS):push()
		        end
			else
				return true
	        end
		       
			end, nil, nil, true)
	end

	self:onTick(0)
end

function PartyCombatView:onSectionUpdate()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end


function PartyCombatView:onExit()
	PartyCombatView.super.onExit(self)

	ManagerTimer.removeTickListener(self.m_tickHandler)
	self.m_tickHandler = nil

	if self.m_sectionUpdateHandler then
		Notify.unregister(self.m_sectionUpdateHandler)
		self.m_sectionUpdateHandler = nil
	end
end

function PartyCombatView:onTick(dt)
	if not self.m_pageView then return end

	if self.m_pageView:getPageIndex() == 2 then
		if self.m_altarboss_item then
			if PartyBO.canFight() then 
				local seconds = PartyMO.altarBoss_.cdTime
				self.m_altarboss_item.tips:setString(UiUtil.strBuildTime(seconds))
				self.m_altarboss_item.tips:setColor(COLOR[2])
			else
				self.m_altarboss_item.tips:setString(CommonText[953][5])
				self.m_altarboss_item.tips:setColor(COLOR[6])

				self:doTickCall()
			end
		end
	end
end

local TickGap = 10
local tick = 0
function PartyCombatView:doTickCall()
	tick = tick + 1
	if tick > TickGap then
		tick = 0
		PartyBO.asynGetPartyAltarBossData()
	end
end

return PartyCombatView