package com.game.service.seniormine;

import com.game.constant.*;
import com.game.dao.table.mine.CrossMinePlayerTableDao;
import com.game.datamgr.*;
import com.game.domain.CrossPlayer;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.domain.table.crossmine.CrossMinePlayerTable;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.grpc.proto.mine.CrossSeniorMineProto;
import com.game.manager.cross.seniormine.CrossMineCache;
import com.game.manager.cross.seniormine.CrossMineDataManager;
import com.game.pb.CommonPb;
import com.game.pb.CrossMinPb;
import com.game.service.FightService;
import com.game.service.crossmin.Session;
import com.game.service.crossmin.SessionManager;
import com.game.service.teaminstance.MsgSender;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author yeding
 * @create 2019/6/15 12:28
 * @decs
 */
@Component
public class CrossSeniorMineService {


    @Autowired
    private SeniorMineDataManager mineDataManager;

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private FightService fightService;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;


    @Autowired
    private CrossMinePlayerTableDao crossMinePlayerTableDao;

    @Autowired
    private CrossMineDataManager CrossMineDataManager;


    @Autowired
    private StaticLabDataMgr staticDataMgr;

    private static int[] ROB_SCORE = {50 * 3, 52 * 3, 54 * 3, 56 * 3, 58 * 3, 60 * 3, 62 * 3, 64 * 4, 66 * 4, 68 * 3};

    private static int[] OCCUPA_SCORE = {50, 52, 54, 56, 58, 60, 62, 64, 66, 68};


    /**
     * 查看矿地图信息
     *
     * @param request
     * @return
     */
    public CrossSeniorMineProto.RpcFindMineResponse findMine(CrossSeniorMineProto.RpcFindMineRequest request) {
        List<Guard> list;
        Guard guard;
        boolean sameParty;
        Iterator<List<Guard>> it = mineDataManager.getGuardMap().values().iterator();
        CrossSeniorMineProto.RpcFindMineResponse.Builder builder = CrossSeniorMineProto.RpcFindMineResponse.newBuilder();
        CrossPlayer me = CrossMineCache.getPlayer(request.getRoleId());
        if (me == null) {
            me = new CrossPlayer(request.getRoleId());
            me.setServerId(request.getServerId());
            me.setPartyId(request.getPartyId());
            me.setPartyName(request.getPartyName());
            CrossMineCache.addPlayer(me);
        }
        while (it.hasNext()) {
            list = it.next();
            if (list != null && !list.isEmpty()) {
                guard = list.get(0);
                sameParty = false;
                if (guard.getPlayer() != null && me != null && guard.getPlayer().getServerId() == me.getServerId() && guard.getPlayer().getPartyId() != 0 && guard.getPlayer().getPartyId() == me.getPartyId()) {
                    sameParty = true;
                }
                builder.addMines(CrossPbHelper.createSeniorPb(me, guard.getPlayer(), guard.getArmy(), sameParty, guard.getFreeWarTime(), guard.getStartFreeWarTime()));
            }
        }
        return builder.build();
    }


