/**   
 * @Title: StaticBuilding.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月20日 下午3:40:51    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticBuilding
 * @Description: 建筑配置
 * @author ZhangJun
 * @date 2015年7月20日 下午3:40:51
 * 
 */
public class StaticBuilding {
	private int buildingId;
	private String name;
	private int type;
	private int canUp;
	private int canDestory;
	private int canResource;
	private int canProduct;
	private int proDefault;
	private List<Integer> proBuyPrice;
	private int initLv;
	private int pros;
	private int pros2;

	public int getBuildingId() {
		return buildingId;
	}

	public void setBuildingId(int buildingId) {
		this.buildingId = buildingId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getCanUp() {
		return canUp;
	}

	public void setCanUp(int canUp) {
		this.canUp = canUp;
	}

	public int getCanDestory() {
		return canDestory;
	}

	public void setCanDestory(int canDestory) {
		this.canDestory = canDestory;
	}

	public int getInitLv() {
		return initLv;
	}

	public void setInitLv(int initLv) {
		this.initLv = initLv;
	}

	public int getPros() {
		return pros;
	}

	public void setPros(int pros) {
		this.pros = pros;
	}

	public int getCanResource() {
		return canResource;
	}

	public void setCanResource(int canResource) {
		this.canResource = canResource;
	}

    public int getCanProduct() {
        return canProduct;
    }

    public void setCanProduct(int canProduct) {
        this.canProduct = canProduct;
    }

    public int getProDefault() {
        return proDefault;
    }

    public void setProDefault(int proDefault) {
        this.proDefault = proDefault;
    }

    public List<Integer> getProBuyPrice() {
        return proBuyPrice;
    }

    public void setProBuyPrice(List<Integer> proBuyPrice) {
        this.proBuyPrice = proBuyPrice;
    }

	public int getPros2() {
		return pros2;
	}

	public void setPros2(int pros2) {
		this.pros2 = pros2;
	}
}
