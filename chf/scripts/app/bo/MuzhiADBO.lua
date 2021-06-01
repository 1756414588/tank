
-- 拇指广告

MuzhiADBO = {}


--拉取7日活动秒升级 的广告 观看状态
function MuzhiADBO.GetDay7ActLvUpADStatus(doneCallback)
	-- MuzhiADMO.Day7ActLvUpADStatus = 0
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetDay7ActLvUpADStatus")
		MuzhiADMO.Day7ActLvUpADStatus = data.status 
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetDay7ActLvUpADStatus"))
end

--观看7日活动秒升1级 权限广告
function MuzhiADBO.PlayDay7ActLvUpAD(doneCallback)
	--测试数据
	-- MuzhiADMO.Day7ActLvUpADStatus = 1
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		MuzhiADMO.Day7ActLvUpADStatus = 1
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayDay7ActLvUpAD"))
end

--拉取登录观看广告活动状态
function MuzhiADBO.GetLoginADStatus(doneCallback)
	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetLoginADStatus")
		MuzhiADMO.LoginADStatus = data.playStatus
		MuzhiADMO.LoginADAwards = PbProtocol.decodeArray(data["award"])
		gdump(MuzhiADMO.LoginADAwards,"MuzhiADMO.LoginADAwards")
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetLoginADStatus"))
end

--观看登录广告
function MuzhiADBO.PlayLoginAD(doneCallback)
	-- MuzhiADMO.LoginADStatus = 1
	-- if doneCallback then doneCallback() end
	-- do return end
	local function parseResult(name, data)
		MuzhiADMO.LoginADStatus = 1
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayLoginAD"))
end


--拉取首充奖励 观看广告 天数和当天次数  playDays 为-1 表明活动未开启
function MuzhiADBO.GetFirstGiftADStatus(doneCallback)
	-- MuzhiADMO.FirstGiftADDay = 1
	-- MuzhiADMO.FirstGiftADTime = 2
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetFirstGiftADStatus")
		MuzhiADMO.FirstGiftADDay = data.playDays
		MuzhiADMO.FirstGiftADTime = data.playTimes
		if MuzhiADMO.FirstGiftADTime > MZAD_FIRSTGIFT_TIME then
			MuzhiADMO.FirstGiftADTime = MZAD_FIRSTGIFT_TIME
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetFirstGiftADStatus"))
end


--观看首充奖励广告
function MuzhiADBO.PlayFirstGiftAD(doneCallback)
	-- MuzhiADMO.FirstGiftADDay = 5
	-- MuzhiADMO.FirstGiftADTime = 5
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.PlayFirstGiftAD")
		MuzhiADMO.FirstGiftADTime = data.playTimes
		MuzhiADMO.FirstGiftADDay = data.playDays
		if MuzhiADMO.FirstGiftADTime > MZAD_FIRSTGIFT_TIME then
			MuzhiADMO.FirstGiftADTime = MZAD_FIRSTGIFT_TIME
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayFirstGiftAD"))
end

function MuzhiADBO.AwardFirstGiftAD(doneCallback)

	local function parseResult(name, data)
		UserMO.topup_ = data.topUp
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("AwardFirstGiftAD"))
end


function MuzhiADBO.GetExpAddStatus(doneCallback)
	-- MuzhiADMO.ExpAddADTime = 1
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetExpAddStatus")
		MuzhiADMO.ExpAddADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetExpAddStatus"))
end

function MuzhiADBO.PlayExpAddAD(doneCallback)
	-- MuzhiADMO.ExpAddADTime = 2
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		MuzhiADMO.ExpAddADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayExpAddAD"))
end


function MuzhiADBO.GetStaffingAddStatus(doneCallback)
	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetStaffingAddStatus")
		MuzhiADMO.StaffingAddADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetStaffingAddStatus"))
end

function MuzhiADBO.PlayStaffingAddAD(doneCallback)
	-- MuzhiADMO.StaffingAddADTime = 3
	-- if doneCallback then doneCallback() end
	-- do return end

	local function parseResult(name, data)
		MuzhiADMO.StaffingAddADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayStaffingAddAD"))
end


function MuzhiADBO.PlayAddPowerAD(doneCallback)

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.PlayAddPowerAD")
		MuzhiADMO.AddPowerADTime = data.playTimes
		--领取次数已达上限
		if MuzhiADMO.AddPowerADTime > MZAD_ADD_POWER_MAX then
			Toast.show(CommonText.MuzhiAD[4][3]) 
		else
			if table.isexist(data, "award") then
				local awards = PbProtocol.decodeArray(data["award"])
				 --加入背包
				local ret = CombatBO.addAwards(awards)
				UiUtil.showAwards(ret)
			end
		end
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayAddPowerAD"))
end

function MuzhiADBO.PlayAddCommandAD(doneCallback)

	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.PlayAddCommandAD")
		MuzhiADMO.AddCommandADTime = data.playTimes

		if MuzhiADMO.AddCommandADTime > MZAD_ADD_COMMAND_MAX then
			Toast.show(CommonText.MuzhiAD[4][3]) 
		else
			if table.isexist(data, "award") then
				local awards = PbProtocol.decodeArray(data["award"])
				 --加入背包
				local ret = CombatBO.addAwards(awards)
				UiUtil.showAwards(ret)
			end
		end
		
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("PlayAddCommandAD"))
end

function MuzhiADBO.GetAddPowerAD(doneCallback)
	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetAddPowerAD")
		MuzhiADMO.AddPowerADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetAddPowerAD"))
end


function MuzhiADBO.GetAddCommandAD(doneCallback)
	local function parseResult(name, data)
		gdump(data,"MuzhiADBO.GetAddCommandAD")
		MuzhiADMO.AddCommandADTime = data.playTimes
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetAddCommandAD"))
end