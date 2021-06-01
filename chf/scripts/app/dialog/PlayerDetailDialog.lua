--
-- Author: gf
-- Date: 2015-09-06 12:39:41
-- 玩家详情


local Dialog = require("app.dialog.Dialog")
local PlayerDetailDialog = class("PlayerDetailDialog", Dialog)

DIALOG_FOR_FRIEND = 1 -- 社交中的好友详情
DIALOG_FOR_WORLD_OTHER = 2 -- 在世界中的别人详情
DIALOG_FOR_WORLD_SELF  = 3 -- 在世界中的自己
DIALOG_FOR_CHAT = 4 -- 聊天中详情

-- viewFor:当等于DIALOG_FOR_WORLD_OTHER和DIALOG_FOR_WORLD_SELF时，param中pos表示在世界的坐标 chat用来传递玩家当前的聊天内容（在举报的时候用到）
function PlayerDetailDialog:ctor(viewFor, player, param, chat)
	PlayerDetailDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 600)})

	viewFor = viewFor or DIALOG_FOR_FRIEND

	player = player or {}
	player.lordId = player.lordId or 0
	player.icon = player.icon or 0
	player.nick = player.nick or ""
	player.level = player.level or 1
	player.fight = player.fight or 0
	player.party = player.party or CommonText[108] -- 无
	player.pos = player.pos
	player.sex = player.sex or SEX_FEMALE
	player.pros = player.pros or 0
	player.prosMax = player.prosMax or 0
	player.ruins = player.ruins
	player.jobId = player.jobId or 0

	self.viewFor = viewFor
	self.player = player
	self.param = param
	self.chat = chat
end

