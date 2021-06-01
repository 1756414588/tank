package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author GuiJie
 * @description 组队副本
 * @created 2018/04/20 09:40
 */
public class TeamInstanceInfo {

    /**
     * 兑换次数
     */
    private Map<Integer, Integer> countInfo = new HashMap<>();
    /**
     * 通关奖励领取次数
     */
    private Map<Integer, Integer> rewardInfo = new HashMap<>();

    /**
     * 任务记录
     */
    private Map<Integer, Integer> taskInfo = new HashMap<>();
    /**
     * 任务奖励领取状态
     */
    private Map<Integer, Integer> taskRewardState = new HashMap<>();

    /**
     * 每天获得的代币数量
     */
    private int dayItemCount = 0;
    
    /**
     * 领取时间
     */
    private long time = 0;
    
    /**
     * 赏金代币总数
     */
    private int bounty = 0;
    
    
    public int getBounty() {
		return bounty;
	}

	public void setBounty(int bounty) {
		this.bounty = bounty;
	}

	public Map<Integer, Integer> getCountInfo() {
        return countInfo;
    }

    public void setCountInfo(Map<Integer, Integer> countInfo) {
        this.countInfo = countInfo;
    }

    public Map<Integer, Integer> getRewardInfo() {
        return rewardInfo;
    }

    public void setRewardInfo(Map<Integer, Integer> rewardInfo) {
        this.rewardInfo = rewardInfo;
    }

    public Map<Integer, Integer> getTaskInfo() {
        return taskInfo;
    }

    public void setTaskInfo(Map<Integer, Integer> taskInfo) {
        this.taskInfo = taskInfo;
    }

    public Map<Integer, Integer> getTaskRewardState() {
        return taskRewardState;
    }

    public void setTaskRewardState(Map<Integer, Integer> taskRewardState) {
        this.taskRewardState = taskRewardState;
    }


    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public int getDayItemCount() {
        return dayItemCount;
    }

    public void setDayItemCount(int dayItemCount) {
        this.dayItemCount = dayItemCount;
    }
}
