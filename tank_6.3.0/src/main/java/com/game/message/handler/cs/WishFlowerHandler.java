package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.WishFlowerRq;
import com.game.service.ActionCenterService;

public class WishFlowerHandler extends ClientHandler {

	@Override
	public void action() {
		WishFlowerRq req = msg.getExtension(WishFlowerRq.ext);
		getService(ActionCenterService.class).wishFlower(req, this);
	}

}