function PlayerDetailDialog:onEnter()
	PlayerDetailDialog.super.onEnter(self)
	PictureValidateBO.getScoutInfo(function ()
	end)
	
	self:setTitle(CommonText[543])

	gdump(self.player,"PlayerDetailDialog:ctor..player")

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 530))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg(), -1)
	infoBg:setPreferredSize(cc.size(510, 362))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height - 75 - infoBg:getContentSize().height / 2)
	
	-- 头像
	local itemView = UiUtil.createItemView(ITEM_KIND_PORTRAIT, self.player.icon):addTo(infoBg)
	itemView:setScale(0.75)
	itemView:setPosition(100, infoBg:getContentSize().height - 115)

	-- 名称
	local name = nil
	if self.player.jobId > 0 then
		local t = display.newSprite("image/item/job_"..self.player.jobId ..".png")
			:addTo(infoBg):align(display.LEFT_CENTER,200,infoBg:height() - 50)
		name = UiUtil.label(self.player.nick,FONT_SIZE_MEDIUM,COLOR[12]):addTo(infoBg):rightTo(t)
	else
		name = ui.newTTFLabel({text = self.player.nick, font = G_FONT, size = FONT_SIZE_MEDIUM,  x = 200, y = infoBg:getContentSize().height - 50, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
		name:setAnchorPoint(cc.p(0, 0.5))
	end

	if self.player.sex == 0 then self.player.sex = 1 end
	-- 性别
	local sex = UiUtil.createItemSprite(ITEM_KIND_SEX, self.player.sex):addTo(infoBg)
	sex:setPosition(name:getPositionX() + name:getContentSize().width + 10 + sex:getContentSize().width / 2, name:getPositionY())

	-- 等级
	local levelLab = ui.newTTFLabel({text = CommonText[544][1], font = G_FONT, size = FONT_SIZE_SMALL, x = name:getPositionX(), y = name:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	levelLab:setAnchorPoint(cc.p(0, 0.5))
	local levelValue = ui.newTTFLabel({text = self.player.level, font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX() + levelLab:getContentSize().width, y = levelLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	levelValue:setAnchorPoint(cc.p(0, 0.5))

	-- 战力
	local powerLab = ui.newTTFLabel({text = CommonText[544][2], font = G_FONT, size = FONT_SIZE_SMALL, x = levelLab:getPositionX(), y = levelLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	powerLab:setAnchorPoint(cc.p(0, 0.5))
	local powerValue = ui.newTTFLabel({text = UiUtil.strNumSimplify(self.player.fight), font = G_FONT, size = FONT_SIZE_SMALL, x = powerLab:getPositionX() + powerLab:getContentSize().width, y = powerLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	powerValue:setAnchorPoint(cc.p(0, 0.5))

	-- 军团
	local gangLab = ui.newTTFLabel({text = CommonText[544][3], font = G_FONT, size = FONT_SIZE_SMALL, x = powerLab:getPositionX(), y = powerLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	gangLab:setAnchorPoint(cc.p(0, 0.5))
	local gangValue = ui.newTTFLabel({text = self.player.party, font = G_FONT, size = FONT_SIZE_SMALL, x = gangLab:getPositionX() + gangLab:getContentSize().width, y = gangLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
	gangValue:setAnchorPoint(cc.p(0, 0.5))

	-- local pos = WorldMO.decodePosition(self.player.pos)

	-- 坐标
	local posLab = ui.newTTFLabel({text = CommonText[544][4], font = G_FONT, size = FONT_SIZE_SMALL, x = gangLab:getPositionX(), y = gangLab:getPositionY() - 30, align = ui.TEXT_ALIGN_CENTER, color = COLOR[11]}):addTo(infoBg)
	posLab:setAnchorPoint(cc.p(0, 0.5))

	if self.player.pos then
		local posValue = ui.newTTFLabel({text = "(" .. self.player.pos.x .. "," .. self.player.pos.y .. ")", font = G_FONT, size = FONT_SIZE_SMALL, x = posLab:getPositionX() + posLab:getContentSize().width, y = posLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		posValue:setAnchorPoint(cc.p(0, 0.5))
	else
		-- 未知
		local posValue = ui.newTTFLabel({text = CommonText[371], font = G_FONT, size = FONT_SIZE_SMALL, x = posLab:getPositionX() + posLab:getContentSize().width, y = posLab:getPositionY(), align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(infoBg)
		posValue:setAnchorPoint(cc.p(0, 0.5))
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(470, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2, 150)

    local level = WorldMO.getBuildLevelByProps(self.player.pros, self.player.prosMax, self.player.ruins)

    -- 建筑
    local itemView = UiUtil.createItemSprite(ITEM_KIND_WORLD_RES, WORLD_ID_BUILD, {level = level}):addTo(infoBg)
    itemView:setScale(math.min(160 / itemView:getContentSize().width, 130 / itemView:getContentSize().height))
    itemView:setAnchorPoint(cc.p(0.5, 0))
    itemView:setPosition(90, 10)

    local node = UiUtil.showProsValue(self.player.pros, self.player.prosMax):addTo(infoBg)
    node:setPosition(infoBg:getContentSize().width - 280, 90)

    local bar = UiUtil.showProsBar(self.player.pros, self.player.prosMax):addTo(infoBg)
    bar:setPosition(node:getPositionX() + node:getContentSize().width / 2, node:getPositionY() - 6)

	self:showButtons()
end

function PlayerDetailDialog:showButtons()
	if self.viewFor == DIALOG_FOR_FRIEND then
		local isMyfriend = SocialityBO.isMyFriend(self.player.lordId)
		local isOther = SocialityBO.isOtherFriend(self.player.lordId)
		--删好友
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local delBtn = MenuButton.new(normal, selected, disabled, handler(self,self.delFriendHandler)):addTo(self:getBg())
		delBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 26)
		delBtn:setLabel(CommonText[538][6])
		delBtn.isOther = isOther
		delBtn:setVisible(isMyfriend == true)

		-- 加好友
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local addBtn = MenuButton.new(normal, selected, disabled, handler(self,self.addFriendHandler)):addTo(self:getBg())
		addBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 26)
		addBtn:setLabel(CommonText[538][3])
		addBtn:setVisible(isMyfriend == false)

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local mailBtn = MenuButton.new(normal, selected, nil, handler(self,self.mailFriendHandler)):addTo(self:getBg())
		mailBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
		mailBtn:setLabel(CommonText[538][7])

		-- 私聊
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local chatBtn = MenuButton.new(normal, selected, nil, handler(self,self.chatFriendHandler)):addTo(self:getBg())
		chatBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 26)
		chatBtn:setLabel(CommonText[538][8])
	elseif self.viewFor == DIALOG_FOR_CHAT then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local friendBtn = MenuButton.new(normal, selected, disabled, nil):addTo(self:getBg())
		friendBtn:setPosition(self:getBg():getContentSize().width / 2 - 210, 26)

		local isMyfriend = SocialityBO.isMyFriend(self.player.lordId)
		local isOther = SocialityBO.isOtherFriend(self.player.lordId)

		if isMyfriend then
			friendBtn:setLabel(CommonText[538][6])  --删好友
			friendBtn.isOther = isOther
			friendBtn:setTagCallback(handler(self,self.delFriendHandler))
		else
			friendBtn:setLabel(CommonText[538][3])  -- 加好友
			friendBtn:setTagCallback(handler(self,self.addFriendHandler))
		end

		-- 写信
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local mailBtn = MenuButton.new(normal, selected, nil, handler(self,self.mailFriendHandler)):addTo(self:getBg())
		mailBtn:setPosition(self:getBg():getContentSize().width / 2 - 70, 26)
		mailBtn:setLabel(CommonText[538][7])

		-- 私聊
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local chatBtn = MenuButton.new(normal, selected, nil, handler(self,self.chatFriendHandler)):addTo(self:getBg())
		chatBtn:setPosition(self:getBg():getContentSize().width / 2 + 70, 26)
		chatBtn:setLabel(CommonText[538][8])

		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local shieldBtn = MenuButton.new(normal, selected, nil, handler(self, self.shieldFriendHandler)):addTo(self:getBg())
		shieldBtn:setPosition(self:getBg():getContentSize().width / 2 + 210, 26)
		if ChatBO.isShield(self.player.lordId) then
			shieldBtn:setLabel(CommonText[404][3])  -- 取消屏蔽
		else
			shieldBtn:setLabel(CommonText[404][2])  -- 屏蔽
		end

		--举报按钮
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local reportBtn = MenuButton.new(normal, selected, nil, handler(self, self.reportHandler)):addTo(self:getBg())
		reportBtn:setPosition(self:getBg():getContentSize().width / 2 + 210, 90)
		reportBtn:setLabel(CommonText[899])
		reportBtn:setVisible(not self.chat.sysId or self.chat.sysId == 0)
		reportBtn.msg = self.chat.msg

		--赠送红包
		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local redBtn = MenuButton.new(normal, selected, nil, handler(self, self.redHandler)):addTo(self:getBg())
		redBtn:setPosition(chatBtn:x(),reportBtn:y())
		redBtn:setLabel("送红包")

	elseif self.viewFor == DIALOG_FOR_WORLD_OTHER then -- 世界，其他玩家
		-- 加好友
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local friendBtn = MenuButton.new(normal ,selected, nil, handler(self, self.addFriendHandler)):addTo(self:getBg())
		friendBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 110)
		friendBtn:setLabel(CommonText[538][3])

		-- 写信
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local letterBtn = MenuButton.new(normal ,selected, nil, handler(self, self.mailFriendHandler)):addTo(self:getBg())
		letterBtn:setPosition(self:getBg():getContentSize().width / 2, 110)
		letterBtn:setLabel(CommonText[538][7])

		-- 私聊
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local chatBtn = MenuButton.new(normal, selected, nil, handler(self,self.chatFriendHandler)):addTo(self:getBg())
		chatBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 110)
		chatBtn:setLabel(CommonText[538][8])

		-- -- 将领分享
		-- local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		-- local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		-- local heroBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onHeroCallback)):addTo(self:getBg())
		-- heroBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 110)
		-- heroBtn:setLabel(CommonText[313][3])

		-- 收藏
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local storeBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onStoreCallback)):addTo(self:getBg())
		storeBtn:setPosition(self:getBg():getContentSize().width / 2 - 170, 26)
		storeBtn:setLabel(CommonText[313][4])

		-- 侦查
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local scoutBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onScoutCallback)):addTo(self:getBg())
		scoutBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
		scoutBtn:setLabel(CommonText[313][5])

		if self.player.free then -- 对手处理免战中
			scoutBtn:setEnabled(false)
		end

		local canAttack = true
		if PartyBO.getMyParty() then -- 我有军团
			local name = PartyBO.getMyPartyName()
			if self.player.party and self.player.party ~= "" and self.player.party == name then -- 我们是一个军团的，在不能攻击
				canAttack = false
			end
		end

		if canAttack then
			-- 攻击
			local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
			local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
			local atkBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onAttackCallback)):addTo(self:getBg())
			atkBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 26)
			atkBtn:setLabel(CommonText[313][6])

			if self.player.free then -- 对手处理免战中
				-- 查一下自己有没有免战将，如果有免战将，且可以出战那么可以攻击
				local heroAvoidWar = HeroMO.getNewHeroIgnoreAvoidWar()
				if heroAvoidWar == nil then
					atkBtn:setEnabled(false)
				end
			end
		else
			-- 驻军
			local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
			local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
			local guardBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onGuardCallback)):addTo(self:getBg())
			guardBtn:setPosition(self:getBg():getContentSize().width / 2 + 170, 26)
			guardBtn:setLabel(CommonText[365])
		end
	elseif self.viewFor == DIALOG_FOR_WORLD_SELF then -- 世界、自己
		-- 军团驻地
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local partyBtn = MenuButton.new(normal ,selected, disabled, handler(self, self.onPartyCallback)):addTo(self:getBg())
		partyBtn:setPosition(self:getBg():getContentSize().width / 2 - 180, 26)
		partyBtn:setLabel(CommonText[314][1])
		if not PartyBO.getMyParty() then
			partyBtn:setEnabled(false)
		end

		-- 增益
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local effectBtn = MenuButton.new(normal, selected, nil, handler(self, self.onEffectCallback)):addTo(self:getBg())
		effectBtn:setPosition(self:getBg():getContentSize().width / 2, 26)
		effectBtn:setLabel(CommonText[135])

		-- 进入基地
		local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
		local baseBtn = MenuButton.new(normal ,selected, nil, handler(self, self.onBaseCallback)):addTo(self:getBg())
		baseBtn:setPosition(self:getBg():getContentSize().width / 2 + 180, 26)
		baseBtn:setLabel(CommonText[314][2])
	end
end

function PlayerDetailDialog:addFriendHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	--判断好友上限
	if #SocialityMO.myFriends_ >= SocialityMO.friendMax then
		Toast.show(CommonText[710])
		return
	end
	Loading.getInstance():show()
	SocialityBO.asynAddFriend(function()
			Loading.getInstance():unshow()
			Toast.show(CommonText[708])
			self:pop()
		end,self.player.lordId)
	Loading.getInstance():show()
	SocialityBO.getFriend(function()
		Loading.getInstance():unshow()
		end)
end

function PlayerDetailDialog:delFriendHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function doDel()
		Loading.getInstance():show()
		SocialityBO.asynDelFriend(function()
				Loading.getInstance():unshow()
				Toast.show(CommonText[709])
				self:pop()
			end,self.player.lordId)
		Loading.getInstance():show()
		SocialityBO.getFriend(function()
			Loading.getInstance():unshow()
			end)
	end

	--如果是相互的好友
	if sender.isOther then
		require("app.dialog.TipsAnyThingDialog").new(CommonText[1870],function ()
			doDel()
		end):push()
	else
		doDel()
	end
end

function PlayerDetailDialog:mailFriendHandler()
	ManagerSound.playNormalButtonSound()

	require("app.dialog.MailSendDialog").new(self.player.nick,MAIL_SEND_TYPE_NORMAL):push()
end

function PlayerDetailDialog:chatFriendHandler()
	ManagerSound.playNormalButtonSound()

	local function doneCallback(man)
		Loading.getInstance():unshow()
		if man then -- 搜索到了
			gdump(man, "PlayerDetailDialog:chatFriendHandler")
			UiDirector.popMakeUiTop("HomeView")
			
			ChatMO.curPrivacyLordId_ = man.lordId
			local ChatView = require("app.view.ChatView")
			ChatView.new(CHAT_TYPE_CALLCENTER):push()
		else
			-- 角色不存在或不在线
			Toast.show(CommonText[355][3])
		end
	end

	Loading.getInstance():show()
	ChatBO.asynSearchOl(doneCallback, self.player.nick)
end

-- 屏蔽
function PlayerDetailDialog:shieldFriendHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	local shield = ChatBO.getShield(self.player.lordId)
	if shield then -- 已经屏蔽了
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[405][2], shield[2]), function()
				ChatBO.deleteShield(shield[1])
				self:pop()
			end):push()
	else
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[405][1], self.player.nick), function()
				if ChatBO.isShieldFull() then  -- 屏蔽列表已满
					Toast.show(CommonText[404][4])
				else
					ChatBO.addShield(self.player.lordId, self.player.nick, self.player.icon, self.player.level)
				end
				self:pop()
			end):push()
	end
