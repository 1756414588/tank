/**   
 * @Title: DoArenaHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 下午4:24:17    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DoArenaRq;
import com.game.service.ArenaService;

/**
 * @ClassName: DoArenaHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月7日 下午4:24:17
 * 
 */
public class DoArenaHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		DoArenaRq req = msg.getExtension(DoArenaRq.ext);
		getService(ArenaService.class).doArena(req.getRank(), this);
	}

}
