/**
 * @Title: StaffingDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2016年3月10日 下午4:52:33
 * @version V1.0
 */
package com.game.manager;

import java.util.*;

import com.game.constant.ArmyState;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.pb.BasePb;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.ChatService;
import com.game.service.SeniorMineService;
import com.game.service.WorldMineService;
import com.game.service.WorldService;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.actor.role.PlayerEventService;
import com.game.dao.impl.p.ServerLogDao;
import com.game.dataMgr.StaticStaffingDataMgr;
import com.game.domain.Player;
import com.game.util.TimeHelper;

/**
 * @author ZhangJun
 * @ClassName: StaffingDataManager
 * @Description:
 * @date 2016年3月10日 下午4:52:33
 */

// class ComparatorGroup implements Comparator<Player> {
//
// /**
// * Overriding: compare
// *
// * @param o1
// * @param o2
// * @return
// * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
// */
// @Override
// public int compare(Player o1, Player o2) {
// //Auto-generated method stub
// Lord l1 = o1.lord;
// Lord l2 = o2.lord;
//
// if (l1.getStaffingLv() < l2.getStaffingLv())
// return 1;
// else if (l1.getStaffingLv() > l2.getStaffingLv()) {
// return -1;
// } else {
// if (l1.getStaffingExp() < l2.getStaffingExp()) {
// return 1;
// } else if (l1.getStaffingExp() > l2.getStaffingExp()) {
// return -1;
// }
// return 0;
// }
// }
// }

class ComparatorRank implements Comparator<StaffingRank> {

    /**
     * Overriding: compare
     *
     * @param o1
     * @param o2
     * @return
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    @Override
    public int compare(StaffingRank o1, StaffingRank o2) {
        //Auto-generated method stub
        Lord l1 = o1.player.lord;
        Lord l2 = o2.player.lord;

//		if (o1.id < o2.id) {
//			return 1;
//		} else if (o1.id > o2.id) {
//			return -1;
//		} else {
//			if (l1.getStaffingLv() < l2.getStaffingLv())
//				return 1;
//			else if (l1.getStaffingLv() > l2.getStaffingLv()) {
//				return -1;
//			} else {
//				if (l1.getStaffingExp() < l2.getStaffingExp()) {
//					return 1;
//				} else if (l1.getStaffingExp() > l2.getStaffingExp()) {
//					return -1;
//				}
//				return 0;
//			}
//		}

        if (l1.getStaffingLv() < l2.getStaffingLv())
            return 1;
        else if (l1.getStaffingLv() > l2.getStaffingLv()) {
            return -1;
        } else {
            if (l1.getStaffingExp() < l2.getStaffingExp()) {
                return 1;
            } else if (l1.getStaffingExp() > l2.getStaffingExp()) {
                return -1;
            }
            return o1.id > o2.id ? 1 : o1.id < o2.id ? -1 : 0;
        }


    }
}

class StaffingRank {
    public Player player;
    public int id;

    /**
     * @param player
     * @param id
     */
    public StaffingRank(Player player, int id) {
        super();
        this.player = player;
        this.id = id;
    }

}

@Component
public class StaffingDataManager {

    @Autowired
    private ServerLogDao serverLogDao;

    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private WorldDataManager worldDataManager;
    @Autowired
    private WorldService worldService;
    @Autowired
    private WorldMineService worldMineService;
    @Autowired
    private ChatService chatService;
    @Autowired
    private SeniorMineDataManager seniorMineDataManager;
    @Autowired
    private SeniorMineService seniorMineService;
    private WorldLog worldLog;

    private StaticStaffingWorld staffingWorld;

    // private List<List<StaffingRank>> staffingList = new ArrayList<>();

    private List<StaffingRank> totalList = new ArrayList<>();

    public void addStaffingPlayer(Player player) {
        if (player.lord.getStaffing() >= 6) {
            // staffingList.get(player.lord.getStaffing() - 6).add(new
            // StaffingRank(player, player.lord.getStaffing()));
            totalList.add(new StaffingRank(player, player.lord.getStaffing()));
        }
    }

