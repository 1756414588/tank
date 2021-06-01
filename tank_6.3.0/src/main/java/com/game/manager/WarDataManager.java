/**
 * @Title: PartyFightDataManager.java
 * @Package com.game.manager
 * @author ZhangJun
 * @date 2015年12月12日 下午12:03:43
 * @version V1.0
 */
package com.game.manager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;

import com.game.service.ActivityNewService;
import com.game.service.TacticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.ArmyState;
import com.game.constant.AwardFrom;
import com.game.constant.MailType;
import com.game.constant.WarState;
import com.game.dao.impl.p.ServerLogDao;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.Army;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Form;
import com.game.domain.p.FortressBattleParty;
import com.game.domain.p.PartyRank;
import com.game.domain.p.WarLog;
import com.game.domain.p.WarRankInfo;
import com.game.domain.p.WarRankJiFenInfo;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.fortressFight.domain.MyFortressFightData;
import com.game.fortressFight.domain.MyPartyStatistics;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.FortressRecord;
import com.game.pb.CommonPb.RptAtkFortress;
import com.game.pb.CommonPb.RptAtkWar;
import com.game.pb.CommonPb.WarRecord;
import com.game.service.FortressWarService;
import com.game.service.WarService;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import com.game.warFight.domain.FightPair;
import com.game.warFight.domain.WarMember;
import com.game.warFight.domain.WarParty;

/**
 * 军团战排序器
 *
 * @author
 * @ClassName: ComparatorWinRank
 * @Description: TODO
 */
class ComparatorWinRank implements Comparator<WarMember> {

    /**
     * Overriding: compare
     *
     * @param o1
     * @param o2
     * @return
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    @Override
    public int compare(WarMember o1, WarMember o2) {
        long d1 = o1.getMember().getWinCount();
        long d2 = o2.getMember().getWinCount();

        if (d1 < d2)
            return 1;
        else if (d1 > d2) {
            return -1;
        } else {
            long v1 = o1.getMember().getRegFight();
            long v2 = o2.getMember().getRegFight();
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
 * 百团战数据处理
 *
 * @author
 * @ClassName: WarDataManager
 * @Description: TODO
 */
@Component
public class WarDataManager {
    static final int MAX_RECORD_COUNT = 20;

    @Autowired
    private ServerLogDao serverLogDao;

    // @Autowired
    // private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private SmallIdManager smallIdManager;
    @Autowired
    private ActivityNewService activityNewService;
    @Autowired
    private TacticsService tacticsService;

    private WarLog warLog;

    private WarService.WarFight warFight;

    // 所有报名军团
    private Map<Integer, WarParty> partyMap = new HashMap<>();

    // 战力排行
    private Map<Integer, Long> partyFightMap = new LinkedHashMap<>();

    // 军团排名
    private Map<Integer, WarParty> rankMap = new TreeMap<>();

    // 连胜排行
    private LinkedList<WarMember> winRankList = new LinkedList<>();

    // 连胜排行玩家id
    private Set<Long> winRankSet = new HashSet<>();

    // // 已经领取过连胜排行的玩家
    // private Set<Long> getWinRank = new HashSet<>();

    // 能参加要塞战的军团
    private LinkedHashMap<Integer, FortressBattleParty> canFightFortressPartyMap;
    // 要塞战
    private FortressWarService.FortressFight fortressFight;
    // 要塞战记录
    private LinkedHashMap<Integer, FortressRecord> fortressRecords;
    // 要塞战战报
    private Map<Integer, RptAtkFortress> rptRtkFortresss;
    // 我的要塞战数据
    private Map<Long, MyFortressFightData> myFortressFightData;// 初始化fortressPartyInnerJiFenRankMap
    // 统计要塞战军团数据(军团id, 统计,积分排行)
    private LinkedHashMap<Integer, MyPartyStatistics> partyStatisticsMap;
    // 记录全服个人积分排名信息(100名)
    private LinkedHashMap<Long, MyFortressFightData> allServerFortressFightDataRankLordMap;
    // 要塞主任命职位信息
    private List<FortressJobAppoint> fortressJobAppointList; // 初始化fortressJobAppointMapByLordId和fortressJobAppointMap
    // 要塞战军团内部积分排名
    private Map<Integer, LinkedHashMap<Long, MyFortressFightData>> fortressPartyInnerJiFenRankMap = new HashMap<Integer, LinkedHashMap<Long, MyFortressFightData>>();
    // lordId,FortressJobAppoint
    private Map<Long, FortressJobAppoint> fortressJobAppointMapByLordId = new HashMap<Long, FortressJobAppoint>();
    // 要塞主任命职位信息<jobId,List>
    private Map<Integer, List<FortressJobAppoint>> fortressJobAppointMap = new HashMap<Integer, List<FortressJobAppoint>>();
    // 本周军团混战我的军团积分排名 partyId,FortressBattleParty
    private LinkedHashMap<Integer, FortressBattleParty> thisWeekMyWarJiFenRank = new LinkedHashMap<Integer, FortressBattleParty>();

    /**
     * 刷新要塞战数据
     */
    public void refulshFortressData() {
        fortressRecords.clear();
        rptRtkFortresss.clear();
        myFortressFightData.clear();
        partyStatisticsMap.clear();
        fortressJobAppointList.clear();
        allServerFortressFightDataRankLordMap.clear();
        fortressPartyInnerJiFenRankMap.clear();
        fortressJobAppointMapByLordId.clear();
        fortressJobAppointMap.clear();
        globalDataManager.gameGlobal.setFortressTime(TimeHelper.getCurrentDay());
    }

