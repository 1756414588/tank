/**   
 * @Title: WarRankJiFenInfo.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author WanYi  
 * @date 2016年5月31日 下午2:43:09    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: WarRankJiFenInfo
 * @Description: 军团战积分排名
 * @author WanYi
 * @date 2016年5月31日 下午2:43:09
 * 
 */
public class WarRankJiFenInfo {
	private int partyId;
	private String partyName;
	private int jiFen;

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

	public int getJiFen() {
		return jiFen;
	}

	public void setJiFen(int jiFen) {
		this.jiFen = jiFen;
	}

	/**
	 * @param partyId
	 * @param partyName
	 * @param jiFen
	 */
	public WarRankJiFenInfo(int partyId, String partyName, int jiFen) {
		super();
		this.partyId = partyId;
		this.partyName = partyName;
		this.jiFen = jiFen;
	}

	/**      
	*     
	*/
	public WarRankJiFenInfo() {
		super();
	}

	@Override
	public String toString() {
		return "WarRankJiFenInfo [partyId=" + partyId + ", partyName=" + partyName + ", jiFen=" + jiFen + "]";
	}
	
	

}
