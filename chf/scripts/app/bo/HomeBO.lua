
COLOR = {
[1] = cc.c3b(226, 224, 212), -- 白
[2] = cc.c3b(18, 127, 3), -- 绿
[3] = cc.c3b(3, 212, 231), -- 蓝
[4] = cc.c3b(183, 10, 184),  -- 紫
[5] = cc.c3b(239, 66, 5),  -- 橙
[6] = cc.c3b(184, 50, 50), -- 红
[11] = cc.c3b(205, 205, 205), -- 灰，游戏中label标签的颜色
[12] = cc.c3b(191, 154, 64), -- 黄
[21] = cc.c3b(255, 255, 255), -- 白
[22] = cc.c3b(18, 255, 3), -- 绿
[23] = cc.c3b(0, 234, 255), -- 蓝
[24] = cc.c3b(237, 5, 252),  -- 紫
[25] = cc.c3b(254, 110, 31),  -- 橙
[26] = cc.c3b(255, 0, 0), -- 红
[99] = cc.c3b(238, 199, 16), -- 金色
}

RomeNum = {
[1] = "Ⅰ",	
[2] = "Ⅱ",	
[3] = "Ⅲ",	
[4] = "Ⅳ",	
[5] = "Ⅴ",	
[6] = "Ⅵ",	
[7] = "Ⅶ",	
[8] = "Ⅷ",	
[9] = "Ⅸ",	
[10] = "Ⅹ",	
}

HomeBO = {}

-- 主场景中所有的建筑排放的位置
HomeBaseMapConfig_100 = {
{id=BUILD_ID_COMMAND, x=837, y=800, sx = -10, sy = 0, order=84},  -- sx阴影的偏移量；tx建筑名view的位置
{id=BUILD_ID_WAREHOUSE_A, x=314, y=660, sx=-20, sy=0, ss=0.7, tx=60, ty=90, order=115},
{id=BUILD_ID_WAREHOUSE_B, x=220, y=612, sx =-20, sy = 0, ss=0.7, tx=60, ty=90, order=116},
{id=BUILD_ID_ARENA, x=650, y=732, sx=0, sy=0, ss=0.8, order=93},
{id=BUILD_ID_REFIT, x=806, y=628, sx=-20, sy=0, ss=0.8, tx=90, ty=120, order=91},
{id=BUILD_ID_SCHOOL, x=946, y=564, sx = -20, sy = 0, order=146},
{id=BUILD_ID_PARTY, x=616, y=910, sx=0, sy=0, ss=0.8, tx=80, order=80},
{id=BUILD_ID_SCIENCE, x=528, y=778, sx = -20, sy = 0, ss=0.65, tx=60, order=92},  -- ss阴影的缩放
{id=BUILD_ID_COMPONENT, x=816, y=254, sx=0, sy=0, ss=0.6, order=99},
{id=BUILD_ID_CHARIOT_A, x=484, y=502, sx=-15, sy=0, ss=0.75, tx=90, order=95},
{id=BUILD_ID_CHARIOT_B, x=596, y=446, sx=-15, sy=0, ss=0.75, tx=90, order=102},
{id=BUILD_ID_WORKSHOP, x=422, y=838, sx=-15, sy=0, ss=0.6, tx=80, order=91},
{id=BUILD_ID_EQUIP, x=946, y=322, sx=0, sy=0, ss=0.6, order=100},
{id=BUILD_ID_AFFAIRE, x=1048, y=660, sx = 0, sy = 0, ss=0.6, order=90},  -- 外交部
-- {id=BUILD_ID_NOTICE, x=1076, y=448, sx = 0, sy = 0, ss=0.4, order=146},  -- 公告
{id=BUILD_ID_HARBOUR, x=125, y=680, sx = 0, sy = 0, ss=0.4, order=146},  -- 
{id=BUILD_ID_MILITARY, x=1046, y=434, sx = 0, sy = 20, ss=0.5, order=150},  --军工科技
}

