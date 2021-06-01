package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/07/09 13:56
 */
public class StaticActPayNew {

    private int keyId;
    private int payId;
    private int awardId;
    private int ratio1;
    private List<List<Integer>> ratio2;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getPayId() {
        return payId;
    }

    public void setPayId(int payId) {
        this.payId = payId;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getRatio1() {
        return ratio1;
    }

    public void setRatio1(int ratio1) {
        this.ratio1 = ratio1;
    }

    public List<List<Integer>> getRatio2() {
        return ratio2;
    }

    public void setRatio2(List<List<Integer>> ratio2) {
        this.ratio2 = ratio2;
    }
}
