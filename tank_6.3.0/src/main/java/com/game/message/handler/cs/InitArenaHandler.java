/**   
 * @Title: InitArenaHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 下午5:10:50    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.InitArenaRq;
import com.game.service.ArenaService;

/**
 * @ClassName: InitArenaHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月7日 下午5:10:50
 * 
 */
public class InitArenaHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		InitArenaRq req = msg.getExtension(InitArenaRq.ext);
		getService(ArenaService.class).initArena(req, this);
	}

}
