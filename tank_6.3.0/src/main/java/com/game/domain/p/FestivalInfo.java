package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/17 14:56
 */
public class FestivalInfo {

    private int loginTime;
    private String version ="";

    private Map<Integer, Integer> count = new HashMap<>();
    private int loginState;

    public Map<Integer, Integer> getCount() {
        return count;
    }

    public void setCount(Map<Integer, Integer> count) {
        this.count = count;
    }

    public int getLoginState() {
        return loginState;
    }

    public void setLoginState(int loginState) {
        this.loginState = loginState;
    }

    public int getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(int loginTime) {
        this.loginTime = loginTime;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }
}
