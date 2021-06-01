/**   
 * @Title: FortressBattleParty.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author WanYi  
 * @date 2016年5月30日 下午5:35:17    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: FortressBattleParty
 * @Description: 要塞战
 * @author WanYi
 * @date 2016年5月30日 下午5:35:17
 * 
 */
public class FortressBattleParty {

	private int rank; // 排名
	private int partyId; // 军团ID
	private String partyName; // 军团名称
	private int jifen;

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

	public int getJifen() {
		return jifen;
	}

	public void setJifen(int jifen) {
		this.jifen = jifen;
	}

	@Override
	public String toString() {
		return "FortressBattleParty [rank=" + rank + ", partyId=" + partyId + ", partyName=" + partyName + ", jifen="
				+ jifen + "]";
	}

}
