package com.game.domain;

import com.alibaba.fastjson.JSONArray;
import com.game.domain.l.PartyJobFree;
import com.game.domain.p.*;
import com.game.domain.p.airship.AirshipGuard;
import com.game.domain.p.airship.AirshipTeam;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.WarRecord;
import com.game.pb.SerializePb;
import com.game.pb.SerializePb.*;
import com.game.util.*;
import com.google.protobuf.InvalidProtocolBufferException;
import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;
import com.hundredcent.game.aop.domain.IPartySave;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午4:05:25
 * @declare
 */
@SaveOptimize(level = SaveLevel.IMMEDIATE_PARTY)
public class PartyData implements IPartySave {
    private int partyId;
    private String partyName;
    private String legatusName;
    private int partyLv;
    private int scienceLv;
    private int wealLv;
    private int lively;
    private int build;
    private long fight;
    private int apply;
    private int applyLv;
    private long applyFight;
    private String slogan;
    private String innerSlogan;
    private String jobName1;
    private String jobName2;
    private String jobName3;
    private String jobName4;
    private int refreshTime;
    private int rank;
    private Weal reportMine = new Weal();
    private Map<Integer, PartyScience> sciences = new HashMap<>();
    private Map<Long, PartyApply> applys = new HashMap<>();
    private LinkedList<Trend> trends = new LinkedList<>();
    private Map<Integer, PartyCombat> partyCombats = new HashMap<>();
    private Map<Integer, LiveTask> liveTasks = new HashMap<>();
    private Map<Integer, Activity> activitys = new HashMap<>();
    private Map<Integer, Prop> amyProps = new HashMap<>();
    private List<Integer> shopProps = new ArrayList<>();
    // 每日捐献数据，key：1军团大厅，2军团科技 ；value：捐赠者roleId
    private Map<Integer, List<Long>> donates = new HashMap<>();

    private LinkedList<WarRecord> warRecords = new LinkedList<>();
    private int regLv;
    private int warRank;
    private long regFight;
    private int score;

    private int lastSaveTime;

    private int altarLv;// 军团祭坛的等级
    private int nextCallBossSec;// 下一次可以召唤祭坛BOSS的时间（CD结束时间），毫秒数/1000
    private int bossLv;// 祭坛BOSS的等级
    private int bossState;// 祭坛BOSS的状态
    private int bossWhich;// 祭坛BOSS当前是第几管血
    private int bossHp;// 祭坛BOSS当前血量万分比
    private List<Long> bossHurtRankList = new ArrayList<>();// 祭坛BOSS伤害排行
    private List<Long> bossAwardList = new ArrayList<>();// 祭坛BOSS排行奖励，已领取奖励的玩家记录
    private int shopTime;//军团商店 上次全局刷新时间

    private Map<Integer, AirshipTeam> airshipTeamMap = new TreeMap<>();//飞艇队伍
    private Map<Integer, AirshipGuard> airshipGuardMap = new TreeMap<>();//飞艇驻军
    private Map<Integer, Long> airshipLeaderMap = new HashMap<>();//飞艇拥有者
    private Map<Integer, PartyJobFree> freeMap = new HashMap<>();
    private long teamRecharge;//军团累计充值金币量
    private int altarBossExp;//祭壇Boss的經驗值

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public void setLastSaveTime(int lastSaveTime) {
        this.lastSaveTime = lastSaveTime;
    }

    public int getLastSaveTime() {
        return lastSaveTime;
    }

    public String getPartyName() {
        return partyName;
    }

    public void setPartyName(String partyName) {
        this.partyName = partyName;
    }

    public String getLegatusName() {
        return legatusName;
    }

    public void setLegatusName(String legatusName) {
        this.legatusName = legatusName;
    }

    public int getPartyLv() {
        return partyLv;
    }

    public void setPartyLv(int partyLv) {
        this.partyLv = partyLv;
    }

    public int getScienceLv() {
        return scienceLv;
    }

    public void setScienceLv(int scienceLv) {
        this.scienceLv = scienceLv;
    }

    public int getWealLv() {
        return wealLv;
    }

    public void setWealLv(int wealLv) {
        this.wealLv = wealLv;
    }

