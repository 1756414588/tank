package com.game.manager.cross.fight;

import com.game.constant.CrossConst;
import com.game.cross.domain.*;
import com.game.dao.table.fight.*;
import com.game.datamgr.StaticCrossDataMgr;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.table.cross.*;
import com.game.pb.CommonPb.CrossRecord;
import com.game.pb.CommonPb.CrossRptAtk;
import com.game.service.cross.fight.CrossService.CrossFightFinal;
import com.game.service.cross.fight.CrossService.CrossFightJiFen;
import com.game.service.cross.fight.CrossService.CrossFightKnock;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.google.common.base.Stopwatch;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import sun.rmi.runtime.Log;

import java.util.*;
import java.util.Map.Entry;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/13 11:32 @Description :java类作用描述
 */
@Component
public class CrossDataManager {
    public static final int crossId = 1;
    @Autowired
    private CrossFightTableDao crossFightTableDao;
    @Autowired
    private CrossFightRecordsTableDao crossFightRecordsTableDao;
    @Autowired
    private CrossFightInfoTableDao crossFightInfoTableDao;
    @Autowired
    private CrossFightAthleteTableDao crossFightAthleteTableDao;
    @Autowired
    private CrossFightPlayerJifenTableDao crossFightPlayerJifenTableDao;
    @Autowired
    private StaticCrossDataMgr staticCrossDataMgr;
    public CrossFightJiFen crossJiFenFight;
    public CrossFightKnock crossFightKnock;
    public CrossFightFinal crossFightFinal;

    private final Stopwatch stopwatch = Stopwatch.createUnstarted();


