package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActVipGiftRq;
import com.game.service.ActivityService;

public class DoActVipGiftHandler extends ClientHandler {

	@Override
	public void action() {
		DoActVipGiftRq req = msg.getExtension(DoActVipGiftRq.ext);
		getService(ActivityService.class).doActVipGiftRq(req, this);
	}

}
