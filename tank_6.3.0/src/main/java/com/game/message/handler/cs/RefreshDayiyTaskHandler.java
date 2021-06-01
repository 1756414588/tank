package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.TaskService;

public class RefreshDayiyTaskHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TaskService.class).refreshDayiyTask(this);
	}

}
