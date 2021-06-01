--
-- Author: gf
-- Date: 2015-09-07 16:09:29
-- 邮件详情

local ScrollText = class("ScrollText", TableView)

function ScrollText:ctor(size, contont)
	ScrollText.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_contont = contont
	local contentLab = ui.newTTFLabel({text = self.m_contont, font = G_FONT, size = FONT_SIZE_SMALL, color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(size.width, 0)
   		})

	self.m_cellSize = contentLab:getContentSize()
	self.m_cellSize.height = math.max(size.height, self.m_cellSize.height)
end

-- 获得view中总共有多少个cell
function ScrollText:numberOfCells()
	return 1
end

-- 索引为index的cell的大小，index从1开启
function ScrollText:cellSizeForIndex(index)
	return self.m_cellSize
end

-- cell:默认会创建一个空的node，node包含有_CELL_INDEX_的值。方法的返回的cellNode才是最终的cell
function ScrollText:createCellAtIndex(cell, index)
	local contentLab = ui.newTTFLabel({text = self.m_contont, font = G_FONT, size = FONT_SIZE_SMALL,color = COLOR[1], 
   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
   		dimensions = cc.size(self.m_cellSize.width, 0)
   		}):addTo(cell)

	contentLab:setPosition(self.m_cellSize.width/2, self.m_cellSize.height - contentLab:getContentSize().height/2)

	return cell
end

-----------------------------------------------------------------------------


local Dialog = require("app.dialog.Dialog")
local MailDetailDialog = class("MailDetailDialog", Dialog)

function MailDetailDialog:ctor(mail,read)
	MailDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT)})

	self.mail = mail
	self.m_read = read
end

