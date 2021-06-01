/**
 * @Title: WorldService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年9月11日 下午5:54:52
 * @version V1.0
 */
package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.Army;
import com.game.domain.p.ArmyStatu;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Collect;
import com.game.domain.p.Effect;
import com.game.domain.p.Form;
import com.game.domain.p.Friend;
import com.game.domain.p.Grab;
import com.game.domain.p.Hero;
import com.game.domain.p.Mail;
import com.game.domain.p.Prop;
import com.game.domain.p.RptTank;
import com.game.domain.p.Science;
import com.game.domain.p.Tank;
import com.game.domain.p.WorldStaffing;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.domain.s.friend.FriendlinessResourceRate;
import com.game.domain.sort.ActRedBag;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.honour.domain.HonourConstant;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.*;
import com.game.pb.GamePb1.SpeedQueRq;
import com.game.pb.GamePb1.SpeedQueRs;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.RefreshScoutImgRq;
import com.game.pb.GamePb6.RefreshScoutImgRs;
import com.game.rebel.domain.Rebel;
import com.game.server.GameServer;
import com.game.server.util.ChannelUtil;
import com.game.service.airship.AirshipService;
import com.game.service.crossmine.CrossSeniorMineService;
import com.game.util.*;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.*;

/**
 * @author ZhangJun
 * @ClassName: WorldService
 * @Description: 世界地图相关
 * @date 2015年9月11日 下午5:54:52
 */
@Service
public class WorldService {
    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private StaffingDataManager staffingDataManager;

    @Autowired
    private SeniorMineDataManager seniorMineDataManager;

    @Autowired
    private StaticRebelDataMgr staticRebelDataMgr;

    @Autowired
    private RebelDataManager rebelDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private HonourDataManager honourDataManager;

    @Autowired
    private StaticScoutDataMgr staticScoutDataMgr;

    @Autowired
    private FightService fightService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private WorldMineService mineService;

    @Autowired
    private AirshipService airshipService;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private FightLabService fightLabService;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private StatisticsService statisticsService;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private ActivityKingService activityKingService;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private StaticIniDataMgr staticIniDataMgr;
    @Autowired
    private RebelService rebelService;

    @Autowired
    private CrossSeniorMineService crossSeniorMineService;


