--
-- Author: gf
-- Date: 2015-09-17 13:40:25
-- 军团管理

local ConfirmDialog = require("app.dialog.ConfirmDialog")

local PartyManageView = class("PartyManageView", UiNode)

function PartyManageView:ctor(pageIndex)
	PartyManageView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
	if not pageIndex then
		self.pageIndex = 1
	else
		self.pageIndex = pageIndex
	end
	
end

function PartyManageView:onEnter()
	PartyManageView.super.onEnter(self)

	self:setTitle(CommonText[620][1])
	self.m_updatePartyInfo = Notify.register(LOCAL_PARTY_OPTION_UPDATE_EVENT, handler(self, self.updatePartyInfo))
	self.m_updateMember = Notify.register(LOCAL_PARTY_MEMBER_UPDATE_EVENT, handler(self, self.updatePartyInfo))
	self.m_applyHandler = Notify.register(LOCAL_PARTY_APPLY_UPDATE_EVENT, handler(self, self.updateTip))

	local function createDelegate(container, index)
		if index == 1 then
			self.applyJudgeBtn = nil
			Loading.getInstance():show()
			PartyBO.asynGetParty(function()
				Loading.getInstance():unshow()
				self:showPartyInfo(container)
			end, 0)
			
		elseif index == 2 then
			Loading.getInstance():show()
			PartyBO.asynGetPartyMember(function(type)
				Loading.getInstance():unshow()
				self:showPartyMember(container,type)
				end,1)
		elseif index == 3 then
			Loading.getInstance():show()
			PartyBO.asynGetPartyMember(function(type)
				Loading.getInstance():unshow()
				self:showPartyMember(container,type)
				end,2)
		elseif index == 4 then
			Loading.getInstance():show()
			PartyBO.asynGetPartyRank(function()
				Loading.getInstance():unshow()
				self:showPartyList(container)
				end, 0, 1)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[620][1],CommonText[620][2],CommonText[620][3],CommonText[620][4]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.pageIndex)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

end

