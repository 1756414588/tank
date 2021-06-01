/**   
 * @Title: EndWipeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月30日 上午11:02:44    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.CombatService;

/**
 * @ClassName: EndWipeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月30日 上午11:02:44
 * 
 */
public class EndWipeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(CombatService.class).endWipe(this);
	}

}
