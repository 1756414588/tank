package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SeachPlayerRq;
import com.game.service.FriendService;

public class SeachPlayerHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		SeachPlayerRq req = msg.getExtension(SeachPlayerRq.ext);
		getService(FriendService.class).seachPlayer(req, this);
	}

}
