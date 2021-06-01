package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.UpMemberJobRq;
import com.game.service.PartyService;

public class UpMemberJobHandler extends ClientHandler {

	@Override
	public void action() {
		UpMemberJobRq req = msg.getExtension(UpMemberJobRq.ext);
		getService(PartyService.class).upMemberJob(req, this);
	}

}
