--[[
	挂件数据配置表
--]]
local s_pendant = require("app.data.s_pendant")
local s_portrait = require("app.data.s_portrait")

local db_pendant_ = nil
local db_portrait_ = nil
local db_pendantCount_ = 0
PendantMO = {}

PENDANT_TYPE_LEVEL = 1
PENDANT_TYPE_VIP = 2
PENDANT_TYPE_CROSS = 3 --跨服

PendantMO.PORTRAIT_MAX_ID = 46

function PendantMO.init()
	db_pendant_ = {}
	db_pendantCount_  = 0
	local records = DataBase.query(s_pendant)
	for index = 1, #records do
		local data = records[index]
		db_pendant_[data.pendantId] = data
		db_pendantCount_ = db_pendantCount_ + 1
	end

	PendantMO.PORTRAIT_MAX_ID = 0
	db_portrait_ = {}
	local records = DataBase.query(s_portrait)
	for index = 1, #records do
		local data = records[index]
		db_portrait_[data.id] = data
		if data.id > PendantMO.PORTRAIT_MAX_ID then
			PendantMO.PORTRAIT_MAX_ID = data.id
		end
	end
end

function PendantMO.queryPendantById(id)
	return db_pendant_[id]
end

function PendantMO.queryPortrait(id)
	return db_portrait_[id]
end

function PendantMO.queryMaxPendant()
	return db_pendantCount_
end

function PendantMO.queryPortraits()
	local group = {}
	for i,v in pairs(db_portrait_) do
		if (v.cansee == 0 and PendantBO.portraits_[v.id]) or v.cansee == 1 then
			if not group[v.type] then
				group[v.type] = {}
			end
			table.insert(group[v.type],v)
		end
	end
	for k,v in ipairs(group) do
		table.sort(v,function ( a,b )
			return a.id < b.id
		end)
	end
	return group
end

function PendantMO.queryPendants()
	local group = {}
	for i,v in pairs(db_pendant_) do
		if v.pendantId > 0 then
			if (v.cansee == 0 and PendantBO.pendants_[v.pendantId]) or v.cansee == 1 then
				if not group[v.type] then
					group[v.type] = {}
				end
				table.insert(group[v.type],v)
			end
		end
	end
	for k,v in ipairs(group) do
		table.sort(v,function ( a,b )
			return a.pendantId < b.pendantId
		end)
	end
	return group
end
