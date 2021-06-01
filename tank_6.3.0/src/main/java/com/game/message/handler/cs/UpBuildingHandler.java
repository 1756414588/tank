/**   
 * @Title: UpBuildingHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 下午2:30:55    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpBuildingRq;
import com.game.service.BuildingService;

/**
 * @ClassName: UpBuildingHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月10日 下午2:30:55
 * 
 */
public class UpBuildingHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		UpBuildingRq req = msg.getExtension(UpBuildingRq.ext);
		BuildingService buildingService = getService(BuildingService.class);
		if (req.hasPos()) {
			buildingService.upMill(req, this);
		} else {
			buildingService.upBuilding(req, this);
		}

	}
}
