package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.AcceptTaskRq;
import com.game.service.TaskService;

public class AcceptTaskHandler extends ClientHandler {

	@Override
	public void action() {
		AcceptTaskRq req = msg.getExtension(AcceptTaskRq.ext);
		getService(TaskService.class).acceptTaskRq(req, this);
	}

}
