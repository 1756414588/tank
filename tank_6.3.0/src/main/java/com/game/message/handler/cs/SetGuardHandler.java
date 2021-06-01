/**   
 * @Title: SetGuardHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午12:20:16    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SetGuardRq;
import com.game.service.WorldService;

/**
 * @ClassName: SetGuardHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月21日 下午12:20:16
 * 
 */
public class SetGuardHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).setGuard(msg.getExtension(SetGuardRq.ext), this);
	}

}
