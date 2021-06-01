/**   
 * @Title: SetFormHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月8日 下午3:37:08    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SetFormRq;
import com.game.service.ArmyService;

/**
 * @ClassName: SetFormHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月8日 下午3:37:08
 * 
 */
public class SetFormHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.message.handler.Handler#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		SetFormRq req = msg.getExtension(SetFormRq.ext);
		ArmyService armyService = getService(ArmyService.class);
		armyService.setForm(req, this);
	}

}
