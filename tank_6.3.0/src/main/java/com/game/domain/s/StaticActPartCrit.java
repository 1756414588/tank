package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActPartCrit
 * @Description: 淬炼暴击
 * @date 2017-05-22 17:10
 */
public class StaticActPartCrit {
    private int id;//唯一ID
    private int activityId;//活动ID
    private int mode;//淬炼方式（1为普通，2为专家，3为大师）
    //单次淬炼暴击率[[倍数,概率], [倍数,概率], [倍数,概率]…, [倍数,概率]]
    private List<List<Integer>> crit;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getActivityId() {
        return activityId;
    }

    public void setActivityId(int activityId) {
        this.activityId = activityId;
    }

    public int getMode() {
        return mode;
    }

    public void setMode(int mode) {
        this.mode = mode;
    }

    public List<List<Integer>> getCrit() {
        return crit;
    }

    public void setCrit(List<List<Integer>> crit) {
        this.crit = crit;
    }
}
