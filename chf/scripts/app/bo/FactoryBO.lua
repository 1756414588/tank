
-- 具有生产功能的建筑BO

QUEUE_STATE_PRODUCTING = 1 -- 队列状态为正在生产
QUEUE_STATE_WAIT       = 0 -- 队列状态为等待

FactoryBO = {}

-- 获得建筑buildingId的生产队列数组
function FactoryBO.orderProduct(buildingId)
	if not BuildMO.buildData_[buildingId] then return end

	local ret = {}
	local queue = BuildMO.buildData_[buildingId].productQueue
	for schedulerId, data in pairs(queue) do
		ret[#ret + 1] = schedulerId
	end

	local function order(idA, idB)
		local sA = SchedulerSet.getSetById(idA)
		local sB = SchedulerSet.getSetById(idB)
		if sA and not sB then return true
		elseif not sA and sB then return false
		elseif sA.state == SchedulerSet.STATE_RUN and sB.state == SchedulerSet.STATE_RUN then
			if sA.period > sB.period then return false
			else return true end
		elseif sA.state == SchedulerSet.STATE_RUN then return true
		elseif sB.state == SchedulerSet.STATE_RUN then return false
		else
			if sA.period < sB.period then return true
			else return false end
		end
	end

	table.sort(ret, order)

	return ret
end

function FactoryBO.isProducting(buildingId)
	local queue = BuildMO.buildData_[buildingId].productQueue
	for schedulerId, data in pairs(queue) do
		local set = SchedulerSet.getSetById(schedulerId)
		if set and set.state == SchedulerSet.STATE_RUN then
			return true
		end
	end
end

function FactoryBO.getWaitProducts(buildingId)
	if not BuildMO.buildData_[buildingId] then return {} end

	local ret = {}
	
	local queue = BuildMO.buildData_[buildingId].productQueue
	for schedulerId, data in pairs(queue) do
		local set = SchedulerSet.getSetById(schedulerId)
		if set and set.state == SchedulerSet.STATE_WAIT then
			ret[#ret + 1] = schedulerId
		end
	end
	return ret
end

function FactoryBO.getProductData(buildingId, schedulerId)
	if not BuildMO.buildData_[buildingId] then return end

	local queue = BuildMO.buildData_[buildingId].productQueue
	for id, data in pairs(queue) do
		if id == schedulerId then
			local data = SchedulerSet.getSetById(schedulerId)
			return clone(data)
			-- return {buildingId = data.buildingId, keyId = data.keyId, tankId = data.tankId, count = data.count, state = data.state}
		end
	end
	return nil
end

-- buildingId添加生产的任务schedulerId
function FactoryBO.addSchedulerProduct(buildingId, schedulerId)
	-- gprint("要添加了", buildingId)
	if not BuildMO.buildData_[buildingId] then return end

	local data = {}
	data.schedulerId = schedulerId
	data.buildingId = buildingId

	BuildMO.buildData_[buildingId].productQueue[schedulerId] = data

	gdump(BuildMO.buildData_[buildingId].productQueue, "[FactoryBO] addSchedulerProduct")
end

function FactoryBO.removeSchdulerProduct(buildingId, schedulerId)
	if not BuildMO.buildData_[buildingId] then return end

	SchedulerSet.remove(schedulerId)
	BuildMO.buildData_[buildingId].productQueue[schedulerId] = nil
end

function FactoryBO.clearAllProduct(buildingId)
	if not BuildMO.buildData_[buildingId] then return end

	local schedulerIds = BuildMO.buildData_[buildingId].productQueue
	for schedulerId, data in pairs(schedulerIds) do
		SchedulerSet.remove(schedulerId)
	end

	BuildMO.buildData_[buildingId].productQueue = {}
end

-- 获得buildingId的某个生产任务schedulerId的剩余时间
function FactoryBO.getProductTime(buildingId, schedulerId)
	if not BuildMO.buildData_[buildingId] then return end

	local productData = BuildMO.buildData_[buildingId].productQueue[schedulerId]
	if productData then
		return SchedulerSet.getTimeById(productData.schedulerId)
	else
		return 0
	end
end

-- 获得buildingId当前某种生产状态下的队列的数量。默认是返回所有的生产队列。
function FactoryBO.getProductNum(buildingId, state)
	if not BuildMO.buildData_[buildingId] then return 0 end

	if state == nil then
		return table.nums(BuildMO.buildData_[buildingId].productQueue)
	else
		return nil
	end
end