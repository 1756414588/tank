package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.TipGuyRq;
import com.game.service.TipGuyService;

public class TipGuyHandler extends ClientHandler {

	@Override
	public void action() {
		TipGuyRq req = msg.getExtension(TipGuyRq.ext);
		getService(TipGuyService.class).tipGuyRq(req, this);
	}

}
