
local s_equip = require("app.data.s_equip")
local s_equip_lv = require("app.data.s_equip_lv")
local s_equip_attr = require("app.data.s_equip_bonus_attribute")
local s_equip_star = require("app.data.s_equip_upstar")

local db_equip_ = nil
local db_equip_level_ = nil  -- 按照装备品质和等级
local db_equip_attr_ = nil  -- 套装属性
local db_equip_equipId_ = nil
local db_equip_star_ = nil --装备星级

-- 阵型每个位置有装备的数量
FIGHT_EQUIP_POS_NUM = 6

EQUIP_POS_ATK     = 1  -- 攻击
EQUIP_POS_HP      = 2  -- 生命
EQUIP_POS_HIT     = 3 -- 命中
EQUIP_POS_DODGE   = 4 -- 闪避
EQUIP_POS_CRIT    = 5 -- 暴击
EQUIP_POS_CRIT_DEF = 6 -- 抗暴

EquipMO = {}

EQUIP_CAPACITY_MAX_TIME = 10 -- 仓库扩容的最大次数
-- EQUIP_CAPACITY_TAKE_COIN = 10  -- 装备扩容消耗金币数
EQUIP_CAPACITY_DELTA_NUM = 20  -- 装备增加的容量

EQUIP_BLUE_SUIT_ADD = 5 -- 蓝色套装加成系数
EQUIP_PURPLE_SUIT_ADD = 10  --

-- 所有的装备
EquipMO.equip_ = {}

-- 装备位置安装装备的信息
EquipMO.equipData_ = {}

-- 是否重新检查 装备
EquipMO.reCheck = 0

function EquipMO.init()
	db_equip_ = {}
	db_equip_equipId_ = {}
	local records = DataBase.query(s_equip)
	for index = 1, #records do
		local equip = records[index]
		db_equip_[equip.equipId] = equip
		db_equip_equipId_[equip.equipId] = equip
	end

	db_equip_level_ = {}
	local records = DataBase.query(s_equip_lv)
	for index = 1, #records do
		local equipLevel = records[index]

		if not db_equip_level_[equipLevel.quality] then db_equip_level_[equipLevel.quality] = {} end

		if equipLevel.level == 0 then
			-- 等级0忽略
		else
			db_equip_level_[equipLevel.quality][equipLevel.level] = equipLevel
		end
	end
	db_equip_attr_ = {}
	local records = DataBase.query(s_equip_attr)
	for index = 1, #records do
		local attr = records[index]
		if not db_equip_attr_[attr.quality] then
			db_equip_attr_[attr.quality] = {}
		end
		table.insert(db_equip_attr_[attr.quality],attr)
	end

	db_equip_star_ = {}
	local records = DataBase.query(s_equip_star)
	for index = 1, #records do
		local equip = records[index]
		db_equip_star_[equip.keyId] = equip
	end

	for index = 1, FIGHT_FORMATION_POS_NUM do
		EquipMO.equipData_[index] = {}
	end
end

function EquipMO.getAttr()
	return db_equip_attr_
end

function EquipMO.queryEquipById(equipId)
	if not equipId or equipId <= 0 then
		gprint("[EquipMO] queryEquipById id is Error:", tankId)
		error("EquipMO:queryEquipById() - id is Error")
	end
	if not db_equip_[equipId].starLv then --赋值星级默认都为0
		db_equip_[equipId].starLv = 0
	end
	return db_equip_[equipId]
end

function EquipMO.queryEquipLevel(quality, equipLv)
	if not db_equip_level_[quality] then return nil end
	return db_equip_level_[quality][equipLv]
end

function EquipMO.queryMaxLevelByQuality(quality)
	return #db_equip_level_[quality]
end

-- 根据装备的id获得装备所在的位置
function EquipMO.getPosByEquipId(equipId)
	local equipPos = math.floor(equipId / 100)
	if equipPos > FIGHT_EQUIP_POS_NUM then return 0
	else return equipPos end
end

function EquipMO.getEquipByKeyId(keyId)
	return EquipMO.equip_[keyId]
end

function EquipMO.getKeyIdAtPos(formatIndex, equipPos)
	if not EquipMO.equipData_[formatIndex] then return 0 end
	return EquipMO.equipData_[formatIndex][equipPos]
end

