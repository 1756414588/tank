/**   
 * @Title: Prop.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 下午6:56:10    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Prop
 * @Description: 道具 对应s_prop表
 * @author ZhangJun
 * @date 2015年8月13日 下午6:56:10
 * 
 */
public class Prop {
	private int propId;
	private int count;

	public int getPropId() {
		return propId;
	}

	public void setPropId(int propId) {
		this.propId = propId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	/**
	 * @param propId
	 * @param count
	 */
	public Prop(int propId, int count) {
		super();
		this.propId = propId;
		this.count = count;
	}

}
