--
-- Author:
-- Date:
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local socket = require "socket.core"

ManagerTimer = {}

local isStart_ = false
local runInterval_ = 1 -- 运行间隔是1秒

local currentGameTime_ = 0 -- 当前的时间
local currentOsTime_ = 0 -- 当前的系统CPU时间(不对外)
local updateTime_ = 0 --更新客户端时间的时间

local scheduler_ = nil

local refreshTimeScheduler_ = nil -- 用于刷新客户端时间，调用协议的scheduler

ManagerTimer.NAME = "MANAGER_TIMER_TICK_"

local g_timePointDatas = {} -- 整点时间的数据，只能用于定点
local g_24hourLaterDatas = {} -- 保存需要延迟24小时后执行的数据

local function refreshTime()
	local function parseTime(name, data)
		-- gdump(data, "[ManagerTimer] refresh time 要刷新时间了")

		currentGameTime_ = data.time
		-- currentOsTime_ = os.time()
		currentOsTime_ = socket.gettime()
	end
	if SocketWrapper.getInstance() and SocketWrapper.getInstance():isConnected() and LoginMO.isInLogin_ then
		SocketWrapper.wrapSend(parseTime, NetRequest.new("GetTime"))
	else
		gprint("[ManagerTimer] refresh network not connect")
	end

	local function parseResource(name, data)
		local delta = UserBO.updateGetResource(data)
		-- gdump(delta, "资源变化")
		-- UiUtil.showAwards({awards = delta})
	end

	if SocketWrapper.getInstance() and SocketWrapper.getInstance():isConnected() and LoginMO.isInLogin_ then
		SocketWrapper.wrapSend(parseResource, NetRequest.new("GetResource"))
	end

	local date = ManagerTimer.getDate()
	local count = #g_24hourLaterDatas
	
	for index = 1, count do
		if g_24hourLaterDatas[index] then
			if g_24hourLaterDatas[index].month < date.month
				or g_24hourLaterDatas[index].day < date.day then  -- 可以将延迟的时间任务放入到时间数据中
				-- print("ManagerTimer:onMin 延迟时间转入时间数据中: hour=" .. g_24hourLaterDatas[index].hour)
				g_timePointDatas[#g_timePointDatas + 1] = {listener = g_24hourLaterDatas[index].listener, hour = g_24hourLaterDatas[index].hour} 
				g_24hourLaterDatas[index] = nil
				-- dump(g_timePointDatas)
			end
		end
	end

	local count = #g_timePointDatas
	for index = 1, count do
		if g_timePointDatas[index] then
			if g_timePointDatas[index].hour <= date.hour then -- 需要执行
				-- dump(g_timePointDatas[index])

				-- print("ManagerTimer 需要执行")

				-- if true then
				-- 	table.insert(ManagerTimer.m_timeExeQueue, g_timePointDatas[index].listener)  -- 延迟执行
				-- else
					g_timePointDatas[index].listener(g_timePointDatas[index].hour)
				-- end
				g_timePointDatas[index] = nil -- 删除
			end
		end
	end
end

-- serverTime: 服务器时间，单位秒
function ManagerTimer.start(serverTime)
	if isStart_ then return end

	isStart_ = true

	gprint("serverTime:", serverTime)
	gdump(os.date("*t", serverTime), "ManagerTimer.start")

	currentGameTime_ = serverTime
	-- currentOsTime_ = os.time()
	currentOsTime_ = socket.gettime()

	local function onTick(dt)
		-- local curTime = os.time()
		local curTime = socket.gettime()
		local delta = curTime - currentOsTime_

		currentGameTime_ = currentGameTime_ + delta
		currentOsTime_ = curTime

		-- gprint("game time:", currentGameTime_)

		app:dispatchEvent({name = ManagerTimer.NAME, data = delta})
	end

	if scheduler_ then
		scheduler.unscheduleGlobal(scheduler_)
	end
	scheduler_ = scheduler.scheduleGlobal(onTick, 1)

	if not refreshTimeScheduler_ then
		refreshTimeScheduler_ = scheduler.scheduleGlobal(refreshTime, 60)  -- 每分钟执行一次
	end
end

function ManagerTimer.addTickListener(callback)
	if callback and ManagerTimer.NAME then
		return app:addEventListener(ManagerTimer.NAME, function(event)
			callback(event.data)
			end)
	end
end

function ManagerTimer.removeTickListener(listener)
	if listener then
		app:removeEventListener(listener)
	end
end

-- 从当前时间后的下一个时间点为hour的时候触发一次
-- 注: 1.如果需要每天处理定点时间，则需要在ManagerTimer触发callback回调后，再调用一次addClockListener
--     2.如果当前时间刚好等于hour，会在24小时后再执行
-- hour: 触发的时间点,0~23
function ManagerTimer.addClockListener(hour, callback)
	-- gdump(hour, "ManagerTimer.addClockListener")
	if hour < 0 or hour > 23 then return nil end
	if not isRepeat then isRepeat = false end

	local date = ManagerTimer.getDate()
	if date.hour >= hour then  -- 监听当天已经无法执行了
		gprint("ManagerTimer.addClockListener 监听延迟24小时启动:" .. hour)
		g_24hourLaterDatas[#g_24hourLaterDatas + 1] = {listener = callback, hour = hour, day = date.day, month = date.month}
		return g_24hourLaterDatas[#g_24hourLaterDatas]
	else
		g_timePointDatas[#g_timePointDatas + 1] = {listener = callback, hour = hour}
		return g_timePointDatas[#g_timePointDatas]
	end
end

function ManagerTimer.removeClockListener(handler)
	for index = #g_24hourLaterDatas, 1, -1 do
		if g_24hourLaterDatas[index] == handler then
			g_24hourLaterDatas[index] = nil
			return true
		end
	end

	for index = #g_timePointDatas, 1, -1 do
		if g_timePointDatas[index] == handler then
			g_timePointDatas[index] = nil
			return true
		end
	end
	return false
end

function ManagerTimer.clearClockListener()
	gprint("ManagerTimer.clearClockListener")
	g_24hourLaterDatas = {}
	g_timePointDatas = {}
end

function ManagerTimer.destroy()
	isStart_ = false
	if scheduler_ then
		scheduler.unscheduleGlobal(scheduler_)
		scheduler_ = nil
	end
	if refreshTimeScheduler_ then
		scheduler.unscheduleGlobal(refreshTimeScheduler_)
		refreshTimeScheduler_ = nil
	end
	app:removeEventListenersByEvent(ManagerTimer.NAME)
end

-- -- 是否在时间间隔内，hour加上interva的值不能大于23
-- -- hour: 小时,0~23
-- -- interval: 间隔小时
-- function ManagerTimer.isInInterval(hour, interval)
-- 	local date = ManagerTimer.getDate()
-- 	if date.hour >= hour and date.hour <= (hour + interval) then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

-- -- 在某些状态下managertimer可能被停止
-- function ManagerTimer.checkStop()
-- 	if not ManagerTimer.m_oldTime then
-- 		ManagerTimer.m_oldTime = currentOsTime_
-- 		ManagerTimer.m_sameTimeCount = 0
-- 	else
-- 		if ManagerTimer.m_oldTime == currentOsTime_ then  -- 在连续
-- 			ManagerTimer.m_sameTimeCount = ManagerTimer.m_sameTimeCount + 1
-- 			-- print("ManagerTimer.checkStop 定时器不动:" .. ManagerTimer.m_sameTimeCount)
-- 			if ManagerTimer.m_sameTimeCount > 600 then  -- 长时间定时器不动
-- 				ManagerTimer.m_sameTimeCount = 0
-- 				isStart_ = false
-- 				local function startTimer()
-- 					gprint("ManagerTimer.checkStop 长时间不动 重新开始定时器了" .. ManagerTimer.m_sameTimeCount)
-- 					gdump(ManagerData.getCacheData(GetTime).data)
-- 					ManagerTimer.start(ManagerData.getCacheData(GetTime).data)
-- 				end
-- 				ManagerRequest.requestRefreshRequest(startTimer)
-- 			end
-- 		else
-- 			ManagerTimer.m_oldTime = currentOsTime_
-- 			ManagerTimer.m_sameTimeCount = 0
-- 		end
-- 	end
-- end

function ManagerTimer.isStart()
	return isStart_
end

function ManagerTimer.getTime()
	return currentGameTime_
end

-- 获取当前时间
function ManagerTimer.getDate()
	return os.date("*t", ManagerTimer.getTime())
end

-- 将数字时间time，单位为秒，转换为时间格式
function ManagerTimer.time(time)
	local data = {}
	data.second = time % 60
	data.minute = math.floor(time / 60) % 60
	data.hour = math.floor(time / 3600) % 24
	data.day = math.floor(time / 86400)
	return data
end

-- 将数字时间time转换为字符串的时间格式
-- function ManagerTimer.string(time)
-- 	local seconds = time % 60
-- 	local minutes = math.floor(time / 60) % 60
-- 	local hours = math.floor(time / 3600)
-- 	local result = string.format("%02d:%02d:%02d", hours, minutes, seconds)
-- 	return result
-- end

