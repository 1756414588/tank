package com.game.service.crossmine;

import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.grpc.proto.mine.CrossSeniorMineProto;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.*;
import com.game.server.CrossMinContext;
import com.game.server.GameServer;
import com.game.service.*;
import com.game.service.teaminstance.TeamInstanceService;
import com.game.service.teaminstance.TeamRpcService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import sun.rmi.runtime.Log;

import java.util.*;

/**
 * @author yeding
 * @create 2019/6/12 9:14
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
    private StaticPropDataMgr staticPropDataMgr;

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
    private RewardService rewardService;

    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private TeamInstanceService teamInstanceService;

    @Autowired
    private StaticLabDataMgr staticDataMgr;


    private static int[] ROB_SCORE = {50 * 3, 52 * 3, 54 * 3, 56 * 3, 58 * 3, 60 * 3, 62 * 3, 64 * 4, 66 * 4, 68 * 3};

    private static int[] OCCUPA_SCORE = {50, 52, 54, 56, 58, 60, 62, 64, 66, 68};

    /**
     * CrossSeniorMineService
     * 军事矿地图
     *
     * @param handler void
     */
    public void getSeniorMap(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }
        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (player.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }
        if (!CrossMinContext.isCrossMinSocket()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        refreshSenior(player);
        GamePb6.GetCrossSeniorMapRs.Builder builder = GamePb6.GetCrossSeniorMapRs.newBuilder();

        CrossSeniorMineProto.RpcFindMineRequest.Builder senMsg = CrossSeniorMineProto.RpcFindMineRequest.newBuilder();
        senMsg.setRoleId(player.lord.getLordId());
        Member member = partyDataManager.getMemberById(player.lord.getLordId());
        if (member != null) {
            senMsg.setPartyId(member.getPartyId());
            PartyData party = partyDataManager.getParty(member.getPartyId());
            if (party != null) {
                senMsg.setPartyName(party.getPartyName());
            }
        }
        senMsg.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
        CrossSeniorMineProto.RpcFindMineResponse mine = MineRpcService.findMine(senMsg);

        if (mine == null) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        List<CrossSeniorMineProto.SeniorMapData> minesList = mine.getMinesList();
        for (CrossSeniorMineProto.SeniorMapData seniorMapData : minesList) {
            builder.addData(CrossPbHelper.createCorssMine(seniorMapData));
        }
        builder.setCount(player.seniorCount);
        builder.setLimit(5);
        builder.setBuy(player.seniorBuy);
        handler.sendMsgToPlayer(GamePb6.GetCrossSeniorMapRs.ext, builder.build());
    }


    /**
     * 侦查矿点协议处理
     *
     * @param pos
     * @param handler void
     */
    public void scout(int pos, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }
        if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {// 结算
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_DAY);
            return;
        }
        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (player.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }
        if (!teamInstanceService.isCrossOpen()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        //检查并重置侦查次数
        int nowDay = TimeHelper.getCurrentDay();
        playerService.checkAndResetScount(player, nowDay);

        scoutMine(player, pos, handler);
    }


    /**
     * 进攻军事矿区
     *
     * @param req
     * @param handler void
     */
    public void attack(GamePb6.AtkCrossSeniorMineRq req, ClientHandler handler) {
        Player attacker = playerDataManager.getPlayer(handler.getRoleId());
        if (attacker == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }
        if (mineDataManager.getSeniorState() != SeniorState.START_STATE) {// 结算
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_DAY);
            return;
        }
        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (attacker.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }
        if (!teamInstanceService.isCrossOpen()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        if (attacker.lord.getPower() < 1) {
            handler.sendErrorMsgToPlayer(GameError.NO_POWER);
            return;
        }
        int maxCount = playerDataManager.armyCount(attacker);
        if (playerDataManager.getPlayArmyCount(attacker, maxCount) >= maxCount) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }
        int pos = req.getPos();
        StaticMine staticMine = mineDataManager.getCrossSeniorMine(pos);//获取跨服军矿配置
        if (staticMine == null) {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
            return;
        }
        refreshSenior(attacker);
        int type = req.getType();

        CrossSeniorMineProto.FightMineResponse fightMineResponse = MineRpcService.fightMine(handler.getRoleId(), pos, type, attacker.seniorCount);
        if (fightMineResponse == null) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        int code = fightMineResponse.getCode();
        if (code != GameError.OK.getCode()) {
            handler.sendErrorMsgCodeToPlayer(code);
            return;
        }
        Form attackForm = PbHelper.createForm(req.getForm());
        boolean flag = doFight(attacker, handler, attackForm);
        if (!flag) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        //同步用户基础数据去跨服
        TeamRpcService.synPlayer(attacker, partyDataManager, fightService, true, 2);
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(attacker.maxKey(), pos, ArmyState.CROSS_MINE, attackForm, 0, now, playerDataManager.isRuins(attacker));
        army.setCrossMine(true);
        //军团科技
        Map<Integer, PartyScience> science = partyDataManager.getScience(attacker);
        Map<Integer, Map<Integer, Integer>> graduateInfo = attacker.labInfo.getGraduateInfo();
        army.flushPartySenc(science, graduateInfo);
        attacker.armys.add(army);
        playerDataManager.subPower(attacker.lord, 1);
        if (fightMineResponse.getIsZJ()) {
            attacker.seniorCount = attacker.seniorCount - 1;
        } else {
            army.setOccupy(true);
        }
        //攻打
        CrossMinPb.CrossMineAttack.Builder attack = CrossMinPb.CrossMineAttack.newBuilder();
        attack.setRoleId(attacker.lord.getLordId());
        attack.setArmy(PbHelper.createArmyPb(army));
        attack.setNow(now);
        attack.setLoad(0);

        BasePb.Base.Builder baseBuilder = PbHelper.createRqBase(CrossMinPb.CrossMineAttack.EXT_FIELD_NUMBER, null, CrossMinPb.CrossMineAttack.ext, attack.build());
        GameServer.getInstance().sendMsgToCrossMin(baseBuilder);

    }


    /**
     * 查看个人排行
     *
     * @param handler
     */
    public void checkScoreRank(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }

        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (player.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }

        if (!CrossMinContext.isCrossMinSocket()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }

        CrossSeniorMineProto.RpcScoreRankResponse rpcScoreRankResponse = MineRpcService.checkScoreRank(handler.getRoleId());
        if (rpcScoreRankResponse == null) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }

        GamePb6.CrossScoreRankRs.Builder msg = GamePb6.CrossScoreRankRs.newBuilder();
        List<CrossSeniorMineProto.ScoreRank> scoreRankList = rpcScoreRankResponse.getScoreRankList();
        for (CrossSeniorMineProto.ScoreRank scoreRank : scoreRankList) {
            msg.addScoreRank(CrossPbHelper.createScoreRankPb(scoreRank));
        }
        msg.setCanGet(rpcScoreRankResponse.getCanGet());
        msg.setRank(rpcScoreRankResponse.getRank());
        msg.setScore(rpcScoreRankResponse.getScore());
        handler.sendMsgToPlayer(GamePb6.CrossScoreRankRs.ext, msg.build());

    }

    /**
     * 领取个人排行奖励
     *
     * @param handler
     */
    public void doScoreAward(ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }

        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }
        if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_NOT_END);
            return;
        }

        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (player.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }

        if (!CrossMinContext.isCrossMinSocket()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        refreshSenior(player);
        CrossSeniorMineProto.RpcCoreAwardResponse scoreRank = MineRpcService.getScoreRankAward(handler.getRoleId());
        if (scoreRank == null) {
            return;
        }
        if (scoreRank.getCode() != GameError.OK.getCode()) {
            handler.sendErrorMsgCodeToPlayer(scoreRank.getCode());
            return;
        }
        GamePb6.CrossScoreAwardRs.Builder builder = GamePb6.CrossScoreAwardRs.newBuilder();
        List<List<Integer>> awards = staticWarAwardDataMgr.getCrossMineAward(scoreRank.getRank());
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.CROSS_SCORE_AWARD));
        handler.sendMsgToPlayer(GamePb6.CrossScoreAwardRs.ext, builder.build());
    }


    /**
     * 查看服务器排行
     *
     * @param handler
     */
    public void checkServerScoreRank(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }

        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }

        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_UNLOCK);
        if (systemConstantById != null) {
            if (player.lord.getLevel() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
        }

        if (!CrossMinContext.isCrossMinSocket()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }

        CrossSeniorMineProto.RpcServerScoreRankResponse rpcServerScoreRankResponse = MineRpcService.checkServerScoreRank();
        if (rpcServerScoreRankResponse == null) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }
        GamePb6.CrossServerScoreRankRs.Builder msg = GamePb6.CrossServerScoreRankRs.newBuilder();
        List<CrossSeniorMineProto.ServerScoreAward> infoList = rpcServerScoreRankResponse.getInfoList();
        for (CrossSeniorMineProto.ServerScoreAward serverScoreAward : infoList) {
            msg.addScoreRank(CrossPbHelper.createServerScoreRankPb(serverScoreAward));
        }
        msg.setScore(rpcServerScoreRankResponse.getScore());
        int rank = rpcServerScoreRankResponse.getRank();
        msg.setRank(rank);
        if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {// 结算
            msg.setCanGet(0);
        } else {
            if (player.getCrossMineGet() == 2) {
                msg.setCanGet(player.getCrossMineGet());
            } else {
                msg.setCanGet(0);
                if (rank > 0) {
                    List<List<Integer>> crossServerMineAward = staticWarAwardDataMgr.getCrossServerMineAward(rank);
                    if (crossServerMineAward != null) {
                        StaticSystem flag = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_AWARD_UNLOCK);
                        msg.setCanGet(player.getCrossMineGet());
                        if (flag != null) {
                            if (player.getCrossMineScore() < Integer.parseInt(flag.getValue())) {
                                msg.setCanGet(0);
                            }
                        }
                    }
                }
            }
        }
        handler.sendMsgToPlayer(GamePb6.CrossServerScoreRankRs.ext, msg.build());
    }


    /**
     * 领取服务器排行奖励
     *
     * @param handler
     */
    public void doServerScoreAward(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        if (!TimeHelper.isStaffingOpen()) {
            handler.sendErrorMsgToPlayer(GameError.STAFFING_NOT_OPEN);
            return;
        }
        if (mineDataManager.getSeniorState() != SeniorState.END_STATE) {
            handler.sendErrorMsgToPlayer(GameError.SENIOR_MINE_NOT_END);
            return;
        }

        StaticSystem systemConstantById = staticIniDataMgr.getSystemConstantById(SystemId.CROSSMINE_AWARD_UNLOCK);
        if (systemConstantById != null) {
            if (player.getCrossMineScore() < Integer.parseInt(systemConstantById.getValue())) {
                handler.sendErrorMsgToPlayer(GameError.SCORE_NOT_ENOUGH);
                return;
            }
        }

        if (!CrossMinContext.isCrossMinSocket()) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }

        refreshSenior(player);
        CrossSeniorMineProto.RpcCoreAwardResponse scoreRank = MineRpcService.getServerRankAward(handler.getRoleId());
        if (scoreRank == null) {
            return;
        }
        if (scoreRank.getCode() != GameError.OK.getCode()) {
            handler.sendErrorMsgCodeToPlayer(scoreRank.getCode());
            return;
        }
        GamePb6.CrossServerScoreAwardRs.Builder builder = GamePb6.CrossServerScoreAwardRs.newBuilder();
        List<List<Integer>> awards = staticWarAwardDataMgr.getCrossServerMineAward(scoreRank.getRank());
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.CROSS_SERVER_SCORE_AWARD));
        player.setCrossMineGet(2);
        handler.sendMsgToPlayer(GamePb6.CrossServerScoreAwardRs.ext, builder.build());
    }


    /**
     * 侦查矿点
     *
     * @param player
     * @param pos
     * @param handler void
     */
    private void scoutMine(Player player, int pos, ClientHandler handler) {
        StaticMine staticMine = mineDataManager.getCrossSeniorMine(pos);
        if (staticMine == null) {
            handler.sendErrorMsgToPlayer(GameError.EMPTY_POS);
            return;
        }

        Lord lord = player.lord;
        int scount = lord.getScount() + 1;
        long scountCost = worldDataManager.getScoutNeedStone(lord, staticMine.getLv(), 1);
        if (player.resource.getStone() < scountCost) {
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }
        lord.setScount(scount);

        int now = TimeHelper.getCurrentSecond();
        CrossSeniorMineProto.RpcScoutMineResponse rpcScoutMineResponse = MineRpcService.scoutMine(handler.getRoleId(), now, pos);

        if (rpcScoutMineResponse == null) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
            return;
        }

        if (rpcScoutMineResponse.getCode() != GameError.OK.getCode()) {
            handler.sendErrorMsgCodeToPlayer(rpcScoutMineResponse.getCode());
            return;
        }
        boolean isZJ = rpcScoutMineResponse.getIsZJ();
        CommonPb.RptScoutMine.Builder rptMine = CommonPb.RptScoutMine.newBuilder();
        int product = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv()).getProduction();
        if (isZJ) {
            rptMine.setParty(rpcScoutMineResponse.getPartyNane());
            rptMine.setFriend(rpcScoutMineResponse.getNickName());
            rptMine.setForm(CrossPbHelper.createFormPb(rpcScoutMineResponse.getForm()));
            rptMine.setHarvest(rpcScoutMineResponse.getHavset());
        } else {
            //无驻军时 拿跨服npc驻军数据
            List<CrossSeniorMineProto.MineTwoInt> seniorList = rpcScoutMineResponse.getSeniorList();
            List<List<Integer>> list = new ArrayList<>();
            for (CrossSeniorMineProto.MineTwoInt mineTwoInt : seniorList) {
                ArrayList<Integer> al = new ArrayList<>();
                al.add(mineTwoInt.getV1());
                al.add(mineTwoInt.getV2());
                list.add(al);
            }
            rptMine.setForm(PbHelper.createFormPb(list));
        }
        rptMine.setPos(pos);
        rptMine.setLv(staticMine.getLv());
        rptMine.setProduct(product);
        rptMine.setMine(staticMine.getType());

        CommonPb.Report.Builder report = CommonPb.Report.newBuilder();
        report.setScoutMine(rptMine);
        report.setTime(now);
        Mail mail = playerDataManager.createReportMail(player, report.build(), MailType.CROSS_MINE_SCOUT, TimeHelper.getCurrentSecond(), String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
        playerDataManager.modifyStone(player, -scountCost, AwardFrom.SCOUT_MINE);
        GamePb6.SctCrossSeniorMineRs.Builder builder = GamePb6.SctCrossSeniorMineRs.newBuilder();
        builder.setMail(PbHelper.createMailPb(mail));
        handler.sendMsgToPlayer(GamePb6.SctCrossSeniorMineRs.ext, builder.build());
    }


    /**
     * 游戏服通知跨服 部队撤回
     *
     * @param uid
     * @param pos
     */
    public void retreatArmy(long uid, int pos) {
        CrossSeniorMineProto.RpcRetreatArmyRequest.Builder request = CrossSeniorMineProto.RpcRetreatArmyRequest.newBuilder();
        request.setRoleId(uid);
        request.setPos(pos);
        MineRpcService.resetArmy(request.build());
    }

    /**
     * 攻打 npc矿后 ,跨服 回调
     *
     * @param mine
     */
    public void synCrossNpcMine(CrossMinPb.CrossNpcMine mine) {
        long roleId = mine.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        int pos = mine.getPos();
        StaticMine staticMine = mineDataManager.getCrossSeniorMine(pos);
        Army army = getArmy(player, mine.getAttAkey());
        Map<Integer, RptTank> attackHaust = new HashMap<>();
        Map<Integer, RptTank> defenceHaust = new HashMap<>();
        MapUtil.crossMap(attackHaust, mine.getAttackTankList());
        MapUtil.crossMap(defenceHaust, mine.getDeferTankList());
        //战功计算 0-攻方战功,1-防守方战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = playerDataManager.calcMilitaryExploit(attackHaust, null);
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }
        CommonPb.RptAtkMine rpt = mine.getRpt();
        activityDataManager.tankDestory(player, defenceHaust, false);// 疯狂歼灭坦克
        int result = mine.getResult();
        int now = mine.getNow();
        List<Integer> atterFormNumList = mine.getAtterFormNumList();
        subForceToForm(atterFormNumList, army.getForm());
        subTank(player, attackHaust);
        GamePb6.AtkCrossSeniorMineRs.Builder atk = GamePb6.AtkCrossSeniorMineRs.newBuilder();
        switch (result) {
            case 1:
                playerDataManager.activeBoxDrop(player);
                int score = OCCUPA_SCORE[(staticMine.getLv() - 102) / 2];
                player.setCrossMineScore(player.getCrossMineScore() + score);

                StaticMineLv staticMineLv = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv());
                int heroId = army.getForm().getCommander();
                StaticHero staticHero = null;
                if (heroId != 0) {
                    staticHero = staticHeroDataMgr.getStaticHero(heroId);
                }
                int exp = (int) (staticMineLv.getExp() * fightService.effectMineExpAdd(player, staticHero));
                playerDataManager.addExp(player, exp);

                if (mine.getAtterReborn()) {
                    backHero(player, army.getForm());
                    removeArmy(mine.getAttAkey(), player);
                    ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                    playerDataManager.synArmyToPlayer(player, guardStatu);
                } else {
                    collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), 0);
                    atk.setArmy(PbHelper.createArmyPb(army));
                }
                int realExp = playerDataManager.realExp(player, exp);

                CommonPb.RptAtkMine.Builder builder = rpt.toBuilder();
                builder.addAward(PbHelper.createAwardPb(AwardType.EXP, 0, realExp));
                CommonPb.Award award = mineDropOneAward(player, staticMine.getDropOne());
                if (award != null) {
                    StaticProp staticProp = staticPropDataMgr.getStaticProp(award.getId());
                    if (staticProp != null && staticProp.getColor() >= 4) {
                        chatService.sendWorldChat(chatService.createSysChat(SysChatId.ATTACK_MINE, player.lord.getNick(), staticProp.getPropName()));
                    }
                    builder.addAward(award);
                }
                playerDataManager.sendReportMail(player, createAtkMineReport(builder.build(), now), MailType.ATTACT_CROSS_MINE_WIN, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                break;
            case 2:
                backHero(player, army.getForm());
                removeArmy(mine.getAttAkey(), player);
                playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.ATTACT_CROSS_MINE_FALSE, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                break;
            default:
                playerDataManager.retreatEnd(player, army);
                removeArmy(mine.getAttAkey(), player);
                playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.ATTACT_CROSS_MINE_FALSE, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                break;
        }
        atk.setCount(player.seniorCount);
        BasePb.Base.Builder builder = PbHelper.createSynBase(GamePb6.AtkCrossSeniorMineRs.EXT_FIELD_NUMBER, GamePb6.AtkCrossSeniorMineRs.ext, atk.build());
        GameServer.getInstance().sendMsgToPlayer(player.ctx, builder);
    }


    /**
     * 攻打驻军矿之后的回调
     *
     * @param mine
     */
    public void synCrossMine(CrossMinPb.CrossMine mine) {
        Player player = playerDataManager.getPlayer(mine.getRoleId());
        if (player == null) {
            return;
        }
        //攻击者处理逻辑
        Map<Integer, RptTank> attackHaust = new HashMap<>();
        Map<Integer, RptTank> defenceHaust = new HashMap<>();
        MapUtil.crossMap(attackHaust, mine.getAttackTankList());
        MapUtil.crossMap(defenceHaust, mine.getDeferTankList());
        Army army;
        CommonPb.TwoLong mplts = mine.getMplts();
        StaticMine staticMine = mineDataManager.getCrossSeniorMine(mine.getPos());
        StaticMineLv staticMineLv = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv());
        CommonPb.RptAtkMine rpt = mine.getRpt();
        int now = TimeHelper.getCurrentSecond();
        int result = mine.getResult();
        int winnerExp = mine.getSuExp();
        int loseExp = mine.getFaExp();
        int honor = mine.getHonor();
        int type = mine.getType();
        if (type == 1) {
            army = getArmy(player, mine.getAttAkey());
            if (army == null) {
                return;
            }
            //如果是进攻方
            activityDataManager.tankDestory(player, defenceHaust, true);// 疯狂歼灭坦克
            subTank(player, attackHaust);
            if (result == 1) {
                player.lord.setHonour(player.lord.getHonour() + honor);
            } else {
                int ho = player.lord.getHonour() - honor;
                player.lord.setHonour(ho < 0 ? 0 : ho);
            }
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts.getV1(), AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            List<Integer> atterFormNumList = mine.getAtterFormNumList();
            subForceToForm(atterFormNumList, army.getForm());
            GamePb6.AtkCrossSeniorMineRs.Builder atk = GamePb6.AtkCrossSeniorMineRs.newBuilder();
            //如果是进攻方,且胜利
            switch (result) {
                case 1:
                    staticStaffingDataMgr.addStaffingExp(player.lord, winnerExp);
                    rankDataManager.setStaffing(player.lord);
                    player.lord.setStaffing(calcStaffing(player));
                    synStaffingToPlayer(player);
                    playerDataManager.activeBoxDrop(player);
                    int score = ROB_SCORE[(staticMine.getLv() - 102) / 2];
                    player.setCrossMineScore(player.getCrossMineScore() + score);
                    if (mine.getAtterReborn()) {
                        backHero(player, army.getForm());
                        removeArmy(mine.getAttAkey(), player);
                        ArmyStatu guardStatu = new ArmyStatu(player.roleId, army.getKeyId(), 3);
                        playerDataManager.synArmyToPlayer(player, guardStatu);

                    } else {
                        collectArmy(player, army, now, staticMine, staticMineLv.getProduction(), mine.getGet());
                        atk.setArmy(PbHelper.createArmyPb(army));
                    }
                    CommonPb.RptAtkMine.Builder builder = rpt.toBuilder();
                    Grab g = new Grab();
                    g.rs[staticMine.getType() - 1] = mine.getGet();
                    builder.setGrab(PbHelper.createGrabPb(g));
                    playerDataManager.sendReportMail(player, createAtkMineReport(builder.build(), now), MailType.ATTACT_CROSS_MINE_WIN, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                    break;
                case 2:
                    backHero(player, army.getForm());
                    removeArmy(mine.getAttAkey(), player);
                    playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.ATTACT_CROSS_MINE_FALSE, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                    break;
                default:
                    playerDataManager.retreatEnd(player, army);
                    removeArmy(mine.getAttAkey(), player);
                    playerDataManager.sendReportMail(player, createAtkMineReport(rpt, now), MailType.ATTACT_CROSS_MINE_FALSE, now, String.valueOf(staticMine.getType()), String.valueOf(staticMine.getLv()));
                    break;
            }
            atk.setCount(player.seniorCount);
            BasePb.Base.Builder builder = PbHelper.createSynBase(GamePb6.AtkCrossSeniorMineRs.EXT_FIELD_NUMBER, GamePb6.AtkCrossSeniorMineRs.ext, atk.build());
            GameServer.getInstance().sendMsgToPlayer(player.ctx, builder);
        } else {
            //如果是防守方.
            army = getArmy(player, mine.getDefAkey());
            if (army == null) {
                return;
            }
            CommonPb.Form form = mine.getAttForm();
            activityDataManager.tankDestory(player, attackHaust, true);// 疯狂歼灭坦克
            subDferTank(player, defenceHaust, PbHelper.createForm(form));
            //设置army里面的form tank数量
            List<Integer> deferFo = mine.getDeferFormNumList();
            subForceToForm(deferFo, army.getForm());
            if (result == 1) {
                int ho = player.lord.getHonour() - honor;
                player.lord.setHonour(ho < 0 ? 0 : ho);
            } else {
                player.lord.setHonour(player.lord.getHonour() + honor);
            }
            playerDataManager.addAward(player, AwardType.MILITARY_EXPLOIT, 1, mplts.getV2(), AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            int defAkey = mine.getDefAkey();
            switch (result) {
                case 1:
                    removeArmy(defAkey, player);
                    CommonPb.RptAtkMine.Builder builder = rpt.toBuilder();
                    long get = mine.getGet();
                    Grab grab = new Grab();
                    grab.rs[staticMine.getType() - 1] = get;
                    builder.setGrab(PbHelper.createGrabPb(grab));
                    playerDataManager.sendReportMail(player, createDefMineReport(builder.build(), now), MailType.DF_CROSS_MINE_FALSE, now, mine.getAttackName(), String.valueOf(mine.getAttackLevel()));
                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 3));
                    staticStaffingDataMgr.subStaffingExp(player.lord, loseExp);
                    rankDataManager.setStaffing(player.lord);
                    player.lord.setStaffing(calcStaffing(player));
                    synStaffingToPlayer(player);
                    break;
                case 2:
                    //防守方继续采集
                    int state = 3;
                    recollectArmy(player, army, now, staticMine, staticMineLv.getProduction(), mine.getGet());
                    playerDataManager.sendReportMail(player, createDefMineReport(rpt, now), MailType.DF_CROSS_MINE_WIN, now, mine.getAttackName(), String.valueOf(mine.getAttackLevel()));
                    if (mine.getDefReborn()) {
                        backHero(player, army.getForm());
                        removeArmy(defAkey, player);
                    } else {
                        state = 4;
                    }
                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), state));
                    break;
                default:
                    //防守者继续采集
                    recollectArmy(player, army, now, staticMine, staticMineLv.getProduction(), mine.getGet());
                    playerDataManager.sendReportMail(player, createDefMineReport(rpt, now), MailType.DF_CROSS_MINE_WIN, now, mine.getAttackName(), String.valueOf(mine.getAttackLevel()));
                    playerDataManager.synArmyToPlayer(player, new ArmyStatu(player.roleId, army.getKeyId(), 4));
                    break;
            }
        }
    }

    /**
     * 跨服通知游戏服矿被炸了.移除部队
     */
    public void removeArmy(int key, Player player) {
        if (player == null) {
            return;
        }
        LinkedList<Army> armys = player.armys;
        Army army = null;
        for (Army army1 : armys) {
            if (army1.getKeyId() == key) {
                army = army1;
                break;
            }
        }
        armys.remove(army);
        int heroId = army.getForm().getCommander();
        if (army.getForm().getAwakenHero() != null) {
            AwakenHero awakenHero = player.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.ELIMINATE_GUARD, player.account, player.lord, awakenHero, 0);
        } else if (heroId > 0) {
            playerDataManager.addHero(player, heroId, 1, AwardFrom.ELIMINATE_GUARD);
        }
        //取消战术
        if (!army.getForm().getTactics().isEmpty()) {
            tacticsService.cancelUseTactics(player, army.getForm().getTactics());
        }
    }


    /**
     * 根据玩家当前编制等级 得到编制类型
     *
     * @param player
     * @return int
     */
    public int calcStaffing(Player player) {
        return rewardService.calcStaffing(player);
    }

    /**
     * 同步编制变更到玩家
     *
     * @param target void
     */
    public void synStaffingToPlayer(Player target) {
        if (target != null && target.isLogin) {
            GamePb3.SynStaffingRq.Builder builder = GamePb3.SynStaffingRq.newBuilder();
            builder.setStaffingLv(target.lord.getStaffingLv());
            builder.setStaffingExp(target.lord.getStaffingExp());
            builder.setStaffing(target.lord.getStaffing());
            try {
                BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb3.SynStaffingRq.EXT_FIELD_NUMBER, GamePb3.SynStaffingRq.ext, builder.build());
                GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
    }

    public Army getArmy(Player player, int key) {
        LinkedList<Army> armys = player.armys;
        for (Army army : armys) {
            if (army.getKeyId() == key) {
                return army;
            }
        }
        return null;
    }


    /**
     * 防守矿点战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private CommonPb.Report createDefMineReport(CommonPb.RptAtkMine rpt, int now) {
        CommonPb.Report.Builder report = CommonPb.Report.newBuilder();
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

    /**
     * 进攻方的tank反还(按比率)
     *
     * @param player
     * @param map
     */
    public void subTank(Player player, Map<Integer, RptTank> map) {
        Map<Integer, Tank> tanks = player.tanks;
        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            int killed;
            RptTank rptTank = it.next();
            killed = rptTank.getCount();
            int repair = (int) Math.ceil(0.9 * killed);
            Tank tank = tanks.get(rptTank.getTankId());
            if (tank == null) {
                tank = new Tank(rptTank.getTankId(), 0, 0);
                tanks.put(rptTank.getTankId(), tank);
            }
            tank.setCount(tank.getCount() + repair);
            LogLordHelper.tank(AwardFrom.CROSS_ATK_SENIOR_MINE, player.account, player.lord, tank.getTankId(), tank.getCount(), repair, repair - killed, 0);
        }
        if (map.isEmpty()) {
            LogLordHelper.tank(AwardFrom.CROSS_ATK_SENIOR_MINE, player.account, player.lord, -1, 0, 0, 0, 0);
        }
    }

    /**
     * 防守方的tank反还
     *
     * @param player
     * @param map
     * @param attForm
     */
    public void subDferTank(Player player, Map<Integer, RptTank> map, Form attForm) {
        Map<Integer, Tank> tanks = player.tanks;
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
        int killed;
        Iterator<RptTank> it = map.values().iterator();
        while (it.hasNext()) {
            RptTank rptTank = it.next();
            killed = rptTank.getCount();
            if (ratioNew > 1) {
                ratioNew = 1.0f;
            }
            int repair = (int) Math.ceil(killed * (1.0f - ratioNew));
            Tank tank = tanks.get(rptTank.getTankId());
            if (tank == null) {
                tank = new Tank(rptTank.getTankId(), 0, 0);
                tanks.put(rptTank.getTankId(), tank);
            }
            tank.setCount(tank.getCount() + repair);
            LogLordHelper.tank(AwardFrom.CROSS_ATK_SENIOR_MINE, player.account, player.lord, tank.getTankId(), tank.getCount(), repair, repair - killed, 0);
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
    }

    /**
     * 攻击矿点战报
     *
     * @param rpt
     * @param now
     * @return Report
     */
    private CommonPb.Report createAtkMineReport(CommonPb.RptAtkMine rpt, int now) {
        CommonPb.Report.Builder report = CommonPb.Report.newBuilder();
        report.setAtkMine(rpt);
        report.setTime(now);
        return report.build();
    }

    /**
     * 打矿随机掉落
     *
     * @param player
     * @param drop
     * @return Award
     */
    private CommonPb.Award mineDropOneAward(Player player, List<List<Integer>> drop) {
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

    public boolean doFight(Player attacker, ClientHandler handler, Form attackForm) {
        if (attackForm == null) {
            return false;
        }
        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (attackForm.getAwakenHero() != null) {//使用觉醒将领
            awakenHero = attacker.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return false;
            }
            attackForm.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (attackForm.getCommander() > 0) {
            hero = attacker.heros.get(attackForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return false;
            }
            heroId = hero.getHeroId();
        }
        if (heroId != 0) {
            staticHero = staticHeroDataMgr.getStaticHero(heroId);
            if (staticHero == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return false;
            }
            if (staticHero.getType() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
                return false;
            }
        }
        //战术验证
        if (!attackForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(attacker, attackForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return false;
            }
        }
        int maxTankCount = playerDataManager.formTankCount(attacker, staticHero, awakenHero);
        if (!playerDataManager.checkAndSubTank(attacker, attackForm, maxTankCount, AwardFrom.CROSS_ATK_SENIOR_MINE)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return false;
        }
        if (hero != null) {
            playerDataManager.addHero(attacker, hero.getHeroId(), -1, AwardFrom.CROSS_ATK_SENIOR_MINE);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.CROSS_ATK_SENIOR_MINE, attacker.account, attacker.lord, awakenHero, 0);
        }
        //使用战术
        if (!attackForm.getTactics().isEmpty()) {
            tacticsService.useTactics(attacker, attackForm.getTactics());
        }

        return true;
    }

    /**
     * fighter的force给到form
     *
     * @param form void
     */
    public void subForceToForm(List<Integer> list, Form form) {
        int[] c = form.c;
        for (int i = 0; i < c.length; i++) {
            int count = list.get(i);
            form.c[i] = count;
        }
    }


    /**
     * 星期一凌晨执行 ,将 采集资源加到玩家身上
     */
    public void flushArmy() {
        LogUtil.error("flushArmy cross mine ");
        long t = System.currentTimeMillis();
        Map<Long, Player> recThreeMonOnlPlayer = playerDataManager.getRecThreeMonOnlPlayer();
        for (Player player : recThreeMonOnlPlayer.values()) {
            LinkedList<Army> armys = player.armys;
            Iterator<Army> iterator = armys.iterator();
            while (iterator.hasNext()) {
                Army army = iterator.next();
                if (army.isCrossMine() && army.getState() == ArmyState.COLLECT) {
                    StaticMine staticMine = mineDataManager.getCrossSeniorMine(army.getTarget());
                    if (staticMine != null) {
                        int production = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv()).getProduction();
                        long get = calcCollect(army, TimeHelper.getCurrentSecond(), staticMine, production);
                        Grab grab = new Grab();
                        grab.rs[staticMine.getType() - 1] = get;
                        army.setGrab(grab);
                        playerDataManager.retreatEnd(player, army);
                        iterator.remove();
                    } else {
                        playerDataManager.retreatEnd(player, army);
                        iterator.remove();
                    }
                }
            }
        }
        LogUtil.error("flushArmy cross mine time ={}", System.currentTimeMillis() - t);
    }


    /**
     * 跨服军矿采集部队 结算编制经验
     */
    public void crossMineArmyStaffingLogic() {
        Map<Long, Player> recThreeMonOnlPlayer = playerDataManager.getRecThreeMonOnlPlayer();
        int now = TimeHelper.getCurrentSecond();
        for (Player player : recThreeMonOnlPlayer.values()) {
            LinkedList<Army> armys = player.armys;
            for (Army army : armys) {
                if (army.isCrossMine() && army.getState() == ArmyState.COLLECT && army.getStaffingTime() != 0 && now >= army.getStaffingTime()) {
                    addStaffing(player, army, now);
                }
            }
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
            StaticMine staticMine = mineDataManager.getCrossSeniorMine(army.getTarget());
            int exp = staticWorldDataMgr.getCrossMineLvSenior(staticMine.getLv()).getStaffingExp();
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
     * 获取作战实验室对指定属性的加成
     *
     * @param specilAttrId
     * @return 加成数值
     */
    public int getSpecilAttrAdd(Army army, int specilAttrId) {
        int attrAdd = 0;
        Map<Integer, Set<Integer>> typeMap = staticDataMgr.getSpecilSkillList(specilAttrId);
        if (typeMap == null || typeMap.isEmpty()) {
            return attrAdd;//此属性没有任何加成技能
        }
        Map<Integer, Map<Integer, Integer>> grdMap = army.getGraduateInfo();
        for (Map.Entry<Integer, Set<Integer>> entry : typeMap.entrySet()) {
            Map<Integer, Integer> sklMap = grdMap.get(entry.getKey());
            if (sklMap == null || sklMap.isEmpty()) {
                continue;//指定类型的技能集合不存在
            }
            for (Integer skillId : entry.getValue()) {
                Integer skillLv = sklMap.get(skillId);
                if (skillLv == null || skillLv == 0) {
                    continue;//技能未学习
                }
                StaticLaboratoryMilitary data = staticDataMgr.getGraduateConfig(entry.getKey(), skillId, skillLv);
                List<List<Integer>> effects = data != null ? data.getEffect() : null;
                if (effects == null || effects.isEmpty()) {
                    continue;//技能效果未配置
                }
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
        //计算军团科技载重加成
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
     * Method: calcCollect
     *
     * @Description: 计算当前部队携带的资源量 @param player @param army @param now @param staticMine @param collect @return @return
     * long @throws
     */
    public long calcCollect(Army army, int now, StaticMine staticMine, int collect) {
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
            payload = calcLoad(army);
        }
        get = get + (long) ((now - (army.getEndTime() - army.getPeriod())) / ((double) TimeHelper.HOUR_S) * collect);
        if (get > payload) {
            get = payload;
        }
        return get;
    }


}
