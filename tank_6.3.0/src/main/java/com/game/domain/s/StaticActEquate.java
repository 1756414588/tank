package com.game.domain.s;

import com.game.util.CheckNull;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName StaticActEquate.java
 * @Description 坦克嘉年华活动配置表
 * @author TanDonghai
 * @date 创建时间：2016年9月14日 上午10:58:49
 *
 */
public class StaticActEquate {
	private int equateId;
	private int activityId;
	private int type;// 竖列，1为第1列，2为第2列，3为第3列
	private int kind;// 用于区分是否是同一个物品
	private List<Integer> showList;
	private List<List<Integer>> awardList;
	private int priority;

	private Map<Integer, List<Integer>> rewardMap;

	/**
	 * 获取其奖励类型
	 * 
	 * @return
	 */
	public int getAwardType() {
		if (CheckNull.isEmpty(showList)) {
			return 0;
		}
		return showList.get(0);
	}

	/**
	 * 根据物品的出现数量，获取对应的奖励
	 * 
	 * @param num
	 * @return
	 */
	public List<Integer> getRewardList(int num) {
		if (null == rewardMap) {// 初始化map
			rewardMap = new HashMap<>();
			for (List<Integer> list : awardList) {// list的格式:num,awardType,id,count
				rewardMap.put(list.get(0), list.subList(1, list.size()));
			}
		}
		return rewardMap.get(num);
	}

	public int getEquateId() {
		return equateId;
	}

	public void setEquateId(int equateId) {
		this.equateId = equateId;
	}

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getKind() {
		return kind;
	}

	public void setKind(int kind) {
		this.kind = kind;
	}

	public List<Integer> getShowList() {
		return showList;
	}

	public void setShowList(List<Integer> showList) {
		this.showList = showList;
	}

	public List<List<Integer>> getAwardList() {
		return awardList;
	}

	public void setAwardList(List<List<Integer>> awardList) {
		this.awardList = awardList;
	}

	public int getPriority() {
		return priority;
	}

	public void setPriority(int priority) {
		this.priority = priority;
	}

	@Override
	public String toString() {
		return "StaticActEquate [equateId=" + equateId + ", activityId=" + activityId + ", type=" + type + ", kind="
				+ kind + ", showList=" + showList + ", awardList=" + awardList + ", priority=" + priority + "]";
	}
}
