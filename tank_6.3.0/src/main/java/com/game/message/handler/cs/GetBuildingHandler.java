/**   
 * @Title: GetBuildingHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 下午2:23:12    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.BuildingService;

/**
 * @ClassName: GetBuildingHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月10日 下午2:23:12
 * 
 */
public class GetBuildingHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		BuildingService buildingService = getService(BuildingService.class);
		buildingService.getBuilding(this);
	}

}
