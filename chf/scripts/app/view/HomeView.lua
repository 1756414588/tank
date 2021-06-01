
MAIN_SHOW_BASE = 1 -- 基地
MAIN_SHOW_WILD = 2 -- 野外
MAIN_SHOW_WORLD = 3 -- 世界
MAIN_SHOW_PARTY = 4 -- 军团
MAIN_SHOW_MINE_AREA = 5 -- 军事矿区
MAIN_SHOW_FORTRESS = 6 -- 军团要塞战
MAIN_SHOW_MONEYTANK = 7 -- 高级金币车
MAIN_SHOW_CROSSSERVER_MINE_AREA = 8 -- 跨服军事矿区

------------------------------------------------------------------------------
-- 主场景的头部玩家信息view
------------------------------------------------------------------------------
local HeadView = class("HeadView", function()
	local node = display.newNode()
	node:setNodeEventEnabled(true)
    nodeExportComponentMethod(node)
	return node
end)

function HeadView:ctor()
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_4.png"):addTo(self)
	bg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

	self:setContentSize(bg:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))

	-- display.newSprite(IMAGE_COMMON.."ui_top.png")
	-- 	:addTo(self,9999):align(display.LEFT_TOP, 0, self:height())
	nodeTouchEventProtocol(bg, function(event) end, nil, nil, true)
end

function HeadView:onEnter()
	self:showUI()

	self.expHandler_ = Notify.register(LOCAL_EXP_EVENT, handler(self, self.onUpdateInfo))
	self.resHandler_ = Notify.register(LOCAL_RES_EVENT, handler(self, self.onUpdateInfo))
	self.powerHandler_ = Notify.register(LOCAL_POWER_EVENT, handler(self, self.onUpdateInfo))
	self.fightHandler_ = Notify.register(LOCAL_FIGHT_EVENT, handler(self, self.onUpdateInfo))
	self.prosHandler_ = Notify.register(LOCAL_PROSPEROUS_EVENT, handler(self, self.onUpdateInfo))
	self.portraitHandler_ = Notify.register(LOCAL_PORTRAIT_EVENT, handler(self, self.onUpdateInfo))
	self.nickHandler_ = Notify.register(LOCAL_NICK_EVENT, handler(self, self.onUpdateInfo))
	self.m_effectHandler = Notify.register(LOCAL_EFFECT_EVENT, handler(self, self.onUpdateEffect))
end

function HeadView:onExit()
	Notify.unregister(self.expHandler_)
	self.expHandler_ = nil

	Notify.unregister(self.resHandler_)
	self.resHandler_ = nil

	Notify.unregister(self.powerHandler_)
	self.powerHandler_ = nil

	Notify.unregister(self.fightHandler_)
	self.fightHandler_ = nil

	Notify.unregister(self.prosHandler_)
	self.prosHandler_ = nil

	Notify.unregister(self.portraitHandler_)
	self.portraitHandler_ = nil

	Notify.unregister(self.nickHandler_)
	self.nickHandler_ = nil

	Notify.unregister(self.m_effectHandler)
	self.m_effectHandler = nil
end

local itemIds = {RESOURCE_ID_STONE, RESOURCE_ID_IRON, RESOURCE_ID_OIL, RESOURCE_ID_COPPER, RESOURCE_ID_SILICON}

