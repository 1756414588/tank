package com.game.domain.p;


/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/17 14:56
 */
public class LuckyInfo {

    private int useLuckyCount;
    private int recharge;
    private String version ="";

    public int getUseLuckyCount() {
        return useLuckyCount;
    }

    public void setUseLuckyCount(int useLuckyCount) {
        this.useLuckyCount = useLuckyCount;
    }

    public int getRecharge() {
        return recharge;
    }

    public void setRecharge(int recharge) {
        this.recharge = recharge;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }
}
