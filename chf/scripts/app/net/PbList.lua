PbList = {
["Base"]                = {0, 0}, -- Base.pb必须第一个加载。如果数值大于等于1000，表明是服务器推送给客户端的
["DoLogin"]				= {101, 102},
["DoRegister"]			= {103, 104},
["DoActive"]			= {105, 106},
["BeginGame"]			= {201, 202},
["CreateRole"]			= {203, 204},
["GetNames"]			= {205, 206},
["RoleLogin"]			= {207, 208},
["GetLord"]				= {209, 210},
["GetTime"]				= {211, 212},
["GetTank"]             = {213, 214},
["GetArmy"]             = {215, 216},
["GetForm"]             = {217, 218},
["SetForm"]             = {219, 220},
["Repair"]              = {221, 222},
["GetResource"]         = {223, 224},
["GetBuilding"]         = {225, 226},
["UpBuilding"]			= {227, 228},
["LoadData"]			= {229, 230},
["BuildTank"]			= {231, 232},
["Heart"]				= {233, 234},
["CancelQue"]			= {235, 236},
["GetProp"]				= {237, 238},
["BuyProp"]				= {239, 240},
["UseProp"]				= {241, 242},
["SpeedQue"]			= {243, 244},
["BuildProp"]			= {245, 246},
["RefitTank"]			= {247, 248},
["GetEquip"]			= {249, 250},
["SellEquip"]			= {251, 252},
["UpEquip"]				= {253, 254},
["OnEquip"]				= {255, 256},
["UpCapacity"]			= {257, 258},
["AllEquip"]			= {259, 260},
["GetPart"]				= {261, 262},
["GetChip"]				= {263, 264},
["CombinePart"]			= {265, 266},
["ExplodePart"]			= {267, 268},
["OnPart"]				= {269, 270},
["ExplodeChip"]			= {271, 272},
["UpPart"]				= {273, 274},
["RefitPart"]			= {275, 276},
["GetScience"]			= {277, 278},
["UpgradeScience"]		= {279, 280},
["GetCombat"]			= {281, 282},
["DoCombat"]			= {283, 284},
["GetMyHeros"]			= {285, 286},
["HeroDecompose"]		= {287, 288},
["HeroLevelUp"]			= {289, 290},
["HeroImprove"]			= {291, 292},
["LotteryHero"]			= {293, 294},
["BuyExplore"]			= {295, 296},
["ResetExtrEpr"]		= {297, 298},
["GetFriend"]			= {299, 300},
["AddFriend"]			= {301, 302},
["DelFriend"]			= {303, 304},
["BlessFriend"]			= {305, 306},
["GetBless"]			= {307, 308},
["AcceptBless"]			= {309, 310},
["GetStore"]			= {311, 312},
["RecordStore"]			= {313, 314},
["MarkStore"]			= {315, 316},
["GetMail"]				= {317, 318},
["SendMail"]			= {319, 320},
["RewardMail"]			= {321, 322},
["DelMail"]				= {323, 324},
["CombatBox"]			= {325, 326},
["BuyPower"]			= {327, 328},
["UpRank"]				= {329, 330},
["UpCommand"]			= {331, 332},
["BuyPros"]				= {333, 334},
["BuyFame"]				= {335, 336},
["ClickFame"]			= {337, 338},
["GetSkill"]			= {339, 340},
["UpSkill"]				= {341, 342},
["ResetSkill"]			= {343, 344},
-- ["GetMill"]				= {345, 346},
["DestroyMill"]			= {347, 348},
["SeachPlayer"]			= {349, 350},
["GetEffect"]         	= {351, 352},
["DoSome"] 	        	= {353, 354},
["DelStore"] 	       	= {355, 356},
["DoLottery"] 	       	= {357, 358},
["GetArena"] 	       	= {359, 360},
["DoArena"] 	       	= {361, 362},
["BuyArena"] 	       	= {363, 364},
["ArenaAward"] 	       	= {365, 366},
["UseScore"] 	       	= {367, 368},
["InitArena"]           = {369, 370},
["ReadMail"]            = {371, 372},
["GetLotteryEquip"]     = {373, 374},
["GetPartyRank"]     	= {375, 376},
["GetParty"]     		= {377, 378},
["GetPartyBuilding"]    = {379, 380},
["GetPartyMember"]    	= {381, 382},
["GetPartyHall"]    	= {383, 384},
["GetPartyScience"]    	= {385, 386},
["GetPartyWeal"]    	= {387, 388},
["GetPartyTrend"]    	= {389, 390},
["GetPartyShop"]    	= {391, 392},
["DonateParty"]    		= {393, 394},
["UpPartyBuilding"]    	= {395, 396},
["SetPartyJob"]    		= {397, 398},
["BuyPartyShop"]    	= {399, 400},
["WealDayParty"]    	= {401, 402},
["PartyApplyList"]    	= {403, 404},
["PartyApply"]    		= {405, 406},
["PartyApplyJudge"]    	= {407, 408},
["CreateParty"]    		= {409, 410},
["QuitParty"]    		= {411, 412},
["DonateScience"]    	= {413, 414},
["WealResourceParty"]   = {415, 416},
["CannlyApply"]    		= {417, 418},
["ApplyList"]    		= {419, 420},
["SeachParty"]    		= {421, 422},
["DoneGuide"]    		= {423, 424},
["GetMap"]    			= {425, 426},
["ScoutPos"]    		= {427, 428},
["AttackPos"]    		= {429, 430},
["MoveHome"]    		= {431, 432},
["Retreat"]    			= {433, 434},
["GetSign"]    			= {435, 436},
["Sign"]    			= {437, 438},
["GetMajorTask"]    	= {439, 440},
["TaskAward"]    		= {441, 442},
["SloganParty"]    		= {443, 444},
["UpMemberJob"]    		= {445, 446},
["CleanMember"]    		= {447, 448},
["ConcedeJob"]    		= {449, 450},
["SetMemberJob"]    	= {451, 452},
["PartyJobCount"]    	= {453, 454},
["PartyApplyEdit"]		= {455, 456},
["GetPartySection"]		= {457, 458},
["GetPartyCombat"]		= {459, 460},
["DoPartyCombat"]		= {461, 462},
["PartyctAward"]		= {463, 464},
["GetMailList"]			= {465, 466},
["GetMailById"]			= {467, 468},
["GetInvasion"]			= {469, 470},
["GetAid"]				= {471, 472},
["SetGuard"]			= {473, 474},
["GuardPos"]			= {475, 476},
["GetChat"]				= {477, 478},
["DoChat"]				= {479, 480},
["SearchOl"]			= {481, 482},
["GetDayiyTask"]		= {483, 484},
["GetLiveTask"]			= {485, 486},
["AcceptTask"]			= {487, 488},
["AcceptNoTask"]		= {489, 490},
["GetReport"]			= {491, 492},
["ShareReport"]			= {493, 494},
["TaskLiveAward"]		= {495, 496},
["TaskDaylyReset"]		= {497, 498},
["RefreshDayiyTask"]	= {499, 500},
["RetreatAid"]			= {501, 502},
["GetExtreme"]			= {503, 504},
["ExtremeRecord"]		= {505, 506},
["SetData"]				= {507, 508},
["PtcForm"]				= {509, 510},
["BeginWipe"]			= {511, 512},
["EndWipe"]				= {513, 514},
["GetGuideGift"]		= {515, 516},
["GetRank"]				= {517, 518},
["GetPartyLiveRank"]	= {519, 520},
["SetPortrait"]			= {521, 522},
["GetLotteryExplore"]	= {523, 524},
["PartyRecruit"]		= {525, 526},
["BuyBuild"]			= {527, 528},
["GetActivityList"]		= {529, 530},
["GetActivityAward"]	= {531, 532},
["ActLevel"]			= {533, 534},
["ActAttack"]			= {535, 536},
["ActFight"]			= {537, 538},
["ActCombat"]			= {539, 540},
["ActHonour"]			= {541, 542},
["GetPowerGiveData"]    = {993, 994}, 
["GetFreePower"]        = {995, 996},

["GiftCode"]			= {551, 552},
["ActPartyLv"]			= {553, 554},
["ActPartyDonate"]		= {555, 556},
["ActCollect"]			= {557, 558},
["ActCombatSkill"]		= {559, 560},
["ActPartyFight"]		= {561, 562},
["GetActionCenter"]		= {563,	564},
["GetActMecha"]			= {565,	566},
["DoActMecha"]			= {567,	568},
["AssembleMecha"]		= {569, 570},
["OlAward"]				= {571, 572},
["ActInvest"]			= {573, 574},
["DoInvest"]			= {575, 576},
["ActPayRedGift"]		= {577, 578},
["ActEveryDayPay"]		= {579, 580},
["ActPayFirst"]			= {581, 582},
["ActQuota"]			= {583, 584},
["DoQuota"]				= {585, 586},
["ActPurpleEqpColl"]	= {587, 588},
["ActPurpleEqpUp"]		= {589, 590},
["ActCrazyArena"]		= {591, 592},
["ActCrazyUpgrade"]		= {593, 594},
["ActPartEvolve"]		= {595, 596},
["ActFlashSale"]		= {597, 598},
["ActCostGold"]			= {599, 600},
["ActContuPay"]			= {601, 602},
["ActFlashMeta"]		= {603, 604},
["ActDayPay"]			= {605, 606},
["ActDayBuy"]			= {607, 608},
["GetPartyLvRank"]		= {609, 610},
["ActMonthSale"]		= {611, 612},
["ActGiftOL"]			= {613, 614},
["ActMonthLogin"]		= {615, 616},
["GetActAmyRebate"]		= {617, 618},
["GetActAmyfestivity"]	= {619, 620},
["DoActAmyRebate"]		= {621, 622},
["DoActAmyfestivity"]	= {623, 624},
["GetActFortune"]		= {625, 626},
["GetActFortuneRank"]	= {627, 628},
["DoActFortune"]		= {629, 630},
["GetRankAward"]		= {631, 632},
["GetActBee"]			= {633, 634},
["GetActBeeRank"]		= {635, 636},
["GetRankAwardList"]	= {637, 638},
["EveLogin"]			= {639, 640},
["AcceptEveLogin"]		= {641, 642},
["GetActProfoto"]		= {643, 644},
["DoActProfoto"]		= {645, 646},
["UnfoldProfoto"]		= {647, 648},
["GetActPartDial"]		= {649, 650},
["GetActPartDialRank"]	= {651, 652},
["DoActPartDial"]		= {653, 654},
["ActEnemySale"]		= {655, 656},
["ActUpEquipCrit"]		= {657, 658},
["DoActTankRaffle"]		= {659, 660},
["GetActTankRaffle"]	= {661, 662},
["WarReg"]				= {663, 664},
["WarMembers"]			= {665, 666},
["WarParties"]			= {667, 668},
["WarReport"]			= {669, 670},
["WarCancel"]			= {671, 672},
["GetActDestroy"]		= {673, 674},
["GetActDestroyRank"]	= {675, 676},
["ActReFristPay"]		= {677, 678},
["ActGiftPay"]			= {679, 680},
["GetPartyAmyProps"]	= {681, 682},
["SendPartyAmyProp"]	= {683 ,684},
["WarWinAward"]			= {685 ,686},
["WarRank"]				= {687 ,688},
["WarWinRank"]			= {689 ,690},
["UseAmyProp"]			= {691 ,692},
["GetWarFight"]			= {693 ,694},
["GetActTech"]			= {695 ,696},
["DoActTech"]			= {697 ,698},
["GetActGeneral"]		= {699 ,700},
["DoActGeneral"]		= {701 ,702},
["GetActGeneralRank"]	= {703 ,704},
["ActVipGift"]			= {705 ,706},
["ActPayContu4"]		= {707 ,708},
["DoPartyTipAward"]		= {709 ,710},
["GetActEDayPay"]		= {711 ,712},
["DoActEDayPay"]		= {713 ,714},
["DoActVipGift"]		= {715, 716},
["GetBoss"]				= {717, 718},
["GetBossHurtRank"]		= {719, 720},
["SetBossAutoFight"]	= {721, 722},
["BlessBossFight"]		= {723, 724},
["FightBoss"]			= {725, 726},
["BuyBossCd"]			= {727, 728},
["BossHurtAward"]		= {729, 730},
["ComposeSant"]			= {731, 732},
["GetTipFriends"]		= {733, 734},
["AddTipFriends"]		= {735, 736},
["BuyArenaCd"]			= {737, 738},
["BuyAutoBuild"]		= {739, 740},
["SetAutoBuild"]		= {741, 742},
["ActFesSale"]			= {743, 744},
["GetActConsumeDial"]	= {745, 746},
["GetActConsumeDialRank"]	= {747, 748},
["DoActConsumeDial"]	= {749, 750},
["GetActVacationland"]	= {751, 752},
["BuyActVacationland"]	= {753, 754},
["DoActVacationland"]	= {755, 756},
["GetActPartCash"]		= {757, 758},
["DoPartCash"]			= {759, 760},
["GetActEquipCash"]		= {761, 762},
["DoEquipCash"]			= {763, 764},
["GetActPartResolve"]	= {765, 766},
["DoActPartResolve"]	= {767, 768},
["RefshPartCash"]		= {769, 770},
["RefshEquipCash"]		= {771, 772},
["GetStaffing"]			= {773, 774},
["GetActGamble"]		= {775, 776},
["DoActGamble"]			= {777, 778},
["GetActPayTurntable"]	= {779, 780},
["DoActPayTurntable"]	= {781, 782},
["GetSeniorMap"]		= {783, 784},
["AtkSeniorMine"]		= {785, 786},
["SctSeniorMine"]		= {787, 788},
["ScoreRank"]			= {789, 790},
["ScorePartyRank"]		= {791, 792},
["BuySenior"]			= {793, 794},
["ScoreAward"]			= {795, 796},
["PartyScoreAward"]		= {797, 798},
["GetActCarnival"]		= {799, 800},
["GetActPray"]			= {801, 802},
["DoActPray"]			= {803, 804},
["ActPrayAward"]		= {805, 806},
["GetActPartyDonateRank"] = {807, 808},
["GetPartyRankAward"]	= {809, 810},
["MultiHeroImprove"]	= {811, 812},
["TipGuy"]				= {813, 814},
["LockPart"]			= {815, 816},
["GetActNewRaffle"]		= {817, 818},
["DoActNewRaffle"]		= {819, 820},
["LockNewRaffle"]		= {821, 822},
["GetMilitaryScience"]	= {823, 824},
["GetActTankExtract"]	= {825, 826},
["DoActTankExtract"]	= {827, 828},
["FormulaTankExtract"]	= {829, 830},
["UpMilitaryScience"]	= {831, 832},
["GetMilitaryScienceGrid"]	= {833, 834},
["FitMilitaryScience"]	= {835, 836},
["MilitaryRefitTank"]	= {837, 838},
["GetActTankCarnival"]	= {839, 840},
["DoActTankCarnival"]	= {841, 842},
["GetMilitaryMaterial"]	= {843,844},
["GetFortressBattleParty"]  =	{849,850},	
["SetFortressBattleForm"]   =	{851,852},	
["GetFortressBattleDefend"] =   {853,854}, 
["FortressBattleRecord"]	=   {855,856},     
["SynFortressBattleState"]	=	{1029,1030},
["BuyFortressBattleCd"] 	=   {857,858},		
["AttackFortress"]     		=   {859,860},		
["GetFortressPartyRank"]	=   {861,862},     
["GetFortressJiFenRank"]	=   {863,864},		
["GetFortressCombatStatics"]=   {865,866},	
["GetFortressFightReport"]	=	{867,868}, 
["GetFortressAttr"]     	=   {869,870},		
["UpFortressAttr"]			=   {871,872},		
["GetFortressJob"]			=	{881,882},		
["FortressAppoint"]			=   {883,884},		
["GetFortressWinParty"]		=   {885,886},		
["GetMyFortressJob"]		=   {887,888},		
["GetThisWeekMyWarJiFenRank"]=  {889,890},		
["GetScout"]				=   {891,892},
["GetActSmeltPartCrit"]     =   {4401,4402}, --淬炼暴击活动
["GetActSmeltPartMaster"]   =   {4403,4404}, --淬炼大师活动
["LotteryInSmeltPartMaster"] =  {4405,4406}, --淬炼大师氪金抽奖
["GetActSmeltPartMasterRank"] = {4407,4408}, --淬炼大师活动排行信息
["GetPlayerBackMessage"]      = {4501,4502}, --老玩家回归活动
["GetPlayerBackAwards"]       = {4503,4504}, --老玩家回归领奖
["GetPlayerBackBuff"]         = {4505,4506}, --老玩家回归buff

-- 能晶系统，能晶在这里统一使用energyStone表示
["GetRoleEnergyStone"]		=	{893,894},		---获取能晶仓库信息
["GetEnergyStoneInlay"]		=	{895,896},		---获取能晶镶嵌信息
["CombineEnergyStone"]		=	{897,898},		---合成能晶
["OnEnergyStone"]			=	{899,900},		---镶嵌、卸下能晶
["GetAltarBossData"]		=	{901,902},		---获取祭坛BOSS数据
["GetAltarBossHurtRank"]	=	{903,904},		---获取祭坛BOSS伤害排行
["SetAltarBossAutoFight"]	=	{905,906},		---祭坛BOSS设置vip自动战斗
["BlessAltarBossFight"]		=	{907,908},		---祭坛BOSS祝福
["CallAltarBoss"]		    =	{909,910},		---召唤祭坛BOSS
["BuyAltarBossCd"]			=	{911,912},		---消除祭坛BOSS的CD时间
["FightAltarBoss"]			=	{913,914},		---挑战祭坛BOSS
["AltarBossHurtAward"]		=	{915,916},		---领取祭坛BOSS伤害排名奖励
["GetTreasureShopBuy"]		=	{917,918},		---荒宝商店信息
["BuyTreasureShop"]		    =	{919,920},		---荒宝商店购买
--  军事演习（红蓝大战）
["GetDrillData"]			=	{921,922},		-- 获取红蓝大战的状态信息等数据
["DrillEnroll"]				=	{923,924},		-- 玩家报名参加红蓝大战
["ExchangeDrillTank"]		=	{925,926},		-- 兑换演习军力
["GetDrillRecord"]			=	{927,928},		-- 获取红蓝大战的战况
["GetDrillFightReport"]		=	{929,930},		-- 获取红蓝大战的具体战报
["GetDrillRank"]			=	{931,932},		-- 获取红蓝大战排行榜
["DrillReward"]				=	{933,934},		-- 领取红蓝大战的奖励
["GetDrillShop"]			=	{935,936},		-- 获取军演商店数据
["ExchangeDrillShop"]		=	{937,938},		-- 兑换军演商店的物品
["GetDrillImprove"]			=	{939,940},		-- 获取玩家的演习进修信息
["DrillImprove"]			=	{941,942},		-- 演习进修
["GetDrillTank"]			=	{943,944},		-- 获取演习军力

-- 叛军入侵
["GetRebelData"]			=	{981,982},		-- 获取叛军入侵活动相关数据
["GetRebelRank"]			=	{983,984},		-- 获取叛军入侵活动的排行榜数据
["RebelRankReward"]			=	{985,986},		-- 领取叛军入侵活动的排行奖励
["RebelIsDead"]				=	{987,988},		-- 获取叛军是否死亡
["GetTankCarnival"]			=	{989,990},		-- 获取坦克嘉年华活动数据
["TankCarnivalReward"]		=	{991,992},		-- 坦克嘉年华活动拉取奖励

["GetPushState"]			=	{945,946},		-- 获取Push评论推送信息
["PushComment"]				=	{947,948},		-- 评论

-- 配件进阶淬炼
["PartQualityUp"]	        =   {997,998},     -- 配件进阶橙品
["SmeltPart"]	            =   {3001,3002},   -- 配件淬炼
["SaveSmeltPart"]	        =   {3003,3004},   -- 配件淬炼保存
["TenSmeltPart"]	        =   {3005,3006},   -- 配件10次淬炼

["GetCollectCharacter"]     =   {3007,3008},   -- 请求集字活动信息
["CollectCharacterCombine"] =	{3009,3010},   -- 合成
["CollectCharacterChange"]  =   {3011,3012},   -- 兑换

["GetActM1a2"]              =   {3013,3014},   --请求m1a2活动信息
["DoActM1a2"]               =	{3015,3016},   --探索m1a2活动
["M1a2RefitTank"]           =	{3017,3018},   --m1a2改造坦克
["GetFlower"]	            =   {3019,3020},   --请求鲜花活动信息
["WishFlower"]	            =   {3021,3022},   --鲜花祝福
["AllEnergyStone"]          =   {3023,3024},   -- 一键镶嵌
["EquipQualityUp"]          =   {3025,3026},   -- 装备进阶

["GetPayRebate"]            =   {3027,3028},   -- 请求返利转盘信息
["DoPayRebate"]             =   {3029,3030},   -- 开始转盘

["GetMedal"]                =   {3037,3038},   -- 勋章信息
["GetMedalChip"]            =   {3039,3040},   -- 勋章碎片信息
["CombineMedal"]            =   {3041,3042},   --合成勋章
["ExplodeMedal"]            =   {3043,3044},   --分解勋章
["ExplodeMedalChip"]        =   {3045,3046},   --分解勋章碎片
["OnMedal"]                 =   {3047,3048},   --穿上、卸下勋章
["LockMedal"]               =   {3049,3050},   --锁定勋章
["UpMedal"]                 =   {3051,3052},   --强化勋章
["BuyMedalCdTime"]          =   {3053,3054},   --购买强化勋章cd
["RefitMedal"]              =   {3055,3056},   --改造勋章
["GetMedalBouns"]           =   {3065,3066},   --获取勋章展厅
["DoMedalBouns"]            =   {3067,3068},   --勋章展示

["GetPirateLottery"]        =   {3031,3032},   --请求抽奖界面
["DoPirateLottery"]         =   {3033,3034},   --海贼宝藏抽奖
["ResetPirateLottery"]      =   {3035,3036},   --充值抽奖
["GetPirateChange"]         =   {3057,3058},   --请求兑换界面
["DoPirateChange"]          =   {3059,3060},   --请求兑换
["GetActPirateRank"]        =   {3063,3064},   --请求排行榜

["ActContuPayMore"]         =   {3077,3078},   --连续充值界面信息
["GetActEnergyStoneDial"]   =	{3079,3080},	--能晶转盘
["GetActEnergyStoneDialRank"] =	{3081,3082},	--能晶转盘排行榜
["DoActEnergyStoneDial"]	=	{3083,3084},	--能晶转盘抽奖

["GetActBoss"]              =	{3085,3086},	--活动界面数据
["CallActBoss"]             =	{3087,3088},	--召唤
["AttackActBoss"]           =	{3089,3090},	--挑战
["BuyActBossCd"]            =	{3091,3092},	--购买CD
["GetActBossRank"]          =	{3093,3094},	--排行榜
["UsePropChoose"]           =   {3095,3096},    --使用可控制道具

["GetActHilarityPray"]      =   {3097,3098},   --请求狂欢祈福充值领奖界面信息
["ReceiveActHilarityPray"]  =   {3099,3100},   --领取狂欢祈福充值奖励
["GetActHilarityPrayAction"] =   {4001,4002},   --请求狂欢祈福祈福界面信息
["DoActHilarityPrayAction"] =   {4003,4004},   --使用卡片道具祈福
["ReceiveActHilarityPrayAction"] =  {4005,4006},   --领取狂欢祈福充值奖励
["SpeedActHilarityPrayAction"] = {4007,4008},   --祈福加速
["LockHero"]				=	{4009,4010},	--将领加锁

--七日活动
["GetDay7ActTips"]			= {4011,4012},			--小红点
["GetDay7Act"]				= {4013,4014},			--界面数据
["RecvDay7ActAward"]		= {4015,4016},			--领奖
["SynDay7ActTips"]			= {1065},			--推送小红点
["Day7ActLvUp"]		= {4017,4018},			--立即升级

["GetOverRebateAct"]        =   {4019,4020},   	-- 请求界面
["DoOverRebateAct"]         =   {4021,4022},   	-- 请求抽奖

["GetWorshipGodAct"]		=	{4023,4024},	-- 请求拜神界面
["DoWorshipGodAct"]			=	{4025,4026},	-- 拜神
["GetWorshipTaskAct"]		=	{4027,4028},	-- 请求许愿界面
["DoWorshipTaskAct"]		=	{4029,4030},	-- 许愿
["ActRebelIsDead"]			=	{4037,4038},	-- 剿匪
["GetActMergeGift"]         =   {4039,4040},    -- 合服登录
["GetActRebelRank"]         =   {4041,4042},    --活动叛军排行榜
["ActRebelRankReward"]      =   {4043,4044},    --活动叛军排行榜领奖
["HeroAwaken"]              =   {4045,4046},    --觉醒英雄数据
["HeroAwakenSkillLv"]       =   {4047,4048},    --觉醒技能升级方式，状态
["GetShopInfo"]       		=   {4049,4050},    --商店信息
["BuyShopGoods"]       		=   {4051,4052},    --购买商店
--西点学院活动
["GetActCollege"]           =   {4053,4054},    --活动主界面数据
["BuyActProp"]              =   {4055,4056},    --购买活动道具
["DoActCollege"]            =   {4057,4058},    --进修
--签到
["GetMonthSign"]            =   {4061,4062},    --签到信息
["MonthSign"]           	=   {4063,4064},    --签到
["DrawMonthSignExt"]        =   {4065,4066},    --额外签到

--飞艇
["CreateAirshipTeam"]       =  	{4067,4068},     --创建攻打飞艇队伍(战事)
["JoinAirshipTeam"]     	=  	{4069,4070},     --加入军团玩家创建的战事(队伍)
["CancelTeam"]     	   	    =  	{4071,4072},     --撤销飞艇队伍(战事)
["GetAirshipTeamList"]    	=  	{4073,4074},     --获取成员战事队伍列表
["GetAirshipTeamDetail"]    =  	{4075,4076},     --获取组队详情
["SetPlayerAttackSeq"]      =  	{4077,4078},     --设置攻击顺序-我的战事入口
["StartAirshipTeamMarch"]   =  	{4079,4080},     --立即行军
["GuardAirship"]            =  	{4083,4084},     --驻防飞艇
["GetAirshpTeamArmy"]       =  	{4085,4086},     --查看组队(战事)部队信息
["GetAirshipGuard"]         =   {4087,4088},     --查看驻防部队信息
["ScoutAirship"]         	=   {4089,4090},     --侦查飞艇
["RecvAirshipProduceAward"] =   {4091,4092},     --领取飞艇自产奖励
["AppointAirshipCommander"]	=	{4093,4094},	 --任命飞艇指挥
["GetPartyAirshipCommander"]=	{4095,4096},	 --获取军团中所有飞艇指挥官信息
["RebuildAirship"]			=	{4097,4098},	 --重建飞艇
["GetAirship"]           	=  	{4099,4100},     --获取所有飞艇
["GetAirshipPlayer"]		=	{4101,4102},	 --根据飞艇ID获取飞艇信息
["GetAirshipGuardArmy"]		=	{4103,4104},	 --查看飞艇驻军部队信息
["GetRecvAirshipProduceAwardRecord"]	=	{4105,4106},	--获取飞艇征收详情


--军备相关
["GetLordEquipInfo"]        =   {4201,4202},    --军备列表
["PutonLordEquip"]       	=   {4203,4204},    --穿上军备
["TakeOffEquip"]      		=   {4205,4206},    --脱下列表

["ShareLordEquip"]          =	{4207,4208},   --军备分享
["ProductEquip"]			=	{4209,4210},	--生产军备
["CollectLordEquip"]		= 	{4211,4212},	--收取军备
["ResloveLordEquip"]		=	{4213,4214},	--分解军备
["UseTechnical"]			=	{4215,4216},	--使用铁匠加速
["EmployTechnical"]			=	{4217,4218},	--雇佣铁匠
["LordEquipSpeedByGold"]	=   {4219,4220},    --金币加速
["ProductLordEquipMat"]     =   {4261,4262},    --生产军备材料
["BuyMaterialPro"]          =   {4263,4264},    --材料工坊购买生产位
["CollectLeqMaterial"]      =   {4265,4266},    --收取材料工坊生产材料
["GetLembQueue"]            =   {4267,4268},    --每隔一分钟获取一次材料生产状况
["LordEquipChange"]			=	{4281,4282},	--军备洗练装备功能
["LordEquipChangeFreeTime"]	=	{4283,4284},	--获取免费洗练次数和恢复时间
["LockLordEquip"]           =   {4221,4222},    --军备解锁/锁定
--

-------------------------新充值活动 能量灌注-------------------------
["GetActCumulativePayInfo"]		=	{4507,4508},	-- 查看充值详情
["GetActCumulativePayAward"]	=	{4509,4510},	-- 领取奖励
["ActCumulativeRePay"]			=	{4511,4512},	-- 补充第几天

-------------------------荣誉勋章 活动-------------------------
["GetActMedalofhonorInfo"]		=	{4521,4522},	-- 获取荣誉勋章活动信息
["OpenActMedalofhonor"]			=	{4523,4524},	-- 打开活动宝箱(大吉大利,晚上吃鸡)
["SearchActMedalofhonorTargets"]=	{4525,4526},	-- 搜索宝箱
["BuyActMedalofhonorItem"]		=	{4527,4528},	-- 购买荣誉勋章活动道具
["GetActMedalofhonorRankAward"]	=	{4529,4530},	-- 领取荣誉勋章活动排名奖励
["GetActMedalofhonorRankInfo"]	=	{4531,4532},	-- 查看排行榜

-----------------------------大富翁活动----------------------------
["GetMonopolyInfo"]				=	{4541,4542},	-- 获取大富翁活动信息
["ThrowDice"]					=	{4543,4544},	-- 投骰子
["BuyOrUseEnergy"]				=	{4545,4546},	-- 购买精力
["BuyDiscountGoods"]			=	{4547,4548},	-- 购买打折商品
["SelectDialog"]				=	{4549,4550},	-- 选择对话事件，对话选项
["DrawFinishCountAward"]		=	{4551,4552},	-- 领取已完成的游戏次数奖励
["DrawFreeEnergy"]				=	{4553,4554},	-- 领取免费精力

-----------------------------秘密武器活动--------------------------
["GetActScrtWpnStdCnt"]         =   {4571,4572},    -- 秘密武器活动

-----------------------------闪击行动--------------------------
["GetActStroke"]				=	{4581,4582},	-- 闪击行动活动
["DrawActStrokeAward"]			=	{4583,4584},	-- 领取闪击行动奖励

-----------------------------大咖带队--------------------------
["GetActVipCountInfo"]			=	{4591,4592},	-- 大咖带队

-----------------------------探宝活动---------------------------
["GetActLotteryExplore"]		=	{4601,4602},	-- 探宝活动

-----------------------------抢红包活动---------------------------
["GetActRedBagInfo"]			=	{4611,4612},	-- 红包活动信息
["DrawActRedBagStageAward"]		=	{4613,4614},	-- 领取红包活动阶段奖励
["GetActRedBagList"]			=	{4615,4616},	-- 获取红包列表
["GrabRedBag"]					=	{4617,4618},	-- 抢红包
-- ["GetRedBagDetail"]				=	{4619,4620},	-- 查看红包详细信息
["SendActRedBag"]				=	{4621,4622},	-- 发红包

-------------------------军衔信息------------------------------------
["GetMilitaryRank"]			= 	{5001,5002},	--获取玩家军衔军功相关信息
["UpMilitaryRank"]			=	{5003,5004},	--升级指挥官军衔


---------------------------战争武器（战鼓玩法）---------------------
["GetSecretWeaponInfo"]		=	{5151,5152},	-- 获取秘密武器信息
["UnlockWeaponBar"]		=	{5153,5154},	-- 解锁秘密武器技能
["LockedWeaponBar"]			=	{5155,5156},	-- 秘密武器加锁解锁
["StudyWeaponSkill"]		=	{5157,5158},	-- 洗练秘密武器技能

---------------------------战斗特效---------------------
["GetAttackEffect"]			=	{5201,5202},	-- 获取攻击特效列表
["UseAttackEffect"]			=	{5203,5204},	-- 使用攻击特效


-------------------------拇指广告------------------------------------------------

["GetLoginADStatus"]        =   {5601,5602},    --拉取登录观看广告活动状态
["PlayLoginAD"]            	=   {5603,5604},    --观看登录广告
["GetFirstGiftADStatus"]    =   {5605,5606},    --拉取首充奖励 观看广告 天数和当天次数
["PlayFirstGiftAD"]         =   {5607,5608},    --观看首充奖励广告
["AwardFirstGiftAD"]        =   {5609,5610},    --领取首充奖励
["GetExpAddStatus"]         =   {5611,5612},    --经验加成广告状态
["PlayExpAddAD"]         	=   {5613,5614},    --播放经验加成广告
["GetDay7ActLvUpADStatus"]  =   {5615,5616},    --秒升一级 活动状态
["PlayDay7ActLvUpAD"]  		=   {5617,5618},    --观看秒升一级 活动广告
["GetStaffingAddStatus"]  	=   {5619,5620},    --编制加成广告状态
["PlayStaffingAddAD"]  		=   {5621,5622},    --观看编制加成广告
["PlayAddPowerAD"]  		=   {5623,5624},    --播放体力增加的广告
["PlayAddCommandAD"]  		=   {5625,5626},    --播放统率书增加的广告
["GetAddPowerAD"]  			=   {5627,5628},    --获取体力增加的广告
["GetAddCommandAD"]  		=   {5629,5630},    --获取统率书增加的广告


------------------------- 皮肤管理 -------------------------
["GetSkins"]				= 	{5811,5812},	--获取皮肤
["BuySkin"]					=	{5813,5814},	--购买皮肤
["UseSkin"]					=	{5815,5816},	--使用皮肤


["GetActChooseGift"]		=	{5901,5902},	--进入自选豪礼界面
["DoActChooseGift"]			=	{5903,5904},	--自选豪礼领取奖励
["GetActBrotherTask"]		=	{5905,5906},	--获取兄弟同心活动界面信息
["UpBrotherBuff"]			=	{5907,5908},	--升级buffer
["GetBrotherAward"]			=	{5909,5910},	--领取奖励


------------------------- 作战实验室 -------------------------
["GetFightLabItemInfo"]		=	{6001,6002},	-- 作战实验室获取物品信息 和 产出的资源信息
["GetFightLabInfo"]			=	{6003,6004},	-- 作战实验室获取人员信息 科技信息 建筑信息
["SetFightLabPersonCount"]	=	{6005,6006},	-- 作战实验室设置人员信
["UpFightLabTechUpLevel"]	=	{6007,6008},	-- 作战实验室 科技升级
["ActFightLabArchAct"]		=	{6009,6010},	-- 作战实验室 建筑激活
["GetFightLabResource"]		=	{6011,6012},	-- 作战实验室 领取生产的资源
["GetFightLabGraduateInfo"]			=	{6013,6014},	-- 作战实验室 获取深度研究所信息
["UpFightLabGraduateUp"]			=	{6015,6016},	-- 作战实验室 深度研究所 升级
["GetFightLabGraduateReward"]		=	{6017,6018},	--作战实验室 获取领取奖励信息
["GetFightLabSpyInfo"]		=	{6019,6020},	-- 作战实验室 获取间谍信息
["ActFightLabSpyArea"]		=	{6021,6022},	-- 作战实验室 间谍地图激活
["RefFightLabSpyTask"]		=	{6023,6024},	-- 作战实验室 间谍任务刷新
["ActFightLabSpyTask"]		=	{6025,6026},	-- 作战实验室 间谍任务派遣
["GctFightLabSpyTaskReward"]		=	{6027,6028},	-- 作战实验室 间谍任务领取奖励
["ResetFightLabGraduateUp"] =	{6029, 6030},

-------------------------红色方案活动------------------------------------------
["GetRedPlanInfo"]          =   {6200,6201},    --红色方案获取信息
["MoveRedPlan"]             =   {6202,6203},    --红色方案移动格子
["RedPlanReward"]           =   {6204,6205},    --红色方案兑换物品
["RedPlanBuyFuel"]          =   {6206,6207},    --红色方案购买燃料
["GetRedPlanBox"]           =   {6208,6209},    --红色方案领取通关宝箱
["GetRedPlanAreaInfo"]      =   {6210,6211},    --红色方案获取某个区域块内信息
["RefRedPlanArea"]			=	{6212,6213},	--红色方案扫荡

["GetGuideReward"]			=	{6300,6301},	--新手引导获取奖励

-------------------------节日碎片活动------------------------------------------
["GetFestivalInfo"]         = 	{6500,6501},    --获取活动信息
["GetFestivalReward"]       = 	{6502,6503},    --商店兑换
["GetFestivalLoginReward"]  = 	{6504,6505},    --领取登录奖励

-------------------------幸运奖池------------------------------------------
["GetActLuckyInfo"]			=	{6600,6601},	--幸运奖池获取信息
["GetActLuckyReward"]		=	{6602,6603},	--幸运奖池单次抽取
["ActLuckyPoolGoldChange"]	=	{6604,6605},	--幸运奖池 同步奖金池 推送
["GetActLuckyPoolLog"]		=	{6606,6607},	--幸运奖池 获取中奖纪录

--------------------------坦克转换------------------------------------------
["GetTankConvertInfo"]      =   {7002, 7003},
["TankConvert"]             =   {7000, 7001},

--------------------------图纸兑换-----------------------------------------
["GetDrawingCash"]          =   {7100,7101}, --获取信息
["RefshDrawingCash"]        =   {7102,7103}, --刷新
["DoDrawingCash"]           =   {7104,7105}, --兑换

--------------------------装备升星-----------------------------------------
["UpEquipStarLv"]           =   {7200,7201}, --升星
-------------------------跨服服务器----------------------------------
["GetCrossServerList"]		=	{951,952},		-- 获取参加跨服战的服务器列表
["GetCrossFightState"]		=	{953,954},		-- 获取跨服战状态
["CrossFightReg"]			=	{955,956},		-- 跨服战报名
["GetCrossRegInfo"]			=	{957,958},		-- 获取跨服战报名信息
["CancelCrossReg"]			=	{959,960},		-- 取消跨服战报名
["GetCrossForm"]			=	{961,962},		-- 获取跨服战阵型
["SetCrossForm"]			=	{963,964},		-- 设置跨服战阵型
["GetCrossPersonSituation"]	=	{965,966},		-- 获取跨服战个人战况
["GetCrossJiFenRank"]	    =	{967,968},		-- 获取跨服战积分排名
["GetCrossReport"]			=	{969,970},		-- 获取跨服战战报
["GetCrossKnockCompetInfo"]	=	{971,972},		-- 获取跨服战淘汰赛比赛信息
["GetCrossFinalCompetInfo"]	=	{973,974},		-- 获取跨服战总决赛比赛信息
["BetBattle"]				=   {975,976},		-- 比赛下注
["GetMyBet"]				=	{977,978},		-- 获取我的下注
["ReceiveBet"]				=	{979,980},		-- 领取下注
["GetCrossShop"]			=	{3101,3102},	-- 获取跨服战商店数据
["ExchangeCrossShop"]		=	{3103,3104},	-- 兑换跨服战商店的物品
["GetCrossTrend"]		    =	{3105,3106},	-- 获取跨服战积分详情
["GetCrossFinalRank"]		= 	{3107,3108},	-- 获取总排行
["ReceiveRankRward"]		=	{3109,3110},	-- 领取排行奖励
["SynCrossState"]			=	{1033,1034},	-- 通知跨服战报名开启
["GetCrossRank"]            =   {3111,3112},	-- 获取跨服排行榜

-- 跨服军团战
["GetCrossPartyState"]		=	{3201,3202},	 -- 获取跨服军团状态
["SynCrossPartyState"]		=	{1035,1036},	 -- 通知跨服军团状态
["GetCrossPartyServerList"]	=	{3205,3206},	 -- 获取跨服军团服务器列表
["CrossPartyReg"]			=	{3207,3208},     -- 跨服军团战报名
["GetCPMyRegInfo"]			=	{3209,3210},	 -- 获取军团我的报名状态
["GetCrossPartyMember"]		=	{3211,3212},	 -- 获取报名跨服军团成员列表
["GetCrossParty"]           =   {3213,3214},     -- 获取参加跨服军团
["GetCPSituation"]			=	{3215,3216},	 -- 获取跨服军团状况
["GetCPOurServerSituation"]	=	{3217,3218},	 -- 获取跨服军团本服战况
["GetCPReport"]				=   {3221,3222},	 -- 获取跨服军团战报
["GetCPRank"]               =   {3223,3224},	 -- 获取跨服军团排名
["ReceiveCPReward"]			=   {3225,3226},	 -- 领取跨服军团奖励
["GetCPShop"]				=	{3227,3228},	 -- 获取跨服军团商店数据
["ExchangeCPShop"]			=	{3229,3230},	 -- 兑换跨服军团商店的物品
["GetCPForm"]				=	{3233,3234},	 -- 获取跨服军团阵型
["SetCPForm"]				=	{3235,3236},	 -- 设置跨服军团阵型
["GetCPTrend"]				=	{3237,3238}, 	 -- 获取跨服军团积分详情
["SynCPSituation"]			=	{1037,1038},	 -- 同步小组赛战况
----------------------------------------------------------------------------------------------跨服服务器----
-----------勋章精炼-------------------
["TransMedal"]			    =	{3357,3358},	 -- 勋章精炼
-----------勋章精炼end----------------
-------超时空财团---------------------
["ShowQuinn"]               =   {5911,5912},     -- 刷新显示
["BuyQuinn"]                =   {5913,5914},     -- 物品购买
["GetQuinnAward"]           =   {5915,5916},     -- 领取奖品
-------超时空财团end------------------

------------------点击宝箱获得奖励----------------------
["GetGiftReward"]			=	{6100,6101},	-- 点击宝箱获得奖励
--------------------------------------------------------
["GetRebelBoxAward"]		=	{6700,6701},	--
["GrabRebelRedBag"]			=	{6702,6703},	--

["SynFortressSelf"]		=   {1031,1032},
["SynInnerModProps"]	=	{1039,1040},   -- 道具数量推送		

["UnLockMilitaryGrid"]	= {845,846},
["GetPendant"]			= {847,848},
["SynChat"]				= {1001},
["SynMail"]				= {1003, 1004},
["SynInvasion"]			= {1005, 1006},
["SynPartyOut"]			= {1007},
["SynPartyAccept"]		= {1009, 1010},
["SynBless"]			= {1011, 1012},
["SynArmy"]				= {1013},
["SynGold"]				= {1015, 1016},
["SynApply"]			= {1017, 1018},
["SynWarRecord"]		= {1019, 1020},
["SynWarState"]			= {1021, 1022},
["SynResource"]			= {1023, 1024},
["SynBuild"]			= {1025},
["SynStaffing"]			= {1027},
["SynUnlockTechnical"]  = {1041,1042},
--------------新活跃度-----------------------------------------------
["NewGetLiveTask"]      = {5801,5802},
["NewTaskLiveAward"]    = {5803,5804},
["GetHeroPutInfo"]      = {5101,5102}, --文官入驻信息
["SetHeroPut"]          = {5103,5104}, --设置文官入驻

----------------飞艇的通知消息
["SynAirshipTeamArmy"]  = {1067},  ------同步队伍部队状态
["SynAirshipTeam"]  	= {1069},  ------队伍ID也就是飞艇ID
["SynAirshipChange"]  	= {1071},  ------同步飞艇变化

---------------邮件一键领取
["RewardAllMail"]       = {5821,5822}, --邮件一键领取
["CollectionsMail"]     = {5823,5824}, --邮件删除
["SyncMail"]            = {1073},   --邮件到期删除推送

---------------外挂处理
["PlugInScoutMineValidCode"]	=	{8001,8002},	--矿点扫描外挂验证码回答
["SynPlugInScoutMine"]			=	{1081},			--通知玩家已被标记为正在使用扫矿外挂需要输入验证码来取消

---------------- 兄弟同心（飞艇BUFF）-----------
["SynBrother"]			= {1075},	-- 激活/升级某个技能时广播的消息
["SynAirShipFightTask"]	= {1077},	-- 打完飞艇或占领飞艇时广播消息

---------------- 系统 --------------
["SynLoginElseWhere"]	= {1079},	-- 通知玩家在别处登录

---------------- 红包 ------------------
["SynSendActRedBag"]	= {1083},	-- 红包主推聊天
---------------- 赏金 ------------------
["CreateTeam"]			= {6400, 6401},
["JoinTeam"]			= {6402, 6403},
["LeaveTeam"]			= {6404, 6405},
["KickOut"]				= {6406, 6407},
["DismissTeam"]			= {6408, 6409},
["FindTeam"]			= {6410, 6411},
["ChangeMemberStatus"]	= {6412, 6413},
["ExchangeOrder"]		= {6414, 6415},
["TeamChat"] = {6416, 6417},
["LookMemberInfo"] = {6418, 6419},
["InviteMember"] = {6420, 6421},
["TeamInstanceExchange"] = {6424, 6425},
["GetBountyShopBuy"] = {6426, 6427},
["GetTaskRewardStatus"] = {6428, 6429},
["GetTaskReward"]		= {6430, 6431},
["TeamFightBoss"]		= {6432, 6433},
["GetTeamFightBossInfo"] = {6434, 6435},
["ResetMilitaryScience"] = {6800, 6801},
["GetCrossServerInfo"] = {8723, 8724},  --跨服信息

-----------------------部件转换-------------------------
["PartConvert"] = {6900, 6901},
-----------------------幸运转盘每日目标-------------------------
["GetActFortuneDayInfo"] = {7300, 7301},
["GetFortuneDayAward"] = {7303, 7304},
["GetEnergyDialDayInfo"] = {7305, 7306},
["GetEnergyDialDayAward"] = {7307, 7308},
-----------------------装备转盘---------------------------------
["GetActEquipDial"] = {7309, 7310},
["GetActEquipDialRank"] = {7311, 7312},
["DoActEquipDial"] = {7313, 7314},
["GetEquipDialDayInfo"] = {7315, 7316},
["GetEquipDialDayAward"] = {7317, 7318},
-----------------------活动道具批量购买/兑换---------------------
["BuyInBuck"]          = {7323,7324},
----------------------勋章分解------------------------------------
["GetActMedalResolve"] = {7319, 7320},
["DoActMedalResolve"] = {7321, 7322},
----------------------首冲新活动------------------------------------
["GetActNewPayInfo"] = {7400, 7401},
["ActTechInfo"]      = {7402,7403}, --科技加速活动

["GetActNew2PayInfo"] = {7406, 7407},
----------------------福利特惠----------------------------------
["GetBoxInfo"]       = {7500,7501}, --获取信息
["BuyBox"]           = {7502,7503}, --购买
--活跃宝箱
["GetActiveBoxAward"] = {7700,7701},
--建筑加速
["ActBuildInfo"]      = {7404,7405},
--侦察验证
["GetScoutFreeTime"] = {7600,7601},
["VCodeScout"] = {7602,7603},
["RefreshScoutImg"] = {7604,7605},
-- 
["GetHonourRank"] = {7710, 7711},
["GetHonourRankAward"] = {7712, 7713},
["HonourCollectInfo"] = {7714, 7715},
["QuickUpMedal"] = {7716,7717},
--登录福利
["GetLoginWelfareInfo"] = {7718,7719}, --获取活动信息
["GetLoginWelfareAward"] = {7720,7721}, --领奖
--军备套装
["SetLeqScheme"]      = {7722,7723}, -- 设置套装
["PutonLeqScheme"]    = {7724,7725}, -- 读取并穿戴
["GetAllLeqScheme"]   = {7726,7727}, -- 获取所有套装
["LordEquipInherit"]  = {4285,4286}, -- 军备第二套属性解锁
["SetLordEquipUseType"] = {4287,4288}, -- 设置军备使用的是第几套属性
--荣耀积分金币
["HonourScoreGoldInfo"] = {7732,7733}, -- 获取信息
["GetHonourScoreGold"]  = {7734,7735}, -- 领奖

["GetHonourStatus"] = {7730, 7731},
["GetNewHeroInfo"] = {7800, 7801},
["ClearHeroCd"] = {7802, 7803},
["GetHeroCd"] = {7804, 7805},
["GetHeroEndTime"] = {7806, 7807},

--军团副本一键
["GetAllPcbtAward"]          = {7900,7901},  --领奖
["DonateAllPartyRes"]        = {7902,7903},--一键捐献军团大厅
["DonateAllPartyScience"]    = {7904,7905},--一键捐献军团科技
["QueSendAnswer"]            = {7906,7907}, --提交问卷
["GetQueAwardStatus"]        = {7908,7909}, --获取活动状态
["GetAllSpyTaskReward"]      = {6031,6032},--一键领取作战实验室

-- 世界矿点
["GetWorldStaffing"]         = {8100, 8101}, --

-- 神秘部队
["GetNewPayEveryday"]        = {8201, 8202},
["GetPartyRecharge"]         = {8203, 8204}, --军团充值活动
["GetWarActivityInfo"]          = {8300, 8301},  --军团活跃活动
["GetWarActivityReward"]        = {8302, 8303},  --军团活跃活动领奖
["GetFeedAltarBoss"]         = {8400, 8401}, -- 军团BOSS获得资源捐献信息
["GetFeedAltarContriBute"]         = {8402, 8403}, -- 军团BOSS资源捐献

-- 最强王者活动
["GetPsnKillRank"]           = {8600,8601},  --最强王者获取活动信息
["GetAllRanks"]              = {8602,8603},  --获取活动总榜信息
["GetRanksInfo"]             = {8604,8605},  --获取活动分榜信息
["GetKingRankAward"]         = {8606,8607},  --领奖
["GetKingAward"]             = {8608,8609},  --领个人积分奖

-- 好友相关
["FriendGiveProp"]           = {8610,8611}, -- 赠送道具


--战术
["GetTactics"]                  = {8500,8501},  --拉取战术信息
["UpgradeTactics"]              = {8502,8503},  --战术升级
["TpTactics"]                   = {8504,8505},  --战术突破
["AdvancedTactics"]             = {8506,8507},  --战术进阶
["ComposeTactics"]              = {8508,8509},  --战术合成
["SetTacticsForm"]              = {8510,8511},  --战术设置阵型
["BindTacticsForm"]             = {8512,8513},  --战术锁定/解锁
["SynTactics"]                  = {1087},       --推送

--一键扫荡
["GetWipeInfo"]                 = {8700,8701},  --获取冒险关卡扫荡信息
["SetWipeInfo"]                 = {8702,8703},  --设置冒险关卡扫荡信息
["GetWipeRewar"]                = {8704,8705},  --设置冒险关卡扫荡信息

--能源核心
["EnergyCore"]                 = {8719,8720},  --获取当前信息
["SmeltCoreEquip"]             = {8721,8722},  --熔炼

--战术转盘活动
["GetActTicDial"]               = {8709,8710},
["GetActTicDialRank"]           = {8711,8712},
["DoActTicDial"]                = {8713,8714},
["GetTicDialDayInfo"]           = {8715,8716},
["GetTicDialDayAward"]          = {8717,8718},

--跨服军矿
["GetCrossSeniorMap"] = {8725, 8726},
["SctCrossSeniorMine"] = {8727, 8728},
["AtkCrossSeniorMine"] = {8729, 8730},
["CrossScoreRank"] = {8731, 8732},
["CrossScoreAward"] = {8733, 8734},
["CrossServerScoreRank"] = {8735, 8736},
["CrossServerScoreAward"] = {8737, 8738},

["SynTeamInfo"] = {1050},
["SynNotifyDisMissTeam"] = {1051},
["SynNotifyKickOut"] = {1052},
["SynChangeStatus"] = {1053},
["SynTeamOrder"] = {1054},
["SynTeamChat"] = {1055},
["SynStageCloseToTeam"] = {1056},
["SyncTeamFightBoss"] = {1057},
["SyncActNewPayInfo"] = {1059},
["SyncActNew2PayInfo"] = {1060},
["SynActiveBoxDrop"] = {1100}, --活跃宝箱
["SynHonourSurviveOpen"] = {1101},
["SynUpdateSafeArea"] = {1102},
["SynNextSafeArea"] = {1103},
["SynWorldStaffing"] = {1084},
["SynWarActivityInfo"] = {1085}, --军团活跃活动推送
["SynFeedAltarContriButeExp"] = {1086}, --军团BOSS推送
["SynFriendliness"] = {1088}, --友好度推送
["RebelBoosState"] = {1089}, --叛军BOSS推送
["RebelBoosEffect"] = {1090}, --叛军BOSS死亡推送
["SynCrossServerInfo"] = {1091}, --跨服组队副本推送
}

-- 根据Request的值101、103等等建立map
PbRequest = {}

-- 根据Response的返回码102、104、等等建立map
PbResponse = {}

function PbList_init()
	for name, code in pairs(PbList) do
		if code[1] then
			PbRequest[code[1]] = name
		end

		if code[2] then
			PbResponse[code[2]] = name
		end
	end
	-- gdump(PbResponse, "PbList init")
end
