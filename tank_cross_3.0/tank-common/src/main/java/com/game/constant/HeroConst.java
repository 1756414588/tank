package com.game.constant;

public interface HeroConst {
  /** 已派出 */
  final int HERO_AWAKEN_STATE_USED = 1;

  /** 烟幕打击 战斗开始前，高速射出一波烟幕弹，随机使敌方1-6个部队一回合无法行动。 */
  final int ID_SKILL_SMOKE = 1;

  /** 火箭专精+1 鲷哥率领火箭进行战斗时，火箭属性+1%。 */
  final int ID_SKILL_2 = 2;

  /** 穿甲弹头+1 使用穿甲弹头装备部队，穿刺+1。 */
  final int ID_SKILL_3 = 3;

  /** 闪电战术+1 精通闪电战术的鲷哥，能充分发挥机械化部队的特点，先手值+1。 */
  final int ID_SKILL_4 = 4;

  /** 名将之风+1 鲷哥的名将风范令敌人闻风丧胆，震慑值+1。 */
  final int ID_SKILL_5 = 5;

  /** 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。 */
  final int ID_SKILL_BARRIER = 6;

  /** 战车专精+1 幽影率领战车进行战斗时，战车属性+1%。 */
  final int ID_SKILL_7 = 7;

  /** 重型装甲+1 使用重型装甲装备部队，防护+1。 */
  final int ID_SKILL_8 = 8;

  /** 无限毅力+1 作为特工所散发出来的毅力与坚韧感染着全军，刚毅值+1。 */
  final int ID_SKILL_9 = 9;

  /** 隐秘行动+1 强化己方的隐秘性，另敌军更加难以锁定自己，敌方命中-1%。 */
  final int ID_SKILL_10 = 10;

  /** 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害30%。这个效果每回合会10%，直至完全消失。 */
  final int ID_SKILL_11 = 11;

  /** 兵贵神速，风行者率领的部队行动迅速，如狂风飞旋。部队的先手值提升 */
  final int ID_SKILL_12 = 12;

  /** 深谙兵法的风行者率领部队进行战斗时，所有部队攻击力 */
  final int ID_SKILL_13 = 13;

  /** 动，则如雷霆。风行者的威名震慑着敌军，提升率领部队的震慑值 */
  final int ID_SKILL_14 = 14;

  /** 风行者擅长隐藏军情，其率领部队数量实际上更高，带兵数量提升。 */
  final int ID_SKILL_15 = 15;

  /** 增加少量防护和刚毅（全体）主动技能 */
  final int ID_SKILL_16 = 16;

  /** 减伤护罩（全体，持续回合） */
  final int ID_SKILL_17 = 17;

  /** 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率） */
  final int ID_SKILL_18 = 18;

  /** 全体上一个不屈buff（不屈：死后复活的部队会提升攻击，暴击，爆裂） */
  final int ID_SKILL_19 = 19;
  /** 增加闪避（全体) */
  final int ID_SKILL_20 = 20;

  /** 烟雾弹 */
  final int EFFECT_TYPE_SMOKE = 1;

  /** 增加属性 */
  final int EFFECT_TYPE_ATTR = 2;

  /** 增加先手值 */
  final int EFFECT_TYPE_FIRST_VAL = 3;

  /** 屏障 */
  final int EFFECT_TYPE_BARRIER = 4;

  /** 增加伤害，每回合递减 */
  final int EFFECT_TYPE_DEMAGEF = 5;

  /** 增加带兵量 */
  final int EFFECT_TYPE_TANK_COUNT = 6;

  /** 采集资源点获得编制经验提高 */
  final int HERO_ADD_EXP = 7;

  /** 载重提升 */
  final int HERO_ADD_LOAD = 8;

  /** 采集后有一定时间的免战（包括军矿，时间叠加） */
  final int HERO_FREE_WAR_TIME = 9;

  /** 增加闪避（全体） */
  final int HERO_ADD_ATTRIBUTE = 10;

  /** 炸矿成功获得编制经验提高 */
  final int HERO_STAFFING_EXP = 11;

  /** 炸矿造成的损兵提高 */
  final int HERO_SUB_TANK = 12;

  /** 增加少量防护和刚毅（全体）主动技能 */
  final int HERO_ADD_ATTR = 13;

  /** 减伤护罩（全体，持续回合） */
  final int HERO_SUB_HURT = 14;

  /** 守卫基地/资源加刚毅 守卫基地/资源加抗暴 守卫基地/资源加防护 */
  final int HERO_ADD_RESUORCE_ATTR = 15;

  /** 守卫基地/资源减繁荣度损失 */
  final int HERO_PROS = 16;

  /** 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率） */
  final int HERO_IMMUNE = 17;

  /** 被动加减伤百分比 */
  final int HERO_SUB_HURT_B = 18;

  /** 全体上一个不屈buff（不屈：死后复活的部队会提升攻击，暴击，爆裂） */
  final int HERO_BUFF_FH = 19;
  /** 复活后加属性 */
  final int HERO_BUFF_FH_B = 20;
}
