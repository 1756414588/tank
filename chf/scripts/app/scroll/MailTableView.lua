--
-- Author: gf
-- Date: 2015-09-07 15:14:43
--

local MailTableView = class("MailTableView", TableView)

function MailTableView:ctor(size,type)
	MailTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(self:getViewSize().width, 145)

	self.mailList = MailMO.queryMyMails_(type)
	self.type = type
end


function MailTableView:onEnter()
	MailTableView.super.onEnter(self)
	self.m_updateHandler = Notify.register(LOCAL_MAIL_UPDATE_EVENT, handler(self, self.onMailUpdate))
end

function MailTableView:numberOfCells()
	return #self.mailList
end

function MailTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function MailTableView:createCellAtIndex(cell, index)
	MailTableView.super.createCellAtIndex(self, cell, index)
	local mail = MailBO.parseMailTitleAndCon(self.mailList[index])
	local mb = MailMO.queryMail(mail.moldId)
	local mailIcon,bg
	if mail.state == MailMO.MAIL_STATE_NEW or mail.state == MailMO.MAIL_STATE_NEW_AWARD then
		bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_26.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		if mb and mb.icon and mb.icon ~= "" then
			mailIcon = mb.icon
		else
			mailIcon = "icon_letter_close"
		end
	else
		bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_25.png"):addTo(cell, -1)
		bg:setPreferredSize(cc.size(607, 140))
		bg:setCapInsets(cc.rect(220, 60, 1, 1))
		bg:setPosition(self.m_cellSize.width / 2, self.m_cellSize.height / 2)
		if mb and mb.iconOpened and mb.iconOpened ~= "" then
			mailIcon = mb.iconOpened
		else
			mailIcon = "icon_letter_open"
		end

		if mail.isCollections == MAIL_COLLECT_TYPE_COLLECTED then
			display.newSprite(IMAGE_COMMON.."collected.png"):addTo(bg,10):align(display.RIGHT_TOP,bg:width(),bg:height())
		else
			display.newSprite(IMAGE_COMMON.."read.png"):addTo(bg,10):align(display.RIGHT_TOP,bg:width(),bg:height())
		end
	end
	mailIcon = display.newSprite(IMAGE_COMMON .. mailIcon ..".png", 70, 65):addTo(bg)

	local mailTitle = ui.newTTFLabel({text = mail.title, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 114, color = COLOR[12], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	mailTitle:setAnchorPoint(cc.p(0, 0.5))

	local mailSendName = ui.newTTFLabel({text = mail.sendName, font = G_FONT, size = FONT_SIZE_SMALL, 
		x = 170, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
	mailSendName:setAnchorPoint(cc.p(0, 0.5))

	if mail.type == MAIL_TYPE_SEND and not mail.keyId then
		mailSendName:setString(MailBO.nickListToString(mail.toName))
	else
		mailSendName:setString(mail.sendName)
	end

	if UserMO.queryFuncOpen(UFP_MAIL_SYNC) and self.type ~= 2 then
		local time = ui.newTTFLabel({text = os.date("%m-%d %X", mail.time), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 450, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		time:setAnchorPoint(cc.p(1, 0.5))

		local remainTime = mail.time + 30 * 24 * 3600
		local remainDay = ManagerTimer.time(remainTime - ManagerTimer.getTime())
		local toDay = CommonText[100029]
		if remainDay.day > 0 then
			toDay = string.format(CommonText[100027], remainDay.day)
		end

		local remain = ui.newTTFLabel({text = "("..toDay..")", font = G_FONT, size = FONT_SIZE_TINY, color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		remain:rightTo(time,10)

	else
		local time = ui.newTTFLabel({text = os.date("%m-%d %X", mail.time), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 500, y = 54, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(cell)
		time:setAnchorPoint(cc.p(1, 0.5))
	end
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_detail_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_detail_selected.png")
	-- local detailBtn = CellMenuButton.new(normal, selected, nil, handler(self,self.openDetailhandler))
	-- detailBtn.mail = mail
	-- cell:addButton(detailBtn, self.m_cellSize.width - 70, self.m_cellSize.height / 2 - 20)

	return cell
end

function MailTableView:openDetailhandler(tag, sender)
	ManagerSound.playSound("mail_check")
	self:openDetail(sender.mail)
end

function MailTableView:openDetail(mail)
	-- gdump(mail,"[MailTableView:openDetail..mail]")
	-- if mail.state == MailMO.MAIL_STATE_READ or 
	-- 	mail.state == MailMO.MAIL_STATE_READ_AWARD or 
	-- 	mail.state == MailMO.MAIL_STATE_READ_AWARD_GET then
	-- 	require("app.dialog.MailDetailDialog").new(mail):push()
	-- 	return
	-- end

	-- MailBO.asynReadMail(function(mail)
	-- 	require("app.dialog.MailDetailDialog").new(mail):push()
	-- 	end,mail)
	if mail.type == MAIL_TYPE_SEND then
		self:openMailDetail(mail)
	else
		local mailReport = MailBO.mailHasGet(mail.keyId) 
		if mailReport then
			-- gdump(mail,"MailTableView:openDetail..mail")
			self:openMailDetail(mail)
		else
			Loading.getInstance():show()
			MailBO.asynGetMailById(handler(self,self.openMailDetail),mail.keyId)
		end
	end
end

function MailTableView:openMailDetail(mail)
	Loading.getInstance():unshow()
	if mail.type == MAIL_TYPE_PLAYER or mail.type == MAIL_TYPE_SEND then
		require("app.dialog.MailDetailDialog").new(mail):push()
	elseif mail.type == MAIL_TYPE_REPORT then
		print("@^^^^^^^openMailDetail^^^^")
		for k,v in pairs(mail) do
			if type(v) ~= "table" then
				print(k , v)
			end
		end
		-- dump(mail.report, "@^^^^^^^^openDetail ")
		if mail.report and (mail.report.scoutHome or mail.report.scoutMine or mail.report.scoutRebel) then
			--侦查
			local ReportScoutView = require("app.view.ReportScoutView")
			ReportScoutView.new(mail):push()
		else
			--攻打、防守
			require("app.view.ReportAttackView").new(mail):push()
		end
	elseif mail.type == MAIL_TYPE_STSTEM then
		require("app.view.SystemMailView").new(mail):push()
	elseif mail.type == MAIL_TYPE_REPORT_AS then
		print("@^^^^^^飞艇战报^^^^^^")
		if mail.report and next(mail.report) ~= nil then
			require("app.view.ReportAirShipView").new(mail):push()
		end		
	end
end

function MailTableView:cellTouched(cell, index)
	ManagerSound.playSound("mail_check")

	local mail = self.mailList[index]
	self:openDetail(mail)
end

function MailTableView:onMailUpdate()
	self.mailList = MailMO.queryMyMails_(self.type)
	self:reloadData()
end



function MailTableView:onExit()
	MailTableView.super.onExit(self)
	
	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end



return MailTableView