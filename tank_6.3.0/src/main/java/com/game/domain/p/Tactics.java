package com.game.domain.p;

public class Tactics {

    private int keyId;//唯一id
    private int tacticsId;//战术id
    private int lv;//等级
    private int exp;//等级exp
    private int use;//是否佩戴  0没有  1佩戴
    private int state;//是否突破  0没有  1已经突破，这个只有在需要突破的等级才会生效
    private int bind;//是否绑定

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getTacticsId() {
        return tacticsId;
    }

    public void setTacticsId(int tacticsId) {
        this.tacticsId = tacticsId;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getExp() {
        return exp;
    }

    public void setExp(int exp) {
        this.exp = exp;
    }

    public int getUse() {
        return use;
    }

    public void setUse(int use) {
        this.use = use;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    public int getBind() {
        return bind;
    }

    public void setBind(int bind) {
        this.bind = bind;
    }

    /**
     * 用于打印日志
     *
     * @return
     */
    @Override
    public String toString() {
        return keyId + "|" + tacticsId + "|" + lv + "|" + exp + "|" + use + "|" + state;
    }
}
