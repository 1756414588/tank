--
-- Author: gf
-- Date: 2015-11-05 18:43:12
--
local GMMailAwardTableView = class("GMMailAwardTableView", TableView)

function GMMailAwardTableView:ctor(size)
	GMMailAwardTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 110)
	self.m_awards = GMBO.getAwards()
end

function GMMailAwardTableView:onEnter()
	GMMailAwardTableView.super.onEnter(self)
	self.m_updateListHandler = Notify.register(LOCAL_GM_UPDATE_EVENT, handler(self, self.onUpgradeUpdate))
end

function GMMailAwardTableView:numberOfCells()
	return #self.m_awards
end

function GMMailAwardTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function GMMailAwardTableView:createCellAtIndex(cell, index)
	GMMailAwardTableView.super.createCellAtIndex(self, cell, index)

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(580, 100))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local name = ui.newTTFLabel({text = index, font = G_FONT, size = FONT_SIZE_HUGE, x = 30, y = 50, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	name:setAnchorPoint(cc.p(0, 0.5))

	local awards = self.m_awards[index]
	local awardCount
	if #awards > 5 then
		awardCount = 5
	else
		awardCount = #awards
	end
	for j=1,awardCount do
		local award = awards[j]
		local itemView = UiUtil.createItemView(award.type, award.id, {count = award.count})
		itemView:setScale(0.7)
		itemView:setPosition(100 + itemView:getContentSize().width * 0.7 / 2 + (j - 1) * 80,bg:getContentSize().height / 2)
		cell:addChild(itemView)
		UiUtil.createItemDetailButton(itemView,cell,true)
	end
	
	--删除按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	local delBtn = CellMenuButton.new(normal, selected, nil, handler(self, self.onDelhandler))
	delBtn.idx = index
	cell:addButton(delBtn, self.m_cellSize.width - 80, self.m_cellSize.height / 2)

	return cell
end

function GMMailAwardTableView:onDelhandler(tag,sender)
	local oldAwards = GMBO.getAwards()
	table.remove(oldAwards,sender.idx)
	GMBO.saveAwards(function()
		Toast.show("删除成功!")
		end,oldAwards)
end

function GMMailAwardTableView:onUpgradeUpdate()
	self.m_awards = GMBO.getAwards()
	self:reloadData()
end

function GMMailAwardTableView:onExit()
	GMMailAwardTableView.super.onExit(self)
	if self.m_updateListHandler then
		Notify.unregister(self.m_updateListHandler)
		self.m_updateListHandler = nil
	end

end

----------------------------------------------------------------------------------------------------------------------------

local ConfirmDialog = require("app.dialog.ConfirmDialog")
local GMToolView = class("GMToolView", UiNode)

function GMToolView:ctor(buildingId)
	GMToolView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function GMToolView:onEnter()
	GMToolView.super.onEnter(self)

	self:setTitle(CommonText[712])

	

	local function createDelegate(container, index)
		if index == 1 then  
			self:showChatTool(container)
		elseif index == 2 then 
			self:showMailTool(container)
		end
	end

	local function clickDelegate(container, index)
		
	end

	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, CommonText[732], {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, self.m_pageView:getPositionY() + self.m_pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)
end


function GMToolView:showMailTool(container)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(container, -1)
	btm:setPreferredSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	btm:setPosition(container:getContentSize().width / 2, container:getContentSize().height / 2 - 6)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(btm)
   	line:setPreferredSize(cc.size(btm:getContentSize().width - 60, line:getContentSize().height))
   	line:setPosition(btm:getContentSize().width / 2, 150)

   	self.m_checkBoxs = {}
   	for index = 1, #GM_MAIL_SEND_TYPE do
		local checkBox = CheckBox.new(nil, nil, handler(self, self.checkedChanged)):addTo(btm)
		local info = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, 
		color = COLOR[1]}):addTo(btm)
		info:setAnchorPoint(cc.p(0,0.5))
		checkBox:setPosition(60 + (index - 1) * 150,btm:getContentSize().height - 125)
		checkBox.index = index
		info:setPosition(checkBox:getPositionX() + checkBox:getContentSize().width / 2,checkBox:getPositionY())
		--屏蔽全服和在线选项
		if index == 3 then
			checkBox:setEnabled(true)
		else
			checkBox:setEnabled(false)
		end
		info:setString(GM_MAIL_SEND_TYPE[index].name)
		self.m_checkBoxs[index] = checkBox
	end
	self.m_checkBoxs[3]:setChecked(true)
	self.sendType = 3

	local nameLab = ui.newTTFLabel({text = CommonText[550][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = btm:getContentSize().height - 180, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	nameLab:setAnchorPoint(cc.p(0, 0.5))

	local input_bg = IMAGE_COMMON .. "info_bg_15.png"

    local inputDesc = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(450, 50)}):addTo(btm)
	inputDesc:setFontColor(COLOR[3])
	inputDesc:setFontSize(FONT_SIZE_TINY)
	inputDesc:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + inputDesc:getContentSize().width / 2, nameLab:getPositionY())

	self.inputDesc = inputDesc

	local view = GMMailAwardTableView.new(cc.size(btm:getContentSize().width - 20, btm:getContentSize().height - 505 - 4)):addTo(btm)
	view:setPosition(10, 290)
	view:reloadData()



	local awardLab = ui.newTTFLabel({text = "奖励ID", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = 200, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	awardLab:setAnchorPoint(cc.p(0, 0.5))

	local input_bg = IMAGE_COMMON .. "info_bg_15.png"

    local inputAwardId = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(100, 50)}):addTo(btm)
	inputAwardId:setFontColor(COLOR[3])
	inputAwardId:setFontSize(FONT_SIZE_TINY)
	inputAwardId:setPosition(awardLab:getPositionX() + awardLab:getContentSize().width + inputAwardId:getContentSize().width / 2, awardLab:getPositionY())

	self.inputAwardId = inputAwardId

	local moldidLab = ui.newTTFLabel({text = "moldId:", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 250, y = 200, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	moldidLab:setAnchorPoint(cc.p(0, 0.5))

	local input_bg = IMAGE_COMMON .. "info_bg_15.png"

    local inputMoldidLab = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(100, 50)}):addTo(btm)
	inputMoldidLab:setFontColor(COLOR[3])
	inputMoldidLab:setFontSize(FONT_SIZE_TINY)
	inputMoldidLab:setPosition(moldidLab:getPositionX() + moldidLab:getContentSize().width + inputAwardId:getContentSize().width / 2, moldidLab:getPositionY())

	self.inputMoldidLab = inputMoldidLab



	local contentLab = ui.newTTFLabel({text = "邮件内容:", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = 250, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
	contentLab:setAnchorPoint(cc.p(0, 0.5))

	local input_bg = IMAGE_COMMON .. "info_bg_15.png"

    local inputContent = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(500, 50)}):addTo(btm)
	inputContent:setFontColor(COLOR[3])
	inputContent:setFontSize(FONT_SIZE_TINY)
	inputContent:setPosition(contentLab:getPositionX() + contentLab:getContentSize().width + inputContent:getContentSize().width / 2, contentLab:getPositionY())

	self.inputContent = inputContent

	for index=1,#CommonText[741] do
		local lab = ui.newTTFLabel({text = CommonText[741][index], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 250, y = 150 + (index - 1) * -30, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		lab:setAnchorPoint(cc.p(0, 0.5))
	end

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local sendBtn = MenuButton.new(normal, selected, nil, handler(self,self.sendHandler)):addTo(container)
	sendBtn:setPosition(container:getContentSize().width / 2 + 200,90)
	sendBtn:setLabel(CommonText[553][2])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local previewBtn = MenuButton.new(normal, selected, nil, handler(self,self.previewHandler)):addTo(container)
	previewBtn:setPosition(container:getContentSize().width / 2 + 200,10)
	previewBtn:setLabel("邮件预览")


	--邮件奖励维护
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local awardBtn = MenuButton.new(normal, selected, nil, handler(self,self.awardsHandler)):addTo(container)
	awardBtn:setPosition(container:getContentSize().width / 2 - 200,10)
	awardBtn:setLabel("奖励维护")
end

function GMToolView:awardsHandler(tag, sender)
	require_ex("app.dialog.GMAwardsDialog").new():push()
end

function GMToolView:showChatTool(container)
	local nameLab = ui.newTTFLabel({text = CommonText[734], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = container:getContentSize().height - 180, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	nameLab:setAnchorPoint(cc.p(0, 0.5))

	local input_bg = IMAGE_COMMON .. "info_bg_15.png"

    local inputDesc = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(450, 50)}):addTo(container)
	inputDesc:setFontColor(COLOR[3])
	inputDesc:setFontSize(FONT_SIZE_TINY)
	inputDesc:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + inputDesc:getContentSize().width / 2, nameLab:getPositionY())

	self.inputDesc = inputDesc

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local setTopupBtn = MenuButton.new(normal, selected, nil, handler(self,self.clearMailHandler)):addTo(container)
	setTopupBtn:setPosition(container:getContentSize().width / 2 + 200,inputDesc:getPositionY() - 60)
	setTopupBtn:setLabel(CommonText[733][6])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local kickBtn = MenuButton.new(normal, selected, nil, handler(self,self.gagHandler)):addTo(container)
	kickBtn:setPosition(container:getContentSize().width / 2 - 200,90)
	kickBtn:setLabel(CommonText[733][3])
	kickBtn:setTag(3)
	
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local gagBtn = MenuButton.new(normal, selected, nil, handler(self,self.gagHandler)):addTo(container)
	gagBtn:setPosition(container:getContentSize().width / 2 + 200,90)
	gagBtn:setLabel(CommonText[733][1])
	gagBtn:setTag(1)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local noGagBtn = MenuButton.new(normal, selected, nil, handler(self,self.gagHandler)):addTo(container)
	noGagBtn:setPosition(container:getContentSize().width / 2,90)
	noGagBtn:setLabel(CommonText[733][2])
	noGagBtn:setTag(2)


	

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local setVipBtn = MenuButton.new(normal, selected, nil, handler(self,self.setVipHandler)):addTo(container)
	setVipBtn:setPosition(container:getContentSize().width / 2 - 200,200)
	setVipBtn:setLabel(CommonText[733][4])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local setTopupBtn = MenuButton.new(normal, selected, nil, handler(self,self.setTopupHandler)):addTo(container)
	setTopupBtn:setPosition(container:getContentSize().width / 2 + 100,200)
	setTopupBtn:setLabel(CommonText[733][5])


	

	local inputVip = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(150, 50)}):addTo(container)
	inputVip:setFontColor(COLOR[3])
	inputVip:setFontSize(FONT_SIZE_TINY)
	inputVip:setPosition(setVipBtn:getPositionX() + setVipBtn:getContentSize().width / 2 + inputVip:getContentSize().width / 2, 200)

	self.inputVip = inputVip