    public int getLively() {
        return lively;
    }

    public void setLively(int lively) {
        this.lively = lively;
    }

    public int getBuild() {
        return build;
    }

    public void setBuild(int build) {
        this.build = build;
    }

    public int getApply() {
        return apply;
    }

    public void setApply(int apply) {
        this.apply = apply;
    }

    public int getApplyLv() {
        return applyLv;
    }

    public void setApplyLv(int applyLv) {
        this.applyLv = applyLv;
    }

    public String getSlogan() {
        return slogan;
    }

    public void setSlogan(String slogan) {
        this.slogan = slogan;
    }

    public String getInnerSlogan() {
        return innerSlogan;
    }

    public void setInnerSlogan(String innerSlogan) {
        this.innerSlogan = innerSlogan;
    }

    public String getJobName1() {
        return jobName1;
    }

    public void setJobName1(String jobName1) {
        this.jobName1 = jobName1;
    }

    public String getJobName2() {
        return jobName2;
    }

    public void setJobName2(String jobName2) {
        this.jobName2 = jobName2;
    }

    public String getJobName3() {
        return jobName3;
    }

    public void setJobName3(String jobName3) {
        this.jobName3 = jobName3;
    }

    public String getJobName4() {
        return jobName4;
    }

    public void setJobName4(String jobName4) {
        this.jobName4 = jobName4;
    }

    public int getRefreshTime() {
        return refreshTime;
    }

