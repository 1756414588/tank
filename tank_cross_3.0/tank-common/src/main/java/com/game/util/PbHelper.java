package com.game.util;

import com.game.constant.CrossConst;
import com.game.constant.GameError;
import com.game.cross.domain.Athlete;
import com.game.cross.domain.*;
import com.game.cross.domain.CompteRound;
import com.game.cross.domain.CrossShopBuy;
import com.game.cross.domain.CrossTrend;
import com.game.cross.domain.JiFenPlayer;
import com.game.cross.domain.KnockoutBattleGroup;
import com.game.crossParty.domain.GroupParty;
import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.PartyMember;
import com.game.crossParty.domain.ServerSisuation;
import com.game.domain.CrossPlayer;
import com.game.domain.PEnergyCore;
import com.game.domain.p.*;
import com.game.domain.p.Army;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Collect;
import com.game.domain.p.Effect;
import com.game.domain.p.EnergyStoneInlay;
import com.game.domain.p.Equip;
import com.game.domain.p.Form;
import com.game.domain.p.Grab;
import com.game.domain.p.Medal;
import com.game.domain.p.MedalBouns;
import com.game.domain.p.MilitaryScience;
import com.game.domain.p.MilitaryScienceGrid;
import com.game.domain.p.Part;
import com.game.domain.p.RptTank;
import com.game.domain.p.Science;
import com.game.domain.p.SecretWeapon;
import com.game.domain.p.SecretWeaponBar;
import com.game.domain.s.StaticActPartResolve;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.*;
import com.game.pb.CommonPb.ComptePojo;
import com.game.pb.CommonPb.MyBet;
import com.game.server.GameContext;
import com.game.server.config.gameServer.Server;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;
import java.util.Map.Entry;

public class PbHelper {
    public static byte[] putShort(short s) {
        byte[] b = new byte[2];
        b[0] = (byte) (s >> 8);
        b[1] = (byte) (s >> 0);
        return b;
    }

    public static short getShort(byte[] b, int index) {
        return (short) (((b[index + 1] & 0xff) | b[index + 0] << 8));
    }

    public static Base parseFromByte(byte[] result) throws InvalidProtocolBufferException {
        short len = PbHelper.getShort(result, 0);
        byte[] data = new byte[len];
        System.arraycopy(result, 2, data, 0, len);
        Base rs = Base.parseFrom(data, GameContext.registry);
        return rs;
    }

    public static <T> Base.Builder createRsBase(int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setExtension(ext, msg);
        return baseBuilder;
    }

    public static <T> Base.Builder createRsBase(
            GameError gameError, int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setCode(gameError.getCode());
        if (msg != null) {
            baseBuilder.setExtension(ext, msg);
        }

        return baseBuilder;
    }

