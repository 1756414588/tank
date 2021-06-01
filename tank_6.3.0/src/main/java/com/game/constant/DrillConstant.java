package com.game.constant;

/**
 * @ClassName DrillConstant.java
 * @Description 红蓝大战常量
 * @author TanDonghai
 * @date 创建时间：2016年8月9日 上午11:52:15
 *
 */
public class DrillConstant {
	/** 红蓝大战状态：未开启或已结束 */
	public static final int STATUS_NOT_START = 0;
	/** 红蓝大战状态：报名 */
	public static final int STATUS_ENROLL = 1;
	/** 红蓝大战状态：备战 */
	public static final int STATUS_PREPARE = 2;
	/** 红蓝大战状态：预热 */
	public static final int STATUS_PREHEAT = 3;
	/** 红蓝大战状态：第一部队战斗 */
	public static final int STATUS_FIRST_BATTLE = 4;
	/** 红蓝大战状态：第二部队战斗 */
	public static final int STATUS_SECOND_BATTLE = 5;
	/** 红蓝大战状态：第三部队战斗 */
	public static final int STATUS_THIRD_BATTLE = 6;
	/** 红蓝大战状态：活动结束 */
	public static final int STATUS_END = 7;

	/** 战报类型: 个人战报 */
	public static final int RECORD_TYPE_ONE = 1;
	/** 战报类型: 全服战报 */
	public static final int RECORD_TYPE_ALL = 2;

	/** 奖励类型: 个人奖励（排行奖励） */
	public static final int REWARD_TYPE_RANK = 1;

	/** 奖励类型: 阵营奖励 */
	public static final int REWARD_TYPE_CAMP = 2;

	/** 排行榜类型：上路排行榜 */
	public static final int RANK_TYPE_FIRST = 1;

	/** 排行榜类型：中路排行榜 */
	public static final int RANK_TYPE_SECOND = 2;

	/** 排行榜类型：下路排行榜 */
	public static final int RANK_TYPE_THIRD = 3;

	/** 排行榜类型：总榜 */
	public static final int RANK_TYPE_TOTAL = 4;

	/** 战斗结果：平局 */
	public static final int RESULT_DRAW = 0;

	/** 战斗结果：红方胜 */
	public static final int RESULT_RED = 1;

	/** 战斗结果：蓝方胜 */
	public static final int RESULT_BLUE = 2;

	/** 红蓝大战红方 */
	public static final String RED = "红军";

	/** 红蓝大战蓝方 */
	public static final String BLUE = "蓝军";

	/** 红蓝大战上路名称 */
	public static final String ONE = "战车工厂";

	/** 红蓝大战中路名称 */
	public static final String TWO = "军事学院";

	/** 红蓝大战下路名称 */
	public static final String THREE = "装备工厂";

	/**
	 * 获取某路的名称
	 * 
	 * @param which
	 * @return
	 */
	public static String getName(int which) {
		switch (which) {
		case 1:
			return ONE;
		case 2:
			return TWO;
		case 3:
			return THREE;
		default:
			break;
		}
		return null;
	}
}
