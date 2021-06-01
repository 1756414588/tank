package com.game.domain.p.corss;

/**
 * 
* @ClassName: FamePojo 
* @Description:名人堂头衔玩家 id :1冠军 2亚军 3季军 4殿军 5 人气王
* @author
 */
public class FamePojo {
	private int id;// 1冠军 2亚军 3季军 4殿军 5 人气王
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

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
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
