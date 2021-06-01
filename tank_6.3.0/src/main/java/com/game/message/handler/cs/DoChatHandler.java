/**   
 * @Title: DoChatHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月22日 下午4:06:11    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.DoChatRq;
import com.game.service.ChatService;

/**
 * @ClassName: DoChatHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月22日 下午4:06:11
 * 
 */
public class DoChatHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).doChat(msg.getExtension(DoChatRq.ext), this);
	}

}
