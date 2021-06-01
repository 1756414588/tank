--
-- Author: Xiaohang
-- Date: 2016-08-10 14:52:50
--
ExerciseMO = {}

local s_redblue_buff = require("app.data.s_redblue_buff")
local s_redblue_shop = require("app.data.s_redblue_shop")
local db_redblue_buff_ = nil
local db_redblue_shop_ = nil

function ExerciseMO.inApplyTime()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	if (week == 2) and (h < 20 or h == 20 and m <30) then 
		return true
	end
end

function ExerciseMO.inPrepareTime()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	if (week == 2) and h == 20 and (m >=30 and m <55) then 
		return true
	end
end

function ExerciseMO.refreshTime()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	if (week == 2) and h == 21 
		and (m == 0 or m == 10 or m == 20 or m == 30) and s == 0 then 
		return true
	end
end

--检查活动结束
function ExerciseMO.checkEnd()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	if week == 2 and h == 21 and m == 30 and s == 1 then 
		--清空演习阵型
		for index = FORMATION_FOR_EXERCISE1,FORMATION_FOR_EXERCISE3 do
			TankMO.formation_[index] = TankMO.getEmptyFormation()
		end
	end
end

function ExerciseMO.getState(state)
	local label = ""
	local c = COLOR[2]
	if state == 0 then
		label = CommonText[411]
		c = COLOR[6]
	elseif state == 1 then
		label = CommonText[827][1]
	elseif state == 2 then
		label = CommonText[20096]
	elseif state == 3 then
		label = CommonText[20023]
	elseif state == 4 then
		label = CommonText[20067][1]..CommonText[20015]
	elseif state == 5 then
		label = CommonText[20067][2]..CommonText[20015]
	elseif state == 6 then
		label = CommonText[20067][3]..CommonText[20015]
	elseif state == 7 then
		label = CommonText[871]
		c = COLOR[6]
	end
	return label,c
end

function ExerciseMO.init()
	db_redblue_buff_ = {}
	local records = DataBase.query(s_redblue_buff)
	for index = 1, #records do
		local data = records[index]
		if not db_redblue_buff_[data.buffId] then
			db_redblue_buff_[data.buffId] = {}
		end
		db_redblue_buff_[data.buffId][data.lv] = data
	end

	db_redblue_shop_ = {}
	local records = DataBase.query(s_redblue_shop)
	for index = 1, #records do
		local data = records[index]
		if not db_redblue_shop_[data.treasure] then
			db_redblue_shop_[data.treasure] = {}
		end
		table.insert(db_redblue_shop_[data.treasure],data)
	end
end

function ExerciseMO.getBuffs()
	return db_redblue_buff_
end

function ExerciseMO.getShop(kind)
	return db_redblue_shop_[kind]
end

function ExerciseMO.getImage(id)
	local bg = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
	local view = display.newSprite("image/item/redblue_" .. id .. ".jpg")
		:addTo(bg):center()
	view:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	display.newSprite(IMAGE_COMMON .. "item_fame_" .. 1 .. ".png"):addTo(bg, 6):center()
	return bg
end

function ExerciseMO.queryBuffById(id,level)
	level = level or 0
	return db_redblue_buff_[id][level]
end

function ExerciseMO.queryShopById(id,kind)
	kind = kind or 0
	return db_redblue_shop_[id]
end
