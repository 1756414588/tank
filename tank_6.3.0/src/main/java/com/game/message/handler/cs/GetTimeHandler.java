/**   
 * @Title: GetTimeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月8日 下午12:02:30    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: GetTimeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月8日 下午12:02:30
 * 
 */
public class GetTimeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		PlayerService playerService = getService(PlayerService.class);
		playerService.getTime(this);
	}

}
