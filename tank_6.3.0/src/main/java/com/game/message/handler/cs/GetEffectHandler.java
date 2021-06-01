/**   
 * @Title: GetEffectHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月6日 下午3:08:31    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: GetEffectHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月6日 下午3:08:31
 * 
 */
public class GetEffectHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).getEffect(this);
	}

}
