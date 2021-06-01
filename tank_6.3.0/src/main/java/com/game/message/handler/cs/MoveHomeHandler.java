/**   
 * @Title: MoveHomeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月18日 下午5:46:34    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.MoveHomeRq;
import com.game.service.WorldService;

/**
 * @ClassName: MoveHomeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月18日 下午5:46:34
 * 
 */
public class MoveHomeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).moveHome(msg.getExtension(MoveHomeRq.ext), this);
	}

}