    public void setRefreshTime(int refreshTime) {
        this.refreshTime = refreshTime;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public Weal getReportMine() {
        return reportMine;
    }

    public void setReportMine(Weal reportMine) {
        this.reportMine = reportMine;
    }

    public Map<Integer, PartyScience> getSciences() {
        return sciences;
    }

    public void setSciences(Map<Integer, PartyScience> sciences) {
        this.sciences = sciences;
    }

    public Map<Long, PartyApply> getApplys() {
        return applys;
    }

    public void setApplys(Map<Long, PartyApply> applys) {
        this.applys = applys;
    }

    public LinkedList<Trend> getTrends() {
        return trends;
    }

    public void setTrends(LinkedList<Trend> trends) {
        this.trends = trends;
    }

    public Map<Integer, PartyCombat> getPartyCombats() {
        return partyCombats;
    }

    public void setPartyCombats(Map<Integer, PartyCombat> partyCombats) {
        this.partyCombats = partyCombats;
    }

    public long getFight() {
        return fight;
    }

    @SaveOptimize(level = SaveLevel.NEVER)
    public void setFight(long fight) {
        this.fight = fight;
    }

    public long getApplyFight() {
        return applyFight;
    }

    public void setApplyFight(long applyFight) {
        this.applyFight = applyFight;
    }

    public Map<Integer, Activity> getActivitys() {
        return activitys;
    }

    public void setActivitys(Map<Integer, Activity> activitys) {
        this.activitys = activitys;
    }

    public Map<Integer, Prop> getAmyProps() {
        return amyProps;
    }

    public void setAmyProps(Map<Integer, Prop> amyProps) {
        this.amyProps = amyProps;
    }

    public List<Integer> getShopProps() {
        return shopProps;
    }

    public void setShopProps(List<Integer> shopProps) {
        this.shopProps = shopProps;
    }

    public List<Long> getDonates(int type) {
        return donates.get(type);
    }

    public void putDonates(int key, List<Long> donateList) {
        this.donates.put(key, donateList);
    }

    public Map<Integer, List<Long>> getDonates() {
        return donates;
    }

    /**
     * @param stone
     * @param iron
     * @param copper
     * @param silicon
     * @param oil
     */
    public void addMine(int stone, int iron, int copper, int silicon, int oil) {
        reportMine.setStone(reportMine.getStone() + stone);
        reportMine.setIron(reportMine.getIron() + iron);
        reportMine.setCopper(reportMine.getCopper() + copper);
        reportMine.setSilicon(reportMine.getSilicon() + silicon);
        reportMine.setOil(reportMine.getOil() + oil);
    }

    public byte[] serMine() {
        SerWeal.Builder ser = SerWeal.newBuilder();
        ser.setWeal(PbHelper.createWealPb(reportMine));
        return ser.build().toByteArray();
    }

    public void dserMine(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerWeal ser = SerWeal.parseFrom(data);
        CommonPb.Weal e = ser.getWeal();
        reportMine.setStone(e.getStone());
        reportMine.setIron(e.getIron());
        reportMine.setCopper(e.getCopper());
        reportMine.setSilicon(e.getSilicon());
        reportMine.setOil(e.getOil());
    }

    public byte[] serScience() {
        SerScience.Builder ser = SerScience.newBuilder();
        Iterator<PartyScience> it = sciences.values().iterator();
        while (it.hasNext()) {
            ser.addScience(PbHelper.createPartySciencePb(it.next()));
        }
        return ser.build().toByteArray();
    }

    public void dserScience(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerScience ser = SerScience.parseFrom(data);
        List<CommonPb.Science> list = ser.getScienceList();
        for (CommonPb.Science e : list) {
            PartyScience science = new PartyScience(e.getScienceId(), e.getScienceLv());
            science.setSchedule(e.getSchedule());
            sciences.put(e.getScienceId(), science);
        }
    }

    public byte[] serActivity() {
        SerDbActivity.Builder ser = SerDbActivity.newBuilder();
        Iterator<Activity> it = activitys.values().iterator();
        while (it.hasNext()) {
            ser.addDbActivity(PbHelper.createDbActivityPb(it.next()));
        }
        return ser.build().toByteArray();
    }

    public byte[] serWarRecord() {
        SerWarRecord.Builder ser = SerWarRecord.newBuilder();
        ser.addAllWarRecord(warRecords);
        return ser.build().toByteArray();
    }

    public void dserActivity(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerDbActivity ser = SerDbActivity.parseFrom(data);
        List<CommonPb.DbActivity> list = ser.getDbActivityList();
        for (CommonPb.DbActivity e : list) {
            Activity activity = new Activity();
            activity.setActivityId(e.getActivityId());
            activity.setBeginTime(e.getBeginTime());
            activity.setEndTime(e.getEndTime());
            activity.setOpen(e.getOpen());
            List<Long> statusList = new ArrayList<Long>();
            for (Long ee : e.getStatusList()) {
                statusList.add(ee);
            }
            activity.setStatusList(statusList);
            List<CommonPb.TwoInt> tlist = e.getTowIntList();
            Map<Integer, Integer> statusMap = new HashMap<Integer, Integer>();
            if (tlist != null) {
                for (CommonPb.TwoInt et : tlist) {
                    statusMap.put(et.getV1(), et.getV2());
                }
            }
            activity.setStatusMap(statusMap);
            activitys.put(e.getActivityId(), activity);
        }
    }

    public void dserWarRecord(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerWarRecord ser = SerWarRecord.parseFrom(data);
        warRecords.addAll(ser.getWarRecordList());
    }

    public byte[] serTrend() {
        SerDbTrend.Builder ser = SerDbTrend.newBuilder();
        Iterator<Trend> it = trends.iterator();
        while (it.hasNext()) {
            Trend trend = it.next();
            ser.addDbTrend(PbHelper.createDbTrendPb(trend));
        }
        return ser.build().toByteArray();
    }

    public void dserTrend(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerDbTrend ser = SerDbTrend.parseFrom(data);
        List<CommonPb.DbTrend> list = ser.getDbTrendList();
        if (list != null && list.size() > 0) {
            for (CommonPb.DbTrend e : list) {
                Trend trend = new Trend(e.getTrendId(), e.getTrendTime());
                List<String> paramList = e.getParamList();
                if (paramList != null && paramList.size() > 0) {
                    int size = paramList.size();
                    String[] param = new String[paramList.size()];
                    for (int i = 0; i < size; i++) {
                        param[i] = paramList.get(i);
                    }
                    trend.setParam(param);
                }
                trends.add(trend);
            }
        }
    }

    public byte[] serAmyProps() {
        SerProp.Builder ser = SerProp.newBuilder();
        Iterator<Prop> it = amyProps.values().iterator();
        while (it.hasNext()) {
            Prop prop = it.next();
            ser.addProp(PbHelper.createPropPb(prop));
        }
        return ser.build().toByteArray();
    }

    public void dserAmyProps(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerProp ser = SerProp.parseFrom(data);
        List<CommonPb.Prop> list = ser.getPropList();
        if (list != null && list.size() > 0) {
            for (CommonPb.Prop e : list) {
                Prop prop = new Prop(e.getPropId(), e.getCount());
                amyProps.put(prop.getPropId(), prop);
            }
        }
    }

    public String serShopProps() {
        JSONArray jsonArray = new JSONArray();
        for (Integer shopId : shopProps) {
            jsonArray.add(shopId);
        }
        return jsonArray.toString();
    }

    public void dserShopProps(String shopProp) throws InvalidProtocolBufferException {
        if (shopProp == null || shopProp.equals("") || !shopProp.startsWith("[") || !shopProp.endsWith("]")) {
            shopProps.add(0);
            shopProps.add(0);
            shopProps.add(0);
        } else {
            JSONArray array = JSONArray.parseArray(shopProp);
            for (int i = 0; i < array.size(); i++) {
                shopProps.add(array.getInteger(i));
            }
        }
    }

    public byte[] serDonates() {
        SerTwoValue.Builder ser = SerTwoValue.newBuilder();
        List<Long> hallList = donates.get(1);
        if (hallList != null) {
            for (Long lordId : hallList) {
                ser.addTwoValue(PbHelper.createTwoValuePb(1, lordId));
            }
        }
        List<Long> scienceList = donates.get(2);
        if (scienceList != null) {
            for (Long lordId : scienceList) {
                ser.addTwoValue(PbHelper.createTwoValuePb(2, lordId));
            }
        }
        return ser.build().toByteArray();
    }

    public void dserDonates(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerTwoValue ser = SerTwoValue.parseFrom(data);
        List<CommonPb.TwoValue> list = ser.getTwoValueList();
        if (list != null) {
            for (CommonPb.TwoValue e : list) {
                int key = e.getV1();
                List<Long> keyList = donates.get(key);
                if (keyList == null) {
                    keyList = new ArrayList<Long>();
                    donates.put(key, keyList);
                }
                keyList.add(e.getV2());
            }
        }
    }

    public byte[] serPartyCombat() {
        SerPartyCombat.Builder ser = SerPartyCombat.newBuilder();
        Iterator<PartyCombat> it = partyCombats.values().iterator();
        while (it.hasNext()) {
            PartyCombat partyCombat = it.next();
            ser.addPartyCombat(PbHelper.createPartyCombatPb(partyCombat));
        }
        return ser.build().toByteArray();
    }

    public void dserPartyCombat(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerPartyCombat ser = SerPartyCombat.parseFrom(data);
        List<CommonPb.PartyCombat> list = ser.getPartyCombatList();
        for (CommonPb.PartyCombat e : list) {
            PartyCombat partyCombat = new PartyCombat();
            partyCombat.setCombatId(e.getCombatId());
            partyCombat.setSchedule(e.getSchedule());
            CommonPb.Form eForm = e.getForm();
            Form form = PbHelper.createForm(eForm);
            partyCombat.setForm(form);
            partyCombats.put(e.getCombatId(), partyCombat);
        }
    }

    public byte[] serLiveTask() {
        SerLiveTask.Builder ser = SerLiveTask.newBuilder();
        Iterator<LiveTask> it = liveTasks.values().iterator();
        while (it.hasNext()) {
            ser.addLiveTask(PbHelper.createLiveTaskPb(it.next()));
        }
        return ser.build().toByteArray();
    }

    public void dserLiveTask(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerLiveTask ser = SerLiveTask.parseFrom(data);
        List<CommonPb.LiveTask> list = ser.getLiveTaskList();
        for (CommonPb.LiveTask e : list) {
            LiveTask liveTask = new LiveTask();
            liveTask.setTaskId(e.getTaskId());
            liveTask.setCount(e.getCount());
            liveTasks.put(liveTask.getTaskId(), liveTask);
        }
    }

    public byte[] serPartyApply() {
        SerPartyApply.Builder ser = SerPartyApply.newBuilder();
        Iterator<PartyApply> it = applys.values().iterator();
        while (it.hasNext()) {
            ser.addDbPartyApply(PbHelper.createDbPartyApplyPb(it.next()));
        }
        return ser.build().toByteArray();
    }

    public void dserPartyApply(byte[] data) throws InvalidProtocolBufferException {
        if (data == null) {
            return;
        }
        SerPartyApply ser = SerPartyApply.parseFrom(data);
        List<CommonPb.DbPartyApply> list = ser.getDbPartyApplyList();
        for (CommonPb.DbPartyApply e : list) {
            PartyApply partyApply = new PartyApply();
            partyApply.setLordId(e.getLordId());
            partyApply.setApplyDate(e.getApplyDate());
            applys.put(e.getLordId(), partyApply);
        }
    }

    public String serBossHurtRank() {
        JSONArray jsonArray = new JSONArray();
        for (Long lordId : bossHurtRankList) {
            jsonArray.add(lordId);
        }
        return jsonArray.toString();
    }

    public void dserBossHurtRank(String bossHurtRank) {
        if (CheckNull.isNullTrim(bossHurtRank) || !bossHurtRank.startsWith("[") || !bossHurtRank.endsWith("]")) {
            bossHurtRankList.add(0L);
            bossHurtRankList.add(0L);
            bossHurtRankList.add(0L);
        } else {
            JSONArray array = JSONArray.parseArray(bossHurtRank);
            for (int i = 0; i < array.size(); i++) {
                bossHurtRankList.add(array.getLong(i));
            }
        }
    }

    public String serBossAward() {
        JSONArray jsonArray = new JSONArray();
        for (Long lordId : bossAwardList) {
            jsonArray.add(lordId);
        }
        return jsonArray.toString();
    }

    public void dserBossAward(String bossAward) {
        if (CheckNull.isNullTrim(bossAward) || !bossAward.startsWith("[") || !bossAward.endsWith("]")) {
            bossAwardList.add(0L);
            bossAwardList.add(0L);
            bossAwardList.add(0L);
        } else {
            JSONArray array = JSONArray.parseArray(bossAward);
            for (int i = 0; i < array.size(); i++) {
                bossAwardList.add(array.getLong(i));
            }
        }
    }

    private byte[] serAirshipData() {
        SerAirshipData.Builder builder = SerAirshipData.newBuilder();
        for (AirshipTeam team : airshipTeamMap.values()) {
            builder.addAirshipTeam(SerPbHelper.createAirshipTeam(team));
        }
        for (AirshipGuard guard : airshipGuardMap.values()) {
            SerializePb.AirshipGuard.Builder b = SerializePb.AirshipGuard.newBuilder();
            b.setId(guard.getId());
            for (Army army : guard.getArmys()) {
                b.addArmys(PbHelper.createTwoLongPb(army.player.roleId, army.getKeyId()));
            }
            builder.addGuard(b);
        }

        for (Entry<Integer, Long> entry : airshipLeaderMap.entrySet()) {
            builder.addLeaders(PbHelper.createTwoLongPb(entry.getKey(), entry.getValue()));
        }

        //免费集结信息
        for (Entry<Integer, PartyJobFree> entry : freeMap.entrySet()) {
            SerPartyJobFree.Builder pbFree = SerPartyJobFree.newBuilder();
            pbFree.setJob(entry.getKey());
            pbFree.setFree(entry.getValue().getFree());
            pbFree.setFreeDay(entry.getValue().getFreeDay());
            builder.addFree(pbFree);
        }

        return builder.build().toByteArray();
    }

    private void dserAirshipData(byte[] airshipData) throws InvalidProtocolBufferException {
        if (airshipData == null) {
            return;
        }
        SerAirshipData builder = SerAirshipData.parseFrom(airshipData);
        for (AirshipTeamDb team : builder.getAirshipTeamList()) {
            airshipTeamMap.put(team.getId(), new AirshipTeam(team));
        }
        for (SerializePb.AirshipGuard guard : builder.getGuardList()) {
            AirshipGuard g = new AirshipGuard(guard);
            airshipGuardMap.put(g.getId(), g);
        }
        for (CommonPb.TwoLong leader : builder.getLeadersList()) {
            airshipLeaderMap.put((int) leader.getV1(), leader.getV2());
        }
        for (SerPartyJobFree pbFree : builder.getFreeList()) {
            freeMap.put(pbFree.getJob(), new PartyJobFree(pbFree));
        }
    }

    public PartyData(Party party) {
        this.partyId = party.getPartyId();
        this.partyName = party.getPartyName();
        this.legatusName = party.getLegatusName();
        this.partyLv = party.getPartyLv();
        this.scienceLv = party.getScienceLv();
        this.wealLv = party.getWealLv();
        this.lively = party.getLively();
        this.build = party.getBuild();
        this.fight = party.getFight();
        this.apply = party.getApply();
        this.applyLv = party.getApplyLv();
        this.applyFight = party.getApplyFight();
        this.slogan = party.getSlogan();
        this.innerSlogan = party.getInnerSlogan();
        this.jobName1 = party.getJobName1();
        this.jobName2 = party.getJobName2();
        this.jobName3 = party.getJobName3();
        this.jobName4 = party.getJobName4();
        this.refreshTime = party.getRefreshTime();
        this.score = party.getScore();

        this.altarLv = party.getAltarLv();
        this.nextCallBossSec = party.getNextCallBossSec();
        this.bossLv = party.getBossLv();
        this.bossState = party.getBossState();
        this.bossWhich = party.getBossWhich();
        this.bossHp = party.getBossHp();
        this.shopTime = party.getShopTime();
        this.teamRecharge = party.getTeamRecharge();
        this.altarBossExp = party.getAltarBossExp();

        lastSaveTime = TimeHelper.getCurrentSecond() + RandomHelper.randomInSize(180);
        try {
            dserMine(party.getMine());
            dserScience(party.getScience());
            dserActivity(party.getActivity());
            dserPartyApply(party.getApplyList());
            dserTrend(party.getTrend());
            dserAmyProps(party.getAmyProps());
            dserShopProps(party.getShopProps());
            dserPartyCombat(party.getPartyCombat());
            dserLiveTask(party.getLiveTask());
            dserWarRecord(party.getWarRecord());
            dserDonates(party.getDonates());
            dserBossHurtRank(party.getBossHurtRank());
            dserBossAward(party.getBossAward());
            this.regLv = party.getRegLv();
            this.warRank = party.getWarRank();
            this.regFight = party.getRegFight();
            dserAirshipData(party.getAirshipData());
        } catch (InvalidProtocolBufferException e) {
            e.printStackTrace();
        }
    }

    /**
     * Method: copyData
     *
     * @Description: 拷贝数据给保存线程使用 @return @return Party @throws
     */
    public Party copyData() {
        Party party = new Party();
        party.setPartyId(partyId);
        party.setPartyName(partyName);
        party.setLegatusName(legatusName);
        party.setPartyLv(partyLv);
        party.setScienceLv(scienceLv);
        party.setWealLv(wealLv);
        party.setLively(lively);
        party.setBuild(build);
        party.setFight(fight);
        party.setApply(apply);
        party.setApplyLv(applyLv);
        party.setApplyFight(applyFight);
        party.setSlogan(slogan);
        party.setInnerSlogan(innerSlogan);
        party.setJobName1(jobName1);
        party.setJobName2(jobName2);
        party.setJobName3(jobName3);
        party.setJobName4(jobName4);
        party.setRefreshTime(refreshTime);
        party.setMine(serMine());
        party.setScience(serScience());
        party.setActivity(serActivity());
        party.setApplyList(serPartyApply());
        party.setTrend(serTrend());
        party.setAmyProps(serAmyProps());
        party.setShopProps(serShopProps());
        party.setDonates(serDonates());
        party.setPartyCombat(serPartyCombat());
        party.setLiveTask(serLiveTask());
        party.setWarRecord(serWarRecord());
        party.setRegLv(regLv);
        party.setWarRank(warRank);
        party.setRegFight(regFight);
        party.setScore(score);

        party.setAltarLv(altarLv);
        party.setNextCallBossSec(nextCallBossSec);
        party.setBossLv(bossLv);
        party.setBossState(bossState);
        party.setBossWhich(bossWhich);
        party.setBossHp(bossHp);
        party.setBossHurtRank(serBossHurtRank());
        party.setBossAward(serBossAward());
        party.setShopTime(shopTime);
        party.setAirshipData(serAirshipData());
        party.setTeamRecharge(teamRecharge);
        party.setAltarBossExp(altarBossExp);
        return party;
    }

    /**
     * 此方法为强制清除玩家在工会中的残留数据, 相关逻辑判断请在调用此方法前处理<br>
     * eg:玩家如果是飞艇指挥官是不能离开军团的, 请在调用此方法前做逻辑判断<br>
     *
     * @param lordId
     */
    public void clearData(long lordId) {
        try {
            //清除指挥官信息
            Set<Integer> removeSet = new HashSet<>();
            for (Map.Entry<Integer, Long> entry : airshipLeaderMap.entrySet()) {
                if (entry.getValue() == lordId) {
                    removeSet.add(entry.getKey());
                }
            }
            if (!removeSet.isEmpty()) {
                for (Integer key : removeSet) {
                    airshipLeaderMap.remove(key);
                }
                removeSet.clear();
            }

            //清除驻军信息
            for (Entry<Integer, AirshipGuard> entry : airshipGuardMap.entrySet()) {
                AirshipGuard guard = entry.getValue();
                Iterator<Long[]> iter = guard.getArmysDb().iterator();
                while (iter.hasNext()) {
                    Long[] twoLong = iter.next();
                    if (twoLong != null && twoLong.length == 2 && twoLong[0] == lordId) {
                        iter.remove();
                    }
                }

                Iterator<Army> amIter = guard.getArmys().iterator();
                while (amIter.hasNext()) {
                    Army army = amIter.next();
                    if (army != null && army.player != null
                            && army.player.lord.getLordId() == lordId) {
                        amIter.remove();
                    }
                }
            }

            //清除进攻飞艇队伍信息
            for (Entry<Integer, AirshipTeam> entry : airshipTeamMap.entrySet()) {
                AirshipTeam team = entry.getValue();
                if (team.getLordId() == lordId) {
                    removeSet.add(entry.getKey());
                }
                Iterator<Long[]> iter = team.getArmysDb().iterator();
                while (iter.hasNext()) {
                    Long[] twoLong = iter.next();
                    if (twoLong != null && twoLong.length == 2 && twoLong[0] == lordId) {
                        iter.remove();
                    }
                }
                Iterator<Army> amIter = team.getArmys().iterator();
                while (amIter.hasNext()) {
                    Army army = amIter.next();
                    if (army != null && army.player != null
                            && army.player.lord.getLordId() == lordId) {
                        amIter.remove();
                    }
                }
            }
            if (!removeSet.isEmpty()) {
                for (Integer key : removeSet) {
                    airshipTeamMap.remove(key);
                }
                removeSet.clear();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Map<Integer, LiveTask> getLiveTasks() {
        return liveTasks;
    }

    public void setLiveTasks(Map<Integer, LiveTask> liveTasks) {
        this.liveTasks = liveTasks;
    }

    public LinkedList<WarRecord> getWarRecords() {
        return warRecords;
    }

    public void setWarRecords(LinkedList<WarRecord> warRecords) {
        this.warRecords = warRecords;
    }

    public int getRegLv() {
        return regLv;
    }

    public void setRegLv(int regLv) {
        this.regLv = regLv;
    }

    public int getWarRank() {
        return warRank;
    }

    public void setWarRank(int warRank) {
        this.warRank = warRank;
    }

    public long getRegFight() {
        return regFight;
    }

    public void setRegFight(long regFight) {
        this.regFight = regFight;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getAltarLv() {
        return altarLv;
    }

    public void setAltarLv(int altarLv) {
        this.altarLv = altarLv;
    }

    public int getNextCallBossSec() {
        return nextCallBossSec;
    }

    public void setNextCallBossSec(int nextCallBossSec) {
        this.nextCallBossSec = nextCallBossSec;
    }

    public int getBossLv() {
        return bossLv;
    }

    public void setBossLv(int bossLv) {
        this.bossLv = bossLv;
    }

    public int getBossState() {
        return bossState;
    }

    public void setBossState(int bossState) {
        this.bossState = bossState;
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

    public List<Long> getBossHurtRankList() {
        return bossHurtRankList;
    }

    public void setBossHurtRankList(List<Long> bossHurtRankList) {
        this.bossHurtRankList = bossHurtRankList;
    }

    public List<Long> getBossAwardList() {
        return bossAwardList;
    }

    public void setBossAwardList(List<Long> bossAwardList) {
        this.bossAwardList = bossAwardList;
    }

    public int getShopTime() {
        return shopTime;
    }

    public void setShopTime(int shopTime) {
        this.shopTime = shopTime;
    }

    public Map<Integer, AirshipTeam> getAirshipTeamMap() {
        return airshipTeamMap;
    }

    public Map<Integer, AirshipGuard> getAirshipGuardMap() {
        return airshipGuardMap;
    }

    public Map<Integer, Long> getAirshipLeaderMap() {
        return airshipLeaderMap;
    }

    public void setAirshipLeaderMap(Map<Integer, Long> airshipLeaderMap) {
        this.airshipLeaderMap = airshipLeaderMap;
    }

    public Map<Integer, PartyJobFree> getFreeMap() {
        return freeMap;
    }


    public int getAltarBossExp() {
        return altarBossExp;
    }

    public void setAltarBossExp(int altarBossExp) {
        this.altarBossExp = altarBossExp;
    }


    public long getTeamRecharge() {
        return teamRecharge;
    }

    public void setTeamRecharge(long teamRecharge) {
        this.teamRecharge = teamRecharge;
    }

    @Override
    public String toString() {
        return "PartyData{" +
                "partyId=" + partyId +
                ", partyName='" + partyName + '\'' +
                ", legatusName='" + legatusName + '\'' +
                ", partyLv=" + partyLv +
                ", scienceLv=" + scienceLv +
                ", wealLv=" + wealLv +
                ", lively=" + lively +
                ", build=" + build +
                ", fight=" + fight +
                ", apply=" + apply +
                ", applyLv=" + applyLv +
                ", applyFight=" + applyFight +
                ", slogan='" + slogan + '\'' +
                ", innerSlogan='" + innerSlogan + '\'' +
                ", jobName1='" + jobName1 + '\'' +
                ", jobName2='" + jobName2 + '\'' +
                ", jobName3='" + jobName3 + '\'' +
                ", jobName4='" + jobName4 + '\'' +
                ", refreshTime=" + refreshTime +
                ", rank=" + rank +
                ", reportMine=" + reportMine +
                ", sciences=" + sciences +
                ", applys=" + applys +
                ", trends=" + trends +
                ", partyCombats=" + partyCombats +
                ", liveTasks=" + liveTasks +
                ", activitys=" + activitys +
                ", amyProps=" + amyProps +
                ", shopProps=" + shopProps +
                ", donates=" + donates +
                ", warRecords=" + warRecords +
                ", regLv=" + regLv +
                ", warRank=" + warRank +
                ", regFight=" + regFight +
                ", score=" + score +
                ", lastSaveTime=" + lastSaveTime +
                ", altarLv=" + altarLv +
                ", nextCallBossSec=" + nextCallBossSec +
                ", bossLv=" + bossLv +
                ", bossState=" + bossState +
                ", bossWhich=" + bossWhich +
                ", bossHp=" + bossHp +
                ", bossHurtRankList=" + bossHurtRankList +
                ", bossAwardList=" + bossAwardList +
                ", shopTime=" + shopTime +
                ", airshipTeamMap=" + airshipTeamMap +
                ", airshipGuardMap=" + airshipGuardMap +
                ", airshipLeaderMap=" + airshipLeaderMap +
                ", freeMap=" + freeMap +
                ", teamRecharge=" + teamRecharge +
                ", altarBossExp=" + altarBossExp +
                '}';
    }

    @Override
    public long objectId() {
        return partyId;
    }

    @Override
    public boolean refreshImportant() {
        return true;
    }

    @Override
    public int getNextSaveTime() {
        return lastSaveTime;
    }

    @Override
    public void nextSaveTime(int nextSaveTime) {
        this.lastSaveTime = nextSaveTime;
    }

    @Override
    public boolean isImmediateSave() {
        return false;
    }

    @Override
    public boolean isActive() {
        return true;
    }
}
