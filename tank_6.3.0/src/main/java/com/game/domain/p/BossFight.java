/**
 * @Title: BossFight.java
 * @Package com.game.domain.p
 * @Description:
 * @author ZhangJun
 * @date 2015年12月29日 下午3:08:41
 * @version V1.0
 */
package com.game.domain.p;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

/**
 * @ClassName: BossFight
 * @Description: 玩家打boss信息
 * @author ZhangJun
 * @date 2015年12月29日 下午3:08:41
 *
 */
@SaveOptimize(level = SaveLevel.IDLE)
public class BossFight implements Cloneable {
    private long lordId;
    private int bossType;// BOSS类型，1 世界BOSS，2 祭坛BOSS
    private long hurt;// 玩家伤害量
    private int bless1;// 祝福等级
    private int bless2;
    private int bless3;
    private int autoFight;// VIP自动战斗
    private int attackTime;

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getBossType() {
        return bossType;
    }

    public void setBossType(int bossType) {
        this.bossType = bossType;
    }

    public long getHurt() {
        return hurt;
    }

    public void setHurt(long hurt) {
        this.hurt = hurt;
    }

    public int getBless1() {
        return bless1;
    }

    public void setBless1(int bless1) {
        this.bless1 = bless1;
    }

    public int getBless2() {
        return bless2;
    }

    public void setBless2(int bless2) {
        this.bless2 = bless2;
    }

    public int getBless3() {
        return bless3;
    }

    public void setBless3(int bless3) {
        this.bless3 = bless3;
    }

    @Override
    public Object clone() {
        try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            //Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public int getAttackTime() {
        return attackTime;
    }

    public void setAttackTime(int attackTime) {
        this.attackTime = attackTime;
    }

    public int getAutoFight() {
        return autoFight;
    }

    public void setAutoFight(int autoFight) {
        this.autoFight = autoFight;
    }

    @Override
    public String toString() {
        return "BossFight [lordId=" + lordId + ", bossType=" + bossType + ", hurt=" + hurt + ", bless1=" + bless1
                + ", bless2=" + bless2 + ", bless3=" + bless3 + ", autoFight=" + autoFight + ", attackTime="
                + attackTime + "]";
    }
}