function HeadView:showUI()
	-- check0.jpg
	local top = display.newScale9Sprite(IMAGE_COMMON .. "check0.jpg"):addTo(self, 1)
	top:setPreferredSize(cc.size(display.width, 65))
	top:setAnchorPoint(cc.p(0.5,1))
	top:setPosition(display.cx, self:getContentSize().height)

	-- local bottom = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_20.png"):addTo(self, -1)
	-- bottom:setPreferredSize(cc.size(display.width, bottom:getContentSize().height))
	-- bottom:setPosition(display.cx, self:getContentSize().height - bottom:getContentSize().height / 2)

	local function gotoGold(tag, sender)
		-- require("app.view.RechargeView").new():push()
		RechargeBO.openRechargeView()
	end
	-- goldbtn 金币
	local normal = display.newSprite(IMAGE_COMMON .. "btn_coin_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_coin_selected.png")
	local goldBtn = MenuButton.new(normal, selected, nil, gotoGold):addTo(self, 2)
	goldBtn:setPosition(self:getContentSize().width - goldBtn:width() * 0.5, self:getContentSize().height - goldBtn:getContentSize().height * 0.5)

	-- gold number
	local getCoinLabel = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = 10, y = goldBtn:height() - 20, align = ui.TEXT_ALIGN_CENTER}):addTo(goldBtn)
	getCoinLabel:setAnchorPoint(cc.p(0, 0.5))
	getCoinLabel:setString(UserMO.getResource(ITEM_KIND_COIN))
	self.coinLabel_ = getCoinLabel


	local function gotoFightValue()
		ManagerSound.playNormalButtonSound()
		require("app.view.FightValueView").new():push()
	end
	-- 战斗力
	local normal = display.newSprite(IMAGE_COMMON .. "info_bg_power.png")
	local fightValueBtn = TouchButton.new(normal, nil, nil, nil, gotoFightValue):addTo(self, 2)
	fightValueBtn:setPosition(goldBtn:x() - goldBtn:width() * 0.5 - fightValueBtn:width() * 0.5, self:getContentSize().height - fightValueBtn:getContentSize().height * 0.5)

	local fightValueLabel = ui.newTTFLabel({text = "", font = G_FONT, color = cc.c3b(173, 252, 255), x = fightValueBtn:getContentSize().width / 2, y = fightValueBtn:height() * 0.5 - 10}):addTo(fightValueBtn)
	self.m_fightLabel = fightValueLabel


	local function gotoVip()
		ManagerSound.playNormalButtonSound()
		require("app.view.VipView").new():push()
	end
	-- VIP
	local normal = display.newSprite(IMAGE_COMMON .. "info_bg_123.png")
	local vipBtn = TouchButton.new(normal, nil, nil, gotoVip):addTo(self, 4)
	vipBtn:setPosition(fightValueBtn:x() - fightValueBtn:width() * 0.5 - vipBtn:width() * 0.5, self:getContentSize().height - vipBtn:getContentSize().height * 0.5)
	-- self.m_vipBtn = vipBtn

	local vipicon = display.newSprite(IMAGE_COMMON .. "vip_new.png"):addTo(vipBtn)
	vipicon:setPosition(vipBtn:width() * 0.5, vipBtn:height() * 0.5)

	local getVIPLabel = ui.newBMFontLabel({text = "", font = "fnt/num_9.fnt", x = vipBtn:width() * 0.5, y = 12, align = ui.TEXT_ALIGN_CENTER}):addTo(vipBtn)
	self.m_viplb = getVIPLabel


	local function gotoPlayer(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.PlayerView").new():push()
	end
	-- 头像
	local normal = display.newSprite(IMAGE_COMMON .. "bg_head_new.png")
	local infoBtn = TouchButton.new(normal,nil, nil, nil, gotoPlayer):addTo(self, 4)
	infoBtn:setPosition(infoBtn:width() * 0.5 , self:getContentSize().height - infoBtn:height() * 0.5)
	self.m_portraitBtn = infoBtn

	-- 头像
	local head = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, 0):addTo(self.m_portraitBtn, 2)
	head:setPosition(self.m_portraitBtn:getContentSize().width * 0.5, self.m_portraitBtn:getContentSize().height * 0.5 + 10)
	head:setScale(0.65)
	self.m_portraitBtn.portrait = head

	-- namebg 
	-- local namebg = display.newSprite(IMAGE_COMMON .. "bg_name.png"):addTo(self.m_portraitBtn, 3)
	-- namebg:setPosition(self.m_portraitBtn:getContentSize().width * 0.5, 10 + namebg:height() * 1.5)
	-- -- 名称
	-- self.nickNameLabel_ = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_TINY, x = self.m_portraitBtn:getContentSize().width * 0.5, y = namebg:height() * 0.5, color = cc.c3b(252, 230,171), align = ui.TEXT_ALIGN_CENTER}):addTo(namebg)
	-- 等级
	self.lvLabel_ = ui.newTTFLabel({text = "100", font = G_FONT, size = FONT_SIZE_TINY, x = 12, y = 10, color = cc.c3b(23, 175, 179), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_portraitBtn, 4)
	-- 经验
	local expBar = ProgressBar.new(IMAGE_COMMON .. "bar_15.png", BAR_DIRECTION_HORIZONTAL, cc.size(83,8), {bgName = IMAGE_COMMON .. "bar_bg_14.png"}):addTo(self.m_portraitBtn, 4)
	expBar:setPosition(22 + expBar:getContentSize().width / 2, 17)
	expBar:setPercent(100)
	self.expBar_ = expBar

	-- 能量
	local powerBar = ProgressBar.new(IMAGE_COMMON .. "bar_16.png", BAR_DIRECTION_HORIZONTAL, cc.size(83, 8), {bgName = IMAGE_COMMON .. "bar_bg_14.png"}):addTo(self.m_portraitBtn, 4)
	powerBar:setPosition(22 + powerBar:getContentSize().width / 2, 7)
	powerBar:setPercent(100)
	self.powerBar_ = powerBar

	local function gotoRes()
		ManagerSound.playNormalButtonSound()
		-- 仓库储备
		UiDirector.push(require("app.view.ReserverView").new())
	end
	-- 4个资源的信息背景
	local normal = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_37.png")
	normal:setPreferredSize(cc.size(self:getContentSize().width, 63))
	local resInfoBtn = TouchButton.new(normal, nil, nil, gotoRes):addTo(self)
	resInfoBtn:setTouchSwallowEnabled(true)
	resInfoBtn:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height - top:height() - resInfoBtn:height() * 0.5 + 25)

	local pos = {0, 100, 195, 290, 385}
	self.m_resLabel = {}
	for index = 1, #itemIds do
		local id = itemIds[index]

		local tag = UiUtil.createItemSprite(ITEM_KIND_RESOURCE, id):addTo(resInfoBtn)
		tag:setAnchorPoint(cc.p(0, 0.5))
		tag:setPosition(pos[index] + infoBtn:width() + 20, resInfoBtn:getContentSize().height / 2 - 5 - 10)

		-- self.m_resLabel[index] = ui.newBMFontLabel({text = "", font = "fnt/num_1.fnt", x = tag:getPositionX() + 22, y = resInfoBtn:getContentSize().height / 2 - 2}):addTo(resInfoBtn)
		self.m_resLabel[index] = ui.newTTFLabelWithOutline({text = "", font = G_FONT, size = FONT_SIZE_SMALL + 2, color = cc.c3b(255, 222, 0), x = tag:getPositionX() + tag:getBoundingBox().size.width, y = tag:getPositionY()}):addTo(resInfoBtn)
		self.m_resLabel[index]:setAnchorPoint(cc.p(0, 0.5))
		self.m_resLabel[index]:setScale(0.8)
	end

	-- 繁荣度
	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_124.png"):addTo(self)
	bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(infoBtn:width(), resInfoBtn:y() - resInfoBtn:height() * 0.5 - bg:height() * 0.5)

	local resData = UserMO.getResourceData(ITEM_KIND_PROSPEROUS)
	local label = ui.newTTFLabel({text = resData.name2 .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 8, y = bg:getContentSize().height / 2, color = cc.c3b(252, 230,171), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[2], align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_prosLabel = value

	local value = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = value:getPositionX() + value:getContentSize().width, y = value:getPositionY(), color = cc.c3b(252, 230,171), align = ui.TEXT_ALIGN_CENTER}):addTo(bg)
	value:setAnchorPoint(cc.p(0, 0.5))
	self.m_prosMaxLabel = value


	local function gotoEffect(tag, sender)
		ManagerSound.playNormalButtonSound()
		require("app.view.EffectView").new():push()
	end
	self.m_effectButtons = {}
	-- 增益
	for index = 1, 3 do

		local normal = display.newSprite(IMAGE_COMMON .. "btn_effect.png")
		local effectBtn = ScaleButton.new(normal, gotoEffect):addTo(self)
		effectBtn:setPosition(effectBtn:width() / 2 + (index - 1) * 48, infoBtn:y() - infoBtn:height() / 2 - effectBtn:height() / 2 )
		self.m_effectButtons[index] = effectBtn

	end

	self:onUpdateInfo()

	self:onUpdateEffect()

	if RoyaleSurviveMO.tipOpenFlag == true then
		local InfoDialog = require("app.dialog.InfoDialog")
		InfoDialog.new(CommonText[2105], function() end, cc.size(500, 300), cc.p(0, -40)):push()
		RoyaleSurviveMO.tipOpenFlag = false
	end
end

