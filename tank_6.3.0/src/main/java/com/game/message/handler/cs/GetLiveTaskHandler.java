package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.TaskService;

public class GetLiveTaskHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TaskService.class).getLiveTask(this);
	}

}
