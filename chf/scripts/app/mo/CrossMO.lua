--
-- Author: Xiaohang
-- Date: 2016-09-22 11:02:54
--
CrossMO = {}
-- local LAST = 9 --持续9天
local LAST = 5 --持续9天
CrossMO.applyState = 2 --报名日
CrossMO.peakCondition = 35000000 --巅峰组报名要求
--时间状态
-- local STATE = {
-- 	[1] = {
-- 		[1] = {"00:00-23:59",1},
-- 	},
-- 	[2] = {
-- 		[1] = {"00:00-23:59",2},
-- 	},
-- 	[3] = {
-- 		[1] = {"00:00-11:59",3},
-- 		[2] = {"12:00-14:59",4},
-- 		[3] = {"14:59-20:59",5},
-- 		[4] = {"21:00-23:59",6},
-- 	},
-- 	[4] = {
-- 		[1] = {"00:00-11:59",6},
-- 		[2] = {"12:00-14:59",7},
-- 		[3] = {"15:00-20:59",8},
-- 		[4] = {"21:00-23:59",9},
-- 	},
-- 	[5] = {
-- 		[1] = {"00:00-11:59",9},
-- 		[2] = {"12:00-14:59",10},
-- 		[3] = {"15:00-20:59",11},
-- 		[4] = {"21:00-23:59",12},
-- 	},
-- 	[6] = {
-- 		[1] = {"00:00-19:59",12},
-- 		[2] = {"20:00-20:14",13},
-- 		[3] = {"20:15-20:59",14},
-- 		[4] = {"21:00-21:14",15},
-- 		[5] = {"21:15-23:59",16},
-- 	},
-- 	[7] = {
-- 		[1] = {"00:00-19:59",16},
-- 		[2] = {"20:00-20:14",17},
-- 		[3] = {"20:15-20:59",18},
-- 		[4] = {"21:00-21:14",19},
-- 		[5] = {"21:15-23:59",20},
-- 	},
-- 	[8] = {
-- 		[1] = {"00:00-19:59",20},
-- 		[2] = {"20:00-20:14",21},
-- 		[3] = {"20:15-20:59",22},
-- 		[4] = {"21:00-21:14",23},
-- 		[5] = {"21:15-23:59",24},
-- 	},
-- 	[9] = {
-- 		[1] = {"00:00-23:59",24},
-- 	},
-- 	[10] = {
-- 		[1] = {"00:00-23:59",24},
-- 	},
-- }

local STATE = {
	[1] = {
		[1] = {"00:00-23:59",1},
	},
	[2] = {
		[1] = {"00:00-23:59",2},
	},
	[3] = {
		[1] = {"00:00-11:59",3},
		[2] = {"12:00-12:29",4},
		[3] = {"12:30-12:59",5},
		[4] = {"13:00-15:59",6},
		[5] = {"16:00-16:29",7},
		[6] = {"16:30-16:59",8},
		[7] = {"17:00-19:59",9},
		[8] = {"20:00-20:29",10},
		[9] = {"20:30-20:59",11},
		[10] = {"21:00-23:59",12},
	},
	[4] = {
		[1] = {"00:00-11:59",12},
		[2] = {"12:00-12:29",13},
		[3] = {"12:30-15:29",14},
		[4] = {"15:30-15:59",15},
		[5] = {"16:00-18:59",16},
		[6] = {"19:00-19:29",17},
		[7] = {"19:30-22:29",18},
		[8] = {"22:30-22:59",19},
		[9] = {"23:00-23:59",20},
	},
	[5] = {
		[1] = {"00:00-11:59",20},
		[2] = {"12:00-12:14",21},
		[3] = {"12:15-19:59",22},
		[4] = {"20:00-20:14",23},
		[5] = {"20:15-23:59",24},
	},
	[6] = {
		[1] = {"00:00-23:59",24},
	},
}

local s_server_betting = require("app.data.s_server_war_betting")
local s_shop = require("app.data.s_server_war_shop")
local s_integral = require("app.data.s_sever_war_integral")
local d_server_betting = nil
local d_server_shop = nil
local d_integral = nil

