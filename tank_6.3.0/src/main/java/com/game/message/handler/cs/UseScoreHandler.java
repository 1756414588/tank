/**   
 * @Title: UseScore.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月9日 下午2:01:05    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UseScoreRq;
import com.game.service.ArenaService;

/**
 * @ClassName: UseScore
 * @Description: 
 * @author ZhangJun
 * @date 2015年9月9日 下午2:01:05
 * 
 */
public class UseScoreHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		UseScoreRq req = msg.getExtension(UseScoreRq.ext);
		getService(ArenaService.class).useScore(req.getPropId(), this);
	}

}
