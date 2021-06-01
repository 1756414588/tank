/**
 * @Title: FormType.java @Package com.game.constant @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月7日 下午4:52:06
 * @version V1.0
 */
package com.game.constant;

/**
 * @ClassName: FormType @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月7日 下午4:52:06
 */
public interface FormType {
  // 模板
  final int TEMPLATE = 1;

  // 基地防守
  final int HOME_DEFEND = 2;

  // 竞技场
  final int ARENA = 3;

  final int VIP2 = 4;

  final int VIP5 = 5;

  final int VIP8 = 6;

  /** 世界BOSS */
  final int BOSS = 7;

  /** 要塞战防守 */
  final int FORTRESS = 8;

  /** 祭坛BOSS */
  final int ALTARBOSS = 9;

  // 跨服战
  final int Cross1 = 13;
  final int Cross2 = 14;
  final int Cross3 = 15;

  // 赏金组队
  final int TEAM = 16;
}
