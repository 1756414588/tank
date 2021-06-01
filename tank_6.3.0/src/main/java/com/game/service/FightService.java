/**
 * @Title: FightService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年8月28日 下午4:20:00
 * @version V1.0
 */
package com.game.service;

import com.alibaba.fastjson.JSONArray;
import com.game.bossFight.domain.Boss;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.MedalBouns;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.*;
import com.game.domain.s.tactics.StaticTacticsTankSuit;
import com.game.drill.domain.DrillImproveInfo;
import com.game.fight.domain.AttrData;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.fortressFight.domain.DefenceNPC;
import com.game.fortressFight.domain.MyFortressAttr;
import com.game.manager.ActivityDataManager;
import com.game.manager.HonourDataManager;
import com.game.manager.PartyDataManager;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: FightService
 * @Description:战斗逻辑服务
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
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticLabDataMgr staticFightLabDataMgr;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticCombatDataMgr staticCombatDataMgr;

    @Autowired
    private StaticMilitaryDataMgr staticMilitaryDataMgr;

    @Autowired
    private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;

    @Autowired
    private StaticFortressDataMgr staticFortressDataMgr;

    @Autowired
    private StaticDrillDataManager staticDrillDataManager;

    @Autowired
    private StaticRebelDataMgr staticRebelDataMgr;

    @Autowired
    private StaticMedalDataMgr staticMedalDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticSecretWeaponDataMgr staticSecretWeaponDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private HonourDataManager honourDataManager;

    @Autowired
    private TacticsService tacticsService;

    @Autowired
    private StaticCoreDataMgr staticCoreDataMgr;

    private Fighter createFighter() {
        return new Fighter();
    }

    /**
     * 创建关卡战斗单位
     *
     * @param staticCombat
     * @return Fighter
     */
    public Fighter createFighter(StaticCombat staticCombat) {
        Fighter fighter = createFighter();
        fighter.addForce(createForce(staticCombat, 1), 1);
        fighter.addForce(createForce(staticCombat, 2), 2);
        fighter.addForce(createForce(staticCombat, 3), 3);
        fighter.addForce(createForce(staticCombat, 4), 4);
        fighter.addForce(createForce(staticCombat, 5), 5);
        fighter.addForce(createForce(staticCombat, 6), 6);
        return fighter;
    }

    /**
     * 创建极限探险战斗单位
     *
     * @param staticExplore
     * @return Fighter
     */
    public Fighter createFighter(StaticExplore staticExplore) {
        Fighter fighter = createFighter();
        fighter.addForce(createForce(staticExplore, 1), 1);
        fighter.addForce(createForce(staticExplore, 2), 2);
        fighter.addForce(createForce(staticExplore, 3), 3);
        fighter.addForce(createForce(staticExplore, 4), 4);
        fighter.addForce(createForce(staticExplore, 5), 5);
        fighter.addForce(createForce(staticExplore, 6), 6);
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

    /**
     * 叛军战斗单位
     *
     * @param form
     * @param rebelType
     * @param lv
     * @param attackType
     * @return Fighter
     */
    public Fighter createRebelFighter(Form form, int rebelType, int lv, int attackType, float hp) {
        Fighter fighter = createFighter();
        fighter.addForce(createRebelForce(form, rebelType, lv, 1, hp), 1);
        fighter.addForce(createRebelForce(form, rebelType, lv, 2, hp), 2);
        fighter.addForce(createRebelForce(form, rebelType, lv, 3, hp), 3);
        fighter.addForce(createRebelForce(form, rebelType, lv, 4, hp), 4);
        fighter.addForce(createRebelForce(form, rebelType, lv, 5, hp), 5);
        fighter.addForce(createRebelForce(form, rebelType, lv, 6, hp), 6);

        if (form.getCommander() > 0) {
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
            effectHero(fighter, staticHero, attackType);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), attackType);
        }
        return fighter;
    }

    /**
     * 活动叛军战斗单位
     *
     * @param form
     * @param lv
     * @param attackType
     * @return Fighter
     */
    public Fighter createActRebelFighter(Form form, int lv, int attackType) {
        Fighter fighter = createFighter();
        fighter.addForce(createActRebelForce(form, lv, 1), 1);
        fighter.addForce(createActRebelForce(form, lv, 2), 2);
        fighter.addForce(createActRebelForce(form, lv, 3), 3);
        fighter.addForce(createActRebelForce(form, lv, 4), 4);
        fighter.addForce(createActRebelForce(form, lv, 5), 5);
        fighter.addForce(createActRebelForce(form, lv, 6), 6);

        if (form.getCommander() > 0) {
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
            effectHero(fighter, staticHero, attackType);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), attackType);
        }
        return fighter;
    }

    /**
     * 玩家防守飞艇战斗单位
     *
     * @param player
     * @param form
     * @param type
     * @return Fighter
     */
    public Fighter createAirshipFighter(Player player, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (c[i] > 0) {
                fighter.addForce(createForce(player, i + 1, p[i], c[i], form), i + 1);
            }
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

        fighter.tactics.addAll(new ArrayList<>(form.getTactics()));
        fighter.player = player;
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
    public Fighter createFighter(Player player, Form form, int type) {
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
        fighter.tactics.addAll(new ArrayList<>(form.getTactics()));
        fighter.player = player;
        return fighter;
    }

    /**
     * 玩家红蓝大战战斗单位
     *
     * @param player
     * @param form
     * @param type
     * @param improves
     * @return Fighter
     */
    public Fighter createDrillFighter(Player player, Form form, int type, Map<Integer, DrillImproveInfo> improves) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (c[i] > 0) {
                fighter.addForce(createDrillForce(player, i + 1, p[i], c[i], improves, form), i + 1);
            }
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
        fighter.tactics.addAll(new ArrayList<>(form.getTactics()));
        fighter.player = player;
        return fighter;
    }

    /**
     * 玩家要塞战战斗单位
     *
     * @param player
     * @param form
     * @param type
     * @return Fighter
     */
    public Fighter createFortressFighter(Player player, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createFortressForce(player, i + 1, p[i], c[i], form), i + 1);
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
        fighter.tactics.addAll(new ArrayList<>(form.getTactics()));
        // 进修对先手值加层
        fortressAttrUpperHand(fighter, GameServer.ac.getBean(FortressWarService.class).getMyFortressAttrMap(player.lord.getLordId()));
        fighter.player = player;
        return fighter;
    }

    /**
     * 创建飞艇战斗对象, 根据耐久度初始化飞艇的血量
     *
     * @param sAirship
     * @param airship
     * @return
     */
    public Fighter createAirshipFighter(StaticAirship sAirship, Airship airship) {
        List<Integer> army = sAirship.getArmy();
        Fighter fighter = createFighter();
        Force force = createAirshipForce(army.get(0), army.get(1));
        if (airship.getPartyData() != null && airship.getDurability() < AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX) {
            force.maxHp = force.calcHp();// 单个飞艇最大血量值
            // 当前飞艇血量 = 单个飞艇血量 * 飞艇数量 * 耐久度 / 飞艇总耐久度
            force.hp = force.maxHp * force.count * airship.getDurability() / AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX;
            fighter.isFighted = true;// 不重FightLogic里面不再重新初始化血量
        }
        fighter.addForce(force, 5);
        fighter.type = FightConst.TYPE_AIRSHIP;
        return fighter;
    }

    // 进修对先手值加层
    private void fortressAttrUpperHand(Fighter fighter, Map<Integer, MyFortressAttr> myFortressAttrMap) {
        if (myFortressAttrMap != null) {
            MyFortressAttr my = myFortressAttrMap.get(FortressFightConst.Attr_UpperHand);

            if (my.getLevel() > 0) {
                List<List<Integer>> list = staticFortressDataMgr.getStaticFortressAttr(my.getId(), my.getLevel()).getEffect();

                int value = list.get(0).get(1);
                fighter.firstValue = fighter.firstValue + value;
            }
        }
    }

    /**
     * 基地防守
     *
     * @param defenceNpc
     * @param type
     * @return Fighter
     */
    public Fighter createFighter(DefenceNPC defenceNpc, int type) {
        Fighter fighter = createFighter();
        Form form = defenceNpc.getInstForm();
        int[] p = form.p;
        int[] c = form.c;

        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createForce(staticCombatDataMgr.getStaticExplore(defenceNpc.getExploreId()), p[i], c[i], i + 1), i + 1);
        }

        if (form.getCommander() > 0) {
            StaticHero staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
            effectHero(fighter, staticHero, type);
            effectFirstValue(fighter, staticHero, form.getAwakenHero(), type);
        }
        return fighter;
    }

    /**
     * 世界boss玩家战斗单位
     *
     * @param bossFight
     * @param player
     * @param form
     * @param type
     * @return Fighter
     */
    public Fighter createFighter(BossFight bossFight, Player player, Form form, int type) {
        Fighter fighter = createFighter();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            fighter.addForce(createForce(bossFight, player, i + 1, p[i], c[i], form), i + 1);
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
        fighter.player = player;

        fighter.tactics.addAll(new ArrayList<>(form.getTactics()));
        return fighter;
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

    public Force createForce(Form form, int pos, List<Integer> attrs) {
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
     * 军团副本战斗单位
     *
     * @param form
     * @param staticPartyCombat
     * @return Fighter
     */
    public Fighter createFighter(Form form, StaticPartyCombat staticPartyCombat) {
        Fighter fighter = createFighter();
        fighter.addForce(createForce(form, staticPartyCombat, 1), 1);
        fighter.addForce(createForce(form, staticPartyCombat, 2), 2);
        fighter.addForce(createForce(form, staticPartyCombat, 3), 3);
        fighter.addForce(createForce(form, staticPartyCombat, 4), 4);
        fighter.addForce(createForce(form, staticPartyCombat, 5), 5);
        fighter.addForce(createForce(form, staticPartyCombat, 6), 6);
        return fighter;
    }

    // public Fighter createFighter(Form form, StaticMineForm staticMineForm) {
    // Fighter fighter = createFighter();
    // fighter.addForce(createForce(form, staticMineForm, 1), 1);
    // fighter.addForce(createForce(form, staticMineForm, 2), 2);
    // fighter.addForce(createForce(form, staticMineForm, 3), 3);
    // fighter.addForce(createForce(form, staticMineForm, 4), 4);
    // fighter.addForce(createForce(form, staticMineForm, 5), 5);
    // fighter.addForce(createForce(form, staticMineForm, 6), 6);
    // return fighter;
    // }

    /**
     * boss战斗单位
     *
     * @param boss
     * @return Fighter
     */
    public Fighter createBoss(Boss boss) {
        return createAltarBoss(boss, 10000);
    }

    public Fighter createAltarBoss(Boss boss, int bossCount) {
        Fighter fighter = createFighter();
        fighter.boss = true;

        int lv = boss.getBossLv();
        int which = boss.getBossWhich();

        boolean dizzy = true;
        boolean god = true;
        int count = 0;
        for (int i = 0; i < 6; i++) {
            if (i < which) {
                count = 0;
            } else if (i > which) {
                count = bossCount;
                god = true;
            } else {
                count = boss.getBossHp();
                god = false;
            }
            dizzy = i != 5;
            if (boss.getBossType() == 1) {// 世界BOSS，坦克id从31开始
                fighter.addForce(createBossForce(31 + (lv - 45) * 6 + i, count, i + 1, dizzy, god), i + 1);
            } else if (boss.getBossType() == 2) {// 祭坛BOSS，坦克id从131开始
                fighter.addForce(createBossForce(131 + (lv - 1) * 6 + i, count, i + 1, dizzy, god), i + 1);
                fighter.isAltarBoss = true;
            }
        }
        return fighter;
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
    public Force createForce(Player player, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, player.equips.get(pos));
        partAttr(attrData, player.parts.get(staticTank.getType()));
        militaryAttr(attrData, player.militaryScienceGrids.get(tankId), player.militarySciences);
        scienceAttr(staticTank.getType(), attrData, player.sciences, partyDataManager.getScience(player));
        skillAttr(staticTank.getType(), attrData, player.skills);
        effectAttr(player, attrData);
        energyStoneAttr(attrData, player.energyInlay.get(pos));// 能晶加成
        secretWeaponAttr(player, attrData, pos);// 秘密武器加成
        medalAttr(attrData, player.medals.get(1));// 勋章
        medalBounsAttr(attrData, player.medalBounss.get(1));// 勋章展厅
        lordEquiqAttr(player, attrData, player.leqInfo.getPutonLordEquips());// 军备属性
        militaryRankAttr(attrData, player.lord.getMilitaryRank());// 军衔属性
        heroAwakenSkill(attrData, form.getAwakenHero());// 将领觉醒技能
        fightLabAttr(attrData, player.labInfo, staticTank);// 作战实验室
        honourBuffAttr(attrData, player);// 荣耀玩法buff
        energyCoreAttr(attrData, player);// 能源核心完成加成
        energyPosCoreAttr(attrData, player, pos); //能源核心点亮加成(只加对应位置)

        // 设置攻击特效
        int eid = getAttackEffectId(player, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(player, force, form, staticTank);//战术大师属性

//        LogUtil.error("player " + player.roleId + " | " + player.lord.getNick() + "|\n=======> tank game force " + JSON.toJSONString(force));
        return force;
    }

    /**
     * 红蓝大战战斗格子Force
     *
     * @param player
     * @param pos
     * @param tankId
     * @param count
     * @param improves
     * @param form
     * @return Force
     */
    public Force createDrillForce(Player player, int pos, int tankId, int count, Map<Integer, DrillImproveInfo> improves, Form form) {
        if (tankId == 0) {
            return null;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, player.equips.get(pos));
        partAttr(attrData, player.parts.get(staticTank.getType()));
        militaryAttr(attrData, player.militaryScienceGrids.get(tankId), player.militarySciences);
        scienceAttr(staticTank.getType(), attrData, player.sciences, partyDataManager.getScience(player));
        skillAttr(staticTank.getType(), attrData, player.skills);
        effectAttr(player, attrData);
        energyStoneAttr(attrData, player.energyInlay.get(pos));// 能晶加成
        secretWeaponAttr(player, attrData, pos);// 秘密武器加成
        drillImproveAttr(attrData, improves);// 演习进修加成
        medalAttr(attrData, player.medals.get(1));// 勋章
        medalBounsAttr(attrData, player.medalBounss.get(1));// 勋章展厅
        lordEquiqAttr(player, attrData, player.leqInfo.getPutonLordEquips());// 军备属性
        militaryRankAttr(attrData, player.lord.getMilitaryRank());// 军衔属性
        heroAwakenSkill(attrData, form.getAwakenHero());// 将领觉醒技能
        fightLabAttr(attrData, player.labInfo, staticTank);// 作战实验室
        honourBuffAttr(attrData, player);// 荣耀生存玩法buff
        energyCoreAttr(attrData, player);//能源核心加成
        energyPosCoreAttr(attrData, player, pos); //能源核心点亮加成(只加对应位置)
        // 设置攻击特效
        int eid = getAttackEffectId(player, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(player, force, form, staticTank);//战术大师属性
        return force;
    }

    /**
     * 要塞战
     *
     * @param player
     * @param pos
     * @param tankId
     * @param count
     * @param form
     * @return Force
     */
    public Force createFortressForce(Player player, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        equipAttr(attrData, player.equips.get(pos));
        partAttr(attrData, player.parts.get(staticTank.getType()));
        scienceAttr(staticTank.getType(), attrData, player.sciences, partyDataManager.getScience(player));
        skillAttr(staticTank.getType(), attrData, player.skills);
        effectAttr(player, attrData);
        energyStoneAttr(attrData, player.energyInlay.get(pos));// 能晶加成
        secretWeaponAttr(player, attrData, pos);// 秘密武器加成
        fortressAttr(attrData, GameServer.ac.getBean(FortressWarService.class).getMyFortressAttrMap(player.lord.getLordId()));
        medalAttr(attrData, player.medals.get(1));// 勋章
        medalBounsAttr(attrData, player.medalBounss.get(1));// 勋章展厅
        lordEquiqAttr(player, attrData, player.leqInfo.getPutonLordEquips());// 军备属性
        militaryRankAttr(attrData, player.lord.getMilitaryRank());// 军衔属性
        heroAwakenSkill(attrData, form.getAwakenHero());// 将领觉醒技能
        fightLabAttr(attrData, player.labInfo, staticTank);// 作战实验室
        honourBuffAttr(attrData, player);// 荣耀生存玩法buff
        energyCoreAttr(attrData, player);//能源核心加成
        energyPosCoreAttr(attrData, player, pos); //能源核心点亮加成(只加对应位置)
        // 设置攻击特效
        int eid = getAttackEffectId(player, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(player, force, form, staticTank);//战术大师属性

        return force;
    }

    /**
     * 玩家战斗单位格子
     *
     * @param bossFight
     * @param player
     * @param pos
     * @param tankId
     * @param count
     * @param form
     * @return Force
     */
    public Force createForce(BossFight bossFight, Player player, int pos, int tankId, int count, Form form) {
        if (tankId == 0) {
            return null;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank, bossFight);
        equipAttr(attrData, player.equips.get(pos));
        partAttr(attrData, player.parts.get(staticTank.getType()));
        // militaryAttr(attrData, player.militaryScienceGrids.get(tankId),
        // player.militarySciences);
        scienceAttr(staticTank.getType(), attrData, player.sciences, partyDataManager.getScience(player));
        skillAttr(staticTank.getType(), attrData, player.skills);
        effectAttr(player, attrData);
        energyStoneAttr(attrData, player.energyInlay.get(pos));// 能晶加成
        secretWeaponAttr(player, attrData, pos);// 秘密武器加成
        medalAttr(attrData, player.medals.get(1));// 勋章
        medalBounsAttr(attrData, player.medalBounss.get(1));// 勋章展厅
        lordEquiqAttr(player, attrData, player.leqInfo.getPutonLordEquips());// 军衔属性
        militaryRankAttr(attrData, player.lord.getMilitaryRank());// 军备属性
        heroAwakenSkill(attrData, form.getAwakenHero());// 将领觉醒技能
        fightLabAttr(attrData, player.labInfo, staticTank);// 作战实验室
        honourBuffAttr(attrData, player);// 荣耀生存玩法buff
        energyCoreAttr(attrData, player);//能源核心加成
        energyPosCoreAttr(attrData, player, pos); //能源核心点亮加成(只加对应位置)
        // 设置攻击特效
        int eid = getAttackEffectId(player, staticTank.getType());
        Force force = new Force(staticTank, attrData, pos, count, eid);
        tacticsAttr(player, force, form, staticTank);//战术大师属性

        return force;
    }

    /**
     * 关卡战斗单位的格子
     *
     * @param staticCombat
     * @param pos
     * @return Force
     */
    public Force createForce(StaticCombat staticCombat, int pos) {
        List<Integer> slot = staticCombat.getForm().get(pos - 1);
        if (slot.isEmpty()) {
            return null;
        }

        int tankId = slot.get(0);
        int count = slot.get(1);

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        List<Integer> attrs = staticCombat.getAttr().get(pos - 1);
        AttrData attrData = new AttrData(attrs);

        return new Force(staticTank, attrData, pos, count);
    }

    // public Force createForce(StaticMineForm staticMineForm, int pos) {
    // List<Integer> slot = staticMineForm.getForm().get(pos - 1);
    // if (slot.isEmpty()) {
    // return null;
    // }
    //
    // int tankId = slot.get(0);
    // int count = slot.get(1);
    //
    // StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
    // List<Integer> attrs = staticMineForm.getAttr().get(pos - 1);
    // AttrData attrData = new AttrData(attrs);
    //
    // Force force = new Force(staticTank, attrData, pos, count);
    // return force;
    // }

    /**
     * @param staticExplore
     * @param pos
     * @return Force
     */
    public Force createForce(StaticExplore staticExplore, int pos) {
        List<Integer> slot = staticExplore.getForm().get(pos - 1);
        if (slot.isEmpty()) {
            return null;
        }

        int tankId = slot.get(0);
        int count = slot.get(1);

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        List<Integer> attrs = staticExplore.getAttr().get(pos - 1);
        AttrData attrData = new AttrData(attrs);

        return new Force(staticTank, attrData, pos, count);
    }

    public Force createForce(StaticExplore staticExplore, int tankId, int count, int pos) {
        if (tankId == 0) {
            return null;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        List<Integer> attrs = staticExplore.getAttr().get(pos - 1);
        AttrData attrData = new AttrData(attrs);

        return new Force(staticTank, attrData, pos, count);
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

    public Force createActRebelForce(Form form, int lv, int pos) {
        int p = form.p[pos - 1];
        if (p <= 0) {
            return null;
        }

        int count = form.c[pos - 1];

        StaticTank staticTank = staticTankDataMgr.getStaticTank(p);
        StaticActRebelAttr staticActRebelAttr = staticActivityDataMgr.getActRebelAttr(p, lv);
        AttrData attrData = new AttrData(staticActRebelAttr);

        return new Force(staticTank, attrData, pos, count);
    }

    public Force createRebelForce(Form form, int rebelType, int lv, int pos, float hp) {
        int p = form.p[pos - 1];
        if (p <= 0) {
            return null;
        }

        int count = form.c[pos - 1];

        StaticTank staticTank = staticTankDataMgr.getStaticTank(p);
        StaticRebelAttr staticRebelAttr = staticRebelDataMgr.getRebelAttr(rebelType, lv, p);
        if (hp < 1) {
            hp = 1;
        }
        AttrData attrData = new AttrData(staticRebelAttr, hp);

        return new Force(staticTank, attrData, pos, count);
    }

    public Force createForce(Form form, StaticPartyCombat staticPartyCombat, int pos) {
        int p = form.p[pos - 1];
        if (p <= 0) {
            return null;
        }

        int count = form.c[pos - 1];

        StaticTank staticTank = staticTankDataMgr.getStaticTank(p);
        List<Integer> attrs = staticPartyCombat.getAttr().get(pos - 1);
        AttrData attrData = new AttrData(attrs);

        return new Force(staticTank, attrData, pos, count);
    }

    // public Force createForce(Form form, StaticMineForm staticMineForm, int
    // pos) {
    // int p = form.p[pos - 1];
    // if (p <= 0) {
    // return null;
    // }
    //
    // int tankId = p;
    // int count = form.c[pos - 1];
    //
    // StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
    // List<Integer> attrs = staticMineForm.getAttr().get(pos - 1);
    // AttrData attrData = new AttrData(attrs);
    //
    // Force force = new Force(staticTank, attrData, pos, count);
    // return force;
    // }

    public Force createBossForce(int tankId, int count, int pos, boolean dizzy, boolean god) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        Force force = new Force(staticTank, attrData, pos, count);
        force.dizzy = dizzy;
        force.god = god;
        return force;
    }

    public Force createAirshipForce(int tankId, int count) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);
        Force force = new Force(staticTank, attrData, 5, count);
        force.initCount = count;
        return force;
    }

    /**
     * Method: equipAttr
     *
     * @Description: 加装备属性 @param attrData @param equips @return void @throws
     */
    private void equipAttr(AttrData attrData, Map<Integer, Equip> equips) {
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
                if (blue + orange >= bonusAttribute.getNumber()) {// 蓝色套装激活
                    for (List<Integer> attr : bonusAttribute.getAttribute()) {
                        attrData.addValue(attr.get(0), attr.get(1));
                    }
                }
            } else if (bonusAttribute.getQuality() == 4) {
                if (purple + orange >= bonusAttribute.getNumber()) {// 紫色套装激活
                    for (List<Integer> attr : bonusAttribute.getAttribute()) {
                        attrData.addValue(attr.get(0), attr.get(1));
                    }
                }
            } else if (bonusAttribute.getQuality() == 5) {
                if (orange >= bonusAttribute.getNumber()) {// 橙色套装激活
                    for (List<Integer> attr : bonusAttribute.getAttribute()) {
                        attrData.addValue(attr.get(0), attr.get(1));
                    }
                }
            }
        }
        // int v = 0;
        // if (blue == 6) {
        // v = 50;
        // } else if (purple == 6) {
        // v = 100;
        // }
        //
        // if (v != 0) {
        // attrData.addValue(AttrId.ATTACK_F, v * 10);
        // attrData.addValue(AttrId.HIT, v);
        // attrData.addValue(AttrId.CRIT, v);
        //
        // attrData.addValue(AttrId.HP_F, v * 10);
        // attrData.addValue(AttrId.DODGE, v);
        // attrData.addValue(AttrId.CRITDEF, v);
        // }

    }

    /**
     * 勋章属性
     */
    private void medalAttr(AttrData attrData, Map<Integer, Medal> medals) {
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

    /**
     * 勋章展示属性
     */
    private void medalBounsAttr(AttrData attrData, Map<Integer, MedalBouns> medalBounss) {
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

    /**
     * 计算军备属性
     *
     * @param attrData
     * @param leqMap   军备列表
     */
    private void lordEquiqAttr(Player player, AttrData attrData, Map<Integer, LordEquip> leqMap) {
        if (leqMap != null && !leqMap.isEmpty()) {
            Map<Integer, StaticLordEquipSkill> skillMap = staticEquipDataMgr.getLordEquipSkillMap();
            for (Entry<Integer, LordEquip> entry : leqMap.entrySet()) {
                if (entry.getKey() > 0) {
                    LordEquip leq = entry.getValue();
                    StaticLordEquip sleq = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
                    // 加军备属性
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
                        if (staticLeSkill != null) {
                            List<List<Integer>> attrList = staticLeSkill.getAttrs();
                            for (List<Integer> attr : attrList) {
                                attrData.addValue(attr.get(0), attr.get(1));
                            }
                        }

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

    /**
     * Method: partAttr
     *
     * @Description: 加配件属性 @param attrData @param equips @return void @throws
     */
    private void partAttr(AttrData attrData, Map<Integer, Part> equips) {
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


    /**
     * 改方法为了兼容客户端给配置额外增加了 15%的属性 此方法只用于计算总战力
     *
     * @param attrData
     * @param equips
     */
    private void partAttrFight(AttrData attrData, Map<Integer, Part> equips) {
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

            if (part.getRefitLv() >= 10 && Constant.MEDAL_RATE > 0) {
                int a = (int) (staticPart.getA1() * (part.getUpLv() + 1) * (Constant.MEDAL_RATE / 100.0f));
                int b = (int) (staticPart.getA2() * (part.getUpLv() + 1) * (Constant.MEDAL_RATE / 100.0f));
                int c = (int) (staticPart.getA3() * (part.getUpLv() + 1) * (Constant.MEDAL_RATE / 100.0F));
                attrData.addValue(attrId1, a);
                attrData.addValue(attrId2, b);
                attrData.addValue(attrId3, c);
            }


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

    /**
     * 军事演习（红蓝大战）演习进修属性加成
     *
     * @param attrData
     * @param improves
     */
    private void drillImproveAttr(AttrData attrData, Map<Integer, DrillImproveInfo> improves) {
        if (CheckNull.isEmpty(improves)) {
            return;
        }

        StaticDrillBuff buff;
        for (DrillImproveInfo info : improves.values()) {
            buff = staticDrillDataManager.getDrillBuffByIdAndLv(info.getBuffId(), info.getBuffLv());
            attrData.addValue(buff.getAttrId(), buff.getAttrValue());
        }
    }

    /**
     * 秘密武器加成
     *
     * @param player
     * @param attrData
     */
    private void secretWeaponAttr(Player player, AttrData attrData, int pos) {
        if (!player.secretWeaponMap.isEmpty()) {
            for (Entry<Integer, SecretWeapon> entry : player.secretWeaponMap.entrySet()) {
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
            if (null != stone) {// 增加能晶自身加成属性
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
     * 要塞战进修加成
     *
     * @param attrData
     * @param myFortressAttrs
     */
    private void fortressAttr(AttrData attrData, Map<Integer, MyFortressAttr> myFortressAttrs) {
        if (myFortressAttrs != null) {
            Iterator<MyFortressAttr> its = myFortressAttrs.values().iterator();
            while (its.hasNext()) {
                MyFortressAttr my = its.next();
                if (my.getLevel() > 0) {
                    List<List<Integer>> list = staticFortressDataMgr.getStaticFortressAttr(my.getId(), my.getLevel()).getEffect();
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

    private void militaryAttrFight(AttrData attrData, StaticTank staticTank, Map<Integer, MilitaryScienceGrid> scienceGrids,
                                   Map<Integer, MilitaryScience> sciences) {
        int attack = attrData.attack;
        long hp = attrData.hp;
        militaryAttr(attrData, scienceGrids, sciences);
        int militaryAttack = attrData.attack - attack;// 军工增加的攻击
        long militaryHp = attrData.hp - hp;// 军工增加的hp-其他地方都是增加的hpF
        if (militaryAttack > 0) {
            militaryAttack = (int) (militaryAttack * 1f / staticTank.getAttack() * 1000f);
            attrData.attack = attack + militaryAttack;
        }
        if (militaryHp > 0) {
            militaryHp = (int) (militaryHp * 1f / staticTank.getHp() * 1000f);
            attrData.hp = hp + militaryHp;
        }
    }

    /**
     * Method: militaryAttr
     *
     * @Description: 军工科技对属性加层 @param attrData @param scienceGrids @return void @throws
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
                        StaticMilitaryDevelopTree tree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(s.getMilitaryScienceId(),
                                s.getLevel());
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
     * Method: scienceAttr
     *
     * @Description: 加科技属性 @param tankType @param attrData @param sciences @return void @throws
     */
    private void scienceAttr(int tankType, AttrData attrData, Map<Integer, Science> sciences, Map<Integer, PartyScience> partySciences) {
        Iterator<Science> it = sciences.values().iterator();
        while (it.hasNext()) {
            Science science = (Science) it.next();
            StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(science.getScienceId());
            if (staticRefine == null) {
                LogUtil.error("scienceId 不存在 " + science.getScienceId());
                continue;
            }

            if (staticRefine.getType() == tankType) {
                int attrId = staticRefine.getAttributeId();
                int value = staticRefine.getAddtion() * science.getScienceLv();
                attrData.addValue(attrId, value);
            }
        }

        if (partySciences != null) {
            Iterator<PartyScience> ite = partySciences.values().iterator();
            while (ite.hasNext()) {
                PartyScience science = (PartyScience) ite.next();
                StaticRefine staticRefine = staticRefineDataMgr.getStaticRefine(science.getScienceId());
                if (staticRefine == null) {
                    ite.remove();
                    LogUtil.error("scienceId 不存在 " + science.getScienceId());
                    continue;
                }
                if (staticRefine.getType() == 5 || staticRefine.getType() == tankType) {
                    int attrId = staticRefine.getAttributeId();
                    int value = staticRefine.getAddtion() * science.getScienceLv();
                    attrData.addValue(attrId, value);
                }
            }
        }
    }

    /**
     * Method: skillAttr
     *
     * @Description: 加技能属性 @param tankType @param attrData @param skills @return void @throws
     */
    private void skillAttr(int tankType, AttrData attrData, Map<Integer, Integer> skills) {
        for (Map.Entry<Integer, Integer> entry : skills.entrySet()) {
            StaticSkill staticSkill = staticTankDataMgr.getStaticSkill(entry.getKey());

            if (staticSkill == null) {
                return;
            }

            if (staticSkill.getTarget() == 0 || staticSkill.getTarget() == tankType) {
                attrData.addValue(staticSkill.getAttr(), staticSkill.getAttrValue() * entry.getValue());
            }
        }
    }

    /**
     * Method: effectAttr
     *
     * @Description: 效果加成 @param player @param attrData @return void @throws
     */
    private void effectAttr(Player player, AttrData attrData) {
        // 增加己方部队20%伤害
        if (player.effects.containsKey(EffectType.ADD_HURT)) {
            attrData.addValue(AttrId.ATTACK_F, 2000);
        } else if (player.effects.containsKey(EffectType.ADD_HURT_SUPUR)) {
            attrData.addValue(AttrId.ATTACK_F, 3000);
        }

        // 降低地方部队20%伤害
        if (player.effects.containsKey(EffectType.REDUCE_HURT)) {
            attrData.addValue(AttrId.INJURED_F, 2000);
        } else if (player.effects.containsKey(EffectType.REDUCE_HURT_SUPER)) {
            attrData.addValue(AttrId.INJURED_F, 3000);
        }

        // 使用改变基地外观：命中+15%.闪避暴击抗暴+5%
        if (player.effects.containsKey(EffectType.CHANGE_SURFACE_1)) {
            attrData.addValue(AttrId.HIT, 150);
            attrData.addValue(AttrId.DODGE, 50);
            attrData.addValue(AttrId.CRIT, 50);
            attrData.addValue(AttrId.CRITDEF, 50);
        }

        // 使用改变基地外观 ： 命中，抗暴 +20% 闪避，暴击 +10%
        if (player.effects.containsKey(EffectType.CHANGE_SURFACE_992)) {
            attrData.addValue(AttrId.HIT, 200);
            attrData.addValue(AttrId.CRITDEF, 200);
            attrData.addValue(AttrId.DODGE, 100);
            attrData.addValue(AttrId.CRIT, 100);
        }
//		//使用改变基地外观 ： 命中，抗暴 +20% 闪避，暴击 +10%
//		if (player.effects.containsKey(EffectType.CHANGE_SURFACE_2005)) {
//			attrData.addValue(AttrId.HIT, 200);
//			attrData.addValue(AttrId.CRITDEF, 200);
//			attrData.addValue(AttrId.DODGE, 100);
//			attrData.addValue(AttrId.CRIT, 100);
//		}

        // 编制加成
        StaticStaffing staffing = staticStaffingDataMgr.getStaffing(player.lord.getStaffing());
        if (staffing != null) {
            List<List<Integer>> attrs = staffing.getAttr();
            for (List<Integer> attr : attrs) {
                attrData.addValue(attr.get(0), attr.get(1));
            }
        }
    }

    /**
     * Method: effectHeroAttr
     *
     * @Description: 加武将属性和技能属性 @param fighter @param staticHero @param type 1.攻打副本 2.防守玩家 3.其他 @return void @throws
     */
    public void effectHero(Fighter fighter, StaticHero staticHero, int type) {


        //将领默认先手值
        if (staticHero.getSpeed() > 0) {
            fighter.firstValue = fighter.firstValue + staticHero.getSpeed();
        }

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
        if (staticHero.getSkillId() == 14) {// 部队全灭时，有几率复活已经死亡的任意两支部队【不计战损】
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
                int seeds[] = {0, 0};
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
                fighter.getRebornforces().put(pos, null);
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

    /**
     * 编制属性战斗力加成 ---实际属性加成在 effectAttr
     */
    private void staffingAttr(AttrData attrData, Player player) {
        // 编制加成
        StaticStaffing staffing = staticStaffingDataMgr.getStaffing(player.lord.getStaffing());
        if (staffing != null) {
            List<List<Integer>> attrs = staffing.getAttr();
            for (List<Integer> attr : attrs) {
                attrData.addValue(attr.get(0), attr.get(1));
            }
        }
    }

    /**
     * 将领技能增益加成
     *
     * @param type
     * @param force
     * @param staticHero void
     */
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
                    LogUtil.error("觉醒将领技能未配置:" + entry.getKey() + " 等级:" + entry.getValue());
                    continue;
                }
                switch (staticHeroAwakenSkill.getEffectType()) {
                    case HeroConst.EFFECT_TYPE_FIRST_VAL:
                        fighter.firstValue += Integer.parseInt(staticHeroAwakenSkill.getEffectVal());
                        break;
                    case HeroConst.EFFECT_TYPE_SMOKE:
                    case HeroConst.EFFECT_TYPE_BARRIER:
                    case HeroConst.EFFECT_TYPE_DEMAGEF:
                        if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
                            fighter.awakenHeroSkill.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getEffectVal());
                        }
                        break;
                    case HeroConst.HERO_ADD_ATTRIBUTE:
                        if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
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
                        if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
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
                            if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
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

                        String effectVal5 = staticHeroAwakenSkill.getEffectVal();
                        if (effectVal5 != null && !effectVal5.equals("")) {
                            JSONArray jsonArray = JSONArray.parseArray(effectVal5);
                            for (Object str : jsonArray) {
                                JSONArray json = JSONArray.parseArray(str.toString());
                                if (!addHeroResurceAttribute.containsKey(json.getIntValue(0))) {
                                    addHeroResurceAttribute.put(json.getIntValue(0), 0);
                                }
                                addHeroResurceAttribute.put(json.getIntValue(0),
                                        addHeroResurceAttribute.get(json.getIntValue(0)) + json.getIntValue(1));
                            }
                        }

                        break;

                    case HeroConst.HERO_IMMUNE:
                        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
                        if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
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
                        if (staticHero.getAwakenSkillArr().size() != 0) {// 觉醒中的将领不能使用主动技能
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
                                addHeroFhbAttribute.put(json.getIntValue(0),
                                        addHeroFhbAttribute.get(json.getIntValue(0)) + json.getIntValue(1));
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

            // 守卫基地/资源加刚毅 守卫基地/资源加抗暴 守卫基地/资源加防护
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
     * Method: honourBuffAttr
     *
     * @param attrData
     * @param player
     * @Description: 荣耀玩法buff加成
     */
    private void honourBuffAttr(AttrData attrData, Player player) {
        int pos = player.lord.getPos();
        if (pos == -1)
            return;
        StaticHonourBuff buff = honourDataManager.getHonourBuff(pos);
        if (buff == null)
            return;
        Map<Integer, Integer> attrBuff = buff.getAttrBuff();
        for (Entry<Integer, Integer> attr : attrBuff.entrySet()) {
            if (buff.getType() == 1) {
                attrData.addValue(attr.getKey(), attr.getValue());
            } else {
                attrData.delValue(attr.getKey(), attr.getValue());
            }
        }
    }

    /**
     * 加完成属性(所有)
     *
     * @param attrData
     * @param player
     */
    private void energyCoreAttr(AttrData attrData, Player player) {
        Map<Integer, StaticCoreAward> allAwardConfig = staticCoreDataMgr.getAllAwardConfig();
        if (allAwardConfig != null) {
            for (int i = 1; i < player.energyCore.getLevel(); i++) {
                StaticCoreAward aw = allAwardConfig.get(i);
                if (aw != null) {
                    //完成奖励只加一次
                    for (List<Integer> integers : aw.getFinishAward()) {
                        attrData.addValue(integers.get(0), integers.get(1));
                    }
                }
            }
            StaticCoreAward aw = allAwardConfig.get(player.energyCore.getLevel());
            if (aw != null && player.energyCore.getState() == 1) {
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
     * @param player
     */
    private void energyPosCoreAttr(AttrData attrData, Player player, int pos) {
        Map<Integer, StaticCoreAward> allAwardConfig = staticCoreDataMgr.getAllAwardConfig();
        if (allAwardConfig != null) {
            for (int i = 1; i < player.energyCore.getLevel(); i++) {
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
            StaticCoreAward aw = allAwardConfig.get(player.energyCore.getLevel());
            if (aw != null && aw.getIndex() == pos) {
                for (int j = 1; j < player.energyCore.getSection(); j++) {
                    for (List<Integer> integers : aw.getLightAward()) {
                        attrData.addValue(integers.get(0), integers.get(1));
                    }
                }
            }
        }
    }

    /**
     * 关卡经验加成增益
     *
     * @param player
     * @param staticHero
     * @return float
     */
    public float effectCombatExpAdd(Player player, StaticHero staticHero) {
        float factor = 1;

        if (staticHero != null && staticHero.getSkillId() == 3) {
            factor += (staticHero.getSkillValue() / NumberHelper.HUNDRED_FLOAT);
        }

        Science science1 = player.sciences.get(ScienceId.FIGHT_EXP);
        if (science1 != null) {
            factor += (5 * science1.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
        }

        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science2 = sciences.get(ScienceId.PARTY_FIGHT_EXP);
            if (science2 != null) {
                factor += (science2.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
            }
        }

        int revelry[] = activityDataManager.revelry();
        factor += revelry[1] / 100f;

        // vip新增经验加成
        float expup = staticVipDataMgr.getStaticVip(player.lord.getVip()).getExpup();
        factor += expup;

        return factor;
    }

    /**
     * 矿点战斗经验加成
     *
     * @param player
     * @param staticHero
     * @return float
     */
    public float effectMineExpAdd(Player player, StaticHero staticHero) {
        float factor = 1;

        if (staticHero != null && staticHero.getSkillId() == 4) {
            factor += (staticHero.getSkillValue() / NumberHelper.HUNDRED_FLOAT);
        }

        Science science1 = player.sciences.get(ScienceId.FIGHT_EXP);
        if (science1 != null) {
            factor += (5 * science1.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
        }

        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science2 = sciences.get(ScienceId.PARTY_FIGHT_EXP);
            if (science2 != null) {
                factor += (science2.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
            }
        }

        // vip新增经验加成
        float expup = staticVipDataMgr.getStaticVip(player.lord.getVip()).getExpup();
        factor += expup;

        return factor;
    }

    /**
     * 军团副本经验加成
     *
     * @param player
     * @return float
     */
    public float effectExpAdd(Player player) {
        float factor = 1;

        Science science1 = player.sciences.get(ScienceId.FIGHT_EXP);
        if (science1 != null) {
            factor += (5 * science1.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
        }

        Map<Integer, PartyScience> sciences = partyDataManager.getScience(player);
        if (sciences != null) {
            PartyScience science2 = sciences.get(ScienceId.PARTY_FIGHT_EXP);
            if (science2 != null) {
                factor += (science2.getScienceLv() / NumberHelper.HUNDRED_FLOAT);
            }
        }

        // vip新增经验加成
        float expup = staticVipDataMgr.getStaticVip(player.lord.getVip()).getExpup();
        factor += expup;

        return factor;
    }

    /**
     * 作战实验室属性加成
     *
     * @param attrData
     * @param labInfo
     */
    private void fightLabAttr(AttrData attrData, LabInfo labInfo, StaticTank staticTank) {

        Map<Integer, Map<Integer, Integer>> map = labInfo.getGraduateInfo();
        for (Entry<Integer, Map<Integer, Integer>> typeEntry : map.entrySet()) {
            for (Entry<Integer, Integer> skillEntry : typeEntry.getValue().entrySet()) {
                Integer level = skillEntry.getValue();
                if (level != null && level > 0) {
                    StaticLaboratoryMilitary data = staticFightLabDataMgr.getGraduateConfig(typeEntry.getKey(), skillEntry.getKey(),
                            skillEntry.getValue());
                    if (data != null) {

                        if (data.getType() == staticTank.getType()) {
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
     * Method: calcTankFight
     *
     * @Description: 计算坦克的战力(不包括装备) @param player @param tankId @return @return int @throws
     */
    public double calcTankFightWithoutEquip(Player player, int tankId, StaticHero staticHero) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);

        AttrData attrData = new AttrData(staticTank);

        // double fight = 0d;

        // if (player.lord.getNick().equals("cj")){//基础战力
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [base] cur fight :%f, sub fight :%f ", totalFight, totalFight- fight));
        // fight = totalFight;
        // }

        partAttrFight(attrData, player.parts.get(staticTank.getType()));// 配件
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [partAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        militaryAttrFight(attrData, staticTank, player.militaryScienceGrids.get(tankId), player.militarySciences);// 军工科技
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [militaryAttrFight] cur fight :%f, sub fight :%f ", totalFight,
        // totalFight- fight));
        // fight = totalFight;
        // }

        scienceAttr(staticTank.getType(), attrData, player.sciences, partyDataManager.getScience(player));// 科技(科研所)
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [scienceAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        skillAttr(staticTank.getType(), attrData, player.skills);// 指挥官技能
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [skillAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        effectHeroAttr(attrData, staticHero);// 将领BUFF
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [effectHeroAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        medalAttr(attrData, player.medals.get(1));// 勋章
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [medalAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        medalBounsAttr(attrData, player.medalBounss.get(1));// 勋章展厅
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [medalBounsAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        staffingAttr(attrData, player);
        // if (player.lord.getNick().equals("cj")){//编制
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [staffingAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        lordEquiqAttr(player, attrData, player.leqInfo.getPutonLordEquips());// 军备属性
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [lordEquiqAttr] cur fight :%f, sub fight :%f ", totalFight, totalFight-
        // fight));
        // fight = totalFight;
        // }

        militaryRankAttr(attrData, player.lord.getMilitaryRank()); // 军衔等级附加属性
        // if (player.lord.getNick().equals("cj")){
        // double totalFight = calcFight(attrData, staticTank);
        // LogUtil.error(String.format("nick cj [militaryRankAttr] cur fight :%f, sub fight :%f ", totalFight,
        // totalFight- fight));
        // fight = totalFight;
        // }

        fightLabAttr(attrData, player.labInfo, staticTank);// 作战实验室

        tacticsAttrFight(player, attrData, staticTank);// 战术

        energyCoreAttr(attrData, player);//能源核心完成加成

        return calcFight(attrData, staticTank);
    }

    /**
     * 计算属性战力
     *
     * @param attrData   属性集合
     * @param staticTank 坦克信息
     * @return
     */
    private double calcFight(AttrData attrData, StaticTank staticTank) {
        // 属性 * 战力固定值
        return (attrData.attack - staticTank.getAttack()) * staticTank.getAttckFactor()
                + (attrData.hp - staticTank.getHp()) * staticTank.getHpFactor() + attrData.attackF * staticTank.getAttckFactor() / 10d
                + attrData.hpF * staticTank.getHpFactor() / 10d + (attrData.hit - staticTank.getHit()) * 0.1d
                + (attrData.crit - staticTank.getCrit()) * 0.1d + (attrData.critDef - staticTank.getCritDef()) * 0.1d
                + (attrData.dodge - staticTank.getDodge()) * 0.1d + (attrData.impale - staticTank.getImpale()) * 0.01d
                + (attrData.defend - staticTank.getDefend()) * 0.01d + (attrData.tenacityF) * 0.01d + (attrData.burstF) * 0.01d
                + (attrData.frighten) * 0.01d + (attrData.fortitude) * 0.01d + (attrData.injuredF) * 0.01d + staticTank.getFight();
    }

    /**
     * 计算相应位置的加成属性
     *
     * @param player
     * @param tankId
     * @param pos
     * @return
     */
    private float calcTankFight(Player player, int tankId, int pos) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        AttrData attrData = new AttrData(staticTank);

        // 添加秘密武器属性
        secretWeaponAttr(player, attrData, pos);

        //能源核心点亮加成(只加对应位置)
        energyPosCoreAttr(attrData, player, pos);

        //计算坦克
        calcTankEquipFight(player, attrData, pos);

        return (attrData.attack - staticTank.getAttack()) * staticTank.getAttckFactor()
                + attrData.attackF * staticTank.getAttckFactor() / 10 + attrData.hpF * staticTank.getHpFactor() / 10
                + (attrData.hit - staticTank.getHit()) * 0.1f + (attrData.crit - staticTank.getCrit()) * 0.1f
                + (attrData.critDef - staticTank.getCritDef()) * 0.1f + (attrData.dodge - staticTank.getDodge()) * 0.1f
                + (attrData.impale - staticTank.getImpale()) * 0.01f + (attrData.defend - staticTank.getDefend()) * 0.01f
                + (attrData.tenacityF) * 0.01f + (attrData.burstF) * 0.01f + (attrData.frighten) * 0.01f + (attrData.injuredF) * 0.01f
                + (attrData.fortitude) * 0.01f;

    }


    /**
     * Method: calcTankEquipFight
     *
     * @Description: 计算坦克的装备战力 @param player @param tankId @param pos @return @return float @throws
     */
    private void calcTankEquipFight(Player player, AttrData attrData, int pos) {
        if (!player.equips.get(pos).isEmpty()) {
            equipAttr(attrData, player.equips.get(pos));
        }
        Map<Integer, EnergyStoneInlay> inlays = player.energyInlay.get(pos);
        if (inlays != null && !inlays.isEmpty()) {
            energyStoneAttr(attrData, player.energyInlay.get(pos));
        }
    }


    /**
     * 计算属性战力
     *
     * @param attrData 属性集合
     * @return
     */
    public double calcNewFight(AttrData attrData) {
        // 属性 * 战力固定值
        return (attrData.attack)
                + (attrData.hp) + attrData.attackF / 10d
                + attrData.hpF / 10d + (attrData.hit) * 0.1d
                + (attrData.crit) * 0.1d + (attrData.critDef) * 0.1d
                + (attrData.dodge) * 0.1d + (attrData.impale) * 0.01d
                + (attrData.defend) * 0.01d + (attrData.tenacityF) * 0.01d + (attrData.burstF) * 0.01d
                + (attrData.frighten) * 0.01d + (attrData.fortitude) * 0.01d + (attrData.injuredF) * 0.01d;
    }


    /**
     * Method: calcFormFight
     *
     * @Description: 计算阵型战力 @param player @param form @return @return int @throws
     */
    public long calcFormFight(Player player, Form form) {
        StaticHero staticHero = null;
        if (form.getAwakenHero() != null) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getAwakenHero().getHeroId());
        } else if (form.getCommander() > 0) {
            staticHero = staticHeroDataMgr.getStaticHero(form.getCommander());
        }

        Double fight;
        float totalFight = 0;
        Map<Integer, Double> cacheFight = new HashMap<> ();
        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                fight = cacheFight.get(p[i]);
                if (fight == null) {
                    fight = calcTankFightWithoutEquip(player, p[i], staticHero);
                    cacheFight.put(p[i], fight);
                }
                totalFight += (fight * c[i] + calcTankFight(player, p[i], i + 1) * c[i]);
            }
        }
        return (long) Math.floor(totalFight);
    }

    /**
     * Method: selectMaxFightHero
     *
     * @Description: 上阵优先级最高的武将 @param player @return @return StaticHero @throws
     */
    public StaticHero selectMaxFightHero(Player player, int ismax) {
        Iterator<Integer> it = player.heros.keySet().iterator();
        int i;
        int max = 0;
        while (it.hasNext()) {
            i = it.next();
            if (i > max) {
                max = i;
            }
        }
        if (ismax == 0) {
            for (AwakenHero awakenHero : player.awakenHeros.values()) {
                if (!awakenHero.isUsed() && awakenHero.getHeroId() > max) {
                    max = awakenHero.getHeroId();
                }
            }
        } else {
            for (AwakenHero awakenHero : player.awakenHeros.values()) {
                if (awakenHero.getHeroId() > max) {
                    max = awakenHero.getHeroId();
                }
            }
        }

        StaticHero staticHero = staticHeroDataMgr.getStaticHero(max);
        if (staticHero == null || staticHero.getType() != 2) {
            return null;
        }

        return staticHero;
    }

    /**
     *
     * Method: calcFight
     *
     * @Description: 计算玩家最大战力 @param player @return @return int @throws
     */
    // public int calcMaxFight(Player player) {
    // int slot = playerDataManager.formSlotCount(player.lord.getLevel());
    // StaticHero staticHero = selectMaxFightHero(player,0);
    // int tankCount = playerDataManager.formTankCount(player, staticHero);
    // Map<Integer, Tank> tanks = player.tanks;
    // List<Turple3<Integer, Integer, Integer>> orderList = new ArrayList<>();
    // Map<Integer, Double> cacheFight = new HashMap<>();
    // Iterator<Tank> it = tanks.values().iterator();
    // Integer tankId;
    // int count;
    // while (it.hasNext()) {
    // Tank tank = (Tank) it.next();
    // tankId = tank.getTankId();
    // count = tank.getCount();
    // Double fight = cacheFight.get(tankId);
    // if (fight == null) {
    // fight = calcTankFightWithoutEquip(player, tankId, staticHero);
    // cacheFight.put(tankId, fight);
    // }
    //
    // if (count > 0) {
    // if (count <= tankCount) {
    // orderList.add(new Turple3<Integer, Integer, Integer>(tankId, (int) (fight * count), count));
    // break;
    // } else {
    // count -= tankCount;
    // orderList.add(new Turple3<Integer, Integer, Integer>(tankId, (int) (fight * tankCount), tankCount));
    // }
    // }
    // }
    // Collections.sort(orderList, new Comparator<Turple3<Integer, Integer, Integer>>() {
    // @Override
    // public int compare(Turple3<Integer, Integer, Integer> o1, Turple3<Integer, Integer, Integer> o2) {
    // if (o1.getB() < o2.getB()) {
    // return 1;
    // }
    // return -1;
    // }
    // });
    //
    // int fight = 0;
    // for (int i = 0; i < slot && i < orderList.size(); i++) {
    // Turple3<Integer, Integer, Integer> one = orderList.get(i);
    // fight += one.getB();
    // fight += calcTankEquipFight(player, one.getA(), i + 1) * one.getC();
    // }
    //
    // return fight;
    // }

    /**
     *
     * Method: calcFight
     *
     * @Description: 计算玩家总战斗力 @param player @return @return int @throws
     */
    // public long calcMaxMaxFight(Player player) {
    // int slot = playerDataManager.formSlotCount(player.lord.getLevel());
    // int tankCount = 0;
    // StaticHero staticHero = null;
    // if(player.heros.size()!=0){
    // staticHero = selectMaxFightHero(player,1);
    // tankCount = playerDataManager.formTankCount(player, staticHero);
    // }else{
    // tankCount = playerDataManager.formTankCount(player, null);
    // }
    // Map<Integer, Tank> tanks = player.tanks;
    // List<Turple3<Integer, Integer, Integer>> orderList = new ArrayList<>();
    // Map<Integer, Double> cacheFight = new HashMap<>();
    // Iterator<Tank> it = tanks.values().iterator();
    // Integer tankId;
    // int count;
    // int lv = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_1, player.building);
    // int lv1 = PlayerDataManager.getBuildingLv(BuildingId.FACTORY_2, player.building);
    // lv = lv > lv1 ? lv : lv1;
    // while (it.hasNext()) {
    // Tank tank = (Tank) it.next();
    // tankId = tank.getTankId();
    //
    // StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
    // if(staticTank.getFactoryLv()!=0&&staticTank.getFactoryLv()<=lv){
    // count = slot*tankCount;
    // }else{
    // count = tank.getCount();
    // }
    // Double fight = cacheFight.get(tankId);
    // if (fight == null) {
    // fight = calcTankFightWithoutEquip(player, tankId, staticHero);
    // cacheFight.put(tankId, fight);
    // }
    // if (count > 0) {
    // while (true) {
    // if (count <= tankCount) {
    // orderList.add(new Turple3<Integer, Integer, Integer>(tankId, (int) (fight * count), count));
    // break;
    // } else {
    // count -= tankCount;
    // orderList.add(new Turple3<Integer, Integer, Integer>(tankId, (int) (fight * tankCount), tankCount));
    // }
    // }
    // }
    // }
    // Collections.sort(orderList, new Comparator<Turple3<Integer, Integer, Integer>>() {
    // @Override
    // public int compare(Turple3<Integer, Integer, Integer> o1, Turple3<Integer, Integer, Integer> o2) {
    // if (o1.getB() < o2.getB()) {
    // return 1;
    // }
    // return -1;
    // }
    // });
    //
    // long fight = 0;
    // for (int i = 0; i < slot && i < orderList.size(); i++) {
    // Turple3<Integer, Integer, Integer> one = orderList.get(i);
    // fight += one.getB();
    // fight += calcTankEquipFight(player, one.getA(), i + 1) * one.getC();
    // }
    //
    // return fight;
    // }

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

    public int getAttackEffectId(Player player, int type) {
        AttackEffect effect = player.atkEffects.get(type);
        return effect != null ? effect.getUseId() : 0;
    }


    /**
     * 战术属性
     *
     * @param player
     * @param force
     * @param form
     * @param staticTank
     */
    private void tacticsAttr(Player player, Force force, Form form, StaticTank staticTank) {

        List<Tactics> tactics = tacticsService.getPlayerTactics(player, form.getTactics());

        Map<Integer, Integer> attr = new HashMap<>();


        //战术基础属性
        Map<Integer, Integer> baseAttribute = tacticsService.getBaseAttribute(tactics);
        //战术 全部装配单一效果战术属性
        Map<Integer, Integer> taozhaungAttribute = tacticsService.getTaozhaungAttribute(tactics);
        // 兵种套属性
        Map<Integer, Integer> tankTypeAttribute = tacticsService.getTankTypeAttribute(tactics, staticTank);

        //这个用于伤害计算
        StaticTacticsTankSuit tankTypeAttributeConfig = tacticsService.getTankTypeAttributeConfig(tactics);
        if (tankTypeAttributeConfig != null && staticTank.getType() == tacticsService.getTankType(tactics)) {
            force.tacticsTankSuitConfig = tankTypeAttributeConfig;
        }

        MapUtil.addMapValue(attr, baseAttribute);
        MapUtil.addMapValue(attr, taozhaungAttribute);
        MapUtil.addMapValue(attr, tankTypeAttribute);


        //添加属性
        for (Entry<Integer, Integer> e : attr.entrySet()) {
            force.attrData.addValue(e.getKey(), e.getValue());
        }


    }

    /**
     * 实力榜计算战术属性
     *
     * @param player
     * @param attrData
     * @param staticTank
     */
    private void tacticsAttrFight(Player player, AttrData attrData, StaticTank staticTank) {


//        LogUtil.error("tacticsAttrFight 1 roleId=" + player.lord.getNick());

        List<Tactics> tacticsList = tacticsService.getTacticsMaxFight(player, staticTank);

//        LogUtil.error("tacticsAttrFight 2 roleId=" + player.lord.getNick() + "tacticsList= " + JSON.toJSONString(tacticsList));


        //战术基础属性
        Map<Integer, Integer> baseAttribute = tacticsService.getBaseAttribute(tacticsList);
        //添加属性
        for (Entry<Integer, Integer> e : baseAttribute.entrySet()) {
            attrData.addValue(e.getKey(), e.getValue());
        }

//        LogUtil.error("tacticsAttrFight 3 roleId=" + player.lord.getNick() + "baseAttribute= " + JSON.toJSONString(baseAttribute));

    }
}
