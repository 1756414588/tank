/**   
 * @Title: OlAwardHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年11月2日 下午2:48:59    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: OlAwardHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年11月2日 下午2:48:59
 * 
 */
public class OlAwardHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).olAward(this);
	}

}
