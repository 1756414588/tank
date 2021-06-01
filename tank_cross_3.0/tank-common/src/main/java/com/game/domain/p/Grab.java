/**   
 * @Title: Grab.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月16日 下午2:53:16    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: Grab
 * @Description: 掠夺的资源 rs代表5种资源
 * @author ZhangJun
 * @date 2015年9月16日 下午2:53:16
 * 
 */
public class Grab {
	public long[] rs = new long[5];

	public long payload() {
		return rs[0] + rs[1] + rs[2] + rs[3] + rs[4];
	}
}