HomeBaseMapConfig_138 = { -- GAME_APK_VERSION版本为1.3.8及以上的配置
{id=BUILD_ID_COMMAND, x=813, y=782, sx = -10, sy = 10, ss=0.9, order=84},  -- sx阴影的偏移量；tx建筑名view的位置
{id=BUILD_ID_WAREHOUSE_A, x=292, y=634, sx=-20, sy=0, ss=0.7, tx=60, ty=100, order=115},
{id=BUILD_ID_WAREHOUSE_B, x=190, y=586, sx =-20, sy = 0, ss=0.7, tx=60, ty=100, order=116},
{id=BUILD_ID_ARENA, x=624, y=704, sx=0, sy=0, ss=0.8, order=93},
{id=BUILD_ID_REFIT, x=776, y=611, sx=-20, sy=0, ss=0.8, tx=90, ty=120, order=91},
{id=BUILD_ID_SCHOOL, x=912, y=540, sx = -20, sy = 10, ss=0.8, order=146},
{id=BUILD_ID_PARTY, x=586, y=860, sx=-10, sy=0, ss=0.7, tx=45, order=80},
{id=BUILD_ID_SCIENCE, x=508, y=758, sx = -20, sy = 10, ss=0.65, tx=60, order=92},  -- ss阴影的缩放
{id=BUILD_ID_COMPONENT, x=784, y=234, sx=-0, sy=25, ss=0.7, order=99},
{id=BUILD_ID_CHARIOT_A, x=454, y=476, sx=-15, sy=0, ss=0.75, tx=90, order=95},
{id=BUILD_ID_CHARIOT_B, x=566, y=420, sx=-15, sy=0, ss=0.75, tx=90, order=102},
{id=BUILD_ID_WORKSHOP, x=408, y=808, sx=-15, sy=10, ss=0.6, tx=80, order=91},
{id=BUILD_ID_EQUIP, x=906, y=312, sx=0, sy=10, ss=0.6, order=100},
{id=BUILD_ID_AFFAIRE, x=998, y=636, sx = 0, sy = 0, ss=0.6, order=90},  -- 外交部
-- {id=BUILD_ID_NOTICE, x=1036, y=432, sx = 0, sy = 10, ss=0.45, order=146},  -- 公告
{id=BUILD_ID_HARBOUR, x=168, y=824, sx = 0, sy = 20, ss=0.5, order=146},  -- 
{id=BUILD_ID_MILITARY, x=1046, y=434, sx = 0, sy = 20, ss=0.5, order=150},  --军工科技
{id=BUILD_ID_MATERIAL_WORKSHOP, x =1184, y=465, sx = 0, sy = 20, ss=0.5, order=151}, --材料工坊
{id=BUILD_ID_ARMAMENT, x =1160+130, y=220+145, sx = 0, sy = 20, ss=0.5, tx = 70, order=152}, --军备工厂
{id=BUILD_ID_LABORATORY, x =1275 + 10, y=540 + 5, sx = 0, sy = 20, ss=0.5, order=152}, --作战实验室
}

HomeBaseMapConfig_138_0 = { -- GAME_APK_VERSION版本为1.3.8及以上的配置
{id=BUILD_ID_COMMAND, x=813, y=782, sx = -10, sy = 10, ss=0.9, order=84},  -- sx阴影的偏移量；tx建筑名view的位置
{id=BUILD_ID_WAREHOUSE_A, x=292, y=634, sx=-20, sy=0, ss=0.7, tx=60, ty=100, order=115},
{id=BUILD_ID_WAREHOUSE_B, x=190, y=586, sx =-20, sy = 0, ss=0.7, tx=60, ty=100, order=116},
{id=BUILD_ID_ARENA, x=624, y=704, sx=0, sy=0, ss=0.8, order=93},
{id=BUILD_ID_REFIT, x =505, y=400, sx = 0, sy = 20, ss=0.5, order=153},
{id=BUILD_ID_SCHOOL, x=912, y=540, sx = -20, sy = 10, ss=0.8, order=146},
{id=BUILD_ID_PARTY, x=586, y=860, sx=-10, sy=0, ss=0.7, tx=45, order=80},
{id=BUILD_ID_SCIENCE, x=508, y=758, sx = -20, sy = 10, ss=0.65, tx=60, order=92},  -- ss阴影的缩放
{id=BUILD_ID_COMPONENT, x=784, y=234, sx=-0, sy=25, ss=0.7, order=99},
{id=BUILD_ID_CHARIOT_A, x=454 + 65, y=476 + 40, sx=-15, sy=0, ss=0.75, tx=90, order=95},
{id=BUILD_ID_CHARIOT_B, x=566 + 65, y=420 + 40, sx=-15, sy=0, ss=0.75, tx=90, order=102},
{id=BUILD_ID_WORKSHOP, x=408, y=808, sx=-15, sy=10, ss=0.6, tx=80, order=91},
{id=BUILD_ID_EQUIP, x=906, y=312, sx=0, sy=10, ss=0.6, order=100},
{id=BUILD_ID_AFFAIRE, x=998, y=636, sx = 0, sy = 0, ss=0.6, order=90},  -- 外交部
-- {id=BUILD_ID_NOTICE, x=1036, y=432, sx = 0, sy = 10, ss=0.45, order=146},  -- 公告
{id=BUILD_ID_HARBOUR, x=168, y=824, sx = 0, sy = 20, ss=0.5, order=146},  -- 
-- {id=BUILD_ID_MILITARY, x=1046, y=434, sx = 0, sy = 20, ss=0.5, order=150},  --军工科技
{id=BUILD_ID_MILITARY, x =1160+110, y=220+145, sx = 0, sy = 20, ss=0.5, tx = 70, order=152}, --军工科技
{id=BUILD_ID_MATERIAL_WORKSHOP, x =1184, y=465 + 15, sx = 0, sy = 20, ss=0.5, order=151}, --材料工坊
-- {id=BUILD_ID_ARMAMENT, x =1160+130, y=220+145, sx = 0, sy = 20, ss=0.5, tx = 70, order=152}, --军备工厂
{id=BUILD_ID_ARMAMENT, x =1160+243, y=220+86, sx = 0, sy = 20, ss=0.5, tx = 70, order=153}, --军备工厂
{id=BUILD_ID_LABORATORY, x =1275 + 10 - 7, y=540 + 5 - 6, sx = 0, sy = 20, ss=0.5, order=152}, --作战实验室
{id=BUILD_ID_ADVANCEDTANK, x =405, y=455, sx = 0, sy = 20, ss=0.5, ty=100, order=152}, --高级金币车
{id=BUILD_ID_TACTICCENTER, x=770, y=600, sx=-20, sy=0, ss=0.8, tx=90, ty=133, order=91}, --战术中心
-- {id=BUILD_ID_ENERGYCORE, x =1160+215, y=220+87, sx = 0, sy = 20, ss=0.5, tx = 110, order=153}, --能源核心
{id=BUILD_ID_ENERGYCORE, x=1046, y=434, sx = 0, sy = 20, ss=0.5, order=150},  --能源核心
}

