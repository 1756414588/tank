package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.RecvDay7ActAwardRq;
import com.game.service.PlayerService;

public class RecvDay7ActAwardHandler extends ClientHandler {

	@Override
	public void action() {
		RecvDay7ActAwardRq req = msg.getExtension(RecvDay7ActAwardRq.ext);
		getService(PlayerService.class).recvDay7ActAward(req.getKeyId(), this);
	}

}
