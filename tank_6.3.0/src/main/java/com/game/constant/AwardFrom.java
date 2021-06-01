/**
 * @Title: GoldGive.java
 * @Package com.game.constant
 * @Description:
 * @author ZhangJun
 * @date 2015年8月10日 下午1:39:52
 * @version V1.0
 */
package com.game.constant;

/**
 * @author ZhangJun
 * @ClassName: AwardFrom
 * @Description: 奖励来源，要细分记录
 * @date 2015年8月10日 下午1:39:52
 */
public enum AwardFrom {
    CAIZHENG(2, "CAI ZHENG GUAN") {// 财政官收入

    },
    RED_PACKET(3, "RED PACKET") {// 红包奖励

    },
    ASSEMBLE_MECHA(4, "JI JIA HONG LIU") {// 机甲洪流奖励

    },
    HALF_COST(5, "HALF COST") {// 半价购买

    },
    ACTIVITY_AWARD(6, "ACTIVITY AWARD") {// 活动奖励

    },
    ARENA_SCORE(7, "ARENA SCORE") {// 竞技场积分兑换

    },
    ARENA_RANK(8, "ARENA RANK") {// 竞技场排名奖励

    },
    HUANGBAO_BOX(9, "HUANGBAO BOX") {// 兑换荒宝宝箱

    },
    PART_BOX(10, "PART BOX") {// 配件副本开箱子

    },
    EQUIP_BOX(11, "EQUIP BOX") {// 装备副本开箱子

    },
    COMBAT_BOX(12, "COMBAT BOX") {// 普通副本开箱子

    },
    COMBAT_FIRST(13, "COMBAT FIRST") {// 副本首次过关奖励

    },
    COMBAT_DROP(14, "COMBAT EXPLORE EXTREME DROP") {// 副本掉落

    },
    HERO_DECOMPOSE(15, "HERO DECOMPOSE") {// 将领分解

    },
    LOTTERY_HERO(16, "LOTTERY_HERO") {// 武将招募

    },
    MAIL_ATTACH(17, "MAIL ATTACH") {// 领取邮件附件

    },
    PARTY_SHOP(18, "PARTY SHOP") {// 军团商店兑换

    },
    PARTY_COMBAT(19, "PARTY COMBAT") {// 打军团副本

    },
    PARTY_COMBAT_BOX(20, "PARTY COMBAT BOX") {// 军团副本开箱子

    },
    PARTY_WEAL_DAY(21, "PARTY WEAL DAY") {// 军团每日福利

    },
    GIFT_CODE(22, "GIFT CODE") {// 兑换码

    },
    NEWER_GIFT(23, "NEWER GIFT") {// 新手引导礼包

    },
    OL_AWARD(24, "PORT ONLINE AWARD") {// 港口在线奖励

    },
    USE_PROP(25, "USE PROP") {// 使用道具

    },
    SIGN_AWARD(26, "SIGN AWARD") {// 签到奖励

    },
    FIGHT_MINE(27, "FIGHT MINE DROP") {// 世界地图攻打资源点，随机掉落

    },
    WASTE_SMALL(28, "WASTE_SMALL") {// 荒宝小

    },
    WASTE(29, "WASTE") {// 荒宝小

    },
    WASTE_LARGE(30, "WASTE_LARGE") {// 荒宝大

    },
    EXPLORE_SINGLE(31, "EXPLORE_SINGLE") {// 探宝箱子

    },
    EXPLORE_THREE(32, "EXPLORE_THREE") {// 三被探宝

    },
    GREEN_SINGLE(33, "GREEN_SINGLE") {// 绿色单抽

    },
    BLUE_SINGLE(34, "BLUE_SINGLE") {// 蓝色单抽

    },
    PURPLE_SINGLE(35, "BLUE_SINGLE") {// 紫色单抽

    },
    PURPLE_NINE(36, "PURPLE_NINE") {// 紫色多抽

    },
    TASK_DAYIY_AWARD(37, "TASK_AWARD") {// 主线/日常任务奖励

    },
    TASK_LIVILY_AWARD(38, "TASK_AWARD") {// 活跃活动

    },
    PAY(39, "PAY") {// 充值

    },
    PART_EVOLVE(40, "PART_EVOLVE") {// 配件进阶

    },
    FLASH_SALE(41, "FLASH_SALE") {// 限时购买

    },
    FLASH_META(42, "FLASH_META") {// 限购材料

    },
    DAY_BUY(43, "DAY_BUY") {// 天天购买

    },
    AMY_REBATE(44, "AMY REBATE") {// 建军节返利

    },
    PAWN(45, "PAWN") {// 极限单兵

    },
    ACT_RANK_AWARD(46, "ACT_RANK_AWARD") {// 极限单兵

    },
    SIGN_LOGIN(47, "SIGN LOGIN") {// 签到登录奖励

    },
    PART_DIAL(48, "PART_DIAL") {// 配件转盘

    },
    COMBAT_COURSE(49, "COMBAT_COURSE") {// 关卡拦截

    },
    PARTY_AMY_PROP(50, "PARTY_AMY_PROP") {// 军团战事福利

    },
    USE_AMY_PROP(51, "USE_AMY_PROP") {// 使用军团福利坦克箱子

    },
    WAR_WIN(52, "WAR WIN RANK") {// 百团混战连胜排名奖励

    },
    WAR_PARTY(53, "WAR IN PARTY") {// 百团混战贡献度奖励

    },
    ACTIVITY_TECH(54, "ACTIVITY TECH") {// 技术革新

    },
    ATTACK_BOSS(55, "ATTACK BOS") {// 挑战boss

    },
    BOSS_HURT(56, "BOSS HURT RANK") {// 世界boss伤害排名奖励

    },
    ACTIVITY_GENERAL(57, "ACTIVITY GENERAL") {// 招募武将

    },
    PARTY_TIP_AWARD(58, "PARTY TIP AWARD") {// 军团tip奖励

    },
    EVERY_DAY_PAY(59, "EVERY_DAY_PAY") {// 每日充值

    },
    VIP_GIFT(60, "VIP_GIFT") {// vip礼包

    },
    CONSUME_DIAL(61, "CONSUME_DIAL") {// 消费转盘

    },
    VACATION(62, "VACATION") {// 度假胜地

    },
    EXCHANGE_PART(63, "EXCHANGE_PART") {// 兑换配件

    },
    EXCHANGE_EQUIP(64, "EXCHANGE_EQUIP") {// 兑换装备

    },
    PART_RESOLVE(65, "PART_RESOLVE") {// 兑换装备

    },
    TOPUP_GAMBLE(66, "TOPUP_GAMBLE") {// 充值下注 下注投入

    },
    SCORE_AWARD(67, "SCORE AWARD") {// 军事矿区个人积分排名奖励

    },
    PARTY_SCORE_AWARD(68, "PARTY SCORE AWARD") {// 军事矿区军团积分排名奖励

    },
    PAY_TURN_TABLE(69, "PAY_TURN_TABLE") {// 充值转盘

    },
    PRAY_AWARD(70, "PRAY_AWARD") {// 祈福奖励

    },
    ACTIVITY_MINE(71, "ACTIVITY_MINE") {// 活动矿掉落

    },
    ACT_M1A2(72, "ACT_M1A2") {// M1A2掉落

    },
    FRIEND_BLESS(73, "FRIEND_BLESS") {// 好友祝福
    },
    ACT_PROFOTO(74, "ACT_PROFOTO") {// 哈洛克宝藏
    },
    SPEED_TANK_QEU(75, "SPEED_TANK_QEU") {// 加速坦克生产
    },
    SPEED_REFIT_QEU(76, "SPEED_REFIT_QEU") {// 改装坦克加速
    },
    BUILD_TANK(77, "BUILD_TANK") {// 生产坦克
    },
    REFIT_TANK(78, "REFIT_TANK") {// 改装坦克
    },
    BUILD_QUE(79, "BUILD_QUE") {// 建筑加速
    },
    HERO_UP(80, "HERO_UP") {// 武将升级
    },
    HERO_IMPROVE(81, "HERO_IMPROVE") {// 武将进阶
    },
    UP_COMMAND(82, "UP_COMMAND") {// 统帅升级
    },
    UP_SKILL(83, "UP_SKILL") {// 技能升级
    },
    COMPOSE_SANT(84, "COMPOSE_SANT") {// 将神魂
    },
    BUILD_PROP(85, "BUILD_PROP") {// 制造车间生产道具
    },
    SPEED_SCIENCE_QUE(86, "SPEED_SCIENCE_QUE") {// 加速科技研发
    },
    MOVE_HOME(87, "MOVE_HOME") {// 搬家
    },
    DO_ARENA(88, "DO_ARENA") {// 竞技场挑战
    },
    CANCEL_TANK_QUE(89, "CANCEL_TANK_QUE") {// 取消生产坦克队列
    },
    CANCEL_REFIT_QUE(90, "CANCEL_REFIT_QUE") {// 取消改装坦克队列
    },
    RESET_SKILL(91, "RESET_SKILL") {// 重置技能
    },
    BUY_PROP(92, "BUY_PROP") {// 购买道具
    },
    CANCEL_PROP_QUE(93, "CANCEL_PROP_QUE") {// 取消制造车间道具生产
    },
    SELL_EQUIP(94, "SELL_EQUIP") {// 出售装备
    },
    EAT_EQUIP(95, "EAT_EQUIP") {// 喂养装备
    },
    COMBINE_PART(96, "COMBINE_PART") {// 合成配件
    },
    EXPLODE_PART(97, "EXPLODE_PART") {// 分解配件
    },
    EXPLODE_CHIP(98, "EXPLODE_CHIP") {// 分解配件碎片
    },
    RETREAT_END(100, "RETREAT_END") {// 矿区部队召回
    },
    CANCEL_ARMY(101, "CANCEL_ARMY") {// 取消部队
    },
    ELIMINATE_GUARD(102, "ELIMINATE_GUARD") {// 取消部队
    },
    BACK_HERO(103, "BACK_HERO") {// 回收武将
    },
    BUY_FAME(104, "BUY_FAME") {// 购买声望
    },
    CLICK_FAME(105, "CLICK_FAME") {// 领取军衔声望
    },
    UNDERGO_GRAB(106, "UNDERGO_GRAB") {// 被掠夺资源
    },
    GAIN_GRAB(107, "GAIN_GRAB") {// 掠夺资源
    },
    UP_BUILD(108, "UP_BUILD") {// 升级建筑
    },
    CANCEL_BUILD_QUE(109, "CANCEL_BUILD_QUE") {// 取消建筑队列
    },
    UP_MILL(110, "UP_MILL") {// 升级城外建筑
    },
    DO_AUTO_MILL(111, "DO_AUTO_MILL") {// 自动升级建筑
    },
    UP_PART(112, "UP_PART") {// 升级配件
    },
    DONATE_PARTY(113, "DONATE_PARTY") {// 军团大厅捐献
    },
    WEAL_DAY(114, "WEAL_DAY") {// 军团福利大厅
    },
    DONATE_SCIENCE(115, "DONATE_SCIENCE") {// 军团科技大厅
    },
    UP_RANK(116, "UP_RANK") {// 升级军衔
    },
    UP_SCIENCE(117, "UP_SCIENCE") {// 升级科技
    },
    CANCEL_SCIENCE_QUE(118, "CANCEL_SCIENCE_QUE") {// 取消科技升级
    },
    SCOUT_MINE(119, "SCOUT_MINE") {// 侦查矿
    },
    SCOUT_HOME(120, "SCOUT_HOME") {// 侦查基地
    },
    REFIT_PART(121, "REFIT_PART") {// 改造配件
    },
    ATK_SENIOR_MINE(122, "ATK_SENIOR_MINE") {// 进攻军事矿区
    },
    WAR_REG(123, "WAR_REG") {// 百团混战
    },
    ATTACK_POS(124, "ATTACK_POS") {// 进攻坐标点
    },
    GUARD_POS(125, "GUARD_POS") {// 设置防守
    },
    REFIT_TANK_COMPLETE(126, "REFIT_TANK_COMPLETE") {// 改装坦克完成
    },
    TANK_COMPLETE(127, "TANK_COMPLETE") {// 生产坦克完成
    },
    MILITARY_REFIT_TANK(128, "MILITARY_REFIT_TANK") {// 军工科技改造
    },
    UNLOCK_SCIECE_GRID(129, "UNLOCK_SCIECE_GRID") {// 解锁军工科技格子
    },
    UP_MILITARY_SCIENCE(130, "UP_MILITARY_SCIENCE") {// 升级军工科技
    },
    ACTIVITY_DAY_BUY(131, "ACTIVITY_DAY_BUY") {// 坦克拉霸
    },
    BUY_ARENA(132, "BUY_ARENA") {// 购买竞技场
    },
    ARENA_CD(133, "ARENA_CD") {// 消除arena cd
    },
    REPAIR_TANK(134, "REPAIR_TANK") {// 修复坦克
    },
    BLESS_FIGHT(135, "BLESS_FIGHT") {// 世界boss祝福
    },
    BOSS_CD(136, "BOSS_CD") {// 世界CD
    },
    BUY_AUTO_BUILD(137, "BUY_AUTO_BUILD") {// 购买建筑自动升级
    },
    BUY_EXPLORE(138, "BUY_EXPLORE") {// 购买副本次数
    },
    BUY_MILITARY(139, "BUY_MILITARY") {// 购买军工探险次数
    },
    PARTY_CREATE(140, "PARTY_CREATE") {// 创建军团
    },
    BUY_POWER(141, "BUY_POWER") {// 购买能量
    },
    BUY_PROSP(142, "BUY_PROSP") {// 购买繁荣度
    },
    BUY_BUILD(143, "BUY_BUILD") {// 购买建筑位
    },
    SPEED_PROP_QUE(144, "SPEED_PROP_QUE") {// 生产道具加速
    },
    BUY_SENIOR(145, "BUY_SENIOR") {// 购买军事矿区掠夺次数
    },
    TASK_DAYLY_RESET(146, "TASK_DAYLY_RESET") {// 重置日常任务
    },
    REFRESH_DAYIY_TASK(147, "REFRESH_DAYIY_TASK") {// 刷新日常任务
    },
    SPEED_ARMY(148, "SPEED_ARMY") {// 加速行军
    },
    UP_CAPACITY(149, "UP_CAPACITY") {// 装备仓库扩充
    },
    ATTACK_MINE(150, "ATTACK_MINE") {// 打世界矿
    },
    ATTACK_SOMEONE_MINE(151, "ATTACK_SOMEONE_MINE") {// 炸矿
    },
    SOMEONE_ATTACK_MINE(152, "SOMEONE_ATTACK_MINE") {// 矿被别人炸了
    },
    ATTACK_SOMEONE_HOME(153, "ATTACK_SOMEONE_HOME") {// 攻打别人基地
    },
    SOMEONE_ATTACK_HOME(154, "SOMEONE_ATTACK_HOME") {// 基地被攻打
    },
    PAY_CONTINUE(155, "PAY_CONTINUE") {// 连续充值活动
    },
    PAY_FOISON(156, "PAY_FOISON") {// 充值丰收
    },
    FIGHT_BOSS(157, "FIGHT_BOSS") {// 打boss
    },
    GM_SEND(158, "GM_SEND") {// 充值丰收
    },
    PAY_FRIST(159, "PAY_FRIST") {// 首次充值
    },
    BUILD_UP_FINISH(160, "BUILD_UP_FINISH") {// 建筑升级完成
    },
    BUILD_REMOVE(161, "BUILD_REMOVE") {// 拆建筑
    },
    DEL_MAIL(162, "DEL_MAIL") {// 删除邮件
    },
    FORTRESS_JOB(163, "FORTRESS_JOB") {// 要塞职位
    },
    FORTRESS_FIGHT_OUT(164, "FORTRESS_JOB") {// 要塞出局
    },
    BUY_FORTRESS_CD(165, "BUY_FORTRESS_CD") {// 购买要塞CD
    },
    UP_FORTRESS_ATTR(166, "UP_FORTRESS_ATTR") {// 要塞进修
    },
    ENERGY_STONE_BOX(167, "ENERGY_STONE_BOX") {// 能晶副本箱子
    },
    ALTAR_BOSS_PARTICIPATE(168, "ALTAR_BOSS_PARTICIPATE") {// 祭坛BOSS参与奖励
    },
    ALTAR_BOSS_KILL(169, "ALTAR_BOSS_KILL") {// 祭坛BOSS最后一击
    },
    ALTAR_BOSS_HURT_RANK(170, "ALTAR_BOSS_HURT_RANK") {// 祭坛BOSS伤害排行
    },
    ALTAR_BOSS_BLESS_FIGHT(171, "BLESS_FIGHT") {// 购买祭坛BOSS祝福
    },
    ALTAR_BOSS_BUY_CD(172, "ALTAR_BOSS_BUY_CD") {// 消除祭坛BOSS的CD时间
    },
    ENERGY_STONE_COMBINE(173, "ENERGY_STONE_COMBINE") {// 能晶合成
    },
    ENERGY_STONE_EQUIP(174, "ENERGY_STONE_EQUIP") {// 能晶镶嵌、卸下
    },
    TREASURE_SHOP_BUY(175, "TREASURE_SHOP_BUY") {// 荒宝碎片兑换商店（宝物商店）购买
    },
    DRILL_RANK_AWARD(176, "DRILL_RANK_AWARD") {// 军事演习（红蓝大战）排行奖励
    },
    DRILL_PART_WIN_AWARD(177, "DRILL_PART_WIN_AWARD") {// 军事演习（红蓝大战）胜利方参与奖励
    },
    DRILL_PART_FAIL_AWARD(178, "DRILL_PART_FAIL_AWARD") {// 军事演习（红蓝大战）失败方参与奖励
    },
    DRILL_SHOP_EXCHANGE(179, "DRILL_SHOP_EXCHANGE") {// 军事演习（红蓝大战）军演商店兑换
    },
    DRILL_IMPROVE(180, "DRILL_IMPROVE") {// 军事演习（红蓝大战）演习进修
    },
    DRILL_FIGHT(181, "DRILL_IMPROVE") {// 军事演习（红蓝大战）战斗
    },
    DRILL_EXCHANGE_TANk(182, "DRILL_EXCHANGE_TANk") {// 军事演习（红蓝大战）兑换坦克
    },
    ACTIVITY_INVEST(183, "ACTIVITY_INVEST") {// 活动-投资计划
    },
    REBEL_PLAYER_RANK_REWARD(184, "REBEL_PLAYER_RANK_REWARD") {// 叛军入侵周个人排行奖励
    },
    SCOUT_REBEL(185, "SCOUT_REBEL") {// 叛军入侵 侦查叛军
    },
    ATTACK_REBEL(186, "ATTACK_REBEL") {// 叛军入侵 攻击叛军
    },
    REBEL_DISAPPEAR(187, "REBEL_DISAPPEAR") {// 叛军入侵 叛军消失，部队遣返
    },
    REBEL_BUFF_REWARD(188, "REBEL_BUFF_REWARD") {// 叛军入侵 叛军全部死亡，全服buff奖励
    },
    ACT_POWER_GIVE_REWARD(189, "ACT_POWER_GIVE_REWARD") {// 能量补给活动奖励
    },
    BUY_TANK_CARNIVAL(190, "BUY_TANK_CARNIVAL") {// 活动-坦克嘉年华，付费拉取奖励
    },
    TANK_CARNIVAL_REWARD(191, "TANK_CARNIVAL_REWARD") {// 活动-坦克嘉年华，拉取奖励
    },
    SMELT_PART(192, "SMELT_PART") {// 配件-淬炼
    },
    TEN_SMELT_PART(193, "TEN_SMELT_PART") {// 配件-淬炼-10次
    },
    HOME_DEFEND(194, "HOME_DEFEND") {// 创建基地防守阵型，拿走坦克数量，战斗完返还
    },
    FORTRESS_FORM(195, "FORTRESS_FORM") {// 要塞战设置防守阵型，拿走坦克数量，战斗完返还
    },
    FORTRESS_ATTACK(196, "FORTRESS_ATTACK") {// 要塞战攻击要塞损失
    },
    DO_COMBAT(197, "DO_COMBAT") {// 关卡挑战，损失坦克
    },
    GM_REMOVE_FORTRESS_ARMY(198, "GM_REMOVE_FORTRESS_ARMY") {// gm返回要塞战防守军团
    },
    GM_REMOVE_WAR_ARMY(199, "GM_REMOVE_WAR_ARMY") {// gm返回参与军团战部队
    },
    COLLECT_CHARACTER_CHANGE(200, "COLLECT_CHARACTER_CHANGE") {// 集字活动兑换
    },
    COLLECT_CHARACTER_COMBINE(201, "COLLECT_CHARACTER_COMBINE") {// 集字活动合成
    },
    CROSS_RECEIVE_BAT_JIFEN(202, "CROSS_RECEIVE_BAT_JIFEN") {// 领取跨服战下注积分
    },
    CROSS_TOP_SERVER_REWARD(203, "CROSS_TOP_SERVER_REWARD") {// 跨服全服奖励
    },
    CROSS_JIFEN_EXCHANGE(204, "CROSS_JIFEN_EXCHANGE") {// 跨服积分兑换
    },
    CROSS_BET(205, "CROSS_BET") { // 下注
    },
    CROSS_RANK_AWARD(206, "CROSS_RANK_AWARD") {// 跨服战排名奖励
    },
    BUY_ENERGY_STONE(207, "BUY_ENERGY_STONE") {// 购买能晶副本次数
    },
    UP_PART_QUALITY(208, "UP_PART_QUALITY") {// 进阶配件
    },
    DO_ACT_M1A2(209, "DO_ACT_M1A2") {// 探索m1a2活动
    },
    M1A2_REFIT_TANK(210, "M1A2_REFIT_TANK") {// m1a2坦克改造
    },
    WISH_FLOWER(211, "WISH_FLOWER") {// 鲜花祝福
    },
    ALL_ENERGY_STONE(212, "ALL_ENERGY_STONE") {// 一键镶嵌能晶
    },
    EQUIP_QUALITY_UP(213, "EQUIP_QUALITY_UP") {// 装备进阶
    },
    ACT_REBATE(214, "ACT_REBATE") {// 返利我做主返利
    },
    ACT_PIRATE_LOTTERY(215, "ACT_PIRATE_LOTTERY") {// 海贼宝藏抽奖
    },
    ACT_PIRATE_CHANGE(216, "ACT_PIRATE_CHANGE") {// 海贼宝藏兑换
    },
    ACT_PIRATE_RECEIVE(217, "ACT_PIRATE_RECEIVE") {// 海贼宝藏排名领取奖励
    },
    ACTIVITY_GOD_GENERAL(218, "ACTIVITY_GOD_GENERAL") {// 神将招募

    },
    COMBINE_MEDAL(219, "COMBINE_MEDAL") {// 合成勋章
    },
    EXPLODE_MEDAL(220, "EXPLODE_MEDAL") {// 分解勋章
    },
    EXPLODE_MEDAL_CHIP(221, "EXPLODE_MEDAL_CHIP") {// 分解勋章碎片
    },
    UP_MEDAL(222, "UP_MEDAL") {// 强化勋章
    },
    BUY_MEDAL_CD_TIME(223, "BUY_MEDAL_CD_TIME") {// 购买强化勋章CD
    },
    REFIT_MEDAL(224, "REFIT_MEDAL") {// 勋章改造
    },
    MEDAL_BOX(225, "PART BOX") {// 勋章副本开箱子

    },
    REPAIR_NAME(226, "REPAIR_NAME") {// 程序自动修复重复名字
    },
    ACT_CONTU_PAY_NEW(227, "ACT_CONTU_PAY_NEW") {// 新连续充值
    },
    BUY_SCOUT_CD_TIME(228, "BUY_SCOUT_CD_TIME") {// 修改侦查CD
    },
    DO_MEDAL_BOUNS(229, "DO_MEDAL_BOUNS") {// 勋章展示
    },
    DO_ACT_RECHARGE(230, "DO_ACT_RECHARGE") {// 连续充值
    },
    DO_SECTION_REWARD(231, "DO_SECTION_REWARD") {// 探险关卡奖励
    },
    ENERGYSTONE_DIAL(232, "PART_DIAL") {// 能晶转盘
    },
    CALL_ACT_BOSS(233, "CALL_ACT_BOSS") {// 召唤活动boss-机甲贺岁
    },
    ATTACK_ACT_BOSS(234, "ATTACK_ACT_BOSS") {// 挑战活动boss-机甲贺岁
    },
    BUY_ACT_PROP(235, "BUY_ACT_PROP") {// 购买活动道具
    },
    ACT_HILARITY_PRAY(236, "ACT_HILARITY_PRAY") {// 狂欢祈福
    },
    BUY_ACT_BOSS_CD_TIME(237, "BUY_ACT_BOSS_CD_TIME") {// 购买活动BOSSCD
    },
    RECV_DAY_7_ACT_AWARD(238, "RECV_DAY_7_ACT_AWARD") {// 领取7日活动奖励
    },
    ACT_OVER_REBATE_AWARD(239, "ACT_OVER_REBATE_AWARD") {// 清盘计划活动奖励
    },
    ACT_WORSHIP_GOD(240, "ACT_WORSHIP_GOD") {// 拜神许愿  拜神 支出
    },
    EXPLORE_GOLD_ONE(241, "EXPLORE_GOLD_ONE") {// 钻石探宝一抽
    },
    EXPLORE_GOLD_TEN(242, "EXPLORE_GOLD_TEN") {// 钻石探宝十抽
    },
    RECV_LOTTERY_LUCKY_AWARD(243, "RECV_LOTTERY_LUCKY_AWARD") {// 领取探宝幸运值奖励
    },
    ACT_REBEL_DISAPPEAR(244, "ACT_REBEL_DISAPPEAR") {// 活动叛军入侵 叛军消失，部队遣返
    },
    ATTACK_ACT_REBEL(245, "ATTACK_REBEL") {// 活动叛军入侵 攻击叛军
    },
    ACT_REBEL_RANK_REWARD(246, "ACT_REBEL_RANK_REWARD") {// 活动叛军领取排名奖励
    },
    HERO_AWAKEN(247, "HERO_IMPROVE") {// 武将觉醒
    },
    HERO_AWAKEN_SKILL_LV(248, "HERO_IMPROVE") {// 觉醒将领-技能升级
    },
    VIP_SHOP_BUY_GOODS(249, "VIP_SHOP_BUY_GOODS") {//VIP商店道具购买
    },
    WORLD_SHOP_BUY_GOODS(251, "WORLD_SHOP_BUY_GOODS") {//世界商店道具购买
    },
    DO_ACT_COLLEGE(252, "DO_ACT_COLLEGE") {// 西点学院进修
    },
    MONTH_SIGN(253, "MONTH_SIGN") {//每月签到
    },
    MONTH_SIGN_EXT(254, "MONTH_SIGN_EXT") {//每月签到额外奖励
    },
    FIRST_LOAD_AIRSHIP(255, "FIRST_LOAD_AIRSHIP") {// 飞艇载入
    },
    AIRSHIP_SET_FORM(256, "AIRSHIP_SET_FORM") {// 飞艇设置部队
    },
    AIRSHIP_TEAM_CANCEL(257, "AIRSHIP_TEAM_CANCEL") {// 飞艇团队解散
    },
    GUARD_AIRSHIP(258, "GUARD_AIRSHIP") {// 驻防飞艇
    },
    SCOUT_AIRSHIP(259, "SCOUT_AIRSHIP") {// 侦查飞艇
    },
    GUARD_ARMY_RETREAT(260, "GUARD_ARMY_RETREAT") {// 驻军返回
    },
    ATTACK_AIRSHIP(261, "ATTACK_AIRSHIP") {// 攻打飞艇
    },
    RECV_AIRSHIP_PRODUCE_AWARD(262, "RECV_AIRSHIP_PRODUCE_AWARD") {// 领取飞艇自产奖励
    },
    FORMULA_PRODUCT_PROP(263, "FORMULA_PRODUCT_PROP") {//通过合成公式合成道具
    },
    LORD_EQUIP_PRODUCT(264, "LORD_EQUIP_PRODUCT") {// 生产军备
    },
    LORD_EQUIP_RESLOVE(265, "LORD_EQUIP_RESLOVE") {// 军备分解
    },
    LORD_EQUIP_TECH_EMPLOY(266, "LORD_EQUIP_TECH_EMPLOY") {// 军备铁匠招募
    },
    LORD_EQUIP_GOLD_SPEED(267, "LORD_EQUIP_GOLD_SPEED") {// 金币加速军备生产
    },
    LORD_EQUIP_PRODUCT_FINISH(268, "LORD_EQUIP_PRODUCT_FINISH") {// 军备生产结束
    },
    LORD_EQUIP_MAT_PRO(269, "LORD_EQUIP_MAT_PRO") {// 军备材料生产
    },
    LORD_EQUIP_MAT_PRO_BUY(270, "LORD_EQUIP_MAT_PRO_BUY") {// 购买军备材料生产坑位
    },
    LORD_EQUIP_MAT_COLLECT(271, "LORD_EQUIP_MAT_COLLECT") {// 收取已经生产结束的军备材料
    },
    LOGIN_AD(272, "LOGIN_AD") {//观看广告给的奖励
    },
    UP_MILITARY_RANK(273, "LORD_EQUIP_MAT_COLLECT") {// 升级军衔
    },
    PART_SMELT_MASTER_LOTTERY(274, "LORD_EQUIP_MAT_COLLECT") {// 淬炼大师活动中氪金抽奖
    },
    TANK_DISAPPER(278, "SENIOR_FIGHT_LOST") {//战斗永久损失坦克
    },
    TANK_DESTROY(279, "SENIOR_FIGHT_DESTORY") {//战斗永久摧毁坦克
    },
    FIGHT_TANK_DISAPPER_AND_DESTROY(280, "FIGHT_TANK_DISAPPER_AND_DESTROY") {//战斗中坦克的消耗与摧毁
    },
    AIRSHIP_REBUILD(281, "AIRSHIP_REBUILD") {//飞艇重建
    },
    AIRSHIP_MARCH_RETREA(282, "AIRSHIP_REBUILD") {//行军中紧急撤销部队
    },
    AIRSHIP_GET_PRODUCT_RESOUCE(283, "AIRSHIP_GET_PRODUCT_RESOUCE") {//领取飞艇生产的资源
    },
    AIRSHIP_CREATE_TEAM(284, "AIRSHIP_CREATE_TEAM") {//创建飞艇进攻队伍
    },
    AIRSHIP_DEFENCE_FIGHT(285, "AIRSHIP_DEFENCE_FIGHT") {//飞艇驻军防守战斗
    },
    PLAYER_BACK_PAY(286, "PLAYER_BACK_PAY") {// 玩家回归
    },
    PLAYER_BACK_AWARD(287, "PLAYER_BACK_AWARD") {// 玩家回归
    },
    ACT_CUMULATIVE(288, "ACT_CUMULATIVE") {//能量灌注
    },
    LORD_EQUIP_CHANGE_FREE(289, "LORD_EQUIP_CHANGE_FREE") {//军备洗练免费洗练
    },
    LORD_EQUIP_CHANGE_GOLD(290, "LORD_EQUIP_CHANGE_GOLD") {//军备洗练至尊洗练
    },
    LORD_EQUIP_CHANGE_SUPER(291, "LORD_EQUIP_CHANGE_SUPER") {//军备洗练神秘洗练
    },
    AUTO_DEL_MAIL(292, "AUTO_DEL_MAIL") { //邮件到期或达到上限时自动删除邮件，记录帮用户收取附件
    },
    BUY_SKIN(293, "BUY_SKIN") { //购买皮肤
    },
    USE_SKIN(294, "USE_SKIN") { //使用皮肤
    },
    ACT_WORSHIP_GOD_ADD(295, " ACT_WORSHIP_GOD_ADD") { //拜神许愿 拜神收益
    },
    TOPUP_GAMBLE_ADD(296, "TOPUP_GAMBLE") {// 充值下注 下注收益
    },
    ACT_CHOOSE_GIFT(297, "ACT_CHOOSE_GIFT") { //自选豪礼
    },
    ACT_BROTHER_UP_BUFF(298, "ACT_BROTHER_UPDATE") { //兄弟同心升级buff
    },
    ACT_BROTHER_GET_AWARD(299, "ACT_BROTHER_UPDATE") { //兄弟同心获取奖励
    },
    TRANS_MEDAL(300, "TRANS_MEDAL") {// 精炼勋章
    },
    BUY_NAMEPLATE(301, "BUY_NAMEPLATE") {

    }, //购买铭牌
    BUY_BUBBLE(302, "BUY_BUBBLE") {

    }, //购买聊天气泡
    REFRESH_QUINNPANEL(303, "REFRESH_QUINNPANEL") {// 刷新超时空财团面板
    },
    QUINNPANEL_BUY(304, "QUINNPANEL_BUY") {// 购买超时空军团商品
    },
    GET_QUINN_AWARD(305, "GET_QUINN_AWARD") {// 购买超时空军团商品
    },
    GM_ADD_PARTY_PROP(306, "GM_ADD_PARTY_PROP") {// GM增加贡献
    },
    SEND_FORTRESS_DONATE(307, "SEND_FORTRESS_DONATE") {// 要塞战加贡献
    },
    ACT_MEDALOFHONOR_BOX(308, "荣誉勋章活动开宝箱奖励") {
    },
    ACT_MEDALOFHONOR_CHICKEN(309, "荣誉勋章活动吃鸡奖励") {
    },
    ACT_MEDALOFHONOR_SEARCH(310, "荣誉勋章活动索敌") {
    },
    ACT_MEDALOFHONOR_RANK(311, "荣誉勋章活动排名奖励") {
    },
    ACT_MEDALOFHONOR_SHOP_BUY(312, "荣誉勋章活动商店购买") {
    },
    SECRET_WEAPON_UNLOCK(313, "秘密武器解锁") {
    },
    SECRET_WEAPON_STUDY(314, "秘密武器洗练") {
    },
    ATTACK_EFFECT_DEFAULT(315, "默认开启攻击特效") {
    },
    ACT_MOMOPOLY_THROW_DICE(316, "大富翁扔骰子") {
    },
    ACT_MOMOPOLY_BUY_ENERGY(317, "大富翁购买精力") {
    },
    ACT_MOMOPOLY_USE_ENERGY_PROP(318, "大富翁使用精力道具") {
    },
    ACT_MOMOPOLY_BUY_GOODS(319, "大富翁购买买买买事件中的物品") {
    },
    ACT_MOMOPOLY_CHOOSE_DLG(320, "大富翁选择对话框") {
    },
    ACT_MOMOPOLY_DRAW_FINISH_COUNT(321, "大富翁领取完成次数奖励") {
    },
    ACT_MOMOPOLY_DRAW_FREE_ENERGY(322, "大富翁领取免费精力") {
    },