HomeBaseMapConfig = {}

-- 在放置tank区域内，从上到下、从左到右的每个位置的信息，索引为数组中的索引
HomeBaseTankPos_100 = {
{x = 280, y = 496, order = 100}, -- 第一个位置  x-48 y-24  80, 92
{x = 324, y = 474, order = 101},
{x = 368, y = 452, order = 102},
{x = 408, y = 430, order = 103},
{x = 454, y = 408, order = 104},
{x = 498, y = 384, order = 105},

{x = 215, y = 464, order = 200},
{x = 260, y = 444, order = 201},
{x = 304, y = 420, order = 202},
{x = 346, y = 398, order = 203},
{x = 390, y = 376, order = 204},
{x = 432, y = 354, order = 205},

{x = 154, y = 434, order = 300},
{x = 200, y = 410, order = 301},
{x = 244, y = 388, order = 302},
{x = 286, y = 368, order = 303},
{x = 328, y = 344, order = 304},
{x = 372, y = 324, order = 305},

{x = 94, y = 402, order = 400},
{x = 140, y = 380, order = 401},
{x = 184, y = 358, order = 402},
{x = 224, y = 336, order = 403},
{x = 270, y = 314, order = 404},
{x = 314, y = 290, order = 405},

{x = 32, y = 372, order = 500},
{x = 76, y = 348, order = 501},
{x = 118, y = 326, order = 502},
{x = 160, y = 304, order = 503},
{x = 202, y = 282, order = 504},
{x = 250, y = 258, order = 505},

{x = 152, y = 250, order = 600},  -- 31
{x = 200, y = 226, order = 601},
}

HomeBaseTankPos_138 = {
{x = 272, y = 480, order = 100}, -- 第一个位置  x-48 y-24  80, 92
{x = 316, y = 458, order = 101},
{x = 360, y = 436, order = 102},
{x = 396, y = 414, order = 103},
{x = 442, y = 392, order = 104},
{x = 478, y = 374, order = 105},

{x = 212, y = 456, order = 200},
{x = 256, y = 436, order = 201},
{x = 300, y = 412, order = 202},
{x = 342, y = 390, order = 203},
{x = 386, y = 368, order = 204},
{x = 428, y = 346, order = 205},

{x = 150, y = 426, order = 300},
{x = 196, y = 402, order = 301},
{x = 240, y = 380, order = 302},
{x = 282, y = 360, order = 303},
{x = 324, y = 336, order = 304},
{x = 368, y = 316, order = 305},

{x = 90, y = 398, order = 400},
{x = 136, y = 376, order = 401},
{x = 180, y = 354, order = 402},
{x = 220, y = 332, order = 403},
{x = 266, y = 310, order = 404},
{x = 310, y = 286, order = 405},

{x = 32, y = 372, order = 500},
{x = 76, y = 348, order = 501},
{x = 118, y = 326, order = 502},
{x = 160, y = 304, order = 503},
{x = 202, y = 282, order = 504},
{x = 250, y = 258, order = 505},

{x = 142, y = 258, order = 600},
{x = 202, y = 228, order = 601},
}

