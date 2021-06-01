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
import com.game.pb.GamePb5.UsePropChooseRq;
import com.game.service.PropService;

/**
 * @ClassName: UsePropHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月14日 下午2:50:31
 * 
 */
public class UsePropChooseHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		UsePropChooseRq req = msg.getExtension(UsePropChooseRq.ext);
		getService(PropService.class).usePropChoose(req, this);
	}

}
