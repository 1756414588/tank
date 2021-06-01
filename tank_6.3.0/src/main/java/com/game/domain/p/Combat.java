/**   
 * @Title: Combat.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午3:16:56    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Combat
 * @Description: 关卡
 * @author ZhangJun
 * @date 2015年8月28日 下午3:16:56
 * 
 */
public class Combat {
	private int combatId;
	private int star;

	public int getCombatId() {
		return combatId;
	}

	public void setCombatId(int combatId) {
		this.combatId = combatId;
	}

	public int getStar() {
		return star;
	}

	public void setStar(int star) {
		this.star = star;
	}

	/**      
	* @param combatId
	* @param star    
	*/
	public Combat(int combatId, int star) {
		super();
		this.combatId = combatId;
		this.star = star;
	}

	
	
}