function HeadView:onUpdateInfo(event)
	-- gprint("金币:", UserMO.coin_)
	-- 金币
	if self.coinLabel_ then
		self.coinLabel_:setString(UserMO.getResource(ITEM_KIND_COIN))
	end
	

	-- 战斗力
	if self.m_fightLabel then
		self.m_fightLabel:setString(UiUtil.strNumSimplify(UserMO.fightValue_))
	end
	
	-- VIP
	if self.m_viplb then
		self.m_viplb:setString(UserMO.vip_)
	end

	-- 头像
	if self.m_portraitBtn.portrait then
		self.m_portraitBtn.portrait:removeSelf()
		self.m_portraitBtn.portrait = nil
	end
	local portraitID = UserMO.portrait_
	if portraitID >= 100 then
		local q, p = UserBO.parsePortrait(portraitID)  -- 有头像和挂件
		portraitID = q
	end
	local head = UiUtil.createItemSprite(ITEM_KIND_PORTRAIT, portraitID):addTo(self.m_portraitBtn, 2)
	head:setPosition(self.m_portraitBtn:getContentSize().width * 0.5, self.m_portraitBtn:getContentSize().height * 0.5 + 10)
	head:setScale(0.65)
	self.m_portraitBtn.portrait = head


	-- self.nickNameLabel_:setString(UserMO.nickName_)
	if UserMO.level_ >= 100 then
		if self.lvLabel_ then
			self.lvLabel_:removeSelf()
			self.lvLabel_ = nil
		end
		self.lvLabel_ = ui.newTTFLabel({text = "100", font = G_FONT, size = 12, x = 12, y = 10, color = cc.c3b(23, 175, 179), align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_portraitBtn, 4)
		self.lvLabel_:setString(tostring(UserMO.level_))
	else
		self.lvLabel_:setString(tostring(UserMO.level_))
	end

	self.m_prosLabel:setString(UserMO.getResource(ITEM_KIND_PROSPEROUS))
	self.m_prosMaxLabel:setString("/" .. UserMO.maxProsperous_)
	self.m_prosMaxLabel:setPosition(self.m_prosLabel:getPositionX() + self.m_prosLabel:getContentSize().width, self.m_prosLabel:getPositionY())


	if UserBO.isLordFullLevel() then
		self.expBar_:setPercent(1)
	else
		local nxtLord = UserMO.queryLordByLevel(UserMO.level_ + 1)
		self.expBar_:setPercent(UserMO.exp_ / nxtLord.needExp)
	end

	self.powerBar_:setPercent(UserMO.getResource(ITEM_KIND_POWER) / POWER_MAX_VALUE)


	for index = 1, #itemIds do
		self.m_resLabel[index]:setString(UiUtil.strNumSimplify(UserMO.getResource(ITEM_KIND_RESOURCE, itemIds[index])))
	end
end

function HeadView:onUpdateEffect(event)
	for index = 1, #self.m_effectButtons do
		if self.m_effectButtons[index].buff then
			self.m_effectButtons[index].buff:removeSelf()
			self.m_effectButtons[index].buff = nil
		end
	end

	local showData = {}
	local hasShow = false

	local effects = EffectBO.getShowEffects()
	for index = 1, #effects do
		local effect = effects[index]
		local valid, _ = EffectBO.getEffectValid(effect.effectId)
		if valid then
			local showType = EffectMO.getEffectShowType(effect.effectId)
			if showType ~= 0 then
				showData[showType] = true
				hasShow = true
			end
		end
	end

	if hasShow then
		local num = 1
		for index = 1, EFFECT_SHOW_TYPE_RESOURCE do
			if showData[index] then
				local button = self.m_effectButtons[num]

				local sprite = display.newSprite(IMAGE_COMMON .. "icon_buff_" .. index .. ".png"):addTo(button)
				sprite:setPosition(button:getContentSize().width / 2, button:getContentSize().height / 2)
				button.buff = sprite

				num = num + 1
			end
		end
	end
end

------------------------------------------------------------------------------
-- 主场景的头部增益效果信息
------------------------------------------------------------------------------

-- local EffectInfoView = class("EffectInfoView", function()
-- 	local node = display.newNode()
-- 	node:setNodeEventEnabled(true)
--     nodeExportComponentMethod(node)
-- 	return node
-- end)

-- function EffectInfoView:ctor()
-- end

-- function EffectInfoView:onEnter()
-- 	self.m_effectHandler = Notify.register(LOCAL_EFFECT_EVENT, handler(self, self.updateEffect))
-- end

-- function EffectInfoView:onExit()
-- 	if self.m_effectHandler then
-- 		Notify.unregister(self.m_effectHandler)
-- 		self.m_effectHandler = nil
-- 	end
-- end

-- function EffectInfoView:updateEffect()
-- 	self:removeAllChildren()

-- 	local showData = {}
-- 	local hasShow = false

-- 	local effects = EffectBO.getShowEffects()
-- 	for index = 1, #effects do
-- 		local effect = effects[index]
-- 		local valid, _ = EffectBO.getEffectValid(effect.effectId)
-- 		if valid then
-- 			local showType = EffectMO.getEffectShowType(effect.effectId)
-- 			if showType ~= 0 then
-- 				showData[showType] = true
-- 				hasShow = true
-- 			end
-- 		end
-- 	end

-- 	local function gotoEffect(tag, sender)
-- 		ManagerSound.playNormalButtonSound()
-- 		require("app.view.EffectView").new():push()
-- 	end

-- 	if hasShow then
-- 		local num = 1
-- 		for index = 1, EFFECT_SHOW_TYPE_RESOURCE do
-- 			if showData[index] then
-- 				local sprite = display.newSprite(IMAGE_COMMON .. "icon_buff_" .. index .. ".png")
-- 				local btn = TouchButton.new(sprite, nil, nil, nil, gotoEffect):addTo(self)
-- 				btn:setAnchorPoint(cc.p(0, 0.5))
-- 				btn:setPosition((btn:getContentSize().width + 10) * (num - 1), 0)

-- 				num = num + 1
-- 			end
-- 		end
-- 	else
-- 		local sprite = display.newSprite(IMAGE_COMMON .. "info_bg_42.png")
-- 		local btn = TouchButton.new(sprite, nil, nil, nil, gotoEffect):addTo(self)
-- 		btn:setAnchorPoint(cc.p(0, 0.5))
-- 		btn:setPosition(0, -2)

-- 		-- 增益
-- 		local label = ui.newTTFLabel({text = CommonText[135], font = G_FONT, size = FONT_SIZE_TINY, x = btn:getContentSize().width / 2, y = btn:getContentSize().height / 2 + 10, align = ui.TEXT_ALIGN_CENTER}):addTo(btn)
-- 	end
-- end


------------------------------------------------------------------------------
-- 首页，主场景view
------------------------------------------------------------------------------
local HomeView = class("HomeView", UiNode)

function HomeView:ctor(mainShowIndex)
	HomeView.super.ctor(self)

	self.m_curShowIndex = mainShowIndex or MAIN_SHOW_BASE  -- 默认是基地
	
	if self.m_curShowIndex == MAIN_SHOW_MINE_AREA then  -- 军事矿区
		self.__cname = "HomeView1"
	elseif self.m_curShowIndex == MAIN_SHOW_FORTRESS then
		self.__cname = "HomeView2"
	elseif self.m_curShowIndex == MAIN_SHOW_CROSSSERVER_MINE_AREA then -- 跨服军事矿区
		self.__cname = "HomeView3"
	end
end

function HomeView:onEnter()
	HomeView.super.onEnter(self)
	if UserMO.querySystemId(49) == 1 then
		--雪花效果
		local path = "animation/effect/bg_huoxing.plist"
	    local particleSys = cc.ParticleSystemQuad:create(path)
	    particleSys:setPosition(display.width/2, display.height/2)
	    particleSys:addTo(self, 999)
	end

	HomeBO.NO_OPERATE_FREE_TIMER = 0

	-- self:hasCoinButton(true)

	-- local coinBtn = self:getCoinButton()
	-- coinBtn:setScale(GAME_X_SCALE_FACTOR)
	-- coinBtn:setPosition(self:getBg():getContentSize().width - coinBtn:getBoundingBox().size.width / 2,
	-- 	self:getBg():getContentSize().height - coinBtn:getBoundingBox().size.height / 2)

	self.m_starZoom = true

	self.m_locationHandler = Notify.register(LOCAL_LOCATION_EVENT, handler(self, self.onLocationUpdate))
	self.m_locationMilitaryAreaHandler = Notify.register(LOCAL_LOCATION_MILITARY_AREA_EVENT, handler(self.onLocationMilitaryAreaUpdate))
	self.m_showWildHandler = Notify.register(LOCAL_SHOW_WILD_EVENT, handler(self, self.onShowWildUpdate))
	self.m_armyHandler = Notify.register(LOCAL_ARMY_EVENT, handler(self, self.onArmyUpdate))
	self.m_chatHandler = Notify.register(LOCAL_SERVER_CHAT_EVENT, handler(self, self.onChatUpdate))
	self.m_readChatHandler = Notify.register(LOCAL_READ_CHAT_EVENT, handler(self, self.onChatUpdate))

	self.m_timerHandler = ManagerTimer.addTickListener(handler(self, self.onTick))

	self.m_showNewerGuideHandler = Notify.register(LOCAL_SHOW_NEWER_GUIDE_EVENT, handler(self, self.onShowNewerGuide))

	self.m_showTaskGuideHandler = Notify.register(LOCAL_SHOW_TASK_GUIDE_EVENT, handler(self, self.onShowTaskGuide))

	self.m_showTriggerNewerHandler = Notify.register(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT, handler(self, self.onShowTriggerGuide))

	self.m_showPushHandler = Notify.register(LOCAL_SHOW_PUSH_EVENT, handler(self, self.onPushComment))


	local btmBg = display.newSprite(IMAGE_COMMON .. "info_bg_3.png"):addTo(self, 3)
	btmBg:setScale(GAME_X_SCALE_FACTOR)
	btmBg:setPosition(display.cx, btmBg:getBoundingBox().size.height / 2)
	-- display.newSprite(IMAGE_COMMON.."ui_down.png"):addTo(btmBg,999):align(display.LEFT_BOTTOM, 0, 0)
	self.m_bottomBg = btmBg
	nodeTouchEventProtocol(btmBg, function(event) end, nil, nil, true)

	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		local snowBg = display.newSprite("image/screen/a_bg_3.png"):addTo(btmBg, 100)
		snowBg:setPosition(btmBg:getContentSize().width / 2, snowBg:getContentSize().height / 2)
	else
		if UserMO.querySystemId(49) == 1 then
			local snowBg = display.newSprite("image/screen/a_bg_8.png"):addTo(btmBg, 100)
			snowBg:setPosition(btmBg:getContentSize().width / 2, btmBg:getContentSize().height / 2 + 10)
		end
	end

	self:showChosenIndex(self.m_curShowIndex)

	local function gotoChat()
		ManagerSound.playNormalButtonSound()

		if ChatMO.showChat_ then
			require("app.view.ChatView").new():push()
		else
			require("app.view.ChatSearchView").new():push()
		end
	end

	-- 聊天按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_chat_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_chat_selected.png")
	local chatBtn = MenuButton.new(normal, selected, nil, gotoChat):addTo(btmBg, 2)
	chatBtn:setPosition(btmBg:getContentSize().width - 30, 120)
	self.m_chatButton = chatBtn

	local ChatButtonView = require("app.view.ChatButtonView")
	local view = ChatButtonView.new():addTo(btmBg)
	view:setPosition(view:getContentSize().width / 2, btmBg:getContentSize().height - view:getContentSize().height / 2 + 10)

	-- 主界面底部菜单TableView
	local HomeButtonTableView = require("app.scroll.HomeButtonTableView")
	local tableView = HomeButtonTableView.new(cc.size(494, 100)):addTo(btmBg)
	tableView:setPosition(146, 0)
	tableView:reloadData()
	self.m_homeButtonTableView = tableView

	-- if SignMO.dailyLogin_.display and not SignMO.dailyLogin_.accept then  -- 要显示而没有领取的
	-- 	local DailyLoginDialog = require("app.dialog.DailyLoginDialog")
	-- 	DailyLoginDialog.new():push()
	-- end

	local function partyBSignHandler(tag, sender)
		ManagerSound.playNormalButtonSound()

		--判断等级
		if UserMO.level_ < BuildMO.getOpenLevel(BUILD_ID_PARTY) then
			local build = BuildMO.queryBuildById(BUILD_ID_PARTY)
			Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(BUILD_ID_PARTY), build.name))
			return
		end

		--判断是否有军团
		if PartyMO.partyData_.partyId and PartyMO.partyData_.partyId > 0 then
			require("app.view.PartyBattleView").new():push()
		else
			--打开军团列表
			Loading.getInstance():show()
			PartyBO.asynGetPartyRank(function()
				Loading.getInstance():unshow()
				require("app.view.AllPartyView").new():push()
				end, 0, PartyMO.allPartyList_type_)
		end
		
	end
	--百团混战报名按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_45_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_45_selected.png")
	local partyBSignBtn = MenuButton.new(normal, selected, nil, partyBSignHandler):addTo(self, 150)
	self.m_partyBSignBtn = partyBSignBtn

	--百团混战战况按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_46_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_46_selected.png")
	local partyBBtn = MenuButton.new(normal, selected, nil, partyBSignHandler):addTo(self, 150)
	self.m_partyBBtn = partyBBtn

	UserMO.startCheckFight_ = true

	UserBO.triggerFightCheck()

	self:showArmy()
	
	self:onChatUpdate()

	self:onShowNewerGuide()

	self:updatePartyBattle()

	self:checkNewFunction()

	-- -- 在这里就去拉赏金的关卡信息
	-- HunterBO.getTeamFightBossInfo(function ()
	-- 	-- body
	-- end)
