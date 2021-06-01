
HunterMO = {}

local s_bounty_stage = require("app.data.s_bounty_stage")
local s_bounty_boss = require("app.data.s_bounty_boss")
local s_bounty_shop = require("app.data.s_bounty_shop")
local s_bounty_wanted = require("app.data.s_bounty_wanted")
local s_bounty_skill = require("app.data.s_bounty_skill")
local s_bounty_config = require("app.data.s_bounty_config")
local s_bounty_enemy = require("app.data.s_bounty_enemy")
local db_bounty_stage_ = nil
local db_bounty_boss_ = nil
local db_bounty_shop_ = nil
local db_bounty_wanted_ = nil
local db_bounty_skill_ = nil
local db_bounty_config_ = nil
local db_bounty_enemy_ = nil
local stage_count = 0
local wanted_count = 0

HunterMO.synTeamInfoHandler_ = nil
HunterMO.synNotifyDismissTeamHandler_ = nil
HunterMO.synNotifyKickOutHandler_ = nil
HunterMO.synChangeStatusHandler_ = nil
HunterMO.synTeamOrderHandler_ = nil
HunterMO.synTeamChatHandler_ = nil
HunterMO.synStageCloseToTeamHandler_ = nil
HunterMO.synTeamFightBossHandler_ = nil
HunterMO.curBountyBossId = nil

HunterMO.combatConfirm = false
HunterMO.curTeamFightBossData_ = nil
HunterMO.teamFightCrossData_ = {}

HunterMO.allBattleStatistics_ = {}

function HunterMO.init()
	db_bounty_stage_ = {}
	local records = DataBase.query(s_bounty_stage)
	stage_count = #records
	for index = 1, stage_count do
		local data = records[index]
		db_bounty_stage_[data.id] = data
	end

	db_bounty_boss_ = {}
	local records1 = DataBase.query(s_bounty_boss)
	for index = 1, #records1 do
		local data = records1[index]
		db_bounty_boss_[data.id] = data
	end

	db_bounty_shop_ = {}
	local records2 = DataBase.query(s_bounty_shop)
	for index = 1, #records2 do
		local data = records2[index]
		if db_bounty_shop_[data.openWeek%4] == nil then
			db_bounty_shop_[data.openWeek%4] = {}
		end
		table.insert(db_bounty_shop_[data.openWeek%4], data)
	end

	db_bounty_wanted_ = {}
	local records3 = DataBase.query(s_bounty_wanted)
	wanted_count = #records3
	for index = 1, wanted_count do
		local data = records3[index]
		db_bounty_wanted_[data.id] = data
	end

	db_bounty_skill_ = {}
	local records4 = DataBase.query(s_bounty_skill)
	for index = 1, #records4 do
		local data = records4[index]
		db_bounty_skill_[data.id] = data
	end

	db_bounty_config_ = {}
	local records5 = DataBase.query(s_bounty_config)
	for index = 1, #records5 do
		local data = records5[index]
		db_bounty_config_[data.id] = data
	end

	db_bounty_enemy_ = {}
	local records6 = DataBase.query(s_bounty_enemy)
	for index = 1, #records6 do
		local data = records6[index]
		db_bounty_enemy_[data.id] = data
	end
end


function HunterMO.queryStageById(stageId)
	-- body
	return db_bounty_stage_[stageId]
end


function HunterMO.getStageCount()
	-- body
	return stage_count
end


function HunterMO.getOpenTimeShow(openTimeStr)
	-- body
	local temp1 = json.decode(openTimeStr)
	local str = ""
	for i = 1, #temp1 do
		local d = tonumber(temp1[i])
		if i ~= #temp1 then
			str = str .. string.format("%d、", d)
		else
			str = str .. string.format("%d", d)
		end
	end
	return string.format(CommonText[345][10], str)
end


function HunterMO.queryBossById(bossId)
	-- body
	return db_bounty_boss_[bossId]
end


function HunterMO.queryShopByWeek(week)
	return db_bounty_shop_[week%4]
end


function HunterMO.getBountyWantedArray()
	-- body
	local array = {}
	for k, v in pairs(db_bounty_wanted_) do
		table.insert(array, v)
	end
	table.sort(array, function (a, b)
		return a.id < b.id
	end)
	return array
end