    public void sortStaffing() {
        // for (int i = 0; i < 6; i++) {
        // List<StaffingRank> list = staffingList.get(i);
        // Collections.sort(list, new ComparatorRank());
        // }

        Collections.sort(totalList, new ComparatorRank());
    }

    //	@PostConstruct
    public void init() {

    }

    public void initStaffingWorld() {
        // for (int i = 0; i < 6; i++) {
        // staffingList.add(new ArrayList<StaffingRank>());
        // }

        worldLog = serverLogDao.selectLastWorldLog();
        int currentDay = TimeHelper.getCurrentDay();
        if (worldLog == null || worldLog.getLvTime() < currentDay) {
            List<Lord> list = rankDataManager.getRankList(9);
            int totalLv = 0;
            for (Lord lord : list) {
                totalLv += lord.getStaffingLv();
            }

            staffingWorld = staticStaffingDataMgr.calcWolrdLv(totalLv);

            worldLog = new WorldLog();
            worldLog.setLvTime(currentDay);
            worldLog.setTotalLv(totalLv);
            worldLog.setWorldLv(staffingWorld.getWorldLv());
            flushWarLog();
        } else {
            staffingWorld = staticStaffingDataMgr.calcWolrdLv(worldLog.getTotalLv());
        }
    }

    public void reCalcWorldLv() {
        int currentDay = TimeHelper.getCurrentDay();
        if (currentDay != worldLog.getLvTime()) {


            //世界等级开始衰减
            WorldStaffing worldStaffing = globalDataManager.gameGlobal.getWorldStaffing();

            long oldExp = worldStaffing.getExp();

            if (worldStaffing.getExp() > 0) {

                StaticWorldMine staticWorldMine = staticWorldDataMgr.getStaticWorldMine(worldStaffing.getExp());

                double exp = worldStaffing.getExp() * (1 - (staticWorldMine.getDecline() / 1000.0f));
                if (exp < 1.0f) {
                    worldStaffing.setExp(0);
                } else {
                    worldStaffing.setExp(Math.round(exp));
                }

                LogUtil.common("reCalcWorldLv worldStaffing old= " + oldExp + " exp=" + worldStaffing.getExp() + " decline=" + staticWorldMine.getDecline());
            }

            long roleExp = 0;

            Map<Long, Player> players = playerDataManager.getPlayers();
            int totalLv = 0;
            for (Player player : players.values()) {
                try {
                    totalLv += player.lord.getStaffingLv();
                    if (player.lord.getStaffingLv() == 999) {
                        int ex = (int) (player.lord.getStaffingExp() * 0.1);
                        roleExp += ex;
                        LogUtil.common("reCalcWorldLv worldStaffing player contributionWorldStaffing  old= " + player.contributionWorldStaffing + " exp=" + ex);
                        player.contributionWorldStaffing = ex;
                        player.lord.setStaffingExp(player.lord.getStaffingExp() - ex);
                        playerDataManager.synStaffingToPlayer(playerDataManager.getPlayer(player.lord.getLordId()));

                    } else {
                        player.contributionWorldStaffing = 0;
                    }
                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }


            staffingWorld = staticStaffingDataMgr.calcWolrdLv(totalLv);

            worldLog = new WorldLog();
            worldLog.setLvTime(currentDay);
            worldLog.setTotalLv(totalLv);
            worldLog.setWorldLv(staffingWorld.getWorldLv());
            flushWarLog();
            worldStaffing.setExp(worldStaffing.getExp() + roleExp);

            for (Player player : players.values()) {
                try {

                    if (player.isLogin) {
                        GamePb6.SynWorldStaffingRq.Builder builder = GamePb6.SynWorldStaffingRq.newBuilder();
                        builder.setWorldExp(worldStaffing.getExp());
                        builder.setDayExp(player.contributionWorldStaffing);
                        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynWorldStaffingRq.EXT_FIELD_NUMBER, GamePb6.SynWorldStaffingRq.ext, builder.build());
                        GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
                    }

                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }
            changeWorldLevel(oldExp);
            recollectArmy((int) (System.currentTimeMillis() / 1000));
        }
    }

    public int getWorldLv() {
        if (staffingWorld == null) {
            return 0;
        }
        return staffingWorld.getWorldLv();
    }

    public double getWorldRatio() {
        return 1 - staffingWorld.getHaust() / 100.0;
    }

    public void flushWarLog() {
        serverLogDao.insertWorldLog(worldLog);
    }

    final static int[] LIMIT = {9999, 30, 10, 6, 3, 1};

    private void rerank() {
        if (totalList.isEmpty()) {
            return;
        }

        Collections.sort(totalList, new ComparatorRank());

        int maxId = totalList.get(0).id;
        int[] count = {0, 0, 0, 0, 0, 0};


        int id;
        for (int i = 0; i < totalList.size(); i++) {
            StaffingRank e = totalList.get(i);
            id = e.id;
            if (id > maxId) {
                id = maxId;
            }

            if (count[id - 6] < LIMIT[id - 6]) {
                if (id != e.player.lord.getStaffing()) {
                    e.player.lord.setStaffing(id);
                    playerDataManager.synStaffingToPlayer(e.player);
                }

                count[id - 6]++;
            } else {
                maxId = id - 1;
                i--;
            }
        }
    }

    private void removeRank(Player player) {
        for (Iterator<StaffingRank> iterator = totalList.iterator(); iterator.hasNext(); ) {
            if (iterator.next().player.roleId.equals(player.roleId)) {
                iterator.remove();
                return;
            }
        }
    }

    private StaffingRank findRank(Player player) {
        StaffingRank rank = null;
        for (Iterator<StaffingRank> iterator = totalList.iterator(); iterator.hasNext(); ) {
            rank = iterator.next();
            if (rank.player.roleId.equals(player.roleId)) {
                return rank;
            }
        }
        return null;
    }

    /**
     * 根据玩家当前编制等级 得到编制类型
     *
     * @param player
     * @return int
     */
    public int calcStaffing(Player player) {
        int calcId = 0;
        int preId = player.lord.getStaffing();

        StaticStaffing staticStaffing = staticStaffingDataMgr.calcStaffing(player.lord.getStaffingLv(), player.lord.getRanks());
        if (staticStaffing == null) {
            calcId = 0;
        } else {
            calcId = staticStaffing.getStaffingId();
        }

//		LogHelper.MESSAGE_LOGGER.trace("player:" + player.lord.getNick() + " calc 1:" + calcId);

        if (preId < 6 && calcId < 6) {
            player.lord.setStaffing(calcId);
            playerDataManager.synStaffingToPlayer(player);
            //重新计算玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
//			LogHelper.MESSAGE_LOGGER.trace("player:" + player.lord.getNick() + " calc 2:" + calcId);
            return calcId;
        }

        if (preId < 6) {// 上排行榜
            totalList.add(new StaffingRank(player, calcId));
            rerank();
//			LogHelper.MESSAGE_LOGGER.trace("player:" + player.lord.getNick() + " calc 3:" + calcId);
        } else {
            if (calcId < 6) {// 下榜
                removeRank(player);
                player.lord.setStaffing(calcId);
                playerDataManager.synStaffingToPlayer(player);
                //重新计算玩家最强实力
                playerEventService.calcStrongestFormAndFight(player);
                rerank();
//				LogHelper.MESSAGE_LOGGER.trace("player:" + player.lord.getNick() + " calc 4:" + calcId);
            } else {// 重新排
                StaffingRank rank = findRank(player);
                if (rank != null) {
                    rank.id = calcId;
                }
                rerank();
//				LogHelper.MESSAGE_LOGGER.trace("player:" + player.lord.getNick() + " calc 5:" + calcId);
            }
        }

        return player.lord.getStaffing();
    }

    public void setWorldLv(int lv) {
        staffingWorld = staticStaffingDataMgr.getStaffingWorld(lv);
    }


    public int getWorldMineLevel() {
        WorldStaffing worldStaffing = globalDataManager.gameGlobal.getWorldStaffing();
        if (worldStaffing.getExp() > 0) {
            StaticWorldMine staticWorldMine = staticWorldDataMgr.getStaticWorldMine(worldStaffing.getExp());
            return staticWorldMine.getLv() * 2;
        }
        return 0;
    }


    public StaticWorldMine getWorldMineLevelConfig() {
        WorldStaffing worldStaffing = globalDataManager.gameGlobal.getWorldStaffing();
        StaticWorldMine staticWorldMine = staticWorldDataMgr.getStaticWorldMine(worldStaffing.getExp());
        return staticWorldMine;
    }

    public void changeWorldLevel(long exp) {
        StaticWorldMine staticWorldMine = staticWorldDataMgr.getStaticWorldMine(exp);
        //等级发生了变化
        StaticWorldMine worldMineLevel2 = getWorldMineLevelConfig();

        if (staticWorldMine.getLv() != worldMineLevel2.getLv()) {
            worldDataManager.getMineFormMap().clear();
            seniorMineDataManager.getMineFormMap().clear();
            //升级
            if (staticWorldMine.getLv() < worldMineLevel2.getLv()) {
                chatService.sendHornChat(chatService.createSysChat(SysChatId.world_level_1, worldMineLevel2.getLv() + ""), 1);
            }
            //降级
            if (staticWorldMine.getLv() > worldMineLevel2.getLv()) {
                chatService.sendHornChat(chatService.createSysChat(SysChatId.world_level_2, worldMineLevel2.getLv() + ""), 1);
            }

        }

    }

    /**
     * 世界经验发生变化，采集加速，重新计算所有已经在采集的部队
     */
    public void recollectArmy(int now) {

//		recollectArmyWorld(now);
//
//		recollectArmySenior(now);

    }

    private void recollectArmyWorld(int now) {
        Map<Integer, List<Guard>> guardMap = worldDataManager.getGuardMap();
        for (List<Guard> guardList : guardMap.values()) {
            for (Guard guard : guardList) {
                try {
                    StaticMine staticMine = worldDataManager.evaluatePos(guard.getArmy().getTarget());
                    if (staticMine == null || guard == null) {
                        continue;
                    }
                    StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), getWorldMineLevel());
                    if (staticMineLv == null) {
                        continue;
                    }
                    Player player = guard.getPlayer();
                    Army army = guard.getArmy();
                    if (army.getState() != ArmyState.COLLECT) {
                        continue;
                    }
                    if (army.getEndTime() < now || army.getEndTime() - army.getPeriod() > now) {
                        continue;
                    }
                    int collect = worldMineService.getMineProdunction(guard.getArmy().getTarget(), staticMineLv.getProduction());
                    long get = playerDataManager.calcCollect(player, army, now, staticMine,
                            worldMineService.getMineProdunction(guard.getArmy().getTarget(), staticMineLv.getProduction()));
                    worldService.recollectArmy(player, army, now, staticMine, collect, get);
                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }


        }
        LogUtil.common("世界经验发生变化，采集加速，重新计算所有已经在采集的部队 : ");

    }

