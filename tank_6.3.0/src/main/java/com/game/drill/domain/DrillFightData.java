package com.game.drill.domain;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.constant.DrillConstant;
import com.game.constant.FormType;
import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.util.CheckNull;

/**
 * @ClassName DrillFight.java
 * @Description 玩家红蓝大战数据记录
 * @author TanDonghai
 * @date 创建时间：2016年8月9日 上午11:27:54
 *
 */
public class DrillFightData {

	private long lordId;
	private int lastEnrollDate;// 玩家最后一次报名红蓝大战的日期，格式:20160809
	private int successNum;// 胜利次数
	private int failNum;// 失败次数
	private int exploit;// 玩家在最近一次红蓝大战活动中获得的总功勋值
	private boolean isRed;// 玩家的阵营，true为红方，否则为蓝方
	private boolean campRewad;// 是否已领取本次的阵营奖励
	// key:红蓝大战的上中下路1-3
	private Map<Integer, List<Integer>> recordKeyMap = new HashMap<>();// 玩家在红蓝大战中的战报key

	private Map<Integer, DrillArmy> armyMap;

	private Map<Integer, Integer> successMap = new HashMap<>();
	private Map<Integer, Integer> failMap = new HashMap<>();

	private long fight;// 玩家战力，用于排行榜总榜排序

	public DrillFightData() {
	}

	public DrillFightData(com.game.pb.CommonPb.DrillFightData data) {
		this.lordId = data.getLordId();
		this.lastEnrollDate = data.getLastEnrollDate();
		this.successNum = data.getSuccessNum();
		this.failNum = data.getFailNum();
		this.exploit = data.getExploit();
		this.isRed = data.getIsRed();
		this.campRewad = data.getCampRewad();
		List<Integer> list;
		list = new ArrayList<>();
		recordKeyMap.put(1, list);
		for (Integer reportKey : data.getFirstRecordKeyList()) {
			list.add(reportKey);
		}
		list = new ArrayList<>();
		recordKeyMap.put(2, list);
		for (Integer reportKey : data.getSecondRecordKeyList()) {
			list.add(reportKey);
		}
		list = new ArrayList<>();
		recordKeyMap.put(3, list);
		for (Integer reportKey : data.getThirdRecordKeyList()) {
			list.add(reportKey);
		}
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getLastEnrollDate() {
		return lastEnrollDate;
	}

	public void setLastEnrollDate(int lastEnrollDate) {
		this.lastEnrollDate = lastEnrollDate;
	}

	public int getSuccessNum() {
		return successNum;
	}

	public void setSuccessNum(int successNum) {
		this.successNum = successNum;
	}

	public int getFailNum() {
		return failNum;
	}

	public void setFailNum(int failNum) {
		this.failNum = failNum;
	}

	public boolean isRed() {
		return isRed;
	}

	public void setRed(boolean isRed) {
		this.isRed = isRed;
	}

	public int getExploit() {
		return exploit;
	}

	public void setExploit(int exploit) {
		this.exploit = exploit;
	}

	public Map<Integer, List<Integer>> getRecordKeyMap() {
		return recordKeyMap;
	}

	public void setRecordKeyMap(Map<Integer, List<Integer>> recordKeyMap) {
		this.recordKeyMap = recordKeyMap;
	}

	public boolean isCampRewad() {
		return campRewad;
	}

	public void setCampRewad(boolean campRewad) {
		this.campRewad = campRewad;
	}

	public Map<Integer, DrillArmy> getArmyMap() {
		return armyMap;
	}

	public void setArmyMap(Map<Integer, DrillArmy> armyMap) {
		this.armyMap = armyMap;
	}

	public Map<Integer, Integer> getSuccessMap() {
		return successMap;
	}

	public void setSuccessMap(Map<Integer, Integer> successMap) {
		this.successMap = successMap;
	}

	public Map<Integer, Integer> getFailMap() {
		return failMap;
	}

	public int getSuccessNum(int which) {
		if (which == DrillConstant.RANK_TYPE_TOTAL) {// 获取总胜利次数
			return successNum;
		}
		Integer num = successMap.get(which);
		if (null == num) {
			return 0;
		}
		return num;
	}

	public int getFailNum(int which) {
		if (which == DrillConstant.RANK_TYPE_TOTAL) {// 获取总失败次数
			return failNum;
		}
		Integer num = failMap.get(which);
		if (null == num) {
			return 0;
		}
		return num;
	}

	/**
	 * 三路战斗结束后更新玩家的相关数据
	 */
	public void updateData() {
		successNum = 0;
		for (Integer num : successMap.values()) {
			if (null != num) {
				successNum += num;
			}
		}

		failNum = 0;
		for (Integer num : failMap.values()) {
			if (null != num) {
				failNum += num;
			}
		}
	}

	public int addSuccessNum(int which) {
		Integer num = successMap.get(which);
		if (null == num) {
			successMap.put(which, 1);
		} else {
			successMap.put(which, num + 1);
		}
		return successMap.get(which);
	}

	public void addFailNum(int which) {
		Integer num = failMap.get(which);
		if (null == num) {
			failMap.put(which, 1);
		} else {
			failMap.put(which, num + 1);
		}
	}

	public void setFailMap(Map<Integer, Integer> failMap) {
		this.failMap = failMap;
	}

	/**
	 * 记录玩家的战报key
	 * 
	 * @param which
	 * @param reportKey
	 */
	public void addReportKey(int which, int reportKey) {
		List<Integer> list = recordKeyMap.get(which);
		if (list == null) {
			list = new ArrayList<>();
			recordKeyMap.put(which, list);
		}
		list.add(reportKey);
	}

	/**
	 * 刷新玩家部队数据
	 * 
	 * @param player
	 */
	public void refreshData(Player player) {
		if (null == armyMap) {
			armyMap = new HashMap<>(2);
		} else {
			armyMap.clear();
		}

		Form form;
		for (int i = FormType.DRILL_1; i <= FormType.DRILL_3; i++) {
			form = player.forms.get(i);
			if (null != form) {
				DrillArmy army = new DrillArmy(form);
				armyMap.put(i - FormType.DRILL_1 + 1, army);
			}
		}

		fight = player.lord.getFight();
	}

	/**
	 * 清除数据
	 */
	public void clearData() {
		recordKeyMap.clear();
		campRewad = false;
		clearSuccessNum();
	}

	public void clearSuccessNum() {
		successMap.clear();
		failMap.clear();
		successNum = 0;
		failNum = 0;
		exploit = 0;
	}

	/**
	 * 获取玩家某一路的阵营信息
	 * 
	 * @param which
	 * @return
	 */
	public Form getForm(int which) {
		if (CheckNull.isEmpty(armyMap)) {
			return null;
		}
		return armyMap.get(which).form;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

}
