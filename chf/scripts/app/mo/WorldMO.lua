
-- 世界MO

local s_mine = require("app.data.s_mine")
local s_mine_lv = require("app.data.s_mine_lv")
local s_scout = require("app.data.s_scout")
local s_mine_quality = require("app.data.s_mine_quality")
local s_world_mine = require("app.data.s_world_mine")
local s_world_mine_speed = require("app.data.s_world_mine_speed")

local db_mine_ = nil
local db_mine_lv_ = nil
local db_scout_ = nil
local db_mine_quality_ = nil
local db_world_mine_ = nil
local db_world_mine_speed_ = nil

local db_environment_ = {
[16] = {1, 1}, -- 树木的第一个形态
[51] = {2, 3}, -- 花的第三个形态
[79] = {1, 1},
[95] = {1, 3},
[114] = {1, 1},
[129] = {2, 1},
[152] = {1, 3},
[162] = {1, 3},
[174] = {1, 1},
[189] = {2, 2},
[217] = {1, 2},
[225] = {1, 2},
[247] = {1, 1},
[258] = {1, 2},
[275] = {2, 2},
[302] = {1, 1},
[315] = {1, 3},
[331] = {2, 2},
[358] = {1, 2},
[378] = {1, 1},
[394] = {1, 3},
[414] = {2, 2},
[433] = {1, 2},
[449] = {2, 3},
[472] = {1, 2},
[493] = {1, 1},
[516] = {2, 3},
[565] = {1, 1},
[580] = {2, 1},
[602] = {2, 2},
[605] = {2, 1},
[627] = {1, 2},
[657] = {2, 2},
[670] = {2, 1},
[678] = {2, 3},
[706] = {2, 2},
[733] = {2, 3},
[749] = {2, 1},
[761] = {2, 1},
[778] = {1, 1},
[782] = {1, 2},
[806] = {2, 1},
[831] = {2, 3},
[855] = {2, 1},
[880] = {1, 1},
[901] = {2, 3},
[917] = {2, 1},
[927] = {1, 2},
[937] = {2, 2},
[951] = {2, 3},
[967] = {2, 1},
[973] = {1, 2},
[990] = {2, 1},
[1009] = {1, 3},
[1016] = {1, 1},
[1033] = {2, 1},
[1037] = {1, 3},
[1058] = {2, 1},
[1085] = {2, 3},
[1115] = {2, 2},
[1134] = {1, 2},
[1159] = {1, 3},
[1176] = {2, 3},
[1186] = {1, 1},
[1202] = {1, 3},
[1212] = {2, 1},
[1229] = {2, 2},
[1239] = {1, 2},
[1254] = {2, 3},
[1271] = {2, 1},
[1282] = {1, 3},
[1292] = {2, 2},
[1320] = {1, 3},
[1328] = {2, 2},
[1346] = {1, 3},
[1365] = {2, 2},
[1382] = {2, 3},
[1406] = {1, 2},
[1422] = {2, 1},
[1438] = {1, 2},
[1457] = {1, 1},
[1468] = {2, 3},
[1479] = {1, 3},
[1501] = {2, 2},
[1512] = {1, 2},
[1528] = {1, 3},
[1548] = {1, 1},
[1570] = {1, 2},
[1581] = {2, 2},
[1592] = {1, 3},
}

WorldMO = {}

WORLD_SIZE_WIDTH = 600
WORLD_SIZE_HEIGHT = 600

MINE_SIZE_WIDTH = 40
MINE_SIZE_HEIGHT = 40

MINE_OFFSET_SEED = 13

HOME_MOVE_TAKE_COIN = 88

WORLD_TILE_WIDTH = 320
WORLD_TILE_HEIGHT = 160


SCOUT_MAX = 1000   ---侦查次数

WorldMO.pos_ = cc.p(0, 0) -- 玩家在世界的坐标

WorldMO.currentPos_ = nil  -- 玩家预览到的当前坐标

WorldMO.getMapHandler_ = nil -- 用于获得GetMap协议的数据的句柄

WorldMO.mapData_ = {}  -- 每个坐标的数据
WorldMO.partyMine_ = {}  -- 同一个军团的矿资源数据
WorldMO.mine_ = {}  -- 坐标矿点信息
WorldMO.warFree_ = {}  -- 免战信息

WorldMO.areaIndex_ = {}  -- 标记是否从服务器请求某个区块的地图数据，如果请求过，则不再请求数据

WorldMO.curAttackPos_ = cc.p(0, 0)  -- 当前攻击的目标的坐标

