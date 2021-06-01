package com.game.util;

import com.game.domain.MedalBouns;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.grpc.proto.mine.CrossSeniorMineProto;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.pb.CommonPb;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/4/24 14:52
 * @decs
 */
public class CrossPbHelper {


    public static CrossTeamProto.Equip getCrossEquipPb(Equip equip) {
        CrossTeamProto.Equip.Builder builder = CrossTeamProto.Equip.newBuilder();
        builder.setEquipId(equip.getEquipId());
        builder.setExp(equip.getExp());
        builder.setKeyId(equip.getKeyId());
        builder.setLv(equip.getLv());
        builder.setPos(equip.getPos());
        builder.setStarLv(equip.getStarlv());
        return builder.build();
    }


    public static CrossTeamProto.Science getCrossSciencePb(Science science) {
        CrossTeamProto.Science.Builder builder = CrossTeamProto.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        return builder.build();
    }

    public static CrossTeamProto.Part getCrossPartPb(Part part) {
        CrossTeamProto.Part.Builder builder = CrossTeamProto.Part.newBuilder();
        builder.setKeyId(part.getKeyId());
        builder.setPartId(part.getPartId());
        builder.setUpLv(part.getUpLv());
        builder.setRefitLv(part.getRefitLv());
        builder.setPos(part.getPos());
        builder.setLocked(part.isLocked());
        builder.setSmeltLv(part.getSmeltLv());
        builder.setSmeltExp(part.getSmeltExp());
        for (Map.Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            CrossTeamProto.PartSmeltAttr.Builder attr = CrossTeamProto.PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        builder.setSaved(part.isSaved());
        return builder.build();
    }

    public static CrossTeamProto.Skill getSkillPb(int skillId, int lv) {
        CrossTeamProto.Skill.Builder builder = CrossTeamProto.Skill.newBuilder();
        builder.setId(skillId);
        builder.setLv(lv);
        return builder.build();
    }

    public static CrossTeamProto.Effect createEffectPb(Effect effect) {
        CrossTeamProto.Effect.Builder builder = CrossTeamProto.Effect.newBuilder();
        builder.setId(effect.getEffectId());
        builder.setEndTime(effect.getEndTime());
        return builder.build();
    }

    public static CrossTeamProto.EnergyStoneInlay createEnergyStoneInlayPb(EnergyStoneInlay inlay) {
        CrossTeamProto.EnergyStoneInlay.Builder builder = CrossTeamProto.EnergyStoneInlay.newBuilder();
        builder.setHole(inlay.getHole());
        builder.setStoneId(inlay.getStoneId());
        builder.setPos(inlay.getPos());
        return builder.build();
    }

    public static CrossTeamProto.MilitaryScience createMilitaryScienecePb(MilitaryScience militaryScienece) {
        CrossTeamProto.MilitaryScience.Builder builder = CrossTeamProto.MilitaryScience.newBuilder();
        builder.setMilitaryScienceId(militaryScienece.getMilitaryScienceId());
        builder.setLevel(militaryScienece.getLevel());
        builder.setFitTankId(militaryScienece.getFitTankId());
        builder.setFitPos(militaryScienece.getFitPos());
        return builder.build();
    }

    static public CrossTeamProto.MilitaryScienceGrid createMilitaryScieneceGridPb(MilitaryScienceGrid militaryScieneceGrid) {
        CrossTeamProto.MilitaryScienceGrid.Builder builder = CrossTeamProto.MilitaryScienceGrid.newBuilder();
        builder.setTankId(militaryScieneceGrid.getTankId());
        builder.setPos(militaryScieneceGrid.getPos());
        builder.setStatus(militaryScieneceGrid.getStatus());
        builder.setMilitaryScienceId(militaryScieneceGrid.getMilitaryScienceId());
        return builder.build();
    }

    static public CrossTeamProto.Medal createMedalPb(Medal medal) {
        CrossTeamProto.Medal.Builder builder = CrossTeamProto.Medal.newBuilder();
        builder.setKeyId(medal.getKeyId());
        builder.setMedalId(medal.getMedalId());
        builder.setUpLv(medal.getUpLv());
        builder.setUpExp(medal.getUpExp());
        builder.setRefitLv(medal.getRefitLv());
        builder.setPos(medal.getPos());
        builder.setLocked(medal.isLocked());
        return builder.build();
    }

    static public CrossTeamProto.MedalBouns createMedalBounsPb(MedalBouns medalBouns) {
        CrossTeamProto.MedalBouns.Builder builder = CrossTeamProto.MedalBouns.newBuilder();
        builder.setMedalId(medalBouns.getMedalId());
        builder.setState(medalBouns.getState());
        return builder.build();
    }

    public static CrossTeamProto.AwakenHero createAwakenHeroPb(AwakenHero awakenHero) {
        CrossTeamProto.AwakenHero.Builder builder = CrossTeamProto.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(createTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

    public static CommonPb.AwakenHero createCommonAwakenHeroPb(CrossTeamProto.AwakenHero awakenHero) {
        CommonPb.AwakenHero.Builder builder = CommonPb.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (CrossTeamProto.TwoInt twoInt : awakenHero.getSkillLvList()) {
            builder.addSkillLv(createCommonTwoIntPb(twoInt.getV1(), twoInt.getV2()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }


    public static CrossTeamProto.LordEquip createLordEquip(LordEquip eq) {
        CrossTeamProto.LordEquip.Builder builder = CrossTeamProto.LordEquip.newBuilder();
        builder.setKeyId(eq.getKeyId());
        builder.setEquipId(eq.getEquipId());
        builder.setPos(eq.getPos());
        builder.setIsLock(eq.isLock());
        for (List<Integer> skillId : eq.getLordEquipSkillList()) {
            // [军备技能id,等级]列表
            builder.addSkillLv(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }
        for (List<Integer> skillId : eq.getLordEquipSkillSecondList()) {
            // [军备技能id,等级]列表
            builder.addSkillLvSecond(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }
        builder.setLordEquipSaveType(eq.getLordEquipSaveType());
        return builder.build();
    }


    /**
     * 创建秘密武器信息
     *
     * @param weapon
     * @return
     */
    public static CrossTeamProto.SecretWeapon createSecretWeapon(SecretWeapon weapon) {
        CrossTeamProto.SecretWeapon.Builder builder = CrossTeamProto.SecretWeapon.newBuilder();
        builder.setId(weapon.getId());
        for (SecretWeaponBar bar : weapon.getBars()) {
            CrossTeamProto.SecretWeaponBar.Builder pbBar = CrossTeamProto.SecretWeaponBar.newBuilder();
            pbBar.setSid(bar.getSid());
            pbBar.setLocked(bar.isLock());
            builder.addBar(pbBar);
        }
        return builder.build();
    }

    /**
     * @param effect
     * @return
     */
    public static CrossTeamProto.AttackEffectPb createAttackEffectPb(AttackEffect effect) {
        CrossTeamProto.AttackEffectPb.Builder builder = CrossTeamProto.AttackEffectPb.newBuilder();
        builder.addAllUnlock(effect.getUnlock());
        builder.setType(effect.getType());
        builder.setUseId(effect.getUseId());
        return builder.build();
    }

    /**
     * 序列化作战实验室兵种调配
     *
     * @return
     */
    public static List<CrossTeamProto.GraduateInfoPb> createGraduateInfoPb(Map<Integer, Map<Integer, Integer>> graduateMap) {
        List<CrossTeamProto.GraduateInfoPb> list = new ArrayList<>();
        for (Map.Entry<Integer, Map<Integer, Integer>> typeEntry : graduateMap.entrySet()) {
            CrossTeamProto.GraduateInfoPb.Builder builder = CrossTeamProto.GraduateInfoPb.newBuilder();
            builder.setType(typeEntry.getKey());
            for (Map.Entry<Integer, Integer> skillEntry : typeEntry.getValue().entrySet()) {
                Integer level = skillEntry.getValue();
                if (level != null && level > 0) {
                    builder.addGraduateInfo(createTwoIntPb(skillEntry.getKey(), skillEntry.getValue()));
                }
            }
            list.add(builder.build());
        }
        return list;
    }

    static public CrossTeamProto.Science createPartySciencePb(PartyScience science) {
        CrossTeamProto.Science.Builder builder = CrossTeamProto.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        builder.setSchedule(science.getSchedule());
        return builder.build();
    }

    /**
     * 创建TwoInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CrossTeamProto.TwoInt createTwoIntPb(int p, int c) {
        CrossTeamProto.TwoInt.Builder builder = CrossTeamProto.TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    /**
     * 创建TwoInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CrossTeamProto.ThreeInt createThreeIntPb(int p, int c,int s) {
        CrossTeamProto.ThreeInt.Builder builder = CrossTeamProto.ThreeInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        builder.setV3(s);
        return builder.build();
    }


    /**
     * 创建TwoInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CommonPb.TwoInt createCommonTwoIntPb(int p, int c) {
        CommonPb.TwoInt.Builder builder = CommonPb.TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }



    static public CrossTeamProto.Form createFormPb(Form form) {
        CrossTeamProto.Form.Builder builder = CrossTeamProto.Form.newBuilder();
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

        if (form.getFormName() != null) {
            builder.setFormName(form.getFormName());
        }

        if (form.getTactics() != null && !form.getTactics().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTactics());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createTwoIntPb(e.getKey(), e.getValue()));
            }
        }

        return builder.build();
    }


    static public CommonPb.Form createFormPb(CrossTeamProto.Form form) {
        CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            builder.setAwakenHero(createCommonAwakenHeroPb(form.getAwakenHero()));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        for (Integer integer : form.getTacticsKeyIdList()) {
            builder.addTacticsKeyId(integer);
        }
        builder.setP1(createCommonTwoIntPb(form.getP1().getV1(), form.getP1().getV2()));
        builder.setP2(createCommonTwoIntPb(form.getP2().getV1(), form.getP2().getV2()));
        builder.setP3(createCommonTwoIntPb(form.getP3().getV1(), form.getP3().getV2()));
        builder.setP4(createCommonTwoIntPb(form.getP4().getV1(), form.getP4().getV2()));
        builder.setP5(createCommonTwoIntPb(form.getP5().getV1(), form.getP5().getV2()));
        builder.setP6(createCommonTwoIntPb(form.getP6().getV1(), form.getP6().getV2()));
        if (form.getFormName() != null) {
            builder.setFormName(form.getFormName());
        }
        List<CrossTeamProto.TwoInt> tacticsList = form.getTacticsList();
        for (CrossTeamProto.TwoInt twoInt : tacticsList) {
            builder.addTactics(createCommonTwoIntPb(twoInt.getV1(), twoInt.getV2()));
        }
        return builder.build();
    }


    /**
     * 组装rpc 矿信息
     * @param seniorMapData
     * @return
     */
    static public CommonPb.SeniorMapData createCorssMine(CrossSeniorMineProto.SeniorMapData seniorMapData){
        CommonPb.SeniorMapData.Builder msg =CommonPb.SeniorMapData.newBuilder();
        msg.setPos(seniorMapData.getPos());
        msg.setName(seniorMapData.getName());
        msg.setParty(seniorMapData.getParty());
        msg.setFreeTime(seniorMapData.getFreeTime());
        msg.setMy(seniorMapData.getMy());
        return msg.build();
    }



    static public CommonPb.Form createFormPb(CrossSeniorMineProto.MineForm form) {
        CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            CrossSeniorMineProto.MineAwakenHero awakenHero = form.getAwakenHero();
            builder.setAwakenHero(createCommonAwakenHeroPb(awakenHero));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        for (Integer integer : form.getTacticsKeyIdList()) {
            builder.addTacticsKeyId(integer);
        }
        builder.setP1(createCommonTwoIntPb(form.getP1().getV1(), form.getP1().getV2()));
        builder.setP2(createCommonTwoIntPb(form.getP2().getV1(), form.getP2().getV2()));
        builder.setP3(createCommonTwoIntPb(form.getP3().getV1(), form.getP3().getV2()));
        builder.setP4(createCommonTwoIntPb(form.getP4().getV1(), form.getP4().getV2()));
        builder.setP5(createCommonTwoIntPb(form.getP5().getV1(), form.getP5().getV2()));
        builder.setP6(createCommonTwoIntPb(form.getP6().getV1(), form.getP6().getV2()));
        if (form.getFormName() != null) {
            builder.setFormName(form.getFormName());
        }
        List<CrossSeniorMineProto.MineTwoInt> tacticsList = form.getTacticsList();
        for (CrossSeniorMineProto.MineTwoInt mineTwoInt : tacticsList) {
            builder.addTactics(createCommonTwoIntPb(mineTwoInt.getV1(), mineTwoInt.getV2()));
        }
        return builder.build();
    }

    /**
     * 跨服军矿form
     *
     * @param form
     * @return
     */
    public static CrossSeniorMineProto.MineForm createMineFormPb(Form form) {
        CrossSeniorMineProto.MineForm.Builder builder = CrossSeniorMineProto.MineForm.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            builder.setAwakenHero(createMineAwakenHeroPb(form.getAwakenHero()));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        v = form.p[0];
        if (v != 0) {
            builder.setP1(createMineTwoIntPb(v, form.c[0]));
        }
        v = form.p[1];
        if (v != 0) {
            builder.setP2(createMineTwoIntPb(v, form.c[1]));
        }
        v = form.p[2];
        if (v != 0) {
            builder.setP3(createMineTwoIntPb(v, form.c[2]));
        }
        v = form.p[3];
        if (v != 0) {
            builder.setP4(createMineTwoIntPb(v, form.c[3]));
        }
        v = form.p[4];
        if (v != 0) {
            builder.setP5(createMineTwoIntPb(v, form.c[4]));
        }
        v = form.p[5];
        if (v != 0) {
            builder.setP6(createMineTwoIntPb(v, form.c[5]));
        }

        if (form.getTactics() != null && !form.getTactics().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTactics());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createMineTwoIntPb(e.getKey(), e.getValue()));
            }
        }
        return builder.build();
    }

    public static CrossSeniorMineProto.MineAwakenHero createMineAwakenHeroPb(AwakenHero awakenHero) {
        CrossSeniorMineProto.MineAwakenHero.Builder builder = CrossSeniorMineProto.MineAwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(createMineTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }


    public static CrossSeniorMineProto.MineTwoInt createMineTwoIntPb(int p, int c) {
        CrossSeniorMineProto.MineTwoInt.Builder builder = CrossSeniorMineProto.MineTwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    static public CommonPb.ScoreRank createScoreRankPb(CrossSeniorMineProto.ScoreRank rank) {
        CommonPb.ScoreRank.Builder builder = CommonPb.ScoreRank.newBuilder();
        builder.setName(rank.getName());
        builder.setFight(rank.getFight());
        builder.setScore(rank.getScore());
        return builder.build();
    }

    static public CommonPb.ScoreRank createServerScoreRankPb(CrossSeniorMineProto.ServerScoreAward serverScoreAward) {
        CommonPb.ScoreRank.Builder builder = CommonPb.ScoreRank.newBuilder();
        builder.setName(serverScoreAward.getServerName());
        builder.setFight(serverScoreAward.getServerId());
        builder.setScore(serverScoreAward.getScore());
        return builder.build();
    }

    public static CommonPb.AwakenHero createCommonAwakenHeroPb(CrossSeniorMineProto.MineAwakenHero awakenHero) {
        CommonPb.AwakenHero.Builder builder = CommonPb.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());

        for (CrossSeniorMineProto.MineTwoInt mineTwoInt : awakenHero.getSkillLvList()) {
            builder.addSkillLv(createCommonTwoIntPb(mineTwoInt.getV1(), mineTwoInt.getV2()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

}
