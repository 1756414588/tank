/**   
 * @Title: DbExtreme.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月26日 上午11:10:44    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: DbExtreme
 * @Description: 用来保存到数据库中的极限探险pojo
 * @author ZhangJun
 * @date 2015年9月26日 上午11:10:44
 * 
 */
public class DbExtreme {
	private int extremeId;
	private byte[] first1;
	private byte[] last3;

	public int getExtremeId() {
		return extremeId;
	}

	public void setExtremeId(int extremeId) {
		this.extremeId = extremeId;
	}

	public byte[] getFirst1() {
		return first1;
	}

	public void setFirst1(byte[] first) {
		this.first1 = first;
	}

	public byte[] getLast3() {
		return last3;
	}

	public void setLast3(byte[] last3) {
		this.last3 = last3;
	}
}
