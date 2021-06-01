package com.game.manager.cross.seniormine;

import com.game.dao.table.mine.CrossMineArmyTableDao;
import com.game.dao.table.mine.CrossMinePlayerTableDao;
import com.game.domain.CrossPlayer;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.Army;
import com.game.domain.p.Guard;
import com.game.domain.table.crossmine.CrossMineAmryTable;
import com.game.domain.table.crossmine.CrossMinePlayerTable;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.game.service.seniormine.SeniorMineDataManager;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.google.common.base.Stopwatch;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author yeding
 * @create 2019/6/18 11:00
 * @decs
 */
@Component
public class CrossMineDataManager {

    private final int id = 1;

    @Autowired
    private CrossMinePlayerTableDao crossMinePlayerTableDao;

    @Autowired
    private CrossMineArmyTableDao crossMineArmyTableDao;

    @Autowired
    private SeniorMineDataManager seniorMineDataManager;

    private final Stopwatch stopwatch = Stopwatch.createUnstarted();


    /**
     * 初始化 玩家信息
     */
    public void initCrossMine() {
        List<CrossMinePlayerTable> allPlyaer = crossMinePlayerTableDao.findAll();
        for (CrossMinePlayerTable crossMinePlayerTable : allPlyaer) {
            CrossPlayer player = crossMinePlayerTable.desPlayer();
            CrossMineCache.addPlayer(player);
        }

        CrossMineAmryTable crossMineAmryTable = crossMineArmyTableDao.get(id);
        if (crossMineAmryTable != null) {


            byte[] armyInfo = crossMineAmryTable.getArmyInfo();
            byte[] playerRank = crossMineAmryTable.getPlayerRankInfo();
            byte[] serversRankScore = crossMineAmryTable.getServersRankScore();
            byte[] getInfo = crossMineAmryTable.getGetInfo();
            try {
                //矿点驻军信息
                SerializePb.SerCrossMineArmy msg = SerializePb.SerCrossMineArmy.parseFrom(armyInfo);
                List<SerializePb.CrossMineArmy> infoList = msg.getInfoList();
                for (SerializePb.CrossMineArmy crossMineArmy : infoList) {
                    long roleId = crossMineArmy.getRoleId();
                    CrossPlayer player = CrossMineCache.getPlayer(roleId);
                    if (player != null) {
                        CommonPb.Army army = crossMineArmy.getArmy();
                        Army army1 = new Army(army);
                        Guard guard = new Guard(player, army1);
                        seniorMineDataManager.setGuard(guard);
                    }
                }
                //个人积分排名信息
                SerializePb.CrossMinePalyerRankInfo prank = SerializePb.CrossMinePalyerRankInfo.parseFrom(playerRank);
                List<SerializePb.CrossMinePlayerRank> rankList = prank.getRankList();
                for (SerializePb.CrossMinePlayerRank crossMinePlayerRank : rankList) {
                    CrossPlayer player = CrossMineCache.getPlayer(crossMinePlayerRank.getRoleId());
                    if (player != null) {
                        seniorMineDataManager.setScoreRank(player);
                    }
                }
                //服务器排名信息
                SerializePb.CrossMineServerRankInfo srank = SerializePb.CrossMineServerRankInfo.parseFrom(serversRankScore);
                List<SerializePb.CrossMineServerRank> rankList1 = srank.getRankList();
                for (SerializePb.CrossMineServerRank crossMineServerRank : rankList1) {
                    seniorMineDataManager.addServerRank(new SeniorScoreRank(crossMineServerRank));
                }
                if (getInfo != null) {
                    SerializePb.CrossMineGetInfo info = SerializePb.CrossMineGetInfo.parseFrom(getInfo);
                    List<Long> roleIdList = info.getRoleIdList();
                    for (Long aLong : roleIdList) {
                        CrossPlayer player = CrossMineCache.getPlayer(aLong);
                        if (player != null) {
                            seniorMineDataManager.addGetInfo(player);
                        }
                    }
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }

        }


    }

    /**
     * 定时刷新个人基础信息
     */
    public void flushPlayerTable() {
        Map<Long, CrossPlayer> playerMap = CrossMineCache.playerMap;
        for (CrossPlayer player : playerMap.values()) {
            CrossMinePlayerTable table = new CrossMinePlayerTable(player);
            crossMinePlayerTableDao.update(table);
        }
    }

    /**
     * 定时刷新  驻军信息/个人排行信息/服务器总得分信息
     */
    public void flushArmy() {
        CrossMineAmryTable table = new CrossMineAmryTable();
        table.setId(id);
        Map<Integer, List<Guard>> guardMap = seniorMineDataManager.getGuardMap();
        SerializePb.SerCrossMineArmy.Builder msg = SerializePb.SerCrossMineArmy.newBuilder();
        for (Map.Entry<Integer, List<Guard>> integerListEntry : guardMap.entrySet()) {
            SerializePb.CrossMineArmy.Builder builder = SerializePb.CrossMineArmy.newBuilder();
            for (Guard guard : integerListEntry.getValue()) {
                builder.setRoleId(guard.getPlayer().getRoleId());
                builder.setArmy(PbHelper.createArmyPb(guard.getArmy()));
            }
            msg.addInfo(builder);
        }
        table.setArmyInfo(msg.build().toByteArray());

        //个人排行
        LinkedList<SeniorScoreRank> scoreRank = seniorMineDataManager.getScoreRank();
        SerializePb.CrossMinePalyerRankInfo.Builder builder = SerializePb.CrossMinePalyerRankInfo.newBuilder();
        for (SeniorScoreRank seniorScoreRank : scoreRank) {
            builder.addRank(seniorScoreRank.dserPlayerRank());
        }
        table.setPlayerRankInfo(builder.build().toByteArray());

        //服务器排行
        List<SeniorScoreRank> serverScoreRank = seniorMineDataManager.getServerScoreRank();
        SerializePb.CrossMineServerRankInfo.Builder srank = SerializePb.CrossMineServerRankInfo.newBuilder();
        for (SeniorScoreRank seniorScoreRank : serverScoreRank) {
            srank.addRank(seniorScoreRank.dserServerRank());
        }
        table.setServersRankScore(srank.build().toByteArray());

        Set<Long> getInfo = seniorMineDataManager.getGetInfo();
        SerializePb.CrossMineGetInfo.Builder info = SerializePb.CrossMineGetInfo.newBuilder();
        info.addAllRoleId(getInfo);
        table.setGetInfo(info.build().toByteArray());

        CrossMineAmryTable crossMineAmryTable = crossMineArmyTableDao.get(1);
        if (crossMineAmryTable == null) {
            crossMineArmyTableDao.insert(table);
        } else {
            crossMineArmyTableDao.update(table);
        }
    }
}
