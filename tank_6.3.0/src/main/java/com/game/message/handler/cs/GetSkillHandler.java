/**   
 * @Title: GetSkillHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月4日 下午2:35:45    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**
 * @ClassName: GetSkillHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月4日 下午2:35:45
 * 
 */
public class GetSkillHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).getSkill(this);
	}

}
