package com.game.drill.domain;

/**
 * @ClassName DrillRecord.java
 * @Description 红蓝大战战斗记录
 * @author TanDonghai
 * @date 创建时间：2016年8月9日 上午11:38:29
 *
 */
public class DrillRecord {
	private int reportKey;
	private String attacker; // 进攻方玩家名字
	private int attackNum; // 进攻方玩家的坦克数量百分比，1~100
	private boolean attackCamp; // 进攻方玩家阵营，是否属于红方，是则为true，否则为false
	private String defender; // 防守方玩家名字
	private int defendNum; // 防守方玩家的坦克数量百分比，1~100
	private boolean defendCamp; // 防守方玩家阵营，是否属于红方，是则为true，否则为false
	private boolean result; // 进攻方是否胜利，true表示胜利
	private int time; // 时间

	public DrillRecord() {
	}

	public DrillRecord(com.game.pb.CommonPb.DrillRecord record) {
		this.reportKey = record.getReportKey();
		this.attacker = record.getAttacker();
		this.attackNum = record.getAttackNum();
		this.attackCamp = record.getAttackCamp();
		this.defender = record.getDefender();
		this.defendNum = record.getDefendNum();
		this.defendCamp = record.getDefendCamp();
		this.result = record.getResult();
		this.time = record.getTime();
	}

	public int getReportKey() {
		return reportKey;
	}

	public void setReportKey(int reportKey) {
		this.reportKey = reportKey;
	}

	public String getAttacker() {
		return attacker;
	}

	public void setAttacker(String attacker) {
		this.attacker = attacker;
	}

	public int getAttackNum() {
		return attackNum;
	}

	public void setAttackNum(int attackNum) {
		this.attackNum = attackNum;
	}

	public boolean isAttackCamp() {
		return attackCamp;
	}

	public void setAttackCamp(boolean attackCamp) {
		this.attackCamp = attackCamp;
	}

	public String getDefender() {
		return defender;
	}

	public void setDefender(String defender) {
		this.defender = defender;
	}

	public int getDefendNum() {
		return defendNum;
	}

	public void setDefendNum(int defendNum) {
		this.defendNum = defendNum;
	}

	public boolean isDefendCamp() {
		return defendCamp;
	}

	public void setDefendCamp(boolean defendCamp) {
		this.defendCamp = defendCamp;
	}

	public boolean isResult() {
		return result;
	}

	public void setResult(boolean result) {
		this.result = result;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	@Override
	public String toString() {
		return "DrillRecord [reportKey=" + reportKey + ", attacker=" + attacker + ", attackNum=" + attackNum
				+ ", attackCamp=" + attackCamp + ", defender=" + defender + ", defendNum=" + defendNum + ", defendCamp="
				+ defendCamp + ", result=" + result + ", time=" + time + "]";
	}
}
