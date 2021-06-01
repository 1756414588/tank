package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.service.teaminstance.TeamInstanceService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class GetTaskStatusHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TeamInstanceService.class).getTaskStatus(this);
	}

}
