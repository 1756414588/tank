package com.game.domain.p;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午1:58:25
 * @Description: 军团等级【排名
 */

public class PartyLvRank {

	private int rank;
	private int partyId;
	private String partyName;
	private int partyLv;
	private int scienceLv;
	private int wealLv;
	private int build;

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

	public String getPartyName() {
		return partyName;
	}

	public void setPartyName(String partyName) {
		this.partyName = partyName;
	}

	public int getPartyLv() {
		return partyLv;
	}

	public void setPartyLv(int partyLv) {
		this.partyLv = partyLv;
	}

	public int getScienceLv() {
		return scienceLv;
	}

	public void setScienceLv(int scienceLv) {
		this.scienceLv = scienceLv;
	}

	public int getWealLv() {
		return wealLv;
	}

	public void setWealLv(int wealLv) {
		this.wealLv = wealLv;
	}

	public int getBuild() {
		return build;
	}

	public void setBuild(int build) {
		this.build = build;
	}

	public PartyLvRank(int partyId, String partyName, int partyLv, int scienceLv, int wealLv, int build) {
		this.partyId = partyId;
		this.partyName = partyName;
		this.partyLv = partyLv;
		this.scienceLv = scienceLv;
		this.wealLv = wealLv;
		this.build = build;
	}

	public PartyLvRank(Party party) {
		this.partyId = party.getPartyId();
		this.partyLv = party.getPartyLv();
		this.partyName = party.getPartyName();
		this.scienceLv = party.getScienceLv();
		this.wealLv = party.getWealLv();
		this.build = party.getBuild();
	}

    @Override
    public String toString() {
        return "PartyLvRank{" +
                "rank=" + rank +
                ", partyId=" + partyId +
                ", partyName='" + partyName + '\'' +
                ", partyLv=" + partyLv +
                ", scienceLv=" + scienceLv +
                ", wealLv=" + wealLv +
                ", build=" + build +
                '}';
    }
}
