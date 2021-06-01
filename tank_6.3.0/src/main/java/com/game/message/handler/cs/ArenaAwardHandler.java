/**   
 * @Title: ArenaAwardHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月9日 下午2:00:47    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ArenaService;

/**
 * @ClassName: ArenaAwardHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月9日 下午2:00:47
 * 
 */
public class ArenaAwardHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ArenaService.class).arenaAward(this);
	}

}
