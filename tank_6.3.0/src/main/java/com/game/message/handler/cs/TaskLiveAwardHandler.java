package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.TaskLiveAwardRq;
import com.game.service.TaskService;

public class TaskLiveAwardHandler extends ClientHandler {

	@Override
	public void action() {
		TaskLiveAwardRq req = msg.getExtension(TaskLiveAwardRq.ext);
		getService(TaskService.class).taskLiveAward(req, this);
	}

}
