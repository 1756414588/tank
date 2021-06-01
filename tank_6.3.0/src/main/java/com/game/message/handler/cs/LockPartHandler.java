/**   
 * @Title: UpPartHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月20日 下午12:29:54    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.LockPartRq;
import com.game.service.PartService;

/**
 * @ClassName: UpPartHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月20日 下午12:29:54
 * 
 */
public class LockPartHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		LockPartRq req = msg.getExtension(LockPartRq.ext);
		getService(PartService.class).lockPart(req, this);
	}

}
