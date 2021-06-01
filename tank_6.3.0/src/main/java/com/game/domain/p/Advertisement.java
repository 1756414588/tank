package com.game.domain.p;

import java.util.Date;

/**
 * @author LiuYiFan
 * @ClassName: AD
 * @Description: 广告奖励
 * @date 2017年5月24日17:00:54
 */
public class Advertisement {
    private long lordId;// 关联角色id
    private int buffCount;// 观看了几次编制buff广告
    private int firstPay;// 观看了几次首冲广告
    private Date lastFirstPayADTime;// 最后观看首冲广告的时间
    private int firstPayCount;// 连续观看了几天首冲广告
    private int firstPayStatus;// 首冲状态1可领取0不可领取
    private int lvUpStatus;// 秒升一级1可使用0不可使用
    private Date lvUpLastTime;// 最后观看秒升一级的时间
    private int loginStatus;// 登陆广告状态1可领取0不可领取
    private Date lastLoginTime;// 最后一次领取登陆广告时间
    private Date lastBuffTime;// 最后一次加编制buff的时间
    private int buffCount2;// 观看了几次编制buff广告
    private Date lastBuff2Time;// 最后一次加编制buff的时间
    private int powerCount;// 体力广告次数
    private Date powerTime;// 体力广告最后时间
    private int commondCount;// 统率书广告次数
    private Date commondTime;// 统率书广告最后时间

    public int getPowerCount() {
        return powerCount;
    }

    public void setPowerCount(int powerCount) {
        this.powerCount = powerCount;
    }

    public Date getPowerTime() {
        return powerTime;
    }

    public void setPowerTime(Date powerTime) {
        this.powerTime = powerTime;
    }

    public int getCommondCount() {
        return commondCount;
    }

    public void setCommondCount(int commondCount) {
        this.commondCount = commondCount;
    }

    public Date getCommondTime() {
        return commondTime;
    }

    public void setCommondTime(Date commondTime) {
        this.commondTime = commondTime;
    }

    public int getBuffCount2() {
        return buffCount2;
    }

    public void setBuffCount2(int buffCount2) {
        this.buffCount2 = buffCount2;
    }

    public Date getLastBuff2Time() {
        return lastBuff2Time;
    }

    public void setLastBuff2Time(Date lastBuff2Time) {
        this.lastBuff2Time = lastBuff2Time;
    }

    public Date getLastBuffTime() {
        return lastBuffTime;
    }

    public void setLastBuffTime(Date lastBuffTime) {
        this.lastBuffTime = lastBuffTime;
    }

    public Date getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(Date lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    public int getLoginStatus() {
        return loginStatus;
    }

    public void setLoginStatus(int loginStatus) {
        this.loginStatus = loginStatus;
    }

    public Date getLvUpLastTime() {
        return lvUpLastTime;
    }

    public void setLvUpLastTime(Date lvUpLastTime) {
        this.lvUpLastTime = lvUpLastTime;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getBuffCount() {
        return buffCount;
    }

    public void setBuffCount(int buffCount) {
        this.buffCount = buffCount;
    }

    public int getFirstPay() {
        return firstPay;
    }

    public void setFirstPay(int firstPay) {
        this.firstPay = firstPay;
    }

    public Date getLastFirstPayADTime() {
        return lastFirstPayADTime;
    }

    public void setLastFirstPayADTime(Date lastFirstPayADTime) {
        this.lastFirstPayADTime = lastFirstPayADTime;
    }

    public int getFirstPayCount() {
        return firstPayCount;
    }

    public void setFirstPayCount(int firstPayCount) {
        this.firstPayCount = firstPayCount;
    }

    public int getFirstPayStatus() {
        return firstPayStatus;
    }

    public void setFirstPayStatus(int firstPayStatus) {
        this.firstPayStatus = firstPayStatus;
    }

    public int getLvUpStatus() {
        return lvUpStatus;
    }

    public void setLvUpStatus(int lvUpStatus) {
        this.lvUpStatus = lvUpStatus;
    }

}
