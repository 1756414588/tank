/**   
 * @Title: ScoutPosHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月18日 下午4:58:59    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.ScoutPosRq;
import com.game.service.WorldService;

/**
 * @ClassName: ScoutPosHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月18日 下午4:58:59
 * 
 */
public class ScoutPosHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ScoutPosRq req = msg.getExtension(ScoutPosRq.ext);
		getService(WorldService.class).scoutPos(req.getPos(), this);
	}

}
