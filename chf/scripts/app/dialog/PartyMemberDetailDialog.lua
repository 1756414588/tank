--
-- Author: gf
-- Date: 2015-09-18 11:02:43
-- 军团成员详情弹出
local ConfirmDialog = require("app.dialog.ConfirmDialog")
local Dialog = require("app.dialog.Dialog")
local PartyMemberDetailDialog = class("PartyMemberDetailDialog", Dialog)

function PartyMemberDetailDialog:ctor(member)
	PartyMemberDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(560, 850)})

	self.member = member
end


function PartyMemberDetailDialog:onEnter()
	PartyMemberDetailDialog.super.onEnter(self)

	self:setTitle(CommonText[645])

	self.m_updateHandler = Notify.register(LOCAL_PARTY_MEMBER_UPDATE_EVENT, handler(self, self.updateHandler))

	local member = self.member

	-- gdump(self.member,UserMO.lordId_)

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg",
		self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2):addTo(self:getBg(), -1)

	for index = 1,#CommonText[642] do
		local labTit = ui.newTTFLabel({text = CommonText[642][index], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 60, y = btm:getContentSize().height - 70 - (index - 1) * 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		labTit:setAnchorPoint(cc.p(0, 0.5))

		local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
			x = labTit:getPositionX() + labTit:getContentSize().width, y = labTit:getPositionY(), color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		value:setAnchorPoint(cc.p(0, 0.5))
		if index == 1 then
			value:setString(member.nick)
		elseif index == 2 then
			value:setString(PartyBO.getJobNameById(member.job))
			self.jobValue = value

		elseif index == 3 then
			value:setString(member.rank)
			value:setColor(COLOR[2])
		elseif index == 4 then
			value:setString(member.level)
		elseif index == 5 then
			value:setString(UiUtil.strNumSimplify(member.fight))
		elseif index == 6 then
			value:setString(member.donate)
		elseif index == 7 then
			if member.isOnline == 0 then
				value:setString(CommonText[644][1])
			else
				value:setString(string.format(CommonText[644][2],os.date("%Y/%m/%d %X", member.isOnline)))
			end
			value:setColor(COLOR[2])
		end
	end

	local contectLab = ui.newTTFLabel({text = CommonText[643][1], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 60, y = btm:getContentSize().height - 400, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		contectLab:setAnchorPoint(cc.p(0, 0.5))

	local manaLab = ui.newTTFLabel({text = CommonText[643][2], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = 60, y = btm:getContentSize().height - 490, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(btm)
		manaLab:setAnchorPoint(cc.p(0, 0.5))


	--按钮
	--邮件
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local mailBtn = MenuButton.new(normal, selected, disabled, handler(self,self.mailHandler)):addTo(btm)
	mailBtn:setPosition(250,contectLab:getPositionY())
	mailBtn:setLabel(CommonText[646][1])
	mailBtn.nick = member.nick
	mailBtn:setEnabled(member.lordId ~= UserMO.lordId_)

	--私聊
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local chatBtn = MenuButton.new(normal, selected, disabled, handler(self,self.chatHandler)):addTo(btm)
	chatBtn:setPosition(420,contectLab:getPositionY())
	chatBtn:setLabel(CommonText[646][2])
	chatBtn.lordId = member.lordId
	chatBtn.nick = member.nick
	chatBtn:setEnabled(member.lordId ~= UserMO.lordId_)

	--升职
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local upBtn = MenuButton.new(normal, selected, disabled, handler(self,self.upHandler)):addTo(btm)
	upBtn:setPosition(250,manaLab:getPositionY())
	upBtn:setLabel(CommonText[647][1])
	upBtn:setVisible(member.lordId == UserMO.lordId_)
	gdump(member.job,"member.job")
	upBtn:setEnabled(member.job < PARTY_JOB_MASTER)



	--设定职位
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local setJobBtn = MenuButton.new(normal, selected, disabled, handler(self,self.setJobHandler)):addTo(btm)
	setJobBtn:setPosition(250,manaLab:getPositionY())
	setJobBtn:setLabel(CommonText[647][2])
	setJobBtn:setVisible(member.lordId ~= UserMO.lordId_)
	setJobBtn:setEnabled(PartyMO.myJob > PARTY_JOB_OFFICAIL and PartyMO.myJob > member.job)
	self.setJobBtn = setJobBtn


	--踢出军团
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local kickBtn = MenuButton.new(normal, selected, disabled, handler(self,self.cleanMemberHandler)):addTo(btm)
	kickBtn:setPosition(420,manaLab:getPositionY())
	kickBtn:setLabel(CommonText[647][3])
	kickBtn:setEnabled(member.lordId ~= UserMO.lordId_ and PartyMO.myJob > PARTY_JOB_OFFICAIL and PartyMO.myJob > member.job)
	self.kickBtn = kickBtn
	

	--转让团长
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local masterBtn = MenuButton.new(normal, selected, disabled, handler(self,self.masterHandler)):addTo(btm)
	masterBtn:setPosition(250,manaLab:getPositionY() - 90)
	masterBtn:setLabel(CommonText[647][4])
	masterBtn:setEnabled(member.lordId ~= UserMO.lordId_ and PartyMO.myJob == PARTY_JOB_MASTER)
	self.masterBtn = masterBtn



	--退出军团
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local quitBtn = MenuButton.new(normal, selected, disabled, handler(self,self.quitHandler)):addTo(btm)
	quitBtn:setPosition(420,manaLab:getPositionY() - 90)
	quitBtn:setLabel(CommonText[647][5])
	quitBtn:setEnabled(member.lordId == UserMO.lordId_ and member.job < PARTY_JOB_MASTER)
	self.quitBtn = quitBtn



end

function PartyMemberDetailDialog:updateHandler()
	self.jobValue:setString(PartyBO.getJobNameById(self.member.job))
end

function PartyMemberDetailDialog:mailHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.MailSendDialog").new(sender.nick,MAIL_SEND_TYPE_NORMAL):push()
end

function PartyMemberDetailDialog:chatHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local function doneCallback(man)
		Loading.getInstance():unshow()
		if man then -- 搜索到了
			-- gdump(man, "PartyMemberDetailDialog:chatHandler")
			UiDirector.popMakeUiTop("HomeView")
			
			ChatMO.curPrivacyLordId_ = man.lordId
			local ChatView = require("app.view.ChatView")
			ChatView.new(CHAT_TYPE_PRIVACY):push()
		else
			-- 角色不存在或不在线
			Toast.show(CommonText[355][3])
		end
	end

	Loading.getInstance():show()
	ChatBO.asynSearchOl(doneCallback, sender.nick)
end

function PartyMemberDetailDialog:upHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	PartyBO.asynUpMemberJob(function()
		Loading.getInstance():unshow()
		end,self.member)
end

function PartyMemberDetailDialog:cleanMemberHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(string.format(CommonText[650],self.member.nick), function()
			Loading.getInstance():show()
			PartyBO.asynCleanMember(function()
				Loading.getInstance():unshow()
				self:pop()
				end,self.member)
		end):push()
end



function PartyMemberDetailDialog:setJobHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.PartyMemberJobSetDialog").new(self.member):push()
end


function PartyMemberDetailDialog:masterHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(string.format(CommonText[651],self.member.nick), function()
			Loading.getInstance():show()
			PartyBO.asynConcedeJob(function()
				Loading.getInstance():unshow()
				self.masterBtn:setEnabled(self.member.lordId ~= UserMO.lordId_ and PartyMO.myJob == PARTY_JOB_MASTER)
				self.setJobBtn:setEnabled(PartyMO.myJob > PARTY_JOB_OFFICAIL and PartyMO.myJob > self.member.job)
				self.quitBtn:setEnabled(self.member.lordId == UserMO.lordId_ and self.member.job < PARTY_JOB_MASTER)
				self.kickBtn:setEnabled(self.member.lordId ~= UserMO.lordId_ and PartyMO.myJob > PARTY_JOB_OFFICAIL and PartyMO.myJob > self.member.job)
				end,self.member)
		end):push()

end

function PartyMemberDetailDialog:quitHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	ConfirmDialog.new(CommonText[623], function()
			Loading.getInstance():show()
			PartyBO.asynQuitParty(function()
				Loading.getInstance():unshow()
				end)
		end):push()
end


function PartyMemberDetailDialog:onExit()
	PartyMemberDetailDialog.super.onExit(self)

	if self.m_updateHandler then
		Notify.unregister(self.m_updateHandler)
		self.m_updateHandler = nil
	end
end


return PartyMemberDetailDialog