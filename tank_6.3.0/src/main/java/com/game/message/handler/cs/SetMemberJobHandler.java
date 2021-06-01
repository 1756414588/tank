package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SetMemberJobRq;
import com.game.service.PartyService;

public class SetMemberJobHandler extends ClientHandler {

	@Override
	public void action() {
		SetMemberJobRq req = msg.getExtension(SetMemberJobRq.ext);
		getService(PartyService.class).setMemberJobRq(req, this);
	}

}
