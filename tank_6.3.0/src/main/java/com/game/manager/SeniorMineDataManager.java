/**
 * @Title: SenioMineDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2016年3月14日 下午2:56:50
 * @version V1.0
 */
package com.game.manager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.SeniorPartyScoreRank;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.Army;
import com.game.domain.p.Guard;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticMineForm;
import com.game.util.Tuple;


/**
 * 军事矿区排序器
 * @ClassName: ComparatorScore
 * @Description: TODO
 * @author
 */
class ComparatorScore implements Comparator<SeniorScoreRank> {

    /**
     * Overriding: compare
     *
     * @param o1
     * @param o2
     * @return
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    @Override
    public int compare(SeniorScoreRank o1, SeniorScoreRank o2) {
        //Auto-generated method stub
        int d1 = o1.getScore();
        int d2 = o2.getScore();

        if (d1 < d2)
            return 1;
        else if (d1 > d2) {
            return -1;
        } else {
            long v1 = o1.getFight();
            long v2 = o2.getFight();
            if (v1 < v2) {
                return 1;
            } else if (v1 > v2) {
                return -1;
            }

            return 0;
        }
    }
}

/**
 * 军事矿区军团排名
 * @ClassName: ComparatorPartyScore
 * @Description: TODO
 * @author
 */
class ComparatorPartyScore implements Comparator<SeniorPartyScoreRank> {

    /**
     * Overriding: compare
     *
     * @param o1
     * @param o2
     * @return
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    @Override
    public int compare(SeniorPartyScoreRank o1, SeniorPartyScoreRank o2) {
        //Auto-generated method stub
        int d1 = o1.getScore();
        int d2 = o2.getScore();

        if (d1 < d2)
            return 1;
        else if (d1 > d2) {
            return -1;
        } else {
            long v1 = o1.getFight();
            long v2 = o2.getFight();
            if (v1 < v2) {
                return 1;
            } else if (v1 > v2) {
                return -1;
            }

            return 0;
        }
    }
}

/**
 * 军事矿区数据相关
 * @ClassName: SeniorMineDataManager
 * @Description: TODO
 * @author
 */
@Component
public class SeniorMineDataManager {
    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    // 军事矿区驻军数据
    private Map<Integer, List<Guard>> guardMap = new HashMap<>();

    // 矿的防守阵型
    private Map<Integer, StaticMineForm> mineFormMap = new HashMap<>();

    public Map<Integer, StaticMineForm> getMineFormMap() {
        return mineFormMap;
    }

    // 积分排行玩家id
    private Set<Long> scoreRankSet = new HashSet<>();

    // 积分排行玩家id
    private Set<Integer> partyScoreRankSet = new HashSet<>();

    //	@PostConstruct
    public void init() {
        initData();
    }

    private void initData() {
        for (SeniorScoreRank rank : globalDataManager.gameGlobal.getScoreRank()) {
            scoreRankSet.add(rank.getLordId());
        }

        for (SeniorPartyScoreRank rank : globalDataManager.gameGlobal.getScorePartyRank()) {
            partyScoreRankSet.add(rank.getPartyId());
        }
    }

    public Map<Integer, List<Guard>> getGuardMap() {
        return guardMap;
    }

    public void setGuardMap(Map<Integer, List<Guard>> guardMap) {
        this.guardMap = guardMap;
    }

    /**
     *
     * 传坐标进去 获得矿点对象
     * @param pos 坐标
     * @return
     * StaticMine
     */
    public StaticMine evaluatePos(int pos) {
        StaticMine staticMine = staticWorldDataMgr.getSeniorMine(pos);
        return staticMine;
    }

    /**
     *
     * 传坐标进去 获得矿点对象
     * @param pos 坐标
     * @return
     * StaticMine
     */
    public StaticMine getCrossSeniorMine(int pos) {
        StaticMine staticMine = staticWorldDataMgr.getCrossSeniorMine(pos);
        return staticMine;
    }

    /**
     *
     * 传坐标和矿点等级  如果该坐标没有部队 则设置指定等级的部队
     * @param pos
     * @param lv
     * @return
     * StaticMineForm
     */
    public StaticMineForm getMineForm(int pos, int lv) {
        StaticMineForm form = mineFormMap.get(pos);
        if (form == null) {
            form = staticWorldDataMgr.randomForm(lv);
            mineFormMap.put(pos, form);
        }
        return form;
    }

