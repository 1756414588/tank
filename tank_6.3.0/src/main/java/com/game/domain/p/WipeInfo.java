package com.game.domain.p;

import com.game.pb.CommonPb;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/2/15 10:13
 * @description：扫荡信息
 */
public class WipeInfo {
    /**
     * 副本类型
     */
    private int exploreType;
    /**
     * 设置的扫荡关卡id
     */

    private int combatId;
    /**
     * 设置的购买次数
     */
    private int buyCount;

    public WipeInfo() {

    }

    public WipeInfo(CommonPb.WipeInfo winfo) {
        this.exploreType = winfo.getExploreType();
        this.combatId = winfo.getCombatId();
        this.buyCount = winfo.getBuyCount();
    }

    public int getExploreType() {
        return exploreType;
    }

    public void setExploreType(int exploreType) {
        this.exploreType = exploreType;
    }

    public int getCombatId() {
        return combatId;
    }

    public void setCombatId(int combatId) {
        this.combatId = combatId;
    }

    public int getBuyCount() {
        return buyCount;
    }

    public void setBuyCount(int buyCount) {
        this.buyCount = buyCount;
    }
}
