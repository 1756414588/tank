/**
 * @Title: FightLogic.java
 * @Package com.game.fight
 * @Description:
 * @author ZhangJun
 * @date 2015年8月29日 上午11:38:30
 * @version V1.0
 */
package com.game.fight;

import java.util.*;
import java.util.Map.Entry;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.game.constant.FirstActType;
import com.game.constant.HeroConst;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBuff;
import com.game.domain.s.StaticHeroAwakenSkill;
import com.game.domain.s.StaticTank;
import com.game.fight.domain.AttrData;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Reborn;
import com.game.server.GameServer;
import com.game.service.TacticsService;
import com.game.util.LogUtil;
import com.game.util.LotteryUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;

/**
 * @author ZhangJun
 * @ClassName: FightLogic
 * @Description: 战斗逻辑类
 * @date 2015年8月29日 上午11:38:30
 */
public class FightLogic {

    public boolean recordFlag = true;
    private Fighter first;
    private Fighter second;
    private int loopCounter = 100;
    private Force[] forces = new Force[12];

    // 进攻方胜负 1.胜 2.负
    private int winState = 0;

    private int forceRound = 0;

    private CommonPb.Record.Builder recordData;
    private CommonPb.Round.Builder roundData;
    private CommonPb.Action.Builder actionData;

    // 是否开启震慑功能
    private boolean isFrighten;

    public FightLogic(Fighter attacker, Fighter defencer, int firstStrategy, boolean recordFlag) {
        isFrighten = GameServer.ac.getBean(StaticFunctionPlanDataMgr.class).isFrightenOpen();
        GameServer.ac.getBean(TacticsService.class).calTacticsRestrictAttribute(attacker, defencer);
        attacker.isAttacker = true;
        this.recordFlag = recordFlag;
        if (recordFlag) {
            recordData = CommonPb.Record.newBuilder();
        }
        // 判定先手方
        if (firstStrategy == FirstActType.ATTACKER) {
            first = attacker;
            second = defencer;
        } else if (firstStrategy == FirstActType.DEFENCER) {
            first = defencer;
            second = attacker;
        } else if (firstStrategy == FirstActType.FISRT_VALUE_1) {
            if (attacker.firstValue > defencer.firstValue) {
                first = attacker;
                second = defencer;
            } else {
                first = defencer;
                second = attacker;
            }
        } else if (firstStrategy == FirstActType.FISRT_VALUE_2) {
            if (attacker.firstValue >= defencer.firstValue) {
                first = attacker;
                second = defencer;
            } else {
                first = defencer;
                second = attacker;
            }
        } else if (firstStrategy == FirstActType.FISRT_VALUE_DRILL) {
            if (attacker.firstValue > defencer.firstValue
                    || (attacker.firstValue == defencer.firstValue && RandomHelper.isHitRangeIn100(50))) {
                first = attacker;
                second = defencer;
            } else {
                first = defencer;
                second = attacker;
            }
        }

        first.oppoFighter = second;
        second.oppoFighter = first;

        first.fightLogic = this;
        second.fightLogic = this;
        // 出手顺序初始化
        numberForce();
        initAura();
        for (Force force : forces) {
            if (force != null) {
                if (!force.fighter.isFighted) {
                    force.initHp();
                }
                if (recordFlag) {
                    recordData.addHp(force.hp);
                }
            }
        }

        // 备份可能复活的部队
        if (!first.isFighted) {
            for (Integer pos : first.getRebornforces().keySet()) {

                Force force = first.forces[pos].copyForce();
                force.calFhAttr();
                force.initHp();
                first.getRebornforces().put(pos, force);
            }
        }

        if (!second.isFighted) {
            for (Integer pos : second.getRebornforces().keySet()) {
                Force force = second.forces[pos].copyForce();
                force.calFhAttr();
                force.initHp();
                second.getRebornforces().put(pos, force);
            }
        }
        first.isFighted = true;
        second.isFighted = true;

        // 设置战斗中的秘密武器特效
        packSecretWeapon(attacker, defencer);

        // 设置战斗中坦克攻击特效
        packAttackEffect(attacker, defencer);

    }

    public void packForm(Form a, Form b) {
        recordData.setFormA(PbHelper.createFormPb(a));
        if (b != null) {
            recordData.setFormB(PbHelper.createFormPb(b));
        }
    }

    public void packSecretWeapon(Fighter attacker, Fighter defencer) {
        // 设置战斗中秘密武器的使用
        if (recordData != null && attacker.player != null) {
            int secretWeaponId = attacker.player.getHighestOpenSecretWeapon();
            if (secretWeaponId > 0) {
                CommonPb.FormExt.Builder extA = CommonPb.FormExt.newBuilder();
                extA.addWeaponId(secretWeaponId);
                recordData.setFormExtA(extA);
            }
        }

        if (recordData != null && defencer.player != null) {
            int secretWeaponId = defencer.player.getHighestOpenSecretWeapon();
            if (secretWeaponId > 0) {
                CommonPb.FormExt.Builder extB = CommonPb.FormExt.newBuilder();
                extB.addWeaponId(secretWeaponId);
                recordData.setFormExtB(extB);
            }
        }
    }

    /**
     * 设置攻击特效
     *
     * @param attacker
     * @param defencer
     */
    public void packAttackEffect(Fighter attacker, Fighter defencer) {
        if (recordData != null && attacker.player != null) {
            CommonPb.FormExt.Builder builder;
            if (recordData.getFormExtA() != null) {
                builder = recordData.getFormExtA().toBuilder();
            } else {
                builder = CommonPb.FormExt.newBuilder();
            }
            for (Force force : attacker.forces) {
                builder.addEid(force != null ? force.eid : 0);
            }
            recordData.setFormExtA(builder);
        }

        if (recordData != null && defencer.player != null) {
            CommonPb.FormExt.Builder builder;
            if (recordData.getFormExtB() != null) {
                builder = recordData.getFormExtB().toBuilder();
            } else {
                builder = CommonPb.FormExt.newBuilder();
            }
            for (Force force : defencer.forces) {
                builder.addEid(force != null ? force.eid : 0);
            }
            recordData.setFormExtB(builder);
        }
    }

