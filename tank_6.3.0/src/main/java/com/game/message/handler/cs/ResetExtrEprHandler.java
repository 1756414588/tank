/**   
 * @Title: ResetExtrEprHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月1日 下午6:31:08    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.CombatService;

/**
 * @ClassName: ResetExtrEprHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月1日 下午6:31:08
 * 
 */
public class ResetExtrEprHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(CombatService.class).resetExtrEpr(this);
	}

}