    /**
     * 侦查矿
     *
     * @param request
     * @return
     */
    public CrossSeniorMineProto.RpcScoutMineResponse scoutMine(CrossSeniorMineProto.RpcScoutMineRequest request) {
        int pos = request.getPos();
        int now = request.getTime();
        CrossSeniorMineProto.RpcScoutMineResponse.Builder response = CrossSeniorMineProto.RpcScoutMineResponse.newBuilder();

        StaticMine staticMine = mineDataManager.evaluatePos(pos);
        if (staticMine == null) {
            return response.setCode(GameError.EMPTY_POS.getCode()).build();
        }
        int product = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv()).getProduction();
        Guard guard = mineDataManager.getMineGuard(pos);
        response.setIsZJ(false);
        if (guard != null) {// 有驻军
            Army army = guard.getArmy();//1800
            if (army.getOccupy()) {
                long time = (army.getCaiJiStartTime() / 1000) + 1800 + (guard.getFreeWarTime() - guard.getStartFreeWarTime()) / 1000;
                if (now < time) {
                    return response.setCode(GameError.ATTACK_FREE.getCode()).build();
                }
            } else {
                if (guard.isFreeWar()) {
                    return response.setCode(GameError.ATTACK_FREE.getCode()).build();
                }
            }
            response.setCode(GameError.OK.getCode());
            response.setIsZJ(true);
            response.setForm(CrossPbHelper.createMineFormPb(army.getForm()));
            response.setPartyNane(guard.getPlayer().getPartyName());
            String serverName = getServerName(guard.getPlayer().getServerId());
            serverName = "(" + serverName + ")";
            response.setNickName(serverName + guard.getPlayer().getNick());
            response.setHavset(calcCollect(guard.getPlayer(), army, now, staticMine, product));
        } else {
            //无驻军,返回npc驻军信息给游戏服
            List<List<Integer>> form = mineDataManager.getMineForm(pos, staticMine.getLv()).getForm();
            for (List<Integer> integers : form) {
                response.addSenior(CrossPbHelper.createMineTwoIntPb(integers.get(0), integers.get(1)));
            }
        }
        response.setCode(GameError.OK.getCode());
        return response.build();
    }


    public CrossSeniorMineProto.FightMineResponse fightMine(CrossSeniorMineProto.FightMineRequest request) {
        int pos = request.getPos();
        int type = request.getType();
        int num = request.getNum();
        CrossPlayer attacker = CrossMineCache.getPlayer(request.getRoleId());
        if (attacker == null) {

        }
        Guard guard = mineDataManager.getMineGuard(pos);
        CrossSeniorMineProto.FightMineResponse.Builder msg = CrossSeniorMineProto.FightMineResponse.newBuilder();
        msg.setIsZJ(false);
        // 有驻军
        if (guard != null) {
            msg.setIsZJ(true);
            if (guard.isFreeWar()) {
                return msg.setCode(GameError.HERO_FREEWAR_TIME.getCode()).build();
            }
            CrossPlayer guarder = guard.getPlayer();
            if (attacker == guarder) {
                return msg.setCode(GameError.IN_COLLECT.getCode()).build();
            } else {
                if (guarder.getServerId() == attacker.getServerId() && guarder.getRoleId() == attacker.getRoleId()) {
                    return msg.setCode(GameError.IN_SAME_PARTY.getCode()).build();
                }
            }
            if (type == 2) {
                return msg.setCode(GameError.SENIOR_ATTACK_1.getCode()).build();
            }
            if (num < 1) {
                return msg.setCode(GameError.NO_SENIOR_COUNT.getCode()).build();
            }
            Army guardArmy = guard.getArmy();
            int now = TimeHelper.getCurrentSecond();
            if (guardArmy.getOccupy()) {
                long time = (guardArmy.getCaiJiStartTime() / 1000) + 1800 + (guard.getFreeWarTime() - guard.getStartFreeWarTime()) / 1000;
                if (now < time) {
                    return msg.setCode(GameError.ATTACK_FREE.getCode()).build();
                }
            }
        } else {
            if (type == 1) {
                return msg.setCode(GameError.SENIOR_ATTACK_2.getCode()).build();
            }
        }
        return msg.setCode(GameError.OK.getCode()).build();
    }

    /**
     * 攻击矿
     *
     * @param request
     */
    public void attackMine(CrossMinPb.CrossMineAttack request) {
        CrossPlayer player = CrossMineCache.getPlayer(request.getRoleId());
        Army army = new Army(request.getArmy());
        int pos = army.getTarget();
        int now = request.getNow();
        long load = request.getLoad();
        army.setLoad(load);//设置载重
        Map<Integer, PartyScience> partyScienceMap = player.getPartyScienceMap();
        Map<Integer, Map<Integer, Integer>> graduateInfo = player.getGraduateInfo();
        army.flushPartySenc(partyScienceMap, graduateInfo);
        Guard guard = mineDataManager.getMineGuard(pos);
        if (guard != null) {
            fightMineGuard(player, army, now, guard);
        } else {
            fightMineNpc(player, army, now);
        }
    }

    /**
     * 查看排名
     *
     * @param request
     * @return
     */
    public CrossSeniorMineProto.RpcScoreRankResponse checkScoreRank(CrossSeniorMineProto.RpcScoreRankRequest request) {
        CrossPlayer player = CrossMineCache.getPlayer(request.getRoleId());
        CrossSeniorMineProto.RpcScoreRankResponse.Builder builder = CrossSeniorMineProto.RpcScoreRankResponse.newBuilder();
        for (SeniorScoreRank one : mineDataManager.getScoreRank()) {
            CrossPlayer target = CrossMineCache.getPlayer(one.getLordId());
            builder.addScoreRank(CrossPbHelper.createScoreRankPb(target.getNick(), one));
        }
        Tuple<Integer, SeniorScoreRank> rank;
        if (player != null) {
            rank = mineDataManager.getScoreRank(player.getRoleId());
            builder.setScore(player.getSenScore());
        } else {
            rank = new Tuple<>(0, null);
        }
        builder.setRank(rank.getA());
        int canGet = 0;
        if (mineDataManager.getSeniorState() == mineDataManager.END_STATE) {// 结算
            if (rank.getA() > 0 && rank.getA() < 21) {
                if (!rank.getB().getGet()) {
                    canGet = 1;
                } else {
                    canGet = 2;
                }
            }
        }
        builder.setCanGet(canGet);
        return builder.build();
    }


    /**
     * 领取排名奖励
     *
     * @param request
     * @return
     */
    public CrossSeniorMineProto.RpcCoreAwardResponse getScoreAward(CrossSeniorMineProto.RpcCoreAwardRequest request) {
        CrossSeniorMineProto.RpcCoreAwardResponse.Builder msg = CrossSeniorMineProto.RpcCoreAwardResponse.newBuilder();
        Tuple<Integer, SeniorScoreRank> rank = mineDataManager.getScoreRank(request.getRoleId());
        if (rank.getA() > 0 && rank.getA() < 21) {
            if (rank.getB().getGet()) {
                return msg.setCode(GameError.ALREADY_GET_AWARD.getCode()).build();
            }
        } else {
            return msg.setCode(GameError.NOT_ON_SCORE_RANK.getCode()).build();
        }
        rank.getB().setGet(true);
        msg.setCode(GameError.OK.getCode());
        msg.setRank(rank.getA());
        return msg.build();
    }

    /**
     * 获取跨服积分排行
     *
     * @return
     */
    public CrossSeniorMineProto.RpcServerScoreRankResponse getServerRankScore(int serverId) {
        List<SeniorScoreRank> serverScoreRank = mineDataManager.getServerScoreRank();
        CrossSeniorMineProto.RpcServerScoreRankResponse.Builder msg = CrossSeniorMineProto.RpcServerScoreRankResponse.newBuilder();
        msg.setScore(0);
        msg.setRank(0);
        for (int i = 0; i < serverScoreRank.size(); i++) {
            SeniorScoreRank seniorScoreRank = serverScoreRank.get(i);
            if (seniorScoreRank.getScore() > 800) {
                CrossSeniorMineProto.ServerScoreAward.Builder builder = CrossSeniorMineProto.ServerScoreAward.newBuilder();
                builder.setScore(seniorScoreRank.getScore());
                builder.setServerId(seniorScoreRank.getLordId());
                Session session = SessionManager.getSession((int) seniorScoreRank.getLordId());
                if (session != null) {
                    builder.setServerName(session.getServerName());
                }
                msg.addInfo(builder);
            }
            if (seniorScoreRank.getLordId() == serverId) {
                msg.setScore(seniorScoreRank.getScore());
                if (seniorScoreRank.getScore() > 800) {
                    msg.setRank(i + 1);
                }
            }
        }
        return msg.build();
    }

    /**
     * 领取服务器排名奖励
     *
     * @return
     */
    public CrossSeniorMineProto.RpcCoreAwardResponse getServerRankAward(CrossSeniorMineProto.RpcCoreAwardRequest request) {
        CrossSeniorMineProto.RpcCoreAwardResponse.Builder msg = CrossSeniorMineProto.RpcCoreAwardResponse.newBuilder();
        CrossPlayer player = CrossMineCache.getPlayer(request.getRoleId());
        if (player != null) {
            if (mineDataManager.isOnGet(player)) {
                return msg.setCode(GameError.PARAM_ERROR.getCode()).build();
            }
            mineDataManager.addGetInfo(player);
            int serverScoreRank = mineDataManager.getServerScoreRank(player.getServerId());
            msg.setRank(serverScoreRank);
        }
        msg.setCode(GameError.OK.getCode());
        return msg.build();
    }


    /**
     * 攻击NPC矿点
     */
    public void fightMineNpc(CrossPlayer player, Army army, int now) {
        int pos = army.getTarget();
        StaticMine staticMine = mineDataManager.evaluatePos(pos);
        StaticMineForm staticMineForm = mineDataManager.getMineForm(pos, staticMine.getLv());
        if (staticMine == null || staticMineForm == null) {
            LogUtil.error("跨服军矿攻打有玩家驻守的矿 配置为空 pos ={}", pos);
            return;
        }
        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_OTHER);
        Fighter defencer = fightService.createFighter(staticMineForm);
        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.ATTACKER, true);
        fightLogic.packForm(army.getForm(), PbHelper.createForm(staticMineForm.getForm()));
        fightLogic.fight();
        Map<Integer, RptTank> attackHaust = haustArmyTank(attacker, army.getForm());
        Map<Integer, RptTank> defenceHaust = fightService.statisticHaustTank(defencer);
        CommonPb.Record record = fightLogic.generateRecord();
        long[] mplts = calcMilitaryExploit(attackHaust, null);
        CommonPb.RptAtkMine.Builder rptAtkMine = CommonPb.RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(0);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptMine(pos, staticMine, defenceHaust, defencer.firstValue));
        rptAtkMine.setRecord(record);
        int result = fightLogic.getWinState();
        StaticMineLv staticMineLv = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv());
        switch (result) {
            case 1:
                rptAtkMine.setResult(true);
                mineDataManager.resetMineForm(pos, staticMine.getLv());
                int score = OCCUPA_SCORE[(staticMine.getLv() - 102) / 2];
                player.setSenScore(player.getSenScore() + score);

                this.flushPlayerScore(player);
                mineDataManager.setScoreRank(player);
                mineDataManager.addServerScore(player, score);
                if (!attacker.isReborn) {
                    collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), 0);
                    //打赢了 存库/更新库
                    this.flushDb(player);
                    CrossMineDataManager.flushArmy();
                }
                break;
            default:
                rptAtkMine.setResult(false);
                break;
        }
        CrossMinPb.CrossNpcMine.Builder msg = CrossMinPb.CrossNpcMine.newBuilder();
        for (RptTank rptTank : attackHaust.values()) {
            msg.addAttackTank(CrossPbHelper.createCrossMineTwoIntPb(rptTank.getTankId(), rptTank.getCount()));
        }
        for (RptTank rptTank : defenceHaust.values()) {
            msg.addDeferTank(CrossPbHelper.createCrossMineTwoIntPb(rptTank.getTankId(), rptTank.getCount()));
        }
        msg.setRoleId(player.getRoleId());
        CommonPb.TwoLong.Builder tolong = CommonPb.TwoLong.newBuilder();
        tolong.setV1(mplts[0]);
        tolong.setV2(mplts[1]);
        msg.setMplts(tolong);
        msg.setResult(result);
        msg.setAtterReborn(attacker.isReborn);
        msg.setAttAkey(army.getKeyId());
        msg.setPos(pos);
        msg.setType(1);
        msg.setRoleId(player.getRoleId());
        msg.setRpt(rptAtkMine);
        msg.setNow(now);
        //进攻后 玩家身上携带的坦克数量
        for (int i : army.getForm().c) {
            msg.addAtterFormNum(i);
        }
        //发给进攻方
        MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossNpcMine.EXT_FIELD_NUMBER, CrossMinPb.CrossNpcMine.ext, msg.build());

    }

    /**
     * @param player
     * @param army
     * @param now
     * @return boolean
     * @throws
     * @Title: fightMineGuard
     * @Description: 攻击的矿点有玩家驻守
     */
    private void fightMineGuard(CrossPlayer player, Army army, int now, Guard guard) {
        int pos = army.getTarget();
        StaticMine staticMine = mineDataManager.evaluatePos(pos);
        if (staticMine == null) {
            LogUtil.error("跨服军矿攻打有玩家驻守的矿 配置为空 pos ={}", pos);
            return;
        }
        CrossPlayer guardPlayer = guard.getPlayer();
        Form targetForm = guard.getArmy().getForm();
        StaticMineLv staticMineLv = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv());
        long get = calcCollect(guard.getPlayer(), guard.getArmy(), now, staticMine, staticMineLv.getProduction());//计算被攻击者的资源量

        Fighter attacker = fightService.createFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
        Fighter defencer = fightService.createFighter(guardPlayer, targetForm, AttackType.ACK_DEFAULT_PLAYER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_1, true);
        fightLogic.packForm(army.getForm(), targetForm);
        fightLogic.fight();
        CommonPb.Record record = fightLogic.generateRecord();

        double worldRatio = 0.9;

        // 计算攻击者的坦克 在游戏服计算
        Map<Integer, RptTank> attackHaust = haustArmyTank(attacker, army.getForm());
        Map<Integer, RptTank> defenceHaust = haustArmyTank(defencer, targetForm);

        int result = fightLogic.getWinState();

        //计算荣耀值 游戏服做加减
        int honor = calcHonor(attackHaust, defenceHaust, worldRatio);
        if (honor > 0) {
            if (result == 1) {
                honor = giveHonor(guardPlayer, honor);
            } else {
                honor = giveHonor(player, honor);
            }
        }
        // 游戏服战功计算 0-攻方战功,1-防守方战功
        long[] mplts = calcMilitaryExploit(attackHaust, defenceHaust);
        CommonPb.RptAtkMine.Builder rptAtkMine = CommonPb.RptAtkMine.newBuilder();
        rptAtkMine.setFirst(fightLogic.attackerIsFirst());
        rptAtkMine.setHonour(honor);
        rptAtkMine.setAttacker(createRptMan(player, army.getHero(), attackHaust, 0, mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkMine.setDefencer(createRptMine(pos, staticMine, guardPlayer, targetForm.getHero(), defenceHaust, mplts != null ? mplts[1] : null, defencer.firstValue));
        rptAtkMine.setRecord(record);
        int staffingExp = calcStaffingExp(defenceHaust, worldRatio);
        int suncExp = 0;
        if (result == 1) {// 攻方胜利

            int score = ROB_SCORE[(staticMine.getLv() - 102) / 2];
            player.setSenScore(player.getSenScore() + score);
            this.flushPlayerScore(player);

            mineDataManager.setScoreRank(player);
            mineDataManager.addServerScore(player, score);

            int winStaffingExp = 0;
            int staffingExpAdd = 0;
            if (staffingExp > 0) {
                // 返回失败玩家实际扣除的编制经验
                staffingExp = giveStaffingExp(player, guardPlayer, staffingExp, army);
                suncExp = staffingExp;
                // 计算编制经验加速buff增加的比例
                winStaffingExp = staffingExp;// 只有胜利玩家获得的编制经验有加成，失败玩家扣除的编制经验没有加成
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_FIGHT)) {
                    winStaffingExp += staffingExp * 0.1;
                    staffingExpAdd += 10;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_ALL)) {
                    winStaffingExp += staffingExp * 0.1;
                    staffingExpAdd += 10;
                }

                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_AD1)) {
                    winStaffingExp += staffingExp * 0.01;
                    staffingExpAdd += 1;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_AD2)) {
                    winStaffingExp += staffingExp * 0.02;
                    staffingExpAdd += 2;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_AD3)) {
                    winStaffingExp += staffingExp * 0.03;
                    staffingExpAdd += 3;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_AD4)) {
                    winStaffingExp += staffingExp * 0.04;
                    staffingExpAdd += 4;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_AD5)) {
                    winStaffingExp += staffingExp * 0.05;
                    staffingExpAdd += 5;
                }
                if (player.getEffects().containsKey(EffectType.ADD_STAFFING_ALL2)) {
                    winStaffingExp += staffingExp * 0.2;
                    staffingExpAdd += 20;
                }
            }

            rptAtkMine.setWinStaffingExp(winStaffingExp);
            rptAtkMine.setFailStaffingExp(staffingExp);
            rptAtkMine.setStaffingExpAdd(staffingExpAdd);

            mineDataManager.removeGuard(guard);
            if (!attacker.isReborn) {
                //采集
                collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), get);
                //打赢了 存库/更新库
                this.flushDb(player);
                CrossMineDataManager.flushArmy();
            }
            rptAtkMine.setResult(true);
        } else if (result == 2) {
            rptAtkMine.setResult(false);
            //继续采集
            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, staticMineLv.getProduction(), get);
            if (defencer.isReborn) {
                mineDataManager.removeGuard(guard);
            }
        } else {
            rptAtkMine.setResult(false);
            //继续采集
            recollectArmy(guardPlayer, guard.getArmy(), now, staticMine, staticMineLv.getProduction(), get);
        }
        CrossMinPb.CrossMine.Builder msg = CrossMinPb.CrossMine.newBuilder();
        for (RptTank rptTank : attackHaust.values()) {
            msg.addAttackTank(CrossPbHelper.createCrossMineTwoIntPb(rptTank.getTankId(), rptTank.getCount()));
        }
        for (RptTank rptTank : defenceHaust.values()) {
            msg.addDeferTank(CrossPbHelper.createCrossMineTwoIntPb(rptTank.getTankId(), rptTank.getCount()));
        }
        msg.setHonor(honor);
        CommonPb.TwoLong.Builder tolong = CommonPb.TwoLong.newBuilder();
        tolong.setV1(mplts[0]);
        tolong.setV2(mplts[1]);
        msg.setMplts(tolong);
        msg.setResult(result);
        msg.setAtterReborn(attacker.isReborn);
        msg.setGet(get);
        msg.setAttAkey(army.getKeyId());
        msg.setDefAkey(guard.getArmy().getKeyId());
        msg.setPos(pos);
        msg.setDefReborn(defencer.isReborn);
        msg.setType(1);
        msg.setRoleId(player.getRoleId());
        msg.setRpt(rptAtkMine);
        for (int i : army.getForm().c) {
            msg.addAtterFormNum(i);
        }
        for (int i : targetForm.c) {
            msg.addDeferFormNum(i);
        }
        msg.setSuExp(suncExp);
        msg.setFaExp(staffingExp);
        msg.setNow(now);
        msg.setAttForm(PbHelper.createFormPb(army.getForm()));
        msg.setAttackName(player.getNick());
        msg.setAttackLevel(player.getLevel());

        //发给进攻方
        MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossMine.EXT_FIELD_NUMBER, CrossMinPb.CrossMine.ext, msg.build());

        //发给防守方
        msg.setRoleId(guardPlayer.getRoleId());
        msg.setType(2);
        MsgSender.send2Game(guardPlayer.getServerId(), CrossMinPb.CrossMine.EXT_FIELD_NUMBER, CrossMinPb.CrossMine.ext, msg.build());

    }


    /**
     * 计算坦克消耗和待修理坦克
     *
     * @param fighter
     * @param form
     * @return
     */
    private Map<Integer, RptTank> haustArmyTank(Fighter fighter, Form form) {
        Map<Integer, RptTank> map = new HashMap<>();
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
        subForceToForm(fighter, form);
        return map;
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
     * Method: calcHonorScore
     *
     * @Description: 计算战损的荣誉点 @param map1 @param map2 @param ratio @return @return int @throws
     */
    public int calcHonor(Map<Integer, RptTank> map1, Map<Integer, RptTank> map2, double ratio) {
        int score1 = calcHonorScore(map1, ratio);
        int score2 = calcHonorScore(map2, ratio);
        int score = score1 + score2;
        if (score <= 0) {
            return 0;
        } else if (score < 101) {
            return 2;
        } else if (score < 501) {
            return 3;
        } else if (score < 2001) {
            return 4;
        } else if (score < 5001) {
            return 5;
        } else if (score < 10001) {
            return 7;
        } else if (score < 16001) {
            return 10;
        } else if (score < 25001) {
            return 15;
        } else {
            return 20;
        }
    }

    /**
     * 计算荣耀点数
     *
     * @param map   key 坦克编号 RptTank 损失的坦克
     * @param ratio
     * @return int
     */
    private int calcHonorScore(Map<Integer, RptTank> map, double ratio) {
        Iterator<RptTank> it = map.values().iterator();
        int score = 0;
        int killed;
        int lost;
        StaticTank staticTank;
        while (it.hasNext()) {
            RptTank rptTank = it.next();
            killed = rptTank.getCount();
            lost = killed - (int) Math.ceil(ratio * killed);
            staticTank = staticTankDataMgr.getStaticTank(rptTank.getTankId());
            if (staticTank != null)
                score += staticTank.getHonorScore() * lost;
        }

        return score;
    }


    /**
     * 玩家pK后获得荣耀
     *
     * @param loser
     * @param honor
     * @return int
     */
    public int giveHonor(CrossPlayer loser, int honor) {
        int give;
        if (loser.getHonor() < honor) {
            give = loser.getHonor();
        } else {
            give = honor;
        }
        return give;
    }


    /**
     * 根据战损列表计算军功
     *
     * @param attackHaust    攻击方战损
     * @param defencerkHaust 防守方战损
     * @return [0]-进攻方军功, [1]-防守方军功, null :表示功能未开启
     */
    public long[] calcMilitaryExploit(Map<Integer, RptTank> attackHaust, Map<Integer, RptTank> defencerkHaust) {
        double aEplt = 0L, dEplt = 0L;// 进攻方获得军功,防守方获得军功
        if (attackHaust != null && !attackHaust.isEmpty()) {
            double[] mplt = getMilitaryExploit(attackHaust);
            aEplt += mplt[0];// 进攻方获得的军功
            dEplt += mplt[1];// 防守方获得的军功
        }
        if (defencerkHaust != null && !defencerkHaust.isEmpty()) {
            double[] mplt = getMilitaryExploit(defencerkHaust);
            aEplt += mplt[1];// 进攻方获得的军功
            dEplt += mplt[0];// 防守方获得的军功
        }
        return new long[]{(long) aEplt, (long) dEplt};
    }

    /**
     * 根据战损 双方获得的军工
     *
     * @param haust key :tank编号
     * @return double[]
     */
    private double[] getMilitaryExploit(Map<Integer, RptTank> haust) {
        double[] mplt = new double[2]; // 0-己方获得军功,1-敌方获得军功
        for (Map.Entry<Integer, RptTank> entry : haust.entrySet()) {
            StaticTank tankData = staticTankDataMgr.getTankMap().get(entry.getKey());
            if (tankData == null) {
                continue;
            }
            mplt[0] += tankData.getLostMilitary() * entry.getValue().getCount() / NumberHelper.TEN_THOUSAND;
            mplt[1] += tankData.getDestroyMilitary() * entry.getValue().getCount() / NumberHelper.TEN_THOUSAND;
        }
        return mplt;
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
    private CommonPb.RptMan createRptMan(CrossPlayer player, int hero, Map<Integer, RptTank> haust, int prosAdd, Long mplt, int firstValue) {
        CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
        builder.setName(player.getNick() == null ? "" : player.getNick());
        builder.setVip(player.getVip());
        builder.setPros(player.getPros());
        builder.setProsMax(player.getMaxPros());
        builder.setFirstValue(firstValue);
        if (mplt != null) {
            builder.setMplt(mplt.intValue());
        }
        builder.setParty(player.getPartyName());
        if (hero != 0) {
            builder.setHero(hero);
        }
        if (prosAdd != 0) {
            builder.setProsAdd(prosAdd);
        }
        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(CrossPbHelper.createRtpTankPb(it.next()));
            }
        }
        String serverName = getServerName(player.getServerId());
        builder.setServerName(serverName);
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
    private CommonPb.RptMine createRptMine(int pos, StaticMine staticMine, CrossPlayer guard, int hero, Map<Integer, RptTank> haust, Long mplt, int firstValue) {
        CommonPb.RptMine.Builder builder = CommonPb.RptMine.newBuilder();
        builder.setPos(pos);
        builder.setMine(staticMine.getType());
        builder.setLv(staticMine.getLv());
        builder.setName(guard.getNick() == null ? "" : guard.getNick());
        builder.setVip(guard.getVip());
        builder.setFirstValue(firstValue);
        if (mplt != null) {
            builder.setMplt(mplt.intValue());
        }
        builder.setParty(guard.getPartyName());

        if (hero != 0) {
            builder.setHero(hero);
        }
        if (haust != null) {
            Iterator<RptTank> it = haust.values().iterator();
            while (it.hasNext()) {
                builder.addTank(CrossPbHelper.createRtpTankPb(it.next()));
            }
        }
        String serverName = getServerName(guard.getServerId());
        builder.setServerName(serverName);
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
        builder.setLv(staticMine.getLv());
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
     * Method: calcCollect
     *
     * @Description: 计算当前部队携带的资源量 @param player @param army @param now @param staticMine @param collect @return @return
     * long @throws
     */
    public long calcCollect(CrossPlayer player, Army army, int now, StaticMine staticMine, int collect) {
        long get = 0;
        if (army.getGrab() != null) {
            get = army.getGrab().rs[staticMine.getType() - 1];
        }

        long payload;
        Collect c = army.getCollect();
        if (c != null) {
            collect = (int) (collect * (1 + c.speed / NumberHelper.HUNDRED_FLOAT));
            payload = c.load;
        } else {
            payload = this.calcLoad(army);
        }

        get = get + (long) ((now - (army.getEndTime() - army.getPeriod())) / ((double) TimeHelper.HOUR_S) * collect);

        if (get > payload) {
            get = payload;
        }
        return get;
    }

    /**
     * 采集
     * 部队载重随着游戏服算好传过来,后续不做改变
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
     */
    private void collectArmy(CrossPlayer player, Army army, int now, StaticMine staticMine, int collect, long get) {
        long load = calcLoad(army);
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
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.getVip());
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
        Effect effect = player.getEffects().get(EffectType.ADD_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd += 5;
        }
        // 采集加速
        effect = player.getEffects().get(EffectType.COLLECT_SPEED_SUPER);
        if (effect != null) {
            speedAdd += 20;
        }
        effect = player.getEffects().get(EffectType.SUB_Collect_SPEED_PS);
        if (effect != null) {
            speedAdd -= 10;
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
     * 炸矿后重新采集
     *
     * @param player
     * @param army
     * @param now
     * @param staticMine
     * @param collect
     * @param get        void
     */
    public void recollectArmy(CrossPlayer player, Army army, int now, StaticMine staticMine, int collect, long get) {
        long load = calcLoad(army);
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
            StaticVip staticVip = staticVipDataMgr.getStaticVip(player.getVip());
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

        // 这里使用时改变了occupy的语义，这里是表示该部队不处于保护中了
        army.setOccupy(false);
    }


    /**
     * Method: calcStaffingExp
     *
     * @Description: 计算战损产生的编制经验 @param map @param ratio @return @return int @throws
     */
    public int calcStaffingExp(Map<Integer, RptTank> map, double ratio) {
        int exp = 0;
        int killed;
        int lost;
        StaticTank staticTank;
        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = it.next();
            killed = rptTank.getCount();
            lost = killed - (int) Math.ceil(ratio * killed);
            staticTank = staticTankDataMgr.getStaticTank(rptTank.getTankId());
            if (staticTank != null)
                exp += staticTank.getStaffingExp() * lost;
        }
        return exp;
    }

    /**
     * 玩家pk后获得编制经验
     *
     * @param winner
     * @param loser
     * @param exp
     * @return int
     */
    public int giveStaffingExp(CrossPlayer winner, CrossPlayer loser, int exp, Army army) {
        int winnerExp = exp;
        if (exp != 0) {
            // 计算编制经验加速buff增加的比例
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_FIGHT)) {
                winnerExp += exp * 0.1;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_ALL)) {
                winnerExp += exp * 0.1;
            }

            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_AD1)) {
                winnerExp += exp * 0.01;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_AD2)) {
                winnerExp += exp * 0.02;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_AD3)) {
                winnerExp += exp * 0.03;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_AD4)) {
                winnerExp += exp * 0.04;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_AD5)) {
                winnerExp += exp * 0.05;
            }
            if (winner.getEffects().containsKey(EffectType.ADD_STAFFING_ALL2)) {
                winnerExp += exp * 0.2;
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
                            LogUtil.error("觉醒将领技能未配置ccx:" + entry.getKey() + " 等级:" + entry.getValue());
                            continue;
                        }
                        if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_STAFFING_EXP) {
                            String val = staticHeroAwakenSkill.getEffectVal();
                            if (val != null && !val.isEmpty()) {
                                winnerExp += exp * (Float.valueOf(val) / 100.0f);
                            }
                        }
                    }
                }
            }
        }
        return winnerExp;
    }

    /**
     * 刷新数据库
     *
     * @param player
     */
    public void flushDb(CrossPlayer player) {
        CrossMinePlayerTable table = crossMinePlayerTableDao.get(player.getRoleId());
        if (table == null) {
            table = new CrossMinePlayerTable(player);
            crossMinePlayerTableDao.insert(table);
        } else {
            table = new CrossMinePlayerTable(player);
            crossMinePlayerTableDao.update(table);
        }
    }

    /**
     * 玩家撤回部队
     *
     * @param request
     */
    public CrossSeniorMineProto.RpcRetreatArmyResponse retreatArmy(CrossSeniorMineProto.RpcRetreatArmyRequest request) {
        long roleId = request.getRoleId();
        int pos = request.getPos();
        Guard mineGuard = mineDataManager.getMineGuard(pos);
        if (mineGuard != null) {
            CrossPlayer player = mineGuard.getPlayer();
            if (player != null && player.getRoleId() == roleId) {
                mineDataManager.removeGuard(pos);
            }
        }
        CrossSeniorMineProto.RpcRetreatArmyResponse.Builder msg = CrossSeniorMineProto.RpcRetreatArmyResponse.newBuilder();
        msg.setCode(GameError.OK.getCode());
        return msg.build();
    }


    public void flushPlayerScore(CrossPlayer player) {
        CrossMinePlayerTable table = crossMinePlayerTableDao.get(player.getRoleId());
        if (table == null) {
            table = new CrossMinePlayerTable(player);
            crossMinePlayerTableDao.insert(table);
        } else {
            table.setScore(player.getSenScore());
            crossMinePlayerTableDao.update(table);
        }

    }

    public CrossSeniorMineProto.RpcRetreatArmyResponse gmClear(CrossSeniorMineProto.RpcGmquest request) {
        int type = request.getType();
        switch (type) {
            case 1:
                String nick = request.getNick();
                CrossPlayer player = CrossMineCache.getPalyer(nick);
                player.setSenScore(request.getScore());
                mineDataManager.addServerScore(player, request.getScore());
                mineDataManager.setScoreRank(player);
                break;
            case 2:
                mineDataManager.clear();
                break;
            default:
                break;
        }
        return CrossSeniorMineProto.RpcRetreatArmyResponse.newBuilder().setCode(GameError.OK.getCode()).build();

    }


    /**
     * 计算部队载重
     *
     * @return long
     */
    public long calcLoad(Army army) {
        Form form = army.getForm();
        long load = 0L;
        int[] p = form.p;
        int[] c = form.c;
        // 载重技术
        int scienceLv = 0;
        float scienceLv215 = 0.0f;
        Map<Integer, Integer> partyScience = army.getPartyScience();
        Integer payLv = partyScience.get(ScienceId.PAY_LOAD);
        if (payLv != null) {
            scienceLv = payLv;
        }
        Integer science215 = partyScience.get(ScienceId.PAY_LOAD_215);
        if (science215 != null) {
            scienceLv215 = science215;
        }
        for (int i = 0; i < p.length; i++) {
            if (p[i] != 0) {
                StaticTank staticTank = staticTankDataMgr.getStaticTank(p[i]);
                // 作战实验室单兵种载重加成
                int labAdd = this.getSpecilAttrAdd(army, AttrId.LOAD_CAPACITY_ALL + staticTank.getType());
                int labAddAll = this.getSpecilAttrAdd(army, AttrId.LOAD_CAPACITY_ALL);
                int heroAtio = 0;
                // 英雄觉醒被动技能增加载重百分百
                AwakenHero awakenHero = form.getAwakenHero();
                if (awakenHero != null) {
                    for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                        if (entry.getValue() <= 0) {
                            continue;
                        }
                        StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                        if (staticHeroAwakenSkill == null) {
                            LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                            continue;
                        }
                        if (staticHeroAwakenSkill.getEffectType() == HeroConst.HERO_ADD_LOAD) {
                            String val = staticHeroAwakenSkill.getEffectVal();
                            if (val != null && !val.isEmpty()) {
                                heroAtio += Float.valueOf(val);
                            }
                        }
                    }
                }
                float addtion = labAdd + labAddAll + heroAtio + scienceLv + NumberHelper.HUNDRED_INT;
                //大于等于4品质以上的才载重
                if (staticTank.getGrade() == 4) {
                    addtion = addtion + scienceLv215 * 0.5f;
                }
                if (staticTank.getGrade() >= 5) {
                    addtion = addtion + scienceLv215;
                }
                load += (staticTank.getPayload() * (long) c[i]) * ((addtion * 1.0f) / NumberHelper.HUNDRED_INT);
            }
        }
        // 废墟载重减半
        if (army.isRuins()) {
            load = (long) ((load * Constant.RUINS_LOAD_REDUCE * 1.0f) / NumberHelper.TEN_THOUSAND);
        }
        return load;
    }


    /**
     * 获取服务器编号
     *
     * @param serverId
     * @return
     */
    public String getServerName(int serverId) {
        Session session = SessionManager.getSession(serverId);
        String servName = null;
        String[] split = null;
        if (session != null) {
            servName = session.getServerName();
            if (servName != null) {
                split = servName.split(" ");
            }
        }
        if (split != null) {
            servName = split[0];
        }
        return servName == null ? "" : servName;
    }


    /**
     * 获取作战实验室对指定属性的加成
     *
     * @param specilAttrId
     * @return 加成数值
     */
    public int getSpecilAttrAdd(Army army, int specilAttrId) {
        int attrAdd = 0;
        Map<Integer, Set<Integer>> typeMap = staticDataMgr.getSpecilSkillList(specilAttrId);
        if (typeMap == null || typeMap.isEmpty())
            return attrAdd;//此属性没有任何加成技能
        Map<Integer, Map<Integer, Integer>> grdMap = army.getGraduateInfo();
        for (Map.Entry<Integer, Set<Integer>> entry : typeMap.entrySet()) {
            Map<Integer, Integer> sklMap = grdMap.get(entry.getKey());
            if (sklMap == null || sklMap.isEmpty())
                continue;//指定类型的技能集合不存在

            for (Integer skillId : entry.getValue()) {
                Integer skillLv = sklMap.get(skillId);
                if (skillLv == null || skillLv == 0)
                    continue;//技能未学习

                StaticLaboratoryMilitary data = staticDataMgr.getGraduateConfig(entry.getKey(), skillId, skillLv);
                List<List<Integer>> effects = data != null ? data.getEffect() : null;
                if (effects == null || effects.isEmpty())
                    continue;//技能效果未配置

                //累加技能属性
                for (List<Integer> effect : data.getEffect()) {
                    if (effect.get(0) == specilAttrId) {
                        attrAdd += effect.get(1);
                    }
                }
            }
        }
        return attrAdd;
    }

}