/**   
 * @Title: UseGiftCodeRsHandler.java    
 * @Package com.game.message.handler.ss    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月23日 下午6:44:57    
 * @version V1.0   
 */
package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.UseGiftCodeRs;
import com.game.server.GameServer;
import com.game.service.PlayerService;

/**
 * @ClassName: UseGiftCodeRsHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年10月23日 下午6:44:57
 * 
 */
public class UseGiftCodeRsHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		UseGiftCodeRs req = msg.getExtension(UseGiftCodeRs.ext);
		PlayerService playerService = GameServer.ac.getBean(PlayerService.class);
		playerService.useGiftCodeRs(req, this);
	}

}
