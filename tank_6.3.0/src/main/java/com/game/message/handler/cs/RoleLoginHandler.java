/**   
 * @Title: RoleLoginHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月6日 下午6:14:09    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: RoleLoginHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月6日 下午6:14:09
 * 
 */
public class RoleLoginHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		PlayerService playerService = getService(PlayerService.class);
		playerService.roleLogin(this);
	}
}
