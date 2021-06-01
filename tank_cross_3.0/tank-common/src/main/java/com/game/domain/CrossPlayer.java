package com.game.domain;

import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.util.CrossPbHelper;

import java.util.*;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/22 14:51
 * @description：跨服player
 */
public class CrossPlayer {

    /**
     * 游戏服id
     */
    private int serverId;

    /**
     * 玩家id
     */
    private long roleId;
    /**
     * 玩家昵称
     */
    private String nick;
    /**
     * 玩家战力
     */
    private long fight;
    /**
     * 玩家等级
     */
    private int level;
    /**
     * 开服时间
     */
    private int openTime;
    /**
     * 指挥官头像
     */
    private int portrait;

    /**
     * 编制id
     */
    private int StaffingId;
    /**
     * 军衔等级
     */
    private int militaryRank;
    /**
     * 阵型
     */
    private Map<Integer, Form> forms = new HashMap<Integer, Form>();
    /**
     * 装备
     */
    private HashMap<Integer, HashMap<Integer, Equip>> equips = new HashMap<Integer, HashMap<Integer, Equip>>();
    /**
     * 科技
     */
    private HashMap<Integer, Science> sciences = new HashMap<Integer, Science>();
    /**
     * 配件
     */
    private HashMap<Integer, HashMap<Integer, Part>> parts = new HashMap<Integer, HashMap<Integer, Part>>();
    /**
     * 技能
     */
    private HashMap<Integer, Integer> skills = new HashMap<Integer, Integer>();
    /**
     * 效果buff
     */
    private HashMap<Integer, Effect> effects = new HashMap<Integer, Effect>();
    /**
     * 能晶镶嵌信息
     */
    private Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay = new HashMap<Integer, Map<Integer, EnergyStoneInlay>>();
    /**
     * 军工科技 (科技id,科技信息)
     */
    private HashMap<Integer, MilitaryScience> militarySciences = new HashMap<Integer, MilitaryScience>();
    /**
     * 军工科技格子状态(tankId,pos,状态)
     */
    private HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids = new HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>>();
    /**
     * 勋章数据
     */
    private HashMap<Integer, HashMap<Integer, Medal>> medals = new HashMap<>();
    /**
     * 勋章展示数据
     */
    private HashMap<Integer, HashMap<Integer, MedalBouns>> medalBounss = new HashMap<>();
    /**
     * 将领觉醒集合
     */
    private HashMap<Integer, AwakenHero> awakenHeros = new HashMap<>();
    /**
     * 军备
     */
    private Map<Integer, LordEquip> lordEquips = new HashMap<>();

    /**
     * 秘密武器信息
     */
    private TreeMap<Integer, SecretWeapon> secretWeaponMap = new TreeMap<>();
    /**
     * 攻击特效
     */
    private Map<Integer, AttackEffect> atkEffects = new HashMap<>();
    /**
     * 作战实验室科技树
     */
    private Map<Integer, Map<Integer, Integer>> graduateInfo = new HashMap<>();
    /**
     * 军团科技列表
     */
    private Map<Integer, PartyScience> partyScienceMap = new HashMap<>();
    /**
     * 能源核心
     */
    private PEnergyCore pEnergyCore = new PEnergyCore();

    /**
     * 玩家军团id
     */
    private int partyId;

    /**
     * 军团名称
     */
    private String partyName;

    /**
     * vip
     */
    private int vip;

    /**
     * 荣耀点数
     */
    private int honor;

    private int pros;

    private int maxPros;

    /**
     * 跨服军团玩家积分
     */
    private int senScore;

    public CrossPlayer() {
    }

    public CrossPlayer(long roleId) {
        this.roleId = roleId;
    }

