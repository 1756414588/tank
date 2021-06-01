/**   
 * @Title: Ruins.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author WanYi  
 * @date 2016年4月26日 下午2:10:23    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Ruins
 * @Description: 废墟
 * @author WanYi
 * @date 2016年4月26日 下午2:10:23
 * 
 */
public class Ruins {
	private boolean isRuins;
	private long lordId;
	private String attackerName ="";

	public boolean isRuins() {
		return isRuins;
	}

	public void setRuins(boolean isRuins) {
		this.isRuins = isRuins;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public String getAttackerName() {
		return attackerName;
	}

	public void setAttackerName(String attackerName) {
		this.attackerName = attackerName;
	}
	
}
