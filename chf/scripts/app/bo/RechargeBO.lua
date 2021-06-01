--
-- Author: gf
-- Date: 2015-11-04 11:05:52
-- 充值


RechargeBO = {}

function RechargeBO.parseSynGold(name, data)
	-- gdump(data,"RechargeBO.parseSynGold")
	local awards = {
		{kind = ITEM_KIND_COIN, count = data.addGold},
		{kind = ITEM_KIND_TOPUP, count = data.addTopup}
	}

  	local RechargeAwardsView = require("app.view.RechargeAwardsView")
	RechargeAwardsView.show(awards)

	--判断是否是首充
	if UserMO.topup_ == 0 then
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		ConfirmDialog.new(CommonText[759], function()
			require("app.view.MailView").new(4):push()
		end):push()
	end

	UserMO.addUpgradeResouce(ITEM_KIND_TOPUP, data.addTopup)


	local newVip = data.vip

	if newVip > UserMO.vip_ then end --vip升级

	UserMO.vip_ = newVip
	
	UserMO.updateResource(ITEM_KIND_COIN, data.gold)

	Notify.notify(LOCAL_RECHARGE_UPDATE_EVENT)

	--TK统计 充值到账
	TKGameBO.onPay(GameConfig.keyId,data.serialId,data.addTopup * 10,"CNY",0,data.addGold)
	

	if ActivityBO.isValid(ACTIVITY_ID_PAY_RED_GIFT) then
		ActivityBO.trigger(ACTIVITY_ID_PAY_RED_GIFT, data.addTopup)
	end
	if ActivityBO.isValid(ACTIVITY_ID_PAY_EVERYDAY) then
		ActivityBO.trigger(ACTIVITY_ID_PAY_EVERYDAY, data.addTopup)
	end
	local ids = {ACTIVITY_ID_CONTU_PAY, ACTIVITY_ID_PAY_FOUR}  -- 连续充值
	for index = 1, #ids do
		local id = ids[index]
		if ActivityBO.isValid(id) then
			local activityContent = ActivityMO.getActivityContentById(id)
			if activityContent and activityContent.conditions and activityContent.conditions[1]
				and activityContent.conditions[1].param and type(activityContent.conditions[1].param) == "string" and (json.decode(activityContent.conditions[1].param) <= data.addTopup) then
				ActivityBO.asynGetActivityContent(nil, id)
			end
		end
	end
	if ActivityBO.isValid(ACTIVITY_ID_DAY_PAY) then -- 天天充值
		ActivityBO.trigger(ACTIVITY_ID_DAY_PAY, data.addTopup)
	end
	if ActivityBO.isValid(ACTIVITY_ID_FIRST_REBATE) then  -- 首充返利
		ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_FIRST_REBATE)
	end
	if ActivityBO.isValid(ACTIVITY_ID_RECHARGE_GIFT) then
		ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_RECHARGE_GIFT)
	end
	if ActivityBO.isValid(ACTIVITY_ID_CON_RECHARGE_GIFT) then
		ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_CON_RECHARGE_GIFT)
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_AMY_REBATE) then --节日返利
		ActivityCenterBO.asynGetActivityContent(nil, ACTIVITY_ID_AMY_REBATE, 2)
	end
	if ActivityBO.isValid(ACTIVITY_ID_CONTU_PAY_NEW) then -- 天天充值
		ActivityBO.asynGetActivityContent(nil, ACTIVITY_ID_CONTU_PAY_NEW)
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_FESTIVAL) then -- 节日狂欢
		ActivityCenterMO.activityContents_[ACTIVITY_ID_FESTIVAL] = {}
		Notify.notify("FESTIVAL_PAY")
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_RECHARGE) then -- 充值返利(返利我做主)
		Notify.notify("ACTIVITY_ID_RECHARGE_UPDATA_UI")
	end
	if ActivityCenterMO.isCheckActivityNewenergy() then	-- 能量灌注
		ActivityCenterMO.ActivityEnergyOfdata.updateui = true
		if ActivityCenterMO.isCheckActivityNewenergy(1) then
			Notify.notify("ACTIVITY_NOTIFY_NEWENERGY")
		end
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_OWNGIFT) then -- 自选豪礼
		Notify.notify("ACTIVITY_NOTIFY_OWNGIFT")
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_LUCKYROUND) then -- 幸运奖池
		Notify.notify("ACTIVITY_LUCKY_ROUND_ROMATE_UPDATE")
	end
	if ActivityCenterBO.isValid(ACTIVITY_ID_SECRETARMY) then
		Notify.notify(LOCAL_RECHARGE_UPDATE)
	end
	--每日充值
	ActivityCenterBO.asynGetActEDayPay(function()
		Notify.notify(LOCAL_DAYPAY_UPDATE_EVENT)
		end)
