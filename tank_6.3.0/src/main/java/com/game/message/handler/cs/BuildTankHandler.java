/**   
 * @Title: BuildTankHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月11日 下午5:04:04    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuildTankRq;
import com.game.service.ArmyService;

/**
 * @ClassName: BuildTankHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月11日 下午5:04:04
 * 
 */
public class BuildTankHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		BuildTankRq req = msg.getExtension(BuildTankRq.ext);
		ArmyService armyService = getService(ArmyService.class);
		armyService.buildTank(req, this);
	}

}
