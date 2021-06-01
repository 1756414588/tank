/**   
 * @Title: CombinePartHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月20日 上午11:48:34    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.CombinePartRq;
import com.game.service.PartService;

/**
 * @ClassName: CombinePartHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月20日 上午11:48:34
 * 
 */
public class CombinePartHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		CombinePartRq req = msg.getExtension(CombinePartRq.ext);
		getService(PartService.class).combinePart(req, this);
	}

}
