package com.game.domain.p;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PersonKingInfo {

    private String version = "";

    private Map<Long, PersonRankInfo> killInfo = new HashMap<>();//击杀叛军
    private Map<Long, PersonRankInfo> sourceInfo = new HashMap<>();//采集资源
    private Map<Long, PersonRankInfo> creditInfo = new HashMap<>();//获取军工
    private Map<Long, PersonRankInfo> totalKillInfo = new HashMap<>();//个人总积分
    private Map<Long, PartyRankInfo> partyInfo = new HashMap<>();//军团总积分

    public void clear() {
        killInfo.clear();
        sourceInfo.clear();
        creditInfo.clear();
        totalKillInfo.clear();
        partyInfo.clear();
    }


    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public Map<Long, PersonRankInfo> getKillInfo() {
        return killInfo;
    }

    public void setKillInfo(Map<Long, PersonRankInfo> killInfo) {
        this.killInfo = killInfo;
    }

    public Map<Long, PersonRankInfo> getSourceInfo() {
        return sourceInfo;
    }

    public void setSourceInfo(Map<Long, PersonRankInfo> sourceInfo) {
        this.sourceInfo = sourceInfo;
    }

    public Map<Long, PersonRankInfo> getCreditInfo() {
        return creditInfo;
    }

    public void setCreditInfo(Map<Long, PersonRankInfo> creditInfo) {
        this.creditInfo = creditInfo;
    }

    public Map<Long, PersonRankInfo> getTotalKillInfo() {
        return totalKillInfo;
    }

    public void setTotalKillInfo(Map<Long, PersonRankInfo> totalKillInfo) {
        this.totalKillInfo = totalKillInfo;
    }

    public Map<Long, PartyRankInfo> getPartyInfo() {
        return partyInfo;
    }

    public void setPartyInfo(Map<Long, PartyRankInfo> partyInfo) {
        this.partyInfo = partyInfo;
    }
}
