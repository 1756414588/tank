
-- 设置view

local SettingView = class("SettingView", UiNode)

function SettingView:ctor()
	SettingView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
end

function SettingView:onEnter()
	SettingView.super.onEnter(self)

	self:setTitle(CommonText[327])

	local function createDelegate(container, index)
		if index == 1 then  -- 游戏设置
			self:showGameSetting(container)
		elseif index == 2 then -- 账号切换
			self:showAccount(container)
		-- elseif index == 3 then -- 安全锁设置
			-- self:showLock(container)
		-- elseif index == 4 then -- 联系我们
			-- self:showContact(container)
		elseif index == 3 then -- 兑换码
			self:showGiftCode(container)
		end
	end

	local function clickDelegate(container, index)
	end
	
	local pages = {CommonText[322][1], CommonText[322][2], CommonText[434]}
	if not GameConfig.enableCode then
		pages = {CommonText[322][1], CommonText[322][2]}
	end
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	line:setPreferredSize(cc.size(self:getBg():getContentSize().width, line:getContentSize().height))
	line:setScaleY(-1)
	line:setPosition(self:getBg():getContentSize().width / 2, pageView:getPositionY() + pageView:getContentSize().height / 2 + line:getContentSize().height / 2 - 4)

	self.m_clear = false
end

function SettingView:onExit()
	SettingView.super.onExit(self)
	-- if self.m_armyHandler then
	-- 	Notify.unregister(self.m_armyHandler)
	-- 	self.m_armyHandler = nil
	-- end
	if self.m_clear then
		UiUtil.clearImageCache()
	end
end

function SettingView:showGameSetting(container)
	local SettingGameTableView = require("app.scroll.SettingGameTableView")
	local view = SettingGameTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 4)):addTo(container)
	view:setPosition(0, 0)
	view:reloadData()
end