    public static Base createRsBase(int cmd, int code) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setCode(code);
        return baseBuilder.build();
    }

    public static <T> Base.Builder createRqBase(
            int cmd, Long param, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        if (param != null) {
            baseBuilder.setParam(param);
        }
        baseBuilder.setExtension(ext, msg);
        return baseBuilder;
    }

    public static TwoInt createTwoIntPb(int p, int c) {
        TwoInt.Builder builder = TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }


    public static CommonPb.Form createFormPb(Form form) {
        CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }

        if (form.getAwakenHero() != null) {
            builder.setAwakenHero(createAwakenHeroPb(form.getAwakenHero()));
        }

        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }

        v = form.p[0];
        if (v != 0) {
            builder.setP1(createTwoIntPb(v, form.c[0]));
        }

        v = form.p[1];
        if (v != 0) {
            builder.setP2(createTwoIntPb(v, form.c[1]));
        }

        v = form.p[2];
        if (v != 0) {
            builder.setP3(createTwoIntPb(v, form.c[2]));
        }

        v = form.p[3];
        if (v != 0) {
            builder.setP4(createTwoIntPb(v, form.c[3]));
        }

        v = form.p[4];
        if (v != 0) {
            builder.setP5(createTwoIntPb(v, form.c[4]));
        }

        v = form.p[5];
        if (v != 0) {
            builder.setP6(createTwoIntPb(v, form.c[5]));
        }

        if (form.getTacticsKeyId() != null && !form.getTacticsKeyId().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTacticsKeyId());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createTwoIntPb(e.getKey(), e.getValue()));
            }
        }

        return builder.build();
    }


    public static Form createForm(CommonPb.Form form) {
        Form e = new Form();
        e.setType(form.getType());

        if (form.hasAwakenHero()) {
            e.setAwakenHero(new AwakenHero(form.getAwakenHero()));
        }

        if (form.hasCommander()) {
            e.setCommander(form.getCommander());
        }

        if (form.hasP1()) {
            TwoInt p = form.getP1();
            e.p[0] = p.getV1();
            e.c[0] = p.getV2();
        }

        if (form.hasP2()) {
            TwoInt p = form.getP2();
            e.p[1] = p.getV1();
            e.c[1] = p.getV2();
        }

        if (form.hasP3()) {
            TwoInt p = form.getP3();
            e.p[2] = p.getV1();
            e.c[2] = p.getV2();
        }

        if (form.hasP4()) {
            TwoInt p = form.getP4();
            e.p[3] = p.getV1();
            e.c[3] = p.getV2();
        }

        if (form.hasP5()) {
            TwoInt p = form.getP5();
            e.p[4] = p.getV1();
            e.c[4] = p.getV2();
        }

        if (form.hasP6()) {
            TwoInt p = form.getP6();
            e.p[5] = p.getV1();
            e.c[5] = p.getV2();
        }

        e.setTacticsKeyId(new ArrayList<Integer>(form.getTacticsKeyIdList()));

        List<TwoInt> tacticsList = form.getTacticsList();
        for (TwoInt t : tacticsList) {
            e.getTacticsList().add(new TowInt(t.getV1(), t.getV2()));
        }
        return e;
    }


    static public Form createForm(List<List<Integer>> tanks) {
        Form form = new Form();
        List<Integer> one;
        for (int i = 0; i < tanks.size() && i < 6; i++) {
            one = tanks.get(i);
            if (one.isEmpty())
                continue;
            form.p[i] = one.get(0);
            form.c[i] = one.get(1);
        }

        return form;
    }


    public static CommonPb.Equip createEquipPb(Equip equip) {
        CommonPb.Equip.Builder builder = CommonPb.Equip.newBuilder();
        builder.setKeyId(equip.getKeyId());
        builder.setEquipId(equip.getEquipId());
        builder.setLv(equip.getLv());
        builder.setExp(equip.getExp());
        builder.setPos(equip.getPos());
        builder.setStarLv(equip.getStarlv());
        return builder.build();
    }

    public static Equip createEquip(CommonPb.Equip equip) {
        Equip equip1 =
                new Equip(
                        equip.getKeyId(), equip.getEquipId(), equip.getLv(), equip.getExp(), equip.getPos());
        equip1.setStarlv(equip.getStarLv());
        return equip1;
    }

    public static CommonPb.Part createPartPb(Part part) {
        CommonPb.Part.Builder builder = CommonPb.Part.newBuilder();
        builder.setKeyId(part.getKeyId());
        builder.setPartId(part.getPartId());
        builder.setUpLv(part.getUpLv());
        builder.setRefitLv(part.getRefitLv());
        builder.setPos(part.getPos());
        builder.setLocked(part.isLocked());
        builder.setSmeltLv(part.getSmeltLv());
        builder.setSmeltExp(part.getSmeltExp());
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            PartSmeltAttr.Builder attr = PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        builder.setSaved(part.isSaved());
        return builder.build();
    }

    public static CommonPb.Science createSciencePb(Science science) {
        CommonPb.Science.Builder builder = CommonPb.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        return builder.build();
    }

    public static Science createScience(CommonPb.Science science) {
        return new Science(science.getScienceId(), science.getScienceLv());
    }

    public static CommonPb.Science createPartySciencePb(PartyScience science) {
        CommonPb.Science.Builder builder = CommonPb.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        builder.setSchedule(science.getSchedule());
        return builder.build();
    }


    /**
     * Method: createAwardPb @Description: 无keyId的奖励 @param type @param id @param
     * count @return @return CommonPb.Award @throws
     */
    public static CommonPb.Award createAwardPb(int type, int id, int count) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        return builder.build();
    }

    /**
     * Method: createAwardPb @Description: 有keyId的奖励 @param type @param id @param count @param
     * keyId @return @return CommonPb.Award @throws
     */
    public static CommonPb.Award createAwardPb(int type, int id, long count, int keyId) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        if (keyId != 0) {
            builder.setKeyId(keyId);
        }

        return builder.build();
    }


    public static Skill createSkillPb(int skillId, int lv) {
        Skill.Builder builder = Skill.newBuilder();
        builder.setId(skillId);
        builder.setLv(lv);
        return builder.build();
    }

    public static CommonPb.Effect createEffectPb(Effect effect) {
        CommonPb.Effect.Builder builder = CommonPb.Effect.newBuilder();
        builder.setId(effect.getEffectId());
        builder.setEndTime(effect.getEndTime());
        return builder.build();
    }

    public static Effect createEffect(CommonPb.Effect effect) {
        return new Effect(effect.getId(), effect.getEndTime());
    }

    public static Man createManPb(Man man) {
        Man.Builder builder = Man.newBuilder();
        builder.setLordId(man.getLordId());
        int icon = man.getIcon();
        int sex = man.getSex();
        String nick = man.getNick();
        int level = man.getLevel();
        long fight = man.getFight();
        int ranks = man.getRanks();
        int exp = man.getExp();
        int pos = man.getPos();
        int vip = man.getVip();
        int honour = man.getHonour();
        int pros = man.getPros();
        int prosMax = man.getProsMax();
        String partyName = man.getPartyName();
        int jobId = man.getJobId();
        if (icon != 0) {
            builder.setIcon(icon);
        }
        if (sex != 0) {
            builder.setSex(sex);
        }
        if (nick != null) {
            builder.setNick(nick);
        }
        if (level != 0) {
            builder.setLevel(level);
        }
        if (fight != 0) {
            builder.setFight(fight);
        }
        if (ranks != 0) {
            builder.setRanks(ranks);
        }
        if (exp != 0) {
            builder.setExp(exp);
        }
        if (pos != 0) {
            builder.setPos(pos);
        }
        if (vip != -1) {
            builder.setVip(vip);
        }
        if (honour != -1) {
            builder.setHonour(honour);
        }
        if (pros != -1) {
            builder.setPros(pros);
        }
        if (prosMax != 0) {
            builder.setProsMax(prosMax);
        }
        if (partyName != null) {
            builder.setPartyName(partyName);
        }
        if (jobId != 0) {
            builder.setJobId(jobId);
        }
        return builder.build();
    }


    public static <T> Base.Builder createSynBase(int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        if (msg != null) {
            baseBuilder.setExtension(ext, msg);
        }

        return baseBuilder;
    }


    public static CommonPb.MilitaryScience createMilitaryScienecePb(
            MilitaryScience militaryScienece) {
        CommonPb.MilitaryScience.Builder builder = CommonPb.MilitaryScience.newBuilder();
        builder.setMilitaryScienceId(militaryScienece.getMilitaryScienceId());
        builder.setLevel(militaryScienece.getLevel());
        builder.setFitTankId(militaryScienece.getFitTankId());
        builder.setFitPos(militaryScienece.getFitPos());
        return builder.build();
    }

    public static MilitaryScience createMilitaryScienece(CommonPb.MilitaryScience m) {
        return new MilitaryScience(
                m.getMilitaryScienceId(), m.getLevel(), m.getFitTankId(), m.getFitPos());
    }

    public static CommonPb.MilitaryScienceGrid createMilitaryScieneceGridPb(
            MilitaryScienceGrid militaryScieneceGrid) {
        CommonPb.MilitaryScienceGrid.Builder builder = CommonPb.MilitaryScienceGrid.newBuilder();
        builder.setTankId(militaryScieneceGrid.getTankId());
        builder.setPos(militaryScieneceGrid.getPos());
        builder.setStatus(militaryScieneceGrid.getStatus());
        builder.setMilitaryScienceId(militaryScieneceGrid.getMilitaryScienceId());
        return builder.build();
    }


    public static MilitaryScienceGrid createMilitaryScieneceGrid(CommonPb.MilitaryScienceGrid m) {
        return new MilitaryScienceGrid(
                m.getTankId(), m.getPos(), m.getStatus(), m.getMilitaryScienceId());
    }

    public static MilitaryMaterial createMilitaryMaterialPb(
            MilitaryMaterial militaryMaterial) {
        MilitaryMaterial.Builder builder = MilitaryMaterial.newBuilder();
        builder.setId(militaryMaterial.getId());
        builder.setCount(militaryMaterial.getCount());
        return builder.build();
    }

    public static PartResolve createPartResolvePb(
            StaticActPartResolve staticActPartResolve) {
        PartResolve.Builder builder = PartResolve.newBuilder();
        builder.setResolveId(staticActPartResolve.getResolveId());
        builder.setCount(staticActPartResolve.getSlug());
        List<List<Integer>> awardList = staticActPartResolve.getAwardList();
        for (List<Integer> e : awardList) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.setAward(PbHelper.createAwardPb(type, id, count));
        }
        return builder.build();
    }


    public static CommonPb.EnergyStoneInlay createEnergyStoneInlayPb(EnergyStoneInlay inlay) {
        CommonPb.EnergyStoneInlay.Builder builder = CommonPb.EnergyStoneInlay.newBuilder();
        builder.setHole(inlay.getHole());
        builder.setStoneId(inlay.getStoneId());
        builder.setPos(inlay.getPos());
        return builder.build();
    }

    public static EnergyStoneInlay createEnergyStoneInlay(CommonPb.EnergyStoneInlay inlay) {
        return new EnergyStoneInlay(inlay.getPos(), inlay.getHole(), inlay.getStoneId());
    }


    public static GameServerInfo createGameServerInfoPb(
            Server server) {
        GameServerInfo.Builder builder = GameServerInfo.newBuilder();
        builder.setServerName(server.getName());
        builder.setServerId(server.getId());
        return builder.build();
    }


    public static com.game.pb.CommonPb.Athlete crateAthletePb(Athlete athlete) {
        com.game.pb.CommonPb.Athlete.Builder builder = com.game.pb.CommonPb.Athlete.newBuilder();
        builder.setNick(athlete.getNick());
        builder.setServerId(athlete.getServerId());
        builder.setRoleId(athlete.getRoleId());
        builder.setGroupId(athlete.getGroupId());
        builder.setFight(athlete.getFight());
        builder.setWinNum(athlete.getWinNum());
        builder.setFailNum(athlete.getFailNum());
        builder.setPortrait(athlete.getPortrait());

        builder.setLevel(athlete.getLevel());
        if (athlete.getPartyName() != null) {
            builder.setPartyName(athlete.getPartyName());
        }

        builder.addAllMyReportKeys(athlete.getMyReportKeys());
        Iterator<com.game.domain.p.Form> its = athlete.forms.values().iterator();
        while (its.hasNext()) {
            builder.addForm(createFormPb(its.next()));
        }

        Iterator<HashMap<Integer, Equip>> itequips = athlete.equips.values().iterator();
        while (itequips.hasNext()) {
            HashMap<Integer, Equip> map = itequips.next();
            Iterator<Equip> iiequips = map.values().iterator();
            while (iiequips.hasNext()) {
                builder.addEquip(createEquipPb(iiequips.next()));
            }
        }

        Iterator<HashMap<Integer, Part>> itParts = athlete.parts.values().iterator();
        while (itParts.hasNext()) {
            HashMap<Integer, Part> map = itParts.next();
            Iterator<Part> iiparts = map.values().iterator();
            while (iiparts.hasNext()) {
                builder.addPart(createPartPb(iiparts.next()));
            }
        }

        Iterator<Science> itscce = athlete.sciences.values().iterator();
        while (itscce.hasNext()) {
            builder.addScience(createSciencePb(itscce.next()));
        }
        Set<Integer> keySet = athlete.skills.keySet();
        for (Integer key : keySet) {
            int value = athlete.skills.get(key);
            builder.addSkill(createSkillPb(key, value));
        }

        Iterator<Effect> ieffect = athlete.effects.values().iterator();
        while (ieffect.hasNext()) {
            builder.addEffect(createEffectPb(ieffect.next()));
        }

        builder.setStaffingId(athlete.StaffingId);

        Iterator<Map<Integer, EnergyStoneInlay>> ite = athlete.energyInlay.values().iterator();
        while (ite.hasNext()) {
            Map<Integer, EnergyStoneInlay> map = ite.next();
            Iterator<EnergyStoneInlay> iimap = map.values().iterator();
            while (iimap.hasNext()) {
                builder.addInlay(createEnergyStoneInlayPb(iimap.next()));
            }
        }

        Iterator<MilitaryScience> itm = athlete.militarySciences.values().iterator();
        while (itm.hasNext()) {
            builder.addMilitaryScience(createMilitaryScienecePb(itm.next()));
        }

        Iterator<HashMap<Integer, MilitaryScienceGrid>> itmsc =
                athlete.militaryScienceGrids.values().iterator();
        while (itmsc.hasNext()) {
            HashMap<Integer, MilitaryScienceGrid> map = itmsc.next();
            Iterator<MilitaryScienceGrid> itmap = map.values().iterator();
            while (itmap.hasNext()) {
                builder.addMilitaryScienceGrid(createMilitaryScieneceGridPb(itmap.next()));
            }
        }

        Iterator<HashMap<Integer, Medal>> medalsits = athlete.medals.values().iterator();
        while (medalsits.hasNext()) {
            HashMap<Integer, Medal> map = medalsits.next();
            Iterator<Medal> iits = map.values().iterator();
            while (iits.hasNext()) {
                builder.addMedal(createMedalPb(iits.next()));
            }
        }

        Iterator<HashMap<Integer, MedalBouns>> mbs = athlete.medalBounss.values().iterator();
        while (mbs.hasNext()) {
            HashMap<Integer, MedalBouns> map = mbs.next();
            Iterator<MedalBouns> iits = map.values().iterator();
            while (iits.hasNext()) {
                builder.addMedalBouns(createMedalBounsPb(iits.next()));
            }
        }

        // 觉醒将领
        for (AwakenHero awakenHero : athlete.awakenHeros.values()) {
            builder.addAwakenHero(PbHelper.createAwakenHeroPb(awakenHero));
        }

        // 军备
        for (Entry<Integer, com.game.domain.p.lordequip.LordEquip> entry : athlete.lordEquips.entrySet()) {
            builder.addLeq(createLordEquip(entry.getValue()));
        }

        // 军衔
        builder.setMilitaryRank(athlete.militaryRank);

        // 秘密武器
        for (Entry<Integer, SecretWeapon> entry : athlete.secretWeaponMap.entrySet()) {
            builder.addSecretWeapon(createSecretWeapon(entry.getValue()));
        }

        // 攻击特效
        for (Entry<Integer, AttackEffect> entry : athlete.atkEffects.entrySet()) {
            builder.addAtkEft(PbHelper.createAttackEffectPb(entry.getValue()));
        }

        // 作战实验室科技树
        if (!athlete.graduateInfo.isEmpty()) {
            builder.addAllGraduateInfo(PbHelper.createGraduateInfoPb(athlete.graduateInfo));
        }

        if (!athlete.partyScienceMap.isEmpty()) {
            Collection<PartyScience> partySciences = athlete.partyScienceMap.values();
            for (PartyScience partyScience : partySciences) {
                builder.addPartyScience(PbHelper.createPartySciencePb(partyScience));
            }
        }
        PEnergyCore pEnergyCore = athlete.getpEnergyCore();
        builder.setEnergyCore(PbHelper.createThreeIntPb(pEnergyCore.getLevel(),pEnergyCore.getSection(),pEnergyCore.getState()));
        return builder.build();
    }

    /**
     * 创建ThreeInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CommonPb.ThreeInt createThreeIntPb(int p, int c,int s) {
        ThreeInt.Builder builder = ThreeInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        builder.setV3(s);
        return builder.build();
    }


    public static CommonPb.MedalBouns createMedalBounsPb(MedalBouns medalBouns) {
        CommonPb.MedalBouns.Builder builder = CommonPb.MedalBouns.newBuilder();
        builder.setMedalId(medalBouns.getMedalId());
        builder.setState(medalBouns.getState());
        return builder.build();
    }

    public static CommonPb.Medal createMedalPb(Medal medal) {
        CommonPb.Medal.Builder builder = CommonPb.Medal.newBuilder();
        builder.setKeyId(medal.getKeyId());
        builder.setMedalId(medal.getMedalId());
        builder.setUpLv(medal.getUpLv());
        builder.setUpExp(medal.getUpExp());
        builder.setRefitLv(medal.getRefitLv());
        builder.setPos(medal.getPos());
        builder.setLocked(medal.isLocked());
        return builder.build();
    }

    public static CrossRptAtk createCrossRptAtk(
            int reportKey,
            int result,
            int detail,
            boolean attackerIsFirst,
            CrossRptMan attacker,
            CrossRptMan defencer,
            Record record) {
        CrossRptAtk.Builder builder =
                CrossRptAtk.newBuilder();
        builder.setReportKey(reportKey);
        builder.setResult(result);
        builder.setDetail(detail);
        builder.setFirst(attackerIsFirst);
        builder.setAttacker(attacker);
        if (defencer != null) {
            builder.setDefencer(defencer);
        }
        if (record != null) {
            builder.setRecord(record);
        }

        return builder.build();
    }

    public static CrossRecord createCrossRecrod(
            int reportKey,
            String attackServerName,
            String attackName,
            int hp1,
            String defencerServerName,
            String defencerName,
            int hp2,
            int result,
            int time,
            int detail) {
        CrossRecord.Builder builder = CrossRecord.newBuilder();
        builder.setReportKey(reportKey);

        if (attackServerName != null) {
            builder.setServerName1(attackServerName);
        }
        if (attackName != null) {
            builder.setName1(attackName);
        }
        builder.setHp1(hp1);
        if (defencerServerName != null) {
            builder.setServerName2(defencerServerName);
        }
        if (defencerName != null) {
            builder.setName2(defencerName);
        }
        builder.setHp2(hp2);
        builder.setResult(result);
        builder.setTime(time);
        builder.setDetail(detail);
        return builder.build();
    }

    public static CrossJiFenRank createCrossJiFenRankPb(
            int rank, String serverName, String name, int winNum, int failNum, int jifen, int myGroup) {
        CrossJiFenRank.Builder builder = CrossJiFenRank.newBuilder();
        builder.setRank(rank);
        builder.setServerName(serverName);
        builder.setName(name);
        builder.setWinNum(winNum);
        builder.setFailNum(failNum);
        builder.setJifen(jifen);
        builder.setMyGroup(myGroup);
        return builder.build();
    }

    public static KnockoutCompetGroup createKnockoutCompetGroupPb(CompetGroup c) {
        KnockoutCompetGroup.Builder builder = KnockoutCompetGroup.newBuilder();
        builder.setCompetGroupId(c.getCompetGroupId());
        if (c.getC1() != null) {
            builder.setC1(createComptePojoPb(c.getC1()));
        }
        if (c.getC2() != null) {
            builder.setC2(createComptePojoPb(c.getC2()));
        }

        builder.setWin(c.getWin());
        if (c.getMap().size() > 0) {
            Iterator<CompteRound> its = c.getMap().values().iterator();
            while (its.hasNext()) {
                builder.addCompteRound(createCompteRoundPb(its.next()));
            }
        }

        return builder.build();
    }

    public static KnockoutCompetGroup createKnockoutCompetGroupPb(
            CompetGroup c, com.game.cross.domain.ComptePojo c1, com.game.cross.domain.ComptePojo c2) {
        KnockoutCompetGroup.Builder builder = KnockoutCompetGroup.newBuilder();
        builder.setCompetGroupId(c.getCompetGroupId());
        if (c.getC1() != null) {
            builder.setC1(createComptePojoPb(c1, c.getC1()));
        }
        if (c.getC2() != null) {
            builder.setC2(createComptePojoPb(c2, c.getC2()));
        }

        builder.setWin(c.getWin());
        if (c.getMap().size() > 0) {
            Iterator<CompteRound> its = c.getMap().values().iterator();
            while (its.hasNext()) {
                builder.addCompteRound(createCompteRoundPb(its.next()));
            }
        }

        return builder.build();
    }

    private static CommonPb.CompteRound createCompteRoundPb(CompteRound c) {
        CommonPb.CompteRound.Builder builder =
                CommonPb.CompteRound.newBuilder();
        builder.setRoundNum(c.getRoundNum());
        builder.setWin(c.getWin());
        builder.setReportKey(c.getReportKey());
        builder.setDetail(c.getDetail());
        return builder.build();
    }

    private static ComptePojo createComptePojoPb(com.game.cross.domain.ComptePojo c1) {
        ComptePojo.Builder builder = ComptePojo.newBuilder();
        builder.setPos(c1.getPos());
        builder.setServerId(c1.getServerId());
        builder.setRoleId(c1.getRoleId());
        builder.setNick(c1.getNick());
        builder.setBet(c1.getBet());
        builder.setMyBetNum(c1.getMyBetNum());
        builder.setServerName(c1.getServerName());
        builder.setFight(c1.getFight());
        builder.setPortrait(c1.getPortrait());
        builder.setLevel(c1.getLevel());
        if (c1.getPartyName() != null) {
            builder.setPartyName(c1.getPartyName());
        }
        return builder.build();
    }

    private static ComptePojo createComptePojoPb(
            com.game.cross.domain.ComptePojo c1, com.game.cross.domain.ComptePojo cc) {
        ComptePojo.Builder builder = ComptePojo.newBuilder();
        builder.setPos(cc.getPos());
        builder.setServerId(cc.getServerId());
        builder.setRoleId(cc.getRoleId());
        builder.setNick(cc.getNick());
        builder.setBet(cc.getBet());
        builder.setMyBetNum(c1.getMyBetNum());
        builder.setServerName(cc.getServerName());
        builder.setFight(cc.getFight());
        builder.setPortrait(cc.getPortrait());
        builder.setLevel(cc.getLevel());
        if (cc.getPartyName() != null) {
            builder.setPartyName(cc.getPartyName());
        }
        return builder.build();
    }

    public static CommonPb.KnockoutBattleGroup createKnockoutBattleGroupPb(
            KnockoutBattleGroup kg) {
        CommonPb.KnockoutBattleGroup.Builder builder =
                CommonPb.KnockoutBattleGroup.newBuilder();
        builder.setGroupType(kg.getGroupType());
        if (kg.groupMaps.size() > 0) {
            Iterator<CompetGroup> its = kg.groupMaps.values().iterator();
            while (its.hasNext()) {
                builder.addCompetGroup(createKnockoutCompetGroupPb(its.next()));
            }
        }

        return builder.build();
    }

    public static FinalCompetGroup createFinalCompetGroupPb(CompetGroup c) {
        FinalCompetGroup.Builder builder = FinalCompetGroup.newBuilder();
        builder.setCompetGroupId(c.getCompetGroupId());
        if (c.getC1() != null) {
            builder.setC1(createComptePojoPb(c.getC1()));
        }
        if (c.getC2() != null) {
            builder.setC2(createComptePojoPb(c.getC2()));
        }

        builder.setWin(c.getWin());
        if (c.getMap().size() > 0) {
            Iterator<CompteRound> its = c.getMap().values().iterator();
            while (its.hasNext()) {
                builder.addCompteRound(createCompteRoundPb(its.next()));
            }
        }

        return builder.build();
    }


    public static MyBet createMyBetPb(com.game.cross.domain.MyBet myBet, CompetGroup cg) {
        MyBet.Builder builder = MyBet.newBuilder();
        builder.setMyGroup(myBet.getMyGroup());
        builder.setStage(myBet.getStage());
        builder.setGroupType(myBet.getGroupType());

        builder.setCompetGroupId(myBet.getCompetGroupId());
        if (myBet.getC1() != null) {
            builder.setC1(createComptePojoPb(myBet.getC1(), cg.getC1()));
        }
        if (myBet.getC2() != null) {
            builder.setC2(createComptePojoPb(myBet.getC2(), cg.getC2()));
        }

        builder.setWin(myBet.getWin());
        for (CompteRound cr : myBet.getCompteRounds()) {
            builder.addCompteRound(createCompteRoundPb(cr));
        }

        builder.setBetState(myBet.getBetState());
        builder.setBetTime(myBet.getBetTime());
        return builder.build();
    }

    public static CommonPb.CrossShopBuy createCrossShopBuyPb(CrossShopBuy buy) {
        CommonPb.CrossShopBuy.Builder builder =
                CommonPb.CrossShopBuy.newBuilder();
        builder.setShopId(buy.getShopId());
        builder.setBuyNum(buy.getBuyNum());
        builder.setRestNum(buy.getRestNum());
        return builder.build();
    }

    public static CrossTopRank createCrossTopRankPb(
            int index, String serverName, String name, long fight, long roleId) {
        CrossTopRank.Builder builder = CrossTopRank.newBuilder();
        builder.setRank(index);
        builder.setServerName(serverName);
        builder.setName(name);
        builder.setFight(fight);
        builder.setRoleId(roleId);
        return builder.build();
    }

    public static JiFenPlayer createJifenPlayer(CommonPb.JiFenPlayer jp) {
        JiFenPlayer j =
                new JiFenPlayer(
                        jp.getServerId(), jp.getRoleId(), jp.getNick(), jp.getJifen(), jp.getExchangeJifen());

        for (CommonPb.CrossTrend ct : jp.getCrossTrendsList()) {
            CrossTrend c = new CrossTrend();
            c.setTrendId(ct.getTrendId());
            c.setTrendTime(ct.getTrendTime());

            String[] s = new String[ct.getTrendParamCount()];
            ct.getTrendParamList().toArray(s);
            c.setTrendParam(s);

            j.crossTrends.add(c);
        }

        for (MyBet myBet : jp.getMybetList()) {
            com.game.cross.domain.MyBet my = new com.game.cross.domain.MyBet();
            my.setMyGroup(myBet.getMyGroup());
            my.setStage(myBet.getStage());
            if (myBet.hasGroupType()) {
                my.setGroupType(myBet.getGroupType());
            }
            my.setCompetGroupId(myBet.getCompetGroupId());
            if (myBet.hasC1()) {
                my.setC1(
                        new com.game.cross.domain.ComptePojo(
                                myBet.getC1().getPos(),
                                myBet.getC1().getServerId(),
                                myBet.getC1().getRoleId(),
                                myBet.getC1().getNick(),
                                myBet.getC1().getBet(),
                                myBet.getC1().getMyBetNum(),
                                myBet.getC1().getServerName(),
                                myBet.getC1().getFight(),
                                myBet.getC1().getPortrait(),
                                myBet.getC1().getPartyName(),
                                myBet.getC1().getLevel()));
            }
            if (myBet.hasC2()) {
                my.setC2(
                        new com.game.cross.domain.ComptePojo(
                                myBet.getC2().getPos(),
                                myBet.getC2().getServerId(),
                                myBet.getC2().getRoleId(),
                                myBet.getC2().getNick(),
                                myBet.getC2().getBet(),
                                myBet.getC2().getMyBetNum(),
                                myBet.getC2().getServerName(),
                                myBet.getC2().getFight(),
                                myBet.getC2().getPortrait(),
                                myBet.getC2().getPartyName(),
                                myBet.getC2().getLevel()));
            }
            if (myBet.hasWin()) {
                my.setWin(myBet.getWin());
            }

            for (CommonPb.CompteRound c : myBet.getCompteRoundList()) {
                my.getCompteRounds()
                        .add(new CompteRound(c.getRoundNum(), c.getWin(), c.getReportKey(), c.getDetail()));
            }

            my.setBetState(myBet.getBetState());
            if (myBet.hasBetTime()) {
                my.setBetTime(myBet.getBetTime());
            }

            String key =
                    my.getMyGroup()
                            + "_"
                            + my.getStage()
                            + "_"
                            + my.getGroupType()
                            + "_"
                            + my.getCompetGroupId();

            j.myBets.put(key, my);
        }

        for (CommonPb.CrossShopBuy cs : jp.getCrossShopBuyList()) {
            CrossShopBuy c = new CrossShopBuy(cs);
            j.crossShopBuy.put(c.getShopId(), c);
        }

        if (jp.hasLastUpdateCrossShopDate()) {
            j.setLastUpdateCrossShopDate(jp.getLastUpdateCrossShopDate());
        }

        return j;
    }

    public static CommonPb.CrossTrend createCrossTrendPb(CrossTrend ct) {
        CommonPb.CrossTrend.Builder builder = CommonPb.CrossTrend.newBuilder();
        builder.setTrendId(ct.getTrendId());
        builder.setTrendTime(ct.getTrendTime());
        for (String s : ct.getTrendParam()) {
            builder.addTrendParam(s);
        }
        return builder.build();
    }

    public static CommonPb.CrossShopBuy createCrossShopBuyPb(
            int shopId, int buyNum, int restNum) {
        CommonPb.CrossShopBuy.Builder builder =
                CommonPb.CrossShopBuy.newBuilder();
        builder.setShopId(shopId);
        builder.setBuyNum(buyNum);
        builder.setRestNum(restNum);
        return builder.build();
    }

    public static FamePojo createFamePojoPb(
            int id, String name, int serverId, String serverName, int level, long fight, int portrait) {
        FamePojo.Builder builder = FamePojo.newBuilder();
        builder.setId(id);
        builder.setName(name);
        builder.setServerId(serverId);
        builder.setServerName(serverName);
        builder.setLevel(level);
        builder.setFight(fight);
        builder.setPortrait(portrait);
        return builder.build();
    }

    public static FameBattleReview createFameBattleReviewPb(
            int pos, String name, int serverId, String serverName, int level, long fight, int portrait) {
        FameBattleReview.Builder builder = FameBattleReview.newBuilder();
        builder.setPos(pos);
        builder.setName(name);
        builder.setServerId(serverId);
        builder.setServerName(serverName);
        builder.setLevel(level);
        builder.setFight(fight);
        builder.setPortrait(portrait);

        return builder.build();
    }

    public static CPMemberReg createCpMemberRegPb(PartyMember pm) {
        CPMemberReg.Builder builder = CPMemberReg.newBuilder();
        builder.setTime(pm.getRegTime());
        builder.setName(pm.getNick());
        builder.setLv(pm.getLevel());
        builder.setFight(pm.getFight());
        builder.setPartyId(pm.getPartyId());
        builder.setPartyName(pm.getPartyName());
        return builder.build();
    }

    public static CPPartyInfo createCPPartyInfo(Party p, String serverName) {
        CPPartyInfo.Builder builder = CPPartyInfo.newBuilder();
        builder.setPartyLv(p.getPartyLv());
        builder.setPartyId(p.getPartyId());
        builder.setPartyName(p.getPartyName());
        builder.setMemberNum(p.getMembers().size());
        builder.setTotalFight(p.getFight());
        builder.setServerName(serverName);
        return builder.build();
    }

    public static CPRecord createCpRecordPb(
            int reportKey,
            String attackPartyName,
            String attackName,
            String attackServerName,
            int hp1,
            String defencePartyName,
            String defenceName,
            String defenceServerName,
            int hp2,
            int result,
            int time,
            int group,
            int serverId1,
            int serverId2,
            long roleId1,
            long roleId2) {
        CPRecord.Builder builder = CPRecord.newBuilder();
        builder.setReportKey(reportKey);
        builder.setPartyName1(attackPartyName);
        builder.setName1(attackName);
        builder.setServerName1(attackServerName);
        builder.setHp1(hp1);
        builder.setPartyName2(defencePartyName);
        builder.setName2(defenceName);
        builder.setServerName2(defenceServerName);
        builder.setHp2(hp2);
        builder.setResult(result);
        builder.setTime(time);
        builder.setGroup(group);
        builder.setServerId1(serverId1);
        builder.setServerId2(serverId2);
        builder.setRoleId1(roleId1);
        builder.setRoleId2(roleId2);
        return builder.build();
    }

    public static CPRecord createCpResultPb(
            int key,
            String serverName1,
            String partyName1,
            String serverName2,
            String partyName2,
            String nick2,
            int rank,
            int time,
            int group) {
        CPRecord.Builder builder = CPRecord.newBuilder();
        builder.setReportKey(key);
        builder.setServerName1(serverName1);
        builder.setPartyName1(partyName1);

        builder.setServerName2(serverName2);
        builder.setPartyName2(partyName2);

        builder.setName2(nick2);
        builder.setTime(time);
        builder.setRank(rank);
        builder.setGroup(group);

        return builder.build();
    }

    public static CPRank createCpRankPb(
            int rank, String name, int fightCount, int jifen, String serverName, long fight) {
        CPRank.Builder builder = CPRank.newBuilder();
        builder.setRank(rank);
        builder.setName(name);
        builder.setFightCount(fightCount);
        builder.setJifen(jifen);
        builder.setServerName(serverName);
        builder.setFight(fight);
        return builder.build();
    }

    public static CPRank createCpRankPb(int rank, int rewardState) {
        CPRank.Builder builder = CPRank.newBuilder();
        builder.setRank(rank);
        builder.setRewardState(rewardState);
        return builder.build();
    }

    public static CPRank createLianShengCpRankPb(
            int rank, String name, String serverName, long fight, int winCount) {
        CPRank.Builder builder = CPRank.newBuilder();
        builder.setRank(rank);
        builder.setName(name);
        builder.setServerName(serverName);
        builder.setFight(fight);
        builder.setWinCount(winCount);
        return builder.build();
    }

    public static CPRank createPartyCpRankPb(
            int rank, String serverName, String partyName, long fight, int jifen) {
        CPRank.Builder builder = CPRank.newBuilder();
        builder.setRank(rank);
        builder.setServerName(serverName);
        builder.setPartyName(partyName);
        builder.setFight(fight);
        builder.setJifen(jifen);
        return builder.build();
    }

    public static CPPartyMember createCpPartyMemberPb(PartyMember pm) {
        CPPartyMember.Builder builder = CPPartyMember.newBuilder();
        builder.setServerId(pm.getServerId());
        builder.setRoleId(pm.getRoleId());
        builder.setNick(pm.getNick());
        builder.setFight(pm.getFight());
        builder.setLevel(pm.getLevel());
        builder.setGroupWinNum(pm.getGroupWinNum());
        builder.setFinalWinNum(pm.getFinalWinNum());
        builder.setFightCount(pm.getFightCount());
        builder.setPartyId(pm.getPartyId());
        builder.setPartyName(pm.getPartyName());
        builder.setJifen(pm.getJifen());
        builder.setRegTime(pm.getRegTime());
        builder.addAllMyReportKeys(pm.getMyReportKeys());
        builder.setJifenjiangli(pm.getJifenjiangli());
        builder.setExchangeJifen(pm.getExchangeJifen());
        builder.setPortrait(pm.getPortrait());

        for (CrossTrend ct : pm.crossTrends) {
            builder.addCrossTrends(PbHelper.createCrossTrendPb(ct));
        }

        Iterator<CrossShopBuy> i = pm.crossShopBuy.values().iterator();
        while (i.hasNext()) {
            builder.addCrossShopBuy(PbHelper.createCrossShopBuyPb(i.next()));
        }

        if (pm.getForm() != null) {
            builder.setForm(createFormPb(pm.getForm()));
        }

        Iterator<HashMap<Integer, Equip>> itequips = pm.equips.values().iterator();
        while (itequips.hasNext()) {
            HashMap<Integer, Equip> map = itequips.next();
            Iterator<Equip> iiequips = map.values().iterator();
            while (iiequips.hasNext()) {
                builder.addEquip(createEquipPb(iiequips.next()));
            }
        }

        Iterator<HashMap<Integer, Part>> itParts = pm.parts.values().iterator();
        while (itParts.hasNext()) {
            HashMap<Integer, Part> map = itParts.next();
            Iterator<Part> iiparts = map.values().iterator();
            while (iiparts.hasNext()) {
                builder.addPart(createPartPb(iiparts.next()));
            }
        }

        Iterator<Science> itscce = pm.sciences.values().iterator();
        while (itscce.hasNext()) {
            builder.addScience(createSciencePb(itscce.next()));
        }
        Set<Integer> keySet = pm.skills.keySet();
        for (Integer key : keySet) {
            int value = pm.skills.get(key);
            builder.addSkill(createSkillPb(key, value));
        }

        Iterator<Effect> ieffect = pm.effects.values().iterator();
        while (ieffect.hasNext()) {
            builder.addEffect(createEffectPb(ieffect.next()));
        }

        builder.setStaffingId(pm.StaffingId);

        Iterator<Map<Integer, EnergyStoneInlay>> ite = pm.energyInlay.values().iterator();
        while (ite.hasNext()) {
            Map<Integer, EnergyStoneInlay> map = ite.next();
            Iterator<EnergyStoneInlay> iimap = map.values().iterator();
            while (iimap.hasNext()) {
                builder.addInlay(createEnergyStoneInlayPb(iimap.next()));
            }
        }

        Iterator<MilitaryScience> itm = pm.militarySciences.values().iterator();
        while (itm.hasNext()) {
            builder.addMilitaryScience(createMilitaryScienecePb(itm.next()));
        }

        Iterator<HashMap<Integer, MilitaryScienceGrid>> itmsc =
                pm.militaryScienceGrids.values().iterator();
        while (itmsc.hasNext()) {
            HashMap<Integer, MilitaryScienceGrid> map = itmsc.next();
            Iterator<MilitaryScienceGrid> itmap = map.values().iterator();
            while (itmap.hasNext()) {
                builder.addMilitaryScienceGrid(createMilitaryScieneceGridPb(itmap.next()));
            }
        }

        builder.setState(pm.getState());
        if (pm.getInstForm() != null) {
            builder.setInstForm(createFormPb(pm.getInstForm()));
        }

        Iterator<HashMap<Integer, Medal>> medalsits = pm.medals.values().iterator();
        while (medalsits.hasNext()) {
            HashMap<Integer, Medal> map = medalsits.next();
            Iterator<Medal> iits = map.values().iterator();
            while (iits.hasNext()) {
                builder.addMedal(createMedalPb(iits.next()));
            }
        }

        Iterator<HashMap<Integer, MedalBouns>> mds = pm.medalBounss.values().iterator();
        while (mds.hasNext()) {
            HashMap<Integer, MedalBouns> map = mds.next();
            Iterator<MedalBouns> iits = map.values().iterator();
            while (iits.hasNext()) {
                builder.addMedalBouns(createMedalBounsPb(iits.next()));
            }
        }

        // 觉醒将领
        for (AwakenHero awakenHero : pm.awakenHeros.values()) {
            builder.addAwakenHero(PbHelper.createAwakenHeroPb(awakenHero));
        }

        // 军备
        for (Entry<Integer, com.game.domain.p.lordequip.LordEquip> entry : pm.lordEquips.entrySet()) {
            builder.addLeq(createLordEquip(entry.getValue()));
        }

        // 军衔等级
        builder.setMilitaryRank(pm.militaryRank);

        // 秘密武器
        for (Entry<Integer, SecretWeapon> entry : pm.secretWeaponMap.entrySet()) {
            builder.addSecretWeapon(createSecretWeapon(entry.getValue()));
        }

        // 攻击特效
        for (Entry<Integer, AttackEffect> entry : pm.atkEffects.entrySet()) {
            builder.addAttackEffect(createAttackEffectPb(entry.getValue()));
        }

        // 作战实验室科技树
        if (!pm.graduateInfo.isEmpty()) {
            builder.addAllGraduateInfo(PbHelper.createGraduateInfoPb(pm.graduateInfo));
        }

        if (!pm.partyScienceMap.isEmpty()) {
            Collection<PartyScience> partySciences = pm.partyScienceMap.values();
            for (PartyScience partyScience : partySciences) {
                builder.addPartyScience(PbHelper.createPartySciencePb(partyScience));
            }
        }
        PEnergyCore pEnergyCore = pm.getpEnergyCore();
        builder.setEnergyCore(PbHelper.createThreeIntPb(pEnergyCore.getLevel(),pEnergyCore.getSection(),pEnergyCore.getState()));
        return builder.build();
    }

    public static CPParty createCpPartyPb(Party p) {
        CPParty.Builder builder = CPParty.newBuilder();
        Iterator<Long> its = p.getMembers().keySet().iterator();
        while (its.hasNext()) {
            builder.addRoleId(its.next());
        }

        Iterator<PartyMember> itsp = p.getFighters().iterator();
        while (itsp.hasNext()) {
            builder.addFighters(itsp.next().getRoleId());
        }

        builder.setOrder(p.getOrder());
        builder.setOutCount(p.getOutCount());
        builder.setFormNum(p.getFormNum());
        builder.setServerId(p.getServerId());
        builder.setPartyId(p.getPartyId());
        builder.setPartyName(p.getPartyName());
        builder.setPartyLv(p.getPartyLv());
        builder.setWarRank(p.getWarRank());
        builder.setFight(p.getFight());
        builder.setGroup(p.getGroup());
        builder.setIsFinalGroup(p.isFinalGroup());
        builder.addAllPartyReportKey(p.getPartyReportKey());
        builder.setTotalJifen(p.getTotalJifen());
        builder.setMyPartySirPortrait(p.getMyPartySirPortrait());

        return builder.build();
    }

    public static CommonPb.GroupParty createGroupPartyPb(GroupParty g) {
        CommonPb.GroupParty.Builder builder = CommonPb.GroupParty.newBuilder();
        builder.setGroup(g.getGroup());
        builder.addAllGroupPartyMap(g.getGroupPartyMap().keySet());
        builder.addAllGroupKeyList(g.getGroupKeyList());

        Iterator<Entry<Integer, Party>> its = g.getRankMap().entrySet().iterator();
        while (its.hasNext()) {
            Entry<Integer, Party> i = its.next();

            builder.addRankParty(
                    createRankPartyPb(
                            i.getKey(), i.getValue().getServerId() + "_" + i.getValue().getPartyId()));
        }

        return builder.build();
    }

    private static RankParty createRankPartyPb(int rank, String key) {
        RankParty.Builder builder = RankParty.newBuilder();
        builder.setRank(rank);
        builder.setKey(key);
        return builder.build();
    }

    public static CommonPb.ServerSisuation createServerSisuationPb(ServerSisuation ss) {
        CommonPb.ServerSisuation.Builder builder =
                CommonPb.ServerSisuation.newBuilder();
        builder.setServerId(ss.getServerId());
        builder.addAllGroupKeyList(ss.getGroupKeyList());
        builder.addAllFinalKeyList(ss.getFinalKeyList());

        return builder.build();
    }

    public static CPRank createMyPartyCPRankPb(int i) {
        CPRank.Builder builder = CPRank.newBuilder();
        builder.setRank(i);
        return builder.build();
    }

    public static CPRecord createCpResultFirstPb(
            int kk, String serverName, String partyName, int rank, int time, int group) {
        CPRecord.Builder builder = CPRecord.newBuilder();
        builder.setReportKey(kk);
        builder.setServerName1(serverName);
        builder.setPartyName1(partyName);
        builder.setRank(rank);
        builder.setGroup(group);
        builder.setTime(time);
        return builder.build();
    }

    public static com.game.domain.p.Medal createMedal(CommonPb.Medal m) {
        return new Medal(
                m.getKeyId(),
                m.getMedalId(),
                m.getUpLv(),
                m.getRefitLv(),
                m.getPos(),
                m.getUpExp(),
                m.getLocked());
    }

    public static com.game.domain.p.MedalBouns createMedalBouns(CommonPb.MedalBouns m) {
        return new MedalBouns(m.getMedalId(), m.getState());
    }

    public static CommonPb.AwakenHero createAwakenHeroPb(AwakenHero awakenHero) {
        CommonPb.AwakenHero.Builder builder = CommonPb.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

    public static CommonPb.LordEquip createLordEquip(com.game.domain.p.lordequip.LordEquip eq) {
        CommonPb.LordEquip.Builder builder = CommonPb.LordEquip.newBuilder();
        builder.setKeyId(eq.getKeyId());
        builder.setEquipId(eq.getEquipId());
        builder.setPos(eq.getPos());
        builder.setLordEquipSaveType(eq.getLordEquipSaveType());
        for (List<Integer> skillId : eq.getLordEquipSkillList()) {
            // [军备技能id,等级]列表
            builder.addSkillLv(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }

        for (List<Integer> skillId : eq.getLordEquipSkillSecondList()) {
            // [军备技能id,等级]列表
            builder.addSkillLvSecond(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }
        return builder.build();
    }


    /**
     * 创建秘密武器信息
     *
     * @param weapon
     * @return
     */
    public static CommonPb.SecretWeapon createSecretWeapon(SecretWeapon weapon) {
        CommonPb.SecretWeapon.Builder builder = CommonPb.SecretWeapon.newBuilder();
        builder.setId(weapon.getId());
        for (SecretWeaponBar bar : weapon.getBars()) {
            CommonPb.SecretWeaponBar.Builder pbBar = CommonPb.SecretWeaponBar.newBuilder();
            pbBar.setSid(bar.getSid());
            pbBar.setLocked(bar.isLock());
            builder.addBar(pbBar);
        }
        return builder.build();
    }

    /**
     * 攻击特效
     *
     * @param effect
     * @return
     */
    public static AttackEffectPb createAttackEffectPb(AttackEffect effect) {
        AttackEffectPb.Builder builder = AttackEffectPb.newBuilder();
        builder.addAllUnlock(effect.getUnlock());
        builder.setType(effect.getType());
        builder.setUseId(effect.getUseId());
        return builder.build();
    }

    /**
     * 序列化作战实验室兵种调配
     *
     * @param
     * @return
     */
    public static List<GraduateInfoPb> createGraduateInfoPb(
            Map<Integer, Map<Integer, Integer>> graduateMap) {
        List<GraduateInfoPb> list = new ArrayList<>();
        for (Entry<Integer, Map<Integer, Integer>> typeEntry : graduateMap.entrySet()) {
            GraduateInfoPb.Builder builder = GraduateInfoPb.newBuilder();
            builder.setType(typeEntry.getKey());
            for (Entry<Integer, Integer> skillEntry : typeEntry.getValue().entrySet()) {
                Integer level = skillEntry.getValue();
                if (level != null && level > 0) {
                    builder.addGraduateInfo(
                            PbHelper.createTwoIntPb(skillEntry.getKey(), skillEntry.getValue()));
                }
            }
            list.add(builder.build());
        }
        return list;
    }

    public static Athlete dserAthlete(CommonPb.Athlete athletePb) {
        Athlete athlete = new Athlete();
        athlete.setServerId(athletePb.getServerId());
        athlete.setRoleId(athletePb.getRoleId());
        athlete.setNick(athletePb.getNick());
        athlete.setGroupId(athletePb.getGroupId());
        athlete.setFight(athletePb.getFight());
        athlete.setWinNum(athletePb.getWinNum());
        athlete.setFailNum(athletePb.getFailNum());
        athlete.setPortrait(athletePb.getPortrait());

        if (athletePb.hasLevel()) {
            athlete.setLevel(athletePb.getLevel());
        }
        if (athletePb.hasPartyName()) {
            athlete.setPartyName(athletePb.getPartyName());
        }

        athlete.getMyReportKeys().addAll(athletePb.getMyReportKeysList());

        for (com.game.pb.CommonPb.Form form : athletePb.getFormList()) {
            athlete.getForms().put(form.getType(), PbHelper.createForm(form));
        }

        // 装备
        for (com.game.pb.CommonPb.Equip pbEquip : athletePb.getEquipList()) {
            com.game.domain.p.Equip equip = PbHelper.createEquip(pbEquip);
            HashMap<Integer, com.game.domain.p.Equip> map = athlete.equips.get(equip.getPos());
            if (map == null) {
                map = new HashMap<>();
                athlete.equips.put(equip.getPos(), map);
            }
            map.put(equip.getKeyId(), equip);
        }

        // 配件
        for (CommonPb.Part e : athletePb.getPartList()) {
            boolean locked = false;
            if (e.hasLocked()) {
                locked = e.getLocked();
            }
            Map<Integer, Integer[]> mapAttr = new HashMap<>();
            for (CommonPb.PartSmeltAttr attr : e.getAttrList()) {
                Integer[] i = new Integer[]{attr.getVal(), attr.getNewVal()};
                mapAttr.put(attr.getId(), i);
            }

            Part part =
                    new Part(
                            e.getKeyId(),
                            e.getPartId(),
                            e.getUpLv(),
                            e.getRefitLv(),
                            e.getPos(),
                            locked,
                            e.getSmeltLv(),
                            e.getSmeltExp(),
                            mapAttr,
                            e.getSaved());
            HashMap<Integer, com.game.domain.p.Part> map = athlete.parts.get(part.getPos());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.Part>();
                athlete.parts.put(part.getPos(), map);
            }
            map.put(part.getKeyId(), part);
        }

        // 科技
        for (CommonPb.Science pbs : athletePb.getScienceList()) {
            com.game.domain.p.Science s = PbHelper.createScience(pbs);
            athlete.sciences.put(s.getScienceId(), s);
        }

        // 技能
        for (CommonPb.Skill skill : athletePb.getSkillList()) {
            athlete.skills.put(skill.getId(), skill.getLv());
        }

        // 影响
        for (CommonPb.Effect pbe : athletePb.getEffectList()) {
            com.game.domain.p.Effect e = PbHelper.createEffect(pbe);
            athlete.effects.put(e.getEffectId(), e);
        }

        athlete.setStaffingId(athletePb.getStaffingId());

        for (CommonPb.EnergyStoneInlay pbe : athletePb.getInlayList()) {
            com.game.domain.p.EnergyStoneInlay e = PbHelper.createEnergyStoneInlay(pbe);

            Map<Integer, com.game.domain.p.EnergyStoneInlay> map = athlete.energyInlay.get(e.getPos());
            if (map == null) {
                map = new HashMap<>();
                athlete.energyInlay.put(e.getPos(), map);
            }
            map.put(e.getHole(), e);
        }

        for (CommonPb.MilitaryScienceGrid pbmg : athletePb.getMilitaryScienceGridList()) {
            com.game.domain.p.MilitaryScienceGrid m = PbHelper.createMilitaryScieneceGrid(pbmg);

            HashMap<Integer, com.game.domain.p.MilitaryScienceGrid> map =
                    athlete.militaryScienceGrids.get(m.getTankId());
            if (map == null) {
                map = new HashMap<>();
                athlete.militaryScienceGrids.put(m.getTankId(), map);
            }
            map.put(m.getPos(), m);
        }
        for (CommonPb.MilitaryScience pbms : athletePb.getMilitaryScienceList()) {
            com.game.domain.p.MilitaryScience m = PbHelper.createMilitaryScienece(pbms);
            athlete.militarySciences.put(m.getMilitaryScienceId(), m);
        }

        for (CommonPb.Medal mpb : athletePb.getMedalList()) {
            com.game.domain.p.Medal m = PbHelper.createMedal(mpb);

            HashMap<Integer, com.game.domain.p.Medal> map = athlete.medals.get(m.getPos());
            if (map == null) {
                map = new HashMap<>();
                athlete.medals.put(m.getPos(), map);
            }

            map.put(m.getKeyId(), m);
        }

        for (com.game.pb.CommonPb.MedalBouns mpb : athletePb.getMedalBounsList()) {
            com.game.domain.p.MedalBouns m = PbHelper.createMedalBouns(mpb);

            HashMap<Integer, com.game.domain.p.MedalBouns> map = athlete.medalBounss.get(m.getState());
            if (map == null) {
                map = new HashMap<>();
                athlete.medalBounss.put(m.getState(), map);
            }

            map.put(m.getMedalId(), m);
        }

        for (com.game.pb.CommonPb.AwakenHero mpb : athletePb.getAwakenHeroList()) {
            AwakenHero ah = new AwakenHero(mpb);
            athlete.awakenHeros.put(ah.getKeyId(), ah);
        }

        // 军备
        for (CommonPb.LordEquip pbLeq : athletePb.getLeqList()) {
            com.game.domain.p.lordequip.LordEquip leq = new com.game.domain.p.lordequip.LordEquip(pbLeq.getKeyId(), pbLeq.getEquipId(), pbLeq.getPos());
            athlete.lordEquips.put(leq.getPos(), leq);
            leq.setLordEquipSaveType(pbLeq.getLordEquipSaveType());
            List<CommonPb.TwoInt> skillLvList = pbLeq.getSkillLvList();
            List<List<Integer>> lordEquipSkillList = leq.getLordEquipSkillList();
            for (CommonPb.TwoInt twoInt : skillLvList) {
                List<Integer> skillLv = new ArrayList<Integer>();
                skillLv.add(twoInt.getV1());
                skillLv.add(twoInt.getV2());
                lordEquipSkillList.add(skillLv);
            }

            List<CommonPb.TwoInt> skillLvListSecond = pbLeq.getSkillLvSecondList();
            List<List<Integer>> lordEquipSkillSecond = leq.getLordEquipSkillSecondList();
            for (CommonPb.TwoInt twoInt : skillLvListSecond) {
                List<Integer> map = new ArrayList<Integer>();
                map.add(twoInt.getV1());
                map.add(twoInt.getV2());
                lordEquipSkillSecond.add(map);
            }
        }

        // 军衔
        athlete.militaryRank = athletePb.getMilitaryRank();

        // 秘密武器
        for (CommonPb.SecretWeapon pbw : athletePb.getSecretWeaponList()) {
            athlete.secretWeaponMap.put(pbw.getId(), new SecretWeapon(pbw));
        }

        // 攻击特效
        for (CommonPb.AttackEffectPb pb : athletePb.getAtkEftList()) {
            athlete.atkEffects.put(pb.getType(), new AttackEffect(pb));
        }

        // 作战实验室
        for (CommonPb.GraduateInfoPb pb : athletePb.getGraduateInfoList()) {
            Map<Integer, Integer> skillMap = athlete.graduateInfo.get(pb.getType());
            if (skillMap == null) athlete.graduateInfo.put(pb.getType(), skillMap = new HashMap<>());
            for (CommonPb.TwoInt twoInt : pb.getGraduateInfoList()) {
                skillMap.put(twoInt.getV1(), twoInt.getV2());
            }
        }

        if (athletePb.getPartyScienceList() != null) {
            List<CommonPb.Science> scienceList = athletePb.getPartyScienceList();
            for (CommonPb.Science science : scienceList) {
                PartyScience partyScience =
                        new PartyScience(science.getScienceId(), science.getScienceLv());
                partyScience.setSchedule(science.getSchedule());
                athlete.partyScienceMap.put(partyScience.getScienceId(), partyScience);
            }
        }
        athlete.setUpdate(false);
        athlete.setpEnergyCore(new PEnergyCore(athletePb.getEnergyCore().getV1(),athletePb.getEnergyCore().getV2(),athletePb.getEnergyCore().getV3()));
        return athlete;
    }


    /**
     * @param jp
     * @return
     */
    public static CommonPb.JiFenPlayer createJifenPlayerPb(
            JiFenPlayer jp,
            Map<Integer, KnockoutBattleGroup> dfKnockoutBattleGroups,
            Map<Integer, KnockoutBattleGroup> jyKnockoutBattleGroups,
            Map<Integer, CompetGroup> jyFinalBattleGroups,
            Map<Integer, CompetGroup> dfFinalBattleGroups) {
        CommonPb.JiFenPlayer.Builder builder =
                CommonPb.JiFenPlayer.newBuilder();
        builder.setServerId(jp.getServerId());
        builder.setRoleId(jp.getRoleId());
        builder.setNick(jp.getNick());
        builder.setJifen(jp.getJifen());
        builder.setExchangeJifen(jp.getExchangeJifen());

        Iterator<com.game.cross.domain.MyBet> its = jp.myBets.values().iterator();
        while (its.hasNext()) {

            com.game.cross.domain.MyBet myBet = its.next();

            int myGroup = myBet.getMyGroup(); // 1精英组 2巅峰组
            int stage = myBet.getStage(); // 1淘汰赛,2总决赛
            int groupType = myBet.getGroupType(); // 淘汰赛有分组,1A 2B 3C 4D 总决赛0
            int competGroupId = myBet.getCompetGroupId(); // 淘汰赛(1-15组)
            // 总决赛(1-4组)

            CompetGroup cg = null;
            if (myGroup == CrossConst.DF_Group) {

                // 巅峰组
                if (stage == CrossConst.Knock_Session) {
                    // 淘汰赛
                    KnockoutBattleGroup k = dfKnockoutBattleGroups.get(groupType);
                    cg = k.groupMaps.get(competGroupId);

                } else {
                    // 总决赛
                    cg = dfFinalBattleGroups.get(competGroupId);
                }
            } else {
                // 精英组
                if (stage == CrossConst.Knock_Session) {
                    // 淘汰赛
                    KnockoutBattleGroup k = jyKnockoutBattleGroups.get(groupType);
                    cg = k.groupMaps.get(competGroupId);
                } else {
                    // 总决赛;
                    cg = jyFinalBattleGroups.get(competGroupId);
                }
            }

            builder.addMybet(PbHelper.createMyBetPb(myBet, cg));
        }

        for (CrossTrend ct : jp.crossTrends) {
            builder.addCrossTrends(PbHelper.createCrossTrendPb(ct));
        }

        Iterator<CrossShopBuy> i = jp.crossShopBuy.values().iterator();
        while (i.hasNext()) {
            builder.addCrossShopBuy(PbHelper.createCrossShopBuyPb(i.next()));
        }

        builder.setLastUpdateCrossShopDate(jp.getLastUpdateCrossShopDate());

        return builder.build();
    }

    /**
     * 组队副本队员信息
     *
     * @param roleId
     * @param nick
     * @param portrait
     * @param status
     * @param fight
     * @return
     */
    public static CrossTeamProto.RpcTeamRoleInfo createTeamRoleInfo(long roleId, String nick, int portrait, int status, long fight ,String serverName) {
        CrossTeamProto.RpcTeamRoleInfo.Builder builder = CrossTeamProto.RpcTeamRoleInfo.newBuilder();
        builder.setRoleId(roleId);
        builder.setNick(nick);
        builder.setPortrait(portrait);
        builder.setFight(fight);
        builder.setStatus(status);
        builder.setServerName(serverName);
        return builder.build();
    }

    /**
     * 组队副本队员信息
     *
     * @param player
     * @param status
     * @return
     */
    public static CommonPb.TeamRoleInfo createTeamRoleInfo(CrossPlayer player, int status, long fight,String serverName) {
        CommonPb.TeamRoleInfo.Builder builder = CommonPb.TeamRoleInfo.newBuilder();
        builder.setRoleId(player.getRoleId());
        builder.setNick(player.getNick());
        builder.setPortrait(player.getPortrait());
        builder.setFight(fight);
        builder.setStatus(status);
        builder.setServerName(serverName);
        return builder.build();
    }

    static public CommonPb.TwoLong createTwoLongPb(long p, long c) {
        TwoLong.Builder builder = TwoLong.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }


    static public CommonPb.RptTank createRtpTankPb(RptTank rptTank) {
        CommonPb.RptTank.Builder builder = CommonPb.RptTank.newBuilder();
        builder.setTankId(rptTank.getTankId());
        builder.setCount(rptTank.getCount());
        return builder.build();
    }



    static public CommonPb.Army createArmyPb(Army army) {
        CommonPb.Army.Builder builder = CommonPb.Army.newBuilder();
        builder.setKeyId(army.getKeyId());
        builder.setTarget(army.getTarget());
        builder.setState(army.getState());
        builder.setPeriod(army.getPeriod());
        builder.setEndTime(army.getEndTime());
        builder.setForm(createFormPb(army.getForm()));
        builder.setIsRuins(army.isRuins());
        builder.setTarQua(army.getTarQua());
        builder.setType(army.getType());
        builder.setCollectBeginTime(army.getCollectBeginTime());
        builder.setHonourGold(army.getHonourGold());
        builder.setHonourScore(army.getHonourScore());

        builder.setNewHeroAddGold(army.getNewHeroAddGold());
        builder.setCaiJiStartTime(army.getCaiJiStartTime());
        builder.setCaiJiEndTime(army.getCaiJiEndTime());
        builder.setNewHeroSubGold(army.getNewHeroSubGold());
        builder.setStaffingExp(army.getStaffingExp());
        builder.setIsZhuJun(army.getIsZhuJun());
        if (army.getGrab() != null) {
            builder.setGrab(createGrabPb(army.getGrab()));
        }

        if (army.getCollect() != null) {
            builder.setCollect(createCollectPb(army.getCollect()));
        }

        if (army.getStaffingTime() != 0) {
            builder.setStaffingTime(army.getStaffingTime());
        }

        if (army.getSenior()) {
            builder.setSenior(true);
        }

        if (army.getOccupy()) {
            builder.setOccupy(true);
        }

        builder.setFight(army.getFight());

        builder.setFreeWarTime(army.getFreeWarTime());
        builder.setStartFreeWarTime(army.getStartFreeWarTime());

        builder.setLordId(army.getLoad());

        return builder.build();
    }


    static public CommonPb.Grab createGrabPb(Grab grab) {
        CommonPb.Grab.Builder builder = CommonPb.Grab.newBuilder();

        if (grab.rs[0] != 0) {
            builder.setIron(grab.rs[0]);
        }

        if (grab.rs[1] != 0) {
            builder.setOil(grab.rs[1]);
        }

        if (grab.rs[2] != 0) {
            builder.setCopper(grab.rs[2]);
        }

        if (grab.rs[3] != 0) {
            builder.setSilicon(grab.rs[3]);
        }

        if (grab.rs[4] != 0) {
            builder.setStone(grab.rs[4]);
        }

        return builder.build();
    }

    static public CommonPb.Collect createCollectPb(Collect collect) {
        CommonPb.Collect.Builder builder = CommonPb.Collect.newBuilder();
        builder.setLoad(collect.load);
        builder.setSpeed(collect.speed);
        return builder.build();
    }




}
