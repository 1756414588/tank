package com.game.constant;

import com.game.service.LoadService;

/**
 * 
* @ClassName: AirshipConst 
* @Description: 飞艇
* @author
 */
public class AirshipConst {
	/** 组队部队状态 撤销*/
	public static int TEAM_STATE_CANCEL = 1;
	
	/** 组队部队状态 状态改变*/
	public static int TEAM_STATE_ARMY_CHANGE = 2;

	/** 创建队伍*/
    public static int TEAM_STATUS_CREATE = 1;

    /** 队伍变化 [加入队伍,离开队伍,队伍开始行军]*/
    public static int TEAM_STATUS_UPDATE = 2;

    /** 删除队伍[ 队伍准备阶段被队长删除, 行军开始的时候部队列表为空自动删除, 行军过程当中部队全部撤回自动删除]*/
    public static int TEAM_STATUS_DELETE = 3;

    /**工会军团张和副军团长每天有1次的免费创建队伍的机会*/
    public static int AIRSHIP_FREE_CREATE_TEAM_COUNT = 1;



	
	/**飞艇战事准备时间*/
	public static int AIRSHIP_BEGAIN_SECOND;
	
	/**飞艇进攻默认行军时间*/
	public static int AIRSHIP_ATTACK_MARCH_SECOND;
	
	/**飞艇部队进攻增加时间*/
	public static int AIRSHIP_ATTACK_MARCH_ADD_SECOND;
	
	/**飞艇进攻部队撤回时间*/
	public static int AIRSHIP_ATTACK_RETREAT_SECOND;
	
	/**飞艇驻军撤回时间*/
	public static int AIRSHIP_GUARD_RETREAT_SECOND;
	
	/**飞艇部队永久损失比例*/
	public static int AIRSHIP_HAUST_TANK_RATIO;
	
	/**飞艇部队进攻失效返回*/
	public static int AIRSHIP_ATTACK_FAIL_RETREAT_SECOND;
	
	/**飞艇部队驻军行军时间*/
	public static int AIRSHIP_GUARD_MARCH_SECOND;
	
	/**飞艇成功占领后的安全时间*/
	public static int AIRSHIP_SAFE_TIME;

	/**每次重建修复飞艇耐久度*/
	public static int AIRSHIP_REBUILD_DURABILITY = 500;

	/**飞艇满耐久度的值*/
    public static int AIRSHIP_REBUILD_DURABILITY_MAX = 10000;

    /**侦查有效期30分钟*/
    public static int AIRSHIP_SCOUT_VALID_TIME = 30;

	public static void loadSystem(LoadService loadService) {
		AIRSHIP_BEGAIN_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_BEGAIN_SECOND, 0);
		AIRSHIP_ATTACK_MARCH_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_ATTACK_MARCH_SECOND, 0);
		AIRSHIP_ATTACK_MARCH_ADD_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_ATTACK_MARCH_ADD_SECOND, 0);
		AIRSHIP_ATTACK_RETREAT_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_ATTACK_RETREAT_SECOND, 0);
		AIRSHIP_GUARD_RETREAT_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_GUARD_RETREAT_SECOND, 0);
		AIRSHIP_HAUST_TANK_RATIO = loadService.getIntegerSystemValue(SystemId.AIRSHIP_HAUST_TANK_RATIO, 0);
		AIRSHIP_ATTACK_FAIL_RETREAT_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_ATTACK_FAIL_RETREAT_SECOND, 0);
		AIRSHIP_GUARD_MARCH_SECOND = loadService.getIntegerSystemValue(SystemId.AIRSHIP_GUARD_MARCH_SECOND, 0);
		AIRSHIP_SAFE_TIME = loadService.getIntegerSystemValue(SystemId.AIRSHIP_SAFE_TIME, 0);
	}
}
