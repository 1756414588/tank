
local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)

local LOADING_STATUS_START    = 0 -- 加载开始
local LOADING_STATUS_RESOURCE = 1 -- 需要加载资源
local LOADING_STATUS_DATA     = 2 -- 需要加载数据
local LOADING_STATUS_USER     = 4 -- 加载用于数据

function LoadingScene:ctor()
    local bg = LoginBO.getLoadingBg()
    bg:setScale(GAME_X_SCALE_FACTOR)
    self:addChild(bg)
    self.bg = bg
end

function LoadingScene:onEnter()

	-- 显示版本号
    local versionLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = display.width, y = 30, color = ccc3(255, 255, 255)}):addTo(self, 1000)
    versionLab:setAnchorPoint(cc.p(1,0.5))
    if GAME_APK_VERSION then
        versionLab:setString("App v" .. GAME_APK_VERSION .. "  Res v" .. GameConfig.version)
    else
        versionLab:setString("Res v" .. GameConfig.version)
    end
    
	self.loadingView = display.newNode():addTo(self)

	self.m_curPercent = 1
	self.m_curStatus = LOADING_STATUS_START

	local barBgName = ""

	if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
		barBgName = "image/screen/a_bg_7.png"
	else
		barBgName = "image/screen/b_bg_7.png"
		if HOME_SNOW_DEFAULT == 1 then
			barBgName = "image/screen/a_bg_7.png"
		end
	end

	local bar = ProgressBar.new(IMAGE_COMMON .. "login/bar_1.png", BAR_DIRECTION_HORIZONTAL, cc.size(296, 20), {bgName = barBgName}):addTo(self.loadingView)
	bar:setPosition(display.cx, display.cy - 380)
	self.loadingView.progressBar = bar

	local desc = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = display.cx, y = display.cy - 430, align = ui.TEXT_ALIGN_CENTER}):addTo(self.loadingView)
	self.loadingView.desc = desc

	local dot = display.newSprite("image/common/login/downEffect.png"):addTo(bar,100)
    dot:setPosition(0, 10)
    self.dot = dot

	self:showBar()

	self.m_frameCount = 0
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
	self:scheduleUpdate()

	self.exitScheduler_ = scheduler.scheduleGlobal(handler(self, self.onExitCallback), 30)  -- 一段时间内，没有完成加载，则重新登录
end

function LoadingScene:update(dt)
	if self.m_curStatus == LOADING_STATUS_START then
		-- 进入加载资源
		self.m_frameCount = 0
		self.m_curStatus = LOADING_STATUS_RESOURCE
		gprint("[LoadingScene] go to loading resource")
	elseif self.m_curStatus == LOADING_STATUS_RESOURCE then
		self:onLoadRes()
	elseif self.m_curStatus == LOADING_STATUS_DATA then
		self:onLoadData()
	elseif self.m_curStatus == LOADING_STATUS_USER then
		self:onLoadUser()
	end

	self:showBar()

	self.m_frameCount = self.m_frameCount + 1

end

function LoadingScene:onLoadRes()
	if self.m_frameCount == 4 then
		local texture = cc.TextureCache:sharedTextureCache():addImage("image/bg/bg_main_1_1.jpg")
		texture:retain()

		self.m_curPercent = 10
	elseif self.m_frameCount == 8 then
		local texture = cc.TextureCache:sharedTextureCache():addImage("image/bg/bg_wild_1_1.jpg")
		texture:retain()
		local texture = cc.TextureCache:sharedTextureCache():addImage("image/bg/bg_wild_1_2.jpg")
		texture:retain()

		local texture = cc.TextureCache:sharedTextureCache():addImage("image/world/tile_1.png")
		texture:retain()
		local texture = cc.TextureCache:sharedTextureCache():addImage("image/world/tile_2.png")
		texture:retain()
		local texture = cc.TextureCache:sharedTextureCache():addImage("image/world/world.png")
		texture:retain()

		self.m_curPercent = 20
	elseif self.m_frameCount == 10 then
		self.m_curPercent = 30
	elseif self.m_frameCount == 12 then
		self.m_curPercent = 32

		-- 进入加载数据
		self.m_frameCount = 0
		self.m_curStatus = LOADING_STATUS_DATA

		gprint("[LoadingScene] go to loading data")
	end
