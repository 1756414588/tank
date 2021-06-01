package com.game.domain.p.corssParty;

/**
 * 跨服军团战名人堂明细
* @ClassName: CPFame 
* @Description: TODO
* @author
 */
public class CPFame {
	private int type;
	private String serverName;
	private String name;
	private int portrait;

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public String getServerName() {
		return serverName;
	}

	public void setServerName(String serverName) {
		this.serverName = serverName;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getPortrait() {
		return portrait;
	}

	public void setPortrait(int portrait) {
		this.portrait = portrait;
	}

}