    private void initAura() {
        // 还原坦克光环之前的属性
        if (first.isFighted) {
            for (Force force : first.forces) {
                if (force != null) {
                    List<StaticBuff> buffs = force.staticTank.getBuffs();
                    if (buffs != null) {
                        for (StaticBuff staticBuff : buffs) {
                            if (staticBuff.getType() == 1) {
                                first.delEffectAura(staticBuff);
                            } else {
                                second.delEffectAura(staticBuff);
                            }
                        }
                    }
                }
            }
            first.aura.clear();
        }

        for (Force force : first.forces) {
            if (force != null) {
                List<StaticBuff> buffs = force.staticTank.getBuffs();
                if (buffs != null) {
                    for (StaticBuff staticBuff : buffs) {
                        if (staticBuff.getType() == 1) {
                            first.addAura(staticBuff);
                        } else {
                            second.addAura(staticBuff);
                        }
                    }
                }
            }
        }

        if (second.isFighted) {
            for (Force force : second.forces) {
                if (force != null) {
                    List<StaticBuff> buffs = force.staticTank.getBuffs();
                    if (buffs != null) {
                        for (StaticBuff staticBuff : buffs) {
                            if (staticBuff.getType() == 1) {
                                second.delEffectAura(staticBuff);
                            } else {
                                first.delEffectAura(staticBuff);
                            }
                        }
                    }
                }
            }
            second.aura.clear();
        }

        for (Force force : second.forces) {
            if (force != null) {
                List<StaticBuff> buffs = force.staticTank.getBuffs();
                if (buffs != null) {
                    for (StaticBuff staticBuff : buffs) {
                        if (staticBuff.getType() == 1) {
                            second.addAura(staticBuff);
                        } else {
                            first.addAura(staticBuff);
                        }
                    }
                }
            }
        }

        first.effectAura();
        second.effectAura();
    }

    private void arrangeAura(Force dieForce) {
        List<StaticBuff> list = dieForce.staticTank.getBuffs();
        if (list != null) {
            for (StaticBuff buff : list) {
                if (buff.getType() == 1) {
                    dieForce.fighter.removeAura(buff);
                } else {
                    dieForce.fighter.oppoFighter.removeAura(buff);
                }
            }
        }
    }

    /**
     * Method: calcStar
     *
     * @return int
     * @Description: 星级评定
     */
    public int estimateStar() {
        Fighter fighter = null;
        if (first.isAttacker) {
            fighter = first;
        } else {
            fighter = second;
        }

        int left = 0;
        for (Force force : fighter.forces) {
            if (force != null && force.alive()) {
                left += force.count;
            }
        }

        float ratio = left / (float) fighter.totalTank;
        if (ratio >= 0.9f) {
            return 3;
        } else if (ratio >= 0.8f) {
            return 2;
        } else {
            return 1;
        }
    }