end

function PlayerDetailDialog:onHeroCallback(tag, sender)
end

function PlayerDetailDialog:onStoreCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	self:pop(function()
			local StoreDialog = require("app.dialog.StoreDialog")
			StoreDialog.new(STORE_TYPE_PLAYER, self.param.pos.x, self.param.pos.y, self.player):push()
		end)
end

function PlayerDetailDialog:onScoutCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Mtime=ManagerTimer.getTime()
	local s=UserMO.prohibitedTime-Mtime
	if s>0 then
		-- 如果被禁时间大于0,则显示被禁止的时间
		local freeTime=UiUtil.strBuildTime(s, "hms")
		Toast.show("侦察功能冷却中,还有"..freeTime.."恢复")
		self:pop()
	else
		local scout = WorldMO.queryScout(self.player.level)
		local resData = UserMO.getResourceData(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)

		local function doneCallback(mail)
			Loading.getInstance():unshow()
			self:pop(function()
			require("app.view.ReportScoutView").new(mail):push()
			end)
		end
		local str = resData.name
		if scout.mulit then
			str = str .."("..scout.mulit..CommonText[988] ..")"
		end
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(string.format(CommonText[310], UiUtil.strNumSimplify(scout.scoutCost), str, UserMO.scout_ + 1), function()
			local count = UserMO.getResource(ITEM_KIND_RESOURCE, RESOURCE_ID_STONE)
			if count < scout.scoutCost then
				Toast.show(resData.name .. CommonText[223])
				UserMO.scoutValidate=true
				return
			end
			--获取是否需要验证
			PictureValidateBO.getScoutInfo(function ()
				if PictureValidateBO.validate == 1 then
					local PictureValidateDialog=require("app.dialog.PictureValidateDialog")
					local k1 = nil
					local k2 = nil
					PictureValidateBO.getValidatePic(true,function ()
						gprint("PictureValidateBO.validateKeyWord1=======",PictureValidateBO.validateKeyWord1)
						gprint("PictureValidateBO.validateKeyWord2=======",PictureValidateBO.validateKeyWord2)
						gdump(PictureValidateBO.validatePic,"得到的图片")
						if PictureValidateBO.validateKeyWord1 >100 then
							k1 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord1)
						else
							k1 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord1)
						end

						if PictureValidateBO.validateKeyWord2 >100 then
							k2 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord2)
						else
							k2 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord2)
						end
						gprint("k1====",k1)
						gprint("k2====",k2)
						local validate=PictureValidateDialog.new(k1, k2, function()
							Loading.getInstance():show()
							WorldBO.asynScoutPos(doneCallback, self.player.pos.x, self.player.pos.y)
						end)
						validate:push()
					end)
				else
					Loading.getInstance():show()
					WorldBO.asynScoutPos(doneCallback, self.player.pos.x, self.player.pos.y)
				end
			end)
		end):push()
	end