    private void recollectArmySenior(int now) {
        Map<Integer, List<Guard>> seniorGuardMap = seniorMineDataManager.getGuardMap();
        for (List<Guard> guardList : seniorGuardMap.values()) {
            for (Guard guard : guardList) {
                try {
                    StaticMine staticMine = seniorMineDataManager.evaluatePos(guard.getArmy().getTarget());
                    if (staticMine == null || guard == null) {
                        continue;
                    }
                    StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), getWorldMineLevel());
                    if (staticMineLv == null) {
                        continue;
                    }
                    Player player = guard.getPlayer();
                    Army army = guard.getArmy();
                    if (army.getState() != ArmyState.COLLECT) {
                        continue;
                    }
                    if (army.getEndTime() < now || army.getEndTime() - army.getPeriod() > now) {
                        continue;
                    }
                    long get = playerDataManager.calcCollect(player, army, now, staticMine,
                            worldMineService.getMineProdunction(guard.getArmy().getTarget(), staticMineLv.getProduction()));
                    seniorMineService.refreshCollectArmy(player, guard.getArmy(), now, staticMine, staticMineLv.getProduction(), get);
                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }

        }

        LogUtil.common("世界经验发生变化，采集加速，重新计算所有军矿已经在采集的部队 : ");

    }
}
