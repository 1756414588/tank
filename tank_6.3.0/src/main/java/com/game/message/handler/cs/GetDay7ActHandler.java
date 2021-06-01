package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetDay7ActRq;
import com.game.service.PlayerService;

public class GetDay7ActHandler extends ClientHandler {

	@Override
	public void action() {
		GetDay7ActRq req = msg.getExtension(GetDay7ActRq.ext);
		getService(PlayerService.class).getDay7Act(req.getDay(), this);
	}

}
