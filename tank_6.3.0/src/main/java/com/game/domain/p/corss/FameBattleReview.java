package com.game.domain.p.corss;

/**
 * 
* @ClassName: FameBattleReview 
* @Description: 名人堂排行玩家1-8 9-12 13-14 15 顺序排列
* @author
 */
public class FameBattleReview {
	private int pos;// 1-8 9-12 13-14 15 顺序排列
	private String name;
	private int serverId;
	private String serverName;
	private int level;
	private long fight;
	private int portrait;

	public int getPortrait() {
		return portrait;
	}

	public void setPortrait(int portrait) {
		this.portrait = portrait;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public String getServerName() {
		return serverName;
	}

	public void setServerName(String serverName) {
		this.serverName = serverName;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

}
