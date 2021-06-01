/**   
 * @Title: GetSeniorMapHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月15日 下午2:53:13    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SeniorMineService;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @ClassName: GetSeniorMapHandler
 * @Description: 
 * @author ZhangJun
 * @date 2016年3月15日 下午2:53:13
 * 
 */
public class GetSeniorMapHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).getSeniorMap(this);
	}

}