    public CrossPlayer(CrossTeamProto.RpcSynPlayerRequest request) {
        this.openTime = request.getOpenTime();
        this.serverId = request.getServerId();
        this.roleId = request.getRoleId();
        this.nick = request.getNick();
        this.fight = request.getFight();
        this.level = request.getLevel();
        this.portrait = request.getPortrait();
        this.StaffingId = request.getStaffingId();
        this.militaryRank = request.getMilitaryRank();
        Form form = CrossPbHelper.createForm(request.getForm());
        this.forms.put(form.getType(), form); //初始化阵型
        this.dserEquip(equips, request.getEquipList()); //初始化装备
        this.dserScience(sciences, request.getScienceList());
        this.dserPart(parts, request.getPartList());
        this.dserSkill(skills, request.getSkillList());
        this.dserEffect(effects, request.getEffectList());
        this.dserEnergyStone(energyInlay, request.getInlayList());
        this.dserMilitaryScience(militarySciences, request.getMilitaryScienceList());
        this.dserMilitaryScienceGrid(militaryScienceGrids, request.getMilitaryScienceGridList());
        this.dserMedal(medals, request.getMedalList());
        this.dserMedalBounds(medalBounss, request.getMedalBounsList());
        this.dserAwakenHeros(awakenHeros, request.getAwakenHeroList());
        this.dserLordEquip(lordEquips, request.getLeqList());
        this.dserSecretWeapon(secretWeaponMap, request.getSecretWeaponList());
        this.dserAttackEffects(atkEffects, request.getAtkEftList());
        this.dserGraduateInfo(graduateInfo, request.getGraduateInfoList());
        this.dserPartyScience(partyScienceMap, request.getPartyScienceList());
        this.dserEnergyCore(request.getEnergyCore());
        this.partyId = request.getPartyId();
        this.partyName = request.getPartyName();
        this.vip = request.getVip();
        this.honor = request.getHonor();
        this.pros = request.getPros();
        this.maxPros = request.getMaxPros();
        this.senScore = request.getCrossMineScore();
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getStaffingId() {
        return StaffingId;
    }

    public void setStaffingId(int staffingId) {
        StaffingId = staffingId;
    }

    public int getMilitaryRank() {
        return militaryRank;
    }

    public void setMilitaryRank(int militaryRank) {
        this.militaryRank = militaryRank;
    }

    public Map<Integer, Form> getForms() {
        return forms;
    }

    public void setForms(Map<Integer, Form> forms) {
        this.forms = forms;
    }

    public HashMap<Integer, HashMap<Integer, Equip>> getEquips() {
        return equips;
    }

    public void setEquips(HashMap<Integer, HashMap<Integer, Equip>> equips) {
        this.equips = equips;
    }

    public HashMap<Integer, Science> getSciences() {
        return sciences;
    }

    public void setSciences(HashMap<Integer, Science> sciences) {
        this.sciences = sciences;
    }

    public HashMap<Integer, HashMap<Integer, Part>> getParts() {
        return parts;
    }

    public void setParts(HashMap<Integer, HashMap<Integer, Part>> parts) {
        this.parts = parts;
    }

    public HashMap<Integer, Integer> getSkills() {
        return skills;
    }

    public void setSkills(HashMap<Integer, Integer> skills) {
        this.skills = skills;
    }

    public HashMap<Integer, Effect> getEffects() {
        return effects;
    }

    public void setEffects(HashMap<Integer, Effect> effects) {
        this.effects = effects;
    }

    public Map<Integer, Map<Integer, EnergyStoneInlay>> getEnergyInlay() {
        return energyInlay;
    }

    public void setEnergyInlay(Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay) {
        this.energyInlay = energyInlay;
    }

    public HashMap<Integer, MilitaryScience> getMilitarySciences() {
        return militarySciences;
    }

    public void setMilitarySciences(HashMap<Integer, MilitaryScience> militarySciences) {
        this.militarySciences = militarySciences;
    }

    public HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> getMilitaryScienceGrids() {
        return militaryScienceGrids;
    }

    public void setMilitaryScienceGrids(HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids) {
        this.militaryScienceGrids = militaryScienceGrids;
    }

    public HashMap<Integer, HashMap<Integer, Medal>> getMedals() {
        return medals;
    }

    public void setMedals(HashMap<Integer, HashMap<Integer, Medal>> medals) {
        this.medals = medals;
    }

    public HashMap<Integer, HashMap<Integer, MedalBouns>> getMedalBounss() {
        return medalBounss;
    }

    public void setMedalBounss(HashMap<Integer, HashMap<Integer, MedalBouns>> medalBounss) {
        this.medalBounss = medalBounss;
    }

    public HashMap<Integer, AwakenHero> getAwakenHeros() {
        return awakenHeros;
    }

    public void setAwakenHeros(HashMap<Integer, AwakenHero> awakenHeros) {
        this.awakenHeros = awakenHeros;
    }

    public Map<Integer, LordEquip> getLordEquips() {
        return lordEquips;
    }

    public void setLordEquips(Map<Integer, LordEquip> lordEquips) {
        this.lordEquips = lordEquips;
    }

    public TreeMap<Integer, SecretWeapon> getSecretWeaponMap() {
        return secretWeaponMap;
    }

    public void setSecretWeaponMap(TreeMap<Integer, SecretWeapon> secretWeaponMap) {
        this.secretWeaponMap = secretWeaponMap;
    }

    public Map<Integer, AttackEffect> getAtkEffects() {
        return atkEffects;
    }

    public void setAtkEffects(Map<Integer, AttackEffect> atkEffects) {
        this.atkEffects = atkEffects;
    }

    public Map<Integer, Map<Integer, Integer>> getGraduateInfo() {
        return graduateInfo;
    }

    public void setGraduateInfo(Map<Integer, Map<Integer, Integer>> graduateInfo) {
        this.graduateInfo = graduateInfo;
    }

    public Map<Integer, PartyScience> getPartyScienceMap() {
        return partyScienceMap;
    }

    public void setPartyScienceMap(Map<Integer, PartyScience> partyScienceMap) {
        this.partyScienceMap = partyScienceMap;
    }

    public int getPortrait() {
        return portrait;
    }

    public void setPortrait(int portrait) {
        this.portrait = portrait;
    }

    public int getOpenTime() {
        return openTime;
    }

    public void setOpenTime(int openTime) {
        this.openTime = openTime;
    }

    public PEnergyCore getpEnergyCore() {
        return pEnergyCore;
    }

    public void setpEnergyCore(PEnergyCore pEnergyCore) {
        this.pEnergyCore = pEnergyCore;
    }

    private void dserEquip(HashMap<Integer, HashMap<Integer, Equip>> equips, List<CrossTeamProto.Equip> equipList) {
        if (equipList != null) {
            for (CrossTeamProto.Equip eq : equipList) {
                Equip equip = new Equip(eq);
                HashMap<Integer, Equip> map = equips.get(equip.getPos());
                if (map == null) {
                    map = new HashMap<>();
                    equips.put(equip.getPos(), map);
                }
                map.put(equip.getKeyId(), equip);
            }
        }
    }

    private void dserScience(HashMap<Integer, Science> sciences, List<CrossTeamProto.Science> scienceList) {
        if (scienceList != null) {
            for (CrossTeamProto.Science science : scienceList) {
                Science s = new Science(science);
                sciences.put(s.getScienceId(), s);
            }
        }
    }

    private void dserPart(HashMap<Integer, HashMap<Integer, Part>> parts, List<CrossTeamProto.Part> partList) {
        if (partList != null) {
            for (CrossTeamProto.Part e : partList) {
                boolean locked = false;
                if (e.hasLocked()) {
                    locked = e.getLocked();
                }
                Map<Integer, Integer[]> mapAttr = new HashMap<>();
                for (CrossTeamProto.PartSmeltAttr attr : e.getAttrList()) {
                    Integer[] i = new Integer[]{attr.getVal(), attr.getNewVal()};
                    mapAttr.put(attr.getId(), i);
                }
                Part part = new Part(e.getKeyId(), e.getPartId(), e.getUpLv(), e.getRefitLv(), e.getPos(), locked, e.getSmeltLv(), e.getSmeltExp(), mapAttr, e.getSaved());
                HashMap<Integer, Part> map = parts.get(part.getPos());
                if (map == null) {
                    map = new HashMap<>();
                    parts.put(part.getPos(), map);
                }
                map.put(part.getKeyId(), part);
            }
        }
    }

    private void dserSkill(HashMap<Integer, Integer> skills, List<CrossTeamProto.Skill> skillList) {
        if (skillList != null) {
            if (skillList != null) {
                for (CrossTeamProto.Skill skill : skillList) {
                    skills.put(skill.getId(), skill.getLv());
                }
            }
        }
    }

    private void dserEffect(HashMap<Integer, Effect> effects, List<CrossTeamProto.Effect> effectList) {
        if (effectList != null) {
            for (CrossTeamProto.Effect pbe : effectList) {
                Effect e = new Effect(pbe);
                effects.put(e.getEffectId(), e);
            }
        }
    }

    private void dserEnergyStone(Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay, List<CrossTeamProto.EnergyStoneInlay> inlayList) {
        if (inlayList != null) {
            for (CrossTeamProto.EnergyStoneInlay pbe : inlayList) {
                EnergyStoneInlay e = new EnergyStoneInlay(pbe);
                Map<Integer, EnergyStoneInlay> map = energyInlay.get(e.getPos());
                if (map == null) {
                    map = new HashMap<>();
                    energyInlay.put(e.getPos(), map);
                }
                map.put(e.getHole(), e);
            }
        }
    }

    private void dserMilitaryScience(HashMap<Integer, MilitaryScience> militarySciences, List<CrossTeamProto.MilitaryScience> militaryScienceList) {
        if (militaryScienceList != null) {
            for (CrossTeamProto.MilitaryScience pbms : militaryScienceList) {
                MilitaryScience m = new MilitaryScience(pbms);
                militarySciences.put(m.getMilitaryScienceId(), m);
            }
        }
    }

    private void dserMilitaryScienceGrid(HashMap<Integer, HashMap<Integer, MilitaryScienceGrid>> militaryScienceGrids, List<CrossTeamProto.MilitaryScienceGrid> militaryScienceGridList) {
        if (militaryScienceGridList != null) {
            for (CrossTeamProto.MilitaryScienceGrid pbmg : militaryScienceGridList) {
                MilitaryScienceGrid m = new MilitaryScienceGrid(pbmg);
                HashMap<Integer, MilitaryScienceGrid> map = militaryScienceGrids.get(m.getTankId());
                if (map == null) {
                    map = new HashMap<>();
                    militaryScienceGrids.put(m.getTankId(), map);
                }
                map.put(m.getPos(), m);
            }
        }
    }

    private void dserMedal(HashMap<Integer, HashMap<Integer, Medal>> medals, List<CrossTeamProto.Medal> medalList) {
        if (medalList != null) {
            for (CrossTeamProto.Medal mpb : medalList) {
                Medal m = new Medal(mpb);
                HashMap<Integer, Medal> map = medals.get(m.getPos());
                if (map == null) {
                    map = new HashMap<>();
                    medals.put(m.getPos(), map);
                }
                map.put(m.getKeyId(), m);
            }
        }
    }

    private void dserMedalBounds(HashMap<Integer, HashMap<Integer, MedalBouns>> medalBounss, List<CrossTeamProto.MedalBouns> medalBounsList) {
        if (medalBounsList != null) {
            for (CrossTeamProto.MedalBouns mpb : medalBounsList) {
                MedalBouns m = new MedalBouns(mpb);
                HashMap<Integer, MedalBouns> map = medalBounss.get(m.getState());
                if (map == null) {
                    map = new HashMap<>();
                    medalBounss.put(m.getState(), map);
                }
                map.put(m.getMedalId(), m);
            }
        }
    }

    private void dserAwakenHeros(HashMap<Integer, AwakenHero> awakenHeros, List<CrossTeamProto.AwakenHero> awakenHeroList) {
        if (awakenHeroList != null) {
            for (CrossTeamProto.AwakenHero mpb : awakenHeroList) {
                awakenHeros.put(mpb.getKeyId(), new AwakenHero(mpb));
            }
        }
    }

    private void dserLordEquip(Map<Integer, LordEquip> lordEquip, List<CrossTeamProto.LordEquip> lordEquips) {
        if (lordEquips != null && !lordEquips.isEmpty()) {
            for (CrossTeamProto.LordEquip pbLeq : lordEquips) {
                LordEquip leq = new LordEquip(pbLeq.getKeyId(), pbLeq.getEquipId(), pbLeq.getPos());
                lordEquip.put(leq.getPos(), leq);
                leq.setLordEquipSaveType(pbLeq.getLordEquipSaveType());
                // 获取军备技能
                List<List<Integer>> skillList = leq.getLordEquipSkillList();
                List<CrossTeamProto.TwoInt> twoIntList = pbLeq.getSkillLvList();
                for (CrossTeamProto.TwoInt twoInt : twoIntList) {
                    List<Integer> skill = new ArrayList<Integer>(2);
                    skill.add(twoInt.getV1());
                    skill.add(twoInt.getV2());
                    skillList.add(skill);
                }
                List<List<Integer>> lordEquipSkillSecondList = leq.getLordEquipSkillSecondList();
                List<CrossTeamProto.TwoInt> twoIntSecondList = pbLeq.getSkillLvSecondList();
                for (CrossTeamProto.TwoInt twoInt : twoIntSecondList) {
                    List<Integer> skill = new ArrayList<Integer>(2);
                    skill.add(twoInt.getV1());
                    skill.add(twoInt.getV2());
                    lordEquipSkillSecondList.add(skill);
                }
            }
        }
    }

    /**
     * 加载秘密武器
     *
     * @param pbWeapons
     */
    private void dserSecretWeapon(TreeMap<Integer, SecretWeapon> secretWeaponMap, List<CrossTeamProto.SecretWeapon> pbWeapons) {
        if (pbWeapons != null && !pbWeapons.isEmpty()) {
            for (CrossTeamProto.SecretWeapon pbw : pbWeapons) {
                SecretWeapon secretWeapon = new SecretWeapon(pbw);
                secretWeaponMap.put(pbw.getId(), secretWeapon);
            }
        }
    }

    /**
     * 加载攻击特效
     *
     * @param effectPbs
     */
    private void dserAttackEffects(Map<Integer, AttackEffect> atkEffects, List<CrossTeamProto.AttackEffectPb> effectPbs) {
        if (effectPbs != null && !effectPbs.isEmpty()) {
            for (CrossTeamProto.AttackEffectPb pb : effectPbs) {
                atkEffects.put(pb.getType(), new AttackEffect(pb));
            }
        }
    }

    /**
     * 加载作战实验室科技树
     *
     * @param pbs
     */
    private void dserGraduateInfo(Map<Integer, Map<Integer, Integer>> graduateInfo, List<CrossTeamProto.GraduateInfoPb> pbs) {
        if (pbs != null) {
            for (CrossTeamProto.GraduateInfoPb pb : pbs) {
                Map<Integer, Integer> skillMap = graduateInfo.get(pb.getType());
                if (skillMap == null) {
                    graduateInfo.put(pb.getType(), skillMap = new HashMap<>());
                }
                for (CrossTeamProto.TwoInt ti : pb.getGraduateInfoList()) {
                    skillMap.put(ti.getV1(), ti.getV2());
                }
            }
        }
    }

    /**
     * 加载军团科技列表
     *
     * @param partyScienceList
     */
    private void dserPartyScience(Map<Integer, PartyScience> partyScienceMap, List<CrossTeamProto.Science> partyScienceList) {
        if (partyScienceList != null) {
            for (CrossTeamProto.Science s : partyScienceList) {
                PartyScience partyScience = new PartyScience(s.getScienceId(), s.getScienceLv());
                partyScience.setSchedule(s.getSchedule());
                partyScienceMap.put(partyScience.getScienceId(), partyScience);
            }
        }
    }

    /**
     * 初始化能源核心
     *
     * @param energy
     */
    private void dserEnergyCore(CrossTeamProto.ThreeInt energy) {
        if (energy != null) {
            this.pEnergyCore = new PEnergyCore(energy.getV1(), energy.getV2(), energy.getV3());
        }
    }

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public String getPartyName() {
        return partyName;
    }

    public void setPartyName(String partyName) {
        this.partyName = partyName;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getHonor() {
        return honor;
    }

    public void setHonor(int honor) {
        this.honor = honor;
    }

    public int getPros() {
        return pros;
    }

    public void setPros(int pros) {
        this.pros = pros;
    }

    public int getMaxPros() {
        return maxPros;
    }

    public void setMaxPros(int maxPros) {
        this.maxPros = maxPros;
    }

    public int getSenScore() {
        return senScore;
    }

    public void setSenScore(int senScore) {
        this.senScore = senScore;
    }
}
