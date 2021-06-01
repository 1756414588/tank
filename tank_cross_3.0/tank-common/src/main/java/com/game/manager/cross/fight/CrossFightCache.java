package com.game.manager.cross.fight;

import com.game.constant.CrossConst;
import com.game.cross.domain.*;
import com.game.pb.CommonPb;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 18:31
 * @description：跨服战缓存
 */
public class CrossFightCache {

    private static final Map<Long, Athlete> athleteMap = new HashMap<>();

    /**
     * 巅峰参赛者
     */
    private static final LinkedHashMap<Long, Athlete> dfAthleteMap =
            new LinkedHashMap<Long, Athlete>();
    /**
     * 精英参赛者
     */
    private static final LinkedHashMap<Long, Athlete> jyAthleteMap =
            new LinkedHashMap<Long, Athlete>();

    /**
     * 所有的积分玩家
     */
    private static final LinkedHashMap<Long, JiFenPlayer> jifenPlayerMap = new LinkedHashMap<>();

    /**
     * 巅峰组信息 淘汰战
     */
    private static final Map<Integer, KnockoutBattleGroup> dfKnockoutBattleGroups = new HashMap<>();
    /**
     * 精英组信息 淘汰战
     */
    private static final Map<Integer, KnockoutBattleGroup> jyKnockoutBattleGroups = new HashMap<>();

    /**
     * 精英组信息 决战
     */
    private static final Map<Integer, CompetGroup> jyFinalBattleGroups = new HashMap<>();
    /**
     * 巅峰组信息 决战
     */
    private static final Map<Integer, CompetGroup> dfFinalBattleGroups = new HashMap<>();

    /**
     * 记录缓存
     */
    private static final LinkedHashMap<Integer, CommonPb.CrossRecord> crossRecords =
            new LinkedHashMap<>();

    /**
     * 战报
     */
    private static final Map<Integer, CommonPb.CrossRptAtk> crossRptAtks = new HashMap<>();

    /**
     * 跨服商店的珍品购买情况（改了需求珍品商店没有全局限购的概念,此数据暂时用不上,先放着）
     */
    private static final Map<Integer, CrossShopBuy> crossShopMap =
            new HashMap<Integer, CrossShopBuy>();

    /**
     * jy排行
     */
    private static final LinkedHashMap<Long, Long> jyRankMap = new LinkedHashMap<>();
    /**
     * df排行
     */
    private static final LinkedHashMap<Long, Long> dfRankMap = new LinkedHashMap<>();

    /**
     * 添加玩家信息到缓存
     *
     * @param athlete
     */
    public static void addAthlete(Athlete athlete) {

        athleteMap.put(athlete.getRoleId(), athlete);

//        LogHelper.ERROR_LOGGER.error("AAAAAAAAAAA roleId=" + athlete.getRoleId() + " name=" + athlete.getNick());

        if (athlete.getGroupId() == CrossConst.DF_Group) {
            dfAthleteMap.put(athlete.getRoleId(), athlete);
        } else {
            jyAthleteMap.put(athlete.getRoleId(), athlete);
        }
    }

    public static Athlete getAthlete(long roleId) {
        return athleteMap.get(roleId);
    }

    /**
     * 删除玩家信息缓存
     *
     * @param athlete
     */
    public static void removeAthlete(Athlete athlete) {

        athleteMap.remove(athlete.getRoleId());
        if (athlete.getGroupId() == CrossConst.DF_Group) {
            dfAthleteMap.remove(athlete.getRoleId());
        } else {
            jyAthleteMap.remove(athlete.getRoleId());
        }
    }

    /**
     * 积分玩家
     *
     * @return
     */
    public static void addJifenPlayer(JiFenPlayer jiFenPlayer) {
        jifenPlayerMap.put(jiFenPlayer.getRoleId(), jiFenPlayer);
    }

    /**
     * 巅峰参赛者
     *
     * @return
     */
    public static LinkedHashMap<Long, Athlete> getDfAthleteMap() {
        return dfAthleteMap;
    }

    /**
     * 精英参赛者
     *
     * @return
     */
    public static LinkedHashMap<Long, Athlete> getJyAthleteMap() {
        return jyAthleteMap;
    }

    /**
     * 巅峰组信息 淘汰战
     *
     * @return
     */
    public static Map<Integer, KnockoutBattleGroup> getDfKnockoutBattleGroups() {
        return dfKnockoutBattleGroups;
    }

    /**
     * 精英组信息 淘汰战
     *
     * @return
     */
    public static Map<Integer, KnockoutBattleGroup> getJyKnockoutBattleGroups() {
        return jyKnockoutBattleGroups;
    }

    /**
     * 精英组信息 决战
     *
     * @return
     */
    public static Map<Integer, CompetGroup> getJyFinalBattleGroups() {
        return jyFinalBattleGroups;
    }

    /**
     * 巅峰组信息 决战
     *
     * @return
     */
    public static Map<Integer, CompetGroup> getDfFinalBattleGroups() {
        return dfFinalBattleGroups;
    }

    /**
     * 所有的积分玩家
     *
     * @return
     */
    public static LinkedHashMap<Long, JiFenPlayer> getJifenPlayerMap() {
        return jifenPlayerMap;
    }

    public static LinkedHashMap<Integer, CommonPb.CrossRecord> getCrossRecords() {
        return crossRecords;
    }

    public static Map<Integer, CommonPb.CrossRptAtk> getCrossRptAtks() {
        return crossRptAtks;
    }

    public static Map<Integer, CrossShopBuy> getCrossShopMap() {
        return crossShopMap;
    }

    public static LinkedHashMap<Long, Long> getJyRankMap() {
        return jyRankMap;
    }

    public static LinkedHashMap<Long, Long> getDfRankMap() {
        return dfRankMap;
    }

    public static Map<Long, Athlete> getAthleteMap() {
        return athleteMap;
    }
}
