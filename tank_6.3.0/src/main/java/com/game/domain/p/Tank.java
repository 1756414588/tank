package com.game.domain.p;
/**
* @ClassName: Tank 
* @Description: 坦克
* @author
 */
public class Tank implements Cloneable {
	protected int tankId;
    protected int count; 	 //当前可用数量
	private int rest;		//可维修数量

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getRest() {
		return rest;
	}

	public void setRest(int rest) {
		this.rest = rest;
	}

	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			//Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * @param tankId
	 * @param count
	 * @param rest
	 */
	public Tank(int tankId, int count, int rest) {
		super();
		this.tankId = tankId;
		this.count = count;
		this.rest = rest;
	}

}
