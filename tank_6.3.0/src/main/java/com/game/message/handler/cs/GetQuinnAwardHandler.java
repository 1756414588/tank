package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.QuinnService;

/**

 * @Description: 领取完成任务奖励
 */
public class GetQuinnAwardHandler extends ClientHandler {
	@Override
	public void action() {
		GameServer.ac.getBean(QuinnService.class).getQuinnAward( this);
	}

}
