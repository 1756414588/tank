/**
 * @Title: StaticStaffingWolrd.java
 * @Package com.game.domain.s
 * @Description:
 * @author ZhangJun
 * @date 2016年3月11日 下午5:13:36
 * @version V1.0
 */
package com.game.domain.s;

/**
 * @ClassName: StaticStaffingWolrd
 * @Description: 世界编制等级
 * @author ZhangJun
 * @date 2016年3月11日 下午5:13:36
 *
 */
public class StaticStaffingWorld {
    private int worldLv;
    private int sumStaffing;
    private int haust;
    private int limit;

    public int getSumStaffing() {
        return sumStaffing;
    }

    public void setSumStaffing(int sumStaffing) {
        this.sumStaffing = sumStaffing;
    }

    public int getHaust() {
        return haust;
    }

    public void setHaust(int haust) {
        this.haust = haust;
    }

    public int getWorldLv() {
        return worldLv;
    }

    public void setWorldLv(int worldLv) {
        this.worldLv = worldLv;
    }

    public int getLimit() {
        return limit;
    }

    public void setLimit(int limit) {
        this.limit = limit;
    }
}
