package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

public class WarActivityInfo {
    private String version ="";
    private Map<Integer, Integer> info = new HashMap<>();
    private Map<Integer, Integer> rewardState = new HashMap<>();

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public Map<Integer, Integer> getInfo() {
        return info;
    }

    public void setInfo(Map<Integer, Integer> info) {
        this.info = info;
    }

    public Map<Integer, Integer> getRewardState() {
        return rewardState;
    }

    public void setRewardState(Map<Integer, Integer> rewardState) {
        this.rewardState = rewardState;
    }
}
