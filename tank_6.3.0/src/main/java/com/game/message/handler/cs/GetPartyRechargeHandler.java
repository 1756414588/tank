package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

public class GetPartyRechargeHandler extends ClientHandler{

	public void action() {
		getService(ActivityService.class).getPartyRecharge(this);
	}

}
