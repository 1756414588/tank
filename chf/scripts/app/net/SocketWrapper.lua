
require("app.text.LoginText")

local scheduler = require("framework.scheduler")

local socket = require "socket.core"

-- SOCKET_CONN_TICK_TIME = 0.001
-- SOCKET_TICK_TIME = 0.001
SOCKET_CONN_TICK_TIME = 1
SOCKET_TICK_TIME = 0.5

SOCKET_CONNECT_MAX_NUM = 6 -- 连接尝试的最大次数，超过此次数还没有连接上，则连接失败

STATUS_CLOSED = "closed"
STATUS_NOT_CONNECTED = "Socket is not connected"
STATUS_ALREADY_CONNECTED = "already connected"

-- cc.net = require("framework.cc.net.init")
-- local ByteArray = require("framework.cc.utils.ByteArray")

-- require("framework.cc.utils.bit")

local SocketWrapper = class("SocketWrapper")

function SocketWrapper:ctor(host, port)
	self.host_ = host
	self.port_ = port

	self.isConnected_ = nil
	self.connectTime_ = nil -- 连接次数计数
end

-- 连接成功后的回调
function SocketWrapper:connect(connectCallback)
	local time = socket.gettime()
	gprint("[SocketWrapper] connect time:" .. time)
	gprint("[SocketWrapper] host:", self.host_)
	gprint("[SocketWrapper] port:", self.port_)

	self.showDisconnect_ = true


	ServiceBO.getIPAddress(function(ipAddress)
				-- self.tcp_ = socket.tcp()
				local myDeviceIP = ipAddress
				local localVersion = LoginBO.getLocalApkVersion()
				if not myDeviceIP then myDeviceIP = "" end
				if (device.platform == "ios" or device.platform == "mac") and localVersion >= 200 and myDeviceIP:find(":") then
					self.tcp_ = socket.tcp6()
				else
					self.tcp_ = socket.tcp()
				end

	        	self.tcp_:settimeout(0)
				self.tcp_:setoption("tcp-nodelay", true)

				local function _connect()
					-- local succ, status = self.tcp_:connect(self.host_, self.port_)
					local succ, status = self.tcp_:connect(self.host_, self.port_)
					gprint("[SocketWrapper] connect:", succ, status)

					if (succ and succ == 1) or status == STATUS_ALREADY_CONNECTED then
						self.isConnected_ = true  -- 连接上了

						self:_onConnected()

						if connectCallback then
							connectCallback()
						end
						return true
					else
						return false
					end
				end

				if not _connect() then  -- 如果没有连接上，启动定时器，尝试多次连接
					local connectTick = function ()
						if self.isConnected_ then
							if self.connectTickHandler then
								scheduler.unscheduleGlobal(self.connectTickHandler)
								self.connectTickHandler = nil
							end
							return
						end

						self.connectTime_ = self.connectTime_ or 0
						self.connectTime_ = self.connectTime_ + 1

						gprint("[SocketWrapper] try connect! num:", self.connectTime_)

						if self.connectTime_ >= SOCKET_CONNECT_MAX_NUM then  -- 连接不上了
							self.connectTime_ = nil
							self:close()
						end

						_connect()
					end

								self.connectTickHandler = scheduler.scheduleGlobal(connectTick, SOCKET_CONN_TICK_TIME)
							end
	    end)
end

-- connect成功后，开始监听接收数据
function SocketWrapper:_onConnected()

	Pinging.GetInstance():resetData()

	local __tick = function()
		while true do
			local body, status, partial = self.tcp_:receive("*a")

			-- gprint("status:", status, "body:", body and #body or 0, "partial:", partial and #partial or 0)

			if status == STATUS_CLOSED or status == STATUS_NOT_CONNECTED or UserMO.systemLoginErrorState then
				gprint("SocketWrapper:_onConnected: status:", status)
				self:close()
				return
			end

			if (body and string.len(body) == 0) or (partial and string.len(partial) == 0) then return end

			if body and partial then body = body .. partial end

			self:_onReceiveData(partial or body, partial, body)
		end
	end

	self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end

-- function SocketWrapper:_onReconnect()
-- 	if not self.isRetryConnect_ then return end

-- 	gprint("[SocketWrapper] _onReconnect")

-- 	if self.reconnectScheduler then
-- 		scheduler.unscheduleGlobal(self.reconnectScheduler)
-- 		self.reconnectScheduler = nil
-- 	end

-- 	local __doReConnect = function ()
-- 		-- if self.reconnectScheduler then
-- 		-- 	scheduler.unscheduleGlobal(self.reconnectScheduler)
-- 		-- end
-- 		self.reconnectScheduler = nil

-- 		self:connect()
-- 	end
-- 	self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, 2)
-- end

