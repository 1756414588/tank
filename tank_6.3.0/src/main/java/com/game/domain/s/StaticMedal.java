package com.game.domain.s;

import java.util.List;
/**
* @ClassName: StaticMedal 
* @Description: 勋章表
* @author
 */
public class StaticMedal {
	private int medalId;
	private String medalName;
	public String getMedalName() {
        return medalName;
    }

    public void setMedalName(String medalName) {
        this.medalName = medalName;
    }

    private int position;
	private int quality;
	private int attr1;
	private int attr2;
	private int a1;
	private int a2;
	private int b1;
	private int b2;
	private int refit;
	private int chipCount;
	private List<List<Integer>> attrShowed;
	private int explodeChipCount;
	private int transform;
	private List<List<Integer>> transformCost;
	
	public int getMedalId() {
		return medalId;
	}

	public void setMedalId(int medalId) {
		this.medalId = medalId;
	}

	public int getPosition() {
		return position;
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public int getQuality() {
		return quality;
	}

	public void setQuality(int quality) {
		this.quality = quality;
	}

	public int getAttr1() {
		return attr1;
	}

	public void setAttr1(int attr1) {
		this.attr1 = attr1;
	}

	public int getAttr2() {
		return attr2;
	}

	public void setAttr2(int attr2) {
		this.attr2 = attr2;
	}

	public int getA1() {
		return a1;
	}

	public void setA1(int a1) {
		this.a1 = a1;
	}

	public int getA2() {
		return a2;
	}

	public void setA2(int a2) {
		this.a2 = a2;
	}

	public int getB1() {
		return b1;
	}

	public void setB1(int b1) {
		this.b1 = b1;
	}

	public int getB2() {
		return b2;
	}

	public void setB2(int b2) {
		this.b2 = b2;
	}

	public int getRefit() {
		return refit;
	}

	public void setRefit(int refit) {
		this.refit = refit;
	}

	public int getChipCount() {
		return chipCount;
	}

	public void setChipCount(int chipCount) {
		this.chipCount = chipCount;
	}

	public List<List<Integer>> getAttrShowed() {
		return attrShowed;
	}

	public void setAttrShowed(List<List<Integer>> attrShowed) {
		this.attrShowed = attrShowed;
	}

	public int getExplodeChipCount() {
		return explodeChipCount;
	}

	public void setExplodeChipCount(int explodeChipCount) {
		this.explodeChipCount = explodeChipCount;
	}

    public int getTransform() {
        return transform;
    }

    public void setTransform(int transform) {
        this.transform = transform;
    }

    public List<List<Integer>> getTransformCost() {
        return transformCost;
    }

    public void setTransformCost(List<List<Integer>> transformCost) {
        this.transformCost = transformCost;
    }
}
