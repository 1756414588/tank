/**
 * @Title: FightCalc.java @Package com.game.fight @Description: TODO
 * @author ZhangJun
 * @date 2015年8月29日 下午12:48:59
 * @version V1.0
 */
package com.game.fight;

import com.alibaba.fastjson.JSON;
import com.game.constant.TankType;
import com.game.fight.domain.AttrData;
import com.game.fight.domain.Force;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;

/**
 * @author ZhangJun @ClassName: FightCalc @Description: TODO
 * @date 2015年8月29日 下午12:48:59
 */
public class FightCalc {
    private static final float[] COUNT_RATIO = {
            0, 0.1f, 0.3f, 0.5f, 0.65f, 0.7f, 0.8f, 0.85f, 0.9f, 0.95f, 1.0f, 1.05f, 1.1f, 1.15f, 1.2f,
            1.25f, 1.4f, 1.6f, 2.0f, 5.0f, 10.0f
    };

    // final static private float[] COUNT_RATIO_FACTOR = { 0.25f, 0.3f, 0.4f,
    // 0.5f, 0.65f, 0.7f, 0.75f, 0.8f, 0.85f, 0.9f, 1.0f, 1.1f, 1.2f, 1.3f,
    // 1.4f, 1.5f,
    // 1.7f, 2f, 2.5f, 3.0f, 4.0f };
    //
    // final static private float[] IMPALE_SUB_FACTOR = { 0.8f, 0.5f, 0.3f,
    // 0.2f, 0.1f };

    private static final int[] IMPALE_SUB = {100 * 100, 200 * 100, 300 * 100, 500 * 100, 999999999};

    private static final float[] COUNT_RATIO_FACTOR = {
            0.25f, 0.3f, 0.4f, 0.5f, 0.65f, 0.7f, 0.75f, 0.8f, 0.85f, 0.9f, 1.0f, 1.1f, 1.1f, 1.1f, 1.2f,
            1.3f, 1.4f, 1.5f, 1.7f, 2.0f, 2.5f
    };

    private static final float[] IMPALE_SUB_FACTOR = {0.25f, 0.2f, 0.15f, 0.1f, 0.05f};

    public static final double BASE = 10000.0;

    // 震慑造成眩晕的概率，根据之前已经造成眩晕时的force个数来降低概率发生
    public static final int[] DIZZY_FACTOR = {8000, 6000, 4000, 2000, 1000};

    public static boolean isDodge(Force force, Force target) {
        if (target.fighter.boss || force.fighter.boss) {
            return false;
        }

        int dodge = target.calcDodge();
        int hit = force.calcHit();
        int prob = (int) ((dodge - hit) / 1.2f);
        if (prob < 20) {
            prob = 20;
        } else if (prob > 800) {
            prob = 800;
        }

        return RandomHelper.isHitRangeIn1000(prob);
    }

    public static boolean isCrit(Force force, Force target) {
        if (force.fighter.boss) {
            return false;
        }

        int crit = force.calcCrit();
        int critDef = target.calcCritDef();
        int prob = (int) ((crit - critDef) / 1.2f);
        if (prob < 80) {
            prob = 80;
        } else if (prob > 900) {
            prob = 900;
        }

        return RandomHelper.isHitRangeIn1000(prob);
    }

    public static boolean isImpale(Force force, Force target) {
        if (target.fighter.boss || force.fighter.boss) {
            return false;
        }
        float countRatio = force.count / (float) target.count;
        // countRatio  = 攻击方坦克数据/防御方坦克数量

        float countFactor = 0;
        for (int i = 0; i < COUNT_RATIO.length; i++) {
            if (countRatio > COUNT_RATIO[i]) {
                countFactor = COUNT_RATIO_FACTOR[i];
            } else {
                break;
            }
        }

        // 穿刺 减去 穿刺防护
        int impaleSub = force.calcImpale() - target.calcDefend();

        float impaleFactor = 0;

        // 如果大于0才走这些
        if (impaleSub > 0) {
            int temp = impaleSub;
            for (int i = 0; i < IMPALE_SUB.length; i++) { // 每一档遍历
                if (impaleSub > IMPALE_SUB[i]) {
                    temp -= IMPALE_SUB[i];
                    impaleFactor += IMPALE_SUB[i] * IMPALE_SUB_FACTOR[i];
                } else {
                    impaleFactor += temp * IMPALE_SUB_FACTOR[i];
                    break;
                }
            }
        }
        // 坦克配置表字段
        int imf1 = force.staticTank.getImpaleFactor();
        int imf2 = target.staticTank.getImpaleFactor();
        imf1 = (imf1 != 0 ? imf1 : 1);
        imf2 = (imf2 != 0 ? imf2 : 1);
        int prob = (int) (countFactor * impaleFactor * imf1 / imf2);
        if (prob > 80000) {
            prob = 80000;
        }
        prob = shakeValue(prob);
        boolean hitRangeIn100000 = RandomHelper.isHitRangeIn100000(prob);
        if (prob == 1 && hitRangeIn100000) {
            LogUtil.error("is impale穿刺:-----穿刺了------");
            LogUtil.error(
                    "is impale穿刺:force"
                            + force.count
                            + "| "
                            + target.count
                            + "| "
                            + JSON.toJSONString(force.attrData)
                            + "|\n target"
                            + JSON.toJSONString(target.attrData));
        }
        return hitRangeIn100000;
    }

