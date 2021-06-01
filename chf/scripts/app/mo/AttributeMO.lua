
local s_attribute = require("app.data.s_attribute")

local db_attribute_ = nil

ATTRIBUTE_INDEX_HP = 1
ATTRIBUTE_INDEX_ATTACK = 3
ATTRIBUTE_INDEX_HIT = 5
ATTRIBUTE_INDEX_DODGE = 7
ATTRIBUTE_INDEX_CRIT = 9
ATTRIBUTE_INDEX_CRIT_DEF = 11
ATTRIBUTE_INDEX_IMPALE = 13
ATTRIBUTE_INDEX_DEFEND = 15
ATTRIBUTE_INDEX_TENACITY = 19
ATTRIBUTE_INDEX_BURST = 21
ATTRIBUTE_INDEX_FORTITUDE = 37
ATTRIBUTE_INDEX_FRIGHTEN = 39
ATTRIBUTE_INDEX_HURT = 17 --减伤
ATTRIBUTE_ADD_HURT = 34 --增伤

ATTRIBUTE_INDEX_PAYLOAD = 1000 -- 载重 目前仅客户端使用

ATTRIBUTE_INDEX_PAYLOAD0 = 1020 -- 全部载重
ATTRIBUTE_INDEX_PAYLOAD1 = 1021 -- 坦克载重
ATTRIBUTE_INDEX_PAYLOAD2 = 1022 -- 战车载重
ATTRIBUTE_INDEX_PAYLOAD3 = 1023 -- 火炮载重
ATTRIBUTE_INDEX_PAYLOAD4 = 1024 -- 火箭载重

ATTRIBUTE_INDEX_PRODUCT0 = 1030 -- 全部生产速度
ATTRIBUTE_INDEX_PRODUCT1 = 1031 -- 坦克生产速度
ATTRIBUTE_INDEX_PRODUCT2 = 1032 -- 战车生产速度
ATTRIBUTE_INDEX_PRODUCT3 = 1033 -- 火炮生产速度
ATTRIBUTE_INDEX_PRODUCT4 = 1034 -- 火箭生产速度

ATTRIBUTE_INDEX_REFIT0 = 1040 -- 全部改造速度
ATTRIBUTE_INDEX_REFIT1 = 1041 -- 坦克改造速度
ATTRIBUTE_INDEX_REFIT2 = 1042 -- 战车改造速度
ATTRIBUTE_INDEX_REFIT3 = 1043 -- 火炮改造速度
ATTRIBUTE_INDEX_REFIT4 = 1044 -- 火箭改造速度

ATTRIBUTE_INDEX_SPEED = 1011	-- 行军速度
ATTRIBUTE_INDEX_SOLDIER = 1051	-- 带兵量

AttributeMO = {}

function AttributeMO.init()
	db_attribute_ = {}
	local records = DataBase.query(s_attribute)
	for index = 1, #records do
		local data = records[index]
		db_attribute_[data.attributeId] = data
	end
end

function AttributeMO.queryAttributeById(attributeId)
	if not attributeId or attributeId <= 0 then
		gprint("[AttributeMO] queryAttributeById id is Error:", attributeId)
	end

	return db_attribute_[attributeId]
end