end

function LoadingScene:onLoadData()

	if self.m_frameCount == 4 then
		self.m_curPercent = 50

		HomeBO.init()
		AttributeMO.init()

		PendantMO.init()

		UserMO.init()
		if not UserMO.synResourceHandler_ then
			UserMO.synResourceHandler_ = SocketReceiver.register("SynResource", UserBO.parseSynResource, true)
		end

		TankMO.init()

		BuildMO.init()
		if not BuildMO.synBuildHandler_ then
			BuildMO.synBuildHandler_ = SocketReceiver.register("SynBuild", BuildBO.parseSynBuild, true)
		end

		PropMO.init()
		EquipMO.init()
		PartMO.init()

		EnergySparMO.init()

		ScienceMO.init()
		CombatMO.init()
		HeroMO.init()

		SocialityMO.init()
		if not SocialityMO.synBlessHandler_ then
			SocialityMO.synBlessHandler_ = SocketReceiver.register("SynBless", SocialityBO.parseSynBless, true)
		end

		if not SocialityMO.synFriendGiveHandler_ then
			SocialityMO.synFriendGiveHandler_ = SocketReceiver.register("SynFriendliness", SocialityBO.parseSynFriendGive, true)
		end

		SkillMO.init()
		EffectMO.init()
		LotteryMO.init()

		PartyMO.init()
		if not PartyMO.synPartyOutHandler_ then
			PartyMO.synPartyOutHandler_ = SocketReceiver.register("SynPartyOut", PartyBO.parseSynPartyOut, true)
		end

		if not PartyMO.synPartyAcceptHandler_ then
			PartyMO.synPartyAcceptHandler_ = SocketReceiver.register("SynPartyAccept", PartyBO.parseSynPartyAccept, true)
		end

		if not PartyMO.synApplyHandler_ then
			PartyMO.synApplyHandler_ = SocketReceiver.register("SynApply", PartyBO.parseSynApply, true)
		end

		PartyCombatMO.init()

		PartyBattleMO.init()
		if not PartyBattleMO.synReportHandler_ then
			PartyBattleMO.synReportHandler_ = SocketReceiver.register("SynWarRecord", PartyBattleBO.parseSynReport, true)
		end

		if not PartyBattleMO.synWarStateHandler_ then
			PartyBattleMO.synWarStateHandler_ = SocketReceiver.register("SynWarState", PartyBattleBO.parseSynWarState, true)
		end

		SignMO.init()
		WorldMO.init()
		TaskMO.init()
		VipMO.init()
		NewerMO.init()
		TriggerGuideMO.init()

		ChatMO.init()
		if not ChatMO.chatSynHandler_ then  -- 接受ChatSyn数据
			ChatMO.chatSynHandler_ = SocketReceiver.register("SynChat", ChatBO.parseChatSync, true)
		end

		--活跃宝箱的推送
		if not ActivityMO.activeBoxHandler_ then
			ActivityMO.activeBoxHandler_ = SocketReceiver.register("SynActiveBoxDrop", HomeBO.SyncActActiveBox, true)
		end

		if not ArmyMO.synInvasionHandler_ then
			ArmyMO.synInvasionHandler_ = SocketReceiver.register("SynInvasion", ArmyBO.parseSynInvasion, true)
		end

		if not ArmyMO.synArmyHandler_ then
			ArmyMO.synArmyHandler_ = SocketReceiver.register("SynArmy", ArmyBO.parseSynArmy, true)
		end

		MailMO.init()
		if not MailMO.synMailHandler_ then
			MailMO.synMailHandler_ = SocketReceiver.register("SynMail", MailBO.parseSynMail, true)
		end
		-- gdump(MailMO.myMails_,"MailMO.myMails_====")

		BuffMO.init()
		ActivityMO.init()
		ActivityCenterMO.init()
		RechargeMO.init()

		RechargeBO.init()
		if not RechargeMO.synGoldHandler_ then
			RechargeMO.synGoldHandler_ = SocketReceiver.register("SynGold", RechargeBO.parseSynGold, true)
		end

		StaffMO.init()
		if not StaffMO.synStaffingHandler_ then
			StaffMO.synStaffingHandler_ = SocketReceiver.register("SynStaffing", StaffBO.parseSynStaffing, true)
		end

		OrdnanceMO.init()

		if not FortressBO.synSelf_ then
			FortressBO.synSelf_ = SocketReceiver.register("SynFortressSelf", FortressBO.parseFortressSelf, true)
		end

		if not CrossBO.synSelf_ then
			CrossBO.synSelf_ = SocketReceiver.register("SynCrossState", CrossBO.parseCrossSelf, true)
		end

		if not CrossPartyBO.synSelf_ then
			CrossPartyBO.synSelf_ = SocketReceiver.register("SynCrossPartyState", CrossPartyBO.parseCrossSelf, true)
		end
		if not CrossPartyBO.synTeam_ then
			CrossPartyBO.synTeam_ = SocketReceiver.register("SynCPSituation", CrossPartyBO.parseCrossTeam, true)
		end
		if not PropBO.synSelf_ then
			PropBO.synSelf_ = SocketReceiver.register("SynInnerModProps", PropBO.parseModProps, true)
		end
		FortressMO.init()
		ExerciseMO.init()
		RebelMO.init()

		--叛军BOSS状态推送
		if not RebelMO.synRebelBossHandler_ then
			RebelMO.synRebelBossHandler_= SocketReceiver.register("RebelBoosState", RebelBO.parseSynRebelBoss, true)
		end

		--叛军BOSS死亡推送
		if not RebelMO.synRebelBossDieHandler_ then
			RebelMO.synRebelBossDieHandler_= SocketReceiver.register("RebelBoosEffect", RebelBO.parseSynOnRebelBossDie, true)
		end

		CrossMO.init()
		CrossPartyMO.init()
		MedalMO.init()
		WeaponryMO.init()
		MaterialMO.init()  --材料工坊MO
		PlayerBackMO.init()--玩家回归MO
		if not WeaponryBO.synSelf_ then
			WeaponryBO.synSelf_ = SocketReceiver.register("SynUnlockTechnical", WeaponryBO.parseUnlockTechnical, true)
		end	

		ActivityWeekMO.init()
		if not ActivityWeekMO.synDay7ActTipsHandler_ then
			ActivityWeekMO.synDay7ActTipsHandler_ = SocketReceiver.register("SynDay7ActTips", ActivityWeekMO.parseSynDay7ActTips, true)
		end
		AirshipMO.init()
		if UserMO.queryFuncOpen(UFP_AIRSHIP) and not AirshipBO.synTeamArmy_ then
			AirshipBO.synTeamArmy_ = SocketReceiver.register("SynAirshipTeamArmy", AirshipBO.updateTeamArmy, true)
		end

		if UserMO.queryFuncOpen(UFP_AIRSHIP) and not AirshipBO.synAirShipTeamChange_ then
			AirshipBO.synAirShipTeamChange_ = SocketReceiver.register("SynAirshipTeam", AirshipBO.parseSynAirShipTeamChanged, true)
		end

		if UserMO.queryFuncOpen(UFP_AIRSHIP) and not AirshipBO.synAirShipChange_ then
			AirshipBO.synAirShipChange_ = SocketReceiver.register("SynAirshipChange", AirshipBO.parseSynAirShipChanged, true)
		end

		if UserMO.queryFuncOpen(UFP_MAIL_SYNC) and not MailBO.synMailChange_ then
			MailBO.synMailChange_ = SocketReceiver.register("SyncMail", MailBO.SyncMail, true)
		end

		if not UserMO.systemLoginErrorListener then
			UserMO.systemLoginErrorListener = SocketReceiver.register("SynLoginElseWhere", UserMO.SystemLoginError, true)
		end

		if not UserMO.SynPlugInScoutMineListener then
			UserMO.SynPlugInScoutMineListener = SocketReceiver.register("SynPlugInScoutMine", UserBO.SynPlugInScoutMine, true)
		end

		PictureValidateMO.init() --图片验证

		MilitaryRankMO.init()
		WarWeaponMO.Init()
		FighterEffectMO.init()
		LaboratoryMO.init()
		HunterMO.init()
		RoyaleSurviveMO.init()
		TacticsMO.init() --战术
		if not TacticsMO.tacticSynHandler_ then
			TacticsMO.tacticSynHandler_ = SocketReceiver.register("SynTactics", TacticsBO.parseTacticSync, true)
		end

		--能源核心
		EnergyCoreMO.init()

		if not HunterMO.synTeamInfoHandler_ then
			HunterMO.synTeamInfoHandler_ = SocketReceiver.register("SynTeamInfo", HunterBO.SynTeamInfo, true)
		end

		if not HunterMO.synNotifyDismissTeamHandler_ then
			HunterMO.synNotifyDismissTeamHandler_ = SocketReceiver.register("SynNotifyDisMissTeam", HunterBO.SynNotifyDismissTeam, true)
		end

		if not HunterMO.synNotifyKickOutHandler_ then
			HunterMO.synNotifyKickOutHandler_ = SocketReceiver.register("SynNotifyKickOut", HunterBO.SynNotifyKickOut, true)
		end

		if not HunterMO.synChangeStatusHandler_ then
			HunterMO.synChangeStatusHandler_ = SocketReceiver.register("SynChangeStatus", HunterBO.SynChangeStatus, true)
		end

		if not HunterMO.synTeamOrderHandler_ then
			HunterMO.synTeamOrderHandler_ = SocketReceiver.register("SynTeamOrder", HunterBO.SynTeamOrder, true)
		end

		if not HunterMO.synTeamChatHandler_ then
			HunterMO.synTeamChatHandler_ = SocketReceiver.register("SynTeamChat", HunterBO.SynTeamChat, true)
		end

		if not HunterMO.synStageCloseToTeamHandler_ then
			HunterMO.synStageCloseToTeamHandler_ = SocketReceiver.register("SynStageCloseToTeam", HunterBO.SynStageCloseToTeam, true)
		end

		if not HunterMO.synTeamFightBossHandler_ then
			HunterMO.synTeamFightBossHandler_ = SocketReceiver.register("SyncTeamFightBoss", HunterBO.SyncTeamFightBoss, true)
		end

		--跨服信息
		if not HunterMO.synTeamFightCrossHandler_ then
			HunterMO.synTeamFightCrossHandler_ = SocketReceiver.register("SynCrossServerInfo", HunterBO.SyncTeamFightCrossInfo, true)
		end

		if not RechargeMO.synActNewPayInfoHandler_ then
			RechargeMO.synActNewPayInfoHandler_ = SocketReceiver.register("SyncActNewPayInfo", HunterBO.SyncActNewPayInfo, true)
		end

		if not RechargeMO.synActNew2PayInfoHandler_ then
			RechargeMO.synActNew2PayInfoHandler_ = SocketReceiver.register("SyncActNew2PayInfo", HunterBO.SyncActNew2PayInfo, true)
		end

		if not RoyaleSurviveMO.synHonourSurviveOpenHandler_ then
			RoyaleSurviveMO.synHonourSurviveOpenHandler_ = SocketReceiver.register("SynHonourSurviveOpen", RoyaleSurviveBO.SynHonourSurviveOpen, true)
		end

		if not RoyaleSurviveMO.synUpdateSafeAreaHandler_ then
			RoyaleSurviveMO.synUpdateSafeAreaHandler_ = SocketReceiver.register("SynUpdateSafeArea", RoyaleSurviveBO.SynUpdateSafeArea, true)
		end

		if not RoyaleSurviveMO.synNextSafeAreaHandler_ then
			RoyaleSurviveMO.synNextSafeAreaHandler_ = SocketReceiver.register("SynNextSafeArea", RoyaleSurviveBO.SynNextSafeArea, true)
		end

		if not WorldMO.synWorldStaffingHandler_ then
			WorldMO.synWorldStaffingHandler_ = SocketReceiver.register("SynWorldStaffing", WorldBO.SynWorldStaffing, true)
		end

		if not ActivityMO.partyWarHandler_ then
			ActivityMO.partyWarHandler_ = SocketReceiver.register("SynWarActivityInfo", ActivityBO.SynPartyWarInfo, true)
		end

		if not PartyMO.partyBossHandler_ then
			PartyMO.partyBossHandler_ = SocketReceiver.register("SynFeedAltarContriButeExp", PartyBO.SynPartyBossInfo, true)
		end

	elseif self.m_frameCount == 12 then
		self.m_curPercent = 92

		self.m_frameCount = 0
		self.m_curStatus = LOADING_STATUS_USER

		gprint("[LoadingScene] go to request connect server")
	end
