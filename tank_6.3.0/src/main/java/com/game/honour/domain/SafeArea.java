package com.game.honour.domain;

import com.game.util.Tuple;

/**
 * @author: LiFeng
 * @date:
 * @description:安全区
 */
public class SafeArea {
	private int beginx;
	private int beginy;
	private int endx;
	private int endy;
	private int phase; // 阶段
	// 是否需要通知客户端刷新安全区的标记，当阶段改变，或边界移动了一个单位以上时，为true;
	private boolean flag = false;

	public int getBeginx() {
		return beginx;
	}

	public void setBeginx(int beginx) {
		this.beginx = beginx;
	}

	public int getBeginy() {
		return beginy;
	}

	public void setBeginy(int beginy) {
		this.beginy = beginy;
	}

	public int getEndx() {
		return endx;
	}

	public void setEndx(int endx) {
		this.endx = endx;
	}

	public int getEndy() {
		return endy;
	}

	public void setEndy(int endy) {
		this.endy = endy;
	}

	public int getPhase() {
		return phase;
	}

	public void setPhase(int phase) {
		this.phase = phase;
	}

	public boolean isFlag() {
		return flag;
	}

	public void setFlag(boolean flag) {
		this.flag = flag;
	}

	/**
	 * 当未缩圈，安全区为正方形时的构造方法
	 * 
	 * @param pos 中心点坐标
	 * @param halfLength 半边长
	 * @param phase 当前阶段
	 */
	public SafeArea(Tuple<Integer, Integer> pos, int halfLength, int phase) {
		this.beginx = pos.getA() - halfLength;
		this.endx = pos.getA() + halfLength;
		this.beginy = pos.getB() - halfLength;
		this.endy = pos.getB() + halfLength;
		this.phase = phase;
	}

	/**
	 * 缩小安全区时实时更新安全区边界坐标
	 * 
	 * @param last 上一个未缩圈时的安全区大小
	 * @param next 下一个未缩圈时的安全区大小
	 * @param rate 当前缩圈进度
	 * @param phase 当前阶段
	 */
	public void refresh(SafeArea last, SafeArea next, float rate, int phase) {
		int oldBeginx = this.beginx;
		int oldBeginy = this.beginy;
		int oldEndx = this.endx;
		int oldEndy = this.endy;

		this.beginx = last.getBeginx() + (int) ((next.getBeginx() - last.getBeginx()) * rate);
		this.endx = last.getEndx() - (int) ((last.getEndx() - next.getEndx()) * rate);
		this.beginy = last.getBeginy() + (int) ((next.getBeginy() - last.getBeginy()) * rate);
		this.endy = last.getEndy() - (int) ((last.getEndy() - next.getEndy()) * rate);
		this.phase = phase;

		if (Math.abs(beginx - oldBeginx) >= 1 || Math.abs(endx - oldEndx) >= 1 || Math.abs(endy - oldEndy) >= 1
				|| Math.abs(beginy - oldBeginy) >= 1) {
			this.flag = true;
		} else {
			this.flag = false;
		}

	}

	public SafeArea() {

	}


	public int isSafe(int pos) {
		int x = pos % 600;
		int y = pos / 600;
		if (x >= beginx && x <= endx && y >= beginy && y <= endy)
			return 1;
		return -1;
	}

}
