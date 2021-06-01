/**   
 * @Title: CombatBoxHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月3日 上午11:19:50    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.CombatBoxRq;
import com.game.service.CombatService;

/**
 * @ClassName: CombatBoxHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月3日 上午11:19:50
 * 
 */
public class CombatBoxHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		CombatBoxRq req = msg.getExtension(CombatBoxRq.ext);
		getService(CombatService.class).combatBox(req, this);
	}

}
