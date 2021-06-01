--
-- Author: gf
-- Date: 2015-09-01 11:37:15
--

local s_hero = require("app.data.s_hero")
-- local s_hero_addition = require("app.data.s_hero_addition")
-- local s_hero_skill = require("app.data.s_hero_skill")
local s_cost = require("app.data.s_cost")
local s_awards = require("app.data.s_awards")
local s_awake_skill = require("app.data.s_hero_awaken_skill")
local s_awake_fali = require("app.data.s_hero_awaken_failure")

HeroMO = {}

HERO_TYPE_CIVILIAN = 1 -- 文官
HERO_TYPE_MILITARY = 2 -- 武将

DECOMPOSE_TYPE_HERO = 1 --单个分解
DECOMPOSE_TYPE_BATCH = 2 --批量分解

HERO_ID_COMMAND = 101 -- 统率官
HERO_ID_REFIT_SIR = 103
HERO_ID_PRODUCT_SIR = 104 -- 生产官
HERO_ID_SCIENCE_SIR = 105
HERO_ID_REFIT_SOLDIER = 106
HERO_ID_PRODUCT_SOLDIER = 107 -- 生产兵
HERO_ID_SCIENCE_SOLDIER = 108
HERO_ID_MEDAL_SOLDIER = 109 --勋章军需官

HERO_STAFF_PRODUCT = 1  --生产官
HERO_STAFF_REFINE  = 2  --改造官
HERO_STAFF_SCIENCE = 3  --科技官

HERO_SKILL_TANKCOUNT_ID = 15
-- TOFIX: correct this id
HERO_SKILL_TANKPAYLOAD_ID = 23

HERO_SKILL_EF_TANKCOUNT = 6
HERO_SKILL_EF_TANKPAYLOAD = 8


--我方所有将领
HeroMO.heros_ = {
	-- {keyId = 1,heroId = 88, count = 1},
	-- {keyId = 2,heroId = 49, count = 2},
	-- {keyId = 3,heroId = 41, count = 3},
	-- {keyId = 4,heroId = 43, count = 4},
	-- {keyId = 5,heroId = 45, count = 5},
	-- {keyId = 6,heroId = 18, count = 6},
	-- {keyId = 8,heroId = 1, count = 3},
	-- {keyId = 9,heroId = 2, count = 3},
	-- {keyId = 10,heroId = 3, count = 3},
	-- {keyId = 11,heroId = 4, count = 3},
	-- {keyId = 12,heroId = 5, count = 3},
	-- {keyId = 13,heroId = 6, count = 3}
}
HeroMO.awakeHeros_ = {}  --所有可觉醒将领
--所有将领图鉴
HeroMO.heros_pic_ = {}

--玩家升阶的时候选择的武将
HeroMO.improve_heros_s = {}

--本日金币招募次数
HeroMO.coinCount = 0
--本日资源招募次数
HeroMO.resCount = 0

HeroMO.improve_need_propId = 59
HeroMO.improve_need_propCount = {1,2,5,10}

HeroMO.HERO_LOTTERY_TYPE_RES_1 = 1
HeroMO.HERO_LOTTERY_TYPE_RES_5 = 2
HeroMO.HERO_LOTTERY_TYPE_GOLD_1 = 3
HeroMO.HERO_LOTTERY_TYPE_GOLD_5 = 4

HeroMO.dirtyHeroData_ = false

local db_hero_ = nil
-- local db_hero_addition_ = nil
-- local db_skill_ = nil
local db_cost_ = nil
local db_awards_ = nil
local db_awake_skill_ = nil
local db_awake_skillNum_ = nil
local db_awake_failTip_ = nil

local fxzIgnore = {charge = {}, clear = {}}

-- 将领功能锁 添加 {风行者}
-- 置换表
local ignoreChargeId = {246, 260, 274, 288, 314, 331}
-- 删除表
local ignoreClearId = {352, 353, 354, 355, 356, 357}

