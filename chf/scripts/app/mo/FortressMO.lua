
-- 要塞

FortressMO = {}

FortressMO.pos_ = cc.p(299, 299)

--各种时间
FortressMO.war_week = 0
FortressMO.war_starh = 20
FortressMO.war_starm = 0
FortressMO.war_last = 15
FortressMO.peace_week = 6
FortressMO.peace_endh = 19
FortressMO.peace_endm = 0
FortressMO.preheat_starh = 19
FortressMO.preheat_starhm = 30
FortressMO.preheat_last = 30

FortressMO.TIME_PICE    = 1 --和平时期
FortressMO.TIME_PREHEAT = 2 --预热时期
FortressMO.TIME_WAR     = 3 --战争时期

local IMG = {"attr_crit","attr_dodge","attr_tenacity","attr_score","activity_staff_exercise"}

local s_fortress_attr = require("app.data.s_fortress_attr")
local s_fortress_job = require("app.data.s_fortress_job")
local db_fortress_attr = nil
local db_fortress_job = nil

function FortressMO.init()
	db_fortress_attr = {}
	local records = DataBase.query(s_fortress_attr)
	for index = 1, #records do
		local data = records[index]
		if not db_fortress_attr[data.id] then
			db_fortress_attr[data.id] = {}
		end
		db_fortress_attr[data.id][data.level] = data
	end

	db_fortress_job = {}
	local records = DataBase.query(s_fortress_job)
	for index = 1, #records do
		local data = records[index]
		db_fortress_job[data.id] = data
	end
end

function FortressMO.getAttrs()
	return db_fortress_attr
end

function FortressMO.getJobs()
	return db_fortress_job
end

function FortressMO.queryAttrById(id,level)
	level = level or 0
	return db_fortress_attr[id][level]
end

function FortressMO.queryJobById(id)
	return db_fortress_job[id]
end

function FortressMO.getImage(id)
	local bg = display.newSprite(IMAGE_COMMON .. "item_bg_0.png")
	local view = display.newSprite("image/item/" .. IMG[id] .. ".jpg")
		:addTo(bg):center()
	view:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	display.newSprite(IMAGE_COMMON .. "item_fame_" .. 1 .. ".png"):addTo(bg, 6):center()
	return bg
end

function FortressMO.effectIng(effectId)
	local ef = EffectMO.getEffectById(effectId)
	if not ef or ef.leftTime <= 0 then return 0 end
	if effectId == 31 then
		return 10
	elseif effectId == 122 then
		return -10
	elseif effectId == 23 then
		return 5
	elseif effectId == 123 then
		return -10
	elseif effectId == 24 then
		return 5
	elseif effectId == 25 then
		return 5
	elseif effectId == 125 then
		return -10
	elseif effectId == 127 then
		return -50
	else
		return 0
	end
end

--获取带兵量
function FortressMO.takeNum()
	return FortressMO.effectIng(31) + FortressMO.effectIng(122)
end

--建筑加速
function FortressMO.buildSpeed()
	return FortressMO.effectIng(23) + FortressMO.effectIng(123)
end

--科技加速
function FortressMO.scienceSpeed()
	return FortressMO.effectIng(24)
end

--生产改造加速
function FortressMO.productSpeed()
	return FortressMO.effectIng(25) + FortressMO.effectIng(125)
end

--行军加速
function FortressMO.armySpeed()
	return FortressMO.effectIng(127)
end

function FortressMO.myJob()
	if not FortressBO.job_  or FortressBO.job_.endTime < ManagerTimer.getTime() then
		return 0
	end
	return FortressBO.job_.jobId
end

function FortressMO.getEffectValid()
	local ef = EffectMO.getEffectById(28)
	if ef and ef.leftTime>0 then
		return "+",ef.leftTime,5
	end
	ef = EffectMO.getEffectById(129)
	if ef and ef.leftTime>0 then
		return "-",ef.leftTime,10
	end
	ef = EffectMO.getEffectById(128)
	if ef and ef.leftTime>0 then
		return "-",ef.leftTime,10
	end
	return nil
end

--预热期和战争期
function FortressMO.inWar()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	if week == FortressMO.war_week and 
		((h == FortressMO.preheat_starh and m >= FortressMO.preheat_starhm) or
		(h == FortressMO.war_starh and m < FortressMO.war_starm + FortressMO.war_last)) then
		return true
	end
	return false
end

--和平期间
function FortressMO.inPeace()
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	local s = tonumber(os.date("%S", t))
	--和平时期 周日20:15 - 周六19:00 
	if (week > FortressMO.war_week and week < FortressMO.peace_week)
		or (week == FortressMO.peace_week and h<FortressMO.peace_endh)
		or (week == FortressMO.war_week and 
			((h==FortressMO.war_starh and m>=FortressMO.war_starm+FortressMO.war_last) or h>FortressMO.war_starh)) then
		return true
	end
	return false
end