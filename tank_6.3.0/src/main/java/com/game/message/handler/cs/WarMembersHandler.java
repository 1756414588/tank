/**   
 * @Title: WarMembersHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月21日 下午5:48:46    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WarService;

/**
 * @ClassName: WarMembersHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年12月21日 下午5:48:46
 * 
 */
public class WarMembersHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warMembers(this);
	}

}
