/**   
 * @Title: SearchOlHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月22日 下午4:07:14    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SearchOlRq;
import com.game.service.ChatService;

/**
 * @ClassName: SearchOlHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月22日 下午4:07:14
 * 
 */
public class SearchOlHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).searchOl(msg.getExtension(SearchOlRq.ext).getName(), this);
	}

}
