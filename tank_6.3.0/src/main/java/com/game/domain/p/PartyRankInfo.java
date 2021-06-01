package com.game.domain.p;

public class PartyRankInfo {

    private long partyId; //军团Id
    private long points; //积分
    private long time; //最后更新积分时间

    public long getPartyId() {
        return partyId;
    }

    public void setPartyId(long partyId) {
        this.partyId = partyId;
    }

    public long getPoints() {
        return points;
    }

    public void setPoints(long points) {
        this.points = points;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }
}
