--
-- Author: 
-- Date: 
-- 数据访问工具

DataBase = {}

-- 根据条件conds在表ctable中取记录
-- 注：本方法是逐条的在表中查询，所以效率低。如果数据量大，而查询频繁，需要上层进行数据缓存优化
-- conds:{{'title', '=', 'value'}}
local function getRecords(ctable, conds)
	-- dump(ctable, "ctable-------")
	-- dump(conds, "conds-------")

	if not ctable then return nil end

	if not conds or #conds <= 0 then return ctable.records end -- 没有条件，则返回所有的数据

	local indies = {}

	-- 找到所有条件属性对应的表中的索引
	for indexCond = 1, #conds do
		for index = 1, #ctable.title do
			if ctable.title[index] == conds[indexCond][1] then
				indies[indexCond] = index
			end
		end

		if indies[indexCond] == nil then  -- 没有找到当前条件对应的表中的列索引
			print("DataBase.lua getRecords 查询中有无法匹配的字段 Error ==> ", conds[indexCond][1])
			indies = {}
			break
		end
	end

	-- dump(indies, "indies-------")

	if #indies <= 0 then return nil end -- 要求的条件字段在表中不存在

	local records = {}

	-- dump(ctable.records, "????")

	-- for index = 1, #ctable.records do
	for key, rcd in pairs(ctable.records) do
		-- local rcd = ctable.records[index]
		-- dump(rcd, "????")

		local isOk = true

		for indexCond = 1, #conds do
			if conds[indexCond][2] == "=" then -- 是需要求相等的
				if rcd[indies[indexCond]] ~= conds[indexCond][3] then  -- 值相等
					isOk = false
					break
				end
			elseif conds[indexCond][2] == ">" then -- 是需要大于的
				if rcd[indies[indexCond]] <= conds[indexCond][3] then  -- 值小于等于的，不符合要求
					isOk = false
					break
				end
			elseif conds[indexCond][2] == ">=" then -- 是需要大于等于的
				if rcd[indies[indexCond]] < conds[indexCond][3] then  -- 值小于等于的，不符合要求
					isOk = false
					break
				end
			elseif conds[indexCond][2] == "<" then -- 是需要小于的
				if rcd[indies[indexCond]] >= conds[indexCond][3] then  -- 值大于等于的，不符合要求
					isOk = false
					break
				end
			elseif conds[indexCond][2] == "<=" then -- 是需要小于的
				if rcd[indies[indexCond]] > conds[indexCond][3] then  -- 值大于等于的，不符合要求
					isOk = false
					break
				end
			else
				isOk = false
				print("DataBase.lua getRecords 查询条件要求是 Error ==> ", conds[indexCond][2])
			end
		end

		if isOk then
			table.insert(records, rcd)
		end
	end

	-- dump(records, "records--------")

	if #records <= 0 then return nil end

	return records
end

--转换记录为数据对象
local function combineRecord(ctable, record)
	if not record then return nil end

	local data = {}
	for i = 1, #ctable.title do
		data[ctable.title[i]] = record[i]
	end
	return data
end

-- 按照条件conds的方式在表ctable中查询，结果以数组的形式返回
function DataBase.query(ctable, conds)
	local records = getRecords(ctable, conds)

	if not records then return nil end

	if records then
		local arr = {}
		for index = 1, #records do
			arr[index] = combineRecord(ctable, records[index])
		end
		return arr
	end
end

--取单条记录记录
--[[
	@param cond  {prop="heroId", value=1}
]]
-- function DataBase.queryOne(ctable, cond)
-- 	local record = getRecord(ctable, cond, false)
-- 	return combineRecord(ctable, record)
-- end

--取符合条件的所有记录
-- function DataBase.queryAll(ctable, cond)
-- 	local records = getRecord(ctable, cond, true)
-- 	if records then
-- 		local arr = {}
-- 		for i = 1, #records do
-- 			arr[i] = combineRecord(ctable, records[i])
-- 		end
-- 		return arr
-- 	end
-- end

--取map表的记录
-- function DataBase.queryMap(ctable, key)
-- 	local record = ctable.records[key]
-- 	return combineRecord(ctable, record)
-- end

-- function DataBase.queryMapAll(ctable, cond)
-- 	local arr = {}

-- 	for i = 1, #ctable.title do
-- 		if ctable.title[i] == cond['prop'] then
-- 			index = i
-- 			break
-- 		end
-- 	end
-- 	for k, v in pairs(ctable.records) do
-- 		if v[index] == cond['value'] then
-- 			table.insert(arr, combineRecord(ctable, v))
-- 		end
-- 	end
-- 	return arr
-- end