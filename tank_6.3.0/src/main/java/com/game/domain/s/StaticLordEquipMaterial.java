package com.game.domain.s;

/**
 * @author zhangdh
 * @ClassName: StaticLordEquipMaterial
 * @Description: 军备材料
 * @date 2017/4/26 15:48
 */
public class StaticLordEquipMaterial {
    private int id;
    private String name;
    private int quality;
    private int formula;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getFormula() {
        return formula;
    }

    public void setFormula(int formula) {
        this.formula = formula;
    }

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
    
}
