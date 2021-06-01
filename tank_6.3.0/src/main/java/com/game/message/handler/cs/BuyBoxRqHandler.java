package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

public class BuyBoxRqHandler extends ClientHandler {
	@Override
	public void action() {
		getService(ActivityNewService.class).buyBoxRq(msg.getExtension(GamePb6.BuyBoxRq.ext),this);
	}

}