function PartyManageView:showPartyInfo(container)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	btm:setPreferredSize(cc.size(container:getContentSize().width - 40, 640))
	btm:setPosition(container:getContentSize().width / 2, container:getContentSize().height - btm:getContentSize().height / 2 - 10)
	local party = PartyMO.partyData_
	for index = 1,#CommonText[571] - 1 do
		local labTit = ui.newTTFLabel({text = CommonText[571][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 30, y = btm:getContentSize().height - 30 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then
			value:setString(party.partyName)
		elseif index == 2 then
			value:setString(party.legatusName)
		elseif index == 3 then
			if not table.isexist(party, "rank") then party.rank = 0 end
			value:setString(party.rank)
			value:setColor(COLOR[2])
		elseif index == 4 then
			value:setString(party.partyLv)
		elseif index == 5 then
			value:setString(party.member .. "/" .. PartyMO.queryParty(party.partyLv).partyNum)
		elseif index == 6 then
			value:setString(CommonText[570][party.applyType])
		elseif index == 7 then
			local applyNeedString = ""
			-- gdump(party,"partyparty")
			if party.applyLv == 0 and party.applyFight == 0 then
				applyNeedString = CommonText[575][1]
			elseif party.applyLv > 0 and party.applyFight > 0 then
				applyNeedString = string.format(CommonText[575][2],party.applyLv) .. "  " .. string.format(CommonText[575][3],UiUtil.strNumSimplify(party.applyFight))
			else
				if party.applyLv > 0 then
					applyNeedString = string.format(CommonText[575][2],party.applyLv)
				else
					applyNeedString = string.format(CommonText[575][3],UiUtil.strNumSimplify(party.applyFight))
				end
			end
			value:setString(applyNeedString)
			value:setColor(COLOR[2])
		end
	end

	local gotrendView = function()
		ManagerSound.playNormalButtonSound()
		Loading.getInstance():show()
		PartyBO.asynGetPartyTrend(function()
			Loading.getInstance():unshow()
			require("app.view.PartyTrendView").new():push()
			end, 0,PARTY_TREND_TYPE_1)
	end
	--情报按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local trendBtn = MenuButton.new(normal, selected, nil, gotrendView):addTo(btm)
	trendBtn:setPosition(btm:getContentSize().width - 80,btm:getContentSize().height - 50)
	trendBtn:setLabel(CommonText[622][1])

	local sloganBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(container)
	sloganBg:setPreferredSize(cc.size(btm:getContentSize().width - 40, 250))
	sloganBg:setCapInsets(cc.rect(130, 40, 1, 1))
	sloganBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - sloganBg:getContentSize().height - 200)

	local titBg = display.newSprite(IMAGE_COMMON .. "info_bg_28.png", 
		sloganBg:getContentSize().width / 2, sloganBg:getContentSize().height):addTo(sloganBg)

	local sloganLab = ui.newTTFLabel({text = CommonText[621], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = titBg:getContentSize().width / 2, y = titBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titBg)


	-- local sloganValue = ui.newTTFLabel({text = party.innerSlogan, font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 	x = sloganBg:getContentSize().width / 2, y = sloganBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(sloganBg)
	
	local sloganValue = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 0, y = sloganBg:getContentSize().height - 30, color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(sloganBg:getContentSize().width - 20, 150)}):addTo(sloganBg)
	sloganValue:setAnchorPoint(cc.p(0, 1))
	sloganValue:setPosition(10, sloganBg:getContentSize().height - 30)
	if party.innerSlogan and party.innerSlogan ~= "" then
		sloganValue:setString(party.innerSlogan)
		sloganValue:setColor(COLOR[1])
	else
		sloganValue:setString(CommonText[740])
		sloganValue:setColor(COLOR[11])
	end
	

	local saveSloganhandler = function()
		ManagerSound.playNormalButtonSound()
		local slogan = string.gsub(sloganValue:getString()," ","")
		local length = string.utf8len(slogan)

	    if WordMO.filterSensitiveWords(slogan) == true then
	    	Toast.show(CommonText[718])
	    	return
	    end
	    if length > 30 then
	    	Toast.show(string.format(CommonText[719],30))
	    	return
	    end
		Loading.getInstance():show()
		PartyBO.asynSloganParty(function()
			Loading.getInstance():unshow()
			self.saveSloganBtn:setVisible(false)
			end,1,slogan)
	end
	--保存公告按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local saveSloganBtn = MenuButton.new(normal, selected, nil, saveSloganhandler):addTo(sloganBg)
	saveSloganBtn:setPosition(sloganBg:getContentSize().width - 70,50)
	saveSloganBtn:setLabel(CommonText[622][2])
	saveSloganBtn:setVisible(false)
	self.saveSloganBtn = saveSloganBtn

	local function onEdit1(event, editbox)

	   if event == "return" then
	   		-- gdump(editbox:getText(),"editbox")
	   		sloganValue:setString(editbox:getText())
	   		editbox:setText("")
	   		editbox:setVisible(true)
	   		if sloganValue:getString() ~= "" and sloganValue:getString() ~= CommonText[740] then
				sloganValue:setColor(COLOR[1])
				saveSloganBtn:setVisible(true)
			else
				sloganValue:setString(CommonText[740])
				sloganValue:setColor(COLOR[11])
				saveSloganBtn:setVisible(false)
			end
	   		
	   elseif event == "began" then
	   		editbox:setVisible(false)
	   		if sloganValue:getString() == CommonText[740] then
	   			editbox:setText("")
	   		else
	   			editbox:setText(sloganValue:getString())
	   		end
	   		
	   end
    end

	local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(sloganBg:getContentSize().width, 150)}):addTo(sloganBg)
	inputContent:setFontColor(COLOR[1])
	inputContent:setFontSize(FONT_SIZE_SMALL)
	inputContent:setPosition(sloganBg:getContentSize().width / 2, sloganBg:getContentSize().height / 2 + 20)
	inputContent:setEnabled(PartyMO.myJob >= PARTY_JOB_OFFICAIL)
	--职位编辑按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local jobEditBtn = MenuButton.new(normal, selected, nil, handler(self,self.jobEditHandler)):addTo(btm)
	jobEditBtn:setPosition(btm:getContentSize().width / 2 - 210,40)
	jobEditBtn:setLabel(CommonText[622][3])
	jobEditBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	--编辑按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local optionEditBtn = MenuButton.new(normal, selected, nil, handler(self,self.optionEditBtn)):addTo(btm)
	optionEditBtn:setPosition(btm:getContentSize().width / 2 - 70,40)
	optionEditBtn:setLabel(CommonText[622][4])
	optionEditBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	--军团招募
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local recruitBtn = MenuButton.new(normal, selected, nil, handler(self,self.recruitHandler)):addTo(btm)
	recruitBtn:setPosition(btm:getContentSize().width / 2 + 70,40)
	recruitBtn:setLabel(CommonText[622][5])
	recruitBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	--军团聊天
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local chatBtn = MenuButton.new(normal, selected, nil, handler(self,self.chatHandler)):addTo(btm)
	chatBtn:setPosition(btm:getContentSize().width / 2 + 210,40)
	chatBtn:setLabel(CommonText[622][6])
	chatBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)


	--退出军团按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local quitBtn = MenuButton.new(normal, selected, nil, handler(self,self.quitHandler)):addTo(btm)
	quitBtn:setPosition(btm:getContentSize().width / 2 - 210,40)
	quitBtn:setLabel(CommonText[622][10])
	quitBtn:setVisible(PartyMO.myJob < PARTY_JOB_MASTER)


	--军团邮件
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local mailBtn = MenuButton.new(normal, selected, nil, handler(self,self.mailHandler)):addTo(btm)
	mailBtn:setPosition(btm:getContentSize().width / 2 - 200,-60)
	mailBtn:setLabel(CommonText[622][7])
	mailBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	--军团审批
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local applyJudgeBtn = MenuButton.new(normal, selected, nil, handler(self,self.applyJudgeHandler)):addTo(btm)
	applyJudgeBtn:setPosition(btm:getContentSize().width / 2,-60)
	applyJudgeBtn:setLabel(CommonText[622][8])
	applyJudgeBtn:setVisible(PartyMO.myJob >= PARTY_JOB_OFFICAIL)
	self.applyJudgeBtn = applyJudgeBtn


	--军团驻地
	local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local stationBtn = MenuButton.new(normal, selected, nil, handler(self,self.stationHandler)):addTo(btm)
	stationBtn:setPosition(btm:getContentSize().width / 2 + 200,-60)
	stationBtn:setLabel(CommonText[622][9])
	-- stationBtn:setVisible(PartyMO.myJob > PARTY_JOB_OFFICAIL)

	self:updateTip()
