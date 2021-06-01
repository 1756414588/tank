--
-- Author:
-- Date:
-- 登录场景

require_ex("app.text.LoginText")

LOGIN_TYPE_LOGIN = 1    --登录
LOGIN_TYPE_SWITCH = 2   --切换帐号
LOGIN_TYPE_LOGINOUT = 3 --注销

local function sdkLoginCallback(sid)
    ServiceBO.sdkLoginStatus_ = false
    if sid ~= nil and sid ~= "" then
        local token
        --腾讯特殊判断
        if GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_chpub" 
            or GameConfig.environment == "tencent_anfan" or GameConfig.environment == "tencent_anfan_hj3" 
            or GameConfig.environment == "tencent_muzhi_sjdz" or GameConfig.environment == "tencent_anfan_fktk" 
            or GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "tencent_muzhi_hd" 
            or GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "tencent_yxfc" 
            or GameConfig.environment == "tencent_chpub_zzzhg" or GameConfig.environment == "tencent_chpub_redtank"
            or GameConfig.environment == "chhjfc_yyb_client" then
            local info = string.split(sid, "|")
            local plat = info[1]
            --根据版本号判断是MSDK还是YSDK(GAME_APK_VERSION 2.0.1之后都是YSDK,之前都是MSDK)
            local localVersion = LoginBO.getLocalApkVersion()
            if localVersion >= 201 then
                if plat == "1" then
                    LOGIN_PLATFORM_PARAM = LOGIN_PLATFORM_PARAM_QQ
                elseif plat == "2" then
                    LOGIN_PLATFORM_PARAM = LOGIN_PLATFORM_PARAM_WX
                end
            else
                if plat == "1" then
                    LOGIN_PLATFORM_PARAM = LOGIN_PLATFORM_PARAM_WX
                elseif plat == "2" then
                    LOGIN_PLATFORM_PARAM = LOGIN_PLATFORM_PARAM_QQ
                end
            end
            token = info[2]
        else
            token = sid
        end
        LoginBO.asynSdkLogin(token)
    end
end

local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

function LoginScene:ctor(type)
    -- gprint("LoginScene:ctor ... ")
    local bg = LoginBO.getLoadingBg()
    bg:setScale(GAME_X_SCALE_FACTOR)
    self:addChild(bg)
    self.bg = bg


    local starttxt = display.newSprite("image/common/label_click_screen_star.png", display.cx, 160)
    starttxt:addTo(self)
    starttxt:setVisible(type and type == LOGIN_TYPE_SWITCH)

    if not type then 
        self.login_type = LOGIN_TYPE_LOGIN 
    else
        self.login_type = type
    end
end

function LoginScene:onEnter()
    gprint("LoginScene:onEnter ... ")

    --草花应用宝特殊处理(由于在应用宝被下架，之前的玩家无法登陆，提示框引导玩家进行联系客服处理)
    if GameConfig.environment == "tencent_chpub" then
        ChannelMaintainDialog.getInstance():show(InitText[31], function() os.exit() end)
        return
    end
    -- 初始化 登录信息
    LoginMO.isInLogin_ = false --未登录或已退出(切换帐号)

    ----------------------------------------------------------------
    -- 在更新后提前加载协议资源
    ----------------------------------------------------------------
    PbList_init()
    
    -- PbProtocol.preLoadAll()
    PbProtocol.loadPb("Base.pb")
    PbProtocol.loadPb("Account.pb")

    NetQueue.start()

    LoginBO.initLocalAcounts() -- 初始本地保存的账号
    LoginBO.initUUID(handler(self, self.goToLogin))
end

function LoginScene:onExit()
end