function HunterMO.getBountyWantedArrayOpen(refOpenStage)
	-- body
	local array = {}

	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	if week == 0 then week = 7 end

	for k, v in pairs(db_bounty_wanted_) do
		local openDay = json.decode(v.openDay)
		local todayOpen = false
		for i = 1, #openDay do
			local d = tonumber(openDay[i])
			if week == d then
				todayOpen = true
				break
			end
		end

		if todayOpen then
			local openTimeStr = v.openTime
			local temp = string.sub(openTimeStr, 2, #openTimeStr-1)
			local frags = string.split(temp, ",")
			for i1, v1 in ipairs(frags) do
				local stage = {}
				local chunks = string.split(v1, "-")
				local startStr = chunks[1]
				local subchunks = string.split(startStr, ":")
				local startHour = tonumber(subchunks[1])
				local startMin = tonumber(subchunks[2])
				stage['start']={startHour, startMin}

				local endStr = chunks[2]
				local subchunks1 = string.split(endStr, ":")
				local endHour = tonumber(subchunks1[1])
				local endMin = tonumber(subchunks1[2])
				stage['end']={endHour, endMin}

				local startSame = (refOpenStage['start'][1] == stage['start'][1] and refOpenStage['start'][2] == stage['start'][2])
				local endSame = (refOpenStage['end'][1] == stage['end'][1] and refOpenStage['end'][2] == stage['end'][2])
				-- 如果开始时间和结束时间相同，那么这个通缉就是这个时段开放的
				if startSame and endSame then
					table.insert(array, v)
					break
				end
			end
		end
	end
	table.sort(array, function (a, b)
		return a.id < b.id
	end)
	return array
end

function HunterMO.getBountyWantedOpenTimeStages()
	-- body
	local openStages = {}
	for k, v in pairs(db_bounty_wanted_) do
		local openTimeStr = v.openTime
		local temp = string.sub(openTimeStr, 2, #openTimeStr-1)
		local frags = string.split(temp, ",")
		for i1, v1 in ipairs(frags) do
			local stage = {}
			local chunks = string.split(v1, "-")
			local startStr = chunks[1]
			local subchunks = string.split(startStr, ":")
			local startHour = tonumber(subchunks[1])
			local startMin = tonumber(subchunks[2])
			stage['start']={startHour, startMin}

			local endStr = chunks[2]
			local subchunks1 = string.split(endStr, ":")
			local endHour = tonumber(subchunks1[1])
			local endMin = tonumber(subchunks1[2])
			stage['end']={endHour, endMin}

			if #openStages == 0 then
				table.insert(openStages, stage)
			else
				local same = false
				for i2, v2 in ipairs(openStages) do
					local startSame = (v2['start'][1] == stage['start'][1] and v2['start'][2] == stage['start'][2])
					local endSame = (v2['end'][1] == stage['end'][1] and v2['end'][2] == stage['end'][2])
					if startSame and endSame then
						same = true
						break
					else
					end
				end
				if same == false then
					table.insert(openStages, stage)
				end
			end
		end
	end
	table.sort(openStages, function (a, b) 
		if a['start'][1] < b['start'][1] then
			return true
		elseif a['start'][1] == b['start'][1] then
			return a['start'][2] < b['start'][2]
		else
			return false
		end
	end)
	return openStages
end


function HunterMO.getBountyWantedOpenTimeStagesByTaskId(taskId)
	-- body
	local openStages = {}
	for k, v in pairs(db_bounty_wanted_) do
		if k == taskId then
			local openTimeStr = v.openTime
			local temp = string.sub(openTimeStr, 2, #openTimeStr-1)
			local frags = string.split(temp, ",")
			for i1, v1 in ipairs(frags) do
				local stage = {}
				local chunks = string.split(v1, "-")
				local startStr = chunks[1]
				local subchunks = string.split(startStr, ":")
				local startHour = tonumber(subchunks[1])
				local startMin = tonumber(subchunks[2])
				stage['start']={startHour, startMin}

				local endStr = chunks[2]
				local subchunks1 = string.split(endStr, ":")
				local endHour = tonumber(subchunks1[1])
				local endMin = tonumber(subchunks1[2])
				stage['end']={endHour, endMin}

				if #openStages == 0 then
					table.insert(openStages, stage)
				else
					local same = false
					for i2, v2 in ipairs(openStages) do
						local startSame = (v2['start'][1] == stage['start'][1] and v2['start'][2] == stage['start'][2])
						local endSame = (v2['end'][1] == stage['end'][1] and v2['end'][2] == stage['end'][2])
						if startSame and endSame then
							same = true
							break
						else
						end
					end
					if same == false then
						table.insert(openStages, stage)
					end
				end
			end
			break
		end
	end
	table.sort(openStages, function (a, b) 
		if a['start'][1] < b['start'][1] then
			return true
		elseif a['start'][1] == b['start'][1] then
			return a['start'][2] < b['start'][2]
		else
			return false
		end
	end)
	return openStages
end


function HunterMO.getBountyWantedCount()
	-- body
	return wanted_count
end


function HunterMO.getRailGunChargeRound()
	-- body
	local paramJsonStr = db_bounty_skill_[1].param
	local paramJson = json.decode(paramJsonStr)
	return paramJson[1][1]
end

function HunterMO.getBountySkillById(skillId)
	-- body
	return db_bounty_skill_[skillId]
end


function HunterMO.getBountyCoinGainedMax()
	-- body
	return db_bounty_config_[1].count1
end


function HunterMO.getBountyBenefitOffPercent()
	-- body
	return db_bounty_config_[1].percent
end


function HunterMO.queryBountyEnemyById( enemyId )
	-- body
	return db_bounty_enemy_[enemyId]
end