HomeBaseTankPos_167 = {
{x = 272 + 30, y = 480 + 10, order = 100}, -- 第一个位置  x-48 y-24  80, 92
{x = 316 + 30, y = 458 + 10, order = 101},
{x = 360 + 30, y = 436 + 10, order = 102},
{x = 396 + 30, y = 414 + 10, order = 103},
{x = 442 + 30, y = 392 + 10, order = 104},
{x = 478 + 30, y = 374 + 10, order = 105},
{x = 514 + 30, y = 352 + 10, order = 106},

{x = 212 + 30, y = 456 + 10, order = 200},
{x = 256 + 30, y = 436 + 10, order = 201},
{x = 300 + 30, y = 412 + 10, order = 202},
{x = 342 + 30, y = 390 + 10, order = 203},
{x = 386 + 30, y = 368 + 10, order = 204},
{x = 428 + 30, y = 346 + 10, order = 205},
{x = 470 + 30, y = 324 + 10, order = 206},

{x = 150 + 30, y = 426 + 10, order = 300},
{x = 196 + 30, y = 402 + 10, order = 301},
{x = 240 + 30, y = 380 + 10, order = 302},
{x = 282 + 30, y = 360 + 10, order = 303},
{x = 324 + 30, y = 336 + 10, order = 304},
{x = 368 + 30, y = 316 + 10, order = 305},
{x = 412 + 30, y = 296 + 10, order = 306},

{x = 90 + 30, y = 398 + 10, order = 400},
{x = 136 + 30, y = 376 + 10, order = 401},
{x = 180 + 30, y = 354 + 10, order = 402},
{x = 220 + 30, y = 332 + 10, order = 403},
{x = 266 + 30, y = 310 + 10, order = 404},
{x = 310 + 30, y = 286 + 10, order = 405},
{x = 354 + 30, y = 262 + 10, order = 406},

-- {x = 32 + 30, y = 372 + 10, order = 500},
-- {x = 76 + 30, y = 348 + 10, order = 501},
-- {x = 118 + 30, y = 326 + 10, order = 502},
-- {x = 160 + 30, y = 304 + 10, order = 503},
-- {x = 202 + 30, y = 282 + 10, order = 504},
-- {x = 250 + 30, y = 258 + 10, order = 505},

-- {x = 12, y = 348, order = 600}, -- 31
-- {x = 49, y = 323, order = 601},  -- 32
-- {x = 90, y = 302, order = 602},
-- {x = 132, y = 284, order = 603},
-- {x = 175, y = 260, order = 604},
-- {x = 218, y = 240, order = 605}, -- 36

-- {x = 33, y = 279, order = 701},  -- 37
-- {x = 77, y = 259, order = 702},
-- {x = 123, y = 239, order = 703},
-- {x = 165, y = 211, order = 704}, -- 40
}

--金币车位置
HomeBaseMoneyTankPos = {
	{x = 230, y = 770, order = 101},
	{x = 330, y = 710, order = 102},
	{x = 430, y = 660, order = 103},
	{x = 520, y = 620, order = 104},

	{x = 198, y = 648, order = 201},
	{x = 290, y = 590, order = 202},
	{x = 380, y = 540, order = 203},
	{x = 480, y = 490, order = 204},

	{x = 160, y = 520, order = 301},
	{x = 250, y = 470, order = 302},
	{x = 340, y = 410, order = 303},
	{x = 430, y = 370, order = 304},

	{x = 120, y = 413, order = 401},
	{x = 215, y = 340, order = 402},
	{x = 305, y = 300, order = 403},
	{x = 395, y = 250, order = 404},
}

HomeBaseTankPos = {}

