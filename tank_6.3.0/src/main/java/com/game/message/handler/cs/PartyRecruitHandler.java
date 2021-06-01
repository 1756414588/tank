/**   
 * @Title: PartyRecruitHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月21日 上午10:59:22    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ChatService;

/**
 * @ClassName: PartyRecruitHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年10月21日 上午10:59:22
 * 
 */
public class PartyRecruitHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ChatService.class).partyRecruit(this);
	}

}