end

function PartyManageView:jobEditHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
		PartyBO.asynPartyJobCount(function()
			Loading.getInstance():unshow()
			require("app.dialog.PartyJobEditDialog").new():push()
			end)
end

function PartyManageView:optionEditBtn(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyOptionDialog").new():push()
end

function PartyManageView:recruitHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynPartyRecruit(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[715])
		end)
end

function PartyManageView:chatHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local ChatView = require("app.view.ChatView")
	ChatView.new(CHAT_TYPE_PARTY):push()
end

function PartyManageView:quitHandler()
	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(CommonText[623], function()
			Loading.getInstance():show()
			PartyBO.asynQuitParty(function()
				Loading.getInstance():unshow()
				end)

		end):push()
end

function PartyManageView:mailHandler()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.MailSendDialog").new(nil,MAIL_SEND_TYPE_PARTY):push()
end

function PartyManageView:applyJudgeHandler()
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynPartyApplyList(function(list)
			Loading.getInstance():unshow()
			require("app.dialog.PartyApplyJudgeDialog").new():push()
		end)
end

function PartyManageView:stationHandler()
	ManagerSound.playNormalButtonSound()
	UiDirector.pop()
end

function PartyManageView:showPartyList(container)
	--我的军团
	self:showMyParty(container)

	local PartyTableView = require("app.scroll.PartyTableView")
	local view = PartyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 205 - 4)):addTo(container)
	view:setPosition(0, 95)
	view:reloadData()
	self.partyTableView = view

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(container)
	line:setPreferredSize(cc.size(view:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, view:getPositionY())

	local infoLab = ui.newTTFLabel({text = CommonText[568][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 40, y = line:getPositionY() - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0, 0.5))


	local function onEdit(event, editbox)
	--    if eventType == "return" then
	--    end
    end
	local input_bg = IMAGE_COMMON .. "info_bg_16.png"

    local inputDesc = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(450, 40)}):addTo(container)
	inputDesc:setFontColor(COLOR[3])
	inputDesc:setFontSize(FONT_SIZE_TINY)
	inputDesc:setPosition(40 + inputDesc:getContentSize().width / 2, infoLab:getPositionY() - 50)
	self.inputDesc = inputDesc

	local function clearEdit()
		ManagerSound.playNormalButtonSound()
		self.inputDesc:setText("")
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_del_selected.png")
	local delBtn = MenuButton.new(normal, selected, nil, clearEdit):addTo(inputDesc)
	delBtn:setPosition(inputDesc:getContentSize().width - 30,inputDesc:getContentSize().height / 2)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local searchBtn = MenuButton.new(normal, selected, nil, handler(self,self.searchHandler)):addTo(container)
	searchBtn.container = container
	searchBtn:setPosition(inputDesc:getPositionX() + inputDesc:getContentSize().width / 2 + 50,inputDesc:getPositionY())
end

