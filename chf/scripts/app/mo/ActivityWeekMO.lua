--七天活动
local db_act_week = nil
local s_act_week = require("app.data.s_day_7_act")

ActivityWeekMO = {}
ActivityWeekMO.synDay7ActTipsHandler_ = nil

--七日活动相关

function ActivityWeekMO.init()
	db_act_week = {}
	local records = DataBase.query(s_act_week)
	for index = 1, #records do
		local data = records[index]
		db_act_week[data.keyId] = data
	end

	ActivityWeekMO.synDay7ActTipsHandler_ = nil
	
	-- ActivityWeekBO.refTime()
end

function ActivityWeekMO.getAllWeekActivity()
	return db_act_week
end

function ActivityWeekMO.getAllWeekActivityById(id)
	return db_act_week[id]
end

function ActivityWeekMO.getOneDataByDay(index)
	local ret = {}
	for i=1,#db_act_week do
		if index == db_act_week[i].day and db_act_week[i].type <= 14  then
			table.insert(ret,db_act_week[i])
		end
	end	
	return ret
end

function ActivityWeekMO.getFirstTabData(index)
	local ret = {}
	for k,v in pairs(db_act_week) do
		if index == v.day and v.type > 14 and v.type < 18 then
			table.insert(ret,v)
		end
	end
	local sortFun = function(a,b)
		if a.keyId == b.keyId then
			return false
		else
			return a.keyId < b.keyId
		end
	end
	table.sort(ret,sortFun)
	return ret
end

function ActivityWeekMO.getFourTabData(index)
	local ret = {}
	for k,v in pairs(db_act_week) do
		if index == v.day and  v.type == 18 then
			table.insert(ret,v)
		end
	end
	local sortFun = function(a,b)
		if a.keyId == b.keyId then
			return false
		else
			return a.keyId < b.keyId
		end
	end
	table.sort(ret,sortFun)
	return ret
end


function ActivityWeekMO.getTwoTabData(index)
	local ret = {}
	for k,v in pairs(db_act_week) do
		if index == v.day and v.type <= 14 and v.type%2 == 1 then
			table.insert(ret,v)
		end
	end	
	local sortFun = function(a,b)
		if a.keyId == b.keyId then
			return false
		else
			return a.keyId < b.keyId
		end
	end
	table.sort(ret,sortFun)
	return ret
end

function ActivityWeekMO.getThreeTabData(index)
	local ret = {}
	for k,v in pairs(db_act_week) do
		if index == v.day and v.type <= 14 and v.type%2 == 0 then
			table.insert(ret,v)
		end
	end	
	local sortFun = function(a,b)
		if a.keyId == b.keyId then
			return false
		else
			return a.keyId < b.keyId
		end
	end
	table.sort(ret,sortFun)
	return ret
end

--排序
function ActivityWeekMO.sortWeekData(_needData,_ret)
	local weekData = _needData
	local reqData = _ret

	local ret = {}
	for i=1,#weekData do
		for k,v in pairs(reqData) do
			if weekData[i].keyId == v.keyId then
				weekData[i].Tag = v.recved
			end
		end
	end
	local sortFun = function(a,b)
		if a.Tag == b.Tag then
			if a.keyId == b.keyId then
				return false
			else
				if a.gotoUi == 35 then
					return a.keyId > b.keyId
				else
					return a.keyId < b.keyId
				end
			end
		else
			return a.Tag < b.Tag
		end
	end
	table.sort(weekData, sortFun )

	return weekData 
end


--推送小红点。更新
function ActivityWeekMO.parseSynDay7ActTips(name, data)
	ActivityWeekBO.refTime()
end
