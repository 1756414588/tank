/**   
 * @Title: StaticEquip.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月18日 上午11:16:23    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticEquip
 * @Description: 装备配置
 * @author ZhangJun
 * @date 2015年8月18日 上午11:16:23
 * 
 */
public class StaticEquip {
	private int equipId;
	private String equipName;
	private int quality;
	private int attributeId;
	private int a;
	private int b;
	private int price;
	private int transform;
	private List<List<Integer>> cost; 

	public int getEquipId() {
		return equipId;
	}

	public void setEquipId(int equipId) {
		this.equipId = equipId;
	}

	public int getQuality() {
		return quality;
	}

	public void setQuality(int quality) {
		this.quality = quality;
	}

	public int getAttributeId() {
		return attributeId;
	}

	public void setAttributeId(int attributeId) {
		this.attributeId = attributeId;
	}

	public int getA() {
		return a;
	}

	public void setA(int a) {
		this.a = a;
	}

	public int getB() {
		return b;
	}

	public void setB(int b) {
		this.b = b;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public String getEquipName() {
		return equipName;
	}

	public void setEquipName(String equipName) {
		this.equipName = equipName;
	}

	public int getTransform() {
		return transform;
	}

	public void setTransform(int transform) {
		this.transform = transform;
	}

	public List<List<Integer>> getCost() {
		return cost;
	}

	public void setCost(List<List<Integer>> cost) {
		this.cost = cost;
	}

}
