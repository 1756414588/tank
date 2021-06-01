/**   
 * @Title: RptTank.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月17日 下午4:19:02    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: RptTank
 * @Description: 坦克消耗
 * @author ZhangJun
 * @date 2015年9月17日 下午4:19:02
 * 
 */
public class RptTank {
	private int tankId;
	private int count;

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

	/**
	 * @param tankId
	 * @param count
	 */
	public RptTank(int tankId, int count) {
		super();
		this.tankId = tankId;
		this.count = count;
	}

    @Override
    public String toString() {
        return "RptTank{" +
                "tankId=" + tankId +
                ", count=" + count +
                '}';
    }
}
