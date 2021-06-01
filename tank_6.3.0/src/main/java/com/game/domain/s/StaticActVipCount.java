package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActVipCount
 * @Description: 大咖带队
 * @date 2018-01-17 17:10
 */
public class StaticActVipCount {
    //唯一ID
    private int id;
    //活动ID
    private int activityId;
    //VIP等级
    private int vip;
    //系统自增间隔
    private int incSec;
    //系统自增数量
    private int incCnt;
    //未完成时需要广播的数量
    private List<Integer> notFinishCnt;
    //广播ID
    private int notFinishChatId;
    //完成时广播ID
    private int finishChatId;

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

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getIncSec() {
        return incSec;
    }

    public void setIncSec(int incSec) {
        this.incSec = incSec;
    }

    public int getIncCnt() {
        return incCnt;
    }

    public void setIncCnt(int incCnt) {
        this.incCnt = incCnt;
    }

    public List<Integer> getNotFinishCnt() {
        return notFinishCnt;
    }

    public void setNotFinishCnt(List<Integer> notFinishCnt) {
        this.notFinishCnt = notFinishCnt;
    }

    public int getNotFinishChatId() {
        return notFinishChatId;
    }

    public void setNotFinishChatId(int notFinishChatId) {
        this.notFinishChatId = notFinishChatId;
    }

    public int getFinishChatId() {
        return finishChatId;
    }

    public void setFinishChatId(int finishChatId) {
        this.finishChatId = finishChatId;
    }
}
