package com.game.domain.table.party;

import com.game.cross.domain.CrossShopBuy;
import com.game.cross.domain.CrossTrend;
import com.game.crossParty.domain.PartyMember;
import com.game.domain.PEnergyCore;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.pb.CommonPb;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 玩家信息 @Author: hezhi @Date: 2019/3/11 17:15
 */
@Table(value = "cross_party_member_table", fetch = Table.FeatchType.START)
public class CrossPartyMemberTable implements KeyDataEntity<Long> {

    @Primary
    @Foreign
    @Column(value = "role_id", comment = "玩家role_id")
    private long roleId;

    @Column(value = "server_id", comment = "玩家server Id")
    private int serverId;

    @Column(value = "party_id", comment = "玩家partyId Id")
    private int partyId;

    @Column(value = "member_info", comment = "玩家信息")
    private byte[] memberInfo;

    @Column(value = "receivePersionRward", comment = "领取个人奖励玩家")
    private int receivePersionRward;

    @Column(value = "receiveLianShengRward", comment = "领取连胜奖励玩家")
    private int receiveLianShengRward;

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public byte[] getMemberInfo() {
        return memberInfo;
    }

    public void setMemberInfo(byte[] memberInfo) {
        this.memberInfo = memberInfo;
    }

    public int getReceivePersionRward() {
        return receivePersionRward;
    }

    public void setReceivePersionRward(int receivePersionRward) {
        this.receivePersionRward = receivePersionRward;
    }

    public int getReceiveLianShengRward() {
        return receiveLianShengRward;
    }

    public void setReceiveLianShengRward(int receiveLianShengRward) {
        this.receiveLianShengRward = receiveLianShengRward;
    }

    public byte[] serPartyMembers(PartyMember partyMember) {
        CommonPb.CPPartyMember cpPartyMemberPb = PbHelper.createCpPartyMemberPb(partyMember);
        return cpPartyMemberPb.toByteArray();
    }

    public PartyMember dserPartyMember() throws InvalidProtocolBufferException {

        if (memberInfo == null) {
            return null;
        }

        CommonPb.CPPartyMember cp = CommonPb.CPPartyMember.parseFrom(memberInfo);

        int serverId = cp.getServerId();
        long roleId = cp.getRoleId();
        String nick = cp.getNick();
        long fight = cp.getFight();
        int level = cp.getLevel();
        int groupWinNum = cp.getGroupWinNum();
        int finalWinNum = cp.getFinalWinNum();
        int fightCount = cp.getFightCount();
        int partyId = cp.getPartyId();
        String partyName = cp.getPartyName();
        int jifen = cp.getJifen();
        int regTime = cp.getRegTime();
        int portrait = 0;
        if (cp.hasPortrait()) {
            portrait = cp.getPortrait();
        }

        PartyMember p = new PartyMember();
        p.setServerId(serverId);
        p.setRoleId(roleId);
        p.setNick(nick);
        p.setFight(fight);
        p.setLevel(level);
        p.setGroupWinNum(groupWinNum);
        p.setFinalWinNum(finalWinNum);
        p.setFightCount(fightCount);
        p.setPartyId(partyId);
        p.setPartyName(partyName);
        p.setJifen(jifen);
        p.setRegTime(regTime);
        p.setPortrait(portrait);
        for (CommonPb.CrossTrend ct : cp.getCrossTrendsList()) {
            CrossTrend c = new CrossTrend();
            c.setTrendId(ct.getTrendId());
            c.setTrendTime(ct.getTrendTime());

            String[] s = new String[ct.getTrendParamCount()];
            ct.getTrendParamList().toArray(s);
            c.setTrendParam(s);

            p.crossTrends.add(c);
        }

        if (cp.hasJifenjiangli()) {
            p.setJifenjiangli(cp.getJifenjiangli());
        }
        if (cp.hasExchangeJifen()) {
            p.setExchangeJifen(cp.getExchangeJifen());
        }

        if (cp.getMyReportKeysCount() > 0) {
            p.getMyReportKeys().addAll(cp.getMyReportKeysList());
        }

        for (CommonPb.CrossShopBuy cs : cp.getCrossShopBuyList()) {
            CrossShopBuy c = new CrossShopBuy(cs);
            p.getCrossShopBuy().put(c.getShopId(), c);
        }

        if (cp.hasForm()) {
            p.setForm(PbHelper.createForm(cp.getForm()));
        }

        // 装备
        for (CommonPb.Equip pbEquip : cp.getEquipList()) {
            com.game.domain.p.Equip equip = PbHelper.createEquip(pbEquip);
            HashMap<Integer, com.game.domain.p.Equip> map = p.equips.get(equip.getPos());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.Equip>();
                p.equips.put(equip.getPos(), map);
            }
            map.put(equip.getKeyId(), equip);
        }

        // 配件
        for (CommonPb.Part e : cp.getPartList()) {
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
            HashMap<Integer, Part> map = p.parts.get(part.getPos());
            if (map == null) {
                map = new HashMap<Integer, Part>();
                p.parts.put(part.getPos(), map);
            }
            map.put(part.getKeyId(), part);
        }

