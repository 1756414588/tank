/**
 * @Title: SeniorMineService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2016年3月15日 下午2:55:00
 * @version V1.0
 */
package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.SeniorPartyScoreRank;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.Report;
import com.game.pb.CommonPb.RptAtkMine;
import com.game.pb.CommonPb.RptScoutMine;
import com.game.pb.GamePb3.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author ZhangJun
 * @ClassName: SeniorMineService
 * @Description: 军事矿区相关逻辑
 * @date 2016年3月15日 下午2:55:00
 */
@Component
public class SeniorMineService {

    @Autowired
    private SeniorMineDataManager mineDataManager;

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private FightService fightService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PlayerService playerService;
    @Autowired
    private StaffingDataManager staffingDataManager;

    private static int[] OCCUPA_SCORE = {50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88};

    private static int[] ROB_SCORE = {50 * 3, 52 * 3, 54 * 3, 56 * 3, 58 * 3, 60 * 3, 62 * 3, 64 * 3, 66 * 3, 68 * 3, 70 * 3, 72 * 3, 74 * 3, 76 * 3, 78 * 3, 80 * 3, 82 * 3, 84 * 3, 86 * 3, 88 * 3};

    /**
     * 军事矿地图
     *
     * @param handler void
     */
    public void getSeniorMap(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        refreshSenior(player);

        int playerPartyId = partyDataManager.getPartyId(player.roleId);

        List<Guard> list;
        Guard guard;
        int partyId;
        boolean sameParty;
        Iterator<List<Guard>> it = mineDataManager.getGuardMap().values().iterator();
        GetSeniorMapRs.Builder builder = GetSeniorMapRs.newBuilder();

        while (it.hasNext()) {
            list = it.next();
            if (list != null && !list.isEmpty()) {
                guard = list.get(0);
                sameParty = false;
                if (playerPartyId != 0) {
                    partyId = partyDataManager.getPartyId(guard.getPlayer().roleId);
                    if (partyId == playerPartyId) {
                        sameParty = true;
                    }
                }

                builder.addData(PbHelper.createSeniorMapDataPb(player, guard.getPlayer(), guard.getArmy(), sameParty, guard.getFreeWarTime(), guard.getStartFreeWarTime()));
            }
        }

        builder.setCount(player.seniorCount);
        builder.setLimit(5);
        builder.setBuy(player.seniorBuy);
        handler.sendMsgToPlayer(GetSeniorMapRs.ext, builder.build());
    }

    /**
     * 侦查矿点协议处理
     *
     * @param pos
     * @param handler void
     */
    public void scout(int pos, ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {// 结算
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_DAY);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        //检查并重置侦查次数
        int nowDay = TimeHelper.getCurrentDay();
        playerService.checkAndResetScount(player, nowDay);

        scoutMine(player, pos, handler);
    }

    /**
     * 侦查矿点
     *
     * @param player
     * @param pos
     * @param handler void
     */
    private void scoutMine(Player player, int pos, ClientHandler handler) {
        StaticMine staticMine = mineDataManager.evaluatePos(pos);
        if (staticMine != null) {
            Lord lord = player.lord;
            int scount = lord.getScount() + 1;
            long scountCost = worldDataManager.getScoutNeedStone(lord, staticMine.getLv() + staffingDataManager.getWorldMineLevel(), 1);
            if (player.resource.getStone() < scountCost) {
                handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
                return;
            }
            lord.setScount(scount);
            RptScoutMine.Builder rptMine = RptScoutMine.newBuilder();

            int product = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getProduction();
            int now = TimeHelper.getCurrentSecond();

            Guard guard = mineDataManager.getMineGuard(pos);
            if (guard != null) {// 有驻军
                Army army = guard.getArmy();
                if (army.getOccupy()) {

                    long time = (army.getCaiJiStartTime() / 1000) + 1800 + (guard.getFreeWarTime() - guard.getStartFreeWarTime()) / 1000;

                    if (now < time) {
                        handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
                        return;
                    }
                } else {

                    if (guard.isFreeWar()) {
                        handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
                        return;
                    }

                }


                rptMine.setForm(PbHelper.createFormPb(army.getForm()));
                String partyName = partyDataManager.getPartyNameByLordId(guard.getPlayer().roleId);
                if (partyName != null) {
                    rptMine.setParty(partyName);
                }

                rptMine.setFriend(guard.getPlayer().lord.getNick());
                rptMine.setHarvest(playerDataManager.calcCollect(guard.getPlayer(), army, now, staticMine, product));
            } else {// 无驻军
                rptMine.setForm(PbHelper.createFormPb(mineDataManager.getMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel()).getForm()));
            }

            rptMine.setPos(pos);
            rptMine.setLv(staticMine.getLv() + staffingDataManager.getWorldMineLevel());
            rptMine.setProduct(product);
            rptMine.setMine(staticMine.getType());

            Report.Builder report = Report.newBuilder();
            report.setScoutMine(rptMine);
            report.setTime(now);

            Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.MOLD_SENIOR_MINE_SCOUT, TimeHelper.getCurrentSecond(),
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_MINE);

