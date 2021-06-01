package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class BountyInfo {
	
	 /**
     * 兑换物品次数
     */
    private Map<Integer, Integer> shopInfo = new HashMap<>();

	public Map<Integer, Integer> getShopInfo() {
		return shopInfo;
	}

	public void setShopInfo(Map<Integer, Integer> shopInfo) {
		this.shopInfo = shopInfo;
	}
    
}