end

-- 检测新功能
function HomeView:checkNewFunction()
	-- print("检测新功能")
	-- 秘密武器
	if UserMO.queryFuncOpen(UFP_WARWEAPON) and 
		UserMO.level_ >= UserMO.querySystemId(48) and 
		not TriggerGuideBO.guideIsDone(70) and 
		not WarWeaponBO.isHaveSkill() then
		-- 延迟2秒 检测新功能
		scheduler.performWithDelayGlobal(function()
        	WarWeaponBO.GetSecretWeaponInfo(function ()
	            TriggerGuideMO.currentStateId = 70
	            Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
	            Notify.notify(LOCAL_HOME_LIMIT_ITEM)
	        end)
        end, 2)

        return
	end
end

function HomeView:onMainCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if self.m_curShowIndex == MAIN_SHOW_MINE_AREA or self.m_curShowIndex == MAIN_SHOW_FORTRESS
	or self.m_curShowIndex == MAIN_SHOW_MONEYTANK or self.m_curShowIndex == MAIN_SHOW_CROSSSERVER_MINE_AREA then
		gprint("HomeView onMainCallback pop mine area!!!!!!!!!!")
		if not self:pop() then
			self:showChosenIndex(self.m_perIndex or MAIN_SHOW_BASE)
		end
		return
	end

	local index = 0
	if self.m_curShowIndex == MAIN_SHOW_BASE then
		if UserMO.level_ < 2 and UserMO.newerGift_ == 0 then Toast.show(CommonText[691]) return end
		index = MAIN_SHOW_WILD
	elseif self.m_curShowIndex == MAIN_SHOW_WILD then index = MAIN_SHOW_WORLD
	elseif self.m_curShowIndex == MAIN_SHOW_WORLD then index = MAIN_SHOW_BASE
	elseif self.m_curShowIndex == MAIN_SHOW_PARTY then index = MAIN_SHOW_BASE
	end

	self:showChosenIndex(index)

	-- 从城内到城外的转场动画
	-- if index == MAIN_SHOW_WILD then
		-- armature_add(IMAGE_ANIMATION .. "effect/ui_home_cloud.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_home_cloud.plist", IMAGE_ANIMATION .. "effect/ui_home_cloud.xml")

	 --    local node = display.newNode():addTo(self, 1000)
	 --    node:setContentSize(cc.size(display.width, display.height))
	 --    node.index = index
	 --    nodeTouchEventProtocol(node, function(event) end, nil, nil, true)

		-- local armature = armature_create("ui_home_cloud", display.cx, display.cy,
		-- 	function (movementType, movementID, armature)
		-- 		if movementType == MovementEventType.COMPLETE then
		-- 			armature:getParent():removeSelf()
		-- 		end
		-- 	end):addTo(node, 1000)
	 --    armature:getAnimation():playWithIndex(0)
	 --    armature:getAnimation():setSpeedScale(1.2)
	 --    node:runAction(transition.sequence({cc.DelayTime:create(0.6), cc.CallFuncN:create(function(sender)
	 --    		self:showChosenIndex(sender.index)
	 --    	end)}))
	-- else
	-- 	self:showChosenIndex(index)
	-- end
end

function HomeView:showChosenIndex(showIndex)
	self.m_perIndex = self.m_curShowIndex
	self.m_curShowIndex = showIndex

	self:showMainUI()
	self:showMainButton()
	if self.fortressBtn then self.fortressBtn:removeSelf() self.fortressBtn = nil end
	if self.redblueBtn then self.redblueBtn:removeSelf() self.redblueBtn = nil end
	if self.rebelBtn then self.rebelBtn:removeSelf() self.rebelBtn = nil end
	if self.vsBtn then self.vsBtn:removeSelf() self.vsBtn = nil end
end