function SettingView:showAccount(container)
	local function logout()
		self.m_clear = true
		SocketWrapper.getInstance():disconnect(true)
		local localVersion = LoginBO.getLocalApkVersion()

		if GameConfig.environment == "qihoo360_client" or GameConfig.environment == "weiuu_client" or GameConfig.environment == "muzhiJh_client" 
			or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "muzhiJhly_client" 
			or GameConfig.environment == "tt_client" or GameConfig.environment == "muzhiU8ly_client" or GameConfig.environment == "muzhiJhYyb_client" 
			or GameConfig.environment == "muzhiJhYyb1_client" then
			Enter.startLogin(LOGIN_TYPE_SWITCH)
		elseif GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_chpub" or 
				GameConfig.environment == "tencent_anfan" or GameConfig.environment == "tencent_anfan_hj3" or
				GameConfig.environment == "tencent_muzhi_sjdz" or GameConfig.environment == "tencent_anfan_fktk" or
				GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "tencent_muzhi_hd" or 
				GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "tencent_yxfc" or 
				GameConfig.environment == "tencent_chpub_zzzhg" or GameConfig.environment == "tencent_chpub_redtank" or
				GameConfig.environment == "chhjfc_yyb_client" then
			ServiceBO.txSdkLogout()
		elseif GameConfig.environment == "sogou_client" or GameConfig.environment == "37wan_client" 
			or GameConfig.environment == "mzw_client" or GameConfig.environment == "jrtt_client"  
			or GameConfig.environment == "nhdz_client" or GameConfig.environment == "hm_client" 
			or GameConfig.environment == "wdj_client" or GameConfig.environment == "yoYou_client" 
			or GameConfig.environment == "chgtfc_appstore" or GameConfig.environment == "chzjqy_appstore" 
			or GameConfig.environment == "chpubNew_client" or (GameConfig.environment == "ch_appstore" and localVersion >= 287) 
			or ((GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chxsjt_appstore") and localVersion >= 292) 
			or GameConfig.environment == "mzXmly_appstore" or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
			or GameConfig.environment == "mzYiwanCyzc_appstore" or GameConfig.environment == "chhjfc_meizu_client"
			or GameConfig.environment == "chhjfc_xiaoqi_client" or GameConfig.environment == "chhjfc_360_client" 
			or GameConfig.environment == "chCjzjtkzz_appstore" or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "chhjfc_appstore" then
			ServiceBO.switchAccount()
		else
			Enter.startLogin()
		end
	end
	local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_2_selected.png")
	local btn = MenuButton.new(normal, selected, nil, logout):addTo(container)
	btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 200)
	btn:setLabel(CommonText[322][2])
end

-- function SettingView:showLock(container)
-- end

function SettingView:showContact(container)
	-- local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	-- local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	-- local btn = MenuButton.new(normal, selected, nil, nil):addTo(container)
	-- btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 200)
	-- btn:setLabel(CommonText[322][4])

	-- local logo = display.newSprite(IMAGE_COMMON .. "icon_logo.png"):addTo(container)
	-- logo:setAnchorPoint(cc.p(0, 0.5))
	-- logo:setPosition(45, container:getContentSize().height - 75)

	-- 客服电话
	local label = ui.newTTFLabel({text = CommonText[328][1] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = 45, y = container:getContentSize().height - 120, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[328][2], font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = CommonText[328][3] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX(), y = label:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[328][4], font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))

	local label = ui.newTTFLabel({text = CommonText[328][5] .. ":", font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX(), y = label:getPositionY() - 40, color = COLOR[11], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	label:setAnchorPoint(cc.p(0, 0.5))

	local value = ui.newTTFLabel({text = CommonText[328][6], font = G_FONT, size = FONT_SIZE_MEDIUM, x = label:getPositionX() + label:getContentSize().width, y = label:getPositionY(), color = COLOR[3], align = ui.TEXT_ALIGN_CENTER}):addTo(container)
	value:setAnchorPoint(cc.p(0, 0.5))
end

function SettingView:showGiftCode(container)
    local function onEdit(event, editbox)
        -- if editbox:getText() == CommonText[435][1] then
        --     editbox:setText("")
        -- end
    end

    local width = 450
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

	local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(container)
	inputBg:setPreferredSize(cc.size(width + 20, height + 10))
	inputBg:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 130)

    local inputMsg = ui.newEditBox({x = container:getContentSize().width / 2, y = container:getContentSize().height - 130, size = cc.size(width, height), listener = onEdit}):addTo(container)
    inputMsg:setFontColor(COLOR[11])
    -- inputMsg:setText(CommonText[435][1]) -- 请输入兑换码
    inputMsg:setPlaceholderFontColor(COLOR[11])
    inputMsg:setPlaceHolder(CommonText[435][1])

    local function doneGift(state, awards)
    	Loading.getInstance():unshow()
    	UiUtil.showAwards(awards)

    	if state > 0 then
    		Toast.show(CommonText[436][state])
    	else
    		Toast.show(CommonText[437])  -- 兑换码使用成功
    	end
    end

    local function onGiftCallback(tag, sender)
    	local code = string.gsub(inputMsg:getText()," ","")
    	if code == "!显示错误日志" then
    		UserBO.showDebug = true
    		print("!显示错误日志")
    		return
    	end
    	-- if code == CommonText[435][1] then
    	-- 	inputMsg:setText("")
    	-- 	return
    	-- end

    	if code == "" then
    		Toast.show(CommonText[355][1])
    		return
    	end

    	local length = string.len(code)
    	if length ~= 12 then
    		Toast.show(CommonText[436][4]) -- 兑换码无效
    		return
    	end
    	
    	if GameConfig.environment == "mzw_client" then
    		ServiceBO.useGiftCode(code)
    	end
    	

    	Loading.getInstance():show()
    	UserBO.asynGiftCode(doneGift, code)
	end

    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local btn = MenuButton.new(normal, selected, nil, onGiftCallback):addTo(container)
    btn:setPosition(container:getContentSize().width / 2, container:getContentSize().height - 240)
    btn:setLabel(CommonText[589])
end

return SettingView
