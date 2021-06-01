/**   
 * @Title: GetInvasionHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 上午10:36:17    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WorldService;

/**
 * @ClassName: GetInvasionHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月21日 上午10:36:17
 * 
 */
public class GetInvasionHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).getInvasion(this);
	}

}
