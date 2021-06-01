package com.game.domain.p;
/**
 * 
* @ClassName: ActRebelData 
* @Description: 活动叛军
* @author
 */
public class ActRebelData {
	private int rebelId;// 叛军id，对应s_rebel_team中的rebelId字段

	private int rebelLv;// 叛军的等级

	private int pos;// 坐标

	public ActRebelData() {
	}

	public ActRebelData(int rebelId, int rebelLv, int pos) {
		this.rebelId = rebelId;
		this.rebelLv = rebelLv;
		this.pos = pos;
	}
	
	public int getRebelId() {
		return rebelId;
	}

	public void setRebelId(int rebelId) {
		this.rebelId = rebelId;
	}

	public int getRebelLv() {
		return rebelLv;
	}

	public void setRebelLv(int rebelLv) {
		this.rebelLv = rebelLv;
	}
	
	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	@Override
	public String toString() {
		return "ActRebel [rebelId=" + rebelId + ", rebelLv=" + rebelLv + ", pos=" + pos + "]";
	}
}
