package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

public class GetActPartResolveHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getActPartResolveRq(this);
	}

}
