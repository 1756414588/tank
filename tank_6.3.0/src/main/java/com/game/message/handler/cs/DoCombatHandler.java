/**   
 * @Title: DoCombatHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午3:37:07    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.constant.ComBatConst;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DoCombatRq;
import com.game.server.GameServer;
import com.game.service.CombatService;

/**
 * @ClassName: DoCombatHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月28日 下午3:37:07
 * 
 */
public class DoCombatHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		DoCombatRq req = msg.getExtension(DoCombatRq.ext);
		CombatService combatService = GameServer.ac.getBean(CombatService.class);
		int type = req.getType();
		if (type == ComBatConst.Combat_Normal) {
			combatService.doCombat(req, this);
		} else if(type == ComBatConst.Combat_Extreme) {
			combatService.doExtreme(req, this);
		}else {
			combatService.doExplore(req, this);
		}
	}

}
