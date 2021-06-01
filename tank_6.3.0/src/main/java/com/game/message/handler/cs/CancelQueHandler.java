/**   
 * @Title: CancelQueHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 下午6:02:07    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.CancelQueRq;
import com.game.service.ArmyService;
import com.game.service.BuildingService;
import com.game.service.PropService;
import com.game.service.ScienceService;

/**
 * @ClassName: CancelQueHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月13日 下午6:02:07
 * 
 */
public class CancelQueHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		CancelQueRq req = msg.getExtension(CancelQueRq.ext);
		int type = req.getType();
		if (type == 1) {
			getService(BuildingService.class).cancelQue(req, this);
		} else if (type == 2) {
			getService(ArmyService.class).cancelTankQue(req, this);
		} else if (type == 3) {
			getService(ArmyService.class).cancelRefitQue(req, this);
		} else if (type == 4) {
			getService(PropService.class).cancelPropQue(req, this);
		} else if (type == 5) {
			getService(ScienceService.class).cancelScienceQue(req, this);
		}
	}
}
