/**   
 * @Title: PtcFormHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月29日 下午6:22:30    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.PtcFormRq;
import com.game.service.PartyService;

/**
 * @ClassName: PtcFormHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月29日 下午6:22:30
 * 
 */
public class PtcFormHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PartyService.class).ptcForm(msg.getExtension(PtcFormRq.ext).getCombatId(), this);
	}

}