WorldMO.curGuardPos_ = cc.p(0, 0)  -- 当前驻军目标的坐标

WorldMO.clearMapData_ = false

WorldMO.worldMineExp = 0

WorldMO.worldMineLevel = 0

WorldMO.synWorldStaffingHandler_ = nil

function WorldMO.init()
	db_mine_ = {}
	local records = DataBase.query(s_mine)
	for index = 1, #records do
		local data = records[index]
		db_mine_[data.pos] = data
	end

	db_mine_lv_ = {}
	local records = DataBase.query(s_mine_lv)
	for index = 1, #records do
		local data = records[index]
		if db_mine_lv_[data.type] == nil then
			db_mine_lv_[data.type] = {}
		end
		db_mine_lv_[data.type][data.lv] = data
	end

	db_scout_ = {}
	local records = DataBase.query(s_scout)
	for index = 1, #records do
		local data = records[index]
		db_scout_[data.lv] = data
	end

	db_mine_quality_ = {}
	local records = DataBase.query(s_mine_quality)
	for index = 1, #records do
		local data = records[index]
		if not db_mine_quality_[data.quality] then
			db_mine_quality_[data.quality] = {}
		end
		db_mine_quality_[data.quality][data.mineLv] = data
	end

	db_world_mine_ = {}
	local records = DataBase.query(s_world_mine)
	for index = 1, #records do
		local data = records[index]
		db_world_mine_[data.lv] = data
	end

	db_world_mine_speed_ = {}
	local records = DataBase.query(s_world_mine_speed)
	for index = 1, #records do
		local data = records[index]
		db_world_mine_speed_[data.id] = data
	end
end

function WorldMO.queryMineByPos(pos)
	local mineData = clone(db_mine_[pos])
	if mineData then
		mineData.lv = mineData.lv + WorldMO.worldMineLevel * 2
		if mineData.lv > 80 then
			mineData.lv = 80
		end
		return mineData
	end
end

function WorldMO.queryMineQuality(quality,level)
	return db_mine_quality_[quality][level or 2]
end

function WorldMO.queryMineLvByLv(lv, type)
	return db_mine_lv_[type][lv]
end

function WorldMO.queryEnvironmentByPos(pos)
	return db_environment_[pos]
end

function WorldMO.queryScout(lv,heroData)
	local scoutCost = db_scout_[lv].scoutCost
	--*叛军类型
	if heroData and heroData.heroPick ~= -2 then
		local hd = RebelMO.queryHeroById(heroData.heroPick)
		scoutCost = scoutCost * hd.teamType
	end
	-- if scout > SCOUT_MAX then
	-- 	scoutCost = scoutCost + scoutCost * math.pow(scout - SCOUT_MAX, 5)
	-- end
	-- 表里的值*（（侦查方等级-被侦查方等级）*等级差系数+1）*梯度系数；
	-- 侦查方等级-被侦查方等级小于0时取0。
	local lvEx = lv - UserMO.level_ < 0 and 0 or lv - UserMO.level_
	local graded = UiUtil.getGradedPrice(json.decode(UserMO.querySystemId(29)),UserMO.scout_,1)
	scoutCost = scoutCost*(lvEx*(UserMO.querySystemId(28)/10000) + 1) * (graded/10000)
	scoutCost = math.ceil(scoutCost)
	local mulit = graded > 10000 and string.format("%.1f", graded/10000) or nil
	return {lv=lv, scoutCost=scoutCost, mulit = mulit}
end

function WorldMO.updatePos(pos)
	if pos == -1 then
		WorldMO.pos_ = cc.p(-599, -599)
	else
		WorldMO.pos_ = WorldMO.decodePosition(pos)
		-- print("rePos=============================")
		-- print("pos", pos)
		-- print("x:", WorldMO.pos_.x, "y:", WorldMO.pos_.y)
	end

	if not WorldMO.currentPos_ then
		WorldMO.currentPos_ = cc.p(WorldMO.pos_.x, WorldMO.pos_.y)
	end
end

function WorldMO.setCurrentPosition(x, y)
	WorldMO.currentPos_.x = x
	WorldMO.currentPos_.y = y
end

-- 需要判断是否是废墟
function WorldMO.isRuin(pros, prosMax, ruins)
	if pros == prosMax or pros >= 600 then
		--手动重置下数据
		if ruins then
			ruins.isRuins = false
		end
		return false
	end
	if ruins then
		return ruins.isRuins
	else
		if UserMO.ruins then
			return UserMO.ruins.isRuins
		else
			if prosMax < 600 then if pros == 0 then return true end
			else if pros < 600 then return true end end
		end
	end
end

