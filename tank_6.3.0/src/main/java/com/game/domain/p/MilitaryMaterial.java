/**   
 * @Title: MilitaryMaterial.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author WanYi  
 * @date 2016年5月11日 下午4:12:08    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: MilitaryMaterial
 * @Description: 军工材料
 * @author WanYi
 * @date 2016年5月11日 下午4:12:08
 * 
 */
public class MilitaryMaterial {
	private int id;
	private long count;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}


	public long getCount() {
		return count;
	}

	public void setCount(long count) {
		this.count = count;
	}

	@Override
	public String toString() {
		return "MilitaryMaterial [id=" + id + ", count=" + count + "]";
	}

	/**      
	* @param id
	* @param count    
	*/
	public MilitaryMaterial(int id, long count) {
		super();
		this.id = id;
		this.count = count;
	}

}
