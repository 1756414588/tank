package com.game.service.cross.fight;

import com.alibaba.fastjson.JSON;
import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.cross.domain.Athlete;
import com.game.cross.domain.ComptePojo;
import com.game.cross.domain.CompteRound;
import com.game.cross.domain.CrossShopBuy;
import com.game.cross.domain.CrossTrend;
import com.game.cross.domain.JiFenPlayer;
import com.game.cross.domain.KnockoutBattleGroup;
import com.game.cross.domain.MyBet;
import com.game.cross.domain.*;
import com.game.dao.table.fight.*;
import com.game.datamgr.StaticCrossDataMgr;
import com.game.datamgr.StaticHeroDataMgr;
import com.game.datamgr.StaticWarAwardDataMgr;
import com.game.domain.PEnergyCore;
import com.game.domain.p.AttackEffect;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Form;
import com.game.domain.p.PartyScience;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.s.StaticHero;
import com.game.domain.table.cross.CrossFightAthleteTable;
import com.game.domain.table.cross.CrossFightInfoTable;
import com.game.domain.table.cross.CrossFightPlayerJifenTable;
import com.game.domain.table.cross.CrossFightTable;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.cross.fight.CrossDataManager;
import com.game.manager.cross.fight.CrossFightCache;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.*;
import com.game.pb.CrossGamePb.*;
import com.game.server.GameContext;
import com.game.server.config.gameServer.Server;
import com.game.server.util.ChannelUtil;
import com.game.service.ChatService;
import com.game.service.FightService;
import com.game.service.cross.ChatInfo;
import com.game.service.cross.MailInfo;
import com.game.service.cross.party.CrossPartyService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/13 13:43 @Description :java类作用描述
 */
@Service
public class CrossService {
    @Autowired
    private ChatService chatService;
    @Autowired
    private CrossDataManager crossDataManager;
    @Autowired
    private FightService fightService;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private StaticCrossDataMgr staticCrossDataMgr;
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;
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
    private CrossCacheUpdateService crossCacheUpdateService;
    @Autowired
    private ServerSetting serverSetting;
    /**
     * 跨服id
     */
    public static final int crossId = CrossDataManager.crossId;

