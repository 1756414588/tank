--
-- Author: gf
-- Date: 2015-10-17 09:51:07
--

-- 主场景中活动按钮

local HomeActivityButtonView = class("HomeActivityButtonView", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

AWARD_BUTTON_INDEX_RECHARGE  	= 1 -- 首充禮包
AWARD_BUTTON_INDEX_LOGIN    	= 2 -- 登录奖励
AWARD_BUTTON_INDEX_ACTIVITY  	= 3 -- 热门活动
AWARD_BUTTON_INDEX_DAILY 		= 4 -- 日常活动
AWARD_BUTTON_INDEX_PARTYTIP		= 5 -- 军团加入
AWARD_BUTTON_INDEX_DAYPAY		= 6 -- 每日充值
AWARD_BUTTON_INDEX_DAY7  		= 7 -- 7日活动
AWARD_BUTTON_INDEX_DAYUP  		= 8 -- 7日活动秒升级
AWARD_BUTTON_INDEX_SIGN  		= 9 -- 累计签到

AWARD_BUTTON_INDEX_EXPADD  		= 10 -- 拇指广告经验加速
AWARD_BUTTON_INDEX_STAFFADD  	= 11 -- 拇指广告编制加速
AWARD_BUTTON_INDEX_POWERADD  	= 12 -- 拇指广告获得体力
AWARD_BUTTON_INDEX_VITALITY     = 13 --新活跃度

AWARD_BUTTON_INDEX_SERVER_FIXED	= 14 --定时奖励
AWARD_BUTTON_INDEX_EXP_ADDITION	= 15 --经验加成
AWARD_BUTTON_INDEX_WEL_FARE 	= 16 --福利特惠

function HomeActivityButtonView:ctor()
end

function HomeActivityButtonView:onEnter()
	--加载动画
	armature_add("animation/effect/ui_btn_activity_first.pvr.ccz", "animation/effect/ui_btn_activity_first.plist", "animation/effect/ui_btn_activity_first.xml")
	armature_add("animation/effect/ui_btn_activity_hot.pvr.ccz", "animation/effect/ui_btn_activity_hot.plist", "animation/effect/ui_btn_activity_hot.xml")
	armature_add("animation/effect/ui_btn_activity_login.pvr.ccz", "animation/effect/ui_btn_activity_login.plist", "animation/effect/ui_btn_activity_login.xml")
	armature_add("animation/effect/ui_btn_activity_daily.pvr.ccz", "animation/effect/ui_btn_activity_daily.plist", "animation/effect/ui_btn_activity_daily.xml")
	armature_add("animation/effect/ui_btn_activity_daily_recharge.pvr.ccz", "animation/effect/ui_btn_activity_daily_recharge.plist", "animation/effect/ui_btn_activity_daily_recharge.xml")
	armature_add("animation/effect/shengdan_7rihuodong.pvr.ccz", "animation/effect/shengdan_7rihuodong.plist", "animation/effect/shengdan_7rihuodong.xml")
	armature_add("animation/effect/shengdan_juntuan.pvr.ccz", "animation/effect/shengdan_juntuan.plist", "animation/effect/shengdan_juntuan.xml")
	armature_add("animation/effect/shengdan_miaoshengyiji.pvr.ccz", "animation/effect/shengdan_miaoshengyiji.plist", "animation/effect/shengdan_miaoshengyiji.xml")
	armature_add("animation/effect/shengdan_shouchong.pvr.ccz", "animation/effect/shengdan_shouchong.plist", "animation/effect/shengdan_shouchong.xml")
	armature_add("animation/effect/tehui_lingdang.pvr.ccz", "animation/effect/tehui_lingdang.plist", "animation/effect/tehui_lingdang.xml")

	self.m_buttons = {}

	--登录奖励
	if not SignMO.dailyLogin_.display then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_normal.png")
		normal:setOpacity(0)
		local btn = ScaleButton.new(normal, handler(self, self.onLoginCallback)):addTo(self, -1)
		btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		-- btn:setScale(0.8)
		self.m_buttons[AWARD_BUTTON_INDEX_LOGIN] = btn
	

		local lightEffect = CCArmature:create("ui_btn_activity_login")
	    lightEffect:getAnimation():playWithIndex(0)
	    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 +2)
		btn:addChild(lightEffect)	
	end        

	--每日充值
	local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_normal.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onDayPayCallback)):addTo(self, -1)
	btn:setPosition(self:getContentSize().width / 2 - 70, self:getContentSize().height / 2 + 2 )
	-- btn:setScale(0.8)
	self.m_buttons[AWARD_BUTTON_INDEX_DAYPAY] = btn

	local lightEffect = CCArmature:create("ui_btn_activity_daily_recharge")
    lightEffect:getAnimation():playWithIndex(0)
    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 - 4)
	btn:addChild(lightEffect)
	btn:setVisible(UserMO.openServerDay < ACTIVITY_WEL_FARE)	        

	--福利特惠
	local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_normal.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onWelFareCallback)):addTo(self, -1)
	btn:setPosition(self:getContentSize().width / 2 - 70, self:getContentSize().height / 2 + 2 )
	self.m_buttons[AWARD_BUTTON_INDEX_WEL_FARE] = btn

	local lightEffect = CCArmature:create("tehui_lingdang")
    lightEffect:getAnimation():playWithIndex(0)
    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 - 4)
	btn:addChild(lightEffect)        
	btn:setVisible(UserMO.openServerDay >= ACTIVITY_WEL_FARE)
	
	--热门活动
	local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_normal.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onActivityCallback)):addTo(self, -1)
	btn:setPosition(self:getContentSize().width / 2 - 70 * 2, self:getContentSize().height / 2)
	-- btn:setScale(0.8)
	self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY] = btn
	--光效
	local lightEffect = armature_create("ui_btn_activity_hot", btn:getContentSize().width / 2, btn:getContentSize().height / 2 )
    lightEffect:getAnimation():playWithIndex(0)
	btn:addChild(lightEffect)	        

	-- 日常活动
	local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_normal.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onDailyCallback)):addTo(self, -1)
	btn:setPosition(self:getContentSize().width / 2 - 70 * 3, self:getContentSize().height / 2)
	-- btn:setScale(0.8)
	self.m_buttons[AWARD_BUTTON_INDEX_DAILY] = btn
	local armature = armature_create("ui_btn_activity_daily", btn:getContentSize().width / 2, btn:getContentSize().height / 2 ):addTo(btn)
	armature:getAnimation():playWithIndex(0)

	-- 签到活动
	if SignMO.dailyLogin_.display then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_sign.png")
		local btn = ScaleButton.new(normal, handler(self, self.onSignCallback)):addTo(self, -1)
		-- btn:setPosition(self:getContentSize().width / 2 - 70 * 4, self:getContentSize().height / 2)
		btn:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		-- btn:setScale(0.8)
		self.m_buttons[AWARD_BUTTON_INDEX_SIGN] = btn
	end
	-- local armature = armature_create("ui_btn_activity_daily", btn:getContentSize().width / 2, btn:getContentSize().height / 2 + 2):addTo(btn)
	-- armature:getAnimation():playWithIndex(0)

	-- 新活跃度
	if UserMO.queryFuncOpen(UFP_NEW_ACTIVE) then
		local normal = display.newSprite(IMAGE_COMMON .. "btn_new_active.png")
		local btn = ScaleButton.new(normal, handler(self, self.onActiveCallback)):addTo(self, -1)
		btn:setPosition(self:getContentSize().width / 2 - 70 * 4, self:getContentSize().height / 2)
		self.m_buttons[AWARD_BUTTON_INDEX_VITALITY] = btn
	end

	--7日活动
	local normal = display.newSprite(IMAGE_COMMON .. "day_7.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onDay7Callback)):addTo(self, -1)
	btn:setPosition(-70, -80)
	self.m_buttons[AWARD_BUTTON_INDEX_DAY7] = btn
	--7日特效
	local lightEffect = armature_create("shengdan_7rihuodong", btn:getContentSize().width / 2, btn:getContentSize().height / 2 )
    lightEffect:getAnimation():playWithIndex(0)
	btn:addChild(lightEffect)
	-- local lightEffect = CCArmature:create("ui_btn_activity_first")
 --    lightEffect:getAnimation():playWithIndex(0)
 --    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
 --    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	-- btn:addChild(lightEffect)	

	--7日活动秒升级
	local normal = display.newSprite(IMAGE_COMMON .. "quick_up.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onDayUpCallback)):addTo(self, -1)
	btn:setPosition(-140, -80)
	self.m_buttons[AWARD_BUTTON_INDEX_DAYUP] = btn
	--秒升特效
	local lightEffect = armature_create("shengdan_miaoshengyiji", btn:getContentSize().width / 2, btn:getContentSize().height / 2 + 4 )
    lightEffect:getAnimation():playWithIndex(0)
	btn:addChild(lightEffect)
	-- local lightEffect = CCArmature:create("ui_btn_activity_first")
 --    lightEffect:getAnimation():playWithIndex(0)
 --    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
 --    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	-- btn:addChild(lightEffect)	

	--首充禮包
	local normal = display.newSprite(IMAGE_COMMON .. "btn_activity_first.png")
	normal:setOpacity(0)
	local btn = ScaleButton.new(normal, handler(self, self.onFirstRechargeCallback)):addTo(self, -1)
	btn:setPosition(0, -80)
	-- btn:setScale(0.8)
	self.m_buttons[AWARD_BUTTON_INDEX_RECHARGE] = btn

	--首充特效
	local lightEffect = armature_create("shengdan_shouchong", btn:getContentSize().width / 2, btn:getContentSize().height / 2 )
    lightEffect:getAnimation():playWithIndex(0)
	btn:addChild(lightEffect)	  

	-- local lightEffect = CCArmature:create("ui_btn_activity_first")
 --    lightEffect:getAnimation():playWithIndex(0)
 --    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
 --    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
	-- btn:addChild(lightEffect)	        

	--加入军团按钮
	local function onPartyCallback()
		require("app.dialog.PartyJoinTipDialog").new():push()
	end

	local normal = display.newSprite(IMAGE_COMMON .. "icon_party_join.png")
	normal:setOpacity(0)
	-- local selected = display.newSprite(IMAGE_COMMON .. "icon_party_join.png")
	local partyBtn = ScaleButton.new(normal, onPartyCallback):addTo(self, -1)
	partyBtn:setPosition(0, -160)
	-- partyBtn:setScale(0.8)
	self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP] = partyBtn
	--军团特效
	local lightEffect = armature_create("shengdan_juntuan", partyBtn:getContentSize().width / 2, partyBtn:getContentSize().height / 2 )
    lightEffect:getAnimation():playWithIndex(0)
	partyBtn:addChild(lightEffect)	  
	-- local lightEffect = CCArmature:create("ui_btn_activity_first")
 --    lightEffect:getAnimation():playWithIndex(0)
 --    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
 --    lightEffect:setPosition(partyBtn:getContentSize().width / 2, partyBtn:getContentSize().height / 2)
	-- partyBtn:addChild(lightEffect)




	-- if ActivityBO.ServerFixedCheck() > 0 then
	local function onOpenServerFixed()
		require("app.dialog.ServerFixedAwardDialog").new():push()
	end
	-- 定时礼包
	local normal = display.newSprite(IMAGE_COMMON .. "icon_fixed.png")
	local fixedBtn = ScaleButton.new(normal, onOpenServerFixed):addTo(self, -1)
	fixedBtn:setPosition(self:getContentSize().width / 2 - 70 * 5 - 5, self:getContentSize().height / 2)

	local timelb = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, 
	x = fixedBtn:width() * 0.5, y = 13, color = cc.c3b(163, 19, 19), align = ui.TEXT_ALIGN_CENTER}):addTo(fixedBtn)
	fixedBtn.timelb = timelb

	local fixedsp = display.newSprite(IMAGE_COMMON .. "icon_fixed_ksb.png"):addTo(fixedBtn)
	fixedsp:setPosition(fixedBtn:width() * 0.5 , 37)
	fixedsp:setVisible(false)
	fixedBtn.fixedsp = fixedsp

	self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED] = fixedBtn
	-- end
	


	if ServiceBO.muzhiAdPlat() then

		local normal = display.newSprite(IMAGE_COMMON .. "adPowerAdd.png")
		local btn = ScaleButton.new(normal, handler(self, self.onPowerAddCallback)):addTo(self, -1)
		if self.m_buttons[AWARD_BUTTON_INDEX_DAYUP]:isVisible() then
			btn:setPosition(-220, -80)
		else
			btn:setPosition(-70, -80)
		end
		
		self.m_buttons[AWARD_BUTTON_INDEX_POWERADD] = btn
		local lightEffect = CCArmature:create("ui_btn_activity_first")
	    lightEffect:getAnimation():playWithIndex(0)
	    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
		btn:addChild(lightEffect)

		--拇指观看广告 经验和编制加速按钮
		local normal = display.newSprite(IMAGE_COMMON .. "adExpAdd.png")
		local btn = ScaleButton.new(normal, handler(self, self.onExpAddCallback)):addTo(self, -1)
		btn:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_POWERADD]:getPositionX() - 80, -80)
		self.m_buttons[AWARD_BUTTON_INDEX_EXPADD] = btn
		local lightEffect = CCArmature:create("ui_btn_activity_first")
	    lightEffect:getAnimation():playWithIndex(0)
	    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
		btn:addChild(lightEffect)

		local normal = display.newSprite(IMAGE_COMMON .. "adStaffAdd.png")
		local btn = ScaleButton.new(normal, handler(self, self.onStaffAddCallback)):addTo(self, -1)
		btn:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_EXPADD]:getPositionX() - 80, -80)
		self.m_buttons[AWARD_BUTTON_INDEX_STAFFADD] = btn
		local lightEffect = CCArmature:create("ui_btn_activity_first")
	    lightEffect:getAnimation():playWithIndex(0)
	    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
	    lightEffect:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
		btn:addChild(lightEffect)


	end
	
	--经验加成
	if UserMO.level_ < 90 then
		local normal = display.newSprite(IMAGE_COMMON .. "exp_addition.png")
		local btn = ScaleButton.new(normal, function ()
			UiDirector.push(require("app.dialog.ExpAdditionDialog").new())
		end):addTo(self, -1)

		if self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:isVisible() then
			btn:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:getPositionX(), self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:getPositionY() - 80)
		else
			btn:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:getPosition())
		end
		self.m_buttons[AWARD_BUTTON_INDEX_EXP_ADDITION] = btn
	end

	
	self.timerHandler_ = ManagerTimer.addTickListener(handler(self, self.update))
	self.m_signHandler = Notify.register(LOCAL_SIGN_UPDATE_EVENT, handler(self, self.updateTip))
	self.m_activityHandler = Notify.register(LOCLA_ACTIVITY_EVENT, handler(self, self.updateTip))
	self.m_activityCenterHandler = Notify.register(LOCLA_ACTIVITY_CENTER_EVENT, handler(self, self.updateTip))
	self.m_partyTipHandler = Notify.register(LOCAL_MYPARTY_UPDATE_EVENT, handler(self, self.updateTip))
	self.m_dayPayHandler = Notify.register(LOCAL_DAYPAY_UPDATE_EVENT, handler(self, self.updateTip))
	self.m_taskliveHandler = Notify.register(LOCAL_ACTIVITY_TASK_LIVE, handler(self, self.updateTip))

	self:updateTip()
	self:update(0)
