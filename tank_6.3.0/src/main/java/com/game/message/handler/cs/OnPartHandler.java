/**   
 * @Title: OnPartHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月20日 上午11:53:20    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.OnPartRq;
import com.game.service.PartService;

/**
 * @ClassName: OnPartHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月20日 上午11:53:20
 * 
 */
public class OnPartHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		OnPartRq req = msg.getExtension(OnPartRq.ext);
		getService(PartService.class).onPart(req, this);
	}

}