function CrossMO.init()
	d_server_betting = {}
	local records = DataBase.query(s_server_betting)
	for index = 1, #records do
		local data = records[index]
		d_server_betting[data.bettingid] = data
	end

	d_server_shop = {}
	local records = DataBase.query(s_shop)
	for index = 1, #records do
		local data = records[index]
		if not d_server_shop[data.type] then
			d_server_shop[data.type] = {}
		end
		if not d_server_shop[data.type][data.treasure+1] then
			d_server_shop[data.type][data.treasure+1] = {}
		end
		table.insert(d_server_shop[data.type][data.treasure+1],data)
	end

	d_integral = {}
	local records = DataBase.query(s_integral)
	for index = 1, #records do
		local data = records[index]
		d_integral[data.trendId] = data
	end
end

function CrossMO.getBetById(id)
	return d_server_betting[id]
end

function CrossMO.getShop(kind,index)
	return d_server_shop[kind][index]
end

function CrossMO.getIntegralById(id)
	return d_integral[id]
end

--获取状态
function CrossMO.getState(state)
	if not STATE[state] then
		return CommonText[30021]
	else
		for k,v in ipairs(STATE[state]) do
			local temp = string.split(v[1],"-")
			local time1 = string.split(temp[1], ":")
			local time2 = string.split(temp[2], ":")
			local t = ManagerTimer.getTime()
			local h = tonumber(os.date("%H", t))
			local m = tonumber(os.date("%M", t))
			local s = tonumber(os.date("%S", t))
			local h1,m1 = tonumber(time1[1]),tonumber(time1[2])
			local h2,m2 = tonumber(time2[1]),tonumber(time2[2])
			gprint("time now==========",h1,m2,h,m,h2,m2)
			if  (h1*60+m1) <= (h*60+m) and (h*60+m) <= (h2*60+m2) then
				local endTime = t + (h2*60+m2-h*60-m)*60 + 60 - s
				if h2 == 23 and m2 == 59 and temp[1] ~= "00:00" then --处理隔天
					local next = STATE[state+1]
					if next then
						local nt = string.split(next[1][1],"-")
						if nt[1] == "00:00" then
							local nt2 = string.split(nt[2], ":")
							local nh2,nm2 = tonumber(nt2[1]),tonumber(nt2[2])
							endTime = endTime + nh2*3600+nm2*60
						end
					end
				end
				-- if CrossMO.inShopTime() then --最后2天积分商店是连续的
				-- 	endTime = endTime + 24*3600
				-- end
				return CommonText[30020][v[2]],endTime,k
			end
		end
	end
end

--获取时间点
function CrossMO.inShopTime()
	local y,m,d = CrossMO.getDateString()
	local time =  os.time({year=y,month=m,day=d,hour=0,min=0,sec=0})
	time = time + 4*24*3600
	local time1 = time + 20*3600 + 15 * 60
	local time2 = time + 2*24*3600
	return {time1,time2}
end

--服务器列表信息
function CrossMO.getServerList()
	if not CrossBO.serverList_ then
		return CommonText[509]
	else
		local str = ""
		for i=1,2 do
			if CrossBO.serverList_[i] then
				str = str .. CrossBO.serverList_[i].serverName
				str = str .. (i == 1 and "," or "...")
			end
		end
		return str
	end
end

function CrossMO.getDateString()
	local time = CrossBO.beginTime_
	time = string.split(time, " ")[1]
	time = string.split(time, "-")
	return tonumber(time[1]),tonumber(time[2]),tonumber(time[3])
end

--跨服战时间
function CrossMO.getTime()
	local y,m,d = CrossMO.getDateString()
	local time =  os.time({year=y,month=m,day=d})
	time = time + LAST*24*3600
	time = os.date("*t",time)
	return y.."/"..m .."/"..d .."-" ..time.year.."/"..time.month.."/"..time.day
end

--获取积分赛时间点
function CrossMO.getScroeTime()
	local y,m,d = CrossMO.getDateString()
	--第3天到第5天
	local str = ""
	-- local list = {3,5}
	local list = {3}
	for k,v in ipairs(list) do
		local time =  os.time({year=y,month=m,day=d})
		time = time + (v-1)*24*3600
		time = os.date("*t",time)
		str = str .. time.year.."/"..time.month.."/"..time.day
		if k == 1 and #list > 1 then
			str = str .. "-"
		end
	end
	return str
