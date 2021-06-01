package com.game.manager;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.pb.GamePb2;
import com.game.service.WorldMineService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.alibaba.fastjson.JSONArray;
import com.game.common.ServerSetting;
import com.game.dao.impl.p.DataRepairDao;
import com.game.dao.impl.p.MailDao;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipGuard;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.p.airship.PlayerAirship;
import com.game.domain.p.airship.RecvAirshipProduceAwardRecord;
import com.game.domain.p.repair.InvestNew;
import com.game.domain.p.repair.MailDelt;
import com.game.domain.p.repair.ReissueItem;
import com.game.drill.domain.DrillRank;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.fortressFight.domain.MyFortressFightData;
import com.game.fortressFight.domain.MyPartyStatistics;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.game.rebel.domain.Rebel;
import com.game.server.GameServer;
import com.game.service.CombatService;
import com.game.service.HonourSurviveService;

/**
 * 线上玩家数据修复处理
 *
 * @author zhangdh
 * @ClassName: OnlineDataRepairDataManager
 * @Description:
 * @date 2017-07-03 16:04
 */
@Component
public class DataRepairDM {
    @Autowired
    private DataRepairDao dataRepairDao;

    @Autowired
    private MailDao mailDao;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private ServerSetting serverSetting;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private CombatService combatService;

    @Autowired
    private StaffingDataManager staffingDataManager;
    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    private Map<Long, RedefinedLordId> ids;

    private Map<Long, RedefinedLordId> nIds;

    public void init() {
        ids = dataRepairDao.selectLordIds();
        nIds = new HashMap<>();
        for (Map.Entry<Long, RedefinedLordId> entry : ids.entrySet()) {
            nIds.put(entry.getValue().getNewId(), entry.getValue());
        }
    }

    /**
     * @param newLordId
     * @return long
     * @throws
     * @Title: getOldLordId
     * @Description: 获得旧角色id
     */
    public long getOldLordId(long newLordId) {
        RedefinedLordId rpId = nIds.get(newLordId);
        return rpId != null ? rpId.getOldId() : newLordId;
    }

    /**
     * @param oldLordId
     * @return long
     * @Title: getNewLordId
     * @Description: 通过旧角色id获得新角色id
     */
    public long getNewLordId(long oldLordId) {
        RedefinedLordId rpId = ids.get(oldLordId);
        return rpId != null ? rpId.getNewId() : oldLordId;
    }

    /**
     * @param partyId
     * @return int
     * @Title: getPartyNewId
     * @Description: 服务器id作为军团id前缀
     */
    public int getPartyNewId(int partyId) {
        if (partyId > 0 && partyId < PartyDataManager.MAX_PARTY_ID_FLAG) {
            return serverSetting.getServerID() * PartyDataManager.MAX_PARTY_ID_FLAG + partyId;
        } else {
            return partyId;
        }
    }

