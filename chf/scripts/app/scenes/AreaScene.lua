--
-- 选区

local AreaScene = class("AreaScene", function()
    return display.newScene("AreaScene")
end)

function AreaScene:ctor()
    gprint("AreaScene:ctor ... ")
    local bg = LoginBO.getLoadingBg()
    bg:setScale(GAME_X_SCALE_FACTOR)
    self:addChild(bg)
    self.bg = bg
end

function AreaScene:onEnter()
    LoginBO.asynGetServerList(handler(self, self.show))
	-- self:show()
    --强制重新加载数据文件，防止切换账号数据混乱
    package.loaded["app.init"] = nil
    package.preload["app.init"] = nil
    for k, v in pairs(package.loaded) do
        if string.find(k, "app.mo") or string.find(k, "app.bo") then
            package.loaded[k] = nil
            package.preload[k] = nil
        end
    end
    require("app.init")
end

function AreaScene:onExit()
 --    armature_remove("image/animation/effect/ui_home_view_effect.pvr.ccz", "image/animation/effect/ui_home_view_effect.plist", "image/animation/effect/ui_home_view_zxt.xml")
 --    armature_remove("image/animation/effect/ui_login_xingxingshan.pvr.ccz", "image/animation/effect/ui_login_xingxingshan.plist", "image/animation/effect/ui_login_xingxingshan.xml")
 --    armature_remove("image/animation/effect/ui_login_zhezhao.pvr.ccz", "image/animation/effect/ui_login_zhezhao.plist", "image/animation/effect/ui_login_zhezhao.xml")
	-- ManagerUI.clearImageCache()
end

