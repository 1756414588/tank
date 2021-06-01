/**   
 * @Title: DoSomeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月6日 下午7:09:30    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FriendService;

/**
 * @ClassName: DoSomeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月6日 下午7:09:30
 * 
 */
public class GetStoreHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		getService(FriendService.class).getStoreRq(this);
	}

}
