--
-- Author: Your Name
-- Date: 2017-06-16 15:19:56
--
local s_back_package = require("app.data.s_backone")
local s_back_buff = require("app.data.s_backbuff")
local s_back_rebate= require("app.data.s_backmoney")


PlayerBackMO = {}
PlayerBackMO.isBack_ =  false
PlayerBackMO.backPackage_ = nil --礼包信息
PlayerBackMO.backTime_ = nil

local db_pack_ = nil
local db_buff_ = nil
local db_rebate_ = nil

function PlayerBackMO.init()
	db_pack_ = nil
	db_buff_ = nil
	db_rebate_ = nil

	--礼包
	if not db_pack_ then
		db_pack_ = {}
		local records = DataBase.query(s_back_package)
		for index = 1, #records do
			local awards = records[index]
			if not db_pack_[awards.backtime] then db_pack_[awards.backtime] = {}	end
				db_pack_[awards.backtime][awards.day] = awards
		end
	end
	--buff
	if not db_buff_ then
		db_buff_ = {}
		local records = DataBase.query(s_back_buff)
		for index = 1, #records do
			local awards = records[index]
			if not db_buff_[awards.backtime] then db_buff_[awards.backtime] = {}	end
				db_buff_[awards.backtime][awards.day] = awards
		end
	end
	--返利
	if not db_rebate_ then
		db_rebate_ = {}
		local records = DataBase.query(s_back_rebate)
		for index = 1, #records do
			local data = records[index]
			db_rebate_[data.backTime] = data
		end
	end

end

--根据backtime索取礼包列表
function PlayerBackMO.getBackPackByBackTime(backTime)
	local pack = db_pack_[backTime] or {}
	-- return table.getn(pack)
	return pack
end

--根据backtime获取buff列表
function PlayerBackMO.getBackBuffByTime(backTime)
	local buff = db_buff_[backTime] or {}
	return buff
end

--根据backtime获取返利列表
function PlayerBackMO.getBackRebateByTime(backTime)
	local rebate = db_rebate_[backTime] or {}
	return rebate
end