-- 以id为标识的tank放置的位置索引
HomeBaseTankConfig = {
{tankId=1, pos=1},
{tankId=2, pos=8},
{tankId=3, pos=15},
{tankId=4, pos=22},

{tankId=5, pos=2},
{tankId=6, pos=9},
{tankId=7, pos=16},
{tankId=8, pos=23},

{tankId=9, pos=3},
{tankId=10, pos=10},
{tankId=11, pos=17},
{tankId=12, pos=24},

{tankId=13, pos=4},
{tankId=14, pos=11},
{tankId=15, pos=18},
{tankId=16, pos=25},

{tankId=17, pos=5},
{tankId=18, pos=12},
{tankId=19, pos=19},
{tankId=20, pos=26},

{tankId=21, pos=6},
{tankId=22, pos=13},
{tankId=23, pos=20},
{tankId=24, pos=27},

{tankId=103, pos=7},
{tankId=104, pos=14},
{tankId=105, pos=21},
{tankId=106, pos=28},

-- {tankId=25, pos=25},
-- {tankId=26, pos=26},
-- {tankId=27, pos=27},
-- {tankId=28, pos=28},


-- {tankId=29, pos=29},
-- {tankId=30, pos=30},

-- {tankId=97, pos=31},
-- {tankId=98, pos=32},
-- {tankId=99, pos=33},
-- {tankId=100, pos=34},
-- {tankId=101, pos=35},
-- {tankId=102, pos=36},

-- {tankId=103, pos=37},
-- {tankId=104, pos=38},
-- {tankId=105, pos=39},
-- {tankId=106, pos=40},
}

--金币车的位置
HomeBaseMoneyTankConfig = {
	{tankId=25, pos=1},
	{tankId=29, pos=5},
	{tankId=26, pos=9},
	{tankId=30, pos=13},

	{tankId=27, pos=2},
	{tankId=97, pos=6},
	{tankId=28, pos=10},
	{tankId=98, pos=14},

	{tankId=99, pos=3},
	{tankId=100, pos=7},
	{tankId=101, pos=11},
	{tankId=102, pos=15},

	{tankId=107, pos=4},
	{tankId=108, pos=8},
	{tankId=109, pos=12},
	{tankId=110, pos=16},
}

HomeWildPos = {
{x = 1240, y = 330, order = 999},
{x = 1120, y = 390, order = 998},
{x = 1000, y = 450, order = 997},
{x = 880, y = 510, order = 996},
{x = 760, y = 570, order = 995},
{x = 640, y = 630, order = 994},
{x = 520, y = 690, order = 993},
{x = 400, y = 750, order = 992},
{x = 1120, y = 230, order = 1100},  -- 9
{x = 1000, y = 290, order = 1099},
{x = 880, y = 350, order = 1098},
{x = 760, y = 410, order = 1097},
{x = 640, y = 470, order = 1096},
{x = 520, y = 530, order = 1095},
{x = 400, y = 590, order = 1094},
{x = 280, y = 650, order = 1093},
{x = 760, y = 250, order = 1200},  -- 17
{x = 640, y = 310, order = 1199},
{x = 520, y = 370, order = 1198},
{x = 400, y = 430, order = 1197},
{x = 280, y = 490, order = 1196},
{x = 160, y = 550, order = 1195},
{x = 400, y = 270, order = 1300},  -- 23
{x = 280, y = 330, order = 1299},
{x = 160, y = 390, order = 1298},
{x = 160, y = 230, order = 1400},
{x = 1440, y = 380, order = 899},  -- 27
{x = 1320, y = 440, order = 898},
{x = 1200, y = 500, order = 897},
{x = 1080, y = 560, order = 896},
{x = 960, y = 620, order = 895},
{x = 840, y = 680, order = 894},
{x = 720, y = 740, order = 893},
{x = 600, y = 800, order = 892},
{x = 1440, y = 540, order = 799},  -- 35
{x = 1320, y = 600, order = 798},
{x = 1200, y = 660, order = 797},
{x = 1080, y = 720, order = 796},
{x = 960, y = 780, order = 795},
{x = 1460, y = 690, order = 699},  -- 40
{x = 1340, y = 750, order = 698},
{x = 1220, y = 830, order = 697},
}

