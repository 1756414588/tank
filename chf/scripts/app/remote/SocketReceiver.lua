
-- 处理socket段获得数据的接收器

local scheduler = require("framework.scheduler")

SocketReceiver = {}

local dataMap_ = {}

local tickHandler_ = nil
local handlerIndex_ = 1

local function handlerData(name)
	local isHandler = false

	local data = dataMap_[name].data
	local forevers = dataMap_[name].forevers

	if forevers then
		for key, callback in pairs(forevers) do
			if callback then
				local result = callback(name, data)

				if not result then  -- 不再向其他的listener传递
					-- gprint("SocketReceiver: forever no more pass")
					isHandler = true
					break
				end
			end
		end
	end

	if isHandler then
		dataMap_[name].data = nil
		-- if name == "GetMap" then
		-- 	dump(dataMap_[name])
		-- end
		return
	end

	local callbacks = dataMap_[name].callbacks

	if not callbacks then
		-- gprint("[SocketReceiver] ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NO listener, name:", name)
		return
	end

	-- for key, callback in pairs(callbacks) do  -- 一个data只能对应使用一个callback
	-- 	if callback then
	-- 		dataMap_[name].data = nil -- 先清除掉数据
	-- 		-- dataMap_[name].callbacks = {}

	-- 		dataMap_[name].callbacks[key] = nil

	-- 		callback(name, data)
	-- 		return
	-- 	end
	-- end

	local minIndex = GAME_INVALID_VALUE

	for key, callback in pairs(callbacks) do  -- 只要有一个接收处理了，则结束
		if key < minIndex then
			minIndex = key
		end
	end

	if minIndex ~= GAME_INVALID_VALUE then
		local cb = dataMap_[name].callbacks[minIndex]
		dataMap_[name].data = nil
		dataMap_[name].callbacks[minIndex] = nil

		cb(name, data)
	end
end

function SocketReceiver.init()
	dataMap_ = {}
	
	if tickHandler_ then return end

	local _tick = function()
		for name, data in pairs(dataMap_) do
			if data and data.data then
				handlerData(name)
			end
		end
	end

	tickHandler_ = scheduler.scheduleGlobal(_tick, 0.1)
end

-- listener：返回一个bool类型，当forever为true时，返回值有效，具体的含义：
-- 返回false，则注册notifyName的forever是true的listener捕捉到数据，不再传递给其他注册此notifyName的listener
-- 返回true，则listener不处理数据，交给其他的listener处理。
-- 默认返回false，注意返回值只对forever为true的有效
-- 只要有一个listener处理了数据，则最终notifyName会删除此数据。只要有一个forever为false的listener接收到了数据，则会删除数据，并清除所有forever为false的listener
-- forever: 是否是注册notifyName的listener永远存在，一直监听notifyName。
--          forever为true比为false的监听级别高。默认为false。
-- -- clear: (目前无效)，是否清除之前已经注册的所有forever为false的listener。默认为true
-- force --强制监听，即使返回错误码，也要执行listen
function SocketReceiver.register(notifyName, listener, forever, clear, force)
    if not notifyName or notifyName == "" then
        gprint("[SocketReceiver] register wrong notify name. Error!!!")
	    return
    end

    -- if clear == nil then clear = true end

    if not dataMap_[notifyName] then
    	dataMap_[notifyName] = {}
    	dataMap_[notifyName].callbacks = {}
    	dataMap_[notifyName].forevers = {}
    end

    -- if clear then
    -- 	dataMap_[notifyName].callbacks = {}
    -- end

    local index = handlerIndex_

    if forever then
    	if not dataMap_[notifyName].forevers then dataMap_[notifyName].forevers = {} end
    	dataMap_[notifyName].forevers[index] = listener
    else
    	if not dataMap_[notifyName].callbacks then dataMap_[notifyName].callbacks = {} end
    	dataMap_[notifyName].callbacks[index] = listener
    	dataMap_[notifyName].force = force
    end

    handlerIndex_ = handlerIndex_ + 1
    if handlerIndex_ >= (GAME_INVALID_VALUE - 1) then
    	handlerIndex_ = 1
    end

    return index
