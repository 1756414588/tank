--
-- Author: gf
-- Date: 2015-09-11 12:19:27
--

local AllPartyView = class("AllPartyView", UiNode)

function AllPartyView:ctor(pageIdx)
	AllPartyView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_BOTTOM_TO_UP)
	self.pageIdx = pageIdx
	if not self.pageIdx then self.pageIdx = 1 end
end

function AllPartyView:onEnter()
	AllPartyView.super.onEnter(self)

	self:setTitle(CommonText[565][1])

	local function createDelegate(container, index)
		if index == 1 then  -- 军团列表
			self:showAllPartyList(container)
		elseif index == 2 then -- 创建军团
			self:showCreatParty(container)
		end
	end

	local function clickDelegate(container, index)
	end

	local pages = {CommonText[566][1],CommonText[566][2]}
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.pageIdx)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end

function AllPartyView:showAllPartyList(container)
	local PartyTableView = require("app.scroll.PartyTableView")
	local view = PartyTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 100 - 4)):addTo(container)
	view:setPosition(0, 100)
	view:reloadData()
	self.partyTableView = view

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(container)
	line:setPreferredSize(cc.size(view:getContentSize().width, line:getContentSize().height))
	line:setPosition(container:getContentSize().width / 2, view:getPositionY())

	local infoLab = ui.newTTFLabel({text = CommonText[568][1], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 30, y = line:getPositionY() - 20, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	infoLab:setAnchorPoint(cc.p(0, 0.5))

	

	local checkBox = CheckBox.new(nil, nil, handler(self, self.onCheckedChanged)):addTo(container)
	checkBox:setPosition(50,infoLab:getPositionY() - 50)
	checkBox:setChecked(PartyMO.allPartyList_type_ == 2)
	self.checkBox = checkBox

	local infoLab1 = ui.newTTFLabel({text = CommonText[568][2], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = checkBox:getPositionX() + checkBox:getContentSize().width / 2 + 20, y = checkBox:getPositionY(), color = COLOR[2], 
		align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	infoLab1:setAnchorPoint(cc.p(0, 0.5))


	local function onEdit(event, editbox)
	--    if eventType == "return" then
	--    end
    end
	local input_bg = IMAGE_COMMON .. "info_bg_16.png"

    local inputDesc = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(316, 40)}):addTo(container)
	inputDesc:setFontColor(COLOR[3])
	inputDesc:setFontSize(FONT_SIZE_TINY)
	inputDesc:setPosition(infoLab1:getPositionX() + 250, infoLab1:getPositionY())
	-- inputDesc:setText(CommonText[568][3])
	self.inputDesc = inputDesc

	local function clearEdit()
		self.inputDesc:setText("")
		self.m_pageView:setPageIndex(1)
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

function AllPartyView:showCreatParty(container)
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	bg:setPreferredSize(cc.size(container:getContentSize().width - 40, container:getContentSize().height - 100))
	bg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - bg:getContentSize().height / 2 - 20)

	--军团名称
	local info1 = ui.newTTFLabel({text = CommonText[569][1], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = 40, 
		y = bg:getContentSize().height - 30}):addTo(bg)
	info1:setAnchorPoint(cc.p(0,0.5))

	local function onEdit(event, editbox)
	   -- if eventType == "began" then
	   -- 		editbox:setText("")
	   -- end
    end

    local width = 316
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_BIG)

    local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(bg)
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(190, info1:getPositionY() - 60)

	local inputDesc = ui.newEditBox({x = 190, y = info1:getPositionY() - 60, size = cc.size(width, height), listener = onEdit}):addTo(bg)
    inputDesc:setFontColor(COLOR[3])
    inputDesc:setText(CommonText[569][2])
    self.inputDesc = inputDesc

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(bg)
	line:setPreferredSize(cc.size(bg:getContentSize().width - 40, line:getContentSize().height))
	line:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 135)

	--加入条件
	local info2 = ui.newTTFLabel({text = CommonText[569][3], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = 40, 
		y = info1:getPositionY() - 140}):addTo(bg)
	info2:setAnchorPoint(cc.p(0,0.5))

	self.m_joinCheckBoxs = {}
	for index = 1, 2 do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onJoinCheckedChanged)):addTo(bg)
		local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(bg)
		info:setAnchorPoint(cc.p(0,0.5))
		if index == 1 then
			checkBox:setPosition(180,info2:getPositionY())
		else
			checkBox:setPosition(180,info2:getPositionY() - 60)
		end
		checkBox.index = index
		info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width,checkBox:getPositionY())
		info:setString(CommonText[570][index])
		self.m_joinCheckBoxs[index] = checkBox
	end
	self.m_joinCheckBoxs[1]:setChecked(true)

	local line1 = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(bg)
	line1:setPreferredSize(cc.size(bg:getContentSize().width - 40, line:getContentSize().height))
	line1:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 270)

	--创建方式
	local info3 = ui.newTTFLabel({text = CommonText[569][4], font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[11],
		x = 40, 
		y = info2:getPositionY() - 140}):addTo(bg)
	info3:setAnchorPoint(cc.p(0,0.5))

	self.m_creatCheckBoxs = {}
	for index = 1, 2 do
		-- 改造保证的checkbox
		local checkBox = CheckBox.new(nil, nil, handler(self, self.onCreatCheckedChanged)):addTo(bg)
		if index == 1 then
			checkBox:setPosition(180,info3:getPositionY())
		else
			checkBox:setPosition(180,info3:getPositionY() - 60)
		end
		checkBox.index = index
		self.m_creatCheckBoxs[index] = checkBox
	end
	local resIds = {ITEM_KIND_COIN,RESOURCE_ID_STONE,RESOURCE_ID_IRON,RESOURCE_ID_OIL,RESOURCE_ID_COPPER,RESOURCE_ID_SILICON}
	local resNeed = {CREAT_PARTY_NEED_COIN,CREAT_PARTY_NEED_STONE,CREAT_PARTY_NEED_IRON,CREAT_PARTY_NEED_OIL,CREAT_PARTY_NEED_COPPER,CREAT_PARTY_NEED_SILICON}

	for index = 1, 6 do
		local icon
		if index == 1 then
			icon = UiUtil.createItemView(resIds[index])
		else
			icon = UiUtil.createItemView(ITEM_KIND_RESOURCE,resIds[index])
		end
		icon:setScale(0.4)
		icon:setPosition(250,info3:getPositionY() - 5 - (index - 1) * 60)
		local value = ui.newTTFLabel({text = UiUtil.strNumSimplify(resNeed[index]), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1],
			x = icon:getPositionX() + icon:getContentSize().width / 2 - 10, 
			y = icon:getPositionY()}):addTo(bg)
		value:setAnchorPoint(cc.p(0,0.5))
		bg:addChild(icon)
	end
	self.m_creatCheckBoxs[1]:setChecked(true)

	local info4 = ui.newTTFLabel({text = string.format(CommonText[569][5],CREAT_PARTY_LV), font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[2],
		x = 40, 
		y = 35}):addTo(container)
	info4:setAnchorPoint(cc.p(0,0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local creatBtn = MenuButton.new(normal, selected, nil, handler(self,self.creatPartyHandler)):addTo(container)
	creatBtn:setLabel(CommonText[569][6])
	creatBtn:setPosition(container:getContentSize().width - creatBtn:getContentSize().width / 2,info4:getPositionY())
end

function AllPartyView:creatPartyHandler(tag,sender)
	local type
    if self.m_joinCheckBoxs[1]:isChecked() then
    	type = 1
    else
    	type = 2
    end

    local applyType
    if self.m_creatCheckBoxs[1]:isChecked() then
    	applyType = 1
    else
    	applyType = 2
    end

	--判断等级
	if UserMO.level_ < CREAT_PARTY_LV then
		Toast.show(CommonText[572][1])
		return
	end
	--判断资源
	if PartyBO.canCreatParty(applyType) == false then
		Toast.show(CommonText[572][2])
		return
	end

	--判断名称
	local partyName = string.gsub(self.inputDesc:getText()," ","")
	if partyName == "" then
        Toast.show(CommonText[572][3])
        return
    end
    
    if WordMO.isSensitiveWords(partyName) == true then
    	Toast.show(CommonText[572][4])
    	return
    end

    local length = string.utf8len(partyName)

    if length < 2 or length > 6 then
        Toast.show(CommonText[569][2])
    	return
    end


	Loading.getInstance():show()
	PartyBO.asynCreatParty(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[572][5])
		self:pop()
		end, partyName, applyType ,type)
end

function AllPartyView:onCreatCheckedChanged(sender, isChecked)
	for index = 1,#self.m_creatCheckBoxs do
		if index == sender.index then
			self.m_creatCheckBoxs[index]:setChecked(true)
		else
			self.m_creatCheckBoxs[index]:setChecked(false)
		end
	end
end

function AllPartyView:onJoinCheckedChanged(sender, isChecked)
	for index = 1,#self.m_joinCheckBoxs do
		if index == sender.index then
			self.m_joinCheckBoxs[index]:setChecked(true)
		else
			self.m_joinCheckBoxs[index]:setChecked(false)
		end
	end
end

function AllPartyView:onCheckedChanged(sender, isChecked)
	gdump(isChecked,"AllPartyView:onCheckedChanged")
	if isChecked then
		PartyMO.allPartyList_type_ = 2
	else
		PartyMO.allPartyList_type_ = 1
	end
	Loading.getInstance():show()
	PartyBO.asynGetPartyRank(function()
		Loading.getInstance():unshow()
		end, 0, PartyMO.allPartyList_type_)
end

function AllPartyView:showSearchResult(party,container)
	self.partyTableView:setVisible(false)

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

function AllPartyView:showPartyDetail(party)
	Loading.getInstance():show()
	PartyBO.asynGetParty(function(data)
		Loading.getInstance():unshow()
		require("app.dialog.PartyDetailDialog").new(data):push()
		end, party.partyId)
end


function AllPartyView:searchHandler(tag,sender)
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


function AllPartyView:onExit()
	PartyBO.clearAllParty()
end





return AllPartyView