function AreaScene:show()
	--加载资源
    -- armature_add("image/animation/effect/ui_login_title.pvr.ccz", "image/animation/effect/ui_login_title.plist", "image/animation/effect/ui_login_title.xml")
    -- local titleArmature = CCArmature:create("logo_bgjs_mc")
    -- titleArmature:setPosition(display.left + 220, GAME_ORIGIANL_Y + GAME_SIZE_HEIGHT - 100)
    -- titleArmature:setScale(0.9)
    -- titleArmature:getAnimation():playWithIndex(0)
    -- titleArmature:connectMovementEventSignal(function()
    -- end)
    -- self:addChild(titleArmature)
    --LOGO
    -- local logo = display.newSprite("image/common/login/logo.png")
    -- logo:setPosition(GAME_ORIGIANL_X + logo:getContentSize().width / 2,GAME_ORIGIANL_Y + bg:getContentSize().height - logo:getContentSize().height / 2)
    -- logo:addTo(self)

    --加载资源
    -- -- armature_add("image/animation/effect/ui_login_title.pvr.ccz", "image/animation/effect/ui_login_title.plist", "image/animation/effect/ui_login_title.xml")
    -- armature_add("image/animation/effect/ui_home_view_effect.pvr.ccz", "image/animation/effect/ui_home_view_effect.plist", "image/animation/effect/ui_home_view_zxt.xml")
    -- armature_add("image/animation/effect/ui_login_xingxingshan.pvr.ccz", "image/animation/effect/ui_login_xingxingshan.plist", "image/animation/effect/ui_login_xingxingshan.xml")
    -- armature_add("image/animation/effect/ui_login_zhezhao.pvr.ccz", "image/animation/effect/ui_login_zhezhao.plist", "image/animation/effect/ui_login_zhezhao.xml")

    -- --星星
    -- local starEffect = CCArmature:create("bgjs_logoxxs_mc")
    -- starEffect:retain()
    -- starEffect:setPosition(60, 127)
    -- starEffect:getAnimation():playWithIndex(0)
    -- starEffect:connectMovementEventSignal(function(movementType, movementID) end)
    -- logo:addChild(starEffect)

    -- local starEffect1 = CCArmature:create("bgjs_logoxxs_mc")
    -- starEffect1:retain()
    -- starEffect1:setPosition(213, 74)
    -- starEffect1:getAnimation():playWithIndex(0)
    -- starEffect1:connectMovementEventSignal(function(movementType, movementID) end)
    -- logo:addChild(starEffect1)

    -- --遮罩
    -- local shadeEffect = CCArmature:create("bgjs_zz_mc")
    -- shadeEffect:retain()
    -- shadeEffect:setPosition(141, 88)
    -- shadeEffect:getAnimation():playWithIndex(0)
    -- shadeEffect:connectMovementEventSignal(function(movementType, movementID) end)
    -- logo:addChild(shadeEffect)

    -- local effect = CCArmature:create("zxt_mc")
    -- effect:retain()
    -- effect:setPosition(470, 554)
    -- effect:getAnimation():playWithIndex(0)
    -- effect:connectMovementEventSignal(function(movementType, movementID) end)
    -- bg:addChild(effect)

	-- if LoginMO.recentLogin then
	-- 	recentData = ServerDM.recent
	-- end

	-- areaData = ServerDM.getData()
	-- -- dump(recentData, "recent")
	-- -- dump(areaData, "area")


    -- gdump(LoginMO.serverList_,"LoginMO.serverList_==")
    -- 显示版本号
    local versionLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = display.width, y = 30, color = ccc3(255, 255, 255)}):addTo(self, 1000)
    versionLab:setAnchorPoint(cc.p(1,0.5))
    if GAME_APK_VERSION then
        versionLab:setString("App v" .. GAME_APK_VERSION .. "  Res v" .. GameConfig.version)
    else
        versionLab:setString("Res v" .. GameConfig.version)
    end
    

	if LoginMO.recentLogin_ and #LoginMO.recentLogin_ > 0 and LoginMO.recentLogin_[1] > 0 and LoginMO.getServerById(LoginMO.recentLogin_[1]) then
		self:showRecent(LoginMO.recentLogin_[1])
	else
        -- self:showRecent(LoginMO.serverList_[#LoginMO.serverList_].id)
        self:showRecent(LoginBO.getNewOpenServerIdx())
		-- self:showAll()
	end
    if LOGIN_PLATFORM_PARAM == "mz_appstoreXXX" then
        require("app.dialog.NoticeDialog").new():push()
        UiDirector.getTopUi():setLocalZOrder(10000)
    end
	-- local versionLab = CCLabelTTF:create("Version:"..GameConfig.ver, FONTS, 22)
	-- versionLab:setColor(ccc3(0,0,0))
	-- versionLab:setPosition(winSize.width/2 + 380, winSize.height/2 - 300)
	-- self:addChild(versionLab,1000)

    --公告
    -- ServiceBO.showNotice(GameConfig.downRootURL .. "notice.html?t=" .. os.time())


    --草花母包2 子渠道特殊弹窗提示
    ServiceBO.getPackageInfo(function(packageInfo)
               --获得包体的包名和versionCode
               local info = string.split(packageInfo, "|")
               local apk_packageName = info[1]
               local apk_versionCode = tonumber(info[2])
               if apk_packageName == "com.caohua.hjgl.nearme.gamecenter" or apk_packageName == "com.kushang.hjgl.vivo" then
                    --弹出强更提示框
                    IosUpdateDialog.getInstance():show({msg = LoginText[62], code = nil}, 1, function() IosUpdateDialog.getInstance():removeSelf() end,  function() IosUpdateDialog.getInstance():removeSelf() end)  
                    IosUpdateDialog.getInstance().m_bg:setPreferredSize(cc.size(550, 600))
                    IosUpdateDialog.getInstance().m_okBtn:setLabel(LoginText[61])
                    IosUpdateDialog.getInstance().m_msgLab:setPositionY(340)
               end
        end)

end

--最近登录
function AreaScene:showRecent(curAreaIndex)
	local currentArea = nil
-- 	if data then
-- 		currentArea = data
-- 	else
-- 		currentArea = recentData[1]
-- 	end
    if self.recentView then
        self.recentView:removeSelf()
        self.recentView = nil
    end

    if self.m_choseView then
        self.m_choseView:removeSelf()
        self.m_choseView = nil
    end
    
	self.recentView = display.newNode()
	self:addChild(self.recentView)

    local function choseServer(tag, sender)
        ManagerSound.playNormalButtonSound()
        self:showAll()
    end

    gprint("curAreaIndex===",curAreaIndex)
    local server = LoginMO.getServerById(curAreaIndex)
    -- gdump(server, "AreaScene 当前服务器")
   
    local normal = display.newScale9Sprite(IMAGE_COMMON .. "login/info_bg_1.png")
    -- normal:setPreferredSize(cc.size(314, 94))
    local selected = display.newScale9Sprite(IMAGE_COMMON .. "login/info_bg_1.png")
    -- selected:setPreferredSize(cc.size(314, 94))

    local curAreaBtn = MenuButton.new(normal, selected, nil, choseServer):addTo(self.recentView)
    curAreaBtn:setPosition(display.cx, display.cy - 240)
    curAreaBtn:setLabel(server.name, cc.c3b(255, 255, 255))


	
    GameConfig.areaId = curAreaIndex

	--进入游戏
	local normal = display.newSprite(IMAGE_COMMON .. "login/btn_login_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "login/btn_login_selected.png")
	local beginBtn = MenuButton.new(normal, selected, nil, handler(self,self.onBeginCallback))
	beginBtn:setPosition(display.cx, display.cy - 335)
    beginBtn:setLabel(LoginText[52])
	self.recentView:addChild(beginBtn)
end

function AreaScene:showAll()
	if self.recentView then
        self.recentView:removeSelf()
        self.recentView = nil
	end

	if self.m_choseView then
        self.m_choseView:removeSelf()
        self.m_choseView = nil
	end

    local bg = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png", display.cx, display.cy - 50)
    bg:setPreferredSize(cc.size(582, 587))
    self:addChild(bg)
    self.m_choseView = bg

    local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(bg, -1)
    btm:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 6)
    btm:setScaleY((bg:getContentSize().height - 70) / btm:getContentSize().height)

    if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
        local snowTop = display.newSprite("image/screen/a_bg_1.png"):addTo(bg, 3)
        snowTop:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - snowTop:getContentSize().height / 2 + 6)

        local snowBtm = display.newSprite("image/screen/a_bg_2.png"):addTo(bg, 3)
        snowBtm:setPosition(bg:getContentSize().width / 2, snowBtm:getContentSize().height / 2)
    else
        if HOME_SNOW_DEFAULT == 1 then
            local snowTop = display.newSprite("image/screen/a_bg_1.png"):addTo(bg, 3)
            snowTop:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - snowTop:getContentSize().height / 2 + 6)

            local snowBtm = display.newSprite("image/screen/a_bg_2.png"):addTo(bg, 3)
            snowBtm:setPosition(bg:getContentSize().width / 2, snowBtm:getContentSize().height / 2)
        end
    end

    local labelColor = cc.c3b(98,165,210)

    local tilte = ui.newTTFLabel({text = LoginText[4], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_choseView:getContentSize().width / 2, y = self.m_choseView:getContentSize().height - 26, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_choseView)

    -- 最新推荐
    local label = ui.newTTFLabel({text = LoginText[26] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 40, y = self.m_choseView:getContentSize().height - 80, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_choseView)
    label:setAnchorPoint(cc.p(0, 0.5))

    local normal = display.newSprite(IMAGE_COMMON .. "login/btn_server_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "login/btn_server_selected.png")
    local tuijianBtn = MenuButton.new(normal, selected, nil, function(tag, sender) ManagerSound.playNormalButtonSound(); self:showRecent(sender.serverIndex) end):addTo(bg)
    tuijianBtn:setPosition(40 + tuijianBtn:getContentSize().width / 2, bg:getContentSize().height - 120)
    tuijianBtn.serverIndex = LoginBO.getNewOpenServerIdx() 

    local ser = LoginMO.getServerById(tuijianBtn.serverIndex)

    local lab = ui.newTTFLabel({text = ser.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = tuijianBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER, color = COLOR[1]}):addTo(tuijianBtn)
    lab:setAnchorPoint(cc.p(0, 0.5))

    local tag = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = tuijianBtn:getContentSize().width - 20, y = tuijianBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(tuijianBtn)
    if ser.stop and ser.stop == 1 then -- 维
        tag:setString(LoginText[59])
        tag:setColor(COLOR[3])
        lab:setColor(COLOR[11])
    elseif ser.hot and ser.hot == 1 then -- 热
        tag:setString(LoginText[27])
        tag:setColor(cc.c3b(235, 64, 100))
        lab:setColor(COLOR[1])
    elseif ser.new and ser.new == 1 then -- 新
        tag:setString(LoginText[28])
        tag:setColor(cc.c3b(59, 219, 4))
        lab:setColor(COLOR[1])
    end

    -- 最近登录
    if LoginMO.recentLogin_ and #LoginMO.recentLogin_ > 0 and LoginMO.recentLogin_[1] > 0 then
        local label = ui.newTTFLabel({text = LoginText[25] .. ":", font = G_FONT, size = FONT_SIZE_SMALL, x = 302, y = self.m_choseView:getContentSize().height - 80, color = labelColor, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_choseView)
        label:setAnchorPoint(cc.p(0, 0.5))

        local normal = display.newSprite(IMAGE_COMMON .. "login/btn_server_normal.png")
        local selected = display.newSprite(IMAGE_COMMON .. "login/btn_server_selected.png")
        local serverBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); self:showRecent(LoginMO.recentLogin_[1]) end):addTo(bg)
        serverBtn:setPosition(302 + serverBtn:getContentSize().width / 2, bg:getContentSize().height - 120)

        local ser = LoginMO.getServerById(LoginMO.recentLogin_[1])

        if ser then
            -- gdump(ser, "recent login")
            local lab = ui.newTTFLabel({text = ser.name, font = G_FONT, size = FONT_SIZE_SMALL, x = 10, y = serverBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER,color = COLOR[1]}):addTo(serverBtn)
            lab:setAnchorPoint(cc.p(0, 0.5))

            local tag = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = serverBtn:getContentSize().width - 20, y = serverBtn:getContentSize().height / 2, align = ui.TEXT_ALIGN_CENTER}):addTo(serverBtn)
            if ser.stop and ser.stop == 1 then -- 维
                tag:setString(LoginText[59])
                tag:setColor(COLOR[3])
                lab:setColor(COLOR[11])
            elseif ser.hot and ser.hot == 1 then -- 热
                tag:setString(LoginText[27])
                tag:setColor(cc.c3b(235, 64, 100))
                lab:setColor(COLOR[1])
            elseif ser.new and ser.new == 1 then -- 新
                tag:setString(LoginText[28])
                tag:setColor(cc.c3b(59, 219, 4))
                lab:setColor(COLOR[1])
            end
        end
    end


    local tag = display.newSprite(IMAGE_COMMON .. "info_bg_66.png"):addTo(bg)
    tag:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height - 190)

    local size = cc.size(bg:getContentSize().width - 60, 330)
    local pages = {}
    local pageNum = math.ceil(#LoginMO.serverList_ / AREA_PAGE_SERVER_NUM)
    for index = 1, pageNum do
        pages[index] = ""
    end

    local function createYesBtnCallback(index)
        local form = (index - 1) * AREA_PAGE_SERVER_NUM + 1
        local to = index * AREA_PAGE_SERVER_NUM

        local button = nil
        index = index % 3
        if index == 1 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 170, size.height + 32)
            button:setLabel(form .. "-" .. to)
        elseif index == 2 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_41_normal.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_41_normal.png")
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2, size.height + 32)
            button:setLabel(form .. "-" .. to)
        elseif index == 0 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            normal:setScaleX(-1)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_selected.png")
            selected:setScaleX(-1)
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 170, size.height + 32)
            button:setLabel(form .. "-" .. to)
        end
        return button
    end

    local function createNoBtnCallback(index)
        local form = (index - 1) * AREA_PAGE_SERVER_NUM + 1
        local to = index * AREA_PAGE_SERVER_NUM
        local tag = index
        local button = nil
        index = index % 3
        if index == 1 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 - 170, size.height + 32)
            button:setLabel(form .. "-" .. to)
        elseif index == 2 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_41_selected.png")
            local selected = display.newSprite(IMAGE_COMMON .. "btn_41_selected.png")
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2, size.height + 32)
            button:setLabel(form .. "-" .. to)
        elseif index == 0 then
            local normal = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            normal:setScaleX(-1)
            local selected = display.newSprite(IMAGE_COMMON .. "btn_13_normal.png")
            selected:setScaleX(-1)
            button = CellMenuButton.new(normal, selected, nil, nil)
            button:setPosition(size.width / 2 + 170, size.height + 32)
            button:setLabel(form .. "-" .. to)
        end
        return button
    end

    local function createDelegate(container, index)
        local ServerTableView = require("app.scroll.ServerTableView")
        local view = ServerTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height), index):addTo(container)
        view:addEventListener("CHOSEN_SERVER_EVENT", function(event) self:showRecent(LoginMO.serverList_[event.serverIndex].id) end)
        view:setPosition(0, 0)
        view:reloadData()
    end

    local function clickDelegate(container, index)
    end

    local pageView = MultiPageView.new(MULTIPAGE_STYLE_DIY, size, pages, {x = bg:getContentSize().width / 2, y = size.height / 2 + 38,
        createDelegate = createDelegate, clickDelegate = clickDelegate, 
        styleDelegates = {createYesBtnCallback = createYesBtnCallback, 
                          createNoBtnCallback = createNoBtnCallback,
                          createTabCount = 3}}):addTo(bg, 2)
    
    pageView:setPageIndex(pageNum)

    --计算偏移量
    if pageNum < 3 then
        return
    end
    local offsetX = (math.floor(pageNum / 3) - 1) * 492  + (pageNum % 3 * 492 / 3) 
    pageView.m_tabPageView:setContentOffset(cc.p(-offsetX, 0))