function HeroMO.init()
	for index = 1 ,#ignoreChargeId do fxzIgnore.charge[ignoreChargeId[index]] = true end
	for index = 1 ,#ignoreClearId do fxzIgnore.clear[ignoreClearId[index]] = true end
	
	db_hero_ = nil
	db_cost_ = nil
	db_awards_ = nil
	db_awake_skill_ = nil
	db_awake_skillNum_ = nil
	db_awake_failTip_ = nil

	HeroMO.heros_ = {}
	--所有将领图鉴
	HeroMO.heros_pic_ = {}

	--玩家升阶的时候选择的武将
	HeroMO.improve_heros_s = {}

	-- 觉醒将领 功能锁
	local fxzFun = UserMO.queryFuncOpen(UFP_HERO_FXZ)
	local _index = 0
	if not db_hero_ then
		db_hero_ = {}

		local records = DataBase.query(s_hero)
		for index = 1, #records do
			_index = _index + 1

			local hero = records[index]
			db_hero_[hero.heroId] = hero

			if not fxzFun then
				if fxzIgnore.charge[hero.heroId] then
					db_hero_[hero.heroId].awakenHeroId = 0
					hero.awakenHeroId = 0
				end
				if fxzIgnore.clear[hero.heroId] then
					db_hero_[hero.heroId] = nil
					hero = nil
				end
			end

			if hero.picShow == 1 then
				HeroMO.heros_pic_[#HeroMO.heros_pic_ + 1] = hero
			end
		end
	end

	-- if not db_hero_addition_ then
	-- 	db_hero_addition_ = {}
	-- 	local records = DataBase.query(s_hero_addition)
	-- 	for index = 1, #records do
	-- 		local hero_addition = records[index]
	-- 		db_hero_addition_[hero_addition.additionId] = hero_addition
			
	-- 	end
	-- end

	-- if not db_skill_ then
	-- 	db_skill_ = {}
	-- 	local records = DataBase.query(s_hero_skill)
	-- 	for index = 1, #records do
	-- 		local skill = records[index]
	-- 		db_skill_[skill.skillId] = skill
			
	-- 	end
	-- end

	if not db_cost_ then
		db_cost_ = {}
		local records = DataBase.query(s_cost)
		for index = 1, #records do
			local cost = records[index]
			if not db_cost_[cost.costId] then db_cost_[cost.costId] = {} end
			db_cost_[cost.costId][cost.count] = cost
		end
	end

	if not db_awards_ then
		db_awards_ = {}
		local records = DataBase.query(s_awards)
		for index = 1, #records do
			local awards = records[index]
			db_awards_[awards.awardId] = awards
		end
	end

	--根据ID获取失败提示信息
	if not db_awake_failTip_ then
		db_awake_failTip_ = {}
		local records = DataBase.query(s_awake_fali)
		for index = 1, #records do
			local awards = records[index]
			db_awake_failTip_[awards.id] = awards
		end
	end

	--通过技能ID和等级读取对应的信息
	if not db_awake_skill_ then
		db_awake_skill_ = {}
		local records = DataBase.query(s_awake_skill)
		for index = 1, #records do
			local awards = records[index]
			if not db_awake_skill_[awards.id] then db_awake_skill_[awards.id] = {}	end
				db_awake_skill_[awards.id][awards.level] = awards
		end
	end
end


function HeroMO.queryHero(heroId)
	if not db_hero_[heroId] then return nil end
	return db_hero_[heroId]
end

-- function HeroMO.queryHeroAddition(additionId)
-- 	if not db_hero_addition_[additionId] then return nil end
-- 	return db_hero_addition_[additionId]
-- end

-- function HeroMO.querySkill(skillId)
-- 	if not db_skill_[skillId] then return nil end
-- 	return db_skill_[skillId]
-- end

function HeroMO.queryCost(costId, count)
	if count > 100 then count = 100 end
	if not db_cost_[costId] then return nil end
	return db_cost_[costId][count]
end

function HeroMO.queryAwards(awardId)
	if not db_awards_[awardId] then return nil end
	return db_awards_[awardId]
end
--通过ID获取到觉醒失败提示
function HeroMO.queryFailTips(id)
	if not db_awake_failTip_[id] then return nil end
	return db_awake_failTip_[id]
end
--获取失败信息提示的总数量
function HeroMO.queryFailTipsNum()
	local num = db_awake_failTip_
	return table.getn(num)
end
--通过ID和等级索取到觉醒技能信息
function HeroMO.queryAwakeSkillInfo(id,level)
	if not db_awake_skill_[id] then return nil end
	return db_awake_skill_[id][level]
end

--通过觉醒技能ID索取技能等级数
function HeroMO.queryAwakeSkillLevel(skillId)
	local skills = db_awake_skill_[skillId] or {}
	return table.getn(skills)
end

function HeroMO.queryHeroPicByStar(star)
	if star == 0 then return HeroMO.heros_pic_ end
	local heros = {}
	for index=1,#HeroMO.heros_pic_ do
		local hero = HeroMO.heros_pic_[index]
		if hero.star == star then
			heros[#heros + 1] = hero
		end
	end
	return heros
end

function HeroMO.queryHeroByStar(star)
	if star == 0 then return HeroMO.heros_ end
	local heros = {}
	for index=1,#HeroMO.heros_ do
		local hero = HeroMO.heros_[index]
		if hero.star == star then
			heros[#heros + 1] = hero
		end
	end
	return heros
end

--获取当前所有普通将最低的星级是几星星
function HeroMO.getLowestStar()
	if #HeroMO.heros_ > 0 then
		local star = {}
		for k,v in ipairs(HeroMO.heros_) do
			star[k] = v.star
		end
		local function sortFun(a,b)
			return a > b
		end
		table.sort(star,sortFun)
		return star[1]
	end
	return 0
end

--获取已觉醒将领信息
function HeroMO.queryCanAwakeHero(data)
	if not data or data == nil then return nil end
	local awakeHeros = {}
	for index =1,#data do
		if data[index].awakenHeroId > 0 then
			table.insert(awakeHeros,data[index].heroId)
		end
	end
	return awakeHeros
end

function HeroMO.getHeroById(heroId)
	if not heroId then return nil end

	for index = 1, #HeroMO.heros_ do
		if HeroMO.heros_[index].heroId == heroId then
			return HeroMO.heros_[index]
		end
	end
	--普通将领找不到，继续找觉醒将
	for k,v in pairs(HeroMO.awakeHeros_) do
		if v.heroId == heroId then
			return v
		end
	end
	return nil
end

-- 重新解析觉醒将领结构
function HeroMO.putAwakeHero(datalist)
	HeroMO.awakeHeros_ = {}
	for index = 1, #datalist do
		local data = datalist[index]
		if table.isexist(data,"skillLv") then
			data.skillLvPBInfo = HeroMO.PareSkill(data.skillLv) 
		end
		HeroMO.awakeHeros_[data.keyId] = data
	end
end

function HeroMO.PareSkill(skilllist)
	local list = PbProtocol.decodeArray(skilllist) 
	local out = {}
	for index = 1 , #list do
		local data = list[index]
		out[data.v1] = data.v2
	end
	return out
end

--通过觉醒将的KeyId索取到觉醒将的信息
function HeroMO.getHeroByKeyId(keyId)
	if not keyId then return nil end
	local info = HeroBO.getAwakeHeroByKeyId(keyId)
	if info ~= nil then
		return info
	end
	return nil
end

function HeroMO.queryHeroToInfo(data)
	local heros = {}
	if not data then return heros end
	
	for index=1,#data do
		local hero = HeroMO.queryHero(data[index].heroId) 
		if hero then
			hero.count = data[index].count
			hero.keyId = data[index].keyId
			hero.locked = false --data[index].locked
			if table.isexist(data[index], 'endTime') then
				hero.endTime = data[index].endTime / 1000
			end
			if table.isexist(data[index], 'cd') then
				hero.cd = data[index].cd / 1000
			end
			heros[#heros + 1] = hero
		end
	end
	return heros
end

-- 更新将领锁定列表
function HeroMO.updateHeroLock(data)
	if not data then return end

	-- local mysort = function (a,b)
	-- 	return a.heroId < b.heroId
	-- end

	-- table.sort(HeroMO.heros_ , mysort)
	-- table.sort(data)

	local lockedlist = {}
	for k,v in pairs(data) do
		lockedlist[v] = true
	end

	--local hIndex = 1

	for index=1,#HeroMO.heros_ do
		local hero = HeroMO.heros_[index]
		--local lockid = data[hIndex]
		if lockedlist[hero.heroId] then
			HeroMO.heros_[index].locked = true
			--hIndex = hIndex + 1
		end
	end
end

-- 判断将领是否被锁定
function HeroMO.IsLockById(heroId)
	if not heroId then return false end
	
	for index = 1, #HeroMO.heros_ do
		if HeroMO.heros_[index].heroId == heroId then
			return HeroMO.heros_[index].locked
		end
	end
	return false
end

-- 修改锁定命令
function HeroMO.setHeroLockById( heroId, isLock)
	if not heroId then return end

	for index = 1, #HeroMO.heros_ do
		if HeroMO.heros_[index].heroId == heroId then
			HeroMO.heros_[index].locked = isLock
		end
	end
end

--获取可上阵所有文官
function HeroMO.getStaffHeros(partId)
	local staffHeros = {}
	for index =1,#HeroMO.heros_ do
		local heroInfo = StaffMO.queryStaffHeroById(partId)
		local heroId  = json.decode(heroInfo.heroId)
		for idx =1,#heroId do
			if heroId[idx] == HeroMO.heros_[index].heroId then
				staffHeros[#staffHeros + 1] =  HeroMO.heros_[index]
			end
		end
	end
	return staffHeros
end

--得到所有的已经入驻的文官
function HeroMO.getPutStaffHeros()
	local putHeros = {}
	local staffHerosInfo = {}
	for index =1,#StaffMO.staffHerosData_ do
		local data = StaffMO.staffHerosData_[index].heroId
		for mmm = 1 ,#data do
			local d = data[mmm]
			if d ~= 0 then
				putHeros[#putHeros + 1] = d
			end
		end
	end
	staffHerosInfo = HeroMO.queryStaffHeroToInfo(putHeros)
	return staffHerosInfo
end

--根据id判断文官是否一入驻
function HeroMO.isStaffHeroPutById(heroId)
	if not heroId then return nil end
	if UserMO.queryFuncOpen(UFP_STAFF_CONFIG) then
		local hero = HeroMO.getPutStaffHeros()
		for index =1,#hero do
			if hero[index].heroId == heroId then
				return hero[index]
			end
		end
	else
		return HeroMO.getHeroById(heroId)
	end

	return nil
end

--根据所有入驻文官ID读表获取信息
function HeroMO.queryStaffHeroToInfo(data)
	local heros = {}
	if not data then return heros end
	
	for index=1,#data do
		local hero = HeroMO.queryHero(data[index]) 
		if hero then
			-- hero.count = data[index].count
			-- hero.keyId = data[index].keyId
			heros[#heros + 1] = hero
		end
	end
	return heros
end

--获得可加buff的文官
function HeroMO.getBuffHeros(partId)
	local staffHeros = {}
	local heroInfo = StaffMO.queryStaffHeroById(partId)
	local heroId  = json.decode(heroInfo.heroId)
	for index =1,#HeroMO.heros_ do
		for idx =1,#heroId do
			if heroId[idx] == HeroMO.heros_[index].heroId and HeroMO.isStaffHeroPutById(heroId[idx]) then
				staffHeros[#staffHeros + 1] =  HeroMO.heros_[index]
			end
		end
	end
	if heroInfo.fullSkill then
		local isall = true
		for index = 1, #heroId do
			if not staffHeros[index] then
				isall = false
			end
		end
		if isall then
			staffHeros = {}
			local hero_ = {skillValue = heroInfo.fullSkillValue}
			staffHeros[#staffHeros + 1] = hero_
		end
	end
	return staffHeros
end

--判断当前ID文官buff
function HeroMO.getStaffHeroById(heroId)
	if not heroId then return nil end
	local staffHeros = HeroMO.getBuffHeros(heroId)--HeroMO.getPutStaffHeros()
	local hero_ = nil
	for num =1,#staffHeros do
		local _heror = staffHeros[num]
		if not hero_ then
			hero_ = _heror
		else
			if _heror.skillValue >= hero_.skillValue then
				hero_ = _heror
			end
		end
	end
	return hero_
end

--文官已部署的数量
function HeroMO.getHeroStaffNum(heroId)
 	local num = 0
 	if HeroMO.isStaffHeroPutById(heroId) then
 		num = num + 1
 	end
 	return num
 end 

 -- 将领带兵量计算
function HeroMO.HeroForTankCount(heroId,awakeHeroKeyId)
 	local tankCount = 0
 	local heroDB = HeroMO.queryHero(heroId)
 	if heroDB.tankCount > 0 then
		tankCount = tankCount + heroDB.tankCount
	end

	local awakeHero = nil
	if awakeHeroKeyId then
		awakeHero = HeroMO.awakeHeros_[awakeHeroKeyId]
	end
	if awakeHero then
		if table.isexist(awakeHero, "skillLvPBInfo") then
			local awakeSkilllist = awakeHero.skillLvPBInfo
			for k, v in pairs(awakeSkilllist) do
				local skill = HeroMO.queryAwakeSkillInfo(k, v)
				if skill and skill.effectType == HERO_SKILL_EF_TANKCOUNT then
					tankCount = tankCount + skill.effectVal
				end
			end
		end
	end
	return tankCount
 end


function HeroMO.HeroForTankPayloadAdd(awakeHeroKeyId)
	-- 计算觉醒将领对坦克载重的加成
	local awakeVal = 0
	local awakeHero = nil
	if awakeHeroKeyId then
		awakeHero = HeroMO.awakeHeros_[awakeHeroKeyId]
	end
	if awakeHero then
		if table.isexist(awakeHero, "skillLvPBInfo") then
			local awakeSkilllist = awakeHero.skillLvPBInfo
			for k, v in pairs(awakeSkilllist) do
				local skill = HeroMO.queryAwakeSkillInfo(k, v)
				if skill and skill.effectType == HERO_SKILL_EF_TANKPAYLOAD then
					awakeVal = awakeVal + skill.effectVal
				end
			end
		end
	end
	return awakeVal * 0.01
end

function HeroMO.getNewHeroIgnoreAvoidWar()
	-- body
	local heros = HeroMO.heros_
	local skillCanUse = false
	local res = nil
	local minCD = nil
	for i, v in ipairs(heros) do
		if v.skillId == 22 and table.isexist(v, 'cd') then -- 判断是否有强攻技能
			local curTime = ManagerTimer.getTime()
			local skillCanUse = (curTime >= v.cd or v.cd == 0)
			local canFight = HeroBO.canHeroFight(v.heroId, nil)
			local overdue = false
			if v.endTime ~= nil then
				if v.endTime > 0 and curTime >= v.endTime then
					overdue = true
				end
			end

			if not overdue then -- 不能是过期的将领
				if skillCanUse and canFight then
					return v
				elseif canFight and not skillCanUse then
					local cdRemain = v.cd - curTime
					if res == nil then
						res = v
						minCD = cdRemain
					else
						-- 选一个剩余cd最短的将领
						if cdRemain < minCD then
							res = v
							minCD = cdRemain
						end
					end
				end
			end
		end
	end
	return res
end

function HeroMO.getShowHeroList(heroList)
	if not heroList then return end
	local newList = {}
	local herodData = clone(heroList)

	for index=1,#herodData do
		local data = herodData[index]
		if data.type == 2 then
			table.insert(newList,data)
		end
	end

	return newList
end

function HeroMO.queryFightHeroByStar(star)
	if star == 0 then return HeroMO.heros_ end
	local heros = {}
	for index=1,#HeroMO.heros_ do
		local hero = HeroMO.heros_[index]
		if hero.star == star and hero.type == 2 then --且是武将
			heros[#heros + 1] = hero
		end
	end
	return heros
end