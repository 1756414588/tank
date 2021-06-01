--
-- Author: Gss
-- Date: 2018-04-11 17:02:51
--
-- 每个队伍有多少个位置
CHALLENGE_TROOPS_NUM = 3

local BTN_CREATE_TEAM = 1
local BTN_FIND_TEAM = 2
local BTN_CONFIG_ARMY = 3
local BTN_DISMISS_TEAM = 4
local BTN_LUANCH_ATTACK = 5
local BTN_LEAVE_TEAM = 6
local BTN_GET_READY = 7

--如果移动距离过短，则不判断发生了移动
local function convertDistanceFromPointToInch(pointDis)
	local factor = ( CCEGLView:sharedOpenGLView():getScaleX() + CCEGLView:sharedOpenGLView():getScaleY() ) / 2
	return pointDis * factor / CCDevice:getDPI()
end


-- 队伍中的每个小节点位置
local TroopNode = class("TroopNode", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function TroopNode:ctor(posIndex, troopData, sectionId)
	local normal = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png"):addTo(self)
	normal:setPosition(normal:getContentSize().width / 2, normal:getContentSize().height / 2)
	normal:setVisible(true)
	normal:setScale(0.8)

	local selected = display.newSprite(IMAGE_COMMON .. "chose_1.png"):addTo(self)
	selected:setPosition(normal:x(), normal:y())
	selected:setVisible(false)   -- 初始不可见

	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(cc.size(normal:getContentSize().width, normal:getContentSize().height))
	self.normal_ = normal
	self.selected_ = selected

	self.posIndex = posIndex
	self.m_sectionId = sectionId

	self:update(troopData)
end

function TroopNode:update(troopData)
	self.m_param = troopData

	if self.node_ then
		self.node_:removeSelf()
		self.node_ = nil
	end

	local node = display.newNode():addTo(self)
	node:setContentSize(cc.size(self:getContentSize().width, self:getContentSize().height))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self.node_ = node

	--当前格子队伍为空
	if self.m_param == nil then
		local tag = display.newSprite(IMAGE_COMMON .. "icon_plus.png")

		local function inviteOthers()
			if UserMO.lordId_ == HunterBO.captainRoleId then
				if HunterBO.world_invite_enable == true then
					HunterBO.inviteMember(self.m_sectionId, function ()
						-- body
					end)
					HunterBO.world_invite_enable = false
					if HunterBO.inviteScheduler == nil then
						HunterBO.inviteScheduler = scheduler.performWithDelayGlobal(function ()
							HunterBO.world_invite_enable = true
							HunterBO.inviteScheduler = nil
						end, 30)
					end
					Toast.show("邀请已发出")
				else
					Toast.show("你已经发出过邀请，请30s后再试")
				end
			else
				Toast.show("权限不足，无法邀请")
			end
		end

		local lookBtn = ScaleButton.new(tag, inviteOthers):addTo(self.node_)
		lookBtn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

		ui.newTTFLabel({text = "发送邀请", font = G_FONT, size = FONT_SIZE_TINY, x = self:getContentSize().width / 2, y = 34, align = ui.TEXT_ALIGN_CENTER, color = COLOR[2]}):addTo(self.node_)
	else
		local value = self.m_param.portrait
		local portrait = value % 100
		if portrait < 1 then
			portrait = 1
		elseif portrait > PendantMO.PORTRAIT_MAX_ID then
			portrait = PendantMO.PORTRAIT_MAX_ID
		end
		local head = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, portrait):addTo(node)
		head:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
		head:setScale(0.8)

		if self.m_param.isCaptain then
			local skillBtn = display.newSprite(IMAGE_COMMON .. "bounty_captain.png"):addTo(head)
			local _portrait = PendantMO.queryPortrait(portrait)
			if _portrait.isdynamic > 0 then
				skillBtn:setPosition(-70, head:getContentSize().height - 70)
			else
				skillBtn:setPosition(0, head:getContentSize().height - 5)
			end
		end
	end
end

function TroopNode:setNormal()
	if not self.m_lock then
		self.normal_:setVisible(true)
		self.selected_:setVisible(false)
	end
end

function TroopNode:setSelected()
	if not self.m_lock then
		self.normal_:setVisible(true)
		self.selected_:setVisible(true)
	end
end

function TroopNode:setChosen()
	if not self.m_lock then
		if self.chosen_ then self.chosen_:setVisible(true) end
		if self.unchosen_ then self.unchosen_:setVisible(false) end
	end
end

function TroopNode:setUnchosen()
	if not self.m_lock then
		if self.chosen_ then self.chosen_:setVisible(false) end
		if self.unchosen_ then self.unchosen_:setVisible(true) end
	end
end

function TroopNode:isLock()
	return self.m_lock
end

-- 队伍聊天界面
local TeamChatView = class("TeamChatView", TableView)

function TeamChatView:ctor(size)
	TeamChatView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	local cell_width = self:getViewSize().width
	print("cell_width!!", cell_width)
	self.m_cellSize = cc.size(cell_width, 60)
	-- self.m_viewFor = viewFor
end

function TeamChatView:onEnter()
	TeamChatView.super.onEnter(self)
end

function TeamChatView:numberOfCells()
	return #HunterBO.teamChats
end

function TeamChatView:cellSizeForIndex(index)
	return self.m_cellSize
end

