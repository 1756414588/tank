--
-- Author: gf
-- Date: 2015-10-14 14:53:14
--

local JJCReportTableView = class("JJCReportTableView", TableView)

function JJCReportTableView:ctor(size,type)
	JJCReportTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)
	if type == MAIL_TYPE_PERSON_JJC then
		self.mailList = MailMO.myJJCPersonReprot_
	else
		self.mailList = MailMO.myJJCAllReprot_
	end	
	self.type = type
end


function JJCReportTableView:onEnter()
	JJCReportTableView.super.onEnter(self)
	self.m_updateHandler = Notify.register(LOCAL_JJC_REPORT_UPDATE_EVENT, handler(self, self.onMailUpdate))
end

function JJCReportTableView:numberOfCells()
	return #self.mailList
end

function JJCReportTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function JJCReportTableView:createCellAtIndex(cell, index)
	JJCReportTableView.super.createCellAtIndex(self, cell, index)

	local mail = MailBO.parseMailTitleAndCon(self.mailList[index])

	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
	bg:setPreferredSize(cc.size(607, 140))
	bg:setCapInsets(cc.rect(220, 60, 1, 1))
	bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)

	local mailIcon
	if mail.state == MailMO.MAIL_STATE_NEW or mail.state == MailMO.MAIL_STATE_NEW_AWARD then
		mailIcon = display.newSprite(IMAGE_COMMON .. "icon_letter_close.png", 70, 65):addTo(bg)
	else
		mailIcon = display.newSprite(IMAGE_COMMON .. "icon_letter_open.png", 70, 65):addTo(bg)
	end

	local mailTitle = ui.newTTFLabel({text = mail.title, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	mailTitle:setAnchorPoint(cc.p(0, 0.5))

	local mailSendName = ui.newTTFLabel({text = mail.sendName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	mailSendName:setAnchorPoint(cc.p(0, 0.5))

	local time = ui.newTTFLabel({text = os.date("%m-%d %X", mail.time), font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 500, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	time:setAnchorPoint(cc.p(1, 0.5))

	local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetailhandler))
	detailBtn.mail = mail
	cell:addButton(detailBtn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 20)

	return cell
end

function JJCReportTableView:openDetailhandler(tag, sender)
	self:openDetail(sender.mail)
end

function JJCReportTableView:openDetail(mail)
	if table.isexist(mail, "report") then
		-- gdump(mail,"JJCReportTableView:openDetail..mail")
		require("app.view.ReportArenaView").new(mail):push()
	else
		Loading.getInstance():show()
		MailBO.asynGetJJCReportById(function(mail)
			Loading.getInstance():unshow()
			require("app.view.ReportArenaView").new(mail):push()
			end,mail.keyId,self.type)
	end
end

function JJCReportTableView:cellTouched(cell, index)
	ManagerSound.playSound("mail_check")

	local mail = self.mailList[index]
	self:openDetail(mail)
end

function JJCReportTableView:onMailUpdate()
	if self.type == MAIL_TYPE_PERSON_JJC then
		self.mailList = MailMO.myJJCPersonReprot_
	else
		self.mailList = MailMO.myJJCAllReprot_
	end
	-- gdump(self.mailList,"JJCReportTableView:onMailUpdate()")
	self:reloadData()
end



function JJCReportTableView:onExit()
	JJCReportTableView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end



return JJCReportTableView