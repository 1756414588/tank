package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActPartResolveRq;
import com.game.service.ActionCenterService;

public class DoActPartResolveHandler extends ClientHandler {

	@Override
	public void action() {
		DoActPartResolveRq req = msg.getExtension(DoActPartResolveRq.ext);
		getService(ActionCenterService.class).doActPartResolveRq(req, this);
	}

}
