package com.game.service.cross.party;

import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.cross.domain.CrossShopBuy;
import com.game.cross.domain.CrossState;
import com.game.cross.domain.CrossTrend;
import com.game.crossParty.domain.*;
import com.game.crossParty.domain.GroupParty;
import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.PartyMember;
import com.game.crossParty.domain.ServerSisuation;
import com.game.dao.table.party.CrossPartyDataTableDao;
import com.game.dao.table.party.CrossPartyMemberTableDao;
import com.game.dao.table.party.CrossPartyRecordsTableDao;
import com.game.dao.table.party.CrossPartyTableDao;
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
import com.game.domain.s.StaticServerPartyWining;
import com.game.domain.table.party.CrossPartyDataTable;
import com.game.domain.table.party.CrossPartyMemberTable;
import com.game.domain.table.party.CrossPartyTable;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.cross.party.CrossPartyDataCache;
import com.game.manager.cross.party.CrossPartyDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.*;
import com.game.pb.CrossGamePb.*;
import com.game.server.GameContext;
import com.game.server.config.gameServer.Server;
import com.game.service.ChatService;
import com.game.service.FightService;
import com.game.service.cross.ChatInfo;
import com.game.service.cross.MailInfo;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/4/22 14:09
 * @Description :跨服军团战斗
 */
@Service
public class CrossPartyService {
    @Autowired
    private ChatService chatService;
    @Autowired
    private CrossPartyDataManager crossPartyDataManager;
    @Autowired
    private FightService fightService;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private StaticCrossDataMgr staticCrossDataMgr;
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;
    @Autowired
    private CrossPartyDataTableDao crossPartyDataTableDao;
    @Autowired
    private CrossPartyMemberTableDao crossPartyMemberTableDao;
    @Autowired
    private CrossPartyRecordsTableDao crossPartyRecordsTableDao;
    @Autowired
    private CrossPartyTableDao crossPartyTableDao;
    private static final int crossId = CrossPartyDataManager.crossId;