function TeamChatView:createCellAtIndex(cell, index)
	TeamChatView.super.createCellAtIndex(self, cell, index)

	local chats = HunterBO.teamChats
	local chat = chats[index]
	local roleId = chat.roleId

	local nickName = ""
	local color = nil
	if roleId == UserMO.lordId_ then
		nickName = "我"
		color = COLOR[6]
	else
		nickName = chat.name
		if HunterMO.teamFightCrossData_.state == 2 then
			nickName = chat.name.."("..chat.serName..")"
		end
		color = COLOR[3]
	end

	-- 显示最后一条聊天记录
	local stringDatas = {}
	local show_msg = string.format("%s: %s", nickName, chat.content)
	stringDatas[1] = {["content"] = show_msg, color=color}
	local msg = RichLabel.new(stringDatas, self.m_cellSize):addTo(cell, 100)
	msg:setPositionY(self.m_cellSize.height / 2 + 15)

	return cell
end

function TeamChatView:reloadData()
	TeamChatView.super.reloadData(self)
end

-----------------------------------------------------------------------------------------------------------
--新极限挑战View
-----------------------------------------------------------------------------------------------------------
local CombatHunterView = class("CombatHunterView", UiNode)

function CombatHunterView:ctor(sectionId, enterStyle, param)
	enterStyle = enterStyle or UI_ENTER_NONE
	CombatHunterView.super.ctor(self, "image/common/bg_ui.jpg", enterStyle)
	self.m_sectionId = sectionId
	self.m_param = param
	-- self.m_isCaptain = false
	self.m_isChatOpen = false
	self.m_send_show_content = ""
	self.m_containerNode = nil
	self.m_positionNodes = {}
	HunterBO.lastSectionId = sectionId
end

function CombatHunterView:onEnter()
	CombatHunterView.super.onEnter(self)

	self.m_hndTeaminfo = Notify.register(LOCAL_TEAM_INFO_EVENT, handler(self, self.onTeamInfoUpdate))
	self.m_hndTeamKickOut = Notify.register(LOCAL_TEAM_KICK_OUT_EVENT, handler(self, self.onTeamKickOut))
	self.m_hndSynTeamOrder = Notify.register(LOCAL_TEAM_ORDER_EVENT, handler(self, self.onSynTeamOrder))
	self.m_hndSynTeamChat = Notify.register(LOCAL_TEAM_CHAT_EVENT, handler(self, self.onSynTeamChat))
	self.m_hndTeamDissmiss = Notify.register(LOCAL_TEAM_DISMISS_EVENT, handler(self, self.onSynDismissTeam))
	self.m_hndSynChangeStatus = Notify.register(LOCAL_TEAM_CHANGE_STATUS_EVENT, handler(self, self.onSynChangeStatus))
	self.m_hndSynTeamStageClose = Notify.register(LOCAL_TEAM_STAGE_CLOSE_EVENT, handler(self, self.onSynTeamStageClose))

	local sectionDB = HunterMO.queryStageById(self.m_sectionId)
	self:setTitle(sectionDB.name)

	-- self.m_isCaptain = false
	self.m_isChatOpen = false
	self.m_send_show_content = ""
	self.m_containerNode = nil
	self:showBOSS()
	self:showReady()
	self:createChatPanel()
	-- self:showTroops()
end

