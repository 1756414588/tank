package com.game.domain.l;

import com.game.pb.SerializePb;

/**
 * @author zhangdh
 * @ClassName: PartyJobFree
 * @Description:军团职能免费使用记录
 * @date 2017-06-22 4:10
 */
public class PartyJobFree {
    private int job;//军团职位
    private int free;//今日免费使用次数
    private int freeDay;//最后免费使用时间

    public PartyJobFree(){}

    public PartyJobFree(SerializePb.SerPartyJobFree pbJobFree){
        this.job = pbJobFree.getJob();
        this.free = pbJobFree.getFree();
        this.freeDay = pbJobFree.getFreeDay();
    }

    public int getJob() {
        return job;
    }

    public void setJob(int job) {
        this.job = job;
    }

    public int getFree() {
        return free;
    }

    public void setFree(int free) {
        this.free = free;
    }

    public int getFreeDay() {
        return freeDay;
    }

    public void setFreeDay(int freeDay) {
        this.freeDay = freeDay;
    }
}
