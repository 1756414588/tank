--
-- Author: gf
-- Date: 2015-12-15 16:05:39
-- 百团大战

PARTY_BATTLE_VIEW_INDEX_SIGN = 1
PARTY_BATTLE_VIEW_INDEX_COMBAT = 2
PARTY_BATTLE_VIEW_INDEX_RANK = 3

local PartyBattleView = class("PartyBattleView", UiNode)

function PartyBattleView:ctor()
	PartyBattleView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function PartyBattleView:onEnter()
	PartyBattleView.super.onEnter(self)

	self:setTitle(CommonText[794])

	
	local function createDelegate(container, index)
		if index == PARTY_BATTLE_VIEW_INDEX_SIGN then
			Loading.getInstance():show()
			PartyBattleBO.asynWarMembers(function()
				Loading.getInstance():unshow()
				self:showSignView(container)
				end)
		elseif index == PARTY_BATTLE_VIEW_INDEX_COMBAT then
			self:showCombatView(container)
		elseif index == PARTY_BATTLE_VIEW_INDEX_RANK then
			self:showRankView(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = CommonText[795]
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	
	local battleStatus = PartyBattleBO.getBattleStatus()
	--如果当前时间是报名时间
	if battleStatus.stage == 1 then
		pageView:setPageIndex(PARTY_BATTLE_VIEW_INDEX_SIGN)
	else
		--如果当前时间是混战时间
		pageView:setPageIndex(PARTY_BATTLE_VIEW_INDEX_COMBAT)
	end
	
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)


	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, handler(self, self.onChatUpdate))
	self.m_readChatHandler = Notify.register(LOCAL_READ_CHAT_EVENT, handler(self, self.onChatUpdate))

	self:onChatUpdate()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.updateView))
	self:scheduleUpdate()
end

