/**   
 * @Title: DefenseNPC.java    
 * @Package com.game.fortressFight.domain    
 * @Description:   
 * @author WanYi  
 * @date 2016年6月4日 下午2:02:45    
 * @version V1.0   
 */
package com.game.fortressFight.domain;


/**
 * @ClassName: DefenseNPC
 * @Description: 防守方NPC
 * @author WanYi
 * @date 2016年6月4日 下午2:02:45
 * 
 */
public class DefenceNPC extends Defence {
	private int index; // npc序号(400个)
	private int exploreId = 701;

	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}

	public int getExploreId() {
		return exploreId;
	}

	public void setExploreId(int exploreId) {
		this.exploreId = exploreId;
	}
	
}