end

function GMToolView:checkedChanged(sender, isChecked)
	for index = 1,#self.m_checkBoxs do
		if index == sender.index then
			self.m_checkBoxs[index]:setChecked(true)
			self.sendType = index
		else
			self.m_checkBoxs[index]:setChecked(false)
		end
	end
end

function GMToolView:sendHandler(tag,sender)
	local mail = {
		keyId = 0,
		type = 4,
		state = 3,
		time = 0,
		contont = ""
	}
	

	local moldid = string.gsub(self.inputMoldidLab:getText(), " ", "")
	if moldid ~= "" then
		moldid = tonumber(moldid)
		if moldid > 0 then
			if moldid >= 35 and moldid <= 37 or moldid == 41 or moldid == 43 then
				mail.moldId = moldid
			else
				Toast.show(CommonText[746])
				return
			end
		end
	else
		Toast.show(CommonText[745])
		return
	end

	print(moldid,"moldid")
	-- if moldid ~= 41 then
		
	-- end
	local awards = GMBO.getAwards()
	local awardId = string.gsub(self.inputAwardId:getText(), " ", "")
	if awardId ~= "" then
		awardId = tonumber(awardId)
		if awardId > 0 and awards[awardId] then
			mail.award = awards[awardId]
		else
			Toast.show(CommonText[743])
			return
		end
	else
		-- Toast.show(CommonText[744])
		-- return
	end

	local content = string.gsub(self.inputContent:getText(), " ", "")

	if (moldid == 35 or moldid == 41 or moldid == 43) and content == "" then
		Toast.show(CommonText[742])
		return
	end
	mail.contont = content

	local str = GM_MAIL_SEND_TYPE[self.sendType].str
	if self.sendType == 3 then
		local nicks = string.gsub(self.inputDesc:getText(), " ", "")
		if nicks == "" then
			Toast.show(CommonText[554][2])
			return
		end
		str = string.format(str,nicks)
	elseif self.sendType == 4 then
		local platName = string.gsub(self.inputDesc:getText(), " ", "")
		if platName == "" then
			Toast.show(CommonText[782])
			return
		end
		str = string.format(str,platName)
	end

	dump({str = str,mail = mail},"GMMAIL CONTENT:")

	ConfirmDialog.new("确认发送邮件吗？", function()
				GMBO.asynSendMail(function()
					end,str,mail)
		end):push()
