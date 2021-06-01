/**   
 * @Title: ArmyState.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月15日 下午6:53:53    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: ArmyState
 * @Description: 单位状态
 * @author ZhangJun
 * @date 2015年9月15日 下午6:53:53
 * 
 */
public interface ArmyState {
	// 行军
	int MARCH = 1;

	// 返回
	int RETREAT = 2;

	// 采集
	int COLLECT = 3;

	// 驻军
	int GUARD = 4;

	// 等待
	int WAIT = 5;

	// 援助行军
	int AID = 6;

	// 参与军团战
	int WAR = 7;
	
	// 参与要塞战
	int FortessBattle = 8;
	
	/** 军事演习（红蓝大战） */
	int DRILL = 9;
	
	/** 飞艇部队 准备中*/
	int AIRSHIP_BEGAIN = 15;
	
	/** 飞艇部队 行军中 */
	int AIRSHIP_MARCH = 16;
	
	/** 飞艇部队 驻防行军中*/
	int AIRSHIP_GUARD_MARCH = 17;
	
	/** 飞艇部队 驻防中*/
	int AIRSHIP_GUARD = 18;
}