HomeBuildWildConfig = {
{index=1, pos = 1, lv=0, tag=0}, -- lv要求司令部等级，tag:0表示普通的，1表示专门用于宝石，2专门用于硅
{index=2, pos = 2, lv=0, tag=0},
{index=3, pos = 9, lv=0, tag=0},
{index=4, pos = 10, lv=0, tag=0},
{index=5, pos = 3, lv=0, tag=0},
{index=6, pos = 11, lv=2, tag=0},  -- 6
{index=7, pos = 4, lv=4, tag=0},
{index=8, pos = 12, lv=6, tag=0},
{index=9, pos = 18, lv=8, tag=0},
{index=10, pos = 19, lv=10, tag=0},
{index=11, pos = 23, lv=12, tag=0},  -- 11
{index=12, pos = 5, lv=14, tag=0},
{index=13, pos = 13, lv=16, tag=0},
{index=14, pos = 6, lv=18, tag=0},
{index=15, pos = 14, lv=20, tag=0},
{index=16, pos = 20, lv=22, tag=0},
{index=17, pos = 24, lv=24, tag=0},
{index=18, pos = 26, lv=26, tag=0},
{index=19, pos = 25, lv=28, tag=0},
{index=20, pos = 22, lv=30, tag=0},
{index=21, pos = 21, lv=32, tag=0}, -- 21
{index=22, pos = 15, lv=34, tag=0},
{index=23, pos = 7, lv=36, tag=0},
{index=24, pos = 8, lv=38, tag=0},
{index=25, pos = 31, lv=40, tag=0},  -- 25
{index=26, pos = 32, lv=42, tag=0},
{index=27, pos = 33, lv=44, tag=0},
{index=28, pos = 34, lv=46, tag=0},
{index=29, pos = 39, lv=48, tag=0},
{index=30, pos = 38, lv=50, tag=0},
{index=31, pos = 41, lv=52, tag=0},
{index=32, pos = 17, lv=54, tag=0},
{index=33, pos = 42, lv=56, tag=0},
{index=34, pos = 40, lv=58, tag=0},
{index=35, pos = 16, lv=60, tag=0},

{index=36, pos = 29, lv=10, tag=2},
{index=37, pos = 28, lv=20, tag=2},
{index=38, pos = 27, lv=30, tag=2},
{index=39, pos = 37, lv=40, tag=2},
{index=40, pos = 36, lv=50, tag=2},
{index=41, pos = 35, lv=60, tag=2},
{index=42, pos = 30, lv=3, tag=1},
}

function HomeBO.init()
	local apkVersion = LoginBO.getLocalApkVersion()

    if apkVersion <= HOME_SNOW_VERSION then
    	HomeBaseMapConfig = HomeBaseMapConfig_100
    	HomeBaseTankPos = HomeBaseTankPos_100
	elseif apkVersion <= 166 then
    	HomeBaseMapConfig = HomeBaseMapConfig_138
    	HomeBaseTankPos = HomeBaseTankPos_138
    else  -- 使用新的主场景
    	HomeBaseMapConfig = HomeBaseMapConfig_138_0
    	HomeBaseTankPos = HomeBaseTankPos_167
    end
end

function HomeBO.getBuildConfig(buildingId)
	for buildIndex = 1, #HomeBaseMapConfig do
		local config = HomeBaseMapConfig[buildIndex]
		if config.id == buildingId then return config end
	end
end


-- function HomeBO.update(data)
-- 	gdump(data, "[HomeBO] update get mill")
-- end

-- function HomeBO.getMapConfig(kind, id)
-- 	if kind == HOME_MAP_KIND_BASE then
-- 		for _, config in pairs(HomeBaseMapConfig) do
-- 			if config.id == id then
-- 				return config
-- 			end
-- 		end
-- 	end
-- end

INDICATOR_TYPE_BUILD_BASE = 1 -- 基地建造
INDICATOR_TYPE_WILD = 2
INDICATOR_TYPE_ACTIVITY_LEVEL = 3

