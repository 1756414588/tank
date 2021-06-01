/**
 * @Title: GoldGive.java @Package com.game.constant @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月10日 下午1:39:52
 * @version V1.0
 */
package com.game.constant;

/**
 * @ClassName: AwardFrom @Description: 奖励来源，要细分记录
 *
 * @author ZhangJun
 * @date 2015年8月10日 下午1:39:52
 */
public enum AwardFrom {
  CAIZHENG(2, "CAI ZHENG GUAN") { // 财政官收入
  },
  RED_PACKET(3, "RED PACKET") { // 红包奖励
  },
  ASSEMBLE_MECHA(4, "JI JIA HONG LIU") { // 机甲洪流奖励
  },
  HALF_COST(5, "HALF COST") { // 半价购买
  },
  ACTIVITY_AWARD(6, "ACTIVITY AWARD") { // 活动奖励
  },
  ARENA_SCORE(7, "ARENA SCORE") { // 竞技场积分兑换
  },
  ARENA_RANK(8, "ARENA RANK") { // 竞技场排名奖励
  },
  HUANGBAO_BOX(9, "HUANGBAO BOX") { // 兑换荒宝宝箱
  },
  PART_BOX(10, "PART BOX") { // 配件副本开箱子
  },
  EQUIP_BOX(11, "EQUIP BOX") { // 装备副本开箱子
  },
  COMBAT_BOX(12, "COMBAT BOX") { // 普通副本开箱子
  },
  COMBAT_FIRST(13, "COMBAT FIRST") { // 副本首次过关奖励
  },
  COMBAT_DROP(14, "COMBAT EXPLORE EXTREME DROP") { // 副本掉落
  },
  HERO_DECOMPOSE(15, "HERO DECOMPOSE") { // 将领分解
  },
  LOTTERY_HERO(16, "LOTTERY_HERO") { // 武将招募
  },
  MAIL_ATTACH(17, "MAIL ATTACH") { // 领取邮件附件
  },
  PARTY_SHOP(18, "PARTY SHOP") { // 军团商店兑换
  },
  PARTY_COMBAT(19, "PARTY COMBAT") { // 打军团副本
  },
  PARTY_COMBAT_BOX(20, "PARTY COMBAT BOX") { // 军团副本开箱子
  },
  PARTY_WEAL_DAY(21, "PARTY WEAL DAY") { // 军团每日福利
  },
  GIFT_CODE(22, "GIFT CODE") { // 兑换码
  },
  NEWER_GIFT(23, "NEWER GIFT") { // 新手引导礼包
  },
  OL_AWARD(24, "PORT ONLINE AWARD") { // 港口在线奖励
  },
  USE_PROP(25, "USE PROP") { // 使用道具
  },
  SIGN_AWARD(26, "SIGN AWARD") { // 签到奖励
  },
  FIGHT_MINE(27, "FIGHT MINE DROP") { // 世界地图攻打资源点，随机掉落
  },
  WASTE_SMALL(28, "WASTE_SMALL") { // 荒宝小
  },
  WASTE(29, "WASTE") { // 荒宝小
  },
  WASTE_LARGE(30, "WASTE_LARGE") { // 荒宝大
  },
  EXPLORE_SINGLE(31, "EXPLORE_SINGLE") { // 探宝箱子
  },
  EXPLORE_THREE(32, "EXPLORE_THREE") { // 三被探宝
  },
  GREEN_SINGLE(33, "GREEN_SINGLE") { // 绿色单抽
  },
  BLUE_SINGLE(34, "BLUE_SINGLE") { // 蓝色单抽
  },
  PURPLE_SINGLE(35, "BLUE_SINGLE") { // 紫色单抽
  },
  PURPLE_NINE(36, "PURPLE_NINE") { // 紫色多抽
  },
  TASK_DAYIY_AWARD(37, "TASK_AWARD") { // 主线/日常任务奖励
  },
  TASK_LIVILY_AWARD(38, "TASK_AWARD") { // 活跃活动
  },
  PAY(39, "PAY") { // 充值
  },
  PART_EVOLVE(40, "PART_EVOLVE") { // 配件进阶
  },
  FLASH_SALE(41, "FLASH_SALE") { // 限时购买
  },
  FLASH_META(42, "FLASH_META") { // 限购材料
  },
  DAY_BUY(43, "DAY_BUY") { // 天天购买
  },
  AMY_REBATE(44, "AMY REBATE") { // 建军节返利
  },
  PAWN(45, "PAWN") { // 极限单兵
  },
  ACT_RANK_AWARD(46, "ACT_RANK_AWARD") { // 极限单兵
  },
  SIGN_LOGIN(47, "SIGN LOGIN") { // 签到登录奖励
  },
  PART_DIAL(48, "PART_DIAL") { // 配件转盘
  },
  COMBAT_COURSE(49, "COMBAT_COURSE") { // 关卡拦截
  },
  PARTY_AMY_PROP(50, "PARTY_AMY_PROP") { // 军团战事福利
  },
  USE_AMY_PROP(51, "USE_AMY_PROP") { // 使用军团福利坦克箱子
  },
  WAR_WIN(52, "WAR WIN RANK") { // 百团混战连胜排名奖励
  },
  WAR_PARTY(53, "WAR IN PARTY") { // 百团混战贡献度奖励
  },
  ACTIVITY_TECH(54, "ACTIVITY TECH") { // 技术革新
  },
  ATTACK_BOSS(55, "ATTACK BOS") { // 挑战boss
  },
  BOSS_HURT(56, "BOSS HURT RANK") { // 世界boss伤害排名奖励
  },
  ACTIVITY_GENERAL(57, "ACTIVITY GENERAL") { // 招募武将
  },
  PARTY_TIP_AWARD(58, "PARTY TIP AWARD") { // 军团tip奖励
  },
  EVERY_DAY_PAY(59, "EVERY_DAY_PAY") { // 每日充值
  },
  VIP_GIFT(60, "VIP_GIFT") { // vip礼包
  },
  CONSUME_DIAL(61, "CONSUME_DIAL") { // 消费转盘
  },
  VACATION(62, "VACATION") { // 度假胜地
  },
  EXCHANGE_PART(63, "EXCHANGE_PART") { // 兑换配件
  },
  EXCHANGE_EQUIP(64, "EXCHANGE_EQUIP") { // 兑换装备
  },
  PART_RESOLVE(65, "PART_RESOLVE") { // 兑换装备
  },
  TOPUP_GAMBLE(66, "TOPUP_GAMBLE") { // 充值下注
  },
  SCORE_AWARD(67, "SCORE AWARD") { // 军事矿区个人积分排名奖励
  },
  PARTY_SCORE_AWARD(68, "PARTY SCORE AWARD") { // 军事矿区军团积分排名奖励
  },
  PAY_TURN_TABLE(69, "PAY_TURN_TABLE") { // 充值转盘
  },
  PRAY_AWARD(70, "PRAY_AWARD") { // 祈福奖励
  },
  ACTIVITY_MINE(71, "ACTIVITY_MINE") { // 活动矿掉落
  },
  ACT_M1A2(72, "ACT_M1A2") { // M1A2掉落
  },
  FRIEND_BLESS(73, "FRIEND_BLESS") { // 好友祝福
  },
  ACT_PROFOTO(74, "ACT_PROFOTO") { // 哈洛克宝藏
  },
  SPEED_TANK_QEU(75, "SPEED_TANK_QEU") { // 加速坦克生产
  },
  SPEED_REFIT_QEU(76, "SPEED_REFIT_QEU") { // 改装坦克加速
  },
  BUILD_TANK(77, "BUILD_TANK") { // 生产坦克
  },
  REFIT_TANK(78, "REFIT_TANK") { // 改装坦克
  },
  BUILD_QUE(79, "BUILD_QUE") { // 建筑加速
  },
  HERO_UP(80, "HERO_UP") { // 武将升级
  },
  HERO_IMPROVE(81, "HERO_IMPROVE") { // 武将进阶
  },
  UP_COMMAND(82, "UP_COMMAND") { // 统帅升级
  },
  UP_SKILL(83, "UP_SKILL") { // 技能升级
  },
  COMPOSE_SANT(84, "COMPOSE_SANT") { // 将神魂
  },
  BUILD_PROP(85, "BUILD_PROP") { // 制造车间生产道具
  },
  SPEED_SCIENCE_QUE(86, "SPEED_SCIENCE_QUE") { // 加速科技研发
  },
  MOVE_HOME(87, "MOVE_HOME") { // 搬家
  },
  DO_ARENA(88, "DO_ARENA") { // 竞技场挑战
  },
  CANCEL_TANK_QUE(89, "CANCEL_TANK_QUE") { // 取消生产坦克队列
  },
  CANCEL_REFIT_QUE(90, "CANCEL_REFIT_QUE") { // 取消改装坦克队列
  },
  RESET_SKILL(91, "RESET_SKILL") { // 重置技能
  },
  BUY_PROP(92, "BUY_PROP") { // 购买道具
  },
  CANCEL_PROP_QUE(93, "CANCEL_PROP_QUE") { // 取消制造车间道具生产
  },
  SELL_EQUIP(94, "SELL_EQUIP") { // 出售装备
  },
  EAT_EQUIP(95, "EAT_EQUIP") { // 喂养装备
  },
  COMBINE_PART(96, "COMBINE_PART") { // 合成配件
  },
  EXPLODE_PART(97, "EXPLODE_PART") { // 分解配件
  },
  EXPLODE_CHIP(98, "EXPLODE_CHIP") { // 分解配件碎片
  },
  RETREAT_END(100, "RETREAT_END") { // 矿区部队召回
  },
  CANCEL_ARMY(101, "CANCEL_ARMY") { // 取消部队
  },
  ELIMINATE_GUARD(102, "ELIMINATE_GUARD") { // 取消部队
  },
  BACK_HERO(103, "BACK_HERO") { // 回收武将
  },
  BUY_FAME(104, "BUY_FAME") { // 购买声望
  },
  CLICK_FAME(105, "CLICK_FAME") { // 领取军衔声望
  },
  UNDERGO_GRAB(106, "UNDERGO_GRAB") { // 被掠夺资源
  },
  GAIN_GRAB(107, "GAIN_GRAB") { // 掠夺资源
  },
  UP_BUILD(108, "UP_BUILD") { // 升级建筑
  },
  CANCEL_BUILD_QUE(109, "CANCEL_BUILD_QUE") { // 取消建筑队列
  },
  UP_MILL(110, "UP_MILL") { // 升级城外建筑
  },
  DO_AUTO_MILL(111, "DO_AUTO_MILL") { // 自动升级建筑
  },
  UP_PART(112, "UP_PART") { // 升级配件
  },
  DONATE_PARTY(113, "DONATE_PARTY") { // 军团大厅捐献
  },
  WEAL_DAY(114, "WEAL_DAY") { // 军团福利大厅
  },
  DONATE_SCIENCE(115, "DONATE_SCIENCE") { // 军团科技大厅
  },
  UP_RANK(116, "UP_RANK") { // 升级军衔
  },
  UP_SCIENCE(117, "UP_SCIENCE") { // 升级科技
  },
  CANCEL_SCIENCE_QUE(118, "CANCEL_SCIENCE_QUE") { // 取消科技升级
  },
  SCOUT_MINE(119, "SCOUT_MINE") { // 侦查矿
  },
  SCOUT_HOME(120, "SCOUT_HOME") { // 侦查基地
  },
  REFIT_PART(121, "REFIT_PART") { // 改造配件
  },
  ATK_SENIOR_MINE(122, "ATK_SENIOR_MINE") { // 进攻军事矿区
  },
  WAR_REG(123, "WAR_REG") { // 百团混战
  },
  ATTACK_POS(124, "ATTACK_POS") { // 进攻坐标点
  },
  GUARD_POS(125, "GUARD_POS") { // 设置防守
  },
  REFIT_TANK_COMPLETE(126, "REFIT_TANK_COMPLETE") { // 改装坦克完成
  },
  TANK_COMPLETE(127, "TANK_COMPLETE") { // 生产坦克完成
  },
  MILITARY_REFIT_TANK(128, "MILITARY_REFIT_TANK") { // 军工科技改造
  },
  UNLOCK_SCIECE_GRID(129, "UNLOCK_SCIECE_GRID") { // 解锁军工科技格子
  },
  UP_MILITARY_SCIENCE(130, "UP_MILITARY_SCIENCE") { // 升级军工科技
  },
  ACTIVITY_DAY_BUY(131, "ACTIVITY_DAY_BUY") { // 坦克拉霸
  },
  ACTIVITY_INVEST(132, "ACTIVITY_INVEST") { // 活动-投资计划
  },
  BUY_ARENA(132, "BUY_ARENA") { // 购买竞技场
  },
  ARENA_CD(133, "ARENA_CD") { // 消除arena cd
  },
  REPAIR_TANK(134, "REPAIR_TANK") { // 修复坦克
  },
  BLESS_FIGHT(135, "BLESS_FIGHT") { // 世界boss祝福
  },
  BOSS_CD(136, "BOSS_CD") { // 世界CD
  },
  BUY_AUTO_BUILD(137, "BUY_AUTO_BUILD") { // 购买建筑自动升级
  },
  BUY_EXPLORE(138, "BUY_EXPLORE") { // 购买副本次数
  },
  BUY_MILITARY(139, "BUY_MILITARY") { // 购买军工探险次数
  },
  PARTY_CREATE(140, "PARTY_CREATE") { // 创建军团
  },
  BUY_POWER(141, "BUY_POWER") { // 购买能量
  },
  BUY_PROSP(142, "BUY_PROSP") { // 购买繁荣度
  },
  BUY_BUILD(143, "BUY_BUILD") { // 购买建筑位
  },
  SPEED_PROP_QUE(144, "SPEED_PROP_QUE") { // 生产道具加速
  },
  BUY_SENIOR(145, "BUY_SENIOR") { // 购买军事矿区掠夺次数
  },
  TASK_DAYLY_RESET(146, "TASK_DAYLY_RESET") { // 重置日常任务
  },
  REFRESH_DAYIY_TASK(147, "REFRESH_DAYIY_TASK") { // 刷新日常任务
  },
  SPEED_ARMY(148, "SPEED_ARMY") { // 加速行军
  },
  UP_CAPACITY(149, "UP_CAPACITY") { // 装备仓库扩充
  },
  ATTACK_MINE(150, "ATTACK_MINE") { // 打世界矿
  },
  ATTACK_SOMEONE_MINE(151, "ATTACK_SOMEONE_MINE") { // 炸矿
  },
  SOMEONE_ATTACK_MINE(152, "SOMEONE_ATTACK_MINE") { // 矿被别人炸了
  },
  ATTACK_SOMEONE_HOME(153, "ATTACK_SOMEONE_HOME") { // 攻打别人基地
  },
  SOMEONE_ATTACK_HOME(154, "SOMEONE_ATTACK_HOME") { // 基地被攻打
  },
  PAY_CONTINUE(155, "PAY_CONTINUE") { // 连续充值活动
  },
  PAY_FOISON(156, "PAY_FOISON") { // 充值丰收
  },
  FIGHT_BOSS(157, "FIGHT_BOSS") { // 打boss
  },
  GM_SEND(158, "GM_SEND") { // 充值丰收
  },
  PAY_FRIST(159, "PAY_FRIST") { // 首次充值
  },
  BUILD_UP_FINISH(160, "BUILD_UP_FINISH") { // 建筑升级完成
  },
  BUILD_REMOVE(161, "BUILD_REMOVE") { // 拆建筑
  },
  DEL_MAIL(162, "DEL_MAIL") { // 删除邮件
  },
  FORTRESS_JOB(163, "FORTRESS_JOB") { // 要塞职位
  },
  FORTRESS_FIGHT_OUT(164, "FORTRESS_JOB") { // 要塞出局
  },
  BUY_FORTRESS_CD(165, "BUY_FORTRESS_CD") { // 购买要塞CD
  },
  UP_FORTRESS_ATTR(166, "UP_FORTRESS_ATTR") { // 要塞进修
  },
  ENERGY_STONE_BOX(167, "ENERGY_STONE_BOX") { // 能晶副本箱子
  },
  ALTAR_BOSS_PARTICIPATE(168, "ALTAR_BOSS_PARTICIPATE") { // 祭坛BOSS参与奖励
  },
  ALTAR_BOSS_KILL(169, "ALTAR_BOSS_KILL") { // 祭坛BOSS最后一击
  },
  ALTAR_BOSS_HURT_RANK(170, "ALTAR_BOSS_HURT_RANK") { // 祭坛BOSS伤害排行
  },
  ALTAR_BOSS_BLESS_FIGHT(171, "BLESS_FIGHT") { // 购买祭坛BOSS祝福
  },
  ALTAR_BOSS_BUY_CD(172, "ALTAR_BOSS_BUY_CD") { // 消除祭坛BOSS的CD时间
  },
  BUY_ENERGY_STONE(172, "BUY_ENERGY_STONE") { // 购买能晶副本次数
  },
  ENERGY_STONE_COMBINE(173, "ENERGY_STONE_COMBINE") { // 能晶合成
  },
  ENERGY_STONE_EQUIP(174, "ENERGY_STONE_EQUIP") { // 能晶镶嵌、卸下
  },
  CROSS_BET(200, "CROSS_BET") { // 下注
  },
  CROSS_RANK_AWARD(201, "CROSS_RANK_AWARD") { // 跨服战排名奖励
  },
  CROSS_RECEIVE_BAT_JIFEN(202, "CROSS_RECEIVE_BAT_JIFEN") { // 领取跨服战下注积分
  },
  CP_PER_RANK_AWARD(203, "CP_PER_RANK_AWARD") { // 跨服战个人排名
  },
  CP_LIANSHENG_RANK_AWARD(204, "CP_LIANSHENG_RANK_AWARD") { // 跨服战个人排名
  },
  DO_SOME(99, "DO SOME") { // gm 命令
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
