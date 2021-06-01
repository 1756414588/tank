/**   
 * @Title: GetStaffingHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月11日 下午3:09:51    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.StaffingService;

/**
 * @ClassName: GetStaffingHandler
 * @Description: 
 * @author ZhangJun
 * @date 2016年3月11日 下午3:09:51
 * 
 */
public class GetStaffingHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(StaffingService.class).getStaffing(this);
	}

}
