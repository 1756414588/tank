package com.game.service.teaminstance;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class Team {
    // 自增的队伍ID
    private static AtomicInteger autoId = new AtomicInteger(1);

    public Team() {
    }

    public Team(long captainId, int teamType) {
        this.captainId = captainId;
        this.teamType = teamType;
        this.teamId = autoId.getAndIncrement();
        this.status = TeamConstant.UN_READY;
        initOrder();
        this.order.set(0, captainId);
        membersInfo.put(captainId, TeamConstant.READY);
    }

    private int teamId;
    private long captainId;
    private int teamType;
    private int status;
    private HashMap<Long, Integer> membersInfo = new HashMap<>();
    // order中会使用数字0L 来进行占位，使用时需小心
    private List<Long> order = new ArrayList<>();

    public int getTeamId() {
        return teamId;
    }

    public void setTeamId(int teamId) {
        this.teamId = teamId;
    }

    public long getCaptainId() {
        return captainId;
    }

    public void setCaptainId(long captainId) {
        this.captainId = captainId;
    }

    public HashMap<Long, Integer> getMembersInfo() {
        return membersInfo;
    }

    public void setMembersInfo(HashMap<Long, Integer> membersInfo) {
        this.membersInfo = membersInfo;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getTeamType() {
        return teamType;
    }

    public void setTeamType(int teamType) {
        this.teamType = teamType;
    }

    public List<Long> getOrder() {
        return order;
    }

    public void setOrder(List<Long> order) {
        this.order = order;
    }

    /**
     * 初始化队伍顺序，使用0占位
     */
    private void initOrder() {
        for (int i = 0; i < TeamConstant.TEAM_LIMIT; i++) {
            this.order.add(0L);
        }
    }
}