    /**
     *
     * 获取矿
     * @param pos
     * @return
     * Guard
     */
    public Guard getMineGuard(int pos) {
        List<Guard> list = guardMap.get(pos);
        if (list != null && !list.isEmpty()) {
            return list.get(0);
        }
        return null;
    }

    /**
     *
     * 重置矿点部队
     * @param pos
     * @param lv
     * void
     */
    public void resetMineForm(int pos, int lv) {
        mineFormMap.put(pos, staticWorldDataMgr.randomForm(lv));
    }

    /**
     *
     * 将防守部队设置到目标坐标
     * @param guard
     * void
     */
    public void setGuard(Guard guard) {
        int pos = guard.getArmy().getTarget();
        List<Guard> list = guardMap.get(pos);
        if (list == null) {
            list = new ArrayList<>();
            guardMap.put(pos, list);
        }
        list.add(guard);
    }

    /**
     *
     * 将防守部队从目标坐标删除
     * @param guard
     * void
     */
    public void removeGuard(Guard guard) {
        int pos = guard.getArmy().getTarget();
        guard.getArmy().setStartFreeWarTime(0);
        guard.getArmy().setFreeWarTime(0);
        guardMap.get(pos).remove(guard);
    }

    /**
     *
     * 从指定坐标将防守部队删除
     * @param guard
     * void
     */
    public void removeGuard(int pos) {
        guardMap.remove(pos);
    }

    /**
     *
     * 将指定玩家的指定部队从目标坐标删除
     * @param player
     * @param army
     * void
     */
    public void removeGuard(Player player, Army army) {
        int pos = army.getTarget();
        List<Guard> list = guardMap.get(pos);
        Guard e;
        if (list != null) {
            for (int i = 0; i < list.size(); i++) {
                e = list.get(i);
                if (e.getPlayer() == player && e.getArmy().getKeyId() == army.getKeyId()) {
                    e.getArmy().setStartFreeWarTime(0);
                    e.getArmy().setFreeWarTime(0);
                    list.remove(i);
                    break;
                }
            }
        }
    }

    /**
     *
     * 查询玩家排名
     * @param player
     * @return
     * SeniorScoreRank
     */
    private SeniorScoreRank findRank(Player player) {
        for (SeniorScoreRank one : globalDataManager.gameGlobal.getScoreRank()) {
            if (one.getLordId() == player.roleId) {
                return one;
            }
        }

        return null;
    }

    /**
     *
     * 查询军团排名
     * @param partyData
     * @return
     * SeniorPartyScoreRank
     */
    private SeniorPartyScoreRank findRank(PartyData partyData) {
        for (SeniorPartyScoreRank one : globalDataManager.gameGlobal.getScorePartyRank()) {
            if (one.getPartyId() == partyData.getPartyId()) {
                return one;
            }
        }
        return null;
    }

    /**
     *
     * 将玩家加入排行并设置玩家排名
     * @param player
     * void
     */
    public void setScoreRank(Player player) {

        LinkedList<SeniorScoreRank> list = globalDataManager.gameGlobal.getScoreRank();
        SeniorScoreRank rank;
        if (scoreRankSet.contains(player.roleId)) {
            rank = findRank(player);
            if (rank != null) {
                if (player.seniorScore < 150) {
                    list.remove(rank);
                    scoreRankSet.remove(player.roleId);
                    return;
                }

                rank.setScore(player.seniorScore);
                rank.setFight(player.lord.getFight());
                Collections.sort(list, new ComparatorScore());
            }
        } else {
            if (player.seniorScore < 150) {
                return;
            }

            if (list.isEmpty()) {
                list.add(new SeniorScoreRank(player));
            } else {
                boolean added = false;
                ListIterator<SeniorScoreRank> rankIt = list.listIterator(list.size());
                while (rankIt.hasPrevious()) {
                    SeniorScoreRank e = rankIt.previous();
                    if (player.seniorScore < e.getScore()) {
                        rankIt.next();
                        rankIt.add(new SeniorScoreRank(player));
                        added = true;
                        break;
                    } else if (player.seniorScore == e.getScore()) {
                        if (player.lord.getFight() <= e.getFight()) {
                            rankIt.next();
                            rankIt.add(new SeniorScoreRank(player));
                            added = true;
                            break;
                        }
                    }
                }

                if (!added) {
                    list.addFirst(new SeniorScoreRank(player));
                }
            }

            scoreRankSet.add(player.roleId);
            if (list.size() > 10) {
                scoreRankSet.remove(list.removeLast().getLordId());
            }
        }
    }

