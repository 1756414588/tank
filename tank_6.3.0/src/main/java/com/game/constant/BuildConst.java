package com.game.constant;

import com.game.service.LoadService;

/**
 * 
* @ClassName: BuildConst 
* @Description: 资源生产配置
* @author
 */
public class BuildConst {
	
	/** 玩家离线超过配置时间，自产为0 */
	public static int RESOURCE_STOP_ADD_OFFTIME;
	
	
	public static void loadSystem(LoadService loadService) {
		RESOURCE_STOP_ADD_OFFTIME = loadService.getIntegerSystemValue(SystemId.RESOURCE_STOP_ADD_OFFTIME, 86400);
	}

}