    /**
     * 初始化跨服数据
     */
    public void initCross() {
        LogUtil.info("开始加载数据到缓存");
        stopwatch.reset().start();
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        if (crossFightTable == null) {
            crossFightTable = new CrossFightTable();
            crossFightTable.setCrossId(crossId);
            crossFightTableDao.insert(crossFightTable);
        }
        try {
            Map<Integer, CrossShopBuy> crossShopBuyMap = crossFightTable.dserCrossShop();
            CrossFightCache.getCrossShopMap().putAll(crossShopBuyMap);
            LinkedHashMap<Long, Long> dserJyRankMap = crossFightTable.dserJyRankMap();
            CrossFightCache.getJyRankMap().putAll(dserJyRankMap);
            LinkedHashMap<Long, Long> dserDfRankMap = crossFightTable.dserDfRankMap();
            CrossFightCache.getDfRankMap().putAll(dserDfRankMap);
        } catch (InvalidProtocolBufferException e) {
            LogUtil.error(e);
        }
        LogUtil.info("跨服战表初始化完成耗时 {}", stopwatch.stop());


        LogUtil.info("开始查询玩家数据 并放入到缓存");
        stopwatch.reset().start();
        /** 缓存玩家数据 */
        List<CrossFightAthleteTable> fightAthleteTableDaoAll = crossFightAthleteTableDao.findAll();
        if (fightAthleteTableDaoAll != null) {
            for (CrossFightAthleteTable athleteTable : fightAthleteTableDaoAll) {
                Athlete athlete = athleteTable.getAthlete();
                if (athlete != null) {
                    CrossFightCache.addAthlete(athlete);
                }
            }
        }
        LogUtil.info("玩家数据缓存完成耗时 {}", stopwatch.stop());


        LogUtil.info("开始查询玩家积分数据 并放入到缓存");
        stopwatch.reset().start();
        List<CrossFightPlayerJifenTable> crossFightPlayerJifenTableDaoAll = crossFightPlayerJifenTableDao.findAll();
        if (crossFightPlayerJifenTableDaoAll != null) {
            for (CrossFightPlayerJifenTable crossFightPlayerJifenTable : crossFightPlayerJifenTableDaoAll) {
                JiFenPlayer jiFenPlayer = crossFightPlayerJifenTable.getJiFenPlayer();
                if (jiFenPlayer != null) {
                    CrossFightCache.addJifenPlayer(jiFenPlayer);


                    if( jiFenPlayer.getRoleId() == 8103260008651L ||
                            jiFenPlayer.getRoleId() == 8103260023803L ||
                            jiFenPlayer.getRoleId() == 8103260012692L ||
                            jiFenPlayer.getRoleId() == 8103260000065L ||
                            jiFenPlayer.getRoleId() == 8103260025407L){

                        List<CrossTrend> crossTrends = jiFenPlayer.crossTrends;
                        for (CrossTrend crossTrend : crossTrends) {
                            String[] trendParam = crossTrend.getTrendParam();

                            String beginTime = DateHelper.formatDateTime(new Date(crossTrend.getTrendTime()*1000L), DateHelper.format1);

                            if(crossTrend.getTrendId() ==1){
                                LogUtil.info("{}\t{}\t{}\t 跨服战商店兑换 您在积分商店中兑换了 {} ，消耗了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }
                            if(crossTrend.getTrendId() ==2){
                                LogUtil.info("{}\t{}\t{}\t 跨服战下注胜利 您支持的选手 {} 获得胜利，作为下注回报，您获得了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }
                            if(crossTrend.getTrendId() ==3){
                                LogUtil.info("{}\t{}\t{}\t 跨服战下注失败 您支持的选手 {} 不幸落败，作为下注安慰，您获得了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }
                            if(crossTrend.getTrendId() ==4){
                                LogUtil.info("{}\t{}\t{}\t 跨服战排名领奖 您在跨服战中排名第 {} ，领取了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }
                            if(crossTrend.getTrendId() ==5){
                                LogUtil.info("{}\t{}\t{}\t 连胜积分* 您在军团军团争霸中获得 {} 连胜，获得了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }
                            if(crossTrend.getTrendId() ==6){
                                LogUtil.info("{}\t{}\t{}\t 终结积分*您在军团军团争霸中终结了 {} 连胜，获得了 {} 积分",beginTime,jiFenPlayer.getRoleId(),jiFenPlayer.getNick(),trendParam[0],trendParam[1]);
                            }


                        }

                    }
                }
            }
        }
        LogUtil.info("开始查询玩家积分数据 完成耗时{}", stopwatch.stop());
        stopwatch.reset().start();
        if (!CrossFightCache.getJifenPlayerMap().isEmpty()) {
            sortJiFen();
        }
        LogUtil.info("玩家积分数据排序完成耗时 {}", stopwatch.stop());

        LogUtil.info("开始查询战斗记录 并放入到缓存");
        stopwatch.reset().start();
        /** 初始跨服战排行信息 */
        CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
        if (crossFightInfoTable == null) {
            crossFightInfoTable = new CrossFightInfoTable();
            crossFightInfoTable.setCrossId(crossId);
            crossFightInfoTableDao.insert(crossFightInfoTable);
        }
        try {
            Map<Integer, KnockoutBattleGroup> dfKnockoutBattleGroupMap = crossFightInfoTable.dserDfKnockoutBattleGroups();
            CrossFightCache.getDfKnockoutBattleGroups().putAll(dfKnockoutBattleGroupMap);
            Map<Integer, KnockoutBattleGroup> jyKnockoutBattleGroupMap = crossFightInfoTable.dserJyKnockoutBattleGroups();
            CrossFightCache.getJyKnockoutBattleGroups().putAll(jyKnockoutBattleGroupMap);
            Map<Integer, CompetGroup> dfFinalBattleGroups = crossFightInfoTable.dserDFFinalBattleGroups();
            CrossFightCache.getDfFinalBattleGroups().putAll(dfFinalBattleGroups);
            Map<Integer, CompetGroup> jyFinalBattleGroups = crossFightInfoTable.dserJYFinalBattleGroups();
            CrossFightCache.getJyFinalBattleGroups().putAll(jyFinalBattleGroups);
        } catch (InvalidProtocolBufferException e) {
            LogUtil.error(e);
        }
        LogUtil.info("战斗记录查询完成 并放入到缓存耗时 {}", stopwatch.stop());


        LogUtil.info("开始查询战报记录 并放入到缓存");
        stopwatch.reset().start();
        /** 初始化战报 */
        CrossFightInfoRecordsTable crossFightInfoRecordsTable = crossFightRecordsTableDao.get(crossId);
        if (crossFightInfoRecordsTable == null) {
            crossFightInfoRecordsTable = new CrossFightInfoRecordsTable();
            crossFightInfoRecordsTable.setCrossId(crossId);
            crossFightRecordsTableDao.insert(crossFightInfoRecordsTable);
        }
        try {
            LinkedHashMap<Integer, CrossRecord> recordLinkedHashMap = crossFightInfoRecordsTable.dserCrossRecrods();
            CrossFightCache.getCrossRecords().putAll(recordLinkedHashMap);
            Map<Integer, CrossRptAtk> crossRptAtkMap = crossFightInfoRecordsTable.dserCrossRptAtks();
            CrossFightCache.getCrossRptAtks().putAll(crossRptAtkMap);
        } catch (InvalidProtocolBufferException e) {
            LogUtil.error(e);
        }
        LogUtil.info("战报记录查询完成 并放入到缓存耗时 {}", stopwatch.stop());
    }

    /**
     * 添加战斗记录
     *
     * @param myRecord
     */
    public void addCrossRecord(CrossRecord myRecord) {
        if (myRecord != null) {
            CrossFightCache.getCrossRecords().put(myRecord.getReportKey(), myRecord);
            CrossFightInfoRecordsTable fightInfoRecordsTable = crossFightRecordsTableDao.get(crossId);
            if (fightInfoRecordsTable == null) {
                fightInfoRecordsTable = new CrossFightInfoRecordsTable();
                fightInfoRecordsTable.setCrossId(crossId);
                crossFightRecordsTableDao.insert(fightInfoRecordsTable);
            }
            Collection<CrossRecord> crossRecords = CrossFightCache.getCrossRecords().values();
            byte[] crossRecords1 = fightInfoRecordsTable.serCrossRecords(crossRecords);
            fightInfoRecordsTable.setRecords(crossRecords1);
            crossFightRecordsTableDao.update(fightInfoRecordsTable);
        }
    }

    /**
     * 添加战报
     *
     * @param atk
     */
    public void addCrossRptAtk(CrossRptAtk atk) {
        if (atk != null) {
            CrossFightCache.getCrossRptAtks().put(atk.getReportKey(), atk);
            Collection<CrossRptAtk> crossRptAtks = CrossFightCache.getCrossRptAtks().values();
            CrossFightInfoRecordsTable fightInfoRecordsTable = crossFightRecordsTableDao.get(crossId);
            if (fightInfoRecordsTable == null) {
                fightInfoRecordsTable = new CrossFightInfoRecordsTable();
                fightInfoRecordsTable.setCrossId(crossId);
                byte[] crossRptAtks1 = fightInfoRecordsTable.serCrossRptAtks(crossRptAtks);
                fightInfoRecordsTable.setRptAtks(crossRptAtks1);
                crossFightRecordsTableDao.insert(fightInfoRecordsTable);
            } else {
                byte[] crossRptAtks1 = fightInfoRecordsTable.serCrossRptAtks(crossRptAtks);
                fightInfoRecordsTable.setRptAtks(crossRptAtks1);
                crossFightRecordsTableDao.update(fightInfoRecordsTable);
            }
        }
    }

    /**
     * 积分排序
     */
    public void sortJiFen() {
        List<Entry<Long, JiFenPlayer>> infoIds = new ArrayList<Entry<Long, JiFenPlayer>>(CrossFightCache.getJifenPlayerMap().entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<Long, JiFenPlayer>>() {
                @Override
                public int compare(Entry<Long, JiFenPlayer> o1, Entry<Long, JiFenPlayer> o2) {
                    JiFenPlayer j1 = o1.getValue();
                    JiFenPlayer j2 = o2.getValue();

                    if (j2.getJifen() > j1.getJifen()) {
                        return 1;
                    } else if (j2.getJifen() < j1.getJifen()) {
                        return -1;
                    } else {

                        Athlete a1 = CrossFightCache.getAthlete(j1.getRoleId());
                        Athlete a2 = CrossFightCache.getAthlete(j2.getRoleId());
                        long f1 = (a1 == null ? 0 : a1.getFight());
                        long f2 = (a2 == null ? 0 : a2.getFight());

                        if (f2 > f1) {
                            return 1;
                        } else if (f2 < f1) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<Long, JiFenPlayer> newMap = new LinkedHashMap<Long, JiFenPlayer>();
        for (Entry<Long, JiFenPlayer> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        CrossFightCache.getJifenPlayerMap().clear();
        CrossFightCache.getJifenPlayerMap().putAll(newMap);
    }

    /**
     * DF参赛者排序
     */
    public void sortDfAthlete() {
        sortAthlete(CrossFightCache.getDfAthleteMap());
    }

    /**
     * JY参赛者排序
     */
    public void sortJyAthlete() {
        sortAthlete(CrossFightCache.getJyAthleteMap());
    }

    /**
     * 排序
     *
     * @param athleteLinkedHashMap
     */
    private void sortAthlete(LinkedHashMap<Long, Athlete> athleteLinkedHashMap) {
        List<Entry<Long, Athlete>> infoIds = new ArrayList<Entry<Long, Athlete>>(athleteLinkedHashMap.entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<Long, Athlete>>() {
                @Override
                public int compare(Entry<Long, Athlete> o1, Entry<Long, Athlete> o2) {
                    Athlete a1 = o1.getValue();
                    Athlete a2 = o2.getValue();
                    JiFenPlayer j1 = CrossFightCache.getJifenPlayerMap().get(a1.getRoleId());
                    JiFenPlayer j2 = CrossFightCache.getJifenPlayerMap().get(a2.getRoleId());
                    if (j2.getJifen() > j1.getJifen()) {
                        return 1;
                    } else if (j2.getJifen() < j1.getJifen()) {
                        return -1;
                    } else {
                        if (a2.getFight() > a1.getFight()) {
                            return 1;
                        } else if (a2.getFight() < a1.getFight()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<Long, Athlete> newMap = new LinkedHashMap<Long, Athlete>();
        for (Entry<Long, Athlete> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        athleteLinkedHashMap.clear();
        athleteLinkedHashMap.putAll(newMap);
    }

    /**
     * 跨服商店刷新逻辑
     */
    public void refreshCrossShopLogic() {
        int today = TimeHelper.getCurrentDay();
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        if (today == crossFightTable.getCrossShopRefreshDate()) {
            return; // 今天已刷新过，跳过
        }
        // 判断是否可以刷新
        int day = TimeHelper.getDayOfCrossWar();
        if (day >= CrossConst.STAGE.STATE_FINAL) {
            // 清空之前的记录，重新生成数据
            CrossFightCache.getCrossShopMap().clear();
            for (StaticCrossShop shop : staticCrossDataMgr.getCrossShopMap().values()) {
                // 只记录珍宝商品
                if (shop.isTreasure()) {
                    CrossFightCache.getCrossShopMap().put(shop.getGoodID(), new CrossShopBuy(shop.getGoodID(), 0, shop.getTotalNumber()));
                }
            }
            crossFightTable.setCrossShopRefreshDate(today);
            Collection<CrossShopBuy> crossShopBuys = CrossFightCache.getCrossShopMap().values();
            byte[] serCrossShopMap = crossFightTable.serCrossShopMap(crossShopBuys);
            crossFightTable.setCrossShop(serCrossShopMap);
            crossFightTableDao.update(crossFightTable);
            LogUtil.info("跨服商店刷新完成");
        }
    }

    /**
     * 获取冠軍
     *
     * @param group
     * @return
     */
    public Athlete getTop1(int group) {
        CompetGroup cg = null;
        if (group == CrossConst.DF_Group) {
            cg = CrossFightCache.getDfFinalBattleGroups().get(3);
        } else {
            cg = CrossFightCache.getJyFinalBattleGroups().get(3);
        }
        if (cg != null) {
            if (cg.getWin() == 1) {
                if (cg.getC1() != null) {
                    return CrossFightCache.getAthlete(cg.getC1().getRoleId());
                }
            } else {
                if (cg.getC2() != null) {
                    return CrossFightCache.getAthlete(cg.getC2().getRoleId());
                }
            }
        }
        return null;
    }

    /**
     * 獲取季军
     *
     * @param group
     * @return
     */
    public Athlete getTop2(int group) {
        CompetGroup cg = null;
        if (group == CrossConst.DF_Group) {
            cg = CrossFightCache.getDfFinalBattleGroups().get(3);
        } else {
            cg = CrossFightCache.getJyFinalBattleGroups().get(3);
        }
        if (cg != null) {
            if (cg.getWin() == 1) {
                if (cg.getC2() != null) {
                    return CrossFightCache.getAthlete(cg.getC2().getRoleId());
                }
            } else {
                if (cg.getC1() != null) {
                    return CrossFightCache.getAthlete(cg.getC1().getRoleId());
                }
            }
        }
        return null;
    }

    /**
     * 獲取季军
     *
     * @param group
     * @return
     */
    public Athlete getTop3(int group) {
        CompetGroup cg = null;
        if (group == CrossConst.DF_Group) {
            cg = CrossFightCache.getDfFinalBattleGroups().get(4);
        } else {
            cg = CrossFightCache.getJyFinalBattleGroups().get(4);
        }
        if (cg != null) {
            if (cg.getWin() == 1) {
                if (cg.getC1() != null) {
                    return CrossFightCache.getAthlete(cg.getC1().getRoleId());
                }
            } else {
                if (cg.getC2() != null) {
                    return CrossFightCache.getAthlete(cg.getC2().getRoleId());
                }
            }
        }
        return null;
    }

    public Athlete getTop4(int group) {
        CompetGroup cg = null;
        if (group == CrossConst.DF_Group) {
            cg = CrossFightCache.getDfFinalBattleGroups().get(4);
        } else {
            cg = CrossFightCache.getJyFinalBattleGroups().get(4);
        }
        if (cg != null) {
            if (cg.getWin() == 1) {
                if (cg.getC2() != null) {
                    return CrossFightCache.getAthlete(cg.getC2().getRoleId());
                }
            } else {
                if (cg.getC1() != null) {
                    return CrossFightCache.getAthlete(cg.getC1().getRoleId());
                }
            }
        }
        return null;
    }

    // 排在一起
    public void totalRank(LinkedHashMap<Long, Long> totalMap, LinkedHashMap<Long, Long> tempMap) {
        for (Entry<Long, Long> entry : tempMap.entrySet()) {
            if (!totalMap.containsKey(entry.getKey())) {
                totalMap.put(entry.getKey(), entry.getValue());
            }
        }
    }

    /**
     * 排序by积分
     *
     * @param map
     */
    public void sortMapByJifen(LinkedHashMap<Long, Long> map) {
        List<Entry<Long, Long>> infoIds = new ArrayList<Entry<Long, Long>>(map.entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<Long, Long>>() {
                @Override
                public int compare(Entry<Long, Long> o1, Entry<Long, Long> o2) {
                    JiFenPlayer j1 = CrossFightCache.getJifenPlayerMap().get(o1.getKey());
                    JiFenPlayer j2 = CrossFightCache.getJifenPlayerMap().get(o2.getKey());

                    if (j2.getJifen() > j1.getJifen()) {
                        return 1;
                    } else if (j2.getJifen() < j1.getJifen()) {
                        return -1;
                    } else {

                        Athlete a1 = CrossFightCache.getAthlete(o1.getKey());
                        Athlete a2 = CrossFightCache.getAthlete(o2.getKey());
                        long f1 = a1 == null ? 0 : a1.getFight();
                        long f2 = a2 == null ? 0 : a2.getFight();

                        if (f2 > f1) {
                            return 1;
                        } else if (f2 < f1) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<Long, Long> newMap = new LinkedHashMap<Long, Long>();
        for (Entry<Long, Long> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        map.clear();
        map.putAll(newMap);
    }

    public void sortMapByBet(LinkedHashMap<Long, Integer> map) {
        List<Entry<Long, Integer>> infoIds = new ArrayList<Entry<Long, Integer>>(map.entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<Long, Integer>>() {
                @Override
                public int compare(Entry<Long, Integer> o1, Entry<Long, Integer> o2) {
                    if (o2.getValue() > o1.getValue()) {
                        return 1;
                    } else if (o2.getValue() < o1.getValue()) {
                        return -1;
                    } else {
                        Athlete a1 = CrossFightCache.getAthlete(o1.getKey());
                        Athlete a2 = CrossFightCache.getAthlete(o2.getKey());
                        long f1 = a1 == null ? 0 : a1.getFight();
                        long f2 = a2 == null ? 0 : a2.getFight();

                        if (f2 > f1) {
                            return 1;
                        } else if (f2 < f1) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<Long, Integer> newMap = new LinkedHashMap<Long, Integer>();
        for (Entry<Long, Integer> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        map.clear();
        map.putAll(newMap);
    }
}