end


function HomeActivityButtonView:update(dt)
	--首充礼包
	self.m_buttons[AWARD_BUTTON_INDEX_RECHARGE]:setVisible(ActivityBO.isPayFirstOpen())

	--军团tip按钮
	self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:setVisible(UserMO.level_ >= 10 and UserMO.partyTipAward_ and UserMO.partyTipAward_ ~= 2)

	if self.m_buttons[AWARD_BUTTON_INDEX_DAY7] then
	    -- AWARD_BUTTON_INDEX_DAY7 , AWARD_BUTTON_INDEX_DAYUP
	    -- 前7天不限制等级 之后小于55级才可见
	    if UserMO.level_ < 70 and UserBO.getWeekAwardEndTime() - ManagerTimer.getTime() > 0 then
	        self.m_buttons[AWARD_BUTTON_INDEX_DAY7]:setVisible(true)
	        self.m_buttons[AWARD_BUTTON_INDEX_DAYUP]:setVisible(true)
	        local function show()
	            if  ActivityWeekBO.firstOpen == true then
	                if ActivityWeekMO.RedPoint ~= nil  and ActivityWeekMO.RedPoint >= 0 then      
	                    UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_DAY7], ActivityWeekMO.RedPoint+1, 50, 50)
	                end
	            else
	                if ActivityWeekMO.RedPoint ~= nil  and ActivityWeekMO.RedPoint >= 1 then      
	                    UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_DAY7], ActivityWeekMO.RedPoint, 50, 50)
	                else
	                    UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_DAY7])
	                end          
	            end
	            if ActivityWeekMO.lvUpIsUse == false then
	                UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_DAYUP], 1, 50, 50)
	            else
	                UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_DAYUP])
	            end
	        end
	        if not ActivityWeekMO.WeekList_ then
	            ActivityWeekMO.WeekList_  = {}
	            ActivityWeekBO.asynGetDay7ActTips(function(success,data) if success then show() end end)
	        else
	            show()
	        end
	    else
	        self.m_buttons[AWARD_BUTTON_INDEX_DAYUP]:setVisible(false)
	        self.m_buttons[AWARD_BUTTON_INDEX_DAY7]:setVisible(false)
	    end
	    if UserBO.getWeekActEndTime() - ManagerTimer.getTime() <= 0 then
	        self.m_buttons[AWARD_BUTTON_INDEX_DAYUP]:setVisible(false)
	    end

	end
	if SignMO.dailyLogin_.display then
		if ActivityBO.hasSign() then      
		    UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_SIGN], 1, 50, 50)
		else
		    UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_SIGN])
		end 
	end

	if self.m_buttons[AWARD_BUTTON_INDEX_STAFFADD] then
		self.m_buttons[AWARD_BUTTON_INDEX_STAFFADD]:setVisible(MuzhiADMO.StaffingAddADTime >= 0)
	end
	if self.m_buttons[AWARD_BUTTON_INDEX_POWERADD] then
		if self.m_buttons[AWARD_BUTTON_INDEX_DAYUP]:isVisible() then
			self.m_buttons[AWARD_BUTTON_INDEX_POWERADD]:setPosition(-220, -80)
		else
			self.m_buttons[AWARD_BUTTON_INDEX_POWERADD]:setPosition(-70, -80)
		end
		if self.m_buttons[AWARD_BUTTON_INDEX_EXPADD] then
			self.m_buttons[AWARD_BUTTON_INDEX_EXPADD]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_POWERADD]:getPositionX() - 80, -80)
		end
		if self.m_buttons[AWARD_BUTTON_INDEX_STAFFADD] then
			self.m_buttons[AWARD_BUTTON_INDEX_STAFFADD]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_EXPADD]:getPositionX() - 80, -80)
		end
	end

	-- 闪击行动
	if self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED] then
		local time = ActivityBO.ServerFixedUpdate()
		if time then
			if time == -1 or time == -3 then -- 关闭显示
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED]:setVisible(false)
			elseif time == -2 then -- 可领取
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED]:setVisible(true)
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].fixedsp:setVisible(true)
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].timelb:setString("")
			-- elseif time == -3 then -- 领取完
			-- 	self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED]:setVisible(true)
			-- 	self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].fixedsp:setVisible(false)
			-- 	self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].timelb:setString("")
			else -- 显示倒计时
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED]:setVisible(true)
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].fixedsp:setVisible(false)
				self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED].timelb:setString(UiUtil.strBuildTime(time,"dhm"))
			end
		else
			self.m_buttons[AWARD_BUTTON_INDEX_SERVER_FIXED]:setVisible(false)
		end
	end

	--军团
	if self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP] then
		if self.m_buttons[AWARD_BUTTON_INDEX_RECHARGE]:isVisible() then
			self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_RECHARGE]:getPositionX(), - 160)
		else
			self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_RECHARGE]:getPosition())
		end
	end

	--等级经验加成
	if self.m_buttons[AWARD_BUTTON_INDEX_EXP_ADDITION] then
		if self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:isVisible() then
			self.m_buttons[AWARD_BUTTON_INDEX_EXP_ADDITION]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:getPositionX(), self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:y() - 80)
		else
			self.m_buttons[AWARD_BUTTON_INDEX_EXP_ADDITION]:setPosition(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP]:getPosition())
		end
	end
