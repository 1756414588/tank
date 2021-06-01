/**   
 * @Title: SpeedQueHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月14日 下午4:05:10    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SpeedQueRq;
import com.game.service.*;

/**
 * @ClassName: SpeedQueHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月14日 下午4:05:10
 * 
 */
public class SpeedQueHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		SpeedQueRq req = msg.getExtension(SpeedQueRq.ext);
		int type = req.getType();
		if (type == 1) {// 建筑升级
			getService(BuildingService.class).speedQue(req, this);
		} else if (type == 2) {// 生产坦克
			getService(ArmyService.class).speedTankQue(req, this);
		} else if (type == 3) {// 改装坦克
			getService(ArmyService.class).speedRefitQue(req, this);
		} else if (type == 4) {
			getService(PropService.class).speedPropQue(req, this);
		} else if (type == 5) {
			getService(ScienceService.class).speedScienceQue(req, this);
		} else if (type == 6) {
			getService(WorldService.class).speedArmy(req, this);
		}
	}

}
