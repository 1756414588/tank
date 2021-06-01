/**   
 * @Title: WarState.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月23日 上午11:49:54    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: WarState
 * @Description: 百团大战状态
 * @author ZhangJun
 * @date 2015年12月23日 上午11:49:54
 * 
 */
public interface WarState {
	final int REG_STATE = 1;// 报名中
	final int PREPAIR_STATE = 2;// 准备中
	final int FIGHT_STATE = 3;// 战斗中
	final int FIGHT_END = 4;// 战斗结束
	final int WAR_END = 5;// 团战结束
	final int CANCEL_STATE = 6;// 团战取消
}
