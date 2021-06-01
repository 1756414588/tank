--
-- Author: gf
-- Date: 2015-09-29 09:53:16
-- 系统邮件


local SystemMailView = class("SystemMailView", UiNode)

function SystemMailView:ctor(mail,read)
	SystemMailView.super.ctor(self, "image/common/bg_ui.jpg")

	self.m_mail = mail
	self.m_read = read
	-- gdump(self.m_mail, "SystemMailView:ctor")
end

function SystemMailView:onEnter()
	SystemMailView.super.onEnter(self)

	self:setTitle(CommonText[548][4])

	self:setUI()
end

function SystemMailView:setUI()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg())
	infoBg:setPreferredSize(cc.size(600, self:getBg():getContentSize().height - 220))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 100 - infoBg:getContentSize().height / 2)


	local SystemMailTableView = require("app.scroll.SystemMailTableView")
	local view = SystemMailTableView.new(cc.size(infoBg:getContentSize().width, infoBg:getContentSize().height - 20),self.m_mail):addTo(infoBg)
	view:setPosition(0, 0)
	view:reloadData()
	
	--按钮

	--删除
	local normal = display.newSprite(IMAGE_COMMON .. "btn_store_del_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_store_del_selected.png")
	local delBtn = MenuButton.new(normal, selected, nil, handler(self,self.delHandler)):addTo(self:getBg())
	delBtn:setPosition(self:getBg():getContentSize().width / 2 - 250,80)
	delBtn.mail = self.m_mail
	delBtn:setVisible(not self.m_read)
	

	--提取附件
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local getAwardBtn = MenuButton.new(normal, selected, disabled, handler(self,self.getAwardHandler)):addTo(self:getBg())
	getAwardBtn:setLabel(CommonText[690])
	getAwardBtn:setPosition(self:getBg():getContentSize().width / 2 + 230,80)
	getAwardBtn:setVisible(self.m_mail.award and #self.m_mail.award > 0 and not self.m_read)
	getAwardBtn:setEnabled(self.m_mail.state ~= MailMO.MAIL_STATE_READ_AWARD_GET)
	getAwardBtn.mail = self.m_mail
	self.getAwardBtn = getAwardBtn
end


function SystemMailView:delHandler(tag,sender)
	ManagerSound.playNormalButtonSound()

	local function delMail()
		Loading.getInstance():show()
		MailBO.asynDelMail(function()
			Loading.getInstance():unshow()
			Toast.show(CommonText[551][2])
			self:pop()
			end,sender.mail)
	end
	--判断是否有未领的附件
	if self.m_mail.state ~= MailMO.MAIL_STATE_NEW_AWARD and self.m_mail.state ~= MailMO.MAIL_STATE_READ_AWARD then
		delMail()
	else
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		-- 是否确定取消
		ConfirmDialog.new(CommonText[840], function()
				delMail()

			end):push()
	end
end

function SystemMailView:getAwardHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynRewardMail(function(mail)
		Loading.getInstance():unshow()
		self.m_mail = mail
		Toast.show(CommonText[605])
		self.getAwardBtn:setVisible(mail.award and #mail.award > 0)
		self.getAwardBtn:setEnabled(mail.state ~= MailMO.MAIL_STATE_READ_AWARD_GET)
		end,sender.mail)

end



return SystemMailView
