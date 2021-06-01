package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DelStoreRq;
import com.game.service.FriendService;

public class DelStoreHandler extends ClientHandler {

	@Override
	public void action() {
		DelStoreRq req = msg.getExtension(DelStoreRq.ext);
		getService(FriendService.class).delStoreRq(req, this);
	}

}
