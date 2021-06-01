package com.game.domain.p;

import java.util.Map;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-21 下午7:01:26
 * @declare
 */
@Deprecated
public class TaskLive {

	private int live;
	private int liveAward;
	private Map<Integer, Integer> statusMap;

	
	public Map<Integer, Integer> getStatusMap() {
        return statusMap;
    }

    public void setStatusMap(Map<Integer, Integer> statusMap) {
        this.statusMap = statusMap;
    }

    public int getLive() {
		return live;
	}

	public void setLive(int live) {
		this.live = live;
	}

	public int getLiveAward() {
		return liveAward;
	}

	public void setLiveAward(int liveAward) {
		this.liveAward = liveAward;
	}

}
