/**   
 * @Title: BeginGameHandler.java    
 * @Package com.game.message.handler    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月3日 下午12:45:00    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BeginGameRq;
import com.game.service.PlayerService;

/**
 * @ClassName: BeginGameHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月3日 下午12:45:00
 * 
 */
public class BeginGameHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		PlayerService playerService = getService(PlayerService.class);
		BeginGameRq req = msg.getExtension(BeginGameRq.ext);

		playerService.beginGame(req, this);
	}
}