end

function HomeActivityButtonView:onDayUpCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

	--如果是拇指广告
	if ServiceBO.muzhiAdPlat() and ActivityWeekMO.lvUpIsUse == false then
		Loading.getInstance():show()
		MuzhiADBO.GetDay7ActLvUpADStatus(function()
				Loading.getInstance():unshow()
				require("app.dialog.QuickUpLevelDialog").new(ActivityWeekMO.lvUpIsUse):push()
			end)
	else
		require("app.dialog.QuickUpLevelDialog").new(ActivityWeekMO.lvUpIsUse):push()
	end
	
end

function HomeActivityButtonView:onDay7Callback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.ActivityWeekView").new():push()
end

function HomeActivityButtonView:onSignCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.dialog.ActivityDaySign").new():push()
end

function HomeActivityButtonView:onActiveCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	TaskBO.asynNewGetLiveTask(function (data)
		Loading.getInstance():unshow()
		require("app.view.ActivityNewActiveView").new():push()
	end)
end

function HomeActivityButtonView:onFirstRechargeCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- local ActivityView = require("app.view.ActivityView")
	-- ActivityView.new():push()
	require("app.dialog.FirstPayDialog").new():push()
	
end

function HomeActivityButtonView:onLoginCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	if SignMO.dailyLogin_.display then
		-- local DailyLoginDialog = require("app.dialog.DailyLoginDialog")
		-- DailyLoginDialog.new():push()
		require("app.dialog.ActivityDaySign").new():push()
	else
		UiDirector.push(require("app.view.SignView").new())
	end
