package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticCrossDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.MedalBouns;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.s.StaticHero;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.WarDataManager;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.InnerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CrossGamePb.*;
import com.game.pb.GamePb6.*;
import com.game.server.GameServer;
import com.game.util.CheckNull;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import com.game.warFight.domain.WarParty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 跨服军团 @ClassName: CrossPartyService @Description: TODO
 *
 * @author
 */
@Service
public class CrossPartyService {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private StaticCrossDataMgr staticCrossDataMgr;
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private WarDataManager warDataManager;

    /**
     * 获取跨服军团的状态
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyState(CCGetCrossPartyStateRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());

        GetCrossPartyStateRs.Builder builder = GetCrossPartyStateRs.newBuilder();
        builder.setState(rq.getState());
        builder.setBeginTime(rq.getBeginTime());

        handler.sendMsgToPlayer(
                player, GetCrossPartyStateRs.ext, GetCrossPartyStateRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取服务器列表
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyServerList(CCGetCrossPartyServerListRs rq, InnerHandler handler) {
        GetCrossPartyServerListRs.Builder builder = GetCrossPartyServerListRs.newBuilder();
        builder.addAllGameServerInfo(rq.getGameServerInfoList());

        Player player = playerDataManager.getPlayer(rq.getRoleId());

        handler.sendMsgToPlayer(
                player,
                GetCrossPartyServerListRs.ext,
                GetCrossPartyServerListRs.EXT_FIELD_NUMBER,
                builder.build());
    }

    /**
     * 跨服军团报名
     *
     * @param rq
     */
    public void crossPartyReg(CrossPartyRegRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
            return;
        }
        int enterTime = member.getEnterTime();
        if (enterTime == TimeHelper.getCurrentDay()) {
            handler.sendErrorMsgToPlayer(GameError.IN_PARTY_TIME);
            return;
        }

        int level = player.lord.getLevel();
        int warRank = 0;
        int partyId = 0;
        String partyName = "";
        int partyLv = 0;
        int mPortrait = player.lord.getPortrait();
        int myPartySirPortrait = 0;

        CCCrossPartyRegRq.Builder builder = CCCrossPartyRegRq.newBuilder();
        builder.setRoleId(handler.getRoleId());

        // 排名
        partyId = member.getPartyId();
        PartyData partyData = partyDataManager.getParty(partyId);
        partyLv = partyData.getPartyLv();
        warRank = partyData.getWarRank();
        partyName = partyData.getPartyName();

        // 获取军团长的名字
        String legatusName = partyData.getLegatusName();
        Player p = playerDataManager.getPlayer(legatusName);
        if (p != null) {
            myPartySirPortrait = p.lord.getPortrait();
        }

        builder.setNick(player.lord.getNick());
        builder.setLevel(level);
        builder.setWarRank(warRank);
        builder.setPartyId(partyId);
        builder.setPartyName(partyName);
        builder.setPartyLv(partyLv);

        // 我的头像
        builder.setPortrait(mPortrait);
        // 军团长的头像
        builder.setMyPartySirPortrait(myPartySirPortrait);

