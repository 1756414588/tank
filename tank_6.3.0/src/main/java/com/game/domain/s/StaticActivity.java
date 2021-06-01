package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-12-18 下午2:47:32
 * @declare  s_activity 活动表配置
 */

public class StaticActivity {

	private int activityId;
	private String name;
	private int clean;
	private int podium;
	private int whole;
	//活动参与最小等级限制
	private int minLv;

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getClean() {
		return clean;
	}

	public void setClean(int clean) {
		this.clean = clean;
	}

	public int getPodium() {
		return podium;
	}

	public void setPodium(int podium) {
		this.podium = podium;
	}

	public int getWhole() {
		return whole;
	}

	public void setWhole(int whole) {
		this.whole = whole;
	}

    public int getMinLv() {
        return minLv;
    }

    public void setMinLv(int minLv) {
        this.minLv = minLv;
    }
}
