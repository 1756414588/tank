package com.game.constant;

/**
 * @ClassName SystemId.java @Description 全局常量配置表id配置信息
 *
 * @author TanDonghai
 * @date 创建时间：2016年9月3日 上午11:40:22
 */
public class SystemId {
  private SystemId() {}

  /** 叛军入侵活动首次开启条件，开服第几天 */
  public static final int REBEL_FIRST_OPEN_DAY = 1;

  /** 叛军入侵活动开启日期（星期几），多个日期用半角逗号分割 ps:2,4 */
  public static final int REBEL_OPEN_WEEK_DAY = 2;

  /** 叛军入侵活动开启时间，格式:mm:ss，多个时间用半角逗号分割 ps:12:00,18:00 */
  public static final int REBEL_OPEN_TIME = 3;

  /** 叛军入侵活动持续时长，单位：秒 */
  public static final int REBEL_DURATION = 4;

  /** 叛军入侵活动，将领按类型掉落上限：分队 */
  public static final int UNIT_DROP_LIMIT = 5;

  /** 叛军入侵活动，将领按类型掉落上限：卫队 */
  public static final int GUARD_DROP_LIMIT = 6;

  /** 叛军入侵活动，将领按类型掉落上限：领袖 */
  public static final int LEADER_DROP_LIMIT = 7;

  /** 服务器当前玩家等级上限 */
  public static final int MAX_ROLE_LEVEL = 8;

  /** 单次叛军活动，可击杀叛军数上限 */
  public static final int KILL_REBEL_LIMIT = 9;

  /** 叛军两种类型之间出现的间隔时间，单位：秒 */
  public static final int REBEL_DELAY = 10;

  /** 勋章温养总冷却时间,单位：s */
  public static final int MEDAL_UP_TIME_MAX = 11;

  /** 勋章温养单次花费时间，单位：s */
  public static final int MEDAL_UP_TIME = 12;

  /** 勋章温养每次的基础经验 */
  public static final int MEDAL_UP_ADD_EXP = 13;

  /** 奥古斯特复活部队数量权重 */
  public static final int HERO_REBORN_WEIGHT = 14;

  /** 废墟影响载重减少率 万分率 */
  public static final int RUINS_LOAD_REDUCE = 24;

  public static final int MEDAL_RATE = 64;

}
