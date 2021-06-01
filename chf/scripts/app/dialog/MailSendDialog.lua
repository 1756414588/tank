--
-- Author: gf
-- Date: 2015-09-07 17:42:41
-- 邮件发送

local Dialog = require("app.dialog.Dialog")
local MailSendDialog = class("MailSendDialog", Dialog)

function MailSendDialog:ctor(toName,type,title)
	MailSendDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)})
	if not toName then toName = "" end
	if not title then title = "" end
	self.toName = toName
	self.sendType = type
	self.title_ = title
end

function MailSendDialog:onEnter()
	MailSendDialog.super.onEnter(self)

	self:setTitle(CommonText[549][4])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(btm)
   	line:setPreferredSize(cc.size(btm:getContentSize().width - 60, line:getContentSize().height))
   	line:setPosition(btm:getContentSize().width / 2, 150)

   	local nameLab = ui.newTTFLabel({text = CommonText[550][1], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = self:getBg():getContentSize().height - 110, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	nameLab:setAnchorPoint(cc.p(0, 0.5))

	-- local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	-- nameBg:setPreferredSize(cc.size(474, 40))
	-- nameBg:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + nameBg:getContentSize().width / 2, nameLab:getPositionY())

	-- local nameContent = ui.newTTFLabel({text = toName, font = G_FONT, size = FONT_SIZE_SMALL, 
 --   		x = 20, y = nameBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
	-- nameContent:setAnchorPoint(cc.p(0, 0.5))

	local function onEdit(event, editbox)
	--    if eventType == "return" then
	--    end
    end
	local input_bg = IMAGE_COMMON .. "info_bg_14.jpg"

    local inputName = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(390, 40)}):addTo(self:getBg())
	inputName:setFontColor(COLOR[1])
	inputName:setFontSize(FONT_SIZE_SMALL)
	inputName:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + inputName:getContentSize().width / 2, nameLab:getPositionY())
	self.inputName = inputName
	self.inputName:setText(self.toName)
	inputName:setEnabled(self.sendType == MAIL_SEND_TYPE_NORMAL)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_search_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_search_selected.png")
	local contactBtn = MenuButton.new(normal, selected, nil, handler(self,self.openContactDia)):addTo(self:getBg())
	contactBtn:setPosition(self:getBg():getContentSize().width - 80, self:getBg():getContentSize().height - 110)

	if self.sendType == MAIL_SEND_TYPE_PARTY then
		inputName:setText(CommonText[634])
	end

	local titleLab = ui.newTTFLabel({text = CommonText[550][3], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = self:getBg():getContentSize().height - 160, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titleLab:setAnchorPoint(cc.p(0, 0.5))

    local inputTitle = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(390, 40)}):addTo(self:getBg())
	inputTitle:setFontColor(COLOR[1])
	inputTitle:setFontSize(FONT_SIZE_SMALL)
	inputTitle:setPosition(titleLab:getPositionX() + titleLab:getContentSize().width + inputName:getContentSize().width / 2, titleLab:getPositionY())
	self.inputTitle = inputTitle
	self.inputTitle:setText(self.title_)
	
	

	local contentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	contentBg:setPreferredSize(cc.size(550,618))
	contentBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - contentBg:getContentSize().height + 120)

	local contentLab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = -220, y = contentBg:getContentSize().height - 20, color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(510, 573)}):addTo(contentBg)
	contentLab:setAnchorPoint(cc.p(0, 1))
	self.contentLab = contentLab


 -- 	function creatContentLab(str)
	-- 	if self.contentLab then contentBg:removeChild(self.contentLab) end
	-- 	local contentLab = ui.newTTFLabel({text = str, font = G_FONT, size = FONT_SIZE_SMALL, 
	-- 	   		x = -220, y = contentBg:getContentSize().height - 20, color = COLOR[1], 
	-- 	   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	-- 	   		dimensions = cc.size(510, 573)}):addTo(contentBg)
	-- 	contentLab:setAnchorPoint(cc.p(0, 1))
	-- 	self.contentLab = contentLab
	-- end

	local function onEdit1(event, editbox)
	   if event == "return" then
	   		editbox:setText("")
	   		editbox:setVisible(true)
	   elseif event == "changed" then
	   		contentLab:setString(editbox:getText())
	   elseif event == "began" then
	   		editbox:setVisible(false)
	   		if self.contentLab then 
	   			editbox:setText(self.contentLab:getString())
	   		end
	   end
    end
	local input_bg = IMAGE_COMMON .. "info_bg_15.png"
	for index=1,15 do
		local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(510, 40)}):addTo(self:getBg())
		inputContent:setFontColor(COLOR[1])
		inputContent:setFontSize(FONT_SIZE_SMALL)
		inputContent:setMaxLength(200)  
		inputContent:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 220 - (index - 1) * 40)
	end

   	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, handler(self,self.camcelHandler)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 200,90)
	cancelBtn:setLabel(CommonText[553][1])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local sendBtn = MenuButton.new(normal, selected, nil, handler(self,self.sendHandler)):addTo(self:getBg())
	sendBtn:setPosition(self:getBg():getContentSize().width / 2 + 200,90)
	sendBtn:setLabel(CommonText[553][2])


end


function MailSendDialog:sendHandler(tag,sender)
	ManagerSound.playNormalButtonSound()

	--判断等级
	if UserMO.level_ < 15 then
		Toast.show(CommonText[860])
		return
	end

	local nicks = string.split(string.gsub(self.inputName:getText(), " ", ""),"&")
	-- gdump(nicks,"MailSendDialog:sendHandler..names")

	if MailBO.nicksIsYes(nicks) == false then
		Toast.show(CommonText[554][4])
		return
	end
	local title = WordMO.filterSensitiveWords(self.inputTitle:getText())
	local content = WordMO.filterSensitiveWords(self.contentLab:getString())

	if string.gsub(title, " ", "") == "" then
		Toast.show(CommonText[554][1])
		return
	end

	local titleLen = string.utf8len(title)
	if titleLen > 20 then
		Toast.show(CommonText[750][1])
		return
	end
	
	if string.gsub(content, " ", "") == "" then
		Toast.show(CommonText[554][3])
		return
	end

	local contentLen = string.utf8len(content)
	if contentLen > 200 then
		Toast.show(CommonText[750][2])
		return
	end

	
	local mail = {
		keyId = 0,
		type = 1,
		title = title,
		sendName = UserMO.nickName_,
		toName = nicks,
		state = 1,
		contont = content,
		time = 0
	}

	-- gdump(mail,"MailSendDialog:sendHandler..mail")
	Loading.getInstance():show()
	MailBO.asynSendMail(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[551][1])
		self:pop()
		end,mail,self.sendType)
end

function MailSendDialog:camcelHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function MailSendDialog:openContactDia()
	local function contactCallback(contacts)
		local num = 0
		if contacts and #contacts > 0 then
			self.inputName:setText(contacts[1].name)
		else
			self.inputName:setText("")
		end
	end

	local ContactDialog = require("app.dialog.ContactDialog")
	ContactDialog.new(CONTACT_MODE_SINGLE, contactCallback):push()
end

return MailSendDialog