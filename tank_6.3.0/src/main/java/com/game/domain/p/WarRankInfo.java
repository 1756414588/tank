/**   
 * @Title: WarRankInfo.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author WanYi  
 * @date 2016年5月28日 下午2:23:29    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: WarRankInfo
 * @Description: 百团战排名
 * @author WanYi
 * @date 2016年5月28日 下午2:23:29
 * 
 */
public class WarRankInfo {
	private int dateTime;
	private int rank;
	private int partyId;
	private String partyName;
	
	public String getPartyName() {
		return partyName;
	}

	public void setPartyName(String partyName) {
		this.partyName = partyName;
	}

	public int getRank() {
		return rank;
	}

	public int getDateTime() {
		return dateTime;
	}

	public void setDateTime(int dateTime) {
		this.dateTime = dateTime;
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

	/**      
	* @param dateTime
	* @param rank
	* @param partyId
	* @param partyName    
	*/
	public WarRankInfo(int dateTime, int rank, int partyId, String partyName) {
		super();
		this.dateTime = dateTime;
		this.rank = rank;
		this.partyId = partyId;
		this.partyName = partyName;
	}

	/**      
	*     
	*/
	public WarRankInfo() {
		super();
	}

	@Override
	public String toString() {
		return "WarRankInfo [dateTime=" + dateTime + ", rank=" + rank + ", partyId=" + partyId + ", partyName="
				+ partyName + "]";
	}

}
