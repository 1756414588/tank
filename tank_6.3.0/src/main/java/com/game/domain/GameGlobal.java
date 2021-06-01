/**
 * @Title: GameGlobal.java
 * @Package com.game.domain
 * @Description:
 * @author ZhangJun
 * @date 2015年10月13日 下午3:21:50
 * @version V1.0
 */
package com.game.domain;

import com.alibaba.fastjson.JSONArray;
import com.game.domain.p.ActLuckyPoolLog;
import com.game.domain.p.Award;
import com.game.domain.p.FortressBattleParty;
import com.game.domain.p.LuckyGlobalInfo;
import com.game.domain.p.Mail;
import com.game.domain.p.Mine;
import com.game.domain.p.PartyRankInfo;
import com.game.domain.p.PersonKingInfo;
import com.game.domain.p.PersonRankInfo;
import com.game.domain.p.TeamTask;
import com.game.domain.p.WarRankInfo;
import com.game.domain.p.WorldStaffing;
import com.game.domain.p.*;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.PlayerAirship;
import com.game.domain.sort.ActRedBag;
import com.game.drill.domain.DrillImproveInfo;
import com.game.drill.domain.DrillRank;
import com.game.drill.domain.DrillRecord;
import com.game.drill.domain.DrillResult;
import com.game.drill.domain.DrillShopBuy;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.fortressFight.domain.MyFortressAttr;
import com.game.fortressFight.domain.MyFortressFightData;
import com.game.fortressFight.domain.MyPartyStatistics;
import com.game.honour.domain.HonourPartyScore;
import com.game.manager.BossDataManager;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.*;
import com.game.pb.SerializePb;
import com.game.pb.SerializePb.*;
import com.game.rebel.domain.PartyRebelData;
import com.game.rebel.domain.Rebel;
import com.game.server.GameServer;
import com.game.util.PbHelper;
import com.game.util.SerPbHelper;
import com.game.util.Tuple;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: GameGlobal
 * @Description:
 * @date 2015年10月13日 下午3:21:50
 */
public class GameGlobal {
    private int globalId;
    private int maxKey;
    private LinkedList<Mail> mails = new LinkedList<Mail>();

    private int warTime;
    private LinkedList<WarRecord> warRecord = new LinkedList<>();

    /**
     * 百团混战状态 1.报名中 2.准备阶段 3.战斗中 4.结束 5.取消
     */
    private int warState;
    private List<Long> winRank = new ArrayList<>();
    private Set<Long> getWinRank = new HashSet<>();

    private int bossTime;
    private int bossLv;
    private int bossWhich;
    private int bossHp;
    private int bossState;
    private List<Long> hurtRank = new ArrayList<>();
    private Set<Long> getHurtRank = new HashSet<>();
    private String bossKiller;
    private List<Integer> shop = new ArrayList<Integer>();
    private int shopTime;

    private LinkedList<SeniorScoreRank> scoreRank = new LinkedList<>();
    private LinkedList<SeniorPartyScoreRank> scorePartyRank = new LinkedList<>();

    private int seniorWeek;

    private Map<Long, Map<Integer, List<com.game.domain.p.Award>>> notGetMap = new HashMap<>();


    /**
     * 军事矿区状态
     */
    private int seniorState;

    // 记录本周军团战排名数据 time,rank,WarRankInfo
    private Map<Integer, Map<Integer, WarRankInfo>> warRankRecords = new HashMap<Integer, Map<Integer, WarRankInfo>>();
    // 能参加要塞战的军团
    private LinkedHashMap<Integer, FortressBattleParty> canFightFortressPartyMap = new LinkedHashMap<Integer, FortressBattleParty>();
    // 要塞战记录
    private LinkedHashMap<Integer, FortressRecord> fortressRecords = new LinkedHashMap<Integer, FortressRecord>();
    // 要塞战战报
    private Map<Integer, RptAtkFortress> rptRtkFortresss = new HashMap<Integer, RptAtkFortress>();
    // 我的要塞战数据
    private Map<Long, MyFortressFightData> myFortressFightDatas = new HashMap<Long, MyFortressFightData>();
    // 统计要塞战军团数据(军团id, 统计,积分排行)
    private LinkedHashMap<Integer, MyPartyStatistics> partyStatisticsMap = new LinkedHashMap<Integer, MyPartyStatistics>();
    // 要塞主任命职位信息
    private List<FortressJobAppoint> fortressJobAppointList = new ArrayList<FortressJobAppoint>();
    // 全服个人积分排名top100
    private LinkedHashMap<Long, MyFortressFightData> allServerFortressFightDataRankLordMap = new LinkedHashMap<Long, MyFortressFightData>(
            100);
    // 要塞战状态:0未开始,1准备2开始3取消4战斗结束5奖励结束
    private int fortressState;
    // 要塞主军团
    private int fortressPartyId;
    // 要塞战时间
    private int fortressTime;

    // 计算可以參加要塞战军团的时间
    private int calCanJoinFortressTime;

    // 清理要塞战职位时间
    private int clearJobTime;

    // 红蓝大战活动的状态，0 未开启，1 报名，2 备战，3 预热，4 第一部队战斗，5 第二部队战斗，6 第三部队战斗
    private int drillStatus;

    // 红蓝大战最近一次开启的日期，格式:20160809
    private int lastOpenDrillDate;

    // 红蓝大战玩家排行榜
    private Map<Integer, LinkedHashMap<Long, DrillRank>> drillRank = new HashMap<>();

    // 红蓝大战玩家战况记录
    private Map<Integer, LinkedHashMap<Integer, DrillRecord>> drillRecords = new HashMap<>();

    // 红蓝大战玩家的战报记录
    private Map<Integer, RptAtkFortress> drillFightRpts = new HashMap<>();

    // 红蓝大战三路战斗结果
    private Map<Integer, DrillResult> drillResult = new HashMap<>();

    private int redExploit;// 红方阵营功勋

    private int blueExploit;// 蓝方阵营功勋

    private int drillWinner;// 红蓝大战最终胜利阵营，0 平局，1 红方胜，2 蓝方胜

    // 红蓝大战红方的进修情况
    private Map<Integer, DrillImproveInfo> drillRedImprove = new HashMap<>();

    // 红蓝大战蓝方的进修情况
    private Map<Integer, DrillImproveInfo> drillBlueImprove = new HashMap<>();

    // 红蓝大战军演商店购买情况
    private Map<Integer, DrillShopBuy> drillShop = new HashMap<>();

    private int refreshDrillShopDate;// 上次刷新军演商店的日期

    // 叛军入侵活动状态
    private int rebelStatus;

    // 叛军入侵活动最近一次开启的时间
    private int rebelLastOpenTime;

    // 叛军入侵，玩家活动相关数据
    private Map<Integer, Rebel> rebelMap = new HashMap<>();

    // 叛军礼盒掉落时间
    private Map<Integer, Integer> boxDropTime = new HashMap<>();

    // 叛军礼盒剩余可领取次数
    private Map<Integer, Integer> boxLeftCount = new HashMap<>();

    // 叛军礼盒开启获得的系统红包
    private Map<Integer, ActRedBag> redBags = new TreeMap<>();

    // 叛军活动每周军团活动信息
    private LinkedList<PartyRebelData> rebelPartyInfo = new LinkedList<>();

    // 叛军上周军团排行
    private List<Integer> lastWeekPartyRank = new LinkedList<>();

    // 上周玩家排行
    private List<Long> rebelLastWeekRankList = new ArrayList<>();

    // 已领取上周排行的玩家lordId
    private Set<Long> rebelRewardSet = new HashSet<>();

    // 已领取上周排行的玩家lordId
    private Set<Long> partyRewardSet = new HashSet<>();

    private int rebelLastWeekRankDate;// 上次刷新周排行榜的日期

    // 叛军入侵活动，本次活动已掉落将领记录, key:heroId, value:droppedNum
    private Map<Integer, Integer> rebelHeroDropMap = new HashMap<>();

    // 叛军入侵活动，本次活动已掉落将领叛军类型记录, key:rebelType, value:droppedNum
    private Map<Integer, Integer> rebelTypeDropMap = new HashMap<>();

    // KEY:矿点位置,VALUE:矿点信息
    private Map<Integer, Mine> worldMineInfo = new HashMap<>();

    // 服务器停服时间 (停服保护矿点经验不扣除)
    private int gameStopTime;

    // 飞艇列表
    private Map<Integer, Airship> airshipMap = new HashMap<>();

    // 玩家的飞艇信息
    private Map<Long, PlayerAirship> playerAirshipMap = new HashMap<>();

    // 幸运奖池
    private LuckyGlobalInfo luckyGlobalInfo = new LuckyGlobalInfo();

    // 组队副本任务
    private TeamTask teamTask = new TeamTask();

    // 荣耀玩法开启时间
    private int honourOpenTime;

