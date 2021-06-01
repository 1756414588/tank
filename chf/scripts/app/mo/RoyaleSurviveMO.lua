--
-- Author: heyunlong
-- Date: 2018-07-18 14:22
--

RoyaleSurviveMO = {}

local s_honour_live_system = require("app.data.s_honour_live_system")
local s_honour_live = require("app.data.s_honour_live")
local s_honour_score_gold = require("app.data.s_honour_score_gold")

local db_honour_live_system_ = nil
local db_honour_live_ = nil
local db_honour_score_gold_ = nil

RoyaleSurviveMO.synHonourSurviveOpenHandler_ = nil
RoyaleSurviveMO.synUpdateSafeAreaHandler_ = nil
RoyaleSurviveMO.synNextSafeAreaHandler_ = nil

RoyaleSurviveMO.safeAreaRightUpCorner = nil --{x=500, y=500}
RoyaleSurviveMO.safeAreaLeftBottomCorner = nil --{x=100, y=100}

RoyaleSurviveMO.nextSafeAreaRightUpCorner = nil --{x=400, y=400}
RoyaleSurviveMO.nextSafeAreaLeftBottomCorner = nil --{x=200, y=200}

-- 总圈数
RoyaleSurviveMO.totalPhase = 0
RoyaleSurviveMO.curPhase = 0
RoyaleSurviveMO.shrinkStartTime = 0 -- 1533141265
RoyaleSurviveMO.shrinkEndTime = 0 -- 1533161265
RoyaleSurviveMO.tipOpenFlag = false
RoyaleSurviveMO.poisonPos = nil
RoyaleSurviveMO.shrinkAllOver = false
RoyaleSurviveMO.isActOver = false

RoyaleSurviveMO.AREA_POISON = 0
RoyaleSurviveMO.AREA_SAFE_CORNER_B = 1
RoyaleSurviveMO.AREA_SAFE_CORNER_R = 2
RoyaleSurviveMO.AREA_SAFE_CORNER_T = 3
RoyaleSurviveMO.AREA_SAFE_CORNER_L = 4
RoyaleSurviveMO.AREA_SAFE_BORDER_1 = 5
RoyaleSurviveMO.AREA_SAFE_BORDER_2 = 6
RoyaleSurviveMO.AREA_SAFE_BORDER1_1 = 7
RoyaleSurviveMO.AREA_SAFE_BORDER1_2 = 8
RoyaleSurviveMO.AREA_SAFE_INNER = 9
RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_B = 10
RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_R = 11
RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_T = 12
RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_L = 13
RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_1 = 14
RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_2 = 15
RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_1 = 16
RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_2 = 17


function RoyaleSurviveMO.init()
	db_honour_live_system_ = {}
	local records = DataBase.query(s_honour_live_system)
	for index = 1, #records do
		local data = records[index]
		db_honour_live_system_[data.id] = data
	end

	local stageTimeStr = db_honour_live_system_[5].value
	local stageTimeData = json.decode(stageTimeStr)
	RoyaleSurviveMO.totalPhase = #stageTimeData

	db_honour_live_ = {}
	local records = DataBase.query(s_honour_live)
	for index = 1, #records do
		local data = records[index]
		if db_honour_live_[data.type] == nil then
			db_honour_live_[data.type] = {}
		end
		db_honour_live_[data.type][data.phase] = data
	end

	db_honour_score_gold_ = {}
	local records = DataBase.query(s_honour_score_gold)
	for index = 1, #records do
		local data = records[index]
		db_honour_score_gold_[data.id] = data
	end

	RoyaleSurviveMO.preMinimapData()
end


function RoyaleSurviveMO.getRankScoreForOnList(tp)
	-- body
	if tp == 1 then
		return db_honour_live_system_[7].value
	elseif tp == 2 then
		return db_honour_live_system_[8].value
	end
end


function RoyaleSurviveMO.getBuffAttrShow(buff, phase)
	-- body
	return db_honour_live_[buff][phase].attr
end

function RoyaleSurviveMO.getScoreGoldById(id)
	if not id then return db_honour_score_gold_ end
	if not db_honour_score_gold_[id] then
		return nil
	end
	return db_honour_score_gold_[id]
end

function RoyaleSurviveMO.getForeverTankLoss(phase)
	-- body
	return db_honour_live_[-1][phase].deathtank
end


function RoyaleSurviveMO.isActOpen()
	-- body
	if RoyaleSurviveMO.safeAreaRightUpCorner == nil or
		RoyaleSurviveMO.safeAreaLeftBottomCorner == nil then
		return false
	else
		return true
	end
end


function RoyaleSurviveMO.isDuringLastCircleStage()
	-- body
	if RoyaleSurviveMO.curPhase > 0 then
		return RoyaleSurviveMO.curPhase == RoyaleSurviveMO.totalPhase
	end
	return false
end


function RoyaleSurviveMO.IsInSafeArea(tilePos)
	-- body
	if not RoyaleSurviveMO.isActOpen() then
		return true
	end

	local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
	local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

	local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
	local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

	if tilePos.x >= xbegin and tilePos.x <= xend and
		tilePos.y >= ybegin and tilePos.y <= yend then
		return true
	else
		return false
	end
end


function RoyaleSurviveMO.IsInNextSafeArea(tilePos)
	-- body
	if not RoyaleSurviveMO.isActOpen() then
		return false
	end

	local xbegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
	local xend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

	local ybegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
	local yend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y

	if tilePos.x >= xbegin and tilePos.x <= xend and
		tilePos.y >= ybegin and tilePos.y <= yend then
		return true
	else
		return false
	end
