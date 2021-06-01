--
-- Author: xiaoxing
-- Date: 2017-04-15 15:09:52
--
AirshipMO = {}

local s_airship = require("app.data.s_airship")
local db_airship_ = nil

local CACHE_TIME = 120
function AirshipMO.init()
	db_airship_ = {}
	local records = DataBase.query(s_airship)
	for index = 1, #records do
		local data = records[index]
		db_airship_[data.pos] = data
	end

	local function refresh()
		AirshipBO.needUpdate_ = true
	end
	if not AirshipMO.refreshHandler_ then
		AirshipMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, CACHE_TIME)
	end
end

function AirshipMO.isInScope(tilePos)
	if not UserMO.queryFuncOpen(UFP_AIRSHIP) then return nil end 
	for k,v in pairs(db_airship_) do
		local pos = WorldMO.decodePosition(k)
		if tilePos.x >= pos.x and tilePos.y >= pos.y and 
			tilePos.x <= pos.x + 1 and tilePos.y <= pos.y + 1 then
			return k
		end
	end
	return nil
end

function AirshipMO.queryShip(pos)
	if not pos then
		return table.values(db_airship_)
	end
	return db_airship_[pos]
end

function AirshipMO.queryShipById(id)
	for k,v in pairs(db_airship_) do
		if v.id == id then
			return v
		end
	end
end

-----飞艇重建 系数，跟世界等级相关
function AirshipMO.queryRebuildFactor( worldLv )
	worldLv = worldLv or 0
	local factor = (math.pow(worldLv, 2) + 1)*(math.sqrt(worldLv) + 1)
	return factor
end


