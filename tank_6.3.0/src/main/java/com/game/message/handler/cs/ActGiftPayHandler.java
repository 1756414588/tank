package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.ActGiftPayRq;
import com.game.service.ActivityService;

public class ActGiftPayHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actGiftPayRq(msg.getExtension(ActGiftPayRq.ext), this);
	}

}
