--
-- Author: xiaoxing
-- Date: 2016-12-21 19:15:02
--
MedalMO = {}

MedalMO.level_ = 70 --开启等级
MEDAL_ID_ALL_PIECE      = 1101 -- 万能碎片(这是碎片，kind=ITEM_KIND_CHIP)

local s_medal = require("app.data.s_medal")
local s_medal_matrial = require("app.data.s_medal_matrial")
local s_medal_up = require("app.data.s_medal_up")
local s_medal_refit = require("app.data.s_medal_refit")
local s_medal_bouns = require("app.data.s_medal_bouns")

local d_medal = {}
local d_medal_up = {}
local d_medal_refit = {}
local d_medal_matrial = {}
local d_medal_bouns = {}
 
local SORT = 
{
	show = function(a,b)
			if MedalBO.shows[a.medalId] == 1 then
				if MedalBO.shows[b.medalId] == 1 then
					return 0
				else
					return true
				end
			elseif MedalBO.shows[b.medalId] == 1 then
				return false
			else
				return 0
			end
		end,
	lock = function(a,b)
			if MedalBO.shows[a.medalId] == 0 then
				if MedalBO.shows[b.medalId] == 0 then
					return 0
				else
					return true
				end
			elseif MedalBO.shows[b.medalId] == 0 then
				return false
			else
				return 0
			end
		end,
	id = function(a,b)
			if a.medalId==b.medalId then
				return 0
			else
	 			return a.medalId < b.medalId
	 		end
		end,
}

function MedalMO.init()
	local records = DataBase.query(s_medal)
	for index = 1, #records do
		local data = records[index]
		d_medal[data.medalId] = data
	end
	local records = DataBase.query(s_medal_matrial)
	for index = 1, #records do
		local data = records[index]
		d_medal_matrial[data.id] = data
	end

	local records = DataBase.query(s_medal_up)
	for index = 1, #records do
		local data = records[index]
		if not d_medal_up[data.quality] then d_medal_up[data.quality] = {} end
		d_medal_up[data.quality][data.lv] = data
	end

	local records = DataBase.query(s_medal_refit)
	for index = 1, #records do
		local data = records[index]
		if not d_medal_refit[data.quality] then d_medal_refit[data.quality] = {} end
		d_medal_refit[data.quality][data.lv] = data
	end

	local records = DataBase.query(s_medal_bouns)
	for index = 1, #records do
		local data = records[index]
		d_medal_bouns[data.id] = data
	end
end

function MedalMO.queryBouns()
	return d_medal_bouns
end

function MedalMO.queryUp(quality, partLv)
	return d_medal_up[quality][partLv]
end

function MedalMO.queryUpMaxLevel(quality)
	if not d_medal_up[quality] then return 0 end
	return #d_medal_up[quality]
end

function MedalMO.queryRefit(quality, partLv)
	if not d_medal_refit[quality] then return nil end
	return d_medal_refit[quality][partLv]
end

function MedalMO.queryRefitMaxLevel(quality)
	if not d_medal_refit[quality] then return 0 end
	return #d_medal_refit[quality]
	-- return #db_part_refit_[quality]
end

function MedalMO.queryById(id)
	return d_medal[id]
end

function MedalMO.queryPropById(id)
	return d_medal_matrial[id]
end

function MedalMO.getShowMedal(qualitys)
	local medals = {}
	if not qualitys then
		local num = 0
		for k,v in pairs(d_medal) do
			if v.position ~= 11 then
				num = num + 1
			end
		end
		return num
	end
	for k,v in pairs(d_medal) do
		if qualitys[v.quality] and v.position ~= 11 then
			table.insert(medals, v)
		end
	end
	local order = {"show","lock","id"}
	table.bubble(medals, function(a,b)
		for k,v in ipairs(order) do
			local r = SORT[v](a,b)
			if r ~= 0 then
				return r
			end
		end
		return false
	end)
	return medals
end