end


function RoyaleSurviveMO.GetAreaType(tilePos)
	-- body
	if not RoyaleSurviveMO.isActOpen() then
		return RoyaleSurviveMO.AREA_SAFE_INNER
	end
	if RoyaleSurviveMO.IsInSafeArea(tilePos) then
		local xbegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.x
		local xend = RoyaleSurviveMO.safeAreaRightUpCorner.x

		local ybegin = RoyaleSurviveMO.safeAreaLeftBottomCorner.y
		local yend = RoyaleSurviveMO.safeAreaRightUpCorner.y

		local n_xbegin = nil
		local n_xend = nil
		local n_ybegin = nil
		local n_yend = nil
		if RoyaleSurviveMO.nextSafeAreaLeftBottomCorner and RoyaleSurviveMO.nextSafeAreaRightUpCorner then
			n_xbegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.x
			n_xend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.x

			n_ybegin = RoyaleSurviveMO.nextSafeAreaLeftBottomCorner.y
			n_yend = RoyaleSurviveMO.nextSafeAreaRightUpCorner.y
		end

		if (tilePos.x == xbegin or tilePos.x == xend) and (tilePos.y == ybegin or tilePos.y == yend) then
			if tilePos.x == xbegin and tilePos.y == ybegin then
				return RoyaleSurviveMO.AREA_SAFE_CORNER_B
			elseif tilePos.x == xbegin and tilePos.y == yend then
				return RoyaleSurviveMO.AREA_SAFE_CORNER_L
			elseif tilePos.x == xend and tilePos.y == ybegin then
				return RoyaleSurviveMO.AREA_SAFE_CORNER_R
			else
				return RoyaleSurviveMO.AREA_SAFE_CORNER_T
			end
		elseif (tilePos.y == ybegin or tilePos.y == yend) and (tilePos.x > xbegin and tilePos.x < xend) then
			if tilePos.y == ybegin then
				return RoyaleSurviveMO.AREA_SAFE_BORDER1_1
			else
				return RoyaleSurviveMO.AREA_SAFE_BORDER1_2
			end
		elseif (tilePos.x == xbegin or tilePos.x == xend) and (tilePos.y > ybegin and tilePos.y < yend) then
			if tilePos.x == xbegin then
				return RoyaleSurviveMO.AREA_SAFE_BORDER_1
			else
				return RoyaleSurviveMO.AREA_SAFE_BORDER_2
			end
		else
			if n_xbegin and n_xend and n_ybegin and n_yend then
				if (tilePos.x == n_xbegin or tilePos.x == n_xend) and (tilePos.y == n_ybegin or tilePos.y == n_yend) then
					if tilePos.x == n_xbegin and tilePos.y == n_ybegin then
						return RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_B
					elseif tilePos.x == n_xbegin and tilePos.y == n_yend then
						return RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_L
					elseif tilePos.x == n_xend and tilePos.y == n_ybegin then
						return RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_R
					else
						return RoyaleSurviveMO.AREA_NEXT_SAFE_CORNER_T
					end
				elseif (tilePos.y == n_ybegin or tilePos.y == n_yend) and (tilePos.x > n_xbegin and tilePos.x < n_xend) then
					if tilePos.y == n_ybegin then
						return RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_1
					else
						return RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER1_2
					end
				elseif (tilePos.x == n_xbegin or tilePos.x == n_xend) and (tilePos.y > n_ybegin and tilePos.y < n_yend) then
					if tilePos.x == n_xbegin then
						return RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_1
					else
						return RoyaleSurviveMO.AREA_NEXT_SAFE_BORDER_2
					end
				else
					return RoyaleSurviveMO.AREA_SAFE_INNER
				end
			else
				return RoyaleSurviveMO.AREA_SAFE_INNER
			end
		end
	else
		return RoyaleSurviveMO.AREA_POISON
	end
end


function RoyaleSurviveMO.preMinimapData()
	-- body
	local MINIMAP_SIZE = 12
	RoyaleSurviveMO.poisonPos = {}
	local unitAreaSize = WORLD_SIZE_WIDTH / MINIMAP_SIZE
	for i = 1, MINIMAP_SIZE do
		RoyaleSurviveMO.poisonPos[i] = {}
		for j = 1, MINIMAP_SIZE do
			local midx, midy = RoyaleSurviveMO.checkAreaPoison(i, j, unitAreaSize)
			local p = {}
			p.pos_ = {x=midx, y=midy}
			local tx, ty = RoyaleSurviveMO.posToMiniPos(midx, midy)
			p.miniPos = {x=tx, y=ty}
			RoyaleSurviveMO.poisonPos[i][j] = p
		end
	end
end


function RoyaleSurviveMO.checkAreaPoison(mx, my, areaSize)
	-- body
	local minx = 1 + (mx - 1) * areaSize
	local maxx = mx * areaSize
	local miny = 1 + (my - 1) * areaSize
	local maxy = my * areaSize
	local midx = math.floor((minx + maxx)*0.5)
	local midy = math.floor((miny + maxy)*0.5)
	return midx, midy
end


function RoyaleSurviveMO.posToMiniPos(x,y)
	--先转成v字型坐标
	local minimapH = 244
	local minimapW = 502
	local l = math.sqrt(minimapH*minimapH + minimapW*minimapW)/2
	local rate = WORLD_SIZE_WIDTH/l
	local r = math.deg(math.atan2(minimapH, minimapW))
	local tx = math.cos(math.rad(r))*(x/rate - y/rate) + minimapW/2
	local ty = math.sin(math.rad(r))*(x/rate + y/rate)
	return tx,ty
end