end

function PlayerDetailDialog:onAttackCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local function gotoAttack(heroAvoidWar)
		local num = UserMO.getResource(ITEM_KIND_POWER)
		if num < 1 then  --能量不足
			require("app.dialog.BuyPawerDialog").new():push()
			local resData = UserMO.getResourceData(ITEM_KIND_POWER)
			Toast.show(resData.name .. CommonText[223])
			return
		end

		WorldMO.curAttackPos_ = cc.p(self.param.pos.x, self.param.pos.y)

		self:pop(function()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_WORLD, nil, heroAvoidWar):push()
		end)
	end

	if self.player.free then -- 如果对手是免战还进了这一段逻辑
		local function realWork( ... )
			-- body
			local heroAvoidWar = HeroMO.getNewHeroIgnoreAvoidWar()
			if heroAvoidWar then
				local curTime = ManagerTimer.getTime()
				local skillCanUse = (curTime >= heroAvoidWar.cd or heroAvoidWar.cd == 0)
				if not skillCanUse then
					local cdClearTotalCount = UserMO.getIgnoreAvoidWarCDClearCount()
					local cdClearCount = heroAvoidWar.cdClearCount
					if cdClearCount == nil then
						cdClearCount = 0
					end
					local cdClearRemains = cdClearTotalCount - cdClearCount
					if cdClearRemains > 0 then
						-- 破罩技能处理冷却状态是否要花费金币清除冷却
						local NewHeroCDConfirmDialog = require("app.dialog.NewHeroCDConfirmDialog")
						local goldPerM = UserMO.getIgnoreAvoidWarCDClearCost()
						local remain_s = heroAvoidWar.cd - curTime
						NewHeroCDConfirmDialog.new(function()
							HeroBO.clearHeroCd(function ()
								-- body
								local valid, _ = EffectBO.getEffectValid(EFFECT_ID_FREE_WAR)
								if valid then -- 是免战
									local ConfirmDialog = require("app.dialog.ConfirmDialog")
									ConfirmDialog.new(CommonText[430], function() gotoAttack(heroAvoidWar) end):push()
								else
									gotoAttack(heroAvoidWar)
								end
							end, heroAvoidWar.heroId)
						end, nil, nil, remain_s, goldPerM, cdClearRemains):push()
					else
						Toast.show(CommonText[2202])
						return
					end
				else
					local valid, _ = EffectBO.getEffectValid(EFFECT_ID_FREE_WAR)
					if valid then -- 是免战
						local ConfirmDialog = require("app.dialog.ConfirmDialog")
						ConfirmDialog.new(CommonText[430], function() gotoAttack(heroAvoidWar) end):push()
					else
						gotoAttack(heroAvoidWar)
					end
				end
			else
				Toast.show(CommonText[2205])
			end
		end

		-- 先拉取cd再处理逻辑
		HeroBO.getHeroCd(realWork)
	else
		local valid, _ = EffectBO.getEffectValid(EFFECT_ID_FREE_WAR)
		if valid then -- 是免战
			local ConfirmDialog = require("app.dialog.ConfirmDialog")
			ConfirmDialog.new(CommonText[430], function() gotoAttack() end):push()
		else
			gotoAttack()
		end
	end
