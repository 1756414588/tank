/**   
 * @Title: GetRankHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月8日 下午5:35:11    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.UseAmyPropRq;
import com.game.service.PartyService;

public class UseAmyPropHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		UseAmyPropRq req = msg.getExtension(UseAmyPropRq.ext);
		getService(PartyService.class).useAmyPropRq(req, this);
	}

}