HomeIndicatorConifg = {
-- step中的kind:1表示箭头指定位置，2表示dialog， 0表示over
-- offset:nil或者1以底部为标准, 2以中部为标准, 3已顶部为标准
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_COMMAND, size=cc.size(110,160), noSkip=true},
	{kind=2,text=CommonText[491][1]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1,buildingId=BUILD_ID_CHARIOT_A, size=cc.size(100, 100), noSkip=true},
	{kind=2,text=CommonText[491][2]},
	{kind=0}}},
{type=INDICATOR_TYPE_WILD, step={
	{kind=1,pos=cc.p(75, 0), size=cc.size(120, 100), noSkip=true},
	{kind=2,text=CommonText[491][3]},
	{kind=1,wildPos=2, size=cc.size(100, 100)},
	{kind=2,text=CommonText[491][4]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_SCIENCE,size=cc.size(150,100), noSkip=true},
	{kind=2,text=CommonText[491][5]}, {kind=0}}},
{type=INDICATOR_TYPE_ACTIVITY_LEVEL, step={
	{kind=1, pos=cc.p(400,-190), offset=3, size=cc.size(50,80), name="ActivityView", noSkip=true},
	{kind=2,text=CommonText[491][6]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(50,80), pos=cc.p(600,-175), offset=3, command="login_prize", noSkip=true},
	{kind=2,text=CommonText[491][7]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_EQUIP, size=cc.size(130,110), noSkip=true},
	{kind=1, size=cc.size(140,70), pos=cc.p(520,-500), offset=3, command="equipOneKey"},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	-- {kind=1, buildingId=BUILD_ID_EQUIP, size=cc.size(130,110), noSkip=true},
	-- {kind=1, size=cc.size(140,140), pos=cc.p(100,-220), offset=3, size=cc.size(120,120), command="equipUpgrade"},
	-- {kind=1, size=cc.size(150,70), pos=cc.p(470,-180),offset=2, command="equipDialog_upgrade"},
	-- {kind=2, text=CommonText[491][8]},
	-- {kind=0}}},
	{kind=1, size=cc.size(90,90), pos=cc.p(600,320), command="lottery_equip", name="LotteryEquipView"},
	{kind=2, text=CommonText[491][12]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_CHARIOT_A, size=cc.size(130,110), noSkip=true},
	{kind=1, size=cc.size(160,50), pos=cc.p(240,-150), offset=3, command="chariotView_product"},
	{kind=1, size=cc.size(100,100), pos=cc.p(555,-282), offset=3, command="chariotView_chose"},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(45,-90), offset=3, name="PlayerView"},
	{kind=1, size=cc.size(90,90), pos=cc.p(554,-769), offset=3, command="player_upCommand"},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(45,-90), offset=3, name="PlayerView"},
	{kind=1, size=cc.size(160,60), pos=cc.p(240,-150), offset=3, command="player_skill"},
	{kind=2, text=CommonText[491][9]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_SCIENCE, size=cc.size(130,150), noSkip=true},
	{kind=1, size=cc.size(160,60), pos=cc.p(240,-150), offset=3, command="science_study"},
	{kind=2, text=CommonText[491][10]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(600,240), command="lottery_treasure", name="LotteryTreasureView"},
	{kind=2, text=CommonText[491][11]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(600,320), command="lottery_equip", name="LotteryEquipView"},
	{kind=2, text=CommonText[491][12]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=2, text=CommonText[491][13], command="chat"},
	{kind=2, text=CommonText[491][14]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=2, text=CommonText[491][15], command="chat"},
	{kind=2, text=CommonText[491][16]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(45,-90), offset=3, name="PlayerView"},
	{kind=1, size=cc.size(160,60), pos=cc.p(560,-150), offset=3, command="player_portrait"},
	{kind=2, text=CommonText[491][17]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=2, text=CommonText[491][18], command="rank"},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(96,96), pos=cc.p(195,5), command="combat", name="CombatSectionView"},
	{kind=2, text=CommonText[491][19]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(150,120), pos=cc.p(75,5), command="home_wild"},
	{kind=1, size=cc.size(150,120), pos=cc.p(75,5), command="home_world"},
	{kind=1, size=cc.size(90,90), pos=cc.p(590,200), command="world_nearby"},
	{kind=2, text=CommonText[491][20]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(150,120), pos=cc.p(75,5), command="home_wild"},
	{kind=1, size=cc.size(150,120), pos=cc.p(75,5), command="home_world"},
	{kind=1, size=cc.size(90,90), pos=cc.p(590,200), command="world_nearby"},
	{kind=2, text=CommonText[491][21]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, size=cc.size(90,90), pos=cc.p(380,5), name="TaskView"},
	{kind=1, size=cc.size(160,60), pos=cc.p(240,-150), offset=3, command="task_daily"},
	{kind=2, text=CommonText[491][22]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, buildingId=BUILD_ID_PARTY, size=cc.size(110, 110)},
	{kind=2, text=CommonText[491][23]},
	{kind=0}}},
{type=INDICATOR_TYPE_BUILD_BASE, step={
	{kind=1, pos=cc.p(320, -110), offset=3, size=cc.size(640, 45), name="ReserverView"},
	{kind=2, text=CommonText[491][24]},
	{kind=0}}},
}

HomeIndicatorWildConifg = {type=INDICATOR_TYPE_BUILD_BASE,step={{kind=1, size=cc.size(170,110), wildPos=0, command="indicate_wild_create"}, {kind=0}}}

-- kind:101通过第一章
HomePassSectionConfig = {type=INDICATOR_TYPE_BUILD_BASE,step={{kind=2, text=CommonText[496][1]},{kind=101}}}

HomeUpCommandConfig = {type=INDICATOR_TYPE_BUILD_BASE,step={{kind=1, pos=cc.p(550,-490),size=cc.size(110,110),offset=3,command="up_rank"}, {kind=0,command="up_rank"}}}

--基地装扮动态气球配置
HomeBallonsAnimationConfig = {
	{x = 419, y = 763},{x = 50, y = 713},{x = 170, y = 588},{x = 150, y = 518},
	{x = 328, y = 598},{x = 655, y = 303},{x = 655, y = 413},{x = 875, y = 523}}