    LAB_FIGHT_ARCHACT(323, "作战实验室建筑激活") {
    },
    LAB_FIGHT_TECHUP(324, "作战实验室科技升级") {
    },
    LAB_FIGHT_RESOURCE(325, "作战实验室资源领取") {
    },
    LAB_FIGHT_LABGRADUATEUP(326, "作战实验室深度研究所升级") {
    },
    LAB_FIGHT_LABGRADUATE_REWARD(327, "作战实验室深度研究领取奖励") {
    },
    DRAW_ACT_STROKE(328, "领取闪击行动活动奖励") {
    },
    GIFT_REWARD(329, "点击宝箱获得奖励") {
    },
    DRAW_ACT_RED_BAG_STAGE_AWARD(330, "领取抢红包活动阶段奖励") {
    },
    ACT_RED_BAG_TOPUP(331, "充值获得红包") {
    },
    ACT_SEND_RED_BAG_TOPUP(332, "发放红包") {
    },
    ACT_GRAB_RED_BAG(333, "抢红包") {
    },

    LAB_FIGHT_SPY_ACTAREA(334, "作战实验室间谍地图激活") {
    },
    LAB_FIGHT_SPY_REF_TASK(335, "作战实验室间谍刷新任务") {
    },
    LAB_FIGHT_SPY_TASK(336, "作战实验室间谍接受任务") {
    },
    LAB_FIGHT_SPY_TASK_REWARD(337, "作战实验室间谍领取任务固定奖励") {
    },
    LAB_FIGHT_SPY_TASK_REWARD_LOTTERY(338, "作战实验室间谍领取任务随机奖励") {
    },