function CombatHunterView:showBOSS()
	-- local sectionDB = CombatMO.querySectionById(self.m_sectionId)
	local sectionDB = HunterMO.queryStageById(self.m_sectionId)
	local showBoss = sectionDB.showBoss
	local bountyBossDB = HunterMO.queryBossById(showBoss)

	local bgFile = nil
	if showBoss == 1 then
		bgFile = "bounty_railgun_bg.jpg"
	else
		bgFile = "bounty_boss_bg.jpg"
	end

	local bg = display.newSprite(IMAGE_COMMON .. bgFile):addTo(self:getBg())
	bg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():height() - bg:height() / 2 - 100)

	local name = UiUtil.label(sectionDB.bg):addTo(bg)
	name:setPosition(bg:width() / 2, bg:height() - 20)

	local function gotoDetail(tag, sender)
		ManagerSound.playNormalButtonSound()
		local DetailTextDialog = require("app.dialog.DetailTextDialog")
		DetailTextDialog.new(DetailText.bountyBoss):push()
	end
	local btn = UiUtil.button("btn_detail_normal.png","btn_detail_selected.png",nil,gotoDetail):addTo(bg):align(display.CENTER_TOP, bg:getContentSize().width - 53, bg:getContentSize().height - 38)

	local icon = showBoss
	local boss = display.newSprite(IMAGE_COMMON .. "bounty_boss" .. icon..".png"):addTo(bg)
	boss:setPosition(bg:getContentSize().width / 2, 210)
	self.m_bossSprite = boss
	self.m_bossSprite:setVisible(showBoss ~= 1)

	--左边
	local leftBg = display.newScale9Sprite(IMAGE_COMMON .. "bounty_left_bg.png"):addTo(bg, 2)
	leftBg:setPreferredSize(cc.size(150, 220))
	leftBg:setPosition(leftBg:width() / 2 + 30, btn:y() - leftBg:height() / 2)

	-- local titleBgL = display.newScale9Sprite(IMAGE_COMMON .. "btn_49_normal.png"):addTo(leftBg)
	-- titleBgL:setPosition(leftBg:width() / 2, leftBg:height())
	local intelligence = UiUtil.label("敌军情报"):addTo(leftBg)
	intelligence:setPosition(leftBg:width() / 2, leftBg:height() - intelligence:getContentSize().height / 2)

	--名称
	local bossName = UiUtil.label("名称：", 18):addTo(leftBg)
	bossName:setAnchorPoint(cc.p(0,0.5))
	bossName:setPosition(5, intelligence:y() - intelligence:height() / 2 - 25)

	local bossNameDetail = UiUtil.label(bountyBossDB.name, 18, COLOR[99]):addTo(leftBg):rightTo(bossName)
	bossNameDetail:setAnchorPoint(cc.p(0,0.5))

	--技能
	local skill = UiUtil.label("技能：",18):addTo(leftBg)
	skill:setAnchorPoint(cc.p(0,0.5))
	skill:setPosition(5, bossName:y() - 40)

	local skillIconPath = IMAGE_COMMON .. "bounty_boss_skill" .. bountyBossDB.skill .. ".jpg"

	local skillId = bountyBossDB.skill
	local skillDB = HunterMO.getBountySkillById(skillId)
	local skillDesc = skillDB.desc
	local skillName = skillDB.name

	local skillBtn = display.newSprite(skillIconPath):addTo(leftBg):rightTo(skill)
	skillBtn:setScale(0.5)

	local skillDetail = nil
	skillBtn:setTouchEnabled(true)
	skillBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			skillDetail = UiUtil.createSkillView(1, nil, {name = skillName,desc = skillDesc}):addTo(leftBg):rightTo(skill, 50)
			skillDetail:setAnchorPoint(cc.p(0,0.5))
			local origPosY = skillDetail:getPositionY()
			skillDetail:setPositionY(origPosY + 50)
			return true
		elseif event.name == "ended" then
			skillDetail:removeSelf()
		end
	end)

	--战力
	local power = UiUtil.label("战力：",18):addTo(leftBg)
	power:setAnchorPoint(cc.p(0,0.5))
	power:setPosition(5, skill:y() - 30)

	local powerDetail = UiUtil.label(UiUtil.strNumSimplify(bountyBossDB.fight), 18, COLOR[99]):addTo(leftBg):rightTo(power)
	powerDetail:setAnchorPoint(cc.p(0,0.5))

	--奖励
	local award_json = sectionDB.award
	-- 副本已挑战次数
	local passTime = HunterBO.getStageChanllCount(self.m_sectionId)
	-- 今日已获得金币数
	local todayCoinGot = HunterBO.todayCoinGot
	local offPercent = HunterMO.getBountyBenefitOffPercent()

	local color = COLOR[1]
	if todayCoinGot >= HunterMO.getBountyCoinGainedMax() then
		award_json = 0
		color = COLOR[2]
	else
		if passTime >= sectionDB.count then
			award_json = award_json * offPercent / 100.0
			color = COLOR[2]
		end
	end

	local award = UiUtil.label(string.format("奖励：%d", award_json), 18, color):addTo(leftBg)
	award:setAnchorPoint(cc.p(0,0.5))
	award:setPosition(5, power:y() - 30)

	local awardPic = display.newSprite("image/common/bounty_coin.png"):addTo(leftBg):rightTo(award,10)
	awardPic:setScale(0.5)

	--波数
	local wave = UiUtil.label("波数：", 18):addTo(leftBg)
	wave:setAnchorPoint(cc.p(0,0.5))
	wave:setPosition(5, award:y() - 30)

	local waveDetail = UiUtil.label(sectionDB.wave, 18, COLOR[6]):addTo(leftBg):rightTo(wave)
	waveDetail:setAnchorPoint(cc.p(0,0.5))

	--右边
	local rightBg = display.newScale9Sprite(IMAGE_COMMON .. "bounty_right_bg.png"):addTo(bg)
	rightBg:setPreferredSize(cc.size(620, 100))
	rightBg:setPosition(bg:width() / 2, rightBg:height() / 2)

	-- local titleBgR = display.newScale9Sprite(IMAGE_COMMON .. "btn_49_normal.png"):addTo(rightBg)
	-- titleBgR:setPosition(leftBg:width() / 2, leftBg:height())

	local introduction = UiUtil.label("BOSS简介", 20, COLOR[99]):addTo(rightBg)
	introduction:setAnchorPoint(cc.p(0,0.5))
	introduction:setPosition(5, 100 - introduction:getContentSize().height / 2)

	local textInfo = UiUtil.label(bountyBossDB.desc,18,nil,
		cc.size(630, 0), ui.TEXT_ALIGN_LEFT):addTo(rightBg)
	textInfo:setPosition(10, introduction:y() - introduction:getContentSize().height / 2 - textInfo:height() / 2 - 5)
	textInfo:setAnchorPoint(cc.p(0,1))

	local decoLine = display.newSprite("image/common/line3.png"):addTo(bg, 10)
	decoLine:setPosition(bg:getContentSize().width / 2, 0)
end

--创建队伍
function CombatHunterView:showReady()
	if self.m_containerNode == nil then
		local containerNode = display.newNode():addTo(self:getBg())
		self.m_containerNode = containerNode
		--寻找队伍
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local findBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(self.m_containerNode,0,BTN_FIND_TEAM)
		findBtn:setPosition(self:getBg():width() / 2,120)
		findBtn:setLabel("寻找队伍")

		--创建队伍
		local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local autoBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(self.m_containerNode,0,BTN_CREATE_TEAM):leftTo(findBtn,60)
		autoBtn:setLabel("组建队伍")

		--设置阵型
		local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
		local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
		local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
		local settingBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(self.m_containerNode,0,BTN_CONFIG_ARMY):rightTo(findBtn,60)
		settingBtn:setLabel("设置阵型")
	end
