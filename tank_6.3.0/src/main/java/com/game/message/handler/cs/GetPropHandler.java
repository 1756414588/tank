/**   
 * @Title: GetPropHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月14日 下午2:49:35    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PropService;

/**
 * @ClassName: GetPropHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月14日 下午2:49:35
 * 
 */
public class GetPropHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PropService.class).getProp(this);
	}

}