end

function HomeActivityButtonView:onActivityCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	UiDirector.push(require("app.view.ActivityCenterView").new())
	-- if #ActivityCenterMO.activityList_ > 0 then
	-- 	UiDirector.push(require("app.view.ActivityCenterView").new())
	-- else
	-- 	UiDirector.push(require("app.view.LotteryTreasureView").new())
	-- end
end

function HomeActivityButtonView:onDailyCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	-- 至少有一个兑换码
	if #ActivityMO.activityList_ == 0 then
		SocketWrapper.wrapSend(function(name,data)
				ActivityBO.update(data)
				if ActivityBO.isValid(ACTIVITY_ID_PARTY_LIVES) then --如果军团活跃活动开启了
					Loading.getInstance():show()
					ActivityBO.asynGetActivityContent(function ()
						Loading.getInstance():unshow()
						local ActivityView = require("app.view.ActivityView")
						ActivityView.new():push()
					end, ACTIVITY_ID_PARTY_LIVES)
				else
					local ActivityView = require("app.view.ActivityView")
					ActivityView.new():push()
				end
			end, NetRequest.new("GetActivityList"))
	else
		if ActivityBO.isValid(ACTIVITY_ID_PARTY_LIVES) then --如果军团活跃活动开启了
			Loading.getInstance():show()
			ActivityBO.asynGetActivityContent(function ()
				Loading.getInstance():unshow()
				local ActivityView = require("app.view.ActivityView")
				ActivityView.new():push()
			end, ACTIVITY_ID_PARTY_LIVES)
		else
			local ActivityView = require("app.view.ActivityView")
			ActivityView.new():push()
		end
	end
