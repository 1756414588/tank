package com.game.service;

import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.dataMgr.StaticCrossDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.corss.CrossFameInfo;
import com.game.domain.p.corssParty.CPFameInfo;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.s.StaticHero;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.DealType;
import com.game.message.handler.InnerHandler;
import com.game.message.handler.ServerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CrossGamePb.*;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb5.SynCrossStateRq;
import com.game.pb.InnerPb.NotifyCrossOnLineRq;
import com.game.pb.SerializePb.SerCpFame;
import com.game.pb.SerializePb.SerCrossFame;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.util.*;
import com.game.warFight.domain.WarParty;
import com.google.protobuf.InvalidProtocolBufferException;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;


@Service
public class CrossService {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private ChatService chatService;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private ArenaDataManager arenaDataManager;
    @Autowired
    private StaticCrossDataMgr staticCrossDataMgr;
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private CrossDataManager crossDataManager;
    @Autowired
    private WarDataManager warDataManager;
    @Autowired
    private TacticsService tacticsService;

    /**
     * 通知cross服在线<br>
     * 去注册
     *
     * @param req
     * @param handler
     */
    public void notifyCrossOnLine(final NotifyCrossOnLineRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {

               if( GameServer.getInstance().isStop){
                   LogUtil.crossInfo("游戏服正在关闭中..拒绝连接跨服");
                   return;
               }

                LogUtil.crossInfo("通知game服去跨服注册");
                int serverId = req.getServerId();
                if (GameServer.ac.getBean(ServerSetting.class).getServerID() != serverId) {
                    LogUtil.crossInfo("配置文件中serverId为 【" + serverId + "】与本服的serverId【" + GameServer.ac.getBean(ServerSetting.class).getServerID() + "】不一致,不注册!!");
                    return;
                }
                // 跟cross服注册
                GameServer.getInstance().registerToCross(req);
                hertRequestTime = System.currentTimeMillis();
            }
        }, DealType.MAIN);
    }

    /**
     * 转发获取跨服信息给玩家
     *
     * @param rq
     * @param handler
     */
    public void getCrossServerList(CCGetCrossServerListRs rq, InnerHandler handler) {
        GetCrossServerListRs.Builder builder = GetCrossServerListRs.newBuilder();
        builder.addAllGameServerInfo(rq.getGameServerInfoList());
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        handler.sendMsgToPlayer(player, GetCrossServerListRs.ext, GetCrossServerListRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 转发跨服战状态给玩家
     *
     * @param extension
     * @param handler
     */
    public void getCrossFightState(CCGetCrossFightStateRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossFightStateRs.Builder builder = GetCrossFightStateRs.newBuilder();
        builder.setState(rq.getState());
        builder.setBeginTime(rq.getBeginTime());
        handler.sendMsgToPlayer(player, GetCrossFightStateRs.ext, GetCrossFightStateRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 转发系统消息
     *
     * @param rq
     * @param handler
     */
    public void rqSynChat(CCSynChatRq rq, InnerHandler handler) {
        LogUtil.crossInfo("接收到跨服战系统消息:" + rq.getChat().getSysId());
        // 推送系统消息到所有玩家
        chatService.sendHornChat(chatService.createSysChat(rq.getChat()), 1);
    }

    /**
     * 转发报名消息
     *
     * @param rq
     * @param ccCrossFightRegHandler
     */
    public void crossFightReg(int code, CCCrossFightRegRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        CrossFightRegRs.Builder builder = CrossFightRegRs.newBuilder();
        handler.sendMsgToPlayer(player, code, CrossFightRegRs.ext, CrossFightRegRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 转发获取报名信息
     *
     * @param extension
     * @param ccGetCrossRegInfoHandler
     */
    public void getCrossRegInfo(CCGetCrossRegInfoRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossRegInfoRs.Builder builder = GetCrossRegInfoRs.newBuilder();
        builder.setJyGroupPlayerNum(rq.getJyGroupPlayerNum());
        builder.setDfGroupPlayerNum(rq.getDfGroupPlayerNum());
        builder.setMyGroup(rq.getMyGroup());
        handler.sendMsgToPlayer(player, GetCrossRegInfoRs.ext, GetCrossRegInfoRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 转发取消报名
     *
     * @param code
     * @param extension
     * @param ccCancelCrossRegHandler
     */
    public void cancelCrossReg(int code, CCCancelCrossRegRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        CancelCrossRegRs.Builder builder = CancelCrossRegRs.newBuilder();
        handler.sendMsgToPlayer(player, code, CancelCrossRegRs.ext, CancelCrossRegRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 獲取陣型
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void getCrossForm(int code, CCGetCrossFormRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossFormRs.Builder builder = GetCrossFormRs.newBuilder();
        if (code == GameError.OK.getCode()) {
            if (rq.getFormCount() > 0) {
                builder.addAllForm(rq.getFormList());
            }
        }
        handler.sendMsgToPlayer(player, code, GetCrossFormRs.ext, GetCrossFormRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 设置跨服战阵型
     *
     * @param rq
     * @param handler
     */
    public void setCrossForm(SetCrossFormRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        CommonPb.Form form = rq.getForm();
        List<Integer> tacticsKeyIdList = form.getTacticsKeyIdList();
        if (!tacticsKeyIdList.isEmpty()) {
            CommonPb.Form.Builder builder1 = form.toBuilder();
            List<Tactics> tactics = tacticsService.getPlayerTactics(player, tacticsKeyIdList);
            for (Tactics t : tactics) {
                builder1.addTactics(PbHelper.createTwoIntPb(t.getTacticsId(), t.getLv()));
            }
            form = builder1.build();
        }
        CCSetCrossFormRq.Builder builder = CCSetCrossFormRq.newBuilder();
        builder.setRoleId(player.lord.getLordId());
        builder.setForm(form);
        builder.setFight(rq.getFight());
        for (Map.Entry<Integer, Tank> entry : player.tanks.entrySet()) {
            builder.addTank(PbHelper.createTankPb(entry.getValue()));
        }
        Iterator<Hero> it = player.heros.values().iterator();
        while (it.hasNext()) {
            Hero next = it.next();
            if (next.getCount() <= 0) {
                continue;
            }
            builder.addHero(PbHelper.createHeroPb(next));
        }
        StaticHero staticHero = null;
        AwakenHero awakenHero = null;
        if (rq.getForm().hasAwakenHero()) { //使用觉醒将领
            awakenHero = player.awakenHeros.get(rq.getForm().getAwakenHero().getKeyId());
            if (awakenHero != null && !awakenHero.isUsed()) {
                staticHero = staticHeroDataMgr.getStaticHero(awakenHero.getHeroId());
            }
        } else {
            if (rq.getForm().getCommander() > 0) {
                staticHero = staticHeroDataMgr.getStaticHero(rq.getForm().getCommander());
            }
        }
        builder.setMaxTankNum(playerDataManager.formTankCount(player, staticHero, awakenHero));
        // 装备
        for (int i = 0; i < 7; i++) {
            Map<Integer, Equip> equipMap = player.equips.get(i);
            Iterator<Equip> itEquip = equipMap.values().iterator();
            while (itEquip.hasNext()) {
                builder.addEquip(PbHelper.createEquipPb(itEquip.next()));
            }
        }
        // 配件
        for (int i = 0; i < 5; i++) {
            Map<Integer, Part> map = player.parts.get(i);
            Iterator<Part> itPart = map.values().iterator();
            while (itPart.hasNext()) {
                builder.addPart(PbHelper.createPartPb(itPart.next()));
            }
        }
        // 科技
        Iterator<Science> itScience = player.sciences.values().iterator();
        while (itScience.hasNext()) {
            builder.addScience(PbHelper.createSciencePb(itScience.next()));
        }
        // effect
        Iterator<Effect> itEffect = player.effects.values().iterator();
        while (itEffect.hasNext()) {
            builder.addEffect(PbHelper.createEffectPb(itEffect.next()));
        }
        // staffingId
        builder.setStaffingId(player.lord.getStaffing());
        // 军工科技
        Collection<Map<Integer, MilitaryScienceGrid>> c = player.militaryScienceGrids.values();
        for (Map<Integer, MilitaryScienceGrid> hashMap : c) {
            Iterator<MilitaryScienceGrid> itmg = hashMap.values().iterator();
            while (itmg.hasNext()) {
                builder.addMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(itmg.next()));
            }
        }
        Iterator<MilitaryScience> itms = player.militarySciences.values().iterator();
        while (itms.hasNext()) {
            builder.addMilitaryScience(PbHelper.createMilitaryScienecePb(itms.next()));
        }
        // 能晶
        for (int pos = 1; pos <= 6; pos++) {
            Map<Integer, EnergyStoneInlay> stoneMap = player.energyInlay.get(pos);
            if (!CheckNull.isEmpty(stoneMap)) {
                for (EnergyStoneInlay inlay : stoneMap.values()) {
                    builder.addInlay(PbHelper.createEnergyStoneInlayPb(inlay));
                }
            }
        }
        // 勋章
        for (Map<Integer, Medal> map : player.medals.values()) {
            Iterator<Medal> itmedls = map.values().iterator();
            while (itmedls.hasNext()) {
                builder.addMedal(PbHelper.createMedalPb(itmedls.next()));
            }
        }
        // 勋章展厅
        for (Map<Integer, MedalBouns> map : player.medalBounss.values()) {
            Iterator<MedalBouns> itmedls = map.values().iterator();
            while (itmedls.hasNext()) {
                builder.addMedalBouns(PbHelper.createMedalBounsPb(itmedls.next()));
            }
        }
        //觉醒将领
        for (AwakenHero hero : player.awakenHeros.values()) {
            builder.addAwakenHero(PbHelper.createAwakenHeroPb(hero));
        }
        //军备列表
        if (!player.leqInfo.getPutonLordEquips().isEmpty()) {
            for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getPutonLordEquips().entrySet()) {
                builder.addLeq(PbHelper.createLordEquip(entry.getValue()));
            }
        }
        //军衔
        builder.setMilitaryRank(player.lord.getMilitaryRank());
        //秘密武器
        if (!player.secretWeaponMap.isEmpty()) {
            for (Map.Entry<Integer, SecretWeapon> entry : player.secretWeaponMap.entrySet()) {
                builder.addSecretWeapon(PbHelper.createSecretWeapon(entry.getValue()));
            }
        }
        //攻击特效
        if (!player.atkEffects.isEmpty()) {
            for (Map.Entry<Integer, AttackEffect> entry : player.atkEffects.entrySet()) {
                builder.addAtkEft(PbHelper.createAttackEffectPb(entry.getValue()));
            }
        }
        //作战实验室
        if (!player.labInfo.getGraduateInfo().isEmpty()) {
            List<CommonPb.GraduateInfoPb> list = PbHelper.createGraduateInfoPb(player.labInfo.getGraduateInfo());
            if (!list.isEmpty()) {
                builder.addAllGraduateInfo(list);
            }
        }
        //玩家军团科技列表
        if (partyDataManager.getScience(player) != null && !partyDataManager.getScience(player).isEmpty()) {
            Iterator<PartyScience> psIt = partyDataManager.getScience(player).values().iterator();
            while (psIt.hasNext()) {
                builder.addPartyScience(PbHelper.createPartySciencePb(psIt.next()));
            }
        }
        //技能
        if (!player.skills.isEmpty()) {
            for (Map.Entry<Integer, Integer> entry : player.skills.entrySet()) {
                builder.addSkill(PbHelper.createSkillPb(entry.getKey(), entry.getValue()));
            }
        }
        PEnergyCore energyCore = player.energyCore;
        if (energyCore != null){
            builder.setEnergyCore(PbHelper.createThreeIntPb(energyCore.getLevel(), energyCore.getSection(), energyCore.getState()));
        }
        handler.sendMsgToCrossServer(CCSetCrossFormRq.EXT_FIELD_NUMBER, CCSetCrossFormRq.ext, builder.build());
    }

    /***
     * 设置阵型
     *
     * @param rq
     * @param handler
     */
    public void setCrossForm(int code, CCSetCrossFormRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        if (player != null) {
            SetCrossFormRs.Builder builder = SetCrossFormRs.newBuilder();
            builder.setFight(rq.getFight());
            builder.setForm(rq.getForm());
            handler.sendMsgToPlayer(player, code, SetCrossFormRs.ext, SetCrossFormRs.EXT_FIELD_NUMBER, builder.build());
        }
    }

    /**
     * 获取个人战况
     *
     * @param rq
     * @param handler
     */
    public void getCrossPersonSituation(CCGetCrossPersonSituationRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossPersonSituationRs.Builder builder = GetCrossPersonSituationRs.newBuilder();
        builder.addAllCrossRecord(rq.getCrossRecordList());
        handler.sendMsgToPlayer(player, GetCrossPersonSituationRs.ext, GetCrossPersonSituationRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取积分排名
     *
     * @param extension
     * @param ccGetCrossJiFenRankHandler
     */
    public void getCrossJiFenRank(CCGetCrossJiFenRankRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossJiFenRankRs.Builder builder = GetCrossJiFenRankRs.newBuilder();
        builder.addAllCrossJiFenRank(rq.getCrossJiFenRankList());
        builder.setJifen(rq.getJifen());
        builder.setMyRank(rq.getMyRank());
        handler.sendMsgToPlayer(player, GetCrossJiFenRankRs.ext, GetCrossJiFenRankRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取战报
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void getCrossReport(int code, CCGetCrossReportRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossReportRs.Builder builder = GetCrossReportRs.newBuilder();
        if (code == GameError.OK.getCode()) {
            builder.setCrossRptAtk(rq.getCrossRptAtk());
        }
        handler.sendMsgToPlayer(player, code, GetCrossReportRs.ext, GetCrossReportRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取淘汰赛信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossKnockCompetInfo(CCGetCrossKnockCompetInfoRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossKnockCompetInfoRs.Builder builder = GetCrossKnockCompetInfoRs.newBuilder();
        builder.setGroupId(rq.getGroupId());
        builder.setGroupType(rq.getGroupType());
        builder.addAllKnockoutCompetGroup(rq.getKnockoutCompetGroupList());
        handler.sendMsgToPlayer(player, GetCrossKnockCompetInfoRs.ext, GetCrossKnockCompetInfoRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取总决赛信息
     *
     * @param
     * @param
     */
    public void getCrossFinalCompetInfo(CCGetCrossFinalCompetInfoRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossFinalCompetInfoRs.Builder builder = GetCrossFinalCompetInfoRs.newBuilder();
        builder.setGroupId(rq.getGroupId());
        builder.addAllFinalCompetGroup(rq.getFinalCompetGroupList());
        handler.sendMsgToPlayer(player, GetCrossFinalCompetInfoRs.ext, GetCrossFinalCompetInfoRs.EXT_FIELD_NUMBER, builder.build());
    }

    public Player getPlayer(long roleId) {
        return playerDataManager.getPlayer(roleId);
    }

    public Arena getArena(long roldId) {
        return arenaDataManager.getArena(roldId);
    }

    public Arena getLastArena(int lastRank) {
        return arenaDataManager.getArenaByLastRank(lastRank);
    }

    /**
     * 玩家军团名
     *
     * @param roldId
     * @return String
     */
    public String getParyName(long roldId) {
        String ret = null;
        Member member = partyDataManager.getMemberById(roldId);
        if (member != null && member.getPartyId() > 0) {
            int partyId = member.getPartyId();
            PartyData partyData = partyDataManager.getParty(partyId);
            if (partyData != null) {
                ret = partyData.getPartyName();
            }
        }
        return ret;
    }

    /**
     * 获取跨服战我的下注
     *
     * @param getMyBetHandler
     */
    public void getMyBet(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        CCGetMyBetRq.Builder builder = CCGetMyBetRq.newBuilder();
        builder.setRoleId(player.lord.getLordId());
        handler.sendMsgToCrossServer(CCGetMyBetRq.EXT_FIELD_NUMBER, CCGetMyBetRq.ext, builder.build());
    }

    /**
     * 下注
     *
     * @param rq
     * @param handler
     */
    public void betBattle(BetBattleRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (rq.getStage() == CrossConst.Final_Session) {
            handler.sendErrorMsgToPlayer(GameError.CROSS_FINAL_NO_BET);
            return;
        }
        CCBetBattleRq.Builder builder = CCBetBattleRq.newBuilder();
        builder.setRoleId(player.lord.getLordId());
        builder.setMyGroup(rq.getMyGroup());
        builder.setStage(rq.getStage());
        builder.setGroupType(rq.getGroupType());
        builder.setCompetGroupId(rq.getCompetGroupId());
        builder.setPos(rq.getPos());
        handler.sendMsgToCrossServer(CCBetBattleRq.EXT_FIELD_NUMBER, CCBetBattleRq.ext, builder.build());
    }

    /**
     * 转发报名信息 若有错误还需要回退
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void betBattle(int code, CCBetBattleRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        BetBattleRs.Builder builder = BetBattleRs.newBuilder();
        GameError ret = GameError.OK;
        com.game.pb.CommonPb.MyBet pbMyBet = rq.getMyBet();
        int pos = rq.getPos();
        int myGroup = pbMyBet.getMyGroup();
        int stage = pbMyBet.getStage();
        int groupType = pbMyBet.getGroupType();
        int competGroupId = pbMyBet.getCompetGroupId();
        CommonPb.ComptePojo pbCp1 = pbMyBet.getC1();
        CommonPb.ComptePojo pbCp2 = pbMyBet.getC2();
        int win = pbMyBet.getWin();
        int betState = pbMyBet.getBetState();
        if (code == GameError.OK.getCode()) {
            if (pos == 1) {
                ret = checkAndBet(player, pbCp1.getMyBetNum());
                LogLordHelper.crossBattle(AwardFrom.CROSS_BATTLE, player.account, player.lord, pbCp1.getServerId(), pbCp1.getNick(), pbCp1.getRoleId(), myGroup + "", pbCp2.getServerName(), (ret.getCode() != GameError.OK.getCode() ? 0 : 1));
            } else {
                ret = checkAndBet(player, pbCp2.getMyBetNum());
                LogLordHelper.crossBattle(AwardFrom.CROSS_BATTLE, player.account, player.lord, pbCp2.getServerId(), pbCp2.getNick(), pbCp2.getRoleId(), myGroup + "", pbCp2.getServerName(), (ret.getCode() != GameError.OK.getCode() ? 0 : 1));
            }
            if (ret.getCode() != GameError.OK.getCode()) {
                // 通知跨服回滚
                CCBetRollBackRq.Builder ccBetRollBackRq = CCBetRollBackRq.newBuilder();
                ccBetRollBackRq.setRoleId(rq.getRoleId());
                ccBetRollBackRq.setMyGroup(myGroup);
                ccBetRollBackRq.setStage(stage);
                ccBetRollBackRq.setGroupType(groupType);
                ccBetRollBackRq.setCompetGroupId(competGroupId);
                ccBetRollBackRq.setPos(pos);
                handler.sendMsgToCrossServer(CCBetRollBackRq.EXT_FIELD_NUMBER, CCBetRollBackRq.ext, ccBetRollBackRq.build());
                code = ret.getCode();
            }
            builder.setMyBet(pbMyBet);
        }
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(player, code, BetBattleRs.ext, BetBattleRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 判断够不够 扣除金钱
     *
     * @param player
     * @param nowBetNum
     * @return GameError
     */
    private GameError checkAndBet(Player player, int nowBetNum) {
        GameError ret = GameError.OK;
        int cost = staticCrossDataMgr.getServerWarBettingMap().get(nowBetNum).getCost();
        if (player.lord.getGold() < cost) {
            return GameError.GOLD_NOT_ENOUGH;
        }
        // 支付失败
        if (!playerDataManager.subGoldCross(player, cost, AwardFrom.CROSS_BET)) {
            return GameError.GOLD_NOT_ENOUGH;
        }
        return ret;
    }

    /**
     * 转发
     *
     * @param rq
     * @param handler
     */
    public void getMyBet(CCGetMyBetRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetMyBetRs.Builder builder = GetMyBetRs.newBuilder();
        builder.addAllMyBet(rq.getMyBetsList());
        handler.sendMsgToPlayer(player, GetMyBetRs.ext, GetMyBetRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 领取积分
     *
     * @param rq
     * @param handler
     */
    public void receiveBet(int code, CCReceiveBetRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        ReceiveBetRs.Builder builder = ReceiveBetRs.newBuilder();
        if (code == GameError.OK.getCode()) {
            builder.setCrossJifen(rq.getJifen());
            builder.setMyBet(rq.getMyBet());
        }
        handler.sendMsgToPlayer(player, code, ReceiveBetRs.ext, ReceiveBetRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取跨服战商店数据
     *
     * @param code
     * @param rs
     * @param handler
     */
    public void getCrossShop(int code, CCGetCrossShopRs rs, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rs.getRoleId());
        GetCrossShopRs.Builder builder = GetCrossShopRs.newBuilder();
        builder.setCrossJifen(rs.getCrossJifen());
        if (code != GameError.OK.getCode()) {
            handler.sendMsgToPlayer(player, code, GetCrossShopRs.ext, GetCrossShopRs.EXT_FIELD_NUMBER, builder.build());
        } else {
            builder.addAllBuy(rs.getBuyList());
            handler.sendMsgToPlayer(player, GetCrossShopRs.ext, GetCrossShopRs.EXT_FIELD_NUMBER, builder.build());
        }
    }

    /**
     * 兑换跨服战商店的物品
     *
     * @param code
     * @param rs
     * @param handler
     */
    public void exchangeCrossShop(int code, CCExchangeCrossShopRs rs, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rs.getRoleId());
        ExchangeCrossShopRs.Builder builder = ExchangeCrossShopRs.newBuilder();
        builder.setCrossJifen(rs.getCrossJifen());
        builder.setShopId(rs.getShopId());
        if (code != GameError.OK.getCode()) {
            handler.sendMsgToPlayer(player, code, ExchangeCrossShopRs.ext, ExchangeCrossShopRs.EXT_FIELD_NUMBER, builder.build());
        } else {
            StaticCrossShop shop = staticCrossDataMgr.getStaticCrossShopById(rs.getShopId());
            playerDataManager.addAward(player, shop.getRewardList().get(0).get(0), shop.getRewardList().get(0).get(1), shop.getRewardList().get(0).get(2) * rs.getCount(), AwardFrom.CROSS_JIFEN_EXCHANGE);
            builder.setCount(rs.getCount());
            builder.setCount(rs.getRestNum());
            handler.sendMsgToPlayer(player, ExchangeCrossShopRs.ext, ExchangeCrossShopRs.EXT_FIELD_NUMBER, builder.build());
        }
    }

    private long hertTime = 0l;
    /**
     * 心跳返回时间
     */
    public static long hertRequestTime = 0l;

    /**
     * 心跳
     */
    public void heartRq() {


        long currentTime = System.currentTimeMillis();
        if (Math.abs(currentTime - hertTime) > 20000) {
            hertTime = currentTime;
            if (!isCrossAive()) {

                //连接无效 但是跨服连接还开着 就主动关闭
                if (GameServer.getInstance().innerServer != null && (GameServer.getInstance().innerServer.innerCtx != null)) {
                    LogUtil.crossInfo("[跨服战或者跨服军团战] 连接无效 但是跨服连接还开着 就主动关闭");
                    GameServer.getInstance().closeCross();
                }
                return;
            }


            try {
                if (hertRequestTime == 0) {
                    hertRequestTime = System.currentTimeMillis();
                }
                //说明跨服没有回复心跳 说明跨服死了
                long ltime = System.currentTimeMillis() - hertRequestTime;
                if (Math.abs(ltime) > 180000) {
                    hertRequestTime = System.currentTimeMillis();
                    LogUtil.crossInfo("[跨服战或者跨服军团战] 跨服已经有3分钟时间没有回复心跳 " + (ltime / 1000) + " s");
                    GameServer.getInstance().closeCross();
                    LogUtil.crossInfo("[跨服战或者跨服军团战] 跨服已经很久没有回复心跳了 自动关闭跨服入口");
                    return;
                }


                LogUtil.crossInfo("[跨服战或者跨服军团战] 向跨服发送心跳");
                CCHeartRq.Builder builder = CCHeartRq.newBuilder();
                builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
                Base.Builder baseBuilder = PbHelper.createRqBase(CCHeartRq.EXT_FIELD_NUMBER, null, CCHeartRq.ext, builder.build());
                GameServer.getInstance().sendMsgToCross(baseBuilder);

            } catch (BeansException e) {
                LogUtil.error(e);
            }
        }


    }

    /**
     * 是否和跨服服连接状态
     *
     * @return boolean
     */
    private boolean isCrossAive() {
        return GameServer.getInstance().innerServer != null && (GameServer.getInstance().innerServer.innerCtx != null) && (GameServer.getInstance().innerServer.innerCtx.channel().isActive());
    }

    /**
     * 获取总排名
     *
     * @param rs
     * @param handler
     */
    public void getCrossFinalRank(CCGetCrossFinalRankRs rs, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rs.getRoleId());
        GetCrossFinalRankRs.Builder builder = GetCrossFinalRankRs.newBuilder();
        builder.setGroup(rs.getGroup());
        builder.addAllCrossTopRank(rs.getCrossTopRankList());
        builder.setMyRank(rs.getMyRank());
        builder.setState(rs.getState());
        builder.setMyJiFen(rs.getMyJiFen());
        handler.sendMsgToPlayer(player, GetCrossFinalRankRs.ext, GetCrossFinalRankRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 领取跨服战排名奖励
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void receiveRankRward(int code, CCReceiveRankRwardRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        ReceiveRankRwardRs.Builder builder = ReceiveRankRwardRs.newBuilder();
        builder.setGroup(rq.getGroup());
        if (code == GameError.OK.getCode()) {
            int rank = rq.getRank();
            List<List<Integer>> awards = null;
            if (rq.getGroup() == CrossConst.DF_Group) {
                awards = staticWarAwardDataMgr.getTopServerRankAwards(rank);
            } else {
                awards = staticWarAwardDataMgr.getEliteServerRankAwards(rank);
            }
            builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.CROSS_RANK_AWARD));
        }
        handler.sendMsgToPlayer(player, code, ReceiveRankRwardRs.ext, ReceiveRankRwardRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 邮件处理
     *
     * @param extension
     * @param handler
     */
    public void rqSynMail(CCSynMailRq rq, InnerHandler handler) {
        int moldId = rq.getMoldId();
        String strs[] = null;
        if (rq.getParamCount() > 0) {
            strs = new String[rq.getParamCount()];
            for (int i = 0; i < rq.getParamCount(); i++) {
                strs[i] = rq.getParamList().get(i);
            }
        }
        LogUtil.crossInfo("收到跨服战邮件:" + moldId);
        switch (moldId) {
            case MailType.MOLD_CROSS_PLAN:
                sendAllPlayerNormalMail(moldId, TimeHelper.getCurrentSecond(), 50, strs);
                break;
            case MailType.MOLD_CROSS_REG:
                sendTop100NormalMail(moldId, TimeHelper.getCurrentSecond(), 50, strs);
                break;
            case MailType.MOLD_JIFEN_PLAN:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_KNOCK_PLAN:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_KNOCK_BET:
                sendAllPlayerNormalMail(moldId, TimeHelper.getCurrentSecond(), 50, strs);
                break;
            case MailType.MOLD_FINAL_PLAN:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_GET_SECEND:
            case MailType.MOLD_GET_THRID:
            case MailType.MOLD_GET_FIRST:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_THRID_FIGHT:
            case MailType.MOLD_FIRST_FIGHT:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_KNOCK_OUT:
            case MailType.MOLD_FINAL_OUT:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_JIFEN_GET:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_TOP_SERVER_REWARD:
            case MailType.MOLD_TOP2_SERVER_REWARD:
            case MailType.MOLD_TOP3_SERVER_REWARD:
                sendTopServerReward(moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            // 跨服军团战
            case MailType.MOLD_CP_104:
                // 给所有玩家发
                sendAllPlayerNormalMail(moldId, TimeHelper.getCurrentSecond(), 0, strs);
                break;
            case MailType.MOLD_CP_105:
                // 给军团战前三名的军团发
                sendPartyTop3NorMalMail(moldId);
                break;
            case MailType.MOLD_CP_106:
            case MailType.MOLD_CP_107:
                // 个人发
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_CP_108:
            case MailType.MOLD_CP_110:
            case MailType.MOLD_CP_111:
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_CP_109:
                // 个人发
                sendRoleNormalMail(rq.getRoleId(), moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_CP_112:
            case MailType.MOLD_CP_113:
            case MailType.MOLD_CP_114:
                // 冠亚季军团所在服奖励
                sendCPTopServerReward(moldId, TimeHelper.getCurrentSecond(), strs);
                break;
            case MailType.MOLD_CP_115:
                // 给跨服排名军团发奖励
                sendCPPartyRankReward(strs);
                break;
            default:
                break;
        }
    }

    /**
     * 发送跨服军团军事福利
     *
     * @param strs void
     */
    private void sendCPPartyRankReward(String[] strs) {
        int partyId = Integer.parseInt(strs[0]);
        int rank = Integer.parseInt(strs[1]);
        List<List<Integer>> awards = staticWarAwardDataMgr.getServerPartyRankAward(rank);
        List<Prop> props = new ArrayList<Prop>();
        for (List<Integer> prop : awards) {
            props.add(new Prop(prop.get(1), prop.get(2)));
        }
        // 发送福利到军团福利院
        partyDataManager.addAmyProps(partyId, props);
        partyDataManager.addPartyTrend(partyId, 23, String.valueOf(rank));
        LogUtil.crossInfo("发送跨服军团军事福利:" + partyId + "|" + " get rank:" + rank);
    }

    /**
     * 发送全服奖励邮件
     *
     * @param moldId
     * @param currentSecond
     * @param strs          void
     */
    private void sendCPTopServerReward(int moldId, int currentSecond, String[] strs) {
        LogUtil.crossInfo("发送全服奖励邮件:" + moldId + ":" + strs);
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        String partyName = strs[0];
        int rank = Integer.parseInt(strs[1]);
        List<List<Integer>> awardList = null;
        awardList = staticWarAwardDataMgr.getServerPartyAllAward(rank);
        List<CommonPb.Award> awards = PbHelper.createAwardsPb(awardList);
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            playerDataManager.sendAttachMail(AwardFrom.CROSS_TOP_SERVER_REWARD, player, awards, moldId, currentSecond, partyName, rank + "");
        }
    }

    // 给军团战前三名的军团发
    private void sendPartyTop3NorMalMail(int moldId) {
        for (int i = 1; i <= 3; i++) {
            try {
                WarParty warParty = warDataManager.getRankMap().get(i);
                List<Member> list = partyDataManager.getMemberList(warParty.getPartyData().getPartyId());
                for (Member m : list) {
                    sendRoleNormalMail(m.getLordId(), moldId, TimeHelper.getCurrentSecond());
                }
            } catch (Exception e) {
                LogHelper.GAME_LOGGER.error(e);
            }
        }
    }

    /**
     * 发送全服奖励邮件
     *
     * @param moldId
     * @param currentSecond
     */
    private void sendTopServerReward(int moldId, int currentSecond, String... strs) {
        LogUtil.crossInfo("发送全服奖励邮件:" + moldId + ":" + strs);
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        String nick = strs[0];
        int group = Integer.parseInt(strs[1]);
        int rank = 1;
        if (moldId == MailType.MOLD_TOP_SERVER_REWARD) {
            rank = 1;
        } else if (moldId == MailType.MOLD_TOP2_SERVER_REWARD) {
            rank = 2;
        } else if (moldId == MailType.MOLD_TOP3_SERVER_REWARD) {
            rank = 3;
        }
        List<List<Integer>> awardList = null;
        if (group == CrossConst.DF_Group) {
            awardList = staticWarAwardDataMgr.getTopAllAwards(rank);
        } else {
            awardList = staticWarAwardDataMgr.getEliteAllAwards(rank);
        }
        List<CommonPb.Award> awards = PbHelper.createAwardsPb(awardList);
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            playerDataManager.sendAttachMail(AwardFrom.CROSS_TOP_SERVER_REWARD, player, awards, moldId, currentSecond, nick, isDForJyGroup(group));
        }
    }

    private String isDForJyGroup(int whichGroup) {
        String str = CrossConst.DF_DESC;
        if (whichGroup == CrossConst.JY_Group) {
            str = CrossConst.JY_DESC;
        }
        return str;
    }

    /**
     * @param moldId
     * @param now
     * @param limitLevel 限制等级 如果0则不限制
     * @param params
     */
    public void sendAllPlayerNormalMail(int moldId, int now, int limitLevel, String... params) {
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            if (limitLevel > 0 && player.lord.getLevel() < limitLevel) {
                continue;
            }
            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), params);
        }
    }

    /**
     * 给指定的玩家发邮件
     *
     * @param moldId
     * @param now
     * @param params
     */
    public void sendRoleNormalMail(Long role, int moldId, int now, String... params) {
        if (role != null) {
            Player player = playerDataManager.getPlayer(role);
            playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), params);
        }
    }

    /**
     * 给竞技场前100名发邮件
     *
     * @param moldId
     * @param now
     * @param params
     */
    public void sendTop100NormalMail(int moldId, int now, int limitLevel, String... params) {
        for (int i = 1; i <= 100; i++) {
            Arena a = getLastArena(i);
            if (a != null) {
                Player player = playerDataManager.getPlayer(a.getLordId());
                if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                    continue;
                }
                if (limitLevel > 0 && player.lord.getLevel() < limitLevel) {
                    continue;
                }
                playerDataManager.sendNormalMail(player, moldId, TimeHelper.getCurrentSecond(), params);
            }
        }
    }

    /**
     * 获取积分详情
     *
     * @param extension
     * @param ccGetCrossTrendHanlder
     */
    public void getCrossTrend(CCGetCrossTrendRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossTrendRs.Builder builder = GetCrossTrendRs.newBuilder();
        builder.setCrossJifen(rq.getCrossJifen());
        builder.addAllCrossTrend(rq.getCrossTrendList());
        handler.sendMsgToPlayer(player, GetCrossTrendRs.ext, GetCrossTrendRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 同步跨服战状态
     *
     * @param rq
     * @param handler
     */
    public void rqSynCrossState(CCSynCrossStateRq rq, InnerHandler handler) {
        synCrossState(rq.getState());
    }

    private void synCrossState(int state) {
        SynCrossStateRq.Builder builder = SynCrossStateRq.newBuilder();
        builder.setState(state);
        SynCrossStateRq req = builder.build();
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            playerDataManager.synCrossStateToPlayer(player, req);
        }
    }

    /**
     * gm报名跨服战
     *
     * @param id
     * @param count
     * @param parseInt
     */
    public void gmCrossReg(int group, int beginRank, int endRank) {
        for (int i = beginRank; i <= endRank; i++) {
            Arena a = arenaDataManager.getArenaByLastRank(i);
            if (a != null) {
                Player player = playerDataManager.getPlayer(a.getLordId());
                if (player.lord.getLevel() < Constant.CROSS_REG_LEVEL) continue;
                CCCrossFightRegRq.Builder builder = CCCrossFightRegRq.newBuilder();
                builder.setRoleId(player.lord.getLordId());
                builder.setGroupId(group);
                builder.setRankId(a.getLastRank());
                builder.setFight(player.lord.getFight());
                builder.setNick(player.lord.getNick());
                builder.setPortrait(player.lord.getPortrait());
                builder.setLevel(player.lord.getLevel());
                String partyName = getParyName(player.lord.getLordId());
                if (partyName != null) {
                    builder.setPartyName(partyName);
                }
                Base.Builder baseBuilder = PbHelper.createRqBase(CCCrossFightRegRq.EXT_FIELD_NUMBER, null, CCCrossFightRegRq.ext, builder.build());
                GameServer.getInstance().sendMsgToCross(baseBuilder);
            }
        }
    }

    /**
     * gm设置阵型
     *
     * @param fromNum
     */
    public void gmSetCrossFrom(int formNum) {
        CCGMSetCrossFormRq.Builder builder = CCGMSetCrossFormRq.newBuilder();
        builder.setFormNum(formNum);
        Base.Builder baseBuilder = PbHelper.createRqBase(CCGMSetCrossFormRq.EXT_FIELD_NUMBER, null, CCGMSetCrossFormRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }

    /**
     * 通知跨服服务器同步最后一次数据过来
     */
    public void gmSynCrossLashRank(int type) {
        CCGmSynCrossLashRankRq.Builder builder = CCGmSynCrossLashRankRq.newBuilder();
        builder.setType(type);
        Base.Builder baseBuilder = PbHelper.createRqBase(CCGmSynCrossLashRankRq.EXT_FIELD_NUMBER, null, CCGmSynCrossLashRankRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }

    /**
     * 清除本地脏数据
     */
    public void gmClearAllCrossForm() {
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            player.forms.remove(FormType.Cross1);
            player.forms.remove(FormType.Cross2);
            player.forms.remove(FormType.Cross3);
        }
    }

    /**
     * 跨服战排名
     *
     * @param rq
     * @param clientHanlder
     */
    public void getCrossRank(GetCrossRankRq rq, ClientHandler handler) {
        int type = 1;
        if (rq.hasType()) {
            type = rq.getType();
        }
        GetCrossRankRs.Builder builder = GetCrossRankRs.newBuilder();
        int rank = 1;
        if (type == 1) {
            Iterator<CrossFameInfo> its = crossDataManager.getCrossFameInfos().iterator();
            while (its.hasNext()) {
                builder.addCrossFameInfo(PbHelper.createCrossFameInfoPb(its.next(), rank));
                rank++;
            }
        } else if (type == 2) {
            Iterator<CPFameInfo> its = crossDataManager.getCpFameInfos().iterator();
            while (its.hasNext()) {
                builder.addCpFameInfo(PbHelper.createCPFameInfoPb(its.next(), rank));
                rank++;
            }
        }
        handler.sendMsgToPlayer(GetCrossRankRs.ext, builder.build());
    }

    /**
     * 同步跨服排名信息
     *
     * @param rq
     * @param handler
     */
    public void rqSynCrossFame(CCSynCrossFameRq rq, InnerHandler handler) {
        String beginTime = rq.getBeginTime();
        String endTime = rq.getEndTime();
        int type = 1;
        if (rq.hasType()) {
            type = rq.getType();
        }
        try {
            if (type == 1) {
                SerCrossFame.Builder builder = SerCrossFame.newBuilder();
                builder.addAllCrossFame(rq.getCrossFameList());
                crossDataManager.addCrossFrame(beginTime, endTime, builder.build().toByteArray());
            } else if (type == 2) {
                SerCpFame.Builder builder = SerCpFame.newBuilder();
                builder.addAllCpFame(rq.getCpFameList());
                crossDataManager.addCpFrame(beginTime, endTime, builder.build().toByteArray());
            }
        } catch (InvalidProtocolBufferException e) {
            e.printStackTrace();
            LogUtil.crossInfo("同步跨服排名信息失败:" + e.getMessage());
        }
    }

    //gm增加跨服战积分
    public void gmAddCCJiFen(long lordId, int addJifen, int ccType) {
        CCGMAddJiFenRq.Builder builder = CCGMAddJiFenRq.newBuilder();
        builder.setRoleId(lordId);
        builder.setAddJifen(addJifen);
        builder.setCcType(ccType);
        Base.Builder baseBuilder = PbHelper.createRqBase(CCGMAddJiFenRq.EXT_FIELD_NUMBER, null, CCGMAddJiFenRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }
}