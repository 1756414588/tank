package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.constant.*;
import com.game.cross.domain.Athlete;
import com.game.crossParty.domain.PartyMember;
import com.game.datamgr.*;
import com.game.domain.CrossPlayer;
import com.game.domain.PEnergyCore;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.*;
import com.game.domain.s.tactics.StaticTacticsTankSuit;
import com.game.fight.domain.AttrData;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.util.LogUtil;
import com.game.util.MapUtil;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun @ClassName: FightService @Description: TODO
 * @date 2015年8月28日 下午4:20:00
 */
@Service
public class FightService {
    @Autowired
    private StaticTankDataMgr staticTankDataMgr;
    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;
    @Autowired
    private StaticPartDataMgr staticPartDataMgr;
    @Autowired
    private StaticRefineDataMgr staticRefineDataMgr;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;
    @Autowired
    private StaticLabDataMgr staticLabDataMgr;
    @Autowired
    private StaticCombatDataMgr staticCombatDataMgr;
    @Autowired
    private StaticMilitaryDataMgr staticMilitaryDataMgr;
    @Autowired
    private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;
    @Autowired
    private StaticFortressDataMgr staticFortressDataMgr;
    @Autowired
    private StaticMedalDataMgr staticMedalDataMgr;
    @Autowired
    private StaticLordDataMgr staticLordDataMgr;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private StaticSecretWeaponDataMgr staticSecretWeaponDataMgr;
    @Autowired
    private StaticCoreDataMgr staticCoreDataMgr;

    private Fighter createFighter() {
        Fighter fighter = new Fighter();
        return fighter;
    }

