/**
 * @Title: AwardType.java @Package com.game.constant @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月31日 下午1:43:57
 * @version V1.0
 */
package com.game.constant;

/**
 * @ClassName: AwardType @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月31日 下午1:43:57
 */
public interface AwardType {
  // 经验
  final int EXP = 1;

  // 繁荣度
  final int PROS = 2;

  // 声望
  final int FAME = 3;

  // 荣誉
  final int HONOUR = 4;

  // 道具 id对应道具表
  final int PROP = 5;

  // 装备 id对应装备表
  final int EQUIP = 7;

  // 配件 id对应配件表
  final int PART = 8;

  // 碎片 id对应配件表
  final int CHIP = 9;

  // 配件材料 id对应关系 1.零件 2.记忆金属 3.设计蓝图 4.金属矿物 5.改造工具 6.改造图纸
  final int PART_MATERIAL = 10;

  // 竞技场积分
  final int SCORE = 11;

  // 军团贡献度
  final int CONTRIBUTION = 12;

  // 荒宝碎片
  final int HUANGBAO = 13;

  // 坦克 id对应坦克表
  final int TANK = 14;

  // 将领 id对应将领表
  final int HERO = 15;

  // 金币
  final int GOLD = 16;

  // 资源 1.铁 2.石油 3.铜 4.硅 5.宝石
  final int RESOURCE = 17;

  // 军团建设度
  final int PARTY_BUILD = 18;

  // 能量
  final int POWER = 19;

  // 红包(不能通过PlayerDataManager.addAward来增加红包金币，必须使用)
  final int RED_PACKET = 20;

  // 科技
  final int SCIENCE = 21;

  // 头像
  final int ICON = 22;

  // 军工材料
  final int MILITARY_MATERIAL = 23;

  // 能晶
  final int ENERGY_STONE = 24;

  // 功勋
  final int EXPLOIT = 25;

  // 编制经验
  final int STAFFING = 26;

  // 跨服战积分
  final int CROSS_JIFEN = 27;
}