end

--单个send发送之前清除之前的callback，防止断线关闭界面造成报错
function SocketReceiver.unregister(name)
	if dataMap_[name] and dataMap_[name].callbacks then
		dataMap_[name].callbacks = {}
	end
end

function SocketReceiver.fill(notifyName, data)
    if not notifyName or notifyName == "" then
        gprint("[SocketReceiver] fill wrong notify name. Error!!!")
	    return
    end

	if not dataMap_[notifyName] then
		-- gprint("[SocketReceiver] Error!!! fill no register name:", notifyName)
    	dataMap_[notifyName] = {}
		-- return
	end

	if dataMap_[notifyName].data then
		gprint("[SocketReceiver] Error. 333 fill. Old data exist", notifyName)
		handlerData(notifyName)
		gdump(data, notifyName .. "")
	end

	dataMap_[notifyName].data = data
end

-- 将notifyName的数据挖走，receiver中会删除数据
function SocketReceiver.dig(notifyName)
	if not dataMap_[notifyName] then return end

	local data = dataMap_[notifyName].data

	dataMap_[notifyName].data = nil

	return data
end

-- -- 不删除forever的回调
-- function SocketReceiver.clear(notifyName)
-- 	gprint("SocketReceiver.clear:", notifyName)
-- 	if dataMap_[notifyName] then
-- 		if dataMap_[notifyName].data then
-- 			handlerData(notifyName)
-- 		end

-- 		dataMap_[notifyName].data = nil -- 先清除掉数据
-- 		dataMap_[notifyName].callbacks = {}
-- 	end
-- end

function SocketReceiver.errorPick(notifyName, errorCode)
    if not notifyName or notifyName == "" or not errorCode or not dataMap_[notifyName] then
        gprint("[SocketReceiver] error wrong notify name. Error!!!", notifyName, errorCode)
	    return
    end

    Loading.getInstance():unshow()

    gprint("SocketReceiver.errorPick:", errorCode)

    local func = "socket_error_" .. errorCode .. "_callback"

    if _G[func] then
	    xpcall(function() _G[func](errorCode) end, function()
			    print("------------SOCKET ERROR----------------")
			    print(debug.traceback())
			    print("----------------------------------------")
	    	end)
    elseif dataMap_[notifyName] and dataMap_[notifyName].force == nil then --强制监听返回不处理错误码
	    local text = ErrorText["text" .. tostring(errorCode)]
	    text = text or ErrorText.textnil
	    text = text .. "(" .. errorCode .. ")"
	    print("========== ERROR NET ========== " .. text .. " (" .. tostring(notifyName) .. ")")
	    if errorCode and errorCode == SYSTEM_SOCKET_ACTIVITY_NO_FLUSHDATA then
	    	Notify.notify(LOCAL_USER_REFRESH_CLOCK)
	    else
	    	 Toast.show(text)
	    end
    end

	local copy = clone(dataMap_[notifyName].forevers)
	if copy then
		copy = table.values(copy)
		if #copy > 0 then return end
	end

	local callbacks = dataMap_[notifyName].callbacks
	if not callbacks then return end

	local minIndex = GAME_INVALID_VALUE

	for key, callback in pairs(callbacks) do  -- 如果Socket协议返回的是errorCode非200，则删除callback中第一个callback
		if key < minIndex then
			minIndex = key
		end
	end

	if minIndex ~= GAME_INVALID_VALUE then
		local cb = dataMap_[notifyName].callbacks[minIndex]
		if dataMap_[notifyName].force then --强制执行
			cb()
		end
		dataMap_[notifyName].callbacks[minIndex] = nil
	end
end

function SocketReceiver.clear()
	for name, data in pairs(dataMap_) do
		dataMap_[name].callbacks = {}
		dataMap_[name].data = nil
	end
end