package com.game.dataMgr;

import com.game.common.ServerSetting;
import com.game.constant.ActCollegeConst;
import com.game.constant.ActivityConst;
import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.activity.StaticActMonopolyDataMgr;
import com.game.dataMgr.activity.StaticActRedBagDataMgr;
import com.game.dataMgr.activity.simple.StaticActStrokeDataMgr;
import com.game.dataMgr.activity.simple.StaticActVipDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.s.*;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author
 * @ClassName: StaticActivityDataMgr
 * @Description: 活动数据
 */
@Component
public class StaticActivityDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    @Autowired
    private ServerSetting serverSetting;

    /** key:activityId  */
    private Map<Integer, List<StaticActAward>> awardMap = new HashMap<>();

    /** key:awardId  */
    private Map<Integer, StaticActAward> actAwardMap = new HashMap<>();

	private List<ActivityBase> activityList = new ArrayList<>();

    private Map<Integer, StaticActMecha> actMechaMap = new HashMap<>();

    private Map<Integer, StaticActQuota> actQuotaMap = new HashMap<>();

    private Map<Integer, StaticActRebate> actRebateMap = new HashMap<>();

    private Map<Integer, StaticActFortune> actFortuneMap = new HashMap<>();

    private Map<Integer, StaticActProfoto> actProfotoMap = new HashMap<>();

    private Map<Integer, List<StaticActRaffle>> actRaffleMap = new HashMap<>();

    private Map<Integer, Map<Integer, List<StaticActRank>>> actRankMap = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActCourse>> actCourseMap = new HashMap<>();

    private Map<Integer, StaticActCourse> actCourseResourceMap = new HashMap<>();

    private Map<Integer, StaticActCourse> actCourseBaseMap = new HashMap<>();

    private Map<Integer, StaticActTech> actTechMap = new HashMap<>();

    private Map<Integer, StaticActGeneral> actGeneralMap = new HashMap<>();

    private Map<Integer, StaticActEverydayPay> actEverydayPayMap = new HashMap<>();

    private Map<Integer, StaticActDestory> actDestoryMap = new HashMap<>();

    private Map<Integer, StaticActVacationland> actVacationlandMap = new HashMap<>();

    private List<StaticActVacationland> villageList = new ArrayList<>();

    private Map<Integer, List<StaticActExchange>> exchangeMap = new HashMap<>();

    private Map<Integer, List<StaticActPartResolve>> resolveMap = new HashMap<>();

    //key1:activityId , key2:type , key3:quality , value:count
    private Map<Integer, Map<Integer, Map<Integer, Integer>>> resolveSlugMap = new HashMap<>();

    private Map<Integer, List<StaticActGamble>> gambleMap = new HashMap<>();

    // 记录同一个activityId所有的awardId
    private Map<Integer, Set<Integer>> activityAwardIdMap = new HashMap<>();

    // 坦克嘉年华活动配置, key:type
    private Map<Integer, List<StaticActEquate>> actEquateListMap = new HashMap<>();

    // key:equateId
    private Map<Integer, StaticActEquate> actEquateKindMap = new HashMap<>();

    private Map<Integer, List<StaticActivityTime>> activityTimeMap = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActivityEffect>> activityEffectMap = new HashMap<>();

    private Map<Integer, StaticActivityProp> activityPropMap = new HashMap<>();

    private Map<Integer, StaticCharacterChange> characterChangeMap = new HashMap<>();

    private Map<Integer, StaticActivityM1a2> activityM1a2Map = new HashMap<>();

    private Map<Integer, StaticActivityFlower> activityFlowerMap = new HashMap<>();

    private List<StaticActPayRebate> actPayRebateList = new ArrayList<>();

    private Map<Integer, Map<Integer, StaticActPirate>> actPirateAllMap = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActivityChange>> activityChangeMap = new HashMap<>();

    private StaticActBoss actBoss = null;

    private Map<Integer, StaticActHilarityPray> actHilarityPrayMap = new HashMap<>();

    private Map<Integer, StaticActWorshipGod> actWorshipGodMap = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActWorshipTask>> actWorshipTaskMap = new HashMap<>();

    private Map<Integer, List<StaticActRebelTeam>> actRebelLvMap = new HashMap<>();//还是先写成支持多个等级的

    private Map<Integer, StaticActRebelTeam> actRebelIdMap = new HashMap<>();

    // key:rebelType_lv_tankId
    private Map<String, StaticActRebelAttr> attrMap = new HashMap<>();

    private StaticActRebel actRebel;

    private Map<Integer, StaticActWorshipGodData> actWorshipGodDataMap = new HashMap<>();

    private Map<Integer, StaticActFoison> actFoisonMap = new HashMap<>();

    private Map<Integer, StaticActCollegeSubject> actCollegeSubjectMap = new HashMap<>();

    private List<StaticActCollegeEducation> actCollegeEducationList = new ArrayList<>();

    //淬炼活动, KEY0:淬炼活动ID, KEY1: 淬炼方式, VALUE:淬炼暴击信息
    private Map<Integer, TreeMap<Integer, StaticActPartCrit>> partCritMap = new HashMap<>();

    //部件淬炼大师活动, KEY0:淬炼方式, VALUE:淬炼大师信息
    private Map<Integer, StaticActPartMaster> partSmeltMasterMap = new HashMap<>();

    //部件淬炼大师活动中氪金抽奖, KEY0:抽奖方式, VALUE:抽奖配置
    private Map<Integer, StaticActPartMasterLottery> partSmeltMasterLotteryMap = new HashMap<>();

    //能量灌注配置
    private Map<Integer, List<StaticActCumulativePay>> staticActCumulativePayMap;

    //自选豪礼配置
    private Map<Integer, StaticActChooseGift> staticActChooseGiftMap;

    //兄弟同心buff配置-type,level为键
    private Map<Integer, Map<Integer, StaticActBrotherBuff>> staticActBrotherBuffMap;

    //兄弟同心任务列表 type为键
    private Map<Integer, List<StaticActBrotherTask>> staticActBrotherTaskMap;

    /**
     * 超时空财团商品 awardid为键
     */
    private Map<Integer, Map<Integer, List<StaticActQuinn>>> staticActQuinnMap;

    /**
     * 超时空财团金币刷新累积奖励 type为键
     */
    private Map<Integer, List<StaticActQuinnEasteregg>> staticActQuinnEastereggMap;
    /**
     * 超时空财团金币刷新所需金币
     */
    private Map<Integer, StaticActQuinnRefresh> staticActQuinnRefreshMap;


    //荣誉探险活动配置表
    private Map<Integer, StaticActMedalofhonor> medalofhonorMap = new HashMap<>();
    //KEY:荣誉勋章宝箱类型, VALUE:宝箱列表
    private Map<Integer, List<StaticActMedalofhonor>> medalofhonorListMap = new HashMap<>();
    //KEY:荣誉勋章商店商品ID, VALUE:商品信息
    private Map<Integer, StaticActMedalofhonorRule> medalofhonorRuleMap = new HashMap<>();

    //荣誉勋章探险价格
    private StaticActMedalofhonorExplore actMedalofhonorExplore;

    @Autowired
    private StaticActMonopolyDataMgr staticActMonopolyDataMgr;
    //大咖带队活动配置
    @Autowired
    private StaticActVipDataMgr staticActVipDataMgr;
    @Autowired
    private StaticActStrokeDataMgr staticActStrokeDataMgr;
    @Autowired
    private StaticActRedBagDataMgr staticActRedBagDataMgr;


    //兄弟同心降低战损值
    private int reduceloss;

    @Override
    public void init() {
        List<StaticActAward> list = staticDataDao.selectActAward();

        Map<Integer, StaticActAward> actAwardMap = new HashMap<>();
        Map<Integer, List<StaticActAward>> awardMap = new HashMap<>();
        for (StaticActAward e : list) {
            int activityId = e.getActivityId();
            actAwardMap.put(e.getKeyId(), e);
            // 活动
            List<StaticActAward> eeList = awardMap.get(activityId);
            if (eeList == null) {
                eeList = new ArrayList<>();
                awardMap.put(activityId, eeList);
            }
            eeList.add(e);
        }
        this.awardMap = awardMap;
        this.actAwardMap = actAwardMap;

        List<StaticActRank> srankList = staticDataDao.selectActRankList();
        Map<Integer, Map<Integer, List<StaticActRank>>> actRankMap = new HashMap<>();
        for (StaticActRank e : srankList) {
            int activityId = e.getActivityId();
            Map<Integer, List<StaticActRank>> rankListMap = actRankMap.get(activityId);
            if (rankListMap == null) {
                rankListMap = new HashMap<>();
                actRankMap.put(activityId, rankListMap);
            }
            int sortId = e.getSortId();
            List<StaticActRank> sortRankList = rankListMap.get(sortId);
            if (sortRankList == null) {
                sortRankList = new ArrayList<>();
                rankListMap.put(sortId, sortRankList);
            }
            sortRankList.add(e);
        }
        this.actRankMap = actRankMap;

        this.actMechaMap = staticDataDao.selectActMecha();
        this.actQuotaMap = staticDataDao.selectActQuota();
        this.actRebateMap = staticDataDao.selectActRebate();
        this.actFortuneMap = staticDataDao.selectActFortune();
        this.actProfotoMap = staticDataDao.selectActProfoto();
        this.activityPropMap = staticDataDao.selectActivityPropMap();
        this.characterChangeMap = staticDataDao.selectCharacterChangeMap();
        this.activityM1a2Map = staticDataDao.selectActivityM1a2Map();
        this.activityFlowerMap = staticDataDao.selectActivityFlowerMap();
        this.actPayRebateList = staticDataDao.selectActPayRebateList();
        this.actBoss = staticDataDao.selectActBoss();
        this.actHilarityPrayMap = staticDataDao.selectActHilarityPrayMap();
        this.actWorshipGodMap = staticDataDao.selectActWorshipGodMap();
        this.actWorshipGodDataMap = staticDataDao.selectActWorshipGodDataMap();
        this.actFoisonMap = staticDataDao.selectActFoison();
        this.actCollegeSubjectMap = staticDataDao.selectStaticActCollegeSubjectMap();
        this.actCollegeEducationList = staticDataDao.selectStaticActCollegeEducationList();
        this.partSmeltMasterMap = staticDataDao.selectStaticActPartMaster();
        this.staticActChooseGiftMap = staticDataDao.selectActChooseGift();
        this.reduceloss = staticDataDao.selectActBrotherReduceloss();

        tankRaffle();
        course();
        activity();
        initTech();
        initGeneral();
        initEverydayPay();
        initDestory();
        initVacationland();
        initExchange();
        initPartResolve();
        initGamble();
        initPirate();
        initWorshipTask();
        initActivityAwardIdMap();
        initActEquateList();
        initActivityTimeMap();
        initActivityEffectMap();
        initActivityChange();
        initActRebel();
        initActPartCrit();
        initActPartSmeltMaster();
        initActCumulativepay();
        initActBrotherBuff();
        initActBrotherTask();
        initActQuinn();
        initActQuinnEasteregg();
        initActQuinnRefresh();
        initActMadelofhonor();

        //大富翁(圣诞宝藏)活动
        staticActMonopolyDataMgr.init();
        //大咖带队活动
        staticActVipDataMgr.init();
        //闪击行动活动
        staticActStrokeDataMgr.init();
        //抢红包活动
        staticActRedBagDataMgr.init();
    }

    /**
     * 初始化荣誉勋章活动
     */
    private void initActMadelofhonor() {
        this.medalofhonorListMap.clear();
        Map<Integer, StaticActMedalofhonor> map = staticDataDao.selectActMedalOfhonor();
        for (Map.Entry<Integer, StaticActMedalofhonor> entry : map.entrySet()) {
            StaticActMedalofhonor data = entry.getValue();
            List<StaticActMedalofhonor> list = medalofhonorListMap.get(data.getType());
            if (list == null) medalofhonorListMap.put(data.getType(), list = new ArrayList<StaticActMedalofhonor>());
            list.add(data);
        }

        this.medalofhonorMap = map;
        //荣誉勋章索敌价格表
        this.actMedalofhonorExplore = staticDataDao.selectActMedalofhonorExplore();
        //荣誉勋章商店信息
        medalofhonorRuleMap = staticDataDao.selectActMedalofhonorRule();
    }


    /**
     * 初始化奎恩亲王（超时空财团）金币刷新奖励列表
     */
    private void initActQuinnEasteregg() {
        List<StaticActQuinnEasteregg> list = staticDataDao.selectActQuinnEasteregg();
        Map<Integer, List<StaticActQuinnEasteregg>> staticActQuinnEastereggMap = new HashMap<>();
        Integer type;
        List<StaticActQuinnEasteregg> temp;
        for (StaticActQuinnEasteregg task : list) {
            type = task.getType();
            temp = staticActQuinnEastereggMap.get(type);
            if (temp == null) {
                temp = new ArrayList<>();
                staticActQuinnEastereggMap.put(type, temp);
            }
            temp.add(task);
        }
        this.setStaticActQuinnEastereggMap(staticActQuinnEastereggMap);
    }

    /**
     * 初始化奎恩亲王（超时空财团）金币刷新费用列表
     */
    private void initActQuinnRefresh() {
        List<StaticActQuinnRefresh> list = staticDataDao.selectActQuinnRefresh();
        Map<Integer, StaticActQuinnRefresh> staticActQuinnRefreshMap = new HashMap<>();
        for (StaticActQuinnRefresh task : list) {
            staticActQuinnRefreshMap.put(task.getType(), task);
        }
        this.setStaticActQuinnRefreshMap(staticActQuinnRefreshMap);
    }

    /**
     * 初始化奎恩亲王（超时空财团）商品列表
     */
    private void initActQuinn() {
        List<StaticActQuinn> list = staticDataDao.selectActQuinn();
        Map<Integer, Map<Integer, List<StaticActQuinn>>> staticActQuinnMap = new HashMap<>();
        Integer awardId;
        Integer type;
        Map<Integer, List<StaticActQuinn>> temp;
        List<StaticActQuinn> temp2;
        for (StaticActQuinn task : list) {
            awardId = task.getAwardid();
            temp = staticActQuinnMap.get(awardId);
            if (temp == null) {
                temp = new HashMap<>();
                staticActQuinnMap.put(awardId, temp);
            }
            type = task.getType();
            temp2 = temp.get(type);
            if (temp2 == null) {
                temp2 = new ArrayList<>();
                temp.put(type, temp2);
            }
            temp2.add(task);
        }
        this.setStaticActQuinnMap(staticActQuinnMap);
    }

    /**
     * 初始化兄弟同心任务列表
     */
    private void initActBrotherTask() {
        List<StaticActBrotherTask> list = staticDataDao.selectActBrotherTask();
        Map<Integer, List<StaticActBrotherTask>> staticActBrotherTaskMap = new HashMap<>();
        Integer type;
        List<StaticActBrotherTask> temp;
        for (StaticActBrotherTask task : list) {
            type = task.getType();
            temp = staticActBrotherTaskMap.get(type);
            if (temp == null) {
                temp = new ArrayList<>();
                staticActBrotherTaskMap.put(type, temp);
            }
            temp.add(task);
        }
        this.staticActBrotherTaskMap = staticActBrotherTaskMap;
    }

    /**
     * 初始化兄弟同心buff数据
     */
    private void initActBrotherBuff() {
        List<StaticActBrotherBuff> list = staticDataDao.selectActBrotherBuff();
        Map<Integer, Map<Integer, StaticActBrotherBuff>> staticActBrotherBuffMap = new HashMap<>();
        Integer type;
        Map<Integer, StaticActBrotherBuff> temp;
        for (StaticActBrotherBuff buff : list) {
            type = buff.getType();
            temp = staticActBrotherBuffMap.get(type);
            if (temp == null) {
                temp = new HashMap<>();
                staticActBrotherBuffMap.put(type, temp);
            }
            temp.put(buff.getLevel(), buff);
        }

        this.staticActBrotherBuffMap = staticActBrotherBuffMap;
    }

    /**
     * 初始化能量灌注配置
     */
    private void initActCumulativepay() {
        List<StaticActCumulativePay> staticActCumulativePayList = staticDataDao.selectActCumulativePay();
        Map<Integer, List<StaticActCumulativePay>> staticActCumulativePayMap = new HashMap<>();
        for (StaticActCumulativePay s : staticActCumulativePayList) {
            List<StaticActCumulativePay> temp = staticActCumulativePayMap.get(s.getActivityid());
            if (temp == null) {
                temp = new ArrayList<>();
                staticActCumulativePayMap.put(s.getActivityid(), temp);
            }
            temp.add(s);
        }
        this.staticActCumulativePayMap = staticActCumulativePayMap;
    }

    /**
     * 初始化部件淬炼大师活动抽奖信息
     */
    private void initActPartSmeltMaster() {
        Map<Integer, StaticActPartMasterLottery> partSmeltMasterLotteryMap0 = new HashMap<>();
        for (Map.Entry<Integer, StaticActPartMasterLottery> entry : staticDataDao.selectStaticActPartMasterLottery().entrySet()) {
            partSmeltMasterLotteryMap0.put(entry.getValue().getCount(), entry.getValue());
        }
        this.partSmeltMasterLotteryMap = partSmeltMasterLotteryMap0;
    }

    /**
     * 初始化淬炼暴击活动
     */
    private void initActPartCrit() {
        Map<Integer, TreeMap<Integer, StaticActPartCrit>> partCritMap = new HashMap<>();
        Map<Integer, StaticActPartCrit> map = staticDataDao.selectActPartCrit();
        for (Map.Entry<Integer, StaticActPartCrit> entry : map.entrySet()) {
            StaticActPartCrit data = entry.getValue();
            TreeMap<Integer, StaticActPartCrit> actMap = partCritMap.get(data.getActivityId());
            if (actMap == null) partCritMap.put(data.getActivityId(), actMap = new TreeMap<>());
            actMap.put(data.getMode(), data);
        }
        this.partCritMap = partCritMap;
    }

    private void initActRebel() {
        List<StaticActRebelTeam> list = staticDataDao.selectStaticActRebelTeamList();
        Map<Integer, List<StaticActRebelTeam>> actRebelLvMap = new HashMap<>();//还是先写成支持多个等级的
        Map<Integer, StaticActRebelTeam> actRebelIdMap = new HashMap<>();
        for (StaticActRebelTeam staticActRebelTeam : list) {
            List<StaticActRebelTeam> sart = actRebelLvMap.get(staticActRebelTeam.getLevel());
            if (sart == null) {
                sart = new ArrayList<>();
                actRebelLvMap.put(staticActRebelTeam.getLevel(), sart);
            }
            sart.add(staticActRebelTeam);
            actRebelIdMap.put(staticActRebelTeam.getRebelId(), staticActRebelTeam);
        }

        this.actRebelLvMap = actRebelLvMap;
        this.actRebelIdMap = actRebelIdMap;

        Map<Integer, StaticActRebelAttr> rebelAttrMap = staticDataDao.selectActRebelAttrMap();
        Map<String, StaticActRebelAttr> attrMap = new HashMap<>();
        for (StaticActRebelAttr attr : rebelAttrMap.values()) {
            attrMap.put(getMapKey(attr.getTankId(), attr.getEnemyLevel()), attr);
        }
        this.attrMap = attrMap;
        this.actRebel = staticDataDao.selectActRebel();
    }

    private void initActEquateList() {
        List<StaticActEquate> list;
        List<StaticActEquate> totalList = staticDataDao.selectActEquateList();
        Map<Integer, List<StaticActEquate>> actEquateListMap = new HashMap<>();
        Map<Integer, StaticActEquate> actEquateKindMap = new HashMap<>();
        for (StaticActEquate equate : totalList) {
            list = actEquateListMap.get(equate.getType());
            if (null == list) {
                list = new ArrayList<>();
                actEquateListMap.put(equate.getType(), list);
            }
            list.add(equate);
            actEquateKindMap.put(equate.getKind(), equate);
        }
        this.actEquateListMap = actEquateListMap;
        this.actEquateKindMap = actEquateKindMap;
    }

    private void initActivityTimeMap() {
        List<StaticActivityTime> list;
        List<StaticActivityTime> totalLst = staticDataDao.selectActivityTimeList();
        Map<Integer, List<StaticActivityTime>> activityTimeMap = new HashMap<>();
        for (StaticActivityTime time : totalLst) {
            list = activityTimeMap.get(time.getActivityId());
            if (null == list) {
                list = new ArrayList<>();
                activityTimeMap.put(time.getActivityId(), list);
            }
            list.add(time);
        }
        this.activityTimeMap = activityTimeMap;
    }

    private void initActivityEffectMap() {
        Map<Integer, StaticActivityEffect> map;
        List<StaticActivityEffect> totalLst = staticDataDao.selectActivityEffectList();
        Map<Integer, Map<Integer, StaticActivityEffect>> activityEffectMap = new HashMap<>();
        for (StaticActivityEffect effect : totalLst) {
            map = activityEffectMap.get(effect.getActivityId());
            if (null == map) {
                map = new HashMap<>();
                activityEffectMap.put(effect.getActivityId(), map);
            }
            map.put(effect.getDay(), effect);
        }
        this.activityEffectMap = activityEffectMap;
    }

    private void initActivityAwardIdMap() {
        List<StaticActivityPlan> planList = staticDataDao.selectStaticActivityPlan();
        Set<Integer> set;
        Map<Integer, Set<Integer>> activityAwardIdMap = new HashMap<>();
        for (StaticActivityPlan plan : planList) {
            set = activityAwardIdMap.get(plan.getActivityId());
            if (null == set) {
                set = new HashSet<>();
                activityAwardIdMap.put(plan.getActivityId(), set);
            }
            set.add(plan.getAwardId());
        }
        this.activityAwardIdMap = activityAwardIdMap;
    }

    private void initActivityChange() {
        List<StaticActivityChange> list = staticDataDao.selectActivityChange();
        Map<Integer, StaticActivityChange> map;
        Map<Integer, Map<Integer, StaticActivityChange>> changeMap = new HashMap<>();
        for (StaticActivityChange change : list) {
            map = changeMap.get(change.getActivityId());
            if (map == null) {
                map = new HashMap<>();
                changeMap.put(change.getActivityId(), map);
            }
            map.put(change.getId(), change);
        }
        this.activityChangeMap = changeMap;
    }

    private void tankRaffle() {
        List<StaticActRaffle> list = staticDataDao.selectActRaffle();
        Map<Integer, List<StaticActRaffle>> actRaffleMap = new HashMap<>();
        for (StaticActRaffle e : list) {
            int activityId = e.getActivityId();
            List<StaticActRaffle> raffleList = actRaffleMap.get(activityId);
            if (raffleList == null) {
                raffleList = new ArrayList<>();
                actRaffleMap.put(activityId, raffleList);
            }
            raffleList.add(e);
        }
        this.actRaffleMap = actRaffleMap;
    }

    private void course() {
        List<StaticActCourse> list = staticDataDao.selectActCourse();
        Map<Integer, Map<Integer, StaticActCourse>> actCourseMap = new HashMap<>();
        actCourseResourceMap = new HashMap<>();
        actCourseBaseMap = new HashMap<>();
        for (StaticActCourse e : list) {
            int activityId = e.getActivityId();
            if (e.getType() == 1) { // 关卡
                Map<Integer, StaticActCourse> courseMap = actCourseMap.get(activityId);
                if (courseMap == null) {
                    courseMap = new HashMap<>();
                    actCourseMap.put(activityId, courseMap);
                }
                courseMap.put(e.getSctionId(), e);
            } else if (e.getType() == 2) { // 资源点
                actCourseResourceMap.put(activityId, e);
            } else if (e.getType() == 3) { // 基地
                actCourseBaseMap.put(activityId, e);
            }
        }
        this.actCourseMap = actCourseMap;
    }

    private void activity() {
        int activityMoldId = serverSetting.getActMoldId();
        Map<Integer, StaticActivity> activityMap = staticDataDao.selectStaticActivity();
        List<StaticActivityPlan> planList = staticDataDao.selectStaticActivityPlan();
        Date openTime = DateHelper.parseDate(serverSetting.getOpenTime());
        List<ActivityBase> activityList = new ArrayList<>();
        for (StaticActivityPlan e : planList) {
            int activityId = e.getActivityId();
            StaticActivity staticActivity = activityMap.get(activityId);
            if (staticActivity == null) {
                continue;
            }
            int moldId = e.getMoldId();
            if (activityMoldId != moldId) {
                continue;
            }
            ActivityBase activityBase = new ActivityBase();
            activityBase.setOpenTime(openTime);
            activityBase.setPlan(e);
            activityBase.setStaticActivity(staticActivity);
            boolean flag = activityBase.initData();
            if (flag) {
                activityList.add(activityBase);
            }
        }
        this.activityList = activityList;
    }

    private void initTech() {
        this.actTechMap = staticDataDao.selectActTech();
    }

    private void initGeneral() {
        this.actGeneralMap = staticDataDao.selectActGeneral();
    }

    private void initEverydayPay() {
        this.actEverydayPayMap = staticDataDao.selectActEveryDayPay();
    }

    private void initDestory() {
        this.actDestoryMap = staticDataDao.selectActDestory();
    }

    private void initVacationland() {
        Map<Integer, StaticActVacationland> actVacationlandMap = staticDataDao.selectActVacationland();
        this.actVacationlandMap = actVacationlandMap;
        int vid = 0;
        Iterator<StaticActVacationland> it = actVacationlandMap.values().iterator();
        List<StaticActVacationland> villageList = new ArrayList<>();
        while (it.hasNext()) {
            StaticActVacationland next = it.next();
            if (next.getVillageId() != vid) {
                villageList.add(next);
                vid = next.getVillageId();
            }
        }
        this.villageList = villageList;
    }

    private void initExchange() {
        List<StaticActExchange> exchangeList = staticDataDao.selectActExchange();
        Map<Integer, List<StaticActExchange>> exchangeMap = new HashMap<>();
        for (StaticActExchange e : exchangeList) {
            int activityId = e.getActivityId();

            List<StaticActExchange> eList = exchangeMap.get(activityId);
            if (eList == null) {
                eList = new ArrayList<>();
                exchangeMap.put(activityId, eList);
            }
            eList.add(e);
        }
        this.exchangeMap = exchangeMap;
    }

    private void initPartResolve() {
        List<StaticActPartResolve> partResolveList = staticDataDao.selectActPartResolve();
        Map<Integer, List<StaticActPartResolve>> resolveMap = new HashMap<>();
        Map<Integer, Map<Integer, Map<Integer, Integer>>> resolveSlugMap = new HashMap<>();
        for (StaticActPartResolve e : partResolveList) {
            int activityId = e.getActivityId();

            List<StaticActPartResolve> eList = resolveMap.get(activityId);
            if (eList == null) {
                eList = new ArrayList<>();
                resolveMap.put(activityId, eList);
            }

            List<List<Integer>> resolveList = e.getResolveList();
            if (resolveList != null) {
                for (List<Integer> eresolve : resolveList) {
                    int type = eresolve.get(0);
                    int quality = eresolve.get(1);
                    int count = eresolve.get(2);

                    Map<Integer, Map<Integer, Integer>> amap = resolveSlugMap.get(activityId);
                    if (amap == null) {
                        amap = new HashMap<>();
                        resolveSlugMap.put(activityId, amap);
                    }
                    Map<Integer, Integer> tmap = amap.get(type);
                    if (tmap == null) {
                        tmap = new HashMap<>();
                        amap.put(type, tmap);
                    }
                    if (!tmap.containsKey(quality)) {
                        tmap.put(quality, count);
                    }
                }
            }

            eList.add(e);
        }
        this.resolveMap = resolveMap;
        this.resolveSlugMap = resolveSlugMap;
    }

    private void initGamble() {
        List<StaticActGamble> gambleList = staticDataDao.selectActGamble();
        Map<Integer, List<StaticActGamble>> gambleMap = new HashMap<>();
        for (StaticActGamble e : gambleList) {
            int activityId = e.getActivityId();

            List<StaticActGamble> eList = gambleMap.get(activityId);
            if (eList == null) {
                eList = new ArrayList<>();
                gambleMap.put(activityId, eList);
            }

            eList.add(e);
        }
        this.gambleMap = gambleMap;
    }

    private void initPirate() {
        List<StaticActPirate> list = staticDataDao.selectActPirateList();
        Map<Integer, StaticActPirate> map;
        Map<Integer, Map<Integer, StaticActPirate>> actPirateAllMap = new HashMap<>();
        for (StaticActPirate pirate : list) {
            map = actPirateAllMap.get(pirate.getAwardId());
            if (map == null) {
                map = new HashMap<>();
                actPirateAllMap.put(pirate.getAwardId(), map);
            }
            map.put(pirate.getId(), pirate);
        }
        this.actPirateAllMap = actPirateAllMap;
    }

    private void initWorshipTask() {
        List<StaticActWorshipTask> list = staticDataDao.selectActWorshipTaskList();
        Map<Integer, StaticActWorshipTask> map;
        Map<Integer, Map<Integer, StaticActWorshipTask>> actWorshipTaskMap = new HashMap<>();
        for (StaticActWorshipTask task : list) {
            map = actWorshipTaskMap.get(task.getAwardId());
            if (map == null) {
                map = new HashMap<>();
                actWorshipTaskMap.put(task.getAwardId(), map);
            }
            map.put(task.getDay(), task);
        }
        this.actWorshipTaskMap = actWorshipTaskMap;
    }

    public List<ActivityBase> getActivityList() {
        return activityList;
    }

    public List<StaticActAward> getActAwardById(int activityId) {
        return awardMap.get(activityId);
    }

    public StaticActAward getActAward(int keyId) {
        return actAwardMap.get(keyId);
    }

    public ActivityBase getActivityById(int activityId) {
        for (ActivityBase e : activityList) {
            StaticActivity a = e.getStaticActivity();
            StaticActivityPlan plan = e.getPlan();
            if (a == null || plan == null) {
                continue;
            }
            if (a.getActivityId() == activityId && e.getStep() != ActivityConst.OPEN_CLOSE) {
                return e;
            }
        }
        return null;
    }

    public ActivityBase getActivityById(int activityId, int plat) {
        int platFlag = 1;// 默认安卓用户
        if (plat == 94 || plat == 95 || plat > 500) {
            platFlag = 2;// IOS用户
        }
        for (ActivityBase e : activityList) {
            StaticActivity a = e.getStaticActivity();
            StaticActivityPlan plan = e.getPlan();
            if (a == null || plan == null) {
                continue;
            }
            if (plan.getPlat() == 1 && platFlag == 2) {// 如果是安卓平台,IOS玩家不可见
                continue;
            } else if (plan.getPlat() == 2 && platFlag == 1) {// 如果是IOS平台,安卓玩家不可见
                continue;
            }
            if (a.getActivityId() == activityId && e.getStep() != ActivityConst.OPEN_CLOSE) {
                return e;
            }
        }
        return null;
    }

    public StaticActMecha getMechaById(int mechaId) {
        return actMechaMap.get(mechaId);
    }

    public StaticActMecha getMechaById(int activityId, int count) {
        Iterator<StaticActMecha> it = actMechaMap.values().iterator();
        while (it.hasNext()) {
            StaticActMecha next = it.next();
            if (next.getActivityId() == activityId && next.getCount() == count) {
                return next;
            }
        }
        return null;
    }

    public Map<Integer, StaticActMecha> getActMechaMap() {
        return actMechaMap;
    }

    public List<StaticActQuota> getQuotaList(int activityId) {
        List<StaticActQuota> rs = new ArrayList<>();
        Iterator<StaticActQuota> it = actQuotaMap.values().iterator();
        while (it.hasNext()) {
            StaticActQuota next = it.next();
            if (next.getActivityId() == activityId) {
                rs.add(next);
            }
        }
        return rs;
    }

    public StaticActQuota getQuotaById(int quotaId) {
        return actQuotaMap.get(quotaId);
    }

    public Map<Integer, StaticActQuota> getActQuotaMap() {
        return actQuotaMap;
    }

    public StaticActRebate getRebateById(int rebateId) {
        return actRebateMap.get(rebateId);
    }

    public StaticActRebate getRebateByMoney(int money, int activityId) {
        Iterator<StaticActRebate> it = actRebateMap.values().iterator();
        StaticActRebate rebate = null;
        while (it.hasNext()) {
            StaticActRebate next = it.next();
            if (next.getType() != activityId) {
                continue;
            }
            if (rebate == null) {
                if (next.getMoney() <= money) {
                    rebate = next;
                }
            } else {
                if (next.getMoney() <= money && next.getMoney() >= rebate.getMoney()) {
                    rebate = next;
                }
            }
        }
        return rebate;
    }

    public Set<Integer> getSorts(int activityId) {
        Set<Integer> sets = new HashSet<>();
        List<StaticActAward> list = awardMap.get(activityId);
        for (StaticActAward ee : list) {
            if (!sets.contains(ee.getSortId())) {
                sets.add(ee.getSortId());
            }
        }
        return sets;
    }

    public StaticActFortune getActFortune(int fortuneId) {
        return actFortuneMap.get(fortuneId);
    }

    public List<StaticActFortune> getActFortuneList(int activityId) {
        List<StaticActFortune> list = new ArrayList<>();
        Iterator<StaticActFortune> it = actFortuneMap.values().iterator();
        while (it.hasNext()) {
            StaticActFortune next = it.next();
            if (next.getActivityId() == activityId) {
                list.add(next);
            }
        }
        return list;
    }

    /**
     * @param awardList格式为 List<Integer>:类型,ID,数量,权重
     * @return
     */
    public List<Integer> randomAwardList(List<List<Integer>> awardList) {
        if (awardList == null || awardList.size() == 0) {
            return null;
        }
        int[] seeds = {0, 0};
        for (List<Integer> entity : awardList) {
            if (entity.size() < 4) {
                continue;
            }
            seeds[0] += entity.get(3);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (List<Integer> entity : awardList) {
            if (entity.size() < 4) {
                continue;
            }
            seeds[1] += entity.get(3);
            if (seeds[0] <= seeds[1]) {
                return entity;
            }
        }
        return null;
    }

    public StaticActRank getActRank(int activityId, int sortId, int rank) {
        if (!actRankMap.containsKey(activityId)) {
            return null;
        }
        List<StaticActRank> list = actRankMap.get(activityId).get(sortId);
        if (list == null) {
            return null;
        }
        for (StaticActRank e : list) {
            if (rank <= e.getRankEnd() && rank >= e.getRankBegin()) {
                return e;
            }
        }
        return null;
    }

    public List<StaticActRank> getActRankList(int activityId, int sortId) {
        List<StaticActRank> list = new ArrayList<>();
        if (!actRankMap.containsKey(activityId)) {
            return list;
        }
        return actRankMap.get(activityId).get(sortId);
    }

    public StaticActProfoto getActProfoto(int activityId) {
        return actProfotoMap.get(activityId);
    }

    public StaticActRaffle getActRaffle(int activityId) {
        List<StaticActRaffle> list = actRaffleMap.get(activityId);
        if (list == null) {
            return null;
        }
        int[] seeds = {0, 0};
        for (StaticActRaffle e : list) {
            seeds[0] += e.getProbability();
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (StaticActRaffle e : list) {
            seeds[1] += e.getProbability();
            if (seeds[0] <= seeds[1]) {
                return e;
            }
        }
        return null;
    }

    public int[] getColor(StaticActRaffle staticActRaffle) {
        // 奖励,颜色1,颜色2,颜色3
        int[] colors = {0, 0, 0, 0};
        if (staticActRaffle.getScale() == 1) {// 一等奖(颜色都一样)
            int color = RandomHelper.randomInSize(4) + 1;
            for (int i = 0; i < 4; i++) {
                colors[i] = color;
            }
        } else if (staticActRaffle.getScale() == 2) {// 二等奖{2个值相同,1个不同}
            int seed = RandomHelper.randomInSize(15) + 1;
            colors[1] = seed / 4 + 1;
            colors[2] = seed % 4 + 1;
            if (colors[1] == colors[2]) {// 已相同有2种,第三种颜色不相同
                colors[3] = 5 - colors[0];
                colors[0] = colors[1];
            } else {
                int color = RandomHelper.randomInSize(2);
                if (color == 0) {
                    colors[3] = colors[1];
                    colors[0] = colors[1];
                } else {
                    colors[3] = colors[2];
                    colors[0] = colors[2];
                }
            }
        } else if (staticActRaffle.getScale() == 3) {// 三等奖{3个值不同1-4之间}
            int seed = RandomHelper.randomInSize(4) + 1;
            colors[0] = seed;
            colors[1] = seed;
            colors[2] = 5 - seed;
            colors[3] = (6 - seed) % 4 + 1;
        }
        return colors;
    }

    public StaticActCourse getActCourse(int activityId, int sectionId) {
        Map<Integer, StaticActCourse> courseMap = actCourseMap.get(activityId);
        if (courseMap != null) {
            return courseMap.get(sectionId);
        }
        return null;
    }

    public Map<Integer, StaticActCourse> getActResourceCourseMap() {
        return actCourseResourceMap;
    }

    public Map<Integer, StaticActCourse> getActBaseCourseMap() {
        return actCourseBaseMap;
    }

    public List<Integer> getActTechAward(StaticActTech staticActTech) {
        if (staticActTech == null) {
            return null;
        }
        List<List<Integer>> awardList = staticActTech.getAwardList();
        if (awardList.size() == 1) {
            return awardList.get(0);
        }
        int[] seeds = {0, 0};
        for (List<Integer> e : awardList) {
            if (e.size() < 4) {
                continue;
            }
            seeds[0] += e.get(3);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (List<Integer> e : awardList) {
            seeds[1] += e.get(3);
            if (seeds[0] <= seeds[1]) {
                return e;
            }
        }
        return null;
    }

    public StaticActTech getActTech(int techId) {
        return actTechMap.get(techId);
    }

    public Map<Integer, StaticActTech> getActTechMap() {
        return actTechMap;
    }

    public List<StaticActGeneral> getActGeneralList(int activityId) {
        List<StaticActGeneral> list = new ArrayList<>();
        Iterator<StaticActGeneral> it = actGeneralMap.values().iterator();
        while (it.hasNext()) {
            StaticActGeneral next = it.next();
            if (next.getActivityId() == activityId) {
                list.add(next);
            }
        }
        return list;
    }

    public StaticActGeneral getActGeneral(int generalId) {
        return actGeneralMap.get(generalId);
    }

    public StaticActEverydayPay getActEverydayPay(int dayiy) {
        return actEverydayPayMap.get(dayiy);
    }

    public StaticActDestory getActDestory(int tankId) {
        return actDestoryMap.get(tankId);
    }

    public boolean isSpecial(StaticActEverydayPay everyDay, int type, int id) {
        List<List<Integer>> list = everyDay.getSpecialList();
        for (List<Integer> e : list) {
            if (e.size() < 3) {
                continue;
            }
            if (e.get(0) == type && e.get(1) == id) {
                return true;
            }
        }
        return false;
    }

    public Map<Integer, StaticActVacationland> getActVacationlandMap() {
        return actVacationlandMap;
    }

    public List<StaticActVacationland> getVillageList() {
        return villageList;
    }

    public StaticActVacationland getVillage(int landId) {
        return actVacationlandMap.get(landId);
    }

    public List<StaticActExchange> getActExchange(int activityId) {
        return exchangeMap.get(activityId);
    }

    public StaticActExchange getActExchange(int activityId, int exchangeId) {
        List<StaticActExchange> list = exchangeMap.get(activityId);
        if (list == null) {
            return null;
        }
        for (StaticActExchange e : list) {
            if (e.getExchangeId() == exchangeId) {
                return e;
            }
        }
        return null;
    }

    public Map<Integer, StaticActChooseGift> getStaticActChooseGiftMap() {
        return staticActChooseGiftMap;
    }

    /**
     * 获取配件分解改造
     *
     * @param activityId
     * @return
     */
    public List<StaticActPartResolve> getActPartResolveList(int activityId) {
        if (!resolveMap.containsKey(activityId)) {
            return null;
        }
        return resolveMap.get(activityId);
    }
    
    /**
     * 获取勋章分解积分获得比率
     *
     * @param activityId
     * @return
     */
    public List<List<Integer>> getMedalResolveScoreRate(int activityId) {
        if (!resolveMap.containsKey(activityId)) {
            return null;
        }
        return resolveMap.get(activityId).get(0).getPartNum();
    }
    

    public int getResolveSlug(int activityId, int type, int quality) {
        if (!resolveSlugMap.containsKey(activityId)) {
            return 0;
        }
        Map<Integer, Map<Integer, Integer>> amap = resolveSlugMap.get(activityId);
        if (amap == null) {
            return 0;
        }
        Map<Integer, Integer> tmap = amap.get(type);
        if (tmap == null) {
            return 0;
        }
        if (!tmap.containsKey(quality)) {
            return 0;
        }
        return tmap.get(quality);
    }

    /**
     * 获取配件分解改造
     *
     * @param activityId
     * @param resolveId
     * @return
     */
    public StaticActPartResolve getActPartResolve(int activityId, int resolveId) {
        if (!resolveMap.containsKey(activityId)) {
            return null;
        }
        List<StaticActPartResolve> list = resolveMap.get(activityId);
        for (StaticActPartResolve e : list) {
            if (e.getResolveId() == resolveId) {
                return e;
            }
        }
        return null;
    }

    /**
     * 获取下注赢金币列表
     *
     * @param activityId
     * @return
     */
    public List<StaticActGamble> getActGambleList(int activityId) {
        if (!gambleMap.containsKey(activityId)) {
            return null;
        }
        return gambleMap.get(activityId);
    }

    /**
     * 赢取下注
     *
     * @param activityId
     * @param topup总充值
     * @param price已下注额
     * @return
     */
    public StaticActGamble getActGamble(int activityId, int topup, int price) {
        if (!gambleMap.containsKey(activityId)) {
            return null;
        }
        List<StaticActGamble> list = gambleMap.get(activityId);
        for (StaticActGamble e : list) {
            if (e.getPrice() > price && topup >= e.getTopup()) {
                return e;
            }
        }
        return null;
    }

    /**
     * 返回活动对应的awardId是否有效，如果是
     *
     * @param activityId
     * @param awardId
     * @return
     */
    public boolean isValidAwardId(int activityId, int awardId) {
        Set<Integer> set = activityAwardIdMap.get(activityId);
        return null != set && set.contains(awardId);
    }

    public List<StaticActEquate> getActEquateList(int type) {
        return actEquateListMap.get(type);
    }

    public StaticActEquate getActEquateByKind(int kind) {
        return actEquateKindMap.get(kind);
    }

    public List<StaticActivityTime> getActivityTimeById(int activityId) {
        return activityTimeMap.get(activityId);
    }

    public Map<Integer, StaticActivityEffect> getActivityEffectById(int activityId) {
        return activityEffectMap.get(activityId);
    }

    public StaticActivityProp getActivityPropById(int id) {
        return activityPropMap.get(id);
    }

    public Map<Integer, StaticActivityProp> getActivityPropMap() {
        return activityPropMap;
    }

    public Map<Integer, StaticCharacterChange> getCharacterChangeMap() {
        return characterChangeMap;
    }

    public StaticActivityM1a2 getActivityM1a2(int id) {
        return activityM1a2Map.get(id);
    }

    public Map<Integer, StaticActivityFlower> getActivityFlowerMap() {
        return activityFlowerMap;
    }

    public Map<Integer, StaticActPirate> getActPirateMap(int activityId) {
        return actPirateAllMap.get(activityId);
    }

    public Map<Integer, StaticActivityChange> getActivityChangeMap(int id) {
        return activityChangeMap.get(id);
    }

    public StaticActBoss getActBoss() {
        return actBoss;
    }

    public Map<Integer, Integer> randomActPirate(int activityId) {
        Map<Integer, Integer> map = new HashMap<>();
        Map<Integer, StaticActPirate> actPirateMap = getActPirateMap(activityId);
        for (StaticActPirate pirate : actPirateMap.values()) {
            int random = 0, total = 0;
            for (List<Integer> list : pirate.getAward()) {
                random += list.get(3);
            }
            random = RandomHelper.randomInSize(random);
            for (int i = 0; i < pirate.getAward().size(); i++) {
                total += pirate.getAward().get(i).get(3);
                if (random <= total) {
                    map.put(pirate.getId(), i);  //  奖励下标
                    map.put(-pirate.getId(), 0); //  抽取状态
                    break;
                }
            }
        }
        return map;
    }

    public StaticActQuinn randomQuinn(int awardId, int type) {
        int random = 0;
        List<StaticActQuinn> list = staticActQuinnMap.get(awardId).get(type);
        for (StaticActQuinn staticActQuinn : list) {
            random += staticActQuinn.getProbability();
        }
        random = RandomHelper.randomInSize(random);
        int total = 0;
        for (StaticActQuinn staticActQuinn : list) {
            total += staticActQuinn.getProbability();
            if (random <= total) {
                return staticActQuinn;
            }
        }
        return null;
    }

    public int randomActPirate(Map<Integer, Integer> saveMap, int activityId) {
        Map<Integer, StaticActPirate> actPirateMap = getActPirateMap(activityId);
        int random = 0, total = 0;
        for (Integer id : saveMap.keySet()) {
            if (id == 10) {
                continue;
            }
            if (id < 1) {  // 剔除 次数参数与状态参数  （物品参数为 1-9）
                continue;
            }
            if (saveMap.get(-id) != null && saveMap.get(-id) == 1) { // 剔除 已经抽取的id
                continue;
            }
            random += actPirateMap.get(id).getAward().get(saveMap.get(id)).get(3);
        }
        random = RandomHelper.randomInSize(random);
        for (Integer id : saveMap.keySet()) {
            if (id == 10) {
                continue;
            }
            if (id < 1) {  // 剔除 次数参数与状态参数  （物品参数为 1-9）
                continue;
            }
            if (saveMap.get(-id) != null && saveMap.get(-id) == 1) { // 剔除 已经抽取的id
                continue;
            }
            total += actPirateMap.get(id).getAward().get(saveMap.get(id)).get(3);
            if (random <= total) {
                return id;
            }
        }
        return 0;
    }

    public StaticActPayRebate randomPayRebateRate(int type) {
        int random = 0;
        for (StaticActPayRebate payRebate : actPayRebateList) {
            if (payRebate.getType() != type) {
                continue;
            }
            random += payRebate.getWeight();
        }
        random = RandomHelper.randomInSize(random);
        int total = 0;
        for (StaticActPayRebate payRebate : actPayRebateList) {
            if (payRebate.getType() != type) {
                continue;
            }
            total += payRebate.getWeight();
            if (random <= total) {
                return payRebate;
            }
        }
        return null;
    }

    public Map<Integer, StaticActHilarityPray> getActHilarityPrayMap() {
        return actHilarityPrayMap;
    }

    public StaticActWorshipGod getActWorshipGod(int day) {
        return actWorshipGodMap.get(day);
    }

    public StaticActWorshipTask getActWorshipTask(int awardId, int day) {
        return actWorshipTaskMap.get(awardId).get(day);
    }

    public StaticActRebelTeam getActRebelTeamByLv(int lv) {
        List<StaticActRebelTeam> sart = actRebelLvMap.get(lv);
        if (sart != null && sart.size() > 0) {
            return sart.get(RandomHelper.randomInSize(sart.size()));
        }
        return null;
    }

    public StaticActRebelTeam getActRebel(int id) {
        return actRebelIdMap.get(id);
    }

    private String getMapKey(int tankId, int level) {
        return tankId + "_" + level;
    }

    public StaticActRebelAttr getActRebelAttr(int tankId, int lv) {
        return attrMap.get(getMapKey(tankId, lv));
    }

    public StaticActRebel getActRebel() {
        return actRebel;
    }

    public StaticActWorshipGodData getActWorshipGodData(int count) {
        return actWorshipGodDataMap.get(count);
    }

    public StaticActFoison getActFoison(int awardId) {
        return actFoisonMap.get(awardId);
    }

    public StaticActCollegeSubject getActCollegeSubject(int id) {
        return actCollegeSubjectMap.get(id);
    }

    public StaticActCollegeEducation getActCollegeEducation(int point) {
        for (StaticActCollegeEducation s : actCollegeEducationList) {
            if (point <= s.getMaxnumber()) {
                return s;
            }
        }
        return null;
    }

    public List<List<Integer>> getActCollegeEducation(int oldPoint, int curPoint) {
        List<List<Integer>> list = new ArrayList<>();
        for (int i = 0; i < actCollegeEducationList.size(); i++) {
            StaticActCollegeEducation s = actCollegeEducationList.get(i);
            if (s == null || s.getCumulativerewards().size() == 0) {
                continue;
            }
            if (oldPoint >= s.getMaxnumber()) {
                continue;
            }
            if (s.getMaxnumber() > curPoint) {
                break;
            }
            if (oldPoint < s.getMaxnumber() && curPoint >= s.getMaxnumber()) {
                list.add(s.getCumulativerewards());
            }
        }
        return list;
    }

    public void addMapNum(Map<Integer, Map<Integer, Integer>> map, int type, int id, int count) {
        if (count <= 0) {
            return;
        }
        Map<Integer, Integer> map2 = map.get(type);
        if (map2 == null) {
            map2 = new HashMap<>();
            map.put(type, map2);
        }
        Integer curCount = map2.get(id);
        if (curCount == null) {
            curCount = 0;
        }
        curCount += count;
        map2.put(id, curCount);
    }

    public List<StaticActCollegeSubject> addActCollegePoint(StaticActCollegeSubject sActCollegeSubject, List<Long> statusList, int point) {
        int curPoint = statusList.get(ActCollegeConst.INDEX_POINT).intValue();
        int oldPoint = curPoint;
        int curTotalPoint = statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue();
        curPoint += point;
        List<StaticActCollegeSubject> subjectIds = new ArrayList<>();//结业科目
        do {
            int needPoint = sActCollegeSubject.getCredits();
            StaticActCollegeSubject s = getActCollegeSubject(sActCollegeSubject.getId() + 1);
            if (s == null && oldPoint < needPoint && curPoint >= needPoint) {//满级了
                subjectIds.add(sActCollegeSubject);
            }
            if (curPoint >= needPoint) {
                curPoint -= needPoint;
                if (s == null) {
                    curPoint = needPoint;
                    break;
                }
                subjectIds.add(sActCollegeSubject);
                sActCollegeSubject = s;
            } else {
                break;
            }
        } while (sActCollegeSubject != null);
        statusList.set(ActCollegeConst.INDEX_SUBJECT, (long) sActCollegeSubject.getId());
        statusList.set(ActCollegeConst.INDEX_POINT, (long) curPoint);
        statusList.set(ActCollegeConst.INDEX_TOTAL_POINT, (long) (curTotalPoint + point));
        return subjectIds;
    }

    /**
     * 活动道具购买价格 活动道具模版  已经购买了数量  当前准备购买数量
     */
    public int getActCollegePropGold(StaticActivityProp sap, int buyNum, int count) {
        //[[20, 20], [50, 25], [100, 30], [2100000000, 50]]
        int costGold = 0;
        int curNum = buyNum;
        int curCount = count;
        List<List<Integer>> priceArr = sap.getTrapezoidalprice();
        for (List<Integer> price : priceArr) {
            if (buyNum <= price.get(0)) {
                if (price.get(0) < buyNum + count) {
                    costGold += price.get(1) * (price.get(0) - curNum);
                    curCount -= price.get(0) - curNum;
                    curNum = price.get(0);
                } else {
                    costGold += price.get(1) * curCount;
                    break;
                }
            }
        }
        return costGold;
    }

    /**
     * 获去部件强化暴击信息
     *
     * @param activityId
     * @return
     */
    public TreeMap<Integer, StaticActPartCrit> getPartCritMap(int activityId) {
        TreeMap<Integer, StaticActPartCrit> critMap = partCritMap.get(activityId);
        if (critMap == null) {
            LogUtil.error(String.format("not found part crit activity id :%d", activityId));
        }
        return critMap;
    }

    /**
     * 获取淬炼大师活动中淬炼获得氪金的信息
     *
     * @param mode 淬炼方式
     * @return
     */
    public StaticActPartMaster getPartSmeltMaster(int mode) {
        StaticActPartMaster data = partSmeltMasterMap.get(mode);
        if (data == null) {
            LogUtil.error("not found data mode :" + mode);
        }
        return data;
    }

    /**
     * 获取淬炼大师活动中氪金抽奖数据
     *
     * @param count
     * @return
     */
    public StaticActPartMasterLottery getStaticActPartMasterLottery(int count) {
        StaticActPartMasterLottery data = partSmeltMasterLotteryMap.get(count);
        if (data == null) {
            LogUtil.error("not found part smelt master lottery count :" + count);
        }
        return data;
    }

    public Map<Integer, List<StaticActCumulativePay>> getStaticActCumulativePayMap() {
        return staticActCumulativePayMap;
    }

    public Map<Integer, Map<Integer, StaticActBrotherBuff>> getActBrotherBuffMap() {
        return staticActBrotherBuffMap;
    }

    /**
     * 按类型、等级获取buff
     *
     * @param type buff类型
     * @param lv   buff等级
     * @return
     */
    public StaticActBrotherBuff getActBrotherBuff(int type, int lv) {
        return staticActBrotherBuffMap.get(type).get(lv);
    }

    public Map<Integer, List<StaticActBrotherTask>> getStaticActBrotherTaskMap() {
        return staticActBrotherTaskMap;
    }

    /**
     * @return 返回兄弟同心降低战损值
     */
    public int getActBrotherReduceloss() {
        return reduceloss;
    }


    public Map<Integer, Map<Integer, List<StaticActQuinn>>> getStaticActQuinnMap() {
        return staticActQuinnMap;
    }


    public void setStaticActQuinnMap(Map<Integer, Map<Integer, List<StaticActQuinn>>> staticActQuinnMap) {
        this.staticActQuinnMap = staticActQuinnMap;
    }


    public Map<Integer, List<StaticActQuinnEasteregg>> getStaticActQuinnEastereggMap() {
        return staticActQuinnEastereggMap;
    }


    public void setStaticActQuinnEastereggMap(Map<Integer, List<StaticActQuinnEasteregg>> staticActQuinnEastereggMap) {
        this.staticActQuinnEastereggMap = staticActQuinnEastereggMap;
    }


    public Map<Integer, StaticActQuinnRefresh> getStaticActQuinnRefreshMap() {
        return staticActQuinnRefreshMap;
    }


    public void setStaticActQuinnRefreshMap(Map<Integer, StaticActQuinnRefresh> staticActQuinnRefreshMap) {
        this.staticActQuinnRefreshMap = staticActQuinnRefreshMap;
    }


    /**
     * 根据类型获取荣誉勋章宝箱列表
     *
     * @param type 荣誉勋章宝箱类型
     * @return
     */
    public List<StaticActMedalofhonor> getActMedalofhonorListByType(int type) {
        List<StaticActMedalofhonor> dataLst = this.medalofhonorListMap.get(type);
        if (dataLst == null) {
            LogUtil.error("not found medalofhonor list data, type :" + type);
        }
        return dataLst;
    }

    public StaticActMedalofhonor getActMedalofhonor(int id) {
        StaticActMedalofhonor data = this.medalofhonorMap.get(id);
        if (data == null) {
            LogUtil.error("not found medalofhonor data, id :" + id);
        }
        return data;
    }

    public StaticActMedalofhonorExplore getActMedalofhonorExplore() {
        return actMedalofhonorExplore;
    }

    public Map<Integer, StaticActMedalofhonorRule> getMedalofhonorRuleMap() {
        return medalofhonorRuleMap;
    }

    /**
     * 判断荣誉勋章活动是否开启状态
     *
     * @return
     */
    public boolean isMedalofhonorActivityOpen() {
        ActivityBase activityBase = getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        return activityBase != null;
    }
}
