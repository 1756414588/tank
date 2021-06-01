/**   
 * @Title: StaticSysParam.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author WanYi  
 * @date 2016年5月18日 下午1:30:50    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticSysParam
 * @Description: 好友祝福获得军工材料配置
 * @author WanYi
 * @date 2016年5月18日 下午1:30:50
 * 
 */
public class StaticMilitaryBless {
	private List<List<Integer>> awardOne;

	private int weight;

	public List<List<Integer>> getAwardOne() {
		return awardOne;
	}

	public void setAwardOne(List<List<Integer>> awardOne) {
		this.awardOne = awardOne;
	}

	public int getWeight() {
		return weight;
	}

	public void setWeight(int weight) {
		this.weight = weight;
	}

}