function HomeView:showMainButton()
	if not self.m_mainButton then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_base_normal.png")
		-- local selected = display.newSprite(IMAGE_COMMON .. "btn_base_selected.png")
		local mainBtn = ScaleButton.new(normal,handler(self, self.onMainCallback)):addTo(self.m_bottomBg)
		mainBtn:setPosition(75, 58)
		self.m_mainButton = mainBtn

		-- local light = display.newSprite(IMAGE_COMMON .. "info_bg_71.png"):addTo(mainBtn, 999)
		-- light:setPosition(mainBtn:getContentSize().width / 2, mainBtn:getContentSize().height / 2 + 24)
	end

	-- if self.m_mainButton.icon then
	-- 	self.m_mainButton.icon:removeSelf()
	-- 	self.m_mainButton.icon = nil
	-- end

	-- local normal = nil
	-- local selected = nil
	local icon = nil
	if self.m_curShowIndex == MAIN_SHOW_BASE then
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_base_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_base_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_base_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_WILD then
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_wild_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_wild_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_wild_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_WORLD then
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_world_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_world_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_world_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_PARTY then
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_go_base_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_go_base_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_go_base_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_MINE_AREA then -- 军事矿区
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_go_base_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_go_base_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_go_base_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_FORTRESS then -- 军团要塞战
		-- normal = display.newSprite(IMAGE_COMMON .. "btn_go_base_normal.png")
		-- selected = display.newSprite(IMAGE_COMMON .. "btn_go_base_selected.png")
		icon = display.newSprite(IMAGE_COMMON .. "btn_go_base_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_MONEYTANK then -- 军团要塞战
		icon = display.newSprite(IMAGE_COMMON .. "btn_go_base_icon.png")
	elseif self.m_curShowIndex == MAIN_SHOW_CROSSSERVER_MINE_AREA then --跨服军事矿区
		icon = display.newSprite(IMAGE_COMMON .. "btn_go_base_icon.png")
	end

	-- self.m_mainButton:setNormalSprite(normal)
	-- self.m_mainButton:setSelectedSprite(selected)
	self.m_mainButton:setTouchSprite(icon)

	-- icon:setPosition(self.m_mainButton:getContentSize().width / 2, self.m_mainButton:getContentSize().height / 2)
	-- self.m_mainButton:addChild(icon)
	-- self.m_mainButton.icon = icon

	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		local snowBg = display.newSprite("image/screen/a_bg_4.png"):addTo(self, 1000)
		snowBg:setPosition(display.cx, display.height - snowBg:getContentSize().height / 2)
	else
		if UserMO.querySystemId(49) == 1 then
			local snowBg = display.newSprite("image/screen/a_bg_9.png"):addTo(self, 1000)
			snowBg:setScale(display.width / 640)
			snowBg:setPosition(display.cx, display.height - snowBg:getContentSize().height / 2)
		end
	end
end

function HomeView:showMainUI()
	if not self.m_mainUIs then
		self.m_mainUIs = {}
	end

	-- for index = 1, MAIN_SHOW_FORTRESS do
	for index = 1, MAIN_SHOW_MONEYTANK do
		if self.m_mainUIs[index] then
			self.m_mainUIs[index]:removeSelf()
			self.m_mainUIs[index] = nil
		end
	end

	UiUtil.clearImageCache()
	
	self.m_mainUIs = {}

	if not self.m_mainUIs[self.m_curShowIndex] then
		if self.m_curShowIndex == MAIN_SHOW_BASE then
			local HomeBaseTableView = require("app.scroll.HomeBaseTableView")
			local tableView = HomeBaseTableView.new(cc.size(display.width, display.height)):addTo(self)
			tableView:setPosition(0, 0)
			tableView:reloadData()
			if UserMO.onlineAwardIndex_ >= UserMO.getOnlineAwardTotalNum() then  -- 全部都领取完了
				tableView:setContentOffset(cc.p(-410, 0))
			else
				if UserMO.getOnlineAwardLeftTime() > 5 then tableView:setContentOffset(cc.p(-410, 0))
				else tableView:setContentOffset(cc.p(0, 0)) end
			end
			-- gdump(NewerMO.currentStateId,"NewerMO.currentStateId=====")
			-- gdump(self.m_starZoom,"self.m_starZoom===")
			if self.m_starZoom and (NewerMO.currentStateId == 180 or NewerMO.currentStateId == 0) then  -- 只操作一次
				tableView:startZoomEnter()
				self.m_starZoom = false
			else
				tableView:setZoomScale(1.1)
			end
			self.m_mainUIs[self.m_curShowIndex] = tableView

			--触发评论推送
			if UserBO.isEnablePush()
				and UserMO.pushState == IOS_PUSH_STATE_NO and UserMO.shouldPushTime and UserMO.shouldPushTime > 0 
				and ManagerTimer.getTime() - UserMO.shouldPushTime >= 0 then
				-- UserMO.shouldPushTime = nil
				-- UserMO.pushState = IOS_PUSH_STATE_YES
				Notify.notify(LOCAL_SHOW_PUSH_EVENT)
			end

		elseif self.m_curShowIndex == MAIN_SHOW_WILD then
			local HomeMillTableView = require("app.scroll.HomeMillTableView")
			local tableView = HomeMillTableView.new(cc.size(display.width, display.height)):addTo(self)
			tableView:setPosition(0, 0)
			tableView:reloadData()
			-- tableView:startZoomEnter()
			self.m_mainUIs[self.m_curShowIndex] = tableView

			local maxNum = BuildBO.getOpenWildMaxNum()
			local config = HomeBuildWildConfig[maxNum]
			local pos = HomeWildPos[config.pos]
			tableView:setContentOffset(cc.p(-pos.x + display.cx, 0))
		elseif self.m_curShowIndex == MAIN_SHOW_WORLD then
			local HomeWorldView = require("app.view.HomeWorldView")
			local view = HomeWorldView.new():addTo(self)
			view:setPosition(display.cx, display.cy)
			view.m_tileMap:locate(WorldMO.currentPos_.x, WorldMO.currentPos_.y)
			self.m_mainUIs[self.m_curShowIndex] = view
			--触发世界引导
			if UserMO.level_ <= 20 and UserMO.level_ >= 9 then
				TriggerGuideMO.currentStateId = 10
				Notify.notify(LOCAL_SHOW_NEWER_GUIDE_TRIGGER_EVENT)
			end
		elseif self.m_curShowIndex == MAIN_SHOW_PARTY then
			local HomePartyTableView = require("app.scroll.HomePartyTableView")
			local tableView = HomePartyTableView.new(cc.size(display.width, display.height)):addTo(self)
			tableView:setPosition(0, 0)
			tableView:reloadData()
			tableView:setContentOffset(cc.p(-150, 0))
			self.m_mainUIs[self.m_curShowIndex] = tableView
		elseif self.m_curShowIndex == MAIN_SHOW_MINE_AREA then  -- 军事矿区
			local MineMap = require("app.mine.MineMap")
			local view = MineMap.new(cc.size(display.width, display.height - 100 - 30)):addTo(self)
			view:setPosition(0, 102)
			view:locate(5, 5)
			self.m_mainUIs[self.m_curShowIndex] = view
		elseif self.m_curShowIndex == MAIN_SHOW_FORTRESS then --军团要塞战
			local tableView = require("app.view.DefendWarView").new():addTo(self)
			self.m_mainUIs[self.m_curShowIndex] = tableView
		elseif self.m_curShowIndex == MAIN_SHOW_MONEYTANK then --金币车
			local MoneyTankView = require("app.view.MoneyTankView").new():addTo(self)
			self.m_mainUIs[self.m_curShowIndex] = MoneyTankView
		elseif self.m_curShowIndex == MAIN_SHOW_CROSSSERVER_MINE_AREA then -- 跨服军事矿区
			local CrossServerMineMap = require("app.mine.CrossServerMineMap")
			local view = CrossServerMineMap.new(cc.size(display.width, display.height - 100 - 30)):addTo(self)
			view:setPosition(0, 102)
			view:locate(10, 10)
			self.m_mainUIs[self.m_curShowIndex] = view
		end
	end

	-- 根据当前需要显示，在三个ui中切换
	for id, view in pairs(self.m_mainUIs) do
		if id ~= self.m_curShowIndex then
			if view then view:setVisible(false) end
		else
			if view then view:setVisible(true) end
		end
	end

	if not self.m_headView then
		local view = HeadView.new():addTo(self, 100)
		view:setScale(GAME_X_SCALE_FACTOR)
		view:setPosition(display.cx, display.height - view:getContentSize().height / 2)
		self.m_headView = view
		--系统时间
		if self.m_curShowIndex == MAIN_SHOW_BASE then
			local bg = display.newSprite(IMAGE_COMMON .. "info_bg_39.png"):addTo(self, 100)
				:align(display.LEFT_TOP,0,display.height - view:height() - 140)
			local label = UiUtil.label("",20):addTo(bg):align(display.LEFT_CENTER,10,bg:height()/2)
			local function tick()
				local t = ManagerTimer.getTime()
				local week = tonumber(os.date("%w",t))
				local h = os.date("%H", t)
				local m = os.date("%M", t)
				local str = string.format("%02d-%02d(%s) %02d:%02d",
						os.date("%m",t),os.date("%d",t),CommonText.week[week],h,m)
				label:setString(str)
			end
			tick()
			label:performWithDelay(tick, 1, 1)
			self.timeBg = bg
		end
	end
	if self.m_curShowIndex ~= MAIN_SHOW_BASE and self.timeBg then
		self.timeBg:hide()
	elseif self.timeBg then
		self.timeBg:show()
	end
	if self.m_curShowIndex == MAIN_SHOW_FORTRESS then
		if self.m_headView then
			self.m_headView:removeSelf()
			self.m_headView = nil
		end
		-- self:hasCoinButton()
	else
		-- self:hasCoinButton(true)
	end

	-- local view = EffectInfoView.new():addTo(self, 100)
	-- view:setPosition(375, display.height - 60)
	-- view:updateEffect()
	-- self.m_effectView = view
	if UserMO.canClickFame_ and (WorldMO.pos_.x > 0 or WorldMO.pos_.y > 0) then
		local function doneCallback(up, delta)
			if delta > 0 then
				UiUtil.showAwards({awards = {{kind = ITEM_KIND_FAME, count = delta}}})
			end
		end
		UserBO.asynClickFame(doneCallback)
	end
end

function HomeView:getCurShowIndex()
	return self.m_curShowIndex
end

function HomeView:getCurContainer()
	return self.m_mainUIs[self:getCurShowIndex()]
end

function HomeView:onLocationUpdate(event)
	-- dump(event)
    -- gprint("onLocationUpdate:", event.obj.x, event.obj.y)
    -- self:locate(event.obj.x, event.obj.y)

    self:showChosenIndex(MAIN_SHOW_WORLD)
    if self.m_mainUIs[MAIN_SHOW_WORLD] then
    	if event and event.obj and event.obj.x and event.obj.y then
	    	self.m_mainUIs[MAIN_SHOW_WORLD]:onLocate(event.obj.x, event.obj.y, true)
	    end
    end
end

function HomeView:onLocationMilitaryAreaUpdate(event)
	self:showChosenIndex(MAIN_SHOW_MINE_AREA)
	if self.m_mainUIs[MAIN_SHOW_MINE_AREA] then
    	if event and event.obj and event.obj.x and event.obj.y then
	    	self.m_mainUIs[MAIN_SHOW_MINE_AREA]:locate(event.obj.x, event.obj.y, true)
	    end
	end
end

function HomeView:onShowWildUpdate(event)
	-- dump(event)
    -- gprint("onLocationUpdate:", event.obj.x, event.obj.y)
    -- self:locate(event.obj.x, event.obj.y)

    self:showChosenIndex(MAIN_SHOW_WILD)
end


function HomeView:onExit()
	ManagerTimer.removeTickListener(self.m_timerHandler)
	self.m_timerHandler = nil

    Notify.unregister(self.m_locationHandler)
    self.m_locationHandler = nil

	Notify.unregister(self.m_showWildHandler)
	self.m_showWildHandler = nil

	Notify.unregister(self.m_armyHandler)
	self.m_armyHandler = nil

	Notify.unregister(self.m_chatHandler)
	self.m_chatHandler = nil

	Notify.unregister(self.m_readChatHandler)
	self.m_readChatHandler = nil

	Notify.unregister(self.m_showNewerGuideHandler)
	self.m_showNewerGuideHandler = nil

	Notify.unregister(self.m_showTaskGuideHandler)
	self.m_showTaskGuideHandler = nil

	Notify.unregister(self.m_showTriggerNewerHandler)
	self.m_showTriggerNewerHandler = nil

	Notify.unregister(self.m_showPushHandler)
	self.m_showPushHandler = nil

	if self.m_invasion then
		self.m_invasion:removeSelf()
	end
	self.m_invasion = nil
end

function HomeView:onTick(dt)
	if self.m_armyNode then -- 有任务在执行
		local show = self.m_armyNode.showArmy
		local showType = self.m_armyNode.showType
		if show then
			if showType== ARMY_TYPE_AID then
				self.m_armyNode.timeLabel_:setString(CommonText[320][4]) -- 驻军中
			elseif showType == ARMY_TYPE_INVASION then
				local leftTime = SchedulerSet.getTimeById(show.schedulerId)
				self.m_armyNode.timeLabel_:setString(ActivityCenterBO.formatTime(leftTime))
			elseif showType == ARMY_TYPE_ARMY then
				if show.state == ARMY_STATE_GARRISON or show.state == ARMY_STATE_WAITTING or show.state == ARMY_STATE_AID_MARCH then
					self.m_armyNode.timeLabel_:setString(CommonText[320][4]) -- 驻军中
				elseif self.m_armyNode.timeLabel_ then
					local leftTime = SchedulerSet.getTimeById(show.schedulerId)
					self.m_armyNode.timeLabel_:setString(ActivityCenterBO.formatTime(leftTime))
				end
			end
		elseif self.m_armyNode.timeLabel_ then
			self.m_armyNode.timeLabel_:setString("")
		end
	end

	if UiDirector.getTopUiName() ~= "HomeView" or self.m_curShowIndex ~= MAIN_SHOW_BASE then
		-- gprint("定时器 清0")
		HomeBO.NO_OPERATE_FREE_TIMER = 0
	else
		HomeBO.NO_OPERATE_FREE_TIMER = HomeBO.NO_OPERATE_FREE_TIMER + dt
	end

	if (HomeBO.NO_OPERATE_FREE_TIMER >= 30 and UserMO.level_ < 20) or
		(HomeBO.NO_OPERATE_FREE_TIMER >= 180 and UserMO.level_ < 30) then -- 三分钟
		self:homeBottomButton(true)
		Notify.notify(LOCAL_SHOW_TASK_GUIDE_EVENT,{kind = 600,type = 1})
	end
	--显示要塞战
	if FortressMO.inWar() and self.m_curShowIndex == MAIN_SHOW_BASE then
		if not self.fortressBtn then
			self.fortressBtn = UiUtil.button("fight_normal.png","fight_selected.png",nil,function()
					self:showChosenIndex(MAIN_SHOW_FORTRESS)
				end):addTo(self):pos(595,530)
			self.fortressBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.2),
				 cc.ScaleTo:create(0.5, 1)})))
		end
	else
		if self.fortressBtn then
			self.fortressBtn:removeSelf()
			self.fortressBtn = nil
		end
	end
	--显示红蓝大战状态
	if self.m_curShowIndex == MAIN_SHOW_BASE and StaffMO.worldLv_ >= 1 then
		if (not ExerciseBO.data or ExerciseBO.data.isEnrolled == false) and ExerciseMO.inApplyTime() then
			if not self.redblueBtn then
				self.redblueBtn = UiUtil.button("btn_45_normal.png","btn_45_selected.png",nil,function()
						require("app.view.ExerciseView").new():push()
					end):addTo(self,0,1):pos(595,530)
				self.redblueBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.2),
					 cc.ScaleTo:create(0.5, 1)})))
			end
		elseif ExerciseMO.inPrepareTime() then
			if self.redblueBtn and self.redblueBtn:getTag() == 1 then
				self.redblueBtn:removeSelf()
				self.redblueBtn = nil
			end
			if not self.redblueBtn then
				self.redblueBtn = UiUtil.button("fight_normal.png","fight_selected.png",nil,function()
						require("app.view.ExerciseView").new():push()
					end):addTo(self,0,2):pos(595,530)
				self.redblueBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.2),
					 cc.ScaleTo:create(0.5, 1)})))
			end
		else
			if self.redblueBtn then
				self.redblueBtn:removeSelf()
				self.redblueBtn = nil
			end
		end
	end
	--显示叛军入侵
	if (self.m_curShowIndex == MAIN_SHOW_BASE or self.m_curShowIndex == MAIN_SHOW_WORLD) and RebelMO.checkOpen() then
		if not self.rebelBtn then
			self.rebelBtn = UiUtil.button("rebel_come.png","rebel_come.png",nil,function()
					require("app.view.RebelView").new():push()
				end):addTo(self)
			self.rebelBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0.5, 1.2),
				 cc.ScaleTo:create(0.5, 1)})))
			if self.redblueBtn then
				self.rebelBtn:pos(595,630)
			else
				self.rebelBtn:pos(595,555)
			end
		end
	else
		if self.rebelBtn then
			self.rebelBtn:removeSelf()
			self.rebelBtn = nil
		end
	end
	--显示争霸
	if (CrossPartyMO.isOpen_ or CrossMO.isOpen_) and self.m_curShowIndex == MAIN_SHOW_BASE then
		if not self.vsBtn then
			self.vsBtn = UiUtil.button("vs_normal.png","vs_normal.png",nil,function()
					if CrossMO.isOpen_ then
						if UserMO.level_ < UserMO.querySystemId(45) then
							Toast.show(string.format(CommonText[1083], UserMO.querySystemId(45)))
							return
						end
						require("app.view.CrossEnter").new():push()
					elseif CrossPartyMO.isOpen_ then
						require("app.view.CrossPartyEnter").new():push()
					end
				end):addTo(self):pos(50,530)
			self.vsBtn:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(1.8, 1.3),
				 cc.ScaleTo:create(2.2, 1)})))
		end
	else
		if self.vsBtn then
			self.vsBtn:removeSelf()
			self.vsBtn = nil
		end
	end
	ExerciseMO.checkEnd()
	self:updatePartyBattle()
