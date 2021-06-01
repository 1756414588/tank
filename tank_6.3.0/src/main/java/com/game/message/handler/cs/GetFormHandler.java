/**   
 * @Title: GetFormHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月8日 下午2:52:36    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ArmyService;

/**
 * @ClassName: GetFormHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月8日 下午2:52:36
 * 
 */
public class GetFormHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ArmyService armyService = getService(ArmyService.class);
		armyService.getForm(this);
	}

}
