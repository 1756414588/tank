package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BlessFriendRq;
import com.game.service.FriendService;

public class BlessFriendHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		BlessFriendRq req = msg.getExtension(BlessFriendRq.ext);
		getService(FriendService.class).blessFriendRq(req, this);
	}

}
