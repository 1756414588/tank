
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

NetQueue = {}

local isStart_ = false

local g_requestQueue = {}  -- 联网请求的队列
local lastRequestTime_ = nil -- 联网上次发生请求的时间

local SEND_TIME_DELTA = 0.2  -- 请求发送的最小间隔

function NetQueue.start()
	if isStart_ then return end
	isStart_ = true

	local function onTick(dt)
	    if #g_requestQueue > 0 then
	        local curTime = os.time()
	        local delta = curTime - lastRequestTime_

	        if delta >= SEND_TIME_DELTA then
	            gprint("[NetQueue] 协议发送:", g_requestQueue[1].wrapper:getName(), "time:", os.time())

	            g_requestQueue[1]:start()
	            g_requestQueue[1]:release()
	            table.remove(g_requestQueue, 1)
	            lastRequestTime_ = curTime
	        end
	    end
	end

	if scheduler_ then
		scheduler.unscheduleGlobal(scheduler_)
	end
	scheduler_ = scheduler.scheduleGlobal(onTick, 0.2)
end

function NetQueue.triggerRequest(request)
    if not GLOBAL_NETWORK_SEQUENCE then  -- 不需要顺序的发送则直接发送
        request:start()
        return
    end

    if not isStart_ then  -- 计时器没有开启，则直接发送
		request:start()
		return
	end

	if not lastRequestTime_ then
		lastRequestTime_ = os.time()
		request:start()
		return
	end

	local curTime = os.time()
	local delta = curTime - lastRequestTime_

	-- print("delta:" .. delta)
	if delta >= SEND_TIME_DELTA then  -- 如果两次发送协议的时间间隔过大，则当前协议可以直接发送
		lastRequestTime_ = curTime
		request:start()
	else
		request:retain()
		table.insert(g_requestQueue, request)  -- 需要队列延迟执行
	end
end

function NetQueue.clear()
end