end

function HomeView:onArmyUpdate(event)
	self:showArmy()
end

function HomeView:showArmy()
	if self.m_armyNode then
		self.m_armyNode:removeSelf()
		self.m_armyNode = nil
	end

	local invasions = ArmyMO.getAllInvasions()
	local aids = ArmyMO.getAllAids()
	local armies = ArmyMO.getAllArmies()
	if #armies <= 0 and #invasions <= 0 and #aids <= 0 then -- 没有任务
		return
	end
	local armyType = 0
	local show = nil

	if #invasions > 0 then
		armyType = ARMY_TYPE_INVASION
		show = invasions[1]
	elseif #aids > 0 then
		armyType = ARMY_TYPE_AID
		show = aids[1]
	elseif #armies > 0 then
		armyType = ARMY_TYPE_ARMY
		table.sort(armies, ArmyMO.orderArmy)
		show = armies[1]
	end

	-- print("armyType:", armyType)
	-- dump(show, "我顶")

	self.m_armyNode = display.newNode():addTo(self, 100)
	self.m_armyNode:setPosition(10, 265)

	local normal = nil
	local selected = nil
	if armyType == ARMY_TYPE_INVASION then
		if show.state == ARMY_STATE_AID_MARCH then -- 在驻军的路上
			normal = display.newSprite(IMAGE_COMMON .. "btn_36_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_36_selected.png")
		else
			normal = display.newSprite(IMAGE_COMMON .. "btn_37_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_37_selected.png")
		end
	elseif armyType == ARMY_TYPE_AID then
		normal = display.newSprite(IMAGE_COMMON .. "btn_36_normal.png")
		selected = display.newSprite(IMAGE_COMMON .. "btn_36_selected.png")
	else
		if show.state == ARMY_STATE_MARCH or show.state == ARMY_STATE_AID_MARCH then
			normal = display.newSprite(IMAGE_COMMON .. "btn_33_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_33_selected.png")
		elseif show.state == ARMY_STATE_RETURN then
			normal = display.newSprite(IMAGE_COMMON .. "btn_34_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_34_selected.png")
		elseif show.state == ARMY_STATE_COLLECT then
			normal = display.newSprite(IMAGE_COMMON .. "btn_35_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_35_selected.png")
		elseif show.state == ARMY_STATE_GARRISON or show.state == ARMY_STATE_WAITTING then
			normal = display.newSprite(IMAGE_COMMON .. "btn_36_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_36_selected.png")
		else
			normal = display.newSprite(IMAGE_COMMON .. "btn_35_normal.png")
			selected = display.newSprite(IMAGE_COMMON .. "btn_35_selected.png")
		end
	end

	local btn = MenuButton.new(normal, selected, nil, function()
			if self.m_armyNode.showType == ARMY_TYPE_INVASION then
				if self.m_armyNode.showArmy.state == ARMY_STATE_AID_MARCH then -- 在驻军的路上
					require("app.dialog.GuardDialog").new():push()
				else
					require("app.dialog.InvasionDialog").new():push()
				end
			elseif self.m_armyNode.showType == ARMY_TYPE_AID then
				require("app.dialog.GuardDialog").new():push()
			else
				local view = require("app.view.ArmyView").new(ARMY_VIEW_FOR_UI):push()
				view.m_pageView:setPageIndex(2)
			end
		end):addTo(self.m_armyNode)
	btn:setPosition(btn:getContentSize().width / 2, 0)

	if armyType == ARMY_TYPE_INVASION and show.state ~= ARMY_STATE_AID_MARCH then   -- 在攻击的路上
		armature_add(IMAGE_ANIMATION .. "effect/ui_army_invasion.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_army_invasion.plist", IMAGE_ANIMATION .. "effect/ui_army_invasion.xml")
		
		local armature = armature_create("ui_army_invasion"):addTo(btn)
		armature:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
		armature:getAnimation():playWithIndex(0)

		armature_add(IMAGE_ANIMATION .. "effect/gongji_hongguang.pvr.ccz", IMAGE_ANIMATION .. "effect/gongji_hongguang.plist", IMAGE_ANIMATION .. "effect/gongji_hongguang.xml")

		if not self.m_invasion then
			local armature = armature_create("gongji_hongguang"):addTo(self)
			armature:center()
			armature:getAnimation():playWithIndex(0)
			self.m_invasion = armature
		end

		self.m_invasion:stopAllActions()
		self.m_invasion:runAction(transition.sequence({cc.DelayTime:create(3),cc.CallFuncN:create(function ()
			self.m_invasion:removeSelf()
			self.m_invasion = nil
		end)}))
	elseif armyType == ARMY_TYPE_ARMY and show.state == ARMY_STATE_COLLECT then
		local leftTime = SchedulerSet.getTimeById(show.schedulerId)
		if leftTime <= 0 then  -- 采集已经完成结束了
			armature_add(IMAGE_ANIMATION .. "effect/ui_army_return.pvr.ccz", IMAGE_ANIMATION .. "effect/ui_army_return.plist", IMAGE_ANIMATION .. "effect/ui_army_return.xml")

			local armature = armature_create("ui_army_return"):addTo(btn)
			armature:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
			armature:getAnimation():playWithIndex(0)
		end
	end

	local bg = display.newSprite(IMAGE_COMMON .. "info_bg_54.png"):addTo(self.m_armyNode)
	-- bg:setAnchorPoint(cc.p(0, 0.5))
	bg:setPosition(btn:getPositionX(), -40)

	local leftTime = SchedulerSet.getTimeById(show.schedulerId)
	local timeLabel = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_LIMIT, x = btn:getPositionX(), y = -40, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_armyNode)
	-- local timeLabel = ui.newTTFLabel({text = UiUtil.strBuildTime(leftTime), font = G_FONT, size = FONT_SIZE_LIMIT, x = 60, y = 0, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_armyNode)
	-- timeLabel:setAnchorPoint(cc.p(0, 0.5))
	if show.state ~= ARMY_STATE_FORTRESS then
		self.m_armyNode.timeLabel_ = timeLabel
	else
		bg:removeSelf()
	end

	self.m_armyNode.showType = armyType
	self.m_armyNode.showArmy = show

	self:onTick(0)
end

function HomeView:onShowNewerGuide(event)
	-- gprint("HomeView:onShowNewerGuide(event)")
	--根据玩家数据判断是否触发引导
	-- if UserMO.level_ > 2 and NewerBO.getState() == 0 then
	print("UserMO.level_!!!", UserMO.level_)
	if UserMO.level_ > 2 then
		--已经领取过新手礼包，不走引导
		print("UserMO.newerGift_!!!", UserMO.newerGift_)
		if UserMO.newerGift_ == 1 then
			NewerMO.showNewer = false
		else
			--未领取新手礼包,直接跳到最后一步
			NewerMO.currentStateId = 100
		end
	elseif UserMO.level_ == 2 and NewerBO.getState() == 0 then -- 防止老变态用户存在 配合服务端
		if UserMO.newerGift_ == 1 then
			NewerMO.showNewer = false
		end
		NewerMO.currentStateId = 100
	elseif UserMO.level_ == 1 then
		local state = NewerBO.getState()
		if state == 0 then
			NewerMO.currentStateId = 0
		elseif state == 1 then
			NewerMO.currentStateId = 5
		end
	end

	local view = UiDirector.getUiByName("NewerView")
	if view then
		return
	end

	if NewerMO.showNewer == false then return end
	-- gdump(NewerMO.currentStateId,"NewerMO.currentStateIdNewerMO.currentStateId")
	local newerData = NewerBO:getCurrentNewerData()
	-- gdump(newerData,"newerData===")
	if newerData then
		local process = table.remove(newerData.process,1)
		local pushNewerView = function()
			local NewerView = require("app.view.NewerView").new():push()
			NewerView:init(newerData)
			NewerView:setData(process)
		end

		if process.init then
			NewerBO.doInitCommond(process.init,pushNewerView,process.initParam)
		else
			pushNewerView()
		end
	end
	--防止点击间隔过小多次打开界面
	scheduler.performWithDelayGlobal(function()
            local newerView = UiDirector.getUiByName("NewerView")
			if newerView then
				UiDirector.popMakeUiTop("NewerView")
			end
            end, 0.5)
end

--触发型引导
function HomeView:onShowTriggerGuide(event)
	local newerData = TriggerGuideBO:getCurrentNewerData()
	gdump(newerData,"newerData===")
	if newerData then
		local process = table.remove(newerData.process,1)
		local pushNewerView = function()
			local TriggerGuideView = require("app.view.TriggerGuideView").new():push()
			TriggerGuideView:init(newerData)
			TriggerGuideView:setData(process)
		end

		if process.init then
			TriggerGuideBO.doInitCommond(process.init,pushNewerView,process.initParam)
		else
			pushNewerView()
		end
	end
	--防止点击间隔过小多次打开界面
	scheduler.performWithDelayGlobal(function()
            local TriggerGuideView = UiDirector.getUiByName("TriggerGuideView")
			if TriggerGuideView then
				UiDirector.popMakeUiTop("TriggerGuideView")
			end
            end, 0.5)
end


function HomeView:onShowTaskGuide(event)
	if event.obj and event.obj.kind > 0 then
		if event.obj.kind == 600 and TaskGuideMO.showFreeGuideStatus == false then
			local process = TaskGuideMO.getGuideStateById(event.obj.kind,event.obj.type)
			if process then
				local GuideView = require("app.view.GuideView").new():push()
				GuideView:setData(process)
				TaskGuideMO.showFreeGuideStatus = true
			end
		else
			local process = TaskGuideMO.getGuideStateById(event.obj.kind,event.obj.type)
			if process then
				local GuideView = require("app.view.GuideView").new():push()
				GuideView:setData(process)
			end
		end
	end
end

function HomeView:onChatUpdate(event)
	local num = ChatBO.getUnreadChatNum()
	if num > 0 then
		local tip = UiUtil.showTip(self.m_chatButton, num, 42, 42)
		tip:setScale(1 / GAME_X_SCALE_FACTOR)
	else
		UiUtil.unshowTip(self.m_chatButton)
	end
end

function HomeView:getTableOffSet()
	return self.m_mainUIs[self.m_curShowIndex]:getContentOffset()
end

function HomeView:homeBottomButton(animation)
	if self.m_homeButtonTableView then
		local offset = self.m_homeButtonTableView:getContentOffset()
		offset.x = 0
		self.m_homeButtonTableView:setContentOffset(offset, animation)
	end
end

function HomeView:doIndicator(indicatorConfig, stepIndex, animation)
	local step = indicatorConfig.step[stepIndex]

	if indicatorConfig.type == INDICATOR_TYPE_BUILD_BASE then
		local buildingId = step.buildingId
		if self:getCurShowIndex() ~= MAIN_SHOW_BASE then
			self:showChosenIndex(MAIN_SHOW_BASE)
		end

		local tabelView = self.m_mainUIs[MAIN_SHOW_BASE]
		tabelView:centerBuilding(buildingId, animation)
	elseif indicatorConfig.type == INDICATOR_TYPE_WILD then
		if self:getCurShowIndex() ~= MAIN_SHOW_WILD then
			self:showChosenIndex(MAIN_SHOW_WILD)
		end
	end
end

function HomeView:doCommand(command, callback)
	if command == "home_wild" then
		self:showChosenIndex(MAIN_SHOW_WILD)
	elseif command == "home_world" then
		self:showChosenIndex(MAIN_SHOW_WORLD)
	elseif command == "world_nearby" then
		 require("app.dialog.WorldNearbyDialog").new(WorldMO.currentPos_.x, WorldMO.currentPos_.y):push()
	 -- elseif command == "wild_create" then -- 引导框生产
	 -- 	self:showChosenIndex(MAIN_SHOW_WILD)
	 -- 	local tabelView = self.m_mainUIs[MAIN_SHOW_WILD]
	 -- 	tabelView:centerPosition()
	end
end


function HomeView:updatePartyBattle()
	local battleStatus = PartyBattleBO.getBattleStatus()
	self.m_partyBSignBtn:setVisible(battleStatus.stage == 1 and PartyBattleMO.isOpen)

	self.m_partyBBtn:setVisible(battleStatus.stage == 3 and PartyBattleMO.isOpen)

	if self.m_armyNode then
		self.m_partyBSignBtn:setPosition(130, 265)
		self.m_partyBBtn:setPosition(130, 265)
	else
		self.m_partyBSignBtn:setPosition(50, 265)
		self.m_partyBBtn:setPosition(50, 265)
	end
	if not PartyBattleMO.isOpen then return end

	--根据军团战阶段
	local partyStage = PartyBattleBO.getBattleStage()
	if partyStage > 0 then
		-- local str = CommonText[824][partyStage]
		-- local chat = {
		-- 	isGm = true,
		-- 	style = 1,
		-- 	msg = str
		-- }
		-- UiUtil.showHorn(chat)
		local sysId
		if partyStage == 1 then
			sysId = 140
		elseif partyStage == 2 then
			sysId = 141
		elseif partyStage == 3 then
			sysId = 142
		end
		local chat = {channel = CHAT_TYPE_WORLD, sysId = sysId, style = 1}
		ChatMO.addChat(chat.channel, chat.name, 1, 1, "", 0, 0, nil, nil, chat.style, nil, chat.sysId, 0, false, false, 0, nil, false)
		UiUtil.showHorn(chat)
		Notify.notify(LOCAL_SERVER_CHAT_EVENT, {type = chat.channel, nick = chat.name, chat = chat})

	end
	
end




--触发评论push推送
function HomeView:onPushComment(event)
	if UiDirector.getUiByName("IosPushCommentDialog") then return end
	require("app.dialog.IosPushCommentDialog").new():push()
end


return HomeView