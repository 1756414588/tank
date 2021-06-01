/**   
 * @Title: StaticSection.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午12:04:36    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticSection
 * @Description: 大关卡
 * @author ZhangJun
 * @date 2015年8月28日 下午12:04:36
 * 
 */
public class StaticSection {
	private int sectionId;
	private int rank;
	private int type;
	private List<List<Integer>> box1;
	private List<List<Integer>> box2;
	private List<List<Integer>> box3;
	private int startId;
	private int endId;

	public int getSectionId() {
		return sectionId;
	}

	public void setSectionId(int sectionId) {
		this.sectionId = sectionId;
	}

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public List<List<Integer>> getBox1() {
		return box1;
	}

	public void setBox1(List<List<Integer>> box1) {
		this.box1 = box1;
	}

	public List<List<Integer>> getBox2() {
		return box2;
	}

	public void setBox2(List<List<Integer>> box2) {
		this.box2 = box2;
	}

	public List<List<Integer>> getBox3() {
		return box3;
	}

	public void setBox3(List<List<Integer>> box3) {
		this.box3 = box3;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getEndId() {
		return endId;
	}

	public void setEndId(int endId) {
		this.endId = endId;
	}

	public int getStartId() {
		return startId;
	}

	public void setStartId(int startId) {
		this.startId = startId;
	}

}
