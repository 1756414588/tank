package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.MarkStoreRq;
import com.game.service.FriendService;

public class MarkStoreHandler extends ClientHandler {

	@Override
	public void action() {
		MarkStoreRq req = msg.getExtension(MarkStoreRq.ext);
		getService(FriendService.class).markStoreRq(req, this);
	}

}
