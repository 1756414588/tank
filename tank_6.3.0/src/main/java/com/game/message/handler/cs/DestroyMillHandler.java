/**   
 * @Title: DestroryMillHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月6日 上午10:02:00    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DestroyMillRq;
import com.game.service.BuildingService;

/**
 * @ClassName: DestroryMillHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月6日 上午10:02:00
 * 
 */
public class DestroyMillHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		DestroyMillRq req = msg.getExtension(DestroyMillRq.ext);
		getService(BuildingService.class).destroyMill(req.getPos(), this);
	}

}