function PartyBattleView:showSignView(container)
	self.battleStatusLab = nil
	local banner = display.newSprite(IMAGE_COMMON .. "bar_partyBattle.jpg", container:getContentSize().width / 2, container:getContentSize().height - 110):addTo(container)
	--规则按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local ruleBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.partyBattleSign):push()
		end):addTo(container)
	ruleBtn:setPosition(container:getContentSize().width - 50, container:getContentSize().height - 180)

	--报名状态
	local signStatusLab = ui.newTTFLabel({text = CommonText[796][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 215, y = 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(banner)
	signStatusLab:setAnchorPoint(cc.p(0, 0.5))

	local signStatusValue = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = signStatusLab:getPositionX() + signStatusLab:getContentSize().width, 
		y = signStatusLab:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(banner)
	signStatusValue:setAnchorPoint(cc.p(0, 0.5))
	self.signStatusValue = signStatusValue
	
	--本军团已报名玩家

	local signNumLab = ui.newTTFLabel({text = CommonText[796][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 215, y = 20, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(banner)
	signNumLab:setAnchorPoint(cc.p(0, 0.5))

	local signNumValue = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = signNumLab:getPositionX() + signNumLab:getContentSize().width, 
		y = signNumLab:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(banner)
	signNumValue:setAnchorPoint(cc.p(0, 0.5))
	self.signNumValue = signNumValue

	local signNumMax = ui.newTTFLabel({text = "0", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = signNumValue:getPositionX() + signNumValue:getContentSize().width, 
		y = signNumValue:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(banner)
	signNumMax:setAnchorPoint(cc.p(0, 0.5))
	signNumMax:setString("/" .. PartyMO.queryParty(PartyMO.partyData_.partyLv).partyNum)
	self.signNumMax = signNumMax
	

	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, self:getBg():getContentSize().height - 480))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tableBg:getContentSize().height / 2 - 220)

	local posX = {45, 200, 350, 470}
	for index=1,#CommonText[799] do
		local labTit = ui.newTTFLabel({text = CommonText[799][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		labTit:setAnchorPoint(cc.p(0, 0.5))
	end


	local PartyBSignTableView = require("app.scroll.PartyBSignTableView")
	--报名玩家tableView
	local view = PartyBSignTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70)):addTo(tableBg)
	view:setPosition(0, 25)
	view:reloadData()


	--按钮
	--参与军团
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local joinPartyBtn = MenuButton.new(normal, selected, nil, handler(self,self.openJoinPartyView)):addTo(container)
	joinPartyBtn:setPosition(container:getContentSize().width / 2 - 195,35)
	joinPartyBtn:setLabel(CommonText[798][1])
	self.joinPartyBtn = joinPartyBtn

	--报名
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local signBtn = MenuButton.new(normal, selected, nil, handler(self,self.signHandler)):addTo(container)
	signBtn:setPosition(container:getContentSize().width / 2,35)
	signBtn:setLabel(CommonText[798][2])
	self.signBtn = signBtn

	--取消报名
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local cancelSignBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelSignHandler)):addTo(container)
	cancelSignBtn:setPosition(container:getContentSize().width / 2,35)
	cancelSignBtn:setLabel(CommonText[798][3])
	self.cancelSignBtn = cancelSignBtn

	--查看阵形
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local formationBtn = MenuButton.new(normal, selected, nil, handler(self,self.formationHandler)):addTo(container)
	formationBtn:setPosition(container:getContentSize().width / 2 + 195,35)
	formationBtn:setLabel(CommonText[798][4])
	self.formationBtn = formationBtn

end

function PartyBattleView:updateView()
	local battleStatus = PartyBattleBO.getBattleStatus()
	if self.m_pageView:getPageIndex() == PARTY_BATTLE_VIEW_INDEX_SIGN then
		if not self.signStatusValue then return end
		--判断报名状态
		if battleStatus.stage == 0 then
			--未开始
			self.signStatusValue:setString(CommonText[797][1])
			self.signStatusValue:setColor(COLOR[6])
			self.signBtn:setVisible(false)
			self.cancelSignBtn:setVisible(false)
			self.formationBtn:setVisible(false)
		else
			
			--已开始
			if battleStatus.stage == 1 then
				local time = ManagerTimer.time(battleStatus.cd)
				if PartyBattleBO.haveSign() == false then
					--未报名
					self.signStatusValue:setString(CommonText[797][2] .. "(" .. string.format("%02d:%02d", time.minute, time.second) .. ")")
					self.signStatusValue:setColor(COLOR[2])
					self.signBtn:setVisible(true)
					self.cancelSignBtn:setVisible(false)
					self.formationBtn:setVisible(false)
				else
					--已报名
					self.signStatusValue:setString(CommonText[797][3] .. "(" .. string.format("%02d:%02d", time.minute, time.second) .. ")")
					self.signStatusValue:setColor(COLOR[2])
					self.signBtn:setVisible(false)
					self.cancelSignBtn:setVisible(true)
					self.formationBtn:setVisible(true)
				end
			elseif battleStatus.stage == 2 then
				local time = ManagerTimer.time(battleStatus.cd)
				self.signStatusValue:setString(CommonText[797][4] .. "(" .. string.format("%02d:%02d", time.minute, time.second) .. ")")
				self.signStatusValue:setColor(COLOR[2])
				self.signBtn:setVisible(false)
				self.cancelSignBtn:setVisible(false)
				self.formationBtn:setVisible(false)
			else
				self.signBtn:setVisible(false)
				self.cancelSignBtn:setVisible(false)
				self.formationBtn:setVisible(false)
			end
		end
		--已报名人数
		self.signNumValue:setString(#PartyBattleMO.joinMember)
		self.signNumMax:setPosition(self.signNumValue:getPositionX() + self.signNumValue:getContentSize().width,self.signNumValue:getPositionY())

	elseif self.m_pageView:getPageIndex() == PARTY_BATTLE_VIEW_INDEX_COMBAT then
		if not self.battleStatusLab then return end
		if battleStatus.stage == 2 and battleStatus.cd > 0 then
			local time = ManagerTimer.time(battleStatus.cd)
			self.battleStatusLab:setString(CommonText[827][2] .. "(" .. string.format("%02d:%02d", time.minute, time.second) .. ")")
		else
			self.battleStatusLab:setString("")
		end
	end
	
end


function PartyBattleView:openJoinPartyView(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarParties(function()
		Loading.getInstance():unshow()
		require("app.dialog.PartyBJoinDialog").new():push()
		end,0)
end

function PartyBattleView:formationHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function openArmy(army)
		gdump(army,"PartyBattleView:formationHandler")
		local ReportArmyDetailView = require("app.view.ReportArmyDetailView")
		ReportArmyDetailView.new(army):push()
	end

	if PartyBattleMO.myArmy then
		openArmy(PartyBattleMO.myArmy)
		
	else
		Loading.getInstance():show()
		ArmyBO.asynGetArmy(function()
			Loading.getInstance():unshow()
			if PartyBattleMO.myArmy then
				openArmy(PartyBattleMO.myArmy)
			else
				
			end
		end)
	end
end

function PartyBattleView:signHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local ArmyView = require("app.view.ArmyView")
	local view = ArmyView.new(ARMY_VIEW_FOR_PARTYB):push()
end

function PartyBattleView:cancelSignHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBattleBO.asynWarCancel(function()
		Loading.getInstance():unshow()
		end)
end


function PartyBattleView:showCombatView(container)
	self.signStatusValue = nil
	local banner = display.newSprite(IMAGE_COMMON .. "bar_partyBattle.jpg", container:getContentSize().width / 2, container:getContentSize().height - 110):addTo(container)
	--规则按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local ruleBtn = MenuButton.new(normal, selected, nil, function()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.partyBattle):push()
		end):addTo(container)
	ruleBtn:setPosition(container:getContentSize().width - 50, container:getContentSize().height - 50)

	--tab按钮
	self.battleTabBtns = {}
	local tabPosX = {260,380,500}
	for index = 1,#CommonText[806] do
		local normal,selected
		if index == 1 then
			normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
	    	selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
		elseif index == 2 then
			normal = display.newSprite(IMAGE_COMMON .. "btn_41_selected.png")
	    	selected = display.newSprite(IMAGE_COMMON .. "btn_41_normal.png")
		elseif index == 3 then
			normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
	    	selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
	    	normal:setScaleX(-1)
	    	selected:setScaleX(-1)
		end

	    local tabBtn = MenuButton.new(normal, selected, nil, handler(self,self.showBattleProcess))
	    banner:addChild(tabBtn)
	    tabBtn:setPosition(tabPosX[index], 30)
	    tabBtn:setLabel(CommonText[806][index])
	    tabBtn:setTag(index)
	    self.battleTabBtns[#self.battleTabBtns + 1] = tabBtn
	end
	self.battleTabBtns[1]:selected()


	local tableBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBg:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, self:getBg():getContentSize().height - 480))
	tableBg:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tableBg:getContentSize().height / 2 - 220)
	self.tableBg = tableBg

	local posX = {45, 170, 340, 470}
	for index=1,#CommonText[807] do
		local labTit = ui.newTTFLabel({text = CommonText[807][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBg:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBg)
		labTit:setAnchorPoint(cc.p(0, 0.5))
	end
    
    local PartyBProcessTableView = require("app.scroll.PartyBProcessTableView")
	local view = PartyBProcessTableView.new(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height - 70)):addTo(tableBg)
	view:setPosition(0, 25)
	self.m_partyBProcessTableView = view
	self:updateRankView(1)


	local function chatCallback(tag, sender)
		ManagerSound.playNormalButtonSound()
		if ChatMO.showChat_ then
			require("app.view.ChatView").new():push()
		else
			require("app.view.ChatSearchView").new():push()
		end

		-- PartyBattleBO.parseSynReport()
		
	end
	-- 聊天按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	local chatBtn = MenuButton.new(normal, selected, nil, chatCallback):addTo(container)
	chatBtn:setPosition(60, 35)
	self.m_chatButton = chatBtn
	display.newSprite(IMAGE_COMMON.."info_bg_39.png"):addTo(banner):align(display.LEFT_CENTER,200,95):scaleTX(188)
	self.jifen = UiUtil.label(CommonText[20054]..PartyBattleBO.fortressJifen):addTo(banner):align(display.LEFT_CENTER,200,95)
	display.newSprite(IMAGE_COMMON.."info_bg_39.png"):addTo(banner):align(display.LEFT_CENTER,200,70):scaleTX(188)
	self.rank = UiUtil.label(CommonText[20055]..PartyBattleBO.fortressRank):addTo(banner):align(display.LEFT_CENTER,200,70)

	--查看战报
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local reportBtn = MenuButton.new(normal, selected, nil, handler(self,self.openReportDia)):addTo(container)
	reportBtn:setPosition(container:getContentSize().width / 2,35)
	reportBtn:setLabel(CommonText[808])
	reportBtn:setVisible(false)
	self.reportBtn = reportBtn


	--战斗状态
	local battleStatusLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
		x = container:getContentSize().width - 30, 
		y = 60, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	battleStatusLab:setAnchorPoint(cc.p(1, 0.5))
	self.battleStatusLab = battleStatusLab





	-- 聊天按钮
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	-- local aaa = MenuButton.new(normal, selected, nil, function()
	-- 		local chat = {channel = CHAT_TYPE_WORLD, sysId = 140, style = 1}
	-- 		ChatMO.addChat(chat.channel, chat.name, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, 0, nil, false)
	-- 		UiUtil.showHorn(chat)
	-- 		Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = chat})
	-- 	end):addTo(container)
	-- aaa:setPosition(160, 35)

	-- -- 聊天按钮
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	-- local aaa = MenuButton.new(normal, selected, nil, function()
	-- 		PartyBattleBO.parseSynWarState(nil, {state = 3})
	-- 	end):addTo(container)
	-- aaa:setPosition(260, 35)

	

	-- -- 聊天按钮
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	-- local aaa = MenuButton.new(normal, selected, nil, function()
	-- 		PartyBattleBO.parseSynWarState(nil, {state = 5})
	-- 	end):addTo(container)
	-- aaa:setPosition(360, 35)

	
end

function PartyBattleView:onChatUpdate(event)
	if self.m_pageView:getPageIndex() == PARTY_BATTLE_VIEW_INDEX_COMBAT then
		local num = ChatBO.getUnreadChatNum()
		if num > 0 then
			UiUtil.showTip(self.m_chatButton, num, 42, 42)
		else
			UiUtil.unshowTip(self.m_chatButton)
		end
	end
end

function PartyBattleView:showBattleProcess(tag, sender)
	for index=1,#self.battleTabBtns do
		local tabBtn = self.battleTabBtns[index]
		if tabBtn:getTag() == tag then
			tabBtn:selected()
		else
			tabBtn:unselected()
		end
	end
	self.reportBtn:setVisible(tag == PARTY_BATTLE_PROCESS_TYPE_PERSONAL)
	self:updateRankView(tag)
end

function PartyBattleView:getRank()
	Loading.getInstance():show()
	PartyBattleBO.getFortressRank(function(info)
			Loading.getInstance():unshow()
			self.jifen:setString(CommonText[20054]..PartyBattleBO.fortressJifen)
			self.rank:setString(CommonText[20055]..PartyBattleBO.fortressRank)
		end)
end

function PartyBattleView:updateRankView(tag)
	local data
	if tag == PARTY_BATTLE_PROCESS_TYPE_ALL then
		data = PartyBattleMO.processList.all
	elseif tag == PARTY_BATTLE_PROCESS_TYPE_PARTY then
		data = PartyBattleMO.processList.party
	else
		data = PartyBattleMO.processList.personal
	end
	if data and #data > 0 then 
		self.m_partyBProcessTableView:reloadData(tag)
		self:getRank()
		return 
	end
	Loading.getInstance():show()
	PartyBattleBO.asynWarReport(function()
		Loading.getInstance():unshow()
		self.m_partyBProcessTableView:reloadData(tag)
		self:getRank()
		end,tag)
end

function PartyBattleView:openReportDia(tag)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyBPersonalDialog").new(tag):push()

end

function PartyBattleView:showRankView(container)
	self.signStatusValue = nil
	self.battleStatusLab = nil
	local banner = display.newSprite(IMAGE_COMMON .. "bar_partyBattle.jpg", container:getContentSize().width / 2, container:getContentSize().height - 110):addTo(container)

	--tab按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
	normal:setScaleX(1.3)
    local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
    selected:setScaleX(1.3)
    local tabButtonWin = MenuButton.new(normal, selected, nil, handler(self,self.showBattleRank))
    banner:addChild(tabButtonWin)
    tabButtonWin:setPosition(285, 30)
    tabButtonWin:setLabel(CommonText[802][1])
    tabButtonWin:selected()
    tabButtonWin:setTag(1)
    self.tabButtonWin = tabButtonWin

    local normal = display.newSprite(IMAGE_COMMON .. "btn_12_normal.png")
    normal:setScaleX(-1.3)
    local selected = display.newSprite(IMAGE_COMMON .. "btn_12_selected.png")
    selected:setScaleX(-1.3)
    local tabButtonParty = MenuButton.new(normal, selected, nil, handler(self,self.showBattleRank))
    banner:addChild(tabButtonParty)
    tabButtonParty:setPosition(475, 30)
    tabButtonParty:setLabel(CommonText[802][2])
    tabButtonParty:unselected()
 	tabButtonParty:setTag(2)
 	self.tabButtonParty = tabButtonParty

 	--连胜排行
 	local tableBgWin = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBgWin:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, self:getBg():getContentSize().height - 480))
	tableBgWin:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBgWin:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tableBgWin:getContentSize().height / 2 - 220)
	self.tableBgWin = tableBgWin

	local posX = {45, 170, 320, 470}
	for index=1,#CommonText[804] do
		local labTit = ui.newTTFLabel({text = CommonText[804][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBgWin:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBgWin)
		labTit:setAnchorPoint(cc.p(0, 0.5))
	end

	--军团排行
	local tableBgParty = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_9.png"):addTo(container)
	tableBgParty:setPreferredSize(cc.size(self:getBg():getContentSize().width - 40, self:getBg():getContentSize().height - 480))
	tableBgParty:setCapInsets(cc.rect(80, 60, 1, 1))
	tableBgParty:setPosition(container:getContentSize().width / 2, container:getContentSize().height - tableBgParty:getContentSize().height / 2 - 220)
	self.tableBgParty = tableBgParty
	tableBgParty:setVisible(false)

	for index=1,#CommonText[805] do
		local labTit = ui.newTTFLabel({text = CommonText[805][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = posX[index], y = tableBgParty:getContentSize().height - 25, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(tableBgParty)
		labTit:setAnchorPoint(cc.p(0, 0.5))
	end

	self:showBattleRank(1)

	--连胜奖励
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardWinBtn = MenuButton.new(normal, selected, nil, handler(self,self.openRankAwards)):addTo(container)
	awardWinBtn:setPosition(container:getContentSize().width / 2 - 195,35)
	awardWinBtn:setLabel(CommonText[803][1])
	awardWinBtn:setTag(1)

	--奖励一览
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local awardBtn = MenuButton.new(normal, selected, nil, handler(self,self.openRankAwards)):addTo(container)
	awardBtn:setPosition(container:getContentSize().width / 2 + 195,35)
	awardBtn:setLabel(CommonText[803][2])
	awardBtn:setTag(2)
end

function PartyBattleView:showBattleRank(tag, sender)
	if tag == 1 then
		self.tabButtonWin:selected()
		self.tabButtonParty:unselected()
		self.tableBgWin:setVisible(true)
		self.tableBgParty:setVisible(false)
		Loading.getInstance():show()
		PartyBattleBO.asynWarWinRank(function()
			Loading.getInstance():unshow()
			self:updateRankWin()
			end)
		
	else
		self.tabButtonWin:unselected()
		self.tabButtonParty:selected()
		self.tableBgWin:setVisible(false)
		self.tableBgParty:setVisible(true)
		Loading.getInstance():show()
		PartyBattleBO.asynWarRank(function()
			Loading.getInstance():unshow()
			self:updateRankParty()
		end,0)
	end

end

function PartyBattleView:updateRankWin()
	local tableBgWin = self.tableBgWin
	if self.node_rankWin then
		tableBgWin:removeChild(self.node_rankWin, true)
	end

	self.node_rankWin = display.newNode():addTo(tableBgWin)

	if PartyBattleMO.myRankWin then
		------我的连胜排名
		local mybg_win = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self.node_rankWin)
		mybg_win:setPreferredSize(cc.size(tableBgWin:getContentSize().width - 50, 70))
		mybg_win:setPosition(tableBgWin:getContentSize().width / 2, tableBgWin:getContentSize().height - 80)
		
		local rankTitle
		if PartyBattleMO.myRankWin.rank > 0 then
			rankTitle = ArenaBO.createRank(PartyBattleMO.myRankWin.rank)
		else
			--未上榜
			rankTitle = ui.newTTFLabel({text = CommonText[768], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER})
			rankTitle:setColor(COLOR[6])
		end
		rankTitle:setPosition(40, 30)
		mybg_win:addChild(rankTitle)
		
		local nameLab = ui.newTTFLabel({text = PartyBattleMO.myRankWin.name, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 177, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(mybg_win)
		nameLab:setAnchorPoint(cc.p(0.5, 0.5))

		local numLab = ui.newTTFLabel({text = PartyBattleMO.myRankWin.winCount, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 336, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(mybg_win)
		numLab:setAnchorPoint(cc.p(0.5, 0.5))

		local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(PartyBattleMO.myRankWin.fight), font = "fnt/num_2.fnt"}):addTo(mybg_win)
		fightValue:setPosition(485,30)
		------我的连胜排名
	end
	
	------连胜排行tableView
	local PartyBWinRankTableView = require("app.scroll.PartyBWinRankTableView")
	local view
	if PartyBattleMO.myRankWin then
		view = PartyBWinRankTableView.new(cc.size(tableBgWin:getContentSize().width, tableBgWin:getContentSize().height - 140)):addTo(self.node_rankWin)
	else
		view = PartyBWinRankTableView.new(cc.size(tableBgWin:getContentSize().width, tableBgWin:getContentSize().height - 70)):addTo(self.node_rankWin)
	end
	
	view:setPosition(0, 25)
	view:reloadData()
	------连胜排行tableView
end

function PartyBattleView:updateRankParty()
	local tableBgParty = self.tableBgParty
	if self.node_rankParty then
		tableBgParty:removeChild(self.node_rankParty, true)
	end
	self.node_rankParty = display.newNode():addTo(tableBgParty)
	if PartyBattleMO.myRankParty then
		------我的军团排名
		local mybg_party = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self.node_rankParty)
		mybg_party:setPreferredSize(cc.size(tableBgParty:getContentSize().width - 50, 70))
		mybg_party:setPosition(tableBgParty:getContentSize().width / 2, tableBgParty:getContentSize().height - 80)
		
		local rankTitle = ArenaBO.createRank(PartyBattleMO.myRankParty.rank)
		rankTitle:setPosition(40, 30)
		mybg_party:addChild(rankTitle)
		
		local nameLab = ui.newTTFLabel({text = PartyBattleMO.myRankParty.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 177, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(mybg_party)
		nameLab:setAnchorPoint(cc.p(0.5, 0.5))

		local numLab = ui.newTTFLabel({text = PartyBattleMO.myRankParty.count, font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 336, y = 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(mybg_party)
		numLab:setAnchorPoint(cc.p(0.5, 0.5))

		local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(PartyBattleMO.myRankParty.fight), font = "fnt/num_2.fnt"}):addTo(mybg_party)
		fightValue:setPosition(485,30)
		------我的军团排名
	end
	

	------军团排行tableView
	local PartyBRankTableView = require("app.scroll.PartyBRankTableView")
	local view
	if PartyBattleMO.myRankParty then
		view = PartyBRankTableView.new(cc.size(tableBgParty:getContentSize().width, tableBgParty:getContentSize().height - 140)):addTo(self.node_rankParty)
	else
		view = PartyBRankTableView.new(cc.size(tableBgParty:getContentSize().width, tableBgParty:getContentSize().height - 70)):addTo(self.node_rankParty)
	end
	view:setPosition(0, 25)
	view:reloadData()
	------军团排行tableView
end



function PartyBattleView:openRankAwards(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyBAwardDialog").new(tag):push()
end


function PartyBattleView:onExit()
	PartyBattleView.super.onExit(self)

	if self.m_chatHandler then
		Notify.unregister(self.m_chatHandler)
		self.m_chatHandler = nil
	end

	if self.m_readChatHandler then
		Notify.unregister(self.m_readChatHandler)
		self.m_readChatHandler = nil
	end
end




return PartyBattleView