function PartyManageView:showMyParty(container)
	local myPartyNode = display.newNode():addTo(container)
	self.myPartyNode = myPartyNode

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(myPartyNode)
	bg:setPreferredSize(cc.size(607, 105))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 60)
	local party = PartyMO.myPartyRank
	local rankTitle = ArenaBO.createRank(party.rank)
	rankTitle:setPosition(45, bg:getContentSize().height / 2)
	bg:addChild(rankTitle)
	
	local name = ui.newTTFLabel({text = CommonText[567][1] .. party.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local levelLab = ui.newTTFLabel({text = CommonText[567][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))

	local levelValue = ui.newTTFLabel({text = party.partyLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = levelLab:getPositionX() + levelLab:getContentSize().width, y = levelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	local fightLab = ui.newTTFLabel({text = CommonText[567][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	fightLab:setAnchorPoint(cc.p(0, 0.5))

	local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(party.fight), font = "fnt/num_2.fnt"}):addTo(bg)
	fightValue:setPosition(fightLab:getPositionX() + fightLab:getContentSize().width + fightValue:getContentSize().width / 2,fightLab:getPositionY())
	
	local numLab = ui.newTTFLabel({text = CommonText[567][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 + 20, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	local numValue = ui.newTTFLabel({text = party.member .. "/" .. PartyMO.queryParty(party.partyLv).partyNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	nodeTouchEventProtocol(bg, function(event) self:showPartyDetail(party) end, nil, nil, true)
end

function PartyManageView:searchHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local nick = string.gsub(self.inputDesc:getText()," ","")
	if nick == "" then
        Toast.show(CommonText[573])
        return
    end
    Loading.getInstance():show()
	PartyBO.asynSeachParty(function(party)
			Loading.getInstance():unshow()
			if party then
				self:showSearchResult(party,sender.container)
			end 
		end,nick)
end

function PartyManageView:showSearchResult(party,container)
	self.partyTableView:setVisible(false)
	self.myPartyNode:setVisible(false)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(607, 105))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 60)

	local rankTitle = ArenaBO.createRank(party.rank)
	rankTitle:setPosition(45, bg:getContentSize().height / 2)
	bg:addChild(rankTitle)
	
	local name = ui.newTTFLabel({text = CommonText[567][1] .. party.partyName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 + 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local levelLab = ui.newTTFLabel({text = CommonText[567][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))

	local levelValue = ui.newTTFLabel({text = party.partyLv, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = levelLab:getPositionX() + levelLab:getContentSize().width, y = levelLab:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	local fightLab = ui.newTTFLabel({text = CommonText[567][4], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 110, y = bg:getContentSize().height / 2 - 30, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	fightLab:setAnchorPoint(cc.p(0, 0.5))

	local fightValue = ui.newBMFontLabel({text = UiUtil.strNumSimplify(party.fight), font = "fnt/num_2.fnt"}):addTo(bg)
	fightValue:setPosition(fightLab:getPositionX() + fightLab:getContentSize().width + fightValue:getContentSize().width / 2,fightLab:getPositionY())
	
	local numLab = ui.newTTFLabel({text = CommonText[567][3], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 + 20, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	
	local numValue = ui.newTTFLabel({text = party.member .. "/" .. PartyMO.queryParty(party.partyLv).partyNum, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = bg:getContentSize().width - 60, y = bg:getContentSize().height / 2 - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)

	nodeTouchEventProtocol(bg, function(event) self:showPartyDetail(party) end, nil, nil, true)
end

function PartyManageView:showPartyDetail(party)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynGetParty(function(data)
		Loading.getInstance():unshow()
		require("app.dialog.PartyDetailDialog").new(data):push()
		end, party.partyId)
end

function PartyManageView:showPartyMember(container,type)
	local PartyMemberTableView = require("app.scroll.PartyMemberTableView")
	local view = PartyMemberTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 30),type):addTo(container)
	view:setPosition(0, 20)
	view:reloadData()
end

function PartyManageView:updatePartyInfo()
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
end

function PartyManageView:updateTip()
	if self.m_pageView and self.m_pageView:getPageIndex() == 1 and PartyMO.myJob >= PARTY_JOB_OFFICAIL and self.applyJudgeBtn then
		local applyNum = PartyMO.partyApplyList_num
		if applyNum > 0 then
			UiUtil.showTip(self.applyJudgeBtn, applyNum, 170, 70)
		else
			UiUtil.unshowTip(self.applyJudgeBtn)
		end
	end 
end

function PartyManageView:onExit()
	PartyManageView.super.onExit(self)
	if self.m_updatePartyInfo then
		Notify.unregister(self.m_updatePartyInfo)
		self.m_updatePartyInfo = nil
	end

	if self.m_updateMember then
		Notify.unregister(self.m_updateMember)
		self.m_updateMember = nil
	end

	if self.m_applyHandler then
		Notify.unregister(self.m_applyHandler)
		self.m_applyHandler = nil
	end

	
end

return PartyManageView