    /**
     * 获取跨服军团战状态
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyState(CCGetCrossPartyStateRq rq, ClientHandler handler) {
        CCGetCrossPartyStateRs.Builder builder = CCGetCrossPartyStateRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        int d = TimeHelper.getDayOfCrossWar();
        builder.setRoleId(rq.getRoleId());
        builder.setBeginTime(GameContext.getAc().getBean(ServerSetting.class).getCrossBeginTime());
        int state = 0;
        if (d >= 1 && d <= 10) {
            state = d;
        }
        builder.setState(state);
        handler.sendMsgToPlayer(CCGetCrossPartyStateRs.ext, builder.build());
    }

    /**
     * 获取服务器列表
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyServerList(CCGetCrossPartyServerListRq rq, ClientHandler handler) {
        CCGetCrossPartyServerListRs.Builder builder = CCGetCrossPartyServerListRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        for (Server server : GameContext.getGameServerConfig().getList()) {
            builder.addGameServerInfo(PbHelper.createGameServerInfoPb(server));
        }
        handler.sendMsgToPlayer(CCGetCrossPartyServerListRs.ext, builder.build());
    }

    /**
     * 跨服军团战报名
     *
     * @param rq
     * @param handler
     */
    public void crossPartyReg(CCCrossPartyRegRq rq, ClientHandler handler) {
        CCCrossPartyRegRs.Builder builder = CCCrossPartyRegRs.newBuilder();
        boolean isGmReg = rq.getGmState() > 0;
        long gmRoleId = rq.getGmState();
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        String nick = rq.getNick();
        int level = rq.getLevel();
        int rank = rq.getWarRank();
        int partyId = rq.getPartyId();
        String partyName = rq.getPartyName();
        int partyLv = rq.getPartyLv();
        int portrait = 0;
        int myPartySirPortrait = 0;
        if (rq.hasPortrait()) {
            portrait = rq.getPortrait();
        }
        if (rq.hasMyPartySirPortrait()) {
            myPartySirPortrait = rq.getMyPartySirPortrait();
        }
        builder.setRoleId(roleId);
        // 判断够不够报名资格
        if (rank == 0 || rank > CrossPartyConst.reg_rank) {
            LogUtil.error("gmRoleId=" + gmRoleId + " rank" + rank);
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_REG_RANK, CCCrossPartyRegRs.ext, builder.build());
            return;
        }
        // 判断报名时间是否正确
        if (!TimeHelper.isInCrossPartyRegTime()) {
            LogUtil.error("gmRoleId=" + gmRoleId + " time");
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_IN_REG_TIME, CCCrossPartyRegRs.ext, builder.build());
            return;
        }
        if (!isGmReg) {
            // 判断是否报名
            if (crossPartyDataManager.isReg(serverId, roleId)) {
                handler.sendMsgToPlayer(GameError.CROSS_PARTY_HAVE_REG, CCCrossPartyRegRs.ext, builder.build());
                return;
            }
        } else {
            // 判断是否报名
            if (crossPartyDataManager.isReg(serverId, gmRoleId)) {
                handler.sendMsgToPlayer(GameError.CROSS_PARTY_HAVE_REG, CCCrossPartyRegRs.ext, builder.build());
                return;
            }
        }
        PartyMember m = new PartyMember();
        m.setServerId(serverId);
        if (!isGmReg) {
            m.setRoleId(roleId);
        } else {
            m.setRoleId(gmRoleId);
        }
        m.setNick(nick);
        m.setLevel(level);
        m.setPartyId(partyId);
        m.setPartyName(partyName);
        m.setRegTime(TimeHelper.getCurrentSecond());
        m.setPortrait(portrait);
        crossPartyDataManager.partyReg(m, partyLv, rank, myPartySirPortrait);
        handler.sendMsgToPlayer(CCCrossPartyRegRs.ext, builder.build());
    }

    /**
     * Method: checkTank @Description: 检查阵型中的坦克是否足够 @param player @param form @param
     * tankCount @return @return boolean @throws
     */
    public boolean checkTank(Map<Integer, Integer> ownTanks, Form form, int tankCount) {
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
        for (Entry<Integer, Integer> entry : formTanks.entrySet()) {
            Integer num = ownTanks.get(entry.getKey());
            if (num == null || num < entry.getValue()) {
                return false;
            }
        }
        if (totalTank == 0) {
            return false;
        }
        return true;
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

    private void getMilitaryScience(PartyMember a, List<MilitaryScience> militaryScienceList) {
        if (militaryScienceList != null) {
            a.militarySciences.clear();
            for (MilitaryScience pbms : militaryScienceList) {
                com.game.domain.p.MilitaryScience m = PbHelper.createMilitaryScienece(pbms);
                a.militarySciences.put(m.getMilitaryScienceId(), m);
            }
        }
    }

    private void getMilitaryScienceGrid(PartyMember a, List<MilitaryScienceGrid> militaryScienceGridList) {
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

    private void getEnergyStone(PartyMember a, List<EnergyStoneInlay> inlayList) {
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

    private void getEffect(PartyMember a, List<Effect> effectList) {
        if (effectList != null) {
            a.effects.clear();
            for (Effect pbe : effectList) {
                com.game.domain.p.Effect e = PbHelper.createEffect(pbe);
                a.effects.put(e.getEffectId(), e);
            }
        }
    }

    private void getStaffingId(PartyMember a, int staffingId) {
        a.StaffingId = staffingId;
    }

    private void getSkill(PartyMember a, List<Skill> skillList) {
        if (skillList != null) {
            a.skills.clear();
            for (Skill skill : skillList) {
                a.skills.put(skill.getId(), skill.getLv());
            }
        }
    }

    // 获取科技
    private void getScience(PartyMember a, List<Science> scienceList) {
        if (scienceList != null) {
            a.sciences.clear();
            for (Science pbs : scienceList) {
                com.game.domain.p.Science s = PbHelper.createScience(pbs);
                a.sciences.put(s.getScienceId(), s);
            }
        }
    }

    // 获取配件
    private void getPart(PartyMember a, List<Part> partList) {
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
    private void getEquip(PartyMember a, List<Equip> equipList) {
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

    /**
     * 获取参加军团战的我的军团信息
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyMember(CCGetCrossPartyMemberRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        int partyId = rq.getPartyId();
        CCGetCrossPartyMemberRs.Builder builder = CCGetCrossPartyMemberRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setPartyNums(CrossPartyDataCache.getPartys().size());
        // 报名期,我的军团已报名的人数
        int myPartyMemberNum = 0;
        Party party = CrossPartyDataCache.getPartys().get(serverId + "_" + partyId);
        if (party != null) {
            myPartyMemberNum = party.getMembers().size();
            // 获取我的军团报名成员信息
            Iterator<PartyMember> its = party.getMembers().values().iterator();
            while (its.hasNext()) {
                builder.addCpMemberReg(PbHelper.createCpMemberRegPb(its.next()));
            }
            builder.setGroup(party.getGroup());
        }
        builder.setMyPartyMemberNum(myPartyMemberNum);
        // 判断若是在报名时间内获取,则需要判断当前warRank是不是前三。 若不是,则报没有资格。
        // if (TimeHelper.isInCrossPartyRegTime()) {
        // if (warRank == 0 || warRank > CrossPartyConst.reg_rank) {
        // handler.sendMsgToPlayer(GameError.CROSS_PARTY_REG_RANK,
        // CCGetCrossPartyMemberRs.ext, builder.build());
        // return;
        // }
        //
        // // 报名期,我的军团已报名的人数
        // int myPartyMemberNum = 0;
        // Party party =
        // crossPartyDataManager.gameCrossParty.getPartys().get(serverId + "_" +
        // partyId);
        // if (party != null) {
        // myPartyMemberNum = party.getMembers().size();
        //
        // // 获取我的军团报名成员信息
        // Iterator<PartyMember> its = party.getMembers().values().iterator();
        // while (its.hasNext()) {
        // builder.addCpMemberReg(PbHelper.createCpMemberRegPb(its.next()));
        // }
        // }
        // builder.setMyPartyMemberNum(myPartyMemberNum);
        // builder.setPartyNums(crossPartyDataManager.gameCrossParty.getPartys().size());
        //
        // } else {
        // // 若不是报名时间获取,则需要比较partyId 是否已经报名,若没有报名,则报未报名
        // if (!crossPartyDataManager.isRegParty(serverId, partyId)) {
        // handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_REG,
        // CCGetCrossPartyMemberRs.ext, builder.build());
        // return;
        // }
        //
        // // 获取我的军团报名人数
        // Party party =
        // crossPartyDataManager.gameCrossParty.getPartys().get(serverId + "_" +
        // partyId);
        // builder.setMyPartyMemberNum(party.getMembers().size());
        //
        // // 获取已报名的军团数
        // builder.setPartyNums(crossPartyDataManager.gameCrossParty.getPartys().size());
        //
        // // 获取我的军团报名成员信息
        // Iterator<PartyMember> its = party.getMembers().values().iterator();
        // while (its.hasNext()) {
        // builder.addCpMemberReg(PbHelper.createCpMemberRegPb(its.next()));
        // }
        // }
        handler.sendMsgToPlayer(CCGetCrossPartyMemberRs.ext, builder.build());
    }

    /**
     * 获取跨服军团
     *
     * @param rq
     * @param handler
     */
    public void getCrossPartyHandler(CCGetCrossPartyRq rq, ClientHandler handler) {
        CCGetCrossPartyRs.Builder builder = CCGetCrossPartyRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        builder.setGroup(rq.getGroup());
        GroupParty gp = CrossPartyDataCache.getGroupMap().get(rq.getGroup());
        if (gp != null) {
            Iterator<Party> its = gp.groupPartyMap.values().iterator();
            while (its.hasNext()) {
                Party p = its.next();
                String serverName = GameContext.gameServerMaps.get(p.getServerId()).getName();
                builder.addCpPartyInfo(PbHelper.createCPPartyInfo(p, serverName));
            }
            builder.setGroupRegPartyNum(gp.groupPartyMap.size());
        }
        builder.setTotalRegPartyNum(CrossPartyDataCache.getPartys().size());
        handler.sendMsgToPlayer(CCGetCrossPartyRs.ext, builder.build());
    }

    /**
     * 获取跨服军团布阵
     *
     * @param rq
     * @param handler
     */
    public void getCPForm(CCGetCPFormRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        CCGetCPFormRs.Builder builder = CCGetCPFormRs.newBuilder();
        builder.setRoleId(roleId);
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(serverId + "_" + roleId);
        if (pm != null && pm.getForm() != null) {
            builder.setForm(PbHelper.createFormPb(pm.getForm()));
            builder.setFight(pm.getFight());
        }
        handler.sendMsgToPlayer(CCGetCPFormRs.ext, builder.build());
    }

    /**
     * 布阵
     *
     * @param rq
     * @param handler
     */
    public void setCPForm(CCSetCPFormRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        CommonPb.Form pbFrom = rq.getForm();
        long fight = rq.getFight();
        int maxTankNum = rq.getMaxTankNum();
        int staffingId = rq.getStaffingId();
        CCSetCPFormRs.Builder builder = CCSetCPFormRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setForm(rq.getForm());
        builder.setFight(fight);
        // 判断是否报名
        if (!crossPartyDataManager.isReg(serverId, roleId)) {
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_CANT_SET_FORM_CASE_NO_REG, CCSetCPFormRs.ext, builder.build());
            return;
        }
        // 判断是否布阵时间
        if (!TimeHelper.isInCrossPartySetFormTime()) {
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_IN_FORM_TIME, CCSetCPFormRs.ext, builder.build());
            return;
        }
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(serverId + "_" + roleId);
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
        Form destForm = PbHelper.createForm(pbFrom);
        int heroId = 0;
        if (destForm.getAwakenHero() != null) { // 使用觉醒将领
            CommonPb.AwakenHero awakenHero = awakenHeros.get(destForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.getState() == HeroConst.HERO_AWAKEN_STATE_USED) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            heroId = awakenHero.getHeroId();
            destForm.setAwakenHero(new AwakenHero(awakenHero));
        } else if (destForm.getCommander() > 0) {
            Hero hero = heros.get(destForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendMsgToPlayer(GameError.NO_HERO, CCSetCPFormRs.ext, builder.build());
                return;
            }
            heroId = destForm.getCommander();
        }
        if (heroId != 0) {
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);
            if (staticHero == null) {
                handler.sendMsgToPlayer(GameError.NO_CONFIG, CCSetCPFormRs.ext, builder.build());
                return;
            }
            if (staticHero.getType() != 2) {
                handler.sendMsgToPlayer(GameError.NOT_HERO, CCSetCPFormRs.ext, builder.build());
                return;
            }
        }
        // 计算坦克够不够
        if (!checkTank(tanks, destForm, maxTankNum)) {
            handler.sendMsgToPlayer(GameError.TANK_COUNT, CCSetCPFormRs.ext, builder.build());
            return;
        }
        pm.setForm(destForm);
        pm.setInstForm(new Form(destForm));
        pm.setStaffingId(staffingId);
        pm.setFight(fight);
        // 获取装备
        getEquip(pm, rq.getEquipList());
        // 获取配件
        getPart(pm, rq.getPartList());
        // 获取科技
        getScience(pm, rq.getScienceList());
        // 获取技能
        getSkill(pm, rq.getSkillList());
        // 获取编制
        getStaffingId(pm, rq.getStaffingId());
        // 获取effect
        getEffect(pm, rq.getEffectList());
        // 获取能晶
        getEnergyStone(pm, rq.getInlayList());
        // 获取军工科技
        getMilitaryScienceGrid(pm, rq.getMilitaryScienceGridList());
        getMilitaryScience(pm, rq.getMilitaryScienceList());
        // 勋章
        // 获取勋章展厅
        getMedalBounds(pm, rq.getMedalBounsList());
        getMedal(pm, rq.getMedalList());
        // 觉醒将领
        getAwakenHeros(pm, rq.getAwakenHeroList());
        // 军备
        getLordEquips(pm, rq.getLeqList());
        // 军衔等级
        pm.militaryRank = rq.getMilitaryRank();
        // 秘密武器
        getSecretWeapon(pm, rq.getSecretWeaponList());
        // 攻击特效
        getAttackEffects(pm, rq.getAtkEftList());
        // 作战实验室科技树
        getGraduateInfo(pm, rq.getGraduateInfoList());
        // 军团科技列表
        getPartyScience(pm, rq.getPartyScienceList());
        //能源核心
        getEnergyCore(pm, rq.getEnergyCore());
        // 要重新计算军团战力
        crossPartyDataManager.caluPartyFight(serverId, pm.getPartyId());
        builder.setForm(PbHelper.createFormPb(destForm));
        CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
        byte[] bytes = crossPartyMemberTable.serPartyMembers(pm);
        crossPartyMemberTable.setMemberInfo(bytes);
        crossPartyMemberTableDao.update(crossPartyMemberTable);
        handler.sendMsgToPlayer(CCSetCPFormRs.ext, builder.build());
    }

    /**
     * 能源核心
     *
     * @param a
     * @param energyCore
     */
    private void getEnergyCore(PartyMember a, ThreeInt energyCore) {
        PEnergyCore core = new PEnergyCore(1, 1,0);
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
    private void getPartyScience(PartyMember a, List<Science> partyScienceList) {
        a.partyScienceMap.clear();
        for (Science s : partyScienceList) {
            PartyScience partyScience = new PartyScience(s.getScienceId(), s.getScienceLv());
            partyScience.setSchedule(s.getSchedule());
            a.partyScienceMap.put(partyScience.getScienceId(), partyScience);
        }
    }

    private void getGraduateInfo(PartyMember pm, List<GraduateInfoPb> pbs) {
        pm.graduateInfo.clear();
        for (GraduateInfoPb pb : pbs) {
            Map<Integer, Integer> skillMap = pm.graduateInfo.get(pb.getType());
            if (skillMap == null) {
                pm.graduateInfo.put(pb.getType(), skillMap = new HashMap<>());
            }
            for (TwoInt ti : pb.getGraduateInfoList()) {
                skillMap.put(ti.getV1(), ti.getV2());
            }
        }
    }

    private void getAttackEffects(PartyMember pm, List<AttackEffectPb> effectPbs) {
        pm.atkEffects.clear();
        if (effectPbs != null && !effectPbs.isEmpty()) {
            for (AttackEffectPb pb : effectPbs) {
                pm.atkEffects.put(pb.getType(), new AttackEffect(pb));
            }
        }
    }

    /**
     * 加载秘密武器
     *
     * @param pm
     * @param pbWeapons
     */
    private void getSecretWeapon(PartyMember pm, List<SecretWeapon> pbWeapons) {
        pm.secretWeaponMap.clear();
        if (pbWeapons != null && !pbWeapons.isEmpty()) {
            for (SecretWeapon pbw : pbWeapons) {
                com.game.domain.p.SecretWeapon secretWeapon = new com.game.domain.p.SecretWeapon(pbw);
                pm.secretWeaponMap.put(pbw.getId(), secretWeapon);
            }
        }
    }

    private void getLordEquips(PartyMember a, List<CommonPb.LordEquip> lordEquips) {
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

    private void getAwakenHeros(PartyMember a, List<CommonPb.AwakenHero> awakenHeroList) {
        if (awakenHeroList != null) {
            a.awakenHeros.clear();
            for (CommonPb.AwakenHero mpb : awakenHeroList) {
                a.awakenHeros.put(mpb.getKeyId(), new AwakenHero(mpb));
            }
        }
    }

    private void getMedalBounds(PartyMember a, List<MedalBouns> medalBounsList) {
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

    private void getMedal(PartyMember pm, List<Medal> medalList) {
        if (medalList != null) {
            pm.medals.clear();
            for (Medal mpb : medalList) {
                com.game.domain.p.Medal m = PbHelper.createMedal(mpb);
                HashMap<Integer, com.game.domain.p.Medal> map = pm.medals.get(m.getPos());
                if (map == null) {
                    map = new HashMap<Integer, com.game.domain.p.Medal>();
                    pm.medals.put(m.getPos(), map);
                }
                map.put(m.getKeyId(), m);
            }
        }
    }

    /**
     * 分组
     */
    private void makeGroup() {
        // 获取所有排名第一的军团,然后随机分配到ABCD四个组
        List<Party> firtRankList = new ArrayList<Party>();
        // 其他所有排名的军团
        List<Party> otherList = new ArrayList<Party>();
        Iterator<Party> its = CrossPartyDataCache.getPartys().values().iterator();
        while (its.hasNext()) {
            Party p = its.next();
            if (p.getWarRank() == 1) {
                firtRankList.add(p);
            } else {
                otherList.add(p);
            }
        }
        Collections.shuffle(firtRankList);
        Collections.shuffle(otherList);
        Map<Integer, GroupParty> map = CrossPartyDataCache.getGroupMap();
        int size = firtRankList.size();
        for (int i = 0; i < size; i++) {
            int group = ((i + 1) % 4 == 0) ? 4 : ((i + 1) % 4);
            Party p = firtRankList.get(i);
            p.setGroup(group);
            addParty(map, p);
            CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(p.getPartyId());
            byte[] bytes = crossPartyDataTable.serParty(p);
            crossPartyDataTable.setPartyInfo(bytes);
            crossPartyDataTableDao.update(crossPartyDataTable);
        }
        size = otherList.size();
        for (int i = 0; i < size; i++) {
            int temp = ((i + 1) % 4) == 0 ? 4 : ((i + 1) % 4);
            int group = 5 - temp;
            Party p = otherList.get(i);
            p.setGroup(group);
            addParty(map, p);
            CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(p.getPartyId());
            byte[] bytes = crossPartyDataTable.serParty(p);
            crossPartyDataTable.setPartyInfo(bytes);
            crossPartyDataTableDao.update(crossPartyDataTable);
        }
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        byte[] bytesg = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
        crossPartyTable.setGroupMap(bytesg);
        byte[] bytes = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
        crossPartyTable.setGroupMap(bytes);
        crossPartyTableDao.update(crossPartyTable);
    }

    /**
     * 分组
     */
    private void makeGroupTest() {
        Map<Integer, GroupParty> map = CrossPartyDataCache.getGroupMap();
        Iterator<Party> its = CrossPartyDataCache.getPartys().values().iterator();
        while (its.hasNext()) {
            Party p = its.next();
            p.setGroup(1);
            addParty(map, p);
        }
    }

    private void addParty(Map<Integer, GroupParty> map, Party p) {
        GroupParty gp = map.get(p.getGroup());
        if (gp == null) {
            gp = new GroupParty();
            gp.setGroup(p.getGroup());
            map.put(p.getGroup(), gp);
        }
        gp.groupPartyMap.put(p.getServerId() + "_" + p.getPartyId(), p);
        LogUtil.error(p.getPartyName() + " 军团分到 " + gp.getGroup() + " 组");
    }

    /**
     * 跨服军团战逻辑
     */
    public void crossPartyWarTimerLogic() {
        int dayNum = TimeHelper.getDayOfCrossWar();
        // 跨服战是否开始
        if (dayNum >= 1 && dayNum <= 11) {
            // 发送跨服战开始消息
            synCrossBeginMsg(dayNum);
            synCrossBeginMail(dayNum);
        }
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        CrossState cs = crossPartyTable.getCrossStateConfig();
        if (cs == null) {
            cs = new CrossState();
        }
        // 资格赛争夺
        if (TimeHelper.isInCPFightForQualificate()) {
            String beginTime = "00:00:00";
            String endTime = "21:00:00";
            if (cs.getStage() != 1 || !cs.getBeginTime().equals(beginTime)) {
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossTime(TimeHelper.getCurrentDay());
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
            }
        } else if (TimeHelper.isInCrossPartyRegTime()) {
            // 报名时间
            String beginTime = "21:00:00";
            String endTime = "23:59:59";
            if (cs.getStage() != 1 || !cs.getBeginTime().equals(beginTime)) {
                // 说明第一次
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
            }
        } else if (TimeHelper.isInCPGroupSetFormTime(dayNum)) {
            // 小组布阵时间
            String beginTime = "00:00:00";
            String endTime = "17:00:00";
            if (cs.getStage() != 3 || !cs.getBeginTime().equals(beginTime)) {
                // 说明第一次
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
                LogUtil.error("布阵时间到了,开始分组");
                // 分组
                makeGroup();
                // makeGroupTest();
            }
        } else if (TimeHelper.isinCPGruopFight(dayNum, CrossPartyConst.group_A)) {
            doFight(dayNum, "17:00:00", "18:00:00", CrossPartyConst.group_A);
        } else if (TimeHelper.isinCPGruopFight(dayNum, CrossPartyConst.group_B)) {
            doFight(dayNum, "18:00:00", "19:00:00", CrossPartyConst.group_B);
        } else if (TimeHelper.isinCPGruopFight(dayNum, CrossPartyConst.group_C)) {
            doFight(dayNum, "19:00:00", "20:00:00", CrossPartyConst.group_C);
        } else if (TimeHelper.isinCPGruopFight(dayNum, CrossPartyConst.group_D)) {
            doFight(dayNum, "20:00:00", "21:00:00", CrossPartyConst.group_D);
        } else if (TimeHelper.isInCPFinalSetFormTime(dayNum)) {
            // 小组布阵时间
            String beginTime = "21:00:00";
            String endTime = "14:00:00";
            if (cs.getStage() != 3 || !cs.getBeginTime().equals(beginTime)) {
                // 说明第一次
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
            }
        } else if (TimeHelper.isinCPFinalFight(dayNum)) {
            // 跨服军团决赛
            doFight(dayNum, "14:00:00", "16:00:00", CrossPartyConst.group_E);
        } else if (TimeHelper.isinCpReceiveReward(dayNum)) {
            // 跨服军团领奖
        }
    }

    /**
     * 战斗
     *
     * @param group
     */
    private void doFight(int dayNum, String beginTime, String endTime, int group) {
        CrossPartyGroupFight crossFight = crossPartyDataManager.crossPartyGroupFight;
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        CrossState cs = crossPartyTable.getCrossStateConfig();
        if (cs == null) {
            cs = new CrossState();
        }
        if (crossFight == null) {
            if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                // 说明第一次
                crossFight = new CrossPartyGroupFight(dayNum, beginTime, group);
                crossFight.init();
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
                crossPartyDataManager.crossPartyGroupFight = crossFight;
            }
        } else {
            // 判断上次记录的时间,若不想同,说明是上次的,new 新的
            if (cs.getStage() != dayNum || !cs.getBeginTime().equals(beginTime)) {
                crossFight = new CrossPartyGroupFight(dayNum, beginTime, group);
                crossFight.init();
                cs.setStage(dayNum);
                cs.setBeginTime(beginTime);
                cs.setEndTime(endTime);
                cs.setState(CrossConst.begin_state);
                crossPartyTable.setCrossStateConfig(cs);
                crossPartyTableDao.update(crossPartyTable);
                crossPartyDataManager.crossPartyGroupFight = crossFight;
            }
            if (cs.getStage() == dayNum && cs.getBeginTime().equals(beginTime)) {
                if (cs.getState() != CrossConst.end_state) {
                    if (crossFight.round()) {
                        cs.setState(CrossConst.end_state);
                        crossPartyTable.setCrossStateConfig(cs);
                        crossPartyTableDao.update(crossPartyTable);
                        LogUtil.error(group + "组 完成");
                        // 小组赛完成刷新更新排行榜
                        sortMapByJifen(CrossPartyDataCache.getPartyMembers());
                        // 若是D组完成,生成E组
                        if (crossFight.getGroup() == CrossPartyConst.group_D) {
                            genearyGroupE();
                        }
                        // 若e组完成,生成排行
                        if (crossFight.getGroup() == CrossPartyConst.group_E) {
                            // 获取第一军团的名字
                            Party p = getTopParty(1);
                            if (p != null) {
                                chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_224, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getPartyName()));
                            }
                            LogUtil.error("开始生成排行榜");
                            rank();
                        }
                    }
                }
            }
        }
    }

    private void rank() {
        // // 个人积分排行
        // sortMapByJifen(crossPartyDataManager.gameCrossParty.getPartyMembers());
        // 军团积分排行
        sortPartyRank();
        // 连胜排行
        sortLianShengRank();
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        byte[] bytes = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
        crossPartyTable.setGroupMap(bytes);
        byte[] bytes1 = crossPartyTable.serLianShengRank(CrossPartyDataCache.getLianShengRank());
        crossPartyTable.setLianShengRank(bytes1);
        crossPartyTableDao.update(crossPartyTable);
        // 发送名人堂
        synCpFame();
    }

    // 总决赛连胜排行
    public void sortLianShengRank() {
        LinkedHashMap<String, String> map = CrossPartyDataCache.getLianShengRank();
        if (CrossPartyDataCache.getGroupMap().isEmpty() || !CrossPartyDataCache.getGroupMap().containsKey(CrossPartyConst.group_E)) {
            return;
        }
        // 获取E组的玩家
        Iterator<Party> its = CrossPartyDataCache.getGroupMap().get(CrossPartyConst.group_E).groupPartyMap.values().iterator();
        while (its.hasNext()) {
            Party p = its.next();
            Iterator<PartyMember> is = p.getMembers().values().iterator();
            while (is.hasNext()) {
                PartyMember pm = is.next();
                String key = pm.getServerId() + "_" + pm.getRoleId();
                map.put(key, key);
            }
        }
        // 排序
        List<Entry<String, String>> infoIds = new ArrayList<Entry<String, String>>(map.entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<String, String>>() {
                @
                        Override
                public int compare(Entry<String, String> o1, Entry<String, String> o2) {
                    PartyMember p1 = CrossPartyDataCache.getPartyMembers().get(o1.getKey());
                    PartyMember p2 = CrossPartyDataCache.getPartyMembers().get(o2.getKey());
                    if (p2.getFinalWinNum() > p1.getFinalWinNum()) {
                        return 1;
                    } else if (p2.getFinalWinNum() < p1.getFinalWinNum()) {
                        return -1;
                    } else {
                        if (p2.getFight() > p1.getFight()) {
                            return 1;
                        } else if (p2.getFight() < p1.getFight()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<String, String> newMap = new LinkedHashMap<String, String>();
        for (Entry<String, String> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        map.clear();
        map.putAll(newMap);
    }

    // 军团积分排行
    public void sortPartyRank() {
        // 先按总决赛的名次排,名字不够24名,则按积分排
        LinkedHashMap<String, Party> map = CrossPartyDataCache.getPartys();
        if (map.isEmpty()) {
            return;
        }
        List<Entry<String, Party>> infoIds = new ArrayList<Entry<String, Party>>(map.entrySet());
        // 遍历计算军团总积分
        Iterator<Party> its = map.values().iterator();
        while (its.hasNext()) {
            Party p = its.next();
            Iterator<PartyMember> is = p.getMembers().values().iterator();
            while (is.hasNext()) {
                PartyMember pm = is.next();
                p.setTotalJifen(p.getTotalJifen() + pm.getJifen());
            }
        }
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<String, Party>>() {
                @
                        Override
                public int compare(Entry<String, Party> o1, Entry<String, Party> o2) {
                    Party p1 = o1.getValue();
                    Party p2 = o2.getValue();
                    int rank1 = 999;
                    int rank2 = 999;
                    // 首先比较决赛的排名; 决赛排名过后，比较积分
                    GroupParty gp = CrossPartyDataCache.getGroupMap().get(5);
                    if (gp != null) {
                        Iterator<Entry<Integer, Party>> its = gp.getRankMap().entrySet().iterator();
                        while (its.hasNext()) {
                            Entry<Integer, Party> e = its.next();
                            if (e.getValue() == p1) {
                                rank1 = e.getKey();
                            }
                            if (e.getValue() == p2) {
                                rank2 = e.getKey();
                            }
                        }
                        if (rank1 > rank2) {
                            return 1;
                        }
                        if (rank1 < rank2) {
                            return -1;
                        }
                    }
                    if (p2.getTotalJifen() > p1.getTotalJifen()) {
                        return 1;
                    } else if (p2.getTotalJifen() < p1.getTotalJifen()) {
                        return -1;
                    } else {
                        if (p2.getFight() > p1.getFight()) {
                            return 1;
                        } else if (p2.getFight() < p1.getFight()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<String, Party> newMap = new LinkedHashMap<String, Party>();
        for (Entry<String, Party> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        map.clear();
        map.putAll(newMap);
        newMap = null;
    }

    private void genearyGroupE() {
        Map<Integer, GroupParty> map = CrossPartyDataCache.getGroupMap();
        for (int i = 1; i <= 4; i++) {
            GroupParty gp = map.get(i);
            if (gp != null) {
                // 获取gp前6名
                for (int j = 1; j <= 6; j++) {
                    Party p = gp.getRankMap().get(j);
                    if (p != null) {
                        p.setFinalGroup(true);
                        addPartyToGruopE(p);
                    }
                }
            }
        }
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        byte[] bytesg = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
        crossPartyTable.setGroupMap(bytesg);
        crossPartyTableDao.update(crossPartyTable);
        LogUtil.error("E组生成完成,总共参加的军团数为:" + map.get(CrossPartyConst.group_E).groupPartyMap.size());
    }

    private void addPartyToGruopE(Party p) {
        Map<Integer, GroupParty> map = CrossPartyDataCache.getGroupMap();
        GroupParty gp = map.get(CrossPartyConst.group_E);
        if (gp == null) {
            gp = new GroupParty();
            gp.setGroup(CrossPartyConst.group_E);
            map.put(gp.getGroup(), gp);
        }
        gp.groupPartyMap.put(p.getServerId() + "_" + p.getPartyId(), p);
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        byte[] bytes = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
        crossPartyTable.setGroupMap(bytes);
        crossPartyTableDao.update(crossPartyTable);
    }

    private int generateReportKey() {
        CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
        int ret = crossPartyTable.getReportKey() + 1;
        crossPartyTable.setReportKey(ret);
        crossPartyTableDao.update(crossPartyTable);
        return ret;
    }

    /**
     * 小组赛战斗
     *
     * @author wanyi ABCD小组 E决赛
     */
    public class CrossPartyGroupFight {
        private List<Party> fighters = new ArrayList<Party>();
        private int days;
        private String beginTime;
        private int group;
        private int outCount = 0;
        private int tick = 0;
        private int noneSetFromPartyNum = 0; // 没有设置阵型的军团个数
        private List<FightPair> pairs;

        public CrossPartyGroupFight(int days, String beginTime, int group) {
            super();
            this.days = days;
            this.beginTime = beginTime;
            this.group = group;
        }

        public List<FightPair> arrangePair() {
            List<FightPair> pairs = new LinkedList<>();
            Collections.shuffle(fighters);
            int size = fighters.size();
            for (int i = 0; i < size / 2; i++) {
                FightPair fightPair = new FightPair();
                Party party1 = fighters.get(2 * i);
                Party party2 = fighters.get(2 * i + 1);
                fightPair.attacker = party1.aquireFighter();
                fightPair.defencer = party2.aquireFighter();
                pairs.add(fightPair);
            }
            return pairs;
        }

        public void init() {
            fighters.clear();
            outCount = 0;
            noneSetFromPartyNum = 0;
            if (group <= 4) {
                // 发送232消息
                chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_232, getGroupName(group)));
            } else if (group == 5) {
                chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_223));
            }
            LogUtil.error("战斗初始化组别:" + group);
            GroupParty gp = CrossPartyDataCache.getGroupMap().get(group);
            if (gp != null) {
                Iterator<Party> its = gp.groupPartyMap.values().iterator();
                while (its.hasNext()) {
                    Party p = its.next();
                    p.prepair();
                    if (p.getFormNum() != 0) {
                        fighters.add(p);
                        LogUtil.error(group + "|" + p.getServerId() + "|" + p.getPartyId() + "|" + p.getPartyName() + " setForm in war");
                    } else {
                        noneSetFromPartyNum++;
                        LogUtil.error(group + "|" + p.getServerId() + "|" + p.getPartyId() + "|" + p.getPartyName() + " 没有设置阵型");
                    }
                }
            }
            LogUtil.error("战斗軍團數为:" + fighters.size());
        }

        public boolean round() {
            tick++;
            if (tick % 3 != 0) {
                return false;
            }
            int time = TimeHelper.getCurrentSecond();
            if (pairs == null || pairs.isEmpty()) {
                pairs = arrangePair();
            }
            int result;
            int rank;
            int hp1;
            int hp2;
            Iterator<FightPair> it = pairs.iterator();
            while (it.hasNext()) {
                FightPair fightPair = (FightPair) it.next();
                hp1 = fightPair.attacker.calcHp();
                LogUtil.error("hp1:" + hp1);
                hp2 = fightPair.defencer.calcHp();
                LogUtil.error("hp2:" + hp2);
                int reportKey = generateReportKey();
                String attackName = fightPair.attacker.getNick();
                String attackPartyName = fightPair.attacker.getPartyName();
                String attackServerName = GameContext.gameServerMaps.get(fightPair.attacker.getServerId()).getName();
                String defenceName = fightPair.defencer.getNick();
                String defencePartyName = fightPair.defencer.getPartyName();
                String defenceServerName = GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName();
                int serverId1 = fightPair.attacker.getServerId();
                int serverId2 = fightPair.defencer.getServerId();
                long roleId1 = fightPair.attacker.getRoleId();
                long roleId2 = fightPair.defencer.getRoleId();
                CPRptAtk.Builder rptAtkWar = CPRptAtk.newBuilder();
                if (fightWarMember(fightPair.attacker, fightPair.defencer, rptAtkWar, reportKey)) {
                    LogUtil.error(fightPair.attacker.getServerId() + "/" + fightPair.attacker.getNick() + " win " + fightPair.defencer.getServerId() + "/" + fightPair.defencer.getNick());
                    addWinCount(fightPair.attacker, group);
                    addWinJiFen(fightPair.attacker, group);
                    addFailJiFen(fightPair.defencer, group);
                    result = getResult(fightPair.attacker, group);
                    // 进攻方连胜奖励
                    LianShengJiFen(fightPair.attacker, group);
                    // 进攻方终结防守方奖励
                    ZhongJieJiFen(fightPair.attacker, fightPair.defencer, group);
                    CrossPartyDataCache.getPartys().get(fightPair.defencer.getServerId() + "_" + fightPair.defencer.getPartyId()).fighterOut(fightPair.defencer);
                } else {
                    LogUtil.error(fightPair.attacker.getServerId() + "/" + fightPair.attacker.getNick() + " fail " + fightPair.defencer.getServerId() + "/" + fightPair.defencer.getNick());
                    result = 0;
                    addWinCount(fightPair.defencer, group);
                    addWinJiFen(fightPair.defencer, group);
                    addFailJiFen(fightPair.attacker, group);
                    // 防守方连胜奖励
                    LianShengJiFen(fightPair.defencer, group);
                    // 防守方终结进攻方奖励
                    ZhongJieJiFen(fightPair.defencer, fightPair.attacker, group);
                    CrossPartyDataCache.getPartys().get(fightPair.attacker.getServerId() + "_" + fightPair.attacker.getPartyId()).fighterOut(fightPair.attacker);
                }
                CPRecord record = PbHelper.createCpRecordPb(reportKey, attackPartyName, attackName, attackServerName, hp1, defencePartyName, defenceName, defenceServerName, hp2, result, time, group, serverId1, serverId2, roleId1, roleId2);
                SynCPSituation(record, group);
                // 增加key
                addReportKey(fightPair.attacker, fightPair.defencer, reportKey, group);
                // 战斗次数
                fightPair.attacker.setFightCount(fightPair.attacker.getFightCount() + 1);
                fightPair.defencer.setFightCount(fightPair.defencer.getFightCount() + 1);
                crossPartyDataManager.addCPRecord(record);
                crossPartyDataManager.addCPRptAtk(rptAtkWar.build());
                Party warParty = null;
                if (result == 0) {
                    warParty = getParty(fightPair.attacker.getServerId(), fightPair.attacker.getPartyId());
                    // 被终结
                    if (warParty.allOut()) {
                        rank = CrossPartyDataCache.getGroupMap().get(group).groupPartyMap.size() - noneSetFromPartyNum - outCount;
                        setWarRank(warParty, rank, group);
                        outCount++;
                        int key = generateReportKey();
                        CPRecord out = PbHelper.createCpResultPb(key, GameContext.gameServerMaps.get(warParty.getServerId()).getName(), warParty.getPartyName(), GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName(), fightPair.defencer.getPartyName(), fightPair.defencer.getNick(), rank, time, group);
                        SynCPSituation(out, group);
                        addReportKey(fightPair.attacker, fightPair.defencer, key, group);
                        crossPartyDataManager.addCPRecord(out);
                        if (rank == 2) {
                            int kk = generateReportKey();
                            CPRecord first = PbHelper.createCpResultFirstPb(kk, GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName(), fightPair.defencer.getPartyName(), 1, time, group);
                            crossPartyDataManager.addCPRecord(first);
                            addReportKey(fightPair.attacker, fightPair.defencer, kk, group);
                        }
                        // 第三名被终结,需要发108
                        if (!isGroupType(group) && rank == 3) {
                            sendTop123Mail(warParty, fightPair.defencer.getPartyName(), MailType.MOLD_CP_108);
                        }
                        if (!isGroupType(group) && rank == 2) {
                            // 第二名发110
                            sendTop123Mail(warParty, fightPair.defencer.getPartyName(), MailType.MOLD_CP_110);
                            // 第一名发111
                            sendTop123Mail(getParty(fightPair.defencer.getServerId(), fightPair.defencer.getPartyId()), fightPair.attacker.getPartyName(), MailType.MOLD_CP_111);
                        }
                        // 小组赛获取决赛资格
                        if (group <= 4 && rank <= CrossPartyConst.group_up_q_rank) {
                            chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_230, GameContext.gameServerMaps.get(warParty.getServerId()).getName(), warParty.getPartyName(), rank + ""));
                        }
                    }
                } else {
                    warParty = getParty(fightPair.defencer.getServerId(), fightPair.defencer.getPartyId());
                    // 被终结
                    if (warParty.allOut()) {
                        rank = CrossPartyDataCache.getGroupMap().get(group).groupPartyMap.size() - noneSetFromPartyNum - outCount;
                        setWarRank(warParty, rank, group);
                        outCount++;
                        int key = generateReportKey();
                        CPRecord out = PbHelper.createCpResultPb(key, GameContext.gameServerMaps.get(fightPair.defencer.getServerId()).getName(), fightPair.defencer.getPartyName(), GameContext.gameServerMaps.get(fightPair.attacker.getServerId()).getName(), fightPair.attacker.getPartyName(), fightPair.attacker.getNick(), rank, time, group);
                        SynCPSituation(out, group);
                        addReportKey(fightPair.attacker, fightPair.defencer, key, group);
                        crossPartyDataManager.addCPRecord(out);
                        if (rank == 2) {
                            int kk = generateReportKey();
                            CPRecord first = PbHelper.createCpResultFirstPb(kk, GameContext.gameServerMaps.get(fightPair.attacker.getServerId()).getName(), fightPair.attacker.getPartyName(), 1, time, group);
                            crossPartyDataManager.addCPRecord(first);
                            addReportKey(fightPair.attacker, fightPair.defencer, kk, group);
                        }
                        // 第三名被终结,需要发108
                        if (!isGroupType(group) && rank == 3) {
                            sendTop123Mail(warParty, fightPair.attacker.getPartyName(), MailType.MOLD_CP_108);
                        }
                        if (!isGroupType(group) && rank == 2) {
                            // 第二名发110
                            sendTop123Mail(warParty, fightPair.attacker.getPartyName(), MailType.MOLD_CP_110);
                            // 第一名发111
                            sendTop123Mail(getParty(fightPair.attacker.getServerId(), fightPair.attacker.getPartyId()), fightPair.defencer.getPartyName(), MailType.MOLD_CP_111);
                        }
                        // 小组赛获取决赛资格
                        if (group <= 4 && rank <= CrossPartyConst.group_up_q_rank) {
                            chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_230, GameContext.gameServerMaps.get(warParty.getServerId()).getName(), warParty.getPartyName(), rank + ""));
                        }
                    }
                }
                // 更新玩家数据
                if (fightPair.attacker != null) {
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(fightPair.attacker.getRoleId());
                    byte[] bytes = crossPartyMemberTable.serPartyMembers(fightPair.attacker);
                    crossPartyMemberTable.setMemberInfo(bytes);
                    crossPartyMemberTableDao.update(crossPartyMemberTable);
                    Party party = getParty(fightPair.attacker.getServerId(), fightPair.attacker.getPartyId());
                    if (party != null) {
                        CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(fightPair.attacker.getPartyId());
                        byte[] bytes1 = crossPartyDataTable.serParty(party);
                        crossPartyDataTable.setPartyInfo(bytes1);
                        crossPartyDataTableDao.update(crossPartyDataTable);
                    }
                }
                if (fightPair.defencer != null) {
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(fightPair.defencer.getRoleId());
                    byte[] bytes = crossPartyMemberTable.serPartyMembers(fightPair.defencer);
                    crossPartyMemberTable.setMemberInfo(bytes);
                    crossPartyMemberTableDao.update(crossPartyMemberTable);
                    Party party = getParty(fightPair.defencer.getServerId(), fightPair.defencer.getPartyId());
                    if (party != null) {
                        CrossPartyDataTable crossPartyDataTable = crossPartyDataTableDao.get(fightPair.defencer.getPartyId());
                        byte[] bytes1 = crossPartyDataTable.serParty(party);
                        crossPartyDataTable.setPartyInfo(bytes1);
                        crossPartyDataTableDao.update(crossPartyDataTable);
                    }
                }
                it.remove();
                break;
            }
            partyOut();
            if (fighters.size() == 1) { // 剩下的是冠军，比赛结束
                Party warParty = fighters.get(0);
                setWarRank(warParty, 1, group);
                // 小组赛获取决赛资格
                if (group <= 4) {
                    chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_230, GameContext.gameServerMaps.get(warParty.getServerId()).getName(), warParty.getPartyName(), 1 + ""));
                }
                return true;
            }
            if (fighters.size() == 0) {
                return true;
            }
            // }
            return false;
        }

        private void ZhongJieJiFen(PartyMember winer, PartyMember failer, int group) {
            // 判断终结的次数出不出于终结奖励区间
            int time = 0;
            StaticServerPartyWining s = null;
            if (isGroupType(group)) {
                time = getZhongeJieTime(failer.getGroupWinNum());
            } else {
                time = getZhongeJieTime(failer.getFinalWinNum());
            }
            if (time != 0) {
                s = staticCrossDataMgr.getServerPartyWining().get(time);
            }
            if (s != null) {
                chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_233, GameContext.gameServerMaps.get(winer.getServerId()).getName(), winer.getNick(), GameContext.gameServerMaps.get(failer.getServerId()).getName(), failer.getNick()));
                winer.setJifen(winer.getJifen() + s.getShutdown());
                CrossTrendHelper.addCrossTrend(winer, CrossConst.TREND.ZHONG_JIE_JIFEN, String.valueOf(s.getTime()), String.valueOf(s.getShutdown()));
                CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(winer.getRoleId());
                byte[] bytes = crossPartyMemberTable.serPartyMembers(winer);
                crossPartyMemberTable.setMemberInfo(bytes);
                crossPartyMemberTableDao.update(crossPartyMemberTable);
                LogUtil.error(winer.getNick() + "终结了" + failer.getPartyName() + "连胜,获得" + s.getShutdown() + "积分,现有积分" + winer.getJifen());
            }
        }

        private int getZhongeJieTime(int num) {
            int ret = 0;
            if (num < 7) {
                ret = 0;
            } else if (num >= 7 && num < 9) {
                ret = 7;
            } else if (num >= 9 && num < 11) {
                ret = 9;
            } else if (num >= 11 && num < 13) {
                ret = 11;
            } else {
                ret = 13;
            }
            return ret;
        }

        /**
         * 连胜奖励
         *
         * @param p
         * @param group
         */
        private void LianShengJiFen(PartyMember p, int group) {
            StaticServerPartyWining s = null;
            if (isGroupType(group)) {
                s = staticCrossDataMgr.getServerPartyWining().get(p.getGroupWinNum());
            } else {
                s = staticCrossDataMgr.getServerPartyWining().get(p.getFinalWinNum());
            }
            if (s != null) {
                p.setJifen(p.getJifen() + s.getScore());
                CrossTrendHelper.addCrossTrend(p, CrossConst.TREND.LIAN_SHENG_JIFEN, String.valueOf(s.getTime()), String.valueOf(s.getScore()));
                CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(p.getRoleId());
                byte[] bytes = crossPartyMemberTable.serPartyMembers(p);
                crossPartyMemberTable.setMemberInfo(bytes);
                crossPartyMemberTableDao.update(crossPartyMemberTable);
            }
        }

        private void addFailJiFen(PartyMember p, int group) {
            int getJifen = 0;
            if (isGroupType(group)) {
                getJifen = CrossPartyConst.FAIL_JIFEN;
            } else {
                getJifen = CrossPartyConst.FINAL_FAIL_JIFEN;
            }
            p.setJifen(p.getJifen() + getJifen);
            LogUtil.error(p.getNick() + "失败,获得" + getJifen + "积分,现有积分" + p.getJifen());
        }

        private void addWinJiFen(PartyMember p, int group) {
            int getJifen = 0;
            if (isGroupType(group)) {
                // 小组赛
                getJifen = CrossPartyConst.WIN_JIFEN;
            } else {
                getJifen = CrossPartyConst.FINAL_WIN_JIFEN;
            }
            p.setJifen(p.getJifen() + getJifen);
            LogUtil.error(p.getNick() + "胜利,获得" + getJifen + "积分,现有积分" + p.getJifen());
        }

        public int getGroup() {
            return group;
        }

        public void setGroup(int group) {
            this.group = group;
        }

        private void addReportKey(PartyMember attacker, PartyMember defencer, int reportKey, int group) {
            // 个人
            attacker.addReportKey(reportKey);
            defencer.addReportKey(reportKey);
            // 军团
            Party ap = getParty(attacker.getServerId(), attacker.getPartyId());
            if (ap != null) {
                ap.addKey(reportKey);
            }
            Party dp = getParty(defencer.getServerId(), defencer.getPartyId());
            if (dp != null) {
                dp.addKey(reportKey);
            }
            // 分组
            CrossPartyDataCache.getGroupMap().get(group).addKey(reportKey);
            // 服务器
            if (attacker.getServerId() == defencer.getServerId()) {
                addServerKey(attacker.getServerId(), group, reportKey);
            } else {
                addServerKey(attacker.getServerId(), group, reportKey);
                addServerKey(defencer.getServerId(), group, reportKey);
            }
            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
            byte[] bytes = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
            crossPartyTable.setGroupMap(bytes);
            crossPartyTableDao.update(crossPartyTable);
        }

        public void addServerKey(int serverId, int group, int key) {
            ServerSisuation ss = CrossPartyDataCache.getServerSisuationMap().get(serverId);
            if (ss == null) {
                ss = new ServerSisuation();
                ss.setServerId(serverId);
                CrossPartyDataCache.getServerSisuationMap().put(serverId, ss);
            }
            if (group == CrossPartyConst.group_E) {
                ss.getFinalKeyList().add(key);
            } else {
                ss.getGroupKeyList().add(key);
            }
            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
            byte[] bytes = crossPartyTable.serServerSisuationMap(CrossPartyDataCache.getServerSisuationMap());
            crossPartyTable.setServerSisuationMap(bytes);
            crossPartyTableDao.update(crossPartyTable);
        }

        /**
         * 获取军团
         *
         * @param serverId
         * @param partyId
         * @return
         */
        private Party getParty(int serverId, int partyId) {
            return CrossPartyDataCache.getPartys().get(serverId + "_" + partyId);
        }

        private int getResult(PartyMember a, int group) {
            if (isGroupType(group)) {
                return a.getGroupWinNum();
            } else {
                return a.getFinalWinNum();
            }
        }

        private void setWarRank(Party p, int rank, int group) {
            LogUtil.error(p.getPartyName() + " 获得了 " + group + "组 第" + rank + "名");
            CrossPartyDataCache.getGroupMap().get(group).getRankMap().put(rank, p);
            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
            byte[] bytes = crossPartyTable.serGroupMap(CrossPartyDataCache.getGroupMap());
            crossPartyTable.setGroupMap(bytes);
            crossPartyTableDao.update(crossPartyTable);
        }

        private void addWinCount(PartyMember p, int group) {
            StaticServerPartyWining s = null;
            if (isGroupType(group)) {
                p.setGroupWinNum(p.getGroupWinNum() + 1);
                s = staticCrossDataMgr.getServerPartyWining().get(p.getGroupWinNum());
            } else {
                p.setFinalWinNum(p.getFinalWinNum() + 1);
                s = staticCrossDataMgr.getServerPartyWining().get(p.getFinalWinNum());
            }
            if (s != null) {
                s = staticCrossDataMgr.getServerPartyWining().get(p.getFinalWinNum());
                LogUtil.error(p.getServerId() + "/" + p.getNick() + "获得了 【" + p.getGroupWinNum() + "】 连胜");
                if (p.getGroupWinNum() == 7) {
                    chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_226, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getNick(), CrossPartyConst.groupName));
                } else if (p.getGroupWinNum() == 9) {
                    chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_227, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getNick(), CrossPartyConst.groupName));
                } else if (p.getGroupWinNum() == 11) {
                    chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_228, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getNick(), CrossPartyConst.groupName));
                } else if (p.getGroupWinNum() == 13) {
                    chatService.sendAllGameChat(chatService.createSysChat(SysChatId.cp_225, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getNick(), CrossPartyConst.groupName));
                }
            }
        }

        public void partyOut() {
            Iterator<Party> it = fighters.iterator();
            while (it.hasNext()) {
                Party warParty = (Party) it.next();
                if (warParty.allOut()) {
                    it.remove();
                }
            }
        }
    }

    private String getGroupName(int group) {
        String ret = "";
        if (group == CrossPartyConst.group_A) {
            ret = CrossPartyConst.groupA;
        } else if (group == CrossPartyConst.group_B) {
            ret = CrossPartyConst.groupB;
        } else if (group == CrossPartyConst.group_C) {
            ret = CrossPartyConst.groupC;
        } else if (group == CrossPartyConst.group_D) {
            ret = CrossPartyConst.groupD;
        }
        return ret;
    }

    /**
     * 同步战况
     *
     * @param cp
     * @param group
     */
    private void SynCPSituation(CPRecord cp, int group) {
        CCSynCPSituationRq.Builder builder = CCSynCPSituationRq.newBuilder();
        builder.setCpRecord(cp);
        builder.setGruop(group);
        Base.Builder msg = PbHelper.createSynBase(CCSynCPSituationRq.EXT_FIELD_NUMBER, CCSynCPSituationRq.ext, builder.build());
        for (Server server : GameContext.getGameServerConfig().getList()) {
            if (server.isConect()) {
                try {
                    GameContext.synMsgToPlayer(server.ctx, msg);
                } catch (Exception e) {
                    LogUtil.error(e);
                }
            }
        }
    }

    /**
     * 是否小组赛
     *
     * @param group
     * @return
     */
    public boolean isGroupType(int group) {
        return group == CrossPartyConst.group_A || group == CrossPartyConst.group_B || group == CrossPartyConst.group_C || group == CrossPartyConst.group_D;
    }

    private boolean fightWarMember(PartyMember a, PartyMember d, CPRptAtk.Builder rptAtkWar, int reportKey) {
        Fighter attacker = fightService.createCrossPartyFighter(a, a.getInstForm(), AttackType.ACK_PLAYER);
        Fighter defencer = fightService.createCrossPartyFighter(d, d.getInstForm(), AttackType.ACK_PLAYER);
        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
        fightLogic.packForm(a.getInstForm(), d.getInstForm());
        fightLogic.fight();
        Record record = fightLogic.generateRecord();
        subForceToForm(attacker, a.getInstForm());
        subForceToForm(defencer, d.getInstForm());
        int result = fightLogic.getWinState();
        rptAtkWar.setReportKey(reportKey);
        rptAtkWar.setFirst(fightLogic.attackerIsFirst());
        rptAtkWar.setAttacker(createCrossRptMan(a, attacker.firstValue));
        rptAtkWar.setDefencer(createCrossRptMan(d, defencer.firstValue));
        rptAtkWar.setRecord(record);
        if (result == 1) { // 攻方胜利
            rptAtkWar.setResult(true);
            return true;
        } else {
            rptAtkWar.setResult(false);
            return false;
        }
    }

    private CrossRptMan createCrossRptMan(PartyMember a, int firstValue) {
        CrossRptMan.Builder builder = CrossRptMan.newBuilder();
        builder.setName(a.getNick());
        builder.setServerName(GameContext.gameServerMaps.get(a.getServerId()).getName());
        builder.setFirstValue(firstValue);
        return builder.build();
    }

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
     * 发送跨服战系统消息
     */
    private void synCrossBeginMsg(int dayNum) {
        Map<String, ChatInfo> temp = CrossPartyServiceCache.getSysChatConst(dayNum);
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
            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
            if (!((crossPartyTable.getChatDayNum() == dayNum) && (crossPartyTable.getChatDayTime().equals(info.getBeginTime())))) {
                if (info.getId() == SysChatId.cp_224) {
                    // 获取第一军团的名字
                    Party p = getTopParty(1);
                    if (p != null) {
                        chatService.sendAllGameChat(chatService.createSysChat(info.getId(), GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getPartyName()));
                    }
                } else {
                    if (info.getId() == SysChatId.CP_BEGIN) {
                        // 同步跨服开始
                        sendCPPush(0, CrossPartyConst.State.begin);
                    } else if (info.getId() == SysChatId.cp_234) {
                        // 同步结束
                        sendCPPush(0, CrossPartyConst.State.end);
                    } else {
                        chatService.sendAllGameChat(chatService.createSysChat(info.getId()));
                    }
                }
                crossPartyTable.setChatDayNum(dayNum);
                crossPartyTable.setChatDayTime(info.getBeginTime());
                crossPartyTableDao.update(crossPartyTable);
            }
        }
    }

    // 获取军团排名
    public Party getTopParty(int rank) {
        Party p = null;
        GroupParty gp = CrossPartyDataCache.getGroupMap().get(5);
        if (gp != null) {
            p = gp.getRankMap().get(rank);
        }
        return p;
    }

    /**
     * 获取积分排名第一的玩家
     *
     * @return
     */
    public PartyMember getTop1RankMember() {
        LinkedHashMap<String, PartyMember> rankMap = CrossPartyDataCache.getPartyMembers();
        PartyMember pm = null;
        for (Entry<String, PartyMember> entry : rankMap.entrySet()) {
            pm = entry.getValue();
            break;
        }
        return pm;
    }

    /**
     * 获取连胜排名第一的玩家
     *
     * @return
     */
    public PartyMember getTop1LianshengRankMember() {
        PartyMember pm = null;
        LinkedHashMap<String, String> rankMap = CrossPartyDataCache.getLianShengRank();
        for (Entry<String, String> entry : rankMap.entrySet()) {
            pm = CrossPartyDataCache.getPartyMembers().get(entry.getValue());
            break;
        }
        return pm;
    }

    /**
     * 发送跨服战邮件消息
     */
    private void synCrossBeginMail(int dayNum) {
        Map<String, MailInfo> temp = CrossPartyServiceCache.getSysMailConst(dayNum);
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
            CrossPartyTable crossPartyTable = crossPartyTableDao.get(crossId);
            if (!((crossPartyTable.getMailDayNum() == dayNum) && (crossPartyTable.getMailDayTime()).equals(info.getBeginTime()))) {
                sendGameChat(info.getId(), dayNum, beginTime);
                crossPartyTable.setMailDayNum(dayNum);
                crossPartyTable.setMailDayTime(info.getBeginTime());
                crossPartyTableDao.update(crossPartyTable);
            }
        }
    }

    private void sendGameChat(int moldId, int dayNum, String beginTime) {
        switch (moldId) {
            case MailType.MOLD_CP_104:
                // 发送全服邮件
                sendGameMail(0, moldId, CrossConst.MailType.All, null);
                break;
            case MailType.MOLD_CP_105:
                sendGameMail(0, moldId, CrossConst.MailType.All, null);
                break;
            case MailType.MOLD_CP_106:
                // 给报名的玩家发邮件
                sendGroupWinAndFailMail();
                break;
            case MailType.MOLD_CP_109:
                sendRewardMail();
                break;
            default:
                break;
        }
    }

    /**
     * 发送冠亚季争夺邮件
     *
     * @param p
     * @param zhongjiePartyName
     * @param mold
     */
    private void sendTop123Mail(Party p, String zhongjiePartyName, int mold) {
        Iterator<PartyMember> its = p.getMembers().values().iterator();
        while (its.hasNext()) {
            PartyMember pm = its.next();
            sendGameMail(pm.getServerId(), mold, CrossConst.MailType.Person, pm.getRoleId(), zhongjiePartyName);
        }
    }

    /**
     * 发送奖励邮件 109 112 113 114
     */
    private void sendRewardMail() {
        // 给所有参赛玩家发109
        Iterator<PartyMember> its = CrossPartyDataCache.getPartyMembers().values().iterator();
        while (its.hasNext()) {
            PartyMember pm = its.next();
            if (pm.getJifen() > 0) {
                sendGameMail(pm.getServerId(), MailType.MOLD_CP_109, CrossConst.MailType.Person, pm.getRoleId(), pm.getJifen() + "");
            }
        }
        // 在此发军团排名奖励,利用115邮件通知
        sendPartyRankReward();
        GroupParty gp = CrossPartyDataCache.getGroupMap().get(5);
        if (gp != null) {
            // 给冠军军团所在服务器发112
            // 给亚军军团所在服务器发113
            // 给季军军团所在服务器发114
            Party p1 = gp.getRankMap().get(1);
            sendGameMail(p1.getServerId(), MailType.MOLD_CP_112, CrossConst.MailType.All, null, p1.getPartyName(), 1 + "");
            Party p2 = gp.getRankMap().get(2);
            sendGameMail(p2.getServerId(), MailType.MOLD_CP_113, CrossConst.MailType.All, null, p2.getPartyName(), 2 + "");
            Party p3 = gp.getRankMap().get(3);
            sendGameMail(p3.getServerId(), MailType.MOLD_CP_114, CrossConst.MailType.All, null, p3.getPartyName(), 3 + "");
        }
    }

    // 在此发军团排名奖励,利用115邮件通知
    private void sendPartyRankReward() {
        LinkedHashMap<String, Party> rankMap = CrossPartyDataCache.getPartys();
        int index = 0;
        for (Entry<String, Party> entry : rankMap.entrySet()) {
            if (index >= 24) {
                break;
            }
            Party p = entry.getValue();
            sendGameMail(p.getServerId(), MailType.MOLD_CP_115, CrossConst.MailType.All, null, p.getPartyId() + "", (index + 1) + "");
            index++;
        }
    }

    /**
     * 给小组晋级和失败的玩法发邮件 106,107
     */
    private void sendGroupWinAndFailMail() {
        for (int i = 1; i <= 4; i++) {
            GroupParty gp = CrossPartyDataCache.getGroupMap().get(i);
            if (gp != null) {
                Iterator<Entry<Integer, Party>> its = gp.getRankMap().entrySet().iterator();
                while (its.hasNext()) {
                    Entry<Integer, Party> e = its.next();
                    int rank = e.getKey();
                    Party p = e.getValue();
                    // 给军团成员发晋级的邮件 106
                    if (rank <= CrossPartyConst.group_up_q_rank) {
                        Iterator<PartyMember> ii = p.getMembers().values().iterator();
                        while (ii.hasNext()) {
                            PartyMember pm = ii.next();
                            sendGameMail(pm.getServerId(), MailType.MOLD_CP_106, CrossConst.MailType.Person, pm.getRoleId());
                        }
                    } else {
                        // 给军团成员发失败的邮件 107
                        Iterator<PartyMember> ii = p.getMembers().values().iterator();
                        while (ii.hasNext()) {
                            PartyMember pm = ii.next();
                            sendGameMail(pm.getServerId(), MailType.MOLD_CP_107, CrossConst.MailType.Person, pm.getRoleId());
                        }
                    }
                }
            }
        }
    }

    /**
     * * 给某个game服发邮件<br>
     * * type 类型,1全服,2个人 serverId 0 代表所有服
     *
     * @param serverId
     * @param mold
     * @param type
     * @param role
     * @param param
     */
    private void sendGameMail(int serverId, int mold, int type, Long role, String... param) {
        CCSynMailRq.Builder builder = CCSynMailRq.newBuilder();
        builder.setMoldId(mold);
        builder.setType(type);
        if (role != null) {
            builder.setRoleId(role);
        }
        if (param != null) {
            for (int i = 0; i < param.length; i++) {
                builder.addParam(param[i]);
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
    }

    /**
     * 获取战况
     *
     * @param rq
     * @param handler
     */
    public void getCPSituation(CCGetCPSituationRq rq, ClientHandler handler) {
        int group = rq.getGroup();
        int page = rq.getPage();
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        CCGetCPSituationRs.Builder builder = CCGetCPSituationRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setPage(page);
        builder.setGroup(group);
        GroupParty gp = CrossPartyDataCache.getGroupMap().get(group);
        if (gp != null) {
            List<Integer> list = gp.getGroupKeyList();
            int size = list.size();
            int begin = page * 20;
            int end = begin + 20;
            LogUtil.error(group + "组记录数" + size + ", 获取" + begin + "到" + end + "之间的数据");
            for (int i = begin; i < end && i < size; i++) {
                CPRecord cr = CrossPartyDataCache.getCrossRecords().get(list.get(i));
                if (cr != null) {
                    builder.addCpRecord(transCPRecord(cr, serverId, roleId));
                }
            }
        }
        handler.sendMsgToPlayer(CCGetCPSituationRs.ext, builder.build());
    }

    private CPRecord transCPRecord(CPRecord cr, int serverId, long roleId) {
        boolean flag = false;
        if (cr.hasServerId1()) {
            if (cr.getServerId1() == serverId && cr.getRoleId1() == roleId) {
                flag = true;
            }
        }
        if (cr.hasServerId2()) {
            if (cr.getServerId2() == serverId && cr.getRoleId2() == roleId) {
                flag = true;
            }
        }
        if (flag) {
            CPRecord.Builder builder = CPRecord.newBuilder();
            if (cr.hasReportKey()) {
                builder.setReportKey(cr.getReportKey());
            }
            if (cr.hasPartyName1()) {
                builder.setPartyName1(cr.getPartyName1());
            }
            if (cr.hasName1()) {
                builder.setName1(cr.getName1());
            }
            if (cr.hasServerName1()) {
                builder.setServerName1(cr.getServerName1());
            }
            if (cr.hasHp1()) {
                builder.setHp1(cr.getHp1());
            }
            if (cr.hasPartyName2()) {
                builder.setPartyName2(cr.getPartyName2());
            }
            if (cr.hasName2()) {
                builder.setName2(cr.getName2());
            }
            if (cr.hasServerName2()) {
                builder.setServerName2(cr.getServerName2());
            }
            if (cr.hasHp2()) {
                builder.setHp2(cr.getHp2());
            }
            if (cr.hasResult()) {
                builder.setResult(cr.getResult());
            }
            if (cr.hasRank()) {
                builder.setRank(cr.getRank());
            }
            if (cr.hasTime()) {
                builder.setTime(cr.getTime());
            }
            if (cr.hasGroup()) {
                builder.setGroup(cr.getGroup());
            }
            builder.setIsMy(true);
            if (cr.hasServerId1()) {
                builder.setServerId1(cr.getServerId1());
            }
            if (cr.hasServerId2()) {
                builder.setServerId2(cr.getServerId2());
            }
            if (cr.hasRoleId1()) {
                builder.setRoleId1(cr.getRoleId1());
            }
            if (cr.hasRoleId2()) {
                builder.setRoleId2(cr.getRoleId2());
            }
            return builder.build();
        } else {
            return cr;
        }
    }

    /**
     * 获取本服战况
     *
     * @param rq
     * @param handler
     */
    public void getCPOurServerSituation(CCGetCPOurServerSituationRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        int type = rq.getType();
        int page = rq.getPage();
        long roleId = rq.getRoleId();
        CCGetCPOurServerSituationRs.Builder builder = CCGetCPOurServerSituationRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setPage(page);
        builder.setType(type);
        List<Integer> list = null;
        if (type == 1) { // 本服
            ServerSisuation s = CrossPartyDataCache.getServerSisuationMap().get(serverId);
            if (s != null) {
                list = new ArrayList<Integer>();
                list.addAll(s.getGroupKeyList());
                list.addAll(s.getFinalKeyList());
            }
        } else if (type == 2) { // 军团战况
            int partyId = rq.getPartyId();
            Party p = CrossPartyDataCache.getPartys().get(serverId + "_" + partyId);
            if (p != null) {
                list = p.getPartyReportKey();
            }
        } else if (type == 3) { // 个人战况
            PartyMember p = CrossPartyDataCache.getPartyMembers().get(serverId + "_" + roleId);
            if (p != null) {
                list = p.getMyReportKeys();
            }
        }
        if (list != null) {
            int size = list.size();
            int begin = page * 20;
            int end = begin + 20;
            for (int i = begin; i < end && i < size; i++) {
                CPRecord cr = CrossPartyDataCache.getCrossRecords().get(list.get(i));
                if (cr != null) {
                    builder.addCpRecord(transCPRecord(cr, serverId, roleId));
                }
            }
        }
        handler.sendMsgToPlayer(CCGetCPOurServerSituationRs.ext, builder.build());
    }

    public void getCPReport(CCGetCPReportRq rq, ClientHandler handler) {
        CCGetCPReportRs.Builder builder = CCGetCPReportRs.newBuilder();
        builder.setRoleId(rq.getRoleId());
        CPRptAtk atk = CrossPartyDataCache.getCrossRptAtks().get(rq.getReportKey());
        if (atk != null) {
            builder.setCpRptAtk(atk);
        }
        handler.sendMsgToPlayer(CCGetCPReportRs.ext, builder.build());
    }

    /**
     * 排序by积分
     *
     * @param map
     */
    public void sortMapByJifen(LinkedHashMap<String, PartyMember> map) {
        List<Entry<String, PartyMember>> infoIds = new ArrayList<Entry<String, PartyMember>>(map.entrySet());
        try {
            // 排序
            Collections.sort(infoIds, new Comparator<Entry<String, PartyMember>>() {
                @
                        Override
                public int compare(Entry<String, PartyMember> o1, Entry<String, PartyMember> o2) {
                    PartyMember p1 = o1.getValue();
                    PartyMember p2 = o2.getValue();
                    if (p2.getJifen() > p1.getJifen()) {
                        return 1;
                    } else if (p2.getJifen() < p1.getJifen()) {
                        return -1;
                    } else {
                        if (p2.getFight() > p1.getFight()) {
                            return 1;
                        } else if (p2.getFight() < p1.getFight()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                }
            });
        } catch (Exception e) {
            LogUtil.error(e);
        }
        /* 转换成新map输出 */
        LinkedHashMap<String, PartyMember> newMap = new LinkedHashMap<String, PartyMember>();
        for (Entry<String, PartyMember> entity : infoIds) {
            newMap.put(entity.getKey(), entity.getValue());
        }
        map.clear();
        map.putAll(newMap);
        newMap = null;
    }

    /**
     * 获取排名
     *
     * @param rq
     * @param handler
     */
    public void getCPRank(CCGetCPRankRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int page = rq.getPage();
        int serverId = handler.getServerId();
        int type = rq.getType();
        int myJifen = 0;
        PartyMember pmm = CrossPartyDataCache.getPartyMembers().get(serverId + "_" + roleId);
        if (pmm != null) {
            myJifen = pmm.getJifen() + pmm.getJifenjiangli() - pmm.getExchangeJifen();
        }
        CCGetCPRankRs.Builder builder = CCGetCPRankRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setType(type);
        builder.setPage(page);
        if (type == 1) { // 个人排行
            LinkedHashMap<String, PartyMember> rankMap = CrossPartyDataCache.getPartyMembers();
            int begin = page * 20;
            int end = begin + 20;
            int index = 0;
            LogUtil.error("个人排行总共的记录数" + rankMap.size() + ", 获取" + begin + "到" + end + "之间的数据");
            for (Entry<String, PartyMember> entry : rankMap.entrySet()) {
                if (index >= end) {
                    break;
                }
                if (index >= begin) {
                    PartyMember pm = entry.getValue();
                    String name = pm.getNick();
                    int fightCount = pm.getFightCount();
                    int jifen = pm.getJifen();
                    if (jifen <= 0) {
                        break;
                    }
                    String serverName = GameContext.gameServerMaps.get(pm.getServerId()).getName();
                    long fight = pm.getFight();
                    builder.addCpRank(PbHelper.createCpRankPb(index + 1, name, fightCount, jifen, serverName, fight));
                }
                index++;
            }
            // 判断自己
            int i = 0;
            for (Entry<String, PartyMember> entry : rankMap.entrySet()) {
                if (i > 100) {
                    break;
                }
                PartyMember pm = entry.getValue();
                if (pm.getJifen() <= 0) {
                    break;
                }
                if (serverId == pm.getServerId() && roleId == pm.getRoleId()) {
                    int rewardState = CrossPartyConst.receive_reward_cant;
                    // 是否领取
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
                    if (crossPartyMemberTable != null) {
                        if (crossPartyMemberTable.getReceivePersionRward() == 1) {
                            rewardState = CrossPartyConst.receive_reward_haveReceive;
                        } else {
                            if (i >= 10) {
                                rewardState = CrossPartyConst.receive_reward_cant;
                            } else {
                                rewardState = CrossPartyConst.receive_reward_can;
                            }
                        }
                    }
                    builder.setMySelf(PbHelper.createCpRankPb(i + 1, rewardState));
                    break;
                }
                i++;
            }
        } else if (type == 2) { // 连胜排行
            LinkedHashMap<String, String> rankMap = CrossPartyDataCache.getLianShengRank();
            int begin = page * 20;
            int end = begin + 20;
            int index = 0;
            LogUtil.error("连胜排行总共的记录数" + rankMap.size() + ", 获取" + begin + "到" + end + "之间的数据");
            for (Entry<String, String> entry : rankMap.entrySet()) {
                if (index >= end) {
                    break;
                }
                if (index >= begin) {
                    PartyMember pm = CrossPartyDataCache.getPartyMembers().get(entry.getValue());
                    String name = pm.getNick();
                    String serverName = GameContext.gameServerMaps.get(pm.getServerId()).getName();
                    long fight = pm.getFight();
                    int winCount = pm.getFinalWinNum();
                    if (winCount <= 0) {
                        break;
                    }
                    builder.addCpRank(PbHelper.createLianShengCpRankPb(index + 1, name, serverName, fight, winCount));
                }
                index++;
            }
            // 判断自己
            int i = 0;
            for (Entry<String, String> entry : rankMap.entrySet()) {
                if (i > 100) {
                    break;
                }
                PartyMember pm = CrossPartyDataCache.getPartyMembers().get(entry.getValue());
                if (serverId == pm.getServerId() && roleId == pm.getRoleId()) {
                    if (pm.getFinalWinNum() < 0) {
                        break;
                    }
                    int rewardState = CrossPartyConst.receive_reward_cant;
                    // 是否太浪费
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
                    if (crossPartyMemberTable != null) {
                        if (crossPartyMemberTable.getReceiveLianShengRward() == 1) {
                            rewardState = CrossPartyConst.receive_reward_haveReceive;
                        } else {
                            if (i >= 10) {
                                rewardState = CrossPartyConst.receive_reward_cant;
                            } else {
                                rewardState = CrossPartyConst.receive_reward_can;
                            }
                        }
                    }
                    builder.setMySelf(PbHelper.createCpRankPb(i + 1, rewardState));
                    break;
                }
                i++;
            }
        } else if (type == 3) {
            LinkedHashMap<String, Party> rankMap = CrossPartyDataCache.getPartys();
            int begin = page * 20;
            int end = begin + 20;
            int index = 0;
            LogUtil.error("军团排行总共的记录数" + rankMap.size() + ", 获取" + begin + "到" + end + "之间的数据");
            for (Entry<String, Party> entry : rankMap.entrySet()) {
                if (index >= end) {
                    break;
                }
                if (index >= begin) {
                    Party p = entry.getValue();
                    String partyName = p.getPartyName();
                    String serverName = GameContext.gameServerMaps.get(p.getServerId()).getName();
                    long fight = p.getFight();
                    int jifen = p.getTotalJifen();
                    if (jifen <= 0) {
                        break;
                    }
                    builder.addCpRank(PbHelper.createPartyCpRankPb(index + 1, serverName, partyName, fight, jifen));
                }
                index++;
            }
            // 判断自己
            if (pmm != null) {
                int myPartyId = pmm.getPartyId();
                String key = serverId + "_" + myPartyId;
                int i = 0;
                for (Entry<String, Party> entry : rankMap.entrySet()) {
                    if (i > 100) {
                        break;
                    }
                    Party p = entry.getValue();
                    int jifen = p.getTotalJifen();
                    if (jifen <= 0) {
                        break;
                    }
                    if (key.equals(p.getServerId() + "_" + p.getPartyId())) {
                        builder.setMySelf(PbHelper.createMyPartyCPRankPb(i + 1));
                        break;
                    }
                    i++;
                }
            }
        }
        builder.setMyJiFen(myJifen);
        handler.sendMsgToPlayer(CCGetCPRankRs.ext, builder.build());
    }

    public void receiveCPReward(CCReceiveCPRewardRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int type = rq.getType();
        int serverId = handler.getServerId();
        CCReceiveCPRewardRs.Builder builder = CCReceiveCPRewardRs.newBuilder();
        builder.setType(type);
        builder.setRoleId(roleId);
        // 判断领奖时间
        String beginTime = "16:00:00";
        // 判断当前状态
        if (TimeHelper.getDayOfCrossWar() < CrossPartyConst.STAGE.STAGE_4) {
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_RECEIVE_TIME, CCReceiveCPRewardRs.ext, builder.build());
            return;
        }
        String nowTime = TimeHelper.getNowHourAndMins();
        if (TimeHelper.getDayOfCrossWar() == CrossPartyConst.STAGE.STAGE_4 && (nowTime.compareTo(beginTime) < 0)) {
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_RECEIVE_TIME, CCReceiveCPRewardRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() > CrossPartyConst.STAGE.STAGE_5) {
            // 时间过不不能兑换
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_RECEIVE_EXCEED, CCReceiveCPRewardRs.ext, builder.build());
            return;
        }
        int rank = 0;
        if (type == 1) {
            LinkedHashMap<String, PartyMember> rankMap = CrossPartyDataCache.getPartyMembers();
            // 判断自己
            int i = 0;
            for (Entry<String, PartyMember> entry : rankMap.entrySet()) {
                if (i > 10) {
                    break;
                }
                PartyMember pm = entry.getValue();
                if (serverId == pm.getServerId() && roleId == pm.getRoleId()) {
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
                    if (crossPartyMemberTable == null || crossPartyMemberTable.getReceivePersionRward() == 1) {
                        // 已经领取
                        handler.sendMsgToPlayer(GameError.CROSS_PARTY_HAVE_RECEIVE, CCReceiveCPRewardRs.ext, builder.build());
                        return;
                    }
                    crossPartyMemberTable.setReceivePersionRward(1);
                    crossPartyMemberTableDao.update(crossPartyMemberTable);
                    rank = i + 1;
                    // 积分领取掉
                    List<List<Integer>> awards = null;
                    awards = staticWarAwardDataMgr.getServerPartyPersonAward(rank);
                    addAwardsBackPb(pm, awards, AwardFrom.CP_PER_RANK_AWARD);
                    break;
                }
                i++;
            }
        } else if (type == 2) {
            LinkedHashMap<String, String> rankMap = CrossPartyDataCache.getLianShengRank();
            // 判断自己
            int i = 0;
            for (Entry<String, String> entry : rankMap.entrySet()) {
                if (i > 10) {
                    break;
                }
                PartyMember pm = CrossPartyDataCache.getPartyMembers().get(entry.getValue());
                if (serverId == pm.getServerId() && roleId == pm.getRoleId()) {
                    CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
                    if (crossPartyMemberTable == null || crossPartyMemberTable.getReceiveLianShengRward() == 1) {
                        // 已经领取
                        handler.sendMsgToPlayer(GameError.CROSS_PARTY_HAVE_RECEIVE, CCReceiveCPRewardRs.ext, builder.build());
                        return;
                    }
                    crossPartyMemberTable.setReceiveLianShengRward(1);
                    crossPartyMemberTableDao.update(crossPartyMemberTable);
                    rank = i + 1;
                    // 积分领取掉
                    List<List<Integer>> awards = null;
                    awards = staticWarAwardDataMgr.getServerPartyWinAward(rank);
                    addAwardsBackPb(pm, awards, AwardFrom.CP_LIANSHENG_RANK_AWARD);
                    break;
                }
                i++;
            }
        }
        if (rank == 0) {
            // 没有排名
            handler.sendMsgToPlayer(GameError.CROSS_PARTY_NO_RANK, CCReceiveCPRewardRs.ext, builder.build());
            return;
        } else {
            builder.setRank(rank);
            handler.sendMsgToPlayer(CCReceiveCPRewardRs.ext, builder.build());
        }
    }

    public void getCPMyRegInfo(CCGetCPMyRegInfoRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        int partyId = rq.getPartyId();
        CCGetCPMyRegInfoRs.Builder builder = CCGetCPMyRegInfoRs.newBuilder();
        boolean ret = false;
        Party p = CrossPartyDataCache.getPartys().get(serverId + "_" + partyId);
        if (p != null) {
            PartyMember pm = p.getMember(roleId);
            if (pm != null) {
                ret = true;
            }
        }
        builder.setRoleId(roleId);
        builder.setIsReg(ret);
        handler.sendMsgToPlayer(CCGetCPMyRegInfoRs.ext, builder.build());
    }

    public void gMSetCPForm(CCGMSetCPFormRq rq, ClientHandler handler) {
        int type = rq.getType();
        int serverId = handler.getServerId();
        // 0给所有玩家设置
        // 1给本服玩家设置
        Iterator<PartyMember> its = CrossPartyDataCache.getPartyMembers().values().iterator();
        while (its.hasNext()) {
            PartyMember p = its.next();
            if (type == 1 && p.getServerId() == serverId) {
                Form form = new Form();
                form.setCommander(339);
                form.setType(FormType.Cross1);
                form.p[0] = 1;
                form.c[0] = 1;
                p.setForm(form);
                p.setInstForm(new Form(form));
                crossPartyDataManager.caluPartyFight(p.getServerId(), p.getPartyId());
            } else if (type == 0) {
                Form form = new Form();
                form.setCommander(339);
                form.setType(FormType.Cross1);
                form.p[0] = 1;
                form.c[0] = 1;
                p.setForm(form);
                p.setInstForm(new Form(form));
                crossPartyDataManager.caluPartyFight(p.getServerId(), p.getPartyId());
            }
            CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(p.getRoleId());
            byte[] bytes = crossPartyMemberTable.serPartyMembers(p);
            crossPartyMemberTable.setMemberInfo(bytes);
            crossPartyMemberTableDao.update(crossPartyMemberTable);
        }
    }

    /**
     * Method: addAwardAndBack @Description: 只领取积分 from @return @return List<Award> @throws
     */
    public List<Award> addAwardsBackPb(PartyMember player, List<List<Integer>> drop, AwardFrom from) {
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

    public int addAward(PartyMember player, int type, int id, long count, AwardFrom from) {
        switch (type) {
            case AwardType.CROSS_JIFEN:
                addCPJiFen(player, (int) count, from);
                break;
            default:
                break;
        }
        return 0;
    }

    public void addCPJiFen(PartyMember player, int count, AwardFrom from) {
        player.setJifenjiangli(player.getJifenjiangli() + count);
    }

    public void getCPShop(CCGetCPShopRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        String key = serverId + "_" + roleId;
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(key);
        int jifen = 0;
        if (pm != null) {
            jifen = pm.getJifen() + pm.getJifenjiangli() - pm.getExchangeJifen();
        }
        CCGetCPShopRs.Builder builder = CCGetCPShopRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setJifen(jifen);
        if (pm != null) {
            for (CrossShopBuy buy : pm.crossShopBuy.values()) { // 普通商品记录
                builder.addBuy(PbHelper.createCrossShopBuyPb(buy));
            }
        }
        handler.sendMsgToPlayer(CCGetCPShopRs.ext, builder.build());
    }

    public void exchangeCPShop(CCExchangeCPShopRq req, ClientHandler handler) {
        long roleId = req.getRoleId();
        int shopId = req.getShopId();
        int count = req.getCount();
        int serverId = handler.getServerId();
        String key = serverId + "_" + roleId;
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(key);
        int jifen = 0;
        if (pm != null) {
            jifen = pm.getJifen() + pm.getJifenjiangli() - pm.getExchangeJifen();
        }
        CCExchangeCPShopRs.Builder builder = CCExchangeCPShopRs.newBuilder();
        String nowTime = TimeHelper.getNowHourAndMins();
        String beginTime = "16:00:00";
        builder.setRoleId(roleId);
        builder.setShopId(shopId);
        // 检查玩家积分是否足够
        builder.setJifen(jifen);
        // 判断当前状态
        if (TimeHelper.getDayOfCrossWar() < CrossPartyConst.STAGE.STAGE_4) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() == CrossPartyConst.STAGE.STAGE_4 && (nowTime.compareTo(beginTime) < 0)) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_TIME, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        if (TimeHelper.getDayOfCrossWar() > CrossPartyConst.STAGE.STAGE_5) {
            // 时间过不不能兑换
            handler.sendMsgToPlayer(GameError.CROSS_CAN_NOT_EXCHANGE_CASE_TIME, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        // 检查shopId是否正确
        StaticCrossShop shop = staticCrossDataMgr.getStaticCrossShopById(shopId);
        if (null == shop) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_FOUND, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        if (shop.getType() != 2) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_FOUND, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        int cost = shop.getCost() * count;
        if (null == pm || (jifen < cost)) {
            handler.sendMsgToPlayer(GameError.CROSS_JIFEN_NOT_ENOUGH, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        // 检查购买数量是否合法
        if (count < 1 || count > Integer.MAX_VALUE) {
            handler.sendMsgToPlayer(GameError.INVALID_PARAM, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        CrossShopBuy csb = pm.crossShopBuy.get(shopId);
        if (null == csb) {
            csb = new CrossShopBuy();
            csb.setShopId(shopId);
            csb.setBuyNum(0);
            pm.crossShopBuy.put(shopId, csb);
        }
        // 检查剩余数量是否足够
        if ((csb.getBuyNum() + count) > shop.getPersonNumber()) {
            handler.sendMsgToPlayer(GameError.CROSS_SHOP_NOT_ENOUGH, CCExchangeCPShopRs.ext, builder.build());
            return;
        }
        // 更新玩家的积分
        pm.setExchangeJifen(pm.getExchangeJifen() + cost);
        // 更新玩家购买次数
        csb = pm.crossShopBuy.get(shopId);
        csb.setBuyNum(csb.getBuyNum() + count);
        jifen = pm.getJifen() + pm.getJifenjiangli() - pm.getExchangeJifen();
        builder.setJifen(jifen);
        builder.setCount(count);
        builder.setRestNum(0);
        handler.sendMsgToPlayer(CCExchangeCPShopRs.ext, builder.build());
        // 记录玩家积分详情
        CrossTrendHelper.addCrossTrend(pm, CrossConst.TREND.SHOP_EXCHANGE, shop.getGoodName(), String.valueOf(cost));
        CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
        byte[] bytes = crossPartyMemberTable.serPartyMembers(pm);
        crossPartyMemberTable.setMemberInfo(bytes);
        crossPartyMemberTableDao.update(crossPartyMemberTable);
        LogUtil.error(pm.getNick() + " 兑换商品 " + shop.getGoodName() + " 消耗积分 " + cost + ",剩余积分:" + jifen);
    }

    public void getCPTrend(CCGetCPTrendRq rq, ClientHandler handler) {
        long roleId = rq.getRoleId();
        int serverId = handler.getServerId();
        String key = serverId + "_" + roleId;
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(key);
        int jifen = 0;
        if (pm != null) {
            jifen = pm.getJifen() + pm.getJifenjiangli() - pm.getExchangeJifen();
        }
        CCGetCPTrendRs.Builder builder = CCGetCPTrendRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setJifen(jifen);
        if (pm != null) {
            for (CrossTrend ct : pm.crossTrends) {
                builder.addCrossTrend(PbHelper.createCrossTrendPb(ct));
            }
        }
        handler.sendMsgToPlayer(CCGetCPTrendRs.ext, builder.build());
    }

    private void sendCPPush(int serverId, int state) {
        CCSynCrossPartyStateRq.Builder builder = CCSynCrossPartyStateRq.newBuilder();
        builder.setState(state);
        Base.Builder msg = PbHelper.createSynBase(CCSynCrossPartyStateRq.EXT_FIELD_NUMBER, CCSynCrossPartyStateRq.ext, builder.build());
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

    public void synCpFame() {
        CCSynCrossFameRq.Builder builder = CCSynCrossFameRq.newBuilder();
        String beginTime = DateHelper.formatDateTime(GameContext.CROSS_BEGIN_DATA, DateHelper.format2);
        String endTime = DateHelper.formatDateTime(DateHelper.someDayAfter(GameContext.CROSS_BEGIN_DATA, 4), DateHelper.format2);
        builder.setBeginTime(beginTime);
        builder.setEndTime(endTime);
        builder.setType(2);
        // 获取冠军军团
        Party p = getTopParty(1);
        if (p != null) {
            builder.addCpFame(getCPFamePb(CrossPartyConst.CP_FAME_TYPE.top1, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getPartyName(), p.getMyPartySirPortrait()));
        }
        p = getTopParty(2);
        if (p != null) {
            builder.addCpFame(getCPFamePb(CrossPartyConst.CP_FAME_TYPE.top2, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getPartyName(), p.getMyPartySirPortrait()));
        }
        p = getTopParty(3);
        if (p != null) {
            builder.addCpFame(getCPFamePb(CrossPartyConst.CP_FAME_TYPE.top3, GameContext.gameServerMaps.get(p.getServerId()).getName(), p.getPartyName(), p.getMyPartySirPortrait()));
        }
        PartyMember pm = getTop1RankMember();
        if (pm != null) {
            builder.addCpFame(getCPFamePb(CrossPartyConst.CP_FAME_TYPE.jifenTop1, GameContext.gameServerMaps.get(pm.getServerId()).getName(), pm.getNick(), pm.getPortrait()));
        }
        pm = getTop1LianshengRankMember();
        if (pm != null) {
            builder.addCpFame(getCPFamePb(CrossPartyConst.CP_FAME_TYPE.lianshengTop1, GameContext.gameServerMaps.get(pm.getServerId()).getName(), pm.getNick(), pm.getPortrait()));
        }
        Base.Builder msg = PbHelper.createSynBase(CCSynCrossFameRq.EXT_FIELD_NUMBER, CCSynCrossFameRq.ext, builder.build());
        for (Server server : GameContext.getGameServerConfig().getList()) {
            if (server.isConect()) {
                GameContext.synMsgToPlayer(server.ctx, msg);
            }
        }
    }

    private CPFame getCPFamePb(int type, String serverName, String name, int portrait) {
        CPFame.Builder builder = CPFame.newBuilder();
        builder.setType(type);
        builder.setServerName(serverName);
        builder.setName(name);
        builder.setPortrait(portrait);
        return builder.build();
    }

    public void canQuitParty(CCCanQuitPartyRq rq, ClientHandler handler) {
        int serverId = handler.getServerId();
        long roleId = rq.getRoleId();
        int type = rq.getType();
        boolean isFlag = false;
        if (type == 1) {
            isFlag = crossPartyDataManager.isReg(serverId, roleId);
        } else if (type == 2 && rq.hasCleanRoleId()) {
            isFlag = crossPartyDataManager.isReg(serverId, rq.getCleanRoleId());
        }
        CCCanQuitPartyRs.Builder builder = CCCanQuitPartyRs.newBuilder();
        builder.setRoleId(roleId);
        builder.setIsReg(isFlag);
        builder.setType(type);
        if (rq.hasCleanRoleId()) {
            builder.setCleanRoleId(rq.getCleanRoleId());
        }
        handler.sendMsgToPlayer(CCCanQuitPartyRs.ext, builder.build());
    }

    public void gMAddJifen(int serverId, long roleId, int addJifen) {
        PartyMember pm = CrossPartyDataCache.getPartyMembers().get(serverId + "_" + roleId);
        if (pm != null) {
            pm.setJifen(pm.getJifen() + addJifen);
            LogUtil.error(pm.getNick() + " gm命令增加积分 " + addJifen);
            sortMapByJifen(CrossPartyDataCache.getPartyMembers());
            CrossPartyMemberTable crossPartyMemberTable = crossPartyMemberTableDao.get(roleId);
            byte[] bytes = crossPartyMemberTable.serPartyMembers(pm);
            crossPartyMemberTable.setMemberInfo(bytes);
            crossPartyMemberTableDao.update(crossPartyMemberTable);
        }
    }
}