end

function CombatHunterView:closeReady()
	-- body
	if self.m_containerNode then
		self.m_containerNode:removeAllChildren()
		self.m_containerNode:removeSelf()
		self.m_containerNode = nil
	end
end


function CombatHunterView:createChatPanel()
	-- body
	-- 创建聊天背景
	local chatBg = display.newScale9Sprite(IMAGE_COMMON .. "chat_bg.png"):addTo(self:getBg(), 99)
	local bgHeight = self:getBg():height() - 500
	chatBg:setPreferredSize(cc.size(self:getBg():width() - 20, bgHeight))
	chatBg:setPosition(self:getBg():width() / 2, bgHeight / 2 + 158)


	local view = TeamChatView.new(cc.size(chatBg:getContentSize().width, chatBg:getContentSize().height - 20)):addTo(chatBg)
	view:setPosition(0, 10)

	self.m_ChatView = view

	local btmNode = display.newNode():addTo(chatBg)
	btmNode:setPosition(0, -56)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(btmNode)
	local width = chatBg:getContentSize().width - 58 * 3
	local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)
	inputBg:setPreferredSize(cc.size(width, height))
	inputBg:setPosition(width / 2 + 5, 30)

	local function onEdit(event, editbox)
		if event == "began" then
			self.m_send_show_content = editbox:getText()
		elseif event == "changed" then
			self.m_send_show_content = editbox:getText()
		end
	end

	local inputMsg = ui.newEditBox({x = inputBg:getPositionX(), y = 28, size = cc.size(width, height), listener = onEdit}):addTo(btmNode)
	inputMsg:setFontColor(COLOR[11])
	inputMsg:setPlaceholderFontColor(COLOR[11])
	inputMsg:setPlaceHolder(CommonText[353])
	inputMsg:setMaxLength(CHAT_MAX_LENGTH)
	self.m_inputMsg = inputMsg

	-- 表情
	local normal = display.newSprite(IMAGE_COMMON .. "btn_express_normal_s.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_express_selected_s.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onExpressCallback)):addTo(btmNode)
	btn:setPosition(chatBg:getContentSize().width - 140, 28)

	-- 发送
	local normal = display.newSprite(IMAGE_COMMON .. "btn_send_normal_s.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_send_selected_s.png")
	local btn = MenuButton.new(normal, selected, nil, handler(self, self.onSendCallback)):addTo(btmNode)
	btn:setPosition(chatBg:getContentSize().width - 84, 28)

	self.m_chatNode = chatBg
	self.m_chatNode:setVisible(false)
end

function CombatHunterView:onExpressCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local ExpressDialog = require("app.dialog.ExpressDialog")
	local dialog = ExpressDialog.new(handler(self, self.onClickExpress)):push()
	if dialog then
		dialog:getBg():setPosition(display.cx, 160 + dialog:getBg():getContentSize().height / 2)
	end
end

function CombatHunterView:onClickExpress(id)
	local express = UserMO.express[id]
	self.m_send_show_content = self.m_send_show_content .. express.desc
	self.m_inputMsg:setText(self.m_send_show_content)
end

function CombatHunterView:onSendCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	local content = string.trim(self.m_inputMsg:getText())

	-- 如果发送的空字符串
	if content == "" then
		Toast.show(CommonText[355][1])
		return
	end

	-- 如果发送的长度不符合要求
	local length = string.utf8len(content)
	if length > CHAT_MAX_LENGTH or length < 0 then
		Toast.show(CommonText[355][2])
		return
	end

	local content = WordMO.filterSensitiveWords(content)

	HunterBO.teamChat(content, function (time)
		-- 处理聊天
		table.insert(HunterBO.teamChats, {roleId=UserMO.lordId_, content=content, time=time, name=UserMO.nickName_, serName = ""})
		table.sort(HunterBO.teamChats, function(a,b) return a.time < b.time end)
		self.m_ChatView:reloadData()
		self:onViewOffset(self.m_ChatView)
		self.m_inputMsg:setText("")
		self.m_send_show_content = ""
	end)
end

function CombatHunterView:showChatPanel(isShow)
	-- body
	if self.m_isChatOpen == false and isShow == true then
		-- 如果是打开聊天界面操作
		HunterBO.unreadMsgCount = 0
		UiUtil.unshowTip(self.m_chatButton)
	end

	self.m_isChatOpen = isShow
	self.m_chatNode:setVisible(isShow)
	if isShow == false then
		local uiName = UiDirector.getTopUiName()
		if uiName == "ExpressDialog" then
			UiDirector.pop()
		end
	end
end

--队伍详情
function CombatHunterView:showTroops()
	-- BG
	-- local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	-- bg:setPreferredSize(cc.size(self:getBg():width() - 20, self:getBg():height() - 550))
	-- bg:setPosition(self:getBg():width() / 2, bg:height() / 2 + 20)
	local bg = display.newNode():addTo(self:getBg())
	self.m_troopBg = bg

	--title
	-- local title = UiUtil.label("队伍",18):addTo(bg)
	-- title:setPosition(bg:width() / 2, bg:height())

	local teamInfos = HunterBO.teamInfos
	local teamOrders = HunterBO.teamOrders
	local captainRoleId = HunterBO.captainRoleId
	local isCaptain = (captainRoleId == UserMO.lordId_)
	local showKick = isCaptain
	gdump(teamInfos, "showTroops teamInfos==")
	gdump(teamOrders, "showTroops teamOrders==")

	--队伍
	for index=1,CHALLENGE_TROOPS_NUM do
		local mateInfo = nil
		local roleId = nil
		if index <= #teamOrders then
			roleId = teamOrders[index]
			if roleId then
				mateInfo = teamInfos[roleId]
			end
		end
		print("mateInfo!!", mateInfo)

		if self.m_positionNodes[index] then
			self.m_positionNodes[index]:removeSelf()
			self.m_positionNodes[index] = nil
		end

		if mateInfo and roleId then
			if roleId == captainRoleId then
				mateInfo.isCaptain = true
			else
				mateInfo.isCaptain = false
			end
		end

		local node = TroopNode.new(index, mateInfo, self.m_sectionId):addTo(bg)
		local position = self:getPositionAtIndex(index)
		node:setPosition(position.x, position.y)

		nodeTouchEventProtocol(node, handler(self, self.onTouch), nil, nil, false)
		node:setTouchSwallowEnabled(false)

		self.m_positionNodes[index] = node

		if mateInfo ~= nil then
			--玩家名字
			local nameBg = display.newScale9Sprite(IMAGE_COMMON .. "bg_name.png"):addTo(bg)
			nameBg:setPosition(node:x(),node:y() - node:height() / 2 + 10)

			local name = UiUtil.label("名字最多八个字母",18,COLOR[3]):addTo(bg)
			name:setPosition(node:x(),node:y() - node:height() / 2 + 10)
			local nickName = mateInfo.nick
			name:setString(nickName)

			--战力
			local powerIcon = display.newScale9Sprite(IMAGE_COMMON .. "bounty_fight_bg.png"):addTo(bg)
			powerIcon:setPosition(name:x(), name:y() - 35)

			local fight = UiUtil.label(UiUtil.strNumSimplify(mateInfo.fight),18,COLOR[2]):addTo(bg)
			fight:setPosition(name:x(),name:y() - 35)

			--准备(根据服务端的推送判断是否是绿色或者灰色)
			local ready = display.newScale9Sprite(IMAGE_COMMON .. "check1.png"):addTo(bg)
			ready:setPosition(powerIcon:x() - 40, powerIcon:y() - 30)
			ready:setScale(0.6)
			ready:setVisible(mateInfo.status == 0)

			local function viewPlayerInfo()
				-- gprint("查看玩家信息roleid=", mateInfo.roleId)
				HunterBO.lookMemberInfo(mateInfo.roleId, function (fight, formation, commander)
					-- body
					gdump("viewPlayerInfo formation==", formation)
					local TeammateInfoDialog = require("app.dialog.TeammateInfoDialog")
					local dialog = TeammateInfoDialog.new(fight, formation, nickName, commander):push()
				end)
			end

			--玩家信息
			local normal = display.newSprite(IMAGE_COMMON .. "bounty_team.png")
			local lookBtn = ScaleButton.new(normal, viewPlayerInfo):addTo(bg):rightTo(ready)
			lookBtn:setScale(0.6)

			local function kickPlayer()
				gprint("踢出该玩家roleid=", mateInfo.roleId)
				HunterBO.kickOut(mateInfo.roleId, function ()
					-- body
				end)
			end

			--踢出队伍
			local normal = display.newSprite(IMAGE_COMMON .. "bounty_kick.png")
			local shotBtn = ScaleButton.new(normal, kickPlayer):addTo(bg):rightTo(lookBtn)
			shotBtn:setScale(0.6)
			if showKick == true then
				if mateInfo.roleId == UserMO.lordId_ then
					-- 自己不能踢自己
					shotBtn:setVisible(false)
				else
					shotBtn:setVisible(true)
				end
			else
				shotBtn:setVisible(showKick)
			end
			
		end
	end

	--解散队伍
	local btn_tag = nil
	local btnLabelContent = ""
	if isCaptain == true then
		btn_tag = BTN_DISMISS_TEAM
		btnLabelContent = "解散队伍"
	else
		btn_tag = BTN_LEAVE_TEAM
		btnLabelContent = "离开队伍"
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local destroyBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(bg,0,btn_tag)
	destroyBtn:setPosition(self:getBg():width() / 2,50)
	destroyBtn:setLabel(btnLabelContent) --队长

	--出击
	local btn_tag1 = nil
	local btnLabelContent1 = ""
	if isCaptain == true then
		btn_tag1 = BTN_LUANCH_ATTACK
		btnLabelContent1 = "出击"
	else
		btn_tag1 = BTN_GET_READY
		ready = (HunterBO.teamInfos[UserMO.lordId_].status == 0)
		if ready then
			btnLabelContent1 = "取消准备"
		else
			btnLabelContent1 = "准备"
		end
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local hitBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(bg,0,btn_tag1):leftTo(destroyBtn,60)
	hitBtn:setLabel(btnLabelContent1)

	--设置阵型
	local normal = display.newSprite(IMAGE_COMMON .. "btn_19_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_19_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local settingBtn = MenuButton.new(normal, selected, disabled, handler(self, self.TroopsHandler)):addTo(bg,0,BTN_CONFIG_ARMY):rightTo(destroyBtn,60)
	settingBtn:setLabel("设置阵型")

	--tips
	local tips = UiUtil.label("提示：队长可通过拖动队员头像调整出战顺序。",18):addTo(bg)
	tips:setPosition(self:getBg():getContentSize().width / 2,settingBtn:y() + 50)
	tips:setAnchorPoint(cc.p(0.5, 0.5))

	-- 聊天按钮
	local function gotoChat()
		ManagerSound.playNormalButtonSound()

		if self.m_chatNode then
			self:showChatPanel(not self.m_isChatOpen)
		end
	end

	-- 聊天按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	local chatBtn = MenuButton.new(normal, selected, nil, gotoChat):addTo(bg, 5)
	chatBtn:setPosition(self:getBg():getContentSize().width - 35, settingBtn:y() + 80)

	self.m_chatButton = chatBtn

	if HunterBO.unreadMsgCount > 0 and self.m_isChatOpen == false then
		UiUtil.showTip(self.m_chatButton, HunterBO.unreadMsgCount, 42, 42)
	end
end

function CombatHunterView:joinTeamUI()
	-- body
	-- 如果查找队伍成功
	self:closeReady()
	self:openTeamInfoPanel()
end

function CombatHunterView:onViewOffset(tableView, offset)
	local maxOffset = tableView:maxContainerOffset()
	local minOffset = tableView:minContainerOffset()
	if minOffset.y > maxOffset.y or not offset then
		local y = math.max(maxOffset.y, minOffset.y)
		tableView:setContentOffset(cc.p(0, y))
	elseif offset then
		tableView:setContentOffset(offset)
	end
end

function CombatHunterView:openTeamInfoPanel()
	-- 打开队伍详细信息面板
	-- body
	self:showTroops()

	if self.m_ChatView then
		self.m_ChatView:reloadData()
		self:onViewOffset(self.m_ChatView)
	end
end

function CombatHunterView:updateTeamInfoPanel()
	-- body
	self:closeReady()
	self:closeTeamInfoPanel()
	self:showTroops()
end

function CombatHunterView:closeTeamInfoPanel()
	-- body
	if self.m_troopBg then
		self.m_troopBg:removeAllChildren()
		self.m_troopBg:removeSelf()
		self.m_troopBg = nil

		self.m_positionNodes = {} --初始化队伍节点
	end
end

function CombatHunterView:TroopsHandler(tag,sender)
	if self.m_isChatOpen == true then return end
	ManagerSound.playNormalButtonSound()
	if tag == BTN_CREATE_TEAM then --创建队伍
		-- 一条协议上去, 告诉服务器我要创建赏金BOSS的战斗
		gprint("发送协议CreateTeam, teamType=%d", self.m_sectionId)
		HunterBO.createTeam(self.m_sectionId, function()
			self:closeReady()
			-- self.m_isCaptain = true
			self:openTeamInfoPanel()
		end
		)
	elseif tag == BTN_DISMISS_TEAM then --解散队伍
		gprint("发送协议DismissTeam")
		HunterBO.dismissTeam(function ()
			HunterBO.clear()
			self:closeTeamInfoPanel()
			self:showReady()
		end)
	elseif tag == BTN_LEAVE_TEAM then -- 离开队伍
		gprint("发送协议LeaveTeam")
		HunterBO.leaveTeam(function ()
			HunterBO.clear()
			self:closeTeamInfoPanel()
			self:showReady()
		end)
	elseif tag == BTN_CONFIG_ARMY then --设置阵型
		local teamId = HunterBO.teamId
		if teamId then
			local isCaptain = (HunterBO.captainRoleId == UserMO.lordId_)
			local isReady = (HunterBO.teamInfos[UserMO.lordId_].status == 0)
			if isCaptain == false and isReady == true then
				-- 你必须先取消准备才能重新设置阵型
				Toast.show("你必须先取消准备才能重新设置阵型")
			else
				local ArmyView = require("app.view.ArmyView")
				local view = ArmyView.new(ARMY_VIEW_HUNTER):push()
			end
		else
			local ArmyView = require("app.view.ArmyView")
			local view = ArmyView.new(ARMY_VIEW_HUNTER):push()
		end
	elseif tag == BTN_FIND_TEAM then --寻找队伍
		gprint("发送协议FindTeam")
		HunterBO.findTeam(self.m_sectionId, function ()
		end)

	elseif tag == BTN_LUANCH_ATTACK then --- 发起攻击
		--队伍出击
		HunterBO.teamFightBoss(function ()
			-- body
			-- 开始战斗协议发送成功
			gprint("TeamFightBossRs recieved")
		end
		)
	elseif tag == BTN_GET_READY then
		--队伍准备
		gprint("发送协议GetReady")
		HunterBO.changeMemberReadyState(function ()
		end)
	end
end


function CombatHunterView:onTouch(event)
	if event.name == "began" then
		return self:onTouchBegan(event)
	elseif event.name == "moved" then
		self:onTouchMoved(event)
	elseif event.name == "ended" then
		self:onTouchEnded(event)
	else -- cancelled
		self:onTouchCancelled(event)
	end
end

function CombatHunterView:onTouchBegan(event)
	if self.m_isChatOpen == true then return end
	local isCaptain = (UserMO.lordId_ == HunterBO.captainRoleId)
	if isCaptain == false then
		return false
	end
	local captureIndex = 0
	for index = 1, CHALLENGE_TROOPS_NUM do
		local point = self:convertToNodeSpace(cc.p(event.x, event.y))

		local viewNode = self.m_positionNodes[index]

		if cc.rectContainsPoint(viewNode:getBoundingBox(), point) then
			captureIndex = index
			break
		end
	end

	self.m_touchMoved = false
	self.m_touchPoint = cc.p(event.x, event.y)
	self.m_touchIndex = captureIndex

	-- 如果有点到队伍上面的人
	if captureIndex > 0 then
		-- 把非当前结点的zorder和选中状态设置一下
		for index = 1, CHALLENGE_TROOPS_NUM do
			if index ~= self.m_touchIndex then
				local viewNode = self.m_positionNodes[index]
				viewNode:setZOrder(1)
				viewNode:setNormal()
				viewNode:setUnchosen()
			end
		end

		self:onBeganPosition(captureIndex)
		return true
	else
		return false
	end
end

function CombatHunterView:onTouchMoved(event)
	if self.m_touchIndex == 0 then return end

	local newPoint = cc.p(event.x, event.y)
	local moveDistance = cc.PointSub(newPoint, self.m_touchPoint)

	if not self.m_touchMoved then
		local dis = math.sqrt(moveDistance.x * moveDistance.x + moveDistance.y * moveDistance.y)
		if math.abs(convertDistanceFromPointToInch(dis)) < 0.04375 then
			return false
		end
	end

	if not self.m_touchMoved then
		moveDistance = cc.p(0, 0)
	end

	self.m_touchPoint = newPoint
	self.m_touchMoved = true

	local curViewNode = self.m_positionNodes[self.m_touchIndex]

	-- 移动你选择的结点
	local newPos = cc.p(curViewNode:getPositionX() + moveDistance.x, curViewNode:getPositionY() + moveDistance.y)
	curViewNode:setPosition(newPos.x, newPos.y)

	local find = self:findNeighbouring(self.m_touchIndex)

	for index = 1, CHALLENGE_TROOPS_NUM do
		if index ~= self.m_touchIndex then
			local viewNode = self.m_positionNodes[index]
			if find == index then
				viewNode:setSelected()
			else
				viewNode:setNormal()
			end
		end
	end
end

function CombatHunterView:onTouchEnded(event)
	if self.m_touchIndex == 0 then return end

	if self.m_touchMoved then
		local find = self:findNeighbouring(self.m_touchIndex)
		if find > 0 then  -- 两个node需要交换位置
			-- local findNode = self.m_positionNodes[find]
			-- 交换view
			local teamOrders = HunterBO.teamOrders
			local role1 = teamOrders[self.m_touchIndex]
			local role2 = teamOrders[find]

			-- print("m_touchIndex==", self.m_touchIndex)
			-- print("find==", find)
			-- print("role1==",  role1)
			-- print("role2==",  role2)

			gdump(teamOrders, "onTouchEnded teamOrders==")

			-- 发送交换协议
			HunterBO.exchangeOrder(self.m_touchIndex, find, function ()
				-- body
			end)

			teamOrders[find] = role1
			teamOrders[self.m_touchIndex] = role2

			local tmp = self.m_positionNodes[self.m_touchIndex]
			self.m_positionNodes[self.m_touchIndex] = self.m_positionNodes[find]
			self.m_positionNodes[find] = tmp

			self.m_touchIndex = find -- 更新当前索引的位置
		end

		-- 播放移动动画
		for index = 1, CHALLENGE_TROOPS_NUM do
			local viewNode = self.m_positionNodes[index]

			local position = self:getPositionAtIndex(index)

			if viewNode then
				if index ~= self.m_touchIndex then
					viewNode:runAction(transition.sequence({cc.EaseBackOut:create(cc.MoveTo:create(0.18, cc.p(position.x, position.y))), cc.CallFunc:create(function() viewNode:setZOrder(1) end)}))
				else
					viewNode:runAction(transition.sequence({cc.CallFunc:create(function()
						--do some
					  end),
						cc.MoveTo:create(0.18, cc.p(position.x, position.y)),
						cc.CallFunc:create(function()
								viewNode:setZOrder(1)
							end)}))
				end
			end
		end
	else
		-- 判断当前选中的是否可以触发点击事件
		local point = self:convertToNodeSpace(cc.p(event.x, event.y))
		if self.m_touchIndex ~= 0 and cc.rectContainsPoint(self.m_positionNodes[self.m_touchIndex]:getBoundingBox(), point) then
			self:onPositionCallback(self.m_touchIndex)
		end
	end

	for index = 1, CHALLENGE_TROOPS_NUM do
		local viewNode = self.m_positionNodes[index]
		if index ~= self.m_touchIndex then
			if not viewNode:isLock() then
				viewNode:setNormal()
			end
		else
			if not viewNode:isLock() then
				viewNode:setSelected()
			end
		end
	end

	self.m_touchIndex = 0
	self.m_touchPoint = cc.p(0, 0)
	self.m_touchMoved = false
end

function CombatHunterView:onTouchCancelled(event)
	for index = 1, CHALLENGE_TROOPS_NUM do
		local viewNode = self.m_positionNodes[index]
		if index ~= self.m_touchIndex then
			viewNode:setNormal()
		else
			viewNode:setSelected()
		end
	end

	self.m_touchIndex = 0
	self.m_touchPoint = cc.p(0, 0)
	self.m_touchMoved = false
end

function CombatHunterView:onBeganPosition(position)
	local viewNode = self.m_positionNodes[position]

	viewNode:setZOrder(2)
	viewNode:setSelected()
	viewNode:setChosen()

	self.m_chosePosition = position
	-- self:dispatchEvent({name = "FORMATION_BEGAN_EVENT", position = position})
end

-- 查找curPosIndex的节点最近可互换位置的node，返回可互换位置node的索引
function CombatHunterView:findNeighbouring(curPosIndex)
	local curViewNode = self.m_positionNodes[curPosIndex]

	for index = 1, CHALLENGE_TROOPS_NUM do
		if curPosIndex ~= index then
			local viewNode = self.m_positionNodes[index]

			local deltaX = curViewNode:getPositionX() - viewNode:getPositionX()
			local deltaY = curViewNode:getPositionY() - viewNode:getPositionY()
			local dis = math.sqrt(deltaX * deltaX + deltaY * deltaY)

			if dis <= curViewNode:getContentSize().height / 2 then
				return index
			end
		end
	end
	return 0
end

-- 某个位置被点击到了
function CombatHunterView:onPositionCallback(position)
	ManagerSound.playNormalButtonSound()
	--根据position判断
	--如果当前选择的位置有队伍则显示选中，否则就发起集结公告

end

function CombatHunterView:getPositionAtIndex(index)
	return cc.p(90 + 220 *(index - 1), self:getBg():height() - 660)
end

function CombatHunterView:onExit()
	if self.m_hndTeaminfo then
		Notify.unregister(self.m_hndTeaminfo)
		self.m_hndTeaminfo = nil
	end

	if self.m_hndTeamKickOut then
		Notify.unregister(self.m_hndTeamKickOut)
		self.m_hndTeamKickOut = nil
	end

	if self.m_hndSynTeamOrder then
		Notify.unregister(self.m_hndSynTeamOrder)
		self.m_hndSynTeamOrder = nil
	end

	if self.m_hndSynTeamChat then
		Notify.unregister(self.m_hndSynTeamChat)
		self.m_hndSynTeamChat = nil
	end

	if self.m_hndTeamDissmiss then
		Notify.unregister(self.m_hndTeamDissmiss)
		self.m_hndTeamDissmiss = nil
	end

	if self.m_hndSynChangeStatus then
		Notify.unregister(self.m_hndSynChangeStatus)
		self.m_hndSynChangeStatus = nil
	end

	if self.m_hndSynTeamStageClose then
		Notify.unregister(self.m_hndSynTeamStageClose)
		self.m_hndSynTeamStageClose = nil
	end

	self:closeReady()

	CombatHunterView.super.onExit(self)
end

function CombatHunterView:onTeamInfoUpdate(event)
	local tp = event.obj.type
	if tp == 1 then
		self:joinTeamUI()
	elseif tp == 2 then
		self:updateTeamInfoPanel()
	elseif tp == 3 then
		self:updateTeamInfoPanel()
	elseif tp == 4 then
		self:updateTeamInfoPanel()
	elseif tp == 7 then
		self:updateTeamInfoPanel()
	end
end

function CombatHunterView:onTeamKickOut(event)
	-- body
	Toast.show("你已经被队长移除出了队伍")
	self:showChatPanel(false)
	self:closeTeamInfoPanel()
	self:showReady()
end

function CombatHunterView:onSynTeamOrder(event)
	-- body
	self:updateTeamInfoPanel()
end

function CombatHunterView:onSynTeamChat(event)
	-- body
	if self.m_isChatOpen == false then
		-- 如果聊天框是关闭状态
		HunterBO.unreadMsgCount = HunterBO.unreadMsgCount + 1
		local tip = UiUtil.showTip(self.m_chatButton, HunterBO.unreadMsgCount, 42, 42)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	end

	if self.m_ChatView then
		self.m_ChatView:reloadData()
		self:onViewOffset(self.m_ChatView)
	end
end

function CombatHunterView:onSynDismissTeam(event)
	-- body
	Toast.show("队长已经解散了队伍")
	self:showChatPanel(false)
	self:closeTeamInfoPanel()
	self:showReady()
end


function CombatHunterView:onSynChangeStatus(event)
	-- body
	self:updateTeamInfoPanel()
end


function CombatHunterView:onSynTeamStageClose(event)
	-- body
	Toast.show("当前挑战因为超过开放时间而关闭, 队伍已解散")
	self:closeTeamInfoPanel()
	self:showReady()
end


-- 重载，要做特殊处理
function CombatHunterView:onReturnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	if HunterBO.teamId ~= nil then  -- 如果有队伍
		local function DissmissTeam()
			HunterBO.dismissTeam(function ()
				self:CloseAndCallback()
				self:pop()
			end)
		end

		local function LeaveTeam()
			HunterBO.leaveTeam(function ()
				-- 当离开退伍成功时
				self:CloseAndCallback()
				self:pop()
			end)
		end

		local dialogStr = ""
		local okFunc = nil
		if UserMO.lordId_ == HunterBO.captainRoleId then
			dialogStr = "确认要解散队伍吗?"
			okFunc = DissmissTeam
		else
			dialogStr= "确认要离开队伍吗?"
			okFunc = LeaveTeam
		end

		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(dialogStr, function()
			okFunc()
		end):push()
	else
		-- 直接退出
		self:CloseAndCallback()
		self:pop()
	end
end

return CombatHunterView
