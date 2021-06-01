/**   
 * @Title: DoSomeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月6日 下午7:09:30    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DoSomeRq;
import com.game.service.GmService;

/**
 * @ClassName: DoSomeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月6日 下午7:09:30
 * 
 */
public class DoSomeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		DoSomeRq req = msg.getExtension(DoSomeRq.ext);
		getService(GmService.class).doSome(req, this);
	}

}
