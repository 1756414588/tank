/**   
 * @Title: ExplodePartHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月20日 上午11:51:11    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.ExplodePartRq;
import com.game.service.PartService;

/**
 * @ClassName: ExplodePartHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月20日 上午11:51:11
 * 
 */
public class ExplodePartHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ExplodePartRq req = msg.getExtension(ExplodePartRq.ext);
		getService(PartService.class).explodePart(req, this);
	}

}
