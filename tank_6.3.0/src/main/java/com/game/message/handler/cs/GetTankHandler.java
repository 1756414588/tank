/**   
 * @Title: GetTankHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月8日 下午1:40:15    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ArmyService;

/**
 * @ClassName: GetTankHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月8日 下午1:40:15
 * 
 */
public class GetTankHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ArmyService armyService = getService(ArmyService.class);
		armyService.getTank(this);
	}

}
