package com.game.constant;

/**
* @ClassName: ActRebelConst 
* @Description: 叛军常量
* @author
 */
public interface ActRebelConst {
	/** 等级前多少名来计算叛军等级  */
	final static int PLAYER_LEVEL_RANK = 200;
	
	/** 活动叛军 */
	static final int REBEL_TYPE_ACT = -2;//-1叛军
	
	/** 玩家活动status索引数据 */
	static final int INDEX_KILL = 0;//击杀数
	
	/** 玩家活动status索引数据 */
	static final int INDEX_SCORE = 1;//当前积分
}
