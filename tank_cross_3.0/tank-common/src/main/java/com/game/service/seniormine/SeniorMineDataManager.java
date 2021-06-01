/**
 * @Title: SenioMineDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2016年3月14日 下午2:56:50
 * @version V1.0
 */
package com.game.service.seniormine;

import com.game.dao.table.mine.CrossMinePlayerTableDao;
import com.game.datamgr.StaticWorldDataMgr;
import com.game.domain.CrossPlayer;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.Army;
import com.game.domain.p.Guard;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticMineForm;
import com.game.domain.table.crossmine.CrossMinePlayerTable;
import com.game.manager.cross.seniormine.CrossMineCache;
import com.game.pb.CommonPb;
import com.game.util.Tuple;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;


/**
 * 军事矿区数据相关
 *
 * @author
 * @ClassName: SeniorMineDataManager
 * @Description: TODO
 */
@Component
public class SeniorMineDataManager {

    public final int START_STATE = 1;// 开始
    public final int END_STATE = 2;// 结束

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;
    @Autowired
    private CrossMinePlayerTableDao crossMinePlayerTableDao;

    // 军事矿区驻军数据
    private Map<Integer, List<Guard>> guardMap = new ConcurrentHashMap<>();

    // 矿的防守阵型
    private Map<Integer, StaticMineForm> mineFormMap = new HashMap<>();


    // 积分排行玩家id
    private Set<Long> scoreRankSet = new HashSet<>();

    /**
     * 存玩家个人
     */
    private LinkedList<SeniorScoreRank> scoreRank = new LinkedList<>();

    /**
     * 存 服务器 累计获取积分
     */
    private Map<Integer, SeniorScoreRank> serverScoreRank = new ConcurrentHashMap<>();

    /**
     * 活动状态
     */
    private int state;

    public Map<Integer, List<Guard>> getGuardMap() {
        return guardMap;
    }


    private Set<Long> getInfo = new HashSet<>();

    /**
     * 传坐标进去 获得矿点对象
     *
     * @param pos 坐标
     * @return StaticMine
     */
    public StaticMine evaluatePos(int pos) {
        StaticMine staticMine = staticWorldDataMgr.getSeniorMine(pos);
        return staticMine;
    }

    /**
     * 传坐标和矿点等级  如果该坐标没有部队 则设置指定等级的部队
     *
     * @param pos
     * @param lv
     * @return StaticMineForm
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
     * 获取矿
     *
     * @param pos
     * @return Guard
     */
    public Guard getMineGuard(int pos) {
        List<Guard> list = guardMap.get(pos);
        if (list != null && !list.isEmpty()) {
            return list.get(0);
        }
        return null;
    }

    /**
     * 重置矿点部队
     *
     * @param pos
     * @param lv  void
     */
    public void resetMineForm(int pos, int lv) {
        mineFormMap.put(pos, staticWorldDataMgr.randomForm(lv));
    }

    /**
     * 将防守部队设置到目标坐标
     *
     * @param guard void
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
     * 将防守部队从目标坐标删除
     *
     * @param guard void
     */
    public void removeGuard(Guard guard) {
        int pos = guard.getArmy().getTarget();
        guard.getArmy().setStartFreeWarTime(0);
        guard.getArmy().setFreeWarTime(0);
        guardMap.get(pos).remove(guard);
    }

    /**
     * 从指定坐标将防守部队删除
     * void
     */
    public void removeGuard(int pos) {
        guardMap.remove(pos);
    }