-- 返回0表示废墟
function WorldMO.getBuildLevelByProps(pros, prosMax, ruins)
	if WorldMO.isRuin(pros, prosMax, ruins) then return 0 end

	local level = UserBO.getProsperousLevel(prosMax)
	return UserMO.queryProsperousByLevel(level).icon
end

function WorldMO.getMapDataAt(x, y)
	if not WorldMO.mapData_[x] then return nil end
	return WorldMO.mapData_[x][y]
end

function WorldMO.setMapDataAt(x, y, mapData)
	if not WorldMO.mapData_[x] then WorldMO.mapData_[x] = {} end
	WorldMO.mapData_[x][y] = mapData
end

function WorldMO.setPartyMineAt(x, y, partyMine)
	if not WorldMO.partyMine_[x] then WorldMO.partyMine_[x] = {} end
	WorldMO.partyMine_[x][y] = partyMine
end

function WorldMO.getPartyMineAt(x, y)
	if not WorldMO.partyMine_[x] then return nil end
	return WorldMO.partyMine_[x][y]
end

function WorldMO.setMineAt(x, y, mine)
	if not WorldMO.mine_[x] then WorldMO.mine_[x] = {} end
	WorldMO.mine_[x][y] = mine
end

function WorldMO.getMineAt(x, y)
	if not WorldMO.mine_[x] then return nil end
	return WorldMO.mine_[x][y]
end

function WorldMO.getWarFreeInfo(x, y)
	-- body
	local areaIndex = WorldMO.getAreaInex({x=x, y=y})
	if WorldMO.warFree_[areaIndex] == nil then return nil end
	if WorldMO.warFree_[areaIndex][x] == nil then return nil end
	return WorldMO.warFree_[areaIndex][x][y]
end

function WorldMO.setWarFreeInfo(x, y, free)
	-- body
	local areaIndex = WorldMO.getAreaInex({x=x, y=y})
	if WorldMO.warFree_[areaIndex] == nil then
		WorldMO.warFree_[areaIndex] = {}
	end
	if WorldMO.warFree_[areaIndex][x] == nil then
		WorldMO.warFree_[areaIndex][x] = {}
	end
	WorldMO.warFree_[areaIndex][x][y] = free
end

-- -- 删除位置(x,y)的mapData数据
-- function WorldMO.removeMapDataAt(x, y)
-- end

function WorldMO.encodePosition(x, y)
	return x + WORLD_SIZE_WIDTH * y
end

function WorldMO.decodePosition(pos)
	pos = pos or 0
	local x = pos % WORLD_SIZE_WIDTH
	local y = math.floor(pos / WORLD_SIZE_WIDTH)
	return cc.p(x, y)
end

function WorldMO.getAreaInex(pos)
	local x = math.floor(pos.x / 15)
	local y = math.floor(pos.y / 15)
	local area = x + y * 40
	return area
end

--矿点品质功能是否开启
function WorldMO.ifOpen()
	local temp = UserMO.querySystemId(27)
	temp = json.decode(temp)
	if #temp > 0 then
		for k,v in ipairs(temp) do
			if v == GameConfig.areaId then
				return true
			end
		end
		return false
	else
		return true
	end
end

function WorldMO.queryWorldMineLevelByExp(worldExp)
	-- body
	if worldExp < 0 then
		return 0
	end

	local maxLevel = WorldMO.queryWorldMineMaxLevel()
	local level = 0
	while true do
		local minExp = db_world_mine_[level].worldExp
		local maxExp = db_world_mine_[level+1].worldExp
		if worldExp >= minExp and worldExp < maxExp then
			return level
		end

		level = level + 1
		if level == maxLevel then
			return level
		end
	end
end


function WorldMO.queryWorldMineExpByLevel(level)
	-- body
	return db_world_mine_[level].worldExp
end


function WorldMO.queryWorldMineDeclineByLevel(level)
	-- body
	return db_world_mine_[level].decline / 1000
end

function WorldMO.queryWorldMineMaxLevel()
	-- body
	local maxLevel = 0
	for k, v in pairs(db_world_mine_) do
		if v.lv > maxLevel then
			maxLevel = v.lv
		end
	end
	return maxLevel
end


function WorldMO.queryWorldMineSpeedUpByDayExp(dayExp)
	-- body
	if dayExp < 0 then
		return 0
	end
	for k, v in pairs(db_world_mine_speed_) do
		if dayExp >= v.capBegin and dayExp <= v.capEnd then
			local su = ((v.a / 10000000000) * dayExp + (v.b / 1000)) * 100
			return su
		end
	end
end