            SctSeniorMineRs.Builder builder = SctSeniorMineRs.newBuilder();
            builder.setMail(PbHelper.createMailPb(mail));
            handler.sendMsgToPlayer(SctSeniorMineRs.ext, builder.build());
        } else {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
        }

    }

    /**
     * 每天重置军事矿区掠夺次数
     *
     * @param player void
     */
    private void refreshSenior(Player player) {
        int day = TimeHelper.getCurrentDay();
        if (day != player.seniorDay) {
            player.seniorDay = day;
            player.seniorCount = 5;
            player.seniorBuy = 0;
        }

        // int week = TimeHelper.getCurrentWeek();
        // if (week != player.seniorWeek) {
        // player.seniorWeek = week;
        // player.seniorScore = 0;
        // player.seniorAward = 0;
        // }
    }

    /**
     * 进攻军事矿区
     *
     * @param req
     * @param handler void
     */
    public void attack(AtkSeniorMineRq req, ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {// 结算
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_DAY);
            return;
        }

        int pos = req.getPos();
        int type = req.getType();

        Player attacker = playerDataManager.getPlayer(handler.getRoleId());
        if (attacker == null) {
//			LogHelper.ERROR_LOGGER.error("attack nul!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
            LogUtil.error("attack null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
        }

        if (attacker.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        if (attacker.lord.getPower() < 1) {
            handler.sendErrorMsgToPlayer(GameError.NO_POWER);
            return;
        }

//		int armyCount = attacker.armys.size();
//		for (Army army : attacker.armys) {
//			if (army.getState() == ArmyState.WAR) {
//				armyCount -= 1;
//				break;
//			}
//		}

        int maxCount = playerDataManager.armyCount(attacker);
        if (playerDataManager.getPlayArmyCount(attacker, maxCount) >= maxCount) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }

//		if (armyCount >= playerDataManager.armyCount(attacker)) {
//			handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
//			return;
//		}

        refreshSenior(attacker);

        StaticMine staticMine = mineDataManager.evaluatePos(pos);
        if (staticMine != null) {// 打矿
            Guard guard = mineDataManager.getMineGuard(pos);
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

                if (type == 2) {
                    handler.sendErrorMsgToPlayer(GameError.SENIOR_ATTACK_1);
                    return;
                }

                if (attacker.seniorCount < 1) {
                    handler.sendErrorMsgToPlayer(GameError.NO_SENIOR_COUNT);
                    return;
                }

                Army guardArmy = guard.getArmy();
                int now = TimeHelper.getCurrentSecond();
                if (guardArmy.getOccupy()) {
                    long time = (guardArmy.getCaiJiStartTime() / 1000) + 1800 + (guard.getFreeWarTime() - guard.getStartFreeWarTime()) / 1000;
                    if (now < time) {
                        handler.sendErrorMsgToPlayer(GameError.ATTACK_FREE);
                        return;
                    }
                }

                Form attackForm = PbHelper.createForm(req.getForm());
                StaticHero staticHero = null;
                int heroId = 0;
                AwakenHero awakenHero = null;
                Hero hero = null;
                if (attackForm.getAwakenHero() != null) {//使用觉醒将领
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
                if (!playerDataManager.checkAndSubTank(attacker, attackForm, maxTankCount, AwardFrom.ATK_SENIOR_MINE)) {
                    handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
                    return;
                }

                if (hero != null) {
                    playerDataManager.addHero(attacker, hero.getHeroId(), -1, AwardFrom.ATK_SENIOR_MINE);
                }

                if (awakenHero != null) {
                    awakenHero.setUsed(true);
                    LogLordHelper.awakenHero(AwardFrom.ATK_SENIOR_MINE, attacker.account, attacker.lord, awakenHero, 0);
                }


                //使用战术
                if (!attackForm.getTactics().isEmpty()) {
                    tacticsService.useTactics(attacker, attackForm.getTactics());
                }


                Army army = new Army(attacker.maxKey(), pos, ArmyState.MARCH, attackForm, 0, now, playerDataManager.isRuins(attacker));
                army.setSenior(true);
                attacker.armys.add(army);

                AtkSeniorMineRs.Builder builder = AtkSeniorMineRs.newBuilder();

                if (fightMineGuard(attacker, army, staticMine, guard, now)) {
                    attacker.armys.remove(army);
                } else {
                    builder.setArmy(PbHelper.createArmyPb(army));
                }

                attacker.seniorCount = attacker.seniorCount - 1;

                playerDataManager.subPower(attacker.lord, 1);

                builder.setCount(attacker.seniorCount);
                handler.sendMsgToPlayer(AtkSeniorMineRs.ext, builder.build());

            } else {
                if (type == 1) {
                    handler.sendErrorMsgToPlayer(GameError.SENIOR_ATTACK_2);
                    return;
                }

                Form attackForm = PbHelper.createForm(req.getForm());
                StaticHero staticHero = null;
                Hero hero = null;
                int heroId = 0;
                AwakenHero awakenHero = null;
                if (attackForm.getAwakenHero() != null) {//使用觉醒将领
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
                if (!playerDataManager.checkAndSubTank(attacker, attackForm, maxTankCount, AwardFrom.ATK_SENIOR_MINE)) {
                    handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
                    return;
                }


                if (hero != null) {
                    playerDataManager.addHero(attacker, hero.getHeroId(), -1, AwardFrom.ATK_SENIOR_MINE);
                }

                if (awakenHero != null) {
                    awakenHero.setUsed(true);
                    LogLordHelper.awakenHero(AwardFrom.ATK_SENIOR_MINE, attacker.account, attacker.lord, awakenHero, 0);
                }

                //使用战术
                if (!attackForm.getTactics().isEmpty()) {
                    tacticsService.useTactics(attacker, attackForm.getTactics());
                }


                int now = TimeHelper.getCurrentSecond();
                Army army = new Army(attacker.maxKey(), pos, ArmyState.MARCH, attackForm, 0, now, playerDataManager.isRuins(attacker));
                army.setSenior(true);
                army.setOccupy(true);
                attacker.armys.add(army);

                AtkSeniorMineRs.Builder builder = AtkSeniorMineRs.newBuilder();

                if (fightMineNpc(attacker, army, staticMine, now)) {
                    attacker.armys.remove(army);
                } else {
                    builder.setArmy(PbHelper.createArmyPb(army));
                }

                playerDataManager.subPower(attacker.lord, 1);

                builder.setCount(attacker.seniorCount);
                handler.sendMsgToPlayer(AtkSeniorMineRs.ext, builder.build());
            }
        } else {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
            return;
        }
    }

    /**
     * fighter的force给到form
     *
     * @param fighter
     * @param form    void
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
     * 计算坦克消耗和待修理坦克
     *
     * @param player
     * @param fighter
     * @param form
     * @param ratio
     * @return Map<Integer       ,       RptTank>
     */
    private Map<Integer, RptTank> haustArmyTank(Player player, Fighter fighter, Form form, double ratio) {
        Map<Integer, RptTank> map = new HashMap<>();
        Map<Integer, Tank> tanks = player.tanks;
        int killed = 0;
        int tankId = 0;
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
            RptTank rptTank = (RptTank) it.next();
            killed = rptTank.getCount();
            int repair = (int) Math.ceil(ratio * killed);

            Tank tank = tanks.get(rptTank.getTankId());
            // tank.setRest(tank.getRest() + repair);
            tank.setCount(tank.getCount() + repair);
            LogLordHelper.tank(AwardFrom.ATK_SENIOR_MINE, player.account, player.lord, tank.getTankId(),
                    tank.getCount(), repair, repair - killed, 0);
        }

        if (map.isEmpty()) {
            LogLordHelper.tank(AwardFrom.ATK_SENIOR_MINE, player.account, player.lord, -1,
                    0, 0, 0, 0);
        }

        subForceToForm(fighter, form);
        return map;
    }


    /**
     * 计算坦克消耗和待修理坦克
     *
     * @param player
     * @param fighter
     * @param form
     * @param ratio
     * @return Map<Integer       ,       RptTank>
     */
    private Map<Integer, RptTank> haustRargetArmyTank(Player player, Fighter fighter, Form form, double ratio, Form attForm) {
        Map<Integer, RptTank> map = new HashMap<>();
        Map<Integer, Tank> tanks = player.tanks;
        int killed = 0;
        int tankId = 0;
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

        float ratioNew = 0.1f;

        if (attForm != null) {
            AwakenHero awakenHero = attForm.getAwakenHero();
            if (awakenHero != null) {
                for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                    if (entry.getValue() <= 0) {
                        continue;
                    }
                    StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                    if (staticHeroAwakenSkill == null) {
                        LogUtil.error("觉醒将领技能未配c置:" + entry.getKey() + " 等级:" + entry.getValue());
                        continue;
                    }
                    if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_SUB_TANK) {
                        String val = staticHeroAwakenSkill.getEffectVal();
                        if (val != null && !val.isEmpty()) {
                            ratioNew += (Float.valueOf(val) / 100.0f);
                        }
                    }
                }
            }
        }


        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = (RptTank) it.next();
            killed = rptTank.getCount();

            if (ratioNew > 1) {
                ratioNew = 1.0f;
            }

            int repair = (int) Math.ceil(killed * (1.0f - ratioNew));
            Tank tank = tanks.get(rptTank.getTankId());
            tank.setCount(tank.getCount() + repair);
            LogLordHelper.tank(AwardFrom.ATK_SENIOR_MINE, player.account, player.lord, tank.getTankId(),
                    tank.getCount(), repair, repair - killed, 0);
        }
        if (map.isEmpty()) {
            LogLordHelper.tank(AwardFrom.ATK_SENIOR_MINE, player.account, player.lord, -1,
                    0, 0, 0, 0);
        }
        subForceToForm(fighter, form);
        return map;
    }


    /**
     * 炸矿后重新采集
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
     */
    public void recollectArmy(Player player, Army army, int now, StaticMine staticMine, int collect, long get) {
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
        Collect c = army.getCollect();
        if (c != null) {
            c.load = load;
            speedAdd = c.speed;
        } else {
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

            c = new Collect();
            c.speed = speedAdd;
            c.load = load;
            army.setCollect(c);
        }

        long loadFree = 0;
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

        // 这里使用时改变了occupy的语义，这里是表示该部队不处于保护中了
        army.setOccupy(false);
    }

    /**
     * 矿被炸了 移除防守部队
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
        //取消战术
        if (!army.getForm().getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(target, army.getForm().getTactics());
        }
        mineDataManager.removeGuard(guard);
    }

    /**
     * @param player
     * @param army
     * @param staticMine
     * @param guard
     * @param now
     * @return boolean
     * @throws
     * @Title: fightMineGuard
     * @Description: 攻击的矿点有玩家驻守
     */
    private boolean fightMineGuard(Player player, Army army, StaticMine staticMine, Guard guard, int now) {
        int pos = army.getTarget();
        Player guardPlayer = guard.getPlayer();
        Form targetForm = guard.getArmy().getForm();

        StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
        long get = playerDataManager.calcCollect(guardPlayer, guard.getArmy(), now, staticMine, staticMineLv.getProduction());

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
        Fighter defencer = fightService.createFighter(guardPlayer, targetForm, AttackType.ACK_DEFAULT_PLAYER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_1, true);
        fightLogic.packForm(army.getForm(), targetForm);
        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = 0.9;
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio);
        Map<Integer, RptTank> defenceHaust = haustRargetArmyTank(guardPlayer, defencer, targetForm, worldRatio, army.getForm());

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

        //战功计算 0-攻方战功,1-防守方战功
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
        rptAtkMine.setDefencer(createRptMine(pos, staticMine, guardPlayer, targetForm.getHero(), defenceHaust, mplts != null ? mplts[1] : null, defencer.firstValue));
        rptAtkMine.setRecord(record);

        boolean deltArmy = false;

        if (result == 1) {// 攻方胜利
            playerDataManager.activeBoxDrop(player);
            int score = ROB_SCORE[(staticMine.getLv() + staffingDataManager.getWorldMineLevel() - 62) / 2];
            player.seniorScore += score;
            mineDataManager.setScoreRank(player);
            PartyData party = partyDataManager.getPartyByLordId(player.roleId);
            if (party != null) {
                party.setScore(party.getScore() + score);
                mineDataManager.setPartyScoreRank(party);
                LogLordHelper.partyScore(party, player, score);
            }

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
            if (attacker.isReborn) {
                deltArmy = true;
                backHero(player, army.getForm());
                ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                playerDataManager.synArmyToPlayer(player, guardStatu);
            } else {
                collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), get);
            }

            rptAtkMine.setResult(true);
            long param = 0;
            if (army.getGrab() != null) {
                rptAtkMine.setGrab(PbHelper.createGrabPb(army.getGrab()));
                param = army.getGrab().rs[0] + army.getGrab().rs[1] + army.getGrab().rs[2] + army.getGrab().rs[3] + army.getGrab().rs[4];
            }

            RptAtkMine rpt = rptAtkMine.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_WIN, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_DEFEND_LOSE, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);

            partyDataManager.addPartyTrend(13, guardPlayer, player, String.valueOf(param));// 军团军情

