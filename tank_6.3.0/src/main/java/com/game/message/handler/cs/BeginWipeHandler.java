/**   
 * @Title: BeginWipeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月30日 上午11:02:26    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.CombatService;

/**
 * @ClassName: BeginWipeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月30日 上午11:02:26
 * 
 */
public class BeginWipeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(CombatService.class).beginWipe(this);
	}

}