end

function GMToolView:previewHandler(tag,sender)
	local mail = {
		keyId = 0,
		type = 4,
		state = 3,
		time = 0,
		contont = "",
		sendName = "系统邮件"
	}
	

	local moldid = string.gsub(self.inputMoldidLab:getText(), " ", "")
	if moldid ~= "" then
		moldid = tonumber(moldid)
		if moldid > 0 then
			if moldid >= 35 and moldid <= 37 or moldid == 41 or moldid == 43 then
				mail.moldId = moldid
			else
				Toast.show(CommonText[746])
				return
			end
		end
	else
		Toast.show(CommonText[745])
		return
	end


	local awards = GMBO.getAwards()
	local awardId = string.gsub(self.inputAwardId:getText(), " ", "")
	if awardId ~= "" then
		awardId = tonumber(awardId)
		if awardId > 0 and awards[awardId] then
			mail.award = awards[awardId]
		else
			Toast.show(CommonText[743])
			return
		end
	else
		-- if moldid ~= 41 then
		-- 	Toast.show(CommonText[744])
		-- 	return
		-- end
		
	end

	local mailInfo = MailMO.queryMail(mail.moldId)

	local content = string.gsub(self.inputContent:getText(), " ", "")
	if (moldid == 35 or moldid == 41 or moldid == 43) and content == "" then
		Toast.show(CommonText[742])
		return
	end
	if moldid == 35 then
		mail.contont = string.format(mailInfo.mcontent,content)
	elseif moldid == 41 or moldid == 43 then
		mail.contont = content
	else
		mail.contont = mailInfo.mcontent
	end


	local str = GM_MAIL_SEND_TYPE[self.sendType].str
	if self.sendType == 3 then
		local nicks = string.gsub(self.inputDesc:getText(), " ", "")
		if nicks == "" then
			Toast.show(CommonText[554][2])
			return
		end
		str = string.format(str,nicks)
	end

	

	mail.title = mailInfo.mtitle
	mail.type = mailInfo.type

	if mail.type == MAIL_TYPE_PLAYER or mail.type == MAIL_TYPE_SEND then
		require("app.dialog.MailDetailDialog").new(mail,true):push()
	elseif mail.type == MAIL_TYPE_STSTEM then
		require("app.view.SystemMailView").new(mail,true):push()
	end
