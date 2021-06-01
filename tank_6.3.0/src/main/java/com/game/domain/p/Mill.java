/**   
 * @Title: Mill.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月4日 下午3:53:57    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Mill
 * @Description: 工厂
 * @author ZhangJun
 * @date 2015年9月4日 下午3:53:57
 * 
 */
public class Mill {
	private int pos;
	private int id;
	private int lv;

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	/**      
	* @param pos
	* @param id
	* @param lv    
	*/
	public Mill(int pos, int id, int lv) {
		super();
		this.pos = pos;
		this.id = id;
		this.lv = lv;
	}

	
}