-- 获得所有还没有装上的装备
function EquipMO.getFreeEquipsAtPos(equipPos)
	local ret = {}
	for keyId, equip in pairs(EquipMO.equip_) do
		if equip.formatPos == 0 then
			local pos = EquipMO.getPosByEquipId(equip.equipId)
			if equipPos == nil or pos == equipPos then
				ret[#ret + 1] = equip
			end
		end
	end
	return ret
end

-- 获得所有装备id是equipId的空闲装备
function EquipMO.getFreeEquipsById(equipId)
	local ret = {}
	for keyId, equip in pairs(EquipMO.equip_) do
		if equip.formatPos == 0 and equip.equipId == equipId and equip.level == 1 then
			ret[#ret + 1] = equip
		end
	end
	return ret
end

-- 获得所有可以装备的空闲装备
function EquipMO.getFreeCanEquips()
	local ret = {}
	for keyId, equip in pairs(EquipMO.equip_) do
		if equip.formatPos == 0 then
			local pos = EquipMO.getPosByEquipId(equip.equipId)
			if pos ~= 0 then
				ret[#ret + 1] = equip
			end
		end
	end
	return ret
end

-- keyId代表的装备升级可以用来吸收的装备
function EquipMO.getCanUseUpgradeEqups(keyId)
	-- local equip = EquipMO.getEquipByKeyId(keyId)
	-- local equipPos = EquipMO.getPosByEquipId(equip.equipId)
	local equips = EquipMO.getFreeEquipsAtPos()
	local findIndex = 0

	for index = 1, #equips do
		if equips[index].keyId == keyId then
			findIndex = index
			break
		end
	end
	if findIndex > 0 then
		table.remove(equips,findIndex)
	end
	return equips
end

function EquipMO.removeEquipByKeyId(keyId)
	local equip = EquipMO.getEquipByKeyId(keyId)
	if not equip then
		gprint("[EquipMO] removeEquipByKeyId Error!!! 1")
		return
	end

	if equip.formatPos ~= 0 then  -- 装备被装上了
		gprint("[EquipMO] removeEquipByKeyId Error!!! 2")
		return
	end
	--TK统计 装备消耗
	TKGameBO.onEvnt(TKText.eventName[8], {equipId = equip.equipId})

	EquipMO.equip_[keyId] = nil
end

-- 装备添加经验
-- quality: 装备的品质
-- curLevel: 装备当前等级
-- curExp: 装备当前等级的经验值
-- addExp: 装备添加的经验值
-- 返回新的等级，以及新的经验值
function EquipMO.addExp(quality, curLevel, curExp, addExp)
	local maxLevel = EquipMO.queryMaxLevelByQuality(quality)
	local newExp = curExp + addExp

	if curLevel >= maxLevel then
		return curLevel, newExp
	end
	
	local needExp = EquipMO.queryEquipLevel(quality, curLevel + 1).needExp

	while newExp >= needExp do  -- 升级了
		curLevel = curLevel + 1
		newExp = newExp - needExp

		-- 达到装备的上限
		if curLevel >= maxLevel then
			return curLevel, newExp
		end

		needExp = EquipMO.queryEquipLevel(quality, curLevel + 1).needExp
	end

	return curLevel, newExp
end

--进阶后装备等级
function EquipMO.getAdvanceLv(keyId)
	local equip = EquipMO.getEquipByKeyId(keyId)
	local equipDB = EquipMO.queryEquipById(equip.equipId)
	local exp = equip.exp
	for i=1,equip.level do
		exp = exp + EquipMO.queryEquipLevel(equipDB.quality, i).needExp
	end
	local lv = 1
	local upExp = EquipMO.queryEquipLevel(equipDB.quality+1, lv+1).needExp
	while exp >= upExp do
		exp = exp - upExp
		lv = lv + 1
		local eb = EquipMO.queryEquipLevel(equipDB.quality+1, lv+1)
		if not eb then
			return lv
		end
		upExp = eb.needExp
	end
	return lv
end

--装备套装属性
function EquipMO.getShowSuit(formatPos)
	-- 当前激活套装效果
	local contents = {}
	table.insert(contents,{{content = CommonText[413][1],color = COLOR[12]}})

	local attrs,nums = EquipBO.getSuitAttr(formatPos)
	if #attrs > 0 then
		for k,v in ipairs(attrs) do
			table.insert(contents,{{content = "  "..v.name,color = COLOR[v.quality]},{content=CommonText[413][4]}})
		end
	else
		table.insert(contents,{{content = "  "..CommonText[108]}})
	end
	--套装列表
	table.insert(contents,{{content = CommonText[413][2],color = COLOR[12]}})

	for i=3,5 do
		for k,v in ipairs(EquipMO.getAttr()[i]) do
			local own = nums[v.quality] or 0
			table.insert(contents,{{content = "  "..CommonText.color[v.quality][2]..v.number ..CommonText[237][5]},{content = v.name,color = COLOR[v.quality]},
				{content=v.dec,color=own>=v.number and cc.c3b(255,255,255) or cc.c3b(115,115,115)},{content="("},{content=own.."",color=COLOR[2]},{content= "/" ..v.number ..")"}})
		end
	end
	--套装说明
	table.insert(contents,{{content = CommonText[20156],color = COLOR[12]}})
	table.insert(contents,{{content = CommonText[20155][2]}})
	table.insert(contents,{{content = CommonText[20155][3]}})

	return contents
end

-- (80级装备补丁) 检查是否有超经验值装备 
function EquipMO.selectNextProEquip(equipId , level , curExp)
	local nextLevel = level + 1
	local quality = db_equip_equipId_[equipId].quality
	local data = db_equip_level_[quality][nextLevel]

	if data == nil then return EquipMO.reCheck end
	local maxexp = data.needExp
	if curExp >= maxexp then
		return EquipMO.reCheck + 1
	else
		return EquipMO.reCheck
	end
end

--装备星级信息
function EquipMO.queryEquipStarsById(keyId)
	return db_equip_star_[keyId]
end

--获得所有ID相同的装备
function EquipMO.getEquipById(equipId)
	local ret = {}
	local freeEquips = EquipMO.getFreeEquipsAtPos()
	for index=1,#freeEquips do
		if freeEquips[index].equipId == equipId then
			ret[#ret + 1] = freeEquips[index]
		end
	end

	return ret
end

--获取所有装备等级总和
function EquipMO.getAllPosedEquipLv()
	local data = EquipMO.equipData_
	local lv = 0
	for index=1,#data do
		local record = data[index]
		for num=1,#record do
			local keyId = record[num]
			if keyId > 0 then
				local equip = EquipMO.getEquipByKeyId(keyId)
				lv = lv + equip.level
			end
		end
	end

	return lv
end

--获取所有装备星级等级总和
function EquipMO.getAllPosedEquipStarLv()
	local data = EquipMO.equipData_
	local lv = 0
	for index=1,#data do
		local record = data[index]
		for num=1,#record do
			local keyId = record[num]
			if keyId > 0 then
				local equip = EquipMO.getEquipByKeyId(keyId)
				lv = lv + equip.starLv
			end
		end
	end

	return lv
end