/**   
 * @Title: SctSeniorMineHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月15日 下午3:07:12    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.SctSeniorMineRq;
import com.game.service.SeniorMineService;

/**
 * @ClassName: SctSeniorMineHandler
 * @Description: 
 * @author ZhangJun
 * @date 2016年3月15日 下午3:07:12
 * 
 */
public class SctSeniorMineHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).scout(msg.getExtension(SctSeniorMineRq.ext).getPos(), this);
	}

}
