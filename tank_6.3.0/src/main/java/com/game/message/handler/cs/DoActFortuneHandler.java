package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoActFortuneRq;
import com.game.service.ActionCenterService;

public class DoActFortuneHandler extends ClientHandler {

	@Override
	public void action() {
		DoActFortuneRq req = msg.getExtension(DoActFortuneRq.ext);
		getService(ActionCenterService.class).doActFortuneRq(req, this);
	}

}