end

function HomeActivityButtonView:onDayPayCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	ActivityCenterBO.asynGetActEDayPay(function()
		Loading.getInstance():unshow()
		UiDirector.push(require("app.dialog.ActivityDayPayDialog").new())
		end)
end

function HomeActivityButtonView:onWelFareCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.WelFareView").new():push()
end

function HomeActivityButtonView:onExit()
	if self.timerHandler_ then
		ManagerTimer.removeTickListener(self.timerHandler_)
		self.timerHandler_ = nil
	end

	if self.m_signHandler then
		Notify.unregister(self.m_signHandler)
		self.m_signHandler = nil
	end

	if self.m_activityHandler then
		Notify.unregister(self.m_activityHandler)
		self.m_activityHandler = nil
	end

	if self.m_activityCenterHandler then
		Notify.unregister(self.m_activityCenterHandler)
		self.m_activityCenterHandler = nil
	end

	if self.m_partyTipHandler then
		Notify.unregister(self.m_partyTipHandler)
		self.m_partyTipHandler = nil
	end

	if self.m_dayPayHandler then
		Notify.unregister(self.m_dayPayHandler)
		self.m_dayPayHandler = nil
	end

	if self.m_taskliveHandler then
		Notify.unregister(self.m_taskliveHandler)
		self.m_taskliveHandler = nil
	end


	armature_remove("animation/effect/ui_btn_activity_first.pvr.ccz", "animation/effect/ui_btn_activity_first.plist", "animation/effect/ui_btn_activity_first.xml")
	armature_remove("animation/effect/ui_btn_activity_hot.pvr.ccz", "animation/effect/ui_btn_activity_hot.plist", "animation/effect/ui_btn_activity_hot.xml")
	armature_remove("animation/effect/ui_btn_activity_login.pvr.ccz", "animation/effect/ui_btn_activity_login.plist", "animation/effect/ui_btn_activity_login.xml")
	armature_remove("animation/effect/ui_btn_activity_daily.pvr.ccz", "animation/effect/ui_btn_activity_daily.plist", "animation/effect/ui_btn_activity_daily.xml")
	armature_remove("animation/effect/ui_btn_activity_daily_recharge.pvr.ccz", "animation/effect/ui_btn_activity_daily_recharge.plist", "animation/effect/ui_btn_activity_daily_recharge.xml")
