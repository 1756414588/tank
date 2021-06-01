package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午1:58:25
 * @Description: 军团战力排名
 */
public class PartyRank implements Cloneable {

	private int rank;
	private int partyId;
	private long fight;
	private int level;

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public PartyRank() {
	}

	public PartyRank(int partyId, int partyLv) {
		this.partyId = partyId;
		this.level = partyLv;
	}

	public PartyRank(int partyId, int partyLv, long fight) {
		this.partyId = partyId;
		this.level = partyLv;
		this.fight = fight;
	}

	public PartyRank(Party party) {
		this.partyId = party.getPartyId();
		this.fight = party.getFight();
		this.level = party.getPartyLv();
	}
}