    public LinkedHashMap<Integer, FortressBattleParty> getThisWeekMyWarJiFenRank() {
        return thisWeekMyWarJiFenRank;
    }

    public void setThisWeekMyWarJiFenRank(LinkedHashMap<Integer, FortressBattleParty> thisWeekMyWarJiFenRank) {
        this.thisWeekMyWarJiFenRank = thisWeekMyWarJiFenRank;
    }

    public List<FortressJobAppoint> getFortressJobAppointList() {
        return fortressJobAppointList;
    }

    public void setFortressJobAppointList(List<FortressJobAppoint> fortressJobAppointList) {
        this.fortressJobAppointList = fortressJobAppointList;
    }

    public Map<Long, FortressJobAppoint> getFortressJobAppointMapByLordId() {
        return fortressJobAppointMapByLordId;
    }

    public void setFortressJobAppointMapByLordId(Map<Long, FortressJobAppoint> fortressJobAppointMapByLordId) {
        this.fortressJobAppointMapByLordId = fortressJobAppointMapByLordId;
    }

    public Map<Integer, List<FortressJobAppoint>> getFortressJobAppointMap() {
        return fortressJobAppointMap;
    }

    public void setFortressJobAppointMap(Map<Integer, List<FortressJobAppoint>> fortressJobAppointMap) {
        this.fortressJobAppointMap = fortressJobAppointMap;
    }

    public Map<Integer, LinkedHashMap<Long, MyFortressFightData>> getFortressPartyInnerJiFenRankMap() {
        return fortressPartyInnerJiFenRankMap;
    }

    public LinkedHashMap<Long, MyFortressFightData> getAllServerFortressFightDataRankLordMap() {
        return allServerFortressFightDataRankLordMap;
    }

    public void setAllServerFortressFightDataRankLordMap(
            LinkedHashMap<Long, MyFortressFightData> allServerFortressFightDataRankLordMap) {
        this.allServerFortressFightDataRankLordMap = allServerFortressFightDataRankLordMap;
    }

    public void setFortressPartyInnerJiFenRankMap(
            Map<Integer, LinkedHashMap<Long, MyFortressFightData>> fortressPartyInnerJiFenRankMap) {
        this.fortressPartyInnerJiFenRankMap = fortressPartyInnerJiFenRankMap;
    }

    public void addFortressRecord(FortressRecord record) {
        fortressRecords.put(record.getReportKey(), record);
    }

    public LinkedHashMap<Integer, FortressBattleParty> getCanFightFortressPartyMap() {
        return canFightFortressPartyMap;
    }

    public void setCanFightFortressPartyMap(LinkedHashMap<Integer, FortressBattleParty> canFightFortressPartyMap) {
        this.canFightFortressPartyMap = canFightFortressPartyMap;
    }

    public void addRptRtkFortress(RptAtkFortress rpt) {
        rptRtkFortresss.put(rpt.getReportKey(), rpt);
    }

