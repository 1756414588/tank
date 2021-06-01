/**   
 * @Title: UsePropHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月14日 下午2:50:31    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UsePropRq;
import com.game.service.PropService;

/**
 * @ClassName: UsePropHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月14日 下午2:50:31
 * 
 */
public class UsePropHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		UsePropRq req = msg.getExtension(UsePropRq.ext);
		getService(PropService.class).useProp(req, this);
	}

}
