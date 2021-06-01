/**   
 * @Title: BuyExploreHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月1日 下午6:29:28    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuyExploreRq;
import com.game.service.CombatService;

/**
 * @ClassName: BuyExploreHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月1日 下午6:29:28
 * 
 */
public class BuyExploreHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		BuyExploreRq req = msg.getExtension(BuyExploreRq.ext);
		getService(CombatService.class).buyExplore(req.getType(), this);
	}

}