    // 荣耀玩法当前阶段
    private int honourPhase;

    // 荣耀玩法安全区中心点
    private List<Tuple<Integer, Integer>> points = new ArrayList<>();

    // 荣耀玩法军团积分
    private Map<Integer, HonourPartyScore> partyScore = new HashMap<>();

    // 荣耀玩法已领取个人排行奖励的玩家
    private List<Long> playerRankAward = new LinkedList<>();

    // 荣耀玩法已领取军团排行奖励的玩家
    private List<Long> partyRankAward = new LinkedList<>();

    //世界矿点经验存储
    private WorldStaffing worldStaffing = new WorldStaffing();

    //最强王者活动
    private PersonKingInfo kingInfo = new PersonKingInfo();


    public List<Long> getPlayerRankAward() {
        return playerRankAward;
    }

    public void setPlayerRankAward(List<Long> playerRankAward) {
        this.playerRankAward = playerRankAward;
    }

    public List<Long> getPartyRankAward() {
        return partyRankAward;
    }

    public void setPartyRankAward(List<Long> partyRankAward) {
        this.partyRankAward = partyRankAward;
    }

    public Map<Integer, HonourPartyScore> getPartyScore() {
        return partyScore;
    }

    public void setPartyScore(Map<Integer, HonourPartyScore> partyScore) {
        this.partyScore = partyScore;
    }

    public Map<Integer, ActRedBag> getRedBags() {
        return redBags;
    }

    public int getFortressTime() {
        return fortressTime;
    }

    public void setFortressTime(int fortressTime) {
        this.fortressTime = fortressTime;
    }

    public LinkedHashMap<Long, MyFortressFightData> getAllServerFortressFightDataRankLordMap() {
        return allServerFortressFightDataRankLordMap;
    }

    public int getCalCanJoinFortressTime() {
        return calCanJoinFortressTime;
    }

    public void setCalCanJoinFortressTime(int calCanJoinFortressTime) {
        this.calCanJoinFortressTime = calCanJoinFortressTime;
    }

    public int getClearJobTime() {
        return clearJobTime;
    }

    public void setClearJobTime(int clearJobTime) {
        this.clearJobTime = clearJobTime;
    }

    public void setAllServerFortressFightDataRankLordMap(LinkedHashMap<Long, MyFortressFightData> allServerFortressFightDataRankLordMap) {
        this.allServerFortressFightDataRankLordMap = allServerFortressFightDataRankLordMap;
    }

    public LinkedHashMap<Integer, FortressBattleParty> getCanFightFortressPartyMap() {
        return canFightFortressPartyMap;
    }

    public void setCanFightFortressPartyMap(LinkedHashMap<Integer, FortressBattleParty> canFightFortressPartyMap) {
        this.canFightFortressPartyMap = canFightFortressPartyMap;
    }

    public List<Long> getWinRank() {
        return winRank;
    }

    public void setWinRank(List<Long> winRank) {
        this.winRank = winRank;
    }

    public int getWarTime() {
        return warTime;
    }

    public void setWarTime(int warTime) {
        this.warTime = warTime;
    }

    public int getWarState() {
        return warState;
    }

    public void setWarState(int warState) {
        this.warState = warState;
    }

    public int getGlobalId() {
        return globalId;
    }

    public void setGlobalId(int globalId) {
        this.globalId = globalId;
    }

    public int getMaxKey() {
        return maxKey;
    }

    public void setMaxKey(int maxKey) {
        this.maxKey = maxKey;
    }

    public LinkedList<Mail> getMails() {
        return mails;
    }

    public void setMails(LinkedList<Mail> mails) {
        this.mails = mails;
    }

    public int getBossLv() {
        return bossLv;
    }

    public void setBossLv(int bossLv) {
        this.bossLv = bossLv;
    }

    public int getBossWhich() {
        return bossWhich;
    }

    public void setBossWhich(int bossWhich) {
        this.bossWhich = bossWhich;
    }

    public int getBossHp() {
        return bossHp;
    }

    public void setBossHp(int bossHp) {
        this.bossHp = bossHp;
    }

    public List<Long> getHurtRank() {
        return hurtRank;
    }

    public void setHurtRank(List<Long> hurtRank) {
        this.hurtRank = hurtRank;
    }

    public Set<Long> getGetHurtRank() {
        return getHurtRank;
    }

    public void setGetHurtRank(Set<Long> getHurtRank) {
        this.getHurtRank = getHurtRank;
    }

    public List<Integer> getShop() {
        return shop;
    }

    public void setShop(List<Integer> shop) {
        this.shop = shop;
    }

    public int getShopTime() {
        return shopTime;
    }

    public void setShopTime(int shopTime) {
        this.shopTime = shopTime;
    }

    public LinkedList<SeniorScoreRank> getScoreRank() {
        return scoreRank;
    }

    public void setScoreRank(LinkedList<SeniorScoreRank> scoreRank) {
        this.scoreRank = scoreRank;
    }

    public LinkedList<SeniorPartyScoreRank> getScorePartyRank() {
        return scorePartyRank;
    }

    public void setScorePartyRank(LinkedList<SeniorPartyScoreRank> scorePartyRank) {
        this.scorePartyRank = scorePartyRank;
    }

    public int getSeniorWeek() {
        return seniorWeek;
    }

    public void setSeniorWeek(int seniorWeek) {
        this.seniorWeek = seniorWeek;
    }

    public DbGlobal ser() {
        return ser(false);
    }

    /**
     * @param isHefu 是否是合服调用
     * @return
     */
    public DbGlobal ser(boolean isHefu) {
        DbGlobal dbGlobal = new DbGlobal();
        dbGlobal.setGlobalId(globalId);
        dbGlobal.setMaxKey(maxKey);
        dbGlobal.setWarTime(warTime);
        dbGlobal.setWarState(warState);
        dbGlobal.setMails(serMail());
        dbGlobal.setWarRecord(serWarRecord());
        dbGlobal.setGetWinRank(serGetWinRank());
        dbGlobal.setWinRank(serWinRank());

        dbGlobal.setShop(serShop());

        dbGlobal.setBossTime(bossTime);
        dbGlobal.setBossLv(bossLv);
        dbGlobal.setBossWhich(bossWhich);
        dbGlobal.setBossHp(bossHp);

        //
        dbGlobal.setHurtRank(serHurtRank(isHefu));
        dbGlobal.setGetHurtRank(serGetHurtRank());
        dbGlobal.setBossState(bossState);
        dbGlobal.setBossKiller(bossKiller);
        dbGlobal.setShopTime(shopTime);
        dbGlobal.setSeniorWeek(seniorWeek);
        dbGlobal.setScoreRank(serScoreRank());
        dbGlobal.setScorePartyRank(serScorePartyRank());
        dbGlobal.setSeniorState(seniorState);

        dbGlobal.setWarRankRecords(serWarRankRecords());
        dbGlobal.setCanFightFortressPartyMap(serCanFightFortressPartyMap());
        dbGlobal.setFortressTime(fortressTime);
        dbGlobal.setFortressPartyId(fortressPartyId);
        dbGlobal.setFortressState(fortressState);
        dbGlobal.setFortressRecords(serFortressRecords());
        dbGlobal.setRptRtkFortresss(serRptRtkFortresss());
        dbGlobal.setMyFortressFightDatas(serMyFortressFightDatas());
        dbGlobal.setPartyStatisticsMap(serPartyStatisticsMap());
        dbGlobal.setFortressJobAppointList(serFortressJobAppointList());
        dbGlobal.setAllServerFortressFightDataRankLordMap(serAllServerFortressFightDataRankLordMap());

        dbGlobal.setDrillStatus(drillStatus);
        dbGlobal.setLastOpenDrillDate(lastOpenDrillDate);
        dbGlobal.setDrillRank(serDrillRank());
        dbGlobal.setDrillRecords(serDrillRecords());
        dbGlobal.setDrillFightRpts(serDrillFightRpts());
        dbGlobal.setDrillResult(serDrillResult());
        dbGlobal.setDrillImprove(serDrillImprove());
        dbGlobal.setDrillShop(serDrillShop());

        dbGlobal.setRebelStatus(rebelStatus);
        dbGlobal.setRebelLastOpenTime(rebelLastOpenTime);
        dbGlobal.setRebelTotalData(serRebelTotalData());
        dbGlobal.setWorldMineInfo(serWorldMineInfo());
        dbGlobal.setGameStopTime(gameStopTime);
        dbGlobal.setAirship(serAirship());
        dbGlobal.setNotGetAward(serNotGetAward());
        dbGlobal.setLuckyInfo(serLuckyData());
        dbGlobal.setTeamTask(serTeamData());
        dbGlobal.setHonourTotalData(serHonourTotalData());

        dbGlobal.setWorldStaffing(serWorldStaffing(worldStaffing));
        dbGlobal.setActKingInfo(serPersonKingInfo());
        return dbGlobal;
    }