        handler.sendMsgToCrossServer(
                CCCrossPartyRegRq.EXT_FIELD_NUMBER, CCCrossPartyRegRq.ext, builder.build());
    }

    /**
     * gm报名前十的军团
     */
    public void gmCrossPartyReg(ClientHandler handler) {

        Map<Integer, PartyData> parMap = partyDataManager.getPartyMap();
        if (parMap != null && !parMap.isEmpty()) {

            List<PartyData> list = new ArrayList<>(parMap.values());

            Collections.sort(list,
                    new Comparator<PartyData>() {
                        @Override
                        public int compare(PartyData o1, PartyData o2) {

                            if (o1.getFight() > o2.getFight()) {
                                return -1;
                            }

                            if (o1.getFight() > o2.getFight()) {
                                return 1;
                            }
                            return 0;
                        }
                    });

            if (list.size() > 10) {
                list = list.subList(0, 10);
            }

            int partyId1 = partyDataManager.getPartyId(handler.getRoleId());

            if (parMap.containsKey(partyId1)) {
                list.add(parMap.get(partyId1));
            }

            for (PartyData par : list) {

                List<Member> meList = partyDataManager.getMemberList(par.getPartyId());

                if (meList == null) {
                    continue;
                }

                for (Member me : meList) {
                    Player player = playerDataManager.getPlayer(me.getLordId());

                    if (player == null) {
                        continue;
                    }

                    Member member = partyDataManager.getMemberById(me.getLordId());
                    if (member == null || member.getPartyId() == 0) {
                        handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
                        return;
                    }
                    int enterTime = member.getEnterTime();
                    if (enterTime == TimeHelper.getCurrentDay()) {
                        handler.sendErrorMsgToPlayer(GameError.IN_PARTY_TIME);
                        return;
                    }

                    int level = player.lord.getLevel();
                    int partyId = 0;
                    String partyName = "";
                    int partyLv = 0;
                    int mPortrait = player.lord.getPortrait();
                    int myPartySirPortrait = 0;

                    CCCrossPartyRegRq.Builder builder = CCCrossPartyRegRq.newBuilder();
                    builder.setRoleId(player.lord.getLordId());

                    // 排名
                    partyId = member.getPartyId();
                    PartyData partyData = partyDataManager.getParty(partyId);
                    partyLv = partyData.getPartyLv();
                    partyName = partyData.getPartyName();
                    // 获取军团长的名字
                    String legatusName = partyData.getLegatusName();
                    Player p = playerDataManager.getPlayer(legatusName);
                    if (p != null) {
                        myPartySirPortrait = p.lord.getPortrait();
                    }

                    builder.setNick(player.lord.getNick());
                    builder.setLevel(level);
                    builder.setWarRank(1);
                    builder.setPartyId(partyId);
                    builder.setPartyName(partyName);
                    builder.setPartyLv(partyLv);

                    // 我的头像
                    builder.setPortrait(mPortrait);
                    // 军团长的头像
                    builder.setMyPartySirPortrait(myPartySirPortrait);

                    handler.sendMsgToCrossServer(CCCrossPartyRegRq.EXT_FIELD_NUMBER, CCCrossPartyRegRq.ext, builder.build());
                }
            }
        }
    }

    /**
     * 跨服军团战报名
     *
     * @param code
     * @param rq
     * @param handler void
     */
    public void crossPartyReg(int code, CCCrossPartyRegRs rq, InnerHandler handler) {
        CrossPartyRegRs.Builder builder = CrossPartyRegRs.newBuilder();

        Player player = playerDataManager.getPlayer(rq.getRoleId());

        handler.sendMsgToPlayer(
                player, code, CrossPartyRegRs.ext, CrossPartyRegRs.EXT_FIELD_NUMBER, builder.build());
    }

    public void getCrossPartyMember(GetCrossPartyMemberRq rq, ClientHandler handler) {
        CCGetCrossPartyMemberRq.Builder builder = CCGetCrossPartyMemberRq.newBuilder();
        builder.setRoleId(handler.getRoleId());

        int partyId = 0;
        int warRank = 0;
        // 排名
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() > 0) {
            partyId = member.getPartyId();
            PartyData partyData = partyDataManager.getParty(partyId);
            warRank = partyData.getWarRank();
        }

        builder.setPartyId(partyId);
        builder.setWarRank(warRank);

        handler.sendMsgToCrossServer(
                CCGetCrossPartyMemberRq.EXT_FIELD_NUMBER, CCGetCrossPartyMemberRq.ext, builder.build());
    }

    /**
     * 获取我的军团
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void getCrossPartyMember(int code, CCGetCrossPartyMemberRs rq, InnerHandler handler) {

        GetCrossPartyMemberRs.Builder builder = GetCrossPartyMemberRs.newBuilder();

        Player player = playerDataManager.getPlayer(rq.getRoleId());

        if (code == GameError.OK.getCode()) {
            if (rq.hasPartyNums()) {
                builder.setPartyNums(rq.getPartyNums());
            }
            if (rq.hasMyPartyMemberNum()) {
                builder.setMyPartyMemberNum(rq.getMyPartyMemberNum());
            }
            if (rq.getCpMemberRegCount() > 0) {
                builder.addAllCpMemberReg(rq.getCpMemberRegList());
            }
            if (rq.hasGroup()) {
                builder.setGroup(rq.getGroup());
            }
        }

        handler.sendMsgToPlayer(
                player,
                code,
                GetCrossPartyMemberRs.ext,
                GetCrossPartyMemberRs.EXT_FIELD_NUMBER,
                builder.build());
    }

    /**
     * 获取跨服战军团
     *
     * @param rq
     * @param handler
     */
    public void getCrossParty(CCGetCrossPartyRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCrossPartyRs.Builder builder = GetCrossPartyRs.newBuilder();
        builder.setGroup(rq.getGroup());
        if (rq.getCpPartyInfoCount() > 0) {
            builder.addAllCpPartyInfo(rq.getCpPartyInfoList());
        }

        if (rq.hasTotalRegPartyNum()) {
            builder.setTotalRegPartyNum(rq.getTotalRegPartyNum());
        }
        if (rq.hasGroupRegPartyNum()) {
            builder.setGroupRegPartyNum(rq.getGroupRegPartyNum());
        }

        handler.sendMsgToPlayer(
                player, GetCrossPartyRs.ext, GetCrossPartyRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 获取阵营
     *
     * @param code
     * @param rq
     * @param handler
     */
    public void getCPForm(int code, CCGetCPFormRs rq, InnerHandler handler) {

        GetCPFormRs.Builder builder = GetCPFormRs.newBuilder();

        Player player = playerDataManager.getPlayer(rq.getRoleId());

        if (code == GameError.OK.getCode()) {
            if (rq.hasForm()) {
                builder.setForm(rq.getForm());
            }
            if (rq.hasFight()) {
                builder.setFight(rq.getFight());
            }
        }

        handler.sendMsgToPlayer(
                player, code, GetCPFormRs.ext, GetCPFormRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 跨服军团战设置阵型 （向跨服服务器发送）
     *
     * @param rq
     * @param handler void
     */
    public void setCPForm(SetCPFormRq rq, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        CCSetCPFormRq.Builder builder = CCSetCPFormRq.newBuilder();

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

        builder.setRoleId(handler.getRoleId());
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
        if (rq.getForm().hasAwakenHero()) { // 使用觉醒将领
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

        // 觉醒将领
        for (AwakenHero hero : player.awakenHeros.values()) {
            builder.addAwakenHero(PbHelper.createAwakenHeroPb(hero));
        }

        // 军备列表
        if (!player.leqInfo.getPutonLordEquips().isEmpty()) {
            for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getPutonLordEquips().entrySet()) {
                builder.addLeq(PbHelper.createLordEquip(entry.getValue()));
            }
        }

        // 军衔等级
        builder.setMilitaryRank(player.lord.getMilitaryRank());

        // 秘密武器
        if (!player.secretWeaponMap.isEmpty()) {
            for (Map.Entry<Integer, SecretWeapon> entry : player.secretWeaponMap.entrySet()) {
                builder.addSecretWeapon(PbHelper.createSecretWeapon(entry.getValue()));
            }
        }

        // 攻击特效
        if (!player.atkEffects.isEmpty()) {
            for (Map.Entry<Integer, AttackEffect> entry : player.atkEffects.entrySet()) {
                builder.addAtkEft(PbHelper.createAttackEffectPb(entry.getValue()));
            }
        }

        // 作战实验室
        if (!player.labInfo.getGraduateInfo().isEmpty()) {
            List<CommonPb.GraduateInfoPb> list =
                    PbHelper.createGraduateInfoPb(player.labInfo.getGraduateInfo());
            if (!list.isEmpty()) {
                builder.addAllGraduateInfo(list);
            }
        }

        // 玩家军团科技列表
        if (partyDataManager.getScience(player) != null
                && !partyDataManager.getScience(player).isEmpty()) {
            Iterator<PartyScience> psIt = partyDataManager.getScience(player).values().iterator();
            while (psIt.hasNext()) {
                builder.addPartyScience(PbHelper.createPartySciencePb(psIt.next()));
            }
        }

        // 技能
        if (!player.skills.isEmpty()) {
            for (Map.Entry<Integer, Integer> entry : player.skills.entrySet()) {
                builder.addSkill(PbHelper.createSkillPb(entry.getKey(), entry.getValue()));
            }
        }
        //能源核心
        PEnergyCore energyCore = player.energyCore;
        if (energyCore != null) {
            builder.setEnergyCore(PbHelper.createThreeIntPb(energyCore.getLevel(), energyCore.getSection(), energyCore.getState()));
        }
        handler.sendMsgToCrossServer(CCSetCPFormRq.EXT_FIELD_NUMBER, CCSetCPFormRq.ext, builder.build());
    }

    /**
     * 获取战况
     *
     * @param rq
     * @param handler
     */
    public void getCPSituation(CCGetCPSituationRs rq, InnerHandler handler) {
        GetCPSituationRs.Builder builder = GetCPSituationRs.newBuilder();
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        builder.setGroup(rq.getGroup());
        builder.setPage(rq.getPage());
        builder.addAllCpRecord(rq.getCpRecordList());

        handler.sendMsgToPlayer(
                player, GetCPSituationRs.ext, GetCPSituationRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 从跨服服务器获取本服战况
     *
     * @param rq
     * @param handler void
     */
    public void getCPOurServerSituation(GetCPOurServerSituationRq rq, ClientHandler handler) {
        int type = rq.getType();
        int page = rq.getPage();
        long roleId = handler.getRoleId();

        CCGetCPOurServerSituationRq.Builder builder = CCGetCPOurServerSituationRq.newBuilder();
        builder.setRoleId(roleId);

        builder.setType(type);
        builder.setPage(page);

        if (type == 2) {
            int partyId = 0;
            // 排名
            Member member = partyDataManager.getMemberById(handler.getRoleId());
            if (member != null && member.getPartyId() > 0) {
                partyId = member.getPartyId();
            }
            builder.setPartyId(partyId);
        }

        handler.sendMsgToCrossServer(
                CCGetCPOurServerSituationRq.EXT_FIELD_NUMBER,
                CCGetCPOurServerSituationRq.ext,
                builder.build());
    }

    /**
     * 玩家获取本服战况
     *
     * @param rq
     * @param handler void
     */
    public void getCPOurServerSituation(CCGetCPOurServerSituationRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCPOurServerSituationRs.Builder builder = GetCPOurServerSituationRs.newBuilder();
        builder.setType(rq.getType());
        builder.setPage(rq.getPage());
        if (rq.getCpRecordCount() > 0) {
            builder.addAllCpRecord(rq.getCpRecordList());
        }

        handler.sendMsgToPlayer(
                player,
                GetCPOurServerSituationRs.ext,
                GetCPOurServerSituationRs.EXT_FIELD_NUMBER,
                builder.build());
    }

    /**
     * 跨服军团战排名
     *
     * @param rq
     * @param handler void
     */
    public void getCPRank(CCGetCPRankRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCPRankRs.Builder builder = GetCPRankRs.newBuilder();
        builder.setType(rq.getType());
        builder.setPage(rq.getPage());
        if (rq.getCpRankCount() > 0) {
            builder.addAllCpRank(rq.getCpRankList());
        }
        if (rq.hasMySelf()) {
            builder.setMySelf(rq.getMySelf());
        }

        if (rq.hasMyJiFen()) {
            builder.setMyJiFen(rq.getMyJiFen());
        }
        handler.sendMsgToPlayer(player, GetCPRankRs.ext, GetCPRankRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 跨服军团战战报
     *
     * @param rq
     * @param handler void
     */
    public void getCPReport(CCGetCPReportRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCPReportRs.Builder builder = GetCPReportRs.newBuilder();
        if (rq.hasCpRptAtk()) {
            builder.setCpRptAtk(rq.getCpRptAtk());
        }
        handler.sendMsgToPlayer(
                player, GetCPReportRs.ext, GetCPReportRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 收取跨服军团战奖励
     *
     * @param code
     * @param rq
     * @param handler void
     */
    public void receiveCPReward(int code, CCReceiveCPRewardRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        int type = rq.getType();

        ReceiveCPRewardRs.Builder builder = ReceiveCPRewardRs.newBuilder();
        builder.setType(type);

        if (code == GameError.OK.getCode()) {
            int rank = rq.getRank();

            List<List<Integer>> awards = null;

            if (type == 1) {
                awards = staticWarAwardDataMgr.getServerPartyPersonAward(rank);
            } else if (type == 2) {
                awards = staticWarAwardDataMgr.getServerPartyWinAward(rank);
            }
            builder.addAllAward(
                    playerDataManager.addAwardsBackPb(player, awards, AwardFrom.CROSS_RANK_AWARD));
        }

        handler.sendMsgToPlayer(
                player, code, ReceiveCPRewardRs.ext, ReceiveCPRewardRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 从跨服服务器获取跨服军团战个人报名信息
     *
     * @param rq
     * @param handler void
     */
    public void getCPMyRegInfo(GetCPMyRegInfoRq rq, ClientHandler handler) {
        int partyId = 0;

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member != null && member.getPartyId() > 0) {
            partyId = member.getPartyId();
        }

        CCGetCPMyRegInfoRq.Builder builder = CCGetCPMyRegInfoRq.newBuilder();
        builder.setRoleId(handler.getRoleId());
        builder.setPartyId(partyId);
        handler.sendMsgToCrossServer(
                CCGetCPMyRegInfoRq.EXT_FIELD_NUMBER, CCGetCPMyRegInfoRq.ext, builder.build());
    }

    /**
     * 客户端获取跨服军团战个人报名信息
     *
     * @param rq
     * @param handler void
     */
    public void getCPMyRegInfo(CCGetCPMyRegInfoRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCPMyRegInfoRs.Builder builder = GetCPMyRegInfoRs.newBuilder();
        builder.setIsReg(rq.getIsReg());
        handler.sendMsgToPlayer(
                player, GetCPMyRegInfoRs.ext, GetCPMyRegInfoRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 发送给所有玩家
     *
     * @param rq
     */
    public void synCPSituation(CCSynCPSituationRq rq) {
        SynCPSituationRq.Builder builder = SynCPSituationRq.newBuilder();
        builder.setGruop(rq.getGruop());
        builder.setCpRecord(rq.getCpRecord());

        SynCPSituationRq req = builder.build();
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            playerDataManager.synCPSisutionToPlayer(player, req);
        }
    }

    /**
     * 跨服军团战设置阵型 （处理客户端消息）
     *
     * @param code
     * @param rq
     * @param handler void
     */
    public void setCPForm(int code, CCSetCPFormRs rq, InnerHandler handler) {

        Player player = playerDataManager.getPlayer(rq.getRoleId());

        SetCPFormRs.Builder builder = SetCPFormRs.newBuilder();
        builder.setForm(rq.getForm());
        builder.setFight(rq.getFight());

        handler.sendMsgToPlayer(
                player, code, SetCPFormRs.ext, SetCPFormRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * GM设置跨服军团阵型
     *
     * @param type void
     */
    public void gmSetCpForm(int type) {
        CCGMSetCPFormRq.Builder builder = CCGMSetCPFormRq.newBuilder();
        builder.setType(type);
        Base.Builder baseBuilder =
                PbHelper.createRqBase(
                        CCGMSetCPFormRq.EXT_FIELD_NUMBER, null, CCGMSetCPFormRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }

    /**
     * GM设置跨服军团战报名 void
     */
    public void gmCPReg() {
        // 给该服务器军团排前十的报名
        // Iterator<PartyRank> its =
        // partyDataManager.getPartyRanks().iterator();
        // while (its.hasNext()) {
        //
        // PartyRank pl = its.next();
        // if (pl.getRank() <= 3) {
        //
        // List<Member> list = partyDataManager.getMemberList(pl.getPartyId());
        // // 给所有人报名
        // for (Member m : list) {
        // try {
        // gmCpReg(m.getLordId());
        // } catch (Exception e) {
        // LogHelper.CROSS_LOGGER.equals(e);
        // }
        // }
        // }
        // }

        // Iterator<PartyData> its =
        // partyDataManager.getPartyMap().values().iterator();
        // while (its.hasNext()) {
        // PartyData pd = its.next();
        // int partyId = pd.getPartyId();
        // if (partyId != 0) {
        // List<Member> list = partyDataManager.getMemberList(partyId);
        // // 给所有人报名
        // for (Member m : list) {
        // try {
        // gmCpReg(m.getLordId());
        // } catch (Exception e) {
        // LogHelper.CROSS_LOGGER.equals(e);
        // }
        // }
        // }
        // }

        // 获取军团排名前三
        for (int i = 1; i <= 3; i++) {
            WarParty wp1 = warDataManager.getRankMap().get(i);
            if (wp1 != null) {
                int partyId = wp1.getPartyData().getPartyId();
                List<Member> list = partyDataManager.getMemberList(partyId);

                // 给所有人报名
                for (Member m : list) {
                    gmCpReg(m.getLordId());
                }
            }
        }
    }

    /**
     * GM给玩家报名
     *
     * @param roleId void
     */
    private void gmCpReg(long roleId) {
        Player player = playerDataManager.getPlayer(roleId);
        int level = player.lord.getLevel();
        int warRank = 0;
        int partyId = 0;
        String partyName = "";
        int partyLv = 0;

        CCCrossPartyRegRq.Builder builder = CCCrossPartyRegRq.newBuilder();
        builder.setRoleId(roleId);

        int mPortrait = player.lord.getPortrait();
        int myPartySirPortrait = 0;
        // 排名
        Member member = partyDataManager.getMemberById(roleId);
        if (member != null && member.getPartyId() > 0) {
            partyId = member.getPartyId();
            PartyData partyData = partyDataManager.getParty(partyId);
            partyLv = partyData.getPartyLv();
            warRank = partyData.getWarRank();
            partyName = partyData.getPartyName();
            String legatusName = partyData.getLegatusName();
            // 获取军团长的名字
            Player p = playerDataManager.getPlayer(legatusName);
            if (p != null) {
                myPartySirPortrait = p.lord.getPortrait();
            }
        }

        builder.setNick(player.lord.getNick());
        builder.setLevel(level);
        builder.setWarRank(warRank);
        builder.setPartyId(partyId);
        builder.setPartyName(partyName);
        builder.setPartyLv(partyLv);
        builder.setPortrait(mPortrait);
        builder.setMyPartySirPortrait(myPartySirPortrait);

        Base.Builder baseBuilder =
                PbHelper.createRqBase(
                        CCCrossPartyRegRq.EXT_FIELD_NUMBER, null, CCCrossPartyRegRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }

    /**
     * 跨服军团商店
     *
     * @param rq
     * @param handler void
     */
    public void getCPShop(CCGetCPShopRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());

        GetCPShopRs.Builder builder = GetCPShopRs.newBuilder();
        builder.setJifen(rq.getJifen());
        builder.addAllBuy(rq.getBuyList());
        handler.sendMsgToPlayer(player, GetCPShopRs.ext, GetCPShopRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 跨服服务器发来的回执 玩家积分兑换商品
     *
     * @param code
     * @param rs
     * @param handler void
     */
    public void exchangeCPShop(int code, CCExchangeCPShopRs rs, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rs.getRoleId());

        ExchangeCPShopRs.Builder builder = ExchangeCPShopRs.newBuilder();
        builder.setJifen(rs.getJifen());
        builder.setShopId(rs.getShopId());
        if (code != GameError.OK.getCode()) {
            handler.sendMsgToPlayer(player, code, ExchangeCPShopRs.ext, ExchangeCPShopRs.EXT_FIELD_NUMBER, builder.build());
        } else {
            StaticCrossShop shop = staticCrossDataMgr.getStaticCrossShopById(rs.getShopId());
            playerDataManager.addAward(player, shop.getRewardList().get(0).get(0), shop.getRewardList().get(0).get(1), shop.getRewardList().get(0).get(2) * rs.getCount(), AwardFrom.CROSS_JIFEN_EXCHANGE);
            builder.setCount(rs.getCount());
            builder.setRestNum(rs.getRestNum());
            handler.sendMsgToPlayer(player, ExchangeCPShopRs.ext, ExchangeCPShopRs.EXT_FIELD_NUMBER, builder.build());
        }
    }

    /**
     * 跨服服调用 玩家所有战局发送给玩家
     *
     * @param rq
     * @param handler void
     */
    public void getCPTrend(CCGetCPTrendRs rq, InnerHandler handler) {
        Player player = playerDataManager.getPlayer(rq.getRoleId());
        GetCPTrendRs.Builder builder = GetCPTrendRs.newBuilder();
        builder.setJifen(rq.getJifen());
        builder.addAllCrossTrend(rq.getCrossTrendList());

        handler.sendMsgToPlayer(
                player, GetCPTrendRs.ext, GetCPTrendRs.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 跨服服调用 同步跨服军团战状态给玩家
     *
     * @param rq
     * @param handler void
     */
    public void synCrossPartyState(CCSynCrossPartyStateRq rq, InnerHandler handler) {
        synCpState(rq.getState());
    }

    /**
     * 军团战状态发送给玩家
     *
     * @param state void
     */
    private void synCpState(int state) {
        SynCrossPartyStateRq.Builder builder = SynCrossPartyStateRq.newBuilder();
        builder.setState(state);
        SynCrossPartyStateRq req = builder.build();
        Iterator<Player> it = playerDataManager.getPlayers().values().iterator();
        while (it.hasNext()) {
            Player player = it.next();
            if (player == null || player.account == null || !player.isActive() || player.lord == null) {
                continue;
            }
            playerDataManager.synCPStateToPlayer(player, req);
        }
    }
}
