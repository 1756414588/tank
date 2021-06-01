
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

SchedulerSet = {}

local scheduler_ = nil
local set_ = {}

local schedulerIndex_ = 0

SchedulerSet.STATE_RUN = 1  -- 运行
SchedulerSet.STATE_WAIT = 2  -- 等待

-- set保存数据，数据中必须有doneCallback，表示倒计时结束时的回调
-- state: 状态。默认是STATE_RUN
function SchedulerSet.add(endTime, set, state)
	state = state or SchedulerSet.STATE_RUN 

	if not scheduler_ then
		scheduler_ = scheduler.scheduleGlobal(SchedulerSet.onTick, 1)
	end

	local node = {}
	node.endTime_ = endTime
	node.state = state
	node.doneCallback = set.doneCallback

	set.endTime_ = nil
	set.doneCallback = nil

	table.merge(node, set)

	schedulerIndex_ = schedulerIndex_ + 1
	set_[schedulerIndex_] = node

	return schedulerIndex_
end

function SchedulerSet.onTick(dt)
	local curTime = ManagerTimer.getTime()

	-- gprint("SchedulerSet.onTick ....", #table.values(set_))

	for index, set in pairs(set_) do
		if set then
			if set.state == SchedulerSet.STATE_RUN then -- 正在运行
				local delta = set.endTime_ - curTime

				if delta <= 0 then
					if set.doneCallback then
						set.doneCallback(index, set)
					end
					set_[index] = nil
				end
			elseif set.state == SchedulerSet.STATE_WAIT then
				-- gprint("正在等待")
			end
		else
			gprint("[SchedulerSet] Error!!! 这儿是空的:", index)
		end
	end
end

function SchedulerSet.getEndTime(id)
	local set = set_[id]
	if not set then
		return 0
	end
	return set.endTime_
end

function SchedulerSet.getTimeById(id)
	local set = set_[id]
	if not set then
		return 0
	end
	local delta = set.endTime_ - ManagerTimer.getTime()
	if delta < 0 then delta = 0 end
	
	return delta
end

-- 设置计划任务的剩余时间
function SchedulerSet.setTimeById(id, endTime)
	-- if time < 0 then time = 0 end

	local set = set_[id]
	if not set then return false end

	set.endTime_ = endTime
	return true
end

function SchedulerSet.getStateById(id)
	local set = set_[id]
	if not set then
		return nil
	end
	return set.state
end

function SchedulerSet.start(id)
	local set = set_[id]
	if set then
		set.state = SchedulerSet.STATE_RUN
	end
end

function SchedulerSet.getSetById(id)
	return set_[id]
end

function SchedulerSet.remove(schedulerIndex)
	if not schedulerIndex then return end
	set_[schedulerIndex] = nil
end

function SchedulerSet.destroy()
	set_ = {}
	if scheduler_ then
		scheduler.unscheduleGlobal(scheduler_)
		scheduler_ = nil
	end
end