    /**
     * @Title: replacePlayerLordId
     * @Description: 把旧lordid换成新的lordid
     * void
     */
    public void replacePlayerLordId() {
        for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
            Player player = entry.getValue();
            if (!player.friends.isEmpty()) {
                //玩家好友列表
                Map<Long, Friend> replaceMap = new HashMap<>();
                for (Map.Entry<Long, Friend> friendEntry : player.friends.entrySet()) {
                    RedefinedLordId rpId = ids.get(friendEntry.getKey());
                    if (rpId != null) {
                        Friend friend = friendEntry.getValue();
                        friend.setLordId(rpId.getNewId());
                        replaceMap.put(friend.getLordId(), friend);
                    } else {
                        replaceMap.put(friendEntry.getKey(), friendEntry.getValue());
                    }
                }
                player.friends.clear();
                player.friends.putAll(replaceMap);

            }

            //好友祝福
            if (!player.blesses.isEmpty()) {
                Map<Long, Bless> replaceMap = new HashMap<>();
                for (Map.Entry<Long, Bless> blessEntry : player.blesses.entrySet()) {
                    RedefinedLordId rpId = ids.get(blessEntry.getKey());
                    if (rpId != null) {
                        Bless bless = blessEntry.getValue();
                        bless.setLordId(rpId.getNewId());
                        replaceMap.put(bless.getLordId(), bless);
                    } else {
                        replaceMap.put(blessEntry.getKey(), blessEntry.getValue());
                    }
                }
                player.blesses.clear();
                player.blesses.putAll(replaceMap);
            }

            //废墟相关
            if (player.ruins.getLordId() != 0) {
                RedefinedLordId rpId = ids.get(player.ruins.getLordId());
                if (rpId != null) {
                    player.ruins.setLordId(rpId.getNewId());
                }
            }

            //收藏相关
            if (!player.coords.isEmpty()) {
                for (Store coord : player.coords) {
                    Man man = coord.getMan();
                    if (man != null && man.getLordId() > 0) {
                        RedefinedLordId rpId = ids.get(man.getLordId());
                        if (rpId != null) {
                            man.setLordId(rpId.getNewId());
                        }
                    }
                }
            }

            //红蓝大战
            if (player.drillFightData != null) {
                long lordId = player.drillFightData.getLordId();
                RedefinedLordId rpId = ids.get(lordId);
                if (rpId != null) {
                    player.drillFightData.setLordId(rpId.getNewId());
                }
            }

            //叛军入侵
            if (player.rebelData != null) {
                long lordId = player.rebelData.getLordId();
                RedefinedLordId rpId = ids.get(lordId);
                if (rpId != null) {
                    player.rebelData.setLordId(rpId.getNewId());
                }
            }

        }
    }

    /**
     * 替换全服活动中的玩家LordId
     */
    public void replaceLordIdInActivity() {
        Map<Integer, UsualActivityData> activityMap = activityDataManager.getActivityMap();
        for (Map.Entry<Integer, UsualActivityData> entry : activityMap.entrySet()) {
            UsualActivityData activity = entry.getValue();
            //军团排名活动
            LinkedList<ActPartyRank> partyRanks = activity.getPartyRanks();
            if (!partyRanks.isEmpty()) {
                for (ActPartyRank partyRank : partyRanks) {
                    List<Long> lordIds = partyRank.getLordIds();
                    replaceLordId(lordIds);
                }
            }

            //玩家排行榜
            Map<Integer, LinkedList<ActPlayerRank>> ranks = activity.getRanks();
            if (!ranks.isEmpty()) {
                for (Map.Entry<Integer, LinkedList<ActPlayerRank>> rankEntry : ranks.entrySet()) {
                    LinkedList<ActPlayerRank> list = rankEntry.getValue();
                    if (!list.isEmpty()) {
                        for (ActPlayerRank rank : list) {
                            long lordId = rank.getLordId();
                            RedefinedLordId rpId = ids.get(lordId);
                            if (rpId != null) {
                                rank.setLordId(rpId.getNewId());
                            }
                        }
                    }
                }
            }

            //活动BOSS
            ActBoss boss = activity.getActBoss();
            if (boss.getLordId() > 0) {
                RedefinedLordId rpId = ids.get(boss.getLordId());
                if (rpId != null) {
                    boss.setLordId(rpId.getNewId());
                }
            }

            if (!boss.getJoinLordIds().isEmpty()) {
                replaceLordId(boss.getJoinLordIds());
            }

            //活动叛军
            ActRebel rebel = activity.getActRebel();
            if (!rebel.getRebelRank().isEmpty()) {
                //活动叛军排名
                for (ActRebelRank actRebelRank : rebel.getRebelRank()) {
                    long lordId = actRebelRank.getLordId();
                    RedefinedLordId rpId = ids.get(lordId);
                    if (rpId != null) {
                        actRebelRank.setLordId(rpId.getNewId());
                        rebel.getRebelRankLordIdMap().remove(lordId);
                        rebel.getRebelRankLordIdMap().put(actRebelRank.getLordId(), actRebelRank);
                    }
                }
            }

        }

    }

    /**
     * 替换军团中的LordId
     */
    public void replaceLordIdInPartyData() {
        for (Map.Entry<Integer, PartyData> entry : partyDataManager.getPartyMap().entrySet()) {
            PartyData partyData = entry.getValue();
            //替换申请加入工会玩家ID
            Map<Long, PartyApply> applys = partyData.getApplys();
            if (!applys.isEmpty()) {
                Map<Long, PartyApply> replaceMap = new HashMap<>();
                for (Map.Entry<Long, PartyApply> applyEntry : applys.entrySet()) {
                    RedefinedLordId rpId = ids.get(applyEntry.getKey());
                    if (rpId != null) {
                        PartyApply data = applyEntry.getValue();
                        data.setLordId(rpId.getNewId());
                        replaceMap.put(rpId.getNewId(), data);
                    } else {
                        replaceMap.put(applyEntry.getKey(), applyEntry.getValue());
                    }
                }
                applys.clear();
                applys.putAll(replaceMap);
            }

            //军团捐赠
            Map<Integer, List<Long>> donates = partyData.getDonates();
            if (!donates.isEmpty()) {
                for (Map.Entry<Integer, List<Long>> donateEntry : donates.entrySet()) {
                    List<Long> list = donateEntry.getValue();
                    replaceLordId(list);
                }
            }

            //祭坛BOSS排名
            List<Long> bossHurtRankList = partyData.getBossHurtRankList();
            replaceLordId(bossHurtRankList);
            //祭坛BOSS领奖信息
            List<Long> bossAwawrdList = partyData.getBossAwardList();
            replaceLordId(bossAwawrdList);

            //飞艇进攻队伍队伍
            Map<Integer, AirshipTeam> teamMap = partyData.getAirshipTeamMap();
            for (Map.Entry<Integer, AirshipTeam> teamEntry : teamMap.entrySet()) {
                AirshipTeam team = teamEntry.getValue();
                team.setLordId(getNewLordId(team.getLordId()));
                List<Long[]> teamIds = team.getArmysDb();
                for (Long[] lordId_key : teamIds) {
                    RedefinedLordId rpId = ids.get(lordId_key[0]);
                    if (rpId != null) {
                        lordId_key[0] = rpId.getNewId();
                    }
                }
            }

            //飞艇驻防队伍
            Map<Integer, AirshipGuard> guardMap = partyData.getAirshipGuardMap();
            for (Map.Entry<Integer, AirshipGuard> guardEntry : guardMap.entrySet()) {
                AirshipGuard guard = guardEntry.getValue();
                List<Long[]> teamIds = guard.getArmysDb();
                for (Long[] lordId_key : teamIds) {
                    RedefinedLordId rpId = ids.get(lordId_key[0]);
                    if (rpId != null) {
                        lordId_key[0] = rpId.getNewId();
                    }
                }
            }

            //飞艇指挥官
            Map<Integer, Long> leaderMap = partyData.getAirshipLeaderMap();
            for (Map.Entry<Integer, Long> leaderEntry : leaderMap.entrySet()) {
                Long lordId = leaderEntry.getValue();
                RedefinedLordId rpId = ids.get(lordId);
                if (rpId != null) {
                    leaderEntry.setValue(rpId.getNewId());
                }
            }

            Map<Integer, Activity> activitys = partyData.getActivitys();
            if (!activitys.isEmpty()) {
                //军团战力活动
                Activity activity_fight = activitys.get(ActivityConst.ACT_RANK_PARTY_FIGHT);
                List<Long> status_fight = activity_fight != null ? activity_fight.getStatusList() : null;
                if (status_fight != null && status_fight.size() > 1) {
                    for (int i = 1; i < status_fight.size(); i++) {
                        Long lordId = status_fight.get(i);
                        RedefinedLordId rpId = ids.get(lordId);
                        if (rpId != null) {
                            status_fight.set(i, rpId.getNewId());
                        }
                    }
                }

                //军团等级活动
                Activity activity_lv = activitys.get(ActivityConst.ACT_RANK_PARTY_LV);
                List<Long> status_lv = activity_lv != null ? activity_lv.getStatusList() : null;
                if (status_lv != null && status_lv.size() > 1) {
                    for (int i = 1; i < status_lv.size(); i++) {
                        Long lordId = status_lv.get(i);
                        RedefinedLordId rpId = ids.get(lordId);
                        if (rpId != null) {
                            status_lv.set(i, rpId.getNewId());
                        }
                    }
                }
            }
        }
    }

    /**
     * 替换Global中的LordId
     */
    public void replaceLordIdInGlobal() {
        //百团混战
        replaceLordId(globalDataManager.gameGlobal.getWinRank());
        replaceLordId(globalDataManager.gameGlobal.getGetWinRank());

        //BOSS战
        replaceLordId(globalDataManager.gameGlobal.getHurtRank());
        replaceLordId(globalDataManager.gameGlobal.getGetHurtRank());

        //军事矿区个人积分排名
        replaceSeniorScoreRankLordId(globalDataManager.gameGlobal.getScoreRank());

        //个人要塞战数据
        replaceMyFortressFightDatas(globalDataManager.gameGlobal.getMyFortressFightDatas());

        //要塞主任命职位信息
        replaceFortressJobAppoint(globalDataManager.gameGlobal.getFortressJobAppointList());

        //玩家要塞战排名
        repalceAllServerFortressFightDataRankLordMap(
                globalDataManager.gameGlobal.getAllServerFortressFightDataRankLordMap());

        //红蓝大战玩家排行榜
        replaceDrillRank(globalDataManager.gameGlobal.getDrillRank());

        //叛军上周玩家排行
        replaceLordId(globalDataManager.gameGlobal.getRebelLastWeekRankList());

        // 已领取上周排行的玩家lordId
        replaceLordId(globalDataManager.gameGlobal.getRebelRewardSet());

        //世界地图矿点信息
        replaceWorldMine(globalDataManager.gameGlobal.getWorldMineInfo());

        //飞艇征收记录
        replaceRecvAirshipProduceAwardRecord(globalDataManager.gameGlobal.getAirshipMap());

        //玩家飞艇信息
        replacePlayerAirship(globalDataManager.gameGlobal.getPlayerAirshipMap());
    }

    /**
     * 替换
     *
     * @param playerAirshipMap
     */
    private void replacePlayerAirship(Map<Long, PlayerAirship> playerAirshipMap) {
        if (!playerAirshipMap.isEmpty()) {
            Map<Long, PlayerAirship> replaceMap = new HashMap<>();
            for (Map.Entry<Long, PlayerAirship> entry : playerAirshipMap.entrySet()) {
                RedefinedLordId rpId = ids.get(entry.getKey());
                replaceMap.put(rpId != null ? rpId.getNewId() : entry.getKey(), entry.getValue());
            }
            playerAirshipMap.clear();
            playerAirshipMap.putAll(replaceMap);
        }
    }

    private void replaceRecvAirshipProduceAwardRecord(Map<Integer, Airship> airshipMap) {
        for (Map.Entry<Integer, Airship> entry : airshipMap.entrySet()) {
            Airship airship = entry.getValue();
            List<RecvAirshipProduceAwardRecord> list = airship.getRecvRecordList();
            if (list != null && !list.isEmpty()) {
                for (RecvAirshipProduceAwardRecord record : list) {
                    record.setLordId(getNewLordId(record.getLordId()));
                }
            }
        }
    }

    private void replaceWorldMine(Map<Integer, Mine> mineMap) {
        for (Map.Entry<Integer, Mine> entry : mineMap.entrySet()) {
            Mine mine = entry.getValue();
            if (!mine.getScoutMap().isEmpty()) {
                Map<Long, Integer> replaceMap = new HashMap<>();
                for (Map.Entry<Long, Integer> scoutMapEntry : mine.getScoutMap().entrySet()) {
                    RedefinedLordId rpId = ids.get(scoutMapEntry.getKey());
                    replaceMap.put(rpId != null ? rpId.getNewId() : entry.getKey(), scoutMapEntry.getValue());
                }
                mine.getScoutMap().clear();
                mine.getScoutMap().putAll(replaceMap);
            }
        }
    }

    private void replaceDrillRank(Map<Integer, LinkedHashMap<Long, DrillRank>> drillRank) {
        if (!drillRank.isEmpty()) {
            for (Map.Entry<Integer, LinkedHashMap<Long, DrillRank>> entry : drillRank.entrySet()) {
                LinkedHashMap<Long, DrillRank> rankMap = entry.getValue();
                if (!rankMap.isEmpty()) {
                    LinkedHashMap<Long, DrillRank> replaceMap = new LinkedHashMap<>();
                    for (Map.Entry<Long, DrillRank> rankEntry : rankMap.entrySet()) {
                        RedefinedLordId rpId = ids.get(rankEntry.getKey());
                        if (rpId != null) {
                            DrillRank data = rankEntry.getValue();
                            data.setLordId(rpId.getNewId());
                            replaceMap.put(data.getLordId(), data);
                        } else {
                            replaceMap.put(rankEntry.getKey(), rankEntry.getValue());
                        }
                    }
                    rankMap.clear();
                    rankMap.putAll(replaceMap);
                }
            }
        }
    }

    private void repalceAllServerFortressFightDataRankLordMap(LinkedHashMap<Long, MyFortressFightData> dataMap) {
        if (!dataMap.isEmpty()) {
            LinkedHashMap<Long, MyFortressFightData> dataMap0 = new LinkedHashMap<>();
            for (Map.Entry<Long, MyFortressFightData> entry : dataMap.entrySet()) {
                RedefinedLordId rpId = ids.get(entry.getKey());
                if (rpId != null) {
                    MyFortressFightData data = entry.getValue();
                    data.setLordId(rpId.getNewId());
                    dataMap0.put(data.getLordId(), data);
                } else {
                    dataMap0.put(entry.getKey(), entry.getValue());
                }
            }
            dataMap.clear();
            dataMap.putAll(dataMap0);
        }
    }

    private void replaceFortressJobAppoint(List<FortressJobAppoint> list) {
        if (!list.isEmpty()) {
            for (FortressJobAppoint appoint : list) {
                long lordId = appoint.getLordId();
                RedefinedLordId rpId = ids.get(lordId);
                if (rpId != null) {
                    appoint.setLordId(rpId.getNewId());
                }
            }
        }
    }

    private void replaceMyFortressFightDatas(Map<Long, MyFortressFightData> dataMap) {
        Map<Long, MyFortressFightData> replaceMap = new HashMap<>();
        for (Map.Entry<Long, MyFortressFightData> entry : dataMap.entrySet()) {
            MyFortressFightData data = entry.getValue();
            RedefinedLordId rpId = ids.get(entry.getKey());
            if (rpId != null) {
                data.setLordId(rpId.getNewId());
                replaceMap.put(rpId.getNewId(), data);
            } else {
                replaceMap.put(entry.getKey(), entry.getValue());
            }
        }
        dataMap.clear();
        dataMap.putAll(replaceMap);
    }

    private void replaceSeniorScoreRankLordId(List<SeniorScoreRank> list) {
        for (SeniorScoreRank rank : list) {
            RedefinedLordId rpId = ids.get(rank.getLordId());
            if (rpId != null) {
                rank.setLordId(rpId.getNewId());
            }
        }
    }

    /**
     * 替换一组LordId
     *
     * @param lordIds
     */
    private void replaceLordId(Collection<Long> lordIds) {
        if (lordIds != null && !lordIds.isEmpty()) {
            List<Long> replaceList = new ArrayList<>();
            for (Long lordId : lordIds) {
                RedefinedLordId rpId = ids.get(lordId);
                replaceList.add(rpId != null ? rpId.getNewId() : lordId);
            }
            lordIds.clear();
            lordIds.addAll(replaceList);
        }
    }

    /**
     * 替换活动中的军团ID
     */
    public void reaplcePartyIdInActivity() {
        Map<Integer, UsualActivityData> activityMap = activityDataManager.getActivityMap();
        for (Map.Entry<Integer, UsualActivityData> entry : activityMap.entrySet()) {
            UsualActivityData activity = entry.getValue();
            //军团排行榜活动
            for (ActPartyRank actPartyRank : activity.getPartyRanks()) {
                actPartyRank.setPartyId(getPartyNewId(actPartyRank.getPartyId()));
            }

            //军团排名
            Map<Integer, Long> partyRanks = activity.getPartyRankMap();
            if (!partyRanks.isEmpty()) {
                Map<Integer, Long> replaceMap = new HashMap<>();
                for (Map.Entry<Integer, Long> rankEntry : partyRanks.entrySet()) {
                    replaceMap.put(getPartyNewId(rankEntry.getKey()), rankEntry.getValue());
                }
                partyRanks.clear();
                partyRanks.putAll(replaceMap);
            }
        }
    }

    /**
     * 替换Global中的军团ID
     */
    public void replacePartyInGlobal() {
        //军事矿区军团排名
        replaceSeniorPartyScoreRank(globalDataManager.gameGlobal.getScorePartyRank());

        //记录本周军团战排名数据 time,rank,WarRankInfo
        replaceWarRankRecords(globalDataManager.gameGlobal.getWarRankRecords());

        //能参加要塞战的军团
        replaceCanFightFortressPartyMap(globalDataManager.gameGlobal.getCanFightFortressPartyMap());

        //统计要塞战军团数据(军团id, 统计,积分排行)
        replacePartyStatisticsMap(globalDataManager.gameGlobal.getPartyStatisticsMap());

        //飞艇所属军团
        replaceAirshipParty(globalDataManager.gameGlobal.getAirshipMap());

        int fortressPartyId = globalDataManager.gameGlobal.getFortressPartyId();
        if (fortressPartyId > 0) {
            globalDataManager.gameGlobal.setFortressPartyId(getPartyNewId(fortressPartyId));
        }

        //替换玩家申请的军团ID |10000592|10000342|10000600|10000154|
        for (Map.Entry<Long, Member> entry : partyDataManager.getMemberMap().entrySet()) {
            Member member = entry.getValue();
            String applyList = member.getApplyList();
            if (applyList != null && !"|".equals(applyList)) {
                String[] applyIds = applyList.split("\\|");
                if (applyIds.length > 0) {
                    String apSb = "|";
                    for (String apId : applyIds) {
                        if (null != apId && !"".equals(apId)) {
                            int nApId = getPartyNewId(Integer.valueOf(apId));
                            apSb += nApId + "|";
                        }
                    }
                }
            }
        }
    }

    private void replaceAirshipParty(Map<Integer, Airship> airshipMap) {
        for (Map.Entry<Integer, Airship> entry : airshipMap.entrySet()) {
            Airship airship = entry.getValue();
            if (airship.getPartyId() > 0) {
                airship.setPartyId(getPartyNewId(airship.getPartyId()));
            }
        }
    }

    private void replacePartyStatisticsMap(LinkedHashMap<Integer, MyPartyStatistics> partyStatisticsMap) {
        LinkedHashMap<Integer, MyPartyStatistics> replaceMap = new LinkedHashMap<>();
        for (Map.Entry<Integer, MyPartyStatistics> entry : partyStatisticsMap.entrySet()) {
            int partyId = getPartyNewId(entry.getKey());
            MyPartyStatistics v = entry.getValue();
            v.setPartyId(partyId);
            replaceMap.put(partyId, v);
        }
        partyStatisticsMap.clear();
        partyStatisticsMap.putAll(replaceMap);
    }

    private void replaceCanFightFortressPartyMap(LinkedHashMap<Integer, FortressBattleParty> canFightFortressPartyMap) {
        LinkedHashMap<Integer, FortressBattleParty> replaceMap = new LinkedHashMap<>();
        for (Map.Entry<Integer, FortressBattleParty> entry : canFightFortressPartyMap.entrySet()) {
            int partyId = getPartyNewId(entry.getKey());
            FortressBattleParty v = entry.getValue();
            v.setPartyId(partyId);
            replaceMap.put(partyId, v);
        }
        canFightFortressPartyMap.clear();
        canFightFortressPartyMap.putAll(replaceMap);
    }

    private void replaceWarRankRecords(Map<Integer, Map<Integer, WarRankInfo>> warRankRecords) {
        for (Map.Entry<Integer, Map<Integer, WarRankInfo>> entry : warRankRecords.entrySet()) {
            for (Map.Entry<Integer, WarRankInfo> infoEntry : entry.getValue().entrySet()) {
                WarRankInfo rank = infoEntry.getValue();
                rank.setPartyId(getPartyNewId(rank.getPartyId()));
            }
        }
    }

    private void replaceSeniorPartyScoreRank(LinkedList<SeniorPartyScoreRank> seniorPartyScoreRanks) {
        for (SeniorPartyScoreRank rank : seniorPartyScoreRanks) {
            rank.setPartyId(getPartyNewId(rank.getPartyId()));
        }
    }

    //飞艇进攻队伍LordIds在军团中处理
    //    private void replaceAirship(Map<Integer, Airship> airshipMap){
    //        for (Map.Entry<Integer, Airship> entry : airshipMap.entrySet()) {
    //            Airship airship = entry.getValue();
    //            List<AirshipTeam> teamList = airship.getTeamArmy();
    //            for (AirshipTeam airshipTeam : teamList) {
    //
    //            }
    //        }
    //    }

    public void repairInvestNew() {
        int finalBeginTime = 20151117;
        List<InvestNew> list = dataRepairDao.selectInvestNew();
        String title = "7月27日18时活动异常补偿";
        String mail_content = "尊敬的指挥官：核实您在7月27日18时维护后部分玩家“成长基金”出现购买异常，应扣除异常购买领取的金币*%d。附件为您重复投资的金币*500。如附件。请注意查收！若有疑问请联系客服反馈，谢谢您的配合！";
        //        String awardsStr = "[[16,1,500],[5,393,2],[5,394,2],[5,246,16],[5,118,2],[5,356,4],[5,210,32],[5,211,32],[5,58,24]]";
        String awardsStr = "[[16,1,500]]";
        List<List<Integer>> lst = getListList(awardsStr);
        String[] awardsArr = awardsStr.split(",");
        List<CommonPb.Award> pbAwards = new ArrayList<>(9);
        for (List<Integer> item : lst) {
            pbAwards.add(PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2)));
        }
        int nowSec = TimeHelper.getCurrentSecond();
        for (InvestNew ivn : list) {
            //已经扣除过了
            if (ivn.getFlag() > 0 || ivn.getNeedSub() == 0)
                continue;
            Player player = playerDataManager.getPlayer(ivn.getLordId());
            if (player != null && player.lord.getNick() != null) {
                if (player.lord.getNick().equals(ivn.getNick())) {
                    Activity activity = player.activitys.get(ActivityConst.ACT_INVEST_NEW);
                    if (activity == null || activity.getBeginTime() != finalBeginTime) {
                        int beginTime = activity != null ? activity.getBeginTime() : 0;
                        LogUtil.common(
                                String.format("nick :%s, activity id :%d, begin time :%d, not 20151117", ivn.getNick(),
                                        ActivityConst.ACT_INVEST_NEW, beginTime));
                    }
                    subInvestNewGold(player, ivn, title, mail_content, pbAwards, nowSec);
                }
            }
        }

        //修复玩家活动数据
        repaireActivityBeginTime(finalBeginTime);
    }

    private void subInvestNewGold(Player player, InvestNew ivn, String title, String mail_content,
                                  List<CommonPb.Award> pbAwards, int nowSec) {
        try {
            Lord lord = player.lord;
            int sub = Math.min(lord.getGold(), ivn.getNeedSub());
            if (sub == 0) {//玩家身上金币为0
                LogUtil.common(
                        String.format("nick :%s, need sub gold :%d, but has gold :%d ", ivn.getNick(), ivn.getNeedSub(),
                                lord.getGold()));
            }
            lord.setGold(lord.getGold() - sub);

            //记录处理信息
            ivn.setAlreadySub(sub);
            ivn.setRemain(lord.getGold());
            ivn.setFlag(1);
            dataRepairDao.updateInvestNew(ivn);
            LogLordHelper.gold(AwardFrom.ONLINE_DATA_REPAIR_INVEST_NEW, player.account, lord, -sub, 0);
            //发送补偿邮件
            String content = String.format(mail_content, ivn.getNeedSub());
            playerDataManager
                    .sendAttachMail(AwardFrom.ONLINE_DATA_REPAIR, player, pbAwards, MailType.MOLD_GM_2, nowSec, title,
                            content);
        } catch (Exception e) {
            LogUtil.error(String.format("hand nick :%s, error ivn :%s", ivn.getNick(), ivn.toString()), e);
        }
    }

    /**
     * 将玩家参与的VIP礼包购买与成长基金活动参与时间设置为1服的开服时间(20151117)
     * 避免玩家在合服后这2个活动因为参与时间重置
     *
     * @param finalBeginTime 1服的开服时间
     */
    private void repaireActivityBeginTime(int finalBeginTime) {
        for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
            Player player = entry.getValue();
            try {
                //成长基金
                Activity activity_invest_new = player.activitys.get(ActivityConst.ACT_INVEST_NEW);
                if (activity_invest_new != null) {
                    int oldBeginTime = activity_invest_new.getBeginTime();
                    if (oldBeginTime != finalBeginTime) {
                        activity_invest_new.setBeginTime(finalBeginTime);
                        LogUtil.common(
                                String.format("nick :%s, activity id :%d, old begin time is :%d, set to begin time :%d",
                                        player.lord.getNick(), ActivityConst.ACT_INVEST_NEW, oldBeginTime,
                                        finalBeginTime));
                    } else {
                        LogUtil.common(
                                String.format("nick :%s, activity id :%d, old begin time is :%d", player.lord.getNick(),
                                        ActivityConst.ACT_INVEST_NEW, oldBeginTime));
                    }
                } else {
                    LogUtil.common(String.format("nick :%s, activity id :%d, not found", player.lord.getNick(),
                            ActivityConst.ACT_INVEST_NEW));
                }

                //VIP礼包

                Activity activity_vip_gift = player.activitys.get(ActivityConst.ACT_VIP_GIFT);
                if (activity_vip_gift != null && activity_vip_gift.getBeginTime() != finalBeginTime) {
                    activity_vip_gift.setBeginTime(finalBeginTime);
                } else {
                    if (activity_vip_gift == null) {
                        LogUtil.common(String.format("nick :%s, activity id :%d, not found", player.lord.getNick(),
                                ActivityConst.ACT_VIP_GIFT));
                    }
                }
            } catch (Exception e) {
                LogUtil.error(String.format("nick :%s, repaire activity begin time err", player.lord.getNick()), e);
            }
        }
    }

    public void repaireReissueItem() {
        List<ReissueItem> list = dataRepairDao.selectReissueItem();
        int nowSec = TimeHelper.getCurrentSecond();
        String title = "活动显示异常补发";
        //        String content_base = "尊敬的指挥官：由于7月2日“装甲风暴”活动显示异常，期间用金币参与的该活动获得: %s，%s已扣除，活动内消耗的%d金币已全额返还，如附件。请注意查收！";
        String content_base = "由于7月2日活动“装甲风暴”显示异常，期间应该扣除: %s %s 已返还该活动内消耗：%d金币。如附件，请注意查收！";
        for (ReissueItem rsi : list) {
            if (rsi.getBackGold() > 0 || rsi.getGold() == 0)
                continue;//已经补偿过了,或者没有金币消耗
            Player player = playerDataManager.getPlayer(rsi.getLordId());
            if (player != null) {
                if (player.lord.getNick().equals(rsi.getNick())) {
                    //玩家服务器错误
                    if (player.account.getServerId() != rsi.getServerId()) {
                        LogUtil.error(String.format(
                                "rsiErrSid, lordId :%d, nick :%s, serverId :%d, rsi serverId :%d, server setting serverId :%d",
                                rsi.getLordId(), rsi.getNick(), player.account.getServerId(), rsi.getServerId(),
                                serverSetting.getServerID()));
                        continue;
                    }

                    //补偿金币错误
                    if (rsi.getGold() > 0) {
                        LogUtil.error(String.format("rsiErrGold, serverId :%d, lord id :%d, nick :%s, gold :%d",
                                rsi.getServerId(), rsi.getLordId(), rsi.getNick(), rsi.getGold()));
                        continue;
                    }

                    //玩家处理
                    repaireReissueItem(player, rsi, nowSec, title, content_base);
                }
            }
        }
    }

    private void repaireReissueItem(Player player, ReissueItem rsi, int nowSec, String title, String content) {
        try {
            //检测坦克 id 为25 的数量是否足够
            Tank tk25 = player.tanks.get(25);
            int cnt25 = tk25 != null ? tk25.getCount() : 0;
            //            if (rsi.getTank25() > 0 && cnt25 < rsi.getTank25()) {
            //                int rst25 = tk25 != null ? tk25.getRest() : 0;
            //                LogUtil.error(String.format("rsiErr25, serverId :%d, lord id :%d, nick :%s, need cnt :%d, tank_25 cnt:%d, rst cnt :%d",
            //                        rsi.getServerId(), rsi.getLordId(), rsi.getNick(), rsi.getTank25(), cnt25, rst25));
            //                return;
            //            }

            //检测坦克 id 为99 的数量是否足够
            Tank tk99 = player.tanks.get(99);
            int cnt99 = tk99 != null ? tk99.getCount() : 0;
            //            if (rsi.getTank99() > 0 && cnt99 < rsi.getTank99()) {
            //                int rst99 = tk99 != null ? tk99.getRest() : 0;
            //                LogUtil.error(String.format("rsiErr99, serverId :%d, lord id :%d, nick :%s, need cnt :%d, tank_99 cnt:%d, rst cnt :%d",
            //                        rsi.getServerId(), rsi.getLordId(), rsi.getNick(), rsi.getTank99(), cnt99, rst99));
            //                return;
            //            }

            //检测道具 id 为99 的数量是否足够
            Prop prop = player.props.get(200);
            int cnt200 = prop != null ? prop.getCount() : 0;
            //            if (rsi.getProp200() > 0 && cnt200 < rsi.getProp200()) {
            //                LogUtil.error(String.format("rsiErr200, serverId :%d, lord id :%d, nick :%s, need cnt :%d, prop_200 cnt :%d",
            //                        rsi.getServerId(), rsi.getLordId(), rsi.getNick(), rsi.getProp200(), cnt200));
            //                return;
            //            }

            StringBuilder tkSb = new StringBuilder("");

            if (rsi.getTank25() > 0) {
                StaticTank staticTank = staticTankDataMgr.getStaticTank(25);
                tkSb.append(staticTank.getName()).append(" *").append(rsi.getTank25()).append("、 ");
                if (cnt25 > 0) {
                    playerDataManager
                            .subTank(player, tk25, Math.min(rsi.getTank25(), cnt25), AwardFrom.ONLINE_DATA_REPAIR);
                }
            }
            if (rsi.getTank99() > 0) {
                StaticTank staticTank = staticTankDataMgr.getStaticTank(99);
                tkSb.append(staticTank.getName()).append(" *").append(rsi.getTank99()).append("、 ");
                if (cnt99 > 0) {
                    playerDataManager
                            .subTank(player, tk99, Math.min(rsi.getTank99(), cnt99), AwardFrom.ONLINE_DATA_REPAIR);
                }
            }

            if (tkSb.length() > 0) {
                tkSb.delete(tkSb.length() - 2, tkSb.length());
            }

            StringBuilder propSb = new StringBuilder("");
            if (rsi.getProp200() > 0) {
                if (tkSb.length() > 0) {
                    tkSb.append("， ");
                }
                StaticProp staticProp = staticPropDataMgr.getStaticProp(200);
                propSb.append(staticProp.getPropName()).append(" *").append(rsi.getProp200()).append("， ");
                if (cnt200 > 0) {
                    playerDataManager
                            .subProp(player, prop, Math.min(rsi.getProp200(), cnt200), AwardFrom.ONLINE_DATA_REPAIR);
                }
            }

            String mail_content = String.format(content, tkSb.toString(), propSb.toString(), Math.abs(rsi.getGold()));
            if (rsi.getGold() < 0) {
                CommonPb.Award award = PbHelper.createAwardPb(AwardType.GOLD, 1, Math.abs(rsi.getGold()));
                List<CommonPb.Award> awards = new ArrayList<>();
                awards.add(award);

                rsi.setBackGold(Math.abs(rsi.getGold()));
                dataRepairDao.updateReissueItem(rsi);

                playerDataManager
                        .sendAttachMail(AwardFrom.ONLINE_DATA_REPAIR, player, awards, MailType.MOLD_GM_2, nowSec, title,
                                mail_content);

            }
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error(String.format("rsiErrUnknow, serverId :%d, lordId :%d, nick :%s", rsi.getServerId(),
                    rsi.getLordId(), rsi.getNick()), e);
        }
    }

    /**
     * 预埋的热更线上BUG处理方法
     */
    public void executeHotfix() {
        try {
            LogUtil.hotfix("start execute hotfix logic....");
            logicExc();
            LogUtil.hotfix("execute hotfix logic finish....");
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

    public void logicExc() {

        Map<Long, Player> players = playerDataManager.getPlayers();
        Map<Long, Player> recThreeMonOnlPlayer = playerDataManager.getRecThreeMonOnlPlayer();
        for (Player player : players.values()) {
            if (!recThreeMonOnlPlayer.containsKey(player.roleId)) {
                player.effects.remove(EffectType.ATTACK_FREE);
            }
        }
    }

    /**
     * 解決飛艇找不到 leader的問題
     */
    public void flushAirShip() {
        Map<Integer, Airship> airshipMap = GameServer.ac.getBean(AirshipDataManager.class).getAirshipMap();
        if (airshipMap != null) {
            for (Airship airship : airshipMap.values()) {
                PartyData partyData = airship.getPartyData();
                if (partyData != null) {
                    Long aLong = partyData.getAirshipLeaderMap().get(airship.getId());
                    if (aLong == null) {
                        StaticAirship staticAirship = GameServer.ac.getBean(StaticWorldDataMgr.class).getAirshipMap().get(airship.getId());
                        GameServer.ac.getBean(AirshipDataManager.class).clearAirshipData2Npc(staticAirship, airship);
                    }
                }
            }
        }
    }

    /**
     * 修复玩家基地坐标和玩家重复问题
     */
    public void repaireWorldMapPlayerPostionError() {
        try {
            LogUtil.hotfix("开始修复荣耀生存结束状态BUG....");

            HonourDataManager honourDataManager = GameServer.ac.getBean(HonourDataManager.class);
            HonourSurviveService honourSurviveService = GameServer.ac.getBean(HonourSurviveService.class);
            if (!honourDataManager.isNotifyClose()) {
                LogUtil.hotfix("HonourSurvive Error | ServerId : " + GameServer.ac.getBean(ServerSetting.class).getServerID());
                for (Player player : playerDataManager.getPlayers().values()) {
                    try {
                        if (honourDataManager.isOpen() && player.honourNotify == false) {
                            honourSurviveService.notifyOpenOrClose(player, 2);
                        }
                    } catch (Exception e) {
                        LogUtil.error("荣耀生存通知玩家活动结束报错 | roleId : " + player.lord.getLordId(), e);
                    }
                }
                honourDataManager.setNotifyClose(true);
                honourDataManager.endClear();
            }
            LogUtil.hotfix("结束修复荣耀生存结束状态BUG....");
        } catch (Exception e) {
            LogUtil.error("修复荣耀生存结束状态报错", e);
        }
    }


    /**
     * 修复玩家部队占领的矿点超出世界地图的范围BUG
     */
    public void repaireWorldMapPlayerPostionErrorBack() {
        try {
            LogUtil.hotfix("start execute hotfix logic....");
            int now = TimeHelper.getCurrentSecond();
            Map<Long, Player> players = playerDataManager.getPlayers();
            WorldDataManager worldDataManager = GameServer.ac.getBean(WorldDataManager.class);
            StaticWorldDataMgr staticWorldDataMgr = GameServer.ac.getBean(StaticWorldDataMgr.class);
            WorldMineService mineService = GameServer.ac.getBean(WorldMineService.class);
            //军事矿区
            SeniorMineDataManager seniorMineDataManager = GameServer.ac.getBean(SeniorMineDataManager.class);

            for (Map.Entry<Long, Player> entry : players.entrySet()) {
                Player player = entry.getValue();
                if (!player.armys.isEmpty()) {
                    for (Army army : player.armys) {
                        Tuple<Integer, Integer> turple = MapHelper.reducePos(army.getTarget());
                        if (turple.getA() > 600 || turple.getB() > 600) {
                            GamePb2.RetreatRs.Builder builder = GamePb2.RetreatRs.newBuilder();
                            int state = army.getState();
                            if (state == ArmyState.RETREAT || state == ArmyState.MARCH) {
                                continue;
                            }
                            if (state == ArmyState.COLLECT) {
                                LogUtil.hotfix(String.format("玩家 %s, x :%d, y :%d, 部队信息 :%s", player.lord.getNick(),
                                        turple.getA(), turple.getB(), army.toString()));
                                if (!army.getSenior()) {
                                    StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
                                    if (staticMine != null) {
                                        int produnction = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel())
                                                .getProduction();
                                        produnction = mineService.getMineProdunction(army.getTarget(), produnction);
                                        long get = playerDataManager
                                                .calcCollect(player, army, now, staticMine, produnction);
                                        Grab grab = new Grab();
                                        grab.rs[staticMine.getType() - 1] = get;
                                        army.setGrab(grab);

                                        worldDataManager.removeGuard(player, army);
                                        //增加矿点品质经验
                                        mineService.addMineQualityExp(player, army.getTarget(), staticMine.getLv() + staffingDataManager.getWorldMineLevel(),
                                                now - (army.getEndTime() - army.getPeriod()));
                                        //撤回部队
                                        army.setState(ArmyState.RETREAT);
                                        army.setPeriod(0);
                                        army.setEndTime(now);
                                    } else {
                                        // handler.sendErrorMsgToPlayer(GameError.IN_MARCH);
                                        // return;
                                        worldDataManager.removeGuard(player, army);
                                        //撤回部队
                                        army.setState(ArmyState.RETREAT);
                                        army.setPeriod(0);
                                        army.setEndTime(now);
                                    }
                                } else {
                                    StaticMine staticMine = seniorMineDataManager.evaluatePos(army.getTarget());
                                    if (staticMine != null) {
                                        long get = playerDataManager.calcCollect(player, army, now, staticMine,
                                                staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getProduction());
                                        Grab grab = new Grab();
                                        grab.rs[staticMine.getType() - 1] = get;
                                        army.setGrab(grab);

                                        seniorMineDataManager.removeGuard(player, army);
                                        playerDataManager.retreatEnd(player, army);
                                        player.armys.remove(army);
                                    } else {
                                        seniorMineDataManager.removeGuard(player, army);
                                        playerDataManager.retreatEnd(player, army);
                                        player.armys.remove(army);
                                    }
                                }
                                if (player.ctx != null) {
                                    player.ctx.close();
                                }
                            }
                        }
                    }
                }
            }
            LogUtil.hotfix("execute hotfix logic finish....");
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

    /**
     * 修复玩家基地与矿点坐标重复
     */
    public void repaireMineRepeat() {
        WorldDataManager worldDataManager = GameServer.ac.getBean(WorldDataManager.class);
        Map<Long, Player> players = playerDataManager.getPlayers();
        for (Map.Entry<Long, Player> entry : players.entrySet()) {
            Player player = entry.getValue();
            Lord lord = player.lord;
            int oldPos = lord.getPos();
            StaticMine staticMine = worldDataManager.evaluatePos(oldPos);
            if (staticMine != null) {
                LogUtil.hotfix(String.format("lord Id :%d, nick :%s, pos :%d, has mine... mine type :%d, mine lv :%d",
                        lord.getLordId(), lord.getNick(), oldPos, staticMine.getType(), staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

                RebelDataManager rebelDataManager = GameServer.ac.getBean(RebelDataManager.class);
                Tuple<Integer, Integer> turple = WorldDataManager.reducePos(oldPos);
                int x = turple.getA() + 100;
                int y = turple.getB() + 100;
                Loop:
                for (int i = turple.getA(); i < x; i++) {
                    for (int j = turple.getB(); j < y; j++) {
                        int newPos = WorldDataManager.pos(i, j);
                        if (!worldDataManager.isValidPos(newPos)) {
                            continue;
                        }

                        Player target = worldDataManager.getPosData(newPos);
                        if (target != null) {
                            continue;
                        }

                        StaticMine staticMineTemp = worldDataManager.evaluatePos(newPos);
                        if (staticMineTemp != null) {
                            continue;
                        }

                        // 检查是否被叛军占据

                        Rebel rebel = rebelDataManager.getRebelByPos(newPos);
                        if (rebel != null && rebelDataManager.isRebelStart()) {
                            continue;
                        }

                        //活动叛军
                        ActRebelData actRebelData = activityDataManager.getActRebelByPos(newPos);
                        if (actRebelData != null) {
                            continue;
                        }

                        if (worldDataManager.isAirship(newPos)) {
                            continue;
                        }

                        //                            //行军中的玩家,修改目的地
                        //                            List<March> marchList = worldDataManager.getMarch(oldPos);
                        //                            if (marchList != null) {
                        //                                for (March march : marchList) {
                        //                                    march.getArmy().setTarget(newPos);
                        //                                    worldDataManager.addMarch(march);
                        //
                        //                                    Player marchPlayer = march.getPlayer();
                        //                                    if (marchPlayer != null) {
                        //                                        LogUtil.hotfix(String.format("lordId :%d, nick :%s, march target oldPos :%d, newPos :%d",
                        //                                                marchPlayer.lord.getLordId(), marchPlayer.lord.getNick(), oldPos, newPos));
                        //                                    }
                        //                                }
                        //                            }

                        List<Guard> list = worldDataManager.getGuard(oldPos);
                        if (list != null) {
                            for (int k = 0; k < list.size(); k++) {
                                Guard guard = list.get(k);
                                guard.getArmy().setTarget(newPos);
                                worldDataManager.setGuard(guard);
                            }
                        }

                        worldDataManager.removeGuard(oldPos);
                        worldDataManager.removePosPlayer(oldPos);

                        player.lord.setPos(newPos);
                        worldDataManager.putPlayer(player);
                        LogUtil.hotfix(String.format("lordId :%d, nick :%s, lv :%d, oldPos :%d, ---> newPos :%d",
                                lord.getLordId(), lord.getNick(), lord.getLevel(), oldPos, newPos));
                        if (player.ctx != null) {
                            player.ctx.close();
                        }
                        break Loop;
                    }
                }
            }
        }
    }

    /**
     * 删除配件ID为66的配件，因为此配件不存在
     */
    public void repairePart66() {
        for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
            Player player = entry.getValue();
            for (Map.Entry<Integer, Map<Integer, Part>> partMapEntry : player.parts.entrySet()) {
                Set<Integer> deltSet = new HashSet<>();
                for (Map.Entry<Integer, Part> partEntry : partMapEntry.getValue().entrySet()) {
                    if (partEntry.getValue().getPartId() == 66) {
                        deltSet.add(partEntry.getKey());
                    }
                }

                if (!deltSet.isEmpty()) {
                    for (Integer deltId : deltSet) {
                        Part part = partMapEntry.getValue().remove(deltId);
                        LogUtil.common(String.format("lordId :%d, part info :%s ", player.lord.getLordId(), part));

                    }
                }

            }
        }
    }

    /**
     * 将扫荡奖励合并
     */
    private void repaireMailAward() {
        for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
            Map<Integer, Mail> mails = entry.getValue().getMails();
            for (Map.Entry<Integer, Mail> mailEntry : mails.entrySet()) {
                Mail mail = mailEntry.getValue();
                if (mail.getMoldId() == MailType.MOLD_WIPE) {
                    if (mail.getAward() != null && !mail.getAward().isEmpty()) {
                        mail.setAward(combatService.repeateAwardHand(entry.getValue(), mail.getAward()));
                        entry.getValue().updMailState(mail, mail.getState());
                    }
                }
            }
        }
    }

    public void repaireMail() {
        try {
            LogUtil.start("开始修复玩家邮件数据.......");
            //201710/19 - 2017/10/26 之间删除的邮件列表
            List<MailDelt> deltList = dataRepairDao.selectMailDelt(serverSetting.getServerID());
            //KEY0:玩家ID(老ID), KEY1邮件ID, 删除时间
            Map<Long, HashMap<Integer, Date>> deltMail = new HashMap<>();
            for (MailDelt delt : deltList) {
                long newLordId = getNewLordId(delt.getLordId());
                HashMap<Integer, Date> lordMap = deltMail.get(newLordId);
                if (lordMap == null)
                    deltMail.put(newLordId, lordMap = new HashMap<Integer, Date>());
                lordMap.put(delt.getGetKeyId(), delt.getCreateDate());
            }
            LogUtil.start("已经删除的邮件记录 : " + deltList.size());

            //历史邮件列表
            List<DataNew> mailList = dataRepairDao.loadDataBak();
            for (DataNew dataNew : mailList) {
                long startMill = System.currentTimeMillis();
                byte[] byteMail = dataNew.getMail();
                long newLordId = getNewLordId(dataNew.getLordId());
                if (newLordId > 0) {
                    dserMail(newLordId, byteMail, deltMail);
                    long endMill = System.currentTimeMillis();
                    LogUtil.common(
                            String.format("repaire lordId :%d, cost sec :%d", newLordId, (endMill - startMill) / 1000));
                }
            }
            LogUtil.start("修复玩家邮件数据结束.......");
        } catch (Exception e) {
            LogUtil.error("", e);
        }

        LogUtil.start("处理扫荡邮件奖励合并重复项， 开始  ");
        repaireMailAward();
        LogUtil.start("扫荡邮件奖励合并重复项， 结束");
    }

    /**
     * 解析邮件
     *
     * @param lordId   新角色ID
     * @param data     角色的邮件数据
     * @param deltMail KEY:新角色ID,VALUE
     */
    private void dserMail(long lordId, byte[] data, Map<Long, HashMap<Integer, Date>> deltMail) {
        if (data == null || lordId == 0) {
            return;
        }
        int keyId = 0;
        try {
            SerializePb.SerMail serMail = SerializePb.SerMail.parseFrom(data);
            List<CommonPb.Mail> list = serMail.getMailList();
            for (CommonPb.Mail e : list) {
                keyId = e.getKeyId();
                HashMap<Integer, Date> lordDelt = deltMail.get(lordId);
                Date date = lordDelt != null ? lordDelt.get(keyId) : null;
                if (date != null) {
                    LogUtil.common(String.format("lordId :%d, mail keyId :%d, is delte on time :%s ", lordId, keyId,
                            DateHelper.formatDateMiniTime(date)));
                    continue;
                }

                Player player = playerDataManager.getPlayer(lordId);
                if (player == null)
                    continue;
                if (player.getMails().containsKey(e.getKeyId())) {
                    LogUtil.common(String.format("lordId :%d, mail keyId :%d, already exist", lordId, keyId));
                    continue;
                }

                Mail mail = new Mail();
                mail.setKeyId(e.getKeyId());

                if (e.hasTitle()) {
                    mail.setTitle(EmojiHelper.filterEmojiWith0(e.getTitle()));
                }

                if (e.hasContont()) {
                    mail.setContont(EmojiHelper.filterEmojiWith0(e.getContont()));
                }

                if (e.hasSendName()) {
                    mail.setSendName(EmojiHelper.filterEmojiWith0(e.getSendName()));
                }

                if (e.hasMoldId()) {
                    mail.setMoldId(e.getMoldId());
                }

                mail.setState(e.getState());
                mail.setTime(e.getTime());
                mail.setType(e.getType());
                mail.setToName(e.getToNameList());
                mail.setAward(e.getAwardList());

                List<String> paramList = e.getParamList();
                if (paramList != null && paramList.size() > 0) {
                    String[] param = new String[paramList.size()];
                    for (int i = 0; i < param.length; i++) {
                        param[i] = paramList.get(i);
                    }
                    mail.setParam(param);
                }

                if (e.hasReport()) {
                    mail.setReport(e.getReport());
                }

                //                NewMail newMail = MailHelper.createNewMail(lordId, mail);
                //                try {
                //                    mailDao.insertMail(newMail);
                //                } catch (Exception e1) {
                //                    LogUtil.error(String.format("lordId :%d, keyId :%d, title :%s, content :%s", lordId, keyId, mail.getTitle(), mail.getContont()), e1);
                //                }
                //                player.getMails().put(mail.getKeyId(), mail);

                //只恢复到内存，让定时器写入数据库，不实时写入库
                player.addNewMail(mail);
                LogUtil.common(String.format("lordId :%d, mail keyId :%d, huifu succ", lordId, keyId));

            }
        } catch (Exception e) {
            LogUtil.error(String.format("lordId :%d, mail keyId :%d, paser error", lordId, keyId), e);
        }
    }

    private String replaceSpecail(String text) {
        boolean bChange = false;
        byte[] b_text = text.getBytes();
        for (int i = 0; i < b_text.length; i++) {
            if ((b_text[i] & 0xF8) == 0xF0) {
                for (int j = 0; j < 4; j++) {
                    b_text[i + j] = 0x30;
                }
                i += 3;
                bChange = true;
            }
        }
        if (bChange) {
            try {
                String n_text = new String(b_text, "utf-8");
                LogUtil.common(String.format("text :%s", text));
                LogUtil.common(String.format("n_test :%s", n_text));
                return n_text;
            } catch (Exception e) {
                LogUtil.error("", e);
            }
        }
        return text;
    }

    private List<List<Integer>> getListList(String columnValue) {
        List<List<Integer>> listList = new ArrayList<>();
        if (columnValue == null || columnValue.isEmpty()) {
            return listList;
        }

        try {
            JSONArray arrays = JSONArray.parseArray(columnValue);
            for (int i = 0; i < arrays.size(); i++) {
                List<Integer> list = new ArrayList<>();
                JSONArray array = arrays.getJSONArray(i);
                for (int j = 0; j < array.size(); j++) {
                    list.add(array.getInteger(j));
                }

                // if (!list.isEmpty()) {
                listList.add(list);
                // }
            }
        } catch (Exception e) {
            LogUtil.info("ListListTypeHandler parse:" + columnValue);
            throw e;
        }

        return listList;
    }
}
