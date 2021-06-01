package com.game.constant;
/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/13 13:47 @Description :java类作用描述
 */
public class CrossConst {
  /** 跨服争霸类型 */
  public static final int CrossType = 1;
  /** 跨服军团战类型 */
  public static final int CrossPartyType = 2;
  /** 精英组 */
  public static int JY_Group = 1;
  /** 巅峰组 */
  public static int DF_Group = 2;

  /** 精英组基础战力 */
  public static int JY_Group_Base_Fight = 10000000;
  /** 巅峰组基础战力 */
  public static int DF_Group_Base_fight = 35000000;

  /** 精英组竞技场基础排名 */
  public static int JY_Group_Base_Rank = 100;
  /** 巅峰组竞技场基础排名 */
  public static int DF_Group_Base_Rank = 20;

  /** 默认状态 */
  public static int default_state = 0;
  /** 开始状态 */
  public static int begin_state = 1;
  /** 结束状态 */
  public static int end_state = 2;

  public static int Jifen_JY_WIN_JIFEN = 30;
  public static int JiFen_DF_WIN_JIFEN = 45;

  public static int Knock_JY_WIN_JIFEN = 10;
  public static int Knock_DF_WIN_JIFEN = 15;

  public static int A_Group_Type = 1;
  public static int B_Group_Type = 2;
  public static int C_Group_Type = 3;
  public static int D_Group_Type = 4;

  /** 淘汰赛 */
  public static int Knock_Session = 1;
  /** 总决赛 */
  public static int Final_Session = 2;

  public static String DF_DESC = "【巅峰】";
  public static String JY_DESC = "【精英】";

  public interface BetState {
    /** 已经领取 */
    int BET_STATE_HAVE_RECEIVED = 1;
    /** 可以领取 */
    int BET_STATE_COULD_RECEIVE = 2;
    /** 不能领取 */
    int BET_STATE_HAVE_NO_RECEIVED = 3;
  }

  /**
   * 阶段
   *
   * @author wanyi
   */
  public interface STAGE {
    /** 资格争夺 */
    int STAGE_ZIGEZHENDUO = 1;
    /** 报名 */
    int STAGE_REG = 2;
    /** 积分赛第一天 */
    int STAGE_JIFEN1 = 3;
    /** 淘汰赛第一天 */
    int STAGE_KNOCK1 = 4;
    /** 总决赛 */
    int STATE_FINAL = 5;
    /** 积分商店 */
    int STATE_SHOP1 = 6;
  }

  /**
   * 领取排行奖励状态
   *
   * @author wanyi
   */
  public interface ReceiveRankRwardState {
    /** 默认,没有排名 */
    int DEFAULT = 0;
    /** 可以领取 */
    int CAN_RECEIVE = 1;
    /** 已经领取 */
    int HAVE_RECEIVE = 2;
  }

  /** 1全服,2个人，3系统自行判断 */
  public interface MailType {
    int All = 1;
    int Person = 2;
    int SysAuto = 3;
  }

  /** 跨服战积分详情 */
  public interface TREND {
    /** 跨服战商店兑换 您在积分商店中兑换了|%s|，消耗了|%s|积分 */
    int SHOP_EXCHANGE = 1;
    /** 跨服战下注胜利 您支持的选手|%s|获得胜利，作为下注回报，您获得了|%s|积分 */
    int BET_SUCCESS = 2;
    /** 跨服战下注失败 您支持的选手|%s|不幸落败，作为下注安慰，您获得了|%s|积分 */
    int BET_FAIL = 3;
    /** 跨服战排名领奖 您在跨服战中排名第|%s|，领取了|%s|积分 */
    int RANK_AWARD = 4;
    /** 连胜积分* 您在军团军团争霸中获得|%s|连胜，获得了|%s|积分 */
    int LIAN_SHENG_JIFEN = 5;
    /** 终结积分*您在军团军团争霸中终结了|%s|连胜，获得了|%s|积分 */
    int ZHONG_JIE_JIFEN = 6;
  }

  public interface State {
    /** 报名开始 */
    int reg_begin = 1;
    /** 跨服战结束 */
    int cross_End = 2;
    /** 积分商店开放 */
    int jifen_shop_open = 6;
  }
}
