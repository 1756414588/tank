--
-- Author: gf
-- Date: 2015-09-08 11:09:16
--

local s_treasure = require("app.data.s_treasure")

LotteryMO = {}
LotteryMO.doLotteryTreasureChangeFightPoint = false

local db_treasure_ = nil

LotteryMO.LOTTERY_TYPE_HUANGBAO_SMALL = 1   --荒宝小
LotteryMO.LOTTERY_TYPE_HUANGBAO_MIDDLE = 2 	--荒宝中
LotteryMO.LOTTERY_TYPE_HUANGBAO_BIG = 3 	--荒宝大
LotteryMO.LOTTERY_TYPE_TANBAO_1 = 4 		--探宝单抽
LotteryMO.LOTTERY_TYPE_TANBAO_3 = 5 		--探宝3抽
LotteryMO.LOTTERY_TYPE_EQUIP_GREEN = 6 		--装备绿色单抽
LotteryMO.LOTTERY_TYPE_EQUIP_BLUE = 7 		--装备蓝色单抽
LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE = 8 	--装备紫色单抽
LotteryMO.LOTTERY_TYPE_EQUIP_PURPLE_9 = 9 	--装备紫色9抽


LotteryMO.LOTTERY_EQUIP_VIEW_GREEN = 1 		--装备绿色
LotteryMO.LOTTERY_EQUIP_VIEW_BLUE = 2 		--装备蓝色
LotteryMO.LOTTERY_EQUIP_VIEW_PURPLE = 3 	--装备紫色

--抽装备消耗金币
LotteryMO.LOTTERY_EQUIP_NEED = {20,100,300}
--抽装备活动折扣
LOTTERY_TYPE_EQUIP_PURPLE_DISCOUNT = 0.8
LOTTERY_TYPE_EQUIP_PURPLE9_DISCOUNT = 0.7
--探宝消耗
LotteryMO.LOTTERY_TREASURE_NEED = {1,3,15,45}

LotteryMO.runTickList = {}

LotteryMO.LotteryEquipData_ = {}

--普通探宝免费次数
LotteryMO.LotteryTreasureFree_ = 0

--高级探宝开启等级
LotteryMO.treasure3OpenLv = 15

function LotteryMO.init()
	db_treasure_ = {}
	local records = DataBase.query(s_treasure)
	for index = 1, #records do
		local data = records[index]
		db_treasure_[data.id] = data
	end

	LotteryMO.LotteryEquipData_ = {}
	--普通探宝免费次数
	LotteryMO.LotteryTreasureFree_ = 0
end

-- 探宝奖励显示
function LotteryMO.getTreasure(id)
	return db_treasure_[id]
end

function LotteryMO.getLotteryDataByType(type)
	for index = 1,#LotteryMO.LotteryEquipData_ do
		if LotteryMO.LotteryEquipData_[index].lotteryId == type then
			return LotteryMO.LotteryEquipData_[index]
		end
	end
end