end



function AreaScene:onBeginCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

    LoginBO.asynGetServerList(function()
            local server = LoginMO.getServerById(GameConfig.areaId)

            gdump(server, "[AreaScene]:onBeginCallback 进入的分服信息")

            if not GameConfig.skipStop and server and server.stop == 1 then
                local msg = nil
                if server.info then
                    msg = server.info
                else
                    msg = LoginText[17]  -- 服务器正在维护中，请稍候重试！
                end

                Toast.show(msg)
                return
            end

            Loading.getInstance():show()
            -- 获得GameURL
            LoginBO.initGameURL()

            PbProtocol.loadPb("Common.pb")
            PbProtocol.loadPb("Game.pb")
            PbProtocol.loadPb("Advertisement.pb")

            SocketReceiver.init()

            local function connectCallback()
                -- print("AreaScene: 连接成功了")
                LoginBO.asynBeginGame()
            end

            -- if SocketWrapper.getInstance() then
            --     if SocketWrapper.getInstance():isConnected() then -- 已经连接了
            --         gprint("LoginBO.asynReLogin instance is EXIST. But Connenct!!!")
            --         SocketWrapper.getInstance():disconnect()
            --     else
            --         gprint("LoginBO.asynReLogin instance is EXIST. But not Connenct!!!")
            --     end

            --     SocketWrapper.deleteInstance()
            -- end
            -- socket方式连接游戏服务器
            SocketWrapper.init(GameConfig.gameSocketURL, GameConfig.gamePort, connectCallback)


        end)

	
end


return AreaScene