        // 科技
        for (CommonPb.Science pbs : cp.getScienceList()) {
            com.game.domain.p.Science s = PbHelper.createScience(pbs);
            p.sciences.put(s.getScienceId(), s);
        }

        // 技能
        for (CommonPb.Skill skill : cp.getSkillList()) {
            p.skills.put(skill.getId(), skill.getLv());
        }

        // 影响
        for (CommonPb.Effect pbe : cp.getEffectList()) {
            Effect e = PbHelper.createEffect(pbe);
            p.effects.put(e.getEffectId(), e);
        }

        p.setStaffingId(cp.getStaffingId());

        for (CommonPb.EnergyStoneInlay pbe : cp.getInlayList()) {
            com.game.domain.p.EnergyStoneInlay e = PbHelper.createEnergyStoneInlay(pbe);

            Map<Integer, com.game.domain.p.EnergyStoneInlay> map = p.energyInlay.get(e.getPos());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.EnergyStoneInlay>();
                p.energyInlay.put(e.getPos(), map);
            }
            map.put(e.getHole(), e);
        }

        for (CommonPb.MilitaryScienceGrid pbmg : cp.getMilitaryScienceGridList()) {
            com.game.domain.p.MilitaryScienceGrid m = PbHelper.createMilitaryScieneceGrid(pbmg);

            HashMap<Integer, com.game.domain.p.MilitaryScienceGrid> map =
                    p.militaryScienceGrids.get(m.getTankId());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.MilitaryScienceGrid>();
                p.militaryScienceGrids.put(m.getTankId(), map);
            }
            map.put(m.getPos(), m);
        }
        for (CommonPb.MilitaryScience pbms : cp.getMilitaryScienceList()) {
            com.game.domain.p.MilitaryScience m = PbHelper.createMilitaryScienece(pbms);
            p.militarySciences.put(m.getMilitaryScienceId(), m);
        }

        p.setState(cp.getState());

        if (cp.hasInstForm()) {
            p.setInstForm(PbHelper.createForm(cp.getInstForm()));
        }

        // 勋章
        for (CommonPb.Medal mpb : cp.getMedalList()) {
            com.game.domain.p.Medal m = PbHelper.createMedal(mpb);

            HashMap<Integer, com.game.domain.p.Medal> map = p.medals.get(m.getPos());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.Medal>();
                p.medals.put(m.getPos(), map);
            }

            map.put(m.getKeyId(), m);
        }

        // 勋章展厅
        for (CommonPb.MedalBouns mpb : cp.getMedalBounsList()) {
            com.game.domain.p.MedalBouns m = PbHelper.createMedalBouns(mpb);

            HashMap<Integer, com.game.domain.p.MedalBouns> map = p.medalBounss.get(m.getState());
            if (map == null) {
                map = new HashMap<Integer, com.game.domain.p.MedalBouns>();
                p.medalBounss.put(m.getState(), map);
            }

            map.put(m.getMedalId(), m);
        }

        for (CommonPb.AwakenHero mpb : cp.getAwakenHeroList()) {
            AwakenHero ah = new AwakenHero(mpb);
            p.awakenHeros.put(ah.getKeyId(), ah);
        }

        // 军备信息
        if (cp.getLeqList() != null) {
            for (CommonPb.LordEquip pbLeq : cp.getLeqList()) {
                LordEquip leq = new LordEquip(pbLeq.getKeyId(), pbLeq.getEquipId(), pbLeq.getPos());
                p.lordEquips.put(leq.getPos(), leq);

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
        }

        // 军衔
        p.militaryRank = cp.getMilitaryRank();

        // 秘密武器
        if (cp.getSecretWeaponList() != null) {
            for (CommonPb.SecretWeapon pbw : cp.getSecretWeaponList()) {
                p.secretWeaponMap.put(pbw.getId(), new SecretWeapon(pbw));
            }
        }

        // 攻击特效
        if (cp.getAttackEffectList() != null) {
            for (CommonPb.AttackEffectPb pb : cp.getAttackEffectList()) {
                p.atkEffects.put(pb.getType(), new AttackEffect(pb));
            }
        }

        // 作战实验室
        if (cp.getGraduateInfoList() != null) {
            for (CommonPb.GraduateInfoPb pb : cp.getGraduateInfoList()) {
                Map<Integer, Integer> skillMap = p.graduateInfo.get(pb.getType());
                if (skillMap == null) p.graduateInfo.put(pb.getType(), skillMap = new HashMap<>());
                for (CommonPb.TwoInt twoInt : pb.getGraduateInfoList()) {
                    skillMap.put(twoInt.getV1(), twoInt.getV2());
                }
            }
        }

        if (cp.getPartyScienceList() != null) {

            List<CommonPb.Science> scienceList = cp.getPartyScienceList();

            for (CommonPb.Science science : scienceList) {
                PartyScience partyScience =
                        new PartyScience(science.getScienceId(), science.getScienceLv());
                partyScience.setSchedule(science.getSchedule());
                p.partyScienceMap.put(partyScience.getScienceId(), partyScience);
            }
        }
        p.setpEnergyCore(new PEnergyCore(cp.getEnergyCore().getV1(),cp.getEnergyCore().getV2(),cp.getEnergyCore().getV3()));

        return p;
    }
}
