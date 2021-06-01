--
-- Author: Xiaohang
-- Date: 2016-09-07 17:01:03
--
RebelMO = {}
RebelMO.OPEN = 8 --开服8天开启
local s_rebel_team = require("app.data.s_rebel_team")
local s_act_rebel_team = require("app.data.s_act_rebel_team")
local s_rebel_hero_push = require("app.data.s_rebel_hero_push")
local s_act_rebel = require("app.data.s_act_rebel")
local d_rebel_team = nil
local d_act_rebel_team = nil
local d_rebel_hero_push = nil
local d_act_rebel_ = {}

local openDate = {}
local openTime = {}

function RebelMO.init()
	d_rebel_team = {}
	local records = DataBase.query(s_rebel_team)
	for index = 1, #records do
		local data = records[index]
		d_rebel_team[data.rebelId] = data
	end

	d_rebel_hero_push = {}
	local records = DataBase.query(s_rebel_hero_push)
	for index = 1, #records do
		local data = records[index]
		d_rebel_hero_push[data.heroPick] = data
	end

	d_act_rebel_team = {}
	local records = DataBase.query(s_act_rebel_team)
	for index = 1, #records do
		local data = records[index]
		d_act_rebel_team[data.rebelId] = data
	end

	local records = DataBase.query(s_act_rebel)
	for index = 1, #records do
		local data = records[index]
		d_act_rebel_[data.id] = data
	end

	openDate = {}
	local _openDate = string.split(UserMO.querySystemId(2), ",")
	for k, v in ipairs(_openDate) do openDate[#openDate + 1] = tonumber(v) end
	local _openTime = string.split(UserMO.querySystemId(3), ",")
	openTime = {}
	for index = 1, #_openTime do
		local time = string.split(_openTime[index], ":")
		openTime[#openTime + 1] = tonumber(time[1])
	end
end

function RebelMO.queryActId(id)
	return d_act_rebel_[id]
end

function RebelMO.getTeamById(id)
	return d_act_rebel_team[id]
end

function RebelMO.checkDay(showTip)
	if UserMO.openServerDay < RebelMO.OPEN then
		if showTip then
			Toast.show(string.format(CommonText[20128], RebelMO.OPEN))
		end
		return false
	end
	return true
end

function RebelMO.checkOpen()
	if not RebelMO.checkDay() then return false end
	local t = ManagerTimer.getTime()
	local week = tonumber(os.date("%w",t))
	local h = tonumber(os.date("%H", t))
	local m = tonumber(os.date("%M", t))
	if week == 0 then week = 7 end
 	for index = 1, #openDate do
		local _date = openDate[index]
		if (week == _date) and (h == openTime[1] or h == openTime[2]) and m <= 59 then
			return true
		end
	end
	return false
end

function RebelMO.queryHeroById(heroPick)
	return d_rebel_hero_push[heroPick]
end

function RebelMO.getShowTank(rebelId)
	local hd = d_rebel_team[rebelId]
	for i=1,6 do
		if hd["team"..i.."Id"] > 0 and hd["team"..i.."number"] > 0 then
			return hd["team"..i.."Id"]
		end
	end
end

--掉落信息
function RebelMO.getDropList(rebelId,heroPick)
	local list = {}
	local tb = heroPick == -2 and d_act_rebel_team or d_rebel_team
	local hd = tb[rebelId]
	table.insert(list,{ITEM_KIND_EXP,hd.heroDrop,hd.exp})
	for k,v in ipairs(json.decode(hd.drop)) do
		table.insert(list,{v[1],v[2],v[3]})
	end
	if heroPick ~= -2 then
		hd = d_rebel_hero_push[heroPick]
		table.insert(list,{ITEM_KIND_HERO,hd.heroDrop,hd.limitation})
	end
	return list
end

--战斗力
function RebelMO.getFight(rebelId,heroPick)
	if heroPick == -2 then
		return UiUtil.strNumSimplify(d_act_rebel_team[rebelId].fight)
	end
	local hd = d_rebel_hero_push[heroPick]
	local fight = hd.fight
	hd = d_rebel_team[rebelId]
	fight = fight + hd.fight
	return UiUtil.strNumSimplify(fight)
end

function RebelMO.getImage(heroPick)
	if heroPick == -2 then
		local t = display.newSprite(IMAGE_COMMON.."btn_head_normal.png"):scale(0.6)
		display.newSprite(IMAGE_COMMON.."bandit.jpg"):addTo(t):center()
		return t
	end
	local rd = RebelMO.queryHeroById(heroPick)
	local hd = HeroMO.queryHero(rd.associate)
	local t = UiUtil.createItemSprite(ITEM_KIND_HERO, rd.associate)
	UiUtil.sprite9("item_fame_".. math.floor((hd.star-1)/2)+2 ..".png", 20, 20, 62, 62,t:width(),t:height()):addTo(t):center()
	return t
end