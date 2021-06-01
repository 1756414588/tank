package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.TaskService;

public class TaskDaylyResetHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TaskService.class).taskDaylyReset(this);
	}

}
