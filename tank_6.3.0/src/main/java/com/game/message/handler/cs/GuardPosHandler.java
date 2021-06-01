/**   
 * @Title: GuardPosHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月21日 下午2:26:31    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GuardPosRq;
import com.game.service.WorldService;

/**
 * @ClassName: GuardPosHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月21日 下午2:26:31
 * 
 */
public class GuardPosHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).guardPos(msg.getExtension(GuardPosRq.ext), this);
	}

}