function MailDetailDialog:onEnter()
	MailDetailDialog.super.onEnter(self)

	self:setTitle(CommonText[548][1])

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(GAME_SIZE_WIDTH, GAME_SIZE_HEIGHT))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(btm)
   	line:setPreferredSize(cc.size(btm:getContentSize().width - 60, line:getContentSize().height))
   	line:setPosition(btm:getContentSize().width / 2, 150)

   	local nameLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = self:getBg():getContentSize().height - 100, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	nameLab:setAnchorPoint(cc.p(0, 0.5))
	if self.mail.type == MAIL_TYPE_SEND then
		nameLab:setString(CommonText[550][1])
	else
		nameLab:setString(CommonText[550][2])
	end

	local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	nameBg:setPreferredSize(cc.size(474, 40))
	nameBg:setPosition(nameLab:getPositionX() + nameLab:getContentSize().width + nameBg:getContentSize().width / 2, nameLab:getPositionY())

	local nameContent = ui.newTTFLabel({text = self.mail.sendName, font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 20, y = nameBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
	nameContent:setAnchorPoint(cc.p(0, 0.5))
	if self.mail.type == MAIL_TYPE_SEND then
		nameContent:setString(MailBO.nickListToString(self.mail.toName))
	else
		nameContent:setString(self.mail.sendName)
	end

	local danger = display.newSprite(IMAGE_COMMON.."danger.png"):rightTo(nameContent, 20)
	danger:setScale(0.6)
	danger:setVisible(false)
	if table.isexist(self.mail, "isOther") and self.mail.isOther == 0 then
		danger:setVisible(true)
	end

	if self.mail.type == MAIL_TYPE_PLAYER and self.mail.moldId == 0 then
		----只处理玩家 私信邮件
		local lvContent = ui.newTTFLabel({text = "LV." .. self.mail.lv, font = G_FONT, size = FONT_SIZE_SMALL, 
	   		x = nameBg:getContentSize().width - 180, y = nameBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(nameBg)
		lvContent:setAnchorPoint(cc.p(0, 0.5))	

		local vipLvContent = display.newSprite(IMAGE_COMMON .. "vip/vip_".. self.mail.vipLv .. ".png", nameBg:getContentSize().width - 80, nameBg:getContentSize().height / 2):addTo(nameBg)
		vipLvContent:setAnchorPoint(cc.p(0.5, 0.5))		
		vipLvContent:setScale(0.8)
	end

	local contentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	contentBg:setPreferredSize(cc.size(550,618))
	contentBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - contentBg:getContentSize().height + 120)

	-- local text = ScrollText.new(cc.size(520, 600), self.mail.contont):addTo(contentBg)
	-- text:setPosition(20,10)
	-- text:reloadData()

	if #self.mail.toName <= 0 then
		local text = ScrollText.new(cc.size(520, 600), self.mail.contont):addTo(contentBg)
		text:setPosition(20,10)
		text:reloadData()
	else
		--适应坐标点击的
		local stringDatas = {}
		local msgs = ChatBO.parseCoordinate(self.mail.contont)
		for index = 1, #msgs do
			local mg = msgs[index]
			if mg.str then  -- 是信息
				stringDatas[#stringDatas + 1] = {["content"] = mg.str}
			elseif mg.pos then  -- 是坐标
				stringDatas[#stringDatas + 1] = {["content"] = mg.pos.x .. ":" .. mg.pos.y, color = COLOR[3], click = function()
						gprint("x:", mg.pos.x, "y:", mg.pos.y)
						UiDirector.clear()
						Notify.notify(LOCAL_LOCATION_EVENT, {x = mg.pos.x, y = mg.pos.y})
					end}
			end
		end

		local msg = RichLabel.new(stringDatas,cc.size(530, 0)):addTo(contentBg)
		msg:setPosition(10, contentBg:height() - 20)
	end

	local titleLab = ui.newTTFLabel({text = CommonText[550][3], font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 50, y = self:getBg():getContentSize().height - 150, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(self:getBg())
	titleLab:setAnchorPoint(cc.p(0, 0.5))

	local titleBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	titleBg:setPreferredSize(cc.size(474, 40))
	titleBg:setPosition(nameBg:getPositionX(), titleLab:getPositionY())

	local titleContent = ui.newTTFLabel({text = self.mail.title, font = G_FONT, size = FONT_SIZE_SMALL, 
   		x = 20, y = titleBg:getContentSize().height / 2, color = COLOR[1], align = ui.TEXT_ALIGN_CENTER}):addTo(titleBg)
	titleContent:setAnchorPoint(cc.p(0, 0.5))

   	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local delBtn = MenuButton.new(normal, selected, nil, handler(self,self.delHandler)):addTo(self:getBg())
	delBtn:setPosition(self:getBg():getContentSize().width / 2 - 200,90)
	delBtn:setLabel(CommonText[549][1])
	delBtn.mail = self.mail
	delBtn:setVisible(not self.m_read)


	gdump(self.mail,"self.mailself.mail")
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local contactBtn = MenuButton.new(normal, selected, nil, handler(self,self.contactHandler)):addTo(self:getBg())
	contactBtn:setPosition(self:getBg():getContentSize().width / 2 ,90)
	contactBtn:setLabel(CommonText[549][2])
	contactBtn:setVisible(self.mail.type ~= MAIL_TYPE_SEND and (self.mail.moldId == 0 or self.mail.moldId == 4))
	contactBtn.mail = self.mail

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	local mailBtn = MenuButton.new(normal, selected, nil, handler(self,self.mailHandler)):addTo(self:getBg())
	mailBtn:setPosition(self:getBg():getContentSize().width / 2 + 200,90)
	mailBtn:setLabel(CommonText[549][3])
	mailBtn:setVisible(self.mail.type ~= MAIL_TYPE_SEND and (self.mail.moldId == 0 or self.mail.moldId == 4))
	mailBtn.mail = self.mail
end

function MailDetailDialog:delHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	MailBO.asynDelMail(function()
		Loading.getInstance():unshow()
		Toast.show(CommonText[551][2])
		self:pop()
		end,sender.mail)
end

function MailDetailDialog:contactHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local playerName
	if self.mail.moldId == 0 then
		playerName = self.mail.sendName
	elseif self.mail.moldId == 4 then
		gdump(self.mail,"self.mailself.mail")
		playerName = self.mail.param[1]
	end
	SocialityBO.asynSearchPlayer(function(man)
		local player = {icon = man.icon, nick = man.nick, level = man.level, lordId = man.lordId, rank = man.ranks,
	        fight = man.fight, sex = man.sex, party = man.partyName, pros = man.pros, prosMax = man.prosMax}
	    require("app.dialog.PlayerDetailDialog").new(DIALOG_FOR_FRIEND, player):push()
		end,playerName)
end

function MailDetailDialog:mailHandler(tag,sender)
	ManagerSound.playNormalButtonSound()
	local playerName,title
	if self.mail.moldId == 0 then
		playerName = self.mail.sendName
		title = "Re:" .. self.mail.title
	elseif self.mail.moldId == 4 then
		playerName = self.mail.param[1]
	end
	
	require("app.dialog.MailSendDialog").new(playerName,MAIL_SEND_TYPE_NORMAL,title):push()
end

return MailDetailDialog