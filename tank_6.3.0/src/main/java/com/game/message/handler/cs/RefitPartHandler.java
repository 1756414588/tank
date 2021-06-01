/**   
 * @Title: RefitPartHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月20日 下午12:31:51    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RefitPartRq;
import com.game.service.PartService;

/**
 * @ClassName: RefitPartHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月20日 下午12:31:51
 * 
 */
public class RefitPartHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		RefitPartRq req = msg.getExtension(RefitPartRq.ext);
		getService(PartService.class).refitPart(req, this);
	}

}
