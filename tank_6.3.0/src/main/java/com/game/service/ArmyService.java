/**
 * @Title: ArmyService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年8月10日 上午11:11:32
 * @version V1.0
 */
package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.ArenaDataManager;
import com.game.manager.DrillDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.StaffingDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb1.*;
import com.game.server.CrossMinContext;
import com.game.service.teaminstance.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: ArmyService
 * @Description:
 * @date 2015年8月10日 上午11:11:32
 */

@Service
public class ArmyService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private FightLabService fightLabService;

    @Autowired
    private FightService fightService;

    @Autowired
    private ArenaDataManager arenaDataManager;

    @Autowired
    private MilitaryScienceService militaryScienceService;

    @Autowired
    private DrillDataManager drillDataManager;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private TeamService teamService;
    @Autowired
    private WorldService worldService;
    @Autowired
    private TacticsService tacticsService;

    @Autowired
    private StaffingDataManager staffingDataManager;
    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;

    /**
     * 定时处理坦克生产队列
     *
     * @param player
     * @param list
     * @param now
     * @return boolean
     */
    private boolean dealTankQue(Player player, List<TankQue> list, int now) {
        Iterator<TankQue> it = list.iterator();
        int endTime = 0;
        boolean complete = false;
        Tank tank;
        while (it.hasNext()) {
            TankQue tankQue = it.next();
            if (tankQue.getState() == 1) {
                endTime = tankQue.getEndTime();
                if (now >= endTime) {
                    tank = playerDataManager.addTank(player, tankQue.getTankId(), tankQue.getCount(), AwardFrom.TANK_COMPLETE);
                    playerDataManager.updTask(player, TaskType.COND_TANK_PRODUCT, tankQue.getCount(), tankQue.getTankId());
                    playerDataManager.updDay7ActSchedule(player, 6, tankQue.getTankId(), tankQue.getCount());
                    it.remove();
                    complete = true;
                    continue;
                }
                break;
            } else {
                if (endTime == 0) {
                    endTime = now;
                }

                endTime += tankQue.getPeriod();
                if (now >= endTime) {
                    tank = playerDataManager.addTank(player, tankQue.getTankId(), tankQue.getCount(), AwardFrom.TANK_COMPLETE);
                    playerDataManager.updTask(player, TaskType.COND_TANK_PRODUCT, tankQue.getCount(), tankQue.getTankId());
                    playerDataManager.updDay7ActSchedule(player, 6, tankQue.getTankId(), tankQue.getCount());
                    it.remove();
                    complete = true;
                    continue;
                }

                tankQue.setState(1);
                tankQue.setEndTime(endTime);
                break;
            }
        }

        return complete;
    }

    /**
     * 定时处理坦克改装
     *
     * @param player
     * @param list
     * @param now
     * @return boolean
     */
    private boolean dealRefitQue(Player player, List<RefitQue> list, int now) {
        Iterator<RefitQue> it = list.iterator();
        int endTime = 0;
        boolean complete = false;
        Tank tank;
        while (it.hasNext()) {
            RefitQue refitQue = it.next();
            if (refitQue.getState() == 1) {
                endTime = refitQue.getEndTime();
                if (now >= endTime) {
                    tank = playerDataManager.addTank(player, refitQue.getRefitId(), refitQue.getCount(), AwardFrom.REFIT_TANK_COMPLETE);
                    it.remove();
                    complete = true;
                    continue;
                }
                break;
            } else {
                if (endTime == 0) {
                    endTime = now;
                }

                endTime += refitQue.getPeriod();
                if (now >= endTime) {
                    tank = playerDataManager.addTank(player, refitQue.getRefitId(), refitQue.getCount(), AwardFrom.REFIT_TANK_COMPLETE);
                    // LogHelper.logCompleteTank(player.lord, refitQue, tank);
                    it.remove();
                    complete = true;
                    continue;
                }

                refitQue.setState(1);
                refitQue.setEndTime(endTime);
                break;
            }
        }

        return complete;
    }

    /**
     * Method: getTank
     *
     * @return void
     * @Description: 获取玩家坦克数据
     */
    public void getTank(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player != null) {
            GetTankRs.Builder builder = GetTankRs.newBuilder();
            for (Map.Entry<Integer, Tank> entry : player.tanks.entrySet()) {
                builder.addTank(PbHelper.createTankPb(entry.getValue()));
            }

            for (TankQue tankQue : player.tankQue_1) {
                builder.addQueue1(PbHelper.createTankQuePb(tankQue));
            }

            for (TankQue tankQue : player.tankQue_2) {
                builder.addQueue2(PbHelper.createTankQuePb(tankQue));
            }

            for (RefitQue refitQue : player.refitQue) {
                builder.addRefit(PbHelper.createRefitQuePb(refitQue));
            }

            handler.sendMsgToPlayer(GetTankRs.ext, builder.build());
        }
    }

    /**
     * Method: getArmy
     *
     * @return void
     * @Description: 客户端获取部队数据
     */
    public void getArmy(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player != null) {
            GetArmyRs.Builder builder = GetArmyRs.newBuilder();
            List<Army> list = player.armys;
            for (Army army : list) {
                builder.addArmy(PbHelper.createArmyPb(army));
            }

            handler.sendMsgToPlayer(GetArmyRs.ext, builder.build());
        }
    }

    /**
     * Method: getForm
     *
     * @return void
     * @Description: 客户端获取阵型数据
     */
    public void getForm(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player != null) {
            GetFormRs.Builder builder = GetFormRs.newBuilder();
            Iterator<Form> it = player.forms.values().iterator();
            while (it.hasNext()) {
                builder.addForm(PbHelper.createFormPb(it.next()));
            }
            handler.sendMsgToPlayer(GetFormRs.ext, builder.build());
        }
    }

    // private void setLordFormByIndex(Form lordForm, int index, int tankId, int
    // count) {
    // switch (index) {
    // case 1:
    // lordForm.setP1(tankId);
    // lordForm.setC1(count);
    // break;
    // case 2:
    // lordForm.setP2(tankId);
    // lordForm.setC2(count);
    // break;
    // case 3:
    // lordForm.setP3(tankId);
    // lordForm.setC3(count);
    // break;
    // case 4:
    // lordForm.setP4(tankId);
    // lordForm.setC4(count);
    // break;
    // case 5:
    // lordForm.setP5(tankId);
    // lordForm.setC5(count);
    // break;
    // case 6:
    // lordForm.setP6(tankId);
    // lordForm.setC6(count);
    // break;
    // default:
    // break;
    // }
    // }

    // private TwoInt dealForm(Map<Integer, Tank> tankMap, TwoInt v, Form
    // lordForm, int index) {
    // int tankId = v.getV1();
    // int count = v.getV2();
    // if (count >= 0) {
    // Tank tank = tankMap.get(tankId);
    // if (tank != null) {
    // int hasCount = tank.getCount();
    // if (hasCount >= 0) {
    // int putCount = (hasCount >= count) ? count : hasCount;
    // tank.setCount(hasCount - putCount);
    // setLordFormByIndex(lordForm, index, tankId, putCount);
    // TwoInt.Builder bd = TwoInt.newBuilder();
    // bd.setV1(tankId);
    // bd.setV2(putCount);
    // return bd.build();
    // }
    // } else if (tankId == 0) {
    // setLordFormByIndex(lordForm, index, 0, 0);
    // TwoInt.Builder bd = TwoInt.newBuilder();
    // bd.setV1(tankId);
    // bd.setV2(count);
    // return bd.build();
    // }
    // }
    // return null;
    // }

    /**
     * Method: setForm
     *
     * @param req
     * @return void
     * @Description: 玩家设置阵型
     */
    public void setForm(SetFormRq req, ClientHandler handler) {
        boolean clean = false;
        if (req.hasClean()) {
            clean = req.getClean();
        }

        CommonPb.Form form = req.getForm();
        if (!form.hasType()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        int formType = form.getType();

        if (formType < FormType.TEMPLATE || formType > FormType.DRILL_3) {
            if (formType != FormType.TEAM) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        worldService.removeExpireHero(player, 0);

        if (formType == FormType.ARENA) {
            if (player.lord.getLevel() < ArenaService.ARENA_LV) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        } else if (formType == FormType.BOSS) {
            if (player.lord.getLevel() < 30) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        } else if (formType >= FormType.DRILL_1 && formType <= FormType.DRILL_3) {// 红蓝大战，只有备战状态可以设置阵型
            if (DrillDataManager.getDrillStatus() != DrillConstant.STATUS_PREPARE) {
                handler.sendErrorMsgToPlayer(GameError.DRILL_STATUS_EROOR);
                return;
            }

            if (!clean) {
                int armyNum = 0;
                for (int i = FormType.DRILL_1; i <= FormType.DRILL_3; i++) {
                    if (null != player.forms.get(i)) {
                        armyNum++;
                    }
                }
                if (armyNum >= 2 && !player.forms.containsKey(formType)) {
                    handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                    return;
                }
            }
        }

        Form destForm = PbHelper.createForm(form);

        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (destForm.getAwakenHero() != null) {// 使用觉醒将领
            awakenHero = player.awakenHeros.get(destForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            destForm.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (destForm.getCommander() > 0) {
            hero = player.heros.get(destForm.getCommander());
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

        int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
        if (!clean) {
            if (!playerDataManager.checkTank(player, destForm, maxTankCount)) {
                handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
                return;
            }
        }

        //战术验证
        if (!destForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(player, destForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }

        long fight = fightService.calcFormFight(player, destForm);

        if (formType == FormType.ARENA) {
            Arena arena = arenaDataManager.getArena(player.roleId);
            if (arena == null) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            arena.setFight(fight);

        } else if (formType == FormType.VIP2) {
            if (player.lord.getVip() < 2) {
                handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
                return;
            }
        } else if (formType == FormType.VIP5) {
            if (player.lord.getVip() < 5) {
                handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
                return;
            }
        } else if (formType == FormType.VIP8) {
            if (player.lord.getVip() < 8) {
                handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
                return;
            }
        }

        if (clean && formType != FormType.ARENA) {
            player.forms.remove(formType);
            if (formType >= FormType.DRILL_1 && formType <= FormType.DRILL_3) {
                drillDataManager.removeCampArmy(player.drillFightData.isRed(), formType - FormType.ALTARBOSS, player.roleId);
            }
        }

        if (!clean) {
            player.forms.put(formType, destForm);
            if (formType >= FormType.DRILL_1 && formType <= FormType.DRILL_3) {
                drillDataManager.addCampArmy(player.drillFightData.isRed(), formType - FormType.ALTARBOSS, player.roleId);
            }
        }

        if (formType == FormType.TEAM) {
            if (CrossMinContext.isCrossMinSocket()) {
                TeamRpcService.synForm(handler.getRoleId(), destForm, fight);
            } else {
                Team team = TeamManager.getTeamByRoleId(handler.getRoleId());
                if (team != null) {
                    teamService.synTeamInfoToMembers(team, TeamConstant.SET_FORM, handler.getRoleId());
                }
            }
        }

        SetFormRs.Builder builder = SetFormRs.newBuilder();
        builder.setForm(PbHelper.createFormPb(destForm));
        builder.setFight(fight);
        handler.sendMsgToPlayer(SetFormRs.ext, builder.build());

    }

    /**
     * 修理某种坦克
     *
     * @param tankId
     * @param repairType
     * @param handler    void
     */
    private void repairOne(int tankId, int repairType, ClientHandler handler) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Tank tank = player.tanks.get(tankId);
        if (tank == null || tank.getRest() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_REPAIR);
            return;
        }

        if (repairType == 1) {// 宝石修理
            int rest = tank.getRest();
            Resource resource = player.resource;
            long cost = 1L * staticTank.getRepair() * rest;
            if (cost < 0) {
                handler.sendErrorMsgToPlayer(GameError.DATA_EXCEPTION);
                return;
            }

            if (resource.getStone() < cost) {
                handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
                return;
            }

            playerDataManager.modifyStone(player, -cost, AwardFrom.REPAIR_TANK);

            tank.setCount(tank.getCount() + rest);
            LogLordHelper.tank(AwardFrom.REPAIR_TANK, player.account, player.lord, tank.getTankId(), tank.getCount(), rest, 0, 0);
            tank.setRest(0);
            // armyDao.updateTank(tank);

            RepairRs.Builder builder = RepairRs.newBuilder();
            builder.setCount(rest);
            builder.setCur(player.resource.getStone());

            handler.sendMsgToPlayer(RepairRs.ext, builder.build());
            return;
        } else if (repairType == 2) {// 金币修
            int rest = tank.getRest();
            Lord lord = player.lord;
            if (lord == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_LORD);
                return;
            }

            int cost = rest / 10 + (rest % 10 > 0 ? 1 : 0);
            if (cost < 0) {
                handler.sendErrorMsgToPlayer(GameError.DATA_EXCEPTION);
                return;
            }

            if (lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            playerDataManager.subGold(player, cost, AwardFrom.REPAIR_TANK);

            tank.setCount(tank.getCount() + rest);
            LogLordHelper.tank(AwardFrom.REPAIR_TANK, player.account, player.lord, tank.getTankId(), tank.getCount(), rest, 0, 0);
            tank.setRest(0);
            // armyDao.updateTank(tank);

            RepairRs.Builder builder = RepairRs.newBuilder();
            builder.setCount(rest);
            builder.setCur(lord.getGold());
            handler.sendMsgToPlayer(RepairRs.ext, builder.build());
            return;
        }
    }

    /**
     * 金币修理所有坦克
     *
     * @param handler void
     */
    private void repairAllByGold(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // List<Tank> updateList = new ArrayList<>();
        Lord lord = player.lord;
        Map<Integer, Tank> tanks = player.tanks;

        int cost = 0;
        int count = 0;
        for (Tank tank : tanks.values()) {
            int tankId = tank.getTankId();
            if (tank == null || tank.getRest() == 0) {
                continue;
            }

            StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
            if (staticTank == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            count += tank.getRest();
            cost += tank.getRest() / 10 + (tank.getRest() % 10 > 0 ? 1 : 0);
            if (cost < 0) {
                handler.sendErrorMsgToPlayer(GameError.DATA_EXCEPTION);
                return;
            }

            if (lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
        }

        for (Tank tank : tanks.values()) {
            if (tank.getRest() > 0) {
                tank.setCount(tank.getCount() + tank.getRest());
                LogLordHelper.tank(AwardFrom.REPAIR_TANK, player.account, player.lord, tank.getTankId(), tank.getCount(), tank.getRest(), 0,
                        0);
                tank.setRest(0);
            }
        }

        playerDataManager.subGold(player, cost, AwardFrom.REPAIR_TANK);

        // for (TankDb tank : updateList) {
        // armyDao.updateTank(tank);
        // }

        RepairRs.Builder builder = RepairRs.newBuilder();
        builder.setCount(count);
        builder.setCur(lord.getGold());

        handler.sendMsgToPlayer(RepairRs.ext, builder.build());
    }

    /**
     * 水晶修复所有坦克
     *
     * @param handler void
     */
    private void repairAllByStone(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // List<Tank> updateList = new ArrayList<>();
        Resource resource = player.resource;
        Map<Integer, Tank> tanks = player.tanks;

        long cost = 0;
        int count = 0;
        for (Tank tank : tanks.values()) {
            int tankId = tank.getTankId();
            if (tank.getRest() == 0) {
                continue;
            }

            StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
            if (staticTank == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            count += tank.getRest();
            cost += 1L * staticTank.getRepair() * tank.getRest();
            if (cost < 0) {
                handler.sendErrorMsgToPlayer(GameError.DATA_EXCEPTION);
                return;
            }

            if (resource.getStone() < cost) {
                handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
                return;
            }

            // updateList.add(tank);
        }

        for (Tank tank : tanks.values()) {
            if (tank.getRest() > 0) {
                tank.setCount(tank.getCount() + tank.getRest());
                LogLordHelper.tank(AwardFrom.REPAIR_TANK, player.account, player.lord, tank.getTankId(), tank.getCount(), tank.getRest(), 0,
                        0);
                tank.setRest(0);
            }
        }

        playerDataManager.modifyStone(player, -cost, AwardFrom.REPAIR_TANK);
        // resourceDao.updateResource(resource);

        // for (TankDb tank : updateList) {
        // armyDao.updateTank(tank);
        // }

        RepairRs.Builder builder = RepairRs.newBuilder();
        builder.setCount(count);
        builder.setCur(player.resource.getStone());

        handler.sendMsgToPlayer(RepairRs.ext, builder.build());
    }

    /**
     * 修复所有坦克
     *
     * @param repairType
     * @param handler    void
     */
    private void repairAll(int repairType, ClientHandler handler) {
        if (repairType == 1) {
            repairAllByStone(handler);
        } else if (repairType == 2) {
            repairAllByGold(handler);
        } else {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
        }
    }

    /**
     * Method: repair 修复坦克协议处理
     *
     * @param req
     * @return void
     * @Description:
     */
    public void repair(RepairRq req, ClientHandler handler) {
        int tankId = req.getTankId();
        int repairType = req.getRepairType();
        if (tankId == 0) {
            repairAll(repairType, handler);
        } else {
            repairOne(tankId, repairType, handler);
        }
    }

    /**
     * 坦克生产队列等待数量
     *
     * @param lord
     * @return int
     */
    private int getTankQueWaitCount(Lord lord) {
        StaticVip staticVip = staticVipDataMgr.getStaticVip(lord.getVip());
        if (staticVip != null) {
            return staticVip.getWaitQue();
        }
        return 0;
    }

    /**
     * 添加一个等待生产队列
     *
     * @param player
     * @param tankId
     * @param count
     * @param period
     * @param endTime
     * @return TankQue
     */
    private TankQue createTankWaitQue(Player player, int tankId, int count, int period, int endTime) {
        TankQue tankQue = new TankQue(player.maxKey(), tankId, count, 0, period, endTime);
        return tankQue;
    }

    /**
     * 创建一个坦克生产队列
     *
     * @param player
     * @param tankId
     * @param count
     * @param period
     * @param endTime
     * @return TankQue
     */
    private TankQue createTankQue(Player player, int tankId, int count, int period, int endTime) {
        TankQue tankQue = new TankQue(player.maxKey(), tankId, count, 1, period, endTime);
        return tankQue;
    }

    /**
     * 添加一个坦克等待改装队列
     *
     * @param player
     * @param tankId
     * @param refitId
     * @param count
     * @param period
     * @param endTime
     * @return RefitQue
     */
    private RefitQue createRefitWaitQue(Player player, int tankId, int refitId, int count, int period, int endTime) {
        RefitQue refitQue = new RefitQue(player.maxKey(), tankId, refitId, count, 0, period, endTime);
        return refitQue;
    }

    /**
     * 添加一个坦克改装队列
     *
     * @param player
     * @param tankId
     * @param refitId
     * @param count
     * @param period
     * @param endTime
     * @return RefitQue
     */
    private RefitQue createRefitQue(Player player, int tankId, int refitId, int count, int period, int endTime) {
        RefitQue refitQue = new RefitQue(player.maxKey(), tankId, refitId, count, 1, period, endTime);
        return refitQue;
    }

    /**
     * Method: speedQue
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 加速生产坦克
     */
    public void speedTankQue(SpeedQueRq req, ClientHandler handler) {
        if (!req.hasWhich()) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int keyId = req.getKeyId();
        int cost = req.getCost();
        int which = req.getWhich();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<TankQue> list = (which == 1) ? player.tankQue_1 : player.tankQue_2;
        TankQue que = null;
        for (TankQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        if (que.getState() == 0) {
            handler.sendErrorMsgToPlayer(GameError.SPEED_WAIT_QUE);
            return;
        }

        int now = TimeHelper.getCurrentSecond();

        SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();
        if (cost == 1) {// 金币
            int leftTime = que.getEndTime() - now;
            if (leftTime <= 0) {
                leftTime = 1;
            }

            int sub = (int) Math.ceil(leftTime / 60.0);
            Lord lord = player.lord;
            if (lord.getGold() < sub) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, sub, AwardFrom.SPEED_TANK_QEU);
            que.setEndTime(now);

            dealTankQue(player, list, now);

            builder.setGold(lord.getGold());
            handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
            return;
        } else {// 道具
            if (!req.hasPropId()) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            int propId = req.getPropId();

            int propCount = 1;
            if (req.hasPropCount()) {
                propCount = req.getPropCount();
            }

            Prop prop = player.props.get(propId);
            if (prop == null || prop.getCount() < propCount) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }

            StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
            if (staticProp.getEffectType() != 3) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            List<List<Integer>> value = staticProp.getEffectValue();
            if (value == null || value.isEmpty()) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            List<Integer> one = value.get(0);
            if (one.size() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            int type = one.get(0);
            int speedTime = one.get(1) * propCount;
            if (type != 2) {// 坦克加速
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            playerDataManager.subProp(player, prop, propCount, AwardFrom.SPEED_TANK_QEU);

            que.setEndTime(que.getEndTime() - speedTime);
            dealTankQue(player, list, now);

            builder.setCount(prop.getCount());
            builder.setEndTime(que.getEndTime());
            handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
            return;
        }
    }

    /**
     * Method: speedRefitQue
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 加速改装坦克
     */
    public void speedRefitQue(SpeedQueRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int cost = req.getCost();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<RefitQue> list = player.refitQue;
        RefitQue que = null;
        for (RefitQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        if (que.getState() == 0) {
            handler.sendErrorMsgToPlayer(GameError.SPEED_WAIT_QUE);
            return;
        }

        int now = TimeHelper.getCurrentSecond();

        SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();
        if (cost == 1) {// 金币
            int leftTime = que.getEndTime() - now;
            if (leftTime <= 0) {
                leftTime = 1;
            }
            int sub = (int) Math.ceil(leftTime / 60.0);
            Lord lord = player.lord;
            if (lord.getGold() < sub) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, sub, AwardFrom.SPEED_REFIT_QEU);
            que.setEndTime(now);

            dealRefitQue(player, list, now);

            builder.setGold(lord.getGold());
            handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
            return;
        } else {// 道具
            if (!req.hasPropId()) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            int propId = req.getPropId();
            int propCount = 1;

            if (req.hasPropCount()) {
                propCount = req.getPropCount();
            }

            Prop prop = player.props.get(propId);
            if (prop == null || prop.getCount() < propCount) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }

            StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
            if (staticProp.getEffectType() != 3) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            List<List<Integer>> value = staticProp.getEffectValue();
            if (value == null || value.isEmpty()) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            List<Integer> one = value.get(0);
            if (one.size() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            int type = one.get(0);
            int speedTime = one.get(1) * propCount;
            if (type != 2) {// 坦克加速
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            playerDataManager.subProp(player, prop, propCount, AwardFrom.SPEED_REFIT_QEU);

            que.setEndTime(que.getEndTime() - speedTime);
            dealRefitQue(player, list, now);

            builder.setCount(prop.getCount());
            builder.setEndTime(que.getEndTime());
            handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
            return;
        }
    }

    /**
     * Method: cancelQue
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 玩家取消生产坦克
     */
    public void cancelTankQue(CancelQueRq req, ClientHandler handler) {
        if (!req.hasWhich()) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int keyId = req.getKeyId();
        int which = req.getWhich();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<TankQue> list = (which == 1) ? player.tankQue_1 : player.tankQue_2;

        TankQue que = null;
        for (TankQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        int tankId = que.getTankId();
        int count = que.getCount();
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        list.remove(que);

        Resource resource = player.resource;
        int ironCost = staticTank.getIron() * count / 2;
        int oilCost = staticTank.getOil() * count / 2;
        int copperCost = staticTank.getCopper() * count / 2;
        int siliconCost = staticTank.getSilicon() * count / 2;

        int bookCount = staticTank.getBook() * count / 2;
        int drawingId = staticTank.getDrawing();
        int drawingCount = count / 2;

        if (bookCount > 0) {
            playerDataManager.addProp(player, PropId.SKILL_BOOK, bookCount, AwardFrom.CANCEL_TANK_QUE);
        }

        if (drawingId > 0 && drawingCount > 0) {
            playerDataManager.addProp(player, drawingId, drawingCount, AwardFrom.CANCEL_TANK_QUE);
        }

        CancelQueRs.Builder builder = CancelQueRs.newBuilder();
        if (ironCost > 0) {
            playerDataManager.modifyIron(player, ironCost, AwardFrom.CANCEL_TANK_QUE);
            builder.setIron(resource.getIron());
        }

        if (oilCost > 0) {
            playerDataManager.modifyOil(player, oilCost, AwardFrom.CANCEL_TANK_QUE);
            builder.setOil(resource.getOil());
        }

        if (copperCost > 0) {
            playerDataManager.modifyCopper(player, copperCost, AwardFrom.CANCEL_TANK_QUE);
            builder.setCopper(resource.getCopper());
        }

        if (siliconCost > 0) {
            playerDataManager.modifySilicon(player, siliconCost, AwardFrom.CANCEL_TANK_QUE);
            builder.setSilicon(resource.getSilicon());
        }

        // resourceDao.updateResource(resource);
        handler.sendMsgToPlayer(CancelQueRs.ext, builder.build());
    }

    /**
     * Method: cancelRefitQue
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 玩家取消改装
     */
    public void cancelRefitQue(CancelQueRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<RefitQue> list = player.refitQue;
        RefitQue que = null;
        for (RefitQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        int tankId = que.getTankId();
        int refitId = que.getRefitId();
        int count = que.getCount();
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        StaticTank refitTank = staticTankDataMgr.getStaticTank(refitId);
        if (staticTank == null || refitTank == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        list.remove(que);

        playerDataManager.addTank(player, tankId, count, AwardFrom.CANCEL_REFIT_QUE);

        int ironCost = (refitTank.getIron() - staticTank.getIron()) * count / 2;
        int oilCost = (refitTank.getOil() - staticTank.getOil()) * count / 2;
        int copperCost = (refitTank.getCopper() - staticTank.getCopper()) * count / 2;
        int siliconCost = (refitTank.getSilicon() - staticTank.getSilicon()) * count / 2;

        int bookCount = refitTank.getBook() * count / 2;
        int drawingId = refitTank.getDrawing();
        int drawingCount = count / 2;

        if (bookCount > 0) {
            playerDataManager.addProp(player, PropId.SKILL_BOOK, bookCount, AwardFrom.CANCEL_REFIT_QUE);
        }

        if (drawingId > 0 && drawingCount > 0) {
            playerDataManager.addProp(player, drawingId, drawingCount, AwardFrom.CANCEL_REFIT_QUE);
        }

        Resource resource = player.resource;
        CancelQueRs.Builder builder = CancelQueRs.newBuilder();
        if (ironCost > 0) {
            playerDataManager.modifyIron(player, ironCost, AwardFrom.CANCEL_REFIT_QUE);
            builder.setIron(resource.getIron());
        }

        if (oilCost > 0) {
            playerDataManager.modifyOil(player, oilCost, AwardFrom.CANCEL_REFIT_QUE);
            builder.setOil(resource.getOil());
        }

        if (copperCost > 0) {
            playerDataManager.modifyCopper(player, copperCost, AwardFrom.CANCEL_REFIT_QUE);
            builder.setCopper(resource.getCopper());
        }

        if (siliconCost > 0) {
            playerDataManager.modifySilicon(player, siliconCost, AwardFrom.CANCEL_REFIT_QUE);
            builder.setSilicon(resource.getSilicon());
        }

        // resourceDao.updateResource(resource);
        handler.sendMsgToPlayer(CancelQueRs.ext, builder.build());
    }

    private int buildTankTime(Player player, StaticTank staticTank, int count, int factoryLv) {
        float add = 0;
        // 功能开启则按文官入驻规则计算，否则按是否有文官计算
        if (staticFunctionPlanDataMgr.isHeroPutOpen()) {
            if (player.isHeroPut(HeroId.SHENG_CHAN_GUAN)) {
                // 如果生产官和生产兵都入驻了，则取集齐后的技能值
                if (player.isHeroPut(HeroId.SHENG_CHAN_BING)) {
                    StaticHeroPut staticHeroPut = staticHeroDataMgr.getHeroPutMap().get(HeroId.SHENG_CHAN);
                    if (staticHeroPut != null) {
                        add = staticHeroPut.getFullSkillValue() / NumberHelper.HUNDRED_FLOAT;
                    }
                } else { // 只有生产官
                    add = staticHeroDataMgr.getStaticHero(HeroId.SHENG_CHAN_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
                }
            } else if (player.isHeroPut(HeroId.SHENG_CHAN_BING)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.SHENG_CHAN_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            }
        } else {
            if (player.hasHero(HeroId.SHENG_CHAN_GUAN)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.SHENG_CHAN_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            } else if (player.hasHero(HeroId.SHENG_CHAN_BING)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.SHENG_CHAN_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            }
        }
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            add += (staticVip.getSpeedTank() / NumberHelper.HUNDRED_FLOAT);
        }

        Effect effect = player.effects.get(EffectType.ADD_PRODUCE_SPEED_PS);
        if (effect != null) {
            add += (5 / NumberHelper.HUNDRED_FLOAT);
        }
        effect = player.effects.get(EffectType.SUB_PRODUCE_SPEED_PS);
        if (effect != null) {
            add += (-10 / NumberHelper.HUNDRED_FLOAT);
        }
        effect = player.effects.get(EffectType.ACTIVITY_BUILD_TANK_ADD_SPEED);
        if (effect != null) {
            add += (100 / NumberHelper.HUNDRED_FLOAT);
        }

        // 作战实验室加成
        int labAdd = fightLabService.getSpecilAttrAdd(player, AttrId.PRODUCT_SPEED_ALL);
        labAdd += fightLabService.getSpecilAttrAdd(player, AttrId.PRODUCT_SPEED_ALL + staticTank.getType());
        if (labAdd > 0) {
            add += (labAdd / NumberHelper.HUNDRED_FLOAT);
        }

        // 获取军工科技效率加成的时间
        int reduceTime = militaryScienceService.caulMilitaryProduceReduceTime(player, staticTank.getTankId());
        float needTime = (float) ((staticTank.getBuildTime() - reduceTime) / (1 + factoryLv * 0.05 + add));
        if (needTime <= 0) {
            needTime = 0f;
        }

        return (int) Math.ceil(needTime * count);
    }

    private int refitTankTime(Player player, int time, StaticTank refitTank, int count, int factoryLv) {
        float add = 0;
        // 功能开启则按文官入驻规则计算，否则按是否有文官计算
        if (staticFunctionPlanDataMgr.isHeroPutOpen()) {
            if (player.isHeroPut(HeroId.GAI_ZAO_GUAN)) {
                if (player.isHeroPut(HeroId.GAI_ZAO_BING)) {
                    StaticHeroPut staticHeroPut = staticHeroDataMgr.getHeroPutMap().get(HeroId.GAI_ZAO);
                    if (staticHeroPut != null) {
                        add = staticHeroPut.getFullSkillValue() / NumberHelper.HUNDRED_FLOAT;
                    }
                } else {
                    add = staticHeroDataMgr.getStaticHero(HeroId.GAI_ZAO_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
                }
            } else if (player.isHeroPut(HeroId.GAI_ZAO_BING)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.GAI_ZAO_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            }
        } else {
            if (player.hasHero(HeroId.GAI_ZAO_GUAN)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.GAI_ZAO_GUAN).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            } else if (player.hasHero(HeroId.GAI_ZAO_BING)) {
                add = staticHeroDataMgr.getStaticHero(HeroId.GAI_ZAO_BING).getSkillValue() / NumberHelper.HUNDRED_FLOAT;
            }
        }
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            add += (staticVip.getSpeedRefit() / NumberHelper.HUNDRED_FLOAT);
        }

        Effect effect = player.effects.get(EffectType.ADD_PRODUCE_SPEED_PS);
        if (effect != null) {
            add += (5 / NumberHelper.HUNDRED_FLOAT);
        }
        effect = player.effects.get(EffectType.SUB_PRODUCE_SPEED_PS);
        if (effect != null) {
            add += (-10 / NumberHelper.HUNDRED_FLOAT);
        }
        effect = player.effects.get(EffectType.ACTIVITY_REFIT_TANK_ADD_SPEED);
        if (effect != null) {
            add += (100 / NumberHelper.HUNDRED_FLOAT);
        }

        // 作战实验室加成
        int labAdd = fightLabService.getSpecilAttrAdd(player, AttrId.REFIT_SPEED_ALL);
        labAdd += fightLabService.getSpecilAttrAdd(player, AttrId.REFIT_SPEED_ALL + refitTank.getType());
        if (labAdd > 0) {
            add += (labAdd / NumberHelper.HUNDRED_FLOAT);
        }

        // 获取军工科技效率加成的时间
        int reduceTime = militaryScienceService.caulMilitaryProduceReduceTime(player, refitTank.getTankId());
        float needTime = (float) ((time - reduceTime) / (1 + factoryLv * 0.05 + add));
        if (needTime <= 0) {
            needTime = 0f;
        }

        return (int) Math.ceil(needTime * count);
    }

    /**
     * Method: buildTank
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 生产坦克
     */
    public void buildTank(BuildTankRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int which = req.getWhich();
        int tankId = req.getTankId();
        int count = req.getCount();
        int factoryLv = 0;
        List<TankQue> tankQue = null;

        int maxCount = 100;
        int worldLv = staffingDataManager.getWorldLv();
        StaticStaffingWorld staffingWorld = staticStaffingDataMgr.getStaffingWorld(worldLv);
        if (staffingWorld != null) {
            maxCount += staffingWorld.getLimit();
        }


        if (count <= 0 || count > maxCount) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (staticTank.getCanBuild() == 1) {
            handler.sendErrorMsgToPlayer(GameError.CANT_BUILD);
            return;
        }

        if (which == 1) {// 第一工厂
            which = 1;
            factoryLv = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_1, player.building);
            tankQue = player.tankQue_1;
        } else {// 第二工厂
            which = 2;
            factoryLv = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
            tankQue = player.tankQue_2;
        }

        if (factoryLv < staticTank.getFactoryLv()) {
            handler.sendErrorMsgToPlayer(GameError.BUILD_LEVEL);
            return;
        }

        if (player.lord.getLevel() < staticTank.getLordLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        // 坦克生产所需的作战实验室技能是否开启
        if (!fightLabService.isTankBuildOpen(player, staticTank)) {
            handler.sendErrorMsgToPlayer(GameError.FIGHT_LAB_SKILL_NOT_FOUND);
            return;
        }

        Resource resource = player.resource;
        int ironCost = staticTank.getIron() * count;
        int oilCost = staticTank.getOil() * count;
        int copperCost = staticTank.getCopper() * count;
        int siliconCost = staticTank.getSilicon() * count;

        if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
                || resource.getSilicon() < siliconCost) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }

        Prop book = null;
        int needBook = 0;
        if (staticTank.getBook() != 0) {
            book = player.props.get(PropId.SKILL_BOOK);
            needBook = staticTank.getBook() * count;
            if (book == null || book.getCount() < needBook) {
                handler.sendErrorMsgToPlayer(GameError.BOOK_NOT_ENOUGH);
                return;
            }
        }

        Prop drawing = null;
        if (staticTank.getDrawing() != 0) {
            drawing = player.props.get(staticTank.getDrawing());
            if (drawing == null || drawing.getCount() < count) {
                handler.sendErrorMsgToPlayer(GameError.DRAWING_NOT_ENOUGH);
                return;
            }
        }

        int queSize = tankQue.size();
        TankQue que = null;
        int now = TimeHelper.getCurrentSecond();
        int haust = buildTankTime(player, staticTank, count, factoryLv);
        if (queSize == 0) {
            que = createTankQue(player, tankId, count, haust, now + haust);
            tankQue.add(que);
        } else {
            if (queSize > 0 && queSize < getTankQueWaitCount(player.lord) + 1) {
                que = createTankWaitQue(player, tankId, count, haust, now + haust);
                tankQue.add(que);
            } else {
                handler.sendErrorMsgToPlayer(GameError.MAX_TANK_QUE);
                return;
            }
        }

        if (needBook > 0) {
            playerDataManager.subProp(player, book, needBook, AwardFrom.BUILD_TANK);
        }

        if (drawing != null) {
            playerDataManager.subProp(player, drawing, count, AwardFrom.BUILD_TANK);
        }

        BuildTankRs.Builder builder = BuildTankRs.newBuilder();

        if (ironCost > 0) {
            playerDataManager.modifyIron(player, -ironCost, AwardFrom.BUILD_TANK);
            builder.setIron(resource.getIron());
        }

        if (oilCost > 0) {
            playerDataManager.modifyOil(player, -oilCost, AwardFrom.BUILD_TANK);
            builder.setOil(resource.getOil());
        }

        if (copperCost > 0) {
            playerDataManager.modifyCopper(player, -copperCost, AwardFrom.BUILD_TANK);
            builder.setCopper(resource.getCopper());
        }

        if (siliconCost > 0) {
            playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.BUILD_TANK);
            builder.setSilicon(resource.getSilicon());
        }

        builder.setQueue(PbHelper.createTankQuePb(que));
        handler.sendMsgToPlayer(BuildTankRs.ext, builder.build());

        LogLordHelper.tank(AwardFrom.BUILD_TANK, player.account, player.lord, tankId, 0, count, 0, 0);
    }

    /**
     * Method: refitTank
     *
     * @param req
     * @param handler
     * @return void
     * @Description: 改装坦克
     */
    public void refitTank(RefitTankRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int tankId = req.getTankId();
        int count = req.getCount();


        int maxCount = 100;
        int worldLv = staffingDataManager.getWorldLv();
        StaticStaffingWorld staffingWorld = staticStaffingDataMgr.getStaffingWorld(worldLv);
        if (staffingWorld != null) {
            maxCount += staffingWorld.getLimit();
        }
        if (count <= 0 || count > maxCount) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (staticTank.getCanRefit() != 1) {
            handler.sendErrorMsgToPlayer(GameError.CANT_REFIT);
            return;
        }

        int refitId = staticTank.getRefitId();
        StaticTank refitTank = staticTankDataMgr.getStaticTank(refitId);
        if (refitTank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Tank tank = player.tanks.get(tankId);
        if (tank == null || tank.getCount() < count) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        int refitLv = PlayerDataManager.getBuildingLv(BuildingId.REFIT, player.building);
        int factory1 = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_1, player.building);
        int factory2 = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
        int factoryLv = (factory1 > factory2) ? factory1 : factory2;

        if (factoryLv < refitTank.getRefitLv()) {
            handler.sendErrorMsgToPlayer(GameError.BUILD_LEVEL);
            return;
        }

        if (player.lord.getLevel() < refitTank.getLordLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Resource resource = player.resource;
        int ironCost = (refitTank.getIron() - staticTank.getIron()) * count;
        int oilCost = (refitTank.getOil() - staticTank.getOil()) * count;
        int copperCost = (refitTank.getCopper() - staticTank.getCopper()) * count;
        int siliconCost = (refitTank.getSilicon() - staticTank.getSilicon()) * count;

        if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
                || resource.getSilicon() < siliconCost) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }

        int bookCount = refitTank.getBook() * count;
        int drawingId = refitTank.getDrawing();
        int drawingCount = count;

        Prop bookProp = null;
        Prop drawingProp = null;
        if (bookCount > 0) {
            bookProp = player.props.get(PropId.SKILL_BOOK);
            if (bookProp == null || bookProp.getCount() < bookCount) {
                handler.sendErrorMsgToPlayer(GameError.BOOK_NOT_ENOUGH);
                return;
            }
        }

        if (drawingId > 0 && drawingCount > 0) {
            drawingProp = player.props.get(drawingId);
            if (drawingProp == null || drawingProp.getCount() < drawingCount) {
                handler.sendErrorMsgToPlayer(GameError.DRAWING_NOT_ENOUGH);
                return;
            }
        }

        List<RefitQue> refitQue = player.refitQue;
        int queSize = refitQue.size();
        RefitQue que = null;
        int now = TimeHelper.getCurrentSecond();
        int refitBaseTime = refitTank.getBuildTime() - staticTank.getBuildTime();
        int haust = refitTankTime(player, refitBaseTime, refitTank, count, refitLv);

        if (queSize == 0) {
            que = createRefitQue(player, tankId, refitId, count, haust, now + haust);
            refitQue.add(que);
        } else {
            if (queSize > 0 && queSize < getTankQueWaitCount(player.lord) + 1) {
                que = createRefitWaitQue(player, tankId, refitId, count, haust, now + haust);
                refitQue.add(que);
            } else {
                handler.sendErrorMsgToPlayer(GameError.MAX_REFIT_QUE);
                return;
            }
        }

        playerDataManager.subTank(player, tank, count, AwardFrom.REFIT_TANK);

        if (bookCount > 0) {
            playerDataManager.subProp(player, bookProp, bookCount, AwardFrom.REFIT_TANK);
        }

        if (drawingId > 0) {
            playerDataManager.subProp(player, drawingProp, drawingCount, AwardFrom.REFIT_TANK);
        }

        RefitTankRs.Builder builder = RefitTankRs.newBuilder();

        if (ironCost > 0) {
            playerDataManager.modifyIron(player, -ironCost, AwardFrom.REFIT_TANK);
            builder.setIron(resource.getIron());
        }

        if (oilCost > 0) {
            playerDataManager.modifyOil(player, -oilCost, AwardFrom.REFIT_TANK);
            builder.setOil(resource.getOil());
        }

        if (copperCost > 0) {
            playerDataManager.modifyCopper(player, -copperCost, AwardFrom.REFIT_TANK);
            builder.setCopper(resource.getCopper());
        }

        if (siliconCost > 0) {
            playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.REFIT_TANK);
            builder.setSilicon(resource.getSilicon());
        }

        builder.setQueue(PbHelper.createRefitQuePb(que));
        handler.sendMsgToPlayer(RefitTankRs.ext, builder.build());

        LogLordHelper.tank(AwardFrom.REFIT_TANK, player.account, player.lord, tankId, tank.getCount(), count, 0, 0);
    }

    /**
     * Method: tankQueTimerLogic
     *
     * @return void
     * @Description: 坦克建造、改装队列定时器逻辑
     */
    public void tankQueTimerLogic() {
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        while (iterator.hasNext()) {
            boolean completeBuild = false;
            Player player = iterator.next();
            try {
                if (!player.isActive()) {
                    continue;
                }
                if (!player.tankQue_1.isEmpty()) {
                    completeBuild = dealTankQue(player, player.tankQue_1, now);
                }
                if (!player.tankQue_2.isEmpty()) {
                    completeBuild = dealTankQue(player, player.tankQue_2, now);
                }
                if (!player.refitQue.isEmpty()) {
                    completeBuild = dealRefitQue(player, player.refitQue, now);
                }
                if (completeBuild) {
                    playerDataManager.updateFight(player);
                }
            } catch (Exception e) {
                LogUtil.error("坦克建造、改装队列定时器报错, lordId:" + player.lord.getLordId(), e);
            }
        }
    }

    /**
     * 检测最强阵形的合法性
     *
     * @param player
     * @param form
     * @return false - 阵形非法
     */
    public boolean checkStrongestForm(Player player, Form form) {
        AwakenHero awakenHero = form.getAwakenHero();
        StaticHero staticHero = null;

        if (awakenHero != null) {
            // 不存在此觉醒英雄
            if (awakenHero.getKeyId() < 1 || !player.awakenHeros.containsKey(awakenHero.getKeyId())) {
                LogUtil.error(String.format("nick :%s, error awaken keyId :%d", player.lord.getNick(), awakenHero.getKeyId()));
                return false;
            }
            awakenHero.setHeroId(form.getCommander());
            staticHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());
        } else {
            if (form.getCommander() > 0) {
                Hero hero = player.heros.get(form.getCommander());
                if (hero == null || hero.getCount() < 1) {
                    // 不存在此英雄
                    boolean notFound = true;
                    for (Army army : player.armys) {
                        if (army.getForm().getCommander() == form.getCommander()) {
                            notFound = false;
                            break;
                        }
                    }
                    if (notFound) {
                        LogUtil.error(String.format("nick :%s, no heroId :%d", player.lord.getNick(), form.getCommander()));
                        return false;
                    }
                }
                staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
            }
        }

        // 最大带兵量
        int maxTankCnt = playerDataManager.formTankCount(player, staticHero, awakenHero);

        return checkStrongestFormTanks(player, form, maxTankCnt);
    }

    /**
     * 部队阵容是否合法
     *
     * @param player
     * @param form
     * @param maxTankCnt
     * @return boolean
     */
    private boolean checkStrongestFormTanks(Player player, Form form, int maxTankCnt) {
        // 当前不可生产的坦克
        Map<Integer, Integer> extTanks = new HashMap<>();
        // 普通可建造坦克
        int flv = Math.max(player.building.getFactory1(), player.building.getFactory2());
        for (int i = 0; i < form.p.length; i++) {
            int tankId = form.p[i];
            if (tankId > 0) {
                // 超过带兵上限
                if (form.c[i] > maxTankCnt) {
                    LogUtil.error(String.format("nick :%s, upper limit :%d > %d", player.lord.getNick(), form.c[i], maxTankCnt));
                    return false;
                }

                StaticTank sdata = staticTankDataMgr.getStaticTank(tankId);

                if (sdata == null) {
                    return false;
                }

                if (sdata.getDestroyMilitary() == 0) {
                    // 该坦克玩家不可获得
                    LogUtil.error(String.format("nick :%s, error tank :%d", player.lord.getNick(), tankId));
                    return false;
                }
                // 玩家已经可以生产该坦克
                if (flv < sdata.getFactoryLv() || player.lord.getLevel() < sdata.getLordLv()) {
                    Integer cnt = extTanks.get(tankId);
                    extTanks.put(tankId, (cnt != null ? cnt : 0) + form.c[i]);
                }
            }
        }

        // 不可生产的坦克是否足够
        if (!extTanks.isEmpty()) {
            // 统计部队中的坦克数量
            Map<Integer, Integer> afmTanks = null;
            for (Map.Entry<Integer, Integer> entry : extTanks.entrySet()) {
                Tank tank = player.tanks.get(entry.getKey());
                int factoryCnt = tank != null ? tank.getCount() : 0;
                // 仓库中就有了足够的坦克
                if (factoryCnt >= entry.getValue())
                    continue;
                // 仓库+部队中的坦克
                if (afmTanks == null)
                    afmTanks = calcArmyTanks(player);
                Integer amCnt = afmTanks.get(entry.getKey());
                if (amCnt == null || amCnt + factoryCnt < entry.getValue()) {
                    LogUtil.error(String.format("nick %s, need cnt :%d, factory cnt :%d, am cnt :%d", player.lord.getNick(),
                            entry.getValue(), factoryCnt, amCnt != null ? amCnt : 0));
                    return false;// 加上阵形中的坦克依然不够
                }
            }
        }
        return true;
    }

    /**
     * 计算所有部队中的坦克 每种坦克数量
     *
     * @param player
     * @return Map<Integer                               ,                               Integer>
     */
    private Map<Integer, Integer> calcArmyTanks(Player player) {
        Map<Integer, Integer> afmTanks = new HashMap<>();
        // 加上部队中的坦克看看是否足够
        for (Army army : player.armys) {
            Form afm = army.getForm();
            if (afm != null) {
                for (int i = 0; i < afm.p.length; i++) {
                    int tankId = afm.p[i];
                    if (tankId > 0 && afm.c[i] > 0) {
                        Integer cnt = afmTanks.get(tankId);
                        afmTanks.put(tankId, (cnt != null ? cnt : 0) + afm.c[i]);
                    }
                }
            }
        }
        return afmTanks;
    }

}
