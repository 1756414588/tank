package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RecordStoreRq;
import com.game.service.FriendService;

public class RecordStoreHandler extends ClientHandler {

	@Override
	public void action() {
		RecordStoreRq req = msg.getExtension(RecordStoreRq.ext);
		getService(FriendService.class).recordStoreRq(req, this);
	}

}
