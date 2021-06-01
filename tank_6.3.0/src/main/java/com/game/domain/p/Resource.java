/**   
 * @Title: Resource.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月17日 下午4:38:10    
 * @version V1.0   
 */
package com.game.domain.p;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

/**
 * @ClassName: Resource
 * @Description: 资源明细
 * @author ZhangJun
 * @date 2015年7月17日 下午4:38:10
 * 
 */
@SaveOptimize(level = SaveLevel.IDLE)
public class Resource implements Cloneable {
	private long lordId;
	private long iron;
	private long oil;
	private long copper;
	private long silicon;
	private long stone;
	private long ironOut;
	private long oilOut;
	private long copperOut;
	private long siliconOut;
	private long stoneOut;
	private long ironOutF;
	private int oilOutF;
	private int copperOutF;
	private int siliconOutF;
	private int stoneOutF;
	private long ironMax;
	private long oilMax;
	private long copperMax;
	private long siliconMax;
	private long stoneMax;
	private int storeF;
	private long tIron;
	private long tOil;
	private long tCopper;
	private long tSilicon;
	private long tStone;
	private int storeTime;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public long getIron() {
		return iron;
	}

	public void setIron(long iron) {
		this.iron = iron;
	}

	public long getOil() {
		return oil;
	}

	public void setOil(long oil) {
		this.oil = oil;
	}

	public long getCopper() {
		return copper;
	}

	public void setCopper(long copper) {
		this.copper = copper;
	}

	public long getSilicon() {
		return silicon;
	}

	public void setSilicon(long silicon) {
		this.silicon = silicon;
	}

	public long getStone() {
		return stone;
	}

	public void setStone(long stone) {
		this.stone = stone;
	}

	public long gettIron() {
		return tIron;
	}

	public void settIron(long tIron) {
		this.tIron = tIron;
	}

	public long gettOil() {
		return tOil;
	}

	public void settOil(long tOil) {
		this.tOil = tOil;
	}

	public long gettCopper() {
		return tCopper;
	}

	public void settCopper(long tCopper) {
		this.tCopper = tCopper;
	}

	public long gettSilicon() {
		return tSilicon;
	}

	public void settSilicon(long tSilicon) {
		this.tSilicon = tSilicon;
	}

	public long gettStone() {
		return tStone;
	}

	public void settStone(long tStone) {
		this.tStone = tStone;
	}

	public int getStoreTime() {
		return storeTime;
	}

	public void setStoreTime(int storeTime) {
		this.storeTime = storeTime;
	}

	public long getIronOut() {
		return ironOut;
	}

	public void setIronOut(long ironOut) {
		this.ironOut = ironOut;
	}

	public long getOilOut() {
		return oilOut;
	}

	public void setOilOut(long oilOut) {
		this.oilOut = oilOut;
	}

	public long getCopperOut() {
		return copperOut;
	}

	public void setCopperOut(long copperOut) {
		this.copperOut = copperOut;
	}

	public long getSiliconOut() {
		return siliconOut;
	}

	public void setSiliconOut(long siliconOut) {
		this.siliconOut = siliconOut;
	}

	public long getStoneOut() {
		return stoneOut;
	}

	public void setStoneOut(long stoneOut) {
		this.stoneOut = stoneOut;
	}

	public long getIronMax() {
		return ironMax;
	}

	public void setIronMax(long ironMax) {
		this.ironMax = ironMax;
	}

	public long getOilMax() {
		return oilMax;
	}

	public void setOilMax(long oilMax) {
		this.oilMax = oilMax;
	}

	public long getCopperMax() {
		return copperMax;
	}

	public void setCopperMax(long copperMax) {
		this.copperMax = copperMax;
	}

	public long getSiliconMax() {
		return siliconMax;
	}

	public void setSiliconMax(long siliconMax) {
		this.siliconMax = siliconMax;
	}

	public long getStoneMax() {
		return stoneMax;
	}

	public void setStoneMax(long stoneMax) {
		this.stoneMax = stoneMax;
	}

	public long getIronOutF() {
		return ironOutF;
	}

	public void setIronOutF(long ironOutF) {
		this.ironOutF = ironOutF;
	}

	public int getOilOutF() {
		return oilOutF;
	}

	public void setOilOutF(int oilOutF) {
		this.oilOutF = oilOutF;
	}

	public int getCopperOutF() {
		return copperOutF;
	}

	public void setCopperOutF(int copperOutF) {
		this.copperOutF = copperOutF;
	}

	public int getSiliconOutF() {
		return siliconOutF;
	}

	public void setSiliconOutF(int siliconOutF) {
		this.siliconOutF = siliconOutF;
	}

	public int getStoneOutF() {
		return stoneOutF;
	}

	public void setStoneOutF(int stoneOutF) {
		this.stoneOutF = stoneOutF;
	}

	@Override
	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			//Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	public int getStoreF() {
		return storeF;
	}

	public void setStoreF(int storeF) {
		this.storeF = storeF;
	}
}
