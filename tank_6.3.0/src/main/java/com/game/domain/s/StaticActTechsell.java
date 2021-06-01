package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/07/10 17:33
 */
public class StaticActTechsell {


    private int awardId;
    private List<Integer> techId;
    private int resource;
    private int lv;

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public List<Integer> getTechId() {
        return techId;
    }

    public void setTechId(List<Integer> techId) {
        this.techId = techId;
    }

    public int getResource() {
        return resource;
    }

    public void setResource(int resource) {
        this.resource = resource;
    }

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}
    
}