    private byte[] serLuckyData() {
        CommonPb.LuckyGlobalInfo.Builder luck = CommonPb.LuckyGlobalInfo.newBuilder();
        luck.setPoolGold(luckyGlobalInfo.getPoolGold());
        luck.setVersion(luckyGlobalInfo.getVersion());
        for (ActLuckyPoolLog log : luckyGlobalInfo.getLuckyLog()) {
            luck.addLuckyLog(PbHelper.createActLuckyPoolLog(log));
        }
        return luck.build().toByteArray();
    }

    private byte[] serTeamData() {
        CommonPb.TeamTaskData.Builder t = CommonPb.TeamTaskData.newBuilder();

        Map<Integer, Long> taskInfo = teamTask.getTaskInfo();
        for (Map.Entry<Integer, Long> e : taskInfo.entrySet()) {
            KvLong.Builder kv = KvLong.newBuilder();
            kv.setKey(e.getKey());
            kv.setValue(e.getValue());
            t.addTaskInfo(kv.build());
        }

        return t.build().toByteArray();
    }

    private byte[] serAirship() {
        return SerPbHelper.serAirship(airshipMap, playerAirshipMap);
    }

    private byte[] serWorldMineInfo() {
        return SerPbHelper.serWorldMine(worldMineInfo);
    }

