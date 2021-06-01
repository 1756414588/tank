/**   
 * @Title: FirstActType.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 下午5:45:12    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: FirstActType
 * @Description: 先手设定常量
 * @author ZhangJun
 * @date 2015年9月7日 下午5:45:12
 * 
 */
public interface FirstActType {
	// 进攻方先手
	final int ATTACKER = 1;

	// 防守方先手
	final int DEFENCER = 2;

	// 先手值判断,先手值相同防守方先手
	final int FISRT_VALUE_1 = 3;

	// 先手值判断,先手值相同进攻方方先手
	final int FISRT_VALUE_2 = 4;

	// 红蓝大战的先手值判断,先手值相同，战力高的先手
	final int FISRT_VALUE_DRILL = 5;
}