end

function HomeActivityButtonView:updateTip()
	--登录奖励
	local count = 0
	if not SignMO.dailyLogin_.display then
		count = SignBO.getAwardCount()
		if count > 0 then
			UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_LOGIN], count, 50, 50)
		else
			UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_LOGIN])
		end
	end

	-- 日常
	local activityNum = 0
	local activityList = ActivityBO.getShowList()
	if ActivityMO.clickView_ then
		for index = 1, #activityList do
			local activity = activityList[index]
			activityNum = activityNum + ActivityBO.getUnReceiveNum(activity.activityId)
		end
	else
		activityNum = #activityList

		if ActivityBO.isPayFirstOpen() then  -- 如果首充开启，还得额外增加一个活动
			activityNum = activityNum + 1
		end
	end

	local function getLimitTipNum()
		local num = 0
		for index = 1, #ActivityCenterMO.activityLimitList_ do
			local activity = ActivityCenterMO.activityLimitList_[index]
			if activity.activity == ACTIVITY_ID_BOSS then
				if ActivityCenterMO.isBossOpen_ and UserMO.level_ >= ACTIVITY_BOSS_OPEN_LEVEL then -- 世界BOSS开启
					local status, cdTime = ActivityCenterBO.getBossStatus()
					if status == ACTIVITY_BOSS_STATE_READY or status == ACTIVITY_BOSS_STATE_FIGHTING then  -- 世界BOSS状态
						num = 1
					end
				end
			end
		end
		return num
	end

	--限时活动
	local activiteCount = #ActivityCenterMO.activityList_ + getLimitTipNum()
	if not ActivityCenterMO.showTip and activiteCount > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY], activiteCount, 50, 50)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_ACTIVITY])
	end

	-- 日常活动
	if activityNum > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_DAILY], activityNum, 50, 50)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_DAILY])
	end

	--军团tip
	if UserMO.partyTipAward_ and UserMO.partyTipAward_ == 1 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP], 1, 50, 50)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_PARTYTIP])
	end

	--每日充值
	if ActivityCenterMO.dayPayData.state and ActivityCenterMO.dayPayData.state == 1 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_DAYPAY], 1, 50, 50)
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_WEL_FARE], 1, 50, 50)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_DAYPAY])
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_WEL_FARE])
	end

	-- 活跃任务
	local lifeValue = TaskMO.getActivityCanrecive()
	if lifeValue > 0 then
		UiUtil.showTip(self.m_buttons[AWARD_BUTTON_INDEX_VITALITY], lifeValue, 50, 50)
	else
		UiUtil.unshowTip(self.m_buttons[AWARD_BUTTON_INDEX_VITALITY])
	end
end



function HomeActivityButtonView:onPowerAddCallback()
	Loading.getInstance():show()
	MuzhiADBO.GetAddPowerAD(function()
			Loading.getInstance():unshow()
			local ADPowerAddDialog = require_ex("app.dialog.ADPowerAddDialog")
			ADPowerAddDialog.new():push()
		end)
end

function HomeActivityButtonView:onExpAddCallback()
	Loading.getInstance():show()
	MuzhiADBO.GetExpAddStatus(function()
			Loading.getInstance():unshow()
			local ADExpAddDialog = require("app.dialog.ADExpAddDialog")
			ADExpAddDialog.new(1):push()
		end)
end


function HomeActivityButtonView:onStaffAddCallback()
	Loading.getInstance():show()
	MuzhiADBO.GetStaffingAddStatus(function()
			Loading.getInstance():unshow()
			local ADExpAddDialog = require("app.dialog.ADExpAddDialog")
			ADExpAddDialog.new(2):push()
		end)
end

return HomeActivityButtonView