    public void addMyFortressFightData(MyFortressFightData data) {
        myFortressFightData.put(data.getLordId(), data);
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

    public Map<Long, MyFortressFightData> getMyFortressFightData() {
        return myFortressFightData;
    }

    public void setMyFortressFightData(Map<Long, MyFortressFightData> myFortressFightData) {
        this.myFortressFightData = myFortressFightData;
    }

    public Map<Integer, WarParty> getRankMap() {
        return rankMap;
    }

    public void setRankMap(Map<Integer, WarParty> rankMap) {
        this.rankMap = rankMap;
    }

    public LinkedList<WarMember> getWinRankList() {
        return winRankList;
    }

    public void setWinRankList(LinkedList<WarMember> winRankList) {
        this.winRankList = winRankList;
    }

    public WarLog getWarLog() {
        return warLog;
    }

    public void setWarLog(WarLog warLog) {
        this.warLog = warLog;
    }

    public LinkedHashMap<Integer, MyPartyStatistics> getPartyStatisticsMap() {
        return partyStatisticsMap;
    }

    public void setPartyStatisticsMap(LinkedHashMap<Integer, MyPartyStatistics> partyStatisticsMap) {
        this.partyStatisticsMap = partyStatisticsMap;
    }

    //	@PostConstruct
    public void init() {
        initWarLog();
        initData();
        initFortressData();
    }

    /**
     * 初始化要塞战数据
     */
    private void initFortressData() {
        canFightFortressPartyMap = globalDataManager.gameGlobal.getCanFightFortressPartyMap();
        fortressRecords = globalDataManager.gameGlobal.getFortressRecords();
        rptRtkFortresss = globalDataManager.gameGlobal.getRptRtkFortresss();
        myFortressFightData = globalDataManager.gameGlobal.getMyFortressFightDatas();
        partyStatisticsMap = globalDataManager.gameGlobal.getPartyStatisticsMap();
        fortressJobAppointList = globalDataManager.gameGlobal.getFortressJobAppointList();
        allServerFortressFightDataRankLordMap = globalDataManager.gameGlobal.getAllServerFortressFightDataRankLordMap();

        // 初始化fortressPartyInnerJiFenRankMap
        initFortressPartyInnerJiFenRankMap();

        // 初始化fortressJobAppointMapByLordId和fortressJobAppointMap
        initFortressJob();

        // 初始化本周军团战积分排名
        initThisWeekMyWarJiFenRank();
    }

    /**
     * 计算本周个人积分排行
     * void
     */
    private void initThisWeekMyWarJiFenRank() {
        calThisWeekWarPartyJiFenRank();
    }

    /**
     * 要塞战职务
     * void
     */
    private void initFortressJob() {
        for (FortressJobAppoint f : fortressJobAppointList) {
            fortressJobAppointMapByLordId.put(f.getLordId(), f);
            List<FortressJobAppoint> list = fortressJobAppointMap.get(f.getJobId());
            if (list == null) {
                list = new ArrayList<FortressJobAppoint>();
                fortressJobAppointMap.put(f.getJobId(), list);
            }
            list.add(f);
        }
    }

    /**
     * 要塞战军团内部排名
     * void
     */
    private void initFortressPartyInnerJiFenRankMap() {
        Iterator<MyFortressFightData> its = myFortressFightData.values().iterator();
        while (its.hasNext()) {
            joinFortressPartyInnerRankMap(its.next(), false);
        }
        // 排序
        Set<Integer> keySet = fortressPartyInnerJiFenRankMap.keySet();
        for (Integer partyId : keySet) {
            LinkedHashMap<Long, MyFortressFightData> mp = fortressPartyInnerJiFenRankMap.get(partyId);
            sortFortressPartyInnnerRankMap(partyId, mp);
        }
    }

    private void initData() {
        Map<Integer, PartyData> parties = partyDataManager.getPartyMap();
        Iterator<PartyData> itParty = parties.values().iterator();
        while (itParty.hasNext()) {
            PartyData partyData = (PartyData) itParty.next();
            if (partyData.getRegLv() > 0 && partyData.getRegFight() > 0) {
                partyFightMap.put(partyData.getPartyId(), partyData.getRegFight());
            }
        }

        Iterator<Member> it = partyDataManager.getMemberMap().values().iterator();
        while (it.hasNext()) {
            Member member = it.next();
            if (!smallIdManager.isSmallId(member.getLordId())) {

                if (member.getRegLv() != 0) {
                    if (member.getRegParty() != 0) {
                        PartyData partyData = partyDataManager.getParty(member.getRegParty());
                        if (null == partyData) {
                            LogUtil.error("报名军团不存在，有可能是小号军团，跳过, partyId:" + member.getRegParty());
                            continue;
                        }
                        loadReg(partyData, member);
                    } else if (member.getPartyId() != 0) {
                        PartyData partyData = partyDataManager.getParty(member.getPartyId());
                        loadReg(partyData, member);
                    }
                }
            }
        }

        List<Long> list = globalDataManager.gameGlobal.getWinRank();
        for (Long roleId : list) {
            if (!smallIdManager.isSmallId(roleId)) {
                Member member = partyDataManager.getMemberById(roleId);
                WarParty warParty;
                if (member.getRegParty() != 0) {
                    warParty = partyMap.get(member.getRegParty());
                } else {
                    warParty = partyMap.get(member.getPartyId());
                }
                if (warParty == null) {
                    continue;
                }
                WarMember warMember = warParty.getMember(roleId);
                ;

                winRankList.add(warMember);
                winRankSet.add(roleId);
            }
        }

        partyFightMap = sortMap(partyFightMap);

        Iterator<WarParty> partyIt = partyMap.values().iterator();
        while (partyIt.hasNext()) {
            WarParty warParty = (WarParty) partyIt.next();
            setWarRank(warParty, warParty.getPartyData().getWarRank());
        }

    }


    /**
     * 报名信息
     *
     * @param partyData
     * @param member    void
     */
    public void loadReg(PartyData partyData, Member member) {
        int partyId = member.getRegParty();
        WarParty warParty = partyMap.get(partyId);
        if (warParty == null) {
            warParty = new WarParty(partyData);
            partyMap.put(partyId, warParty);
        }

        WarMember warMember = loadWarMember(member, partyData);
        warParty.load(warMember);
        // setWinRank(warMember);
    }

    /**
     * 重置军团战信息
     * void
     */
    public void refreshForWarFight() {
        Map<Integer, PartyData> parties = partyDataManager.getPartyMap();
        Iterator<PartyData> it = parties.values().iterator();
        while (it.hasNext()) {
            PartyData partyData = (PartyData) it.next();
            partyData.getWarRecords().clear();
            partyData.setRegLv(0);
            partyData.setRegFight(0);
            partyData.setWarRank(0);
        }

        Iterator<Member> itMember = partyDataManager.getMemberMap().values().iterator();
        while (itMember.hasNext()) {
            Member member = itMember.next();
            if (member.getRegLv() != 0) {
                member.setRegParty(0);
                member.setRegLv(0);
                member.setRegFight(0);
                member.setWinCount(0);
                member.getWarRecords().clear();
            }
        }

        partyMap.clear();
        partyFightMap.clear();
        globalDataManager.clearWarRecord();

        rankMap.clear();
        winRankList.clear();
        winRankSet.clear();

        globalDataManager.gameGlobal.getWinRank().clear();
        globalDataManager.gameGlobal.getGetWinRank().clear();
        globalDataManager.gameGlobal.setWarTime(TimeHelper.getCurrentDay());
    }

    /**
     * 关闭军团战
     * void
     */
    public void cancelWarFight() {
        Map<Integer, PartyData> parties = partyDataManager.getPartyMap();
        Iterator<PartyData> it = parties.values().iterator();
        while (it.hasNext()) {
            PartyData partyData = (PartyData) it.next();
            partyData.getWarRecords().clear();
            partyData.setRegLv(0);
            partyData.setRegFight(0);
            partyData.setWarRank(0);
        }

        Iterator<Member> itMember = partyDataManager.getMemberMap().values().iterator();
        while (itMember.hasNext()) {
            Member member = itMember.next();
            if (member.getRegLv() != 0 && member.getRegParty() != 0) {
                member.setRegParty(0);
                member.setRegLv(0);
                member.setRegFight(0);
                member.setWinCount(0);
                member.getWarRecords().clear();
            }
        }

        partyMap.clear();
        partyFightMap.clear();
        globalDataManager.clearWarRecord();
        rankMap.clear();
        winRankList.clear();
        winRankSet.clear();

        globalDataManager.gameGlobal.getWinRank().clear();
        globalDataManager.gameGlobal.getGetWinRank().clear();
    }

    /**
     * 要塞战结束时清理
     * void
     */
    public void endClearFortress() {
        canFightFortressPartyMap.clear();
        thisWeekMyWarJiFenRank.clear();
    }

    /**
     * 关闭要塞战
     * void
     */
    public void cancelFortressFight() {
        canFightFortressPartyMap.clear();
        thisWeekMyWarJiFenRank.clear();
        // fortressRecords = globalDataManager.gameGlobal.getFortressRecords();
        // rptRtkFortresss = globalDataManager.gameGlobal.getRptRtkFortresss();
        // myFortressFightData =
        // globalDataManager.gameGlobal.getMyFortressFightDatas();
        // partyStatisticsMap =
        // globalDataManager.gameGlobal.getPartyStatisticsMap();
        // fortressJobAppointList =
        // globalDataManager.gameGlobal.getFortressJobAppointList();
        // allServerFortressFightDataRankLordMap = globalDataManager.gameGlobal
        // .getAllServerFortressFightDataRankLordMap();
        //
        // // 初始化fortressPartyInnerJiFenRankMap
        // initFortressPartyInnerJiFenRankMap();
        //
        // // 初始化fortressJobAppointMapByLordId和fortressJobAppointMap
        // initFortressJob();
        //
        // // 初始化本周军团战积分排名
        // initThisWeekMyWarJiFenRank();
    }

    /**
     * 增加战斗记录
     *
     * @param fightPair 交战人员信息
     * @param record
     * @param rpt       void
     */
    public void addRecord(FightPair fightPair, WarRecord record, RptAtkWar rpt) {
        globalDataManager.addWarRecord(record);

        LinkedList<CommonPb.WarRecord> party = fightPair.attacker.getWarParty().getPartyData().getWarRecords();
        party.add(record);
        if (party.size() > MAX_RECORD_COUNT) {
            party.removeFirst();
        }

        party = fightPair.defencer.getWarParty().getPartyData().getWarRecords();
        party.add(record);
        if (party.size() > MAX_RECORD_COUNT) {
            party.removeFirst();
        }

        Member target = fightPair.attacker.getMember();
        CommonPb.WarRecordPerson personRecord = PbHelper.createPersonWarRecordPb(record, rpt);
        target.warRecords.add(personRecord);
        if (target.warRecords.size() > MAX_RECORD_COUNT) {
            target.warRecords.removeFirst();
        }

        target = fightPair.defencer.getMember();
        target.warRecords.add(personRecord);
        if (target.warRecords.size() > MAX_RECORD_COUNT) {
            target.warRecords.removeFirst();
        }
    }

    /**
     * 增加军团战记录
     *
     * @param warParty
     * @param record   void
     */
    public void addWorldAndPartyRecord(WarParty warParty, WarRecord record) {
        globalDataManager.addWarRecord(record);

        LinkedList<CommonPb.WarRecord> party = warParty.getPartyData().getWarRecords();
        party.add(record);
        if (party.size() > MAX_RECORD_COUNT) {
            party.removeFirst();
        }
    }

    /**
     * 服务器启动时加载军团战日志
     * void
     */
    private void initWarLog() {
        warLog = serverLogDao.selectLastWarLog();
        // if (warLog == null) {
        // warLog = new WarLog();
        // warLog.setWarTime(TimeHelper.getCurrentDay());
        // }
    }

    /**
     * 保存战斗日志到数据库
     * void
     */
    public void flushWarLog() {
        serverLogDao.insertWarLog(warLog);
    }

    /**
     * 排序类型ArrayList<Map.Entry<Integer, Long>>按值
     *
     * @param oldMap
     * @return Map<Integer               ,               Long>
     */
    private Map<Integer, Long> sortMap(Map<Integer, Long> oldMap) {
        ArrayList<Map.Entry<Integer, Long>> list = new ArrayList<Map.Entry<Integer, Long>>(oldMap.entrySet());
        Collections.sort(list, new Comparator<Entry<Integer, Long>>() {

            @Override
            public int compare(Entry<Integer, Long> o1, Entry<Integer, Long> o2) {
                long d1 = o1.getValue();
                long d2 = o2.getValue();
                if (d1 < d2)
                    return 1;
                else if (d1 > d2) {
                    return -1;
                }

                return 0;
            }
        });

        Map<Integer, Long> newMap = new LinkedHashMap<Integer, Long>();
        for (int i = 0; i < list.size(); i++) {
            newMap.put(list.get(i).getKey(), list.get(i).getValue());
        }
        return newMap;
    }

    /**
     * 排序partyStatisticsMap 按军团要塞战积分
     * void
     */
    public void sortPartyStatisticsMap() {
        List<Map.Entry<Integer, MyPartyStatistics>> infoIds = new ArrayList<Map.Entry<Integer, MyPartyStatistics>>(
                partyStatisticsMap.entrySet());

        // 排序
        Collections.sort(infoIds, new Comparator<Map.Entry<Integer, MyPartyStatistics>>() {
            public int compare(Map.Entry<Integer, MyPartyStatistics> o1, Map.Entry<Integer, MyPartyStatistics> o2) {
                MyPartyStatistics p1 = (MyPartyStatistics) o1.getValue();
                MyPartyStatistics p2 = (MyPartyStatistics) o2.getValue();

                return p2.getJifen() - p1.getJifen();
            }
        });

        /* 转换成新map输出 */
        LinkedHashMap<Integer, MyPartyStatistics> newMap = new LinkedHashMap<Integer, MyPartyStatistics>();

        for (Map.Entry<Integer, MyPartyStatistics> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }

        partyStatisticsMap.clear();
        partyStatisticsMap.putAll(newMap);
        newMap = null;
    }

    // 加入并排序
    public void joinMyFortressDataRankMap(MyFortressFightData my) {
        // 判断map中有没有，若有则直接排序
        if (allServerFortressFightDataRankLordMap.containsKey(my.getLordId())) {
            sortAllServerMyFortressDataRankMap();
        } else {
            // 若没有,则需判断能否加入
            // 若size<100,直接加入并排序
            if (allServerFortressFightDataRankLordMap.size() < 100) {
                allServerFortressFightDataRankLordMap.put(my.getLordId(), my);
                sortAllServerMyFortressDataRankMap();
            } else {
                // 同最后一条记录比较，若比最后一条记录大则剔除最后一条并加入
                List<MyFortressFightData> list = new ArrayList<MyFortressFightData>(
                        allServerFortressFightDataRankLordMap.values());
                MyFortressFightData last = list.get(list.size() - 1);
                if (last.getJifen() >= my.getJifen()) {
                    // 不处理
                } else {
                    allServerFortressFightDataRankLordMap.remove(last.getLordId());
                    allServerFortressFightDataRankLordMap.put(my.getLordId(), my);
                    sortAllServerMyFortressDataRankMap();
                }
                list = null;
            }
        }
    }

    /**
     * 加入军团内排名并排序
     *
     * @param my
     */
    public void joinFortressPartyInnerRankMap(MyFortressFightData my, boolean isNeedSort) {
        // 获取partyId
        Member m = partyDataManager.getMemberById(my.getLordId());
        if (m == null || m.getPartyId() == 0) {
            return;
        }

        int partyId = m.getPartyId();

        LinkedHashMap<Long, MyFortressFightData> mp = fortressPartyInnerJiFenRankMap.get(partyId);
        if (mp == null) {
            mp = new LinkedHashMap<Long, MyFortressFightData>();
            fortressPartyInnerJiFenRankMap.put(partyId, mp);
        }

        // 判断是否存在吗,若不存在加入且排序
        if (!mp.containsKey(my.getLordId())) {
            mp.put(my.getLordId(), my);
        }

        // 排序
        if (isNeedSort) {
            sortFortressPartyInnnerRankMap(partyId, mp);
        }
    }

    /**
     * 排序 LinkedHashMap<Long, MyFortressFightData> 按MyFortressFightData个人要塞战积分
     *
     * @param partyId
     * @param mp      void
     */
    private void sortFortressPartyInnnerRankMap(int partyId, LinkedHashMap<Long, MyFortressFightData> mp) {
        List<Map.Entry<Long, MyFortressFightData>> infoIds = new ArrayList<Map.Entry<Long, MyFortressFightData>>(
                mp.entrySet());

        // 排序
        Collections.sort(infoIds, new Comparator<Map.Entry<Long, MyFortressFightData>>() {
            public int compare(Map.Entry<Long, MyFortressFightData> o1, Map.Entry<Long, MyFortressFightData> o2) {
                MyFortressFightData p1 = (MyFortressFightData) o1.getValue();
                MyFortressFightData p2 = (MyFortressFightData) o2.getValue();

                return p2.getJifen() - p1.getJifen();
            }
        });

        /* 转换成新map输出 */
        LinkedHashMap<Long, MyFortressFightData> newMap = new LinkedHashMap<Long, MyFortressFightData>();

        for (Map.Entry<Long, MyFortressFightData> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }

        mp.clear();
        mp.putAll(newMap);
        newMap = null;

        fortressPartyInnerJiFenRankMap.put(partyId, mp);
    }

    /**
     * 排序全服玩家要塞战积分
     * void
     */
    public void sortAllServerMyFortressDataRankMap() {
        List<Map.Entry<Long, MyFortressFightData>> infoIds = new ArrayList<Map.Entry<Long, MyFortressFightData>>(
                allServerFortressFightDataRankLordMap.entrySet());

        // 排序
        Collections.sort(infoIds, new Comparator<Map.Entry<Long, MyFortressFightData>>() {
            public int compare(Map.Entry<Long, MyFortressFightData> o1, Map.Entry<Long, MyFortressFightData> o2) {
                MyFortressFightData p1 = (MyFortressFightData) o1.getValue();
                MyFortressFightData p2 = (MyFortressFightData) o2.getValue();

                return p2.getJifen() - p1.getJifen();
            }
        });

        /* 转换成新map输出 */
        LinkedHashMap<Long, MyFortressFightData> newMap = new LinkedHashMap<Long, MyFortressFightData>();

        for (Map.Entry<Long, MyFortressFightData> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }

        allServerFortressFightDataRankLordMap.clear();
        allServerFortressFightDataRankLordMap.putAll(newMap);
        newMap = null;
    }

    /**
     * 新增报名参加军团战的军团成员信息
     *
     * @param player
     * @param member
     * @param form
     * @param fight
     * @return WarMember
     */
    public WarMember createWarMember(Player player, Member member, Form form, long fight) {
        WarMember warMember = new WarMember();
        warMember.setPlayer(player);
        warMember.setMember(member);
        warMember.setForm(form);
        member.setRegParty(member.getPartyId());
        member.setRegFight(fight);
        member.setRegLv(player.lord.getLevel());
        member.setRegTime(TimeHelper.getCurrentSecond());
        warMember.setInstForm(new Form(form));
        return warMember;
    }

    /**
     * 初始化时加载军团战的军团成员信息
     *
     * @param member
     * @param partyData
     * @return WarMember
     */
    private WarMember loadWarMember(Member member, PartyData partyData) {
        Player player = playerDataManager.getPlayer(member.getLordId());
        WarMember warMember = new WarMember();
        warMember.setPlayer(player);
        warMember.setMember(member);
        return warMember;
    }

    /**
     * 军团战为军团报名
     *
     * @param warMember
     * @return boolean
     */
    public boolean warReg(WarMember warMember) {
        int partyId = warMember.getMember().getPartyId();
        WarParty warParty = partyMap.get(partyId);
        if (warParty == null) {
            PartyData partyData = partyDataManager.getParty(partyId);
            if (partyData == null) {
                return false;
            }
            warParty = new WarParty(partyData);
            partyMap.put(partyId, warParty);
        }

        warParty.add(warMember);

        Long fight = partyFightMap.get(partyId);
        if (fight == null) {
            partyFightMap.put(partyId, warMember.getMember().getRegFight());
        } else {
            partyFightMap.put(partyId, fight + warMember.getMember().getRegFight());
        }

        partyFightMap = sortMap(partyFightMap);
        return true;
    }

    /**
     * 取消军团战时撤回部队
     *
     * @param warMember
     * @param isCaseByServerRest void
     */
    public void cancelArmy(WarMember warMember, boolean isCaseByServerRest) {
        Player target = warMember.getPlayer();

        Iterator<Army> it = target.armys.iterator();
        Army army = null;
        while (it.hasNext()) {
            army = (Army) it.next();
            if (army.getState() == ArmyState.WAR) {
                it.remove();
                break;
            }
        }

        Form form;
        if (isCaseByServerRest) {
            form = army.getForm();
        } else {
            form = warMember.getForm();
        }
        if (form != null) {
            for (int i = 0; i < form.c.length; i++) {
                if (form.c[i] > 0) {
                    playerDataManager.addTank(target, form.p[i], form.c[i], AwardFrom.CANCEL_ARMY);
                }
            }
            if (form.getAwakenHero() != null) {
                AwakenHero awakenHero = target.awakenHeros.get(form.getAwakenHero().getKeyId());
                awakenHero.setUsed(false);
                LogLordHelper.awakenHero(AwardFrom.CANCEL_ARMY, target.account, target.lord, awakenHero, 0);
            } else if (form.getCommander() > 0) {
                playerDataManager.addHero(target, form.getCommander(), 1, AwardFrom.CANCEL_ARMY);
            }

            //取消战术
            if (!form.getTactics().isEmpty()) {
                tacticsService.cancelUseTactics(target, form.getTactics());
            }
        }
    }

    /**
     * 取消报名
     *
     * @param partyId
     * @param roleId  void
     */
    public void warUnReg(int partyId, long roleId) {
        WarParty warParty = partyMap.get(partyId);
        if (warParty != null) {
            WarMember warMember = warParty.getMember(roleId);
            if (warMember != null) {
                Long fight = partyFightMap.get(partyId);
                if (fight != null) {
                    fight -= warMember.getMember().getRegFight();
                    if (fight > 0) {
                        partyFightMap.put(partyId, fight);
                    } else {
                        partyFightMap.remove(partyId);
                    }
                }

                warParty.remove(warMember);
                // cancelArmy(warMember);
            }

            if (warParty.getMembers().size() == 0) {
                warParty.getPartyData().setRegFight(0);
                warParty.getPartyData().setRegLv(0);
                partyMap.remove(partyId);
            }
        }
    }

    public WarParty getWarParty(int partyId) {
        return partyMap.get(partyId);
    }

    public Map<Integer, WarParty> getParties() {
        return partyMap;
    }

    public Long getPartyFight(int partyId) {
        return partyFightMap.get(partyId);
    }

    public Map<Integer, Long> getPartyFightMap() {
        return partyFightMap;
    }

    /**
     * 军团战斗记录
     *
     * @param partyId
     * @return LinkedList<CommonPb.WarRecord>
     */
    public LinkedList<CommonPb.WarRecord> getPartyWarRecord(int partyId) {
        WarParty warParty = partyMap.get(partyId);
        if (warParty != null) {
            return warParty.getPartyData().getWarRecords();
        }

        return null;
    }

    // public LinkedList<CommonPb.WarRecord> getWorldWarRecord() {
    // return worldRecord;
    // }

    // public void recordRank() {
    // arrangeWinRank();
    // arrangePartyRank();
    // }

    public void setWarRank(WarParty warParty, int rank) {
        rankMap.put(rank, warParty);
    }

    /**
     * 增加到军团战连胜排行
     *
     * @param warMember void
     */
    public void setWinRank(WarMember warMember) {
        if (warMember.getMember().getWinCount() == 0) {
            return;
        }

        if (winRankSet.contains(warMember.getPlayer().roleId)) {
            Collections.sort(winRankList, new ComparatorWinRank());
        } else {
            if (winRankList.isEmpty()) {
                winRankList.add(warMember);
            } else {
                boolean added = false;
                ListIterator<WarMember> rankIt = winRankList.listIterator(winRankList.size());
                while (rankIt.hasPrevious()) {
                    Member e = rankIt.previous().getMember();
                    if (warMember.getMember().getWinCount() < e.getWinCount()) {
                        rankIt.next();
                        rankIt.add(warMember);
                        added = true;
                        break;
                    } else if (warMember.getMember().getWinCount() == e.getWinCount()) {
                        if (warMember.getMember().getRegFight() <= e.getRegFight()) {
                            rankIt.next();
                            rankIt.add(warMember);
                            added = true;
                            break;
                        }
                    }
                }

                if (!added) {
                    winRankList.addFirst(warMember);
                }
            }

            winRankSet.add(warMember.getPlayer().roleId);
            if (winRankList.size() > 10) {
                winRankSet.remove(winRankList.removeLast().getPlayer().roleId);
            }
        }
    }

    /**
     * 获取连胜排名
     *
     * @param roleId
     * @return int
     */
    public int getWinRank(long roleId) {
        if (winRankSet.contains(roleId)) {
            int rank = 0;
            for (WarMember warMember : winRankList) {
                rank++;
                if (warMember.getPlayer().roleId == roleId) {
                    return rank;
                }
            }
        }
        return 0;
    }

    /**
     * 是否已领取连胜奖励
     *
     * @param roleId
     * @return boolean
     */
    public boolean hadGetWinRankAward(long roleId) {
        return globalDataManager.gameGlobal.getGetWinRank().contains(roleId);
    }

    /**
     * 设置已领取连胜奖励
     *
     * @param roleId void
     */
    public void setWinRankAward(long roleId) {
        globalDataManager.gameGlobal.getGetWinRank().add(roleId);
    }


    public WarService.WarFight getWarFight() {
        return warFight;
    }

    /**
     * 开启一个军团战 往内存中设置新的军团战信息
     *
     * @param warFight void
     */
    public void setWarFight(WarService.WarFight warFight) {
        this.warFight = warFight;
        refreshForWarFight();
    }

    /**
     * 是否是注册时间
     *
     * @return boolean
     */
    public boolean inRegTime() {
        if (globalDataManager.gameGlobal.getWarState() == WarState.REG_STATE) {
            return true;
        }

        return false;
    }

    /**
     * @Description: 记录百团大战名次 @return void @throws
     */
    public void recordRankTop10() {
        Map<Integer, Map<Integer, WarRankInfo>> recordWarRanks = globalDataManager.gameGlobal.getWarRankRecords();

        Set<Integer> keySet = recordWarRanks.keySet();
        if (keySet.size() >= 3) {
            // 若查过3次，则删除最远的一次
            List<Integer> list = new ArrayList<Integer>(keySet);
            Collections.sort(list, new Comparator<Integer>() {

                @Override
                public int compare(Integer o1, Integer o2) {
                    return o1 >= o2 ? 1 : -1;
                }
            });

            int keySize = keySet.size();
            // 超过多次的时候，就删掉只剩下3次
            for (int i = 0; i <= (keySize - 3); i++) {
                recordWarRanks.remove(list.get(0));
            }
        }

        Map<Integer, WarRankInfo> m = new HashMap<Integer, WarRankInfo>();
        int keyId = TimeHelper.getCurrentDay();

        int size = rankMap.size() >= 10 ? 10 : rankMap.size();

        for (int i = 0; i < size; i++) {
            // 打印当前排名
            WarParty warParty = rankMap.get(i + 1);
            int partyId = warParty.getPartyData().getPartyId();
            String partyName = warParty.getPartyData().getPartyName();

//			LogHelper.WAR_LOGGER.trace("this war party player rank :" + partyId + "|" + partyName +"|"+ (i+1));
            LogUtil.war("this war party player rank :" + partyId + "|" + partyName + "|" + (i + 1));

            m.put(i + 1, new WarRankInfo(keyId, i + 1, partyId, partyName));

            try {
                if (i == 0) {
                    activityNewService.refreshStateWar(partyId);
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }

        recordWarRanks.put(keyId, m);

    }

    /**
     * 计算本周军团混战军团排名
     */
    public void calThisWeekWarPartyJiFenRank() {
        thisWeekMyWarJiFenRank.clear();
        Map<Integer, Map<Integer, WarRankInfo>> recordWarRanks = globalDataManager.gameGlobal.getWarRankRecords();
        Set<Integer> keySet = recordWarRanks.keySet();
        int monday = TimeHelper.getThisWeekMonday();
        int sunday = TimeHelper.getThisWeekSunday();
        Map<Integer, WarRankJiFenInfo> temp = new HashMap<Integer, WarRankJiFenInfo>();
        for (Integer dateTime : keySet) {
            if (dateTime >= monday && dateTime <= sunday) {
                Map<Integer, WarRankInfo> map = recordWarRanks.get(dateTime);
                Iterator<WarRankInfo> it = map.values().iterator();
                while (it.hasNext()) {
                    WarRankInfo info = it.next();
                    WarRankJiFenInfo t = temp.get(info.getPartyId());
                    if (t == null) {
                        t = new WarRankJiFenInfo(info.getPartyId(), info.getPartyName(), jifens[info.getRank() - 1]);
                        temp.put(t.getPartyId(), t);
                    } else {
                        t.setJiFen(t.getJiFen() + jifens[info.getRank() - 1]);
                    }
                }
            }
        }


        List<WarRankJiFenInfo> list = new ArrayList<>(temp.values());
        Collections.sort(list, new Comparator<WarRankJiFenInfo>() {
            @Override
            public int compare(WarRankJiFenInfo o1, WarRankJiFenInfo o2) {
                return o2.getJiFen() - o1.getJiFen();
            }
        });

        int size = list.size();
        for (int i = 0; i < size; i++) {
            WarRankJiFenInfo info = list.get(i);
            FortressBattleParty p = new FortressBattleParty();
            p.setPartyId(info.getPartyId());
            p.setPartyName(info.getPartyName());
            p.setRank(i + 1);
            p.setJifen(info.getJiFen());
            thisWeekMyWarJiFenRank.put(p.getPartyId(), p);

//			LogHelper.WAR_LOGGER.trace("this week war jifen rank:" + p.getPartyId() + "|" + p.getPartyName() +"|"+ p.getJifen()+"|"+p.getRank());
            LogUtil.war("this week war jifen rank:" + p.getPartyId() + "|" + p.getPartyName() + "|" + p.getJifen() + "|"
                    + p.getRank());
        }
    }

    /**
     * 计算能参加要塞战的军团
     */
    public void calCanFightFortressParty() {
        canFightFortressPartyMap.clear();

        // 若没有积分排名则从军团战力排行中选
        if (thisWeekMyWarJiFenRank.size() == 0) {
            int size = partyDataManager.getPartyRanks().size();
            size = size >= 10 ? 10 : size;
            for (int i = 0; i < size; i++) {
                PartyRank pr = partyDataManager.getPartyRanks().get(i);
                if (pr.getRank() == 1) {
                    // 发送防守要塞邀请邮件
                    playerDataManager.sendMailToParty(pr.getPartyId(), MailType.MOLD_FORTRESS_DEFANCE_Invitation,
                            1 + "");
                } else {
                    // 发送进攻要塞邀请邮件
                    playerDataManager.sendMailToParty(pr.getPartyId(), MailType.MOLD_FORTRESS_ATTACK_Invitation,
                            pr.getRank() + "");
                }

//				LogHelper.WAR_LOGGER.trace("party join fortress by rank :" + pr.getPartyId() + "|"
//						+ partyDataManager.getParty(pr.getPartyId()).getPartyName() + "|" + pr.getRank());
                LogUtil.war("party join fortress by rank :" + pr.getPartyId() + "|"
                        + partyDataManager.getParty(pr.getPartyId()).getPartyName() + "|" + pr.getRank());
            }
        } else {
            Iterator<FortressBattleParty> its = thisWeekMyWarJiFenRank.values().iterator();
            int i = 0;
            while (its.hasNext() && i < 10) {
                i++;
                FortressBattleParty p = its.next();
                canFightFortressPartyMap.put(p.getPartyId(), p);

//				LogHelper.WAR_LOGGER.trace("caul join fortress party :" + p.getPartyId() + "|" + p.getPartyName() + "|"
//						+ p.getJifen() + "|" + p.getRank());
                LogUtil.war("caul join fortress party :" + p.getPartyId() + "|" + p.getPartyName() + "|" + p.getJifen()
                        + "|" + p.getRank());
                if (p.getRank() == 1) {
                    // 发送防守要塞邀请邮件
                    playerDataManager.sendMailToParty(p.getPartyId(), MailType.MOLD_FORTRESS_DEFANCE_Invitation,
                            1 + "");
                } else {
                    // 发送进攻要塞邀请邮件
                    playerDataManager.sendMailToParty(p.getPartyId(), MailType.MOLD_FORTRESS_ATTACK_Invitation,
                            p.getRank() + "");
                }
            }
        }
    }

    public FortressWarService.FortressFight getFortressFight() {
        return fortressFight;
    }

    /**
     * 开启新的要塞战时设置数据
     *
     * @param fortressFight void
     */
    public void setFortressFight(FortressWarService.FortressFight fortressFight) {
        this.fortressFight = fortressFight;
        fortressFight.refulsh();
    }

    /**
     * 统计要塞战军团数据(军团id, 统计,积分排行)
     *
     * @param partyId
     * @return MyPartyStatistics
     */
    public MyPartyStatistics getMyPartyStatistics(int partyId) {
        MyPartyStatistics ps = partyStatisticsMap.get(partyId);
        if (ps == null) {
            ps = new MyPartyStatistics();
            ps.setPartyId(partyId);

            ps.setAttack(canFightFortressPartyMap.get(partyId).getRank() == 1 ? false : true);
            partyStatisticsMap.put(partyId, ps);
        }
        return ps;
    }

    // 排名积分
    public static int[] jifens = {20, 15, 12, 9, 7, 5, 4, 3, 2, 1};

    /**
     * 任命要塞战关官员
     *
     * @param index
     * @param jobId
     * @param lordId
     * @param nick
     * @param durationTime
     * @return FortressJobAppoint
     */
    public FortressJobAppoint appointFortressJob(int index, int jobId, long lordId, String nick, int durationTime) {
        FortressJobAppoint f = new FortressJobAppoint();
        f.setJobId(jobId);
        f.setIndex(index);
        f.setLordId(lordId);
        f.setNick(nick);
        int nowS = TimeHelper.getCurrentSecond();
        f.setAppointTime(nowS);
        f.setEndTime(nowS + durationTime);

        fortressJobAppointList.add(f);
        fortressJobAppointMapByLordId.put(f.getLordId(), f);
        List<FortressJobAppoint> list = fortressJobAppointMap.get(jobId);
        if (list == null) {
            list = new ArrayList<FortressJobAppoint>();
            fortressJobAppointMap.put(jobId, list);
        }
        list.add(f);

        return f;
    }

    /**
     * 初始化军团统计数据
     */
    public void initStaticPartyData() {
        Iterator<Integer> its = canFightFortressPartyMap.keySet().iterator();
        while (its.hasNext()) {
            int partyId = its.next();
            getMyPartyStatistics(partyId);
        }

        sortPartyStatisticsMap();
    }
}