--基地装扮静态气球配置
HomeBallons1Config = {
	{x = 435, y = 285},{x = 578, y = 215},{x = 735, y = 150},{x = 593, y = 325},{x = 750, y = 413},
	{x = 778, y = 525},{x = 623, y = 597},{x = 835, y = 545},{x = 270, y = 870},{x = 435, y = 950},
	{x = 570, y = 1020},{x = 698, y = 980},{x = 863, y = 900},{x = 1026, y = 825},{x = 1175, y = 743},
	{x = 1317, y = 673}}
HomeBallons2Config = {
	{x = 500, y = 255},{x = 660, y = 185},{x = 670, y = 373},{x = 830, y = 453},{x = 703, y = 567},{x = 550, y = 642},
	{x = 755, y = 585},{x = 355, y = 910},{x = 500, y = 990},{x = 618, y = 1021},{x = 775, y = 950},{x = 945, y = 865},
	{x = 1097, y = 787},{x = 1230, y = 713}}
--基地装扮礼花配置
HomeFireworksConfig = {{x = 180, y = 500},{x = 140, y = 280},{x = 180 + 450, y = 380},{x = 1160, y = 270}}

function HomeBO.getTankConfig(tankId)
	for index = 1, #HomeBaseTankConfig do
		local config = HomeBaseTankConfig[index]
		if config.tankId == tankId then
			return HomeBaseTankPos[config.pos]
		end
	end
end

function HomeBO.getMoneyTankConfig(tankId)
	for index = 1, #HomeBaseMoneyTankConfig do
		local config = HomeBaseMoneyTankConfig[index]
		if config.tankId == tankId then
			return HomeBaseMoneyTankPos[config.pos]
		end
	end
end

HomeBO.NO_OPERATE_FREE_TIMER = 0 -- 空闲无操作计时器

-- function HomeBO.getBuildView(mapKind, buildingId)
-- 	return UiUtil.createItemSprite(ITEM_KIND_BUILD, buildingId)
-- 	-- local config = HomeBO.getMapConfig(mapKind, buildingId)
-- 	-- return display.newSprite("image/home/build/" .. config.name .. ".png")
-- end

-- function HomeBO.asynGetMill()
-- 	local function parseGetMill(name, data)
-- 		gdump(data, "[HomeBO] get mill")
-- 	end
-- 	SocketWrapper.wrapSend(parseClickFame, NetRequest.new("ClickFame"))
-- end
function HomeBO.doBuildQueueCount(buySuccessCallback)
	if UserMO.buildCount_ < VipBO.getBuildQueueNum() then  -- 可以购买建造位
		local resData = UserMO.getResourceData(ITEM_KIND_COIN)
		local take = BuildBuyTakeCoin[UserMO.buildCount_ + 1]

		local function doneCallback()
			Loading.getInstance():unshow()
			Toast.show(CommonText[10001])
			if buySuccessCallback then buySuccessCallback() end
		end

		local function gotoBuy()
			local count = UserMO.getResource(ITEM_KIND_COIN)
			if count < take then  -- 金币不足
				require("app.dialog.CoinTipDialog").new():push()
				return
			end

			Loading.getInstance():show()
			UserBO.asynBuyBuild(doneCallback)
		end

		if UserMO.consumeConfirm then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[427], take, resData.name), function() gotoBuy() end):push()
		else
			gotoBuy()
		end
	else
		Toast.show(CommonText[351])
	end

end

--活跃宝箱
function HomeBO.SyncActActiveBox(name, data)
	ActivityMO.activeBoxInfo = data.boxId
	if UiDirector.hasUiByName("HomeView") then
		local view = UiDirector.getUiByName("HomeView")
		view:performWithDelay(function ()
			Toast.show(CommonText[1834])
		end, 1)
		Notify.notify(LOCAL_ACTIVE_BOX)
	end
end

function HomeBO.getActiveBox(doneCallback)
	local function parseActiveBox(name, data)
		Loading.getInstance():unshow()
		ActivityMO.activeBoxInfo = {} --数据初始化

		--奖励
		local awards = {}
		if table.isexist(data, "award") then
			awards = PbProtocol.decodeArray(data["award"])
			local showAwards = clone(awards)
			 --加入背包
			local ret = CombatBO.addAwards(awards)
			if doneCallback then doneCallback(showAwards,ret) end
		end
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseActiveBox, NetRequest.new("GetActiveBoxAward",{boxId = ActivityMO.activeBoxInfo}))
end