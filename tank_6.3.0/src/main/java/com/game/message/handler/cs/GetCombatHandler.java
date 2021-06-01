/**   
 * @Title: GetCombatHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午3:33:17    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.CombatService;

/**
 * @ClassName: GetCombatHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月28日 下午3:33:17
 * 
 */
public class GetCombatHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		GameServer.ac.getBean(CombatService.class).getCombat(this);
	}

}