    /**
     * 获取跨服服务器信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossServerList(CCGetCrossServerListRq rq, ClientHandler handler) {
        // 这里初始化了所以查看 跨服的玩家数据   这个有必要么？？？
        if (Integer.valueOf(serverSetting.getCrossType()) == CrossConst.CrossType) {
            initJifenPlayer(rq.getRoleId(), handler.getServerId(), rq.getNick());
        }
        CCGetCrossServerListRs.Builder builder = CCGetCrossServerListRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        for (Server server : GameContext.getGameServerConfig().getList()) {
            builder.addGameServerInfo(PbHelper.createGameServerInfoPb(server));
        }
        handler.sendMsgToPlayer(CCGetCrossServerListRs.ext, builder.build());
    }

    /**
     * 跨服战逻辑定时器
     */
    public void crossWarTimerLogic() {
        int dayNum = TimeHelper.getDayOfCrossWar();
        // 跨服战是否开始
        if (dayNum >= 1 && dayNum <= 11) {
            // 发送跨服战开始消息
            synCrossBeginMsg(dayNum);
            synCrossBeginMail(dayNum);
        }
        LinkedHashMap<String, String> timeRegion = CrossServiceCache.getFlow(dayNum);
        try {
            if (timeRegion != null) {
                // 资格争夺
                if (dayNum == CrossConst.STAGE.STAGE_ZIGEZHENDUO) {
                    doZiGeZhenDuo();
                }
                // 报名
                else if (dayNum == CrossConst.STAGE.STAGE_REG) {
                    doCrossReg();
                }
                // 积分赛第一天
                else if (dayNum == CrossConst.STAGE.STAGE_JIFEN1) {
                    doJiFenFight(dayNum, true);
                }
                // 淘汰赛第一天
                else if (dayNum == CrossConst.STAGE.STAGE_KNOCK1) {
                    doKnockFight(dayNum);
                }
                // 总决赛
                else if (dayNum == CrossConst.STAGE.STATE_FINAL) {
                    doFinalFight(dayNum);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error("", e);
        }
    }

    /**
     * 总决赛
     *
     * @param dayNum
     */
    private void doFinalFight(int dayNum) {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        String crossState = crossFightTable.getCrossState();
        CrossState cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        CrossFightFinal crossFight = crossDataManager.crossFightFinal;
        // 半决赛
        if (TimeHelper.isFinalBeginHalf()) {
            String beginTime = "12:00:00";
            String endTime = "12:15:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightFinal(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightFinal = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightFinal(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightFinal = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                            LogUtil.error("总决赛场半决赛 完成");
                        }
                    }
                }
            }
        }
        // 总决赛
        else if (TimeHelper.isFinalBeginFinal()) {
            String beginTime = "20:00:00";
            String endTime = "20:15:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightFinal(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightFinal = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightFinal(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightFinal = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            LogUtil.error("总决赛场决赛 完成");
                            // 生成排行
                            generateTopRank();
                            // 发送奖励
                            sendTopServerRewardMail();
                            // 生成排行名人同步数据到各个服
                            synCrossRank();
                            // 自动领取下注积分
                            autoReceiveBet();
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                        }
                    }
                }
            }
        }
    }

    /**
     * 淘汰赛
     *
     * @param dayNum
     */
    private void doKnockFight(int dayNum) {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        String crossState = crossFightTable.getCrossState();
        CrossState cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        CrossFightKnock crossFight = crossDataManager.crossFightKnock;
        // 淘汰赛时间
        if (TimeHelper.isKnockBegin_16_8()) {
            String beginTime = "12:00:00";
            String endTime = "12:30:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                            LogUtil.error("淘汰赛16-8完成");
                        }
                    }
                }
            }
        } else if (TimeHelper.isKnockBegin_8_4()) {
            String beginTime = "15:30:00";
            String endTime = "16:00:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                            LogUtil.error("淘汰赛8-4完成");
                        }
                    }
                }
            }
        } else if (TimeHelper.isKnockBegin_4_2()) {
            String beginTime = "19:00:00";
            String endTime = "19:30:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                            LogUtil.error("淘汰赛4-2完成");
                        }
                    }
                }
            }
        } else if (TimeHelper.isKnockBegin2_1()) {
            String beginTime = "22:30:00";
            String endTime = "23:00:00";
            if (crossFight == null) {
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    // 说明第一次
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightKnock(dayNum, beginTime);
                    crossFight.init();
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                    crossDataManager.crossFightKnock = crossFight;
                }
                if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                    if (cs.getState() != CrossConst.end_state) {
                        if (crossFight.round()) {
                            cs.setState(CrossConst.end_state);
                            crossFightTable.setCrossState(JSON.toJSONString(cs));
                            crossFightTableDao.update(crossFightTable);
                            LogUtil.error("淘汰赛2-1完成");
                        }
                    }
                }
            }
        }
    }

    /**
     * 积分战
     *
     * @param dayNum         哪一天
     * @param isGengeryKnock 是否生成淘汰赛
     */
    private void doJiFenFight(int dayNum, boolean isGengeryKnock) {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        String crossState = crossFightTable.getCrossState();
        CrossState cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        if (cs == null) {
            cs = new CrossState();
        }
        CrossFightJiFen crossFight = crossDataManager.crossJiFenFight;
        String nowTime = TimeHelper.getNowHourAndMins();
        // 判断时间是否在比赛时间内
        LinkedHashMap<String, String> regions = CrossServiceCache.getFlow(dayNum);
        String beginTime = null;
        String endTime = null;
        Iterator<String> its = regions.keySet().iterator();
        // 获取比赛时间
        while (its.hasNext()) {
            String tempBeginTime = its.next();
            String tempEndTime = regions.get(tempBeginTime);
            if ((nowTime.compareTo(tempBeginTime) > 0) && (tempEndTime.compareTo(nowTime) > 0)) {
                beginTime = tempBeginTime;
                endTime = tempEndTime;
                break;
            }
        }
        // 说明在比赛时间内
        if (beginTime != null) {
            if (crossFight == null) {
                // 判断上次记录的是什么时间,若跟现在时间不一致。 若不是同一天,则说明第一次,new 新的。
                // 若是同一天,则说明跨越了,new 新的
                if (cs.getStage() != dayNum) {
                    crossFight = new CrossFightJiFen(dayNum, beginTime);
                    crossFight.init();
                    crossDataManager.crossJiFenFight = crossFight;
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                } else if (!cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightJiFen(dayNum, beginTime);
                    crossFight.init();
                    crossDataManager.crossJiFenFight = crossFight;
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                }
                // 若跟现在一致,则说明是 该时间段内重启的,new 新的 并设置结束
                // if (cs.getBeginTime().equals(beginTime)) {
                // crossFight = new CrossFightJiFen(dayNum, beginTime);
                // // crossFight.init();
                // crossDataManager.crossJiFenFight = crossFight;
                //
                // cs.setStage(dayNum);
                // cs.setBeginTime(beginTime);
                // cs.setEndTime(endTime);
                // cs.setState(CrossConst.end_state);
                // }
            } else {
                // 判断上次记录的时间,若不想同,说明是上次的,new 新的
                if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                    crossFight = new CrossFightJiFen(dayNum, beginTime);
                    crossFight.init();
                    crossDataManager.crossJiFenFight = crossFight;
                    cs.setStage(dayNum);
                    cs.setBeginTime(beginTime);
                    cs.setEndTime(endTime);
                    cs.setState(CrossConst.begin_state);
                    crossFightTable.setCrossState(JSON.toJSONString(cs));
                    crossFightTableDao.update(crossFightTable);
                }
                // 若相同,判断是否打完,没打完继续打
                if (cs.getState() != CrossConst.end_state) {
                    if (crossFight.round()) {
                        cs.setState(CrossConst.end_state);
                        crossFightTable.setCrossState(JSON.toJSONString(cs));
                        crossFightTableDao.update(crossFightTable);
                        if (isGengeryKnock) {
                            // 若是最后一次, 则需要生成
                            Object[] os = regions.keySet().toArray();
                            List<Object> list = Arrays.asList(os);
                            String key = (String) list.get(list.size() - 1);
                            if (beginTime.equals(key)) {
                                // 生成淘汰赛16强
                                generateKnockOut16();
                            }
                        }
                    }
                }
            }
        }
        // 判断到没有23点,若过了23点,且没有生成，则生成16强
        if (nowTime.compareTo("23:00:00") > 0 && "23:00:05".compareTo(nowTime) > 0) {
            Object[] os = regions.keySet().toArray();
            List<Object> list = Arrays.asList(os);
            String key = (String) list.get(list.size() - 1);
            if (!(cs.getStage() == dayNum && cs.getBeginTime().equals(key) && cs.getState() == CrossConst.end_state)) {
                // 生成淘汰赛16强
                generateKnockOut16();
            }
        }
    }

    /**
     * 生成总排行 决赛完成时进行排名
     */
    private void generateTopRank() {
        // 巅峰总决赛排行
        LinkedHashMap<Long, Long> dfFinalRankMap4 = new LinkedHashMap<Long, Long>();
        // 巅峰前8
        LinkedHashMap<Long, Long> dfKnockRankMap8 = new LinkedHashMap<Long, Long>();
        // 巅峰淘汰前16
        LinkedHashMap<Long, Long> dfKnockRankMap16 = new LinkedHashMap<Long, Long>();
        // 巅峰淘汰前32
        LinkedHashMap<Long, Long> dfKnockRankMap32 = new LinkedHashMap<Long, Long>();
        // 巅峰淘汰前64
        LinkedHashMap<Long, Long> dfKnockRankMap64 = new LinkedHashMap<Long, Long>();
        // 巅峰总决赛冠亚季殿军
        CompetGroup dfFinalCg3 = CrossFightCache.getDfFinalBattleGroups().get(3);
        addKeyToMap(dfFinalCg3, dfFinalRankMap4);
        CompetGroup dfFinalCg4 = CrossFightCache.getDfFinalBattleGroups().get(4);
        addKeyToMap(dfFinalCg4, dfFinalRankMap4);
        // 前8
        KnockoutBattleGroup dfA = CrossFightCache.getDfKnockoutBattleGroups().get(1);
        KnockoutBattleGroup dfB = CrossFightCache.getDfKnockoutBattleGroups().get(2);
        KnockoutBattleGroup dfC = CrossFightCache.getDfKnockoutBattleGroups().get(3);
        KnockoutBattleGroup dfD = CrossFightCache.getDfKnockoutBattleGroups().get(4);
        addKnockKeyToMap(dfA, dfKnockRankMap8, 15, 15);
        addKnockKeyToMap(dfB, dfKnockRankMap8, 15, 15);
        addKnockKeyToMap(dfC, dfKnockRankMap8, 15, 15);
        addKnockKeyToMap(dfD, dfKnockRankMap8, 15, 15);
        crossDataManager.sortMapByJifen(dfKnockRankMap8);
        // 前16
        dfA = CrossFightCache.getDfKnockoutBattleGroups().get(1);
        dfB = CrossFightCache.getDfKnockoutBattleGroups().get(2);
        dfC = CrossFightCache.getDfKnockoutBattleGroups().get(3);
        dfD = CrossFightCache.getDfKnockoutBattleGroups().get(4);
        addKnockKeyToMap(dfA, dfKnockRankMap16, 13, 14);
        addKnockKeyToMap(dfB, dfKnockRankMap16, 13, 14);
        addKnockKeyToMap(dfC, dfKnockRankMap16, 13, 14);
        addKnockKeyToMap(dfD, dfKnockRankMap16, 13, 14);
        crossDataManager.sortMapByJifen(dfKnockRankMap16);
        // 前32
        dfA = CrossFightCache.getDfKnockoutBattleGroups().get(1);
        dfB = CrossFightCache.getDfKnockoutBattleGroups().get(2);
        dfC = CrossFightCache.getDfKnockoutBattleGroups().get(3);
        dfD = CrossFightCache.getDfKnockoutBattleGroups().get(4);
        addKnockKeyToMap(dfA, dfKnockRankMap32, 9, 12);
        addKnockKeyToMap(dfB, dfKnockRankMap32, 9, 12);
        addKnockKeyToMap(dfC, dfKnockRankMap32, 9, 12);
        addKnockKeyToMap(dfD, dfKnockRankMap32, 9, 12);
        crossDataManager.sortMapByJifen(dfKnockRankMap32);
        // 巅峰淘汰赛前64名
        dfA = CrossFightCache.getDfKnockoutBattleGroups().get(1);
        dfB = CrossFightCache.getDfKnockoutBattleGroups().get(2);
        dfC = CrossFightCache.getDfKnockoutBattleGroups().get(3);
        dfD = CrossFightCache.getDfKnockoutBattleGroups().get(4);
        addKnockKeyToMap(dfA, dfKnockRankMap64, 1, 8);
        addKnockKeyToMap(dfB, dfKnockRankMap64, 1, 8);
        addKnockKeyToMap(dfC, dfKnockRankMap64, 1, 8);
        addKnockKeyToMap(dfD, dfKnockRankMap64, 1, 8);
        crossDataManager.sortMapByJifen(dfKnockRankMap64);
        crossDataManager.totalRank(CrossFightCache.getDfRankMap(), dfFinalRankMap4);
        crossDataManager.totalRank(CrossFightCache.getDfRankMap(), dfKnockRankMap8);
        crossDataManager.totalRank(CrossFightCache.getDfRankMap(), dfKnockRankMap16);
        crossDataManager.totalRank(CrossFightCache.getDfRankMap(), dfKnockRankMap32);
        crossDataManager.totalRank(CrossFightCache.getDfRankMap(), dfKnockRankMap64);
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        byte[] bytes1 = crossFightTable.serdfRankMap(CrossFightCache.getDfRankMap());
        crossFightTable.setDfRank(bytes1);
        /** 精英总决赛4 */
        LinkedHashMap<Long, Long> jyFinalRankMap4 = new LinkedHashMap<Long, Long>();
        /** 精英淘汰赛8 */
        LinkedHashMap<Long, Long> jyKnockRankMap8 = new LinkedHashMap<Long, Long>();
        /** 精英淘汰赛16 */
        LinkedHashMap<Long, Long> jyKnockRankMap16 = new LinkedHashMap<Long, Long>();
        /** 精英淘汰赛32 */
        LinkedHashMap<Long, Long> jyKnockRankMap32 = new LinkedHashMap<Long, Long>();
        /** 精英淘汰赛64 */
        LinkedHashMap<Long, Long> jyKnockRankMap64 = new LinkedHashMap<Long, Long>();
        // 精英总决赛冠亚季殿军
        CompetGroup jyFinalCg3 = CrossFightCache.getJyFinalBattleGroups().get(3);
        addKeyToMap(jyFinalCg3, jyFinalRankMap4);
        CompetGroup jyFinalCg4 = CrossFightCache.getJyFinalBattleGroups().get(4);
        addKeyToMap(jyFinalCg4, jyFinalRankMap4);
        // 8
        KnockoutBattleGroup jyA = CrossFightCache.getJyKnockoutBattleGroups().get(1);
        KnockoutBattleGroup jyB = CrossFightCache.getJyKnockoutBattleGroups().get(2);
        KnockoutBattleGroup jyC = CrossFightCache.getJyKnockoutBattleGroups().get(3);
        KnockoutBattleGroup jyD = CrossFightCache.getJyKnockoutBattleGroups().get(4);
        addKnockKeyToMap(jyA, jyKnockRankMap8, 15, 15);
        addKnockKeyToMap(jyB, jyKnockRankMap8, 15, 15);
        addKnockKeyToMap(jyC, jyKnockRankMap8, 15, 15);
        addKnockKeyToMap(jyD, jyKnockRankMap8, 15, 15);
        crossDataManager.sortMapByJifen(jyKnockRankMap8);
        // 16
        jyA = CrossFightCache.getJyKnockoutBattleGroups().get(1);
        jyB = CrossFightCache.getJyKnockoutBattleGroups().get(2);
        jyC = CrossFightCache.getJyKnockoutBattleGroups().get(3);
        jyD = CrossFightCache.getJyKnockoutBattleGroups().get(4);
        addKnockKeyToMap(jyA, jyKnockRankMap16, 13, 14);
        addKnockKeyToMap(jyB, jyKnockRankMap16, 13, 14);
        addKnockKeyToMap(jyC, jyKnockRankMap16, 13, 14);
        addKnockKeyToMap(jyD, jyKnockRankMap16, 13, 14);
        crossDataManager.sortMapByJifen(jyKnockRankMap16);
        // 32
        jyA = CrossFightCache.getJyKnockoutBattleGroups().get(1);
        jyB = CrossFightCache.getJyKnockoutBattleGroups().get(2);
        jyC = CrossFightCache.getJyKnockoutBattleGroups().get(3);
        jyD = CrossFightCache.getJyKnockoutBattleGroups().get(4);
        addKnockKeyToMap(jyA, jyKnockRankMap32, 9, 12);
        addKnockKeyToMap(jyB, jyKnockRankMap32, 9, 12);
        addKnockKeyToMap(jyC, jyKnockRankMap32, 9, 12);
        addKnockKeyToMap(jyD, jyKnockRankMap32, 9, 12);
        crossDataManager.sortMapByJifen(jyKnockRankMap32);
        // 精英淘汰赛前64名
        jyA = CrossFightCache.getJyKnockoutBattleGroups().get(1);
        jyB = CrossFightCache.getJyKnockoutBattleGroups().get(2);
        jyC = CrossFightCache.getJyKnockoutBattleGroups().get(3);
        jyD = CrossFightCache.getJyKnockoutBattleGroups().get(4);
        addKnockKeyToMap(jyA, jyKnockRankMap64, 1, 8);
        addKnockKeyToMap(jyB, jyKnockRankMap64, 1, 8);
        addKnockKeyToMap(jyC, jyKnockRankMap64, 1, 8);
        addKnockKeyToMap(jyD, jyKnockRankMap64, 1, 8);
        crossDataManager.sortMapByJifen(jyKnockRankMap64);
        crossDataManager.totalRank(CrossFightCache.getJyRankMap(), jyFinalRankMap4);
        crossDataManager.totalRank(CrossFightCache.getJyRankMap(), jyKnockRankMap8);
        crossDataManager.totalRank(CrossFightCache.getJyRankMap(), jyKnockRankMap16);
        crossDataManager.totalRank(CrossFightCache.getJyRankMap(), jyKnockRankMap32);
        crossDataManager.totalRank(CrossFightCache.getJyRankMap(), jyKnockRankMap64);
        byte[] bytes = crossFightTable.serJyRankMap(CrossFightCache.getJyRankMap());
        crossFightTable.setJyrank(bytes);
        crossFightTableDao.update(crossFightTable);
    }

    private void addKnockKeyToMap(KnockoutBattleGroup kg, LinkedHashMap<Long, Long> map, int begin, int end) {
        if (kg != null) {
            for (int i = begin; i <= end; i++) {
                addKeyToMap(kg.groupMaps.get(i), map);
            }
        }
    }

    private void addKeyToMap(CompetGroup cg, LinkedHashMap<Long, Long> map) {
        if (cg != null) {
            if (cg.getWin() == 1) {
                if (cg.getC1() != null) {
                    map.put(cg.getC1().getRoleId(), cg.getC1().getRoleId());
                }
                if (cg.getC2() != null) {
                    map.put(cg.getC2().getRoleId(), cg.getC2().getRoleId());
                }
            } else {
                if (cg.getC2() != null) {
                    map.put(cg.getC2().getRoleId(), cg.getC2().getRoleId());
                }
                if (cg.getC1() != null) {
                    map.put(cg.getC1().getRoleId(), cg.getC1().getRoleId());
                }
            }
        }
    }

    /**
     * do跨服战报名
     */
    private void doCrossReg() {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        String crossState = crossFightTable.getCrossState();
        CrossState cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        if (crossState == null) {
            cs = new CrossState();
        } else {
            cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        }
        if (cs.getStage() != CrossConst.STAGE.STAGE_REG) {
            // 直接设置为报名
            cs.setStage(CrossConst.STAGE.STAGE_REG);
            LinkedHashMap<String, String> regions = CrossServiceCache.getFlow(CrossConst.STAGE.STAGE_REG);
            String beginTime = "";
            String endTime = "";
            Iterator<String> its = regions.keySet().iterator();
            while (its.hasNext()) {
                beginTime = its.next();
                endTime = regions.get(beginTime);
            }
            cs.setBeginTime(beginTime);
            cs.setEndTime(endTime);
            cs.setState(CrossConst.begin_state);
            crossFightTable.setCrossState(JSON.toJSONString(cs));
            crossFightTableDao.update(crossFightTable);
        }
        // 时间到了,设置结束
        if (cs.getState() != CrossConst.end_state && cs.getEndTime().equals(TimeHelper.getNowHourAndMins())) {
            cs.setState(CrossConst.end_state);
            crossFightTable.setCrossState(JSON.toJSONString(cs));
            crossFightTableDao.update(crossFightTable);
        }
    }

    /**
     * do资格争夺
     */
    private void doZiGeZhenDuo() {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        String crossState = crossFightTable.getCrossState();
        CrossState cs = null;
        if (crossState == null) {
            cs = new CrossState();
        } else {
            cs = JSON.toJavaObject(JSON.parseObject(crossState), CrossState.class);
        }
        if (cs.getStage() != CrossConst.STAGE.STAGE_ZIGEZHENDUO) {
            cs.setStage(CrossConst.STAGE.STAGE_ZIGEZHENDUO);
            LinkedHashMap<String, String> regions = CrossServiceCache.getFlow(CrossConst.STAGE.STAGE_ZIGEZHENDUO);
            String beginTime = "";
            String endTime = "";
            Iterator<String> its = regions.keySet().iterator();
            while (its.hasNext()) {
                beginTime = its.next();
                endTime = regions.get(beginTime);
            }
            cs.setBeginTime(beginTime);
            cs.setEndTime(endTime);
            cs.setState(CrossConst.begin_state);
            crossFightTable.setCrossState(JSON.toJSONString(cs));
            crossFightTableDao.update(crossFightTable);
        }
        // 时间到了,设置结束
        if (cs.getState() != CrossConst.end_state && cs.getEndTime().equals(TimeHelper.getNowHourAndMins())) {
            cs.setState(CrossConst.end_state);
            crossFightTable.setCrossState(JSON.toJSONString(cs));
            crossFightTableDao.update(crossFightTable);
        }
    }

    /**
     * @param athleteLinkedHashMap
     * @return
     */
    private List<Athlete> sortAthlete(LinkedHashMap<Long, Athlete> athleteLinkedHashMap) {
        LogUtil.error("大于64的玩家使用新的排序 1 count=" + athleteLinkedHashMap.size());
        List<Athlete> dfList = new ArrayList<>();
        List<Athlete> athleteList = new ArrayList<>(athleteLinkedHashMap.values());
        dfList.add(athleteList.get(0));
        dfList.add(athleteList.get(1));
        dfList.add(athleteList.get(2));
        dfList.add(athleteList.get(3));
        dfList.add(athleteList.get(63));
        dfList.add(athleteList.get(62));
        dfList.add(athleteList.get(61));
        dfList.add(athleteList.get(60));
        for (int a = 9; a <= 60; a++) {
            dfList.add(athleteList.get(a - 1));
        }
        dfList.add(athleteList.get(7));
        dfList.add(athleteList.get(6));
        dfList.add(athleteList.get(5));
        dfList.add(athleteList.get(4));
        LogUtil.error("大于64的玩家使用新的排序 2 count=" + dfList.size());
        return dfList;
    }

    private void _generateKnockOutDf16(List<Athlete> athleteList) {
        LogUtil.error("生成淘汰赛玩家 df16 count=" + athleteList.size());
        // 前四名
        int indexDf = 1;
        for (Athlete entry : athleteList) {
            if (indexDf > 64) {
                break;
            }
            // 4个大赛区
            int temp = (indexDf % 4 == 0) ? 4 : (indexDf % 4);
            KnockoutBattleGroup group = CrossFightCache.getDfKnockoutBattleGroups().get(temp);
            if (group == null) {
                group = new KnockoutBattleGroup();
                group.setGroupType(temp);
                CrossFightCache.getDfKnockoutBattleGroups().put(temp, group);
            }
            // pos(1-16)
            int pos = (indexDf + 3) / 4;
            // 获取组别 (1,2 第1组) (3,4 第2组) (5,6 第三组) ...
            int competGroupId = 0;
            if (pos % 2 == 0) {
                competGroupId = pos / 2;
            } else {
                competGroupId = (pos + 1) / 2;
            }
            pos = pos % 2 == 0 ? 2 : 1;
            CompetGroup competGroup = group.groupMaps.get(competGroupId);
            if (competGroup == null) {
                competGroup = new CompetGroup();
                competGroup.setCompetGroupId(competGroupId);
                group.groupMaps.put(competGroupId, competGroup);
            }
            ComptePojo pojo = new ComptePojo(pos, entry.getServerId(), entry.getRoleId(), entry.getNick(), 0, 0, GameContext.gameServerMaps.get(entry.getServerId()).getName(), entry.getFight(), entry.getPortrait(), entry.getPartyName(), entry.getLevel());
            if (pos == 1) {
                competGroup.setC1(pojo);
            } else {
                competGroup.setC2(pojo);
            }
            LogUtil.error("生成【巅峰】淘汰赛组:temp=" + temp + " competGroupId=" + competGroupId + " indexDf=" + indexDf + " pos=" + pos + " name=" + entry.getNick());
            indexDf++;
        }
        // 更改淘汰赛阵型
        CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
        byte[] dfKnockoutBattleGroups = crossFightInfoTable.serDfKnockoutBattleGroups(CrossFightCache.getDfKnockoutBattleGroups());
        crossFightInfoTable.setDfKnockoutBattleGroups(dfKnockoutBattleGroups);
        crossFightInfoTableDao.update(crossFightInfoTable);
    }

    private void _generateKnockOutJY16(List<Athlete> athleteList) {
        LogUtil.error("生成淘汰赛玩家 jy16 count=" + athleteList.size());
        int indexJy = 1;
        for (Athlete entry : athleteList) {
            if (indexJy > 64) {
                break;
            }
            int temp = (indexJy % 4 == 0) ? 4 : (indexJy % 4);
            KnockoutBattleGroup group = CrossFightCache.getJyKnockoutBattleGroups().get(temp);
            if (group == null) {
                group = new KnockoutBattleGroup();
                group.setGroupType(temp);
                CrossFightCache.getJyKnockoutBattleGroups().put(temp, group);
            }
            // pos(1-16)
            int pos = (indexJy + 3) / 4;
            // 获取组别 (1,2 第1组) (3,4 第2组) (5,6 第三组) ...
            int competGroupId = 0;
            if (pos % 2 == 0) {
                competGroupId = pos / 2;
            } else {
                competGroupId = (pos + 1) / 2;
            }
            pos = pos % 2 == 0 ? 2 : 1;
            CompetGroup competGroup = group.groupMaps.get(competGroupId);
            if (competGroup == null) {
                competGroup = new CompetGroup();
                competGroup.setCompetGroupId(competGroupId);
                group.groupMaps.put(competGroupId, competGroup);
            }
            ComptePojo pojo = new ComptePojo(pos, entry.getServerId(), entry.getRoleId(), entry.getNick(), 0, 0, GameContext.gameServerMaps.get(entry.getServerId()).getName(), entry.getFight(), entry.getPortrait(), entry.getPartyName(), entry.getLevel());
            if (pos == 1) {
                competGroup.setC1(pojo);
            } else {
                competGroup.setC2(pojo);
            }
            LogUtil.error("生成【精英】淘汰赛组:temp=" + temp + " competGroupId=" + competGroupId + " indexDf=" + indexJy + " pos=" + pos + " name=" + entry.getNick());
            indexJy++;
        }
        // 更改淘汰赛阵型
        CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
        byte[] serJyKnockoutBattleGroups = crossFightInfoTable.serJyKnockoutBattleGroups(CrossFightCache.getJyKnockoutBattleGroups());
        crossFightInfoTable.setJyKnockoutBattleGroups(serJyKnockoutBattleGroups);
        crossFightInfoTableDao.update(crossFightInfoTable);
    }

    /**
     * 生成淘汰赛的名次
     */
    private void generateKnockOut16() {
        // 先对巅峰和精英的玩家按积分排名
        crossDataManager.sortDfAthlete();
        crossDataManager.sortJyAthlete();
        LogUtil.error("生成淘汰赛玩家 df count=" + CrossFightCache.getDfAthleteMap().size());
        if (CrossFightCache.getDfAthleteMap().size() >= 64) {
            _generateKnockOutDf16(new ArrayList<Athlete>(sortAthlete(CrossFightCache.getDfAthleteMap())));
        } else {
            _generateKnockOutDf16(new ArrayList<Athlete>(CrossFightCache.getDfAthleteMap().values()));
        }
        LogUtil.error("生成淘汰赛玩家 jy count=" + CrossFightCache.getJyAthleteMap().size());
        if (CrossFightCache.getJyAthleteMap().size() >= 64) {
            _generateKnockOutJY16(new ArrayList<Athlete>(sortAthlete(CrossFightCache.getJyAthleteMap())));
        } else {
            _generateKnockOutJY16(new ArrayList<Athlete>(CrossFightCache.getJyAthleteMap().values()));
        }
    }

    /**
     * 发送跨服战系统消息
     */
    private void synCrossBeginMsg(int dayNum) {
        Map<String, ChatInfo> temp = CrossServiceCache.getChat(dayNum);
        if (temp == null) {
            return;
        }
        String beginTime = null;
        String endTime = null;
        String nowTime = TimeHelper.getNowHourAndMins();
        Iterator<ChatInfo> its = temp.values().iterator();
        ChatInfo info = null;
        while (its.hasNext()) {
            info = its.next();
            String tempBeginTime = info.getBeginTime();
            String tempEndTime = info.getEndTime();
            if ((nowTime.compareTo(tempBeginTime) > 0) && (tempEndTime.compareTo(nowTime) > 0)) {
                beginTime = tempBeginTime;
                endTime = tempEndTime;
                break;
            }
        }
        if (beginTime != null) {
            CrossFightTable crossFightTable = crossFightTableDao.get(CrossDataManager.crossId);
            if (!((crossFightTable.getChatDayNum() == dayNum) && (crossFightTable.getChatDayTime().equals(info.getBeginTime())))) {
                if (info.getId() == SysChatId.Cross_Champion_Brocast) {
                    String s1 = "";
                    String s2 = "";
                    Athlete a1 = crossDataManager.getTop1(CrossConst.DF_Group);
                    if (a1 != null) {
                        s1 = a1.getNick();
                    }
                    Athlete a2 = crossDataManager.getTop1(CrossConst.JY_Group);
                    if (a2 != null) {
                        s2 = a2.getNick();
                    }
                    chatService.sendAllGameChat(chatService.createSysChat(info.getId(), s1, s2));
                } else if (info.getId() == SysChatId.Cross_End) {
                    // 推送结束的状态
                    sendCrossPush(0, CrossConst.State.cross_End);
                } else {
                    chatService.sendAllGameChat(chatService.createSysChat(info.getId()));
                }
                crossFightTable.setChatDayNum(dayNum);
                crossFightTable.setChatDayTime(info.getBeginTime());
                crossFightTableDao.update(crossFightTable);
            }
        }
    }

    /**
     * 发送跨服战邮件消息
     */
    private void synCrossBeginMail(int dayNum) {
        Map<String, MailInfo> temp = CrossServiceCache.getMail(dayNum);
        if (temp == null) {
            return;
        }
        String beginTime = null;
        String endTime = null;
        String nowTime = TimeHelper.getNowHourAndMins();
        Iterator<MailInfo> its = temp.values().iterator();
        MailInfo info = null;
        while (its.hasNext()) {
            info = its.next();
            String tempBeginTime = info.getBeginTime();
            String tempEndTime = info.getEndTime();
            if ((nowTime.compareTo(tempBeginTime) > 0) && (tempEndTime.compareTo(nowTime) > 0)) {
                beginTime = tempBeginTime;
                endTime = tempEndTime;
                break;
            }
        }
        // 判断当前时间是否到了发广播的时间
        if (beginTime != null) {
            CrossFightTable crossFightTable = crossFightTableDao.get(CrossDataManager.crossId);
            if (!((crossFightTable.getMailDayNum() == dayNum) && (crossFightTable.getMailDayTime().equals(info.getBeginTime())))) {
                sendGameChat(info.getId(), dayNum, beginTime);
                crossFightTable.setMailDayNum(dayNum);
                crossFightTable.setMailDayTime(info.getBeginTime());
                crossFightTableDao.update(crossFightTable);
            }
        }
    }

    /**
     * 获取跨服战状态信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossFightState(CCGetCrossFightStateRq rq, ClientHandler handler) {
        int d = TimeHelper.getDayOfCrossWar();
        CCGetCrossFightStateRs.Builder builder = CCGetCrossFightStateRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        builder.setBeginTime(GameContext.getAc().getBean(ServerSetting.class).getCrossBeginTime());
        int state = 0;
        if (d >= 1 && d <= 10) {
            state = d;
        }
        builder.setState(state);
        handler.sendMsgToPlayer(CCGetCrossFightStateRs.ext, builder.build());
    }

    /**
     * 跨服战报名
     *
     * @param rq
     * @param handler
     */
    public void crossFightReg(CCCrossFightRegRq rq, ClientHandler handler) {
        int serverId = ChannelUtil.getServerId(handler.getCtx());
        long fight = rq.getFight();
        long rank = rq.getRankId();
        long roleId = rq.getRoleId();
        int groupId = rq.getGroupId();
        String nick = rq.getNick();
        int portrait = rq.getPortrait();
        int level = rq.getLevel();
        CCCrossFightRegRs.Builder builder = CCCrossFightRegRs.newBuilder();
        builder.setRoleId(roleId);
        if (!(groupId == CrossConst.JY_Group || groupId == CrossConst.DF_Group)) {
            handler.sendMsgToPlayer(GameError.PARAM_ERROR, CCCrossFightRegRs.ext, builder.build());
            return;
        }
        // 判断报名时间对不对（第二天报名）
        if (TimeHelper.getDayOfCrossWar() != 2) {
            handler.sendMsgToPlayer(GameError.CROSS_REG_TIME_IS_WRONG, CCCrossFightRegRs.ext, builder.build());
            return;
        }
        // 判断是否报名过
        if (CrossFightCache.getAthlete(roleId) != null) {
            handler.sendMsgToPlayer(GameError.HAVE_REG_CROSS, CCCrossFightRegRs.ext, builder.build());
            return;
        }
        // 巅峰组报名需要条件为战力高于35M，排名在服务器竞技场前4名
        if (rq.getGroupId() == CrossConst.DF_Group) {
            if (fight < CrossConst.DF_Group_Base_fight || rank > CrossConst.DF_Group_Base_Rank) {
                handler.sendMsgToPlayer(GameError.CANNT_CROSSREG_CASE_FIGHTORRANKREASON, CCCrossFightRegRs.ext, builder.build());
                return;
            }
        } else {
            // 精英组报名需要条件为战力高于10M，排名在服务器竞技场前200名
            if (fight < CrossConst.JY_Group_Base_Fight || rank > CrossConst.JY_Group_Base_Rank) {
                handler.sendMsgToPlayer(GameError.CANNT_CROSSREG_CASE_FIGHTORRANKREASON, CCCrossFightRegRs.ext, builder.build());
                return;
            }
        }
        Athlete athlete = new Athlete();
        athlete.setGroupId(groupId);
        athlete.setServerId(serverId);
        athlete.setNick(nick);
        athlete.setRoleId(roleId);
        athlete.setFight(fight);
        athlete.setPortrait(portrait);
        athlete.setLevel(level);
        if (rq.hasPartyName()) {
            athlete.setPartyName(rq.getPartyName());
        }
        CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(roleId);
        if (athleteTable == null) {
            athleteTable = new CrossFightAthleteTable();
            athleteTable.setRoleId(roleId);
            athleteTable.setServerId(serverId);
            athleteTable.setReceiveCrossRankReward(0);
            crossFightAthleteTableDao.insert(athleteTable);
        }
        athleteTable.setAthlete(athlete);
        crossFightAthleteTableDao.update(athleteTable);
        // 报名
        CrossFightCache.addAthlete(athlete);
        initJifenPlayer(roleId, serverId, nick);
        handler.sendMsgToPlayer(CCCrossFightRegRs.ext, builder.build());
    }

    /**
     * 初始化玩家积分数据
     *
     * @param roleId
     * @param serverId
     * @param nick
     */
    private void initJifenPlayer(long roleId, int serverId, String nick) {
        CrossFightPlayerJifenTable crossFightPlayerJifenTable = crossFightPlayerJifenTableDao.get(roleId);
        if (crossFightPlayerJifenTable == null) {
            crossFightPlayerJifenTable = new CrossFightPlayerJifenTable();
            crossFightPlayerJifenTable.setRoleId(roleId);
            crossFightPlayerJifenTable.setServerId(serverId);
            crossFightPlayerJifenTableDao.insert(crossFightPlayerJifenTable);
        }
        JiFenPlayer jiFenPlayer = crossFightPlayerJifenTable.getJiFenPlayer();
        if (jiFenPlayer == null) {
            jiFenPlayer = new JiFenPlayer(serverId, roleId, nick, 0, 0);
        }
        CrossFightCache.addJifenPlayer(jiFenPlayer);
        CommonPb.JiFenPlayer jifenPlayerPb = PbHelper.createJifenPlayerPb(jiFenPlayer, CrossFightCache.getDfKnockoutBattleGroups(), CrossFightCache.getJyKnockoutBattleGroups(), CrossFightCache.getJyFinalBattleGroups(), CrossFightCache.getDfFinalBattleGroups());
        crossFightPlayerJifenTable.setJifenInfo(jifenPlayerPb.toByteArray());
        crossFightPlayerJifenTableDao.update(crossFightPlayerJifenTable);
    }

    /**
     * 获取报名信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossRegInfo(CCGetCrossRegInfoRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCGetCrossRegInfoRs.Builder builder = CCGetCrossRegInfoRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setJyGroupPlayerNum(CrossFightCache.getJyAthleteMap().size());
        builder.setDfGroupPlayerNum(CrossFightCache.getDfAthleteMap().size());
        int myGroup = 0;
        Athlete a = CrossFightCache.getAthlete(roleId);
        if (a != null) {
            myGroup = a.getGroupId();
        }
        builder.setMyGroup(myGroup);
        handler.sendMsgToPlayer(CCGetCrossRegInfoRs.ext, builder.build());
    }

    /**
     * 取消报名
     *
     * @param rq
     * @param handler
     */
    public void cancelCrossReg(CCCancelCrossRegRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        CCCancelCrossRegRs.Builder builder = CCCancelCrossRegRs.newBuilder();
        builder.setRoleId(roleId);
        CrossFightAthleteTable crossFightAthleteTable = crossFightAthleteTableDao.get(roleId);
        if (crossFightAthleteTable != null) {
            Athlete athlete = crossFightAthleteTable.getAthlete();
            CrossFightCache.removeAthlete(athlete);
            crossFightAthleteTableDao.delete(crossFightAthleteTable);
            handler.sendMsgToPlayer(CCCancelCrossRegRs.ext, builder.build());
        } else {
            // 没有报名
            handler.sendMsgToPlayer(GameError.CROSS_NO_REG, CCCancelCrossRegRs.ext, builder.build());
        }
    }

    /**
     * 获取阵型信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossForm(CCGetCrossFormRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCGetCrossFormRs.Builder builder = CCGetCrossFormRs.newBuilder();
        builder.setRoleId(roleId);
        Athlete a = CrossFightCache.getAthlete(roleId);
        if (a == null) {
            handler.sendMsgToPlayer(GameError.CROSS_NO_REG, CCGetCrossFormRs.ext, builder.build());
            return;
        }
        if (a.getForms().size() > 0) {
            Iterator<Form> its = a.getForms().values().iterator();
            while (its.hasNext()) {
                builder.addForm(PbHelper.createFormPb(its.next()));
            }
        }
        handler.sendMsgToPlayer(CCGetCrossFormRs.ext, builder.build());
    }

    /**
     * 设置跨服战阵型
     *
     * @param rq
     * @param handler
     */
    public void setCrossForm(CCSetCrossFormRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCSetCrossFormRs.Builder builder = CCSetCrossFormRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setForm(rq.getForm());
        builder.setFight(rq.getFight());
        // 判断时间是否正确
        if (!TimeHelper.isSetCrossFromTime()) {
            handler.sendMsgToPlayer(GameError.CROSS_NO_SET_FORM_TIME, CCSetCrossFormRs.ext, builder.build());
            return;
        }
        // 是否注册
        Athlete a = CrossFightCache.getAthlete(roleId);
        if (a == null) {
            handler.sendMsgToPlayer(GameError.CROSS_NO_REG, CCSetCrossFormRs.ext, builder.build());
            return;
        }
        // 第三天到第五天15点之前只能设置阵型一
        if (isSetForm1Time() && rq.getForm().getType() != FormType.Cross1) {
            handler.sendMsgToPlayer(GameError.CROSS_JUST_SET_FORM_1, CCSetCrossFormRs.ext, builder.build());
            return;
        }
        CommonPb.Form form = rq.getForm();
        if (!form.hasType()) {
            handler.sendMsgToPlayer(GameError.PARAM_ERROR, CCSetCrossFormRs.ext, builder.build());
            return;
        }
        int formType = form.getType();
        if (!(formType == FormType.Cross1 || formType == FormType.Cross2 | formType == FormType.Cross3)) {
            handler.sendMsgToPlayer(GameError.PARAM_ERROR, CCSetCrossFormRs.ext, builder.build());
            return;
        }
        Map<Integer, Hero> heros = new HashMap<Integer, Hero>();
        for (Hero pbHero : rq.getHeroList()) {
            heros.put(pbHero.getHeroId(), pbHero);
        }
        Map<Integer, CommonPb.AwakenHero> awakenHeros = new HashMap<Integer, CommonPb.AwakenHero>();
        for (CommonPb.AwakenHero pbHero : rq.getAwakenHeroList()) {
            awakenHeros.put(pbHero.getKeyId(), pbHero);
        }
        Map<Integer, Integer> tanks = new HashMap<Integer, Integer>();
        for (Tank pbTank : rq.getTankList()) {
            tanks.put(pbTank.getTankId(), pbTank.getCount());
        }
        Form destForm = PbHelper.createForm(form);
        StaticHero staticHero = null;
        // 使用觉醒将领
        if (destForm.getAwakenHero() != null) {
            CommonPb.AwakenHero awakenHero = awakenHeros.get(destForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.getState() == HeroConst.HERO_AWAKEN_STATE_USED) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            staticHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());
            if (staticHero == null) {
                handler.sendMsgToPlayer(GameError.NO_CONFIG, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            if (staticHero.getType() != 2) {
                handler.sendMsgToPlayer(GameError.NOT_HERO, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            Set<Integer> tempHeros = new HashSet<Integer>();
            for (int j = FormType.Cross1; j <= FormType.Cross3; j++) {
                if (formType != j) {
                    Form f = a.forms.get(j);
                    if (f != null) {
                        if (f.getAwakenHero() != null) {
                            tempHeros.add(f.getAwakenHero().getKeyId());
                        }
                    }
                }
            }
            if (tempHeros.contains(awakenHero.getKeyId())) {
                handler.sendMsgToPlayer(GameError.NO_HERO, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            destForm.setAwakenHero(new AwakenHero(awakenHero));
        } else if (destForm.getCommander() > 0) {
            Hero hero = heros.get(destForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendMsgToPlayer(GameError.NO_HERO, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            staticHero = staticHeroDataMgr.getStaticHero(hero.getHeroId());
            if (staticHero == null) {
                handler.sendMsgToPlayer(GameError.NO_CONFIG, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            if (staticHero.getType() != 2) {
                handler.sendMsgToPlayer(GameError.NOT_HERO, CCSetCrossFormRs.ext, builder.build());
                return;
            }
            Map<Integer, Integer> tempHeros = new HashMap<Integer, Integer>();
            for (int j = FormType.Cross1; j <= FormType.Cross3; j++) {
                if (formType != j) {
                    Form f = a.forms.get(j);
                    if (f != null && f.getAwakenHero() == null) {
                        putTempHeros(tempHeros, f.getCommander());
                    }
                }
            }
            putTempHeros(tempHeros, destForm.getCommander());
            // 英雄个数判断
            int useHeroCount = tempHeros.get(destForm.getCommander());
            hero = heros.get(destForm.getCommander());
            if (hero == null || hero.getCount() < useHeroCount) {
                handler.sendMsgToPlayer(GameError.NO_HERO, CCSetCrossFormRs.ext, builder.build());
                return;
            }
        }
        // // 计算坦克够不够
        // if (!checkCrossTank(destForm, a.forms, rq.getMaxTankNum(), tanks)) {
        // handler.sendMsgToPlayer(GameError.TANK_COUNT, CCSetCrossFormRs.ext,
        // builder.build());
        // return;
        // }
        a.forms.put(destForm.getType(), destForm);
        builder.setFight(rq.getFight());
        builder.setForm(PbHelper.createFormPb(destForm));
        handler.sendMsgToPlayer(CCSetCrossFormRs.ext, builder.build());
        // 获取装备
        getEquip(a, rq.getEquipList());
        // 获取配件
        getPart(a, rq.getPartList());
        // 获取科技
        getScience(a, rq.getScienceList());
        // 获取技能
        getSkill(a, rq.getSkillList());
        // 获取编制
        getStaffingId(a, rq.getStaffingId());
        // 获取effect
        getEffect(a, rq.getEffectList());
        // 获取能晶
        getEnergyStone(a, rq.getInlayList());
        // 获取军工科技
        getMilitaryScienceGrid(a, rq.getMilitaryScienceGridList());
        getMilitaryScience(a, rq.getMilitaryScienceList());
        // 获取勋章
        getMedal(a, rq.getMedalList());
        // 获取勋章展厅
        getMedalBounds(a, rq.getMedalBounsList());
        // 觉醒将领
        getAwakenHeros(a, rq.getAwakenHeroList());
        // 军备信息
        getLordEquip(a, rq.getLeqList());
        // 军衔等级
        a.militaryRank = rq.getMilitaryRank();
        // 秘密武器
        getSecretWeapon(a, rq.getSecretWeaponList());
        // 攻击特效
        getAttackEffects(a, rq.getAtkEftList());
        // 作战实验室
        getGraduateInfo(a, rq.getGraduateInfoList());
        // 军团科技列表
        getPartyScience(a, rq.getPartyScienceList());
        //能源核心
        getEnergyCore(a, rq.getEnergyCore());
        CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(a.getRoleId());
        athleteTable.setAthlete(a);
        crossFightAthleteTableDao.update(athleteTable);
    }

    /**
     * 能源核心
     *
     * @param a
     * @param energyCore
     */
    private void getEnergyCore(Athlete a, ThreeInt energyCore) {
        PEnergyCore core = new PEnergyCore(1, 1, 0);
        if (energyCore != null) {
            core.setLevel(energyCore.getV1());
            core.setSection(energyCore.getV2());
            core.setState(energyCore.getV3());
            a.setpEnergyCore(core);
        }
    }

    /**
     * 加载军团科技列表
     *
     * @param a
     * @param partyScienceList
     */
    private void getPartyScience(Athlete a, List<Science> partyScienceList) {
        a.partyScienceMap.clear();
        for (Science s : partyScienceList) {
            PartyScience partyScience = new PartyScience(s.getScienceId(), s.getScienceLv());
            partyScience.setSchedule(s.getSchedule());
            a.partyScienceMap.put(partyScience.getScienceId(), partyScience);
        }
    }

    /**
     * 加载作战实验室科技树
     *
     * @param a
     * @param pbs
     */
    private void getGraduateInfo(Athlete a, List<GraduateInfoPb> pbs) {
        a.graduateInfo.clear();
        for (GraduateInfoPb pb : pbs) {
            Map<Integer, Integer> skillMap = a.graduateInfo.get(pb.getType());
            if (skillMap == null) a.graduateInfo.put(pb.getType(), skillMap = new HashMap<>());
            for (TwoInt ti : pb.getGraduateInfoList()) {
                skillMap.put(ti.getV1(), ti.getV2());
            }
        }
    }

    /**
     * 加载攻击特效
     *
     * @param a
     * @param effectPbs
     */
    private void getAttackEffects(Athlete a, List<AttackEffectPb> effectPbs) {
        a.atkEffects.clear();
        if (effectPbs != null && !effectPbs.isEmpty()) {
            for (AttackEffectPb pb : effectPbs) {
                a.atkEffects.put(pb.getType(), new AttackEffect(pb));
            }
        }
    }

    /**
     * 加载秘密武器
     *
     * @param a
     * @param pbWeapons
     */
    private void getSecretWeapon(Athlete a, List<SecretWeapon> pbWeapons) {
        a.secretWeaponMap.clear();
        if (pbWeapons != null && !pbWeapons.isEmpty()) {
            for (SecretWeapon pbw : pbWeapons) {
                com.game.domain.p.SecretWeapon secretWeapon = new com.game.domain.p.SecretWeapon(pbw);
                a.secretWeaponMap.put(pbw.getId(), secretWeapon);
            }
        }
    }

    private void getLordEquip(Athlete a, List<CommonPb.LordEquip> lordEquips) {
        a.lordEquips.clear();
        if (lordEquips != null && !lordEquips.isEmpty()) {
            for (CommonPb.LordEquip pbLeq : lordEquips) {
                LordEquip leq = new LordEquip(pbLeq.getKeyId(), pbLeq.getEquipId(), pbLeq.getPos());
                a.lordEquips.put(leq.getPos(), leq);
                leq.setLordEquipSaveType(pbLeq.getLordEquipSaveType());
                // 获取军备技能
                List<List<Integer>> skillList = leq.getLordEquipSkillList();
                List<TwoInt> twoIntList = pbLeq.getSkillLvList();
                for (TwoInt twoInt : twoIntList) {
                    List<Integer> skill = new ArrayList<Integer>(2);
                    skill.add(twoInt.getV1());
                    skill.add(twoInt.getV2());
                    skillList.add(skill);
                }
                List<List<Integer>> lordEquipSkillSecondList = leq.getLordEquipSkillSecondList();
                List<TwoInt> twoIntSecondList = pbLeq.getSkillLvSecondList();
                for (TwoInt twoInt : twoIntSecondList) {
                    List<Integer> skill = new ArrayList<Integer>(2);
                    skill.add(twoInt.getV1());
                    skill.add(twoInt.getV2());
                    lordEquipSkillSecondList.add(skill);
                }
            }
        }
    }

    private void getAwakenHeros(Athlete a, List<CommonPb.AwakenHero> awakenHeroList) {
        if (awakenHeroList != null) {
            a.awakenHeros.clear();
            for (CommonPb.AwakenHero mpb : awakenHeroList) {
                a.awakenHeros.put(mpb.getKeyId(), new AwakenHero(mpb));
            }
        }
    }

    private void getMedalBounds(Athlete a, List<MedalBouns> medalBounsList) {
        if (medalBounsList != null) {
            a.medalBounss.clear();
            for (MedalBouns mpb : medalBounsList) {
                com.game.domain.p.MedalBouns m = PbHelper.createMedalBouns(mpb);
                HashMap<Integer, com.game.domain.p.MedalBouns> map = a.medalBounss.get(m.getState());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.MedalBouns>();
                    a.medalBounss.put(m.getState(), map);
                }
                map.put(m.getMedalId(), m);
            }
        }
    }

    private void getMedal(Athlete a, List<Medal> medalList) {
        if (medalList != null) {
            a.medals.clear();
            for (Medal mpb : medalList) {
                com.game.domain.p.Medal m = PbHelper.createMedal(mpb);
                HashMap<Integer, com.game.domain.p.Medal> map = a.medals.get(m.getPos());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.Medal>();
                    a.medals.put(m.getPos(), map);
                }
                map.put(m.getKeyId(), m);
            }
        }
    }

    private void getMilitaryScience(Athlete a, List<MilitaryScience> militaryScienceList) {
        if (militaryScienceList != null) {
            a.militarySciences.clear();
            for (MilitaryScience pbms : militaryScienceList) {
                com.game.domain.p.MilitaryScience m = PbHelper.createMilitaryScienece(pbms);
                a.militarySciences.put(m.getMilitaryScienceId(), m);
            }
        }
    }

    private void getMilitaryScienceGrid(Athlete a, List<MilitaryScienceGrid> militaryScienceGridList) {
        if (militaryScienceGridList != null) {
            a.militaryScienceGrids.clear();
            for (MilitaryScienceGrid pbmg : militaryScienceGridList) {
                com.game.domain.p.MilitaryScienceGrid m = PbHelper.createMilitaryScieneceGrid(pbmg);
                HashMap<Integer, com.game.domain.p.MilitaryScienceGrid> map = a.militaryScienceGrids.get(m.getTankId());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.MilitaryScienceGrid>();
                    a.militaryScienceGrids.put(m.getTankId(), map);
                }
                map.put(m.getPos(), m);
            }
        }
    }

    private void getEnergyStone(Athlete a, List<EnergyStoneInlay> inlayList) {
        if (inlayList != null) {
            a.energyInlay.clear();
            for (EnergyStoneInlay pbe : inlayList) {
                com.game.domain.p.EnergyStoneInlay e = PbHelper.createEnergyStoneInlay(pbe);
                Map<Integer, com.game.domain.p.EnergyStoneInlay> map = a.energyInlay.get(e.getPos());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.EnergyStoneInlay>();
                    a.energyInlay.put(e.getPos(), map);
                }
                map.put(e.getHole(), e);
            }
        }
    }

    private void getEffect(Athlete a, List<Effect> effectList) {
        if (effectList != null) {
            a.effects.clear();
            for (Effect pbe : effectList) {
                com.game.domain.p.Effect e = PbHelper.createEffect(pbe);
                a.effects.put(e.getEffectId(), e);
            }
        }
    }

    private void getStaffingId(Athlete a, int staffingId) {
        a.StaffingId = staffingId;
    }

    private void getSkill(Athlete a, List<Skill> skillList) {
        if (skillList != null) {
            a.skills.clear();
            for (Skill skill : skillList) {
                a.skills.put(skill.getId(), skill.getLv());
            }
        }
    }

    // 获取科技
    private void getScience(Athlete a, List<Science> scienceList) {
        if (scienceList != null) {
            a.sciences.clear();
            for (Science pbs : scienceList) {
                com.game.domain.p.Science s = PbHelper.createScience(pbs);
                a.sciences.put(s.getScienceId(), s);
            }
        }
    }

    // 获取配件
    private void getPart(Athlete a, List<Part> partList) {
        if (partList != null) {
            a.parts.clear();
            for (Part e : partList) {
                boolean locked = false;
                if (e.hasLocked()) {
                    locked = e.getLocked();
                }
                Map<Integer, Integer[]> mapAttr = new HashMap<>();
                for (PartSmeltAttr attr : e.getAttrList()) {
                    Integer[] i = new Integer[]{
                            attr.getVal(), attr.getNewVal()
                    };
                    mapAttr.put(attr.getId(), i);
                }
                com.game.domain.p.Part part = new com.game.domain.p.Part(e.getKeyId(), e.getPartId(), e.getUpLv(), e.getRefitLv(), e.getPos(), locked, e.getSmeltLv(), e.getSmeltExp(), mapAttr, e.getSaved());
                HashMap<Integer, com.game.domain.p.Part> map = a.parts.get(part.getPos());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.Part>();
                    a.parts.put(part.getPos(), map);
                }
                map.put(part.getKeyId(), part);
            }
        }
    }

    // 获取装备
    private void getEquip(Athlete a, List<Equip> equipList) {
        if (equipList != null) {
            a.equips.clear();
            for (Equip pbEquip : equipList) {
                com.game.domain.p.Equip equip = PbHelper.createEquip(pbEquip);
                HashMap<Integer, com.game.domain.p.Equip> map = a.equips.get(equip.getPos());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.Equip>();
                    a.equips.put(equip.getPos(), map);
                }
                map.put(equip.getKeyId(), equip);
            }
        }
    }

    private void putTempHeros(Map<Integer, Integer> heros, int heroId) {
        Integer count = heros.get(heroId);
        if (count == null) {
            heros.put(heroId, 1);
        } else {
            heros.put(heroId, count + 1);
        }
    }

    private boolean checkCrossTank(Form form, Map<Integer, Form> forms, int tankCount, Map<Integer, Integer> haveTanks) {
        int totalTank = 0;
        int count = 0;
        Map<Integer, Integer> formTanks = new HashMap<Integer, Integer>();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                count = addTankMapCount(formTanks, p[i], c[i], tankCount);
                totalTank += count;
                c[i] = count;
            }
        }
        if (totalTank == 0) {
            return true;
        }
        for (int j = FormType.Cross1; j <= FormType.Cross3; j++) {
            if (form.getType() != j) {
                Form f = forms.get(j);
                if (f != null) {
                    int[] p2 = f.p;
                    int[] c2 = f.c;
                    for (int i = 0; i < p.length; i++) {
                        if (p2[i] > 0) {
                            addTank(p2[i], c2[i], formTanks);
                        }
                    }
                }
            }
        }
        for (Entry<Integer, Integer> entry : formTanks.entrySet()) {
            Integer num = haveTanks.get(entry.getKey());
            if (num == null || num < entry.getValue()) {
                return false;
            }
        }
        return true;
    }

    private void addTank(int tankId, int tankCount, Map<Integer, Integer> formTanks) {
        if (formTanks.containsKey(tankId)) {
            formTanks.put(tankId, formTanks.get(tankId) + tankCount);
        } else {
            formTanks.put(tankId, tankCount);
        }
    }

    private int addTankMapCount(Map<Integer, Integer> formTanks, int tankId, int count, int maxCount) {
        if (count < 0) {
            return 0;
        }
        if (count > maxCount) {
            count = maxCount;
        }
        if (formTanks.containsKey(tankId)) {
            formTanks.put(tankId, formTanks.get(tankId) + count);
        } else {
            formTanks.put(tankId, count);
        }
        return count;
    }

    /**
     * 第三天20点之前只能设置阵型一
     *
     * @return
     */
    private boolean isSetForm1Time() {
        int day = TimeHelper.getDayOfCrossWar();
        if ((day == 3) && TimeHelper.isInTime(0, 0, 0, 20, 0, 0)) {
            return true;
        }
        return false;
    }

    /**
     * 总决赛
     *
     * @author wanyi
     */
    public class CrossFightFinal {
        private int days;
        private String beginTime;

        public CrossFightFinal(int days, String beginTime) {
            super();
            this.days = days;
            this.beginTime = beginTime;
        }

        List<CompetGroup> dfCp = new ArrayList<CompetGroup>();
        List<CompetGroup> jyCp = new ArrayList<CompetGroup>();

        public boolean round() {
            try {
                int time = TimeHelper.getCurrentSecond();
                Iterator<CompetGroup> its = jyCp.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.JY_Group);
                    generyFinalNextGroup(fightPair, CrossConst.JY_Group);
                }
                its = dfCp.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.DF_Group);
                    generyFinalNextGroup(fightPair, CrossConst.DF_Group);
                }
                // 积分排序
                crossDataManager.sortJiFen();
                LogUtil.error("开始更新赛战斗记录");
                // 更改淘汰赛阵型
                CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
                byte[] serJYFinalBattleGroups = crossFightInfoTable.serJYFinalBattleGroups(CrossFightCache.getJyFinalBattleGroups());
                crossFightInfoTable.setJyFinalBattleGroups(serJYFinalBattleGroups);
                byte[] serDFFinalBattleGroups = crossFightInfoTable.serDFFinalBattleGroups(CrossFightCache.getDfFinalBattleGroups());
                crossFightInfoTable.setDfFinalBattleGroups(serDFFinalBattleGroups);
                crossFightInfoTableDao.update(crossFightInfoTable);
                LogUtil.error("更新赛战斗记录 完成");
            } catch (Exception e) {
                LogUtil.error("", e);
            }
            LogUtil.info(days + "_" + beginTime + "总决赛战斗结束");
            return true;
        }

        /**
         * 生成下一组
         *
         * @param fightPair
         * @param whichGroup
         */
        private void generyFinalNextGroup(CompetGroup fightPair, int whichGroup) {
            Map<Integer, CompetGroup> map;
            if (whichGroup == CrossConst.DF_Group) {
                map = CrossFightCache.getDfFinalBattleGroups();
            } else {
                map = CrossFightCache.getJyFinalBattleGroups();
            }
            // 生成下一组
            if (days == CrossConst.STAGE.STATE_FINAL && "12:00:00".equals(beginTime)) {
                // 1,2 组生成3,4组
                if (fightPair.getWin() != -1) {
                    // 获取胜利者
                    ComptePojo winCp = null;
                    ComptePojo failCp = null;
                    if (fightPair.getWin() == 1) {
                        winCp = new ComptePojo(fightPair.getC1().getPos(), fightPair.getC1().getServerId(), fightPair.getC1().getRoleId(), fightPair.getC1().getNick(), 0, 0, fightPair.getC1().getServerName(), fightPair.getC1().getFight(), fightPair.getC1().getPortrait(), fightPair.getC1().getPartyName(), fightPair.getC1().getLevel());
                        if (fightPair.getC2() != null) {
                            failCp = new ComptePojo(fightPair.getC2().getPos(), fightPair.getC2().getServerId(), fightPair.getC2().getRoleId(), fightPair.getC2().getNick(), 0, 0, fightPair.getC2().getServerName(), fightPair.getC2().getFight(), fightPair.getC2().getPortrait(), fightPair.getC2().getPartyName(), fightPair.getC2().getLevel());
                        }
                    } else if (fightPair.getWin() == 0) {
                        winCp = new ComptePojo(fightPair.getC2().getPos(), fightPair.getC2().getServerId(), fightPair.getC2().getRoleId(), fightPair.getC2().getNick(), 0, 0, fightPair.getC2().getServerName(), fightPair.getC2().getFight(), fightPair.getC2().getPortrait(), fightPair.getC2().getPartyName(), fightPair.getC2().getLevel());
                        if (fightPair.getC1() != null) {
                            failCp = new ComptePojo(fightPair.getC1().getPos(), fightPair.getC1().getServerId(), fightPair.getC1().getRoleId(), fightPair.getC1().getNick(), 0, 0, fightPair.getC1().getServerName(), fightPair.getC1().getFight(), fightPair.getC1().getPortrait(), fightPair.getC1().getPartyName(), fightPair.getC1().getLevel());
                        }
                    }
                    // 1组胜利的放入到3组1 ,失败的放到4组1
                    // 2组胜利的放入到3组2 ,失败的放到4组2
                    CompetGroup cg3 = getCompetGroup(map, 3);
                    CompetGroup cg4 = getCompetGroup(map, 4);
                    if (fightPair.getCompetGroupId() == 1) {
                        winCp.setPos(1);
                        cg3.setC1(winCp);
                        LogUtil.error("生成" + isDForJyGroup(whichGroup) + "决赛组 第三组左边");
                        if (failCp != null) {
                            failCp.setPos(1);
                            cg4.setC1(failCp);
                            LogUtil.error("生成" + isDForJyGroup(whichGroup) + "决赛组 第四组左边");
                        }
                    } else if (fightPair.getCompetGroupId() == 2) {
                        winCp.setPos(2);
                        cg3.setC2(winCp);
                        LogUtil.error("生成" + isDForJyGroup(whichGroup) + "决赛组 第三组右边");
                        if (failCp != null) {
                            failCp.setPos(2);
                            cg4.setC2(failCp);
                            LogUtil.error("生成" + isDForJyGroup(whichGroup) + "决赛组 第四组右边");
                        }
                    }
                    // 给胜利的发邮件,进入冠军争夺
                    // 给失败的发邮件,进入季军争夺
                    String winNick = null;
                    String failNick = null;
                    if (winCp != null) {
                        winNick = winCp.getNick();
                    }
                    if (failCp != null) {
                        failNick = failCp.getNick();
                    }
                    if (winCp != null) {
                        sendGameMail(winCp.getServerId(), MailType.MOLD_FIRST_FIGHT, CrossConst.MailType.Person, winCp.getRoleId(), failNick);
                    }
                    if (failCp != null) {
                        sendGameMail(failCp.getServerId(), MailType.MOLD_THRID_FIGHT, CrossConst.MailType.Person, failCp.getRoleId(), winNick);
                    }
                }
            } else if (days == CrossConst.STAGE.STATE_FINAL && "20:00:00".equals(beginTime)) {
                // 3，4组设置完成
                if (fightPair.getWin() == -1) {
                    // 战力大的设置为赢
                    ComptePojo winCp = getFightOver(fightPair.getC1(), fightPair.getC2());
                    if (winCp == fightPair.getC1()) {
                        fightPair.setWin(1);
                    } else {
                        fightPair.setWin(0);
                    }
                }
                ComptePojo winCp = null;
                ComptePojo failCp = null;
                if (fightPair.getWin() == 1) {
                    winCp = fightPair.getC1();
                    if (fightPair.getC2() != null) {
                        failCp = fightPair.getC2();
                    }
                } else {
                    winCp = fightPair.getC2();
                    if (fightPair.getC1() != null) {
                        failCp = fightPair.getC1();
                    }
                }
                // 给胜利的发邮件,获得了冠军/季军
                // 给失败的发邮件,获得了亚军,失败
                String winNick = null;
                String failNick = null;
                if (winCp != null) {
                    winNick = winCp.getNick();
                }
                if (failCp != null) {
                    failNick = failCp.getNick();
                }
                // 判断是第3组还是第4组
                if (fightPair.getCompetGroupId() == 3) {
                    // 胜者冠军
                    if (winCp != null) {
                        Athlete a = CrossFightCache.getAthlete(winCp.getRoleId());
                        sendGameMail(winCp.getServerId(), MailType.MOLD_GET_FIRST, CrossConst.MailType.Person, winCp.getRoleId(), failNick, isDForJyGroup(a.getGroupId()));
                        LogUtil.error("给冠军发邮件:" + isDForJyGroup(whichGroup) + ":" + a.getRoleId() + "|" + a.getNick() + "|" + a.getServerId() + "|" + GameContext.gameServerMaps.get(a.getServerId()).getName());
                    }
                    // 败者亚军
                    if (failCp != null) {
                        Athlete a = CrossFightCache.getAthlete(failCp.getRoleId());
                        sendGameMail(failCp.getServerId(), MailType.MOLD_GET_SECEND, CrossConst.MailType.Person, failCp.getRoleId(), winNick, isDForJyGroup(a.getGroupId()));
                        LogUtil.error("给亚军发邮件:" + isDForJyGroup(whichGroup) + ":" + a.getRoleId() + "|" + a.getNick() + "|" + a.getServerId() + "|" + GameContext.gameServerMaps.get(a.getServerId()).getName());
                    }
                } else {
                    // 胜者季军
                    if (winCp != null) {
                        Athlete a = CrossFightCache.getAthlete(winCp.getRoleId());
                        sendGameMail(winCp.getServerId(), MailType.MOLD_GET_THRID, CrossConst.MailType.Person, winCp.getRoleId(), failNick, isDForJyGroup(a.getGroupId()));
                        LogUtil.error("给季军发邮件:" + isDForJyGroup(whichGroup) + ":" + a.getRoleId() + "|" + a.getNick() + "|" + a.getServerId() + "|" + GameContext.gameServerMaps.get(a.getServerId()).getName());
                    }
                    // 败者啥都没有
                    if (failCp != null) {
                        sendGameMail(failCp.getServerId(), MailType.MOLD_FINAL_OUT, CrossConst.MailType.Person, failCp.getRoleId(), winNick);
                    }
                }
                LogUtil.info(isDForJyGroup(whichGroup) + "总决赛比赛完成");
            }
        }

        private CompetGroup getCompetGroup(Map<Integer, CompetGroup> map, int group) {
            CompetGroup cg = map.get(group);
            if (cg == null) {
                cg = new CompetGroup();
                cg.setCompetGroupId(group);
                map.put(group, cg);
            }
            return cg;
        }

        public void init() {
            LogUtil.info(days + "_" + beginTime + "总决赛战斗开始");
            if ("12:00:00".equals(beginTime)) {
                // 初始化1,2组
                CompetGroup cg = CrossFightCache.getJyFinalBattleGroups().get(1);
                if (cg != null) {
                    jyCp.add(cg);
                }
                cg = CrossFightCache.getJyFinalBattleGroups().get(2);
                if (cg != null) {
                    jyCp.add(cg);
                }
                cg = CrossFightCache.getDfFinalBattleGroups().get(1);
                if (cg != null) {
                    dfCp.add(cg);
                }
                cg = CrossFightCache.getDfFinalBattleGroups().get(2);
                if (cg != null) {
                    dfCp.add(cg);
                }
            } else if ("20:00:00".equals(beginTime)) {
                // 初始化3,4组
                CompetGroup cg = CrossFightCache.getJyFinalBattleGroups().get(3);
                if (cg != null) {
                    jyCp.add(cg);
                }
                cg = CrossFightCache.getJyFinalBattleGroups().get(4);
                if (cg != null) {
                    jyCp.add(cg);
                }
                cg = CrossFightCache.getDfFinalBattleGroups().get(3);
                if (cg != null) {
                    dfCp.add(cg);
                }
                cg = CrossFightCache.getDfFinalBattleGroups().get(4);
                if (cg != null) {
                    dfCp.add(cg);
                }
            }
        }

        public int getDays() {
            return days;
        }

        public void setDays(int days) {
            this.days = days;
        }

        public String getBeginTime() {
            return beginTime;
        }

        public void setBeginTime(String beginTime) {
            this.beginTime = beginTime;
        }
    }

    /**
     * 淘汰赛战斗
     *
     * @author wanyi
     */
    public class CrossFightKnock {
        private int days;
        private String beginTime;

        public CrossFightKnock(int days, String beginTime) {
            super();
            this.days = days;
            this.beginTime = beginTime;
        }

        List<CompetGroup> jyA = new ArrayList<CompetGroup>();
        List<CompetGroup> jyB = new ArrayList<CompetGroup>();
        List<CompetGroup> jyC = new ArrayList<CompetGroup>();
        List<CompetGroup> jyD = new ArrayList<CompetGroup>();
        List<CompetGroup> dfA = new ArrayList<CompetGroup>();
        List<CompetGroup> dfB = new ArrayList<CompetGroup>();
        List<CompetGroup> dfC = new ArrayList<CompetGroup>();
        List<CompetGroup> dfD = new ArrayList<CompetGroup>();
        KnockoutBattleGroup kbgJyA = CrossFightCache.getJyKnockoutBattleGroups().get(1);
        KnockoutBattleGroup kbgJyB = CrossFightCache.getJyKnockoutBattleGroups().get(2);
        KnockoutBattleGroup kbgJyC = CrossFightCache.getJyKnockoutBattleGroups().get(3);
        KnockoutBattleGroup kbgJyD = CrossFightCache.getJyKnockoutBattleGroups().get(4);
        KnockoutBattleGroup kbgDfA = CrossFightCache.getDfKnockoutBattleGroups().get(1);
        KnockoutBattleGroup kbgDfB = CrossFightCache.getDfKnockoutBattleGroups().get(2);
        KnockoutBattleGroup kbgDfC = CrossFightCache.getDfKnockoutBattleGroups().get(3);
        KnockoutBattleGroup kbgDfD = CrossFightCache.getDfKnockoutBattleGroups().get(4);

        public boolean round() {
            try {
                LogUtil.error(days + "_" + beginTime + "淘汰赛战斗开始");
                int time = TimeHelper.getCurrentSecond();
                Iterator<CompetGroup> its = jyA.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.JY_Group);
                    generyKnockNextGroup(fightPair, CrossConst.A_Group_Type, CrossConst.JY_Group);
                }
                its = jyB.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.JY_Group);
                    generyKnockNextGroup(fightPair, CrossConst.B_Group_Type, CrossConst.JY_Group);
                }
                its = jyC.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.JY_Group);
                    generyKnockNextGroup(fightPair, CrossConst.C_Group_Type, CrossConst.JY_Group);
                }
                its = jyD.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.JY_Group);
                    generyKnockNextGroup(fightPair, CrossConst.D_Group_Type, CrossConst.JY_Group);
                }
                its = dfA.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.DF_Group);
                    generyKnockNextGroup(fightPair, CrossConst.A_Group_Type, CrossConst.DF_Group);
                }
                its = dfB.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.DF_Group);
                    generyKnockNextGroup(fightPair, CrossConst.B_Group_Type, CrossConst.DF_Group);
                }
                its = dfC.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.DF_Group);
                    generyKnockNextGroup(fightPair, CrossConst.C_Group_Type, CrossConst.DF_Group);
                }
                its = dfD.iterator();
                while (its.hasNext()) {
                    CompetGroup fightPair = its.next();
                    fightRound(time, fightPair, CrossConst.DF_Group);
                    generyKnockNextGroup(fightPair, CrossConst.D_Group_Type, CrossConst.DF_Group);
                }
                // 积分排序
                crossDataManager.sortJiFen();
                // 更改淘汰赛阵型
                CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
                byte[] serJyKnockoutBattleGroups = crossFightInfoTable.serJyKnockoutBattleGroups(CrossFightCache.getJyKnockoutBattleGroups());
                crossFightInfoTable.setJyKnockoutBattleGroups(serJyKnockoutBattleGroups);
                byte[] dfKnockoutBattleGroups = crossFightInfoTable.serDfKnockoutBattleGroups(CrossFightCache.getDfKnockoutBattleGroups());
                crossFightInfoTable.setDfKnockoutBattleGroups(dfKnockoutBattleGroups);
                crossFightInfoTableDao.update(crossFightInfoTable);
                LogUtil.error(days + "_" + beginTime + "淘汰赛战斗结束");
            } catch (Exception e) {
                LogUtil.error("", e);
            }
            return true;
        }

        /**
         * 生成下一组
         *
         * @param fightPair
         * @param group_Type ABCD
         * @param whichGroup 精英/巅峰
         */
        private void generyKnockNextGroup(CompetGroup fightPair, int group_Type, int whichGroup) {
            LogUtil.error("淘汰赛生成下一组");
            KnockoutBattleGroup group;
            if (whichGroup == CrossConst.DF_Group) {
                group = CrossFightCache.getDfKnockoutBattleGroups().get(group_Type);
            } else {
                group = CrossFightCache.getJyKnockoutBattleGroups().get(group_Type);
            }
            // 生成下一组
            if (days == CrossConst.STAGE.STAGE_KNOCK1 && "12:00:00".equals(beginTime)) {
                // 1-8组生成9-12组
                if (fightPair.getWin() != -1) {
                    // 获取胜利者
                    ComptePojo cp = null;
                    if (fightPair.getWin() == 1) {
                        cp = fightPair.getC1();
                    } else if (fightPair.getWin() == 0) {
                        cp = fightPair.getC2();
                    } else {
                        // 平局战力高的晋级
                        cp = getFightOver(fightPair.getC1(), fightPair.getC2());
                    }
                    // 获取分配的组
                    int competGroupId = fightPair.getCompetGroupId() % 2 == 0 ? (fightPair.getCompetGroupId() / 2 + 8) : ((fightPair.getCompetGroupId() + 1) / 2 + 8);
                    CompetGroup cg = group.groupMaps.get(competGroupId);
                    if (cg == null) {
                        cg = new CompetGroup();
                        cg.setCompetGroupId(competGroupId);
                        group.groupMaps.put(competGroupId, cg);
                    }
                    ComptePojo pojo = new ComptePojo(cp.getPos(), cp.getServerId(), cp.getRoleId(), cp.getNick(), 0, 0, cp.getServerName(), cp.getFight(), cp.getPortrait(), cp.getPartyName(), cp.getLevel());
                    if (fightPair.getCompetGroupId() % 2 == 0) {
                        cg.setC2(pojo);
                    } else {
                        cg.setC1(pojo);
                    }
                    LogUtil.error("生成" + isDForJyGroup(whichGroup) + "淘汰组：" + isGroupTypeName(group_Type) + competGroupId + (fightPair.getCompetGroupId() % 2 == 0 ? "右边" : "左边"));
                }
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "15:30:00".equals(beginTime)) {
                // 9-12组 生成 13,14 组
                if (fightPair.getWin() != -1) {
                    // 获取胜利者
                    ComptePojo cp = null;
                    if (fightPair.getWin() == 1) {
                        cp = fightPair.getC1();
                    } else if (fightPair.getWin() == 0) {
                        cp = fightPair.getC2();
                    } else {
                        // 平局战力高的晋级
                        cp = getFightOver(fightPair.getC1(), fightPair.getC2());
                    }
                    // 获取分配的组
                    int competGroupId = fightPair.getCompetGroupId() % 2 == 0 ? ((fightPair.getCompetGroupId() - 8) / 2 + 12) : ((fightPair.getCompetGroupId() + 1 - 8) / 2 + 12);
                    CompetGroup cg = group.groupMaps.get(competGroupId);
                    if (cg == null) {
                        cg = new CompetGroup();
                        cg.setCompetGroupId(competGroupId);
                        group.groupMaps.put(competGroupId, cg);
                    }
                    ComptePojo pojo = new ComptePojo(cp.getPos(), cp.getServerId(), cp.getRoleId(), cp.getNick(), 0, 0, cp.getServerName(), cp.getFight(), cp.getPortrait(), cp.getPartyName(), cp.getLevel());
                    if (fightPair.getCompetGroupId() % 2 == 0) {
                        cg.setC2(pojo);
                    } else {
                        cg.setC1(pojo);
                    }
                    LogUtil.error("生成" + isDForJyGroup(whichGroup) + "淘汰组：" + isGroupTypeName(group_Type) + competGroupId + (fightPair.getCompetGroupId() % 2 == 0 ? "右边" : "左边"));
                }
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "19:00:00".equals(beginTime)) {
                // 13,14组 生成 15 组
                if (fightPair.getWin() != -1) {
                    // 获取胜利者
                    ComptePojo cp = null;
                    if (fightPair.getWin() == 1) {
                        cp = fightPair.getC1();
                    } else if (fightPair.getWin() == 0) {
                        cp = fightPair.getC2();
                    } else {
                        // 平局战力高的晋级
                        cp = getFightOver(fightPair.getC1(), fightPair.getC2());
                    }
                    // 获取分配的组
                    int competGroupId = 15;
                    CompetGroup cg = group.groupMaps.get(competGroupId);
                    if (cg == null) {
                        cg = new CompetGroup();
                        cg.setCompetGroupId(competGroupId);
                        group.groupMaps.put(competGroupId, cg);
                    }
                    ComptePojo pojo = new ComptePojo(cp.getPos(), cp.getServerId(), cp.getRoleId(), cp.getNick(), 0, 0, cp.getServerName(), cp.getFight(), cp.getPortrait(), cp.getPartyName(), cp.getLevel());
                    if (fightPair.getCompetGroupId() % 2 == 0) {
                        cg.setC2(pojo);
                    } else {
                        cg.setC1(pojo);
                    }
                    LogUtil.error("生成" + isDForJyGroup(whichGroup) + "淘汰组：" + isGroupTypeName(group_Type) + competGroupId + (fightPair.getCompetGroupId() % 2 == 0 ? "右边" : "左边"));
                }
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "22:30:00".equals(beginTime)) {
                // 生成总决赛四强,1,2组
                Map<Integer, CompetGroup> map;
                if (whichGroup == CrossConst.DF_Group) {
                    map = CrossFightCache.getDfFinalBattleGroups();
                } else {
                    map = CrossFightCache.getJyFinalBattleGroups();
                }
                // 获取组别
                // AB:1组 CD:2组
                // AD:1组 BC:2组
                if (fightPair.getWin() != -1) {
                    // 获取胜利者
                    ComptePojo cp = null;
                    if (fightPair.getWin() == 1) {
                        cp = fightPair.getC1();
                    } else if (fightPair.getWin() == 0) {
                        cp = fightPair.getC2();
                    } else {
                        // 平局战力高的晋级
                        cp = getFightOver(fightPair.getC1(), fightPair.getC2());
                    }
                    // 获取分配的组
                    int competGroupId = 1;
                    if (group_Type == 1 || group_Type == 4) {
                        competGroupId = 1;
                    } else {
                        competGroupId = 2;
                    }
                    // int competGroupId = (group_Type % 2 == 0 ? (group_Type /
                    // 2) : (group_Type + 1) / 2);
                    // if (group_Type % 2 == 0) {
                    // cg.setC2(pojo);
                    // pojo.setPos(2);
                    // } else {
                    // cg.setC1(pojo);
                    // pojo.setPos(1);
                    // }
                    CompetGroup cg = map.get(competGroupId);
                    if (cg == null) {
                        cg = new CompetGroup();
                        cg.setCompetGroupId(competGroupId);
                        map.put(competGroupId, cg);
                    }
                    ComptePojo pojo = new ComptePojo(cp.getPos(), cp.getServerId(), cp.getRoleId(), cp.getNick(), 0, 0, cp.getServerName(), cp.getFight(), cp.getPortrait(), cp.getPartyName(), cp.getLevel());
                    if (group_Type == 1 || group_Type == 2) {
                        cg.setC1(pojo);
                        pojo.setPos(1);
                    } else {
                        cg.setC2(pojo);
                        pojo.setPos(2);
                    }
                    LogUtil.error("生成" + isDForJyGroup(whichGroup) + "总决赛：" + competGroupId + ((group_Type == 1 || group_Type == 2) ? "右边" : "左边"));
                    LogUtil.error("生成决战");
                    CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
                    byte[] serJYFinalBattleGroups = crossFightInfoTable.serJYFinalBattleGroups(CrossFightCache.getJyFinalBattleGroups());
                    crossFightInfoTable.setJyFinalBattleGroups(serJYFinalBattleGroups);
                    byte[] serDFFinalBattleGroups = crossFightInfoTable.serDFFinalBattleGroups(CrossFightCache.getDfFinalBattleGroups());
                    crossFightInfoTable.setDfFinalBattleGroups(serDFFinalBattleGroups);
                    crossFightInfoTableDao.update(crossFightInfoTable);
                    LogUtil.error("保存决战记录");
                }
            }
            // 给失败的发邮件
            ComptePojo winCp = null;
            ComptePojo failCp = null;
            if (fightPair.getWin() == 1) {
                winCp = fightPair.getC1();
                if (fightPair.getC2() != null) {
                    failCp = fightPair.getC2();
                }
            } else {
                winCp = fightPair.getC2();
                if (fightPair.getC1() != null) {
                    failCp = fightPair.getC1();
                }
            }
            String winNick = null;
            if (winCp != null) {
                winNick = winCp.getNick();
            }
            if (failCp != null) {
                sendGameMail(failCp.getServerId(), MailType.MOLD_KNOCK_OUT, CrossConst.MailType.Person, failCp.getRoleId(), winNick);
            }
        }

        public void init() {
            LogUtil.info(days + "_" + beginTime + "淘汰赛战斗");
            if (days == CrossConst.STAGE.STAGE_KNOCK1 && "12:00:00".equals(beginTime)) {
                // 1-8组
                initCompetGroup(kbgJyA, jyA, 1, 8);
                initCompetGroup(kbgJyB, jyB, 1, 8);
                initCompetGroup(kbgJyC, jyC, 1, 8);
                initCompetGroup(kbgJyD, jyD, 1, 8);
                initCompetGroup(kbgDfA, dfA, 1, 8);
                initCompetGroup(kbgDfB, dfB, 1, 8);
                initCompetGroup(kbgDfC, dfC, 1, 8);
                initCompetGroup(kbgDfD, dfD, 1, 8);
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "15:30:00".equals(beginTime)) {
                // 9-12组
                initCompetGroup(kbgJyA, jyA, 9, 12);
                initCompetGroup(kbgJyB, jyB, 9, 12);
                initCompetGroup(kbgJyC, jyC, 9, 12);
                initCompetGroup(kbgJyD, jyD, 9, 12);
                initCompetGroup(kbgDfA, dfA, 9, 12);
                initCompetGroup(kbgDfB, dfB, 9, 12);
                initCompetGroup(kbgDfC, dfC, 9, 12);
                initCompetGroup(kbgDfD, dfD, 9, 12);
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "19:00:00".equals(beginTime)) {
                // 13,14组
                initCompetGroup(kbgJyA, jyA, 13, 14);
                initCompetGroup(kbgJyB, jyB, 13, 14);
                initCompetGroup(kbgJyC, jyC, 13, 14);
                initCompetGroup(kbgJyD, jyD, 13, 14);
                initCompetGroup(kbgDfA, dfA, 13, 14);
                initCompetGroup(kbgDfB, dfB, 13, 14);
                initCompetGroup(kbgDfC, dfC, 13, 14);
                initCompetGroup(kbgDfD, dfD, 13, 14);
            } else if (days == CrossConst.STAGE.STAGE_KNOCK1 && "22:30:00".equals(beginTime)) {
                // 15组
                initCompetGroup(kbgJyA, jyA, 15, 15);
                initCompetGroup(kbgJyB, jyB, 15, 15);
                initCompetGroup(kbgJyC, jyC, 15, 15);
                initCompetGroup(kbgJyD, jyD, 15, 15);
                initCompetGroup(kbgDfA, dfA, 15, 15);
                initCompetGroup(kbgDfB, dfB, 15, 15);
                initCompetGroup(kbgDfC, dfC, 15, 15);
                initCompetGroup(kbgDfD, dfD, 15, 15);
            }
        }

        private void initCompetGroup(KnockoutBattleGroup kbg, List<CompetGroup> cg, int begin, int end) {
            if (kbg != null) {
                for (int i = begin; i <= end; i++) {
                    CompetGroup c = kbg.groupMaps.get(i);
                    if (c != null) {
                        cg.add(c);
                    }
                }
            }
        }

        public int getDays() {
            return days;
        }

        public void setDays(int days) {
            this.days = days;
        }

        public String getBeginTime() {
            return beginTime;
        }

        public void setBeginTime(String beginTime) {
            this.beginTime = beginTime;
        }
    }

    private String isGroupTypeName(int group_Type) {
        String str = "A";
        if (group_Type == CrossConst.B_Group_Type) {
            str = "B";
        } else if (group_Type == CrossConst.C_Group_Type) {
            str = "C";
        } else if (group_Type == CrossConst.D_Group_Type) {
            str = "D";
        }
        return str;
    }

    /**
     * 获取战力高的
     *
     * @param c1
     * @param c2
     * @return
     */
    public ComptePojo getFightOver(ComptePojo c1, ComptePojo c2) {
        if (c1 != null && c2 == null) {
            return c1;
        }
        if (c1 == null && c2 != null) {
            return c2;
        }
        if (c1 == null && c2 == null) {
            return null;
        }
        if (c1.getFight() >= c2.getFight()) {
            return c1;
        } else {
            return c2;
        }
    }

    private String isDForJyGroup(int whichGroup) {
        String str = CrossConst.DF_DESC;
        if (whichGroup == CrossConst.JY_Group) {
            str = CrossConst.JY_DESC;
        }
        return str;
    }

    private CompteRound fightKnock(CompetGroup fightPair, int time, int num, int formType) {
        try {
            int result = 0;
            int reportKey = generateReportKey();
            int detail = 1;
            int whoFirst = 0;
            int attackDesNum = 0;
            int defenceDesNum = 0;
            CrossRptAtk atk = null;
            CrossRecord myRecord = null;
            String attackName = null;
            String attackServerName = null;
            String defencerName = null;
            String defencerServerName = null;
            Athlete attackerAth = null;
            Athlete defenceKeyAth = null;
            // 判断攻击和防守有一个为空(两个都为空的情况不会出现在此方法中)
            if (fightPair.getC1() == null || fightPair.getC2() == null) {
                if (fightPair.getC1() == null) {
                    // 进攻方不存在,防守方赢
                    result = 0;
                    detail = 6;
                    defenceKeyAth = CrossFightCache.getAthlete(fightPair.getC2().getRoleId());
                    defencerName = defenceKeyAth.getNick();
                    defencerServerName = GameContext.gameServerMaps.get(defenceKeyAth.getServerId()).getName();
                    int firstValue = 0;
                    if (defenceKeyAth.forms.get(formType) != null) {
                        Fighter defencer = fightService.createCrossFighter(defenceKeyAth, defenceKeyAth.forms.get(formType), 3);
                        firstValue = defencer.firstValue;
                    }
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, null, createCrossRptMan(defenceKeyAth, firstValue), null);
                } else {
                    // 防守方不存在,进攻方赢
                    result = 1;
                    detail = 4;
                    attackerAth = CrossFightCache.getAthlete(fightPair.getC1().getRoleId());
                    attackName = attackerAth.getNick();
                    attackServerName = GameContext.gameServerMaps.get(attackerAth.getServerId()).getName();
                    int firstValue = 0;
                    if (attackerAth.forms.get(formType) != null) {
                        Fighter attacker = fightService.createCrossFighter(attackerAth, attackerAth.forms.get(formType), 3);
                        firstValue = attacker.firstValue;
                    }
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(attackerAth, firstValue), null, null);
                }
            } else {
                // 攻击和防守都在
                attackerAth = CrossFightCache.getAthlete(fightPair.getC1().getRoleId());
                defenceKeyAth = CrossFightCache.getAthlete(fightPair.getC2().getRoleId());
                attackName = attackerAth.getNick();
                attackServerName = GameContext.gameServerMaps.get(attackerAth.getServerId()).getName();
                defencerName = defenceKeyAth.getNick();
                defencerServerName = GameContext.gameServerMaps.get(defenceKeyAth.getServerId()).getName();
                // 若双方都没有设置阵型,都都失败
                if (attackerAth.forms.get(formType) == null && defenceKeyAth.forms.get(formType) == null) {
                    result = -1;
                    detail = 5;
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(attackerAth, 0), createCrossRptMan(defenceKeyAth, 0), null);
                } else if (attackerAth.forms.get(formType) == null) {
                    // 进攻方未设置,防守方赢
                    result = 0;
                    detail = 2;
                    Fighter defencer = fightService.createCrossFighter(defenceKeyAth, defenceKeyAth.forms.get(formType), 3);
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(attackerAth, 0), createCrossRptMan(defenceKeyAth, defencer.firstValue), null);
                } else if (defenceKeyAth.forms.get(formType) == null) {
                    // 防守方未设置，进攻方赢
                    result = 1;
                    detail = 3;
                    Fighter attacker = fightService.createCrossFighter(attackerAth, attackerAth.forms.get(formType), 3);
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(attackerAth, attacker.firstValue), createCrossRptMan(defenceKeyAth, 0), null);
                } else {
                    // 都设置阵型了,战斗
                    Fighter attacker = fightService.createCrossFighter(attackerAth, attackerAth.forms.get(formType), 3);
                    Fighter defencer = fightService.createCrossFighter(defenceKeyAth, defenceKeyAth.forms.get(formType), 3);
                    defencerName = defenceKeyAth.getNick();
                    defencerServerName = GameContext.gameServerMaps.get(defenceKeyAth.getServerId()).getName();
                    FightLogic fightLogic = new FightLogic(attacker, defencer, num, fightPair, true);
                    fightLogic.packForm(attackerAth.forms.get(formType), defenceKeyAth.forms.get(formType));
                    fightLogic.fight();
                    Record record = fightLogic.generateRecord();
                    result = fightLogic.getWinState() == 1 ? 1 : 0;
                    detail = 1;
                    whoFirst = fightLogic.first == attacker ? 1 : 2;
                    attackDesNum = caluAttackDesNum(attacker);
                    defenceDesNum = caluAttackDesNum(defencer);
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, fightLogic.attackerIsFirst(), createCrossRptMan(attackerAth, attacker.firstValue), createCrossRptMan(defenceKeyAth, defencer.firstValue), record);
                }
            }
            myRecord = PbHelper.createCrossRecrod(reportKey, attackServerName, attackName, 100, defencerServerName, defencerName, 100, result, time, detail);
            if (attackerAth != null) {
                attackerAth.addReportKey(reportKey);
                crossCacheUpdateService.updateAthlete(attackerAth);
            }
            if (defenceKeyAth != null) {
                defenceKeyAth.addReportKey(reportKey);
                crossCacheUpdateService.updateAthlete(defenceKeyAth);
            }
            reportKey(reportKey, attackerAth, defenceKeyAth);
            crossDataManager.addCrossRecord(myRecord);
            crossDataManager.addCrossRptAtk(atk);
            CompteRound cr = new CompteRound();
            cr.setReportKey(reportKey);
            cr.setRoundNum(num);
            cr.setWin(result);
            cr.setDetail(detail);
            cr.setWhoFist(whoFirst);
            cr.setAttackDestroyNum(attackDesNum);
            cr.setDenfenceDestroyNum(defenceDesNum);
            return cr;
        } catch (Exception e) {
            LogUtil.error("", e);
        }
        return null;
    }

    private void reportKey(int reportKey, Athlete attackerAth, Athlete defenceKeyAth) {
        String str = " 攻击方 " + attackerAth.getNick() + " roleId=" + attackerAth.getRoleId();
        String str2 = "";
        if (defenceKeyAth != null) {
            str2 = " 防守方 " + defenceKeyAth.getNick() + " roleId=" + defenceKeyAth.getRoleId();
        }
        LogUtil.error("添加战报key " + reportKey + str + str2);
    }

    private int caluAttackDesNum(Fighter f) {
        int ret = 0;
        for (Force force : f.forces) {
            if (force != null) {
                ret += force.killed;
            }
        }
        return ret;
    }

    /**
     * @param time
     * @param fightPair
     * @param group
     */
    private void fightRound(int time, CompetGroup fightPair, int group) {
        try {
            CompteRound frist = fightKnock(fightPair, time, 1, FormType.Cross1);
            fightPair.map.put(frist.getRoundNum(), frist);
            CompteRound secend = fightKnock(fightPair, time, 2, FormType.Cross2);
            fightPair.map.put(secend.getRoundNum(), secend);
            CompteRound third = fightKnock(fightPair, time, 3, FormType.Cross3);
            fightPair.map.put(third.getRoundNum(), third);
            int win1 = 0;
            int win2 = 0;
            if (frist.getWin() == 1) {
                win1 += 1;
            } else if (frist.getWin() == 0) {
                win2 += 1;
            }
            if (secend.getWin() == 1) {
                win1 += 1;
            } else if (secend.getWin() == 0) {
                win2 += 1;
            }
            if (third.getWin() == 1) {
                win1 += 1;
            } else if (third.getWin() == 0) {
                win2 += 1;
            }
            Athlete c1 = null;
            Athlete c2 = null;
            JiFenPlayer jp1 = null;
            JiFenPlayer jp2 = null;
            if (win1 > win2) {
                fightPair.setWin(1);
                c1 = CrossFightCache.getAthlete(fightPair.getC1().getRoleId());
                jp1 = CrossFightCache.getJifenPlayerMap().get(fightPair.getC1().getRoleId());
                if (group == CrossConst.JY_Group) {
                    jp1.setJifen(jp1.getJifen() + CrossConst.Knock_JY_WIN_JIFEN);
                } else {
                    jp1.setJifen(jp1.getJifen() + CrossConst.Knock_DF_WIN_JIFEN);
                }
                c1.setWinNum(c1.getWinNum() + 1);
                if (fightPair.getC2() != null) {
                    c2 = CrossFightCache.getAthlete(fightPair.getC2().getRoleId());
                    c2.setFailNum(c2.getFailNum() + 1);
                }
            } else if (win1 < win2) {
                fightPair.setWin(0);
                c2 = CrossFightCache.getAthlete(fightPair.getC2().getRoleId());
                jp2 = CrossFightCache.getJifenPlayerMap().get(fightPair.getC2().getRoleId());
                if (group == CrossConst.JY_Group) {
                    jp2.setJifen(jp2.getJifen() + CrossConst.Knock_JY_WIN_JIFEN);
                } else {
                    jp2.setJifen(jp2.getJifen() + CrossConst.Knock_DF_WIN_JIFEN);
                }
                c2.setWinNum(c2.getWinNum() + 1);
                if (fightPair.getC1() != null) {
                    c1 = CrossFightCache.getAthlete(fightPair.getC1().getRoleId());
                    c1.setFailNum(c1.getFailNum() + 1);
                }
            } else {
                // 相同则选择战力高的获胜
                c1 = CrossFightCache.getAthlete(fightPair.getC1().getRoleId());
                jp1 = CrossFightCache.getJifenPlayerMap().get(fightPair.getC1().getRoleId());
                c2 = CrossFightCache.getAthlete(fightPair.getC2().getRoleId());
                jp2 = CrossFightCache.getJifenPlayerMap().get(fightPair.getC2().getRoleId());
                if (c1.getFight() >= c2.getFight()) {
                    fightPair.setWin(1);
                    if (group == CrossConst.JY_Group) {
                        jp1.setJifen(jp1.getJifen() + CrossConst.Knock_JY_WIN_JIFEN);
                    } else {
                        jp1.setJifen(jp1.getJifen() + CrossConst.Knock_DF_WIN_JIFEN);
                    }
                    c1.setWinNum(c1.getWinNum() + 1);
                    c2.setFailNum(c2.getFailNum() + 1);
                } else {
                    fightPair.setWin(0);
                    if (group == CrossConst.JY_Group) {
                        jp2.setJifen(jp2.getJifen() + CrossConst.Knock_JY_WIN_JIFEN);
                    } else {
                        jp2.setJifen(jp2.getJifen() + CrossConst.Knock_DF_WIN_JIFEN);
                    }
                    c2.setWinNum(c2.getWinNum() + 1);
                    c1.setFailNum(c1.getFailNum() + 1);
                }
            }
            if (jp1 != null) {
                crossCacheUpdateService.updateJiFenPlayer(jp1);
            }
            if (jp2 != null) {
                crossCacheUpdateService.updateJiFenPlayer(jp2);
            }
            if (c1 != null) {
                crossCacheUpdateService.updateAthlete(c1);
            }
            if (c2 != null) {
                crossCacheUpdateService.updateAthlete(c2);
            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

    /**
     * 积分赛战斗
     */
    public class CrossFightJiFen {
        private int days;
        private String beginTime;
        private int state = 0;
        List<CrossFightPair> dfPairs = new ArrayList<CrossFightPair>();
        List<CrossFightPair> jyPairs = new ArrayList<CrossFightPair>();
        private Athlete dfNull = null; // 轮空的玩家
        private Athlete jyNull = null;

        public CrossFightJiFen(int days, String beginTime) {
            super();
            this.days = days;
            this.beginTime = beginTime;
        }

        private boolean check(List<Athlete> athletes) {
            for (int i = 0; i < athletes.size() / 2; i++) {
                Athlete athlete = athletes.get(2 * i);
                Athlete athlete1 = athletes.get(2 * i + 1);
                if (athlete.getHistoryRoleId().contains(athlete1.getRoleId())) {
                    return false;
                }
            }
            return true;
        }

        private void shuffle(List<Athlete> athletes, int i) {
            LogUtil.error("积分赛打乱玩家顺序 次数=" + i);
            Collections.shuffle(athletes);
            if (i >= 20) {
                return;
            }
            if (check(athletes)) {
                return;
            } else {
                i++;
                shuffle(athletes, i);
            }
        }

        public void init() {
            LogUtil.error(days + "_" + beginTime + "积分战斗开始");
            dfNull = null;
            jyNull = null;
            List<Athlete> jyAthletes = new ArrayList<Athlete>();
            List<Athlete> dfAthletes = new ArrayList<Athlete>();
            dfAthletes.addAll(CrossFightCache.getDfAthleteMap().values());
            jyAthletes.addAll(CrossFightCache.getJyAthleteMap().values());
            shuffle(jyAthletes, 0);
            shuffle(dfAthletes, 0);
            LogUtil.error(days + "_" + beginTime + "积分战斗开始2");
            int size = jyAthletes.size();
            for (int i = 0; i < size / 2; i++) {
                CrossFightPair fightPair = new CrossFightPair();
                Athlete athlete = jyAthletes.get(2 * i);
                Athlete athlete1 = jyAthletes.get(2 * i + 1);
                fightPair.attacker = athlete;
                fightPair.defencer = athlete1;
                athlete.getHistoryRoleId().add(athlete1.getRoleId());
                athlete1.getHistoryRoleId().add(athlete.getRoleId());
                jyPairs.add(fightPair);
            }
            if (size % 2 != 0) {
                jyNull = jyAthletes.get(size - 1);
                LogUtil.error("本次积分赛精英组轮空的玩家为:" + jyNull.getNick());
            }
            size = dfAthletes.size();
            for (int i = 0; i < size / 2; i++) {
                CrossFightPair fightPair = new CrossFightPair();
                Athlete athlete = dfAthletes.get(2 * i);
                Athlete athlete1 = dfAthletes.get(2 * i + 1);
                fightPair.attacker = athlete;
                fightPair.defencer = athlete1;
                athlete.getHistoryRoleId().add(athlete1.getRoleId());
                athlete1.getHistoryRoleId().add(athlete.getRoleId());
                dfPairs.add(fightPair);
            }
            if (size % 2 != 0) {
                dfNull = dfAthletes.get(size - 1);
                LogUtil.error("本次积分赛巅峰组轮空的玩家为:" + dfNull.getNick());
            }
            LogUtil.error(days + "_" + beginTime + "积分战斗开始3");
        }

        public boolean round() {
            LogUtil.info("积分赛...");
            int jyNum = 1;
            int dfNum = 1;
            int time = TimeHelper.getCurrentSecond();
            Iterator<CrossFightPair> jyIts = jyPairs.iterator();
            while (jyIts.hasNext() && (jyNum % 10 != 0)) {
                LogUtil.info("精英赛战斗----------------------" + jyNum);
                jyNum++;
                CrossFightPair fightPair = jyIts.next();
                fightJiFen(fightPair, FormType.Cross1, time);
                jyIts.remove();
            }
            Iterator<CrossFightPair> dfIts = dfPairs.iterator();
            while (dfIts.hasNext() && (dfNum % 10 != 0)) {
                LogUtil.info("巅峰赛战斗----------------------" + dfNum);
                dfNum++;
                CrossFightPair fightPair = dfIts.next();
                fightJiFen(fightPair, FormType.Cross1, time);
                dfIts.remove();
            }
            // 积分排序
            crossDataManager.sortJiFen();
            // 打完了
            if ((!jyIts.hasNext()) && (!dfIts.hasNext())) {
                // 轮空的玩家加胜利场次和积分
                if (dfNull != null) {
                    dfNull.setWinNum(dfNull.getWinNum() + 1);
                    JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(dfNull.getRoleId());
                    if (dfNull.getGroupId() == CrossConst.JY_Group) {
                        jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                    } else {
                        jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                    }
                    crossCacheUpdateService.updateAthlete(dfNull);
                    crossCacheUpdateService.updateJiFenPlayer(jp);
                }
                if (jyNull != null) {
                    jyNull.setWinNum(jyNull.getWinNum() + 1);
                    JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(jyNull.getRoleId());
                    if (jyNull.getGroupId() == CrossConst.JY_Group) {
                        jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                    } else {
                        jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                    }
                    crossCacheUpdateService.updateAthlete(jyNull);
                    crossCacheUpdateService.updateJiFenPlayer(jp);
                }
                crossDataManager.sortJiFen();
                LogUtil.error(days + "_" + beginTime + "积分战斗结束");
                return true;
            }
            return false;
        }

        /**
         * 战斗
         *
         * @param fightPair
         * @param formType
         * @return
         */
        private void fightJiFen(CrossFightPair fightPair, int formType, int time) {
            int result = 0;
            int reportKey = generateReportKey();
            int detail = 1;
            String attackName = fightPair.attacker.getNick();
            String attackServerName = GameContext.gameServerMaps.get(fightPair.attacker.getServerId()).getName();
            String defencerName = null;
            String defencerServerName = null;
            CrossRptAtk atk = null;
            CrossRecord myRecord = null;
            if (fightPair.attacker.forms.get(formType) == null) {
                // 若防守方不在,进攻方赢
                if (fightPair.defencer == null) {
                    result = 1;
                    detail = 4;
                    Fighter attacker = fightService.createCrossFighter(fightPair.attacker, fightPair.attacker.forms.get(formType), 3);
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(fightPair.attacker, attacker.firstValue), null, null);
                    JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.attacker.getRoleId());
                    if (fightPair.attacker.getGroupId() == CrossConst.JY_Group) {
                        jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                    } else {
                        jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                    }
                    // 设置胜负
                    fightPair.attacker.setWinNum(fightPair.attacker.getWinNum() + 1);
                } else {
                    // 若防守方在,则判断防守方有没有设置阵型;若没有,则都失败,若有,则防守方赢
                    defencerName = fightPair.defencer.getNick();
                    defencerServerName = GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName();
                    if (fightPair.defencer.forms.get(formType) == null) {
                        result = -1;
                        detail = 5;
                        atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(fightPair.attacker, 0), createCrossRptMan(fightPair.defencer, 0), null);
                    } else {
                        result = 0;
                        detail = 2;
                        Fighter defencer = fightService.createCrossFighter(fightPair.defencer, fightPair.defencer.forms.get(formType), 3);
                        atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(fightPair.attacker, 0), createCrossRptMan(fightPair.defencer, defencer.firstValue), null);
                        JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.defencer.getRoleId());
                        if (fightPair.defencer.getGroupId() == CrossConst.JY_Group) {
                            jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                        } else {
                            jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                        }
                        // 设置胜负
                        fightPair.defencer.setWinNum(fightPair.defencer.getWinNum() + 1);
                    }
                }
            } else {
                Fighter attacker = fightService.createCrossFighter(fightPair.attacker, fightPair.attacker.forms.get(formType), 3);
                if (fightPair.defencer == null) {
                    // 若防守方不存在,则进攻方胜利
                    result = 1;
                    detail = 4;
                    atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(fightPair.attacker, attacker.firstValue), null, null);
                    JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.attacker.getRoleId());
                    // 设置积分
                    if (fightPair.attacker.getGroupId() == CrossConst.JY_Group) {
                        jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                    } else {
                        jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                    }
                    // 设置胜负
                    fightPair.attacker.setWinNum(fightPair.attacker.getWinNum() + 1);
                } else {
                    // 若防守方未设置阵型,则进攻方胜利
                    defencerName = fightPair.defencer.getNick();
                    defencerServerName = GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName();
                    if (fightPair.defencer.forms.get(formType) == null) {
                        result = 1;
                        detail = 3;
                        atk = PbHelper.createCrossRptAtk(reportKey, result, detail, true, createCrossRptMan(fightPair.attacker, attacker.firstValue), createCrossRptMan(fightPair.defencer, 0), null);
                        JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.attacker.getRoleId());
                        // 设置积分
                        if (fightPair.attacker.getGroupId() == CrossConst.JY_Group) {
                            jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                        } else {
                            jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                        }
                        // 设置胜负
                        fightPair.attacker.setWinNum(fightPair.attacker.getWinNum() + 1);
                    } else {
                        Fighter defencer = fightService.createCrossFighter(fightPair.defencer, fightPair.defencer.forms.get(formType), 3);
                        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
                        fightLogic.packForm(fightPair.attacker.forms.get(formType), fightPair.defencer.forms.get(formType));
                        fightLogic.fight();
                        Record record = fightLogic.generateRecord();
                        result = fightLogic.getWinState() == 1 ? 1 : 0;
                        detail = 1;
                        atk = PbHelper.createCrossRptAtk(reportKey, result, detail, fightLogic.attackerIsFirst(), createCrossRptMan(fightPair.attacker, attacker.firstValue), createCrossRptMan(fightPair.defencer, defencer.firstValue), record);
                        // 设置积分
                        if (result == 1) {
                            JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.attacker.getRoleId());
                            if (fightPair.attacker.getGroupId() == CrossConst.JY_Group) {
                                jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                            } else {
                                jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                            }
                            fightPair.attacker.setWinNum(fightPair.attacker.getWinNum() + 1);
                            fightPair.defencer.setFailNum(fightPair.defencer.getFailNum() + 1);
                        } else {
                            JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.defencer.getRoleId());
                            if (fightPair.defencer.getGroupId() == CrossConst.JY_Group) {
                                jp.setJifen(jp.getJifen() + CrossConst.Jifen_JY_WIN_JIFEN);
                            } else {
                                jp.setJifen(jp.getJifen() + CrossConst.JiFen_DF_WIN_JIFEN);
                            }
                            fightPair.defencer.setWinNum(fightPair.defencer.getWinNum() + 1);
                            fightPair.attacker.setFailNum(fightPair.attacker.getFailNum() + 1);
                        }
                    }
                }
            }
            myRecord = PbHelper.createCrossRecrod(reportKey, attackServerName, attackName, 100, defencerServerName, defencerName, 100, result, time, detail);
            fightPair.attacker.addReportKey(reportKey);
            if (fightPair.defencer != null) {
                fightPair.defencer.addReportKey(reportKey);
            }
            reportKey(reportKey, fightPair.attacker, fightPair.defencer);
            crossDataManager.addCrossRecord(myRecord);
            crossDataManager.addCrossRptAtk(atk);
            // 更新玩家数据
            if (fightPair.attacker != null) {
                crossCacheUpdateService.updateAthlete(fightPair.attacker);
                JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.attacker.getRoleId());
                crossCacheUpdateService.updateJiFenPlayer(jp);
            }
            if (fightPair.defencer != null) {
                crossCacheUpdateService.updateAthlete(fightPair.defencer);
                JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(fightPair.defencer.getRoleId());
                crossCacheUpdateService.updateJiFenPlayer(jp);
            }
        }

        public int getDays() {
            return days;
        }

        public void setDays(int days) {
            this.days = days;
        }

        public String getBeginTime() {
            return beginTime;
        }

        public void setBeginTime(String beginTime) {
            this.beginTime = beginTime;
        }

        public int getState() {
            return state;
        }

        public void setState(int state) {
            this.state = state;
        }
    }

    private int generateReportKey() {
        CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
        int ret = crossFightTable.getReportKey() + 1;
        crossFightTable.setReportKey(ret);
        crossFightTableDao.update(crossFightTable);
        return ret;
    }

    private CrossRptMan createCrossRptMan(Athlete player, int firstValue) {
        CrossRptMan.Builder builder = CrossRptMan.newBuilder();
        builder.setName(player.getNick());
        builder.setServerName(GameContext.gameServerMaps.get(player.getServerId()).getName());
        builder.setFirstValue(firstValue);
        return builder.build();
    }

    /**
     * 获取个人战况
     *
     * @param rq
     * @param handler
     */
    public void getCrossPersonSituation(CCGetCrossPersonSituationRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int page = rq.getPage();
        int serverId = handler.getServerId();
        CCGetCrossPersonSituationRs.Builder builder = CCGetCrossPersonSituationRs.newBuilder();
        builder.setRoleId(roleId);
        Athlete at = CrossFightCache.getAthlete(roleId);
        if (at == null) {
            handler.sendMsgToPlayer(GameError.CROSS_NO_REG, CCGetCrossPersonSituationRs.ext, builder.build());
            return;
        }
        Map<Integer, CrossRecord> rankMap = CrossFightCache.getCrossRecords();
        List<Integer> list = at.getMyReportKeys();
        int size = list.size();
        int begin = page * 20;
        int end = begin + 20;
        for (int i = begin; i < end && i < size; i++) {
            Integer key = list.get(i);
            if (rankMap.containsKey(key)) {
                builder.addCrossRecord(rankMap.get(key));
            }
        }
        handler.sendMsgToPlayer(CCGetCrossPersonSituationRs.ext, builder.build());
    }

    /**
     * 获取积分排名
     *
     * @param rq
     * @param handler
     */
    public void getCrossJiFenRank(CCGetCrossJiFenRankRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int page = rq.getPage();
        CCGetCrossJiFenRankRs.Builder builder = CCGetCrossJiFenRankRs.newBuilder();
        builder.setRoleId(roleId);
        LinkedHashMap<Long, JiFenPlayer> rankMap = CrossFightCache.getJifenPlayerMap();
        JiFenPlayer myJiFenPlayer = rankMap.get(roleId);
        int myjifen = 0;
        if (myJiFenPlayer != null) {
            myjifen = myJiFenPlayer.getJifen();
        }
        int myRank = 0;
        int begin = page * 20;
        int end = begin + 20;
        int index = 0;
        for (Entry<Long, JiFenPlayer> entry : rankMap.entrySet()) {
            if (index >= end) {
                break;
            }
            if (index >= begin && entry.getValue().getJifen() > 0) {
                JiFenPlayer jp = entry.getValue();
                String serverName = GameContext.gameServerMaps.get(jp.getServerId()).getName();
                String name = jp.getNick();
                Athlete a = CrossFightCache.getAthlete(entry.getKey());
                int winNum = 0;
                int failNum = 0;
                int myGroup = 0;
                if (a != null) {
                    winNum = a.getWinNum();
                    failNum = a.getFailNum();
                    myGroup = a.getGroupId();
                }
                int jifen = jp.getJifen();
                builder.addCrossJiFenRank(PbHelper.createCrossJiFenRankPb(index + 1, serverName, name, winNum, failNum, jifen, myGroup));
            }
            index++;
        }
        if (myRank == 0) {
            // 从前500名找，没找到，就是未上榜
            if (myJiFenPlayer != null) {
                int i = 0;
                for (Entry<Long, JiFenPlayer> entry : rankMap.entrySet()) {
                    if (i < 500) {
                        JiFenPlayer jp = entry.getValue();
                        if (jp == myJiFenPlayer && jp.getJifen() > 0) {
                            myRank = i + 1;
                        }
                        i++;
                    }
                }
            }
        }
        builder.setJifen(myjifen);
        builder.setMyRank(myRank);
        handler.sendMsgToPlayer(CCGetCrossJiFenRankRs.ext, builder.build());
    }

    /**
     * 获取战报
     *
     * @param rq
     * @param handler
     */
    public void getCrossReport(CCGetCrossReportRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int reportKey = rq.getReportKey();
        CCGetCrossReportRs.Builder builder = CCGetCrossReportRs.newBuilder();
        builder.setRoleId(roleId);
        CrossRptAtk atk = CrossFightCache.getCrossRptAtks().get(reportKey);
        if (atk == null) {
            handler.sendMsgToPlayer(GameError.CROSS_REPORT_IS_NOT_EXISTED, CCGetCrossReportRs.ext, builder.build());
            return;
        }
        builder.setCrossRptAtk(atk);
        handler.sendMsgToPlayer(CCGetCrossReportRs.ext, builder.build());
    }

    /**
     * 获取淘汰赛信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossKnockCompetInfo(CCGetCrossKnockCompetInfoRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int groupId = rq.getGroupId();
        int groupType = rq.getGroupType();
        int serverId = handler.getServerId();
        KnockoutBattleGroup k = null;
        if (groupId == CrossConst.DF_Group) {
            k = CrossFightCache.getDfKnockoutBattleGroups().get(groupType);
        } else {
            k = CrossFightCache.getJyKnockoutBattleGroups().get(groupType);
        }
        JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(roleId);
        CCGetCrossKnockCompetInfoRs.Builder builder = CCGetCrossKnockCompetInfoRs.newBuilder();
        if (k != null) {
            builder.setRoleId(roleId);
            builder.setGroupId(groupId);
            builder.setGroupType(groupType);
            Iterator<CompetGroup> its = k.groupMaps.values().iterator();
            while (its.hasNext()) {
                CompetGroup cg = its.next();
                String myBetKey = groupId + "_" + CrossConst.Knock_Session + "_" + groupType + "_" + cg.getCompetGroupId();
                MyBet myBet = jp.myBets.get(myBetKey);
                if (myBet != null) {
                    builder.addKnockoutCompetGroup(PbHelper.createKnockoutCompetGroupPb(cg, myBet.getC1(), myBet.getC2()));
                } else {
                    builder.addKnockoutCompetGroup(PbHelper.createKnockoutCompetGroupPb(cg));
                }
            }
        }
        builder.setRoleId(roleId);
        builder.setGroupId(groupId);
        builder.setGroupType(groupType);
        handler.sendMsgToPlayer(CCGetCrossKnockCompetInfoRs.ext, builder.build());
    }

    /**
     * 获取总决赛信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossFinalCompetInfo(CCGetCrossFinalCompetInfoRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int groupId = rq.getGroupId();
        Map<Integer, CompetGroup> map = null;
        if (groupId == CrossConst.DF_Group) {
            map = CrossFightCache.getDfFinalBattleGroups();
        } else {
            map = CrossFightCache.getJyFinalBattleGroups();
        }
        CCGetCrossFinalCompetInfoRs.Builder builder = CCGetCrossFinalCompetInfoRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setGroupId(groupId);
        Iterator<CompetGroup> its = map.values().iterator();
        while (its.hasNext()) {
            builder.addFinalCompetGroup(PbHelper.createFinalCompetGroupPb(its.next()));
        }
        handler.sendMsgToPlayer(CCGetCrossFinalCompetInfoRs.ext, builder.build());
    }

    /**
     * 下注
     *
     * @param rq
     * @param handler
     */
    public void betBattle(CCBetBattleRq rq, ClientHandler handler) {
        CCBetBattleRs.Builder builder = CCBetBattleRs.newBuilder();
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        builder.setRoleId(roleId);
        int myGroup = rq.getMyGroup(); // 1精英组 2巅峰组
        int stage = rq.getStage(); // 1淘汰赛,2总决赛
        int groupType = rq.getGroupType(); // 淘汰赛有分组,1A 2B 3C 4D 总决赛0
        int competGroupId = rq.getCompetGroupId(); // 淘汰赛(1-15组) 总决赛(1-4组)
        int pos = rq.getPos();
        String betKey = myGroup + "_" + stage + "_" + groupType + "_" + competGroupId;
        builder.setPos(pos);
        boolean isSameCg = false;
        Iterator<MyBet> its = CrossFightCache.getJifenPlayerMap().get(roleId).myBets.values().iterator();
        while (its.hasNext()) {
            MyBet m = its.next();
            if (m.getMyGroup() == myGroup && m.getStage() == stage && isSameCg(competGroupId, m.getCompetGroupId(), groupType, m.getGroupType())) {
                isSameCg = true;
                break;
            }
        }
        if (isSameCg) {
            handler.sendMsgToPlayer(GameError.CROSS_CAN_BET_CASE_SAME_CG, CCBetBattleRs.ext, builder.build());
            return;
        }
        MyBet myBet = CrossFightCache.getJifenPlayerMap().get(roleId).myBets.get(betKey);
        int limitNum = 4;
        CompetGroup cg = null;
        if (myGroup == CrossConst.DF_Group) {
            // 巅峰组
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getDfKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                if (k == null) {
                    // 时间未到
                    handler.sendMsgToPlayer(GameError.CROSS_BET_NOT_TIME, CCBetBattleRs.ext, builder.build());
                    return;
                } else {
                    cg = k.groupMaps.get(competGroupId);
                }
            } else {
                // 总决赛不能下注
                handler.sendMsgToPlayer(GameError.CROSS_FINAL_NO_BET, CCBetBattleRs.ext, builder.build());
                return;
            }
        } else {
            limitNum = 3;
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getJyKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                if (k == null) {
                    // 时间未到
                    handler.sendMsgToPlayer(GameError.CROSS_BET_NOT_TIME, CCBetBattleRs.ext, builder.build());
                    return;
                } else {
                    cg = k.groupMaps.get(competGroupId);
                }
            } else {
                // 总决赛不能下注
                handler.sendMsgToPlayer(GameError.CROSS_FINAL_NO_BET, CCBetBattleRs.ext, builder.build());
                return;
            }
        }
        if (cg == null) {
            // 时间未到
            handler.sendMsgToPlayer(GameError.CROSS_BET_NOT_TIME, CCBetBattleRs.ext, builder.build());
            return;
        }
        if (cg.getC1() == null || cg.getC2() == null) {
            // 如果轮空了,不下注
            handler.sendMsgToPlayer(GameError.CROSS_NO_OPPONENT, CCBetBattleRs.ext, builder.build());
            return;
        }
        if (cg.getMap().size() == 3) {
            // 已经打完了不能下注
            handler.sendMsgToPlayer(GameError.CROSS_CAN_NOT_BET_CASE_HAVE_FIGHT, CCBetBattleRs.ext, builder.build());
            return;
        }
        // 如果超过次数，不下注(巅峰4次,精英组3次)
        if (pos == 1) {
            if (myBet != null && myBet.getC1().getMyBetNum() >= limitNum) {
                handler.sendMsgToPlayer(GameError.CROSS_BET_NUM_LIMIT, CCBetBattleRs.ext, builder.build());
                return;
            }
        } else {
            if (myBet != null && myBet.getC2().getMyBetNum() >= limitNum) {
                handler.sendMsgToPlayer(GameError.CROSS_BET_NUM_LIMIT, CCBetBattleRs.ext, builder.build());
                return;
            }
        }
        if (myBet == null) {
            // 第一次下注
            myBet = new MyBet();
            myBet.setMyGroup(myGroup);
            myBet.setStage(stage);
            myBet.setGroupType(groupType);
            myBet.setCompetGroupId(competGroupId);
            int amount = staticCrossDataMgr.getServerWarBettingMap().get(1).getAmount();
            if (pos == 1) {
                ComptePojo cp = new ComptePojo(pos, cg.getC1().getServerId(), cg.getC1().getRoleId(), cg.getC1().getNick(), cg.getC1().getBet(), 1, cg.getC1().getServerName(), cg.getC1().getFight(), cg.getC1().getPortrait(), cg.getC1().getPartyName(), cg.getC1().getLevel());
                myBet.setC1(cp);
                cg.getC1().setBet(cg.getC1().getBet() + amount);
                ComptePojo cp2 = new ComptePojo(2, cg.getC2().getServerId(), cg.getC2().getRoleId(), cg.getC2().getNick(), cg.getC2().getBet(), 0, cg.getC2().getServerName(), cg.getC2().getFight(), cg.getC2().getPortrait(), cg.getC2().getPartyName(), cg.getC2().getLevel());
                myBet.setC2(cp2);
            } else {
                ComptePojo cp2 = new ComptePojo(pos, cg.getC2().getServerId(), cg.getC2().getRoleId(), cg.getC2().getNick(), cg.getC2().getBet(), 1, cg.getC2().getServerName(), cg.getC2().getFight(), cg.getC2().getPortrait(), cg.getC2().getPartyName(), cg.getC2().getLevel());
                myBet.setC2(cp2);
                cg.getC2().setBet(cg.getC2().getBet() + amount);
                ComptePojo cp1 = new ComptePojo(1, cg.getC1().getServerId(), cg.getC1().getRoleId(), cg.getC1().getNick(), cg.getC1().getBet(), 0, cg.getC1().getServerName(), cg.getC1().getFight(), cg.getC1().getPortrait(), cg.getC1().getPartyName(), cg.getC1().getLevel());
                myBet.setC1(cp1);
            }
            myBet.setWin(cg.getWin());
            myBet.setBetState(CrossConst.BetState.BET_STATE_HAVE_NO_RECEIVED);
            myBet.setBetTime(DateHelper.getServerTime());
            CrossFightCache.getJifenPlayerMap().get(roleId).myBets.put(betKey, myBet);
        } else {
            ComptePojo c1 = myBet.getC1();
            ComptePojo c2 = myBet.getC2();
            if (pos == 1) {
                // 判断c2 有没有下注,若有不能下注
                if (c2.getMyBetNum() >= 1) {
                    handler.sendMsgToPlayer(GameError.CROSS_CAN_BET_TWO_BOY, CCBetBattleRs.ext, builder.build());
                    return;
                }
                int amount = staticCrossDataMgr.getServerWarBettingMap().get(c1.getMyBetNum() + 1).getAmount();
                cg.getC1().setBet(cg.getC1().getBet() + amount);
                c1.setMyBetNum(c1.getMyBetNum() + 1);
            } else {
                // 判断对c1有没有下注
                if (c1.getMyBetNum() >= 1) {
                    handler.sendMsgToPlayer(GameError.CROSS_CAN_BET_TWO_BOY, CCBetBattleRs.ext, builder.build());
                    return;
                }
                int amount = staticCrossDataMgr.getServerWarBettingMap().get(c2.getMyBetNum() + 1).getAmount();
                cg.getC2().setBet(cg.getC2().getBet() + amount);
                c2.setMyBetNum(c2.getMyBetNum() + 1);
            }
            myBet.setWin(cg.getWin());
            myBet.setBetState(CrossConst.BetState.BET_STATE_HAVE_NO_RECEIVED);
            myBet.setBetTime(DateHelper.getServerTime());
        }
        // 更改淘汰赛阵型
        CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
        byte[] dfKnockoutBattleGroups = crossFightInfoTable.serDfKnockoutBattleGroups(CrossFightCache.getDfKnockoutBattleGroups());
        crossFightInfoTable.setDfKnockoutBattleGroups(dfKnockoutBattleGroups);
        byte[] serJyKnockoutBattleGroups = crossFightInfoTable.serJyKnockoutBattleGroups(CrossFightCache.getJyKnockoutBattleGroups());
        crossFightInfoTable.setJyKnockoutBattleGroups(serJyKnockoutBattleGroups);
        crossFightInfoTableDao.update(crossFightInfoTable);
        crossCacheUpdateService.updateJiFenPlayer(CrossFightCache.getJifenPlayerMap().get(roleId));
        builder.setMyBet(PbHelper.createMyBetPb(myBet, cg));
        handler.sendMsgToPlayer(CCBetBattleRs.ext, builder.build());
    }

    /**
     * 1-8 9-12 13-14 为相同组
     *
     * @param competGroupId1
     * @param competGroupId2
     * @param groupType1
     * @param groupType2
     * @return
     */
    private boolean isSameCg(int competGroupId1, int competGroupId2, int groupType1, int groupType2) {
        if (groupType1 == groupType2) {
            if (competGroupId1 != competGroupId2) {
                if (competGroupId1 >= 1 && competGroupId1 <= 8 && competGroupId2 >= 1 && competGroupId2 <= 8) {
                    return true;
                }
                if (competGroupId1 >= 9 && competGroupId1 <= 12 && competGroupId2 >= 9 && competGroupId2 <= 12) {
                    return true;
                }
                if (competGroupId1 >= 13 && competGroupId1 <= 14 && competGroupId2 >= 13 && competGroupId2 <= 14) {
                    return true;
                }
                if (competGroupId1 == 15 && competGroupId2 == 15) {
                    return true;
                }
            }
        } else {
            if (competGroupId1 >= 1 && competGroupId1 <= 8 && competGroupId2 >= 1 && competGroupId2 <= 8) {
                return true;
            }
            if (competGroupId1 >= 9 && competGroupId1 <= 12 && competGroupId2 >= 9 && competGroupId2 <= 12) {
                return true;
            }
            if (competGroupId1 >= 13 && competGroupId1 <= 14 && competGroupId2 >= 13 && competGroupId2 <= 14) {
                return true;
            }
            if (competGroupId1 == 15 && competGroupId2 == 15) {
                return true;
            }
        }
        return false;
    }

    /**
     * 下注回滚
     *
     * @param rq
     * @param handler
     */
    public void betRollBack(CCBetRollBackRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        int myGroup = rq.getMyGroup(); // 1精英组 2巅峰组
        int stage = rq.getStage(); // 1淘汰赛,2总决赛
        int groupType = rq.getGroupType(); // 淘汰赛有分组,1A 2B 3C 4D 总决赛0
        int competGroupId = rq.getCompetGroupId(); // 淘汰赛(1-15组) 总决赛(1-4组)
        int pos = rq.getPos();
        String betKey = myGroup + "_" + stage + "_" + groupType + "_" + competGroupId;
        // 获取下注的次数
        MyBet myBet = CrossFightCache.getJifenPlayerMap().get(roleId).myBets.get(betKey);
        CompetGroup cg = null;
        if (myGroup == CrossConst.DF_Group) {
            // 巅峰组
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getDfKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                cg = k.groupMaps.get(competGroupId);
            } else {
                // 总决赛
                cg = CrossFightCache.getDfFinalBattleGroups().get(competGroupId);
            }
        } else {
            // 精英组
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getJyKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                cg = k.groupMaps.get(competGroupId);
            } else {
                // 总决赛;
                cg = CrossFightCache.getJyFinalBattleGroups().get(competGroupId);
            }
        }
        if (pos == 1) {
            cg.getC1().setBet(cg.getC1().getBet() - staticCrossDataMgr.getServerWarBettingMap().get(myBet.getC1().getMyBetNum()).getAmount());
            myBet.getC1().setMyBetNum(myBet.getC1().getMyBetNum() - 1);
        } else {
            cg.getC2().setBet(cg.getC2().getBet() - staticCrossDataMgr.getServerWarBettingMap().get(myBet.getC2().getMyBetNum()).getAmount());
            myBet.getC2().setMyBetNum(myBet.getC2().getMyBetNum() - 1);
        }
        CrossFightInfoTable crossFightInfoTable = crossFightInfoTableDao.get(crossId);
        byte[] dfKnockoutBattleGroups = crossFightInfoTable.serDfKnockoutBattleGroups(CrossFightCache.getDfKnockoutBattleGroups());
        crossFightInfoTable.setDfKnockoutBattleGroups(dfKnockoutBattleGroups);
        byte[] serJyKnockoutBattleGroups = crossFightInfoTable.serJyKnockoutBattleGroups(CrossFightCache.getJyKnockoutBattleGroups());
        crossFightInfoTable.setJyKnockoutBattleGroups(serJyKnockoutBattleGroups);
        crossFightInfoTableDao.update(crossFightInfoTable);
        crossCacheUpdateService.updateJiFenPlayer(CrossFightCache.getJifenPlayerMap().get(roleId));
    }

    /**
     * 获取我的下注(总下注信息)
     *
     * @param rq
     * @param handler
     */
    public void getMyBet(CCGetMyBetRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCGetMyBetRs.Builder builder = CCGetMyBetRs.newBuilder();
        builder.setRoleId(roleId);
        HashMap<String, MyBet> m = CrossFightCache.getJifenPlayerMap().get(roleId).myBets;
        Iterator<MyBet> its = m.values().iterator();
        while (its.hasNext()) {
            MyBet myBet = its.next();
            // 1精英组 2巅峰组
            int myGroup = myBet.getMyGroup();
            // 1淘汰赛,2总决赛
            int stage = myBet.getStage();
            // 淘汰赛有分组,1A 2B 3C 4D 总决赛0
            int groupType = myBet.getGroupType();
            // 淘汰赛(1-15组)
            int competGroupId = myBet.getCompetGroupId();
            // 总决赛(1-4组)
            CompetGroup cg = null;
            if (myGroup == CrossConst.DF_Group) {
                // 巅峰组
                if (stage == CrossConst.Knock_Session) {
                    // 淘汰赛
                    Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getDfKnockoutBattleGroups();
                    KnockoutBattleGroup k = map.get(groupType);
                    cg = k.groupMaps.get(competGroupId);
                } else {
                    // 总决赛
                    cg = CrossFightCache.getDfFinalBattleGroups().get(competGroupId);
                }
            } else {
                // 精英组
                if (stage == CrossConst.Knock_Session) {
                    // 淘汰赛
                    Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getJyKnockoutBattleGroups();
                    KnockoutBattleGroup k = map.get(groupType);
                    cg = k.groupMaps.get(competGroupId);
                } else {
                    // 总决赛;
                    cg = CrossFightCache.getJyFinalBattleGroups().get(competGroupId);
                }
            }
            // 胜利或者失败
            if (cg.getMap().size() == 3) {
                if (myBet.getBetState() != CrossConst.BetState.BET_STATE_HAVE_RECEIVED) {
                    myBet.setBetState(CrossConst.BetState.BET_STATE_COULD_RECEIVE);
                }
            }
            myBet.getC1().setBet(cg.getC1().getBet());
            myBet.getC2().setBet(cg.getC2().getBet());
            myBet.setWin(cg.getWin());
            myBet.getCompteRounds().clear();
            myBet.getCompteRounds().addAll(cg.map.values());
            builder.addMyBets(PbHelper.createMyBetPb(myBet, cg));
        }
        handler.sendMsgToPlayer(CCGetMyBetRs.ext, builder.build());
    }

    public void autoReceiveBet() {
        List<JiFenPlayer> list = new ArrayList<>(CrossFightCache.getJifenPlayerMap().values());
        Iterator<JiFenPlayer> jpIts = list.iterator();
        while (jpIts.hasNext()) {
            JiFenPlayer jp = jpIts.next();
            Iterator<MyBet> betIts = jp.myBets.values().iterator();
            int oldJifen = jp.getJifen();
            StringBuilder betSb = new StringBuilder();
            int costGold = 0;
            for (Entry<String, MyBet> entry : jp.myBets.entrySet()) {
                MyBet myBet = betIts.next();
                try {
                    if (myBet.getBetState() == CrossConst.BetState.BET_STATE_HAVE_RECEIVED) {
                        continue;
                    }
                    CompetGroup cg = null;
                    int myGroup = myBet.getMyGroup();
                    int stage = myBet.getStage();
                    int groupType = myBet.getGroupType();
                    int competGroupId = myBet.getCompetGroupId();
                    if (myGroup == CrossConst.DF_Group) {
                        // 巅峰组
                        if (stage == CrossConst.Knock_Session) {
                            // 淘汰赛
                            Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getDfKnockoutBattleGroups();
                            KnockoutBattleGroup k = map.get(groupType);
                            cg = k.groupMaps.get(competGroupId);
                        } else {
                            // 总决赛
                            cg = CrossFightCache.getDfFinalBattleGroups().get(competGroupId);
                        }
                    } else {
                        // 精英组
                        if (stage == CrossConst.Knock_Session) {
                            // 淘汰赛
                            Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getJyKnockoutBattleGroups();
                            KnockoutBattleGroup k = map.get(groupType);
                            cg = k.groupMaps.get(competGroupId);
                        } else {
                            // 总决赛;
                            cg = CrossFightCache.getJyFinalBattleGroups().get(competGroupId);
                        }
                    }
                    myBet.setWin(cg.getWin());
                    // 胜利或者失败
                    if (cg.getMap().size() == 3) {
                        if (myBet.getBetState() != CrossConst.BetState.BET_STATE_HAVE_RECEIVED) {
                            int num = 0;
                            int jifen = 0;
                            String nick;
                            boolean isWin = false;
                            // 查看我下了c1还是c2
                            if (myBet.getC1().getMyBetNum() > 0) {
                                num = myBet.getC1().getMyBetNum();
                                nick = myBet.getC1().getNick();
                                // 下的c1并且失败
                                if (myBet.getWin() == 0) {
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                                } else if (myBet.getWin() == 1) {
                                    // 下的c1并且赢了
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getWin();
                                    isWin = true;
                                } else {
                                    // 没有战斗
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                                }
                            } else {
                                num = myBet.getC2().getMyBetNum();
                                // 下注后又撤回了
                                if (num == 0) {
                                    continue;
                                }
                                nick = myBet.getC2().getNick();
                                // 下的c2并且赢了
                                if (myBet.getWin() == 0) {
                                    isWin = true;
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getWin();
                                } else if (myBet.getWin() == 1) {
                                    // 下的c2并且输了
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                                } else {
                                    jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                                }
                            }
                            costGold += staticCrossDataMgr.getServerWarBettingMap().get(num).getCost();
                            // 设置已经领取
                            myBet.setBetState(CrossConst.BetState.BET_STATE_HAVE_RECEIVED);
                            jp.setJifen(jp.getJifen() + jifen);
                            betSb.append("[").append(String.format("[bet key :%s, num :%d, jifen :%d", entry.getKey(), num, jifen)).append("],");
                            // 记录玩家积分详情
                            if (isWin) {
                                CrossTrendHelper.addCrossTrend(jp, CrossConst.TREND.BET_SUCCESS, nick, String.valueOf(jifen));
                            } else {
                                CrossTrendHelper.addCrossTrend(jp, CrossConst.TREND.BET_FAIL, nick, String.valueOf(jifen));
                            }
                        }
                    }
                } catch (Exception e) {
                    LogUtil.error(String.format("自动领取下注错误 id :%d, nick :%s, myGroup :%d,  stage :%d, groupType :%d, competGroupId :%d ", jp.getRoleId(), jp.getNick(), myBet.getMyGroup(), myBet.getStage(), myBet.getGroupType(), myBet.getCompetGroupId()), e);
                }
            }
            if (oldJifen != jp.getJifen()) {
                String jpStr = String.format("玩家积分 sid :%d, roleId :%d, role :%s, jifen :%d, after receive bet jifen :%d, exchangeJifen :%d, cost gold :%d, bet detail :%s", jp.getServerId(), jp.getRoleId(), jp.getNick(), oldJifen, jp.getJifen(), jp.getExchangeJifen(), costGold, betSb);
                LogUtil.error(jpStr);
            }

            crossCacheUpdateService.updateJiFenPlayer(jp);
        }
        crossDataManager.sortJiFen();
    }

    /**
     * 能否领取
     *
     * @param rq
     * @param handler
     */
    public void receiveBet(CCReceiveBetRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCReceiveBetRs.Builder builder = CCReceiveBetRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setJifen(0);
        int myGroup = rq.getMyGroup(); // 1精英组 2巅峰组
        int stage = rq.getStage(); // 1淘汰赛,2总决赛
        int groupType = rq.getGroupType(); // 淘汰赛有分组,1A 2B 3C 4D 总决赛0
        int competGroupId = rq.getCompetGroupId(); // 淘汰赛(1-15组) 总决赛(1-4组)
        // 判断时间,总决赛之前要领取
        String nowTime = TimeHelper.getNowHourAndMins();
        String beginTime = "20:00:00";
        // 判断当前状态
        if (TimeHelper.getDayOfCrossWar() > CrossConst.STAGE.STATE_FINAL) {
            handler.sendMsgToPlayer(GameError.CROSS_CAN_RECEIVE_BET_CASE_TIME, CCReceiveBetRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() == CrossConst.STAGE.STATE_FINAL && (nowTime.compareTo(beginTime) > 0)) {
            handler.sendMsgToPlayer(GameError.CROSS_CAN_RECEIVE_BET_CASE_TIME, CCReceiveBetRs.ext, builder.build());
            return;
        }
        CompetGroup cg = null;
        if (myGroup == CrossConst.DF_Group) {
            // 巅峰组
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getDfKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                cg = k.groupMaps.get(competGroupId);
            } else {
                // 总决赛
                cg = CrossFightCache.getDfFinalBattleGroups().get(competGroupId);
            }
        } else {
            // 精英组
            if (stage == CrossConst.Knock_Session) {
                // 淘汰赛
                Map<Integer, KnockoutBattleGroup> map = CrossFightCache.getJyKnockoutBattleGroups();
                KnockoutBattleGroup k = map.get(groupType);
                cg = k.groupMaps.get(competGroupId);
            } else {
                // 总决赛;
                cg = CrossFightCache.getJyFinalBattleGroups().get(competGroupId);
            }
        }
        String betKey = myGroup + "_" + stage + "_" + groupType + "_" + competGroupId;
        MyBet myBet = CrossFightCache.getJifenPlayerMap().get(roleId).myBets.get(betKey);
        if (myBet == null) {
            // 没有下注
            handler.sendMsgToPlayer(GameError.CROSS_NO_BET, CCReceiveBetRs.ext, builder.build());
            return;
        }
        myBet.setWin(cg.getWin());
        // 胜利或者失败
        if (cg.getMap().size() == 3) {
            if (myBet.getBetState() != CrossConst.BetState.BET_STATE_HAVE_RECEIVED) {
                int num = 0;
                int jifen = 0;
                String nick;
                boolean isWin = false;
                // 查看我下了c1还是c2
                if (myBet.getC1().getMyBetNum() > 0) {
                    num = myBet.getC1().getMyBetNum();
                    nick = myBet.getC1().getNick();
                    // 下的c1并且失败
                    if (myBet.getWin() == 0) {
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                    } else if (myBet.getWin() == 1) {
                        // 下的c1并且赢了
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getWin();
                        isWin = true;
                    } else {
                        // 没有战斗
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                    }
                } else {
                    num = myBet.getC2().getMyBetNum();
                    nick = myBet.getC2().getNick();
                    // 下的c2并且赢了
                    if (myBet.getWin() == 0) {
                        isWin = true;
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getWin();
                    } else if (myBet.getWin() == 1) {
                        // 下的c2并且输了
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                    } else {
                        jifen = staticCrossDataMgr.getServerWarBettingMap().get(num).getLose();
                    }
                }
                // 设置已经领取
                myBet.setBetState(CrossConst.BetState.BET_STATE_HAVE_RECEIVED);
                JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(roleId);
                jp.setJifen(jp.getJifen() + jifen);
                builder.setJifen(jp.getJifen() - jp.getExchangeJifen());
                builder.setMyBet(PbHelper.createMyBetPb(myBet, cg));
                crossDataManager.sortJiFen();
                // 记录玩家积分详情
                if (isWin) {
                    CrossTrendHelper.addCrossTrend(jp, CrossConst.TREND.BET_SUCCESS, nick, String.valueOf(jifen));
                } else {
                    CrossTrendHelper.addCrossTrend(jp, CrossConst.TREND.BET_FAIL, nick, String.valueOf(jifen));
                }
                crossCacheUpdateService.updateJiFenPlayer(jp);
                handler.sendMsgToPlayer(CCReceiveBetRs.ext, builder.build());
            } else {
                // 已经领取过
                handler.sendMsgToPlayer(GameError.CROSS_BET_HAVE_RECEIVE, CCReceiveBetRs.ext, builder.build());
                return;
            }
        } else {
            // 还没战斗不能领奖
            handler.sendMsgToPlayer(GameError.CROSS_CANT_RECEVIE_BET_CAUSE_NO_FIGHT, CCReceiveBetRs.ext, builder.build());
            return;
        }
    }

    /**
     * 获取跨服商店信息
     *
     * @param req
     * @param handler
     */
    public void getCrossShop(CCGetCrossShopRq req, ClientHandler handler) {
        CCGetCrossShopRs.Builder builder = CCGetCrossShopRs.newBuilder();
        long roleId = req.getRoleId();
        int serverId = handler.getServerId();
        JiFenPlayer athlete = CrossFightCache.getJifenPlayerMap().get(roleId);
        builder.setRoleId(roleId);
        builder.setCrossJifen(null == athlete ? 0 : (athlete.getJifen() - athlete.getExchangeJifen()));
        String nowTime = TimeHelper.getNowHourAndMins();
        String beginTime = "20:15:00";
        // // 判断当前状态
        // if (TimeHelper.getDayOfCrossWar() < CrossConst.STAGE.STATE_FINAL) {
        // handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME,
        // CCGetCrossShopRs.ext, builder.build());
        // return;
        // }
        //
        // if (TimeHelper.getDayOfCrossWar() == CrossConst.STAGE.STATE_FINAL &&
        // (nowTime.compareTo(beginTime) < 0)) {
        // handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME,
        // CCGetCrossShopRs.ext, builder.build());
        // return;
        // }
        updateCrossShopData(athlete);
        // Map<Integer, CrossShopBuy> map =
        // crossDataManager.gameCross.getCrossShopMap();
        // for (CrossShopBuy buy : map.values()) {
        // CrossShopBuy csb = athlete.crossShopBuy.get(buy.getShopId());
        // if (csb == null) {
        // csb = new CrossShopBuy(buy.getShopId(), 0, buy.getRestNum());
        // athlete.crossShopBuy.put(csb.getShopId(), csb);
        // }
        // builder.addBuy(PbHelper.createCrossShopBuyPb(csb));
        // }
        for (CrossShopBuy buy : athlete.crossShopBuy.values()) { // 普通商品记录
            builder.addBuy(PbHelper.createCrossShopBuyPb(buy));
        }
        handler.sendMsgToPlayer(CCGetCrossShopRs.ext, builder.build());
    }

    private void updateCrossShopData(JiFenPlayer player) {
        // int today = TimeHelper.getCurrentDay();
        // if (today != player.getLastUpdateCrossShopDate()) {//
        // 上次更新时间不是今天，重置购买记录
        // player.crossShopBuy.clear();
        // player.setLastUpdateCrossShopDate(today);
        // }
    }

    /**
     * 玩家兑换跨服商店商品
     *
     * @param req
     * @param handler
     */
    public void exchangeCrossShop(CCExchangeCrossShopRq req, ClientHandler handler) {
        CCExchangeCrossShopRs.Builder builder = CCExchangeCrossShopRs.newBuilder();
        String nowTime = TimeHelper.getNowHourAndMins();
        String beginTime = "20:15:00";
        long roleId = req.getRoleId();
        int shopId = req.getShopId();
        int count = req.getCount();
        builder.setRoleId(roleId);
        builder.setShopId(shopId);
        // 检查玩家积分是否足够
        int serverId = ChannelUtil.getServerId(handler.getCtx());
        JiFenPlayer athlete = CrossFightCache.getJifenPlayerMap().get(roleId);
        if (athlete == null) {
            // 不可能到此处
            LogUtil.error("不可能执行到此处");
            return;
        }
        builder.setCrossJifen(athlete.getJifen() - athlete.getExchangeJifen());
        // 判断当前状态
        if (TimeHelper.getDayOfCrossWar() < CrossConst.STAGE.STATE_FINAL) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() == CrossConst.STAGE.STATE_FINAL && (nowTime.compareTo(beginTime) < 0)) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() > CrossConst.STAGE.STATE_SHOP1) {
            // 时间过不不能兑换
            handler.sendMsgToPlayer(GameError.CROSS_CAN_NOT_EXCHANGE_CASE_TIME, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        // 检查shopId是否正确
        StaticCrossShop shop = staticCrossDataMgr.getStaticCrossShopById(shopId);
        if (null == shop) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_FOUND, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        if (shop.getType() != 1) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_FOUND, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        int cost = shop.getCost() * count;
        if (null == athlete || (athlete.getJifen() - athlete.getExchangeJifen()) < cost) {
            handler.sendMsgToPlayer(GameError.CROSS_JIFEN_NOT_ENOUGH, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        // 检查购买数量是否合法
        if (count < 1 || count > Integer.MAX_VALUE) {
            handler.sendMsgToPlayer(GameError.INVALID_PARAM, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        updateCrossShopData(athlete);
        // 如果是珍品，更新购买次数
        if (shop.isTreasure()) {
            // 参赛玩家才能购买
            if (CrossFightCache.getAthlete(roleId) == null) {
                handler.sendMsgToPlayer(GameError.CROSS_ATHLETE_CAN_ECHAGE_Treasure, CCExchangeCrossShopRs.ext, builder.build());
                return;
            }
        }
        CrossShopBuy csb = athlete.crossShopBuy.get(shopId);
        if (null == csb) {
            csb = new CrossShopBuy();
            csb.setShopId(shopId);
            csb.setBuyNum(0);
            athlete.crossShopBuy.put(shopId, csb);
        }
        // 检查剩余数量是否足够
        if ((csb.getBuyNum() + count) > shop.getPersonNumber()) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_ENOUGH, CCExchangeCrossShopRs.ext, builder.build());
            return;
        }
        // 更新玩家的积分
        athlete.setExchangeJifen(athlete.getExchangeJifen() + cost);
        // 更新玩家购买次数
        csb = athlete.crossShopBuy.get(shopId);
        csb.setBuyNum(csb.getBuyNum() + count);
        builder.setCrossJifen(athlete.getJifen() - athlete.getExchangeJifen());
        builder.setCount(count);
        builder.setRestNum(0);
        handler.sendMsgToPlayer(CCExchangeCrossShopRs.ext, builder.build());
        // 记录玩家积分详情
        CrossTrendHelper.addCrossTrend(athlete, CrossConst.TREND.SHOP_EXCHANGE, shop.getGoodName(), String.valueOf(cost));
        crossCacheUpdateService.updateJiFenPlayer(athlete);
    }

    /**
     * 获取排行信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossFinalRank(CCGetCrossFinalRankRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int group = rq.getGroup();
        int serverId = handler.getServerId();
        LinkedHashMap<Long, Long> map = null;
        if (group == CrossConst.DF_Group) {
            map = CrossFightCache.getDfRankMap();
        } else {
            map = CrossFightCache.getJyRankMap();
        }
        CCGetCrossFinalRankRs.Builder builder = CCGetCrossFinalRankRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setGroup(group);
        int index = 0;
        builder.setMyRank(0);
        builder.setState(CrossConst.ReceiveRankRwardState.DEFAULT);
        for (Entry<Long, Long> entry : map.entrySet()) {
            index++;
            Athlete at = CrossFightCache.getAthlete(entry.getKey());
            String serverName = GameContext.gameServerMaps.get(at.getServerId()).getName();
            if (roleId == entry.getKey()) {
                builder.setMyRank(index);
                CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(roleId);
                if (athleteTable != null) {
                    if (athleteTable.getReceiveCrossRankReward() == 1) {
                        // 已经领取
                        builder.setState(CrossConst.ReceiveRankRwardState.HAVE_RECEIVE);
                    }
                }
            }
            builder.addCrossTopRank(PbHelper.createCrossTopRankPb(index, serverName, at.getNick(), at.getFight(), at.getRoleId()));
            if (index >= 64) {
                break;
            }
        }
        JiFenPlayer fenPlayer = CrossFightCache.getJifenPlayerMap().get(roleId);
        int jf = 0;
        if (fenPlayer != null) {
            jf = fenPlayer.getJifen();
        }
        builder.setMyJiFen(jf);
        handler.sendMsgToPlayer(CCGetCrossFinalRankRs.ext, builder.build());
    }

    /**
     * 领取排行奖励
     *
     * @param rq
     * @param handler
     */
    public void receiveRankRwardHandler(CCReceiveRankRwardRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int group = rq.getGroup();
        int serverId = handler.getServerId();
        CCReceiveRankRwardRs.Builder builder = CCReceiveRankRwardRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setGroup(group);
        JiFenPlayer player = CrossFightCache.getJifenPlayerMap().get(roleId);
        int rank = getTopRank(group, roleId);
        builder.setRank(rank);
        if (rank == 0) {
            handler.sendMsgToPlayer(GameError.CROSS_NO_RANK, CCReceiveRankRwardRs.ext, builder.build());
            return;
        }
        // 判断当前状态
        if (!(TimeHelper.getDayOfCrossWar() == CrossConst.STAGE.STATE_SHOP1)) {
            if (TimeHelper.getDayOfCrossWar() != CrossConst.STAGE.STATE_FINAL) {
                handler.sendMsgToPlayer(GameError.CROSS_NO_RECEIVE_RANK_TIME, CCReceiveRankRwardRs.ext, builder.build());
                return;
            }
            String beginTime = "20:00:00";
            CrossFightTable crossFightTable = crossFightTableDao.get(crossId);
            CrossState cs = JSON.toJavaObject(JSON.parseObject(crossFightTable.getCrossState()), CrossState.class);
            if ((!cs.getBeginTime().equals(beginTime)) || (cs.getState() != CrossConst.end_state)) {
                handler.sendMsgToPlayer(GameError.CROSS_NO_RECEIVE_RANK_TIME, CCReceiveRankRwardRs.ext, builder.build());
                return;
            }
        }
        CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(roleId);
        if (athleteTable.getReceiveCrossRankReward() != 1) {
            athleteTable.setReceiveCrossRankReward(1);
            crossFightAthleteTableDao.update(athleteTable);
            builder.setRank(rank);
            // 积分领取掉
            List<List<Integer>> awards = null;
            if (rq.getGroup() == CrossConst.DF_Group) {
                awards = staticWarAwardDataMgr.getTopServerRankAwards(rank);
            } else {
                awards = staticWarAwardDataMgr.getEliteServerRankAwards(rank);
            }
            addAwardsBackPb(player, awards, AwardFrom.CROSS_RANK_AWARD);
            crossDataManager.sortJiFen();
            // 记录玩家积分详情
            CrossTrendHelper.addCrossTrend(player, CrossConst.TREND.RANK_AWARD, rank + "", awards.get(0).get(2) + "");
            crossCacheUpdateService.updateJiFenPlayer(player);
            handler.sendMsgToPlayer(CCReceiveRankRwardRs.ext, builder.build());
        } else {
            // 已经领取
            handler.sendMsgToPlayer(GameError.CROSS_HAVE_RECEIVE_CROSS_RANK, CCReceiveRankRwardRs.ext, builder.build());
        }
    }

    /**
     * Method: addAwardAndBack @Description: 只领取积分 from @return @return List<Award> @throws
     */
    public List<Award> addAwardsBackPb(JiFenPlayer player, List<List<Integer>> drop, AwardFrom from) {
        List<Award> awards = new ArrayList<>();
        if (drop != null && !drop.isEmpty()) {
            int type = 0;
            int id = 0;
            int count = 0;
            int keyId = 0;
            for (List<Integer> award : drop) {
                if (award.size() != 3) {
                    continue;
                }
                type = award.get(0);
                id = award.get(1);
                count = award.get(2);
                keyId = addAward(player, type, id, count, from);
                awards.add(PbHelper.createAwardPb(type, id, count, keyId));
            }
        }
        return awards;
    }

    public int addAward(JiFenPlayer player, int type, int id, long count, AwardFrom from) {
        switch (type) {
            case AwardType.CROSS_JIFEN:
                addCrossJiFen(player, (int) count, from);
                break;
            default:
                break;
        }
        return 0;
    }

    public void addCrossJiFen(JiFenPlayer player, int count, AwardFrom from) {
        player.setJifen(player.getJifen() + count);
        // LogLordHelper.crossJifen(from, player.account, player.lord,
        // player.crossJiFen, count, 0);
    }

    public int getTopRank(int group, long roleId) {
        int ret = 0;
        LinkedHashMap<Long, Long> map = null;
        if (group == CrossConst.DF_Group) {
            map = CrossFightCache.getDfRankMap();
        } else {
            map = CrossFightCache.getJyRankMap();
        }
        int index = 0;
        for (Entry<Long, Long> entry : map.entrySet()) {
            index++;
            if (entry.getKey() == roleId) {
                ret = index;
                break;
            }
            if (index >= 64) {
                break;
            }
        }
        return ret;
    }

    /**
     * 给某个game服发邮件<br>
     * type 类型,1全服,2个人 serverId 0 代表所有服
     *
     * @param serverId
     * @param mold
     * @param type
     * @param role
     * @param param
     */
    private void sendGameMail(int serverId, int mold, int type, Long role, String... param) {
        try {
            CCSynMailRq.Builder builder = CCSynMailRq.newBuilder();
            builder.setMoldId(mold);
            builder.setType(type);
            if (role != null) {
                builder.setRoleId(role);
            }
            if (param != null) {
                for (int i = 0; i < param.length; i++) {
                    String str = param[i];
                    if (str == null) {
                        str = " ";
                    }
                    builder.addParam(str);
                }
            }
            Base.Builder msg = PbHelper.createSynBase(CCSynMailRq.EXT_FIELD_NUMBER, CCSynMailRq.ext, builder.build());
            if (serverId == 0) {
                for (Server server : GameContext.getGameServerConfig().getList()) {
                    if (server.isConect()) {
                        GameContext.synMsgToPlayer(server.ctx, msg);
                    }
                }
            } else {
                GameContext.synMsgToPlayer(GameContext.gameServerMaps.get(serverId).ctx, msg);
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    public void synCrossRank() {
        CCSynCrossFameRq.Builder builder = CCSynCrossFameRq.newBuilder();
        String beginTime = DateHelper.formatDateTime(GameContext.CROSS_BEGIN_DATA, DateHelper.format2);
        String endTime = DateHelper.formatDateTime(DateHelper.someDayAfter(GameContext.CROSS_BEGIN_DATA, 5), DateHelper.format2);
        builder.setBeginTime(beginTime);
        builder.setEndTime(endTime);
        builder.addCrossFame(getCrossFamePb(CrossConst.JY_Group));
        builder.addCrossFame(getCrossFamePb(CrossConst.DF_Group));
        Base.Builder msg = PbHelper.createSynBase(CCSynCrossFameRq.EXT_FIELD_NUMBER, CCSynCrossFameRq.ext, builder.build());
        try {
            for (Server server : GameContext.getGameServerConfig().getList()) {
                if (server.isConect()) {
                    try {
                        GameContext.synMsgToPlayer(server.ctx, msg);
                    } catch (Exception e) {
                        LogUtil.error(e);
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    private CrossFame getCrossFamePb(int group) {
        CrossFame.Builder builder = CrossFame.newBuilder();
        builder.setGroupId(group);
        // 获取对应组的冠军
        // 获取对应组的亚军
        // 获取对应组的季军
        // 获取对应组的殿军
        // 获取对应组的人气王
        Athlete top1 = crossDataManager.getTop1(group);
        if (top1 != null) {
            builder.addFamePojo(PbHelper.createFamePojoPb(1, top1.getNick(), top1.getServerId(), GameContext.gameServerMaps.get(top1.getServerId()).getName(), top1.getLevel(), top1.getFight(), top1.getPortrait()));
        }
        Athlete top2 = crossDataManager.getTop2(group);
        if (top2 != null) {
            builder.addFamePojo(PbHelper.createFamePojoPb(2, top2.getNick(), top2.getServerId(), GameContext.gameServerMaps.get(top2.getServerId()).getName(), top2.getLevel(), top2.getFight(), top2.getPortrait()));
        }
        Athlete top3 = crossDataManager.getTop3(group);
        if (top3 != null) {
            builder.addFamePojo(PbHelper.createFamePojoPb(3, top3.getNick(), top3.getServerId(), GameContext.gameServerMaps.get(top3.getServerId()).getName(), top3.getLevel(), top3.getFight(), top3.getPortrait()));
        }
        Athlete top4 = crossDataManager.getTop4(group);
        if (top4 != null) {
            builder.addFamePojo(PbHelper.createFamePojoPb(4, top4.getNick(), top4.getServerId(), GameContext.gameServerMaps.get(top4.getServerId()).getName(), top4.getLevel(), top4.getFight(), top4.getPortrait()));
        }
        Athlete fames1 = getFames1(group);
        if (fames1 != null) {
            builder.addFamePojo(PbHelper.createFamePojoPb(5, fames1.getNick(), fames1.getServerId(), GameContext.gameServerMaps.get(fames1.getServerId()).getName(), fames1.getLevel(), fames1.getFight(), fames1.getPortrait()));
        }
        // 获取对应组的战局回顾
        // 获取A赛区15组两个(1,2位) ,胜利方9位
        // 获取D赛区15组两个(3,4位) ,胜利方10位
        // 获取B赛区15组两个(5,6位) ,胜利方11位
        // 获取C赛区15组两个(7,8位) ,胜利方12位
        // 获取总决赛3组两个(13 14位),胜利方 15位
        Map<Integer, KnockoutBattleGroup> temp = null;
        if (group == CrossConst.DF_Group) {
            temp = CrossFightCache.getDfKnockoutBattleGroups();
        } else {
            temp = CrossFightCache.getJyKnockoutBattleGroups();
        }
        KnockoutBattleGroup kgbA = temp.get(1);
        KnockoutBattleGroup kgbB = temp.get(2);
        KnockoutBattleGroup kgbC = temp.get(3);
        KnockoutBattleGroup kgbD = temp.get(4);
        if (kgbA != null) {
            addFrameBattleReview(builder, kgbA, 1, 2, 9);
        }
        if (kgbD != null) {
            addFrameBattleReview(builder, kgbD, 3, 4, 10);
        }
        if (kgbB != null) {
            addFrameBattleReview(builder, kgbB, 5, 6, 11);
        }
        if (kgbC != null) {
            addFrameBattleReview(builder, kgbC, 7, 8, 12);
        }
        Map<Integer, CompetGroup> cgmap = null;
        if (group == CrossConst.DF_Group) {
            cgmap = CrossFightCache.getDfFinalBattleGroups();
        } else {
            cgmap = CrossFightCache.getJyFinalBattleGroups();
        }
        CompetGroup cg = cgmap.get(3);
        if (cg != null) {
            ComptePojo c1 = cg.getC1();
            ComptePojo c2 = cg.getC2();
            if (c1 != null) {
                builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(13, c1.getNick(), c1.getServerId(), GameContext.gameServerMaps.get(c1.getServerId()).getName(), c1.getLevel(), c1.getFight(), c1.getPortrait()));
            }
            if (c2 != null) {
                builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(14, c2.getNick(), c2.getServerId(), GameContext.gameServerMaps.get(c2.getServerId()).getName(), c2.getLevel(), c2.getFight(), c2.getPortrait()));
            }
            // 获取获胜方
            ComptePojo cp = null;
            if (cg.getWin() == 1) {
                cp = cg.getC1();
            } else if (cg.getWin() == 0) {
                cp = cg.getC2();
            } else {
                // 平局战力高的晋级
                cp = getFightOver(cg.getC1(), cg.getC2());
            }
            builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(15, cp.getNick(), cp.getServerId(), GameContext.gameServerMaps.get(cp.getServerId()).getName(), cp.getLevel(), cp.getFight(), cp.getPortrait()));
        }
        return builder.build();
    }

    private void addFrameBattleReview(CrossFame.Builder builder, KnockoutBattleGroup kgb, int pos1, int pos2, int pos3) {
        CompetGroup cg = kgb.groupMaps.get(15);
        if (cg != null) {
            ComptePojo c1 = cg.getC1();
            ComptePojo c2 = cg.getC2();
            if (c1 != null) {
                builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(pos1, c1.getNick(), c1.getServerId(), GameContext.gameServerMaps.get(c1.getServerId()).getName(), c1.getLevel(), c1.getFight(), c1.getPortrait()));
            }
            if (c2 != null) {
                builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(pos2, c2.getNick(), c2.getServerId(), GameContext.gameServerMaps.get(c2.getServerId()).getName(), c2.getLevel(), c2.getFight(), c2.getPortrait()));
            }
            // 获取获胜方
            ComptePojo cp = null;
            if (cg.getWin() == 1) {
                cp = cg.getC1();
            } else if (cg.getWin() == 0) {
                cp = cg.getC2();
            } else {
                // 平局战力高的晋级
                cp = getFightOver(cg.getC1(), cg.getC2());
            }
            builder.addFameBattleReview(PbHelper.createFameBattleReviewPb(pos3, cp.getNick(), cp.getServerId(), GameContext.gameServerMaps.get(cp.getServerId()).getName(), cp.getLevel(), cp.getFight(), cp.getPortrait()));
        }
    }

    /**
     * 人气王
     *
     * @param group
     * @return
     */
    private Athlete getFames1(int group) {
        // 遍历淘汰赛的玩家，获取下注最多的
        LinkedHashMap<Long, Integer> map = new LinkedHashMap<Long, Integer>();
        Map<Integer, KnockoutBattleGroup> temp = null;
        if (group == CrossConst.DF_Group) {
            temp = CrossFightCache.getDfKnockoutBattleGroups();
        } else {
            temp = CrossFightCache.getJyKnockoutBattleGroups();
        }
        for (int i = 1; i <= 4; i++) {
            KnockoutBattleGroup kbg = temp.get(i);
            if (kbg != null) {
                for (int j = 1; j <= 15; j++) {
                    CompetGroup cg = kbg.groupMaps.get(j);
                    if (cg != null) {
                        ComptePojo c1 = cg.getC1();
                        ComptePojo c2 = cg.getC2();
                        if (c1 != null) {
                            if (map.containsKey(c1.getRoleId())) {
                                map.put(c1.getRoleId(), map.get(c1.getRoleId()) + c1.getBet());
                            } else {
                                map.put(c1.getRoleId(), c1.getBet());
                            }
                        }
                        if (c2 != null) {
                            if (map.containsKey(c2.getRoleId())) {
                                map.put(c2.getRoleId(), map.get(c2.getRoleId()) + c2.getBet());
                            } else {
                                map.put(c2.getRoleId(), c2.getBet());
                            }
                        }
                    }
                }
            }
        }
        crossDataManager.sortMapByBet(map);
        Athlete ret = null;
        for (Entry<Long, Integer> entry : map.entrySet()) {
            ret = CrossFightCache.getAthlete(entry.getKey());
            break;
        }
        return ret;
    }

    private void sendCrossPush(int serverId, int state) {
        CCSynCrossStateRq.Builder builder = CCSynCrossStateRq.newBuilder();
        builder.setState(state);
        Base.Builder msg = PbHelper.createSynBase(CCSynCrossStateRq.EXT_FIELD_NUMBER, CCSynCrossStateRq.ext, builder.build());
        if (serverId == 0) {
            for (Server server : GameContext.getGameServerConfig().getList()) {
                if (server.isConect()) {
                    GameContext.synMsgToPlayer(server.ctx, msg);
                }
            }
        } else {
            GameContext.synMsgToPlayer(GameContext.gameServerMaps.get(serverId).ctx, msg);
        }
    }

    private void sendGameChat(int moldId, int dayNum, String beginTime) {
        switch (moldId) {
            case MailType.MOLD_CROSS_PLAN:
                // 发送全服邮件
                sendGameMail(0, moldId, CrossConst.MailType.All, null, "明天凌晨", CrossConst.DF_Group_Base_Rank + "", CrossConst.JY_Group_Base_Rank + "");
                sendCrossPush(0, CrossConst.State.reg_begin);
                break;
            case MailType.MOLD_CROSS_REG:
                sendGameMail(0, moldId, CrossConst.MailType.SysAuto, null);
                break;
            case MailType.MOLD_JIFEN_PLAN:
                // 给报名的玩家发邮件
                sendRegPlayMail(MailType.MOLD_JIFEN_PLAN);
                break;
            case MailType.MOLD_KNOCK_PLAN:
                // 给参加淘汰赛的玩家发邮件
                sendKnockPlayMail(MailType.MOLD_KNOCK_PLAN, dayNum, beginTime);
                // 给所有玩家发邮件(下注)
                sendGameMail(0, MailType.MOLD_KNOCK_BET, CrossConst.MailType.All, null);
                break;
            case MailType.MOLD_FINAL_PLAN:
                // 给参加总决赛的玩家发邮件
                sendFinalPlayMail(MailType.MOLD_FINAL_PLAN);
                break;
            case MailType.MOLD_JIFEN_GET:
                // 给所有积分玩家发邮件
                sendJiFenPlay(MailType.MOLD_JIFEN_GET);
                break;
            default:
                break;
        }
    }

    /**
     * 给所有积分玩家发邮件
     *
     * @param moldId
     */
    private void sendJiFenPlay(int moldId) {
        Iterator<JiFenPlayer> its = CrossFightCache.getJifenPlayerMap().values().iterator();
        while (its.hasNext()) {
            JiFenPlayer a = its.next();
            if (a.getJifen() > 0) {
                sendGameMail(a.getServerId(), moldId, CrossConst.MailType.Person, a.getRoleId(), a.getJifen() + "");
            }
        }
    }

    /**
     * 给总决赛玩家发邮件
     *
     * @param moldId
     */
    private void sendFinalPlayMail(int moldId) {
        for (int i = 1; i <= 2; i++) {
            CompetGroup cg = CrossFightCache.getJyFinalBattleGroups().get(i);
            if (cg != null) {
                if (cg.getC1() != null) {
                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                }
                if (cg.getC2() != null) {
                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                }
            }
        }
        for (int i = 1; i <= 2; i++) {
            CompetGroup cg = CrossFightCache.getDfFinalBattleGroups().get(i);
            if (cg != null) {
                if (cg.getC1() != null) {
                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                }
                if (cg.getC2() != null) {
                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                }
            }
        }
    }

    /**
     * 给报名的玩家发邮件
     *
     * @param moldId
     */
    private void sendRegPlayMail(int moldId) {
        Iterator<Athlete> its = CrossFightCache.getAthleteMap().values().iterator();
        while (its.hasNext()) {
            Athlete a = its.next();
            sendGameMail(a.getServerId(), moldId, CrossConst.MailType.Person, a.getRoleId());
        }
    }

    /**
     * 给参加淘汰赛的玩家发邮件
     *
     * @param moldId
     */
    private void sendKnockPlayMail(int moldId, int dayNum, String beginTime) {
        if (dayNum == CrossConst.STAGE.STAGE_JIFEN1) {
            if (beginTime.equals("21:00:01")) {
                // 给16-8强发 (1-8组)
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getJyKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 1; j <= 8; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getDfKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 1; j <= 8; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
            }
        }
        // 淘汰赛第1天
        else if (dayNum == CrossConst.STAGE.STAGE_KNOCK1) {
            if (beginTime.equals("12:30:01")) {
                // 给8-4 发(9-12组)
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getJyKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 9; j <= 12; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getDfKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 9; j <= 12; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
            } else if (beginTime.equals("16:00:01")) {
                // 给4-2发(13,14组)
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getJyKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 13; j <= 14; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getDfKnockoutBattleGroups().get(i);
                    if (k != null) {
                        for (int j = 13; j <= 14; j++) {
                            CompetGroup cg = k.groupMaps.get(j);
                            if (cg != null) {
                                if (cg.getC1() != null) {
                                    sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                                }
                                if (cg.getC2() != null) {
                                    sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                                }
                            }
                        }
                    }
                }
            }
        } else if (dayNum == CrossConst.STAGE.STAGE_KNOCK1) {
            if (beginTime.equals("19:30:01")) {
                // 给2-1 发(15组)
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getJyKnockoutBattleGroups().get(i);
                    if (k != null) {
                        CompetGroup cg = k.groupMaps.get(15);
                        if (cg != null) {
                            if (cg.getC1() != null) {
                                sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                            }
                            if (cg.getC2() != null) {
                                sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                            }
                        }
                    }
                }
                for (int i = 1; i <= 4; i++) {
                    KnockoutBattleGroup k = CrossFightCache.getDfKnockoutBattleGroups().get(i);
                    if (k != null) {
                        CompetGroup cg = k.groupMaps.get(15);
                        if (cg != null) {
                            if (cg.getC1() != null) {
                                sendGameMail(cg.getC1().getServerId(), moldId, CrossConst.MailType.Person, cg.getC1().getRoleId());
                            }
                            if (cg.getC2() != null) {
                                sendGameMail(cg.getC2().getServerId(), moldId, CrossConst.MailType.Person, cg.getC2().getRoleId());
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * 发送全服奖励邮件
     */
    private void sendTopServerRewardMail() {
        LogUtil.info("发送全服奖励邮件");
        // 第一名
        Athlete dfTop1 = crossDataManager.getTop1(CrossConst.DF_Group);
        Athlete dfTop2 = crossDataManager.getTop2(CrossConst.DF_Group);
        Athlete dfTop3 = crossDataManager.getTop3(CrossConst.DF_Group);
        Athlete jyTop1 = crossDataManager.getTop1(CrossConst.JY_Group);
        Athlete jyTop2 = crossDataManager.getTop2(CrossConst.JY_Group);
        Athlete jyTop3 = crossDataManager.getTop3(CrossConst.JY_Group);
        if (dfTop1 != null) {
            sendGameMail(dfTop1.getServerId(), MailType.MOLD_TOP_SERVER_REWARD, CrossConst.MailType.All, null, dfTop1.getNick(), CrossConst.DF_Group + "");
        }
        if (dfTop2 != null) {
            sendGameMail(dfTop2.getServerId(), MailType.MOLD_TOP2_SERVER_REWARD, CrossConst.MailType.All, null, dfTop2.getNick(), CrossConst.DF_Group + "");
        }
        if (dfTop3 != null) {
            sendGameMail(dfTop3.getServerId(), MailType.MOLD_TOP3_SERVER_REWARD, CrossConst.MailType.All, null, dfTop3.getNick(), CrossConst.DF_Group + "");
        }
        if (jyTop1 != null) {
            sendGameMail(jyTop1.getServerId(), MailType.MOLD_TOP_SERVER_REWARD, CrossConst.MailType.All, null, jyTop1.getNick(), CrossConst.JY_Group + "");
        }
        if (jyTop2 != null) {
            sendGameMail(jyTop2.getServerId(), MailType.MOLD_TOP2_SERVER_REWARD, CrossConst.MailType.All, null, jyTop2.getNick(), CrossConst.JY_Group + "");
        }
        if (jyTop3 != null) {
            sendGameMail(jyTop3.getServerId(), MailType.MOLD_TOP3_SERVER_REWARD, CrossConst.MailType.All, null, jyTop3.getNick(), CrossConst.JY_Group + "");
        }
    }

    /**
     * 获取积分详情
     *
     * @param rq
     * @param handler
     */
    public void getCrossTrend(CCGetCrossTrendRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(roleId);
        CCGetCrossTrendRs.Builder builder = CCGetCrossTrendRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setCrossJifen(jp.getJifen() - jp.getExchangeJifen());
        for (CrossTrend ct : jp.crossTrends) {
            builder.addCrossTrend(PbHelper.createCrossTrendPb(ct));
        }
        handler.sendMsgToPlayer(CCGetCrossTrendRs.ext, builder.build());
    }

    /**
     * gm设置阵型
     *
     * @param rq
     * @param handler
     */
    public void gMSetCrossForm(CCGMSetCrossFormRq rq, ClientHandler handler) {
        Iterator<Athlete> its = CrossFightCache.getAthleteMap().values().iterator();
        int formNum = rq.getFormNum();
        while (its.hasNext()) {
            Athlete a = its.next();
            if (formNum == 1) {
                // 设置一个
                Form form = new Form();
                form.setType(FormType.Cross1);
                form.p[0] = 1;
                form.c[0] = 1;
                a.forms.put(form.getType(), form);
            } else {
                // 设置3个
                Form form1 = new Form();
                form1.setType(FormType.Cross1);
                form1.p[0] = 1;
                form1.c[0] = 1;
                a.forms.put(form1.getType(), form1);
                Form form2 = new Form();
                form2.setType(FormType.Cross2);
                form2.p[1] = 1;
                form2.c[1] = 1;
                a.forms.put(form2.getType(), form2);
                Form form3 = new Form();
                form3.setType(FormType.Cross3);
                form3.p[2] = 1;
                form3.c[2] = 1;
                a.forms.put(form3.getType(), form3);
            }
            CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(a.getRoleId());
            athleteTable.setAthlete(a);
            crossFightAthleteTableDao.update(athleteTable);
        }
    }

    public void heart(ClientHandler handler) {
        LogUtil.crossInfo("[跨服战或者跨服军团战] 收到心跳: {}", handler.getServerId());
        CCHeartRs.Builder builder = CCHeartRs.newBuilder();
        Base.Builder msg = PbHelper.createSynBase(CCHeartRs.EXT_FIELD_NUMBER, CCHeartRs.ext, builder.build());
        handler.sendMsgToPlayer(msg);
    }

    public void gMAddJifen(CCGMAddJiFenRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        int addJifen = rq.getAddJifen();
        int type = rq.getCcType();
        if (type == CrossConst.CrossType) {
            JiFenPlayer jp = CrossFightCache.getJifenPlayerMap().get(roleId);
            if (jp != null) {
                jp.setJifen(jp.getJifen() + addJifen);
                LogUtil.error(jp.getNick() + " gm命令增加积分 " + addJifen);
                crossDataManager.sortJiFen();
            }
            CrossFightPlayerJifenTable crossFightPlayerJifenTable = crossFightPlayerJifenTableDao.get(roleId);
            CommonPb.JiFenPlayer jifenPlayerPb = PbHelper.createJifenPlayerPb(jp, CrossFightCache.getDfKnockoutBattleGroups(), CrossFightCache.getJyKnockoutBattleGroups(), CrossFightCache.getJyFinalBattleGroups(), CrossFightCache.getDfFinalBattleGroups());
            crossFightPlayerJifenTable.setJifenInfo(jifenPlayerPb.toByteArray());
            crossFightPlayerJifenTableDao.update(crossFightPlayerJifenTable);
        } else if (type == CrossConst.CrossPartyType) {
            GameContext.getAc().getBean(CrossPartyService.class).gMAddJifen(serverId, roleId, addJifen);
        } else if (type == 3) {
            // 生成淘汰赛16强
            generateKnockOut16();
        }
    }
}