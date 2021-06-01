/**   
 * @Title: GiftCodeHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月23日 下午6:35:34    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GiftCodeRq;
import com.game.service.PlayerService;

/**
 * @ClassName: GiftCodeHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年10月23日 下午6:35:34
 * 
 */
public class GiftCodeHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).giftCode(msg.getExtension(GiftCodeRq.ext).getCode(), this);
	}

}
