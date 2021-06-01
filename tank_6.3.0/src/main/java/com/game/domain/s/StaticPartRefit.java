/**   
 * @Title: StaticPartRefit.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月19日 下午5:30:17    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticPartRefit
 * @Description: 配件改造系数
 * @author ZhangJun
 * @date 2015年8月19日 下午5:30:17
 * 
 */
public class StaticPartRefit {
	private int quality;
	private int lv;
	private int fitting;
	private int plan;
	private int mineral;
	private int tool;
	private List<List<Integer>> cost;
	private int fittingExplode;
	private int planExplode;
	private int mineralExplode;
	private int toolExplode;
	private List<List<Integer>> explode;
	/**
	 * 9-10号配件的标识，9-10号配件改造和分解读取标识对应的列
	 */
	private int nineOrTen;

	public int getQuality() {
		return quality;
	}

	public void setQuality(int quality) {
		this.quality = quality;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public int getFitting() {
		return fitting;
	}

	public void setFitting(int fitting) {
		this.fitting = fitting;
	}

	public int getPlan() {
		return plan;
	}

	public void setPlan(int plan) {
		this.plan = plan;
	}

	public int getMineral() {
		return mineral;
	}

	public void setMineral(int mineral) {
		this.mineral = mineral;
	}

	public int getTool() {
		return tool;
	}

	public void setTool(int tool) {
		this.tool = tool;
	}

	public List<List<Integer>> getCost() {
		return cost;
	}

	public void setCost(List<List<Integer>> cost) {
		this.cost = cost;
	}

	public int getFittingExplode() {
		return fittingExplode;
	}

	public void setFittingExplode(int fittingExplode) {
		this.fittingExplode = fittingExplode;
	}

	public int getPlanExplode() {
		return planExplode;
	}

	public void setPlanExplode(int planExplode) {
		this.planExplode = planExplode;
	}

	public int getMineralExplode() {
		return mineralExplode;
	}

	public void setMineralExplode(int mineralExplode) {
		this.mineralExplode = mineralExplode;
	}

	public int getToolExplode() {
		return toolExplode;
	}

	public void setToolExplode(int toolExplode) {
		this.toolExplode = toolExplode;
	}

	public List<List<Integer>> getExplode() {
		return explode;
	}

	public void setExplode(List<List<Integer>> explode) {
		this.explode = explode;
	}

	public int getNineOrTen() {
		return nineOrTen;
	}

	public void setNineOrTen(int nineOrTen) {
		this.nineOrTen = nineOrTen;
	}
}