    /**
     * 玩家战斗单位
     *
     * @param player
     * @param form
     * @param type
     * @return Fighter
     */
    public Fighter createFighter(CrossPlayer player, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createForce(player, i + 1, p[i], c[i], form), i + 1);
        }
        StaticHero staticHero = null;
        if (form.getAwakenHero() != null) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getAwakenHero().getHeroId());
        } else if (form.getCommander() > 0) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
        }
        if (staticHero != null) {
            effectHero(fighter, staticHero, type);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), type);
        }
        fighter.tacticsList.addAll(new ArrayList<>(form.getTacticsList()));
        fighter.crossPlayer = player;
        return fighter;
    }


    /**
     * 矿点战斗单位
     *
     * @param staticMineForm
     * @return Fighter
     */
    public Fighter createFighter(StaticMineForm staticMineForm) {
        Fighter fighter = createFighter();
        fighter.addForce(createForce(staticMineForm, 1), 1);
        fighter.addForce(createForce(staticMineForm, 2), 2);
        fighter.addForce(createForce(staticMineForm, 3), 3);
        fighter.addForce(createForce(staticMineForm, 4), 4);
        fighter.addForce(createForce(staticMineForm, 5), 5);
        fighter.addForce(createForce(staticMineForm, 6), 6);
        return fighter;
    }

    public Force createForce(StaticMineForm staticMineForm, int pos) {
        List<Integer> slot = staticMineForm.getForm().get(pos - 1);
        if (slot.isEmpty()) {
            return null;
        }

        int tankId = slot.get(0);
        int count = slot.get(1);

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        List<Integer> attrs = staticMineForm.getAttr().get(pos - 1);
        AttrData attrData = new AttrData(attrs);

        return new Force(staticTank, attrData, pos, count);
    }


    /**
     * 创建一个战斗格子（一个阵型有6个格子）
     *
     * @param player
     * @param pos
     * @param tankId
     * @param count
     * @param form
     * @return Force
     */
    public Force createForce(CrossPlayer player, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, player.getEquips().get(pos));
        partAttr(attrData, player.getParts().get(staticTank.getType()));
        militaryAttr(attrData, player.getMilitaryScienceGrids().get(tankId), player.getMilitarySciences());
        scienceAttr(staticTank.getType(), attrData, player.getSciences(), player.getPartyScienceMap());
        skillAttr(staticTank.getType(), attrData, player.getSkills());
        effectAttr(player.getEffects(), player.getStaffingId(), attrData);
        energyStoneAttr(attrData, player.getEnergyInlay().get(pos));// 能晶加成
        secretWeaponAttr(player.getSecretWeaponMap(), attrData, pos);// 秘密武器加成
        medalAttr(attrData, player.getMedals().get(1));// 勋章
        medalBounsAttr(attrData, player.getMedalBounss().get(1));// 勋章展厅
        lordEquiqAttr(attrData, player.getLordEquips());// 军备属性
        militaryRankAttr(attrData, player.getMilitaryRank());// 军衔属性
        heroAwakenSkill(attrData, form.getAwakenHero());// 将领觉醒技能
        fightLabAttr(attrData, player.getGraduateInfo(), staticTank);// 作战实验室
        addEnergyAttr(player.getpEnergyCore(), attrData);//能源核心点亮加成(按等级全部加成)
        addEnergyPosCoreAttr(attrData, player.getpEnergyCore(), pos); //能源核心点亮加成(只加对应位置)

        // 设置攻击特效
        int eid = getAttackEffectId(player, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(force, form, staticTank);//战术大师属性

        return force;
    }


    public Fighter createCrossFighter(Athlete attacker, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createCrossForce(attacker, i + 1, p[i], c[i], form), i + 1);
        }
        StaticHero staticHero = null;
        if (form.getAwakenHero() != null) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getAwakenHero().getHeroId());
        } else if (form.getCommander() > 0) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
        }
        if (staticHero != null) {
            effectHero(fighter, staticHero, type);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), type);
        }
        fighter.secretWeaponMap = attacker.secretWeaponMap;
        fighter.tacticsList = form.getTacticsList();
        return fighter;
    }

    public Fighter createCrossPartyFighter(PartyMember attacker, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createCrossPartyForce(attacker, i + 1, p[i], c[i], form), i + 1);
        }
        StaticHero staticHero = null;
        if (form.getAwakenHero() != null) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getAwakenHero().getHeroId());
        } else if (form.getCommander() > 0) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
        }
        if (staticHero != null) {
            effectHero(fighter, staticHero, type);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), type);
        }
        fighter.secretWeaponMap = attacker.secretWeaponMap;
        fighter.tacticsList = form.getTacticsList();
        return fighter;
    }

    private Force createCrossForce(Athlete athlete, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, athlete.equips.get(pos)); // 加装备属性
        partAttr(attrData, athlete.parts.get(staticTank.getType())); // 加配件属性
        militaryAttr(attrData, athlete.militaryScienceGrids.get(tankId), athlete.militarySciences); // 军工科技对属性加层
        scienceAttr(staticTank.getType(), attrData, athlete.sciences, athlete.partyScienceMap); // 加科技属性
        skillAttr(staticTank.getType(), attrData, athlete.skills); // 加技能属性
        effectAttr(athlete.effects, athlete.StaffingId, attrData);
        energyStoneAttr(attrData, athlete.energyInlay.get(pos)); // 能晶加成
        secretWeaponAttr(athlete.secretWeaponMap, attrData, pos); // 秘密武器
        medalAttr(attrData, athlete.medals.get(1)); // 勋章
        medalBounsAttr(attrData, athlete.medalBounss.get(1)); // 勋章展厅
        heroAwakenSkill(attrData, form.getAwakenHero()); // 将领觉醒技能
        lordEquiqAttr(attrData, athlete.lordEquips); // 军备属性
        militaryRankAttr(attrData, athlete.militaryRank); // 军衔属性
        fightLabAttr(attrData, athlete.graduateInfo, staticTank); // 作战实验室
        addEnergyAttr(athlete.getpEnergyCore(), attrData);//能源核心点亮加成(按等级全部加成)
        addEnergyPosCoreAttr(attrData, athlete.getpEnergyCore(), pos); //能源核心点亮加成(只加对应位置)

        // 设置攻击特效
        int eid = getAttackEffectId(athlete, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(force, form, staticTank);
        return force;
    }


    /**
     * 战术属性
     *
     * @param force
     * @param form
     * @param staticTank
     */
    private void tacticsAttr(Force force, Form form, StaticTank staticTank) {
        Map<Integer, Integer> attr = new HashMap<>();
        List<TowInt> tacticsList = form.getTacticsList();
        // 战术基础属性
        Map<Integer, Integer> baseAttribute = tacticsService.getBaseAttribute(tacticsList);
        // 战术 全部装配单一效果战术属性
        Map<Integer, Integer> taozhaungAttribute = tacticsService.getTaozhaungAttribute(tacticsList);
        // 兵种套属性
        Map<Integer, Integer> tankTypeAttribute = tacticsService.getTankTypeAttribute(tacticsList, staticTank);
        // 这个用于伤害计算
        StaticTacticsTankSuit tankTypeAttributeConfig = tacticsService.getTankTypeAttributeConfig(tacticsList);
        if (tankTypeAttributeConfig != null && staticTank.getType() == tacticsService.getTankType(tacticsList)) {
            force.tacticsTankSuitConfig = tankTypeAttributeConfig;
        }
        MapUtil.addMapValue(attr, baseAttribute);
        MapUtil.addMapValue(attr, taozhaungAttribute);
        MapUtil.addMapValue(attr, tankTypeAttribute);
        // 添加属性
        for (Entry<Integer, Integer> e : attr.entrySet()) {
            force.attrData.addValue(e.getKey(), e.getValue());
        }
    }

    private Force createCrossPartyForce(PartyMember athlete, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, athlete.equips.get(pos));
        partAttr(attrData, athlete.parts.get(staticTank.getType()));
        militaryAttr(attrData, athlete.militaryScienceGrids.get(tankId), athlete.militarySciences);
        scienceAttr(staticTank.getType(), attrData, athlete.sciences, athlete.partyScienceMap);
        skillAttr(staticTank.getType(), attrData, athlete.skills);
        effectAttr(athlete.effects, athlete.StaffingId, attrData);
        energyStoneAttr(attrData, athlete.energyInlay.get(pos)); // 能晶加成
        secretWeaponAttr(athlete.secretWeaponMap, attrData, pos); // 秘密武器
        medalAttr(attrData, athlete.medals.get(1)); // 勋章
        medalBounsAttr(attrData, athlete.medalBounss.get(1)); // 勋章展厅
        heroAwakenSkill(attrData, form.getAwakenHero()); // 将领觉醒技能
        lordEquiqAttr(attrData, athlete.lordEquips); // 军备属性
        militaryRankAttr(attrData, athlete.militaryRank); // 军衔属性
        fightLabAttr(attrData, athlete.graduateInfo, staticTank); // 作战实验室
        addEnergyAttr(athlete.getpEnergyCore(), attrData);//能源核心点亮加成(按等级全部加成)
        addEnergyPosCoreAttr(attrData, athlete.getpEnergyCore(), pos);//能源核心点亮加成(只加对应位置)
        // 设置攻击特效
        int eid = getAttackEffectId(athlete, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(force, form, staticTank);
        return force;
    }

    private void equipAttr(AttrData attrData, Map<Integer, Equip> equips) {
        if (equips != null) {
            Iterator<Equip> it = equips.values().iterator();
            int blue = 0;
            int purple = 0;
            int orange = 0;
            while (it.hasNext()) {
                Equip equip = it.next();
                StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equip.getEquipId());
                int attrId = staticEquip.getAttributeId();
                int value = staticEquip.getA() + staticEquip.getB() * (equip.getLv() - 1);
                if (equip.getStarlv() > 0) {
                    StaticEquipUpStar equipStar = staticEquipDataMgr.getEquipStar(equip.getStarlv() - 1);
                    if (equipStar != null) {
                        value += staticEquip.getB() * equipStar.getStarUpProperty();
                    }
                }
                attrData.addValue(attrId, value);
                if (staticEquip.getQuality() == 3) {
                    blue++;
                } else if (staticEquip.getQuality() == 4) {
                    purple++;
                } else if (staticEquip.getQuality() == 5) {
                    orange++;
                }
            }
            // 6件橙色装备激活所有套装属性
            for (StaticEquipBonusAttribute bonusAttribute : staticEquipDataMgr.getBonusAttribute()) {
                if (bonusAttribute.getQuality() == 3) {
                    if (blue + orange >= bonusAttribute.getNumber()) { // 蓝色套装激活
                        for (List<Integer> attr : bonusAttribute.getAttribute()) {
                            attrData.addValue(attr.get(0), attr.get(1));
                        }
                    }
                } else if (bonusAttribute.getQuality() == 4) {
                    if (purple + orange >= bonusAttribute.getNumber()) { // 紫色套装激活
                        for (List<Integer> attr : bonusAttribute.getAttribute()) {
                            attrData.addValue(attr.get(0), attr.get(1));
                        }
                    }
                } else if (bonusAttribute.getQuality() == 5) {
                    if (orange >= bonusAttribute.getNumber()) { // 橙色套装激活
                        for (List<Integer> attr : bonusAttribute.getAttribute()) {
                            attrData.addValue(attr.get(0), attr.get(1));
                        }
                    }
                }
            }
        }
    }

    /**
     * 勋章属性
     */
    private void medalAttr(AttrData attrData, Map<Integer, Medal> medals) {
        if (medals != null) {
            Iterator<Medal> it = medals.values().iterator();
            while (it.hasNext()) {
                Medal medal = it.next();
                StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medal.getMedalId());
                int attrId1 = staticMedal.getAttr1();
                int value1 = staticMedal.getA1() * (medal.getUpLv() + 1) + staticMedal.getB1() * medal.getRefitLv();
                int attrId2 = staticMedal.getAttr2();
                int value2 = staticMedal.getA2() * (medal.getUpLv() + 1) + staticMedal.getB2() * medal.getRefitLv();
                attrData.addValue(attrId1, value1);
                attrData.addValue(attrId2, value2);
                if (medal.getRefitLv() >= 10 && Constant.MEDAL_RATE > 0) {
                    int a = (int) (staticMedal.getA1() * (medal.getUpLv() + 1) * (Constant.MEDAL_RATE / 100.0f));
                    int b = (int) (staticMedal.getA2() * (medal.getUpLv() + 1) * (Constant.MEDAL_RATE / 100.0f));
                    attrData.addValue(attrId1, a);
                    attrData.addValue(attrId2, b);
                }
            }
        }
    }

    /**
     * 勋章展示属性
     */
    private void medalBounsAttr(AttrData attrData, Map<Integer, MedalBouns> medalBounss) {
        if (medalBounss != null) {
            Iterator<MedalBouns> it = medalBounss.values().iterator();
            while (it.hasNext()) {
                MedalBouns medalBouns = it.next();
                StaticMedal staticMedal = staticMedalDataMgr.getStaticMedal(medalBouns.getMedalId());
                for (List<Integer> attr : staticMedal.getAttrShowed()) {
                    attrData.addValue(attr.get(0), attr.get(1));
                }
            }
            // 套装
            int number = medalBounss.size();
            for (StaticMedalBouns staticMedalBouns : staticMedalDataMgr.getMedalBounsList()) {
                if (number >= staticMedalBouns.getNumber()) {
                    for (List<Integer> attr : staticMedalBouns.getBonus()) {
                        attrData.addValue(attr.get(0), attr.get(1));
                    }
                }
            }
        }
    }

    private void partAttr(AttrData attrData, Map<Integer, Part> equips) {
        if (equips != null) {
            Iterator<Part> it = equips.values().iterator();
            while (it.hasNext()) {
                Part part = it.next();
                StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
                int attrId1 = staticPart.getAttr1();
                int value1 = staticPart.getA1() * (part.getUpLv() + 1) + staticPart.getB1() * part.getRefitLv();
                int attrId2 = staticPart.getAttr2();
                int value2 = staticPart.getA2() * (part.getUpLv() + 1) + staticPart.getB2() * part.getRefitLv();
                int attrId3 = staticPart.getAttr3();
                int value3 = staticPart.getA3() * (part.getUpLv() + 1) + staticPart.getB3() * part.getRefitLv();
                attrData.addValue(attrId1, value1);
                attrData.addValue(attrId2, value2);
                attrData.addValue(attrId3, value3);
                // 配件淬炼属性
                for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
                    attrData.addValue(entry.getKey(), entry.getValue()[0]);
                }
                // 配件淬炼激活属性
                for (int i = 0; i < staticPart.getUnlockAttr().size(); i++) {
                    // 激活属性
                    List<Integer> attr = staticPart.getUnlockAttr().get(i);
                    // 激活条件
                    List<Integer> condi = staticPart.getUnlockAttrCondition().get(i);
                    Integer[] val = part.getSmeltAttr().get(condi.get(0));
                    if (val != null && val[0] >= condi.get(1)) {
                        attrData.addValue(attr.get(0), attr.get(1));
                    }
                }
            }
        }
    }

    /**
     * 秘密武器加成
     *
     * @param secretWeaponMap
     * @param attrData
     * @param pos
     */
    private void secretWeaponAttr(Map<Integer, SecretWeapon> secretWeaponMap, AttrData attrData, int pos) {
        if (!secretWeaponMap.isEmpty()) {
            for (Entry<Integer, SecretWeapon> entry : secretWeaponMap.entrySet()) {
                List<SecretWeaponBar> bars = entry.getValue().getBars();
                if (!bars.isEmpty()) {
                    for (SecretWeaponBar bar : bars) {
                        StaticSecretWeaponSkill data = staticSecretWeaponDataMgr.getSecretWeaponSkill(bar.getSid());
                        if (data != null && data.getPos() == pos) {
                            List<Integer> atts = data.getAttr();
                            if (atts.size() == 2) {
                                attrData.addValue(atts.get(0), atts.get(1));
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * 加能晶属性
     *
     * @param attrData
     * @param inlays   能晶镶嵌信息
     */
    private void energyStoneAttr(AttrData attrData, Map<Integer, EnergyStoneInlay> inlays) {
        if (null == inlays || inlays.isEmpty()) {
            return;
        }
        StaticEnergyStone stone;
        for (EnergyStoneInlay inlay : inlays.values()) {
            stone = staticEnergyStoneDataMgr.getEnergyStoneById(inlay.getStoneId());
            if (null != stone) { // 增加能晶自身加成属性
                attrData.addValue(stone.getAttrId(), stone.getAttrValue());
            }
        }
        // 增加能晶隐藏属性加成
        List<List<Integer>> hiddenAttrList = staticEnergyStoneDataMgr.getEnergyHiddenAttrByStone(inlays.values());
        if (null != hiddenAttrList && hiddenAttrList.size() > 0) {
            for (List<Integer> list : hiddenAttrList) {
                attrData.addValue(list.get(0), list.get(1));
            }
        }
    }

    /**
     * Method: militaryAttr @Description: 军工科技对属性加层 @param attrData @param scienceGrids @return
     * void @throws
     */
    private void militaryAttr(AttrData attrData, Map<Integer, MilitaryScienceGrid> scienceGrids, Map<Integer, MilitaryScience> sciences) {
        if (scienceGrids != null && sciences != null) {
            Iterator<MilitaryScienceGrid> it = scienceGrids.values().iterator();
            while (it.hasNext()) {
                MilitaryScienceGrid grid = it.next();
                if (grid.getMilitaryScienceId() != 0) {
                    // 通过科技id 获取科技信息
                    MilitaryScience s = sciences.get(grid.getMilitaryScienceId());
                    if (s.getLevel() != 0) {
                        StaticMilitaryDevelopTree tree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(s.getMilitaryScienceId(), s.getLevel());
                        List<List<Integer>> list = tree.getEffect();
                        for (List<Integer> list2 : list) {
                            if (list2.size() > 0) {
                                int attrId = list2.get(0);
                                int value = list2.get(1);
                                attrData.addValue(attrId, value);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Method: scienceAttr @Description: 加科技属性 @param tankType @param attrData @param sciences @return
     * void @throws
     */
    private void scienceAttr(int tankType, AttrData attrData, Map<Integer, Science> sciences, Map<Integer, PartyScience> partySciences) {
        if (sciences != null) {
            Iterator<Science> it = sciences.values().iterator();
            while (it.hasNext()) {
                Science science = (Science) it.next();
                StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(science.getScienceId());
                if (staticRefine.getType() == tankType) {
                    int attrId = staticRefine.getAttributeId();
                    int value = staticRefine.getAddtion() * science.getScienceLv();
                    attrData.addValue(attrId, value);
                }
            }
        }
        if (partySciences != null) {
            Iterator<PartyScience> ite = partySciences.values().iterator();
            while (ite.hasNext()) {
                PartyScience science = (PartyScience) ite.next();
                StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(science.getScienceId());
                if (staticRefine.getType() == 5 || staticRefine.getType() == tankType) {
                    int attrId = staticRefine.getAttributeId();
                    int value = staticRefine.getAddtion() * science.getScienceLv();
                    attrData.addValue(attrId, value);
                }
            }
        }
    }

    /**
     * Method: skillAttr @Description: 加技能属性 @param tankType @param attrData @param skills @return
     * void @throws
     */
    private void skillAttr(int tankType, AttrData attrData, Map<Integer, Integer> skills) {
        if (skills != null) {
            for (Map.Entry<Integer, Integer> entry : skills.entrySet()) {
                StaticSkill staticSkill = staticTankDataMgr.getStaticSkill(entry.getKey());
                if (staticSkill.getTarget() == 0 || staticSkill.getTarget() == tankType) {
                    attrData.addValue(staticSkill.getAttr(), staticSkill.getAttrValue() * entry.getValue());
                }
            }
        }
    }

    private void effectAttr(HashMap<Integer, Effect> effects, int staffingId, AttrData attrData) {
        // 增加己方部队20%伤害
        if (effects.containsKey(EffectType.ADD_HURT)) {
            attrData.addValue(AttrId.ATTACK_F, 2000);
        } else if (effects.containsKey(EffectType.ADD_HURT_SUPUR)) {
            attrData.addValue(AttrId.ATTACK_F, 3000);
        }
        // 降低地方部队20%伤害
        if (effects.containsKey(EffectType.REDUCE_HURT)) {
            attrData.addValue(AttrId.INJURED_F, 2000);
        } else if (effects.containsKey(EffectType.REDUCE_HURT_SUPER)) {
            attrData.addValue(AttrId.INJURED_F, 3000);
        }
        // 使用改变基地外观.命中+15%.闪避暴击抗暴+5%
        if (effects.containsKey(EffectType.CHANGE_SURFACE_1)) {
            attrData.addValue(AttrId.HIT, 150);
            attrData.addValue(AttrId.DODGE, 50);
            attrData.addValue(AttrId.CRIT, 50);
            attrData.addValue(AttrId.CRITDEF, 50);
        }
        // 编制加成
        StaticStaffing staffing = staticStaffingDataMgr.getStaffing(staffingId);
        if (staffing != null) {
            List<List<Integer>> attrs = staffing.getAttr();
            for (List<Integer> attr : attrs) {
                attrData.addValue(attr.get(0), attr.get(1));
            }
        }
    }


    /**
     * Method: effectHeroAttr @Description: 加武将属性和技能属性 @param fighter @param staticHero @param type
     * 1.攻打副本 2.防守玩家 3.其他 @return void @throws
     */
    public void effectHero(Fighter fighter, StaticHero staticHero, int type) {
        List<List<Integer>> list = staticHero.getAttr();
        if (list != null && !list.isEmpty()) {
            for (int i = 0; i < list.size(); i++) {
                List<Integer> one = list.get(i);
                if (one.size() != 2) {
                    continue;
                }
                for (Force force : fighter.forces) {
                    if (force != null) {
                        force.attrData.addValue(one.get(0), one.get(1));
                        effectHeroSkill(type, force, staticHero);
                    }
                }
            }
        }
        // 技能
        if (staticHero.getSkillId() == 14) { // 部队全灭时，有几率复活已经死亡的任意两支部队【不计战损】
            // 是否触发复活
            if (!RandomHelper.isHitRangeIn10000(staticHero.getSkillValue())) {
                return;
            }
            List<Integer> hasTankPos = new ArrayList<>();
            for (Force force : fighter.forces) {
                if (force != null && force.alive()) {
                    hasTankPos.add(force.pos - 1);
                }
            }
            int rebornNum = 0;
            if (hasTankPos.size() == 0) {
                return;
            }
            // 有概率复活部队数量
            if (hasTankPos.size() == 1) {
                rebornNum = 1;
            } else {
                // 能复活数量
                int canNum = hasTankPos.size();
                if (canNum > Constant.HERO_REBORN_WEIGHT.size()) {
                    canNum = Constant.HERO_REBORN_WEIGHT.size();
                }
                // 概率复活数量
                int seeds[] = {
                        0, 0
                };
                for (int i = 0; i < canNum; i++) {
                    seeds[0] += Constant.HERO_REBORN_WEIGHT.get(i).get(1);
                }
                seeds[0] = RandomHelper.randomInSize(seeds[0]);
                for (int i = 0; i < canNum; i++) {
                    List<Integer> w = Constant.HERO_REBORN_WEIGHT.get(i);
                    seeds[1] += w.get(1);
                    if (seeds[0] <= seeds[1]) {
                        rebornNum = w.get(0);
                        break;
                    }
                }
            }
            Random rand = new Random();
            for (int i = 0; i < rebornNum; i++) {
                // 触发复活位置0,1,2,3,4,5不会重复
                int pos = hasTankPos.remove(rand.nextInt(hasTankPos.size()));
                fighter.rebornforces.put(pos, null);
            }
        }
    }

    private void effectHeroAttr(AttrData attrData, StaticHero staticHero) {
        if (staticHero == null) {
            return;
        }
        List<List<Integer>> list = staticHero.getAttr();
        if (list != null && !list.isEmpty()) {
            for (int i = 0; i < list.size(); i++) {
                List<Integer> one = list.get(i);
                if (one.size() != 2) {
                    continue;
                }
                attrData.addValue(one.get(0), one.get(1));
            }
        }
    }

    private void effectHeroSkill(int type, Force force, StaticHero staticHero) {
        if (type == AttackType.ACK_COMBIT) {
            if (staticHero.getSkillId() == 1) {
                force.attrData.addValue(AttrId.ATTACK_F, staticHero.getSkillValue());
            } else if (staticHero.getSkillId() == 2) {
                force.attrData.addValue(AttrId.INJURED_F, staticHero.getSkillValue());
            }
        } else if (type == AttackType.ACK_DEFAULT_PLAYER) {
            if (staticHero.getSkillId() == 8) {
                force.attrData.addValue(AttrId.INJURED_F, staticHero.getSkillValue());
            }
            if (staticHero.getSkillId() == 9) {
                force.attrData.addValue(AttrId.DODGE, staticHero.getSkillValue());
            }
            if (staticHero.getSkillId() == 10) {
                force.attrData.addValue(AttrId.HIT, staticHero.getSkillValue());
            }
        } else if (type == AttackType.ACK_PLAYER) {
            if (staticHero.getSkillId() == 9) {
                force.attrData.addValue(AttrId.DODGE, staticHero.getSkillValue());
            }
            if (staticHero.getSkillId() == 10) {
                force.attrData.addValue(AttrId.HIT, staticHero.getSkillValue());
            }
        }
    }

    /**
     * 将领觉醒技能
     *
     * @param fighter
     * @param staticHero
     * @param awakenHero void
     */
    private void effectFirstValue(Fighter fighter, StaticHero staticHero, AwakenHero awakenHero, int type) {
        if (staticHero.getSkillId() == 6) {
            fighter.firstValue += staticHero.getSkillValue();
        }
        if (awakenHero != null) {
            Map<Integer, Integer> addAttribute = new HashMap<>();
            Map<Integer, Integer> addHeroAttribute = new HashMap<>();
            Map<Integer, Integer> addHeroResurceAttribute = new HashMap<>();
            Map<Integer, Integer> addHeroFhAttribute = new HashMap<>();
            Map<Integer, Integer> addHeroFhbAttribute = new HashMap<>();
            for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
                if (entry.getValue() <= 0) {
                    continue;
                }
                StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
                if (staticHeroAwakenSkill == null) {
                    //					LogUtils.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                    continue;
                }
                switch (staticHeroAwakenSkill.getEffectType()) {
                    case HeroConst.EFFECT_TYPE_FIRST_VAL:
                        fighter.firstValue += Integer.parseInt(staticHeroAwakenSkill.getEffectVal());
                        break;
                    case HeroConst.EFFECT_TYPE_SMOKE:
                    case HeroConst.EFFECT_TYPE_BARRIER:
                    case HeroConst.EFFECT_TYPE_DEMAGEF:
                        if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal());
                        }
                        break;
                    case HeroConst.HERO_ADD_ATTRIBUTE:
                        if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal2());
                        }
                        String effectVal = staticHeroAwakenSkill.getEffectVal();
                        if (effectVal != null) {
                            JSONArray jsonArray = JSONArray.parseArray(effectVal);
                            for (Object str : jsonArray) {
                                JSONArray j = JSONArray.parseArray(str.toString());
                                if (!addAttribute.containsKey(j.getIntValue(0))) {
                                    addAttribute.put(j.getIntValue(0), 0);
                                }
                                addAttribute.put(j.getIntValue(0), addAttribute.get(j.getIntValue(0)) + j.getIntValue(1));
                            }
                        }
                        break;
                    case HeroConst.HERO_ADD_ATTR:
                        if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal2());
                        }
                        String effectVal2 = staticHeroAwakenSkill.getEffectVal();
                        if (effectVal2 != null) {
                            JSONArray jsonArray = JSONArray.parseArray(effectVal2);
                            for (Object str : jsonArray) {
                                JSONArray j = JSONArray.parseArray(str.toString());
                                if (!addHeroAttribute.containsKey(j.getIntValue(0))) {
                                    addHeroAttribute.put(j.getIntValue(0), 0);
                                }
                                addHeroAttribute.put(j.getIntValue(0), addHeroAttribute.get(j.getIntValue(0)) + j.getIntValue(1));
                            }
                        }
                        break;
                    case HeroConst.HERO_SUB_HURT:
                        if (type == AttackType.ACK_DEFAULT_PLAYER) {
                            if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                                fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal2());
                            }
                            for (Force f : fighter.forces) {
                                if (f != null) {
                                    f.subHurtB = f.subHurtB + (Float.valueOf(staticHeroAwakenSkill.getEffectVal()) / 100.0f);
                                }
                            }
                        }
                        break;
                    case HeroConst.HERO_ADD_RESUORCE_ATTR:
                        //						if(type == AttackType.ACK_DEFAULT_PLAYER){
                        String effectVa15 = staticHeroAwakenSkill.getEffectVal();
                        if (effectVa15 != null && !effectVa15.equals("")) {
                            JSONArray jsonArray = JSONArray.parseArray(effectVa15);
                            for (Object str : jsonArray) {
                                JSONArray json = JSONArray.parseArray(str.toString());
                                if (!addHeroResurceAttribute.containsKey(json.getIntValue(0))) {
                                    addHeroResurceAttribute.put(json.getIntValue(0), 0);
                                }
                                addHeroResurceAttribute.put(json.getIntValue(0), addHeroResurceAttribute.get(json.getIntValue(0)) + json.getIntValue(1));
                            }
                            //							}
                        }
                        break;
                    case HeroConst.HERO_IMMUNE:
                        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
                        if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal2());
                            fighter.immuneId = staticHeroAwakenSkill.getId();
                        }
                        break;
                    case HeroConst.HERO_SUB_HURT_B:
                        for (Force f : fighter.forces) {
                            if (f != null) {
                                f.subHurtB2 = f.subHurtB2 + (Float.valueOf(staticHeroAwakenSkill.getEffectVal()) / 100.0f);
                            }
                        }
                        break;
                    case HeroConst.HERO_BUFF_FH:
                        if (staticHero.getAwakenSkillArr().size() != 0) { // 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getLevel() + "");
                        }
                        String effectValFh = staticHeroAwakenSkill.getEffectVal();
                        if (effectValFh != null) {
                            JSONArray jsonArray = JSONArray.parseArray(effectValFh);
                            for (Object str : jsonArray) {
                                JSONArray j = JSONArray.parseArray(str.toString());
                                if (!addHeroFhAttribute.containsKey(j.getIntValue(0))) {
                                    addHeroFhAttribute.put(j.getIntValue(0), 0);
                                }
                                addHeroFhAttribute.put(j.getIntValue(0), addHeroFhAttribute.get(j.getIntValue(0)) + j.getIntValue(1));
                            }
                        }
                        break;
                    case HeroConst.HERO_BUFF_FH_B:
                        String effectVal3 = staticHeroAwakenSkill.getEffectVal();
                        if (effectVal3 != null && !"".equals(effectVal3)) {
                            JSONArray jsonArray = JSONArray.parseArray(effectVal3);
                            for (Object str : jsonArray) {
                                JSONArray json = JSONArray.parseArray(str.toString());
                                if (!addHeroFhbAttribute.containsKey(json.getIntValue(0))) {
                                    addHeroFhbAttribute.put(json.getIntValue(0), 0);
                                }
                                addHeroFhbAttribute.put(json.getIntValue(0), addHeroFhbAttribute.get(json.getIntValue(0)) + json.getIntValue(1));
                            }
                        }
                        break;
                }
            }
            // 觉醒技能增加属性 被动技能
            if (!addAttribute.isEmpty()) {
                Force[] forces = fighter.forces;
                for (Force f : forces) {
                    if (f != null) {
                        for (Entry<Integer, Integer> e : addAttribute.entrySet()) {
                            f.attrData.addValue(e.getKey(), e.getValue());
                        }
                    }
                }
            }
            // 增加少量防护和刚毅（全体） 主动技能
            if (!addHeroAttribute.isEmpty()) {
                Force[] forces = fighter.forces;
                for (Force f : forces) {
                    if (f != null) {
                        for (Entry<Integer, Integer> e : addHeroAttribute.entrySet()) {
                            f.addHeroAttr(e.getKey(), e.getValue());
                        }
                    }
                }
            }
            // 守卫基地/资源加刚毅  守卫基地/资源加抗暴 守卫基地/资源加防护
            if (!addHeroResurceAttribute.isEmpty()) {
                Force[] forces = fighter.forces;
                for (Force f : forces) {
                    if (f != null && f.alive()) {
                        for (Entry<Integer, Integer> e : addHeroResurceAttribute.entrySet()) {
                            f.attrData.addValue(e.getKey(), e.getValue());
                        }
                    }
                }
            }
            // 全体上一个不屈buff（不屈：死后复活的部队会提升攻击，暴击，爆裂）
            if (!addHeroFhAttribute.isEmpty()) {
                Force[] forces = fighter.forces;
                for (Force f : forces) {
                    if (f != null && f.alive()) {
                        for (Entry<Integer, Integer> e : addHeroFhAttribute.entrySet()) {
                            f.addFhAttr(e.getKey(), e.getValue());
                        }
                    }
                }
            }
            // 全体上一个不屈buff（不屈：死后复活的部队会提升攻击，暴击，爆裂）
            if (!addHeroFhbAttribute.isEmpty()) {
                Force[] forces = fighter.forces;
                for (Force f : forces) {
                    if (f != null && f.alive()) {
                        for (Entry<Integer, Integer> e : addHeroFhbAttribute.entrySet()) {
                            f.addFhAttr(e.getKey(), e.getValue());
                        }
                    }
                }
            }
        }
    }

    /**
     * 觉醒将领技能
     */
    private void heroAwakenSkill(AttrData attrData, AwakenHero awakenHero) {
        if (awakenHero == null) {
            return;
        }
        for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            if (entry.getValue() <= 0) {
                continue;
            }
            StaticHeroAwakenSkill staticHeroAwakenSkill = staticHeroDataMgr.getHeroAwakenSkill(entry.getKey(), entry.getValue());
            if (staticHeroAwakenSkill == null) {
                LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                continue;
            }
            if (staticHeroAwakenSkill.getEffectType() == HeroConst.EFFECT_TYPE_ATTR) {
                // 添加属性
                JSONArray attArr = JSONArray.parseArray(staticHeroAwakenSkill.getEffectVal());
                if (attArr == null) {
                    continue;
                }
                for (int i = 0; i < attArr.size(); i++) {
                    attrData.addValue(attArr.getJSONArray(i).getIntValue(0), attArr.getJSONArray(i).getIntValue(1));
                }
            }
        }
    }

    /**
     * 计算军备属性
     *
     * @param attrData
     * @param leqMap   军备列表
     */
    private void lordEquiqAttr(AttrData attrData, Map<Integer, LordEquip> leqMap) {
        if (leqMap != null && !leqMap.isEmpty()) {
            Map<Integer, StaticLordEquipSkill> skillMap = staticEquipDataMgr.getLordEquipSkillMap();
            for (Entry<Integer, LordEquip> entry : leqMap.entrySet()) {
                if (entry.getKey() > 0) {
                    LordEquip leq = entry.getValue();
                    StaticLordEquip sleq = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
                    if (sleq != null && sleq.getAtts() != null) {
                        for (List<Integer> attr : sleq.getAtts()) {
                            attrData.addValue(attr.get(0), attr.get(1));
                        }
                    }
                    // 加军备技能属性
                    List<List<Integer>> leSkillList = leq.getLordEquipSkillList();
                    if (leq.getLordEquipSaveType() == 1) {
                        leSkillList = leq.getLordEquipSkillSecondList();
                    }
                    for (List<Integer> skill : leSkillList) {
                        StaticLordEquipSkill staticLeSkill = skillMap.get(skill.get(0));
                        List<List<Integer>> attrList = staticLeSkill.getAttrs();
                        for (List<Integer> attr : attrList) {
                            attrData.addValue(attr.get(0), attr.get(1));
                        }
                    }
                }
            }
        }
    }

    /**
     * 作战实验室属性加成
     *
     * @param attrData
     * @param graduateInfo
     * @param staticTank
     */
    private void fightLabAttr(AttrData attrData, Map<Integer, Map<Integer, Integer>> graduateInfo, StaticTank staticTank) {
        for (Entry<Integer, Map<Integer, Integer>> typeEntry : graduateInfo.entrySet()) {
            for (Entry<Integer, Integer> skillEntry : typeEntry.getValue().entrySet()) {
                Integer level = skillEntry.getValue();
                if (level != null && level > 0) {
                    StaticLaboratoryMilitary data = staticLabDataMgr.getGraduateConfig(typeEntry.getKey(), skillEntry.getKey(), skillEntry.getValue());
                    if (data != null) {
                        if (staticTank.getType() == data.getType()) {
                            List<List<Integer>> effects = data.getEffect();
                            if (effects != null && !effects.isEmpty()) {
                                for (List<Integer> effect : effects) {
                                    attrData.addValue(effect.get(0), effect.get(1));
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * 增加能源核心属性
     *
     * @param attrData
     */
    public void addEnergyAttr(PEnergyCore energyCore, AttrData attrData) {
        Map<Integer, StaticCoreAward> allAwardConfig = staticCoreDataMgr.getAllAwardConfig();
        if (allAwardConfig != null) {
            for (int i = 1; i < energyCore.getLevel(); i++) {
                StaticCoreAward aw = allAwardConfig.get(i);
                if (aw != null) {
                    //完成奖励只加一次
                    for (List<Integer> integers : aw.getFinishAward()) {
                        attrData.addValue(integers.get(0), integers.get(1));
                    }
                }
            }
            StaticCoreAward aw = allAwardConfig.get(energyCore.getLevel());
            if (aw != null && energyCore.getState() == 1) {
                //完成奖励只加一次
                for (List<Integer> integers : aw.getFinishAward()) {
                    attrData.addValue(integers.get(0), integers.get(1));
                }
            }
        }
    }


    /**
     * 加对应位置的点亮属性(只加对应位置)
     *
     * @param attrData
     * @param energyCore
     * @param pos
     */
    private void addEnergyPosCoreAttr(AttrData attrData, PEnergyCore energyCore, int pos) {
        Map<Integer, StaticCoreAward> allAwardConfig = staticCoreDataMgr.getAllAwardConfig();
        if (allAwardConfig != null) {
            for (int i = 1; i < energyCore.getLevel(); i++) {
                StaticCoreAward aw = allAwardConfig.get(i);
                if (aw != null && aw.getIndex() == pos) {
                    Map<Integer, StaticCoreExp> map = staticCoreDataMgr.getCoreExpBylV(i);
                    //点亮奖励有几个阶段加几个阶段
                    if (map != null) {
                        for (int j = 0; j < map.size(); j++) {
                            for (List<Integer> integers : aw.getLightAward()) {
                                attrData.addValue(integers.get(0), integers.get(1));
                            }
                        }
                    }
                }
            }
            StaticCoreAward aw = allAwardConfig.get(energyCore.getLevel());
            if (aw != null && aw.getIndex() == pos) {
                for (int j = 1; j < energyCore.getSection(); j++) {
                    for (List<Integer> integers : aw.getLightAward()) {
                        attrData.addValue(integers.get(0), integers.get(1));
                    }
                }
            }
        }
    }

    /**
     * 加载指挥官军衔属性
     *
     * @param attrData
     * @param militaryRank
     */
    private void militaryRankAttr(AttrData attrData, int militaryRank) {
        if (militaryRank > 0) {
            StaticMilitaryRank data = staticLordDataMgr.getStaticMilitaryRank(militaryRank);
            if (data != null && data.getAttrs() != null) {
                for (List<Integer> attr : data.getAttrs()) {
                    attrData.addValue(attr.get(0), attr.get(1));
                }
            }
        }
    }

    public int getAttackEffectId(Athlete athlete, int type) {
        AttackEffect effect = athlete.atkEffects.get(type);
        return effect != null ? effect.getUseId() : 0;
    }

    public int getAttackEffectId(PartyMember pm, int type) {
        AttackEffect effect = pm.atkEffects.get(type);
        return effect != null ? effect.getUseId() : 0;
    }

    public int getAttackEffectId(CrossPlayer player, int type) {
        AttackEffect effect = player.getAtkEffects().get(type);
        return effect != null ? effect.getUseId() : 0;
    }


    public Fighter createTeamFighter(Form form, StaticBountyEnemy staticBountyEnemy, StaticBountySkill staticBountySkill) {
        Fighter fighter = createFighter();
        fighter.setStaticBountyEnemy(staticBountyEnemy);
        fighter.setStaticBountySkill(staticBountySkill);

        fighter.addForce(createForce(form, 1, staticBountyEnemy.getAttr().get(0)), 1);
        fighter.addForce(createForce(form, 2, staticBountyEnemy.getAttr().get(1)), 2);
        fighter.addForce(createForce(form, 3, staticBountyEnemy.getAttr().get(2)), 3);
        fighter.addForce(createForce(form, 4, staticBountyEnemy.getAttr().get(3)), 4);
        fighter.addForce(createForce(form, 5, staticBountyEnemy.getAttr().get(4)), 5);
        fighter.addForce(createForce(form, 6, staticBountyEnemy.getAttr().get(5)), 6);
        return fighter;
    }

    private Force createForce(Form form, int pos, List<Integer> attrs) {
        int p = form.p[pos - 1];
        if (p <= 0) {
            return null;
        }

        int count = form.c[pos - 1];
        StaticTank staticTank = staticTankDataMgr.getStaticTank(p);
        AttrData attrData = new AttrData(staticTank);

        if (attrs != null && !attrs.isEmpty()) {
            attrData.setAttr(attrs);
        }

        return new Force(staticTank, attrData, pos, count);
    }

    /**
     * Method: statisticHaustTank
     *
     * @Description: 只统计战斗中坦克消耗，不做扣除 @param fighter @return @return Map <Integer,RptTank> @throws
     */
    public Map<Integer, RptTank> statisticHaustTank(Fighter fighter) {
        Map<Integer, RptTank> map = new HashMap<Integer, RptTank>();
        int killed = 0;
        int tankId;
        for (Force force : fighter.forces) {
            if (force != null) {
                killed = force.killed;
                tankId = force.staticTank.getTankId();
                if (killed > 0) {
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

        return map;
    }
}