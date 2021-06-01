
--local s_officialPosition = require("app.data.s_officialPosition")
local s_military_rank = require("app.data.s_military_rank")
local db_s_military_rank_ = nil --军衔表

MilitaryRankMO = {}

MilitaryRankMO.militaryMax = 61

function MilitaryRankMO.init()
	db_s_military_rank_ = {}
	local records = DataBase.query(s_military_rank)
	for index = 1, #records do
		local data = records[index]
		db_s_military_rank_[data.id] = data
	end
end

-- 根据军衔id 获取军衔信息
function MilitaryRankMO.queryById(id)
	if not db_s_military_rank_[id] then return nil end
	return db_s_military_rank_[id]
end

-- 
function MilitaryRankMO.couldLevelUp(lv)
	-- 已达最高级
	if lv > MilitaryRankMO.militaryMax then 
		Toast.show(CommonText[1016][2])
		return true
	end
	
	local data = MilitaryRankMO.queryById(lv)
	local targetdata = json.decode(data.upCost)
	for index=1 , #targetdata do
		local data = targetdata[index]
		local kind , id , limit =  data[1], data[2], data[3]
		local name = UserMO.getResourceData(kind,id).name
		local cur = UserMO.getResource(kind,id)
		if cur < limit then
			Toast.show(string.format(CommonText[1016][1],name))
			return true
		end
	end
	return false
end

function MilitaryRankMO.useResource(lv)
	-- 已达最高级
	if lv > MilitaryRankMO.militaryMax then return end

	local data = MilitaryRankMO.queryById(lv)
	local targetdata = json.decode(data.upCost)
	for index=1 , #targetdata do
		local data = targetdata[index]
		local kind , id , limit =  data[1], data[2], data[3]
		if kind ~= ITEM_KIND_MILITARY_EXPLOIT then
			local reduce = { {kind = kind , id = id , count = limit} }
			UserMO.reduceResources(reduce)
		end
	end
end

function MilitaryRankMO.getAttrByLv(lv)
	local data = MilitaryRankMO.queryById(lv)
	local effectdata = json.decode(data.attrs)
end

function MilitaryRankMO.getMilitrayRankName(lv)
	if not lv then return nil end
	if lv == 0 then
		return CommonText[985]
	end
	local rankdata = MilitaryRankMO.queryById(lv)
	return rankdata.name
end