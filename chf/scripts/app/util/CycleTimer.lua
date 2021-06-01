
-- 用于倒计时在周期结束后，重新新的倒计时。(如能量倒计时等)

local socket = require "socket.core"

local CycleTimer = class("CycleTimer")

function CycleTimer:ctor(deltaTime, cycleTime)
	deltaTime = deltaTime or 0
	cycleTime = cycleTime or -1

	self.isStart_ = true

	self:setCycle(cycleTime)
	self:setDeltaTime(deltaTime)
end

-- 获得倒计时剩余时间。如果有倒计时周期，还会返回经过了几次周期。
-- 当调用时的间隔已经在一轮倒计时之后了，如果设置了倒计时时，会计算多余的时间间隔等于几个周期并返回
function CycleTimer:calculate()
	if not self.isStart_ then return 0, 0 end

	-- local delta = self.endTime_ - os.time()
	local delta = self.endTime_ - socket.gettime()
	if delta < 0 then
		local absDelta = math.abs(delta)
		if self.cycle_ > 0 then -- 有时间周期
			local newTime = self.cycle_ - absDelta % self.cycle_

			self:setDeltaTime(newTime)

			local count = math.floor(absDelta / self.cycle_) + 1
			-- gprint("间隔大于时间周期.. newTime:" .. newTime .. " count:" .. count)

			return newTime, count
		else
			return 0, 0
		end
	else
		return delta, 0
	end
end

function CycleTimer:isStart()
	return self.isStart_
end

function CycleTimer:start()
	self.isStart_ = true

	--[[
	if self.cycle > 0 then  -- 如果设置了定时器，则重新开始
		self:setTime(self.cycle)
	end
	]]
end

function CycleTimer:stop()
	self.isStart_ = false
end

-- 设置倒计时周期，单位为妙
function CycleTimer:setCycle(cycleTime)
	self.cycle_ = cycleTime
end

-- 设置倒计时，如果需要倒计时周期，倒计时不可大于周期，单位为妙
function CycleTimer:setDeltaTime(time)
	-- 倒计时结束时间
	-- self.endTime_ = os.time() + time
	self.endTime_ = socket.gettime() + time
end

function CycleTimer:getLeftTime()
	if not self.isStart_ then return 0 end
	
	return math.max(self.endTime_ - socket.gettime(), 0)
	-- return math.max(self.endTime_ - os.time(), 0)
end

return CycleTimer