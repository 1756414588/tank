/**   
 * @Title: GetEquipHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月18日 下午2:41:51    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.EquipService;

/**
 * @ClassName: GetEquipHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月18日 下午2:41:51
 * 
 */
public class GetEquipHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(EquipService.class).getEquip(this);
	}

}