//			activityDataManager.profoto(player, staticMine.getLv()+staffingDataManager.getWorldMineLevel());// 哈洛克宝藏活动

            playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3));
            return deltArmy;
        } else if (result == 2) {
            rptAtkMine.setResult(false);
            backHero(player, army.getForm());

            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, staticMineLv.getProduction(), get);

            RptAtkMine rpt = rptAtkMine.build();
            Mail mail = playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_DEFEND_WIN, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            // 分享战力top
            chatService.shareChallengeFightRankTop5(player, guardPlayer, mail, result);

            partyDataManager.addPartyTrend(12, guardPlayer, player, null);
            if (defencer.isReborn) {
                backHero(guardPlayer, guard.getArmy().getForm());
                mineDataManager.removeGuard(guard);
                guardPlayer.armys.remove(guard.getArmy());

                playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 3));
            } else {
                playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4));
            }
            return true;
        } else {
            rptAtkMine.setResult(false);

            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, staticMineLv.getProduction(), get);

            playerDataManager.retreatEnd(player, army);

            RptAtkMine rpt = rptAtkMine.build();

            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            playerDataManager.sendReportMail(guardPlayer, createDefMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_DEFEND_WIN, now, player.lord.getNick(),
                    String.valueOf(player.lord.getLevel()));

            playerDataManager.synArmyToPlayer(guardPlayer, new ArmyStatu(guardPlayer.roleId, guard.getArmy().getKeyId(), 4));
            return true;
        }
    }

    /**
     * 创建玩家战损序列化对象
     *
     * @param player
     * @param hero
     * @param haust
     * @param prosAdd
     * @param mplt
     * @param firstValue
     * @return CommonPb.RptMan
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
        if (mplt != null) {
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
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 创建 矿点战损序列化对象
     *
     * @param pos        坐标
     * @param staticMine 矿点配置信息
     * @param haust      坦克损失
     * @param firstValue 先手值
     * @return CommonPb.RptMine
     */
    private CommonPb.RptMine createRptMine(int pos, StaticMine staticMine, Map<Integer, RptTank> haust, int firstValue) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        builder.setMine(staticMine.getType());
        builder.setLv(staticMine.getLv() + staffingDataManager.getWorldMineLevel());
        builder.setPos(pos);
        builder.setFirstValue(firstValue);
        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(PbHelper.createRtpTankPb(it.next()));
            }
        }

        return builder.build();
    }

    /**
     * 创建 矿点战损序列化对象
     *
     * @param pos
     * @param staticMine
     * @param guard      防守方
     * @param hero       英雄
     * @param haust
     * @param mplt       军工
     * @param firstValue
     * @return CommonPb.RptMine
     */
    private CommonPb.RptMine createRptMine(int pos, StaticMine staticMine, Player guard, int hero, Map<Integer, RptTank> haust, Long mplt, int firstValue) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        Lord lord = guard.lord;
        builder.setPos(pos);
        builder.setMine(staticMine.getType());
        builder.setLv(staticMine.getLv() + staffingDataManager.getWorldMineLevel());
        builder.setName(lord.getNick());
        builder.setVip(lord.getVip());
        builder.setFirstValue(firstValue);
        if (mplt != null) {
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
     * 采集
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
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

        collect = (int) (collect * (1 + speedAdd / NumberHelper.HUNDRED_FLOAT));

        int collectTime = (int) (loadFree / (collect / (double) TimeHelper.HOUR_S));
        army.setState(ArmyState.COLLECT);
        army.setPeriod(collectTime);
        army.setEndTime(now + collectTime);
        army.setStaffingTime(now + TimeHelper.HALF_HOUR_S);

        army.setCaiJiStartTime(System.currentTimeMillis());
        army.setCaiJiEndTime(army.getEndTime() * 1000L);

        Collect c = new Collect();
        c.speed = speedAdd;
        c.load = load;
        army.setCollect(c);


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
                    LogUtil.error("觉醒将领技能未配置dd:" + entry.getKey() + " 等级:" + entry.getValue());
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


        mineDataManager.setGuard(guard);
    }

    /**
     * 攻击矿点战报
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
     * 防守矿点战报
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
     * 回收武将
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

        //取消战术
        if (!form.getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(player, form.getTactics());
        }

    }

    // public void retreatEnd(Player player, Army army) {
    // // 部队返回
    // int[] p = army.getForm().p;
    // int[] c = army.getForm().c;
    // for (int i = 0; i < p.length; i++) {
    // if (p[i] > 0 && c[i] > 0) {
    // playerDataManager.addTank(player, p[i], c[i]);
    // }
    // }
    // // 将领返回
    // int heroId = army.getForm().getCommander();
    // if (heroId > 0) {
    // playerDataManager.addHero(player, heroId, 1);
    // }
    //
    // // 加资源
    // Grab grab = army.getGrab();
    // if (grab != null) {
    // playerDataManager.gainGrab(player, grab);
    // StaticMine staticMine = mineDataManager.evaluatePos(army.getTarget());
    // if (staticMine != null) {
    // partyDataManager.collectMine(player.roleId, grab);
    // activityDataManager.resourceCollect(player,
    // ActivityConst.ACT_COLLECT_RESOURCE, grab);// 资源采集活动
    // activityDataManager.beeCollect(player,
    // ActivityConst.ACT_COLLECT_RESOURCE, grab);// 勤劳致富
    // activityDataManager.amyRebate(player, 0, grab.rs);// 建军节欢庆
    // }
    // }
    // }

    /**
     * 攻击NPC矿点
     *
     * @param player
     * @param army
     * @param staticMine
     * @param now
     * @return boolean
     */
    private boolean fightMineNpc(Player player, Army army, StaticMine staticMine, int now) {
        int pos = army.getTarget();
        StaticMineForm staticMineForm = mineDataManager.getMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_OTHER);
        Fighter defencer = fightService.createFighter(staticMineForm);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.ATTACKER, true);
        fightLogic.packForm(army.getForm(), PbHelper.createForm(staticMineForm.getForm()));

        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = 0.9;
        Map<Integer, RptTank> attackHaust = haustArmyTank(player, attacker, army.getForm(), worldRatio);
        Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);

        //战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, null);
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

        boolean deltArmy = false;

        if (result == 1) {// 攻方胜利
            playerDataManager.activeBoxDrop(player);
            mineDataManager.resetMineForm(pos, staticMine.getLv() + staffingDataManager.getWorldMineLevel());

            int score = OCCUPA_SCORE[(staticMine.getLv() + staffingDataManager.getWorldMineLevel() - 62) / 2];
            player.seniorScore += score;
            mineDataManager.setScoreRank(player);
            PartyData party = partyDataManager.getPartyByLordId(player.roleId);
            if (party != null) {
                party.setScore(party.getScore() + score);
                mineDataManager.setPartyScoreRank(party);
                LogLordHelper.partyScore(party, player, score);
            }

            StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel());
            int heroId = army.getForm().getCommander();
            StaticHero staticHero = null;
            if (heroId != 0) {
                staticHero = staticHeroDataMgr.getStaticHero(heroId);
            }

            int exp = (int) (staticMineLv.getExp() * fightService.effectMineExpAdd(player, staticHero));
            playerDataManager.addExp(player, exp);

            Award award = mineDropOneAward(player, staticMine.getDropOne());
            if (attacker.isReborn) {
                deltArmy = true;
                backHero(player, army.getForm());
                ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                playerDataManager.synArmyToPlayer(player, guardStatu);
            } else {
                collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), 0);
            }

            int realExp = playerDataManager.realExp(player, exp);
            rptAtkMine.setResult(true);
            rptAtkMine.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp));
            if (award != null) {
                StaticProp staticProp = staticPropDataMgr.getStaticProp(award.getId());
                if (staticProp != null && staticProp.getColor() >= 4) {
                    chatService.sendWorldChat(chatService.createSysChat(SysChatId.ATTACK_MINE, player.lord.getNick(), staticProp.getPropName()));
                }

                rptAtkMine.addAward(award);
            }

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_WIN, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