end

function LoadingScene:onLoadUser()
	if not self.request_ then
		self.request_ = true

		local function doneLordData()
			gprint("[LoadingScene] go to lord data done")

			-- self.m_curPercent = 95
			self:onComplete()
		end

		UserBO.asynLordData(doneLordData)
	end
end

function LoadingScene:updatePer(per)
	self.m_curPercent = per
end

function LoadingScene:showBar()
	self.loadingView.progressBar:setPercent(self.m_curPercent / 100)
	self.loadingView.desc:setString(LoginText[49] .. self.m_curPercent .. "%")

	local w = self.loadingView.progressBar:getContentSize().width * self.m_curPercent / 100
	self.dot:setPositionX(w)
end

function LoadingScene:onComplete()
	--TK统计 登录设置帐号
	TKGameBO.setAccount(UserMO.lordId_,GameConfig.areaId)
	TKGameBO.setAccountName(UserMO.nickName_)
	TKGameBO.setLevel(UserMO.level_)
    		
	if GameConfig.environment == "n_uc_client" or GameConfig.environment == "oppo_client" 
		or GameConfig.environment == "pps_client" or GameConfig.environment == "mi_client" 
		or GameConfig.environment == "4399_client" or GameConfig.environment == "kugou_client" 
		or GameConfig.environment == "mmy_client" or GameConfig.environment == "youlong_client" 
		or GameConfig.environment == "kaopu_client" or GameConfig.environment == "nduo_client" 
		or GameConfig.environment == "zty_client" or GameConfig.environment == "chpub_client" 
		or GameConfig.environment == "anfan_client" or GameConfig.environment == "tencent_chpub" 
		or GameConfig.environment == "anfanKoudai_client" or GameConfig.environment == "weiuu_client" 
		or GameConfig.environment == "anzhi_client" or GameConfig.environment == "37wan_client"
		or GameConfig.environment == "ch_appstore"  or GameConfig.environment == "af_appstore" 
		or GameConfig.environment == "kaopu_client" or GameConfig.environment == "chYh_client" 
		or GameConfig.environment == "mz_appstore" or GameConfig.environment == "muzhiJh_client" 
		or GameConfig.environment == "chpub_hj4_client" or GameConfig.environment == "anfan_client_small" 
		or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "mztkwz_appstore" 
		or GameConfig.environment == "mztkdg_appstore" or GameConfig.environment == "mzeztk_appstore" 
		or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore" 
		or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "anfanJh_client" 
		or GameConfig.environment == "muzhi_49" or GameConfig.environment == "mztkwz_client" 
		or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "muzhiJhly_client" 
		or GameConfig.environment == "mztkjjylfc_appstore" or GameConfig.environment == "ztyLy_client" 
		or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "anfanaz_client" 
		or GameConfig.environment == "chgtfc_appstore" or GameConfig.environment == "chzdjj_appstore" 
		or GameConfig.environment == "pptv_client" or GameConfig.environment == "chdgfb_appstore" 
		or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "chpubNew_client" 
		or GameConfig.environment == "mzAqHszz_appstore" or GameConfig.environment == "mzAqTkjt_appstore" 
		or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "chxsjt_appstore" 
		or GameConfig.environment == "tencent_chpub_zzzhg" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" 
        or GameConfig.environment == "mzAqZzfy_appstore" or GameConfig.environment == "mzTkjjQysk_appstore" 
        or GameConfig.environment == "muzhiU8ly_client" or GameConfig.environment == "muzhiJhYyb_client" 
        or GameConfig.environment == "downjoy_client" or GameConfig.environment == "chzzzhg_appstore" 
        or GameConfig.environment == "afGhgxs_appstore" or GameConfig.environment == "afMjdzh_appstore" 
        or GameConfig.environment == "afWpzj_appstore" or GameConfig.environment == "afXzlm_appstore" 
        or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "chzzzhg1_appstore" 
        or GameConfig.environment == "muzhiTkjj_client" or GameConfig.environment == "hongshouzhi_client" 
        or GameConfig.environment == "aile_client" or GameConfig.environment == "youlong_client" 
        or GameConfig.environment == "chzzzhg2_appstore" or GameConfig.environment == "afghgzh_client" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore"
		or GameConfig.environment == "chhjfc_hawei_client" or GameConfig.environment == "chhjfc_mi_client"
		or GameConfig.environment == "chhjfc_gp_client" or GameConfig.environment == "chhjfc_baidu_client"
    	or GameConfig.environment == "chhjfc_uc_client" or GameConfig.environment == "chhjfc_sw_client"
    	or GameConfig.environment == "chhjfc_meizu_client" or GameConfig.environment == "chhjfc_coolpad_client"
    	or GameConfig.environment == "chhjfc_gionee_client" or GameConfig.environment == "chhjfc_downjoy_client"
    	or GameConfig.environment == "chhjfc_xiaoqi_client" or GameConfig.environment == "chhjfc_360_client"
    	or GameConfig.environment == "chhjfc_lenovo_client" or GameConfig.environment == "chhjfc_sanxing_client"
    	or GameConfig.environment == "chhjfc_oppo_client" or GameConfig.environment == "afTqdknHD_appstore"
    	or GameConfig.environment == "tencent_chpub_redtank" or GameConfig.environment == "chhjfc_yyb_client" 
    	or GameConfig.environment == "muzhiJhYyb1_client" or GameConfig.environment == "chCjzjtkzz_appstore" 
    	or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "chZjqytkdz_appstore"
    	or GameConfig.environment == "muzhi_vertify" or GameConfig.environment == "mzLzwz_appstore" 
    	or GameConfig.environment == "afNewMjdzh_appstore" or GameConfig.environment == "afNewWpzj_appstore" 
    	or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
			ServiceBO.setUserInfo()
	end
	

	-- 读取客户端配置
	local content = readfile(GAME_SETTING_FILE .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId)
	if content then
		local data = json.decode(content)
		ManagerSound.musicEnable = data[1]
		ManagerSound.soundEnable = data[2]
		UserMO.autoDefend = data[3]
		UserMO.consumeConfirm = data[4]
		UserMO.showBuildName = data[5]
		UserMO.showArmyLine = data[6]
		UserMO.showPintUI = data[7]
	end

	self.m_curPercent = 99
	self:runAction(transition.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function()
			gprint("[LoadingScene] go to main")

		    if self.exitScheduler_ then
		    	scheduler.unscheduleGlobal(self.exitScheduler_)
		    	self.exitScheduler_ = nil
		    end
		    -----------登陆时额外检查数据--------
		    UserBO.triggerCombatStar()
		    if not StaffMO.hasData_ then
		    	StaffBO.asynGetStaffing()
		    end
	        if ActivityCenterBO.getActivityById(ACTIVITY_ID_COLLECRION) then
	    	    ActivityCenterBO.GetCollectInfo(function()
	    	    end)
	    	end
    	    if ActivityCenterBO.getActivityById(ACTIVITY_ID_VACATION) then
    		    ActivityCenterBO.asynGetActivityContent(function()
    		    	end,ACTIVITY_ID_VACATION)
    		end
    		if ActivityCenterBO.getActivityById(ACTIVITY_ID_BROTHER) and not ActivityCenterMO.ActivityBrotherListener then
    			ActivityCenterMO.ActivityBrotherListener = SocketReceiver.register("SynBrother", ActivityCenterBO.AcceptBrotherList, true)
    		end
    		if ActivityCenterBO.getActivityById(ACTIVITY_ID_BROTHER) and not ActivityCenterMO.ActivityBroFightLitener then
    			ActivityCenterMO.ActivityBroFightLitener = SocketReceiver.register("SynAirShipFightTask", ActivityCenterBO.AcceptBrotherFight, true)
    		end
			Enter.startMain()
		end)}))
end

function LoadingScene:onExit()
    -- self:removeAllChildrenWithCleanup(true)
    -- clearImageCache()

    if self.exitScheduler_ then
    	scheduler.unscheduleGlobal(self.exitScheduler_)
    	self.exitScheduler_ = nil
    end
end

function LoadingScene:onExitCallback()
	gprint("LoadingScene:onExitCallback....")
    if self.exitScheduler_ then
    	scheduler.unscheduleGlobal(self.exitScheduler_)
    	self.exitScheduler_ = nil
    end

	SocketWrapper:getInstance():disconnect()

	Enter.startLogin()
end

return LoadingScene