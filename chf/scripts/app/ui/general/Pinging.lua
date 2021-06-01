-- Ping View 
-- UI显示界面
local PingView = class("Pinging", function ()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	return node
end)

local MOVETIME = 0.5 -- 移动时间
local INTIME = 0.125 -- 遮蔽时间

local P_GREEN = 50
local P_YELLOW = 100
local P_RED = 200

local msgListener = {}

local timeStrEx = "ms"

function PingView:ctor()
 	self:setLocalZOrder(999999)
	self:setContentSize(cc.size(display.width, display.height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(display.cx, display.cy)

    -- 测试
    self.test = false -- 中心测试

	self:Init()
end 

function PingView:Init()
	if self.test then
		self.testNode = CCDrawNode:create():addTo(self,3)
	end
	
	local view = display.newSprite(IMAGE_COMMON .. "ping.png"):addTo(self,2) -- talk_panel icon_secretary
	view:setAnchorPoint(cc.p(0.5,0.5))
	-- view:setColor(ccc3(189,61,53))	-- red
	view:setColor(ccc3(128,217,97))	-- green
	-- view:setColor(ccc3(203,196,80))	-- yellow
	view:setPosition(display.width * 0.75, display.height * 0.75)
	view:setVisible(false)

	local pingStr = ui.newTTFLabel({text = "", font = G_FONT, size = 14, x = view:width() * 0.5, y = view:height() * 0.5, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(225, 255, 255)}):addTo(view)
	self.pingStr = pingStr
	self.pingStr.autoIndex = 0

	nodeTouchEventProtocol(view, handler(self, self.onTouch), nil, nil, true)

	self.touchInfo = {}
	self.touchInfo.visible = false
	self.touchInfo.view = view

	-- 四方位 max
	self.touchInfo.top = display.height
	self.touchInfo.bottom = 0
	self.touchInfo.left = 0
	self.touchInfo.right = display.width

	-- 触击点
	self.touchInfo.x = 0
	self.touchInfo.y = 0

	-- 四方位
	self.touchInfo.viewTop = 0
	self.touchInfo.viewBottom = 0
	self.touchInfo.viewLeft = 0
	self.touchInfo.viewRight = 0

	-- 移动中心
	self.touchInfo.moveCenterx = view:x()
	self.touchInfo.moveCentery = view:y()

	-- 最终中心
	self.touchInfo.viewCenterx = view:x()
	self.touchInfo.viewCentery = view:y()

	-- 大小
	self.touchInfo.width = view:width()
	self.touchInfo.height = view:height()

	-- 增量
	self.touchInfo.touchDexX = 0
	self.touchInfo.touchDexY = 0

	-- 四象计算
	self.touchInfo.CalculationFunc = function(info)
			info.viewTop = info.moveCentery + info.height * 0.5 
			info.viewBottom = info.moveCentery - info.height * 0.5 
			info.viewLeft = info.moveCenterx - info.width * 0.5 
			info.viewRight = info.moveCenterx + info.width * 0.5 
		end

	self.touchInfo:CalculationFunc()

	self.touchInfo.ieEnabled = false


	---------------------------------------
	local function func1(rv,ft)
		rv.autoIndex = rv.autoIndex + 1
		if rv.state == 0 then
			if self.touchInfo.viewLeft > rv.rect.x then
				rv.distance1 = self.touchInfo.viewLeft - rv.rect.x
				rv.speed1 = rv.distance1 / MOVETIME * ft
				rv.speed1 = 10
				rv.state = 1
			else
				rv.autoIndex = 0
				rv.state = 2
			end
		elseif rv.state == 1 then
			if self.touchInfo.viewLeft > rv.rect.x then
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - rv.speed1
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
			else
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - (self.touchInfo.viewLeft - rv.rect.x)
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
				rv.autoIndex = 0
				rv.state = 2
			end
		elseif rv.state == 2 then
			if rv.autoIndex > 30 then
				rv.distance2 = self.touchInfo.viewCenterx - rv.rect.x
				rv.speed2 = rv.distance2 / INTIME * ft
				rv.state = 3
			end
		elseif rv.state == 3 then
			if self.touchInfo.viewCenterx > rv.rect.x then
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - rv.speed2
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
			else
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - (self.touchInfo.viewCenterx - rv.rect.x)
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
				rv.state = 4
			end
		else -- rv.state == 4
			if rv.funcDone then rv.funcDone() end
			rv.state = -1
		end
	end

	local function funDone1()
		timeStrEx = ""
		pingStr:setPosition(view:width() * 0.75,view:height() * 0.5)
	end

	local function func2(rv,ft)
		rv.autoIndex = rv.autoIndex + 1
		if rv.state == 0 then
			if self.touchInfo.viewRight < (rv.rect.x + rv.rect.width) then
				rv.distance1 = self.touchInfo.viewRight - (rv.rect.x + rv.rect.width)
				rv.speed1 = rv.distance1 / MOVETIME * ft
				rv.speed1 = -10
				rv.state = 1
			else
				rv.autoIndex = 0
				rv.state = 2
			end
		elseif rv.state == 1 then
			if self.touchInfo.viewRight < (rv.rect.x + rv.rect.width) then
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - rv.speed1
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
			else
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - (self.touchInfo.viewRight - (rv.rect.x + rv.rect.width))
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
				rv.autoIndex = 0
				rv.state = 2
			end
		elseif rv.state == 2 then
			if rv.autoIndex > 30 then
				rv.distance2 = self.touchInfo.viewCenterx - (rv.rect.x + rv.rect.width)
				rv.speed2 = rv.distance2 / INTIME * ft
				rv.state = 3
			end
		elseif rv.state == 3 then
			if self.touchInfo.viewCenterx < (rv.rect.x + rv.rect.width - 1) then
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - rv.speed2
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
			else
				self.touchInfo.moveCenterx = self.touchInfo.viewCenterx
				self.touchInfo.moveCenterx = self.touchInfo.moveCenterx - (self.touchInfo.viewCenterx - (rv.rect.x + rv.rect.width - 1))
				self.touchInfo:CalculationFunc()
				self.touchInfo.viewCenterx = self.touchInfo.moveCenterx
				self.touchInfo.view:setPosition(self.touchInfo.viewCenterx,self.touchInfo.viewCentery)
				rv.state = 4
			end
		else -- rv.state == 4
			if rv.funcDone then rv.funcDone() end
			rv.state = -1
		end
	end

	local function funDone2()
		timeStrEx = ""
		pingStr:setPosition(view:width() * 0.25,view:height() * 0.5)
	end


	self.CheckRect = {}

	-- rect one left
	local RectView = {}
	RectView.rect = cc.rect(0, 0, display.width * 0.5 - 0.01 , display.height) 	-- 移动判断区域
	RectView.viewrect = cc.rect(-50, 0, display.width * 0.5 + 50 - 0.01 , display.height) -- 可视最大判断区域
	RectView.state = 0 															-- 状态	-1停止使用 0默认检测 1靠拢状态 2等待|测试状态 3归位状态 4完成
	RectView.autoIndex = 0 														-- 计数点
	RectView.func = func1 														-- 处理方法
	RectView.distance1 = 0
	RectView.speed1 = 0
	RectView.distance2 = 0
	RectView.speed2 = 0
	RectView.funcDone = funDone1
	
	self.CheckRect[#self.CheckRect + 1] = RectView

	-- rect two right
	local RectView2 = {}
	RectView2.rect = cc.rect(display.cx, 0, display.width * 0.5 , display.height) 	-- 移动判断区域
	RectView2.viewrect = cc.rect(display.cx, 0, display.width * 0.5 + 50 , display.height) -- 可视最大判断区域
	RectView2.state = 0 													-- 状态	-1停止使用 0默认检测 1靠拢状态 2等待|测试状态 3归位状态 4完成
	RectView2.autoIndex = 0 													-- 计数点
	RectView2.func = func2 													-- 处理方法
	RectView2.distance1 = 0
	RectView2.speed1 = 0
	RectView2.distance2 = 0
	RectView2.speed2 = 0
	RectView2.funcDone = funDone2
	self.CheckRect[#self.CheckRect + 1] = RectView2

	self.state = true

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
end

-- 显示
function PingView:ShowUI()
	self.touchInfo.view:setVisible(true)
	self.touchInfo.view:setPosition(display.width * 0.75,display.height * 0.75)

	-- 移动中心
	self.touchInfo.moveCenterx = self.touchInfo.view:x()
	self.touchInfo.moveCentery = self.touchInfo.view:y()

	-- 最终中心
	self.touchInfo.viewCenterx = self.touchInfo.view:x()
	self.touchInfo.viewCentery = self.touchInfo.view:y()

	self.touchInfo:CalculationFunc()

	self:reset()

	self.touchInfo.visible = true
end

-- 隐藏
function PingView:HidUI()
	self.touchInfo.view:setVisible(false)
	self.touchInfo.visible = false
end

-- 复位预判断信息
function PingView:reset()
	for index = 1 , #self.CheckRect do
		local rectview = self.CheckRect[index]
		rectview.state = 0
	end
	timeStrEx = "ms"
	self.pingStr:setPosition(self.touchInfo.view:width() * 0.5,self.touchInfo.view:height() * 0.5)
end

function PingView:onEnterFrame(ft)
	if not self.touchInfo.visible then return end
	if self.pingStr then
		self.pingStr.autoIndex = self.pingStr.autoIndex + 1
		if self.pingStr.autoIndex > 30 then
			self.pingStr.autoIndex = 0

			local strNum = msgListener.delayTime + msgListener.addping + math.random(-5,5)
			if strNum <= 0 then strNum = 1 end
			if strNum > 1000 then
				self.pingStr:setString(">999ms")
			else
				self.pingStr:setString(strNum..timeStrEx)
			end

			if self.touchInfo.view then
				if strNum < (P_GREEN * 2) then
					self.touchInfo.view:setColor(ccc3(128,217,97))
				elseif strNum < (P_YELLOW * 2) then
					self.touchInfo.view:setColor(ccc3(203,196,80))
				else -- P_RED
					self.touchInfo.view:setColor(ccc3(189,61,53))
				end
			end
		end
	end

	if self.test then
		self.testNode:clear()
		self.testNode:drawDot(cc.p(self.touchInfo.moveCenterx, self.touchInfo.moveCentery) , 4 , ccc4f(0.9,0,0,1))
	end
	if self.touchInfo.ieEnabled then
		if self.state then
			self.state = false
			-- 
			self:reset()
		end
	else
		self.state = true
		for index = 1 , #self.CheckRect do
			local rectview = self.CheckRect[index]
			if rectview.state >= 0 and cc.rectContainsPoint(rectview.viewrect, cc.p(math.floor(self.touchInfo.viewCenterx), self.touchInfo.viewCentery)) then
				rectview:func(ft)
			else
				rectview.state = -1
			end
		end
	end
end

function PingView:onTouch(event)
	if event.name == "began" then
		return self:began(event)
	elseif event.name == "moved" then
		self:moved(event)
	elseif event.name == "ended" then
		self:ended(event)
	end
end

function PingView:began(event)
	if cc.rectContainsPoint(self.touchInfo.view:getCascadeBoundingBox(), cc.p(event.x,event.y)) then
		self.touchInfo.x = event.x
		self.touchInfo.y = event.y
		self.touchInfo.viewCenterx = self.touchInfo.view:x()
		self.touchInfo.viewCentery = self.touchInfo.view:y()
		self.touchInfo.moveCenterx = self.touchInfo.view:x()
		self.touchInfo.moveCentery = self.touchInfo.view:y()
		self.touchInfo.touchDexX = 0
		self.touchInfo.touchDexY = 0
		self.touchInfo.ieEnabled = true
	end
	return true
end
function PingView:moved(event)
	local dexX , dexY = event.x - self.touchInfo.x, event.y - self.touchInfo.y
	self.touchInfo.moveCenterx , self.touchInfo.moveCentery = self.touchInfo.viewCenterx + dexX , self.touchInfo.viewCentery + dexY
	self.touchInfo:CalculationFunc()

	self.touchInfo.touchDexX , self.touchInfo.touchDexY = 0,0
	-- -- 顶部测试
	if self.touchInfo.viewTop > self.touchInfo.top then
		self.touchInfo.touchDexY = self.touchInfo.touchDexY + (self.touchInfo.top - self.touchInfo.viewTop)
	end
	-- 底部测试
	if self.touchInfo.viewBottom < self.touchInfo.bottom then
		self.touchInfo.touchDexY = self.touchInfo.touchDexY + (self.touchInfo.bottom - self.touchInfo.viewBottom)
	end
	-- 左边测试
	if self.touchInfo.viewLeft < self.touchInfo.left then
		self.touchInfo.touchDexX = self.touchInfo.touchDexX + (self.touchInfo.left - self.touchInfo.viewLeft)
	end
	-- 右边测试
	if self.touchInfo.viewRight > self.touchInfo.right then
		self.touchInfo.touchDexX = self.touchInfo.touchDexX + (self.touchInfo.right - self.touchInfo.viewRight)
	end

	local touchX, touchY = self.touchInfo.moveCenterx + self.touchInfo.touchDexX , self.touchInfo.moveCentery + self.touchInfo.touchDexY

	self.touchInfo.view:setPosition(touchX,touchY)
end
function PingView:ended(event)
	self.touchInfo.viewCenterx , self.touchInfo.viewCentery = self.touchInfo.moveCenterx + self.touchInfo.touchDexX , self.touchInfo.moveCentery + self.touchInfo.touchDexY
	self.touchInfo.ieEnabled = false
end

function PingView:Destory()
	self:removeSelf()
end




local scheduler = require("framework.scheduler")
local Pinging = class("Pinging", nil)

local pingInstance = nil

function Pinging.GetInstance()
	if not pingInstance then
		pingInstance = Pinging.new()
	end
	return pingInstance
end

function Pinging:ctor()
	msgListener = {msg = {}, addping = 0, delayTime = 0, liquidation = {}}
	if not msgListener.Handler then
		msgListener.Handler = scheduler.scheduleGlobal(handler(self,self.onTick), 3)
	end
end

function Pinging:onTick( ft )
	if msgListener and msgListener.liquidation and table.getn(msgListener.liquidation) > 0 then
		local delayAlltime = 0
		for index = 1 , #msgListener.liquidation do
			local info = msgListener.liquidation[index]
			delayAlltime = delayAlltime + info.delayTime
		end
		local delayTime = delayAlltime / (#msgListener.liquidation)
		msgListener.delayTime = math.ceil(delayTime)
		msgListener.liquidation = {}
	end
end

function Pinging:Init()
	local pv = PingView.new()
	pingInstance.view = pv
	local scene = display.getRunningScene()
	scene:addChild(pv, 999999)
end

function Pinging:show()
	if pingInstance.view and UserMO.showPintUI then
		pingInstance.view:ShowUI()
	end
	self:resetPing() -- 重置显示
end

function Pinging:unshow()
	if pingInstance.view then
		pingInstance.view:HidUI()
	end
end

function Pinging:Destory()
	if not tolua.isnull(pingInstance.view) then
		pingInstance.view:Destory()
		pingInstance.view = nil
	end
	if msgListener.Handler then
		scheduler.unscheduleGlobal(msgListener.Handler)
		msgListener.Handler = nil
	end
	pingInstance.view = nil
	pingInstance = nil
end

-- test
function Pinging:ShowTo()
	local pv = PingView.new()
	pingInstance.view = pv
	return pv
end

----------------------------------------------------------
--						DATA							--
----------------------------------------------------------
function Pinging.sendData(name,time)
	-- print("Ping Send :" .. name .. " time " .. time)
	if not pingInstance then return end
	msgListener.msg[name] = time

end

function Pinging:resetData()
	-- print("================= [ping] resetData ===============")
	if msgListener then
		if msgListener.Handler then
			scheduler.unscheduleGlobal(msgListener.Handler)
			msgListener.Handler = nil
		end
	else
		msgListener = {}
	end

	msgListener.liquidation = {}
	msgListener.msg = {}
	msgListener.addping = 0
	msgListener.delayTime = 1

	if not msgListener.Handler then
		msgListener.Handler = scheduler.scheduleGlobal(handler(self,self.onTick), 1)
	end
end

function Pinging:closeData()
	-- print(" ================== SocketWrapper:close ===============")
	if msgListener and msgListener.Handler then
		scheduler.unscheduleGlobal(msgListener.Handler)
		msgListener.Handler = nil
	end
	-- body
	msgListener.addping = msgListener.addping + 10000
end

function Pinging:resetPing()
	-- print(" ================== Pinging:resetPing ===============")
	msgListener.addping = 0
	msgListener.delayTime = 1
end
-- socket.gettime()
function Pinging.receiveData(name,time)
	-- print("Ping Receive :" .. name .. " time " .. time)
	if not pingInstance then return end
	if msgListener.msg[name] then
		local receiveTime = time
		local sendTime = msgListener.msg[name]
		local delay = (receiveTime - sendTime)-- * 0.5
		local delayTime = math.ceil(delay * 100)

		local timeInfo = {}
		timeInfo.name = name
		timeInfo.sendTime = sendTime
		timeInfo.receiveTime = receiveTime
		timeInfo.delayTime = delayTime
		msgListener.liquidation[#msgListener.liquidation + 1] = timeInfo
	end
end

return Pinging