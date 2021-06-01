/**   
 * @Title: BossState.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月30日 下午3:58:04    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: BossState
 * @Description: boss状态
 * @author ZhangJun
 * @date 2015年12月30日 下午3:58:04
 * 
 */
public interface BossState {
	final int INIT_STATE = 0;// 初始
	final int PREPAIR_STATE = 1;// 准备中
	final int FIGHT_STATE = 2;// 战斗中
	final int BOSS_DIE = 3;// BOSS挂了
	final int BOSS_END = 4;// 战斗结束，boss存活
}