    RED_PLAN_EXCHANGE(339, "红色方案兑换物品") {
    },
    RED_PLAN_MOVE(340, "红色方案挑战奖励") {
    },
    RED_PLAN_FUEL(341, "红色方案购买燃料") {
    },
    RED_PLAN_BOX(342, "红色方案领取宝箱奖励") {
    },
    RED_PLAN_REF(343, "红色方案扫荡励") {
    },
    GET_GUIDE_REWARD(344, "新手引导获得奖励") {
    },
    GET_FESTIVAL_REWARD(345, "假日碎片兑换") {
    },
    GET_FESTIVAL_LOGIN_REWARD(345, "假日碎片登录领取奖励") {
    },
    GET_LUCKY_REWARD(346, "幸运奖池转盘奖励") {
    },

    BOUNTY_SHOP_EXCHANGE(347, "赏金活动商店兑换物品") {
    },
    BOUNTY_REWARD(348, "赏金活动关卡奖励") {
    },
    BOUNTY_TASK_REWARD(349, "赏金活动通缉令完成奖励") {
    },

    REBEL_HEAD_BOX(350, "叛军头目掉落礼盒随机获取奖励") {
    },
    REBEL_RED_BAG(351, "领取叛军礼盒开出的金币红包") {
    },
    REBEL_PARTY_RANK_REWARD(352, "REBEL_PARTY_RANK_REWARD") {// 叛军入侵周军团排行奖励
    },
    LAB_FIGHT_RESET(353, "LAB_FIGHT_RESET") {// 作战实验室重置
    },
    PART_CONVERT(354, "PART_CONVERT") {// 配件转换
    },
    RESET_MILITARY_SCIENCE(355, "RESET_MILITARY_SCIENCE") {// 重置军工科技
    },
    TANK_CONVERT(356, "TANK_CONVERT") {// 金币车转换
    },
    EQUIP_STAR_LV(357, "EQUIP_STAR_LV") {// 装备升星
    },
    EXCHANGE_EQUIP_METERIAL(358, "EXCHANGE_EQUIP_METERIAL") {// 军备图纸兑换
    },
    FORTUNE_DAYILGOAL_AWARD(359, "FORTUNE_DAYILGOAL_AWARD") {// 幸运转盘每日目标奖励
    },
    ENERGRDIAL_DAYILGOAL_AWARD(360, "ENERGRDIAL_DAYILGOAL_AWARD") {// 能晶转盘每日目标奖励
    },
    EQUIP_DIAL(361, "EQUIP_DIAL") {// 装备转盘抽奖
    },
    EQUIPDIAL_DAYILGOAL_AWARD(362, "EQUIPDIAL_DAYILGOAL_AWARD") {// 装备转盘每日目标奖励
    },
    MEDAL_RESOLVE(363, "MEDAL_RESOLVE") {//勋章分解兑换
    },
    NEW_PAY_FRIST(364, "NEW_PAY_FRIST") {// 新首次充值
    },
    BUY_DAY_BOX(365, "BUY_DAY_BOX") {//购买每天和每周的宝箱
    },
    VCODESCOUT(366, "VCODESCOUT") {//侦查验证码成功奖励
    },
    ACTIVE_BOX(367, "ACTIVE_BOX") {// 新活跃宝箱
    },
    HONOUR_SURVIVE_BUFF(368, "HONOUR_SURVIVE") {// 荣耀玩法buff
    },
    HONOUR_SURVIVE_PLAYER_RANK(369, "HONOUR_SURVIVE_PLAYER_RANK") {// 荣耀玩法个人排行榜
    },
    HONOUR_SURVIVE_PARTY_RANK(370, "HONOUR_SURVIVE_PARTY_RANK") {// 荣耀玩法军团排行榜
    },
    NEW_PAY_FRIST_NEW(371, "NEW_PAY_FRIST_NEW") {// 新首次充值
    },
    ACT_LOGIN_WELFARE(372, "ACT_LOGIN_WELFARE") {// 登陆福利
    },
    NEW_BERO_ADD_GOLD(373, "NEW_BERO_ADD_GOLD") {// 新英雄采集增加的金币
    },
    HONOUR_SCORE_GOLD(374, "HONOUR_SCORE_GOLD") {// 荣耀玩法积分金币奖励
    },
    NEW_BERO_LUE_GOLD(375, "NEW_BERO_LUE_GOLD") {// 新英雄掠夺别人的金币
    },
    NEW_BERO_CLEAR_CD(376, "NEW_BERO_CLEAR_CD") {// 新英雄清除cd
    },
    QUESTIONNAIRE_SURVEY(377, "QUESTIONNAIRE_SURVEY") {// 问卷调查奖励
    },
    LORD_LORDEQUIPINHERITRQ(378, "LORD_LORDEQUIPINHERITRQ") {// 第二套军备继承
    },
    ACT_WAR_ACTIVITY(379, "ACT_WAR_ACTIVITY") {// 军团战活跃
    },
    Altar_BOSS_CONTRIBUTE(380, "Altar_BOSS_CONTRIBUTE") {// 军团战活跃
    },
    UPGRADE_TACTICS(381, "UPGRADE_TACTICS") {//  战术升级
    },
    ADVANCED_TACTICS(382, "ADVANCED_TACTICS") {//  战术进阶
    },
    COMPOSE_TACTICS(383, "COMPOSE_TACTICS") {//  战术合成
    },
    COMPOSE_TUPO(384, "COMPOSE_TUPO") {//  战术突破
    },
    KING_RANK_1(385, "KING_RANK_1") {//  最强王者排行奖励
    },
    KING_RANK_2(386, "KING_RANK_2") {//  最强王者条件达成奖励
    },
    TACTICS_BOX(387, "TACTICS_BOX") {// 战术副本开箱子
    },
    WIPE_DECR(389, "WIPE_DECR") {// 一键扫荡
    },