end

function PlayerDetailDialog:onGuardCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	WorldMO.curGuardPos_ = cc.p(self.param.pos.x, self.param.pos.y)
	
	self:pop(function()
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_FOR_GUARD):push()
		end)
end

function PlayerDetailDialog:onPartyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function()
			if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
				Loading.getInstance():show()
				PartyBO.asynGetParty(function()
						--进入军团场景
						Loading.getInstance():unshow()
						UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_PARTY)
					end, 0)
			else
				--打开军团列表
				Loading.getInstance():show()
				PartyBO.asynGetPartyRank(function()
					Loading.getInstance():unshow()
					require("app.view.AllPartyView").new():push()
					end, 0, PartyMO.allPartyList_type_)
			end
		end)
end

function PlayerDetailDialog:onEffectCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function() require("app.view.EffectView").new():push() end)
end

function PlayerDetailDialog:onBaseCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	self:pop(function() UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_BASE) end)
end

function PlayerDetailDialog:reportHandler(tag, sender)
	ManagerSound.playNormalButtonSound()

	-- local shield = ChatBO.getShield(self.player.lordId)
	local ConfirmDialog = require("app.dialog.ConfirmDialog")
	ConfirmDialog.new(string.format(CommonText[900], self.player.nick), function()
				ChatBO.asynTipGuy(function()
					self:pop()
					end, self.player.lordId,sender.msg)
			end):push()
end

function PlayerDetailDialog:redHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	local data = UserMO.getAllRedPes()
	if #data <= 0 then
		Toast.show(CommonText[1820])
		return
	end
	local worldPoint = sender:getParent():convertToWorldSpace(cc.p(sender:getPositionX(), sender:getPositionY()))
	require("app.dialog.RedPesDialog").new(worldPoint,self.player):push()
end

-- function PlayerDetailDialog:onExit()
-- 	if self.closeCb then self.closeCb() end
-- end

return PlayerDetailDialog