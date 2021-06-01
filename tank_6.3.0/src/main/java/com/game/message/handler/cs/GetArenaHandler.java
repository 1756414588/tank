/**   
 * @Title: GetArenaHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 下午3:38:07    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ArenaService;

/**
 * @ClassName: GetArenaHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月7日 下午3:38:07
 * 
 */
public class GetArenaHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ArenaService.class).getArena(this);
	}

}
