/**   
 * @Title: ResetSkillHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月4日 下午2:36:28    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: ResetSkillHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月4日 下午2:36:28
 * 
 */
public class ResetSkillHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).resetSkill(this);
	}

}
