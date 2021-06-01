package com.game.manager;

import java.util.*;

import com.alibaba.fastjson.JSONArray;
import com.game.pb.BasePb;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.AwardFrom;
import com.game.constant.Constant;
import com.game.constant.MailType;
import com.game.constant.RebelConstant;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticRebelDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.domain.s.StaticRebelHero;
import com.game.domain.s.StaticRebelTeam;
import com.game.domain.sort.ActRedBag;
import com.game.rebel.domain.PartyRebelData;
import com.game.rebel.domain.Rebel;
import com.game.rebel.domain.RoleRebelData;
import com.game.service.ChatService;

/**
 * @author TanDonghai
 * @ClassName RebelDataManager.java
 * @Description 叛军相关数据处理
 * @date 创建时间：2016年9月3日 下午1:56:04
 */
@Component
public class RebelDataManager {
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private StaticRebelDataMgr staticRebelDataMgr;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private SmallIdManager smallIdManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PartyDataManager partyDataManager;

    private int rebelStatus;// 叛军入侵活动状态

    private int lastOpenTime;// 最近一次开启叛军活动的时间

    private int lastOpenWeek;// 最近一次开启叛军活动的是开服第几周

    private int changeStatusTime;// 记录下次状态改变时间，包括改变为开启或结束状态

    private int nextAppearanceTime;// 记录下一波叛军出现的时间

    private int nextRebelType;// 记录下一波叛军的类型

    /**
     * 记录叛军领袖 刷新时间
     */
    private long boss_time = System.currentTimeMillis();


    // 叛军入侵活动，叛军信息
    private Map<Integer, Rebel> rebelMap;

    // 叛军入侵活动，上周玩家排行
    private List<Long> lastWeekRankList;

    // 叛军入侵活动，上周军团排行
    private List<Integer> lastWeekPartyRank;

    // 叛军入侵活动，已领取上周个人排行的玩家lordId
    private Set<Long> rebelRewardSet;

    // 叛军入侵活动，已领取上周军团排行的玩家lordId
    private Set<Long> partyRewardSet;

    // 上次刷新周排行榜的日期
    private int rebelLastWeekRankDate;

    // 叛军入侵活动，本次活动已掉落将领记录, key:heroId, value:droppedNum
    private Map<Integer, Integer> rebelHeroDropMap;

    // 叛军入侵活动，本次活动已掉落将领叛军类型记录, key:rebelType, value:droppedNum
    private Map<Integer, Integer> rebelTypeDropMap;

    // 叛军入侵，玩家活动相关数据
    private Map<Long, RoleRebelData> roleRebelMap = new HashMap<>();

    // 叛军入侵活动本周玩家排行数据
    private LinkedList<RoleRebelData> rebelWeekRank = new LinkedList<>();

    // 叛军入侵活动排行总榜数据
    private LinkedList<RoleRebelData> rebelTotalRank = new LinkedList<>();

    // 叛军入侵活动本周军团活动数据
    private LinkedList<PartyRebelData> rebelPartyInfo = new LinkedList<>();

    // 叛军入侵活动本周军团排行
    private LinkedList<PartyRebelData> partyWeekRank = new LinkedList<>();

    // 叛军礼盒掉落时间
    private Map<Integer, Integer> boxDropTime = new HashMap<>();

    // 叛军礼盒剩余可领取次数
    private Map<Integer, Integer> boxLeftCount = new HashMap<>();

    // 叛军礼盒开启获得的系统红包
    private Map<Integer, ActRedBag> redBags = new TreeMap<>();

    // @PostConstruct
    public void init() {
        rebelStatus = globalDataManager.gameGlobal.getRebelStatus();
        lastOpenTime = globalDataManager.gameGlobal.getRebelLastOpenTime();
        rebelLastWeekRankDate = globalDataManager.gameGlobal.getRebelLastWeekRankDate();

        rebelMap = globalDataManager.gameGlobal.getRebelMap();
        rebelRewardSet = globalDataManager.gameGlobal.getRebelRewardSet();
        rebelHeroDropMap = globalDataManager.gameGlobal.getRebelHeroDropMap();
        rebelTypeDropMap = globalDataManager.gameGlobal.getRebelTypeDropMap();
        lastWeekRankList = globalDataManager.gameGlobal.getRebelLastWeekRankList();
        lastWeekPartyRank = globalDataManager.gameGlobal.getRebelLastWeekPartyRank();
        boxLeftCount = globalDataManager.gameGlobal.getBoxLeftCount();
        boxDropTime = globalDataManager.gameGlobal.getBoxDropTime();
        redBags = globalDataManager.gameGlobal.getRedBags();
        partyRewardSet = globalDataManager.gameGlobal.getPartyRewardSet();
        rebelPartyInfo = globalDataManager.gameGlobal.getRebelPartyInfo();

        // 初始化阵型，并放入地图
        StaticRebelTeam team;
        StaticRebelHero hero;
        for (Rebel rebel : rebelMap.values()) {
            if (rebel.isAlive()) {
                team = staticRebelDataMgr.getRebelTeam(rebel.getType(), rebel.getRebelLv());
                hero = staticRebelDataMgr.getRebelHeroById(rebel.getHeroPick());
                putRebelInMap(team, hero.getAssociate(), rebel.getPos());
            }
        }

        // 将礼盒放入地图
        worldDataManager.setRebelBoxInMap(boxLeftCount);
    }


    /**
     * 判断叛军领袖是否全部击杀
     *
     * @return
     */
    public boolean checkRebelTypeLeaderDead() {

        if (rebelMap != null) {
            Collection<Rebel> values = rebelMap.values();
            for (Rebel rebel : values) {

                if (rebel.getType() == RebelConstant.REBEL_TYPE_LEADER) {

                    if (rebel.getState() != RebelConstant.REBEL_STATE_DEAD) {
                        return false;
                    }
                }
            }
            return true;

        }
        return false;
    }

