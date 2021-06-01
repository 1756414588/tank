/**   
 * @Title: GetAidHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 上午10:36:47    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WorldService;

/**
 * @ClassName: GetAidHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月21日 上午10:36:47
 * 
 */
public class GetAidHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).getAid(this);
	}

}