local ary = nil

local byteQue = {}
local spilt = 50000

local msgLen = 0
local msgData = ""

function SocketWrapper:_onReceiveData(data, partial, body)
	-- print("接受...到数据了")

	-- gprint("[SocketWrapper] _onReceiveData status:", status, "data:", data, "partial:", partial)

	local count = math.ceil(#data/spilt)
	-- gprint("@^^^^^^^^^write data", #data, count)
	for i=1,count do
		local p = cc.utils.ByteArray.new()
		p:setEndian(cc.utils.ByteArray.ENDIAN_BIG)
		byteQue[#byteQue+1] = p
		local pos = p:getPos()
		local sIdx = (i-1) * spilt + 1
		local eIdx = i * spilt
		if eIdx > #data then
			eIdx = #data
		end
		for s=sIdx,eIdx do
			p:writeRawByte(string.sub(data,s,s))
		end
		p:setPos(pos)
	end

	local receivetime = socket.gettime()

	while #byteQue > 0 do
		msgLen = 0
		msgData = ""

		local remove = 1
		local ary = byteQue[remove]
		pos = ary:getPos()

		local len = 4
		local lenStr = ""
		while ary and (len > ary:getAvailable()) do 
			local available = ary:getAvailable()
			lenStr = lenStr .. ary:readBuf(available)
			len = len - available
			ary = byteQue[remove+1]
			remove = remove + 1
		end
		
		if ary then
			lenStr = lenStr .. ary:readBuf(len)
			_, msgLen = string.unpack(lenStr, ary:_getLC("i"))

			local readLen = msgLen
			while ary and (readLen > ary:getAvailable()) do 
				local available = ary:getAvailable()
				msgData = msgData .. ary:readString(available)
				readLen = readLen - available
				ary = byteQue[remove+1]
				remove = remove + 1
			end

			if ary then
				msgData = msgData .. ary:readString(readLen)
		        local name, cmd, code, param, data = PbProtocol.decode(msgData)
		        name = name or ""
		        code = code or 0
		        -- gdump(data, "[SocketWrapper] receive data. name:" .. name .. " code:" .. code)
		        Pinging.receiveData(name,receivetime)
		        if code ~= 0 and code ~= 200 then
		        	-- errorCode = code
		        	-- ok = false
		        	SocketReceiver.errorPick(name, code)
		        else
		        	-- gprint("name:", name)
		        	-- local PbName = PbResponse[cmd]
		        	data = data or {}
		        	-- 填充数据
		        	SocketReceiver.fill(name, data)
		        end

		        if ary:getAvailable() > 0 then
		        	remove = remove - 1
		        end

		        for i=1,remove do
		        	table.remove(byteQue, 1)
		        end
		    else
		    	for i=1,remove-1 do
		    		if i == 1 then
			    		byteQue[i]:setPos(pos)
		    		else
			    		byteQue[i]:setPos(1)
			    	end
		    	end		

		    	break        
	       end
	    else
	    	for i=1,remove-1 do
	    		if i == 1 then
		    		byteQue[i]:setPos(pos)
	    		else
		    		byteQue[i]:setPos(1)
		    	end
	    	end
	    	break
       end
	end
	-- print("level!@~~~~~~~~~~~~", #byteQue)
	
	-- local pos = ary:getPos()
	
	-- gprint("@^^^^^^write data :", pos, #data)

	-- ary:writeBuf(data)
	-- ary:setPos(pos)

    -- local ok = true
    -- local errorCode = 0
	-- while ary:getAvailable() > 4 do
	-- 	pos = ary:getPos()
	-- 	gprint("@^^^^^^getAvailable :", pos, ary:getAvailable())
	-- 	local msgLen = ary:readInt()
 --        gprint("@^^^^^^msgLen:",msgLen, "available", ary:getAvailable())
	-- 	if msgLen > ary:getAvailable() then
	-- 		ary:setPos(pos)
	-- 		break
	-- 	end

 --        local msgData = ary:readString(msgLen)
 --        pos = ary:getPos()

 --        gprint("@^^^^^^msgData^^^^", msgLen, #msgData)

 --        local name, cmd, code, param, data = PbProtocol.decode(msgData)
 --        name = name or ""
 --        code = code or 0
 --        -- gdump(data, "[SocketWrapper] receive data. name:" .. name .. " code:" .. code)
 --        if code ~= 0 and code ~= 200 then
 --        	-- errorCode = code
 --        	-- ok = false
 --        	SocketReceiver.errorPick(name, code)
 --        else
 --        	-- gprint("name:", name)
 --        	-- local PbName = PbResponse[cmd]
 --        	data = data or {}
 --        	-- 填充数据
 --        	SocketReceiver.fill(name, data)
 --        end
 --        -- if ary:getAvailable() == 0 then
 --        -- 	break
 --        -- end
 --    end

 --    if ary:getAvailable() > 0 then
	--     local temp = cc.utils.ByteArray.new()
	-- 	temp:setEndian(cc.utils.ByteArray.ENDIAN_BIG)

	-- 	gprint("@^^^^^^^retain^^^^", ary:getPos(), ary:getAvailable())

	--     temp:writeBytes(ary, ary:getPos(), ary:getAvailable())
	--     ary = nil
	--     ary = temp
	--     -- temp = nil
	--     ary:setPos(1)
	-- else
	-- 	ary = nil
	-- end
    -- if not ok then
    --     gprint("[SocketWrapper] ERROR!!! code:", errorCode)

    --     Loading.getInstance():unshow()

    --     local text = ErrorText["text" .. tostring(errorCode)]
    --     text = text or ErrorText.textnil
    --     text = text .. "(" .. errorCode .. ")"
    --     Toast.show(text)
    -- end
end

function SocketWrapper:close()
	gprint("[SocketWrapper] close")
	self.tcp_:close()

	self.isConnected_ = false

	if self.connectTickHandler then
		scheduler.unscheduleGlobal(self.connectTickHandler)
		self.connectTickHandler = nil
	end

	if self.tickScheduler then
		scheduler.unscheduleGlobal(self.tickScheduler)
		self.tickScheduler = nil
	end

	Pinging.GetInstance():closeData()

	-- 断开后显示内容
	self:getVer()
end

-- 网络外部强制关闭连接
-- silience: 是否安静的关闭连接；false会在连接断开后，进入showConnect()函数
function SocketWrapper:disconnect(silience)
-- 	gprint("[SocketWrapper] disconnect")
	if silience then
		self.showDisconnect_ = false
	else
		self.showDisconnect_ = true
	end
	self.isConnected_ = false
	self.tcp_:shutdown()
end

function SocketWrapper:send(data)
	if not self.isConnected_ then return end
	
	-- gprint("[SocketWrapper] 发送:", data)
	-- self.socketConn_:send(data)
	-- dump(self.tcp_, "发送时")
	-- dump(self.tcp_:getstats(), "xxx")
	
	self.tcp_:send(data)
end

-- function SocketWrapper.receive(event)
-- 	print("SocketWrapper.receive")

-- 	local ba = ByteArray.new(ByteArray.ENDIAN_BIG)
-- 	ba:writeBuf(event.data)
-- 	ba:setPos(1)

-- 	while ba:getAvailable() <= ba:getLen() do
-- 		if ba:getAvailable() == 0 then
-- 			break
-- 		end
-- 	end
-- end

function SocketWrapper:isConnected()
	return self.isConnected_
end

--断线重连判断版本是否需要更新
function SocketWrapper:getVer()
	local rhand = handler(self, self.showConnect)
	--ios 不要检测更新
	if device.platform == "ios" then
		rhand()
		return
	end
    local request = network.createHTTPRequest(function(event)
    	local request = event.request
    	if event.name == "completed" then
	        if request:getResponseStatusCode() ~= 200 then
	        	rhand()
	        else
	            local dataRecv = request:getResponseData()
	            if string.sub(dataRecv,1,string.len(GameConfig.version)) == GameConfig.version then
	            	rhand()
	            else
	            	BusErrorDialog.getInstance():show({msg=ErrorText.text207}, function()
	            						-- SocketWrapper.getInstance():disconnect(true)
	            						Enter.startLogo()
	            					end)
	            	BusErrorDialog.getInstance().m_cancelBtn:hide()
	            	BusErrorDialog.getInstance().m_okBtn:x(BusErrorDialog.getInstance().m_okBtn:getParent():width()/2)
	            end
	        end
   		else
        	rhand()
    	end
    end, GameConfig.VER_URL or "", "GET")
    
    if request then
        request:setTimeout(30)
        request:start()
	else
		rhand()
    end
end

function SocketWrapper:showConnect()
	local needLogout = LoginMO.isInLogin_

	LoginMO.isInLogin_ = false -- 断开连接，不在游戏中

	Loading.getInstance():unshow()

	if self.isConnected_ then
		gprint("SocketWrapper ErrorDialog socket is connected Error!!!!!!")
	end

	if not self.showDisconnect_ then
	-- 	gprint("SocketWrapper:showConnect() not show disconnect!!!!!!!!")
		if needLogout then UserBO.logout() end
		return
	end

	if UiDirector.hasUiByName("HomeView") then -- 在游戏中 UserMO.systemLoginErrorStr ErrorText.text6
	    BusErrorDialog.getInstance():show({msg=UserMO.systemLoginErrorStr, code=nil}, function()

	    		UserMO.updateSystemLoginError()

	    		if needLogout then UserBO.logout() end

	    		local function doneLordData()
		    		Loading.getInstance():unshow()
		    		-- 重登陆之后拉取一下荣誉状态
		    		RoyaleSurviveBO.getHonourStatus()
		    		HeroBO.getHeroCd()
		    		HeroBO.getHeroEndTime()
		    		WorldBO.getWorldStaffing()

		    		UiDirector.popMakeUiTop("HomeView")
	    			local homeView = UiDirector.getUiByName("HomeView")
	    			homeView:showChosenIndex(MAIN_SHOW_BASE)
	    			UserMO.startCheckFight_ = true
	    		end

	    		local function doneRoleLogin(notifyName, data)
		    		Loading.getInstance():unshow()
		    		Loading.getInstance():show(nil, nil, 0)

		    		if table.isexist(data, "war") and data.war == 1 then
						PartyBattleMO.isOpen = true
					else
						PartyBattleMO.isOpen = false
					end

					if table.isexist(data, "fortress") and data.fortress == 1 then -- 编制功能是否开启
						FortressMO.isOpen_ = true
					else
						FortressMO.isOpen_ = false
					end
					CrossBO.newFormation_ = nil
	    			UserBO.asynLordData(doneLordData)
	    		end

	    		local function doneBeginGame(name, data)
		    		Loading.getInstance():unshow()
		    		Loading.getInstance():show(nil, nil, 0)
					SocketWrapper.wrapSend(doneRoleLogin, NetRequest.new("RoleLogin"))
	    		end

	    		local function doneReLogin()
		    		Loading.getInstance():unshow()
		    		Loading.getInstance():show(nil, nil, 0)

		    		self:connect(function()
		    				LoginBO.asynBeginGame(doneBeginGame)
		    			end)
	    		end

	    		local function doneServerList()
		    		Loading.getInstance():unshow()

	    			local currentArea = LoginMO.getServerById(GameConfig.areaId)
	    			gdump(currentArea, "SocketWrapper doneServerList")
	    			if not currentArea or currentArea.stop == 1 then
	    				BusErrorDialog.getInstance():show({msg=LoginText[58], code=nil}, function() os.exit() end) -- 请退出游戏，稍后再试
	    				return
	    			end

		    		Loading.getInstance():show(nil, nil, 0)
	    			LoginBO.asynReLogin(doneReLogin)
	    		end

	    		Loading.getInstance():show(nil, GAME_INVALID_VALUE, 0)
	    		LoginBO.asynGetServerList(doneServerList)
	    	end)
	else
		if needLogout then UserBO.logout() end

		-- 不在登录流程中
		Enter.startLogin()
		scheduler.performWithDelayGlobal(function()
				Toast.show(LoginText[55])  -- 重新登录
			end, 0.25)
	end

	-- gprint("SocketWrapper:showConnect() showErrorDialog")

 --    NetErrorDialog.getInstance():show({msg=LoginText[54], code=nil}, function()

	-- 		-- LoginBO.asynReLogin()

	-- 		if UiDirector.hasUiByName("HomeView") then -- 在游戏中
	-- 			Loading.getInstance():show()
	--     		self:connect(function()
	--     				Loading.getInstance():unshow()

	--     				-- local sceneName = display.getRunningScene().__cname
	--     				-- if sceneName == "MainScene" then
	--     				-- 	gprint("===============================================")
	--     				-- 	gprint("======= IN GAME !!! REPLACE RCENE =============")
	--     				-- 	Enter.startMain()
	--     				-- else

	-- 						-- UiDirector.clear(true)
	--     		-- 			display.replaceScene(require("app.scenes.MainScene").new())
	--     		-- 		end
	--     			end)
	-- 		else
	-- 			-- 不在游戏中，则直接先返回登录
	-- 			gprint("SocketWrapper:showConnect not in GAME!!!")

	-- 			Loading.getInstance():unshow()
	-- 			Enter.startLogin()
	-- 		end
 --    	end)
end

local instance_ = nil

local heartHandler_ = nil  -- 心跳句柄
local heartNoSendTime_ = 0 --  计算多久没有发送信息的时间

local function heartCallback(dt)
	-- print(heartNoSendTime_)
	heartNoSendTime_ = heartNoSendTime_ + dt
	if heartNoSendTime_ > 10 then  -- 需要发送心跳包
		if SocketWrapper.getInstance() and SocketWrapper.getInstance():isConnected() and LoginMO.isInLogin_ then
			-- print("心跳")
			SocketWrapper.wrapSend(function ( )
				-- body
				-- print("收到心跳")
			end, NetRequest.new("Heart"))
			heartNoSendTime_ = 0
		end
	end
end

function SocketWrapper.init(host, port, connectCallback)
	-- gdump(instance_, "SocketWrapper.init")
	if not instance_ then
		instance_ = nil
	end
	
	instance_ = SocketWrapper.new(host, port)
	instance_:connect(connectCallback)

	if heartHandler_ then
		ManagerTimer.removeTickListener(heartHandler_)
		heartHandler_ = nil
	end
	heartHandler_ = ManagerTimer.addTickListener(heartCallback)
end

function SocketWrapper.wrapSends(requests)
	if not requests or #requests < 1 then
		gprint("[SocketWrapper] wrap send Error!!! no REQUEST")
		return
	end

	local ary = cc.utils.ByteArray.new()
	ary:setEndian(cc.utils.ByteArray.ENDIAN_BIG)

	for index = 1, #requests do
        local unit = requests[index]
        gdump(unit.param_, "[SocketWrapper] send data. name:" .. unit.name_)

        local extend = protobuf.encode(unit.name_ .. "Rq", unit.param_)
    	local s = "Base cmd " .. unit.name_ .. "Rq" .. ".ext"
    	local data = protobuf.pack(s, PbList[unit.name_][1], extend)

		-- local data = PbProtocol.encode(unit.name_ .. "Rq", PbList[unit.name_][1], unit.param_)
	    ary:writeInt(#data)
        ary:writeBuf(data)

        -- if true then ----- 测试
        -- 	local s = "Base cmd " .. unit.name_ .. "Rq" .. ".ext"
        -- 	print("s:", s, "len:", #data)
        -- 	local data1, c = protobuf.unpack(s, data)
        -- 	-- print("data1:", data1, "  end", #data1)
        -- 	gdump(data1, "这不是坑爹吗")
        -- 	gdump(c, "ddddddd")

        -- 	gdump(protobuf.decode(unit.name_ .. "Rq", c[1], c[2]), "这你妹解的出来吗？")
        -- end
	end

	local content = ary:getBytes()

	heartNoSendTime_ = 0

	instance_:send(content)
end

-- 只支持发送单个request
function SocketWrapper.wrapSend(listener, request, removeBefore)
	local handle = 0
	if listener then
		local name = request:getName()
		if removeBefore then
			SocketReceiver.unregister(name)
		end
		handle = SocketReceiver.register(name, listener)
		Pinging.sendData(request:getName(),socket.gettime())
	end

	SocketWrapper.wrapSends({request})
	return handle
end

function SocketWrapper.getInstance()
	return instance_
end

-- function SocketWrapper.deleteInstance()
-- 	instance_ = nil
-- end

return SocketWrapper