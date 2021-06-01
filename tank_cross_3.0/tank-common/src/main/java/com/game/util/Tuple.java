/**   
 * @Title: Turple.java    
 * @Package com.game.util    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 下午2:54:33    
 * @version V1.0   
 */
package com.game.util;

/**
 * @ClassName: Tuple
 * @Description: 坐标的domain
 * @author ZhangJun
 * @date 2015年8月13日 下午2:54:33
 * 
 */
public class Tuple<T, V> {
	private T a;
	private V b;

	public Tuple(T a, V b) {
		this.setA(a);
		this.setB(b);
	}

	public T getA() {
		return a;
	}

	public void setA(T a) {
		this.a = a;
	}

	public V getB() {
		return b;
	}

	public void setB(V b) {
		this.b = b;
	}

}
