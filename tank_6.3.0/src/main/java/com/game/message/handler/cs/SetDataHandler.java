/**   
 * @Title: SetDataHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月28日 下午4:45:14    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SetDataRq;
import com.game.service.PlayerService;

/**
 * @ClassName: SetDataHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月28日 下午4:45:14
 * 
 */
public class SetDataHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).setData(msg.getExtension(SetDataRq.ext), this);
	}
}