    /**
     * 将指定玩家的指定部队从目标坐标删除
     *
     * @param player
     * @param army   void
     */
    public void removeGuard(CrossPlayer player, Army army) {
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
     * 查询玩家排名
     *
     * @param player
     * @return SeniorScoreRank
     */
    private SeniorScoreRank findRank(CrossPlayer player) {
        for (SeniorScoreRank one : scoreRank) {
            if (one.getLordId() == player.getRoleId()) {
                return one;
            }
        }

        return null;
    }


    /**
     * 将玩家加入排行并设置玩家排名
     *
     * @param player void
     */
    public void setScoreRank(CrossPlayer player) {
        SeniorScoreRank rank;
        if (scoreRankSet.contains(player.getRoleId())) {
            rank = findRank(player);
            if (rank != null) {
                if (player.getSenScore() < 150) {
                    scoreRank.remove(rank);
                    scoreRankSet.remove(player.getRoleId());
                    return;
                }

                rank.setScore(player.getSenScore());
                rank.setFight(player.getFight());
                Collections.sort(scoreRank, new ComparatorScore());
            }
        } else {
            if (player.getSenScore() < 150) {
                return;
            }

            if (scoreRank.isEmpty()) {
                scoreRank.add(new SeniorScoreRank(player));
            } else {
                boolean added = false;
                ListIterator<SeniorScoreRank> rankIt = scoreRank.listIterator(scoreRank.size());
                while (rankIt.hasPrevious()) {
                    SeniorScoreRank e = rankIt.previous();
                    if (player.getSenScore() < e.getScore()) {
                        rankIt.next();
                        rankIt.add(new SeniorScoreRank(player));
                        added = true;
                        break;
                    } else if (player.getSenScore() == e.getScore()) {
                        if (player.getFight() <= e.getFight()) {
                            rankIt.next();
                            rankIt.add(new SeniorScoreRank(player));
                            added = true;
                            break;
                        }
                    }
                }

                if (!added) {
                    scoreRank.addFirst(new SeniorScoreRank(player));
                }
            }

            scoreRankSet.add(player.getRoleId());
            if (scoreRank.size() > 20) {
                scoreRankSet.remove(scoreRank.removeLast().getLordId());
            }
        }
    }


    /**
     * 增加服务器积分
     *
     * @param player
     * @param score
     */
    public void addServerScore(CrossPlayer player, int score) {
        SeniorScoreRank seniorScoreRank = serverScoreRank.get(player.getServerId());
        if (seniorScoreRank == null) {
            seniorScoreRank = new SeniorScoreRank(player.getServerId());
            serverScoreRank.put(player.getServerId(), seniorScoreRank);
        }
        seniorScoreRank.setScore(seniorScoreRank.getScore() + score);
    }

    /**
     * 获取服务器排行
     */
    public List<SeniorScoreRank> getServerScoreRank() {
        List<SeniorScoreRank> list = new ArrayList<>(serverScoreRank.values());
        Collections.sort(list, new ComparatorScore());
        return list;
    }

    /**
     * 获取服务器排行(名次)
     */
    public int getServerScoreRank(int serverId) {
        List<SeniorScoreRank> list = new ArrayList<>(serverScoreRank.values());
        Collections.sort(list, new ComparatorScore());
        for (int i = 0; i < list.size(); i++) {
            SeniorScoreRank seniorScoreRank = list.get(i);
            if (seniorScoreRank.getLordId() == serverId) {
                return i + 1;
            }
        }
        return 0;
    }

    /**
     * 获取服务器积分
     */
    public int getServerScore(int serverId) {
        List<SeniorScoreRank> list = new ArrayList<>(serverScoreRank.values());
        Collections.sort(list, new ComparatorScore());
        for (int i = 0; i < list.size(); i++) {
            SeniorScoreRank seniorScoreRank = list.get(i);
            if (seniorScoreRank.getLordId() == serverId) {
                return seniorScoreRank.getScore();
            }
        }
        return 0;
    }

    public void addServerRank(SeniorScoreRank rank) {
        serverScoreRank.put((int) rank.getLordId(), rank);
    }


    /**
     * 军事矿排行
     *
     * @param roleId
     * @return Turple<Integer,SeniorScoreRank>
     */
    public Tuple<Integer, SeniorScoreRank> getScoreRank(long roleId) {
        if (scoreRankSet.contains(roleId)) {
            int rank = 0;
            for (SeniorScoreRank e : scoreRank) {
                rank++;
                if (e.getLordId() == roleId) {
                    return new Tuple<>(rank, e);
                }
            }
        }
        return new Tuple<>(0, null);
    }


    public int getSeniorState() {
        return this.state;
    }

    public LinkedList<SeniorScoreRank> getScoreRank() {
        return scoreRank;
    }

    public void setScoreRank(LinkedList<SeniorScoreRank> scoreRank) {
        this.scoreRank = scoreRank;
    }


    /**
     * 清楚积分和排名(周六凌晨)
     * void
     */
    public void clearRanking() {
        this.state = START_STATE;
        clearRank();
    }


    /**
     * 清理排名
     * void
     */
    public void clearRank() {
        scoreRank.clear();
        scoreRankSet.clear();
        serverScoreRank.clear();
        this.getInfo.clear();
        guardMap.clear();
        Map<Long, CrossPlayer> playerMap = CrossMineCache.playerMap;
        for (CrossPlayer player : playerMap.values()) {
            player.setSenScore(0);
            CrossMinePlayerTable table = crossMinePlayerTableDao.get(player.getRoleId());
            if (table == null) {
                CrossMinePlayerTable table1 = new CrossMinePlayerTable(player);
                crossMinePlayerTableDao.insert(table1);
            } else {
                table.setScore(player.getSenScore());
                crossMinePlayerTableDao.update(table);
            }
        }
    }

    /**
     * 清楚积分和排名（周一凌晨）
     * void
     */
    public void calRanking() {
        this.state = END_STATE;
        guardMap.clear();
    }


    /**
     * 清理排名
     * void
     */
    public void clear() {
        scoreRank.clear();
        scoreRankSet.clear();
        serverScoreRank.clear();
        Map<Long, CrossPlayer> playerMap = CrossMineCache.playerMap;
        for (CrossPlayer player : playerMap.values()) {
            player.setSenScore(0);
            CrossMinePlayerTable table = crossMinePlayerTableDao.get(player.getRoleId());
            if (table == null) {
                CrossMinePlayerTable table1 = new CrossMinePlayerTable(player);
                crossMinePlayerTableDao.insert(table1);
            } else {
                table.setScore(player.getSenScore());
                crossMinePlayerTableDao.update(table);
            }
        }
    }


    public void addGetInfo(CrossPlayer player) {
        this.getInfo.add(player.getRoleId());
    }

    public boolean isOnGet(CrossPlayer player) {
        return this.getInfo.contains(player.getRoleId());
    }

    public Set<Long> getGetInfo() {
        return getInfo;
    }

    public void setGetInfo(Set<Long> getInfo) {
        this.getInfo = getInfo;
    }
}

/**
 * 军事矿区排序器
 */
class ComparatorScore implements Comparator<SeniorScoreRank> {

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


