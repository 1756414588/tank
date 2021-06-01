/**   
 * @Title: GetLordHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月8日 上午11:10:31    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: GetLordHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月8日 上午11:10:31
 * 
 */
public class GetPendantHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		PlayerService playerService = getService(PlayerService.class);
		playerService.getPendant(this);
	}
}