    public static long calcHurt(Force force, Force target, float crit) {
        AttrData attackData = force.attrData;
        AttrData defendData = target.attrData;

        Integer restriction = force.staticTank.getRestriction().get(target.staticTank.getSubType());
        if (restriction == null) {
            restriction = 0;
        }

        int impaleSub = (force.calcImpale() - target.calcDefend()) / 1000;
        int frightenSub = (force.calcFrighten() - target.calcFortitude()) / 1000;

        // 风行者增伤
        int addDemageF = force.getDemageF();

        // 调整伤害加成下限为0.2，上限不变
        double addtionValue =
                ((BASE
                        + attackData.attackF
                        + force.fighter.auraData[force.type - 1].attackF
                        + attackData.demageF
                        + addDemageF
                        - defendData.injuredF
                        - target.fighter.auraData[target.type - 1].injuredF
                        + impaleSub * 80
                        + frightenSub * 80)
                        / BASE);
        addtionValue = addtionValue < 0.2 ? 0.2 : addtionValue;

        long hurt =
                (long)
                        ((attackData.attack * addtionValue * force.count * crit)
                                * (1 + (restriction / 100.0f)));

        // 若是战车的话，伤害削减40%
        if (force.type == TankType.Chariot) {
            hurt *= 0.4;
        }

        // 觉醒将领 幽影特工开启幽能屏障，降低首回合受到伤害。
        int targetReduceHurt = target.getSkillEffectBarrier();
        if (targetReduceHurt > 0) {
            hurt *= 1 - (targetReduceHurt / 10000.0f);
        }

        // 减伤护罩（全体，持续回合）
        if (target.subHurtB > 0) {
            hurt *= (1 - target.subHurtB);
        }
        // 被动加减伤百分比
        if (target.subHurtB2 > 0) {
            hurt *= (1 - target.subHurtB2);
        }

        if (hurt < 1) {
            hurt = 1;
        }

        return hurt;
    }

    public static int calcAlive(Force target) {
        return (int) Math.ceil(target.hp / (double) target.maxHp);
    }

    public static int shakeValue(int value) {
        int shake = (int) (value * 0.04);
        if (shake != 0) {
            shake = RandomHelper.randomInSize(shake);
        }
        int v = (int) (shake + value * 0.98);
        if (v < 1) {
            v = 1;
        }
        return v;
    }

    public static long shakeValue(long value) {
        long shake = (long) (value * 0.04);
        if (shake != 0) {
            shake = RandomHelper.randomInSize(shake);
        }

        long v = (long) (shake + value * 0.98);
        if (v < 1) {
            v = 1;
        }
        return v;
    }

    /**
     * Method: calcCrit
     *
     * @param force
     * @param target
     * @param crit
     * @return float
     * @throws @Description: 计算爆裂和坚韧后的暴击比
     */
    public static float calcCrit(Force force, Force target, float crit) {
        AttrData attackData = force.attrData;
        AttrData defendData = target.attrData;
        int differ = attackData.burstF - defendData.tenacityF;
        if (differ < -5000) {
            differ = -5000;
        } else if (differ > 20000) {
            differ = 20000;
        }
        return (crit * 10000 + differ) / 10000;
    }

    /**
     * 震慑是否触发眩晕效果，逻辑跟是否穿刺一样
     *
     * @param force
     * @param target
     * @return
     */
    public static boolean isFrighten(Force force, Force target) {
        if (target.fighter.boss || force.fighter.boss) {
            return false;
        }

        float countRatio = force.count / (float) target.count;
        float countFactor = 0;
        for (int i = 0; i < COUNT_RATIO.length; i++) {
            if (countRatio > COUNT_RATIO[i]) {
                countFactor = COUNT_RATIO_FACTOR[i];
            } else {
                break;
            }
        }

        int frightenSub = force.calcFrighten() - target.calcFortitude();

        float frightenFactor = 0;

        if (frightenSub > 0) {
            int temp = frightenSub;
            for (int i = 0; i < IMPALE_SUB.length; i++) { // 每一档遍历
                if (frightenSub > IMPALE_SUB[i]) {
                    temp -= IMPALE_SUB[i];
                    frightenFactor += IMPALE_SUB[i] * IMPALE_SUB_FACTOR[i];
                } else {
                    frightenFactor += temp * IMPALE_SUB_FACTOR[i];
                    break;
                }
            }
        }

        int frighten1 = force.staticTank.getImpaleFactor();
        int frighten2 = target.staticTank.getImpaleFactor();
        frighten1 = (frighten1 != 0 ? frighten1 : 1);
        frighten2 = (frighten2 != 0 ? frighten2 : 1);
        int prob = (int) (countFactor * frightenFactor * frighten1 / frighten2);
        if (prob > 80000) {
            prob = 80000;
        }

        prob = shakeValue(prob);

        // 如果前面已经有造成眩晕的部队，则降低本次造成眩晕的概率
        if (force.frightenNum > 0) {
            prob *= (int) (DIZZY_FACTOR[force.frightenNum - 1] / BASE);
        }

        return RandomHelper.isHitRangeIn100000(prob);
    }
}
