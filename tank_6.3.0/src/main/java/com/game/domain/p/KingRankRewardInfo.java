package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

public class KingRankRewardInfo {

    private String version = "";//版本号

    private Map<Integer, Integer> pointsStatus = new HashMap<>(); //条件奖励状态
    private Map<Integer, Integer> rankStatus = new HashMap<>();//排行榜奖励状态


    public String getVersion() {
        return version;
    }

    public void clear() {
        pointsStatus.clear();
        rankStatus.clear();
    }

    public Map<Integer, Integer> getPointsStatus() {
        return pointsStatus;
    }

    public Map<Integer, Integer> getRankStatus() {
        return rankStatus;
    }

    public void setVersion(String version) {
        this.version = version;
    }
}