//			activityDataManager.profoto(player, staticMine.getLv()+staffingDataManager.getWorldMineLevel());// 哈洛克宝藏活动
            return deltArmy;
        } else if (result == 2) {
            backHero(player, army.getForm());
            rptAtkMine.setResult(false);

            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            return true;
        } else {
            rptAtkMine.setResult(false);

            playerDataManager.retreatEnd(player, army);
            RptAtkMine rpt = rptAtkMine.build();
            playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.MOLD_SENIOR_MINE_ATTACK_LOSE, now,
                    String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()));

            return true;
        }

    }

    /**
     * 军事矿区采矿排名
     *
     * @param handler void
     */
    public void scoreRank(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        ScoreRankRs.Builder builder = ScoreRankRs.newBuilder();
        for (SeniorScoreRank one : mineDataManager.getScoreRankList()) {
            Player target = playerDataManager.getPlayer(one.getLordId());
            builder.addScoreRank(PbHelper.createScoreRankPb(target.lord.getNick(), one));
        }

        Tuple<Integer, SeniorScoreRank> rank = mineDataManager.getScoreRank(player.roleId);
        builder.setRank(rank.getA());
        builder.setScore(player.seniorScore);

        int canGet = 0;
        if (mineDataManager.getSeniorState() == SeniorState.END_STATE) {// 结算
            if (rank.getA() > 0 && rank.getA() < 11) {
                if (!rank.getB().getGet()) {
                    canGet = 1;
                } else {
                    canGet = 2;
                }
            }
        }

        builder.setCanGet(canGet);
        handler.sendMsgToPlayer(ScoreRankRs.ext, builder.build());
    }

    /**
     * 军事矿采集军团排名
     *
     * @param handler void
     */
    public void scorePartyRank(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        ScorePartyRankRs.Builder builder = ScorePartyRankRs.newBuilder();
        for (SeniorPartyScoreRank one : mineDataManager.getScorePartyRankList()) {
            PartyData party = partyDataManager.getParty(one.getPartyId());
            if (party != null) {
                builder.addScoreRank(PbHelper.createScoreRankPb(party.getPartyName(), one));
            }
        }

        int canGet = 0;
        int rankOrder = 0;
        int score = 0;
        PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);
        if (partyData != null) {
            Tuple<Integer, SeniorPartyScoreRank> rank = mineDataManager.getPartyScoreRank(partyData.getPartyId());
            rankOrder = rank.getA();
            score = partyData.getScore();
            if (mineDataManager.getSeniorState() == SeniorState.END_STATE) {
                if (rank.getA() > 0 && rank.getA() < 6) {
                    if (player.seniorAward == 0) {
                        canGet = 1;
                    } else {
                        canGet = 2;
                    }
                }
            }
        }

        builder.setScore(score);
        builder.setRank(rankOrder);
        builder.setCanGet(canGet);
        handler.sendMsgToPlayer(ScorePartyRankRs.ext, builder.build());
    }

    /**
     * 购买掠夺次数
     *
     * @param handler void
     */
    public void buySenior(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_DAY);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        refreshSenior(player);

        int buyCount = player.seniorBuy;

        int cost = 5 * (buyCount + 1);
        if (player.lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, cost, AwardFrom.BUY_SENIOR);
        player.seniorBuy++;
        player.seniorCount++;

        BuySeniorRs.Builder builder = BuySeniorRs.newBuilder();
        builder.setCount(player.seniorCount);
        builder.setGold(player.lord.getGold());
        builder.setBuy(player.seniorBuy);
        handler.sendMsgToPlayer(BuySeniorRs.ext, builder.build());
    }

    /**
     * 军事矿采集排行奖励
     *
     * @param handler void
     */
    public void scoreAward(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_NOT_END);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        refreshSenior(player);

        Tuple<Integer, SeniorScoreRank> rank = mineDataManager.getScoreRank(player.roleId);

        if (rank.getA() > 0 && rank.getA() < 11) {
            if (rank.getB().getGet()) {
                handler.sendErrorMsgToPlayer(GameError.ALREADY_GET_AWARD);
                return;
            }
        } else {
            handler.sendErrorMsgToPlayer(GameError.NOT_ON_SCORE_RANK);
            return;
        }

        rank.getB().setGet(true);

        ScoreAwardRs.Builder builder = ScoreAwardRs.newBuilder();

        List<List<Integer>> awards = staticWarAwardDataMgr.getScoreAward(rank.getA());
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.SCORE_AWARD));
        handler.sendMsgToPlayer(ScoreAwardRs.ext, builder.build());
    }

    /**
     * 军事矿军团排行奖励
     *
     * @param handler void
     */
    public void partyScoreAward(ClientHandler handler) {
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_NOT_END);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        refreshSenior(player);

        Tuple<Integer, SeniorPartyScoreRank> rank;
        PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);
        if (partyData != null) {
            rank = mineDataManager.getPartyScoreRank(partyData.getPartyId());
            if (mineDataManager.getSeniorState() == SeniorState.END_STATE) {
                if (rank.getA() > 0 && rank.getA() < 6) {
                    if (player.seniorAward == 1) {
                        handler.sendErrorMsgToPlayer(GameError.ALREADY_GET_AWARD);
                        return;
                    }
                } else {
                    handler.sendErrorMsgToPlayer(GameError.NOT_ON_SCORE_RANK);
                    return;
                }
            }
        } else {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        player.seniorAward = 1;

        PartyScoreAwardRs.Builder builder = PartyScoreAwardRs.newBuilder();

        List<List<Integer>> awards = staticWarAwardDataMgr.getScorePartyAward(rank.getA());
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.PARTY_SCORE_AWARD));
        handler.sendMsgToPlayer(PartyScoreAwardRs.ext, builder.build());

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
            StaticMine staticMine = mineDataManager.evaluatePos(army.getTarget());
            int exp = staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getStaffingExp();
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


            exp += exp * ratio;
            playerDataManager.addStaffingExp(player, exp);
            army.setStaffingExp(army.getStaffingExp() + exp);
        }
    }

    /**
     * Method: mineStaffingLogic
     *
     * @return void
     * @throws
     * @Description: 军事地图半小时编制经验结算
     */
    public void mineStaffingLogic() {
        Iterator<List<Guard>> it = mineDataManager.getGuardMap().values().iterator();
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
                    LogUtil.error("军事地图半小时编制经验结算报错, guard:" + guard, e);
                }
            }
        }
    }

    /**
     * 清楚积分和排名
     * void
     */
    public void clearSeniorRanking() {
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            if (!player.isActive()) {
                continue;
            }

            player.seniorAward = 0;
            player.seniorScore = 0;


            //周六 刷新个人积分 和 服务器排名领取情况
            player.setCrossMineScore(0);
            player.setCrossMineGet(1);
        }

        //清除所有军团积分
        for (PartyData party : partyDataManager.getPartyMap().values()) {
            party.setScore(0);
        }

        mineDataManager.clearRank();

    }

    /**
     * 撤除所有矿点驻军
     * void
     */
    private void retreat() {
        Iterator<List<Guard>> it = mineDataManager.getGuardMap().values().iterator();
        int state;
        Army army;
        List<Guard> list;
        while (it.hasNext()) {
            list = it.next();
            if (list != null && !list.isEmpty()) {
                Guard guard = list.get(0);
                army = guard.getArmy();
                state = army.getState();
                if (state == ArmyState.COLLECT) {
                    Player player = guard.getPlayer();

                    StaticMine staticMine = mineDataManager.evaluatePos(army.getTarget());
                    if (staticMine != null) {
                        long get = playerDataManager.calcCollect(player, army, TimeHelper.getCurrentSecond(), staticMine,
                                staticWorldDataMgr.getStaticMineLvSenior(staticMine.getLv(), staffingDataManager.getWorldMineLevel()).getProduction());
                        Grab grab = new Grab();
                        grab.rs[staticMine.getType() - 1] = get;
                        army.setGrab(grab);

                        mineDataManager.removeGuard(player, army);
                        playerDataManager.retreatEnd(player, army);
                        player.armys.remove(army);
                    } else {
                        mineDataManager.removeGuard(player, army);
                        playerDataManager.retreatEnd(player, army);
                        player.armys.remove(army);
                    }
                }
            }
        }
    }

    /**
     * 军事矿区计时器 用于清除旧数据和结束时结算
     * void
     */
    public void seniorMineLogic() {
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        if (dayOfWeek == Calendar.SATURDAY) {

            if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {// 清除数据
                mineDataManager.setSeniorState(SeniorState.START_STATE);
                clearSeniorRanking();
                retreat();
            }
        } else if (dayOfWeek == Calendar.MONDAY) {

            if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {// 结算
                mineDataManager.setSeniorState(SeniorState.END_STATE);
                mineDataManager.setSeniorWeek(TimeHelper.getCurrentWeek());
                retreat();
            }
        }
    }

    /**
     * 星期六凌晨刷新 ，军矿
     */
    public void flushSeniorInSat() {
        mineDataManager.setSeniorState(SeniorState.START_STATE);
        clearSeniorRanking();
        retreat();
    }

    public void flushSeniorInMon() {
        mineDataManager.setSeniorState(SeniorState.END_STATE);
        mineDataManager.setSeniorWeek(TimeHelper.getCurrentWeek());
        retreat();
    }


    /**
     * 采集
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
     */
    public void refreshCollectArmy(Player player, Army army, int now, StaticMine staticMine, int collect, long get) {
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

        collect = (int) (collect * (1 + speedAdd / NumberHelper.HUNDRED_FLOAT));

        int collectTime = (int) (loadFree / (collect / (double) TimeHelper.HOUR_S));
        army.setState(ArmyState.COLLECT);
        army.setPeriod(collectTime);
        army.setEndTime(now + collectTime);
        army.setCaiJiEndTime(army.getEndTime() * 1000L);

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
    }
}
