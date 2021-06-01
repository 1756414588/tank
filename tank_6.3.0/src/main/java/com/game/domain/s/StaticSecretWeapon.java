package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticSecretWeapon
 * @Description: 秘密武器配置
 * @date 2017-11-13 18:55
 */
public class StaticSecretWeapon {
    private int id;
    private int openId;
    private int sknIni;
    private int sknMax;
    private List<Integer> unlockCost;//解锁技能栏费用
    private int studyCost;//洗练消耗金币
    private List<Integer> studyProp;//洗练消耗道具
    private List<Integer> studyLockCost;//洗练锁定消耗

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOpenId() {
        return openId;
    }

    public void setOpenId(int openId) {
        this.openId = openId;
    }

    public int getSknMax() {
        return sknMax;
    }

    public void setSknMax(int sknMax) {
        this.sknMax = sknMax;
    }

    public int getSknIni() {
        return sknIni;
    }

    public void setSknIni(int sknIni) {
        this.sknIni = sknIni;
    }

    public List<Integer> getUnlockCost() {
        return unlockCost;
    }

    public void setUnlockCost(List<Integer> unlockCost) {
        this.unlockCost = unlockCost;
    }

    public int getStudyCost() {
        return studyCost;
    }

    public void setStudyCost(int studyCost) {
        this.studyCost = studyCost;
    }

    public List<Integer> getStudyProp() {
        return studyProp;
    }

    public void setStudyProp(List<Integer> studyProp) {
        this.studyProp = studyProp;
    }

    public List<Integer> getStudyLockCost() {
        return studyLockCost;
    }

    public void setStudyLockCost(List<Integer> studyLockCost) {
        this.studyLockCost = studyLockCost;
    }
}