    private byte[] serRebelTotalData() {
        SerRebelTotalData.Builder ser = SerRebelTotalData.newBuilder();
        for (Rebel rebel : rebelMap.values()) {
            ser.addRebel(PbHelper.createRebelPb(rebel));
        }

        ser.addAllLastWeekRank(rebelLastWeekRankList);
        ser.addAllRebelReward(rebelRewardSet);
        ser.addAllLastWeekPartyRank(lastWeekPartyRank);
        ser.addAllPartyReward(partyRewardSet);

        for (PartyRebelData data : rebelPartyInfo) {
            ser.addPartyRebelData(PbHelper.createPartyRebelData(data));
        }

        for (Entry<Integer, Integer> entry : rebelHeroDropMap.entrySet()) {
            ser.addRebelHeroDrop(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }

        for (Entry<Integer, Integer> entry : rebelTypeDropMap.entrySet()) {
            ser.addRebelTypeDrop(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }

        for (Entry<Integer, Integer> entry : boxLeftCount.entrySet()) {
            ser.addBoxLeftCount(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }

        for (Entry<Integer, Integer> entry : boxDropTime.entrySet()) {
            ser.addBoxDropTime(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }

        for (Entry<Integer, ActRedBag> entry : redBags.entrySet()) {
            ser.addRedBag(entry.getValue().paserPb());
        }

        ser.setLastWeekRankDate(rebelLastWeekRankDate);

        return ser.build().toByteArray();
    }

    private byte[] serDrillShop() {
        SerDrillShopBuy.Builder ser = SerDrillShopBuy.newBuilder();
        for (DrillShopBuy buy : drillShop.values()) {
            ser.addBuy(PbHelper.createDrillShopBuyPb(buy, buy.getRestNum()));
        }
        ser.setRefreshShopDate(refreshDrillShopDate);
        return ser.build().toByteArray();
    }

    private byte[] serDrillImprove() {
        SerDrillImproveInfo.Builder ser = SerDrillImproveInfo.newBuilder();
        for (DrillImproveInfo info : drillRedImprove.values()) {
            ser.addRedImprove(PbHelper.createDrillImproveInfoPb(info.getBuffId(), info.getBuffLv(), info.getExper(), 0));
        }
        for (DrillImproveInfo info : drillBlueImprove.values()) {
            ser.addBlueImprove(PbHelper.createDrillImproveInfoPb(info.getBuffId(), info.getBuffLv(), info.getExper(), 0));
        }
        return ser.build().toByteArray();
    }

    private byte[] serDrillResult() {
        SerDrillResult.Builder ser = SerDrillResult.newBuilder();
        for (Entry<Integer, DrillResult> entry : drillResult.entrySet()) {
            if (entry.getKey() == 1) {
                ser.setFirstResult(PbHelper.createDrillResultPb(entry.getValue()));
            } else if (entry.getKey() == 2) {
                ser.setSecondResult(PbHelper.createDrillResultPb(entry.getValue()));
            } else if (entry.getKey() == 3) {
                ser.setThirdResult(PbHelper.createDrillResultPb(entry.getValue()));
            }
        }
        ser.setRedExploit(redExploit);
        ser.setBlueExploit(blueExploit);
        ser.setDrillWinner(drillWinner);
        return ser.build().toByteArray();
    }

    private byte[] serDrillFightRpts() {
        SerRptRtkFortresss.Builder ser = SerRptRtkFortresss.newBuilder();
        for (RptAtkFortress report : drillFightRpts.values()) {
            ser.addRptAtkFortress(PbHelper.createRptAtkFortressPb(report));
        }
        return ser.build().toByteArray();
    }

    private byte[] serDrillRecords() {
        SerDrillRecord.Builder ser = SerDrillRecord.newBuilder();
        for (Entry<Integer, LinkedHashMap<Integer, DrillRecord>> entry : drillRecords.entrySet()) {
            if (entry.getKey() == 1) {
                for (DrillRecord record : entry.getValue().values()) {
                    ser.addFirstRecord(PbHelper.createDrillRecordPb(record));
                }
            } else if (entry.getKey() == 2) {
                for (DrillRecord record : entry.getValue().values()) {
                    ser.addSecondRecord(PbHelper.createDrillRecordPb(record));
                }
            } else if (entry.getKey() == 3) {
                for (DrillRecord record : entry.getValue().values()) {
                    ser.addThirdRecord(PbHelper.createDrillRecordPb(record));
                }
            }
        }
        return ser.build().toByteArray();
    }

    private byte[] serDrillRank() {
        SerDrillRank.Builder ser = SerDrillRank.newBuilder();
        for (Entry<Integer, LinkedHashMap<Long, DrillRank>> entry : drillRank.entrySet()) {
            if (entry.getKey() == 1) {
                for (DrillRank rank : entry.getValue().values()) {
                    ser.addFirstRank(PbHelper.createDrillRankPb(rank));
                }
            } else if (entry.getKey() == 2) {
                for (DrillRank rank : entry.getValue().values()) {
                    ser.addSecondRank(PbHelper.createDrillRankPb(rank));
                }
            } else if (entry.getKey() == 3) {
                for (DrillRank rank : entry.getValue().values()) {
                    ser.addThirdRank(PbHelper.createDrillRankPb(rank));
                }
            } else if (entry.getKey() == 4) {
                for (DrillRank rank : entry.getValue().values()) {
                    ser.addTotalRank(PbHelper.createDrillRankPb(rank));
                }
            }
        }
        return ser.build().toByteArray();
    }

    private byte[] serAllServerFortressFightDataRankLordMap() {
        SerAllServerFortressFightDataRankLordMap.Builder ser = SerAllServerFortressFightDataRankLordMap.newBuilder();
        Iterator<MyFortressFightData> its = allServerFortressFightDataRankLordMap.values().iterator();
        while (its.hasNext()) {
            ser.addMyFortressFightData(PbHelper.createMyFortressFightDataPb(its.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serFortressJobAppointList() {
        SerFortressJobAppointList.Builder ser = SerFortressJobAppointList.newBuilder();
        ser.setClearJobTime(clearJobTime);
        for (FortressJobAppoint f : fortressJobAppointList) {
            ser.addFortressJobAppoint(PbHelper.createFortressJobAppointPb(f));
        }

        return ser.build().toByteArray();
    }

    private byte[] serPartyStatisticsMap() {
        SerPartyStatisticsMap.Builder ser = SerPartyStatisticsMap.newBuilder();
        Iterator<MyPartyStatistics> its = partyStatisticsMap.values().iterator();
        while (its.hasNext()) {
            ser.addMyPartyStatistics(PbHelper.createMyPartyStatistics(its.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serMyFortressFightDatas() {
        SerMyFortressFightDatas.Builder ser = SerMyFortressFightDatas.newBuilder();
        Iterator<MyFortressFightData> its = myFortressFightDatas.values().iterator();
        while (its.hasNext()) {
            ser.addMyFortressFightData(PbHelper.createMyFortressFightDataPb(its.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serRptRtkFortresss() {
        SerRptRtkFortresss.Builder ser = SerRptRtkFortresss.newBuilder();
        Iterator<RptAtkFortress> its = rptRtkFortresss.values().iterator();
        while (its.hasNext()) {
            ser.addRptAtkFortress(PbHelper.createRptAtkFortressPb(its.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serFortressRecords() {
        SerFortressRecords.Builder ser = SerFortressRecords.newBuilder();
        Iterator<FortressRecord> its = fortressRecords.values().iterator();
        while (its.hasNext()) {
            ser.addFortressRecord(PbHelper.createFortressRecord(its.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serCanFightFortressPartyMap() {
        SerCanFightFortressPartyMap.Builder ser = SerCanFightFortressPartyMap.newBuilder();
        Iterator<FortressBattleParty> its = canFightFortressPartyMap.values().iterator();
        while (its.hasNext()) {
            ser.addFortressBattleParty(PbHelper.createFortressBattlePartyPb(its.next()));
        }
        ser.setCalCanJoinFortressTime(calCanJoinFortressTime);

        return ser.build().toByteArray();
    }

    /**
     * Method: serWarRankRecords @Description: @return @return byte[] @throws
     */
    private byte[] serWarRankRecords() {
        SerWarRankInfo.Builder ser = SerWarRankInfo.newBuilder();
        Iterator<Map<Integer, WarRankInfo>> it = warRankRecords.values().iterator();
        while (it.hasNext()) {
            Iterator<WarRankInfo> i = it.next().values().iterator();
            while (i.hasNext()) {
                ser.addWarRankInfo(PbHelper.createWarRankInfoPb(i.next()));
            }
        }
        return ser.build().toByteArray();
    }

    public void dser(DbGlobal dbGlobal) throws InvalidProtocolBufferException {
        globalId = dbGlobal.getGlobalId();
        maxKey = dbGlobal.getMaxKey();
        warTime = dbGlobal.getWarTime();
        warState = dbGlobal.getWarState();
        dserMail(dbGlobal.getMails());
        dserWarRecord(dbGlobal.getWarRecord());
        dserGetWinRank(dbGlobal.getGetWinRank());
        dserWinRank(dbGlobal.getWinRank());

        dserShop(dbGlobal.getShop());

        bossTime = dbGlobal.getBossTime();
        bossLv = dbGlobal.getBossLv();
        bossWhich = dbGlobal.getBossWhich();
        bossHp = dbGlobal.getBossHp();
        bossState = dbGlobal.getBossState();
        dserHurtRank(dbGlobal.getHurtRank());
        dserGetHurtRank(dbGlobal.getGetHurtRank());
        bossKiller = dbGlobal.getBossKiller();
        shopTime = dbGlobal.getShopTime();
        dserScoreRank(dbGlobal.getScoreRank());
        dserScorePartyRank(dbGlobal.getScorePartyRank());
        seniorWeek = dbGlobal.getSeniorWeek();
        seniorState = dbGlobal.getSeniorState();

        dserWarRankRecords(dbGlobal.getWarRankRecords());
        dserCanFightFortressPartyMap(dbGlobal.getCanFightFortressPartyMap());
        dserFortressRecords(dbGlobal.getFortressRecords());
        dserRptRtkFortresss(dbGlobal.getRptRtkFortresss());
        dserMyFortressFightDatas(dbGlobal.getMyFortressFightDatas());
        dserPartyStatisticsMap(dbGlobal.getPartyStatisticsMap());
        dserFortressJobAppointList(dbGlobal.getFortressJobAppointList());
        dserAllServerFortressFightDataRankMap(dbGlobal.getAllServerFortressFightDataRankLordMap());
        fortressState = dbGlobal.getFortressState();
        fortressPartyId = dbGlobal.getFortressPartyId();
        fortressTime = dbGlobal.getFortressTime();

        drillStatus = dbGlobal.getDrillStatus();
        lastOpenDrillDate = dbGlobal.getLastOpenDrillDate();
        dserDrillRank(dbGlobal.getDrillRank());
        dserDrillRecords(dbGlobal.getDrillRecords());
        dserDrillFightRpts(dbGlobal.getDrillFightRpts());
        dserDrillResult(dbGlobal.getDrillResult());
        dserDrillImprove(dbGlobal.getDrillImprove());
        dserDrillShop(dbGlobal.getDrillShop());

        rebelStatus = dbGlobal.getRebelStatus();
        rebelLastOpenTime = dbGlobal.getRebelLastOpenTime();
        dserRebelTotalData(dbGlobal.getRebelTotalData());
        dserWorldMineInfo(dbGlobal.getWorldMineInfo());
        gameStopTime = dbGlobal.getGameStopTime();
        dserAirship(dbGlobal.getAirship());
        dserNotGetAward(dbGlobal.getNotGetAward());

        dseruckyGlobalInfo(dbGlobal.getLuckyInfo());

        dserTeamTaskGlobalInfo(dbGlobal.getTeamTask());
        dserHonourTotalData(dbGlobal.getHonourTotalData());
        dserPersonKingInfo(dbGlobal.getActKingInfo());
        dserWorldStaffing(dbGlobal.getWorldStaffing(), worldStaffing);
    }

    private void dserTeamTaskGlobalInfo(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }
        CommonPb.TeamTaskData t = CommonPb.TeamTaskData.parseFrom(data);
        List<KvLong> taskInfoList = t.getTaskInfoList();
        for (KvLong e : taskInfoList) {
            teamTask.getTaskInfo().put(e.getKey(), e.getValue());
        }

    }

    private void dseruckyGlobalInfo(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }
        CommonPb.LuckyGlobalInfo luck = CommonPb.LuckyGlobalInfo.parseFrom(data);
        luckyGlobalInfo.setPoolGold(luck.getPoolGold());
        luckyGlobalInfo.setVersion(luck.getVersion());
        for (com.game.pb.CommonPb.ActLuckyPoolLog log : luck.getLuckyLogList()) {
            luckyGlobalInfo.getLuckyLog().add(new ActLuckyPoolLog(log));
        }
    }

    private void dserAirship(byte[] data) throws InvalidProtocolBufferException {
        if (null == data)
            return;
        SerAirship ser = SerAirship.parseFrom(data);
        for (com.game.pb.SerializePb.AirshipDb airshipPb : ser.getAirshipList()) {
            airshipMap.put(airshipPb.getId(), new Airship(airshipPb));
        }
        for (SerializePb.SerPlayerAirship pbPlayerAirship : ser.getPlayerAirshipList()) {
            playerAirshipMap.put(pbPlayerAirship.getLordId(), new PlayerAirship(pbPlayerAirship));
        }
    }

    /**
     * @param notGetAward
     */
    private void dserNotGetAward(byte[] notGetAward) throws InvalidProtocolBufferException {
        if (notGetAward == null || notGetAward.length == 0) {
            return;
        }
        SerNotGetAward ser = SerNotGetAward.parseFrom(notGetAward);

        for (NotGetAward award : ser.getAwardList()) {
            long lordId = award.getLordId();
            int type = award.getType();
            List<com.game.pb.CommonPb.Award> awardList = award.getAwardList();
            List<Award> list = new ArrayList<>();
            for (com.game.pb.CommonPb.Award awardPb : awardList) {
                Award a = new Award(awardPb.getType(), awardPb.getId(), (int) awardPb.getCount(), 0);
                list.add(a);
            }
            this.addNotGet(lordId, type, list);
        }
    }

    private void dserRebelTotalData(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerRebelTotalData ser = SerRebelTotalData.parseFrom(data);
        for (com.game.pb.CommonPb.Rebel rebel : ser.getRebelList()) {
            rebelMap.put(rebel.getPos(), new Rebel(rebel));
        }

        rebelLastWeekRankList.addAll(ser.getLastWeekRankList());
        rebelRewardSet.addAll(ser.getRebelRewardList());
        partyRewardSet.addAll(ser.getPartyRewardList());
        lastWeekPartyRank.addAll(ser.getLastWeekPartyRankList());

        for (com.game.pb.CommonPb.PartyRebelData partyData : ser.getPartyRebelDataList()) {
            rebelPartyInfo.add(new PartyRebelData(partyData));
        }

        for (TwoInt twoInt : ser.getRebelHeroDropList()) {
            rebelHeroDropMap.put(twoInt.getV1(), twoInt.getV2());
        }

        for (TwoInt twoInt : ser.getBoxDropTimeList()) {
            boxDropTime.put(twoInt.getV1(), twoInt.getV2());
        }

        for (TwoInt twoInt : ser.getBoxLeftCountList()) {
            boxLeftCount.put(twoInt.getV1(), twoInt.getV2());
        }

        for (SerActRedBag pb : ser.getRedBagList()) {
            ActRedBag arb = new ActRedBag(pb);
            redBags.put(arb.getId(), arb);
        }

        if (ser.hasLastWeekRankDate()) {
            rebelLastWeekRankDate = ser.getLastWeekRankDate();
        }
    }

    private void dserWorldMineInfo(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }
        worldMineInfo = SerPbHelper.dserWorldMine(data);
    }

    private void dserDrillShop(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerDrillShopBuy ser = SerDrillShopBuy.parseFrom(data);
        for (com.game.pb.CommonPb.DrillShopBuy buy : ser.getBuyList()) {
            drillShop.put(buy.getShopId(), new DrillShopBuy(buy));
        }

        if (ser.hasRefreshShopDate()) {
            refreshDrillShopDate = ser.getRefreshShopDate();
        }
    }

    private void dserDrillImprove(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerDrillImproveInfo ser = SerDrillImproveInfo.parseFrom(data);
        for (com.game.pb.CommonPb.DrillImproveInfo info : ser.getRedImproveList()) {
            drillRedImprove.put(info.getBuffId(), new DrillImproveInfo(info));
        }
        for (com.game.pb.CommonPb.DrillImproveInfo info : ser.getBlueImproveList()) {
            drillBlueImprove.put(info.getBuffId(), new DrillImproveInfo(info));
        }
    }

    private void dserDrillResult(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerDrillResult ser = SerDrillResult.parseFrom(data);
        if (ser.hasFirstResult()) {
            drillResult.put(1, new DrillResult(ser.getFirstResult()));
        }
        if (ser.hasSecondResult()) {
            drillResult.put(2, new DrillResult(ser.getSecondResult()));
        }
        if (ser.hasThirdResult()) {
            drillResult.put(3, new DrillResult(ser.getThirdResult()));
        }
        if (ser.hasRedExploit()) {
            redExploit = ser.getRedExploit();
        }
        if (ser.hasBlueExploit()) {
            blueExploit = ser.getBlueExploit();
        }
        if (ser.hasDrillWinner()) {
            drillWinner = ser.getDrillWinner();
        }
    }

    private void dserDrillFightRpts(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }
        SerRptRtkFortresss ser = SerRptRtkFortresss.parseFrom(data);
        for (RptAtkFortress r : ser.getRptAtkFortressList()) {
            drillFightRpts.put(r.getReportKey(), r);
        }
    }

    private void dserDrillRecords(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerDrillRecord ser = SerDrillRecord.parseFrom(data);
        LinkedHashMap<Integer, DrillRecord> map;
        for (com.game.pb.CommonPb.DrillRecord record : ser.getFirstRecordList()) {
            map = drillRecords.get(1);
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRecords.put(1, map);
            }
            map.put(record.getReportKey(), new DrillRecord(record));
        }
        for (com.game.pb.CommonPb.DrillRecord record : ser.getSecondRecordList()) {
            map = drillRecords.get(2);
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRecords.put(2, map);
            }
            map.put(record.getReportKey(), new DrillRecord(record));
        }
        for (com.game.pb.CommonPb.DrillRecord record : ser.getThirdRecordList()) {
            map = drillRecords.get(3);
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRecords.put(3, map);
            }
            map.put(record.getReportKey(), new DrillRecord(record));
        }
    }

    private void dserDrillRank(byte[] data) throws InvalidProtocolBufferException {
        if (null == data) {
            return;
        }

        SerDrillRank ser = SerDrillRank.parseFrom(data);
        LinkedHashMap<Long, DrillRank> map = drillRank.get(1);
        for (com.game.pb.CommonPb.DrillRank rank : ser.getFirstRankList()) {
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRank.put(1, map);
            }
            map.put(rank.getLordId(), new DrillRank(rank));
        }
        map = drillRank.get(2);
        for (com.game.pb.CommonPb.DrillRank rank : ser.getSecondRankList()) {
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRank.put(2, map);
            }
            map.put(rank.getLordId(), new DrillRank(rank));
        }
        map = drillRank.get(3);
        for (com.game.pb.CommonPb.DrillRank rank : ser.getThirdRankList()) {
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRank.put(3, map);
            }
            map.put(rank.getLordId(), new DrillRank(rank));
        }
        map = drillRank.get(4);
        for (com.game.pb.CommonPb.DrillRank rank : ser.getTotalRankList()) {
            if (null == map) {
                map = new LinkedHashMap<>();
                drillRank.put(4, map);
            }
            map.put(rank.getLordId(), new DrillRank(rank));
        }
    }

    private void dserAllServerFortressFightDataRankMap(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerAllServerFortressFightDataRankLordMap ser = SerAllServerFortressFightDataRankLordMap.parseFrom(data);

        for (CommonPb.MyFortressFightData my : ser.getMyFortressFightDataList()) {
            MyFortressFightData md = new MyFortressFightData();
            md.setLordId(my.getLordId());

            for (SufferTank s : my.getSufferTankMapList()) {
                md.getSufferTankMap().put(s.getTankId(), new com.game.fortressFight.domain.SufferTank(s.getTankId(), s.getSufferCount()));
            }

            for (SufferTank s : my.getDestoryTankMapList()) {
                md.getDestoryTankMap().put(s.getTankId(), new com.game.fortressFight.domain.SufferTank(s.getTankId(), s.getSufferCount()));
            }

            md.getMyCD().setBeginTime(my.getMyCD().getBeginTime());
            md.getMyCD().setEndTime(my.getMyCD().getEndTime());

            md.setJifen(my.getJifen());
            md.setFightNum(my.getFightNum());
            md.setWinNum(my.getWinNum());
            md.getMyReportKeys().addAll(my.getMyReportKeysList());

            for (com.game.pb.CommonPb.MyFortressAttr a : my.getMyFortressAttrList()) {
                md.getMyFortressAttrs().put(a.getId(), new MyFortressAttr(a.getId(), a.getLevel()));
            }

            md.setSufferTankCountForevel(my.getDestoryTankMapCount());
            md.setMplt(my.getMplt());

            allServerFortressFightDataRankLordMap.put(md.getLordId(), md);
        }
    }

    private void dserFortressJobAppointList(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerFortressJobAppointList ser = SerFortressJobAppointList.parseFrom(data);
        for (CommonPb.FortressJobAppoint f : ser.getFortressJobAppointList()) {
            FortressJobAppoint m = new FortressJobAppoint();
            m.setJobId(f.getJobId());
            m.setLordId(f.getLordId());
            m.setAppointTime(f.getAppointTime());
            m.setEndTime(f.getEndTime());
            m.setNick(f.getNick());
            m.setIndex(f.getIndex());
            fortressJobAppointList.add(m);
        }
        if (ser.hasClearJobTime()) {
            this.clearJobTime = ser.getClearJobTime();
        }
    }

    private void dserPartyStatisticsMap(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerPartyStatisticsMap ser = SerPartyStatisticsMap.parseFrom(data);
        List<CommonPb.MyPartyStatistics> list = ser.getMyPartyStatisticsList();
        for (CommonPb.MyPartyStatistics m : list) {
            MyPartyStatistics ms = new MyPartyStatistics();
            ms.setPartyId(m.getPartyId());
            ms.setFightNum(m.getFightNum());
            ms.setJifen(m.getJifen());
            ms.setWinNum(m.getWinNum());
            ms.setAttack(m.getIsAttack());

            for (SufferTank s : m.getDestoryTankMapList()) {
                ms.getDestoryTankMap().put(s.getTankId(), new com.game.fortressFight.domain.SufferTank(s.getTankId(), s.getSufferCount()));
            }
            partyStatisticsMap.put(ms.getPartyId(), ms);
        }

    }

    private void dserMyFortressFightDatas(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerMyFortressFightDatas ser = SerMyFortressFightDatas.parseFrom(data);
        List<CommonPb.MyFortressFightData> list = ser.getMyFortressFightDataList();
        for (CommonPb.MyFortressFightData my : list) {
            MyFortressFightData md = new MyFortressFightData();
            md.setLordId(my.getLordId());

            for (SufferTank s : my.getSufferTankMapList()) {
                md.getSufferTankMap().put(s.getTankId(), new com.game.fortressFight.domain.SufferTank(s.getTankId(), s.getSufferCount()));
            }

            for (SufferTank s : my.getDestoryTankMapList()) {
                md.getDestoryTankMap().put(s.getTankId(), new com.game.fortressFight.domain.SufferTank(s.getTankId(), s.getSufferCount()));
            }

            md.getMyCD().setBeginTime(my.getMyCD().getBeginTime());
            md.getMyCD().setEndTime(my.getMyCD().getEndTime());

            md.setJifen(my.getJifen());
            md.setFightNum(my.getFightNum());
            md.setWinNum(my.getWinNum());
            md.getMyReportKeys().addAll(my.getMyReportKeysList());

            for (com.game.pb.CommonPb.MyFortressAttr a : my.getMyFortressAttrList()) {
                md.getMyFortressAttrs().put(a.getId(), new MyFortressAttr(a.getId(), a.getLevel()));
            }

            md.setSufferTankCountForevel(my.getDestoryTankMapCount());
            md.setMplt(my.getMplt());

            myFortressFightDatas.put(md.getLordId(), md);
        }
    }

    private void dserRptRtkFortresss(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerRptRtkFortresss ser = SerRptRtkFortresss.parseFrom(data);
        List<CommonPb.RptAtkFortress> list = ser.getRptAtkFortressList();
        for (CommonPb.RptAtkFortress f : list) {
            rptRtkFortresss.put(f.getReportKey(), f);
        }
    }

    private void dserFortressRecords(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerFortressRecords ser = SerFortressRecords.parseFrom(data);
        List<CommonPb.FortressRecord> list = ser.getFortressRecordList();
        for (CommonPb.FortressRecord f : list) {
            fortressRecords.put(f.getReportKey(), f);
        }
    }

    private void dserCanFightFortressPartyMap(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerCanFightFortressPartyMap ser = SerCanFightFortressPartyMap.parseFrom(data);
        List<CommonPb.FortressBattleParty> list = ser.getFortressBattlePartyList();
        for (CommonPb.FortressBattleParty f : list) {
            FortressBattleParty p = new FortressBattleParty();
            p.setPartyId(f.getPartyId());
            p.setPartyName(f.getPartyName());
            p.setRank(f.getRank());
            canFightFortressPartyMap.put(f.getPartyId(), p);
        }

        if (ser.hasCalCanJoinFortressTime()) {
            this.calCanJoinFortressTime = ser.getCalCanJoinFortressTime();
        }
    }

    /**
     * @throws InvalidProtocolBufferException Method: dserWarRankRecords @Description: @param warRankRecords2 @return
     *                                        void @throws
     */
    private void dserWarRankRecords(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerWarRankInfo ser = SerWarRankInfo.parseFrom(data);
        List<CommonPb.WarRankInfo> list = ser.getWarRankInfoList();
        for (CommonPb.WarRankInfo pbInfo : list) {
            WarRankInfo info = new WarRankInfo(pbInfo.getDateTime(), pbInfo.getRankId(), pbInfo.getPartyId(), pbInfo.getPartyName());
            Map<Integer, WarRankInfo> map = warRankRecords.get(info.getDateTime());
            if (map == null) {
                map = new HashMap<Integer, WarRankInfo>();
                warRankRecords.put(info.getDateTime(), map);
            }
            map.put(info.getRank(), info);
        }
    }

    private byte[] serMail() {
        SerMail.Builder ser = SerMail.newBuilder();
        Iterator<Mail> it = mails.iterator();
        while (it.hasNext()) {
            ser.addMail(PbHelper.createMailPb(it.next()));
        }
        return ser.build().toByteArray();
    }

    private byte[] serWarRecord() {
        SerWarRecord.Builder ser = SerWarRecord.newBuilder();
        ser.addAllWarRecord(warRecord);
        return ser.build().toByteArray();
    }

    private byte[] serGetWinRank() {
        SerOneLong.Builder ser = SerOneLong.newBuilder();
        ser.addAllV(getWinRank);
        return ser.build().toByteArray();
    }

    private byte[] serWinRank() {
        SerOneLong.Builder ser = SerOneLong.newBuilder();
        ser.addAllV(winRank);
        return ser.build().toByteArray();
    }

    private String serShop() {
        JSONArray array = new JSONArray();
        for (Integer v : shop) {
            array.add(v);
        }
        return array.toString();
    }

    private byte[] serHurtRank(boolean isHefu) {
        SerOneLong.Builder ser = SerOneLong.newBuilder();

        //由于以前人偷懒  导致合服的时候 会去加载全部的 applicationContext.xml 导致报错 合服的时候不需要合并此字段
        if (!isHefu) {
            List<BossFight> list = (GameServer.ac.getBean(BossDataManager.class)).getHurtRankList();
            hurtRank.clear();

            for (BossFight bossFight : list) {
                hurtRank.add(bossFight.getLordId());
            }
        }

        ser.addAllV(hurtRank);
        return ser.build().toByteArray();
    }

    private byte[] serGetHurtRank() {
        SerOneLong.Builder ser = SerOneLong.newBuilder();
        ser.addAllV(getHurtRank);
        return ser.build().toByteArray();
    }

    private byte[] serScoreRank() {
        SerSeniorScore.Builder ser = SerSeniorScore.newBuilder();
        for (SeniorScoreRank one : scoreRank) {
            ser.addSeniorScore(one.ser());
        }
        return ser.build().toByteArray();
    }

    private byte[] serScorePartyRank() {
        SerSeniorPartyScore.Builder ser = SerSeniorPartyScore.newBuilder();
        for (SeniorPartyScoreRank one : scorePartyRank) {
            ser.addSeniorPartyScore(one.ser());
        }

        return ser.build().toByteArray();
    }

    private void dserWarRecord(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerWarRecord ser = SerWarRecord.parseFrom(data);
        warRecord.addAll(ser.getWarRecordList());
    }

    private void dserGetWinRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerOneLong ser = SerOneLong.parseFrom(data);
        getWinRank.addAll(ser.getVList());
    }

    private void dserWinRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerOneLong ser = SerOneLong.parseFrom(data);
        winRank.addAll(ser.getVList());
    }

    private void dserShop(String data) throws InvalidProtocolBufferException {
        if (data == null || data.equals("")) {
            return;
        }
        JSONArray json = JSONArray.parseArray(data);
        for (int i = 0; i < json.size(); i++) {
            shop.add(json.getInteger(i));
        }
    }

    private void dserHurtRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerOneLong ser = SerOneLong.parseFrom(data);
        hurtRank.addAll(ser.getVList());
    }

    private void dserGetHurtRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerOneLong ser = SerOneLong.parseFrom(data);
        getHurtRank.addAll(ser.getVList());
    }

    private void dserScoreRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerSeniorScore ser = SerSeniorScore.parseFrom(data);
        for (SeniorScore one : ser.getSeniorScoreList()) {
            scoreRank.add(new SeniorScoreRank(one));
        }

    }

    private void dserScorePartyRank(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }

        SerSeniorPartyScore ser = SerSeniorPartyScore.parseFrom(data);
        for (SeniorPartyScore one : ser.getSeniorPartyScoreList()) {
            scorePartyRank.add(new SeniorPartyScoreRank(one));
        }
    }

    private void dserMail(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerMail serMail = SerMail.parseFrom(data);
        List<CommonPb.Mail> list = serMail.getMailList();
        for (CommonPb.Mail e : list) {
            Mail mail = new Mail();
            mail.setKeyId(e.getKeyId());
            if (e.hasTitle()) {
                mail.setTitle(e.getTitle());
            }

            if (e.hasContont()) {
                mail.setContont(e.getContont());
            }

            if (e.hasSendName()) {
                mail.setSendName(e.getSendName());
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

            mails.add(mail);
        }
    }

    public static void dserWorldStaffing(byte[] data, WorldStaffing worldStaffing) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        CommonPb.WorldStaffing worldStaffingPb = CommonPb.WorldStaffing.parseFrom(data);
        worldStaffing.setExp(worldStaffingPb.getExp());
    }


    public void dserHonourTotalData(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerHonourTotalData honourData = SerHonourTotalData.parseFrom(data);
        this.honourOpenTime = honourData.getOpenTime();
        this.honourPhase = honourData.getPhase();
        List<TwoInt> list = honourData.getPointsList();
        for (TwoInt value : list) {
            this.points.add(new Tuple<Integer, Integer>(value.getV1(), value.getV2()));
        }
        List<HonourScore> partyScoreList = honourData.getPartyScoreList();
        for (HonourScore score : partyScoreList) {
            this.partyScore.put(score.getPartyId(), new HonourPartyScore(score));
        }

        playerRankAward.addAll(honourData.getPlayerRankAwardList());
        partyRankAward.addAll(honourData.getPartyRankAwardList());

    }

    public static byte[] serWorldStaffing(WorldStaffing w) {
        CommonPb.WorldStaffing.Builder builder = CommonPb.WorldStaffing.newBuilder();
        builder.setExp(w.getExp());
        return builder.build().toByteArray();
    }

    public byte[] serHonourTotalData() {
        SerHonourTotalData.Builder builder = SerHonourTotalData.newBuilder();
        builder.setOpenTime(honourOpenTime);
        builder.setPhase(honourPhase);
        for (Tuple<Integer, Integer> tuple : points) {
            TwoInt twoInt = PbHelper.createTwoIntPb(tuple.getA(), tuple.getB());
            builder.addPoints(twoInt);
        }
        for (HonourPartyScore score : partyScore.values()) {
            com.game.pb.CommonPb.HonourScore s = PbHelper.createHonourPartyScore(score);
            builder.addPartyScore(s);
        }
        builder.addAllPartyRankAward(partyRankAward);
        builder.addAllPlayerRankAward(playerRankAward);
        return builder.build().toByteArray();
    }

    public int maxKey() {
        return ++maxKey;
    }

    public LinkedList<WarRecord> getWarRecord() {
        return warRecord;
    }

    public void setWarRecord(LinkedList<WarRecord> warRecord) {
        this.warRecord = warRecord;
    }

    public Set<Long> getGetWinRank() {
        return getWinRank;
    }

    public void setGetWinRank(Set<Long> getWinRank) {
        this.getWinRank = getWinRank;
    }

    public int getBossTime() {
        return bossTime;
    }

    public void setBossTime(int bossTime) {
        this.bossTime = bossTime;
    }

    public int getBossState() {
        return bossState;
    }

    public void setBossState(int bossState) {
        this.bossState = bossState;
    }

    public String getBossKiller() {
        return bossKiller;
    }

    public void setBossKiller(String bossKiller) {
        this.bossKiller = bossKiller;
    }

    public int getSeniorState() {
        return seniorState;
    }

    public void setSeniorState(int seniorState) {
        this.seniorState = seniorState;
    }

    public Map<Integer, Map<Integer, WarRankInfo>> getWarRankRecords() {
        return warRankRecords;
    }

    public void setWarRankRecords(Map<Integer, Map<Integer, WarRankInfo>> warRankRecords) {
        this.warRankRecords = warRankRecords;
    }

    public int getFortressState() {
        return fortressState;
    }

    public void setFortressState(int fortressState) {
        this.fortressState = fortressState;
    }

    public int getFortressPartyId() {
        return fortressPartyId;
    }

    public void setFortressPartyId(int fortressPartyId) {
        this.fortressPartyId = fortressPartyId;
    }

    public LinkedHashMap<Integer, FortressRecord> getFortressRecords() {
        return fortressRecords;
    }

    public void setFortressRecords(LinkedHashMap<Integer, FortressRecord> fortressRecords) {
        this.fortressRecords = fortressRecords;
    }

    public Map<Integer, RptAtkFortress> getRptRtkFortresss() {
        return rptRtkFortresss;
    }

    public void setRptRtkFortresss(Map<Integer, RptAtkFortress> rptRtkFortresss) {
        this.rptRtkFortresss = rptRtkFortresss;
    }

    public Map<Long, MyFortressFightData> getMyFortressFightDatas() {
        return myFortressFightDatas;
    }

    public void setMyFortressFightDatas(Map<Long, MyFortressFightData> myFortressFightDatas) {
        this.myFortressFightDatas = myFortressFightDatas;
    }

    public LinkedHashMap<Integer, MyPartyStatistics> getPartyStatisticsMap() {
        return partyStatisticsMap;
    }

    public List<FortressJobAppoint> getFortressJobAppointList() {
        return fortressJobAppointList;
    }

    public int getDrillStatus() {
        return drillStatus;
    }

    public void setDrillStatus(int drillStatus) {
        this.drillStatus = drillStatus;
    }

    public int getLastOpenDrillDate() {
        return lastOpenDrillDate;
    }

    public void setLastOpenDrillDate(int lastOpenDrillDate) {
        this.lastOpenDrillDate = lastOpenDrillDate;
    }

    public Map<Integer, LinkedHashMap<Long, DrillRank>> getDrillRank() {
        return drillRank;
    }

    public void setDrillRank(Map<Integer, LinkedHashMap<Long, DrillRank>> drillRank) {
        this.drillRank = drillRank;
    }

    public Map<Integer, LinkedHashMap<Integer, DrillRecord>> getDrillRecords() {
        return drillRecords;
    }

    public void setDrillRecords(Map<Integer, LinkedHashMap<Integer, DrillRecord>> drillRecords) {
        this.drillRecords = drillRecords;
    }

    public Map<Integer, RptAtkFortress> getDrillFightRpts() {
        return drillFightRpts;
    }

    public void setDrillFightRpts(Map<Integer, RptAtkFortress> drillFightRpts) {
        this.drillFightRpts = drillFightRpts;
    }

    public Map<Integer, DrillResult> getDrillResult() {
        return drillResult;
    }

    public void setDrillResult(Map<Integer, DrillResult> drillResult) {
        this.drillResult = drillResult;
    }

    public int getRedExploit() {
        return redExploit;
    }

    public void setRedExploit(int redExploit) {
        this.redExploit = redExploit;
    }

    public int getBlueExploit() {
        return blueExploit;
    }

    public void setBlueExploit(int blueExploit) {
        this.blueExploit = blueExploit;
    }

    public int getDrillWinner() {
        return drillWinner;
    }

    public void setDrillWinner(int drillWinner) {
        this.drillWinner = drillWinner;
    }

    public Map<Integer, DrillImproveInfo> getDrillRedImprove() {
        return drillRedImprove;
    }

    public void setDrillRedImprove(Map<Integer, DrillImproveInfo> drillRedImprove) {
        this.drillRedImprove = drillRedImprove;
    }

    public Map<Integer, DrillImproveInfo> getDrillBlueImprove() {
        return drillBlueImprove;
    }

    public void setDrillBlueImprove(Map<Integer, DrillImproveInfo> drillBlueImprove) {
        this.drillBlueImprove = drillBlueImprove;
    }

    public Map<Integer, DrillShopBuy> getDrillShop() {
        return drillShop;
    }

    public void setDrillShop(Map<Integer, DrillShopBuy> drillShop) {
        this.drillShop = drillShop;
    }

    public int getRefreshDrillShopDate() {
        return refreshDrillShopDate;
    }

    public void setRefreshDrillShopDate(int refreshDrillShopDate) {
        this.refreshDrillShopDate = refreshDrillShopDate;
    }

    public Map<Integer, Rebel> getRebelMap() {
        return rebelMap;
    }

    public void setRebelMap(Map<Integer, Rebel> rebelMap) {
        this.rebelMap = rebelMap;
    }

    public List<Long> getRebelLastWeekRankList() {
        return rebelLastWeekRankList;
    }

    public void setRebelLastWeekRankList(List<Long> rebelLastWeekRankList) {
        this.rebelLastWeekRankList = rebelLastWeekRankList;
    }

    public Set<Long> getRebelRewardSet() {
        return rebelRewardSet;
    }

    public void setRebelRewardSet(Set<Long> rebelRewardSet) {
        this.rebelRewardSet = rebelRewardSet;
    }

    public Map<Integer, Integer> getRebelHeroDropMap() {
        return rebelHeroDropMap;
    }

    public void setRebelHeroDropMap(Map<Integer, Integer> rebelHeroDropMap) {
        this.rebelHeroDropMap = rebelHeroDropMap;
    }

    public Map<Integer, Integer> getRebelTypeDropMap() {
        return rebelTypeDropMap;
    }

    public void setRebelTypeDropMap(Map<Integer, Integer> rebelTypeDropMap) {
        this.rebelTypeDropMap = rebelTypeDropMap;
    }

    public int getRebelStatus() {
        return rebelStatus;
    }

    public void setRebelStatus(int rebelStatus) {
        this.rebelStatus = rebelStatus;
    }

    public int getRebelLastOpenTime() {
        return rebelLastOpenTime;
    }

    public void setRebelLastOpenTime(int rebelLastOpenTime) {
        this.rebelLastOpenTime = rebelLastOpenTime;
    }

    public int getRebelLastWeekRankDate() {
        return rebelLastWeekRankDate;
    }

    public void setRebelLastWeekRankDate(int rebelLastWeekRankDate) {
        this.rebelLastWeekRankDate = rebelLastWeekRankDate;
    }

    public Map<Integer, Mine> getWorldMineInfo() {
        return worldMineInfo;
    }

    public int getGameStopTime() {
        return gameStopTime;
    }

    public void setGameStopTime(int gameStopTime) {
        this.gameStopTime = gameStopTime;
    }

    public Map<Integer, Airship> getAirshipMap() {
        return airshipMap;
    }

    public Map<Long, PlayerAirship> getPlayerAirshipMap() {
        return playerAirshipMap;
    }

    public LuckyGlobalInfo getLuckyGlobalInfo() {
        return luckyGlobalInfo;
    }

    public void setLuckyGlobalInfo(LuckyGlobalInfo luckyGlobalInfo) {
        this.luckyGlobalInfo = luckyGlobalInfo;
    }

    public Map<Integer, Integer> getBoxDropTime() {
        return boxDropTime;
    }

    public void setBoxDropTime(Map<Integer, Integer> boxDropTime) {
        this.boxDropTime = boxDropTime;
    }

    public Map<Integer, Integer> getBoxLeftCount() {
        return boxLeftCount;
    }

    public void setBoxLeftCount(Map<Integer, Integer> boxLeftCount) {
        this.boxLeftCount = boxLeftCount;
    }

    public List<Integer> getRebelLastWeekPartyRank() {
        return lastWeekPartyRank;
    }

    public Set<Long> getPartyRewardSet() {
        return partyRewardSet;
    }

    public LinkedList<PartyRebelData> getRebelPartyInfo() {
        return rebelPartyInfo;
    }

    public TeamTask getTeamTask() {
        return teamTask;
    }

    public void setTeamTask(TeamTask teamTask) {
        this.teamTask = teamTask;
    }

    public int getHonourOpenTime() {
        return honourOpenTime;
    }

    public void setHonourOpenTime(int honourOpenTime) {
        this.honourOpenTime = honourOpenTime;
    }

    public int getHonourPhase() {
        return honourPhase;
    }

    public void setHonourPhase(int honourPhase) {
        this.honourPhase = honourPhase;
    }

    public List<Tuple<Integer, Integer>> getPoints() {
        return points;
    }

    public void setPoints(List<Tuple<Integer, Integer>> points) {
        this.points = points;
    }

    public WorldStaffing getWorldStaffing() {
        return worldStaffing;
    }

    public void setWorldStaffing(WorldStaffing worldStaffing) {
        this.worldStaffing = worldStaffing;
    }


    public Map<Long, Map<Integer, List<com.game.domain.p.Award>>> getNotGetMap() {
        return notGetMap;
    }

    public void setNotGetMap(Map<Long, Map<Integer, List<com.game.domain.p.Award>>> notGetMap) {
        this.notGetMap = notGetMap;
    }

    /**
     * 直接加入玩家的未领奖map里
     *
     * @param lordId
     * @param type
     * @param list
     */
    public void addNotGet(long lordId, int type, List<com.game.domain.p.Award> list) {
        Map<Integer, List<com.game.domain.p.Award>> map = new HashMap<>();
        notGetMap.put(lordId, map);
        map.put(type, list);
    }

    public void removeNotGet(Long lordId, int type) {
        Map<Integer, List<com.game.domain.p.Award>> map = notGetMap.get(lordId);
        if (map == null || map.isEmpty()) {
            return;
        }
        map.remove(type);
    }

    public Map<Long, Map<Integer, List<com.game.domain.p.Award>>> getNotGetAwardMap() {
        return notGetMap;
    }

    /**
     * @return
     */
    private byte[] serNotGetAward() {
        SerNotGetAward.Builder builder = SerNotGetAward.newBuilder();
        Iterator<Entry<Long, Map<Integer, List<com.game.domain.p.Award>>>> playerIt = notGetMap.entrySet().iterator();
        while (playerIt.hasNext()) {
            Entry<Long, Map<Integer, List<com.game.domain.p.Award>>> playerEntry = playerIt.next();
            long lordId = playerEntry.getKey();
            Map<Integer, List<com.game.domain.p.Award>> map = playerEntry.getValue();
            Iterator<Entry<Integer, List<com.game.domain.p.Award>>> awardIt = map.entrySet().iterator();
            while (awardIt.hasNext()) {
                Entry<Integer, List<com.game.domain.p.Award>> awardEntry = awardIt.next();

                List<com.game.pb.CommonPb.Award> list = PbHelper.createAwardListPb(awardEntry.getValue());

                NotGetAward.Builder nBuilder = NotGetAward.newBuilder();
                nBuilder.setLordId(lordId);
                nBuilder.setType(awardEntry.getKey());
                nBuilder.addAllAward(list);

                builder.addAward(nBuilder);
            }
        }
        return builder.build().toByteArray();
    }


    public byte[] serPersonKingInfo() {
        CommonPb.PersonKingInfo.Builder builder = CommonPb.PersonKingInfo.newBuilder();
        builder.setVersion(kingInfo.getVersion());

        {
            List<PersonRankInfo> killInfo = new ArrayList<>(kingInfo.getKillInfo().values());
            for (PersonRankInfo info : killInfo) {
                CommonPb.PersonRankInfo.Builder b = CommonPb.PersonRankInfo.newBuilder();
                b.setLordId(info.getLordId());
                b.setPoints(info.getPoints());
                b.setTotalNumber(info.getTotalNumber());
                b.setTime(info.getTime());
                builder.addKillInfo(b);
            }
        }


        {
            List<PersonRankInfo> sourceInfo =  new ArrayList<>(kingInfo.getSourceInfo().values());
            for (PersonRankInfo info : sourceInfo) {
                CommonPb.PersonRankInfo.Builder b = CommonPb.PersonRankInfo.newBuilder();
                b.setLordId(info.getLordId());
                b.setPoints(info.getPoints());
                b.setTotalNumber(info.getTotalNumber());
                b.setTime(info.getTime());
                builder.addSourceInfo(b);
            }
        }

        {
            List<PersonRankInfo> creditInfo = new ArrayList<>(kingInfo.getCreditInfo().values());
            for (PersonRankInfo info : creditInfo) {
                CommonPb.PersonRankInfo.Builder b = CommonPb.PersonRankInfo.newBuilder();
                b.setLordId(info.getLordId());
                b.setPoints(info.getPoints());
                b.setTotalNumber(info.getTotalNumber());
                b.setTime(info.getTime());
                builder.addCreditInfo(b);
            }
        }


        {
            List<PersonRankInfo> totalKillInfo = new ArrayList<>(kingInfo.getTotalKillInfo().values());
            for (PersonRankInfo info : totalKillInfo) {
                CommonPb.PersonRankInfo.Builder b = CommonPb.PersonRankInfo.newBuilder();
                b.setLordId(info.getLordId());
                b.setPoints(info.getPoints());
                b.setTotalNumber(info.getTotalNumber());
                b.setTime(info.getTime());
                builder.addTotalKillInfo(b);
            }
        }


        {
            List<PartyRankInfo> partyInfo =  new ArrayList<>(kingInfo.getPartyInfo().values());
            for (PartyRankInfo info : partyInfo) {
                CommonPb.PartyRankInfo.Builder b = CommonPb.PartyRankInfo.newBuilder();
                b.setPartyId(info.getPartyId());
                b.setPoints(info.getPoints());
                b.setTime(info.getTime());
                builder.addPartyInfo(b);
            }
        }

        return builder.build().toByteArray();
    }


    public void dserPersonKingInfo(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        CommonPb.PersonKingInfo personKingInfo = CommonPb.PersonKingInfo.parseFrom(data);
        kingInfo.setVersion(personKingInfo.getVersion());

        {
            List<CommonPb.PersonRankInfo> killInfoList = personKingInfo.getKillInfoList();
            for (CommonPb.PersonRankInfo killInfo : killInfoList) {
                PersonRankInfo info = new PersonRankInfo();
                info.setLordId(killInfo.getLordId());
                info.setTotalNumber(killInfo.getTotalNumber());
                info.setPoints(killInfo.getPoints());
                info.setTime(killInfo.getTime());
                kingInfo.getKillInfo().put(info.getLordId(),info);
            }
        }

        {
            List<CommonPb.PersonRankInfo> sourceInfoList = personKingInfo.getSourceInfoList();
            for (CommonPb.PersonRankInfo sourceInfo : sourceInfoList) {
                PersonRankInfo info = new PersonRankInfo();
                info.setLordId(sourceInfo.getLordId());
                info.setTotalNumber(sourceInfo.getTotalNumber());
                info.setPoints(sourceInfo.getPoints());
                info.setTime(sourceInfo.getTime());
                kingInfo.getSourceInfo().put(info.getLordId(),info);
            }
        }


        {


            List<CommonPb.PersonRankInfo> creditInfoList = personKingInfo.getCreditInfoList();
            for (CommonPb.PersonRankInfo creditInfo : creditInfoList) {
                PersonRankInfo info = new PersonRankInfo();
                info.setLordId(creditInfo.getLordId());
                info.setTotalNumber(creditInfo.getTotalNumber());
                info.setPoints(creditInfo.getPoints());
                info.setTime(creditInfo.getTime());
                kingInfo.getCreditInfo().put(info.getLordId(),info);
            }
        }

        {


            List<CommonPb.PersonRankInfo> totalKillInfoList = personKingInfo.getTotalKillInfoList();
            for (CommonPb.PersonRankInfo totalKillInfo : totalKillInfoList) {
                PersonRankInfo info = new PersonRankInfo();
                info.setLordId(totalKillInfo.getLordId());
                info.setTotalNumber(totalKillInfo.getTotalNumber());
                info.setPoints(totalKillInfo.getPoints());
                info.setTime(totalKillInfo.getTime());
                kingInfo.getTotalKillInfo().put(info.getLordId(),info);
            }
        }


        {

            List<CommonPb.PartyRankInfo> partyInfoList = personKingInfo.getPartyInfoList();
            for (CommonPb.PartyRankInfo killInfo : partyInfoList) {
                PartyRankInfo info = new PartyRankInfo();
                info.setPartyId(killInfo.getPartyId());
                info.setPoints(killInfo.getPoints());
                info.setTime(killInfo.getTime());
                kingInfo.getPartyInfo().put(info.getPartyId(),info);
            }
        }


    }

    public PersonKingInfo getKingInfo() {
        return kingInfo;
    }
}
