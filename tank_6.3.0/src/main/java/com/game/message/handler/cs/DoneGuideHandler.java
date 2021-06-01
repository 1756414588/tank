/**   
 * @Title: DoneGuideHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月12日 上午11:45:57    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: DoneGuideHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月12日 上午11:45:57
 * 
 */
public class DoneGuideHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).doneGuide(this);
	}

}
