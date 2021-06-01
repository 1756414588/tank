package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.SetCrossFormRq;
import com.game.service.CrossService;

public class SetCrossFormHandler extends ClientHandler {

	@Override
	public void action() {
		SetCrossFormRq rq = msg.getExtension(SetCrossFormRq.ext);

		getService(CrossService.class).setCrossForm(rq, this);
	}

}