    ENERGYCORE_EQUIP(399, "ENERGYCORE_EQUIP") {//消耗装备 装备卡
    },

    TIC_DIAL(400, "TIC_DIAL") {// 战术转盘}
    },
    TIC_DAYILGOAL_AWARD(401, "TIC_DAYILGOAL_AWARD") {// 战术转盘转盘每日目标奖励
    },

    RECEIVE_FIGHT_VALUE_ADD_AWARD(600, "RECEIVE_FIGHT_VALUE_ADD_AWARD") {// 领取战力增强奖励
    },


    CROSS_SCORE_AWARD(601, "CROSS_SCORE_AWARD") {// 军事矿区个人积分排名奖励

    },

    CROSS_SERVER_SCORE_AWARD(602, "CROSS_SERVER_SCORE_AWARD") {// 军事矿区个人积分排名奖励

    },

    CROSS_ATK_SENIOR_MINE(603, "CROSS_ATK_SENIOR_MINE") {// 进攻军事矿区

    },

    PEAK_ACT(604, "PEAK_ACT") {// 激活巅峰属性

    },
    DO_SOME(99, "DO SOME") {// gm 命令
    },

    INNER_MOD_PROPS(999, "INNER MOD PROPS") {// 后台修改道具数量命令
    },

    ONLINE_DATA_REPAIR(998, "ONLINE_DATA_REPAIR") {//修复线上BUG导致的玩家异常数据
    },

    STOP_SERVER_FOR_MAINTAIN(997, "STOP_SERVER_FOR_MAINTAIN") {//停服维护
    },

    ONLINE_DATA_REPAIR_INVEST_NEW(10001, "ONLINE_DATA_REPAIR_INVEST_NEW") {//玩家
    },

    CROSS_BATTLE(10002, "CROSS_BATTLE") {//跨服战下注日志
    },

    FRIEND_GIVE(10003, "FRIEND_GIVE") {//好友赠送
    };


    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    private AwardFrom(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    private int code;
    private String msg;
}
