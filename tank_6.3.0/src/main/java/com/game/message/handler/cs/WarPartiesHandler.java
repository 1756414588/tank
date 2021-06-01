/**   
 * @Title: WarPartiesHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月21日 下午5:50:29    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.WarPartiesRq;
import com.game.service.WarService;

/**
 * @ClassName: WarPartiesHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年12月21日 下午5:50:29
 * 
 */
public class WarPartiesHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warParties(msg.getExtension(WarPartiesRq.ext), this);
	}

}
