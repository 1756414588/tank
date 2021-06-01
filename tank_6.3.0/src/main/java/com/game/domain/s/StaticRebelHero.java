package com.game.domain.s;

/**
 * @ClassName StaticRebelHero.java
 * @Description 叛军将领配置
 * @author TanDonghai
 * @date 创建时间：2016年9月6日 下午4:55:12
 *
 */
public class StaticRebelHero {
	private int heroPick;// 将领搭配
	private int teamType;// 部队类型
	private int levelDown;// 等级下限
	private int levelup;// 等级上限
	private int associate;// 关联
	private int right;// 出现权重
	private int fight;// 将领战斗力
	private int heroDrop;// 掉落将领
	private int dropProbability;// 掉落几率
	private int limitation;// 活动掉落限制。例如：1表示只会掉落一个。

	public int getHeroPick() {
		return heroPick;
	}

	public void setHeroPick(int heroPick) {
		this.heroPick = heroPick;
	}

	public int getTeamType() {
		return teamType;
	}

	public void setTeamType(int teamType) {
		this.teamType = teamType;
	}

	public int getLevelDown() {
		return levelDown;
	}

	public void setLevelDown(int levelDown) {
		this.levelDown = levelDown;
	}

	public int getLevelup() {
		return levelup;
	}

	public void setLevelup(int levelup) {
		this.levelup = levelup;
	}

	public int getAssociate() {
		return associate;
	}

	public void setAssociate(int associate) {
		this.associate = associate;
	}

	public int getRight() {
		return right;
	}

	public void setRight(int right) {
		this.right = right;
	}

	public int getFight() {
		return fight;
	}

	public void setFight(int fight) {
		this.fight = fight;
	}

	public int getHeroDrop() {
		return heroDrop;
	}

	public void setHeroDrop(int heroDrop) {
		this.heroDrop = heroDrop;
	}

	public int getDropProbability() {
		return dropProbability;
	}

	public void setDropProbability(int dropProbability) {
		this.dropProbability = dropProbability;
	}

	public int getLimitation() {
		return limitation;
	}

	public void setLimitation(int limitation) {
		this.limitation = limitation;
	}

	@Override
	public String toString() {
		return "StaticRebelHero [heroPick=" + heroPick + ", teamType=" + teamType + ", levelDown=" + levelDown
				+ ", levelup=" + levelup + ", associate=" + associate + ", right=" + right + ", fight=" + fight
				+ ", heroDrop=" + heroDrop + ", dropProbability=" + dropProbability + ", limitation=" + limitation
				+ "]";
	}
}
