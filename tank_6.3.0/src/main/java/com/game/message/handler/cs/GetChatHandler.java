/**   
 * @Title: GetChatHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午6:21:38    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ChatService;

/**
 * @ClassName: GetChatHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月21日 下午6:21:38
 * 
 */
public class GetChatHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).getChat(this);
	}

}
