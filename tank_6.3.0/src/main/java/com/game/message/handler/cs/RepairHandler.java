/**   
 * @Title: RepairHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 上午11:09:49    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RepairRq;
import com.game.service.ArmyService;

/**
 * @ClassName: RepairHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月10日 上午11:09:49
 * 
 */
public class RepairHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ArmyService armyService = getService(ArmyService.class);
		RepairRq req = msg.getExtension(RepairRq.ext);
		armyService.repair(req, this);
	}

}