end

--获取淘汰赛时间点
function CrossMO.getOutTime(isFinal)
	local y,m,d = CrossMO.getDateString()
	-- local list = isFinal and {{7,5},{8,3}} or {{5,4},{6,3},{6,5},{7,3}}
	local list = isFinal and {{4,9},{5,3}} or {{3,10},{4,3},{4,5},{4,7}}
	local data = {}
	for k,v in ipairs(list) do
		local day,hour = v[1],STATE[v[1]][v[2]][1]
		local time =  os.time({year=y,month=m,day=d})
		time = time + (day-1)*24*3600
		time = os.date("*t",time)
		day = time.year.."/"..time.month.."/"..time.day .." "..string.split(hour,"-")[1]
		table.insert(data, day)
	end
	return data
end

--获取下注时状态
function CrossMO.getBetState()
	local y,m,d = CrossMO.getDateString()
	local a1 = {year=y,month=m,day=d}
	local a2 = os.date("*t",ManagerTimer.getTime())
	a2 = {year=a2.year,month=a2.month,day=a2.day}
	local day = (os.time(a2) - os.time(a1))/(3600*24) + 1
	local _,endTime,k = CrossMO.getState(day)
	--只在准备期才能下注
	if day == 3 then
		if k == 10 then return CommonText[30023][1],endTime end
	elseif day == 4 then
		if k == 1 then return CommonText[30023][1],endTime end
		if k == 3 then return CommonText[30023][2],endTime end
		if k == 5 then return CommonText[30023][3],endTime end
		if k == 7 then return CommonText[30023][4],endTime end
		if k == 9 then return CommonText[30024][1],endTime end
	elseif day == 5 then
		if k == 3 then return CommonText[30024][2],endTime end
	end
	-- if day == 5 then
	-- 	if k == 4 then return CommonText[30023][1],endTime end
	-- elseif day == 6 then
	-- 	if k == 1 then return CommonText[30023][1],endTime end
	-- 	if k == 3 then return CommonText[30023][2],endTime end
	-- 	if k == 5 then return CommonText[30023][3],endTime end
	-- elseif day == 7 then
	-- 	if k == 3 then return CommonText[30023][4],endTime end
	-- 	if k == 4 then return CommonText[30024][1],endTime end
	-- elseif day == 8 then
	-- 	if k == 3 then return CommonText[30024][2],endTime end
	-- end
end

--是否可下注
function CrossMO.cantState()
	gprint("canState =========",CrossBO.state_,tonumber(os.date("%H", ManagerTimer.getTime())))
	if CrossBO.state_ == 3 then
		local h = tonumber(os.date("%H", ManagerTimer.getTime()))
		if h >= 21 then
			return true
		end
	elseif CrossBO.state_ > 3 then
		return true
	end
	return false
	-- if CrossBO.state_ == 5 then
	-- 	local h = tonumber(os.date("%H", ManagerTimer.getTime()))
	-- 	if h >= 21 then
	-- 		return true
	-- 	end
	-- elseif CrossBO.state_ > 5 then
	-- 	return true
	-- end
end

--商店是否开启
function CrossMO.canShop()
	if CrossBO.state_ == 5 then
		local t = ManagerTimer.getTime()
		local h = tonumber(os.date("%H", t))
		local m = tonumber(os.date("%M", t))
		if (h*60+m) >= (20*60+15) then
			return true
		end
	elseif CrossBO.state_ > 5 then
		return true
	end
	-- if CrossBO.state_ == 8 then
	-- 	local t = ManagerTimer.getTime()
	-- 	local h = tonumber(os.date("%H", t))
	-- 	local m = tonumber(os.date("%M", t))
	-- 	if (h*60+m) >= (21*60+15) then
	-- 		return true
	-- 	end
	-- elseif CrossBO.state_ > 8 then
	-- 	return true
	-- end
end

function CrossMO.goToView(index,kind)
	if not CrossMO.isOpen_ then
		Toast.show(CommonText[30049])
		return
	end
	if not CrossBO.state_ then
		CrossBO.getState(function()
				require("app.view.CrossView").new(nil,index,kind):push()
			end)
	else
		require("app.view.CrossView").new(nil,index,kind):push()
	end
end