    public void fight() {

        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_SMOKE)) {
            // 烟幕打击 战斗开始前，高速射出一波烟幕弹，随机使敌方1-6个部队一回合无法行动。
            addSkillEffectSmoke(second, first.awakenHeroSkill.get(HeroConst.ID_SKILL_SMOKE));
        }
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(first, Integer.parseInt(first.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(first, first.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_SMOKE)) {
            // 烟幕打击 战斗开始前，高速射出一波烟幕弹，随机使敌方1-6个部队一回合无法行动。
            addSkillEffectSmoke(first, second.awakenHeroSkill.get(HeroConst.ID_SKILL_SMOKE));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(second, Integer.parseInt(second.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(second, second.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(second);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(second);
        }

        // 增加闪避（全体）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(second);
        }

        int rebornState = 0;
        while (loopCounter-- > 0 && winState == 0) {

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr(second);
                }

            }
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (first.loopCounter)) {
                    cancelSkillEffectSubHurt(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (second.loopCounter)) {
                    cancelSkillEffectSubHurt(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (first.loopCounter)) {
                    cancelSkillEffectImmune(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (second.loopCounter)) {
                    cancelSkillEffectImmune(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr20(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr20(second);
                }

            }

            if (rebornState == 2) {// 后手方死亡 先手攻击
                roundB();
            } else {
                round();
            }
            rebornState = checkDie();

            // 一轮回合后减少风行者觉醒技的增伤值
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = first.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = second.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }

            first.loopCounter++;
            second.loopCounter++;

        }
    }

    /**
     * 每回合减少风行者增加的增伤值，如果减少到0，则删除该effect
     */
    private void subDemageF(Force force) {
        List<Integer> twoInt = (List<Integer>) force.skillEffect.get(HeroConst.ID_SKILL_11);
        if (twoInt == null || twoInt.size() != 2) {
            return;
        }

        // 每回合增伤值都会减少
        int demageF = twoInt.get(0) - twoInt.get(1);

        // 增伤值减少到小于等于0则删除改特效
        if (demageF > 0) {
            twoInt.set(0, demageF);
        } else {
            force.skillEffect.remove(HeroConst.ID_SKILL_11);
            // 通知客户端取消特效光环
            addAddSkillEffect(force.key, -HeroConst.ID_SKILL_11);
        }
    }

    public void fightBoss() {

        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(first, Integer.parseInt(first.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(first, first.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(second, Integer.parseInt(second.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(second, second.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(second);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(second);
        }

        // 增加闪避（全体）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(second);
        }

        int rebornState = 0;
        while (loopCounter-- > 0 && winState == 0) {

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr(second);
                }

            }
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (first.loopCounter)) {
                    cancelSkillEffectSubHurt(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (second.loopCounter)) {
                    cancelSkillEffectSubHurt(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (first.loopCounter)) {
                    cancelSkillEffectImmune(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (second.loopCounter)) {
                    cancelSkillEffectImmune(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr20(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr20(second);
                }

            }

            if (rebornState == 2) {// 后手方死亡 先手攻击
                bossRoundB();
            } else {
                bossRound();
            }
            rebornState = checkDie();

            // 一轮回合后减少增伤值
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = first.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = second.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }

            first.loopCounter++;
            second.loopCounter++;

        }
    }

    /**
     * 组队战斗
     */
    public void fightTeam() {

        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
            addSkillEffectImmune(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(first, Integer.parseInt(first.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(first, first.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }

        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_BARRIER)) {
            // 幽能屏障 幽影特工开启幽能屏障，首回合受到伤害-10%。
            addSkillEffectBarrier(second, Integer.parseInt(second.awakenHeroSkill.get(HeroConst.ID_SKILL_BARRIER)));
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
            // 雷厉风行 觉醒技，迅速集中优势火力，对敌方进行猛烈轰击，使部队最终伤害+30%。这个效果每回合会-10%，直至完全消失。
            addSkillEffectAddDemageF(second, second.awakenHeroSkill.get(HeroConst.ID_SKILL_11));
        }

        // 增加闪避（全体）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
            addSkillEffectAttr20(second);
        }

        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
            addSkillEffectAttr(second);
        }

        // 第一回合部分部队免疫震慑和穿刺
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(first);
        }
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
            addSkillEffectSubHurt(second);
        }

        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(first);
        }
        // 第一回合部分部队免疫震慑和穿刺（1-3个部队，随机概率）
        if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_19)) {
            addSkillEffectFhBuff(second);
        }

        int rebornState = 0;
        while (loopCounter-- > 0 && winState == 0) {

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_16)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_16)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr(second);
                }

            }
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (first.loopCounter)) {
                    cancelSkillEffectSubHurt(first);
                }

            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_17)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_17)) <= (second.loopCounter)) {
                    cancelSkillEffectSubHurt(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (first.loopCounter)) {
                    cancelSkillEffectImmune(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_18)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_18)) <= (second.loopCounter)) {
                    cancelSkillEffectImmune(second);
                }

            }

            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {

                if (Integer.valueOf(first.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (first.loopCounter)) {
                    cancelSkillEffectAttr20(first);
                }

            }

            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_20)) {
                if (Integer.valueOf(second.awakenHeroSkill.get(HeroConst.ID_SKILL_20)) <= (second.loopCounter)) {
                    cancelSkillEffectAttr20(second);
                }

            }

            if (rebornState == 2) {// 后手方死亡 先手攻击
                teamRoundB();
            } else {
                teamRound();
            }
            rebornState = teamCheckDie();

            // 一轮回合后减少风行者觉醒技的增伤值
            if (first.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = first.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }
            if (second.awakenHeroSkill.containsKey(HeroConst.ID_SKILL_11)) {
                Force force;
                for (int i = 0; i < 6; i++) {
                    force = second.forces[i];
                    if (force != null) {
                        subDemageF(force);
                    }
                }
            }

            first.loopCounter++;
            second.loopCounter++;

        }

    }

    public CommonPb.Record generateRecord() {
        recordData.setFirst(first.isAttacker);
        return recordData.build();
    }

    public boolean attackerIsFirst() {
        return first.isAttacker;
    }

    private int teamCheckDie() {
        boolean firstAlive = false;
        boolean secondAlive = false;
        for (Force force : first.forces) {
            if (force != null) {
                if (force.alive()) {
                    firstAlive = true;
                }
            }
        }

        for (Force force : second.forces) {
            if (force != null) {

                if (force.alive()) {
                    secondAlive = true;
                } else {
                    // 自爆卡车只有打过才算死亡
                    if (force.type == 6 && !force.isExplosion) {
                        secondAlive = true;
                    }
                }
            }
        }

        if (firstAlive && secondAlive) {
            setWinState(0);
        } else {
            // int rebornState = checkReborn(firstAlive, secondAlive);
            // if (rebornState > 0) {
            // setWinState(0);
            // return rebornState;
            // }

            // backRebornAura();

            // 如果双方都死了判定玩家赢
            if (!firstAlive && !secondAlive) {
                setWinState(1);
                return 0;
            }

            if (first.isAttacker) {
                setWinState(firstAlive ? 1 : 2);
            } else {
                setWinState(firstAlive ? 2 : 1);
            }
        }
        return 0;
    }

    private int checkDie() {
        boolean firstAlive = false;
        boolean secondAlive = false;
        for (Force force : first.forces) {
            if (force != null) {
                if (force.alive()) {
                    firstAlive = true;
                }
            }
        }

        for (Force force : second.forces) {
            if (force != null) {
                if (force.alive()) {
                    secondAlive = true;
                }
            }
        }

        if (firstAlive && secondAlive) {
            setWinState(0);
        } else {
            int rebornState = checkReborn(firstAlive, secondAlive);
            if (rebornState > 0) {
                setWinState(0);
                return rebornState;
            }

            backRebornAura();

            if (first.isAttacker) {
                setWinState(firstAlive ? 1 : 2);
            } else {
                setWinState(firstAlive ? 2 : 1);
            }
        }
        return 0;
    }

    /**
     * 0不复活 1先手玩家复活 2后手玩家复活
     */
    private int checkReborn(boolean firstAlive, boolean secondAlive) {
        int rebornState = 0;
        if (!firstAlive && first.getRebornforces().size() > 0 && !first.isReborn) {// 部队全灭
            first.isReborn = true;
            rebornState = 1;
            Set<Integer> posSet = new HashSet<>(first.getRebornforces().keySet());

            Reborn.Builder reborn = null;
            if (recordFlag) {
                reborn = Reborn.newBuilder();
                reborn.setRound(forceRound);
            }
            for (Integer pos : posSet) {
                // 部队替换
                Force newForce = first.getRebornforces().get(pos);
                // newForce.count = newForce.count * 10000;
                // newForce.initCount = newForce.initCount * 10000;
                // newForce.initHp();

                Force oldForce = first.forces[pos];
                first.forces[pos] = newForce;
                first.getRebornforces().put(pos, oldForce);
                // 如果是车轮战,玩家的站位KEY值有可能发生变化,需要重新计算
                newForce.key = oldForce != null ? oldForce.key : newForce.pos * 2 - 1;
                if (recordFlag) {
                    reborn.addPos(pos + 1);
                    reborn.addTankId(newForce.staticTank.getTankId());
                    reborn.addCount(newForce.count);
                    reborn.addHp(newForce.hp);

                    int state = 0;
                    if (newForce.fighter != null && newForce.fighter.awakenHeroSkill.containsKey(19) && newForce.fighter.awakenHeroSkill.get(19).equals("4")) {
                        state = 1;
                    }
                    reborn.addAwake(state);
                }

                // 加buff
                List<StaticBuff> buffs = first.forces[pos].staticTank.getBuffs();
                if (buffs == null) {
                    continue;
                }

                for (StaticBuff staticBuff : buffs) {
                    if (staticBuff.getType() == 1) {
                        first.addEffectAura(staticBuff);
                    } else {
                        second.addEffectAura(staticBuff);
                    }
                }
            }

            if (recordFlag) {
                recordData.addReborn(reborn);
            }
        }
        if (!secondAlive && second.getRebornforces().size() > 0 && !second.isReborn) {// 部队全灭
            second.isReborn = true;
            rebornState = 2;
            Set<Integer> posSet = new HashSet<>(second.getRebornforces().keySet());

            Reborn.Builder reborn = null;
            if (recordFlag) {
                reborn = Reborn.newBuilder();
                reborn.setRound(forceRound);
            }

            for (Integer pos : posSet) {
                // 部队替换
                Force newForce = second.getRebornforces().get(pos);
                Force oldForce = second.forces[pos];
                second.forces[pos] = newForce;
                second.getRebornforces().put(pos, oldForce);
                // 如果是车轮战,玩家的站位KEY值有可能发生变化,需要重新计算
                newForce.key = oldForce != null ? oldForce.key : newForce.pos * 2;
                if (recordFlag) {
                    reborn.addPos(pos + 6 + 1);
                    reborn.addTankId(newForce.staticTank.getTankId());
                    reborn.addCount(newForce.count);
                    reborn.addHp(newForce.hp);
                    int state = 0;
                    if (newForce.fighter != null && newForce.fighter.awakenHeroSkill.containsKey(19) && newForce.fighter.awakenHeroSkill.get(19).equals("4")) {
                        state = 1;
                    }
                    reborn.addAwake(state);
                }

                // 加buff
                List<StaticBuff> buffs = second.forces[pos].staticTank.getBuffs();
                if (buffs == null) {
                    continue;
                }

                for (StaticBuff staticBuff : buffs) {
                    if (staticBuff.getType() == 1) {
                        second.addEffectAura(staticBuff);
                    } else {
                        first.addEffectAura(staticBuff);
                    }
                }
            }

            if (recordFlag) {
                recordData.addReborn(reborn);
            }
        }
        return rebornState;
    }

    private void backRebornAura() {
        // 回合结束 备份复活数据复原
        if (first.isReborn) {// 部队复活还原
            for (Entry<Integer, Force> entry : first.getRebornforces().entrySet()) {
                first.forces[entry.getKey()] = entry.getValue();
                if (first.forces[entry.getKey()] != null) {
                    // 删掉所有光环buff
                    List<StaticBuff> buffs = first.forces[entry.getKey()].staticTank.getBuffs();
                    if (buffs == null) {
                        continue;
                    }

                    for (StaticBuff staticBuff : buffs) {
                        if (staticBuff.getType() == 1) {
                            first.delEffectAura(staticBuff);
                        } else {
                            second.delEffectAura(staticBuff);
                        }
                    }
                }
            }
        }
        if (second.isReborn) {// 部队复活还原
            for (Entry<Integer, Force> entry : second.getRebornforces().entrySet()) {
                second.forces[entry.getKey()] = entry.getValue();
                if (second.forces[entry.getKey()] != null) {
                    // 删掉所有光环buff
                    List<StaticBuff> buffs = second.forces[entry.getKey()].staticTank.getBuffs();
                    if (buffs == null) {
                        continue;
                    }

                    for (StaticBuff staticBuff : buffs) {
                        if (staticBuff.getType() == 1) {
                            second.delEffectAura(staticBuff);
                        } else {
                            first.delEffectAura(staticBuff);
                        }
                    }
                }
            }
        }
    }

    private void numberForce() {
        for (Force force : first.forces) {
            if (force != null) {
                force.key = force.pos * 2 - 1;
                forces[force.key - 1] = force;
            } else {

            }
        }

        for (Force force : second.forces) {
            if (force != null) {
                force.key = force.pos * 2;
                forces[force.key - 1] = force;
            } else {

            }
        }
    }

    /**
     * Method: round
     *
     * @return void
     * @Description: 一回合，双方坦克都act一次，算一回合
     */
    private void round() {
        int indexA = 0;
        int indexB = 0;
        for (int i = 0; i < 6; i++) {
            while (indexA < 6) {
                Force force = first.forces[indexA++];
                if (force != null && force.alive()) {
                    // 没有被穿刺并且没有被震慑
                    if (!force.dizzy && !force.frightenDizzy) {
                        if (act(force)) {
                            return;
                        }
                    } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                        force.frightenDizzy = false;
                        // 取消眩晕效果
                        if (recordFlag) {
                            roundData = CommonPb.Round.newBuilder();
                            roundData.setKey(force.key);
                            forceRound++;
                            recordData.addRound(roundData);
                        }
                    }
                    break;
                }
            }

            while (indexB < 6) {
                Force force = second.forces[indexB++];
                if (force != null && force.alive()) {
                    if (!force.dizzy && !force.frightenDizzy) {
                        if (act(force)) {
                            return;
                        }
                    } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                        force.frightenDizzy = false;
                        // 取消眩晕效果
                        if (recordFlag) {
                            roundData = CommonPb.Round.newBuilder();
                            roundData.setKey(force.key);
                            forceRound++;
                            recordData.addRound(roundData);
                        }
                    }
                    break;
                }
            }
        }
    }

    /**
     * 交换先后手玩家
     */
    private void roundB() {
        int indexA = 0;
        int indexB = 0;
        for (int i = 0; i < 6; i++) {
            while (indexB < 6) {
                Force force = second.forces[indexB++];
                if (force != null && force.alive()) {
                    if (!force.dizzy && !force.frightenDizzy) {
                        if (act(force)) {
                            return;
                        }
                    } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                        force.frightenDizzy = false;
                        // 取消眩晕效果
                        if (recordFlag) {
                            roundData = CommonPb.Round.newBuilder();
                            roundData.setKey(force.key);
                            forceRound++;
                            recordData.addRound(roundData);
                        }
                    }
                    break;
                }
            }

            while (indexA < 6) {
                Force force = first.forces[indexA++];
                if (force != null && force.alive()) {
                    if (!force.dizzy && !force.frightenDizzy) {
                        if (act(force)) {
                            return;
                        }
                    } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                        force.frightenDizzy = false;
                        // 取消眩晕效果
                        if (recordFlag) {
                            roundData = CommonPb.Round.newBuilder();
                            roundData.setKey(force.key);
                            forceRound++;
                            recordData.addRound(roundData);
                        }
                    }
                    break;
                }
            }
        }
    }

    private void bossRound() {
        int indexA = 0;
        int indexB = 0;

        while (indexA < 6) {
            Force force = first.forces[indexA++];
            if (force != null && force.alive()) {
                if (!force.dizzy && !force.frightenDizzy) {
                    if (act(force)) {
                        return;
                    }
                } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                    force.frightenDizzy = false;
                    // 取消眩晕效果
                    if (recordFlag) {
                        roundData = CommonPb.Round.newBuilder();
                        roundData.setKey(force.key);
                        forceRound++;
                        recordData.addRound(roundData);
                    }
                }
            }
        }

        while (indexB < 6) {
            Force force = second.forces[indexB++];
            if (force != null && force.alive()) {
                if (!force.dizzy && !force.frightenDizzy) {
                    if (act(force)) {
                        return;
                    }
                } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                    force.frightenDizzy = false;
                    // 取消眩晕效果
                    if (recordFlag) {
                        roundData = CommonPb.Round.newBuilder();
                        roundData.setKey(force.key);
                        forceRound++;
                        recordData.addRound(roundData);
                    }
                }
            }
        }
    }

    private void bossRoundB() {
        int indexA = 0;
        int indexB = 0;

        while (indexB < 6) {
            Force force = second.forces[indexB++];
            if (force != null && force.alive()) {
                if (!force.dizzy && !force.frightenDizzy) {
                    if (act(force)) {
                        return;
                    }
                } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                    force.frightenDizzy = false;
                    // 取消眩晕效果
                    if (recordFlag) {
                        roundData = CommonPb.Round.newBuilder();
                        roundData.setKey(force.key);
                        forceRound++;
                        recordData.addRound(roundData);
                    }
                }
            }
        }

        while (indexA < 6) {
            Force force = first.forces[indexA++];
            if (force != null && force.alive()) {
                if (!force.dizzy && !force.frightenDizzy) {
                    if (act(force)) {
                        return;
                    }
                } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                    force.frightenDizzy = false;
                    // 取消眩晕效果
                    if (recordFlag) {
                        roundData = CommonPb.Round.newBuilder();
                        roundData.setKey(force.key);
                        forceRound++;
                        recordData.addRound(roundData);
                    }
                }
            }
        }
    }

    /**
     * Method: round
     *
     * @return void
     * @Description: 一回合，双方坦克都act一次，算一回合
     */
    private void teamRound() {
        int indexA = 0;
        int indexB = 0;
        for (int i = 0; i < 6; i++) {
            while (indexA < 6) {
                Force force = first.forces[indexA++];
                if (force != null && force.alive()) {
                    // 没有被穿刺并且没有被震慑
                    if (!force.dizzy && !force.frightenDizzy) {
                        if (act(force)) {
                            break;
                        }
                    } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                        force.frightenDizzy = false;
                        // 取消眩晕效果
                        if (recordFlag) {
                            roundData = CommonPb.Round.newBuilder();
                            roundData.setKey(force.key);
                            forceRound++;
                            recordData.addRound(roundData);
                        }
                    }
                    break;
                }
            }

            while (indexB < 6) {
                Force force = second.forces[indexB++];

                if (force != null) {

                    if (force.alive()) {

                        if (force.staticTank.getAttackMode() > 0) {

                            if (!force.dizzy && !force.frightenDizzy) {

                                // 蓄力类型坦克
                                if (!force.isforce && force.type == 5) {

                                    // 蓄力回合满了 秒杀
                                    if (force.forceCount >= second.getStaticBountySkill().getParam().get(0).get(0)) {
                                        force.isforce = true;
                                        if (act(force)) {
                                            break;
                                        }
                                        force.forceCount = 0;
                                        force.isforce = false;
                                    } else {
                                        force.forceCount++;

                                        roundData = CommonPb.Round.newBuilder();
                                        roundData.setKey(force.key);

                                        CommonPb.Action.Builder builder = CommonPb.Action.newBuilder();
                                        builder.setTarget(force.key);
                                        builder.setForceCount(force.forceCount);
                                        roundData.addAction(builder.build());
                                        forceRound++;
                                        recordData.addRound(roundData);
                                    }

                                } else {

                                    if (act(force)) {
                                        break;
                                    }
                                }

                            } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态

                                force.frightenDizzy = false;
                                // 取消眩晕效果
                                if (recordFlag) {
                                    roundData = CommonPb.Round.newBuilder();
                                    roundData.setKey(force.key);
                                    forceRound++;
                                    recordData.addRound(roundData);
                                }
                            }

                            break;
                        }
                    } else {
                        // 自爆卡车
                        if (force.type == 6 && !force.isExplosion) {
                            force.isExplosion = true;
                            if (act(force)) {
                                break;
                            }
                        }
                    }

                }
            }
        }
    }

    /**
     * 交换先后手玩家
     */
    private void teamRoundB() {
        int indexA = 0;
        int indexB = 0;

        LogUtil.info("开始还手还手B");

        while (indexB < 6) {
            Force force = second.forces[indexB++];

            if (force != null) {

                if (force.alive()) {

                    if (force.staticTank.getAttackMode() > 0) {

                        if (!force.dizzy && !force.frightenDizzy) {

                            // 蓄力类型坦克
                            if (!force.isforce && force.type == 5) {

                                // 蓄力回合满了 秒杀
                                if (force.forceCount >= second.getStaticBountySkill().getParam().get(0).get(0)) {
                                    force.isforce = true;

                                    if (act(force)) {
                                        return;
                                    }
                                    force.forceCount = 0;
                                    force.isforce = false;

                                } else {
                                    force.forceCount++;

                                    // 取消眩晕效果
                                    if (recordFlag) {
                                        roundData = CommonPb.Round.newBuilder();
                                        roundData.setKey(force.key);

                                        CommonPb.Action.Builder builder = CommonPb.Action.newBuilder();
                                        builder.setTarget(force.key);
                                        builder.setForceCount(force.forceCount);
                                        roundData.addAction(builder.build());

                                        forceRound++;
                                        recordData.addRound(roundData);
                                    }
                                }

                            } else {

                                LogUtil.info("还手的人B " + JSON.toJSONString(force.pos));

                                if (act(force)) {
                                    return;
                                }

                            }

                        } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态

                            LogUtil.info("开始还手还 取消眩晕效果 B" + JSON.toJSONString(force.pos));

                            force.frightenDizzy = false;
                            // 取消眩晕效果
                            if (recordFlag) {
                                roundData = CommonPb.Round.newBuilder();
                                roundData.setKey(force.key);
                                forceRound++;
                                recordData.addRound(roundData);
                            }
                        }
                        break;
                    }

                    // 自爆卡车
                } else {
                    if (force.type == 6 && !force.isExplosion) {
                        force.isExplosion = true;
                        if (act(force)) {
                            return;
                        }
                    }

                }

            }

        }
        while (indexA < 6) {
            Force force = first.forces[indexA++];
            if (force != null && force.alive()) {
                if (!force.dizzy && !force.frightenDizzy) {
                    if (act(force)) {
                        return;
                    }
                } else if (force.frightenDizzy) { // 如果是震慑造成的眩晕，则下轮清除眩晕状态
                    force.frightenDizzy = false;
                    // 取消眩晕效果
                    if (recordFlag) {
                        roundData = CommonPb.Round.newBuilder();
                        roundData.setKey(force.key);
                        forceRound++;
                        recordData.addRound(roundData);
                    }
                }
                break;
            }
        }
    }

    /**
     * @param force
     * @return
     */
    private boolean act(Force force) {
        List<Force> targets = selectTarget(force);
        if (targets == null || targets.isEmpty()) {
            return true;
        }

        if (recordFlag) {
            roundData = CommonPb.Round.newBuilder();
            roundData.setKey(force.key);
            forceRound++;
        }

        if (force.removeSkillEffect(HeroConst.ID_SKILL_SMOKE)) {
            if (recordFlag) {
                recordData.addRound(roundData);
            }
            return false;
        }

        for (Force target : targets) {
            attack(force, target);
            if (recordFlag) {
                roundData.addAction(actionData);
            }
        }
        // 攻击完毕后，清空本次震慑造成的眩晕数
        force.cleanDizzyNum();

        if (recordFlag) {
            recordData.addRound(roundData);
        }

        return false;
    }

    /**
     * @param force
     * @param target
     */
    private void attack(Force force, Force target) {
        if (recordFlag) {
            actionData = CommonPb.Action.newBuilder();
            actionData.setTarget(target.key);
        }

        boolean isDodge = true;

        // 自爆卡车不能被闪避 不受闪避的坦克类型
        if (limit.contains(force.type) || limit.contains(target.type)) {
            isDodge = false;
        }

        if (FightCalc.isDodge(force, target) && isDodge) {
            if (recordFlag) {
                actionData.setDodge(true);
            }
            return;
        }

        float crit = 1;
        if (FightCalc.isCrit(force, target)) {
            if (recordFlag) {
                actionData.setCrit(true);
            }
            crit = 2;
            // 加入爆裂和坚韧后重新计算暴击率
            crit = FightCalc.calcCrit(force, target, crit);
        }

        // 穿刺
        if (!limit.contains(target.type)) {

            if (!target.isImmune) {
                if (FightCalc.isImpale(force, target)) {
                    target.dizzy = true;
                    if (recordFlag) {
                        actionData.setImpale(true);
                    }
                }
            }

        }

        // 没有被穿刺，也没有被震慑，才会有可能被震慑

        if (!limit.contains(target.type)) {
            if (!target.isImmune) {
                if (isFrighten && !target.dizzy && !target.frightenDizzy && FightCalc.isFrighten(force, target)) {
                    target.frightenDizzy = true;
                    force.frightenNum++;
                    if (recordFlag) {
                        actionData.setFrighten(true);
                    }
                }
            }
        }

        if (force.staticTank.getAttackMode() == 4) {
            long hurt = 0;
            for (int i = 0; i < 4; i++) {
                if (target.alive()) {
                    hurt = FightCalc.shakeValue(FightCalc.calcHurt(force, target, crit));

                    // 蓄力类型的直接把对方击杀掉
                    if (force.isforce || force.isDivisive || force.type == 6 || force.type == 7) {
                        hurt = target.hp;

                        if (force.isforce) {
                            force.force++;
                        }
                    }

                    if (!target.fighter.isAltarBoss || !target.god) {// 祭坛BOSS不扣血时不增加玩家伤害值

                        if (target.type == 5) {
                            if (hurt > target.hp) {
                                target.lcbHurt += target.hp;
                            } else {
                                target.lcbHurt += hurt;
                            }
                        }

                        target.hurt(hurt);
                        force.fighter.hurt += hurt;
                        if (recordFlag) {
                            actionData.addHurt(hurt);
                        }
                    }

                    divisiveFighter(target);

                }


            }
        } else {
            long hurt = FightCalc.shakeValue(FightCalc.calcHurt(force, target, crit));

            // 蓄力类型的直接把对方击杀掉
            if (force.isforce || force.isDivisive || force.type == 6 || force.type == 7) {
                hurt = target.hp;

                if (force.isforce) {
                    force.force++;
                }

            }

            if (target.type == 5) {

                if (hurt > target.hp) {
                    target.lcbHurt += target.hp;
                } else {
                    target.lcbHurt += hurt;
                }

            }

            if (!target.fighter.isAltarBoss || !target.god) {// 祭坛BOSS不扣血时不增加玩家伤害值
                target.hurt(hurt);
                force.fighter.hurt += hurt;
                if (recordFlag) {
                    actionData.addHurt(hurt);
                }
            }

            if (force.isforce && recordFlag) {
                actionData.setForce(true);
            }

            divisiveFighter(target);
        }

        if (recordFlag) {
            actionData.setCount(target.count);
        }

        target.removeSkillEffect(HeroConst.ID_SKILL_BARRIER);
    }

    /**
     * 分裂的
     *
     * @param target
     */
    private void divisiveFighter(Force target) {
        // 分裂的
        if (target.type == 7 && !target.alive()) {
            List<List<Integer>> param = target.fighter.getStaticBountySkill().getParam();
            __divisiveFighter(target.fighter, param, target.fighter.getStaticBountyEnemy().getAttr());

            if (recordFlag) {
                CommonPb.PassiveSkillEffect.Builder passiveSkillEffect = CommonPb.PassiveSkillEffect.newBuilder();
                passiveSkillEffect.setRound(forceRound);
                passiveSkillEffect.setKey(target.key);
                passiveSkillEffect.setId(target.fighter.getStaticBountySkill().getId());
                passiveSkillEffect.setEnemyId(target.fighter.getStaticBountyEnemy().getId());
                recordData.addPassiveSkillEffect(passiveSkillEffect);
            }
        }

    }

    /**
     * 自爆
     *
     * @param acter
     * @param forces
     */
    public List<Force> blastSelectFighter(Force acter, Force[] forces) {

        List<Force> result = new ArrayList<>();
        List<List<Integer>> param = acter.fighter.getStaticBountySkill().getParam();

        Map<Integer, Float> map = new HashMap<>();
        for (List<Integer> l : param) {
            map.put(l.get(0), l.get(1) * 1.0f);
        }
        Integer randomKey = LotteryUtil.getRandomKey(map);
        if (randomKey == null) {
            return result;
        }
        // Integer[] nums = new Integer[]{1,2,3,4,5,0};
        Integer[] nums = LotteryUtil.lotteryInt(6, randomKey);
        for (Integer index : nums) {
            Force force = forces[index];
            if (force != null && force.alive()) {
                result.add(force);
            }
        }

        if (result.size() == 0) {
            for (Force force : forces) {
                if (force != null && force.alive()) {
                    if (result.size() <= nums.length) {
                        result.add(force);
                    }

                }
            }
        }

        acter.zbCount = result.size();
        return result;

    }

    /**
     * 分裂
     *
     * @param fighter
     * @param param
     */
    public void __divisiveFighter(Fighter fighter, List<List<Integer>> param, List<List<Integer>> attr) {
        for (List<Integer> l : param) {
            int p = l.get(1);
            int count = l.get(2);
            StaticTank staticTank = GameServer.ac.getBean(StaticTankDataMgr.class).getStaticTank(p);
            AttrData attrData = new AttrData(staticTank);
            if (attr.get(l.get(3) - 1) != null && !attr.get(l.get(3) - 1).isEmpty()) {
                attrData.setAttr(attr.get(l.get(3) - 1));
            }
            Force force = new Force(staticTank, attrData, l.get(3), count);
            force.key = force.pos * 2;
            forces[force.key - 1] = force;

            force.initHp();
            // if (recordFlag) {
            // recordData.addHp(force.hp);
            // }

            force.isDivisive = true;
            fighter.addForce(force, l.get(3));
        }
    }

    /**
     * Method: horizantalTarget
     *
     * @param target
     * @return ArrayList<Force>
     * @Description: 横排目标
     */
    private List<Force> horizantalTarget(Fighter target) {
        ArrayList<Force> targets = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            Force force = target.forces[i];
            if (force != null && force.alive()) {
                targets.add(force);
            }
        }

        if (targets.isEmpty()) {
            for (int i = 3; i < 6; i++) {
                Force force = target.forces[i];
                if (force != null && force.alive()) {
                    targets.add(force);
                }
            }
        }
        return targets;
    }

    private void addColumnTarget(Force[] targets, ArrayList<Force> list, int column) {
        Force force = targets[column - 1];
        if (force != null && force.alive()) {
            list.add(force);
        }

        // if (!list.isEmpty()) {
        // return;
        // }

        force = targets[column + 2];
        if (force != null && force.alive()) {
            list.add(force);
        }

        // LogUtil.info("addColumnTarget list:" + list.size() + " column:"
        // + column);
        // printForce(targets);
    }

    protected void printForce(Force[] targets) {
        for (int i = 0; i < targets.length; i++) {
            Force force = targets[i];
            if (force != null) {
                LogUtil.info("force " + i + "|tankid:" + force.staticTank.getTankId() + "|key:" + force.key + "|pos:" + force.pos
                        + "|count:" + force.count);
            } else {
                LogUtil.info("force " + i);
            }
        }
    }

    /**
     * Method: verticalTarget
     *
     * @param target
     * @param pos
     * @return ArrayList<Force>
     * @Description: 竖排目标
     */
    private List<Force> verticalTarget(Fighter target, int pos) {
        // LogUtil.info("verticalTarget pos:" + pos);
        ArrayList<Force> targets = new ArrayList<>();
        int column = (pos - 1) % 3 + 1;
        int[] order = new int[3];
        if (column == 1) {
            order[0] = 1;
            order[1] = 2;
            order[2] = 3;
        } else if (column == 2) {
            order[0] = 2;
            order[1] = 1;
            order[2] = 3;
        } else {
            order[0] = 3;
            order[1] = 2;
            order[2] = 1;
        }

        for (int i : order) {
            addColumnTarget(target.forces, targets, i);
            if (!targets.isEmpty()) {
                break;
            }
        }
        return targets;
    }

    /**
     * Method: allTarget
     *
     * @param target
     * @return ArrayList<Force>
     * @Description: 全体目标
     */
    private List<Force> allTarget(Fighter target) {
        ArrayList<Force> targets = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            Force force = target.forces[i];
            if (force != null && force.alive()) {
                targets.add(force);
            }
        }

        return targets;
    }

    /**
     * Method: oneTarget
     *
     * @param target
     * @return ArrayList<Force>
     * @Description: 单体
     */
    private List<Force> oneTarget(Fighter target, int pos) {
        List<Force> targets = new ArrayList<>();
        List<Force> fromVertical = verticalTarget(target, pos);
        if (!fromVertical.isEmpty()) {
            targets.add(fromVertical.get(0));
        }

        return targets;
    }

    private List<Force> selectTarget(Force acter) {

        // 蓄力坦克
        if (acter.isforce) {
            return allTarget(acter.fighter.oppoFighter);
        }

        // 自爆卡车
        if (acter.type == 6) {
            return blastSelectFighter(acter, acter.fighter.oppoFighter.forces);
        }

        switch (acter.staticTank.getAttackMode()) {// 1.横排 2.竖排 3.全体 4.单体五连击
            case 1:
                return horizantalTarget(acter.fighter.oppoFighter);
            case 2:
                return verticalTarget(acter.fighter.oppoFighter, acter.pos);
            case 3:
                return allTarget(acter.fighter.oppoFighter);
            case 4:
                return oneTarget(acter.fighter.oppoFighter, acter.pos);
            default:
                break;
        }
        return null;
    }

    public int getWinState() {
        return winState;
    }

    public void setWinState(int winState) {
        this.winState = winState;
    }

    public void onForceDie(Force force) {
        arrangeAura(force);
        if (force.fighter.boss) {
            force.fighter.changeGod();
        }
    }

    private void addSkillEffectSmoke(Fighter fighter, String val) {
        List<Force> hasTankPos = new ArrayList<>();
        for (Force force : fighter.forces) {
            if (force != null && force.alive() && !force.dizzy) {
                hasTankPos.add(force);
            }
        }
        int num = 0;
        if (hasTankPos.size() == 0) {
            return;
        }
        // 部队数量
        if (hasTankPos.size() == 1) {
            num = 1;
        } else {
            JSONArray arr = JSONArray.parseArray(val);
            List<List<Integer>> weight = new ArrayList<>();
            for (int i = 0; i < arr.size(); i++) {
                JSONArray a = arr.getJSONArray(i);
                List<Integer> wArr = new ArrayList<>();
                wArr.add(a.getInteger(0));
                wArr.add(a.getInteger(1));
                weight.add(wArr);
            }
            // 能数量
            int canNum = hasTankPos.size();
            if (canNum > weight.size()) {
                canNum = weight.size();
            }
            // 概率数量
            int seeds[] = {0, 0};
            for (int i = 0; i < canNum; i++) {
                seeds[0] += weight.get(i).get(1);
            }
            seeds[0] = RandomHelper.randomInSize(seeds[0]);
            for (int i = 0; i < canNum; i++) {
                List<Integer> w = weight.get(i);
                seeds[1] += w.get(1);
                if (seeds[0] <= seeds[1]) {
                    num = w.get(0);
                    break;
                }
            }
        }
        Random rand = new Random();
        for (int i = 0; i < num; i++) {
            // 触发位置0,1,2,3,4,5不会重复
            Force force = hasTankPos.remove(rand.nextInt(hasTankPos.size()));
            if (force.isImmune) {
                addAddSkillEffect(force.key, HeroConst.ID_SKILL_SMOKE, 1);
            } else {
                force.skillEffect.put(HeroConst.ID_SKILL_SMOKE, "");
                addAddSkillEffect(force.key, HeroConst.ID_SKILL_SMOKE);
            }

        }
    }

    private void addSkillEffectBarrier(Fighter fighter, int reduceHurt) {
        for (Force force : fighter.forces) {
            if (force != null && force.alive() && !force.dizzy && !force.skillEffect.containsKey(HeroConst.ID_SKILL_BARRIER)) {
                force.skillEffect.put(HeroConst.ID_SKILL_BARRIER, reduceHurt);
                addAddSkillEffect(force.key, HeroConst.ID_SKILL_BARRIER);
            }
        }
    }

    private void addSkillEffectAttr20(Fighter fighter) {

        if (fighter.isAnxin) {
            return;
        }

        fighter.isAnxin = true;

        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive()) {
                addAddSkillEffect(f.key, HeroConst.ID_SKILL_20);
            }
        }

    }

    private void cancelSkillEffectAttr20(Fighter fighter) {
        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive() && !f.heroAttr.isEmpty()) {
                f.clearHeroAttr();
                addAddSkillEffect(f.key, -HeroConst.ID_SKILL_20);
            }
        }
        fighter.awakenHeroSkill.remove(HeroConst.ID_SKILL_20);

    }

    private void addSkillEffectAttr(Fighter fighter) {

        if (fighter.isAnxin) {
            return;
        }

        fighter.isAnxin = true;

        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive() && !f.getHeroAttr().isEmpty()) {
                addAddSkillEffect(f.key, HeroConst.ID_SKILL_16);
            }
        }

    }

    private void addSkillEffectFhBuff(Fighter fighter) {

        if (fighter.isAnxin) {
            return;
        }

        fighter.isAnxin = true;

        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive()) {
                addAddSkillEffect(f.key, HeroConst.ID_SKILL_19);
            }
        }
    }

    private void addSkillEffectImmune(Fighter fighter) {

        if (fighter.isAnxin) {
            return;
        }
        fighter.isAnxin = true;

        StaticHeroDataMgr staticHeroDataMgr = GameServer.ac.getBean(StaticHeroDataMgr.class);
        StaticHeroAwakenSkill config = staticHeroDataMgr.getHeroAwakenSkillById(fighter.immuneId);

        String effectVal = config.getEffectVal();

        Map<Integer, Float> mapRate = new HashMap<>();
        if (effectVal != null) {
            JSONArray jsonArray = JSONArray.parseArray(effectVal);
            for (Object str : jsonArray) {
                JSONArray j = JSONArray.parseArray(str.toString());
                mapRate.put(j.getInteger(0), j.getFloat(1));
            }

        }

        if (mapRate.isEmpty()) {
            return;
        }

        Integer count = LotteryUtil.getRandomKey(mapRate);
        Integer[] nums = LotteryUtil.lotteryInt(6, count);
        int size = 0;
        for (Integer index : nums) {
            Force force = fighter.forces[index];
            if (force != null && force.alive()) {
                force.isImmune = true;
                size++;

                addAddSkillEffect(force.key, HeroConst.ID_SKILL_18);
            }
        }

        if (size == 0) {
            for (Force force : fighter.forces) {
                if (force != null && force.alive()) {
                    force.isImmune = true;
                    addAddSkillEffect(force.key, HeroConst.ID_SKILL_18);
                }
            }
        }

    }

    private void cancelSkillEffectImmune(Fighter fighter) {
        for (Force force : fighter.forces) {
            if (force != null && force.alive() && force.isImmune) {
                force.isImmune = false;
                addAddSkillEffect(force.key, -HeroConst.ID_SKILL_18);
            }
        }

        fighter.awakenHeroSkill.remove(HeroConst.ID_SKILL_18);

    }

    private void cancelSkillEffectAttr(Fighter fighter) {
        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive() && !f.getHeroAttr().isEmpty()) {
                f.clearHeroAttr();
                addAddSkillEffect(f.key, -HeroConst.ID_SKILL_16);
            }
        }

        fighter.awakenHeroSkill.remove(HeroConst.ID_SKILL_16);

    }

    private void addSkillEffectSubHurt(Fighter fighter) {

        if (fighter.isAnxin) {
            return;
        }

        fighter.isAnxin = true;

        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive() && !f.getHeroAttr().isEmpty()) {
                addAddSkillEffect(f.key, HeroConst.ID_SKILL_17);
            }
        }

    }

    private void cancelSkillEffectSubHurt(Fighter fighter) {
        Force[] forces = fighter.forces;
        for (Force f : forces) {
            if (f != null && f.alive() && !f.getHeroAttr().isEmpty()) {
                f.clearHeroAttr();
                addAddSkillEffect(f.key, -HeroConst.ID_SKILL_17);
            }
        }
        fighter.awakenHeroSkill.remove(HeroConst.ID_SKILL_17);

    }

    /**
     * 解析增伤值存入每个force的技能表
     */
    private void addSkillEffectAddDemageF(Fighter fighter, String demageF) {
        if (demageF == null || demageF.length() == 0) {
            return;
        }

        // 格式错误则返回
        JSONArray arr = JSONArray.parseArray(demageF);
        if (arr == null || arr.isEmpty()) {
            return;
        }
        JSONArray array = arr.getJSONArray(0);
        if (array == null || array.size() != 2) {
            return;
        }

        int df = array.getInteger(0);// 首回合时增伤值
        int sub = array.getInteger(1);// 每回合时减少的增伤值
        for (Force force : fighter.forces) {
            if (force != null && force.alive() && !force.skillEffect.containsKey(HeroConst.ID_SKILL_11)) {
                List<Integer> list = new ArrayList<>(2);
                list.add(df);
                list.add(sub);
                force.skillEffect.put(HeroConst.ID_SKILL_11, list);
                addAddSkillEffect(force.key, HeroConst.ID_SKILL_11);
            }
        }
    }

    private void addAddSkillEffect(int forceKey, int id) {
        if (recordFlag) {
            CommonPb.SkillEffect.Builder skillEffect = CommonPb.SkillEffect.newBuilder();
            skillEffect.setRound(forceRound + 1);
            skillEffect.setKey(forceKey);
            skillEffect.setId(id);
            recordData.addAddSkillEffect(skillEffect);
        }
    }

    private void addAddSkillEffect(int forceKey, int id, int state) {
        if (recordFlag) {
            CommonPb.SkillEffect.Builder skillEffect = CommonPb.SkillEffect.newBuilder();
            skillEffect.setRound(forceRound + 1);
            skillEffect.setKey(forceKey);
            skillEffect.setId(id);
            skillEffect.setState(state);
            recordData.addAddSkillEffect(skillEffect);
        }
    }

    /**
     * 不受闪避 烟幕的坦克类型 震慑 眩晕
     */
    private static List<Integer> limit = new ArrayList<>();

    static {
        limit.add(5);
        limit.add(6);
        limit.add(7);
        limit.add(8);
    }
}
