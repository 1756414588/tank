package com.game.manager;

import com.game.constant.*;
import com.game.dao.impl.p.ActivityDao;
import com.game.dataMgr.*;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.RptAtkHome;
import com.game.pb.CommonPb.RptAtkMine;
import com.game.util.*;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-29 上午11:57:11
 * @declare 游戏服活动数据处理
 */
@Component
public class ActivityDataManager {

    @Autowired
    private ActivityDao activityDao;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private StaticBackDataMgr staticBackDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private StaticMailDataMgr staticMailDataMgr;

    private Map<Integer, UsualActivityData> activityMap = new HashMap<>();

    // @PostConstruct
    public void init() throws InvalidProtocolBufferException {
        iniUsualActivity();
    }

    public void iniUsualActivity() throws InvalidProtocolBufferException {
        List<UsualActivity> list = activityDao.selectUsualActivity();
        if (list != null) {
            for (UsualActivity e : list) {
                UsualActivityData usualActivity = new UsualActivityData(e);
                activityMap.put(e.getActivityId(), usualActivity);
            }
        }
    }

    public Map<Integer, UsualActivityData> getActivityMap() {
        return activityMap;
    }

    public void updateActivityData(UsualActivity activity) {
        activityDao.updateActivity(activity);
    }

    /**
     * Function:活动信息通用部分,开启,记录重置
     *
     * @param player
     * @param activityId
     * @param handler
     * @return
     */
    public Activity getActivityInfo(Player player, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return null;
        }
        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);
        Activity activity = player.activitys.get(activityId);
        if (activity == null) {
            activity = new Activity(activityBase, begin);
            refreshStatus(activity);
            player.activitys.put(activityId, activity);
        } else {
            activity.isReset(begin);// 是否重新设置活动
            activity.autoDayClean(activityBase);
        }
        activity.setOpen(activityBase.getBaseOpen());
        return activity;
    }

    /**
     * Function:活动信息通用部分,开启,记录重置
     *
     * @param player
     * @param activityId
     * @param handler
     * @return
     */
    public Activity getActivityInfo(PartyData partyData, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return null;
        }
        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);
        Activity activity = partyData.getActivitys().get(activityId);
        if (activity == null) {
            activity = new Activity(activityBase, begin);
            refreshStatus(activity);
            partyData.getActivitys().put(activityId, activity);
        } else {
            activity.isReset(begin);// 是否重新设置活动
            activity.autoDayClean(activityBase);// 自动每日清理
        }
        activity.setOpen(activityBase.getBaseOpen());
        return activity;
    }

    public UsualActivityData getUsualActivity(int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return null;
        }
        int open = activityBase.getBaseOpen();
        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);
        UsualActivityData activity = activityMap.get(activityId);
        if (activity == null) {
            activity = new UsualActivityData(activityBase, begin);
            activityMap.put(activityId, activity);
        } else {
            activity.isReset(begin);
            activity.autoDayClean(activityBase);
        }
        activity.setOpen(open);
        return activity;
    }

    /**
     * 更新玩家活动记录
     *
     * @param player
     * @param activityId
     * @param schedule
     */
    public void updActivity(Player player, int activityId, long schedule, int sortId) {
        try {
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
            if (activityBase == null) {
                return;
            }
            int step = activityBase.getStep();
            if (step != ActivityConst.OPEN_STEP) {
                return;
            }
            Date beginTime = activityBase.getBeginTime();
            int begin = TimeHelper.getDay(beginTime);
            Activity activity = player.activitys.get(activityId);
            if (activity == null) {
                activity = new Activity(activityBase, begin);
                refreshStatus(activity);
                player.activitys.put(activityId, activity);
                activity.setEndTime(TimeHelper.getCurrentDay());
            } else {
                activity.isReset(begin);// 是否重新设置活动
                activity.autoDayClean(activityBase);
            }
            long state = activity.getStatusList().get(sortId);
            state = state + schedule;
            activity.getStatusList().set(sortId, state);
        } catch (Exception e) {
            // LogHelper.ERROR_LOGGER.error("Activity Exception : " + activityId, e);
            LogUtil.error("Activity Exception : " + activityId, e);
        }
    }

    /**
     * Function:紫装升级
     *
     * @param player
     * @param add
     * @return
     */
    public void purpleEquipUp(Player player, StaticEquip staticEquip, int lv, int toLv) {
        if (staticEquip.getQuality() < 4) {
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PURPLE_UP);
        if (activityBase == null) {
            return;
        }

        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_PURPLE_UP);
        for (StaticActAward e : list) {
            int plv = Integer.valueOf(e.getParam().trim());
            if (plv > lv && plv <= toLv) {
                int sortId = e.getSortId();
                updActivity(player, ActivityConst.ACT_PURPLE_UP, 1, sortId);
            }
        }
    }

    /**
     * Function:消耗金币活动
     *
     * @param lord
     * @param gold
     * @param activityId
     * @return
     */
    public void ActCostGold(Lord lord, int gold, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return;
        }
        Player player = playerDataManager.getPlayer(lord.getLordId());
        updActivity(player, activityId, gold, 0);
    }

    /**
     * 升装暴击,喂装备额外增加50%经验
     *
     * @param exp
     * @return
     */
    public int upEquipExp(int exp) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_UP_EQUIP_CRIT);
        if (activityBase == null) {
            return exp;
        }
        exp = (int) (exp * 1.5f);
        return exp;
    }

    /**
     * 关卡拦截
     *
     * @return
     */
    public List<Integer> combatCourse(Player player, int sectionId, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return null;
        }
        StaticActCourse course = staticActivityDataMgr.getActCourse(activityBase.getKeyId(), sectionId);
        if (course == null) {
            return null;
        }
        if (player.lord.getLevel() < course.getLevel()) {
            return null;
        }
        return courseDeal(course);
    }

    /**
     * 装配兑换关卡掉落
     *
     * @param sectionId
     * @return
     */
    public List<Integer> combatCash(Player player, int activityId, int sectionId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return null;
        }
        if (activityId == ActivityConst.ACT_BOSS) {
            int step = activityBase.getStep();
            if (step != ActivityConst.OPEN_STEP) {
                return null;
            }
        }
        StaticActCourse course = staticActivityDataMgr.getActCourse(activityBase.getKeyId(), sectionId);
        if (course == null) {
            course = staticActivityDataMgr.getActCourse(activityBase.getKeyId(), 0);
        }

        if (course == null) {
            course = staticActivityDataMgr.getActCourse(activityId, 0);
        }

        if (course == null) {
            return null;
        }
        if (player.lord.getLevel() < course.getLevel()) {
            return null;
        }
        return courseDeal(course);
    }

    /**
     * 打资源 活动掉落
     *
     * @param player
     * @return
     */
    public void attackResourceCourse(Player player, RptAtkMine.Builder rptAtkMine) {
        for (StaticActCourse course : staticActivityDataMgr.getActResourceCourseMap().values()) {
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(course.getActivityId());
            if (activityBase == null) {
                continue;
            }
            if (player.lord.getLevel() < course.getLevel()) {
                continue;
            }
            List<Integer> prop = courseDeal(course);
            if (prop != null) {
                playerDataManager.addAward(player, prop.get(0), prop.get(1), prop.get(2), AwardFrom.ATTACK_SOMEONE_MINE);
                rptAtkMine.addAward(PbHelper.createAwardPb(prop.get(0), prop.get(1), prop.get(2)));
            }
        }
    }

    /**
     * 打玩家 活动掉落
     *
     * @param player
     * @return
     */
    public void attackPlayerCourse(Player player, RptAtkHome.Builder rptAtkHome) {
        for (StaticActCourse course : staticActivityDataMgr.getActBaseCourseMap().values()) {
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(course.getActivityId());
            if (activityBase == null) {
                continue;
            }
            if (player.lord.getLevel() < course.getLevel()) {
                continue;
            }
            List<Integer> prop = courseDeal(course);
            if (prop != null) {
                playerDataManager.addAward(player, prop.get(0), prop.get(1), prop.get(2), AwardFrom.ATTACK_SOMEONE_HOME);
                rptAtkHome.addAward(PbHelper.createAwardPb(prop.get(0), prop.get(1), prop.get(2)));
            }
        }
    }

    /**
     * @param course
     * @return List<Integer>
     * @Title: courseDeal
     * @Description: 根据权重计算掉落物品
     */
    private List<Integer> courseDeal(StaticActCourse course) {
        int seeds[] = {0, 0};
        seeds[0] = RandomHelper.randomInSize(course.getDeno());
        for (List<Integer> elist : course.getDropList()) {
            if (elist.size() < 4) {
                continue;
            }
            seeds[1] += elist.get(3);
            if (seeds[0] <= seeds[1]) {
                return elist;
            }
        }
        return null;
    }

    /**
     * 鲜花祝福攻击玩家基地掉落
     *
     * @param sectionId
     * @return
     */
    public void attackPlayerForActFlower(Player player, Player target, RptAtkHome.Builder rptAtkHome) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_FLOWER);
        if (activityBase == null) {
            return;
        }
        int value = player.lord.getLevel() - target.lord.getLevel();
        int count = 0;
        if (value <= 0) {
            count = 2;
        } else if (value > 0 && value <= 5) {
            count = 4;
        } else if (value > 5 && value <= 10) {
            count = 6;
        } else if (value > 10) {
            count = 20;
        }
        if (count != 0 && RandomHelper.randomInSize(count) == 0) {
            playerDataManager.addAward(player, AwardType.ACTIVITY_PROP, 6, 1, AwardFrom.ATTACK_SOMEONE_HOME);
            rptAtkHome.addAward(PbHelper.createAwardPb(AwardType.ACTIVITY_PROP, 6, 1));
        }
    }

    /**
     * 资源采集活动
     *
     * @param player
     * @param activityId
     * @param grab
     */
    public void resourceCollect(Player player, int activityId, Grab grab) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_COLLECT_RESOURCE);
        if (activityBase == null) {
            return;
        }
        // 资源采集活动（数据填错位,讲错就错的方式处理）
        long iron = grab.rs[0];
        long oil = grab.rs[1];
        long copper = grab.rs[2];
        long silicon = grab.rs[3];
        long stone = grab.rs[4];
        if (iron > 0)
            updActivity(player, ActivityConst.ACT_COLLECT_RESOURCE, grab.rs[0], 1);// 铁
        if (oil > 0)
            updActivity(player, ActivityConst.ACT_COLLECT_RESOURCE, grab.rs[1], 2);// 石油
        if (copper > 0)
            updActivity(player, ActivityConst.ACT_COLLECT_RESOURCE, grab.rs[2], 3);// 铜
        if (silicon > 0)
            updActivity(player, ActivityConst.ACT_COLLECT_RESOURCE, grab.rs[3], 4);// 钛
        if (stone > 0)
            updActivity(player, ActivityConst.ACT_COLLECT_RESOURCE, grab.rs[4], 0);// 水晶
    }

    /**
     * 勤劳致富
     *
     * @param player
     * @param activityId
     * @param grab
     */
    public void beeCollect(Player player, int activityId, Grab grab) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }

        UsualActivityData usualActivityData = getUsualActivity(activityId);
        if (usualActivityData == null) {
            return;
        }
        // 勤劳致富活动
        long iron = grab.rs[0];
        long oil = grab.rs[1];
        long copper = grab.rs[2];
        long silicon = grab.rs[3];
        long stone = grab.rs[4];

        long lordId = player.lord.getLordId();
        int rankType = -1;// 排名类型0铁,1石油,2铜,3钛,4水晶
        long rankValue = 0;
        if (iron > 0) {
            rankType = 0;
            updActivity(player, activityId, iron, 0);// 铁
            Activity activity = player.activitys.get(activityId);
            rankValue = activity.getStatusList().get(0);
        } else if (oil > 0) {
            rankType = 1;
            updActivity(player, activityId, oil, 1);// 石油
            Activity activity = player.activitys.get(activityId);
            rankValue = activity.getStatusList().get(1);
        } else if (copper > 0) {
            rankType = 2;
            updActivity(player, activityId, copper, 2);// 铜
            Activity activity = player.activitys.get(activityId);
            rankValue = activity.getStatusList().get(2);
        } else if (silicon > 0) {
            rankType = 3;
            updActivity(player, activityId, silicon, 3);// 钛
            Activity activity = player.activitys.get(activityId);
            rankValue = activity.getStatusList().get(3);
        } else if (stone > 0) {
            rankType = 4;
            updActivity(player, activityId, stone, 4);// 水晶
            Activity activity = player.activitys.get(activityId);
            rankValue = activity.getStatusList().get(4);
        }
        if (rankType == -1 || rankValue <= 0) {
            return;
        }
        // 更新排名
        usualActivityData.addPlayerRank(lordId, rankType, rankValue, ActivityConst.RANK_BEE, ActivityConst.DESC);
    }

    /**
     * Function:疯狂进阶
     *
     * @param player
     * @param add
     * @return
     */
    public void heroImprove(Player player, int toStar) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CRAZY_HERO);
        if (activityBase == null) {
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_CRAZY_HERO);
        for (StaticActAward e : list) {
            int pstar = Integer.valueOf(e.getParam().trim());
            if (pstar == toStar) {
                int sortId = e.getSortId();
                updActivity(player, ActivityConst.ACT_CRAZY_HERO, 1, sortId);
            }
        }
    }

    /**
     * Function:装备探险免费次数(每天免费5次)
     *
     * @param player
     * @param add
     * @return
     */
    public int freeLotEquip() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOT_EQUIP);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * Function:配件探险免费次数(每天免费5次)
     *
     * @return
     */
    public int freeLotPart() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOT_PART);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * @return int
     * @Title: freeLotMilitary
     * @Description: 军工探险免费次数
     */
    public int freeLotMilitary() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOT_MILITARY);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * @return int
     * @Title: freeLotEnergyStone
     * @Description: 能晶探险免费次数
     */
    public int freeLotEnergyStone() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOT_ENERGYSTONE);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * @return int
     * @Title: freeLotMedal
     * @Description: 勋章探险免费次数
     */
    public int freeLotMedal() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOTTERY_MEDAL);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * @return int
     * @Title: freeLotMedal
     * @Description: 战术探险免费次数
     */
    public int freeLotTactics() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TACTICS_LOTTERY);
        if (activityBase == null) {
            return 0;
        }
        return 5;
    }

    /**
     * 捐献金币折扣
     *
     * @return
     */
    public float discountDonate(int resourceId) {
        if (resourceId != 6) {
            return 100f;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DONATE_RE);
        if (activityBase == null) {
            return 100f;
        }
        return 40f;
    }

    /**
     * 打折活动
     *
     * @param activityId
     * @param sortId
     * @return
     */
    public float discountActivity(int activityId, int sortId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return 100f;
        }
        switch (activityId) {
            case ActivityConst.ACT_PART_EVOLVE:// 配件失败扣费85%
                return 85f;
            case ActivityConst.ACT_ENLARGE: {// 金币：单次8折，五次7折。宝石：单次6折，五次5折
                if (sortId == 0) {
                    return 80f;
                } else if (sortId == 1) {
                    return 70f;
                } else if (sortId == 2) {
                    return 60f;
                } else if (sortId == 3) {
                    return 50f;
                }
            }
            case ActivityConst.ACT_LOTTEY_EQUIP:// 紫色单抽8折，紫色九抽7折
                if (sortId == 0) {
                    return 80f;
                } else if (sortId == 1) {
                    return 70f;
                }
            case ActivityConst.ACT_EQUIP_FEED:// 装备补给5折
                return 50f;
            default:
                break;
        }
        return 100f;
    }

    public boolean partEvolve() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_EVOLVE);
        if (activityBase == null) {
            return false;
        }
        return true;
    }

    /**
     * 装备补给，活动开启攻打装备关卡增加30%伤害
     *
     * @return
     */
    public float equipFeed() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_FEED);
        if (activityBase == null) {
            return 100f;
        }
        return 130f;
    }

    /**
     * 全民狂欢
     *
     * @return index0统帅成功率index1资源点资源和关卡的经验index2资源点和道具掉落率
     */
    public int[] revelry() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_REVELRY);
        if (activityBase == null) {
            return new int[]{0, 0, 0};
        }
        // 统帅10%值填写100
        return new int[]{100, 20, 30};
    }

    /**
     * 连续充值
     *
     * @param gold
     * @return
     */
    public void payContinue(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONTU_PAY);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_CONTU_PAY);
        if (activity == null) {
            return;
        }
        int serverId = player.account.getServerId();
        Date now = new Date();
        Date beginTime = activityBase.getBeginTime();
        StaticActAward staticActAward = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_CONTU_PAY).get(0);
        if (gold >= Integer.parseInt(staticActAward.getParam())) {
            List<Long> statusList = activity.getStatusList();

            int dayiy = DateHelper.dayiy(beginTime, now);
            if (dayiy > 7) {
                return;
            }
            for (int i = 0; i < dayiy; i++) {
                long v = statusList.get(i).longValue();
                if (i < dayiy - 1 && v == 0) {
                    break;
                }
                if (i == dayiy - 1 && v == 0) {
                    statusList.set(i, (long) gold);
                }
            }

            Lord lord = player.lord;
            if (lord != null) {
                int addGold = gold / 10;
                List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
                awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
                playerDataManager.sendAttachMail(AwardFrom.PAY_CONTINUE, player, awards, MailType.MOLD_ACT_2, TimeHelper.getCurrentSecond(),
                        String.valueOf(addGold));
                LogHelper.logActivity(lord, ActivityConst.LOG_PAY_CONTINUE, 0, AwardType.GOLD, 0, addGold, serverId);
            }
        }
    }

    /**
     * 每日首笔充值
     *
     * @param gold
     * @return
     */
    public void reFirstPay(Player player, int gold) {
        int plat = player.account.getPlatNo();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RE_FRIST_PAY, plat);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_RE_FRIST_PAY);
        if (activity == null) {
            return;
        }
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        StaticActAward actAward = null;
        for (int i = 0; i < condList.size(); i++) {
            StaticActAward en = condList.get(i);
            if (gold >= en.getCond()) {
                if (actAward == null) {
                    actAward = en;
                } else {
                    if (en.getCond() > actAward.getCond()) {
                        actAward = en;
                    }
                }
            }

        }
        List<Long> statusList = activity.getStatusList();
        if (actAward != null && statusList.get(actAward.getSortId()) == 0) {
            statusList.set(actAward.getSortId(), (long) gold);
        }
    }

    /**
     * 每日首笔充值
     *
     * @param gold
     * @return
     */
    public void giftPay(Player player, int gold, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, activityId);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        long state = statusList.get(0);
        state += gold;
        statusList.set(0, state);
    }

    /**
     * 充值丰收
     *
     * @param gold
     * @return
     */
    public void payFoison(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_FOISON);
        if (activityBase == null) {
            return;
        }
        StaticActFoison foison = staticActivityDataMgr.getActFoison(activityBase.getKeyId());

        int serverId = player.account.getServerId();
        int addGold = gold * foison.getMoney() / 100;
        Lord lord = player.lord;
        if (lord != null) {
            int stone = gold * foison.getStone();
            List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
            awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
            awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 5, stone));
            playerDataManager.sendAttachMail(AwardFrom.PAY_FOISON, player, awards, MailType.MOLD_ACT_1, TimeHelper.getCurrentSecond(),
                    String.valueOf(addGold), String.valueOf(stone));
            LogHelper.logActivity(lord, ActivityConst.ACT_PAY_FOISON, 0, AwardType.GOLD, 0, addGold, serverId);
            LogHelper.logActivity(lord, ActivityConst.ACT_PAY_FOISON, 0, AwardType.RESOURCE, 5, stone, serverId);
        }
    }

    /**
     * @param player
     * @param gold   void
     * @Title: payEveryday
     * @Description: 天天充值记录
     */
    public void payEveryday(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EDAY_PAY_ID);
        if (activityBase == null) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_EDAY_PAY_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        if (statusList.get(0) == 0) {
            statusList.set(0, 1L);
        }
    }

    /**
     * @param player
     * @param gold   void
     * @Title: payVacationland
     * @Description: 度假圣地玩家活动状态记录
     */
    public void payVacationland(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VACATIONLAND_ID);
        if (activityBase == null) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_VACATIONLAND_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0) + gold;
        statusList.set(0, topup);
    }

    /**
     * 充值下注
     *
     * @param player
     * @param gold
     */
    public void payGamble(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GAMBLE_ID);
        if (activityBase == null) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_GAMBLE_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0) + gold;
        statusList.set(0, topup);
    }

    /**
     * 充值转盘
     *
     * @param player
     * @param gold
     */
    public void payTrunTable(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activityBase == null) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0) + gold;
        statusList.set(0, topup);
    }

    /**
     * 返利我做主
     *
     * @param player
     * @param gold
     */
    public void payRebate(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_REBATE);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_PAY_REBATE);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        if (statusList.get(0) == 0 || statusList.get(1) == 0) { // 并没有转转盘
            return;
        }
        long topup = statusList.get(2) + gold;
        if (topup >= statusList.get(0)) { // 充值已到达该档位
            int addGold = (int) (statusList.get(0) * statusList.get(1) / 100.0f);
            statusList.set(0, 0L);
            statusList.set(1, 0L);
            statusList.set(2, 0L);
            List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
            awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
            playerDataManager.sendAttachMail(AwardFrom.ACT_REBATE, player, awards, MailType.ACT_REBATE_ADD_GOLD,
                    TimeHelper.getCurrentSecond(), String.valueOf(addGold));
            LogHelper.logActivity(player.lord, ActivityConst.ACT_PAY_REBATE, 0, AwardType.GOLD, 0, addGold, player.account.getServerId());
        } else { // 未达到档位 增加充值经验
            statusList.set(2, topup);
        }
    }

    /**
     * 连续充值
     *
     * @param gold
     * @return
     */
    public void payContinueMore(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONTU_PAY_MORE);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_CONTU_PAY_MORE);
        if (activity == null) {
            return;
        }
        if (activityBase.getStep() != ActivityConst.OPEN_STEP) {
            return;
        }
        int serverId = player.account.getServerId();
        Date now = new Date();
        Date beginTime = activityBase.getBeginTime();
        List<Long> statusList = activity.getStatusList();

        int dayiy = DateHelper.dayiy(beginTime, now);
        Long value = statusList.get(dayiy - 1);
        if (value == null) {
            statusList.set(dayiy - 1, (long) gold);
        } else {
            statusList.set(dayiy - 1, value + gold);
        }
        Lord lord = player.lord;
        if (lord != null) {
            int addGold = gold / 5;
            List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
            awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
            playerDataManager.sendAttachMail(AwardFrom.PAY_CONTINUE, player, awards, MailType.MOLD_ACT_2, TimeHelper.getCurrentSecond(),
                    String.valueOf(addGold));
            LogHelper.logActivity(lord, ActivityConst.LOG_PAY_CONTINUE, 0, AwardType.GOLD, 0, addGold, serverId);
        }
    }

    /**
     * 新年狂欢祈福
     *
     * @param gold
     * @return
     */
    public void payHilarityPray(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            return;
        }

        List<Long> statusList = activity.getStatusList(); // 下标0： 0.没充值 1.充值未领取 -1.已领取 下标>0: 连续充值天数 当天是否充值

        // 充值每日充值
        int nowDay = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != nowDay) {
            statusList.set(0, 0L);
            activity.setEndTime(nowDay);
        }
        // 设置当日充值领奖状态
        if (statusList.get(0) == 0) { // 今天沒充值 设为已经充值可领取
            statusList.set(0, 1L);
        }

        // 设置连续充值
        Date now = new Date();
        Date beginTime = activityBase.getBeginTime();
        int dayiy = DateHelper.dayiy(beginTime, now);
        Long value = statusList.get(dayiy);
        if (value == null) {
            statusList.set(dayiy, 1L);
        } else {
            statusList.set(dayiy, 1L);
        }

        // 设置累计充值额度
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        if (saveMap.get(0) != null) {
            saveMap.put(0, saveMap.get(0) + gold);
        } else {
            saveMap.put(0, gold);
        }
    }

    /**
     * 清盘计划
     *
     * @param gold
     * @return
     */
    public void payOverRebate(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_OVER_REBATE_ID);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_OVER_REBATE_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList(); // 0:充值额度 >0:下标奖励是否已经抽中
        long topup = statusList.get(0) + gold;
        statusList.set(0, topup);
    }

    /**
     * 有任务需求的活动更新任务状态
     *
     * @param player
     */
    public void activityTaskUpdata(Player player, int cond, int schedule) {
        worshipTaskUpdata(player, cond, schedule); // 拜神许愿
    }

    /**
     * 拜神许愿任务更新
     *
     * @param player
     * @param cond
     */
    private void worshipTaskUpdata(Player player, int cond, int schedule) {
        if (player == null || null == player.lord) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_WORSHIP_ID);
        if (activity == null) {
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_WORSHIP_ID);
        if (activityBase == null) {
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        Date beginTime = activityBase.getBeginTime();
        int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
        StaticActWorshipTask worshipTask = staticActivityDataMgr.getActWorshipTask(activityKeyId, dayiy);
        if (worshipTask == null) {
            return;
        }
        int index = 0;
        for (int i = 0; i < worshipTask.getTask().size(); i++) {
            if (worshipTask.getTask().get(i).get(0) == cond) {
                index = i + 1; // 储存下标 从1开始
                break;
            }
        }
        if (index == 0) { // 没有符合的任务
            return;
        }
        int max = worshipTask.getTask().get(index - 1).get(1); // 获取需要完成的次数
        List<Long> statusList = activity.getStatusList();
        Long num = statusList.get(index);
        if (num == null) {
            statusList.set(index, 1L);
        } else {
            if (num >= max) { // 达到次数 已经完成
                return;
            }
            Long nowNum = num + schedule;
            statusList.set(index, nowNum > max ? max : nowNum);
        }
        if (statusList.get(index) == max) { // 任务刚完成 添加许愿次数
            Integer count = activity.getSaveMap().get(1);
            if (count == null) {
                activity.getSaveMap().put(1, 1);
            } else {
                activity.getSaveMap().put(1, count + 1);
            }
        }
    }

    /**
     * 建军返利
     *
     * @param player
     * @param money
     * @param resource
     */
    public void amyRebate(Player player, int money, long[] resource, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            return;
        }
        UsualActivityData usualActivityData = getUsualActivity(activityId);
        int score = 0;
        if (money > 0) {
            Activity activity = getActivityInfo(player, activityId);
            if (activity != null) {
                StaticActRebate staticRebate = staticActivityDataMgr.getRebateByMoney(money, activityId);
                if (staticRebate != null) {
                    long rebateId = (long) staticRebate.getRebateId();
                    List<Long> statusList = activity.getStatusList();
                    if (statusList.size() == 0) {
                        statusList.add(rebateId);
                    } else {
                        boolean flag = false;
                        for (int i = 0; i < statusList.size(); i++) {
                            Long se = statusList.get(i);
                            if (se.longValue() == 0) {
                                statusList.set(i, rebateId);
                                flag = true;
                                break;
                            }
                        }
                        if (!flag) {
                            statusList.add(rebateId);
                        }
                    }
                }
            }
            score += money * 30;
        }
        if (resource != null) {//
            long res = resource[0] + resource[1] + resource[2] + resource[3] + resource[4];
            res = (res / 1000000) * 30;
            if (res > 0) {
                score += res;
            }
        }
        usualActivityData.setGoal(usualActivityData.getGoal() + score);
    }

    /**
     * 宝藏
     *
     * @param player
     * @param mintLv
     */
    public void profoto(Player player, int mineLv) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PROFOTO_ID);
        if (activityBase == null) {
            return;
        }
        StaticActProfoto staticActProfoto = staticActivityDataMgr.getActProfoto(ActivityConst.ACT_PROFOTO_ID);
        if (staticActProfoto == null) {
            return;
        }
        List<List<Integer>> dropList = staticActProfoto.getDropList();
        for (List<Integer> entity : dropList) {
            if (entity.size() != 4) {
                continue;
            }
            int lv = entity.get(0);
            if (lv != mineLv) {
                continue;
            }
            int seed = entity.get(1);
            int part = entity.get(2);
            int trust = entity.get(3);
            int random = RandomHelper.randomInSize(seed);

            if (random <= part) {
                int partId = RandomHelper.randomInSize(4) + 1;
                if (partId == 1) {
                    playerDataManager.addProp(player, staticActProfoto.getPart1(), 1, AwardFrom.ACT_PROFOTO);
                } else if (partId == 2) {
                    playerDataManager.addProp(player, staticActProfoto.getPart2(), 1, AwardFrom.ACT_PROFOTO);
                } else if (partId == 3) {
                    playerDataManager.addProp(player, staticActProfoto.getPart3(), 1, AwardFrom.ACT_PROFOTO);
                } else if (partId == 4) {
                    playerDataManager.addProp(player, staticActProfoto.getPart4(), 1, AwardFrom.ACT_PROFOTO);
                }
            }
            if (random > part && random <= part + trust) {
                playerDataManager.addProp(player, staticActProfoto.getTrust(), 1, AwardFrom.ACT_PROFOTO);
            }
            break;
        }
    }

    /**
     * 连续充值
     *
     * @param player
     * @param mintLv
     */
    public void payContu4(Player player, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_CONTINUE4);
        if (activityBase == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_PAY_CONTINUE4);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();

        Date now = new Date();
        Date beginTime = activityBase.getBeginTime();
        StaticActAward staticActAward = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_PAY_CONTINUE4).get(0);
        int serverId = player.account.getServerId();
        if (gold >= Integer.parseInt(staticActAward.getParam())) {
            int dayiy = DateHelper.dayiy(beginTime, now);
            dayiy = dayiy > 4 ? 4 : dayiy;
            for (int i = 0; i < dayiy; i++) {
                long v = statusList.get(i).longValue();
                if (i < dayiy - 1 && v == 0) {
                    break;
                }
                if (i == dayiy - 1 && v == 0) {
                    statusList.set(i, (long) gold);
                }
            }
            Lord lord = player.lord;
            if (lord != null) {
                int addGold = gold / 10;
                List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
                awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
                playerDataManager.sendAttachMail(AwardFrom.PAY_CONTINUE, player, awards, MailType.MOLD_ACT_2, TimeHelper.getCurrentSecond(),
                        String.valueOf(addGold));
                LogHelper.logActivity(lord, ActivityConst.LOG_PAY_CONTINUE, 0, AwardType.GOLD, 0, addGold, serverId);
            }
        }
    }

    /**
     * 疯狂歼灭坦克
     *
     * @param player
     * @param destoryTanks
     */
    public void tankDestory(Player player, Map<Integer, RptTank> destoryTanks, boolean cal) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_DESTORY_ID);
        if (activityBase == null) {
            return;
        }
        if (destoryTanks == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_TANK_DESTORY_ID);
        if (activity == null) {
            return;
        }

        UsualActivityData usualActivityData = getUsualActivity(ActivityConst.ACT_TANK_DESTORY_ID);
        if (usualActivityData == null) {
            return;
        }

        List<Long> statusList = activity.getStatusList();
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        int nowDay = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != nowDay) {// 清理歼灭数据{坦克,战车,火炮,火箭}
            List<StaticActAward> actAwardList = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_TANK_DESTORY_ID);
            if (actAwardList != null) {
                for (StaticActAward e : actAwardList) {
                    int sortId = e.getSortId();
                    int param = Integer.parseInt(e.getParam().trim());
                    if (param != 0) {
                        statusList.set(sortId, 0L);
                        statusMap.remove(e.getKeyId());
                    }
                }
            }
            activity.setEndTime(nowDay);
        }

        // 坦克,战车,火炮,火箭,全部类型坦克,积分
        int[] destorys = {0, 0, 0, 0, 0, 0};
        Iterator<RptTank> it = destoryTanks.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = it.next();
            StaticTank staticTank = staticTankDataMgr.getStaticTank(rptTank.getTankId());
            if (staticTank != null) {
                StaticActDestory staticActDestory = staticActivityDataMgr.getActDestory(rptTank.getTankId());
                int dscore = 0;
                if (staticActDestory != null) {
                    dscore = staticActDestory.getScore();
                }
                int type = staticTank.getType();
                destorys[type - 1] += rptTank.getCount();// 坦克类型消耗
                destorys[4] += rptTank.getCount();// 总击杀任意消耗
                if (cal) {
                    destorys[5] += rptTank.getCount() * dscore;
                }
            }
        }

        for (int i = 0; i < 6; i++) {// 记录坦克,战车,火炮,火箭,总击杀,积分
            if (destorys[i] > 0) {
                updActivity(player, ActivityConst.ACT_TANK_DESTORY_ID, destorys[i], i);
            }
        }
        if (destorys[5] > 0) {// 积分纳入排行榜
            long score = activity.getStatusList().get(5);
            if (score >= 50000) {
                usualActivityData.addPlayerRank(player.lord.getLordId(), score, ActivityConst.RANK_TANK_DESTORY, ActivityConst.DESC);
            }
        }
    }

    /**
     * 消费转盘
     *
     * @param lord
     * @param gold
     */
    public void actConsumeDail(Lord lord, int gold) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }
        Player player = playerDataManager.getPlayer(lord.getLordId());
        if (player == null) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activity == null) {
            return;
        }
        List<Long> statusList = activity.getStatusList();
        long consume = statusList.get(0);
        statusList.set(0, consume + gold);

    }

    /**
     * 刷新配件/装备公式
     *
     * @param player
     * @param actExchange
     */
    public Cash freshCash(Player player, Cash cash, StaticActExchange actExchange, boolean reset) {
        int exchangeId = actExchange.getExchangeId();
        int formulaId = actExchange.getFormulaId();
        int price = actExchange.getPrice();
        if (cash == null) {
            cash = new Cash();
            cash.setFree(1);// 免费次数
            cash.setState(actExchange.getLimit());// 可购买次数
        }
        if (reset) {
            cash.setFree(1);// 免费次数
            cash.setState(actExchange.getLimit());// 可购买次数
        }

        cash.setCashId(exchangeId);
        cash.setFormulaId(formulaId);
        cash.setPrice(price);

        List<List<Integer>> rets = new ArrayList<List<Integer>>();
        rets.add(random(actExchange.getMeta1()));
        rets.add(random(actExchange.getMeta2()));
        rets.add(random(actExchange.getMeta3()));
        List<Integer> m4 = random(actExchange.getMeta4());
        if (m4 != null) {
            rets.add(m4);
        }
        List<Integer> m5 = random(actExchange.getMeta5());
        if (m5 != null) {
            rets.add(m5);
        }
        // 刷新材料
        cash.setList(rets);
        // 刷新奖励
        //cash.setAwardList(random(actExchange.getAwardList()));
        List<Integer> replacAward = this.getReplacAward(rets, actExchange, 0);
        cash.setAwardList(replacAward);
        return cash;
        //return cash;
    }

    /**
     * 剔除材料与奖励相同
     *
     * @param rets
     * @param cash
     * @param actExchange
     * @param count
     */
    private List<Integer> getReplacAward(List<List<Integer>> rets, StaticActExchange actExchange, int count) {
        List<Integer> random = random(actExchange.getAwardList());
        if (count >= 10) {
            for (List<Integer> aw : actExchange.getAwardList()) {
                boolean flag = true;
                for (List<Integer> ret : rets) {
                    if (aw.get(0).intValue() == ret.get(0).intValue() && aw.get(1).intValue() == ret.get(1).intValue()) {
                        flag = false;
                        break;
                    }
                }
                if (flag) {
                    return random;
                }
            }
        }
        if (random != null) {
            boolean bln = false;
            for (List<Integer> ret : rets) {
                if (ret.get(0).intValue() == random.get(0).intValue() && random.get(1).intValue() == ret.get(1).intValue()) {
                    bln = true;
                    break;
                }
            }
            if (!bln) {
                return random;
            } else {
                return getReplacAward(rets, actExchange, ++count);
            }
        }

        return null;
    }


    /**
     * 随机奖励
     *
     * @param metaList
     * @return
     */
    public List<Integer> random(List<List<Integer>> metaList) {
        if (metaList == null || metaList.size() == 0) {
            return null;
        }
        int[] seeds = {0, 0};
        for (List<Integer> e : metaList) {
            if (e.size() != 4) {
                continue;
            }
            seeds[0] += e.get(3);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (List<Integer> e : metaList) {
            if (e.size() != 4) {
                continue;
            }
            seeds[1] += e.get(3);
            if (seeds[0] <= seeds[1]) {
                return e;
            }
        }
        return null;
    }

    /**
     * 勋章补给：勋章关卡伤害+30%，购买价格减半
     *
     * @param player
     * @return
     */
    public float medalSupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_SUPPLY);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_MEDAL_SUPPLY);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 战术大师 购买价格减半
     *
     * @param player
     * @return
     */
    public float tacticsSupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TACTICS_SUPPLY);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_TACTICS_SUPPLY);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 配件补给：配件关卡伤害+30%,购买次数返回60%金币
     *
     * @param player
     * @return
     */
    public float partSupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_SUPPLY);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_PART_SUPPLY);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 购买军工关卡次数：即买即返50%金币
     *
     * @param player
     * @return
     */
    public float militarySupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MILITARY_SUPPLY);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_MILITARY_SUPPLY);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 购买装备关卡次数：即买即返50%金币
     *
     * @param player
     * @return
     */
    public float equipSupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_FEED);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_EQUIP_FEED);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 购买能晶关卡次数：即买即返50%金币
     *
     * @param player
     * @return
     */
    public float energyStoneSupply(Player player) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_SUPPLY);
        if (activityBase == null) {
            return 1f;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 1f;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_ENERGYSTONE_SUPPLY);
        if (activity == null) {
            return 1f;
        }
        return 0.5f;
    }

    /**
     * 科技优惠：资源类升级提速100%（相当于20级科技馆建筑）;资源类升级消耗资源减少50%
     *
     * @return
     */
    public int[] scienceDiscount(Player player, int scienceId) {
        // 铁，石头，铜，钛，水晶
        if (scienceId != 101 && scienceId != 102 && scienceId != 103 && scienceId != 104 && scienceId != 105) {
            return new int[]{0, 1};
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_SCIENCE_MATERIAL);
        if (activityBase == null) {
            return new int[]{0, 1};
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return new int[]{0, 1};
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_SCIENCE_MATERIAL);
        if (activity == null) {
            return new int[]{0, 1};
        }
        return new int[]{20, 2};
    }

    /**
     * 火力全开：军团大厅建设贡献提高50%，科技捐献经营和贡献提高50%
     *
     * @return
     */
    public int fireSheet(Player player, int partyId, int build) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_FIRE_SHEET);
        if (activityBase == null) {
            return build;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return build;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_FIRE_SHEET);
        if (activity == null) {
            return build;
        }
        UsualActivityData activityData = getUsualActivity(ActivityConst.ACT_FIRE_SHEET);
        if (activityData == null) {
            return build;
        }
        // 添加排名记录
        build = (int) Math.ceil(build * 1.5f);
        activityData.addPartyRank(partyId, build, ActivityConst.RANK_FIRE_SHEET, ActivityConst.DESC);
        return build;
    }

    /**
     * 配件分解兑换
     *
     * @return
     */
    public void partResolve(Player player, List<PartResolve> resolveList) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_RESOLVE_ID);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_PART_RESOLVE_ID);
        if (activity == null) {
            return;
        }
        int add = 0;
        for (PartResolve e : resolveList) {
            int quality = e.getQuality();
            int type = e.getType();
            int count = e.getCount();
            int score = staticActivityDataMgr.getResolveSlug(activityBase.getKeyId(), type, quality);
            add += count * score;
        }
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0).longValue();
        statusList.set(0, score + add);

    }

    /**
     * 勋章分解兑换
     *
     * @return
     */
    public void medalResolve(Player player, List<MedalResolve> resolveList) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_RESOLVE);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }
        Activity activity = getActivityInfo(player, ActivityConst.ACT_MEDAL_RESOLVE);
        if (activity == null) {
            return;
        }
        int add = 0;
        for (MedalResolve e : resolveList) {
            int quality = e.getQuality();
            int type = e.getType();
            int count = e.getCount();
            float score = staticActivityDataMgr.getResolveSlug(activityBase.getKeyId(), type, quality);
            // 对紫色品质的勋章，不同部位有特殊处理，在原积分的基础上乘以不同的系数
            if (quality == 4 && type == AwardType.MEDAL) {
                List<List<Integer>> rate = staticActivityDataMgr.getMedalResolveScoreRate(activityBase.getKeyId());
                for (List<Integer> list : rate) {
                    if (list.get(0) == e.getPosition()) {
                        score *= (list.get(1) / 100F);
                        break;
                    }
                }
            }

            add += count * score;
        }
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0).longValue();
        statusList.set(0, score + add);

    }

    public void initPartyLvRank(int begin) {
        int status = rankDataManager.partyLvRankList.status;
        if (status != begin) {// 初始化
            rankDataManager.partyLvRankList.status = begin;// 开启时间设置为当前
            rankDataManager.partyLvRankList.getList().clear();// 清除已有历史
            Map<Integer, PartyData> partyMap = partyDataManager.getPartyMap();
            if (partyMap != null && !partyMap.isEmpty()) {
                Iterator<PartyData> it = partyMap.values().iterator();
                while (it.hasNext()) {
                    PartyData next = it.next();
                    int partyId = next.getPartyId();
                    String partyName = next.getPartyName();
                    int partyLv = next.getPartyLv();
                    int scienceLv = next.getScienceLv();
                    int wealLv = next.getWealLv();
                    int build = next.getBuild();
                    rankDataManager.LoadPartyLv(partyId, partyName, partyLv, scienceLv, wealLv, build);
                }
            }
            Collections.sort(rankDataManager.partyLvRankList.getList(), new ComparatorPartyLv());
        }
    }

    /**
     * 啥都没做
     *
     * @param activityId
     */
    public void resetPlayerRank(int activityId, int maxRank) {
        Map<Long, Player> playerMap = playerDataManager.getPlayers();
        Iterator<Player> it = playerMap.values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            Activity activity = getActivityInfo(player, activityId);
            if (activity == null) {
                continue;
            }
        }
        // Set<Integer> sets = staticActivityDataMgr.getSorts(activityId);
        // List<ActivityRankList> rankList = new ArrayList<ActivityRankList>();
        // for (int i = 0; i < sets.size(); i++) {
        // ActivityRankList ranks = new ActivityRankList();
        // rankList.add(ranks);
        // }
        // activityRankMap.put(activityId, rankList);
    }

    /**
     * 获取活动排行
     *
     * @return
     */
    public PartyLvRank getPartyLvRank(int partyId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) {
            return null;
        }
        int step = activityBase.getStep();
        if (step == ActivityConst.OPEN_STEP) {// begin-end之间
            int begin = TimeHelper.getDay(activityBase.getBeginTime());
            initPartyLvRank(begin);// 如果未初始化则初始化
        }
        PartyLvRank partyLvRank = rankDataManager.getPartyRank(partyId);
        return partyLvRank;
    }

    /**
     * @param page 第几页
     * @return List<PartyLvRank>
     * @Title: getPartyLvRankList
     * @Description: 军团等级排名
     */
    public List<PartyLvRank> getPartyLvRankList(int page) {
        List<PartyLvRank> list = new ArrayList<PartyLvRank>();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) {
            return list;
        }
        int step = activityBase.getStep();
        if (step == ActivityConst.OPEN_STEP) {// beginTime-endTime之间
            int begin = TimeHelper.getDay(activityBase.getBeginTime());
            initPartyLvRank(begin);// 如果未初始化则初始化
        }
        return rankDataManager.getPartyLvRank(page);
    }

    /**
     * @return List<PartyLvRank>
     * @Title: getPartyLvRankList
     * @Description: 军团等级排名
     */
    public List<PartyLvRank> getPartyLvRankList() {
        List<PartyLvRank> list = new ArrayList<PartyLvRank>();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) {
            return list;
        }
        int step = activityBase.getStep();
        if (step == ActivityConst.OPEN_STEP) {// beginTime-endTime之间
            int begin = TimeHelper.getDay(activityBase.getBeginTime());
            initPartyLvRank(begin);// 如果未初始化则初始化
        }
        return rankDataManager.getPartyLvRankList();
    }

    /**
     * 更新帮派等级排行
     *
     * @param partyId
     * @param partyLv
     */
    public void updatePartyLvRank(PartyData partyData) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) {
            return;
        }
        int begin = TimeHelper.getDay(activityBase.getBeginTime());
        initPartyLvRank(begin);// 如果未初始化则初始化
        rankDataManager.updatePartyLv(partyData);
    }

    /**
     * @param partyData void
     * @Title: addPartyLvRank
     * @Description: 新增军团时 加入排名系统
     */
    public void addPartyLvRank(PartyData partyData) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
        if (activityBase == null) {
            return;
        }
        int begin = TimeHelper.getDay(activityBase.getBeginTime());
        initPartyLvRank(begin);// 如果未初始化则初始化
        int partyId = partyData.getPartyId();
        String partyName = partyData.getPartyName();
        int partyLv = partyData.getPartyLv();
        int scienceLv = partyData.getScienceLv();
        int wealLv = partyData.getWealLv();
        int build = partyData.getBuild();
        PartyLvRank partyLvRank = new PartyLvRank(partyId, partyName, partyLv, scienceLv, wealLv, build);
        rankDataManager.getPartyLvRankList().add(partyLvRank);
    }

    /**
     * @param activity void
     * @Title: refreshDay
     * @Description: 清理隔天活动数据
     */
    public void refreshDay(Activity activity) {
        if (activity == null) {
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
        if (activityBase == null) {
            return;
        }
        activity.autoDayClean(activityBase);
    }

    /**
     * Function：活动状态刷新：创建和重开活动状态重置
     *
     * @param activity
     * @param beginTime
     */
    public void refreshStatus(Activity activity) {
        List<Long> statusList = new ArrayList<Long>();
        switch (activity.getActivityId()) {
            case ActivityConst.ACT_LEVEL:// 等级
                break;
            case ActivityConst.ACT_ATTACK: {// 攻打玩家
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_RANK_FIGHT:// 战力排行
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RANK_COMBAT:// 关卡排行
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RANK_HONOUR:// 荣誉排行
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RANK_PARTY_LV:// 军团等级排行
                for (int i = 0; i < 5; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PARTY_DONATE:// 军团捐献
                for (int i = 0; i < 4; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_LOT_EQUIP:// 装备探险
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_LOT_PART:// 配件探险
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_COLLECT_RESOURCE:// 资源收集
                for (int i = 0; i < 5; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_COMBAT:// 关卡送技能书
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RANK_PARTY_FIGHT:// 军团战力排行
                statusList.add(0L);// 军团战力排行
                for (int i = 0; i < 10; i++) {// 1-10名玩家ID
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_INVEST:// 投资计划
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RED_GIFT:// 充值红包
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_EVERYDAY:// 每日充值活动
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_FIRST:// 首次充值活动
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_QUOTA:// 折扣半价
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;

            case ActivityConst.ACT_PURPLE_COLL:// 紫装收集
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PURPLE_UP:// 紫装升级
                for (int i = 0; i < 20; i++) {
                    statusList.add(0L);//
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CRAZY_ARENA:// 疯狂竞技
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CRAZY_HERO:// 疯狂进阶
                for (int i = 0; i < 20; i++) {
                    statusList.add(0L);//
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_EVOLVE:// 配件进化
                break;
            case ActivityConst.ACT_FLASH_SALE:// 限时出售
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_ENLARGE:// 招兵买将
                break;
            case ActivityConst.ACT_LOTTEY_EQUIP:// 抽将折扣
                break;
            case ActivityConst.ACT_COST_GOLD:// 消费有奖
            case ActivityConst.ACT_COST_GOLD_MERGE:// 合服消费
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_EQUIP_FEED:// 装备补给
                break;
            case ActivityConst.ACT_CONTU_PAY:// 连续充值
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);//
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_FOISON:// 充值丰收
                break;
            case ActivityConst.ACT_DAY_PAY:// 天天充值
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_DAY_BUY:// 天天限购
            case ActivityConst.ACT_FLASH_META:// 材料限购
            case ActivityConst.ACT_MONTH_SALE:// 月末限购
            case ActivityConst.ACT_GIFT_OL:// 在线好礼
            case ActivityConst.ACT_MONTH_LOGIN:// 每月登录
            case ActivityConst.ACT_ENEMY_SALE:// 敌军兜售
            case ActivityConst.ACT_UP_EQUIP_CRIT:// 升装暴击
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_RE_FRIST_PAY:// 每天首充返利
            case ActivityConst.ACT_GIFT_PAY:// 充值送礼
            case ActivityConst.ACT_GIFT_PAY_MERGE:
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_VIP_GIFT:// vip礼包
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_CONTINUE4:// 连续充值
                for (int i = 0; i < 4; i++)
                    statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_SUPPLY:// 配件补给
            case ActivityConst.ACT_LOT_MILITARY:// 军工探险
            case ActivityConst.ACT_MILITARY_SUPPLY:// 军工补给
            case ActivityConst.ACT_LOT_ENERGYSTONE:// 能晶探险
            case ActivityConst.ACT_ENERGYSTONE_SUPPLY:// 能晶补给
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CONTU_PAY_MORE:// 连续充值2
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);//
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_ATTACK2: {// 攻打玩家2
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_INVEST_NEW:// 投资计划
                statusList.add(0L);//
                activity.setStatusList(statusList);
                break;
            /******* 精彩活动 ******/
            case ActivityConst.ACT_MECHA:// 机甲洪流
                for (int i = 0; i < 4; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_BEE_ID:// 勤劳致富
            case ActivityConst.ACT_BEE_NEW_ID:// 勤劳致富（新）
                for (int i = 0; i < 20; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_AMY_ID:// 建军节
            case ActivityConst.ACT_AMY_ID2:// 建军节2
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAWN_ID:// 极限单兵
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_DIAL_ID:// 配件转盘
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_TANK_DESTORY_ID:// 疯狂歼灭
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_GENERAL_ID:// 将领招募
                statusList.add(0L);// 积分
                statusList.add(0L);// 招募次数
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_EDAY_PAY_ID:// 每日充值
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CONSUME_DIAL_ID:// 消费转盘
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_VACATIONLAND_ID:// 度假胜地
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_EXCHANGE_ID:// 配件兑换
                for (int i = 0; i < 50; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_EQUIP_EXCHANGE_ID:// 装备兑换
                for (int i = 0; i < 50; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_RESOLVE_ID:// 配件分解兑换
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_MEDAL_RESOLVE:// 勋章分解兑换
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_GAMBLE_ID:// 累充下注
                statusList.add(0L);
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_TURNTABLE_ID:// 充值转盘
                statusList.add(0L);
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_SPRING_ID:// 新春狂欢
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PAY_REBATE:// 返利我做主
                statusList.add(0L); // 当前档位需求金额
                statusList.add(0L); // 当前档位返利百分率
                statusList.add(0L); // 当前档位已充值金额
                statusList.add(0L); // 转盘已转次数
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_GOD_GENERAL_ID:// 神领招募
                statusList.add(0L);// 积分
                statusList.add(0L);// 招募次数
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_BOSS:// 机甲贺岁
                statusList.add(0L);// 福袋数量
                statusList.add(0L);// 召唤次数
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_ENERGYSTONE_DIAL_ID:// 能晶转盘
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_HILARITY_PRAY_ID: // 新春狂欢祈福
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_OVER_REBATE_ID:// 清盘计划
                for (int i = 0; i < 20; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_WORSHIP_ID: // 拜神许愿
                for (int i = 0; i < 20; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_REBEL:// 活动叛军
                statusList.add(0L);// 击杀
                statusList.add(0L);// 积分
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_COLLEGE:// 西点学院
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_PART_SMELT_MASTER:// 淬炼大师
                statusList.add(0L);// 氪金抽奖获得积分
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CUMULATIVE:// 能量灌注
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_CHOOSE_GIFT:// 自选豪礼
                statusList.add(0L);// 总充值金额
                statusList.add(0L);// 领奖次数
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_BROTHER:// 兄弟同心
                for (int i = 0; i < 4; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            case ActivityConst.ACT_MEDAL_OF_HONOR: {
                for (int i = 0; i < 1; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_MONOPOLY: {//// 大富翁(圣诞宝藏)
                for (int i = 0; i < ActConst.ActMonopolyConst.GRID_SIZE; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_SECRET_STUDY_COUNT: {// 秘密行动
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_LOTTERY_EXPLORE: {// 探宝积分
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_EQUIP_DIAL: {// 装备转盘积分
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_LOGIN_WELFARE: {// 登陆福利
                List<StaticActAward> list = new ArrayList<>();
                ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOGIN_WELFARE);
                if (activityBase != null) {
                    list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
                }
                // 没有单独的配置指明活动开启天数，所以用奖励总条数-1(额外的1个最终奖励)来代替表示活动总天数
                for (int i = 0; i < list.size(); i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_QUESTIONNAIRE_SURVEY: {// 问卷调查活动
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_PAY_EVERYDAY_NEW_1:
            case ActivityConst.ACT_PAY_EVERYDAY_NEW_2: {// 新充值活动
                statusList.add(2L);
                statusList.add(2L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_PAY_PARTY: {// 军团充值
                statusList.add(0L);
                activity.setStatusList(statusList);
                break;
            }
            case ActivityConst.ACT_TIC_DIAL_ID:// 战术转盘
                for (int i = 0; i < 10; i++) {
                    statusList.add(0L);
                }
                activity.setStatusList(statusList);
                break;
            default:
                break;
        }
        if (activity.getStatusList() == null) {
            activity.setStatusList(statusList);
        }
    }

    /**
     * 获取当前处于开启时间段内的活动配置
     *
     * @param activityId
     * @return
     */
    public StaticActivityTime getCurActivityTime(int activityId) {
        int now = TimeHelper.getCurrentSecond();
        int weekDay = TimeHelper.getCNDayOfWeek();
        List<StaticActivityTime> list = staticActivityDataMgr.getActivityTimeById(activityId);
        if (!CheckNull.isEmpty(list)) {
            for (StaticActivityTime time : list) {
                if (time.getOpenWeekDay().contains(weekDay) && time.getStartTimeSec() <= now && now <= time.getEndTimeSec()) {
                    return time;
                }
            }
        }
        return null;
    }

    /**
     * @param player
     * @param staticActivityM1a2
     * @param times
     * @param from
     * @return List<CommonPb.Award>
     * @Title: getM1a2Awards
     * @Description: 根据权重计算m1a2活动掉落物品
     */
    public List<CommonPb.Award> getM1a2Awards(Player player, StaticActivityM1a2 staticActivityM1a2, int times, AwardFrom from) {
        List<CommonPb.Award> awards = new ArrayList<>();
        for (int i = 0; i < times; i++) {
            int seeds[] = {0, 0};
            for (List<Integer> award : staticActivityM1a2.getAwards()) {
                seeds[0] += award.get(3);
            }
            seeds[0] = RandomHelper.randomInSize(seeds[0]);
            Iterator<List<Integer>> its = staticActivityM1a2.getAwards().iterator();
            while (its.hasNext()) {
                List<Integer> award = its.next();
                seeds[1] += award.get(3);
                if (seeds[0] < seeds[1]) {
                    int type = award.get(0);
                    int id = award.get(1);
                    int count = award.get(2);

                    List<Integer> list = new ArrayList<>();
                    list.add(type);
                    list.add(id);
                    list.add(count);

                    awards.add(playerDataManager.addAwardBackPb(player, list, from));
                    break;
                }
            }
        }
        return awards;
    }

    // /** 全服玩家平均角色等级 */
    // private int caclRebelLv(){
    // List<Integer> lvList = new ArrayList<>();
    // Iterator<Player> its = playerDataManager.getPlayers().values().iterator();
    // while (its.hasNext()) {
    // lvList.add(its.next().lord.getLevel());
    // }
    //
    // if (lvList.size() == 0) { // 如果没有玩家，直接返回1
    // return 1;
    // }
    //
    // // 对玩家等级排行
    // Collections.sort(lvList);
    //
    // // 截取前100名玩家
    // int totalLv = 0;
    // int size = lvList.size() >= ActRebelConst.PLAYER_LEVEL_RANK ? ActRebelConst.PLAYER_LEVEL_RANK : lvList.size();
    // for (int i = lvList.size() - size; i < lvList.size(); i++) {
    // totalLv += lvList.get(i);
    // }
    //
    // // 计算平均等级，向上取整
    // return (totalLv + size - 1) / size;
    // }

    /**
     * 将基础等级上下浮动后，进行边界判断，返回最终值
     */
    private int getOffsetLv(int lv, int offset) {
        int level = lv + offset;
        if (level <= 0) {// 不小于1级
            level = 1;
        }

        if (level > Constant.PLAYER_OPEN_LV) {// 不超过当前玩家等级上限
            level = Constant.PLAYER_OPEN_LV;
        }
        return level;
    }

    /**
     * 刷新活动叛军
     */
    public int refreshActRebel(ActRebel actRebel, StaticActRebel staticActRebel) {
        // int averageLv = caclRebelLv();// 计算本次活动叛军等级
        // 根据当前在线人数刷新叛军
        Map<String, Player> playerMap = playerDataManager.getAllOnlinePlayer();
        Iterator<Player> it = playerMap.values().iterator();
        int count = playerMap.size();
        if (count <= 0) {
            return 0;
        }
        int i = 0;
        while (it.hasNext()) {
            Player next = it.next();
            if (next.lord == null) {
                continue;
            }
            if (next.lord.getPos() <= 0) {
                continue;
            }
            int averageLv = next.lord.getLevel();// 玩家等级+-5
            int differLv = RandomHelper.randomInSize(6);
            if (RandomHelper.randomInSize(2) == 1) {
                differLv = -differLv;
            }
            averageLv = getOffsetLv(averageLv, differLv);
            createActRebel(averageLv, next.lord.getPos(), actRebel, staticActRebel);// 创建叛军对象
            i++;
        }
        return i;
    }

    /**
     * @Title: actRebelEnd
     * @Description: 活动叛军结束 void
     */
    public void actRebelEnd() {
        worldDataManager.clearActRebelForm();
    }

    /**
     * 创建叛军在地图显示
     */
    private void createActRebel(int lv, int centerPos, ActRebel actRebel, StaticActRebel staticActRebel) {
        // 获取对应的叛军配置
        StaticActRebelTeam team = staticActivityDataMgr.getActRebelTeamByLv(lv);
        if (null == team) {
            LogUtil.error("活动叛军信息未配置, lv:" + lv + ", team:" + team);
            return;
        }

        Tuple<Integer, Integer> xy = WorldDataManager.reducePos(centerPos);
        int x = xy.getA();
        int y = xy.getB();
        // 八个方向
        List<Integer> canUsePos = new ArrayList<>();// 可用点
        Integer nearHasActRebelNum = 0;// 附近已有叛军数量
        for (int i = 1; i <= 8; i++) {
            int nearPos = 0;
            switch (i) {
                case 1:
                    nearPos = WorldDataManager.pos(x, y - 1);
                    break;
                case 2:
                    nearPos = WorldDataManager.pos(x + 1, y - 1);
                    break;
                case 3:
                    nearPos = WorldDataManager.pos(x + 1, y);
                    break;
                case 4:
                    nearPos = WorldDataManager.pos(x + 1, y + 1);
                    break;
                case 5:
                    nearPos = WorldDataManager.pos(x, y + 1);
                    break;
                case 6:
                    nearPos = WorldDataManager.pos(x - 1, y + 1);
                    break;
                case 7:
                    nearPos = WorldDataManager.pos(x - 1, y);
                    break;
                case 8:
                    nearPos = WorldDataManager.pos(x - 1, y - 1);
                    break;
            }
            if (!worldDataManager.isValidPos(nearPos)) {
                continue;
            }
            if (!worldDataManager.getFreePostList().contains(nearPos)) {
                if (worldDataManager.isActRebel(nearPos)) {
                    nearHasActRebelNum++;
                }
                continue;
            }
            canUsePos.add(nearPos);
        }

        int nearNumMax = staticActRebel.getMaxNumber();// 玩家周围最大活动叛军数
        int nearNumAdd = staticActRebel.getNumber();// 每次刷新数
        if (nearHasActRebelNum >= nearNumMax) {
            return;
        }

        if (nearNumMax < nearHasActRebelNum + nearNumAdd) {
            nearNumAdd = nearNumMax - nearHasActRebelNum;
        }
        if (nearNumAdd > canUsePos.size()) {
            nearNumAdd = canUsePos.size();
        }
        for (int i = 0; i < nearNumAdd; i++) {
            int pos = canUsePos.remove(0);
            ActRebelData rebel = new ActRebelData(team.getRebelId(), lv, pos);
            actRebel.getRebel().put(pos, rebel);

            // 初始化阵型，并放入地图
            putActRebelInMap(team, 0, pos);
        }
    }

    /**
     * @param team
     * @param heroId
     * @param pos    坐标 void
     * @Title: putActRebelInMap
     * @Description: 在地图上加入活动叛军
     */
    private void putActRebelInMap(StaticActRebelTeam team, int heroId, int pos) {
        Form form = new Form();
        form.setCommander(heroId);
        form.p[0] = team.getTeam1Id();
        form.c[0] = team.getTeam1number();
        form.p[1] = team.getTeam2Id();
        form.c[1] = team.getTeam2number();
        form.p[2] = team.getTeam3Id();
        form.c[2] = team.getTeam3number();
        form.p[3] = team.getTeam4Id();
        form.c[3] = team.getTeam4number();
        form.p[4] = team.getTeam5Id();
        form.c[4] = team.getTeam5number();
        form.p[5] = team.getTeam6Id();
        form.c[5] = team.getTeam6number();
        worldDataManager.setActRebelForm(pos, form);
    }

    /**
     * @return ActRebel
     * @Title: getActRebel
     * @Description: 获得活动叛军全局信息
     */
    public ActRebel getActRebel() {
        UsualActivityData activityData = getUsualActivity(ActivityConst.ACT_REBEL);
        if (activityData == null) {
            return null;
        }
        return activityData.getActRebel();
    }

    /**
     * @param area 区域id
     * @return List<ActRebelData>
     * @Title: getActRebelInArea
     * @Description: 获得该区域的活动叛军列表
     */
    public List<ActRebelData> getActRebelInArea(int area) {
        ActRebel actRebel = getActRebel();
        List<ActRebelData> list = new ArrayList<>();
        if (actRebel == null) {
            return list;
        }
        Map<Integer, ActRebelData> rebelMap = actRebel.getRebel();
        for (ActRebelData rebel : rebelMap.values()) {
            if (area == worldDataManager.area(rebel.getPos())) {
                list.add(rebel);
            }
        }
        return list;
    }

    /**
     * @param pos 坐标
     * @return ActRebelData
     * @Title: getActRebelByPos
     * @Description: 获得该坐标的活动叛军
     */
    public ActRebelData getActRebelByPos(int pos) {
        ActRebel actRebel = getActRebel();
        if (actRebel == null) {
            return null;
        }
        return actRebel.getRebel().get(pos);
    }

    /**
     * @param player
     * @param rebel
     * @param staticActRebel void
     * @Title: actRebelKill
     * @Description: 叛军被击杀
     */
    public void actRebelKill(Player player, ActRebelData rebel, StaticActRebel staticActRebel) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_REBEL);
        if (activityBase == null) {
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }

        Activity activity = getActivityInfo(player, ActivityConst.ACT_REBEL);
        if (activity == null) {
            return;
        }

        ActRebel actRebel = getActRebel();
        if (actRebel == null) {
            return;
        }
        actRebel.getRebel().remove(rebel.getPos());

        List<Long> statusList = activity.getStatusList();
        Long killNum = statusList.get(ActRebelConst.INDEX_KILL);
        Long score = statusList.get(ActRebelConst.INDEX_SCORE);

        int differLv = rebel.getRebelLv() - player.lord.getLevel();
        List<List<Integer>> pointPerTime = staticActRebel.getPointPerTime();
        int addScore = 0;
        for (List<Integer> pointRange : pointPerTime) {
            if (differLv <= pointRange.get(0) || differLv <= pointRange.get(1)) {
                addScore = pointRange.get(2);
                break;
            }
        }

        killNum++;
        score += addScore;

        statusList.set(ActRebelConst.INDEX_KILL, killNum);
        statusList.set(ActRebelConst.INDEX_SCORE, score);

        if (score >= staticActRebel.getPoint()) {
            addActRebelRankPlayer(actRebel, player.roleId, killNum.intValue(), score.intValue());
        }
    }

    /**
     * @param actRebel
     * @param lordId
     * @param killNum
     * @param score    void
     * @Title: addActRebelRankPlayer
     * @Description: 活动叛军击杀排名
     */
    public void addActRebelRankPlayer(ActRebel actRebel, long lordId, int killNum, int score) {
        LinkedList<ActRebelRank> rebelRank = actRebel.getRebelRank();
        ActRebelRank actRebelRank = actRebel.getRebelRankLordIdMap().get(lordId);

        if (actRebelRank == null) {
            actRebelRank = new ActRebelRank(lordId);
            actRebel.getRebelRankLordIdMap().put(lordId, actRebelRank);
            rebelRank.add(actRebelRank);
        }
        actRebelRank.setKillNum(killNum);
        actRebelRank.setScore(score);

        actRebelRank.setLastUpdateTime(TimeHelper.getCurrentSecond());
        Collections.sort(rebelRank, new ActRebelRankCompator());
    }

    /**
     * @author
     * @ClassName: ActRebelRankCompator
     * @Description: 活动叛军排序器
     */
    class ActRebelRankCompator implements Comparator<ActRebelRank> {

        @Override
        public int compare(ActRebelRank o1, ActRebelRank o2) {
            if (o1.getScore() != o2.getScore()) {
                return o2.getScore() - o1.getScore();
            }
            if (o1.getKillNum() != o2.getKillNum()) {
                return o2.getKillNum() - o1.getKillNum();
            }
            return o1.getLastUpdateTime() - o2.getLastUpdateTime();
        }
    }

    /**
     * @param actRebel 活动叛军全局
     * @param lordId   玩家编号
     * @return int
     * @Title: getActRebelRank
     * @Description: 得到玩家活动叛军击杀排名
     */
    public int getActRebelRank(ActRebel actRebel, long lordId) {
        int rank = 0;
        for (ActRebelRank r : actRebel.getRebelRank()) {
            rank++;
            if (r.getLordId() == lordId) {
                return rank;
            }
        }
        return 0;
    }

    /**
     * 回归玩家充值奖励
     */
    public void playerBackPay(Player player, int topup) {
        try {
            if (!staticFunctionPlanDataMgr.isPlayerBackOpen())
                return;// 判断老玩家回归活动是否开启
            int lv = player.account.getBackState();// 根据回归等级对应策划表中的回归天数
            int days = 0;
            if (lv == 0) {
                return;
            }
            if (lv == 1) {
                days = 7;
            } else if (lv == 2) {
                days = 14;
            } else if (lv == 3) {
                days = 21;
            } else if (lv == 4) {
                days = 28;
            }
            StaticBackMoney staticBackMoney = staticBackDataMgr.getMoney(days);// 获取回归返利信息
            if (staticBackMoney != null) {
                long endTime = player.account.getBackEndTime().getTime();// 获取回归玩家状态的结束时间
                int day = 10;
                if (endTime > System.currentTimeMillis()) {// 获取当前是处于回归的第几天
                    int time = (int) ((endTime - System.currentTimeMillis()) / 1000);
                    while (time > TimeHelper.DAY_S) {// 距离第二个回归点的秒数
                        time = time - TimeHelper.DAY_S;
                        day -= 1;
                    }
                }
                if (player.lord.getLevel() >= 30 && day <= staticBackMoney.getDay()) {// 回归状态是否结束以及玩家是否在30级以上并且处于回归的前三天
                    int value = staticBackMoney.getLuckey();// 读取策划表中不同级别的回归返利基数
                    List<Award> awards = new ArrayList<Award>();
                    awards.add(PbHelper.createAwardPb(AwardType.GOLD, 0, topup / 10));
                    awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 1, topup * value));
                    awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 2, topup * value));
                    awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 3, topup * value));
                    awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 4, topup * value));
                    awards.add(PbHelper.createAwardPb(AwardType.RESOURCE, 5, topup * value));
                    playerDataManager.sendAttachMail(AwardFrom.PLAYER_BACK_PAY, player, awards, MailType.PLAYER_BACK_PAY,
                            TimeHelper.getCurrentSecond(), String.valueOf(topup / 10));// 通过邮件像玩家发放回归奖励
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * @param player
     * @param topup
     */
    public void payEverydayNew(final int acrivityId, Player player, int topup) {
//        final int acrivityId = ActivityConst.ACT_PAY_EVERYDAY_NEW_1;
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(acrivityId);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }
        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);
        Activity activity = player.activitys.get(acrivityId);
        if (activity == null) {
            activity = new Activity(activityBase, begin);
            refreshStatus(activity);
            player.activitys.put(acrivityId, activity);
            activity.setEndTime(TimeHelper.getCurrentDay());
        } else {
            activity.isReset(begin);// 是否重新设置活动
            activity.autoDayClean(activityBase);
        }

        List<Long> statusList = activity.getStatusList();
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        long state = activity.getStatusList().get(0);
        Integer totalPay = statusMap.get(0);
        if (totalPay == null) totalPay = 0;
        // 如果当天第一次满足充值条件，则设置可领奖

        if (state != 2L) {
            return;
        }
        statusList.set(0, 0L);
        totalPay++;
        statusMap.put(0, totalPay);
        List<StaticActAward> awardList = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId());
        // 设置领奖状态
        for (StaticActAward actAward : awardList) {
            if (actAward.getCond() == 1) {
                // 加入到未领列表
                List<com.game.domain.p.Award> list = new LinkedList<>();
                for (List<Integer> al : actAward.getAwardList()) {
                    com.game.domain.p.Award award = new com.game.domain.p.Award(al.get(0), al.get(1), al.get(2), 0);
                    list.add(award);
                }
                globalDataManager.gameGlobal.addNotGet(player.roleId, NotGetAwardType.PAY_EVERYDAY_NEW, list);
                continue;
            }
            int keyId = actAward.getKeyId();
            Integer status = statusMap.get(keyId);
            if (status == null || status == 2) { // 如果未领奖则查看是否满足领奖条件，如果满足则设置为可领奖状态
                if (totalPay >= actAward.getCond()) {
                    statusMap.put(keyId, 0);
                }
            }
        }
    }

    //每日充值奖励如当日24点前没领取，则自动发送
    public void sendNotGetAwardMail() {
        Iterator<Entry<Long, Map<Integer, List<com.game.domain.p.Award>>>> playerIt = globalDataManager.gameGlobal.getNotGetAwardMap().entrySet().iterator();
        while (playerIt.hasNext()) {
            Entry<Long, Map<Integer, List<com.game.domain.p.Award>>> playerEntry = playerIt.next();
            long lordId = playerEntry.getKey();
            Map<Integer, List<com.game.domain.p.Award>> map = playerEntry.getValue();
            Iterator<Entry<Integer, List<com.game.domain.p.Award>>> awardIt = map.entrySet().iterator();
            Player player = null;
            while (awardIt.hasNext()) {
                Entry<Integer, List<com.game.domain.p.Award>> awardEntry = awardIt.next();

                if (awardEntry.getKey() == NotGetAwardType.PAY_EVERYDAY_NEW) {
                    List<Award> list = PbHelper.createAwardListPb(awardEntry.getValue());

                    if (player == null) {
                        player = playerDataManager.getPlayer(lordId);
                    }

                    StaticMail staticMail = staticMailDataMgr.getStaticMail(MailType.MOLD_MAIL_NOTGETAWARD);
                    Mail sendMail = new Mail(player.maxKey(), staticMail.getType(), staticMail.getMoldId(),
                            MailType.STATE_UNREAD_ITEM, TimeHelper.getCurrentSecond());
                    sendMail.setAward(list);
                    player.mails.put(sendMail.getKeyId(), sendMail);
                    playerDataManager.synMailToPlayer(player, sendMail);
                    awardIt.remove();
                }
            }
        }
    }

    public void payPartyRecharge(int acrivityId, Player player, int topup) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(acrivityId);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }
        //若活动再次开启，将oldPartyId置为0,活动结束后由定时器统计更新
        player.lord.setOldPartyId(0);

        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);
        Activity activity = player.activitys.get(acrivityId);
        if (activity == null) {
            activity = new Activity(activityBase, begin);
            refreshStatus(activity);
            player.activitys.put(acrivityId, activity);
            activity.setEndTime(TimeHelper.getCurrentDay());
        } else {
            activity.isReset(begin);// 是否重新设置活动
            activity.autoDayClean(activityBase);
        }

        List<Long> statusList = activity.getStatusList();
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Integer totalPay = activity.getStatusList().size() > 0 ? activity.getStatusList().get(0).intValue() : null;
        if (totalPay == null) {
            totalPay = 0;
        }

        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData != null) {
            totalPay = (int) partyData.getTeamRecharge() + topup;
            partyData.setTeamRecharge(totalPay);
            //partyData.copyData();
        } else if (partyData == null && step == ActivityConst.OPEN_STEP) {
            statusMap.clear();
            return;
        }
        statusList.set(0, Long.valueOf(totalPay));
        List<StaticActAward> awardList = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId());
        // 设置领奖状态
        for (StaticActAward actAward : awardList) {
            int keyId = actAward.getKeyId();
            Integer status = statusMap.get(keyId);
            if (status == null || status == 2) { // 如果未领奖则查看是否满足领奖条件，如果满足则设置为可领奖状态
                if (totalPay >= actAward.getCond()) {
                    statusMap.put(keyId, 0);
                }
            }
        }

    }

}
