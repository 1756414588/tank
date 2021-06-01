/**   
 * @Title: SetBossAutoFightHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年1月5日 下午6:37:11    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.SetBossAutoFightRq;
import com.game.service.BossService;

/**
 * @ClassName: SetBossAutoFightHandler
 * @Description: 
 * @author ZhangJun
 * @date 2016年1月5日 下午6:37:11
 * 
 */
public class SetBossAutoFightHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BossService.class).setAutoFight(msg.getExtension(SetBossAutoFightRq.ext), this);
	}

}
