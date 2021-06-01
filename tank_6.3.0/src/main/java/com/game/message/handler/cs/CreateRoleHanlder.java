/**   
 * @Title: CreateRoleHanlder.java    
 * @Package com.game.message.handler    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月3日 下午12:48:25    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.CreateRoleRq;
import com.game.service.PlayerService;

/**
 * @ClassName: CreateRoleHanlder
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月3日 下午12:48:25
 * 
 */
public class CreateRoleHanlder extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		CreateRoleRq req = msg.getExtension(CreateRoleRq.ext);
		PlayerService playerService = getService(PlayerService.class);
		playerService.createRole(req, this);
	}
	
}
