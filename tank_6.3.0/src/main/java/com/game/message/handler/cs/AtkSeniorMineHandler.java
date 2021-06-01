/**   
 * @Title: AtkSeniorMineHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月15日 下午3:06:46    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.AtkSeniorMineRq;
import com.game.service.SeniorMineService;

/**
 * @ClassName: AtkSeniorMineHandler
 * @Description: 
 * @author ZhangJun
 * @date 2016年3月15日 下午3:06:46
 * 
 */
public class AtkSeniorMineHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).attack(msg.getExtension(AtkSeniorMineRq.ext), this);
	}

}
