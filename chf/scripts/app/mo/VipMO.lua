--
-- Author: gf
-- Date: 2015-09-24 15:25:31
--

local s_vip = require("app.data.s_vip")

VipMO = {}


local db_vip_ 

function VipMO.init()
	if not db_vip_ then
		db_vip_ = {}
		local records = DataBase.query(s_vip)
		for index = 1, #records do
			local data = records[index]
			--vip存在0的情况
			db_vip_[data.vip + 1] = data
		end
	end
end

function VipMO.queryVip(vip)
	--vip存在0的情况
	if not db_vip_[vip + 1] then return nil end
	return db_vip_[vip + 1]
end

function VipMO.queryMaxVip()
	return #db_vip_ - 1
end

--根据累充金币获得VIP等级
function VipMO.getVipByTopup(topup_)
	if topup_ < 0 then return 0 end

	local maxTopup = db_vip_[#db_vip_].topup
	if topup_ >= maxTopup then return VipMO.queryMaxVip() end

	for index=1,#db_vip_ do
		local vipdb = db_vip_[index]
		if topup_ < vipdb.topup then return db_vip_[index-1].vip end
	end
end