    /**
     *
     * 将军团加入排行榜并设置排名
     * @param partyData
     * void
     */
    public void setPartyScoreRank(PartyData partyData) {

        LinkedList<SeniorPartyScoreRank> list = globalDataManager.gameGlobal.getScorePartyRank();
        SeniorPartyScoreRank rank;
        if (partyScoreRankSet.contains(partyData.getPartyId())) {
            rank = findRank(partyData);
            if (rank != null) {
                if (partyData.getScore() < 800) {
                    partyScoreRankSet.remove(partyData.getPartyId());
                    list.remove(rank);
                    return;
                }

                rank.setScore(partyData.getScore());
                rank.setFight(partyData.getFight());
                Collections.sort(list, new ComparatorPartyScore());
            }
        } else {
            if (partyData.getScore() < 800) {
                return;
            }

            if (list.isEmpty()) {
                list.add(new SeniorPartyScoreRank(partyData));
            } else {
                boolean added = false;
                ListIterator<SeniorPartyScoreRank> rankIt = list.listIterator(list.size());
                while (rankIt.hasPrevious()) {
                    SeniorPartyScoreRank e = rankIt.previous();
                    if (partyData.getScore() < e.getScore()) {
                        rankIt.next();
                        rankIt.add(new SeniorPartyScoreRank(partyData));
                        added = true;
                        break;
                    } else if (partyData.getScore() == e.getScore()) {
                        if (partyData.getFight() <= e.getFight()) {
                            rankIt.next();
                            rankIt.add(new SeniorPartyScoreRank(partyData));
                            added = true;
                            break;
                        }
                    }
                }

                if (!added) {
                    list.addFirst(new SeniorPartyScoreRank(partyData));
                }
            }

            partyScoreRankSet.add(partyData.getPartyId());
            if (list.size() > 5) {
                partyScoreRankSet.remove(list.removeLast().getPartyId());
            }
        }
    }

    /**
     *
     * 军事矿排行
     * @param roleId
     * @return
     * Turple<Integer , SeniorScoreRank>
     */
    public Tuple<Integer, SeniorScoreRank> getScoreRank(long roleId) {
        if (scoreRankSet.contains(roleId)) {
            int rank = 0;
            for (SeniorScoreRank e : globalDataManager.gameGlobal.getScoreRank()) {
                rank++;
                if (e.getLordId() == roleId) {
                    return new Tuple<Integer, SeniorScoreRank>(rank, e);
                }
            }
        }

        return new Tuple<Integer, SeniorScoreRank>(0, null);
    }

    /**
     *
     * 军事矿军团排名
     * @param partyId
     * @return
     * Turple<Integer , SeniorPartyScoreRank>
     */
    public Tuple<Integer, SeniorPartyScoreRank> getPartyScoreRank(int partyId) {
        if (partyScoreRankSet.contains(partyId)) {
            int rank = 0;
            for (SeniorPartyScoreRank e : globalDataManager.gameGlobal.getScorePartyRank()) {
                rank++;
                if (e.getPartyId() == partyId) {
                    return new Tuple<Integer, SeniorPartyScoreRank>(rank, e);
                }
            }
        }

        return new Tuple<Integer, SeniorPartyScoreRank>(0, null);
    }

    public List<SeniorScoreRank> getScoreRankList() {
        return globalDataManager.gameGlobal.getScoreRank();
    }

    /**
     *
     * 军事矿军团排行
     * @return
     * List<SeniorPartyScoreRank>
     */
    public List<SeniorPartyScoreRank> getScorePartyRankList() {
        return globalDataManager.gameGlobal.getScorePartyRank();
    }

    /**
     *
     *   清理排名
     * void
     */
    public void clearRank() {
        globalDataManager.gameGlobal.getScoreRank().clear();
        globalDataManager.gameGlobal.getScorePartyRank().clear();
        partyScoreRankSet.clear();
        scoreRankSet.clear();
    }

    public int getSeniorState() {
//		return SeniorState.START_STATE;
//		return SeniorState.END_STATE;
        return globalDataManager.gameGlobal.getSeniorState();
    }

    /**
     *
     * 军事矿区砖头
     * @param state
     * void
     */
    public void setSeniorState(int state) {
        globalDataManager.gameGlobal.setSeniorState(state);
    }

    /**
     *
     * 开启军事矿区的第几周
     * @param week
     * void
     */
    public void setSeniorWeek(int week) {
        globalDataManager.gameGlobal.setSeniorWeek(week);
    }
}