end


function RechargeBO.init()
	-- if device.platform == "android" or device.platform == "windows" then
	-- 	RechargeMO.rechargeList = RechargeMO.getRechargeByPlatform(RECHARGE_PLATFORM_ANDROID)
	-- else
	-- 	RechargeMO.rechargeList = RechargeMO.getRechargeByPlatform(RECHARGE_PLATFORM_IOS)
	-- end
	--充值挡
	RechargeMO.rechargeList = RechargeMO.getRechargeByPlatform()

	--根据渠道判断兑换比例和币种 海外版需要增加判断
	
	--兑换比例
	GAME_PAY_RATE = 10
	GAME_PAY_CURRENCYTYPE = "CNY"
end

function RechargeBO.rechargeCallBack(payResult)
	local result = payResult
	if result == RECHARGE_RESULT_CANCEL then 
		--取消支付
	elseif result == RECHARGE_RESULT_SUCCESS then
		--支付成功
	elseif result == RECHARGE_RESULT_FAIL then
		--支付失败
	end	
end



function RechargeBO.getCurrencyType()
	if GAME_PAY_CURRENCYTYPE == "CNY" then
		return CommonText[738]
	end
	return GAME_PAY_CURRENCYTYPE
end



---触发专属客服
local personal_state = "personal_state"

function RechargeBO.getVipServState()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. personal_state .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    local data = nil
    if io.exists(path) then
        data = io.readfile(path)
    end
    return data
end


--保存引导阶段
function RechargeBO.saveVipServState()
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. personal_state .. "_" .. UserMO.lordId_ .. "_" .. GameConfig.areaId
    io.writefile(path, "1", "w+b")
end

-- 获取充值状态
function RechargeBO.getActNewPayInfo(doneCallback)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "getActNewPayInfo recieve data==")
		local info = PbProtocol.decodeArray(data.info)
		for i, v in ipairs(info) do
			RechargeMO.setRechargeState(v.v1, v.v2)
		end
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetActNewPayInfo", {}))
end


function RechargeBO.getActNew2PayInfo(doneCallback)
	-- body
	local function getResult(name, data)
		Loading.getInstance():unshow()
		gdump(data, "getActNew2PayInfo recieve data==")
		local info = PbProtocol.decodeArray(data.info)
		for i, v in ipairs(info) do
			RechargeMO.setRechargeNewState(v.v1, v.v2)
		end
		if doneCallback then doneCallback() end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetActNew2PayInfo", {}))
end

function RechargeBO.openRechargeView()
	-- body
	if ActivityBO.isActCashbackOpen() then
		RechargeBO.getActNewPayInfo(function ()
			-- body
			require("app.view.RechargeView").new(1):push()
		end)
	elseif ActivityBO.isActCashbackNewOpen() then
		RechargeBO.getActNew2PayInfo(function ()
			-- body
			require("app.view.RechargeView").new(2):push()
		end)
	else
		require("app.view.RechargeView").new():push()
	end
end

function RechargeBO.SyncActNewPayInfo(name, data)
	-- body
	local info = PbProtocol.decodeArray(data.info)
	for i, v in ipairs(info) do
		RechargeMO.setRechargeState(v.v1, v.v2)
	end
	Notify.notify(LOCAL_RECHARGE_UPDATE_EVENT, {})
end


function RechargeBO.SyncActNew2PayInfo(name, data)
	-- body
	local info = PbProtocol.decodeArray(data.info)
	for i, v in ipairs(info) do
		RechargeMO.setRechargeNewState(v.v1, v.v2)
	end
	Notify.notify(LOCAL_RECHARGE_UPDATE_EVENT, {})
end
