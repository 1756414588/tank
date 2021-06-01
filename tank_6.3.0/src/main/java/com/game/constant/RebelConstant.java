package com.game.constant;

import com.game.service.LoadService;
import com.game.util.CheckNull;

import java.util.*;

/**
 * @author TanDonghai
 * @ClassName RebelConstant.java
 * @Description 叛军
 * @date 创建时间：2016年9月5日 上午10:42:06
 */
public class RebelConstant {

    /**
     * 分队叛军的初始数量
     */
    public static final int UNIT_REBEL_NUM = 50;

    /**
     * 卫队叛军的初始数量
     */
    public static final int GUARD_REBEL_NUM = 18;

    /**
     * 领袖叛军的初始数量
     */
    public static final int LEADER_REBEL_NUM = 6;

    /**
     * 叛军入侵周个人榜入榜积分最低要求
     */
    public static final int WEEK_PLAYER_RANK_LIMIT = 20;

    /**
     * 叛军入侵周军团榜入榜积分最低要求
     */
    public static final int WEEK_PARTY_RANK_LIMIT = 50;

    /**
     * 叛军入侵总榜入榜积分最低要求
     */
    public static final int TOTAL_RANK_LIMIT = 150;

    /**
     * 叛军类型:分队
     */
    public static final int REBEL_TYPE_UNIT = 1;

    /**
     * 叛军类型:卫队
     */
    public static final int REBEL_TYPE_GUARD = 2;

    /**
     * 叛军类型:领袖
     */
    public static final int REBEL_TYPE_LEADER = 3;

    /**
     * 叛军类型:boss
     */
    public static final int REBEL_TYPE_BOOS = 4;

    /**
     * 活动状态： 已刷新
     */
    public static final int REBEL_STATUS_OPEN = 1;

    /**
     * 活动状态： 未开启或已结束
     */
    public static final int REBEL_STATUS_END = 0;

    /**
     * 排行榜类型：周--个人榜
     */
    public static final int RANK_TYPE_WEEK_PLAYER = 1;

    /**
     * 排行榜类型：总--个人榜
     */
    public static final int RANK_TYPE_TOTAL_PLAYER = 2;

    /**
     * 排行榜类型：周--军团榜
     */
    public static final int RANK_TYPE_WEEK_PARTY = 3;

    /**
     * 排行榜奖励：周--个人榜
     */
    public static final int AWARD_TYPE_WEEK_PLAYER = 1;

    /**
     * 排行榜奖励：周--军团榜
     */
    public static final int AWARD_TYPE_WEEK_PARTY = 3;

    /**
     * 叛军状态:已击杀
     */
    public static final int REBEL_STATE_DEAD = 0;

    /**
     * 叛军状态:未击杀
     */
    public static final int REBEL_STATE_ALIVE = 1;

    /**
     * 叛军状态:已逃跑
     */
    public static final int REBEL_STATE_RUN = 2;

    /**
     * 击杀叛军得分：分队
     */
    public static final int REBEL_SCORE_UNIT = 5;

    /**
     * 击杀叛军得分：卫队
     */
    public static final int REBEL_SCORE_GUARD = 8;

    /**
     * 击杀叛军得分：领袖
     */
    public static final int REBEL_SCORE_LEADER = 12;

    /**
     * 叛军活动损兵比例
     */
    public static final double REBEL_TANK_RATIO = 0.2;

    /**
     * 叛军入侵活动首次开启条件，开服第几天
     */
    public static int REBEL_FIRST_OPEN_DAY;

    /**
     * 叛军入侵活动开启日期（星期几）
     */
    public static final List<Integer> RebelOpenWeekDayList = new ArrayList<>();

    /**
     * 叛军入侵活动开启时间, key:hour, value:minute
     */
    public static final Map<Integer, Integer> RebelOpenTimeMap = new HashMap<>();

    /**
     * 叛军入侵活动持续时长，单位：秒
     */
    public static int REBEL_DURATION;

    /**
     * 叛军入侵活动，将领按类型掉落上限：分队
     */
    public static int UNIT_DROP_LIMIT;

