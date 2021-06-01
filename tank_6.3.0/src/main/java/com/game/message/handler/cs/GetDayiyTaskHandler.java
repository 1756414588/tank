package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.TaskService;

public class GetDayiyTaskHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TaskService.class).getDayiyTaskRq(this);
	}

}
