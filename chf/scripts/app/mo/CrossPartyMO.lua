--
-- Author: Xiaohang
-- Date: 2016-09-22 11:02:54
--
CrossPartyMO = {}
local LAST = 4 --持续4天
--时间状态
local STATE = {
	[1] = {
		[1] = {"00:00-20:59",1},
		[2] = {"21:00-23:59",2},
	},
	[2] = {
		[1] = {"00:00-23:59",2},
	},
	[3] = {
		[1] = {"00:00-16:59",3},
		[2] = {"17:00-17:59",4},
		[3] = {"18:00-18:59",5},
		[4] = {"19:00-19:59",6},
		[5] = {"20:00-20:59",7},
		[6] = {"21:00-23:59",8},
	},
	[4] = {
		[1] = {"00:00-13:59",8},
		[2] = {"14:00-15:59",9},
		[3] = {"16:00-23:59",10},
	},
	[5] = {
		[1] = {"00:00-23:59",10},
	},
}

function CrossPartyMO.init()
end

--获取状态
function CrossPartyMO.getState(state)
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
				-- if CrossPartyMO.inShopTime() then --最后2天积分商店是连续的
				-- 	endTime = endTime + 24*3600
				-- end
				return CommonText[30065][v[2]],endTime,k
			end
		end
	end
end

--获取时间点
function CrossPartyMO.inShopTime()
	local y,m,d = CrossPartyMO.getDateString()
	local time =  os.time({year=y,month=m,day=d,hour=0,min=0,sec=0})
	time = time + 3*24*3600
	local time1 = time + 16*3600
	local time2 = time + 2*24*3600
	return {time1,time2}
end

function CrossPartyMO.inApplyTime()
	if CrossPartyBO.state_ == 1 then
		local t = ManagerTimer.getTime()
		local h = tonumber(os.date("%H", t))
		local m = tonumber(os.date("%M", t))
		if (h*60+m) >= (21*60) then
			return true
		end
	elseif CrossPartyBO.state_ == 2 then
		return true
	end
end

--服务器列表信息
function CrossPartyMO.getServerList()
	if not CrossPartyMO.serverList_ then
		return CommonText[509]
	else
		local str = ""
		for i=1,2 do
			if CrossPartyBO.serverList_[i] then
				str = str .. CrossPartyBO.serverList_[i].serverName
				str = str .. (i == 1 and "," or "...")
			end
		end
		return str
	end
end

function CrossPartyMO.getDateString()
	local time = CrossPartyBO.beginTime_
	time = string.split(time, " ")[1]
	time = string.split(time, "-")
	return tonumber(time[1]),tonumber(time[2]),tonumber(time[3])
end

--跨服战时间
function CrossPartyMO.getTime()
	local y,m,d = CrossPartyMO.getDateString()
	local time =  os.time({year=y,month=m,day=d})
	time = time + LAST*24*3600
	time = os.date("*t",time)
	return y.."/"..m .."/"..d .."-" ..time.year.."/"..time.month.."/"..time.day
end

function CrossPartyMO.goToView(index,kind)
	if not CrossPartyMO.isOpen_ then
		Toast.show(CommonText[30049])
		return
	end
	if not CrossPartyBO.state_ then
		CrossPartyBO.getState(function()
				require("app.view.CrossView").new(nil,index,kind):push()
			end)
	else
		require("app.view.CrossView").new(nil,index,kind):push()
	end
end