    /**
     * 叛军入侵活动，将领按类型掉落上限：卫队
     */
    public static int GUARD_DROP_LIMIT;

    /**
     * 叛军入侵活动，将领按类型掉落上限：领袖
     */
    public static int LEADER_DROP_LIMIT;

    /**
     * 单次叛军活动，可击杀叛军数上限
     */
    public static int KILL_REBEL_LIMIT;

    /**
     * 叛军两种类型之间出现的间隔时间，单位：秒
     */
    public static int REBEL_DELAY;

    /**
     * 叛军来袭礼盒触发概率
     */
    public static int REBEL_BOX_PROB;

    /**
     * 叛军来袭礼盒领取等级
     */
    public static int GET_BOX_LEVEL;

    /**
     * 叛军来袭礼盒初始个数
     */
    public static int BOX_INIT_COUNT;

    /**
     * 叛军来袭礼盒及红包每人每天领取个数
     */
    public static int BOX_DAILY_LIMIT;

    /**
     * 叛军来袭世界金币红包个数
     */
    public static int WORLD_REDBAG_COUNT;
    public static int REBEL_TYPE_BOOS_REDBAG;

    public static String REBEL_HP;

    public static void loadSystem(LoadService loadService) {
        REBEL_FIRST_OPEN_DAY = loadService.getIntegerSystemValue(SystemId.REBEL_FIRST_OPEN_DAY, 8);
        String openWeekDay = loadService.getStringSystemValue(SystemId.REBEL_OPEN_WEEK_DAY, "2,4");
        RebelOpenWeekDayList.clear();
        if (!CheckNull.isNullTrim(openWeekDay)) {
            String[] ss = openWeekDay.split(",");
            for (String str : ss) {
                RebelOpenWeekDayList.add(Integer.valueOf(str));
            }
            Collections.sort(RebelOpenWeekDayList);
        }
        String openTime = loadService.getStringSystemValue(SystemId.REBEL_OPEN_TIME, "12:00,18:00");
        RebelOpenTimeMap.clear();
        if (!CheckNull.isNullTrim(openTime)) {
            String[] strs = openTime.split(",");
            for (String str : strs) {
                if (str.indexOf(":") > -1) {
                    String[] ss = str.split(":");
                    RebelOpenTimeMap.put(Integer.valueOf(ss[0]), Integer.valueOf(ss[1]));
                }
            }
        }

        REBEL_DURATION = loadService.getIntegerSystemValue(SystemId.REBEL_DURATION, 3600);
        UNIT_DROP_LIMIT = loadService.getIntegerSystemValue(SystemId.UNIT_DROP_LIMIT, 10);
        GUARD_DROP_LIMIT = loadService.getIntegerSystemValue(SystemId.GUARD_DROP_LIMIT, 5);
        LEADER_DROP_LIMIT = loadService.getIntegerSystemValue(SystemId.LEADER_DROP_LIMIT, 1);
        KILL_REBEL_LIMIT = loadService.getIntegerSystemValue(SystemId.KILL_REBEL_LIMIT, 5);
        REBEL_DELAY = loadService.getIntegerSystemValue(SystemId.REBEL_DELAY, 300);
        REBEL_BOX_PROB = loadService.getIntegerSystemValue(SystemId.REBEL_BOX_PROB, 33);
        GET_BOX_LEVEL = loadService.getIntegerSystemValue(SystemId.GET_BOX_LEVEL, 20);
        BOX_INIT_COUNT = loadService.getIntegerSystemValue(SystemId.BOX_INIT_COUNT, 20);
        BOX_DAILY_LIMIT = loadService.getIntegerSystemValue(SystemId.BOX_DAILY_LIMIT, 5);
        WORLD_REDBAG_COUNT = loadService.getIntegerSystemValue(SystemId.WORLD_REDBAG_COUNT, 20);
        REBEL_HP = loadService.getStringSystemValue(SystemId.REBEL_HP, "[[0,2,500],[2,5,200],[5,30,150],[30,60,120]]");
        REBEL_TYPE_BOOS_REDBAG = loadService.getIntegerSystemValue(SystemId.REBEL_TYPE_BOOS_REDBAG, 500);

    }

}