    /**
     * 判断叛军是否全部击杀 排除叛军boss
     *
     * @return
     */
    public boolean checkRebelDead() {

        if (rebelMap != null) {
            Collection<Rebel> values = rebelMap.values();
            for (Rebel rebel : values) {

                if (rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {
                    continue;
                }

                if (rebel.getState() != RebelConstant.REBEL_STATE_DEAD) {
                    return false;
                }
            }
            return true;
        }

        return false;
    }

    /**
     * 刷新叛军boss
     */
    public void refreshRebelBoss(Rebel rebel) {

        if (rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {
            syncInfo(rebel);
            return;
        }

        Rebel rebelBoss = getRebelBoss();
        //说明已经刷新
        if (rebelBoss != null) {
            return;
        }

        //说明 领袖还没有全部死亡
        if (!checkRebelTypeLeaderDead()) {
            return;
        }

        //可以刷新了
        LogUtil.common("叛军入侵活动，领袖全部死亡 可以刷新叛军boss了");
        initRebels(RebelConstant.REBEL_TYPE_BOOS);

    }


    public Rebel getRebelBoss() {
        Collection<Rebel> values = rebelMap.values();
        for (Rebel rebel : values) {
            if (rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {
                return rebel;
            }
        }
        return null;
    }

    private float getBossHp(long time) {
        float minute = (int) (time / 1000 / 60.0f);
        String rebelHp = RebelConstant.REBEL_HP;
        JSONArray jsonArray = JSONArray.parseArray(rebelHp);
        for (Object obj : jsonArray) {
            JSONArray jsonArray1 = JSONArray.parseArray(obj.toString());
            if (minute >= jsonArray1.getIntValue(0) && minute <= jsonArray1.getIntValue(1)) {
                return Float.valueOf(jsonArray1.getIntValue(2) / 100.0f);
            }
        }
        return 1;
    }


    /**
     * 服务器启动后执行部分需要数据加载完成才能执行的初始化操作
     */
    public void initData() {
        if (changeStatusTime == 0) {
            if (rebelStatus == RebelConstant.REBEL_STATUS_OPEN) {
                setChangeStatusTime(lastOpenTime + RebelConstant.REBEL_DURATION);

                // 如果活动还没有结束，而且过了刷叛军的时间，对应的叛军没有刷出来，执行相应的操作
                int hasRefreshed = haveRebelType();
                if (hasRefreshed < 3) {
                    int delay = TimeHelper.getCurrentSecond() - lastOpenTime;// 活动开始到当前时间的时间间隔，单位：秒
                    int batch = delay / RebelConstant.REBEL_DELAY;// 活动开启后到当前时间能刷新的叛军批次
                    if (hasRefreshed == 0) {
                        LogUtil.common("服务器重启，叛军开启中，却没有叛军对象!!!lastOpenTime:" + lastOpenTime + ", rebelMap:" + rebelMap);
                    } else if (hasRefreshed == 1) {// 已经刷新了一波叛军
                        if (batch == 0) {// 当前还没到刷新第二波叛军的时间，计算出刷新下波叛军的时间，并记录
                            nextAppearanceTime = lastOpenTime + RebelConstant.REBEL_DELAY;
                            nextRebelType = RebelConstant.REBEL_TYPE_GUARD;
                        } else if (batch == 1) {// 已经过了刷新第二波叛军的时间，但还没到刷新第三波的时间，执行刷新第二波叛军
                            LogUtil.common("叛军入侵活动，重启后刷新第2波叛军");
                            initRebels(RebelConstant.REBEL_TYPE_GUARD);
                        } else {// 当前已经过了刷新所有叛军的时间，却只刷新了一波叛军，立即刷新出剩余两波叛军
                            LogUtil.common("叛军入侵活动，重启后刷新第2波叛军");
                            initRebels(RebelConstant.REBEL_TYPE_GUARD);
                            LogUtil.common("叛军入侵活动，重启后刷新第2波叛军");
                            initRebels(RebelConstant.REBEL_TYPE_LEADER);
                        }
                    } else {// 已经刷新了两波叛军
                        if (batch < 1) {
                            LogUtil.common("叛军入侵活动，重启后未到刷新第二波叛军的时间，却已刷出两波叛军!!!lastOpenTime:" + lastOpenTime);
                        } else if (batch == 1) {// 已刷出第二波叛军，未到刷出第三波的时间，计算并记录刷新第三波的时间
                            nextAppearanceTime = lastOpenTime + RebelConstant.REBEL_DELAY * 2;
                            nextRebelType = RebelConstant.REBEL_TYPE_LEADER;
                        } else {// 当前已经过了第三波叛军出现的时间，还没有刷新叛军，立即刷新
                            LogUtil.common("叛军入侵活动，重启后刷新第3波叛军");
                            initRebels(RebelConstant.REBEL_TYPE_LEADER);
                        }
                    }
                }

                // 如果当前已经过了活动时间，结束活动
                int now = TimeHelper.getCurrentSecond();
                if (now >= getChangeStatusTime()) {
                    rebelEnd();
                    LogUtil.common("启动后已过活动时间，叛军入侵活动结束");
                }
            } else {
                setChangeStatusTime(getNextOpenTime());
            }

            if (lastOpenTime > 0) {
                lastOpenWeek = DateHelper.getWeekOfYearCN(lastOpenTime * 1000L);
                LogUtil.common("重启后更新lastOpenWeek:" + lastOpenWeek);
            }
        }

        Iterator<Player> its = playerDataManager.getPlayers().values().iterator();
        RoleRebelData data;
        while (its.hasNext()) {
            Player player = its.next();
            if (!smallIdManager.isSmallId(player.lord.getLordId())) {// 去小号
                data = player.rebelData;
                if (null != data) {
                    roleRebelMap.put(player.lord.getLordId(), data);

                    if (DateHelper.getWeekOfYearCN(data.getWeekRankTime() * 1000L) == lastOpenWeek) {
                        data.setLastUpdateWeek(lastOpenWeek);
                    }

                    if (data.getLastUpdateWeek() == lastOpenWeek
                            && data.getScore() >= RebelConstant.WEEK_PLAYER_RANK_LIMIT) {
                        rebelWeekRank.add(data);
                    }

                    if (data.getTotalScore() >= RebelConstant.TOTAL_RANK_LIMIT) {
                        rebelTotalRank.add(data);
                    }
                }
            }
        }
        if (rebelPartyInfo.size() == 0) {
            // 计算获取周军团榜，理论上，只会在军团榜系统初创时计算一次，之后每周一刷新后的计算并无意义
            caclWeekPartyInfo();
        }

        // 重排排行榜
        Collections.sort(rebelWeekRank, new RebelRankCompator());
        Collections.sort(rebelTotalRank, new RebelTotalRankCompator());
    }

    /**
     * 计算当前已刷新了几种叛军
     *
     * @return
     */
    private int haveRebelType() {
        Set<Integer> rebelTypeSet = new HashSet<>();
        for (Rebel rebel : rebelMap.values()) {
            if (!rebelTypeSet.contains(rebel.getType())) {
                rebelTypeSet.add(rebel.getType());
            }
        }
        return rebelTypeSet.size();
    }

    /**
     * 计算下一次开启叛军活动的时间
     *
     * @return
     */
    private int getNextOpenTime() {
        int nextHour = 0;
        int nextOpenTime = 0;
        boolean newDay = true;// 记录下次开启活动是否是在新的一天
        boolean newWeek = true;// 记录下次开启活动是否是在下一个星期
        int dayOfWeek = TimeHelper.getCNDayOfWeek();

        List<Integer> hourList = new ArrayList<>(RebelConstant.RebelOpenTimeMap.keySet());
        Collections.sort(hourList);

        // 如果今天还未到活动首开时间，或今天不是需要开启活动的日子，则下次活动一定是在新的一天中进行，且时间一定是当天的最小开启时间，不用进入下面的判断
        int openServerDay = DateHelper.getServerOpenDay();
        if (openServerDay >= RebelConstant.REBEL_FIRST_OPEN_DAY
                || RebelConstant.RebelOpenWeekDayList.contains(dayOfWeek)) {
            int hour = TimeHelper.getHour();// 当前小时
            int minute = TimeHelper.getMinute();// 当前分钟
            for (Integer h : hourList) {
                if (h > hour || (h == hour && RebelConstant.RebelOpenTimeMap.get(h) > minute)) {
                    // 如果当前还未到活动开启时间，则说明今天还会开启叛军活动
                    nextHour = h;
                    newDay = false;
                    break;
                }
            }
        }

        if (newDay) {// 今天不会再有叛军活动，计算下次开启在几天后的几点
            nextHour = hourList.get(0);

            int add = 0;
            // 如果当前还未到首开活动的时间，计算首开活动的是星期几，并记录今天到首开那天隔了几天
            if (openServerDay < RebelConstant.REBEL_FIRST_OPEN_DAY) {
                add = RebelConstant.REBEL_FIRST_OPEN_DAY - openServerDay;
                dayOfWeek = (dayOfWeek + add) % 7;
                if (dayOfWeek == 0) {
                    dayOfWeek = 7;
                }
            }

            int nextWeekDay = 0;
            for (Integer day : RebelConstant.RebelOpenWeekDayList) {
                if (day > dayOfWeek) {
                    nextWeekDay = day;
                    newWeek = false;
                }
            }

            int addDays = add;
            if (newWeek) {// 如果该周已经不会再开启叛军活动，则下次开启一定是在下个星期最早开启活动的那天
                nextWeekDay = RebelConstant.RebelOpenWeekDayList.get(0);
                addDays = nextWeekDay + 7 - dayOfWeek;
            } else {
                addDays = nextWeekDay - dayOfWeek;
            }

            nextOpenTime = TimeHelper.getSomeDayAfter(addDays, nextHour, RebelConstant.RebelOpenTimeMap.get(nextHour),
                    0);
        } else {// 今天还会开启叛军活动
            nextOpenTime = TimeHelper.getSecond(nextHour, RebelConstant.RebelOpenTimeMap.get(nextHour), 0);
        }

        return nextOpenTime;
    }

    /**
     * 叛军入侵活动开始
     */
    public void rebelStart() {
        // 清空上次记录
        rebelMap.clear();
        rebelHeroDropMap.clear();
        rebelTypeDropMap.clear();

        // 发送公告
        chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_Start), 1);

        initRebels(RebelConstant.REBEL_TYPE_UNIT);// 活动开启时只生成分队叛军的数据，其它类型的叛军在后面陆续创建

        setRebelStatus(RebelConstant.REBEL_STATUS_OPEN);
        lastOpenWeek = DateHelper.getWeekOfYearCN();
        setLastOpenTime(TimeHelper.getCurrentSecond());
        changeStatusTime = lastOpenTime + RebelConstant.REBEL_DURATION;
        isSendBuffRewad = false;

        nextAppearanceTime = lastOpenTime + RebelConstant.REBEL_DELAY;
        nextRebelType = RebelConstant.REBEL_TYPE_GUARD;
    }

    /**
     * 按叛军类型初始化相关叛军数据
     *
     * @param rebelType
     */
    public void initRebels(int rebelType) {
        int lv = 0;
        int averageLv = caclRebelLv();// 计算本次活动叛军等级
        List<StaticRebelHero> selectedList = new ArrayList<>();
        if (rebelType == RebelConstant.REBEL_TYPE_UNIT) {
            for (int i = 0; i < RebelConstant.UNIT_REBEL_NUM; i++) {// 初始化分队叛军数据，等级向上下浮动2级，平均分配
                if (i <= (RebelConstant.UNIT_REBEL_NUM / 5)) {
                    lv = getOffsetLv(averageLv, -2);
                } else if (i <= (RebelConstant.UNIT_REBEL_NUM * 2 / 5)) {
                    lv = getOffsetLv(averageLv, -1);
                } else if (i <= (RebelConstant.UNIT_REBEL_NUM * 3 / 5)) {
                    lv = averageLv;
                } else if (i <= (RebelConstant.UNIT_REBEL_NUM * 4 / 5)) {
                    lv = getOffsetLv(averageLv, 1);
                } else {
                    lv = getOffsetLv(averageLv, 2);
                }

                createRebel(lv, RebelConstant.REBEL_TYPE_UNIT, selectedList);// 创建叛军对象
            }
            // 发送公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_Unit), 1);
        } else if (rebelType == RebelConstant.REBEL_TYPE_GUARD) {
            for (int i = 0; i < RebelConstant.GUARD_REBEL_NUM; i++) {// 初始化卫队叛军数据，等级向上下浮动1级，平均分配
                if (i <= (RebelConstant.GUARD_REBEL_NUM / 3)) {
                    lv = getOffsetLv(averageLv, -1);
                } else if (i <= (RebelConstant.GUARD_REBEL_NUM * 2 / 3)) {
                    lv = averageLv;
                } else {
                    lv = getOffsetLv(averageLv, 1);
                }

                createRebel(lv, RebelConstant.REBEL_TYPE_GUARD, selectedList);// 创建叛军对象
            }
            nextAppearanceTime = lastOpenTime + RebelConstant.REBEL_DELAY * 2;
            nextRebelType = RebelConstant.REBEL_TYPE_LEADER;
            // 发送公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_Guard), 1);
        } else if (rebelType == RebelConstant.REBEL_TYPE_LEADER) {
            for (int i = 0; i < RebelConstant.LEADER_REBEL_NUM; i++) {// 初始化领袖叛军数据，等级向上浮动1级，平均分配
                if (i <= (RebelConstant.LEADER_REBEL_NUM / 2)) {
                    lv = averageLv;
                } else {
                    lv = getOffsetLv(averageLv, 1);
                }

                createRebel(lv, RebelConstant.REBEL_TYPE_LEADER, selectedList);// 创建叛军对象
            }
            nextAppearanceTime = 0;

            boss_time = System.currentTimeMillis();
            // 发送公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_Leader), 1);
        } else if (rebelType == RebelConstant.REBEL_TYPE_BOOS) {
            // 创建叛军boss对象
            createRebel(averageLv, RebelConstant.REBEL_TYPE_BOOS, selectedList);

        }

        selectedList.clear();
    }

    /**
     * 创建叛军对象，并在地图中显示
     *
     * @param lv
     * @param type
     * @param selectedList
     */
    private void createRebel(int lv, int type, List<StaticRebelHero> selectedList) {

        if (lv > 90) {
            lv = 90;
        }

        // 获取对应的叛军配置
        StaticRebelTeam team = staticRebelDataMgr.getRebelTeam(type, lv);

        // 随机将领
        StaticRebelHero hero = staticRebelDataMgr.randomHeroByType(type, lv, selectedList);

        if (null == team || null == hero) {
            LogUtil.error("叛军信息未配置, lv:" + lv + ", type:" + type + ", team:" + team + ", hero:" + hero);
            return;
        }
        selectedList.add(hero);// 记录已随机到的hero

        // 从地图中随机空闲坐标
        int pos = worldDataManager.randomEmptyPos();

        Rebel rebel = new Rebel(team.getRebelId(), lv, type, pos, hero.getHeroPick());

        if (type == RebelConstant.REBEL_TYPE_BOOS) {

            long time = System.currentTimeMillis() - boss_time;
            rebel.setBoss_hp(getBossHp(time));
            LogUtil.common("刷新叛军boss  time=" + boss_time + " hp=" + rebel.getBoss_hp());

            // 发送公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.REBEL_BOSS, pos + ""), 1);

            syncInfo(rebel);
        }

        rebelMap.put(pos, rebel);
        // 初始化阵型，并放入地图
        putRebelInMap(team, hero.getAssociate(), pos);


    }

    /**
     * 初始化阵型，并放入地图
     *
     * @param team
     * @param heroId
     * @param pos
     */
    private void putRebelInMap(StaticRebelTeam team, int heroId, int pos) {
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
        worldDataManager.setRebelForm(pos, form);
    }

    /**
     * 将基础等级上下浮动后，进行边界判断，返回最终值
     *
     * @param lv
     * @param offset
     * @return
     */
    private int getOffsetLv(int lv, int offset) {
        int level = lv + offset;
        if (level < 0) {// 不小于1级
            level = 1;
        }

        if (level > Constant.MAX_ROLE_LEVEL) {// 不超过当前玩家等级上限
            level = Constant.MAX_ROLE_LEVEL;
        }
        return level;
    }

    /**
     * 计算全服等级排行前100名玩家的平均等级，向上取整，作为本次叛军活动的基础等级
     *
     * @return
     */
    private int caclRebelLv() {
        List<Integer> lvList = new ArrayList<>();
        Iterator<Player> its = playerDataManager.getPlayers().values().iterator();
        while (its.hasNext()) {
            lvList.add(its.next().lord.getLevel());
        }

        if (lvList.size() == 0) { // 如果没有玩家，直接返回1
            return 1;
        }

        // 对玩家等级排行
        Collections.sort(lvList);

        // 截取前100名玩家
        int totalLv = 0;
        int size = lvList.size() >= 100 ? 100 : lvList.size();
        for (int i = lvList.size() - size; i < lvList.size(); i++) {
            totalLv += lvList.get(i);
        }

        int result = (totalLv + size - 1) / size;

        if (result > 90) {
            result = 90;
        }
        // 计算平均等级，向上取整
        return result;
    }

    /**
     * 叛军活动随机掉落将领，如果不掉落，返回0
     *
     * @param heroPick
     * @return
     */
    public int randomHeroDrop(int heroPick) {
        StaticRebelHero hero = staticRebelDataMgr.getRebelHeroById(heroPick);

        Integer heroDrop = rebelHeroDropMap.get(hero.getHeroDrop());
        Integer typeDrop = rebelTypeDropMap.get(hero.getTeamType());
        if ((heroDrop == null || heroDrop < hero.getLimitation()) && canDropRebelTypeHero(hero.getTeamType(), typeDrop)) {// 将领掉落有上限
            int random = RandomHelper.randomInSize(100);// 按概率随机
            if (random < hero.getDropProbability()) {
                if (null == heroDrop) {
                    heroDrop = 0;
                }
                if (null == typeDrop) {
                    typeDrop = 0;
                }
                // 记录已掉落数量
                rebelHeroDropMap.put(hero.getHeroDrop(), heroDrop + 1);
                rebelTypeDropMap.put(hero.getTeamType(), typeDrop + 1);
                return hero.getHeroDrop();
            }
        }

        return 0;
    }

    /**
     * 计算该类叛军是否达到掉落将领的上限
     *
     * @param rebelType
     * @param typeDrop
     * @return
     */
    private boolean canDropRebelTypeHero(int rebelType, Integer typeDrop) {
        int droppedNum = 0;
        if (null != typeDrop) {
            droppedNum = typeDrop;
        }
        switch (rebelType) {
            case RebelConstant.REBEL_TYPE_UNIT:
                return droppedNum < RebelConstant.UNIT_DROP_LIMIT;
            case RebelConstant.REBEL_TYPE_GUARD:
                return droppedNum < RebelConstant.GUARD_DROP_LIMIT;
            case RebelConstant.REBEL_TYPE_LEADER:
                return droppedNum < RebelConstant.LEADER_DROP_LIMIT;
        }
        return false;
    }

    private boolean isSendBuffRewad;

    /**
     * 玩家在活动结束前击杀所有叛军，给全服玩家发随机buff
     */
    public void sendRebelBuffReward() {
        if (rebelStatus != RebelConstant.REBEL_STATUS_OPEN) {
            return;
        }


        if (checkRebelDead() && nextAppearanceTime == 0) {
            if (isSendBuffRewad) {
                LogUtil.common("叛军全服随机BUFF奖励已发，跳过");
                return;
            }

            List<List<Integer>> rewardList = staticWarAwardDataMgr.getRebelBuffReward();
            if (CheckNull.isEmpty(rewardList)) {
                LogUtil.error("叛军全部死亡，全服随机BUFF未配置");
                return;
            }

            // 从奖励配置中随机一个奖励
            List<Integer> list = rewardList.get(RandomHelper.randomInSize(rewardList.size()));
            if (CheckNull.isEmpty(list) || list.size() < 3) {
                LogUtil.common("叛军全部死亡，全服随机BUFF配置不正确, randomReward:" + list);
                return;
            }

            Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
            LogUtil.common("叛军全部死亡，给全服玩家发随机BUFF, reward:" + list);
            while (it.hasNext()) {
                Player player = it.next();
                try {
                    if (player != null && player.isActive()) {
                        // 发送buff奖励
                        playerDataManager.addAward(player, list.get(0), list.get(1), list.get(2),
                                AwardFrom.REBEL_BUFF_REWARD);

                        // 发送通知邮件
                        playerDataManager.sendNormalMail(player, MailType.MOLD_BUFF_REWARD,
                                TimeHelper.getCurrentSecond(), String.valueOf(list.get(1)));
                    }
                } catch (Exception e) {
                    LogUtil.error("全服随机BUFF发送异常, lordId:" + player.lord.getLordId() + ", reward:" + list);
                }
            }

            // 发送公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_All_Dead), 1);

            isSendBuffRewad = true;
        }
    }

    /**
     * 叛军入侵活动结束
     */
    public void rebelEnd() {
        // 检查叛军是否全部死亡
        if (!worldDataManager.getRebelFormMap().isEmpty()) {
            // 发送活动结束公告
            chatService.sendHornChat(chatService.createSysChat(SysChatId.Rebel_End), 1);

            // 清空叛军所在坐标数据
            worldDataManager.clearRebelForm();

            // 返还礼盒坐标
            for (Integer pos : boxLeftCount.keySet()) {
                worldDataManager.removeReblBoxFromMap(pos);
            }
            // 清除礼盒
            boxLeftCount.clear();
            boxDropTime.clear();

            // 将未死亡的叛军记录为逃跑状态
            for (Rebel rebel : rebelMap.values()) {
                if (rebel.isAlive()) {
                    rebel.setState(RebelConstant.REBEL_STATE_RUN);
                }
            }
        }

        setRebelStatus(RebelConstant.REBEL_STATUS_END);
        setChangeStatusTime(getNextOpenTime());
    }

    /**
     * 刷新周榜数据，每周一0点执行
     */
    public void refreshRebelWeekRank() {
        int monday = TimeHelper.getThisWeekMonday();
        if (monday == rebelLastWeekRankDate) {
            return;// 本次已刷新过了，跳过
        }

        lastWeekRankList.clear();
        lastWeekPartyRank.clear();
        rebelRewardSet.clear();
        partyRewardSet.clear();

        // 将当前的排行数据填充入上周排行榜中
        int playerRank = 0;
        int partyRank = 0;
        for (RoleRebelData data : rebelWeekRank) {
            lastWeekRankList.add(data.getLordId());

            playerRank++;
            // 重置玩家的上周排行
            data.setLastRank(playerRank);

            if (playerRank <= 30) {
                LogUtil.common("叛军周排行榜，上榜玩家:" + data.getLordId() + "|" + data.getNick() + ", rank:" + playerRank);
            }
        }

        for (PartyRebelData data : partyWeekRank) {
            lastWeekPartyRank.add(data.getPartyId());

            partyRank++;
            data.setLastRank(partyRank);
            if (playerRank <= 30) {
                LogUtil.common("叛军周排行榜，上榜军团:" + data.getPartyId() + "|" + data.getPartyName() + ", rank:" + playerRank);
            }
        }

        // 清空当前排行榜
        rebelWeekRank.clear();

        // 重新清一次军团榜
        rebelPartyInfo.clear();
        partyWeekRank.clear();

        // 清空玩家的本周记录，并记录玩家结算时的军团id
        for (RoleRebelData data : roleRebelMap.values()) {
            data.cleanWeekData(lastOpenWeek);
            Player player = playerDataManager.getPlayer(data.getLordId());
            player.rebelEndPartyId = partyDataManager.getPartyId(data.getLordId());
        }

        setRebelLastWeekRankDate(monday);
        LogUtil.common("已成功刷新叛军周排行榜");
    }

    /**
     * 将玩家加入排行榜
     *
     * @param data
     */
    public void addRankPlayer(RoleRebelData data) {
        // 周个人榜相关操作
        if (data.getScore() >= RebelConstant.WEEK_PLAYER_RANK_LIMIT) {
            if (rebelWeekRank.size() == 0) {
                rebelWeekRank.add(data);
            } else {
                if (!rebelWeekRank.contains(data)) {
                    rebelWeekRank.add(data);
                }
            }

            data.setWeekRankTime(TimeHelper.getCurrentSecond());
            Collections.sort(rebelWeekRank, new RebelRankCompator());
        }

        // 总榜相关操作
        if (data.getTotalScore() >= RebelConstant.TOTAL_RANK_LIMIT) {
            if (rebelTotalRank.size() == 0) {
                rebelTotalRank.add(data);
            } else {
                if (!rebelTotalRank.contains(data)) {
                    rebelTotalRank.add(data);
                }
            }

            data.setTotalRankTime(TimeHelper.getCurrentSecond());
            Collections.sort(rebelTotalRank, new RebelTotalRankCompator());
        }
    }

    /**
     * 获取玩家上周的排行，如果未上榜，返回0
     *
     * @param lordId
     * @param rankType
     * @return
     */
    public int getRoleLastWeekRank(long lordId, int rankType) {
        Player player = playerDataManager.getPlayer(lordId);
        int rank = 0;
        if (rankType == RebelConstant.RANK_TYPE_WEEK_PLAYER) {
            for (Long roleId : lastWeekRankList) {
                rank++;
                if (roleId == lordId) {
                    return rank;
                }
            }
        } else if (rankType == RebelConstant.RANK_TYPE_WEEK_PARTY) {
            for (int partyId : lastWeekPartyRank) {
                rank++;
                // 叛军军团榜规则变更
                int p = player.rebelEndPartyId;
                // 对更新之前的排行榜特殊处理，按之前的机制领奖
                if (TimeHelper.getCurrentSecond() < 1538323200) {
                    p = partyDataManager.getPartyId(lordId);
                }
                if (partyId == p) {
                    return rank;
                }
            }
        }

        return 0;
    }

    /**
     * 获取玩家在周榜上的排行，如果未上榜，返回0
     *
     * @param lordId
     * @return
     */
    public int getCurrentRank(long lordId) {
        int rank = 0;
        for (RoleRebelData data : rebelWeekRank) {
            rank++;
            if (data.getLordId() == lordId) {
                return rank;
            }
        }
        return 0;
    }

    /**
     * 获取军团在周榜上的排行，如果未上榜，返回0
     *
     * @param partyId
     * @return
     */
    public int getCurrentPartyRank(int partyId) {
        int rank = 0;
        for (PartyRebelData data : partyWeekRank) {
            rank++;
            if (data.getPartyId() == partyId) {
                return rank;
            }
        }
        return 0;
    }

    /**
     * 获取玩家总榜排行，如果未上榜，返回0
     *
     * @param lordId
     * @return
     */
    public int getTotalRank(long lordId) {
        int rank = 0;
        for (RoleRebelData data : rebelTotalRank) {
            rank++;
            if (data.getLordId() == lordId) {
                return rank;
            }
        }
        return 0;
    }

    /**
     * 是否已领取奖励
     *
     * @param lordId
     * @param awardType
     * @return boolean
     */
    public boolean isGetReward(long lordId, int awardType) {
        if (awardType == RebelConstant.AWARD_TYPE_WEEK_PLAYER) {
            return rebelRewardSet.contains(lordId);
        }
        if (awardType == RebelConstant.AWARD_TYPE_WEEK_PARTY) {
            return partyRewardSet.contains(lordId);
        }
        return true;
    }

    public int getRebelStatus() {
        return rebelStatus;
    }

    public void setRebelStatus(int rebelStatus) {
        this.rebelStatus = rebelStatus;
        globalDataManager.gameGlobal.setRebelStatus(rebelStatus);
    }

    /**
     * @return boolean
     */
    public boolean isRebelStart() {
        return rebelStatus == RebelConstant.REBEL_STATUS_OPEN;
    }

    public int getLastOpenTime() {
        return lastOpenTime;
    }

    public void setLastOpenTime(int lastOpenTime) {
        this.lastOpenTime = lastOpenTime;
        globalDataManager.gameGlobal.setRebelLastOpenTime(lastOpenTime);
    }

    /**
     * 叛军周排行榜
     *
     * @param rebelLastWeekRankDate void
     */
    public void setRebelLastWeekRankDate(int rebelLastWeekRankDate) {
        this.rebelLastWeekRankDate = rebelLastWeekRankDate;
        globalDataManager.gameGlobal.setRebelLastWeekRankDate(rebelLastWeekRankDate);
    }

    public int getChangeStatusTime() {
        return changeStatusTime;
    }

    public void setChangeStatusTime(int changeStatusTime) {
        this.changeStatusTime = changeStatusTime;
    }

    public int getNextAppearanceTime() {
        return nextAppearanceTime;
    }

    public int getNextRebelType() {
        return nextRebelType;
    }

    public int getLastOpenWeek() {
        return lastOpenWeek;
    }

    public void setLastOpenWeek(int lastOpenWeek) {
        this.lastOpenWeek = lastOpenWeek;
    }

    public Rebel getRebelByPos(int pos) {
        return rebelMap.get(pos);
    }

    public Map<Integer, Rebel> getRebelMap() {
        return rebelMap;
    }

    public Map<Integer, Integer> getBoxDropTime() {
        return boxDropTime;
    }

    public void setBoxDropTime(Map<Integer, Integer> dropTime) {
        this.boxDropTime = dropTime;
    }

    public Map<Integer, Integer> getBoxLeftCount() {
        return boxLeftCount;
    }

    public void setBoxLeftCount(Map<Integer, Integer> leftCount) {
        this.boxLeftCount = leftCount;
    }

    public Map<Integer, ActRedBag> getRedBags() {
        return redBags;
    }

    public void setRedBags(Map<Integer, ActRedBag> redBags) {
        this.redBags = redBags;
    }

    public Set<Long> getPartyRewardSet() {
        return partyRewardSet;
    }

    /**
     * 获取区域内的所有叛军
     *
     * @param area
     * @return
     */
    public List<Rebel> getRebelInArea(int area) {
        List<Rebel> list = new ArrayList<>();
        for (Rebel rebel : rebelMap.values()) {
            if (area == worldDataManager.area(rebel.getPos())) {
                list.add(rebel);
            }
        }
        return list;
    }

    /**
     * 获取区域内所有的礼盒
     *
     * @param area
     * @return
     */
    public List<Integer> getBoxPosInArea(int area) {
        List<Integer> list = new ArrayList<>();
        Set<Integer> boxPos = worldDataManager.getRebelBoxMap().keySet();
        for (Integer pos : boxPos) {
            if (area == worldDataManager.area(pos)) {
                list.add(pos);
            }
        }
        return list;
    }

    public Map<Long, RoleRebelData> getRoleRebelMap() {
        return roleRebelMap;
    }

    /**
     * 获取玩家叛军活动数据，如果没有，初始化
     *
     * @param lordId
     * @return
     */
    public RoleRebelData getRoleRebelData(long lordId) {
        RoleRebelData data = roleRebelMap.get(lordId);
        if (null == data) {
            data = new RoleRebelData();
            Player player = playerDataManager.getPlayer(lordId);
            data.setLordId(lordId);
            data.setNick(player.lord.getNick());
            data.setLastUpdateTime(lastOpenTime);
            data.setLastUpdateWeek(lastOpenWeek);

            roleRebelMap.put(lordId, data);
            player.rebelData = data;
        }
        return data;
    }

    /**
     * 返回玩家在本次叛军活动中，是否已经达到击杀上限
     *
     * @param lordId
     * @return
     */
    public boolean killNumIsMax(long lordId) {
        RoleRebelData data = getRoleRebelData(lordId);
        return data.getKillNum() >= RebelConstant.KILL_REBEL_LIMIT;
    }

    public Set<Long> getRebelRewardSet() {
        return rebelRewardSet;
    }

    public LinkedList<RoleRebelData> getRebelWeekRank() {
        return rebelWeekRank;
    }

    public LinkedList<RoleRebelData> getRebelTotalRank() {
        return rebelTotalRank;
    }

    public LinkedList<PartyRebelData> getPartyWeekRank() {
        return partyWeekRank;
    }

    public LinkedList<PartyRebelData> getRebelPartyInfo() {
        return rebelPartyInfo;
    }

    public List<Integer> getLastWeekPartyRank() {
        return lastWeekPartyRank;
    }

    /**
     * 获取参加过本周叛军活动的所有军团
     */
    private Set<PartyRebelData> getRebelWeekParty() {
        Set<PartyRebelData> WeekPartyInfo = new HashSet<>();
        for (Long roleId : roleRebelMap.keySet()) {
            // 如果该玩家本周内参与过叛军活动，才会将其军团加入周排行榜
            if (roleRebelMap.get(roleId).getLastUpdateWeek() != lastOpenWeek) {
                continue;
            }
            int partyId = partyDataManager.getPartyId(roleId);
            // 如果该玩家未加入加团
            if (partyId == 0) {
                continue;
            }
            String partyName = partyDataManager.getPartyNameByLordId(roleId);
            int rank = partyDataManager.getRank(partyId);
            PartyRebelData partyData = new PartyRebelData(partyId, partyName, rank);

            WeekPartyInfo.add(partyData);
        }
        return WeekPartyInfo;
    }

    /**
     * 每次起服时，重新根据个人周榜，计算出所有军团本周的叛军活动信息
     */
    public void caclWeekPartyInfo() {
        // 先计算出本周参加过叛军活动的军团
        Set<PartyRebelData> WeekPartyInfo = getRebelWeekParty();
        for (PartyRebelData partyRebelData : WeekPartyInfo) {
            int killUnit = 0;
            int killGuard = 0;
            int killLeader = 0;
            int score = 0;
            for (RoleRebelData roleData : roleRebelMap.values()) {
                if (partyDataManager.getPartyId(roleData.getLordId()) == partyRebelData.getPartyId()) {
                    killUnit += roleData.getKillUnit();
                    killGuard += roleData.getKillGuard();
                    killLeader += roleData.getKillLeader();
                    score += roleData.getScore();
                }
            }
            partyRebelData.setKillUnit(killUnit);
            partyRebelData.setKillGuard(killGuard);
            partyRebelData.setKillLeader(killLeader);
            partyRebelData.setScore(score);
        }
        this.rebelPartyInfo = new LinkedList<>(WeekPartyInfo);
        caclPartyWeekRank();
    }

    /**
     * 根据所有军团本周的活动信息，计算军团周榜
     */
    public LinkedList<PartyRebelData> caclPartyWeekRank() {
        Collections.sort(this.rebelPartyInfo, new RebelPartyRankCompator());
        partyWeekRank.clear();
        for (int i = 0; i < rebelPartyInfo.size(); i++) {
            PartyRebelData data = rebelPartyInfo.get(i);
            // 当军团满足最低分要求时，且排行榜中不存在该军团时，将其加入排行榜
            if (data.getScore() >= RebelConstant.WEEK_PARTY_RANK_LIMIT) {
                partyWeekRank.add(data);
            }
        }
        return partyWeekRank;
    }

    /**
     * 将玩家所在军团加入排行榜,若已存在，更新军团信息
     */
    public void updateWeekPartyRank(RoleRebelData data, int type) {
        PartyRebelData partyRebelData = new PartyRebelData();
        int partyId = partyDataManager.getPartyId(data.getLordId());
        // 若未加入军团，不做任何更新处理
        if (partyId == 0) {
            return;
        }
        String partyName = partyDataManager.getPartyNameByLordId(data.getLordId());
        partyRebelData.setPartyId(partyId);
        partyRebelData.setPartyName(partyName);
        partyRebelData.setRank(partyDataManager.getRank(partyId));
        // 如果该军团已记录，更新信息
        if (rebelPartyInfo.contains(partyRebelData)) {
            for (PartyRebelData party : rebelPartyInfo) {
                if (party.getPartyId() == partyId) {
                    party.addKillNum(type);
                    break;
                }
            }
        } else {
            // 未记录，则必然是第一次打叛军
            partyRebelData.addKillNum(type);
            rebelPartyInfo.add(partyRebelData);
        }
        caclPartyWeekRank();
    }

    /**
     * 根据玩家ID，获取其所在军团的叛军排行信息
     */
    public PartyRebelData getPartyRebelDataByRoleId(long roleId) {
        PartyRebelData data = new PartyRebelData();
        for (PartyRebelData partyData : rebelPartyInfo) {
            if (partyData.getPartyId() == partyDataManager.getPartyId(roleId)) {
                data = partyData;
            }
        }
        /*
         * 逻辑上，若此partyId==0,即意味着 1.该玩家之前未加入军团，未加入军团之前的积分不计入该玩家之后所属军团
         * 2.或者其所在军团之前未参加过叛军活动
         */
        if (data.getPartyId() == 0) {
            PartyRebelData data2 = new PartyRebelData();
            int partyId = partyDataManager.getPartyId(roleId);
            String partyName = partyDataManager.getPartyNameByLordId(roleId);
            data2.setPartyId(partyId);
            data2.setPartyName(partyName);
            data2.setRank(partyDataManager.getRank(partyId));
            rebelPartyInfo.add(data2);
            data = data2;
        }
        return data;
    }


    private void syncInfo(Rebel rebel) {
        try {

            GamePb6.RebelBoosStateRq.Builder builder = GamePb6.RebelBoosStateRq.newBuilder();
            builder.setBoosState(PbHelper.createRebelPb(rebel));
            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.RebelBoosStateRq.EXT_FIELD_NUMBER, GamePb6.RebelBoosStateRq.ext, builder.build());

            Collection<Player> values = playerDataManager.getPlayers().values();
            for (Player player : values) {
                if (player.isLogin) {
                    try {
                        GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
                    } catch (Exception e) {
                        LogUtil.error(e);
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

}

/**
 * 总榜排序器
 *
 * @author
 * @ClassName: RebelTotalRankCompator
 * @Description: TODO
 */
class RebelTotalRankCompator implements Comparator<RoleRebelData> {

    @Override
    public int compare(RoleRebelData o1, RoleRebelData o2) {
        if (o1.getTotalScore() > o2.getTotalScore()) {
            return -1;
        } else if (o1.getTotalScore() < o2.getTotalScore()) {
            return 1;
        } else {
            if (o1.getTotalRankTime() < o2.getTotalRankTime()) {
                return -1;
            } else if (o1.getTotalRankTime() > o2.getTotalRankTime()) {
                return 1;
            }
        }
        return 0;
    }
}

/**
 * 排行排序器
 *
 * @author
 * @ClassName: RebelRankCompator
 * @Description: TODO
 */
class RebelRankCompator implements Comparator<RoleRebelData> {

    @Override
    public int compare(RoleRebelData o1, RoleRebelData o2) {
        if (o1.getScore() > o2.getScore()) {
            return -1;
        } else if (o1.getScore() < o2.getScore()) {
            return 1;
        } else {
            if (o1.getWeekRankTime() < o2.getWeekRankTime()) {
                return -1;
            } else if (o1.getWeekRankTime() > o2.getWeekRankTime()) {
                return 1;
            }
        }
        return 0;
    }
}

/**
 * 军团榜排序器
 *
 * @author
 * @ClassName: RebelRankCompator
 * @Description: TODO
 */
class RebelPartyRankCompator implements Comparator<PartyRebelData> {

    @Override
    public int compare(PartyRebelData o1, PartyRebelData o2) {
        if (o1.getScore() > o2.getScore()) {
            return -1;
        } else if (o1.getScore() < o2.getScore()) {
            return 1;
        } else {
            if (o1.getRank() < o2.getRank()) {
                return -1;
            } else if (o1.getRank() > o2.getRank()) {
                return 1;
            }
        }
        return 0;
    }


}
