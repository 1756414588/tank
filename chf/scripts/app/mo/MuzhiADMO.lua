--
-- Author: gf
-- Date: 2017-05-24 10:15:55
-- 拇指广告

MuzhiADMO = {}

--广告类型
MZAD_TYPE_BANNER = 1;
MZAD_TYPE_FULLSCREEN = 2;
MZAD_TYPE_VIDEO = 3;

--登录观看广告活动状态 0未观看 1已观看
MuzhiADMO.LoginADStatus = 1
MuzhiADMO.LoginADAwards = {
}

--秒升1级领取权限 广告观看状态 1 已观看 0 未观看
MuzhiADMO.Day7ActLvUpADStatus = 0

--首充奖励观看广告天数
MuzhiADMO.FirstGiftADDay = 0
--首充奖励观看广告当天次数
MuzhiADMO.FirstGiftADTime = 0


--经验加速活动 广告观看次数
MuzhiADMO.ExpAddADTime = 0
--编制加速活动 广告观看次数
MuzhiADMO.StaffingAddADTime = 0


--角色经验值 倍数
MZAD_EXPADD_TIME = 5
--编制经验值 倍数
MZAD_STAFFADD_TIME = 5
--倍率
MZAD_EXPADD_FACTOR = 0.4

MZAD_FIRSTGIFT_DAY = 7
MZAD_FIRSTGIFT_TIME = 5


--观看广告增加体力 次数
MuzhiADMO.AddPowerADTime = 0
--观看广告增加统率书 次数
MuzhiADMO.AddCommandADTime = 0

MZAD_ADD_POWER_MAX = 5
MZAD_ADD_COMMAND_MAX = 2

function MuzhiADMO.get24HourCD()
	local cd = ""
	local time = ManagerTimer.getDate()
	local min_,sec_
	-- if time.min == 0 then
	-- 	min_ = 59
	-- else
		min_ = 59 - time.min
	-- end
	-- if time.sec == 0 then
	-- 	sec_ = 0
	-- else
		sec_ = 59 - time.sec
	-- end

	cd = string.format("%02d:%02d:%02d",  23 - time.hour, min_, sec_)
	return cd
end