    /**
     * Method: getMap
     *
     * @param handler
     * @return void
     * @throws @Description: 获取区域玩家数据
     */
    public void getMap(int area, ClientHandler handler) {

        GetMapRs.Builder builder = GetMapRs.newBuilder();
        List<Player> list = worldDataManager.getMap(area);
        Player p;
        if (list != null && !list.isEmpty()) {
            for (int i = 0; i < list.size(); i++) {
                p = list.get(i);
                String party = partyDataManager.getPartyNameByLordId(p.roleId);
                playerDataManager.replaceRuinsName(p);
                builder.addData(PbHelper.createMapDataPb(p, party));
            }
        }
        // 叛军信息
        if (rebelDataManager.isRebelStart()) {
            List<Rebel> rebelList = rebelDataManager.getRebelInArea(area);
            for (Rebel rebel : rebelList) {
                builder.addData(PbHelper.createMapDataPb(rebel));
            }
            List<Integer> boxPos = rebelDataManager.getBoxPosInArea(area);
            for (Integer pos : boxPos) {
                int count = worldDataManager.getRebelBoxMap().get(pos);
                builder.addData(PbHelper.createMapDataPb(pos, count));
            }
        }

        // 活动叛军信息
        List<ActRebelData> actRebelDataList = activityDataManager.getActRebelInArea(area);
        for (ActRebelData actRebelData : actRebelDataList) {
            builder.addData(PbHelper.createMapDataPb(actRebelData));
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int partyId = partyDataManager.getPartyId(player.roleId);

        // 世界地图矿点信息
        mineService.buildMineInfo(builder, player, area);
        List<Guard> guards = worldDataManager.getAreaMineGuard(area);

        if (guards != null) {

            // 矿上的驻军
            for (int i = 0; i < guards.size(); i++) {
                Guard guard = guards.get(i);

                if (partyId != 0) {
                    int id = partyDataManager.getPartyId(guard.getPlayer().roleId);
                    if (partyId == id) {
                        builder.addPartyMine(PbHelper.createPartyMinePb(guard.getPlayer().lord.getNick(), guard.getArmy().getTarget()));
                    }
                }

                if (guard.isFreeWar()) {
                    builder.addFreeTimeInfo(PbHelper.createWorldFreeTimeInfoPb((int) (guard.getFreeWarTime() / 1000),
                            guard.getArmy().getTarget(), player.roleId.longValue() == guard.getPlayer().roleId.longValue()));
                }

            }

        }

        builder.setArea(area);
        handler.sendMsgToPlayer(GetMapRs.ext, builder.build());
    }

    /**
     * 行军速度属性改变时调用 重新计算行军时间
     *
     * @param player void
     */
    public void recalcArmyMarch(Player player) {
        int state;
        int period;
        int originPeriod;
        Player targetPlayer;
        for (Army army : player.armys) {
            state = army.getState();
            if (state == ArmyState.MARCH) {
                originPeriod = army.getPeriod();
                period = marchTime(player, army.getTarget(), army.getType());
                if (originPeriod != period) {
                    army.setEndTime(army.getEndTime() - army.getPeriod() + period);
                    army.setPeriod(period);

                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));

                    targetPlayer = worldDataManager.getPosData(army.getTarget());
                    if (targetPlayer != null) {
                        playerDataManager.synArmyToPlayer(targetPlayer, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                    }
                }
            } else if (state == ArmyState.RETREAT) {
                originPeriod = army.getPeriod();
                period = marchTime(player, army.getTarget(), army.getType());
                if (originPeriod != period) {
                    army.setEndTime(army.getEndTime() - army.getPeriod() + period);
                    army.setPeriod(period);

                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                }
            } else if (state == ArmyState.AID) {
                originPeriod = army.getPeriod();
                period = partyMarchTime(player, army.getTarget());
                if (originPeriod != period) {
                    army.setEndTime(army.getEndTime() - army.getPeriod() + period);
                    army.setPeriod(period);

                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));

                    targetPlayer = worldDataManager.getPosData(army.getTarget());
                    if (targetPlayer != null) {
                        playerDataManager.synArmyToPlayer(targetPlayer, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                    }
                }
            }
        }
    }

    /**
     * Method: marchTime
     *
     * @param player
     * @param pos
     * @return int
     * @throws @Description: 世界地图行军时间
     */
    private int marchTime(Player player, int pos, int type) {
        Tuple<Integer, Integer> selfXy = WorldDataManager.reducePos(player.lord.getPos());
        Tuple<Integer, Integer> targetXy = WorldDataManager.reducePos(pos);
        // int time = 180 + Math.abs(selfXy.getA() - targetXy.getA()) +
        // Math.abs(selfXy.getB() - targetXy.getB());

        // int time = 180;
        // if (selfXy.getA() == targetXy.getA()) {// 横坐标相同
        // time += Math.round(Math.abs(selfXy.getB() - targetXy.getB()) * 7.5);
        // } else if (selfXy.getB() == targetXy.getB()) {// 纵坐标相同
        // time += Math.round(Math.abs(selfXy.getA() - targetXy.getA()) * 7.5);
        // } else {
        // time += Math.round((Math.abs(selfXy.getA() - targetXy.getA()) +
        // Math.abs(selfXy.getB() - selfXy.getA() + targetXy.getA() -
        // targetXy.getB())) * 7.5);
        // }

        int k = 1;
        if (selfXy.getA().intValue() != targetXy.getA().intValue()) {
            if ((selfXy.getB() - targetXy.getB()) / (float) (selfXy.getA() - targetXy.getA()) < 0) {
                k = -1;
            }
        }

        int time = 180 + Math.round((Math.abs(selfXy.getA() - targetXy.getA())
                + Math.abs(selfXy.getB() - k * selfXy.getA() + k * targetXy.getA() - targetXy.getB())) * 7.5f);

        // float factor = 1;
        int factor = NumberHelper.HUNDRED_INT;
        // 引擎强化科技
        Science science = player.sciences.get(ScienceId.ENGINE);
        if (science != null) {
            factor += science.getScienceLv() * 5;
        }

        if (player.effects.containsKey(EffectType.MARCH_SPEED)) {// 世界地图行军速度提升100%
            factor += NumberHelper.HUNDRED_INT;
        } else if (player.effects.containsKey(EffectType.MARCH_SPEED_SUPER)) {
            factor += 150;
        }

        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            factor += staticVip.getSpeedArmy();
        }

        Effect effect = player.effects.get(EffectType.ADD_MARCH_SPEED_PS);
        if (effect != null) {
            factor += 5;
        }
        effect = player.effects.get(EffectType.SUB_MARCH_SPEED_PS);
        if (effect != null) {
            factor += -50;
        }

        if (type == ArmyConst.ACT_REBEL) {
            factor += staticActivityDataMgr.getActRebel().getSpeedArmy();
        }

        // 作战实验室加成
        factor += fightLabService.getSpecilAttrAdd(player, AttrId.MARCHING_SPEED);

        // 荣耀生存buff更改行军速度
        int pos2 = player.lord.getPos();
        StaticHonourBuff honourBuff = honourDataManager.getHonourBuff(pos2);
        // 日常叛军活动行军不受影响
        if (honourBuff != null && type != ArmyConst.REBEL) {
            Map<Integer, Integer> attrBuff = honourBuff.getAttrBuff();
            if (attrBuff.containsKey(AttrId.MARCHING_SPEED)) {
                int honourAdd = honourBuff.getAttrBuff().get(AttrId.MARCHING_SPEED);
                if (honourBuff.getType() == -1) {
                    factor -= honourAdd;
                } else {
                    factor += honourAdd;
                }
            }
        }

        if (factor == 0) {
            factor = 1;
        }

        time = (int) (time * NumberHelper.HUNDRED_INT / factor);

        if (time < 1) {
            time = 1;
        }
        return time;
    }

    /**
     * Method: partyMarchTime
     *
     * @param player
     * @param pos
     * @return int
     * @throws @Description: 军团驻军行军时间
     */
    public int partyMarchTime(Player player, int pos) {
        Tuple<Integer, Integer> selfXy = WorldDataManager.reducePos(player.lord.getPos());
        Tuple<Integer, Integer> targetXy = WorldDataManager.reducePos(pos);
        int k = 1;
        if (selfXy.getA() != targetXy.getA()) {
            if ((selfXy.getB() - targetXy.getB()) / (float) (selfXy.getA() - targetXy.getA()) < 0) {
                k = -1;
            }
        }

        int time = 180 + Math.round((Math.abs(selfXy.getA() - targetXy.getA())
                + Math.abs(selfXy.getB() - k * selfXy.getA() + k * targetXy.getA() - targetXy.getB())) * 7.5f);

        // float factor = 1;
        int factor = NumberHelper.HUNDRED_INT;

        // 引擎强化科技
        Science science1 = player.sciences.get(ScienceId.ENGINE);
        if (science1 != null) {
            factor += science1.getScienceLv() * 5;
        }

        // 帮派科技，火线支援
        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science2 = sciences.get(ScienceId.PARTY_MARCH_TIME);
            if (science2 != null) {
                factor += science2.getScienceLv() * 10;
            }
        }

        if (player.effects.containsKey(EffectType.MARCH_SPEED)) {// 世界地图行军速度提升100%
            factor += NumberHelper.HUNDRED_INT;
        } else if (player.effects.containsKey(EffectType.MARCH_SPEED_SUPER)) {
            factor += 150;
        }

        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            factor += staticVip.getSpeedArmy();
        }

        // 荣耀生存buff更改行军速度
        int pos2 = player.lord.getPos();
        StaticHonourBuff honourBuff = honourDataManager.getHonourBuff(pos2);
        if (honourBuff != null) {
            Map<Integer, Integer> attrBuff = honourBuff.getAttrBuff();
            if (attrBuff.containsKey(AttrId.MARCHING_SPEED)) {
                int honourAdd = honourBuff.getAttrBuff().get(AttrId.MARCHING_SPEED);
                if (honourBuff.getType() == -1) {
                    factor -= honourAdd;
                } else {
                    factor += honourAdd;
                }
            }
        }

        time = (int) (time * NumberHelper.HUNDRED_INT / factor);

        if (time < 1) {
            time = 1;
        }
        return time;
    }

    // private int calcHarvest(Army army, int prodction) {
    // return (int) ((TimeHelper.getCurrentSecond() - army.getEndTime() +
    // army.getPeriod()) * prodction / (float) TimeHelper.HOUR_S);
    // }

    /**
     * 掠夺的资源量
     *
     * @param v       掠夺总资源量
     * @param protect 受保护的资源量
     * @return long
     */
    private long grabMax(long v, long protect) {
        if (v < protect) {
            return 0;
        }

        long max = v - protect;
        v = v / 10;

        return ((v > max) ? max : v);
    }

    /**
     * 创建战报里玩家部分（信息包括战损 将领 先手值什么的）
     *
     * @param player
     * @param hero
     * @param haust
     * @param prosAdd
     * @param mplt       null ：活动未开启，不初始化值
     * @param firstValue 先手值
     * @return
     */
    private CommonPb.RptMan createRptMan(Player player, int hero, Map<Integer, RptTank> haust, int prosAdd, Long mplt, int firstValue) {
        CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
        Lord lord = player.lord;
        builder.setPos(lord.getPos());
        builder.setName(lord.getNick());
        builder.setVip(lord.getVip());
        builder.setPros(lord.getPros());
        builder.setProsMax(lord.getProsMax());
        builder.setFirstValue(firstValue);
        if (mplt != null) {// null 表示功能未开启不初始化此值给Client
            builder.setMplt(mplt.intValue());
        }

        String party = partyDataManager.getPartyNameByLordId(player.roleId);
        if (party != null) {
            builder.setParty(party);
        }

        if (hero != 0) {
            builder.setHero(hero);
        }

        if (prosAdd != 0) {
            builder.setProsAdd(prosAdd);
        }

        if (haust != null) {
            // int militaryExploit = 0;
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 炸矿战斗后 战报里被炸玩家部分（信息包括战损 将领 先手值什么的）
     *
     * @param pos
     * @param staticMine
     * @param guard
     * @param hero
     * @param haust
     * @param mplt
     * @param first
     * @return CommonPb.RptMine
     */
    private CommonPb.RptMine createRptMine(int pos, StaticMine staticMine, Player guard, int hero, Map<Integer, RptTank> haust, Long mplt,
                                           int first) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        Lord lord = guard.lord;
        builder.setPos(pos);
        builder.setMine(staticMine.getType());
        builder.setLv(staticMine.getLv() + staffingDataManager.getWorldMineLevel());
        builder.setName(lord.getNick());
        builder.setVip(lord.getVip());
        builder.setFirstValue(first);
        if (mplt != null) {// null 表示功能未开启不初始化此值给Client
            builder.setMplt(mplt.intValue());
        }
        String party = partyDataManager.getPartyNameByLordId(guard.roleId);
        if (party != null) {
            builder.setParty(party);
        }

        if (hero != 0) {
            builder.setHero(hero);
        }

        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 打矿或者叛军的战报 现在只有打叛军用到了
     *
     * @param pos
     * @param lv
     * @param heroPick
     * @param haust
     * @param type
     * @param first
     * @return CommonPb.RptMine
     */
    private CommonPb.RptMine createRptRebel(int pos, int lv, int heroPick, Map<Integer, RptTank> haust, int type, int first) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        builder.setLv(lv);
        builder.setPos(pos);
        builder.setMine(type);// -1表示叛军
        builder.setHero(heroPick);
        builder.setFirstValue(first);
        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 打矿战报里 矿点NPC驻军部分
     *
     * @param pos
     * @param staticMine
     * @param haust
     * @param first
     * @return CommonPb.RptMine
     */
    private CommonPb.RptMine createRptMine(int pos, StaticMine staticMine, Map<Integer, RptTank> haust, int first) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        builder.setMine(staticMine.getType());
        builder.setLv(staticMine.getLv() + staffingDataManager.getWorldMineLevel());
        builder.setPos(pos);
        builder.setFirstValue(first);
        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 计算掠夺数量
     *
     * @param target
     * @param load
     * @return Grab
     */
    private Grab calcGrab(Player target, long load) {
        Grab grab = new Grab();
        long protect = playerDataManager.calcProtect(target);
        long stone = grabMax(target.resource.getStone(), protect);
        long iron = grabMax(target.resource.getIron(), protect);
        long silicon = grabMax(target.resource.getSilicon(), protect);
        long copper = grabMax(target.resource.getCopper(), protect);
        long oil = grabMax(target.resource.getOil(), protect);
        double total = stone + iron + silicon + copper + oil;
        if (load < total) {
            stone = (long) (stone / total * load);
            iron = (long) (iron / total * load);
            silicon = (long) (silicon / total * load);
            copper = (long) (copper / total * load);
            oil = (long) (oil / total * load);
        }

        grab.rs[0] = iron;
        grab.rs[1] = oil;
        grab.rs[2] = copper;
        grab.rs[3] = silicon;
        grab.rs[4] = stone;

        return grab;
    }

    /**
     * 计算所有资源掠夺量
     *
     * @param target
     * @return Grab
     */
    private Grab calcMaxGrab(Player target) {
        Grab grab = new Grab();
        long protect = playerDataManager.calcProtect(target);
        long stone = grabMax(target.resource.getStone(), protect);
        long iron = grabMax(target.resource.getIron(), protect);
        long silicon = grabMax(target.resource.getSilicon(), protect);
        long copper = grabMax(target.resource.getCopper(), protect);
        long oil = grabMax(target.resource.getOil(), protect);
        grab.rs[0] = iron;
        grab.rs[1] = oil;
        grab.rs[2] = copper;
        grab.rs[3] = silicon;
        grab.rs[4] = stone;
        return grab;
    }

    // private void changeArmyState(Player player, Army army, int state, int
    // now, int period) {
    // if (state == ArmyState.RETREAT) {
    // army.setState(state);
    // army.setPeriod(period);
    // army.setEndTime(now + period);
    // worldDataManager.removeMarch(player, army);
    // } else if (state == ArmyState.COLLECT) {
    // army.setState(state);
    // army.setPeriod(period);
    // army.setEndTime(now + period);
    // worldDataManager.removeMarch(player, army);
    // worldDataManager.setGuard(new Guard(player, army));
    // }
    // }

    /**
     * 部队返回
     *
     * @param player
     * @param army
     * @param now    void
     */
    private void retreatArmy(Player player, Army army, int now) {
        int marchTime = marchTime(player, army.getTarget(), army.getType());
        army.setState(ArmyState.RETREAT);
        army.setPeriod(marchTime);
        army.setEndTime(now + marchTime);
    }

    /**
     * 部队返回 同上
     *
     * @param player
     * @param army
     * @param now    void
     */
    private void retreatAidArmy(Player player, Army army, int now) {
        // int marchTime = partyMarchTime(player, army.getTarget());
        int marchTime = marchTime(player, army.getTarget(), army.getType());
        army.setState(ArmyState.RETREAT);
        army.setPeriod(marchTime);
        army.setEndTime(now + marchTime);
    }

    /**
     * 所有防守的部队返回
     *
     * @param player void
     */
    public void retreatAllGuard(Player player) {
        int now = TimeHelper.getCurrentSecond();
        int pos = player.lord.getPos();

        List<Guard> list = worldDataManager.getGuard(pos);
        if (list != null) {
            Army army;
            Player target;
            for (int i = 0; i < list.size(); i++) {
                Guard guard = list.get(i);
                target = guard.getPlayer();
                army = guard.getArmy();

                retreatAidArmy(player, army, now);

                playerDataManager.sendNormalMail(target, MailType.MOLD_RETREAT, now, player.lord.getNick());
                playerDataManager.synArmyToPlayer(target, new ArmyStatu(target.roleId, army.getKeyId(), 2));
            }
            list.clear();
        }

        for (Army e : player.armys) {
            int state = e.getState();
            if (state == ArmyState.GUARD || state == ArmyState.WAIT) {// 召回驻防
                worldDataManager.removeGuard(player, e);
                retreatArmy(player, e, TimeHelper.getCurrentSecond());
                Player target = worldDataManager.getPosData(e.getTarget());
                if (target != null) {
                    playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, e.getKeyId(), 2));
                }
            }
        }
    }

    /**
     * Method: collectArmy
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect    矿点每小时产量
     * @param get        已采集（或掠夺）资源所占载重
     * @return void
     * @throws @Description: 部队开始采集
     */
    private void collectArmy(Player player, Army army, int now, StaticMine staticMine, int collect, long get) {
        long load = playerDataManager.calcLoad(player, army.getForm(), army.isRuins());
        long loadFree = load;
        if (get > 0) {
            Grab grab = new Grab();
            if (load > get) {
                loadFree -= get;
                grab.rs[staticMine.getType() - 1] = get;
            } else {
                grab.rs[staticMine.getType() - 1] = loadFree;
                loadFree = 0;
            }

            army.setGrab(grab);
        }

        int speedAdd = 0;
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            speedAdd += staticVip.getSpeedCollect();
        }

        int heroId = army.getForm().getCommander();
        if (army.getForm().getAwakenHero() != null) {
            heroId = army.getForm().getAwakenHero().getHeroId();
        }
        StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
        if (staticHero != null && staticHero.getSkillId() == 5) {
            speedAdd += staticHero.getSkillValue();
        }

        Effect effect = player.effects.get(EffectType.ADD_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd += 5;
        }

        // 采集加速
        effect = player.effects.get(EffectType.COLLECT_SPEED_SUPER);
        if (effect != null) {
            speedAdd += 20;
        }

        effect = player.effects.get(EffectType.SUB_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd -= 10;
        }
        if (player.contributionWorldStaffing > 0) {
            speedAdd += staticWorldDataMgr.getWorldMineSpeed(player.contributionWorldStaffing);
        }

        // 荣耀玩法buff
        StaticHonourBuff buff = honourDataManager.getHonourBuff(army.getTarget());
        // 4阶段后下矿，采集加速
        if (buff != null && buff.getPhase() == 4 && buff.getType() == 1) {
            // 仅在缩圈完全结束后改buff才生效
            if (honourDataManager.getPhase() == 4) {
                speedAdd += buff.getResourceup();
            }
        }

        collect = (int) (collect * (1 + speedAdd / NumberHelper.HUNDRED_FLOAT));

        int collectTime = (int) (loadFree / (collect / (double) TimeHelper.HOUR_S));
        army.setState(ArmyState.COLLECT);
        army.setPeriod(collectTime);
        army.setEndTime(now + collectTime);
        army.setCollectBeginTime(now);
        army.setCaiJiStartTime(System.currentTimeMillis());
        army.setCaiJiEndTime(army.getEndTime() * 1000L);

        army.setStaffingTime(now + TimeHelper.HALF_HOUR_S);

        Collect c = new Collect();
        c.speed = speedAdd;
        c.load = load;
        army.setCollect(c);

        mineService.startCollectMine(player, army, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

        Guard guard = new Guard(player, army);

        long freeWarTime = 0;

        // 觉醒将领effect增加带兵量
        if (army.getForm().getAwakenHero() != null && !army.getForm().getAwakenHero().isUsed()) {
            for (Map.Entry<Integer, Integer> entry : army.getForm().getAwakenHero().getSkillLv().entrySet()) {
                if (entry.getValue() <= 0) {
                    continue;
                }
                StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                if (staticHeroAwakenSkill == null) {
                    LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                    continue;
                }
                if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_FREE_WAR_TIME) {
                    String val = staticHeroAwakenSkill.getEffectVal();
                    if (val != null && !val.isEmpty()) {
                        freeWarTime += Integer.parseInt(val) * 1000;
                    }
                }
            }
        }

        if (freeWarTime > 0) {
            guard.setFreeWarTime(System.currentTimeMillis() + freeWarTime);
            guard.setStartFreeWarTime(System.currentTimeMillis());
        }

        worldDataManager.setGuard(guard);
    }

    /**
     * 部队采集
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
     */
    public void recollectArmy(Player player, Army army, int now, StaticMine staticMine, int collect, long get) {
        // 先将已采集的荣耀积分存起来
        if (honourDataManager.isOpen()) {
            StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
            if (staticMineLv != null) {
                int honourScore1 = honourDataManager.calcHonourScore(army, now, staticMineLv.getHonourLiveScore(), army.getTarget());
                army.setHonourScore(honourScore1);
            }
        }

        long load = playerDataManager.calcLoad(player, army.getForm(), army.isRuins());
        // long grab = get;
        Grab grab = army.getGrab();
        if (grab == null) {
            grab = new Grab();
            army.setGrab(grab);
        }

        if (get > load) {
            grab.rs[staticMine.getType() - 1] = load;
        } else {
            grab.rs[staticMine.getType() - 1] = get;
        }

        int speedAdd = 0;
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            speedAdd += staticVip.getSpeedCollect();
        }

        Effect effect = player.effects.get(EffectType.ADD_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd += 5;
        }

        // 采集加速
        effect = player.effects.get(EffectType.COLLECT_SPEED_SUPER);
        if (effect != null) {
            speedAdd += 20;
        }

        effect = player.effects.get(EffectType.SUB_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd -= 10;
        }
        if (player.contributionWorldStaffing > 0) {
            speedAdd += staticWorldDataMgr.getWorldMineSpeed(player.contributionWorldStaffing);
        }
        // 荣耀玩法buff
        StaticHonourBuff buff = honourDataManager.getHonourBuff(army.getTarget());
        if (buff != null && buff.getPhase() == 4 && buff.getType() == 1) {
            // 仅在缩圈完全结束后改buff才生效
            if (honourDataManager.getPhase() == 4) {
                speedAdd += buff.getResourceup();
            }
        }

        int heroId = army.getForm().getCommander();
        if (army.getForm().getAwakenHero() != null) {
            heroId = army.getForm().getAwakenHero().getHeroId();
        }
        StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
        if (staticHero != null && staticHero.getSkillId() == 5) {
            speedAdd += staticHero.getSkillValue();
        }

        Collect c = army.getCollect();
        if (c != null) {
            c.load = load;
            c.speed = speedAdd;
        } else {
            c = new Collect();
            c.speed = speedAdd;
            c.load = load;
            army.setCollect(c);
        }

        long loadFree;
        if (get >= load) {// 已经获取的资源 大于 当前负载
            loadFree = 0;
        } else {
            loadFree = load - get;
        }

        collect = (int) (collect * (1 + speedAdd / NumberHelper.HUNDRED_FLOAT));

        int collectTime = (int) (loadFree / (collect / (double) TimeHelper.HOUR_S));
        army.setState(ArmyState.COLLECT);
        army.setPeriod(collectTime);
        army.setEndTime(now + collectTime);
        army.setCaiJiEndTime(army.getEndTime() * 1000L);
    }

    /**
     * 玩家点击部队返回
     *
     * @param keyId
     * @param handler void
     */
    public void retreat(int keyId, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        LinkedList<Army> armys = player.armys;
        if (armys == null || armys.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }
        boolean find = false;
        Army army = null;
        for (Army e : armys) {
            if (e.getKeyId() == keyId) {
                find = true;
                army = e;
                break;
            }
        }

        if (!find) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }

        int state = army.getState();
        if (state == ArmyState.RETREAT || state == ArmyState.MARCH) {
            handler.sendErrorMsgToPlayer(GameError.IN_MARCH);
            return;
        }

        RetreatRs.Builder builder = RetreatRs.newBuilder();
        int now = TimeHelper.getCurrentSecond();
        if (state == ArmyState.COLLECT) {
            if (!army.getSenior() && !army.isCrossMine()) {
                StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
                if (staticMine != null) {
                    StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
                    int produnction = staticMineLv.getProduction();
                    produnction = mineService.getMineProdunction(army.getTarget(), produnction);
                    long get = playerDataManager.calcCollect(player, army, now, staticMine, produnction);
                    int honourScore = honourDataManager.calcHonourScore(army, now, staticMineLv.getHonourLiveScore(), army.getTarget());
                    int honourGold = honourDataManager.calcHonourCollectGold(army, now / 60);
                    // 荣耀玩法buff
                    StaticHonourBuff buff = honourDataManager.getHonourBuff(army.getTarget());
                    int addtion = 100;
                    if (buff != null) {
                        if (buff.getType() == 1) {
                            addtion += buff.getScoreup();
                        } else {
                            addtion -= buff.getScoreup();
                        }
                        addtion = addtion < 0 ? 0 : addtion;
                    }
                    honourScore = (int) (honourScore * addtion / 100D);
                    Grab grab = new Grab();
                    grab.rs[staticMine.getType() - 1] = get;
                    army.setGrab(grab);
                    army.setHonourScore(honourScore);
                    army.setHonourGold(0);

                    // 加荣耀金币
                    playerDataManager.addGold(player, honourGold, AwardFrom.HONOUR_SURVIVE_BUFF);
                    worldDataManager.removeGuard(player, army);
                    // 增加矿点品质经验
                    mineService.addMineQualityExp(player, army.getTarget(), staticMine.getLv() + staffingDataManager.getWorldMineLevel(),
                            now - (army.getEndTime() - army.getPeriod()));

                    builder.setHonourGold(honourGold);


                    int heorGold = 0;

                    //新英雄攻打有玩家的矿掠夺的金币
                    if (army.getNewHeroAddGold() > 0) {

                        if (player.newHeroAddGoldTime == 0) {
                            player.newHeroAddGoldTime = System.currentTimeMillis();
                        }

                        if (!DateHelper.isToday(new Date(player.newHeroAddGoldTime))) {
                            player.newHeroAddGold = 0;
                            player.newHeroAddGoldTime = System.currentTimeMillis();
                        }
                        heorGold += army.getNewHeroAddGold();
                        playerDataManager.addGold(player, army.getNewHeroAddGold(), AwardFrom.NEW_BERO_LUE_GOLD);
                    }


                    //新英雄采集获得金币
                    Form form = army.getForm();
                    if (form != null) {
                        if (form.getCommander() != 0) {
                            StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
                            if (staticHero != null && staticHero.getTime() > 0 && staticHero.getSkillId() == 21) {
                                int newHeroGold = getNewHeroGold(player, army);
                                if (newHeroGold > 0) {
                                    heorGold += newHeroGold;
                                    playerDataManager.addGold(player, newHeroGold, AwardFrom.NEW_BERO_ADD_GOLD);
                                }
                            }
                        }
                    }

                    builder.setHeroGold(heorGold);
                    retreatArmy(player, army, now);
                } else {
                    // handler.sendErrorMsgToPlayer(GameError.IN_MARCH);
                    // return;
                    worldDataManager.removeGuard(player, army);
                    retreatArmy(player, army, now);
                }
            } else {
                StaticMine staticMine;
                long get;
                if (army.getSenior()) {
                    staticMine = seniorMineDataManager.evaluatePos(army.getTarget());
                    int production = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getProduction();
                    get = playerDataManager.calcCollect(player, army, now, staticMine, production);
                    if (staticMine != null) {
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
                } else if (army.isCrossMine()) {
                    staticMine = seniorMineDataManager.getCrossSeniorMine(army.getTarget());
                    StaticMineLv crossMineLvSenior = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv());
                    get = crossSeniorMineService.calcCollect(army, now, staticMine, crossMineLvSenior.getProduction());
                    if (staticMine != null) {
                        Grab grab = new Grab();
                        grab.rs[staticMine.getType() - 1] = get;
                        army.setGrab(grab);
                        playerDataManager.retreatEnd(player, army);
                        player.armys.remove(army);
                    } else {
                        playerDataManager.retreatEnd(player, army);
                        player.armys.remove(army);
                    }
                    crossSeniorMineService.retreatArmy(player.roleId, army.getTarget());
                }
            }
        } else if (state == ArmyState.GUARD || state == ArmyState.WAIT) {// 召回驻防
            worldDataManager.removeGuard(player, army);
            retreatArmy(player, army, now);
            Player target = worldDataManager.getPosData(army.getTarget());
            if (target != null) {
                playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 2));
            }
        } else if (state == ArmyState.AIRSHIP_BEGAIN || state == ArmyState.AIRSHIP_MARCH || state == ArmyState.AIRSHIP_GUARD_MARCH
                || state == ArmyState.AIRSHIP_GUARD) {
            if (!airshipService.retreatArishipTeamArmy(army, handler, builder)) {
                return;
            }
        }

        handler.sendMsgToPlayer(RetreatRs.ext, builder.build());
    }

    /**
     * 玩家点召回援助部队
     *
     * @param req
     * @param handler void
     */
    public void retreatAid(RetreatAidRq req, ClientHandler handler) {
        long targetId = req.getLordId();
        int keyId = req.getKeyId();
        Player target = playerDataManager.getPlayer(targetId);

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int pos = player.lord.getPos();

        boolean find = false;
        Army army = null;
        for (Army e : target.armys) {
            if (e.getKeyId() == keyId && e.getTarget() == pos) {
                find = true;
                army = e;
                break;
            }
        }

        if (!find) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }

        int state = army.getState();
        if (state != ArmyState.WAIT && state != ArmyState.GUARD) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        worldDataManager.removeGuard(target, army);

        int now = TimeHelper.getCurrentSecond();
        retreatAidArmy(target, army, now);

        playerDataManager.sendNormalMail(target, MailType.MOLD_RETREAT, now, player.lord.getNick());
        playerDataManager.synArmyToPlayer(target, new ArmyStatu(target.roleId, army.getKeyId(), 2));

        RetreatAidRs.Builder builder = RetreatAidRs.newBuilder();
        handler.sendMsgToPlayer(RetreatAidRs.ext, builder.build());
    }

    /**
     * 前往同军团的玩家基地进行驻军
     *
     * @param req
     * @param handler void
     */
    public void guardPos(GuardPosRq req, ClientHandler handler) {
        int pos = req.getPos();
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        partyDataManager.refreshMember(member);

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // GameServer.GAME_LOGGER.error("getAid roleId:" + handler.getRoleId());

        // if (player.armys.size() >= armyCount(player)) {
        // handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
        // return;
        // }


        int maxCount = playerDataManager.armyCount(player);
        if (playerDataManager.getPlayArmyCount(player, maxCount) >= maxCount + 1) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }

        Player target = worldDataManager.getPosData(pos);
        if (target == null) {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
            return;
        }

        if (player.roleId.intValue() == target.roleId) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (!partyDataManager.isSameParty(player.roleId, target.roleId)) {
            handler.sendErrorMsgToPlayer(GameError.NOT_SAME_PARTY);
            return;
        }

        Form attackForm = PbHelper.createForm(req.getForm());
        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (attackForm.getAwakenHero() != null) {// 使用觉醒将领
            awakenHero = player.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            attackForm.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (attackForm.getCommander() > 0) {
            hero = player.heros.get(attackForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            heroId = hero.getHeroId();
        }

        if (heroId != 0) {
            staticHero = staticHeroDataMgr.getStaticHero(heroId);
            if (staticHero == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            if (staticHero.getType() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
                return;
            }
        }
        //战术验证
        if (!attackForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(player, attackForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }
        int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
        if (!playerDataManager.checkAndSubTank(player, attackForm, maxTankCount, AwardFrom.GUARD_POS)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        if (hero != null) {
            playerDataManager.addHero(player, hero.getHeroId(), -1, AwardFrom.GUARD_POS);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.GUARD_POS, player.account, player.lord, awakenHero, 0);
        }

        //战术
        if (!attackForm.getTactics().isEmpty()) {
            tacticsService.useTactics(target, attackForm.getTactics());
        }

        int marchTime = partyMarchTime(player, pos);
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(player.maxKey(), pos, ArmyState.AID, attackForm, marchTime, now + marchTime,
                playerDataManager.isRuins(player));
        army.setIsZhuJun(1);
        player.armys.add(army);
        March march = new March(player, army);
        worldDataManager.addMarch(march);

        PartyDataManager.doPartyLivelyTask(partyData, member, PartyType.TASK_ARMY);
        playerDataManager.updTask(player, TaskType.COND_PARTY_GUARD, 1, null);

        GuardPosRs.Builder builder = GuardPosRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(GuardPosRs.ext, builder.build());

        playerDataManager.synInvasionToPlayer(target, march);
    }

    /**
     * 设置防守
     *
     * @param req
     * @param handler void
     */
    public void setGuard(SetGuardRq req, ClientHandler handler) {
        long lordId = req.getLordId();
        int keyId = req.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (lordId == 0) {// 撤防
            Guard guard = worldDataManager.getHomeGuard(player.lord.getPos());
            if (guard == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
                return;
            }

            guard.getArmy().setState(ArmyState.WAIT);
        } else {// 上防
            List<Guard> list = worldDataManager.getGuard(player.lord.getPos());
            boolean find = false;
            boolean hadOld = false;
            Guard oldGuard = null;
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    oldGuard = list.get(i);
                    if (oldGuard.getArmy().getState() == ArmyState.GUARD) {
                        oldGuard.getArmy().setState(ArmyState.WAIT);
                        hadOld = true;
                    }
                }

                for (int i = 0; i < list.size(); i++) {
                    Guard guard = list.get(i);
                    if (guard.getPlayer().roleId == lordId && guard.getArmy().getKeyId() == keyId
                            && guard.getArmy().getState() == ArmyState.WAIT) {
                        guard.getArmy().setState(ArmyState.GUARD);
                        find = true;
                    }
                }
            }

            if (!find) {
                if (hadOld) {
                    oldGuard.getArmy().setState(ArmyState.GUARD);
                }
                handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
                return;
            }
        }

        SetGuardRs.Builder builder = SetGuardRs.newBuilder();
        handler.sendMsgToPlayer(SetGuardRs.ext, builder.build());
    }

    /**
     * 移动基地
     *
     * @param req
     * @param handler void
     */
    public void moveHome(MoveHomeRq req, ClientHandler handler) {
        int type = req.getType();
        int pos = -1;
        if (type == 1) {// 金币
            if (!req.hasPos()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            pos = req.getPos();

            if (!worldDataManager.isValidPos(pos)) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_POS);
                return;
            }

            Player player = playerDataManager.getPlayer(handler.getRoleId());
            if (player.lord.getGold() < 88) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            Player target = worldDataManager.getPosData(pos);
            if (target != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            StaticMine staticMine = worldDataManager.evaluatePos(pos);
            if (staticMine != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            // 检查是否被叛军占据
            Rebel rebel = rebelDataManager.getRebelByPos(pos);
            if (rebel != null && rebelDataManager.isRebelStart()) {
                // if(worldDataManager.isRebel(pos)) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            // 活动叛军
            ActRebelData actRebelData = activityDataManager.getActRebelByPos(pos);
            if (actRebelData != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            if (worldDataManager.isAirship(pos)) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            playerDataManager.subGold(player, 88, AwardFrom.MOVE_HOME);

            int oldPos = player.lord.getPos();
            List<Guard> list = worldDataManager.getGuard(oldPos);
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    Guard guard = list.get(i);
                    guard.getArmy().setTarget(pos);
                    worldDataManager.setGuard(guard);
                }
            }

            worldDataManager.removeGuard(oldPos);
            worldDataManager.removePos(oldPos);

            player.lord.setPos(pos);
            worldDataManager.putPlayer(player);

            MoveHomeRs.Builder builder = MoveHomeRs.newBuilder();
            builder.setPos(pos);
            builder.setGold(player.lord.getGold());
            handler.sendMsgToPlayer(MoveHomeRs.ext, builder.build());
        } else if (type == 2) {// 2.道具(随机)
            Player player = playerDataManager.getPlayer(handler.getRoleId());
            Prop prop = player.props.get(PropId.MOVE_HOME_2);
            if (prop == null || prop.getCount() < 1) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            playerDataManager.subProp(player, prop, 1, AwardFrom.MOVE_HOME);

            while (true) {
                pos = RandomHelper.randomInSize(600 * 600);
                Player target = worldDataManager.getPosData(pos);
                if (target != null) {
                    continue;
                }

                StaticMine staticMine = worldDataManager.evaluatePos(pos);
                if (staticMine != null) {
                    continue;
                }

                if (!worldDataManager.isValidPos(pos)) {
                    continue;
                }

                if (rebelDataManager.isRebelStart()) {// 叛军活动结束前，叛军所在坐标（即使叛军已经死亡）不允许迁入
                    Rebel rebel = rebelDataManager.getRebelByPos(pos);
                    if (null != rebel) {
                        continue;
                    }
                }

                // 活动叛军
                ActRebelData actRebelData = activityDataManager.getActRebelByPos(pos);
                if (actRebelData != null) {
                    continue;
                }

                if (worldDataManager.isAirship(pos)) {
                    handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                    return;
                }

                int oldPos = player.lord.getPos();
                List<Guard> list = worldDataManager.getGuard(oldPos);
                if (list != null) {
                    for (int i = 0; i < list.size(); i++) {
                        Guard guard = list.get(i);
                        guard.getArmy().setTarget(pos);
                        worldDataManager.setGuard(guard);
                    }
                }

                worldDataManager.removeGuard(oldPos);
                worldDataManager.removePos(oldPos);

                player.lord.setPos(pos);
                worldDataManager.putPlayer(player);
                break;
            }

            MoveHomeRs.Builder builder = MoveHomeRs.newBuilder();
            builder.setPos(pos);
            builder.setGold(player.lord.getGold());
            handler.sendMsgToPlayer(MoveHomeRs.ext, builder.build());
        } else if (type == 3) {// 3.道具(定点)
            if (!req.hasPos()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            pos = req.getPos();

            if (!worldDataManager.isValidPos(pos)) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_POS);
                return;
            }

            Player player = playerDataManager.getPlayer(handler.getRoleId());
            Prop prop = player.props.get(PropId.MOVE_HOME_1);
            if (prop == null || prop.getCount() < 1) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            Player target = worldDataManager.getPosData(pos);
            if (target != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            StaticMine staticMine = worldDataManager.evaluatePos(pos);
            if (staticMine != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            // 检查是否被叛军占据
            Rebel rebel = rebelDataManager.getRebelByPos(pos);
            if (rebel != null && rebelDataManager.isRebelStart()) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            // 活动叛军
            ActRebelData actRebelData = activityDataManager.getActRebelByPos(pos);
            if (actRebelData != null) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            if (worldDataManager.isAirship(pos)) {
                handler.sendErrorMsgToPlayer(GameError.POS_NOT_EMPTY);
                return;
            }

            playerDataManager.subProp(player, prop, 1, AwardFrom.MOVE_HOME);

            int oldPos = player.lord.getPos();
            List<Guard> list = worldDataManager.getGuard(oldPos);
            if (list != null) {
                for (int i = 0; i < list.size(); i++) {
                    Guard guard = list.get(i);
                    guard.getArmy().setTarget(pos);
                    worldDataManager.setGuard(guard);
                }
            }

            worldDataManager.removeGuard(oldPos);
            worldDataManager.removePos(oldPos);

            player.lord.setPos(pos);
            worldDataManager.putPlayer(player);

            MoveHomeRs.Builder builder = MoveHomeRs.newBuilder();
            builder.setPos(pos);
            builder.setGold(player.lord.getGold());
            handler.sendMsgToPlayer(MoveHomeRs.ext, builder.build());
        }
    }

    /**
     * 侦查矿点
     *
     * @param player
     * @param pos
     * @param handler void
     */
    private void scoutMine(Player player, int pos, ClientHandler handler) {
        StaticMine staticMine = worldDataManager.evaluatePos(pos);

        if (staticMine != null) {
            int lv = staticMine.getLv();
            // 10分钟内最多侦查3次
            int curSec = TimeHelper.getCurrentSecond();
            LinkedList<Integer> logScoutTime = player.plugInCheck.getLogScoutTime();
            int logSize = logScoutTime.size();
            if (logSize >= Constant.SCOUT_MINE_PLUG_IN_COUNT) {
                int lastTime = logScoutTime.getFirst();
                if (curSec - lastTime <= Constant.SCOUT_MINE_PLUG_IN_TIME_SEC) {
                    String validCode = RandomStringUtils.randomNumeric(4);
                    player.plugInCheck.setScoutMineValidCode(validCode);
                    StcHelper.synPlugInScoutMineChecker(player, validCode);
                    return;
                }
            }

            Lord lord = player.lord;
            int scount = lord.getScount() + 1;
            long scountCost = worldDataManager.getScoutNeedStone(lord, staticMine.getLv() + staffingDataManager.getWorldMineLevel(), 1);
            if (player.resource.getStone() < scountCost) {
                handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
                return;
            }
            lord.setScount(scount);
            RptScoutMine.Builder rptMine = RptScoutMine.newBuilder();
            playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_MINE);
            StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
            int product = staticMineLv.getProduction();
            lv = staticMineLv.getLv();

            product = mineService.getMineProdunction(pos, product);
            int now = TimeHelper.getCurrentSecond();
            Guard guard = worldDataManager.getMineGuard(pos);
            int honourScore = 0;
            int honourGold = 0;
            if (guard != null) {// 有驻军
                if (staticMineLv == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                if (honourDataManager.isOpen()) {
                    honourScore = honourDataManager.calcHonourScore(guard.getArmy(), TimeHelper.getCurrentSecond(),
                            staticMineLv.getHonourLiveScore(), pos);
                    honourGold = honourDataManager.calcHonourCollectGold(guard.getArmy(), TimeHelper.getCurrentMinute());
                }
                rptMine.setForm(PbHelper.createFormPb(guard.getArmy().getForm()));
                String partyName = partyDataManager.getPartyNameByLordId(guard.getPlayer().roleId);
                if (partyName != null) {
                    rptMine.setParty(partyName);
                }
                rptMine.setFriend(guard.getPlayer().lord.getNick());
                rptMine.setHarvest(playerDataManager.calcCollect(guard.getPlayer(), guard.getArmy(), now, staticMine, product));


                //新英雄采集获得金币
                Form form = guard.getArmy().getForm();
                if (form != null) {
                    if (form.getCommander() != 0) {
                        StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
                        if (staticHero != null && staticHero.getTime() > 0 && staticHero.getSkillId() == 21) {
                            int newHeroGold = getNewHeroGold(guard.getPlayer(), guard.getArmy()) + guard.getArmy().getNewHeroAddGold();
                            if (newHeroGold > 0) {
                                rptMine.setNewHeroGold(newHeroGold);
                            }
                        } else {
                            if (guard.getArmy().getNewHeroAddGold() > 0) {
                                rptMine.setNewHeroGold(guard.getArmy().getNewHeroAddGold());
                            }
                        }
                    }
                }

            } else {// 无驻军
                // rptMine.setForm(PbHelper.createFormPb(worldDataManager.getMineForm(pos,
                // staticMine.getLv())));
                rptMine.setForm(PbHelper.createFormPb(worldDataManager.getMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel()).getForm()));
            }

            if (honourDataManager.isOpen()) {
                rptMine.setHonourScore(honourScore);
                if (honourDataManager.getPhase() == 4 && honourDataManager.isInSafeArea(pos) == 1) {
                    rptMine.setHonourGold(honourGold);
                }
            }

            rptMine.setPos(pos);
            rptMine.setLv(lv);
            rptMine.setProduct(product);
            rptMine.setMine(staticMine.getType());

            Report.Builder report = Report.newBuilder();
            report.setScoutMine(rptMine);
            report.setTime(now);

            // 记录对该矿点的侦查信息
            mineService.scoutMine(player, pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

            Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.MOLD_SCOUT_MINE, TimeHelper.getCurrentSecond(),
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            ScoutPosRs.Builder builder = ScoutPosRs.newBuilder();
            builder.setMail(PbHelper.createMailPb(mail));
            builder.setScoutCount(player.lord.getScount());
            handler.sendMsgToPlayer(ScoutPosRs.ext, builder.build());

            // 记录玩家的侦查行为,10分钟最多侦查3次，如果超过3次则被认为是外挂行为
            logScoutTime.add(now);
            while (logScoutTime.size() > Constant.SCOUT_MINE_PLUG_IN_COUNT) {
                logScoutTime.removeFirst();
            }
        } else {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
        }

    }

    /**
     * 侦查叛军
     *
     * @param player
     * @param pos
     * @param handler void
     */
    private void scoutRebel(Player player, int pos, ClientHandler handler) {
        Rebel rebel = rebelDataManager.getRebelByPos(pos);
        int multiple = 1;
        if (rebel.getType() == RebelConstant.REBEL_TYPE_GUARD) {
            multiple = 2;
        } else if (rebel.getType() == RebelConstant.REBEL_TYPE_LEADER) {
            multiple = 3;
        }
        Lord lord = player.lord;
        int scount = lord.getScount() + 1;
        long scountCost = worldDataManager.getScoutNeedStone(lord, rebel.getRebelLv(), multiple);
        if (player.resource.getStone() < scountCost) {// 检查侦查次数是否足够
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }
        lord.setScount(scount);
        playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_REBEL);

        Report.Builder report = Report.newBuilder();
        int now = TimeHelper.getCurrentSecond();
        report.setTime(now);

        RptScoutRebel.Builder rptRebel = RptScoutRebel.newBuilder();
        rptRebel.setPos(pos);
        rptRebel.setLv(rebel.getRebelLv());
        rptRebel.setRebelId(rebel.getRebelId());
        rptRebel.setHeroPick(rebel.getHeroPick());
        rptRebel.setForm(PbHelper.createFormPb(worldDataManager.getRebelForm(pos)));
        report.setScoutRebel(rptRebel);

        Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.MOLD_REBEL_SCOUT, TimeHelper.getCurrentSecond(),
                String.valueOf(rebel.getHeroPick()), String.valueOf(rebel.getRebelLv()));
        ScoutPosRs.Builder builder = ScoutPosRs.newBuilder();
        builder.setMail(PbHelper.createMailPb(mail));
        handler.sendMsgToPlayer(ScoutPosRs.ext, builder.build());
    }

    /**
     * 侦查活动叛军
     *
     * @param player
     * @param pos
     * @param handler void
     */
    private void scoutActRebel(Player player, int pos, ClientHandler handler) {
        ActRebelData rebel = activityDataManager.getActRebelByPos(pos);
        Lord lord = player.lord;
        int scount = lord.getScount() + 1;
        long scountCost = worldDataManager.getScoutNeedStone(lord, rebel.getRebelLv(), 1);
        if (player.resource.getStone() < scountCost) {// 检查侦查次数是否足够
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }
        lord.setScount(scount);
        playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_REBEL);

        Report.Builder report = Report.newBuilder();
        int now = TimeHelper.getCurrentSecond();
        report.setTime(now);

        RptScoutRebel.Builder rptRebel = RptScoutRebel.newBuilder();
        rptRebel.setPos(pos);
        rptRebel.setLv(rebel.getRebelLv());
        rptRebel.setRebelId(rebel.getRebelId());
        rptRebel.setHeroPick(ActRebelConst.REBEL_TYPE_ACT);
        rptRebel.setForm(PbHelper.createFormPb(worldDataManager.getActRebelForm(pos)));
        report.setScoutRebel(rptRebel);

        Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.MOLD_ACT_REBEL_SCOUT, TimeHelper.getCurrentSecond(),
                String.valueOf(rebel.getRebelId()), String.valueOf(rebel.getRebelLv()));
        ScoutPosRs.Builder builder = ScoutPosRs.newBuilder();
        builder.setMail(PbHelper.createMailPb(mail));
        handler.sendMsgToPlayer(ScoutPosRs.ext, builder.build());
    }

    /**
     * 侦查基地
     *
     * @param player
     * @param target
     * @param handler void
     */
    private void scoutHome(Player player, Player target, ClientHandler handler) {
        if (target.effects.containsKey(EffectType.ATTACK_FREE)) {
            handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
            return;
        }
        Lord lord = target.lord;
        int scount = player.lord.getScount() + 1;
        long scountCost = worldDataManager.getScoutNeedStone(player.lord, lord.getLevel(), 1);
        if (player.resource.getStone() < scountCost) {
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }
        player.lord.setScount(scount);
        playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_HOME);

        RptScoutHome.Builder rptHome = RptScoutHome.newBuilder();
        rptHome.setPos(lord.getPos());
        rptHome.setLv(lord.getLevel());
        rptHome.setName(lord.getNick());
        rptHome.setPros(lord.getPros());
        rptHome.setProsMax(lord.getProsMax());
        String party = partyDataManager.getPartyNameByLordId(target.roleId);
        if (party != null) {
            rptHome.setParty(party);
        }

        Guard guard = worldDataManager.getHomeGuard(lord.getPos());
        if (guard != null) {// 有驻军
            // GameServer.ERROR_LOGGER.error("Guard player:" +
            // guard.getPlayer().lord.getNick() + "|pos:" +
            // guard.getPlayer().lord.getPos());
            rptHome.setFriend(guard.getPlayer().lord.getNick());
            rptHome.setForm(PbHelper.createFormPb(guard.getArmy().getForm()));
        } else {
            Form targetForm = playerDataManager.getHomeDefendForm(target);
            if (targetForm != null) {
                rptHome.setForm(PbHelper.createFormPb(targetForm));
            }
        }

        int now = TimeHelper.getCurrentSecond();
        Grab grab = calcMaxGrab(target);
        rptHome.setGrab(PbHelper.createGrabPb(grab));

        Report.Builder report = Report.newBuilder();
        report.setScoutHome(rptHome);
        report.setTime(now);

        Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.MOLD_SCOUT_PLAYER, now, lord.getNick(),
                String.valueOf(lord.getLevel()));

        ScoutPosRs.Builder builder = ScoutPosRs.newBuilder();
        builder.setMail(PbHelper.createMailPb(mail));
        builder.setScoutCount(player.lord.getScount());
        handler.sendMsgToPlayer(ScoutPosRs.ext, builder.build());
    }

    /**
     * Method: scout
     *
     * @param pos
     * @param handler
     * @return void
     * @throws @Description: 侦查
     */
    public void scoutPos(int pos, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player.scoutFreeTime > System.currentTimeMillis()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        int count = player.VCODE_SCOUT_COUNT == 0 ? 1 : player.VCODE_SCOUT_COUNT;
        if (player.isVerification == 0 || player.isVerification % count == 0) {
            if (player.isVerification != 0 && player.isVerificationState != 1 && staticFunctionPlanDataMgr.isVcodeScoutOpen()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
            player.VCODE_SCOUT_COUNT = Constant.VCODE_SCOUT_COUNT + new Random().nextInt(10);
        }
        player.isVerification = player.isVerification + 1;
        // 检查并重置侦查次数
        int nowDay = TimeHelper.getCurrentDay();
        playerService.checkAndResetScount(player, nowDay);

        if (worldDataManager.isRebel(pos)) {// 侦查叛军
            scoutRebel(player, pos, handler);
            return;
        }

        if (worldDataManager.isActRebel(pos)) {// 侦查活动叛军
            scoutActRebel(player, pos, handler);
            return;
        }

        // 记录设备侦查矿点次数
        statisticsService.increaseScoutMineCount(player);

        Player target = worldDataManager.getPosData(pos);
        if (target != null) {
            scoutHome(player, target, handler);
            LogLordHelper.logScoutPos(AwardFrom.SCOUT_HOME, player, ChannelUtil.getIp(player.ctx, player.roleId),
                    player.account.getDeviceNo(), player.lord.getOlTime(), pos);
        } else {
            scoutMine(player, pos, handler);
            LogLordHelper.logScoutPos(AwardFrom.SCOUT_MINE, player, ChannelUtil.getIp(player.ctx, player.roleId),
                    player.account.getDeviceNo(), player.lord.getOlTime(), pos);
        }

    }

    // private int armyCount(Player player) {
    // StaticVip staticVip =
    // staticVipDataMgr.getStaticVip(player.lord.getVip());
    // if (staticVip != null) {
    // return staticVip.getArmyCount();
    // }
    // return 3;
    // }

    /**
     * @param req
     * @param handler void
     * @throws @Title: attackPos
     * @Description: 攻打玩家/攻打资源/攻打流寇/攻打叛军
     */
    public void attackPos(AttackPosRq req, ClientHandler handler) {
        int pos = req.getPos();
        if (pos < 0 || pos > 360000) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Player attacker = playerDataManager.getPlayer(handler.getRoleId());
        if (attacker == null) {
            LogUtil.error("attackPos is null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
            return;
        }
        removeExpireHero(attacker, 0);
        if (attacker.lord.getPower() < 1) {
            handler.sendErrorMsgToPlayer(GameError.NO_POWER);
            return;
        }
        if (attacker.lord.getLevel() < 2) {
            handler.sendErrorMsgToPlayer(GameError.LEFT_ONE_MEMBER);
            return;
        }
        int maxCount = playerDataManager.armyCount(attacker);
        if (playerDataManager.getPlayArmyCount(attacker, maxCount) >= maxCount) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }
        int type;
        Player defencer = null;
        StaticMine staticMine = worldDataManager.evaluatePos(pos);
        // 打矿
        if (staticMine != null) {
            // 记录设备攻击矿点次数
            statisticsService.increaseAttackMineCount(attacker);
            Guard guard = worldDataManager.getMineGuard(pos);
            if (guard != null) {// 有驻军

                if (guard.isFreeWar()) {
                    handler.sendErrorMsgToPlayer(GameError.HERO_FREEWAR_TIME);
                    return;
                }

                Player guarder = guard.getPlayer();
                if (attacker == guarder) {
                    handler.sendErrorMsgToPlayer(GameError.IN_COLLECT);
                    return;
                } else {
                    if (partyDataManager.isSameParty(attacker.roleId, guarder.roleId)) {
                        handler.sendErrorMsgToPlayer(GameError.IN_SAME_PARTY);
                        return;
                    }
                }
            }
            type = ArmyConst.MINE;
            playerDataManager.updTask(attacker, TaskType.COND_ATTACK_RESOURCE, 1, staticMine.getLv() + staffingDataManager.getWorldMineLevel());
        } else if (worldDataManager.isRebel(pos)) {// 打叛军
            type = ArmyConst.REBEL;
            Rebel rebel = rebelDataManager.getRebelByPos(pos);
            if (rebel.getType() != RebelConstant.REBEL_TYPE_BOOS) {
                if (rebelDataManager.killNumIsMax(handler.getRoleId())) {// 叛军活动，有单次击杀上限
                    handler.sendErrorMsgToPlayer(GameError.REBEL_KILL_LIMIT);
                    return;
                }
            }
        } else if (worldDataManager.isActRebel(pos)) {// 打活动叛军
            type = ArmyConst.ACT_REBEL;
        } else {
            // 打人
            defencer = worldDataManager.getPosData(pos);
            if (defencer == null) {
                handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
                return;
            }

            if (attacker.roleId.longValue() == defencer.roleId) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            if (partyDataManager.isSameParty(attacker.roleId, defencer.roleId)) {
                handler.sendErrorMsgToPlayer(GameError.IN_SAME_PARTY);
                return;
            }

            if (defencer.effects.containsKey(EffectType.ATTACK_FREE)) {
                //破罩英雄
                boolean isbln = false;
                CommonPb.Form form = req.getForm();
                if (form != null) {
                    int commander = form.getCommander();
                    StaticHero staticHero = staticHeroDataMgr.getStaticHero(commander);
                    if (staticHero != null && staticHero.getSkillId() == 22) {

                        Hero hero = attacker.heros.get(staticHero.getHeroId());

                        if (hero == null || (hero.getEndTime() > 0 && hero.getEndTime() < System.currentTimeMillis())) {
                            handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                            return;
                        }

                        if (hero != null) {
                            if (hero.getCd() > System.currentTimeMillis()) {
                                handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
                                return;
                            }
                            isbln = true;
                            //技能cd英雄
                            long cd = System.currentTimeMillis() + Constant.NEW_HERO_CD * 60 * 1000L;
                            attacker.herosCdTime.put(staticHero.getHeroId(), cd);
                            hero.setCd(cd);
                        }


                    }

                }

                if (!isbln) {
                    handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
                    return;
                }
            }
            type = ArmyConst.OTH_PLAYER;
            playerDataManager.updTask(attacker, TaskType.COND_ATTACK_PLAYER, 1, null);
        }

        Form attackForm = PbHelper.createForm(req.getForm());
        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (attackForm.getAwakenHero() != null) {// 使用觉醒将领
            awakenHero = attacker.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            attackForm.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (attackForm.getCommander() > 0) {
            hero = attacker.heros.get(attackForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            heroId = hero.getHeroId();
        }

        if (heroId != 0) {
            staticHero = staticHeroDataMgr.getStaticHero(heroId);
            if (staticHero == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            if (staticHero.getType() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
                return;
            }
        }
        //战术验证
        if (!attackForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(attacker, attackForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }

        int maxTankCount = playerDataManager.formTankCount(attacker, staticHero, awakenHero);

        if (!playerDataManager.checkAndSubTank(attacker, attackForm, maxTankCount, AwardFrom.ATTACK_POS)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }


        playerDataManager.subPower(attacker.lord, 1);

        if (hero != null) {
            playerDataManager.addHero(attacker, hero.getHeroId(), -1, AwardFrom.ATTACK_POS);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.ATTACK_POS, attacker.account, attacker.lord, awakenHero, 0);
        }


        //战术
        if (!attackForm.getTactics().isEmpty()) {
            tacticsService.useTactics(attacker, attackForm.getTactics());
        }


        int marchTime = marchTime(attacker, pos, type);
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(attacker.maxKey(), pos, ArmyState.MARCH, attackForm, marchTime, now + marchTime,
                playerDataManager.isRuins(attacker));
        attacker.armys.add(army);
        army.setType(type);
        army.setTarQua(mineService.getMineQualityWithScout(attacker, army.getTarget()));

        March march = new March(attacker, army);
        worldDataManager.addMarch(march);

        if (staticMine == null && !worldDataManager.isRebel(pos) && !worldDataManager.isActRebel(pos)) {

            //添加一个 删除保护罩buff的日志
            if (attacker.effects.containsKey(EffectType.ATTACK_FREE)) {
                Effect effect = attacker.effects.get(EffectType.ATTACK_FREE);
                LogLordHelper.attackFreeBuff(AwardFrom.DO_SOME, attacker, 2, 0, effect.getEndTime(), pos);
                playerDataManager.clearAttackFree(attacker);
            }

        }

        AttackPosRs.Builder builder = AttackPosRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(AttackPosRs.ext, builder.build());
        if (staticMine == null && !worldDataManager.isRebel(pos) && !worldDataManager.isActRebel(pos)) {
            activityDataManager.updActivity(attacker, ActivityConst.ACT_ATTACK, 1, 0);
        }

        if (defencer != null) {
            playerDataManager.synInvasionToPlayer(defencer, march);
        }
    }

    // private void haustMineTank(Form form, Fighter fighter) {
    // int killed = 0;
    // for (int i = 0; i < fighter.forces.length; i++) {
    // Force force = fighter.forces[i];
    // if (force != null) {
    // killed = force.killed;
    // if (killed > 0) {
    // form.c[i] = form.c[i] - killed;
    // }
    // }
    // }
    // }

    // private boolean fightMineNpc(Player player, Army army, StaticMine
    // staticMine, int now) {
    // int pos = army.getTarget();
    //
    // Form mineForm = worldDataManager.getMineForm(pos, staticMine.getLv());
    // StaticMineForm staticMineForm = worldDataManager.getStaticMineForm(pos);
    //
    // Fighter attacker = fightService.createFighter(player, army.getForm(), 3);
    // Fighter defencer = fightService.createFighter(staticMineForm);
    //
    // FightLogic fightLogic = new FightLogic(attacker, defencer,
    // FirstActType.ATTACKER, true);
    // fightLogic.packForm(army.getForm(), mineForm);
    //
    // fightLogic.fight();
    // CommonPb.Record record = fightLogic.generateRecord();
    //
    // Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker,
    // army.getForm(), 0.8);
    // Map<Integer, RptTank> defenceHaust =
    // fightService.statisticHaustTank(defencer);
    //
    // RptAtkMine.Builder rptAtkMine = RptAtkMine.newBuilder();
    // rptAtkMine.setFirst(fightLogic.attackerIsFirst());
    // rptAtkMine.setHonour(0);
    // rptAtkMine.setAttacker(createRptMan(player,
    // army.getForm().getCommander(), attackHaust, 0));
    // rptAtkMine.setDefencer(createRptMine(pos, staticMine, defenceHaust));
    // rptAtkMine.setRecord(record);
    // int result = fightLogic.getWinState();
    //
    // activityDataManager.tankDestory(player, defenceHaust);// 疯狂歼灭坦克
    //
    // if (result == 1) {// 攻方胜利
    // worldDataManager.resetMineForm(pos, staticMine.getLv());
    //
    // StaticMineLv staticMineLv =
    // staticWorldDataMgr.getStaticMineLv(staticMine.getLv());
    // int heroId = army.getForm().getCommander();
    // StaticHero staticHero = null;
    // if (heroId != 0) {
    // staticHero = staticHeroDataMgr.getStaticHero(heroId);
    // }
    //
    // int exp = (int) (staticMineLv.getExp() *
    // fightService.effectMineExpAdd(player, staticHero));
    // playerDataManager.addExp(player.lord, exp);
    //
    // Award award = mineDropOneAward(player, staticMine.getDropOne());
    //
    // collectArmy(player, army, now, staticMine, staticMineLv.getProduction(),
    // 0);
    //
    // rptAtkMine.setResult(true);
    // rptAtkMine.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, exp));
    // if (award != null) {
    // StaticProp staticProp = staticPropDataMgr.getStaticProp(award.getId());
    // if (staticProp != null && staticProp.getColor() >= 4) {
    // chatService.sendWorldChat(chatService.createSysChat(SysChatId.ATTACK_MINE,
    // player.lord.getNick(), staticProp.getPropName()));
    // }
    //
    // rptAtkMine.addAward(award);
    // }
    //
    // RptAtkMine rpt = rptAtkMine.build();
    // playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now),
    // MailType.MOLD_ATTACK_MINE, now, String.valueOf(staticMine.getType()),
    // String.valueOf(staticMine.getLv()));
    // playerDataManager.updTask(player, TaskType.COND_WIN_RESOURCE, 1,
    // staticMine.getLv());
    //
    // activityDataManager.profoto(player, staticMine.getLv());// 哈洛克宝藏活动
    // return false;
    // } else if (result == 2) {
    // haustMineTank(mineForm, defencer);
    // backHero(player, army.getForm());
    // rptAtkMine.setResult(false);
    //
    // RptAtkMine rpt = rptAtkMine.build();
    // playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now),
    // MailType.MOLD_ATTACK_MINE, now, String.valueOf(staticMine.getType()),
    // String.valueOf(staticMine.getLv()));
    //
    // return true;
    // } else {
    // haustMineTank(mineForm, defencer);
    //
    // rptAtkMine.setResult(false);
    // retreatArmy(player, army, now);
    // RptAtkMine rpt = rptAtkMine.build();
    // playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now),
    // MailType.MOLD_ATTACK_MINE, now, String.valueOf(staticMine.getType()),
    // String.valueOf(staticMine.getLv()));
    //
    // return false;
    // }
    //
    // }

    /**
     * 打矿
     *
     * @param player
     * @param army
     * @param staticMine
     * @param now
     * @return boolean
     */
    private boolean fightMineNpc(Player player, Army army, StaticMine staticMine, int now) {
        int pos = army.getTarget();
        StaticMineForm staticMineForm = worldDataManager.getMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_OTHER);
        Fighter defencer = fightService.createFighter(staticMineForm);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.ATTACKER, true);
        fightLogic.packForm(army.getForm(), PbHelper.createForm(staticMineForm.getForm()));

        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = staffingDataManager.getWorldRatio();
        // 荣耀生存玩法buff
        StaticHonourBuff honourBuff = honourDataManager.getHonourBuff(player.lord.getPos());
        if (honourBuff != null && honourBuff.getType() == -1) {
            worldRatio -= (honourBuff.getDeathtank() / 100.0);
        }
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio, 0, AwardFrom.ATTACK_MINE);
        Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);

        // worldDataManager.resetMineForm(pos, staticMine.getLv());
        // 战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, null);// NPC战损不记录到玩家战功中
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        RptAtkMine.Builder rptAtkMine = RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(0);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptMine(pos, staticMine, defenceHaust, defencer.firstValue));
        rptAtkMine.setRecord(record);
        int result = fightLogic.getWinState();

        activityDataManager.tankDestory(player, defenceHaust, false);// 疯狂歼灭坦克

        boolean state = false;
        if (result == 1) {// 攻方胜利
            playerDataManager.activeBoxDrop(player);
            // playerDataManager.updTask(player, TaskType.COND_ATTACK_RESOURCE, 1, staticMine.getLv());// 刷新攻击资源矿点的任务进度
            worldDataManager.resetMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

            StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
            int heroId = army.getForm().getCommander();
            StaticHero staticHero = null;
            if (heroId != 0) {
                staticHero = staticHeroDataMgr.getStaticHero(heroId);
            }

            int exp = (int) (staticMineLv.getExp() * fightService.effectMineExpAdd(player, staticHero));
            playerDataManager.addExp(player, exp);

            Award award = mineDropOneAward(player, staticMine.getDropOne());

            if (attacker.isReborn) {
                state = true;
                backHero(player, army.getForm());
                ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                playerDataManager.synArmyToPlayer(player, guardStatu);
            } else {
                collectArmy(player, army, now, staticMine, mineService.getMineProdunction(pos, staticMineLv.getProduction()), 0);
            }

            rptAtkMine.setResult(true);
            int realExp = playerDataManager.realExp(player, exp);
            rptAtkMine.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp));
            if (award != null) {
                StaticProp staticProp = staticPropDataMgr.getStaticProp(award.getId());
                if (staticProp != null && staticProp.getColor() >= 4) {
                    chatService.sendWorldChat(
                            chatService.createSysChat(SysChatId.ATTACK_MINE, player.lord.getNick(), staticProp.getPropName()));
                }

                rptAtkMine.addAward(award);
            }

            activityDataManager.attackResourceCourse(player, rptAtkMine); // 打矿通用活动掉落

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_WIN, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));
            playerDataManager.updTask(player, TaskType.COND_WIN_RESOURCE, 1, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

            activityDataManager.profoto(player, staticMine.getLv() + staffingDataManager.getWorldMineLevel());// 哈洛克宝藏活动
            return state;
        } else if (result == 2) {
            backHero(player, army.getForm());
            rptAtkMine.setResult(false);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            return true;
        } else {
            // haustMineTank(mineForm, defencer);

            rptAtkMine.setResult(false);

            retreatArmy(player, army, now);
            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            return false;
        }

    }

    // 消灭敌方部队
    // private void eliminateArmy(Player target, Army army) {
    // target.armys.remove(army);
    // int heroId = army.getForm().getCommander();
    // if (heroId > 0) {
    // playerDataManager.addHero(target, heroId, 1);
    // }
    // worldDataManager.removeGuard(guard);
    // }

    /**
     * 取消防守部队
     *
     * @param guard void
     */
    private void eliminateGuard(Guard guard) {
        Player target = guard.getPlayer();
        Army army = guard.getArmy();
        target.armys.remove(army);
        int heroId = army.getForm().getCommander();
        if (army.getForm().getAwakenHero() != null) {
            AwakenHero awakenHero = target.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.ELIMINATE_GUARD, target.account, target.lord, awakenHero, 0);
        } else if (heroId > 0) {
            playerDataManager.addHero(target, heroId, 1, AwardFrom.ELIMINATE_GUARD);
        }


        //战术
        if (!army.getForm().getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(target, army.getForm().getTactics());
        }

        worldDataManager.removeGuard(guard);
    }

    /**
     * 召回将领
     *
     * @param player
     * @param form   void
     */
    private void backHero(Player player, Form form) {
        if (form.getAwakenHero() != null) {
            AwakenHero awakenHero = player.awakenHeros.get(form.getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.BACK_HERO, player.account, player.lord, awakenHero, 0);
        } else if (form.getCommander() > 0) {
            playerDataManager.addHero(player, form.getCommander(), 1, AwardFrom.BACK_HERO);
        }


        //战术
        if (!form.getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(player, form.getTactics());
        }

    }

    /**
     * 矿点掉落奖励
     *
     * @param player
     * @param drop
     * @return Award
     */
    private Award mineDropOneAward(Player player, List<List<Integer>> drop) {
        if (drop != null && !drop.isEmpty()) {
            for (List<Integer> award : drop) {
                if (award.size() != 4) {
                    continue;
                }

                int prob = award.get(3);
                int revelry[] = activityDataManager.revelry();
                prob += revelry[2];

                if (RandomHelper.isHitRangeIn100(prob)) {
                    int type = award.get(0);
                    int id = award.get(1);
                    int count = award.get(2);
                    int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.FIGHT_MINE);
                    return PbHelper.createAwardPb(type, id, count, keyId);
                }
            }
        }
        return null;
    }

    /**
     * 攻击有驻军的矿点
     *
     * @param player
     * @param army
     * @param staticMine
     * @param guard
     * @param now
     * @return boolean
     */
    private boolean fightMineGuard(Player player, Army army, StaticMine staticMine, Guard guard, int now) {
        int pos = army.getTarget();
        Player guardPlayer = guard.getPlayer();
        Form targetForm = guard.getArmy().getForm();

        StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
        long get = playerDataManager.calcCollect(guardPlayer, guard.getArmy(), now, staticMine,
                mineService.getMineProdunction(pos, staticMineLv.getProduction()));

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
        Fighter defencer = fightService.createFighter(guardPlayer, targetForm, AttackType.ACK_DEFAULT_PLAYER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_1, true);
        fightLogic.packForm(army.getForm(), targetForm);
        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = staffingDataManager.getWorldRatio();
        double worldRatio1 = worldRatio;
        double worldRatio2 = worldRatio;
        // 荣耀生存玩法buff
        StaticHonourBuff honourBuff1 = honourDataManager.getHonourBuff(player.lord.getPos());
        if (honourBuff1 != null && honourBuff1.getType() == -1) {
            worldRatio1 -= (honourBuff1.getDeathtank() / 100.0);
        }
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio1, guardPlayer.roleId,
                AwardFrom.ATTACK_SOMEONE_MINE);

        StaticHonourBuff honourBuff2 = honourDataManager.getHonourBuff(guard.getPlayer().lord.getPos());
        if (honourBuff2 != null && honourBuff2.getType() == -1) {
            worldRatio2 -= (honourBuff2.getDeathtank() / 100.0);
        }
        Map<Integer, RptTank> defenceHaust = haustArmyTank(guardPlayer, defencer, targetForm, worldRatio2, player.roleId,
                AwardFrom.SOMEONE_ATTACK_MINE);
        // 炸矿根据敌方战损获取额外荣耀积分
        int honourScore = playerDataManager.calcHonourScore(defenceHaust);
        honourDataManager.addHonourScore(player, honourScore);

        activityDataManager.tankDestory(player, defenceHaust, true);// 疯狂歼灭坦克
        activityDataManager.tankDestory(guardPlayer, attackHaust, true);// 疯狂歼灭坦克

        int result = fightLogic.getWinState();

        int honor = playerDataManager.calcHonor(attackHaust, defenceHaust, worldRatio);
        if (honor > 0) {
            if (result == 1) {
                honor = playerDataManager.giveHonor(player, guardPlayer, honor);
            } else {
                honor = playerDataManager.giveHonor(guardPlayer, player, honor);
            }
        }

        // 战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, defenceHaust);
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            playerDataManager.addAward(guardPlayer, AwardType.MILITARY_EXPLOIT, 1, mplts[1], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        RptAtkMine.Builder rptAtkMine = RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(honor);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptMine(pos, staticMine, guardPlayer, targetForm.getHero(), defenceHaust,
                mplts != null ? mplts[1] : null, defencer.firstValue));
        rptAtkMine.setRecord(record);
        if (honourDataManager.isOpen()) {
            rptAtkMine.setDemageScore(honourScore);
        }

        boolean state = false;
        if (result == 1) {// 攻方胜利
            playerDataManager.activeBoxDrop(player);
            // playerDataManager.updTask(player, TaskType.COND_ATTACK_RESOURCE, 1, staticMine.getLv());// 刷新攻击资源矿点的任务进度
            int staffingExp = playerDataManager.calcStaffingExp(defenceHaust, worldRatio);
            int winStaffingExp = 0;
            int staffingExpAdd = 0;
            if (staffingExp > 0) {
                // 返回失败玩家实际扣除的编制经验
                staffingExp = playerDataManager.giveStaffingExp(player, guardPlayer, staffingExp, army);
                // 计算编制经验加速buff增加的比例
                winStaffingExp = staffingExp;// 只有胜利玩家获得的编制经验有加成，失败玩家扣除的编制经验没有加成
                if (player.effects.containsKey(EffectType.ADD_STAFFING_FIGHT)) {
                    winStaffingExp += staffingExp * 0.1;
                    staffingExpAdd += 10;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_ALL)) {
                    winStaffingExp += staffingExp * 0.1;
                    staffingExpAdd += 10;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_AD1)) {
                    winStaffingExp += staffingExp * 0.01;
                    staffingExpAdd += 1;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_AD2)) {
                    winStaffingExp += staffingExp * 0.02;
                    staffingExpAdd += 2;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_AD3)) {
                    winStaffingExp += staffingExp * 0.03;
                    staffingExpAdd += 3;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_AD4)) {
                    winStaffingExp += staffingExp * 0.04;
                    staffingExpAdd += 4;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_AD5)) {
                    winStaffingExp += staffingExp * 0.05;
                    staffingExpAdd += 5;
                }
                if (player.effects.containsKey(EffectType.ADD_STAFFING_ALL2)) {
                    winStaffingExp += staffingExp * 0.2;
                    staffingExpAdd += 20;
                }
            }

            rptAtkMine.setWinStaffingExp(winStaffingExp);
            rptAtkMine.setFailStaffingExp(staffingExp);
            rptAtkMine.setStaffingExpAdd(staffingExpAdd);

            eliminateGuard(guard);
            // 结算矿点品质经验
            int ctime = now - (army.getEndTime() - army.getPeriod());
            mineService.addMineQualityExp(guardPlayer, pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel(), ctime);
            if (attacker.isReborn) {
                state = true;
                backHero(player, army.getForm());
                ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                playerDataManager.synArmyToPlayer(player, guardStatu);
            } else {
                if (honourDataManager.isOpen()) {
                    int honourScore1 = honourDataManager.calcHonourScore(guard.getArmy(), now, staticMineLv.getHonourLiveScore(), pos);
                    // 掠夺荣耀积分
                    army.setHonourScore(army.getHonourScore() + honourScore1);
                    // guard.getArmy().setHonourScore(0);
                    rptAtkMine.setGrabScore(honourScore1);
                    // 掠夺荣耀金币
                    int have = honourDataManager.calcHonourCollectGold(guard.getArmy(), now / 60);
                    if (player.getHonourGrabGold() < HonourConstant.grabGold) {
                        int grab = HonourConstant.grabGold - player.getHonourGrabGold();
                        grab = grab <= have ? grab : have;
                        army.setHonourGold(army.getHonourGold() + grab);
                        // guard.getArmy().setHonourGold(0);
                        player.setHonourGrabGold(player.getHonourGrabGold() + grab);
                        rptAtkMine.setHonourGoldWin(grab);
                    }
                    // guard.getArmy().setHonourGold(0);
                    rptAtkMine.setHonourGoldFail(have);
                }
                collectArmy(player, army, now, staticMine, mineService.getMineProdunction(pos, staticMineLv.getProduction()), get);
            }

            rptAtkMine.setResult(true);
            long param = 0;
            if (army.getGrab() != null) {
                rptAtkMine.setGrab(PbHelper.createGrabPb(army.getGrab()));
                param = army.getGrab().rs[0] + army.getGrab().rs[1] + army.getGrab().rs[2] + army.getGrab().rs[3] + army.getGrab().rs[4];
            }

            int newHeroGold = getNewHeroGold(guard.getPlayer(), guard.getArmy()) + guard.getArmy().getNewHeroAddGold();
            //新英打人掠夺金币
            if (newHeroGold > 0) {

                if (player.newHeroAddGoldTime == 0) {
                    player.newHeroAddGoldTime = System.currentTimeMillis();
                }

                if (!DateHelper.isToday(new Date(player.newHeroAddGoldTime))) {
                    player.newHeroAddGold = 0;
                    player.newHeroAddGoldTime = System.currentTimeMillis();
                }
                int ldGold = 0;

                if (newHeroGold + player.newHeroAddGold >= Constant.HERO_GOLD) {
                    ldGold = Constant.HERO_GOLD - player.newHeroAddGold;
                } else {
                    ldGold = newHeroGold;
                }
                player.newHeroAddGold = player.newHeroAddGold + ldGold;
                guard.getArmy().setNewHeroSubGold(0);
                guard.getArmy().setNewHeroAddGold(0);
                army.setNewHeroAddGold(ldGold);
                rptAtkMine.setPlunderGold(ldGold);
                rptAtkMine.setDefPlunderGold(newHeroGold);
            }


            activityDataManager.attackResourceCourse(player, rptAtkMine); // 打矿通用活动掉落

            RptAtkMine rpt = rptAtkMine.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_WIN, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_DEFEND_LOSE, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            partyDataManager.addPartyTrend(13, guardPlayer, player, String.valueOf(param));// 军团军情

            playerDataManager.updTask(player, TaskType.COND_WIN_RESOURCE, 1, staticMine.getLv() + staffingDataManager.getWorldMineLevel());// 战胜世界资源点
            activityDataManager.profoto(player, staticMine.getLv() + staffingDataManager.getWorldMineLevel());// 哈洛克宝藏活动

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);

            playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3));
            return state;
        } else if (result == 2) {
            rptAtkMine.setResult(false);
            backHero(player, army.getForm());

            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, mineService.getMineProdunction(pos, staticMineLv.getProduction()),
                    get);

            RptAtkMine rpt = rptAtkMine.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            partyDataManager.addPartyTrend(12, guardPlayer, player, null);

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);
            if (defencer.isReborn) {
                backHero(guardPlayer, guard.getArmy().getForm());
                worldDataManager.removeGuard(guard);
                guardPlayer.armys.remove(guard.getArmy());

                playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3));
            } else {
                playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4));
            }
            return true;
        } else {
            rptAtkMine.setResult(false);

            retreatArmy(player, army, now);

            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, mineService.getMineProdunction(pos, staticMineLv.getProduction()),
                    get);

            RptAtkMine rpt = rptAtkMine.build();

            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ATTACK_MINE_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4));
            return false;
        }
    }

    /**
     * 攻击叛军
     *
     * @param player
     * @param army
     * @param now
     * @return
     */
    private boolean fightRebel(Player player, Army army, int now) {
        int pos = army.getTarget();
        Form form = worldDataManager.getRebelForm(pos);

        Rebel rebel = rebelDataManager.getRebelByPos(pos);
        if (null == form) {
            LogUtil.common("叛军的阵型数据为空, pos:" + pos + ", rebel:" + rebel);
            return true;
        }

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_OTHER);
        Fighter defencer = fightService.createRebelFighter(form, rebel.getType(), rebel.getRebelLv(), AttackType.ACK_OTHER, rebel.getBoss_hp());

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
        fightLogic.packForm(army.getForm(), form);

        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double ratio = 1 - RebelConstant.REBEL_TANK_RATIO;// 可维修返还的比例
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), ratio, 0, AwardFrom.ATTACK_REBEL);
        Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);

        // 战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, null);// NPC战损不记录玩家战功
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        RptAtkMine.Builder rptAtkMine = RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(0);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptRebel(pos, rebel.getRebelLv(), rebel.getHeroPick(), defenceHaust, -1, defencer.firstValue));
        rptAtkMine.setRecord(record);

        int result = fightLogic.getWinState();
        if (result == 1) {// 攻方胜利
            rebel.setState(RebelConstant.REBEL_STATE_DEAD);// 将叛军状态置为死亡

            worldDataManager.getRebelFormMap().remove(pos);// 从地图中移除已被击杀的叛军

            // 记录玩家击杀叛军
            if (rebel.getType() != RebelConstant.REBEL_TYPE_BOOS) {
                player.rebelData.addKillNum(rebel.getType());
                rebelDataManager.addRankPlayer(player.rebelData);

                // 叛军优化，新增军团榜
                rebelDataManager.updateWeekPartyRank(player.rebelData, rebel.getType());
            }

            if (rebel.getType() == RebelConstant.REBEL_TYPE_LEADER || rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {
                rebelDataManager.refreshRebelBoss(rebel);
            }

            // 如果叛军全部死亡，全服玩家获得一个随机BUFF
            rebelDataManager.sendRebelBuffReward();

            StaticRebelTeam team = staticRebelDataMgr.getStaticRebelTeam(rebel.getRebelId());
            int heroId = form.getCommander();
            if (form.getAwakenHero() != null) {
                heroId = form.getAwakenHero().getHeroId();
            }
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);

            int exp = (int) (team.getExp() * fightService.effectMineExpAdd(player, staticHero));
            playerDataManager.addExp(player, exp);

            List<List<Integer>> dropList = team.getDrop();

            List<CommonPb.Award> awardList = dropRandomAward(dropList);// 按配置的绝对概率随机掉落
            // 将领掉落逻辑，随机掉落
            int dropHeroId = rebelDataManager.randomHeroDrop(rebel.getHeroPick());
            if (dropHeroId > 0) {
                awardList.add(PbHelper.createAwardPb(AwardType.HERO, dropHeroId, 1));
            }

            // 叛军优化 , 增加礼盒掉落机制
            if (rebel.getType() == RebelConstant.REBEL_TYPE_LEADER) {
                int prob = RebelConstant.REBEL_BOX_PROB;
                if (RandomHelper.isHitRangeIn100(prob)) {
                    // 记录礼盒掉落，并在世界地图中加入礼盒
                    rebelDataManager.getBoxLeftCount().put(pos, RebelConstant.BOX_INIT_COUNT);
                    rebelDataManager.getBoxDropTime().put(pos, TimeHelper.getCurrentSecond());
                    worldDataManager.setRebelBox(pos, RebelConstant.BOX_INIT_COUNT);
                    // 通知礼盒掉落
                    chatService.sendHornChat(chatService.createSysChat(SysChatId.REBEL_HEAD_BOX, staticHero.getHeroName(),
                            player.lord.getNick(), String.valueOf(pos)), 1);
                }
            }

            // 返还叛军的坐标
            worldDataManager.returnRebelPos(pos);

            // 奖励通过邮件附件发送，只在有掉落的情况下才发邮件
            if (!CheckNull.isEmpty(awardList)) {

                if (rebel.getType() != RebelConstant.REBEL_TYPE_BOOS) {
                    playerDataManager.sendAttachMail(AwardFrom.ATTACK_REBEL, player, awardList, MailType.MOLD_KILL_REBEL, now, staticHero.getHeroName());
                } else {
                    playerDataManager.sendAttachMail(AwardFrom.ATTACK_REBEL, player, awardList, MailType.FRIEND_BOSS, now, staticHero.getHeroName());

                }
            }

            rptAtkMine.setResult(true);
            int realExp = playerDataManager.realExp(player, exp);
            rptAtkMine.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp));
            rptAtkMine.addAllAward(awardList);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_REBEL_ATTACK_WIN, now,
                    String.valueOf(rebel.getHeroPick()), String.valueOf(rebel.getRebelLv()));

            if (rebel.getType() != RebelConstant.REBEL_TYPE_BOOS) {
                activityKingService.updataRebelData(player, rebel.getType(), 1);//最强王者
            }

            if (rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {

                //buff

                List<List<Integer>> dropBuff = team.getDropBuff();
                for (List<Integer> eff : dropBuff) {
                    try {
                        Effect effect = playerDataManager.addEffect(player, eff.get(0), eff.get(1));
                        CommonPb.Effect effectPb = PbHelper.createEffectPb(effect);

                        GamePb6.RebelBoosEffectRq.Builder builder = GamePb6.RebelBoosEffectRq.newBuilder();
                        builder.setEffect(effectPb);
                        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.RebelBoosEffectRq.EXT_FIELD_NUMBER, GamePb6.RebelBoosEffectRq.ext, builder.build());
                        GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
                    } catch (Exception e) {
                        LogUtil.error(e);
                    }

                }

                // 创建红包
                ActRedBag arb = rebelService.createRedBag(player, RebelConstant.REBEL_TYPE_BOOS_REDBAG, RebelConstant.WORLD_REDBAG_COUNT);
                // 记录红包信息
                rebelService.recordRedBag(arb);
                // 发送红包
                chatService.sendHornChat(chatService.createRebelRedBagChat(SysChatId.REBEL_RED_BOOS_BAG, arb.getId(), player.lord.getNick()), 1);

            }


            if (attacker.isReborn) {
                backHero(player, army.getForm());
                return true;
            } else {
                retreatArmy(player, army, now);// 部队返回
            }


            return false;
        } else if (result == 2) {
            backHero(player, army.getForm());
            rptAtkMine.setResult(false);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_REBEL_ATTACK_LOSE, now,
                    String.valueOf(rebel.getHeroPick()), String.valueOf(rebel.getRebelLv()));

            return true;
        } else {
            rptAtkMine.setResult(false);
            retreatArmy(player, army, now);
            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_REBEL_ATTACK_LOSE, now,
                    String.valueOf(rebel.getHeroPick()), String.valueOf(rebel.getRebelLv()));

            return false;
        }
    }

    /**
     * 打叛军逻辑
     *
     * @param player
     * @param army
     * @param now
     * @return boolean
     */
    private boolean fightActRebel(Player player, Army army, int now) {
        int pos = army.getTarget();

        ActRebelData rebel = activityDataManager.getActRebelByPos(pos);
        if (rebel == null) {
            retreatArmy(player, army, now);

            int power = player.lord.getPower();
            if (power < PowerConst.POWER_MAX) {// 补偿能量1点，并发送邮件通知
                playerDataManager.addPower(player.lord, 1);
                playerDataManager.sendNormalMail(player, MailType.MOLD_ACT_REBEL_DISAPPEAR_2, now);
            } else {// 若能量超过上限40，则邮件补偿能量+1道具
                CommonPb.Award award = PbHelper.createAwardPb(AwardType.PROP, PropId.POWER_1, 1);
                List<CommonPb.Award> awards = new ArrayList<>();
                awards.add(award);
                playerDataManager.sendAttachMail(AwardFrom.ACT_REBEL_DISAPPEAR, player, awards, MailType.MOLD_ACT_REBEL_DISAPPEAR, now);
            }
            return false;
        }

        Form form = worldDataManager.getActRebelForm(pos);

        if (null == form) {
            LogUtil.common("活动叛军的阵型数据为空, pos:" + pos + ", rebel:" + rebel);
            return true;
        }

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_OTHER);
        Fighter defencer = fightService.createActRebelFighter(form, rebel.getRebelLv(), AttackType.ACK_OTHER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
        fightLogic.packForm(army.getForm(), form);

        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        StaticActRebel staticActRebel = staticActivityDataMgr.getActRebel();

        double ratio = (100 - staticActRebel.getHaustRatio()) / 100d; // 可维修返还的比例
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), ratio, 0, AwardFrom.ATTACK_ACT_REBEL);
        Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);

        // 战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, null);// NPC战损不记录玩家战功
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        RptAtkMine.Builder rptAtkMine = RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(0);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptRebel(pos, rebel.getRebelLv(), rebel.getRebelId(), defenceHaust, ActRebelConst.REBEL_TYPE_ACT,
                defencer.firstValue));
        rptAtkMine.setRecord(record);

        int result = fightLogic.getWinState();
        if (result == 1) {// 攻方胜利
            worldDataManager.getActRebelFormMap().remove(pos);// 从地图中移除已被击杀的叛军
            worldDataManager.returnActRebelPos(pos);// 返还叛军的坐标

            // 记录玩家击杀叛军
            activityDataManager.actRebelKill(player, rebel, staticActRebel);

            StaticActRebelTeam team = staticActivityDataMgr.getActRebel(rebel.getRebelId());
            // StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());

            int exp = (int) (team.getExp() * fightService.effectMineExpAdd(player, null));
            playerDataManager.addExp(player, exp);

            List<List<Integer>> dropList = team.getDrop();

            List<CommonPb.Award> awardList = dropRandomAward(dropList);// 按配置的绝对概率随机掉落

            // 奖励通过邮件附件发送，只在有掉落的情况下才发邮件
            if (!CheckNull.isEmpty(awardList)) {
                playerDataManager.sendAttachMail(AwardFrom.ATTACK_ACT_REBEL, player, awardList, MailType.MOLD_ACT_KILL_REBEL, now,
                        team.getName());
            }

            rptAtkMine.setResult(true);
            int realExp = playerDataManager.realExp(player, exp);
            rptAtkMine.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp));
            rptAtkMine.addAllAward(awardList);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ACT_REBEL_ATTACK_WIN, now,
                    String.valueOf(rebel.getRebelId()), String.valueOf(rebel.getRebelLv()));

            if (attacker.isReborn) {
                backHero(player, army.getForm());
                return true;
            } else {
                retreatArmy(player, army, now);// 部队返回
            }
            return false;
        } else if (result == 2) {
            backHero(player, army.getForm());
            rptAtkMine.setResult(false);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ACT_REBEL_ATTACK_LOSE, now,
                    String.valueOf(rebel.getRebelId()), String.valueOf(rebel.getRebelLv()));

            return true;
        } else {
            rptAtkMine.setResult(false);
            retreatArmy(player, army, now);
            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_ACT_REBEL_ATTACK_LOSE, now,
                    String.valueOf(rebel.getRebelId()), String.valueOf(rebel.getRebelLv()));

            return false;
        }
    }

    /**
     * 掉落随机物品 根据物品掉落比
     *
     * @param drop
     * @return List<Award>
     */
    private List<Award> dropRandomAward(List<List<Integer>> drop) {
        List<Award> awards = new ArrayList<>();
        if (drop != null && !drop.isEmpty()) {
            for (List<Integer> award : drop) {
                if (award.size() != 4) {
                    continue;
                }

                int prob = award.get(3);
                if (RandomHelper.isHitRangeIn100(prob)) {
                    int type = award.get(0);
                    int id = award.get(1);
                    int count = award.get(2);
                    awards.add(PbHelper.createAwardPb(type, id, count));
                }
            }
        }
        return awards;
    }

    /**
     * Method: fightMine
     *
     * @param player
     * @param army
     * @param staticMine
     * @return boolean
     * @throws @Description: 攻击矿
     */
    private boolean fightMine(Player player, Army army, StaticMine staticMine, int now) {
        int pos = army.getTarget();
        Guard guard = worldDataManager.getMineGuard(pos);
        if (guard != null) { // 有驻军
            if (guard.getPlayer() != player) {
                if (partyDataManager.isSameParty(player.roleId, guard.getPlayer().roleId)) {
                    playerDataManager.sendNormalMail(player, MailType.MOLD_HOLD, now, String.valueOf(staticMine.getType()),
                            String.valueOf(guard.getPlayer().lord.getNick()));
                    retreatArmy(player, army, now);
                    return false;
                }
                return fightMineGuard(player, army, staticMine, guard, now);

            } else {
                playerDataManager.sendNormalMail(player, MailType.MOLD_HOLD, now, String.valueOf(staticMine.getType()),
                        String.valueOf(player.lord.getNick()));
                retreatArmy(player, army, now);
                return false;
            }
        } else {
            return fightMineNpc(player, army, staticMine, now);
        }
    }

    /**
     * fighter里的forces给到form
     *
     * @param fighter 战斗单位
     * @param form    阵型 void
     */
    public void subForceToForm(Fighter fighter, Form form) {
        int[] c = form.c;
        for (int i = 0; i < c.length; i++) {
            Force force = fighter.forces[i];
            if (force != null) {
                form.c[i] = force.count;
            }
        }
    }

    /**
     * Method: haustArmyTank
     *
     * @param player
     * @param fighter
     * @param ratio     战损坦克可修复的概率
     * @param awardFrom
     * @throws @Description: 出征部队的战损
     */
    public Map<Integer, RptTank> haustArmyTank(Player player, Fighter fighter, Form form, double ratio, long attackId, AwardFrom awardFrom) {
        Map<Integer, RptTank> map = new HashMap<>();
        Map<Integer, Tank> tanks = player.tanks;
        int killed;
        int tankId;
        for (Force force : fighter.forces) {
            if (force != null) {
                killed = force.killed;
                if (killed > 0) {
                    tankId = force.staticTank.getTankId();
                    RptTank rptTank = map.get(tankId);
                    if (rptTank != null) {
                        rptTank.setCount(rptTank.getCount() + killed);
                    } else {
                        rptTank = new RptTank(tankId, killed);
                        map.put(tankId, rptTank);
                    }
                }
            }
        }

        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = it.next();
            killed = rptTank.getCount();
            int repair = (int) Math.ceil(ratio * killed);
            Tank tank = tanks.get(rptTank.getTankId());
            tank.setRest(tank.getRest() + repair);
            LogLordHelper.tank(awardFrom, player.account, player.lord, rptTank.getTankId(), tank.getCount(), -killed, -killed + repair, attackId);

            // //增加军功
            // if (rptTank.getDisappear() > 0 && fighter.isPlayerFigher()) {
            // Player destroyer = fighter.oppoFighter != null ? fighter.oppoFighter.player : null;
            // playerDataManager.addMilitaryExploit(player, destroyer, rptTank);
            // }

        }

        if (map.isEmpty()) {
            LogLordHelper.tank(awardFrom, player.account, player.lord, -1, 0, 0, 0, attackId);
        }


        subForceToForm(fighter, form);
        playerEventService.calcStrongestFormAndFight(player);
        return map;
    }

    /**
     * Method: haustHomeTank
     *
     * @param player
     * @param fighter
     * @throws @Description: 基地防守的战损
     */
    private Map<Integer, RptTank> haustHomeTank(Player player, Fighter fighter, double ratio, long attackId, AwardFrom awardFrom) {
        Map<Integer, RptTank> map = new HashMap<>();
        Map<Integer, Tank> tanks = player.tanks;
        int killed;
        int tankId;
        int alive;
        for (Force force : fighter.forces) {
            if (force != null) {
                killed = force.killed;
                alive = force.count;
                tankId = force.staticTank.getTankId();

                if (killed > 0) {
                    RptTank rptTank = map.get(tankId);
                    if (rptTank != null) {
                        rptTank.setCount(rptTank.getCount() + killed);
                    } else {
                        rptTank = new RptTank(tankId, killed);
                        map.put(tankId, rptTank);
                    }
                }

                if (alive > 0) {
                    Tank tank = tanks.get(tankId);
                    tank.setCount(tank.getCount() + alive);
                }
            }
        }

        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = (RptTank) it.next();
            killed = rptTank.getCount();
            int repair = (int) Math.ceil(ratio * killed);
            Tank tank = tanks.get(rptTank.getTankId());
            tank.setRest(tank.getRest() + repair);
            LogLordHelper.tank(awardFrom, player.account, player.lord, rptTank.getTankId(), tank.getCount(), -rptTank.getCount(),
                    -killed + repair, attackId);
        }

        if (map.isEmpty()) {
            LogLordHelper.tank(awardFrom, player.account, player.lord, -1, 0, 0, 0, attackId);
        }


        playerEventService.calcStrongestFormAndFight(player);
        return map;
    }

    /**
     * 计算繁荣度变化
     *
     * @param attacker
     * @param heroId
     * @return int[] index0: 攻击放繁荣度增加 index1 防守方繁荣度减少
     */
    private int[] calcWinPros(Player attacker, int heroId, Form targetForm) {
        int[] v = new int[2];
        StaticLordLv staticLordLv = staticLordDataMgr.getStaticLordLv(attacker.lord.getLevel());
        v[0] = v[1] = staticLordLv.getWinPros();

        StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
        if (staticHero != null && staticHero.getSkillId() == 7) {
            v[1] += staticHero.getSkillValue();
        }

        StaticVip staticVip = staticVipDataMgr.getStaticVip(attacker.lord.getVip());
        if (staticVip != null) {
            v[1] += staticVip.getSubPros();
        }

        if (playerDataManager.isRuins(attacker)) {
            v[0] /= 2;
        }

        int heroPros = 0;

        // 守卫基地/资源减繁荣度损失
        if (targetForm != null) {
            AwakenHero awakenHero = targetForm.getAwakenHero();
            if (awakenHero != null) {
                for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                    if (entry.getValue() <= 0) {
                        continue;
                    }
                    StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                    if (staticHeroAwakenSkill == null) {
                        LogUtil.error("觉醒将领技能未配置calcWinPros:" + entry.getKey() + " 等级:" + entry.getValue());
                        continue;
                    }
                    if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_PROS) {
                        String val = staticHeroAwakenSkill.getEffectVal();
                        if (val != null && !val.isEmpty()) {
                            heroPros += Float.valueOf(val);
                        }
                    }
                }
            }
        }

        if (heroPros > 0) {
            v[1] = v[1] * (1 - heroPros);
        }
        return v;
    }

    /**
     * 攻打不设防的基地
     *
     * @param player
     * @param army
     * @param target
     * @param now
     * @return
     */
    private boolean fightHomePlayer(Player player, Army army, Player target, int now) {
        boolean state = false;
        boolean targetRuins = playerDataManager.isRuins(target);

        Form targetForm = playerDataManager.createHomeDefendForm(target);
        boolean isMilitaryRankOpen = staticFunctionPlanDataMgr.isMilitaryRankOpen();
        if (targetForm == null) {// 没有设置防守阵型，直接胜利
            playerDataManager.activeBoxDrop(player);
            playerDataManager.updTask(player, TaskType.COND_WIN_PLAYER, 1, null);// 刷新攻击玩家的任务进度
            long load = playerDataManager.calcLoad(player, army.getForm(), army.isRuins());
            //友好度额外计算资源掠夺
            load = calcExtraLoadByFriendliness(player, target, load);
            Grab grab = calcGrab(target, load);
            playerDataManager.undergoGrab(target, grab);
            army.setGrab(grab);

            retreatArmy(player, army, now);

            int[] pros = calcWinPros(player,
                    army.getForm().getAwakenHero() != null ? army.getForm().getAwakenHero().getHeroId() : army.getForm().getCommander(),
                    null);
            winPros(player, target, pros);
            Long mplt = isMilitaryRankOpen ? 0L : null;// null表示功能未开启

            Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);

            RptAtkHome.Builder rptAtkHome = RptAtkHome.newBuilder();
            rptAtkHome.setResult(true);
            rptAtkHome.setFirst(true);
            rptAtkHome.setHonour(0);
            rptAtkHome.setAttacker(createRptMan(player, army.getHero(), null, pros[0], mplt, attacker.firstValue));
            rptAtkHome.setDefencer(createRptMan(target, 0, null, -pros[1], mplt, 0));
            /**
             * 战报协议中添加好友之间的友好度
             */
            if (playerDataManager.checkMutualFriend(player.roleId, target.roleId)) {
                Friend friend = player.friends.get(target.roleId);
                if (friend != null) {
                    rptAtkHome.setFriendliness(friend.getFriendliness());
                }
            }
            rptAtkHome.setGrab(PbHelper.createGrabPb(grab));

            activityDataManager.attackPlayerCourse(player, rptAtkHome); // 打玩家基地通用活动掉落
            activityDataManager.attackPlayerForActFlower(player, target, rptAtkHome); // 鲜花祝福活动 掉落鲜花
            activityDataManager.updActivity(player, ActivityConst.ACT_ATTACK2, 1, 0); // 雷霆计划2

            RptAtkHome rpt = rptAtkHome.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_WIN, now,
                    target.lord.getNick(), String.valueOf(target.lord.getLevel()));
            long param = grab.rs[0] + grab.rs[1] + grab.rs[2] + grab.rs[3] + grab.rs[4];
            partyDataManager.addPartyTrend(13, target, player, String.valueOf(param));

            playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_LOSE, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, target, mail, 1);

            playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));

        } else {
            Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
            Fighter defencer = fightService.createFighter(target, targetForm, AttackType.ACK_DEFAULT_PLAYER);

            FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_1, true);
            fightLogic.packForm(army.getForm(), targetForm);

            fightLogic.fight();
            CommonPb.Record record = fightLogic.generateRecord();

            double worldRatio = staffingDataManager.getWorldRatio();
            double worldRatio1 = worldRatio;
            double worldRatio2 = worldRatio;
            // 荣耀生存玩法buff
            StaticHonourBuff honourBuff1 = honourDataManager.getHonourBuff(player.lord.getPos());
            if (honourBuff1 != null && honourBuff1.getType() == -1) {
                worldRatio1 -= (honourBuff1.getDeathtank() / 100.0);
            }
            Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio1, target.roleId,
                    AwardFrom.ATTACK_SOMEONE_HOME);

            StaticHonourBuff honourBuff2 = honourDataManager.getHonourBuff(target.lord.getPos());
            if (honourBuff2 != null && honourBuff2.getType() == -1) {
                worldRatio2 -= (honourBuff2.getDeathtank() / 100.0);
            }
            Map<Integer, RptTank> defenceHaust = haustHomeTank(target, defencer, worldRatio2, player.roleId, AwardFrom.SOMEONE_ATTACK_HOME);

            activityDataManager.tankDestory(player, defenceHaust, true);// 疯狂歼灭坦克
            activityDataManager.tankDestory(target, attackHaust, true);// 疯狂歼灭坦克

            // 根据敌方战损获取额外荣耀积分
            int honourScore2 = playerDataManager.calcHonourScore(defenceHaust);
            honourDataManager.addHonourScore(player, honourScore2);

            int[] pros;
            int result = fightLogic.getWinState();
            if (result == 1) {
                pros = calcWinPros(player, army.getHero(), targetForm);
                winPros(player, target, pros);
                // honor = playerDataManager.giveHonor(player, target, honor);
            } else {
                pros = new int[]{0, 0};
                // honor = playerDataManager.giveHonor(target, player, honor);
            }

            int honor = playerDataManager.calcHonor(attackHaust, defenceHaust, worldRatio);
            if (honor > 0) {
                if (result == 1) {
                    honor = playerDataManager.giveHonor(player, target, honor);
                } else {
                    honor = playerDataManager.giveHonor(target, player, honor);
                }
            }

            // 战功计算 0-攻方战功,1-防守方战功
            long[] mplts = null;
            if (isMilitaryRankOpen) {
                mplts = playerDataManager.calcMilitaryExploit(attackHaust, defenceHaust);
                playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
                playerDataManager.addAward(target, AwardType.MILITARY_EXPLOIT, 1, mplts[1], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            }

            RptAtkHome.Builder rptAtkHome = RptAtkHome.newBuilder();
            rptAtkHome.setFirst(fightLogic.attackerIsFirst());
            rptAtkHome.setHonour(honor);
            rptAtkHome.setAttacker(
                    createRptMan(player, army.getHero(), attackHaust, pros[0], mplts != null ? mplts[0] : null, attacker.firstValue));
            rptAtkHome.setDefencer(createRptMan(target, targetForm.getHero(), defenceHaust, -pros[1], mplts != null ? mplts[1] : null,
                    defencer.firstValue));
            rptAtkHome.setRecord(record);
            if (honourDataManager.isOpen()) {
                rptAtkHome.setDemageScore(honourScore2);
            }

            if (result == 1) {// 攻方胜利
                playerDataManager.activeBoxDrop(player);
                playerDataManager.updTask(player, TaskType.COND_WIN_PLAYER, 1, null);// 刷新攻击玩家的任务进度
                long load = playerDataManager.calcLoad(player, army.getForm(), army.isRuins());
                //友好度额外计算掠夺的资源量
                load = calcExtraLoadByFriendliness(player, target, load);
                Grab grab = calcGrab(target, load);
                playerDataManager.undergoGrab(target, grab);
                army.setGrab(grab);

                rptAtkHome.setResult(true);
                rptAtkHome.setGrab(PbHelper.createGrabPb(grab));

                activityDataManager.attackPlayerCourse(player, rptAtkHome); // 打玩家基地通用活动掉落
                activityDataManager.attackPlayerForActFlower(player, target, rptAtkHome); // 鲜花祝福活动 掉落鲜花
                activityDataManager.updActivity(player, ActivityConst.ACT_ATTACK2, 1, 0); // 雷霆计划2
                /**
                 * 战报协议中添加好友之间的友好度
                 */
                if (playerDataManager.checkMutualFriend(player.roleId, target.roleId)) {
                    Friend friend = player.friends.get(target.roleId);
                    if (friend != null) {
                        rptAtkHome.setFriendliness(friend.getFriendliness());
                    }
                }
                RptAtkHome rpt = rptAtkHome.build();
                Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_WIN, now,
                        target.lord.getNick(), String.valueOf(target.lord.getLevel()));

                playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_LOSE, now,
                        player.lord.getNick(), String.valueOf(player.lord.getLevel()));
                long param = grab.rs[0] + grab.rs[1] + grab.rs[2] + grab.rs[3] + grab.rs[4];
                partyDataManager.addPartyTrend(13, target, player, String.valueOf(param));

                // 分享战力top
                chatService.shareChallengeFightRankTop5(player, target, mail, result);

                if (attacker.isReborn) {
                    backHero(player, army.getForm());
                    state = true;
                } else {
                    retreatArmy(player, army, now);
                }
                playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
            } else if (result == 2) {
                rptAtkHome.setResult(false);
                backHero(player, army.getForm());

                RptAtkHome rpt = rptAtkHome.build();
                Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_LOSE, now,
                        target.lord.getNick(), String.valueOf(target.lord.getLevel()));

                playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                        player.lord.getNick(), String.valueOf(player.lord.getLevel()));
                partyDataManager.addPartyTrend(12, target, player, null);

                // 分享战力top
                chatService.shareChallengeFightRankTop5(player, target, mail, result);
                // if (defencer.isReborn) {
                // backHero(target, targetForm); 基地设防是不会预先扣除将领的
                // target.forms.remove(FormType.HOME_DEFEND);
                // }
                playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
                state = true;
            } else {
                rptAtkHome.setResult(false);

                retreatArmy(player, army, now);

                RptAtkHome rpt = rptAtkHome.build();
                Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_LOSE, now,
                        target.lord.getNick(), String.valueOf(target.lord.getLevel()));

                playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                        player.lord.getNick(), String.valueOf(player.lord.getLevel()));

                // 分享战力top
                chatService.shareChallengeFightRankTop5(player, target, mail, result);

                playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
            }
        }

        if (!targetRuins) {
            if (playerDataManager.isRuins(target)) {
                playerDataManager.sendNormalMail(target, MailType.MOLD_RUINS, now, player.lord.getNick());
            }
        }

        return state;
    }

    /**
     * 打人家基地战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private Report createAtkHomeReport(RptAtkHome rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setAtkHome(rpt);
        report.setTime(now);
        return report.build();
    }

    /**
     * 基地被打战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private Report createDefHomeReport(RptAtkHome rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setDefHome(rpt);
        report.setTime(now);
        return report.build();
    }

    /**
     * 打矿战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private Report createAtkMineReport(RptAtkMine rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setAtkMine(rpt);
        report.setTime(now);
        return report.build();
    }

    /**
     * 矿被炸战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private Report createDefMineReport(RptAtkMine rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setDefMine(rpt);
        report.setTime(now);
        return report.build();
    }

    /**
     * 打基地后战斗后双方繁荣度处理
     *
     * @param attacker
     * @param defencer
     * @param v        void
     */
    private void winPros(Player attacker, Player defencer, int[] v) {
        playerDataManager.addPros(attacker, v[0]);
        playerDataManager.subProsByAttack(defencer, v[1], attacker);
    }

    /**
     * 攻打设防基地
     *
     * @param player
     * @param army
     * @param target
     * @param guard
     * @param now
     * @return
     */
    private boolean fightHomeGuard(Player player, Army army, Player target, Guard guard, int now) {
        boolean state = false;
        boolean targetRuins = playerDataManager.isRuins(target);

        Player guardPlayer = guard.getPlayer();
        Form targetForm = guard.getArmy().getForm();

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
        Fighter defencer = fightService.createFighter(guardPlayer, targetForm, AttackType.ACK_DEFAULT_PLAYER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_1, true);
        fightLogic.packForm(army.getForm(), targetForm);
        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = staffingDataManager.getWorldRatio();
        double worldRatio1 = worldRatio;
        double worldRatio2 = worldRatio;
        // 荣耀生存玩法buff
        StaticHonourBuff honourBuff1 = honourDataManager.getHonourBuff(player.lord.getPos());
        if (honourBuff1 != null && honourBuff1.getType() == -1) {
            worldRatio1 -= (honourBuff1.getDeathtank() / 100.0);
        }
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio1, guardPlayer.roleId,
                AwardFrom.ATTACK_SOMEONE_HOME);

        StaticHonourBuff honourBuff2 = honourDataManager.getHonourBuff(guard.getPlayer().lord.getPos());
        if (honourBuff2 != null && honourBuff2.getType() == -1) {
            worldRatio2 -= (honourBuff2.getDeathtank() / 100.0);
        }
        Map<Integer, RptTank> defenceHaust = haustArmyTank(guardPlayer, defencer, targetForm, worldRatio2, player.roleId,
                AwardFrom.SOMEONE_ATTACK_HOME);

        activityDataManager.tankDestory(player, defenceHaust, true);// 疯狂歼灭坦克
        activityDataManager.tankDestory(target, attackHaust, true);// 疯狂歼灭坦克

        // 根据敌方战损获取额外荣耀积分
        int honourScore2 = playerDataManager.calcHonourScore(defenceHaust);
        honourDataManager.addHonourScore(player, honourScore2);

        int[] pros;
        int result = fightLogic.getWinState();
        if (result == 1) {
            pros = calcWinPros(player, army.getHero(), targetForm);
            winPros(player, target, pros);
        } else {
            pros = new int[]{0, 0};
        }

        // 战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, defenceHaust);
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            playerDataManager.addAward(guardPlayer, AwardType.MILITARY_EXPLOIT, 1, mplts[1], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        RptAtkHome.Builder rptAtkHome = RptAtkHome.newBuilder();
        rptAtkHome.setFirst(fightLogic.attackerIsFirst());
        rptAtkHome.setHonour(0);
        rptAtkHome.setFriend(guardPlayer.lord.getNick());
        rptAtkHome.setAttacker(
                createRptMan(player, army.getHero(), attackHaust, pros[0], mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkHome.setDefencer(
                createRptMan(target, targetForm.getHero(), defenceHaust, -pros[1], mplts != null ? mplts[1] : null, defencer.firstValue));
        rptAtkHome.setRecord(record);
        if (honourDataManager.isOpen()) {
            rptAtkHome.setDemageScore(honourScore2);
        }

        if (result == 1) {// 攻方胜利
            playerDataManager.activeBoxDrop(player);
            playerDataManager.updTask(player, TaskType.COND_WIN_PLAYER, 1, null);// 刷新攻击玩家的任务进度
            long load = playerDataManager.calcLoad(player, army.getForm(), army.isRuins());
            //友好度额外计算资源掠夺
            load = calcExtraLoadByFriendliness(player, target, load);
            Grab grab = calcGrab(target, load);
            playerDataManager.undergoGrab(target, grab);
            army.setGrab(grab);

            rptAtkHome.setResult(true);
            rptAtkHome.setGrab(PbHelper.createGrabPb(grab));

            eliminateGuard(guard);

            activityDataManager.attackPlayerCourse(player, rptAtkHome); // 打玩家基地通用活动掉落
            activityDataManager.attackPlayerForActFlower(player, target, rptAtkHome); // 鲜花祝福活动 掉落鲜花
            activityDataManager.updActivity(player, ActivityConst.ACT_ATTACK2, 1, 0); // 雷霆计划2
            /**
             * 战报协议中添加好友之间的友好度
             */
            if (playerDataManager.checkMutualFriend(player.roleId, target.roleId)) {
                Friend friend = player.friends.get(target.roleId);
                if (friend != null) {
                    rptAtkHome.setFriendliness(friend.getFriendliness());
                }
            }

            RptAtkHome rpt = rptAtkHome.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_WIN, now,
                    target.lord.getNick(), String.valueOf(target.lord.getLevel()));

            playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_LOSE, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_LOSE, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);

            if (attacker.isReborn) {
                backHero(player, army.getForm());
                state = true;
            } else {
                retreatArmy(player, army, now);
            }
            playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
            ArmyStatu guardStatu = new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3);
            playerDataManager.synArmyToPlayer(target, guardStatu);
            playerDataManager.synArmyToPlayer(guardPlayer, guardStatu);
        } else if (result == 2) {
            rptAtkHome.setResult(false);
            backHero(player, army.getForm());

            RptAtkHome rpt = rptAtkHome.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_LOSE, now,
                    target.lord.getNick(), String.valueOf(target.lord.getLevel()));

            playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);

            playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
            ArmyStatu guardStatu;
            if (defencer.isReborn) {
                backHero(guardPlayer, guard.getArmy().getForm());
                worldDataManager.removeGuard(guard);
                guardPlayer.armys.remove(guard.getArmy());

                guardStatu = new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3);
            } else {
                guardStatu = new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4);
            }
            playerDataManager.synArmyToPlayer(target, guardStatu);
            playerDataManager.synArmyToPlayer(guardPlayer, guardStatu);
            state = true;
        } else {
            rptAtkHome.setResult(false);

            retreatArmy(player, army, now);
            playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));

            RptAtkHome rpt = rptAtkHome.build();
            playerDataManager.sendReportMail(player, createAtkHomeReport(rpt, now), MailType.MOLD_ATTACK_PLAYER_LOSE, now,
                    target.lord.getNick(), String.valueOf(target.lord.getLevel()));

            playerDataManager.sendReportMail(target, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefHomeReport(rpt, now), MailType.MOLD_DEFEND_WIN, now,
                    player.lord.getNick(), String.valueOf(player.lord.getLevel()));

            playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
            ArmyStatu armyStatu = new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4);
            playerDataManager.synArmyToPlayer(target, armyStatu);
            playerDataManager.synArmyToPlayer(guardPlayer, armyStatu);
        }

        if (!targetRuins) {
            if (playerDataManager.isRuins(target)) {
                playerDataManager.sendNormalMail(target, MailType.MOLD_RUINS, now, player.lord.getNick());
            }
        }

        return state;
    }

    /**
     * Method: fightPlayer
     *
     * @param player
     * @param army
     * @return boolean
     * @throws @Description: 攻击玩家
     */
    private boolean fightHome(Player player, Army army, Player target, int now) {
        if (player.roleId.longValue() == target.roleId) {// 直接返回
            retreatArmy(player, army, now);
            playerDataManager.sendNormalMail(player, MailType.MOLD_RETREAT, now, player.lord.getNick());
            return false;
        }

        if (partyDataManager.isSameParty(player.roleId, target.roleId)) {
            retreatArmy(player, army, now);
            playerDataManager.sendNormalMail(player, MailType.MOLD_RETREAT, now, target.lord.getNick());
            return false;
        }

        int pos = army.getTarget();
        // Player target = worldDataManager.getPosData(pos);
        // if (target == null || player.roleId == target.roleId) {// 直接返回
        // retreatArmy(player, army, now);
        // return false;
        // }

        if (target.effects.containsKey(EffectType.ATTACK_FREE)) {


            boolean bln = false;

            //新英雄破罩
            Form form = army.getForm();
            if (form != null) {
                int commander = form.getCommander();
                StaticHero staticHero = staticHeroDataMgr.getStaticHero(commander);
                if (staticHero != null && staticHero.getSkillId() == 22) {
                    bln = true;
                }
            }

            if (!bln) {
                retreatArmy(player, army, now);
                playerDataManager.sendNormalMail(player, MailType.MOLD_FREE_ATTACK, now, target.lord.getNick());
                return false;
            }

        }

        Guard guard = worldDataManager.getHomeGuard(pos);
        if (guard != null) // 有驻军
            return fightHomeGuard(player, army, target, guard, now);
        else
            return fightHomePlayer(player, army, target, now);
    }

    /**
     * Method: getInvasion
     *
     * @param handler
     * @return void
     * @throws @Description: 进军数据
     */
    public void getInvasion(ClientHandler handler) {
        // GameServer.GAME_LOGGER.error("getInvasion roleId:" +
        // handler.getRoleId());

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<March> all = new ArrayList<>();
        List<March> list = worldDataManager.getMarch(player.lord.getPos());
        if (list != null) {
            all.addAll(list);
        }

        // for (Army army : player.armys) {
        // if (army.getState() == ArmyState.COLLECT) {
        // List<March> list = worldDataManager.getMarch(army.getTarget());
        // if (list != null) {
        // all.addAll(list);
        // }
        // }
        // }

        GetInvasionRs.Builder builder = GetInvasionRs.newBuilder();
        for (int i = 0; i < all.size(); i++) {
            builder.addInvasion(PbHelper.createInvasionPb(all.get(i)));
        }

        handler.sendMsgToPlayer(GetInvasionRs.ext, builder.build());
    }

    /**
     * Method: getAid
     *
     * @param handler
     * @return void
     * @throws @Description: 盟友驻军数据
     */
    public void getAid(ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<Guard> list = worldDataManager.getGuard(player.lord.getPos());

        GetAidRs.Builder builder = GetAidRs.newBuilder();
        if (list != null) {
            for (Guard grard : list) {
                // 计算驻守部队的战力和载重
                long fight = fightService.calcFormFight(grard.getPlayer(), grard.getArmy().getForm());
                long load = playerDataManager.calcLoad(grard.getPlayer(), grard.getArmy().getForm(), grard.getArmy().isRuins());

                builder.addAid(PbHelper.createAidPb(grard, fight, load));
            }
        }

        handler.sendMsgToPlayer(GetAidRs.ext, builder.build());
    }

    /**
     * Method: speedArmy
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 加速行军
     */
    public void speedArmy(SpeedQueRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        // int cost = req.getCost();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<Army> list = player.armys;
        Army army = null;
        boolean find = false;

        for (Army e : list) {
            if (e.getKeyId() == keyId) {
                army = e;
                find = true;
                break;
            }
        }

        if (!find) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }

        if (ArmyState.MARCH != army.getState() && ArmyState.RETREAT != army.getState() && ArmyState.AID != army.getState()) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_MARCH);
            return;
        }

        int now = TimeHelper.getCurrentSecond();
        SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();

        int leftTime = army.getEndTime() - now;
        if (leftTime <= 0) {
            leftTime = 1;
        }

        int sub = (int) Math.ceil(leftTime / 60.0);
        Lord lord = player.lord;
        if (lord.getGold() < sub) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        playerDataManager.subGold(player, sub, AwardFrom.SPEED_ARMY);
        army.setEndTime(now);

        dealWorldAction(player, now);
        builder.setGold(lord.getGold());
        handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
        return;

    }

    /**
     * 行军结束
     *
     * @param player
     * @param army
     * @param now
     * @return
     */
    private boolean marchEnd(Player player, Army army, int now) {
        worldDataManager.removeMarch(player, army);
        int pos = army.getTarget();

        if (army.getType() == ArmyConst.ACT_REBEL) {// 此次部队目标是活动叛军
            return fightActRebel(player, army, now);
        }

        Rebel rebel = rebelDataManager.getRebelByPos(pos);
        if (rebel != null && rebelDataManager.isRebelStart()) {// 攻击叛军
            boolean isMax = false;
            if (rebel.getType() != RebelConstant.REBEL_TYPE_BOOS) {
                isMax = rebelDataManager.killNumIsMax(player.roleId);
            }

            if (!isMax && rebel.isAlive()) {// 叛军还活着，并且玩家没到击杀上限
                return fightRebel(player, army, now);
            } else {// 若行军抵达时叛军已被击杀则会自动遣返部队
                retreatAidArmy(player, army, now);

                int power = player.lord.getPower();
                if (power < PowerConst.POWER_MAX) {// 补偿能量1点，并发送邮件通知
                    playerDataManager.addPower(player.lord, 1);
                    if (isMax) {
                        playerDataManager.sendNormalMail(player, MailType.MOLD_KILL_REBEL_MAX_1, now);
                    } else {
                        playerDataManager.sendNormalMail(player, MailType.MOLD_REBEL_DISAPPEAR_2, now);
                    }
                } else {// 若能量超过上限40，则邮件补偿能量+1道具
                    CommonPb.Award award = PbHelper.createAwardPb(AwardType.PROP, PropId.POWER_1, 1);
                    List<CommonPb.Award> awards = new ArrayList<>();
                    awards.add(award);
                    if (isMax) {
                        playerDataManager.sendAttachMail(AwardFrom.REBEL_DISAPPEAR, player, awards, MailType.MOLD_KILL_REBEL_MAX_2, now);
                    } else {
                        playerDataManager.sendAttachMail(AwardFrom.REBEL_DISAPPEAR, player, awards, MailType.MOLD_REBEL_DISAPPEAR, now);
                    }
                }
                return false;
            }
        }

        Player target = worldDataManager.getPosData(pos);
        if (target != null) {// 攻击地图上的玩家
            return fightHome(player, army, target, now);
        } else {// 攻击矿
            StaticMine staticMine = worldDataManager.evaluatePos(pos);
            if (staticMine == null) {
                retreatArmy(player, army, now);
                playerDataManager.sendNormalMail(player, MailType.MOLD_TARGET_GONE, now, String.valueOf(pos));
                return false;
            }

            return fightMine(player, army, staticMine, now);
        }
    }

    /**
     * 驻军遣返
     *
     * @param player
     * @param army
     * @param now    void
     */
    private void aidEnd(Player player, Army army, int now) {
        worldDataManager.removeMarch(player, army);
        int pos = army.getTarget();
        Player target = worldDataManager.getPosData(pos);
        if (target != null) {// 地图上的玩家
            if (player.roleId.longValue() == target.roleId) {// 直接返回
                retreatAidArmy(player, army, now);
                playerDataManager.sendNormalMail(player, MailType.MOLD_RETREAT, now, player.lord.getNick());
                return;
            }

            if (partyDataManager.isSameParty(player.roleId, target.roleId)) {
                army.setState(ArmyState.WAIT);
                worldDataManager.setGuard(new Guard(player, army));
                playerDataManager.sendNormalMail(target, MailType.MOLD_GUARD, now, player.lord.getNick());

                playerDataManager.synArmyToPlayer(target, new ArmyStatu(player.roleId, army.getKeyId(), 1));
                return;
            } else {
                retreatAidArmy(player, army, now);
                playerDataManager.sendNormalMail(player, MailType.MOLD_RETREAT, now, target.lord.getNick());
                return;
            }
        } else {
            retreatAidArmy(player, army, now);
            playerDataManager.sendNormalMail(player, MailType.MOLD_AID_GONE, now, String.valueOf(pos));
            return;
        }
    }

    // private void sendTargetGoneMail(Player player, int pos) {
    // playerDataManager.addReportMail(player, MailType.MOLD_TARGET_GONE,
    // String.valueOf(pos));
    // }

    /**
     * 返回行军结束
     *
     * @param player
     * @param army   void
     */
    public void retreatEnd(Player player, Army army) {
        // 部队返回
        int[] p = army.getForm().p;
        int[] c = army.getForm().c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0 && c[i] > 0) {
                playerDataManager.addTank(player, p[i], c[i], AwardFrom.RETREAT_END);
            }
        }
        // 将领返回
        if (army.getForm().getAwakenHero() != null) {
            AwakenHero awakenHero = player.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
            if (awakenHero != null) {
                awakenHero.setUsed(false);
                LogLordHelper.awakenHero(AwardFrom.RETREAT_END, player.account, player.lord, awakenHero, 0);
            } else {
                String nick = army.player != null ? army.player.lord.getNick() : null;
                LogUtil.error(String.format("nick :%s, not found awaken hero :%d, key id :%d", nick != null ? nick : "",
                        army.getForm().getAwakenHero().getHeroId(), army.getForm().getAwakenHero().getKeyId()));
            }
        } else {
            int heroId = army.getForm().getCommander();
            if (heroId > 0) {
                playerDataManager.addHero(player, heroId, 1, AwardFrom.RETREAT_END);
            }
        }

        //战术
        if (!army.getForm().getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(player, army.getForm().getTactics());
        }

        // 加资源
        Grab grab = army.getGrab();
        if (grab != null) {
            playerDataManager.gainGrab(player, grab);
            StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
            if (staticMine != null) {
                partyDataManager.collectMine(player.roleId, grab);
                activityDataManager.resourceCollect(player, ActivityConst.ACT_COLLECT_RESOURCE, grab);// 资源采集活动
                activityDataManager.beeCollect(player, ActivityConst.ACT_BEE_ID, grab);// 勤劳致富
                activityDataManager.beeCollect(player, ActivityConst.ACT_BEE_NEW_ID, grab);// 勤劳致富（新）
                activityDataManager.amyRebate(player, 0, grab.rs, ActivityConst.ACT_AMY_ID);// 建军节欢庆
                activityDataManager.amyRebate(player, 0, grab.rs, ActivityConst.ACT_AMY_ID2);// 建军节欢庆(新)
                playerDataManager.updDay7ActSchedule(player, 10, grab);
                activityKingService.updataResourceData(player, grab.rs);//最强王者

            }
        }

        // 加荣耀积分
        honourDataManager.addHonourScore(player, army.getHonourScore());

        if (army.getForm() != null) {
            //删除过期英雄
            removeExpireHero(player, army.getForm().getCommander());
        }


    }

    /**
     * 增加编制经验
     *
     * @param player
     * @param army
     * @param now    void
     */
    private void addStaffing(Player player, Army army, int now) {
        army.setStaffingTime(army.getStaffingTime() + TimeHelper.HALF_HOUR_S);
        if (TimeHelper.isStaffingOpen() && now <= army.getEndTime()) {
            StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
            int exp = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getStaffingExp();
            double ratio = staticLordDataMgr.getStaticProsLv(player.lord.getPros()).getStaffingAdd() / 100.0;
            if (army.isRuins()) { // 废墟状态 不算加成
                ratio = 0;
            }
            exp = (int) (exp * (1 + ratio));
            ratio = 0;// 计算编制经验加速buff增加的比例
            if (player.effects.containsKey(EffectType.ADD_STAFFING_COLLECT)) {
                ratio += 0.1;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_ALL)) {
                ratio += 0.1;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_AD1)) {
                ratio += 0.01;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_AD2)) {
                ratio += 0.02;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_AD3)) {
                ratio += 0.03;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_AD4)) {
                ratio += 0.04;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_AD5)) {
                ratio += 0.05;
            }
            if (player.effects.containsKey(EffectType.ADD_STAFFING_ALL2)) {
                ratio += 0.2;
            }

            Form form = army.getForm();
            if (form != null) {
                AwakenHero awakenHero = form.getAwakenHero();
                if (awakenHero != null) {
                    for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                        if (entry.getValue() <= 0) {
                            continue;
                        }
                        StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(),
                                entry.getValue());
                        if (staticHeroAwakenSkill == null) {
                            LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                            continue;
                        }
                        if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_ADD_EXP) {
                            String val = staticHeroAwakenSkill.getEffectVal();
                            if (val != null && !val.isEmpty()) {
                                ratio += (Float.valueOf(val) / 100.0f);
                            }
                        }
                    }
                }
            }

            exp += exp * ratio;
            playerDataManager.addStaffingExp(player, exp);
            army.setStaffingExp(army.getStaffingExp() + exp);

        }
    }

    /**
     * 由世界地图计时器调用 行军加速时也会调用 随着时间的推移 地图上行军部队的状态变化
     *
     * @param player
     * @param now    void
     */
    private void dealWorldAction(Player player, int now) {
        List<Army> list = player.armys;
        Iterator<Army> it = list.iterator();

        int state;
        Army army;
        while (it.hasNext()) {
            army = it.next();
            try {
                state = army.getState();
                if (now >= army.getEndTime()) {
                    if (state == ArmyState.MARCH) {// 行军结束
                        if (marchEnd(player, army, now)) {// 部队被灭
                            it.remove();
                        }
                        StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
                        if (staticMine != null) {
                            // 行军结束后增加一次矿点品质侦查效果
                            mineService.scoutMine(player, army.getTarget(), staticMine.getLv() + staffingDataManager.getWorldMineLevel());
                            army.setTarQua(mineService.getMineQuality(army.getTarget()));
                        }
                    } else if (state == ArmyState.AID) {// 援军行军结束
                        aidEnd(player, army, now);
                    } else if (state == ArmyState.RETREAT) {// 返回结束
                        retreatEnd(player, army);
                        it.remove();
                    } else if (state == ArmyState.AIRSHIP_GUARD_MARCH) {// 返回结束
                        airshipService.dealGuardArmyMarch(army, now);
                    }
                }
            } catch (Exception e) {
                LogUtil.error("行军结束，操作报错, lordId:" + player.lord.getLordId() + ", army:" + army, e);
            }
        }
    }

    /**
     * 世界地图计时器 void
     */
    public void worldTimerLogic() {
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        while (iterator.hasNext()) {
            Player player = iterator.next();
           /* if(player.is3MothLogin()){
                continue;
            }*/
            try {
                if (!player.isActive() || player.armys.isEmpty()) {
                    continue;
                }
                dealWorldAction(player, now);
            } catch (Exception e) {
                LogUtil.error("执行行军结束定时任务出现错误, lordId:" + player.lord.getLordId(), e);
            }
        }
    }

    /**
     * Method: mineStaffingLogic
     *
     * @return void
     * @throws @Description: 世界地图半小时编制经验结算
     */
    public void mineStaffingLogic() {
        Iterator<List<Guard>> it = worldDataManager.getGuardMap().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        int state;
        Army army;
        List<Guard> list;
        while (it.hasNext()) {
            list = it.next();
            if (list != null && !list.isEmpty()) {
                Guard guard = list.get(0);
                try {
                    army = guard.getArmy();
                    state = army.getState();
                    if (state == ArmyState.COLLECT && army.getStaffingTime() != 0 && now >= army.getStaffingTime()) {
                        addStaffing(guard.getPlayer(), army, now);
                    }
                } catch (Exception e) {
                    LogUtil.error("世界地图半小时编制经验结算报错, guard:" + guard, e);
                }
            }
        }
    }

    public void getScoutFreeTime(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        clearInfo(player);

        GamePb6.GetScoutFreeTimeRs.Builder builder = GamePb6.GetScoutFreeTimeRs.newBuilder();
        if (player.scoutFreeTime < System.currentTimeMillis()) {
            builder.setTime(0);
        } else {
            builder.setTime((int) (player.scoutFreeTime / 1000));
        }

        builder.setScoutCount(player.lord.getScount());

        if (player.VCODE_SCOUT_COUNT == 0) {
            // 注意：这里的赋值会在第一次侦察scoutpos()方法中又重新覆盖一次，所以实际开始第一次验证的基数是在scoutpos()方法中产生的
            player.VCODE_SCOUT_COUNT = Constant.VCODE_SCOUT_COUNT + new Random().nextInt(10);
        }

        if (player.isVerification != 0 && player.isVerification % player.VCODE_SCOUT_COUNT == 0) {
            builder.setIsVerification(1);
        } else {
            builder.setIsVerification(0);
        }

        if (!staticFunctionPlanDataMgr.isVcodeScoutOpen()) {
            builder.setIsVerification(0);
        }

        builder.setScoutFailCount(player.scoutFreeTimeCount);
        handler.sendMsgToPlayer(GamePb6.GetScoutFreeTimeRs.ext, builder.build());
    }

    private void clearInfo(Player player) {

        if (player.scoutRewardTime == 0) {
            player.scoutRewardTime = System.currentTimeMillis();
        }
        if (!DateHelper.isToday(new Date(player.scoutRewardTime))) {
            player.scoutRewardCount = 0;
            player.scoutRewardTime = System.currentTimeMillis();
            player.scoutBanCount = 0;
            player.isVerification = 0;
        }
    }

    public void refreshScoutImg(RefreshScoutImgRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (!(player.isVerification != 0 && player.isVerification % player.VCODE_SCOUT_COUNT == 0)) {
            return;
        }
        if (rq.getIsFirst()) {
            player.scoutRefreshCount = 0;
        }
        // 每次验证可刷新5次，以及第一次生成图片
        if (player.scoutRefreshCount > 6) {
            return;
        }
        RefreshScoutImgRs.Builder builder = RefreshScoutImgRs.newBuilder();
        try {
            int[] kind = staticScoutDataMgr.generateFromGenusAndSpecies();
            List<Integer> imgid = new ArrayList<>();
            // 图片总数写死是9
            List<Integer> correctImg = staticScoutDataMgr.selectCorrectImg(kind[0], kind[1], 9);
            Map<Integer, List<Integer>> map = new HashMap<>();
            map.put(TimeHelper.getCurrentSecond(), correctImg);
            player.setScoutImg(map);
            List<Integer> errorImg = staticScoutDataMgr.selectErrorImg(kind[0], kind[1], 9 - correctImg.size());
            imgid.addAll(correctImg);
            imgid.addAll(errorImg);
            RandomHelper.randomlizeList(imgid);
            if (imgid.size() != 9) {
                throw new Exception("图片总数超过9");
            }
            builder.setKindOne(kind[0]);
            builder.setKindTwo(kind[1]);
            builder.addAllImgId(imgid);
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error("生成验证码图片信息报错");
            return;
        }
        handler.sendMsgToPlayer(GamePb6.RefreshScoutImgRs.ext, builder.build());
        player.scoutRefreshCount++;
    }

    public void vCodeScout(GamePb6.VCodeScoutRq rq, ClientHandler handler) {
        List<Integer> imgIdList = rq.getImgIdList();
        if (imgIdList == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        player.scoutRefreshCount = 0;
        clearInfo(player);
        if (player.scoutFreeTime > System.currentTimeMillis()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Map<Integer, List<Integer>> scoutImg = player.getScoutImg();
        boolean flag = false;
        if (scoutImg == null || scoutImg.size() != 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        for (Map.Entry<Integer, List<Integer>> entry : scoutImg.entrySet()) {
            if (imgIdList.size() == 0) {
                break;
            }
            if (entry.getValue().containsAll(imgIdList) && imgIdList.containsAll(entry.getValue())) {
                flag = true;
            }
            break;
        }
        GamePb6.VCodeScoutRs.Builder builder = GamePb6.VCodeScoutRs.newBuilder();
        if (flag) {
            player.isVerification = 0;
            builder.setStatus(1);
            player.scoutFreeTimeCount = 0;
            if (player.scoutRewardCount < 6) {
                StaticScoutBonus staticScoutBonus = staticWorldDataMgr.getStaticScoutBonus(player.lord.getLevel());
                playerDataManager.addAward(player, AwardType.RESOURCE, 5, staticScoutBonus.getBonus(),
                        AwardFrom.VCODESCOUT);
                builder.setAward(PbHelper.createAwardPb(AwardType.RESOURCE, 5, staticScoutBonus.getBonus()));
                player.scoutRewardCount = player.scoutRewardCount + 1;
                player.scoutRewardTime = System.currentTimeMillis();
            }
            player.isVerificationState = 1;

            player.getScoutImg().clear();

        } else {
            builder.setStatus(0);
            int scoutFreeTimeCount = player.scoutFreeTimeCount + 1;
            if (scoutFreeTimeCount % 3 == 0) {
                player.scoutFreeTimeCount = 0;
                StaticScoutfreeze staticScoutfreeze = staticWorldDataMgr.getStaticScoutfreeze(player.scoutBanCount + 1);
                long time = System.currentTimeMillis() + staticScoutfreeze.getFrozenTime() * 60 * 1000l;
                player.scoutBanCount = player.scoutBanCount + 1;
                player.scoutFreeTime = time;
                player.isVerification = 0;
            } else {
                player.scoutFreeTimeCount = player.scoutFreeTimeCount + 1;
            }
        }

        if (player.scoutFreeTime < System.currentTimeMillis()) {
            builder.setTime(0);
        } else {
            builder.setTime((int) (player.scoutFreeTime / 1000));
        }
        builder.setScoutFailCount(player.scoutFreeTimeCount);
        handler.sendMsgToPlayer(GamePb6.VCodeScoutRs.ext, builder.build());

    }


    /**
     * 计算新将领采集金币
     *
     * @param player
     * @param army
     * @return
     */
    private int getNewHeroGold(Player player, Army army) {
        StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());

        //小于24级没有金币
        if (player.lord.getLevel() < 24) {
            return 0;
        }

        if (staticMine == null) {
//             staticMine = mineDataManager.evaluatePos(army.getTarget());
            return 0;
        }

        if (army.getState() == ArmyState.RETREAT) {
            return 0;
        }

        StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(), staffingDataManager.getWorldMineLevel());

        Form form = army.getForm();
        if (form == null) {
            return 0;
        }

        if (form.getCommander() == 0) {
            return 0;
        }

        StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
        if (staticHero == null || staticHero.getTime() <= 0 || staticHero.getSkillId() != 21) {
            return 0;
        }

        if (!player.herosExpiredTime.containsKey(form.getCommander())) {
            return 0;
        }

        if (army.getCaiJiStartTime() <= 0 || army.getCaiJiEndTime() <= 0) {
            return 0;
        }

        long heroEndTime = player.herosExpiredTime.get(form.getCommander());

        long now = System.currentTimeMillis();
        long endTime = 0;
        //如果结束时间大于当前时间 就用当前时间
        if (now > heroEndTime) {
            endTime = heroEndTime;
        } else {
            endTime = now;
        }

        if (endTime > army.getCaiJiEndTime()) {
            endTime = army.getCaiJiEndTime();
        }

        LogUtil.error("NewHeroGold roleId=" + player.lord.getLordId() + " start=" + DateHelper.formatDateTime(new Date(army.getCaiJiStartTime()), "yyyy-MM-dd HH:mm:ss") + " end=" + DateHelper.formatDateTime(new Date(endTime), "yyyy-MM-dd HH:mm:ss"));

        int hour = (int) (Math.floor((endTime - army.getCaiJiStartTime()) / 3600000L));

        if (hour <= 0) {
            return 0;
        }

        int caijiGold = hour * staticMineLv.getHeroGold();

        int gold = 0;

        if (army.getNewHeroSubGold() > 0) {
            gold = caijiGold - army.getNewHeroSubGold();
        } else {
            gold = caijiGold;
        }
        LogUtil.error("NewHeroGold roleId=" + player.lord.getLordId() + " hour=" + hour + " caijiGold=" + caijiGold + " sub=" + army.getNewHeroSubGold());
        if (gold < 0) {
            return 0;
        }
        return gold;
    }


    /**
     * 删除过期英雄
     *
     * @param player
     */
    public void removeExpireHero(Player player, int heroId) {
        try {
            Map<Integer, Hero> heros = player.heros;
            for (Hero h : new ArrayList<>(heros.values())) {

                StaticHero staticHero = staticHeroDataMgr.getStaticHero(h.getHeroId());
                if (staticHero != null && staticHero.getTime() > 0) {
                    if (h.getEndTime() > 0 && h.getEndTime() < System.currentTimeMillis()) {

                        Army army = getPlayerArmy(player, h.getHeroId());
                        if (army == null || (army != null && heroId == h.getHeroId())) {
                            heros.remove(h.getHeroId());
                            player.herosExpiredTime.remove(h.getHeroId());
                            player.herosCdTime.remove(h.getHeroId());

                            LogUtil.error("删除过期英雄 roleId=" + player.lord.getLordId() + " heroId=" + h.getHeroId() + " endTime=" + h.getEndTime());

                            Map<Integer, Form> forms = player.forms;
                            for (Integer f : new ArrayList<>(forms.keySet())) {
                                Form form = forms.get(f);
                                if (form.getCommander() == h.getHeroId()) {
                                    player.forms.remove(f);
                                }
                            }
                        }
                    }
                }

            }
        } catch (Exception e) {
            LogUtil.error("删除过期英雄报错", e);
        }
    }


    private Army getPlayerArmy(Player player, int heroId) {
        for (Army e : player.armys) {
            if (e.getForm().getCommander() == heroId) {
                return e;
            }
        }
        return null;
    }

    /**
     * 获取新英雄的采集金币
     *
     * @param handler
     * @param req
     */
    public void getNewHoeoGold(ClientHandler handler, GamePb6.GetNewHeroInfoRq req) {
        int keyId = req.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player == null) {
            LogUtil.error("WorldService.getNewHoeoGold null roleId=" + handler.getRoleId());
        }


        Army army = null;
        for (Army e : player.armys) {
            if (e.getKeyId() == keyId) {
                army = e;
                break;
            }
        }

        if (army == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }

        GamePb6.GetNewHeroInfoRs.Builder builder = GamePb6.GetNewHeroInfoRs.newBuilder();
        StaticHero staticHero = staticHeroDataMgr.getStaticHero(army.getForm().getCommander());

        //掠夺的金币数量
        int gold = army.getNewHeroAddGold();

        //采集的金币数量
        if (staticHero != null && staticHero.getTime() > 0 && staticHero.getSkillId() == 21) {
            gold += getNewHeroGold(player, army);
        }
        builder.setGold(gold);
        builder.setStafExp(army.getStaffingExp());
        handler.sendMsgToPlayer(GamePb6.GetNewHeroInfoRs.ext, builder.build());

    }


    /**
     * 清除新英雄cd
     *
     * @param handler
     * @param req
     */
    public void clearHeroCd(ClientHandler handler, GamePb6.ClearHeroCdRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (!player.heros.containsKey(req.getHeroId())) {
            handler.sendErrorMsgToPlayer(GameError.NO_HERO);
            return;
        }

        Hero hero = player.heros.get(req.getHeroId());
        if (hero.getEndTime() > 0 && hero.getEndTime() < System.currentTimeMillis()) {
            handler.sendErrorMsgToPlayer(GameError.NO_HERO);
            return;
        }


        long cd = player.heros.get(req.getHeroId()).getCd();
        if (cd < System.currentTimeMillis()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        if (player.newHeroAddClearCdTime != 0 && !DateHelper.isToday(new Date(player.newHeroAddClearCdTime))) {
            player.heroClearCdCount.clear();
            player.newHeroAddClearCdTime = System.currentTimeMillis();
        }

        int count = 0;

        if (player.heroClearCdCount.containsKey(req.getHeroId())) {
            count = player.heroClearCdCount.get(req.getHeroId());
        }

        if (count >= Constant.NEW_HERO_COUNT) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        int time = (int) Math.ceil((cd - System.currentTimeMillis()) / 60000f);
        int decrGold = (int) Math.ceil(time * (Constant.NEW_HERO_CD_PRICE / 100.0f));
//        LogUtil.info("time "+time);
//        LogUtil.info("decrGold "+decrGold);

        if (player.lord.getGold() < decrGold) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        count++;
        player.heroClearCdCount.put(req.getHeroId(), count);
        player.newHeroAddClearCdTime = System.currentTimeMillis();
        playerDataManager.subGold(player, decrGold, AwardFrom.NEW_BERO_CLEAR_CD);
        player.heros.get(req.getHeroId()).setCd(0);
        player.herosCdTime.remove(req.getHeroId());
        GamePb6.ClearHeroCdRs.Builder builder = GamePb6.ClearHeroCdRs.newBuilder();
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.ClearHeroCdRs.ext, builder.build());

    }

    /**
     * 获取英雄cd时间
     *
     * @param handler
     * @param req
     */
    public void getHeroCd(ClientHandler handler, GamePb6.GetHeroCdRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player.newHeroAddClearCdTime != 0 && !DateHelper.isToday(new Date(player.newHeroAddClearCdTime))) {
            player.heroClearCdCount.clear();
            player.newHeroAddClearCdTime = System.currentTimeMillis();
        }

        GamePb6.GetHeroCdRs.Builder builder = GamePb6.GetHeroCdRs.newBuilder();

        Map<Integer, Long> herosCdTime = new HashMap<>(player.herosCdTime);
        if (!herosCdTime.isEmpty()) {
            for (Map.Entry<Integer, Long> e : herosCdTime.entrySet()) {
                if (e.getValue() < System.currentTimeMillis()) {
                    player.herosCdTime.remove(e.getKey());
                } else {
                    CommonPb.TwoLong.Builder to = CommonPb.TwoLong.newBuilder();
                    to.setV1(e.getKey());
                    to.setV2(e.getValue());
                    builder.addHeroCd(to.build());
                }

            }
        }

        Set<Map.Entry<Integer, Integer>> entries = player.heroClearCdCount.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addHeroClearCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetHeroCdRs.ext, builder.build());


    }

    /**
     * 获取英雄过期时间
     *
     * @param handler
     * @param req
     */
    public void getHeroEndTime(ClientHandler handler, GamePb6.GetHeroEndTimeRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GamePb6.GetHeroEndTimeRs.Builder builder = GamePb6.GetHeroEndTimeRs.newBuilder();
        Map<Integer, Long> herosCdTime = new HashMap<>(player.herosExpiredTime);
        if (!herosCdTime.isEmpty()) {
            for (Map.Entry<Integer, Long> e : herosCdTime.entrySet()) {
                CommonPb.TwoLong.Builder to = CommonPb.TwoLong.newBuilder();
                to.setV1(e.getKey());
                to.setV2(e.getValue());
                builder.addHeroEndTime(to.build());
            }
        }
        handler.sendMsgToPlayer(GamePb6.GetHeroEndTimeRs.ext, builder.build());


    }


    /**
     * 世界矿点编制经验
     *
     * @param rq
     * @param handler
     */
    public void getWorldStaffing(GamePb6.GetWorldStaffingRq rq, ClientHandler handler) {
        //世界等级开始衰减
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        WorldStaffing worldStaffing = globalDataManager.gameGlobal.getWorldStaffing();
        GamePb6.GetWorldStaffingRs.Builder builder = GamePb6.GetWorldStaffingRs.newBuilder();
        builder.setDayExp(player.contributionWorldStaffing);
        builder.setWorldExp(worldStaffing.getExp());
        handler.sendMsgToPlayer(GamePb6.GetWorldStaffingRs.ext, builder.build());
    }

    /**
     * gm增加世界矿点编制经验
     *
     * @param player
     * @param exp
     */
    public void gmAddWorldStaffing(Player player, int exp, int roleExp) {
        WorldStaffing worldStaffing = globalDataManager.gameGlobal.getWorldStaffing();
        long oldExp = worldStaffing.getExp();
        worldStaffing.setExp(worldStaffing.getExp() + exp);

        if (worldStaffing.getExp() < 0) {
            worldStaffing.setExp(0);
        }

        player.contributionWorldStaffing = player.contributionWorldStaffing + roleExp;
        if (player.contributionWorldStaffing < 0) {
            player.contributionWorldStaffing = 0;
        }
        Map<Long, Player> players = playerDataManager.getPlayers();

        for (Player p : players.values()) {

            try {

                if (p.isLogin) {
                    GamePb6.SynWorldStaffingRq.Builder builder = GamePb6.SynWorldStaffingRq.newBuilder();
                    builder.setWorldExp(worldStaffing.getExp());
                    builder.setDayExp(p.contributionWorldStaffing);
                    BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynWorldStaffingRq.EXT_FIELD_NUMBER, GamePb6.SynWorldStaffingRq.ext, builder.build());
                    GameServer.getInstance().synMsgToPlayer(p.ctx, msg);
                }

            } catch (Exception e) {
                LogUtil.error(e);
            }

        }
        staffingDataManager.changeWorldLevel(oldExp);
        staffingDataManager.recollectArmy((int) (System.currentTimeMillis() / 1000));

    }

    /**
     * 根据好友度额外计算掠夺的资源量
     *
     * @param player 玩家
     * @param target 被攻击玩家
     * @param load   掠夺量
     */
    private long calcExtraLoadByFriendliness(Player player, Player target, long load) {
        //如果双方不互为好友则不计算
        if (!playerDataManager.checkMutualFriend(player.roleId, target.roleId)) {
            return load;
        }

        Friend friend = player.friends.get(target.roleId);

        List<FriendlinessResourceRate> friendlinessResourceRates = staticIniDataMgr.getFriendlinessResourceRates(SystemId.FRIENDLIESS_RESOURCE_RATE);
        if (CollectionUtils.isEmpty(friendlinessResourceRates)) {
            return load;
        }
        for (FriendlinessResourceRate resourceRate : friendlinessResourceRates) {
            if (friend.getFriendliness() >= resourceRate.getMin() && friend.getFriendliness() <= resourceRate.getMax()) {
                load = (long) (load * (1 + (double) resourceRate.getRate() / 100));
            } else {
                continue;
            }
        }
        return load;
    }


}