end

function GMToolView:gagHandler(tag, sender)
	local nicks = string.gsub(self.inputDesc:getText(), " ", "")
	if nicks == "" then
		Toast.show(CommonText[735][1])
		return
	end
	local str = string.format(GM_CHAT_GAG_STR[tag],nicks)
	print("=====str:",str)
	GMBO.asynGag(function()
		Toast.show("操作成功!")
		end,str)
end

function GMToolView:setVipHandler(tag, sender)
	local nicks = string.gsub(self.inputDesc:getText(), " ", "")
	if nicks == "" then
		Toast.show(CommonText[735][1])
		return
	end

	local vip = string.gsub(self.inputVip:getText(), " ", "")
	if vip == "" then
		Toast.show(CommonText[735][2])
		return
	end

	local str = string.format(GM_SET_VIP_STR,nicks,vip)
	print("=====str:",str)
	GMBO.asynSetVip(function()
		Toast.show("操作成功!")
		end,str)
end

function GMToolView:setTopupHandler(tag, sender)
	local nicks = string.gsub(self.inputDesc:getText(), " ", "")
	if nicks == "" then
		Toast.show(CommonText[735][1])
		return
	end

	local topup = string.gsub(self.inputVip:getText(), " ", "")
	if topup == "" then
		Toast.show(CommonText[735][3])
		return
	end

	local str = string.format(GM_SET_TOPUP_STR,nicks,topup)
	print("=====str:",str)
	GMBO.asynSetVip(function()
		Toast.show("操作成功!")
		end,str)
end

function GMToolView:clearMailHandler(tag, sender)
	local nicks = string.gsub(self.inputDesc:getText(), " ", "")
	if nicks == "" then
		Toast.show(CommonText[735][1])
		return
	end
	
	local str = string.format(GM_CLEAR_PLAYER_MAIL,nicks)
	print("=====str:",str)

	--二次确认
	ConfirmDialog.new("确认清除玩家" .. nicks .. "所有的邮件吗？", function()
				GMBO.asynSetVip(function()
					Toast.show("操作成功!")
					end,str)
		end):push()

	
end

function GMToolView:onExit()
	GMToolView.super.onExit(self)
end





return GMToolView