function LoginScene:goToLogin()
    -- 显示版本号
    local versionLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = display.width, y = 30, color = ccc3(255, 255, 255)}):addTo(self, 1000)
    versionLab:setAnchorPoint(cc.p(1,0.5))
    if GAME_APK_VERSION then
        versionLab:setString("App v" .. GAME_APK_VERSION .. "  Res v" .. GameConfig.version)
    else
        versionLab:setString("Res v" .. GameConfig.version)
    end


    --提示语
    ui.newTTFLabelWithOutline({text=InitText[22][1],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER})
        :addTo(self):pos(display.cx,155)
    ui.newTTFLabelWithOutline({text=InitText[22][2],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER})
        :addTo(self):pos(display.cx,130)


    --渠道判断显示 拇指相关信息
    if  GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_muzhi_sjdz" or 
        GameConfig.environment == "tencent_muzhi_hd" or GameConfig.environment == "muzhiJh_client" or GameConfig.environment == "mztkwz_client" or 
        GameConfig.environment == "muzhi_49" or GameConfig.environment == "muzhi_93" or GameConfig.environment == "tt_client" or 
        GameConfig.environment == "baiducl_client" or GameConfig.environment == "baiducltkjj_client" or GameConfig.environment == "mz_appstore" or 
        GameConfig.environment == "mztkjjylfc_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "mztkwz_appstore" or 
        GameConfig.environment == "qihoo360_client" or GameConfig.environment == "37wan_client" or GameConfig.environment == "anzhi_client" or 
        GameConfig.environment == "baidu_client" or GameConfig.environment == "downjoy_client" or GameConfig.environment == "haima_client" or 
        GameConfig.environment == "huashuo_client" or GameConfig.environment == "jrtt_client" or GameConfig.environment == "kaopu_client" or 
        GameConfig.environment == "meizu_client" or GameConfig.environment == "mzw_client" or GameConfig.environment == "nhdz_client" or 
        GameConfig.environment == "pyw_client" or GameConfig.environment == "pptv_client" or GameConfig.environment == "sogou_client" or 
        GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "ttyy_client" or GameConfig.environment == "n_uc_client" or 
        GameConfig.environment == "wdj_client" or GameConfig.environment == "weiuu_client" or GameConfig.environment == "yyh_client" or 
        GameConfig.environment == "zhuoyou_client" or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "mzTkjjQysk_appstore" 
        or GameConfig.environment == "muzhiU8ly_client" or GameConfig.environment == "muzhiJhYyb_client" or GameConfig.environment == "mzGhgzh_appstore" 
        or GameConfig.environment == "muzhiJhYyb1_client" or GameConfig.environment == "mzLzwz_appstore" then
        ui.newTTFLabelWithOutline({text=InitText[26][1],font=G_FONT,size=12,align=ui.TEXT_ALIGN_LEFT,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(0,display.height - 20)
        ui.newTTFLabelWithOutline({text=InitText[26][2],font=G_FONT,size=12,align=ui.TEXT_ALIGN_LEFT,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(0,40)
        ui.newTTFLabelWithOutline({text=InitText[26][3],font=G_FONT,size=12,align=ui.TEXT_ALIGN_LEFT,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(0,20)
    elseif GameConfig.environment == "ch_appstore" or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chzzzhg_appstore" 
        or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" then
        ui.newTTFLabelWithOutline({text=InitText[27][1] .. "   " .. InitText[27][3],font=G_FONT,size=12,align=ui.TEXT_ALIGN_LEFT,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(0,40)
        ui.newTTFLabelWithOutline({text=InitText[27][2] .. "   " .. InitText[27][4],font=G_FONT,size=12,align=ui.TEXT_ALIGN_LEFT,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(0,20)
    elseif GameConfig.environment == "self_client" or GameConfig.environment == "anfanTest_client" or GameConfig.environment == "af_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "afghgzh_client" or GameConfig.environment == "afMjdzh_appstore" 
        or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "afWpzj_appstore" 
        or GameConfig.environment == "afXzlm_appstore" or GameConfig.environment == "anfan_client" or GameConfig.environment == "anfan_client_small" 
        or GameConfig.environment == "anfanaz_client" or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "anfanKoudai_client" 
        or GameConfig.environment == "tencent_anfan" or GameConfig.environment == "tencent_anfan_fktk" or GameConfig.environment == "tencent_anfan_hj3" 
        or GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "zhuoyou_client" or GameConfig.environment == "leqi_client" 
        or GameConfig.environment == "afTqdknHD_appstore" or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "afNewMjdzh_appstore" 
        or GameConfig.environment == "afNewWpzj_appstore" or GameConfig.environment == "afLzyp_appstore" then
        ui.newTTFLabelWithOutline({text=LoginText[63][1],font=G_FONT,size=18,align=ui.TEXT_ALIGN_CENTER,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(display.cx,90)
        ui.newTTFLabelWithOutline({text=LoginText[63][2],font=G_FONT,size=18,align=ui.TEXT_ALIGN_CENTER,color = cc.c3b(205, 205, 205)})
           :addTo(self):pos(display.cx,70)
       ui.newTTFLabelWithOutline({text=LoginText[63][3],font=G_FONT,size=18,align=ui.TEXT_ALIGN_CENTER,color = cc.c3b(205, 205, 205)})
           :addTo(self):pos(display.cx,50)
    elseif GameConfig.environment == "chhjfc_hawei_client"
        or GameConfig.environment == "chhjfc_mi_client" or GameConfig.environment == "chhjfc_gp_client"
        or GameConfig.environment == "chhjfc_uc_client" or GameConfig.environment == "chhjfc_sw_client"
        or GameConfig.environment == "chhjfc_meizu_client" or GameConfig.environment == "chhjfc_coolpad_client"
        or GameConfig.environment == "chhjfc_gionee_client" or GameConfig.environment == "chhjfc_downjoy_client"
        or GameConfig.environment == "chhjfc_xiaoqi_client" or GameConfig.environment == "chhjfc_360_client"
        or GameConfig.environment == "chhjfc_lenovo_client" or GameConfig.environment == "chhjfc_sanxing_client"
        or GameConfig.environment == "chhjfc_baidu_client"  or GameConfig.environment == "chhjfc_oppo_client"
        or GameConfig.environment == "chhjfc_yyb_client" then
         ui.newTTFLabelWithOutline({text=InitText[29][1],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER,color = cc.c3b(205, 205, 205)})
            :addTo(self):pos(display.cx,110)
        ui.newTTFLabelWithOutline({text=InitText[29][2],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER,color = cc.c3b(205, 205, 205)})
           :addTo(self):pos(display.cx,90)
    end

    
    if device.platform == "android" or device.platform == "ios" or device.platform == "mac" then 
        if GameConfig.environment ~= "self_client" and GameConfig.environment ~= "ipay_client" 
        and GameConfig.environment ~= "ipay_101_client" and GameConfig.environment ~= "ios_client"
        and GameConfig.environment ~= "appstore_ios"  and GameConfig.environment ~= "zty_nake_client" then
            nodeTouchEventProtocol(self.bg, function(event)  
                    -- gprint("clickme")
                    -- if ServiceBO.sdkLoginStatus_ == true then return end
                    -- ServiceBO.sdkLoginStatus_ = true
                    if self.login_type == LOGIN_TYPE_LOGIN or self.login_type == LOGIN_TYPE_LOGINOUT then
                        ServiceBO.sdkLogin(sdkLoginCallback)
                    else
                        ServiceBO.switchAccount()
                    end
                    
                end, nil, true)
        end
    end  

    if LoginBO.isSelfLogin() then
        self:showSelfLogin()
    else
        -- ServiceBO.sdkLoginStatus_ = true
        -- ServiceBO.sdkLogin(sdkLoginCallback)
        if self.login_type == LOGIN_TYPE_LOGIN then
            ServiceBO.sdkLogin(sdkLoginCallback)
            
        else
            -- ServiceBO.switchAccount()
        end
        if GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_chpub" 
            or GameConfig.environment == "tencent_anfan" or GameConfig.environment == "tencent_anfan_hj3" 
            or GameConfig.environment == "tencent_muzhi_sjdz" or GameConfig.environment == "tencent_anfan_fktk" 
            or GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "tencent_muzhi_hd" 
            or GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "tencent_yxfc" 
            or GameConfig.environment == "tencent_chpub_zzzhg" or GameConfig.environment == "tencent_chpub_redtank"
            or GameConfig.environment == "chhjfc_yyb_client" then
            --QQ登录按钮
            local normal = display.newSprite("zLoginBg/btn_qq_normal.png")
            local selected = display.newSprite("zLoginBg/btn_qq_selected.png")
            local qqLoginBtn = MenuButton.new(normal, selected, nil, handler(self, self.onTxLoginCallback))
            qqLoginBtn:setPosition(display.cx - 150, display.cy - 350)
            qqLoginBtn.type = "qq"
            self:addChild(qqLoginBtn)

            --微信登录按钮
            local normal = display.newSprite("zLoginBg/btn_wx_normal.png")
            local selected = display.newSprite("zLoginBg/btn_wx_selected.png")
            local wxLoginBtn = MenuButton.new(normal, selected, nil, handler(self, self.onTxLoginCallback))
            wxLoginBtn:setPosition(display.cx + 150, display.cy - 350)
            wxLoginBtn.type = "wx"
            self:addChild(wxLoginBtn)
        end
    end
end

function LoginScene:onTxLoginCallback(tag, sender)
    ServiceBO.txSdkLogin(sdkLoginCallback,sender.type)
end

function LoginScene:showSelfLogin()
    -- 显示登录
    self:showLogin(true)
end

function LoginScene:showLogin(canSee)
    if not self.m_loginBg then
        local abg = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png", display.cx, display.cy - 50)
        abg:setPreferredSize(cc.size(582, 587))
        self:addChild(abg)
        self.m_loginBg = abg

        local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(abg, -1)
        btm:setPosition(abg:getContentSize().width / 2, abg:getContentSize().height / 2 - 6)
        btm:setScaleY((abg:getContentSize().height - 70) / btm:getContentSize().height)

        local labelColor = cc.c3b(98,165,210)

        local tilte = ui.newTTFLabel({text = LoginText[50], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_loginBg:getContentSize().width / 2, y = self.m_loginBg:getContentSize().height - 26, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_loginBg)

        local function onEdit(event, editbox)
            -- if editbox:getText() == LoginText[1][1] or editbox:getText() == LoginText[2][1] then
            --     editbox:setText("")
            -- end
        end

        local width = 400
        local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

        local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_loginBg)
        inputBg:setPreferredSize(cc.size(width + 20, height + 10))
        inputBg:setPosition(self.m_loginBg:getContentSize().width / 2, self.m_loginBg:getContentSize().height - 180)

        -- 账号输入框
        local loginInput1 = ui.newEditBox({x = self.m_loginBg:getContentSize().width / 2, y = self.m_loginBg:getContentSize().height - 180, size = cc.size(width, height), listener = onEdit}):addTo(self.m_loginBg)
        loginInput1:setFontColor(labelColor)
        -- loginInput1:setText(LoginText[1][1])
        loginInput1:setPlaceholderFontColor(labelColor)
        loginInput1:setPlaceHolder(LoginText[1][1])

        local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_loginBg)
        inputBg:setPreferredSize(cc.size(width + 20, height + 10))
        inputBg:setPosition(self.m_loginBg:getContentSize().width / 2, self.m_loginBg:getContentSize().height - 300)

        -- 密码输入框
        local loginInput2 = ui.newEditBox({x = self.m_loginBg:getContentSize().width / 2, y = self.m_loginBg:getContentSize().height - 300, size = cc.size(width, height), listener = onEdit}):addTo(self.m_loginBg)
        loginInput2:setFontColor(labelColor)
        -- loginInput2:setText(LoginText[2][1])
        loginInput2:setPlaceholderFontColor(labelColor)
        loginInput2:setPlaceHolder(LoginText[2][1])
        loginInput2:setInputFlag(0)

        -- self.downArrow = display.newSprite(IMAGE_COMMON .. "login/down.png", display.cx + 180, display.cy + 25):addTo(self.m_loginBg)
    --     Helper.addTouchEvent(self.downArrow, function(event, x, y)
    --         if event.name == "ended" then
    --             ManagerSound.playNormalButtonSound()
    --             self:showHisAccount()
    --         end
    --         return true
    --         end)


        local accounts = LoginMO.getLocalAccounts()
        if accounts and #accounts > 0 then
            local account = accounts[1]
            loginInput1:setText(account.accountId)
            loginInput2:setText(account.passwd)
        end
    --     AccountService.getAccount()
    --     if AccountService.loginHis and #AccountService.loginHis > 0 then
    --         self.loginShow = clone(AccountService.loginHis)
    --         local acc = table.remove(self.loginShow,1)
    --         self.downArrow:setVisible(self.loginShow and #self.loginShow > 0)
    --         -- self.upArrow:setVisible(false)
    --         if acc then
    --             loginInput1:setText(acc.accountId)
    --             loginInput2:setText(acc.passwd)
    --         end
    --     else
    --         self.downArrow:setVisible(false)
    --     end
        
        self.loginInput1 = loginInput1
        self.loginInput2 = loginInput2

        --登录按钮
        local normal = display.newSprite(IMAGE_COMMON.."btn_1_normal.png")
        local selected = display.newSprite(IMAGE_COMMON.."btn_1_selected.png")
        local loginBtn = MenuButton.new(normal, selected, nil, handler(self, self.onLoginCallback))
        loginBtn:setLabel(LoginText[22])
        loginBtn:setPosition(self.m_loginBg:getContentSize().width / 2 + 120, 25)
        self.m_loginBg:addChild(loginBtn)

        --注册按钮
        local normal = display.newSprite(IMAGE_COMMON.."btn_10_normal.png")
        local selected = display.newSprite(IMAGE_COMMON.."btn_10_selected.png")
        local registerBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); self:showRegister(true) end)
        registerBtn:setLabel(LoginText[23])
        registerBtn:setPosition(self.m_loginBg:getContentSize().width / 2 - 120, 25)
        self.m_loginBg:addChild(registerBtn)
    end

    if canSee then
        self.m_loginBg:setVisible(true)
        if self.m_registerBg then self.m_registerBg:setVisible(false) end
    else
        self.m_loginBg:setVisible(false)
        if self.m_registerBg then self.m_registerBg:setVisible(true) end
    end
end

-- function LoginScene:showHisAccount()
--     --如果帐号删除只剩一个，则关闭下拉窗口,隐藏下拉箭头
--     if #AccountService.loginHis == 1 then
--         self:closeHisAccount()
--         self.downArrow:setVisible(false)
--         return
--     end
--     -- self.upArrow:setVisible(true)
--     self.downArrow:setVisible(false)

--     if self.accountSView then
--         self.accountSView:setVisible(true)
--         self.accountSLabel:setString(self.loginInput1:getText())
--     end

--     if self.accountsView then
--         self.accountsView:setVisible(true)
--         self.loginShow = clone(AccountService.loginHis)
--         for i=1,#self.loginShow do
--             if self.loginShow[i].accountId == self.loginInput1:getText() then
--                 table.remove(self.loginShow,i)
--                 break
--             end
--         end

--         self.accountTableView:resetData(self.loginShow)
--         return
--     end

    

--     self.accountsView = display.newScale9Sprite(IMAGE_COMMON.."login/accountsBg.png",winSize.width / 2, winSize.height / 2 - 80)
--     self.accountsView:setPreferredSize(CCSizeMake(434, 165))
--     self.m_loginBg:addChild(self.accountsView)


--     self.accountSView = display.newScale9Sprite(IMAGE_COMMON.."login/accountsBg.png",winSize.width / 2, winSize.height / 2 + 25)
--     self.accountSView:setPreferredSize(CCSizeMake(434, 66))
--     self.m_loginBg:addChild(self.accountSView)
--     self.upArrow = display.newSprite(IMAGE_COMMON .. "login/up.png", 395,32)
--     self.upArrow:setScaleY(0.85)
--     self.accountSView:addChild(self.upArrow)

--     self.accountSLabel = CCLabelTTF:create(self.loginInput1:getText(), FONTS, 25)
--     self.accountSLabel:setAnchorPoint(ccp(0, 0.5))
--     self.accountSLabel:setPosition(35,30)
--     self.accountSLabel:setColor(ccc3(0,0,0))
--     self.accountSView:addChild(self.accountSLabel)

--     Helper.addTouchEvent(self.accountSView, function(event, x, y)
--         if event.name == "ended" then
--             ManagerSound.playNormalButtonSound()
--             self:closeHisAccount()
--         end
--         return true
--         end,true)

--     -- dump(self.loginHis)
    
--     local rect = CCRectMake(0, 0, 400, 140)
--     -- dump(GangDM.partyList)
--     local accountTableView = AccountListView.new(rect, self.loginShow, 1)
    

--     accountTableView:addEventListener("onItemClicked", handler(self, self.onItemClicked))
--     accountTableView:setPosition(15,10)
--     self.accountsView:addChild(accountTableView)
--     self.accountTableView = accountTableView
-- end

-- function LoginScene:closeHisAccount()
--     -- self.upArrow:setVisible(false)
--     self.downArrow:setVisible(true)
--     self.accountsView:setVisible(false)
--     self.accountSView:setVisible(false)
-- end

-- function LoginScene:onItemClicked(event)
--     self:closeHisAccount()
--     self.loginInput1:setText(event.data.accountId)
--     self.loginInput2:setText(event.data.passwd)
-- end

function LoginScene:showRegister(canSee)
    if not self.m_registerBg then
        local abg = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png", display.cx, display.cy - 50)
        abg:setPreferredSize(cc.size(582, 587))
        self:addChild(abg)
        self.m_registerBg = abg

        local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(abg, -1)
        btm:setPosition(abg:getContentSize().width / 2, abg:getContentSize().height / 2 - 6)
        btm:setScaleY((abg:getContentSize().height - 70) / btm:getContentSize().height)

        local labelColor = cc.c3b(98,165,210)

        local tilte = ui.newTTFLabel({text = LoginText[51], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_registerBg:getContentSize().width / 2, y = self.m_registerBg:getContentSize().height - 26, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_registerBg)

        local onEdit = function(event, editbox)
            -- if editbox:getText() == LoginText[1][1] or editbox:getText() == LoginText[2][1] or editbox:getText() == LoginText[3][1] then
            --     editbox:setText("")
            -- end
        end

        local width = 400
        local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

        local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_registerBg)
        inputBg:setPreferredSize(cc.size(width + 20, height + 10))
        inputBg:setPosition(self.m_registerBg:getContentSize().width / 2, self.m_registerBg:getContentSize().height - 180)

        local regInput1 = ui.newEditBox({x = self.m_registerBg:getContentSize().width / 2, y = self.m_registerBg:getContentSize().height - 180, size = cc.size(width, height), listener = onEdit}):addTo(self.m_registerBg)
        regInput1:setFontSize(16)
        regInput1:setFontColor(labelColor)
        -- regInput1:setText(LoginText[1][1])
        regInput1:setPlaceholderFontColor(labelColor)
        regInput1:setPlaceHolder(LoginText[1][1])

        local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_registerBg)
        inputBg:setPreferredSize(cc.size(width + 20, height + 10))
        inputBg:setPosition(self.m_registerBg:getContentSize().width / 2, self.m_registerBg:getContentSize().height - 280)

        local regInput2 = ui.newEditBox({x = self.m_registerBg:getContentSize().width / 2, y = self.m_registerBg:getContentSize().height - 280, size = cc.size(width, height), listener = onEdit}):addTo(self.m_registerBg)
        regInput2:setFontSize(16)
        regInput2:setFontColor(labelColor)
        -- regInput2:setText(LoginText[2][1])
        regInput2:setPlaceholderFontColor(labelColor)
        regInput2:setPlaceHolder(LoginText[2][1])
        regInput2:setInputFlag(0)

        local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_registerBg)
        inputBg:setPreferredSize(cc.size(width + 20, height + 10))
        inputBg:setPosition(self.m_registerBg:getContentSize().width / 2, self.m_registerBg:getContentSize().height - 380)

        local regInput3 = ui.newEditBox({x = self.m_registerBg:getContentSize().width / 2, y = self.m_registerBg:getContentSize().height - 380, size = cc.size(width, height), listener = onEdit}):addTo(self.m_registerBg)
        regInput3:setFontSize(16)
        regInput3:setFontColor(labelColor)
        -- regInput3:setText(LoginText[3][1])
        regInput3:setPlaceholderFontColor(labelColor)
        regInput3:setPlaceHolder(LoginText[3][1])
        regInput3:setInputFlag(0)

        self.m_registerBg.input1 = regInput1
        self.m_registerBg.input2 = regInput2
        self.m_registerBg.input3 = regInput3

        -- 返回按钮
        local normal = display.newSprite(IMAGE_COMMON .. "btn_2_normal.png")
        local selected = display.newSprite(IMAGE_COMMON.."btn_2_selected.png")
        local loginBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); self:showLogin(true) end)
        loginBtn:setLabel(LoginText[24])
        loginBtn:setPosition(self.m_registerBg:getContentSize().width / 2 - 120, 25)
        self.m_registerBg:addChild(loginBtn)

        --注册按钮
        local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
        local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
        local registerBtn = MenuButton.new(normal, selected, nil, function() ManagerSound.playNormalButtonSound(); self:register() end)
        registerBtn:setLabel(LoginText[23])
        registerBtn:setPosition(self.m_registerBg:getContentSize().width / 2 + 120, 25)
        self.m_registerBg:addChild(registerBtn)
    end

    if canSee then
        self.m_loginBg:setVisible(false)
        self.m_registerBg:setVisible(true)
    else
        self.m_loginBg:setVisible(true)
        self.m_registerBg:setVisible(false)
    end
end

-- 点击登录按钮
function LoginScene:onLoginCallback(tag, sender)
    ManagerSound.playNormalButtonSound()

    local email = string.gsub(self.loginInput1:getText(), " ", "")
    local pwd = string.gsub(self.loginInput2:getText(), " ", "")

    gprint("[LoginScene] login account:", email, "pwd:", pwd)

    if email == "" or pwd == "" then
        Toast.show(LoginText[6])
        return
    end

    -- 必须是字母和数字
    if string.find(email,"%W") ~= nil or string.find(pwd,"%W") ~= nil then
        Toast.show(LoginText[31])
        return
    end

    LoginBO.asynAccountLogin(email, pwd)
end

function LoginScene:register()
    -- if true then
    --     require("app.bo.TestRegisterBO")
    --     TestRegisterBO.start()
    --     return
    -- end

    local email = string.gsub(self.m_registerBg.input1:getText()," ","")
    local pwd1 = string.gsub(self.m_registerBg.input2:getText()," ","")
    local pwd2 = string.gsub(self.m_registerBg.input3:getText()," ","")

    gprint("[LoginScene] register: email", email, "pwd1", pwd1, "pwd2", pwd2)

    if email == "" or pwd1 == "" then
        Toast.show(LoginText[6])
        return
    end

    if pwd1 ~= pwd2 then
--         --print("两次密码不相等")
        Toast.show(LoginText[7])
        return
    end

    if string.find(email, "%W") ~= nil or string.find(pwd1, "%W") ~= nil or string.find(pwd2, "%W") ~= nil then
        Toast.show(LoginText[31])
        return
    end

    local length = string.len(email)
    if length > REGISTER_NAME_MAX_LEN then
        Toast.show(string.format(LoginText[36],REGISTER_NAME_MAX_LEN))
        return
    end

    LoginBO.asynRegistAccount(email, pwd1)
end

return LoginScene