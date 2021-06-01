package com.game.honour.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import com.alibaba.fastjson.JSONArray;
import com.game.service.LoadService;
import com.game.util.CheckNull;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class HonourConstant {

	/** 荣耀生存开启时间 */
	public static final int HONOUR_OPEN_LIMIT = 1;
	/** 每月开启时间 */
	public static final int HONOUR_OPEN_MONTHDAY = 2;
	/** 玩法开启时间点 */
	public static final int HONOUR_OPEN_TIME = 3;
	/** 玩法持续时间 */
	public static final int HONOUR_DURATION = 4;
	/** 玩法各阶段开始时间 */
	public static final int HONOUR_REFRESHTIME = 5;
	/** 每个阶段的半边长 */
	public static final int HONOUR_HALFLENGTH = 6;
	/** 个人排行榜上榜最低积分 */
	public static final int HONOUR_ROLERANK_LIMIT_SCORE = 7;
	/** 军团排行榜上榜最低积分 */
	public static final int HONOUR_PARTYRANK_LIMIT_SCORE = 8;
	/** 4阶段金币获取周期 */
	public static final int HONOUR_GOLD_TIME = 9;
	/** 玩法掠夺金币上限 */
	public static final int HONOUR_GRAB_GOLD_LIMIT = 10;
	/** 军团排行榜领取奖励最低个人积分要求 */
	public static final int PARTY_RANK_AWARD_LIMIT = 11;

	/** 玩法开启时间，每个月的第几天 */
	public static int openLimit = 30;

	/** 玩法开启时间，每个月的第几天 */
	public static List<Integer> openDayInMonth = new ArrayList<Integer>();

	/** 玩法开启时间点，openTime[0]:hour openTime[1]:minute */
	public static Integer[] openTime = new Integer[2];

	/** 毒圈半边长 */
	public static List<Integer> halfLength = new ArrayList<Integer>();

	/** 毒圈刷新时间点 Integer[0]:活动开始后多少分钟 ，Integer[1]:刷新结束时活动已开启的时间 ，精确到分 */
	public static LinkedList<Integer[]> refreshTime = new LinkedList<>();

	/** 玩法持续时长， 单位：分 */
	public static int duration = 48 * 60;

	/** 个人榜上榜最低积分 */
	public static int roleRankLimit = 200;

	/** 军团榜上榜最低积分 */
	public static int partyRankLimit = 400;

	/** 金币获取周期，单位：分 */
	public static int goldTime = 60;

	/** 金币掠夺上限 */
	public static int grabGold = 300;

	/** 个人排行榜前几名可获得奖励 */
	public static int playerRankTop = 10;

	/** 军团排行榜前几名可获得奖励 */
	public static int partyRankTop = 10;

	/** 军团排行榜领奖最低个人积分要求 */
	public static int partyRankAwardLimit = 1;

	/**
	 * 初始化全局配置
	 */
	public static void loadSystem(LoadService loadService) {
		// 初始化openDayInMonth
		String openDay = loadService.getStringHonourValue(HONOUR_OPEN_MONTHDAY, "5,20");
		openDayInMonth.clear();
		if (!CheckNull.isNullTrim(openDay)) {
			String[] ss = openDay.split(",");
			for (String str : ss) {
				openDayInMonth.add(Integer.valueOf(str));
			}
			Collections.sort(openDayInMonth);
		}

		// 初始化openTime
		String time = loadService.getStringHonourValue(HONOUR_OPEN_TIME, "0:00");
		if (!CheckNull.isNullTrim(time)) {
			String[] ss = time.split(":");
			for (int i = 0; i < ss.length; i++)
				if (i < openTime.length)
					openTime[i] = Integer.valueOf(ss[i]);
		}

		// 初始化halfLength
		String length = loadService.getStringHonourValue(HONOUR_HALFLENGTH, "200,100,50,15");
		halfLength.clear();
		if (!CheckNull.isNullTrim(length)) {
			String[] ss = length.split(",");
			for (String str : ss) {
				halfLength.add(Integer.valueOf(str));
			}
		}

		// 初始化refreshTime
		String refresh = loadService.getStringHonourValue(HONOUR_REFRESHTIME, "");
		refreshTime.clear();
		JSONArray arr = JSONArray.parseArray(refresh);
		for (int i = 0; i < arr.size(); i++) {
			JSONArray a = arr.getJSONArray(i);
			refreshTime.add(new Integer[] { a.getInteger(0), a.getInteger(1) });
		}
		Collections.sort(refreshTime, new RefreshTimeCompator());

		String ss = loadService.getStringHonourValue(HONOUR_DURATION, "2880");
		duration = Integer.valueOf(ss);

		String roleLimit = loadService.getStringHonourValue(HONOUR_ROLERANK_LIMIT_SCORE, "200");
		roleRankLimit = Integer.valueOf(roleLimit);

		String partyLimit = loadService.getStringHonourValue(HONOUR_PARTYRANK_LIMIT_SCORE, "400");
		partyRankLimit = Integer.valueOf(partyLimit);

		String gold = loadService.getStringHonourValue(HONOUR_GOLD_TIME, "60");
		goldTime = Integer.valueOf(gold);

		String grab = loadService.getStringHonourValue(HONOUR_GRAB_GOLD_LIMIT, "300");
		grabGold = Integer.valueOf(grab);

		String openLimit2 = loadService.getStringHonourValue(HONOUR_OPEN_LIMIT, "30");
		openLimit = Integer.valueOf(openLimit2);

		String awardLimit = loadService.getStringHonourValue(PARTY_RANK_AWARD_LIMIT, "1");
		partyRankAwardLimit = Integer.valueOf(awardLimit);
	}

}

class RefreshTimeCompator implements Comparator<Integer[]> {

	@Override
	public int compare(Integer[] o1, Integer[] o2) {
		if (o1.length == 0 || o2.length == 0) {
			return o1.length - o2.length;
		}
		if (o1[0] > o2[0]) {
			return 1;
		} else if (o1[0] < o2[0]) {
			return -1;
		}
		return 0;
	}
}
