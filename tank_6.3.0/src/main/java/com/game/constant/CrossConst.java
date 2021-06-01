package com.game.constant;
/**
 * 
* @ClassName: CrossConst 
* @Description: 跨服战常量
* @author
 */
public class CrossConst {
	public static int CrossType = 1;	// 跨服争霸类型
	public static int CrossPartyType = 2;	// 跨服军团战类型
	
	
	public static int CrossDayTime = 6;// 跨服战时间
	public static int CrossPartyDayTime = 5;	// 跨服军团时间
	
	public static int JY_Group = 1;// 精英组
	public static int DF_Group = 2;// 巅峰组

	public static int JY_Group_Base_Fight = 10000000;// 精英组基础战力
	public static int DF_Group_Base_fight = 35000000;// 巅峰组基础战力

	public static int JY_Group_Base_Rank = 100; // 精英组竞技场基础排名
	public static int DF_Group_Base_Rank = 4; // 巅峰组竞技场基础排名

	public static int default_state = 0; // 默认状态
	public static int begin_state = 1; // 开始状态
	public static int end_state = 2; // 结束状态

	public static int JY_WIN_JIFEN = 10;
	public static int DF_WIN_JIFEN = 15;

	public static int A_Group_Type = 1;
	public static int B_Group_Type = 2;
	public static int C_Group_Type = 3;
	public static int D_Group_Type = 4;

	public static int Knock_Session = 1; // 淘汰赛
	public static int Final_Session = 2; // 总决赛

	public static String DF_DESC = "【巅峰】";
	public static String JY_DESC = "【精英】";

	public interface BetState {
		int BET_STATE_HAVE_RECEIVED = 1;// 已经领取
		int BET_STATE_COULD_RECEIVE = 2;// 可以领取
		int BET_STATE_HAVE_NO_RECEIVED = 3; // 不能领取
	}

	/**
	 * 阶段
	 * 
	 * @author wanyi
	 *
	 */
	public interface STAGE {
		int STAGE_EXCEPTION = -1; // 结束
		int STAGE_ZIGEZHENDUO = 1; // 资格争夺
		int STAGE_REG = 2; // 报名
		int STAGE_JIFEN1 = 3; // 积分赛第一天
		int STAGE_JIFEN2 = 4;// 积分赛第二天
		int STAGE_JIFEN3 = 5;// 积分第三天
		int STAGE_KNOCK1 = 6;// 淘汰赛第一天
		int STAGE_KNOCK2 = 7;// 淘汰赛第二天
		int STATE_FINAL = 8;// 总决赛
	}

	/**
	 * 跨服战积分详情
	 */
	public interface TREND {
		/** 跨服战商店兑换 */
		int SHOP_EXCHANGE = 1;// 您在积分商店中兑换了|%s|，消耗了|%s|积分
		/** 跨服战下注胜利 */
		int BET_SUCCESS = 2;// 您支持的选手|%s|获得胜利，作为下注回报，您获得了|%s|积分
		/** 跨服战下注失败 */
		int BET_FAIL = 3;// 您支持的选手|%s|不幸落败，作为下注安慰，您获得了|%s|积分
		/** 跨服战排名领奖 */
		int RANK_AWARD = 4;// 您在跨服战中排名第|%s|，领取了|%s|积分
	}

	public interface State {
		int reg_begin = 1;
	}
}
