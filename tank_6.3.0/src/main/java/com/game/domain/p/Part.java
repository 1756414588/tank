/**   
 * @Title: Part.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月19日 下午5:42:18    
 * @version V1.0   
 */
package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @ClassName: Part
 * @Description: 玩家的配件
 * @author ZhangJun
 * @date 2015年8月19日 下午5:42:18
 * 
 */
public class Part {
	private int keyId; // 自增的id，每次获得一个配件+1
	private int partId; // 对应配件表
	private int upLv; // 强化等级
	private int refitLv; // 改造等级
	private int pos; // 1，2，3，4分别对应兵种，5表示未装配
	private boolean locked; // 是否加锁
	private int smeltLv; // 当前淬炼等级
	private int smeltExp; // 当前等级淬炼经验
	private Map<Integer, Integer[]> smeltAttr = new HashMap<>(); // 淬炼属性
	private boolean saved; // 是否保存萃取

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getPartId() {
		return partId;
	}

	public void setPartId(int partId) {
		this.partId = partId;
	}

	public int getUpLv() {
		return upLv;
	}

	public void setUpLv(int upLv) {
		this.upLv = upLv;
	}

	public int getRefitLv() {
		return refitLv;
	}

	public void setRefitLv(int refitLv) {
		this.refitLv = refitLv;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public boolean isLocked() {
		return locked;
	}

	public void setLocked(boolean locked) {
		this.locked = locked;
	}

	public int getSmeltLv() {
		return smeltLv;
	}

	public void setSmeltLv(int smeltLv) {
		this.smeltLv = smeltLv;
	}

	public int getSmeltExp() {
		return smeltExp;
	}

	public void setSmeltExp(int smeltExp) {
		this.smeltExp = smeltExp;
	}

	public Map<Integer, Integer[]> getSmeltAttr() {
		return smeltAttr;
	}

	public void setSmeltAttr(Map<Integer, Integer[]> smeltAttr) {
		this.smeltAttr = smeltAttr;
	}

	public boolean isSaved() {
		return saved;
	}

	public void setSaved(boolean saved) {
		this.saved = saved;
	}

	/**
	 * @param keyId
	 * @param partId
	 * @param upLv
	 * @param refitLv
	 * @param pos
	 */
	public Part(int keyId, int partId, int upLv, int refitLv, int pos, boolean locked, int smeltLv, int smeltExp,
			Map<Integer, Integer[]> attr, boolean saved) {
		super();
		this.keyId = keyId;
		this.partId = partId;
		this.upLv = upLv;
		this.refitLv = refitLv;
		this.pos = pos;
		this.locked = locked;
		this.smeltLv = smeltLv;
		this.smeltExp = smeltExp;
		this.smeltAttr = attr;
		this.saved = saved;
	}

	@Override
	public String toString() {
		return "Part{" + "keyId=" + keyId + ", partId=" + partId + ", upLv=" + upLv + ", refitLv=" + refitLv + ", pos="
				+ pos + ", locked=" + locked + ", smeltLv=" + smeltLv + ", smeltExp=" + smeltExp + ", smeltAttr="
				+ smeltAttr + ", saved=" + saved + '}';
	}

	/**
	 * 配件转换
	 */
	public void partConvert(Part part) {
		this.upLv = part.getUpLv();
		this.refitLv = part.getRefitLv();
		this.locked = part.isLocked();
		this.smeltLv = part.getSmeltLv();
		this.smeltExp = part.getSmeltExp();
		this.smeltAttr = part.getSmeltAttr();
		this.saved = part.isSaved();
	}


}