--获取每个位置
function MedalMO.getPosMedal(pos)
	pos = pos or 0
	local medals = {}
	for k,v in pairs(MedalBO.medals) do
		if v.pos == pos then
			local md = MedalMO.queryById(v.medalId)
			if not medals[md.position] then
				medals[md.position] = {}
			end
			table.insert(medals[md.position], v)
		end
	end
	return medals
end

function MedalMO.sortMedal(a,b)
	local total1,total2 = MedalBO.getPartAttrData(nil, nil, a),MedalBO.getPartAttrData(nil, nil, b)
	return total1.strengthValue > total2.strengthValue
end

function MedalMO.getFreeMedals()
	local medals = {}
	for k,v in pairs(MedalBO.medals) do
		if v.pos == 0 then
			table.insert(medals, v)
		end
	end
	return medals
end

function MedalMO.getAllChips()
	local chips = {}
	for k,v in pairs(MedalBO.chips) do
		if v > 0 then
			table.insert(chips, {chipId=k,count = v})
		end
	end
	return chips
end

function MedalMO.getResolve(keyId)
	local medal = MedalBO.medals[keyId]
	local md = MedalMO.queryById(medal.medalId)
	local ret = {}
	local upt = MedalMO.queryUp(md.quality, medal.upLv)
	local refitt = MedalMO.queryRefit(md.quality, medal.refitLv)
	local temp = {upt.explode,refitt.explode}
	for m,n in pairs(temp) do
		for k,v in ipairs(json.decode(n)) do
			local key = v[1].."_"..v[2]
			if not ret[key] then
				ret[key] = {type = v[1],id = v[2],count = v[3]}
			else
				ret[key].count = ret[key].count + v[3]
			end
		end
	end
	temp = {}
	for k,v in pairs(ret) do
		table.insert(temp, v)
	end
	return temp
end

function MedalMO.getResolveChip(id)
	local md = MedalMO.queryById(id)
	if md.chipCount == 0 then
		return
	end
	local refitt = MedalMO.queryRefit(md.quality, 0)
	local temp = json.decode(refitt.explode)[1]
	temp = {type = temp[1],id = temp[2],count = math.floor(temp[3]/md.explodeChipCount)}
	return temp
end

function MedalMO.getAllShowMedals(isShow)
	local num = 0
	local isShow = isShow or false
	--可展示的
	local all = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0}
	local data = MedalMO.getShowMedal(all) --全部
	local medals = {}

	for k,v in ipairs(data) do
		for m,n in pairs(MedalBO.medals) do
			if n.pos == 0 and n.medalId == v.medalId and n.locked == false and MedalBO.shows[v.medalId] == 0 then
				if not medals[v.medalId] then
					medals[v.medalId] = {}
				end
				table.insert(medals[v.medalId],n)
			end
		end
	end

	for key,medal in pairs(medals) do
		if #medal > 0 then
			num = num + 1
		end
	end

	if isShow then --只是可展示的勋章
		return num
	end
	--可穿戴的
	local equips = MedalMO.getPosMedal(1)
	local unequips = MedalMO.getPosMedal(0)
	local LvLock = json.decode(UserMO.querySystemId(18))
	
 	for index=1,10 do
 		local has = MedalBO.checkListUpMedalsAtPos(equips[index], unequips[index])
 		if has and UserMO.level_ >= LvLock[index][2] then
 			num = num + 1
 		end
 	end

	return num
end

--获取所有装配的勋章的等级总和
function MedalMO.getAllPosedMedalLv()
	local data = MedalMO.getPosMedal(1)
	local lv = 0
	for k,v in pairs(data) do
		local record = v[1]
		lv = lv + record.upLv
	end

	return lv
end

--获取所有装配的勋章的打磨等级总和
function MedalMO.getAllPosedMedalFRefitLv()
	local data = MedalMO.getPosMedal(1)
	local lv = 0
	for k,v in pairs(data) do
		local record = v[1]
		lv = lv + record.refitLv
	end

	return lv
end