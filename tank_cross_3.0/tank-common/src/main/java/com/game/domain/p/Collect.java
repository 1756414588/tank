/**   
 * @Title: Collect.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月7日 下午2:52:46    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Collect
 * @Description: 部队采集项
 * @author ZhangJun
 * @date 2015年12月7日 下午2:52:46
 * 
 */
public class Collect {
	public long load;// 载重
	public int speed;// 采集速度加成
	
	@Override
	public String toString() {
		return "Collect [load=" + load + ", speed=" + speed + "]";
	}
}
